-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Communication\\CommunicationSystem.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local UIConst = require("Const.UIConst")
local Utils = require("Common.Utils.Utils")
local Class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local ClientConst = require("Const.ClientConst")
local DialogueConst = require("Const.DialogueConst")
local EventConst = require("Const.EventConst")
local PlayableConst = require("Common.Const.PlayableConst")
local CameraConst = require("GameApp.Camera.CameraConst")
local AiConst = require("Common.Const.AiConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientUtils = require("Utils.ClientUtils")
local DialogueUtils = require("Utils.DialogueUtils")
local EModelUtils = require("Entities.Utils.EModelUtils")
local AnimationUtils = require("Common.Utils.AnimationUtils")
local PhysicsUtils = require("Common.Utils.PhysicsUtils")
local AIUtils = require("Common.Utils.AIUtils")
local SysConfigData = require("Data.sys_config_data")
local NpcDialogueData = require("Data.npc_dialogue_data")
local NpcSpecialStateData = require("Data.npc_special_state_data")
local PuppetData = require("Data.puppet_data")
local SystemBase = require("GameApp.Core.SystemBase")
local InputCommand = require("GameApp.Input.InputCommand")
local TimerManager = require("Core.Timer.TimerManager")
local Lume = require("Core.Common.lume")
local Time = require("Core.Common.Time")
local SafeCallback = require("Core.Framework.SafeCallback")
local logger = LoggerManager.getLogger("CommunicationSystem")
local SafeCallbackWithStatusAndReturn = require("Core.Framework.SafeCallbackWithStatusAndReturn")
local EntityLookAtUtils = require("GameApp.Communication.EntityLookAtUtils")
local ToBool = ToBool
local Vector3 = Vector3
local Quaternion = Quaternion
local string = string
local CommunicationSystem = Class.LightClass("CommunicationSystem", SystemBase)

function CommunicationSystem:onCtor()
	self.curDialogueId = nil
	self.curDialogueIndex = nil
	self.curChatType = DialogueConst.ChatType.NONE
	self.curMaxDialogIndex = nil
	self.curDialogVoice = nil
	self.curDuration = nil
	self.cameraPresetType = 0
	self.targetEntity = nil
	self.reviewLog = {}
	self.chatTypePriority = {}
	self.isInDialogueGraphControl = false
	self.dialogueGraphTargetEntityActorId = nil
	self.dialogueGraphControlEntityIds = {}
	self.showCursor = false
	self.forbidClickTime = 0
	self.enableDefaultLookAt = true
	self.enableDefaultLookAtFromPreset = true
	self.enablePresetLookAt = true
	self.needResetRotation = false
	self.srcPriority = -1
	self.dialogueEventContext = {}
	self.triggeredLookAtEntIds = {}
	self.toplogoShowConfig = {
		[UIConst.TOPLOGO_COMPONENT.CHAT] = false,
		[UIConst.TOPLOGO_COMPONENT.BUBBLE] = false,
		[UIConst.TOPLOGO_COMPONENT.NPC] = false
	}
	self.forbidShowAIAssistant = false

	function self.onDialogueGraphStartMsg()
		self:onDialogueGraphStart()
	end

	pg.global.eventEmitter:addEventListener(EventConst.DIALOGUE_GRAPH_ON_START, self.onDialogueGraphStartMsg)
end

function CommunicationSystem:onPlayerLeaveScene()
	if self:isInDialogue() and self.isInDialogueGraphControl ~= true then
		self:finishNpcDialog()
	end
end

function CommunicationSystem:onInit()
	self.chatTypePriority = DialogueUtils.getDialoguePriority()
end

function CommunicationSystem:onClear(isInterrupted)
	self.curDialogueId = nil
	self.curDialogueIndex = nil
	self.curDialogVoice = nil
	self.curChatType = DialogueConst.ChatType.NONE
	self.curMaxDialogIndex = nil
	self.curDuration = nil
	self.cameraPresetType = 0

	if self.isInDialogueGraphControl and not isInterrupted or not self.isInDialogueGraphControl then
		self.targetEntity = nil

		Lume.clear(self.reviewLog)

		self.isInDialogueGraphControl = false
		self.dialogueGraphTargetEntityActorId = nil

		Lume.clear(self.dialogueGraphControlEntityIds)

		self.enableDefaultLookAt = true
		self.enableDefaultLookAtFromPreset = true
		self.enablePresetLookAt = true
		self.needResetRotation = false

		Lume.clear(self.dialogueEventContext)
		Lume.clear(self.triggeredLookAtEntIds)
	end

	self.showCursor = false
	self.forbidClickTime = 0
	self.srcPriority = -1

	EntityLookAtUtils.clearAll()
end

function CommunicationSystem:onDestroy()
	self:onClear()

	self.chatTypePriority = nil
	self.reviewLog = nil
	self.toplogoShowConfig = nil
	self.onDialogueGraphStartMsg = nil

	pg.global.eventEmitter:removeEventListener(EventConst.DIALOGUE_GRAPH_ON_START, self.onDialogueGraphStartMsg)
end

function CommunicationSystem:onSceneLoaded()
	EntityLookAtUtils.clearAll()
end

function CommunicationSystem:startNpcDialog(dialogueId, npcEntityId, extraInfo)
	if not pg.game.loading:isFinished() then
		return
	end

	if self.isInDialogueGraphControl then
		return
	end

	extraInfo = extraInfo and extraInfo or {}
	npcEntityId = ToBool(npcEntityId) and npcEntityId or nil

	local index = extraInfo.index or 1
	local npcDialogueData = NpcDialogueData[dialogueId]

	if not npcDialogueData then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error(string.format("dialogueId = %d, npcEntityId = %s 数据不存在！ 反馈策划检查表配置 traceback:%s", dialogueId, tostring(npcEntityId), debug.traceback()))
		end

		self:finishNpcDialog()

		return false
	end

	local dialogInfo = npcDialogueData[index]
	local curChatType = extraInfo.chatType or dialogInfo.chatType

	if not self:checkDialogueDataValid(dialogueId, index, curChatType) then
		return false
	end

	local staticId = extraInfo.staticId
	local targetNpcEntity = npcEntityId and pg.getEntity(npcEntityId)
	local specialChatTypeHandleFunc = DialogueConst.SPECIAL_CHAT_TYPE_FUNC_MAP[curChatType]

	if specialChatTypeHandleFunc and self[specialChatTypeHandleFunc] then
		local src = extraInfo.src

		if src ~= DialogueConst.SrcType.Interaction then
			local isDiffEthnic, dialogType, newDialogueId = DialogueUtils.checkPetsSameEthnicDialogue(pg.pawn, targetNpcEntity)

			dialogueId = newDialogueId or dialogueId
		end

		return self[specialChatTypeHandleFunc](self, dialogueId, index, npcEntityId, extraInfo)
	end

	local triggerSrc = extraInfo.src or DialogueConst.SrcType.SIMPLE_EVENT

	if self.srcPriority ~= -1 and triggerSrc > self.srcPriority then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error(string.format("dialogueId = %d, 来源优先级低 srcPriority %d triggerSrc %d", dialogueId, self.srcPriority, triggerSrc))
		end

		return
	end

	if not self:checkDialoguePriorityValid(curChatType, extraInfo.overridePriority) then
		return false
	end

	if curChatType ~= self.curChatType then
		self:finishNpcDialog()
	end

	self.curDialogueId = dialogueId
	self.curDialogueIndex = index
	self.curChatType = curChatType
	self.curMaxDialogIndex = table.maxn(npcDialogueData)
	self.targetEntity = targetNpcEntity
	self.dialogueEventContext.globalId = self.targetEntity and self.targetEntity.id
	self.srcPriority = triggerSrc

	local normalChatTypeHandleFunc = DialogueConst.CHAT_TYPE_FUNC_MAP[curChatType]

	if normalChatTypeHandleFunc and self[normalChatTypeHandleFunc] then
		self:onDialogueStart(dialogInfo)

		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			logger:debug(string.format("dialogueId = %d, src = %d", dialogueId, triggerSrc))
		end

		return self[normalChatTypeHandleFunc](self, dialogueId, index, npcEntityId, extraInfo)
	else
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error(string.format("Not supportable chatType: %s, @%s @hyj fix problem", curChatType, dialogInfo.author))
		end

		self:onClear()

		return
	end
end

function CommunicationSystem:finishNpcDialog(isInterrupted, key)
	SafeCallback(self.onDialogueFinish, self)
	SafeCallback(self.closeDialogUI, self, key)
	SafeCallback(self.onClear, self, isInterrupted)

	return true
end

function CommunicationSystem:isInDialogue()
	return self.curChatType ~= DialogueConst.ChatType.NONE
end

function CommunicationSystem:isInNormalDialogue()
	return self.curChatType == DialogueConst.ChatType.DIALOGUE
end

function CommunicationSystem:canAutoPlay()
	local playType = DialogueConst.ChatTypeToPlayTypeMap[self.curChatType]

	return playType == DialogueConst.PlayType.AUTO or playType == DialogueConst.PlayType.AUTO_UNBREAKABLE
end

function CommunicationSystem:isDialogueUnbreakable()
	local playType = DialogueConst.ChatTypeToPlayTypeMap[self.curChatType]

	return playType == DialogueConst.PlayType.AUTO_UNBREAKABLE
end

function CommunicationSystem:stopCombatDialogue(dialogId)
	if self.srcPriority ~= DialogueConst.SrcType.COMBAT then
		return
	end

	if dialogId ~= self.curDialogueId then
		return
	end

	self:finishNpcDialog()
end

function CommunicationSystem:closeDialogUI(key)
	pg.global.ui.npcCall:setIsModel(false)
	pg.global.ui.plotPhoneCall:setIsModel(true)

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_NPC_CALL) then
		pg.global.ui.npcCall:close()
	end

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_PLOT_PHONE_CALL) then
		pg.global.ui.plotPhoneCall:close()
	end

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_BOTTOM_DIALOGUE) then
		pg.global.ui.dialogue:finishDialogue()
		pg.global.ui.dialogue:close()
	end

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_AI_ASSISTANT) then
		pg.global.ui.aiAssistant:startClose()
	end

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_SUBTITLES_PANEL) then
		pg.global.ui.SubtitlesPanel:close()
	end

	if pg.global.ui:checkUIShow(UIConst.UI_ID_BLACK_SCREEN) and key ~= DialogueConst.DIALOGUE_CLOSE_KEY.DIALOG_CLOSE_NODE and pg.global.ui.blackScreen:isDialogueGraphScreen() then
		pg.global.ui.blackScreen:startCloseScreen()
	end

	if pg.global.ui:checkUIShow(UIConst.UI_ID_WHITE_SCREEN) and key ~= DialogueConst.DIALOGUE_CLOSE_KEY.DIALOG_CLOSE_NODE and pg.global.ui.whiteScreen:isDialogueGraphScreen() then
		pg.global.ui.whiteScreen:startCloseScreen()
	end

	if pg.global.ui:checkUIShow(UIConst.UI_ID_DIALOG_REVIEW) then
		pg.global.ui:close(UIConst.UI_ID_DIALOG_REVIEW)
	end
