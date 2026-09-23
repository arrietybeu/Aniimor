-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CommonUseConfirm\\Component\\CommonUseConfirmGamePadComponent.lua

local Class = require("Core.Framework.Class")
local TimerManager = require("Core.Timer.TimerManager")
local UIComponent = require("Guis.Helper.UIComponent")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local CommonUseConfirmGamePadComponent = Class.LightClass("CommonUseConfirmGamePadComponent", UIComponent)
local GamePadNavigation = require("Utils.GamePadNavigation")

function CommonUseConfirmGamePadComponent:findObjects()
	self.root = self.view.root
	self.iPropList = self.view.iPropList
	self.navigation = GamePadNavigation.new(self)

	self:initAreas()
end

function CommonUseConfirmGamePadComponent:initView()
	self:initLeftStickMoveEvent()
	self:initPetManagementButtonFun6Event()
	TimerManager.addTimer(0.1, function()
		self.navigation:focusReset(self.navigation.AREAS.LIST_AREA)
	end)
end

function CommonUseConfirmGamePadComponent:initAreas()
	self.navigation.AREAS = {
		LIST_AREA = 1
	}
	self.navigation.LIST_AREA = {
		[self.navigation.MOVE_DIRECTION.UP] = self.navigation.AREAS.LIST_AREA,
		[self.navigation.MOVE_DIRECTION.DOWN] = self.navigation.AREAS.LIST_AREA,
		[self.navigation.MOVE_DIRECTION.LEFT] = self.navigation.AREAS.LIST_AREA,
		[self.navigation.MOVE_DIRECTION.RIGHT] = self.navigation.AREAS.LIST_AREA
	}
	self.navigation.AREA_TABLES = {
		self.navigation.LIST_AREA
	}
	self.navigation.cursorArea = self.navigation.AREAS.LIST_AREA
	self.navigation.cursorIndex = {
		x = 1,
		y = 1
	}
end

function CommonUseConfirmGamePadComponent:initLeftStickMoveEvent()
	local leftStickMoveBinding = KeyBindingPro.GetOrAddKeyBindingByName(self.root.gameObject, "leftStickMove")

	leftStickMoveBinding.isVirtual = true
	leftStickMoveBinding.actionPath = "Hud/LeftStickMove"

	function leftStickMoveBinding.luaTrigger(inputInfo)
		self.navigation.tickPause = inputInfo.phase ~= "Performed"
		self.navigation.leftStickMoveVec2X = inputInfo.valueVec2.x
		self.navigation.leftStickMoveVec2Y = inputInfo.valueVec2.y
	end
end

function CommonUseConfirmGamePadComponent:initPetManagementButtonFun6Event()
	local petManagementButtonFun6Binding = KeyBindingPro.GetOrAddKeyBindingByName(self.root.gameObject, "petManagementButtonFun6")

	petManagementButtonFun6Binding.isVirtual = true
	petManagementButtonFun6Binding.actionPath = "Hud/PetManagementButtonFun6"

	function petManagementButtonFun6Binding.luaTrigger(inputInfo)
		TimerManager.removeTimer(self.navigation.longPressTimer)

		if self.navigation.longPressMayPerformed == true then
			return
		end

		if inputInfo.phase == "Canceled" then
			local curSlot = self.navigation:getCurSlot()

			if curSlot ~= nil and curSlot.Fun6 ~= nil then
				curSlot.Fun6(self.navigation.cursorIndex.x, self.navigation.cursorIndex.y)
			end
		end
	end
end

function CommonUseConfirmGamePadComponent:deSelectLists()
	local buttons = self.iPropList:GetAllButtons()

	for i = 0, buttons.Length - 1 do
		buttons[i]:TryChangePage("JoyStickFocus", 0)
	end
end

function CommonUseConfirmGamePadComponent:deSelectOthers()
	return
end

function CommonUseConfirmGamePadComponent:deSelectAll()
	self:deSelectLists()
	self:deSelectOthers()
end

function CommonUseConfirmGamePadComponent:deHoverAll()
	return
end

function CommonUseConfirmGamePadComponent:onInputDeviceChanged(deviceType)
	if pg.game.input:isUsingGamepad() then
		self.navigation:focusReset(self.navigation.AREAS.LIST_AREA)
	else
		self:deSelectAll()
		self.ctrl:closeCommonItemTip()
	end
end

function CommonUseConfirmGamePadComponent:onDestroy()
	self.root = nil
	self.iPropList = nil

	UIComponent.onDestroy(self)
end

return CommonUseConfirmGamePadComponent
