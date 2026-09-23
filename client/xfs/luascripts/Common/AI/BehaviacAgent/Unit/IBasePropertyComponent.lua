-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\BehaviacAgent\\Unit\\IBasePropertyComponent.lua

local Class = require("Core.Framework.Class")
local SceneUtils = require("Common.Utils.SceneUtils")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local AiConst = require("Common.Const.AiConst")
local PuppetData = require("Data.puppet_data")
local sysConfigData = require("Data.sys_config_data")
local Utils = require("Common.Utils.Utils")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local ResPointUtils = require("Common.Utils.ResPointUtils")
local ListPool = require("Common.Container.ListPool")
local lume = require("Core.Common.lume")
local math_random = math.random
local string_isNilOrEmpty = string.isNilOrEmpty
local string_notNilOrEmpty = string.notNilOrEmpty
local table_clearArray = table.clearArray
local ipairs = ipairs
local IBasePropertyComponent = Class.Component("IBasePropertyComponent")

function IBasePropertyComponent:getAIBlackboardValue(actorId, blackboardName)
	actorId = actorId == 0 and self.ent.actorId or actorId

	local ent = pg.getEntityByActorId(actorId)

	if ent and ent.agent then
		return ent.agent:getBlackBoardProperty(blackboardName)
	end
end

function IBasePropertyComponent:getAnimTagDuration(actorId)
	actorId = actorId == 0 and self.ent.actorId or actorId

	local ent = pg.getEntityByActorId(actorId)

	if ent and ent.getCurrentTagDuration then
		return ent:getCurrentTagDuration()
	end

	return 0
end

function IBasePropertyComponent:getAuthorityPlayer()
	return Utils.getAuthorityPlayerActorId(self.ent)
end

function IBasePropertyComponent:getAuthorityPlayerPet()
	local playerActorId = Utils.getAuthorityPlayerActorId(self.ent)
	local authorityPlayer = pg.getEntityByActorId(playerActorId)

	if authorityPlayer then
		local pet = authorityPlayer:getCurPetEntity()

		if not pet then
			return 0
		end

		return pet.actorId
	else
		return 0
	end
end

function IBasePropertyComponent:getBornState()
	if Utils.isCreatePlenty(self.ent) then
		local emergenceOverrideData = Utils.getPuppetEmergenceOverrideData()

		if emergenceOverrideData and string.notNilOrEmpty(emergenceOverrideData.bornState) then
			return emergenceOverrideData.bornState
		end
	end

	local sceneEntityData = SceneUtils.getSceneEntityData(self.ent.space.sceneId, self.ent.space.id)
	local tEntityData = sceneEntityData[self.ent.staticId]

	if tEntityData and tEntityData.spawnerBornState then
		return tEntityData.spawnerBornState
	end

	local puppetData = PuppetData[self.ent.templateId]

	if puppetData and puppetData.bornState then
		return puppetData.bornState
	end

	return CharacterStateConst[CharacterStateConst.LOCOMOTION].name
end

function IBasePropertyComponent:getDayTime()
	if Utils.checkClient() then
		local worldDayTime = pg.space:getTimePeriod()

		return AiConst.WorldDayTime2AIDayTime[worldDayTime] or AiConst.AIDayTimeType.None
	elseif self.ent.space then
		local worldDayTime = self.ent.space.timePeriod

		return AiConst.WorldDayTime2AIDayTime[worldDayTime] or AiConst.AIDayTimeType.None
	end

	return 0
end

function IBasePropertyComponent:getEntConfigData(actorId, propertyName)
	actorId = actorId == 0 and self.ent.actorId or actorId

	local ent = pg.getEntityByActorId(actorId)

	if ent and ent.getConfigData then
		local configData = ent:getConfigData()

		return configData and configData[propertyName]
	end
end

function IBasePropertyComponent:getEntPosition(actorId)
	actorId = actorId == 0 and self.ent.actorId or actorId

	local ent = pg.getEntityByActorId(actorId)

	if ent then
		return ent:getPosition()
	end

	return Vector3.constZero
end

function IBasePropertyComponent:getEntProperty(actorId, propertyName)
	actorId = actorId == 0 and self.ent.actorId or actorId

	local ent = pg.getEntityByActorId(actorId)

	if ent then
		return ent[propertyName]
	end
end

function IBasePropertyComponent:getForbidFollowMasterCharStateList()
	return sysConfigData.forbidFollowMasterCharStateList
end

function IBasePropertyComponent:getGameTime()
	return self.ent:getGameTime()
end

function IBasePropertyComponent:getId(idName)
	local id = self.ent[idName]
	local ent = pg.getEntity(id)

	return ent and ent.actorId or 0
end

