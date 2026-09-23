-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Event\\EventModel.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = require("Core.Log.LoggerManager").getLogger("EventModel")
local Class = require("Core.Framework.Class")
local ActivityConst = require("Common.Const.ActivityConst")
local FishingCaptureConst = require("Common.Const.FishingCaptureConst")
local ClientConst = require("Const.ClientConst")
local RedDotConst = require("Const.RedDotConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientActivityUtils = require("Utils.ClientActivityUtils")
local TimeUtils = require("Common.Utils.TimeUtils")
local Time = require("Core.Common.Time")
local ServiceUtils = require("Common.Utils.ServiceUtils")
local UIModel = require("Guis.UIModel")
local AddressDataConst = require("Const.AddressDataConst")
local GameEventData = require("Data.game_event_data")
local GameEventTypeData = require("Data.game_event_type_data")
local ActivityPetVoteData = require("Data.activity_pet_vote_data")
local PetData = require("Data.pet_data")
local PetConfigData = require("Data.pet_config_data")
local PetResearchCatchData = require("Data.pet_research_catch_data")
local PetResearchPhotoData = require("Data.pet_research_photo_data")
local PetResearchTrackData = require("Data.pet_research_track_data")
local Const = require("Common.Const.Const")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local Utils = require("Common.Utils.Utils")
local ClientUtils = require("Utils.ClientUtils")
local SysEventData = require("Data.sys_event_data")
local LevelData = require("Data.level_data")
local BuffConfigData = require("Data.buff_config_data")
local EventOfficialGroupData = require("Data.event_official_group_data")
local EventSocialBindData = require("Data.event_social_bind_data")
local GameEventTypePostData = require("Data.game_event_type_post_data")
local EventCatchRogueData = require("Data.event_catch_rogue_data")
local CustomTriggerData = require("Data.custom_trigger_data")
local PetFamilyData = require("Data.pet_family_data")
local ExploreAbilityData = require("Data.explore_ability_data")
local lume = require("Core.Common.lume")
local PetAccessoryTransformData = require("Data.pet_accessory_transform_data")
local TriggerUtils = require("Common.Utils.TriggerUtils")
local TriggerConst = require("Common.Const.TriggerConst")
local PuppetData = require("Data.puppet_data")
local EventModel = Class.LightClass("EventModel", UIModel)
local EnergyMatchThemeData = require("Data.energy_match_theme_data")
local PetSaveManualSubactData = require("Data.event_petsave_manual_subact_data")
local EcoTraceSearchData = require("Data.ecotrace_search_data")
local EventArkCarnData = require("Data.event_ark_carn_data")
local EventAreaActivityData = require("Data.event_area_activity_data")
local EventTaskData = require("Data.event_task_data")
local AppearanceJewelryPetData = require("Data.appearance_jewelry_pet_data")
local EventSignNewbie = require("Data.event_sign_newbie_data")
local EventSignVersion = require("Data.event_sign_version_data")
local FuncIdConfigData = require("Data.func_index_config_data")
local CashShopRedDotUtils = require("Utils.CashShopRedDotUtils")
local SysConfigData = require("Data.sys_config_data")
local SocialPartyData = require("Data.social_party_data")
local EventCommonGuideData = require("Data.event_common_guide_data")
local FishingCaptureActivityData = require("Data.fishing_capture_activity_data")
local EventGrowthGiftData = require("Data.event_growth_gitf_data")
local ActivateTasksData = require("Data.activate_tasks_data")

EventModel.TitleColor = {
	White = 1,
	Black = 0
}

function EventModel:getEventIdByEventType(eventType)
	local data = GameEventTypePostData[eventType]

	if not data then
		return
	end

	for eventId, info in pairs(data) do
		if ClientActivityUtils.isGameEventTabOpen(eventId) and (ActivityUtils.getOprActivityUnlockCond(eventId) or GameEventData[eventId].alwaysShow == 1) then
			return eventId
		end
	end
end

function EventModel:getTabText(eventId)
	local eventData = GameEventData[eventId]

	if not eventData then
		return
	end

	if eventData.eventType == ActivityConst.EventType.GrowthGift then
		local actData = ActivityUtils.getActivityData(pg.me, ActivityConst.EventType.GrowthGift)

		if actData and actData.receivedPetFlag == 1 then
			local actCfg = EventGrowthGiftData[eventData.phase]

			if actCfg and actCfg.eventTitle then
				return actCfg.eventTitle
			end
		end
	end

	return eventData.name
end

function EventModel:getTabList(tabType)
	local res = {}

	for id, eventData in pairs(GameEventData) do
		local eventTypeInfo = GameEventTypeData[eventData.eventType]

		if eventTypeInfo and eventTypeInfo.tabType == tabType and ClientActivityUtils.isGameEventTabOpen(id) then
			local unlock = ActivityUtils.getOprActivityUnlockCond(id) or eventData.alwaysShow == 1

			if unlock then
				local icon = eventData.iconResId

				if eventData.eventType == ActivityConst.EventType.FishingCapture then
					local activityConfig = FishingCaptureActivityData[eventData.phase]
					local displayStage = ClientActivityUtils.getFishingCaptureDisplayStage(id)

					icon = ClientActivityUtils.getFishingCaptureTabIcon(activityConfig, displayStage, icon)
				end

				local showIconUp = eventData.iconUp == 1

				if showIconUp and eventData.eventType == ActivityConst.EventType.LeylineTreeUp then
					showIconUp = ClientActivityUtils._isInLeylineTreeUpTime()
				end

				local info = {
					id = id,
					tabType = eventTypeInfo.tabType,
					text = self:getTabText(id),
					icon = icon,
					order = eventData.rank,
					showIconUp = showIconUp,
					isShow = unlock,
					eventType = eventData.eventType
				}

				table.insert(res, info)
			elseif LoggerManager.checkLogger(LoggerConst.WARN) then
				logger:warn("EventModel:getTabList eventId:%s, conditionId:%s is locked!!!", id, eventData.conditions)
			end
		end
	end

	table.sort(res, function(a, b)
		if a.order ~= b.order then
			return a.order < b.order
		else
			local aId, bId = tonumber(a.id), tonumber(b.id)

			if aId ~= bId then
				return aId < bId
			else
				return false
			end
		end
	end)

	return res
end

function EventModel:getTrackInfo(eventId, eventType)
	local res

	if eventType == ActivityConst.EventType.PuppetCatch then
		local petList = pg.me.luckyPetIdList

		for index, id in ipairs(petList or EMPTY_TABLE) do
			local templateId = id
			local markStaticId = PetResearchTrackData[templateId].petPoint
			local hasTrack = pg.game.map:checkTrackMarkExists(markStaticId)

			if hasTrack then
				res = {
					markStaticId = markStaticId,
					hasTrack = hasTrack,
					targetTemplateId = templateId
				}

				break
			end
		end
	elseif eventType == ActivityConst.EventType.CatchRogue then
		local phase = GameEventData[eventId].phase
		local markStaticId = EventCatchRogueData[phase].markStaticId
		local hasTrack = pg.game.map:checkTrackMarkExists(markStaticId)

		res = {
			markStaticId = markStaticId,
			hasTrack = hasTrack
		}
	elseif eventType == ActivityConst.EventType.EcologyTrace then
		local curCfg = self:getCurEcoTraceSearchCfg()

		if curCfg then
			local hasTrack = pg.game.map:checkTrackMarkExists(curCfg.loacte)

			res = {
				markStaticId = curCfg.loacte,
				hasTrack = hasTrack
			}
		end
	end

	return res
end

function EventModel:getNextDayTimeStamp()
	local now = Time.secondCache
	local nextDay = now + Const.SECONDS_ONE_DAY

	return TimeUtils.getServerDayBegin(nextDay)
end

function EventModel:getTeaPartyDailyItemCfg(index)
	local cfg = SysConfigData.SOCIAL_PARTY_DAILY_MAX_ITEM_NUM or SysConfigData.SOCIAL_PARTY_DAILY_MAX_ITEM_NUM

	return Utils.isTable(cfg) and cfg[index] or nil
end

function EventModel:getTeaPartyGuideEndTime(dailyStartTime)
	local partyTimeCfgList = SocialPartyData[dailyStartTime] or SocialPartyData[tonumber(dailyStartTime)]

	if not Utils.isTable(partyTimeCfgList) then
		return nil
	end

	local dayBegin = TimeUtils.getAreaDayBegin(Time.secondCache)
	local targetEndTime

	for _, partyTimeCfg in pairs(partyTimeCfgList) do
		local endSeconds = partyTimeCfg and Utils.getConfigTimeOfArea(partyTimeCfg, "endTime")

		if endSeconds then
			local endTime = dayBegin + endSeconds

			if partyTimeCfg.isTomorrow or partyTimeCfg.istomorrow then
				endTime = endTime + Const.SECONDS_ONE_DAY
			end

			if not targetEndTime or targetEndTime < endTime then
				targetEndTime = endTime
			end
		end
	end

	return targetEndTime
end

function EventModel:getEventLockInfo(eventId)
	local gameEventData = GameEventData[eventId]
	local condId = gameEventData.conditions
	local customTriggerData = CustomTriggerData[condId]
	local conditionDatas = CustomTriggerData[condId] and CustomTriggerData[condId].condition

	if not conditionDatas then
		return
	end

	local finalTxt, finalTxtKey

	if customTriggerData and customTriggerData.note then
		finalTxt = pg.getLocalizationText(customTriggerData.note)
	else
		local targetLevel, targetTitle

		for index, conditionData in ipairs(conditionDatas) do
			local triggerType = TriggerUtils.getTriggerType(conditionData)

			if finalTxt then
				finalTxtKey = "LIMIT_TITLE_LEVEL"

				if triggerType == TriggerConst.TRIGGER_TARGET_PLAYER_LEVEL then
					targetLevel = pg.me.triggerMap:getConditionTargetCount(condId, index)
				elseif triggerType == TriggerConst.TRIGGER_TARGET_PLAYER_TITLE then
					targetTitle = pg.me.triggerMap:getConditionTargetCount(condId, index)
				end

				finalTxt = string.format(pg.getGameString(finalTxtKey), targetLevel, targetTitle)
			elseif triggerType == TriggerConst.TRIGGER_TARGET_PLAYER_LEVEL then
				finalTxtKey = "LIMIT_LEVEL"
				targetLevel = pg.me.triggerMap:getConditionTargetCount(condId, index)
				finalTxt = string.format(pg.getGameString(finalTxtKey), targetLevel)
			elseif triggerType == TriggerConst.TRIGGER_TARGET_PLAYER_TITLE then
				finalTxtKey = "LIMIT_TITLE"
				targetTitle = pg.me.triggerMap:getConditionTargetCount(condId, index)
				finalTxt = string.format(pg.getGameString(finalTxtKey), targetTitle)
			end
		end
	end

	return finalTxt
end

EventModel.WeekWishPageState = {
	EggGet = 3,
	EggAppear = 2,
	Prayers = 1,
	Begin = 0
}

function EventModel:getWeekWishInfo(curPhase)
	local res = {}

	if not pg.me then
		return
	end

	local activityInfo = pg.me:queryActivityVotePetInfo()

	for activityId, info in pairs(activityInfo or EMPTY_TABLE) do
		if curPhase == activityId then
			local now, voteStartDayTime, voteEndDayTime, eventStartDayTime, eventEndDayTime = unpack(info)

			table.merge(res, info or {})

			if voteStartDayTime <= now and now < voteEndDayTime then
				do
					local votePet = pg.me.activityVotePet[curPhase]

					res[#res + 1] = votePet ~= nil and EventModel.WeekWishPageState.Prayers or EventModel.WeekWishPageState.Begin
				end

				break
			end

			if eventStartDayTime <= now and now < eventEndDayTime then
				local getEggTimeStamp = pg.me.activityVotePetSucc and pg.me.activityVotePetSucc[curPhase] or nil

				res[#res + 1] = getEggTimeStamp and EventModel.WeekWishPageState.EggGet or EventModel.WeekWishPageState.EggAppear
			end

			break
		end
	end

	return res
end

function EventModel:getWeekWishPetList(curPhase)
	local data = ActivityPetVoteData[curPhase]

	if not data or not data.votePetList then
		return
	end

	local petList = {}

	for index, templateId in pairs(data.votePetList or EMPTY_TABLE) do
		local petData = PetData[templateId]
		local temp = {}

		temp.templateId = templateId
		temp.name = petData.name
		temp.petType = petData.functionId
		temp.petFunctionIcon = string.gsub(PetConfigData.petFunctionIcon[petData.functionId] or "", ".png", "2.png")
		temp.petFunctionText = pg.getLocalizationText(PetConfigData[string.format("petFunctionText%s", petData.functionId)])

		local genderPosFix = ""

		temp.iconName = string.format(AddressDataConst.PET_WEEK_WISH_IMG, petData.iconName, genderPosFix)
		temp.formName = LuaUIUtils.getPetFormName(templateId)

		table.insert(petList, temp)
	end

	return petList
end

function EventModel:getWeekWishPetVoteInfo(curPhase, templateId)
	local voteInfo = self._weekWishVoteInfo and self._weekWishVoteInfo[curPhase] or nil

	if not voteInfo then
		return
	end

	local cnt = voteInfo.votePets[tostring(templateId)]
	local sum = voteInfo.sum

	return cnt, sum
end

function EventModel:setWeekWishVoteInfo(voteInfo)
	self._weekWishVoteInfo = self._weekWishVoteInfo or {}

	local activityId = voteInfo.activityId and tonumber(voteInfo.activityId)

	if not activityId then
		return
	end

	self._weekWishVoteInfo[activityId] = {}
	self._weekWishVoteInfo[activityId].votePets = voteInfo.votePets

	local sum = 0
	local petList = ActivityPetVoteData[activityId] and ActivityPetVoteData[activityId].votePetList

	for templateId, cnt in pairs(voteInfo.votePets) do
		if petList and table.contains(petList, tonumber(templateId)) then
			sum = sum + cnt
		end
	end

	self._weekWishVoteInfo[activityId].sum = sum
end

function EventModel:isWeekWishEggRewardCanGet(curPhase)
	if not curPhase then
		return
	end

	local votePet = pg.me.activityVotePet[curPhase]
	local getEggTimeStamp = pg.me.activityVotePetSucc and pg.me.activityVotePetSucc[curPhase] or nil

	return votePet and not getEggTimeStamp
end

EventModel.PuppetCatchState = {
	Finish = 3,
	Reward = 2,
	Track = 1,
	Normal = 0
}

function EventModel:getCurPuppetCatchActivityId()
	return pg.me.luckyPetCurPhase or 0
end

function EventModel:getPuppetCatchList(eventId)
	local res = {}
	local dayIndex = ActivityUtils.getLuckyPetOpenDay()
	local petListData = pg.me.luckyPetIdList

	if not petListData or Utils.isEmptyTable(petListData) then
		logger:error("EventModel:getPuppetCatchList petListData is empty !")

		return res
	end

	if petListData then
		for index, templateId in ipairs(petListData or EMPTY_TABLE) do
			local temp = {}
			local pData = PetData[templateId]
			local trackData = PetResearchTrackData[templateId]

			temp.templateId = templateId
			temp.state = self:getPuppetCatchState(index, templateId, eventId)
			temp.score = trackData and trackData.petScore or 0
			temp.iconName = pData.iconName
			temp.name = pData.name
			temp.index = index
			temp.sourceId = trackData.sourceId

			table.insert(res, temp)
		end
	end

	return res
end

function EventModel:getPuppetCatchState(index, templateId, eventId)
	local curActivityId = self:getCurPuppetCatchActivityId()
	local petFinish = pg.me.luckyPetIdSubmit
	local hasFinish = petFinish[index] == true

	if hasFinish then
		return EventModel.PuppetCatchState.Finish
	else
		local petCatch = pg.me.luckyPetIdFinish
		local hasCatch = petCatch[index] == true

		if hasCatch then
			return EventModel.PuppetCatchState.Reward
		end

		local trackInfo = self:getTrackInfo(eventId, ActivityConst.EventType.PuppetCatch)

		if trackInfo and trackInfo.hasTrack and trackInfo.targetTemplateId == templateId then
			return EventModel.PuppetCatchState.Track
		else
			return EventModel.PuppetCatchState.Normal
		end
	end
end

function EventModel:getPuppetCatchRewardDataList()
	local curActivityId = self:getCurPuppetCatchActivityId()
	local activityData = ActivityUtils.getLuckyPetConfig(curActivityId)

	if not activityData then
		return
	end

	local idx = 1
	local res = {}
	local canGetRewardList = ActivityUtils.getLuckyPetCanRewardList(pg.me)
	local curScore = ActivityUtils.getLuckyPetScore(pg.me)
	local rewardDatas = activityData.scoreRewards or {}

	while rewardDatas[idx] ~= nil do
		local temp = self:_getPuppetCatchRewardItemData(idx, curActivityId)
		local lastScore = idx > 1 and rewardDatas[idx - 1][1] or 0

		temp.progress = (curScore - lastScore) / (temp.targetNum - lastScore)

		local state

		if pg.me.luckyPetDayRewarded[idx] then
			state = ClientConst.RewardState.Claimed
		elseif canGetRewardList[idx] == true and pg.me.luckyPetDayRewarded[idx] ~= true then
			state = ClientConst.RewardState.ReadyToClaim
		elseif canGetRewardList[idx] == false then
			state = ClientConst.RewardState.NotAchieved
		end

		temp.state = state

		table.insert(res, temp)

		idx = idx + 1
	end

	return res
end

function EventModel:_getPuppetCatchRewardItemData(index, activityId)
	local activityData = ActivityUtils.getLuckyPetConfig(activityId)

	if not activityData then
		return
	end

	local rewardDatas = activityData.scoreRewards or {}
	local temp = {}

	temp.targetNum = rewardDatas[index][1] or 0
	temp.index = index
	temp.dropId = rewardDatas[index][2]

	return temp
end

function EventModel:getVitalityContestRewardData(phase, themeId, score)
	local themeData = EnergyMatchThemeData[phase][themeId]

	if not themeData then
		return
	end

	local res = {}
	local rewardDatas = themeData.award or {}
	local lastScore = 0

	for index, rewardData in ipairs(rewardDatas) do
		local temp = {}

		temp.targetNum = rewardData[1]
		temp.index = index
		temp.dropId = rewardData[2]

		local process = 0

		if lastScore < score then
			if score < rewardData[1] then
				process = (score - lastScore) / (rewardData[1] - lastScore)
			else
				process = 1
			end
		end

		temp.progress = process

		local state = ClientConst.RewardState.NotAchieved
		local rewardIndex = pg.me.energyMatchAwardFlag[themeId]

		if rewardIndex then
			if index <= rewardIndex then
				state = ClientConst.RewardState.Claimed
			elseif process == 1 then
				state = ClientConst.RewardState.ReadyToClaim
			end
		elseif process == 1 then
			state = ClientConst.RewardState.ReadyToClaim
		end

		temp.state = state
		lastScore = rewardData[1]

		table.insert(res, temp)
	end

	return res
end

function EventModel:setPetProId(petId)
	local pInfo = pg.me:getPetInfo(petId)

	if not pInfo then
		return nil
	end

	self.adjustPetCurId = petId
	self.adjustPetProId = pInfo.petPrototypeId

	local res = {
		scale = 1,
		offset = {}
	}
	local cData = PetAccessoryTransformData[pInfo.templateId]

	if cData and cData.modelPos and #cData.modelPos >= 3 then
		res.offset = Vector3.New(cData.modelPos[1], cData.modelPos[2], cData.modelPos[3])
		res.scale = cData.scale or 1
	else
		res.offset = Vector3.constZero
	end

	return res
end

function EventModel:parseDefaultAccessInfo(curTemplateId, accessoryId, sliderInfo)
	local refId = PetData[curTemplateId].refId or curTemplateId
	local resTb

	if curTemplateId and accessoryId then
		local t = pgUtils.GetAccessoryConfigFromLocal(curTemplateId, accessoryId)

		t = t or pgUtils.GetAccessoryConfigFromLocal(refId, accessoryId)

		if t then
			resTb = t
		end
	end

	resTb = resTb or {
		accessoryId = accessoryId,
		resId = AppearanceJewelryPetData[accessoryId].res,
		localPosition = sliderInfo.defaultPos,
		localRotation = Vector3.zero,
		scale = sliderInfo.defaultAccessScale
	}

	return resTb
end

function EventModel:clearCacheData()
	self.adjustPetProId = nil
	self.adjustPetCurId = nil
end

function EventModel:getCarnTabData(phaseId)
	local tabs = {}
	local eventArkCarnData = EventArkCarnData[phaseId]

	for stageId, carnInfo in ipairs(eventArkCarnData) do
		local tab = {}

		tab.stageId = stageId
		tab.startTime = Utils.getConfigTimeOfArea(carnInfo, "startTime")
		tab.endTime = Utils.getConfigTimeOfArea(carnInfo, "endTime")
		tab.showStartTime = Utils.getConfigTimeOfAreaByData(carnInfo.showStartTime)
		tab.showEndTime = Utils.getConfigTimeOfAreaByData(carnInfo.showEndTime)
		tab.title = carnInfo.tabName
		tab.isOpen = Time.getSecond() > tab.showStartTime
		tab.isFinish = Time.getSecond() > tab.endTime
		tab.taskOpen = Time.getSecond() > tab.startTime

		table.insert(tabs, tab)
	end

	return tabs
end

function EventModel:hasCanRecvTask(activityId, groupId)
	local tasks = self:getCarnTaskData(activityId, groupId, true)

	for _, task in ipairs(tasks) do
		if task.state == ActivityConst.TaskState.Finihed_CanRecv then
			return true
		end
	end

	return false
end

function EventModel:getCarnTaskData(activityId, groupId, taskOpen)
	local tasks = {}

	for id, taskInfo in pairs(EventTaskData) do
		if taskInfo.activityId == activityId and taskInfo.groupId == groupId and taskInfo.internationalJuge then
			if Utils.isOverseas() then
				if taskInfo.internationalJuge == 2 then
					local task = {}

					task.id = id
					task.index = #tasks
					task.name = taskInfo.taskDes

					local state = ActivityConst.TaskState.UnFinished

					if pg.me.arkCarnTasks[id] then
						state = pg.me.arkCarnTasks[id].state
					end

					task.conditionId = taskInfo.taskCondition
					task.state = state

					if not taskOpen then
						task.state = 4
					end

					task.dropId = taskInfo.award
					task.isQRTask = taskInfo.qrcodeDesc
					task.linkAddress = taskInfo.linkAddress
					task.taskTrackId = taskInfo.taskTrackId

					table.insert(tasks, task)
				end
			elseif taskInfo.internationalJuge == 1 then
				local task = {}

				task.id = id
				task.index = #tasks
				task.name = taskInfo.taskDes

				local state = ActivityConst.TaskState.UnFinished

				if pg.me.arkCarnTasks[id] then
					state = pg.me.arkCarnTasks[id].state
				end

				task.conditionId = taskInfo.taskCondition
				task.state = state

				if not taskOpen then
					task.state = 4
				end

				task.dropId = taskInfo.award
				task.isQRTask = taskInfo.qrcodeDesc
				task.linkAddress = taskInfo.linkAddress
				task.isOpen = taskOpen
				task.taskTrackId = taskInfo.taskTrackId

				table.insert(tasks, task)
			end
		end
	end

	return tasks
end

function EventModel:getCarnPhotoData(phaseId)
	local eventArkCarnData = EventArkCarnData[phaseId][1]
	local id1, num1 = pg.game.event:getArkPartyVoteInfo(eventArkCarnData.voteDrummerKey)
	local id2, num2 = pg.game.event:getArkPartyVoteInfo(eventArkCarnData.voteDancerKey)
	local id3, num3 = pg.game.event:getArkPartyVoteInfo(eventArkCarnData.voteAccompanyKey)
	local id4, num4 = pg.game.event:getArkPartyVoteInfo(eventArkCarnData.voteAtmosKey)

	if not id1 then
		id1 = eventArkCarnData.votePetListeDrummer[1]
		num1 = 0
	end

	if not id2 then
		id2 = eventArkCarnData.votePetListDancer[1]
		num2 = 0
	end

	if not id3 then
		id3 = eventArkCarnData.votePetListAccompany[1]
		num3 = 0
	end

	if not id4 then
		id4 = eventArkCarnData.votePetListAtmos[1]
		num4 = 0
	end

	if id1 and id2 and id3 and id4 then
		local photoDatas = {}
		local data1 = self:getArkPartyVoteData(eventArkCarnData, id1, 1)
		local data2 = self:getArkPartyVoteData(eventArkCarnData, id2, 2)
		local data3 = self:getArkPartyVoteData(eventArkCarnData, id3, 3)
		local data4 = self:getArkPartyVoteData(eventArkCarnData, id4, 4)

		table.insert(photoDatas, data1)
		table.insert(photoDatas, data2)
		table.insert(photoDatas, data3)
		table.insert(photoDatas, data4)

		local mainDanceData = {}

		mainDanceData.petId = eventArkCarnData.petMainDancerId
		mainDanceData.index = 5

		local puppetData = PuppetData[mainDanceData.petId]

		if puppetData then
			local petPrototypeId = puppetData.petPrototypeId

			if table.contains(pg.me.arkCarnPhotoTakedPets, petPrototypeId) then
				mainDanceData.isFinish = true
			end
		end

		table.insert(photoDatas, mainDanceData)

		return photoDatas
	end

	return {}
end

function EventModel:getArkPartyVoteData(eventArkCarnData, petId, index)
	local data = {}

	data.petId = petId
	data.index = index

	local puppetData = PuppetData[petId]

	if puppetData then
		local petPrototypeId = puppetData.petPrototypeId

		if table.contains(pg.me.arkCarnPhotoTakedPets, petPrototypeId) then
			data.isFinish = true
		end
	end

	return data
end

function EventModel:setArkPartyVoteInfo(voteInfo)
	if not voteInfo then
		return
	end

	self.arkPartyVoteInfo = self.arkPartyVoteInfo or {}

	local activityId = voteInfo.activityId and tonumber(voteInfo.activityId)

	if not activityId then
		return
	end

	self.arkPartyVoteInfo[activityId] = {}

	local votePets = {}

	for id, num in pairs(voteInfo.votePets) do
		votePets[tonumber(id)] = num
	end

	self.arkPartyVoteInfo[activityId].votePets = votePets
end

function EventModel:getArkPartyVoteInfo(voteKey)
	if not self.arkPartyVoteInfo then
		return nil
	end

	local voteInfo = self.arkPartyVoteInfo[voteKey]

	if not voteInfo then
		return nil
	end

	local petId = 0
	local voteNum = 0

	for id, num in pairs(voteInfo.votePets) do
		if petId == 0 then
			petId = id
		end

		if voteNum == 0 then
			voteNum = num
		end

		if voteNum < num then
			petId = id
			voteNum = num
		end
	end

	return petId, voteNum
end

EventModel.PuppetPhotoState = {
	Finish = 2,
	Reward = 1,
	Normal = 0
}

function EventModel:getPhotoPuppet(eventId)
	local activityData = ActivityUtils.getFormResearchConfig()
	local templateId = activityData.pet1

	if templateId then
		local temp = {}
		local pData = PetData[templateId]

		temp.templateId = templateId
		temp.state = self:getPhotoPuppetState(templateId, eventId)
		temp.iconName = pData.iconName
		temp.shadowIconName = string.format(AddressDataConst.PET_DAILY_SURVEY_SHADOW_IMG, pData.iconName)

		local localGender = pg.global.prefsCacheUtils:getInt(ClientConst.PrefKey.EventFormResearchGender .. eventId, 0)
		local genderPosFix = ""

		genderPosFix = localGender == Const.GENDER_TYPE_MALE and "_Male" or localGender == Const.GENDER_TYPE_FEMALE and "_Female" or ""

		local finishIconResDir = string.format(AddressDataConst.PET_WEEK_WISH_IMG, pData.iconName, genderPosFix)

		if not pg.global.resMgr:CheckAssetExist(finishIconResDir) then
			finishIconResDir = string.format(AddressDataConst.PET_WEEK_WISH_IMG, pData.iconName, "")
		end

		temp.finishIconName = finishIconResDir
		temp.name = pData.name
		temp.rewardId = activityData.phaseReward

		return temp
	end

	return nil
end

function EventModel:getPuppetPhoto(eventId, force)
	local path = pg.global.prefsCacheUtils:getString(ClientConst.PrefKey.EventFormResearch .. eventId, "")

	if force or not self._photoIndex2Sprite then
		self._photoIndex2Sprite = pg.global.mobileCameraMgr:GetSpriteByFilePath(path)
	end

	return self._photoIndex2Sprite
end

function EventModel:destroyAllPhotoSprite()
	if self._photoIndex2Sprite then
		for idx, sprite in pairs(self._photoIndex2Sprite) do
			pg.global.mobileCameraMgr:DestroySpriteTexture(sprite)
		end
	end

	self._photoIndex2Sprite = nil
end

function EventModel:getPhotoPuppetState(templateId, eventId)
	local formFinish = pg.me.formResearchFinish or {}
	local formReward = pg.me.formResearchRewarded or {}

	if formReward == true then
		return EventModel.PuppetPhotoState.Finish
	elseif formReward ~= true and formFinish == true then
		return EventModel.PuppetPhotoState.Reward
	else
		return EventModel.PuppetPhotoState.Normal
	end
end

function EventModel:getPuppetPhotoClueUnlock(clueIndex)
	if not clueIndex then
		return false
	end

	return pg.me.formResearchClueMap and pg.me.formResearchClueMap[clueIndex] or false
end

function EventModel:getCurPuppetPhotoActivityId()
	return pg.me.formResearchCurPhase
end

function EventModel:getPuppetPhotoRewardDataList()
	local curActivityId = self:getCurPuppetPhotoActivityId()
	local activityData = ActivityUtils.getFormResearchConfig(curActivityId)

	if not activityData then
		return {}
	end

	local idx = 1
	local res = {}
	local canGetRewardList = ActivityUtils.getFormResearchCanRewardList(pg.me)
	local curScore = ActivityUtils.getFormResearchScore(pg.me)
	local rewardDatas = activityData.stageRewards or {}

	while rewardDatas[idx] ~= nil do
		local temp = self:_getPuppetPhotoRewardItemData(idx, curActivityId)
		local lastScore = idx > 1 and rewardDatas[idx - 1][1] or 0

		temp.progress = (curScore - lastScore) / (temp.targetNum - lastScore)

		local state

		if pg.me.formResearchStageRewarded[idx] then
			state = ClientConst.RewardState.Claimed
		elseif canGetRewardList[idx] == true and pg.me.formResearchStageRewarded[idx] ~= true then
			state = ClientConst.RewardState.ReadyToClaim
		elseif canGetRewardList[idx] == false then
			state = ClientConst.RewardState.NotAchieved
		end

		temp.state = state

		table.insert(res, temp)

		idx = idx + 1
	end

	return res
end

function EventModel:_getPuppetPhotoRewardItemData(index, activityId)
	local activityData = ActivityUtils.getFormResearchConfig(activityId)

	if not activityData then
		return
	end

	local rewardDatas = activityData.stageRewards or {}
	local temp = {}

	temp.targetNum = rewardDatas[index][1] or 0
	temp.index = index
	temp.dropId = rewardDatas[index][2]

	return temp
end

function EventModel:getPuppetPhotoDailyRewardDataList()
	local curActivityId = self:getCurPuppetPhotoActivityId()
	local activityData = ActivityUtils.getFormResearchConfig(curActivityId)

	if not activityData then
		return
	end

	local dropId = activityData.phaseReward
	local hasGet = pg.me.formResearchRewarded == true
	local canGet = pg.me.formResearchFinish == true
	local rewards = LuaUIUtils.getRewardItemByDropId(dropId, hasGet, canGet)

	return rewards
end

function EventModel:getPuppetPhotoDailyExtraRewardDataList()
	local curActivityId = self:getCurPuppetPhotoActivityId()
	local activityData = ActivityUtils.getFormResearchConfig(curActivityId)

	if not activityData then
		return
	end

	local dropId = activityData.extraReward
	local hasGet = pg.me.formResearchObRewardRew == true
	local canGet = pg.me.formResearchObRewardFin == true
	local rewards = LuaUIUtils.getRewardItemByDropId(dropId, hasGet, canGet)

	return rewards
end

EventModel.OFFICIAL_GROUP_SHOW_TYPE = {
	URL = 1,
	QR_CODE = 2
}

function EventModel:getOfficialGroupInfo()
	local languageType = pg.languageType or 0
	local areaType = LuaUIUtils.isOverseas() and 2 or 1
	local res = {}

	for channelId, info in pairs(EventOfficialGroupData) do
		local isLanguageMatched = false

		if info.languageShow then
			for _, allowedLang in ipairs(info.languageShow) do
				if allowedLang == languageType then
					isLanguageMatched = true

					break
				end
			end
		end

		local isAreaMatched = info.isOverseas == nil or info.isOverseas == areaType
		local shouldShow = isAreaMatched and isLanguageMatched

		if shouldShow then
			local temp = {}

			temp.id = channelId
			temp.sortIdx = info.sort
			temp.iconName = info.societyIcon
			temp.name = info.societyName
			temp.showType = info.follewType
			temp.qrCodePath = info.qrcodeIcon
			temp.url = info.linkAdress
			temp.dropId = info.societyReward

			if pg.me and pg.me.communityGuideRewarded then
				temp.hasGet = pg.me.communityGuideRewarded[channelId]
			else
				temp.hasGet = true
			end

			res[#res + 1] = temp
		end
	end

	table.sort(res, function(a, b)
		return a.sortIdx < b.sortIdx
	end)

	return res
end

function EventModel:getChannelBindInfoList()
	local languageType = pg.game.setting:getLanguageType()
	local areaType = LuaUIUtils.isOverseas() and 2 or 1
	local res = {}

	for channelId, info in pairs(EventSocialBindData) do
		local isLanguageMatched = false

		if info.languageShow then
			for _, allowedLang in ipairs(info.languageShow) do
				if allowedLang == languageType then
					isLanguageMatched = true

					break
				end
			end
		end

		local shouldShow = info.isOverseas == areaType and isLanguageMatched

		if shouldShow then
			local isDomestic = areaType == 1
			local isSdkSupported = false

			if not isDomestic and pg and pg.global and pg.global.sdkManager then
				isSdkSupported = pg.global.sdkManager:isSocialTypeSupported(info.typeName)
			end

			if not isDomestic and not isSdkSupported then
				shouldShow = false
			end

			if shouldShow then
				local temp = {}

				temp.societyID = channelId
				temp.typeName = info.typeName
				temp.iconName = info.societyIcon
				temp.tipsDes = info.societyDesc
				temp.bindAward = info.bindAward
				temp.sort = info.sort or channelId
				temp.areaType = areaType
				temp.languageType = languageType

				local isBound = false

				if info.typeName == "WeCom" then
					-- block empty
				elseif pg and pg.global and pg.global.sdkManager then
					local bindStatus, _ = pg.global.sdkManager:getSocialBindInfo(info.typeName)

					isBound = bindStatus or false
				end

				temp.isBound = isBound
				res[#res + 1] = temp
			end
		end
	end

	table.sort(res, function(a, b)
		return a.sort < b.sort
	end)

	return res
end

function EventModel:checkPetSaveCurWeekCfg()
	local curWeek = ClientActivityUtils.checkPetSaveCurWeek()

	return PetSaveManualSubactData[curWeek] or nil
end

function EventModel:getEcoTracePet()
	local petId = ClientActivityUtils.getEcoTracePetId()

	if not petId then
		return
	end

	local petData = PetData[petId]
	local temp = {}

	temp.templateId = petId
	temp.name = petData.name
	temp.iconName = LuaUIUtils.getPetIcon(petData.iconName, LuaUIUtils.PET_FIRST_SHOW)
	temp.headName = LuaUIUtils.getPetIcon(petData.iconName, LuaUIUtils.PET_ICON)
	temp.formName = LuaUIUtils.getPetFormName(petId)

	return temp
end

function EventModel:getCurEcoTraceSearchCfg()
	local tracePetId = ClientActivityUtils.getEcoTracePetId()

	if not tracePetId then
		return nil
	end

	return EcoTraceSearchData[tracePetId]
end

function EventModel:getCurEcoTraceSearched()
	local activityData = ClientActivityUtils.getEcoTraceActivityData()

	return activityData and activityData.ecoTraceSearchCnt == 0 or false
end

EventModel.AREA_TASK_STATE = {
	FINISH = 1,
	OPEN = 0
}

function EventModel:getSubTaskState(eventId, subTaskIndex)
	if not eventId or not subTaskIndex then
		return
	end

	local eventPhase = GameEventData[eventId].phase
	local areaData = EventAreaActivityData[eventPhase]
	local taskGroupId = areaData.petResearchTaskGroupId[subTaskIndex]
	local finishCnt, totalCnt = ActivityUtils.getActTaskNumByGroupId(nil, taskGroupId)

	if finishCnt == totalCnt then
		return EventModel.AREA_TASK_STATE.FINISH
	end

	return EventModel.AREA_TASK_STATE.OPEN
end

function EventModel:setSubTaskPrefCache(eventId, subTaskIndex, isFinish)
	if not eventId or not subTaskIndex then
		return
	end

	local prefix = isFinish and ClientConst.PrefKey.EventAreaActivityFinish or ClientConst.PrefKey.EventAreaActivityAppear

	pg.global.prefsCacheUtils:setInt(prefix .. eventId .. subTaskIndex .. pg.me.uid, 1)
end

function EventModel:getRewardShowPetId(eventId, eventPhase)
	local data = EventAreaActivityData[eventPhase]

	return data and data.petShow
end

function EventModel:getAreaActivityBigTaskId(eventId, eventPhase)
	local data = EventAreaActivityData[eventPhase]

	return data and data.grandPrize
end

EventModel.REUNION_TRAINING_TASK_TYPE = ClientActivityUtils.REUNION_TRAINING_TASK_TYPE

function EventModel:getSignData(eventId)
	local eventData = GameEventData[eventId]

	if not eventData then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("eventData nil id: ", eventId)
		end

		return nil
	end

	if eventData.eventType == ActivityConst.EventType.SignNewbie then
		return pg.me.activitySignNewbie
	elseif eventData.eventType == ActivityConst.EventType.SignVersion then
		return pg.me.activitySignVersion
	elseif eventData.eventType == ActivityConst.EventType.LongTermSign then
		return pg.me.activityLongTermSign
	else
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("eventData eventType error id: ", eventId)
		end

		return nil
	end
end

function EventModel:getSignEndTime(eventId)
	local eventData = GameEventData[eventId]

	if not eventData then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("eventData nil id: ", eventId)
		end

		return nil
	end

	local signCfg = self:getSignCfg(eventId)

	if not signCfg then
		return nil
	end

	if eventData.eventType == ActivityConst.EventType.SignNewbie then
		local activitySignNewbie = pg.me.activitySignNewbie
		local durationTime = signCfg.duration * 86400
		local lastEndTime = activitySignNewbie.activityBegTime + durationTime

		return lastEndTime
	elseif eventData.eventType == ActivityConst.EventType.SignVersion or eventData.eventType == ActivityConst.EventType.LongTermSign then
		local eventTimeCfg = Utils.getEventTimeConfig(eventId)

		return eventTimeCfg.tabEndDayTime
	else
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("eventData eventType error id: ", eventId)
		end

		return nil
	end
end

function EventModel:getSignCfg(eventId)
	local eventData = GameEventData[eventId]

	if not eventData then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("eventData nil id: ", eventId)
		end

		return nil
	end

	local signCfg

	if eventData.eventType == ActivityConst.EventType.SignNewbie then
		signCfg = EventSignNewbie[eventData.phase]
	elseif eventData.eventType == ActivityConst.EventType.SignVersion or eventData.eventType == ActivityConst.EventType.LongTermSign then
		signCfg = EventSignVersion[eventData.phase]
	else
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("eventData eventType error id: ", eventId)
		end

		return nil
	end

	if not signCfg then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("signCfg nil id: ", eventId)
		end

		return nil
	end

	return signCfg
end

function EventModel:getSignList(eventId)
	local signCfgList = {}
	local taskGroupIds = ClientActivityUtils.getSignTaskGroupIds(eventId)

	for _, taskGroupId in ipairs(taskGroupIds) do
		local taskInfoList = ClientActivityUtils.getTaskInfoList(taskGroupId, true)

		for _, taskInfo in ipairs(taskInfoList) do
			signCfgList[#signCfgList + 1] = taskInfo
		end
	end

	return signCfgList
end

function EventModel:getTaskInfo(signType, taskState, curDay, index)
	local isSevenDay = signType == ActivityConst.SignDayType.SevenDay
	local btnState, getTex

	if taskState >= ActivityConst.TaskState.Received then
		getTex = pg.getGameString("SIGNIN_AWARD_TIP_1")
		btnState = isSevenDay and 4 or 1
	elseif taskState == ActivityConst.TaskState.Finihed_CanRecv then
		getTex = pg.getGameString("SIGNIN_AWARD_TIP_3")
		btnState = isSevenDay and 1 or 2
	elseif isSevenDay then
		local isNextDay = curDay == index - 1

		getTex = pg.getGameString(isNextDay and "SIGNIN_AWARD_TIP_4" or "SIGNIN_AWARD_TIP_2")
		btnState = isNextDay and 3 or 0
	else
		getTex = pg.getGameString("SIGNIN_AWARD_TIP_2")
		btnState = 2
	end

	return btnState, getTex
end

function EventModel:getDisPatchTaskInfo(taskId)
	local allTaskData = ClientActivityUtils.getTaskInfoByActType(ActivityConst.EventType.PetDispatch)

	for k, data in ipairs(allTaskData) do
		if data.taskId == taskId then
			return data
		end
	end
end

function EventModel:getCurStageDisPatchData(groudId)
	local taskids = ActivityUtils.getActTaskIdsByGroupId(groudId)
	local minSortTaskData, maxCompleteTaskData

	for k, taskid in ipairs(taskids) do
		local taskData = self:getDisPatchTaskInfo(taskid)

		if taskData then
			if (taskData.taskState == ActivityConst.PetDispatchTaskSubState.UnFinished_Disptaching or taskData.taskState < ActivityConst.TaskState.Received) and (not minSortTaskData or taskData.sort < minSortTaskData.sort) then
				minSortTaskData = taskData
			end

			if taskData.taskState == ActivityConst.TaskState.Received and (not maxCompleteTaskData or taskData.sort > maxCompleteTaskData.sort) then
				maxCompleteTaskData = taskData
			end
		end
	end

	return minSortTaskData ~= nil and minSortTaskData or maxCompleteTaskData
end

function EventModel:getCurBlockTakIsComplete(groudId)
	local taskData = self:getCurStageDisPatchData(groudId)

	if taskData and taskData.sort >= 2 then
		return self:getDisPatchTaskIsComplete(taskData.taskState)
	end

	return false
end

function EventModel:getDisPatchGroudCompleteCnt(groudId)
	local cnt = 0
	local taskids = ActivityUtils.getActTaskIdsByGroupId(groudId)

	if not taskids then
		return 0, 0
	end

	for k, taskid in ipairs(taskids) do
		local taskData = self:getDisPatchTaskInfo(taskid)

		if self:getDisPatchTaskIsComplete(taskData.taskState) then
			cnt = cnt + 1
		end
	end

	return cnt, #taskids
end

function EventModel:getDisPatchTaskIsComplete(taskState)
	if not taskState then
		return false
	end

	return taskState ~= ActivityConst.PetDispatchTaskSubState.UnFinished_Disptaching and taskState >= ActivityConst.TaskState.Received
end

function EventModel:getDisPatchTaskIsCanRecv(taskState)
	if not taskState then
		return false
	end

	return taskState ~= ActivityConst.PetDispatchTaskSubState.UnFinished_Disptaching and taskState >= ActivityConst.TaskState.Finihed_CanRecv
end

function EventModel:getDisPatchStage()
	local allTaskData = ClientActivityUtils.getTaskInfoByActType(ActivityConst.EventType.PetDispatch)
	local complete = 0
	local allCnt = 0

	for k, taskData in ipairs(allTaskData) do
		if taskData.taskType == ActivityConst.ActivityTaskType.PetDispatch_Dispatch then
			allCnt = allCnt + 1

			if self:getDisPatchTaskIsCanRecv(taskData.taskState) then
				complete = complete + 1
			end
		end
	end

	return complete, allCnt
end

function EventModel:getDisPatchStageRewardTaskState()
	local allTaskData = ClientActivityUtils.getTaskInfoByActType(ActivityConst.EventType.PetDispatch)

	for k, taskData in ipairs(allTaskData) do
		if taskData.taskType == ActivityConst.ActivityTaskType.PetDispatch_StageScore then
			return taskData
		end
	end
end

function EventModel:redDotRecordSet(treePath, state)
	pg.me:setRedDotRecord(Const.CLIENT_KEY.EVENT_RED_DOT, treePath, state or false)
end

function EventModel:redDotRecordGet(treePath)
	local showRedDot = pg.me:getRedDotRecord(Const.CLIENT_KEY.EVENT_RED_DOT, treePath, true)

	return showRedDot
end

function EventModel:redDotDispatchRecordSet(eventId, state)
	local key = ClientActivityUtils.getDispatchRedDotNewKey(eventId)

	if key then
		pg.me:setRedDotRecord(Const.CLIENT_KEY.PET_DISPATCH_EVENT_TABLE, key, state or false)
	end
end

function EventModel:refreshCommonNodeRedDot(eventId)
	if eventId then
		local tabTreePath = string.format(RedDotConst.RedDotPath.EVENT_TAB_LIST_ITEM, eventId)

		pg.global.refreshRedDotState(tabTreePath)
	end

	pg.global.refreshRedDotState(RedDotConst.RedDotPath.EVENT_TAB1)
	pg.global.refreshRedDotState(RedDotConst.RedDotPath.EVENT_TAB2)
	pg.global.refreshRedDotState(RedDotConst.RedDotPath.FUNC_MENU_EVENT)
end

function EventModel:getEventCurrency(eventType)
	local currencyItems = {}

	if eventType == ActivityConst.EventType.EcologyTrace then
		local ecoCfg = ClientActivityUtils.getEcoTraceActivityCfg()

		if ecoCfg then
			table.insert(currencyItems, {
				id = ecoCfg.consumeItem[1][1]
			})
		end
	end

	return currencyItems
end

EventModel.SeasonHubFuncKey = {
	BattlePass = "battlePass",
	SchoolGuide = "schoolGuide",
	SpecialTrain = "specialTrain",
	JourneyTrial = "journeyTrial"
}
EventModel.SEASON_HUB_JOURNEY_TRIAL_EVENT_ID = 10000020
EventModel.SeasonHubFuncNameMap = {
	[EventModel.SeasonHubFuncKey.BattlePass] = "battlepass",
	[EventModel.SeasonHubFuncKey.SpecialTrain] = "SPECIALTRAIN",
	[EventModel.SeasonHubFuncKey.SchoolGuide] = "SCHOOLGUIDE"
}

function EventModel:_getSeasonHubFuncRedDotStyle(funcKey)
	if funcKey == EventModel.SeasonHubFuncKey.BattlePass then
		return CashShopRedDotUtils.getBattlePassHudRedDotStyle() or RedDotConst.RedDotStyle.NONE
	elseif funcKey == EventModel.SeasonHubFuncKey.SpecialTrain then
		return pg.global.ui.SpecialTrainNew.model:redDot_GetSpecialTrainState()
	elseif funcKey == EventModel.SeasonHubFuncKey.SchoolGuide then
		return LuaUIUtils.SchoolGuide_getBadgeCollectionRedDotStyle() or RedDotConst.RedDotStyle.NONE
	elseif funcKey == EventModel.SeasonHubFuncKey.JourneyTrial then
		return ClientActivityUtils._getJourneyTrialRedDotStyle(EventModel.SEASON_HUB_JOURNEY_TRIAL_EVENT_ID) or RedDotConst.RedDotStyle.NONE
	end

	return RedDotConst.RedDotStyle.NONE
end

function EventModel:getSeasonHubPageOrder()
	local cfg = SysConfigData.SEASON_PAGE_ORDER or SysConfigData.SEASON_PAGE_ORDER

	if cfg and Utils.isTable(cfg) and #cfg > 0 then
		return cfg
	end

	return {
		EventModel.SeasonHubFuncKey.BattlePass,
		EventModel.SeasonHubFuncKey.SpecialTrain,
		EventModel.SeasonHubFuncKey.SchoolGuide,
		EventModel.SeasonHubFuncKey.JourneyTrial
	}
end

function EventModel:getSeasonHubFuncInfo(funcKey)
	local res = {
		isOpen = false,
		redDotStyle = RedDotConst.RedDotStyle.NONE
	}

	if funcKey == EventModel.SeasonHubFuncKey.JourneyTrial then
		local eventId = EventModel.SEASON_HUB_JOURNEY_TRIAL_EVENT_ID
		local eventData = GameEventData[eventId]

		if not eventData then
			res.lockedDesc = ""

			return res
		end

		local tabOpen = ClientActivityUtils.isGameEventTabOpen(eventId)
		local unlock = ActivityUtils.getOprActivityUnlockCond(eventId) or eventData.alwaysShow == 1

		res.isOpen = tabOpen and unlock

		if not res.isOpen then
			res.lockedDesc = self:getEventLockInfo(eventId) or ""
		else
			res.redDotStyle = self:_getSeasonHubFuncRedDotStyle(funcKey)
		end

		return res
	end

	local funcName = EventModel.SeasonHubFuncNameMap[funcKey]

	if not funcName then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("getSeasonHubFuncInfo unknown funcKey=%s", tostring(funcKey))
		end

		return res
	end

	res.isOpen = pg.me and pg.me:checkFunctionUnlock(funcName) or false

	if not res.isOpen then
		local cfg = FuncIdConfigData[funcName]
		local descId = cfg and cfg.unlockDesc

		res.lockedDesc = descId and pg.getLocalizationText(descId) or ""
	else
		res.redDotStyle = self:_getSeasonHubFuncRedDotStyle(funcKey)
	end

	return res
end

function EventModel:getStarPlanGuideItemDataList(commonGuideId)
	local commonGuideData = EventCommonGuideData[commonGuideId]

	if not commonGuideData then
		return {}
	end

	local res = {}
	local index = 1

	while commonGuideData["btnName" .. index] ~= nil do
		local temp = {}

		temp.index = index
		temp.name = commonGuideData["btnName" .. index]
		temp.eventId = commonGuideData["event" .. index]
		temp.sourceId = commonGuideData["soureceId" .. index]
		temp.redDotStyle = self:getStarPlanGuideItemRedDotStyle(index)

		local btnData = commonGuideData["btnData" .. index]

		if btnData then
			temp.tagName = btnData.tagName
			temp.tagType = btnData.tagType
			temp.iconPic = btnData.iconPic
		end

		temp.tIndex = index <= 4 and 0 or 1
		res[#res + 1] = temp
		index = index + 1
	end

	return res
end

function EventModel:getStarPlanGuideItemRedDotStyle(index)
	return ClientActivityUtils._getStarPlanGuideItemRedDotStyle(index)
end

function EventModel:getIsFirstTopup()
	local conditionId = SysConfigData.ACT_FIRST_CHARGE_QUALIFY_COND_ID

	if not conditionId or conditionId <= 0 then
		return false
	end

	return ClientUtils.checkCondition(conditionId)
end

function EventModel:getFirstTopupRewardTask()
	local taskList = ClientActivityUtils.getTaskInfoByTaskType(ActivityConst.EventType.FirstTopup, ActivityConst.ActivityTaskType.Active_AchievementTask)

	table.sort(taskList, function(a, b)
		if a.sort ~= b.sort then
			return a.sort < b.sort
		else
			return a.taskId < b.taskId
		end
	end)

	return taskList
end

function EventModel:getCrossPlatformTaskList()
	local taskList = ClientActivityUtils.getTaskInfoByActType(ActivityConst.EventType.CrossPlatform)

	table.sort(taskList, function(a, b)
		if a.sort ~= b.sort then
			return a.sort < b.sort
		else
			return a.taskId < b.taskId
		end
	end)

	return taskList
end

function EventModel:getLittleFireProgress(eventId, isPersonal)
	return ClientActivityUtils.getLittleFireProgress(eventId, isPersonal)
end

function EventModel:getLittleFireRewardTask(eventId, isPersonal)
	local targetActType = isPersonal and ActivityConst.ActivityTaskType.LittleFire_PersonReward or ActivityConst.ActivityTaskType.LittleFire_GlobalReward
	local taskList = ClientActivityUtils.getTaskInfoByTaskType(ActivityConst.EventType.LittleFirePerson, targetActType)

	table.sort(taskList, function(a, b)
		if a.sort ~= b.sort then
			return a.sort < b.sort
		else
			return a.taskId < b.taskId
		end
	end)

	return taskList
end

EventModel.FishingCaptureStageContentFields = {
	[FishingCaptureConst.ActivityStage.FlowerGathering] = {
		rule = "trainRule",
		title = "trainTab",
		desc = "trainDesc"
	},
	[FishingCaptureConst.ActivityStage.IrisCompanion] = {
		rule = "trainRule2",
		title = "trainTab2",
		desc = "trainDesc2"
	},
	[FishingCaptureConst.ActivityStage.WindkissCompanion] = {
		rule = "trainRule3",
		title = "trainTab3",
		desc = "trainDesc3"
	}
}
EventModel.FishingCaptureExchangeState = {
	NotEnough = 2,
	Exchanged = 3,
	Normal = 1
}
EventModel.FishingCaptureEntranceState = {
	Available = 2,
	Locked = 1,
	Completed = 3
}

function EventModel:getFishingCaptureActivityConfig(eventPhase)
	return FishingCaptureActivityData[eventPhase]
end

function EventModel:getFishingCaptureStageContentConfig(eventPhase, stage)
	local activityData = self:getFishingCaptureActivityConfig(eventPhase)
	local fields = EventModel.FishingCaptureStageContentFields[stage]

	if not activityData or not fields then
		return nil
	end

	return {
		title = activityData[fields.title],
		desc = activityData[fields.desc],
		rule = activityData[fields.rule]
	}
end

function EventModel:resolveFishingCaptureStageTwoActions(irisCubeExchanged, irisRewardReceived, petalCount, exchangeCost)
	if irisRewardReceived == true then
		return EventModel.FishingCaptureExchangeState.Exchanged, EventModel.FishingCaptureEntranceState.Completed
	end

	if irisCubeExchanged == true then
		return EventModel.FishingCaptureExchangeState.Exchanged, EventModel.FishingCaptureEntranceState.Available
	end

	local normalizedPetalCount = math.max(tonumber(petalCount) or 0, 0)
	local normalizedExchangeCost = tonumber(exchangeCost) or 0

	if normalizedExchangeCost > 0 and normalizedExchangeCost <= normalizedPetalCount then
		return EventModel.FishingCaptureExchangeState.Normal, EventModel.FishingCaptureEntranceState.Locked
	end

	return EventModel.FishingCaptureExchangeState.NotEnough, EventModel.FishingCaptureEntranceState.Locked
end

function EventModel:getFishingCaptureSeasonCubeData(eventPhase)
	local activityData = self:getFishingCaptureActivityConfig(eventPhase)

	if not activityData then
		return
	end

	local cubeItemId = activityData.coinseasoncubeId
	local totalCount = math.max(tonumber(activityData.coinseasoncubenum) or 0, 0)
	local craftedCount = math.max(ClientActivityUtils.getFishingCaptureCubeExchangeCount(FishingCaptureConst.CubeType.SEASON), 0)
	local remainingCount = math.max(totalCount - craftedCount, 0)
	local petalItemId = activityData.petalItemId
	local petalCount = petalItemId and pg.me:getItemCountById(petalItemId) or 0
	local cost = math.max(tonumber(activityData.coinseasoncube) or 0, 0)
	local state = FishingCaptureConst.SeasonCubeState.Insufficient

	if remainingCount <= 0 then
		state = FishingCaptureConst.SeasonCubeState.Exhausted
	elseif cost > 0 and cost <= petalCount then
		state = FishingCaptureConst.SeasonCubeState.CanBuild
	end

	return {
		itemId = cubeItemId,
		petalCount = petalCount,
		cost = cost,
		craftedCount = craftedCount,
		remainingCount = remainingCount,
		totalCount = totalCount,
		state = state
	}
end

function EventModel:getFishingCaptureCurrencyItems(eventPhase)
	local activityData = self:getFishingCaptureActivityConfig(eventPhase)

	if not activityData or not activityData.petalItemId then
		return {}
	end

	return {
		{
			id = activityData.petalItemId
		}
	}
end

function EventModel:getFishingCaptureProgressTaskGroupId(eventId)
	local taskData = ActivateTasksData[eventId]
	local foreverTaskGroup = taskData and taskData.foreverTaskGroup

	return foreverTaskGroup and foreverTaskGroup[1]
end

function EventModel:buildFishingCaptureProgressTasks(eventId)
	local taskGroupId = self:getFishingCaptureProgressTaskGroupId(eventId)

	return ClientActivityUtils.getTaskInfoList(taskGroupId, true)
end

return EventModel
