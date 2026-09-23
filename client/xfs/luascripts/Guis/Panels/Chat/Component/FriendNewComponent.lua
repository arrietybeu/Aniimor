-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Chat\\Component\\FriendNewComponent.lua

local UIComponent = require("Guis.Helper.UIComponent")
local Class = require("Core.Framework.Class")
local FriendNewComponent = Class.LightClass("FriendNewComponent", UIComponent)
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local PlayerHeadIconData = require("Data.player_head_icon_data")
local FriendshipLevelData = require("Data.friendship_level_data")
local AvatarPresetData = require("Data.avatar_preset_data")
local SysConfigData = require("Data.sys_config_data")
local AddressDataConst = require("Const.AddressDataConst")
local Const = require("Common.Const.Const")
local NoticeDef = require("Common.NoticeDef")
local HotkeyConst = require("Const.HotkeyConst")
local UIConst = require("Const.UIConst")
local ClientCashShopUtils = require("Utils.ClientCashShopUtils")

FriendNewComponent.OpenType = {
	CashShop = 2,
	TeamInvite = 1,
	CreateChat = 0,
	FriendCard = 9
}
FriendNewComponent.CashShopSendType = {
	FriendShipLevelLock = 1,
	AbleSend = 0,
	HasGift = 2
}
FriendNewComponent.TabType = {
	Group = 1,
	Friends = 0
}

function FriendNewComponent:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.searchUTMPInputField = objectReference:GetRefValue("searchUTMPInputField")
	self.listUList = objectReference:GetRefValue("listUList")
	self.bgCloseUButton = objectReference:GetRefValue("bgCloseUButton")
	self.btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	self.btnConfirmUButton = objectReference:GetRefValue("btnConfirmUButton")
	self.uIPbChatFriendlPopupUComponent = objectReference:GetRefValue("uIPbChatFriendlPopupUComponent")
	self.listTab3thUList = objectReference:GetRefValue("listTab3thUList")
	self.tabUWidget = objectReference:GetRefValue("tabUWidget")
	self.groupChatListUList = objectReference:GetRefValue("groupChatListUList")
	self.textUSDFText = objectReference:GetRefValue("textUSDFText")
	self.uIPbChatFriendlPopupUComponent = objectReference:GetRefValue("uIPbChatFriendlPopupUComponent")
	self.btnSearchUButton = objectReference:GetRefValue("btnSearchUButton")
	self.emptyTipUSDFText = objectReference:GetRefValue("emptyTipUSDFText")
	self.createTipUSDFText = objectReference:GetRefValue("createTipUSDFText")
	self.btnAddUButton = objectReference:GetRefValue("btnAddUButton")
	self.inputHolderUSDFText = objectReference:GetRefValue("inputHolderUSDFText")
	self.btnDeleteUButton = objectReference:GetRefValue("btnDeleteUButton")
	self.keyHotKeyContent = objectReference:GetRefValue("keyHotKeyContent")
end

