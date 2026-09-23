-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientMotionComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local Const = require("Common.Const.Const")
local PlayableConst = require("Common.Const.PlayableConst")
local Utils = require("Common.Utils.Utils")
local AbilityConst = require("Common.Const.AbilityConst")
local ClientConst = require("Const.ClientConst")
local SysConfigData = require("Data.sys_config_data")
local WaterCollideData = require("Data.water_collide_data")
local AIControllerUtils = require("Common.Utils.AIControllerUtils")
local AttributeConst = require("Common.Const.AttributeConst")
local CallbackHandler = require("Core.Common.CallbackHandler")
local AnimationUtils = require("Common.Utils.AnimationUtils")
local ClientAbilityUtils = require("Utils.ClientAbilityUtils")
local NoticeDef = require("Common.NoticeDef")
local Time = require("Core.Common.Time")
local InputCommand = require("GameApp.Input.InputCommand")
local MessageName = require("Const.MessageName")
local AiConst = require("Common.Const.AiConst")
local EModelUtils = require("Entities.Utils.EModelUtils")
local Vector3 = Vector3
local Quaternion = Quaternion
local ClientMotionComponent = class.Component("ClientMotionComponent")
local ControllerType = Const.EntityControllerType
local Wait_Water_Splash_Frame = 5

function ClientMotionComponent:start()
	if self.actorCombatAttribute then
		self.actorCombatAttribute:registerAttributeNotify(AttributeConst.speed_ratio_walk_v, self.onWalkSpeedRatioChange)
		self.actorCombatAttribute:registerAttributeNotify(AttributeConst.speed_ratio_run_v, self.onRunSpeedRatioChange)
		self.actorCombatAttribute:registerAttributeNotify(AttributeConst.speed_ratio_sprint_v, self.onSprintSpeedRatioChange)
		self.actorCombatAttribute:registerAttributeNotify(AttributeConst.speed_ratio_standholdball_v, self.onHoldballSpeedRatioChange)
		self.actorCombatAttribute:registerAttributeNotify(AttributeConst.speed_ratio_swim_v, self.onSwimSpeedRatioChange)
		self.actorCombatAttribute:registerAttributeNotify(AttributeConst.speed_ratio_swim_fast_v, self.onSwimFastSpeedRatioChange)
		self.actorCombatAttribute:registerAttributeNotify(AttributeConst.speed_ratio_swim_dash_v, self.onSwimDashSpeedRatioChange)
		self.actorCombatAttribute:registerAttributeNotify(AttributeConst.speed_ratio_glide_v, self.onGlideSpeedRatioChange)

		if self.actorCombatAttribute.isPet then
			self.actorCombatAttribute:registerAttributeNotify(AttributeConst.speed_ratio_dash_v, self.onDashSpeedRatioChange)
		end

		self.actorCombatAttribute:registerAttributeNotify(AttributeConst.speed_ratio_load_adjustment_v, self.onSpeedRatioLoadAdjustmentChange)
		self.actorCombatAttribute:registerAttributeNotify(AttributeConst.speed_ratio_egg_mode_v, self.onEggModeSpeedRatioChange)
		self.actorCombatAttribute:registerAttributeNotify(AttributeConst.speed_ratio_fallen_v, self.onFallenSpeedRatioChange)
	end

	self:initDisableWeightPushConfig()

	return true
end

function ClientMotionComponent:ctor()
	self.disableMotionDict = {}
	self.disableMotionByAnimDict = {}
end

function ClientMotionComponent:onMotionAttrChange()
	if self.eModel == nil then
		return
	end

	self.eModel:OnSpeedRatioChange(Const.COMPONENT_MOTION)
end

function ClientMotionComponent:getMotionAttr(attributeProp)
	return self.actorCombatAttribute[attributeProp](self.actorCombatAttribute)
end

function ClientMotionComponent:getAttributeSpeedRatio(attributeName)
	local attributeId = AttributeConst[attributeName]

	if attributeId == nil or self.actorCombatAttribute == nil then
		return 1
	end

	local modifier = self.actorCombatAttribute:getAttribValue(attributeId) or 0

	return 1 + math.max(-1, modifier)
