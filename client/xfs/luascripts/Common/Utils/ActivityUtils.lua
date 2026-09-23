-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Utils\\ActivityUtils.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Time = require("Core.Common.Time")
local Const = require("Common.Const.Const")
local TimeUtils = require("Common.Utils.TimeUtils")
local ActivityConst = require("Common.Const.ActivityConst")
local Utils = require("Common.Utils.Utils")
local ItemUtils = require("Common.Utils.ItemUtils")
local GameEventData = require("Data.game_event_data")
local GameEventTypePostData = require("Data.game_event_type_post_data")
local PetResearchCatchData = require("Data.pet_research_catch_data")
local PetResearchTrackData = require("Data.pet_research_track_data")
local PetResearchPhotoData = require("Data.pet_research_photo_data")
local EventCatchRogueData = require("Data.event_catch_rogue_data")
local FishingCaptureActivityData = require("Data.fishing_capture_activity_data")
local PetPrototypeData = require("Data.pet_prototype_data")
local EnergyMatchAccessoriesData = require("Data.energy_match_accessories_data")
local AppearanceJewelryPetData = require("Data.appearance_jewelry_pet_data")
local ItemData = require("Data.item_data")
local SysConfigData = require("Data.sys_config_data")
local ItemConst = require("Common.Const.ItemConst")
local EventArkCarnData = require("Data.event_ark_carn_data")
local EventTaskMapActType = require("Data.event_task_map_acttype_data")
local EventTaskMapGroupData = require("Data.event_task_map_group_data")
local EventTaskGroupMapActId = require("Data.event_task_group_map_actid_data")
local EnergyMatchThemeData = require("Data.energy_match_theme_data")
local CommonSwitch = require("Common.CommonSwitch")
local GameEventTypeData = require("Data.game_event_type_data")
local LoggerManager = require("Core.Log.LoggerManager")
local logger = LoggerManager.getLogger("ActivityUtils")
local TriggerConst = require("Common.Const.TriggerConst")
local EventGuidePreheat = require("Data.event_guide_preheat")
local EventGuidePreheatType = require("Data.event_guide_preheat_type")
local EventCommonGuideData = require("Data.event_common_guide_data")
local EventTaskData = require("Data.event_task_data")
local ActivateTasksData = require("Data.activate_tasks_data")
local lume = require("Core.Common.lume")
local NoticeDef = require("Common.NoticeDef")
local EventTaskMapGroupTypeData = require("Data.event_task_map_group_type_data")
local ActivityUtils = {}

function ActivityUtils.getActivityStageInfo()
	if pg.component == "client" then
		return pg.me and pg.me.activityStageInfo
	else
		local agent = require("Globals").activitySyncAgent

		return agent and agent:getActivityStageInfo()
	end
end

function ActivityUtils.getOprActivityUnlockCond(activityId, player)
	if pg.component == "client" then
		player = player or pg.me
	end

	if not player then
		return false
	end

	local actData = GameEventData[activityId]

	if not actData then
		return false
	end

	local customTriggerId = actData.conditions or 0

	if pg.component == "client" then
		if customTriggerId == 0 then
			return true
		end
	elseif customTriggerId == 0 or actData.eventType == ActivityConst.EventType.FishingCapture then
		return true
	end

	return player.triggerMap:isCompleteOrMeetCondition(customTriggerId) or false
end

function ActivityUtils.isOprActivityTabOpen(activityId, player, ignoreCond)
	local eventData = GameEventData[activityId]

	if not eventData or eventData.switch ~= 1 then
		return false
	end

	local actType = eventData.eventType

	if not actType then
		return false
	end

	if not ActivityUtils.curArenaIsActivateOpen(actType) then
		return false
	end

	local stageInfo = ActivityUtils.getActivityStageInfo()
	local stage = stageInfo and stageInfo[activityId]

	if pg.component == "client" then
		player = player or pg.me
	end

	if player then
		local activity = ActivityUtils.getActivityData(player, actType)
		local activityCanTabOpen = true

		if activity and activity.canTabOpen and type(activity.canTabOpen) == "function" then
			local eventTimeCfg = Utils.getEventTimeConfig(activityId) or {}
			local startTime = eventTimeCfg.tabStartDayTime or 0
			local endTime = eventTimeCfg.tabEndDayTime or 0

			activityCanTabOpen = activity:canTabOpen(startTime, endTime)
		end

		local condUnlock = ignoreCond or ActivityUtils.getOprActivityUnlockCond(activityId, player)

		return stage and stage >= Const.ACTIVITY_STAGE_TYPE.TAB and condUnlock and activityCanTabOpen or false
	else
		return stage and stage >= Const.ACTIVITY_STAGE_TYPE.TAB or false
	end
end

function ActivityUtils.isOprActivityOpen(activityId, player)
	local eventData = GameEventData[activityId]

	if not eventData or eventData.switch ~= 1 then
		return false
	end

	local actType = eventData.eventType

	if not actType then
		return false
	end

	if not ActivityUtils.curArenaIsActivateOpen(actType) then
		return false
	end

	local stageInfo = ActivityUtils.getActivityStageInfo()
	local stage = stageInfo and stageInfo[activityId]

	if pg.component == "client" then
		player = player or pg.me
	end

	if player then
		local activity = ActivityUtils.getActivityData(player, actType)
		local activityCanOpen = true

		if activity and activity.canOpen and type(activity.canOpen) == "function" then
			local eventTimeCfg = Utils.getEventTimeConfig(activityId) or {}
			local startTime = eventTimeCfg.tabStartDayTime or 0
			local endTime = eventTimeCfg.tabEndDayTime or 0

			activityCanOpen = activity:canOpen(startTime, endTime)
		end

		return stage and stage >= Const.ACTIVITY_STAGE_TYPE.TAB and ActivityUtils.getOprActivityUnlockCond(activityId, player) and activityCanOpen or false
	else
		return stage and stage >= Const.ACTIVITY_STAGE_TYPE.TAB or false
	end
end

function ActivityUtils.checkActSwitch(actType)
	if not actType then
		return false
	end

	if lume.findInList(CommonSwitch.CLOSED_ACTIVITY_LIST, actType) then
		return false
	end

	if actType < ActivityConst.EventType.MinType or actType > ActivityConst.EventType.MaxType then
		return false
	end

	local commonSwitchKey = GameEventTypeData[actType] and GameEventTypeData[actType].switchName

	if not commonSwitchKey then
		logger:error("ActivityUtils.checkActSwitch error not find commonSwitchKey actType:%d", actType)

		return false
	else
		commonSwitchKey = "ACT_TYPE_" .. commonSwitchKey
	end

	if CommonSwitch[commonSwitchKey] and CommonSwitch[commonSwitchKey] == true then
		return true
	end

	return false
end

