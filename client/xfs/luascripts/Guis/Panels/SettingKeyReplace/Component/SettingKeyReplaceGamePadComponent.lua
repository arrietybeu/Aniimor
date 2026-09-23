-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\SettingKeyReplace\\Component\\SettingKeyReplaceGamePadComponent.lua

local Class = require("Core.Framework.Class")
local TimerManager = require("Core.Timer.TimerManager")
local UIComponent = require("Guis.Helper.UIComponent")
local SettingKeyReplaceGamePadComponent = Class.LightClass("SettingKeyReplaceGamePadComponent", UIComponent)
local GamePadNavigation = require("Utils.GamePadNavigation")

function SettingKeyReplaceGamePadComponent:findObjects()
	self.root = self.view.root
	self.keyUList = self.view.keyUList
	self.rightStickMoveY = 0
	self.navigation = GamePadNavigation.new(self)

	self:initAreas()
end

function SettingKeyReplaceGamePadComponent:initView()
	self.navigation:addConsoleEvent(self.navigation:initCommonLeftStickMoveData(self.root.gameObject))
	self.navigation:initDPadMoveData(self.root.gameObject)
	self.navigation:addConsoleEvent(self:initRightStickMoveData())
	self.navigation:addConsoleEvent(self.navigation:initCommonKeyData("Y", self.root.gameObject))
	self.navigation:addConsoleEvent(self.navigation:initCommonKeyData("B", self.root.gameObject))
	self.navigation:addConsoleEvent(self.navigation:initCommonKeyData("A", self.root.gameObject))

	self.tickTimer = self.ctrl:startTimer(function()
		self:startTick()
	end, 0, true)
end

function SettingKeyReplaceGamePadComponent:initAreas()
	self.navigation.AREAS = {
		KEY_LIST_AREA = 1,
		KEY_LIST_CHOOSE_AREA = 2
	}
	self.navigation.KEY_LIST_AREA = {
		[self.navigation.MOVE_DIRECTION.UP] = self.navigation.AREAS.KEY_LIST_AREA,
		[self.navigation.MOVE_DIRECTION.DOWN] = self.navigation.AREAS.KEY_LIST_AREA,
		[self.navigation.MOVE_DIRECTION.LEFT] = self.navigation.AREAS.KEY_LIST_AREA,
		[self.navigation.MOVE_DIRECTION.RIGHT] = self.navigation.AREAS.KEY_LIST_AREA
	}
	self.navigation.KEY_LIST_CHOOSE_AREA = {
		[self.navigation.MOVE_DIRECTION.UP] = self.navigation.AREAS.KEY_LIST_CHOOSE_AREA,
		[self.navigation.MOVE_DIRECTION.DOWN] = self.navigation.AREAS.KEY_LIST_CHOOSE_AREA
	}
	self.navigation.AREA_TABLES = {
		self.navigation.KEY_LIST_AREA,
		self.navigation.KEY_LIST_CHOOSE_AREA
	}
end

function SettingKeyReplaceGamePadComponent:startTick()
	if self.rightStickMoveY == 0 then
		return
	end

	self.keyUList.content.transform.anchoredPosition = Vector2(0, self.keyUList.content.transform.anchoredPosition.y - self.rightStickMoveY * 20)
end

function SettingKeyReplaceGamePadComponent:initRightStickMoveData()
	return {
		id = "rightStickMove",
		actionPath = "Hud/RightStickMove",
		isVirtual = true,
		parent = self.root.gameObject,
		event = function(inputInfo)
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
	}
end

function SettingKeyReplaceGamePadComponent:deSelectLists()
	local btns = self.keyUList:GetAllButtons()

	for i = 0, btns.Length - 1 do
		if btns[i].dataFromUList.tIndex == 1 then
			local uList = btns[i]:GetChild("List"):GetComponent("UList")
			local childBtns = uList:GetAllButtons()

			for j = 0, childBtns.Length - 1 do
				childBtns[j]:TryChangePage("GamePadFocus", 0)
			end
		end
	end
end

function SettingKeyReplaceGamePadComponent:deSelectSelectors(selector)
	if selector.transform.childCount >= 6 then
		local selectorTrans = selector.transform:GetChild(5):GetChild(1):Find("View/Content")
		local selectorTransChildCount = selectorTrans.childCount

		for i = 0, selectorTransChildCount - 1 do
			local btn = selectorTrans:GetChild(i):GetComponent("UButton")

			btn:TryChangePage("GamePadFocus", 0)
		end
	end
end

function SettingKeyReplaceGamePadComponent:deSelectOthers()
	return
end

function SettingKeyReplaceGamePadComponent:deSelectAll()
	self:deSelectLists()
	self:deSelectOthers()
end

function SettingKeyReplaceGamePadComponent:onInputDeviceChanged(deviceType)
	if pg.game.input:isUsingGamepad() then
		-- block empty
	end
end

function SettingKeyReplaceGamePadComponent:onDestroy()
	self.root = nil
	self.keyUList = nil
	self.rightStickMoveY = 0
	self.navigation = nil

	if self.tickTimer then
		self.ctrl:killTimer(self.tickTimer)
	end

	self.tickTimer = nil

	UIComponent.onDestroy(self)
end

return SettingKeyReplaceGamePadComponent