end

function ClientMotionComponent:onWalkSpeedRatioChange()
	self:onMotionAttrChange()
	AIControllerUtils.refreshWalkSpeed(self)
end

function ClientMotionComponent:onRunSpeedRatioChange()
	self:onMotionAttrChange()
	AIControllerUtils.refreshRunSpeed(self)
	AIControllerUtils.refreshSkateBoardSpeed(self)
end

function ClientMotionComponent:onSprintSpeedRatioChange()
	self:onMotionAttrChange()
	AIControllerUtils.refreshSprintSpeed(self)
end

function ClientMotionComponent:onHoldballSpeedRatioChange()
	self:onMotionAttrChange()
end

function ClientMotionComponent:onSwimSpeedRatioChange()
	self:onMotionAttrChange()
	AIControllerUtils.refreshSwimSpeed(self)
end

function ClientMotionComponent:onSwimFastSpeedRatioChange()
	self:onMotionAttrChange()
	AIControllerUtils.refreshSwimFastSpeed(self)
end

function ClientMotionComponent:onSwimDashSpeedRatioChange()
	self:onMotionAttrChange()
	AIControllerUtils.refreshSwimFastSpeed(self)
end

function ClientMotionComponent:onGlideSpeedRatioChange()
	self:onMotionAttrChange()
	AIControllerUtils.refreshGlideSpeed(self)
end

function ClientMotionComponent:onDashSpeedRatioChange()
	self:onMotionAttrChange()
	AIControllerUtils.refreshSprintSpeed(self)
end

function ClientMotionComponent:onSpeedRatioLoadAdjustmentChange()
	if self:isControllingPet() then
		local petEnt = self:getCurPetEntity()

		petEnt:onMotionAttrChange()
	else
		self:onMotionAttrChange()
	end
end

function ClientMotionComponent:onEggModeSpeedRatioChange()
	self.eModel.eggModeSpeedRatio = self.actorCombatAttribute:getEggModeSpeedRatio()
end

function ClientMotionComponent:onFallenSpeedRatioChange()
	self:onMotionAttrChange()
end

function ClientMotionComponent.initStatic()
	local motionClass = CS.FunPlus.WorldX.Entities.Components.MotionComponent

	motionClass.enableWeightPush = SysConfigData.enableWeightPush
	motionClass.weightPushThreshold = SysConfigData.weightPushThreshold
	motionClass.weightPushMaxSpeed = SysConfigData.WeightPushMaxSpeed
	motionClass.floatingDuration = SysConfigData.floatingDuration or 0.6
	motionClass.waterJumpVelocityScale = SysConfigData.waterJumpVelocityScale or 1
	motionClass.waterVelocityScale = SysConfigData.waterVelocityScale or 0.7
	motionClass.collisionIgnoreRatio = SysConfigData.collisionIgnoreRatio
	motionClass.minRigidbodyCollisionV = SysConfigData.minRigidbodyCollisionV
	motionClass.controllerCollisionDmgRatio = SysConfigData.controllerCollisionDmgRatio
	motionClass.controllerMaxCollisionV = SysConfigData.controllerMaxCollisionV

	local characterControllerClass = CS.FunPlus.WorldX.Entities.Components.CharacterControllerComponent
	local walkTransitionCurve = characterControllerClass.WalkTransitionCurve

	for _, curveValues in ipairs(SysConfigData.HoldBallMove_TransitionCurve) do
		local keyFrame = CS.UnityEngine.Keyframe(curveValues[1], curveValues[2], curveValues[3], curveValues[4])

		walkTransitionCurve:AddKey(keyFrame)
	end
end

function ClientMotionComponent:resetMotorTempState()
	self.eModel:ResetMotorTempState(Const.COMPONENT_MOTION)
end

