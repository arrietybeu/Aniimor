-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Setting\\Component\\SettingGamePadComponent.lua

local Class = require("Core.Framework.Class")
local Time = require("Core.Common.Time")
local TimerManager = require("Core.Timer.TimerManager")
local UIComponent = require("Guis.Helper.UIComponent")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local SettingGamePadComponent = Class.LightClass("SettingGamePadComponent", UIComponent)
local GamePadNavigation = require("Utils.GamePadNavigation")

SettingGamePadComponent.TRIGGER_DELAY_SLOW = 0.25
SettingGamePadComponent.TRIGGER_DELAY_FAST = 0.001

function SettingGamePadComponent:findObjects()
	self.root = self.view.root
	self.choiceLabUList = self.view.choiceLabUList
	self.mainLabUList = self.view.mainLabUList
	self.consoleKeyUList = self.view.consoleKeyUList
	self.leftTriggerPause = nil
	self.rightTriggerPause = nil
	self.leftTriggerDisableTime = -1
	self.rightTriggerDisableTime = -1
	self.leftTriggerDelay = self.TRIGGER_DELAY_SLOW
	self.rightTriggerDelay = self.TRIGGER_DELAY_SLOW
	self.leftTriggerCount = 0
	self.rightTriggerCount = 0
	self.rightStickMoveY = 0
	self.navigation = GamePadNavigation.new(self)

	self:initAreas()

	self.mainLabMinY = self.view.mainLabUList:GetComponent("RectTransform").sizeDelta.y
end

function SettingGamePadComponent:initView()
	self:initLeftStickMoveEvent()
	self.navigation:initDPadMoveData(self.root.gameObject)
	self:initRightStickMoveEvent()
	self:initPetManagementButtonFun1Event()
	self:initPetManagementButtonFun2Event()
	self:initPetManagementButtonFun3Event()
	self:initPetManagementButtonFun4Event()
	self:initPetManagementButtonFun7Event()
	self:initPetManagementButtonFun8Event()

	self.tickTimer = self.ctrl:startTimer(function()
		self:startTick()
	end, 0, true)
end

function SettingGamePadComponent:startTick()
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

		local curSlot = self.navigation:getCurSlot()

		if curSlot ~= nil and curSlot.Fun7 ~= nil then
			curSlot.Fun7(self.navigation.cursorIndex.x, self.navigation.cursorIndex.y)
		end

		self:temporarilyDisableTime(true)
	end

	if self.rightTriggerPause == false and self.rightTriggerDisableTime <= Time.realSecondCache then
		self.rightTriggerCount = self.rightTriggerCount + 1

		local curSlot = self.navigation:getCurSlot()

		if curSlot ~= nil and curSlot.Fun8 ~= nil then
			curSlot.Fun8(self.navigation.cursorIndex.x, self.navigation.cursorIndex.y)
		end

		self:temporarilyDisableTime(false)
	end

	if self.rightStickMoveY == 0 then
		return
	end

	local y = math.clamp(self.mainLabUList.content.transform.anchoredPosition.y - self.rightStickMoveY * 20, 0, self.mainLabUList.content:GetComponent("RectTransform").sizeDelta.y - self.mainLabMinY)

	self.mainLabUList.content.transform.anchoredPosition = Vector2(0, y)
end

function SettingGamePadComponent:temporarilyDisableTime(isLeft)
	if isLeft == true then
		self.leftTriggerDisableTime = math.max(Time.realSecondCache + self.leftTriggerDelay, self.leftTriggerDisableTime)
	else
		self.rightTriggerDisableTime = math.max(Time.realSecondCache + self.rightTriggerDelay, self.rightTriggerDisableTime)
	end
end

