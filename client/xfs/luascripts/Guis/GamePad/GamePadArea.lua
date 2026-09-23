-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\GamePad\\GamePadArea.lua

local Class = require("Core.Framework.Class")
local GamePadArea = Class.LightClass("GamePadArea")
local GamePadSlot = require("Guis.GamePad.GamePadSlot")
local GamePadConst = require("Guis.GamePad.GamePadConst")

function GamePadArea:ctor()
	return
end

function GamePadArea:initArea(navigation, areaId)
	self._navigation = navigation
	self._areaId = areaId
	self._slot_map = {}
	self._move_dir = {}
	self._curSlot = nil
	self._matchType = GamePadConst.MATCH_MODE.MATCH_DIRECTION
	self._enterAreaCallSlot = nil
	self._cur_Coordinate = Vector2.New(0, 0)
end

function GamePadArea:onEnable()
	local curSlot = self:getCurSlot()

	if curSlot then
		curSlot:focusInner()
	end
end

function GamePadArea:onDisable()
	local curSlot = self:getCurSlot()

	if curSlot then
		curSlot:disFocus()
	end
end

function GamePadArea:bindUWidget(x, y, uWidget)
	local slot = self:getSlot(x, y)

	if slot == nil then
		return
	end

	slot:bindUWidget(uWidget)

	local curSlot = self:getCurSlot()

	if curSlot == slot then
		curSlot:focusInner()
	end
end

function GamePadArea:getAreaId()
	return self._areaId
end

function GamePadArea:addSlot(x, y)
	local slot = GamePadSlot.new()

	slot:initSlot(self._navigation, x, y)

	if self._slot_map[x] == nil then
		self._slot_map[x] = {}
	end

	self._slot_map[x][y] = slot

	return slot
end

function GamePadArea:setMoveableArea(up, down, left, right)
	self._move_dir[GamePadConst.MOVE_DIRECTION.UP] = up
	self._move_dir[GamePadConst.MOVE_DIRECTION.DOWN] = down
	self._move_dir[GamePadConst.MOVE_DIRECTION.LEFT] = left
	self._move_dir[GamePadConst.MOVE_DIRECTION.RIGHT] = right
end

function GamePadArea:getMoveDirectionAreaId(direction)
	return self._move_dir[direction] or self._areaId
end

function GamePadArea:isOutOfBounds(direction)
	local n_x, n_y = self:getNextSlotPos(direction)

	return self:getSlot(n_x, n_y) == nil
end

function GamePadArea:moveSlot(direction)
	local n_x, n_y = self:getNextSlotPos(direction)

	self:focusSlot(n_x, n_y)
end

function GamePadArea:getNextSlotPos(direction)
	local curSlot = self:getCurSlot()

	if curSlot == nil then
		return 1, 1
	end

	local x, y = curSlot:getSlotPos()

	if direction == GamePadConst.MOVE_DIRECTION.UP then
		x = x - 1

		while x > 0 and (self._slot_map[x][y] == nil or self._slot_map[x][y].emptySlot) and y > 1 do
			y = y - 1
		end
	elseif direction == GamePadConst.MOVE_DIRECTION.DOWN then
		x = x + 1

		local maxX = #self._slot_map

		while x < maxX and (self._slot_map[x][y] == nil or self._slot_map[x][y].emptySlot) and y > 1 do
			y = y - 1
		end
	elseif direction == GamePadConst.MOVE_DIRECTION.LEFT then
		y = y - 1
	elseif direction == GamePadConst.MOVE_DIRECTION.RIGHT then
		y = y + 1
	end

	return x, y
end

function GamePadArea:setCurSlot(x, y)
	self._cur_Coordinate:Set(x, y)
end

function GamePadArea:getCurSlot()
	local x = self._cur_Coordinate.x
	local y = self._cur_Coordinate.y

	if x == 0 or y == 0 then
		return nil
	end

	return self._slot_map[x][y]
end

function GamePadArea:getSlot(x, y)
	if self._slot_map[x] == nil then
		return nil
	end

	return self._slot_map[x][y]
