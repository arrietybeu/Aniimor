-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Ability\\CombatActionTool.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local AbilityConst = require("Common.Const.AbilityConst")
local LevelCurve = require("Common.Ability.LevelCurve")
local LevelArray = require("Common.Ability.LevelArray")
local GuardValue = require("Common.Ability.GuardValue")
local Utils = require("Common.Utils.Utils")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local Const = require("Common.Const.Const")
local AttributeConst = require("Common.Const.AttributeConst")
local PetAttributeCalcUtils = require("Common.Utils.PetAttributeCalcUtils")
local ProjectileConst = require("Common.Const.ProjectileConst")
local Lume = require("Core.Common.lume")
local ListPool = require("Common.Container.ListPool")
local EventBus = require("Common.Ability.Buff.EventBus")
local FormulaData = require("Data.formula_data")
local FormulaExplictData = require("Data.formula_explict_data")
local AbilitySettingGlobalConstData = require("Data.ability_setting_global_const_data")
local ReactionBP = require("Common.Data.SkillBPData.tag_reaction_BP")
local ElementPropData = require("Data.element_prop_data")
local CreationData = require("Data.creation_data")
local CombatLogger = require("Common.Ability.CombatLogger")
local PhysicsUtils = require("Common.Utils.PhysicsUtils")
local BuffCalcValueData = require("Data.buff_calc_value_data")
local AbilityCalcValData = require("Data.ability_calc_value_data")
local TimelineCalcValData = require("Data.timeline_calc_value_data")
local ECSConst = require("Const.ECSConst")
local ActorCombatAttribute = require("Common.Ability.Attribute.ActorCombatAttribute")
local Vector3 = Vector3
local Quaternion = Quaternion
local unpack = unpack
local pg = pg
local ToBool = ToBool
local bit = bit
local CombatActionTool = Class.LiteClass("CombatActionTool")

CombatActionTool.INVALID_POS = Vector3(0, -99999, 0)
CombatActionTool.ENABLE_CALC_INFO_BY_LUA_CONFIG = true
CombatActionTool.TEMP_TABLE = {}

function CombatActionTool.parseCurveData(rawData)
	if rawData == nil then
		return nil
	end

	local levelCurve = LevelCurve.new()
	local curveType = type(rawData)

	if curveType == "number" then
		levelCurve:addKey(1, rawData, 0)

		return levelCurve
	elseif curveType == "function" then
		local level = 1

		while level <= AbilityConst.MAX_ABILITY_LEVEL do
			local isOk, result = xpcall(rawData, debug.traceback, level)

			if isOk == false then
				traceback("parseCurveData error" .. tostring(level) .. tostring(rawData))

				return levelCurve
			else
				levelCurve:addKey(level, result, 0)
			end

			level = level + 1
		end

		return levelCurve
	elseif curveType == "table" then
		for key, value in pairs(rawData) do
			local tangent = value[2] ~= nil and value[2] or 0

			levelCurve:addKey(key, value[1], tangent)
		end

		return levelCurve
	else
		traceback("parseCurveData error, not support type" .. tostring(rawData))
	end
end

function CombatActionTool.parseLevelArray(rawData)
	if rawData == nil then
		return nil
	end

	local newCurveArray = LevelArray.new()

	newCurveArray:addKey(1, Utils.deepCopyTable(rawData))

	return newCurveArray
end

function CombatActionTool.parseActorIdCaster(combatContext)
	return combatContext.constCasterInfo and combatContext.constCasterInfo.actorId or 0
end

function CombatActionTool.parseActorIdTarget(combatContext)
	local actorId = 0

	if combatContext.runtimeTargetInfo then
		actorId = combatContext.runtimeTargetInfo.actorId

		if combatContext.runtimeTargetInfo.isVariantTarget then
			actorId = CombatActionTool.getTargetCurrentControllingTarget(actorId)
		end
	end

	return actorId
end

function CombatActionTool.parseActorIdCurPetOrTeamPet(combatContext)
	local ownerEntity = CombatActionTool.getOwnerEntity(combatContext)
	local player = Utils.getMasterPlayer(ownerEntity)

	if not player then
		return 0
	end

	local curPet

	if player then
		curPet = player:getCurPetEntity()
	end

	if curPet and curPet:isAlive() then
		return curPet.actorId
	elseif player.teamInfo and (player:isInTeam() or player:isInDungeonTeam()) then
		local memberInfo

		if player.getCurTeamMemberInfo then
			memberInfo = player:getCurTeamMemberInfo()
		else
			memberInfo = player.teamInfo.membersInfo
		end

		if ToBool(memberInfo) then
			local closestEnt, closetDisSqr

			for _, info in pairs(memberInfo) do
				if info.entityId ~= player.id then
					local teamEnt = pg.getEntity(info.entityId)
					local teamPet = teamEnt and teamEnt:getCurPetEntity()

					if teamPet and teamPet.space == player.space and teamPet:isAlive() then
						local curDist = Vector3.SqrDistance(player:getPosition(), teamPet:getPosition())

						if not closetDisSqr or curDist < closetDisSqr then
							closestEnt = teamPet
							closetDisSqr = curDist
						end
					end
				end
			end

			if closestEnt then
				return closestEnt.actorId
			end
		end
	end

	return 0
end

function CombatActionTool.parseActorIdPosOrTarget(combatContext)
	return combatContext.runtimeTargetInfo and combatContext.runtimeTargetInfo.actorId or 0
end

function CombatActionTool.parseActorIdOwner(combatContext)
	return combatContext.actorId
end

function CombatActionTool.parseActorIdMaster(combatContext)
	local ownerActorId = combatContext.actorId

	if ownerActorId ~= 0 then
		local casterEntity = pg.getEntityByActorId(ownerActorId)
		local masterEntity = casterEntity and casterEntity.getMasterEntity and casterEntity:getMasterEntity() or nil

		if masterEntity ~= nil then
			return masterEntity.actorId
		end
	end

	return ownerActorId
end

function CombatActionTool.parseActorIdCurPet(combatContext)
	local ownerEntity = pg.getEntityByActorId(combatContext.actorId)

	if not ownerEntity then
		return 0
	end

	local player = AbilityUtils.getPlayer(ownerEntity)
	local curPet = player and player:getCurPetEntity()

	return curPet and curPet.actorId or 0
end

function CombatActionTool.parseActorIdSrc(combatContext)
	local buff = combatContext:buff()

	if buff and combatContext.srcType == AbilityConst.SRC_TYPE_BUFF then
		local entity = pg.getEntity(buff.buffData.srcEntityId)

		return entity and entity.actorId or 0
	end

	return combatContext.constCasterInfo and combatContext.constCasterInfo.srcActorId
end

function CombatActionTool.parseActorIdTrapTarget(combatContext)
	return combatContext.trapTargetActorId or 0
end

function CombatActionTool.parseActorId(combatContext, targetType)
	if not combatContext then
		return 0
	end

	local actorId = 0

	if Utils.isTable(targetType) then
		actorId = pg.global.abilityMgr.combatAction:doAction(targetType, combatContext)

		if not AbilityConst.FORBID_CONVERT_CONTROL_TARGET[targetType.name] and type(actorId) == "number" then
			actorId = CombatActionTool.getTargetCurrentControllingTarget(actorId, targetType.name)
		end
	else
		local fun = CombatActionTool[AbilityConst.PARSE_ACTOR_ID_MAP[targetType]]

		if fun then
			actorId = fun(combatContext)
		end
	end

	if type(actorId) ~= "number" then
		actorId = 0
	end

	return actorId
end

function CombatActionTool.getTargetCurrentControllingTarget(actorId, targetName)
	if actorId ~= 0 and actorId ~= nil then
		local entity = pg.getEntityByActorId(actorId)

		if entity then
			if Utils.isPlayer(entity) and entity.controlState == Const.CONTROL_STATE_CONTROL and targetName ~= "getCacheVal" then
				actorId = entity:getCurPetEntity().actorId
			elseif Utils.isPet(entity) then
				local masterEntity = entity:getMasterEntity()
				local curTgtPetEntity = masterEntity and masterEntity:getCurPetEntity()

				if not curTgtPetEntity or curTgtPetEntity:isDead() then
					actorId = masterEntity.actorId
				else
					actorId = curTgtPetEntity.actorId
				end
			end
		end
	end

	return actorId
end

function CombatActionTool.getRegisterEventSubjectEntity(combatContext, targetType)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, targetType))

	if targetEntity and EventBus.isReceiveAdditionalEvent and Utils.isPlayerPet(targetEntity) then
		targetEntity = targetEntity:getMasterEntity()
	end

	if targetEntity and not targetEntity.subject then
		return nil
	end

	return targetEntity
end

function CombatActionTool.notifyCasterEvent(casterEnt, eventName, param1)
	if not casterEnt then
		return
	end

	local isTreatedAsMaster = (Utils.isCreation(casterEnt) or Utils.isPuppet(casterEnt)) and casterEnt.notifyMasterAbilityEvent
	local masterEnt = casterEnt.getMasterEntity and casterEnt:getMasterEntity()

	if isTreatedAsMaster and masterEnt then
		casterEnt.subject:notifySelf(eventName, param1)
		masterEnt.subject:notify(eventName, param1)
	else
		casterEnt.subject:notify(eventName, param1)
	end
end

function CombatActionTool.getCasterAbility(combatContext)
	if not combatContext then
		return nil
	end

	local ability = combatContext:ability()

	if ability then
		return ability
	end

	local buff = combatContext:buff()

	if buff then
		return buff:getSrcAbility()
	end
end

