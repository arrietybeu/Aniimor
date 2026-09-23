-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Shop\\Component\\ShopSellComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("ShopSellComponent")
local LuaUIUtils = require("Utils.LuaUIUtils")
local lume = require("Core.Common.lume")
local UIComponent = require("Guis.Helper.UIComponent")
local Class = require("Core.Framework.Class")
local ShopSellComponent = Class.LightClass("ShopSellComponent", UIComponent)
local ClientTextUtils = require("Utils.ClientTextUtils")

function ShopSellComponent:ctor(ctrl)
	self.ctrl = ctrl
	self.model = ctrl.model
	self.view = ctrl.view

	self:addListener()
	self:init()
end

function ShopSellComponent:init()
	self.isShowFilterList = false
	self.lockSelector = false
end

function ShopSellComponent:onShow()
	if self.curInvenType == nil then
		self.curInvenType = 3
	end

	self:onRefreshSellShopPanel(self.curInvenType)
end

function ShopSellComponent:addListener()
	function self.view.pbSellBtnPokeBall.luaClick()
		self.curInvenType = 3

		self:onRefreshSellShopPanel(self.curInvenType)
	end

	function self.view.pbSellBtnCharacterProps.luaClick()
		self.curInvenType = 1

		self:onRefreshSellShopPanel(self.curInvenType)
	end

	function self.view.pbSellBtnParmonProps.luaClick()
		self.curInvenType = 2

		self:onRefreshSellShopPanel(self.curInvenType)
	end

	function self.view.pbSellListProp.luaRenderItem(button, index, data)
		self:onRefreshItemInfo(button, index, data)
	end

	function self.view.pbSellListProp.luaClick(button, data)
		self:onClickShopItem(button, data)

		if LoggerManager.checkLogger(LoggerConst.INFO) then
			logger:info("shopItemId %d IsInSellItemList %s", data.id)
		end
	end

	function self.view.pbSellFilterNumSelector.luaValueChanged(value)
		if self.lockSelector then
			return
		end

		self:onSelectedItemNumChanged(value)
	end

	function self.view.pbSellFilterSelectedBtn.luaClick(button, data)
		if not self.isShowFilterList then
			self:onRefreshSelectedPanel()
		end

		self.isShowFilterList = not self.isShowFilterList
	end

	function self.view.pbSellFilterPropList.luaRenderItem(button, index, data)
		self:onRefreshFilterListItemInfo(button, index, data)
	end

	function self.view.pbSellFilterQuickSelectBtn.luaClick(button, data)
		self:setQuickSelectOptions()
	end

	function self.view.pbSellFilterQualityList.luaRenderItem(button, index, data)
		self:onRefreshFilterQuickSelectListItemInfo(button, index, data)
	end

	function self.view.pbSellFilterSellBtn.luaClick(button, data)
		self:onRefreshSellTipPanel()
	end

	function self.view.pbSellTipPropList.luaRenderItem(button, index, data)
		self:onRefreshSellTipListItemInfo(button, index, data)
	end

	function self.view.pbSellTipCancelBtn.luaClick(button, data)
		LuaUIUtils.setUIViewVisible(self.view.pbSellTipPanel, false)
	end

	function self.view.pbSellTipConfirmBtn.luaClick(button, data)
		self:onConfirmToSellProp()
	end
end

function ShopSellComponent:onSellItemsCallback()
	self:onRefreshSellShopPanel(self.curInvenType)
end

function ShopSellComponent:onRefreshSellShopPanel(invenId)
	self.sellItemList = {}
	self.curItemData = nil
	self.allItems = self.model:getSellShopProps(invenId)
	self.totalItemsCount = #self.allItems

	self.view.pbSellUComponent:TryChangePage("isEmpty", self.totalItemsCount == 0 and 1 or 0)
	self.view.pbSellListProp:SetList(self.allItems)

	if self.totalItemsCount > 0 then
		self.view.pbSellListProp:SelectItem(0)
		self:onClickShopItem(nil, self.allItems[1], false)
	end

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("%d 显示列表 itemcount %d", invenId)
	end
