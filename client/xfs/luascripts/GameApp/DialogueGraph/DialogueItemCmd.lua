-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueItemCmd.lua

local LoggerConst = require("Core.Log.LoggerConst")
local LoggerManager = require("Core.Log.LoggerManager")
local logger = LoggerManager.getLogger("DialogueItemCmd")
local Class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local ClientConst = require("Const.ClientConst")
local TimerManager = require("Core.Timer.TimerManager")
local SafeCallback = require("Core.Framework.SafeCallback")
local DialogueGraphConst = require("Const.DialogueGraphConst")
local CompiledRuntimeLoader = require("GameApp.DialogueGraph.DialogueGraphRuntime.Core.CompiledRuntimeLoader")
local DialogueGraphUtils = require("GameApp.DialogueGraph.DialogueGraphUtils")
local SafeCallbackWithStatusAndReturn = require("Core.Framework.SafeCallbackWithStatusAndReturn")
local DialogueGraphPlaybackController = require("GameApp.DialogueGraph.DialogueGraphPlaybackController")
local EModelUtils = require("Entities.Utils.EModelUtils")
local DialogueItemCmd = Class.LightClass("DialogueItemCmd")

function DialogueItemCmd:ctor(taskInfo)
	self.id = taskInfo.dialogueId
	self.config = taskInfo.config
	self.skipping = false
	self.autoPlayEnabled = true
	self.playState = DialogueGraphConst.DIALOGUE_GRAPH_STATE.NONE
	self.virtualEntities = {}
	self.taskInfo = taskInfo
	self.cmdNodeState = {}
	self.pauseBtEntities = {}
	self.cacheActorInfo = {}
	self.virtualActorAngle = {}
	self.pendingRPCList = {}
	self.playback = DialogueGraphPlaybackController.new(self)
	self.enableLuaGraph = DialogueGraphUtils.isLuaGraphEnabled(taskInfo)
	self.graphItem = pg.global.dialogueGraphMgr:CreateGraphItem(self.id, self.config.resPath, self, taskInfo.variables)
end

function DialogueItemCmd:preload()
	if self.enableLuaGraph then
		self:tryPreloadCompiledRunner()
	elseif self.graphItem then
		self.graphItem:Preload()
	end

	self.playState = DialogueGraphConst.DIALOGUE_GRAPH_STATE.READY
end

function DialogueItemCmd:preloadAsync(callback)
	if self.enableLuaGraph then
		self:tryPreloadCompiledRunner()

		self.playState = DialogueGraphConst.DIALOGUE_GRAPH_STATE.READY

		if callback then
			callback()
		end
	elseif self.graphItem then
		self.graphItem:AsyncPreload(function()
			self.playState = DialogueGraphConst.DIALOGUE_GRAPH_STATE.READY

			if callback then
				callback()
			end
		end)
	end
end

function DialogueItemCmd:tryPreloadCompiledRunner()
	if self.compiledRunnerResult ~= nil then
		return true
	end

	local context = {
		graphItem = self.graphItem,
		luaCmd = self,
		luaVariables = self.taskInfo.variables,
		resId = self.config.resPath
	}
	local status, result = SafeCallbackWithStatusAndReturn(CompiledRuntimeLoader.preload, self.id, context)

	if not status then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("load compiled dialogue graph failed, id=%s, error=%s", tostring(self.id), tostring(result))
		end

		return false
	end

	if result == nil or result.runner == nil then
		CompiledRuntimeLoader.dispose(result)

		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("create compiled dialogue graph runner failed, id=%s", tostring(self.id))
		end

		return false
	end

	self.compiledRunnerResult = result

	if self.graphItem ~= nil then
		self.graphItem:SetLuaRuntimeActive(true)
	end

	return true
end

function DialogueItemCmd:play()
	self:preload()
	self:init()

	if self.compiledRunnerResult ~= nil and self.compiledRunnerResult.runner ~= nil then
		self.compiledRunnerResult.runner:play()
	elseif self.graphItem ~= nil then
		self.graphItem:Play()
	end
end

function DialogueItemCmd:init()
	self:applyBaseSetting()
	self:applyActorsSetting()
end

function DialogueItemCmd:onDialogueGraphPlay()
	self.playState = DialogueGraphConst.DIALOGUE_GRAPH_STATE.PLAYING

	if self.taskInfo.startCmdCallback ~= nil then
		self.taskInfo.startCmdCallback(self.taskInfo.sysOwner, self)
	end
end

