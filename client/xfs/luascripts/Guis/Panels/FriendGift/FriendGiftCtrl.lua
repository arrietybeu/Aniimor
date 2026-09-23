-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\FriendGift\\FriendGiftCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("FriendGiftCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local FriendGiftCtrl = Class.LightClass("FriendGiftCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")
local FriendshipLevelData = require("Data.friendship_level_data")
local ItemUseTypeMap = require("Data.item_use_type_map")
local ItemConst = require("Common.Const.ItemConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ItemShopData = require("Data.item_shop_data")
local ItemUtils = require("Common.Utils.ItemUtils")
local ShopClassifyData = require("Data.shop_classify_data")
local ShopCommodityData = require("Data.shop_commodity_data")
local UIConst = require("Const.UIConst")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local SysConfigData = require("Data.sys_config_data")
local ClientUtils = require("Utils.ClientUtils")

FriendGiftCtrl.messages = {
	[MessageName.SEND_FRIEND_GIFT_RESULT] = {
		"refreshUI",
		true
	},
	[MessageName.FRIENDSHIP_UPDATE] = {
		"refreshUI",
		true
	},
	[MessageName.SHOP_ON_BUY_ITEMS] = {
		"onBuyGiftItems",
		true
	}
}

local FRIEND_GIFT_SHOP_CFG_ID = 32

function FriendGiftCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	if not info or not info.playerId then
		return
	end

	self.info = info
	self.playerInfo = pg.game.chat:getPlayerInfo(info.playerId)

	if not self.playerInfo then
		return
	end

	self.selectedGiftItemCount = 0

	self:initUI()
end

function FriendGiftCtrl:addListener()
	function self.view.btnCloseUButton.luaClick()
		self:onClose()
	end

	function self.view.btnUButton.luaClick()
		self:onConfirmButtonClick()
	end

	local numSelector = self.view.numSelectorUNumSelector

	function numSelector.luaValueChanged(num)
		self:onGiftNumSelectorValueChanged(num)
	end

	function numSelector.luaOnGetValueText(num)
		local displayNum = math.max(num, 1)
		local isGiftNumEnough = displayNum <= self.selectedGiftItemCount and displayNum <= self:getRemainingGiftNum()

		if not isGiftNumEnough then
			return string.format("<style=Debuff>%d</style>", displayNum)
		end

		return tostring(displayNum)
	end
end

function FriendGiftCtrl:onClose()
	self:close()
end

function FriendGiftCtrl:initUI()
	ClientTextUtils.setText(self.view.txtTltleUSDFText, pg.getGameString("CHAT_GIFT_SEND_TITLE"))

	local displayName = LuaUIUtils.getPlayerDisplayName(self.info.playerId, self.playerInfo.playerName)
	local platformHooks = FriendGiftCtrl._platformHooks

	if platformHooks and platformHooks.refreshUI then
		displayName = platformHooks.refreshUI(self, displayName)
	end

	ClientTextUtils.setText(self.view.textGiveUSDFText, pg.getFormatText(pg.getGameString("CHAT_GIFT_SEND_FRONT"), ""))
	ClientTextUtils.setText(self.view.textNameUSDFText, displayName)
	self:refreshGiftLimitText()
	self:initGiftListRender()
	self:initGiftList()
end

function FriendGiftCtrl:refreshGiftLimitText()
	local limitTypeTextKey = Const.LimitType2TextKeyMap[SysConfigData.SendGiftLimitType]
	local textTemplate = pg.getGameString("FRIEND_GIFT_REMAINING_COUNT")

	ClientTextUtils.setText(self.view.textTipsUSDFText, pg.getFormatText(textTemplate, pg.getGameString(limitTypeTextKey), self:getRemainingGiftNum()))
end

function FriendGiftCtrl:onShow()
	self:startFrameTimer(function()
		self:selectDefaultGiftItem()
	end, 1)
end

function FriendGiftCtrl:refreshUI()
	if not self.view then
		return
	end

	self:refreshGiftLimitText()

	if self.view.giftlistUList and self.giftListData then
		self.view.giftlistUList:SetList(self.giftListData)
	end

	if self.selectedGiftItemId then
		self:refreshGiftNumSelector(self.selectedGiftItemId)
		self:refreshGiftInfo(self.selectedGiftItemId)
	end
end

function FriendGiftCtrl:onBuyGiftItems()
	self:refreshUI()
end

function FriendGiftCtrl:initGiftListRender()
	if not self.view or not self.view.giftlistUList then
		return
	end

	function self.view.giftlistUList.luaRenderItem(button, index, data)
		self:renderGiftListItem(button, index, data)
	end

	function self.view.giftlistUList.luaSelectedChanged(uList, selected)
		self:onGiftListSelectedChanged(uList, selected)
	end

	function self.view.giftlistUList.luaFinishRender(uList)
		if not pg.game.input:isUsingGamepad() then
			return
		end

		local firstItem = uList:GetAllButtons()[0]

		pg.global.navMgr:FocusItem(firstItem)
	end
end

function FriendGiftCtrl:initGiftList()
	if not self.view or not self.view.giftlistUList then
		return
	end

	local data = {}

	for _, giftItemConfig in ipairs(SysConfigData.FRIEND_GIFTS_ID) do
		local itemId, condition = giftItemConfig[1], giftItemConfig[2]

		if itemId then
			data[#data + 1] = {
				tIndex = 0,
				itemId = itemId,
				condition = condition
			}
		end
	end

	self.giftListData = data

	self.view.giftlistUList:SetList(data)
end

function FriendGiftCtrl:selectDefaultGiftItem()
	if not self.view or not self.view.giftlistUList then
		return
	end

	self.view.giftlistUList:SelectItem(0, false)
	self.view.giftlistUList:SetUListSwitchCurrentIndex(0)

	local data = self.giftListData and self.giftListData[1]

	if data then
		self:refreshGiftNumSelector(data.itemId)
		self:refreshGiftInfo(data.itemId)
	end
end

function FriendGiftCtrl:renderGiftListItem(button, index, data)
	if not button or not data then
		return
	end

	local itemId = data.itemId
	local objectReference = button:GetComponent("ObjectReference")
	local giftUButton = objectReference:GetRefValue("giftUButton")
	local textNameUSDFText = objectReference:GetRefValue("textNameUSDFText")
	local textNumUSDFText = objectReference:GetRefValue("textNumUSDFText")
	local lockUSDFText = objectReference:GetRefValue("lockUSDFText")
	local lockUImage = objectReference:GetRefValue("lockUImage")
	local itemCount = ItemUtils.getItemCountById(pg.me, itemId) or 0
	local isUnlock = self:isGiftItemUnlock(data)

	button:TryChangePage("State", isUnlock and 0 or 1)

	if isUnlock then
		LuaUIUtils.renderRewardItem(giftUButton, {
			id = itemId,
			num = itemCount
		})
		ClientTextUtils.setText(textNameUSDFText, LuaUIUtils.getNameByItemId(itemId) or "")
		ClientTextUtils.setText(textNumUSDFText, pg.getFormatText(pg.getGameString("FRIEND_GIFT_OWNED_COUNT"), itemCount))
	else
		lockUImage.url = LuaUIUtils.getIconByItemId(itemId)

		ClientTextUtils.setText(lockUSDFText, pg.getGameString("GIFT_NOT_AVAILABLE"))
	end

	self:refreshGiftItemInteractionState(button, giftUButton, index, isUnlock)
end

function FriendGiftCtrl:refreshGiftItemInteractionState(button, giftUButton, index, isUnlock)
	button.interactable = isUnlock
	button.luaClick = nil
	button.luaNavFocused = nil
	giftUButton.interactable = isUnlock
	giftUButton.luaNavFocused = nil

	if not isUnlock then
		giftUButton.luaClick = nil

		return
	end

	local function selectGiftItem()
		if not pg.game.input:isUsingGamepad() or button.isSelected then
			return
		end

		self.view.giftlistUList:SelectItem(index)
	end

	button.luaNavFocused = selectGiftItem
	giftUButton.luaNavFocused = selectGiftItem
end

function FriendGiftCtrl:onGiftListSelectedChanged(uList, selected)
	if selected == false then
		return
	end

	local data = uList.selectedItem

	if not data or not self:isGiftItemUnlock(data) then
		return
	end

	self:refreshGiftNumSelector(data.itemId)
	self:refreshGiftInfo(data.itemId)
end

function FriendGiftCtrl:refreshGiftNumSelector(itemId)
	if not self.view or not self.view.numSelectorUNumSelector then
		return
	end

	local itemCount = ItemUtils.getItemCountById(pg.me, itemId) or 0

	self.selectedGiftItemId = itemId
	self.selectedGiftItemCount = itemCount

	local numSelector = self.view.numSelectorUNumSelector
	local remainingGiftNum = self:getRemainingGiftNum()
	local minValue = math.min(1, remainingGiftNum)
	local selectableGiftNum = self:calculateGiftNumRange(itemCount, remainingGiftNum)
	local value = math.min(numSelector.value, selectableGiftNum)

	numSelector:SetAllValue(value, minValue, selectableGiftNum, 1, false)
	self:onGiftNumSelectorValueChanged(numSelector.value)
end

function FriendGiftCtrl:calculateGiftNumRange(itemCount, remainingGiftNum)
	local selectableGiftNum = math.min(math.max(itemCount, 1), remainingGiftNum)

	return selectableGiftNum
end

function FriendGiftCtrl:getRemainingGiftNum()
	local sentGiftCount = pg.game.chat:getFriendSendGiftLimitCount(self.info.playerId)

	return math.max(SysConfigData.SendGiftLimitParam - sentGiftCount, 0)
end

function FriendGiftCtrl:onGiftNumSelectorValueChanged(num)
	local remainingGiftNum = self:getRemainingGiftNum()
	local selectableGiftNum = self:calculateGiftNumRange(self.selectedGiftItemCount, remainingGiftNum)

	self.selectedGiftNum = math.min(num, selectableGiftNum)

	if selectableGiftNum < num then
		self.view.numSelectorUNumSelector:SetValueWithoutNotify(selectableGiftNum)

		if remainingGiftNum >= self.selectedGiftItemCount then
			self:showOwnedCountExceededTip()
		else
			pg.global.ui.tips:showTextTip(self:getGiftLimitExceededText())
		end
	end

	self:refreshConfirmButton()
end

function FriendGiftCtrl:showOwnedCountExceededTip()
	pg.global.ui.tips:showTextTip(pg.getGameString("FRIEND_GIFT_OWNED_COUNT_EXCEEDED"))
end

function FriendGiftCtrl:onConfirmButtonClick()
	local itemId = self.selectedGiftItemId
	local itemCount = itemId and ItemUtils.getItemCountById(pg.me, itemId) or 0
	local selectedGiftNum = self:getSelectedGiftNum()
	local remainingGiftNum = self:getRemainingGiftNum()

	if itemCount == 0 and self:isGiftItemPurchasableInFriendGiftShop(itemId) then
		pg.global.ui:open(UIConst.UI_ID_FRIEND_GIFT_BUY, {
			itemId = itemId,
			buyCount = math.max(selectedGiftNum, 1)
		})

		return
	end

	if itemCount > 0 and itemCount < selectedGiftNum then
		self:showOwnedCountExceededTip()

		return
	end

	if remainingGiftNum == 0 or remainingGiftNum < selectedGiftNum then
		pg.global.ui.tips:showTextTip(self:getGiftLimitExceededText())

		return
	end

	if selectedGiftNum <= itemCount then
		self:sendSelectedGift()

		return
	end

	pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
		id = itemId,
		num = itemCount,
		targetRect = self.view.btnUButton
	})
