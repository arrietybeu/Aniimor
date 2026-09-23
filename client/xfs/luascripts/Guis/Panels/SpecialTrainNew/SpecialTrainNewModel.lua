-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\SpecialTrainNew\\SpecialTrainNewModel.lua

local UIModel = require("Guis.UIModel")
local Class = require("Core.Framework.Class")
local QuestUtils = require("GameApp.Quest.QuestUtils")
local QuestConst = require("Common.Const.QuestConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Bitset = require("Common.Bitset")
local SpecialTrainNewModel = Class.LightClass("SpecialTrainNewModel", UIModel)
local SpecialTrainChapterData = require("Data.special_train_chapter_data")
local SpecialTrainTypeData = require("Data.special_train_type_data")
local SpecialTrainEntryData = require("Data.special_train_entry_data")
local SpecialTrainBadgeData = require("Data.special_train_badge_data")
local SpecialTrainGroupRevertData = require("Data.special_train_group_chapter_revert_data")
local GuideCourseData = require("Data.guide_course_data")
local RedDotConst = require("Const.RedDotConst")
local Const = require("Common.Const.Const")
local SysConfigData = require("Data.sys_config_data")
local Time = require("Core.Common.Time")

SpecialTrainNewModel.REWARD_NORMAL = 0
SpecialTrainNewModel.REWARD_RECEIVED = 1
SpecialTrainNewModel.REWARD_CAN_GOT = 2

local getBit = Bitset.getBit

function SpecialTrainNewModel:finishGotRewardCompulsoryNum(chapterId, questGoupId)
	local num = 0
	local mainTaskIds = SpecialTrainChapterData[chapterId].mainTaskId

	for i, v in pairs(mainTaskIds) do
		local totalStage = #SpecialTrainEntryData[v]
		local specialTrainTypeMap = pg.me.specialTrainMapMap[chapterId] or {}
		local specialTrainEntryData = QuestUtils.isHaveNumKey(specialTrainTypeMap) and specialTrainTypeMap[v] or {}

		if getBit(specialTrainEntryData.rewardFlags, totalStage) then
			num = num + 1
		end
	end

	return num
end

function SpecialTrainNewModel:getChapterTb()
	local typeTb = {}

	for id, tp in pairs(SpecialTrainChapterData) do
		local temp = {}

		temp.chapterId = id
		temp.name = self:getChapterName(id)

		table.insert(typeTb, temp)
	end

	table.sort(typeTb, function(a, b)
		return a.chapterId < b.chapterId
	end)

	return typeTb
end

function SpecialTrainNewModel:getChapterName(chapterType)
	local chapterName = SpecialTrainChapterData[chapterType].chapterName
	local chapterTitleDes = SpecialTrainChapterData[chapterType].chapterTitleDes

	return string.format("%s %s", pg.getLocalizationText(chapterName), pg.getLocalizationText(chapterTitleDes))
end

function SpecialTrainNewModel:getChapterCompulsoryList(chapterId)
	local stageListTb = {}
	local temp = {}
	local mainTaskIds = SpecialTrainChapterData[chapterId].mainTaskId
	local mustTaskNum = SpecialTrainChapterData[chapterId].mustTaskNum

	for i, v in pairs(mainTaskIds) do
		if i <= mustTaskNum then
			temp = {
				stage = i,
				chapterId = chapterId,
				taskId = v
			}

			table.insert(stageListTb, temp)
		end
	end

	return stageListTb
end

function SpecialTrainNewModel:getChapterData(chapterType)
	local chapterData = {}

	return chapterData
end

function SpecialTrainNewModel:isCanGetChapterReward(curChapterId)
	local chapterConfig = QuestUtils.getChapterConfig(curChapterId)
	local chapterStateInfo = QuestUtils.getChapterState(curChapterId)
	local totalFinishNum = chapterConfig.mustTaskNum or 0
	local curFinishNum = self:finishGotRewardCompulsoryNum(curChapterId)

	return totalFinishNum <= curFinishNum and not chapterStateInfo.isChapterRewarded
end

function SpecialTrainNewModel:getChapterPageInfo(chapterId, pageType)
	if pageType == QuestConst.QUEST_TRAIN_SUB_TYPE.COMPULSORY then
		return self:getCompulsoryPage(chapterId)
	else
		return self:getElectivePageInfo(pageType)
	end
end

function SpecialTrainNewModel:getCompulsoryPageUnlockTrace(chapterId)
	local chapterMainList = {}

	for k, m in pairs(QuestUtils.getChapterMainTaskList(chapterId, QuestConst.TRAIN_CHAPTER_COURSE_TYPE.COMPULSORY)) do
		table.insert(chapterMainList, m)
	end

	self:listSort(chapterMainList)

	local questId = 0

	if chapterMainList and #chapterMainList > 1 then
		questId = QuestUtils.getParentQuestId(chapterMainList[1].questId)
	end

	return questId
end

function SpecialTrainNewModel:getCompulsoryPage(chapterId)
	local chapterMainList = {}

	for k, m in pairs(QuestUtils.getChapterMainTaskList(chapterId, QuestConst.TRAIN_CHAPTER_COURSE_TYPE.COMPULSORY)) do
		table.insert(chapterMainList, m)
	end

	self:listSort(chapterMainList)

	return chapterMainList
end

function SpecialTrainNewModel:getElectivePageInfo(pageType)
	local pageList = {}

	for i, v in pairs(SpecialTrainChapterData) do
		if not QuestUtils.isChapterLockState(i) then
			for k, m in pairs(QuestUtils.getChapterSideTaskList(i)) do
				if pageType == m.pageType then
					table.insert(pageList, m)
				end
			end
		end
	end

	self:listSort(pageList)

	if pageList and #pageList > 0 and QuestUtils.getCurChapterId() < QuestUtils.getChapterTotalNum() then
		-- block empty
	end

	return pageList or {
		{}
	}
end

function SpecialTrainNewModel:listSort(pageList)
	for _, data in ipairs(pageList) do
		local hasGet, canGet, _, isRecommendTask = self:getSortState(data)

		data._sortHasGet = hasGet and true or false
		data._sortCanGet = canGet and true or false
		data._sortIsRecommend = isRecommendTask and true or false
	end

	table.sort(pageList, function(a, b)
		if a.sortIndex ~= b.sortIndex then
			return a.sortIndex < b.sortIndex
		end

		if a._sortCanGet ~= b._sortCanGet then
			return a._sortCanGet
		end

		if a._sortHasGet ~= b._sortHasGet then
			return b._sortHasGet
		end

		if a._sortIsRecommend ~= b._sortIsRecommend then
			return a._sortIsRecommend
		end

		return a.taskId < b.taskId
	end)
end

function SpecialTrainNewModel:getTypePageConfig(pageType)
	return SpecialTrainTypeData[pageType]
end

function SpecialTrainNewModel:getTypePageName(pageType)
	local typeName = SpecialTrainTypeData[pageType] and SpecialTrainTypeData[pageType].typeName

	return pg.getLocalizationText(typeName)
end

function SpecialTrainNewModel:getPageTypeTb()
	local typeTb = {}

	for _, tp in pairs(QuestConst.QUEST_TRAIN_SUB_TYPE) do
		local temp = {}

		temp.trainType = tp
		temp.name = self:getTypePageName(tp)

		table.insert(typeTb, temp)
	end

	table.sort(typeTb, function(a, b)
		return a.trainType < b.trainType
	end)

	return typeTb
end

function SpecialTrainNewModel:getSelectPageIndex()
	local page = QuestConst.TRAIN_PHASE.CHAPTER

	if not pg.me.isOpenedTrainInterface then
		page = QuestConst.TRAIN_PHASE.NEWBIE

		return page
	end

	return QuestConst.QUEST_TRAIN_SUB_TYPE.COMPULSORY
end

function SpecialTrainNewModel:getQuestChapterIdByTaskId(taskId)
	return SpecialTrainGroupRevertData[taskId]
end

function SpecialTrainNewModel:getSpecialTrainData(questId)
	local specialTrainData = {}
	local courseConf = {}
	local specialRevertConf = QuestUtils.getQuestRevertConfig(questId)

	if specialRevertConf then
		specialTrainData.stage = specialRevertConf.stageId or 0
		specialTrainData.taskId = specialRevertConf.taskId or 0
		specialTrainData.taskType = specialRevertConf.taskType or 0
	end

	local specialRevertConfChapterId = self:getQuestChapterIdByTaskId(specialTrainData.taskId)

	if specialRevertConfChapterId then
		specialTrainData.chapterId = specialRevertConfChapterId
	end

	local specialTrainConfig = QuestUtils.getSpecialTrainConfig(questId)

	if specialTrainConfig then
		specialTrainData.questId = questId
		specialTrainData.specialTask, specialTrainData.recommendTask, specialTrainData.isPreLock = self:isTagTask(questId)
		specialTrainData.isTrace = pg.me.curTraceSecondQuest ~= nil and questId == pg.me.curTraceSecondQuest
		courseConf = GuideCourseData[tonumber(specialTrainConfig.taskTeach)]
		specialTrainData.taskTeachName = courseConf and courseConf.title or ""
		specialTrainData.curProgress, specialTrainData.tagVar, specialTrainData.state, specialTrainData.displayType = self:getQuestObjectProgress(questId)
		specialTrainData.rewardFlags = self:getQuestItemRewardFlags(specialTrainData.chapterId, questId)
		specialTrainData.isCanGetReward = self:isCanGetReward(questId) and not specialTrainData.rewardFlags
	end

	return specialTrainData
end

function SpecialTrainNewModel:isTagTask(questId)
	local isSpecial, isRecommend, isPreLock = false, false, false
	local specialRevertConf = QuestUtils.getQuestRevertConfig(questId)

	if specialRevertConf then
		local taskId = specialRevertConf.taskId
		local taskStageCofTb = SpecialTrainEntryData[taskId][1]

		if taskStageCofTb then
			isSpecial = taskStageCofTb.specialTask and taskStageCofTb.specialTask > 0
			isRecommend = taskStageCofTb.recommendTask and taskStageCofTb.recommendTask > 0

			if taskStageCofTb and taskStageCofTb.taskPreconditions then
				isPreLock = pg.me and not pg.me.triggerMap:isCompleteOrMeetCondition(taskStageCofTb.taskPreconditions1)
			end
		end
	end

	return isSpecial, isRecommend, isPreLock
end

function SpecialTrainNewModel:getQuestObjectProgress(questId)
	local curVar, tagVar, state, displayType = 0, 0, QuestConst.QUEST_STATE.UNRECEIVE, 2
	local questData = QuestUtils.getQuestData(questId)

	if questData then
		state = questData.state
	end

	local questConfig = QuestUtils.getQuestConfig(questId)

	if questConfig ~= nil and questConfig.objectivesIDs ~= nil then
		for j = 1, #questConfig.objectivesIDs do
			local objId = questConfig.objectivesIDs[j]

			curVar = QuestUtils.getQuestDataObjVal(questId, objId)
			tagVar = QuestUtils.getQuestObjectiveTargetVal(questId, objId)
			displayType = questConfig.objectives[objId].displayType
		end
	end

	if QuestUtils.isQuestFinished(questId) then
		curVar = tagVar
		state = QuestConst.QUEST_STATE.COMPLETED
	end

	return curVar, tagVar, state, displayType
end

function SpecialTrainNewModel:getQuestItemRewardFlags(chapterId, questId)
	local revertConfig = QuestUtils.getQuestRevertConfig(questId)
	local rewardState = self.REWARD_NORMAL

	if revertConfig == nil then
		return rewardState == self.REWARD_CAN_GOT
	end

	local specialTrainTypeMap = pg.me.specialTrainMapMap[chapterId] or {}
	local specialTrainEntryData = QuestUtils.isHaveNumKey(specialTrainTypeMap) and specialTrainTypeMap[revertConfig.taskId] or {}

	if getBit(specialTrainEntryData.rewardFlags, revertConfig.stageId) then
		rewardState = self.REWARD_CAN_GOT
	end

	return rewardState == self.REWARD_CAN_GOT
end

function SpecialTrainNewModel:isCanGetReward(questId)
	local questData = QuestUtils.getQuestData(questId)

	if questData ~= nil then
		return questData.state == QuestConst.QUEST_STATE.COMPLETED
	else
		return QuestUtils.isQuestSubmitted(questId)
	end
end

function SpecialTrainNewModel:getQuestPhaseList(taskId)
	if taskId == nil or taskId == 0 then
		return {
			{}
		}
	end

	local stageListTb = {}
	local temp = {}
	local phaseList = SpecialTrainEntryData[taskId]

	if phaseList then
		for i = 1, #phaseList do
			temp = {
				stage = i
			}

			table.insert(stageListTb, temp)
		end
	else
		return {
			{}
		}
	end

	return stageListTb
end

function SpecialTrainNewModel:getQuestItemBadgeList(number)
	if number == nil or number == 0 then
		return {
			{}
		}
	end

	local stageListTb = {}
	local temp = {}

	for i = 1, number do
		temp = {
			stage = i
		}

		table.insert(stageListTb, temp)
	end

	return stageListTb
end

function SpecialTrainNewModel:getLeftPageList()
	local leftList = {}

	for _, tp in pairs(QuestConst.QUEST_TRAIN_SUB_TYPE) do
		if tp ~= QuestConst.QUEST_TRAIN_SUB_TYPE.COMPULSORY then
			local temp = {}

			temp.trainType = tp
			temp.name = self:getTypePageName(tp)
			leftList[#leftList + 1] = temp
		end
	end

	table.sort(leftList, function(a, b)
		return a.trainType < b.trainType
	end)

	return leftList
end

function SpecialTrainNewModel:isGetBadgeMaxReward()
	return pg.me.isGetBadgeMaxReward
end

function SpecialTrainNewModel:getExchangeInfo()
	local exchangeInfo = {}

	exchangeInfo.canExchangeNum = 0
	exchangeInfo.canExchangeCount = pg.me.curBadgeCnt - pg.me.lastBadgeMilestoneCount or 0
	exchangeInfo.curRemaining = exchangeInfo.canExchangeCount or 0
	exchangeInfo.progressMax = SysConfigData.SpecialTrainBadgeContinuousReward and SysConfigData.SpecialTrainBadgeContinuousReward[10] or 10
	exchangeInfo.rewardId = SysConfigData.SpecialTrainBadgeContinuousReward and SysConfigData.SpecialTrainBadgeContinuousReward[2] or 52010

	if exchangeInfo.canExchangeCount >= exchangeInfo.progressMax then
		exchangeInfo.canExchangeNum = math.floor(exchangeInfo.canExchangeCount / exchangeInfo.progressMax)
		exchangeInfo.curRemaining = exchangeInfo.canExchangeCount % exchangeInfo.progressMax
	end

	exchangeInfo.rewardList = {}

	for i = 1, exchangeInfo.progressMax do
		local temp = {}

		temp.stage = i

		table.insert(exchangeInfo.rewardList, temp)
	end

	return exchangeInfo
end

function SpecialTrainNewModel:getBadgeRewardFlags(stageId, num)
	local rewardState = self.REWARD_NORMAL

	if getBit(pg.me.badgeRewardFlags, stageId) then
		rewardState = self.REWARD_CAN_GOT
	elseif num <= pg.me.curBadgeCnt then
		rewardState = self.REWARD_RECEIVED
	end

	return rewardState
end

function SpecialTrainNewModel:getCurPhaseBadgeNum(index)
	local curProgress = pg.me.curBadgeCnt
	local curPhaseProg = 0
	local curIndex = 1
	local rewardListTb = self:getBadgeListTab(0)
	local curTotalProgress = 0

	for i = #rewardListTb, 1, -1 do
		if curProgress >= rewardListTb[#rewardListTb].badgeCollectNum then
			return 1, #rewardListTb
		end

		if curProgress <= rewardListTb[1].badgeCollectNum and index == 1 then
			curTotalProgress = rewardListTb[1].badgeCollectNum

			return curProgress / curTotalProgress, 1
		end

		if curProgress > rewardListTb[i].badgeCollectNum then
			curProgress = curProgress - rewardListTb[i].badgeCollectNum
			curTotalProgress = index ~= 1 and rewardListTb[i + 1].badgeCollectNum - rewardListTb[i].badgeCollectNum or rewardListTb[i].badgeCollectNum
			curIndex = i + 1

			break
		end
	end

	curPhaseProg = curProgress / curTotalProgress

	if index < curIndex then
		if index < curIndex then
			curPhaseProg = 1
		end
	elseif curIndex < index then
		curPhaseProg = 0
	end

	return curPhaseProg, curIndex
end

function SpecialTrainNewModel:getBadgeMaxNum()
	local rewardListTb = SpecialTrainBadgeData

	return rewardListTb[#rewardListTb].badgeCollectNum
end

function SpecialTrainNewModel:getBadgeListTab(flag)
	local rewardListTb = {}
	local temp = {}

	for i = 1, #SpecialTrainBadgeData - flag do
		local badgeConfig = SpecialTrainBadgeData[i]

		if badgeConfig then
			temp = {
				stageId = i,
				badgeCollectNum = badgeConfig.badgeCollectNum or 0,
				satgeRewardId = badgeConfig.satgeRewardId or 0
			}
			temp.rewardState = self:getBadgeRewardFlags(i, temp.badgeCollectNum)
			temp.isFinal = badgeConfig.mainRewardId and badgeConfig.mainRewardId > 0

			table.insert(rewardListTb, temp)
		end
	end

	return rewardListTb
end

function SpecialTrainNewModel:getBadgeDataByStageID(stageId)
	local temp = {}

	stageId = stageId == 0 and #SpecialTrainBadgeData or stageId

	local badgeConfig = SpecialTrainBadgeData[stageId]

	temp.badgeCollectNum = badgeConfig.badgeCollectNum or 0
	temp.stageId = stageId

	local rewardId = badgeConfig.satgeRewardId

	temp.satgeRewardId = rewardId
	temp.isFinal = badgeConfig.mainRewardId and badgeConfig.mainRewardId > 0 or false
	temp.rewardState = self:getBadgeRewardFlags(stageId, temp.badgeCollectNum)
	temp.progress, temp.Index = SpecialTrainNewModel:getCurPhaseBadgeNum(stageId)

	return temp
end

function SpecialTrainNewModel:getSortState(data)
	local hasGet, canGet, isSpecialTask, isRecommendTask = false, false, false, false
	local questConfig = QuestUtils.getSpecialTrainConfig(data.questId)
	local questData = self:getSpecialTrainData(data.questId)

	if questData and questConfig and (questData.rewardFlags ~= nil or true) then
		hasGet = questData.rewardFlags

		if questData.isCanGetReward == nil then
			-- block empty
		end

		canGet = questData.isCanGetReward
		isSpecialTask = questConfig.specialTask or 0

		if questConfig.recommendTask == nil then
			-- block empty
		end

		isRecommendTask = questConfig.recommendTask
	end

	return hasGet, canGet, isSpecialTask, isRecommendTask
end

function SpecialTrainNewModel:getSpecialTrainGetRewardList(taskId)
	local questList = {}
	local taskStageCofTb
	local taskStageCofTbs = SpecialTrainEntryData[taskId]
	local chapterId = self:getQuestChapterIdByTaskId(taskId)

	for k = 1, #taskStageCofTbs do
		taskStageCofTb = taskStageCofTbs[k]

		local rewardFlags = self:getQuestItemRewardFlags(chapterId, taskStageCofTb.questId)
		local isCanGetReward = self:isCanGetReward(taskStageCofTb.questId)

		if isCanGetReward and not rewardFlags then
			table.insert(questList, taskStageCofTbs[k].questId)
		end
	end

	return questList
end

function SpecialTrainNewModel:getAllCanGetSpecialTrainRewardList(chapterId, pageType)
	local questList = {}
	local dataList = self:getChapterPageInfo(chapterId, pageType)

	for _, item in ipairs(dataList) do
		if item.taskId and item.taskId > 0 then
			local taskStageCofTbs = SpecialTrainEntryData[item.taskId]

			if taskStageCofTbs then
				local entryChapterId = self:getQuestChapterIdByTaskId(item.taskId) or chapterId

				for k = 1, #taskStageCofTbs do
					local taskStageCofTb = taskStageCofTbs[k]
					local rewardFlags = self:getQuestItemRewardFlags(entryChapterId, taskStageCofTb.questId)
					local isCanGetReward = self:isCanGetReward(taskStageCofTb.questId)

					if isCanGetReward and not rewardFlags then
						table.insert(questList, taskStageCofTb.questId)
					end
				end
			end
		end
	end

	return questList
end

function SpecialTrainNewModel:collectCanGetRewardQuestIds(excludeQuestId, filterMainQuestInStarTitle, crossChapterCompulsory)
	local questIds = {}
	local pageTb = self:getPageTypeTb()

	if type(pageTb) == "table" then
		for _, tp in ipairs(pageTb) do
			local dataLists = {}
			local curChapterId = QuestUtils.getCurChapterId()

			if crossChapterCompulsory and tp.trainType == QuestConst.QUEST_TRAIN_SUB_TYPE.COMPULSORY then
				for chapterId = curChapterId or 0, 0, -1 do
					dataLists[#dataLists + 1] = self:getChapterPageInfo(chapterId, tp.trainType)
				end
			else
				dataLists[1] = self:getChapterPageInfo(curChapterId, tp.trainType)
			end

			for _, dataList in ipairs(dataLists) do
				if type(dataList) == "table" then
					for _, v in ipairs(dataList) do
						if v.questId and tonumber(v.questId) and tonumber(v.questId) > 0 and self:redDot_CheckHasQuestCanGet(v) and not table.contains(questIds, v.questId) then
							local skip = filterMainQuestInStarTitle and QuestUtils.isSpecialTrainMainQuest(v.questId) and QuestUtils.isInStarTitleQuest()

							if not skip then
								questIds[#questIds + 1] = v.questId
							end
						end
					end
				end
			end
		end
	end

	if excludeQuestId and excludeQuestId > 0 then
		for i = #questIds, 1, -1 do
			if questIds[i] == excludeQuestId then
				table.remove(questIds, i)
			end
		end
	end

	return questIds
end

function SpecialTrainNewModel:getCanGetRewardSpecialTrainQuestIds(questId)
	return #self:collectCanGetRewardQuestIds(questId, true) > 0
end

function SpecialTrainNewModel:redDot_CheckHasQuestCanGet(data)
	local questData = self:getSpecialTrainData(data.questId)

	if questData == nil then
		return false
	end

	if questData.isCanGetReward == nil then
		-- block empty
	end

	local canGet = questData.isCanGetReward

	if questData.rewardFlags == nil then
		-- block empty
	end

	local hasGet = questData.rewardFlags

	return canGet and not hasGet
end

function SpecialTrainNewModel:redDot_CheckHasBadgeRewardCanGet(stageId)
	local itemData = self:getBadgeDataByStageID(stageId)
	local hasGet = itemData.rewardState == self.REWARD_CAN_GOT
	local canGet = itemData.rewardState == self.REWARD_RECEIVED

	return canGet and not hasGet
end

function SpecialTrainNewModel:redDot_GetChapterPageState(data)
	return self:isCanGetChapterReward(data)
end

function SpecialTrainNewModel:redDot_GetChapterUptitleState(data)
	if QuestUtils.isVersionCapChapterFinished(data) then
		return false
	end

	return QuestUtils.isCanUpgradeStar(data)
end

function SpecialTrainNewModel:redDot_GetQuestPageState(trainType, curChapterId)
	local chapterIds = {}

	if curChapterId then
		chapterIds = {
			curChapterId
		}
	else
		local curId = QuestUtils.getCurChapterId()
		local chapterList = self:getChapterTb()

		for _, chapterInfo in ipairs(chapterList) do
			if curId < chapterInfo.chapterId then
				break
			end

			table.insert(chapterIds, chapterInfo.chapterId)
		end
	end

	for _, cid in ipairs(chapterIds) do
		local dataList = self:getChapterPageInfo(cid, trainType)

		for _, v in pairs(dataList) do
			if self:redDot_GetQuestState(v) then
				if trainType == QuestConst.QUEST_TRAIN_SUB_TYPE.COMPULSORY then
					return not QuestUtils.isInStarTitleQuest()
				else
					return true
				end
			end
		end
	end

	return false
end

function SpecialTrainNewModel:redDot_GetQuestState(data)
	return self:redDot_CheckHasQuestCanGet(data)
end

function SpecialTrainNewModel:redDot_GetBadgeState(data)
	return self:redDot_CheckHasBadgeRewardCanGet(data.stageId)
end

function SpecialTrainNewModel:redDot_GetUptitleState()
	if QuestUtils.getCurChapterId() > 0 then
		local chapterList = self:getChapterTb()

		for _, v in ipairs(chapterList) do
			if self:redDot_GetChapterUptitleState(v.chapterId) then
				return true
			end
		end
	end

	return false
end

function SpecialTrainNewModel:redDot_GetPointDotState()
	if QuestUtils.getCurChapterId() > 0 then
		local chapterList = self:getChapterTb()

		for _, v in ipairs(chapterList) do
			if self:redDot_GetChapterPageState(v.chapterId) then
				return true
			end
		end
	end

	local dataList = self:getPageTypeTb()

	for _, v in ipairs(dataList) do
		if self:redDot_GetQuestPageState(v.trainType) then
			return true
		end
	end

	dataList = self:getBadgeListTab(0)

	for _, v in pairs(dataList) do
		if self:redDot_GetBadgeState(v) then
			return true
		end
	end

	if pg.me and pg.me.isGetBadgeMaxReward then
		local exchangeInfo = self:getExchangeInfo()

		return exchangeInfo and exchangeInfo.canExchangeNum > 0
	end

	return false
end

function SpecialTrainNewModel:redDot_GetSpecialTrainState()
	if not LuaUIUtils.checkFuncUnlock(Const.FUNCTION_IDS.SPECIALTRAIN) then
		return RedDotConst.RedDotStyle.NONE
	end

	local uptitleState = self:redDot_GetUptitleState()

	if self:redDot_GetPointDotState() or uptitleState then
		local redDotConstStyle = RedDotConst.RedDotStyle.REWARD

		if not self:redDot_GetPointDotState() and uptitleState then
			redDotConstStyle = RedDotConst.RedDotStyle.POINT
		end

		return redDotConstStyle
	end

	return RedDotConst.RedDotStyle.NONE
end

return SpecialTrainNewModel