function IBasePropertyComponent:getLeaderId(actorId)
	actorId = actorId == 0 and self.ent.actorId or actorId

	local ent = pg.getEntityByActorId(actorId)

	if ent then
		local leader = pg.getEntity(ent.spawnerLeaderId)

		return leader and leader.actorId or 0
	end

	return 0
end

function IBasePropertyComponent:getPartnerIds(actorId)
	local ret = self:getBlackBoardProperty("partnerIds") or {}

	table_clearArray(ret)

	actorId = actorId == 0 and self.ent.actorId or actorId

	local ent = pg.getEntityByActorId(actorId)

	if ent and ent.spawnerPartnerIds then
		for _, id in ipairs(ent.spawnerPartnerIds) do
			local partner = pg.getEntity(id)

			if partner then
				ret[#ret + 1] = partner.actorId
			end
		end
	end

	return ret
end

function IBasePropertyComponent:getLogicState(stateName)
	return stateName
end

function IBasePropertyComponent:getPerceptibilityTable()
	if self.ent.getPerceivedMap then
		return self.ent:getPerceivedMap()
	end

	return AiConst.DefaultNullTable
end

function IBasePropertyComponent:getPerceptibilityValue(actorId)
	if self.ent.getPerceivedValue then
		return self.ent:getPerceivedValue(actorId)
	end

	return 0
end

function IBasePropertyComponent:getPetData(actorId, dataKey, safeGet, defaultValue)
	actorId = actorId == 0 and self.ent.actorId or actorId

	local ent = pg.getEntityByActorId(actorId)
	local ret

	if ent and ent.templateId then
		local configData = ent:getConfigData()

		ret = configData and configData[dataKey]
	end

	if safeGet and ret == nil then
		ret = defaultValue
	end

	return ret
end

function IBasePropertyComponent:getPetLockedId()
	if self.ent.getLockedActorId then
		return self.ent:getLockedActorId()
	end

	return 0
end

function IBasePropertyComponent:getPuppetData(actorId, dataKey, safeGet, defaultValue)
	actorId = actorId == 0 and self.ent.actorId or actorId

	local ent = pg.getEntityByActorId(actorId)
	local ret

	if ent and ent.templateId then
		if dataKey == "id" then
			ret = ent.templateId
		else
			ret = PuppetData[ent.templateId] and PuppetData[ent.templateId][dataKey]
		end
	end

	if safeGet and ret == nil then
		ret = defaultValue
	end

	return ret
end

function IBasePropertyComponent:getSelfId()
	return self.ent.actorId
end

function IBasePropertyComponent:getSkillProperty(skillId, propertyName)
	local abilityData = pg.global.abilityMgr:getAbilityTemplate(skillId)

	if abilityData then
		return abilityData[propertyName]
	end
end

function IBasePropertyComponent:getSkillType(abilityId)
	local abilityParamId = AbilityUtils.getAbilityParamId(abilityId)
	local skillType = AbilityUtils.getAbilityParamSkillType(abilityParamId)

	return skillType or -1
end

function IBasePropertyComponent._checkRouteDayTime(routeDayTag, setDayTime)
	if routeDayTag and routeDayTag > 0 and setDayTime and setDayTime > 0 and routeDayTag ~= setDayTime then
		return false
	end

	return true
end

function IBasePropertyComponent._checkRouteOtherTag(routeOtherTags, setOtherTag1, setOtherTag2, setOtherTag3)
	if string_notNilOrEmpty(setOtherTag1) and not lume.findInList(routeOtherTags, setOtherTag1) then
		return false
	end

	if string_notNilOrEmpty(setOtherTag2) and not lume.findInList(routeOtherTags, setOtherTag2) then
		return false
	end

	if string_notNilOrEmpty(setOtherTag3) and not lume.findInList(routeOtherTags, setOtherTag3) then
		return false
	end

	return true
end

function IBasePropertyComponent._checkRouteEntityTag(routeEntityTags, entityOrEntityTag)
	if not routeEntityTags or #routeEntityTags == 0 or not entityOrEntityTag then
		return true
	end

	if type(entityOrEntityTag) == "string" then
		local entityTag = entityOrEntityTag

		return lume.findInList(routeEntityTags, entityTag)
	end

	local entity = entityOrEntityTag

	return Utils.hasAnyEntityTag(entity, routeEntityTags)
end

function IBasePropertyComponent._checkRouteWeatherId(routeWeatherList, weatherId)
	if not routeWeatherList or #routeWeatherList == 0 then
		return true
	end

	if weatherId ~= 0 then
		return lume.findInList(routeWeatherList, weatherId)
	end

	return false
end

function IBasePropertyComponent._checkRouteMeteorologyId(routeMeteorologyList, meteorologyId)
	if not routeMeteorologyList or #routeMeteorologyList == 0 then
		return true
	end

	if meteorologyId ~= 0 then
		return lume.findInList(routeMeteorologyList, meteorologyId)
	end

	return false
end

function IBasePropertyComponent._getValidWeight(weight)
	if not weight or weight <= 0 then
		weight = 1
	end

	return weight
end

function IBasePropertyComponent:getRouteIdFromEntitySimple(actorId)
	local dayTime = self:getDayTime()
	local weatherId = self:getCurWeatherId(0)
	local meteorologyId = self:getCurMeteorologyId(0)

	return self:getRouteIdFromEntity(actorId, dayTime, weatherId, meteorologyId, self.ent)
end

function IBasePropertyComponent:getRouteIdFromEntity(actorId, dayTime, weatherId, meteorologyId, entityOrEntityTag, otherTag1, otherTag2, otherTag3)
	local ent = actorId == 0 and self.ent or pg.getEntityByActorId(actorId)
	local routeRefList = ent:getPatrolRouteRefList()

	for _, routeRef in ipairs(routeRefList) do
		if IBasePropertyComponent._checkRouteDayTime(routeRef.dayTag, dayTime) and IBasePropertyComponent._checkRouteWeatherId(routeRef.weatherIds, weatherId) and IBasePropertyComponent._checkRouteMeteorologyId(routeRef.meteorologyIds, meteorologyId) and IBasePropertyComponent._checkRouteEntityTag(routeRef.entityTagRoute, entityOrEntityTag) and IBasePropertyComponent._checkRouteOtherTag(routeRef.otherTags, otherTag1, otherTag2, otherTag3) then
			local routeIdSets = routeRef.routeGroup or AiConst.DefaultNullTable

			if #routeIdSets > 1 then
				local totalWeight = 0

				for _, routeIdSet in ipairs(routeIdSets) do
					totalWeight = totalWeight + IBasePropertyComponent._getValidWeight(routeIdSet.weight)
				end

				local randomWeight = math_random(1, totalWeight)
				local currentWeight = 0

				for _, routeIdSet in ipairs(routeIdSets) do
					currentWeight = currentWeight + IBasePropertyComponent._getValidWeight(routeIdSet.weight)

					if randomWeight <= currentWeight then
						return routeIdSet.routeId or 0
					end
				end
			elseif #routeIdSets == 1 then
				return routeIdSets[1].routeId or 0
			else
				return 0
			end
		end
	end

	if string_isNilOrEmpty(otherTag1) and string_isNilOrEmpty(otherTag2) and string_isNilOrEmpty(otherTag3) then
		return ent.routeId or 0
	end

	return 0
end

function IBasePropertyComponent:getRouteIdFromResPoint(getWithIndex, fixPointId, index)
	local actorId, pointId = ResPointUtils.FromFixPointId(fixPointId)

	if getWithIndex then
		return ResPointUtils.GetRouteIdFromResPointWithIndex(actorId, pointId, index)
	else
		return ResPointUtils.GetRouteIdFromResPoint(actorId, pointId)
	end
end

function IBasePropertyComponent:checkRouteIdIsValidSimple(routeId, actorId)
	local dayTime = self:getDayTime()
	local weatherId = self:getCurWeatherId(0)
	local meteorologyId = self:getCurMeteorologyId(0)

	return self:checkRouteIdIsValid(routeId, actorId, dayTime, weatherId, meteorologyId, self.ent)
end

function IBasePropertyComponent:checkRouteIdIsValid(routeId, actorId, dayTime, weatherId, meteorologyId, entityOrEntityTag, otherTag1, otherTag2, otherTag3)
	local ent = actorId == 0 and self.ent or pg.getEntityByActorId(actorId)
	local routeRefList = ent:getPatrolRouteRefList()

	for _, routeRef in ipairs(routeRefList) do
		if IBasePropertyComponent._checkRouteDayTime(routeRef.dayTag, dayTime) and IBasePropertyComponent._checkRouteWeatherId(routeRef.weatherIds, weatherId) and IBasePropertyComponent._checkRouteMeteorologyId(routeRef.meteorologyIds, meteorologyId) and IBasePropertyComponent._checkRouteEntityTag(routeRef.entityTagRoute, entityOrEntityTag) and IBasePropertyComponent._checkRouteOtherTag(routeRef.otherTags, otherTag1, otherTag2, otherTag3) then
			local routeIdSets = routeRef.routeGroup or AiConst.DefaultNullTable

			for _, routeIdSet in ipairs(routeIdSets) do
				if routeIdSet.routeId == routeId then
					return true
				end
			end
		end
	end

	if string_isNilOrEmpty(otherTag1) and string_isNilOrEmpty(otherTag2) and string_isNilOrEmpty(otherTag3) and ent.routeId == routeId then
		return true
	end

	return false
end

return IBasePropertyComponent
