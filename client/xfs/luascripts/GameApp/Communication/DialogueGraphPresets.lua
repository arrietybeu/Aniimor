-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Communication\\DialogueGraphPresets.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local AiConst = require("Common.Const.AiConst")
local AIUtils = require("Common.Utils.AIUtils")
local AnimationUtils = require("Common.Utils.AnimationUtils")
local ClientConst = require("Const.ClientConst")
local DialogueConst = require("Const.DialogueConst")
local DialogueUtils = require("Utils.DialogueUtils")
local NpcDialogueData = require("Data.npc_dialogue_data")
local PlayableConst = require("Common.Const.PlayableConst")
local Time = require("Core.Common.Time")
local TimerManager = require("Core.Timer.TimerManager")
local DialogueCamera = require("GameApp.Communication.DialogueCamera")
local M = {}

function M:prepareDialogue(dialogueGraphId, mode, npcStr, param, callback)
	local npcEntityIds = {}

	self.dialogueGraphControlEntityIds = npcEntityIds

	for entityId in string.gmatch(npcStr, "([^,]+)") do
		npcEntityIds[#npcEntityIds + 1] = entityId
	end

	self.beforeEntityRotationDic = {}

	local getEntity = pg.getEntity
	local firstEntity

	for _, entityId in ipairs(npcEntityIds) do
		AIUtils.PauseAI(entityId, AiConst.PauseBtReason.DialogueControl)

		local npcEntity = getEntity(entityId)

		if npcEntity ~= nil then
			npcEntity.isInDialogue = true
			self.beforeEntityRotationDic[npcEntity.id] = npcEntity:getRotation():Clone()
		end

		if firstEntity == nil then
			firstEntity = npcEntity
		end
	end

	if mode == DialogueConst.DIALOGUE_GRAPH_PRESET_MODE.OneOnOne then
		self:__enterOneOnOneMode(dialogueGraphId, firstEntity, param, callback)
	else
		self:__enterGroupMode(param, callback)
	end
end

function M:__enterOneOnOneMode(dialogueGraphId, npcEntity, param, callback)
	self.cameraPresetType = param.cameraPreset or DialogueConst.CAMERA_MODE.FREEDOM
	self.enableDefaultLookAtFromPreset = param.enableDefaultLookAt
	self.needResetRotation = param.resetOrientation

	if npcEntity == nil then
		return
	end

	self.dialogueGraphTargetEntityActorId = npcEntity.actorId
	self.dialogueEventContext.globalId = npcEntity.id
	npcEntity.isInDialogue = true

	local dialoguePerformanceLevel = param.reactPreset

	if dialoguePerformanceLevel == DialogueConst.PERFORMANCE_LEVEL.LOOK_AT_AND_TURN then
		self:__playLookAtAndTurnPreset(dialogueGraphId, npcEntity, param, callback)
	else
		self:__playDefaultPerformancePreset(npcEntity, param, dialoguePerformanceLevel, callback)
	end
end

function M:__playLookAtAndTurnPreset(dialogueGraphId, npcEntity, param, callback)
	npcEntity:playAnimation(PlayableConst.Idle, true, nil, false, 2)
	self:__waitForPlayerLanded(function()
		self:__faceToTargetNpc(npcEntity, callback, dialogueGraphId, param.cameraPreset, 0)
	end)

	if not DialogueUtils.isPetsSameEthnic(pg.pawn, npcEntity) then
		self.needResetRotation = true
	end
end

function M:__playDefaultPerformancePreset(npcEntity, param, dialoguePerformanceLevel, callback)
	if dialoguePerformanceLevel == DialogueConst.PERFORMANCE_LEVEL.IDLE_AND_LOOK_AT then
		npcEntity:playDefaultAnimation(true)
	end

	if dialoguePerformanceLevel ~= DialogueConst.PERFORMANCE_LEVEL.NO_PERFORMANCE then
		-- block empty
	end

	DialogueCamera.triggerCameraAnim(self.cameraPresetType, npcEntity)

	if callback ~= nil then
		callback()
	end
end

function M:__enterGroupMode(param, callback)
	self.enableDefaultLookAtFromPreset = param.enableGroupLookAt

	DialogueUtils.enterGroupCameraMode(param.cameraPreset or DialogueConst.CAMERA_MODE.FREEDOM, self.dialogueGraphControlEntityIds)

	if callback ~= nil then
		callback()
	end
end

function M:__waitForPlayerLanded(callback)
	self._removeTimer(self._TIMER_KEY.WAIT_LOADING)

	if pg.pawn == nil or pg.pawn.FALL_ST == nil or not pg.pawn:FALL_ST() then
		callback()

		return
	end

	local checkInterval = 0.1
	local timeout = 3
	local startTime = Time.realtimeSinceStartup

	self._timerDic[self._TIMER_KEY.WAIT_LOADING] = TimerManager.addRepeatTimer(checkInterval, function()
		local landed = pg.pawn == nil or not pg.pawn:FALL_ST()

		if landed or Time.realtimeSinceStartup - startTime >= timeout then
			self._removeTimer(self._TIMER_KEY.WAIT_LOADING)
			callback()
		end
	end)
end

function M:__triggerLookAtAndAnimForGraph(chatType, dialogueId, index, extraInfo, npcTemplateId, npcStaticId)
	if chatType == DialogueConst.ChatType.BUBBLE then
		self:triggerAnimAction(npcTemplateId, npcStaticId, dialogueId, index, extraInfo.actionId)

		return
	end

	if DialogueConst.CHAT_TYPE_FUNC_MAP[chatType] ~= nil and chatType ~= DialogueConst.ChatType.DIALOGUE then
		self:triggerAnimAction(npcTemplateId, npcStaticId, dialogueId, index, extraInfo.actionId)
	end
end

function M:__computeDurationIfNeeded(chatType, dialogueId, dialogueDataSet, index, extraInfo)
	local duration = -1

	if chatType == DialogueConst.ChatType.BLACK_SCREEN or chatType == DialogueConst.ChatType.WHITE_SCREEN then
		local dialogCount = dialogueDataSet ~= nil and table.getCount(dialogueDataSet) or 1

		duration = extraInfo.intervalTime * dialogCount
	else
		if extraInfo.matchAudioDuration then
			duration = DialogueUtils.getAudioDuration(dialogueId, index, extraInfo.audioName)
		end

		if duration == nil or duration < 0 then
			duration = extraInfo.duration
		end

		if duration == nil or duration < 0 then
			duration = DialogueUtils.getDialogueDuration(chatType, dialogueId, index)
		end
	end

	extraInfo.duration = duration

	if extraInfo.onSetDuration then
		extraInfo.onSetDuration(duration)
	end

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self._logger:info("Show Dialog dialogueId:%d chatType:%d duration:%s", dialogueId, chatType, tostring(duration))
	end
end

function M:__markDialogueGraphState(extraInfo)
	self.forbidClickTime = extraInfo.skipTime or 0
	self.curDialogueStartTime = pg.me:getGameTime()
	self.overrideDialogVoice = extraInfo.audioName
	self.isInDialogueGraphControl = true
	self.enablePresetLookAt = extraInfo.enablePresetLookAt or false
	extraInfo.isDialogueGraph = true
end

return M
