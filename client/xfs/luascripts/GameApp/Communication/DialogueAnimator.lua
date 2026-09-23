-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Communication\\DialogueAnimator.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local AiConst = require("Common.Const.AiConst")
local AIUtils = require("Common.Utils.AIUtils")
local AnimationUtils = require("Common.Utils.AnimationUtils")
local ClientConst = require("Const.ClientConst")
local Const = require("Common.Const.Const")
local ClientUtils = require("Utils.ClientUtils")
local DialogueConst = require("Const.DialogueConst")
local DialogueUtils = require("Utils.DialogueUtils")
local EModelUtils = require("Entities.Utils.EModelUtils")
local EntityLookAtUtils = require("GameApp.Communication.EntityLookAtUtils")
local InputCommand = require("GameApp.Input.InputCommand")
local NpcDialogueData = require("Data.npc_dialogue_data")
local PlayableConst = require("Common.Const.PlayableConst")
local PuppetData = require("Data.puppet_data")
local PhysicsUtils = require("Common.Utils.PhysicsUtils")
local TimerManager = require("Core.Timer.TimerManager")
local UIConst = require("Const.UIConst")
local Utils = require("Common.Utils.Utils")
local DialogueCamera = require("GameApp.Communication.DialogueCamera")
local M = {}

local function isRidingEntity(entity)
	return entity ~= nil and entity.RIDING_ST ~= nil and entity:RIDING_ST()
end

local function tryRidingEntityLookAt(communication, entity, target)
	if not isRidingEntity(entity) then
		return false
	end

	if entity.lookAtRole ~= nil then
		EntityLookAtUtils.setLookAtManual(entity, target)
		EntityLookAtUtils.doModifyLookAt()

		if communication.triggeredLookAtEntIds ~= nil then
			communication.triggeredLookAtEntIds[entity.id] = true
		end
	end

	return true
end

local function __getTargetRotation(selfEnt, targetRotation)
	local staticId = selfEnt.staticId or 0
	local extraAngle

	extraAngle = staticId == 0 and 0 or pg.game.dialogue:getExtraAngle(staticId)
	targetRotation = targetRotation * Quaternion.Euler(0, -extraAngle, 0)

	return targetRotation
end

function M:__faceToTarget(selfEnt, target, needMovePos, needTurn)
	if selfEnt == nil or target == nil then
		return
	end

	if tryRidingEntityLookAt(self, selfEnt, target) then
		return
	end

	local targetDir = target:getPositionAgentPosition() - selfEnt:getPositionAgentPosition()

	targetDir.y = 0

	local targetRotation = Quaternion.LookRotation(targetDir, Vector3.up)
	local newTargetRotation = __getTargetRotation(selfEnt, targetRotation)

	if needTurn then
		selfEnt:turnToRotation(newTargetRotation)
	else
		selfEnt:faceToRotation(newTargetRotation)
	end

	if needMovePos then
		local targetPos = target:getPosition() - targetRotation * Vector3.forward * 1.5

		targetPos = PhysicsUtils.getGroundPos(targetPos) or targetPos

		local selfPos = selfEnt:getPosition()

		if (targetPos - selfPos).magnitude < 10 and not selfEnt.eModel:OverlapWithIgnoreLayers(Const.COMPONENT_MOTION, targetPos + Vector3.up * 0.003, targetRotation) then
			EModelUtils.setMotionPositionByNumber(selfEnt, targetPos[1], targetPos[2], targetPos[3])
		end
	end

	return targetRotation
end

function M:__faceToTargetAndCrouch(selfEnt, target)
	if selfEnt == nil or target == nil then
		return
	end

	if tryRidingEntityLookAt(self, selfEnt, target) then
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

function M:__faceToTargetNpc(targetNpcEntity, callback, dialogueGraphId, cameraPreset, endState)
	cameraPreset = cameraPreset or DialogueConst.CAMERA_MODE.FREEDOM
	self.cameraPresetType = cameraPreset

	local turnTime = 0

	if targetNpcEntity ~= nil then
		local needTurn = cameraPreset ~= DialogueConst.CAMERA_MODE.IMMERSIVE
		local targetPos = self:preCalculateTargetPos(pg.pawn, targetNpcEntity)

		pg.me:serverMsg("RPC_CS_ForbidPositionCheck", {
			0,
			dialogueGraphId or 0,
			targetPos,
			targetNpcEntity.staticId or 0
		})

		local npcTargetRotation = self:__faceToTarget(targetNpcEntity, pg.pawn, false, needTurn)
		local playerTargetRotation = self:__facePlayerToTargetNpc(targetNpcEntity, cameraPreset, needTurn)

		if needTurn then
			local npcTurnTime = AnimationUtils.getAnimationTurnTime(targetNpcEntity, npcTargetRotation)
			local playerTurnTime = AnimationUtils.getAnimationTurnTime(pg.pawn, playerTargetRotation)

			turnTime = math.max(npcTurnTime, playerTurnTime)
		end
	end

	self._removeTimer(self._TIMER_KEY.WAIT_LOADING)

	if turnTime == 0 then
		DialogueCamera.triggerCameraAnim(self.cameraPresetType, targetNpcEntity)

		if callback ~= nil then
			callback()
		end

		return
	end

	self._timerDic[self._TIMER_KEY.READY_ROTATION] = TimerManager.addTimer(turnTime, function()
		self:__playEndStateAnimationIfNeeded(targetNpcEntity, endState)
		DialogueCamera.triggerCameraAnim(self.cameraPresetType, targetNpcEntity)

		if callback ~= nil then
			callback()
		end
	end)
