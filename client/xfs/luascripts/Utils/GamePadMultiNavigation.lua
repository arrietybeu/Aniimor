-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\GamePadMultiNavigation.lua

local Time = require("Core.Common.Time")
local Class = require("Core.Framework.Class")
local TimerManager = require("Core.Timer.TimerManager")
local UIComponent = require("Guis.Helper.UIComponent")
local GamePadMultiNavigation = Class.LightClass("GamePadMultiNavigation", UIComponent)

GamePadMultiNavigation.MOVE_DIRECTION = {
	DOWN = -2,
	UP = -1,
	NONE = 0,
	RIGHT = -4,
	LEFT = -3
}
GamePadMultiNavigation.NAV_AREA = {
	RIGHT_STICK = 3,
	DPAD = 2,
	LEFT_STICK = 1
}
GamePadMultiNavigation.LEFT_STICK_MOVE_DELAY_SLOW = 0.25
GamePadMultiNavigation.LEFT_STICK_MOVE_DELAY_FAST = 0.15
GamePadMultiNavigation.D_PAD_MOVE_DELAY_SLOW = 0.25
GamePadMultiNavigation.D_PAD_MOVE_DELAY_FAST = 0.15
GamePadMultiNavigation.RIGHT_STICK_MOVE_DELAY_SLOW = 0.25
GamePadMultiNavigation.RIGHT_STICK_MOVE_DELAY_FAST = 0.15

function GamePadMultiNavigation:findObjects()
	self.cursorAreaLeftStick = nil
	self.cursorIndexLeftStick = nil
	self.cursorAreaDPad = nil
	self.cursorIndexDPad = nil
	self.cursorAreaRightStick = nil
	self.cursorIndexRightStick = nil
	self.tickTimer = nil
	self.tickPauseLeftStick = nil
	self.tickPauseDPadUp = nil
	self.tickPauseDPadDown = nil
	self.tickPauseDPadLeft = nil
	self.tickPauseDPadRight = nil
	self.tickPauseRightStick = nil
	self.leftStickMoveDisableTime = -1
	self.dPadUpDisableTime = -1
	self.dPadDownDisableTime = -1
	self.dPadLeftDisableTime = -1
	self.dPadRightDisableTime = -1
	self.rightStickMoveDisableTime = -1
	self.leftStickContinueMoveDelay = self.LEFT_STICK_MOVE_DELAY_SLOW
	self.dPadUpContinueMoveDelay = self.D_PAD_MOVE_DELAY_SLOW
	self.dPadDownContinueMoveDelay = self.D_PAD_MOVE_DELAY_SLOW
	self.dPadLeftContinueMoveDelay = self.D_PAD_MOVE_DELAY_SLOW
	self.dPadRightContinueMoveDelay = self.D_PAD_MOVE_DELAY_SLOW
	self.rightStickContinueMoveDelay = self.RIGHT_STICK_MOVE_DELAY_SLOW
	self.leftStickMoveCount = 0
	self.dPadUpMoveCount = 0
	self.dPadDownMoveCount = 0
	self.dPadLeftMoveCount = 0
	self.dPadRightMoveCount = 0
	self.rightStickMoveCount = 0
	self.leftStickMoveVec2X = nil
	self.leftStickMoveVec2Y = nil
	self.dPadMoveVec2X = nil
	self.dPadMoveVec2Y = nil
	self.rightStickMoveVec2X = nil
	self.rightStickMoveVec2Y = nil
	self.dPadUpRunOnce = false
	self.dPadDownRunOnce = false
	self.dPadLeftRunOnce = false
	self.dPadRightRunOnce = false
end

function GamePadMultiNavigation:initView()
	self.tickTimer = self.ctrl:startTimer(function()
		self:startTick()
	end, 0, true)
end

