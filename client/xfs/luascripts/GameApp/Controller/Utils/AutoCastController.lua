-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Controller\\Utils\\AutoCastController.lua

local Class = require("Core.Framework.Class")
local Lume = require("Core.Common.lume")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local ConflictTypes = require("Common.ConflictTypes")
local AbilityConst = require("Common.Const.AbilityConst")
local Utils = require("Common.Utils.Utils")
local AbilitySettingGlobalConstData = require("Data.ability_setting_global_const_data")
local Const = require("Common.Const.Const")
local ToBool = ToBool
local pg = pg
local Vector3 = Vector3
local Quaternion = Quaternion
local AutoCastController = Class.LiteClass("AutoCastController")

function AutoCastController:ctor()
	self.owner = nil
	self.autoCastInfo = {}
end

function AutoCastController:setOwner(owner)
	self.owner = owner
	self.isAutoCast = false

	self:cancel()
end

function AutoCastController:checkAutoCast(abilityId, extraInfo)
	Lume.clear(self.autoCastInfo)

	local actorId = pg.me.lockedActorId
	local targetEnt = pg.getEntityByActorId(actorId)

	if not ToBool(targetEnt) then
		return false
	end

	if not pg.game.setting:getAutoCast() then
		return false
	end

	if not Utils.isPuppet(targetEnt) and not Utils.isPlayerPet(targetEnt) and not Utils.isCreation(targetEnt) then
		return false
	end

	local abilityTemplate = pg.global.abilityMgr:getAbilityTemplate(abilityId)

	if abilityTemplate.abilityType ~= AbilityConst.EnumAbilityType.Skill then
		return
	end

	local autoCastDis

	if abilityTemplate.autoCastDisByLockDis then
		autoCastDis = AbilitySettingGlobalConstData.forceLockDis
	elseif abilityTemplate.overrideAutoCastDis then
		autoCastDis = (abilityTemplate.overrideAutoCastDis or 0) + (targetEnt.bodySize or 0)
	end

	if autoCastDis and autoCastDis > 0 then
		local horDisSqr = Vector3.HoriSqrDistance(targetEnt:getPosition(), self.owner:getPosition())

		if horDisSqr > autoCastDis * autoCastDis and self.owner:checkStatus(ConflictTypes.CT_AUTO_CAST) then
			self.autoCastInfo.extraInfo = extraInfo or {}
			self.autoCastInfo.autoCastDis = autoCastDis
			self.autoCastInfo.abilityId = abilityId
			self.autoCastInfo.isStartDash = false
			self.autoCastInfo.canCancelTime = self.owner:getGameTime() + (AbilitySettingGlobalConstData.autoCastCancelTime or 1)
			self.autoCastInfo.targetActorId = targetEnt.actorId

			return true
		end
	end

	return false
end

function AutoCastController:updateChaseActorId(abilityId, extraInfo)
	local targetEnt = pg.getEntityByActorId(pg.game.controller.lockHelper.forceLockActorId)

	if not ToBool(targetEnt) then
		return extraInfo
	end

	local abilityTemplate = pg.global.abilityMgr:getAbilityTemplate(abilityId)
	local autoCastDis

	if abilityTemplate.autoCastDisByLockDis then
		autoCastDis = AbilitySettingGlobalConstData.forceLockDis
	else
		autoCastDis = abilityTemplate.overrideAutoCastDis
	end

	if (not autoCastDis or autoCastDis > AbilitySettingGlobalConstData.forceLockDis) and self.owner == pg.pawn and AbilityUtils.isRangePet(self.owner) and AbilityUtils.isAttackAbility(abilityId) then
		autoCastDis = AbilitySettingGlobalConstData.forceLockDis
	end

	if autoCastDis and autoCastDis > 0 then
		local horDisSqr = Vector3.HoriSqrDistance(targetEnt:getPosition(), self.owner:getPosition())

		if horDisSqr > autoCastDis * autoCastDis then
			extraInfo = extraInfo or {}
			extraInfo.chaseActorId = targetEnt.actorId
		end
	end

	return extraInfo
end

function AutoCastController:statDash(targetEntity)
	self.owner:turnToTarget(targetEntity.actorId, true)

	self.autoCastInfo.disableCancel = true

	pg.game.controller.curController:onHandleDash(true)

	self.autoCastInfo.disableCancel = false
end

function AutoCastController:update()
	if not next(self.autoCastInfo) then
		return
	end

	local lockedActorId = self.autoCastInfo.targetActorId
	local lockEnt = pg.getEntityByActorId(lockedActorId)

	if not lockEnt or not Utils.checkValidLock(lockEnt) then
		self:cancel()

		return
	end

	local horDisSqr = Vector3.HoriSqrDistance(self.owner:getPosition(), lockEnt:getPosition())

	if horDisSqr < self.autoCastInfo.autoCastDis * self.autoCastInfo.autoCastDis then
		local abilityId = self.autoCastInfo.abilityId
		local extraInfo = self.autoCastInfo.extraInfo

		extraInfo.targetActorId = self.autoCastInfo.targetActorId
		extraInfo.fromAutoCast = true
		self.autoCastInfo.disableCancel = true

		local result, reason

		result, reason = pg.game.controller:useSkill(abilityId, nil, true, extraInfo)
		self.autoCastInfo.disableCancel = nil

		if result then
			self:cancel()
		end

		return
	else
		if not self.autoCastInfo.isStartDash then
			self:statDash(lockEnt)

			self.autoCastInfo.isStartDash = true
		end

		local dir = lockEnt:getPosition() - self.owner:getPosition()

		dir.y = 0

		Vector3.SetNormalize(dir)

		local cameraRotX, cameraRotY, cameraRotZ, cameraRotW = pg.global.cameraMgr:GetWorldCameraRotationEx()
		local lockDir = Quaternion.MulVec3(Quaternion.GetQuaternionInverse(cameraRotX, cameraRotY, cameraRotZ, cameraRotW), dir)

		self.autoCastInfo.disableCancel = true

		self.owner.eModel:OnHandleMove(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, lockDir.x, lockDir.z, 0)

		self.autoCastInfo.disableCancel = false
	end
end

function AutoCastController:cancel()
	if next(self.autoCastInfo) and not self.autoCastInfo.disableCancel then
		self.autoCastInfo.disableCancel = true

		pg.game.controller.curController:onHandleDash(false)

		self.autoCastInfo.disableCancel = false

		Lume.clear(self.autoCastInfo)
	end
end

return AutoCastController
