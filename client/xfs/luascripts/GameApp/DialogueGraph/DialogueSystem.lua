-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueSystem.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("DialogueSystem")
local UIConst = require("Const.UIConst")
local Utils = require("Common.Utils.Utils")
local ClientUtils = require("Utils.ClientUtils")
local Class = require("Core.Framework.Class")
local EventConst = require("Const.EventConst")
local ClientConst = require("Const.ClientConst")
local HotkeyConst = require("Const.HotkeyConst")
local MessageName = require("Const.MessageName")
local SystemBase = require("GameApp.Core.SystemBase")
local ConflictTypes = require("Common.ConflictTypes")
local SysConfigData = require("Data.sys_config_data")
local EModelUtils = require("Entities.Utils.EModelUtils")
local SafeCallback = require("Core.Framework.SafeCallback")
local DialogueGraphConst = require("Const.DialogueGraphConst")
local DialogueGraphConfig = require("Data.dialogue_graph_data")
local DialogueItemCmd = require("GameApp.DialogueGraph.DialogueItemCmd")
local DialogueGraphUtils = require("GameApp.DialogueGraph.DialogueGraphUtils")
local InteractionSignSystem = require("GameApp.InteractionSign.InteractionSignSystem")
local SafeCallbackWithStatusAndReturn = require("Core.Framework.SafeCallbackWithStatusAndReturn")
local DialogueStateKey = DialogueGraphConst.DIALOGUE_STATE_KEY
local DialogueSystem = Class.LightClass("DialogueSystem", SystemBase)

function DialogueSystem:onCtor()
	self.dialogueCacheList = {}
	self.dialogueRunningList = {}
	self.stateData = {}
	self.isEnterDialogueConflict = false
	self.pendingFinishRpcList = {}
end

function DialogueSystem:initSystem()
	return
end

function DialogueSystem:getMessageBindMap()
	return {
		[MessageName.UI_ON_CLOSE] = "onUIClose",
		[MessageName.ON_PLAYER_ENTER_SPACE] = "onPlayerEnterSpace",
		[MessageName.UI_ON_VISIBLE_CHANGE] = "onUIVisibleChange"
	}
end

function DialogueSystem:onSceneLoaded(sceneId, sceneName)
	if not pg.me or not pg.me.space then
		return
	end

	self:playDialogueGraphList()
end

function DialogueSystem:onPlayerEnterSpace()
	self:playDialogueGraphList()
end

function DialogueSystem:onTick()
	self:retryReqToServerFinishRpc()
end

function DialogueSystem:playDialogueGraphList()
	if self:isLoadingScene() then
		return
	end

	for i = #self.dialogueCacheList, 1, -1 do
		local dialogueInfo = self.dialogueCacheList[i]

		if dialogueInfo ~= nil then
			if not self:canPlayDialogueGraph(dialogueInfo.dialogueId) then
				table.remove(self.dialogueCacheList, i)
				self:unloadCachedDialogueRequest(dialogueInfo)
			elseif DialogueGraphUtils.isInWhiteList(dialogueInfo.dialogueId) then
				table.remove(self.dialogueCacheList, i)
				DialogueGraphUtils.unPreloadCutScenes(dialogueInfo.preloadCutscenes)
				self:completeDialogueRequest(dialogueInfo.dialogueId, dialogueInfo.context, dialogueInfo.onFinishCallback, dialogueInfo.extraData)
			else
				local decision, interruptIds = self:resolvePlaybackDecision(dialogueInfo.dialogueId)

				if decision == DialogueGraphConst.PLAYBACK_DECISION.DISCARD then
					table.remove(self.dialogueCacheList, i)
					self:unloadCachedDialogueRequest(dialogueInfo)
				elseif decision ~= DialogueGraphConst.PLAYBACK_DECISION.QUEUE then
					table.remove(self.dialogueCacheList, i)

					if decision == DialogueGraphConst.PLAYBACK_DECISION.INTERRUPT then
						for _, id in ipairs(interruptIds) do
							self:stopDialogueGraph(id, DialogueGraphConst.FINISHED_REASON.INTERRUPTED_PRIORITY)
						end
					end

					if self:isDialoguePlaying(dialogueInfo.dialogueId) then
						if LoggerManager.checkLogger(LoggerConst.INFO) then
							logger:info("当前对话图正在播放，先停止", dialogueInfo.dialogueId)
						end

						self:stopDialogueGraph(dialogueInfo.dialogueId, DialogueGraphConst.FINISHED_REASON.INTERRUPTED_PLAYING)
					end

					self:startPlayDialogue(dialogueInfo)
				end
			end
		else
			table.remove(self.dialogueCacheList, i)
		end
	end
end