function CombatActionTool.getHitPosition(entity, heightPercent, partId)
	if not entity then
		return nil
	end

	heightPercent = heightPercent or AbilitySettingGlobalConstData.defaultHitPositionPercent

	if not entity.projHitPos then
		entity.projHitPos = Vector3.ForceNew(0, 0, 0)
	end

	local hitPosition = entity.projHitPos

	hitPosition:Copy(entity:getPosition())

	if entity.getLockPartPosition and ToBool(partId) then
		return entity:getLockPartPosition(partId)
	end

	if entity.BURROW_ST and entity:BURROW_ST() then
		return hitPosition
	end

	if entity.isControllingEgg and entity:isControllingEgg() then
		local eggEnt = entity:getCurControllingEgg()

		if eggEnt and eggEnt.getHitPosition then
			return eggEnt:getHitPosition()
		end

		return entity:getPosition()
	end

	if Utils.isCreation(entity) then
		local creationData = CreationData[entity.templateId]
		local heightOffset = 0

		if AbilityConst.LX_GEOMETRY_TYPE_PARSER[creationData.shapeKind] == AbilityConst.LX_GEOMETRY_TYPE_SPHERE then
			heightOffset = creationData.shapeArgs[1]
		else
			heightOffset = creationData.shapeArgs and creationData.shapeArgs[2] * heightPercent or 0
		end

		CombatActionTool.translatePointOffsetXYZ(hitPosition, hitPosition, entity:getRotation(), 0, heightOffset, 0)

		return hitPosition
	elseif Utils.isEnvObj(entity) then
		return entity:getLockPartPosition(partId)
	end

	if entity.bodyHeight == nil then
		return hitPosition
	end

	local height = 0

	if entity.eModel and entity.eModel.height > 0 then
		height = entity.eModel.height * heightPercent
	else
		height = entity.bodyHeight * heightPercent
	end

	CombatActionTool.translatePointOffsetXYZ(hitPosition, hitPosition, entity:getRotation(), 0, height, 0)

	return hitPosition
end

function CombatActionTool.getHeightPosition(entity)
	local heightPosition = entity:getPosition()

	if Utils.isCreation(entity) then
		local creationData = CreationData[entity.templateId]
		local heightOffset = 0

		if AbilityConst.LX_GEOMETRY_TYPE_PARSER[creationData.shapeKind] == AbilityConst.LX_GEOMETRY_TYPE_SPHERE then
			heightOffset = creationData.shapeArgs[1]
		else
			heightOffset = creationData.shapeArgs[2]
		end

		Vector3.enableCreateFromCache()

		local plusVector3 = Vector3(0, heightOffset, 0)

		heightPosition = heightPosition + entity:getRotation():MulVec3(plusVector3)

		Vector3.disableCreateFromCache(heightPosition)

		return heightPosition
	end

	if entity.bodyHeight == nil then
		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			CombatLogger.debug("@hyj entity.bodyHeight not found", entity.actorId)
		end

		return heightPosition
	end

	local height = 0

	if entity.eModel then
		height = entity.eModel.height
	else
		height = entity.bodyHeight
	end

	Vector3.enableCreateFromCache()

	local plusVector3 = Vector3(0, height, 0)

	heightPosition = heightPosition + entity:getRotation():MulVec3(plusVector3)

	Vector3.disableCreateFromCache(heightPosition)

	return heightPosition
end

function CombatActionTool.parseAttackPos(combatContext, refPos)
	if combatContext.constCasterInfo.attackPos then
		refPos:Set(combatContext.constCasterInfo.attackPos.x, combatContext.constCasterInfo.attackPos.y, combatContext.constCasterInfo.attackPos.z)

		return true
	end

	if combatContext.runtimeTargetInfo.hitPos then
		refPos:Set(combatContext.runtimeTargetInfo.hitPos.x, combatContext.runtimeTargetInfo.hitPos.y, combatContext.runtimeTargetInfo.hitPos.z)

		return true
	end

	return false
end

function CombatActionTool.parseTargetPos(combatContext, refPos)
	local actorId = CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_TARGET)
	local entity = pg.getEntityByActorId(actorId)

	if not entity then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			CombatLogger.info("@jqj entity not found", actorId)
		end

		return false
	end

	if entity then
		local targetPosition = entity:getPosition()

		refPos:Set(targetPosition.x, targetPosition.y, targetPosition.z)

		return true
	end

	return false
end

function CombatActionTool.parseTargetHitPos(combatContext, refPos)
	local actorId = CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_TARGET)
	local entity = pg.getEntityByActorId(actorId)

	if not entity then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			CombatLogger.warn("@jqj entity not found", actorId)
		end

		return false
	end

	if entity then
		local partId = 0

		if actorId == combatContext.constCasterInfo.targetActorId then
			partId = combatContext.constCasterInfo.partId
		end

		local hitPosition = CombatActionTool.getHitPosition(entity, nil, partId)

		refPos:Set(hitPosition.x, hitPosition.y, hitPosition.z)

		return true
	end

	return false
end

function CombatActionTool.parseHitPos(combatContext, refPos)
	if not combatContext.runtimeTargetInfo then
		return false
	end

	if not combatContext.runtimeTargetInfo or not combatContext.runtimeTargetInfo.hitPos then
		return false
	end

	refPos:Set(combatContext.runtimeTargetInfo.hitPos.x, combatContext.runtimeTargetInfo.hitPos.y, combatContext.runtimeTargetInfo.hitPos.z)

	return true
end

function CombatActionTool.parseHitRotation(combatContext, rotQua)
	if not combatContext.runtimeTargetInfo then
		return false
	end

	Vector3.enableCreateFromCache()
	rotQua:Copy(Quaternion.LookRotation(combatContext.runtimeTargetInfo.hitDir, Vector3.up))
	Vector3.disableCreateFromCache()

	return true
end

function CombatActionTool.parseRandomPoint(combatContext, refPos)
	refPos:Set(combatContext.randomPointPos.x, combatContext.randomPointPos.y, combatContext.randomPointPos.z)

	return true
end

function CombatActionTool.parseAttackPosOrTarget(combatContext, refPos)
	local targetType = AbilityConst.COMBAT_TARGET_TYPE_POS_OR_TARGET

	if combatContext.constCasterInfo.attackPos ~= nil then
		local casterEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_CASTER))

		if combatContext.abilityId then
			if not casterEntity then
				return false
			end

			if not AbilityUtils.checkTargetSearchRange(combatContext:getAbilityTemplate(), casterEntity:getPosition() or nil, combatContext.constCasterInfo.targetPos or combatContext.constCasterInfo.attackPos, 0, 0) then
				if LoggerManager.checkLogger(LoggerConst.ERROR) then
					CombatLogger.error("checkTargetSearchRange targetPos out range", combatContext.abilityId, (combatContext.constCasterInfo.targetPos or combatContext.constCasterInfo.attackPos):__tostring())
				end

				return false
			end
		end

		refPos:Copy(combatContext.constCasterInfo.attackPos)

		return true
	else
		local actorId = CombatActionTool.parseActorId(combatContext, targetType)
		local entity = pg.getEntityByActorId(actorId)

		if entity ~= nil then
			refPos:Copy(entity:getPosition())

			return true
		else
			local ownerEntity = CombatActionTool.getOwnerEntity(combatContext)

			if ownerEntity then
				refPos:Copy(ownerEntity:getPosition())
			end

			return false
		end
	end

	return false
end

function CombatActionTool.parseHitBoxPos(combatContext, refPos)
	return false
end

function CombatActionTool.parseProjectilePos(combatContext, refPos)
	local projectile = combatContext:projectile()

	if projectile then
		refPos:Set(projectile.pos.x, projectile.pos.y, projectile.pos.z)

		return true
	elseif combatContext.csProjPos then
		refPos:Set(combatContext.csProjPos.x, combatContext.csProjPos.y, combatContext.csProjPos.z)

		return true
	end

	return false
end

function CombatActionTool.parseCurPetHitPos(combatContext, refPos)
	local actorId = CombatActionTool.parseActorIdCurPet(combatContext)
	local entity = pg.getEntityByActorId(actorId)

	if entity ~= nil then
		local hitPosition = CombatActionTool.getHitPosition(entity)

		refPos:Set(hitPosition.x, hitPosition.y, hitPosition.z)

		return true
	end

	return false
end

function CombatActionTool.parseAimPos(combatContext, refPos)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity then
		return false
	end

	local abilityObject = combatContext:ability():getAbilityObject()
	local autoAimInfo = abilityObject.cacheValMap[AbilityConst.COMBAT_EVENT_ON_SKILL_AUTO_AIM]
	local autoAimDuration = autoAimInfo and autoAimInfo.duration or -1
	local autoAimStartTime = autoAimInfo and autoAimInfo.startTime or 0
	local curTime = ownerEntity:getGameTime()

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		CombatLogger.debug("@hyj onParseAimPos", curTime, autoAimStartTime, autoAimDuration, autoAimDuration < curTime - autoAimStartTime)
	end

	if (ownerEntity.isMainPlayer or ownerEntity.isMainPet) and pg.game.camera.playerCameraMode.isInAim and autoAimDuration < curTime - autoAimStartTime then
		if combatContext.isProjectileHasGravity then
			local x, y, z = PhysicsUtils.getScreenCenterPosXYZIgnoreCollision()

			combatContext.isProjectileHasGravity = nil

			refPos:Set(x, y, z)
		else
			local x, y, z = PhysicsUtils.getScreenCenterPosXYZFurtherThanEntity(ownerEntity)

			refPos:Set(x, y, z)
		end

		return true
	else
		Vector3.Copy(refPos, ownerEntity:getPosition())

		return CombatActionTool.parsePosition(combatContext, AbilityConst.COMBAT_TARGET_TYPE_TARGET_HIT, refPos)
	end
end

function CombatActionTool.parseDefaultTargetPos(combatContext, refPos, targetType)
	local actorId = CombatActionTool.parseActorId(combatContext, targetType)
	local entity = pg.getEntityByActorId(actorId)

	if entity ~= nil then
		refPos:Copy(entity:getPosition())

		return true
	end

	return false
