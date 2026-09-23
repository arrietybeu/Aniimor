-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CashGift\\CashGiftView.lua

local logger = require("Core.Log.LoggerManager").getLogger("CashGiftView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ItemPropUIUtils = require("Utils.ItemPropUIUtils")
local ClientCashShopUtils = require("Utils.ClientCashShopUtils")
local ItemData = require("Data.item_data")
local CashGiftView = Class.LightClass("CashGiftView", UIView)

function CashGiftView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.txtTitle = objectReference:GetRefValue("txtTitle")
	self.btnClose = objectReference:GetRefValue("btnClose")
	self.btnBuy = objectReference:GetRefValue("btnBuy")
	self.txtName = objectReference:GetRefValue("txtName")
	self.txtDesc = objectReference:GetRefValue("txtDesc")
	self.txtSendTex = objectReference:GetRefValue("txtSendTex")
	self.txtSendPlayerName = objectReference:GetRefValue("txtSendPlayerName")
	self.txtMsgTitle = objectReference:GetRefValue("txtMsgTitle")
	self.msgInputField = objectReference:GetRefValue("msgInputField")
	self.msgInputFieldLimit = objectReference:GetRefValue("msgInputFieldLimit")
	self.txtMsg = objectReference:GetRefValue("txtMsg")
	self.costItem = objectReference:GetRefValue("costItem")
	self.ImgAvatar = objectReference:GetRefValue("ImgAvatar")
	self.imgItem = objectReference:GetRefValue("imgItem")
	self.itemUComponent = objectReference:GetRefValue("itemUComponent")
	self.numSelector = objectReference:GetRefValue("numSelector")
	self.rootUComponent = objectReference:GetRefValue("rootUComponent")
	self.placeHolderUBaseText = objectReference:GetRefValue("placeHolderUBaseText")
	self.txtSendBtnName = objectReference:GetRefValue("txtSendBtnName")
	self.listCurrencyUList = objectReference:GetRefValue("listCurrencyUList")
	self.listUList = objectReference:GetRefValue("listUList")
end

function CashGiftView:registerObjects()
	return
end

function CashGiftView:setupGiftView(model)
	ClientTextUtils.setText(self.txtTitle, pg.getGameString("SEND_TEXT"))
	ClientTextUtils.setText(self.txtSendTex, pg.getGameString("SEND_SOMEONE"))
	ClientTextUtils.setText(self.txtMsgTitle, pg.getGameString("SEND_MESSAGE"))
	ClientTextUtils.setText(self.txtSendBtnName, pg.getGameString("SEND_TEXT"))

	local sendLimit = model:getSendLimit()

	if self.msgInputField then
		self.msgInputField.characterLimit = sendLimit * 2
	end

	if self.msgInputFieldLimit then
		ClientTextUtils.setText(self.msgInputFieldLimit, string.format("0/%d", sendLimit))
	end

	local defaultWord = model:getDefaultSendWord()

	if defaultWord ~= "" then
		if self.placeHolderUBaseText then
			ClientTextUtils.setText(self.placeHolderUBaseText, defaultWord)
		end

		if self.txtMsg then
			ClientTextUtils.setText(self.txtMsg, defaultWord)
		end
	end
end

function CashGiftView:refreshCommodityInfo(model)
	local commodityInfo = model:getCommodityInfo()
	local itemInfo = model:getItemInfo()
	local hasProductInfo = model:hasProductInfo()

	if not commodityInfo and not hasProductInfo or not itemInfo and not hasProductInfo then
		return
	end

	local productName = hasProductInfo and model:getProductDisplayName()

	if productName then
		ClientTextUtils.setText(self.txtName, pg.getLocalizationText(productName))
	elseif itemInfo then
		ClientTextUtils.setText(self.txtName, pg.getLocalizationText(itemInfo.itemName))
	end

	local productDesc = hasProductInfo and model:getProductDisplayDesc()

	if productDesc then
		ClientTextUtils.setText(self.txtDesc, pg.getLocalizationText(productDesc))
	else
		local avatarType = commodityInfo and commodityInfo.avatarType or itemInfo and itemInfo.displayType

		if avatarType then
			ClientTextUtils.setText(self.txtDesc, ClientCashShopUtils.getAvatarTypeText(avatarType))
		end
	end

	local kindPage = model:getKindPage()

	self.rootUComponent:TryChangePage("Kind", kindPage)

	local displayItemId = model:getItemId()
	local receiverGender = model:getReceiverGender()

	displayItemId = ClientCashShopUtils.getGenderConvertedItemId(displayItemId, receiverGender) or displayItemId

	if kindPage == 0 then
		self.ImgAvatar.url = LuaUIUtils.getIconByItemId(displayItemId)
	elseif kindPage == 1 then
		self.imgItem.url = model:getProductDisplayIcon() or LuaUIUtils.getIconByItemId(displayItemId)
	else
		local data = {
			id = displayItemId,
			num = commodityInfo.num or 1
		}

		LuaUIUtils.renderRewardItem(self.itemUComponent, data)
	end

	if self.numSelector then
		if kindPage == 2 then
			self.numSelector.gameObject:SetActiveEx(true)

			local maxCount = model:getMaxBuyCount()

			self.numSelector.maxValue = math.max(1, maxCount or 0)
			self.numSelector.value = 1
		else
			self.numSelector.gameObject:SetActiveEx(false)
		end
	end
end

function CashGiftView:refreshPlayerInfo(playerName)
	ClientTextUtils.setText(self.txtSendPlayerName, playerName or "")
end

function CashGiftView:_getCostItemRefs()
	if not self.costItem then
		return
	end

	local objectReference = self.costItem:GetComponent("ObjectReference")

	if not objectReference then
		return
	end

	return objectReference, LuaUIUtils.safeGetRefValue(objectReference, "imgIcon"), LuaUIUtils.safeGetRefValue(objectReference, "txtNum")
end

function CashGiftView:refreshCostDisplay(cost, count)
	if not cost then
		local _, imgIcon, txtNum = self:_getCostItemRefs()

		if imgIcon then
			imgIcon.gameObject:SetActiveEx(false)
		end

		if txtNum then
			ClientTextUtils.setText(txtNum, "")
		end

		return
	end

	ItemPropUIUtils.renderConsumeItem(self.costItem, cost, false)

	local _, imgIcon = self:_getCostItemRefs()

	if imgIcon then
		imgIcon.gameObject:SetActiveEx(true)
	end
end

function CashGiftView:refreshCurrencyList(cost)
	if not self.listCurrencyUList then
		return
	end

	if not cost then
		self.listCurrencyUList:SetList({})

		return
	end

	function self.listCurrencyUList.luaRenderItem(button, _, data)
		LuaUIUtils.setTopCurrencyItem(button, data.itemId)
	end

	self.listCurrencyUList:SetList({
		{
			itemId = cost[1]
		}
	})
end

function CashGiftView:refreshItemList(itemList)
	if not self.listUList then
		return
	end

	function self.listUList.luaRenderItem(button, _, data)
		local objectReference = button:GetComponent("ObjectReference")
		local itemIconUImage = objectReference:GetRefValue("itemIconUImage")
		local txtNumUText = objectReference:GetRefValue("txtNumUText")
		local itemId = data.id
		local itemNum = data.num or 1

		if itemIconUImage then
			itemIconUImage.url = LuaUIUtils.getIconByItemId(itemId)
		end

		if txtNumUText then
			ClientTextUtils.setText(txtNumUText, itemNum)
		end

		local itemConfig = ItemData[itemId]

		button:TryChangePage("Quality", itemConfig and itemConfig.quality or 0)

		function button.luaClick()
			LuaUIUtils.onRewardItemClick(button, {
				id = itemId,
				num = itemNum
			})
		end
	end

	self.listUList:SetList(itemList or {})
end

function CashGiftView:refreshCostByProductPrice(priceText)
	local _, imgIcon, txtNum = self:_getCostItemRefs()

	if imgIcon then
		imgIcon.gameObject:SetActiveEx(false)
	end

	if txtNum then
		ClientTextUtils.setText(txtNum, priceText or "")
	end
end

function CashGiftView:refreshInputLimit(currentLen, maxLen)
	if self.msgInputFieldLimit then
		ClientTextUtils.setText(self.msgInputFieldLimit, string.format("%d/%d", currentLen, maxLen))
	end
end

return CashGiftView
