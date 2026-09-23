-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\CashShopRedDotUtils.lua

local RedDotConst = require("Const.RedDotConst")
local CashShopConst = require("Const.CashShopConst")
local Const = require("Common.Const.Const")
local MonthCardUtils = require("GameApp.MonthCard.MonthCardUtils")
local ShopmallCommodityData = require("Data.shopmall_commodity_data")
local ShopmallGiftData = require("Data.shopmall_gift_data")
local ClientConst = require("Const.ClientConst")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local ActivityConst = require("Common.Const.ActivityConst")
local BattlePassData = require("Data.event_battlepass_data")
local EventTaskData = require("Data.event_task_data")
local SysConfigData = require("Data.sys_config_data")
local ShopmallTabGroupData = require("Data.shopmall_tab_group_data")
local Utils = require("Common.Utils.Utils")
local TimeUtils = require("Common.Utils.TimeUtils")
local Time = require("Core.Common.Time")
local ClientCashShopUtils = require("Utils.ClientCashShopUtils")
local ClientActivityUtils = require("Utils.ClientActivityUtils")
local ClientUtils = require("Utils.ClientUtils")
local RandomShopGoodsPoolData = require("Data.random_shop_goods_pool_data")
local CashShopRedDotUtils = {}
local RANDOM_SHOP_SLOT_COUNT = 4
local RANDOM_SHOP_REVEAL_DAY_PREFS_KEY = "RandomShopRevealDay_%s"
local RANDOM_SHOP_REVEAL_MASK_PREFS_KEY = "RandomShopRevealMask_%s"

function CashShopRedDotUtils.getCashShopTabRedDotStyle(tabId)
	return CashShopRedDotUtils._getCashShopRedDotStyle(tabId, nil)
end

function CashShopRedDotUtils.getCashShopGroupRedDotStyle(tabId, groupId)
	return CashShopRedDotUtils._getCashShopRedDotStyle(tabId, groupId)
end

function CashShopRedDotUtils.refreshRedDot(tabId, groupId)
	local function refreshGroup(tid, gid)
		local groupPath = string.format(RedDotConst.RedDotPath.CASH_SHOP_GROUP_LIST_ITEM, tid, gid)

		pg.global.refreshRedDotState(groupPath)
	end

	local function refreshTab(tid)
		local tabPath = string.format(RedDotConst.RedDotPath.CASH_SHOP_TAB_LIST_ITEM, tid)

		pg.global.refreshRedDotState(tabPath)
	end

	local function refreshAllGroupsOfTab(tid)
		for gid, gcfg in pairs(ShopmallTabGroupData) do
			if gcfg.tabId == tid then
				refreshGroup(tid, gid)
			end
		end
	end

	if tabId and groupId then
		refreshGroup(tabId, groupId)
		refreshTab(tabId)
	elseif tabId then
		refreshAllGroupsOfTab(tabId)
		refreshTab(tabId)
	else
		for _, tid in pairs(CashShopConst.CategoryType) do
			refreshAllGroupsOfTab(tid)
			refreshTab(tid)
		end
	end

	pg.global.refreshRedDotState(RedDotConst.RedDotPath.CASH_SHOP_TAB_LIST)
	pg.global.refreshRedDotState(RedDotConst.RedDotPath.FUNC_MENU_CASH_SHOP)
	pg.global.refreshRedDotState(RedDotConst.RedDotPath.FUNC_MENU)
end

function CashShopRedDotUtils.refreshGiftPackTabRedDots()
	for _, giftPackTabId in pairs(CashShopConst.GiftPackTabType) do
		local tabPath = string.format(RedDotConst.RedDotPath.CASH_SHOP_GIFTPACK_TAB_LIST_ITEM, giftPackTabId)

		pg.global.refreshRedDotState(tabPath)
	end
end

