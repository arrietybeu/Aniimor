-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Ability\\SkillState\\KnockUpState.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local SkillState = require("Common.Ability.SkillState.SkillState")
local CombatLogger = require("Common.Ability.CombatLogger")
local PlayableConst = require("Common.Const.PlayableConst")
local AbilityConst = require("Common.Const.AbilityConst")
local Const = require("Common.Const.Const")
local PhysicsUtils = require("Common.Utils.PhysicsUtils")
local VoxelUtils = require("Common.Utils.VoxelUtils")
local Utils = require("Common.Utils.Utils")
local AiConst = require("Common.Const.AiConst")
local AbilitySettingGlobalConstData = require("Data.ability_setting_global_const_data")
local ImpulseData = require("Data.impulse_data")
local Vector3 = Vector3
local Quaternion = Quaternion
local NotNil = NotNil
local KnockUpState = Class.LiteClass("KnockUpState", SkillState)

function KnockUpState:ctor(owner)
	SkillState.ctor(self, owner)

	self.playableState = nil

	if self:isAuthorityMaster() and self.owner.knockState ~= AbilityConst.KNOCK_STATE_NONE then
		self:setState(AbilityConst.KNOCK_STATE_NONE)
	end
end

function KnockUpState:enter(impulseH, impulseV, dir, impulseId, airAttackLevel, isRefresh)
	SkillState.enter(self)
	self:clearDisplacementVelocitySource(Const.DisplacementVelocitySource.KnockUp)

	self.state = nil
	self.lastState = nil
	self.accelerateTime = 0

	if not isRefresh then
		if self:isAuthorityMaster() then
			self.owner:cancelAbility()
			self:openKccFullSimulation()
		end

		local observer = self:getObserver()

		self.owner:startListenStunOnCollision(observer, function(tag)
			if self:isAuthorityMaster() then
				if pg.component == "client" then
					self.owner:serverMsgNoGC("RPC_SC_StunOnCollision", tag, 0)
				end

				self.owner.skillStateMgr:switchState(AbilityConst.SKILL_STATE_NONE)
			end
		end)
	end

	self:forceUngrounded(true)

	self.impulseH = impulseH
	self.impulseV = impulseV
	self.dir = dir
	self.owner.airAttackLevel = airAttackLevel

	if self.impulseV == nil or self.dir == nil then
		if self:isAuthorityMaster() then
			self.owner.skillStateMgr:switchState(AbilityConst.SKILL_STATE_NONE)
		end

		return
	end

	self:setKnockDirection(self.dir)
	self:setState(AbilityConst.KNOCK_STATE_UP_START)

	local impulseData = ImpulseData[impulseId]

	if impulseData and impulseData.canBounceOffGround then
		self.canBounceOffGround = true
		self.bounceImpulseH = impulseData.bounceImpulseH
		self.bounceImpulseV = impulseData.bounceImpulseV
		self.isBouncing = false
	else
		self.canBounceOffGround = false
	end

	if not isRefresh then
		self.playableState = nil

		if self:isAuthorityMaster() and self.owner.pauseBt then
			self.owner:pauseBt(AiConst.PauseBtReason.KnockUp)
		end
	end
end

function KnockUpState:refresh(impulseH, impulseV, dir, attackDat, airAttackLevel)
	self:enter(impulseH, impulseV, dir, attackDat, airAttackLevel, true)
end

function KnockUpState:tick(deltaSeconds)
	if self:isAuthorityMaster() and (self.owner:inBreak() or self.owner:isDead() or self:getState() == AbilityConst.KNOCK_STATE_NONE) then
		self.owner.skillStateMgr:switchState(AbilityConst.SKILL_STATE_NONE)
		self.owner.skillStateMgr:checkState()

		return
	end

	SkillState.tick(self, deltaSeconds)
	self:tickPos(deltaSeconds)
	self:tickAnimation()
end

