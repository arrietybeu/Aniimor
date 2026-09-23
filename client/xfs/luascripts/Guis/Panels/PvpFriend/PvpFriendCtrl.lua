-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PvpFriend\\PvpFriendCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local PvpFriendCtrl = Class.LightClass("PvpFriendCtrl", UICtrl)
local Time = require("Core.Common.Time")
local ClientTextUtils = require("Utils.ClientTextUtils")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local HotkeyConst = require("Const.HotkeyConst")

PvpFriendCtrl.messages = {
	[MessageName.PVP_DETAIL_COVENANT_BATTLE] = {
		"onDetailCovenantBattle",
		true
	},
	[MessageName.PVP_RECEIVE_COVENANT] = {
		"onReceiveCovenant",
		true
	}
}

function PvpFriendCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function PvpFriendCtrl:addListener()
	function self.view.listFriends.luaRenderItem(button, _, data)
		self:onRenderFriendItem(button, data)
	end

	function self.view.btnDisplay.luaClick()
		self:onBtnSetSwitch()
	end

	local closeBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.btnCloseOuter.gameObject, "closeBind")

	closeBind.isVirtual = true
	closeBind.priority = -1
	closeBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel

	function closeBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self:dismiss()
		end
	end

	function self.view.btnCloseOuter.luaClick()
		self:dismiss()
	end

	function self.view.btnCloseInner.luaClick()
		self:dismiss()
	end
end

function PvpFriendCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function PvpFriendCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function PvpFriendCtrl:onShow()
	self:onReloadFriendList(false)
end

function PvpFriendCtrl:onReloadFriendList(onlyFreeFriend)
	local dataList = self.model:getFriendDataList(onlyFreeFriend)

	self.view.listFriends:SetList(dataList)
end

function PvpFriendCtrl:onBtnSetSwitch()
	local _, page = self.view.rootComponent:TryGetCurrentPage("Check")

	page = page == 0 and 1 or 0

	self.view.rootComponent:TryChangePage("Check", page)
	self:onReloadFriendList(page == 1)
end

function PvpFriendCtrl:onRenderFriendItem(button, data)
	local oc = button:GetComponent("ObjectReference")
	local icon = oc:GetRefValue("icon")
	local txtName = oc:GetRefValue("txtName")
	local btnInvite = oc:GetRefValue("btnInvite")

	if data.state == self.model.PLAYER_STATE.OUTLINE then
		button:TryChangePage("State", 2)
	elseif data.state == self.model.PLAYER_STATE.BUSY then
		button:TryChangePage("State", 1)
	else
		button:TryChangePage("State", 0)
	end

	ClientTextUtils.setText(txtName, data.name)

	function btnInvite.luaClick()
		self:onBtnInviteFriend(data)
	end
end

function PvpFriendCtrl:TryGetItemFromUList(uid)
	return
end

function PvpFriendCtrl:onBtnInviteFriend(data)
	pg.me:pvpBattleInvite(data.uid)
end

function PvpFriendCtrl:onReceiveCovenant(inviteeUid, endTime)
	local res, button = self:TryGetItemFromUList(inviteeUid)

	if not res then
		return
	end

	button:TryChangePage("Invite", 1)

	button.interactable = false

	local oc = button:GetComponent("ObjectReference")
	local txtCountDown = oc:GetRefValue("txtCountDown")
	local data = button.dataFromUList

	data.tickTimer = self:startTimer(function()
		ClientTextUtils.setText(txtCountDown, endTime - Time.secondCache)
	end, 0.02, true)
end

function PvpFriendCtrl:onDetailCovenantBattle(res)
	if res.state == 1 then
		self:dismiss()
	else
		self:onClearRenderItemState(res.rivalUid)
	end
end

function PvpFriendCtrl:onClearRenderItemState(uid)
	local res, button = self:TryGetItemFromUList(uid)

	if not res then
		return
	end

	button:TryChangePage("Invite", 0)

	button.interactable = true

	local data = button.dataFromUList

	if data.tickTimer then
		self:killTimer(data.tickTimer)
	end

	data.tickTimer = nil
end

function PvpFriendCtrl:onHide()
	return
end

return PvpFriendCtrl