function CashShopRedDotUtils.getNextGiftPackRefreshTime()
	local currentTime = Time.secondCache
	local nextRefreshTime

	for _, commodityData in pairs(ShopmallCommodityData) do
		local groupData = commodityData and ShopmallTabGroupData[commodityData.tabGroupId]

		if groupData and groupData.tabId == CashShopConst.CategoryType.GIFTPACK then
			local startTime = Utils.getConfigTimeOfArea(commodityData, "startTime")
			local endTime = Utils.getConfigTimeOfArea(commodityData, "endTime")

			if startTime and currentTime < startTime and (not nextRefreshTime or startTime < nextRefreshTime) then
				nextRefreshTime = startTime
			end

			local expireTime = endTime and endTime + 1

			if expireTime and currentTime < expireTime and (not nextRefreshTime or expireTime < nextRefreshTime) then
				nextRefreshTime = expireTime
			end
		end
	end

	return nextRefreshTime
end

function CashShopRedDotUtils.getRandomShopMapValue(map, key)
	if not map then
		return nil
	end

	return map[key] or map[tostring(key)]
end

function CashShopRedDotUtils.isRandomShopGoodsSoldOut(randomShop, slotIndex)
	local hasBuyPos = randomShop and randomShop.hasBuyPos

	if not Utils.isTable(hasBuyPos) then
		return false
	end

	for _, boughtPos in ipairs(hasBuyPos) do
		if tonumber(boughtPos) == tonumber(slotIndex) then
			return true
		end
	end

	return false
end

function CashShopRedDotUtils.getRandomShopRevealMask(shopId)
	local prefsCacheUtils = pg.global and pg.global.prefsCacheUtils

	if not prefsCacheUtils then
		return 0
	end

	local now = tonumber(Time.secondCache)

	if not now or now <= 0 then
		now = Time.getSecond()
	end

	local currentDay = math.floor(TimeUtils.getServerDayBegin(now))
	local dayKey = string.format(RANDOM_SHOP_REVEAL_DAY_PREFS_KEY, tostring(shopId))
	local maskKey = string.format(RANDOM_SHOP_REVEAL_MASK_PREFS_KEY, tostring(shopId))
	local savedDay = prefsCacheUtils:getInt(dayKey, 0, ClientConst.CACHE_TYPE_FLAG.USER)

	if savedDay ~= currentDay then
		return 0
	end

	return tonumber(prefsCacheUtils:getInt(maskKey, 0, ClientConst.CACHE_TYPE_FLAG.USER)) or 0
end

function CashShopRedDotUtils.hasRandomShopUnopenedSlot()
	local shopId = ClientCashShopUtils.getCurrentRandomShop()
	local randomShop = pg.me and pg.me.randomShop

	if not shopId or not randomShop then
		return false
	end

	local serverShopId = randomShop.getShopId and randomShop:getShopId() or randomShop.randomShopBase and randomShop.randomShopBase.shopId

	if tonumber(serverShopId) ~= tonumber(shopId) then
		return false
	end

	local revealMask = CashShopRedDotUtils.getRandomShopRevealMask(shopId)

	for slotIndex = 1, RANDOM_SHOP_SLOT_COUNT do
		local goodId = CashShopRedDotUtils.getRandomShopMapValue(randomShop.goodsList, slotIndex)

		goodId = tonumber(goodId) or goodId

		local slotFlag = 2^(slotIndex - 1)
		local isOpened = math.floor(revealMask / slotFlag) % 2 == 1

		if goodId and RandomShopGoodsPoolData[goodId] and not CashShopRedDotUtils.isRandomShopGoodsSoldOut(randomShop, slotIndex) and not isOpened then
			return true
		end
	end

	return false
end

function CashShopRedDotUtils.getRandomShopAllOpenRedDotStyle()
	return CashShopRedDotUtils.hasRandomShopUnopenedSlot() and RedDotConst.RedDotStyle.POINT or RedDotConst.RedDotStyle.NONE
end

function CashShopRedDotUtils.refreshRandomShopRedDots()
	local tabId = CashShopConst.CategoryType.EXCHANGE
	local groupId = CashShopConst.ExchangeShopTabType.Random
	local allOpenPath = string.format(RedDotConst.RedDotPath.CASH_SHOP_RANDOM_ALL_OPEN, tabId, groupId)

	pg.global.refreshRedDotState(allOpenPath)
	CashShopRedDotUtils.refreshRedDot(tabId, groupId)
end