end

function CombatActionTool.parsePosition(combatContext, targetType, refPos)
	if not targetType then
		return false
	end

	if Utils.isTable(targetType) then
		local result = pg.global.abilityMgr.combatAction:doAction(targetType, combatContext)

		if result then
			local resultType = type(result)

			if AbilityUtils.isVector3(result) and result ~= CombatActionTool.INVALID_POS then
				refPos:Copy(result)

				return true
			elseif resultType == "number" then
				local entity = pg.getEntityByActorId(result)

				if entity then
					refPos:Copy(entity:getPosition())

					return true
				end
			end
		end

		return false
	end

	local fun = CombatActionTool[AbilityConst.PARSE_POSITION_MAP[targetType]]

	if fun then
		return fun(combatContext, refPos)
	else
		return CombatActionTool.parseDefaultTargetPos(combatContext, refPos, targetType)
	end
end

function CombatActionTool.parseRotation(combatContext, targetType, refRot)
	if not targetType then
		return false
	end

	if Utils.isTable(targetType) then
		local result = pg.global.abilityMgr.combatAction:doAction(targetType, combatContext)

		if result then
			if Utils.isTable(result) then
				if result.class == "Quaternion" then
					refRot:Copy(result)
				elseif result.class == "Vector3" then
					refRot:SetEuler(result[1], result[2], result[3])
				end

				return true
			elseif type(result) == "number" then
				local entity = pg.getEntityByActorId(result)

				if entity then
					refRot:Copy(entity:getRotation())

					return true
				end
			end
		end

		return false
	end

	local entity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, targetType))

	if entity then
		refRot:Copy(entity:getRotation())

		return true
	end

	return false
end

function CombatActionTool.parseRotationTargetType(rotationType, overrideData)
	if rotationType == AbilityConst.COMBAT_ROTATION_TYPE_TO_POS then
		return overrideData and overrideData.posType
	end

	return AbilityConst.PARSE_ROTATION_TARGET_MAP[rotationType]
end

function CombatActionTool.parseRotationTowards(combatContext, rotationType, initPos, refRot, overrideData)
	if not ToBool(rotationType) then
		return false
	end

	if rotationType == AbilityConst.COMBAT_ROTATION_TYPE_Direct then
		return CombatActionTool.parseRotation(combatContext, overrideData.targetRotation, refRot)
	elseif rotationType == AbilityConst.COMBAT_ROTATION_TYPE_INV_CIRCLE_CENTER then
		if not overrideData.centerPos then
			return false
		end

		Vector3.enableCreateFromCache()

		local dir = initPos - overrideData.centerPos

		refRot:Copy(Quaternion.LookRotation(dir, Vector3.up))
		Vector3.disableCreateFromCache()
	elseif rotationType == AbilityConst.COMBAT_ROTATION_TYPE_SAME_AS_CIRCLE_CENTER then
		if not overrideData.centerRotation then
			return false
		end

		refRot:Copy(overrideData.centerRotation)
	else
		local targetType = CombatActionTool.parseRotationTargetType(rotationType, overrideData)

		if not ToBool(targetType) then
			return false
		end

		Vector3.enableCreateFromCache()

		local to = initPos:Clone()

		if rotationType == AbilityConst.COMBAT_ROTATION_TYPE_TO_TARGET and overrideData.targetPos then
			to = overrideData.targetPos:Clone()
		elseif not CombatActionTool.parsePosition(combatContext, targetType, to) then
			Vector3.disableCreateFromCache()

			return false
		end

		local dir = to:Sub(initPos)
		local len = dir:Magnitude()

		if len < 0.0001 then
			Vector3.disableCreateFromCache()

			return false
		end

		refRot:Copy(Quaternion.LookRotation(dir, Vector3.up))
		Vector3.disableCreateFromCache()
	end

	return true
end

function CombatActionTool.parseToTargetRotation(targetId, targetPos, pos, refRot)
	if ToBool(targetPos) then
		Vector3.enableCreateFromCache()

		local from = pos:Clone()
		local dir = targetPos:Sub(from)

		dir.y = 0

		local len = dir:Magnitude()

		if len < 0.0001 then
			Vector3.disableCreateFromCache()

			return false
		end

		refRot:Copy(Quaternion.LookRotation(dir, Vector3.up))
		Vector3.disableCreateFromCache()

		return true
	end

	local target = pg.getEntityByActorId(targetId)

	if not target then
		return false
	end

	Vector3.enableCreateFromCache()

	local from = pos:Clone()
	local targetPosition = target:getPosition():Clone()
	local dir = targetPosition:Sub(from)

	dir.y = 0

	local len = dir:Magnitude()

	if len < 0.0001 then
		Vector3.disableCreateFromCache()

		return false
	end

	refRot:Copy(Quaternion.LookRotation(dir, Vector3.up))
	Vector3.disableCreateFromCache()

	return true
end

function CombatActionTool.parseRotationFromTo(combatContext, fromTargetType, toTargetType, refRot, considerYAxis)
	if not ToBool(toTargetType) then
		return CombatActionTool.parseRotation(combatContext, fromTargetType, refRot)
	elseif not ToBool(fromTargetType) then
		if CombatActionTool.parseRotation(combatContext, toTargetType, refRot) then
			Vector3.enableCreateFromCache()
			Quaternion.Copy(refRot, refRot * Quaternion.AngleAxis(180, Vector3.up))
			Vector3.disableCreateFromCache()
		end

		return true
	else
		local owner = pg.getEntityByActorId(combatContext.actorId)

		if not owner then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				CombatLogger.error("@jqj owner not found", combatContext.actorId)
			end

			return false
		end

		Vector3.enableCreateFromCache()

		local from = owner:getPosition():Clone()

		if not CombatActionTool.parsePosition(combatContext, fromTargetType, from) then
			Vector3.disableCreateFromCache()

			return false
		end

		local to = owner:getPosition():Clone()

		if not CombatActionTool.parsePosition(combatContext, toTargetType, to) then
			Vector3.disableCreateFromCache()

			return false
		end

		local dir = to:Sub(from)

		if not considerYAxis then
			dir.y = 0
		end

		local len = dir:Magnitude()

		if len < 0.0001 then
			Vector3.disableCreateFromCache()

			return false
		end

		refRot:Copy(Quaternion.LookRotation(dir, Vector3.up))
		Vector3.disableCreateFromCache()

		return true
	end
end

function CombatActionTool.parseProjectileEmitRotationFromTo(combatContext, fromTargetType, toTargetType, refPos, refRot)
	if not ToBool(toTargetType) then
		return CombatActionTool.parseRotation(combatContext, fromTargetType, refRot)
	else
		Vector3.enableCreateFromCache()

		local from = refPos:Clone()

		if ToBool(fromTargetType) and not CombatActionTool.parsePosition(combatContext, fromTargetType, from) then
			Vector3.disableCreateFromCache()

			return false
		end

		local to = refPos:Clone()

		if not CombatActionTool.parsePosition(combatContext, toTargetType, to) then
			Vector3.disableCreateFromCache()

			return false
		end

		local dir = to:Sub(from)
		local len = dir:Magnitude()

		if len < 0.0001 then
			Vector3.disableCreateFromCache()

			return false
		end

		refRot:Copy(Quaternion.LookRotation(dir, Vector3.up))
		Vector3.disableCreateFromCache()

		return true
	end
end

function CombatActionTool.parseTriggers(triggerStr)
	if not ToBool(triggerStr) then
		return {}
	end

	local triggerIds = {}

	if type(triggerStr) == "string" then
		for _, str in ipairs(string.split(triggerStr, " ")) do
			table.insert(triggerIds, tonumber(str))
		end
	else
		triggerIds = triggerStr
	end

	return triggerIds
end

function CombatActionTool.translatePoint(origin, rot, translation)
	return origin + rot:MulVec3(translation)
end

function CombatActionTool.translatePointOffsetXYZ(refPos, pos, rot, tx, ty, tz)
	local ox, oy, oz = Quaternion.MulXYZNoGC(rot, tx, ty, tz)

	refPos:Set(pos[1] + ox, pos[2] + oy, pos[3] + oz)
end

function CombatActionTool.interpConstantPoint(current, target, deltaTime, interpSpeed, curRot, maxAngle)
	Vector3.enableCreateFromCache()

	local delta = target - current
	local deltaLen = delta:Magnitude()
	local maxStep = interpSpeed * deltaTime
	local maxAngularOffset = maxAngle

	if maxAngularOffset ~= nil and maxAngularOffset >= 0 and Vector3.Magnitude(delta) > math.smallNumber then
		local targetRot = Quaternion.LookRotation(delta, Vector3.up)
		local newRot = Quaternion.RotateTowards(curRot, targetRot, maxAngularOffset * deltaTime)
		local newDir = newRot:MulVec3(Vector3.forward)

		newDir:SetNormalize()

		if deltaLen < maxStep and math.abs(Vector3.Dot(newDir, delta:Normalize()) - 1) < math.smallNumber then
			Vector3.disableCreateFromCache()

			return target, true
		end

		local result = current + newDir * maxStep

		Vector3.disableCreateFromCache(result)

		return result, false
	end

	if deltaLen < maxStep then
		Vector3.disableCreateFromCache()

		return target, true
	end

	if maxStep > 0 then
		local deltaNormal = delta / deltaLen
		local result = current + deltaNormal * maxStep

		Vector3.disableCreateFromCache(result)

		return result, false
	else
		Vector3.disableCreateFromCache()

		return current, false
	end
end