function GamePadMultiNavigation:startTick()
	if self.cursorAreaLeftStick ~= nil and self.cursorIndexLeftStick ~= nil then
		if self.tickPauseLeftStick == true or self.tickPauseLeftStick == nil then
			self.leftStickMoveCount = 0
		else
			if self.leftStickMoveCount >= 3 then
				self.leftStickContinueMoveDelay = self.LEFT_STICK_MOVE_DELAY_FAST
			else
				self.leftStickContinueMoveDelay = self.LEFT_STICK_MOVE_DELAY_SLOW
			end

			if self.leftStickMoveDisableTime <= Time.realSecondCache then
				self:moveOperation(self:checkMoveDirection(self.leftStickMoveVec2X, self.leftStickMoveVec2Y), self.cursorAreaLeftStick, self.cursorIndexLeftStick, self.NAV_AREA.LEFT_STICK)

				self.leftStickMoveCount = self.leftStickMoveCount + 1
				self.leftStickMoveDisableTime = math.max(Time.realSecondCache + self.leftStickContinueMoveDelay, self.leftStickMoveDisableTime)
			end
		end
	end

	if self.cursorAreaDPad ~= nil and self.cursorIndexDPad ~= nil then
		if self.tickPauseDPadUp == true or self.tickPauseDPadUp == nil then
			self.dPadUpMoveCount = 0
			self.dPadUpRunOnce = false
		else
			if self.dPadUpMoveCount >= 3 then
				self.dPadUpContinueMoveDelay = self.D_PAD_MOVE_DELAY_FAST
			else
				self.dPadUpContinueMoveDelay = self.D_PAD_MOVE_DELAY_SLOW
			end

			if self.dPadUpDisableTime <= Time.realSecondCache then
				self.dPadUpMoveCount = self.dPadUpMoveCount + 1
				self.dPadUpDisableTime = math.max(Time.realSecondCache + self.dPadUpContinueMoveDelay, self.dPadUpDisableTime)
				self.dPadUpRunOnce = true
			else
				self.dPadUpRunOnce = false
			end
		end

		if self.tickPauseDPadDown == true or self.tickPauseDPadDown == nil then
			self.dPadDownMoveCount = 0
			self.dPadDownRunOnce = false
		else
			if self.dPadDownMoveCount >= 3 then
				self.dPadDownContinueMoveDelay = self.D_PAD_MOVE_DELAY_FAST
			else
				self.dPadDownContinueMoveDelay = self.D_PAD_MOVE_DELAY_SLOW
			end

			if self.dPadDownDisableTime <= Time.realSecondCache then
				self.dPadDownMoveCount = self.dPadDownMoveCount + 1
				self.dPadDownDisableTime = math.max(Time.realSecondCache + self.dPadDownContinueMoveDelay, self.dPadDownDisableTime)
				self.dPadDownRunOnce = true
			else
				self.dPadDownRunOnce = false
			end
		end

		if self.tickPauseDPadLeft == true or self.tickPauseDPadLeft == nil then
			self.dPadLeftMoveCount = 0
			self.dPadLeftRunOnce = false
		else
			if self.dPadLeftMoveCount >= 3 then
				self.dPadLeftContinueMoveDelay = self.D_PAD_MOVE_DELAY_FAST
			else
				self.dPadLeftContinueMoveDelay = self.D_PAD_MOVE_DELAY_SLOW
			end

			if self.dPadLeftDisableTime <= Time.realSecondCache then
				self.dPadLeftMoveCount = self.dPadLeftMoveCount + 1
				self.dPadLeftDisableTime = math.max(Time.realSecondCache + self.dPadLeftContinueMoveDelay, self.dPadLeftDisableTime)
				self.dPadLeftRunOnce = true
			else
				self.dPadLeftRunOnce = false
			end
		end

		if self.tickPauseDPadRight == true or self.tickPauseDPadRight == nil then
			self.dPadRightMoveCount = 0
			self.dPadRightRunOnce = false
		else
			if self.dPadRightMoveCount >= 3 then
				self.dPadRightContinueMoveDelay = self.D_PAD_MOVE_DELAY_FAST
			else
				self.dPadRightContinueMoveDelay = self.D_PAD_MOVE_DELAY_SLOW
			end

			if self.dPadRightDisableTime <= Time.realSecondCache then
				self.dPadRightMoveCount = self.dPadRightMoveCount + 1
				self.dPadRightDisableTime = math.max(Time.realSecondCache + self.dPadRightContinueMoveDelay, self.dPadRightDisableTime)
				self.dPadRightRunOnce = true
			else
				self.dPadRightRunOnce = false
			end
		end

		if self.dPadUpRunOnce == true or self.dPadDownRunOnce == true or self.dPadLeftRunOnce == true or self.dPadRightRunOnce == true then
			self:moveOperation(self:checkMoveDirection(self.dPadMoveVec2X, self.dPadMoveVec2Y), self.cursorAreaDPad, self.cursorIndexDPad, self.NAV_AREA.DPAD)
		end
	end

	if self.cursorAreaRightStick ~= nil and self.cursorIndexRightStick ~= nil then
		if self.tickPauseRightStick == true or self.tickPauseRightStick == nil then
			self.rightStickMoveCount = 0
		else
			if self.rightStickMoveCount >= 3 then
				self.rightStickContinueMoveDelay = self.RIGHT_STICK_MOVE_DELAY_FAST
			else
				self.rightStickContinueMoveDelay = self.RIGHT_STICK_MOVE_DELAY_SLOW
			end

			if self.rightStickMoveDisableTime <= Time.realSecondCache then
				self:moveOperation(self:checkMoveDirection(self.rightStickMoveVec2X, self.rightStickMoveVec2Y), self.cursorAreaRightStick, self.cursorIndexRightStick, self.NAV_AREA.RIGHT_STICK)

				self.rightStickMoveCount = self.rightStickMoveCount + 1
				self.rightStickMoveDisableTime = math.max(Time.realSecondCache + self.rightStickContinueMoveDelay, self.rightStickMoveDisableTime)
			end
		end
	end
