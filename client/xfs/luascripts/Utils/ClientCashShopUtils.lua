-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\ClientCashShopUtils.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("ClientCashShopUtils")
local MessageName = require("Const.MessageName")
local ClientUtils = require("Utils.ClientUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local NoticeDef = require("Common.NoticeDef")
local UIConst = require("Const.UIConst")
local TimeUtils = require("Common.Utils.TimeUtils")
local Utils = require("Common.Utils.Utils")
local ActivityConst = require("Common.Const.ActivityConst")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local MonthCardUtils = require("GameApp.MonthCard.MonthCardUtils")
local RechargeUtils = require("GameApp.Recharge.RechargeUtils")
local ItemConst = require("Common.Const.ItemConst")
local RechargeConst = require("GameApp.Recharge.RechargeConst")
local CashShopConst = require("Const.CashShopConst")
local Const = require("Common.Const.Const")
local Time = require("Core.Common.Time")
local TriggerUtils = require("Common.Utils.TriggerUtils")
local CommonSwitch = require("Common.CommonSwitch")
local ItemPropUIUtils = require("Utils.ItemPropUIUtils")
local COMMODITY_STATE = {
	POSSESS = 1,
	NORMAL = 0,
	FREE = 5,
	NOTENOUGH = 4,
	SOLDOUT = 3,
	LOCKED = 2
}
local COMMODITY_STATE_TEXT_KEY = {
	[COMMODITY_STATE.POSSESS] = "COMMODITY_STATE_POSSESS",
	[COMMODITY_STATE.LOCKED] = "COMMODITY_STATE_LOCKED",
	[COMMODITY_STATE.SOLDOUT] = "COMMODITY_STATE_SOLDOUT"
}
local COMMODITY_NORMAL_DISPLAY_STATE = {
	[COMMODITY_STATE.NORMAL] = true,
	[COMMODITY_STATE.NOTENOUGH] = true,
	[COMMODITY_STATE.FREE] = true
}
local CommodityData = require("Data.shopmall_commodity_data")
local ItemData = require("Data.item_data")
local AppearanceData = require("Data.appearance_data")
local AppearanceJewelryPetData = require("Data.appearance_jewelry_pet_data")
local AppearanceSuitData = require("Data.appearance_suit_data")
local AvatarHairSuitData = require("Data.avatar_hair_suit_data")
local AppearanceMakeupPresetData = require("Data.appearance_makeup_preset_data")
local GachaEntryData = require("Data.gacha_entry_data")
local ShopConstantData = require("Data.shopmall_constant_data")
local ItemTypeShowData = require("Data.item_type_show_data")
local ShopmallTabGroupData = require("Data.shopmall_tab_group_data")
local ShopMallAppearance = require("Data.shopmall_appearance")
local ShopMallPetAppearance = require("Data.shopmall_pet_appearance")
local RandomShopData = require("Data.random_shop_data")
local ShopMallGiftData = require("Data.shopmall_gift_data")
local ItemConditionConvertData = require("Data.item_condition_convert_data")
local BattlePassData = require("Data.event_battlepass_data")
local AttributeEntryData = require("Data.attribute_entry_data")
local RechargeData = require("Data.shopmall_recharge_data")
local AvatarPresetData = require("Data.avatar_preset_data")
local ShopMallCommodityTabData = require("Data.shopmall_commodity_tab_data")
local ItemUtils = require("Common.Utils.ItemUtils")
local ShopCommonHelper = require("Utils.ShopCommonHelper")
local CONDITION_FEMALE = 7
local CONDITION_MALE = 6
local BODY_FEMALE = 11
local BODY_MALE = 21
local RANDOM_SHOP_TIME_PATTERN = "(%d+)/(%d+)/(%d+)/(%d+):(%d+):(%d+)"
local GIFT_PACK_TAB_ID = 3
local ClientCashShopUtils = {}

ClientCashShopUtils.DEFAULT_MAX_BUY_COUNT = 99
ClientCashShopUtils.onPaymentJump = nil
ClientCashShopUtils.onExchangeConfirmOpen = nil

local _pendingGiveRequest, _appearanceToCommodityIdsCache, _appearanceCommodityCacheVersion, _appearanceToDrawIdsCache, _appearanceDrawIdCacheVersion

function ClientCashShopUtils.renderItemInfoPurchase(button, data)
	if IsNil(button) or not data or data.validate and not data.validate() then
		return
	end

	local objectReference = button:GetComponent("ObjectReference")
	local pbPropInfoNumSelector = objectReference:GetRefValue("pbPropInfoNumSelector")
	local textUnlockUWidget = objectReference:GetRefValue("textUnlockUWidget")
	local txtLock = objectReference:GetRefValue("txtLock")
	local btnPurchaseUButton = objectReference:GetRefValue("btnPurchaseUButton")
	local limitInfoUButton = objectReference:GetRefValue("limitInfoUButton")
	local coinBoxUWidget = objectReference:GetRefValue("coinBoxUWidget")
	local listCoinsUList = objectReference:GetRefValue("listCoinsUList")
	local consumeUWidget = objectReference:GetRefValue("consumeUWidget")
	local listItemsUList = objectReference:GetRefValue("listItemsUList")

	button.luaClick = data.onPurchaseClick and function(clickButton, clickData)
		if data.validate and not data.validate() then
			return
		end

		data.onPurchaseClick(clickButton, clickData)
	end or nil

	local minCount = data.minCount or 1
	local maxCount = data.maxCount or 0
	local maxValue = math.max(minCount, maxCount)
	local buyCount = math.max(minCount, math.min(data.buyCount or minCount, maxValue))

	pbPropInfoNumSelector.luaValueChanged = nil
	pbPropInfoNumSelector.maxValue = maxValue
	pbPropInfoNumSelector.value = buyCount

	LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(pbPropInfoNumSelector, minCount < maxCount)

	function pbPropInfoNumSelector.luaValueChanged(value)
		if data.validate and not data.validate() then
			return
		end

		if data.onCountChanged then
			data.onCountChanged(value)
		end
	end

	local itemCost = data.itemCost or {}

	LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(consumeUWidget, #itemCost > 0)

	function listItemsUList.luaRenderItem(itemButton, _, itemData)
		LuaUIUtils.renderItemWithCountCheck(itemButton, itemData, function(numText)
			local ownCount = data.getCostItemOwnCount and data.getCostItemOwnCount(itemData.id) or 0

			LuaUIUtils.renderConsumeText(numText, ownCount, itemData.num, 1)
		end, true)
	end

	listItemsUList:SetList(itemCost)

	local coinCost = data.coinCost or {}
	local showCoinList = #coinCost > 0

	LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(coinBoxUWidget, showCoinList)

	if showCoinList then
		local coinIsIncome = data.coinIsIncome == true

		ItemPropUIUtils.renderConsumeItemList(listCoinsUList, coinCost, false, nil, coinIsIncome, true, true, data.useShortCoinCost == true)
	end

	local stateData = ClientCashShopUtils.getCommodityStateData(data)
	local state = data.commodityState or ClientCashShopUtils.getCommodityStateByNormalizedData(stateData)

	if data.isLocked then
		state = COMMODITY_STATE.LOCKED
	elseif data.isSellOut then
		state = COMMODITY_STATE.SOLDOUT
	end

	local isNormalDisplayState = COMMODITY_NORMAL_DISPLAY_STATE[state] == true
	local showStateText = not isNormalDisplayState
	local showLimit = data.hasLimit and isNormalDisplayState
	local lockText = ""

	if showLimit then
		local limitCountText = string.format("%d/%d", data.limitLeft or 0, data.limitTotal or 0)
		local limitTitle = string.gsub(data.limitTitle or "", ":$", "")

		limitTitle = string.gsub(limitTitle, "：$", "")

		if limitTitle ~= "" then
			lockText = string.format("%s： %s", limitTitle, limitCountText)
		else
			lockText = limitCountText
		end
	elseif showStateText then
		local stateTextKey = COMMODITY_STATE_TEXT_KEY[state]

		lockText = stateTextKey and pg.getGameString(stateTextKey) or ""
	end

	LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(textUnlockUWidget, showStateText or showLimit)
	ClientTextUtils.setText(txtLock, lockText)

	local showLimitInfo = showLimit and data.limitDesc ~= nil

	if limitInfoUButton then
		LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(limitInfoUButton, showLimitInfo)

		limitInfoUButton.luaRenderTooltip = nil

		if showLimitInfo then
			function limitInfoUButton.luaRenderTooltip(_, tooltip)
				local tooltipObjectReference = tooltip:GetComponent("ObjectReference")
				local txtNameUSDFText = tooltipObjectReference:GetRefValue("txtNameUSDFText")

				ClientTextUtils.setText(txtNameUSDFText, pg.getLocalizationText(data.limitDesc))
			end
		end
	end

	local buttonObjectReference = btnPurchaseUButton.transform:GetComponent("ObjectReference")
	local btnText = buttonObjectReference:GetRefValue("txtNameUText")

	if state == COMMODITY_STATE.SOLDOUT then
		LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(btnPurchaseUButton, false)

		btnPurchaseUButton.interactable = false
		btnPurchaseUButton.luaClick = nil
	elseif data.sourceButtonText and data.onSourceClick then
		LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(btnPurchaseUButton, true)

		btnPurchaseUButton.interactable = true

		ClientTextUtils.setText(btnText, data.sourceButtonText)

		function btnPurchaseUButton.luaClick(clickButton, clickData)
			if data.validate and not data.validate() then
				return
			end

			data.onSourceClick(clickButton, clickData)
		end

		btnPurchaseUButton:TryChangePage("Type", 0)
	else
		LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(btnPurchaseUButton, not data.isLocked)

		btnPurchaseUButton.interactable = data.confirmInteractable ~= false

		ClientTextUtils.setText(btnText, data.confirmButtonText or pg.getGameString("SHOP_BUY"))

		btnPurchaseUButton.luaClick = data.onConfirm and function(clickButton, clickData)
			if data.validate and not data.validate() then
				return
			end

			data.onConfirm(clickButton, clickData)
		end or nil

		btnPurchaseUButton:TryChangePage("Type", 5)
	end

	if data.onRendered then
		data.onRendered(button, buyCount)
	end
end

function ClientCashShopUtils.isCommodityInDiscount(commodityInfo)
	if not commodityInfo then
		return false
	end

	local specialStartTime = Utils.getConfigTimeOfArea(commodityInfo, "specialStartTime")
	local specialEndTime = Utils.getConfigTimeOfArea(commodityInfo, "specialEndTime")

	return specialStartTime and specialEndTime and TimeUtils.isInRangeTimestamp(specialStartTime, specialEndTime)
end

function ClientCashShopUtils.getCommodityLevelCount(commodityId)
	return pg.me and pg.me.shopMallLevelCounts and pg.me.shopMallLevelCounts[commodityId] or 0
end

function ClientCashShopUtils.getCommodityLimitBoughtCount(commodityId)
	local commodityInfo = ClientCashShopUtils.getCommodityData(commodityId)

	if commodityInfo and commodityInfo.limitType == Const.LIMIT_SCENE then
		local curSceneId = pg.me and pg.me.space and pg.me.space.sceneId or 0

		if ShopCommonHelper.isHitSceneLimit(commodityInfo, curSceneId) then
			return pg.me and pg.me.shopMallSceneLimitCounts and pg.me.shopMallSceneLimitCounts[commodityId] or 0
		end

		return 0
	end

	return pg.me and pg.me.shopMallLimitCounts and pg.me.shopMallLimitCounts[commodityId] or 0
end

function ClientCashShopUtils.genMallCostIdNums(costs)
	local costIdNums = {}

	for _, costItem in ipairs(costs or EMPTY_TABLE) do
		costIdNums[costItem.itemId] = (costIdNums[costItem.itemId] or 0) + (costItem.totalPrice or 0)
	end

	return costIdNums
end

function ClientCashShopUtils.adjustMallCostIdNums(costIdNums)
	local adjusted = {}

	for itemId, itemNum in pairs(costIdNums or EMPTY_TABLE) do
		adjusted[itemId] = itemNum
	end

	local needCoinBound = adjusted[ItemConst.ITEM_SPECIAL_MONEY_COIN_BOUND] or 0

	if needCoinBound > 0 then
		local ownCoinBound = ClientUtils.getItemCountById(ItemConst.ITEM_SPECIAL_MONEY_COIN_BOUND) or 0

		if ownCoinBound < needCoinBound then
			local deficit = needCoinBound - ownCoinBound
			local ownCashBound = ClientUtils.getItemCountById(ItemConst.ITEM_SPECIAL_MONEY_CASH_BOUND) or 0

			if ownCashBound < deficit then
				return false, adjusted
			end

			if ownCoinBound > 0 then
				adjusted[ItemConst.ITEM_SPECIAL_MONEY_COIN_BOUND] = ownCoinBound
			else
				adjusted[ItemConst.ITEM_SPECIAL_MONEY_COIN_BOUND] = nil
			end

			adjusted[ItemConst.ITEM_SPECIAL_MONEY_CASH_BOUND] = (adjusted[ItemConst.ITEM_SPECIAL_MONEY_CASH_BOUND] or 0) + deficit
		end
	end

	return true, adjusted
end

function ClientCashShopUtils.canAffordCostIdNums(costIdNums)
	local canAdjust, adjustedCostIdNums = ClientCashShopUtils.adjustMallCostIdNums(costIdNums)

	if not canAdjust then
		return false, adjustedCostIdNums
	end

	for itemId, itemNum in pairs(adjustedCostIdNums or EMPTY_TABLE) do
		local ownNum = ClientUtils.getItemCountById(itemId) or 0

		if ownNum < itemNum then
			return false, adjustedCostIdNums
		end
	end

	return true, adjustedCostIdNums
end

function ClientCashShopUtils.getNotEnoughCostItemId(costIdNums)
	for itemId, itemNum in pairs(costIdNums or EMPTY_TABLE) do
		local ownNum = ClientUtils.getItemCountById(itemId) or 0

		if ownNum < itemNum then
			return itemId
		end
	end
end

function ClientCashShopUtils.showCommodityPriceCalcError(errorCode)
	ClientUtils.showBubbleMessage(errorCode or NoticeDef.SHOP_CONFIG_PARAM_ERROR)
end

function ClientCashShopUtils.shouldUseCommodityLevelCost(commodityId, commodityInfo, options)
	if not commodityInfo or not commodityInfo.levelCost or Utils.checkShopMallCommodityFree(commodityId) then
		return false
	end

	if options and options.forGive then
		local tabId = ShopMallCommodityTabData[commodityId] or 0

		if tabId == Const.ShopMallTabType.Tab_Avater then
			return false
		end
	end

	return true
end

function ClientCashShopUtils.getSequenceValue(list, index)
	if list == nil or index == nil then
		return nil
	end

	return list[index] or list[tostring(index)]
end

function ClientCashShopUtils.toNumberOrDefault(value, defaultValue)
	local numberValue = tonumber(value)

	if numberValue ~= nil then
		return numberValue
	end

	return defaultValue
end

function ClientCashShopUtils.normalizeCostEntry(costEntry)
	if not costEntry then
		return nil, nil
	end

	local currencyId = ClientCashShopUtils.toNumberOrDefault(ClientCashShopUtils.getSequenceValue(costEntry, 1), ClientCashShopUtils.getSequenceValue(costEntry, 1))
	local amount = ClientCashShopUtils.toNumberOrDefault(ClientCashShopUtils.getSequenceValue(costEntry, 2), ClientCashShopUtils.getSequenceValue(costEntry, 2))

	return currencyId, amount
end

function ClientCashShopUtils.isSuitType(avatarType)
	local suitNumber = ShopConstantData.Suit and tonumber(ShopConstantData.Suit.number) or 0

	return ClientCashShopUtils.toNumberOrDefault(avatarType, avatarType) == suitNumber
end

function ClientCashShopUtils.getPlayerGender()
	local presetKey = pg.game.avatar and pg.game.avatar:getPresetKey(pg.me)
	local presetData = presetKey and pg.game.avatar:getAvatarPresetData(presetKey) or nil

	return presetData and presetData.body or BODY_FEMALE
end

function ClientCashShopUtils.getCommodityBannerByGender(commodityConfig, gender)
	if not Utils.isTable(commodityConfig) then
		return nil
	end

	local targetGender = gender or ClientCashShopUtils.getPlayerGender()

	if targetGender == BODY_MALE and not string.isNilOrEmpty(commodityConfig.bannerBoy) then
		return commodityConfig.bannerBoy
	end

	return not string.isNilOrEmpty(commodityConfig.banner) and commodityConfig.banner or nil
end

function ClientCashShopUtils.isItemMatchGender(itemId, gender)
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

function ClientCashShopUtils.getGenderConvertedItemId(itemId, gender)
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

function ClientCashShopUtils.getSuitAppearanceItems(itemId, gender)
	if not itemId then
		return nil
	end

	local targetGender = gender or ClientCashShopUtils.getPlayerGender()
	local convertedId = ClientCashShopUtils.getGenderConvertedItemId(itemId, targetGender) or itemId
	local suitData = AppearanceSuitData[convertedId] or AppearanceSuitData[itemId]

	if not suitData or not suitData.appearanceList and not suitData.jewelryList and not suitData.hair then
		return nil
	end

	local items = {}

	if suitData.appearanceList then
		for _, appearanceId in ipairs(suitData.appearanceList) do
			items[#items + 1] = {
				num = 1,
				id = appearanceId
			}
		end
	end

	if suitData.jewelryList then
		for _, jewelryId in ipairs(suitData.jewelryList) do
			items[#items + 1] = {
				num = 1,
				id = jewelryId
			}
		end
	end

	if suitData.hair and suitData.hair > 0 then
		items[#items + 1] = {
			num = 1,
			id = suitData.hair
		}
	end

	return items
end

local function appendAppearanceItem(items, seen, itemId, num)
	if not itemId or itemId <= 0 or seen[itemId] then
		return
	end

	if not AppearanceData[itemId] and not AppearanceJewelryPetData[itemId] then
		return
	end

	seen[itemId] = true
	items[#items + 1] = {
		id = itemId,
		num = num or 1
	}
end

function ClientCashShopUtils.getAppearanceItemsByCommodityId(commodityId, gender)
	local commodityInfo = ClientCashShopUtils.getCommodityData(commodityId)

	if not commodityInfo or not commodityInfo.itemId then
		return nil
	end

	local itemId = commodityInfo.itemId
	local targetGender = gender or ClientCashShopUtils.getPlayerGender()
	local suitItems = ClientCashShopUtils.getSuitAppearanceItems(itemId, targetGender)

	if suitItems and #suitItems > 0 then
		return suitItems
	end

	local convertedItemId = ClientCashShopUtils.getGenderConvertedItemId(itemId, targetGender) or itemId
	local mappedInfo = ShopMallAppearance[convertedItemId] or ShopMallAppearance[itemId]
	local petAppearanceId = ShopMallPetAppearance[convertedItemId] or ShopMallPetAppearance[itemId]
	local items = {}
	local seen = {}

	appendAppearanceItem(items, seen, convertedItemId, commodityInfo.num)

	if mappedInfo then
		local playerAppearanceId = mappedInfo[1]

		if playerAppearanceId then
			playerAppearanceId = ClientCashShopUtils.getGenderConvertedItemId(playerAppearanceId, targetGender) or playerAppearanceId

			appendAppearanceItem(items, seen, playerAppearanceId, commodityInfo.num)
		end

		appendAppearanceItem(items, seen, mappedInfo[2], commodityInfo.num)
	end

	appendAppearanceItem(items, seen, petAppearanceId, commodityInfo.num)

	return #items > 0 and items or nil
end

function ClientCashShopUtils.getAppearanceItemIdsByCommodityId(commodityId, gender)
	local items = ClientCashShopUtils.getAppearanceItemsByCommodityId(commodityId, gender)

	if not items then
		return nil
	end

	local itemIds = {}

	for _, item in ipairs(items) do
		itemIds[#itemIds + 1] = item.id
	end

	return itemIds
end

local function getAppearanceCommodityCacheVersion()
	return string.format("%s_%s_%s_%s_%s_%s_%s_%s_%s_%s_%s", tostring(CommodityData), tostring(AppearanceData), tostring(AppearanceJewelryPetData), tostring(AppearanceSuitData), tostring(AvatarHairSuitData), tostring(ShopMallAppearance), tostring(ShopMallPetAppearance), tostring(ItemConditionConvertData), tostring(ShopMallGiftData), tostring(ShopmallTabGroupData), tostring(AppearanceMakeupPresetData))
end

local function appendCommodityId(cache, appearanceId, commodityId)
	appearanceId = tonumber(appearanceId)

	if not appearanceId or appearanceId <= 0 or not commodityId then
		return
	end

	local commodityIds = cache[appearanceId]

	if not commodityIds then
		commodityIds = {}
		cache[appearanceId] = commodityIds
	else
		for _, id in ipairs(commodityIds) do
			if id == commodityId then
				return
			end
		end
	end

	commodityIds[#commodityIds + 1] = commodityId
end

local function isAppearanceRelatedId(id)
	return AppearanceData[id] ~= nil or AppearanceJewelryPetData[id] ~= nil or AppearanceSuitData[id] ~= nil or AvatarHairSuitData[id] ~= nil or AppearanceMakeupPresetData[id] ~= nil
end

local function buildGenderVariantMap()
	local variantMap = {}

	local function bindVariant(a, b)
		a = tonumber(a)
		b = tonumber(b)

		if not a or not b or a <= 0 or b <= 0 then
			return
		end

		variantMap[a] = variantMap[a] or {
			[a] = true
		}
		variantMap[b] = variantMap[b] or {
			[b] = true
		}
		variantMap[a][b] = true
		variantMap[b][a] = true
	end

	for itemId, convertData in pairs(ItemConditionConvertData) do
		itemId = tonumber(itemId)

		if itemId and itemId > 0 then
			variantMap[itemId] = variantMap[itemId] or {
				[itemId] = true
			}

			if convertData.targetItem then
				for _, entry in ipairs(convertData.targetItem) do
					local condition = entry[1]

					if condition == CONDITION_FEMALE or condition == CONDITION_MALE then
						bindVariant(itemId, entry[2])
					end
				end
			end
		end
	end

	return variantMap
end

local function appendAppearanceRelatedWithVariants(cache, variantMap, appearanceId, commodityId)
	appearanceId = tonumber(appearanceId)

	if not appearanceId or appearanceId <= 0 then
		return
	end

	local variants = variantMap[appearanceId]

	if variants then
		for variantId in pairs(variants) do
			if isAppearanceRelatedId(variantId) then
				appendCommodityId(cache, variantId, commodityId)
			end
		end
	elseif isAppearanceRelatedId(appearanceId) then
		appendCommodityId(cache, appearanceId, commodityId)
	end
end

local function appendHairSuitMappings(cache, variantMap, hairSuitId, commodityId)
	local hairSuitData = AvatarHairSuitData[hairSuitId]

	if not hairSuitData then
		return
	end

	appendAppearanceRelatedWithVariants(cache, variantMap, hairSuitId, commodityId)

	for _, partId in ipairs(hairSuitData.appearanceList or EMPTY_TABLE) do
		appendAppearanceRelatedWithVariants(cache, variantMap, partId, commodityId)
	end
end

local function appendMakeupSuitMappings(cache, variantMap, makeupSuitId, commodityId)
	local suitData = AppearanceMakeupPresetData[makeupSuitId]

	if not suitData or not suitData.makeupList then
		return
	end

	appendAppearanceRelatedWithVariants(cache, variantMap, makeupSuitId, commodityId)
end

local function appendAppearanceSuitMappings(cache, variantMap, suitId, commodityId)
	local suitData = AppearanceSuitData[suitId]

	if not suitData then
		return
	end

	appendAppearanceRelatedWithVariants(cache, variantMap, suitId, commodityId)

	for _, appearanceId in ipairs(suitData.appearanceList or EMPTY_TABLE) do
		appendAppearanceRelatedWithVariants(cache, variantMap, appearanceId, commodityId)
	end

	for _, jewelryId in ipairs(suitData.jewelryList or EMPTY_TABLE) do
		appendAppearanceRelatedWithVariants(cache, variantMap, jewelryId, commodityId)
	end

	if suitData.hair and suitData.hair > 0 then
		appendAppearanceRelatedWithVariants(cache, variantMap, suitData.hair, commodityId)
		appendHairSuitMappings(cache, variantMap, suitData.hair, commodityId)
	end
end

local function appendShopMallAppearanceMappings(cache, variantMap, shopItemId, commodityId)
	local mappedInfo = ShopMallAppearance[shopItemId]

	if not mappedInfo then
		return
	end

	for _, appearanceId in pairs(mappedInfo) do
		appendAppearanceRelatedWithVariants(cache, variantMap, appearanceId, commodityId)
	end
end

local function appendShopMallPetAppearanceMappings(cache, variantMap, shopItemId, commodityId)
	local mappedInfo = ShopMallPetAppearance[shopItemId]

	if not mappedInfo then
		return
	end

	if type(mappedInfo) == "table" then
		for _, appearanceId in pairs(mappedInfo) do
			appendAppearanceRelatedWithVariants(cache, variantMap, appearanceId, commodityId)
		end
	else
		appendAppearanceRelatedWithVariants(cache, variantMap, mappedInfo, commodityId)
	end
end

local function getCommodityAppearanceLookupItemIds(itemId)
	local itemIds = {}

	local function appendItemId(id)
		id = tonumber(id)

		if id and id > 0 then
			itemIds[id] = true
		end
	end

	local function appendItemAndGenderVariants(id)
		appendItemId(id)
		appendItemId(ClientCashShopUtils.getGenderConvertedItemId(id, BODY_FEMALE))
		appendItemId(ClientCashShopUtils.getGenderConvertedItemId(id, BODY_MALE))
	end

	appendItemAndGenderVariants(itemId)

	local giftData = ShopMallGiftData[tonumber(itemId) or itemId]

	if giftData then
		for _, itemInfo in ipairs(giftData.FixItems or EMPTY_TABLE) do
			appendItemAndGenderVariants(itemInfo[1])
		end

		for _, selectGroup in ipairs(giftData.selectItems or EMPTY_TABLE) do
			for _, itemInfo in ipairs(selectGroup or EMPTY_TABLE) do
				appendItemAndGenderVariants(itemInfo[1])
			end
		end
	end

	return itemIds
end

local function isGiftPackCommodity(commodityInfo)
	if not commodityInfo or not commodityInfo.tabGroupId then
		return false
	end

	local tabGroupData = ShopmallTabGroupData[commodityInfo.tabGroupId]

	return tabGroupData ~= nil and tabGroupData.tabId == GIFT_PACK_TAB_ID
end

local function collectGiftPackItemIds(giftData)
	local itemIds = {}

	if not giftData then
		return itemIds
	end

	local function appendItemId(id)
		id = tonumber(id)

		if id and id > 0 then
			itemIds[id] = true
		end
	end

	for _, item in ipairs(giftData.FixItems or EMPTY_TABLE) do
		appendItemId(item[1])
	end

	for _, optionGroup in ipairs(giftData.selectItems or EMPTY_TABLE) do
		for _, item in ipairs(optionGroup) do
			appendItemId(item[1])
		end
	end

	return itemIds
end

local function appendCommodityItemAppearanceMappings(cache, variantMap, itemId, commodityId)
	for lookupItemId in pairs(getCommodityAppearanceLookupItemIds(itemId)) do
		appendAppearanceRelatedWithVariants(cache, variantMap, lookupItemId, commodityId)
		appendAppearanceSuitMappings(cache, variantMap, lookupItemId, commodityId)
		appendHairSuitMappings(cache, variantMap, lookupItemId, commodityId)
		appendMakeupSuitMappings(cache, variantMap, lookupItemId, commodityId)
		appendShopMallAppearanceMappings(cache, variantMap, lookupItemId, commodityId)
		appendShopMallPetAppearanceMappings(cache, variantMap, lookupItemId, commodityId)
	end
end

local function appendGiftPackAppearanceMappings(cache, variantMap, commodityId, giftPackId)
	local giftData = ShopMallGiftData[giftPackId]

	if not giftData then
		return
	end

	for itemId in pairs(collectGiftPackItemIds(giftData)) do
		appendCommodityItemAppearanceMappings(cache, variantMap, itemId, commodityId)
	end
end

local function ensureAppearanceCommodityCache()
	local version = getAppearanceCommodityCacheVersion()

	if _appearanceToCommodityIdsCache and _appearanceCommodityCacheVersion == version then
		return
	end

	local cache = {}
	local variantMap = buildGenderVariantMap()

	for commodityId, commodityInfo in pairs(CommodityData) do
		local itemId = commodityInfo.itemId

		if itemId then
			appendCommodityItemAppearanceMappings(cache, variantMap, itemId, commodityId)

			if isGiftPackCommodity(commodityInfo) then
				appendGiftPackAppearanceMappings(cache, variantMap, commodityId, itemId)
			end
		end
	end

	_appearanceToCommodityIdsCache = cache
	_appearanceCommodityCacheVersion = version
end

function ClientCashShopUtils.getCommodityIdsByAppearanceItemId(appearanceId)
	appearanceId = tonumber(appearanceId)

	if not appearanceId then
		return nil
	end

	ensureAppearanceCommodityCache()

	return _appearanceToCommodityIdsCache[appearanceId]
end

function ClientCashShopUtils.isAppearanceCommodityOnShelf(appearanceId)
	local commodityIds = ClientCashShopUtils.getCommodityIdsByAppearanceItemId(appearanceId)

	if not commodityIds or #commodityIds == 0 then
		return true
	end

	for _, commodityId in ipairs(commodityIds) do
		if ClientCashShopUtils.isCommodityEnabled(commodityId) and ClientCashShopUtils.isCommodityAfterStartTime(CommodityData[commodityId]) then
			return true
		end
	end

	return false
end

function ClientCashShopUtils.isAppearanceCommodityInSaleTime(appearanceId)
	return ClientCashShopUtils.isAppearanceCommodityOnShelf(appearanceId)
end

local function isValidDrawId(drawId)
	drawId = tonumber(drawId)

	if not drawId or drawId <= 0 then
		return false
	end

	return GachaEntryData[drawId] ~= nil
end

local function getAppearanceDrawIdCacheVersion()
	return string.format("%s_%s_%s_%s_%s_%s", tostring(AppearanceData), tostring(AppearanceJewelryPetData), tostring(AppearanceSuitData), tostring(AvatarHairSuitData), tostring(AppearanceMakeupPresetData), tostring(GachaEntryData))
end

local function appendDrawId(cache, appearanceId, drawId)
	appearanceId = tonumber(appearanceId)
	drawId = tonumber(drawId)

	if not appearanceId or appearanceId <= 0 or not isValidDrawId(drawId) then
		return
	end

	local drawIds = cache[appearanceId]

	if not drawIds then
		drawIds = {}
		cache[appearanceId] = drawIds
	else
		for _, id in ipairs(drawIds) do
			if id == drawId then
				return
			end
		end
	end

	drawIds[#drawIds + 1] = drawId
end

local function appendDrawIdWithVariants(cache, variantMap, appearanceId, drawId)
	appearanceId = tonumber(appearanceId)

	if not appearanceId or appearanceId <= 0 or not isValidDrawId(drawId) then
		return
	end

	local variants = variantMap[appearanceId]

	if variants then
		for variantId in pairs(variants) do
			if isAppearanceRelatedId(variantId) then
				appendDrawId(cache, variantId, drawId)
			end
		end
	elseif isAppearanceRelatedId(appearanceId) then
		appendDrawId(cache, appearanceId, drawId)
	end
end

local function appendSuitSharedDrawMappings(cache, variantMap, suitId, suitData)
	local drawId = suitData and suitData.drawId

	if not isValidDrawId(drawId) then
		return
	end

	appendDrawIdWithVariants(cache, variantMap, suitId, drawId)

	for _, appearanceId in ipairs(suitData.appearanceList or EMPTY_TABLE) do
		appendDrawIdWithVariants(cache, variantMap, appearanceId, drawId)
	end

	for _, jewelryId in ipairs(suitData.jewelryList or EMPTY_TABLE) do
		appendDrawIdWithVariants(cache, variantMap, jewelryId, drawId)
	end

	if suitData.hair and suitData.hair > 0 then
		appendDrawIdWithVariants(cache, variantMap, suitData.hair, drawId)

		local hairSuitData = AvatarHairSuitData[suitData.hair]

		if hairSuitData then
			for _, partId in ipairs(hairSuitData.appearanceList or EMPTY_TABLE) do
				appendDrawIdWithVariants(cache, variantMap, partId, drawId)
			end
		end
	end
end

local function appendHairSuitSharedDrawMappings(cache, variantMap, hairSuitId, hairSuitData)
	local drawId = hairSuitData and hairSuitData.drawId

	if not isValidDrawId(drawId) then
		return
	end

	appendDrawIdWithVariants(cache, variantMap, hairSuitId, drawId)

	for _, partId in ipairs(hairSuitData.appearanceList or EMPTY_TABLE) do
		appendDrawIdWithVariants(cache, variantMap, partId, drawId)
	end
end

local function appendMakeupSuitSharedDrawMappings(cache, variantMap, makeupSuitId, makeupSuitData)
	local drawId = makeupSuitData and makeupSuitData.drawId

	if not isValidDrawId(drawId) or not makeupSuitData.makeupList then
		return
	end

	appendDrawIdWithVariants(cache, variantMap, makeupSuitId, drawId)

	for _, makeupId in ipairs(makeupSuitData.makeupList) do
		appendDrawIdWithVariants(cache, variantMap, makeupId, drawId)
	end
end

local function ensureAppearanceDrawIdCache()
	local version = getAppearanceDrawIdCacheVersion()

	if _appearanceToDrawIdsCache and _appearanceDrawIdCacheVersion == version then
		return
	end

	local cache = {}
	local variantMap = buildGenderVariantMap()

	for suitId, suitData in pairs(AppearanceSuitData) do
		appendSuitSharedDrawMappings(cache, variantMap, suitId, suitData)
	end

	for hairSuitId, hairSuitData in pairs(AvatarHairSuitData) do
		appendHairSuitSharedDrawMappings(cache, variantMap, hairSuitId, hairSuitData)
	end

	for makeupSuitId, makeupSuitData in pairs(AppearanceMakeupPresetData) do
		appendMakeupSuitSharedDrawMappings(cache, variantMap, makeupSuitId, makeupSuitData)
	end

	for appearanceId, appearanceData in pairs(AppearanceData) do
		appendDrawIdWithVariants(cache, variantMap, appearanceId, appearanceData.drawId)
	end

	for petId, petData in pairs(AppearanceJewelryPetData) do
		appendDrawIdWithVariants(cache, variantMap, petId, petData.drawId)
	end

	_appearanceToDrawIdsCache = cache
	_appearanceDrawIdCacheVersion = version
end

function ClientCashShopUtils.getDrawIdsByAppearanceItemId(appearanceId)
	appearanceId = tonumber(appearanceId)

	if not appearanceId then
		return nil
	end

	ensureAppearanceDrawIdCache()

	return _appearanceToDrawIdsCache[appearanceId]
end

local function isDrawIdAfterOpenTime(drawId)
	local entry = GachaEntryData[drawId]

	if not entry then
		return false
	end

	local openTime = Utils.getConfigTimeOfAreaByData(entry.openTime)

	if not openTime then
		return false
	end

	local now = Time.secondCache or Time.getSecond()

	return openTime <= now
end

function ClientCashShopUtils.getAppearanceDrawOpenState(appearanceId)
	local drawIds = ClientCashShopUtils.getDrawIdsByAppearanceItemId(appearanceId)

	if not drawIds or #drawIds == 0 then
		return false, false
	end

	for _, drawId in ipairs(drawIds) do
		if isDrawIdAfterOpenTime(drawId) then
			return true, true
		end
	end

	return true, false
end

function ClientCashShopUtils.isAppearanceReleaseTimeOpen(appearanceId)
	appearanceId = tonumber(appearanceId)

	if not appearanceId then
		return true
	end

	local commodityIds = ClientCashShopUtils.getCommodityIdsByAppearanceItemId(appearanceId)
	local hasCommodity = commodityIds ~= nil and #commodityIds > 0
	local hasDraw, drawOpen = ClientCashShopUtils.getAppearanceDrawOpenState(appearanceId)

	if not hasCommodity and not hasDraw then
		return true
	end

	if hasCommodity then
		for _, commodityId in ipairs(commodityIds) do
			if ClientCashShopUtils.isCommodityEnabled(commodityId) and ClientCashShopUtils.isCommodityAfterStartTime(CommodityData[commodityId]) then
				return true
			end
		end
	end

	if hasDraw and drawOpen then
		return true
	end

	return false
end

function ClientCashShopUtils.getRandomShopTimestamp(cfg, fieldName)
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

function ClientCashShopUtils.isRandomShopCommonSwitchOpen(cfg)
	local switchKey = cfg and cfg.commonSwitchKey

	if not switchKey or switchKey == "" then
		return true
	end

	return CommonSwitch[switchKey] == true
end

function ClientCashShopUtils.getCurrentRandomShop()
	local now = tonumber(Time.secondCache)

	if not now or now <= 0 then
		now = Time.getSecond()
	end

	for shopId, cfg in pairs(RandomShopData) do
		local startTime = ClientCashShopUtils.getRandomShopTimestamp(cfg, "startTime")
		local endTime = ClientCashShopUtils.getRandomShopTimestamp(cfg, "endTime")

		if startTime and endTime and startTime <= now and now <= endTime and ClientCashShopUtils.isRandomShopCommonSwitchOpen(cfg) then
			return shopId, cfg
		end
	end

	return nil, nil
end

function ClientCashShopUtils.canOpenCashShop()
	return CommonSwitch.ShopMall_All == true and LuaUIUtils.checkFuncCanOpen(Const.FUNCTION_IDS.CASHSHOP) == true
end

function ClientCashShopUtils.canOpenBattlePass()
	if not LuaUIUtils.checkFuncCanOpen(Const.FUNCTION_IDS.BATTLEPASS) then
		return false
	end

	local actData = ActivityUtils.getActivityData(pg.me, ActivityConst.EventType.BattlePass)

	if not actData or not actData.activityBase or not actData.activityBase:isGoing() then
		return false
	end

	return true
end

function ClientCashShopUtils.getCommodityData(commodityId)
	return CommodityData[commodityId]
end

function ClientCashShopUtils.getCommodityCostList(commodityId, buyCount, options)
	local commodityInfo = ClientCashShopUtils.getCommodityData(commodityId)

	if not commodityInfo then
		return {}
	end

	local finalBuyCount = math.max(0, tonumber(buyCount) or 1)

	if finalBuyCount <= 0 or Utils.checkShopMallCommodityFree(commodityId) then
		return {}
	end

	local isInDiscount = options and options.isInDiscount

	if isInDiscount == nil then
		isInDiscount = ClientCashShopUtils.isCommodityInDiscount(commodityInfo)
	end

	local costData = commodityInfo.cost or {}

	if commodityInfo.specialCost and isInDiscount then
		costData = commodityInfo.specialCost
	end

	local costs = {}

	for _, costItem in ipairs(costData) do
		if #costItem >= 2 then
			local onePrice = costItem[2] or 0

			costs[#costs + 1] = {
				itemId = costItem[1],
				onePrice = onePrice,
				totalPrice = onePrice * finalBuyCount
			}
		end
	end

	if ClientCashShopUtils.shouldUseCommodityLevelCost(commodityId, commodityInfo, options) and #costs > 0 then
		local ret

		ret, costs = ItemUtils.calcLevelCostBreakdown(costs, commodityInfo.levelCost, ClientCashShopUtils.getCommodityLevelCount(commodityId), finalBuyCount)

		if ret ~= NoticeDef.SUCCESS or not costs then
			logger:error("getCommodityCostList fail levelCost calc commodityId=%s buyCount=%s ret=%s", commodityId, finalBuyCount, ret)

			return nil, ret
		end
	end

	return costs
end

function ClientCashShopUtils.getCommodityConsumeList(commodityId, buyCount, options)
	local costs, errorCode = ClientCashShopUtils.getCommodityCostList(commodityId, buyCount, options)

	if not costs then
		return nil, errorCode
	end

	local consumeList = {}

	for _, costItem in ipairs(costs) do
		consumeList[#consumeList + 1] = {
			costItem.itemId,
			costItem.totalPrice
		}
	end

	return consumeList
end

function ClientCashShopUtils.getCommodityPrimaryCost(commodityId, buyCount, options)
	local costs, errorCode = ClientCashShopUtils.getCommodityCostList(commodityId, buyCount, options)

	if not costs then
		return nil, errorCode
	end

	local primaryCost = costs[1]

	if not primaryCost then
		return nil
	end

	return {
		primaryCost.itemId,
		primaryCost.totalPrice
	}
end

function ClientCashShopUtils.getCommodityLeftLimit(commodityId)
	local commodityInfo = ClientCashShopUtils.getCommodityData(commodityId)

	if not commodityInfo or not commodityInfo.limitNum or commodityInfo.limitNum <= 0 then
		return math.huge
	end

	if commodityInfo.limitType == Const.LIMIT_SCENE then
		local curSceneId = pg.me and pg.me.space and pg.me.space.sceneId or 0

		if not ShopCommonHelper.isHitSceneLimit(commodityInfo, curSceneId) then
			return math.huge
		end
	end

	return math.max(0, commodityInfo.limitNum - ClientCashShopUtils.getCommodityLimitBoughtCount(commodityId))
end

function ClientCashShopUtils.canAffordCommodity(commodityId, buyCount, options)
	local costs, errorCode = ClientCashShopUtils.getCommodityCostList(commodityId, buyCount, options)

	if not costs then
		return false, nil, {}, errorCode
	end

	if #costs == 0 then
		return true, costs, {}
	end

	local costIdNums = ClientCashShopUtils.genMallCostIdNums(costs)
	local result, adjustedCostIdNums = ClientCashShopUtils.canAffordCostIdNums(costIdNums)

	return result, costs, adjustedCostIdNums
end

function ClientCashShopUtils.getCommodityMaxBuyCount(commodityId, options)
	local commodityInfo = ClientCashShopUtils.getCommodityData(commodityId)

	if not commodityInfo then
		return 0
	end

	local maxCount = ClientCashShopUtils.DEFAULT_MAX_BUY_COUNT
	local leftLimit = ClientCashShopUtils.getCommodityLeftLimit(commodityId)

	if leftLimit ~= math.huge then
		maxCount = math.min(maxCount, leftLimit)
	end

	if maxCount <= 0 then
		return 0
	end

	if Utils.checkShopMallCommodityFree(commodityId) then
		return maxCount
	end

	local result = 0

	for count = 1, maxCount do
		local canAfford, _, _, errorCode = ClientCashShopUtils.canAffordCommodity(commodityId, count, options)

		if errorCode then
			return 0, errorCode
		end

		if not canAfford then
			break
		end

		result = count
	end

	return result
end

function ClientCashShopUtils.getItemDataByCommodityId(commodityId)
	local commodity = ClientCashShopUtils.getCommodityData(commodityId)

	if not commodity then
		return nil
	end

	return ItemData[commodity.itemId]
end

function ClientCashShopUtils.getCommodityDisplayIcon(data, fallbackItemId)
	local commodityInfo = data and data.commodityId and ClientCashShopUtils.getCommodityData(data.commodityId) or nil
	local avatarPicShow = data and data.avatarPicShow or nil
	local avatarPic = data and data.avatarPic or nil
	local itemId = data and data.itemId or fallbackItemId

	if commodityInfo then
		avatarPicShow = avatarPicShow or commodityInfo.avatarPicShow
		avatarPic = avatarPic or commodityInfo.avatarPic
		itemId = commodityInfo.itemId or itemId
	end

	return avatarPicShow or avatarPic or LuaUIUtils.getIconByItemId(itemId)
end

function ClientCashShopUtils.getFashionByCommodityId(commodityId, isPet)
	local commodityInfo = ClientCashShopUtils.getCommodityData(commodityId)

	if not commodityInfo then
		return 0
	end

	local avatarId = commodityInfo.itemId

	if ClientCashShopUtils.isSuitType(commodityInfo.avatarType) then
		local suitData = AppearanceSuitData[avatarId]

		if not suitData or not suitData.appearanceList then
			return 0
		end

		local total = 0

		for _, appearanceId in ipairs(suitData.appearanceList) do
			local appearanceRow = AppearanceData[appearanceId]

			if appearanceRow then
				total = total + (appearanceRow.fashion or 0)
			end
		end

		return total
	else
		local lookupId = avatarId
		local appearanceInfo = ShopMallAppearance[avatarId]

		if appearanceInfo then
			lookupId = isPet and appearanceInfo[2] or appearanceInfo[1] or avatarId
		end

		local appearanceRow = isPet and AppearanceJewelryPetData[lookupId] or AppearanceData[lookupId]

		return appearanceRow and (appearanceRow.fashion or 0) or 0
	end
end

function ClientCashShopUtils.getAvatarTypeText(avatarType)
	return ItemTypeShowData[avatarType] and pg.getLocalizationText(ItemTypeShowData[avatarType].type) or ""
end

function ClientCashShopUtils.hasOwnedAppearance(playerEnt, appearanceId)
	if not playerEnt or not playerEnt.appearanceInfo or not appearanceId then
		return false
	end

	local variants = {
		[appearanceId] = true
	}
	local convertData = ItemConditionConvertData[appearanceId]

	if convertData and convertData.targetItem then
		for _, entry in ipairs(convertData.targetItem) do
			if entry[1] == CONDITION_FEMALE or entry[1] == CONDITION_MALE then
				variants[entry[2]] = true
			end
		end
	end

	for configId, _ in pairs(variants) do
		if playerEnt.appearanceInfo[configId] ~= nil then
			return true
		end
	end

	return false
end

function ClientCashShopUtils.hasOwnedCommodityAppearance(playerEnt, commodityData)
	if not playerEnt or not commodityData or not commodityData.itemId then
		return false
	end

	local avatarType = ClientCashShopUtils.toNumberOrDefault(commodityData.avatarType, commodityData.avatarType)

	if avatarType == CashShopConst.CommodityAvatarType.ACCESSORY_PACKAGE then
		return false
	end

	local itemId = commodityData.itemId
	local previewItemId = ClientCashShopUtils.getGenderConvertedItemId(itemId, ClientCashShopUtils.getPlayerGender()) or itemId
	local mappedInfo = ShopMallAppearance[previewItemId] or ShopMallAppearance[itemId]

	if ClientCashShopUtils.isSuitType(commodityData.avatarType) or AppearanceSuitData[previewItemId] or AppearanceSuitData[itemId] then
		return TriggerUtils._getOutfitCount(playerEnt, nil, {
			previewItemId
		}) > 0 or previewItemId ~= itemId and TriggerUtils._getOutfitCount(playerEnt, nil, {
			itemId
		}) > 0
	end

	local playerAppearanceId, petAppearanceId

	if AppearanceData[previewItemId] then
		playerAppearanceId = previewItemId
	elseif mappedInfo and mappedInfo[1] and AppearanceData[mappedInfo[1]] then
		playerAppearanceId = ClientCashShopUtils.getGenderConvertedItemId(mappedInfo[1], ClientCashShopUtils.getPlayerGender())
	end

	if mappedInfo then
		if mappedInfo[2] and AppearanceJewelryPetData[mappedInfo[2]] then
			petAppearanceId = mappedInfo[2]
		elseif mappedInfo[1] and AppearanceJewelryPetData[mappedInfo[1]] then
			petAppearanceId = mappedInfo[1]
		end
	end

	if not petAppearanceId then
		if AppearanceJewelryPetData[previewItemId] then
			petAppearanceId = previewItemId
		elseif AppearanceJewelryPetData[itemId] then
			petAppearanceId = itemId
		end
	end

	return ClientCashShopUtils.hasOwnedAppearance(playerEnt, playerAppearanceId) or ClientCashShopUtils.hasOwnedAppearance(playerEnt, petAppearanceId)
end

function ClientCashShopUtils.isCommodityAvailableInArea(commodityId)
	if commodityId == nil then
		return true
	end

	local finalCommodityId = ClientCashShopUtils.toNumberOrDefault(commodityId, commodityId)
	local commodityInfo = CommodityData[finalCommodityId]
	local areaNo = Utils.getServerArea()

	if not ShopCommonHelper.isConfigAvailableInArea(commodityInfo, areaNo) then
		return false
	end

	local itemInfo = commodityInfo and ItemData[commodityInfo.itemId]

	return ShopCommonHelper.isConfigAvailableInArea(itemInfo, areaNo)
end

function ClientCashShopUtils.isCommodityEnabled(commodityId)
	if commodityId == nil then
		return true
	end

	local finalCommodityId = ClientCashShopUtils.toNumberOrDefault(commodityId, commodityId)
	local commoditySwitch = CommonSwitch.SHOPMALL_COMMODITY or EMPTY_TABLE

	return commoditySwitch[finalCommodityId] ~= false and commoditySwitch[tostring(finalCommodityId)] ~= false and ClientCashShopUtils.isCommodityAvailableInArea(finalCommodityId)
end

function ClientCashShopUtils.isCommodityOnShelf(data, commodityId)
	if not data or ClientCashShopUtils.toNumberOrDefault(data.onSale, data.onSale) ~= 1 then
		return false
	end

	local finalCommodityId = commodityId or data.commodityId

	if not ClientCashShopUtils.isCommodityEnabled(finalCommodityId) then
		return false
	end

	local now = Time.secondCache or Time.getSecond()
	local startTime = Utils.getConfigTimeOfArea(data, "startTime")
	local endTime = Utils.getConfigTimeOfArea(data, "endTime")

	if startTime and now < startTime then
		return false
	end

	if endTime and endTime <= now then
		return false
	end

	return true
end

function ClientCashShopUtils.isCommodityAfterStartTime(data)
	if not data then
		return false
	end

	if data.ignoreStartTime == 1 then
		return true
	end

	local now = Time.secondCache or Time.getSecond()
	local startTime = Utils.getConfigTimeOfArea(data, "startTime")

	if startTime and startTime <= now then
		return true
	end

	return false
end

function ClientCashShopUtils.getCommodityListByGroupId(groupId)
	local result = {}
	local targetGroupId = ClientCashShopUtils.toNumberOrDefault(groupId, groupId)

	for id, cfg in pairs(CommodityData) do
		if ClientCashShopUtils.toNumberOrDefault(cfg.tabGroupId, cfg.tabGroupId) == targetGroupId and ClientCashShopUtils.isCommodityOnShelf(cfg, id) and not ClientCashShopUtils.isCommodityHideByCondition(cfg) then
			local entry = {}

			for k, v in pairs(cfg) do
				entry[k] = v
			end

			entry.commodityId = id
			result[#result + 1] = entry
		end
	end

	table.sort(result, function(a, b)
		return (a.sort or 0) < (b.sort or 0)
	end)

	return result
end

function ClientCashShopUtils.checkConditions(condition)
	if not condition or #condition == 0 then
		return true
	end

	for _, conditionId in ipairs(condition) do
		if not ClientUtils.checkCondition(conditionId) then
			return false
		end
	end

	return true
end

function ClientCashShopUtils.isCommodityHideByCondition(commodityInfo)
	if not commodityInfo or commodityInfo.hideByCondition ~= 1 then
		return false
	end

	if not commodityInfo.condition or #commodityInfo.condition == 0 then
		return false
	end

	if not pg.me then
		return false
	end

	return not ClientCashShopUtils.checkConditions(commodityInfo.condition)
end

function ClientCashShopUtils.getCommodityStateData(data)
	if not data then
		return nil
	end

	if not data.commodityId then
		return data
	end

	local commodityInfo = ClientCashShopUtils.getCommodityData(data.commodityId)

	if not commodityInfo then
		return data
	end

	local stateData = {}

	for k, v in pairs(commodityInfo) do
		stateData[k] = v
	end

	for k, v in pairs(data) do
		stateData[k] = v
	end

	stateData.commodityId = data.commodityId

	return stateData
end

function ClientCashShopUtils.getCommodityStateByNormalizedData(stateData)
	if not stateData then
		return COMMODITY_STATE.NORMAL
	end

	if stateData.condition and not ClientCashShopUtils.checkConditions(stateData.condition) then
		return COMMODITY_STATE.LOCKED
	end

	if stateData.limitNum and stateData.limitNum > 0 then
		local hadBuy = ClientCashShopUtils.getCommodityLimitBoughtCount(stateData.commodityId)

		if hadBuy >= stateData.limitNum then
			return COMMODITY_STATE.SOLDOUT
		end
	end

	if stateData.avatarType and stateData.commodityId and pg.me and ClientCashShopUtils.hasOwnedCommodityAppearance(pg.me, stateData) then
		return COMMODITY_STATE.POSSESS
	end

	return COMMODITY_STATE.NORMAL
end

function ClientCashShopUtils.getCommodityState(data)
	return ClientCashShopUtils.getCommodityStateByNormalizedData(ClientCashShopUtils.getCommodityStateData(data))
end

ClientCashShopUtils.COMMODITY_STATE = COMMODITY_STATE

function ClientCashShopUtils.searchCommodityByName(tabId, keyword)
	if not keyword or keyword == "" then
		return {}
	end

	local normalizedKeyword = string.lower(keyword)
	local groupIds = {}
	local targetTabId = ClientCashShopUtils.toNumberOrDefault(tabId, tabId)

	for groupId, cfg in pairs(ShopmallTabGroupData) do
		if ClientCashShopUtils.toNumberOrDefault(cfg.tabId, cfg.tabId) == targetTabId and ClientCashShopUtils.toNumberOrDefault(cfg.isHide, cfg.isHide) ~= 1 then
			groupIds[groupId] = true
		end
	end

	local result = {}

	for id, cfg in pairs(CommodityData) do
		if (groupIds[cfg.tabGroupId] or groupIds[tostring(cfg.tabGroupId)]) and ClientCashShopUtils.isCommodityOnShelf(cfg, id) and not ClientCashShopUtils.isCommodityHideByCondition(cfg) then
			local localName = cfg.name and pg.getLocalizationText(cfg.name) or LuaUIUtils.getNameByItemId(cfg.itemId)
			local normalizedName = localName and string.lower(localName)

			if normalizedName and string.find(normalizedName, normalizedKeyword, 1, true) then
				local entry = {}

				for k, v in pairs(cfg) do
					entry[k] = v
				end

				entry.commodityId = id
				entry.name = localName
				result[#result + 1] = entry
			end
		end
	end

	table.sort(result, function(a, b)
		return (a.sort or 0) < (b.sort or 0)
	end)

	return result
end

local SORT_VALUE_GETTERS = {
	search_word = function(item)
		return ClientCashShopUtils.toNumberOrDefault(item.sort, 0)
	end,
	search_price = function(item)
		local commodityId = item.commodityId or item.id

		if commodityId then
			local currentCost = ClientCashShopUtils.getCommodityPrimaryCost(commodityId, 1)

			if currentCost then
				return ClientCashShopUtils.toNumberOrDefault(currentCost[2], 0)
			end
		end

		local specialCost = item.specialCost and ClientCashShopUtils.getSequenceValue(item.specialCost, 1)
		local cost = item.cost and ClientCashShopUtils.getSequenceValue(item.cost, 1)
		local _, specialAmount = ClientCashShopUtils.normalizeCostEntry(specialCost)
		local _, costAmount = ClientCashShopUtils.normalizeCostEntry(cost)

		return specialAmount or costAmount or 0
	end,
	search_quality = function(item)
		local itemInfo = ItemData[item.itemId]

		return ClientCashShopUtils.toNumberOrDefault(itemInfo and itemInfo.quality, 0)
	end,
	search_time = function(item)
		return ClientCashShopUtils.toNumberOrDefault(Utils.getConfigTimeOfArea(item, "startTime"), 0)
	end
}
local CATEGORY_AVATAR_TYPE = {
	search_back = 3005,
	search_face = 3004,
	search_head = 3003,
	search_necklace = 3007,
	search_earring = 3006
}

function ClientCashShopUtils.filterAndSortCommodityList(list, filterState)
	if not filterState then
		return list
	end

	local result = {}

	for _, item in ipairs(list) do
		local pass = true

		if filterState.filters then
			for _, filter in ipairs(filterState.filters) do
				local filterType = tonumber(filter.type) or filter.type

				if filterType == 3 then
					local selectedItems = filter.selectedItems or filter.selectedItem and {
						filter.selectedItem
					} or nil

					if selectedItems and #selectedItems > 0 then
						local matched = false
						local itemAvatarType = ClientCashShopUtils.toNumberOrDefault(item.avatarType, item.avatarType)

						for _, key in ipairs(selectedItems) do
							if key == "search_all" then
								matched = true

								break
							end

							local targetType = CATEGORY_AVATAR_TYPE[key]

							if targetType and itemAvatarType == targetType then
								matched = true

								break
							end
						end

						if not matched then
							pass = false
						end
					end
				elseif filterType == 2 then
					local selectedItems = filter.selectedItems or filter.selectedItem and {
						filter.selectedItem
					} or nil

					if selectedItems and #selectedItems > 0 then
						local matched = false
						local currentCost = ClientCashShopUtils.getCommodityPrimaryCost(item.commodityId or item.id, 1)
						local currentCurrencyId = currentCost and currentCost[1] or nil
						local currentAmount = currentCost and currentCost[2] or nil

						if currentCurrencyId == nil then
							local rawSpecialCost = item.specialCost and ClientCashShopUtils.getSequenceValue(item.specialCost, 1)
							local rawCost = item.cost and ClientCashShopUtils.getSequenceValue(item.cost, 1)

							currentCurrencyId, currentAmount = ClientCashShopUtils.normalizeCostEntry(rawSpecialCost or rawCost)
						end

						for _, priceFilter in ipairs(selectedItems) do
							local filterCurrencyId, filterAmount = ClientCashShopUtils.normalizeCostEntry(priceFilter)

							if currentCurrencyId ~= nil and currentCurrencyId == filterCurrencyId and currentAmount == filterAmount then
								matched = true

								break
							end
						end

						if not matched then
							pass = false
						end
					end
				end
			end
		end

		if pass then
			result[#result + 1] = item
		end
	end

	local sortKey = filterState.sortKey
	local ascending = filterState.sortAscending

	if ascending == nil then
		ascending = true
	end

	local getter = SORT_VALUE_GETTERS[sortKey]

	if getter then
		table.sort(result, function(a, b)
			local va = getter(a)
			local vb = getter(b)

			if ascending then
				return va < vb
			else
				return vb < va
			end
		end)
	end

	return result
end

function ClientCashShopUtils.getPrivilegeValueText(attrValue)
	if attrValue == nil then
		return ""
	end

	return tostring(math.ceil(attrValue))
end

function ClientCashShopUtils.getBattlePassPrivilegeCountText(entry, specialColor)
	if not entry or not entry.attrValue then
		return ""
	end

	if string.isNilOrEmpty(specialColor) then
		return entry.attrValue
	end

	return pg.getFormatText(specialColor, entry.attrValue)
end

function ClientCashShopUtils.getBattlePassPrivilegeListByIds(idList, colorType, specialColor, title)
	if not idList then
		return {}
	end

	local result = {}

	if title then
		result[#result + 1] = {
			countText = "",
			id = 0,
			desc = title,
			colorType = colorType or 0
		}
	end

	for _, id in ipairs(idList) do
		local entry = AttributeEntryData[id]

		if entry and (entry.country ~= 1 or not Utils.isOverseas()) then
			result[#result + 1] = {
				id = id,
				desc = entry.desc,
				colorType = colorType or 0,
				countText = ClientCashShopUtils.getBattlePassPrivilegeCountText(entry, specialColor)
			}
		end
	end

	return result
end

function ClientCashShopUtils.buildBattlePassRewardList(rawList, limitItems)
	if not rawList then
		return {}
	end

	local list = {}
	local hasLimitItems = Utils.isTable(limitItems)

	for _, entry in ipairs(rawList) do
		local itemId = entry[1]

		list[#list + 1] = {
			id = itemId,
			num = entry[2],
			showLimitTag = hasLimitItems and table.contains(limitItems, itemId)
		}
	end

	return list
end

function ClientCashShopUtils.renderBattlePassRewardItem(button, _, data)
	LuaUIUtils.renderRewardItem(button, data)

	local objectReference = button:GetComponent("ObjectReference")
	local tagUWidget = objectReference:GetRefValue("tagUWidget")
	local tagTxt = objectReference:GetRefValue("tagTxt")

	if tagUWidget then
		tagUWidget.gameObject:SetActiveEx(data.showLimitTag == true)
	end

	if tagTxt then
		ClientTextUtils.setText(tagTxt, data.showLimitTag and pg.getGameString("CASH_LIMIT_TITLE") or "")
	end
end

function ClientCashShopUtils.renderBPInfo(trans, callback)
	local actData = ActivityUtils.getActivityData(pg.me, ActivityConst.EventType.BattlePass)

	if not actData then
		return
	end

	local phase = actData.activityBase and actData.activityBase.activityPhase
	local bpData = phase and BattlePassData[phase]

	if not bpData then
		return
	end

	local bpGear = actData.bpGear or ActivityConst.BattlePassGear.Free
	local objectReference = trans:GetComponent("ObjectReference")
	local txtSpecialCostTitle1 = objectReference:GetRefValue("txtSpecialCostTitle1")
	local txtBPName1 = objectReference:GetRefValue("txtBPName1")
	local txtRewardTitle1 = objectReference:GetRefValue("txtRewardTitle1")
	local txtPetEggName = objectReference:GetRefValue("txtPetEggName")
	local imgPetEgg = objectReference:GetRefValue("imgPetEgg")
	local itemListUList1 = objectReference:GetRefValue("itemListUList1")
	local txtMoreReward = objectReference:GetRefValue("txtMoreReward")
	local txtBuffTitle1 = objectReference:GetRefValue("txtBuffTitle1")
	local txtCost1 = objectReference:GetRefValue("txtCost1")
	local txtSpecialCostTitle2 = objectReference:GetRefValue("txtSpecialCostTitle2")
	local txtBPName2 = objectReference:GetRefValue("txtBPName2")
	local txtExReward = objectReference:GetRefValue("txtExReward")
	local txtRewardTitle2 = objectReference:GetRefValue("txtRewardTitle2")
	local txtRewardTitle3 = objectReference:GetRefValue("txtRewardTitle3")
	local itemListUList2 = objectReference:GetRefValue("itemListUList2")
	local itemListUList3 = objectReference:GetRefValue("itemListUList3")
	local txtBuffTitle2 = objectReference:GetRefValue("txtBuffTitle2")
	local listBuff1 = objectReference:GetRefValue("listBuff1")
	local listBuff2 = objectReference:GetRefValue("listBuff2")
	local txtCost2 = objectReference:GetRefValue("txtCost2")
	local btnBuy1 = objectReference:GetRefValue("btnBuy1")
	local btnBuy2 = objectReference:GetRefValue("btnBuy2")
	local petQualityUComponent = objectReference:GetRefValue("petQualityUComponent")
	local txtMore = objectReference:GetRefValue("txtMore")
	local btnGoTo = objectReference:GetRefValue("btnGoTo")
	local txtGoToName = objectReference:GetRefValue("txtGoToName")
	local btnBPEgg = objectReference:GetRefValue("btnBPEgg")
	local btnBPEgg2 = objectReference:GetRefValue("btnBPEgg2")
	local txtCost1Lock = objectReference:GetRefValue("txtCost1Lock")
	local txtCost2Lock = objectReference:GetRefValue("txtCost2Lock")
	local rootUComponent = objectReference:GetRefValue("rootUComponent")

	if txtBPName1 then
		ClientTextUtils.setText(txtBPName1, pg.getLocalizationText(bpData.tierName1))
	end

	if txtRewardTitle1 then
		ClientTextUtils.setText(txtRewardTitle1, pg.getGameString("BATTLEPASS_SELLPAGE_LEFTDESC"))
	end

	if txtMoreReward then
		ClientTextUtils.setText(txtMoreReward, pg.getGameString("BATTLEPASS_SELLPAGE_LEFTMOREREWARDS"))
	end

	if txtBuffTitle1 then
		ClientTextUtils.setText(txtBuffTitle1, pg.getGameString("BATTLEPASS_SELLPAGE_PREVILEDGE"))
	end

	if txtBPName2 then
		ClientTextUtils.setText(txtBPName2, pg.getLocalizationText(bpData.tierName2))
	end

	if txtExReward then
		ClientTextUtils.setText(txtExReward, pg.getGameString("BATTLEPASS_SELLPAGE_RIGHSUBTITLE"))
	end

	if txtRewardTitle2 then
		ClientTextUtils.setText(txtRewardTitle2, pg.getGameString("SHOPMALL_BUNDLEIMMEDIATEREWARD_TEXT"))
	end

	if txtRewardTitle3 then
		ClientTextUtils.setText(txtRewardTitle3, pg.getGameString("BATTLEPASS_SELLPAGE_LEFTDESC"))
	end

	if txtBuffTitle2 then
		ClientTextUtils.setText(txtBuffTitle2, pg.getGameString("BATTLEPASS_SELLPAGE_PREVILEDGE"))
	end

	if txtSpecialCostTitle1 then
		ClientTextUtils.setText(txtSpecialCostTitle1, pg.getLocalizationText(bpData.discountTier1))
	end

	if txtSpecialCostTitle2 then
		ClientTextUtils.setText(txtSpecialCostTitle2, pg.getLocalizationText(bpData.discountTier2))
	end

	if txtMore then
		ClientTextUtils.setText(txtMore, "...")
	end

	if txtGoToName then
		ClientTextUtils.setText(txtGoToName, pg.getGameString("BATTLEPASS_PURCHASE_GOTOPASS"))
	end

	local rechargeInfo1 = RechargeUtils.getProductsInfo(RechargeConst.RECHARGE_TYPE.BP, RechargeConst.RECHARGE_BP_TYPE.NORMAL)
	local price2Type = bpGear == ActivityConst.BattlePassGear.Pay1 and RechargeConst.RECHARGE_BP_TYPE.ADD or RechargeConst.RECHARGE_BP_TYPE.ADVANCED
	local rechargeInfo2 = RechargeUtils.getProductsInfo(RechargeConst.RECHARGE_TYPE.BP, price2Type)
	local strPrice1 = ""
	local strPrice2 = ""

	if rechargeInfo1 and rechargeInfo1.sdkInfo then
		strPrice1 = RechargeUtils.getProductsPrice(rechargeInfo1)
	end

	if rechargeInfo2 and rechargeInfo2.sdkInfo then
		strPrice2 = RechargeUtils.getProductsPrice(rechargeInfo2)
	end

	btnBuy1.interactable = true
	btnBuy2.interactable = true

	if bpGear >= ActivityConst.BattlePassGear.Pay2 then
		strPrice1 = pg.getGameString("BATTLEPASS_PURCHASE_UNLOCKED2")
		strPrice2 = pg.getGameString("BATTLEPASS_PURCHASE_UNLOCKED2")

		btnBuy1:TryChangePage("Type", 2)
		btnBuy2:TryChangePage("Type", 2)

		btnBuy1.interactable = false
		btnBuy2.interactable = false
	elseif bpGear >= ActivityConst.BattlePassGear.Pay1 then
		strPrice1 = pg.getGameString("BATTLEPASS_PURCHASE_UNLOCKED1")

		btnBuy1:TryChangePage("Type", 2)

		btnBuy1.interactable = false
	end

	rootUComponent:TryChangePage("AdvancedState", bpGear >= ActivityConst.BattlePassGear.Pay1 and 1 or 0)
	rootUComponent:TryChangePage("DeluxeState", bpGear >= ActivityConst.BattlePassGear.Pay2 and 1 or 0)

	local shopPaySystemStr = pg.getGameString("SHOP_PAY_SYSTEM")

	if strPrice1 == "" then
		strPrice1 = shopPaySystemStr
	end

	if strPrice2 == "" then
		strPrice2 = shopPaySystemStr
	end

	if txtCost1 then
		ClientTextUtils.setText(txtCost1, strPrice1)
	end

	if txtCost2 then
		ClientTextUtils.setText(txtCost2, strPrice2)
	end

	if txtCost1Lock then
		ClientTextUtils.setText(txtCost1Lock, strPrice1)
	end

	if txtCost2Lock then
		ClientTextUtils.setText(txtCost2Lock, strPrice2)
	end

	if petQualityUComponent then
		petQualityUComponent:TryChangePage("Quality", 3)

		local objectReference1 = petQualityUComponent:GetComponent("ObjectReference")
		local txtNameUSDFText = objectReference1:GetRefValue("txtNameUSDFText")

		if txtNameUSDFText then
			local ratingStr = Const.STAGE_TO_RATING_STR[4] or ""

			ClientTextUtils.setText(txtNameUSDFText, pg.getGameString(ratingStr))
		end
	end

	if itemListUList1 then
		itemListUList1.luaRenderItem = ClientCashShopUtils.renderBattlePassRewardItem

		itemListUList1:SetList(ClientCashShopUtils.buildBattlePassRewardList(bpData.rewadPreview1, bpData.limitItems1))
	end

	if itemListUList2 then
		itemListUList2.luaRenderItem = ClientCashShopUtils.renderBattlePassRewardItem

		itemListUList2:SetList(ClientCashShopUtils.buildBattlePassRewardList(bpData.rewadPreview2, bpData.limitItems2))
	end

	if itemListUList3 then
		itemListUList3.luaRenderItem = ClientCashShopUtils.renderBattlePassRewardItem

		itemListUList3:SetList(ClientCashShopUtils.buildBattlePassRewardList(bpData.rewadPreview1, bpData.limitItems1))
	end

	local function renderBuffItem(btn, _, d)
		local objectReference1 = btn:GetComponent("ObjectReference")
		local txtPrivilege = objectReference1:GetRefValue("textUBaseText")
		local counttxtUBaseText = objectReference1:GetRefValue("counttxtUBaseText")

		if txtPrivilege and d.desc then
			ClientTextUtils.setText(txtPrivilege, pg.getLocalizationText(d.desc))
		end

		if counttxtUBaseText then
			ClientTextUtils.setText(counttxtUBaseText, d.countText or "")
		end

		btn:TryChangePage("TextColor", d.colorType)
	end

	if listBuff1 then
		listBuff1.luaRenderItem = renderBuffItem

		local buffList1 = ClientCashShopUtils.getBattlePassPrivilegeListByIds(bpData.privilegeTier1, 0, bpData.specialColor)

		listBuff1:SetList(buffList1)
	end

	if listBuff2 then
		listBuff2.luaRenderItem = renderBuffItem

		local buffList2 = ClientCashShopUtils.getBattlePassPrivilegeListByIds(bpData.privilegeTier2, 1, bpData.specialColor)

		listBuff2:SetList(buffList2)
	end

	if txtPetEggName and bpData.passPetEggId then
		ClientTextUtils.setText(txtPetEggName, pg.getLocalizationText(bpData.passPetName))
	end

	if btnBPEgg then
		function btnBPEgg.luaClick()
			pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
				id = bpData.passPetEggId,
				targetRect = btnBPEgg,
				originData = {
					hideCount = true
				}
			})
		end
	end

	if btnBPEgg2 then
		function btnBPEgg2.luaClick()
			pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
				id = bpData.passPetEggId,
				targetRect = btnBPEgg2,
				originData = {
					hideCount = true
				}
			})
		end
	end

	if btnBuy1 and rechargeInfo1 then
		function btnBuy1.luaClick()
			if bpGear >= ActivityConst.BattlePassGear.Pay1 then
				return
			end

			if callback then
				callback(RechargeConst.RECHARGE_BP_TYPE.NORMAL)
			end
		end
	end

	if btnBuy2 and rechargeInfo2 then
		function btnBuy2.luaClick()
			if not callback then
				return
			end

			if bpGear >= ActivityConst.BattlePassGear.Pay2 then
				return
			end

			if bpGear == ActivityConst.BattlePassGear.Pay1 then
				callback(RechargeConst.RECHARGE_BP_TYPE.ADD)
			else
				callback(RechargeConst.RECHARGE_BP_TYPE.ADVANCED)
			end
		end
	end

	if btnGoTo then
		function btnGoTo.luaClick()
			if not ClientCashShopUtils.canOpenBattlePass() then
				return
			end

			pg.global.ui:open(UIConst.UI_ID_BP_PERMIT)
		end
	end
end

function ClientCashShopUtils.renderCommodityItem(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local imgBanner = objectReference:GetRefValue("imgBanner")
	local txtTitle = objectReference:GetRefValue("txtTitle")
	local discountUWidget = objectReference:GetRefValue("discountUWidget")
	local newUWidget = objectReference:GetRefValue("newUWidget")
	local pullUWidget = objectReference:GetRefValue("pullUWidget")
	local discountCountdownUWidget = objectReference:GetRefValue("discountCountdownUWidget")
	local countDown = objectReference:GetRefValue("countDown")
	local txtDiscountCountDown = objectReference:GetRefValue("txtDiscountCountDown")
	local countDownDiscount = objectReference:GetRefValue("countDownDiscount")
	local txtHas = objectReference:GetRefValue("txtHas")
	local txtSoldOut = objectReference:GetRefValue("txtSoldOut")
	local txtDiscount = objectReference:GetRefValue("txtDiscount")
	local txtNew = objectReference:GetRefValue("txtNew")
	local txtBaseCost = objectReference:GetRefValue("txtBaseCost")
	local txtDiscountCost = objectReference:GetRefValue("txtDiscountCost")
	local imgCost = objectReference:GetRefValue("imgCost")
	local textLocke = objectReference:GetRefValue("textLocke")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local numUWidget = objectReference:GetRefValue("numUWidget")
	local txtItemNum = objectReference:GetRefValue("txtItemNum")

	ClientTextUtils.setText(txtTitle, data.name and pg.getLocalizationText(data.name) or LuaUIUtils.getNameByItemId(data.itemId))
	newUWidget:SetActive(data.tagText)

	if data.tagText then
		ClientTextUtils.setText(txtNew, pg.getLocalizationText(data.tagText))
	end

	ClientTextUtils.setText(txtHas, pg.getGameString("SHOP_ALREADYHAVE"))
	ClientTextUtils.setText(txtSoldOut, pg.getGameString("SHOP_SELLOUT"))
	ClientTextUtils.setText(txtDiscountCountDown, pg.getGameString("SHOP_DISCOUNT"))

	if numUWidget then
		local showGetNum = data.num and data.num > 1

		numUWidget:SetActive(showGetNum)

		if showGetNum then
			ClientTextUtils.setText(txtItemNum, string.format("x %d", data.num))
		end
	end

	local specialStartTime = Utils.getConfigTimeOfArea(data, "specialStartTime")
	local specialEndTime = Utils.getConfigTimeOfArea(data, "specialEndTime")
	local endTime = Utils.getConfigTimeOfArea(data, "endTime")

	data.isInDiscount = specialStartTime and specialEndTime and TimeUtils.isInRangeTimestamp(specialStartTime, specialEndTime)

	local baseCost = data.cost and data.cost[1]
	local specialCost = data.specialCost and data.specialCost[1]
	local displayCost = ClientCashShopUtils.getCommodityPrimaryCost(data.commodityId or data.id, 1, {
		isInDiscount = data.isInDiscount
	})

	if not displayCost then
		local fallbackCost = specialCost and data.isInDiscount and specialCost or baseCost

		if fallbackCost then
			displayCost = {
				fallbackCost[1],
				fallbackCost[2]
			}
		end
	end

	if imgCost and displayCost and displayCost[1] then
		imgCost.url = LuaUIUtils.getIconByItemId(displayCost[1])
	end

	if specialCost and data.isInDiscount then
		if txtBaseCost then
			ClientTextUtils.setText(txtBaseCost, displayCost and displayCost[2] or 0)
		end

		if txtDiscountCost then
			txtDiscountCost.gameObject:SetActiveEx(true)
			ClientTextUtils.setText(txtDiscountCost, baseCost and baseCost[2] or 0)
		end
	else
		if txtBaseCost then
			ClientTextUtils.setText(txtBaseCost, displayCost and displayCost[2] or 0)
		end

		if txtDiscountCost then
			txtDiscountCost.gameObject:SetActiveEx(false)
		end
	end

	if data.isInDiscount then
		discountCountdownUWidget:SetActive(true)
		discountUWidget:SetActive(true)
		pullUWidget:SetActive(false)
		ClientTextUtils.setText(txtDiscount, pg.getLocalizationText(data.specialCostText))
		LuaUIUtils.setCountDownTime(countDownDiscount, specialEndTime, UIConst.TimeType.OneTime)
	else
		discountCountdownUWidget:SetActive(false)
		discountUWidget:SetActive(false)

		if endTime then
			pullUWidget:SetActive(true)
			LuaUIUtils.setCountDownTime(countDown, endTime, UIConst.TimeType.OneTime)
		else
			pullUWidget:SetActive(false)
		end
	end

	if imgBanner and data.pic then
		imgBanner.url = data.pic
	else
		local itemId = data.itemId

		if data.commodityId then
			local commodityInfo = ClientCashShopUtils.getCommodityData(data.commodityId)

			if commodityInfo then
				itemId = commodityInfo.itemId
			end
		end

		if iconUImage then
			iconUImage.url = ClientCashShopUtils.getCommodityDisplayIcon(data, itemId)
		end

		local itemCfg = itemId and ItemData[itemId]

		button:TryChangePage("Quality", itemCfg and itemCfg.quality)
	end

	local stateData = ClientCashShopUtils.getCommodityStateData(data)
	local state = ClientCashShopUtils.getCommodityStateByNormalizedData(stateData)

	button:TryChangePage("State", state)

	if state == COMMODITY_STATE.LOCKED and textLocke then
		ClientTextUtils.setText(textLocke, LuaUIUtils.getCommodityUnlockDesc(stateData))
	end
end

function ClientCashShopUtils._openPurchaseConfirm(commodityId, cost, costs, buyCount, desc, confirmCb, rewardItems, displayGender)
	if cost and cost[1] then
		local totalPrice = cost[2] or 0
		local ownNum = ClientUtils.getItemCountById(cost[1]) or 0
		local costIdNums = ClientCashShopUtils.genMallCostIdNums(costs or {})
		local canAfford, adjustedCostIdNums = ClientCashShopUtils.canAffordCostIdNums(costIdNums)

		if totalPrice > 0 and ownNum < totalPrice then
			local costItemCfg = ItemData[cost[1]]

			if costItemCfg then
				if cost[1] == ItemConst.ITEM_SPECIAL_MONEY_COIN_BOUND then
					local cashNum = ClientUtils.getItemCountById(ItemConst.ITEM_SPECIAL_MONEY_CASH_BOUND) or 0

					if totalPrice <= cashNum + ownNum then
						local offerNum = totalPrice - ownNum
						local coinDesc = pg.getFormatText("{0} {1}", LuaUIUtils.getItemShowText(ItemConst.ITEM_SPECIAL_MONEY_CASH_BOUND), offerNum)
						local boundDesc = pg.getFormatText("{0} {1}", LuaUIUtils.getItemShowText(ItemConst.ITEM_SPECIAL_MONEY_COIN_BOUND), offerNum)
						local changeDesc = pg.getFormatText(pg.getGameString("SHOPMALL_EXCHANGE_TEXT"), coinDesc, boundDesc)

						if ClientCashShopUtils.onExchangeConfirmOpen then
							ClientCashShopUtils.onExchangeConfirmOpen()
						end

						ClientCashShopUtils.openBuyCommonUseConfirm(commodityId, buyCount, changeDesc, confirmCb, cost, rewardItems, ItemConst.ITEM_SPECIAL_MONEY_CASH_BOUND, displayGender)
					else
						if ClientCashShopUtils.onPaymentJump then
							ClientCashShopUtils.onPaymentJump()
						end

						local commCfg = CommodityData[commodityId]

						if commCfg then
							RechargeUtils.openQuickPay({
								itemId = commCfg.itemId,
								itemNum = (commCfg.num or 1) * buyCount,
								needCount = totalPrice,
								currencyID = cost[1],
								categoryType = CashShopConst.CategoryType.ITEM,
								displayGender = displayGender,
								buyCallBack = function()
									ClientCashShopUtils.openBuyConfirm(commodityId, cost, buyCount)
								end
							})
						end
					end
				elseif cost[1] == ItemConst.ITEM_SPECIAL_MONEY_CASH_BOUND then
					if ClientCashShopUtils.onPaymentJump then
						ClientCashShopUtils.onPaymentJump()
					end

					local commCfg = CommodityData[commodityId]

					if commCfg then
						RechargeUtils.openQuickPay({
							itemId = commCfg.itemId,
							itemNum = (commCfg.num or 1) * buyCount,
							needCount = totalPrice,
							currencyID = cost[1],
							categoryType = CashShopConst.CategoryType.ITEM,
							displayGender = displayGender,
							buyCallBack = function()
								ClientCashShopUtils.openBuyConfirm(commodityId, cost, buyCount)
							end
						})
					end
				else
					pg.global.showBubbleMessage(NoticeDef.SHOP_ITEM_NOT_ENOUGH, pg.getLocalizationText(costItemCfg.itemName))
				end
			end

			return
		end

		if totalPrice > 0 and not canAfford then
			local notEnoughItemId = ClientCashShopUtils.getNotEnoughCostItemId(adjustedCostIdNums) or cost[1]
			local costItemCfg = ItemData[notEnoughItemId]

			if costItemCfg then
				pg.global.showBubbleMessage(NoticeDef.SHOP_ITEM_NOT_ENOUGH, pg.getLocalizationText(costItemCfg.itemName))
			end

			return
		end
	end

	if ClientCashShopUtils.onExchangeConfirmOpen then
		ClientCashShopUtils.onExchangeConfirmOpen()
	end

	ClientCashShopUtils.openBuyCommonUseConfirm(commodityId, buyCount, desc, confirmCb, cost, rewardItems, nil, displayGender)
end

function ClientCashShopUtils.openBuyCommonUseConfirm(commodityId, buyCount, desc, confirmCb, cost, rewardItems, exchangeCostId, displayGender)
	local commodity = ClientCashShopUtils.getCommodityData(commodityId)

	if not commodity then
		return
	end

	local secStartTime = Time.realSecondCache

	local function sendSecLog(reason)
		LuaUIUtils.sendCustomLog(Const.BILogName.SHOPPING_MALL_SEC_STAY, {
			leaving_reason_sec = reason,
			stay_time_sec = math.floor(Time.realSecondCache - secStartTime),
			currency_id = cost and cost[1] or 0,
			currency_amount = cost and (cost[2] or 0) or 0,
			item_id = commodity.itemId,
			item_amount = buyCount
		})
	end

	displayGender = displayGender or ClientCashShopUtils.getPlayerGender()

	local displayItemId = ClientCashShopUtils.getGenderConvertedItemId(commodity.itemId, displayGender) or commodity.itemId
	local rewardData = {
		{
			displayItemId,
			(commodity.num or 1) * buyCount,
			ownNum = 1,
			hideOwnNum = true
		}
	}

	if rewardItems then
		local items = {}

		for _, itemInfo in pairs(rewardItems) do
			local data = {}
			local displayRewardItemId = ClientCashShopUtils.getGenderConvertedItemId(itemInfo.id, displayGender) or itemInfo.id

			table.insert(data, displayRewardItemId)
			table.insert(data, itemInfo.num)

			data.hideOwnNum = true
			data.ownNum = 1

			table.insert(items, data)
		end

		rewardData = items
		rewardData.muteCheckEnough = true
	end

	local costId = cost and cost[1]
	local openData = {
		muteCheckEnough = true,
		type = 1,
		title = pg.getGameString("SHOP_BUY_READY"),
		tipTop = desc,
		data = rewardData,
		notEnoughCallback = function(itemId, itemNum)
			pg.global.showBubbleMessage(NoticeDef.HOME_REDEEM_LACK)
		end,
		confirmCb = function()
			sendSecLog(1)

			if confirmCb then
				confirmCb()
			end
		end,
		cancelCb = function()
			sendSecLog(0)
		end
	}

	if costId then
		openData.costId = costId

		if exchangeCostId and exchangeCostId ~= costId then
			openData.exchangeCostId = exchangeCostId
		end
	else
		openData.hideCurrency = 1
	end

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_COMMON_USE_CONFIRM) then
		pg.global.ui.commonUseConfirm:close()
	end

	pg.global.ui.commonUseConfirm:open(openData)
end

function ClientCashShopUtils.openCurrencyPurchaseExchangeConfirm(sourceCurrency, targetCurrency, confirmCb, options)
	if not Utils.isTable(sourceCurrency) or not Utils.isTable(targetCurrency) then
		return false
	end

	local sourceCurrencyId, sourceCurrencyNum = ClientCashShopUtils.normalizeCostEntry(sourceCurrency)
	local targetCurrencyId, targetCurrencyNum = ClientCashShopUtils.normalizeCostEntry(targetCurrency)

	if not sourceCurrencyId or not sourceCurrencyNum or sourceCurrencyNum <= 0 or not targetCurrencyId or not targetCurrencyNum or targetCurrencyNum <= 0 then
		return false
	end

	local sourceDesc = pg.getFormatText("{0} {1}", LuaUIUtils.getItemShowText(sourceCurrencyId), sourceCurrencyNum)
	local targetDesc = pg.getFormatText("{0} {1}", LuaUIUtils.getItemShowText(targetCurrencyId), targetCurrencyNum)

	options = Utils.isTable(options) and options or EMPTY_TABLE

	local changeDesc = pg.getFormatText(pg.getGameString(options.exchangeTextKey or "RANDOM_SHOP_EXCHANGE"), sourceDesc, targetDesc)
	local confirmData = {}
	local confirmType = 4

	if Utils.isTable(options.displayItem) then
		local displayItemId, displayItemNum = ClientCashShopUtils.normalizeCostEntry(options.displayItem)

		if displayItemId and displayItemNum and displayItemNum > 0 then
			confirmData = {
				{
					displayItemId,
					displayItemNum,
					ownNum = 1,
					hideOwnNum = true
				}
			}
			confirmType = 1
		end
	end

	if ClientCashShopUtils.onExchangeConfirmOpen then
		ClientCashShopUtils.onExchangeConfirmOpen()
	end

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_COMMON_USE_CONFIRM) then
		pg.global.ui.commonUseConfirm:close()
	end

	pg.global.ui.commonUseConfirm:open({
		muteCheckEnough = true,
		title = pg.getGameString("SHOP_BUY_READY"),
		tipTop = changeDesc,
		data = confirmData,
		type = confirmType,
		costId = targetCurrencyId,
		exchangeCostId = sourceCurrencyId,
		confirmCb = function()
			if confirmCb then
				confirmCb(sourceCurrency, targetCurrency)
			end
		end
	})

	return true
end

function ClientCashShopUtils.openBuyConfirm(commodityId, cost, buyCount, giftSelectItemIds, rewardItems, callback)
	local costs, errorCode = ClientCashShopUtils.getCommodityCostList(commodityId, buyCount)

	if not costs then
		ClientCashShopUtils.showCommodityPriceCalcError(errorCode)

		return
	end

	local summaryCost = costs[1] and {
		costs[1].itemId,
		costs[1].totalPrice
	} or cost
	local totalPrice = summaryCost and (summaryCost[2] or 0) or 0
	local costIcon = LuaUIUtils.getItemShowText(summaryCost and summaryCost[1])
	local desc = pg.getFormatText(pg.getGameString("SHOP_BUY_SELF"), costIcon, totalPrice)

	ClientCashShopUtils._openPurchaseConfirm(commodityId, summaryCost, costs, buyCount, desc, function()
		ClientCashShopUtils.requestBuyItem(commodityId, buyCount, giftSelectItemIds, callback)
	end, rewardItems)
end

function ClientCashShopUtils.openGiveConfirm(targetPlayerId, commodityId, cost, buyCount, msg, receiverGender)
	local costs, errorCode = ClientCashShopUtils.getCommodityCostList(commodityId, buyCount, {
		forGive = true
	})

	if not costs then
		ClientCashShopUtils.showCommodityPriceCalcError(errorCode)

		return
	end

	local summaryCost = costs[1] and {
		costs[1].itemId,
		costs[1].totalPrice
	} or cost
	local totalPrice = summaryCost and (summaryCost[2] or 0) or 0
	local costIcon = LuaUIUtils.getItemShowText(summaryCost and summaryCost[1])
	local targetPlayerUid = tostring(targetPlayerId)
	local displayName = LuaUIUtils.getPlayerDisplayName(targetPlayerUid, "", false)
	local _h = ClientCashShopUtils._platformHooks

	if _h and _h.resolveGiftReceiverName then
		displayName = _h.resolveGiftReceiverName(targetPlayerUid, displayName)
	end

	local desc = pg.getFormatText(pg.getGameString("SHOP_BUY_SEND"), costIcon, totalPrice, displayName)

	ClientCashShopUtils._openPurchaseConfirm(commodityId, summaryCost, costs, buyCount, desc, function()
		ClientCashShopUtils.requestGiveItem(targetPlayerId, commodityId, buyCount, msg)
	end, nil, receiverGender)
end

function ClientCashShopUtils.requestBuyItem(commodityId, count, giftSelectItemIds, callback)
	if not pg.me then
		return
	end

	giftSelectItemIds = giftSelectItemIds or {}

	pg.me:serverMsg("RPC_CS_ShopMallBuyCommodity", commodityId, count, giftSelectItemIds, function(retStatus, newGenId)
		if callback then
			callback(retStatus, newGenId)
		end

		if retStatus == 0 then
			facade:sendMsgToUI(MessageName.CASH_SHOP_ON_BUY_ITEM, {
				success = true,
				commodityId = commodityId,
				count = count,
				genId = newGenId
			})
		else
			ClientUtils.showBubbleMessage(retStatus)
		end
	end)
end

function ClientCashShopUtils.requestGiveItem(targetPlayerId, commodityId, count, msg, callback)
	if not pg.me then
		return
	end

	_pendingGiveRequest = {
		targetPlayerId = targetPlayerId,
		commodityId = commodityId,
		count = count,
		callback = callback
	}

	pg.me:serverMsg("RPC_CS_ShopMallGiveCommodity", targetPlayerId, commodityId, count, msg or "")
end

function ClientCashShopUtils.onGiveItemResult(retStatus)
	if retStatus == NoticeDef.SHOPMALL_COMMODITY_GIVE_CHECKING then
		return
	end

	local pending = _pendingGiveRequest

	_pendingGiveRequest = nil

	if pending and pending.callback then
		pending.callback(retStatus)
	end

	if retStatus == 0 then
		facade:sendMsgToUI(MessageName.CASH_SHOP_ON_BUY_ITEM, {
			success = true,
			give = true,
			commodityId = pending and pending.commodityId,
			count = pending and pending.count,
			targetPlayerId = pending and pending.targetPlayerId
		})
	else
		ClientUtils.showBubbleMessage(retStatus)
	end
end

function ClientCashShopUtils.getAppearanceGenderVariants(appearanceId)
	local variants = {
		[appearanceId] = true
	}
	local convertData = ItemConditionConvertData[appearanceId]

	if convertData and convertData.targetItem then
		for _, entry in ipairs(convertData.targetItem) do
			if entry[1] == CONDITION_FEMALE or entry[1] == CONDITION_MALE then
				variants[entry[2]] = true
			end
		end
	end

	return variants
end

function ClientCashShopUtils.isAppearanceOnSale(appearanceId)
	if not appearanceId then
		return false
	end

	local commodityIds = ClientCashShopUtils.getCommodityIdsByAppearanceItemId(appearanceId)

	if not commodityIds then
		return false
	end

	for _, commodityId in ipairs(commodityIds) do
		if ClientCashShopUtils.isCommodityOnShelf(CommodityData[commodityId], commodityId) then
			return true
		end
	end

	return false
end

return ClientCashShopUtils
