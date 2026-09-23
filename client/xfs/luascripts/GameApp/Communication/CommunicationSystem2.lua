-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Communication\\CommunicationSystem2.lua

local Class = require("Core.Framework.Class")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local SafeCallback = require("Core.Framework.SafeCallback")
local SafeCallbackWithStatusAndReturn = require("Core.Framework.SafeCallbackWithStatusAndReturn")
local SystemBase = require("GameApp.Core.SystemBase")
local TimerManager = require("Core.Timer.TimerManager")
local AiConst = require("Common.Const.AiConst")
local CameraConst = require("GameApp.Camera.CameraConst")
local ClientConst = require("Const.ClientConst")
local Const = require("Common.Const.Const")
local DialogueConst = require("Const.DialogueConst")
local EventConst = require("Const.EventConst")
local PlayableConst = require("Common.Const.PlayableConst")
local UIConst = require("Const.UIConst")
local AIUtils = require("Common.Utils.AIUtils")
local AnimationUtils = require("Common.Utils.AnimationUtils")
local ClientUtils = require("Utils.ClientUtils")
local DialogueUtils = require("Utils.DialogueUtils")
local EModelUtils = require("Entities.Utils.EModelUtils")
local InputCommand = require("GameApp.Input.InputCommand")
local Lume = require("Core.Common.lume")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PhysicsUtils = require("Common.Utils.PhysicsUtils")
local Time = require("Core.Common.Time")
local Utils = require("Common.Utils.Utils")
local NpcDialogueData = require("Data.npc_dialogue_data")
local NpcSpecialStateData = require("Data.npc_special_state_data")
local PuppetData = require("Data.puppet_data")
local DialogueUIBridge = require("GameApp.Communication.DialogueUIBridge")
local DialogueQuery = require("GameApp.Communication.DialogueQuery")
local DialogueVoice = require("GameApp.Communication.DialogueVoice")
local DialogueNodeEvents = require("GameApp.Communication.DialogueNodeEvents")
local DialogueAnimator = require("GameApp.Communication.DialogueAnimator")
local DialogueGraphPresets = require("GameApp.Communication.DialogueGraphPresets")
local DialogueDispatcher = require("GameApp.Communication.DialogueDispatcher")
local DialogueCompat = require("GameApp.Communication.DialogueCompat")
local EntityLookAtUtils = require("GameApp.Communication.EntityLookAtUtils")
local logger = LoggerManager.getLogger("CommunicationSystem")
local CommunicationSystem = Class.LightClass("CommunicationSystem", SystemBase)

for _, _module in ipairs({
	DialogueQuery,
	DialogueVoice,
	DialogueNodeEvents,
	DialogueAnimator,
	DialogueGraphPresets,
	DialogueDispatcher,
	DialogueCompat
}) do
	for k, v in pairs(_module) do
		if type(v) == "function" then
			rawset(CommunicationSystem, k, v)
		end
	end
end

local ToBool = ToBool
local Vector3 = Vector3
local Quaternion = Quaternion
local string = string
local table = table
local TIMER_KEY = {
	READY_ROTATION = "ready_rotation",
	WAIT_LOADING = "wait_loading"
}
local timerDic = {}

local function removeTimer(key)
	if timerDic[key] then
		TimerManager.removeTimer(timerDic[key])

		timerDic[key] = nil
	end
end

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
	self._timerDic = timerDic
	self._removeTimer = removeTimer
	self._TIMER_KEY = TIMER_KEY
	self._logger = logger
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

function CommunicationSystem:onInit()
	self.chatTypePriority = DialogueUtils.getDialoguePriority()
end

function CommunicationSystem:onClearData(isInterrupted)
	self.curDialogueId = nil
	self.curDialogueIndex = nil
	self.overrideDialogVoice = nil
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
	self.curParam = nil

	EntityLookAtUtils.clearAll()
end

function CommunicationSystem:onDestroy()
	self:onClearData()

	self.chatTypePriority = nil
	self.reviewLog = nil
	self.toplogoShowConfig = nil
	self.onDialogueGraphStartMsg = nil

	pg.global.eventEmitter:removeEventListener(EventConst.DIALOGUE_GRAPH_ON_START, self.onDialogueGraphStartMsg)
end

function CommunicationSystem:onSceneLoaded()
	EntityLookAtUtils.clearAll()
end

function CommunicationSystem:onPlayerLeaveScene()
	if self:isInDialogue() and self.isInDialogueGraphControl ~= true then
		self:finishNpcDialog()
	end
end

function CommunicationSystem:__resolveNpcDialog(dialogueId, extraInfo)
	if not pg.game.loading:isFinished() then
		return false
	end

	extraInfo = extraInfo or {}

	local npcDialogueData = NpcDialogueData[dialogueId]

	if not npcDialogueData then
		if UNITY_EDITOR and LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error(string.format("dialogueId = %d, 数据不存在! 反馈策划检查表配置 traceback:%s", dialogueId, debug.traceback()))
		end

		return false
	end

	local index = extraInfo.index or 1
	local dialogInfo = npcDialogueData[index]
	local curChatType = extraInfo.chatType or dialogInfo.chatType

	if not self:checkDialogueDataValid(dialogueId, index, curChatType) then
		return false
	end

	return true, index, curChatType
end