function DialogueSystem:playDialogueGraph(dialogueGraphId, onFinishCallback, variables, context, extraData)
	if not self:isDialogueGraphIdValid(dialogueGraphId) then
		self:finishDialogueRequest(dialogueGraphId, DialogueGraphConst.RET_FLAG_FAILED, onFinishCallback, extraData)

		return
	end

	if self:isDialoguePlaying(dialogueGraphId) then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			logger:info("当前对话图正在播放", dialogueGraphId)
		end

		self:finishDialogueRequest(dialogueGraphId, DialogueGraphConst.RET_FLAG_FAILED, onFinishCallback, extraData)

		return
	end

	if self:isLoadingScene() then
		local dialogueInfo = self:initDialogueGraphInfo(dialogueGraphId, onFinishCallback, variables, context, extraData)

		self:insertToCacheListSorted(dialogueInfo)

		return
	end

	if not self:canPlayDialogueGraph(dialogueGraphId) then
		self:finishDialogueRequest(dialogueGraphId, DialogueGraphConst.RET_FLAG_FAILED, onFinishCallback, extraData)

		return
	end

	if DialogueGraphUtils.isInWhiteList(dialogueGraphId) then
		self:completeDialogueRequest(dialogueGraphId, context, onFinishCallback, extraData)

		return
	end

	local decision, interruptIds = self:resolvePlaybackDecision(dialogueGraphId)

	if decision == DialogueGraphConst.PLAYBACK_DECISION.DISCARD then
		self:finishDialogueRequest(dialogueGraphId, DialogueGraphConst.RET_FLAG_FAILED, onFinishCallback, extraData)

		return
	end

	local dialogueInfo = self:initDialogueGraphInfo(dialogueGraphId, onFinishCallback, variables, context, extraData)

	if decision == DialogueGraphConst.PLAYBACK_DECISION.QUEUE then
		self:insertToCacheListSorted(dialogueInfo)

		return
	elseif decision == DialogueGraphConst.PLAYBACK_DECISION.INTERRUPT then
		for _, id in ipairs(interruptIds) do
			self:stopDialogueGraph(id, DialogueGraphConst.FINISHED_REASON.INTERRUPTED_PRIORITY)
		end
	end

	self:startPlayDialogue(dialogueInfo)
end

function DialogueSystem:startPlayDialogue(dialogueInfo)
	local ret, errors = ClientUtils.tryWithLogError(function()
		local dialogueCmd = self:createDialogueCmd(dialogueInfo)

		if dialogueCmd == nil then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("创建剧情失败", dialogueInfo.dialogueId)
			end

			return
		end

		if LoggerManager.checkLogger(LoggerConst.INFO) then
			logger:info("播放剧情", dialogueInfo.dialogueId)
		end

		self.dialogueRunningList[dialogueCmd.id] = dialogueCmd

		dialogueCmd:play()
	end)

	if not ret then
		self:stopDialogueGraph(dialogueInfo.dialogueId)

		if dialogueInfo.onFinishCallback ~= nil then
			dialogueInfo.onFinishCallback(false)
		end

		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("播放剧情失败", dialogueInfo.dialogueId, errors)
		end
	end
end

function DialogueSystem:createDialogueCmd(dialogueInfo)
	local dialogueCmd = DialogueItemCmd(dialogueInfo)

	return dialogueCmd
end

function DialogueSystem:initDialogueGraphInfo(dialogueId, onFinishCallback, variables, context, extraData)
	local task = {}

	task.dialogueId = dialogueId
	task.config = DialogueGraphConfig[dialogueId]
	task.onFinishCallback = onFinishCallback
	task.nodeRunningFunc = extraData ~= nil and extraData.nodeRunningFunc or self.onGraphNodeRunning
	task.startCmdCallback = self.onDialogueCmdStart
	task.endCmdCallback = self.onDialogueCmdFinished
	task.scheduleRPCCallback = self.onDialogueCmdScheduleRPC
	task.sysOwner = self
	task.variables = variables and Utils.deepCopyTable(variables) or nil
	task.context = context
	task.extraData = extraData
	task.preloadCutscenes = DialogueGraphUtils.preloadCutscenes(task.config.preloadCutscenes)

	return task
end

function DialogueSystem:onDialogueCmdStart(dialogueCmd)
	if dialogueCmd == nil then
		return
	end

	dialogueCmd.startTime = pg.me:getGameTime()

	if dialogueCmd.config.registMsg == true then
		self:registAllMessage()
	end

	pg.me:ReqPlayDialogueGraph(dialogueCmd.id, dialogueCmd.taskInfo.context)

	if dialogueCmd.extraData ~= nil and dialogueCmd.extraData.onStartCBFunc then
		dialogueCmd.extraData.onStartCBFunc()
	end

	self:setEntitiesVisible(dialogueCmd.id, dialogueCmd.taskInfo.config.initInfo, false)
	pg.global.eventEmitter:emit(EventConst.DIALOGUE_GRAPH_ON_START, dialogueCmd.id)
	facade:sendMsgToUI(MessageName.DIALOGUE_GRAPH_ON_START)
	DialogueGraphUtils.sendDialogueGraphReport(dialogueCmd.id, 0)

	if DialogueGraphUtils.canShowID() then
		pg.global.ui:open(UIConst.UI_ID_DIALOGUE_ID)
	end
end