function ClientMotionComponent:playRaiseUp(dist, duration, unGroundTime)
	self.eModel:RaiseUp(Const.COMPONENT_MOTION, dist, duration)
	self.eModel:ForceNotGroundCheck(Const.COMPONENT_MOTION, unGroundTime)
end

function ClientMotionComponent:refreshControllerType()
	if self.eModel then
		if pg.pawn == self then
			self.eModel:SwitchControllerEx(ControllerType.Player)
		else
			local keepPlayerController = false

			if self.isMainPlayer and self.switchEndTime and Time.realSecondCache <= self.switchEndTime then
				keepPlayerController = true
			end

			if keepPlayerController then
				self.eModel:SwitchControllerEx(ControllerType.Player)
			else
				self.eModel:SwitchControllerEx(ControllerType.AI)
			end
		end

		facade:SendMessageCommand(MessageName.CONTROL_TYPE_CHANGE)
	end
end

function ClientMotionComponent:applyMotionProp()
	local configData = self:getConfigData()

	self:applyStaticMotionProp(configData)
	self:applyCharacterControllerProp(configData)
end

function ClientMotionComponent:applyStaticMotionProp(configData)
	if self:hasEModelComponent(Const.COMPONENT_MOTION) then
		self:resetControlledMotionProp(configData)

		self.eModel.gravity = -SysConfigData.g
		self.eModel.mass = self.bodyMass or 1
		self.eModel.weight = self.bodyWeight or 1
		self.eModel.flySpeedRatio = 1
		self.eModel.airDamping = 2
		self.eModel.crouchCapsuleHeight = configData.rigidbodyHeightInCrouch or 1
		self.eModel.flySpeed = SysConfigData.defaultFlySpeedRatioBySprint * SysConfigData.sprintSpeedLevels[configData.moveLevel or 1]

		local tSteeringTime = configData.turnMaxTime or SysConfigData.defaultTurnMaxTime

		self.eModel.steeringTimeDefault = tSteeringTime

		self.eModel:SetSteering(Const.COMPONENT_MOTION, tSteeringTime)

		self.eModel.slipRadiusRatio = configData.slipRadiusRatio or SysConfigData.defaultSlipRadiusRatio
		self.eModel.climbEndSlidingSpeed = configData.climbEndSlidingSpeed or SysConfigData.defaultClimbEndSlidingSpeed or 1
		self.eModel.canFloat = configData.canFloat or false
		self.eModel.flyLevel = configData.canFly or 0
		self.eModel.enterSwimDepth = (configData.enterSwimDepthRatio or SysConfigData.defaultEnterSwimDepthRatio) * (configData.modelHeight or 0)
		self.eModel.exitSwimDepth = (configData.exitSwimDepthRatio or SysConfigData.defaultExitSwimDepthRatio) * (configData.modelHeight or 0)

		self.eModel:UpdateGlideParameter(Const.COMPONENT_MOTION, SysConfigData.glideSpeedLevels[2], SysConfigData.glideMaxYVelocity)
	end
end

function ClientMotionComponent:resetControlledMotionProp(configData)
	if self:hasEModelComponent(Const.COMPONENT_MOTION) then
		configData = configData or self:getConfigData()
		self.eModel.edgeBlocking = false
		self.eModel.stepHeightUp = self.getStepHeightUp and self:getStepHeightUp() or configData.stepHeightUp or 0
		self.eModel.stepHeightDown = configData.stepHeightDown or 0
	end
end

function ClientMotionComponent:applyCharacterControllerProp(configData)
	if self:hasEModelComponent(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER) then
		local idleSpecialProb = SysConfigData.defaultIdleSpecialProbConnectMode

		if pg.me == self then
			configData = configData or self:getConfigData()
			idleSpecialProb = configData.idleSpecialProb or SysConfigData.defaultIdleSpecialProb
		end

		self.eModel:SetSpecialAnimProb(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, idleSpecialProb, SysConfigData.defaultSpAnimProb)
	end
end

function ClientMotionComponent:setOverrideSteeringTime(v)
	local eModel = self.eModel

	if not eModel then
		return
	end

	return eModel:SetOverrideSteering(Const.COMPONENT_MOTION, v) or false