end

function M:__facePlayerToTargetNpc(targetNpcEntity, cameraPreset, needTurn)
	local isSmallPet = ClientUtils.getPetBodySizeType(targetNpcEntity) == ClientConst.PetBodySizeType.SMALL

	if isSmallPet and Utils.isPlayer(pg.pawn) and cameraPreset ~= DialogueConst.CAMERA_MODE.FREEDOM then
		return self:__faceToTargetAndCrouch(pg.pawn, targetNpcEntity)
	end

	local needMovePos = cameraPreset ~= DialogueConst.CAMERA_MODE.FREEDOM

	return self:__faceToTarget(pg.pawn, targetNpcEntity, needMovePos, needTurn)
end

function M:__playEndStateAnimationIfNeeded(targetNpcEntity, endState)
	if endState == nil or targetNpcEntity == nil then
		return
	end

	if isRidingEntity(targetNpcEntity) then
		return
	end

	if endState == 0 then
		targetNpcEntity:playAnimation(PlayableConst.Idle, true, nil, false, 2)
	elseif endState == 1 then
		targetNpcEntity:playDefaultAnimation(true)
	end
end

function M:__setupPlayerAndNpcFaceToTarget(disablePositionPreset, cameraPreset)
	local needTurn = cameraPreset ~= DialogueConst.CAMERA_MODE.IMMERSIVE
	local npcTargetRotation
	local pData = PuppetData[self.targetEntity.templateId]

	if pData == nil or not pData.lockDirection then
		npcTargetRotation = self:__faceToTarget(self.targetEntity, pg.pawn, false, needTurn)
	end

	local playerTargetRotation
	local isSmallPet = ClientUtils.getPetBodySizeType(self.targetEntity) == ClientConst.PetBodySizeType.SMALL

	if isSmallPet and Utils.isPlayer(pg.pawn) and cameraPreset ~= DialogueConst.CAMERA_MODE.FREEDOM then
		playerTargetRotation = self:__faceToTargetAndCrouch(pg.pawn, self.targetEntity)
	else
		local needMovePos = disablePositionPreset ~= 2 and cameraPreset ~= DialogueConst.CAMERA_MODE.FREEDOM

		playerTargetRotation = self:__faceToTarget(pg.pawn, self.targetEntity, needMovePos, needTurn)
	end

	if not needTurn then
		return 0
	end

	local npcTurnTime = AnimationUtils.getAnimationTurnTime(self.targetEntity, npcTargetRotation)
	local playerTurnTime = AnimationUtils.getAnimationTurnTime(pg.pawn, playerTargetRotation)

	return math.max(npcTurnTime, playerTurnTime)
end

function M:__resetTargetEntityRotationIfNeeded(targetEntity)
	if isRidingEntity(targetEntity) then
		AIUtils.ResumeAI(targetEntity.id, AiConst.PauseBtReason.DialogueControl)

		return
	end

	local npcTurnTime = 0
	local pData = PuppetData[targetEntity.templateId]
	local rawRotation = targetEntity.bornRotation

	if pData ~= nil and ToBool(pData.resetRotation) and rawRotation ~= nil then
		targetEntity:turnToRotation(rawRotation)

		npcTurnTime = AnimationUtils.getAnimationTurnTime(targetEntity, rawRotation)
	end

	if npcTurnTime == 0 then
		AIUtils.ResumeAI(targetEntity.id, AiConst.PauseBtReason.DialogueControl)

		return
	end

	if targetEntity.recoverRotationTimer ~= nil then
		targetEntity:removeTimer(targetEntity.recoverRotationTimer)

		targetEntity.recoverRotationTimer = nil
	end

	targetEntity.recoverRotationTimer = targetEntity:addTimer(npcTurnTime, function()
		if targetEntity ~= nil then
			AIUtils.ResumeAI(targetEntity.id, AiConst.PauseBtReason.DialogueControl)
		end
	end)
