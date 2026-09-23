-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CashShop\\Component\\ExchangeShopsComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local CashShopContainerComponent = require("Guis.Panels.CashShop.Component.CashShopContainerComponent")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientUtils = require("Utils.ClientUtils")
local ItemPropUIUtils = require("Utils.ItemPropUIUtils")
local UIConst = require("Const.UIConst")
local CashShopConst = require("Const.CashShopConst")
local RandomShopsComponent = require("Guis.Panels.CashShop.Component.RandomShopsComponent")
local ExchangeShopsData = require("Data.shopmall_exchange_shops_data")
local ShopTagData = require("Data.shop_tag_data")
local ShopClassifyData = require("Data.shop_classify_data")
local ExchangeShopsComponent = Class.LightClass("ExchangeShopsComponent", CashShopContainerComponent)

function ExchangeShopsComponent:findObjects()
	if not self:checkContentLoaded() then
		return
	end

	CashShopContainerComponent.findObjects(self)

	local objectReference = self.transform:GetChild(0):GetComponent("ObjectReference")

	self.rootUComponent = objectReference:GetRefValue("rootUComponent")
	self.shopUComponent = objectReference:GetRefValue("shopUComponent")
	self.randomUComponent = objectReference:GetRefValue("randomUComponent")

	local shopObjectReference = self.shopUComponent:GetComponent("ObjectReference")

	self.listUList = shopObjectReference:GetRefValue("listUList")

	if self.randomUComponent then
		local randomObjectReference = objectReference

		if not objectReference:GetRefValue("listPropUList") then
			local childObjectReference = self.randomUComponent:GetComponent("ObjectReference")

			if childObjectReference then
				randomObjectReference = childObjectReference
			end
		end

		self.randomShopsComponent = RandomShopsComponent.new(self.ctrl, self.refUContainer, self.categoryType)

		self.randomShopsComponent:initializeEmbedded(randomObjectReference, self.randomUComponent, self.imgBG, self)
	end
end

function ExchangeShopsComponent:addListener()
	CashShopContainerComponent.addListener(self)

	function self.listUList.luaRenderItem(button, index, data)
		self:renderShopItem(button, index, data)
	end
end

function ExchangeShopsComponent:refreshPage()
	local randomShopAvailable = self.ctrl.model:isRandomShopAvailable()

	if self._randomShopAvailable ~= nil and self._randomShopAvailable ~= randomShopAvailable then
		self._randomShopAvailable = randomShopAvailable

		self:_setupGroupTabs()

		return
	end

	self._randomShopAvailable = randomShopAvailable

	if self.listGroupTab then
		local groupList = self.ctrl.model:getGroupListByTabId(CashShopConst.CategoryType.EXCHANGE)

		self.listGroupTab.gameObject:SetActiveEx(#groupList > 1)
	end

	local showRandomShop = self._currentGroupId == CashShopConst.ExchangeShopTabType.Random and self.randomShopsComponent ~= nil

	if self.rootUComponent then
		self.rootUComponent:TryChangePage("Type", showRandomShop and 1 or 0)
	end

	if showRandomShop then
		if self._showingRandomShop then
			self.randomShopsComponent:refreshEmbeddedPage(self._currentGroupData)
		else
			self._showingRandomShop = true

			self.randomShopsComponent:onEnterEmbeddedPage(self._currentGroupData)
		end

		return
	end

	self:exitRandomShopPage()

	local list = {}

	for id, row in pairs(ExchangeShopsData) do
		local entry = {}

		for k, v in pairs(row) do
			entry[k] = v
		end

		entry.id = id
		list[#list + 1] = entry
	end

	table.sort(list, function(a, b)
		return (a.sort or 0) < (b.sort or 0)
	end)
	self.listUList:SetList(list)
end

function ExchangeShopsComponent:_onGroupSelected(data)
	if self._currentGroupId == CashShopConst.ExchangeShopTabType.Random and data.id ~= CashShopConst.ExchangeShopTabType.Random then
		self:exitRandomShopPage()
	end

	CashShopContainerComponent._onGroupSelected(self, data)
end

function ExchangeShopsComponent:isRandomShopPageActive()
	return self._showingRandomShop == true and self._currentGroupId == CashShopConst.ExchangeShopTabType.Random and self.ctrl and self.ctrl.curComponent == self
end

function ExchangeShopsComponent:exitRandomShopPage()
	local randomShopComponent = self.randomShopsComponent
	local needCleanup = self._showingRandomShop == true or randomShopComponent and (randomShopComponent._randomShopPetModelingId or randomShopComponent._dailyRefreshTimerId)

	self._showingRandomShop = false

	if needCleanup and randomShopComponent then
		randomShopComponent:onExitEmbeddedPage()
	end

	self._showingModel = false
	self._showingPet = false

	if self.ctrl and self.ctrl.refreshConsoleBarState then
		self.ctrl:refreshConsoleBarState()
	end
end

function ExchangeShopsComponent:onBeforeExitPage()
	self:exitRandomShopPage()
	CashShopContainerComponent.onBeforeExitPage(self)
end

function ExchangeShopsComponent:onDestroy()
	self:exitRandomShopPage()

	if self.randomShopsComponent then
		self.randomShopsComponent:onDestroy()

		self.randomShopsComponent = nil
	end

	CashShopContainerComponent.onDestroy(self)
end

function ExchangeShopsComponent:renderShopItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local imgBG = objectReference:GetRefValue("imgBG")
	local txtName = objectReference:GetRefValue("txtName")
	local txtDesc = objectReference:GetRefValue("txtDesc")
	local btnRedirect = objectReference:GetRefValue("btnRedirect")
	local btnGeolocation = objectReference:GetRefValue("btnGeolocation")
	local listCurrencyUList = objectReference:GetRefValue("listCurrencyUList")

	imgBG.url = data.pic

	ClientTextUtils.setText(txtName, pg.getLocalizationText(data.name))
	ClientTextUtils.setText(txtDesc, pg.getLocalizationText(data.des))
	button:TryChangePage("Type", not data.type and CashShopConst.ShopShowType.OPEN or CashShopConst.ShopShowType.TRACK)

	local shopClassifyRow = ShopClassifyData[data.id]

	if shopClassifyRow then
		local currencyList = {}
		local seen = {}

		for _, tagId in ipairs(shopClassifyRow.classify or EMPTY_TABLE) do
			local tagData = ShopTagData[tagId]

			if tagData then
				for _, currencyId in ipairs(tagData.currency or EMPTY_TABLE) do
					if not seen[currencyId] then
						seen[currencyId] = true
						currencyList[#currencyList + 1] = {
							currencyId,
							ClientUtils.getItemCountById(currencyId) or 0
						}
					end
				end
			end
		end

		ItemPropUIUtils.renderConsumeItemList(listCurrencyUList, currencyList, false, false, true)

		function btnRedirect.luaClick()
			pg.global.ui:open(UIConst.UI_ID_SHOP_MAIN, {
				shopTags = {
					data.id
				}
			})
		end

		function btnGeolocation.luaClick()
			if not data.type then
				return
			end

			LuaUIUtils.locateMark(data.type[1], data.type[2])
		end
	end
end

function ExchangeShopsComponent:focusOnUnopenCard()
	if not self:isRandomShopPageActive() or not self.randomShopsComponent then
		return false
	end

	return self.randomShopsComponent:focusOnUnopenCard()
end

function ExchangeShopsComponent:focusOnCard()
	if not self:isRandomShopPageActive() or not self.randomShopsComponent then
		return false
	end

	return self.randomShopsComponent:focusOnCard()
end

return ExchangeShopsComponent