function FriendNewComponent:initView()
	ClientTextUtils.setText(self.inputHolderUSDFText, pg.getGameString("PLEASE_INPUT_PLAYER"))

	function self.bgCloseUButton.luaClick()
		if self.view.panelUComponent then
			self.view.panelUComponent:TryChangePage("ShowPopup", 0)
		else
			self.gameObject:SetActiveEx(false)
		end
	end

	function self.btnCloseUButton.luaClick()
		if self.view.panelUComponent then
			self.view.panelUComponent:TryChangePage("ShowPopup", 0)
		else
			self.gameObject:SetActiveEx(false)
		end
	end

	local closeCommonBind = KeyBindingPro.GetOrAddKeyBindingByName(self.btnCloseUButton.gameObject, "closeCommonBind")

	closeCommonBind.isVirtual = true
	closeCommonBind.priority = 1
	closeCommonBind.actionPath = "Common/ClosePanelCommon"

	function closeCommonBind.luaTrigger(inputInfo)
		self.btnCloseUButton.luaClick()
	end

	function self.listUList.luaRenderItem(button, index, data)
		self:renderFriendItem(button, index, data)

		function button.luaClick()
			if self.openType == self.OpenType.CreateChat then
				pg.global.ui.chat:createNewChat(nil, data.playerId)
			elseif self.openType == self.OpenType.TeamInvite then
				pg.game.chat:teamHandle(data.playerId)
			elseif self.openType == self.OpenType.FriendCard then
				self.ctrl.chatComponent:sendFriendCard(data.playerId)
				self.btnCloseUButton.luaClick()
			end
		end
	end

	function self.groupChatListUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local iconUImage = objectReference:GetRefValue("iconUImage")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
		local txtNumUSDFText = objectReference:GetRefValue("txtNumUSDFText")
		local textInformationUSDFText = objectReference:GetRefValue("textInformationUSDFText")

		iconUImage.url = AddressDataConst.CHAT_GROUP_HEAD_ICONS[data.headIconKey]

		ClientTextUtils.setText(txtNameUSDFText, pg.game.chat:getChatGroupDisplayName(data))

		local memberCountText = pg.getFormatText(pg.getGameString("COUNT_OF_TOTAL"), #data.uids, Const.CHAT.CHAT_GROUP_MAX_MEMBER_COUNT)

		ClientTextUtils.setText(txtNumUSDFText, memberCountText)

		local messageInfo = pg.game.chat:getGroupChannelLastMessageOrSystemNotice(data.groupId)
		local lastMessageText = self:getGroupChatLastMessageText(messageInfo)

		lastMessageText = ClientTextUtils.removeRichText(lastMessageText)

		ClientTextUtils.setText(textInformationUSDFText, lastMessageText)

		function button.luaClick()
			pg.global.ui.chat:createNewGroupChat(data.groupId)
		end
	end

	function self.listTab3thUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local txtNameUBaseText = objectReference:GetRefValue("txtNameUBaseText")

		ClientTextUtils.setText(txtNameUBaseText, data.label)
	end

	function self.listTab3thUList.luaSelectedChanged(selector, isSelected)
		if isSelected == false then
			return
		end

		local tabIndex = selector.selectedIndex

		self:refreshPageStateByTab(tabIndex)
	end

	function self.searchUTMPInputField.luaEndEdit(text)
		self:doSearch(text)
	end

	function self.searchUTMPInputField.luaValueChanged(text)
		self.btnDeleteUButton:SetActive(not string.isNilOrEmpty(text))
		self:doSearch(text)
	end

	LuaUIUtils.bindInputFieldGamepad(self.searchUTMPInputField, self.keyHotKeyContent, self.btnDeleteUButton)

	function self.btnAddUButton.luaClick()
		self:onAddButtonClick()
	end
end

function FriendNewComponent:getGroupChatLastMessageText(messageInfo)
	if messageInfo == nil then
		return ""
	end

	local messageSubType = messageInfo.subType
	local subMessageType = pg.game.chat.subMessageType
	local isTextMessage = messageSubType == subMessageType.Text or messageSubType == subMessageType.Audio or messageSubType == subMessageType.FriendCard or messageSubType == subMessageType.Picture

	if isTextMessage then
		if messageInfo.extraInfo then
			local extraText = pg.game.chat:getTextContentFromExtraInfo(messageInfo.extraInfo)

			return extraText or messageInfo.textContent or ""
		end

		return messageInfo.textContent or ""
	elseif messageSubType == subMessageType.Emoji then
		return pg.getGameString("CHAT_BUBBLE_EMOJI")
	elseif messageSubType == subMessageType.DungeonInvite then
		return pg.getGameString("TEAM_INVITE")
	elseif messageSubType == subMessageType.PhotographyStudioInvite then
		return pg.getGameString("PHOTO_STUDIO_CHAT_INVITE_MESSAGE")
	end

	return messageInfo.textContent or ""
end

function FriendNewComponent:refreshPageStateByTab(tabIndex)
	self.curTabType = tabIndex

	local isHasItem = false
	local emptyStrCode, createCode

	if tabIndex == FriendNewComponent.TabType.Friends then
		isHasItem = self.hasFriends
		emptyStrCode = "FRIEND_LIST_EMPTY"
		createCode = "CHAT_ADD_FRIENDS"
	elseif tabIndex == FriendNewComponent.TabType.Group then
		isHasItem = self.hasChatGroup
		emptyStrCode = "CHAT_EMPTY_GROUP"
		createCode = "CHATGROUP_CREAT"
	end

	self.uWidget:TryChangePage("Empty", isHasItem and 0 or 1)

	if isHasItem then
		self.uWidget:TryGetCurrentPage("ListCut", tabIndex)
	else
		ClientTextUtils.setText(self.emptyTipUSDFText, pg.getGameString(emptyStrCode))
		ClientTextUtils.setText(self.createTipUSDFText, pg.getGameString(createCode))
	end
end

function FriendNewComponent:onAddButtonClick()
	if self.curTabType == FriendNewComponent.TabType.Friends then
		self.btnCloseUButton.luaClick()
		self.view.btnFriendUButton:OnClickSimulate()

		local friendTabComponent = self.ctrl.friendTabComponent

		if friendTabComponent and friendTabComponent.addFriendUButton.luaClick then
			friendTabComponent.addFriendUButton.luaClick()
		end
	elseif self.curTabType == FriendNewComponent.TabType.Group then
		if #pg.game.chat:getFriendChatGroupList() >= Const.CHAT.CHAT_CHAT_GROUP_MAX_NUMBER then
			pg.global.showBubbleMessageRaw(pg.getGameString("GROUP_NUMBER_OVER_LIMIT"))

			return
		end

		pg.global.ui:open(UIConst.UI_ID_FRIEND_SETUP, {
			setupType = pg.global.ui.friendSetup.model.FriendSetupType.CreateChatGroup
		})
	end
end

function FriendNewComponent:renderFriendItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local playerInfo = pg.game.chat:getPlayerInfo(data.playerId)
	local presetData = self:renderFriendBaseInfo(objectReference, button, index, data, playerInfo)
	local friendshipLevel, hasGift = self:renderFriendshipInfo(objectReference, data.playerId)

	self:renderFriendCashShopInfo(objectReference, data.playerId, presetData, friendshipLevel, hasGift)
end

function FriendNewComponent:renderFriendBaseInfo(objectReference, button, index, data, playerInfo)
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local textLvUSDFText = objectReference:GetRefValue("textLvUSDFText")
	local imgAvatarUImage = objectReference:GetRefValue("imgAvatarUImage")
	local textStateUSDFText = objectReference:GetRefValue("textStateUSDFText")
	local avatarUButton = objectReference:GetRefValue("avatarUButton")
	local txtNameChangeUSDFText = objectReference:GetRefValue("txtNameChangeUSDFText")
	local txtNameChangeCoverUSDFText = objectReference:GetRefValue("txtNameChangeCoverUSDFText")
	local intimacyUButton = objectReference:GetRefValue("intimacyUButton")

	ClientTextUtils.setText(textLvUSDFText, playerInfo.level)

	local displayName = LuaUIUtils.getPlayerDisplayName(data.playerId, playerInfo.playerName)
	local _h = FriendNewComponent._platformHooks

	if _h and _h.renderFriendItemName then
		local hookDisplayName = _h.renderFriendItemName(self, button, index, data, playerInfo, displayName)

		displayName = hookDisplayName or displayName
	end

	ClientTextUtils.setText(txtNameUSDFText, displayName)
	ClientTextUtils.setText(txtNameChangeUSDFText, displayName)
	ClientTextUtils.setText(txtNameChangeCoverUSDFText, displayName)
	button:TryChangePage("OnlineState", playerInfo.online and 0 or 1)
	button:TryChangePage("isChange", pg.game.chat.specialFriendUId == data.playerId and 1 or 0)
	button:TryChangePage("OpenType", self.openType)

	local presetData = pg.game.avatar:getAvatarPresetData(playerInfo.avatarPresetKey) or {}
	local templateId = presetData.templateId or 0
	local genderPage = 2

	if templateId == 3 then
		genderPage = 1
	elseif templateId == 4 then
		genderPage = 0
	end

	button:TryChangePage("Gender", genderPage)

	local lastLogoutTime = LuaUIUtils.getLastTimeStr(playerInfo.lastLogoutTime)
	local stateText = playerInfo.online and pg.getGameString("ONLINE") or lastLogoutTime

	ClientTextUtils.setText(textStateUSDFText, stateText)
	LuaUIUtils.renderPlayerAvatarButton(avatarUButton, {
		hideLevel = true,
		showOnlineState = true,
		playerId = data.playerId,
		playerInfo = playerInfo,
		avatarType = LuaUIUtils.PLAYER_AVATAR_TYPE.CHAT,
		playSparkAnimation = self.ctrl.sparkAnimationPlayerUid == data.playerId
	})
	self:bindFriendIntimacyEvents(button, intimacyUButton, data.playerId, playerInfo)
	avatarUButton:TryChangePage("State", playerInfo.online and 1 or 2)

	return presetData
end

function FriendNewComponent:bindFriendIntimacyEvents(button, intimacyUButton, playerId, playerInfo)
	local function openFriendIntimacy()
		pg.global.ui:open(UIConst.UI_ID_FRIEND_INTIMACY, {
			notBackToPlayerCard = true,
			playerInfo = playerInfo,
			friendshipValue = pg.game.chat:getFriendIntimacy(playerId)
		})

		return false
	end

	intimacyUButton.luaClick = openFriendIntimacy

	button:RemoveLuaGamepadHotkey()
	button:SetGamepadLongPress(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonWest, nil, 0, openFriendIntimacy)
	button:SetHotkeyActiveOnlyInCurrentItem(true)
	button:SetHotkeyConsoleBar("CONSOLE_INTIMACY", 0)
end

function FriendNewComponent:renderFriendshipInfo(objectReference, playerId)
	local imageIconUImage = objectReference:GetRefValue("imageIconUImage")
	local friendshipLevel = pg.game.chat:getFriendship(playerId)
	local friendshipData = friendshipLevel and FriendshipLevelData[friendshipLevel]

	if friendshipData then
		imageIconUImage.url = friendshipData.levelIcon
	end

	imageIconUImage.gameObject:SetActiveEx(friendshipData)

	local hasGift = self.hasGiftMap and self.hasGiftMap[tostring(playerId)] == true

	return friendshipLevel, hasGift
end

function FriendNewComponent:renderFriendCashShopInfo(objectReference, playerId, presetData, friendshipLevel, hasGift)
	if self.openType ~= self.OpenType.CashShop then
		return
	end

	local cashShopUComponent = objectReference:GetRefValue("cashShopUComponent")
	local txtCashShopLimit = objectReference:GetRefValue("txtCashShopLimit")
	local txtCashShopHas = objectReference:GetRefValue("txtCashShopHas")
	local btnGiftUButton = objectReference:GetRefValue("btnGiftUButton")
	local needLevel = tonumber(SysConfigData.GIVE_GIFT_NEED_FRIENDSHIPLEVEL) or 3
	local isLevelSatisfied = needLevel <= friendshipLevel
	local commodityInfo = ClientCashShopUtils.getCommodityData(self.commodityId)
	local targetGender = presetData.body
	local isGenderMatch = not commodityInfo or ClientCashShopUtils.isItemMatchGender(commodityInfo.itemId, targetGender)

	btnGiftUButton.gameObject:SetActiveEx(isLevelSatisfied and not hasGift)

	local function hideFriendList()
		self.gameObject:SetActiveEx(false)
	end

	function btnGiftUButton.luaClick()
		if not isLevelSatisfied then
			pg.global.showBubbleMessageById(NoticeDef.SHOPMALL_COMMODITY_GIVE_INTIMACY)
		elseif not isGenderMatch then
			pg.global.showBubbleMessageById(NoticeDef.CASH_GIFT_GENDER_ERROR)
		else
			pg.global.ui:open(UIConst.UI_ID_CASH_GIFT, {
				commodityId = self.commodityId,
				playerId = playerId,
				receiverGender = targetGender,
				productInfo = self.productInfo,
				categoryType = self.categoryType
			}, hideFriendList)
		end
	end

	local status = FriendNewComponent.CashShopSendType.FriendShipLevelLock

	if hasGift then
		status = FriendNewComponent.CashShopSendType.HasGift
	elseif isLevelSatisfied then
		status = FriendNewComponent.CashShopSendType.AbleSend
	end

	cashShopUComponent:TryChangePage("Status", status)

	local needFriendshipIcon = FriendshipLevelData[needLevel].levelIcon

	needFriendshipIcon = string.sub(needFriendshipIcon, 2, -5)
	needFriendshipIcon = string.format("<sprite name=\"%s\">", needFriendshipIcon)

	local limitText = pg.getFormatText(pg.getGameString("SHOP_GIFT_FRIEND"), needFriendshipIcon)

	ClientTextUtils.setText(txtCashShopLimit, limitText)
	ClientTextUtils.setText(txtCashShopHas, pg.getGameString("SHOP_GIFT_FRIEND_HAS"))
end

function FriendNewComponent:setHasGiftMap(hasGiftMap)
	self.hasGiftMap = hasGiftMap

	if self.listUList then
		self.listUList:RefreshList()
	end
end

function FriendNewComponent:refreshFriendList(openType, params)
	if self.view.panelUComponent then
		self.view.panelUComponent:TryChangePage("ShowPopup", 5)
	end

	self.openType = openType
	self.commodityId = params and params.giftCommodityId
	self.productInfo = params and params.productInfo
	self.categoryType = params and params.categoryType
	self.hasGiftMap = params and params.hasGiftMap
	self.friendList = params and params.friendList

	if self.uIPbChatFriendlPopupUComponent then
		local isSimplePopup = self.openType == self.OpenType.CashShop or self.openType == self.OpenType.TeamInvite or self.openType == self.OpenType.FriendCard

		if isSimplePopup then
			self.uIPbChatFriendlPopupUComponent:TryChangePage("State", 4)
		else
			self.uIPbChatFriendlPopupUComponent:TryChangePage("State", 0)
		end
	end

	local friendList = self.friendList or pg.game.chat:getFriendList() or {}

	self.hasFriends = next(friendList) ~= nil

	self.listUList:SetList(friendList)

	if self.openType == self.OpenType.CreateChat then
		self:refreshCreateChatFriendList()
	elseif self.openType == self.OpenType.CashShop then
		self:refreshCashShopFriendList()
	elseif self.openType == self.OpenType.FriendCard then
		self:refreshFriendCardList()
	else
		self:refreshTeamInviteFriendList()
	end
end

function FriendNewComponent:refreshCreateChatFriendList()
	ClientTextUtils.setText(self.textUSDFText, pg.getGameString("CHAT_ADD_CONVERSATION_TITLE"))
	self.tabUWidget.gameObject:SetActiveEx(true)

	self.curTabType = FriendNewComponent.TabType.Friends

	local tabs = {
		{
			tabIndex = 0,
			tIndex = 0,
			label = pg.getGameString("FRIEND")
		},
		{
			tabIndex = 1,
			tIndex = 2,
			label = pg.getGameString("CHAT_GROUP")
		}
	}

	self.listTab3thUList:SetList(tabs)
	self.listTab3thUList:SelectItem(0)

	local groups = pg.game.chat:getFriendChatGroupList()
	local groupExist = {}

	for _, group in ipairs(groups) do
		if not group.markForRemove then
			groupExist[#groupExist + 1] = group
		end
	end

	self.hasChatGroup = next(groupExist) ~= nil

	self.groupChatListUList:SetList(groupExist)
end

function FriendNewComponent:refreshCashShopFriendList()
	ClientTextUtils.setText(self.textUSDFText, pg.getGameString("SEND_TEXT"))
	ClientTextUtils.setText(self.emptyTipUSDFText, pg.getGameString("FRIEND_LIST_EMPTY"))
	self.tabUWidget.gameObject:SetActiveEx(false)
	self.uWidget:TryChangePage("Empty", self.hasFriends and 0 or 1)
end

function FriendNewComponent:refreshFriendCardList()
	ClientTextUtils.setText(self.textUSDFText, pg.getGameString("SHARED_FRIEND_CARD"))
	self.tabUWidget.gameObject:SetActiveEx(false)
end

function FriendNewComponent:refreshTeamInviteFriendList()
	ClientTextUtils.setText(self.textUSDFText, pg.getGameString("CHAT_TEAM_INVITE_TITLE"))
	self.tabUWidget.gameObject:SetActiveEx(false)
end

function FriendNewComponent:refreshFriendListState()
	self.listUList:RefreshList()
end

function FriendNewComponent:doSearch(text)
	local friendList = self.friendList or pg.game.chat:getFriendList() or {}

	if string.isNilOrEmpty(text) then
		self.listUList:SetList(friendList)

		return
	end

	local ret = {}

	for _, friend in pairs(friendList) do
		local playerInfo = pg.game.chat:getPlayerInfo(friend.playerId)
		local customInfo = pg.game.chat:getFriendCustomInfo(friend.playerId)

		if customInfo and not string.isNilOrEmpty(customInfo.remark) and string.find(customInfo.remark, text, 1, true) or string.find(playerInfo.playerName, text) or string.find(friend.playerId, text) then
			table.insert(ret, {
				playerId = friend.playerId
			})
		end
	end

	self.listUList:SetList(ret)
end

return FriendNewComponent