end

function M:triggerAnimAction(npcTemplateId, npcStaticId, dialogueId, dialogueIndex, animKey, curAnimInfo)
	if animKey == nil then
		local dialogueData = NpcDialogueData[dialogueId]

		animKey = dialogueData ~= nil and dialogueData[dialogueIndex] ~= nil and dialogueData[dialogueIndex].actionId
	end

	if animKey == nil then
		return false
	end

	local dialogueEntry = NpcDialogueData[dialogueId] ~= nil and NpcDialogueData[dialogueId][dialogueIndex]

	if npcTemplateId == nil then
		npcTemplateId = dialogueEntry ~= nil and dialogueEntry.npcId
	end

	if npcStaticId == nil then
		npcStaticId = dialogueEntry ~= nil and dialogueEntry.npcStaticId
	end

	if npcTemplateId == nil and npcStaticId == nil then
		return false
	end

	local targetEntity, speakerType = DialogueUtils.getDialogueEntity(npcTemplateId, npcStaticId, self.dialogueGraphControlEntityIds)

	if targetEntity == nil then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			self._logger:warn("[triggerAnimAction] cannot find targetEntity", animKey, npcTemplateId)
		end

		return false
	end

	if curAnimInfo ~= nil and curAnimInfo.entity.id == targetEntity.id then
		if curAnimInfo.isSleAni then
			curAnimInfo.entity:stopCfgAnimation()
		else
			curAnimInfo.entity:stopLayerAnimation(PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY)
		end
	end

	local isSleAni = DialogueUtils.playDialogueAnimation(targetEntity, animKey)

	return true, isSleAni, speakerType, targetEntity
end

function M:triggerDialogueSwitchBack(dialogueId, index)
	local dialogueInfo = NpcDialogueData[dialogueId][index]
	local switchBackInfo = dialogueInfo.switchBack

	if not ToBool(switchBackInfo) then
		return false, dialogueId, index
	end

	if ToBool(dialogueInfo.finished) then
		pg.me.currentBranchState[dialogueId] = true
	end

	if self:isInNormalDialogue() then
		pg.global.ui.dialogue:clearDialogueBranchOption()
	end

	return true, switchBackInfo[1], switchBackInfo[2]
end

function M:recoverTargetNpcFaceTowards(customInfo)
	local targetNpcEntity

	if self.isInDialogueGraphControl then
		if self.dialogueGraphTargetEntityActorId == nil then
			return
		end

		targetNpcEntity = pg.getEntityByActorId(self.dialogueGraphTargetEntityActorId)
	else
		targetNpcEntity = self.targetEntity
	end

	if targetNpcEntity == nil then
		return
	end

	if not targetNpcEntity:isFullBodyDefaultAnimationPlaying() then
		targetNpcEntity:stopLayerAnimation(PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY)
	end

	if isRidingEntity(targetNpcEntity) then
		return
	end

	local needResetRotation, rotation

	if customInfo then
		needResetRotation = customInfo.needResetRotation
		rotation = customInfo.rotation
	else
		needResetRotation = self.needResetRotation
	end

	if needResetRotation ~= true then
		return
	end

	if rotation == nil and self.beforeEntityRotationDic then
		rotation = self.beforeEntityRotationDic[targetNpcEntity.id]
		self.beforeEntityRotationDic[targetNpcEntity.id] = nil
	end

	if rotation == nil then
		return
	end

	local npcEntityId = targetNpcEntity.id

	AIUtils.PauseAI(npcEntityId, AiConst.PauseBtReason.DialogueControl)
	pg.global.ui.interact:setUIHide(UIConst.UI_HIDE_KEY.Dialogue, true)

	local npcTurnTime = AnimationUtils.getAnimationTurnTime(targetNpcEntity, rotation)

	if npcTurnTime == 0 then
		targetNpcEntity:faceToRotation(rotation)

		targetNpcEntity.isInInteractTurnAnim = true

		if targetNpcEntity.onInteractRotationRecovered ~= nil then
			targetNpcEntity:onInteractRotationRecovered()
		end

		return
	end

	targetNpcEntity:turnToRotation(rotation)

	if targetNpcEntity.startInteractTurnTimer ~= nil then
		targetNpcEntity:startInteractTurnTimer(npcTurnTime)
	end
end

function M:clearRecoverTargetNpc(entity)
	if self.beforeEntityRotationDic then
		self.beforeEntityRotationDic[entity.id] = nil
	end
end

return M
