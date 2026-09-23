-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HudV2\\BaseComponent\\TemperatureUIComponent.lua

local Class = require("Core.Framework.Class")
local HudBaseComponent = require("Guis.Panels.HudV2.HudBaseComponent")
local TimerManager = require("Core.Timer.TimerManager")
local LuaUIUtils = require("Utils.LuaUIUtils")
local NORMAL_HIDE_DELAY = 2
local SWITCH_HOLD_DURATION = 2
local TEMPERATURE_CHANGE_EPSILON = 0.01
local TEMPERATURE_CONTROLLER = "Temperature"
local SWITCH_CONTROLLER = "Switch"
local SWITCH_FIXED = "Fixed"
local SWITCH_UP = "Up"
local SWITCH_DOWN = "Down"
local ANIM_IN = "VX_Node_Temperature_In"
local ANIM_OUT = "VX_Node_Temperature_Out"
local POINTER_TWEEN_ID = "TemperaturePointerMove"
local POINTER_TWEEN_DURATION = 0.3
local POINTER_TWEEN_EASE = CS.DG.Tweening.Ease.__CastFrom(6)
local POINTER_METER_EXTREME = 135
local POINTER_HALF_RANGE = 72
local TemperatureUIComponent = Class.LightClass("TemperatureUIComponent", HudBaseComponent)
local TEMPERATURE_SEGMENTS = {
	{
		meterMax = -105,
		meterMin = -135,
		tempMax = -40,
		page = "Cold3",
		tempMin = -math.huge
	},
	{
		meterMax = -75,
		meterMin = -105,
		tempMax = -20,
		tempMin = -40,
		page = "Cold2"
	},
	{
		meterMax = -15,
		meterMin = -75,
		tempMax = 0,
		tempMin = -20,
		page = "Cold1"
	},
	{
		meterMax = 15,
		meterMin = -15,
		tempMax = 30,
		tempMin = 0,
		page = "Normal"
	},
	{
		meterMax = 75,
		meterMin = 15,
		tempMax = 60,
		tempMin = 30,
		page = "Hot1"
	},
	{
		meterMax = 105,
		meterMin = 75,
		tempMax = 80,
		tempMin = 60,
		page = "Hot2"
	},
	{
		meterMax = 135,
		meterMin = 105,
		tempMin = 80,
		page = "Hot3",
		tempMax = math.huge
	}
}

TemperatureUIComponent.messages = {}

function TemperatureUIComponent:onCtor()
	self.isViewReady = false
	self.isHidden = true
end

function TemperatureUIComponent:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.pointerRectTransform = objectReference:GetRefValue("pointerRectTransform")
	self.uIAnimation = objectReference:GetRefValue("uIAnimation")
end

function TemperatureUIComponent:initView()
	self.isViewReady = true
	self.isHidden = true

	self:_clearSwitchTimer()

	self.currentTemperature = nil
	self.currentPointerY = nil
	self.currentPage = "Normal"
	self.currentSwitchPage = SWITCH_FIXED

	self.uWidget:TryChangePage(TEMPERATURE_CONTROLLER, "Normal")
	self.uWidget:TryChangePage(SWITCH_CONTROLLER, SWITCH_FIXED)

	if self.uIAnimation then
		UIUtils.PlayAnimation(self.uIAnimation, ANIM_OUT)
	end

	if self.pendingTemperature ~= nil then
		local temperature = self.pendingTemperature

		self.pendingTemperature = nil

		self:_refreshTemperature(temperature)
	end
end

function TemperatureUIComponent:onDestroy()
	self.isViewReady = false
	self.pendingTemperature = nil

	self:_clearHideTimer()
	self:_clearSwitchTimer()

	if self.pointerRectTransform then
		DoTweenAnimMgr.Kill(self.pointerRectTransform.gameObject, LuaUIUtils.TweenId(POINTER_TWEEN_ID), false)
	end

	HudBaseComponent.onDestroy(self)
end

function TemperatureUIComponent:setPointerDegree(temperature)
	temperature = tonumber(temperature)

	if not temperature or temperature ~= temperature then
		return
	end

	if not self.isViewReady then
		self.pendingTemperature = temperature

		return
	end

	self:_refreshTemperature(temperature)
end

function TemperatureUIComponent:_refreshTemperature(temperature)
	local segment, meterValue = self:_getTemperatureDisplayInfo(temperature)
	local pointerY = self:_getPointerYByMeterValue(meterValue)

	self:_updateSwitchPage(temperature)
	self:_tweenPointerY(pointerY)

	if self.currentPage ~= segment.page then
		self.uWidget:TryChangePage(TEMPERATURE_CONTROLLER, segment.page)
	end

	self:_updateNormalVisibility(segment.page)

	self.currentTemperature = temperature
