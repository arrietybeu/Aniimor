-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\SchoolGuide\\SchoolGuideModel.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local logger = require("Core.Log.LoggerManager").getLogger("SchoolGuideModel")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local SceneUtils = require("Common.Utils.SceneUtils")
local MapBossMarkPointData = require("Data.map_boss_mark_point_data")
local RogueDifficultyData = require("Data.rogue_difficulty_data")
local RogueUtils = require("Utils.RogueUtils")
local PuppetData = require("Data.puppet_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ActivityConst = require("Common.Const.ActivityConst")
local AddressDataConst = require("Const.AddressDataConst")
local RoguelikeData = require("Data.roguelike_data")
local LevelRewardLinkedData = require("Data.level_reward_linked_data")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local ClientUtils = require("Utils.ClientUtils")
local Const = require("Common.Const.Const")
local schoolData = require("Data.college_guide_page_data")
local schoolSubData = require("Data.college_guide_subpage_data")
local RogueTalentUtils = require("Common.Utils.RogueTalentUtils")
local CommonSwitch = require("Common.CommonSwitch")
local SchoolGuideConst = require("Common.Const.SchoolGuideConst")
local ClientConst = require("Const.ClientConst")
local ClientActivityUtils = require("Utils.ClientActivityUtils")
local ItemConst = require("Common.Const.ItemConst")
local ItemCompoundData = require("Data.item_compound_data")
local DropData = require("Data.drop_data")
local SchoolGuideCraftData = require("Data.school_guide_craft_data")
local ItemData = require("Data.item_data")
local HomeObjectData = require("Data.home_object_data")
local FunctionEnum = require("Data.function_unlock_enum")
local BOSS_MARK_TYPE = 10304
local LEADER_MARK_TYPE = 10404
local UIModel = require("Guis.UIModel")
local SchoolGuideModel = Class.LightClass("SchoolGuideModel", UIModel)

SchoolGuideModel.IMO_LIST_ITEM_TINDEX = {
	IMO = 0,
	MOCK_DIFF = 1
}
SchoolGuideModel.ITEM_CRAFT_TITLE = {
	Item2 = 2,
	Item1 = 1
}

function SchoolGuideModel:getFirstTabList()
	local tabList = {}

	for k, v in ipairs(schoolData) do
		if v.switch == 1 then
			local switchName = v.switchName and "SCHOOLGUIDE_" .. v.switchName or nil

			if switchName and CommonSwitch[switchName] == true then
				local unlock = true

				if k == SchoolGuideConst.EventType.ItemCraft then
					unlock = pg.me:isFunctionAndSwitchEnable(FunctionEnum.HOMELAND)
				end

				if unlock and (self._checkConfigCondition(v.conditions) == true or v.alwaysShow == true) then
					local tabCfgOne = {
						icon = v.icon,
						cfgId = k,
						order = v.rank,
						tabType = k,
						tabName = v.name
					}

					table.insert(tabList, tabCfgOne)
				end
			end
		end
	end

	table.sort(tabList, function(a, b)
		if a.order ~= b.order then
			return a.order < b.order
		else
			return a.cfgId < b.cfgId
		end
	end)

	return tabList
end

SchoolGuideModel.SECOND_TAB_TYPE_2_ICON_TYPE = {
	[SchoolGuideConst.SecondPageType.LEADER] = 0,
	[SchoolGuideConst.SecondPageType.BOSS] = 1,
	[SchoolGuideConst.SecondPageType.MOCK] = 2
}

function SchoolGuideModel:getSecondTabList(mainTabType)
	local res = {}
	local subData = schoolSubData[mainTabType]

	if not subData then
		return res
	end

	for subId, info in pairs(subData) do
		if info.switch == 1 then
			local switchName = info.switchName and "SCHOOLGUIDE_SUB_" .. info.switchName or nil

			if switchName and CommonSwitch[switchName] == true and (self._checkConfigCondition(info.conditions) == true or info.alwaysShow == true) then
				res[#res + 1] = {
					tabTitle = info.name,
					tabDescribe = info.desc,
					secondTabType = subId,
					iconType = SchoolGuideModel.SECOND_TAB_TYPE_2_ICON_TYPE[subId],
					cfgId = subId,
					order = info.rank,
					stageTypeGroup = info.type
				}
			end
		end
	end

	table.sort(res, function(a, b)
		if a.order ~= b.order then
			return a.order < b.order
		else
			return a.cfgId < b.cfgId
		end
	end)

	return res
end

function SchoolGuideModel:getCommonList(mainTabType, secondTabType)
	if not mainTabType or not secondTabType then
		return {}
	end

	if mainTabType == SchoolGuideConst.EventType.BossChallenge then
		if secondTabType == SchoolGuideConst.SecondPageType.BOSS or schoolSubData[mainTabType] and schoolSubData[mainTabType][secondTabType] then
			return self:getGuideBookBossList(secondTabType)
		end
	elseif mainTabType == SchoolGuideConst.EventType.BattleChallenge and secondTabType == SchoolGuideConst.SecondPageType.MOCK then
		return self:getMockBattleInfo()
	end

	return {}
end

function SchoolGuideModel:getGuideBookBossList(secondTabType)
	local sceneIdList = {
		3000,
		3003
	}
	local markMap = pg.me.mapMarkStatusMap
	local subCfg = schoolSubData[SchoolGuideConst.EventType.BossChallenge] and schoolSubData[SchoolGuideConst.EventType.BossChallenge][secondTabType]
	local stageTypeGroup = subCfg and subCfg.type
	local res = {}

	for _, sceneId in ipairs(sceneIdList) do
		local scenePointData = SceneUtils.getSceneMarkPointData(sceneId)
		local sceneEntityData = SceneUtils.getSceneEntityData(sceneId)
		local idList = {}

		for _, markType in ipairs({
			BOSS_MARK_TYPE,
			LEADER_MARK_TYPE
		}) do
			local data = MapBossMarkPointData[sceneId] and MapBossMarkPointData[sceneId][markType]

			for _, ids in pairs(data or EMPTY_TABLE) do
				for _, id in ipairs(ids or EMPTY_TABLE) do
					idList[#idList + 1] = {
						markType = markType,
						id = id
					}
				end
			end
		end

		for _, info in ipairs(idList) do
			local id = info.id
			local isLeader = info.markType == LEADER_MARK_TYPE
			local isBoss = info.markType == BOSS_MARK_TYPE
			local pointData = scenePointData[id]
			local entityData = pointData and sceneEntityData[pointData.entityId]
			local pData = entityData and PuppetData[entityData.idInType]
			local linkedData = LevelRewardLinkedData[id]

			if stageTypeGroup and (not linkedData or linkedData.stageTypeGroup ~= stageTypeGroup) then
				-- block empty
			else
				local state = markMap:getStatus(sceneId, pointData.markType, id)

				if pData then
					local costRes = self:getBossCostInfo(id)
					local rewardItems = self:getPlayerLevelPeriodRewards(id, state)

					if costRes and rewardItems then
						local name

						if state < Const.MAP_MARK_STATUS_UNLOCKED then
							name = isLeader and pg.getGameString("SCHOOL_GUIDE_HEAD_LOCK_TIP") or pg.getGameString("SCHOOL_GUIDE_BOSS_LOCK_TIP")
						else
							name = pData.name
						end

						res[#res + 1] = {
							downDes = "",
							tIndex = SchoolGuideModel.IMO_LIST_ITEM_TINDEX.IMO,
							markStaticId = id,
							traceId = linkedData.traceId,
							stageBossTip = linkedData.stageBossTip,
							markState = state,
							markType = pointData.markType,
							sceneId = sceneId,
							idInType = entityData.idInType,
							entityId = pointData.entityId,
							sceneId = sceneId,
							title = name,
							rewardItems = rewardItems,
							icon = LuaUIUtils.getPetIcon(pData.iconName, LuaUIUtils.PET_ICON),
							lock = state < Const.MAP_MARK_STATUS_UNLOCKED,
							currencyNum = costRes and costRes.costItemNum,
							currencyIcon = costRes and costRes.costItemIcon,
							describe = isLeader and pg.getGameString("SCHOOL_GUIDE_HEAD_MATERIAL_1") or pg.getGameString("SCHOOL_GUIDE_BOSS_MATERIAL"),
							element = pData.mainElementType,
							isLeader = isLeader,
							isBoss = isBoss
						}
					elseif LoggerManager.checkLogger(LoggerConst.WARN) then
						logger:warn("SchoolGuideModel getGuideBookBossList, but no config markStaticId: %s entityTemplateId:%s", id, pointData.entityId)
					end
				end
			end
		end
	end

	local STATE2PRI = {
		[Const.MAP_MARK_STATUS_UNLOCKED] = 10,
		[Const.MAP_MARK_STATUS_CLOSED] = 9
	}

	local function sortFunc(a, b)
		if a.markState ~= b.markState then
			local aPri = STATE2PRI[a.markState] or 0
			local bPri = STATE2PRI[b.markState] or 0

			return bPri < aPri
		end

		local aLinked = LevelRewardLinkedData[a.markStaticId]
		local bLinked = LevelRewardLinkedData[b.markStaticId]
		local aSort = aLinked and aLinked.stageSortPriority or math.huge
		local bSort = bLinked and bLinked.stageSortPriority or math.huge

		if aSort ~= bSort then
			return aSort < bSort
		end

		if a.markStaticId ~= b.markStaticId then
			return a.markStaticId < b.markStaticId
		end

		return false
	end

	table.sort(res, sortFunc)

	return res
end

function SchoolGuideModel:getMockBattleInfo()
	local res = {}
	local key2ResIdx = {}

	for levelId, info in ipairs(RogueDifficultyData) do
		local key = info.elementType .. "_" .. info.difficultyLv
		local idx = key2ResIdx[key]
		local rogueData = info.roguelikeIDEnd and RoguelikeData[info.roguelikeIDEnd]

		if not idx then
			local tempIdx = #res + 1

			key2ResIdx[key] = tempIdx
			res[tempIdx] = {
				totalStarNum = 1,
				downDes = "",
				tIndex = SchoolGuideModel.IMO_LIST_ITEM_TINDEX.IMO,
				levelId = levelId,
				title = pg.getLocalizationText(info.levelName),
				icon = info.hoverIcon,
				lock = not RogueUtils.checkLevelUnlock(levelId),
				element = info.elementName,
				firstRewardId = info.firstClearReward,
				rewardItems = rogueData and self:getRogueClearReward(info) or {},
				currencyNum = rogueData and rogueData.rogueStaminaRewardCost or 0,
				currencyIcon = LuaUIUtils.getIconByItemId(1009),
				describe = pg.getGameString("SCHOOL_GUIDE_TRAIN_MATERIAL"),
				difficultyLv = info.difficultyLv,
				starNum = RogueUtils.checkLevelPass(levelId) and 1 or 0
			}
		else
			local hasPass = RogueUtils.checkLevelPass(levelId)

			if hasPass then
				res[idx].starNum = res[idx].starNum + 1
				res[idx].title = pg.getLocalizationText(info.levelName)
				res[idx].icon = info.hoverIcon
				res[idx].lock = not RogueUtils.checkLevelUnlock(levelId)
				res[idx].element = info.elementName
				res[idx].firstRewardId = info.firstClearReward
				res[idx].rewardItems = rogueData and self:getRogueClearReward(info) or {}
				res[idx].currencyNum = rogueData and rogueData.rogueStaminaRewardCost or 0
				res[idx].levelId = levelId
			end

			res[idx].totalStarNum = res[idx].totalStarNum + 1
		end
	end

	table.sort(res, function(a, b)
		if a.difficultyLv ~= b.difficultyLv then
			return a.difficultyLv < b.difficultyLv
		elseif a.lock ~= b.lock then
			return a.lock ~= true
		else
			return a.levelId < b.levelId
		end
	end)

	local lastDifficultyLv = 0
	local insertIdx = 1

	for index, info in ipairs(res) do
		if info.difficultyLv ~= lastDifficultyLv then
			insertIdx = index

			break
		end
	end

	table.insert(res, insertIdx, {
		difficultyLv = 1,
		tIndex = SchoolGuideModel.IMO_LIST_ITEM_TINDEX.MOCK_DIFF,
		title = pg.getGameString("SCHOOL_GUIDE_TRAINING_LEVEL_2")
	})
	table.insert(res, 1, {
		difficultyLv = 0,
		tIndex = SchoolGuideModel.IMO_LIST_ITEM_TINDEX.MOCK_DIFF,
		title = pg.getGameString("SCHOOL_GUIDE_TRAINING_LEVEL_1")
	})

	return res
end

function SchoolGuideModel:getItemCraftInfo(compoundId)
	local info = {}
	local currencyId
	local currencyCost = 0
	local compoundCfg = ItemCompoundData[compoundId]

	if not compoundCfg then
		return
	end

	local rData = DropData[compoundCfg.reward]

	if not rData then
		return
	end

	local costList = {}

	if compoundCfg.material and next(compoundCfg.material) then
		for _, materialInfo in ipairs(compoundCfg.material) do
			local itemCfg = ItemData[materialInfo[1]]

			if itemCfg and itemCfg.type == ItemConst.ITEM_TYPE.Currency then
				currencyId = materialInfo[1]
				currencyCost = materialInfo[2]
			else
				costList[#costList + 1] = {
					propId = materialInfo[1],
					countNeed = materialInfo[2]
				}
			end
		end
	end

	local getList = {}

	if rData.displayReward and next(rData.displayReward) then
		for _, value in ipairs(rData.displayReward) do
			getList[#getList + 1] = {
				propId = value[1],
				countNeed = value[2]
			}
		end
	end

	info.costList = costList
	info.getList = getList

	local firstReward = getList[1]
	local configData = firstReward and ItemData[firstReward.propId]

	if configData then
		info.quality = configData.quality
	end

	if firstReward then
		info.craftName = LuaUIUtils.getNameByItemId(firstReward.propId)
		info.craftIcon = LuaUIUtils.getIconByItemId(firstReward.propId, LuaUIUtils.ITEM_ICON_TYPE.ICON_NORMAL)
	end

	info.currencyCost = currencyCost
	info.currencyIcon = currencyId and LuaUIUtils.getIconByItemId(currencyId, LuaUIUtils.ITEM_ICON_TYPE.ICON_SMALL) or nil
	info.costEnough = LuaUIUtils.checkCompositeCountLimit(compoundCfg, 1, true)
	info.currencyId = currencyId

	return info
end

function SchoolGuideModel:getItemCraftList()
	local res = {}

	res[1] = {
		tIndex = 1,
		title = pg.getGameString("SCHOOL_GUIDE_CRAFT_TYPE_1")
	}

	local type

	for index, info in ipairs(SchoolGuideCraftData) do
		if not type then
			type = info.typeId
		elseif type ~= info.typeId then
			res[#res + 1] = {
				tIndex = 1,
				title = pg.getGameString("SCHOOL_GUIDE_CRAFT_TYPE_2")
			}
			type = info.typeId
		end

		local unlock = false
		local unlockDesc

		if info.facilityId and next(info.facilityId) and pg.me.statHomelandOrnament and next(pg.me.statHomelandOrnament) then
			for i, v in pairs(info.facilityId) do
				if pg.me.statHomelandOrnament[v] then
					unlock = true
				end
			end

			if not unlock then
				local homeFacilityCfg = HomeObjectData[info.facilityId[1]]

				if homeFacilityCfg then
					unlockDesc = pg.getFormatText(pg.getGameString("SCHOOL_GUIDE_CRAFT_LOCK_TIP"), pg.getLocalizationText(homeFacilityCfg.name))
				end
			end
		end

		res[#res + 1] = {
			tIndex = 0,
			typeId = info.typeId,
			craftId = info.craftId,
			unlock = unlock,
			unlockDesc = unlockDesc
		}
	end

	return res
end

function SchoolGuideModel:getRogueExchangeRewardItems(rogueData)
	local rewardIds = rogueData.rogueStaminaRewardSet
	local rewardId

	if not RogueTalentUtils.func(pg.me, "rogueStaminaDropId") or RogueTalentUtils.func(pg.me, "rogueStaminaDropId") == 0 then
		rewardId = rewardIds[1]
	else
		rewardId = rewardIds[RogueTalentUtils.func(pg.me, "rogueStaminaDropId")]
	end

	return LuaUIUtils.getRewardItemByDropId(rewardId)
end

function SchoolGuideModel:getRogueClearReward(difficultyCfg)
	return LuaUIUtils.getRewardItemByDropId(difficultyCfg.guideReward)
end

function SchoolGuideModel:getPlayerLevelPeriodRewards(spawnerId, markStatus)
	if not pg.me then
		return nil
	end

	local levelLinkedData = LevelRewardLinkedData[spawnerId]

	if not levelLinkedData then
		return nil
	end

	if not levelLinkedData.cost then
		return nil
	end

	local costItemIcon = LuaUIUtils.getIconByItemId(levelLinkedData.cost[1])
	local costItemNum = levelLinkedData.cost[2]
	local ret = {}

	ret.level = pg.me.starTitle

	if not ret.level then
		return nil
	end

	if not levelLinkedData.periodRewardId then
		return nil
	end

	if not levelLinkedData.periodRewardId[ret.level] then
		return nil
	end

	ret.itemCountTable = {}

	if markStatus < Const.MAP_MARK_STATUS_CLOSED and levelLinkedData.showRewardId then
		local firstRewardItems = LuaUIUtils.getRewardItemByDropId(levelLinkedData.showRewardId, nil, nil, true)

		for _, rewardItem in ipairs(firstRewardItems) do
			ret.itemCountTable[#ret.itemCountTable + 1] = rewardItem
		end
	end

	local periodRewardItems = LuaUIUtils.getRewardItemByDropId(levelLinkedData.periodRewardId[ret.level])

	for _, rewardItem in ipairs(periodRewardItems) do
		ret.itemCountTable[#ret.itemCountTable + 1] = rewardItem
	end

	ret.costItemIcon = costItemIcon
	ret.costItemNum = costItemNum
	ret.costItemId = levelLinkedData.cost[1]

	return ret.itemCountTable
end

function SchoolGuideModel:getBossCostInfo(markStaticId)
	if not pg.me then
		return nil
	end

	local levelLinkedData = LevelRewardLinkedData[markStaticId]

	if not levelLinkedData then
		return nil
	end

	if not levelLinkedData.cost then
		return nil
	end

	local costItemIcon = LuaUIUtils.getIconByItemId(levelLinkedData.cost[1])
	local costItemNum = levelLinkedData.cost[2]
	local ret = {}

	ret.level = pg.me.starTitle

	if not ret.level then
		return nil
	end

	if not levelLinkedData.periodRewardId then
		return nil
	end

	if not levelLinkedData.periodRewardId[ret.level] then
		return nil
	end

	ret.itemCountTable = LuaUIUtils.getRewardItemByDropId(levelLinkedData.periodRewardId[ret.level])
	ret.costItemIcon = costItemIcon
	ret.costItemNum = costItemNum
	ret.costItemId = levelLinkedData.cost[1]

	return ret
end

function SchoolGuideModel:getDailyActiveRewardDataList()
	local isOpen, activityId = ActivityUtils.isOprActivityOpenByType(ActivityConst.EventType.DailyActive)

	if not isOpen then
		return {}
	end

	local playerActivityDailyActive = ActivityUtils.getActivityData(pg.me, ActivityConst.EventType.DailyActive)
	local _, rewardTaskList = self:getDailyActiveTaskDataList()
	local res = {}
	local lastScore = 0
	local curScore = playerActivityDailyActive.dailyActiveScore

	for index, rewardTask in ipairs(rewardTaskList) do
		lastScore = index > 1 and rewardTaskList[index - 1].targetNum or 0

		local state

		if rewardTask.taskState == ActivityConst.TaskState.Received then
			state = ClientConst.RewardState.Claimed
		elseif rewardTask.taskState == ActivityConst.TaskState.Finihed_CanRecv then
			state = ClientConst.RewardState.ReadyToClaim
		elseif rewardTask.taskState == ActivityConst.TaskState.UnFinished then
			state = ClientConst.RewardState.NotAchieved
		end

		res[#res + 1] = {
			targetNum = rewardTask.targetNum,
			index = index,
			dropId = rewardTask.taskAward,
			progress = lastScore < rewardTask.targetNum and (curScore - lastScore) / (rewardTask.targetNum - lastScore) or 1,
			state = state,
			taskId = rewardTask.taskId
		}
	end

	return res
end

function SchoolGuideModel:getDailyActiveTaskDataList()
	local allTaskData = ClientActivityUtils.getTaskInfoByActType(ActivityConst.EventType.DailyActive)

	if not allTaskData then
		return {}
	end

	local commonDataList = {}
	local rewardDataList = {}

	for index, taskData in pairs(allTaskData) do
		if taskData.taskType == ActivityConst.ActivityTaskType.DailyActive_GetScore then
			table.insert(commonDataList, taskData)
		elseif taskData.taskType == ActivityConst.ActivityTaskType.DailyActive_ScoreReward then
			taskData.targetNum = LuaUIUtils.getActScoreCondition(taskData.taskCondition)
			taskData.dropId = taskData.taskAward

			table.insert(rewardDataList, taskData)
		end
	end

	table.sort(commonDataList, function(a, b)
		local aTaskState = a.taskState
		local bTaskState = b.taskState

		if ActivityConst.TaskSortPri[aTaskState] ~= ActivityConst.TaskSortPri[bTaskState] then
			return ActivityConst.TaskSortPri[aTaskState] > ActivityConst.TaskSortPri[bTaskState]
		else
			return a.taskId < b.taskId
		end
	end)
	table.sort(rewardDataList, function(a, b)
		if a.sort ~= b.sort then
			return a.sort < b.sort
		else
			return a.taskId < b.taskId
		end
	end)

	return commonDataList, rewardDataList
end

function SchoolGuideModel._checkConfigCondition(conditionId)
	if conditionId == nil then
		return true
	end

	return ClientUtils.checkCondition(conditionId)
end

function SchoolGuideModel:isHomelandUnlocked()
	return LuaUIUtils.checkFuncUnlock(Const.FUNCTION_IDS.HOMELAND)
end

function SchoolGuideModel:getHomeCarLevel()
	if pg.me and pg.me.homeBasicInfo then
		return pg.me.homeBasicInfo.level or 0
	end

	return 0
end

function SchoolGuideModel:getItemSynthesizeList()
	local carLevel = self:getHomeCarLevel()
	local list = {
		{
			titleKey = "SCHOOL_GUIDE_SYNTHESIZE_MAGIC_CUBE",
			icon = "",
			unlockCarLevel = 0,
			materialNeedCount = 1,
			materialItemId = 0,
			resultItemId = 0,
			synthesizeType = SchoolGuideConst.SynthesizeType.MagicCube
		},
		{
			titleKey = "SCHOOL_GUIDE_SYNTHESIZE_EXP_GEM",
			icon = "",
			unlockCarLevel = 0,
			materialNeedCount = 1,
			materialItemId = 0,
			resultItemId = 0,
			synthesizeType = SchoolGuideConst.SynthesizeType.ExpGem
		}
	}

	for _, item in ipairs(list) do
		item.carLevelEnough = carLevel >= item.unlockCarLevel
		item.ownMaterialCount = ClientUtils.getItemCountById(item.materialItemId, true)
		item.materialEnough = item.ownMaterialCount >= item.materialNeedCount
	end

	return list
end

function SchoolGuideModel:GetMockGuideData()
	local levelData = {}
	local levelTypeList = {}

	for levelId, levelInfo in ipairs(RogueDifficultyData) do
		local key = levelInfo.elementType

		if levelTypeList[key] == nil then
			levelTypeList[key] = #levelData + 1

			table.insert(levelData, {
				elementType = key,
				levels = {},
				selected = #levelData == 0
			})
		end

		local dropData = {}
		local hasGetFirst = pg.me.rogueSettlementCnt[levelInfo.roguelikeIDEnd] and pg.me.rogueSettlementCnt[levelInfo.roguelikeIDEnd] > 0

		if not hasGetFirst and levelInfo.firstClearReward then
			table.insert(dropData, {
				firstReward = true,
				dropId = levelInfo.firstClearReward
			})
		end

		if levelInfo.WeeklyRewardClient then
			table.insert(dropData, {
				dropId = levelInfo.WeeklyRewardClient
			})
		end

		local tabData = levelData[levelTypeList[key]]

		table.insert(tabData.levels, {
			levelId = levelId,
			info = levelInfo,
			dropData = dropData
		})
	end

	return levelData
end

return SchoolGuideModel
