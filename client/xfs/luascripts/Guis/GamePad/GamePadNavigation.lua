-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\GamePad\\GamePadNavigation.lua

local Time = require("Core.Common.Time")
local Class = require("Core.Framework.Class")
local LoggerManager = require("Core.Log.LoggerManager")
local logger = LoggerManager.getLogger("GamePadNavigation")
local GamePadConst = require("Guis.GamePad.GamePadConst")
local GamePadArea = require("Guis.GamePad.GamePadArea")
local GamePadNavigation = Class.LightClass("GamePadNavigationV2")

function GamePadNavigation:ctor()
	self._curArea = nil
	self._areaTb = {}
	self._trigger_move = false
	self._move_vec2 = Vector2.New(0, 0)
	self._move_time = 0
	self._key_state = {}
	self._unUse_key = {}
	self._need_handle_event = false
end

function GamePadNavigation:onEnable()
	self._curArea:onEnable()
end

function GamePadNavigation:onDisable()
	self._curArea:onDisable()
end

function GamePadNavigation:onHandleEvent()
	self:handleLeftStickMoveEvent()
	self:handleRightStickEvent()
	self:handleInputEvent()
end

function GamePadNavigation:handleLeftStickMoveEvent()
	if self._trigger_move == false then
		return
	end

	if Time.realSecondCache - self._move_time < GamePadConst.LEFT_STICK_MOVE_DELAY_SLOW then
		return
	end

	self._move_time = Time.realSecondCache

	local x = self._move_vec2.x
	local y = self._move_vec2.y
	local direction = self:checkMoveDirection(x, y)

	self:moveSlot(direction)
end

function GamePadNavigation:handleRightStickEvent()
	return
end

function GamePadNavigation:handleInputEvent()
	if self._need_handle_event == false then
		return
	end

	if self._curArea == nil then
		return
	end

	table.clear(self._unUse_key)

	local curTime = Time.realSecondCache
	local inv = GamePadConst.LONG_PRESS_THRESHOLD

	for fIdx, s_d in pairs(self._key_state) do
		if s_d.state == GamePadConst.INPUT_STATE.PERFORMED then
			if inv <= curTime - s_d.startTime then
				if not s_d.hasTriggerLongPress then
					self._curArea:invokeBeginLongPress(fIdx)

					s_d.hasTriggerLongPress = true
				else
					self._curArea:invokeLongPress(fIdx)
				end
			end
		else
			if s_d.hasTriggerLongPress then
				self._curArea:invokeEndLongPress(fIdx)
			else
				self._curArea:invokeFunc(fIdx)
			end

			self._unUse_key[#self._unUse_key + 1] = fIdx
		end
	end

	if #self._unUse_key == 0 then
		return
	end

	for _, fIdx in ipairs(self._unUse_key) do
		self._key_state[fIdx] = nil
	end

	self:refreshEventState()
end

function GamePadNavigation:triggerEvent(inputInfo, funcIdx)
	if funcIdx == GamePadConst.FUNCTION_INDEX.LEFT_STICK then
		self:triggerLeftStickMove(inputInfo)
	elseif funcIdx == GamePadConst.FUNCTION_INDEX.RIGHT_STICK then
		self:triggerRightStick(inputInfo)
	else
		self:handleKeyEvent(inputInfo, funcIdx)
	end
end

function GamePadNavigation:handleKeyEvent(inputInfo, funcIdx)
	if inputInfo.phase == "Performed" then
		self._key_state[funcIdx] = {
			idx = funcIdx,
			state = GamePadConst.INPUT_STATE.PERFORMED,
			startTime = Time.realSecondCache
		}

		self:refreshEventState()
	elseif inputInfo.phase == "Canceled" then
		local key_state = self._key_state[funcIdx]

		if key_state then
			key_state.state = GamePadConst.INPUT_STATE.CANCELED
		end
	end
end

function GamePadNavigation:refreshEventState()
	self._need_handle_event = table.nums(self._key_state) > 0
end

function GamePadNavigation:triggerLeftStickMove(inputInfo)
	local continue = true
	local x = inputInfo.valueVec2.x
	local y = inputInfo.valueVec2.y

	if math.abs(x) <= GamePadConst.LEFT_STICK_MOVE_THRESHOLD and math.abs(y) <= GamePadConst.LEFT_STICK_MOVE_THRESHOLD then
		continue = false
		x = 0
		y = 0
	end

	self._trigger_move = continue
	self._move_vec2.x = x
	self._move_vec2.y = y
end

function GamePadNavigation:triggerRightStick(inputInfo)
	if inputInfo.phase == "Performed" then
		-- block empty
	elseif inputInfo.phase == "Canceled" then
		-- block empty
	end
end

function GamePadNavigation:checkMoveDirection(x, y)
	local moveDirection = GamePadConst.MOVE_DIRECTION.NONE

	if x == 0 and y == 0 then
		return moveDirection
	end

	local abs_x = math.abs(x)
	local abs_y = math.abs(y)

	if abs_y <= abs_x then
		moveDirection = x > 0 and GamePadConst.MOVE_DIRECTION.RIGHT or GamePadConst.MOVE_DIRECTION.LEFT
	else
		moveDirection = y > 0 and GamePadConst.MOVE_DIRECTION.UP or GamePadConst.MOVE_DIRECTION.DOWN
	end

	return moveDirection
end

function GamePadNavigation:focusArea(areaId, x, y)
	local area = self:getArea(areaId)

	if area == nil then
		return
	end

	x = x or 1
	y = y or 1

	if self._curArea and self._curArea:isSameArea(areaId) then
		area:focusSlot(x, y)

		return
	end

	if self._curArea then
		self._curArea:exitArea()
	end

	area:enterArea(x, y)

	self._curArea = area
end

function GamePadNavigation:addNewArea(areaId)
	local area = self._areaTb[areaId]

	if area == nil then
		area = GamePadArea.new()

		area:initArea(self.navigation, areaId)
	else
		area:clear()
	end

	self._areaTb[areaId] = area

	return area
end

function GamePadNavigation:getArea(areaId)
	return self._areaTb[areaId]
end

function GamePadNavigation:moveSlot(direction)
	if direction == GamePadConst.MOVE_DIRECTION.NONE then
		return
	end

	local area = self._curArea

	if area:isOutOfBounds(direction) then
		local nextAreaId = area:getMoveDirectionAreaId(direction)
		local slot = area:getCurSlot()

		self:moveToNewArea(nextAreaId, direction, slot)
	else
		area:moveSlot(direction)
	end
end

function GamePadNavigation:moveToNewArea(nextAreaId, direction, oldSlot)
	local newArea = self:getArea(nextAreaId)
	local slotPos = newArea:findFirstMatchSlot(direction, oldSlot)

	if slotPos then
		self:focusArea(nextAreaId, slotPos[1], slotPos[2])
	else
		nextAreaId = newArea:getMoveDirectionAreaId(direction)

		self:moveToNewArea(nextAreaId, direction, oldSlot)
	end
end

function GamePadNavigation:onDestroy()
	if self._curArea then
		self._curArea:destroy()
	end

	self._curArea = nil
end

return GamePadNavigation