end

function CommunicationSystem:hideDialogueTextUI()
	if pg.global.ui:checkUIShow(UIConst.UI_ID_SUBTITLES_PANEL) then
		pg.global.ui.SubtitlesPanel:hide()
	end

	if pg.global.ui:checkUIShow(UIConst.UI_ID_NPC_CALL) then
		pg.global.ui.npcCall:hideNpcCallContent()
	end

	if pg.global.ui:checkUIShow(UIConst.UI_ID_BOTTOM_DIALOGUE) then
		pg.global.ui.dialogue:finishDialogue()
	end

	if pg.global.ui:checkUIShow(UIConst.UI_ID_AI_ASSISTANT) then
		pg.global.ui.aiAssistant:hide()
	end

	if pg.global.ui:checkUIShow(UIConst.UI_ID_BLACK_SCREEN) and pg.global.ui.blackScreen.isDialogueGraph and pg.global.ui.blackScreen:isDialogueGraphScreen() then
		pg.global.ui.blackScreen:closeScreen()
	end

	if pg.global.ui:checkUIShow(UIConst.UI_ID_WHITE_SCREEN) then
		pg.global.ui.whiteScreen:closeScreen()
	end
end

function CommunicationSystem:onDialogueStart(dialogueInfo)
	table.insert(self.reviewLog, {
		dialogId = self.curDialogueId,
		dialogIndex = self.curDialogueIndex
	})
	DialogueUtils.sendDialogueInfoReport(self.curDialogueId, 1, self.curDialogueIndex, DialogueConst.SEND_REPORT_ACTION_EVENT.BEGIN_SENTENCE, 0)

	if ToBool(dialogueInfo.hideUI) then
		self:enableDialogUIMonopoly(true)
	end

	if ToBool(dialogueInfo.showTopLogoType) then
		for _, val in ipairs(dialogueInfo.showTopLogoType) do
			if val == 1 then
				self.toplogoShowConfig[UIConst.TOPLOGO_COMPONENT.CHAT] = true
			elseif val == 2 then
				self.toplogoShowConfig[UIConst.TOPLOGO_COMPONENT.BUBBLE] = true
			elseif val == 3 then
				self.toplogoShowConfig[UIConst.TOPLOGO_COMPONENT.NPC] = true
			end
		end

		ClientUtils.setTopLogoComponentVisible(self.toplogoShowConfig, true)
	else
		ClientUtils.setTopLogoComponentVisible(nil, true)
	end

	if self:isInNormalDialogue() then
		local disableCameraAnim = dialogueInfo.disableCameraLock or pg.game.communication.cameraPresetType == DialogueConst.CAMERA_MODE.NONE

		if not disableCameraAnim then
			self:triggerCameraAnim(self.targetEntity)
		end
	end

	self:stopDialogVoice()
end

function CommunicationSystem:onDialogueFinish()
	local lookAtFadeTimeOnDialogueFinish = DialogueConst.DEFAULT_LOOK_AT_FADE_TIME

	if self.curChatType == DialogueConst.ChatType.DIALOGUE then
		self:onNormalBottomDialogueFinish()
	end

	pg.game.input:setLockCursor(ClientConst.LockCursorKey.Dialogue, true)
	pg.game.communication:enableDialogUIMonopoly(false)

	for _, npcEntityId in ipairs(self.dialogueGraphControlEntityIds) do
		local npcEntity = pg.getEntity(npcEntityId)

		if npcEntity then
			if npcEntity.recoverRotationTimer == nil and npcEntity.recoverInteractRotationTimer == nil then
				AIUtils.ResumeAI(npcEntityId, AiConst.PauseBtReason.DialogueControl)
			end

			npcEntity.isInDialogue = nil

			EntityLookAtUtils.removeLookAtManual(npcEntity, lookAtFadeTimeOnDialogueFinish)
		end
	end

	for entId, _ in pairs(self.triggeredLookAtEntIds) do
		local entity = pg.getEntity(entId)

		if entity then
			EntityLookAtUtils.removeLookAtManual(entity, lookAtFadeTimeOnDialogueFinish)
		end
	end

	if pg.me then
		EntityLookAtUtils.removeLookAtManual(pg.me, lookAtFadeTimeOnDialogueFinish)

		local curPetEnt = pg.me:getCurPetEntity()

		if curPetEnt then
			EntityLookAtUtils.removeLookAtManual(curPetEnt, lookAtFadeTimeOnDialogueFinish)
		end
	end

	local dialogueGraphTargetEntity = self.dialogueGraphTargetEntityActorId and pg.getEntityByActorId(self.dialogueGraphTargetEntityActorId)

	if dialogueGraphTargetEntity then
		EntityLookAtUtils.removeLookAtManual(dialogueGraphTargetEntity, lookAtFadeTimeOnDialogueFinish)
	end

	self:recoverTargetNpcFaceTowards()
	self:removeReadyRotationTimer()
	self:removeWaitLandingTimer()
	pg.game.camera:enableNpcDialogue(false)
	ClientUtils.stopDialogueCameraDof()

	self.toplogoShowConfig[UIConst.TOPLOGO_COMPONENT.CHAT] = false
	self.toplogoShowConfig[UIConst.TOPLOGO_COMPONENT.BUBBLE] = false
	self.toplogoShowConfig[UIConst.TOPLOGO_COMPONENT.NPC] = false

	EntityLookAtUtils.doModifyLookAt()
