-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandMarket\\Component\\HomelandSaleComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomelandSaleComponent")
local Class = require("Core.Framework.Class")
local Time = require("Core.Common.Time")
local Utils = require("Common.Utils.Utils")
local UIComponent = require("Guis.Helper.UIComponent")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local HomelandMaterialShopData = require("Data.homeland_material_shop_data")
local HomelandSaleComponent = Class.LightClass("HomelandSaleComponent", UIComponent)

function HomelandSaleComponent:findObjects()
	return
end

function HomelandSaleComponent:initView()
	self:addListener()
end

function HomelandSaleComponent:addListener()
	function self.view.marketUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local iconUImage = objectReference:GetRefValue("iconUImage")
		local priceUBaseText = objectReference:GetRefValue("priceUBaseText")
		local numUBaseText = objectReference:GetRefValue("numUBaseText")
		local numDescUBaseText = objectReference:GetRefValue("numDescUBaseText")
		local rootUComponent = objectReference:GetRefValue("rootUComponent")

		rootUComponent:TryChangePage("Quality", data.quality)

		iconUImage.url = data.icon

		ClientTextUtils.setText(numDescUBaseText, pg.getGameString("HOMELAND_MARKET_SALE_COUNT"))
		ClientTextUtils.setText(priceUBaseText, data.currencyNum)
		ClientTextUtils.setText(numUBaseText, data.count == 0 and "<style=Debuff>0</style>" or data.count)
	end

	function self.view.marketUList.luaClick(button, data)
		self.ctrl:showItemDetail(data, data.ownCount, data.selectorCount)
	end
end

function HomelandSaleComponent:onDestroy()
	UIComponent.onDestroy(self)
end

function HomelandSaleComponent:onEnterPage()
	self.view.marketUList:DeselectAll()

	self.view.timeUCountDown.baseColor = Color(255, 255, 255)
	self.view.timeUCountDown.formatText = "{1}:{2}:{3}"

	local nextUpdateTimeSecond = pg.me.homelandOrderInfo.updateTs + 86400
	local countDown = nextUpdateTimeSecond - Time.getSecond()

	self.view.timeUCountDown:Play(countDown)

	local shopId = self.ctrl.shopId
	local shopData = HomelandMaterialShopData[shopId]

	self.marketList = self.model:getMarketList(shopId)

	if not shopData or Utils.isEmptyTable(self.marketList) then
		self.view.rootUComponent:TryChangePage("Empty", 1)
		ClientTextUtils.setText(self.view.emptyTitleUBaseText, pg.getGameString("HOMELAND_MARKET_EMPTY_SALE"))
		ClientTextUtils.setText(self.view.emptyInfoUBaseText, pg.getGameString("HOMELAND_MARKET_EMPTY_SALE_INFO"))
		self.ctrl:setItemInfoEmpty()

		return
	end

	self.view.rootUComponent:TryChangePage("Empty", 0)
	self.ctrl:setItemInfoEmpty()
	self.view.marketUList:SetList(self.marketList)
end

function HomelandSaleComponent:refreshSelectElement()
	local index = self.view.marketUList.selectedIndex

	self:refreshElementByIndex(index)
end

function HomelandSaleComponent:refreshElementByIndex(index)
	local selectedItemId = self.view.marketUList.selectedItem and self.view.marketUList.selectedItem.itemId

	if index then
		local data = self.view.marketUList:GetData(index)

		if data then
			local highPriceCountLeft = self.model:getHighPriceCountLeft(self.ctrl.shopId, self.ctrl.materialId)
			local ownCount = self.model:getOwnCount(data.itemId)

			data.ownCount = ownCount
			data.count = highPriceCountLeft
			data.selectorCount = math.min(ownCount, highPriceCountLeft)

			if data.count > 0 then
				self.view.marketUList:SetElement(index, data)

				if index == self.view.marketUList.selectedIndex then
					local res, btn = self.view.marketUList:TryGetChildAt(index)

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
		local res, btn = self.view.marketUList:TryGetChildAt(newIndex)

		if res then
			isSelect = true

			btn:OnClickSimulate()
		end
	end

	if not isSelect then
		self.ctrl:setItemInfoEmpty()
	end
end

function HomelandSaleComponent:tryGetIndexByItemId(itemId)
	for idx, info in ipairs(self.marketList) do
		if info.itemId == itemId then
			return idx - 1
		end
	end
end

return HomelandSaleComponent