function CashShopRedDotUtils.getCashShopEntryRedDotStyle()
	local res = RedDotConst.RedDotStyle.NONE
	local curPri = 0

	for _, tabId in pairs(CashShopConst.CategoryType) do
		local style = CashShopRedDotUtils._getCashShopRedDotStyle(tabId, nil)
		local pri = RedDotConst.RedDotStylePriority[style] or 0

		if curPri < pri then
			curPri = pri
			res = style
		end
	end

	return res
end

function CashShopRedDotUtils.getFirstTopupActivityId()
	local isOpen, activityId = ActivityUtils.isOprActivityOpenByType(ActivityConst.EventType.FirstTopup, pg.me)

	if isOpen == true and activityId and activityId > 0 then
		return activityId
	end

	return nil
end

function CashShopRedDotUtils.getFirstTopupRecordKey(activityId)
	if not pg.me or not activityId then
		return nil
	end

	return tostring(pg.me.uid) .. ClientConst.PrefKey.CashShopFirstTopup .. tostring(activityId)
end

function CashShopRedDotUtils.getFirstTopupRedDotStyle()
	local activityId = CashShopRedDotUtils.getFirstTopupActivityId()

	if not activityId then
		return RedDotConst.RedDotStyle.NONE
	end

	local rewardStyle = ClientActivityUtils.getFirstTopupRedDotStyle()

	if rewardStyle == RedDotConst.RedDotStyle.REWARD then
		return rewardStyle
	end

	local recordKey = CashShopRedDotUtils.getFirstTopupRecordKey(activityId)

	if recordKey and pg.global.prefsCacheUtils:getInt(recordKey, 0) == 0 then
		return RedDotConst.RedDotStyle.POINT
	end

	return RedDotConst.RedDotStyle.NONE
end

function CashShopRedDotUtils.markFirstTopupRead()
	local activityId = CashShopRedDotUtils.getFirstTopupActivityId()
	local recordKey = CashShopRedDotUtils.getFirstTopupRecordKey(activityId)

	if not recordKey or pg.global.prefsCacheUtils:getInt(recordKey, 0) ~= 0 then
		return false
	end

	pg.global.prefsCacheUtils:setInt(recordKey, 1)

	return true
end

function CashShopRedDotUtils.refreshFirstTopupRedDots()
	local tabId = CashShopConst.CategoryType.RECOMMEND
	local itemPath = string.format(RedDotConst.RedDotPath.CASH_SHOP_FIRST_TOPUP_ITEM, tabId)

	pg.global.refreshRedDotState(itemPath)
	CashShopRedDotUtils.refreshRedDot(tabId)
end

function CashShopRedDotUtils._getCategoryTypeKey(tabId)
	for k, v in pairs(CashShopConst.CategoryType) do
		if v == tabId then
			return k
		end
	end

	return nil
end

function CashShopRedDotUtils._getCashShopRedDotStyle(tabId, groupId)
	if not tabId then
		return RedDotConst.RedDotStyle.NONE
	end

	local typeKey = CashShopRedDotUtils._getCategoryTypeKey(tabId)

	if not typeKey then
		return RedDotConst.RedDotStyle.NONE
	end

	local getFuncName = "_getCashShop" .. typeKey .. "RedDotStyle"

	if CashShopRedDotUtils[getFuncName] then
		return CashShopRedDotUtils[getFuncName](groupId) or RedDotConst.RedDotStyle.NONE
	end

	return RedDotConst.RedDotStyle.NONE
end

function CashShopRedDotUtils._getCashShopRECOMMENDRedDotStyle()
	return CashShopRedDotUtils.getFirstTopupRedDotStyle()
end