function SettingGamePadComponent:initAreas()
	self.navigation.AREAS = {
		LANGUAGE_SELECTOR_AREA = 3,
		SUB_AREA = 2,
		MAIN_AREA = 1,
		SCREEN_RESOLUTION_AREA = 5,
		SCREEN_AA_AREA = 6,
		COMMON_SWITCH_AREA = 7,
		SCREEN_MODE_AREA = 4
	}
	self.navigation.MAIN_AREA = {
		[self.navigation.MOVE_DIRECTION.UP] = self.navigation.AREAS.MAIN_AREA,
		[self.navigation.MOVE_DIRECTION.DOWN] = self.navigation.AREAS.MAIN_AREA,
		[self.navigation.MOVE_DIRECTION.RIGHT] = self.navigation.AREAS.SUB_AREA
	}
	self.navigation.SUB_AREA = {
		matchType = self.navigation.MATCH_MODE.MATCH_FIRST,
		[self.navigation.MOVE_DIRECTION.UP] = self.navigation.AREAS.SUB_AREA,
		[self.navigation.MOVE_DIRECTION.DOWN] = self.navigation.AREAS.SUB_AREA,
		[self.navigation.MOVE_DIRECTION.LEFT] = self.navigation.AREAS.MAIN_AREA
	}
	self.navigation.LANGUAGE_SELECTOR_AREA = {
		[self.navigation.MOVE_DIRECTION.UP] = self.navigation.AREAS.LANGUAGE_SELECTOR_AREA,
		[self.navigation.MOVE_DIRECTION.DOWN] = self.navigation.AREAS.LANGUAGE_SELECTOR_AREA
	}
	self.navigation.SCREEN_MODE_AREA = {
		[self.navigation.MOVE_DIRECTION.UP] = self.navigation.AREAS.SCREEN_MODE_AREA,
		[self.navigation.MOVE_DIRECTION.DOWN] = self.navigation.AREAS.SCREEN_MODE_AREA
	}
	self.navigation.SCREEN_RESOLUTION_AREA = {
		[self.navigation.MOVE_DIRECTION.UP] = self.navigation.AREAS.SCREEN_RESOLUTION_AREA,
		[self.navigation.MOVE_DIRECTION.DOWN] = self.navigation.AREAS.SCREEN_RESOLUTION_AREA
	}
	self.navigation.SCREEN_AA_AREA = {
		[self.navigation.MOVE_DIRECTION.UP] = self.navigation.AREAS.SCREEN_AA_AREA,
		[self.navigation.MOVE_DIRECTION.DOWN] = self.navigation.AREAS.SCREEN_AA_AREA
	}
	self.navigation.COMMON_SWITCH_AREA = {
		[self.navigation.MOVE_DIRECTION.UP] = self.navigation.AREAS.COMMON_SWITCH_AREA,
		[self.navigation.MOVE_DIRECTION.DOWN] = self.navigation.AREAS.COMMON_SWITCH_AREA
	}
	self.navigation.AREA_TABLES = {
		self.navigation.MAIN_AREA,
		self.navigation.SUB_AREA,
		self.navigation.LANGUAGE_SELECTOR_AREA,
		self.navigation.SCREEN_MODE_AREA,
		self.navigation.SCREEN_RESOLUTION_AREA,
		self.navigation.SCREEN_AA_AREA,
		self.navigation.COMMON_SWITCH_AREA
	}

	self.navigation:delayFocus(function()
		self.navigation:specificSet(self.navigation.AREAS.MAIN_AREA, 1, 1)
	end, 0.1)
end

function SettingGamePadComponent:initLeftStickMoveEvent()
	local leftStickMoveBinding = KeyBindingPro.GetOrAddKeyBindingByName(self.root.gameObject, "leftStickMove")

	leftStickMoveBinding.isVirtual = true
	leftStickMoveBinding.actionPath = "Hud/LeftStickMove"

	function leftStickMoveBinding.luaTrigger(inputInfo)
		self.navigation.tickPause = inputInfo.phase ~= "Performed"
		self.navigation.leftStickMoveVec2X = inputInfo.valueVec2.x
		self.navigation.leftStickMoveVec2Y = inputInfo.valueVec2.y
	end
end

function SettingGamePadComponent:initRightStickMoveEvent()
	local rightStickMoveBinding = KeyBindingPro.GetOrAddKeyBindingByName(self.root.gameObject, "rightStickMove")

	rightStickMoveBinding.isVirtual = true
	rightStickMoveBinding.actionPath = "Hud/RightStickMove"

	function rightStickMoveBinding.luaTrigger(inputInfo)
		TimerManager.removeTimer(self.navigation.longPressTimer)

		if self.navigation.longPressMayPerformed == true then
			return
		end

		if inputInfo.phase == "Performed" then
			self.rightStickMoveY = inputInfo.valueVec2.y
		else
			self.rightStickMoveY = 0
		end
	end
end

function SettingGamePadComponent:initPetManagementButtonFun1Event()
	local petManagementButtonFun1Binding = KeyBindingPro.GetOrAddKeyBindingByName(self.root.gameObject, "petManagementButtonFun1")

	petManagementButtonFun1Binding.isVirtual = true
	petManagementButtonFun1Binding.actionPath = "Hud/PetManagementButtonFun1"

	function petManagementButtonFun1Binding.luaTrigger(inputInfo)
		TimerManager.removeTimer(self.navigation.longPressTimer)

		if self.navigation.longPressMayPerformed == true then
			return
		end

		if inputInfo.phase == "Canceled" then
			local curSlot = self.navigation:getCurSlot()

			if curSlot ~= nil and curSlot.Fun1 ~= nil then
				curSlot.Fun1(self.navigation.cursorIndex.x, self.navigation.cursorIndex.y)
			end
		end
	end