function CommunicationSystem:startNpcDialog(dialogueId, npcEntityId, extraInfo)
	if self.isInDialogueGraphControl then
		return
	end

	local ok, index, curChatType = self:__resolveNpcDialog(dialogueId, extraInfo)

	if not ok then
		return
	end

	extraInfo = extraInfo or {}
	npcEntityId = ToBool(npcEntityId) and npcEntityId or nil

	local customInfo = {}

	customInfo.needResetRotation = false

	local targetEntity

	if npcEntityId then
		local targetEntity = pg.getEntity(npcEntityId)

		npcEntityId = targetEntity ~= nil and targetEntity.id or npcEntityId

		if targetEntity then
			customInfo.needResetRotation = true
			customInfo.rotation = targetEntity:getRotation():Clone()
		end
	else
		targetEntity = nil
	end

	if extraInfo.duration == nil then
		local audioDuration = DialogueUtils.getAudioDuration(dialogueId, index)

		if audioDuration > 0 then
			extraInfo.duration = audioDuration
		end
	end

	return self:__showDialogText(curChatType, dialogueId, index, extraInfo, npcEntityId, customInfo)
end

function CommunicationSystem:finishNpcDialog(isInterrupted, key, customInfo)
	SafeCallback(self.onDialogueFinish, self, customInfo)
	SafeCallback(DialogueUIBridge.closeDialogUI, key)
	SafeCallback(self.onClearData, self, isInterrupted)

	return true
end

function CommunicationSystem:showDialogText(dialogueId, npcEntityId, dialogueGraphParam, context)
	return self:startDialogByGraph(dialogueId, npcEntityId, dialogueGraphParam, context)
end

function CommunicationSystem:startDialogByGraph(dialogueId, npcEntityId, extraInfo, context)
	if extraInfo == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self._logger:error("[startDialogByGraph] Invalid Call: DialogueGraph params nil, be sure it is called from DialogueGraph or use function[startNpcDialog] instead!", debug.traceback())
		end

		return false
	end

	local index = extraInfo.index or 1
	local dialogueGraphCallback = extraInfo.callback

	npcEntityId = ToBool(npcEntityId) and npcEntityId or nil

	local chatType = extraInfo.chatType

	if not self:checkDialogueDataValid(dialogueId, index, chatType) then
		if dialogueGraphCallback ~= nil then
			dialogueGraphCallback(1, 0)
		end

		return false
	end

	local curNpcDialogueData = NpcDialogueData[dialogueId]

	if chatType == nil then
		chatType = curNpcDialogueData[1].chatType
	end

	self:__computeDurationIfNeeded(chatType, dialogueId, curNpcDialogueData, index, extraInfo)

	local npcTemplateId = extraInfo.npcId
	local npcStaticId = extraInfo.npcStaticId
	local targetNpcEntity = npcEntityId and pg.getEntity(npcEntityId) or DialogueUtils.getDialogueEntity(npcTemplateId, npcStaticId, self.dialogueGraphControlEntityIds)

	npcEntityId = targetNpcEntity ~= nil and targetNpcEntity.id or npcEntityId

	self:__markDialogueGraphState(extraInfo)

	return self:__showDialogText(chatType, dialogueId, index, extraInfo, npcEntityId)
end

function CommunicationSystem:showNextDialogInfo(dialogueId, index, npcEntityId, extraInfo, customInfo)
	if self.curChatType == DialogueConst.ChatType.NONE then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			self._logger:warn("CommunicationSystem: Currently no dialog is running")
		end

		self:onClearData()

		return
	end

	if extraInfo ~= nil and extraInfo.isJump then
		extraInfo.isJump = false

		pg.me:serverMsg("RPC_CS_SetDialogueGroup", self.curDialogueId, self.curDialogueIndex, Const.DIALOGUE_STATE.COMPLETED, self.dialogueEventContext)

		if not dialogueId or not NpcDialogueData[dialogueId] then
			self:finishNpcDialog(nil, nil, customInfo)

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
				self:finishNpcDialog(nil, nil, customInfo)

				if extraInfo ~= nil and extraInfo.callback ~= nil then
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
		DialogueUIBridge.closeDialogUI()

		self.curChatType = nextChatType
	end

	local specialChatTypeHandleFunc = DialogueConst.SPECIAL_CHAT_TYPE_FUNC_MAP[self.curChatType]

	if specialChatTypeHandleFunc and self[specialChatTypeHandleFunc] then
		return self[specialChatTypeHandleFunc](self, dialogueId, index, npcEntityId, extraInfo)
	end

	local curNpcDialogueData = NpcDialogueData[dialogueId]
	local isMyAudio = false

	if curNpcDialogueData then
		local dialogInfo = curNpcDialogueData[index]

		if dialogInfo then
			isMyAudio = dialogInfo.npcId == 0
		end
	end

	if extraInfo == nil then
		extraInfo = {}
	end

	if extraInfo.duration == nil then
		local audioDuration = DialogueUtils.getAudioDuration(dialogueId, index)

		if audioDuration > 0 then
			extraInfo.duration = audioDuration
		end
	end

	if npcEntityId then
		self.targetEntity = pg.getEntity(npcEntityId)
	else
		self.targetEntity = nil
	end

	self:onDialoguePlayVoice(isMyAudio)

	local normalChatTypeHandleFunc = DialogueConst.CHAT_TYPE_FUNC_MAP[self.curChatType]

	if normalChatTypeHandleFunc and self[normalChatTypeHandleFunc] then
		self.reviewLog[#self.reviewLog + 1] = {
			dialogId = dialogueId,
			dialogIndex = index,
			chatType = self.curChatType
		}

		return self[normalChatTypeHandleFunc](self, dialogueId, index, npcEntityId, extraInfo, customInfo)
	end
end

return CommunicationSystem