end

function GamePadMultiNavigation:temporarilyDisableTime(obj, disableTime)
	obj = math.max(Time.realSecondCache + disableTime, obj)
end

function GamePadMultiNavigation:initAreaTableSlots(area, slots)
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

function GamePadMultiNavigation:setCursorArea(area, navArea)
	if navArea == self.NAV_AREA.LEFT_STICK then
		self.cursorAreaLeftStick = area
	elseif navArea == self.NAV_AREA.DPAD then
		self.cursorAreaDPad = area
	else
		self.cursorAreaRightStick = area
	end
end

function GamePadMultiNavigation:getCursorArea(navArea)
	if navArea == self.NAV_AREA.LEFT_STICK then
		return self.cursorAreaLeftStick
	elseif navArea == self.NAV_AREA.DPAD then
		return self.cursorAreaDPad
	else
		return self.cursorAreaRightStick
	end
end

function GamePadMultiNavigation:setCursorIndex(x, y, navArea)
	if navArea == self.NAV_AREA.LEFT_STICK then
		self.cursorIndexLeftStick = {
			x = x,
			y = y
		}
	elseif navArea == self.NAV_AREA.DPAD then
		self.cursorIndexDPad = {
			x = x,
			y = y
		}
	else
		self.cursorIndexRightStick = {
			x = x,
			y = y
		}
	end
end

function GamePadMultiNavigation:getCursorIndex(navArea)
	if navArea == self.NAV_AREA.LEFT_STICK then
		return self.cursorIndexLeftStick
	elseif navArea == self.NAV_AREA.DPAD then
		return self.cursorIndexDPad
	else
		return self.cursorIndexRightStick
	end
end

function GamePadMultiNavigation:getAreaTablesById(id, navArea)
	if navArea == self.NAV_AREA.LEFT_STICK then
		return self.AREA_TABLES[id]
	elseif navArea == self.NAV_AREA.DPAD then
		return self.AREA_TABLES[id]
	else
		return self.AREA_TABLES[id]
	end
end

function GamePadMultiNavigation:checkMoveDirection(x, y)
	if x == nil or y == nil then
		return self.MOVE_DIRECTION.NONE
	end

	if y > 0 and math.abs(x) <= math.abs(y) then
		return self.MOVE_DIRECTION.UP
	elseif y < 0 and math.abs(x) <= math.abs(y) then
		return self.MOVE_DIRECTION.DOWN
	elseif x < 0 and math.abs(y) <= math.abs(x) then
		return self.MOVE_DIRECTION.LEFT
	else
		return self.MOVE_DIRECTION.RIGHT
	end
end

function GamePadMultiNavigation:moveOutOfBounds(area, afterX, afterY)
	if area[afterX] == nil then
		return true
	end

	if area[afterX][afterY] == nil then
		return true
	end

	return false
end