function DialogueItemCmd:onGraphNodeRunning(funName, ...)
	if self.playState ~= DialogueGraphConst.DIALOGUE_GRAPH_STATE.PLAYING then
		logger:info("对话图已经结束", funName)

		return
	end

	if self.taskInfo.nodeRunningFunc then
		local ret = self.taskInfo.nodeRunningFunc(self.taskInfo.sysOwner, self, funName, ...)

		if ret == false then
			return ret
		end
	end

	local funcInfo = DialogueGraphConst.NODE_FUNC_MAP[funName]

	if funcInfo then
		if funcInfo.stateCheckFunc == nil or DialogueGraphUtils[funcInfo.stateCheckFunc](self, ...) then
			self:setNodeFuncTypeState(funName)
		end

		local relatedFunc = funcInfo.relatedFunc

		if relatedFunc then
			self:cancelNodeFuncTypeState(relatedFunc)
		end
	end

	local status, ret
	local func = self[funName] or DialogueGraphUtils[funName]

	if func ~= nil then
		status, ret = SafeCallbackWithStatusAndReturn(func, self, ...)

		if not status then
			DialogueGraphUtils.executeCallbacks(...)
		end
	elseif LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("节点方法未定义:", funName)
	end

	if status and ret ~= nil then
		return ret
	end
end

function DialogueItemCmd:setNodeFuncTypeState(funcType)
	if funcType then
		self.cmdNodeState[funcType] = true
	end
end

function DialogueItemCmd:cancelNodeFuncTypeState(funcType)
	if funcType and self.cmdNodeState[funcType] then
		self.cmdNodeState[funcType] = false
	end
end

function DialogueItemCmd:clearNodeFuncTypeState(funcType)
	if funcType then
		self.cmdNodeState[funcType] = nil
	end
end

function DialogueItemCmd:checkNodeFuncTypeHasState(funcType)
	return self.cmdNodeState[funcType] ~= nil
end

function DialogueItemCmd:checkNodeFuncTypeTakeOver(funcType, param)
	local funcInfo = DialogueGraphConst.NODE_FUNC_MAP[funcType]

	if funcInfo and funcInfo.checkFunc then
		return self[funcInfo.checkFunc](self, param) or false
	end

	return false
end

function DialogueItemCmd:checkNodeFuncTypeInState(funcType)
	return self.cmdNodeState[funcType] == true
end

function DialogueItemCmd:checkNodeInCriticalFuncState()
	return self:checkNodeFuncTypeInState(DialogueGraphConst.NODE_FUNC_TYPE.PLAY_CUTSCENE)
end

function DialogueItemCmd:resetNodeFuncTypeState()
	if self:checkNodeFuncTypeHasState(DialogueGraphConst.NODE_FUNC_TYPE.DIALOGUE_SHOW_DIALOG) or self:checkNodeFuncTypeHasState(DialogueGraphConst.NODE_FUNC_TYPE.DIALOGUE_ENTER_DIALOGUE_PRESET) then
		pg.game.communication:finishNpcDialog()
	end

	for k, v in pairs(self.cmdNodeState) do
		if v == true then
			local cancelFunc = DialogueGraphConst.NODE_FUNC_MAP[k].cancelFunc

			if cancelFunc ~= nil then
				local func = DialogueGraphUtils[cancelFunc] or self[cancelFunc]

				if func then
					func(self)
				end
			end
		end
	end

	table.clear(self.cmdNodeState)
end

function DialogueItemCmd:setDialogueGraphModel(param)
	DialogueGraphUtils.setSkipUIBlackList(self, param.skipUIBlackList)

	if param.enableCharacterFillLight ~= nil then
		local enable = param.enableCharacterFillLight
		local intensity = param.characterFillLightIntensity

		DialogueGraphUtils.setCharacterFillLight(self, enable, intensity)
	end

	if param.disableDialogueCom then
		DialogueGraphUtils.disableEntityDialogueController(self, pg.pawn.id)
	end
end

function DialogueItemCmd:turnOnPlayback(arg)
	if self.playback then
		self.playback:turnOn(arg)
	end
end

function DialogueItemCmd:turnOffPlayback()
	if self.playback then
		self.playback:turnOff()
	end
end

function DialogueItemCmd:getPlaybackState()
	return self.playback and self.playback.playbackState or 0
end

function DialogueItemCmd:isSkipping()
	if self.playback then
		return self.playback:isSkipping()
	end

	return false
end

function DialogueItemCmd:startAutoPlay()
	if self.playback then
		self.playback:startAutoPlay()
	end
end

function DialogueItemCmd:stopAutoPlay()
	if self.playback then
		self.playback:stopAutoPlay()
	end
end

function DialogueItemCmd:isAutoPlaying()
	return self.playback ~= nil and self.playback:isAutoPlaying()