function DialogueSystem:onGraphNodeRunning(dialogueCmd, funcType, param)
	local funcInfo = DialogueGraphConst.NODE_FUNC_MAP[funcType]
	local result = true

	if funcInfo and funcInfo.priority ~= nil then
		for k, v in pairs(self.dialogueRunningList) do
			local cmd = v

			if cmd.id ~= dialogueCmd.id then
				if cmd:checkNodeInCriticalFuncState() then
					if LoggerManager.checkLogger(LoggerConst.INFO) then
						logger:info("对话被打断 CRITICAL curGraph %d priority %d newGraph %d priority %d", dialogueCmd.id, cmd.id)
					end

					self:stopDialogueGraph(dialogueCmd.id, DialogueGraphConst.FINISHED_REASON.INTERRUPTED_CRITICAL)

					result = false

					break
				elseif funcInfo.priority == DialogueGraphConst.NODE_PRIORTTY.CRITICAL then
					if cmd:checkNodeFuncTypeInState(funcType) then
						if LoggerManager.checkLogger(LoggerConst.INFO) then
							logger:info("对话被打断 CRITICAL curGraph %d priority %d newGraph %d priority %d", dialogueCmd.id, cmd.id)
						end

						self:stopDialogueGraph(dialogueCmd.id, DialogueGraphConst.FINISHED_REASON.INTERRUPTED_CRITICAL)

						result = false

						break
					end
				elseif funcInfo.priority == DialogueGraphConst.NODE_PRIORTTY.HIGH and (cmd:checkNodeFuncTypeHasState(funcType) or cmd:checkNodeFuncTypeTakeOver(funcType, param)) then
					local curPriority = cmd.config.priority or 0
					local newPriority = dialogueCmd.config.priority or 0

					if newPriority ~= nil and (curPriority == nil or curPriority <= newPriority) then
						self:stopDialogueGraph(cmd.id, DialogueGraphConst.FINISHED_REASON.INTERRUPTED_PRIORITY)

						if LoggerManager.checkLogger(LoggerConst.INFO) then
							logger:info("对话被打断 HIGH curGraph %d priority %d newGraph %d priority %d", cmd.id, curPriority, dialogueCmd.id, newPriority)
						end

						result = true

						break
					else
						self:stopDialogueGraph(dialogueCmd.id, DialogueGraphConst.FINISHED_REASON.INTERRUPTED_PRIORITY)

						if LoggerManager.checkLogger(LoggerConst.INFO) then
							logger:info("对话被打断 HIGH curGraph %d priority %d newGraph %d priority %d", dialogueCmd.id, newPriority, cmd.id, curPriority)
						end

						result = false

						break
					end
				end
			end
		end
	end

	if funcType == DialogueGraphConst.NODE_FUNC_TYPE.DIALOGUE_SET_MODEL then
		self:setDialogueGraphModel(dialogueCmd, param)
	end

	return result
end

function DialogueSystem:stopDialogueGraph(dialogueId, reason)
	local dialogueCmd = self.dialogueRunningList[dialogueId]

	if dialogueCmd == nil then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			logger:info("剧情Cmd不存在，无法Stop", dialogueId)
		end

		return
	end

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("停止剧情 stopDialogueGraph ", dialogueCmd.id, reason)
	end

	dialogueCmd:stop(reason)
end

function DialogueSystem:stopAllDialogueGraph(reason)
	for i = 1, #self.dialogueCacheList do
		DialogueGraphUtils.unPreloadCutScenes(self.dialogueCacheList[i].preloadCutscenes)
	end

	table.clearArray(self.dialogueCacheList)

	for k, v in pairs(self.dialogueRunningList) do
		self:stopDialogueGraph(v.id, reason)
	end
end

function DialogueSystem:onDialogueCmdFinished(retFlag, cmd, reason)
	SafeCallback(self.setDialogueStateConflict, self, cmd.id, false)
	SafeCallback(self.hideTopLogo, self, cmd.id, false)
	SafeCallback(self.hideAllUI, self, cmd.id, false)
	SafeCallback(self.hideInteractionSign, self, cmd.id, false)
	SafeCallback(self.hideMarkShare, self, cmd.id, false)
	SafeCallback(self.disableSpaceFollow, self, cmd.id, false)
	SafeCallback(self.setBlockEvent, self, cmd.id, false)
	SafeCallback(self.resetEntitiesVisible, self, cmd.id)
	SafeCallback(self.restoreAmbientIntensity, self, cmd)

	local input = pg.game.input

	SafeCallback(input.enablePlayerInput, input, true, HotkeyConst.INPUT_BLOCK_FLAG.Move)

	input.lockCameraZoom = false

	SafeCallback(cmd.destroy, cmd)

	self.dialogueRunningList[cmd.id] = nil

	if pg.me == nil then
		if self:canUnregistMsg() then
			self:unregistAllMessage()
		end

		return
	end

	if cmd.taskInfo.onFinishCallback then
		SafeCallback(cmd.taskInfo.onFinishCallback, retFlag, cmd.id)
	end

	if retFlag == -1 then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			logger:info("剧情异常结束", cmd.id, retFlag, reason)
		end
	elseif LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("剧情播放结束", cmd.id, retFlag, reason)
	end

	local finishRpcInfo = {}

	finishRpcInfo.id = cmd.id
	finishRpcInfo.context = cmd.taskInfo.context
	finishRpcInfo.sendFlag = retFlag >= 0 and retFlag or DialogueGraphConst.RET_FLAG_SUCCESS
	finishRpcInfo.sendRpcInfo = retFlag >= 0 and cmd.pendingRPCList or {}

	function finishRpcInfo.reqCallback()
		self:playDialogueGraphList()
	end

	SafeCallback(self.reqToServerDialogueGraphFinish, self, finishRpcInfo)

	local isPlaying = self:isPlayingDialogueGraph()

	pg.me.isInDialogueGraph = isPlaying

	if self:canUnregistMsg() then
		self:unregistAllMessage()
	end

	if cmd.startTime ~= nil then
		DialogueGraphUtils.sendDialogueGraphReport(cmd.id, pg.me:getGameTime() - cmd.startTime)
	end

	facade:sendMsgToUI(MessageName.DIALOGUE_GRAPH_ON_END)

	if pg.game.loading:isFinished() and pg.me and not isPlaying then
		pg.me:doCacheEvents()
	end

	if not self:isPlayingDialogueGraph() and DialogueGraphUtils.canShowID() then
		pg.global.ui:close(UIConst.UI_ID_DIALOGUE_ID)
	end
end

