-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\GamePadNavigation.lua

local Time = require("Core.Common.Time")
local Class = require("Core.Framework.Class")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local TimerManager = require("Core.Timer.TimerManager")
local UIComponent = require("Guis.Helper.UIComponent")
local HotkeyConst = require("Const.HotkeyConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local UIConst = require("Const.UIConst")
local GamePadConst = require("Guis.GamePad.GamePadConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local GamePadNavigation = Class.LightClass("GamePadNavigation", UIComponent)

GamePadNavigation.LEFT_STICK_MOVE_THRESHOLD = 0.6
GamePadNavigation.FUNCTION_INDEX = {
	RIGHT_STICK = 18,
	LEFT_STICK = 17,
	START = 16,
	SELECT = 15,
	RIGHT = 14,
	LEFT = 13,
	DOWN = 12,
	UP = 11,
	RSD = 10,
	LSD = 9,
	RT = 8,
	LT = 7,
	RS = 6,
	LS = 5,
	A = 4,
	B = 3,
	Y = 2,
	X = 1
}
GamePadNavigation.MOVE_DIRECTION = {
	NONE = 0,
	RIGHT = -4,
	LEFT = -3,
	DOWN = -2,
	UP = -1
}
GamePadNavigation.MATCH_MODE = {
	MATCH_OLD_CACHE = 3,
	MATCH_FIRST = 2,
	MATCH_DIRECTION = 1
}
GamePadNavigation.LEFT_STICK_MOVE_DELAY_SLOW = 0.25
GamePadNavigation.LEFT_STICK_MOVE_DELAY_FAST = 0.15

function GamePadNavigation:findObjects()
	self.cursorArea = nil
	self.cursorIndex = nil
	self.tickTimer = nil
	self.tickPause = nil
	self.rightTickPause = nil
	self.stickMoveDisableTime = -1
	self.leftStickContinueMoveDelay = GamePadConst.LEFT_STICK_MOVE_DELAY_SLOW
	self.leftStickMoveCount = 0
	self.leftStickMoveVec2X = nil
	self.leftStickMoveVec2Y = nil
	self.rightStickMoveVec2X = nil
	self.rightStickMoveVec2Y = nil
	self.longPressMayPerformed = nil
	self.prefabCloneLoader = nil
	self.selectedObj = nil
	self.dropWidget = nil
	self.dropRayBox = nil
	self.hoverWidget = nil
	self.longPressTimer = nil
	self.longPressStart = nil
	self.clonePrefabMoveSpeed = 0.08
	self.longPressDelay = 0.55
	self.dragPrefabHoverCallback = nil
	self.dragPrefabUnHoverCallback = nil
	self.moveOutOfBoundsCustomCallback = nil
	self.cacheAreaIndex = {}
end

function GamePadNavigation:initView()
	self.tickTimer = self.ctrl:startTimer(function()
		self:startTick()
	end, 0, true)
end

function GamePadNavigation:startTick()
	if self.cursorArea == nil or self.cursorIndex == nil then
		return
	end

	self:handleLeftStickEvent()
	self:handleRightStickEvent()
end

function GamePadNavigation:handleLeftStickEvent()
	if self.tickPause == true or self.tickPause == nil then
		self.leftStickMoveCount = 0

		return
	end

	if self.leftStickMoveCount >= 3 then
		self.leftStickContinueMoveDelay = GamePadConst.LEFT_STICK_MOVE_DELAY_FAST
	else
		self.leftStickContinueMoveDelay = GamePadConst.LEFT_STICK_MOVE_DELAY_SLOW
	end

	local moveDirection = GamePadConst.MOVE_DIRECTION.NONE

	if self.longPressMayPerformed == true then
		self:dragSimulationByJoyStick()
	else
		moveDirection = self:handleLeftMove()
	end

	if moveDirection == GamePadConst.MOVE_DIRECTION.NONE then
		self:handleStickFunc(GamePadConst.FUNCTION_INDEX.LEFT_STICK)
	end
end

function GamePadNavigation:handleRightStickEvent()
	if self.rightTickPause == true or self.rightTickPause == nil then
		return
	end

	self:handleStickFunc(GamePadConst.FUNCTION_INDEX.RIGHT_STICK)
end

function GamePadNavigation:handleLeftMove()
	local moveDirection = GamePadConst.MOVE_DIRECTION.NONE

	if self.stickMoveDisableTime > Time.realSecondCache then
		return moveDirection
	end

	moveDirection = self:checkMoveDirection(self.leftStickMoveVec2X, self.leftStickMoveVec2Y)

	self:moveOperation(moveDirection)

	self.leftStickMoveCount = self.leftStickMoveCount + 1

	self:temporarilyDisableTime()

	return moveDirection
end

function GamePadNavigation:dragSimulationByJoyStick()
	if self.longPressStart == true and self.prefabCloneLoader ~= nil and self.prefabCloneLoader.obj ~= nil then
		local pos = self.prefabCloneLoader.obj.transform.position
		local x, y = self:ConstraintInScreenSpace(pos.x + self.leftStickMoveVec2X * self.clonePrefabMoveSpeed, pos.y + self.leftStickMoveVec2Y * self.clonePrefabMoveSpeed)

		self.prefabCloneLoader.obj.transform.position = Vector3(x, y, pos.z)

		local screenPos = UIUtils.WorldToScreenPoint(self.prefabCloneLoader.obj.transform.position)
		local overUI = pg.global.uiMgr:GetOverUI(screenPos, 0)

		self.dropWidget = self:getValidUComponent(overUI)
		self.dropRayBox = overUI ~= nil and overUI:GetComponent("UWidget") or nil

		if self.hoverWidget ~= self.dropWidget then
			if self.hoverWidget ~= nil and not UIUtils.IsNull(self.hoverWidget) then
				local unHoverBtn = self.hoverWidget.gameObject:GetComponent("UButton")

				if unHoverBtn ~= nil and self.dragPrefabUnHoverCallback ~= nil then
					self.dragPrefabUnHoverCallback(self, unHoverBtn)
				end
			end

			if self.dropWidget ~= nil and not UIUtils.IsNull(self.dropWidget) then
				local hoverBtn = self.dropWidget.gameObject:GetComponent("UButton")

				if hoverBtn ~= nil and self.dragPrefabHoverCallback ~= nil then
					self.dragPrefabHoverCallback(self, hoverBtn)
				end
			end

			self.hoverWidget = self.dropWidget
		end
	end
end

function GamePadNavigation:ConstraintInScreenSpace(x, y)
	local leftBot = UIUtils.GetUICanvasRootCornerScreenPos(0)
	local rightTop = UIUtils.GetUICanvasRootCornerScreenPos(2)
	local newX, newY

	newX = x < leftBot[1] and leftBot[1] or x

	if x < leftBot[1] then
		newX = leftBot[1]
	elseif x > rightTop[1] then
		newX = rightTop[1]
	else
		newX = x
	end

	if y < leftBot[2] then
		newY = leftBot[2]
	elseif y > rightTop[2] then
		newY = rightTop[2]
	else
		newY = y
	end

	return newX, newY
end

function GamePadNavigation:getValidUComponent(overUI)
	local dropWidget

	if overUI ~= nil then
		dropWidget = overUI:GetComponent("UWidget")

		while dropWidget ~= nil do
			local dropComponent = dropWidget.gameObject:GetComponent("UComponent")

			if dropComponent ~= nil and dropComponent.dropable == true then
				break
			end

			dropWidget = dropWidget.parentWidget
		end
	end

	return dropWidget
end

function GamePadNavigation:temporarilyDisableTime(disableTime)
	disableTime = disableTime or self.leftStickContinueMoveDelay
	self.stickMoveDisableTime = math.max(Time.realSecondCache + disableTime, self.stickMoveDisableTime)
end

function GamePadNavigation:initAreaTableSlots(area, slots)
	for i = 1, #area do
		area[i] = nil
	end

	for k, v in pairs(slots) do
		local t = {}

		for k1, v1 in pairs(v) do
			t[k1] = v1
		end

		area[k] = t
	end
end

function GamePadNavigation:setCursorArea(area)
	local oldArea = self.cursorArea

	if oldArea ~= area then
		self:handleExitAreaEvent()
	end

	local oldAreaTb = self:getAreaTablesById(oldArea)

	if oldAreaTb and oldAreaTb.CheckCanMoveOut then
		local slot = self:getCurSlot()

		if not oldAreaTb.CheckCanMoveOut(slot, area) then
			return
		end
	end

	if oldArea and self.cursorIndex then
		self.cacheAreaIndex[oldArea] = {
			x = self.cursorIndex.x,
			y = self.cursorIndex.y
		}
	end

	self.cursorArea = area

	if oldArea ~= area then
		self:handleEnterAreaEvent()
	end
end

function GamePadNavigation:setCursorIndex(x, y)
	if self.curBtn and self.curBtn.DisFocus then
		self.curBtn.DisFocus(x, y)
	end

	self.cursorIndex = {
		x = x,
		y = y
	}

	local btn
	local areaTable = self:getAreaTablesById(self.cursorArea)

	if areaTable and areaTable[x] and areaTable[x][y] then
		btn = areaTable[x][y]
	end

	if btn and btn.Focus then
		btn.Focus(x, y)
	end

	self.curBtn = btn
end

function GamePadNavigation:triggerFocus()
	return
end

function GamePadNavigation:findFirstMatchCursor(direction)
	local areaTable = self:getAreaTablesById(self.cursorArea) or {}

	if areaTable.EnterAreaSelectedSlot then
		local areaId = areaTable.EnterAreaSelectedSlot(areaTable)

		if areaId then
			self:setCursorIndex(areaId.x, areaId.y)

			return true
		end
	end

	local maxX = #areaTable

	if maxX <= 0 then
		return false
	end

	local maxY = #areaTable[1]

	for _, v in ipairs(areaTable[1]) do
		local num = #v

		if maxY < num then
			maxY = num
		end
	end

	if maxY <= 0 then
		return false
	end

	local validX = 1
	local validY = 1
	local findRes = false

	if areaTable.matchType == GamePadConst.MATCH_MODE.MATCH_FIRST then
		for x = 1, maxX do
			for y = 1, maxY do
				if not areaTable[x][y].empty then
					validX = x
					validY = y
					findRes = true

					break
				end
			end

			if findRes then
				break
			end
		end
	elseif areaTable.matchType == GamePadConst.MATCH_MODE.MATCH_OLD_CACHE and self.cacheAreaIndex[self.cursorArea] then
		local cacheIdx = self.cacheAreaIndex[self.cursorArea]

		validX = cacheIdx.x
		validY = cacheIdx.y
		findRes = true
	end

	if findRes then
		self:setCursorIndex(validX, validY)

		return true
	end

	if direction == GamePadConst.MOVE_DIRECTION.UP then
		local y = self.cursorIndex.y

		if maxY < y then
			y = maxY
		end

		for x = maxX, 1, -1 do
			if areaTable[x] and areaTable[x][y] and not areaTable[x][y].empty then
				validX = x
				validY = y
				findRes = true

				break
			end
		end
	elseif direction == GamePadConst.MOVE_DIRECTION.DOWN then
		local y = self.cursorIndex.y

		if maxY < y then
			y = maxY
		end

		for x = 1, maxX do
			if areaTable[x] and areaTable[x][y] and not areaTable[x][y].empty then
				validX = x
				validY = y
				findRes = true

				break
			end
		end
	elseif direction == GamePadConst.MOVE_DIRECTION.LEFT then
		local x = self.cursorIndex.x

		if maxX < x then
			x = maxX
		end

		for y = maxY, 1, -1 do
			if areaTable[x][y] and not areaTable[x][y].empty then
				validX = x
				validY = y
				findRes = true

				break
			end
		end
	elseif direction == GamePadConst.MOVE_DIRECTION.RIGHT then
		local x = self.cursorIndex.x

		if maxX < x then
			x = maxX
		end

		for y = 1, maxY do
			if areaTable[x][y] and not areaTable[x][y].empty then
				validX = x
				validY = y
				findRes = true

				break
			end
		end
	end

	if findRes then
		self:setCursorIndex(validX, validY)

		return true
	end

	for x = 1, maxX do
		for y = 1, maxY do
			if not areaTable[x][y].empty then
				validX = x
				validY = y
				findRes = true

				break
			end
		end

		if findRes then
			break
		end
	end

	self:setCursorIndex(validX, validY)

	return true
end

function GamePadNavigation:getAreaTablesById(id)
	return self.AREA_TABLES[id]
end

function GamePadNavigation:checkMoveDirection(x, y)
	if x == nil or y == nil then
		return GamePadConst.MOVE_DIRECTION.NONE
	end

	local moveDirection = GamePadConst.MOVE_DIRECTION.NONE

	if y > 0 and math.abs(x) <= math.abs(y) then
		moveDirection = GamePadConst.MOVE_DIRECTION.UP
	elseif y < 0 and math.abs(x) <= math.abs(y) then
		moveDirection = GamePadConst.MOVE_DIRECTION.DOWN
	elseif x < 0 and math.abs(y) <= math.abs(x) then
		moveDirection = GamePadConst.MOVE_DIRECTION.LEFT
	else
		moveDirection = GamePadConst.MOVE_DIRECTION.RIGHT
	end

	return moveDirection
end

function GamePadNavigation:moveOutOfBounds(area, afterX, afterY)
	if area[afterX] == nil then
		return true
	end

	if area[afterX][afterY] == nil then
		return true
	end

	return false
end

function GamePadNavigation:isTargetDirectionAreaLastSlotNil(area, afterX)
	if area[afterX] == nil then
		return true
	end

	if #area[afterX] <= 0 then
		return true
	end

	return #area[afterX]
end

function GamePadNavigation:moveOperation(direction)
	local curArea = self:getAreaTablesById(self.cursorArea)
	local oldAreaRecord = self:getAreaTablesById(self.cursorArea)
	local curIndexX = self.cursorIndex.x
	local curIndexY = self.cursorIndex.y

	if direction == GamePadConst.MOVE_DIRECTION.UP then
		if self:moveOutOfBounds(curArea, curIndexX - 1, curIndexY) == true then
			local lastAreaId = self.cursorArea
			local lastCursorIndex = self.cursorIndex
			local afterY = self:isTargetDirectionAreaLastSlotNil(curArea, curIndexX - 1)

			if afterY == true then
				if curArea[GamePadConst.MOVE_DIRECTION.UP] ~= nil and #self:getAreaTablesById(curArea[GamePadConst.MOVE_DIRECTION.UP]) > 0 then
					self:setCursorArea(curArea[GamePadConst.MOVE_DIRECTION.UP])

					curArea = self:getAreaTablesById(self.cursorArea)

					if curArea.Lock ~= nil and curArea.Lock.x ~= nil and curArea.Lock.y ~= nil and oldAreaRecord ~= curArea then
						self:setCursorIndex(curArea.Lock.x, curArea.Lock.y)
					else
						self:findFirstMatchCursor(direction)
					end

					self:handleCrossAreaEvent(lastAreaId, lastCursorIndex)
				end
			else
				self:setCursorIndex(curIndexX - 1, afterY)
				self:handleCrossAreaEvent(lastAreaId, lastCursorIndex)
			end
		else
			self:setCursorIndex(curIndexX - 1, curIndexY)
		end
	elseif direction == GamePadConst.MOVE_DIRECTION.DOWN then
		if self:moveOutOfBounds(curArea, curIndexX + 1, curIndexY) == true then
			local lastAreaId = self.cursorArea
			local lastCursorIndex = self.cursorIndex
			local afterY = self:isTargetDirectionAreaLastSlotNil(curArea, curIndexX + 1)

			if afterY == true then
				if curArea[GamePadConst.MOVE_DIRECTION.DOWN] ~= nil and #self:getAreaTablesById(curArea[GamePadConst.MOVE_DIRECTION.DOWN]) > 0 then
					self:setCursorArea(curArea[GamePadConst.MOVE_DIRECTION.DOWN])

					curArea = self:getAreaTablesById(self.cursorArea)

					if curArea.Lock ~= nil and curArea.Lock.x ~= nil and curArea.Lock.y ~= nil and oldAreaRecord ~= curArea then
						self:setCursorIndex(curArea.Lock.x, curArea.Lock.y)
					else
						self:findFirstMatchCursor(direction)
					end

					self:handleCrossAreaEvent(lastAreaId, lastCursorIndex)
				end
			else
				self:setCursorIndex(curIndexX + 1, afterY)
				self:handleCrossAreaEvent(lastAreaId, lastCursorIndex)
			end
		else
			self:setCursorIndex(curIndexX + 1, curIndexY)
		end
	elseif direction == GamePadConst.MOVE_DIRECTION.LEFT then
		if self:moveOutOfBounds(curArea, curIndexX, curIndexY - 1) == true then
			local lastAreaId = self.cursorArea
			local lastCursorIndex = self.cursorIndex

			if curArea[GamePadConst.MOVE_DIRECTION.LEFT] ~= nil and #self:getAreaTablesById(curArea[GamePadConst.MOVE_DIRECTION.LEFT]) > 0 then
				self:setCursorArea(curArea[GamePadConst.MOVE_DIRECTION.LEFT])

				curArea = self:getAreaTablesById(self.cursorArea)

				if curArea.Lock ~= nil and curArea.Lock.x ~= nil and curArea.Lock.y ~= nil and oldAreaRecord ~= curArea then
					self:setCursorIndex(curArea.Lock.x, curArea.Lock.y)
				else
					self:findFirstMatchCursor(direction)
				end

				self:handleCrossAreaEvent(lastAreaId, lastCursorIndex)
			end
		else
			self:setCursorIndex(curIndexX, curIndexY - 1)
		end
	elseif direction == GamePadConst.MOVE_DIRECTION.RIGHT then
		if self:moveOutOfBounds(curArea, curIndexX, curIndexY + 1) == true then
			local lastAreaId = self.cursorArea
			local lastCursorIndex = self.cursorIndex

			if curArea[GamePadConst.MOVE_DIRECTION.RIGHT] ~= nil and #self:getAreaTablesById(curArea[GamePadConst.MOVE_DIRECTION.RIGHT]) > 0 then
				self:setCursorArea(curArea[GamePadConst.MOVE_DIRECTION.RIGHT])

				curArea = self:getAreaTablesById(self.cursorArea)

				if curArea.Lock ~= nil and curArea.Lock.x ~= nil and curArea.Lock.y ~= nil and oldAreaRecord ~= curArea then
					self:setCursorIndex(curArea.Lock.x, curArea.Lock.y)
				else
					self:findFirstMatchCursor(direction)
				end

				self:handleCrossAreaEvent(lastAreaId, lastCursorIndex)
			end
		else
			self:setCursorIndex(curIndexX, curIndexY + 1)
		end
	end

	if self.curBtn and self.curBtn.empty then
		self:moveOperation(direction)
	end
end

function GamePadNavigation:handleExitAreaEvent()
	local curArea = self:getAreaTablesById(self.cursorArea)

	if curArea == nil then
		return
	end

	if curArea.ExitAreaAction then
		curArea.ExitAreaAction(self:getCurSlot())
	end
end

function GamePadNavigation:handleEnterAreaEvent()
	local curArea = self:getAreaTablesById(self.cursorArea)

	if curArea == nil then
		return
	end

	if curArea.EnterAreaAction then
		curArea.EnterAreaAction(self:getCurSlot())
	end
end

function GamePadNavigation:handleCrossAreaEvent(lastAreaId, lastCursorIndex)
	if lastAreaId == self.cursorArea then
		return
	end

	if self.moveOutOfBoundsCustomCallback then
		self.moveOutOfBoundsCustomCallback(lastAreaId, lastCursorIndex)
	end

	local curArea = self:getAreaTablesById(lastAreaId)

	if curArea == nil then
		return
	end

	local slot

	if lastCursorIndex ~= nil and curArea[lastCursorIndex.x] ~= nil and curArea[lastCursorIndex.x][lastCursorIndex.y] ~= nil then
		slot = curArea[lastCursorIndex.x][lastCursorIndex.y]
	end

	if curArea.OutAreaActionPost then
		curArea.OutAreaActionPost(slot)
	end
end

function GamePadNavigation:addConsoleEvent(data)
	local binding = KeyBindingPro.GetOrAddKeyBindingByName(data.parent, data.id)

	binding.isVirtual = data.isVirtual
	binding.actionPath = data.actionPath

	function binding.luaTrigger(inputInfo)
		data.event(inputInfo)
	end
end

function GamePadNavigation:addConsoleLongPressEvent(data)
	local function longPressFunc()
		data.event()
	end

	local binding = self:bindHotKey(data.actionPath, nil, longPressFunc, data.parent, 0)

	binding.isVirtual = data.isVirtual
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
end

function GamePadNavigation:initCommonLeftStickMoveData(rootGameObject)
	return {
		isVirtual = true,
		id = "leftStickMove",
		parent = rootGameObject,
		actionPath = GamePadConst.INDEX_TO_PATH[GamePadConst.FUNCTION_INDEX.LEFT_STICK],
		event = function(inputInfo)
			local continue = false

			if inputInfo.phase ~= "Performed" then
				self.tickPause = true
				continue = true
			elseif math.abs(inputInfo.valueVec2.x) <= GamePadConst.LEFT_STICK_MOVE_THRESHOLD and math.abs(inputInfo.valueVec2.y) <= GamePadConst.LEFT_STICK_MOVE_THRESHOLD then
				continue = false
			else
				self.tickPause = false
				continue = true
			end

			if continue == true then
				self.leftStickMoveVec2X = inputInfo.valueVec2.x
				self.leftStickMoveVec2Y = inputInfo.valueVec2.y
			end
		end
	}
end

function GamePadNavigation:initDPadMoveData(rootGameObject)
	self:addConsoleEvent({
		isVirtual = true,
		id = "DPadMoveUp",
		parent = rootGameObject,
		actionPath = GamePadConst.INDEX_TO_PATH[GamePadConst.FUNCTION_INDEX.UP],
		event = function(inputInfo)
			self.tickPause = inputInfo.phase ~= "Performed"
			self.leftStickMoveVec2X = 0
			self.leftStickMoveVec2Y = 1
		end
	})
	self:addConsoleEvent({
		isVirtual = true,
		id = "DPadMoveDown",
		parent = rootGameObject,
		actionPath = GamePadConst.INDEX_TO_PATH[GamePadConst.FUNCTION_INDEX.DOWN],
		event = function(inputInfo)
			self.tickPause = inputInfo.phase ~= "Performed"
			self.leftStickMoveVec2X = 0
			self.leftStickMoveVec2Y = -1
		end
	})
	self:addConsoleEvent({
		isVirtual = true,
		id = "DPadMoveLeft",
		parent = rootGameObject,
		actionPath = GamePadConst.INDEX_TO_PATH[GamePadConst.FUNCTION_INDEX.LEFT],
		event = function(inputInfo)
			self.tickPause = inputInfo.phase ~= "Performed"
			self.leftStickMoveVec2X = -1
			self.leftStickMoveVec2Y = 0
		end
	})
	self:addConsoleEvent({
		isVirtual = true,
		id = "DPadMoveRight",
		parent = rootGameObject,
		actionPath = GamePadConst.INDEX_TO_PATH[GamePadConst.FUNCTION_INDEX.RIGHT],
		event = function(inputInfo)
			self.tickPause = inputInfo.phase ~= "Performed"
			self.leftStickMoveVec2X = 1
			self.leftStickMoveVec2Y = 0
		end
	})
end

function GamePadNavigation:initCommonRightStickMoveData(rootGameObject)
	return {
		isVirtual = true,
		id = "rightStickMove",
		parent = rootGameObject,
		actionPath = GamePadConst.INDEX_TO_PATH[GamePadConst.FUNCTION_INDEX.RIGHT_STICK],
		event = function(inputInfo)
			local continue = false

			if inputInfo.phase ~= "Performed" then
				self.rightTickPause = true
				continue = true
			elseif math.abs(inputInfo.valueVec2.x) <= GamePadConst.LEFT_STICK_MOVE_THRESHOLD and math.abs(inputInfo.valueVec2.y) <= GamePadConst.LEFT_STICK_MOVE_THRESHOLD then
				continue = false
			else
				self.rightTickPause = false
				continue = true
			end

			if continue == true then
				self.rightStickMoveVec2X = inputInfo.valueVec2.x
				self.rightStickMoveVec2Y = inputInfo.valueVec2.y
			end
		end
	}
end

function GamePadNavigation:handleStickFunc(index)
	local moveX = 0
	local moveY = 0
	local operationArea = self:getAreaTablesById(self.cursorArea)

	if operationArea == nil then
		return
	end

	if index == GamePadConst.FUNCTION_INDEX.LEFT_STICK then
		moveX = self.leftStickMoveVec2X or 0
		moveY = self.leftStickMoveVec2Y or 0

		if operationArea.LeftStickThresholdX and math.abs(moveX) < (operationArea.LeftStickThresholdX or 0) then
			moveX = 0
		end

		if operationArea.LeftStickThresholdY and math.abs(moveY) < (operationArea.LeftStickThresholdY or 0) then
			moveY = 0
		end
	elseif index == GamePadConst.FUNCTION_INDEX.RIGHT_STICK then
		moveX = self.rightStickMoveVec2X or 0
		moveY = self.rightStickMoveVec2Y or 0

		if operationArea.RightStickThresholdX and math.abs(moveX) < (operationArea.RightStickThresholdX or 0) then
			moveX = 0
		end

		if operationArea.RightStickThresholdY and math.abs(moveY) < (operationArea.RightStickThresholdY or 0) then
			moveY = 0
		end
	end

	local curSlot = self:getCurSlot()

	if curSlot == nil or curSlot["Fun" .. index] == nil then
		return
	end

	curSlot["Fun" .. index](moveX, moveY)
end

function GamePadNavigation:initCommonKeyData(index, rootGameObject)
	return {
		isVirtual = true,
		parent = rootGameObject,
		id = "fun" .. GamePadConst.FUNCTION_INDEX[index],
		actionPath = GamePadConst.INDEX_TO_PATH[GamePadConst.FUNCTION_INDEX[index]],
		event = function(inputInfo)
			TimerManager.removeTimer(self.longPressTimer)

			if self.longPressMayPerformed == true then
				return
			end

			if inputInfo.phase == "Performed" then
				local curSlot = self:getCurSlot()

				if curSlot ~= nil and curSlot["Fun" .. GamePadConst.FUNCTION_INDEX[index]] ~= nil then
					curSlot["Fun" .. GamePadConst.FUNCTION_INDEX[index]](self.cursorIndex.x, self.cursorIndex.y)
				end

				self:enableLongPressByRelatedKey(index, true)
			elseif inputInfo.phase == "Canceled" then
				self:enableLongPressByRelatedKey(index, false)
			end
		end
	}
end

function GamePadNavigation:initLongPressKeyData(index, rootGameObject)
	return {
		isVirtual = true,
		parent = rootGameObject,
		id = "fun" .. GamePadConst.FUNCTION_INDEX[index],
		actionPath = GamePadConst.INDEX_TO_PATH[GamePadConst.FUNCTION_INDEX[index]],
		event = function()
			local curSlot = self:getCurSlot()

			if curSlot ~= nil and curSlot["Fun" .. GamePadConst.FUNCTION_INDEX[index]] ~= nil then
				curSlot["Fun" .. GamePadConst.FUNCTION_INDEX[index]](self.cursorIndex.x, self.cursorIndex.y)
			end
		end
	}
end

function GamePadNavigation:baseFocus(t, x, y, consoleKeyUList, finishRenderCallback, disableDefaultAudio)
	if consoleKeyUList == nil then
		return
	end

	if t == nil or t[x] == nil or t[x][y] == nil then
		consoleKeyUList:SetList(nil)

		return
	end

	local keys = {}

	if t[x][y][HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadRightStick] and t[x][y][HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadRightStick .. "name"] then
		keys[#keys + 1] = {
			path = {
				HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadRightStick
			},
			name = t[x][y][HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadRightStick .. "name"]
		}
	end

	for i = 5, 18 do
		if t[x][y]["Fun" .. i] ~= nil and t[x][y]["Fun" .. i .. "Name"] ~= nil then
			local containsLongPress = t[x][y]["Fun" .. i .. "ContainsLongPress"]
			local isImportant = t[x][y]["Fun" .. i .. "IsImportant"]
			local _, relatedKey = LuaUIUtils.tableContains(GamePadConst.FUNCTION_INDEX, i)

			keys[#keys + 1] = {
				path = {
					GamePadConst.INDEX_TO_PATH[i]
				},
				name = t[x][y]["Fun" .. i .. "Name"],
				containsLongPress = containsLongPress,
				relatedKey = relatedKey,
				isImportant = isImportant
			}
		end
	end

	if t[x][y].Fun2 ~= nil and t[x][y].Fun2Name ~= nil then
		local containsLongPress = t[x][y].Fun2ContainsLongPress
		local isImportant = t[x][y].Fun2IsImportant
		local _, relatedKey = LuaUIUtils.tableContains(GamePadConst.FUNCTION_INDEX, 2)

		keys[#keys + 1] = {
			path = {
				GamePadConst.INDEX_TO_PATH[GamePadConst.FUNCTION_INDEX.Y]
			},
			name = t[x][y].Fun2Name,
			containsLongPress = containsLongPress,
			relatedKey = relatedKey,
			isImportant = isImportant
		}
	end

	if t[x][y].Fun1 ~= nil and t[x][y].Fun1Name ~= nil then
		local containsLongPress = t[x][y].Fun1ContainsLongPress
		local isImportant = t[x][y].Fun1IsImportant
		local _, relatedKey = LuaUIUtils.tableContains(GamePadConst.FUNCTION_INDEX, 1)

		keys[#keys + 1] = {
			path = {
				GamePadConst.INDEX_TO_PATH[GamePadConst.FUNCTION_INDEX.X]
			},
			name = t[x][y].Fun1Name,
			containsLongPress = containsLongPress,
			relatedKey = relatedKey,
			isImportant = isImportant
		}
	end

	if t[x][y].Fun4 ~= nil and t[x][y].Fun4Name ~= nil then
		local containsLongPress = t[x][y].Fun4ContainsLongPress
		local isImportant = t[x][y].Fun4IsImportant
		local _, relatedKey = LuaUIUtils.tableContains(GamePadConst.FUNCTION_INDEX, 4)

		keys[#keys + 1] = {
			path = {
				GamePadConst.INDEX_TO_PATH[GamePadConst.FUNCTION_INDEX.A]
			},
			name = t[x][y].Fun4Name,
			containsLongPress = containsLongPress,
			relatedKey = relatedKey,
			isImportant = isImportant
		}
	end

	if t[x][y].Fun3 ~= nil and t[x][y].Fun3Name ~= nil then
		local containsLongPress = t[x][y].Fun3ContainsLongPress
		local isImportant = t[x][y].Fun3IsImportant
		local _, relatedKey = LuaUIUtils.tableContains(GamePadConst.FUNCTION_INDEX, 3)

		keys[#keys + 1] = {
			path = {
				GamePadConst.INDEX_TO_PATH[GamePadConst.FUNCTION_INDEX.B]
			},
			name = t[x][y].Fun3Name,
			containsLongPress = containsLongPress,
			relatedKey = relatedKey,
			isImportant = isImportant
		}
	end

	function consoleKeyUList.luaRenderItem(button, index, data)
		local objRef = button.transform:GetComponent("ObjectReference")
		local keyHotKeyContent = objRef:GetRefValue("keyHotKeyContent")
		local txtNameUText = objRef:GetRefValue("btnTipsUText")
		local keyUList = objRef:GetRefValue("keyUList")

		function keyUList.luaFinishRender(list)
			if finishRenderCallback then
				finishRenderCallback(list, data)
			end
		end

		keyHotKeyContent:SetHotKeyPaths(data.path)
		ClientTextUtils.setText(txtNameUText, data.name)
		button:TryChangePage("KeyType", data.isImportant and 1 or 0)
	end

	consoleKeyUList:SetList(keys)

	self.currentKeyListData = keys
	self.currentKeyList = consoleKeyUList

	if not disableDefaultAudio then
		pg.game.audio:triggerEvent("ui_click_common")
	end
end

function GamePadNavigation:reBaseFocus(consoleKeyUList)
	local curArea = self:getAreaTablesById(self.cursorArea)

	if curArea ~= nil and self.cursorIndex ~= nil and curArea[self.cursorIndex.x] ~= nil and curArea[self.cursorIndex.x][self.cursorIndex.y] ~= nil then
		self:baseFocus(curArea, self.cursorIndex.x, self.cursorIndex.y, consoleKeyUList)
	end
end

function GamePadNavigation:enableLongPressByRelatedKey(index, enable)
	local k1, v1

	if not self.currentKeyListData or not self.currentKeyList then
		return
	end

	for k, v in pairs(self.currentKeyListData) do
		if v.containsLongPress and v.relatedKey == index then
			k1, v1 = k, v
		end
	end

	local btn1

	if not v1 then
		return btn1
	end

	local _, btn = self.currentKeyList:TryGetChildAt(k1 - 1)

	if not btn then
		return
	end

	local objectReference = btn:GetComponent("ObjectReference")
	local keyUList = objectReference:GetRefValue("keyUList")

	_, btn1 = keyUList:TryGetChildAt(0)

	if not btn1 then
		return
	end

	local objectReference1 = btn1:GetComponent("ObjectReference")
	local countDownUCountDown = objectReference1:GetRefValue("countDownUCountDown")

	if enable then
		function countDownUCountDown.luaFinished()
			LuaUIUtils.setUIViewVisible(countDownUCountDown, false)
		end

		LuaUIUtils.setUIViewVisible(countDownUCountDown, true)
		countDownUCountDown:Play(self.longPressDelay)
	else
		LuaUIUtils.setUIViewVisible(countDownUCountDown, false)
	end
end

function GamePadNavigation:focusReset(areaId)
	if pg.game.input:isUsingGamepad() ~= true then
		return
	end

	self:setCursorArea(areaId)

	local curArea = self:getAreaTablesById(self.cursorArea)

	if curArea[1] ~= nil and curArea[1][1] ~= nil then
		self:setCursorIndex(1, 1)
	else
		self.cursorIndex = nil
	end

	local curSlot = self:getCurSlot()

	if curSlot ~= nil and curSlot.Focus ~= nil then
		curSlot.Focus(self.cursorIndex.x, self.cursorIndex.y)
	end
end

function GamePadNavigation:specificSet(areaId, x, y)
	if pg.game.input:isUsingGamepad() ~= true then
		return
	end

	local oldAreaId = self.cursorArea
	local oldAreaIdx = self.cursorIndex

	self:setCursorArea(areaId)

	local curArea = self:getAreaTablesById(self.cursorArea)

	x = x or 1
	y = y or 1

	if (x ~= 1 or y ~= 1) and curArea and curArea[x] ~= nil and curArea[x][y] ~= nil then
		self:setCursorIndex(x, y)
	elseif not self:findFirstMatchCursor(GamePadConst.MOVE_DIRECTION.NONE) then
		self.cursorIndex = nil
	end

	self:handleCrossAreaEvent(oldAreaId, oldAreaIdx)
end

function GamePadNavigation:reFocus()
	if pg.game.input:isUsingGamepad() ~= true then
		return
	end

	local curSlot = self:getCurSlot()

	if curSlot ~= nil and curSlot.Focus ~= nil then
		curSlot.Focus(self.cursorIndex.x, self.cursorIndex.y)
	end
end

function GamePadNavigation:getCurSlot()
	local curArea = self:getAreaTablesById(self.cursorArea)

	if curArea ~= nil and self.cursorIndex ~= nil and curArea[self.cursorIndex.x] ~= nil and curArea[self.cursorIndex.x][self.cursorIndex.y] ~= nil then
		return curArea[self.cursorIndex.x][self.cursorIndex.y]
	end

	return nil
end

function GamePadNavigation:getSlotByAreaAndIndex(areaId, x, y)
	local curArea = self:getAreaTablesById(areaId)

	if curArea ~= nil and x ~= nil and y ~= nil and curArea[x] ~= nil and curArea[x][y] ~= nil then
		return curArea[x][y]
	end

	return nil
end

function GamePadNavigation:delayFocus(areaAndIndexAdjustCallback, delay)
	if pg.game.input:isUsingGamepad() ~= true then
		return
	end

	TimerManager.addTimer(delay, function()
		if areaAndIndexAdjustCallback ~= nil then
			areaAndIndexAdjustCallback()
		end

		local curSlot = self:getCurSlot()

		if curSlot == nil or curSlot.Focus == nil then
			return
		end

		curSlot.Focus(self.cursorIndex.x, self.cursorIndex.y)
	end)
end

function GamePadNavigation:laterFramesFocus(areaAndIndexAdjustCallback, frameCount)
	if pg.game.input:isUsingGamepad() ~= true then
		return
	end

	TimerManager.addSpecificFrameCb(frameCount, false, function()
		if areaAndIndexAdjustCallback ~= nil then
			areaAndIndexAdjustCallback()
		end

		local curSlot = self:getCurSlot()

		if curSlot == nil or curSlot.Focus == nil then
			return
		end

		curSlot.Focus(self.cursorIndex.x, self.cursorIndex.y)
	end)
end

function GamePadNavigation:recordCursor()
	self.cursorAreaRecord = self.cursorArea

	if self.cursorIndex then
		self.cursorIndexXRecord = self.cursorIndex.x
		self.cursorIndexYRecord = self.cursorIndex.y
	else
		self.cursorIndexXRecord = nil
		self.cursorIndexYRecord = nil
	end
end

function GamePadNavigation:resumeCursor()
	self:setCursorArea(self.cursorAreaRecord)
	self:setCursorIndex(self.cursorIndexXRecord, self.cursorIndexYRecord)

	self.cursorAreaRecord = nil
	self.cursorIndexXRecord = nil
	self.cursorIndexYRecord = nil
end

function GamePadNavigation:setLock(areaId, needLock, x, y)
	local curArea = self:getAreaTablesById(areaId)

	if needLock == true then
		curArea.Lock = {
			x = x,
			y = y
		}
	else
		curArea.Lock = nil
	end
end

function GamePadNavigation:setMoveOutOfBoundsCustomCallback(callback)
	self.moveOutOfBoundsCustomCallback = callback
end

function GamePadNavigation:onDestroy()
	self.cursorArea = nil
	self.cursorIndex = nil

	if self.tickTimer then
		self.ctrl:killTimer(self.tickTimer)
	end

	self.tickTimer = nil
	self.tickPause = nil
	self.stickMoveDisableTime = nil
	self.leftStickContinueMoveDelay = nil
	self.leftStickMoveCount = nil
	self.leftStickMoveVec2X = nil
	self.leftStickMoveVec2Y = nil
	self.longPressMayPerformed = nil

	if self.prefabCloneLoader then
		self.prefabCloneLoader:clearInstantiate()

		self.prefabCloneLoader = nil
	end

	self.selectedObj = nil
	self.dropWidget = nil
	self.dropRayBox = nil
	self.hoverWidget = nil

	if self.longPressTimer then
		TimerManager.removeTimer(self.longPressTimer)
	end

	self.longPressTimer = nil
	self.longPressStart = nil
	self.clonePrefabMoveSpeed = nil
	self.longPressDelay = nil
	self.dragPrefabHoverCallback = nil
	self.dragPrefabUnHoverCallback = nil

	UIComponent.onDestroy(self)
end

function GamePadNavigation:setListArea(area, uList, uListData, consoleKeyUList, confirmAction, cancelAction, horizontal, clickText, navMap)
	local navMap = self:createBaseNavMap(area, uList, uListData, consoleKeyUList, confirmAction, cancelAction, horizontal, clickText, navMap)

	self:initAreaTableSlots(area, navMap)
end

function GamePadNavigation:createBaseNavMap(area, uList, uListData, consoleKeyUList, confirmAction, cancelAction, horizontal, clickText, navMap, singleForward)
	if self.areaLists == nil then
		self.areaLists = {}
	end

	self.areaLists[area.index] = uList
	navMap = navMap or self:generateCommonListNavMap(uListData, horizontal)

	local index = 0

	for _, items in ipairs(navMap) do
		for _, item in ipairs(items) do
			index = index + 1

			local curIndex = index

			function item.Focus(x1, y1)
				self:baseFocus(navMap, x1, y1, consoleKeyUList)

				for _, uList in pairs(self.areaLists) do
					local btns = uList:GetAllButtons()

					for i = 0, btns.Length - 1 do
						local btn = btns[i]

						if btn.DoUnHover then
							btn:DoUnHover()
						else
							btn:TryChangePage("button", 0)
						end

						btn:CloseTooltip()

						if pg.global.ui:checkUIOpen(UIConst.UI_ID_COMMON_ITEM_TIP) then
							pg.global.ui.commonItemTip:close()
						end

						self:setButtonFocus(btn, 0)
					end
				end

				local ret, min, max = uList:TryGetVisualRange()

				if curIndex > 0 and curIndex <= #uListData then
					if curIndex == #uListData or curIndex == 1 then
						uList:GoToIndex(curIndex - 1)
					elseif curIndex + 1 <= #uListData and not singleForward and (max < curIndex or min > curIndex - 1) then
						uList:GoToIndex(curIndex - 1)
					end
				end

				area.curSelect = curIndex

				local _, button = uList:TryGetChildAt(curIndex - 1)

				if button then
					if button.DoHover then
						button:DoHover()
					else
						button:TryChangePage("button", 3)
					end

					self:setButtonFocus(button, 1)
				end
			end

			item.Fun3Name = pg.getGameString("COMMON_CANCEL")

			function item.Fun3(x1, y1)
				if cancelAction then
					cancelAction(uList, curIndex)
				end
			end

			item.Fun4Name = clickText or pg.getGameString("COMMON_CONFIRM")

			function item.Fun4(x1, y1)
				if confirmAction then
					confirmAction(uList, curIndex, uListData[curIndex])
				else
					local _, button = uList:TryGetChildAt(curIndex - 1)

					if button and uList.luaClick ~= nil then
						uList.luaClick(button, uList.itemData[curIndex - 1])
					end
				end
			end
		end
	end

	uList:RegisterToScrollEndEvent(function()
		if area.curSelect then
			local _, button = uList:TryGetChildAt(area.curSelect - 1)

			if button then
				if button.DoHover then
					button:DoHover()
				else
					button:TryChangePage("button", 3)
				end
			end
		end
	end)
	self:addConsoleEvent(self:initCommonKeyData("A", uList.gameObject))
	self:addConsoleEvent(self:initCommonKeyData("B", uList.gameObject))
	self:addConsoleEvent(self:initCommonKeyData("Y", uList.gameObject))
	self:addConsoleEvent(self:initCommonLeftStickMoveData(uList.gameObject))

	return navMap
end

function GamePadNavigation:generateCommonListNavMap(uListData, horizontal)
	local navMap = {}

	if horizontal then
		navMap[1] = {}

		for index, value in ipairs(uListData) do
			navMap[1][index] = {}
		end
	else
		for index, value in ipairs(uListData) do
			navMap[index] = {}
			navMap[index][1] = {}
		end
	end

	return navMap
end

function GamePadNavigation:setCustomArea(area, navMap, consoleKeyUList, confirmAction, cancelAction, clickText, focusAction)
	for _, items in ipairs(navMap) do
		for _, item in ipairs(items) do
			function item.Focus(x1, y1)
				self:baseFocus(navMap, x1, y1, consoleKeyUList)

				if focusAction then
					focusAction(item, x1, y1)
				else
					self:defaultFocusAction(navMap, item)
				end
			end

			item.Fun3Name = pg.getGameString("COMMON_CANCEL")

			function item.Fun3(x1, y1)
				if cancelAction then
					cancelAction(item, x1, y1)
				end
			end

			if confirmAction then
				item.Fun4Name = clickText or pg.getGameString("COMMON_CONFIRM")

				function item.Fun4(x1, y1)
					confirmAction(item, x1, y1)
				end
			end
		end
	end

	self:addConsoleEvent(self:initCommonKeyData("A", consoleKeyUList.gameObject))
	self:addConsoleEvent(self:initCommonKeyData("B", consoleKeyUList.gameObject))
	self:addConsoleEvent(self:initCommonKeyData("Y", consoleKeyUList.gameObject))
	self:addConsoleEvent(self:initCommonLeftStickMoveData(consoleKeyUList.gameObject))
	self:initAreaTableSlots(area, navMap)
end

function GamePadNavigation:defaultFocusAction(navMap, item)
	for _, innerItems in ipairs(navMap) do
		for _, innerItem in ipairs(innerItems) do
			if innerItem.element ~= item.element then
				if innerItem.element.DoUnHover then
					innerItem.element:DoUnHover()
				else
					innerItem.element:TryChangePage("button", 0)
				end

				self:setButtonFocus(innerItem.element, 0)
			end

			local button = innerItem.element:GetComponent("UButton")

			if button then
				button:CloseTooltip()
			end

			if pg.global.ui:checkUIOpen(UIConst.UI_ID_COMMON_ITEM_TIP) then
				pg.global.ui.commonItemTip:close()
			end
		end
	end

	if item.element.DoHover then
		item.element:DoHover()
	else
		item.element:TryChangePage("button", 3)
	end

	self:setButtonFocus(item.element, 1)
end

function GamePadNavigation:setButtonFocus(button, state)
	button:TryChangePage("GamePadFocus", state)

	local console = button.transform:Find("ConsoleSelected")

	if console then
		console:GetComponent("UComponent"):TryChangePage("GamePadFocus", state)
	end
end

function GamePadNavigation:clearNavigation()
	if self.curBtn and self.curBtn.DisFocus then
		self.curBtn.DisFocus()
	end
end

return GamePadNavigation