end

function DialogueItemCmd:enableSkipPermission()
	if self.playback then
		self.playback:enableSkipPermission()
	end
end

function DialogueItemCmd:disableSkipPermission()
	if self.playback then
		self.playback:disableSkipPermission()
	end
end

function DialogueItemCmd:startSkip()
	return self.playback ~= nil and self.playback:startSkip()
end

function DialogueItemCmd:stopSkip()
	if self.playback then
		self.playback:stopSkip()
	end
end

function DialogueItemCmd:pause()
	if self.playback then
		self.playback:pause()

		if self.compiledRunnerResult ~= nil and self.compiledRunnerResult.runner ~= nil then
			self.compiledRunnerResult.runner:pause()
		elseif self.graphItem ~= nil then
			self.graphItem:Pause()
		end
	end
end

function DialogueItemCmd:resume()
	if self.playback then
		self.playback:resume()

		if self.compiledRunnerResult ~= nil and self.compiledRunnerResult.runner ~= nil then
			self.compiledRunnerResult.runner:resume()
		elseif self.graphItem ~= nil then
			self.graphItem:Resume()
		end
	end
end

function DialogueItemCmd:canSkip()
	return self.playback ~= nil and self.playback:canSkip()
end

function DialogueItemCmd:setPlaySpeed(speed, force)
	if self.playback then
		self.playback:setPlaySpeed(speed, force)
	end
end

function DialogueItemCmd:getPlaySpeed()
	if self.playback then
		return self.playback:getPlaySpeed()
	end

	return 1
end

function DialogueItemCmd:scheduleRPC(type, param)
	local rpcCount = #self.pendingRPCList

	for i = 1, rpcCount do
		local rpcInfo = self.pendingRPCList[i]

		if rpcInfo[1] == type then
			if LoggerManager.checkLogger(LoggerConst.INFO) then
				logger:info("scheduleRPC Rpc已经存在！type：", type)
			end

			return
		end
	end

	if rpcCount >= 1 and LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("同一个对话图触发了多条RPC，请检查对话图配置！ rpcCount：", rpcCount)
	end

	table.insert(self.pendingRPCList, {
		type,
		param
	})
end

function DialogueItemCmd:stop(reason)
	self.finishReason = reason

	if self.compiledRunnerResult ~= nil and self.compiledRunnerResult.runner ~= nil then
		self.compiledRunnerResult.runner:stop()
	elseif self.graphItem ~= nil then
		self.graphItem:Stop()
	else
		self:onDialogueGraphFinish(-1)
	end
end

function DialogueItemCmd:onDialogueGraphFinish(ret)
	local forceClose = self.finishReason ~= DialogueGraphConst.FINISHED_REASON.INTERRUPTED_PLAYING

	if not forceClose and self.playback:isSkipping() then
		self.playback:registSkipFinishCallback(function()
			self:onDialogueGraphFinish(ret)
		end)
		self.playback:disableSkipPermission()
	else
		self:setDialogueGraphFinish(ret)
	end
end

function DialogueItemCmd:setDialogueGraphFinish(ret)
	self.playState = DialogueGraphConst.DIALOGUE_GRAPH_STATE.STOP

	if self.taskInfo.endCmdCallback ~= nil then
		local finishReason = self.finishReason or DialogueGraphConst.FINISHED_REASON.FINISHED

		self.taskInfo.endCmdCallback(self.taskInfo.sysOwner, ret, self, finishReason)
	end
end

function DialogueItemCmd:setEntityTakeOver(entId)
	if self.takeOverEntities == nil then
		self.takeOverEntities = {}
	end

	self.takeOverEntities[entId] = true

	return true
end

function DialogueItemCmd:checkEntityTakeOver(entId)
	if self.takeOverEntities == nil then
		return false
	end

	return self.takeOverEntities[entId]
end

function DialogueItemCmd:forbidPositionCheck(position)
	pg.me:forbidPositionCheck({
		Const.FORBID_POSITION_REASON.DIALOGUEGRAPH,
		self.id,
		position
	})
end

function DialogueItemCmd:applyBaseSetting()
	self.playSpeed = DialogueGraphUtils.getSetting(DialogueGraphConst.SETTING_KEY.DIALOGUE_GRAPH_PLAY_SPEED, 1)
end

