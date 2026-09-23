-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Controller\\PawnController.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local AbilityConst = require("Common.Const.AbilityConst")
local ControllerBase = require("GameApp.Controller.ControllerBase")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local InputCommand = require("GameApp.Input.InputCommand")
local TimerManager = require("Core.Timer.TimerManager")
local logger = LoggerManager.getLogger("ControllerSystem")
local NoticeDef = require("Common.NoticeDef")
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Time = require("Core.Common.Time")
local CatchProbContext = require("Common.Utils.CatchProbContext")
local ClientCaptureUtils = require("Utils.ClientCaptureUtils")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local SysConfigData = require("Data.sys_config_data")
local ConflictTypes = require("Common.ConflictTypes")
local TagMask = CS.FunPlus.WorldX.Animations.TagMask
local pg = pg
local PawnController = Class.LightClass("PawnController", ControllerBase)

function PawnController:ctor(pawn)
	self.pawn = pawn
	self.lastMoveInput = false
	self.lastDashTime = 0
	self.dashCount = 0
	self.lastShowDashTipTime = 0
end

function PawnController:enter(oldController, inheritMotion)
	if oldController and oldController.className == self.className and oldController.pawn == self.pawn then
		return
	end

	if oldController.isVehicle then
		return
	end

	local newEnt = self.pawn
	local oldEnt = oldController and oldController.pawn

	inheritMotion = inheritMotion or false

	appFacade.entityManager:SwitchControl(oldEnt and oldEnt.eModel, newEnt and newEnt.eModel, inheritMotion)

	if oldEnt and not oldEnt.isDestroyed then
		oldEnt:refreshControllerType()
		oldEnt:onLoseControlled()
	end

	if newEnt and not newEnt.isDestroyed and newEnt.eModel then
		newEnt:refreshControllerType()

		if newEnt:hasEModelComponent(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER) then
			newEnt.eModel.IsInControlMainPlayer = pg.game.controller:isInControlMainPlayer()
		end

		if newEnt.inSkillAim or newEnt.inSkillAim ~= pg.game.camera.playerCameraMode.isInAim then
			pg.game.camera.playerCameraMode:setInAim(newEnt.inSkillAim, newEnt.aimParam)
		end

		local blendTime = 0

		pg.game.camera:setTargetPlayer(newEnt, blendTime)
		newEnt:onBeControlled(oldEnt)
	end
end

function PawnController:checkPawn()
	return self.pawn and not self.pawn.isDestroyed and self.pawn.eModel ~= nil
end

function PawnController:onHandleMove(x, y, z)
	if not self:checkPawn() then
		return
	end

	local pawn = self.pawn
	local curMoveInput = false

	if x ~= 0 or y ~= 0 then
		pawn.subject:notify(AbilityConst.COMBAT_EVENT_ON_MOVE_BY_INPUT)

		curMoveInput = true
	end

	if curMoveInput ~= self.lastMoveInput then
		pawn.subject:notify(AbilityConst.COMBAT_EVENT_ON_PAWN_MOVE_INPUT_CHANGE, curMoveInput)

		self.lastMoveInput = curMoveInput

		pg.me:postComponentMethod("EVENT_OnMoveInputStateChanged", curMoveInput)
	end

	if pawn.updateSkillInputData then
		pawn:updateSkillInputData(x, y, z)
	end

	if x ~= 0 or y ~= 0 then
		local needClearNextSkillAction = true

		if pawn.isMotionDisable and pawn:isMotionDisable() then
			x = 0
			y = 0
			z = 0
			needClearNextSkillAction = false
		elseif not pawn:checkMove() and not pawn:canRotate() and not pawn:canMove() then
			x = 0
			y = 0
			z = 0
			needClearNextSkillAction = false
		elseif pawn.checkIsMotionDisableByAnim and pawn:checkIsMotionDisableByAnim() then
			x = 0
			y = 0
			z = 0
			needClearNextSkillAction = false
		elseif pawn:WALKING_ATTACK_ST() then
			needClearNextSkillAction = false
		end

		if needClearNextSkillAction then
			pg.game.controller.nextSkillAction:clear()
		end
	end

	local autoCastController = pg.game.controller.autoCastController

	if next(autoCastController.autoCastInfo) then
		if pawn:getGameTime() > autoCastController.autoCastInfo.canCancelTime then
			if x ~= 0 or y ~= 0 then
				autoCastController:cancel()
			else
				return
			end
		else
			return
		end
	end

	pg.game.controller:setCacheMoveAxis(x, y, z)
	pawn.eModel:OnHandleMove(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, x, y, z)