end

function CommunicationSystem:onDialogueShow()
	if not self.curDialogueId or not self.curDialogueIndex then
		return
	end

	local curVoiceName = self.curDialogVoice or DialogueUtils.getAudioName(self.curDialogueId, self.curDialogueIndex)

	if curVoiceName then
		self:stopDialogVoice()
		self:playDialogVoice(curVoiceName)
	end
end

function CommunicationSystem:onDialogueGraphStart()
	if self.curChatType ~= DialogueConst.ChatType.NONE and not self.isInDialogueGraphControl then
		self:finishNpcDialog()
	end
end

function CommunicationSystem:addPlayerChoiceReviewLog(branchText, dialogId)
	table.insert(self.reviewLog, {
		isChoice = true,
		branchText = branchText,
		dialogId = dialogId
	})
end

function CommunicationSystem:openDialogReview(closeCb)
	if pg.global.ui.dialogReview then
		pg.global.ui.dialogReview:open(self.reviewLog, nil, closeCb)
	end
end

function CommunicationSystem:getEnableTypewriter()
	if self.srcPriority == DialogueConst.SrcType.COMBAT then
		return false
	end

	return true
end

function CommunicationSystem:getEnableStopUI()
	if self.srcPriority == DialogueConst.SrcType.COMBAT then
		return false
	end

	local curTime = pg.me:getGameTime()

	if self.forbidClickTime > 0 and curTime <= self.curDialogueStartTime + self.forbidClickTime then
		return false
	end

	return true
end

function CommunicationSystem:playDialogVoice(voice)
	if voice then
		self.curDialogVoice = voice

		pg.game.audio:playEvent(voice)
	end
end

function CommunicationSystem:stopDialogVoice()
	if self.curDialogVoice then
		pg.game.audio:stopEvent(self.curDialogVoice)

		self.curDialogVoice = nil
	end
end

function CommunicationSystem:enableDialogUIMonopoly(enable)
	if enable then
		pg.global.ui:hideAllUIByCustomKey(UIConst.UI_HIDE_KEY.Dialogue, {
			[UIConst.UI_ID_BOTTOM_DIALOGUE] = true,
			[UIConst.UI_ID_TIPS] = true,
			[UIConst.UI_ID_COMMON_OBTAIN] = true,
			[UIConst.UI_ID_CONFIG_TOPPING] = true,
			[UIConst.UI_ID_PLOT_PHONE_CALL] = true,
			[UIConst.UI_ID_DIALOG_REVIEW] = true,
			[UIConst.UI_ID_BLACK_SCREEN] = true,
			[UIConst.UI_ID_LOADING] = true,
			[UIConst.UI_ID_SUBTITLES_PANEL] = true,
			[UIConst.UI_ID_PICTURE] = true,
			[UIConst.UI_ID_AI_ASSISTANT] = true,
			[UIConst.UI_ID_NPC_CALL] = true,
			[UIConst.UI_ID_COMMON_CONFIRM] = true,
			[UIConst.UI_ID_DIALOGUE_SKIP] = true,
			[UIConst.UI_ID_BLACK_SCREEN_SKIP_PANEL] = true,
			[UIConst.UI_ID_WHITE_SCREEN] = true
		})
	else
		pg.global.ui:restoreAllUIByCustomKey(UIConst.UI_HIDE_KEY.Dialogue)
	end
end

function CommunicationSystem:enableDeprivePlayerControl(enable)
	pg.global.ui.npcCall:setIsModel(enable)
	pg.global.ui.plotPhoneCall:setIsModel(enable)
	pg.global.ui.dialogue:setIsModel(enable)
	pg.game.input:setLockCursor(ClientConst.LockCursorKey.Dialogue, not enable)

	self.showCursor = enable
end

function CommunicationSystem:playPlotPhoneCallAnim(npcTemplateId, disableAni, callback)
	local npcName, iconUrl = self:getNpcInfoByTemplateId(npcTemplateId)

	self:stopPlotPhoneCallAnim()

	local info = {
		name = npcName,
		resId = iconUrl,
		disableAni = disableAni,
		callback = callback
	}

	pg.global.ui.plotPhoneCall:open(info)
end

function CommunicationSystem:stopPlotPhoneCallAnim()
	if pg.global.ui:checkUIOpen(UIConst.UI_ID_PLOT_PHONE_CALL) then
		pg.global.ui.plotPhoneCall:close()
	end
end

function CommunicationSystem:playSimpleNpcCallAnim(npcTemplateId, callback)
	local npcName, iconUrl = self:getNpcInfoByTemplateId(npcTemplateId)

	self:stopSimpleNpcCallAnim()

	if not pg.global.ui:checkUIOpen(UIConst.UI_ID_NPC_CALL) then
		pg.global.ui.npcCall:open(nil, function()
			pg.global.ui.npcCall.isDialogueGraph = true

			pg.global.ui.npcCall:showHeadIconUI(npcName, iconUrl, callback)
			pg.global.ui.npcCall:show()
		end)
	elseif not pg.global.ui:checkUIShow(UIConst.UI_ID_NPC_CALL) then
		pg.global.ui.npcCall.isDialogueGraph = true

		pg.global.ui.npcCall:showHeadIconUI(npcName, iconUrl, callback)
		pg.global.ui.npcCall:show()
	else
		pg.global.ui.npcCall:showHeadIconUI(npcName, iconUrl, callback)
	end
end

function CommunicationSystem:stopSimpleNpcCallAnim()
	if pg.global.ui:checkUIShow(UIConst.UI_ID_NPC_CALL) then
		pg.global.ui.npcCall:hideHeadIconUI()
	end
end

function CommunicationSystem:setCurDialogChatType(chatType)
	if chatType <= DialogueConst.ChatType.NONE or chatType > DialogueConst.ChatType.MAXN then
		self:finishNpcDialog()

		return
	end

	if self.curChatType ~= DialogueConst.ChatType.NONE and self.curChatType ~= chatType then
		self:hideDialogueTextUI()
	end

	self.curChatType = chatType

	if chatType == DialogueConst.ChatType.DIALOGUE then
		pg.game.input:setLockCursor(ClientConst.LockCursorKey.Dialogue, false)

		self.showCursor = true
	end
end

