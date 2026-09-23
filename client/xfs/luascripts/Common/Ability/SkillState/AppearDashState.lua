-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Ability\\SkillState\\AppearDashState.lua

local Class = require("Core.Framework.Class")
local SkillState = require("Common.Ability.SkillState.SkillState")
local Const = require("Common.Const.Const")
local AbilitySettingGlobalConstData = require("Data.ability_setting_global_const_data")
local AbilityConst = require("Common.Const.AbilityConst")
local PetData = require("Data.pet_data")
local AnimationUtils = require("Common.Utils.AnimationUtils")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local PlayableConst = require("Common.Const.PlayableConst")
local AiConst = require("Common.Const.AiConst")
local Vector3 = Vector3
local NotNil = NotNil
local AppearDashState = Class.LiteClass("AppearDashState", SkillState)
local MOVE_PHASE_NONE
local ACCELERATE_PHASE = 0
local NORMAL_PHASE = 1
local DECELERATE_PHASE = 2
local BLEND_SHAPE_NAME = "Intermediate"

function AppearDashState:enter(abilityId, oldTemplateId, exitCallback, targetPos)
	SkillState.enter(self)
	self:clearDisplacementVelocitySource(Const.DisplacementVelocitySource.AppearDash)

	self.oldTemplateId = oldTemplateId
	self.exitCallback = exitCallback

	self.owner.logger:info("AppearDashState:enter")

	if self.owner.pauseBt then
		self.owner:pauseBt(AiConst.PauseBtReason.AppearDash)
	end

	self.isBlendIn = true

	if self.owner.authority == Const.AUTHORITY_MASTER then
		local masterEntity = self.owner:getMasterEntity()

		if Utils.checkClient() then
			local ClientConst = require("Const.ClientConst")

			self.owner:disableMotion(ClientConst.DISABLE_MOTION_KEY.SKILL_MOVE, true)
		end

		self.owner.eModel:DisableSteering(Const.COMPONENT_MOTION)

		local targetToSelfDir = masterEntity.lastPetPosition - targetPos

		targetToSelfDir.y = 0

		Vector3.SetNormalize(targetToSelfDir)

		self.desirePos = Vector3.Clone(targetPos)

		local moveDir = self.desirePos - masterEntity.lastPetPosition

		moveDir.y = 0

		local moveDis = Vector3.Magnitude(moveDir)

		self.moveDir = Vector3.SetNormalize(moveDir)

		self:openKccFullSimulation()

		self.phase = MOVE_PHASE_NONE
		self.velocity = 0
		self.startTime = self.owner:getGameTime()
		self.decelerationDis = 0.5 * AbilitySettingGlobalConstData.appearDashDesireSpeed * (AbilitySettingGlobalConstData.appearDashDesireSpeed / AbilitySettingGlobalConstData.appearDashAcceleration)
		self.startPos = Vector3.Clone(masterEntity.lastPetPosition)
		self.firstEnter = true
		self.abilityId = abilityId
		self.totalOffset = moveDis
		self.startTime = self.owner:getGameTime()
		self.phase = ACCELERATE_PHASE
	end

	self.owner:deformTo(PetData[oldTemplateId], {
		modelRefreshCallback = function()
			return
		end
	})
	self.owner:playEffect(AbilitySettingGlobalConstData.appearDashEff)

	self.owner.eModel.PlayableSpeed = 0

	if Utils.checkClient() then
		local ClientConst = require("Const.ClientConst")

		self.owner:setVisible(ClientConst.MODEL_VISIBLE_KEY.APPEAR_DASH, false)
	end
end

function AppearDashState:checkEndPhase()
	if self.phase == DECELERATE_PHASE then
		return
	end

	local now = self.owner:getGameTime()

	if now - self.startTime > AbilitySettingGlobalConstData.appearDashMaxTime then
		self.owner.logger:debug("AppearDashState, over max time, enter decelerate state")

		self.phase = DECELERATE_PHASE

		return
	end

	local px, py, pz = self.owner.eModel:GetPositionAgentPosEx()

	Vector3.enableCreateFromCache()

	local dis = Vector3.Magnitude(Vector3.New(self.desirePos.x - px, 0, self.desirePos.z - pz))

	Vector3.disableCreateFromCache()

	local stopTime = self.velocity / AbilitySettingGlobalConstData.appearDashAcceleration
	local stopDis = self.velocity * 0.5 * stopTime

	if dis < stopDis then
		self.phase = DECELERATE_PHASE
		self.deceleration = self.velocity * self.velocity / (2 * dis)

		self.owner.logger:debug("AppearDashState, goto decelerate phase, dis %f, stopDis %f, deceleration %f", dis, stopDis, self.deceleration)

		return
	end
end