end

function GamePadArea:getLastSlotPos()
	local curSlot = self:getCurSlot()

	return curSlot:getSlotPos()
end

function GamePadArea:focusSlot(x, y)
	x = x or 1
	y = y or 1

	local slot = self:getSlot(x, y)

	if slot == nil then
		return
	end

	local curSlot = self:getCurSlot()

	if curSlot and curSlot:isSameSlot(slot) then
		return
	end

	if curSlot then
		curSlot:disFocus()
	end

	slot:focusInner()
	self:setCurSlot(x, y)
end

function GamePadArea:isSameArea(areaId)
	return self._areaId == areaId
end

function GamePadArea:enterArea(x, y)
	self:focusSlot(x, y)
end

function GamePadArea:exitArea()
	local curSlot = self:getCurSlot()

	if curSlot then
		curSlot:disFocus()
	end
end

function GamePadArea:setMatchType(matchMode)
	self._matchType = matchMode
end

function GamePadArea:findCustomMatchSlot()
	if self._enterAreaCallSlot == nil then
		return false
	end

	local slot_pos = self._enterAreaCallSlot()

	if slot_pos == nil or #slot_pos < 2 then
		return false
	end

	return slot_pos
end

function GamePadArea:maxRawCount()
	return #self._slot_map
end

function GamePadArea:maxColCount()
	local maxX = #self._slot_map

	if maxX <= 0 then
		return 0
	end

	local maxY = #self._slot_map[1]

	for _, v in ipairs(self._slot_map) do
		local num = #v

		if maxY < num then
			maxY = num
		end
	end

	return maxY
end

function GamePadArea:findFirstMatchSlot(direction, oldSlot)
	local slot_pos = self:findCustomMatchSlot()

	if slot_pos then
		return slot_pos
	end

	local maxX = self:maxRawCount()
	local maxY = self:maxColCount()

	if maxY <= 0 or maxX <= 0 then
		return false
	end

	local validX = 1
	local validY = 1
	local findRes = false
	local moveMode = self._matchType

	if moveMode == GamePadConst.MATCH_MODE.MATCH_FIRST then
		findRes, validX, validY = self:findFromFirst(maxX, maxY)
	elseif moveMode == GamePadConst.MATCH_MODE.MATCH_OLD_CACHE then
		findRes, validX, validY = self:findFromCache()
	elseif moveMode == GamePadConst.MATCH_MODE.MATCH_DIRECTION then
		findRes, validX, validY = self:findFromDirection(direction, oldSlot)
	elseif moveMode == GamePadConst.MATCH_MODE.MATCH_DISTANCE then
		if self:isOutOfBounds(direction) then
			findRes, validX, validY = self:findFromDirection(direction, oldSlot)
		else
			findRes, validX, validY = self:findFromDistance(direction, oldSlot)
		end
	end

	if findRes then
		return {
			validX,
			validY
		}
	end

	for x = 1, maxX do
		for y = 1, maxY do
			if not self._slot_map[x][y].emptySlot then
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

	return {
		validX,
		validY
	}
end

function GamePadArea:findFromFirst(maxX, maxY)
	local findRes = false
	local validX = 1
	local validY = 1

	for x = 1, maxX do
		for y = 1, maxY do
			if not self._slot_map[x][y].emptySlot then
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

	return findRes, validX, validY
end

function GamePadArea:findFromCache()
	local findRes = false
	local validX = 1
	local validY = 1
	local curSlot = self:getCurSlot()

	if curSlot then
		validX, validY = curSlot:getSlotPos()
		findRes = true
	end

	return findRes, validX, validY
end