end

function TemperatureUIComponent:_getTemperatureDisplayInfo(temperature)
	local segment = TEMPERATURE_SEGMENTS[#TEMPERATURE_SEGMENTS]

	for _, candidate in ipairs(TEMPERATURE_SEGMENTS) do
		if temperature < candidate.tempMax then
			segment = candidate

			break
		end
	end

	if segment.tempMin == -math.huge then
		return segment, segment.meterMin
	end

	if segment.tempMax == math.huge then
		return segment, segment.meterMax
	end

	local ratio = (temperature - segment.tempMin) / (segment.tempMax - segment.tempMin)
	local meterValue = segment.meterMin + (segment.meterMax - segment.meterMin) * ratio

	return segment, meterValue
end

function TemperatureUIComponent:_updateSwitchPage(temperature)
	if self.currentTemperature == nil then
		return
	end

	local delta = temperature - self.currentTemperature

	if delta > TEMPERATURE_CHANGE_EPSILON then
		self:_changeSwitchPage(SWITCH_UP)
		self:_restartSwitchFixedTimer()
	elseif delta < -TEMPERATURE_CHANGE_EPSILON then
		self:_changeSwitchPage(SWITCH_DOWN)
		self:_restartSwitchFixedTimer()
	end
end

function TemperatureUIComponent:_changeSwitchPage(switchPage)
	if self.currentSwitchPage == switchPage then
		return
	end

	self.uWidget:TryChangePage(SWITCH_CONTROLLER, switchPage)

	self.currentSwitchPage = switchPage
end

function TemperatureUIComponent:_restartSwitchFixedTimer()
	self:_clearSwitchTimer()

	self.switchTimer = TimerManager.addTimer(SWITCH_HOLD_DURATION, function()
		self.switchTimer = nil

		if not self.isViewReady then
			return
		end

		self:_changeSwitchPage(SWITCH_FIXED)
	end)
end

function TemperatureUIComponent:_getPointerYByMeterValue(meterValue)
	local normalizedValue = meterValue / POINTER_METER_EXTREME

	if normalizedValue < -1 then
		normalizedValue = -1
	elseif normalizedValue > 1 then
		normalizedValue = 1
	end

	return normalizedValue * POINTER_HALF_RANGE
end

function TemperatureUIComponent:_applyPointerY(pointerY)
	self.currentPointerY = pointerY

	if self.pointerRectTransform then
		local position = self.pointerRectTransform.anchoredPosition

		self.pointerRectTransform.anchoredPosition = Vector2(position.x, pointerY)
	end
end

function TemperatureUIComponent:_tweenPointerY(targetPointerY)
	if not self.pointerRectTransform then
		self.currentPointerY = targetPointerY

		return
	end

	local fromPointerY = self.currentPointerY

	if fromPointerY == nil then
		self:_applyPointerY(targetPointerY)

		return
	end

	if math.abs(targetPointerY - fromPointerY) < TEMPERATURE_CHANGE_EPSILON then
		self:_applyPointerY(targetPointerY)

		return
	end

	DoTweenAnimMgr.Kill(self.pointerRectTransform.gameObject, LuaUIUtils.TweenId(POINTER_TWEEN_ID), false)
	DoTweenAnimMgr.DoFloat(self.pointerRectTransform.gameObject, fromPointerY, targetPointerY, LuaUIUtils.TweenId(POINTER_TWEEN_ID), POINTER_TWEEN_DURATION, 0, POINTER_TWEEN_EASE, nil, function(value)
		self:_applyPointerY(value)
	end)
end

function TemperatureUIComponent:_updateNormalVisibility(page)
	if page == "Normal" then
		if self.currentPage ~= "Normal" and not self.isHidden then
			self:_clearHideTimer()

			self.hideTimer = TimerManager.addTimer(NORMAL_HIDE_DELAY, function()
				self.hideTimer = nil

				if self.currentPage ~= "Normal" then
					return
				end

				if self.uIAnimation then
					UIUtils.PlayAnimation(self.uIAnimation, ANIM_OUT)
				end

				self.isHidden = true
			end)
		end
	else
		self:_clearHideTimer()

		if self.isHidden then
			self.isHidden = false

			if self.uIAnimation then
				UIUtils.PlayAnimation(self.uIAnimation, ANIM_IN)
			end
		end
	end

	self.currentPage = page
end

function TemperatureUIComponent:_clearHideTimer()
	if self.hideTimer then
		TimerManager.removeTimer(self.hideTimer)

		self.hideTimer = nil
	end
end

function TemperatureUIComponent:_clearSwitchTimer()
	if self.switchTimer then
		TimerManager.removeTimer(self.switchTimer)

		self.switchTimer = nil
	end
end

return TemperatureUIComponent