end

function ShopSellComponent:onRefreshItemInfo(button, index, data)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("刷新道具信息：" .. tostring(index) .. " " .. tostring(data.genID))
	end

	local itemConfig = self.model:getItemConfig(data.id)
	local propComs = self.view:getSellPropItemComs(button)

	propComs.icon.url = LuaUIUtils.getIconByIconId(itemConfig.icon)
	propComs.priceImg.url = LuaUIUtils.getIconByItemId(itemConfig.sellPrice[1])

	local selectedCount = self:getSellItem(data)

	if selectedCount > 0 then
		ClientTextUtils.setText(propComs.numberTxt, string.format("%d/%d", selectedCount, data.count))
		ClientTextUtils.setText(propComs.priceTxt, tostring(self.model:getSellPrice(data.id, selectedCount)))
	else
		ClientTextUtils.setText(propComs.numberTxt, tostring(data.count))
		ClientTextUtils.setText(propComs.priceTxt, tostring(self.model:getSellPrice(data.id, data.count)))
	end

	LuaUIUtils.setUIViewVisible(propComs.checked, self:IsInSellItemList(data))

	local isLocked = self.model:isPropLocked(data)

	button:TryChangePage("Lock", isLocked and 1 or 0)
	button:TryChangePage("Quality", itemConfig.quality)

	button.name = tostring(data.genID)
end

function ShopSellComponent:onClickShopItem(button, itemData)
	local curItemData = self.curItemData

	self.curItemData = itemData

	self:onShowSellShopItemDetail(itemData, curItemData)
	self:onRefreshSelectorPanel(itemData, curItemData)

	if button ~= nil then
		local isIn = self:IsInSellItemList(itemData)
		local propComs = self.view:getSellPropItemComs(button)

		LuaUIUtils.setUIViewVisible(propComs.checked, isIn)

		local selectCount = self:getSellItem(itemData)

		if selectCount > 0 then
			ClientTextUtils.setText(propComs.priceTxt, tostring(self.model:getSellPrice(itemData.id, selectCount)))
		else
			ClientTextUtils.setText(propComs.numberTxt, tostring(itemData.count))
			ClientTextUtils.setText(propComs.priceTxt, tostring(self.model:getSellPrice(itemData.id, itemData.count)))
		end

		self.view.pbSellFilterNumSelector:TryChangePage("active", isIn and 0 or 1)
	end
end

function ShopSellComponent:onShowSellShopItemDetail(itemData, curItemData)
	if curItemData ~= nil and curItemData.genID == itemData.genID then
		return
	end

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("刷新道具详情 %d", itemData.genID)
	end

	local itemConfig = self.model:getItemConfig(itemData.id)

	ClientTextUtils.setText(self.view.pbSellInfoTxtName, pg.getLocalizationText(itemConfig.itemName))
	ClientTextUtils.setText(self.view.pbSellInfoTxtType, pg.getLocalizationText(self.model:getItemDisplayType(itemConfig)))

	self.view.pbSellInfoIconProp.url = LuaUIUtils.getIconByIconId(itemConfig.icon)

	ClientTextUtils.setText(self.view.pbSellInfoNumber, string.format("×%d", itemData.count))
	ClientTextUtils.setText(self.view.pbSellInfoTxtContent, pg.getLocalizationText(itemConfig.funcRep))
	self.view.pbSellInfoComponent:TryChangePage("Quality", itemConfig.quality)

	local isLocked = self.model:isPropLocked(itemData)

	if not isLocked then
		self.lockSelector = true

		local selectCount = self:getSellItem(itemData)

		self.view.pbSellFilterNumSelector.value = selectCount
		self.view.pbSellFilterNumSelector.maxValue = itemData.count
		self.lockSelector = false

		ClientTextUtils.setText(self.view.pbSellInfoPriceTxt, tostring(self.model:getSellPrice(itemData.id, itemData.count)))
		LuaUIUtils.setUIViewVisible(self.view.pbSellInfoPriceImg, true)

		self.view.pbSellInfoPriceImg.url = LuaUIUtils.getIconByItemId(itemConfig.sellPrice[1])

		self.view.pbSellFilterPanel:TryChangePage("button", selectCount > 0 and 0 or 4)
		self.view.pbSellFilterNumSelector:TryChangePage("active", selectCount > 0 and 0 or 1)
	else
		ClientTextUtils.setText(self.view.pbSellInfoPriceTxt, nil)
		LuaUIUtils.setUIViewVisible(self.view.pbSellInfoPriceImg, false)
		self.view.pbSellFilterPanel:TryChangePage("button", 4)
		self.view.pbSellFilterNumSelector:TryChangePage("active", 1)
	end

	self.view.pbSellInfoComponent:TryChangePage("Lock", isLocked and 1 or 0)