function CombatActionTool.rotateAround(centerPos, pos, velocity, rotateData, centerForward, centerUp, centerLeft, deltaSeconds)
	local nextPos = pos
	local nextVelocity = velocity

	if ToBool(rotateData) then
		local rotateAngles = Vector3(unpack(rotateData))

		if rotateAngles.z ~= 0 then
			local deltaRot = Quaternion.AngleAxis(rotateAngles.z * deltaSeconds, centerForward)
			local offset = nextPos - centerPos

			nextPos = centerPos + deltaRot:MulVec3(offset)
			nextVelocity = deltaRot:MulVec3(nextVelocity)
		end

		if rotateAngles.y then
			local deltaRot = Quaternion.AngleAxis(rotateAngles.y * deltaSeconds, centerUp)
			local offset = nextPos - centerPos

			nextPos = centerPos + deltaRot:MulVec3(offset)
			nextVelocity = deltaRot:MulVec3(nextVelocity)
		end

		if rotateAngles.x then
			local deltaRot = Quaternion.AngleAxis(rotateAngles.x * deltaSeconds, centerLeft)
			local offset = nextPos - centerPos

			nextPos = centerPos + deltaRot:MulVec3(offset)
			nextVelocity = deltaRot:MulVec3(nextVelocity)
		end
	end

	return nextPos, nextVelocity
end

function CombatActionTool.compressRGB(r, g, b)
	local ur = math.floor(r * 255)
	local ug = math.floor(g * 255)
	local ub = math.floor(b * 255)
	local result = bit.lshift(ur, 16) + bit.lshift(ug, 16) + ub

	return result / (1 * bit.lshift(2, 24))
end

function CombatActionTool.parseProjectileRotation(combatContext, fromPos, toTargetType, refRot)
	local owner = pg.getEntityByActorId(combatContext.actorId)

	if not owner then
		return false
	end

	Vector3.enableCreateFromCache()

	local to = owner:getPosition():Clone()

	if not CombatActionTool.parsePosition(combatContext, toTargetType, to) then
		Vector3.disableCreateFromCache()

		return true
	end

	local dir = to - fromPos

	if dir:Magnitude() < 0.0001 then
		Vector3.disableCreateFromCache()

		return true
	end

	refRot:Copy(Quaternion.LookRotation(dir, Vector3.up))
	Vector3.disableCreateFromCache()

	return true
end

function CombatActionTool.parseMultiTargetInfo(abilityManger, targetData, multiTargetsInfo, scale, combatContext)
	multiTargetsInfo.center = targetData.center
	multiTargetsInfo.rotFrom = targetData.rotFrom
	multiTargetsInfo.rotTo = targetData.rotTo
	multiTargetsInfo.shapeKind = AbilityConst.LX_GEOMETRY_TYPE_PARSER[targetData.shapeKind]

	if not multiTargetsInfo.shapeArgs then
		multiTargetsInfo.shapeArgs = {}
	else
		Lume.clear(multiTargetsInfo.shapeArgs)
	end

	if targetData.shapeArgs.name == nil then
		for idx, value in ipairs(targetData.shapeArgs) do
			if idx == 2 and multiTargetsInfo.shapeKind == AbilityConst.LX_GEOMETRY_TYPE_SECTOR3D or idx == 3 and multiTargetsInfo.shapeKind == AbilityConst.LX_GEOMETRY_TYPE_ANNULARSECTOR3D then
				multiTargetsInfo.shapeArgs[idx] = value
			else
				multiTargetsInfo.shapeArgs[idx] = value * scale
			end
		end
	else
		local shapeArgs = pg.global.abilityMgr.combatAction:doAction(targetData.shapeArgs, combatContext)

		for idx, value in ipairs(shapeArgs) do
			if idx == 2 and multiTargetsInfo.shapeKind == AbilityConst.LX_GEOMETRY_TYPE_SECTOR3D or idx == 3 and multiTargetsInfo.shapeKind == AbilityConst.LX_GEOMETRY_TYPE_ANNULARSECTOR3D then
				multiTargetsInfo.shapeArgs[idx] = value
			else
				multiTargetsInfo.shapeArgs[idx] = value * scale
			end
		end
	end

	multiTargetsInfo.offsetXYZ = targetData.offsetXYZ.name == nil and targetData.offsetXYZ or pg.global.abilityMgr.combatAction:doAction(targetData.offsetXYZ, combatContext)
	multiTargetsInfo.offsetRotation = targetData.offsetRotation.name == nil and targetData.offsetRotation or pg.global.abilityMgr.combatAction:doAction(targetData.offsetRotation, combatContext)
	multiTargetsInfo.relation = targetData.relation
	multiTargetsInfo.maxNum = targetData.maxNum
	multiTargetsInfo.heightDown = 0
	multiTargetsInfo.heightUp = 0

	if multiTargetsInfo.shapeKind == AbilityConst.LX_GEOMETRY_TYPE_CIRCLE3D then
		local radius, heightUp, heightDown = unpack(multiTargetsInfo.shapeArgs)

		multiTargetsInfo.maxRange = radius
		multiTargetsInfo.yOffset = (heightUp - heightDown) / 2
		multiTargetsInfo.height = heightUp + heightDown
		multiTargetsInfo.heightDown = heightDown
		multiTargetsInfo.heightUp = heightUp
	elseif multiTargetsInfo.shapeKind == AbilityConst.LX_GEOMETRY_TYPE_SECTOR3D then
		local radius, theta, heightUp, heightDown = unpack(multiTargetsInfo.shapeArgs)

		multiTargetsInfo.maxRange = radius
		multiTargetsInfo.yOffset = (heightUp - heightDown) / 2
		multiTargetsInfo.height = heightUp + heightDown
		multiTargetsInfo.heightDown = heightDown
		multiTargetsInfo.heightUp = heightUp
	elseif multiTargetsInfo.shapeKind == AbilityConst.LX_GEOMETRY_TYPE_TRAPEZOID3D then
		local startRadius, endRadius, distance, heightUp, heightDown = unpack(multiTargetsInfo.shapeArgs)

		multiTargetsInfo.maxRange = math.sqrt(math.max(startRadius * startRadius + distance * distance, endRadius * endRadius + distance * distance))
		multiTargetsInfo.yOffset = (heightUp - heightDown) / 2
		multiTargetsInfo.height = heightUp + heightDown
		multiTargetsInfo.heightDown = heightDown
		multiTargetsInfo.heightUp = heightUp
	elseif multiTargetsInfo.shapeKind == AbilityConst.LX_GEOMETRY_TYPE_ANNULARSECTOR3D then
		local innerRadius, outerRadius, theta, heightUp, heightDown = unpack(multiTargetsInfo.shapeArgs)

		multiTargetsInfo.maxRange = outerRadius
		multiTargetsInfo.yOffset = (heightUp - heightDown) / 2
		multiTargetsInfo.height = heightUp + heightDown
		multiTargetsInfo.heightDown = heightDown
		multiTargetsInfo.heightUp = heightUp
	else
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("@jqj not support shapeKind", multiTargetsInfo.shapeKind)
		end

		return false
	end

	return true
end

function CombatActionTool.doTagReaction(combatContext, conditionType, ent, combatContextId)
	if conditionType == AbilityConst.CONDITION_TYPE_NONE then
		return false
	end

	local condition = AbilityConst.CONDITION_NUM_TO_STR[conditionType]

	if ReactionBP[condition] == nil then
		return false
	end

	local actorEnt = pg.getEntityByActorId(combatContext.actorId)

	if actorEnt == nil then
		return false
	end

	local selfTags = ent:getTagMaterial() or 0
	local index = 0

	while selfTags ~= 0 do
		if bit.band(selfTags, 1) ~= 0 then
			local tag = bit.lshift(1, index)
			local tagStr = AbilityConst.TAG_NUM_TO_STR[tag]
			local triggerData = ReactionBP[condition][tagStr]

			if ToBool(triggerData) then
				local tagReactionCombatContext = actorEnt:getCombatContextFromCache(AbilityConst.COMBAT_CONTEXT_TYPE_TAG_REACTION, combatContextId)

				tagReactionCombatContext.BPName = "tag_reaction_BP"
				tagReactionCombatContext.tagReactionTags = {
					condition,
					tagStr
				}

				tagReactionCombatContext:setConstCasterInfo(combatContext.constCasterInfo)

				tagReactionCombatContext.runtimeTargetInfo = combatContext.runtimeTargetInfo and combatContext.runtimeTargetInfo:clone()
				tagReactionCombatContext.abilityId = combatContext.abilityId
				tagReactionCombatContext.abilityStoreType = combatContext.abilityStoreType

				tagReactionCombatContext:initNodeMap()
				pg.global.abilityMgr.combatAction:doActions(triggerData, tagReactionCombatContext)
				actorEnt:returnCombatContext(tagReactionCombatContext, true)
			end
		end

		index = index + 1
		selfTags = bit.rshift(selfTags, 1)
	end
end

