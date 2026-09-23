-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CashShop\\Component\\CashShopItemListComponent.lua

local Class = require("Core.Framework.Class")
local CashShopContainerComponent = require("Guis.Panels.CashShop.Component.CashShopContainerComponent")
local CashShopBuyComponent = require("Guis.Panels.CashShop.Component.CashShopBuyComponent")
local CashShopConst = require("Const.CashShopConst")
local AddressDataConst = require("Const.AddressDataConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ClientCashShopUtils = require("Utils.ClientCashShopUtils")
local Utils = require("Common.Utils.Utils")
local PlayerHeadIconData = require("Data.player_head_icon_data")
local PlayerHeadFrameData = require("Data.player_head_frame_data")
local CardBackgroundData = require("Data.card_background_data")
local CashShopItemListComponent = Class.LightClass("CashShopItemListComponent", CashShopContainerComponent)

function CashShopItemListComponent:findObjects()
	if not self:checkContentLoaded() then
		return
	end

	CashShopContainerComponent.findObjects(self)

	local objectReference = self.transform:GetChild(0):GetComponent("ObjectReference")

	self._subContainers = {
		[CashShopConst.ShopItemType.DETAILS] = {
			ref = objectReference:GetRefValue("nonResourceItemsUContainer")
		},
		[CashShopConst.ShopItemType.NO_DETAILS] = {
			ref = objectReference:GetRefValue("resourceItemsUContainer")
		}
	}
end

function CashShopItemListComponent:addListener()
	if not self:checkContentLoaded() then
		return
	end

	CashShopContainerComponent.addListener(self)
end

function CashShopItemListComponent:refreshPage()
	local shopType = self._currentGroupData and self._currentGroupData.shopType or CashShopConst.ShopItemType.DETAILS

	self:_switchSubContainer(shopType, function()
		local info = self._subContainers[shopType]

		if info and info.objectReference then
			if not info.buyComponent then
				local propInfoUContainer = info.objectReference:GetRefValue("propInfoUContainer")

				if propInfoUContainer then
					info.buyComponent = CashShopBuyComponent.new(self, propInfoUContainer, {
						itemInfoContainer = propInfoUContainer
					})
				end
			end

			self.buyComponent = info.buyComponent

			if not info.giftBound then
				info.giftBtn = info.objectReference:GetRefValue("btnGiftUButton")

				local shoppingBtn = info.objectReference:GetRefValue("btnShoppingCartUButton")

				if info.giftBtn and self.ctrl and self.ctrl.showFriendList then
					function info.giftBtn.luaClick()
						self.ctrl:showFriendList(self._curCommodityId)
					end
				end

				if shoppingBtn then
					shoppingBtn:SetActive(true)

					function shoppingBtn.luaClick()
						if self.ctrl and self.ctrl.addCashCartCommodity and self._curCommodityId then
							self.ctrl:addCashCartCommodity(self._curCommodityId)
						end
					end
				end

				info.shoppingBtn = shoppingBtn
				info.giftBound = true
			end

			self.giftBtn = info.giftBtn
			self.shoppingBtn = info.shoppingBtn
		end

		if shopType == CashShopConst.ShopItemType.NO_DETAILS and not self._noDetailsPreviewBound then
			self:_bindNoDetailsPreview(info.objectReference)
		end

		CashShopContainerComponent.refreshPage(self)
	end)
end

function CashShopItemListComponent:_bindNoDetailsPreview(objectReference)
	self.rootUComponent = objectReference:GetRefValue("rootUComponent")
	self.playerHeadUWidget = objectReference:GetRefValue("playerHeadUWidget")
	self.avatarBgUImage = objectReference:GetRefValue("avatarBgUImage")
	self.avatarUImage = objectReference:GetRefValue("avatarUImage")
	self.avatarFrameUImage = objectReference:GetRefValue("avatarFrameUImage")
	self.panelPlayerUWidget = objectReference:GetRefValue("panelPlayerUWidget")
	self.chatBubbleUWidget = objectReference:GetRefValue("chatBubbleUWidget")
	self.chatBgUImage = objectReference:GetRefValue("chatBgUImage")
	self.playerBgUImage = objectReference:GetRefValue("playerBgUImage")
	self.uIDUBaseText = objectReference:GetRefValue("uIDUBaseText")
	self.classInfoUBaseText = objectReference:GetRefValue("classInfoUBaseText")
	self.avatarBgUImage2 = objectReference:GetRefValue("avatarBgUImage2")
	self.avatarUImage2 = objectReference:GetRefValue("avatarUImage2")
	self.avatarFrameUImage2 = objectReference:GetRefValue("avatarFrameUImage2")
	self.txtPlayerLv = objectReference:GetRefValue("txtPlayerLv")
	self.playerNameUBaseText = objectReference:GetRefValue("playerNameUBaseText")
	self.playerSignUBaseText = objectReference:GetRefValue("playerSignUBaseText")
	self.imgGenderUImage = objectReference:GetRefValue("imgGenderUImage")
	self.itemIconUImage = objectReference:GetRefValue("itemIconUImage")
	self.btnAvatarDisplayUButton = objectReference:GetRefValue("btnAvatarDisplayUButton")

	if self.btnAvatarDisplayUButton then
		self.btnAvatarDisplayUButton:SetActive(false)

		self._avatarDisplayOn = false

		self.btnAvatarDisplayUButton:TryChangePage("filter", 0)

		function self.btnAvatarDisplayUButton.luaClick()
			self._avatarDisplayOn = not self._avatarDisplayOn

			self.btnAvatarDisplayUButton:TryChangePage("filter", self._avatarDisplayOn and 1 or 0)

			local data = self._currentData

			if data and data.itemType then
				local ItemType = CashShopConst.CommodityItemType

				if data.itemType == ItemType.AVATAR_FRAME then
					self:refreshPlayerFrame(data)
				elseif data.itemType == ItemType.AVATAR then
					self:refreshPlayerHead(data)
				end
			end
		end
	end

	self._noDetailsPreviewBound = true
end

function CashShopItemListComponent:refreshCommodInfo(data)
	CashShopContainerComponent.refreshCommodInfo(self, data)

	self._curCommodityId = data.commodityId

	local shopType = self._currentGroupData and self._currentGroupData.shopType

	if shopType == CashShopConst.ShopItemType.NO_DETAILS then
		self:commodityClick(data)
	end

	if self.giftBtn then
		local isLocked = ClientCashShopUtils.getCommodityState(data) == ClientCashShopUtils.COMMODITY_STATE.LOCKED

		self.giftBtn:SetActive(data.noGift ~= 1 and not isLocked)
	end

	if self.shoppingBtn then
		local commodityInfo = ClientCashShopUtils.getCommodityData(data.commodityId)
		local state = ClientCashShopUtils.getCommodityState(data)

		self.shoppingBtn:SetActive(commodityInfo and commodityInfo.noAdd ~= 1 and state == ClientCashShopUtils.COMMODITY_STATE.NORMAL)
	end

	if self.buyComponent and data.commodityId then
		self.buyComponent:onShowBuyShopItemDetail(data)
	end
end

function CashShopItemListComponent:commodityClick(data)
	local itemType = data and data.itemType
	local ItemType = CashShopConst.CommodityItemType

	if self.btnAvatarDisplayUButton then
		local showBtn = itemType and (itemType == ItemType.AVATAR_FRAME or itemType == ItemType.AVATAR)

		self.btnAvatarDisplayUButton:SetActive(showBtn and true or false)

		if showBtn then
			self.btnAvatarDisplayUButton:TryChangePage("filter", self._avatarDisplayOn and 1 or 0)
		else
			self._avatarDisplayOn = false

			self.btnAvatarDisplayUButton:TryChangePage("filter", 0)
		end
	end

	if not itemType then
		self:refreshNormalItem(data)

		return
	end

	if itemType == ItemType.AVATAR_FRAME then
		self:refreshPlayerFrame(data)
	elseif itemType == ItemType.AVATAR then
		self:refreshPlayerHead(data)
	elseif itemType == ItemType.CHAT_BUBBLE then
		self:refreshPlayerChat(data)
	elseif itemType == ItemType.PANEL then
		self:refreshPlayerPanel(data)
	end
end

function CashShopItemListComponent:refreshPlayerHead(data)
	self.playerHeadUWidget:SetActive(true)
	self.panelPlayerUWidget:SetActive(false)
	self.chatBubbleUWidget:SetActive(false)
	self.itemIconUImage.gameObject:SetActiveEx(false)

	self.avatarUImage.url = LuaUIUtils.getIconByItemId(data.itemId)

	if self._avatarDisplayOn then
		self.avatarFrameUImage.gameObject:SetActiveEx(true)

		local headFrameCfg = pg.me and PlayerHeadFrameData[pg.me.headFrame]

		self.avatarFrameUImage.url = headFrameCfg and headFrameCfg.res or ""
	else
		self.avatarFrameUImage.gameObject:SetActiveEx(false)
	end
end

function CashShopItemListComponent:refreshPlayerFrame(data)
	self.playerHeadUWidget:SetActive(true)
	self.avatarFrameUImage.gameObject:SetActiveEx(true)
	self.panelPlayerUWidget:SetActive(false)
	self.chatBubbleUWidget:SetActive(false)
	self.itemIconUImage.gameObject:SetActiveEx(false)

	self.avatarFrameUImage.url = LuaUIUtils.getIconByItemId(data.itemId)

	if self._avatarDisplayOn then
		local headIconCfg = pg.me and PlayerHeadIconData[pg.me.headIcon]

		self.avatarUImage.url = headIconCfg and headIconCfg.res or ""
	else
		self.avatarUImage.url = ""
	end
end

function CashShopItemListComponent:refreshPlayerPanel(data)
	self.playerHeadUWidget:SetActive(false)
	self.avatarFrameUImage.gameObject:SetActiveEx(false)
	self.panelPlayerUWidget:SetActive(true)
	self.chatBubbleUWidget:SetActive(false)
	self.itemIconUImage.gameObject:SetActiveEx(false)

	if not pg.me then
		return
	end

	local cardBgCfg = CardBackgroundData[data.itemId]

	self.playerBgUImage.url = cardBgCfg and cardBgCfg.res or AddressDataConst.DEFAULT_CARD_BACKGROUND

	ClientTextUtils.setText(self.uIDUBaseText, pg.me.uid or pg.me.userId or "")
	ClientTextUtils.setText(self.classInfoUBaseText, pg.getFormatText(pg.getGameString("PLAYER_SESSION_CLASS_INFO"), Utils.getClass(pg.me.uid)))

	local headIconCfg = PlayerHeadIconData[pg.me.headIcon]

	self.avatarUImage2.url = headIconCfg and headIconCfg.res or ""

	local headFrameCfg = PlayerHeadFrameData[pg.me.headFrame]

	self.avatarFrameUImage2.url = headFrameCfg and headFrameCfg.res or ""

	ClientTextUtils.setText(self.txtPlayerLv, pg.me.level or 0)
	ClientTextUtils.setText(self.playerNameUBaseText, pg.me.nickname or "")

	local signature = pg.me.showSignature or ""

	ClientTextUtils.setText(self.playerSignUBaseText, signature == "" and pg.getGameString("NO_PLAYER_SIGNATURE") or signature)

	local gender = pg.me.gender or 1

	if gender == 1 then
		self.rootUComponent:TryChangePage("Gender", 0)
	elseif gender == 2 then
		self.rootUComponent:TryChangePage("Gender", 1)
	else
		self.rootUComponent:TryChangePage("Gender", 2)
	end
end

function CashShopItemListComponent:refreshPlayerChat(data)
	self.playerHeadUWidget:SetActive(false)
	self.avatarFrameUImage.gameObject:SetActiveEx(false)
	self.panelPlayerUWidget:SetActive(false)
	self.chatBubbleUWidget:SetActive(true)
	self.itemIconUImage.gameObject:SetActiveEx(false)

	self.chatBgUImage.url = LuaUIUtils.getIconByItemId(data.itemId)
end

function CashShopItemListComponent:refreshNormalItem(data)
	self.playerHeadUWidget:SetActive(false)
	self.avatarFrameUImage.gameObject:SetActiveEx(false)
	self.panelPlayerUWidget:SetActive(false)
	self.chatBubbleUWidget:SetActive(false)
	self.itemIconUImage.gameObject:SetActiveEx(true)

	self.itemIconUImage.url = LuaUIUtils.getIconByItemId(data.itemId, LuaUIUtils.ITEM_ICON_TYPE.ICON_BIG)
end

return CashShopItemListComponent
