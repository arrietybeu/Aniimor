-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandMarket\\Component\\HomelandInventoryComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomelandInventoryComponent")
local Class = require("Core.Framework.Class")
local Utils = require("Common.Utils.Utils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local UIConst = require("Const.UIConst")
local UIComponent = require("Guis.Helper.UIComponent")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local HomelandInventoryComponent = Class.LightClass("HomelandInventoryComponent", UIComponent)

function HomelandInventoryComponent:findObjects()
	return
end

function HomelandInventoryComponent:onCtor(info)
	self.currencyItemFilter = info.currencyItemFilter
end

function HomelandInventoryComponent:initView()
	self:addListener()
end

function HomelandInventoryComponent:addListener()
	function self.view.inventoryUList.luaRenderItem(button, index, data)
		LuaUIUtils.setPropCard(button, index, data, UIConst.INVENTORY_CARD.CARD_IDX)

		local objectReference = button:GetComponent("ObjectReference")
		local txtNameUText = objectReference:GetRefValue("txtNameUText")
		local rateUComponent = objectReference:GetRefValue("rateUComponent")
		local rateUBaseText = objectReference:GetRefValue("rateUBaseText")
		local txtNameAddUBaseText = objectReference:GetRefValue("txtNameAddUBaseText")
		local homeMarketTagUContainer = objectReference:GetRefValue("homeMarketTagUContainer")

		if txtNameAddUBaseText then
			txtNameAddUBaseText:SetActive(false)
		end

		ClientTextUtils.setText(txtNameUText, data.count)

		if data.rate and data.rate ~= 1 then
			rateUComponent.gameObject:SetActiveEx(true)
			ClientTextUtils.setText(rateUBaseText, data.rate)

			if data.rate > 1 then
				rateUComponent:TryChangePage("BuffType", 0)
			else
				rateUComponent:TryChangePage("BuffType", 1)
			end
		else
			rateUComponent.gameObject:SetActiveEx(false)
		end

		button.draggable = false

		local isOrderItem = HomeLandUtils.isHomeOrderItem(data.itemId)

		if isOrderItem and not homeMarketTagUContainer:CheckURLLoaded() then
			homeMarketTagUContainer:LoadDefaultUrlManually()
		end

		homeMarketTagUContainer:SetActive(isOrderItem)
	end

	function self.view.inventoryUList.luaClick(button, data)
		self.ctrl:showItemDetail(data, data.count, data.count)
	end
end

function HomelandInventoryComponent:onDestroy()
	UIComponent.onDestroy(self)
end

function HomelandInventoryComponent:onEnterPage()
	self.view.inventoryUList:DeselectAll()

	self.inventoryList = self.model:getInventoryList(self.ctrl.shopId, self.currencyItemFilter)

	if Utils.isEmptyTable(self.inventoryList) then
		self.view.rootUComponent:TryChangePage("Empty", 1)
		ClientTextUtils.setText(self.view.emptyTitleUBaseText, pg.getGameString("HOMELAND_MARKET_EMPTY_INV"))
		ClientTextUtils.setText(self.view.emptyInfoUBaseText, pg.getGameString("HOMELAND_MARKET_EMPTY_INV_INFO"))
		self.ctrl:setItemInfoEmpty()

		return
	end

	self.view.rootUComponent:TryChangePage("Empty", 0)
	self.ctrl:setItemInfoEmpty()
	self.view.inventoryUList:SetList(self.inventoryList)
end

function HomelandInventoryComponent:refreshSelectElement()
	local index = self.view.inventoryUList.selectedIndex

	self:refreshElementByIndex(index)
end

function HomelandInventoryComponent:refreshElementByIndex(index)
	local selectedItemId = self.view.inventoryUList.selectedItem and self.view.inventoryUList.selectedItem.itemId

	if index then
		local data = self.view.inventoryUList:GetData(index)

		if data then
			data.count = self.model:getOwnCount(data.itemId)

			if data.count > 0 then
				self.view.inventoryUList:SetElement(index, data)

				if index == self.view.inventoryUList.selectedIndex then
					local res, btn = self.view.inventoryUList:TryGetChildAt(index)

					if res then
						btn:OnClickSimulate()
					end
				end

				return
			end
		end
	end

	self:onEnterPage()

	local isSelect = false
	local newIndex = self:tryGetIndexByItemId(selectedItemId)

	if newIndex then
		local res, btn = self.view.inventoryUList:TryGetChildAt(newIndex)

		if res then
			isSelect = true

			btn:OnClickSimulate()
		end
	end

	if not isSelect then
		self.ctrl:setItemInfoEmpty()
	end
end

function HomelandInventoryComponent:tryGetIndexByItemId(itemId)
	for idx, info in ipairs(self.inventoryList) do
		if info.itemId == itemId then
			return idx - 1
		end
	end
end

return HomelandInventoryComponent