function KnockUpState:tickGroundPos(deltaSeconds)
	if not self.owner:getActionMask(AbilityConst.ACTION_MASK_IN_HIT_BACKSWING) and self.playableState and self.playableState.Key == PlayableConst.HitFlyRecover and self.playableState.Time > AbilitySettingGlobalConstData.HitFlyRecoverToBackSwingTime then
		self.owner:setActionMask(AbilityConst.ACTION_MASK_IN_HIT_BACKSWING, true)
	end

	local oldV = self.impulseH

	self.impulseH = math.max(0, self.impulseH - deltaSeconds * self.decelerate)

	local offset = self.dir * (self.impulseH + oldV) / 2 * deltaSeconds

	if self:isAuthorityMaster() then
		if self.impulseH < 0.1 and self.playableState == nil then
			self:clearDisplacementVelocitySource(Const.DisplacementVelocitySource.KnockUp)
			self:addDisplacementOffset(offset, true)
		else
			self:setDisplacementVelocitySource(Const.DisplacementVelocitySource.KnockUp, offset, deltaSeconds, true)
		end
	end

	if self.impulseH < 0.1 and self.playableState == nil and self:isAuthorityMaster() then
		self.owner.skillStateMgr:switchState(AbilityConst.SKILL_STATE_NONE)
	end
end

function KnockUpState:tickPos(deltaSeconds, accumulatedOffset, totalDeltaSeconds)
	totalDeltaSeconds = totalDeltaSeconds or deltaSeconds

	if self.owner.authority ~= Const.AUTHORITY_MASTER then
		return
	end

	if self:getState() == AbilityConst.KNOCK_STATE_UP_END then
		self:tickGroundPos(deltaSeconds)

		return
	end

	if self.accelerateTime < AbilityConst.KNOCK_ACCELERATE_TIME then
		local accDelta = deltaSeconds
		local overTime

		if self.accelerateTime + deltaSeconds > AbilityConst.KNOCK_ACCELERATE_TIME then
			accDelta = AbilityConst.KNOCK_ACCELERATE_TIME - self.accelerateTime
			overTime = self.accelerateTime + deltaSeconds - AbilityConst.KNOCK_ACCELERATE_TIME
			deltaSeconds = deltaSeconds - accDelta + math.smallNumber
		else
			deltaSeconds = 0
		end

		local aveImpulseH = self.impulseH / AbilityConst.KNOCK_ACCELERATE_TIME * (self.accelerateTime * 2 + accDelta) / 2
		local aveImpulseV = self.impulseV / AbilityConst.KNOCK_ACCELERATE_TIME * (self.accelerateTime * 2 + accDelta) / 2

		if self:isAuthorityMaster() then
			Vector3.enableCreateFromCache()

			local offset = self.dir * aveImpulseH * accDelta + Vector3(0, aveImpulseV * accDelta, 0)

			if accumulatedOffset then
				offset = offset + accumulatedOffset
			end

			local combinedOffset = Vector3.Clone(offset)

			Vector3.disableCreateFromCache()

			accumulatedOffset = combinedOffset
		end

		self.accelerateTime = self.accelerateTime + accDelta

		if overTime ~= nil then
			self:tickPos(overTime, accumulatedOffset, totalDeltaSeconds)
		elseif self:isAuthorityMaster() then
			self:setDisplacementVelocitySource(Const.DisplacementVelocitySource.KnockUp, accumulatedOffset, totalDeltaSeconds, false)
		end

		return
	end

	if deltaSeconds <= 0 then
		return
	end

	local curImpulseV = self.impulseV - AbilitySettingGlobalConstData.gravity * deltaSeconds

	if curImpulseV * self.impulseV < 0 and pg.world.setIsSyncPosThisFrame then
		pg.world.setIsSyncPosThisFrame(self.owner.actorId, true)
	end

	Vector3.enableCreateFromCache()

	local offset = self.dir * self.impulseH * deltaSeconds + Vector3(0, (self.impulseV + curImpulseV) * 0.5 * deltaSeconds, 0)

	if accumulatedOffset then
		offset = offset + accumulatedOffset
	end

	local moveHeight = offset.y

	self:setDisplacementVelocitySource(Const.DisplacementVelocitySource.KnockUp, offset, totalDeltaSeconds, false)
	Vector3.disableCreateFromCache()

	self.impulseV = curImpulseV

	if self.impulseV < 0 then
		local checkGround = self:isGroundDetected(moveHeight)

		if checkGround then
			if self.canBounceOffGround and not self.isBouncing then
				self.isBouncing = true
				self.impulseH = self.bounceImpulseH
				self.impulseV = self.bounceImpulseV
				self.accelerateTime = 0
			else
				if self:isAuthorityMaster() then
					self:forceUngrounded(false)
					self:setState(AbilityConst.KNOCK_STATE_UP_END)
				end

				self.impulseV = 0
				self.startDecelerationTime = self.owner:getGameTime()

				if Utils.isPlayerPet(self.owner) then
					self.decelerate = self.impulseH / AbilitySettingGlobalConstData.petDecelerateTime
				else
					self.decelerate = self.impulseH / AbilitySettingGlobalConstData.puppetDecelerateTime
				end
			end
		end
	end
