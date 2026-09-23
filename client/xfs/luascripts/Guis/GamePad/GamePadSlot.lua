-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\GamePad\\GamePadSlot.lua

local Class = require("Core.Framework.Class")
local GamePadConst = require("Guis.GamePad.GamePadConst")
local GamePadSlot = Class.LightClass("GamePadSlot")
local LuaUIUtils = require("Utils.LuaUIUtils")

function GamePadSlot:ctor()
	return
end

function GamePadSlot:initSlot(navigation, x, y)
	self.func_pre_focus = nil
	self.func_focus = nil
	self.func_disFocus = nil
	self.func_funMap = {}
	self._navigation = navigation
	self._uWidget = nil
	self._uList = nil
	self._data = nil
	self._x = x
	self._y = y
	self.emptySlot = false
end

function GamePadSlot:isSameSlot(slot)
	return slot._x == self._x and slot._y == self._y
end

function GamePadSlot:bindOpUIList(uList)
	self._uList = uList

	if IsNil(uList) then
		return
	end

	function uList.luaRenderItem(button, data)
		LuaUIUtils.renderGamePadKey(button, data)
	end
end

function GamePadSlot:bindUWidget(uWidget)
	self._uWidget = uWidget
	self._data = uWidget.dataFromUList or self._data
end

function GamePadSlot:setEmptyState(isEmpty)
	self.emptySlot = isEmpty or false
end

function GamePadSlot:getSlotPos()
	return self._x, self._y
end

function GamePadSlot:setData(data)
	self._data = data or self._data
end

function GamePadSlot:getData()
	return self._data
end

function GamePadSlot:getBindUWidget()
	return self._uWidget
end

function GamePadSlot:setPreFocus(func)
	self.func_pre_focus = func
end

function GamePadSlot:setFocus(func)
	self.func_focus = func
end

function GamePadSlot:setDisFocus(func)
	self.func_disFocus = func
end

function GamePadSlot:setFunc(funcIndex, name, func)
	local func_tb = self.func_funMap[funcIndex] or {}

	func_tb.name = name
	func_tb.func = func
	func_tb.path = {
		GamePadConst.INDEX_TO_PATH[funcIndex]
	}
	self.func_funMap[funcIndex] = func_tb
end

function GamePadSlot:setStartLongPress(funcIndex, onBeginLongPress)
	local func_tb = self.func_funMap[funcIndex]

	if func_tb == nil then
		return
	end

	func_tb.onBeginLongPress = onBeginLongPress
end

function GamePadSlot:setLongPress(funcIndex, onLongPress)
	local func_tb = self.func_funMap[funcIndex]

	if func_tb == nil then
		return
	end

	func_tb.onLongPress = onLongPress
end

function GamePadSlot:setEndLongPress(funcIndex, onEndLongPress)
	local func_tb = self.func_funMap[funcIndex]

	if func_tb == nil then
		return
	end

	func_tb.onEndLongPress = onEndLongPress
end

function GamePadSlot:getFuncList()
	local funcList = {}

	for _, v in pairs(self.func_funMap) do
		funcList[#funcList + 1] = v
	end

	return funcList
end

function GamePadSlot:focusInner()
	self:preFocus()
	self:focus()
end

function GamePadSlot:preFocus()
	if self.func_pre_focus == nil then
		return
	end

	self.func_pre_focus(self._x, self._y)
end

function GamePadSlot:focus()
	if self.func_focus == nil then
		return
	end

	if not IsNil(self._uWidget) then
		self._uWidget:TryChangePage("GamePadFocus", 1)
		self._uWidget:TryChangePage("button", 2)
	end

	if not IsNil(self._uList) then
		local keyList = self:getFuncList()

		self._uList:SetList(keyList)
	end

	self.func_focus(self._x, self._y)
end

function GamePadSlot:disFocus()
	if self.func_disFocus == nil then
		return
	end

	if not IsNil(self._uWidget) then
		self._uWidget:TryChangePage("GamePadFocus", 0)
		self._uWidget:TryChangePage("button", 0)
	end

	self.func_disFocus(self._x, self._y)
end

function GamePadSlot:invokeFunc(funcIdx)
	local funcTb = self.func_funMap[funcIdx]

	if funcTb == nil then
		return
	end

	local func = funcTb.func

	if func == nil then
		return
	end

	local result, cs = xpcall(func, traceback, self._x, self._y)

	if not result then
		traceback(cs)
	end

	pg.game.audio:triggerEvent("ui_click_common")
end

function GamePadSlot:invokeBeginLongPress(funcIdx)
	local funcTb = self.func_funMap[funcIdx]

	if funcTb == nil then
		return
	end

	local func_begin = funcTb.onBeginLongPress

	if func_begin == nil then
		return
	end

	local result, cs = xpcall(func_begin, traceback)

	if not result then
		traceback(cs)
	end
end

function GamePadSlot:invokeLongPress(funcIdx)
	local funcTb = self.func_funMap[funcIdx]

	if funcTb == nil then
		return
	end

	local func_mid = funcTb.onLongPress

	if func_mid == nil then
		return
	end

	local result, cs = xpcall(func_mid, traceback)

	if not result then
		traceback(cs)
	end
end

function GamePadSlot:invokeEndLongPress(funcIdx)
	local funcTb = self.func_funMap[funcIdx]

	if funcTb == nil then
		return
	end

	local func_end = funcTb.onEndLongPress

	if func_end == nil then
		return
	end

	local result, cs = xpcall(func_end, traceback)

	if not result then
		traceback(cs)
	end
end

function GamePadSlot:onClickSimulate()
	if IsNil(self._uWidget) then
		return
	end

	self._uWidget:OnClickSimulate()
end

return GamePadSlot