end

function PawnController:onHandleJump(isPress)
	if not self:checkPawn() then
		return
	end

	if isPress then
		if self.pawn.handleSkillJump then
			self.pawn:handleSkillJump()
		end

		local canFly = self.pawn:checkStatus(ConflictTypes.CT_FLY)
		local isFlying = CharacterStateConst.isChildOfState(self.pawn.characterState, CharacterStateConst.FLYING)

		if canFly and not isFlying then
			self.flyChargingTimer = TimerManager.addTimer(SysConfigData.enterFlyTimeAfterJump, function()
				self.flyChargingTimer = nil

				if self.pawn then
					self.pawn.eModel:SetInputCommand(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, InputCommand.FlyCharging)

					self.flyRiseActive = true

					self.pawn:beginStraightUp()
				end
			end)
		end

		self:performJump(self.pawn:checkJump(), isFlying)
	else
		if self.flyChargingTimer then
			TimerManager.removeTimer(self.flyChargingTimer)

			self.flyChargingTimer = nil
		end

		if self.flyRiseActive then
			self.flyRiseActive = nil

			if self.pawn then
				self.pawn:endStraightUp()
			end
		end
	end
end

function PawnController:performJump(canJump, inFly)
	if canJump then
		pg.game.controller.nextSkillAction:clear()
		self.pawn.eModel:SetInputCommand(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, InputCommand.Jump)
	elseif inFly then
		pg.game.controller.nextSkillAction:clear()
		self.pawn.eModel:SetInputCommand(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, InputCommand.StopFly)
	end
end

function PawnController:showUseSkillFailedMsg(skillId, result, reason, abilityType)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:log2Tag("LuaVerbose", "@bgf checkSkill", skillId, result, AbilityConst.ABILITY_CAST_FAILED_REASONS[reason])
	end

	local noticeId = Utils.abilityReason2noticeId(reason, abilityType)

	if NoticeDef.FAIL ~= noticeId then
		if reason == AbilityConst.ABILITY_CAST_ABILITY_NOT_ENOUGH_ITEM then
			local abilityParamData = pg.global.abilityMgr:getAbilityParamData(skillId)
			local itemCostId = abilityParamData.costItemId
			local itemInfo = LuaUIUtils.getItemClientInfoById(itemCostId)
			local itemName = pg.getLocalizationText(itemInfo.name)

			pg.global.showBubbleMessageById(noticeId, itemName)
		else
			pg.global.showBubbleMessageById(noticeId)
		end
	end
end

function PawnController:useSkill(skillId, abilityType, hideMsg, extraInfo)
	if not skillId then
		return false
	end

	if pg.me and pg.me.invasionInputDisabled then
		return false
	end

	if pg.game.qte:isPlayingSkillQte(skillId) then
		return false
	end

	local result, reason = self:innerUseSkill(skillId, abilityType, nil, extraInfo)

	if not hideMsg and not result then
		self:showUseSkillFailedMsg(skillId, result, reason, abilityType)
	end

	return result
end