end

function ShopSellComponent:forceCancelSelectItem(itemData)
	self:onRefreshSelectorPanel(itemData, self.curItemData, true)

	local allBtns = self.view.pbSellListProp:GetAllButtons()

	for i = 0, allBtns.Length - 1 do
		local btn = allBtns[i]

		if btn.name == tostring(itemData.genID) then
			local propComs = self.view:getSellPropItemComs(btn)

			ClientTextUtils.setText(propComs.numberTxt, tostring(itemData.count))
			ClientTextUtils.setText(propComs.priceTxt, tostring(self.model:getSellPrice(itemData.id, itemData.count)))
			LuaUIUtils.setUIViewVisible(propComs.checked, false)

			break
		end
	end
end

function ShopSellComponent:onRefreshSelectedPanel()
	local items = {}

	for k, v in pairs(self.sellItemList) do
		table.insert(items, {
			itemData = k,
			count = v
		})
	end

	self.view.pbSellFilterPropList:SetList(items)
end

function ShopSellComponent:onRefreshFilterListItemInfo(button, index, data)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("刷新道具信息：" .. tostring(index) .. " " .. tostring(data.itemData.id))
	end

	local itemConfig = self.model:getItemConfig(data.itemData.id)
	local propComs = self.view:getSellPropFilterItemComs(button)

	propComs.icon.url = LuaUIUtils.getIconByIconId(itemConfig.icon)

	ClientTextUtils.setText(propComs.priceTxt, tostring(self.model:getSellPrice(data.itemData.id, data.count)))

	propComs.priceImg.url = LuaUIUtils.getIconByItemId(itemConfig.sellPrice[1])

	local selectCount = self:getSellItem(data.itemData)

	ClientTextUtils.setText(propComs.numberTxt, string.format("%d/%d", selectCount, data.itemData.count))
	LuaUIUtils.setUIViewVisible(propComs.delBtn, true)

	function propComs.delBtn.luaClick()
		self:forceCancelSelectItem(data.itemData)
		self:onRefreshSelectedPanel()
	end

	button:TryChangePage("Quality", itemConfig.quality - 1)

	button.name = tostring(data.itemData.genID)
end

function ShopSellComponent:onSelectedItemNumChanged(num)
	if self.curItemData == nil then
		return
	end

	self:setSellItem(self.curItemData, num)
	self:onRefreshListItemCount(self.curItemData, num)
end

