-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Help\\Component\\HelpGamePadComponent.lua

local Class = require("Core.Framework.Class")
local TimerManager = require("Core.Timer.TimerManager")
local UIComponent = require("Guis.Helper.UIComponent")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local HelpGamePadComponent = Class.LightClass("HelpGamePadComponent", UIComponent)
local GamePadNavigation = require("Utils.GamePadNavigation")
local ClientTextUtils = require("Utils.ClientTextUtils")

function HelpGamePadComponent:findObjects()
	self.root = self.view.root
	self.optionList = self.view.optionList
	self.searchInputField = self.view.searchInputField
	self.consoleKeyUList = self.view.consoleKeyUList
	self.navigation = GamePadNavigation.new(self)

	self:initAreas()
end

function HelpGamePadComponent:initView()
	self:initLeftStickMoveEvent()
	self:initPetManagementButtonFun3Event()
	self:initPetManagementButtonFun4Event()
	self:initPetManagementButtonFun7Event()
	self:initPetManagementButtonFun8Event()
	self:initLeftShoulderEvent()
	self:initRightShoulderEvent()
end

function HelpGamePadComponent:initAreas()
	self.navigation.AREAS = {
		RESEARCH_AREA = 1,
		LIST_AREA = 2
	}
	self.navigation.RESEARCH_AREA = {
		[self.navigation.MOVE_DIRECTION.DOWN] = self.navigation.AREAS.LIST_AREA
	}
	self.navigation.LIST_AREA = {
		[self.navigation.MOVE_DIRECTION.UP] = self.navigation.AREAS.RESEARCH_AREA,
		[self.navigation.MOVE_DIRECTION.DOWN] = self.navigation.AREAS.LIST_AREA
	}
	self.navigation.AREA_TABLES = {
		self.navigation.RESEARCH_AREA,
		self.navigation.LIST_AREA
	}
	self.navigation.cursorArea = self.navigation.AREAS.LIST_AREA
	self.navigation.cursorIndex = {
		x = 1,
		y = 1
	}

	self:researchAreaSupplement()
end

function HelpGamePadComponent:researchAreaSupplement()
	local t = {}

	t[1] = {
		{
			Focus = function(x, y)
				self:baseFocus(t, x, y)
				self:deSelectAll()
				self.searchInputField:TryChangePage("GamePadFocus", 1)
			end,
			Fun4 = function(x, y)
				self.searchInputField:ActivateInputField()
			end,
			Fun4Name = pg.getGameString("INPUT"),
			Fun3 = function(x, y)
				if self.searchInputField.allowInput == true then
					self.searchInputField:DeactivateInputField()
				else
					self.ctrl:dismiss()
				end
			end,
			Fun3Name = pg.getGameString("BACK_TO_PRE")
		}
	}

	self.navigation:initAreaTableSlots(self.navigation.RESEARCH_AREA, t)
end

function HelpGamePadComponent:initLeftStickMoveEvent()
	local leftStickMoveBinding = KeyBindingPro.GetOrAddKeyBindingByName(self.root.gameObject, "leftStickMove")

	leftStickMoveBinding.isVirtual = true
	leftStickMoveBinding.actionPath = "Hud/LeftStickMove"

	function leftStickMoveBinding.luaTrigger(inputInfo)
		self.navigation.tickPause = inputInfo.phase ~= "Performed"
		self.navigation.leftStickMoveVec2X = inputInfo.valueVec2.x
		self.navigation.leftStickMoveVec2Y = inputInfo.valueVec2.y
	end
end

function HelpGamePadComponent:initPetManagementButtonFun3Event()
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

function HelpGamePadComponent:initPetManagementButtonFun4Event()
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

function HelpGamePadComponent:initPetManagementButtonFun7Event()
	local petManagementButtonFun7Binding = KeyBindingPro.GetOrAddKeyBindingByName(self.root.gameObject, "petManagementButtonFun7")

	petManagementButtonFun7Binding.isVirtual = true
	petManagementButtonFun7Binding.actionPath = "Hud/PetManagementButtonFun7"

	function petManagementButtonFun7Binding.luaTrigger(inputInfo)
		TimerManager.removeTimer(self.navigation.longPressTimer)

		if self.navigation.longPressMayPerformed == true then
			return
		end

		if inputInfo.phase == "Canceled" then
			local curSlot = self.navigation:getCurSlot()

			if curSlot ~= nil and curSlot.Fun7 ~= nil then
				curSlot.Fun7(self.navigation.cursorIndex.x, self.navigation.cursorIndex.y)
			end
		end
	end
end