function GamePadMultiNavigation:moveOperation(direction, cursorArea, cursorIndex, navArea)
	local curArea = self:getAreaTablesById(cursorArea, navArea)
	local oldAreaRecord = self:getAreaTablesById(cursorArea, navArea)
	local curIndexX = cursorIndex.x
	local curIndexY = cursorIndex.y

	if direction == self.MOVE_DIRECTION.UP then
		if self:moveOutOfBounds(curArea, curIndexX - 1, curIndexY) == true then
			if curArea[self.MOVE_DIRECTION.UP] ~= nil and #self:getAreaTablesById(curArea[self.MOVE_DIRECTION.UP], navArea) > 0 then
				self:setCursorArea(curArea[self.MOVE_DIRECTION.UP], navArea)

				curArea = self:getAreaTablesById(self:getCursorArea(navArea), navArea)

				if curArea.Lock ~= nil and curArea.Lock.x ~= nil and curArea.Lock.y ~= nil and oldAreaRecord ~= curArea then
					self:setCursorIndex(curArea.Lock.x, curArea.Lock.y, navArea)
					curArea[curArea.Lock.x][curArea.Lock.y].Focus(curArea.Lock.x, curArea.Lock.y)
				else
					self:setCursorIndex(#curArea, 1, navArea)
					curArea[#curArea][1].Focus(#curArea, 1)
				end
			end
		else
			self:setCursorIndex(curIndexX - 1, curIndexY, navArea)
			curArea[curIndexX - 1][curIndexY].Focus(curIndexX - 1, curIndexY)
		end
	elseif direction == self.MOVE_DIRECTION.DOWN then
		if self:moveOutOfBounds(curArea, curIndexX + 1, curIndexY) == true then
			if curArea[self.MOVE_DIRECTION.DOWN] ~= nil and #self:getAreaTablesById(curArea[self.MOVE_DIRECTION.DOWN], navArea) > 0 then
				self:setCursorArea(curArea[self.MOVE_DIRECTION.DOWN], navArea)

				curArea = self:getAreaTablesById(self:getCursorArea(navArea), navArea)

				if curArea.Lock ~= nil and curArea.Lock.x ~= nil and curArea.Lock.y ~= nil and oldAreaRecord ~= curArea then
					self:setCursorIndex(curArea.Lock.x, curArea.Lock.y, navArea)
					curArea[curArea.Lock.x][curArea.Lock.y].Focus(curArea.Lock.x, curArea.Lock.y)
				else
					self:setCursorIndex(1, 1, navArea)
					curArea[1][1].Focus(1, 1)
				end
			end
		else
			self:setCursorIndex(curIndexX + 1, curIndexY, navArea)
			curArea[curIndexX + 1][curIndexY].Focus(curIndexX + 1, curIndexY)
		end
	elseif direction == self.MOVE_DIRECTION.LEFT then
		if self:moveOutOfBounds(curArea, curIndexX, curIndexY - 1) == true then
			if curArea[self.MOVE_DIRECTION.LEFT] ~= nil and #self:getAreaTablesById(curArea[self.MOVE_DIRECTION.LEFT], navArea) > 0 then
				self:setCursorArea(curArea[self.MOVE_DIRECTION.LEFT], navArea)

				curArea = self:getAreaTablesById(self:getCursorArea(navArea), navArea)

				if curArea.Lock ~= nil and curArea.Lock.x ~= nil and curArea.Lock.y ~= nil and oldAreaRecord ~= curArea then
					self:setCursorIndex(curArea.Lock.x, curArea.Lock.y, navArea)
					curArea[curArea.Lock.x][curArea.Lock.y].Focus(curArea.Lock.x, curArea.Lock.y)
				else
					self:setCursorIndex(1, #curArea[1], navArea)
					curArea[1][#curArea[1]].Focus(1, #curArea[1])
				end
			end
		else
			self:setCursorIndex(curIndexX, curIndexY - 1, navArea)
			curArea[curIndexX][curIndexY - 1].Focus(curIndexX, curIndexY - 1)
		end
	elseif direction == self.MOVE_DIRECTION.RIGHT then
		if self:moveOutOfBounds(curArea, curIndexX, curIndexY + 1) == true then
			if curArea[self.MOVE_DIRECTION.RIGHT] ~= nil and #self:getAreaTablesById(curArea[self.MOVE_DIRECTION.RIGHT], navArea) > 0 then
				self:setCursorArea(curArea[self.MOVE_DIRECTION.RIGHT], navArea)

				curArea = self:getAreaTablesById(self:getCursorArea(navArea), navArea)

				if curArea.Lock ~= nil and curArea.Lock.x ~= nil and curArea.Lock.y ~= nil and oldAreaRecord ~= curArea then
					self:setCursorIndex(curArea.Lock.x, curArea.Lock.y, navArea)
					curArea[curArea.Lock.x][curArea.Lock.y].Focus(curArea.Lock.x, curArea.Lock.y)
				else
					self:setCursorIndex(1, 1, navArea)
					curArea[1][1].Focus(1, 1)
				end
			end
		else
			self:setCursorIndex(curIndexX, curIndexY + 1, navArea)
			curArea[curIndexX][curIndexY + 1].Focus(curIndexX, curIndexY + 1)
		end
	else
		return
	end
end

function GamePadMultiNavigation:focusReset(areaId, navArea)
	if pg.game.input:isUsingGamepad() ~= true then
		return
	end

	self:setCursorArea(areaId, navArea)

	local curArea = self:getAreaTablesById(self:getCursorArea(navArea), navArea)

	if curArea[1] ~= nil and curArea[1][1] ~= nil then
		self:setCursorIndex(1, 1, navArea)
	elseif navArea == self.NAV_AREA.LEFT_STICK then
		self.cursorIndexLeftStick = nil
	elseif navArea == self.NAV_AREA.DPAD then
		self.cursorIndexDPad = nil
	else
		self.cursorIndexRightStick = nil
	end

	local curSlot = self:getCurSlot(navArea)

	if curSlot ~= nil and curSlot.Focus ~= nil then
		curSlot.Focus(self:getCursorIndex(navArea).x, self:getCursorIndex(navArea).y)
	end
end

function GamePadMultiNavigation:specificSet(areaId, x, y, navArea)
	if pg.game.input:isUsingGamepad() ~= true then
		return
	end

	self:setCursorArea(areaId, navArea)

	local curArea = self:getAreaTablesById(self:getCursorArea(navArea), navArea)

	if curArea[x] ~= nil and curArea[x][y] ~= nil then
		self:setCursorIndex(x, y, navArea)
	elseif navArea == self.NAV_AREA.LEFT_STICK then
		self.cursorIndexLeftStick = nil
	elseif navArea == self.NAV_AREA.DPAD then
		self.cursorIndexDPad = nil
	else
		self.cursorIndexRightStick = nil
	end
end

function GamePadMultiNavigation:reFocus(navArea)
	if pg.game.input:isUsingGamepad() ~= true then
		return
	end

	local curSlot = self:getCurSlot(navArea)

	if curSlot ~= nil and curSlot.Focus ~= nil then
		curSlot.Focus(self:getCursorIndex(navArea).x, self:getCursorIndex(navArea).y)
	end
end

function GamePadMultiNavigation:getCurSlot(navArea)
	local curArea = self:getAreaTablesById(self:getCursorArea(navArea))

	if curArea ~= nil and self:getCursorIndex(navArea) ~= nil and curArea[self:getCursorIndex(navArea).x] ~= nil and curArea[self:getCursorIndex(navArea).x][self:getCursorIndex(navArea).y] ~= nil then
		return curArea[self:getCursorIndex(navArea).x][self:getCursorIndex(navArea).y]
	end

	return nil
end

function GamePadMultiNavigation:getSlotByAreaAndIndex(areaId, x, y, navArea)
	local curArea = self:getAreaTablesById(areaId, navArea)

	if curArea ~= nil and x ~= nil and y ~= nil and curArea[x] ~= nil and curArea[x][y] ~= nil then
		return curArea[x][y]
	end

	return nil
end

function GamePadMultiNavigation:delayFocus(areaAndIndexAdjustCallback, delay, navArea)
	if pg.game.input:isUsingGamepad() ~= true then
		return
	end

	TimerManager.addTimer(delay, function()
		if areaAndIndexAdjustCallback ~= nil then
			areaAndIndexAdjustCallback()
		end

		local curSlot = self:getCurSlot(navArea)

		if curSlot == nil or curSlot.Focus == nil then
			return
		end

		curSlot.Focus(self:getCursorIndex(navArea).x, self:getCursorIndex(navArea).y)
	end)
end

function GamePadMultiNavigation:recordCursor(navArea)
	if navArea == self.NAV_AREA.LEFT_STICK then
		self.cursorAreaRecordLeftStick = self:getCursorArea(navArea)
		self.cursorIndexXRecordLeftStick = self:getCursorIndex(navArea).x
		self.cursorIndexYRecordLeftStick = self:getCursorIndex(navArea).y
	elseif navArea == self.NAV_AREA.DPAD then
		self.cursorAreaRecordDPad = self:getCursorArea(navArea)
		self.cursorIndexXRecordDPad = self:getCursorIndex(navArea).x
		self.cursorIndexYRecordDPad = self:getCursorIndex(navArea).y
	else
		self.cursorAreaRecordRightStick = self:getCursorArea(navArea)
		self.cursorIndexXRecordRightStick = self:getCursorIndex(navArea).x
		self.cursorIndexYRecordRightStick = self:getCursorIndex(navArea).y
	end
end

function GamePadMultiNavigation:resumeCursor(navArea)
	if navArea == self.NAV_AREA.LEFT_STICK then
		self:setCursorArea(self.cursorAreaRecordLeftStick, navArea)
		self:setCursorIndex(self.cursorIndexXRecordLeftStick, self.cursorIndexYRecordLeftStick, navArea)

		self.cursorAreaRecordLeftStick = nil
		self.cursorIndexXRecordLeftStick = nil
		self.cursorIndexYRecordLeftStick = nil
	elseif navArea == self.NAV_AREA.DPAD then
		self:setCursorArea(self.cursorAreaRecordDPad, navArea)
		self:setCursorIndex(self.cursorIndexXRecordDPad, self.cursorIndexYRecordDPad, navArea)

		self.cursorAreaRecordDPad = nil
		self.cursorIndexXRecordDPad = nil
		self.cursorIndexYRecordDPad = nil
	else
		self:setCursorArea(self.cursorAreaRecordRightStick, navArea)
		self:setCursorIndex(self.cursorIndexXRecordRightStick, self.cursorIndexYRecordRightStick, navArea)

		self.cursorAreaRecordRightStick = nil
		self.cursorIndexXRecordRightStick = nil
		self.cursorIndexYRecordRightStick = nil
	end
end

function GamePadMultiNavigation:setLock(areaId, needLock, x, y, navArea)
	local curArea = self:getAreaTablesById(areaId, navArea)

	if needLock == true then
		curArea.Lock = {
			x = x,
			y = y
		}
	else
		curArea.Lock = nil
	end
end

function GamePadMultiNavigation:onDestroy()
	if self.tickTimer then
		self.ctrl:killTimer(self.tickTimer)
	end

	self.cursorAreaLeftStick = nil
	self.cursorIndexLeftStick = nil
	self.cursorAreaDPad = nil
	self.cursorIndexDPad = nil
	self.cursorAreaRightStick = nil
	self.cursorIndexRightStick = nil
	self.tickTimer = nil
	self.tickPauseLeftStick = nil
	self.tickPauseDPadUp = nil
	self.tickPauseDPadDown = nil
	self.tickPauseDPadLeft = nil
	self.tickPauseDPadRight = nil
	self.tickPauseRightStick = nil
	self.leftStickMoveDisableTime = nil
	self.dPadUpDisableTime = nil
	self.dPadDownDisableTime = nil
	self.dPadLeftDisableTime = nil
	self.dPadRightDisableTime = nil
	self.rightStickMoveDisableTime = nil
	self.leftStickContinueMoveDelay = nil
	self.dPadUpContinueMoveDelay = nil
	self.dPadDownContinueMoveDelay = nil
	self.dPadLeftContinueMoveDelay = nil
	self.dPadRightContinueMoveDelay = nil
	self.rightStickContinueMoveDelay = nil
	self.leftStickMoveCount = nil
	self.dPadUpMoveCount = nil
	self.dPadDownMoveCount = nil
	self.dPadLeftMoveCount = nil
	self.dPadRightMoveCount = nil
	self.rightStickMoveCount = nil
	self.leftStickMoveVec2X = nil
	self.leftStickMoveVec2Y = nil
	self.dPadMoveVec2X = nil
	self.dPadMoveVec2Y = nil
	self.rightStickMoveVec2X = nil
	self.rightStickMoveVec2Y = nil
	self.dPadUpRunOnce = false
	self.dPadDownRunOnce = false
	self.dPadLeftRunOnce = false
	self.dPadRightRunOnce = false

	UIComponent.onDestroy(self)
end

return GamePadMultiNavigation