end

function ClientMotionComponent:setSteering(steeringTime, deceleration, respondInput)
	local eModel = self.eModel

	if not eModel then
		return false
	end

	if not self:hasEModelComponent(Const.COMPONENT_MOTION) then
		return false
	end

	self.eModel:SetSteering(Const.COMPONENT_MOTION, steeringTime, deceleration, respondInput)

	return true
end

function ClientMotionComponent:getDrownedEnterWaterDepth()
	local configData = self:getConfigData()

	return configData.modelHeight * SysConfigData.struggleDepthRatioInWater
end

function ClientMotionComponent:EVENT_AbilityStateChange(value, abilityId)
	self:onAbilitySTChanged(value)
end

function ClientMotionComponent:refreshStepHeight()
	if pg.pawn == self and self.eModel then
		local isEnableEdgeBlocking = self:isAbilityEdgeBlocking()

		self.eModel.edgeBlocking = isEnableEdgeBlocking

		local stepHeightUp, stepHeightDown

		if isEnableEdgeBlocking and not self:WALKING_ATTACK_ST() then
			stepHeightUp = SysConfigData.stepHeightUpInSkill
			stepHeightDown = SysConfigData.stepHeightDownInSkill
		else
			local configData = self:getConfigData()

			stepHeightUp = self.getStepHeightUp and self:getStepHeightUp() or configData.stepHeightUp
			stepHeightDown = configData.stepHeightDown or 0
		end

		stepHeightUp = self.getStepHeightUp and self:getStepHeightUp() or stepHeightUp or 0

		if self:SPEED_BURST_ST() then
			stepHeightUp = math.max(SysConfigData.minStepHeightUpInSpeedBurst or 0, stepHeightUp or 0)
			stepHeightDown = math.max(SysConfigData.minStepHeightDownInSpeedBurst or 0, stepHeightDown or 0)
		elseif self:SKATEBOARD_ST() then
			stepHeightUp = SysConfigData.stepHeightUpInSkateboard
			stepHeightDown = SysConfigData.stepHeightDownInSkateboard
		elseif self:CARRY_EGG_ST() then
			stepHeightUp = SysConfigData.stepHeightUpInBEgg
			stepHeightDown = SysConfigData.stepHeightDownInBEgg
		elseif self:FALLEN_ST() then
			stepHeightUp = SysConfigData.stepHeightUpInDBNO or 0
			stepHeightDown = SysConfigData.stepHeightDownInDBNO or 0
		end

		self.eModel.stepHeightUp = stepHeightUp or 0
		self.eModel.stepHeightDown = stepHeightDown or 0
	end
end

function ClientMotionComponent:refreshSteeringTime()
	if pg.pawn == self and self.eModel then
		local steeringTime

		if self.characterState == CharacterStateConst.FALLENFALL then
			steeringTime = SysConfigData.turnMaxTimeInAirDBNO
		elseif self:FALLEN_ST() then
			steeringTime = SysConfigData.turnMaxTimeInDBNO
		end

		if steeringTime == nil then
			steeringTime = self.eModel.steeringTimeDefault
		end

		self.eModel:SetSteering(Const.COMPONENT_MOTION, steeringTime)
	end
end

function ClientMotionComponent:onAbilitySTChanged(value)
	self:refreshStepHeight()

	if self.eModel then
		self.eModel.inSkill = value
	end
end

function ClientMotionComponent:onKCCMove(velocity)
	self.isMoving = velocity > 0

	if self.inWater then
		if velocity > 0 and self:inWaterSplshFrame() then
			return
		end

		if not self.hitWater and self.eModel.IsOnGround then
			self.hitWater = true

			self:playMotionSplashAction("IntoWater", self.eModel.waterDepth, 4)
		end
	end

	local func = self.DC_OnKCCMove

	if func then
		func(self, velocity)
	end
end

