-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Communication\\DialogueDispatcher.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local AiConst = require("Common.Const.AiConst")
local AIUtils = require("Common.Utils.AIUtils")
local ClientConst = require("Const.ClientConst")
local ClientUtils = require("Utils.ClientUtils")
local Const = require("Common.Const.Const")
local DialogueConst = require("Const.DialogueConst")
local DialogueUIBridge = require("GameApp.Communication.DialogueUIBridge")
local DialogueUtils = require("Utils.DialogueUtils")
local EventConst = require("Const.EventConst")
local InputCommand = require("GameApp.Input.InputCommand")
local LuaUIUtils = require("Utils.LuaUIUtils")
local NpcDialogueData = require("Data.npc_dialogue_data")
local TimerManager = require("Core.Timer.TimerManager")
local UIConst = require("Const.UIConst")
local TimerManager = require("Core.Timer.TimerManager")
local M = {}

function M:executeDialogEvent(dialogueId, index, npcEntityId, extraInfo)
	if pg.me ~= nil then
		if extraInfo ~= nil and ToBool(extraInfo.isDialogueGraph) then
			pg.me:serverMsg("RPC_CS_SetDialogueGroup", dialogueId, index, Const.DIALOGUE_STATE.IN_PROGRESS, self.dialogueEventContext)
		else
			pg.me:serverMsg("RPC_CS_SetDialogueGroup", dialogueId, index, Const.DIALOGUE_STATE.COMPLETED, self.dialogueEventContext)
			self:finishNpcDialog()
		end
	end

	if extraInfo ~= nil and extraInfo.callback ~= nil then
		extraInfo.callback(1, 0)
	end
end

function M:showTopLogoBubble(dialogueId, index, npcEntityId, extraInfo)
	local entity = npcEntityId and pg.getEntity(npcEntityId)
	local extraCallback = extraInfo ~= nil and extraInfo.callback or nil

	if extraCallback ~= nil and entity == nil then
		extraCallback(1, 0)

		return
	end

	if entity == nil or entity.eventEmitter == nil then
		return
	end

	local forceShowInCombat = extraInfo ~= nil and extraInfo.src == DialogueConst.SrcType.COMBAT
	local callback = extraCallback ~= nil and function()
		extraCallback(1, 0)
	end or nil

	self:bubbleCallback(dialogueId, index, npcEntityId, extraInfo, callback)
	entity.eventEmitter:emit(EventConst.TOPLOGO_DIALOGUE, true, dialogueId, nil, nil, forceShowInCombat)
end

function M:bubbleCallback(dialogueId, index, npcEntityId, extraInfo, callback)
	self.bubbleDelayTimer = self.bubbleDelayTimer or {}

	local duration = DialogueConst.CUSTOM_BUBBLE_DEFAULT_DURATION
	local npcItem = NpcDialogueData[dialogueId]

	if npcItem then
		npcItem = npcItem[index or 1]
		duration = npcItem.duration or DialogueConst.CUSTOM_BUBBLE_DEFAULT_DURATION
	end

	local bubbleKey = string.format("%s_%s_%s_%s", dialogueId, index or 1, tostring(npcEntityId), tostring(extraInfo))

	self.bubbleDelayTimer[bubbleKey] = TimerManager.addTimer(duration, function()
		self.bubbleDelayTimer[bubbleKey] = nil

		if callback then
			callback()
		end
	end)
end

function M:clearBubbleCallback(extraInfo)
	if self.bubbleDelayTimer == nil then
		return
	end

	for _, timer in pairs(self.bubbleDelayTimer) do
		if timer then
			TimerManager.removeTimer(timer)
		end
	end

	self.bubbleDelayTimer = nil
end

function M:showAside(dialogueId, index, npcEntityId, extraInfo)
	if extraInfo ~= nil and ToBool(extraInfo.isDialogueGraph) then
		self:showNpcCallDialogTextInternal(true, dialogueId, index, function()
			extraInfo.callback(1, 0)
		end, true, extraInfo)

		return
	end

	self:showNpcCallDialogTextInternal(false, dialogueId, index, function()
		self:showNextDialogInfo(dialogueId, index, npcEntityId, extraInfo)
	end, true)
end

function M:showBottomDialogue(dialogueId, index, npcEntityId, extraInfo, customInfo)
	if extraInfo ~= nil and ToBool(extraInfo.isDialogueGraph) then
		DialogueUtils.showDialogueUI(UIConst.UI_ID_BOTTOM_DIALOGUE, "showDialog", true, extraInfo.callback, extraInfo.cmd, dialogueId, index, npcEntityId, extraInfo)

		return
	end

	self:__showBottomDialogueInNormalFlow(dialogueId, index, npcEntityId, extraInfo, customInfo)