function DialogueSystem:setDialogueGraphModel(cmd, param)
	if not cmd:isValid() then
		return
	end

	if param.showHud == true then
		SafeCallback(pg.global.ui.closeAllNormalPanel, pg.global.ui, DialogueGraphConst.CloseAllPanelWhiteList)
	end

	if param.hideAllUI ~= nil then
		local platformWhiteList

		if param.blockEvent ~= true then
			local curPlatform = ClientUtils.getAdaptionPlatform()

			if curPlatform == UIConst.PLATFORM.Mobile then
				platformWhiteList = DialogueGraphConst.MobilePlatformWhiteList
			end
		end

		local extraWhitleList = param.whiteList or param.hideUIWhiteList

		SafeCallback(self.hideAllUI, self, cmd.id, param.hideAllUI, cmd.config.uiWhiteList, extraWhitleList, platformWhiteList)
	end

	if param.hideInteractionSign ~= nil then
		SafeCallback(self.hideInteractionSign, self, cmd.id, param.hideInteractionSign)
	end

	if param.hideMarkShare ~= nil or param.modeType ~= nil then
		if param.hideMarkShare == nil then
			param.hideMarkShare = param.modeType == DialogueGraphConst.MODE_TYPE.Control
		end

		SafeCallback(self.hideMarkShare, self, cmd.id, param.hideMarkShare)
	end

	if param.hideTopLogo ~= nil then
		SafeCallback(self.hideTopLogo, self, cmd.id, param.hideTopLogo, param.topLogoComs or param.toplogoComList, param.modeType)
	end

	if param.blockEvent ~= nil then
		SafeCallback(self.setBlockEvent, self, cmd.id, param.blockEvent)
	end

	local input = pg.game.input

	if param.resetAllActions == true then
		SafeCallback(input.resetAllActions, input)
	end

	if param.blockCameraZoom ~= nil then
		input.lockCameraZoom = param.blockCameraZoom
	end

	if param.exitCatchMode == true then
		SafeCallback(pg.game.controller.setCatchModeEnable, pg.game.controller, false)
	end

	if param.changeAmbientIntensity then
		SafeCallback(self.changeAmbientIntensity, self, cmd)
	end

	if param.blockPlayerMove ~= nil then
		SafeCallback(input.enablePlayerInput, input, not param.blockPlayerMove, HotkeyConst.INPUT_BLOCK_FLAG.Move)
	end

	if param.turnOnPlayback then
		SafeCallback(cmd.turnOnPlayback, cmd, param)
	end

	if param.turnOffPlayback == true then
		SafeCallback(cmd.turnOffPlayback, cmd)
	end

	if param.pauseNearbyMonsterAI == true then
		SafeCallback(DialogueGraphUtils.pauseNearbyMonsterAI, cmd)
	end

	if param.resumeNearbyMonsterAI == true then
		SafeCallback(DialogueGraphUtils.resumeNearbyMonsterAI, cmd)
	end

	if param.applyStateConflict ~= nil then
		SafeCallback(self.setDialogueStateConflict, self, cmd.id, param.applyStateConflict)
	end

	if param.disableSpaceFollow ~= nil then
		SafeCallback(self.disableSpaceFollow, self, cmd.id, param.disableSpaceFollow)
	end

	if param.disableDialogueCom == true then
		SafeCallback(DialogueGraphUtils.disableEntityDialogueController, cmd, pg.me.id)
	end

	SafeCallback(pg.me.clearTickLookAtInfo, pg.me)
end

function DialogueSystem:setDialogueStateConflict(key, enable)
	local stateConflictData = self:getStateData(DialogueStateKey.STATE_CONFLICT)

	if enable then
		stateConflictData[key] = true

		if not self.isEnterDialogueConflict then
			self.isEnterDialogueConflict = true

			local ok, err = SafeCallbackWithStatusAndReturn(function()
				if pg.pawn then
					pg.pawn:checkStatus(ConflictTypes.CT_DIALOGUE_GRAPH, false)
					EModelUtils.clearDisplacementVelocity(pg.pawn)
				end
			end)

			if not ok and LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("setDialogueStateConflict failed %s", err)
			end
		end
	else
		stateConflictData[key] = nil

		if Utils.tableIsEmptyOrNil(stateConflictData) then
			self.isEnterDialogueConflict = false
		end
	end
end

function DialogueSystem:hideAllUI(key, hide, configWhiteList, extraWhitleList, platformWhiteList)
	local hideAllUIData = self:getStateData(DialogueStateKey.HIDE_ALL_UI)

	if hide then
		local uiWhiteList = {}

		table.merge(uiWhiteList, DialogueGraphConst.HideAllUIWhiteList)

		if extraWhitleList ~= nil then
			table.merge(uiWhiteList, extraWhitleList)
		end

		if platformWhiteList ~= nil then
			table.merge(uiWhiteList, platformWhiteList)
		end

		if configWhiteList ~= nil then
			for i = 1, #configWhiteList do
				local uid = configWhiteList[i]

				uiWhiteList[uid] = true
			end
		end

		hideAllUIData[key] = uiWhiteList
	else
		if hideAllUIData[key] == nil then
			return
		end

		hideAllUIData[key] = nil
	end

	if not Utils.tableIsEmptyOrNil(hideAllUIData) then
		local uiWhiteList = {}

		for k, v in pairs(hideAllUIData) do
			table.merge(uiWhiteList, v)
		end

		pg.global.ui:hideAllUIByCustomKey(UIConst.UI_HIDE_KEY.DIALOAGUE_GRAPH, uiWhiteList)
	else
		pg.global.ui:restoreAllUIByCustomKey(UIConst.UI_HIDE_KEY.DIALOAGUE_GRAPH)
	end
end

