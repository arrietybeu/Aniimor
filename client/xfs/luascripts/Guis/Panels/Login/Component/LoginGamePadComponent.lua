-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Login\\Component\\LoginGamePadComponent.lua

local Class = require("Core.Framework.Class")
local TimerManager = require("Core.Timer.TimerManager")
local UIComponent = require("Guis.Helper.UIComponent")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local LoginGamePadComponent = Class.LightClass("LoginGamePadComponent", UIComponent)
local GamePadNavigation = require("Utils.GamePadNavigation")
local ClientUtils = require("Utils.ClientUtils")

function LoginGamePadComponent:findObjects()
	self.root = self.view.root
	self.inputFieldGamePadFocus = self.view.inputFieldGamePadFocus
	self.serverSelectGamePadFocus = self.view.serverSelectGamePadFocus
	self.startGameGamePadFocus = self.view.startGameGamePadFocus
	self.inputField = self.view.inputField
	self.btnAccount = self.view.accountBtn
	self.accountComp = self.ctrl.loginAccountComponent
	self.navigation = GamePadNavigation.new(self)

	self:initAreas()
end

function LoginGamePadComponent:initView()
	self:initLeftStickMoveEvent()
	self:initPetManagementButtonFun3Event()
	self:initPetManagementButtonFun4Event()
	self.navigation:focusReset(self.navigation.AREAS.MAIN_AREA)
end

function LoginGamePadComponent:initAreas()
	self.navigation.AREAS = {
		ACCOUNT_AREA = 3,
		SERVER_LIST_AREA = 2,
		MAIN_AREA = 1
	}
	self.navigation.MAIN_AREA = {
		[self.navigation.MOVE_DIRECTION.UP] = self.navigation.AREAS.MAIN_AREA,
		[self.navigation.MOVE_DIRECTION.DOWN] = self.navigation.AREAS.MAIN_AREA
	}
	self.navigation.SERVER_LIST_AREA = {}
	self.navigation.ACCOUNT_AREA = {
		[self.navigation.MOVE_DIRECTION.UP] = self.navigation.AREAS.ACCOUNT_AREA,
		[self.navigation.MOVE_DIRECTION.DOWN] = self.navigation.AREAS.ACCOUNT_AREA
	}
	self.navigation.AREA_TABLES = {
		self.navigation.MAIN_AREA,
		self.navigation.SERVER_LIST_AREA,
		self.navigation.ACCOUNT_AREA
	}
	self.navigation.cursorArea = self.navigation.AREAS.MAIN_AREA
	self.navigation.cursorIndex = {
		y = 1,
		x = 1
	}

	self:mainAreaSupplement()
	self:serverListAreaSupplement()
	self:accountAreaSupplement()
end

function LoginGamePadComponent:mainAreaSupplement()
	local t = {}
	local idx = 1

	if ClientConfigDebugHideAccount ~= true then
		t[idx] = {
			{
				Focus = function(x, y)
					self:deSelectAll()
					self.inputFieldGamePadFocus:TryChangePage("GamePadFocus", 1)
				end,
				Fun4 = function(x, y)
					self.inputField:ActivateInputField()
				end,
				Fun3 = function(x, y)
					self.inputField:DeactivateInputField()
				end
			}
		}
		idx = idx + 1
		t[idx] = {
			{
				Focus = function(x, y)
					self:deSelectAll()
					self.serverSelectGamePadFocus:TryChangePage("GamePadFocus", 1)
				end,
				Fun4 = function(x, y)
					self.view.serverSelectUButton.luaClick()
					self.navigation:focusReset(self.navigation.AREAS.SERVER_LIST_AREA)
				end
			}
		}
		idx = idx + 1
	end

	t[idx] = {
		{
			Focus = function(x, y)
				self:deSelectAll()
				self.startGameGamePadFocus:TryChangePage("GamePadFocus", 1)
			end,
			Fun4 = function(x, y)
				self.view.button.luaClick()
			end
		}
	}
	t[idx + 1] = {
		{
			Focus = function(x, y)
				self:deSelectAll()
				self.btnAccount:TryChangePage("GamePadFocus", 1)
			end,
			Fun4 = function(x, y)
				self.accountComp.view.accountBtn.luaClick()
				self.root:TryChangePage("Account", 1)
				self.navigation:focusReset(self.navigation.AREAS.ACCOUNT_AREA)
			end
		}
	}

	self.navigation:initAreaTableSlots(self.navigation.MAIN_AREA, t)
end

function LoginGamePadComponent:serverListAreaSupplement()
	local t = {}

	t[1] = {
		{
			Focus = function(x, y)
				self:deSelectAll()
			end,
			Fun3 = function(x, y)
				self.view.rootUComponent:TryChangePage("server", "close")
				self.navigation:specificSet(self.navigation.AREAS.MAIN_AREA, 2, 1)
				self.navigation:reFocus()
			end
		}
	}

	self.navigation:initAreaTableSlots(self.navigation.SERVER_LIST_AREA, t)
end