end

function M:__showBottomDialogueInNormalFlow(dialogueId, index, npcEntityId, extraInfo, customInfo)
	pg.me:serverMsg("RPC_CS_StartDialogueGroup", dialogueId)

	local dialogueInfo = NpcDialogueData[dialogueId][index]
	local disablePositionPreset = extraInfo ~= nil and extraInfo.disableTurn or dialogueInfo.disablePositionPreset
	local cameraPreset = dialogueInfo.cameraPresetType or 0

	local function openDialogFunc()
		local targetPos = self:preCalculateTargetPos(pg.pawn, self.targetEntity)

		if targetPos ~= nil then
			pg.me:serverMsg("RPC_CS_ForbidPositionCheck", {
				1,
				dialogueId,
				targetPos,
				self.targetEntity.staticId or 0
			})
		end

		self:openDialogPanel(dialogueId, index, npcEntityId, extraInfo, disablePositionPreset, cameraPreset, customInfo)
	end

	if self:checkExitControllingPet(dialogueId, index, self.targetEntity) then
		if not pg.me:requestSwitchToPlayer(Const.CLIENT_SWITCH_REASON.Dialogue, nil, openDialogFunc) then
			openDialogFunc()
		end

		return
	end

	openDialogFunc()
end

function M:openDialogPanel(dialogueId, index, npcEntityId, extraInfo, disablePositionPreset, cameraPreset, customInfo)
	local turnTime = self:onNormalBottomDialogueStart(disablePositionPreset, cameraPreset)

	self:onCommonDialogStart(dialogueId, index)
	self._removeTimer(self._TIMER_KEY.READY_ROTATION)

	if turnTime == 0 then
		self:showNormalDialogueInternal(dialogueId, index, npcEntityId, extraInfo, customInfo)

		if extraInfo.callback ~= nil then
			pg.global.ui.dialogue:registerFinishCallback(extraInfo.callback)
		end

		return
	end

	self._timerDic[self._TIMER_KEY.READY_ROTATION] = TimerManager.addTimer(turnTime, function()
		self:showNormalDialogueInternal(dialogueId, index, npcEntityId, extraInfo, customInfo)

		if extraInfo.callback ~= nil then
			pg.global.ui.dialogue:registerFinishCallback(extraInfo.callback)
		end
	end)
end

function M:showNormalDialogueInternal(dialogueId, index, npcEntityId, extraInfo, customInfo)
	local function cb()
		self:showNextDialogInfo(dialogueId, index, npcEntityId, extraInfo, customInfo)
	end

	DialogueUtils.showDialogueUI(UIConst.UI_ID_BOTTOM_DIALOGUE, "showDialog", false, cb, nil, dialogueId, index, npcEntityId, extraInfo, cb, customInfo)
end

function M:onCommonDialogStart(dialogueId, index)
	self:enableDialogUIMonopoly(true)
	self:__applyDialogueControlPolicy(dialogueId, index)
	self:__applyDialogueCameraPreset(dialogueId, index)
end

function M:__applyDialogueControlPolicy(dialogueId, index)
	local banControl = ToBool(NpcDialogueData[dialogueId][index].banControl)

	self:enableDeprivePlayerControl(banControl)

	if banControl then
		pg.game.input:resetAllActions()
	end
end

function M:__applyDialogueCameraPreset(dialogueId, index)
	if self.curChatType ~= DialogueConst.ChatType.DIALOGUE then
		return
	end

	self.cameraPresetType = NpcDialogueData[dialogueId][index].cameraPresetType or 0

	pg.game.input:setLockCursor(ClientConst.LockCursorKey.Dialogue, false)

	self.showCursor = true
end

function M:onNormalBottomDialogueStart(disablePositionPreset, cameraPreset)
	if self.targetEntity == nil then
		return 0
	end

	AIUtils.PauseAI(self.targetEntity.id, AiConst.PauseBtReason.DialogueControl)

	local turnTime = 0

	if disablePositionPreset ~= 1 then
		turnTime = self:__setupPlayerAndNpcFaceToTarget(disablePositionPreset, cameraPreset)
	end

	self.targetEntity.isInDialogue = true

	if self.targetEntity.onStartDialogue then
		self.targetEntity:onStartDialogue()
	end

	return turnTime
end

function M:onNormalBottomDialogueFinish()
	if pg.me:CROUCH_ST() == true then
		pg.me.eModel:SetInputCommand(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, InputCommand.Crouch)
	end

	local targetEntity = self.targetEntity

	if targetEntity == nil then
		return
	end

	if targetEntity.onFinishDialogue ~= nil then
		targetEntity:onFinishDialogue()
	end

	targetEntity.isInDialogue = false

	self:__resetTargetEntityRotationIfNeeded(targetEntity)