function ClientMotionComponent:inWaterSplshFrame()
	if not self.waitWaterSplashFrame then
		return false
	end

	if self.waitWaterSplashFrame > 0 then
		self.waitWaterSplashFrame = self.waitWaterSplashFrame - 1

		return true
	end

	return false
end

function ClientMotionComponent:onWaterDepthChanged(depth)
	local hitPlayed = false

	if self.hitWater then
		if depth < 0 and not self.eModel.IsOnGround then
			self.hitWater = false

			local v

			if CharacterStateConst.isJumpState(self.characterState) then
				v = depth < SysConfigData.waterCollideDepth and 3.01 or 8.01
			end

			hitPlayed = self:playMotionSplashAction("OutOfWater", depth, v)
		end
	elseif depth > 0.06 then
		self.hitWater = true
		hitPlayed = self:playMotionSplashAction("IntoWater", depth)
	end
end

function ClientMotionComponent:playMotionSplashAction(action, depth, velocity)
	local sizeName = self.sizeLevelName2
	local collideData = WaterCollideData[action][self.sizeLevelName2]

	if not collideData then
		return false
	end

	velocity = velocity or self.eModel.Velocity.y

	if velocity == 0 then
		velocity = self.eModel.LastTargetVelocity.y
	end

	if velocity < 0 then
		velocity = -velocity
	end

	for name, data in pairs(collideData) do
		local speedRange = data.speedRange

		if velocity > speedRange[1] and velocity <= speedRange[2] then
			self:playSoundEvent(data.sfxRes)

			self.waitWaterSplashFrame = Wait_Water_Splash_Frame

			local px, py, pz = self.eModel:GetPositionAgentPosEx()
			local pos = Vector3.New(px, py + depth, pz)

			self:playEffect(data.effectRes, {
				position = pos
			})

			return true
		end
	end

	return false
end

function ClientMotionComponent:fly()
	AnimationUtils.playAnimationState(self, CharacterStateConst.FLYRISE)
	self:initNorAtkAbilityList(true)
end

function ClientMotionComponent:stopFly()
	if not self:FLY_ST() then
		return
	end

	AnimationUtils.playAnimationState(self, CharacterStateConst.FALL)
	self:initNorAtkAbilityList(false)
end

function ClientMotionComponent:onEnterFly()
	pg.global.ui.hudV2:refreshFlyState()
end

function ClientMotionComponent:onExitFly()
	pg.me:updateStaminaMoveDirectionRate(0, 0)
	pg.global.ui.hudV2:refreshFlyState()
end

function ClientMotionComponent:onEnterGlide()
	pg.global.ui.hudV2:refreshFlyState()
end

function ClientMotionComponent:onExitGlide()
	pg.global.ui.hudV2:refreshFlyState()
end

function ClientMotionComponent:onEnterFloat()
	pg.global.ui.hudV2:refreshFlyState()
end

function ClientMotionComponent:onExitFloat()
	pg.global.ui.hudV2:refreshFlyState()
	self:setExitFloatInputCommand()
end

function ClientMotionComponent:setExitFloatInputCommand()
	self:endStraightUp()
	self:endStraightDown()
end

function ClientMotionComponent:beginStraightUp()
	self.eModel:SetInputCommand(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, InputCommand.StraightUp, true, 1)
end

function ClientMotionComponent:endStraightUp()
	self.eModel:SetInputCommand(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, InputCommand.StraightUp, false)
end

function ClientMotionComponent:beginStraightDown()
	self.eModel:SetInputCommand(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, InputCommand.StraightDown, true, 1)
end

function ClientMotionComponent:endStraightDown()
	self.eModel:SetInputCommand(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, InputCommand.StraightDown, false)
end

function ClientMotionComponent:glideRise()
	self.eModel:SetInputCommand(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, InputCommand.GlideRise)
end

function ClientMotionComponent:stopGlide()
	self.eModel:SetInputCommand(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, InputCommand.StopFly)
end

function ClientMotionComponent:setInputCommandDigEgg()
	self.eModel:SetInputCommand(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, InputCommand.DigEgg)
end

