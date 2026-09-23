-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\ClientActivityUtils.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("ClientActivityUtils")
local CoreConst = require("Core.Common.Const")
local ElementPropData = require("Data.element_prop_data")
local PuppetData = require("Data.puppet_data")
local PetData = require("Data.pet_data")
local ExploreAbilityData = require("Data.explore_ability_data")
local ActivityConst = require("Common.Const.ActivityConst")
local FishingCaptureConst = require("Common.Const.FishingCaptureConst")
local ClientConst = require("Const.ClientConst")
local UIConst = require("Const.UIConst")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local lume = require("Core.Common.lume")
local Time = require("Core.Common.Time")
local TimeUtils = require("Common.Utils.TimeUtils")
local ClientUtils = require("Utils.ClientUtils")
local PetConfigData = require("Data.pet_config_data")
local RedDotConst = require("Const.RedDotConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local CustomTriggerData = require("Data.custom_trigger_data")
local SysEventData = require("Data.sys_event_data")
local GameEventData = require("Data.game_event_data")
local FishingCaptureActivityData = require("Data.fishing_capture_activity_data")
local GameEventTypeData = require("Data.game_event_type_data")
local EventCommonGuideData = require("Data.event_common_guide_data")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local SysConfigData = require("Data.sys_config_data")
local SocialPartyData = require("Data.social_party_data")
local PetSaveManualData = require("Data.event_petsave_manual_data")
local PetSaveManualSubactData = require("Data.event_petsave_manual_subact_data")
local EnergyMatchThemeData = require("Data.energy_match_theme_data")
local ActivityPetVoteData = require("Data.activity_pet_vote_data")
local EcoTraceActivityData = require("Data.ecotrace_activity_data")
local EcoTraceSearchData = require("Data.ecotrace_search_data")
local EventTaskData = require("Data.event_task_data")
local EventDispatchData = require("Data.event_pet_dispacth_data")
local EventAreaActivityData = require("Data.event_area_activity_data")
local EventSignNewbieData = require("Data.event_sign_newbie_data")
local EventSignVersionData = require("Data.event_sign_version_data")
local MonthCardUtils = require("GameApp.MonthCard.MonthCardUtils")
local TriggerConst = require("Common.Const.TriggerConst")
local TriggerUtils = require("Common.Utils.TriggerUtils")
local AttributeConst = require("Common.Const.AttributeConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PetTalentRandomGroupData = require("Data.pet_talent_random_group_data")
local EventLeylineTreeUpData = require("Data.event_leylineTree_up_data")
local EventGrowthGiftData = require("Data.event_growth_gitf_data")
local ActivateTasksData = require("Data.activate_tasks_data")
local EventGlobalProgressData = require("Data.event_global_progress_data")
local EventGlobalProgressAlgorithmData = require("Data.event_global_progress_algorithm_data")
local EventLittleFirePersonData = require("Data.event_littleFirePerson_data")
local ItemConst = require("Common.Const.ItemConst")
local ClientActivityUtils = {}

ClientActivityUtils.REUNION_TRAINING_TASK_TYPE = {
	final = 5002,
	row = 5000,
	normal = 5003
}

function ClientActivityUtils.getEventRule(eventId)
	local eventData = GameEventData[eventId] or {}
	local serverAreaNo = Utils.getServerArea()

	if serverAreaNo == Const.SERVER_AREANO.CN then
		return eventData.rule
	elseif serverAreaNo == Const.SERVER_AREANO.EN then
		return eventData.euRule
	elseif serverAreaNo == Const.SERVER_AREANO.US then
		return eventData.naRule
	elseif serverAreaNo == Const.SERVER_AREANO.AP then
		return eventData.apRule
	end

	return eventData.rule
end

function ClientActivityUtils.getEventTitle(eventId)
	local eventData = GameEventData[eventId] or {}

	if eventData then
		return pg.getLocalizationText(eventData.name)
	end

	return ""
end

function ClientActivityUtils.getEventDesc(eventId)
	local eventData = GameEventData[eventId] or {}

	if eventData then
		return pg.getLocalizationText(eventData.eventDesc)
	end

	return ""
end

function ClientActivityUtils.isEventTabOpen(id)
	if GameEventData[id] then
		return ClientActivityUtils.isGameEventTabOpen(id)
	end

	return false
end

function ClientActivityUtils.isGameEventTabOpen(eventId)
	if not eventId then
		return false
	end

	local isTabOpen = ActivityUtils.isOprActivityTabOpen(eventId, pg.me, true)
	local eventData = GameEventData[eventId]

	if not eventData then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("@ClientActivityUtils.isGameEventTabOpen missing GameEventData, eventId=%s", eventId)
		end

		return false
	end

	if isTabOpen and eventData then
		local tabEndTime = Utils.getConfigTimeOfArea(eventData, "tabEndDayTime")

		if tabEndTime and tabEndTime <= Time.secondCache then
			isTabOpen = false
		end
	end

	local eventTypeKey = eventData.component or ClientActivityUtils._getGameEventTypeKey(eventData.eventType)

	if eventTypeKey then
		local extraCheckFunc = "checkGameEvent_" .. eventTypeKey .. "Open"

		if ClientActivityUtils[extraCheckFunc] then
			isTabOpen = isTabOpen and ClientActivityUtils[extraCheckFunc]()
		end
	end

	return isTabOpen
end

function ClientActivityUtils.checkGameEvent_FractureOpen()
	local dungeonData

	for _, info in ipairs(pg.me.activityDatas) do
		if info.activityType == Const.ActivityType.BOSS_DUNGEON then
			dungeonData = info

			break
		end
	end

	return dungeonData ~= nil
end

function ClientActivityUtils.checkGameEvent_CatchRogueOpen()
	if not pg.me then
		return
	end

	return pg.me:getCatchRogueCurGameId() ~= nil and pg.me:getCatchRogueCurGameId() ~= 0
end

function ClientActivityUtils.checkGameEvent_TeaPartyOpen()
	local isOpen, eventId = ActivityUtils.isOprActivityOpenByType(ActivityConst.EventType.TeaParty, pg.me)

	if not isOpen or not eventId then
		return false
	end

	return ClientActivityUtils.isTeaPartyOpenNow(eventId)
end

function ClientActivityUtils.checkGameEvent_SteamBindEmailOpen()
	local sdkManager = pg.global and pg.global.sdkManager

	return sdkManager ~= nil and sdkManager:canSteamBindEmail()
end

function ClientActivityUtils.isEventOpen(id)
	if not id then
		return false
	end

	local eventData = GameEventData[id]

	if not eventData then
		return false
	end

	local isOpen = ActivityUtils.isOprActivityOpen(id)

	if isOpen then
		local tabEndTime = Utils.getConfigTimeOfArea(eventData, "tabEndDayTime")

		if tabEndTime and tabEndTime <= Time.secondCache then
			return false
		end
	end

	return isOpen
end

function ClientActivityUtils.checkSeasonActivity(eventId)
	if not pg.me or not LuaUIUtils.checkFuncCanOpen(Const.FUNCTION_IDS.SEASON) then
		return false
	end

	if not ClientActivityUtils.isGameEventTabOpen(eventId) then
		return false
	end

	if pg.me.isInRiftMode then
		return not pg.me:isInRiftMode()
	end

	return true
end

function ClientActivityUtils.getEventRedDotStyle(tabType, id)
	return ClientActivityUtils._getGameEventRedDotStyle(tabType, id)
end

function ClientActivityUtils._getGameEventTypeKey(eventType)
	for k, t in pairs(ActivityConst.EventType) do
		if k ~= "MinType" and k ~= "MaxType" and eventType == t then
			return k
		end
	end
end

function ClientActivityUtils._getGameEventRedDotStyle(tabType, eventId)
	if eventId then
		if GameEventData[eventId] then
			local eventType = GameEventData[eventId].eventType
			local eventTypeKey = ClientActivityUtils._getGameEventTypeKey(eventType)

			if eventTypeKey and ClientActivityUtils.isEventOpen(eventId) and ActivityUtils.getOprActivityUnlockCond(eventId) then
				local getFuncName = "_get" .. eventTypeKey .. "RedDotStyle"
				local redDotStyle = RedDotConst.RedDotStyle.NONE

				if ClientActivityUtils[getFuncName] then
					redDotStyle = ClientActivityUtils[getFuncName](eventId, true) or RedDotConst.RedDotStyle.NONE
				end

				local hasNew = ClientActivityUtils._getGameEventRedDotNew(eventId)

				if hasNew and RedDotConst.RedDotStylePriority[RedDotConst.RedDotStyle.NEW] > RedDotConst.RedDotStylePriority[redDotStyle] then
					redDotStyle = RedDotConst.RedDotStyle.NEW
				end

				return redDotStyle
			end

			return RedDotConst.RedDotStyle.NONE
		else
			return RedDotConst.RedDotStyle.NONE
		end
	end

	local res = RedDotConst.RedDotStyle.NONE
	local curPri = 0

	for id, _ in pairs(GameEventData) do
		local eventType = GameEventData[id].eventType
		local curTabType = GameEventTypeData[eventType] and GameEventTypeData[eventType].tabType
		local eventTypeKey = ClientActivityUtils._getGameEventTypeKey(eventType)

		if curTabType and curTabType < UIConst.EVENT_TAB_TYPE.SCHOOL_GUIDE and eventTypeKey and ClientActivityUtils.isEventOpen(id) and ClientActivityUtils.isEventTabOpen(id) and (not tabType or tabType == curTabType) then
			local getFuncName = "_get" .. eventTypeKey .. "RedDotStyle"
			local redDotStyle = RedDotConst.RedDotStyle.NONE

			if ClientActivityUtils[getFuncName] then
				redDotStyle = ClientActivityUtils[getFuncName](id, tabType ~= nil) or RedDotConst.RedDotStyle.NONE
			end

			local hasNew = ClientActivityUtils._getGameEventRedDotNew(id)

			if hasNew and RedDotConst.RedDotStylePriority[RedDotConst.RedDotStyle.NEW] > RedDotConst.RedDotStylePriority[redDotStyle] then
				redDotStyle = RedDotConst.RedDotStyle.NEW
			end

			if curPri < RedDotConst.RedDotStylePriority[redDotStyle] then
				curPri = RedDotConst.RedDotStylePriority[redDotStyle]
				res = redDotStyle
			end
		end
	end

	return res
end

function ClientActivityUtils._getGameEventRedDotNew(eventId)
	if not eventId then
		return
	end

	local treePath = string.format(RedDotConst.RedDotPath.EVENT_TAB_LIST_ITEM, eventId)
	local eventType = GameEventData[eventId].eventType
	local showRedDot

	if eventType == ActivityConst.EventType.PetDispatch then
		local key = ClientActivityUtils.getDispatchRedDotNewKey(eventId)

		if key then
			showRedDot = pg.me:getRedDotRecord(Const.CLIENT_KEY.PET_DISPATCH_EVENT_TABLE, key, true)
		end
	else
		showRedDot = (eventType ~= ActivityConst.EventType.TeaParty or false) and pg.me:getRedDotRecord(Const.CLIENT_KEY.EVENT_RED_DOT, treePath, true)
	end

	return showRedDot
end

function ClientActivityUtils._getMockBattleRedDotStyle()
	local RogueUtils = require("Utils.RogueUtils")

	return RogueUtils.getRedDotSeasonWeeklyRewardState()
end

function ClientActivityUtils.refreshMockBattleRedDot()
	if not pg.global or not pg.global.refreshRedDotState then
		return
	end

	for eventId, eventData in pairs(GameEventData) do
		if eventData.eventType == ActivityConst.EventType.MockBattle then
			local treePath = string.format(RedDotConst.RedDotPath.EVENT_TAB_LIST_ITEM, eventId)

			pg.global.refreshRedDotState(treePath)
		end
	end

	pg.global.refreshRedDotState(RedDotConst.RedDotPath.EVENT_TAB1)
	pg.global.refreshRedDotState(RedDotConst.RedDotPath.EVENT_TAB2)
	pg.global.refreshRedDotState(RedDotConst.RedDotPath.FUNC_MENU_EVENT)
end

function ClientActivityUtils.getDispatchRedDotNewKey(eventId)
	local eventConfig = GameEventData[eventId]

	if not eventConfig then
		return
	end

	local eventPhase = eventConfig.phase
	local phaseData = EventDispatchData[eventPhase]
	local taskIds = phaseData and phaseData.mapBlockDispatchTaskId

	if not taskIds then
		return
	end

	local taskMap = ActivityUtils.getActTaskMap(pg.me, ActivityConst.EventType.PetDispatch)

	if not taskMap then
		return
	end

	local activeTaskId

	for _, taskId in ipairs(taskIds) do
		if taskMap[taskId] then
			activeTaskId = taskId
		end
	end

	if not activeTaskId then
		return
	end

	return eventPhase .. "_" .. activeTaskId
end

local function getTeaPartyRangeByDay(partyTimeCfgList, dayBegin)
	local targetStartTime, targetEndTime

	for _, cfg in pairs(partyTimeCfgList) do
		local startSeconds = cfg ~= nil and Utils.getConfigTimeOfArea(cfg, "startTime") or nil
		local endSeconds = cfg ~= nil and Utils.getConfigTimeOfArea(cfg, "endTime") or nil

		if startSeconds ~= nil and endSeconds ~= nil then
			local startTime = dayBegin + startSeconds
			local endTime = dayBegin + endSeconds

			if cfg.isTomorrow == true or cfg.isTomorrow == 1 or cfg.istomorrow == true or cfg.istomorrow == 1 then
				startTime = startTime + Const.SECONDS_ONE_DAY
				endTime = endTime + Const.SECONDS_ONE_DAY
			end

			if targetStartTime == nil or startTime < targetStartTime then
				targetStartTime = startTime
			end

			if targetEndTime == nil or targetEndTime < endTime then
				targetEndTime = endTime
			end
		end
	end

	return targetStartTime, targetEndTime
end

function ClientActivityUtils.getTeaPartyOpenTimeRange(dailyStartTime)
	local partyTimeCfgList = SocialPartyData[dailyStartTime] or SocialPartyData[tonumber(dailyStartTime)]

	if not Utils.isTable(partyTimeCfgList) then
		return nil, nil
	end

	local dayBegin = TimeUtils.getAreaDayBegin(Time.secondCache)
	local now = Time.secondCache

	for _, rangeDayBegin in ipairs({
		dayBegin - Const.SECONDS_ONE_DAY,
		dayBegin
	}) do
		local startTime, endTime = getTeaPartyRangeByDay(partyTimeCfgList, rangeDayBegin)

		if startTime ~= nil and endTime ~= nil and startTime <= now and now < endTime then
			return startTime, endTime
		end
	end

	return getTeaPartyRangeByDay(partyTimeCfgList, dayBegin)
end

function ClientActivityUtils.isTeaPartyOpenNow(eventId)
	local gameEventCfg = GameEventData[eventId]

	if gameEventCfg == nil then
		return true
	end

	local guideId = gameEventCfg.guideId

	if guideId == nil then
		return true
	end

	local guideCfg = EventCommonGuideData[guideId]

	if guideCfg == nil then
		return true
	end

	local dailyStartTime = guideCfg.dailyStartTime

	if dailyStartTime == nil then
		return true
	end

	local startTime, endTime = ClientActivityUtils.getTeaPartyOpenTimeRange(dailyStartTime)

	if startTime == nil or endTime == nil then
		return true
	end

	local now = Time.secondCache

	return startTime <= now and now < endTime
end

function ClientActivityUtils.getTeaPartyDailyRedDotKey(eventId)
	local dayBegin = TimeUtils.getAreaDayBegin(Time.secondCache)

	return string.format("TeaParty_%d_%d", eventId, dayBegin)
end

function ClientActivityUtils._isTeaPartyDailyRewardFull()
	local cfg = SysConfigData.SOCIAL_PARTY_DAILY_MAX_ITEM_NUM

	if not Utils.isTable(cfg) then
		return false
	end

	local acquired = {}

	if pg.me ~= nil and pg.me.cafeGatheringDailyAcquired ~= nil then
		acquired = pg.me.cafeGatheringDailyAcquired
	end

	for _, item in ipairs(cfg) do
		local itemId, maxNum = item[1], item[2]

		if itemId ~= nil and maxNum ~= nil and maxNum > (acquired[itemId] or 0) then
			return false
		end
	end

	return true
end

function ClientActivityUtils._getTeaPartyRedDotStyle(eventId)
	if not ClientActivityUtils.isTeaPartyOpenNow(eventId) then
		return RedDotConst.RedDotStyle.NONE
	end

	if ClientActivityUtils._isTeaPartyDailyRewardFull() then
		return RedDotConst.RedDotStyle.NONE
	end

	if pg.me == nil then
		return RedDotConst.RedDotStyle.NONE
	end

	local dailyKey = ClientActivityUtils.getTeaPartyDailyRedDotKey(eventId)
	local notRead = pg.me:getRedDotRecord(Const.CLIENT_KEY.EVENT_RED_DOT, dailyKey, true)

	if notRead == true then
		return RedDotConst.RedDotStyle.POINT
	end

	return RedDotConst.RedDotStyle.NONE
end

function ClientActivityUtils._getPetSaveRedDotStyle(eventId)
	if ClientActivityUtils.checkPetSavePoint(eventId) then
		return RedDotConst.RedDotStyle.POINT
	end

	if ClientActivityUtils.checkPetSaveRewardPoint() then
		return RedDotConst.RedDotStyle.REWARD
	end

	return RedDotConst.RedDotStyle.NONE
end

function ClientActivityUtils._getWeekWishRedDotStyle(eventId)
	if not eventId then
		return RedDotConst.RedDotStyle.NONE
	end

	local curActivityId = GameEventData[eventId].phase
	local hasGetReward = pg.me.activityVotePetSucc and pg.me.activityVotePetSucc[curActivityId] ~= nil
	local votePet = pg.me.activityVotePet and pg.me.activityVotePet[curActivityId]
	local activityData = ActivityPetVoteData[curActivityId]

	if not activityData then
		return RedDotConst.RedDotStyle.NONE
	end

	local now = Time.getSecond()
	local eventEndDayTime = Utils.getConfigTimeOfArea(activityData, "eventEndDayTime")
	local eventStartDayTime = Utils.getConfigTimeOfArea(activityData, "eventStartDayTime")
	local voteStartDayTime = Utils.getConfigTimeOfArea(activityData, "voteStartDayTime")
	local voteEndDayTime = Utils.getConfigTimeOfArea(activityData, "voteEndDayTime")

	if voteStartDayTime <= now and now < voteEndDayTime and not hasGetReward and not votePet then
		return RedDotConst.RedDotStyle.POINT
	end

	if eventStartDayTime <= now and now < eventEndDayTime and not hasGetReward and votePet then
		return RedDotConst.RedDotStyle.POINT
	end

	return RedDotConst.RedDotStyle.NONE
end

function ClientActivityUtils._getPuppetCatchRedDotStyle(eventId)
	local canGetRewardList = ActivityUtils.getLuckyPetCanRewardList(pg.me)

	for i = 1, #canGetRewardList do
		local canGet = canGetRewardList[i]
		local hasGet = pg.me.luckyPetDayRewarded[i]

		if canGet and not hasGet then
			return RedDotConst.RedDotStyle.REWARD
		end
	end

	local petSubmit = pg.me.luckyPetIdSubmit
	local petCatch = pg.me.luckyPetIdFinish

	if petSubmit and petCatch then
		for index, _ in ipairs(petCatch) do
			if petSubmit[index] ~= true and petCatch[index] == true then
				return RedDotConst.RedDotStyle.POINT
			end
		end
	end

	return RedDotConst.RedDotStyle.NONE
end

function ClientActivityUtils._getEnergyMatchRedDotStyle()
	local phase = ActivityUtils.getNewEnergyTheme(pg.me)
	local themeId = ActivityUtils.getEnergyThemeId(pg.me)
	local themeData = EnergyMatchThemeData[phase][themeId]
	local isJoinRedDotNew = pg.me:getRedDotRecord(Const.CLIENT_KEY.EVENT_VITALITY_JOIN_RED_DOT, tostring(phase), true)

	if isJoinRedDotNew then
		return RedDotConst.RedDotStyle.POINT
	end

	local rewardDatas = themeData.award or {}

	for index = 1, #rewardDatas do
		if ClientActivityUtils.redDotReward_CheckVitalityRewardItem(phase, themeId, index) then
			return RedDotConst.RedDotStyle.REWARD
		end
	end

	return RedDotConst.RedDotStyle.NONE
end

function ClientActivityUtils._getArkCarnRedDotStyle(eventId)
	for id, taskData in pairs(pg.me.arkCarnTasks) do
		if taskData.state == ActivityConst.TaskState.Finihed_CanRecv then
			return RedDotConst.RedDotStyle.REWARD
		end
	end

	if pg.me.arkCarnStageState[3] and pg.me.arkCarnStageState[3] == 1 then
		local key = pg.me.uid .. "ArkCarn_GoTo"
		local gotoValue = pg.global.prefsCacheUtils:getInt(key, 0)

		if gotoValue == 0 then
			return RedDotConst.RedDotStyle.POINT
		end
	end

	return RedDotConst.RedDotStyle.NONE
end

function ClientActivityUtils._getPuppetPhotoRedDotStyle(eventId)
	if pg.me.formResearchFinish == true and pg.me.formResearchRewarded ~= true then
		return RedDotConst.RedDotStyle.REWARD
	end

	if pg.me.formResearchObRewardFin == true and pg.me.formResearchObRewardRew ~= true then
		return RedDotConst.RedDotStyle.REWARD
	end

	local canGetRewardList = ActivityUtils.getFormResearchCanRewardList(pg.me)

	for i = 1, #canGetRewardList do
		local canGet = canGetRewardList[i]
		local hasGet = pg.me.formResearchStageRewarded[i]

		if canGet and not hasGet then
			return RedDotConst.RedDotStyle.REWARD
		end
	end

	return RedDotConst.RedDotStyle.NONE
end

function ClientActivityUtils._getOfficialGroupRedDotStyle(eventId)
	return
end

function ClientActivityUtils._getRedBookRedDotStyle(eventId)
	local activityCfg = ActivateTasksData[eventId]
	local taskGroups = activityCfg and activityCfg.foreverTaskGroup

	if not taskGroups then
		return RedDotConst.RedDotStyle.NONE
	end

	for _, groupId in ipairs(taskGroups) do
		local taskIdsCanReceive = ActivityUtils.getActTaskCanReceiveByGroupId(nil, groupId)

		if next(taskIdsCanReceive) then
			return RedDotConst.RedDotStyle.REWARD
		end
	end

	return RedDotConst.RedDotStyle.NONE
end

function ClientActivityUtils._getEcologyTraceRedDotStyle(eventId, checkSearchPoint)
	if checkSearchPoint and ClientActivityUtils.checkEcologySearchPoint() then
		return RedDotConst.RedDotStyle.POINT
	end

	if ClientActivityUtils.checkEcologyQusetPoint() then
		return RedDotConst.RedDotStyle.REWARD
	end

	return RedDotConst.RedDotStyle.NONE
end

function ClientActivityUtils._getJourneyTrialRedDotStyle(eventId)
	local groups = ClientActivityUtils.REUNION_TRAINING_TASK_TYPE

	for _, taskGroupId in pairs(groups) do
		local taskIdsCanReceive = ActivityUtils.getActTaskCanReceiveByGroupId(nil, taskGroupId)

		if next(taskIdsCanReceive) then
			return RedDotConst.RedDotStyle.REWARD
		end
	end

	return RedDotConst.RedDotStyle.NONE
end

function ClientActivityUtils._getAreaActivityRedDotStyle(eventId)
	local eventData = GameEventData[eventId]
	local areaEventData = EventAreaActivityData[eventData.phase]
	local taskGroupIds = {}

	taskGroupIds[#taskGroupIds + 1] = {
		areaEventData.islandTaskGroupId
	}

	for index, groupId in ipairs(areaEventData.petResearchTaskGroupId or EMPTY_TABLE) do
		taskGroupIds[#taskGroupIds + 1] = {
			groupId
		}
	end

	for i = 1, #taskGroupIds do
		local groupId = taskGroupIds[i][1]

		if ClientActivityUtils.getCanGetRewardByTaskGroupId(groupId) then
			return RedDotConst.RedDotStyle.REWARD
		end
	end

	return RedDotConst.RedDotStyle.NONE
end

function ClientActivityUtils.getSignCfg(eventId)
	local eventData = GameEventData[eventId]

	if not eventData then
		return nil
	end

	if eventData.eventType == ActivityConst.EventType.SignNewbie then
		return EventSignNewbieData[eventData.phase]
	elseif eventData.eventType == ActivityConst.EventType.SignVersion or eventData.eventType == ActivityConst.EventType.LongTermSign then
		return EventSignVersionData[eventData.phase]
	end

	return nil
end

function ClientActivityUtils.getSignTaskGroupIds(eventId)
	local eventData = GameEventData[eventId]

	if eventData and eventData.eventType == ActivityConst.EventType.LongTermSign then
		return ActivityUtils.getForeverTaskGroupIds(eventId) or EMPTY_TABLE
	end

	local signCfg = ClientActivityUtils.getSignCfg(eventId)

	return signCfg and signCfg.taskGroupId and {
		signCfg.taskGroupId
	} or EMPTY_TABLE
end

function ClientActivityUtils.getSignRedDot(eventId)
	local taskGroupIds = ClientActivityUtils.getSignTaskGroupIds(eventId)

	for _, taskGroupId in ipairs(taskGroupIds) do
		local taskIdsCanReceive = ActivityUtils.getActTaskCanReceiveByGroupId(nil, taskGroupId)

		if next(taskIdsCanReceive) then
			return RedDotConst.RedDotStyle.REWARD
		end
	end

	return RedDotConst.RedDotStyle.NONE
end

function ClientActivityUtils._getSignNewbieRedDotStyle(eventId)
	return ClientActivityUtils.getSignRedDot(eventId)
end

function ClientActivityUtils._getSignVersionRedDotStyle(eventId)
	return ClientActivityUtils.getSignRedDot(eventId)
end

function ClientActivityUtils.getLittleFirePersonProgressRedDotStyle(isPersonal)
	local taskType = isPersonal and ActivityConst.ActivityTaskType.LittleFire_PersonReward or ActivityConst.ActivityTaskType.LittleFire_GlobalReward
	local taskInfos = ClientActivityUtils.getTaskInfoByTaskType(ActivityConst.EventType.LittleFirePerson, taskType)

	for _, taskInfo in ipairs(taskInfos) do
		if taskInfo.taskState == ActivityConst.TaskState.Finihed_CanRecv then
			return RedDotConst.RedDotStyle.REWARD
		end
	end

	return RedDotConst.RedDotStyle.NONE
end

function ClientActivityUtils.getLittleFirePersonManualTaskRedDotStyle()
	local taskTypes = {
		ActivityConst.ActivityTaskType.Active_DailyTask,
		ActivityConst.ActivityTaskType.Active_WeeklyTask,
		ActivityConst.ActivityTaskType.Active_AchievementTask
	}

	for _, taskType in ipairs(taskTypes) do
		local taskInfos = ClientActivityUtils.getTaskInfoByTaskType(ActivityConst.EventType.LittleFirePerson, taskType)

		for _, taskInfo in ipairs(taskInfos) do
			if taskInfo.taskState == ActivityConst.TaskState.Finihed_CanRecv then
				return RedDotConst.RedDotStyle.POINT
			end
		end
	end

	return RedDotConst.RedDotStyle.NONE
end

function ClientActivityUtils.getLittleFirePersonRedDotStyle(eventId)
	local personalStyle = ClientActivityUtils.getLittleFirePersonProgressRedDotStyle(true)

	if personalStyle == RedDotConst.RedDotStyle.REWARD then
		return personalStyle
	end

	local globalStyle = ClientActivityUtils.getLittleFirePersonProgressRedDotStyle(false)

	if globalStyle == RedDotConst.RedDotStyle.REWARD then
		return globalStyle
	end

	return ClientActivityUtils.getLittleFirePersonManualTaskRedDotStyle()
end

function ClientActivityUtils._compareLittleFirePersonRank(a, b)
	if a.sparkDays ~= b.sparkDays then
		return a.sparkDays > b.sparkDays
	end

	return a.friendOrder < b.friendOrder
end

function ClientActivityUtils.getLittleFirePersonRankList(eventId)
	local rankList = {}
	local chatSystem = pg.game and pg.game.chat

	if not chatSystem or not pg.me then
		return rankList
	end

	local sparkStreakDaysMap = pg.me.sparkStreakDaysMap or {}
	local sparkLastLightDayMap = pg.me.sparkLastLightDayMap or {}

	for friendOrder, friendInfo in ipairs(chatSystem:getFriendList() or EMPTY_TABLE) do
		local playerId = friendInfo.playerId or friendInfo.uid
		local uid = tostring(playerId or "")

		if uid ~= "" then
			local sparkDays = sparkStreakDaysMap[uid] or 0
			local lastLightDay = sparkLastLightDayMap[uid] or 0

			rankList[#rankList + 1] = {
				uid = uid,
				playerInfo = chatSystem:getPlayerInfo(playerId) or chatSystem:getPlayerInfo(uid),
				sparkDays = sparkDays,
				lastLightDay = lastLightDay,
				sparkedToday = lastLightDay == pg.me.lastDayUpdateTs,
				friendOrder = friendOrder
			}
		end
	end

	table.sort(rankList, ClientActivityUtils._compareLittleFirePersonRank)

	return rankList
end

function ClientActivityUtils.getLittleFireProgress(eventId, isPersonal)
	local activityData = ActivityUtils.getActivityData(pg.me, ActivityConst.EventType.LittleFirePerson)

	if not activityData then
		return 0
	end

	if isPersonal then
		return activityData.notesPerson or 0
	end

	return activityData.notesGlobal or 0
end

function ClientActivityUtils._getLittleFirePersonActivityAndPhaseData()
	local activityData = ActivityUtils.getActivityData(pg.me, ActivityConst.EventType.LittleFirePerson)
	local activityPhase = activityData and activityData.activityBase and activityData.activityBase.activityPhase

	return activityData, activityPhase and EventLittleFirePersonData[activityPhase]
end

function ClientActivityUtils.getLittleFireSparkDailyProgress()
	local activityData, phaseData = ClientActivityUtils._getLittleFirePersonActivityAndPhaseData()

	if not activityData or not phaseData then
		return 0, 0
	end

	local sparkPrize = phaseData.sparkPrize or {}
	local noteNumPerSpark = sparkPrize[ItemConst.ITEM_SPECIAL_MONEY_ACTLITFIRE_NOTE] or 0
	local currentTimes = activityData.noteGetTimesDailyBySpark or 0
	local totalTimes = phaseData.sparkDailyTimes or 0

	return currentTimes * noteNumPerSpark, totalTimes * noteNumPerSpark
end

function ClientActivityUtils.getLittleFireStatueInteractDailyProgress()
	local activityData, phaseData = ClientActivityUtils._getLittleFirePersonActivityAndPhaseData()

	if not activityData or not phaseData then
		return 0, 0, false
	end

	local currentTimes = activityData.litFireManInteractDailyTimes or 0
	local totalTimes = phaseData.dailyStatueInteractTime or 0

	return currentTimes, totalTimes, totalTimes > 0 and currentTimes < totalTimes
end

function ClientActivityUtils._getLittleFirePersonRedDotStyle(eventId)
	return ClientActivityUtils.getLittleFirePersonRedDotStyle(eventId)
end

function ClientActivityUtils._getStarPlanGuideItemRedDotStyle(index)
	if index == 2 then
		return pg.global.ui.SpecialTrainNew.model:redDot_GetSpecialTrainState() or RedDotConst.RedDotStyle.NONE
	elseif index == 3 then
		return LuaUIUtils.SchoolGuide_getDailyActiveRedDotStyle() or RedDotConst.RedDotStyle.NONE
	end

	return RedDotConst.RedDotStyle.NONE
end

function ClientActivityUtils.checkPetResearchPoint()
	return
end

function ClientActivityUtils.checkPetResearchReward(subType)
	if subType == 2 then
		if pg.me.formResearchFinish == true and pg.me.formResearchRewarded ~= true then
			return true
		end

		if pg.me.formResearchObRewardFin == true and pg.me.formResearchObRewardRew ~= true then
			return true
		end

		local canGetRewardList = ActivityUtils.getFormResearchCanRewardList(pg.me)

		for i = 1, #canGetRewardList do
			local canGet = canGetRewardList[i]
			local hasGet = pg.me.formResearchStageRewarded[i]

			if canGet and not hasGet then
				return true
			end
		end
	elseif subType == 1 then
		local canGetRewardList = ActivityUtils.getLuckyPetCanRewardList(pg.me)

		for i = 1, #canGetRewardList do
			local canGet = canGetRewardList[i]
			local hasGet = pg.me.luckyPetDayRewarded[i]

			if canGet and not hasGet then
				return true
			end
		end
	end

	return false
end

function ClientActivityUtils.redDotPoint_CheckPetResearchCatchItem(index)
	if not pg.me or not pg.me.luckyPetDayRewarded then
		return false
	end

	local canGetRewardList = ActivityUtils.getLuckyPetCanRewardList(pg.me)

	return canGetRewardList[index] == true and not pg.me.luckyPetDayRewarded[index]
end

function ClientActivityUtils.redDotPoint_CheckPetResearchPhotoItem(index)
	if not pg.me or not pg.me.formResearchStageRewarded then
		return false
	end

	local canGetRewardList = ActivityUtils.getFormResearchCanRewardList(pg.me)

	return canGetRewardList[index] == true and not pg.me.formResearchStageRewarded[index]
end

function ClientActivityUtils.redDotPoint_CheckDailyActiveRewardItem(taskId)
	if not pg.me or not ActivityUtils.isOprActivityOpenByType(ActivityConst.EventType.DailyActive) then
		return false
	end

	return ActivityUtils.getActTaskState(pg.me, taskId) == ActivityConst.TaskState.Finihed_CanRecv
end

function ClientActivityUtils.checkPetSaveFinish()
	return pg.me.activityPetSaveData and pg.me.activityPetSaveData.savePetInfo and pg.me.activityPetSaveData.savePetInfo.entityId and pg.me.activityPetSaveData.savePetInfo.entityId ~= ""
end

function ClientActivityUtils.checkPetSaveCurWeek()
	local typeData = PetSaveManualData[pg.me.activityPetSaveData and pg.me.activityPetSaveData.pshase or 1]
	local maxIndex = 0
	local saveType = 1

	if not typeData or not next(typeData) then
		return maxIndex
	end

	for type, weekData in ipairs(typeData) do
		for i, weekCfg in pairs(weekData) do
			local time = Utils.getConfigTimeOfArea(weekCfg, "startTime")

			if time <= Time.secondCache and maxIndex < i then
				maxIndex = i
				saveType = type
			end
		end
	end

	return maxIndex
end

function ClientActivityUtils.checkPetSaveChangeLimit()
	return (pg.me.activityPetSaveData and pg.me.activityPetSaveData.saveTimes or 0) < SysConfigData.PETSAVE_CHANGE_TIME
end

function ClientActivityUtils.checkPetSaveFirstWeek(weekIndex)
	local typeData = PetSaveManualData[pg.me.activityPetSaveData and pg.me.activityPetSaveData.pshase or 1]
	local firstStartTime, minIndex

	if not typeData or not next(typeData) then
		return nil
	end

	for type, weekData in ipairs(typeData) do
		for i, weekCfg in pairs(weekData) do
			local time = Utils.getConfigTimeOfArea(weekCfg, "startTime")

			if not firstStartTime or time < firstStartTime then
				firstStartTime = time
				minIndex = i
			end
		end
	end

	return weekIndex == minIndex
end

function ClientActivityUtils.checkIsPetSaveType(weekIndex)
	return PetSaveManualSubactData[weekIndex] and PetSaveManualSubactData[weekIndex].typeId == 2
end

function ClientActivityUtils.checkPetSave(eventId)
	local curWeek = ClientActivityUtils.checkPetSaveCurWeek()

	return ClientActivityUtils.checkIsPetSaveType(curWeek) and not ClientActivityUtils.checkPetSaveFinish()
end

function ClientActivityUtils.getPetSaveVideoName(weekIndex)
	local weekCfg = PetSaveManualSubactData[weekIndex]
	local videoName = weekCfg and weekCfg.videoName

	if string.isNilOrEmpty(videoName) then
		return nil
	end

	return videoName
end

function ClientActivityUtils.checkPetSavePoint(eventId)
	local isOpen = ClientActivityUtils.isEventOpen(eventId)
	local eventData = GameEventData[eventId]

	if not eventData then
		return false
	end

	local isShow = false
	local eventTimeCfg = Utils.getEventTimeConfig(eventId)

	if eventTimeCfg.tabEndDayTime then
		isShow = Time.secondCache >= eventTimeCfg.tabEndDayTime - 72000 and Time.secondCache <= eventTimeCfg.tabEndDayTime
	end

	if isOpen and not ClientActivityUtils.checkPetSaveFinish() and isShow then
		return true
	end

	return false
end

function ClientActivityUtils.checkPetSaveRewardPoint()
	if not pg.me.activityPetSaveData or pg.me.activityPetSaveData.pshase == 0 then
		return false
	end

	local typeData = PetSaveManualData[pg.me.activityPetSaveData.pshase or 1]

	if typeData and pg.me.activityPetSaveData and next(pg.me.activityPetSaveData) then
		for i, weekCfg in pairs(typeData[1]) do
			local time = Utils.getConfigTimeOfArea(weekCfg, "endTime")

			if time <= Time.secondCache and (pg.me.activityPetSaveData[i] and pg.me.activityPetSaveData[i].received == 0 or not pg.me.activityPetSaveData[i]) then
				return true
			end
		end
	end

	return false
end

function ClientActivityUtils.getEcoTraceActivityData()
	return ActivityUtils.getActivityData(pg.me, ActivityConst.EventType.EcologyTrace)
end

function ClientActivityUtils.getEcoTraceActivityPhase()
	local activityData = ClientActivityUtils.getEcoTraceActivityData()

	return activityData and activityData.activityBase and activityData.activityBase.activityPhase or 0
end

function ClientActivityUtils.checkEcologySearchPoint()
	local activityData = ClientActivityUtils.getEcoTraceActivityData()

	return ClientActivityUtils.getEcoTracePetId() and activityData and activityData.ecoTraceSearchCnt > 0 and activityData.ecoTraceSearchMarkId == 0 or false
end

function ClientActivityUtils.checkEcologyQusetPoint()
	local taskUI = pg.global.ui.eventEcoTraceTask
	local model = taskUI and taskUI.model

	return ClientActivityUtils.getEcoTracePetId() and model and model:hasRewardCanGet() or false
end

function ClientActivityUtils.checkEcologyCenterPoint()
	local activityData = ClientActivityUtils.getEcoTraceActivityData()
	local ecoCfgs = ClientActivityUtils.getEcoTraceActivityCfg()
	local projectBoost = ecoCfgs and ecoCfgs.projectBoost and ecoCfgs.projectBoost[Const.ECO_TRACE_PROJECT.Shiny]
	local needCount = math.max(tonumber(projectBoost and projectBoost[1]) or 0, 0)
	local curStage = tonumber(activityData and activityData.ecoTraceSearchProjStage) or 0
	local compTaskNum = math.max(tonumber(activityData and activityData.ecoTraceSearchProjCompTaskNum) or 0, 0)

	return curStage == Const.ECO_TRACE_PROJECT.Shiny and needCount > 0 and needCount <= compTaskNum
end

function ClientActivityUtils.checkEcoTraceSearchNearEnd(eventId)
	local petId = ClientActivityUtils.getEcoTracePetId()
	local ecoTraceCfg = EcoTraceSearchData[petId]

	if not ecoTraceCfg or not next(ecoTraceCfg) then
		return false
	end

	local eventTimeCfg = Utils.getEventTimeConfig(eventId)

	return eventTimeCfg.tabEndDayTime and ecoTraceCfg.durtime and eventTimeCfg.tabEndDayTime - Time.getSecond() <= ecoTraceCfg.durtime
end

function ClientActivityUtils.getEcoTracePetId()
	local activityData = ClientActivityUtils.getEcoTraceActivityData()

	if not activityData or activityData.ecoTracePetId == 0 then
		return nil
	end

	return activityData.ecoTracePetId
end

function ClientActivityUtils.getEcoTraceMarkRadius()
	local petId = ClientActivityUtils.getEcoTracePetId()
	local ecoTraceCfg = EcoTraceSearchData[petId]

	if not ecoTraceCfg or not next(ecoTraceCfg) then
		return 0
	end

	return ecoTraceCfg.radius or 0
end

function ClientActivityUtils.getEcoTraceActivityCfg()
	local phase = ClientActivityUtils.getEcoTraceActivityPhase()

	return EcoTraceActivityData[phase] or nil
end

function ClientActivityUtils.getNextEcoTraceSearchTime()
	local ecoCfgs = ClientActivityUtils.getEcoTraceActivityCfg()

	if not ecoCfgs then
		return 0
	end

	local nextStartTime = 0

	if ecoCfgs.periodStartTimes then
		local curTime = Time.secondCache

		for i, _ in ipairs(ecoCfgs.periodStartTimes) do
			local startTime = Utils.getConfigTimeOfArea(ecoCfgs.periodStartTimes, i)

			if startTime and curTime <= startTime and (nextStartTime == 0 or startTime < nextStartTime) then
				nextStartTime = startTime
			end
		end
	end

	return nextStartTime
end

function ClientActivityUtils.getEcoTraceProInfo(stage)
	local proInfoList = {}
	local ecoCfgs = ClientActivityUtils.getEcoTraceActivityCfg()

	if not ecoCfgs then
		return {}
	end

	local curPro = ClientActivityUtils.getEcoStagePro(stage)
	local boosts = ecoCfgs.projectBoost and ecoCfgs.projectBoost[stage]

	for i = 1, boosts[1] do
		local proNum = ClientActivityUtils.getEcoStageProNum(stage, i)

		proInfoList[i] = {
			pro = proNum,
			state = curPro == i and "CurrentEffect" or i < curPro and "completed" or "incomplete"
		}
	end

	return proInfoList
end

local function isEcoStageFinished(stage, ecoCfgs)
	local activityData = ClientActivityUtils.getEcoTraceActivityData()
	local curStage = tonumber(activityData and activityData.ecoTraceSearchProjStage) or 0

	if curStage <= 0 then
		return false
	end

	if stage < curStage then
		return true
	end

	if curStage ~= stage then
		return false
	end

	if stage ~= Const.ECO_TRACE_PROJECT.Shiny then
		return false
	end

	local projectBoost = ecoCfgs and ecoCfgs.projectBoost and ecoCfgs.projectBoost[stage]
	local needCount = math.max(tonumber(projectBoost and projectBoost[1]) or 0, 0)
	local compTaskNum = math.max(tonumber(activityData and activityData.ecoTraceSearchProjCompTaskNum) or 0, 0)

	return needCount > 0 and needCount <= compTaskNum
end

function ClientActivityUtils.getEcoStageInfo(isSearchInfo)
	local activityData = ClientActivityUtils.getEcoTraceActivityData()
	local ecoCfgs = ClientActivityUtils.getEcoTraceActivityCfg()
	local stageInfo = {}
	local curStage = math.min(math.max(tonumber(activityData and activityData.ecoTraceSearchProjStage) or 1, Const.ECO_TRACE_PROJECT.Maturity), Const.ECO_TRACE_PROJECT.Shiny)

	for stage = Const.ECO_TRACE_PROJECT.Maturity, Const.ECO_TRACE_PROJECT.Shiny do
		local state = UIConst.EventEcoTraceState.UnLock

		if isEcoStageFinished(stage, ecoCfgs) then
			state = UIConst.EventEcoTraceState.Active
		elseif stage == curStage then
			state = UIConst.EventEcoTraceState.Researching
		end

		if isSearchInfo then
			if stage <= (activityData and activityData.ecoTraceSearchStageRecord or 1) then
				table.insert(stageInfo, {
					stage = stage,
					state = state
				})
			end
		else
			stageInfo[stage] = {
				state = state
			}
		end
	end

	return stageInfo, curStage
end

function ClientActivityUtils.getEcoStagePro(stage)
	local activityData = ClientActivityUtils.getEcoTraceActivityData()
	local ecoCfgs = ClientActivityUtils.getEcoTraceActivityCfg()

	if not ecoCfgs then
		return 0, 0
	end

	local boosts = ecoCfgs.projectBoost and ecoCfgs.projectBoost[stage]
	local maxPro = math.max(tonumber(boosts and boosts[1]) or 0, 0)
	local curStage = tonumber(activityData and activityData.ecoTraceSearchProjStage) or 0
	local curStagePro = math.max(tonumber(activityData and activityData.ecoTraceSearchProjCompTaskNum) or 0, 0)

	if maxPro <= 0 then
		return 0, 0
	end

	if stage == curStage then
		return curStagePro, maxPro
	end

	if curStage > 0 and stage < curStage then
		return maxPro, maxPro
	end

	return 0, maxPro
end

function ClientActivityUtils.getEcoStageProNum(stage, setPro)
	local ecoCfgs = ClientActivityUtils.getEcoTraceActivityCfg()

	if not ecoCfgs then
		return 0, 0
	end

	local chosePetId = ClientActivityUtils.getEcoTracePetId()
	local ecoSearchCfg = chosePetId and EcoTraceSearchData[chosePetId] or nil
	local curPro, maxPro = ClientActivityUtils.getEcoStagePro(stage)
	local projectBoost = ecoCfgs.projectBoost and ecoCfgs.projectBoost[stage]
	local boostNeedCount = math.max(tonumber(projectBoost and projectBoost[1]) or 0, 0)
	local boostMaxAdd = math.max(tonumber(projectBoost and projectBoost[2]) or 0, 0)

	curPro = setPro or curPro

	local safeCurPro = math.max(tonumber(curPro) or 0, 0)
	local addNum, maxNum = 0, 1

	if stage == Const.ECO_TRACE_PROJECT.Maturity then
		local weights = ecoSearchCfg and ecoSearchCfg.puppetWeights or nil
		local leftWeight = math.max(tonumber(weights and weights[1]) or 0, 0)
		local rightWeight = math.max(tonumber(weights and weights[2]) or 0, 0)
		local totalWeight = leftWeight + rightWeight
		local addWeight = curPro / maxPro * boostMaxAdd

		if totalWeight <= 0 or rightWeight <= 0 or boostMaxAdd <= 0 then
			return 0, 100
		end

		local baseRate = rightWeight / totalWeight
		local curRate = (rightWeight + addWeight) / (totalWeight + addWeight)
		local maxRate = (rightWeight + boostMaxAdd) / (totalWeight + boostMaxAdd)

		addNum = math.max((curRate - baseRate) / baseRate, 0)
		maxNum = math.max((maxRate - baseRate) / baseRate, 0)
	elseif stage == Const.ECO_TRACE_PROJECT.Shiny then
		local baseRate = ecoSearchCfg.shinyRate or 1
		local targetPro = safeCurPro / boostNeedCount * boostMaxAdd

		if targetPro <= 0 then
			return 0, 100
		end

		addNum = math.min(targetPro, boostMaxAdd) / baseRate
		maxNum = 1
	else
		local addMulti = ecoSearchCfg.param[safeCurPro]
		local maxMulti = ecoSearchCfg.param[maxPro]
		local baseRates = PetTalentRandomGroupData[1].value[2]
		local totalNum = 0
		local totalNumMax = 0
		local baseRate = baseRates[4] / 1

		for i, v in ipairs(baseRates) do
			local addRate = addMulti and v * addMulti[i] or 0
			local addRateMax = v * maxMulti[i]

			totalNum = totalNum + addRate
			totalNumMax = totalNum + addRateMax

			if i == #baseRates then
				addNum = addRate / totalNum / baseRate
				maxNum = addRateMax / totalNumMax / baseRate
			end
		end
	end

	return math.ceil(addNum * 100), math.ceil(maxNum * 100)
end

function ClientActivityUtils.redDotReward_CheckVitalityRewardItem(phase, themeId, rewardIndex)
	local themeData = EnergyMatchThemeData[phase][themeId]
	local curScore = pg.me.energyMatchJoinSum[themeId]
	local getIndex = pg.me.energyMatchAwardFlag[themeId] or 0

	if not curScore then
		return false
	end

	local rewardItem = themeData.award[rewardIndex]

	if rewardItem and curScore >= rewardItem[1] and getIndex < rewardIndex then
		return true
	end

	return false
end

function ClientActivityUtils._isInLeylineTreeUpTime(cfg)
	if not cfg then
		local attrName = ActivityConst.NewFrameEventAttriName[ActivityConst.EventType.LeylineTreeUp]
		local actData = attrName and pg.me[attrName]
		local phase = actData and actData.activityBase and actData.activityBase.activityPhase

		cfg = EventLeylineTreeUpData[phase]
	end

	local upStartTime = cfg and Utils.getConfigTimeOfArea(cfg, "upStartTime")
	local upEndTime = cfg and Utils.getConfigTimeOfArea(cfg, "upEndTime")
	local now = Time.secondCache

	return upStartTime and upEndTime and upStartTime <= now and now < upEndTime or false
end

function ClientActivityUtils._getLeylineTreeUpRedDotStyle(eventId)
	local eventCfg = GameEventData[eventId]

	if not eventCfg or eventCfg.eventType ~= ActivityConst.EventType.LeylineTreeUp then
		return RedDotConst.RedDotStyle.NONE
	end

	if not ClientActivityUtils._isInLeylineTreeUpTime() then
		return RedDotConst.RedDotStyle.NONE
	end

	local taskMap = ActivityUtils.getActTaskMap(pg.me, eventCfg.eventType)

	if not taskMap then
		return RedDotConst.RedDotStyle.NONE
	end

	for _, taskInfo in pairs(taskMap) do
		if taskInfo.state == ActivityConst.TaskState.Finihed_CanRecv then
			return RedDotConst.RedDotStyle.REWARD
		end
	end

	return RedDotConst.RedDotStyle.NONE
end

function ClientActivityUtils._getGrowthGiftRedDotStyle(eventId)
	local actData = ActivityUtils.getActivityData(pg.me, ActivityConst.EventType.GrowthGift)

	if not actData then
		return RedDotConst.RedDotStyle.NONE
	end

	if actData.receivedPetFlag == 1 then
		local activateTaskCfg = ActivateTasksData[eventId]
		local taskGroupId = activateTaskCfg and activateTaskCfg.foreverTaskGroup and activateTaskCfg.foreverTaskGroup[1]

		for _, taskInfo in ipairs(ClientActivityUtils.getTaskInfoList(taskGroupId, true)) do
			if taskInfo.taskState == ActivityConst.TaskState.Finihed_CanRecv then
				return RedDotConst.RedDotStyle.REWARD
			end
		end

		return RedDotConst.RedDotStyle.NONE
	end

	if (actData.selectedPetId or 0) == 0 then
		return RedDotConst.RedDotStyle.POINT
	end

	local eventCfg = GameEventData[eventId]
	local actCfg = eventCfg and EventGrowthGiftData[eventCfg.phase]
	local condId = actCfg and actCfg.canReceiveCond or 0

	if condId == 0 then
		return RedDotConst.RedDotStyle.REWARD
	end

	if pg.me and pg.me.triggerMap and pg.me.triggerMap:isCompleteOrMeetCondition(condId) then
		return RedDotConst.RedDotStyle.REWARD
	end

	return RedDotConst.RedDotStyle.NONE
end

function ClientActivityUtils.getFirstTopupRedDotStyle()
	local taskList = ClientActivityUtils.getTaskInfoByTaskType(ActivityConst.EventType.FirstTopup, ActivityConst.ActivityTaskType.Active_AchievementTask)

	for _, taskData in ipairs(taskList) do
		if taskData.taskState == ActivityConst.TaskState.Finihed_CanRecv then
			return RedDotConst.RedDotStyle.REWARD
		end
	end

	return RedDotConst.RedDotStyle.NONE
end

function ClientActivityUtils._getFirstTopupRedDotStyle()
	return ClientActivityUtils.getFirstTopupRedDotStyle()
end

function ClientActivityUtils._getCrossPlatformRedDotStyle()
	local taskList = ClientActivityUtils.getTaskInfoByActType(ActivityConst.EventType.CrossPlatform)

	for _, taskData in ipairs(taskList) do
		if taskData.taskState == ActivityConst.TaskState.Finihed_CanRecv then
			return RedDotConst.RedDotStyle.REWARD
		end
	end

	return RedDotConst.RedDotStyle.NONE
end

function ClientActivityUtils.isLeylineTreeUp(blockId)
	local result, activityId = ActivityUtils.isOprActivityUpOpenByType(ActivityConst.EventType.LeylineTreeUp)
	local isOpen, isNew = false, false

	if result then
		local attrName = ActivityConst.NewFrameEventAttriName[ActivityConst.EventType.LeylineTreeUp]
		local actData = attrName and pg.me[attrName]
		local phase = actData and actData.activityBase and actData.activityBase.activityPhase
		local cfg = EventLeylineTreeUpData[phase]
		local isInUpTime = ClientActivityUtils._isInLeylineTreeUpTime(cfg)
		local hasRemainTimes = false

		if isInUpTime then
			for _, mapBlockId in ipairs(cfg and cfg.mapBlockIds or {}) do
				local total = cfg.upCounts and cfg.upCounts[mapBlockId] or 0
				local used = actData and actData.upTimesDailys and actData.upTimesDailys[mapBlockId] or 0

				if (not blockId or blockId == mapBlockId) and used < total then
					hasRemainTimes = true

					break
				end
			end
		end

		if hasRemainTimes then
			isOpen = true

			local key = ClientConst.PrefKey.EventIconUpNew .. activityId .. pg.me.uid

			isNew = pg.global.prefsCacheUtils:getBool(key, true)
		end
	end

	return isOpen, isNew, activityId
end

function ClientActivityUtils.setLeylineTreeUpWidget(container, active, overrideTxt)
	if not container then
		return
	end

	container:SetActive(active)

	if active then
		local txt = overrideTxt or pg.getGameString("UP_EVENT_TIP")

		if container:CheckURLLoaded() then
			local objectRef = container.content:GetComponent("ObjectReference")
			local upTxt = objectRef and objectRef:GetRefValue("txtNameUBaseText")

			if upTxt then
				ClientTextUtils.setText(upTxt, txt)
			end
		else
			container:LoadDefaultUrlManually(function(content)
				local objectRef = content:GetComponent("ObjectReference")
				local upTxt = objectRef and objectRef:GetRefValue("txtNameUBaseText")

				if upTxt then
					ClientTextUtils.setText(upTxt, txt)
				end
			end)
		end
	end
end

function ClientActivityUtils.isRogueRewardUp()
	local result, activityId = ActivityUtils.isOprActivityUpOpenByType(ActivityConst.EventType.MockBattle)
	local isOpen, isNew = false, false

	if result then
		isOpen = true

		local key = ClientConst.PrefKey.EventIconUpNew .. activityId .. pg.me.uid

		isNew = pg.global.prefsCacheUtils:getBool(key, true)
	end

	return isOpen, isNew, activityId
end

function ClientActivityUtils.getRogueRewardUpConfig()
	local isOpen, isNew, activityId = ClientActivityUtils.isRogueRewardUp()
	local remainCnt, totalCnt, curPlayCnt = 0, 0, 0

	if isOpen then
		local curCnt = pg.me and pg.me.upRogueExchangeCount or 0

		totalCnt = SysConfigData.mockBattle_UpLimit
		remainCnt = totalCnt - curCnt
		curPlayCnt = pg.me and pg.me.curUpRogueExchangeCount or 0
	end

	return remainCnt, totalCnt, curPlayCnt
end

function ClientActivityUtils.isRogueRewardUpWithRemainTimes()
	local isOpen, isNew, activityId = ClientActivityUtils.isRogueRewardUp()

	if not isOpen then
		return false, isNew, activityId
	end

	local remainCnt = ClientActivityUtils.getRogueRewardUpConfig()

	return remainCnt > 0, isNew, activityId
end

function ClientActivityUtils.initRogueRewardUpWidget(rootWidget, timesTxt)
	if not rootWidget then
		return
	end

	local isRewardUp = ClientActivityUtils.isRogueRewardUpWithRemainTimes()

	rootWidget:SetActive(isRewardUp)

	if isRewardUp then
		local remainCnt, totalCnt, curCostCnt = ClientActivityUtils.getRogueRewardUpConfig()
		local objectRef = rootWidget:GetComponent("ObjectReference")
		local timesUBaseText, curCostTxt

		if objectRef then
			timesUBaseText = objectRef:GetRefValue("timesUBaseText")
			curCostTxt = objectRef:GetRefValue("curCostTxt")
		end

		if timesTxt then
			timesUBaseText = timesTxt
		end

		if timesUBaseText then
			ClientTextUtils.setText(timesUBaseText, string.format("%s/%s", remainCnt, totalCnt))
		end

		if curCostTxt then
			ClientTextUtils.setText(curCostTxt, pg.getFormatText(pg.getGameString("MOCKBATTLE_UP_CONSUME"), curCostCnt))
		end
	end
end

function ClientActivityUtils.getPuppetPhotoClueAllText(templateId)
	local pData = PetData[templateId]

	if not pData then
		return {}
	end

	local res = {}
	local elementInfo = ElementPropData[pData.mainElementType] or {}
	local elementName = elementInfo.name_ch or "None"

	res[ActivityConst.PuppetPhotoClueType.Attr] = {
		pg.getGameString("PETSHAPE_ELEMENT"),
		ClientTextUtils.concatByLanguage(pg.getLocalizationText(elementName), pg.getGameString("FILTER_ELEMENT"))
	}

	local formName = LuaUIUtils.getPetFormName(templateId)

	res[ActivityConst.PuppetPhotoClueType.Form] = {
		pg.getGameString("PET_APPEARANCE"),
		formName
	}
	res[ActivityConst.PuppetPhotoClueType.Stage] = {
		pg.getGameString("PET_STAGE"),
		pg.getGameString("PET_STAGE_TXT_" .. pData.stage)
	}

	local career = pData.functionId or ""

	res[ActivityConst.PuppetPhotoClueType.Career] = {
		pg.getGameString("FILTER_ROLE"),
		pg.getLocalizationText(PetConfigData[string.format("petFunctionText%s", career)]) or ""
	}

	local exploreKeys = {}

	for key, data in pairs(ExploreAbilityData) do
		local num = pData[key] ~= nil and pData[key] or -1

		if type(num) == "boolean" and num or type(num) == "number" and num > 0 then
			table.insert(exploreKeys, key)
		end
	end

	local exploreStr = ""
	local exploreNameSet = {}

	for i = 1, #exploreKeys do
		local str = type(exploreKeys[i]) == "string" and pg.getLocalizationText(ExploreAbilityData[exploreKeys[i]].name) or pg.getLocalizationText(exploreKeys[i])

		if not exploreNameSet[str] then
			exploreNameSet[str] = true

			if exploreStr ~= "" then
				exploreStr = string.format("%s,%s", exploreStr, str)
			else
				exploreStr = str
			end
		end
	end

	res[ActivityConst.PuppetPhotoClueType.Explore] = {
		pg.getGameString("SC_EXPLOREABILITY"),
		exploreStr ~= "" and exploreStr or pg.getGameString("PETSHAPE_NOEXPLORE")
	}

	return res
end

function ClientActivityUtils.getAreaActivitySubTaskPrefCache(eventId, subTaskIndex, isFinish)
	if not eventId or not subTaskIndex then
		return 1
	end

	local prefix = isFinish and ClientConst.PrefKey.EventAreaActivityFinish or ClientConst.PrefKey.EventAreaActivityAppear

	return pg.global.prefsCacheUtils:getInt(prefix .. eventId .. subTaskIndex .. pg.me.uid, 0)
end

function ClientActivityUtils.onRenderRewardProgressItem(button, index, data, isProgressManaged)
	local itemComs = {}
	local objectReference = button.transform:GetComponent("ObjectReference")

	itemComs.button = button
	itemComs.progressNum = objectReference:GetRefValue("progressNum")
	itemComs.progress = objectReference:GetRefValue("progress")
	itemComs.rewardItemAnim = objectReference:GetRefValue("rewardItemAnim")
	itemComs.rewardItem = objectReference:GetRefValue("rewardItem")
	itemComs.progressItemObj = objectReference:GetRefValue("progressItemObj")
	itemComs.progressAnimation = objectReference:GetRefValue("progressAnimation")
	itemComs.specialRewardUButton = objectReference:GetRefValue("specialRewardUButton")
	itemComs.specialRewardUImage = objectReference:GetRefValue("specialRewardUImage")

	ClientTextUtils.setText(itemComs.progressNum, data.targetNum)

	if not isProgressManaged then
		itemComs.progress.value = data.progress or 0
	end

	local subData = {}
	local temp = LuaUIUtils.getRewardItemByDropId(data.dropId)

	if temp ~= nil and #temp > 0 then
		subData = temp[1]
	end

	table.merge(subData, data)

	subData.hasGet = data.state == ClientConst.RewardState.Claimed
	subData.canGet = data.state == ClientConst.RewardState.ReadyToClaim
	subData.hierarchyMode = 1
	subData.sortingOrder = 3

	LuaUIUtils.renderRewards(itemComs.rewardItem, nil, subData)

	if data.isSpecial then
		if itemComs.specialRewardUButton then
			itemComs.button:TryChangePage("Special", 1)

			function itemComs.specialRewardUButton.luaClick()
				LuaUIUtils.onRewardItemClick(itemComs.specialRewardUButton, subData)
			end
		end

		if itemComs.specialRewardUImage then
			itemComs.specialRewardUImage.url = LuaUIUtils.getIconByItemId(subData.id)
		end
	elseif itemComs.specialRewardUButton then
		itemComs.button:TryChangePage("Special", 0)

		itemComs.specialRewardUButton.luaClick = nil
	end

	return itemComs
end

function ClientActivityUtils._getEventTaskDataWithWarn(taskId, source)
	local taskData = EventTaskData and EventTaskData[taskId]

	if not taskData and LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("@ClientActivityUtils missing EventTaskData, source=%s, taskId=%s", tostring(source), tostring(taskId))
	end

	return taskData
end

function ClientActivityUtils.getTaskInfoList(taskGroupId, dontStateSort)
	local res = {}

	if not taskGroupId then
		return res
	end

	local taskIds = ActivityUtils.getActTaskIdsByGroupId(taskGroupId)

	for index, taskId in ipairs(taskIds) do
		local taskData = ClientActivityUtils._getEventTaskDataWithWarn(taskId, "getTaskInfoList")

		if taskData then
			res[#res + 1] = {
				taskId = taskId,
				taskTitle = taskData.eventTitle,
				taskDes = taskData.taskDes,
				taskCondition = taskData.taskCondition,
				taskAward = taskData.award,
				taskState = ActivityUtils.getActTaskState(pg.me, taskId) or 1,
				taskEvent = taskData.event,
				sourceId = taskData.sourceId,
				eventIcon = taskData.eventIcon,
				taskType = taskData.actTaskType,
				showIndex = taskData.sort or 1
			}
		end
	end

	local function sortFunc(a, b)
		local aState = a.taskState
		local bState = b.taskState

		if aState == bState or dontStateSort then
			local aSort = a.showIndex
			local bSort = b.showIndex

			if aSort == bSort then
				return a.taskId < b.taskId
			else
				return aSort < bSort
			end
		else
			local aPri = ActivityConst.TaskSortPri[aState]
			local bPri = ActivityConst.TaskSortPri[bState]

			return bPri < aPri
		end
	end

	table.sort(res, sortFunc)

	return res
end

function ClientActivityUtils.getTaskInfoByActType(actType)
	local res = {}

	if not actType or not pg.me then
		return res
	end

	local taskMap = ActivityUtils.getActTaskMap(pg.me, actType)

	if not taskMap then
		return res
	end

	local triggerMap = pg.me and pg.me.triggerMap

	for taskId, taskInfo in pairs(taskMap) do
		local taskData = ClientActivityUtils._getEventTaskDataWithWarn(taskId, "getTaskInfoByActType")

		if taskData then
			local progress = taskData.taskCondition and triggerMap:getConditionFinishCount(taskData.taskCondition, 1) or 0
			local target = taskData.taskCondition and triggerMap:getConditionTargetCount(taskData.taskCondition, 1) or 0

			res[#res + 1] = {
				taskId = taskId,
				taskTitle = taskData.eventTitle,
				taskDes = taskData.taskDes,
				taskCondition = taskData.taskCondition,
				taskAward = taskData.award,
				taskState = taskInfo.state or 1,
				taskEvent = taskData.event,
				sourceId = taskData.sourceId,
				eventIcon = taskData.eventIcon,
				taskType = taskData.actTaskType,
				taskGroupId = taskData.groupId,
				sort = taskData.sort,
				sparam = taskInfo.sparam,
				progress = taskInfo.state == ActivityConst.TaskState.UnFinished and progress or target,
				target = target
			}
		end
	end

	return res
end

function ClientActivityUtils.getTaskInfoByTaskId(actType, aTaskId)
	if not actType or not pg.me then
		return {}
	end

	local taskInfoList = ClientActivityUtils.getTaskInfoByActType(actType)

	if taskInfoList then
		for _, taskInfo in ipairs(taskInfoList) do
			if taskInfo.taskId == aTaskId then
				return taskInfo
			end
		end
	end
end

function ClientActivityUtils.getTaskInfoByTaskType(actType, taskType)
	local res = {}

	if not actType or not pg.me then
		return res
	end

	local taskInfoList = ClientActivityUtils.getTaskInfoByActType(actType)

	if taskInfoList then
		for _, taskInfo in ipairs(taskInfoList) do
			if taskInfo.taskType == taskType then
				res[#res + 1] = taskInfo
			end
		end
	end

	return res
end

function ClientActivityUtils._getPetDispatchRedDotStyle(eventId)
	local allTaskData = ClientActivityUtils.getTaskInfoByActType(ActivityConst.EventType.PetDispatch)

	for k, data in ipairs(allTaskData) do
		if data.taskState == ActivityConst.TaskState.Finihed_CanRecv then
			return RedDotConst.RedDotStyle.REWARD
		end
	end

	return RedDotConst.RedDotStyle.NONE
end

function ClientActivityUtils.getPetDisPatchInfo(actType, taskId)
	local disPatchInfo
	local taskData = ClientActivityUtils.getTaskInfoByTaskId(ActivityConst.EventType.PetDispatch, taskId)

	if not taskData then
		return
	end

	if taskData.sparam then
		disPatchInfo = lume.deserialize(taskData.sparam)
	end

	return disPatchInfo
end

function ClientActivityUtils.getCanGetRewardByTaskGroupId(taskGroupId)
	local res = false
	local taskIds = ActivityUtils.getActTaskIdsByGroupId(taskGroupId)

	for _, taskId in ipairs(taskIds) do
		if ClientActivityUtils.getCanGetRewardByTaskId(taskId) then
			res = true

			break
		end
	end

	return res
end

function ClientActivityUtils.getCanGetRewardByTaskId(taskId)
	local taskData = ActivityUtils.getActTaskData(pg.me, taskId)

	if taskData and taskData.state == ActivityConst.TaskState.Finihed_CanRecv then
		return true
	end

	return false
end

function ClientActivityUtils.isPetHatchActivityOpen()
	local activity = ActivityUtils.getActivityData(pg.me, ActivityConst.EventType.PetHatch)

	if activity then
		return activity.activityBase:isGoing()
	end

	return false
end

function ClientActivityUtils.getPetHatchActivityUpTimeRata()
	local activity = ActivityUtils.getActivityData(pg.me, ActivityConst.EventType.PetHatch)

	if not activity or not activity.activityBase:isGoing() then
		return 0
	end

	local speedTimeRate = activity:getSpeedUpTimeRate() or 0

	return math.floor(speedTimeRate / 10)
end

function ClientActivityUtils.getMonthCardSpeedupHatchTime()
	local accelMinutes = MonthCardUtils.getPrivilegeReduceHatchTime()

	return accelMinutes
end

function ClientActivityUtils.checkPreHeatDone(activityId)
	if not ActivityUtils.checkActSwitchByActId(activityId) then
		return false
	end

	if not ActivityUtils.isOprActivityTabOpen(activityId, pg.me) then
		return false
	end

	local actType = GameEventData[activityId] and GameEventData[activityId].eventType or nil
	local preHeatsMap = pg.me.activityMapGuidePreheat

	if preHeatsMap and actType then
		return preHeatsMap[actType] and preHeatsMap[actType].preheated == 1
	end

	return false
end

function ClientActivityUtils.getCommonMaxProgress(eventId, isPersonal)
	local cfg = EventGlobalProgressData[eventId]

	if not cfg then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("@ClientActivityUtils missing EventGlobalProgressData, eventId=%s", tostring(eventId))
		end

		return 0
	end

	if isPersonal then
		return cfg.personalProgressMax or 0
	end

	local worldProgressMax = cfg.worldProgressMax

	if not Utils.isTable(worldProgressMax) then
		return 0
	end

	return worldProgressMax[Utils.getServerArea()] or 0
end

function ClientActivityUtils.getFishingCaptureCubeExchangeCount(cubeType)
	local fishingData = ActivityUtils.getActivityData(pg.me, ActivityConst.EventType.FishingCapture)
	local exchangeCountMap = fishingData and fishingData.cubeExchangeCountMap

	return tonumber(exchangeCountMap and exchangeCountMap[cubeType]) or 0
end

function ClientActivityUtils.getFishingCaptureIrisRewardReceived()
	local fishingData = ActivityUtils.getActivityData(pg.me, ActivityConst.EventType.FishingCapture)

	return fishingData ~= nil and fishingData.irisRewardReceived == true
end

ClientActivityUtils.FishingCaptureRedDotName = {
	WeeklyItem = "WeeklyItem",
	Weekly = "Weekly",
	ShopUnlock = "ShopUnlock",
	WindkissStage = "WindkissStage",
	IrisStage = "IrisStage"
}

function ClientActivityUtils.getFishingCaptureRedDotRecordKey(eventId, redDotName, marker)
	return string.format("FishingCapture_%s_%s_%s", tostring(eventId), tostring(redDotName), tostring(marker or 0))
end

function ClientActivityUtils._getFishingCaptureNewState(eventId, redDotName, marker)
	if not pg.me or not pg.me.getRedDotRecord then
		return false
	end

	local recordKey = ClientActivityUtils.getFishingCaptureRedDotRecordKey(eventId, redDotName, marker)

	return pg.me:getRedDotRecord(Const.CLIENT_KEY.EVENT_RED_DOT, recordKey, true) == true
end

function ClientActivityUtils.getFishingCaptureRedDotState(eventId)
	local RedDotStyle = RedDotConst.RedDotStyle
	local RedDotName = ClientActivityUtils.FishingCaptureRedDotName
	local state = {
		weeklyNew = false,
		shopUnlockNew = false,
		windkissStageNew = false,
		irisStageNew = false,
		canSeek = false,
		canExchange = false,
		rewardTaskIds = {},
		style = RedDotStyle.NONE
	}
	local eventData = GameEventData[eventId]
	local activityConfig = eventData and FishingCaptureActivityData[eventData.phase]
	local activityData = ActivateTasksData[eventId]
	local taskGroupId = activityData and activityData.foreverTaskGroup and activityData.foreverTaskGroup[1]

	if taskGroupId then
		for _, taskId in ipairs(ActivityUtils.getActTaskIdsByGroupId(taskGroupId)) do
			if ClientActivityUtils.getCanGetRewardByTaskId(taskId) then
				state.rewardTaskIds[#state.rewardTaskIds + 1] = taskId
			end
		end
	end

	local fishingData = ActivityUtils.getActivityData(pg.me, ActivityConst.EventType.FishingCapture)
	local irisCubeExchanged = ClientActivityUtils.getFishingCaptureCubeExchangeCount(FishingCaptureConst.CubeType.LEGEND) > 0
	local irisRewardReceived = fishingData and fishingData.irisRewardReceived == true
	local displayStage = ClientActivityUtils.getFishingCaptureDisplayStage(eventId)
	local Stage = FishingCaptureConst.ActivityStage
	local irisStageUnlocked = displayStage >= Stage.IrisCompanion
	local windkissStageUnlocked = displayStage >= Stage.WindkissCompanion
	local petalItemId = activityConfig and activityConfig.petalItemId
	local petalCount = petalItemId and pg.me and pg.me.getItemCountById and pg.me:getItemCountById(petalItemId) or 0
	local ticketExchangeCost = tonumber(activityConfig and activityConfig.coincube) or 0

	state.canExchange = irisStageUnlocked and not irisCubeExchanged and ticketExchangeCost > 0 and ticketExchangeCost <= petalCount
	state.canSeek = irisStageUnlocked and irisCubeExchanged and not irisRewardReceived

	if irisStageUnlocked then
		state.irisStageNew = ClientActivityUtils._getFishingCaptureNewState(eventId, RedDotName.IrisStage)
		state.shopUnlockNew = ClientActivityUtils._getFishingCaptureNewState(eventId, RedDotName.ShopUnlock)

		local weekBegin = TimeUtils.getAreaWeekBegin(Time.secondCache)

		state.weeklyNew = ClientActivityUtils._getFishingCaptureNewState(eventId, RedDotName.Weekly, weekBegin)
	end

	if windkissStageUnlocked then
		state.windkissStageNew = ClientActivityUtils._getFishingCaptureNewState(eventId, RedDotName.WindkissStage)
	end

	if #state.rewardTaskIds > 0 then
		state.style = RedDotStyle.REWARD
	elseif state.canExchange or state.canSeek then
		state.style = RedDotStyle.POINT
	elseif state.irisStageNew or state.windkissStageNew or state.shopUnlockNew or state.weeklyNew then
		state.style = RedDotStyle.NEW
	end

	return state
end

function ClientActivityUtils.clearFishingCaptureRedDot(eventId, redDotName, marker)
	if not pg.me or not pg.me.setRedDotRecord then
		return false
	end

	if not ClientActivityUtils._getFishingCaptureNewState(eventId, redDotName, marker) then
		return false
	end

	local recordKey = ClientActivityUtils.getFishingCaptureRedDotRecordKey(eventId, redDotName, marker)
	local success = pg.me:setRedDotRecord(Const.CLIENT_KEY.EVENT_RED_DOT, recordKey, false)

	if success and pg.global and pg.global.refreshRedDotState then
		if redDotName == ClientActivityUtils.FishingCaptureRedDotName.Weekly then
			pg.global.refreshRedDotState(RedDotConst.RedDotPath.EVENT_FISHING_CAPTURE_WEEKLY_TAB)
			pg.global.refreshRedDotState(RedDotConst.RedDotPath.EVENT_FISHING_CAPTURE_PETAL_SOURCE)
		elseif redDotName == ClientActivityUtils.FishingCaptureRedDotName.IrisStage then
			pg.global.refreshRedDotState(string.format(RedDotConst.RedDotPath.EVENT_FISHING_CAPTURE_STAGE, FishingCaptureConst.ActivityStage.IrisCompanion))
		elseif redDotName == ClientActivityUtils.FishingCaptureRedDotName.WindkissStage then
			pg.global.refreshRedDotState(string.format(RedDotConst.RedDotPath.EVENT_FISHING_CAPTURE_STAGE, FishingCaptureConst.ActivityStage.WindkissCompanion))
		elseif redDotName == ClientActivityUtils.FishingCaptureRedDotName.ShopUnlock then
			pg.global.refreshRedDotState(RedDotConst.RedDotPath.EVENT_FISHING_CAPTURE_SHOP)
		end

		pg.global.refreshRedDotState(string.format(RedDotConst.RedDotPath.EVENT_TAB_LIST_ITEM, eventId))
		pg.global.refreshRedDotState(RedDotConst.RedDotPath.EVENT_TAB1)
		pg.global.refreshRedDotState(RedDotConst.RedDotPath.EVENT_TAB2)
		pg.global.refreshRedDotState(RedDotConst.RedDotPath.FUNC_MENU_EVENT)
	end

	return success
end

function ClientActivityUtils._getFishingCaptureRedDotStyle(eventId)
	return ClientActivityUtils.getFishingCaptureRedDotState(eventId).style
end

function ClientActivityUtils.resolveFishingCaptureStage(irisCubeExchanged, now, stageTwoStartTime, activityEndTime)
	local Stage = FishingCaptureConst.ActivityStage

	if irisCubeExchanged then
		return Stage.WindkissCompanion
	end

	if stageTwoStartTime and activityEndTime and stageTwoStartTime <= now and now < activityEndTime then
		return Stage.IrisCompanion
	end

	return Stage.FlowerGathering
end

function ClientActivityUtils.getFishingCaptureDisplayStage(eventId)
	local now = Time.secondCache
	local Stage = FishingCaptureConst.ActivityStage
	local eventData = GameEventData[eventId]
	local activityData = eventData and FishingCaptureActivityData[eventData.phase]
	local stageTwoStartTime = Utils.getConfigTimeOfArea(activityData, "spDayTime1")
	local activityEndTime = Utils.getConfigTimeOfArea(eventData, "tabEndDayTime")
	local irisCubeExchanged = ClientActivityUtils.getFishingCaptureCubeExchangeCount(FishingCaptureConst.CubeType.LEGEND) > 0
	local displayStage = ClientActivityUtils.resolveFishingCaptureStage(irisCubeExchanged, now, stageTwoStartTime, activityEndTime)

	return displayStage, stageTwoStartTime
end

function ClientActivityUtils.buildFishingCaptureStageTabs(displayStage, previousStage, selectedStage, stageTwoStartTime)
	local Stage = FishingCaptureConst.ActivityStage
	local TabState = FishingCaptureConst.ActivityTabState
	local tabs = {
		{
			stage = Stage.FlowerGathering,
			state = TabState.Unlocked
		}
	}

	if displayStage == Stage.FlowerGathering then
		tabs[#tabs + 1] = {
			stage = Stage.IrisCompanion,
			state = TabState.CountdownLocked,
			unlockTime = stageTwoStartTime
		}
		selectedStage = Stage.FlowerGathering
	else
		tabs[#tabs + 1] = {
			stage = Stage.IrisCompanion,
			state = TabState.Unlocked
		}
		tabs[#tabs + 1] = {
			stage = Stage.WindkissCompanion,
			state = displayStage == Stage.WindkissCompanion and TabState.Unlocked or TabState.ConditionLocked
		}

		if displayStage == Stage.IrisCompanion and previousStage ~= Stage.IrisCompanion then
			selectedStage = Stage.IrisCompanion
		elseif selectedStage ~= Stage.FlowerGathering and selectedStage ~= Stage.IrisCompanion and (selectedStage ~= Stage.WindkissCompanion or displayStage ~= Stage.WindkissCompanion) then
			selectedStage = Stage.IrisCompanion
		end
	end

	return tabs, selectedStage
end

function ClientActivityUtils.getFishingCaptureTabIcon(activityConfig, displayStage, fallbackIcon)
	local Stage = FishingCaptureConst.ActivityStage
	local icon

	if activityConfig then
		icon = displayStage == Stage.FlowerGathering and activityConfig.tabIconResId1 or activityConfig.tabIconResId2
	end

	return icon or fallbackIcon
end

function ClientActivityUtils.getFishingCaptureTaskTarget(taskConfig)
	if not pg.me or not taskConfig then
		return 0
	end

	local triggerMap = pg.me.triggerMap

	return triggerMap:getConditionTargetCount(taskConfig.taskCondition, 1)
end

ClientActivityUtils.FishingCaptureProgressMaximum = 100

function ClientActivityUtils.resolveFishingCaptureProgress(petalCount, progressTasks)
	petalCount = math.max(0, tonumber(petalCount) or 0)

	local maximum = ClientActivityUtils.FishingCaptureProgressMaximum
	local completedTarget = 0
	local renderedProgressTasks = {}

	for index, progressTask in ipairs(progressTasks or {}) do
		local target = math.max(0, ClientActivityUtils.getFishingCaptureTaskTarget(progressTask))
		local completed = progressTask.taskState and progressTask.taskState >= ActivityConst.TaskState.Finihed_CanRecv

		if completed then
			completedTarget = math.max(completedTarget, target)
		end

		local rendered = {}

		for key, value in pairs(progressTask) do
			rendered[key] = value
		end

		rendered.progress = completed and target or math.min(petalCount, target)
		rendered.target = target
		renderedProgressTasks[index] = rendered
	end

	local current = math.min(math.max(petalCount, completedTarget), maximum)

	return current, maximum, renderedProgressTasks
end

function ClientActivityUtils.getFishingCapturePetalTotalCnt()
	local fishingData = ActivityUtils.getActivityData(pg.me, ActivityConst.EventType.FishingCapture)
	local totalIrisNum = fishingData and fishingData.totalIrisNum

	if totalIrisNum and totalIrisNum ~= 0 then
		return totalIrisNum
	end

	local rewardStatistics = fishingData and fishingData.rewardStatistics
	local statisticsTotal = rewardStatistics and rewardStatistics[-1]

	if statisticsTotal and statisticsTotal ~= 0 then
		return statisticsTotal
	end

	local result = 0

	if rewardStatistics then
		for logType, cnt in pairs(rewardStatistics) do
			result = result + cnt
		end
	end

	return result
end

function ClientActivityUtils.getFishingCaptureDayHourText(targetTime, formatKey)
	local remainTime = math.max(targetTime - Time.secondCache, 0)
	local days = math.floor(remainTime / 86400)
	local hours = math.floor(remainTime % 86400 / 3600)
	local formatText

	if formatKey then
		formatText = pg.getGameString(formatKey)
	else
		formatText = string.format("{0}%s{1}%s", pg.getGameString("DAY"), pg.getGameString("HOUR"))
	end

	return pg.getFormatText(formatText, days, hours)
end

return ClientActivityUtils
