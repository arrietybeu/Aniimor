-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\FriendInviteList\\FriendInviteListCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local FriendInviteListCtrl = Class.LightClass("FriendInviteListCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")

FriendInviteListCtrl.messages = {}

function FriendInviteListCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.noticeLists = info
	self.itemLineDelay = 0.015

	self:initInviteList(info)

	self.timeTrigger = self:startTimer(function()
		self:refreshInviteList()
	end, 0.1, true)
end

function FriendInviteListCtrl:addListener()
	function self.view.btnCloseUButton.luaClick()
		self:dismiss()
	end

	function self.view.btnCancelUButton.luaClick()
		self:dismiss()
	end

	function self.view.btnConfirmUButton.luaClick()
		for _, item in ipairs(self.noticeLists) do
			pg.me:acceptTeamInvite(item.playerId, false)
		end

		pg.global.ui.tips:removeAllNotice()
		self:dismiss()
	end
end

function FriendInviteListCtrl:initInviteList()
	function self.view.listUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local progress = objectReference:GetRefValue("progressUProgress")
		local btnNoUButton = objectReference:GetRefValue("btnNoUButton")
		local btnYesUButton = objectReference:GetRefValue("btnYesUButton")
		local playerNameUText = objectReference:GetRefValue("playerNameUText")
		local noticeUText = objectReference:GetRefValue("noticeUText")
		local vxParTransform = objectReference:GetRefValue("vxParTransform")

		progress.minValue = 0
		progress.maxValue = data.duration
		progress.value = data.remainderTime

		LuaUIUtils.setUIViewVisible(vxParTransform, data.remainderTime > 0 and data.remainderTime < data.duration)

		function btnNoUButton.luaClick()
			pg.me:acceptTeamInvite(data.playerId, false)
			pg.global.ui.tips:removeTeamInviteNotice(data.noticeId)
			self:refreshInviteList()
		end

		function btnYesUButton.luaClick()
			pg.me:acceptTeamInvite(data.playerId, true)
			pg.global.ui.tips:removeTeamInviteNotice(data.noticeId)
			self:refreshInviteList()
		end

		local playerName = LuaUIUtils.getPlayerDisplayName(data.playerId, data.playerInfo.playerName, true)
		local _h = FriendInviteListCtrl._platformHooks

		playerName = _h and _h.renderInvitePlayerName and _h.renderInvitePlayerName(self, button, data, playerName) or playerName

		ClientTextUtils.setText(playerNameUText, playerName)
		ClientTextUtils.setText(noticeUText, data.noticeMsg or "")
	end

	self:refreshInviteList()

	local _h = FriendInviteListCtrl._platformHooks

	if _h and _h.initInviteList then
		_h.initInviteList(self)
	end
end

function FriendInviteListCtrl:playListAni()
	local buttons = self.view.listUList:GetAllButtons()
	local delayTime = 0

	for i = 0, buttons.Length - 1 do
		local ani = buttons[i]:GetComponent("Animation")

		self:startTimer(function()
			ani:Play()
		end, delayTime)

		delayTime = delayTime + self.itemLineDelay
	end
end

function FriendInviteListCtrl:refreshInviteList()
	self.view.listUList:SetList(self.noticeLists)
end

function FriendInviteListCtrl:onDestroy()
	self:killTimer(self.timeTrigger)
	UICtrl.onDestroy(self)
end

function FriendInviteListCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function FriendInviteListCtrl:onShow()
	return
end

function FriendInviteListCtrl:onHide()
	return
end

return FriendInviteListCtrl