function ActivityUtils.checkActSwitchByActId(actId)
	local actData = GameEventData[actId]

	if not actData then
		logger:error("ActivityUtils.checkActSwitchByActId error not find act cfg actId:%d", actId)

		return false
	end

	return ActivityUtils.checkActSwitch(actData.eventType)
end

function ActivityUtils.isOprActivityTabOpenByType(activityType, player)
	local getdd = GameEventTypePostData[activityType]

	if getdd == nil then
		return false
	end

	for activityId, _ in pairs(getdd) do
		if ActivityUtils.isOprActivityTabOpen(activityId, player) then
			return true, activityId
		end
	end

	return false
end

function ActivityUtils.isOprActivityOpenByType(activityType, player)
	local getdd = GameEventTypePostData[activityType]

	if getdd == nil then
		return false
	end

	for activityId, _ in pairs(getdd) do
		if ActivityUtils.isOprActivityOpen(activityId, player) then
			return true, activityId
		end
	end

	return false
end

function ActivityUtils.isOprActivityUpOpenByType(activityType, player)
	local getdd = GameEventTypePostData[activityType]

	if getdd == nil then
		return false
	end

	for activityId, _ in pairs(getdd) do
		if ActivityUtils.isOprActivityOpen(activityId, player) and GameEventData[activityId].iconUp == 1 then
			return true, activityId
		end
	end

	return false
end

function ActivityUtils.getOprActivityDayStartTsByType(activityType, useServerDayOffset, player)
	local isOpen, activityId = ActivityUtils.isOprActivityOpenByType(activityType, player)

	if not isOpen then
		return 0
	end

	local eventTimeCfg = Utils.getEventTimeConfig(activityId)
	local startTime = eventTimeCfg.tabStartDayTime
	local dayStartOffset = useServerDayOffset and Utils.getSecondsDayStart() or startTime - TimeUtils.getDayBegin(startTime)

	return TimeUtils.getDayBegin(Time.secondCache - dayStartOffset) + dayStartOffset
end

function ActivityUtils.getOprActivityWeekStartTsByType(activityType, useServerDayOffset, player)
	local isOpen, activityId = ActivityUtils.isOprActivityOpenByType(activityType, player)

	if not isOpen then
		return 0
	end

	local eventTimeCfg = Utils.getEventTimeConfig(activityId)
	local startTime = eventTimeCfg.tabStartDayTime
	local weeklyStartOffset = useServerDayOffset and Utils.getSecondsDayStart() or startTime - TimeUtils.getWeekBegin(startTime)

	return TimeUtils.getWeekBegin(Time.secondCache - weeklyStartOffset) + weeklyStartOffset
end

function ActivityUtils.getOprActivityOpenDayByType(activityType, useServerDayOffset, player)
	local isOpen, activityId = ActivityUtils.isOprActivityOpenByType(activityType, player)

	if not isOpen then
		return 0
	end

	local eventTimeCfg = Utils.getEventTimeConfig(activityId)
	local startTime = eventTimeCfg.tabStartDayTime

	if not startTime then
		return 0
	end

	local dayStartOffset = useServerDayOffset and Utils.getSecondsDayStart() or startTime - TimeUtils.getDayBegin(startTime)
	local dayBeginAct = TimeUtils.getDayBegin(startTime - dayStartOffset)
	local dayBeginCur = TimeUtils.getDayBegin(Time.secondCache - dayStartOffset)

	return math.safe_floor((dayBeginCur - dayBeginAct) / Const.SECONDS_ONE_DAY) + 1
end

function ActivityUtils.getOprActivityPhase(activityType, player)
	local isOpen, activityId = ActivityUtils.isOprActivityOpenByType(activityType, player)

	if not isOpen then
		return 0
	end

	local getdd = GameEventTypePostData[activityType] and GameEventTypePostData[activityType][activityId]

	return getdd and getdd.phase
end

function ActivityUtils.getOprActivityIdAndPhaseId(activityType, player)
	local isOpen, activityId = ActivityUtils.isOprActivityOpenByType(activityType, player)

	if not isOpen then
		return 0, 0
	end

	local getdd = GameEventTypePostData[activityType] and GameEventTypePostData[activityType][activityId]
	local phaseId = getdd and getdd.phase or 0

	return activityId, phaseId
end

function ActivityUtils.getOprActivityRule(activityType, player)
	local isOpen, activityId = ActivityUtils.isOprActivityOpenByType(activityType, player)

	if not isOpen then
		return
	end

	local getdd = GameEventTypePostData[activityType] and GameEventTypePostData[activityType][activityId]

	return getdd and getdd.rule
end

function ActivityUtils.getOprActivityConfig(activityType, player)
	local isOpen, activityId = ActivityUtils.isOprActivityOpenByType(activityType, player)

	if not isOpen then
		return
	end

	return GameEventData[activityId], activityId
end

function ActivityUtils.getOprActivityTypeConfig(activityType, player)
	local isOpen, activityId = ActivityUtils.isOprActivityOpenByType(activityType, player)

	if not isOpen then
		return
	end

	return GameEventTypePostData[activityType] and GameEventTypePostData[activityType][activityId]
end

function ActivityUtils.getGuideDataByType(activityType, player)
	local isOpen, activityId = ActivityUtils.isOprActivityOpenByType(activityType, player)

	if not isOpen or not activityId then
		return nil
	end

	local eventData = GameEventData[activityId]

	if not eventData or not eventData.guideId then
		return nil
	end

	return EventCommonGuideData[eventData.guideId]
end

function ActivityUtils.getGuideSandboxIdByType(activityType, player)
	local guideData = ActivityUtils.getGuideDataByType(activityType, player)

	return guideData and guideData.sandboxId
end

function ActivityUtils.getGuideIdByType(activityType, player)
	local isOpen, activityId = ActivityUtils.isOprActivityOpenByType(activityType, player)

	if not isOpen or not activityId then
		return nil
	end

	local eventData = GameEventData[activityId]

	return eventData and eventData.guideId
end

function ActivityUtils.getLuckyPetOpenDay(player)
	return ActivityUtils.getOprActivityOpenDayByType(ActivityConst.EventType.PuppetCatch, false, player)
end

function ActivityUtils.getLuckyPetConfig(phase, player)
	local phase = phase or ActivityUtils.getOprActivityPhase(ActivityConst.EventType.PuppetCatch, player)

	return PetResearchCatchData[phase]
end

function ActivityUtils.getLuckyPetScore(player)
	local score = 0

	for index, id in ipairs(player.luckyPetIdList) do
		local prtdd = PetResearchTrackData[id]

		if prtdd ~= nil and player.luckyPetIdSubmit[index] then
			local scoreItem = prtdd.petScore or 0

			if player.luckyPetIdFinishedUnlock[index] then
				scoreItem = scoreItem * 2
			end

			score = score + scoreItem
		end
	end

	return score
end