function ClientMotionComponent:burrow()
	local burrowActionData = self:getEntityCacheVal(AbilityConst.COMBAT_EVENT_ON_BURROW_STATE_CHANGE)
	local burrowInAnimName = burrowActionData and burrowActionData.burrowInAnim

	AnimationUtils.playAnimationState(self, CharacterStateConst.SNEAKIN, burrowInAnimName and PlayableConst[burrowInAnimName])

	if self.isMainPet and self.isInControl then
		pg.game.camera.playerCameraMode:enableSneakCameraMode(true)
	end
end

function ClientMotionComponent:onSneakInStart()
	self:setVisible(ClientConst.MODEL_VISIBLE_KEY.SAND_UNDERGROUND, true, true, true)
end

function ClientMotionComponent:canStopBurrow(abilityId)
	local impulseThreshold = 0

	if abilityId then
		local abilityData = pg.global.abilityMgr:getAbilityTemplate(abilityId)
		local timelineId = abilityData.stopBurrowTimelineId
		local timelineData = timelineId and pg.global.abilityMgr:getTimelineTemplate(timelineId)

		if abilityData.stopBurrowActOnTgtNodeId and timelineData then
			local actionData = timelineData.nodeMap and timelineData.nodeMap[abilityData.stopBurrowActOnTgtNodeId]

			if actionData then
				impulseThreshold = ClientAbilityUtils.getImpulse(abilityId, actionData.impulseId) or 0
			end
		end
	end

	local defaultRadius, defaultHeight = self:getPhysxDataByState(CharacterStateConst.IDLE)
	local canStop = false

	if defaultRadius and defaultHeight then
		local capsuleScale = self.getCapsuleScale and self:getCapsuleScale() or 1

		self:refreshPhysxData(CharacterStateConst.IDLE)
		self:refreshCapsuleScale(capsuleScale, CharacterStateConst.IDLE)

		canStop = self.eModel:CheckAllOverlapReachImpulseThreshold(Const.COMPONENT_MOTION, self:getPositionAgentPosition(), self:getPositionAgentRotation(), impulseThreshold, false)

		self:refreshPhysxData(CharacterStateConst.SNEAK)
		self:refreshCapsuleScale(capsuleScale, CharacterStateConst.SNEAK)
	else
		canStop = self.eModel:CheckAllOverlapReachImpulseThreshold(Const.COMPONENT_MOTION, self:getPositionAgentPosition(), self:getPositionAgentRotation(), impulseThreshold, true)
	end

	if not canStop then
		pg.global.showBubbleMessageById(NoticeDef.CANNOT_STOP_BURROW_AT_CUR_POS)

		return false
	end

	return true
end

function ClientMotionComponent:stopBurrow(ignoreCheck)
	if self.isMainPet then
		if not ignoreCheck and not self:canStopBurrow() then
			return
		end

		pg.game.camera.playerCameraMode:enableSneakCameraMode(false)
	end

	local sneakIn = self.characterState == CharacterStateConst.SNEAKIN
	local isBurrow = self:BURROW_ST() or sneakIn

	if isBurrow then
		local burrowActionData = self:getEntityCacheVal(AbilityConst.COMBAT_EVENT_ON_BURROW_STATE_CHANGE)
		local burrowOutAnimName = burrowActionData and burrowActionData.burrowOutAnim

		AnimationUtils.playAnimationState(self, CharacterStateConst.SNEAKOUT, burrowOutAnimName and PlayableConst[burrowOutAnimName])
		self:refreshFootPrintVisible()
	end
end

function ClientMotionComponent:stopBurrowByHit()
	if not self:BURROW_ST() and self.characterState ~= CharacterStateConst.SNEAKIN then
		return
	end

	if self:ABILITY_ST() then
		self:cancelAbility()
	end

	if self.isMainPet then
		pg.game.camera.playerCameraMode:enableSneakCameraMode(false)
	end

	AnimationUtils.forceChangeState(self, CharacterStateConst.SNEAKOUTBYHIT)
	self:refreshFootPrintVisible()
