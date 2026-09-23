-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\SeasonShop\\SeasonShopModel.lua

local ActivityConst = require("Common.Const.ActivityConst")
local Const = require("Common.Const.Const")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local TimeUtils = require("Common.Utils.TimeUtils")
local Utils = require("Common.Utils.Utils")
local Time = require("Core.Common.Time")
local Class = require("Core.Framework.Class")
local RedDotConst = require("Const.RedDotConst")
local ShopBaseModel = require("Guis.Panels.Shop.ShopBaseModel")
local ClientActivityUtils = require("Utils.ClientActivityUtils")
local SeasonActivityData = require("Data.season_activity_data")
local WEEKLY_SHOP_RED_DOT_RECORD_KEY = "SeasonShopWeeklyTab"
local SPECIAL_ITEM_RED_DOT_RECORD_KEY = "SeasonShopSpecialItem_%d_%d"
local SeasonShopModel = Class.LightClass("SeasonShopModel", ShopBaseModel)

function SeasonShopModel:_getCurrentSeasonActivityField(fieldName)
	local seasonStageInfo = Utils.getCurrentSeasonStage()
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

function SeasonShopModel:getSeasonShopOpenInfo()
	local shopId = self:_getCurrentSeasonActivityField("shopId")

	if not shopId then
		return nil
	end

	return {
		shopTags = {
			shopId
		}
	}
end

function SeasonShopModel:getOpenActivityIdByType(activityType)
	local isOpen, activityId = ActivityUtils.isOprActivityTabOpenByType(activityType, pg.me)

	if not isOpen or not activityId or not ClientActivityUtils.isGameEventTabOpen(activityId) then
		return nil
	end

	return activityId
end

function SeasonShopModel:getActivityEndTime(activityType)
	local activityId = self:getOpenActivityIdByType(activityType)

	if not activityId then
		return nil
	end

	local eventTimeConfig = Utils.getEventTimeConfig(activityId)

	return eventTimeConfig and eventTimeConfig.tabEndDayTime
end

function SeasonShopModel:getSeasonShopActivityEndTime()
	return self:getActivityEndTime(ActivityConst.EventType.SeasonActivity)
end

function SeasonShopModel:getWeeklyShopRefreshTime()
	local refreshOffset = Utils.getSecondsAreaDayStart()
	local nowWithOffset = Time.secondCache - refreshOffset

	return TimeUtils.getAreaNextWeekBegin(nowWithOffset) + refreshOffset
end

function SeasonShopModel:_getWeeklyShopRefreshVersion()
	return self:getWeeklyShopRefreshTime() - Const.SECONDS_ONE_WEEK
end

function SeasonShopModel:isWeeklyShopTabNew()
	if not pg.me or not pg.me.getRedDotRecord then
		return false
	end

	local viewedVersion = tonumber(pg.me:getRedDotRecord(Const.CLIENT_KEY.EVENT_RED_DOT, WEEKLY_SHOP_RED_DOT_RECORD_KEY, 0)) or 0

	return viewedVersion < self:_getWeeklyShopRefreshVersion()
end

function SeasonShopModel:markWeeklyShopTabRead()
	if not pg.me or not pg.me.setRedDotRecord or not self:isWeeklyShopTabNew() then
		return false
	end

	return pg.me:setRedDotRecord(Const.CLIENT_KEY.EVENT_RED_DOT, WEEKLY_SHOP_RED_DOT_RECORD_KEY, self:_getWeeklyShopRefreshVersion())
end

function SeasonShopModel:_isSeasonExclusiveShopItem(shopItemConfig)
	return shopItemConfig ~= nil and shopItemConfig.isSpecial == 1
end

function SeasonShopModel:isSeasonExclusiveShopItem(shopItemId)
	return self:_isSeasonExclusiveShopItem(self:getShopItemConfig(shopItemId))
end

function SeasonShopModel:_getSpecialItemRedDotRecordKey(shopItemId)
	local seasonStageInfo = Utils.getCurrentSeasonStage()
	local seasonId = seasonStageInfo and seasonStageInfo.seasonId or 0

	return string.format(SPECIAL_ITEM_RED_DOT_RECORD_KEY, seasonId, shopItemId)
end

function SeasonShopModel:isSeasonExclusiveShopItemNew(shopItemId)
	if not pg.me or not pg.me.getRedDotRecord or not self:isSeasonExclusiveShopItem(shopItemId) or not self:isPropUnlock(shopItemId) then
		return false
	end

	return pg.me:getRedDotRecord(Const.CLIENT_KEY.EVENT_RED_DOT, self:_getSpecialItemRedDotRecordKey(shopItemId), true) == true
end

function SeasonShopModel:markSeasonExclusiveShopItemRead(shopItemId)
	if not pg.me or not pg.me.setRedDotRecord or not self:isSeasonExclusiveShopItemNew(shopItemId) then
		return false
	end

	return pg.me:setRedDotRecord(Const.CLIENT_KEY.EVENT_RED_DOT, self:_getSpecialItemRedDotRecordKey(shopItemId), false)
end

function SeasonShopModel:hasNewSeasonExclusiveShopItem()
	local openInfo = self:getSeasonShopOpenInfo()

	if not openInfo then
		return false
	end

	local shopTags = self:getSellShopTags(openInfo)
	local seasonShopTag = shopTags[2]

	if not seasonShopTag then
		return false
	end

	local shopItems = self:getBuyShopProps(seasonShopTag.id)

	for _, shopItem in ipairs(shopItems) do
		if self:isSeasonExclusiveShopItemNew(shopItem.id) then
			return true
		end
	end

	return false
end

function SeasonShopModel:getEntryRedDotStyle()
	if self:isWeeklyShopTabNew() or self:hasNewSeasonExclusiveShopItem() then
		return RedDotConst.RedDotStyle.NEW
	end

	return RedDotConst.RedDotStyle.NONE
end

function SeasonShopModel:partitionShopItems(shopItems)
	local normalItems = {}
	local exclusiveItems = {}

	for _, shopItem in ipairs(shopItems or {}) do
		if self:isSeasonExclusiveShopItem(shopItem.id) then
			exclusiveItems[#exclusiveItems + 1] = shopItem
		else
			normalItems[#normalItems + 1] = shopItem
		end
	end

	return normalItems, exclusiveItems
end

function SeasonShopModel:getHeaderInfo()
	local seasonStageInfo = Utils.getCurrentSeasonStage()

	return {
		seasonTagIcon = seasonStageInfo and seasonStageInfo.seasonTagIcon or "",
		seasonTagTextId = seasonStageInfo and seasonStageInfo.seasonTagTextId
	}
end

return SeasonShopModel
