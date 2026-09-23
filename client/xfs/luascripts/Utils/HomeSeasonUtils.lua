-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\HomeSeasonUtils.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Time = require("Core.Common.Time")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local ItemUtils = require("Common.Utils.ItemUtils")
local HomeSeasonData = require("Data.home_season_data")
local HomeSeasonConfigData = require("Data.home_season_config_data")
local HomeSeasonStageData = require("Data.home_season_stage_data")
local HomeSeasonModuleData = require("Data.home_season_module_data")
local HomeSeasonCollectionItemData = require("Data.home_season_collection_item_data")
local HomeSeasonCollectionRewardData = require("Data.home_season_collection_reward_data")
local RedDotConst = require("Const.RedDotConst")
local QuestCommonUtils = require("Common.Utils.QuestCommonUtils")
local QuestConst = require("Common.Const.QuestConst")
local HomeSeasonMutationCollectionData = require("Data.home_season_mutation_collection_data")
local HomeSeasonMutationCollectionRewardData = require("Data.home_season_mutation_collection_reward_data")
local HomeSeasonDailyTaskData = require("Data.home_season_daily_task_data")
local ActivityConst = require("Common.Const.ActivityConst")
local RedDotUtils = require("Utils.RedDotUtils")
local HomeSeasonUtils = {}

HomeSeasonUtils.COLLECTION_REWARD_STATE_CAN_RECEIVE = 1

function HomeSeasonUtils.isSeasonOpen(seasonId, now)
	local seasonInfo = HomeSeasonData[seasonId]

	if not seasonInfo or seasonInfo.seasonalPlotsEnable ~= 1 then
		return false
	end

	now = now or Time.secondCache or Time.getSecond()

	local startTime = Utils.getConfigTimeOfAreaByData(seasonInfo.startDayTime, seasonInfo.startDayTimeRefId)
	local endTime = Utils.getConfigTimeOfAreaByData(seasonInfo.endDayTime, seasonInfo.endDayTimeRefId)

	return startTime ~= nil and endTime ~= nil and startTime <= now and now <= endTime
end

function HomeSeasonUtils.isSeasonAvailable(player, now)
	local seasonId = player and (player.homeSeasonId or 0) or 0

	if seasonId == 0 or (player.homeSeasonUnlockTs or 0) <= 0 then
		return false
	end

	return HomeSeasonUtils.isSeasonOpen(seasonId, now)
end

function HomeSeasonUtils.getSeasonMoneyId(player)
	local seasonId = player and (player.homeSeasonId or 0) or 0

	if seasonId == 0 then
		return
	end

	local seasonInfo = HomeSeasonData[seasonId]

	return seasonInfo and seasonInfo.seasonMoneyId
end

function HomeSeasonUtils.isSeasonUnlockConditionMet(player)
	local seasonId = player and (player.homeSeasonId or 0) or 0
	local seasonInfo = HomeSeasonData[seasonId]

	if not player or not seasonInfo then
		return false
	end

	if (player.homeSeasonUnlockTs or 0) > 0 then
		return true
	end

	return player.triggerMap ~= nil and player.triggerMap:isCompleteOrMeetCondition(seasonInfo.seasonUnlock)
end

function HomeSeasonUtils.isSeasonShopOpen(player, now)
	if not HomeSeasonUtils.isSeasonAvailable(player, now) then
		return false
	end

	local seasonId = player.homeSeasonId
	local seasonInfo = HomeSeasonData[seasonId]

	return seasonInfo ~= nil and HomeSeasonUtils.isModuleOpen(seasonId, seasonInfo.shopRefId, now)
end

