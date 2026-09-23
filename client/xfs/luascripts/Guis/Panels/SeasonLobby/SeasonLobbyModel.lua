-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\SeasonLobby\\SeasonLobbyModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local ClientConst = require("Const.ClientConst")
local RedDotConst = require("Const.RedDotConst")
local ActivityConst = require("Common.Const.ActivityConst")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local Time = require("Core.Common.Time")
local Utils = require("Common.Utils.Utils")
local ClientActivityUtils = require("Utils.ClientActivityUtils")
local CashShopRedDotUtils = require("Utils.CashShopRedDotUtils")
local BattlePassData = require("Data.event_battlepass_data")
local ItemSourceData = require("Data.item_source_data")
local SeasonActivityData = require("Data.season_activity_data")
local GameEventTypeData = require("Data.game_event_type_data")
local SeasonLobbyModel = Class.LightClass("SeasonLobbyModel", UIModel)

function SeasonLobbyModel:getSeasonStageInfo()
	return Utils.getCurrentSeasonStage()
end

function SeasonLobbyModel:getSeasonId()
	local seasonStageInfo = self:getSeasonStageInfo()

	return seasonStageInfo and seasonStageInfo.seasonId
end

function SeasonLobbyModel:getSeasonCountDownEndTimes()
	local currentStageInfo = self:getSeasonStageInfo()

	if not currentStageInfo then
		return nil, nil
	end

	local stageInfo = Utils.getSeasonStageInfo(currentStageInfo.seasonId, currentStageInfo.stageId)
	local _, seasonEndTime = Utils.getSeasonTimeRange(currentStageInfo.seasonId)

	return seasonEndTime, stageInfo and stageInfo.endTime
end

function SeasonLobbyModel:getCurrentSeasonActivityField(fieldName)
	local seasonStageInfo = self:getSeasonStageInfo()
	local seasonActivityData = seasonStageInfo and SeasonActivityData[seasonStageInfo.seasonId]

	if not seasonActivityData then
		return nil
	end

	local seasonStageActivityData = seasonActivityData[seasonStageInfo.stageId]
	local fieldValue = seasonStageActivityData and seasonStageActivityData[fieldName]

	if fieldValue ~= nil and fieldValue ~= "" then
		return fieldValue
	end

	local firstStageActivityData = seasonActivityData[1]

	return firstStageActivityData and firstStageActivityData[fieldName]
end

function SeasonLobbyModel:getSeasonTitleTextId()
	return self:getCurrentSeasonActivityField("name")
end

function SeasonLobbyModel:getSeasonAudioConfig()
	local bgm = self:getCurrentSeasonActivityField("bgm")
	local enterSound = self:getCurrentSeasonActivityField("enterSound")

	if string.isNilOrEmpty(bgm) then
		bgm = nil
	end

	if string.isNilOrEmpty(enterSound) then
		enterSound = nil
	end

	return bgm, enterSound
end

function SeasonLobbyModel:_getCurrentSeasonActivityTime(fieldName)
	local fieldValue = self:getCurrentSeasonActivityField(fieldName)

	return Utils.getConfigTimeOfArea({
		[fieldName] = fieldValue
	}, fieldName)
end

function SeasonLobbyModel:getOpenActivityIdByType(activityType)
	local isOpen, activityId = ActivityUtils.isOprActivityTabOpenByType(activityType, pg.me)

	if not isOpen or not activityId or not ClientActivityUtils.isGameEventTabOpen(activityId) then
		return nil
	end

	return activityId
end

function SeasonLobbyModel:getSeasonLobbyTitleName()
	local locName = GameEventTypeData[ActivityConst.EventType.SeasonActivity] and GameEventTypeData[ActivityConst.EventType.SeasonActivity].name

	return locName and pg.getLocalizationText(locName) or nil
end

function SeasonLobbyModel:isSeasonActivityOpen()
	return self:getOpenActivityIdByType(ActivityConst.EventType.SeasonActivity) ~= nil
end

function SeasonLobbyModel:getActivityEndTime(activityType)
	local activityId = self:getOpenActivityIdByType(activityType)

	if not activityId then
		return nil
	end

	local eventTimeConfig = Utils.getEventTimeConfig(activityId)

	return eventTimeConfig and eventTimeConfig.tabEndDayTime
