-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Ability\\MultiTargetsInfo.lua

local Class = require("Core.Framework.Class")
local AbilityConst = require("Common.Const.AbilityConst")
local Utils = require("Common.Utils.Utils")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local CombatLogger = require("Common.Ability.CombatLogger")
local CombatActionTool = require("Common.Ability.CombatActionTool")
local Const = require("Common.Const.Const")
local lume = require("Core.Common.lume")
local ListPool = require("Common.Container.ListPool")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local AoiLodConst = require("Common.Const.AoiLodConst")
local MultiTargetsInfo = Class.LiteClass("MultiTargetsInfo")
local pg = pg
local Vector3 = Vector3
local ToBool = ToBool
local IsNil = IsNil

function MultiTargetsInfo:ctor()
	self.center = AbilityConst.COMBAT_TARGET_TYPE_NONE
	self.rotFrom = AbilityConst.COMBAT_TARGET_TYPE_NONE
	self.rotTo = AbilityConst.COMBAT_TARGET_TYPE_NONE
	self.relation = nil
	self.testFun = nil
	self.testEfFun = nil
	self.maxNum = 0
	self.curNum = 0
	self.maxRange = 0
	self.offsetXYZ = nil
	self.offsetRotation = nil
	self.shapeKind = AbilityConst.LX_GEOMETRY_TYPE_INVALID

	if self.shapeArgs then
		lume.clear(self.shapeArgs)
	else
		self.shapeArgs = {}
	end

	self.yOffset = 0
	self.comboCnt = 0
	self.actionData = nil
	self.ownerEntity = nil
	self.abilityId = nil
	self.conditionTypes = nil
	self.combatContext = nil
	self.centerPos = nil
	self.actionIds = nil
	self.actOnEcsSensorActionIds = nil
	self.closestPlayerList = nil
end

function MultiTargetsInfo:updateHitPosY(entity, combatHitResult)
	if not entity.useHitBox then
		local center = self.centerPos

		if not entity:hasEModelComponent(Const.COMPONENT_IDX_PHYSX) then
			return
		end

		local entMinHeight, entMaxHeight = entity.eModel:GetHeightRange(Const.COMPONENT_IDX_PHYSX)
		local min = math.max(center.y - self.heightDown, entMinHeight)
		local max = math.min(center.y + self.heightUp, entMaxHeight)

		if max <= min then
			CombatLogger.error("wrong heightRange")

			return
		end

		local centerY = center.y + self.yOffset

		if min <= centerY and centerY <= max then
			combatHitResult.hitPos.y = centerY
		elseif centerY < min then
			local rate = math.random()

			combatHitResult.hitPos.y = min + (max - min) * 0.5 * rate
		else
			local rate = math.random()

			combatHitResult.hitPos.y = max - (max - min) * 0.5 * rate
		end
	end
end

function MultiTargetsInfo:actOnPartPreCheckFun(actorId)
	local entity = pg.getEntityByActorId(actorId)

	if not entity then
		return false
	end

	local actionData = self.actionData
	local ownerEntity = self.ownerEntity
	local abilityId = self.abilityId

	if actionData.ignoreOwner and ownerEntity == entity then
		return false
	end

	if actionData.checkCanLock and not Utils.checkValidLock(entity) then
		return false
	end

	if not ownerEntity:checkHitTargetSet(actorId, abilityId, actionData) then
		return false
	end

	if not Utils.checkValidTarget(entity, ownerEntity) then
		return false
	end

	return true
end

function MultiTargetsInfo.preCheckActOnTarget(actionData, ownerEntity, entity, abilityId)
	if actionData.ignoreOwner and ownerEntity == entity then
		return true
	end

	if actionData.checkCanLock and not Utils.checkValidLock(entity) then
		return true
	end

	if not ownerEntity:checkHitTargetSet(entity.actorId, abilityId, actionData) then
		return true
	end

	if not Utils.checkValidTarget(entity, ownerEntity) then
		return true
	end

	return false
end