function HomeSeasonUtils.getProgressRewardRedDotStyle(player, seasonId)
	seasonId = seasonId or player and player.homeSeasonId or 0

	if not HomeSeasonUtils.isSeasonAvailable(player) or player.homeSeasonId ~= seasonId then
		return RedDotConst.RedDotStyle.NONE
	end

	local rewardStateMap = player.homeSeasonCollectionRewardStateMap or {}

	for rewardRowId, rewardInfo in pairs(HomeSeasonCollectionRewardData) do
		if rewardInfo.seasonId == seasonId and rewardStateMap[rewardRowId] == HomeSeasonUtils.COLLECTION_REWARD_STATE_CAN_RECEIVE then
			return RedDotConst.RedDotStyle.REWARD
		end
	end

	return RedDotConst.RedDotStyle.NONE
end

function HomeSeasonUtils.hasReceivableHomeSeasonDailyTaskReward(player, seasonId)
	seasonId = seasonId or player and player.homeSeasonId or 0

	if not HomeSeasonUtils.isSeasonAvailable(player) or player.homeSeasonId ~= seasonId then
		return false
	end

	local stageId = player.homeSeasonStageId
	local taskStateMap = player.homeSeasonTaskStateMap or EMPTY_TABLE
	local pendingRewardMap = player.homeSeasonTaskPendingRewardMap or EMPTY_TABLE

	for taskId, taskInfo in pairs(HomeSeasonDailyTaskData) do
		if taskInfo.seasonId == seasonId then
			local pendingRewardCount = pendingRewardMap[taskId] or 0
			local isCurrentStage = false
			local configuredStageIds = taskInfo.stageId

			if type(configuredStageIds) == "number" then
				isCurrentStage = configuredStageIds == stageId
			elseif type(configuredStageIds) == "table" or type(configuredStageIds) == "userdata" then
				for _, configuredStageId in pairs(configuredStageIds) do
					if configuredStageId == stageId then
						isCurrentStage = true

						break
					end
				end
			end

			if (pendingRewardCount > 0 or isCurrentStage) and (pendingRewardCount > 0 or taskStateMap[taskId] == ActivityConst.TaskState.Finihed_CanRecv) then
				return true
			end
		end
	end

	return false
end

function HomeSeasonUtils.isStageModuleEnabled(seasonId, stageId, moduleId)
	if not seasonId or not stageId or not moduleId then
		return false
	end

	local stageInfo = HomeSeasonStageData[stageId]

	if not stageInfo or stageInfo.seasonId ~= seasonId then
		return false
	end

	for _, configId in ipairs(stageInfo.moduleList or EMPTY_TABLE) do
		if configId == moduleId then
			return true
		end
	end

	return false
end

function HomeSeasonUtils.getCurrentStageId(seasonId, now)
	now = now or Time.secondCache or Time.getSecond()

	if not HomeSeasonUtils.isSeasonOpen(seasonId, now) then
		return 0
	end

	local matchedStageId = 0

	for stageId, stageInfo in pairs(HomeSeasonStageData) do
		if stageInfo.seasonId == seasonId then
			local startTime = Utils.getConfigTimeOfAreaByData(stageInfo.startDayTime, stageInfo.startDayTimeRefId)
			local endTime = Utils.getConfigTimeOfAreaByData(stageInfo.endDayTime, stageInfo.endDayTimeRefId)

			if startTime and endTime and startTime <= now and now <= endTime and matchedStageId < stageId then
				matchedStageId = stageId
			end
		end
	end

	return matchedStageId
end

function HomeSeasonUtils.getUnfinishedPreQuestId(player)
	local questId = HomeSeasonConfigData.homeSeasonPreQuest

	if player and questId and questId ~= 0 and not QuestCommonUtils.questCompleted(player, questId) then
		return questId
	end

	return nil
end

