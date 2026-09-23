-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\SettingOperation\\Component\\SettingOperationGamePadComponent.lua

local Class = require("Core.Framework.Class")
local Time = require("Core.Common.Time")
local TimerManager = require("Core.Timer.TimerManager")
local UIComponent = require("Guis.Helper.UIComponent")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local SettingOperationGamePadComponent = Class.LightClass("SettingOperationGamePadComponent", UIComponent)
local GamePadNavigation = require("Utils.GamePadNavigation")
local ClientTextUtils = require("Utils.ClientTextUtils")

SettingOperationGamePadComponent.TRIGGER_DELAY_SLOW = 0.25
SettingOperationGamePadComponent.TRIGGER_DELAY_FAST = 0.15

function SettingOperationGamePadComponent:findObjects()
	self.root = self.view.root
	self.sliderUSlider = self.view.sliderUSlider
	self.consoleKeyUList = self.view.consoleKeyUList
	self.leftTriggerPause = nil
	self.rightTriggerPause = nil
	self.leftTriggerDisableTime = -1
	self.rightTriggerDisableTime = -1
	self.leftTriggerDelay = self.TRIGGER_DELAY_SLOW
	self.rightTriggerDelay = self.TRIGGER_DELAY_SLOW
	self.leftTriggerCount = 0
	self.rightTriggerCount = 0
	self.navigation = GamePadNavigation.new(self)
end

function SettingOperationGamePadComponent:initView()
	self:initPetManagementButtonFun3Event()
	self:initPetManagementButtonFun7Event()
	self:initPetManagementButtonFun8Event()
	self:initConsoleKeys()

	self.tickTimer = self.ctrl:startTimer(function()
		self:startTick()
	end, 0, true)
end

function SettingOperationGamePadComponent:initConsoleKeys()
	local keys = {}

	keys[#keys + 1] = {
		path = {
			"Hud/PetManagementButtonFun7"
		},
		name = pg.getGameString("DEC")
	}
	keys[#keys + 1] = {
		path = {
			"Hud/PetManagementButtonFun8"
		},
		name = pg.getGameString("INC")
	}
	keys[#keys + 1] = {
		path = {
			"Hud/PetManagementButtonFun2"
		},
		name = pg.getGameString("RESTORE_TO_DEFAULT")
	}
	keys[#keys + 1] = {
		path = {
			"Hud/PetManagementButtonFun4"
		},
		name = pg.getGameString("ENSURE")
	}
	keys[#keys + 1] = {
		path = {
			"Hud/PetManagementButtonFun3"
		},
		name = pg.getGameString("BACK_TO_PRE")
	}

	function self.consoleKeyUList.luaRenderItem(button, index, data)
		local objRef = button.transform:GetComponent("ObjectReference")
		local keyHotKeyContent = objRef:GetRefValue("keyHotKeyContent")
		local txtNameUText = objRef:GetRefValue("btnTipsUText")

		keyHotKeyContent:SetHotKeyPaths(data.path)
		ClientTextUtils.setText(txtNameUText, data.name)
	end

	self.consoleKeyUList:SetList(keys)
end

function SettingOperationGamePadComponent:startTick()
	if self.leftTriggerPause == true or self.leftTriggerPause == nil then
		self.leftTriggerCount = 0
	end

	if self.rightTriggerPause == true or self.rightTriggerPause == nil then
		self.rightTriggerCount = 0
	end

	if self.leftTriggerCount >= 3 then
		self.leftTriggerDelay = self.TRIGGER_DELAY_FAST
	else
		self.leftTriggerDelay = self.TRIGGER_DELAY_SLOW
	end

	if self.rightTriggerCount >= 3 then
		self.rightTriggerDelay = self.TRIGGER_DELAY_FAST
	else
		self.rightTriggerDelay = self.TRIGGER_DELAY_SLOW
	end

	if self.leftTriggerPause == false and self.leftTriggerDisableTime <= Time.realSecondCache then
		self.leftTriggerCount = self.leftTriggerCount + 1
		self.sliderUSlider.value = self.sliderUSlider.value - 0.01

		self:temporarilyDisableTime(true)
	end

	if self.rightTriggerPause == false and self.rightTriggerDisableTime <= Time.realSecondCache then
		self.rightTriggerCount = self.rightTriggerCount + 1
		self.sliderUSlider.value = self.sliderUSlider.value + 0.01

		self:temporarilyDisableTime(false)
	end