end

function FriendGiftCtrl:getGiftLimitExceededText()
	local limitTypeTextKey = Const.LimitType2TextKeyMap[SysConfigData.SendGiftLimitType]

	return pg.getFormatText(pg.getGameString("FRIEND_GIFT_LIMIT_EXCEEDED"), pg.getGameString(limitTypeTextKey))
end

function FriendGiftCtrl:isGiftItemPurchasableInFriendGiftShop(itemId)
	local shopClassCfg = ShopClassifyData[FRIEND_GIFT_SHOP_CFG_ID]
	local shopClassify = shopClassCfg and shopClassCfg.classify
	local shopItemIds = ItemShopData[itemId]

	if not shopClassify or not shopItemIds then
		return false
	end

	for _, shopItemId in ipairs(shopItemIds) do
		local shopItemCfg = ShopCommodityData[shopItemId]
		local isOnSale = shopItemCfg and shopItemCfg.onSale == 1
		local isShopTagMatched = isOnSale and table.contains(shopClassify, shopItemCfg.tag)

		if isShopTagMatched then
			return true
		end
	end

	return false
end

function FriendGiftCtrl:sendSelectedGift()
	local itemId = self.selectedGiftItemId
	local giftNum = self:getSelectedGiftNum()

	if not itemId or giftNum <= 0 then
		return
	end

	pg.me:sendGifts(self.info.playerId, {
		[itemId] = giftNum
	})
