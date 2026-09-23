-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\EventFriend\\EventFriendCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PlayerHeadIconData = require("Data.player_head_icon_data")
local FriendshipLevelData = require("Data.friendship_level_data")
local EventFriendCtrl = Class.LightClass("EventFriendCtrl", UICtrl)

function EventFriendCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.showList = info.showList
	self.titleTxt = info.title
	self.emptyTxt = info.emptyTxt
end

function EventFriendCtrl:addListener()
	function self.view.bgCloseUButton.luaClick()
		self:dismiss()
	end

	function self.view.btnCloseUButton.luaClick()
		self:dismiss()
	end

	function self.view.friendUList.luaRenderItem(button, index, data)
		self:renderFriendItem(button, index, data)
	end
end

function EventFriendCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function EventFriendCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	self:initUI()
end

function EventFriendCtrl:initUI()
	ClientTextUtils.setText(self.view.textUBaseText, self.titleTxt)
	ClientTextUtils.setText(self.view.txtEmptyUBaseText, self.emptyTxt)

	local friendList = self.showList

	self.view.friendUList:SetList(friendList)
	self.view.rootUComponent:TryChangePage("Empty", friendList and next(friendList) and 0 or 1)
end

function EventFriendCtrl:renderFriendItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local imgAvatarUImage = objectReference:GetRefValue("imgAvatarUImage")
	local emblemUImage = objectReference:GetRefValue("emblemUImage")
	local nameUBaseText = objectReference:GetRefValue("nameUBaseText")
	local avatarUButton = objectReference:GetRefValue("avatarUButton")
	local iconLikabilityUImage = objectReference:GetRefValue("iconLikabilityUImage")
	local friendshipBtnUButton = objectReference:GetRefValue("friendshipBtnUButton")
	local txtOffLineUBaseText = objectReference:GetRefValue("txtOffLineUBaseText")
	local layoutInfoULayoutBox = objectReference:GetRefValue("layoutInfoULayoutBox")
	local txtNameChangeUSDFText = objectReference:GetRefValue("txtNameChangeUSDFText")
	local nameCoverUSDFText = objectReference:GetRefValue("nameCoverUSDFText")
	local avatarObjectReference = avatarUButton:GetComponent("ObjectReference")
	local textLvUSDFText = avatarObjectReference:GetRefValue("textLvUSDFText")

	button:TryChangePage("isChange", pg.game.chat.specialFriendUId == data.playerId and 1 or 0)

	local playerInfo = pg.game.chat:getPlayerInfo(data.playerId)

	if playerInfo == nil then
		return
	end

	local state = playerInfo.online and 0 or 1

	button:TryChangePage("State", state + 1)

	local text, _ = LuaUIUtils.getLastTimeStr(playerInfo.lastLogoutTime)

	ClientTextUtils.setText(txtOffLineUBaseText, text)

	local friendShipLevel = pg.game.chat:getFriendship(data.playerId)
	local hasFriendship = friendShipLevel and FriendshipLevelData[friendShipLevel]

	function friendshipBtnUButton.luaRenderTooltip(button, panel)
		local objectReference = panel:GetComponent("ObjectReference")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

		ClientTextUtils.setText(txtNameUSDFText, pg.getGameString("FRIEND_LEVELSHIP_TIP"))
	end

	friendshipBtnUButton:SetActive(hasFriendship)

	if hasFriendship then
		local friendshipIcon = FriendshipLevelData[friendShipLevel].levelIcon

		iconLikabilityUImage.url = friendshipIcon
	end

	ClientTextUtils.setText(textLvUSDFText, playerInfo.level or 1)

	local playerName = playerInfo.playerName or ""
	local _h = EventFriendCtrl._platformHooks

	playerName = _h and type(_h.renderFriendItemName) == "function" and _h.renderFriendItemName(self, button, index, data, playerInfo, playerName) or playerName

	ClientTextUtils.setText(nameUBaseText, playerName)
	ClientTextUtils.setText(txtNameChangeUSDFText, playerName)
	ClientTextUtils.setText(nameCoverUSDFText, playerName)

	local headIcon = playerInfo.headIcon or 1

	imgAvatarUImage.url = PlayerHeadIconData[headIcon] and PlayerHeadIconData[headIcon].res or ""
	emblemUImage.url = LuaUIUtils.getStarIcon(playerInfo.starTitle)

	pg.global.ui.chat:handlePlayerTooltip(avatarUButton, data)

	if layoutInfoULayoutBox then
		layoutInfoULayoutBox:ForceRebuildLayoutImmediate()
	end
end

return EventFriendCtrl
