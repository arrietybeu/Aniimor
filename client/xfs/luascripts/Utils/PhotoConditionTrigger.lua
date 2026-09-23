-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\PhotoConditionTrigger.lua

local FrontCondition = require("Data.front_condition_data")
local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local PlayableConst = require("Common.Const.PlayableConst")
local PetBasePrototypeToPrototype = require("Data.pet_base_prototype_to_prototype_map")
local PhotoConditionTrigger = {}
local AIUtils = require("Common.Utils.AIUtils")
local Utils = require("Common.Utils.Utils")
local Operations = {
	"<",
	"<=",
	"=",
	">=",
	">"
}

function PhotoConditionTrigger.checkCondition(entity, conditions)
	if conditions == nil then
		return true
	end

	local totalCount = 0
	local passCount = 0

	for _, value in pairs(conditions) do
		totalCount = totalCount + 1

		if not FrontCondition[value] then
			return false
		end

		local condition = FrontCondition[value].condition
		local conditionExpression = FrontCondition[value].conditionExpression
		local temp = {}

		for _, tag in ipairs(conditionExpression) do
			temp[tag] = false
		end

		for index, v in pairs(condition) do
			local pass = false
			local conditionType = v[1]
			local conditionArg1 = v[2]
			local conditionArg2 = v[3]
			local conditionOperation = v[4] or Operations[4]

			if conditionType == "PLAY_ANIMATION" and PhotoConditionTrigger.checkPlayAnimation(entity, conditionArg1, conditionArg2, conditionOperation) then
				pass = true
			elseif conditionType == "PET_PROP" and PhotoConditionTrigger.checkPetProp(entity, conditionArg1, conditionArg2, conditionOperation) then
				pass = true
			elseif conditionType == "PLAY_TIMELINE" and PhotoConditionTrigger.checkPlayTimeline(entity, conditionArg1, conditionArg2, conditionOperation) then
				pass = true
			elseif conditionType == "CHAT_BUBBLE" and PhotoConditionTrigger.checkChatBubble(entity, conditionArg1, conditionArg2, conditionOperation) then
				pass = true
			elseif conditionType == "STP_FUNNY" and PhotoConditionTrigger.checkStpFunny(entity, conditionArg1, conditionArg2, conditionOperation) then
				pass = true
			elseif conditionType == "HAVE_BUFF" and PhotoConditionTrigger.checkHaveBuff(entity, conditionArg1, conditionArg2, conditionOperation) then
				pass = true
			elseif conditionType == "BEHAVIOUR_ID" and PhotoConditionTrigger.checkPetBehaviourId(entity, conditionArg1, conditionArg2, conditionOperation) then
				pass = true
			elseif conditionType == "ROTUE_ID" and PhotoConditionTrigger.checkPetRotueId(entity, conditionArg1, conditionArg2, conditionOperation) then
				pass = true
			elseif conditionType == "TIME_STATE" and PhotoConditionTrigger.checkTimeState(entity, conditionArg1, conditionArg2, conditionOperation) then
				pass = true
			elseif conditionType == "HAS_ENTITY_TAG" and PhotoConditionTrigger.checkHasEntityTag(entity, conditionArg1, conditionArg2, conditionOperation) then
				pass = true
			elseif conditionType == "HAS_PET_BASE" and PhotoConditionTrigger.checkHasPetBase(entity, conditionArg1, conditionArg2, conditionOperation) then
				pass = true
			end

			temp[conditionExpression[index]] = temp[conditionExpression[index]] or pass
		end

		local pass = true

		for _, value in ipairs(temp) do
			pass = pass and value
		end

		if pass then
			passCount = passCount + 1
		end
	end

	return passCount == totalCount
end

function PhotoConditionTrigger.checkHasEntityTag(entity, conditionArg1, conditionArg2, conditionOperation)
	return Utils.hasEntityTag(entity, conditionArg1[1])
end

function PhotoConditionTrigger.checkHasPetBase(entity, conditionArg1, conditionArg2, conditionOperation)
	local playerHandBookMap = pg.me.petHandbookMap or {}
	local petPrototypeIds = PetBasePrototypeToPrototype[conditionArg1[1]] or {}

	for _, petPrototypeId in ipairs(petPrototypeIds) do
		local petHandbookInfo = playerHandBookMap[petPrototypeId]

		if petHandbookInfo and petHandbookInfo:isCatched() then
			return true
		end
	end

	return false
end

function PhotoConditionTrigger.checkPetBehaviourId(entity, conditionArg1, conditionArg2, conditionOperation)
	return AIUtils.getEntityCurrentBehaviourID(entity) == conditionArg1[1]
end

function PhotoConditionTrigger.checkPetRotueId(entity, conditionArg1, conditionArg2, conditionOperation)
	return AIUtils.getEntityCurrentRouteID(entity) == conditionArg1[1]
end

function PhotoConditionTrigger.checkHaveBuff(entity, conditionArg1, conditionArg2, conditionOperation)
	local buff = entity.actorBuff:findOneBuffByTemplateId(conditionArg1[1])

	return buff ~= nil
end

function PhotoConditionTrigger.checkTimeState(entity, conditionArg1, conditionArg2, conditionOperation)
	return pg.timePeriod == conditionArg1[1]
end

function PhotoConditionTrigger.checkPlayAnimation(entity, conditionArg1, conditionArg2, conditionOperation)
	local curAniKey = entity.animKey

	if ToBool(entity.fullBodyLowPriorityAnimKey) then
		curAniKey = entity.fullBodyLowPriorityAnimKey
	end

	if ToBool(entity.fullBodyAnimKey) then
		curAniKey = entity.fullBodyAnimKey
	end

	return PlayableConst[conditionArg1[1]] == curAniKey
end

function PhotoConditionTrigger.checkPetProp(entity, conditionArg1, conditionArg2, conditionOperation)
	conditionArg1 = conditionArg1[1]

	if conditionArg1 == "weight" then
		local weight = entity.weight

		if conditionOperation == Operations[1] then
			return weight < conditionArg2
		elseif conditionOperation == Operations[2] then
			return weight <= conditionArg2
		elseif conditionOperation == Operations[3] then
			return weight == conditionArg2
		elseif conditionOperation == Operations[4] then
			return conditionArg2 <= weight
		elseif conditionOperation == Operations[5] then
			return conditionArg2 < weight
		else
			return true
		end
	elseif conditionArg1 == "label" then
		return entity.label == conditionArg2[1]
	else
		return true
	end
end

function PhotoConditionTrigger.checkPlayTimeline(entity, conditionArg1, conditionArg2, conditionOperation)
	return false
end

function PhotoConditionTrigger.checkChatBubble(entity, conditionArg1, conditionArg2, conditionOperation)
	return false
end

function PhotoConditionTrigger.checkStpFunny(entity, stpState, stpId)
	return false
end

return PhotoConditionTrigger