end

function FriendGiftCtrl:getSelectedGiftNum()
	if self.selectedGiftNum == nil then
		return 1
	end

	return self.selectedGiftNum
end

function FriendGiftCtrl:refreshConfirmButton()
	if not self.view or not self.view.btnUButton then
		return
	end

	local itemId = self.selectedGiftItemId
	local itemCount = itemId and ItemUtils.getItemCountById(pg.me, itemId) or 0
	local textKey = "SEND_TEXT"

	if itemCount == 0 then
		textKey = self:isGiftItemPurchasableInFriendGiftShop(itemId) and "FRIEND_GIFT_BUY_SEND" or "GET_CHANNEL"
	end

	ClientTextUtils.setText(self.view.txtNameUText, pg.getGameString(textKey))

	self.view.btnUButton.interactable = true

	if self.view.btnUButton.visualInteractable ~= nil then
		self.view.btnUButton.visualInteractable = true
	end
end

function FriendGiftCtrl:isGiftItemUnlock(data)
	local condition = data and data.condition

	if not condition or condition == 0 then
		return true
	end

	print(string.format("%s____%s", condition, ClientUtils.checkCondition(condition) and "true" or "false"))

	return ClientUtils.checkCondition(condition)
end

function FriendGiftCtrl:refreshGiftInfo(giftId)
	if not self.view then
		return
	end

	if self.view.giftIconUImage then
		self.view.giftIconUImage.url = LuaUIUtils.getIconByItemId(giftId) or ""
	end
end

return FriendGiftCtrl