function DialogueItemCmd:applyActorsSetting()
	self:removeRenewInvincible()

	local actors = self.config.actors

	if actors == nil then
		return
	end

	local actorIds

	for i = 1, #actors do
		local actor = actors[i]
		local ent = DialogueGraphUtils.getEntity(actor.staticId)

		if ent then
			if ent.eModel then
				ent.eModel:IgnoreCulling(Const.COMPONENT_INDEX_MODEL, true)
			end

			local cacheInfo = {
				entityId = ent.id
			}

			if actor.closeAI then
				cacheInfo.closeAI = true

				DialogueGraphUtils.pauseEntityBt(self, ent)
			end

			if actor.closeSpecialIdle then
				cacheInfo.closeSpecialIdle = true

				DialogueGraphUtils.canPlaySpecialIdleInDialogueGraph(self, ent, false)
			end

			if actor.reset then
				cacheInfo.reset = true
				cacheInfo.pos = ent:getPosition():Clone()
				cacheInfo.rot = ent:getRotation():Clone()
			end

			cacheInfo.angleDelta = actor.angleDelta or 0

			DialogueGraphUtils.pauseEntityAoi(self, ent)

			if not Utils.isMainPlayer(ent) and ent.isMainPet ~= true and not Utils.isBoss(ent) and not Utils.isElite(ent) then
				DialogueGraphUtils.toggleLodTick(self, ent, false)
			end

			self.cacheActorInfo[actor.staticId] = cacheInfo

			if actor.staticId > DialogueGraphConst.ENTITY_CUSTOM_STATIC_ID_MAX and ent.actorId and not Utils.isNpc(ent) then
				actorIds = actorIds or {}

				table.insert(actorIds, ent.actorId)
			end
		end
	end

	local virtualActors = self.config.virtualActors

	if virtualActors then
		for i = 1, #virtualActors do
			local vActor = virtualActors[i]

			self.virtualActorAngle[vActor.staticId] = vActor.extraAngle or 0
		end
	end

	self:addActorsRenewInvincible(actorIds)
end

function DialogueItemCmd:addActorRenewInvincible(entity)
	if not entity or not entity.actorId or Utils.isNpc(entity) then
		return
	end

	self.actorIds = self.actorIds or {}

	if table.contains(self.actorIds, entity.actorId) then
		return
	end

	table.insert(self.actorIds, entity.actorId)
	self:startActorsRenewInvincible()
end

function DialogueItemCmd:addActorsRenewInvincible(newActorIds)
	if newActorIds == nil or #newActorIds == 0 then
		return
	end

	local added = false

	self.actorIds = self.actorIds or {}

	for _, actorId in ipairs(newActorIds) do
		if not table.contains(self.actorIds, actorId) then
			table.insert(self.actorIds, actorId)

			added = true
		end
	end

	if added then
		self:startActorsRenewInvincible()
	end
end

function DialogueItemCmd:startActorsRenewInvincible()
	if self.actorIds == nil or #self.actorIds == 0 then
		return
	end

	local function sendRenewInvincible()
		pg.me:DialoguePauseRenewInvincible(self.actorIds, self.id)
	end

	sendRenewInvincible()

	if self.renewInvincibleTimer == nil then
		self.renewInvincibleTimer = TimerManager.addRepeatTimer(Const.DIALOGUE_PAUSE_NPC_INVINCIBLE_TIME - 1, sendRenewInvincible)
	end
end

function DialogueItemCmd:resetActorsSetting()
	self:removeRenewInvincible()

	for k, v in pairs(self.cacheActorInfo) do
		local ent = DialogueGraphUtils.getEntityByEntityId(v.entityId)

		if ent ~= nil then
			if ent.eModel then
				ent.eModel:IgnoreCulling(Const.COMPONENT_INDEX_MODEL, false)
			end

			if v.closeAI then
				DialogueGraphUtils.resumeEntityBt(self, ent)
			end

			if v.closeSpecialIdle then
				DialogueGraphUtils.canPlaySpecialIdleInDialogueGraph(self, ent, true)
			end

			if v.reset then
				local cacheInfo = v

				if cacheInfo and ent.eModel then
					EModelUtils.setAgentPositionAndRotation(ent, cacheInfo.pos, cacheInfo.rot, false)
				end
			elseif ent.eModel then
				local position = ent:getPosition()

				self:forbidPositionCheck(position)
				EModelUtils.setAgentPositionAndRotation(ent, position, ent:getRotation(), false)

				if Utils.isNpc(ent) then
					pg.game.entityCount:refreshEntityPositionData(ent.id, position)
				end
			end

			DialogueGraphUtils.resumeEntityAoi(self, ent)

			if not Utils.isMainPlayer(ent) and ent.isMainPet ~= true and not Utils.isBoss(ent) and not Utils.isElite(ent) then
				DialogueGraphUtils.toggleLodTick(self, ent, true)
			end

			if Utils.isMainPlayer(ent) and ent.eModel then
				ent.eModel.InPerformanceWalk = false
				ent.eModel.InPerformanceWalkSpeed = 1
			end
		end
	end