function ShopSellComponent:onRefreshListItemCount(itemData, num)
	local allBtns = self.view.pbSellListProp:GetAllButtons()

	for i = 0, allBtns.Length - 1 do
		if allBtns[i].name == tostring(itemData.genID) then
			local propComs = self.view:getSellPropItemComs(allBtns[i])

			if num > 0 then
				ClientTextUtils.setText(propComs.numberTxt, string.format("%d/%d", num, itemData.count))
				ClientTextUtils.setText(propComs.priceTxt, tostring(self.model:getSellPrice(itemData.id, num)))

				break
			end

			ClientTextUtils.setText(propComs.numberTxt, tostring(itemData.count))
			ClientTextUtils.setText(propComs.priceTxt, tostring(self.model:getSellPrice(itemData.id, itemData.count)))

			break
		end
	end

	self:refreshSelectorInfo()
end

function ShopSellComponent:onRefreshSelectorPanel(itemData, curItemData, forceUpdate)
	local isLocked = self.model:isPropLocked(itemData)

	if isLocked then
		ClientTextUtils.setText(self.view.pbSellFilterNameTxt, nil)
		self:refreshSelectorInfo()

		return
	end

	local itemConfig = self.model:getItemConfig(itemData.id)

	ClientTextUtils.setText(self.view.pbSellFilterNameTxt, pg.getLocalizationText(itemConfig.itemName))

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("刷新数量选择器面板 itemId %d genId %d", itemData.id, itemData.genID)
	end

	if self:IsInSellItemList(itemData) then
		if forceUpdate == true or curItemData ~= nil and curItemData.genID == itemData.genID then
			self.lockSelector = true
			self.view.pbSellFilterNumSelector.value = 0
			self.lockSelector = false

			self:removeSellItem(itemData)
			self:refreshSelectorInfo()
		end
	elseif curItemData ~= nil then
		self.lockSelector = true
		self.view.pbSellFilterNumSelector.value = 1
		self.lockSelector = false

		self:setSellItem(itemData, 1)
		self:refreshSelectorInfo()
	else
		self.lockSelector = true
		self.view.pbSellFilterNumSelector.value = 0
		self.lockSelector = false

		self:refreshSelectorInfo()
	end
end

function ShopSellComponent:refreshSelectorInfo()
	local totalPrice, costItem, selectCount = self:getSellItemsPrice()

	ClientTextUtils.setText(self.view.pbSellFilterNumTxt, string.format("%d/%d", selectCount, self.totalItemsCount))
	ClientTextUtils.setText(self.view.pbSellFilterPriceTxt, string.format("×%d", totalPrice))

	self.view.pbSellFilterPriceImg.url = LuaUIUtils.getIconByItemId(costItem)

	self.view.pbSellFilterSellBtn:TryChangePage("button", selectCount > 0 and 0 or 4)
end

function ShopSellComponent:getSellItemsPrice()
	local totalPrice = 0
	local selectCount = 0
	local costItem

	for k, v in pairs(self.sellItemList) do
		selectCount = selectCount + 1

		local price, item = self.model:getSellPrice(k.id, v)

		totalPrice = totalPrice + price
		costItem = item
	end

	return totalPrice, costItem, selectCount
end

function ShopSellComponent:setQuickSelectOptions()
	local qualityList = self.model:getItemQualityInfoConfig()

	self.view.pbSellFilterQualityList:SetList(qualityList)
end

function ShopSellComponent:onRefreshFilterQuickSelectListItemInfo(button, index, data)
	local itemComs = self.view:getSellPropFilterQuickListItemComs(button)

	ClientTextUtils.setText(itemComs.nameTxt, pg.getLocalizationText(data.name))
	ClientTextUtils.setText(itemComs.numberTxt, self:onGetTargetQualiltyItemCount(data.id))

	function button.luaClick()
		local ret, selectedIndex = button:TryGetCurrentPage("button")

		self:quickSelectTargetQualityItems(selectedIndex == 7, data.id)
	end
end

function ShopSellComponent:onGetTargetQualiltyItemCount(quality)
	local count = 0

	for i = 1, self.totalItemsCount do
		local itemData = self.allItems[i]
		local itemConfig = self.model:getItemConfig(itemData.id)

		if itemConfig.quality == quality then
			count = count + 1
		end
	end

	return count