function PawnController:innerUseSkill(skillId, abilityType, targetId, extraInfo)
	local useSkillEnt = self.pawn
	local abilityParamData = pg.global.abilityMgr:getAbilityParamData(skillId)

	if abilityParamData.isSetRogueExtraTempPet then
		useSkillEnt = pg.me
	end

	if extraInfo and extraInfo.targetActorId then
		targetId = extraInfo.targetActorId
	end

	if useSkillEnt:checkSpecialAttackModeNextAction(skillId) then
		skillId = useSkillEnt.specialAttackModeData.switchSkillInfo.from
	end

	local abilityTemplate = pg.global.abilityMgr:getAbilityTemplate(skillId)

	if AbilityConst.PUSH_SKILL_MAPS[abilityType] and (useSkillEnt.rePressSkillSlotInfo == nil or not pg.pawn.rePressSkillSlotInfo[skillId]) and not abilityTemplate.abilityIndicatorType then
		pg.game.controller.nextSkillAction:pushSkill(skillId, extraInfo)

		return true, AbilityConst.ABILITY_CAST_PUSH_SKILL
	elseif pg.game.controller.autoCastController:checkAutoCast(skillId, extraInfo) then
		return true, AbilityConst.ABILITY_CAST_AUTO_CAST
	end

	if useSkillEnt.rePressSkillSlotInfo and useSkillEnt.rePressSkillSlotInfo[skillId] and useSkillEnt:getGameTime() < useSkillEnt.rePressSkillSlotInfo[skillId].endTime then
		useSkillEnt:serverMsg("RPC_CS_RePressSkillSlot", skillId)
		useSkillEnt.subject:notify(AbilityConst.COMBAT_EVENT_ON_RE_PRESS_SKILL_SLOT, skillId)

		return false, AbilityConst.ABILITY_CAST_IS_CASTING
	end

	local castOnTarget = true

	if extraInfo and extraInfo.aimPos then
		castOnTarget = false
	else
		local partId = pg.me.lockedPartId

		targetId = targetId or pg.me.lockedActorId
		targetId, partId = pg.game.controller.lockHelper:tryLockTarget(targetId, partId)

		if targetId == nil or targetId == 0 then
			castOnTarget = false
			extraInfo = pg.game.controller.autoCastController:updateChaseActorId(skillId, extraInfo)
		end
	end

	if castOnTarget then
		local partId = pg.me.lockedPartId

		extraInfo = extraInfo or {
			partId = partId
		}

		local result, reason = useSkillEnt:clientCastAbilityOnTarget(skillId, targetId, nil, extraInfo)
		local isUseSkillEntPlayer = Utils.isPlayer(useSkillEnt)

		if result and isUseSkillEntPlayer then
			local currentPet = useSkillEnt:getCurPetEntity()

			if currentPet and AbilityUtils.getBpAbilityType(skillId) == AbilityConst.EnumAbilityType.Attack and not currentPet:isDead() and currentPet.agent then
				useSkillEnt:setPetState(Const.PET_STATE_GO, targetId)
			end
		end

		if isUseSkillEntPlayer and skillId ~= AbilityConst.BACK_SKILL_ID then
			local currentPet = useSkillEnt:getCurPetEntity()

			if currentPet then
				currentPet:removeAITag("TA_PetEnterBack")
			end
		end

		return result, reason
	else
		local result, reason = useSkillEnt:clientCastAbilityNoTarget(skillId, nil, extraInfo)

		return result, reason
	end
end