function CashShopRedDotUtils.getCashShopGIFTPACK_DAILY_RedDotStyle()
	for id, cfg in pairs(ShopmallCommodityData) do
		local startTime = Utils.getConfigTimeOfArea(cfg, "startTime")
		local endTime = Utils.getConfigTimeOfArea(cfg, "endTime")
		local showGiftPack = startTime and endTime and TimeUtils.isInRangeTimestamp(startTime, endTime)
		local isAvailable = cfg and cfg.tabGroupId == CashShopConst.GiftPackTabType.Fix and cfg.onSale == 1 and (not ClientCashShopUtils.isCommodityEnabled or ClientCashShopUtils.isCommodityEnabled(id)) and showGiftPack

		if isAvailable then
			local giftData = ShopmallGiftData[cfg.itemId]

			if giftData and giftData.giftPackType == 3 then
				local leftLimit = ClientCashShopUtils.getCommodityLeftLimit(id)

				if leftLimit > 0 then
					return true
				end
			end
		end
	end

	return false
end

function CashShopRedDotUtils.getSeasonGiftPackRecordKey(commodityId)
	return string.format("SeasonGiftPack_%s", tostring(commodityId))
end

function CashShopRedDotUtils.getSeasonGiftPackRefreshVersion(commodityData)
	if not commodityData then
		return 0
	end

	return Utils.getConfigTimeOfArea(commodityData, "startTime") or 0
end

function CashShopRedDotUtils.getWeeklyGiftPackRecordKey(commodityId)
	return string.format("WeeklyGiftPack_%s", tostring(commodityId))
end

function CashShopRedDotUtils.getWeeklyGiftPackRefreshVersion(commodityData)
	if not commodityData then
		return 0
	end

	local startTime = Utils.getConfigTimeOfArea(commodityData, "startTime") or 0
	local weekRefreshTime = pg.me and tonumber(pg.me.lastWeekUpdateTs) or 0

	if weekRefreshTime <= 0 then
		weekRefreshTime = TimeUtils.getAreaWeekBegin(Time.secondCache)
	end

	return math.max(startTime, weekRefreshTime)
end

function CashShopRedDotUtils.isSeasonGiftPackAvailable(commodityId, commodityData)
	local giftData = commodityData and ShopmallGiftData[commodityData.itemId]

	if not commodityData or not giftData or giftData.limitType ~= 1 or commodityData.tabGroupId ~= CashShopConst.GiftPackTabType.Fix or commodityData.onSale ~= 1 or ClientCashShopUtils.isCommodityEnabled and not ClientCashShopUtils.isCommodityEnabled(commodityId) or ClientCashShopUtils.getCommodityLeftLimit(commodityId) <= 0 then
		return false
	end

	local startTime = Utils.getConfigTimeOfArea(commodityData, "startTime")
	local endTime = Utils.getConfigTimeOfArea(commodityData, "endTime")

	return startTime and endTime and TimeUtils.isInRangeTimestamp(startTime, endTime) or false
end

function CashShopRedDotUtils.isSeasonGiftPackNew(commodityId)
	if not pg.me or not pg.me.getRedDotRecord then
		return false
	end

	local commodityData = ShopmallCommodityData[commodityId]

	if not CashShopRedDotUtils.isSeasonGiftPackAvailable(commodityId, commodityData) then
		return false
	end

	local refreshVersion = CashShopRedDotUtils.getSeasonGiftPackRefreshVersion(commodityData)
	local recordKey = CashShopRedDotUtils.getSeasonGiftPackRecordKey(commodityId)
	local viewedVersion = tonumber(pg.me:getRedDotRecord(Const.CLIENT_KEY.EVENT_RED_DOT, recordKey, 0)) or 0

	return viewedVersion < refreshVersion
end

function CashShopRedDotUtils.hasSeasonGiftPackNew()
	for commodityId, commodityData in pairs(ShopmallCommodityData) do
		if CashShopRedDotUtils.isSeasonGiftPackAvailable(commodityId, commodityData) and CashShopRedDotUtils.isSeasonGiftPackNew(commodityId) then
			return true
		end
	end

	return false
end

function CashShopRedDotUtils.getCashShopGIFTPACK_SEASON_RedDotStyle()
	return CashShopRedDotUtils.hasSeasonGiftPackNew() and RedDotConst.RedDotStyle.NEW or RedDotConst.RedDotStyle.NONE
end