function DialogueSystem:hideInteractionSign(key, hide)
	local hideInteractionSignData = self:getStateData(DialogueStateKey.HIDE_INTERACTION_SIGN)

	if hide then
		hideInteractionSignData[key] = true
	else
		hideInteractionSignData[key] = nil
	end

	local isShow = Utils.tableIsEmptyOrNil(hideInteractionSignData)

	pg.game.interactionSignSystem:setSignVisible(InteractionSignSystem.HIDE_KEY.DIALOGUE_GRAPH, isShow)
end

function DialogueSystem:hideMarkShare(key, hide)
	local hideMarkShareData = self:getStateData(DialogueStateKey.HIDE_MARK_SHARE)

	if hide then
		hideMarkShareData[key] = true
	else
		hideMarkShareData[key] = nil
	end

	local scope = Utils.tableIsEmptyOrNil(hideMarkShareData) and pg.game.markShare.FORCE_HIDE_SCOPE.None or pg.game.markShare.FORCE_HIDE_SCOPE.All

	pg.game.markShare:setForceHide(pg.game.markShare.FORCE_HIDE_SOURCE.Dialogue, scope)
end

function DialogueSystem:setBlockEvent(key, lock)
	pg.game.input:setBlockNoneUIEvent(key, lock, DialogueGraphConst.EventBlockWhiteList)
end

function DialogueSystem:reqToServerDialogueGraphFinish(finishRpcInfo, reqStart)
	self.pendingFinishRpcList[finishRpcInfo.id] = finishRpcInfo

	if reqStart == true then
		pg.me:ReqPlayDialogueGraph(finishRpcInfo.id, finishRpcInfo.context)
	end

	pg.me:ReqFinishPlayDialogueGraph(finishRpcInfo.id, finishRpcInfo.sendFlag, finishRpcInfo.context, finishRpcInfo.sendRpcInfo, function(ret)
		self.pendingFinishRpcList[finishRpcInfo.id] = nil

		if finishRpcInfo.reqCallback then
			finishRpcInfo.reqCallback()
		end
	end)
end

function DialogueSystem:retryReqToServerFinishRpc(reqStart)
	if raw_next(self.pendingFinishRpcList) == nil or pg.me == nil or pg.me:isServerLost() then
		return
	end

	for k, v in pairs(self.pendingFinishRpcList) do
		SafeCallback(self.reqToServerDialogueGraphFinish, self, v, reqStart)
	end
end

function DialogueSystem:setEntitiesVisible(key, param, visible)
	if param == nil then
		return
	end

	local hideEntitiesData = self:getStateData(DialogueStateKey.HIDE_ENTITIES)

	if param.hideAllPlayer then
		hideEntitiesData[key] = true

		ClientUtils.SetAllPlayerVisible(ClientConst.MODEL_VISIBLE_KEY.DIALOGUE_GRAPH, visible, param.hideMainPlayer, param.hideTeamMate)
	end

	if param.hideMainPlayerPet then
		hideEntitiesData[key] = true

		pg.me:setCurPetVisible(ClientConst.MODEL_VISIBLE_KEY.DIALOGUE_GRAPH, visible)
	end

	if param.hideAllPuppet then
		hideEntitiesData[key] = true

		ClientUtils.SetAllPuppetVisible(ClientConst.MODEL_VISIBLE_KEY.DIALOGUE_GRAPH, visible)
	end
end

function DialogueSystem:resetEntitiesVisible(key)
	local hideEntitiesData = self:getStateData(DialogueStateKey.HIDE_ENTITIES)
	local param = hideEntitiesData[key]

	if param == nil then
		return
	end

	hideEntitiesData[key] = nil

	if Utils.tableIsEmptyOrNil(hideEntitiesData) then
		pg.me:setCurPetVisible(ClientConst.MODEL_VISIBLE_KEY.DIALOGUE_GRAPH, true)
		ClientUtils.SetAllPlayerVisible(ClientConst.MODEL_VISIBLE_KEY.DIALOGUE_GRAPH, true, true)
		ClientUtils.SetAllPuppetVisible(ClientConst.MODEL_VISIBLE_KEY.DIALOGUE_GRAPH, true)
	end
end

local function m_collectHideTopLogoTargetCompName(targetCompNames, topLogoComs, compName, modeType)
	local visible = topLogoComs[compName]

	if modeType == DialogueGraphConst.MODE_TYPE.Control then
		if visible or visible == nil then
			targetCompNames[compName] = true
		end

		return true
	end

	if visible == nil then
		return false
	end

	if visible then
		targetCompNames[compName] = true
	end

	return true
end

local function m_collectHideTopLogoTargetCompNames(targetCompNames, topLogoComs, modeType)
	if not Utils.isTable(topLogoComs) then
		return false
	end

	for _, compName in pairs(UIConst.TOPLOGO_COMPONENT or EMPTY_TABLE) do
		m_collectHideTopLogoTargetCompName(targetCompNames, topLogoComs, compName, modeType)
	end

	for _, compName in ipairs(DialogueGraphConst.DIALOGUE_GRAPH_LEGACY_TOPLOGO_COMPONENTS) do
		m_collectHideTopLogoTargetCompName(targetCompNames, topLogoComs, compName, modeType)
	end

	local index = 1
	local compName = topLogoComs[index]

	while compName ~= nil do
		if compName then
			targetCompNames[compName] = true
		end

		index = index + 1
		compName = topLogoComs[index]
	end

	return true
end