function CommunicationSystem:showDialogText(dialogueId, npcEntityId, dialogueGraphParam, context)
	if not dialogueGraphParam then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("@hyj Invalid Call Function: DialogueGraph params nil, be sure it is called from DialogueGraph or use function[startNpcDialog] instead!", debug.traceback())
		end

		return false
	end

	local index = dialogueGraphParam.index or 1
	local dialogueGraphCallback = dialogueGraphParam.callback

	npcEntityId = ToBool(npcEntityId) and npcEntityId or nil

	local chatType = dialogueGraphParam.chatType

	if not self:checkDialogueDataValid(dialogueId, index, chatType) then
		if dialogueGraphCallback then
			dialogueGraphCallback(1, 0)
		end

		return false
	end

	local curNpcDialogueData = NpcDialogueData[dialogueId]

	chatType = chatType or curNpcDialogueData[1].chatType
	self.enablePresetLookAt = dialogueGraphParam.enablePresetLookAt or false

	local duration = -1

	if dialogueGraphParam.matchAudioDuration then
		duration = DialogueUtils.getAudioDuration(dialogueId, index, dialogueGraphParam.audioName)
	end

	if duration == -1 then
		duration = DialogueUtils.getDialogueDuration(chatType, dialogueId, index)
	end

	dialogueGraphParam.duration = duration

	if dialogueGraphParam.onSetDuration then
		if chatType == DialogueConst.ChatType.BLACK_SCREEN or chatType == DialogueConst.ChatType.WHITE_SCREEN then
			local dialogCount = table.getCount(curNpcDialogueData)

			dialogueGraphParam.duration = dialogueGraphParam.intervalTime * dialogCount
		end

		dialogueGraphParam.onSetDuration(dialogueGraphParam.duration)
	end

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("Show Dialog dialogueId：%d chatType：%d duration：%s", dialogueId, chatType, tostring(dialogueGraphParam.duration))
	end

	local npcTemplateId = dialogueGraphParam.npcId
	local npcStaticId = dialogueGraphParam.npcStaticId
	local targetNpcEntity = npcEntityId and pg.getEntity(npcEntityId) or DialogueUtils.getDialogueEntity(npcTemplateId, npcStaticId, self.dialogueGraphControlEntityIds)

	npcEntityId = targetNpcEntity and targetNpcEntity.id or npcEntityId

	local specialChatTypeHandleFunc = DialogueConst.SPECIAL_CHAT_TYPE_FUNC_MAP[chatType]

	if specialChatTypeHandleFunc and self[specialChatTypeHandleFunc] then
		if chatType == DialogueConst.ChatType.BUBBLE then
			self:handleDefaultLookAt(dialogueId, index, dialogueGraphParam.lookAtId)
			self:triggerAnimAction(npcTemplateId, npcStaticId, dialogueId, index, dialogueGraphParam.actionId)
		end

		local status, ret = SafeCallbackWithStatusAndReturn(self[specialChatTypeHandleFunc], self, dialogueId, index, npcEntityId, dialogueGraphParam)

		if not status then
			if dialogueGraphParam and dialogueGraphParam.callback then
				dialogueGraphParam.callback()
			end

			return nil
		end

		return ret
	end

	self:setCurDialogChatType(chatType)

	self.isInDialogueGraphControl = true
	self.curDialogueId = dialogueId
	self.curDialogueIndex = index
	self.forbidClickTime = dialogueGraphParam.skipTime or 0
	self.curDialogueStartTime = pg.me:getGameTime()
	self.curDialogVoice = dialogueGraphParam.audioName
	dialogueGraphParam.isDialogueGraph = true

	local showTextFunc = DialogueConst.CHAT_TYPE_FUNC_MAP[self.curChatType]

	if showTextFunc and self[showTextFunc] then
		table.insert(self.reviewLog, {
			dialogId = dialogueId,
			dialogIndex = index
		})
		DialogueUtils.sendDialogueInfoReport(dialogueId, 1, index, DialogueConst.SEND_REPORT_ACTION_EVENT.BEGIN_SENTENCE, 0)
		self:handleDefaultLookAt(dialogueId, index, dialogueGraphParam.lookAtId)

		if self.curChatType ~= DialogueConst.ChatType.DIALOGUE then
			self:triggerAnimAction(npcTemplateId, npcStaticId, dialogueId, index, dialogueGraphParam.actionId)
		end

		self:stopDialogVoice()

		local status, ret = SafeCallbackWithStatusAndReturn(self[showTextFunc], self, dialogueId, index, npcEntityId, dialogueGraphParam)

		if not status then
			if dialogueGraphParam and dialogueGraphParam.callback then
				dialogueGraphParam.callback()
			end

			return nil
		end

		return ret
	end
end

function CommunicationSystem:prepareDialogue(dialogueGraphId, mode, npcEntityIds, param, callback)
	if mode == DialogueConst.DIALOGUE_GRAPH_PRESET_MODE.OneOnOne then
		self:enterOneOnOneMode(dialogueGraphId, npcEntityIds, param, callback)
	else
		self:enterGroupMode(npcEntityIds, param, callback)
	end
end

function CommunicationSystem:enterOneOnOneMode(dialogueGraphId, npcEntityId, param, callback)
	table.insert(self.dialogueGraphControlEntityIds, npcEntityId)
	AIUtils.PauseAI(npcEntityId, AiConst.PauseBtReason.DialogueControl)

	self.cameraPresetType = param.cameraPreset or 0
	self.enableDefaultLookAtFromPreset = param.enableDefaultLookAt
	self.needResetRotation = param.resetOrientation

	local npcEntity = pg.getEntity(npcEntityId)

	if npcEntity then
		self.dialogueGraphTargetEntityActorId = npcEntity.actorId
		self.dialogueEventContext.globalId = npcEntity.id
		npcEntity.isInDialogue = true

		local dialoguePerformanceLevel = param.reactPreset

		if dialoguePerformanceLevel == DialogueConst.PERFORMANCE_LEVEL.LOOK_AT_AND_TURN then
			npcEntity:playAnimation(PlayableConst.Idle, true, nil, false, 2)

			if param.enableDefaultLookAt then
				EntityLookAtUtils.setLookAtManual(npcEntity, pg.pawn)
			end

			self:waitForPlayerLanded(function()
				self:faceToTargetNpc(npcEntity, callback, dialogueGraphId, param.cameraPreset, 0)
			end)

			if not DialogueUtils.isPetsSameEthnic(pg.pawn, npcEntity) then
				self.needResetRotation = true
			end
		else
			if dialoguePerformanceLevel == DialogueConst.PERFORMANCE_LEVEL.IDLE_AND_LOOK_AT then
				npcEntity:playDefaultAnimation(true)
			end

			if dialoguePerformanceLevel ~= DialogueConst.PERFORMANCE_LEVEL.NO_PERFORMANCE and param.enableDefaultLookAt then
				EntityLookAtUtils.setLookAtManual(npcEntity, pg.pawn)
			end

			self:triggerCameraAnim(npcEntity)

			if callback then
				callback()
			end
		end
	end

	EntityLookAtUtils.doModifyLookAt()
end

function CommunicationSystem:enterGroupMode(npcEntityIds, param, callback)
	self.enableDefaultLookAtFromPreset = param.enableGroupLookAt

	for npcEntityId in string.gmatch(npcEntityIds, "([^,]+)") do
		table.insert(self.dialogueGraphControlEntityIds, npcEntityId)
		AIUtils.PauseAI(npcEntityId, AiConst.PauseBtReason.DialogueControl)

		local npcEntity = pg.getEntity(npcEntityId)

		if npcEntity then
			npcEntity.isInDialogue = true
		end
	end

	DialogueUtils.enterGroupCameraMode(param.cameraPreset or 0, self.dialogueGraphControlEntityIds)

	if callback then
		callback()
	end
end

function CommunicationSystem:faceToTargetNpc(targetNpcEntity, callback, dialogueGraphId, cameraPreset, endState)
	cameraPreset = cameraPreset or 0
	self.cameraPresetType = cameraPreset

	local turnTime = 0

	if targetNpcEntity then
		targetNpcEntity.lastRotation = targetNpcEntity:getRotation():Clone()

		local needTurn = cameraPreset ~= 1
		local targetPos = self:preCalculateTargetPos(pg.pawn, targetNpcEntity)

		pg.me:serverMsg("RPC_CS_ForbidPositionCheck", {
			0,
			dialogueGraphId or 0,
			targetPos,
			targetNpcEntity.staticId or 0
		})

		local npcTargetRotation = self:faceToTarget(targetNpcEntity, pg.pawn, false, needTurn)
		local playerTargetRotation

		if ClientUtils.getPetBodySizeType(targetNpcEntity) == ClientConst.PetBodySizeType.SMALL and Utils.isPlayer(pg.pawn) and cameraPreset ~= 0 then
			playerTargetRotation = self:faceToTargetAndCrouch(pg.pawn, targetNpcEntity)
		else
			local needMovePos = true

			if cameraPreset == 0 then
				needMovePos = false
			end

			playerTargetRotation = self:faceToTarget(pg.pawn, targetNpcEntity, needMovePos, needTurn)
		end

		if needTurn then
			local npcTurnTime = AnimationUtils.getAnimationTurnTime(targetNpcEntity, npcTargetRotation)
			local playerTurnTime = AnimationUtils.getAnimationTurnTime(pg.pawn, playerTargetRotation)

			turnTime = math.max(npcTurnTime, playerTurnTime)
		end
	end

	self:removeReadyRotationTimer()

	if turnTime == 0 then
		self:triggerCameraAnim(targetNpcEntity)

		if callback then
			callback()
		end
	else
		self.readyRotationTimer = TimerManager.addTimer(turnTime, function()
			if endState and targetNpcEntity then
				if endState == 0 then
					targetNpcEntity:playAnimation(PlayableConst.Idle, true, nil, false, 2)
				elseif endState == 1 then
					targetNpcEntity:playDefaultAnimation(true)
				end
			end

			self:triggerCameraAnim(targetNpcEntity)

			if callback then
				callback()
			end
		end)
	end
