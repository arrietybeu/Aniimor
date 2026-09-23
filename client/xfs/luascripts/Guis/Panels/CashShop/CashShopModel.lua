-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CashShop\\CashShopModel.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("CashShopModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local ShopmallTabData = require("Data.shopmall_tab_data")
local ShopmallTabGroupData = require("Data.shopmall_tab_group_data")
local RecommendationData = require("Data.shopmall_recommendation_data")
local ShopmallCommodityData = require("Data.shopmall_commodity_data")
local ShopmallGiftData = require("Data.shopmall_gift_data")
local RandomShopData = require("Data.random_shop_data")
local AvatarPresetData = require("Data.avatar_preset_data")
local ItemConditionConvertData = require("Data.item_condition_convert_data")
local AppearanceSuitData = require("Data.appearance_suit_data")
local CommonSwitch = require("Common.CommonSwitch")
local CashShopConst = require("Const.CashShopConst")
local Utils = require("Common.Utils.Utils")
local TimeUtils = require("Common.Utils.TimeUtils")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local ActivityConst = require("Common.Const.ActivityConst")
local ClientCashShopUtils = require("Utils.ClientCashShopUtils")
local ServiceUtils = require("Common.Utils.ServiceUtils")
local Time = require("Core.Common.Time")
local CashShopModel = Class.LightClass("CashShopModel", UIModel)
local BODY_FEMALE = 11
local CONDITION_FEMALE = 7
local CONDITION_MALE = 6
local RANDOM_SHOP_TIME_PATTERN = "(%d+)/(%d+)/(%d+)/(%d+):(%d+):(%d+)"
local RECOMMENDATION_TIME_CONFIG_PATTERN = "^%{%s*(%d+)%s*,%s*\"([^\"]+)\"%s*%}$"

function CashShopModel:ctor()
	self._categoryList = {}
	self._itemCache = {}
	self._currentCategoryId = nil
	self._currentTabId = nil
	self._currentGroupId = nil
	self._showTabs = nil
end

function CashShopModel:setShowTabs(showTabs)
	local newSet

	if Utils.isTable(showTabs) and #showTabs > 0 then
		newSet = {}

		for _, tabId in ipairs(showTabs) do
			newSet[tabId] = true
		end
	end

	local old = self._showTabs
	local changed = false

	if old == nil ~= (newSet == nil) then
		changed = true
	elseif old and newSet then
		for k in pairs(old) do
			if not newSet[k] then
				changed = true

				break
			end
		end

		if not changed then
			for k in pairs(newSet) do
				if not old[k] then
					changed = true

					break
				end
			end
		end
	end

	self._showTabs = newSet

	return changed
end

function CashShopModel:isTabInShowTabs(tabId)
	if not self._showTabs then
		return true
	end

	return self._showTabs[tabId] == true
end

function CashShopModel:addShowTab(tabId)
	if not tabId or not self._showTabs then
		return false
	end

	if self._showTabs[tabId] then
		return false
	end

	self._showTabs[tabId] = true

	return true
end

function CashShopModel:getTabList()
	local result = {}

	for id, cfg in pairs(ShopmallTabData) do
		if not cfg.isHide or cfg.isHide ~= 1 then
			local entry = {}

			for k, v in pairs(cfg) do
				entry[k] = v
			end

			entry.id = id

			local switchKey = cfg.commonSwitchKey

			if switchKey then
				entry.unlock = CommonSwitch[switchKey] == true
			else
				entry.unlock = true
			end

			result[#result + 1] = entry
		end
	end

	table.sort(result, function(a, b)
		return a.sort < b.sort
	end)

	return result
end

function CashShopModel:isTabOpen(tabId)
	if not tabId then
		return false
	end

	local cfg = ShopmallTabData[tabId]

	if not cfg then
		return false
	end

	local switchKey = cfg.commonSwitchKey

	if not switchKey then
		return true
	end

	return CommonSwitch[switchKey] == true
end

function CashShopModel:getDefaultTabId()
	local tabList = self:getTabList()

	for _, tab in ipairs(tabList) do
		if tab.defaultSelect == 1 then
			return tab.id
		end
	end

	return tabList[1] and tabList[1].id or nil
end

function CashShopModel:setCurrentTabId(tabId)
	self._currentTabId = tabId
end

function CashShopModel:getCurrentTabId()
	return self._currentTabId
end

function CashShopModel:getCurrentTabCurrencyList()
	local tabId = self._currentTabId

	if not tabId then
		return {}
	end

	local cfg = ShopmallTabData[tabId]

	if not cfg or not cfg.currency then
		return {}
	end

	local result = {}

	for _, id in ipairs(cfg.currency) do
		result[#result + 1] = {
			itemId = id
		}
	end

	return result
end

function CashShopModel:getRandomShopTimestamp(cfg, fieldName)
	local generatedTimestamp = tonumber(Utils.getConfigTimeOfArea(cfg, fieldName))

	if generatedTimestamp then
		return generatedTimestamp
	end

	local timeConfig = cfg and cfg[fieldName]

	if not Utils.isTable(timeConfig) then
		return nil
	end

	local timeType = tonumber(timeConfig[1])
	local timeString = timeConfig[2]

	if not timeType or type(timeString) ~= "string" or timeString == "" then
		return nil
	end

	local timestamp = TimeUtils.configStringToTimestampByType(timeType, timeString, RANDOM_SHOP_TIME_PATTERN)

	return tonumber(timestamp)
end

function CashShopModel:isRandomShopCommonSwitchOpen(cfg)
	local switchKey = cfg and cfg.commonSwitchKey

	if not switchKey or switchKey == "" then
		return true
	end

	return CommonSwitch[switchKey] == true
end

function CashShopModel:getCurrentRandomShop()
	local now = tonumber(Time.secondCache)

	if not now or now <= 0 then
		now = Time.getSecond()
	end

	for shopId, cfg in pairs(RandomShopData) do
		local startTime = self:getRandomShopTimestamp(cfg, "startTime")
		local endTime = self:getRandomShopTimestamp(cfg, "endTime")

		if startTime and endTime and startTime <= now and now <= endTime and self:isRandomShopCommonSwitchOpen(cfg) then
			return shopId, cfg
		end
	end

	return nil, nil
end

function CashShopModel:isRandomShopAvailable()
	local shopId = self:getCurrentRandomShop()

	return shopId ~= nil
end

function CashShopModel:getGroupListByTabId(tabId)
	local result = {}
	local randomShopAvailable = tabId ~= CashShopConst.CategoryType.EXCHANGE or self:isRandomShopAvailable()

	for id, cfg in pairs(ShopmallTabGroupData) do
		if cfg.tabId == tabId and cfg.isHide ~= 1 and (id ~= CashShopConst.ExchangeShopTabType.Random or randomShopAvailable) then
			local entry = {}

			for k, v in pairs(cfg) do
				entry[k] = v
			end

			entry.id = id
			result[#result + 1] = entry
		end
	end

	table.sort(result, function(a, b)
		return a.sort < b.sort
	end)

	return result
end

function CashShopModel:getDefaultGroupId(tabId)
	local groups = self:getGroupListByTabId(tabId)

	return groups[1] and groups[1].id or nil
end

function CashShopModel:setCurrentGroupId(groupId)
	self._currentGroupId = groupId
end

function CashShopModel:getCurrentGroupId()
	return self._currentGroupId
end

function CashShopModel:setCategoryList(list)
	self._categoryList = list or {}
end

function CashShopModel:getCategoryList()
	return self._categoryList
end

function CashShopModel:getDefaultCategoryId()
	if #self._categoryList > 0 then
		return self._categoryList[1].id
	end

	return nil
end

function CashShopModel:setCurrentCategoryId(categoryId)
	self._currentCategoryId = categoryId
end

function CashShopModel:getCurrentCategoryId()
	return self._currentCategoryId
end

function CashShopModel:setItemList(categoryId, itemList)
	self._itemCache[categoryId] = itemList or {}
end

function CashShopModel:getItemList(categoryId)
	return self._itemCache[categoryId]
end

function CashShopModel:hasItemCache(categoryId)
	return self._itemCache[categoryId] ~= nil
end

function CashShopModel:clearItemCache()
	self._itemCache = {}
end

function CashShopModel:getItemById(itemId)
	local list = self:getItemList(self._currentCategoryId)

	if not list then
		return nil
	end

	for _, item in ipairs(list) do
		if item.id == itemId then
			return item
		end
	end

	return nil
end

function CashShopModel:isItemSoldOut(itemId)
	local item = self:getItemById(itemId)

	if not item then
		return false
	end

	return item.stock ~= nil and item.stock <= 0
end

function CashShopModel:isItemReachLimit(itemId)
	local item = self:getItemById(itemId)

	if not item then
		return false
	end

	if not item.limitNum or item.limitNum <= 0 then
		return false
	end

	return (item.boughtNum or 0) >= item.limitNum
end

function CashShopModel:isOptionalGiftPackAvailable()
	for id, cfg in pairs(ShopmallCommodityData) do
		if cfg and cfg.tabGroupId == CashShopConst.GiftPackTabType.Optional and cfg.onSale == 1 and ClientCashShopUtils.isCommodityEnabled(id) then
			local startTime = Utils.getConfigTimeOfArea(cfg, "startTime")
			local endTime = Utils.getConfigTimeOfArea(cfg, "endTime")
			local inSaleTime = startTime and endTime and TimeUtils.isInRangeTimestamp(startTime, endTime)

			if inSaleTime and ClientCashShopUtils.getCommodityLeftLimit(id) > 0 then
				return true
			end
		end
	end

	return false
end

function CashShopModel:getGiftPackTabData()
	local tabData = {}
	local optionalAvailable = self:isOptionalGiftPackAvailable()

	for id, tabGroup in pairs(ShopmallTabGroupData) do
		if tabGroup.tabId ~= 3 or id == CashShopConst.GiftPackTabType.Optional and not optionalAvailable then
			-- block empty
		else
			local data = {}

			data.id = id
			data.name = tabGroup.tabName
			data.sort = tabGroup.sort

			table.insert(tabData, data)
		end
	end

	table.sort(tabData, function(a, b)
		return a.sort > b.sort
	end)

	return tabData
end

function CashShopModel:getGiftPackData(tabId)
	local giftPackData = {}

	for id, cfg in pairs(ShopmallCommodityData) do
		local startTime = Utils.getConfigTimeOfArea(cfg, "startTime")
		local endTime = Utils.getConfigTimeOfArea(cfg, "endTime")
		local showGiftPack = startTime and endTime and TimeUtils.isInRangeTimestamp(startTime, endTime)

		if cfg and cfg.tabGroupId == tabId and showGiftPack and cfg.onSale == 1 and ClientCashShopUtils.isCommodityEnabled(id) then
			local giftData = ShopmallGiftData[cfg.itemId]

			if giftData then
				local entry = {}

				entry.id = id
				entry.giftPackType = giftData.giftPackType
				entry.giftPackName = giftData.giftPackName
				entry.giftPackIocn = giftData.giftPackIocn
				entry.FixItems = giftData.FixItems
				entry.selectItems = giftData.selectItems
				entry.sort = cfg.sort

				local leftLimit = ClientCashShopUtils.getCommodityLeftLimit(id)

				if leftLimit <= 0 then
					entry.sort = 0
				end

				giftPackData[#giftPackData + 1] = entry
			end
		end
	end

	table.sort(giftPackData, function(a, b)
		return a.sort > b.sort
	end)

	return giftPackData
end

function CashShopModel:costItemEnough(commodityId)
	local commodityData = ShopmallCommodityData[commodityId]

	if not commodityData then
		return false
	end

	local giftData = ShopmallGiftData[commodityData.itemId]

	if not giftData then
		return false
	end

	if giftData.giftPackType == 3 then
		return true
	end

	return ClientCashShopUtils.canAffordCommodity(commodityId, 1)
end

function CashShopModel:_getPlayerGender()
	local presetKey = pg.game.avatar:getPresetKey(pg.me)
	local presetData = pg.game.avatar:getAvatarPresetData(presetKey) or {}

	return presetData.body or BODY_FEMALE
end

function CashShopModel:_getGenderConvertedItemId(itemId, gender)
	if not itemId or not gender then
		return itemId
	end

	local convertData = ItemConditionConvertData[itemId]

	if convertData and convertData.targetItem then
		local targetCondition = gender == BODY_FEMALE and CONDITION_FEMALE or CONDITION_MALE

		for _, entry in ipairs(convertData.targetItem) do
			if entry[1] == targetCondition then
				return entry[2]
			end
		end
	end

	return itemId
end

function CashShopModel:_itemSupportsGender(itemId, gender)
	if not gender or not itemId then
		return true
	end

	local convertData = ItemConditionConvertData[itemId]

	if convertData and convertData.targetItem then
		local targetCondition = gender == BODY_FEMALE and CONDITION_FEMALE or CONDITION_MALE

		for _, entry in ipairs(convertData.targetItem) do
			if entry[1] == targetCondition then
				return true
			end
		end

		return false
	end

	local suitData = AppearanceSuitData[itemId]

	if suitData and suitData.body then
		for _, body in ipairs(suitData.body) do
			if body == gender then
				return true
			end
		end

		return false
	end

	return true
end

function CashShopModel:_getItemIdFromRecommendEntry(entry)
	if not entry then
		return nil
	end

	if entry.commodityId then
		local commodityInfo = ShopmallCommodityData[entry.commodityId]

		return commodityInfo and commodityInfo.itemId
	end

	return entry.itemId
end

function CashShopModel:_getRecommendationTimestamp(entry, fieldName)
	local timeConfig = entry and entry[fieldName]

	if timeConfig == nil or timeConfig == "" then
		return nil
	end

	local generatedTimestamp = tonumber(Utils.getConfigTimeOfArea(entry, fieldName))

	if generatedTimestamp then
		return generatedTimestamp
	end

	local timeType, timeString

	if Utils.isTable(timeConfig) then
		timeType = tonumber(timeConfig[1])
		timeString = timeConfig[2]
	elseif type(timeConfig) == "string" then
		timeType, timeString = string.match(timeConfig, RECOMMENDATION_TIME_CONFIG_PATTERN)
		timeType = tonumber(timeType)
	end

	if not timeType or type(timeString) ~= "string" or timeString == "" then
		return nil
	end

	local timestamp = TimeUtils.configStringToTimestampByType(timeType, timeString, RANDOM_SHOP_TIME_PATTERN)

	return tonumber(timestamp)
end

function CashShopModel:_isRecommendationInDisplayTime(entry)
	local hasStartTime = entry.stratTime ~= nil and entry.stratTime ~= ""
	local hasEndTime = entry.endTime ~= nil and entry.endTime ~= ""

	if not hasStartTime and not hasEndTime then
		return true
	end

	local startTime = self:_getRecommendationTimestamp(entry, "stratTime")
	local endTime = self:_getRecommendationTimestamp(entry, "endTime")

	if hasStartTime and not startTime or hasEndTime and not endTime then
		return false
	end

	return TimeUtils.isInRangeTimestamp(startTime, endTime)
end

function CashShopModel:_isRecommendationEntryVisible(entry, gender, monthlyCardOn, bpActive, firstTopupOpen)
	if not self:_isRecommendationInDisplayTime(entry) then
		return false
	end

	if entry.commodityId and not ClientCashShopUtils.isCommodityEnabled(entry.commodityId) then
		return false
	end

	if entry.showModle == CashShopConst.ShowModle.MonthCard and not monthlyCardOn then
		return false
	end

	if entry.showModle == CashShopConst.ShowModle.BattlePass and not bpActive then
		return false
	end

	if entry.showModle == CashShopConst.ShowModle.FirstTopup and not firstTopupOpen then
		return false
	end

	local itemId = self:_getItemIdFromRecommendEntry(entry)

	return self:_itemSupportsGender(itemId, gender)
end

function CashShopModel:_isFirstTopupOpen()
	local isOpen, activityId = ActivityUtils.isOprActivityOpenByType(ActivityConst.EventType.FirstTopup, pg.me)
	local actData = ActivityUtils.getActivityData(pg.me, ActivityConst.EventType.FirstTopup)
	local activityBase = actData and actData.activityBase
	local runtimeActivityId = activityBase and activityBase.activityId or 0
	local taskCount = 0

	if activityBase and activityBase.activityTasks then
		for _ in pairs(activityBase.activityTasks) do
			taskCount = taskCount + 1
		end
	end

	return isOpen == true and activityId ~= nil and activityId > 0
end

function CashShopModel:getRecommendationLists()
	local bannerList = {}
	local displayRaw = {}
	local gender = self:_getPlayerGender()
	local monthlyCardOn = CommonSwitch.ShopMall_MonthlyCard == true
	local actData = ActivityUtils.getActivityData(pg.me, ActivityConst.EventType.BattlePass)
	local phase = actData and actData.activityBase and actData.activityBase.activityPhase or 0
	local bpActive = phase ~= 0
	local firstTopupOpen = self:_isFirstTopupOpen()

	for id, cfg in pairs(RecommendationData) do
		local entry = {}

		for k, v in pairs(cfg) do
			entry[k] = v
		end

		entry.id = id

		if self:_isRecommendationEntryVisible(entry, gender, monthlyCardOn, bpActive, firstTopupOpen) then
			if cfg.showType == 1 then
				bannerList[#bannerList + 1] = entry
			else
				displayRaw[#displayRaw + 1] = entry
			end
		end
	end

	table.sort(bannerList, function(a, b)
		return a.sort < b.sort
	end)
	table.sort(displayRaw, function(a, b)
		return a.sort < b.sort
	end)

	local displayList = {}
	local i = 1

	while i <= #displayRaw do
		local entry = displayRaw[i]

		if entry.showType == 3 and displayRaw[i + 1] and displayRaw[i + 1].showType == 3 then
			entry.tIndex = 1
			displayList[#displayList + 1] = entry
			displayRaw[i + 1].tIndex = 1
			displayList[#displayList + 1] = displayRaw[i + 1]
			i = i + 2
		else
			entry.tIndex = 2
			displayList[#displayList + 1] = entry
			i = i + 1
		end
	end

	if bannerList and #bannerList > 0 then
		table.insert(displayList, 1, {
			tIndex = 0,
			bannerList = bannerList
		})
	end

	return displayList
end

function CashShopModel:requestFriendShopStatus(friendIds, commodityId, callback)
	if not friendIds or #friendIds == 0 or not commodityId then
		callback({})

		return
	end

	local selfUid = tostring(pg.me.uid)
	local requestFriendIds = {}
	local requestFriendUidMap = {}

	for _, friendId in ipairs(friendIds) do
		local friendUid = tostring(friendId)

		if friendUid ~= selfUid and not requestFriendUidMap[friendUid] then
			requestFriendUidMap[friendUid] = true
			requestFriendIds[#requestFriendIds + 1] = friendUid
		end
	end

	if #requestFriendIds == 0 then
		callback({})

		return
	end

	ServiceUtils.callService("UserDataService", "batchGetAttribute", {
		requestFriendIds,
		{
			"commodityDic"
		},
		false
	}, function(result, resp)
		local hasGiftMap = {}

		if not result or not result.status then
			logger:error("CashShopModel:requestFriendShopStatus failed, result=%s, resp=%s", inspect(result), inspect(resp))
			callback(hasGiftMap)

			return
		end

		local results = resp and resp.Results

		if results then
			for _, item in ipairs(results) do
				local friendUid = tostring(item.Uid or "")
				local attr = item.AttributesMap
				local commodityDic = attr and attr.commodityDic

				if requestFriendUidMap[friendUid] and Utils.isTable(commodityDic) and (commodityDic[commodityId] == true or commodityDic[tostring(commodityId)] == true) then
					hasGiftMap[friendUid] = true
				end
			end
		end

		callback(hasGiftMap)
	end, {
		callerId = pg.me.uid
	})
end

return CashShopModel