function DialogueSystem:m_getHideTopLogoTargetCompNames(modeType)
	local targetCompNames = {}
	local hasParsedCompData = false
	local hideTopLogoData = self:getStateData(DialogueStateKey.HIDE_TOP_LOGO)

	for _, topLogoComs in pairs(hideTopLogoData) do
		local parsed = m_collectHideTopLogoTargetCompNames(targetCompNames, topLogoComs, modeType)

		hasParsedCompData = hasParsedCompData or parsed
	end

	if not hasParsedCompData then
		return nil
	end

	return targetCompNames
end

function DialogueSystem:hideTopLogo(key, hide, topLogoComs, modeType)
	local hideTopLogoData = self:getStateData(DialogueStateKey.HIDE_TOP_LOGO)

	if hide then
		if topLogoComs == nil then
			return
		end

		hideTopLogoData[key] = topLogoComs
	else
		if hideTopLogoData[key] == nil then
			return
		end

		hideTopLogoData[key] = nil
	end

	local visibleData

	if not Utils.tableIsEmptyOrNil(hideTopLogoData) then
		visibleData = {
			visible = false,
			visibleKey = UIConst.TOPLOGO_VISIBLE_KEY.DIALOGUE_GRAPH,
			targetCompNames = self:m_getHideTopLogoTargetCompNames(modeType)
		}
	else
		visibleData = {
			visible = true,
			visibleKey = UIConst.TOPLOGO_VISIBLE_KEY.DIALOGUE_GRAPH
		}
	end

	pg.game.topLogo:registerGlobalVisibleData(visibleData)
	facade:sendMsgToUI(MessageName.UI_ON_SET_TOPLOGO_COMPONENT_VISIBLE, visibleData)
end

function DialogueSystem:changeAmbientIntensity(cmd)
	local ambientIntensityData = self:getStateData(DialogueStateKey.AMBIENT_INTENSITY)

	if ambientIntensityData[cmd.id] ~= nil then
		return
	end

	local needChange = Utils.tableIsEmptyOrNil(ambientIntensityData)

	ambientIntensityData[cmd.id] = cmd

	if needChange then
		DialogueGraphUtils.changeAmbientIntensity(cmd)
	end
end

function DialogueSystem:restoreAmbientIntensity(cmd)
	local ambientIntensityData = self:getStateData(DialogueStateKey.AMBIENT_INTENSITY)
	local registeredCmd = ambientIntensityData[cmd.id]

	if registeredCmd == nil then
		return
	end

	ambientIntensityData[cmd.id] = nil

	if Utils.tableIsEmptyOrNil(ambientIntensityData) then
		DialogueGraphUtils.restoreAmbientIntensity(registeredCmd)
	end
end

function DialogueSystem:disableSpaceFollow(key, disable)
	local disableSpaceFollowData = self:getStateData(DialogueStateKey.DISABLE_SPACE_FOLLOW)

	if disable then
		disableSpaceFollowData[key] = true
	else
		if disableSpaceFollowData[key] == nil then
			return
		end

		disableSpaceFollowData[key] = nil
	end

	local available = Utils.tableIsEmptyOrNil(disableSpaceFollowData)

	Utils.setSpaceFollowAvailable(ClientConst.DISABLE_SPACE_FOLLOW_KEY.DIALOGUE_GRAPH, available)
end

function DialogueSystem:onUIClose(uid)
	for k, v in pairs(self.dialogueRunningList) do
		DialogueGraphUtils.handleCloseUI(v, uid)
	end
end

function DialogueSystem:onUIVisibleChange(arg)
	if arg.visible then
		return
	end

	for k, v in pairs(self.dialogueRunningList) do
		DialogueGraphUtils.handleHideUI(v, arg.uid, arg.visible)
	end
end

function DialogueSystem:unloadCachedDialogueRequest(dialogueInfo, retFlag)
	DialogueGraphUtils.unPreloadCutScenes(dialogueInfo.preloadCutscenes)

	retFlag = retFlag or DialogueGraphConst.RET_FLAG_FAILED

	self:finishDialogueRequest(dialogueInfo.dialogueId, retFlag, dialogueInfo.onFinishCallback, dialogueInfo.extraData)
end

function DialogueSystem:completeDialogueRequest(dialogueGraphId, context, onFinishCallback, extraData)
	if pg.me:isServerLost() then
		self.pendingFinishRpcList[dialogueGraphId] = {
			id = dialogueGraphId,
			sendFlag = DialogueGraphConst.RET_FLAG_SUCCESS,
			context = context,
			sendRpcInfo = {}
		}
	else
		pg.me:ReqPlayDialogueGraph(dialogueGraphId, context)
		pg.me:ReqFinishPlayDialogueGraph(dialogueGraphId, DialogueGraphConst.RET_FLAG_SUCCESS, context)
	end

	self:finishDialogueRequest(dialogueGraphId, DialogueGraphConst.RET_FLAG_SUCCESS, onFinishCallback, extraData)
end

function DialogueSystem:finishDialogueRequest(dialogueGraphId, retFlag, onFinishCallback, extraData)
	if extraData ~= nil and extraData.onStartCallback then
		SafeCallback(extraData.onStartCallback)
	end

	if onFinishCallback ~= nil then
		SafeCallback(onFinishCallback, retFlag, dialogueGraphId)
	end
end

function DialogueSystem:getStateData(stateKey)
	local data = self.stateData[stateKey]

	if data == nil then
		data = {}
		self.stateData[stateKey] = data
	end

	return data
end

function DialogueSystem:isLoadingScene()
	if pg.me ~= nil and pg.me.clientFirstCreateFlag then
		return true
	end

	if pg.me == nil or pg.me.space == nil or pg.space == nil or not pg.game.loading:isFinished() then
		return true
	end

	return false
end