function CombatActionTool.doTagReactions(ownerEntity, entity, hitPos, combatContext, actionData, conditionTypes)
	if ownerEntity.authority == Const.AUTHORITY_MASTER then
		local triggerDataList = ListPool.getList(3)
		local conditionList = ListPool.getList(3)
		local tagStrList = ListPool.getList(3)
		local selfTags = entity:getTagMaterial() or 0

		for _, conditionType in ipairs(conditionTypes) do
			if conditionType and conditionType ~= AbilityConst.CONDITION_TYPE_NONE then
				local condition = AbilityConst.CONDITION_NUM_TO_STR[conditionType]

				if ReactionBP[condition] ~= nil then
					local actorEnt = ownerEntity
					local index = 0

					while selfTags ~= 0 do
						if bit.band(selfTags, 1) ~= 0 then
							local tag = bit.lshift(1, index)
							local tagStr = AbilityConst.TAG_NUM_TO_STR[tag]
							local triggerData = ReactionBP[condition][tagStr]

							if ToBool(triggerData) then
								table.insert(triggerDataList, triggerData)
								table.insert(conditionList, condition)
								table.insert(tagStrList, tagStr)
							end
						end

						index = index + 1
						selfTags = bit.rshift(selfTags, 1)
					end
				end
			end
		end

		if #triggerDataList == 0 then
			ListPool.returnList(triggerDataList, 3)
			ListPool.returnList(conditionList, 3)
			ListPool.returnList(tagStrList, 3)

			return
		end

		local combatHitTargetInfo = pg.global.abilityMgr.runtimeTargetInfoPool:get(true)

		combatHitTargetInfo:initTarget(entity.actorId, hitPos, 1)

		local guardVal = pg.global.abilityMgr.guardValuePool:getWithCtor(true, combatContext, "runtimeTargetInfo", combatHitTargetInfo)
		local combatContextId = ownerEntity:genCombatContextId()

		if pg.component == "client" then
			ownerEntity:serverMsgNoGC("RPC_CS_DoTagReaction", actionData.NodeID, combatContext:getRPCDynamicInfo(), combatContextId)
		end

		for index, triggerData in ipairs(triggerDataList) do
			local tagReactionCombatContext = ownerEntity:getCombatContextFromCache(AbilityConst.COMBAT_CONTEXT_TYPE_TAG_REACTION, combatContextId)

			tagReactionCombatContext.BPName = "tag_reaction_BP"
			tagReactionCombatContext.tagReactionTags = {
				conditionList[index],
				tagStrList[index]
			}

			tagReactionCombatContext:setConstCasterInfo(combatContext.constCasterInfo)

			tagReactionCombatContext.runtimeTargetInfo = combatContext.runtimeTargetInfo and combatContext.runtimeTargetInfo:clone()
			tagReactionCombatContext.abilityId = combatContext.abilityId
			tagReactionCombatContext.abilityStoreType = combatContext.abilityStoreType

			tagReactionCombatContext:initNodeMap()
			pg.global.abilityMgr.combatAction:doActions(triggerData, tagReactionCombatContext)
			ownerEntity:returnCombatContext(tagReactionCombatContext, true)
		end

		pg.global.abilityMgr.runtimeTargetInfoPool:returnObject(combatHitTargetInfo)
		pg.global.abilityMgr.guardValuePool:returnObject(guardVal)
		ListPool.returnList(triggerDataList, 3)
		ListPool.returnList(conditionList, 3)
		ListPool.returnList(tagStrList, 3)
	end
end

function CombatActionTool.getShape(shapeKind, shapeArgs)
	if shapeKind == AbilityConst.LX_GEOMETRY_TYPE_CIRCLE3D then
		local radius, heightUp, heightDown = unpack(shapeArgs)
		local lxCircle = pg.global.abilityMgr.lxCirclePool:getWithCtor(true, nil, nil, radius, heightUp, heightDown)

		return lxCircle
	elseif shapeKind == AbilityConst.LX_GEOMETRY_TYPE_SECTOR3D then
		local radius, theta, heightUp, heightDown = unpack(shapeArgs)
		local lxSector = pg.global.abilityMgr.lxSectorPool:getWithCtor(true, nil, nil, radius, theta, heightUp, heightDown)

		return lxSector
	elseif shapeKind == AbilityConst.LX_GEOMETRY_TYPE_TRAPEZOID3D then
		local startRadius, endRadius, distance, heightUp, heightDown = unpack(shapeArgs)
		local lxTrapezoid = pg.global.abilityMgr.lxTrapezoidPool:getWithCtor(true, nil, nil, startRadius, endRadius, distance, heightUp, heightDown)

		return lxTrapezoid
	elseif shapeKind == AbilityConst.LX_GEOMETRY_TYPE_ANNULARSECTOR3D then
		local innerRadius, outerRadius, theta, heightUp, heightDown = unpack(shapeArgs)
		local lxAnnularSector = pg.global.abilityMgr.lxAnnularSectorPool:getWithCtor(true, nil, nil, innerRadius, outerRadius, theta, heightUp, heightDown)

		return lxAnnularSector
	elseif shapeKind == AbilityConst.LX_GEOMETRY_TYPE_SPHERE then
		local radius = shapeArgs[1]

		return pg.global.abilityMgr.lxSpherePool:getWithCtor(true, nil, nil, radius)
	end
end

function CombatActionTool.returnShape(shape)
	if not shape then
		return
	end

	if shape.className == "LxCircle3D" then
		pg.global.abilityMgr.lxCirclePool:returnObject(shape)
	elseif shape.className == "LxSector3D" then
		pg.global.abilityMgr.lxSectorPool:returnObject(shape)
	elseif shape.className == "LxTrapezoid3D" then
		pg.global.abilityMgr.lxTrapezoidPool:returnObject(shape)
	elseif shape.className == "LxAnnularSector3D" then
		pg.global.abilityMgr.lxAnnularSectorPool:returnObject(shape)
	elseif shape.className == "LxSphere" then
		pg.global.abilityMgr.lxSpherePool:returnObject(shape)
	end
end

function CombatActionTool.getCriticalDamageRatio(casterCombatAttribute, targetCombatAttribute, calcInfo, ability, isInBreak, overrideAbilityType)
	local ret = 1

	if not casterCombatAttribute or not targetCombatAttribute then
		return ret
	end

	local abilityTemplate = pg.global.abilityMgr:getAbilityTemplate(ability and ability.abilityId or 0)
	local abilityType = overrideAbilityType or abilityTemplate and abilityTemplate.abilityType or 0
	local criticalRatio = casterCombatAttribute:getRawAttribValue(AttributeConst.crit_rate_v) + (calcInfo.instant_crit_rate_v or 0) - targetCombatAttribute:getRawAttribValue(AttributeConst.crit_rate_dec_v)

	if abilityType == AbilityConst.EnumAbilityType.Attack then
		criticalRatio = criticalRatio + casterCombatAttribute:getRawAttribValue(AttributeConst.normal_attack_crit_inc_rate_v) - targetCombatAttribute:getRawAttribValue(AttributeConst.normal_attack_crit_dec_rate_v)
	elseif abilityType == AbilityConst.EnumAbilityType.Skill then
		criticalRatio = criticalRatio + casterCombatAttribute:getRawAttribValue(AttributeConst.skill_crit_inc_rate_v) - targetCombatAttribute:getRawAttribValue(AttributeConst.skill_crit_dec_rate_v)
	elseif abilityType == AbilityConst.EnumAbilityType.Ultimate then
		criticalRatio = criticalRatio + casterCombatAttribute:getRawAttribValue(AttributeConst.ultimate_crit_inc_rate_v) - targetCombatAttribute:getRawAttribValue(AttributeConst.ultimate_crit_dec_rate_v)
	end

	if isInBreak then
		criticalRatio = criticalRatio + casterCombatAttribute:getRawAttribValue(AttributeConst.break_crit_inc_rate_v)
	end

	criticalRatio = math.max(math.smallNumber, criticalRatio)

	if criticalRatio <= math.smallNumber then
		return ret
	elseif criticalRatio >= 1 or criticalRatio > math.random() then
		local criticalAddV = casterCombatAttribute:getRawAttribValue(AttributeConst.crit_dmg_v) - targetCombatAttribute:getRawAttribValue(AttributeConst.crit_dmg_rate_dec_v)

		if abilityType == AbilityConst.EnumAbilityType.Attack then
			criticalAddV = criticalAddV + casterCombatAttribute:getRawAttribValue(AttributeConst.normal_attack_crit_dmg_inc_rate_v) - targetCombatAttribute:getRawAttribValue(AttributeConst.normal_attack_crit_dmg_dec_rate_v)
		elseif abilityType == AbilityConst.EnumAbilityType.Skill then
			criticalAddV = criticalAddV + casterCombatAttribute:getRawAttribValue(AttributeConst.skill_crit_dmg_v) - targetCombatAttribute:getRawAttribValue(AttributeConst.skill_crit_dmg_dec_rate_v)
		elseif abilityType == AbilityConst.EnumAbilityType.Ultimate then
			criticalAddV = criticalAddV + casterCombatAttribute:getRawAttribValue(AttributeConst.ultimate_crit_dmg_v) - targetCombatAttribute:getRawAttribValue(AttributeConst.ultimate_crit_dec_dmg_v)
		end

		if isInBreak then
			criticalAddV = criticalAddV + casterCombatAttribute:getRawAttribValue(AttributeConst.break_crit_dmg_v)
		end

		ret = ret + criticalAddV + (calcInfo.instant_crit_dmg_v or 0)

		if criticalRatio > 1 and calcInfo.instant_over_crit_rate_to_crit_dmg then
			ret = ret + (criticalRatio - 1) * calcInfo.instant_over_crit_rate_to_crit_dmg
		end
	end

	return math.max(1, ret)
end

function CombatActionTool.getElementDamageAddRatio(casterCombatAttribute, targetCombatAttribute, elementType)
	local ret = 1

	if not casterCombatAttribute then
		return ret
	end

	local elementData = ElementPropData[elementType] or {}
	local attributeName = elementData.dmg_ratio_name
	local casterAddRatio = 0
	local targetDecRatio = 0

	if attributeName == nil or AttributeConst[attributeName] == nil then
		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			CombatLogger.debug("getElementDamageAddRatio, attributeId not found", attributeName, AttributeConst[attributeName], elementType)
		end
	else
		casterAddRatio = casterCombatAttribute:getAttribValue(AttributeConst[attributeName])
	end

	local attributeDecName = elementData.dmg_dec_ratio_name

	if attributeDecName == nil or AttributeConst[attributeDecName] == nil then
		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			CombatLogger.debug("getElementDamageDecRatio, attributeId not found", attributeDecName, AttributeConst[attributeDecName], elementType)
		end
	else
		targetDecRatio = targetCombatAttribute:getAttribValue(AttributeConst[attributeDecName])
	end

	return ret + casterAddRatio - targetDecRatio