function ActivityUtils.getLuckyPetCanRewardList(player, phase)
	local phase = phase or ActivityUtils.getOprActivityPhase(ActivityConst.EventType.PuppetCatch, player)
	local config = ActivityUtils.getLuckyPetConfig(phase, player)

	if config == nil then
		return {}
	end

	local curScore = ActivityUtils.getLuckyPetScore(player)
	local canRewardList = {}

	for index, scoreReward in ipairs(config.scoreRewards or EMPTY_TABLE) do
		local needScore = scoreReward[ActivityConst.SCORE_REWARDS_IDX_SCORE]

		if needScore and needScore <= curScore then
			canRewardList[index] = true
		else
			canRewardList[index] = false
		end
	end

	return canRewardList
end

function ActivityUtils.getLuckyPetDoubleScore(index, petId)
	if pg.me.luckyPetIdFinish then
		if pg.me.luckyPetIdFinish[index] == true and pg.me.luckyPetIdFinishedUnlock[index] then
			return true
		elseif not pg.me.luckyPetIdFinish[index] and not pg.me.petHandbookMap:isCatched(petId, Const.GROUP_TYPE_SELF) then
			return true
		end
	end

	return false
end

function ActivityUtils.getFormResearchOpenDay(player)
	return ActivityUtils.getOprActivityOpenDayByType(ActivityConst.EventType.PuppetPhoto, false, player)
end

function ActivityUtils.getFormResearchConfig(phase, player)
	local phase = phase or ActivityUtils.getOprActivityPhase(ActivityConst.EventType.PuppetPhoto, player)

	return PetResearchPhotoData[phase]
end

function ActivityUtils.getFormResearchScore(player)
	return player.formResearchWeekUnlockClueCnt or 0
end

function ActivityUtils.getFormResearchCanRewardList(player, phase)
	local phase = phase or ActivityUtils.getOprActivityPhase(ActivityConst.EventType.PuppetPhoto, player)
	local config = ActivityUtils.getFormResearchConfig(phase, player)

	if config == nil then
		return {}
	end

	local curScore = ActivityUtils.getFormResearchScore(player)
	local canRewardList = {}

	for index, stageReward in ipairs(config.stageRewards or EMPTY_TABLE) do
		local needScore = stageReward[ActivityConst.STAGE_REWARDS_IDX_SCORE]

		if needScore and needScore <= curScore then
			canRewardList[index] = true
		else
			canRewardList[index] = false
		end
	end

	return canRewardList
end

function ActivityUtils.getCatchRogueConfig(phase, player)
	local phase = phase or ActivityUtils.getOprActivityPhase(ActivityConst.EventType.CatchRogue, player)

	return EventCatchRogueData[phase]
end

function ActivityUtils.getFishingCaptureConfig(phase, player)
	local phase = phase or ActivityUtils.getOprActivityPhase(ActivityConst.EventType.FishingCapture, player)

	return FishingCaptureActivityData[phase]
end

function ActivityUtils.getNewEnergyTheme(player)
	local newPhase = ActivityUtils.getOprActivityPhase(ActivityConst.EventType.EnergyMatch, player)

	if newPhase == 0 then
		return 0, 0
	end

	local newDay = ActivityUtils.getOprActivityOpenDayByType(ActivityConst.EventType.EnergyMatch, false, player)

	if newDay == 0 then
		return 0, 0
	end

	local newTheme
	local themesData = EnergyMatchThemeData[newPhase]

	for themeId, data in pairs(themesData or EMPTY_TABLE) do
		if data.duration ~= nil and newDay >= data.duration[1] and newDay < data.duration[2] then
			newTheme = themeId % ActivityConst.energyMatchThemeMax

			break
		end
	end

	if newTheme == nil then
		return 0, 0
	end

	return newPhase, newTheme
end

function ActivityUtils.refreshEnergyMatchExpireTime(newPhase, newThemeId, player)
	local isOpen, activityId = ActivityUtils.isOprActivityOpenByType(ActivityConst.EventType.EnergyMatch, player)

	if not isOpen then
		return 0
	end

	local themesData = EnergyMatchThemeData[newPhase]

	if not themesData then
		return 0
	end

	local themeData = themesData[newThemeId]

	if not themeData then
		return 0
	end

	local eventTimeCfg = Utils.getEventTimeConfig(activityId)
	local energyMatchEndTime = eventTimeCfg.tabEndDayTime
	local energyMatchStartTime = eventTimeCfg.tabStartDayTime
	local endTime = (themeData.duration[2] - 1) * Const.SECONDS_ONE_DAY + energyMatchStartTime

	if energyMatchEndTime < endTime then
		return energyMatchEndTime
	end

	return endTime
end

function ActivityUtils.getEnergyThemeId(palyer)
	local phase, day = ActivityUtils.getNewEnergyTheme(palyer)

	return phase * ActivityConst.energyMatchThemeMax + day
end