end

function SettingGamePadComponent:initPetManagementButtonFun2Event()
	local petManagementButtonFun2Binding = KeyBindingPro.GetOrAddKeyBindingByName(self.root.gameObject, "petManagementButtonFun2")

	petManagementButtonFun2Binding.isVirtual = true
	petManagementButtonFun2Binding.actionPath = "Hud/PetManagementButtonFun2"

	function petManagementButtonFun2Binding.luaTrigger(inputInfo)
		TimerManager.removeTimer(self.navigation.longPressTimer)

		if self.navigation.longPressMayPerformed == true then
			return
		end

		if inputInfo.phase == "Canceled" then
			local curSlot = self.navigation:getCurSlot()

			if curSlot ~= nil and curSlot.Fun2 ~= nil then
				curSlot.Fun2(self.navigation.cursorIndex.x, self.navigation.cursorIndex.y)
			end
		end
	end
end

function SettingGamePadComponent:initPetManagementButtonFun3Event()
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

function SettingGamePadComponent:initPetManagementButtonFun4Event()
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

function SettingGamePadComponent:initPetManagementButtonFun7Event()
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

function SettingGamePadComponent:initPetManagementButtonFun8Event()
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

function SettingGamePadComponent:deSelectLists()
	local btns = self.choiceLabUList:GetAllButtons()

	for i = 0, btns.Length - 1 do
		btns[i]:TryChangePage("button", 0)

		btns[i].isSelected = false
	end

	self:deSelectVisualAll()
end

function SettingGamePadComponent:deSelectOthers()
	return
end

function SettingGamePadComponent:deSelectAll()
	self:deSelectLists()
	self:deSelectOthers()
end

function SettingGamePadComponent:deHoverAll()
	return
end

function SettingGamePadComponent:deSelectVisualAll()
	local btns = self.mainLabUList:GetAllButtons()

	for i = 0, btns.Length - 1 do
		local data = btns[i].dataFromUList

		if data.tIndex == 1 then
			btns[i]:TryChangePage("GamePadFocus", 0)

			local objectReference = btns[i].transform:GetComponent("ObjectReference")
			local selectorSortUSelector = objectReference:GetRefValue("selectorSortUSelector")

			if selectorSortUSelector.transform.childCount >= 5 then
				local selectorTrans = selectorSortUSelector.transform:GetChild(4):GetChild(1):Find("View/Content")
				local selectorTransChildCount = selectorTrans.childCount

				for i = 0, selectorTransChildCount - 1 do
					local btn = selectorTrans:GetChild(i):GetComponent("UButton")

					btn:TryChangePage("button", 0)
				end
			end
		elseif data.tIndex == 2 then
			btns[i]:TryChangePage("GamePadFocus", 0)
		elseif data.tIndex == 3 then
			local objectReference = btns[i].transform:GetComponent("ObjectReference")
			local listUList = objectReference:GetRefValue("listUList")
			local buttons = listUList:GetAllButtons()

			for j = 0, buttons.Length - 1 do
				buttons[j]:TryChangePage("button", 0)
				buttons[j]:TryChangePage("GamePadFocus", 0)
			end
		elseif data.tIndex == 5 then
			btns[i]:TryChangePage("GamePadFocus", 0)
		end
	end
end

function SettingGamePadComponent:clearKeyHints()
	self.consoleKeyUList:SetList(nil)
end

function SettingGamePadComponent:onInputDeviceChanged(deviceType)
	if pg.game.input:isUsingGamepad() then
		self.navigation:specificSet(self.navigation.AREAS.MAIN_AREA, 1, 1)
		self.navigation:delayFocus(nil, 0.1)
	else
		self:deSelectVisualAll()
	end
end

function SettingGamePadComponent:onDestroy()
	self.root = nil
	self.choiceLabUList = nil
	self.mainLabUList = nil
	self.consoleKeyUList = nil
	self.navigation = nil
	self.leftTriggerPause = nil
	self.rightTriggerPause = nil
	self.leftTriggerDisableTime = -1
	self.rightTriggerDisableTime = -1
	self.leftTriggerDelay = self.TRIGGER_DELAY_SLOW
	self.rightTriggerDelay = self.TRIGGER_DELAY_SLOW
	self.leftTriggerCount = 0
	self.rightTriggerCount = 0
	self.rightStickMoveY = 0

	if self.tickTimer then
		self.ctrl:killTimer(self.tickTimer)
	end

	self.tickTimer = nil

	UIComponent.onDestroy(self)
end

return SettingGamePadComponent