function HomeSeasonUtils.getFirstUnfinishedStageQuestId(player, now)
	local seasonId = player and (player.homeSeasonId or 0) or 0
	local currentStageId = HomeSeasonUtils.getCurrentStageId(seasonId, now)
	local currentStageInfo = HomeSeasonStageData[currentStageId]

	if not player or not currentStageInfo or currentStageInfo.seasonId ~= seasonId then
		return nil
	end

	local stageList = {}

	for stageId, stageInfo in pairs(HomeSeasonStageData) do
		if stageInfo.seasonId == seasonId then
			table.insert(stageList, {
				id = stageId,
				info = stageInfo,
				startTime = Utils.getConfigTimeOfAreaByData(stageInfo.startDayTime, stageInfo.startDayTimeRefId)
			})
		end
	end

	table.sort(stageList, function(lhs, rhs)
		if lhs.startTime ~= rhs.startTime then
			if lhs.startTime == nil then
				return false
			elseif rhs.startTime == nil then
				return true
			end

			return lhs.startTime < rhs.startTime
		end

		return lhs.id < rhs.id
	end)

	for _, stage in ipairs(stageList) do
		local questId = stage.info.stageQuestId

		if questId and questId ~= 0 and not QuestCommonUtils.questCompleted(player, questId) then
			return questId
		end

		if stage.id == currentStageId then
			break
		end
	end

	return nil
end

function HomeSeasonUtils.getTraceableHomeSeasonQuestId(player, questId, visitedQuestIds)
	if not player or not questId or questId == 0 then
		return nil
	end

	visitedQuestIds = visitedQuestIds or {}

	if visitedQuestIds[questId] then
		return nil
	end

	visitedQuestIds[questId] = true

	local questState = QuestCommonUtils.getQuestState(player, questId)

	if questState == QuestConst.QUEST_STATE.UNRECEIVE or questState == QuestConst.QUEST_STATE.RECEIVED then
		return questId
	end

	if questState ~= QuestConst.QUEST_STATE.INIT then
		return nil
	end

	local QuestUtils = require("GameApp.Quest.QuestUtils")
	local questConfig = QuestUtils.getQuestConfig(questId)

	for _, preQuestIds in pairs(questConfig and questConfig.preQuests or {}) do
		if type(preQuestIds) == "table" then
			for _, preQuestId in ipairs(preQuestIds) do
				local traceQuestId = HomeSeasonUtils.getTraceableHomeSeasonQuestId(player, preQuestId, visitedQuestIds)

				if traceQuestId then
					return traceQuestId
				end
			end
		end
	end

	return nil
end

function HomeSeasonUtils.acceptAndTraceHomeSeasonQuest(player, questId)
	local traceQuestId = HomeSeasonUtils.getTraceableHomeSeasonQuestId(player, questId)

	if not traceQuestId then
		return false
	end

	local QuestUtils = require("GameApp.Quest.QuestUtils")
	local questState = QuestCommonUtils.getQuestState(player, traceQuestId)

	if questState == QuestConst.QUEST_STATE.UNRECEIVE then
		player:acceptQuest(traceQuestId, function(retStatus, acceptedQuestId)
			if retStatus and retStatus.status then
				QuestUtils.questManualForce(acceptedQuestId or traceQuestId, 1)
			end
		end)

		return true
	elseif questState == QuestConst.QUEST_STATE.RECEIVED then
		QuestUtils.questManualForce(traceQuestId, 1)

		return true
	end

	return false
end

function HomeSeasonUtils.getNextStageChangeTime(seasonId, now)
	now = now or Time.secondCache or Time.getSecond()

	local nextChangeTime

	for _, stageInfo in pairs(HomeSeasonStageData) do
		if stageInfo.seasonId == seasonId then
			local startTime = Utils.getConfigTimeOfAreaByData(stageInfo.startDayTime, stageInfo.startDayTimeRefId)
			local endTime = Utils.getConfigTimeOfAreaByData(stageInfo.endDayTime, stageInfo.endDayTimeRefId)

			if startTime and now < startTime and (not nextChangeTime or startTime < nextChangeTime) then
				nextChangeTime = startTime
			end

			local closeTime = endTime and endTime + 1

			if closeTime and now < closeTime and (not nextChangeTime or closeTime < nextChangeTime) then
				nextChangeTime = closeTime
			end
		end
	end

	return nextChangeTime
end