function PawnController:onHandleDash(isPress, ignoreCancelStates)
	if not self:checkPawn() then
		return
	end

	local pawnCharacterState = pg.pawn and pg.pawn.characterState
	local isFlying = pawnCharacterState and CharacterStateConst.isChildOfState(pawnCharacterState, CharacterStateConst.FLYING)

	if isFlying and (pg.me:judgeStaminaInCombat(TagMask.Fly) or pg.pawn:getConfigData().canFly ~= 3) then
		return
	end

	if isPress then
		if self.pawn:SPEEDBURST_DASH_BLOCK_ST() then
			return
		end

		if self.lastDashTime and Time.realSecondCache - self.lastDashTime < SysConfigData.dashRechargeTime and self.dashCount >= SysConfigData.dashLimitNum then
			if Time.realSecondCache - self.lastShowDashTipTime > 60 then
				pg.global.ui.tips:showTextTip(pg.getGameString("DASH_LIMIT_TIP"))

				self.lastShowDashTipTime = Time.realSecondCache
			end

			return
		end

		if Time.realSecondCache - self.lastDashTime > SysConfigData.dashRechargeTime then
			self.dashCount = 0
		end

		if self.pawn:CARRY_EGG_ST() then
			if not self.pawn:FAST_CARRY_EGG_ST() and pg.me:checkEndofStamina() then
				pg.global.showBubbleMessageById(NoticeDef.STAMINA_NOT_ENOUGH)

				return
			end

			self.lastDashTime = Time.realSecondCache

			self.pawn:switchFastCarryEggState()

			return
		end

		self.lastDashTime = Time.realSecondCache

		if pg.me and pg.me:isControllingEgg() and not pg.me:EGG_BE_CARRIED_ST() then
			if not pg.me:checkEggModeDashCD() then
				pg.global.showBubbleMessageById(NoticeDef.EGG_MODE_DASH_CD_LACK, math.fixedFloat(pg.me:getEggModeDashRemainCD()))

				return
			end

			pg.me:setEggModeDashCD()
		end

		if self.pawn:checkDash(false, ignoreCancelStates) then
			self.dashCount = self.dashCount + 1

			if self.pawn.cancelAbility then
				self.pawn:cancelAbility()
			end

			self.pawn.eModel:SetInputCommand(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, InputCommand.DashMark, true)
			self.pawn.eModel:SetInputCommand(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, InputCommand.Dash, true, 1)
		else
			pg.game.controller.nextSkillAction:doDash()
		end
	else
		self.pawn.eModel:SetInputCommand(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, InputCommand.Dash, false)
	end
end

function PawnController:onHandleQuickCapture(entId)
	if not self:checkPawn() then
		return false
	end

	local entity = pg.getEntity(entId)

	if not CatchProbContext.clientGet(entity).canCatch then
		return false
	end

	if entity.lastQuickCaptureTime and Time.realSecondCache - entity.lastQuickCaptureTime < 5 then
		return false
	end

	return self.pawn:quickCapture(entId)
end

function PawnController:onHandleBossCapture(entId)
	if not self:checkPawn() then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("catch boss PawnController:onHandleBossCapture checkPawn failed entId:%s", entId)
		end

		return false
	end

	local entity = pg.getEntity(entId)

	if not entity then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("catch boss PawnController:onHandleBossCapture entity failed entId:%s", entId)
		end

		return false
	end

	local itemId = ClientCaptureUtils.getItemBossCatchValid(entity)

	if not itemId then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("catch boss PawnController:onHandleBossCapture boss catch item failed entId:%s", entId)
		end

		return false
	end

	if not CatchProbContext.clientGet(entity, itemId).canCatch then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("catch boss PawnController:onHandleBossCapture CatchProbContext failed entId:%s", entId)
		end

		return false
	end

	return self.pawn:bossCapture(entId)
end

function PawnController:onHandleCrouch(isPress)
	if not self:checkPawn() then
		return
	end

	if self.pawn.switchCrouch and isPress and self.pawn:checkCrouch() then
		self.pawn:switchCrouch()
	end
end

function PawnController:onHandleSwitchCatchMode(enable)
	if not self:checkPawn() then
		return
	end

	if enable == nil then
		enable = not pg.me:isInCatchMode()
	end

	return self:setCatchModeEnable(enable)
end

function PawnController:setCatchModeEnable(enable)
	if not self:checkPawn() then
		return
	end

	if pg.me:isInCatchMode() == enable then
		return true
	end

	return self.pawn:toggleCatchMode()
end

return PawnController
