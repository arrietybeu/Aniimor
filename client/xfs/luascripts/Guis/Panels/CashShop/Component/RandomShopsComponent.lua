-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CashShop\\Component\\RandomShopsComponent.lua

local Class = require("Core.Framework.Class")
local CashShopContainerComponent = require("Guis.Panels.CashShop.Component.CashShopContainerComponent")
local CashShopConst = require("Const.CashShopConst")
local RedDotConst = require("Const.RedDotConst")
local ClientConst = require("Const.ClientConst")
local UIConst = require("Const.UIConst")
local RandomShopConst = require("Common.Const.RandomShopConst")
local NoticeDef = require("Common.NoticeDef")
local Utils = require("Common.Utils.Utils")
local Time = require("Core.Common.Time")
local TimeUtils = require("Common.Utils.TimeUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientUtils = require("Utils.ClientUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ClientCashShopUtils = require("Utils.ClientCashShopUtils")
local CashShopRedDotUtils = require("Utils.CashShopRedDotUtils")
local ItemPropUIUtils = require("Utils.ItemPropUIUtils")
local ItemData = require("Data.item_data")
local CurrencyExchangeData = require("Data.currency_exchange_data")
local RandomShopGoodsPoolData = require("Data.random_shop_goods_pool_data")
local PetPrototypeData = require("Data.pet_prototype_data")
local RANDOM_SHOP_SLOT_COUNT = 4
local ALL_OPEN_INTERVAL = 0.3
local RANDOM_SHOP_REVEAL_DAY_PREFS_KEY = "RandomShopRevealDay_%s"
local RANDOM_SHOP_REVEAL_MASK_PREFS_KEY = "RandomShopRevealMask_%s"
local SHOW_STATE = {
	OPENED = 1,
	UNOPENED = 0,
	SOLD = 2
}
local RIGHT_STATE = {
	EMPTY = 2,
	PROP = 0
}
local EMPTY_STATE = {
	NO_SELECTION = 0,
	SOLD_OUT = 1
}
local PRIZE_TIER_IMG_STATE = {
	3,
	2,
	1,
	0
}
local RandomShopsComponent = Class.LightClass("RandomShopsComponent", CashShopContainerComponent)

function RandomShopsComponent:findObjects()
	if not self:checkContentLoaded() then
		return
	end

	local objectReference = self._embeddedObjectReference

	if self._embedded then
		self.imgBG = self._embeddedImgBG or objectReference:GetRefValue("imgBG")
	else
		CashShopContainerComponent.findObjects(self)

		objectReference = self.transform:GetChild(0):GetComponent("ObjectReference")
	end

	self.shopBuyUComponent = objectReference:GetRefValue("shopBuyUComponent")
	self.propInfoUContainer = objectReference:GetRefValue("propInfoUContainer")
	self.emptyTxt1 = objectReference:GetRefValue("emptyTxt1")
	self.allOpenBtn = objectReference:GetRefValue("allOpenBtn")
	self.txtAllOpenBtn = objectReference:GetRefValue("txtAllOpenBtn")
	self.emptyTxt2 = objectReference:GetRefValue("emptyTxt2")
	self.emptyTxt3 = objectReference:GetRefValue("emptyTxt3")
	self.savePutBtn = objectReference:GetRefValue("savePutBtn")
	self.txtSavePutBtn = objectReference:GetRefValue("txtSavePutBtn")
	self.confirmBtn = objectReference:GetRefValue("confirmBtn")
	self.txtConfirmBtn = objectReference:GetRefValue("txtConfirmBtn")
	self.buyCurrency = objectReference:GetRefValue("buyCurrency")
	self.ruleBtn = objectReference:GetRefValue("ruleBtn")
	self.txtRuleBtn = objectReference:GetRefValue("txtRuleBtn")
	self.refreshCountDown = objectReference:GetRefValue("refreshCountDown")
	self.txtstrikeTxt = objectReference:GetRefValue("txtstrikeTxt")
	self.usedCurrency = objectReference:GetRefValue("usedCurrency")
	self.listPropUList = objectReference:GetRefValue("listPropUList")
	self.lockUWidget = objectReference:GetRefValue("lockUWidget")
	self.bottomUWidget = objectReference:GetRefValue("bottomUWidget")

	self.lockUWidget:SetActive(false)
	self:bindRandomShopRedDot()
end

function RandomShopsComponent:bindRandomShopRedDot()
	local treePath = string.format(RedDotConst.RedDotPath.CASH_SHOP_RANDOM_ALL_OPEN, CashShopConst.CategoryType.EXCHANGE, CashShopConst.ExchangeShopTabType.Random)

	pg.global.setPreViewRedDot(treePath, self.allOpenBtn, function()
		return CashShopRedDotUtils.getRandomShopAllOpenRedDotStyle()
	end)
end

function RandomShopsComponent:addListener()
	if not self._embedded then
		CashShopContainerComponent.addListener(self)
	end

	function self.listPropUList.luaRenderItem(button, index, data)
		self:renderShopItem(button, index, data)
	end

	function self.listPropUList.luaClick(button, data)
		self:onShopItemClick(button, data)
	end

	function self.allOpenBtn.luaClick()
		self:onAllOpenClick()
	end

	function self.savePutBtn.luaClick()
		self:onSavePutClick()
	end

	function self.confirmBtn.luaClick()
		self:onConfirmClick()
	end

	function self.ruleBtn.luaClick()
		local shopData = self.currentShopData

		if shopData and shopData.des then
			pg.global.ui.tips:openEventRuleDesc(pg.getLocalizationText(shopData.des))
		end
	end
end

function RandomShopsComponent:initializeEmbedded(objectReference, randomUComponent, imgBG, ownerComponent)
	self._embedded = true
	self._embeddedObjectReference = objectReference
	self._embeddedRootUComponent = randomUComponent
	self._embeddedImgBG = imgBG
	self._embeddedOwnerComponent = ownerComponent
	self._contentLoaded = true

	self:findObjects()
	self:addListener()
end

function RandomShopsComponent:getRandomShopCurrencyExchangeInfo()
	local shopData = self.currentShopData
	local sourceId = tonumber(shopData and shopData.sourceId)
	local exchangeConfig = sourceId and CurrencyExchangeData[sourceId]
	local exchangeRate = exchangeConfig and exchangeConfig.exchangeRate

	if not sourceId or sourceId <= 0 or not Utils.isTable(exchangeConfig) or not Utils.isTable(exchangeRate) then
		return nil, nil, nil
	end

	local sourceCurrencyId = tonumber(exchangeConfig.source)
	local targetCurrencyId = tonumber(exchangeConfig.target)
	local sourceCurrencyNum = tonumber(exchangeRate.source)
	local targetCurrencyNum = tonumber(exchangeRate.target)

	if not sourceCurrencyId or sourceCurrencyId <= 0 or not targetCurrencyId or targetCurrencyId <= 0 or not sourceCurrencyNum or sourceCurrencyNum <= 0 or not targetCurrencyNum or targetCurrencyNum <= 0 then
		return nil, nil, nil
	end

	return sourceId, {
		sourceCurrencyId,
		sourceCurrencyNum
	}, {
		targetCurrencyId,
		targetCurrencyNum
	}
end

function RandomShopsComponent:openRandomShopGoodsCurrencyExchange(selectedSlot)
	if self._isChangingMoney or not selectedSlot or not selectedSlot.commodityData then
		return false
	end

	local sourceId, sourceCurrencyUnit, targetCurrencyUnit = self:getRandomShopCurrencyExchangeInfo()
	local moneyType = tonumber(self.currentShopData and self.currentShopData.moneyType)
	local targetCurrencyId = tonumber(targetCurrencyUnit and targetCurrencyUnit[1])

	if not sourceId or not moneyType or moneyType ~= targetCurrencyId then
		pg.global.showBubbleMessage(NoticeDef.SHOP_CURRENCY_EXCHANGE_CONFIG_ERROR)

		return false
	end

	local commodityData = selectedSlot.commodityData
	local totalPrice = tonumber(commodityData.price) or 0
	local ownCurrencyNum = ClientUtils.getItemCountById(moneyType) or 0
	local currencyDeficit = totalPrice - ownCurrencyNum
	local targetCurrencyUnitNum = tonumber(targetCurrencyUnit[2]) or 0

	if currencyDeficit <= 0 or targetCurrencyUnitNum <= 0 then
		return false
	end

	local exchangeTimes = math.ceil(currencyDeficit / targetCurrencyUnitNum)
	local sourceCurrency = {
		sourceCurrencyUnit[1],
		sourceCurrencyUnit[2] * exchangeTimes
	}
	local targetCurrency = {
		targetCurrencyUnit[1],
		targetCurrencyUnit[2] * exchangeTimes
	}
	local ownSourceCurrencyNum = ClientUtils.getItemCountById(sourceCurrency[1]) or 0

	if ownSourceCurrencyNum < sourceCurrency[2] then
		pg.global.showBubbleMessageRaw(pg.getGameString("RANDOM_SHOP_MAJOR_CURRENCY"))

		return false
	end

	local shopId = self.currentShopId
	local pos = selectedSlot.slotIndex
	local goodsId = selectedSlot.goodId
	local buyTimes = 1

	return ClientCashShopUtils.openCurrencyPurchaseExchangeConfirm(sourceCurrency, targetCurrency, function()
		self:requestRandomShopMoneyChange(sourceId, exchangeTimes, function(result)
			if result == NoticeDef.SUCCESS then
				self:buyRandomShopGoods(shopId, pos, goodsId, buyTimes)
			end
		end)
	end, {
		exchangeTextKey = "SHOPMALL_EXCHANGE_TEXT",
		displayItem = {
			commodityData.itemId,
			(commodityData.num or 1) * buyTimes
		}
	})
end

function RandomShopsComponent:requestRandomShopMoneyChange(sourceId, targetNum, callback)
	if self._isChangingMoney or not pg.me or not sourceId or not targetNum then
		return false
	end

	self._isChangingMoney = true

	self:refreshActionArea()
	pg.me:serverMsg("RPC_CS_MoneyChange", sourceId, targetNum, function(result)
		self._isChangingMoney = false

		if result == NoticeDef.SUCCESS then
			self:refreshActionArea()
		elseif result then
			pg.global.showBubbleMessage(result)
		end

		if callback then
			callback(result)
		end
	end)

	return true
end

function RandomShopsComponent:refreshPage()
	if self:syncRandomShopRevealState() then
		self._pendingRevealStateReset = true
	end

	self:showRandomShopPet()
	self:refreshStaticUI()

	local revealStateReset = self._pendingRevealStateReset == true

	if self:refreshRandomShopFromServer(revealStateReset) and revealStateReset then
		self._pendingRevealStateReset = false
	end

	self:refreshRefreshCountDown()

	if self:trySelectDefaultOpenedSlotOnEnter() then
		self:refreshRandomShopUI()
	end

	self:startRandomShopDailyRefreshTimer()
end

function RandomShopsComponent:refreshStaticUI()
	ClientTextUtils.setText(self.emptyTxt1, pg.getGameString("RANDOM_SHOP_EMPTY1"))
	ClientTextUtils.setText(self.emptyTxt2, pg.getGameString("RANDOM_SHOP_EMPTY2"))
	ClientTextUtils.setText(self.emptyTxt3, pg.getGameString("RANDOM_SHOP_EMPTY3"))
	ClientTextUtils.setText(self.txtAllOpenBtn, pg.getGameString("RANDOM_SHOP_ALL_OPEN"))
	ClientTextUtils.setText(self.txtRuleBtn, pg.getGameString("RANDOM_SHOP_RULE"))
	ClientTextUtils.setText(self.txtConfirmBtn, pg.getGameString("RANDOM_SHOP_ALL_BUY"))
	ClientTextUtils.setText(self.txtSavePutBtn, pg.getGameString("RANDOM_SHOP_ALL_SAVE"))
end

function RandomShopsComponent:refreshRefreshCountDown()
	if not self.refreshCountDown then
		return
	end

	self.refreshCountDown.luaFinished = nil

	self.refreshCountDown:Stop()

	if not self:hasRemainingPoolGoods() then
		ClientTextUtils.setText(self.refreshCountDown.title, pg.getGameString("RANDOM_SHOP_NOITEM"))

		return
	end

	LuaUIUtils.setCountDownTime(self.refreshCountDown, TimeUtils.getServerNextDayBegin(Time.secondCache), UIConst.TimeType.Short, nil, nil, nil, "RANDOM_SHOP_REFRESH_TIME")
end

function RandomShopsComponent:getServerRandomShop()
	local randomShop = pg.me and pg.me.randomShop

	if not randomShop then
		return nil
	end

	local shopId = randomShop.getShopId and randomShop:getShopId() or randomShop.randomShopBase and randomShop.randomShopBase.shopId

	if tonumber(shopId) ~= tonumber(self.currentShopId) then
		return nil
	end

	return randomShop
end

function RandomShopsComponent:getRandomShopMapValue(map, key)
	if not map then
		return nil
	end

	return map[key] or map[tostring(key)]
end

function RandomShopsComponent:getRandomShopRevealDay()
	return math.floor(TimeUtils.getServerDayBegin(Time.secondCache))
end

function RandomShopsComponent:getRandomShopRevealPrefsKey(keyFormat)
	return string.format(keyFormat, tostring(self.currentShopId or 0))
end

function RandomShopsComponent:syncRandomShopRevealState()
	local shopId = self.currentShopId

	if not shopId then
		self._randomShopRevealDay = nil
		self._randomShopRevealMask = 0

		return false
	end

	local currentDay = self:getRandomShopRevealDay()

	if self._randomShopRevealShopId == shopId and self._randomShopRevealDay == currentDay then
		return false
	end

	local prefsCacheUtils = pg.global and pg.global.prefsCacheUtils
	local dayKey = self:getRandomShopRevealPrefsKey(RANDOM_SHOP_REVEAL_DAY_PREFS_KEY)
	local maskKey = self:getRandomShopRevealPrefsKey(RANDOM_SHOP_REVEAL_MASK_PREFS_KEY)
	local savedDay = prefsCacheUtils and prefsCacheUtils:getInt(dayKey, 0, ClientConst.CACHE_TYPE_FLAG.USER) or self._randomShopRevealDay
	local dayChanged = savedDay ~= currentDay
	local revealMask = 0

	if dayChanged then
		if prefsCacheUtils then
			prefsCacheUtils:setInt(dayKey, currentDay, ClientConst.CACHE_TYPE_FLAG.USER)
			prefsCacheUtils:setInt(maskKey, 0, ClientConst.CACHE_TYPE_FLAG.USER)
		end
	elseif prefsCacheUtils then
		revealMask = prefsCacheUtils:getInt(maskKey, 0, ClientConst.CACHE_TYPE_FLAG.USER)
	else
		revealMask = self._randomShopRevealMask or 0
	end

	self._randomShopRevealShopId = shopId
	self._randomShopRevealDay = currentDay
	self._randomShopRevealMask = tonumber(revealMask) or 0

	return dayChanged
end

function RandomShopsComponent:isRandomShopSlotOpened(slotIndex)
	self:syncRandomShopRevealState()

	local slotFlag = 2^(slotIndex - 1)

	return math.floor((self._randomShopRevealMask or 0) / slotFlag) % 2 == 1
end

function RandomShopsComponent:recordRandomShopSlotOpened(slotIndex)
	self:syncRandomShopRevealState()

	local slotFlag = 2^(slotIndex - 1)
	local revealMask = self._randomShopRevealMask or 0

	if math.floor(revealMask / slotFlag) % 2 == 1 then
		return
	end

	revealMask = revealMask + slotFlag
	self._randomShopRevealMask = revealMask

	local prefsCacheUtils = pg.global and pg.global.prefsCacheUtils

	if prefsCacheUtils then
		local maskKey = self:getRandomShopRevealPrefsKey(RANDOM_SHOP_REVEAL_MASK_PREFS_KEY)

		prefsCacheUtils:setInt(maskKey, revealMask, ClientConst.CACHE_TYPE_FLAG.USER)
	end
end

function RandomShopsComponent:isRandomShopGoodsSoldOut(randomShop, slotIndex)
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

function RandomShopsComponent:buildRandomShopGoodsVersion(randomShop)
	if not randomShop then
		return "none"
	end

	local version = {
		tostring(self.currentShopId)
	}

	for pos = 1, RANDOM_SHOP_SLOT_COUNT do
		version[#version + 1] = tostring(self:getRandomShopMapValue(randomShop.goodsList, pos) or 0)
	end

	return table.concat(version, ":")
end

function RandomShopsComponent:buildRandomShopDataVersion(randomShop, goodsVersion)
	if not randomShop then
		return "none"
	end

	local version = {
		goodsVersion,
		tostring(randomShop.pity or 0),
		tostring(randomShop.refreshCount or 0)
	}

	for pos = 1, RANDOM_SHOP_SLOT_COUNT do
		version[#version + 1] = tostring(self:getRandomShopMapValue(randomShop.posUlockFlag, pos) == true)
		version[#version + 1] = tostring(self:isRandomShopGoodsSoldOut(randomShop, pos))
	end

	return table.concat(version, ":")
end

function RandomShopsComponent:refreshRandomShopFromServer(forceRebuild)
	local randomShop = self:getServerRandomShop()
	local goodsVersion = self:buildRandomShopGoodsVersion(randomShop)
	local dataVersion = self:buildRandomShopDataVersion(randomShop, goodsVersion)

	if not forceRebuild and self._randomShopSlots and dataVersion == self._randomShopDataVersion then
		return false
	end

	self:applyRandomShopServerData(randomShop, goodsVersion, dataVersion)

	return true
end

function RandomShopsComponent:applyRandomShopServerData(randomShop, goodsVersion, dataVersion)
	if self._allOpening or self._allOpenTimerId then
		self:stopAllOpenSequence(nil, true)
	end

	local selectedSlotIndex = self._selectedSlotIndex

	self._randomShopServerData = randomShop
	self._randomShopGoodsVersion = goodsVersion
	self._randomShopDataVersion = dataVersion
	self._randomShopSlots = {}

	for slotIndex = 1, RANDOM_SHOP_SLOT_COUNT do
		local goodId = randomShop and self:getRandomShopMapValue(randomShop.goodsList, slotIndex)

		goodId = tonumber(goodId) or goodId

		local commodityData = goodId and RandomShopGoodsPoolData[goodId]
		local retained = randomShop and self:getRandomShopMapValue(randomShop.posUlockFlag, slotIndex) == true or false
		local showState

		if commodityData then
			if retained then
				self:recordRandomShopSlotOpened(slotIndex)
			end

			if self:isRandomShopGoodsSoldOut(randomShop, slotIndex) then
				showState = SHOW_STATE.SOLD
			elseif retained or self:isRandomShopSlotOpened(slotIndex) then
				showState = SHOW_STATE.OPENED
			else
				showState = SHOW_STATE.UNOPENED
			end
		end

		self._randomShopSlots[slotIndex] = {
			tIndex = commodityData and 0 or 1,
			slotIndex = slotIndex,
			goodId = goodId,
			commodityData = commodityData,
			showState = showState,
			imgState = commodityData and (PRIZE_TIER_IMG_STATE[tonumber(commodityData.prizeTier)] or 3) or 3,
			retained = retained
		}
	end

	local selectedSlot = selectedSlotIndex and self._randomShopSlots[selectedSlotIndex]

	self._selectedSlotIndex = selectedSlot and selectedSlot.showState == SHOW_STATE.OPENED and not self:hasUnopenedSlot() and selectedSlotIndex or nil

	self:trySelectDefaultOpenedSlot()
	self:refreshRandomShopUI()
end

function RandomShopsComponent:refreshRandomShopUI()
	self.listPropUList:SetList(self._randomShopSlots or {})
	self:refreshRefreshCountDown()
	self:refreshShopBuyPanel()
	self:refreshActionArea()
	self:refreshPityArea()
	CashShopRedDotUtils.refreshRandomShopRedDots()

	if self.ctrl.refreshConsoleBarState then
		self.ctrl:refreshConsoleBarState()
	end
end

function RandomShopsComponent:getSelectedSlot()
	return self._selectedSlotIndex and self._randomShopSlots and self._randomShopSlots[self._selectedSlotIndex] or nil
end

function RandomShopsComponent:getDefaultOpenedSlotIndex()
	local hasCommodity = false
	local defaultSlotIndex

	for _, slotData in ipairs(self._randomShopSlots or {}) do
		if slotData.commodityData then
			hasCommodity = true

			if slotData.showState == SHOW_STATE.UNOPENED then
				return nil, true
			end

			if not defaultSlotIndex and slotData.showState == SHOW_STATE.OPENED then
				defaultSlotIndex = slotData.slotIndex
			end
		end
	end

	return defaultSlotIndex, hasCommodity
end

function RandomShopsComponent:trySelectDefaultOpenedSlot()
	if self._selectedSlotIndex then
		return false
	end

	local defaultSlotIndex = self:getDefaultOpenedSlotIndex()

	if not defaultSlotIndex then
		return false
	end

	self._selectedSlotIndex = defaultSlotIndex

	return true
end

function RandomShopsComponent:trySelectDefaultOpenedSlotOnEnter()
	if not self._shouldSelectDefaultOpenedSlotOnEnter or not self._randomShopSlots then
		return false
	end

	local defaultSlotIndex, hasCommodity = self:getDefaultOpenedSlotIndex()

	if not hasCommodity then
		return false
	end

	self._shouldSelectDefaultOpenedSlotOnEnter = false

	if self._selectedSlotIndex or not defaultSlotIndex then
		return false
	end

	self._selectedSlotIndex = defaultSlotIndex

	return true
end

function RandomShopsComponent:isAllSoldOut()
	local hasCommodity = false

	for _, slotData in ipairs(self._randomShopSlots or {}) do
		if slotData.commodityData then
			hasCommodity = true

			if slotData.showState ~= SHOW_STATE.SOLD then
				return false
			end
		end
	end

	return hasCommodity
end

function RandomShopsComponent:hasRemainingPoolGoods()
	local randomShop = self._randomShopServerData or self:getServerRandomShop()
	local buyCount = randomShop and randomShop.buyCount or nil

	if not Utils.isTable(RandomShopGoodsPoolData) or not Utils.isTable(buyCount) then
		return true
	end

	local playerConfigData = pg.me and pg.me:getConfigData()
	local playerGender = tonumber(playerConfigData and playerConfigData.gender)

	for goodId, goodsConfig in pairs(RandomShopGoodsPoolData) do
		if Utils.isTable(goodsConfig) then
			local goodsGender = tonumber(goodsConfig.gender)
			local genderMatched = goodsGender == RandomShopConst.GenderType.ALL or not playerGender or goodsGender == playerGender

			if genderMatched then
				local limitNum = tonumber(goodsConfig.limitNum)

				if not limitNum or limitNum < 0 then
					return true
				end

				local currentBuyCount = tonumber(self:getRandomShopMapValue(buyCount, goodId)) or 0

				if currentBuyCount < limitNum then
					return true
				end
			end
		end
	end

	return false
end

function RandomShopsComponent:hasUnopenedSlot()
	for _, slotData in ipairs(self._randomShopSlots or {}) do
		if slotData.showState == SHOW_STATE.UNOPENED then
			return true
		end
	end

	return false
end

function RandomShopsComponent:hasCommoditySlot()
	for _, slotData in ipairs(self._randomShopSlots or {}) do
		if slotData.commodityData then
			return true
		end
	end

	return false
end

function RandomShopsComponent:refreshShopBuyPanel()
	local selectedSlot = not self:hasUnopenedSlot() and self:getSelectedSlot() or nil
	local soldOut = self._randomShopSlots ~= nil and (self:isAllSoldOut() or not self:hasCommoditySlot())

	if not selectedSlot or soldOut then
		self.shopBuyUComponent:TryChangePage("RightState", RIGHT_STATE.EMPTY)
		self.shopBuyUComponent:TryChangePage("EmptyState", soldOut and EMPTY_STATE.SOLD_OUT or EMPTY_STATE.NO_SELECTION)

		if soldOut then
			ClientTextUtils.setText(self.emptyTxt3, pg.getGameString(self:hasRemainingPoolGoods() and "RANDOM_SHOP_EMPTY3" or "RANDOM_SHOP_EMPTY4"))
		end

		return
	end

	local commodityData = selectedSlot.commodityData

	self.shopBuyUComponent:TryChangePage("RightState", RIGHT_STATE.PROP)

	local selectedSlotIndex = selectedSlot.slotIndex

	LuaUIUtils.renderItemInfo(self.propInfoUContainer, {
		skipFoldHotkey = true,
		fromParamCount = true,
		itemId = commodityData.itemId,
		uiStyle = UIConst.ITEM_INFO_STATE.SHOP,
		validate = function()
			return self._selectedSlotIndex == selectedSlotIndex
		end
	})
end

function RandomShopsComponent:refreshActionArea()
	local selectedSlot = self:getSelectedSlot()
	local commodityData = selectedSlot and selectedSlot.commodityData
	local canOperateSelected = commodityData ~= nil and selectedSlot.showState == SHOW_STATE.OPENED and not self:hasUnopenedSlot()
	local isRequesting = self._isBuyingGoods or self._isSettingGoodsLock or self._isChangingMoney

	self.allOpenBtn.interactable = self:hasUnopenedSlot() and not self._allOpening and not isRequesting
	self.savePutBtn.interactable = canOperateSelected and commodityData.canLock == 1 and not isRequesting
	self.confirmBtn.interactable = canOperateSelected == true and not isRequesting

	local isRetained = canOperateSelected and selectedSlot.retained == true

	self.savePutBtn:TryChangePage("Btnstate", isRetained and 0 or 1)
	ClientTextUtils.setText(self.txtSavePutBtn, pg.getGameString(isRetained and "RANDOM_SHOP_ALL_PUT" or "RANDOM_SHOP_ALL_SAVE"))
	self.buyCurrency:SetActive(canOperateSelected)

	if canOperateSelected then
		ItemPropUIUtils.renderConsumeItem(self.buyCurrency, {
			self.currentShopData.moneyType,
			commodityData.price
		}, false, false, false)
	end
end

function RandomShopsComponent:refreshPityArea()
	local showPity = tonumber(self.currentShopData and self.currentShopData.showPity) == 1

	self.bottomUWidget:SetActive(showPity)

	if not showPity then
		return
	end

	local randomShop = self._randomShopServerData or self:getServerRandomShop()
	local usedCurrency = tonumber(randomShop and randomShop.pity) or 0
	local pityTarget = self:getRandomShopPityTarget(self.currentShopData.pityParam)
	local poolCleared = not self:hasRemainingPoolGoods()
	local pityReached = pityTarget and pityTarget > 0 and pityTarget <= usedCurrency
	local textKey

	textKey = poolCleared and "RANDOM_SHOP_DONE" or pityReached and "RANDOM_SHOP_MAJOR_ITEM" or "RANDOM_SHOP_NEXT_GUARANTEE"

	ClientTextUtils.setText(self.txtstrikeTxt, pg.getGameString(textKey))

	local showUsedCurrency = not poolCleared and not pityReached

	self.usedCurrency:SetActive(showUsedCurrency)

	if not showUsedCurrency then
		return
	end

	ItemPropUIUtils.renderConsumeItem(self.usedCurrency, {
		self.currentShopData.moneyType,
		usedCurrency
	}, false, false, true)

	if pityTarget and pityTarget > 0 then
		local objectReference = self.usedCurrency:GetComponent("ObjectReference")
		local txtNum = LuaUIUtils.safeGetRefValue(objectReference, "txtNum")

		if txtNum then
			ClientTextUtils.setText(txtNum, string.format("%d/%d", usedCurrency, pityTarget))
		end
	end
end

function RandomShopsComponent:getRandomShopPityTarget(pityParam)
	if not Utils.isTable(pityParam) then
		return tonumber(pityParam)
	end

	local pityTarget

	for value in pairs(pityParam) do
		value = tonumber(value)

		if value and value > 0 and (not pityTarget or value < pityTarget) then
			pityTarget = value
		end
	end

	return pityTarget
end

function RandomShopsComponent:playShopItemOpenSfx(slotIndex)
	local slotData = self._randomShopSlots and self._randomShopSlots[slotIndex]
	local commodityData = slotData and slotData.commodityData

	if not commodityData then
		return
	end

	local isTopPrize = tonumber(commodityData.prizeTier) == RandomShopConst.PrizeTier.TOP

	pg.game.audio:playEvent(isTopPrize and "SFX_UI_Submit_PetSSR" or "SFX_UI_Submit_PetR")
end

function RandomShopsComponent:invokeShopItemShow(slotIndex, fallbackButton)
	local button = fallbackButton
	local found, listButton = self.listPropUList:TryGetChildAt(slotIndex - 1)

	if found and listButton then
		button = listButton
	end

	if button then
		button:InvokeCallback(CS.XGUI.EInvokeTime.Show)
		self:playShopItemOpenSfx(slotIndex)
	end
end

function RandomShopsComponent:refreshShopItemInteractionState()
	local hasUnopened = self:hasUnopenedSlot()

	self.listPropUList:SetNavGroupItemFocusStateOverride(hasUnopened, CS.XGUI.Navigation.NavFocusState.Hover)

	for _, slotData in ipairs(self._randomShopSlots or {}) do
		if slotData.commodityData then
			local found, button = self.listPropUList:TryGetChildAt(slotData.slotIndex - 1)

			if found and button then
				button.interactable = slotData.showState == SHOW_STATE.UNOPENED or not hasUnopened

				button:SetSelected(not hasUnopened and slotData.slotIndex == self._selectedSlotIndex)
			end
		end
	end
end

function RandomShopsComponent:onShopItemClick(button, slotData)
	if self._allOpening or self._isBuyingGoods or self._isSettingGoodsLock or not slotData or not slotData.commodityData then
		return
	end

	local openedNow = false
	local shouldFocusNext = false

	if slotData.showState == SHOW_STATE.UNOPENED then
		shouldFocusNext = true
		slotData.showState = SHOW_STATE.OPENED

		self:recordRandomShopSlotOpened(slotData.slotIndex)

		openedNow = true
	end

	if slotData.showState ~= SHOW_STATE.OPENED and slotData.showState ~= SHOW_STATE.SOLD then
		return
	end

	if self:hasUnopenedSlot() then
		self._selectedSlotIndex = nil
	elseif openedNow then
		self._selectedSlotIndex = nil

		self:trySelectDefaultOpenedSlot()
	else
		self._selectedSlotIndex = slotData.slotIndex
	end

	self.listPropUList:RefreshElement(slotData.slotIndex - 1)
	self:refreshShopItemInteractionState()

	if openedNow then
		self:invokeShopItemShow(slotData.slotIndex, button)
	end

	self:refreshShopBuyPanel()
	self:refreshActionArea()

	if openedNow then
		CashShopRedDotUtils.refreshRandomShopRedDots()
	end

	if shouldFocusNext and pg.game.input:isUsingGamepad() then
		self:focusNextShopItem(slotData.slotIndex)
	end

	if self.ctrl.refreshConsoleBarState then
		self.ctrl:refreshConsoleBarState()
	end
end

function RandomShopsComponent:focusNextShopItem(slotIndex)
	for nextSlotIndex = slotIndex + 1, RANDOM_SHOP_SLOT_COUNT do
		local nextSlot = self._randomShopSlots and self._randomShopSlots[nextSlotIndex]

		if nextSlot and nextSlot.commodityData and nextSlot.showState == SHOW_STATE.UNOPENED then
			local found, nextButton = self.listPropUList:TryGetChildAt(nextSlotIndex - 1)

			if found and nextButton then
				pg.global.navMgr:FocusItem(nextButton, CS.XGUI.Navigation.FocusEntryMode.Restore)

				return
			end
		end
	end
end

function RandomShopsComponent:onSavePutClick()
	if self._isBuyingGoods or self._isSettingGoodsLock or self:hasUnopenedSlot() then
		return
	end

	local selectedSlot = self:getSelectedSlot()

	if not selectedSlot or selectedSlot.showState ~= SHOW_STATE.OPENED or not selectedSlot.commodityData or selectedSlot.commodityData.canLock ~= 1 then
		return
	end

	local shopId = self.currentShopId
	local pos = selectedSlot.slotIndex
	local goodsId = selectedSlot.goodId
	local isLocked = selectedSlot.retained ~= true

	self._isSettingGoodsLock = true

	self:refreshActionArea()

	local requested = self:requestSetGoodsLock(shopId, pos, goodsId, isLocked, function(result)
		self._isSettingGoodsLock = false

		if result == NoticeDef.SUCCESS then
			self:refreshRandomShopFromServer()

			if isLocked then
				pg.global.showBubbleMessageRaw(pg.getGameString("RANDOM_SHOP_REFRESH_RULE"))
			end
		elseif result then
			pg.global.showBubbleMessage(result)
		end

		self:refreshActionArea()
	end)

	if not requested then
		self._isSettingGoodsLock = false

		self:refreshActionArea()
	end
end

function RandomShopsComponent:onConfirmClick()
	if self._isBuyingGoods or self._isSettingGoodsLock or self._isChangingMoney or self:hasUnopenedSlot() then
		return
	end

	local selectedSlot = self:getSelectedSlot()

	if not selectedSlot or selectedSlot.showState ~= SHOW_STATE.OPENED or not selectedSlot.commodityData or not selectedSlot.goodId then
		return
	end

	local shopId = self.currentShopId
	local pos = selectedSlot.slotIndex
	local goodsId = selectedSlot.goodId
	local buyTimes = 1
	local moneyType = tonumber(self.currentShopData and self.currentShopData.moneyType)
	local totalPrice = tonumber(selectedSlot.commodityData.price) or 0
	local ownCurrencyNum = moneyType and ClientUtils.getItemCountById(moneyType) or 0

	if moneyType and ownCurrencyNum < totalPrice then
		self:openRandomShopGoodsCurrencyExchange(selectedSlot)

		return
	end

	self:buyRandomShopGoods(shopId, pos, goodsId, buyTimes)
end

function RandomShopsComponent:buyRandomShopGoods(shopId, pos, goodsId, buyTimes)
	if self._isBuyingGoods or self._isSettingGoodsLock or self._isChangingMoney then
		return false
	end

	self._isBuyingGoods = true

	self:refreshActionArea()

	local requested = self:requestBuyGoods(shopId, pos, goodsId, buyTimes, function(result)
		self._isBuyingGoods = false

		if result == NoticeDef.SUCCESS then
			self:refreshRandomShopFromServer()
		elseif result then
			pg.global.showBubbleMessage(result)
		end

		self:refreshActionArea()
	end)

	if not requested then
		self._isBuyingGoods = false

		self:refreshActionArea()
	end

	return requested
end

function RandomShopsComponent:requestBuyGoods(shopId, pos, goodsId, buyTimes, callback)
	if not pg.me or not shopId or not pos or not goodsId or not buyTimes then
		return false
	end

	pg.me:serverMsg("RPC_CS_RandomShopBuyGoods", shopId, pos, goodsId, buyTimes, callback)

	return true
end

function RandomShopsComponent:requestSetGoodsLock(shopId, pos, goodsId, isLocked, callback)
	if not pg.me or not shopId or not pos or not goodsId then
		return false
	end

	pg.me:serverMsg("RPC_CS_RandomShopSetGoodsLock", shopId, pos, goodsId, isLocked, callback)

	return true
end

function RandomShopsComponent:onAllOpenClick()
	if self._allOpening or self._isBuyingGoods or self._isSettingGoodsLock or not self:hasUnopenedSlot() then
		return
	end

	self._allOpening = true

	self.lockUWidget:SetActive(true)
	self:refreshActionArea()

	local slotIndex = 0
	local pendingComplete = false

	self._allOpenTimerId = self:startTimer(function()
		if pendingComplete then
			self:stopAllOpenSequence(true)

			return
		end

		repeat
			slotIndex = slotIndex + 1
		until slotIndex > RANDOM_SHOP_SLOT_COUNT or self._randomShopSlots[slotIndex].showState == SHOW_STATE.UNOPENED

		if slotIndex <= RANDOM_SHOP_SLOT_COUNT then
			local slotData = self._randomShopSlots[slotIndex]

			slotData.showState = SHOW_STATE.OPENED

			self:recordRandomShopSlotOpened(slotIndex)
			self.listPropUList:RefreshElement(slotIndex - 1)
			self:invokeShopItemShow(slotIndex)
		end

		local completed = slotIndex >= RANDOM_SHOP_SLOT_COUNT or not self:hasUnopenedSlot()

		if completed then
			pendingComplete = true
		end
	end, ALL_OPEN_INTERVAL, true)
end

function RandomShopsComponent:stopAllOpenSequence(completed, skipRefresh)
	if self._allOpenTimerId then
		self:killTimer(self._allOpenTimerId)

		self._allOpenTimerId = nil
	end

	self._allOpening = false

	if NotNil(self.lockUWidget) then
		self.lockUWidget:SetActive(false)
	end

	if self._contentLoaded and not skipRefresh then
		if completed then
			self:trySelectDefaultOpenedSlot()
			self:refreshShopItemInteractionState()
			self:refreshShopBuyPanel()
			CashShopRedDotUtils.refreshRandomShopRedDots()
		end

		self:refreshActionArea()

		local ctrl = self.ctrl

		if ctrl and ctrl.refreshConsoleBarState then
			ctrl:refreshConsoleBarState()
		end
	end
end

function RandomShopsComponent:startRandomShopDailyRefreshTimer()
	if self._dailyRefreshTimerId then
		return
	end

	self._dailyRefreshTimerId = self:startTimer(function()
		if self:syncRandomShopRevealState() then
			self._pendingRevealStateReset = true
		end

		local randomShop = self:getServerRandomShop()
		local goodsVersion = self:buildRandomShopGoodsVersion(randomShop)
		local dataVersion = self:buildRandomShopDataVersion(randomShop, goodsVersion)
		local revealStateReset = self._pendingRevealStateReset == true

		if dataVersion == self._randomShopDataVersion and not revealStateReset then
			return
		end

		if not revealStateReset then
			self:applyRandomShopServerData(randomShop, goodsVersion, dataVersion)

			return
		end

		if self._isDailyRefreshing or self._isBuyingGoods or self._isSettingGoodsLock then
			return
		end

		self._isDailyRefreshing = true

		self:playRandomShopTransition(function(finish)
			self:stopAllOpenSequence()
			self:applyRandomShopServerData(randomShop, goodsVersion, dataVersion)

			self._pendingRevealStateReset = false
			self._isDailyRefreshing = false

			finish()
		end)
	end, 1, true)
end

function RandomShopsComponent:stopRandomShopDailyRefreshTimer(clearPendingReset)
	if self._dailyRefreshTimerId then
		self:killTimer(self._dailyRefreshTimerId)

		self._dailyRefreshTimerId = nil
	end

	self._isDailyRefreshing = false

	if clearPendingReset then
		self._pendingRevealStateReset = false
	end
end

function RandomShopsComponent:showRandomShopPet()
	self:restoreRandomShopPetTransform()

	if self._embeddedOwnerComponent and not self._embeddedOwnerComponent:isRandomShopPageActive() then
		return false
	end

	local shopId, shopData = self.ctrl.model:getCurrentRandomShop()

	self.currentShopId = shopId
	self.currentShopData = shopData

	local modelingId = shopData and shopData.petId
	local petPrototypeData = modelingId and PetPrototypeData[modelingId]
	local avatarComponent = self.ctrl.avatarComponent

	if not petPrototypeData or string.isNilOrEmpty(petPrototypeData.prefabResID) or not avatarComponent then
		return false
	end

	local avatarScene = avatarComponent.avatarScene
	local mirrorRequestToken = self._randomShopMirrorRequestToken
	local posXYZ = self:resolveRandomShopPetTransformParam(shopData.postionIndex)
	local rotXYZ = self:resolveRandomShopPetTransformParam(shopData.rotationIndex)
	local scaleXYZ = self:resolveRandomShopPetTransformParam(shopData.scaleIndex)

	self._randomShopPetModelingId = modelingId

	local entity, originalTransform = avatarComponent:showPetByModelingId(modelingId, nil, posXYZ, rotXYZ, scaleXYZ, function(loadedEntity)
		if mirrorRequestToken ~= self._randomShopMirrorRequestToken or self._randomShopPetModelingId ~= modelingId or self._embeddedOwnerComponent and not self._embeddedOwnerComponent:isRandomShopPageActive() then
			return
		end

		if avatarScene and avatarScene.showRandomShopMirrorPet then
			avatarScene:showRandomShopMirrorPet(loadedEntity, modelingId, petPrototypeData)
		end
	end, petPrototypeData)

	if not entity then
		self._randomShopPetModelingId = nil

		if avatarScene and avatarScene.hideRandomShopMirrorPet then
			avatarScene:hideRandomShopMirrorPet()
		end

		return false
	end

	if self._embeddedOwnerComponent and not self._embeddedOwnerComponent:isRandomShopPageActive() then
		avatarComponent:hideAllEntities()

		self._randomShopPetModelingId = nil
		self._randomShopPetOriginalTransform = nil

		return false
	end

	self._randomShopPetOriginalTransform = originalTransform
	self._showingModel = true
	self._showingPet = true

	if self._embeddedOwnerComponent then
		self._embeddedOwnerComponent._showingModel = true
		self._embeddedOwnerComponent._showingPet = true
	end

	self:_syncBackground()

	if self.ctrl.refreshConsoleBarState then
		self.ctrl:refreshConsoleBarState()
	end

	return true
end

function RandomShopsComponent:resolveRandomShopPetTransformParam(transformParam)
	if not Utils.isTable(transformParam) then
		return nil
	end

	local cashShopParam = transformParam[CashShopConst.PetActionType.CashShop]

	if Utils.isTable(cashShopParam) then
		return cashShopParam
	end

	return transformParam
end

function RandomShopsComponent:restoreRandomShopPetTransform()
	self._randomShopMirrorRequestToken = (self._randomShopMirrorRequestToken or 0) + 1

	local avatarComponent = self.ctrl and self.ctrl.avatarComponent
	local avatarScene = avatarComponent and avatarComponent.avatarScene

	if avatarScene and avatarScene.hideRandomShopMirrorPet then
		avatarScene:hideRandomShopMirrorPet()
	end

	if avatarScene and self._randomShopPetModelingId then
		avatarComponent:restoreModelingPetTransform(self._randomShopPetModelingId, self._randomShopPetOriginalTransform)
	end

	self._randomShopPetModelingId = nil
	self._randomShopPetOriginalTransform = nil
	self._showingModel = false
	self._showingPet = false

	if self._embeddedOwnerComponent then
		self._embeddedOwnerComponent._showingModel = false
		self._embeddedOwnerComponent._showingPet = false
	end
end

function RandomShopsComponent:onBeforeExitPage()
	self:stopAllOpenSequence(nil, true)
	self:stopRandomShopDailyRefreshTimer()
	self:restoreRandomShopPetTransform()
	CashShopContainerComponent.onBeforeExitPage(self)
end

function RandomShopsComponent:onDestroy()
	self:stopAllOpenSequence(nil, true)
	self:stopRandomShopDailyRefreshTimer(true)
	self:restoreRandomShopPetTransform()
	CashShopContainerComponent.onDestroy(self)
end

function RandomShopsComponent:syncEmbeddedGroupData(groupData)
	self._currentGroupData = groupData
	self._currentGroupId = groupData and groupData.id
	self.categoryId = self._currentGroupId
end

function RandomShopsComponent:onEnterEmbeddedPage(groupData)
	self:syncEmbeddedGroupData(groupData)

	self._shouldSelectDefaultOpenedSlotOnEnter = true

	self:refreshPage()
end

function RandomShopsComponent:refreshEmbeddedPage(groupData)
	self:syncEmbeddedGroupData(groupData)
	self:refreshPage()
end

function RandomShopsComponent:onExitEmbeddedPage()
	self:onBeforeExitPage()
end

function RandomShopsComponent:onEnterPage(tabId)
	self._shouldSelectDefaultOpenedSlotOnEnter = true

	CashShopContainerComponent.onEnterPage(self, tabId)
end

function RandomShopsComponent:continueRandomShopTransition(onTransitionCovered)
	if onTransitionCovered then
		onTransitionCovered(function()
			return
		end)
	end
end

function RandomShopsComponent:playRandomShopTransition(onTransitionCovered)
	local shopId, shopData = self.ctrl.model:getCurrentRandomShop()

	self.currentShopId = shopId
	self.currentShopData = shopData

	if not shopData or not shopData.maskRes then
		self:continueRandomShopTransition(onTransitionCovered)

		return false
	end

	pg.global.ui:open(UIConst.UI_ID_SHOP_TRANS, {
		shopClassCfg = shopData,
		onTransitionCovered = function(finish)
			if onTransitionCovered then
				onTransitionCovered(finish)
			else
				finish()
			end
		end
	})

	return true
end

function RandomShopsComponent:renderShopItem(button, index, data)
	if data.tIndex == 1 then
		return
	end

	self.listPropUList:SetNavGroupItemFocusStateOverride(self:hasUnopenedSlot(), CS.XGUI.Navigation.NavFocusState.Hover)

	local objectReference = button:GetComponent("ObjectReference")
	local largeUImage = objectReference:GetRefValue("largeUImage")
	local smallUImage = objectReference:GetRefValue("smallUImage")
	local retainbtnUWidget = objectReference:GetRefValue("retainbtnUWidget")
	local retainTxt = objectReference:GetRefValue("retainTxt")
	local currencyUButton = objectReference:GetRefValue("currencyUButton")
	local nameTxt = objectReference:GetRefValue("nameTxt")
	local emptyTxt = objectReference:GetRefValue("emptyTxt")

	button:TryChangePage("Showstate", data.showState)
	button:TryChangePage("Imgstate", data.imgState)

	local hasUnopened = self:hasUnopenedSlot()

	button.interactable = data.showState == SHOW_STATE.UNOPENED or not hasUnopened

	button:SetSelected(not hasUnopened and data.slotIndex == self._selectedSlotIndex)

	local commodityData = data.commodityData
	local itemId = commodityData and commodityData.itemId
	local itemData = itemId and ItemData[itemId]
	local quality = tonumber(itemData and itemData.quality) or 0

	button:TryChangePage("Quality", quality)
	button:TryChangePage("AniType", quality >= 5 and 1 or 0)

	local icon = itemId and LuaUIUtils.getIconByItemId(itemId) or ""

	largeUImage.gameObject:SetActiveEx(false)
	smallUImage.gameObject:SetActiveEx(commodityData ~= nil)

	largeUImage.url = icon
	smallUImage.url = icon

	retainbtnUWidget:SetActive(data.retained == true)
	ClientTextUtils.setText(retainTxt, pg.getGameString("RANDOM_SHOP_ALL_SAVE"))
	ClientTextUtils.setText(emptyTxt, pg.getGameString("RANDOM_SHOP_SOLD"))
	ClientTextUtils.setText(nameTxt, itemId and LuaUIUtils.getNameByItemId(itemId) or "")
	ItemPropUIUtils.renderConsumeItem(currencyUButton, {
		self.currentShopData.moneyType,
		commodityData and commodityData.price or 0
	}, false, false, true)
end

function RandomShopsComponent:focusOnUnopenCard()
	local navMgr = pg.global.navMgr
	local focused = navMgr and navMgr.CurrentFocusedUContent

	if not focused or IsNil(focused) then
		return false
	end

	for _, slotData in ipairs(self._randomShopSlots or {}) do
		local found, button = self.listPropUList:TryGetChildAt(slotData.slotIndex - 1)

		if found and button == focused then
			return slotData.showState == SHOW_STATE.UNOPENED
		end
	end

	return false
end

function RandomShopsComponent:focusOnCard()
	return not self:isAllSoldOut()
end

return RandomShopsComponent
