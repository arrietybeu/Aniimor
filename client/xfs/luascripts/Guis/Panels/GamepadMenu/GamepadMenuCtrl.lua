-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GamepadMenu\\GamepadMenuCtrl.lua

local ClientUtils = require("Utils.ClientUtils")
local UIComponent = require("Guis.Helper.UIComponent")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local GameStrings = require("Data.gamestrings_data")
local UIConst = require("Const.UIConst")
local MessageName = require("Const.MessageName")
local HotkeyConst = require("Const.HotkeyConst")
local GamepadMenuItemData = require("Data.gamepad_menu_item_fun_data")
local SysConfigData = require("Data.sys_config_data")
local Const = require("Common.Const.Const")
local AudioConst = require("Const.AudioConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local CommonSwitch = require("Common.CommonSwitch")
local AddressDataConst = require("Const.AddressDataConst")
local FuncIdConfigData = require("Data.func_index_config_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local GamepadMenuCtrl = Class.LightClass("GamepadMenuCtrl", UICtrl)
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local InputDeviceType = CS.FunPlus.WorldX.Manager.InputDeviceType
local MENU_ITEM_NUM = 8
local MenuItemType = {
	Photo = "TAKEPHOTO",
	Undefined = "",
	PVP = "PVP",
	Map = "MAP",
	PetBall = "PETBALL",
	PetEntry = "PETENTRY",
	Help = "HELP",
	Config = "CONFIG",
	Bag = "BAG",
	PetBook = "PETRESEARCH",
	Quest = "QUEST"
}
local ZoomingState = Const.ZoomingState

GamepadMenuCtrl.messages = {
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	}
}

function GamepadMenuCtrl:ctor()
	UICtrl.ctor(self)

	self.isOpen = false
	self.listData = {}
end

function GamepadMenuCtrl:addListener()
	local closeBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.widget.gameObject, "closeBind")

	closeBind.isVirtual = true
	closeBind.priority = -1
	closeBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel

	function closeBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self:setMenuOpen(false)
		end
	end

	local actionPath = "Player/Move"

	self:initMenuItems()

	self.menuNavBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.menu.gameObject, "menuNav")
	self.menuNavBind.actionPath = actionPath
	self.menuNavBind.isVirtual = true

	function self.menuNavBind.luaTrigger(inputInfo)
		if self._visible then
			if inputInfo.phase == "Performed" then
				self.view.menu:SetWheelOffset(inputInfo.valueVec2)
			else
				self.view.menu:SetWheelOffset(Vector2(0, 0))
			end
		end
	end

	self.view.hotKeyContent:SetHotKeyPaths(actionPath)

	local zoomInBindPath = "Hud/GamepadZoomIn"

	self.zoomInBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.menu.gameObject, "zoomInBind")
	self.zoomInBind.actionPath = zoomInBindPath
	self.zoomInBind.isVirtual = true

	function self.zoomInBind.luaTrigger(inputInfo)
		self:handleGamepadZoomIn(inputInfo)
	end

	self.view.zoomInHotKey:SetHotKeyPaths(zoomInBindPath)

	local zoomOutBindPath = "Hud/GamepadZoomOut"

	self.zoomOutBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.menu.gameObject, "zoomOutBind")
	self.zoomOutBind.actionPath = zoomOutBindPath
	self.zoomOutBind.isVirtual = true

	function self.zoomOutBind.luaTrigger(inputInfo)
		self:handleGamepadZoomOut(inputInfo)
	end

	self.view.zoomOutHotKey:SetHotKeyPaths(zoomOutBindPath)

	self.view.menu.areaNum = MENU_ITEM_NUM

	function self.view.menu.onLuaWheelIndexChange(index)
		self:refreshMenu()
		pg.game.audio:triggerEvent(AudioConst.EVENT_GAMEPAD_MENU_SELECTED_CHANGED)
	end

	function self.view.menu.onLuaWheelSelect(selectIndex)
		self:selectItem(selectIndex + 1)
	end

	ClientTextUtils.setText(self.view.funcName, "")
end

function GamepadMenuCtrl:onOpen(info)
	self:setMenuOpen(self.isOpen)
end

function GamepadMenuCtrl:onHide()
	pg.game.camera:cancelZooming()

	self.zoomingState = ZoomingState.None
end

function GamepadMenuCtrl:handleGamepadZoomIn(inputInfo)
	if inputInfo.phase == "Performed" then
		pg.game.camera:startZoomingIn()

		self.zoomingState = ZoomingState.ZoomingIn
	elseif inputInfo.phase == "Canceled" and self.zoomingState == ZoomingState.ZoomingIn then
		pg.game.camera:cancelZooming()

		self.zoomingState = ZoomingState.None
	end
end

function GamepadMenuCtrl:handleGamepadZoomOut(inputInfo)
	if inputInfo.phase == "Performed" then
		pg.game.camera:startZoomingOut()

		self.zoomingState = ZoomingState.ZoomingOut
	elseif inputInfo.phase == "Canceled" and self.zoomingState == ZoomingState.ZoomingOut then
		pg.game.camera:cancelZooming()

		self.zoomingState = ZoomingState.None
	end
end