function CashShopRedDotUtils.isWeeklyGiftPackAvailable(commodityId, commodityData)
	if not commodityData or commodityData.tabGroupId ~= CashShopConst.GiftPackTabType.Weekly or commodityData.onSale ~= 1 or ClientCashShopUtils.isCommodityEnabled and not ClientCashShopUtils.isCommodityEnabled(commodityId) or ClientCashShopUtils.getCommodityLeftLimit(commodityId) <= 0 then
		return false
	end

	local startTime = Utils.getConfigTimeOfArea(commodityData, "startTime")
	local endTime = Utils.getConfigTimeOfArea(commodityData, "endTime")

	return startTime and endTime and TimeUtils.isInRangeTimestamp(startTime, endTime) or false
end

function CashShopRedDotUtils.isWeeklyGiftPackNew(commodityId)
	if not pg.me or not pg.me.getRedDotRecord then
		return false
	end

	local commodityData = ShopmallCommodityData[commodityId]

	if not CashShopRedDotUtils.isWeeklyGiftPackAvailable(commodityId, commodityData) then
		return false
	end

	local refreshVersion = CashShopRedDotUtils.getWeeklyGiftPackRefreshVersion(commodityData)
	local recordKey = CashShopRedDotUtils.getWeeklyGiftPackRecordKey(commodityId)
	local viewedVersion = tonumber(pg.me:getRedDotRecord(Const.CLIENT_KEY.EVENT_RED_DOT, recordKey, 0)) or 0

	return viewedVersion < refreshVersion
end

function CashShopRedDotUtils.hasWeeklyGiftPackNew()
	for commodityId, commodityData in pairs(ShopmallCommodityData) do
		if CashShopRedDotUtils.isWeeklyGiftPackAvailable(commodityId, commodityData) and CashShopRedDotUtils.isWeeklyGiftPackNew(commodityId) then
			return true
		end
	end

	return false
end

function CashShopRedDotUtils.getCashShopGIFTPACK_WEEKLY_RedDotStyle()
	return CashShopRedDotUtils.hasWeeklyGiftPackNew() and RedDotConst.RedDotStyle.NEW or RedDotConst.RedDotStyle.NONE
end

function CashShopRedDotUtils.getCashShopGIFTPACK_FIX_RedDotStyle()
	if CashShopRedDotUtils.getCashShopGIFTPACK_DAILY_RedDotStyle() then
		return RedDotConst.RedDotStyle.REWARD
	end

	return CashShopRedDotUtils.getCashShopGIFTPACK_SEASON_RedDotStyle()
end

function CashShopRedDotUtils._markSeasonGiftPackRead(commodityId)
	if not pg.me or not pg.me.setRedDotRecord or not CashShopRedDotUtils.isSeasonGiftPackNew(commodityId) then
		return false
	end

	local commodityData = ShopmallCommodityData[commodityId]
	local refreshVersion = CashShopRedDotUtils.getSeasonGiftPackRefreshVersion(commodityData)
	local recordKey = CashShopRedDotUtils.getSeasonGiftPackRecordKey(commodityId)

	return pg.me:setRedDotRecord(Const.CLIENT_KEY.EVENT_RED_DOT, recordKey, refreshVersion)
end

function CashShopRedDotUtils._markWeeklyGiftPackRead(commodityId)
	if not pg.me or not pg.me.setRedDotRecord or not CashShopRedDotUtils.isWeeklyGiftPackNew(commodityId) then
		return false
	end

	local commodityData = ShopmallCommodityData[commodityId]
	local refreshVersion = CashShopRedDotUtils.getWeeklyGiftPackRefreshVersion(commodityData)
	local recordKey = CashShopRedDotUtils.getWeeklyGiftPackRecordKey(commodityId)

	return pg.me:setRedDotRecord(Const.CLIENT_KEY.EVENT_RED_DOT, recordKey, refreshVersion)
end

function CashShopRedDotUtils.markSeasonGiftPackRead(commodityId)
	local success = CashShopRedDotUtils._markSeasonGiftPackRead(commodityId)

	if success then
		CashShopRedDotUtils.refreshGiftPackTabRedDots()
		CashShopRedDotUtils.refreshRedDot(CashShopConst.CategoryType.GIFTPACK)
	end

	return success
end