end

function KnockUpState:tickAnimation()
	if self.owner.skillStateMgr.currentState ~= AbilityConst.SKILL_STATE_KNOCK_UP then
		return
	end

	local newState = self:getState()

	if self.lastState ~= newState then
		if self.playableState then
			self.playableState:RemoveEndCallback()
		end

		if newState == AbilityConst.KNOCK_STATE_UP_START then
			self:playSkillSkateAnimation(PlayableConst.HitFly, false)

			if self.playableState == nil and self.serverAnimState == nil then
				self.owner.skillStateMgr:switchState(AbilityConst.SKILL_STATE_NONE)

				return
			end

			if self:isAuthorityMaster() then
				self:addCurAnimStateEndCallback(function(reason)
					if reason == PlayableConst.END_REASON.PLAYBACK then
						self:setState(AbilityConst.KNOCK_STATE_UP_LOOP)
						self:tickAnimation()
					end
				end)
			end
		elseif newState == AbilityConst.KNOCK_STATE_UP_LOOP then
			self:playSkillSkateAnimation(PlayableConst.HitFlyLoop, true)
		elseif newState == AbilityConst.KNOCK_STATE_UP_END then
			if Utils.isPet(self.owner) then
				self:playSkillSkateAnimation(PlayableConst.HitFlyRecover, false)

				if self.playableState == nil and self.serverAnimState == nil then
					self:playSkillSkateAnimation(PlayableConst.HitFlyToGround, false)
				end
			else
				self:playSkillSkateAnimation(PlayableConst.HitFlyToGround, false)
			end

			if self.owner.authority == Const.AUTHORITY_MASTER then
				if self.playableState or self.serverAnimState then
					self:addCurAnimStateEndCallback(function(reason)
						if self:getState() == AbilityConst.KNOCK_STATE_UP_END then
							self:setState(AbilityConst.KNOCK_STATE_NONE)
						end
					end)
				else
					self:setState(AbilityConst.KNOCK_STATE_NONE)
				end
			end
		end
	end

	self.lastState = newState
end

function KnockUpState:leave()
	self:clearDisplacementVelocitySource(Const.DisplacementVelocitySource.KnockUp)
	SkillState.leave(self)
	self:stopKnockUpAnimation()
	self:setState(AbilityConst.KNOCK_STATE_NONE)
	self:forceUngrounded(false)

	if self.owner.authority == Const.AUTHORITY_MASTER then
		self:restoreKccFullSimulation()
	end

	if self.owner.resumeBt then
		self.owner:resumeBt(AiConst.PauseBtReason.KnockUp)
	end

	self.playableState = nil
	self.airAttackLevel = 0

	self.owner:setActionMask(AbilityConst.ACTION_MASK_IN_HIT_BACKSWING, false)
end

function KnockUpState:getState()
	return self.state or self.owner.knockState
end

function KnockUpState:setState(state)
	if self:isAuthorityMaster() then
		self.state = state
		self.owner.knockState = state

		if self.owner.refreshKnockGroup then
			self.owner:refreshKnockGroup(state)
		end

		if pg.component == "client" then
			self.owner:serverMsgNoGC("RPC_CS_SetKnockState", state)
		end

		if Utils.isPet(self.owner, true) then
			self.owner:updateKnockUpInvincibleState(self.state)
		end

		if pg.world.setIsSyncPosThisFrame then
			pg.world.setIsSyncPosThisFrame(self.owner.actorId, true)
		end
	end
end

function KnockUpState:stopKnockUpAnimation()
	self:stopSkillStateAnimation()

	if Utils.checkClient() then
		self.owner:stopAnimation(PlayableConst.HitFlyLoop)
	end
end

function KnockUpState:isGroundDetected(moveHeight)
	if Utils.checkClient() then
		local succ, groundHeight = PhysicsUtils.getGroundHeight(self.owner:getPosition())
		local eModel = self.owner.eModel
		local checkGround = succ and groundHeight < 0.1

		return checkGround or eModel.isMoveHitGround and math.abs(eModel.LastTargetVelocity.y) < 0.1
	else
		moveHeight = moveHeight < 0 and math.abs(moveHeight) or 0.1

		return moveHeight > VoxelUtils.getGroundHeight(self.owner.space.id, self.owner:getPosition())
	end
end

return KnockUpState
