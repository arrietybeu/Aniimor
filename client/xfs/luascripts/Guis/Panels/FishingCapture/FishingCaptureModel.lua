-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\FishingCapture\\FishingCaptureModel.lua

local logger = require("Core.Log.LoggerManager").getLogger("FishingCaptureModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local FishingCaptureConst = require("Common.Const.FishingCaptureConst")
local ItemConst = require("Common.Const.ItemConst")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local ActivityConst = require("Common.Const.ActivityConst")
local Utils = require("Common.Utils.Utils")
local SceneUtils = require("Common.Utils.SceneUtils")
local FishingCaptureConfigData = require("Data.fishing_capture_config_data")
local LevelData = require("Data.level_data")
local ChestData = require("Data.chest_data")
local FishingCaptureModel = Class.LightClass("FishingCaptureModel", UIModel)
local DEFAULT_MODE = 1

function FishingCaptureModel:ctor()
	self._selectedMode = DEFAULT_MODE
	self._openInfo = nil
	self._entranceType = FishingCaptureConst.EntranceType.Weekly
end

function FishingCaptureModel:setOpenInfo(info)
	self._openInfo = info

	local entranceType = info and tonumber(info.entranceType)

	if entranceType ~= FishingCaptureConst.EntranceType.Final then
		entranceType = FishingCaptureConst.EntranceType.Weekly
	end

	self._entranceType = entranceType
end

function FishingCaptureModel:getEntranceType()
	return self._entranceType
end

function FishingCaptureModel:isWeeklyEntrance()
	return self._entranceType == FishingCaptureConst.EntranceType.Weekly
end

function FishingCaptureModel:getEntranceStatePage()
	if self:isWeeklyEntrance() then
		return 0
	end

	return 1
end

function FishingCaptureModel:setSelectedMode(mode)
	self._selectedMode = mode
end

function FishingCaptureModel:getSelectedMode()
	return self._selectedMode
end

function FishingCaptureModel:getActivityInfo()
	return ActivityUtils.getFishingCaptureConfig(nil, pg.me)
end

function FishingCaptureModel:getDisplayRewardId()
	local activityInfo = self:getActivityInfo()

	if not activityInfo then
		return nil
	end

	if self:isWeeklyEntrance() then
		return activityInfo.weekreward
	end

	return activityInfo.displayReward
end

function FishingCaptureModel:getEntranceSceneId()
	local activityInfo = self:getActivityInfo()

	if not activityInfo then
		return nil
	end

	if self:isWeeklyEntrance() then
		return activityInfo.weeksceneId
	end

	return activityInfo.sceneId
end

function FishingCaptureModel:getEntranceName()
	local sceneId = self:getEntranceSceneId()
	local dungeonInfo = sceneId and LevelData[sceneId]

	return dungeonInfo and dungeonInfo.name
end

function FishingCaptureModel:getEntranceRule()
	local sceneId = self:getEntranceSceneId()
	local dungeonInfo = sceneId and LevelData[sceneId]

	return dungeonInfo and dungeonInfo.rule
end

function FishingCaptureModel:getEntranceDescription()
	local activityInfo = self:getActivityInfo()

	if not activityInfo then
		return nil
	end

	local sceneId = self:getEntranceSceneId()
	local dungeonInfo = sceneId and LevelData[sceneId]

	return dungeonInfo and dungeonInfo.describe or activityInfo.trainDesc
end

function FishingCaptureModel:getTopCurrencyItemIds()
	if self:isWeeklyEntrance() then
		return {
			ItemConst.ITEM_SPECIAL_MONEY_YUANNENG
		}
	end

	return {}
end

function FishingCaptureModel:getWeeklyChallengeCount()
	local limitCount = FishingCaptureConfigData.FC_WEEKLY_LIMIT

	if not pg.me then
		return 0, limitCount
	end

	local usedCount = 0

	for _, count in pairs(pg.me.weeklyPassRecord) do
		usedCount = usedCount + count
	end

	return math.max(limitCount - usedCount, 0), limitCount
end

function FishingCaptureModel:getWeeklyChestCost()
	local activityInfo = self:getActivityInfo()

	if not activityInfo then
		return nil, nil
	end

	if not activityInfo.weeksceneId then
		logger:error("getWeeklyChestCost: weeksceneId not found")

		return nil, nil
	end

	local chestStaticIds = FishingCaptureConfigData.FC_CHESTID

	if not chestStaticIds or not chestStaticIds[1] then
		logger:error("getWeeklyChestCost: FC_CHESTID not found")

		return nil, nil
	end

	local chestStaticId = chestStaticIds[1]
	local sceneEntityData = SceneUtils.getSceneEntityData(activityInfo.weeksceneId)

	if not sceneEntityData then
		logger:error("getWeeklyChestCost: scene entity data not found, sceneId=%s", activityInfo.weeksceneId)

		return nil, nil
	end

	local sceneEntityInfo = sceneEntityData[chestStaticId]

	if not sceneEntityInfo then
		logger:error("getWeeklyChestCost: weekly chest entity not found, sceneId=%s, staticId=%s", activityInfo.weeksceneId, chestStaticId)

		return nil, nil
	end

	if not sceneEntityInfo.idInType then
		logger:error("getWeeklyChestCost: weekly chest templateId not found, staticId=%s", chestStaticId)

		return nil, nil
	end

	local chestInfo = ChestData[sceneEntityInfo.idInType]

	if not chestInfo or not chestInfo.needItem or not chestInfo.needItem[1] or not chestInfo.needItem[2] then
		logger:error("getWeeklyChestCost: weekly chest config not found, templateId=%s", sceneEntityInfo.idInType)

		return nil, nil
	end

	return chestInfo.needItem[1], chestInfo.needItem[2]
end

function FishingCaptureModel:getDisplayPetId()
	return nil
end

function FishingCaptureModel:getElementList()
	local cfg = self:getActivityInfo()

	if not cfg then
		return {}
	end

	local data = cfg.recommendType

	if not data then
		return {}
	end

	local result = {}

	for i = 1, #data do
		table.insert(result, {
			element = data[i]
		})
	end

	return result
end

function FishingCaptureModel:getActivityEventId()
	local isOpen, activityId = ActivityUtils.isOprActivityTabOpenByType(ActivityConst.EventType.FishingCapture, pg.me)

	if not isOpen then
		return nil
	end

	return activityId
end

function FishingCaptureModel:getActivityEndTime()
	local activityId = self:getActivityEventId()

	if not activityId then
		return 0
	end

	local cfg = Utils.getEventTimeConfig(activityId)

	return cfg and cfg.tabEndDayTime or 0
end

function FishingCaptureModel:getTicketItemId()
	local activityInfo = self:getActivityInfo()

	return activityInfo and activityInfo.coincubeId
end

function FishingCaptureModel:getTicketCount()
	local itemId = self:getTicketItemId()

	if not itemId then
		return 0
	end

	return pg.me:getItemCountById(itemId)
end

function FishingCaptureModel:checkEnterCondition()
	if self:getActivityInfo() == nil or not ActivityUtils.isOprActivityTabOpenByType(ActivityConst.EventType.FishingCapture, pg.me) then
		return false, pg.getGameString("FUNC_NOT_AVAILABLE")
	end

	if not self:isWeeklyEntrance() then
		local fishingData = ActivityUtils.getActivityData(pg.me, ActivityConst.EventType.FishingCapture)

		if fishingData and fishingData.irisRewardReceived == true then
			return false, pg.getGameString("FC_IRIS_LIMIT_TEXT")
		end

		if self:getTicketCount() <= 0 then
			return false, pg.getGameString("FISHING_CAPTURE_TICKET_REQUIRED")
		end
	end

	return true, nil
end

return FishingCaptureModel