function AppearDashState:tick(deltaSeconds)
	self.owner.eModel.PlayableSpeed = 0

	local blendWeight = 100

	self.owner.eModel.modelShaderView:SetMorphEnable(true)

	local px, py, pz = self.owner.eModel:GetPositionAgentPosEx()

	Vector3.enableCreateFromCache()

	local deltaLen = Vector3.Magnitude(Vector3.New(px - self.startPos.x, 0, pz - self.startPos.z))

	Vector3.disableCreateFromCache()

	if self.isBlendIn then
		if deltaLen > self.totalOffset / 2 then
			self.isBlendIn = false
			blendWeight = 100

			self.owner:deformTo(nil, {
				modelRefreshCallback = function()
					return
				end
			})
		else
			local percent = deltaLen / (self.totalOffset / 2)

			percent = math.clamp(percent, 0, 1)
			blendWeight = percent * 100
		end
	else
		local percent = (deltaLen - self.totalOffset / 2) / (self.totalOffset / 2)

		percent = math.clamp(percent, 0, 1)
		blendWeight = (1 - percent) * 100
		blendWeight = math.clamp(blendWeight, 0, 100)
	end

	self.owner.eModel.modelModelView:SetBlendShapeWeight(BLEND_SHAPE_NAME, blendWeight)

	if self.owner.authority == Const.AUTHORITY_MASTER then
		if self.phase == MOVE_PHASE_NONE then
			return
		end

		if self.firstEnter == false and self.velocity <= 0 then
			self.owner.skillStateMgr:switchState(AbilityConst.SKILL_STATE_NONE)

			return
		end

		self.firstEnter = false

		self:checkEndPhase()

		local oldVelocity = self.velocity

		if self.phase == ACCELERATE_PHASE then
			self.velocity = self.velocity + AbilitySettingGlobalConstData.appearDashAcceleration * deltaSeconds

			if self.velocity > AbilitySettingGlobalConstData.appearDashDesireSpeed then
				self.velocity = AbilitySettingGlobalConstData.appearDashDesireSpeed
				self.phase = NORMAL_PHASE

				self.owner.logger:debug("AppearDashState, set normal phase")
			end
		elseif self.phase == DECELERATE_PHASE then
			local deceleration = self.deceleration or AbilitySettingGlobalConstData.appearDashAcceleration

			self.velocity = self.velocity - deceleration * deltaSeconds

			if self.velocity < 0 then
				self.velocity = 0
			end
		end

		px, py, pz = self.owner.eModel:GetPositionAgentPosEx()

		Vector3.enableCreateFromCache()

		local selfToTarget = Vector3.New(self.desirePos.x - px, self.desirePos.y - py, self.desirePos.z - pz)

		if Vector3.Dot(selfToTarget, self.moveDir) < 0 then
			self.owner.logger:debug("AppearDashState, over desirePos, selfToTarget", inspect(selfToTarget))

			self.velocity = 0
		end

		Vector3.disableCreateFromCache()

		local aveVelocity = (self.velocity + oldVelocity) * 0.5
		local offset = self.moveDir * (deltaSeconds * aveVelocity)

		self:setDisplacementVelocitySource(Const.DisplacementVelocitySource.AppearDash, offset, deltaSeconds, true)
	end
end

function AppearDashState:leave()
	self:clearDisplacementVelocitySource(Const.DisplacementVelocitySource.AppearDash)
	self:restoreKccFullSimulation()

	if self.owner.authority == Const.AUTHORITY_MASTER then
		AnimationUtils.playAnimationState(self.owner, CharacterStateConst.IDLE)

		if Utils.checkClient() then
			local ClientConst = require("Const.ClientConst")

			self.owner:disableMotion(ClientConst.DISABLE_MOTION_KEY.SKILL_MOVE, false)
		end

		self.owner.eModel:DefaultSteeringMode(Const.COMPONENT_MOTION)

		self.owner.eModel.PlayableSpeed = 1

		self.owner:serverMsgNoGC("RPC_CS_LeaveAppearDash")
	end

	if self.exitCallback then
		self.exitCallback()
	end

	SkillState.leave(self)

	if self.owner.resumeBt then
		self.owner:resumeBt(AiConst.PauseBtReason.AppearDash)
	end

	if self.virtualEntity then
		if Utils.checkClient() then
			local ClientUtils = require("Utils.ClientUtils")

			ClientUtils.safeDestroy(self.virtualEntity)
		else
			self.virtualEntity:destroy()
		end
	end

	self.owner.eModel.modelModelView:SetBlendShapeWeight(BLEND_SHAPE_NAME, 0)
	self.owner:deformTo()
	self.owner.eModel.modelModelView:SetBlendShapeWeight(BLEND_SHAPE_NAME, 0)

	self.owner.showPetExtraData = nil

	self.owner:stopEffect(AbilitySettingGlobalConstData.appearDashEff)
	self.owner.eModel.modelShaderView:SetMorphEnable(false)

	if Utils.checkClient() then
		local ClientConst = require("Const.ClientConst")

		self.owner:setVisible(ClientConst.MODEL_VISIBLE_KEY.APPEAR_DASH, true)
	end

	local dissolveAppearTime = 1.2

	self.owner:playSwitchAppearEffect(dissolveAppearTime)
end

return AppearDashState