end

function M:showBlackScreen(dialogueId, index, npcEntityId, dialogueGraphParam)
	dialogueGraphParam = dialogueGraphParam or {}
	dialogueGraphParam.id = dialogueId
	dialogueGraphParam.isDialogueGraph = true
	dialogueGraphParam.needClose = true

	pg.global.ui:open(UIConst.UI_ID_BLACK_SCREEN, dialogueGraphParam, nil, dialogueGraphParam.callback)
end

function M:showNpcTeleCall(dialogueId, index, npcEntityId, extraInfo)
	if extraInfo ~= nil and ToBool(extraInfo.isDialogueGraph) then
		self:showNpcCallDialogTextInternal(true, dialogueId, index, function()
			extraInfo.callback(1, 0)
		end, false, extraInfo)
	else
		self:showNpcCallDialogTextInternal(false, dialogueId, index, function()
			self:showNextDialogInfo(dialogueId, index, npcEntityId, extraInfo)
		end, false, extraInfo)
	end
end

function M:showNpcCallDialogTextInternal(isDialogueGraph, dialogueId, index, callback, isAside, extraInfo)
	local dialogueInfo = NpcDialogueData[dialogueId][index]
	local content = LuaUIUtils.getReplacedDialogueText(dialogueInfo.chat)
	local duration = extraInfo ~= nil and extraInfo.duration or dialogueInfo.duration
	local npcTemplateId = extraInfo ~= nil and extraInfo.npcId or dialogueInfo.npcId or 0
	local npcName, _ = self:getNpcInfoByDialogInfo(dialogueId, index)
	local cmd = extraInfo ~= nil and extraInfo.cmd or nil

	DialogueUtils.showDialogueUI(UIConst.UI_ID_NPC_CALL, DialogueConst.UI_SHOW_FUNC_NAME[UIConst.UI_ID_NPC_CALL], isDialogueGraph, callback, cmd, npcName, npcTemplateId, content, duration, isAside)
end

function M:showWhiteScreen(dialogueId, index, npcEntityId, dialogueGraphParam)
	dialogueGraphParam = dialogueGraphParam or {}
	dialogueGraphParam.id = dialogueId
	dialogueGraphParam.isDialogueGraph = true
	dialogueGraphParam.isDialogueGraph = true
	dialogueGraphParam.needClose = true

	pg.global.ui:open(UIConst.UI_ID_WHITE_SCREEN, dialogueGraphParam, nil, dialogueGraphParam.callback)
end

function M:showAIAssistant(dialogueId, index, npcEntityId, extraInfo)
	if self.isInDialogueGraphControl then
		self:showAIAssistantTextInternal(true, dialogueId, index, function()
			extraInfo.callback(1, 0)
		end, extraInfo)

		return
	end

	if self.forbidShowAIAssistant then
		if extraInfo ~= nil and extraInfo.callback ~= nil then
			extraInfo.callback(1, 0)
		end

		return
	end

	self:showAIAssistantTextInternal(false, dialogueId, index, function()
		self:showNextDialogInfo(dialogueId, index, npcEntityId, extraInfo)
	end)
end

function M:showAIAssistantTextInternal(isDialogueGraph, dialogueId, index, callback, extraInfo)
	if not isDialogueGraph and not pg.global.ui:checkUIShow(UIConst.UI_ID_HUD_V2) then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self._logger:error(string.format("[showAIAssistantTextInternal] 不在主界面, 调用失败!"))
		end

		if callback ~= nil then
			callback()
		end

		return
	end

	local dialogueInfo = NpcDialogueData[dialogueId][index]
	local content = LuaUIUtils.getReplacedDialogueText(dialogueInfo.chat)
	local duration = extraInfo ~= nil and extraInfo.duration or dialogueInfo.duration
	local cmd = extraInfo ~= nil and extraInfo.cmd or nil
	local npcName, _ = self:getNpcInfoByDialogInfo(dialogueId, index)

	DialogueUtils.showDialogueUI(UIConst.UI_ID_AI_ASSISTANT, "showContent", isDialogueGraph, callback, cmd, npcName, content, duration)
end

function M:enableDialogUIMonopoly(enable)
	DialogueUIBridge.enableDialogUIMonopoly(enable)
end

function M:enableDeprivePlayerControl(enable)
	DialogueUIBridge.enableDeprivePlayerControl(enable)

	self.showCursor = enable
end

return M