function MultiTargetsInfo:actOnTargetsOperatorFun(actorId, partIdx, hitPosX, hitPosY, hitPosZ)
	local entity = pg.getEntityByActorId(actorId)
	local isCreation = Utils.isCreation(entity)

	if not entity then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("@jqj entity not found")
		end

		return true
	end

	local actionData = self.actionData
	local ownerEntity = self.ownerEntity
	local abilityId = self.abilityId
	local combatContext = self.combatContext
	local actionIds = self.actionIds
	local isSendHit = false
	local hitEventName

	if ownerEntity.authority == Const.AUTHORITY_AUTONOMOUS_PROXY then
		local closestPlayerList = ListPool.getList(1)

		ownerEntity:entitiesInRangeWithTable(AoiLodConst.default_aoi_range / 100, Const.SEARCH_USR_TYPE_PLAYER, 3, closestPlayerList)

		for i = 1, 3 do
			if closestPlayerList[i] == pg.me.actorId then
				isSendHit = true

				break
			end
		end

		ListPool.returnList(closestPlayerList, 1)
	end

	if MultiTargetsInfo.preCheckActOnTarget(actionData, ownerEntity, entity, abilityId) then
		return true
	end

	if entity.useHitBox and partIdx == nil then
		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			CombatLogger.debug("partIdx is nil")
		end

		return true
	end

	if not Utils.checkRelation(ownerEntity, entity, self.relation) then
		return true
	end

	if ToBool(self.maxNum) and self.curNum >= self.maxNum then
		return true
	end

	local combatHitResult = pg.global.abilityMgr.combatHitResultPool:get(true)

	combatHitResult.hitActorId = actorId
	combatHitResult.hitActorPartIdx = partIdx
	combatHitResult.hitPos = Vector3(hitPosX, hitPosY, hitPosZ)

	ownerEntity:addHitTargetActorId(entity.actorId, abilityId, actionData)

	self.curNum = self.curNum + 1

	local combatHitTargetInfo = pg.global.abilityMgr.runtimeTargetInfoPool:get(true)

	if isCreation then
		combatHitTargetInfo:initTarget(entity.actorId, combatHitResult.hitPos, self.curNum - 1)
	else
		combatHitResult.hitActorId = actorId

		self:updateHitPosY(entity, combatHitResult)
		combatHitTargetInfo:initTarget(actorId, combatHitResult.hitPos, self.curNum - 1, partIdx)
	end

	local guardVal = pg.global.abilityMgr.guardValuePool:getWithCtor(true, combatContext, "runtimeTargetInfo", combatHitTargetInfo)

	if actionIds then
		local isFromDialogueGraph = combatContext.constCasterInfo and combatContext.constCasterInfo.castSource == AbilityConst.CAST_SOURCE.DIALOGUE_GRAPH

		if pg.component == "client" and not isFromDialogueGraph then
			if ownerEntity.authority == Const.AUTHORITY_MASTER then
				ownerEntity:serverMsgNoGC("RPC_CS_DoActOnActorActions", actionData.NodeID, combatContext:getRPCDynamicInfo())
			elseif ownerEntity.authority == Const.AUTHORITY_AUTONOMOUS_PROXY and (entity.authorityId == pg.me.id or isSendHit) then
				hitEventName = hitEventName or AbilityUtils.getHitEventName(combatContext)

				CombatLogger.debug("RPC_CS_NotifyActOnActor", ownerEntity.actorId, combatContext.id, hitEventName)
				pg.me:serverMsgNoGC("RPC_CS_NotifyActOnActor", ownerEntity.actorId, combatContext.id, hitEventName, combatHitTargetInfo)
			end
		end

		pg.global.abilityMgr.combatAction:doActions(actionData, combatContext)
	end

	pg.global.abilityMgr.runtimeTargetInfoPool:returnObject(combatHitTargetInfo)
	guardVal:recover()
	pg.global.abilityMgr.guardValuePool:returnObject(guardVal)

	if pg.component == "client" then
		local ClientSwitch = require("Common.ClientSwitch")

		if ClientSwitch.EnableDrawAbilityGizmo then
			entity:RPC_SC_DrawHitActor(entity:getPosition())
		end
	end

	pg.global.abilityMgr.combatHitResultPool:returnObject(combatHitResult)

	return true
end

function MultiTargetsInfo:actOnEcsSensorOperatorFun(actorId)
	local entity = pg.getEntityByActorId(actorId)

	if not Utils.isEnvObj(entity) then
		return true
	end

	local actionIds = self.actOnEcsSensorActionIds

	if actionIds then
		local actionData = self.actionData
		local ownerEntity = self.ownerEntity
		local combatContext = self.combatContext
		local combatHitResult = pg.global.abilityMgr.combatHitResultPool:get(true)

		combatHitResult.hitActorId = actorId

		local combatHitTargetInfo = pg.global.abilityMgr.runtimeTargetInfoPool:get(true)

		combatHitTargetInfo:initTarget(entity.actorId)

		local guardVal = pg.global.abilityMgr.guardValuePool:getWithCtor(true, combatContext, "runtimeTargetInfo", combatHitTargetInfo)

		pg.global.abilityMgr.combatAction:doActionIds(actionIds, combatContext)
		pg.global.abilityMgr.runtimeTargetInfoPool:returnObject(combatHitTargetInfo)
		guardVal:recover()
		pg.global.abilityMgr.guardValuePool:returnObject(guardVal)
		pg.global.abilityMgr.combatHitResultPool:returnObject(combatHitResult)
	end

	return true
end

return MultiTargetsInfo