function LoginGamePadComponent:accountAreaSupplement()
	local t = {}

	t[1] = {
		{
			Focus = function(x, y)
				self:deSelectAll()
				self.accountComp.randomUButton:GetComponent("UComponent"):TryChangePage("GamePadFocus", 1)
			end,
			Fun4 = function(x, y)
				self.accountComp.randomUButton.luaClick()
			end
		}
	}
	t[2] = {
		{
			Focus = function(x, y)
				self:deSelectAll()
				self.accountComp.cancelUButton:GetComponent("UComponent"):TryChangePage("GamePadFocus", 1)
			end,
			Fun4 = function(x, y)
				self.accountComp.cancelUButton.luaClick()
				self.navigation:focusReset(self.navigation.AREAS.MAIN_AREA)
			end
		}
	}
	t[3] = {
		{
			Focus = function(x, y)
				self:deSelectAll()
				self.accountComp.confirmUButton:GetComponent("UComponent"):TryChangePage("GamePadFocus", 1)
			end,
			Fun4 = function(x, y)
				local text = string.trim(self.accountComp.nameUInputField.text)

				if text == nil or text == "" then
					ClientUtils.showBubbleMessageRaw(pg.getGameString("USER_NAME_EMPTY"), 3)

					return
				end

				self.accountComp.confirmUButton.luaClick()
				self.navigation:specificSet(self.navigation.AREAS.MAIN_AREA, 1, 1)
				self.navigation:reFocus()
			end
		}
	}

	self.navigation:initAreaTableSlots(self.navigation.ACCOUNT_AREA, t)
end

function LoginGamePadComponent:initLeftStickMoveEvent()
	local leftStickMoveBinding = KeyBindingPro.GetOrAddKeyBindingByName(self.root.gameObject, "leftStickMove")

	leftStickMoveBinding.isVirtual = true
	leftStickMoveBinding.actionPath = "Hud/LeftStickMove"

	function leftStickMoveBinding.luaTrigger(inputInfo)
		self.navigation.tickPause = inputInfo.phase ~= "Performed"
		self.navigation.leftStickMoveVec2X = inputInfo.valueVec2.x
		self.navigation.leftStickMoveVec2Y = inputInfo.valueVec2.y
	end
end

function LoginGamePadComponent:initPetManagementButtonFun3Event()
	local petManagementButtonFun3Binding = KeyBindingPro.GetOrAddKeyBindingByName(self.root.gameObject, "petManagementButtonFun3")

	petManagementButtonFun3Binding.isVirtual = true
	petManagementButtonFun3Binding.actionPath = "Hud/PetManagementButtonFun3"

	function petManagementButtonFun3Binding.luaTrigger(inputInfo)
		TimerManager.removeTimer(self.navigation.longPressTimer)

		if self.navigation.longPressMayPerformed == true then
			return
		end

		if inputInfo.phase == "Canceled" then
			local curSlot = self.navigation:getCurSlot()

			if curSlot ~= nil and curSlot.Fun3 ~= nil then
				curSlot.Fun3(self.navigation.cursorIndex.x, self.navigation.cursorIndex.y)
			end
		end
	end
end

function LoginGamePadComponent:initPetManagementButtonFun4Event()
	local petManagementButtonFun4Binding = KeyBindingPro.GetOrAddKeyBindingByName(self.root.gameObject, "petManagementButtonFun4")

	petManagementButtonFun4Binding.isVirtual = true
	petManagementButtonFun4Binding.actionPath = "Hud/PetManagementButtonFun4"

	function petManagementButtonFun4Binding.luaTrigger(inputInfo)
		TimerManager.removeTimer(self.navigation.longPressTimer)

		if self.navigation.longPressMayPerformed == true then
			return
		end

		if inputInfo.phase == "Canceled" then
			local curSlot = self.navigation:getCurSlot()

			if curSlot ~= nil and curSlot.Fun4 ~= nil then
				curSlot.Fun4(self.navigation.cursorIndex.x, self.navigation.cursorIndex.y)
			end
		end
	end
end

function LoginGamePadComponent:deSelectLists()
	return
end

function LoginGamePadComponent:deSelectOthers()
	self.inputFieldGamePadFocus:TryChangePage("GamePadFocus", 0)
	self.serverSelectGamePadFocus:TryChangePage("GamePadFocus", 0)
	self.startGameGamePadFocus:TryChangePage("GamePadFocus", 0)
	self.btnAccount:TryChangePage("GamePadFocus", 0)
	self.inputField:DeactivateInputField()
end

function LoginGamePadComponent:deSelectAll()
	self:deSelectLists()
	self:deSelectOthers()
	self:accountDeSelectAll()
end

function LoginGamePadComponent:accountDeSelectAll()
	self.accountComp.randomUButton:GetComponent("UComponent"):TryChangePage("GamePadFocus", 0)
	self.accountComp.cancelUButton:GetComponent("UComponent"):TryChangePage("GamePadFocus", 0)
	self.accountComp.confirmUButton:GetComponent("UComponent"):TryChangePage("GamePadFocus", 0)
end

function LoginGamePadComponent:deHoverAll()
	return
end

function LoginGamePadComponent:onInputDeviceChanged(deviceType)
	if pg.game.input:isUsingGamepad() then
		self.navigation:focusReset(self.navigation.AREAS.MAIN_AREA)
	else
		self:deSelectAll()
	end
end

function LoginGamePadComponent:onDestroy()
	self.root = nil
	self.inputFieldGamePadFocus = nil
	self.serverSelectGamePadFocus = nil
	self.startGameGamePadFocus = nil
	self.inputField = nil
	self.navigation = nil

	UIComponent.onDestroy(self)
end

return LoginGamePadComponent
