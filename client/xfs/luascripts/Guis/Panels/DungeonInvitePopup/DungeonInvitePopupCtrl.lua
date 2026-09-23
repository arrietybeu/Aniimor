-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\DungeonInvitePopup\\DungeonInvitePopupCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local LuaUIUtils = require("Utils.LuaUIUtils")
local HotkeyConst = require("Const.HotkeyConst")
local DungeonInvitePopupCtrl = Class.LightClass("DungeonInvitePopupCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")

DungeonInvitePopupCtrl.messages = {}

function DungeonInvitePopupCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
	self:initInviteList()
end

function DungeonInvitePopupCtrl:addListener()
	function self.view.btnCloseUButton.luaClick()
		self:close()
	end

	function self.view.btnCancelUButton.luaClick()
		self:close()
	end

	function self.view.btnConfirmUButton.luaClick()
		if self.inviteData then
			for _, item in ipairs(self.inviteData) do
				pg.game.chat:teamHandle(item.Uid)

				item.hasInvite = 1
			end

			self.view.listUList:SetList(self.inviteData)
		end
	end

	local keyBindConfirm = self:bindHotKey(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonNorth, function()
		self.view.btnConfirmUButton:OnClickSimulate()
	end)

	keyBindConfirm.priority = 10

	local keyBindCancel = self:bindHotKey(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonEast, function()
		self.view.btnCancelUButton:OnClickSimulate()
	end)

	keyBindCancel.priority = 10
end

function DungeonInvitePopupCtrl:initInviteList()
	function self.view.listUList.luaRenderItem(button, index, data)
		local playerInfo = data.AttributesMap or {}
		local playerName = playerInfo.playerName
		local _h = DungeonInvitePopupCtrl._platformHooks

		playerName = _h and _h.renderInvitePlayerName and _h.renderInvitePlayerName(self, data, playerInfo, playerName) or playerName

		ClientTextUtils.setText(button.transform:Find("TxtName"):GetComponent("UBaseText"), playerName)
		button:TryChangePage("Invite", data.hasInvite)

		button.transform:Find("Invite/BtnInvite"):GetComponent("UButton").luaClick = function()
			pg.game.chat:teamHandle(data.Uid)

			data.hasInvite = 1

			button:TryChangePage("Invite", data.hasInvite)
		end
	end

	pg.me:getRandomOnlinePlayersInfo(20, function(isSuccess, data)
		local selfIndex = -1

		for index, item in ipairs(data) do
			item.hasInvite = 0

			if pg.me.uid == item.Uid then
				selfIndex = index
			end
		end

		if selfIndex ~= -1 then
			table.remove(data, selfIndex)
		end

		self.inviteData = data

		self.view.listUList:SetList(self.inviteData)
	end)

	local _h = DungeonInvitePopupCtrl._platformHooks

	if _h and _h.initInviteList then
		_h.initInviteList(self)
	end
end

function DungeonInvitePopupCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function DungeonInvitePopupCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function DungeonInvitePopupCtrl:onShow()
	return
end

function DungeonInvitePopupCtrl:onHide()
	return
end

return DungeonInvitePopupCtrl