end

function DialogueItemCmd:removeRenewInvincible()
	if self.renewInvincibleTimer ~= nil then
		TimerManager.removeTimer(self.renewInvincibleTimer)

		self.renewInvincibleTimer = nil
	end

	self.actorIds = nil
end

function DialogueItemCmd:handleHideUI(uid)
	if self.uiHideCBs == nil then
		return
	end

	for k, v in pairs(self.uiHideCBs) do
		if v.uid == uid and v.cb ~= nil then
			v.cb()
		end
	end
end

function DialogueItemCmd:handleCloseUI(uid)
	if self.uiCloseCBs == nil then
		return
	end

	for k, v in pairs(self.uiCloseCBs) do
		if v.uid == uid and v.cb ~= nil then
			v.cb()
		end
	end
end

function DialogueItemCmd:registUIHideCB(nodeId, uid, cb)
	self.uiHideCBs = self.uiHideCBs or {}
	self.uiHideCBs[nodeId] = {
		uid = uid,
		cb = cb
	}
end

function DialogueItemCmd:unregistUIHideCB(nodeId, uid)
	if self.uiHideCBs ~= nil and self.uiHideCBs[nodeId] then
		self.uiHideCBs[nodeId] = nil
	end
end

function DialogueItemCmd:unregistAllUIHideCB()
	self.uiHideCBs = nil
end

function DialogueItemCmd:registUICloseCB(nodeId, uid, cb)
	self.uiCloseCBs = self.uiCloseCBs or {}
	self.uiCloseCBs[nodeId] = {
		uid = uid,
		cb = cb
	}
end

function DialogueItemCmd:unregistUICloseCB(nodeId)
	if self.uiCloseCBs ~= nil and self.uiCloseCBs[nodeId] then
		self.uiCloseCBs[nodeId] = nil
	end
end

function DialogueItemCmd:unregistAllUICloseCB()
	self.uiCloseCBs = nil
end

function DialogueItemCmd:getVirtualActorInfo(staticId)
	local virtualActors = self.config.virtualActors

	if virtualActors == nil then
		return
	end

	for i = 1, #virtualActors do
		if virtualActors[i].staticId == staticId then
			return virtualActors[i]
		end
	end
end

function DialogueItemCmd:isValid()
	return self.playState ~= nil and self.playState ~= DialogueGraphConst.DIALOGUE_GRAPH_STATE.NONE and self.playState ~= DialogueGraphConst.DIALOGUE_GRAPH_STATE.DESTROY
end

function DialogueItemCmd:isPlaying()
	return self.playState == DialogueGraphConst.DIALOGUE_GRAPH_STATE.PLAYING
end

function DialogueItemCmd:disposeCompiledRunner()
	local result = self.compiledRunnerResult

	if self.graphItem ~= nil then
		self.graphItem:SetLuaRuntimeActive(false)
	end

	if result == nil then
		return
	end

	self.compiledRunnerResult = nil

	local ok, err = SafeCallbackWithStatusAndReturn(CompiledRuntimeLoader.dispose, result)

	if not ok and LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("dispose compiled dialogue graph runner failed, id=%s, error=%s", tostring(self.id), tostring(err))
	end
end

function DialogueItemCmd:destroy()
	self:disposeCompiledRunner()
	self:unregistAllUIHideCB()
	self:unregistAllUICloseCB()

	self.playState = DialogueGraphConst.DIALOGUE_GRAPH_STATE.DESTROY

	SafeCallback(self.resetActorsSetting, self)
	SafeCallback(self.resetNodeFuncTypeState, self)
	SafeCallback(self.playback.destroy, self.playback)
	SafeCallback(DialogueGraphUtils.cancelAllLookAtRole, self)
	SafeCallback(DialogueGraphUtils.resumeAllEntitiesBt, self)
	SafeCallback(DialogueGraphUtils.resetEntitiesAnimSpeed, self)
	SafeCallback(DialogueGraphUtils.destroyAllVirtualEntities, self)
	SafeCallback(DialogueGraphUtils.stopPlayAllEffect, self)
	SafeCallback(DialogueGraphUtils.stopAllSound, self)
	SafeCallback(DialogueGraphUtils.resetAllEntitiesVisibilityEffect, self)
	SafeCallback(pg.global.dialogueGraphMgr.DestroyGraphItem, pg.global.dialogueGraphMgr, self.graphItem)

	self.graphItem = nil
	self.takeOverEntities = nil
	self.playback = nil
end

return DialogueItemCmd