function GamepadMenuCtrl:initMenuItems()
	self.menuItems = {}

	for i = 1, MENU_ITEM_NUM do
		local menuItem = self.view.menu.transform:GetChild(i - 1):GetComponent("UButton")

		self.menuItems[i] = menuItem
	end
end

function GamepadMenuCtrl:getExcludeResetInputActions()
	return {
		"Hud/GamepadMenu"
	}
end

function GamepadMenuCtrl:refreshMenu()
	self.listData = SysConfigData.defaultGamepadMenuList or {}

	local wheelIndex = self.view.menu.wheelIndex + 1

	for i, menuItem in ipairs(self.menuItems) do
		local menuItemKey = self.listData[i]
		local isUnLock = pg.me:checkFunctionUnlock(menuItemKey) and CommonSwitch[menuItemKey] ~= false
		local menuItemInfo

		if menuItemKey then
			menuItemInfo = GamepadMenuItemData[menuItemKey]
		end

		if menuItemInfo then
			menuItem.customData = menuItemKey

			local icon = menuItem:Find("Item/Icon"):GetComponent("UImage")
			local name = menuItem:Find("Sel/GreenPoint/Bg/Text"):GetComponent("UBaseText")

			if isUnLock then
				ClientTextUtils.setText(name, pg.getLocalizationText(menuItemInfo.name))

				icon.url = menuItemInfo.icon or ""
			else
				ClientTextUtils.setText(name, "")

				icon.url = AddressDataConst.GAMEPAD_MENU_EMPTY_ICON
			end

			if i == wheelIndex then
				menuItem:TryChangePage("State", 2)
			else
				menuItem:TryChangePage("State", isUnLock and 1 or 0)
			end

			if menuItemInfo.disable or not isUnLock then
				menuItem:TryChangePage("disable", 1)
			else
				menuItem:TryChangePage("disable", 0)
			end
		else
			menuItem.customData = ""

			menuItem:TryChangePage("State", 0)
			menuItem:TryChangePage("disable", 1)
		end
	end
end

function GamepadMenuCtrl:selectItem(wheelIndex)
	local selectItem = self.menuItems[wheelIndex]
	local menuItemType = selectItem.customData
	local selectItemInfo = GamepadMenuItemData[selectItem.customData] or {}

	if not selectItemInfo.disable then
		local funcId = Const.FUNCTION_IDS[menuItemType]
		local isUnLock = pg.me:checkFunctionUnlock(menuItemType) and CommonSwitch[menuItemType] ~= false

		if not isUnLock then
			if FuncIdConfigData[menuItemType] and FuncIdConfigData[menuItemType].unlockDesc then
				local tipText = pg.getLocalizationText(FuncIdConfigData[menuItemType].unlockDesc)

				pg.global.ui.tips:showTextTip(tipText)
			end

			return
		end

		if LuaUIUtils.checkFuncForbidden(funcId) then
			pg.global.ui.tips:showTextTip(pg.getGameString("FUNCTION_CANT_STATE"))

			return
		end

		if menuItemType == MenuItemType.Photo then
			pg.global.ui.hudV2:openPhotoPanel()
		elseif menuItemType == MenuItemType.Quest then
			pg.global.ui.hudV2:openQuest()
		elseif menuItemType == MenuItemType.PetBook then
			pg.global.ui.hudV2:openPetResearch()
		elseif menuItemType == MenuItemType.Bag then
			pg.global.ui.inventory:open()
		elseif menuItemType == MenuItemType.Config then
			pg.global.ui:open(UIConst.UI_ID_SETTING)
		elseif menuItemType == MenuItemType.Help then
			pg.global.ui:open(UIConst.UI_ID_HELP)
		elseif menuItemType == MenuItemType.PetBall then
			pg.global.ui.hudV2:openPetBall()
		elseif menuItemType == MenuItemType.PetEntry then
			pg.global.ui.hudV2:openPetPanel()
		elseif menuItemType == MenuItemType.Map then
			pg.global.ui.hudV2:openMap()
		elseif menuItemType == MenuItemType.PVP then
			pg.global.ui.hudV2:openPvpMenu()
		end
	end

	pg.game.input:temporarilyDisableViewControl()
	self:setMenuOpen(false)
end

function GamepadMenuCtrl:setMenuOpen(isOpen)
	self.isOpen = isOpen

	if not self.view then
		return
	end

	if isOpen then
		self:show()
		self.view.menu:ResetWheel()
		self:refreshMenu()
		self.view.widget:TryChangePage("state", 1)
		pg.game.audio:triggerEvent(AudioConst.EVENT_GAMEPAD_MENU_OPEN)
	else
		self.view.widget:TryChangePage("state", 0)
		self:hide()
	end
end

function GamepadMenuCtrl:switchMenuOpen()
	if not self.view then
		self.isOpen = not self.isOpen

		self:open()
	else
		self:setMenuOpen(not self.isOpen)
	end
end

function GamepadMenuCtrl:tryTriggerSelectItem()
	self.view.menu.realWheelIndex = -1
end

function GamepadMenuCtrl:onInputDeviceChanged(deviceType)
	self:setMenuOpen(false)
end

return GamepadMenuCtrl