end

function ClientMotionComponent:onSneakOutEnd()
	self:setVisible(ClientConst.MODEL_VISIBLE_KEY.SAND_UNDERGROUND, true, true, false)
end

function ClientMotionComponent:takeRoot()
	AnimationUtils.playAnimationState(self, CharacterStateConst.TAKEROOTIN)
end

function ClientMotionComponent:stopTakeRoot()
	if not self:TAKE_ROOT_ST() and not self:TAKE_ROOT_IN_ST() then
		return
	end

	AnimationUtils.forceChangeState(self, CharacterStateConst.TAKEROOTOUT)
end

function ClientMotionComponent:ResetVelocity()
	if self.eModel ~= nil then
		self.eModel:ResetVelocity(Const.COMPONENT_MOTION)
	end
end

function ClientMotionComponent:isMotionDisable()
	return not Utils.tableIsEmptyOrNil(self.disableMotionDict)
end

function ClientMotionComponent:hasGameplayShadow()
	if not self.isMainPlayer and not self.isMainPet then
		return false
	end

	return not Utils.isSelfInSpaceTown()
end

function ClientMotionComponent:refreshHeightLimit()
	if self.space then
		self.eModel.heightLimit = self:csRequireSpaceData("heightLimit") or 0
	end
end

function ClientMotionComponent:disableMotion(key, isDisable, clearCache)
	if isDisable then
		if clearCache and self == pg.pawn then
			pg.game.controller:onHandleMove(0, 0, 0)
		end

		self.disableMotionDict[key] = true
	else
		self.disableMotionDict[key] = nil
	end
end

function ClientMotionComponent:disableMotionByAnim(animKey)
	self.disableMotionByAnimDict[animKey] = true
end

function ClientMotionComponent:checkIsMotionDisableByAnim()
	for key, active in pairs(self.disableMotionByAnimDict) do
		if ToBool(active) then
			if self.eModel:IsAnimationPlaying(Const.COMPONENT_IDX_PLAYABLE, AnimationUtils.getID(key)) then
				return true
			else
				self.disableMotionByAnimDict[key] = nil
			end
		end
	end

	return false
end

function ClientMotionComponent:faceToEnt(targetEnt, instant)
	if targetEnt then
		local direction = targetEnt:getPosition() - self:getPosition()

		direction.y = 0

		if self.eModel ~= nil then
			self.eModel:SetDirection(Const.COMPONENT_MOTION, direction, instant or false)
		end
	end
end

function ClientMotionComponent:getSpeedBurstDuration()
	return self.speedBurstData.duration
end

function ClientMotionComponent:refreshVisualSizeName()
	if self:hasEModelComponent(Const.COMPONENT_MOTION) then
		local causeSplashSize = self:getConfigData().visualSize or self.eModel.SquareSize

		for name, range in pairs(SysConfigData.sizeLevelTableBy2) do
			if causeSplashSize >= range[1] and causeSplashSize < range[2] then
				self.sizeLevelName2 = name
			end
		end

		for name, range in pairs(SysConfigData.sizeLevelTableBy3) do
			if causeSplashSize >= range[1] and causeSplashSize < range[2] then
				self.sizeLevelName3 = name
			end
		end
	end
end

function ClientMotionComponent:isHighJump()
	return self.highJumpInfo ~= nil
end

function ClientMotionComponent:getHighJumpInfo(highJumpInfo)
	highJumpInfo.enableSteeringTime = self.highJumpInfo.enableSteeringTime
	highJumpInfo.maxVelocity = self.highJumpInfo.maxVelocity
	highJumpInfo.acceleration = self.highJumpInfo.acceleration
end

function ClientMotionComponent:onExitHighJump()
	self.highJumpInfo = nil
end

function ClientMotionComponent:EVENT_OnLifeDead()
	if self:hasEModelComponent(Const.COMPONENT_MOTION) then
		local forward = self.eModel.TargetRotation * Vector3.forward

		forward.y = 0

		EModelUtils.setMotionRotation(self, Quaternion.LookRotation(forward.normalized), true)
	end