function DialogueSystem:isDialoguePlaying(dialogueId)
	return self.dialogueRunningList[dialogueId] ~= nil
end

function DialogueSystem:isDialogueGraphPrepareToPlay(dialogueGraphId)
	for i = 1, #self.dialogueCacheList do
		local dialogueInfo = self.dialogueCacheList[i]

		if dialogueInfo ~= nil and dialogueInfo.dialogueId == dialogueGraphId then
			return true
		end
	end

	return false
end

function DialogueSystem:isPlayingDialogueGraph()
	return raw_next(self.dialogueRunningList) ~= nil
end

function DialogueSystem:canUnregistMsg()
	for k, v in pairs(self.dialogueRunningList) do
		if v.config.registMsg then
			return false
		end
	end

	return true
end

function DialogueSystem:isPreparingToPlayDialogueGraph()
	return #self.dialogueCacheList > 0
end

function DialogueSystem:resolvePlaybackDecision(dialogueGraphId)
	local config = DialogueGraphConfig[dialogueGraphId]

	if config == nil then
		return DialogueGraphConst.PLAYBACK_DECISION.QUEUE
	end

	local newPriority = config.priority or 0
	local interruptIds

	for _, v in pairs(self.dialogueRunningList) do
		local curPriority = v.config.priority or 0
		local decision = DialogueGraphConst.PRIORITY_MAP[curPriority][newPriority] or DialogueGraphConst.PLAYBACK_DECISION.QUEUE

		if decision == DialogueGraphConst.PLAYBACK_DECISION.DISCARD then
			if LoggerManager.checkLogger(LoggerConst.INFO) then
				logger:info("对话图 %d 优先级 %d 正在播放，当前对话图%d 优先级 %d 被丢弃 decision: %d ", v.id, curPriority, dialogueGraphId, newPriority, decision)
			end

			return decision, nil
		elseif decision == DialogueGraphConst.PLAYBACK_DECISION.QUEUE then
			if LoggerManager.checkLogger(LoggerConst.INFO) then
				logger:info("对话图 %d 优先级 %d 正在播放，当前对话图%d 优先级 %d 进入队列 decision: %d ", v.id, curPriority, dialogueGraphId, newPriority, decision)
			end

			return decision, nil
		elseif decision == DialogueGraphConst.PLAYBACK_DECISION.PARALLEL then
			return decision, nil
		elseif decision == DialogueGraphConst.PLAYBACK_DECISION.INTERRUPT then
			if LoggerManager.checkLogger(LoggerConst.INFO) then
				logger:info("对话图 %d 优先级 %d 正在播放，当前对话图%d 优先级 %d 打断 decision: %d ", v.id, curPriority, dialogueGraphId, newPriority, decision)
			end

			interruptIds = interruptIds or {}

			table.insert(interruptIds, v.id)
		end
	end

	if interruptIds ~= nil then
		return DialogueGraphConst.PLAYBACK_DECISION.INTERRUPT, interruptIds
	end

	return DialogueGraphConst.PLAYBACK_DECISION.PARALLEL, nil
end

function DialogueSystem:canPlayTargetDialogueGraph(dialogueInfo)
	if dialogueInfo == nil then
		return false
	end

	local decision = self:resolvePlaybackDecision(dialogueInfo.dialogueId)

	return decision == DialogueGraphConst.PLAYBACK_DECISION.PARALLEL or decision == DialogueGraphConst.PLAYBACK_DECISION.INTERRUPT
end

function DialogueSystem:insertToCacheListSorted(dialogueInfo)
	local newPriority = dialogueInfo.config.priority or 0
	local insertIndex = 1

	for i = 1, #self.dialogueCacheList do
		local tempPriority = self.dialogueCacheList[i].config.priority or 0

		if newPriority <= tempPriority then
			insertIndex = i

			break
		end

		insertIndex = i + 1
	end

	table.insert(self.dialogueCacheList, insertIndex, dialogueInfo)
end

function DialogueSystem:isDialogueGraphIdValid(dialogueGraphId)
	if string.isNilOrEmpty(dialogueGraphId) then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("对话图ID为空，播放失败！")
		end

		return false
	end

	local cfg = DialogueGraphConfig[dialogueGraphId]

	if cfg == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("对话图 %s 配置不存在，播放失败！", dialogueGraphId)
		end

		return false
	end

	for i = #self.dialogueCacheList, 1, -1 do
		local dialogueGraphInfo = self.dialogueCacheList[i]

		if dialogueGraphInfo.dialogueId == dialogueGraphId then
			logger:error("对话图 %s 已经在播放列表，同时触发了相同的对话图，请排查配置！", dialogueGraphId)

			return false
		end
	end

	return true
end

function DialogueSystem:canPlayDialogueGraph(dialogueGraphId)
	local cfg = DialogueGraphConfig[dialogueGraphId]

	if cfg == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("对话图 %s 配置不存在，播放失败！", dialogueGraphId)
		end

		return false
	end

	local graphType = cfg.graphType or 1

	if graphType == DialogueGraphConst.GraphType.SinglePlayer then
		local canPlay, reason = self:canPlaySinglePlayerDialogueGraph()

		if not canPlay then
			if LoggerManager.checkLogger(LoggerConst.INFO) then
				logger:info("对话图 %s 播放失败：%s", dialogueGraphId, reason)
			end

			return false
		end
	end

	return true
end