function HomeSeasonUtils.isModuleOpen(seasonId, moduleId, now)
	if not seasonId or not moduleId then
		return false
	end

	now = now or Time.secondCache or Time.getSecond()

	if not HomeSeasonUtils.isSeasonOpen(seasonId, now) then
		return false
	end

	local stageId = HomeSeasonUtils.getCurrentStageId(seasonId, now)

	if stageId == 0 then
		return false
	end

	local moduleInfo = HomeSeasonModuleData[moduleId]

	if not moduleInfo or moduleInfo.seasonId ~= seasonId or not HomeSeasonUtils.isStageModuleEnabled(seasonId, stageId, moduleId) then
		return false
	end

	local startTime = Utils.getConfigTimeOfAreaByData(moduleInfo.startDayTime, moduleInfo.startDayTimeRefId)
	local endTime = Utils.getConfigTimeOfAreaByData(moduleInfo.endDayTime, moduleInfo.endDayTimeRefId)

	if moduleInfo.startDayTimeRefId and moduleInfo.startDayTimeRefId ~= 0 and startTime == nil or moduleInfo.endDayTimeRefId and moduleInfo.endDayTimeRefId ~= 0 and endTime == nil then
		return false
	end

	return (not startTime or startTime <= now) and (not endTime or now <= endTime)
end

function HomeSeasonUtils.isCollectionModuleOpen(seasonId, now)
	local seasonInfo = HomeSeasonData[seasonId]

	return seasonInfo ~= nil and HomeSeasonUtils.isModuleOpen(seasonId, seasonInfo.progressRefId, now)
end

function HomeSeasonUtils.getCollectionPointPerItem(itemId, now)
	if not itemId then
		return nil
	end

	now = now or Time.secondCache or Time.getSecond()

	for _, collectionInfo in pairs(HomeSeasonCollectionItemData) do
		if collectionInfo.itemId == itemId and (collectionInfo.pointPerItem or 0) > 0 and HomeSeasonUtils.isCollectionModuleOpen(collectionInfo.seasonId, now) then
			return collectionInfo.pointPerItem, collectionInfo.seasonId
		end
	end

	return nil
end

function HomeSeasonUtils.isHomeSeasonMutationCropItem(seasonId, itemId)
	local cropInfo = itemId and HomeSeasonMutationCollectionData[itemId]

	return cropInfo ~= nil and cropInfo.seasonId == seasonId
end

function HomeSeasonUtils.getHomeSeasonMutationItemCount(player, itemId)
	if not player or not itemId then
		return 0
	end

	local itemCount = ItemUtils.getItemCountById(player, itemId)

	if player:isInSelfHomeland() then
		itemCount = itemCount + ItemUtils.getWareHouseItemCount(player, itemId)
	end

	return itemCount
end

function HomeSeasonUtils.hasCollectableHomeSeasonMutationCrop(player, seasonId, typeId)
	if not player then
		return false
	end

	local collectedMap = player.homeSeasonMutationCollectedMap or {}

	for itemId, cropInfo in pairs(HomeSeasonMutationCollectionData) do
		if cropInfo.seasonId == seasonId and (typeId == nil or cropInfo.typeid == typeId) and collectedMap[itemId] == nil and HomeSeasonUtils.getHomeSeasonMutationItemCount(player, itemId) > 0 then
			return true
		end
	end

	return false
end

function HomeSeasonUtils.hasReceivableHomeSeasonMutationReward(player, seasonId)
	if not player then
		return false
	end

	local starBySeason = player.homeSeasonMutationStarBySeason or {}
	local receivedMap = player.homeSeasonMutationRewardReceived or {}
	local currentStar = starBySeason[seasonId] or 0

	for rewardId, rewardInfo in pairs(HomeSeasonMutationCollectionRewardData) do
		if rewardInfo.seasonId == seasonId and currentStar >= (rewardInfo.needPoint or 0) and receivedMap[rewardId] ~= true then
			return true
		end
	end

	return false
end

function HomeSeasonUtils.isHomeSeasonModuleEntryNew(player, redDotPath)
	if not player or not redDotPath then
		return false
	end

	return player:getRedDotRecord(Const.CLIENT_KEY.EVENT_RED_DOT, redDotPath, true)