function GamePadArea:findFromDirection(direction, oldSlot)
	local maxX = self:maxRawCount()
	local maxY = self:maxColCount()
	local findRes = false
	local validX = 1
	local validY = 1
	local cur_x, cur_y = oldSlot:getSlotPos()

	if direction == GamePadConst.MOVE_DIRECTION.UP then
		local y = cur_y or 1

		if maxY < y then
			y = maxY
		end

		for x = maxX, 1, -1 do
			if self._slot_map[x] and self._slot_map[x][y] and not self._slot_map[x][y].emptySlot then
				validX = x
				validY = y
				findRes = true

				break
			end
		end
	elseif direction == GamePadConst.MOVE_DIRECTION.DOWN then
		local y = cur_y or 1

		if maxY < y then
			y = maxY
		end

		for x = 1, maxX do
			if self._slot_map[x] and self._slot_map[x][y] and not self._slot_map[x][y].emptySlot then
				validX = x
				validY = y
				findRes = true

				break
			end
		end
	elseif direction == GamePadConst.MOVE_DIRECTION.LEFT then
		local x = cur_x or 1

		if maxX < x then
			x = maxX
		end

		for y = maxY, 1, -1 do
			if self._slot_map[x][y] and not self._slot_map[x][y].emptySlot then
				validX = x
				validY = y
				findRes = true

				break
			end
		end
	elseif direction == GamePadConst.MOVE_DIRECTION.RIGHT then
		local x = cur_x or 1

		if maxX < x then
			x = maxX
		end

		for y = 1, maxY do
			if self._slot_map[x][y] and not self._slot_map[x][y].emptySlot then
				validX = x
				validY = y
				findRes = true

				break
			end
		end
	end

	return findRes, validX, validY
end

function GamePadArea:findFromDistance(direction, oldSlot)
	local uWidget = oldSlot:getBindUWidget()

	if IsNil(uWidget) then
		return false, 0, 0
	end

	local minX, maxX, minY, maxY = self:minMaxBounds(oldSlot, direction)
	local anPos = uWidget.anchoredPosition
	local findRes = false
	local validX = 1
	local validY = 1
	local min = math.maxInt

	for x, subMap in ipairs(self._slot_map) do
		if minX <= x and x <= maxX then
			for y, v in ipairs(subMap) do
				if minY <= y and y <= maxY then
					local cWidget = v:getBindUWidget()

					if NotNil(cWidget) then
						local snPos = cWidget.anchoredPosition
						local dis = Vector2.Distance(anPos.x, anPos.y, snPos.x, snPos.y)

						if dis < min then
							findRes = true
							validX = x
							validY = y
							min = dis
						end
					end
				end
			end
		end
	end

	return findRes, validX, validY
end

function GamePadArea:minMaxBounds(slot, direction)
	local o_x, o_y = slot:getSlotPos()
	local minX = 1
	local minY = 1
	local maxX = self:maxRawCount()
	local maxY = self:maxColCount()

	maxX = o_x + GamePadConst.DIRECTION_MOVE_VALUE[direction]
	minX = o_x + GamePadConst.DIRECTION_MOVE_VALUE[direction]
	maxY = o_y + GamePadConst.DIRECTION_MOVE_VALUE[direction]
	minY = o_y + GamePadConst.DIRECTION_MOVE_VALUE[direction]

	return minX, maxX, minY, maxY
end

function GamePadArea:invokeFunc(funcIdx)
	local curSlot = self:getCurSlot()

	if curSlot == nil then
		return
	end

	curSlot:invokeFunc(funcIdx)
end

function GamePadArea:invokeBeginLongPress(funcIdx)
	local curSlot = self:getCurSlot()

	if curSlot == nil then
		return
	end

	curSlot:invokeBeginLongPress(funcIdx)
end

function GamePadArea:invokeLongPress(funcIdx)
	local curSlot = self:getCurSlot()

	if curSlot == nil then
		return
	end

	curSlot:invokeLongPress(funcIdx)
end

function GamePadArea:invokeEndLongPress(funcIdx)
	local curSlot = self:getCurSlot()

	if curSlot == nil then
		return
	end

	curSlot:invokeEndLongPress(funcIdx)
end

function GamePadArea:clear()
	table.clear(self._slot_map)
end

function GamePadArea:destroy()
	local curSlot = self:getCurSlot()

	if curSlot then
		curSlot:disFocus()
	end

	self._cur_Coordinate:Set(0, 0)
end

return GamePadArea