function DialogueSystem:canPlaySinglePlayerDialogueGraph()
	local space = pg.me and pg.me.space or nil

	if space == nil then
		return false, "当前场景不存在"
	end

	if Utils.isSceneSingleWorld(space.sceneId) then
		if space:isMultiPlayerEnv() and not pg.me.isQuestInSelfSpace then
			return false, "单人大世界组队状态下，只有当前主端可以播放单人对话图"
		end

		return true
	elseif Utils.isSceneHomeland(space.sceneId) then
		if not pg.me.isQuestInSelfSpace then
			return false, "家园场景客端不能播放单人对话图"
		end

		return true
	end

	if space:isMultiPlayerEnv() then
		return false, "多人场景不允许播放单人对话图"
	end

	return true
end

function DialogueSystem:onSpaceCreated(space)
	self:playNamingDialogueGraph(space)
end

function DialogueSystem:onPlayerEnterScene()
	self:playNamingDialogueGraph(pg.me and pg.me.space or nil)
end

function DialogueSystem:onConnected()
	self:retryReqToServerFinishRpc(true)
	self:playNamingDialogueGraph(pg.me and pg.me.space or nil)

	if pg.me and pg.me.space then
		pg.me.space:replayDialoguePlayerOnReconnect()
	end
end

function DialogueSystem:playNamingDialogueGraph(space)
	if pg.me == nil or space == nil or space.sceneId ~= SysConfigData.sceneInit then
		return
	end

	if pg.me.playerNameFirstChanged then
		return
	end

	if self:isDialoguePlaying(DialogueGraphConst.DIALOGUE_GRAPH_ID_NAMING) then
		return
	end

	if self:isDialogueGraphPrepareToPlay(DialogueGraphConst.DIALOGUE_GRAPH_ID_NAMING) then
		return
	end

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("取名：发起播放取名对话图 ", DialogueGraphConst.DIALOGUE_GRAPH_ID_NAMING)
	end

	self:playDialogueGraph(DialogueGraphConst.DIALOGUE_GRAPH_ID_NAMING)
end

function DialogueSystem:onPlayerLeaveScene()
	self:stopAllDialogueGraph(DialogueGraphConst.FINISHED_REASON.INTERRUPTED_LEAVE_SCENE)
end

function DialogueSystem:onClear()
	self:stopAllDialogueGraph(DialogueGraphConst.FINISHED_REASON.INTERRUPTED_CLEAR)
	self:onClearData()
end

function DialogueSystem:resetExternalState()
	SafeCallback(pg.game.topLogo.unRegisterGlobalVisibleData, pg.game.topLogo, UIConst.TOPLOGO_VISIBLE_KEY.DIALOGUE_GRAPH)
	SafeCallback(pg.global.ui.restoreAllUIByCustomKey, pg.global.ui, UIConst.UI_HIDE_KEY.DIALOAGUE_GRAPH)
	SafeCallback(pg.game.interactionSignSystem.setSignVisible, pg.game.interactionSignSystem, InteractionSignSystem.HIDE_KEY.DIALOGUE_GRAPH, true)
	SafeCallback(pg.game.markShare.setForceHide, pg.game.markShare, pg.game.markShare.FORCE_HIDE_SOURCE.Dialogue, pg.game.markShare.FORCE_HIDE_SCOPE.None)
	Utils.setSpaceFollowAvailable(ClientConst.DISABLE_SPACE_FOLLOW_KEY.DIALOGUE_GRAPH, true)

	local hasRunningDialogue = not Utils.tableIsEmptyOrNil(self.dialogueRunningList)

	for dialogueId in pairs(self.dialogueRunningList) do
		SafeCallback(self.setBlockEvent, self, dialogueId, false)
	end

	local ambientIntensityData = self:getStateData(DialogueStateKey.AMBIENT_INTENSITY)
	local _, ambientCmd = next(ambientIntensityData)

	if ambientCmd ~= nil then
		SafeCallback(DialogueGraphUtils.restoreAmbientIntensity, ambientCmd)

		self.stateData[DialogueStateKey.AMBIENT_INTENSITY] = nil
	end

	local hideEntitiesData = self:getStateData(DialogueStateKey.HIDE_ENTITIES)

	if not Utils.tableIsEmptyOrNil(hideEntitiesData) then
		if pg.me ~= nil then
			SafeCallback(pg.me.setCurPetVisible, pg.me, ClientConst.MODEL_VISIBLE_KEY.DIALOGUE_GRAPH, true)
		end

		SafeCallback(ClientUtils.SetAllPlayerVisible, ClientConst.MODEL_VISIBLE_KEY.DIALOGUE_GRAPH, true, true)
		SafeCallback(ClientUtils.SetAllPuppetVisible, ClientConst.MODEL_VISIBLE_KEY.DIALOGUE_GRAPH, true)
	end

	if hasRunningDialogue then
		local input = pg.game.input

		SafeCallback(input.enablePlayerInput, input, true, HotkeyConst.INPUT_BLOCK_FLAG.Move)

		input.lockCameraZoom = false
	end
end

function DialogueSystem:onClearData()
	self:resetExternalState()

	self.dialogueCacheList = {}
	self.dialogueRunningList = {}
	self.stateData = {}
	self.isEnterDialogueConflict = false
	self.pendingFinishRpcList = {}
end

function DialogueSystem:onDestroy()
	self:onClear()
end

function DialogueSystem:getExtraAngle(staticId)
	for _, cmd in pairs(self.dialogueRunningList) do
		local cacheInfo = cmd.cacheActorInfo[staticId]

		if cacheInfo then
			return cacheInfo.angleDelta or 0
		end
	end

	for _, cmd in pairs(self.dialogueRunningList) do
		local angle = cmd.virtualActorAngle[staticId]

		if angle then
			return angle
		end
	end

	return 0
end

return DialogueSystem