end

function SeasonLobbyModel:getSeasonRuleDesc()
	local activityId = self:getOpenActivityIdByType(ActivityConst.EventType.SeasonActivity)

	if not activityId then
		return nil
	end

	return ClientActivityUtils.getEventRule(activityId)
end

function SeasonLobbyModel:getSeasonCoinInfo()
	local seasonStageInfo = self:getSeasonStageInfo()
	local seasonCoinId = seasonStageInfo and seasonStageInfo.seasonCoinId

	if not seasonCoinId then
		return nil
	end

	local count = pg.me and pg.me:getItemCountById(seasonCoinId) or 0

	return {
		itemId = seasonCoinId,
		count = count
	}
end

function SeasonLobbyModel:getSeasonCatchButtonData()
	local currentTime = Time.secondCache or Time.getSecond()
	local phaseOneStartTime = self:_getCurrentSeasonActivityTime("buttonStartTime1")
	local phaseTwoStartTime = self:_getCurrentSeasonActivityTime("buttonStartTime2")
	local phase

	if phaseTwoStartTime and phaseTwoStartTime <= currentTime then
		phase = 2
	elseif phaseOneStartTime and phaseOneStartTime <= currentTime then
		phase = 1
	end

	if not phase then
		return nil
	end

	local buttonTextId = self:getCurrentSeasonActivityField("buttonText" .. phase)
	local buttonSourceId = self:getCurrentSeasonActivityField("buttonSource" .. phase)

	return {
		phase = phase,
		textId = buttonTextId,
		iconUrl = self:getCurrentSeasonActivityField("buttonImage" .. phase) or "",
		sourceData = buttonSourceId and ItemSourceData[buttonSourceId]
	}
end

function SeasonLobbyModel:getSeasonShopOpenInfo()
	local shopId = self:getCurrentSeasonActivityField("shopId")

	if not shopId then
		return nil
	end

	return {
		shopTags = {
			shopId
		}
	}
end

function SeasonLobbyModel:getShopBannerList()
	local bannerList = self:getCurrentSeasonActivityField("shopEntryImage")

	return Utils.isTable(bannerList) and bannerList or {}
end

