-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\ShopGiftReceive\\ShopGiftReceiveCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("ShopGiftReceiveCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ShopGiftReceiveCtrl = Class.LightClass("ShopGiftReceiveCtrl", UICtrl)
local UIConst = require("Const.UIConst")
local ClientConst = require("Const.ClientConst")
local Const = require("Common.Const.Const")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")

ShopGiftReceiveCtrl.messages = {}

function ShopGiftReceiveCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	function self.view.btnAcceptUButton.luaClick()
		self:onAcceptClick()
	end

	function self.view.listItemUList.luaRenderItem(button, index, data)
		LuaUIUtils.renderRewardItem(button, data, tostring(data.num or 1))
	end

	function self.view.itemUButton.luaClick()
		local itemId = self.convertedItemId or self.mailData and self.mailData.id

		if itemId then
			pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
				id = itemId,
				num = self.mailData and self.mailData.num or 1,
				targetRect = self.view.itemUButton
			})
		end
	end

	function self.view.btnHeadUButton.luaClick()
		self:onHeadClick()
	end
end

function ShopGiftReceiveCtrl:addListener()
	return
end

function ShopGiftReceiveCtrl:onDestroy()
	pg.global.ui.tips:showGiftTips()
	UICtrl.onDestroy(self)
end

function ShopGiftReceiveCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.mailData = info

	pg.global.ui.tips:hideGiftTips()
	self.view.videoPlayerUVideoPlayerX:SetVideoWithCallback(self.view.videoPlayerUVideoPlayerX.resID, function()
		self.view.giftCardUComponent:InvokeCallback(CS.XGUI.EInvokeTime.Show)
		pg.game.audio:triggerEvent("SFX_SHOP_GET_GIFT_OPEN")
		self:refreshView()
	end)
end

function ShopGiftReceiveCtrl:refreshView()
	local info = self.mailData

	if not info then
		return
	end

	local giverName = ""
	local giverPlayerInfo

	if info.giverUid then
		local playerInfo = pg.game.chat:getPlayerInfo(tostring(info.giverUid))

		if playerInfo then
			giverName = LuaUIUtils.getPlayerDisplayName(tostring(info.giverUid), playerInfo.playerName or "", true) or ""
			giverPlayerInfo = playerInfo

			self:renderPlayerHead(playerInfo)
		end
	end

	local _h = ShopGiftReceiveCtrl._platformHooks

	if _h and _h.resolveGiverDisplayName then
		giverName = _h.resolveGiverDisplayName(self, tostring(info.giverUid), giverName)
	end

	ClientTextUtils.setText(self.view.textPlayerNameUBaseText, giverName)

	local blessText = info.blessTxt or ""

	if _h and _h.resolveGiftBlessText then
		blessText = _h.resolveGiftBlessText(self, tostring(info.giverUid), giverPlayerInfo, blessText)
	end

	ClientTextUtils.setText(self.view.textMessageUBaseText, blessText)

	local itemId = info.id

	if not info.rechargeId then
		itemId = self.model:getConvertedItemId(itemId)
	end

	self.convertedItemId = itemId

	ClientTextUtils.setText(self.view.textGiftNameUBaseText, self.model:getItemName(itemId))

	local avatarPic = self.model:getAvatarPic(info.commodityId)

	if avatarPic ~= "" then
		self.view.characterUImage.url = avatarPic
	end

	local kind = self.model:getGiftKind(itemId, info.rechargeId)
	local quality = self.model:getGiftQuality(itemId)

	self.view.giftCardUComponent:TryChangePage("Kind", kind)
	self.view.giftCardUComponent:TryChangePage("Quality", quality)
	ClientTextUtils.setText(self.view.textSubTitleUBaseText, self.model:getItemSubTitle(itemId))

	local suitItems = self.model:getSuitAppearanceItems(itemId)
	local isMonthlyOrBP = info.rechargeId and (self.model:isBP(info.rechargeId) or self.model:isMonthly(info.rechargeId))

	if suitItems then
		self.view.listItemUList:SetList(suitItems)
	elseif isMonthlyOrBP then
		self.view.listItemUList:SetList(info.giftItems or {})
	else
		local itemIcon = self.model:getItemIcon(itemId)

		if itemIcon ~= "" then
			self.view.itemIconUImage.url = itemIcon
		end

		ClientTextUtils.setText(self.view.itemNumUBaseText, "x" .. (info.num or 1))
	end
end

function ShopGiftReceiveCtrl:renderPlayerHead(playerInfo)
	LuaUIUtils.renderPlayerAvatarImages(self.view.playerHeadObjectReference.transform, {
		avatarIconId = playerInfo.headIcon,
		avatarFrameIconId = playerInfo.headFrame
	})
end

function ShopGiftReceiveCtrl:onHeadClick()
	local giverUid = self.mailData and self.mailData.giverUid

	if not giverUid then
		return
	end

	LuaUIUtils.openInfoPlayerCard({
		playerId = tostring(giverUid),
		openType = ClientConst.PlayerInfoOpenType.Chat
	})
end

function ShopGiftReceiveCtrl:onAcceptClick()
	local info = self.mailData

	if info and info.mail then
		pg.me:setMailGiftReceived({
			info.mail.MailId
		})
	end

	self:thanksGiver(info)
	self:close()
end

function ShopGiftReceiveCtrl:thanksGiver(info)
	local giverUid = info and info.giverUid

	if not giverUid or tostring(giverUid) == tostring(pg.me.uid) then
		return
	end

	local sent = pg.game.chat:sendMessage(pg.getGameString("SHOP_GIFT_THANKS_MESSAGE"), pg.game.chat.subMessageType.Text, pg.game.chat.channelType.Player, tostring(giverUid), {
		[Const.CHAT_EXTRA_TYPE.ChatType] = Const.CHAT_MESSAGE_TYPE.System
	}, true)

	if sent then
		pg.global.showBubbleMessageRaw(pg.getGameString("SHOP_GIFT_THANKS_TIPS"))
	end
end

function ShopGiftReceiveCtrl:onShow()
	return
end

function ShopGiftReceiveCtrl:onVisibleChange(visible)
	if not visible then
		pg.global.ui:close(UIConst.UI_ID_INFO_PLAYER_CARD)
	end
end

return ShopGiftReceiveCtrl
