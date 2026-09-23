-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Lottery\\Component\\LotteryRewardShowComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local UIConst = require("Const.UIConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ClientCashShopUtils = require("Utils.ClientCashShopUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Utils = require("Common.Utils.Utils")
local Time = require("Core.Common.Time")
local ItemData = require("Data.item_data")
local ItemShowTypeData = require("Data.item_type_show_data")
local LotteryRewardShowComponent = Class.LightClass("LotteryRewardShowComponent", UIComponent)

function LotteryRewardShowComponent:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.rootUComponent = objectReference:GetRefValue("rootUComponent")
	self.listLeftUList = objectReference:GetRefValue("listLeftUList")
	self.listRightUList = objectReference:GetRefValue("listRightUList")
	self.btnReward = objectReference:GetRefValue("btnReward")
	self.txtBtnReward = objectReference:GetRefValue("txtBtnReward")
	self.btnGotoGacha = objectReference:GetRefValue("btnGotoGacha")
	self.txtTitle = objectReference:GetRefValue("txtTitle")
	self.txtBtnGotoGacha = objectReference:GetRefValue("txtBtnGotoGacha")
end

function LotteryRewardShowComponent:registerObjects()
	function self.listLeftUList.luaRenderItem(button, index, data)
		self:renderLeftItem(button, index, data)
	end

	function self.listLeftUList.luaClick(button, data)
		self:selectItem(data)
	end

	function self.listRightUList.luaRenderItem(button, index, data)
		LuaUIUtils.renderRewardItem(button, data)
	end

	function self.btnReward.luaClick()
		self:openOtherReward()
	end

	function self.btnGotoGacha.luaClick()
		self.ctrl:gotoGacha()
	end
end

function LotteryRewardShowComponent:initView()
	ClientTextUtils.setText(self.txtBtnReward, pg.getGameString("LOTTERY_OTHER_REWARD"))
	ClientTextUtils.setText(self.txtTitle, pg.getGameString("LOTTERY_HAS_REWARD"))
	ClientTextUtils.setText(self.txtBtnGotoGacha, pg.getGameString("LOTTERY_GO_GACHA"))
	self.listLeftUList:SetList({})
	self.listRightUList:SetList({})
end

function LotteryRewardShowComponent:setInfo(info)
	self._info = Utils.isTable(info) and info or {}
	self._itemList = Utils.isTable(self._info.itemList) and self._info.itemList or {}
	self._selectedItem = self._itemList[1]

	self.listLeftUList:SetList(self._itemList)

	if self._selectedItem then
		self.listLeftUList:SelectItem(0, false)
	else
		self.listLeftUList:SelectItem(-1, false)
	end

	self:refreshContentList()
end

function LotteryRewardShowComponent:renderLeftItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")

	if not objectReference then
		return
	end

	local txtTitle = objectReference:GetRefValue("txtTitle")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local imgCost = objectReference:GetRefValue("imgCost")
	local txtBaseCost = objectReference:GetRefValue("txtBaseCost")
	local txtDiscountCost = objectReference:GetRefValue("txtDiscountCost")
	local discountUWidget = objectReference:GetRefValue("discountUWidget")
	local txtDiscount = objectReference:GetRefValue("txtDiscount")
	local newUWidget = objectReference:GetRefValue("newUWidget")
	local pullUWidget = objectReference:GetRefValue("pullUWidget")
	local discountCountdownUWidget = objectReference:GetRefValue("discountCountdownUWidget")
	local txtDiscountCountDown = objectReference:GetRefValue("txtDiscountCountDown")
	local countDownDiscount = objectReference:GetRefValue("countDownDiscount")
	local itemConfig = ItemData[data.itemId]
	local isCommodity = data.rewardShowType == "commodity"
	local hasDiscount = isCommodity and data.hasDiscount == true
	local isRewardShopCommodity = isCommodity and tonumber(data.showInReward) == 1
	local showDiscount = isRewardShopCommodity or hasDiscount

	ClientTextUtils.setText(txtTitle, data.name and pg.getLocalizationText(data.name) or LuaUIUtils.getNameByItemId(data.itemId))

	if iconUImage then
		local commodityBanner = isCommodity and ClientCashShopUtils.getCommodityBannerByGender(data) or nil

		if not string.isNilOrEmpty(commodityBanner) then
			iconUImage.url = commodityBanner
		else
			iconUImage.url = itemConfig and LuaUIUtils.getIconByIconId(itemConfig.icon) or ""
		end
	end

	if imgCost then
		imgCost:SetActive(false)
	end

	if txtBaseCost then
		txtBaseCost:SetActive(isCommodity)

		local itemShowType = itemConfig and ItemShowTypeData[itemConfig.displayType] or nil

		ClientTextUtils.setText(txtBaseCost, isCommodity and itemShowType and pg.getLocalizationText(itemShowType.type) or "")
	end

	if txtDiscountCost then
		txtDiscountCost:SetActive(false)
	end

	if discountUWidget then
		discountUWidget:SetActive(showDiscount)
	end

	if txtDiscount then
		local discountText = ""

		if isRewardShopCommodity then
			discountText = pg.getGameString("LOTTERY_SHOP_OLNY")
		elseif hasDiscount and data.tagName then
			discountText = pg.getLocalizationText(data.tagName)
		end

		ClientTextUtils.setText(txtDiscount, discountText)
	end

	if newUWidget then
		newUWidget:SetActive(false)
	end

	if pullUWidget then
		pullUWidget:SetActive(false)
	end

	if discountCountdownUWidget then
		discountCountdownUWidget:SetActive(false)
	end

	if txtDiscountCountDown then
		ClientTextUtils.setText(txtDiscountCountDown, isCommodity and pg.getGameString("CASH_SHOP_DISCOUNT_TIME") or "")
	end

	if countDownDiscount then
		countDownDiscount.luaFinished = nil

		countDownDiscount:Stop()
		countDownDiscount:SetActive(false)
	end

	local closeTime = Utils.isTable(self._info) and tonumber(self._info.closeTime) or nil
	local showCountDown = isCommodity and closeTime ~= nil and closeTime > Time.getSecond()

	if discountCountdownUWidget then
		discountCountdownUWidget:SetActive(showCountDown)
	end

	if countDownDiscount then
		countDownDiscount:SetActive(showCountDown)

		if showCountDown then
			function countDownDiscount.luaFinished()
				if discountCountdownUWidget then
					discountCountdownUWidget:SetActive(false)
				end

				countDownDiscount:SetActive(false)
			end

			LuaUIUtils.setCountDownTime(countDownDiscount, closeTime, UIConst.TimeType.Short)
		end
	end

	button:TryChangePage("State", 0)
	button:TryChangePage("Quality", itemConfig and itemConfig.quality or 0)
	button:SetSelected(self._selectedItem ~= nil and self._selectedItem.rewardShowKey == data.rewardShowKey)
end

function LotteryRewardShowComponent:selectItem(data)
	if not Utils.isTable(data) then
		return
	end

	self._selectedItem = data

	for index, itemData in ipairs(self._itemList) do
		if itemData.rewardShowKey == data.rewardShowKey then
			self.listLeftUList:SelectItem(index - 1, false)

			break
		end
	end

	self:refreshContentList()
end

function LotteryRewardShowComponent:refreshContentList()
	local isSuit = Utils.isTable(self._selectedItem) and tonumber(self._selectedItem.isSuit) == 1

	self.rootUComponent:TryChangePage("IsSuit", isSuit and 1 or 0)

	local contentList = self.model:getRewardShowContentList(self._selectedItem)

	self.listRightUList:SetList(contentList)
end

function LotteryRewardShowComponent:openOtherReward()
	local drawId = Utils.isTable(self._info) and self._info.drawId or nil

	pg.global.ui:open(UIConst.UI_ID_LOTTERY_OTHER_REWARD, {
		drawId = drawId
	})
end

function LotteryRewardShowComponent:onDestroy()
	self.listLeftUList.luaRenderItem = nil
	self.listLeftUList.luaClick = nil
	self.listRightUList.luaRenderItem = nil
	self.btnReward.luaClick = nil
	self.btnGotoGacha.luaClick = nil
	self._info = nil
	self._itemList = nil
	self._selectedItem = nil
end

return LotteryRewardShowComponent