function SeasonLobbyModel:getShopImageUrls()
	local imageUrls = {}

	for _, bannerData in ipairs(self:getShopBannerList()) do
		local imageUrl = type(bannerData) == "table" and bannerData.iconPath or bannerData

		if not string.isNilOrEmpty(imageUrl) then
			imageUrls[#imageUrls + 1] = imageUrl
		end
	end

	return imageUrls
end

function SeasonLobbyModel:hasOpenedSeasonLobbySeason(seasonId)
	local firstOpenKey = ClientConst.PrefKey.SeasonLobbyFirstOpenPhase
	local cacheFlag = ClientConst.CACHE_TYPE_FLAG.USER

	return pg.global.prefsCacheUtils:getInt(firstOpenKey, 0, cacheFlag) == seasonId
end

function SeasonLobbyModel:recordSeasonLobbySeasonOpened(seasonId)
	local firstOpenKey = ClientConst.PrefKey.SeasonLobbyFirstOpenPhase
	local cacheFlag = ClientConst.CACHE_TYPE_FLAG.USER

	pg.global.prefsCacheUtils:setInt(firstOpenKey, seasonId, cacheFlag)
end

function SeasonLobbyModel:getBattlePassContext()
	local activityData = ActivityUtils.getActivityData(pg.me, ActivityConst.EventType.BattlePass)
	local phase = activityData and activityData.activityBase and activityData.activityBase.activityPhase

	if not phase then
		return nil
	end

	local battlePassData = BattlePassData[phase]

	return {
		phase = phase,
		config = battlePassData,
		gear = activityData.bpGear or ActivityConst.BattlePassGear.Free,
		level = activityData.bpLevel or 0,
		payGear = ActivityConst.BattlePassGear.Pay1,
		popupLimitLevels = battlePassData and battlePassData.popupLimitLevels
	}
end

function SeasonLobbyModel:getBattlePassPopupRecord()
	local prefsKey = ClientConst.PrefKey.BPCorePop
	local recordPhase = 0
	local shownLevels = {}
	local isLegacyRecord = false
	local prefsValue = pg.global.prefsCacheUtils:getString(prefsKey, "")

	if not string.isNilOrEmpty(prefsValue) then
		local phaseStr, levelsStr = string.match(prefsValue, "^(%d+):?(.*)$")

		if phaseStr then
			recordPhase = tonumber(phaseStr) or 0

			if string.isNilOrEmpty(levelsStr) then
				isLegacyRecord = true
			else
				for _, levelStr in ipairs(string.split(levelsStr, ",")) do
					local level = tonumber(levelStr)

					if level then
						shownLevels[level] = true
					end
				end
			end
		end
	end

	recordPhase = tonumber(recordPhase) or 0

	if recordPhase == 0 then
		recordPhase = tonumber(pg.global.prefsCacheUtils:getInt(prefsKey, 0)) or 0
		isLegacyRecord = recordPhase > 0
	end

	return recordPhase, shownLevels, isLegacyRecord
end

function SeasonLobbyModel:saveBattlePassPopupRecord(phase, shownLevels)
	local levelList = {}

	for level in pairs(shownLevels) do
		levelList[#levelList + 1] = level
	end

	table.sort(levelList)

	local prefsKey = ClientConst.PrefKey.BPCorePop
	local prefsValue = string.format("%d:%s", phase, table.concat(levelList, ","))

	pg.global.prefsCacheUtils:setString(prefsKey, prefsValue)
end

function SeasonLobbyModel:getBattlePassPopupTargetLevel(popupLimitLevels, battlePassLevel, sameSeason, shownLevels)
	local targetLevel

	for _, popupLevel in ipairs(popupLimitLevels) do
		local hasShown = sameSeason and shownLevels[popupLevel]

		if popupLevel <= battlePassLevel and not hasShown and (not targetLevel or targetLevel < popupLevel) then
			targetLevel = popupLevel
		end
	end

	return targetLevel
end

function SeasonLobbyModel:markReachedBattlePassPopupLevels(popupLimitLevels, battlePassLevel, shownLevels)
	shownLevels = shownLevels or {}

	for _, popupLevel in ipairs(popupLimitLevels) do
		if popupLevel <= battlePassLevel then
			shownLevels[popupLevel] = true
		end
	end

	return shownLevels
end

function SeasonLobbyModel:isBattlePassPopupScopeAllowed(battlePassData)
	if not battlePassData or not self:_isBattlePassPopupRegionAllowed(battlePassData.regionLimitId) then
		return false
	end

	local popupStartTime = Utils.getConfigTimeOfArea(battlePassData, "popupStartDayTime") or 0
	local popupEndTime = Utils.getConfigTimeOfArea(battlePassData, "popupEndDayTime") or 0

	if popupStartTime > 0 and popupStartTime > Time.secondCache then
		return false
	end

	if popupEndTime > 0 and popupEndTime <= Time.secondCache then
		return false
	end

	return true
end

function SeasonLobbyModel:_isBattlePassPopupRegionAllowed(regionLimitId)
	if regionLimitId == nil then
		return true
	end

	local serverArea = tonumber(Utils.getServerArea())

	if serverArea == nil then
		return false
	end

	if Utils.isTable(regionLimitId) then
		for _, areaId in ipairs(regionLimitId) do
			if tonumber(areaId) == serverArea then
				return true
			end
		end

		return false
	end

	return tonumber(regionLimitId) == serverArea
end

function SeasonLobbyModel:getEntryRedDotStyle()
	local seasonShop = pg.global.ui.seasonShop
	local seasonShopModel = seasonShop and seasonShop.model
	local styleList = {
		pg.global.ui.seasonAchievement.model:getEntryRedDotStyle(),
		CashShopRedDotUtils.getBattlePassHudRedDotStyle(),
		seasonShopModel and seasonShopModel:getEntryRedDotStyle() or RedDotConst.RedDotStyle.NONE
	}

	return pg.global.calculateRedDotPriority(styleList) or RedDotConst.RedDotStyle.NONE
end

return SeasonLobbyModel