end

function ShopSellComponent:quickSelectTargetQualityItems(isSelected, quality)
	local hasSelected = false

	for i = 1, self.totalItemsCount do
		local itemData = self.allItems[i]
		local itemConfig = self.model:getItemConfig(itemData.id)

		if itemConfig.quality == quality and self:quickSelectItem(isSelected, itemData) then
			if itemData.genID == self.curItemData.genID then
				self.lockSelector = true
				self.view.pbSellFilterNumSelector.value = self:getSellItem(itemData)
				self.lockSelector = false
			end

			hasSelected = true
		end
	end

	if hasSelected then
		self:refreshSelectorInfo()
	end
end

function ShopSellComponent:quickSelectItem(isSelected, itemData)
	if isSelected and self:getSellItem(itemData) == itemData.count or not isSelected and not self:IsInSellItemList(itemData) then
		return false
	end

	self:setSellItem(itemData, isSelected and itemData.count or 0)

	local allBtns = self.view.pbSellListProp:GetAllButtons()

	for i = 0, allBtns.Length - 1 do
		local btn = allBtns[i]

		if btn.name == tostring(itemData.genID) then
			local propComs = self.view:getSellPropItemComs(btn)
			local selectCount = self:getSellItem(itemData)

			if selectCount > 0 then
				ClientTextUtils.setText(propComs.numberTxt, string.format("%d/%d", selectCount, itemData.count))
			else
				ClientTextUtils.setText(propComs.numberTxt, tostring(itemData.count))
			end

			LuaUIUtils.setUIViewVisible(propComs.checked, isSelected)

			return true
		end
	end

	return false
end

function ShopSellComponent:onRefreshSellTipPanel()
	local hasRare = false
	local items = {}

	for k, v in pairs(self.sellItemList) do
		table.insert(items, {
			itemData = k,
			count = v
		})

		if not hasRare and self.model:isRareItem(k.id) then
			hasRare = true
		end
	end

	self.view.pbSellTipPropList:SetList(items)
	LuaUIUtils.setUIViewVisible(self.view.pbSellTipWarn, hasRare)

	self.totalPrice, self.costItem, self.selectCount = self:getSellItemsPrice()

	ClientTextUtils.setText(self.view.pbSellTipPriceTxt, tostring(self.totalPrice))

	self.view.pbSellTipPriceImg.url = LuaUIUtils.getIconByItemId(self.costItem)
end

function ShopSellComponent:onRefreshSellTipListItemInfo(button, index, data)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("刷新道具信息：" .. tostring(index) .. " " .. tostring(data.itemData.id))
	end

	local itemConfig = self.model:getItemConfig(data.itemData.id)
	local propComs = self.view:getSellPropTipItemComs(button)

	propComs.icon.url = LuaUIUtils.getIconByIconId(itemConfig.icon)

	ClientTextUtils.setText(propComs.numberTxt, data.count)

	button.name = tostring(data.itemData.genID)
end

function ShopSellComponent:onConfirmToSellProp()
	LuaUIUtils.setUIViewVisible(self.view.pbSellTipPanel, false)

	local items = {}

	for k, v in pairs(self.sellItemList) do
		items[k.genID] = v
	end

	self.model:sellItemByGenId(self.curInvenType, items, self.costItem, self.totalPrice)
end

function ShopSellComponent:IsInSellItemList(itemData)
	return self.sellItemList[itemData] ~= nil
end

function ShopSellComponent:removeSellItem(itemData)
	self.sellItemList[itemData] = nil
end

function ShopSellComponent:getSellItem(itemData)
	if self.sellItemList[itemData] ~= nil then
		return self.sellItemList[itemData]
	end

	return 0
end

function ShopSellComponent:setSellItem(itemData, count)
	if count == 0 then
		self.sellItemList[itemData] = nil
	else
		self.sellItemList[itemData] = count
	end
end

return ShopSellComponent