end

function CombatActionTool.getElementTpReduceAddRatio(targetEntity, elementType)
	local ret = 1
	local elementData = ElementPropData[elementType] or {}
	local attributeName = elementData.tp_reduce_rate_name
	local addRatio = 0

	if attributeName == nil or AttributeConst[attributeName] == nil then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			CombatLogger.info("getElementTpReduceAddRatio, attributeId not found", attributeName, AttributeConst[attributeName], elementType)
		end
	else
		addRatio = targetEntity.actorCombatAttribute:getRawAttribValue(AttributeConst[attributeName])
	end

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		CombatLogger.debug("getElementTpReduceAddRatio, addRatio, elementType", addRatio, elementType)
	end

	return ret + addRatio
end

function CombatActionTool.getRealCombatContext(ownerEntity, combatContext)
	if combatContext == nil then
		return nil
	end

	if not rawget(combatContext, "isClone") then
		return combatContext
	end

	if not combatContext.id or not ownerEntity or not ownerEntity.getCombatContext then
		return nil
	end

	return ownerEntity:getCombatContext(combatContext.id)
end

function CombatActionTool.getCombatContextAbilityObject(combatContext)
	if not combatContext then
		return nil
	end

	local ctxType = combatContext.ctxType
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity then
		return
	end

	if ctxType == AbilityConst.COMBAT_CONTEXT_TYPE_ABILITY or ctxType == AbilityConst.COMBAT_CONTEXT_TYPE_TAG_REACTION or ctxType == AbilityConst.COMBAT_CONTEXT_TYPE_CHAIN_ATTACK then
		local ability = combatContext:ability()

		return ability and ability:getAbilityObject() or nil
	elseif ctxType == AbilityConst.COMBAT_CONTEXT_TYPE_TIMELINE then
		return ownerEntity and ownerEntity.getTimelineInstance and ownerEntity:getTimelineInstance(combatContext.timelineId)
	elseif ctxType == AbilityConst.COMBAT_CONTEXT_TYPE_BUFF then
		return ownerEntity and ownerEntity.actorBuff and ownerEntity.actorBuff:findBuff(combatContext.id)
	elseif ctxType == AbilityConst.COMBAT_CONTEXT_TYPE_PROJECTILE then
		return ownerEntity and ownerEntity.space and ownerEntity.space.projectileMgr and ownerEntity.space.projectileMgr:getProjectile(combatContext.id)
	end
end

function CombatActionTool.getContextObserver(combatContext)
	local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

	return abilityObject and abilityObject:getObserver() or nil
end

function CombatActionTool.getCasterEnt(combatContext)
	if not combatContext then
		return nil
	end

	local casterActorId = CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_CASTER)
	local casterEntity = pg.getEntityByActorId(casterActorId)

	if not casterEntity and LoggerManager.checkLogger(LoggerConst.DEBUG) then
		CombatLogger.debug("@jqj casterEntity not found", casterActorId)
	end

	return casterEntity
end

function CombatActionTool.getOwnerEntity(combatContext)
	if not combatContext then
		return nil
	end

	return pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))
end

function CombatActionTool.getCombatContextCacheVal(combatContext, key)
	local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

	return abilityObject and abilityObject.cacheValMap[key] or nil
end

function CombatActionTool.setCombatContextCacheVal(combatContext, key, val)
	local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

	if abilityObject then
		abilityObject.cacheValMap[key] = val

		return true
	end

	return false
end

function CombatActionTool.addTimer(key, duration, combatContext, actionData)
	local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

	if abilityObject then
		abilityObject:addTimer(key, duration, function()
			pg.global.abilityMgr.combatAction:doActions(actionData, combatContext)
		end)

		return true
	end

	return false
end

function CombatActionTool.getSameElementDamageRatio(abilityId, buffTemplateId, casterEntity, elementType)
	if not abilityId and not buffTemplateId then
		return 1
	end

	local elementType = elementType or pg.global.abilityMgr:getAbilityParamData(abilityId, buffTemplateId).elementType

	if casterEntity and casterEntity.elementTypes then
		for k, v in pairs(casterEntity.elementTypes) do
			if k == elementType and v then
				return 1 + AbilitySettingGlobalConstData.sameElementDamageAddRatio
			end
		end
	end

	return 1
end

function CombatActionTool.logError(combatContext, actionData, ...)
	if LoggerManager.checkLogger(LoggerConst.ERROR) then
		CombatLogger.error("BpName, nodeId", combatContext and combatContext.BPName, actionData and actionData.NodeID, ...)
	end
end

function CombatActionTool.logDebug(combatContext, actionData, ...)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		CombatLogger.debug("BpName, nodeId", combatContext and combatContext.BPName, actionData.NodeID, ...)
	end
end

function CombatActionTool.isCasterAuthorityMaster(combatContext)
	local casterEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_CASTER))

	return casterEntity and casterEntity.authority == Const.AUTHORITY_MASTER
end

function CombatActionTool.doSweepActions(combatContext, actionData, hitResults, combatAction)
	local conditionTypes = combatAction:getConditionTypes(combatContext, actionData)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity then
		return
	end

	local combatAction = pg.global.abilityMgr.combatAction
	local abilityId = combatContext.abilityId or 0

	for hitIdx, hitResult in ipairs(hitResults) do
		for i = 1, 1 do
			local entity = pg.getEntityByActorId(hitResult.hitActorId)
			local isCreation = Utils.isCreation(entity)

			if entity and Utils.checkValidTarget(entity, ownerEntity) and ownerEntity:checkHitTargetSet(hitResult.hitActorId, abilityId, actionData) and ownerEntity:checkHitTargetCd(hitResult.hitActorId, abilityId, actionData, combatContext.overrideGameTime) then
				if not Utils.checkRelation(ownerEntity, entity, actionData.relation) then
					break
				end

				local combatHitTargetInfo = pg.global.abilityMgr.runtimeTargetInfoPool:get(true)

				ownerEntity:addHitTargetActorId(hitResult.hitActorId, abilityId, actionData)
				ownerEntity:addHitTargetCd(hitResult.hitActorId, abilityId, actionData, combatContext.overrideGameTime)
				combatHitTargetInfo:initTarget(hitResult.hitActorId, hitResult.hitPos, hitIdx, hitResult.hitActorPartIdx)

				local guardVal = GuardValue(combatContext, "runtimeTargetInfo", combatHitTargetInfo)

				combatAction:doActions(actionData, combatContext)
				guardVal:recover()
				pg.global.abilityMgr.runtimeTargetInfoPool:returnObject(combatHitTargetInfo)
			end
		end
	end
end