end

function SettingOperationGamePadComponent:temporarilyDisableTime(isLeft)
	if isLeft == true then
		self.leftTriggerDisableTime = math.max(Time.realSecondCache + self.leftTriggerDelay, self.leftTriggerDisableTime)
	else
		self.rightTriggerDisableTime = math.max(Time.realSecondCache + self.rightTriggerDelay, self.rightTriggerDisableTime)
	end
end

function SettingOperationGamePadComponent:initPetManagementButtonFun3Event()
	local petManagementButtonFun3Binding = KeyBindingPro.GetOrAddKeyBindingByName(self.root.gameObject, "petManagementButtonFun3")

	petManagementButtonFun3Binding.isVirtual = true
	petManagementButtonFun3Binding.actionPath = "Hud/PetManagementButtonFun3"

	function petManagementButtonFun3Binding.luaTrigger(inputInfo)
		TimerManager.removeTimer(self.navigation.longPressTimer)

		if self.navigation.longPressMayPerformed == true then
			return
		end

		if inputInfo.phase == "Performed" then
			self.view.btnCloseUButton.luaClick()
		end
	end
end

function SettingOperationGamePadComponent:initPetManagementButtonFun7Event()
	local petManagementButtonFun7Binding = KeyBindingPro.GetOrAddKeyBindingByName(self.root.gameObject, "petManagementButtonFun7")

	petManagementButtonFun7Binding.isVirtual = true
	petManagementButtonFun7Binding.actionPath = "Hud/PetManagementButtonFun7"

	function petManagementButtonFun7Binding.luaTrigger(inputInfo)
		TimerManager.removeTimer(self.navigation.longPressTimer)

		if self.navigation.longPressMayPerformed == true then
			return
		end

		if inputInfo.phase == "Performed" then
			self.leftTriggerPause = false
		else
			self.leftTriggerPause = true
		end
	end
end

function SettingOperationGamePadComponent:initPetManagementButtonFun8Event()
	local petManagementButtonFun8Binding = KeyBindingPro.GetOrAddKeyBindingByName(self.root.gameObject, "petManagementButtonFun8")

	petManagementButtonFun8Binding.isVirtual = true
	petManagementButtonFun8Binding.actionPath = "Hud/PetManagementButtonFun8"

	function petManagementButtonFun8Binding.luaTrigger(inputInfo)
		TimerManager.removeTimer(self.navigation.longPressTimer)

		if self.navigation.longPressMayPerformed == true then
			return
		end

		if inputInfo.phase == "Performed" then
			self.rightTriggerPause = false
		else
			self.rightTriggerPause = true
		end
	end
end

function SettingOperationGamePadComponent:onDestroy()
	self.root = nil
	self.navigation = nil
	self.leftTriggerPause = nil
	self.rightTriggerPause = nil
	self.leftTriggerDisableTime = -1
	self.rightTriggerDisableTime = -1
	self.leftTriggerDelay = self.TRIGGER_DELAY_SLOW
	self.rightTriggerDelay = self.TRIGGER_DELAY_SLOW
	self.leftTriggerCount = 0
	self.rightTriggerCount = 0

	if self.tickTimer then
		self.ctrl:killTimer(self.tickTimer)
	end

	self.tickTimer = nil

	UIComponent.onDestroy(self)
end

return SettingOperationGamePadComponent