end

function HomeSeasonUtils.markHomeSeasonModuleEntryViewed(player, redDotPath)
	if not player or not redDotPath then
		return false
	end

	return player:setRedDotRecord(Const.CLIENT_KEY.EVENT_RED_DOT, redDotPath, false)
end

function HomeSeasonUtils.getHomeSeasonModuleRedDotPath(seasonId, moduleType)
	if moduleType == Const.HOMELAND_SEASON_MODULE_TYPE.DAILY_QUEST then
		return string.format(RedDotConst.RedDotPath.HOME_SEASON_DAILY_QUEST_ENTRY, seasonId)
	elseif moduleType == Const.HOMELAND_SEASON_MODULE_TYPE.ITEM_COLLECT then
		return string.format(RedDotConst.RedDotPath.HOME_SEASON_ITEM_COLLECT_ENTRY, seasonId)
	elseif moduleType == Const.HOMELAND_SEASON_MODULE_TYPE.PREPARE_QUEST then
		return string.format(RedDotConst.RedDotPath.HOME_SEASON_PREPARE_QUEST_ENTRY, seasonId)
	elseif moduleType == Const.HOMELAND_SEASON_MODULE_TYPE.PARTY then
		return string.format(RedDotConst.RedDotPath.HOME_SEASON_PARTY_ENTRY, seasonId)
	end
end

function HomeSeasonUtils.getHomeSeasonModuleRedDotStyle(player, seasonId, moduleId, moduleType, redDotPath)
	if not HomeSeasonUtils.isModuleOpen(seasonId, moduleId) then
		return RedDotConst.RedDotStyle.NONE
	end

	if moduleType == Const.HOMELAND_SEASON_MODULE_TYPE.DAILY_QUEST then
		if HomeSeasonUtils.hasReceivableHomeSeasonDailyTaskReward(player, seasonId) then
			return RedDotConst.RedDotStyle.REWARD
		end
	elseif moduleType == Const.HOMELAND_SEASON_MODULE_TYPE.ITEM_COLLECT then
		if HomeSeasonUtils.hasReceivableHomeSeasonMutationReward(player, seasonId) then
			return RedDotConst.RedDotStyle.REWARD
		end

		if HomeSeasonUtils.hasCollectableHomeSeasonMutationCrop(player, seasonId) then
			return RedDotConst.RedDotStyle.POINT
		end
	end

	redDotPath = redDotPath or HomeSeasonUtils.getHomeSeasonModuleRedDotPath(seasonId, moduleType)

	if HomeSeasonUtils.isHomeSeasonModuleEntryNew(player, redDotPath) then
		return RedDotConst.RedDotStyle.NEW
	end

	return RedDotConst.RedDotStyle.NONE
end

function HomeSeasonUtils.getHomeSeasonRedDotStyle(player, seasonId)
	seasonId = seasonId or player and player.homeSeasonId or 0

	if not HomeSeasonUtils.isSeasonAvailable(player) or player.homeSeasonId ~= seasonId then
		return RedDotConst.RedDotStyle.NONE
	end

	local seasonInfo = HomeSeasonData[seasonId]
	local styleList = {
		HomeSeasonUtils.getProgressRewardRedDotStyle(player, seasonId)
	}

	for _, moduleId in ipairs(seasonInfo.funcRefIds or EMPTY_TABLE) do
		local moduleInfo = HomeSeasonModuleData[moduleId]

		if moduleInfo and moduleInfo.seasonId == seasonId then
			styleList[#styleList + 1] = HomeSeasonUtils.getHomeSeasonModuleRedDotStyle(player, seasonId, moduleId, moduleInfo.type)
		end
	end

	local redDotStyle = RedDotUtils.calculateRedDotPriority(styleList)

	if redDotStyle == RedDotConst.RedDotStyle.NEW then
		return RedDotConst.RedDotStyle.NONE
	end

	return redDotStyle
end

return HomeSeasonUtils
