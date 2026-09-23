-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Shop\\Component\\ShopBuyComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("ShopBuyComponent")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientCashShopUtils = require("Utils.ClientCashShopUtils")
local NoticeDef = require("Common.NoticeDef")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ItemUtils = require("Common.Utils.ItemUtils")
local RogueUtils = require("Utils.RogueUtils")
local ShopCommodityData = require("Data.shop_commodity_data")
local ShopTagData = require("Data.shop_tag_data")
local ShopConst = require("Common.Const.ShopConst")
local Const = require("Common.Const.Const")
local ItemConst = require("Common.Const.ItemConst")
local UIConst = require("Const.UIConst")
local UIComponent = require("Guis.Helper.UIComponent")
local Class = require("Core.Framework.Class")
local Utils = require("Common.Utils.Utils")
local ItemSourceData = require("Data.item_source_data")
local CatchRoguePhaseData = require("Data.catch_rogue_phase_data")
local RechargeUtils = require("GameApp.Recharge.RechargeUtils")
local ShopBuyComponent = Class.LightClass("ShopBuyComponent", UIComponent)
local ClientUtils = require("Utils.ClientUtils")
local GRAB_EGG_SHOP_ITEM_TYPES = {
	[ItemConst.ITEM_TYPE.WEAPON] = true,
	[ItemConst.ITEM_TYPE.ARMOR] = true,
	[ItemConst.ITEM_TYPE.CHIP] = true,
	[ItemConst.ITEM_TYPE.REPAIR_KIT] = true
}

ShopBuyComponent.SHOP_BUY_STATE = {
	SBS_NORMAL = 0,
	SBS_LIMIT_NUM = 7,
	SBS_FREE = 6,
	SBS_NOT_ENOUGH_COIN = 5,
	SBS_LOCKED = 4,
	SBS_SELL_OUT = 3,
	SBS_NOT_ENOUGH_BAG = 2,
	SBS_NOT_ENOUGH_COUNT = 1
}

function ShopBuyComponent:ctor(ctrl, param)
	self.ctrl = ctrl
	self.param = param
	self.model = ctrl.model
	self.view = ctrl.view
	self._pendingAsyncRefreshTags = {}

	self:addListener()
end