function CombatActionTool.calc2DEnclosedPathArea(enclosedPath)
	local area = 0
	local points = {}

	for _, path in ipairs(enclosedPath) do
		points[#points + 1] = path[1]
	end

	local maxIdx = #points

	for idx, p in ipairs(points) do
		local nextIdx = idx == maxIdx and 1 or idx + 1
		local preIdx = idx == 1 and maxIdx or idx - 1

		area = area + p[1] * (points[nextIdx][3] - points[preIdx][3])
	end

	return math.abs(area * 0.5)
end

function CombatActionTool.checkPointInEnclosedPath(pos, enclosedPath, targetHeight)
	targetHeight = targetHeight or 1

	local xzValid = true
	local yValid = true
	local cnt = 0
	local ymin = math.huge
	local ymax = -math.huge

	for _, path in ipairs(enclosedPath) do
		local p1 = path[1]
		local p2 = path[2]

		if p1[1] ~= p2[1] and not (pos[1] < math.min(p1[1], p2[1])) and not (pos[1] > math.max(p1[1], p2[1])) then
			local tmpY = p1[3] + (p2[3] - p1[3]) * (pos[1] - p1[1]) / (p2[1] - p1[1])

			if tmpY < pos[3] then
				if pos[1] == p1[1] then
					if p1[1] < p2[1] then
						cnt = cnt + 1
					end
				elseif pos[1] == p2[1] then
					if p1[1] > p2[1] then
						cnt = cnt + 1
					end
				else
					cnt = cnt + 1
				end
			end
		end

		ymin = math.min(ymin, p1[2])
		ymin = math.min(ymin, p2[2])
		ymax = math.max(ymax, p1[2])
		ymax = math.max(ymax, p2[2])
	end

	if cnt % 2 == 0 then
		xzValid = false
	end

	if not (pos[2] >= ymin - targetHeight) or not (pos[2] <= ymax + targetHeight) then
		yValid = false
	end

	return xzValid and yValid
end

function CombatActionTool.isSpecialAbilityAnim(animId)
	return AbilityConst.SPECIAL_ABILITY_ANIM_STATE_2_INDEX[animId]
end

function CombatActionTool.calcRelativeControlPoint(referenceStartPos, referenceTargetPos, referenceControlPos, curStartPos, curTargetPos)
	local controlPosList = {}

	table.insert(controlPosList, curStartPos)

	for _, controlPos in ipairs(referenceControlPos or EMPTY_TABLE) do
		controlPos = Vector3(unpack(controlPos))

		local startToTarget = referenceTargetPos - referenceStartPos
		local referenceRot = Quaternion.FromToRotation(Vector3.forward, startToTarget)
		local invReferenceRot = referenceRot:Inverse()
		local curStartToTarget = curTargetPos - curStartPos
		local lookDir = curStartToTarget:Normalize()
		local fwdRot = Quaternion.LookRotation(lookDir, Vector3.up)
		local startToControl = fwdRot:MulVec3(invReferenceRot:MulVec3(controlPos - referenceStartPos))
		local scaleFactor = curStartToTarget:Magnitude() / startToTarget:Magnitude()
		local controlPosOffset = startToControl * scaleFactor

		table.insert(controlPosList, curStartPos + controlPosOffset)
	end

	table.insert(controlPosList, curTargetPos)

	return controlPosList
end

function CombatActionTool.getProjectileTargetInfo(combatContext, targetPosType, projectileType, pos, rot)
	local targetType = AbilityConst.COMBAT_TARGET_TYPE_TARGET

	if targetPosType and (targetPosType == AbilityConst.COMBAT_TARGET_TYPE_CURPET or targetPosType == AbilityConst.COMBAT_TARGET_TYPE_CURPET_HIT) then
		targetType = AbilityConst.COMBAT_TARGET_TYPE_CURPET
	end

	local targetActorId = CombatActionTool.parseActorId(combatContext, targetType)
	local targetPos
	local targetPosValid = false

	projectileType = ProjectileConst.PROJECTILE_TYPE_PARSER[projectileType]

	if projectileType == ProjectileConst.PROJECTILE_TYPE_PARABOLA then
		local forwardDistance = 4

		targetPos = pos + rot:MulVec3(Vector3.forward) * forwardDistance
		targetPosValid = true
	end

	if projectileType == ProjectileConst.PROJECTILE_TYPE_TRACKING then
		if not targetPosType or AbilityUtils.isVector3(targetPosType) then
			-- block empty
		else
			targetActorId = CombatActionTool.parseActorId(combatContext, targetPosType)
		end

		if type(targetActorId) ~= "number" then
			targetActorId = 0
		end
	end

	if (not ToBool(targetActorId) or projectileType ~= ProjectileConst.PROJECTILE_TYPE_TRACKING) and targetPosType then
		if AbilityUtils.isVector3(targetPosType) then
			local targetPosOffset = Vector3(unpack(targetPosType))

			targetPos = pos + rot:MulVec3(targetPosOffset)
			targetPosValid = true
		else
			targetPos = pos:Clone()
			targetPosValid = CombatActionTool.parsePosition(combatContext, targetPosType, targetPos)
		end
	end

	if projectileType == ProjectileConst.PROJECTILE_TYPE_PARABOLA then
		targetPosValid = true
	end

	return targetActorId, targetPosValid and targetPos or nil
end

function CombatActionTool.genPhysxCollider(physxCom, collider, isTrigger)
	local center = Vector3.New(unpack(collider.centerOffsetXYZ))
	local shapeKind = AbilityConst.LX_GEOMETRY_TYPE_PARSER[collider.shapeKind]
	local args = collider.shapeArgs

	if shapeKind == AbilityConst.LX_GEOMETRY_TYPE_SPHERE then
		physxCom:GenSphere(center, args[1], isTrigger)
	elseif shapeKind == AbilityConst.LX_GEOMETRY_TYPE_BOX then
		physxCom:GenBox(center, Vector3.New(unpack(args)), isTrigger)
	elseif shapeKind == AbilityConst.LX_GEOMETRY_TYPE_CAPSULE then
		physxCom:GenCapsule(args[1], args[2], center, isTrigger)
	end
end

local argList = {}

function CombatActionTool.getCalcValue(data, actorCombatAttribute, combatContext)
	Lume.clear(argList)

	if data.formulaValue or data.formulaByPetCacheProp then
		local formulaId = data.formulaValue and data.formulaValue[1] or data.formulaByPetCacheProp[1]
		local formulaData = FormulaData[formulaId]

		if not formulaData then
			return 0
		end

		if data.formulaValue then
			for i = 2, 6 do
				local arg = data.formulaValue[i]

				if not arg then
					break
				end

				if AttributeConst[arg] then
					arg = actorCombatAttribute and actorCombatAttribute:getAttribValue(AttributeConst[arg]) or 0
				end

				table.insert(argList, arg)
			end
		else
			local srcEntity = combatContext and pg.getEntityByActorId(CombatActionTool.parseActorIdSrc(combatContext))
			local petEntity = AbilityUtils.getPet(srcEntity)
			local petInfo = petEntity and petEntity.petInfo
			local attributeMap

			for i = 2, 6 do
				local arg = 0

				if petInfo then
					local propName = data.formulaByPetCacheProp[i]

					if type(propName) == "number" then
						arg = propName
					elseif propName then
						attributeMap = attributeMap or PetAttributeCalcUtils.getAttributeMapByPetInfo(AbilityUtils.getPlayer(petEntity), petInfo)
						arg = attributeMap[AttributeConst[propName]] or 0
					else
						break
					end
				end

				table.insert(argList, arg)
			end
		end

		if data.formulaExplictId then
			local explictData = FormulaExplictData[data.formulaExplictId]

			if not explictData then
				return 0
			end

			table.insert(argList, explictData.minNum)
			table.insert(argList, explictData.rate)
			table.insert(argList, explictData.upRate)
			table.insert(argList, explictData.maxNum)
		end

		local value = formulaData.formula(unpack(argList)) or 0

		return value
	end

	return data.calcValue or 0
end

function CombatActionTool.canProcessCalcInfo(propId, onlyClientModifyAttributes, preModifyAttributes, isClientEnv)
	if onlyClientModifyAttributes[propId] then
		return isClientEnv
	end

	if not preModifyAttributes or preModifyAttributes[propId] then
		return true
	end

	return false
end

function CombatActionTool.getCalcInfo(calcInfo, calcInfoByLuaConfig, combatContext, overrideLevel, isMultiPlayerEnv, isSkipPostProcess)
	isSkipPostProcess = isSkipPostProcess or false

	local abilityMgr = pg.global.abilityMgr
	local calcInfoRuntime = abilityMgr.calcInfoTablePool:get(true)
	local combatAction = abilityMgr.combatAction
	local isClientEnv = Utils.checkClient()
	local onlyClientModifyAttributes = abilityMgr.actorAttributeModifier.OnlyClientModifyAttributes
	local preModifyAttributes = abilityMgr.actorAttributeModifier.ClientPreModifyAttributes

	if isClientEnv and isMultiPlayerEnv then
		preModifyAttributes = onlyClientModifyAttributes
	end

	if calcInfo then
		for k, v in pairs(calcInfo) do
			local propId = AttributeConst[k]

			if CombatActionTool.canProcessCalcInfo(propId, onlyClientModifyAttributes, preModifyAttributes, isClientEnv) then
				local value = v

				if Utils.isTable(v) then
					value = combatAction:doAction(v, combatContext)
				end

				if type(value) == "number" then
					calcInfoRuntime[k] = value
				end
			end
		end
	end

	if not ToBool(calcInfoByLuaConfig) or not CombatActionTool.ENABLE_CALC_INFO_BY_LUA_CONFIG then
		if not isSkipPostProcess then
			CombatActionTool.postProcessCalcInfo(calcInfoRuntime, calcInfo, combatContext)
		end

		return calcInfoRuntime
	end

	local calcType = calcInfoByLuaConfig.type
	local id = calcInfoByLuaConfig.id
	local level = 1
	local configData

	if calcType == AbilityConst.CALC_PARAM_TYPES.BUFF then
		level = overrideLevel or combatContext:buff() and combatContext:buff().buffData.level or 1
		configData = BuffCalcValueData
	elseif calcType == AbilityConst.CALC_PARAM_TYPES.ABILITY then
		local ability = CombatActionTool.getCasterAbility(combatContext)

		level = overrideLevel or ability and ability.abilityLevel or 1
		configData = AbilityCalcValData
	elseif calcType == AbilityConst.CALC_PARAM_TYPES.TIMELINE then
		configData = TimelineCalcValData
	else
		CombatActionTool.logError(combatContext, "not support calcType")

		if not isSkipPostProcess then
			CombatActionTool.postProcessCalcInfo(calcInfoRuntime, calcInfo, combatContext)
		end

		return calcInfoRuntime
	end

	local ownerEntity = CombatActionTool.getOwnerEntity(combatContext)
	local actorCombatAttribute = ownerEntity and ownerEntity.actorCombatAttribute
	local formulaByPetCachePropMap

	for attributeName, paramName in pairs(calcInfoByLuaConfig) do
		local propId = AttributeConst[attributeName]

		if propId then
			local data

			if calcType ~= AbilityConst.CALC_PARAM_TYPES.TIMELINE then
				data = ((configData[id] or EMPTY_TABLE)[paramName] or EMPTY_TABLE)[level]
			else
				data = (configData[id] or EMPTY_TABLE)[paramName]
			end

			if not data then
				CombatActionTool.logDebug(combatContext, "not found attribute value by lua config", id, paramName, level)
			elseif CombatActionTool.canProcessCalcInfo(propId, onlyClientModifyAttributes, preModifyAttributes, isClientEnv) then
				calcInfoRuntime[attributeName] = CombatActionTool.getCalcValue(data, actorCombatAttribute, combatContext)

				if data.formulaByPetCacheProp then
					formulaByPetCachePropMap = formulaByPetCachePropMap or {}
					formulaByPetCachePropMap[attributeName] = data
				end
			end
		end
	end

	local instantDmgRateVData
	local paramName = calcInfoByLuaConfig.instant_dmg_rate_v

	if paramName then
		if calcType ~= AbilityConst.CALC_PARAM_TYPES.TIMELINE then
			instantDmgRateVData = ((configData[id] or EMPTY_TABLE)[paramName] or EMPTY_TABLE)[level]
		else
			instantDmgRateVData = (configData[id] or EMPTY_TABLE)[paramName]
		end

		if instantDmgRateVData then
			calcInfoRuntime.reduce_cur_tp_rate = CombatActionTool.getCalcValue(instantDmgRateVData, actorCombatAttribute, combatContext)
		end
	end

	if not isSkipPostProcess then
		CombatActionTool.postProcessCalcInfo(calcInfoRuntime, calcInfo, combatContext)
	end

	return calcInfoRuntime, formulaByPetCachePropMap
end

function CombatActionTool.postProcessCalcInfo(calcInfoRuntime, calcInfoRaw, combatContext)
	local combatAction = pg.global.abilityMgr.combatAction
	local preModifyAttributes = pg.global.abilityMgr.actorAttributeModifier.ClientPreModifyAttributes

	if not calcInfoRuntime.reduce_cur_tp_rate then
		if not preModifyAttributes then
			calcInfoRuntime.reduce_cur_tp_rate = calcInfoRuntime.instant_dmg_rate_v
		else
			local instantDmgRataV = calcInfoRaw and calcInfoRaw.instant_dmg_rate_v

			if instantDmgRataV then
				local value = instantDmgRataV

				if Utils.isTable(value) then
					value = combatAction:doAction(value, combatContext)
				end

				if type(value) == "number" then
					calcInfoRuntime.reduce_cur_tp_rate = value
				end
			end
		end
	end

	for attributeName, val in pairs(calcInfoRuntime) do
		local propId = AttributeConst[attributeName]

		if propId >= AttributeConst.GROUP_BASE_SINGLE_PROCESS_BEGIN and propId <= AttributeConst.GROUP_BASE_SINGLE_PROCESS_END then
			calcInfoRuntime[attributeName] = ActorCombatAttribute.checkAttributeValue(propId, val)
		end
	end
end

function CombatActionTool.getParamByLuaConfig(calcType, calcId, paramName, combatContext, overrideLevel)
	local level = 1
	local configData
	local ownerEntity = CombatActionTool.getOwnerEntity(combatContext)
	local actorCombatAttribute = ownerEntity and ownerEntity.actorCombatAttribute

	if calcType == AbilityConst.CALC_PARAM_TYPES.BUFF then
		level = overrideLevel or combatContext:buff() and combatContext:buff().buffData.level or 1
		configData = BuffCalcValueData
	elseif calcType == AbilityConst.CALC_PARAM_TYPES.ABILITY then
		local ability = CombatActionTool.getCasterAbility(combatContext)

		level = overrideLevel or ability and ability.abilityLevel or 1
		configData = AbilityCalcValData
	elseif calcType == AbilityConst.CALC_PARAM_TYPES.TIMELINE then
		configData = TimelineCalcValData
	else
		CombatActionTool.logError(combatContext, "not support calcType")

		return 0
	end

	local dataInfo = configData[calcId] and configData[calcId][paramName]

	if calcType ~= AbilityConst.CALC_PARAM_TYPES.TIMELINE then
		return dataInfo and CombatActionTool.getCalcValue(dataInfo[level], actorCombatAttribute, combatContext) or 0
	else
		return dataInfo and CombatActionTool.getCalcValue(dataInfo, actorCombatAttribute, combatContext) or 0
	end
end

function CombatActionTool.applyIgnoreProcessAttributes(ownerEntity, attributes)
	if not ToBool(attributes) then
		return
	end

	for _, attributeName in ipairs(attributes) do
		local attributeId = AttributeConst[attributeName]

		if attributeId then
			ownerEntity.ignoreProcessAttributeMap[attributeId] = (ownerEntity.ignoreProcessAttributeMap[attributeId] or 0) + 1
		end
	end
end

function CombatActionTool.removeIgnoreProcessAttributes(ownerEntity, attributes)
	if not ToBool(attributes) then
		return
	end

	for _, attributeName in ipairs(attributes) do
		local attributeId = AttributeConst[attributeName]

		if attributeId then
			if ownerEntity.ignoreProcessAttributeMap[attributeId] == 1 then
				ownerEntity.ignoreProcessAttributeMap[attributeId] = nil
			else
				ownerEntity.ignoreProcessAttributeMap[attributeId] = ownerEntity.ignoreProcessAttributeMap[attributeId] - 1
			end
		end
	end
end

function CombatActionTool.getAttackElementType(attackData, combatContext)
	local attackDataElementType = attackData and attackData.elementType

	if attackDataElementType and attackData.forceOverrideElementType then
		return attackDataElementType
	end

	local elementType = 0
	local casterEntity = CombatActionTool.getCasterEnt(combatContext)

	if casterEntity and attackData and attackData.useCasterMainElement and casterEntity.mainElementType then
		elementType = casterEntity.mainElementType
	else
		elementType = pg.global.abilityMgr:getAbilityParamData(combatContext.abilityId, combatContext.buffTemplateId).elementType
	end

	if not elementType and attackDataElementType then
		elementType = attackDataElementType
	end

	elementType = elementType or 0

	return elementType
end

function CombatActionTool.getAttackEcsElementType(attackData, combatContext)
	local attackInfoEleType = CombatActionTool.getAttackElementType(attackData, combatContext)
	local transfer = ECSConst.ELEMENT_TYPE_2_ECS_ELEMENT

	if attackInfoEleType and transfer[attackInfoEleType] then
		return transfer[attackInfoEleType]
	end

	return ECSConst.ELEMENT_TYPE_NONE
end

function CombatActionTool.getAttackConditionType(attackData, combatContext)
	local attackInfoEleType = CombatActionTool.getAttackElementType(attackData, combatContext)
	local transfer = AbilityConst.ELEMENT_TYPE_2_CONDITION_TRANSFER

	if attackInfoEleType and transfer[attackInfoEleType] then
		return transfer[attackInfoEleType]
	end

	return AbilityConst.CONDITION_TYPE_NONE
end

function CombatActionTool.getChemElementId(actionData, combatContext)
	local chemElementId = ECSConst.ELEMENT_TYPE_NONE

	if actionData.needEcs ~= false then
		chemElementId = pg.global.abilityMgr:getEcsElement(combatContext.abilityId)

		if not chemElementId or chemElementId == ECSConst.ELEMENT_TYPE_NONE then
			local abilityTypeTemplate = pg.global.abilityMgr:getAbilityTemplate(combatContext.abilityId)
			local abilityType = abilityTypeTemplate and abilityTypeTemplate.abilityType
			local calcData = combatContext.nodeMap[actionData.calcResultNodeId]

			if abilityType ~= AbilityConst.EnumAbilityType.Attack and calcData and calcData.attackData then
				chemElementId = CombatActionTool.getAttackEcsElementType(calcData.attackData, combatContext)
			end
		end
	end

	return chemElementId
end

function CombatActionTool.getFinalCalcResultTarget(actionData, combatContext)
	local targetActorId = CombatActionTool.parseActorId(combatContext, actionData.target)

	if not actionData.attackData and combatContext.ctxType == AbilityConst.COMBAT_CONTEXT_TYPE_BUFF then
		while true do
			local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

			if not ownerEntity then
				break
			end

			if not ownerEntity.isDummyClone then
				break
			end

			if ownerEntity.actorId ~= targetActorId then
				break
			end

			local buff = combatContext:buff()

			if not buff then
				break
			end

			local tags = buff.buffTemplate.tags

			if not tags then
				break
			end

			if not Lume.find(tags, AbilityConst.BUFF_TAG_POSITIVE) then
				break
			end

			local masterEntity = ownerEntity:getMasterEntity()

			targetActorId = masterEntity and masterEntity.actorId or targetActorId

			CombatLogger.debug("CombatActionTool.getFinalCalcResultTarget transfer to masterEntity %d -> %d", ownerEntity.actorId, masterEntity.actorId, inspect())

			break
		end
	end

	return targetActorId
end

function CombatActionTool.getCombatContextById(combatContextId)
	if type(combatContextId) ~= "number" then
		return nil
	end

	local actorId = math.floor(combatContextId / 32768)
	local ent = pg.getEntityByActorId(actorId)

	if ent then
		return ent:getCombatContext(combatContextId)
	end

	return nil
end

function CombatActionTool.isBlockTriggerAbilityEvent(abilityId, ownerEntityActorId, actionData)
	if not ToBool(abilityId) then
		return false
	end

	local ownerEntity = pg.getEntityByActorId(ownerEntityActorId)

	if not ownerEntity then
		return false
	end

	local allowExploreAbility = actionData and ToBool(actionData.allowExploreAbility)

	if allowExploreAbility then
		return false
	end

	local ability = ownerEntity:getAbility(abilityId)
	local isExploreAbility = ability and ability:getAbilityTemplate().abilityType == AbilityConst.EnumAbilityType.Explore

	return isExploreAbility
end

function CombatActionTool.findFatherAbilityId(entity, abilityId)
	if not entity or not entity.abilityMap or not ToBool(abilityId) then
		return nil
	end

	local ability = entity.abilityMap[abilityId]

	if not ability or not ability.isSubAbility then
		return nil
	end

	local abilityMgr = pg.global.abilityMgr

	for parentId, parentAbility in pairs(entity.abilityMap) do
		if not parentAbility.isSubAbility then
			local parentTemplate = abilityMgr:getAbilityTemplate(parentId)

			if parentTemplate and parentTemplate.subAbilityIds then
				for _, subId in ipairs(parentTemplate.subAbilityIds) do
					if subId == abilityId then
						return parentId
					end
				end
			end
		end
	end

	return nil
end

function CombatActionTool.applyOffsetRotation(rot, offsetRot)
	if not offsetRot then
		return
	end

	local offsetRotX = offsetRot[1]
	local offsetRotY = offsetRot[2]
	local offsetRotZ = offsetRot[3]

	if offsetRotX ~= 0 then
		rot:MulUnitAngleAxisNoGC(offsetRotX, -1, 0, 0)
	end

	if offsetRotY ~= 0 then
		rot:MulUnitAngleAxisNoGC(offsetRotY, 0, 1, 0)
	end

	if offsetRotZ ~= 0 then
		rot:MulUnitAngleAxisNoGC(offsetRotZ, 0, 0, 1)
	end
end

return CombatActionTool