function HelpGamePadComponent:initPetManagementButtonFun8Event()
	local petManagementButtonFun8Binding = KeyBindingPro.GetOrAddKeyBindingByName(self.root.gameObject, "petManagementButtonFun8")

	petManagementButtonFun8Binding.isVirtual = true
	petManagementButtonFun8Binding.actionPath = "Hud/PetManagementButtonFun8"

	function petManagementButtonFun8Binding.luaTrigger(inputInfo)
		TimerManager.removeTimer(self.navigation.longPressTimer)

		if self.navigation.longPressMayPerformed == true then
			return
		end

		if inputInfo.phase == "Canceled" then
			local curSlot = self.navigation:getCurSlot()

			if curSlot ~= nil and curSlot.Fun8 ~= nil then
				curSlot.Fun8(self.navigation.cursorIndex.x, self.navigation.cursorIndex.y)
			end
		end
	end
end

function HelpGamePadComponent:initLeftShoulderEvent()
	local leftShoulderBinding = KeyBindingPro.GetOrAddKeyBindingByName(self.root.gameObject, "leftShoulder")

	leftShoulderBinding.isVirtual = true
	leftShoulderBinding.priority = 1
	leftShoulderBinding.actionPath = "Hud/LeftShoulder"

	function leftShoulderBinding.luaTrigger(inputInfo)
		TimerManager.removeTimer(self.navigation.longPressTimer)

		if self.navigation.longPressMayPerformed == true then
			return
		end

		if inputInfo.phase == "Performed" then
			self.ctrl:continueSwitchPages(false)
		end
	end
end

function HelpGamePadComponent:initRightShoulderEvent()
	local rightShoulderBinding = KeyBindingPro.GetOrAddKeyBindingByName(self.root.gameObject, "rightShoulder")

	rightShoulderBinding.isVirtual = true
	rightShoulderBinding.priority = 1
	rightShoulderBinding.actionPath = "Hud/RightShoulder"

	function rightShoulderBinding.luaTrigger(inputInfo)
		TimerManager.removeTimer(self.navigation.longPressTimer)

		if self.navigation.longPressMayPerformed == true then
			return
		end

		if inputInfo.phase == "Performed" then
			self.ctrl:continueSwitchPages(true)
		end
	end
end

function HelpGamePadComponent:deSelectLists()
	local btns = self.optionList:GetAllButtons()

	for i = 0, btns.Length - 1 do
		btns[i]:TryChangePage("button", 0)
	end
end

function HelpGamePadComponent:deSelectOthers()
	self.searchInputField:TryChangePage("GamePadFocus", 0)
	self.searchInputField:DeactivateInputField()
end

function HelpGamePadComponent:deSelectAll()
	self:deSelectLists()
	self:deSelectOthers()
end

function HelpGamePadComponent:deHoverAll()
	return
end

function HelpGamePadComponent:baseFocus(t, x, y)
	if t == nil or t[x] == nil or t[x][y] == nil then
		self:clearKeyHints()

		return
	end

	local keys = {}

	if t[x][y].Fun7 ~= nil and t[x][y].Fun7Name ~= nil then
		keys[#keys + 1] = {
			path = {
				"Hud/PetManagementButtonFun7"
			},
			name = t[x][y].Fun7Name
		}
	end

	if t[x][y].Fun8 ~= nil and t[x][y].Fun8Name ~= nil then
		keys[#keys + 1] = {
			path = {
				"Hud/PetManagementButtonFun8"
			},
			name = t[x][y].Fun8Name
		}
	end

	if t[x][y].Fun4 ~= nil and t[x][y].Fun4Name ~= nil then
		keys[#keys + 1] = {
			path = {
				"Hud/PetManagementButtonFun4"
			},
			name = t[x][y].Fun4Name
		}
	end

	if t[x][y].Fun3 ~= nil and t[x][y].Fun3Name ~= nil then
		keys[#keys + 1] = {
			path = {
				"Hud/PetManagementButtonFun3"
			},
			name = t[x][y].Fun3Name
		}
	end

	function self.consoleKeyUList.luaRenderItem(button, index, data)
		local objRef = button.transform:GetComponent("ObjectReference")
		local keyHotKeyContent = objRef:GetRefValue("keyHotKeyContent")
		local txtNameUText = objRef:GetRefValue("btnTipsUText")

		keyHotKeyContent:SetHotKeyPaths(data.path)
		ClientTextUtils.setText(txtNameUText, data.name)
	end

	self.consoleKeyUList:SetList(keys)
	pg.game.audio:triggerEvent("ui_click_common")
end

function HelpGamePadComponent:clearKeyHints()
	self.consoleKeyUList:SetList(nil)
end

function HelpGamePadComponent:onInputDeviceChanged(deviceType)
	if pg.game.input:isUsingGamepad() then
		self.navigation:specificSet(self.navigation.AREAS.RESEARCH_AREA, 1, 1)
		self.navigation:reFocus()
	else
		self:deSelectAll()
	end
end

function HelpGamePadComponent:onDestroy()
	self.root = nil
	self.optionList = nil
	self.searchInputField = nil
	self.navigation = nil

	UIComponent.onDestroy(self)
end

return HelpGamePadComponent