end

function CommunicationSystem:waitForPlayerLanded(callback)
	self:removeWaitLandingTimer()

	if not pg.pawn or not pg.pawn.FALL_ST or not pg.pawn:FALL_ST() then
		callback()

		return
	end

	local checkInterval = 0.1
	local timeout = 3
	local startTime = Time.realtimeSinceStartup

	self.waitLandingTimer = TimerManager.addRepeatTimer(checkInterval, function()
		local landed = not pg.pawn or not pg.pawn:FALL_ST()

		if landed or Time.realtimeSinceStartup - startTime >= timeout then
			self:removeWaitLandingTimer()
			callback()
		end
	end)
end

function CommunicationSystem:removeWaitLandingTimer()
	if self.waitLandingTimer ~= nil then
		TimerManager.removeTimer(self.waitLandingTimer)

		self.waitLandingTimer = nil
	end
end

function CommunicationSystem:removeReadyRotationTimer()
	if self.readyRotationTimer ~= nil then
		TimerManager.removeTimer(self.readyRotationTimer)

		self.readyRotationTimer = nil
	end
end

function CommunicationSystem:recoverTargetNpcFaceTowards()
	if not self.dialogueGraphTargetEntityActorId then
		return
	end

	local targetNpcEntity = pg.getEntityByActorId(self.dialogueGraphTargetEntityActorId)

	if not targetNpcEntity then
		return
	end

	targetNpcEntity:stopLayerAnimation(2)

	local rawRotation = targetNpcEntity.lastRotation or targetNpcEntity.bornRotation

	if self.needResetRotation and rawRotation then
		local npcEntityId = targetNpcEntity.id

		AIUtils.PauseAI(npcEntityId, AiConst.PauseBtReason.DialogueControl)
		pg.global.ui.interact:setUIHide(UIConst.UI_HIDE_KEY.Dialogue, true)
		targetNpcEntity:turnToRotation(rawRotation)

		local npcTurnTime = AnimationUtils.getAnimationTurnTime(targetNpcEntity, rawRotation)

		if npcTurnTime == 0 then
			targetNpcEntity.isInInteractTurnAnim = true

			if targetNpcEntity.onInteractRotationRecovered then
				targetNpcEntity:onInteractRotationRecovered()
			end
		elseif targetNpcEntity.startInteractTurnTimer then
			targetNpcEntity:startInteractTurnTimer(npcTurnTime)
		end
	end
end

function CommunicationSystem:handleDefaultLookAt(dialogueId, index, lookAtId)
	if self.curChatType == DialogueConst.ChatType.BLACK_SCREEN then
		return
	end

	if self.enablePresetLookAt then
		if not self.enableDefaultLookAtFromPreset then
			return
		end
	elseif not self.enableDefaultLookAt then
		return
	end

	if #self.dialogueGraphControlEntityIds <= 1 then
		self:handleOneOnOneDefaultLookAt(dialogueId, index, lookAtId)

		return
	end

	local speakerId = NpcDialogueData[dialogueId][index].npcId
	local speakerStaticId = NpcDialogueData[dialogueId][index].npcStaticId
	local dialogueGraphTargetEntity = self.dialogueGraphTargetEntityActorId and pg.getEntityByActorId(self.dialogueGraphTargetEntityActorId)
	local speakerEntity = DialogueUtils.getDialogueEntity(speakerId, speakerStaticId, self.dialogueGraphControlEntityIds) or dialogueGraphTargetEntity

	lookAtId = lookAtId or NpcDialogueData[dialogueId][index].lookAtId

	local lookAtEntity = DialogueUtils.getDialogueEntityByTemplateId(lookAtId, self.dialogueGraphControlEntityIds)

	if speakerEntity then
		if lookAtEntity == nil and LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error(string.format("找不到需要被注视的对象 %s", lookAtId))
		end

		EntityLookAtUtils.setLookAtManual(speakerEntity, lookAtEntity)
		EntityLookAtUtils.setLookAtManual(pg.pawn, speakerEntity)

		if Utils.isPlayer(pg.pawn) then
			local curPetEntity = pg.pawn:getCurPetEntity()

			if curPetEntity then
				EntityLookAtUtils.setLookAtManual(curPetEntity, speakerEntity)
			end
		end

		for _, npcEntityId in ipairs(self.dialogueGraphControlEntityIds) do
			if speakerEntity.id ~= npcEntityId then
				local entity = pg.getEntity(npcEntityId)

				if entity then
					EntityLookAtUtils.setLookAtManual(entity, speakerEntity)
				end
			end
		end
	end

	EntityLookAtUtils.doModifyLookAt()
end

function CommunicationSystem:handleOneOnOneDefaultLookAt(dialogueId, index, lookAtId)
	local speakerId = NpcDialogueData[dialogueId][index].npcId
	local speakerStaticId = NpcDialogueData[dialogueId][index].npcStaticId

	lookAtId = lookAtId or NpcDialogueData[dialogueId][index].lookAtId

	local targetEntity = DialogueUtils.getDialogueEntityByTemplateId(lookAtId) or pg.pawn
	local dialogueGraphTargetEntity = self.dialogueGraphTargetEntityActorId and pg.getEntityByActorId(self.dialogueGraphTargetEntityActorId)
	local speakerEntity = DialogueUtils.getDialogueEntity(speakerId, speakerStaticId, self.dialogueGraphControlEntityIds) or dialogueGraphTargetEntity

	if targetEntity == nil and LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error(string.format("找不到需要被注视的对象 %s", lookAtId))
	end

	if speakerEntity and targetEntity and speakerEntity ~= targetEntity then
		EntityLookAtUtils.setLookAtManual(pg.pawn, speakerEntity)

		if speakerEntity.lookAtRole then
			EntityLookAtUtils.setLookAtManual(speakerEntity, targetEntity)

			self.triggeredLookAtEntIds[speakerEntity.id] = true
		end
	end

	EntityLookAtUtils.doModifyLookAt()
end

function CommunicationSystem:executeDialogEvent(dialogueId, index, npcEntityId, extraInfo)
	local isDialogueGraph = extraInfo and ToBool(extraInfo.isDialogueGraph)

	if pg.me then
		if isDialogueGraph then
			pg.me:serverMsg("RPC_CS_SetDialogueGroup", dialogueId, index, Const.DIALOGUE_STATE.IN_PROGRESS, self.dialogueEventContext)
		else
			pg.me:serverMsg("RPC_CS_SetDialogueGroup", dialogueId, index, Const.DIALOGUE_STATE.COMPLETED, self.dialogueEventContext)
			self:finishNpcDialog()
		end
	end

	if extraInfo and extraInfo.callback then
		extraInfo.callback(1, 0)
	end
end

function CommunicationSystem:showTopLogoBubble(dialogueId, index, npcEntityId, extraInfo)
	local entity = npcEntityId and pg.getEntity(npcEntityId)
	local callback

	if extraInfo ~= nil and extraInfo.callback ~= nil then
		if not entity then
			extraInfo.callback(1, 0)

			return
		end

		function callback()
			extraInfo.callback(1, 0)
		end
	end

	if entity and entity.eventEmitter then
		local forceShowInCombat = extraInfo ~= nil and extraInfo.src == DialogueConst.SrcType.COMBAT

		entity.eventEmitter:emit(EventConst.TOPLOGO_DIALOGUE, true, dialogueId, nil, callback, forceShowInCombat)
	end
end

function CommunicationSystem:showBlackScreen(dialogueId, index, npcEntityId, dialogueGraphParam)
	dialogueGraphParam = dialogueGraphParam or {}
	dialogueGraphParam.id = dialogueId
	dialogueGraphParam.isDialogueGraph = true

	pg.global.ui:open(UIConst.UI_ID_BLACK_SCREEN, dialogueGraphParam, nil, dialogueGraphParam.callback)