function CashShopRedDotUtils.markWeeklyGiftPackRead(commodityId)
	local success = CashShopRedDotUtils._markWeeklyGiftPackRead(commodityId)

	if success then
		CashShopRedDotUtils.refreshGiftPackTabRedDots()
		CashShopRedDotUtils.refreshRedDot(CashShopConst.CategoryType.GIFTPACK)
	end

	return success
end

function CashShopRedDotUtils.markGiftPackTabRead(tabId)
	if not pg.me or not tabId then
		return false
	end

	local hasChanged = false

	if tabId == CashShopConst.GiftPackTabType.Optional then
		local recordKey = pg.me.uid .. ClientConst.PrefKey.CashShopGiftPackTab

		if pg.global.prefsCacheUtils:getInt(recordKey, 0) == 0 then
			pg.global.prefsCacheUtils:setInt(recordKey, 1)

			hasChanged = true
		end
	elseif tabId == CashShopConst.GiftPackTabType.Fix then
		for commodityId, commodityData in pairs(ShopmallCommodityData) do
			if commodityData.tabGroupId == tabId and CashShopRedDotUtils._markSeasonGiftPackRead(commodityId) then
				hasChanged = true
			end
		end
	elseif tabId == CashShopConst.GiftPackTabType.Weekly then
		for commodityId, commodityData in pairs(ShopmallCommodityData) do
			if commodityData.tabGroupId == tabId and CashShopRedDotUtils._markWeeklyGiftPackRead(commodityId) then
				hasChanged = true
			end
		end
	end

	if hasChanged then
		CashShopRedDotUtils.refreshGiftPackTabRedDots()
		CashShopRedDotUtils.refreshRedDot(CashShopConst.CategoryType.GIFTPACK)
	end

	return hasChanged
end

function CashShopRedDotUtils.isOptionalGiftPackAvailable()
	for id, cfg in pairs(ShopmallCommodityData) do
		local isEnabled = cfg and cfg.tabGroupId == CashShopConst.GiftPackTabType.Optional and cfg.onSale == 1 and (not ClientCashShopUtils.isCommodityEnabled or ClientCashShopUtils.isCommodityEnabled(id))

		if isEnabled then
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

function CashShopRedDotUtils.getCashShopGIFTPACK_OPTIONAL_RedDotStyle()
	if not CashShopRedDotUtils.isOptionalGiftPackAvailable() then
		return RedDotConst.RedDotStyle.NONE
	end

	local state = pg.global.prefsCacheUtils:getInt(pg.me.uid .. ClientConst.PrefKey.CashShopGiftPackTab, 0)

	return state == 0 and RedDotConst.RedDotStyle.NEW or RedDotConst.RedDotStyle.NONE
end

function CashShopRedDotUtils._getCashShopMONTHLYCARDRedDotStyle(groupId)
	local function monthCardStyle()
		return MonthCardUtils.hasStoredReward() and RedDotConst.RedDotStyle.REWARD or RedDotConst.RedDotStyle.NONE
	end

	local function battlePassStyle()
		return false
	end

	if groupId then
		local cfg = ShopmallTabGroupData[groupId]
		local pageIdx = cfg and cfg.shopType and cfg.shopType - 1

		if pageIdx == CashShopConst.CardShopType.MonthCard then
			return monthCardStyle()
		elseif pageIdx == CashShopConst.CardShopType.BattlePass then
			return battlePassStyle()
		end

		return RedDotConst.RedDotStyle.NONE
	end

	local mc, bp = monthCardStyle(), battlePassStyle()
	local mcPri = RedDotConst.RedDotStylePriority[mc] or 0
	local bpPri = RedDotConst.RedDotStylePriority[bp] or 0

	return bpPri <= mcPri and mc or bp
end

