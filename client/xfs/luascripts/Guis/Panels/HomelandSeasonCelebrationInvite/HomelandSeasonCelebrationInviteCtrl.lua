-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandSeasonCelebrationInvite\\HomelandSeasonCelebrationInviteCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PlayerHeadIconData = require("Data.player_head_icon_data")
local FriendshipLevelData = require("Data.friendship_level_data")
local AvatarPresetData = require("Data.avatar_preset_data")
local MessageName = require("Const.MessageName")
local Const = require("Common.Const.Const")
local CELEBRATION_STATE_PREPARING = 1
local GENDER_MALE = 0
local GENDER_FEMALE = 1
local GENDER_UNKNOWN = 2
local HomelandSeasonCelebrationInviteCtrl = Class.LightClass("HomelandSeasonCelebrationInviteCtrl", UICtrl)

HomelandSeasonCelebrationInviteCtrl.messages = {
	[MessageName.HOME_SEASON_CELEBRATION_CHANGE] = {
		"onCelebrationStateChanged",
		true
	},
	[MessageName.RECV_FRIEND_LIST] = {
		"onFriendListChanged",
		true
	}
}

function HomelandSeasonCelebrationInviteCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.space = info and info.space or pg.space
end

function HomelandSeasonCelebrationInviteCtrl:addListener()
	function self.view.bgCloseUButton.luaClick()
		self:close()
	end

	function self.view.btnCloseUButton.luaClick()
		self:close()
	end

	function self.view.btnConfirmUButton.luaClick()
		self:sendInvite()
	end

	function self.view.listUList.luaRenderItem(button, index, data)
		self:renderFriendItem(button, index, data)
	end

	function self.view.listUList.luaClick(button, data)
		self.selectedUid = data.playerId

		self.view.rootUComponent:TryChangePage("State", 2)
		self.view.listUList:RefreshList()
	end

	function self.view.searchUTMPInputField.luaValueChanged(text)
		self.searchText = text

		self.view.btnDeleteUButton:SetActive(not string.isNilOrEmpty(text))
		self:refreshFriendList()
	end

	LuaUIUtils.bindInputFieldGamepad(self.view.searchUTMPInputField, self.view.keyHotKeyContent, self.view.btnDeleteUButton)
	ClientTextUtils.setText(self.view.textUSDFText, pg.getGameString("HOME_FRIEND_LIST"))
	ClientTextUtils.setText(self.view.inputHolderUSDFText, pg.getGameString("PLEASE_INPUT_PLAYER"))
	ClientTextUtils.setText(self.view.txtNameUSDFText, pg.getGameString("HOME_SEASON_CELEBRATION_INVITE_BUTTON"))
end

function HomelandSeasonCelebrationInviteCtrl:onOpen()
	UICtrl.onOpen(self)

	if not self.space or not self.space:isCelebrationOwner() or self.space.homeSeasonCelebrationState ~= CELEBRATION_STATE_PREPARING then
		self:close()

		return
	end

	self.selectedUid = nil
	self.searchText = nil

	self.view.searchUTMPInputField:TryChangePage("state", 0)
	self.view.searchUTMPInputField:SetTextWithoutNotify("")
	self.view.btnDeleteUButton:SetActive(false)
	self.view.rootUComponent:TryChangePage("State", 1)
	self:refreshFriendList()
end

function HomelandSeasonCelebrationInviteCtrl:onCelebrationStateChanged()
	if not self.space or not self.space:isCelebrationOwner() or self.space.homeSeasonCelebrationState ~= CELEBRATION_STATE_PREPARING then
		self:close()
	end
end

function HomelandSeasonCelebrationInviteCtrl:onFriendListChanged()
	self:refreshFriendList()
end

function HomelandSeasonCelebrationInviteCtrl:refreshFriendList()
	local friends = self.model:getFriends(self.searchText)
	local selectedVisible = false

	for _, friend in ipairs(friends) do
		if friend.playerId == self.selectedUid then
			selectedVisible = true

			break
		end
	end

	if self.selectedUid and not selectedVisible then
		self.selectedUid = nil

		self.view.rootUComponent:TryChangePage("State", 1)
	end

	self.view.listUList:SetList(friends)
end

function HomelandSeasonCelebrationInviteCtrl:resolveGenderPage(avatarPresetKey)
	local preset = avatarPresetKey and AvatarPresetData[avatarPresetKey]
	local templateId = preset and preset.templateId or 0

	if templateId == 4 then
		return GENDER_MALE
	elseif templateId == 3 then
		return GENDER_FEMALE
	end

	return GENDER_UNKNOWN
end

function HomelandSeasonCelebrationInviteCtrl:renderFriendItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtName = objectReference:GetRefValue("txtNameUSDFText")
	local txtLevel = objectReference:GetRefValue("textLvUSDFText")
	local imgAvatar = objectReference:GetRefValue("imgAvatarUImage")
	local txtState = objectReference:GetRefValue("textStateUSDFText")
	local avatarButton = objectReference:GetRefValue("avatarUButton")
	local friendshipIcon = objectReference:GetRefValue("imageIconUImage")
	local playerInfo = pg.game.chat:getPlayerInfo(data.playerId) or {}
	local headIcon = PlayerHeadIconData[playerInfo.headIcon or 1]

	imgAvatar.url = headIcon and headIcon.res or ""

	ClientTextUtils.setText(txtName, playerInfo.playerName or tostring(data.playerId))
	ClientTextUtils.setText(txtLevel, playerInfo.level or data.level or 1)

	local lastLoginText = LuaUIUtils.getLastTimeStr(playerInfo.loginTime)

	ClientTextUtils.setText(txtState, playerInfo.online and pg.getGameString("ONLINE") or lastLoginText)
	button:TryChangePage("OnlineState", playerInfo.online and 0 or 1)
	button:TryChangePage("Gender", self:resolveGenderPage(playerInfo.avatarPresetKey))
	avatarButton:TryChangePage("State", playerInfo.online and 1 or 2)

	local friendshipLevel = pg.game.chat:getFriendship(data.playerId)
	local friendship = friendshipLevel and FriendshipLevelData[friendshipLevel]

	friendshipIcon.gameObject:SetActiveEx(friendship ~= nil)

	if friendship then
		friendshipIcon.url = friendship.levelIcon
	end

	pg.global.ui.chat:handlePlayerTooltip(avatarButton, data)
	button:SetSelected(self.selectedUid == data.playerId)
end

function HomelandSeasonCelebrationInviteCtrl:sendInvite()
	if not self.selectedUid or not self.space or not self.space:isCelebrationOwner() or (self.space.homeSeasonCelebrationState or 0) ~= CELEBRATION_STATE_PREPARING then
		return
	end

	local inviteInfo = {
		ownerUid = pg.me.uid,
		festivalId = self.space.homeSeasonCelebrationFestivalId,
		sessionId = self.space.homeSeasonCelebrationSessionId
	}
	local sent = pg.game.chat:sendMessage(pg.getGameString("HOME_SEASON_CELEBRATION_TITLE"), pg.game.chat.subMessageType.HomeSeasonCelebrationInvite, pg.game.chat.channelType.Player, self.selectedUid, {
		[Const.CHAT_EXTRA_TYPE.HomeSeasonCelebrationInvite] = inviteInfo
	})

	if sent then
		self:close()
	end
end

return HomelandSeasonCelebrationInviteCtrl