end

function CommunicationSystem:showWhiteScreen(dialogueId, index, npcEntityId, dialogueGraphParam)
	dialogueGraphParam = dialogueGraphParam or {}
	dialogueGraphParam.id = dialogueId
	dialogueGraphParam.isDialogueGraph = true

	pg.global.ui:open(UIConst.UI_ID_WHITE_SCREEN, dialogueGraphParam, nil, dialogueGraphParam.callback)
end

function CommunicationSystem:showAside(dialogueId, index, npcEntityId, extraInfo)
	local isDialogueGraph = extraInfo and ToBool(extraInfo.isDialogueGraph)

	if isDialogueGraph then
		self:showNpcCallDialogTextInternal(true, dialogueId, index, function()
			extraInfo.callback(1, 0)
		end, true, extraInfo)
	else
		self:showNpcCallDialogTextInternal(false, dialogueId, index, function()
			self:showNextDialogInfo(dialogueId, index, npcEntityId, extraInfo)
		end, true)
	end
end

function CommunicationSystem:openDialogPanel(dialogueId, index, npcEntityId, extraInfo, disablePositionPreset, cameraPreset)
	self:onNormalBottomDialogueStart(disablePositionPreset, cameraPreset)
	self:onCommonDialogStart(dialogueId, index)
	self:showNormalDialogueInternal(dialogueId, index, npcEntityId, extraInfo)

	if extraInfo.callback then
		pg.global.ui.dialogue:registerFinishCallback(extraInfo.callback)
	end
end

function CommunicationSystem:showNormalDialogueInternal(dialogueId, index, npcEntityId, extraInfo)
	local function cb()
		self:showNextDialogInfo(dialogueId, index, npcEntityId, extraInfo)
	end

	DialogueUtils.showDialogueUI(UIConst.UI_ID_BOTTOM_DIALOGUE, "showDialog", false, cb, nil, dialogueId, index, npcEntityId, extraInfo)
end

function CommunicationSystem:onCommonDialogStart(dialogueId, index)
	self:enableDialogUIMonopoly(true)

	if ToBool(NpcDialogueData[dialogueId][index].banControl) then
		self:enableDeprivePlayerControl(true)
		pg.game.input:resetAllActions()
	else
		self:enableDeprivePlayerControl(false)
	end

	if self.curChatType == DialogueConst.ChatType.DIALOGUE then
		self.cameraPresetType = NpcDialogueData[dialogueId][index].cameraPresetType or 0

		pg.game.input:setLockCursor(ClientConst.LockCursorKey.Dialogue, false)

		self.showCursor = true
	end
end

function CommunicationSystem:showBottomDialogue(dialogueId, index, npcEntityId, extraInfo)
	local isDialogueGraph = extraInfo and ToBool(extraInfo.isDialogueGraph)

	if isDialogueGraph then
		DialogueUtils.showDialogueUI(UIConst.UI_ID_BOTTOM_DIALOGUE, "showDialog", true, extraInfo.callback, extraInfo.cmd, dialogueId, index, npcEntityId, extraInfo)
	else
		pg.me:serverMsg("RPC_CS_StartDialogueGroup", dialogueId)

		local disablePositionPreset = extraInfo and extraInfo.disableTurn or NpcDialogueData[dialogueId][index].disablePositionPreset
		local cameraPreset = NpcDialogueData[dialogueId][index].cameraPresetType or 0

		local function openDialogFunc()
			local targetPos = self:preCalculateTargetPos(pg.pawn, self.targetEntity)

			if targetPos then
				pg.me:serverMsg("RPC_CS_ForbidPositionCheck", {
					1,
					dialogueId,
					targetPos,
					self.targetEntity.staticId or 0
				})
			end

			self:openDialogPanel(dialogueId, index, npcEntityId, extraInfo, disablePositionPreset, cameraPreset)
		end

		if self:checkExitControllingPet(dialogueId, index, self.targetEntity) then
			if not pg.me:requestSwitchToPlayer(Const.CLIENT_SWITCH_REASON.Dialogue, nil, openDialogFunc) then
				openDialogFunc()
			end
		else
			openDialogFunc()
		end
	end
end

function CommunicationSystem:onNormalBottomDialogueStart(disablePositionPreset, cameraPreset)
	if self.targetEntity == nil then
		return
	end

	AIUtils.PauseAI(self.targetEntity.id, AiConst.PauseBtReason.DialogueControl)

	if disablePositionPreset ~= 1 then
		local needTurn = cameraPreset ~= 1
		local pData = PuppetData[self.targetEntity.templateId]

		if not pData or not pData.lockDirection then
			self:faceToTarget(self.targetEntity, pg.pawn, false, needTurn)
		end

		if ClientUtils.getPetBodySizeType(self.targetEntity) == ClientConst.PetBodySizeType.SMALL and Utils.isPlayer(pg.pawn) and cameraPreset ~= 0 then
			self:faceToTargetAndCrouch(pg.pawn, self.targetEntity)
		else
			local needMovePos = true

			if disablePositionPreset == 2 or cameraPreset == 0 then
				needMovePos = false
			end

			self:faceToTarget(pg.pawn, self.targetEntity, needMovePos, needTurn)
		end
	end

	self.targetEntity.isInDialogue = true

	if self.targetEntity.onStartDialogue then
		self.targetEntity:onStartDialogue()
	end
end

function CommunicationSystem:onNormalBottomDialogueFinish()
	if pg.me:CROUCH_ST() then
		pg.me.eModel:SetInputCommand(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, InputCommand.Crouch)
	end

	local targetEntity = self.targetEntity

	if targetEntity == nil then
		return
	end

	if targetEntity.onFinishDialogue then
		targetEntity:onFinishDialogue()
	end

	targetEntity.isInDialogue = false

	local npcTurnTime = 0
	local pData = PuppetData[targetEntity.templateId]

	if pData and pData.resetRotation and targetEntity.bornRotation then
		targetEntity:turnToRotation(targetEntity.bornRotation)

		npcTurnTime = AnimationUtils.getAnimationTurnTime(targetEntity, targetEntity.bornRotation)
	end

	if npcTurnTime == 0 then
		AIUtils.ResumeAI(targetEntity.id, AiConst.PauseBtReason.DialogueControl)
	else
		if targetEntity.recoverRotationTimer ~= nil then
			targetEntity:removeTimer(targetEntity.recoverRotationTimer)

			targetEntity.recoverRotationTimer = nil
		end

		targetEntity.recoverRotationTimer = targetEntity:addTimer(npcTurnTime, function()
			if targetEntity then
				AIUtils.ResumeAI(targetEntity.id, AiConst.PauseBtReason.DialogueControl)
			end
		end)
	end
end

function CommunicationSystem:showNpcTeleCall(dialogueId, index, npcEntityId, extraInfo)
	local isDialogueGraph = extraInfo and ToBool(extraInfo.isDialogueGraph)

	if isDialogueGraph then
		self:showNpcCallDialogTextInternal(true, dialogueId, index, function()
			extraInfo.callback(1, 0)
		end, false, extraInfo)
	else
		self:showNpcCallDialogTextInternal(false, dialogueId, index, function()
			self:showNextDialogInfo(dialogueId, index, npcEntityId, extraInfo)
		end)
	end
end

function CommunicationSystem:showNpcCallDialogTextInternal(isDialogueGraph, dialogueId, index, callback, isAside, extraInfo)
	local content = LuaUIUtils.getReplacedDialogueText(NpcDialogueData[dialogueId][index].chat)
	local duration = extraInfo and extraInfo.duration or NpcDialogueData[dialogueId][index].duration
	local npcTemplateId = NpcDialogueData[dialogueId][index].npcId or 0
	local npcName, _ = self:getNpcInfoByDialogInfo(dialogueId, index)
	local cmd = extraInfo and extraInfo.cmd or nil

	DialogueUtils.showDialogueUI(UIConst.UI_ID_NPC_CALL, DialogueConst.UI_SHOW_FUNC_NAME[UIConst.UI_ID_NPC_CALL], isDialogueGraph, callback, cmd, npcName, npcTemplateId, content, duration, isAside)
