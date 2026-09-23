-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\BpExchange\\BpExchangeCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("BpExchangeCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local CashShopConst = require("Const.CashShopConst")
local ClientCashShopUtils = require("Utils.ClientCashShopUtils")
local UIConst = require("Const.UIConst")
local ProductInformationComponent = require("Guis.Panels.CashShop.Component.ProductInformationComponent")
local CashShopBuyComponent = require("Guis.Panels.CashShop.Component.CashShopBuyComponent")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local ActivityConst = require("Common.Const.ActivityConst")
local BattlePassData = require("Data.event_battlepass_data")
local PlayerHeadIconData = require("Data.player_head_icon_data")
local PlayerHeadFrameData = require("Data.player_head_frame_data")
local CardBackgroundData = require("Data.card_background_data")
local AddressDataConst = require("Const.AddressDataConst")
local Utils = require("Common.Utils.Utils")
local FriendNewComponent = require("Guis.Panels.Chat.Component.FriendNewComponent")
local ShopmallTabGroupData = require("Data.shopmall_tab_group_data")
local BpExchangeCtrl = Class.LightClass("BpExchangeCtrl", UICtrl)

BpExchangeCtrl.messages = {
	[MessageName.CASH_SHOP_REWARD_CHANGED] = {
		"refreshCommodChangeInfo",
		true
	},
	[MessageName.CASH_SHOP_ON_BUY_ITEM] = {
		"onBuyItemResult",
		true
	}
}

function BpExchangeCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self._destroyed = false
end

function BpExchangeCtrl:addListener()
	local view = self.view

	function view.btnBack.luaClick()
		self:dismiss()
	end

	if view.productInformationUComponent and not self.productInformation then
		self.productInformation = ProductInformationComponent.new(self, view.productInformationUComponent)
	end

	if view.propInfoUContainer and not self.buyComponent then
		self.buyComponent = CashShopBuyComponent.new(self, view.propInfoUContainer, {
			itemInfoContainer = view.propInfoUContainer
		})
	end

	if view.btnGiftUButton then
		view.btnGiftUButton:SetActive(false)

		function view.btnGiftUButton.luaClick()
			local data = self._currentData

			if data and data.commodityId then
				self:showFriendList(data.commodityId)
			end
		end
	end

	if view.friendNewUComponent and not self.friendComponent then
		self.friendComponent = FriendNewComponent.new(self, view.friendNewUComponent)
	end

	if self.productInformation then
		self.productInformation:addListener()
	end

	if view.listUList then
		function view.listUList.luaRenderItem(button, index, data)
			ClientCashShopUtils.renderCommodityItem(button, data)
		end

		function view.listUList.luaClick(_, data)
			self:refreshCommodInfo(data)
		end
	end

	if view.btnAvatarDisplayUButton then
		view.btnAvatarDisplayUButton:SetActive(false)

		self._avatarDisplayOn = false

		view.btnAvatarDisplayUButton:TryChangePage("filter", 0)

		function view.btnAvatarDisplayUButton.luaClick()
			self._avatarDisplayOn = not self._avatarDisplayOn

			view.btnAvatarDisplayUButton:TryChangePage("filter", self._avatarDisplayOn and 1 or 0)

			local data = self._currentData

			if data and data.itemType then
				local ItemType = CashShopConst.CommodityItemType

				if data.itemType == ItemType.AVATAR_FRAME then
					self:_refreshPlayerFrame(data)
				elseif data.itemType == ItemType.AVATAR then
					self:_refreshPlayerHead(data)
				end
			end
		end
	end

	if view.btnFilter then
		view.btnFilter:TryChangePage("filter", 0)

		function view.btnFilter.luaClick()
			pg.global.ui:open(UIConst.UI_ID_CASH_FILTER, {
				groupId = self._groupId,
				previousState = self._filterState,
				onConfirm = function(filterState)
					if filterState.isFiltering then
						self._filterState = filterState

						view.btnFilter:TryChangePage("filter", 1)
						self:_refreshList()
					else
						local hadFilter = self._filterState ~= nil

						self._filterState = nil

						view.btnFilter:TryChangePage("filter", 0)

						if hadFilter then
							self:_refreshList()
						end
					end
				end,
				onReset = function()
					self._filterState = nil

					view.btnFilter:TryChangePage("filter", 0)
					self:_refreshList()
				end
			})
		end
	end

	if view.btnEllipses then
		function view.btnEllipses.luaRenderTooltip(_, tipItem)
			local objectReference = tipItem:GetComponent("ObjectReference")
			local listUList = objectReference:GetRefValue("listUList")
			local tooltipData = {
				{
					label = "SHOP_HIDE_UI",
					onClick = function()
						self:dismiss()
					end
				}
			}

			function listUList.luaRenderItem(subButton, _, subData)
				local subObjectReference = subButton:GetComponent("ObjectReference")
				local txtName = subObjectReference:GetRefValue("txtName")

				ClientTextUtils.setText(txtName, pg.getGameString(subData.label))

				function subButton.luaClick()
					view.btnEllipses:ClosePopup()
					subData.onClick()
				end
			end

			listUList:SetList(tooltipData)
		end
	end
end

function BpExchangeCtrl:onDestroy()
	self._destroyed = true

	UICtrl.onDestroy(self)
end

function BpExchangeCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function BpExchangeCtrl:onShow()
	local info = self._openInfo

	self._shopType = info and info.shopType or CashShopConst.ShopItemType.NO_DETAILS

	local actData = ActivityUtils.getActivityData(pg.me, ActivityConst.EventType.BattlePass)
	local phase = actData and actData.activityBase and actData.activityBase.activityPhase
	local bpData = phase and BattlePassData[phase]

	self._groupId = bpData and bpData.shopGroupId
	self._filterState = nil

	local view = self.view

	if view.btnFilter then
		view.btnFilter:TryChangePage("filter", 0)
	end

	self:_refreshCurrencyList()

	if view.txtBtnBack then
		ClientTextUtils.setText(view.txtBtnBack, pg.getGameString("BATTLEPASS_POPUP_TITLETEXT"))
	end

	self:_refreshList()
end

function BpExchangeCtrl:_refreshList()
	local raw = ClientCashShopUtils.getCommodityListByGroupId(self._groupId)

	if self._filterState then
		raw = ClientCashShopUtils.filterAndSortCommodityList(raw, self._filterState)
	end

	local list = self:_sortSoldOutToEnd(raw)
	local view = self.view

	if view.listUList then
		view.listUList:SetList(list)

		if #list > 0 then
			self:refreshCommodInfo(list[1])
		end
	end
end

function BpExchangeCtrl:_sortSoldOutToEnd(list)
	local normal, soldOut = {}, {}

	for _, item in ipairs(list) do
		if ClientCashShopUtils.getCommodityState(item) == ClientCashShopUtils.COMMODITY_STATE.SOLDOUT then
			soldOut[#soldOut + 1] = item
		else
			normal[#normal + 1] = item
		end
	end

	for _, item in ipairs(soldOut) do
		normal[#normal + 1] = item
	end

	return normal
end

function BpExchangeCtrl:refreshCommodInfo(data)
	if not data then
		return
	end

	self._currentData = data

	local view = self.view
	local shopType = self._shopType or CashShopConst.ShopItemType.NO_DETAILS

	if view.btnGiftUButton then
		local commodityState = ClientCashShopUtils.getCommodityState(data)
		local isLocked = commodityState == ClientCashShopUtils.COMMODITY_STATE.LOCKED

		view.btnGiftUButton:SetActive(data.noGift ~= 1 and not isLocked)
	end

	if shopType == CashShopConst.ShopItemType.DETAILS then
		if view.productInformationUComponent then
			view.productInformationUComponent:SetActive(true)
		end

		if view.propInfoUContainer then
			view.propInfoUContainer:SetActive(false)
		end

		if self.productInformation then
			self.productInformation:setInfo(data)
		end
	else
		if view.productInformationUComponent then
			view.productInformationUComponent:SetActive(false)
		end

		if view.propInfoUContainer then
			view.propInfoUContainer:SetActive(true)
		end

		if self.buyComponent then
			self.buyComponent:onShowBuyShopItemDetail(data)
		end

		self:_commodityClick(data)
	end
end

function BpExchangeCtrl:_refreshCurrencyList()
	local tabCfg = self._groupId and ShopmallTabGroupData[self._groupId]
	local currencyIds = tabCfg and tabCfg.currency or {}

	LuaUIUtils.setTopCurrencyItemList(self.view.listCurrencyUList, nil, currencyIds)
end

function BpExchangeCtrl:onBuyItemResult(result)
	if not result.success then
		pg.global.ui.tips:showTextTip(pg.getGameString("CASH_SHOP_BUY_FAIL"))

		return
	end

	self:_refreshCurrencyList()
	self:_refreshList()
end

function BpExchangeCtrl:refreshCommodChangeInfo()
	if self._currentData then
		self:refreshCommodInfo(self._currentData)
	end
end

function BpExchangeCtrl:_commodityClick(data)
	local view = self.view
	local itemType = data and data.itemType
	local ItemType = CashShopConst.CommodityItemType

	if view.btnAvatarDisplayUButton then
		local showBtn = itemType and (itemType == ItemType.AVATAR_FRAME or itemType == ItemType.AVATAR)

		view.btnAvatarDisplayUButton:SetActive(showBtn and true or false)

		if showBtn then
			view.btnAvatarDisplayUButton:TryChangePage("filter", self._avatarDisplayOn and 1 or 0)
		else
			self._avatarDisplayOn = false

			view.btnAvatarDisplayUButton:TryChangePage("filter", 0)
		end
	end

	if not itemType then
		self:_refreshNormalItem(data)
	elseif itemType == ItemType.AVATAR_FRAME then
		self:_refreshPlayerFrame(data)
	elseif itemType == ItemType.AVATAR then
		self:_refreshPlayerHead(data)
	elseif itemType == ItemType.CHAT_BUBBLE then
		self:_refreshPlayerChat(data)
	elseif itemType == ItemType.PANEL then
		self:_refreshPlayerPanel(data)
	end
end

function BpExchangeCtrl:_refreshPlayerHead(data)
	local view = self.view

	if view.playerHeadUWidget then
		view.playerHeadUWidget:SetActive(true)
	end

	if view.panelPlayerUWidget then
		view.panelPlayerUWidget:SetActive(false)
	end

	if view.chatBubbleUWidget then
		view.chatBubbleUWidget:SetActive(false)
	end

	if view.itemIconUImage then
		view.itemIconUImage.gameObject:SetActiveEx(false)
	end

	if view.avatarUImage then
		view.avatarUImage.url = LuaUIUtils.getIconByItemId(data.itemId)
	end

	if view.avatarFrameUImage then
		if self._avatarDisplayOn then
			view.avatarFrameUImage.gameObject:SetActiveEx(true)

			local cfg = pg.me and PlayerHeadFrameData[pg.me.headFrame]

			view.avatarFrameUImage.url = cfg and cfg.res or ""
		else
			view.avatarFrameUImage.gameObject:SetActiveEx(false)
		end
	end
end

function BpExchangeCtrl:_refreshPlayerFrame(data)
	local view = self.view

	if view.playerHeadUWidget then
		view.playerHeadUWidget:SetActive(true)
	end

	if view.panelPlayerUWidget then
		view.panelPlayerUWidget:SetActive(false)
	end

	if view.chatBubbleUWidget then
		view.chatBubbleUWidget:SetActive(false)
	end

	if view.itemIconUImage then
		view.itemIconUImage.gameObject:SetActiveEx(false)
	end

	if view.avatarFrameUImage then
		view.avatarFrameUImage.gameObject:SetActiveEx(true)

		view.avatarFrameUImage.url = LuaUIUtils.getIconByItemId(data.itemId)
	end

	if view.avatarUImage then
		if self._avatarDisplayOn then
			local cfg = pg.me and PlayerHeadIconData[pg.me.headIcon]

			view.avatarUImage.url = cfg and cfg.res or ""
		else
			view.avatarUImage.url = ""
		end
	end
end

function BpExchangeCtrl:_refreshPlayerPanel(data)
	local view = self.view

	if view.playerHeadUWidget then
		view.playerHeadUWidget:SetActive(false)
	end

	if view.avatarFrameUImage then
		view.avatarFrameUImage.gameObject:SetActiveEx(false)
	end

	if view.panelPlayerUWidget then
		view.panelPlayerUWidget:SetActive(true)
	end

	if view.chatBubbleUWidget then
		view.chatBubbleUWidget:SetActive(false)
	end

	if view.itemIconUImage then
		view.itemIconUImage.gameObject:SetActiveEx(false)
	end

	if not pg.me then
		return
	end

	local cardBgCfg = CardBackgroundData[data.itemId]

	if view.playerBgUImage then
		view.playerBgUImage.url = cardBgCfg and cardBgCfg.res or AddressDataConst.DEFAULT_CARD_BACKGROUND
	end

	if view.uIDUBaseText then
		ClientTextUtils.setText(view.uIDUBaseText, pg.me.uid or pg.me.userId or "")
	end

	if view.classInfoUBaseText then
		ClientTextUtils.setText(view.classInfoUBaseText, pg.getFormatText(pg.getGameString("PLAYER_SESSION_CLASS_INFO"), Utils.getClass(pg.me.uid)))
	end

	local headIconCfg = PlayerHeadIconData[pg.me.headIcon]

	if view.avatarUImage2 then
		view.avatarUImage2.url = headIconCfg and headIconCfg.res or ""
	end

	local headFrameCfg = PlayerHeadFrameData[pg.me.headFrame]

	if view.avatarFrameUImage2 then
		view.avatarFrameUImage2.url = headFrameCfg and headFrameCfg.res or ""
	end

	if view.txtPlayerLv then
		ClientTextUtils.setText(view.txtPlayerLv, pg.me.level or 0)
	end

	if view.playerNameUBaseText then
		ClientTextUtils.setText(view.playerNameUBaseText, pg.me.nickname or "")
	end

	local sig = pg.me.showSignature or ""

	if view.playerSignUBaseText then
		ClientTextUtils.setText(view.playerSignUBaseText, sig == "" and pg.getGameString("NO_PLAYER_SIGNATURE") or sig)
	end

	if view.rootUComponent then
		local gender = pg.me.gender or 1
		local page = gender == 1 and 0 or gender == 2 and 1 or 2

		view.rootUComponent:TryChangePage("Gender", page)
	end
end

function BpExchangeCtrl:_refreshPlayerChat(data)
	local view = self.view

	if view.playerHeadUWidget then
		view.playerHeadUWidget:SetActive(false)
	end

	if view.avatarFrameUImage then
		view.avatarFrameUImage.gameObject:SetActiveEx(false)
	end

	if view.panelPlayerUWidget then
		view.panelPlayerUWidget:SetActive(false)
	end

	if view.chatBubbleUWidget then
		view.chatBubbleUWidget:SetActive(true)
	end

	if view.itemIconUImage then
		view.itemIconUImage.gameObject:SetActiveEx(false)
	end

	if view.chatBgUImage then
		view.chatBgUImage.url = LuaUIUtils.getIconByItemId(data.itemId)
	end
end

function BpExchangeCtrl:_refreshNormalItem(data)
	local view = self.view

	if view.playerHeadUWidget then
		view.playerHeadUWidget:SetActive(false)
	end

	if view.avatarFrameUImage then
		view.avatarFrameUImage.gameObject:SetActiveEx(false)
	end

	if view.panelPlayerUWidget then
		view.panelPlayerUWidget:SetActive(false)
	end

	if view.chatBubbleUWidget then
		view.chatBubbleUWidget:SetActive(false)
	end

	if view.itemIconUImage then
		view.itemIconUImage.gameObject:SetActiveEx(true)

		view.itemIconUImage.url = LuaUIUtils.getIconByItemId(data.itemId)
	end
end

function BpExchangeCtrl:showFriendList(commodityId, productInfo)
	if not self.friendComponent then
		return
	end

	self._friendListRequestToken = (self._friendListRequestToken or 0) + 1

	local requestToken = self._friendListRequestToken

	self._giftCommodityId = commodityId

	local friendList = pg.game.chat:getFriendList() or {}
	local friendIds = {}

	for _, friend in ipairs(friendList) do
		friendIds[#friendIds + 1] = friend.playerId
	end

	self.model:requestFriendShopStatus(friendIds, commodityId, function(hasGiftMap)
		if self._destroyed or requestToken ~= self._friendListRequestToken or not self:checkUIOpen() or self:checkUIClosing() or not self.friendComponent or self._giftCommodityId ~= commodityId or not self._currentData or self._currentData.commodityId ~= commodityId then
			return
		end

		self.friendComponent.gameObject:SetActiveEx(true)
		self.friendComponent:refreshFriendList(self.friendComponent.OpenType.CashShop, {
			giftCommodityId = commodityId,
			productInfo = productInfo,
			hasGiftMap = hasGiftMap
		})
	end)
end

function BpExchangeCtrl:onHide()
	self._giftCommodityId = nil
	self._friendListRequestToken = (self._friendListRequestToken or 0) + 1

	if self.friendComponent and self.friendComponent.gameObject then
		self.friendComponent.gameObject:SetActiveEx(false)
	end
end

return BpExchangeCtrl
