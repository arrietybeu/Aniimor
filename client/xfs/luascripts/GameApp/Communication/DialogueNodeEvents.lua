-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Communication\\DialogueNodeEvents.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local AiConst = require("Common.Const.AiConst")
local AIUtils = require("Common.Utils.AIUtils")
local ClientConst = require("Const.ClientConst")
local ClientUtils = require("Utils.ClientUtils")
local DialogueConst = require("Const.DialogueConst")
local DialogueUtils = require("Utils.DialogueUtils")
local EntityLookAtUtils = require("GameApp.Communication.EntityLookAtUtils")
local NpcDialogueData = require("Data.npc_dialogue_data")
local UIConst = require("Const.UIConst")
local PlayableConst = require("Common.Const.PlayableConst")
local DialogueCamera = require("GameApp.Communication.DialogueCamera")
local M = {}

function M:onDialogueStart(param, chatType, isMyAudio)
	local dialogueInfo = NpcDialogueData[self.curDialogueId][self.curDialogueIndex]

	self.reviewLog[#self.reviewLog + 1] = {
		dialogId = self.curDialogueId,
		dialogIndex = self.curDialogueIndex,
		chatType = chatType
	}

	DialogueUtils.sendDialogueInfoReport(self.curDialogueId, 1, self.curDialogueIndex, DialogueConst.SEND_REPORT_ACTION_EVENT.BEGIN_SENTENCE, 0)
	self:onDialoguePlayVoice(isMyAudio)

	if param.isDialogueGraph then
		return
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

	if ToBool(dialogueInfo.hideUI) then
		self:enableDialogUIMonopoly(true)
	end

	if self:isInNormalDialogue() then
		local disableCameraAnim = dialogueInfo.disableCameraLock or pg.game.communication.cameraPresetType == DialogueConst.CAMERA_MODE.NONE

		if not disableCameraAnim then
			DialogueCamera.triggerCameraAnim(self.cameraPresetType, self.targetEntity)
		end
	end
end

function M:__applyDialogueCameraIfNeeded(dialogueInfo)
	if not self:isInNormalDialogue() then
		return
	end

	local disableCameraAnim = dialogueInfo.disableCameraLock or pg.game.communication.cameraPresetType == DialogueConst.CAMERA_MODE.NONE

	if not disableCameraAnim then
		DialogueCamera.triggerCameraAnim(self.cameraPresetType, self.targetEntity)
	end
end

function M:onDialogueFinish(customInfo)
	local lookAtFadeTime = DialogueConst.DEFAULT_LOOK_AT_FADE_TIME

	if self.curChatType == DialogueConst.ChatType.DIALOGUE then
		self:onNormalBottomDialogueFinish()
	end

	pg.game.input:setLockCursor(ClientConst.LockCursorKey.Dialogue, true)
	pg.game.communication:enableDialogUIMonopoly(false)
	self:__cancelDialogueGraphEntitiesLookAt(lookAtFadeTime)
	self:__cancelTriggeredLookAtEntIds(lookAtFadeTime)
	self:__cancelPlayerAndPetLookAt(lookAtFadeTime)
	self:__cancelDialogueGraphTargetLookAt(lookAtFadeTime)
	self:recoverTargetNpcFaceTowards(customInfo)
	self._removeTimer(self._TIMER_KEY.WAIT_LOADING)
	self._removeTimer(self._TIMER_KEY.READY_ROTATION)
	pg.game.camera:enableNpcDialogue(false)
	ClientUtils.stopDialogueCameraDof()
	self:stopDialogVoice()
	self:clearBubbleCallback()

	self.toplogoShowConfig[UIConst.TOPLOGO_COMPONENT.CHAT] = false
	self.toplogoShowConfig[UIConst.TOPLOGO_COMPONENT.BUBBLE] = false
	self.toplogoShowConfig[UIConst.TOPLOGO_COMPONENT.NPC] = false

	EntityLookAtUtils.doModifyLookAt()
end

function M:__cancelDialogueGraphEntitiesLookAt(lookAtFadeTime)
	local getEntity = pg.getEntity
	local ResumeAI = AIUtils.ResumeAI

	for _, npcEntityId in ipairs(self.dialogueGraphControlEntityIds) do
		local npcEntity = getEntity(npcEntityId)

		if npcEntity ~= nil then
			if npcEntity.recoverRotationTimer == nil and npcEntity.recoverInteractRotationTimer == nil then
				ResumeAI(npcEntityId, AiConst.PauseBtReason.DialogueControl)
			end

			npcEntity.isInDialogue = nil

			EntityLookAtUtils.removeLookAtManual(npcEntity, lookAtFadeTime)
		end
	end
end

function M:__cancelTriggeredLookAtEntIds(lookAtFadeTime)
	local getEntity = pg.getEntity

	for entId, _ in pairs(self.triggeredLookAtEntIds) do
		local entity = getEntity(entId)

		if entity ~= nil then
			EntityLookAtUtils.removeLookAtManual(entity, lookAtFadeTime)
		end
	end
end

function M:__cancelPlayerAndPetLookAt(lookAtFadeTime)
	if pg.me == nil then
		return
	end

	EntityLookAtUtils.removeLookAtManual(pg.me, lookAtFadeTime)

	local curPetEnt = pg.me:getCurPetEntity()

	if curPetEnt ~= nil then
		EntityLookAtUtils.removeLookAtManual(curPetEnt, lookAtFadeTime)
	end
end

function M:__cancelDialogueGraphTargetLookAt(lookAtFadeTime)
	local dialogueGraphTargetEntity = self.dialogueGraphTargetEntityActorId and pg.getEntityByActorId(self.dialogueGraphTargetEntityActorId)

	if dialogueGraphTargetEntity ~= nil then
		EntityLookAtUtils.removeLookAtManual(dialogueGraphTargetEntity, lookAtFadeTime)
	end
end

return M