end

function CommunicationSystem:showAIAssistant(dialogueId, index, npcEntityId, extraInfo)
	local isDialogueGraph = extraInfo and ToBool(extraInfo.isDialogueGraph)

	if isDialogueGraph then
		self:showAIAssistantTextInternal(true, dialogueId, index, function()
			extraInfo.callback(1, 0)
		end, extraInfo)
	else
		if self.forbidShowAIAssistant then
			if extraInfo and extraInfo.callback then
				extraInfo.callback(1, 0)
			end

			return
		end

		self:showAIAssistantTextInternal(false, dialogueId, index, function()
			self:showNextDialogInfo(dialogueId, index, npcEntityId, extraInfo)
		end)
	end
end

function CommunicationSystem:showAIAssistantTextInternal(isDialogueGraph, dialogueId, index, callback, extraInfo)
	if not isDialogueGraph and not pg.global.ui:checkUIShow(UIConst.UI_ID_HUD_V2) then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error(string.format("不在主界面 showAIAssistantTextInternal Failed！"))
		end

		if callback then
			callback()
		end

		return
	end

	local content = LuaUIUtils.getReplacedDialogueText(NpcDialogueData[dialogueId][index].chat)
	local duration = extraInfo and extraInfo.duration or NpcDialogueData[dialogueId][index].duration
	local cmd = extraInfo and extraInfo.cmd or nil
	local npcName, _ = self:getNpcInfoByDialogInfo(dialogueId, index)

	DialogueUtils.showDialogueUI(UIConst.UI_ID_AI_ASSISTANT, "showContent", isDialogueGraph, callback, cmd, npcName, content, duration)
end

function CommunicationSystem:showNextDialogInfo(dialogueId, index, npcEntityId, extraInfo)
	if self.curChatType == DialogueConst.ChatType.NONE then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("CommunicationSystem: Currently no dialog is running")
		end

		self:onClear()

		return
	end

	if extraInfo and extraInfo.isJump then
		extraInfo.isJump = false

		pg.me:serverMsg("RPC_CS_SetDialogueGroup", self.curDialogueId, self.curDialogueIndex, Const.DIALOGUE_STATE.COMPLETED, self.dialogueEventContext)

		if not dialogueId or not NpcDialogueData[dialogueId] then
			self:finishNpcDialog()

			return
		end

		self.curMaxDialogIndex = table.maxn(NpcDialogueData[dialogueId])
	else
		local maxDialogIndex = self.curMaxDialogIndex or table.maxn(NpcDialogueData[dialogueId])
		local isEnd = ToBool(NpcDialogueData[dialogueId][index]["end"])
		local isCompleted = maxDialogIndex <= index or isEnd
		local dialogueState = isCompleted and Const.DIALOGUE_STATE.COMPLETED or index == 1 and Const.DIALOGUE_STATE.START or Const.DIALOGUE_STATE.IN_PROGRESS

		pg.me:serverMsg("RPC_CS_SetDialogueGroup", dialogueId, index, dialogueState, self.dialogueEventContext)

		if isCompleted then
			local isTriggerSwitchBack = false

			isTriggerSwitchBack, dialogueId, index = self:triggerDialogueSwitchBack(dialogueId, index)

			if not isTriggerSwitchBack then
				self:finishNpcDialog()

				if extraInfo.callback then
					extraInfo.callback()
				end

				return
			end
		else
			index = index + 1
		end
	end

	self.curDialogueId = dialogueId
	self.curDialogueIndex = index

	local nextChatType = NpcDialogueData[dialogueId][index].chatType

	if nextChatType ~= self.curChatType then
		self:closeDialogUI()

		self.curChatType = nextChatType
	end

	local specialChatTypeHandleFunc = DialogueConst.SPECIAL_CHAT_TYPE_FUNC_MAP[self.curChatType]

	if specialChatTypeHandleFunc and self[specialChatTypeHandleFunc] then
		return self[specialChatTypeHandleFunc](self, dialogueId, index, npcEntityId, extraInfo)
	end

	local normalChatTypeHandleFunc = DialogueConst.CHAT_TYPE_FUNC_MAP[self.curChatType]

	if normalChatTypeHandleFunc and self[normalChatTypeHandleFunc] then
		table.insert(self.reviewLog, {
			dialogId = dialogueId,
			dialogIndex = index
		})

		return self[normalChatTypeHandleFunc](self, dialogueId, index, npcEntityId, extraInfo)
	end
end

function CommunicationSystem:checkDialogueDataValid(id, index, chatType)
	if chatType == DialogueConst.ChatType.BLACK_SCREEN then
		return true
	end

	if not NpcDialogueData[id] then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error(string.format("@策划 dialogId = %d 条目对白不存在！", id))
		end

		return false
	end

	if not NpcDialogueData[id][index] then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error(string.format("@策划 dialogId = %d, index = %d 条目对白不存在！", id, index))
		end

		return false
	end

	return true
end

function CommunicationSystem:checkDialoguePriorityValid(chatType, overridePriority)
	if self.curChatType ~= DialogueConst.ChatType.NONE and self.curDialogueId ~= nil and self.curDialogueIndex ~= nil then
		local curChatTypePriority = self.chatTypePriority[self.curChatType] or 9999
		local newChatTypePriority = overridePriority and overridePriority or self.chatTypePriority[chatType] or 9999

		if curChatTypePriority < newChatTypePriority then
			return false
		end
	end

	return true
end

function CommunicationSystem:checkDifferentEthnicGroup(targetNpcEntity, dialogueId, index, npcStaticId)
	local npcTemplateId = targetNpcEntity and targetNpcEntity.templateId or 0
	local staticId = npcStaticId or 0
	local npcData = PuppetData[npcTemplateId]
	local ret = false

	if npcData and npcData.npcType == DialogueConst.NpcType.Pet and (pg.me:isControllingMaster() or pg.me:isControllingPet() and not Utils.isPetsCanCommunicate(targetNpcEntity, pg.pawn)) and npcData then
		ret = true

		local spData = self:getNPCSpecialState(staticId)

		if spData and spData.unknowDialogue and spData.unknowDialogue > 0 then
			dialogueId = spData.unknowDialogue or dialogueId
		else
			dialogueId = npcData.unknowDialogue or dialogueId
		end

		index = 1
	end

	return ret, dialogueId, index
end

function CommunicationSystem:getNPCSpecialState(staticId)
	local player = pg.me

	if player.specialContentDict then
		local spId = player.specialContentDict[staticId]

		if spId then
			return NpcSpecialStateData[spId]
		end
	end
end

function CommunicationSystem:checkExitControllingPet(dialogueId, index, targetNpcEntity)
	local cData = NpcDialogueData[dialogueId][index]
	local exitMerge1 = pg.me:isControllingPet()
	local exitMerge2 = cData and cData.autoExitMerge ~= 0
	local exitMerge3 = true
	local pData = PuppetData[targetNpcEntity and targetNpcEntity.templateId or 0]

	if pData and pData.npcType == DialogueConst.NpcType.Pet and targetNpcEntity and exitMerge1 then
		exitMerge3 = false
	end

	return exitMerge1 and exitMerge2 and exitMerge3
end

function CommunicationSystem:getNpcHeadIconUrl(templateId)
	local pData = PuppetData[templateId]
	local iconUrl = pData and pData.iconName

	iconUrl = iconUrl or LuaUIUtils.getPetIconByTemplateId(templateId, LuaUIUtils.PET_ICON)

	return iconUrl
end

function CommunicationSystem:getNpcInfoByDialogInfo(dialogueId, index)
	local npcName = NpcDialogueData[dialogueId][index].npcName
	local npcTemplateId = NpcDialogueData[dialogueId][index].npcId or 0
	local iconUrl = self:getNpcHeadIconUrl(npcTemplateId)

	npcName = npcName or PuppetData[npcTemplateId] and PuppetData[npcTemplateId].name
	npcName = npcName and LuaUIUtils.getReplacedDialogueText(npcName)

	return npcName, iconUrl