end

function ClientMotionComponent:EVENT_BeControlled()
	self:refreshVisualSizeName()

	if self:hasEModelComponent(Const.COMPONENT_MOTION) then
		function self.eModel.onWaterDepthChanged(depth)
			self:onWaterDepthChanged(depth)
		end

		function self.eModel.onKCCMoved(velocity)
			self:onKCCMove(velocity)
		end
	end
end

function ClientMotionComponent:EVENT_LoseControlled()
	if self.eModel == nil then
		return
	end

	self:setExitFloatInputCommand()
end

function ClientMotionComponent:EVENT_OnCharacterStateChange(oldState, newState)
	if oldState == CharacterStateConst.SNEAKOUTBYHIT or oldState == CharacterStateConst.SNEAKOUT then
		self:onSneakOutEnd()
		self:refreshPhysxData(newState)

		local scale = self.getCapsuleScale and self:getCapsuleScale() or 1

		self:refreshCapsuleScale(scale, newState)
	end

	if newState == CharacterStateConst.SNEAKIN then
		self:onSneakInStart()
		self:refreshPhysxData(newState)

		local scale = self.getCapsuleScale and self:getCapsuleScale() or 1

		self:refreshCapsuleScale(scale, newState)
	end

	if newState == CharacterStateConst.BEGGPICK or CharacterStateConst.isChildOfState(oldState, CharacterStateConst.BEGG) then
		self:refreshStepHeight()
	end

	if CharacterStateConst.isChildOfState(oldState, CharacterStateConst.FALLEN) or CharacterStateConst.isChildOfState(newState, CharacterStateConst.FALLEN) then
		self:refreshStepHeight()
		self:refreshSteeringTime()
	end
end

function ClientMotionComponent:EVENT_BeStick()
	self.eModel:SetComputeGravity(Const.COMPONENT_MOTION, ClientConst.GravityMask.BeStick, false)
end

function ClientMotionComponent:EVENT_BeUnStick()
	self.eModel:ClearGravityMask(Const.COMPONENT_MOTION, ClientConst.GravityMask.BeStick)
end

function ClientMotionComponent:EVENT_OnEntityBeAttached()
	self.eModel:SetComputeGravity(Const.COMPONENT_MOTION, ClientConst.GravityMask.BeStick, false)
end

function ClientMotionComponent:EVENT_OnEntityBeDetached()
	self.eModel:ClearGravityMask(Const.COMPONENT_MOTION, ClientConst.GravityMask.BeStick)
end

function ClientMotionComponent:initDisableWeightPushConfig()
	local cfg = self:getConfigData()

	if cfg.canNotPush then
		self.eModel.isDisableWeightPush = true
	end

	local ignoreEntityPush = cfg.ignoreEntityPush and true or false

	if self.isDummyClone then
		ignoreEntityPush = true
	end

	self.eModel:SetIgnoreEntityPush(Const.COMPONENT_MOTION, ignoreEntityPush)
end

function ClientMotionComponent:onEnterSpace()
	if self:hasEModelComponent(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER) then
		self:refreshHeightLimit()
	end
end

function ClientMotionComponent:onAIStartAgent()
	AIControllerUtils.setSteeringDeceleration(self, false, AiConst.DecelerationDisableReason.AIDefault)
end

function ClientMotionComponent:onAIResumeAgent()
	AIControllerUtils.setSteeringDeceleration(self, false, AiConst.DecelerationDisableReason.AIDefault)
end

function ClientMotionComponent:onAIPauseAgent()
	AIControllerUtils.setSteeringDeceleration(self, true, AiConst.DecelerationDisableReason.AIDefault)
end

function ClientMotionComponent:preDestroy()
	if self.eModel ~= nil then
		self.eModel.onWaterDepthChanged = nil
		self.eModel.onKCCMoved = nil

		self.eModel:SetKccEnableEx(false, Const.KccDisableReason.SceneLoading)
	end
end

return ClientMotionComponent
