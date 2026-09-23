-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\InteractGesture\\InteractGestureCtrl.lua

local UICtrl = require("Guis.UICtrl")
local Class = require("Core.Framework.Class")
local InteractGestureCtrl = Class.LightClass("InteractGestureCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local HotkeyConst = require("Const.HotkeyConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local UIConst = require("Const.UIConst")
local MessageName = require("Const.MessageName")

InteractGestureCtrl.messages = {
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	},
	[MessageName.GESTURE_TARGET_CHANGE] = {
		"onGestureTargetChanged",
		true
	}
}

function InteractGestureCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.friendshipLevel = 0

	self:refreshGestureList()
end

function InteractGestureCtrl:addListener()
	self:bindHotKeyPerform("Hud/OpenEmotion", function()
		self:close()
	end, self.view.widget.gameObject, "Hud/OpenEmotion")

	function self.view.bgCloseUButton.luaClick()
		self:close()
	end

	function self.view.listUList.luaRenderItem(button, index, data)
		local objectReference1 = button:GetComponent("ObjectReference")
		local iconUImage = objectReference1:GetRefValue("iconUImage")
		local txtNameUSDFText = objectReference1:GetRefValue("txtNameUSDFText")

		button:TryChangePage("button", 0)

		button.isSelected = false

		if data.empty then
			button:TryChangePage("Empty", 1)

			button.interactable = false

			ClientTextUtils.setText(txtNameUSDFText, pg.getGameString("UP_COMING"))

			button.luaClick = nil
		else
			button:TryChangePage("Empty", 0)

			button.interactable = true
			iconUImage.url = data.icon

			ClientTextUtils.setText(txtNameUSDFText, data.name)

			function button.luaClick()
				pg.game.social.interactGestureComponent:chooseAction(data)
				self:close()
				pg.pawn:dismountSelf()
			end

			button:TryChangePage("Icon", (not data.friendshipLevel or self.friendshipLevel >= data.friendshipLevel) and 0 or 1)
		end
	end

	local closeBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.widget.gameObject, "closeBind")

	closeBind.isVirtual = true
	closeBind.priority = -1
	closeBind.actionPath = "Common/ClosePanelCommon"

	function closeBind.luaTrigger(inputInfo)
		self:close()
	end

	self:bindHotKeyPerform(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadDPadLeft, function()
		return pg.game.input:onGamepadLeftStickMoveSimulate(1)
	end, self.view.widget.gameObject)
	self:bindHotKeyPerform(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadDPadRight, function()
		return pg.game.input:onGamepadLeftStickMoveSimulate(2)
	end, self.view.widget.gameObject)
	self:bindHotKeyPerform("Common/GamepadConfirm", function()
		pg.game.input:onGamepadConfirmSimulate()

		return false
	end, self.view.widget.gameObject)

	function self.view.listTabUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local txtNameUBaseText = objectReference:GetRefValue("txtNameUBaseText")

		ClientTextUtils.setText(txtNameUBaseText, data.label)
	end

	function self.view.listTabUList.luaSelectedChanged(ulist, isSelected)
		if not isSelected then
			return
		end

		local gestureData = pg.game.social.interactGestureComponent:getGesturesDataSeparated(ulist.selectedItem.isSingle)

		self.view.listUList:SetList(gestureData)

		if not ulist.selectedItem.isSingle then
			pg.game.social.interactGestureComponent:startSelectPlayer()
		else
			pg.game.social.interactGestureComponent:stopSelectPlayer()
		end
	end
end

function InteractGestureCtrl:refreshGestureList()
	local tabData = {
		{
			tIndex = 0,
			isSingle = true,
			label = pg.getGameString("SINGLE_GESTURE")
		},
		{
			tIndex = 1,
			isSingle = false,
			label = pg.getGameString("MULTI_GESTURE")
		}
	}

	self.view.listTabUList:SetList(tabData)
	self.view.listTabUList:SelectItem(0)
end

function InteractGestureCtrl:onGestureTargetChanged(info)
	self.curSelectedPlayerId = info and info.playerId and info.playerId or nil

	if self.curSelectedPlayerId then
		self.friendshipLevel = pg.game.chat:getFriendship(self.curSelectedPlayerId)
	end

	self.view.listUList:RefreshList()
end

function InteractGestureCtrl:close()
	UICtrl.close(self)

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_HUD_V2) then
		pg.global.ui.hudV2:setMateComponentVisible(true)
	end

	pg.game.social.interactGestureComponent:stopSelectPlayer()
end

function InteractGestureCtrl:checkUIShowVirtualMouseCursor()
	return false
end

function InteractGestureCtrl:onInputDeviceChanged()
	return
end

return InteractGestureCtrl