end

function CommunicationSystem:getNpcInfoByTemplateId(npcTemplateId)
	local iconUrl = self:getNpcHeadIconUrl(npcTemplateId)
	local npcName = PuppetData[npcTemplateId] and PuppetData[npcTemplateId].name

	npcName = npcName and pg.getLocalizationText(npcName)

	return npcName, iconUrl
end

function CommunicationSystem:preCalculateTargetPos(selfEnt, target)
	if selfEnt and target then
		local targetDir = target:getPositionAgentPosition() - selfEnt:getPositionAgentPosition()

		targetDir.y = 0

		local targetRotation = Quaternion.LookRotation(targetDir, Vector3.up)
		local targetPos = target:getPosition() - targetRotation * Vector3.forward * 1.5

		targetPos = PhysicsUtils.getGroundPos(targetPos) or targetPos

		return targetPos
	end

	return nil
end

function CommunicationSystem:faceToTarget(selfEnt, target, needMovePos, needTurn)
	if selfEnt == nil or target == nil then
		return
	end

	local targetDir = target:getPositionAgentPosition() - selfEnt:getPositionAgentPosition()

	targetDir.y = 0

	local targetRotation = Quaternion.LookRotation(targetDir, Vector3.up)

	if needTurn then
		selfEnt:turnToRotation(targetRotation)
	else
		selfEnt:faceToRotation(targetRotation)
	end

	if needMovePos then
		local targetPos = target:getPosition() - targetRotation * Vector3.forward * 1.5

		targetPos = PhysicsUtils.getGroundPos(targetPos) or targetPos

		if not selfEnt.eModel:OverlapWithIgnoreLayers(Const.COMPONENT_MOTION, targetPos + Vector3.up * 0.003, targetRotation) then
			EModelUtils.setMotionPositionByNumber(selfEnt, targetPos[1], targetPos[2], targetPos[3])
		end
	end

	return targetRotation
end

function CommunicationSystem:faceToTargetAndCrouch(selfEnt, target)
	if selfEnt == nil or target == nil then
		return
	end

	local targetDir = target:getPositionAgentPosition() - selfEnt:getPositionAgentPosition()

	targetDir.y = 0

	local targetRotation = Quaternion.LookRotation(targetDir, Vector3.up)

	selfEnt:faceToRotation(targetRotation)
	selfEnt:playAnimation(PlayableConst.Crouch_Enter)

	local targetPos = target:getPosition() - targetRotation * Vector3.forward * 1.5

	targetPos = PhysicsUtils.getGroundPos(targetPos) or targetPos

	if not selfEnt.eModel:OverlapWithIgnoreLayers(Const.COMPONENT_MOTION, targetPos + Vector3.up * 0.003, targetRotation) then
		EModelUtils.setMotionPositionByNumber(selfEnt, targetPos[1], targetPos[2], targetPos[3])
	end

	selfEnt.eModel:SetInputCommand(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, InputCommand.Crouch)

	return targetRotation
end

function CommunicationSystem:getDialogueEntity(npcTemplateId, npcStaticId, dialogueId, dialogueIndex)
	npcTemplateId = npcTemplateId or NpcDialogueData[dialogueId][dialogueIndex].npcId

	return DialogueUtils.getDialogueEntity(npcTemplateId, npcStaticId, self.dialogueGraphControlEntityIds)
end

function CommunicationSystem:triggerAnimAction(npcTemplateId, npcStaticId, dialogueId, dialogueIndex, animKey, curAnimInfo)
	animKey = animKey or NpcDialogueData[dialogueId] and NpcDialogueData[dialogueId][dialogueIndex] and NpcDialogueData[dialogueId][dialogueIndex].actionId

	if not animKey then
		return false
	end

	npcTemplateId = npcTemplateId or NpcDialogueData[dialogueId][dialogueIndex].npcId
	npcStaticId = npcStaticId or NpcDialogueData[dialogueId][dialogueIndex].npcStaticId

	if not npcTemplateId and not npcStaticId then
		return false
	end

	local targetEntity, speakerType = DialogueUtils.getDialogueEntity(npcTemplateId, npcStaticId, self.dialogueGraphControlEntityIds)

	if targetEntity then
		if curAnimInfo ~= nil and curAnimInfo.entity.id == targetEntity.id then
			if curAnimInfo.isSleAni then
				curAnimInfo.entity:stopCfgAnimation()
			else
				curAnimInfo.entity:stopLayerAnimation(PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY)
			end
		end

		local isSleAni = DialogueUtils.playDialogueAnimation(targetEntity, animKey)

		return true, isSleAni, speakerType, targetEntity
	else
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("@hyj onTriggerAnimAction: cannot find targetEntity", animKey, npcTemplateId)
		end

		return false
	end
end

function CommunicationSystem:triggerCameraAnim(targetNpcEntity)
	if not targetNpcEntity then
		return
	end

	if self.cameraPresetType == 0 then
		local npcType = targetNpcEntity:getConfigData().npcType
		local isTargetNpcPet = Utils.isPetNpc(targetNpcEntity) or Utils.isPuppet(targetNpcEntity) and npcType ~= nil and npcType ~= Const.NPC_TYPE.Human
		local isPlayerHuman = Utils.isPlayer(pg.pawn)
		local minDis = 3
		local maxDis = 5
		local distance = 4
		local fov = 40
		local selfPos = pg.pawn:getPositionAgentPosition()
		local targetNpcPos = targetNpcEntity:getPositionAgentPosition()
		local midPoint = (selfPos + targetNpcPos) * 0.5

		if not isPlayerHuman and isTargetNpcPet then
			distance = 3

			local npcModelScale = targetNpcEntity.curModelScale or 1
			local tNearHeight, tFarHeight
			local pNearHeight, pFarHeight = pg.pawn:getCameraHeightInfo()

			if targetNpcEntity.getCameraHeightInfo then
				tNearHeight, tFarHeight = targetNpcEntity:getCameraHeightInfo()
			else
				tNearHeight = pNearHeight
			end

			local avgHeight = (pNearHeight + tNearHeight * npcModelScale) * 0.5

			midPoint.y = midPoint.y + avgHeight

			if pNearHeight < avgHeight then
				minDis = npcModelScale * minDis
				maxDis = npcModelScale * maxDis
				distance = minDis
				fov = 45

				pg.game.camera:setDofEnable(CameraConst.DofStateKeys.Dialogue_AniimoHuge, true)
			else
				pg.game.camera:setDofEnable(CameraConst.DofStateKeys.Dialogue_AniimoSmall, true)
			end
		elseif isPlayerHuman and not isTargetNpcPet then
			local playerHeight, _ = pg.me:getCameraHeightInfo()

			midPoint.y = midPoint.y + playerHeight - 0.2

			pg.game.camera:setDofEnable(CameraConst.DofStateKeys.Dialogue_HumanVSHuman, true)
		else
			local playerHeight, _ = pg.me:getCameraHeightInfo()

			midPoint.y = midPoint.y + playerHeight

			pg.game.camera:setDofEnable(CameraConst.DofStateKeys.Dialogue_HumanVSAniimo, true)
		end

		local initRot = DialogueUtils.calculateClosestInitialRotation(selfPos, targetNpcPos)

		pg.game.camera.npcDialogueCameraMode:enableFreedomCamera(true, initRot, midPoint, minDis, maxDis, distance, fov)
	end
end

function CommunicationSystem:triggerDialogueSwitchBack(dialogueId, index)
	local dialogueInfo = NpcDialogueData[dialogueId][index]
	local switchBackInfo = dialogueInfo.switchBack

	if not ToBool(switchBackInfo) then
		return false, dialogueId, index
	end

	local clientRecordFinished = dialogueInfo.finished

	if ToBool(clientRecordFinished) then
		pg.me.currentBranchState[dialogueId] = true
	end

	if self:isInNormalDialogue() then
		pg.global.ui.dialogue:clearDialogueBranchOption()
	end

	return true, switchBackInfo[1], switchBackInfo[2]
end

return CommunicationSystem
