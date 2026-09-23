-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Utils\\TradeMarketUtils.lua

local UIConst = require("Const.UIConst")
local Time = require("Core.Common.Time")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local ItemUtils = require("Common.Utils.ItemUtils")
local ItemData = require("Data.item_data")
local ClientUtils = require("Utils.ClientUtils")
local ClientCashShopUtils = require("Utils.ClientCashShopUtils")
local ItemConst = require("Common.Const.ItemConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ItemShowTypeData = require("Data.item_type_show_data")
local ItemPropUIUtils = require("Utils.ItemPropUIUtils")
local TradeItemData = require("Data.trade_items_data")
local SysConfigData = require("Data.sys_config_data")
local AppearanceData = require("Data.appearance_data")
local AppearanceSuitData = require("Data.appearance_suit_data")
local AvatarHairSuitData = require("Data.avatar_hair_suit_data")
local AppearanceJewelryPetData = require("Data.appearance_jewelry_pet_data")
local PetData = require("Data.pet_data")
local PetPriceFactorData = require("Data.pet_price_factor_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local TradeConst = require("Common.Const.TradeConst")
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")
local AppearancePurchaseUtils = require("Utils.AppearancePurchaseUtils")
local TradeMarketUtils = {}
local OA_DATE_UNIX_EPOCH_DAYS = 25569

TradeMarketUtils.SubPageType = {
	Goods = 1,
	Pet = 2
}
TradeMarketUtils.Operation = {
	Sell = 2,
	Buy = 1,
	OnSale = 5,
	Purchased = 4,
	Remove = 3
}
TradeMarketUtils.ListTab = {
	OnSale = 1,
	OnHistory = 3,
	OnNotice = 2
}

function TradeMarketUtils.isAppearanceGoods(itemId)
	if not itemId then
		return false, false
	end

	local isPlayerAppearance = AppearanceSuitData[itemId] ~= nil or AvatarHairSuitData[itemId] ~= nil or AppearanceData[itemId] ~= nil

	if isPlayerAppearance then
		return true, false
	end

	if AppearanceJewelryPetData[itemId] ~= nil then
		return true, true
	end

	return false, false
end

function TradeMarketUtils.getItemName(itemId)
	return ItemUtils.getItemFinalNameStrByItemId(itemId)
end

function TradeMarketUtils.getPetName(petTemplateId)
	local petConfig = PetData[petTemplateId]

	return pg.getLocalizationText(petConfig and petConfig.name or "") or ""
end

function TradeMarketUtils.getGoodsSellMaxCount()
	return SysConfigData.TRADE_STALL_NUM_LIMIT and SysConfigData.TRADE_STALL_NUM_LIMIT[1] or 10
end

function TradeMarketUtils.getPetSellMaxCount()
	return SysConfigData.TRADE_STALL_NUM_LIMIT and SysConfigData.TRADE_STALL_NUM_LIMIT[2] or 6
end

function TradeMarketUtils.getHistoryMaxCount()
	return SysConfigData.TRADE_RECORD_LIMIT or 10
end

function TradeMarketUtils.getFollowFullCount()
	return SysConfigData.TRADE_WATCH_FULL_COUNT or 20
end

function TradeMarketUtils.getTradeCurrency()
	return SysConfigData.TRADE_SELL_CURRENCY_TYPE or 4
end

function TradeMarketUtils.getBoothFeeCurrency()
	return SysConfigData.TRADE_STALL_FEE_CURRENCY_TYPE or 2
end

function TradeMarketUtils.getFreePriceMin()
	return SysConfigData.TRADE_FREE_PRICE_MIN
end

function TradeMarketUtils.getFreePriceMax()
	return SysConfigData.TRADE_FREE_PRICE_MAX
end

function TradeMarketUtils.getGoodsHistoryTabCount()
	return 5
end

function TradeMarketUtils.getBoothFeeStr(boothFeeCurrencyType)
	return string.format("%s <sprite name=\"ui_item_%d_small\">", pg.getGameString("STALL_FEE"), boothFeeCurrencyType)
end

function TradeMarketUtils.getTradeCurrencyUrlPath()
	local costItemId = TradeMarketUtils.getTradeCurrency()

	return LuaUIUtils.getIconByItemId(costItemId, LuaUIUtils.ITEM_ICON_TYPE.ICON_SMALL)
end

function TradeMarketUtils.getSubTabData()
	local ret = {}
	local typeName = SysConfigData.TRADE_TYPE_NAME

	for idx, key in ipairs(typeName) do
		table.insert(ret, {
			icon = "",
			subPageType = idx,
			name = key
		})
	end

	return ret
end

function TradeMarketUtils.getInnerTabDat(subTabIndex)
	local ret = {}
	local typeName = SysConfigData.TRADE_SUBTYPE_NAME

	if typeName and typeName[subTabIndex] then
		local innerTabName = typeName[subTabIndex]
		local length = #innerTabName
		local isFirst = true

		for idx, key in ipairs(innerTabName) do
			table.insert(ret, {
				tIndex = isFirst and 0 or 1,
				subIndex = idx,
				name = key
			})

			isFirst = false
		end

		table.insert(ret, {
			tIndex = 2,
			isFollow = true,
			name = "MY_FOLLOWS",
			subIndex = length + 1
		})
	end

	return ret
end

function TradeMarketUtils.getListTab(needNotice, needHistory)
	local ret = {}

	table.insert(ret, {
		name = "ON_SALE",
		tIndex = 0,
		index = 0,
		tabIndex = TradeMarketUtils.ListTab.OnSale
	})

	if needNotice then
		table.insert(ret, {
			name = "ON_NOTICE",
			index = 1,
			tabIndex = TradeMarketUtils.ListTab.OnNotice,
			tIndex = needHistory and 1 or 2
		})
	end

	if needHistory then
		table.insert(ret, {
			name = "HISTORY",
			tIndex = 2,
			index = 2,
			tabIndex = TradeMarketUtils.ListTab.OnHistory
		})
	end

	return ret
end

function TradeMarketUtils.getRecommendedPriceData(cfgId)
	local config = TradeItemData[cfgId]

	if not config then
		return nil
	end

	local recommendedPrice = config.initRecPrice

	if not recommendedPrice or recommendedPrice <= 0 then
		return nil
	end

	local isFreePrice = config.isFreePrice == 1 and 1 or 0
	local minPrice, maxPrice, stepPrice

	if isFreePrice == 1 then
		minPrice = TradeMarketUtils.getFreePriceMin()
		maxPrice = TradeMarketUtils.getFreePriceMax()
		stepPrice = 1
	else
		local minRatio = SysConfigData.TRADE_RECOMMEND_PRICE_MIN_RATIO
		local maxRatio = SysConfigData.TRADE_RECOMMEND_PRICE_MAX_RATIO
		local stepRatio = SysConfigData.TRADE_RECOMMEND_PRICE_STEP_RATIO

		if not minRatio or not maxRatio or not stepRatio then
			return nil
		end

		minPrice = recommendedPrice * minRatio
		maxPrice = recommendedPrice * maxRatio
		stepPrice = recommendedPrice * stepRatio
	end

	if not minPrice or not maxPrice or minPrice <= 0 or maxPrice < minPrice then
		return nil
	end

	recommendedPrice = math.max(math.floor(recommendedPrice + 0.5), 1)
	minPrice = math.max(math.floor(minPrice + 0.5), 1)
	maxPrice = math.max(math.floor(maxPrice + 0.5), minPrice)
	stepPrice = math.max(math.floor(stepPrice + 0.5), 1)

	return {
		isFreePrice = isFreePrice,
		recommendedPrice = recommendedPrice,
		minPrice = minPrice,
		maxPrice = maxPrice,
		stepPrice = stepPrice
	}
end

function TradeMarketUtils.getPetRecommendedPriceData(cfgId, label, isPerfect)
	local priceData = TradeMarketUtils.getRecommendedPriceData(cfgId)

	if not priceData then
		return nil
	end

	local perfectFlag = (isPerfect == true or isPerfect == 1) and 1 or 0
	local priceFactor

	for _, config in pairs(PetPriceFactorData) do
		if config.label == label and (config.isPerfect or 0) == perfectFlag then
			priceFactor = config.priceFactor

			break
		end
	end

	if not priceFactor or priceFactor <= 0 then
		return priceData
	end

	priceData.recommendedPrice = math.max(math.floor(priceData.recommendedPrice * priceFactor + 0.5), 1)

	return priceData
end

function TradeMarketUtils.showPriceLimitTip(priceData, price)
	if not priceData or priceData.isFreePrice ~= 1 then
		return
	end

	local tipKey

	if price == priceData.maxPrice then
		tipKey = "TRADE_PRICE_MAX_TIP"
	elseif price == priceData.minPrice then
		tipKey = "TRADE_PRICE_MIN_TIP"
	end

	if tipKey then
		pg.global.ui.tips:showTextTip(pg.getGameString(tipKey))
	end
end

function TradeMarketUtils.calcStallFee(totalPrice)
	if not totalPrice or totalPrice <= 0 then
		return 0
	end

	local stallFeeRatio = SysConfigData.TRADE_STALL_FEE_RATIO
	local stallFeeMin = SysConfigData.TRADE_STALL_FEE_MIN
	local stallFeeMax = SysConfigData.TRADE_STALL_FEE_MAX

	if not stallFeeRatio or not stallFeeMin or not stallFeeMax or stallFeeRatio < 0 or stallFeeMin < 0 or stallFeeMax < stallFeeMin then
		return 0
	end

	local stallFee = math.floor(totalPrice * stallFeeRatio + 0.5)

	return math.max(stallFeeMin, math.min(stallFee, stallFeeMax))
end

function TradeMarketUtils.getGoodsData(displaySubType)
	local ret = {}

	if displaySubType == nil then
		return ret
	end

	local currentOADate = TradeMarketUtils.getCurOADate()

	for id, config in pairs(TradeItemData) do
		local startTime = tonumber(config.startTime)
		local hasStarted = not startTime or startTime <= 0 or startTime <= currentOADate

		if config.displayType == TradeMarketUtils.SubPageType.Goods and config.displaySubType == displaySubType and hasStarted then
			local data = {}

			for key, value in pairs(config) do
				data[key] = value
			end

			data.id = id

			local itemConfig = ItemData[id]

			data.itemName = string.lower(itemConfig and itemConfig.itemName and pg.getLocalizationText(itemConfig.itemName) or "")
			ret[#ret + 1] = data
		end
	end

	table.sort(ret, function(a, b)
		local rankA = a.rank or math.huge
		local rankB = b.rank or math.huge

		return rankA < rankB
	end)

	return ret
end

function TradeMarketUtils.getCurOADate()
	local areaOffset = Const.TIME_AREA_OFFSET_UTCO[Utils.getServerArea()] or 0
	local currentTime = Time.secondCache or Time.getSecond()
	local currentOADate = (currentTime + areaOffset) / Const.SECONDS_ONE_DAY + OA_DATE_UNIX_EPOCH_DAYS

	return currentOADate
end

function TradeMarketUtils.getPetData(displaySubType, isFollow)
	local ret = {}

	if displaySubType == nil then
		return ret
	end

	local currentOADate = TradeMarketUtils.getCurOADate()
	local playerHandBookMap = pg.me.petHandbookMap

	for id, config in pairs(TradeItemData) do
		local startTime = tonumber(config.startTime)
		local hasStarted = not startTime or startTime <= 0 or startTime <= currentOADate
		local isUnlock = true

		if config.needUnlock == 1 then
			isUnlock = playerHandBookMap:isCatched(id)
		end

		if config.displayType == TradeMarketUtils.SubPageType.Pet and config.displaySubType == displaySubType and hasStarted and isUnlock then
			local data = {}

			for key, value in pairs(config) do
				data[key] = value
			end

			data.id = id
			ret[#ret + 1] = data
		end
	end

	table.sort(ret, function(a, b)
		local rankA = a.rank or math.huge
		local rankB = b.rank or math.huge

		return rankA < rankB
	end)

	return ret
end

function TradeMarketUtils.openSellPetDetailUI(petInfo)
	pg.global.ui:open(UIConst.UI_ID_TRADE_MARKET_PET_SELL_DETAIL, {
		cfgId = petInfo.templateId,
		petData = petInfo
	})
end

function TradeMarketUtils.openBuyPetDetailUI(cfgId, listingData)
	pg.global.ui:open(UIConst.UI_ID_TRADE_MARKET_PET_BUY_DETAIL, {
		cfgId = cfgId,
		listingData = listingData
	})
end

function TradeMarketUtils.openRemovePetDetailUI(listingData)
	pg.global.ui:open(UIConst.UI_ID_TRADE_MARKET_PET_REMOVE_DETAIL, {
		cfgId = listingData.tradeItemId,
		petData = listingData.assetSnapshot,
		listingData = listingData
	})
end

function TradeMarketUtils.openGoodsDetailBuyUI(itemId, goodsType)
	pg.global.ui:open(UIConst.UI_ID_TRADE_MARKET_GOODS_DETAIL, {
		operation = TradeMarketUtils.Operation.Buy,
		itemId = itemId,
		goodsType = goodsType
	})
end

function TradeMarketUtils.openGoodsDetailSellUI(itemId, goodsType, goodsData)
	pg.global.ui:open(UIConst.UI_ID_TRADE_MARKET_GOODS_DETAIL, {
		operation = TradeMarketUtils.Operation.Sell,
		itemId = itemId,
		goodsType = goodsType,
		goodsData = goodsData
	})
end

function TradeMarketUtils.openGoodsDetailRemoveUI(listingData)
	pg.global.ui:open(UIConst.UI_ID_TRADE_MARKET_GOODS_DETAIL, {
		operation = TradeMarketUtils.Operation.Remove,
		itemId = listingData.tradeItemId,
		listingData = listingData
	})
end

function TradeMarketUtils.openBuyConfirmUI(okCallback, money, itemName, buyNum)
	buyNum = buyNum or 1

	local desc = buyNum > 1 and "TRADE_BUT_TIP_DESC_2" or "TRADE_BUT_TIP_DESC"
	local moneyStr = string.format("<color=#da8000>%s</color>", money)
	local itemNameStr = buyNum > 1 and string.format("<color=#da8000>%s x%d</color>", itemName, buyNum) or string.format("<color=#da8000>%s</color>", itemName)

	pg.global.showConfirmMsgRaw(pg.getGameString("TRADE_BUT_TIP_TITLE"), string.format(pg.getGameString(desc), moneyStr, itemNameStr), okCallback, false)
end

function TradeMarketUtils.openSellConfirmUI(okCallback, money, boothFee, itemName, sellNum, sellDayNum)
	sellNum = sellNum or 1

	local moneyStr = string.format("<color=#da8000>%s</color>", money)
	local boothFeeType = TradeMarketUtils.getBoothFeeCurrency()
	local boothFeeStr = string.format("<sprite name=\"ui_item_%d_small\"><color=#da8000>%s</color>", boothFeeType, boothFee)
	local itemNameStr = sellNum > 1 and string.format("<color=#da8000>%s x%d</color>", itemName, sellNum) or string.format("<color=#da8000>%s</color>", itemName)

	pg.global.showConfirmMsgRaw(pg.getGameString("TRADE_SELL_TIP_TITLE"), string.format(pg.getGameString("TRADE_SELL_TIP_DESC"), moneyStr, boothFeeStr, itemNameStr, sellDayNum), okCallback, false)
end

function TradeMarketUtils.openNoticeTipUI(tradeItemCfg)
	if not tradeItemCfg or tradeItemCfg.isNotice ~= 1 then
		return
	end

	local noticeHours = SysConfigData.TRADE_NOTICE_TIME

	if not noticeHours or noticeHours <= 0 then
		noticeHours = math.floor(TradeConst.TRADE_NOTICE_DURATION / 3600)
	end

	local auditHours = SysConfigData.TRADE_AUDIT_TIME

	if not auditHours or auditHours <= 0 then
		auditHours = math.floor(TradeConst.TRADE_AUDIT_DURATION / 3600)
	end

	local sellingHours = tradeItemCfg.sellingTime or 24
	local sellingDays = math.floor(sellingHours / 24)

	pg.global.showConfirmMsgRaw(pg.getGameString("TRADE_NOTICE_TIP_TITLE"), string.format(pg.getGameString("TRADE_NOTICE_TIP_DESC"), noticeHours, auditHours, sellingDays), function()
		return
	end, true)
end

function TradeMarketUtils.renderEmptyTip(emptyTip, tabIndex)
	if tabIndex == TradeMarketUtils.ListTab.OnSale then
		ClientTextUtils.setText(emptyTip, pg.getGameString("NO_GOODS_ON_SALE"))
	elseif tabIndex == TradeMarketUtils.ListTab.OnNotice then
		ClientTextUtils.setText(emptyTip, pg.getGameString("NO_GOODS_ON_NOTICE"))
	elseif tabIndex == TradeMarketUtils.ListTab.OnHistory then
		ClientTextUtils.setText(emptyTip, pg.getGameString("NO_GOODS_HISTORY"))
	end
end

function TradeMarketUtils.renderListTabTip(tipText, tabIndex, canSelect)
	if tabIndex == TradeMarketUtils.ListTab.OnSale then
		tipText:SetActiveFastest(not canSelect)
		ClientTextUtils.setText(tipText, pg.getGameString("TIP_ON_SALE"))
	elseif tabIndex == TradeMarketUtils.ListTab.OnNotice then
		ClientTextUtils.setText(tipText, pg.getGameString("TIP_ON_NOTICE"))
	elseif tabIndex == TradeMarketUtils.ListTab.OnHistory then
		ClientTextUtils.setText(tipText, string.format(pg.getGameString("TIP_ON_HISTORY"), TradeMarketUtils.getGoodsHistoryTabCount()))
	end
end

function TradeMarketUtils.renderSubTabItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local imgAddUImage = objectReference:GetRefValue("imgAddUImage")
	local imgMaskLockUImage = objectReference:GetRefValue("imgMaskLockUImage")
	local textUBaseText = objectReference:GetRefValue("textUBaseText")

	ClientTextUtils.setText(textUBaseText, pg.getGameString(data.name))
end

function TradeMarketUtils.renderItemBasicInfo(itemId, objectReference)
	if pg.me then
		local t = ItemUtils.getReplacedItemCountTable(pg.me, {
			[itemId] = 1
		})

		itemId = next(t) or itemId
	end

	local itemInfo = ItemData[itemId]

	if not itemInfo then
		return
	end

	local ownNum = ClientUtils.getItemCountById(itemId) or 0
	local isCarryItem = itemInfo and (itemInfo.type == ItemConst.ITEM_TYPE_CARRY_CORE or itemInfo.type == ItemConst.ITEM_TYPE_CARRY_ASSISTED)
	local rootComponent = objectReference:GetRefValue("rootComponent")
	local propName = objectReference:GetRefValue("propName")
	local typeName = objectReference:GetRefValue("typeName")
	local countText = objectReference:GetRefValue("countText")
	local scrollInfo = objectReference:GetRefValue("scrollInfo")
	local carryCoreBoxObjectReference = objectReference:GetRefValue("carryCoreBoxObjectReference")
	local detailOC = scrollInfo.content:GetComponent("ObjectReference")
	local desc = detailOC:GetRefValue("desc")
	local itemDesc = detailOC:GetRefValue("itemDesc")

	rootComponent:TryChangePage("Quality", itemInfo.quality)
	rootComponent:TryChangePage("State", isCarryItem and 1 or 0)

	if propName then
		ClientTextUtils.setText(propName, pg.getLocalizationText(itemInfo.itemName))
	end

	if typeName and itemInfo.displayType and ItemShowTypeData[itemInfo.displayType] then
		ClientTextUtils.setText(typeName, pg.getLocalizationText(ItemShowTypeData[itemInfo.displayType].type))
	end

	if countText then
		ClientTextUtils.setText(countText, ownNum)
	end

	if not isCarryItem then
		ClientTextUtils.setText(itemDesc, pg.getLocalizationText(itemInfo.itemDes))
		ClientTextUtils.setText(desc, pg.getLocalizationText(itemInfo.funcRep))
	elseif carryCoreBoxObjectReference then
		ItemPropUIUtils.refreshCarryModule(carryCoreBoxObjectReference, {
			itemId = itemId
		})
	end
end

function TradeMarketUtils.refreshItemCount(itemId, objectReference)
	local ownNum = ClientUtils.getItemCountById(itemId) or 0
	local countText = objectReference:GetRefValue("countText")

	if countText then
		ClientTextUtils.setText(countText, ownNum)
	end
end

function TradeMarketUtils.renderGoodsItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")

	TradeMarketUtils.renderGoodsItem_Basic(objectReference, button, index, data.id, data.minPrice, true, data.count, data.isFollow)
end

function TradeMarketUtils.renderGoodsItem_Basic(objectReference, button, index, itemId, price, hasStartFrom, count, isFollow, status)
	local iconCostUImage = objectReference:GetRefValue("iconCostUImage")
	local txtNumCostUSDFText = objectReference:GetRefValue("txtNumCostUSDFText")
	local txtFromUSDFText = objectReference:GetRefValue("txtFromUSDFText")
	local txtStyleUSDFText = objectReference:GetRefValue("txtStyleUSDFText")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local txtNumSaleUSDFText = objectReference:GetRefValue("txtNumSaleUSDFText")
	local attentionUContainer = objectReference:GetRefValue("attentionUContainer")
	local stateUContainer = objectReference:GetRefValue("stateUContainer")
	local iconAppearanceUImage = objectReference:GetRefValue("iconAppearanceUImage")
	local iconPropUImage = objectReference:GetRefValue("iconPropUImage")
	local itemData = ItemData[itemId]

	if not itemData then
		return
	end

	button:TryChangePage("Quality", itemData.quality)
	ClientTextUtils.setText(txtNameUSDFText, pg.getLocalizationText(itemData.itemName))

	local itemShowType = itemData.displayType and ItemShowTypeData[itemData.displayType]

	ClientTextUtils.setText(txtStyleUSDFText, pg.getLocalizationText(itemShowType.type))

	local isAppearance = TradeMarketUtils.isAppearanceGoods(itemId)

	button:TryChangePage("Type", isAppearance and 0 or 1)

	if isAppearance then
		local purchaseInfo = AppearancePurchaseUtils.GetPurchaseInfo(itemId)
		local commodityInfo = purchaseInfo and ClientCashShopUtils.getCommodityData(purchaseInfo.commodityId) or nil

		iconAppearanceUImage.url = ClientCashShopUtils.getCommodityDisplayIcon(commodityInfo, itemId)
	else
		iconPropUImage.url = itemData.icon
	end

	if not price or price == 0 then
		txtFromUSDFText:SetActiveFastest(false)
		iconCostUImage:SetActiveFastest(false)
		txtNumSaleUSDFText:SetActiveFastest(false)
		ClientTextUtils.setText(txtNumCostUSDFText, pg.getGameString("NO_SELL_PRICE"))
	else
		txtFromUSDFText:SetActiveFastest(true)
		iconCostUImage:SetActiveFastest(true)
		txtNumSaleUSDFText:SetActiveFastest(true)

		if hasStartFrom then
			txtFromUSDFText:SetActiveFastest(true)
			ClientTextUtils.setText(txtFromUSDFText, pg.getGameString("START_FROM"))
		else
			txtFromUSDFText:SetActiveFastest(false)
		end

		local costItemId = TradeMarketUtils.getTradeCurrency()

		iconCostUImage.url = LuaUIUtils.getIconByItemId(costItemId, LuaUIUtils.ITEM_ICON_TYPE.ICON_SMALL)

		ClientTextUtils.setText(txtNumCostUSDFText, LuaUIUtils.formatShortItemNum(price))
		ClientTextUtils.setText(txtNumSaleUSDFText, count or 0)
	end

	if isFollow then
		attentionUContainer:SetActiveFastest(true)
		attentionUContainer:LoadDefaultUrlManually(function(widget)
			local progress = widget:GetComponent("UProgress")
		end)
	else
		attentionUContainer:SetActiveFastest(false)
	end

	if status then
		stateUContainer:SetActiveFastest(true)
	else
		stateUContainer:SetActiveFastest(false)
	end
end

function TradeMarketUtils.renderMySellGoodsItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")

	if data.isEmpty then
		return
	end

	TradeMarketUtils.renderGoodsItem_Basic(objectReference, button, index, data.tradeItemId, data.unitPrice, false, data.remainCount, false, data.status)
end

function TradeMarketUtils.renderGoodsItem_History(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")

	TradeMarketUtils.renderGoodsItem_Basic(objectReference, button, index, data.tradeItemId, data.dealPrice, false, data.count, false, data.status)

	local txtDateUSDFText = objectReference:GetRefValue("txtDateUSDFText")
	local stateUContainer = objectReference:GetRefValue("stateUContainer")
	local dealTime = LuaUIUtils.timeStampToUtcString(data.dealTs, UIConst.TargetTimeType.Long, false)
	local dealTimeStr = string.format("%s: %s", data.isBuyer and pg.getGameString("PURCHASE") or pg.getGameString("SOLD"), dealTime)

	ClientTextUtils.setText(txtDateUSDFText, dealTimeStr)

	local curTimeTs = Time.secondCache

	if data.auditEndTs and curTimeTs < data.auditEndTs then
		stateUContainer:SetActiveFastest(true)
		stateUContainer:LoadDefaultUrlManually(function(widget)
			local widgetOC = widget:GetComponent("ObjectReference")
			local countDownUCountDown = widgetOC:GetRefValue("countDownUCountDown")
			local txtStateUSDFText = widgetOC:GetRefValue("txtStateUSDFText")

			LuaUIUtils.setCountDownTime(countDownUCountDown, data.auditEndTs, UIConst.TimeType.Short)
		end)
	else
		stateUContainer:SetActiveFastest(false)
	end
end

function TradeMarketUtils._renderGoodsState(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local countDownUCountDown = objectReference:GetRefValue("countDownUCountDown")
	local txtStateUSDFText = objectReference:GetRefValue("txtStateUSDFText")
	local iconUWidget = objectReference:GetRefValue("iconUWidget")
	local imgMaskUWidget = objectReference:GetRefValue("imgMaskUWidget")

	imgMaskUWidget:SetActiveFastest(false)

	if data.status == TradeConst.LISTING_STATUS.NOTICE then
		iconUWidget:SetActive(true)
		countDownUCountDown:SetActive(true)
		txtStateUSDFText:SetActive(false)
		LuaUIUtils.setCountDownTime(countDownUCountDown, data.noticeEndTs, UIConst.TimeType.Short)
	elseif data.status == TradeConst.LISTING_STATUS.SELLING then
		iconUWidget:SetActive(true)
		countDownUCountDown:SetActive(true)
		txtStateUSDFText:SetActive(false)
		LuaUIUtils.setCountDownTime(countDownUCountDown, data.expireTs, UIConst.TimeType.Short)
	elseif data.status == TradeConst.LISTING_STATUS.EXPIRED then
		iconUWidget:SetActive(false)
		countDownUCountDown:SetActive(false)
		txtStateUSDFText:SetActive(true)
		ClientTextUtils.setText(txtStateUSDFText, pg.getGameString("EXPIRED"))
	end
end

function TradeMarketUtils.renderPetItem_Basic(objectReference, button, index, petInfo)
	local petIdDisplay = objectReference:GetRefValue("petIdDisplay")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local priceIconUImage = objectReference:GetRefValue("priceIconUImage")
	local numCPUSDFText = objectReference:GetRefValue("numCPUSDFText")
	local listTagUList = objectReference:GetRefValue("listTagUList")
	local frozenUContainer = objectReference:GetRefValue("frozenUContainer")
	local disableUContainer = objectReference:GetRefValue("disableUContainer")
	local attentionUContainer = objectReference:GetRefValue("attentionUContainer")
	local priceUWidget = objectReference:GetRefValue("priceUWidget")
	local reviewUContainer = objectReference:GetRefValue("reviewUContainer")
	local txtDateUSDFText = objectReference:GetRefValue("txtDateUSDFText")

	iconUImage:SetActive(true)
	priceUWidget:SetActive(true)
	listTagUList:SetActive(true)

	iconUImage.url = LuaUIUtils.getPetIcon(petInfo.iconName, LuaUIUtils.PET_ICON, petInfo.label, petInfo.gender)

	function listTagUList.luaRenderItem(tagButton, tagIndex, tagData)
		LuaUIUtils.renderPetTagList(tagButton, tagData)
		LuaUIUtils.setPetTagLabelToolTip(tagButton, LuaUIUtils.getPetTagInfo(petInfo.templateId, petInfo.label))
	end

	listTagUList:SetList(LuaUIUtils.getPetTagList(petInfo))
end

function TradeMarketUtils.renderPetItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")

	TradeMarketUtils.renderPetItem_Basic(objectReference, button, index, data)

	local priceUWidget = objectReference:GetRefValue("priceUWidget")
	local disableUContainer = objectReference:GetRefValue("disableUContainer")
	local frozenUContainer = objectReference:GetRefValue("frozenUContainer")

	priceUWidget:SetActive(false)

	if data.isFrozen then
		frozenUContainer:SetActiveFastest(true)
		disableUContainer:SetActiveFastest(false)
		frozenUContainer:LoadDefaultUrlManually(function(widget)
			local widgetOC = widget:GetComponent("ObjectReference")
			local countDownUCountDown = widgetOC:GetRefValue("countDownUCountDown")
			local txtFrozenUSDFText = widgetOC:GetRefValue("txtFrozenUSDFText")

			ClientTextUtils.setText(txtFrozenUSDFText, pg.getGameString("FREEZING"))

			if data.frozenEndTs then
				countDownUCountDown:SetActiveFastest(true)
				LuaUIUtils.setCountDownTime(countDownUCountDown, data.frozenEndTs, UIConst.TimeType.Short)
			else
				countDownUCountDown:SetActiveFastest(false)
			end
		end)
	elseif data.needWash then
		disableUContainer:SetActiveFastest(true)
		frozenUContainer:SetActiveFastest(false)
		disableUContainer:LoadDefaultUrlManually(function(widget)
			local widgetOC = widget:GetComponent("ObjectReference")
			local txtDisableUSDFText = widgetOC:GetRefValue("txtDisableUSDFText")

			ClientTextUtils.setText(txtDisableUSDFText, pg.getGameString("NEED_TRAIN"))
		end)
	else
		disableUContainer:SetActiveFastest(false)
		frozenUContainer:SetActiveFastest(false)
	end
end

function TradeMarketUtils.renderMyOnSellPetItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")

	if data.isEmpty then
		local petIdDisplay = objectReference:GetRefValue("petIdDisplay")
		local iconUImage = objectReference:GetRefValue("iconUImage")
		local priceIconUImage = objectReference:GetRefValue("priceIconUImage")
		local numCPUSDFText = objectReference:GetRefValue("numCPUSDFText")
		local listTagUList = objectReference:GetRefValue("listTagUList")
		local frozenUContainer = objectReference:GetRefValue("frozenUContainer")
		local disableUContainer = objectReference:GetRefValue("disableUContainer")
		local attentionUContainer = objectReference:GetRefValue("attentionUContainer")
		local priceUWidget = objectReference:GetRefValue("priceUWidget")
		local reviewUContainer = objectReference:GetRefValue("reviewUContainer")
		local txtDateUSDFText = objectReference:GetRefValue("txtDateUSDFText")

		iconUImage:SetActive(false)
		priceUWidget:SetActive(false)
		listTagUList:SetActive(false)

		return
	end

	local assetSnapshot = data.assetSnapshot
	local petInfo = PetManagementDataHelper.setUpPetInfoByTable(assetSnapshot)

	TradeMarketUtils.renderPetItem_Basic(objectReference, button, index, petInfo)

	local priceIconUImage = objectReference:GetRefValue("priceIconUImage")
	local numCPUSDFText = objectReference:GetRefValue("numCPUSDFText")
	local attentionUContainer = objectReference:GetRefValue("attentionUContainer")
	local disableUContainer = objectReference:GetRefValue("disableUContainer")

	priceIconUImage.url = TradeMarketUtils.getTradeCurrencyUrlPath()

	ClientTextUtils.setText(numCPUSDFText, LuaUIUtils.formatShortItemNum(data.unitPrice * data.count))
	attentionUContainer:SetActiveFastest(false)

	if data.status == TradeConst.LISTING_STATUS.EXPIRED then
		disableUContainer.LoadDefaultUrlManually(function(widget)
			local widgetOC = widget:GetComponent("ObjectReference")
			local txtDisableUSDFText = widgetOC:GetRefValue("txtDisableUSDFText")

			ClientTextUtils.setText(txtDisableUSDFText, pg.getGameString("EXPIRED"))
		end)
	elseif data.status == TradeConst.LISTING_STATUS.NOTICE then
		-- block empty
	elseif data.status == TradeConst.LISTING_STATUS.SELLING then
		-- block empty
	end
end

function TradeMarketUtils.renderPetItem_History(button, index, data)
	local assetSnapshot = data.assetSnapshot
	local petInfo = PetManagementDataHelper.setUpPetInfoByTable(assetSnapshot)
	local objectReference = button:GetComponent("ObjectReference")

	TradeMarketUtils.renderPetItem_Basic(objectReference, button, index, petInfo)

	local priceIconUImage = objectReference:GetRefValue("priceIconUImage")
	local numCPUSDFText = objectReference:GetRefValue("numCPUSDFText")
	local frozenUContainer = objectReference:GetRefValue("frozenUContainer")
	local disableUContainer = objectReference:GetRefValue("disableUContainer")
	local attentionUContainer = objectReference:GetRefValue("attentionUContainer")
	local priceUWidget = objectReference:GetRefValue("priceUWidget")
	local reviewUContainer = objectReference:GetRefValue("reviewUContainer")
	local txtDateUSDFText = objectReference:GetRefValue("txtDateUSDFText")

	frozenUContainer:SetActiveFastest(false)
	disableUContainer:SetActiveFastest(false)

	priceIconUImage.url = TradeMarketUtils.getTradeCurrencyUrlPath()

	ClientTextUtils.setText(numCPUSDFText, LuaUIUtils.formatShortItemNum(data.dealPrice))
	ClientTextUtils.setText(txtDateUSDFText, LuaUIUtils.timeStampToUtcString(data.dealTs, UIConst.TargetTimeType.Long, false))
end

function TradeMarketUtils.renderListTabItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUBaseText = objectReference:GetRefValue("txtNameUBaseText")
	local imgAddUImage = objectReference:GetRefValue("imgAddUImage")

	ClientTextUtils.setText(txtNameUBaseText, pg.getGameString(data.name))
end

function TradeMarketUtils.renderPriceItem(button, index, unitPrice, totalCount, noticeEndTs, tabIndex)
	local objectReference = button:GetComponent("ObjectReference")
	local iconCostUImage = objectReference:GetRefValue("iconCostUImage")
	local txtPriceUSDFText = objectReference:GetRefValue("txtPriceUSDFText")
	local txtNumUSDFText = objectReference:GetRefValue("txtNumUSDFText")
	local txtHistoryUSDFText = objectReference:GetRefValue("txtHistoryUSDFText")
	local txtPublicUSDFText = objectReference:GetRefValue("txtPublicUSDFText")
	local countDownUCountDown = objectReference:GetRefValue("countDownUCountDown")

	iconCostUImage.url = TradeMarketUtils.getTradeCurrencyUrlPath()
	tabIndex = tabIndex or TradeMarketUtils.ListTab.OnSale

	button:TryChangePage("Tab", tabIndex - 1)
	ClientTextUtils.setText(txtPriceUSDFText, unitPrice)
	ClientTextUtils.setText(txtNumUSDFText, totalCount or 0)

	if tabIndex == TradeMarketUtils.ListTab.OnNotice then
		ClientTextUtils.setText(txtPublicUSDFText, pg.getGameString("NOTICE_PERIOD"))

		if noticeEndTs then
			LuaUIUtils.setCountDownTime(countDownUCountDown, noticeEndTs, UIConst.TimeType.Short)
		end
	elseif tabIndex == TradeMarketUtils.ListTab.OnHistory then
		ClientTextUtils.setText(txtHistoryUSDFText)
	elseif tabIndex == TradeMarketUtils.ListTab.OnSale then
		-- block empty
	end
end

function TradeMarketUtils.renderListingItem(button, index, data, tabIndex)
	TradeMarketUtils.renderPriceItem(button, index, data.unitPrice, data.remainCount or data.count or 1, data.noticeEndTs, tabIndex)
end

function TradeMarketUtils.dealMsgErrorCode(errorCode)
	return
end

return TradeMarketUtils
