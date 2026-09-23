-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\GamePad\\BaseGamePadComponent.lua

local Class = require("Core.Framework.Class")
local BaseGamePadComponent = Class.LightClass("BaseGamePadComponent")
local GamePadNavigation = require("Guis.GamePad.GamePadNavigation")
local GamePadConst = require("Guis.GamePad.GamePadConst")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local TimerManager = require("Core.Timer.TimerManager")

function BaseGamePadComponent:ctor(uiView)
	self.uiView = uiView
	self.uiViewObject = uiView.gameObject
	self._timers = {}
	self.navigation = GamePadNavigation.new(self)

	self:onCtor()
	self:onRegisterListener()
end

function BaseGamePadComponent:onCtor()
	return
end

function BaseGamePadComponent:initGamePad()
	self:onRegisterKeyEvent()
	self:onBindStaticArea()
end

function BaseGamePadComponent:enableGamePad()
	self:onBindDynamicArea()

	local id = TimerManager.addNextFrameCb(function()
		self:onEnable()
	end)

	self._timers[id] = 1
	id = TimerManager.addSpecificFrameCb(2, false, function()
		self:startUpdate()
	end)
	self._timers[id] = 1
end

function BaseGamePadComponent:disableGamePad()
	if self.timer then
		TimerManager.removeTimer(self.timer)
	end

	self.timer = nil

	self:onDisable()
end

function BaseGamePadComponent:startUpdate()
	if self.timer then
		TimerManager.removeTimer(self.timer)
	end

	self.timer = TimerManager.addRepeatTimer(0.02, function()
		self:update()
	end)
end

function BaseGamePadComponent:update()
	self.navigation:onHandleEvent()
end

function BaseGamePadComponent:onRegisterListener()
	return
end

function BaseGamePadComponent:onRegisterKeyEvent()
	return
end

function BaseGamePadComponent:onBindStaticArea()
	return
end

function BaseGamePadComponent:onBindDynamicArea()
	return
end

function BaseGamePadComponent:onEnable()
	self.navigation:onEnable()
end

function BaseGamePadComponent:onDisable()
	self.navigation:onDisable()
end

function BaseGamePadComponent:addConsoleEvent(keyList)
	for _, fIdx in pairs(keyList) do
		self:addCommonConsoleEvent(fIdx)
	end
end

function BaseGamePadComponent:addCommonConsoleEvent(fIdx)
	local binding = KeyBindingPro.GetOrAddKeyBindingByName(self.uiViewObject, "fun" .. fIdx)

	binding.isVirtual = false
	binding.actionPath = GamePadConst.INDEX_TO_PATH[fIdx]

	function binding.luaTrigger(inputInfo)
		self.navigation:triggerEvent(inputInfo, fIdx)
	end
end

function BaseGamePadComponent:addNewArea(areaId)
	return self.navigation:addNewArea(areaId)
end

function BaseGamePadComponent:getArea(areaId)
	return self.navigation:getArea(areaId)
end

function BaseGamePadComponent:focusImmediate(areaId, x, y)
	self.navigation:focusArea(areaId, x, y)
end

function BaseGamePadComponent:nextFrameFocus(areaId, x, y)
	local id = TimerManager.addNextFrameCb(function()
		self.navigation:focusArea(areaId, x, y)
	end)

	self._timers[id] = 1
end

function BaseGamePadComponent:delayTimeFocus(duration, areaId, x, y)
	local id = TimerManager.addTimer(duration, function()
		self.navigation:focusArea(areaId, x, y)
	end)

	self._timers[id] = 2
end

function BaseGamePadComponent:destroy()
	self:onDestroy()

	for id, kind in pairs(self._timers) do
		if kind == 1 then
			TimerManager.delFrameCb(id)
		else
			TimerManager.removeTimer(id)
		end
	end

	table.clear(self._timers)

	if self.navigation then
		self.navigation:onDestroy()
	end

	self.navigation = nil
	self.uiView = nil
	self.uiViewObject = nil
end

function BaseGamePadComponent:onDestroy()
	return
end

return BaseGamePadComponent
