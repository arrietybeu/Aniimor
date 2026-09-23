-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomePlantsSend\\HomePlantsSendCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomePlantsSendCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PlayerHeadIconData = require("Data.player_head_icon_data")
local FriendshipLevelData = require("Data.friendship_level_data")
local AvatarPresetData = require("Data.avatar_preset_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local HomeSeasonUtils = require("Utils.HomeSeasonUtils")
local NoticeDef = require("Common.NoticeDef")
local UIConst = require("Const.UIConst")
local HomePlantsSendCtrl = Class.LightClass("HomePlantsSendCtrl", UICtrl)
local GENDER_MALE = 0
local GENDER_FEMALE = 1
local GENDER_UNKNOWN = 2

HomePlantsSendCtrl.messages = {}

function HomePlantsSendCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function HomePlantsSendCtrl:addListener()
	function self.view.bgCloseUButton.luaClick()
		self:dismiss()
	end

	function self.view.btnCloseUButton.luaClick()
		self:dismiss()
	end

	function self.view.btnConfirmUButton.luaClick()
		self:onConfirm()
	end

	function self.view.listUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
		local textLvUSDFText = objectReference:GetRefValue("textLvUSDFText")
		local imgAvatarUImage = objectReference:GetRefValue("imgAvatarUImage")
		local textStateUSDFText = objectReference:GetRefValue("textStateUSDFText")
		local avatarUButton = objectReference:GetRefValue("avatarUButton")
		local imageIconUImage = objectReference:GetRefValue("imageIconUImage")
		local playerInfo = pg.game.chat:getPlayerInfo(data.playerId)

		imgAvatarUImage.url = PlayerHeadIconData[playerInfo.headIcon].res

		ClientTextUtils.setText(textLvUSDFText, playerInfo.level)
		ClientTextUtils.setText(txtNameUSDFText, playerInfo.playerName)
		button:TryChangePage("OnlineState", playerInfo.online and 0 or 1)

		local lastLogoutTime = LuaUIUtils.getLastTimeStr(playerInfo.lastLogoutTime)

		ClientTextUtils.setText(textStateUSDFText, playerInfo.online and pg.getGameString("ONLINE") or lastLogoutTime)
		avatarUButton:TryChangePage("State", playerInfo.online and 1 or 2)
		button:TryChangePage("Gender", self:resolveGenderPage(playerInfo.avatarPresetKey))

		if playerInfo ~= nil then
			local friendShipLevel = pg.game.chat:getFriendship(data.playerId)
			local hasFriendship = friendShipLevel and FriendshipLevelData[friendShipLevel]

			if hasFriendship then
				local friendshipIcon = FriendshipLevelData[friendShipLevel].levelIcon

				imageIconUImage.url = friendshipIcon
			end

			imageIconUImage.gameObject:SetActiveEx(hasFriendship)
		end

		if self.sendPlayerUID == data.playerId then
			self.selectBtn = button

			button:SetSelected(true)
		else
			button:SetSelected(false)
		end
	end

	function self.view.listUList.luaClick(button, data)
		if self.selectBtn then
			if self.selectBtn ~= button then
				self.selectBtn:SetSelected(false)

				self.selectBtn = button

				self.selectBtn:SetSelected(true)
			end
		else
			self.selectBtn = button

			self.selectBtn:SetSelected(true)
		end

		self.sendPlayerUID = data.playerId

		self.view.uIPbChatFriendlPopupUComponent:TryChangePage("State", 2)
	end

	function self.view.searchUTMPInputField.luaEndEdit(text)
		self:doSearch(text)
	end

	function self.view.searchUTMPInputField.luaValueChanged(text)
		self:doSearch(text)
	end

	if pg.global.navMgr then
		self:addNavFocusListener(function()
			if self.view then
				self:refreshConsoleBarState()
			end
		end, "HomePlantsSend")
	end

	ClientTextUtils.setText(self.view.textUSDFText, pg.getGameString("HOME_FRIEND_LIST"))
end

function HomePlantsSendCtrl:refreshConsoleBarState()
	local currentFocusedGroupName = pg.global.navMgr.CurrentFocusedGroupName
	local currentFocusedUContent = pg.global.navMgr.CurrentFocusedUContent
	local isListItem = currentFocusedGroupName == "HomeCollectionFriendl" and currentFocusedUContent and currentFocusedUContent.gameObject.name == "UI_Node_Chat_Friend_Cell(Clone)"

	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("HomePlantsSend_List", isListItem)
end

function HomePlantsSendCtrl:onDestroy()
	UICtrl.onDestroy(self)

	self.selectBtn = nil
	self.sendPlayerUID = nil
	self.sendItemId = nil
	self.sendMode = nil
	self.isRequesting = nil
end

function HomePlantsSendCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	info = info or {}
	self.sendItemId = info.itemId
	self.sendMode = info.mode or UIConst.HOME_PLANTS_SEND_MODE.GIFT
	self.isRequesting = false
	self.selectBtn = nil
	self.sendPlayerUID = nil

	local confirmText = self.sendMode == UIConst.HOME_PLANTS_SEND_MODE.HELP and "HOMELAND_SEASON_CROP_HELP" or "COMMON_CONFIRM"

	ClientTextUtils.setText(self.view.txtConfirmUText, pg.getGameString(confirmText))
	ClientTextUtils.setText(self.view.inputHolderUSDFText, pg.getGameString("HOMELAND_SEASON_CROP_INPUT_INFO"))
	self.view.uIPbChatFriendlPopupUComponent:TryChangePage("State", 1)
	self:doSearch()
end

function HomePlantsSendCtrl:onShow()
	return
end

function HomePlantsSendCtrl:onHide()
	return
end

function HomePlantsSendCtrl:resolveGenderPage(avatarPresetKey)
	local preset = avatarPresetKey and pg.game.avatar:getAvatarPresetData(avatarPresetKey)
	local templateId = preset and preset.templateId or 0

	if templateId == 4 then
		return GENDER_MALE
	elseif templateId == 3 then
		return GENDER_FEMALE
	end

	return GENDER_UNKNOWN
end

function HomePlantsSendCtrl:onConfirm()
	if self.isRequesting or not self.sendPlayerUID then
		return
	end

	local targetUid = self.sendPlayerUID

	if self.sendMode == UIConst.HOME_PLANTS_SEND_MODE.HELP then
		self:requestHelpToFriend(targetUid)

		return
	end

	local ownNum = HomeSeasonUtils.getHomeSeasonMutationItemCount(pg.me, self.sendItemId)

	pg.global.ui.commonUseConfirm:open({
		hideCurrency = 1,
		muteCheckEnough = true,
		title = pg.getGameString("HOME_PLANT_SEND_TITLE"),
		tipTop = pg.getGameString("HOMELAND_SEASON_CROP_SEND_CONFIRM_DESC"),
		data = {
			{
				self.sendItemId,
				1,
				ownNum = ownNum
			}
		},
		confirmCb = function()
			self:sendGiftToFriend(targetUid)
		end
	})
end

function HomePlantsSendCtrl:sendGiftToFriend(targetUid)
	if self.isRequesting then
		return
	end

	self.isRequesting = true

	pg.me:reqSendHomeSeasonMutationGift(targetUid, self.sendItemId, function(result)
		logger:info("xzt reqSendHomeSeasonMutationGift 222222", targetUid, self.sendItemId, result, NoticeDef.SUCCESS)

		self.isRequesting = false

		if result ~= NoticeDef.SUCCESS then
			return
		end

		pg.game.chat:sendHomeSeasonMutationGiftChatCard(targetUid, self.sendItemId)
		pg.global.showBubbleMessageRaw(pg.getGameString("HOMELAND_SEASON_CROP_GIFT_SUCCESS"))
		self:dismiss()
	end)
end

function HomePlantsSendCtrl:requestHelpToFriend(friendUid)
	if self.isRequesting then
		return
	end

	self.isRequesting = true

	pg.me:reqRequestHomeSeasonMutationHelpToFriend(friendUid, self.sendItemId, function(result, cardInfo)
		self.isRequesting = false

		if result ~= NoticeDef.SUCCESS then
			return
		end

		pg.global.showBubbleMessageRaw(pg.getGameString("HOMELAND_SEASON_CROP_HELP_SUCCESS"))
		pg.game.chat:sendHomeSeasonMutationHelpChatCard(friendUid, cardInfo)
		self:dismiss()
	end)
end

function HomePlantsSendCtrl:doSearch(text)
	local friendList = pg.game.chat:getFriendList() or {}

	if string.isNilOrEmpty(text) then
		self.view.listUList:SetList(friendList)

		return
	end

	local ret = {}

	for _, friend in pairs(friendList) do
		local playerInfo = pg.game.chat:getPlayerInfo(friend.playerId)

		if string.find(playerInfo.playerName, text) or string.find(friend.playerId, text) then
			table.insert(ret, {
				playerId = friend.playerId
			})
		end
	end

	self.view.listUList:SetList(ret)
end

return HomePlantsSendCtrl
