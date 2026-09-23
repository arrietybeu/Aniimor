-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Utils\\VirtualEntUtils.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local IdManager = require("Core.Common.IDManager")
local AttributeConst = require("Common.Const.AttributeConst")
local Ability = require("CustomTypes.Ability")
local AbilityConst = require("Common.Const.AbilityConst")
local Const = require("Common.Const.Const")
local VirtualEntUtils = Class.OldLightClass("VirtualEntUtils", nil, true)

function VirtualEntUtils:ctor()
	self.actorId = 0
end

function VirtualEntUtils.getNewVirtualEntActorId()
	local singleton = VirtualEntUtils.GetInstance()

	singleton.actorId = singleton.actorId - 1

	return singleton.actorId
end

function VirtualEntUtils.getNewVirtualEntityId()
	return IdManager.genB64ID()
end

function VirtualEntUtils.setDefaultAbility(entity, dict)
	entity.buffDataList = dict.buffDataList or {}
	entity.baseAttr = dict.baseAttr or VirtualEntUtils.getVirtualDefaultAttribute()
	entity.attrEntrysMap = dict.attrEntries or {}
	entity.breakRecoverTime = 0
	entity.buffTag = 0
	entity.buffImmuneTag = 0
	entity.knockState = 0
	entity.shieldDataList = {}
	entity.abilityMap = {}
	entity.stolenAbilityRef = {}
	entity.stolenAbilityMap = {}

	for _, value in pairs(dict.abilityMap or EMPTY_TABLE) do
		VirtualEntUtils.createDefaultAbility(entity, value.abilityId, value.abilityLv, value.cdEndTime, value.isSubAbility or false)
	end
end

function VirtualEntUtils.createDefaultAbility(entity, abilityId, abilityLevel, cdEndTime, isSubAbility)
	if not pg.global.abilityMgr:isValidAbility(abilityId) then
		entity.logger:error("@cyj ability id is not in ability_base_data", abilityId)

		return false
	end

	if abilityLevel > AbilityConst.MAX_ABILITY_LEVEL then
		entity.logger:error("ability level is too large", abilityLevel)

		return false
	end

	local abilityLevelTemplate = pg.global.abilityMgr:getAbilityTemplate(abilityId, abilityLevel)

	if abilityLevelTemplate == nil then
		return false
	end

	local ability = entity:getAbility(abilityId)

	if ability == nil then
		ability = Ability({
			abilityId = abilityId,
			abilityLevel = abilityLevel,
			isSubAbility = isSubAbility,
			cdEndTime = cdEndTime,
			combatContextId = entity:genCombatContextId()
		})

		ability:initAbility(entity.actorId)

		entity.abilityMap[abilityId] = ability

		entity.logger:debug("initAbility", abilityId)
	else
		entity.logger:debug("refresh Ability", abilityId)
		ability:initAbility(entity.actorId)
		ability:refresh(abilityId, abilityLevel, isSubAbility, cdEndTime)
	end

	local abilitySubAbilityIds = abilityLevelTemplate.subAbilityIds

	if abilitySubAbilityIds then
		for _, subAbilityId in ipairs(abilitySubAbilityIds) do
			if subAbilityId == abilityId then
				entity.logger:error("dumplicate sub ability id", abilityId)

				break
			end

			VirtualEntUtils.createDefaultAbility(entity, subAbilityId, abilityLevel, cdEndTime, true)
		end
	end

	ability:onAbilityAdded()

	return true
end

function VirtualEntUtils.getVirtualDefaultAttribute()
	local defaultAttribute = {}

	for attributeId = AttributeConst.GROUP_BEGIN, AttributeConst.GROUP_END do
		defaultAttribute[attributeId] = 0
	end

	return defaultAttribute
end

function VirtualEntUtils.setDefaultCombat(entity, dict)
	entity.life = Const.LIFE_ALIVE
end

return VirtualEntUtils