function CashShopRedDotUtils._getCashShopGIFTPACKRedDotStyle(groupId)
	local fixStyle = CashShopRedDotUtils.getCashShopGIFTPACK_FIX_RedDotStyle()
	local optionalStyle = CashShopRedDotUtils.getCashShopGIFTPACK_OPTIONAL_RedDotStyle()
	local weeklyStyle = CashShopRedDotUtils.getCashShopGIFTPACK_WEEKLY_RedDotStyle()

	if groupId == CashShopConst.GiftPackTabType.Fix then
		return fixStyle
	elseif groupId == CashShopConst.GiftPackTabType.Optional then
		return optionalStyle
	elseif groupId == CashShopConst.GiftPackTabType.Weekly then
		return weeklyStyle
	elseif groupId then
		return RedDotConst.RedDotStyle.NONE
	end

	local styleList = {
		fixStyle,
		optionalStyle,
		weeklyStyle
	}

	return pg.global.calculateRedDotPriority(styleList)
end

function CashShopRedDotUtils._getCashShopEXCHANGERedDotStyle(groupId)
	if groupId and groupId ~= CashShopConst.ExchangeShopTabType.Random then
		return RedDotConst.RedDotStyle.NONE
	end

	return CashShopRedDotUtils.getRandomShopAllOpenRedDotStyle()
end

local function getBpContext()
	local actData = ActivityUtils.getActivityData(pg.me, ActivityConst.EventType.BattlePass)

	if not actData then
		return nil, nil
	end

	local phase = actData.activityBase and actData.activityBase.activityPhase

	return actData, phase and BattlePassData[phase]
end

local function hasClaimableInGroup(groupId)
	if not groupId then
		return false
	end

	for _, taskId in ipairs(ActivityUtils.getActTaskIdsByGroupId(groupId)) do
		if ActivityUtils.getActTaskState(pg.me, taskId) == ActivityConst.TaskState.Finihed_CanRecv then
			return true
		end
	end

	return false
end

function CashShopRedDotUtils._isTaskInTimeRange(cfg)
	if cfg == nil then
		return false
	end

	local startTs = Utils.getConfigTimeOfArea(cfg, "taskStartDayTime")
	local endTs = Utils.getConfigTimeOfArea(cfg, "taskEndDayTime")

	if startTs == nil and endTs == nil then
		return true
	end

	local now = Time.secondCache

	if startTs ~= nil and now < startTs then
		return false
	end

	if endTs ~= nil and endTs <= now then
		return false
	end

	return true
end

function CashShopRedDotUtils._isPrevTaskFinished(prevTaskId)
	if prevTaskId == nil then
		return true
	end

	local state = ActivityUtils.getActTaskState(pg.me, prevTaskId)

	if state == nil then
		return false
	end

	return state >= ActivityConst.TaskState.Received
end

local function hasClaimableVisibleInGroup(groupId)
	if not groupId then
		return false
	end

	for _, taskId in ipairs(ActivityUtils.getActTaskIdsByGroupId(groupId)) do
		local cfg = EventTaskData[taskId]

		if cfg and CashShopRedDotUtils._isTaskInTimeRange(cfg) and (cfg.specialCondition == nil or ClientUtils.checkCondition(cfg.specialCondition)) and CashShopRedDotUtils._isPrevTaskFinished(cfg.preTaskId) and ActivityUtils.getActTaskState(pg.me, taskId) == ActivityConst.TaskState.Finihed_CanRecv then
			return true
		end
	end

	return false
end

local function getCurrentWeekTaskGroupId(actData, bpData)
	local weeklyNum = actData and actData.weeklyNum or 0
	local weekGroups = bpData and bpData.weekTaskGroupId

	return weekGroups and weekGroups[weeklyNum]
end

local function getBattlePassMaxLevel(bpData)
	if not bpData or not bpData.awardTaskGroupId then
		return 0
	end

	local freeCount = 0
	local payCount = 0

	for _, taskId in ipairs(ActivityUtils.getActTaskIdsByGroupId(bpData.awardTaskGroupId)) do
		local cfg = EventTaskData[taskId]

		if cfg then
			if cfg.actTaskType == ActivityConst.ActivityTaskType.BattlePass_AwardFree then
				freeCount = freeCount + 1
			elseif cfg.actTaskType == ActivityConst.ActivityTaskType.BattlePass_AwardPay then
				payCount = payCount + 1
			end
		end
	end

	return math.max(freeCount, payCount)
end