function ActivityUtils.checkAccessories(accessories, themeData, inventoryOwner)
	if not inventoryOwner then
		return {}
	end

	local jewelryBag = ItemUtils.getTypedBag(inventoryOwner, ItemConst.INV_TYPE_PET_JEWELRY)

	if not jewelryBag then
		return {}
	end

	local accessoryTry = themeData.accessoryTry or {}
	local petAccessoriesTry = {}

	for _, accessoryId in ipairs(accessoryTry) do
		petAccessoriesTry[accessoryId] = 1
	end

	local petAccessoriesCount = {}
	local petAccessories = {}

	for _, accessoryId in ipairs(accessories) do
		if petAccessoriesTry[accessoryId] == 1 then
			petAccessoriesTry[accessoryId] = 0
			petAccessories[#petAccessories + 1] = accessoryId
		elseif not petAccessoriesCount[accessoryId] then
			local items = jewelryBag:getItemsById(accessoryId)
			local sum = 0

			for _, item in pairs(items or EMPTY_TABLE) do
				sum = sum + item:getCount()
			end

			if sum > 0 then
				petAccessoriesCount[accessoryId] = sum - 1
				petAccessories[#petAccessories + 1] = accessoryId
			end
		elseif petAccessoriesCount[accessoryId] > 0 then
			petAccessoriesCount[accessoryId] = petAccessoriesCount[accessoryId] - 1
			petAccessories[#petAccessories + 1] = accessoryId
		end
	end

	return petAccessories
end

function ActivityUtils.caculateAccessories(accessories, themeData, curPhase, inventoryOwner)
	local totalScore = 0

	themeData = themeData or {}

	local AccessoryScore = SysConfigData.EnergyMatchAccessory or {}
	local labels = {}
	local scoreInfo = {}

	scoreInfo.fashion = 0
	scoreInfo.tagScore = 0
	scoreInfo.tagScores = {}
	scoreInfo.accessoryScores = {}
	scoreInfo.tagCount = accessories and #accessories or 0

	for _, id in pairs(themeData.accessoryTheme or EMPTY_TABLE) do
		labels[id] = 0
	end

	local petAccessories = {}

	for i, id in ipairs(accessories or EMPTY_TABLE) do
		petAccessories[i] = tonumber(id)
	end

	for _, accessoryId in ipairs(petAccessories) do
		local accessoryData = AppearanceJewelryPetData[accessoryId]
		local accessoryTagData = EnergyMatchAccessoriesData[accessoryId]
		local fashion = accessoryData and accessoryData.fashion or 0
		local tagScore = 0

		scoreInfo.fashion = scoreInfo.fashion + fashion
		totalScore = totalScore + fashion

		if accessoryTagData ~= nil then
			local sum = 0

			for _, labelId in pairs(accessoryTagData.accessoryTag or EMPTY_TABLE) do
				if labels[labelId] then
					sum = sum + 1
					labels[labelId] = labels[labelId] + 1
				end
			end

			if sum == 1 then
				tagScore = AccessoryScore[1] and AccessoryScore[1][1] or 0
			elseif sum > 1 then
				tagScore = AccessoryScore[2] and AccessoryScore[2][1] or 0
			end
		end

		scoreInfo.tagScores[accessoryId] = (scoreInfo.tagScores[accessoryId] or 0) + tagScore
		scoreInfo.tagScore = scoreInfo.tagScore + tagScore
		scoreInfo.accessoryScores[#scoreInfo.accessoryScores + 1] = {
			accessoryId = accessoryId,
			fashion = fashion,
			tagScore = tagScore,
			totalScore = fashion + tagScore
		}
	end

	totalScore = totalScore + scoreInfo.tagScore
	scoreInfo.totalScore = totalScore

	return totalScore, scoreInfo
end

function ActivityUtils.getEnergyMatchSpecialFormType(pet)
	local petPrototypeId = Utils.getPetPetPrototypeId(pet.templateId)
	local isRainbow = Utils.isRainbowType(petPrototypeId)
	local isShiny = Utils.isLabelShiny(pet.label)

	if isRainbow and isShiny then
		return 1
	elseif isRainbow then
		return 2
	elseif isShiny then
		return 3
	end

	return 4
end

function ActivityUtils.getEnergyMatchSpecialFormBonus(pet, themeData)
	local formType = ActivityUtils.getEnergyMatchSpecialFormType(pet)

	for _, cfg in ipairs(themeData.specialFormBonus or EMPTY_TABLE) do
		if cfg[1] == formType then
			return cfg[2] or 0, cfg[3] or 1, formType
		end
	end

	return 0, 1, formType
end

function ActivityUtils._getAttributeScore(pet, themeData, index)
	if not themeData then
		return 0, 0
	end

	local petPrototypeId = Utils.getPetPetPrototypeId(pet.templateId)
	local petConfigData = PetPrototypeData[petPrototypeId]

	if not petConfigData then
		return 0, 0
	end

	local totalScore = 0
	local totalRate = 0
	local attribute = {}

	for _, attr in pairs(petConfigData.elementType) do
		attribute[attr] = 1
	end

	for i, attr in ipairs(themeData["bonusAttribute" .. index] or EMPTY_TABLE) do
		if attribute[attr] then
			local scoreData = themeData["bonusScore" .. index][i]

			if scoreData then
				totalScore = totalScore + scoreData[1]
				totalRate = totalRate + scoreData[2]
			end
		end
	end

	return totalScore == 0 and 10 or totalScore, totalRate
end

function ActivityUtils._getPositionScore(pet, themeData, index)
	if not themeData then
		return 0, 0
	end

	local petPrototypeId = Utils.getPetPetPrototypeId(pet.templateId)
	local petConfigData = PetPrototypeData[petPrototypeId]

	if not petConfigData then
		return 0, 0
	end

	local totalScore = 0
	local totalRate = 0

	for i, data in ipairs(themeData["bonusAttribute" .. index] or EMPTY_TABLE) do
		if petConfigData.functionId == data then
			local scoreData = themeData["bonusScore" .. index][i]

			if scoreData then
				totalScore = totalScore + scoreData[1]
				totalRate = totalRate + scoreData[2]
			end
		end
	end

	return totalScore == 0 and 10 or totalScore, totalRate
end

function ActivityUtils._getPersonalityScore(pet, themeData, index)
	if not themeData then
		return 0, 0
	end

	local talentMap = {}

	for _, data in pairs(pet.talentList or EMPTY_TABLE) do
		talentMap[data.templateId] = 1
	end

	local totalScore = 0

	for i, data in ipairs(themeData["bonusAttribute" .. index] or EMPTY_TABLE) do
		if talentMap[data] then
			local scoreData = themeData["bonusScore" .. index][i]

			if scoreData then
				totalScore = totalScore + scoreData[1]
			end
		end
	end

	return totalScore == 0 and 10 or totalScore
end

function ActivityUtils._getAbilityScore(pet, themeData, index)
	if not themeData then
		return 0, 0
	end

	local petPrototypeId = Utils.getPetPetPrototypeId(pet.templateId)
	local petConfigData = PetPrototypeData[petPrototypeId]

	if not petConfigData then
		return 0, 0
	end

	local totalScore = 0

	for i, data in ipairs(themeData["bonusAttribute" .. index] or EMPTY_TABLE) do
		if petConfigData[data] then
			local scoreData = themeData["bonusScore" .. index][i * petConfigData[data]]

			if scoreData then
				totalScore = totalScore + scoreData[2]
			end
		end
	end

	return totalScore == 0 and 10 or totalScore
end

function ActivityUtils._getFormScore(pet, themeData, index)
	if not themeData then
		return 0, 0
	end

	local petPrototypeId = Utils.getPetPetPrototypeId(pet.templateId)
	local petConfigData = PetPrototypeData[petPrototypeId]

	if not petConfigData then
		return 0, 0
	end

	local totalScore = 0
	local formName = Utils.getPetFormNameByTemplateId(pet.templateId)

	for i, data in ipairs(themeData["bonusAttribute" .. index] or EMPTY_TABLE) do
		if formName == data then
			local scoreData = themeData["bonusScore" .. index][i]

			if scoreData then
				totalScore = totalScore + scoreData[1]
			end
		end
	end

	return totalScore == 0 and 10 or totalScore
end

function ActivityUtils._getEvolutionScore(pet, themeData, index)
	if not themeData then
		return 0, 0
	end

	local totalScore = 0

	for _, data in ipairs(themeData["bonusScore" .. index] or EMPTY_TABLE) do
		if pet.stage == data[1] then
			totalScore = totalScore + data[2]
		end
	end

	return totalScore == 0 and 10 or totalScore
end

ActivityUtils.EnergyMatchFunc = {
	attribute = ActivityUtils._getAttributeScore,
	position = ActivityUtils._getPositionScore,
	personality = ActivityUtils._getPersonalityScore,
	ability = ActivityUtils._getAbilityScore,
	form = ActivityUtils._getFormScore,
	evolution = ActivityUtils._getEvolutionScore
}

function ActivityUtils.actArkCarnIsInStageTime(actPhaseId, stageId)
	if not actPhaseId or not stageId then
		return false
	end

	local data = EventArkCarnData[actPhaseId] and EventArkCarnData[actPhaseId][stageId]

	if data == nil then
		return false
	end

	local now = Time.getSecond()
	local startTs = Utils.getConfigTimeOfArea(data, "startTime") or 0
	local endTs = Utils.getConfigTimeOfArea(data, "endTime") or 0

	if startTs <= now and now < endTs then
		return true
	end

	return false
end

function ActivityUtils.actArkCarnGetStageTime(actPhaseId, stageId)
	local startTs = 0
	local endTs = 0

	if not actPhaseId or not stageId then
		return startTs, endTs
	end

	local data = EventArkCarnData[actPhaseId] and EventArkCarnData[actPhaseId][stageId]

	if data == nil then
		return startTs, endTs
	end

	local startTs = Utils.getConfigTimeOfArea(data, "startTime") or 0
	local endTs = Utils.getConfigTimeOfArea(data, "endTime") or 0

	return startTs, endTs
end

function ActivityUtils._getArkCarnVoteKey(actPhaseId)
	local voteKeys = {}
	local cfgData = EventArkCarnData[actPhaseId] and EventArkCarnData[actPhaseId][ActivityConst.ArkCarnStageId.Vote]

	if not cfgData then
		return voteKeys
	end

	voteKeys[ActivityConst.PET_BAND_POS_TYPE.Drummer] = cfgData.voteDrummerKey or 0
	voteKeys[ActivityConst.PET_BAND_POS_TYPE.Dancer] = cfgData.voteDancerKey or 0
	voteKeys[ActivityConst.PET_BAND_POS_TYPE.Accompany] = cfgData.voteAccompanyKey or 0
	voteKeys[ActivityConst.PET_BAND_POS_TYPE.Atmos] = cfgData.voteAtmosKey or 0

	return voteKeys
end

function ActivityUtils.getActCarnBandPos(actPhaseId, bandpos)
	local cfgData = EventArkCarnData[actPhaseId] and EventArkCarnData[actPhaseId][ActivityConst.ArkCarnStageId.Show]

	if not cfgData then
		return nil, nil
	end

	if bandpos == ActivityConst.PET_BAND_POS_TYPE.Drummer then
		return cfgData.petDrummerPos, cfgData.petDrummerRot
	elseif bandpos == ActivityConst.PET_BAND_POS_TYPE.Dancer then
		return cfgData.petDancerPos, cfgData.petDancerRot
	elseif bandpos == ActivityConst.PET_BAND_POS_TYPE.Accompany then
		return cfgData.petAccompanyPos, cfgData.petAccompanyPosRot
	elseif bandpos == ActivityConst.PET_BAND_POS_TYPE.Atmos then
		return cfgData.petAtmosPos, cfgData.petAtmosRot
	elseif bandpos == ActivityConst.PET_BAND_POS_TYPE.MainDancer then
		return cfgData.petMainDancerPos, cfgData.petMainDancerRot
	end

	return nil, nil
end

function ActivityUtils.getActCarnBandDefautNpcId(actPhaseId, bandpos)
	local cfgData = EventArkCarnData[actPhaseId] and EventArkCarnData[actPhaseId][ActivityConst.ArkCarnStageId.Vote]

	if not cfgData then
		return 0
	end

	if bandpos == ActivityConst.PET_BAND_POS_TYPE.Drummer then
		return cfgData.votePetListeDrummer[1] or 0
	elseif bandpos == ActivityConst.PET_BAND_POS_TYPE.Dancer then
		return cfgData.votePetListDancer[1] or 0
	elseif bandpos == ActivityConst.PET_BAND_POS_TYPE.Accompany then
		return cfgData.votePetListAccompany[1] or 0
	elseif bandpos == ActivityConst.PET_BAND_POS_TYPE.Atmos then
		return cfgData.votePetListAtmos[1] or 0
	end

	return 0
end

function ActivityUtils._areaActCheckPetResearchOpen(petResearchIndex)
	return
end

function ActivityUtils.trySign(activity, signType, signDayUpLimit)
	if not activity then
		return
	end

	local player = activity.activityBase:getPlayer()

	if not player then
		return
	end

	if activity.leastSignTime > 0 and TimeUtils.getServerDayDiff(activity.leastSignTime, Time.secondCache) == 0 then
		return
	end

	if signType == 1 then
		if signDayUpLimit <= activity.totalSignNum then
			return
		end

		activity.totalSignNum = activity.totalSignNum + 1

		player.triggerMap:onTrigger(TriggerConst.TRIGGER_ACT_LOGIN, activity.activityBase.activityId, 1, 0)
	elseif signType == 2 then
		if signDayUpLimit <= activity.continueTotalSignNum then
			return
		end

		local oldSignNum = activity.continueTotalSignNum

		if activity.leastSignTime == 0 then
			activity.continueTotalSignNum = 1
		elseif activity.leastSignTime > 0 then
			if TimeUtils.getServerDayDiff(activity.leastSignTime, Time.secondCache) == 1 then
				activity.continueTotalSignNum = activity.continueTotalSignNum + 1
			else
				activity.continueTotalSignNum = 1
			end
		end

		if activity.continueTotalSignNum ~= oldSignNum then
			player.triggerMap:onTrigger(TriggerConst.TRIGGER_ACT_LOGIN_CONTINUE, activity.activityBase.activityId, activity.continueTotalSignNum, 0)
		end
	end

	activity.leastSignTime = Time.secondCache
end

function ActivityUtils.checkActType(actType)
	if not actType then
		return false
	end

	return actType >= ActivityConst.EventType.MinType and actType <= ActivityConst.EventType.MaxType
end

function ActivityUtils.checkNewFramActType(actType)
	return actType >= ActivityConst.NewFrameEventType.NewActFrameBeg and actType <= ActivityConst.NewFrameEventType.NewActFrameEnd or ActivityConst.NewFrameEventTypeSet[actType]
end

function ActivityUtils.getActivityData(player, actType)
	if pg and pg.component == "client" then
		player = player or pg.me
	end

	if not player then
		return nil
	end

	if not ActivityUtils.checkActType(actType) then
		return nil
	end

	if not ActivityUtils.checkNewFramActType(actType) then
		return nil
	end

	local activityName = ActivityConst.NewFrameEventAttriName[actType]

	if activityName then
		local activity = player[activityName]

		return activity
	elseif ActivityUtils.isGuidePreheatActivity(actType) then
		return player.activityMapGuidePreheat[actType]
	end

	return nil
end

function ActivityUtils.isGuidePreheatActivity(actType)
	return EventGuidePreheatType and EventGuidePreheatType[actType]
end

function ActivityUtils.getActivityType(activityId)
	if not activityId then
		return 0
	end

	return GameEventData[activityId] and GameEventData[activityId].eventType or 0
end

function ActivityUtils.getActTaskActivityType(actTaskId)
	return EventTaskMapActType[actTaskId] or 0
end

function ActivityUtils.getActTaskMap(player, actType)
	if pg and pg.component == "client" then
		player = player or pg.me
	end

	if not player or not actType then
		return nil
	end

	if actType == ActivityConst.EventType.ArkCarn then
		return player.arkCarnTasks
	elseif actType == ActivityConst.EventType.AreaActivity then
		return player.areaActivityTasks
	end

	local actData = ActivityUtils.getActivityData(player, actType)

	if actData and actData.activityBase and actData.activityBase.activityTasks then
		return actData.activityBase.activityTasks
	end

	return nil
end

function ActivityUtils.getActTaskData(player, actTaskId)
	if pg and pg.component == "client" then
		player = player or pg.me
	end

	if not player then
		return nil
	end

	local activityType = ActivityUtils.getActTaskActivityType(actTaskId)
	local actTaskMap = ActivityUtils.getActTaskMap(player, activityType)

	if actTaskMap then
		return actTaskMap[actTaskId]
	end

	return nil
end

function ActivityUtils.getActTaskState(player, actTaskId)
	if pg and pg.component == "client" then
		player = player or pg.me
	end

	local actTaskData = ActivityUtils.getActTaskData(player, actTaskId)

	if not actTaskData then
		return nil
	end

	return actTaskData.state
end

function ActivityUtils.checkActTaskCompleteed(player, actTaskId)
	local taskState = ActivityUtils.getActTaskState(player, actTaskId)

	if taskState and taskState >= ActivityConst.TaskState.Finihed_CanRecv then
		return true
	end

	return false
end

function ActivityUtils.checkActTaskRecved(player, actTaskId)
	local taskState = ActivityUtils.getActTaskState(player, actTaskId)

	if taskState and taskState == ActivityConst.TaskState.Received then
		return true
	end

	return false
end

function ActivityUtils.getActTaskAreaInternationalJuge()
	if Utils.isOverseas() then
		return 2
	end

	return 1
end

function ActivityUtils.getActTaskIdsByGroupId(taskGroupId)
	local internationalJuge = ActivityUtils.getActTaskAreaInternationalJuge()

	return EventTaskMapGroupData[taskGroupId] and EventTaskMapGroupData[taskGroupId][internationalJuge] or {}
end

function ActivityUtils.getActTaskIdsByGroupType(taskGroupId, actTaskType)
	local internationalJuge = ActivityUtils.getActTaskAreaInternationalJuge()
	local groupTaskIds = EventTaskMapGroupTypeData[taskGroupId] or {}
	local groupAreaTaskIds = groupTaskIds[internationalJuge] or {}

	return groupAreaTaskIds[actTaskType] or {}
end

function ActivityUtils.getActTaskNumByGroupId(player, taskGroupId)
	if pg and pg.component == "client" then
		player = player or pg.me
	end

	local taskIds = ActivityUtils.getActTaskIdsByGroupId(taskGroupId)
	local taskIdsCompleted = {}

	for i, taskId in ipairs(taskIds) do
		local taskState = ActivityUtils.getActTaskState(player, taskId)

		if taskState and taskState >= ActivityConst.TaskState.Finihed_CanRecv then
			taskIdsCompleted[#taskIdsCompleted + 1] = taskId
		end
	end

	return #taskIdsCompleted, #taskIds, taskIds
end

function ActivityUtils.getActTaskCanReceiveByGroupId(player, taskGroupId)
	if pg and pg.component == "client" then
		player = player or pg.me
	end

	local taskIds = ActivityUtils.getActTaskIdsByGroupId(taskGroupId)
	local taskIdsCanReceive = {}

	for i, taskId in ipairs(taskIds) do
		local actTaskData = ActivityUtils.getActTaskData(player, taskId)

		if actTaskData and actTaskData.state == ActivityConst.TaskState.Finihed_CanRecv then
			taskIdsCanReceive[#taskIdsCanReceive + 1] = taskId
		end
	end

	return taskIdsCanReceive
end

function ActivityUtils.getActTaskReceivedNumByGroupId(player, taskGroupId)
	if pg and pg.component == "client" then
		player = player or pg.me
	end

	local taskIds = ActivityUtils.getActTaskIdsByGroupId(taskGroupId)
	local revedTaskIds = {}

	for i, taskId in ipairs(taskIds) do
		local actTaskData = ActivityUtils.getActTaskData(player, taskId)

		if actTaskData and actTaskData.state >= ActivityConst.TaskState.Received then
			revedTaskIds[#revedTaskIds + 1] = taskId
		end
	end

	return #revedTaskIds, #taskIds
end

function ActivityUtils.getActIdOfActTaskGroupId(taskGroupId)
	return EventTaskGroupMapActId[taskGroupId] or 0
end

function ActivityUtils.checkActTaskGruopCompleteed(player, activityId, taskGroupId)
	if not player then
		return false
	end

	if not ActivityUtils.isOprActivityOpen(activityId, player) then
		return false
	end

	local taskIdsCompletedNum, taskIdsNum = ActivityUtils.getActTaskNumByGroupId(player, taskGroupId)

	return taskIdsCompletedNum and taskIdsNum and taskIdsNum > 0 and taskIdsCompletedNum == taskIdsNum
end

function ActivityUtils.checkActTaskGroupReceived(player, activityId, taskGroupId)
	if not player then
		return false
	end

	if not ActivityUtils.isOprActivityOpen(activityId, player) then
		return false
	end

	local revedTaskNum, taskIdsNum = ActivityUtils.getActTaskReceivedNumByGroupId(player, taskGroupId)

	return revedTaskNum and taskIdsNum and taskIdsNum > 0 and taskIdsNum == revedTaskNum
end

function ActivityUtils.getActivityIdByTypeAndPhase(actType, actPhase)
	local activtyList = GameEventTypePostData[actType]

	if not activtyList then
		return 0
	end

	for activityId, activty in pairs(activtyList) do
		if activty.phase == actPhase then
			return activityId
		end
	end

	return 0
end

local energyMatchBonusTypes = {}
local energyMatchBonusType = {}

for _, bonusType in ipairs(SysConfigData.GLAMOUR_STAR_BONUS_TYPE or EMPTY_TABLE) do
	local lowerBonusType = string.lower(bonusType)

	energyMatchBonusTypes[#energyMatchBonusTypes + 1] = lowerBonusType
	energyMatchBonusType[bonusType] = lowerBonusType
end

local function isEnergyMatchScorePair(scoreData)
	return Utils.isTable(scoreData) and type(scoreData[1]) == "number" and scoreData[2] ~= nil
end

local function collectEnergyMatchScoreRows(themeData, index)
	local bonusScore = themeData and themeData["bonusScore" .. index]

	if not Utils.isTable(bonusScore) then
		return nil
	end

	if Utils.isTable(bonusScore[1]) then
		return bonusScore
	end

	local rows = {
		bonusScore
	}

	if not isEnergyMatchScorePair(bonusScore) then
		return rows
	end

	local implicitIndex = 1

	for prevIndex = 1, index - 1 do
		local prevScore = themeData["bonusScore" .. prevIndex]

		if isEnergyMatchScorePair(prevScore) then
			local expectedKey = prevScore[1] + 1

			while isEnergyMatchScorePair(themeData[implicitIndex]) and themeData[implicitIndex][1] == expectedKey do
				implicitIndex = implicitIndex + 1
				expectedKey = expectedKey + 1
			end
		end
	end

	local expectedKey = bonusScore[1] + 1

	while isEnergyMatchScorePair(themeData[implicitIndex]) and themeData[implicitIndex][1] == expectedKey do
		rows[#rows + 1] = themeData[implicitIndex]
		implicitIndex = implicitIndex + 1
		expectedKey = expectedKey + 1
	end

	return rows
end

local function getEnergyMatchBonusScore(petInfo, themeData, index)
	local bonusScore = themeData and themeData["bonusScore" .. index]

	if not Utils.isTable(bonusScore) then
		return tonumber(bonusScore) or 0
	end

	if themeData["bonusType" .. index] == energyMatchBonusType.Evolution then
		local stage = petInfo and petInfo.stage

		if not stage then
			return 0
		end

		for _, data in ipairs(collectEnergyMatchScoreRows(themeData, index) or EMPTY_TABLE) do
			if data[1] == stage then
				return tonumber(data[2]) or 0
			end
		end

		return 0
	end

	if Utils.isTable(bonusScore[1]) then
		return tonumber(bonusScore[1][2] or bonusScore[1][1]) or 0
	end

	return tonumber(bonusScore[2] or bonusScore[1]) or 0
end

local function checkEnergyMatchBonusMatched(petInfo, themeData, index)
	if not petInfo or not themeData then
		return false
	end

	local bonusType = themeData["bonusType" .. index]
	local bonusAttrs = themeData["bonusAttribute" .. index] or {}
	local petPrototypeId = Utils.getPetPetPrototypeId(petInfo.templateId)
	local petPrototypeData = PetPrototypeData[petPrototypeId]

	if bonusType == energyMatchBonusType.Attribute then
		if not petPrototypeData then
			return false
		end

		local elementMap = {}

		for _, element in pairs(petPrototypeData.elementType or EMPTY_TABLE) do
			elementMap[element] = true
		end

		for _, element in ipairs(bonusAttrs) do
			if elementMap[element] then
				return true
			end
		end
	elseif bonusType == energyMatchBonusType.Position then
		if not petPrototypeData then
			return false
		end

		for _, functionId in ipairs(bonusAttrs) do
			if petPrototypeData.functionId == functionId then
				return true
			end
		end
	elseif bonusType == energyMatchBonusType.Personality then
		local talentMap = {}

		for _, talent in pairs(petInfo.talentList or EMPTY_TABLE) do
			talentMap[talent.templateId] = true
		end

		for _, talentId in ipairs(bonusAttrs) do
			if talentMap[talentId] then
				return true
			end
		end
	elseif bonusType == energyMatchBonusType.Ability then
		if not petPrototypeData then
			return false
		end

		for _, abilityKey in ipairs(bonusAttrs) do
			if petPrototypeData[abilityKey] then
				return true
			end
		end
	elseif bonusType == energyMatchBonusType.Form then
		if not petPrototypeData then
			return false
		end

		for _, formName in ipairs(bonusAttrs) do
			if Utils.getPetFormNameByTemplateId(petInfo.templateId) == formName then
				return true
			end
		end
	elseif bonusType == energyMatchBonusType.Evolution then
		return getEnergyMatchBonusScore(petInfo, themeData, index) > 0
	end

	return false
end

function ActivityUtils.getEnergyMatchPetBaseScore(petInfo, themeData, detailScores)
	if not themeData then
		return 0
	end

	local score = 0
	local baseScore = themeData.baseScore or 0

	for _, bonusType in ipairs(energyMatchBonusTypes) do
		local typeScore = baseScore

		for index = 1, 3 do
			if themeData["bonusType" .. index] == bonusType and checkEnergyMatchBonusMatched(petInfo, themeData, index) then
				typeScore = typeScore + getEnergyMatchBonusScore(petInfo, themeData, index)
			end
		end

		if detailScores then
			detailScores[bonusType] = typeScore
		end

		score = score + typeScore
	end

	return score
end

function ActivityUtils.getEnergyMatchPetFormBonusScore(petInfo, themeData)
	if not petInfo or not themeData then
		return 0
	end

	local isRainbow = petInfo.isRainbow or petInfo.isBlackRainbow or Utils.isAnyRainbowTypeByTemplateId(petInfo.templateId)
	local isShiny = petInfo.isShiny or Utils.isLabelShiny(petInfo.label)
	local bonusType

	if isRainbow and isShiny then
		bonusType = 1
	elseif isRainbow then
		bonusType = 2
	elseif isShiny then
		bonusType = 3
	end

	if not bonusType then
		return 0
	end

	for _, data in ipairs(themeData.formBonus or EMPTY_TABLE) do
		if data[1] == bonusType then
			return data[2] or 0
		end
	end

	return 0
end

function ActivityUtils.isEnergyMatchPetCaughtThisWeek(petInfo)
	if not petInfo or not petInfo.time then
		return false
	end

	local serverTime = Time.secondCache
	local petCreateTime = tonumber(petInfo.time) or 0

	petCreateTime = math.floor(petCreateTime / 1000)

	local weekBeginTime = TimeUtils.getAreaWeekBegin(serverTime)
	local nextWeekBeginTime = TimeUtils.getAreaNextWeekBegin(serverTime)

	return weekBeginTime <= petCreateTime and petCreateTime < nextWeekBeginTime
end

function ActivityUtils.getEnergyMatchPetNewStarScore(petInfo, themeData)
	if not petInfo then
		return 0
	end

	local baseScore = ActivityUtils.getEnergyMatchPetBaseScore(petInfo, themeData)
	local formBonusScore = ActivityUtils.getEnergyMatchPetFormBonusScore(petInfo, themeData)

	if ActivityUtils.isEnergyMatchPetCaughtThisWeek(petInfo) then
		return math.ceil((baseScore + formBonusScore) * ((themeData and themeData.newBonus or 1) - 1))
	end

	return 0
end

function ActivityUtils.getEnergyMatchPetTotalScore(petInfo, themeData)
	local baseScore = ActivityUtils.getEnergyMatchPetBaseScore(petInfo, themeData)
	local formBonusScore = ActivityUtils.getEnergyMatchPetFormBonusScore(petInfo, themeData)
	local newStarScore = ActivityUtils.getEnergyMatchPetNewStarScore(petInfo, themeData)

	return baseScore + formBonusScore + newStarScore
end

function ActivityUtils.getActivityTaskGroups(activityId)
	if not activityId then
		return nil
	end

	return ActivateTasksData[activityId]
end

function ActivityUtils.getDailyTaskGroupId(activityId)
	local taskGroups = ActivityUtils.getActivityTaskGroups(activityId)

	return taskGroups and taskGroups.dailyTaskGroup
end

function ActivityUtils.getWeeklyTaskGroupId(activityId)
	local taskGroups = ActivityUtils.getActivityTaskGroups(activityId)

	return taskGroups and taskGroups.weeklyTaskGroup
end

function ActivityUtils.getForeverTaskGroupIds(activityId)
	local taskGroups = ActivityUtils.getActivityTaskGroups(activityId)

	return taskGroups and taskGroups.foreverTaskGroup
end

function ActivityUtils.curArenaIsActivateOpen(activeType)
	local areaNo

	if pg.component == "client" then
		areaNo = pg.me and pg.me.serverArea
	else
		local GameServerRepo = require("Core.Server.GameServerRepo")

		areaNo = GameServerRepo.areaNo
	end

	if not areaNo or areaNo <= 0 then
		return false
	end

	if not ActivityUtils.checkActSwitch(activeType) then
		return false
	end

	local eventTypeCfg = GameEventTypeData[activeType]

	if not eventTypeCfg then
		return false
	end

	if not eventTypeCfg.areaNo then
		return true
	end

	local openArenas = eventTypeCfg.areaNo or {}

	if lume.findInList(openArenas, areaNo) then
		return true
	end

	return false
end

function ActivityUtils.getActivityTimeControl(actCfg)
	if not actCfg then
		return nil
	end

	return actCfg.timeControlRule or ActivityConst.TimeControlRule.FixedSpan_Date
end

function ActivityUtils.checkActivityTimeSpan(activityId, actCfg)
	if not activityId or not actCfg then
		return false
	end

	local timeControlRule = ActivityUtils.getActivityTimeControl(actCfg)

	if not timeControlRule then
		return false
	end

	local areaNo = Utils.getServerArea()

	if areaNo == nil then
		return false
	end

	local now = Time.getSecond()
	local timeFormat = timeControlRule % 10

	if timeFormat == ActivityConst.TimeFormat.Date then
		local eventTimeCfg = Utils.getEventTimeConfig(activityId)
		local startTime = eventTimeCfg.tabStartDayTime
		local endTime = eventTimeCfg.tabEndDayTime

		if startTime and now < startTime then
			return false
		end

		if endTime and endTime <= now then
			return false
		end
	elseif timeFormat == ActivityConst.TimeFormat.OpenDays then
		local startOpenDays = actCfg.LaunchDayOpenTime and actCfg.LaunchDayOpenTime[areaNo]
		local endOpenDays = actCfg.LaunchDayEndTime and actCfg.LaunchDayEndTime[areaNo]

		if startOpenDays then
			local startTime = TimeUtils.getAreaOpenDayBegin(startOpenDays)

			if not startTime or now < startTime then
				return false
			end
		end

		if endOpenDays then
			local endTime = TimeUtils.getAreaOpenDayEnd(endOpenDays)

			if endTime and endTime <= now then
				return false
			end
		end
	end

	return true
end

function ActivityUtils.checkActivityGoingDailyCycle(activityId, actCfg)
	if not activityId or not actCfg then
		return false
	end

	local timeControlRule = ActivityUtils.getActivityTimeControl(actCfg)

	if not timeControlRule then
		return false
	end

	local ruleType = math.floor(timeControlRule / 10)

	if ruleType ~= ActivityConst.TimeControlRuleType.DailyCycle then
		return false
	end

	if actCfg.dailyEventTime and #actCfg.dailyEventTime >= 2 then
		local dailyStartTime = actCfg.dailyEventTime[1]
		local dailyEndTime = actCfg.dailyEventTime[2]

		if dailyStartTime and dailyEndTime then
			local pattern = "(%d+):(%d+):(%d+)"
			local startH, startM, startS = dailyStartTime:match(pattern)
			local endH, endM, endS = dailyEndTime:match(pattern)

			if startH and startM and startS and endH and endM and endS then
				local openSec = tonumber(startH) * 3600 + tonumber(startM) * 60 + tonumber(startS)
				local closeSec = tonumber(endH) * 3600 + tonumber(endM) * 60 + tonumber(endS)

				if TimeUtils.isInDailyOpenTime(openSec, closeSec) then
					return true
				end
			end
		end
	end

	return false
end

function ActivityUtils.checkActivityGoingWeeklyCycle(activityId, actCfg)
	if not activityId or not actCfg then
		return false
	end

	local timeControlRule = ActivityUtils.getActivityTimeControl(actCfg)

	if not timeControlRule then
		return false
	end

	local ruleType = math.floor(timeControlRule / 10)

	if ruleType ~= ActivityConst.TimeControlRuleType.WeeklyCycle then
		return false
	end

	if actCfg.weekEventTime and #actCfg.weekEventTime > 0 then
		local now = Time.getSecond()
		local startTs = Utils.getSecondsDayStart()
		local weekBegin = TimeUtils.getAreaWeekBegin(now) + startTs

		if now < weekBegin then
			weekBegin = weekBegin - Const.SECONDS_ONE_WEEK
		end

		local secsFromWeekBegin = now - weekBegin

		for _, timeRange in ipairs(actCfg.weekEventTime) do
			if timeRange and #timeRange >= 2 then
				local startDay = timeRange[1]
				local endDay = timeRange[2]

				if startDay and endDay then
					local startSec = (startDay - 1) * Const.SECONDS_ONE_DAY
					local endSec = endDay * Const.SECONDS_ONE_DAY - 1

					if startSec <= secsFromWeekBegin and secsFromWeekBegin <= endSec then
						return true
					end
				end
			end
		end
	end

	return false
end

function ActivityUtils.checkPlayerHaveQualify(player)
	if not player then
		return false
	end

	local canTriggrCondId = SysConfigData.ACT_FIRST_CHARGE_QUALIFY_COND_ID

	if canTriggrCondId and player.triggerMap:isCompleteOrMeetCondition(canTriggrCondId) then
		return true
	end

	return false
end

function ActivityUtils.activityBaseCheck(activityObj)
	if not activityObj or not activityObj.activityBase then
		return NoticeDef.INVENTOYR_INVALID_PARAM
	end

	if not ActivityUtils.checkActSwitch(activityObj.activityBase.activeType) then
		return NoticeDef.COMMON_SWITCH_CLOSE_TIP
	end

	if not activityObj.activityBase:isGoing() then
		return NoticeDef.ERROR_ACTIVITY_NOT_OPEN
	end

	return NoticeDef.SUCCESS
end

return ActivityUtils
