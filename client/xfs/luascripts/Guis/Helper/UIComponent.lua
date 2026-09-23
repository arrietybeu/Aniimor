-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Helper\\UIComponent.lua

local ClientUtils = require("Utils.ClientUtils")
local Class = require("Core.Framework.Class")
local UIComponent = Class.LightClass("UIComponent")
local TimerManager = require("Core.Timer.TimerManager")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro

function UIComponent:ctor(ctrl, trans, extInfo)
	self.ctrl = ctrl
	self.model = self.ctrl.model
	self.view = self.ctrl.view
	self.uiComponents = {}
	self.uiComponentsSet = {}
	self._timerIds = {}
	self.hideState = {}
	self._isInit = false
	self.extInfo = extInfo

	self:addToCtrl()

	if trans then
		self.gameObject = trans.gameObject
		self.transform = trans.transform
		self.uWidget = self.transform:GetComponent("UWidget")
	end

	self._visible = self:checkActive(true)

	ClientUtils.tryWithLogError(function()
		self:onCtor(extInfo)

		if not extInfo or not extInfo.needLoadRes then
			self:findObjects()
			self:registerObjects()
			self:initView()
			pg.global.ui:registerComponentMessages(self)
		end
	end)
end

function UIComponent:destroy()
	for _, component in ipairs(self.uiComponents) do
		ClientUtils.tryWithLogErrorEx(component.destroy, component)
	end

	self:killAllTimer()
	ClientUtils.tryWithLogErrorEx(self.onDestroy, self)
	pg.global.ui:unRegisterComponentMessages(self)

	self.uiComponents = {}
	self.hideState = nil
	self.model = nil
	self.view = nil
	self.ctrl = nil
	self.transform = nil
	self.gameObject = nil

	local coms = self.uiComponentsSet

	for k, v in next, self do
		if coms[v] then
			self[v] = nil
		end
	end

	self.uiComponentsSet = {}
end

function UIComponent:onCtor(info)
	return
end

function UIComponent:onDestroy()
	return
end

function UIComponent:setTransform(trans)
	if trans then
		self.gameObject = trans.gameObject
		self.transform = trans
		self.uWidget = self.transform:GetComponent("UWidget")
	end
end

function UIComponent:addToCtrl()
	self.ctrl:addUIComponent(self)
end

function UIComponent:findObjects()
	return
end

function UIComponent:registerObjects()
	return
end

function UIComponent:initView()
	return
end

function UIComponent:onParentShow()
	if self._visible then
		self:showComponent()
	end
end

function UIComponent:onParentHide()
	if self._visible then
		self:hideComponent()
	end
end

function UIComponent:onParentVisibleChange(visible)
	local components = self.uiComponents

	for i = 1, #components do
		components[i]:onParentVisibleChange(visible)
	end

	local onVisibleChangeFunc = self.onVisibleChange

	if onVisibleChangeFunc ~= UIComponent.onVisibleChange then
		ClientUtils.tryWithLogErrorEx(onVisibleChangeFunc, self, visible)
	end
end

function UIComponent:showComponent()
	if not self._visible then
		return
	end

	local components = self.uiComponents

	for i = 1, #components do
		components[i]:onParentShow()
	end

	local onShowFunc = self.onShow

	if onShowFunc ~= UIComponent.onShow then
		ClientUtils.tryWithLogErrorEx(onShowFunc, self)
	end
end

function UIComponent:hideComponent()
	local components = self.uiComponents

	for i = 1, #components do
		components[i]:onParentHide()
	end

	local onHideFunc = self.onHide

	if onHideFunc ~= UIComponent.onHide then
		ClientUtils.tryWithLogErrorEx(onHideFunc, self)
	end
end

function UIComponent:onShow()
	return
end

function UIComponent:onHide()
	return
end

function UIComponent:onVisibleChange(visible)
	return
end

function UIComponent:refreshComponentVisible()
	if self.uWidget and NotNil(self.uWidget) then
		self.uWidget:SetActive(self._visible)
	end
end

function UIComponent:checkUIShow()
	if self.ctrl then
		return self.ctrl:checkUIShow() and self._visible
	end

	return self._visible
end

function UIComponent:hide()
	if self._visible ~= false then
		self._visible = false

		self:refreshComponentVisible()
		self:hideComponent()
	end
end

function UIComponent:show()
	if self._visible ~= true then
		self._visible = true

		self:refreshComponentVisible()

		if self:checkUIShow() then
			self:showComponent()
		end
	end
end

function UIComponent:tryHide(key)
	if key then
		self.hideState[key] = true
	end

	self:hide()
end

function UIComponent:tryShow(key)
	if key then
		self.hideState[key] = false
	end

	local visible = true

	for _, state in pairs(self.hideState) do
		if state then
			visible = false
		end
	end

	if visible then
		self:show()
	end
end

function UIComponent:checkActive(state)
	if NotNil(self.gameObject) then
		return self.gameObject.activeSelf == state
	else
		return false
	end
end

function UIComponent:addUIComponent(component)
	self.uiComponents[#self.uiComponents + 1] = component
	self.uiComponentsSet[component] = true
end

function UIComponent:startFrameTimer(func, frame)
	local frameId = TimerManager.addSpecificFrameCb(frame, false, func)

	return frameId
end

function UIComponent:killFrameTimer(frameId)
	TimerManager.delFrameCb(frameId)
end

function UIComponent:startTimer(func, delay, loop)
	local timerId

	loop = loop or false

	if loop then
		timerId = TimerManager.addRepeatTimer(delay, func)
	else
		timerId = TimerManager.addTimer(delay, func)
	end

	self._timerIds[timerId] = loop

	return timerId
end

function UIComponent:killTimer(timerId)
	if not timerId then
		return
	end

	TimerManager.removeTimer(timerId)

	self._timerIds[timerId] = nil
end

function UIComponent:killAllTimer()
	for timerId, loop in pairs(self._timerIds) do
		TimerManager.removeTimer(timerId)
	end

	self._timerIds = {}
end

function UIComponent:bindHotKey(path, func, longPressFunc, obj, delay)
	obj = obj or self.view.transform.gameObject

	local hotKeyBind = KeyBindingPro.GetOrAddKeyBindingByName(obj, path)

	hotKeyBind.isVirtual = true
	hotKeyBind.priority = -1
	hotKeyBind.actionPath = path

	function hotKeyBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			if longPressFunc then
				if self[path .. "press"] then
					self:killTimer(self[path .. "press"])
				end

				self[path .. "press"] = self:startTimer(longPressFunc, delay or 0.1, true)
			end
		elseif inputInfo.phase == "Canceled" then
			if self[path .. "press"] then
				self:killTimer(self[path .. "press"])
			elseif func then
				func()
			end
		end
	end

	return hotKeyBind
end

return UIComponent