function CashShopRedDotUtils.isBattlePassMaxLevel()
	local actData, bpData = getBpContext()

	if not actData or not bpData then
		return false
	end

	if actData.unlockCycleReward == 1 then
		return false
	end

	local maxLevel = getBattlePassMaxLevel(bpData)

	return maxLevel > 0 and maxLevel <= (actData.bpLevel or 0)
end

function CashShopRedDotUtils.hasClaimableAwardTask()
	local actData, bpData = getBpContext()

	if actData and actData.unlockCycleReward == 1 then
		local firstCycleLevel = (SysConfigData.BATTLE_PASS_LEVEL_UP_MAX or 0) + 1
		local lastCycleLevel = math.min(actData.bpLevel or 0, actData.cycleRewardShowMaxlv or 0)

		for level = firstCycleLevel, lastCycleLevel do
			local freeState, payState = actData:getCycleRewardState(level)

			if freeState == ActivityConst.TaskState.Finihed_CanRecv or payState == ActivityConst.TaskState.Finihed_CanRecv then
				return true
			end
		end

		return false
	end

	return bpData and hasClaimableInGroup(bpData.awardTaskGroupId) or false
end

function CashShopRedDotUtils.hasClaimableWeeklyTask()
	if CashShopRedDotUtils.isBattlePassMaxLevel() then
		return false
	end

	local actData, bpData = getBpContext()

	return bpData and hasClaimableVisibleInGroup(getCurrentWeekTaskGroupId(actData, bpData)) or false
end

function CashShopRedDotUtils.hasClaimableSeasonTask()
	if CashShopRedDotUtils.isBattlePassMaxLevel() then
		return false
	end

	local _, bpData = getBpContext()

	return bpData and hasClaimableVisibleInGroup(bpData.seasonTaskGroupId) or false
end

function CashShopRedDotUtils.hasClaimableTask()
	return CashShopRedDotUtils.hasClaimableWeeklyTask() or CashShopRedDotUtils.hasClaimableSeasonTask()
end

function CashShopRedDotUtils.getAwardTabRedDotStyle()
	return CashShopRedDotUtils.hasClaimableAwardTask() and RedDotConst.RedDotStyle.POINT or RedDotConst.RedDotStyle.NONE
end

function CashShopRedDotUtils.getTaskTabRedDotStyle()
	return CashShopRedDotUtils.hasClaimableTask() and RedDotConst.RedDotStyle.POINT or RedDotConst.RedDotStyle.NONE
end

function CashShopRedDotUtils.getWeeklyTaskTabRedDotStyle()
	return CashShopRedDotUtils.hasClaimableWeeklyTask() and RedDotConst.RedDotStyle.POINT or RedDotConst.RedDotStyle.NONE
end

function CashShopRedDotUtils.getSeasonTaskTabRedDotStyle()
	return CashShopRedDotUtils.hasClaimableSeasonTask() and RedDotConst.RedDotStyle.POINT or RedDotConst.RedDotStyle.NONE
end

function CashShopRedDotUtils.getBattlePassHudRedDotStyle()
	if CashShopRedDotUtils.hasClaimableAwardTask() then
		return RedDotConst.RedDotStyle.REWARD
	end

	if CashShopRedDotUtils.hasClaimableTask() then
		return RedDotConst.RedDotStyle.POINT
	end

	return RedDotConst.RedDotStyle.NONE
end

function CashShopRedDotUtils.refreshBattlePassRedDots()
	pg.global.refreshRedDotState(RedDotConst.RedDotPath.BATTLEPASS_AWARD_TAB)
	pg.global.refreshRedDotState(RedDotConst.RedDotPath.BATTLEPASS_TASK_TAB)
	pg.global.refreshRedDotState(RedDotConst.RedDotPath.BATTLEPASS_TASK_WEEK_TAB)
	pg.global.refreshRedDotState(RedDotConst.RedDotPath.BATTLEPASS_TASK_SEASON_TAB)
	pg.global.refreshRedDotState(RedDotConst.RedDotPath.FUNC_MENU_BATTLEPASS)
	pg.global.refreshRedDotState(RedDotConst.RedDotPath.SEASON_LOBBY_BATTLEPASS)
end

return CashShopRedDotUtils
