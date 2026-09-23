-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomeCampInviteFriend\\HomeCampInviteFriendCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomeCampInviteFriendCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PlayerHeadIconData = require("Data.player_head_icon_data")
local FriendshipLevelData = require("Data.friendship_level_data")
local AvatarPresetData = require("Data.avatar_preset_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local HomeCampInviteFriendCtrl = Class.LightClass("HomeCampInviteFriendCtrl", UICtrl)
local NoticeDef = require("Common.NoticeDef")
local GENDER_MALE = 0
local GENDER_FEMALE = 1
local GENDER_UNKNOWN = 2

HomeCampInviteFriendCtrl.messages = {}

function HomeCampInviteFriendCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function HomeCampInviteFriendCtrl:addListener()
	function self.view.bgCloseUButton.luaClick()
		self:close()
	end

	function self.view.btnCloseUButton.luaClick()
		self:close()
	end

	function self.view.btnConfirmUButton.luaClick()
		if self.invitePlayerUID then
			self:sendInviteMessage(self.invitePlayerUID)
		end
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

		local playerName = playerInfo.playerName
		local _h = HomeCampInviteFriendCtrl._platformHooks

		playerName = _h and _h.getMaskedPlayerName and _h.getMaskedPlayerName(self, data, playerInfo, playerName) or playerName

		ClientTextUtils.setText(txtNameUSDFText, playerName)
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

		if self.invitePlayerUID == data.playerId then
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

		self.invitePlayerUID = data.playerId

		self.view.uIPbChatFriendlPopupUComponent:TryChangePage("State", 2)
	end

	function self.view.searchUTMPInputField.luaEndEdit(text)
		self:doSearch(text)
	end

	function self.view.searchUTMPInputField.luaValueChanged(text)
		self:doSearch(text)
	end

	ClientTextUtils.setText(self.view.textUSDFText, pg.getGameString("HOME_FRIEND_LIST"))
	ClientTextUtils.setText(self.view.txtNameUSDFText, pg.getGameString("CHALLENGE_INVITE"))
	ClientTextUtils.setText(self.view.placeHolderUSDFText, pg.getGameString("SHOP_ENTER"))
end

function HomeCampInviteFriendCtrl:onDestroy()
	UICtrl.onDestroy(self)

	self.selectBtn = nil
	self.invitePlayerUID = nil
end

function HomeCampInviteFriendCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.selectBtn = nil

	self.view.uIPbChatFriendlPopupUComponent:TryChangePage("State", 1)
	self:doSearch()
end

function HomeCampInviteFriendCtrl:onShow()
	return
end

function HomeCampInviteFriendCtrl:onHide()
	return
end

function HomeCampInviteFriendCtrl:resolveGenderPage(avatarPresetKey)
	local preset = avatarPresetKey and pg.game.avatar:getAvatarPresetData(avatarPresetKey)
	local templateId = preset and preset.templateId or 0

	if templateId == 4 then
		return GENDER_MALE
	elseif templateId == 3 then
		return GENDER_FEMALE
	end

	return GENDER_UNKNOWN
end

function HomeCampInviteFriendCtrl:doSearch(text)
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

function HomeCampInviteFriendCtrl:sendInviteMessage(invitePlayerUID)
	pg.me:sendInviteFriendMessage(invitePlayerUID, true)
end

return HomeCampInviteFriendCtrl
