-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\PetDispatch\\PetDispatchUtils.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local PetDispatchUtils = {}
local EventTaskData = require("Data.event_task_data")
local EventDispatchData = require("Data.event_pet_dispacth_data")
local CustomTriggerData = require("Data.custom_trigger_data")
local AbilityParamData = require("Data.ability_param_data")
local PetFormTypeData = require("Data.pet_form_type_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Utils = require("Common.Utils.Utils")
local TriggerUtils = require("Common.Utils.TriggerUtils")
local TriggerConst = require("Common.Const.TriggerConst")
local AbilityConst = require("Common.Const.AbilityConst")
local AddressDataConst = require("Const.AddressDataConst")
local UIConst = require("Const.UIConst")
local ActivityConst = require("Common.Const.ActivityConst")
local ClientActivityUtils = require("Utils.ClientActivityUtils")
local ActivityUtils = require("Common.Utils.ActivityUtils")

function PetDispatchUtils.getCurrentStageClues(eventPhase)
	local phaseData = EventDispatchData[eventPhase or 1]

	if not phaseData then
		return {}
	end

	local taskIds = phaseData.mapBlockDispatchTaskId or {}
	local mapBlockIds = phaseData.mapBlockId or {}
	local clueImages = phaseData.clueImage or {}
	local taskBackImages = phaseData.taskBackImage or {}
	local ret = {}

	for i = 1, 5 do
		ret[i] = {
			index = i,
			taskId = taskIds[i],
			mapBlockId = mapBlockIds[i],
			clueImage = clueImages[i],
			taskBackImage = taskBackImages[i],
			clueTaskGroupId = phaseData.clueTaskGroupId
		}
	end

	return ret
end

function PetDispatchUtils.getClueConfig(clueId)
	if not clueId then
		return nil
	end

	local taskConfig = EventTaskData[clueId]

	if not taskConfig then
		return nil
	end

	local clueImage, taskBackImage, mapBlockId, imageDesc

	for _, phaseData in pairs(EventDispatchData) do
		local taskIds = phaseData.mapBlockDispatchTaskId or {}

		for i, tid in ipairs(taskIds) do
			if tid == clueId then
				clueImage = (phaseData.clueImage or EMPTY_TABLE)[i]
				taskBackImage = (phaseData.taskBackImage or EMPTY_TABLE)[i]
				mapBlockId = (phaseData.mapBlockId or EMPTY_TABLE)[i]
				imageDesc = (phaseData.imageDesc or EMPTY_TABLE)[i]

				break
			end
		end

		if clueImage or taskBackImage then
			break
		end
	end

	return {
		taskId = clueId,
		eventTitle = taskConfig.eventTitle,
		taskDes = taskConfig.taskDes,
		awardDes = taskConfig.awardDes,
		mysteryAwardDes = taskConfig.mysteryAwardDes,
		extraAward = taskConfig.extraAward,
		extraAwardConditions = taskConfig.extraAwardConditions,
		groupId = taskConfig.groupId,
		clueImage = clueImage,
		taskBackImage = taskBackImage,
		mapBlockId = mapBlockId,
		imageDesc = imageDesc
	}
end

function PetDispatchUtils.getExtraConditions(clueId)
	local taskData = clueId and EventTaskData[clueId]
	local conditionIds = taskData and taskData.extraAwardConditions or {}
	local ret = {}

	for _, condId in ipairs(conditionIds) do
		ret[#ret + 1] = PetDispatchUtils.getConditionInfo(condId)
	end

	return ret
end

function PetDispatchUtils.calcRating(team, conditions)
	if not conditions or #conditions == 0 then
		return "B"
	end

	local hit = 0

	for _, cond in ipairs(conditions) do
		if PetDispatchUtils.isTeamMatchCondition(team, cond) then
			hit = hit + 1
		end
	end

	if hit >= #conditions then
		return "S"
	end

	if hit >= 1 then
		return "A"
	end

	return "B"
end

function PetDispatchUtils.getConditionInfo(condId)
	local customTriggerData = CustomTriggerData[condId]
	local conditionDatas = customTriggerData and customTriggerData.condition
	local conditionInfo = {}

	if not conditionDatas or not conditionDatas[1] then
		return conditionInfo
	end

	local triggerType = TriggerUtils.getTriggerType(conditionDatas[1])

	conditionInfo.type = triggerType
	conditionInfo.name = customTriggerData.note
	conditionInfo.condId = condId

	if triggerType == TriggerConst.PET_TRIGGER_TARGET_HAS_ELEMENT then
		local value = conditionDatas[1][3]

		conditionInfo.icon = value and AddressDataConst["FILTER_ELEMENT_" .. value]
		conditionInfo.value = value
	elseif triggerType == TriggerConst.PET_TRIGGER_CHECK_SCORE_STAGE then
		local value = conditionDatas[1][3]

		conditionInfo.icon = value and AddressDataConst["FILTER_EVENT_RATING" .. value]
		conditionInfo.value = value
	elseif triggerType == TriggerConst.PET_TRIGGER_TARGET_LAB then
		conditionInfo.value = conditionDatas[1][2]
		conditionInfo.value2 = conditionDatas[1][3]
	elseif triggerType == TriggerConst.PET_TRIGGER_TARGET_HAS_EXPLORE then
		local exploreId = conditionDatas[1][3]
		local skillInfo

		if exploreId and exploreId[1] == AbilityConst.SPECIFIC_ABILITY_INDEX_2_NAME[AbilityConst.SPECIFIC_ABILITY_INDEX_CLIMB] then
			skillInfo = AbilityParamData[9001006]
			conditionInfo.value = AbilityConst.SPECIFIC_ABILITY_INDEX_CLIMB
		elseif exploreId and exploreId[1] == AbilityConst.SPECIFIC_ABILITY_INDEX_2_NAME[AbilityConst.SPECIFIC_ABILITY_INDEX_GLIDE] then
			skillInfo = AbilityParamData[9001007]
			conditionInfo.value = AbilityConst.SPECIFIC_ABILITY_INDEX_GLIDE
		elseif exploreId and exploreId[1] == AbilityConst.SPECIFIC_ABILITY_INDEX_2_NAME[AbilityConst.SPECIFIC_ABILITY_INDEX_SWIM] then
			skillInfo = AbilityParamData[9001008]
			conditionInfo.value = AbilityConst.SPECIFIC_ABILITY_INDEX_SWIM
		end

		conditionInfo.icon = skillInfo and LuaUIUtils.getSkillIcon(skillInfo.icon)
	elseif triggerType == TriggerConst.PET_TRIGGER_TARGET_CP_VALUE then
		conditionInfo.value = conditionDatas[1][3]
	elseif triggerType == TriggerConst.PET_TRIGGER_TARGET_IS_FORM then
		local value = conditionDatas[1][3]

		conditionInfo.value = value

		local formType = PetFormTypeData[value]

		conditionInfo.icon = formType and formType.iconSmall
	end

	return conditionInfo
end

function PetDispatchUtils.isPetMatchCondition(pet, condition)
	if not pet or not condition then
		return false
	end

	local petInfo = pet.id and pg.me and pg.me:getPetInfo(pet.id) or pet

	if petInfo and petInfo.triggerMap and condition.condId then
		return petInfo.triggerMap:isCompleteOrMeetCondition(condition.condId)
	end

	return false
end

function PetDispatchUtils.isTeamMatchCondition(team, condition)
	for _, pet in ipairs(team or EMPTY_TABLE) do
		if PetDispatchUtils.isPetMatchCondition(pet, condition) then
			return true
		end
	end

	return false
end

function PetDispatchUtils.getDispatchProgress()
	local complete = 0

	for _, taskInfo in ipairs(ClientActivityUtils.getTaskInfoByActType(ActivityConst.EventType.PetDispatch)) do
		if taskInfo.taskType == ActivityConst.ActivityTaskType.PetDispatch_Dispatch then
			local state = taskInfo.taskState

			if state and state ~= ActivityConst.PetDispatchTaskSubState.UnFinished_Disptaching and state >= ActivityConst.TaskState.Finihed_CanRecv then
				complete = complete + 1
			end
		end
	end

	local activityData = pg.me and ActivityUtils.getActivityData(pg.me, ActivityConst.EventType.PetDispatch)
	local phaseData = activityData and EventDispatchData[activityData.eventPhase or 1]
	local allCnt = phaseData and phaseData.mapBlockDispatchTaskId and #phaseData.mapBlockDispatchTaskId or 0

	return complete, allCnt
end

function PetDispatchUtils.getStageScoreTarget(taskInfo)
	if not taskInfo or not taskInfo.taskCondition then
		return 0
	end

	local trigger = CustomTriggerData[taskInfo.taskCondition]
	local conds = trigger and trigger.condition
	local first = conds and conds[1]

	return first and first[5] or 0
end

function PetDispatchUtils.getStageScoreTaskInfos()
	local ret = {}

	for _, taskInfo in ipairs(ClientActivityUtils.getTaskInfoByActType(ActivityConst.EventType.PetDispatch)) do
		if taskInfo.taskType == ActivityConst.ActivityTaskType.PetDispatch_StageScore then
			ret[#ret + 1] = taskInfo
		end
	end

	table.sort(ret, function(a, b)
		return (a.taskId or 0) < (b.taskId or 0)
	end)

	return ret
end

function PetDispatchUtils.getDispatchTimeReduceRatio(team)
	local hasRainbow = false
	local hasShiny = false

	for _, pet in ipairs(team or EMPTY_TABLE) do
		local petInfo = pet

		if type(pet) == "number" and pg.me then
			petInfo = pg.me:getPetInfo(pet)
		elseif pet and pet.id and pg.me then
			petInfo = pg.me:getPetInfo(pet.id) or pet
		end

		if petInfo then
			hasShiny = hasShiny or Utils.isLabelShiny(petInfo.label)

			if petInfo.petPrototypeId then
				hasRainbow = hasRainbow or Utils.isAnyRainbowType(petInfo.petPrototypeId)
			elseif petInfo.templateId then
				hasRainbow = hasRainbow or Utils.isAnyRainbowTypeByTemplateId(petInfo.templateId)
			end
		end
	end

	return math.min((hasRainbow and 0.2 or 0) + (hasShiny and 0.1 or 0), 0.3)
end

function PetDispatchUtils.calcDispatchSeconds(baseSeconds, team)
	local reduce = PetDispatchUtils.getDispatchTimeReduceRatio(team)

	return math.floor(baseSeconds * (1 - reduce))
end

function PetDispatchUtils.listSelectablePets(clueId, filter, mode)
	mode = mode or "leader"

	local clueConfig = PetDispatchUtils.getClueConfig(clueId)
	local mapBlockId = clueConfig and clueConfig.mapBlockId
	local conditions = PetDispatchUtils.getExtraConditions(clueId) or {}
	local pets = pg.me and pg.me.pets or {}
	local ret = {}

	for _, pet in pairs(pets) do
		local data = LuaUIUtils.getDispatchPetInfo(pet)

		if PetDispatchUtils.isPetPassFilter(data, filter) then
			local dispatching = (data.activityDispatching or 0) > 0
			local outOfBlock = false

			if mode == "follower" and mapBlockId then
				outOfBlock = not LuaUIUtils.checkPetIsInBlockId(data.petPrototypeId, mapBlockId)
			end

			local matchCount = 0

			for _, cond in ipairs(conditions) do
				if PetDispatchUtils.isPetMatchCondition(data, cond) then
					matchCount = matchCount + 1
				end
			end

			data.dispatching = dispatching
			data.outOfBlock = outOfBlock
			data.matchCount = matchCount
			data.sortTier = PetDispatchUtils._petSortTier(data)
			data.recommendCount = PetDispatchUtils.getRecommendCount(data)
			ret[#ret + 1] = data
		end
	end

	table.sort(ret, function(a, b)
		if a.sortTier ~= b.sortTier then
			return a.sortTier > b.sortTier
		end

		if a.recommendCount ~= b.recommendCount then
			return a.recommendCount > b.recommendCount
		end

		return (a.id or 0) < (b.id or 0)
	end)

	return ret
end

function PetDispatchUtils.getAdventureRewardEntry(eventPhase, index)
	if not index or index <= 0 then
		return nil
	end

	local phaseData = EventDispatchData[eventPhase or 1]

	if not phaseData then
		return nil
	end

	local entries = phaseData.adventureReward or {}

	return entries[index]
end

function PetDispatchUtils.getAdventureRewardDropIds(eventPhase)
	local phaseData = EventDispatchData[eventPhase or 1]

	if not phaseData then
		return {}
	end

	local entries = phaseData.adventureReward or {}
	local dropIds = {}

	for _, entry in ipairs(entries) do
		if entry[1] and entry[2] then
			dropIds[#dropIds + 1] = entry[2]
		end
	end

	return dropIds
end

function PetDispatchUtils._petSortTier(data)
	if data.outOfBlock then
		return 0
	end

	if data.dispatching then
		return 1
	end

	local rainbow = data.isRainbow or data.isBlackRainbow or data.petPrototypeId and Utils.isAnyRainbowType(data.petPrototypeId)
	local shiny = data.isShiny or Utils.isLabelShiny(data.label)

	if rainbow and shiny then
		return 5
	end

	if rainbow then
		return 4
	end

	if shiny then
		return 3
	end

	return 2
end

function PetDispatchUtils.getRecommendCount(data)
	local count = data.matchCount or 0
	local rainbow = data.isRainbow or data.isBlackRainbow or data.petPrototypeId and Utils.isAnyRainbowType(data.petPrototypeId)
	local shiny = data.isShiny or Utils.isLabelShiny(data.label)

	if rainbow then
		count = count + 1
	end

	if shiny then
		count = count + 1
	end

	return count
end

local ElementNameToId = require("Data.element_name_to_id")

local function buildSelectedFormTypeMap(filter)
	local map = {}
	local has = false

	for key, value in pairs(filter) do
		if value == true and type(key) == "string" then
			local formTypeId = string.match(key, "^isForm(%d+)$")

			if formTypeId then
				local id = tonumber(formTypeId)

				map[id] = true
				has = true

				for childId, childData in pairs(PetFormTypeData) do
					if childData.belong == id then
						map[childId] = true
					end
				end
			end
		end
	end

	return map, has
end

function PetDispatchUtils.isPetPassFilter(data, filter)
	if not filter then
		return true
	end

	local keyword = filter.keyword or ""

	if keyword ~= "" then
		local displayName = string.split(pg.getLocalizationText(data.name or ""), "<")[1]

		if not string.find(displayName, keyword, 1, true) then
			return false
		end
	end

	if filter.isNormal or filter.isShiny or filter.isBoss or filter.isRainbow or filter.isDark then
		local petIsRainbow = data.isRainbow or data.isBlackRainbow
		local petIsNormal = not data.isShiny and not data.isBoss and not petIsRainbow and not data.isDark
		local pass = filter.isNormal and petIsNormal or filter.isShiny and data.isShiny or filter.isBoss and data.isBoss or filter.isRainbow and petIsRainbow or filter.isDark and data.isDark

		if not pass then
			return false
		end
	end

	if filter.elements and next(filter.elements) ~= nil then
		if not data.elementIds then
			return false
		end

		local matched = false

		for name in pairs(filter.elements) do
			local id = ElementNameToId[name]

			if id then
				for _, elementId in ipairs(data.elementIds) do
					if elementId == id then
						matched = true

						break
					end
				end
			end

			if matched then
				break
			end
		end

		if not matched then
			return false
		end
	end

	if (filter.isRating1 or filter.isRating2 or filter.isRating3 or filter.isRating4) and not filter["isRating" .. tostring((data.rating or 0) + 1)] then
		return false
	end

	if filter.isDPS or filter.isSup or filter.isHeal or filter.isBreak or filter.isEnergy then
		local t = data.petType
		local pass = filter.isDPS and Utils.isMatchPetFuncType(t, UIConst.NEW_PET_BATTLE_TYPE.DPS) or filter.isSup and Utils.isMatchPetFuncType(t, UIConst.NEW_PET_BATTLE_TYPE.SUP) or filter.isHeal and Utils.isMatchPetFuncType(t, UIConst.NEW_PET_BATTLE_TYPE.HEAL) or filter.isBreak and Utils.isMatchPetFuncType(t, UIConst.NEW_PET_BATTLE_TYPE.BREAK) or filter.isEnergy and Utils.isMatchPetFuncType(t, UIConst.NEW_PET_BATTLE_TYPE.ENERGY)

		if not pass then
			return false
		end
	end

	local favOn = false

	for i = 1, 10 do
		if filter["isFavoriteType" .. i] then
			favOn = true

			break
		end
	end

	if favOn and not filter["isFavoriteType" .. (data.favoriteType or 1)] then
		return false
	end

	if filter.isInBattle or filter.isNotInBattle or filter.isInExplore or filter.isInHomeland then
		local inBattle = data.inBattle
		local pass = filter.isInBattle and inBattle or filter.isNotInBattle and not inBattle or filter.isInExplore and data.inExplore or filter.isInHomeland and data.isPutInHomeland

		if not pass then
			return false
		end
	end

	if filter.isRareFeature or filter.isNotRareFeature then
		local isRare = (data.hasRareFeature or 0) == 1
		local pass = filter.isRareFeature and isRare or filter.isNotRareFeature and not isRare

		if not pass then
			return false
		end
	end

	local selectedFormTypeMap, hasSelectedForm = buildSelectedFormTypeMap(filter)

	if hasSelectedForm and not selectedFormTypeMap[data.formTypeId or 0] then
		return false
	end

	return true
end

function PetDispatchUtils.getSerendipityConfig(serendipityType)
	return nil
end

return PetDispatchUtils
