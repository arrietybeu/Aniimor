-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\InviteFriend\\InviteFriendCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PlayerHeadIconData = require("Data.player_head_icon_data")
local UIConst = require("Const.UIConst")
local MessageName = require("Const.MessageName")
local InviteFriendCtrl = Class.LightClass("InviteFriendCtrl", UICtrl)

InviteFriendCtrl.messages = {
	[MessageName.RECV_FRIEND_LIST] = {
		"refreshFriendList",
		true
	},
	[MessageName.ON_OTHER_PLAYER_ENTER_SCENE] = {
		"refreshFriendList",
		true
	},
	[MessageName.ON_OTHER_PLAYER_LEAVE_SCENE] = {
		"refreshFriendList",
		true
	}
}

function InviteFriendCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
	self:initFriendPage()
end

function InviteFriendCtrl:addListener()
	function self.view.btnCloseUButton.luaClick()
		self:closePanel()
	end

	function self.view.btnClose1UButton.luaClick()
		self:closePanel()
	end
end

function InviteFriendCtrl:initFriendPage()
	ClientTextUtils.setText(self.view.textUSDFText, self.model:getPanelTitleDesc())

	function self.view.searchUTMPInputField.luaValueChanged(value)
		if string.isNilOrEmpty(value) then
			self.searchText = nil
		else
			self.searchText = value
		end

		self:refreshFriendList()
	end

	function self.view.friendList.luaRenderItem(button, index, data)
		self:renderFriendItem(button, index, data)
	end

	function self.view.btnInfoUButton.luaRenderTooltip(btn, prop)
		local objectReference = prop:GetComponent("ObjectReference")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

		ClientTextUtils.setText(txtNameUSDFText, self.model:getPanelTipInfo())
	end

	self:refreshFriendList()
end

function InviteFriendCtrl:renderFriendItem(button, index, data)
	if data.hidden then
		button:SetActive(false)

		return
	end

	if data.tIndex == 0 then
		ClientTextUtils.setText(button:GetChild("TxtName"):GetComponent("UBaseText"), pg.getGameString(data.label))

		function button.luaClick()
			pg.game.chat.friendList[2].state = 1 - pg.game.chat.friendList[2].state

			self:refreshFriendList()
		end
	elseif data.tIndex == 1 then
		local objectReference = button:GetComponent("ObjectReference")
		local imgAvatarUImage = objectReference:GetRefValue("imgAvatarUImage")
		local nameUBaseText = objectReference:GetRefValue("nameUBaseText")
		local avatarUButton = objectReference:GetRefValue("avatarUButton")
		local txtOffLineUBaseText = objectReference:GetRefValue("txtOffLineUBaseText")
		local btnInviteUButton = objectReference:GetRefValue("btnInviteUButton")
		local playerInfo = pg.game.chat:getPlayerInfo(data.playerId)

		if playerInfo then
			local exists = self.model:checkUidExistsInSpace(playerInfo.uid)

			button:TryChangePage("Invite", exists and 1 or 0)

			local state = playerInfo.online and 0 or 1

			button:TryChangePage("State", state + 1)

			local text, _ = LuaUIUtils.getLastTimeStr(playerInfo.lastLogoutTime)

			ClientTextUtils.setText(txtOffLineUBaseText, text)

			local playerName = playerInfo.playerName or ""
			local _h = InviteFriendCtrl._platformHooks

			playerName = _h and _h.renderFriendItemName and _h.renderFriendItemName(self, button, data, playerInfo, playerName) or playerName

			ClientTextUtils.setText(nameUBaseText, playerName)

			local headIcon = playerInfo.headIcon or 1

			imgAvatarUImage.url = PlayerHeadIconData[headIcon] and PlayerHeadIconData[headIcon].res or ""

			local objectReference1 = avatarUButton:GetComponent("ObjectReference")
			local textLvUSDFText = objectReference1:GetRefValue("textLvUSDFText")

			ClientTextUtils.setText(textLvUSDFText, data.level or 1)
			pg.global.ui.chat:handlePlayerTooltip(avatarUButton, data)

			function btnInviteUButton.luaClick()
				pg.me:inviteEnterPhotoWorld(playerInfo.uid)
			end
		end
	end
end

function InviteFriendCtrl:refreshFriendList()
	if not string.isNilOrEmpty(self.searchText) then
		local data = self.model:getSearchedList(self.searchText)

		self.view.friendList:SetList(data)

		return
	end

	if pg.game.chat.friendList[2].state == 0 then
		self.view.friendList:SetList(self.model:getTitleData())
	else
		local data = self.model:getInviteFriendListData()

		self.view.friendList:SetList(data)
	end
end

function InviteFriendCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function InviteFriendCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function InviteFriendCtrl:onShow()
	return
end

function InviteFriendCtrl:onHide()
	return
end

function InviteFriendCtrl:closePanel()
	pg.global.ui:close(UIConst.UI_ID_INVITE_FRIEND)
end

function InviteFriendCtrl:onVisibleChange(visible)
	if visible then
		-- block empty
	end
end

return InviteFriendCtrl