function ShopBuyComponent:init()
	self:setItemInfoEmpty(true)

	self.buyCount = 1
	self.curBuyList = self.view.pbBuyListProp

	local shopTags, locateShopTag, locateShopItemId, classifyId = self.model:getSellShopTags(self.param)

	self.shopTags = shopTags

	if #shopTags > 0 then
		self.locateShopTagType = locateShopTag
		self.locateShopItemId = locateShopItemId
		self.shopClassifyId = classifyId

		self.model:prepareShopRefreshList(shopTags)
		self:requestShopRefreshLists(shopTags)
		self.view.uIPrefabShopPanelUComponent:TryChangePage("HaveTab", 0)

		local shopTagList = self:getShopTagList()

		if shopTagList then
			shopTagList:SetList(shopTags)
		end

		if self.ctrl.isRogue then
			self.curBuyList = self.view.pbBuyListRogue
			self.curShopTagType = shopTags[1].id

			self:onRefreshBuyShopList(self.curShopTagType)
		end

		if self.ctrl.isAFKShop then
			self.view.tabUWidget.gameObject:SetActiveEx(#shopTags > 1)
		end
	end
end

function ShopBuyComponent:getShopTagList()
	return self.view.listTabIconUList or self.view.pbBuyListTag
end

function ShopBuyComponent:getItemInfoContainer()
	return self.view.propInfoUContainer or self.view.panelPropInfoUContainer
end

function ShopBuyComponent:setItemInfoEmpty(isEmpty)
	if isEmpty then
		self.curShopItemId = nil
		self.purchaseModuleWidget = nil
	end

	local expectedShopItemId = self.curShopItemId
	local container = self:getItemInfoContainer()

	LuaUIUtils.refreshItemInfoContainer(container, function(content)
		if self.curShopItemId ~= expectedShopItemId then
			return
		end

		content:TryChangePage("isEmpty", isEmpty and 1 or 0)
	end)
end

function ShopBuyComponent:getPurchaseNumSelector()
	if IsNil(self.purchaseModuleWidget) then
		return nil
	end

	local objectReference = self.purchaseModuleWidget:GetComponent("ObjectReference")

	return objectReference:GetRefValue("pbPropInfoNumSelector")
end

function ShopBuyComponent:requestShopRefreshLists(shopTags)
	if not pg.me or not shopTags then
		return
	end

	self._refreshRequestToken = (self._refreshRequestToken or 0) + 1
	self._pendingAsyncRefreshTags = {}

	local requestToken = self._refreshRequestToken

	for i = 1, #shopTags do
		local tagId = shopTags[i].id
		local tagCfg = ShopTagData[tagId]
		local refreshType = tagCfg and tagCfg.refreshType or 0
		local refreshLimit = tagCfg and tagCfg.refreshLimit or 0

		if refreshType > 0 and refreshLimit > 0 then
			pg.me:serverMsg("RPC_CS_GetShopRefreshList", tagId, function(err, idList)
				if requestToken ~= self._refreshRequestToken or not self.model then
					return
				end

				if err == NoticeDef.SHOP_BACKOP_PULL_CIDS then
					self._pendingAsyncRefreshTags[tagId] = true

					return
				end

				self._pendingAsyncRefreshTags[tagId] = nil

				self:applyShopRefreshListResult(tagId, err, idList)
			end)
		end
	end
end

function ShopBuyComponent:applyShopRefreshListResult(tagId, err, idList)
	if not self.model then
		return
	end

	if err == NoticeDef.SUCCESS then
		self.model:setShopRefreshList(tagId, idList or {})
	elseif err == NoticeDef.SHOP_REFRESH_TAG_DISABLED then
		self.model:setShopRefreshDisabled(tagId)
	else
		self.model:setShopRefreshRequestFailed(tagId)

		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("shop refresh list fail tagId=%s err=%s", tagId, err)
		end
	end

	if self.curShopTagType == tagId then
		self:onRefreshBuyShopList(self.curShopTagType, self.locateShopItemId, self.paginationId)
	end
end

function ShopBuyComponent:onMysteriousMerchantRefresh(err, idList)
	local tagId = ShopConst.ShopTagId.Mystic

	if not self._pendingAsyncRefreshTags or not self._pendingAsyncRefreshTags[tagId] then
		return
	end

	self._pendingAsyncRefreshTags[tagId] = nil

	self:applyShopRefreshListResult(tagId, err, idList)
end

function ShopBuyComponent:onShow()
	self:init()
end

function ShopBuyComponent:navigateTo(shopTag, groupId, shopItemId)
	self.locateShopItemId = shopItemId

	if self.ctrl.isRogue then
		self:onRefreshBuyShopList(self.curShopTagType, self.locateShopItemId, self.paginationId)

		self.locateShopItemId = nil

		return
	end

	if not shopTag or shopTag == self.curShopTagType then
		self:onRefreshSubTabList(self.curShopTagType, self.locateShopItemId, groupId)

		self.locateShopItemId = nil

		return
	end

	local tagList = self:getShopTagList()

	if self.shopTags and tagList then
		for i = 1, #self.shopTags do
			if self.shopTags[i].id == shopTag then
				tagList:SelectItem(i - 1)

				break
			end
		end
	end

	self.curShopTagType = shopTag
	self.paginationId = nil

	self:onRefreshSubTabList(self.curShopTagType, self.locateShopItemId, groupId)

	self.locateShopItemId = nil
end

function ShopBuyComponent:onDestroy()
	self._refreshRequestToken = (self._refreshRequestToken or 0) + 1
	self._pendingAsyncRefreshTags = nil
	self.curShopItemId = nil
	self.purchaseModuleWidget = nil
	self.seasonTagIcon = nil

	if self.model then
		self.model:clearShopRefreshList()
	end
end

function ShopBuyComponent:addListener()
	local shopTagList = self:getShopTagList()

	if shopTagList then
		function shopTagList.luaRenderItem(button, index, data)
			self:onSetShopTagItem(button, index, data)
		end
	end

	function self.view.pbBuyListProp.luaRenderItem(button, index, data)
		self:onRefreshItemInfo(button, index, data)
	end

	if self.view.listTabSubUList then
		function self.view.listTabSubUList.luaRenderItem(button, index, data)
			self:onRenderSubTabItem(button, index, data)
		end

		function self.view.listTabSubUList.luaSelectedChanged(uList)
			self:onSubTabSelected(uList)
		end
	end

	if self.view.pbBuyListRogue then
		function self.view.pbBuyListRogue.luaRenderItem(button, index, data)
			self:onRefreshItemInfo(button, index, data)
		end
	end
end

function ShopBuyComponent:onSetShopTagItem(button, index, data)
	local shopTagConfig = self.model:getShopTagConfig(data.id)

	if self.view.listTabIconUList then
		local objectReference = button:GetComponent("ObjectReference")
		local iconUImage = objectReference:GetRefValue("iconUImage")
		local textUBaseText = objectReference:GetRefValue("textUBaseText")
		local hasIcon = not string.isNilOrEmpty(shopTagConfig.tabIcon)

		if iconUImage then
			iconUImage:SetActive(hasIcon)

			if hasIcon then
				iconUImage.url = shopTagConfig.tabIcon
			end
		end

		if textUBaseText then
			ClientTextUtils.setText(textUBaseText, pg.getLocalizationText(shopTagConfig.name))
		end
	else
		local itemComs = self.view:getBuyShopTagItemComs(button)

		ClientTextUtils.setText(itemComs.nameTxt, pg.getLocalizationText(shopTagConfig.name))
	end

	self.ctrl:onShopTagItemRendered(button, index, data)

	function button.luaClick(btn, subData)
		button.isSelected = true
		self.curShopTagType = data.id
		self.paginationId = nil

		self.ctrl:onShopTagSelected(self.curShopTagType)
		self:onRefreshSubTabList(self.curShopTagType, self.locateShopItemId)

		self.locateShopItemId = nil
	end

	if self.locateShopTagType ~= nil and self.locateShopTagType == data.id or self.curShopTagType == nil and self.locateShopTagType == nil then
		button.luaClick()

		self.locateShopTagType = nil
	end

	if self.ctrl.isAFKShop then
		button:TryChangePage("Status", index)
	end
end

function ShopBuyComponent:onRefreshSubTabList(shopTagType, locateShopItemId, locatePaginationId)
	local thirdTabList = self.model:getThirdTabList(shopTagType)
	local haveThirdList = thirdTabList and next(thirdTabList) and true or false
	local showLeftTab = self.shopTags and #self.shopTags > 1
	local pageId = 0

	if haveThirdList then
		pageId = showLeftTab and 1 or 2
	end

	self.view.uIPrefabShopPanelUComponent:TryChangePage("HaveTab", pageId)

	if haveThirdList then
		local selectIndex = 0

		for i = 1, #thirdTabList do
			local data = thirdTabList[i]

			if i == 1 then
				data.tIndex = 0
			elseif i == #thirdTabList then
				data.tIndex = 2
			else
				data.tIndex = 1
			end

			if locatePaginationId ~= nil and data.paginationId == locatePaginationId then
				selectIndex = i - 1
			end
		end

		self.view.listTabSubUList:SetList(thirdTabList)
		self.view.listTabSubUList:SelectItem(selectIndex)
	else
		self:onRefreshBuyShopList(shopTagType, locateShopItemId)
	end
end

function ShopBuyComponent:_refreshSeasonTagInfo()
	local seasonStageInfo = Utils.getCurrentSeasonStage()

	self.seasonTagIcon = seasonStageInfo and seasonStageInfo.seasonTagIcon or ""
end

function ShopBuyComponent:refreshSeasonLimitedTag(itemComs, shopItemConfig)
	if not itemComs.seasonTagUWidget then
		return
	end

	local isSeasonLimited = shopItemConfig.isSeasonLimited == 1

	itemComs.seasonTagUWidget:SetActive(isSeasonLimited)

	if not isSeasonLimited then
		return
	end

	local seasonTagText = shopItemConfig.seasonTagText or ""

	if type(seasonTagText) == "number" then
		seasonTagText = pg.getLocalizationText(seasonTagText)
	end

	ClientTextUtils.setText(itemComs.seasonTagTitleUSDFText, seasonTagText)

	local hasSeasonTagIcon = string.notNilOrEmpty(self.seasonTagIcon)

	itemComs.seasonTagUImage:SetActive(hasSeasonTagIcon)

	if hasSeasonTagIcon then
		itemComs.seasonTagUImage.url = self.seasonTagIcon
	end
end

function ShopBuyComponent:_findShopItemIndex(shopItems, shopItemId)
	if shopItemId == nil then
		return nil
	end

	for index, shopItem in ipairs(shopItems or {}) do
		if shopItem.id == shopItemId then
			return index - 1
		end
	end

	return nil
end

function ShopBuyComponent:onRefreshBuyShopList(shopTagType, locateShopItemId, paginationId)
	self:_refreshSeasonTagInfo()
	self.ctrl:refreshCurrency(shopTagType)

	local allItems, locateIndex = self.model:getBuyShopProps(shopTagType, locateShopItemId, paginationId or self.paginationId)
	local items, extensionItems = self.ctrl:partitionBuyShopListItems(shopTagType, allItems)

	extensionItems = extensionItems or {}

	local locateItemIndex = self:_findShopItemIndex(items, locateShopItemId)
	local locateExtensionItemIndex = self:_findShopItemIndex(extensionItems, locateShopItemId)

	if locateShopItemId ~= nil then
		locateIndex = locateItemIndex or 0
	end

	local itemCount = #items
	local extensionItemCount = #extensionItems
	local selectedExtensionIndex = locateExtensionItemIndex

	if selectedExtensionIndex == nil and itemCount == 0 and extensionItemCount > 0 then
		selectedExtensionIndex = 0
	end

	self.curBuyList:SetList(items)
	self.ctrl:onBuyShopListRefreshed(shopTagType, extensionItems, selectedExtensionIndex)

	if locateExtensionItemIndex ~= nil then
		self:onShowBuyShopItemDetail(locateShopItemId)
	elseif itemCount > 0 then
		self.curBuyList:SelectItem(locateIndex)
		self:onShowBuyShopItemDetail(items[locateIndex + 1].id)
	elseif extensionItemCount > 0 then
		self:onShowBuyShopItemDetail(extensionItems[1].id)
	else
		self:setItemInfoEmpty(true)
	end
end

function ShopBuyComponent:onBuyItemsCallback(shopItemId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("shopItemId %d", shopItemId)
	end

	self.ctrl:refreshCurrency(ShopCommodityData[shopItemId].tag)
	self.curBuyList:RefreshList()

	if self.curShopItemId == shopItemId then
		self:onShowBuyShopItemDetail(shopItemId)
	end
end

function ShopBuyComponent:refreshNumSelector(maxCount, resetValue)
	self.maxCount = maxCount or 0

	local maxValue = math.max(1, self.maxCount)
	local value = resetValue and 1 or self.buyCount or 1

	self.buyCount = math.max(1, math.min(value, maxValue))
end

function ShopBuyComponent:onMoneyChanged(data)
	if self.curShopItemId == nil then
		return
	end

	local resetValue = (self.maxCount or 0) <= 1

	self:refreshCurrentBuyShopItemDetail(resetValue)

	if self.curBuyList then
		self.curBuyList:RefreshList()
	end
end

function ShopBuyComponent:refreshCurrentBuyShopItemDetail(resetValue)
	if self.curShopItemId == nil or self.model == nil then
		return
	end

	self:refreshNumSelector(self.model:canBuyMaxCount(self.curShopItemId), resetValue)
	self:onRefreshBuyStatePanel()
end

function ShopBuyComponent:onHomelandWarehouseItemChanged(data)
	if self.curShopItemId == nil or data == nil then
		return
	end

	local changedItemId = data.genId

	if changedItemId == nil then
		return
	end

	local cost = self.model:getBuyPriceInfo(self.curShopItemId, 1)

	if cost == nil then
		return
	end

	for i = 1, #cost do
		if cost[i][1] == changedItemId then
			local resetValue = (self.maxCount or 0) <= 1

			self:refreshCurrentBuyShopItemDetail(resetValue)

			if self.curBuyList then
				self.curBuyList:RefreshList()
			end

			break
		end
	end
end

function ShopBuyComponent:_hasSeparatedItemCostComs(propComs)
	return propComs.imgCoinIcon_1 ~= nil and propComs.txtCoinNumber_1 ~= nil
end

function ShopBuyComponent:_getItemCostNumberText(cost)
	local numberText = LuaUIUtils.formatShortItemNum(cost[2])

	if self.model:getCostItemOwnCount(cost[1]) < cost[2] then
		numberText = ClientTextUtils.applyTextColor(numberText, "#F67574")
	end

	return numberText
end

function ShopBuyComponent:_refreshSeparatedItemCost(propComs, shopItemConfig, costList, originalCost)
	if propComs.numCoinUSDFText then
		propComs.numCoinUSDFText:SetActiveFastest(false)
	end

	for index = 1, 2 do
		local cost = costList[index]
		local icon = propComs["imgCoinIcon_" .. index]
		local numberText = propComs["txtCoinNumber_" .. index]
		local hasComponents = icon ~= nil and numberText ~= nil
		local visible = hasComponents and cost ~= nil

		if index > 1 and hasComponents then
			LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(icon, visible)
			LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(numberText, visible)
		end

		if visible then
			icon.url = LuaUIUtils.getIconByItemId(cost[1], LuaUIUtils.ITEM_ICON_TYPE.ICON_SMALL)

			ClientTextUtils.setText(numberText, self:_getItemCostNumberText(cost))
		end
	end

	if shopItemConfig.tagType == 2 and propComs.originalPriceTxt then
		local firstOriginalPrice = originalCost and originalCost[1]
		local originalPriceText = LuaUIUtils.formatShortItemNum(firstOriginalPrice and firstOriginalPrice[2] or 0)

		ClientTextUtils.setText(propComs.originalPriceTxt, originalPriceText)
	end
end

function ShopBuyComponent:_refreshInlineItemCost(propComs, costList)
	propComs.numCoinUSDFText:SetActiveFastest(true)

	local priceText = ""

	for index = 1, math.min(#costList, 2) do
		local cost = costList[index]

		priceText = priceText .. LuaUIUtils.getItemShowText(cost[1]) .. self:_getItemCostNumberText(cost)
	end

	ClientTextUtils.setText(propComs.numCoinUSDFText, priceText)
end

function ShopBuyComponent:refreshBuyItemCost(propComs, shopItemConfig, shopItemId)
	local costList, originalCost = self.model:getBuyPriceInfo(shopItemId, 1)
	local hasCost = costList ~= nil and #costList > 0 and costList[1][2] ~= 0

	if hasCost then
		if self:_hasSeparatedItemCostComs(propComs) then
			self:_refreshSeparatedItemCost(propComs, shopItemConfig, costList, originalCost)
		elseif propComs.numCoinUSDFText then
			self:_refreshInlineItemCost(propComs, costList)
		end

		return true
	end

	if propComs.numCoinUSDFText then
		propComs.numCoinUSDFText:SetActiveFastest(false)
	end

	if propComs.imgCoinIcon_2 and propComs.txtCoinNumber_2 then
		LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(propComs.imgCoinIcon_2, false)
		LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(propComs.txtCoinNumber_2, false)
	end

	return false
end

function ShopBuyComponent:onRefreshItemInfo(button, index, data)
	local shopItemConfig = self.model:getShopItemConfig(data.id)
	local itemId

	if pg.me then
		local t = ItemUtils.getReplacedItemCountTable(pg.me, {
			[shopItemConfig.itemId] = shopItemConfig.itemNum
		})

		itemId = next(t)
	else
		itemId = shopItemConfig.itemId
	end

	local itemConfig = self.model:getItemConfig(itemId)

	if itemConfig == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("道具配置不存在！", itemId)
		end

		return
	end

	local propComs = self.view:getBuyPropItemComs(button)

	self:refreshSeasonLimitedTag(propComs, shopItemConfig)

	propComs.icon.url = LuaUIUtils.getIconByIconId(itemConfig.icon)

	if shopItemConfig.itemNum > 1 then
		local name = pg.getLocalizationText(itemConfig.itemName)
		local num = string.format("×%d", shopItemConfig.itemNum)

		ClientTextUtils.setText(propComs.txtName, string.format("%s %s", name, num))
	else
		ClientTextUtils.setText(propComs.txtName, pg.getLocalizationText(itemConfig.itemName))
	end

	button:TryChangePage("Quality", itemConfig.quality)
	button:TryChangePage("ItemType", itemConfig.qualityType or 0)
	button:TryChangePage("Discount", shopItemConfig.tagType ~= nil and shopItemConfig.tagType or 0)

	local isNew = self.model:isNewSellProp(data.id)

	if isNew then
		ClientTextUtils.setText(propComs.txtNew, pg.getGameString("SHOP_ITEM_NEW"))
	end

	button:TryChangePage("isNew", isNew and 1 or 0)

	if shopItemConfig.tagType ~= nil then
		if shopItemConfig.tagType == 1 then
			ClientTextUtils.setText(propComs.imgGreenTxtName, pg.getLocalizationText(shopItemConfig.tagName))
		elseif shopItemConfig.tagType == 2 then
			ClientTextUtils.setText(propComs.imgYellowTxtName, pg.getLocalizationText(shopItemConfig.tagName))
		elseif shopItemConfig.tagType == 3 then
			ClientTextUtils.setText(propComs.imgRedTxtName, pg.getLocalizationText(shopItemConfig.tagName))
		end
	end

	local hasLimit, _, limitHadBuyCount, limitTotalCount = self.model:getShopItemLimitInfo(shopItemConfig, data.id)

	if hasLimit then
		local leftNum = limitTotalCount - limitHadBuyCount

		ClientTextUtils.setText(propComs.txtInfo, string.format("%s:%d", pg.getGameString("SHOP_LEFT_PROP_NUM"), leftNum))
	else
		ClientTextUtils.setText(propComs.txtInfo, "")
	end

	if not self.model:isPropUnlock(data.id) then
		button:TryChangePage("cardStage", 2)
		ClientTextUtils.setText(propComs.txtLock, self.model:getPropUnlockDesc(shopItemConfig))
	else
		button:TryChangePage("cardStage", 0)
	end

	local isSellOut = self.model:isPropSellOut(data.id)

	LuaUIUtils.setUIViewVisible(propComs.imgSellOut, isSellOut)

	if isSellOut then
		button:TryChangePage("cardStage", 1)
	end

	if self:refreshBuyItemCost(propComs, shopItemConfig, data.id) then
		button:TryChangePage("isFree", 0)
	else
		button:TryChangePage("isFree", 1)
	end

	propComs.countDown:Stop()

	local leftTime = self.model:getLimitPropLeftTime(shopItemConfig)

	LuaUIUtils.setUIViewVisible(propComs.countDown, leftTime > 0)

	if leftTime > 0 then
		function propComs.countDown.luaFinished()
			if LoggerManager.checkLogger(LoggerConst.INFO) then
				logger:info("%d道具限时到期，刷新列表", data.id)
			end

			self:onRefreshBuyShopList(self.curShopTagType)
		end

		propComs.countDown:Play(leftTime)
	end

	if self.ctrl.isRogue then
		propComs.buffIconUImage.url = LuaUIUtils.getIconByIconId(itemConfig.icon)

		local tagIcon = RogueUtils.getRogueBuffTagIcon(itemId)

		if string.notNilOrEmpty(tagIcon) then
			LuaUIUtils.setUIViewVisible(propComs.buffTagIconUWidget, true)

			propComs.buffTagIconUImage.url = tagIcon
		else
			LuaUIUtils.setUIViewVisible(propComs.buffTagIconUWidget, false)
		end

		local buffQuality = RogueUtils.getBuffQuality(itemId)
		local isEquipBuff = buffQuality == Const.RogueBuffQuality.Equipment

		propComs.itemLevelUWidget:SetActive(isEquipBuff)

		if isEquipBuff then
			local buffMaxLayer = RogueUtils.getBuffMaxLayer(itemId)
			local buffCount = pg.me.rogueBuffs[itemId] or 0

			for i = 1, 3 do
				propComs.itemLevelSubItems[i]:TryChangePage("Check", i <= buffCount and 1 or 0)
			end

			if buffMaxLayer <= buffCount then
				button:TryChangePage("Quality", Const.RogueBuffQuality.Boss)
			end
		end
	end

	local curGameId = pg.me:getCatchRogueCurGameId()
	local gameBallItemIds = curGameId and CatchRoguePhaseData[curGameId] and CatchRoguePhaseData[curGameId].gameBallType or nil

	if gameBallItemIds and table.contains(gameBallItemIds, itemId) then
		propComs.exclusiveUContainer:SetActive(true)
		propComs.exclusiveUContainer:LoadDefaultUrlManually()
	else
		propComs.exclusiveUContainer:SetActive(false)
	end

	function button.luaClick(btn, subData)
		button.isSelected = true

		self:onShowBuyShopItemDetail(data.id)
	end

	button.name = tostring(data.id)
end

function ShopBuyComponent:onRenderSubTabItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUBaseText = objectReference:GetRefValue("txtNameUBaseText")

	ClientTextUtils.setText(txtNameUBaseText, ClientTextUtils.getLocalizationText(data.nameHashId))
end

function ShopBuyComponent:onRenderSubTabIconItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local textUBaseText = objectReference:GetRefValue("textUBaseText")

	ClientTextUtils.setText(textUBaseText, ClientTextUtils.getLocalizationText(data.nameHashId))
end

function ShopBuyComponent:onSubTabSelected(uList)
	local sData = uList.selectedItem

	if sData == nil then
		return
	end

	self.paginationId = sData.paginationId

	self:onRefreshBuyShopList(self.curShopTagType, self.locateShopItemId, self.paginationId)
end

function ShopBuyComponent:onShowBuyShopItemDetail(shopItemId)
	self.curShopItemId = shopItemId

	self.ctrl:onBuyShopItemPreviewChanged(shopItemId)

	local shopItemConfig = self.model:getShopItemConfig(self.curShopItemId)
	local itemId

	if pg.me then
		local t = ItemUtils.getReplacedItemCountTable(pg.me, {
			[shopItemConfig.itemId] = 1
		})

		itemId = next(t)
	else
		itemId = shopItemConfig.itemId
	end

	local ownNum = ClientUtils.getItemCountById(itemId)
	local itemConfig = self.model:getItemConfig(itemId)
	local itemType = itemConfig and itemConfig.type
	local showGrabEgg = GRAB_EGG_SHOP_ITEM_TYPES[itemType] == true
	local maxDurability = showGrabEgg and ItemUtils.getRobEggItemMaxDurability(itemId) or nil

	self.purchaseModuleWidget = nil

	self:refreshNumSelector(self.model:canBuyMaxCount(shopItemId), true)

	local selectedShopItemId = shopItemId

	LuaUIUtils.renderShopItemInfo(self:getItemInfoContainer(), {
		fromParamCount = true,
		skipFoldHotkey = true,
		itemId = itemId,
		itemCount = ownNum,
		inheritSellPrice = self.ctrl.isHomelandShop,
		uiStyle = UIConst.ITEM_INFO_STATE.SHOP,
		showGrabEgg = showGrabEgg,
		hideGrabEggPrice = showGrabEgg,
		showGrabEggItemType = showGrabEgg,
		weight = showGrabEgg and ItemUtils.getRobEggItemWeight(itemId) or nil,
		durableText = maxDurability and string.format("%d/%d", maxDurability, maxDurability) or nil
	}, function()
		if self.curShopItemId ~= selectedShopItemId or self.model == nil then
			return nil
		end

		return self:getPurchaseModuleData()
	end)

	if self.model:setCheckedNewProp(shopItemId) and self.curBuyList then
		local allButtons = self.curBuyList:GetAllButtons()

		for i = 0, allButtons.Length - 1 do
			local itemButton = allButtons[i]

			if itemButton.name == tostring(shopItemId) then
				itemButton:TryChangePage("isNew", 0)

				break
			end
		end
	end

	if self.ctrl.trySleepEnd then
		self.ctrl:trySleepEnd()
	end
end

function ShopBuyComponent:onClickPropPriceRuleBtn()
	if self.curShopItemId == nil then
		return
	end

	local shopItemConfig = self.model:getShopItemConfig(self.curShopItemId)

	if shopItemConfig.levelCost == nil or #shopItemConfig.levelCost == 0 then
		return
	end

	local items = {}

	for i = 1, #shopItemConfig.levelCost do
		local levelCost = shopItemConfig.levelCost[i]
		local temp

		if i == 1 then
			temp = string.format("%d-%d", 1, levelCost[1] - 1)

			table.insert(items, {
				shopItemConfig.cost[1],
				shopItemConfig.cost[1][2],
				temp
			})
		else
			local levelCostPre = shopItemConfig.levelCost[i - 1]

			temp = string.format("%d-%d", levelCostPre[1], levelCost[1] - 1)

			table.insert(items, {
				shopItemConfig.cost[1],
				levelCostPre[2],
				temp
			})
		end

		if i == #shopItemConfig.levelCost then
			temp = string.format("%d+", levelCost[1])

			table.insert(items, {
				shopItemConfig.cost[1],
				levelCost[2],
				temp
			})
		end
	end
end

function ShopBuyComponent:onRefreshPropPriceRuleItem(button, index, data)
	local propComs = self.view:getBuyPropPriceRuleComs(button)

	propComs.icon.url = LuaUIUtils.getIconByItemId(data[1][1], LuaUIUtils.ITEM_ICON_TYPE.ICON_SMALL)

	ClientTextUtils.setText(propComs.nameTxt, pg.getLocalizationText(data[3]))
	ClientTextUtils.setText(propComs.numberTxt, pg.getLocalizationText(data[2]))
end

function ShopBuyComponent:GetBuyState(shopItemId)
	local isUnlock = self.model:isPropUnlock(shopItemId)

	if not isUnlock then
		return ShopBuyComponent.SHOP_BUY_STATE.SBS_LOCKED
	end

	local isSellOut = self.model:isPropSellOut(shopItemId)

	if isSellOut then
		return ShopBuyComponent.SHOP_BUY_STATE.SBS_SELL_OUT
	end

	local isEnough, notEnoughItems = self.model:isCurrencyEnough(shopItemId, self.buyCount)

	if not isEnough then
		return ShopBuyComponent.SHOP_BUY_STATE.SBS_NOT_ENOUGH_COIN
	end

	local isPropInsufficient = self.model:isPropInsufficient(shopItemId, self.buyCount)

	if isPropInsufficient then
		return ShopBuyComponent.SHOP_BUY_STATE.SBS_NOT_ENOUGH_COUNT
	end

	if notEnoughItems == nil then
		return ShopBuyComponent.SHOP_BUY_STATE.SBS_FREE
	end

	return ShopBuyComponent.SHOP_BUY_STATE.SBS_NORMAL
end

function ShopBuyComponent:getPurchaseModuleData(shopItemConfig)
	if self.model == nil or self.curShopItemId == nil then
		return nil
	end

	shopItemConfig = shopItemConfig or self.model:getShopItemConfig(self.curShopItemId)

	if shopItemConfig == nil then
		return nil
	end

	local shopItemId = self.curShopItemId

	self.curBuyState = self:GetBuyState(self.curShopItemId, shopItemConfig)

	local isLocked = self.curBuyState == ShopBuyComponent.SHOP_BUY_STATE.SBS_LOCKED
	local isSellOut = self.curBuyState == ShopBuyComponent.SHOP_BUY_STATE.SBS_SELL_OUT
	local coinCost = {}
	local itemCost = {}

	if not isLocked and not isSellOut then
		for _, costData in ipairs(self.model:getBuyPriceInfo(self.curShopItemId, self.buyCount) or {}) do
			local costItemId = costData and costData[1] or 0
			local costNum = costData and costData[2] or 0

			if ItemUtils.isCommonMoney(costItemId) then
				coinCost[#coinCost + 1] = costData
			else
				itemCost[#itemCost + 1] = {
					id = costItemId,
					num = costNum
				}
			end
		end
	end

	local hasLimit, limitTitle, limitHadBuyCount, limitTotalCount, limitDesc = self.model:getShopItemLimitInfo(shopItemConfig, self.curShopItemId)
	local limitLeft = math.max(0, (limitTotalCount or 0) - (limitHadBuyCount or 0))
	local sourceButtonText, onSourceClick
	local clueSeekID = shopItemConfig.source
	local sourceConfig = clueSeekID and clueSeekID > 0 and ItemSourceData[clueSeekID] or nil

	if isLocked and sourceConfig then
		sourceButtonText = pg.getLocalizationText(sourceConfig.buttonTxt)

		function onSourceClick(button)
			if self.curShopItemId ~= shopItemId or self.model == nil then
				return
			end

			local sourceData = {
				clueSeekID = clueSeekID
			}

			table.merge(sourceData, sourceConfig)
			LuaUIUtils.clueSeek(sourceData, nil, button)
		end
	end

	return {
		useShortCoinCost = true,
		validate = function()
			return self.curShopItemId == shopItemId and self.model ~= nil
		end,
		buyState = self.curBuyState,
		buyCount = self.buyCount,
		maxCount = self.maxCount,
		isLocked = isLocked,
		isSellOut = isSellOut,
		coinCost = coinCost,
		itemCost = itemCost,
		hasLimit = hasLimit,
		limitTitle = limitTitle,
		limitLeft = limitLeft,
		limitTotal = limitTotalCount,
		limitDesc = limitDesc,
		sourceButtonText = sourceButtonText,
		onSourceClick = onSourceClick,
		onPurchaseClick = self.ctrl.trySleepEnd and function()
			if self.curShopItemId ~= shopItemId or self.model == nil then
				return
			end

			self.ctrl:trySleepEnd()
		end or nil,
		getCostItemOwnCount = function(itemId)
			if self.curShopItemId ~= shopItemId or self.model == nil then
				return 0
			end

			return self.model:getCostItemOwnCount(itemId)
		end,
		onCountChanged = function(value)
			if self.curShopItemId ~= shopItemId or self.model == nil then
				return
			end

			self.buyCount = value

			self:onRefreshBuyStatePanel()
		end,
		onConfirm = function()
			if self.curShopItemId ~= shopItemId or self.model == nil then
				return
			end

			self:onConfirmToBuy()
		end,
		onRendered = function(content, buyCount)
			if self.curShopItemId ~= shopItemId or self.model == nil then
				return
			end

			self.purchaseModuleWidget = content
			self.buyCount = buyCount
		end
	}
end

function ShopBuyComponent:onRefreshBuyStatePanel()
	if self.curShopItemId == nil or IsNil(self.purchaseModuleWidget) then
		return
	end

	ClientCashShopUtils.renderItemInfoPurchase(self.purchaseModuleWidget, self:getPurchaseModuleData())
end

function ShopBuyComponent:tryOpenQuickPay(notEnoughItems)
	if not notEnoughItems or #notEnoughItems == 0 then
		return false
	end

	local costList = self.model:getBuyPriceInfo(self.curShopItemId, self.buyCount)

	if not costList or #costList == 0 then
		return false
	end

	local shopItemConfig = self.model:getShopItemConfig(self.curShopItemId)

	if not shopItemConfig then
		return false
	end

	for i = 1, #notEnoughItems do
		local costItemId = notEnoughItems[i]

		if costItemId == ItemConst.ITEM_SPECIAL_MONEY_COIN_BOUND or costItemId == ItemConst.ITEM_SPECIAL_MONEY_CASH_BOUND then
			for j = 1, #costList do
				local costInfo = costList[j]

				if costInfo[1] == costItemId then
					RechargeUtils.openQuickPay({
						itemId = shopItemConfig.itemId,
						itemNum = (shopItemConfig.itemNum or 1) * self.buyCount,
						needCount = costInfo[2],
						currencyID = costItemId,
						buyCallBack = function()
							self:onConfirmToBuy()
						end
					})

					return true
				end
			end
		end
	end

	return false
end

function ShopBuyComponent:getCommodityNeedBagSlotCount(commodityId, num)
	local shopItemConfig = self.model:getShopItemConfig(commodityId) or ShopCommodityData[commodityId]

	if not shopItemConfig then
		return num
	end

	local itemNum = shopItemConfig.itemNum or 1
	local totalNum = itemNum * num
	local itemConfig = self.model:getItemConfig(shopItemConfig.itemId)
	local stackCount = itemConfig and itemConfig.stackcount or 1

	if stackCount <= 0 then
		stackCount = 1
	end

	return math.ceil(totalNum / stackCount)
end

function ShopBuyComponent:checkCanBuyCommodity(shopClassifyId, commodityId, num)
	if shopClassifyId ~= Const.SHOP_ID.ROBEGG_SHOP or not pg.me then
		return true
	end

	local needCount = self:getCommodityNeedBagSlotCount(commodityId, num)

	if pg.me.getGrabEggBagEmptyCount then
		local emptyCount = pg.me:getGrabEggBagEmptyCount() or 0

		if emptyCount < needCount then
			ClientUtils.showBubbleMessage(NoticeDef.ITEM_BAG_FULL)

			return false
		end
	elseif pg.me.isGrabEggBagFull and pg.me:isGrabEggBagFull() then
		ClientUtils.showBubbleMessage(NoticeDef.ITEM_BAG_FULL)

		return false
	end

	return true
end

function ShopBuyComponent:onConfirmToBuy()
	if self.curBuyState == ShopBuyComponent.SHOP_BUY_STATE.SBS_NOT_ENOUGH_COIN then
		local ret, items = self.model:isCurrencyEnough(self.curShopItemId, self.buyCount)

		if not ret then
			if self:tryOpenQuickPay(items) then
				return
			end

			for i = 1, #items do
				local itemConfig = self.model:getItemConfig(items[i])

				pg.global.showBubbleMessage(NoticeDef.SHOP_ITEM_NOT_ENOUGH, pg.getLocalizationText(itemConfig.itemName))
			end
		end
	elseif self.curBuyState == ShopBuyComponent.SHOP_BUY_STATE.SBS_NOT_ENOUGH_COUNT then
		-- block empty
	elseif self.curBuyState == ShopBuyComponent.SHOP_BUY_STATE.SBS_NOT_ENOUGH_BAG then
		-- block empty
	end

	if self.curBuyState ~= ShopBuyComponent.SHOP_BUY_STATE.SBS_NORMAL and self.curBuyState ~= ShopBuyComponent.SHOP_BUY_STATE.SBS_FREE then
		return
	end

	if not self:checkCanBuyCommodity(self.shopClassifyId, self.curShopItemId, self.buyCount) then
		return
	end

	local exchangeNum = self.model:getBoundCashExchangeNum(self.curShopItemId, self.buyCount)

	if exchangeNum and exchangeNum > 0 then
		self:openBoundCashExchangeConfirm(exchangeNum, function()
			self.model:buyCommodity(self.shopClassifyId, self.curShopItemId, self.buyCount)
		end)

		return
	end

	self.model:buyCommodity(self.shopClassifyId, self.curShopItemId, self.buyCount)
end

function ShopBuyComponent:openBoundCashExchangeConfirm(exchangeNum, confirmCb)
	local cashDesc = pg.getFormatText("{0} {1}", LuaUIUtils.getItemShowText(ItemConst.ITEM_SPECIAL_MONEY_CASH_BOUND), exchangeNum)
	local coinDesc = pg.getFormatText("{0} {1}", LuaUIUtils.getItemShowText(ItemConst.ITEM_SPECIAL_MONEY_COIN_BOUND), exchangeNum)
	local changeDesc = pg.getFormatText(self.model:getGameString("SHOPMALL_EXCHANGE_TEXT"), cashDesc, coinDesc)
	local shopItemConfig = self.model:getShopItemConfig(self.curShopItemId)

	pg.global.ui.commonUseConfirm:open({
		type = 1,
		muteCheckEnough = true,
		title = self.model:getGameString("SHOP_BUY_READY"),
		tipTop = changeDesc,
		data = {
			{
				shopItemConfig.itemId,
				(shopItemConfig.itemNum or 1) * self.buyCount,
				ownNum = 1,
				hideOwnNum = true
			}
		},
		costId = ItemConst.ITEM_SPECIAL_MONEY_COIN_BOUND,
		exchangeCostId = ItemConst.ITEM_SPECIAL_MONEY_CASH_BOUND,
		confirmCb = confirmCb
	})
end

function ShopBuyComponent:onInputDeviceChanged(deviceType)
	return
end

function ShopBuyComponent:onRefreshList()
	if self.curBuyList then
		self.curBuyList:RefreshList()
	end

	self:onRefreshBuyStatePanel()
end

return ShopBuyComponent
