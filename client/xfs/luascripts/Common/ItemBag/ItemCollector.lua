-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\ItemBag\\ItemCollector.lua

local class = require("Core.Framework.Class")
local NoticeDef = require("Common.NoticeDef")
local ItemCollector = class.LightClass("ItemCollector")
local __emptyTable = {}

function ItemCollector:ctor(dict)
	self.__collected = {}
	self._dict = dict
	self._locked = {}
	self._lastError = nil
end

function ItemCollector:__setLastError(error)
	self._lastError = error
end

function ItemCollector:__getCollectedOrAdd(sid, item)
	local collected = self.__collected[sid]

	if collected == nil then
		collected = {
			count = 0,
			item = item
		}
		self.__collected[sid] = collected
	end

	return collected
end

function ItemCollector:__getItemsArr()
	if self._items_arr == nil then
		self._items_arr = self._dict:toArrayByCfgId()
	end

	return self._items_arr
end

function ItemCollector:lockItem(sid)
	self._locked[sid] = true
end

function ItemCollector:collect(sid, count, validator)
	if self._lastError then
		return false, self._lastError
	end

	if sid == nil then
		self:__setLastError(NoticeDef.BAG_INVALID_PARAM)

		return false, self._lastError
	end

	if count == nil or count == 0 then
		self:__setLastError(NoticeDef.BAG_INVALID_COUNT)

		return false, self._lastError
	end

	local item = self._dict[sid]

	if item == nil then
		self:__setLastError(NoticeDef.BAG_NOT_FOUND)

		return false, self._lastError
	end

	local collectedInfo = self:__getCollectedOrAdd(sid, item)

	if self._locked[sid] then
		self:__setLastError(NoticeDef.BAG_OBJECT_IN_OPERATE)

		return false, self._lastError
	end

	if validator then
		local ok, err = validator(item)

		if not ok then
			if err then
				self:__setLastError(err)
			else
				self:__setLastError(NoticeDef.BAG_NOT_SATISFIED)
			end

			return false, self._lastError
		end
	end

	if count <= -1 then
		count = item.count
	end

	collectedInfo.count = collectedInfo.count + count

	if collectedInfo.count > item.count then
		self:__setLastError(NoticeDef.BAG_COUNT_NOT_ENOUGH)

		return false, self._lastError
	end

	return true
end

function ItemCollector:collectFromSidPairs(sidPairs, validator)
	sidPairs = sidPairs or __emptyTable

	local cnt = #sidPairs

	if cnt % 2 ~= 0 then
		self:__setLastError(NoticeDef.BAG_INVALID_PARAM)

		return false, self:getLastError()
	end

	for i = 1, #sidPairs, 2 do
		local sid = sidPairs[i]

		cnt = sidPairs[i + 1]

		local ret, error = self:collect(sid, cnt, validator)

		if not ret then
			return false, self:getLastError()
		end
	end

	return true
end

function ItemCollector:collectByFilter(filter, count)
	if type(filter) ~= "function" then
		error("filter is not function type!")
	end

	if self._lastError then
		return false, self._lastError
	end

	if count == nil or count == 0 then
		self:__setLastError(NoticeDef.BAG_INVALID_COUNT)

		return false, self._lastError
	end

	local expectedCount = count
	local items = self:__getItemsArr()

	for i = #items, 1, -1 do
		local item = items[i]
		local sid = item.genID

		if filter(item) then
			local collectedInfo = self:__getCollectedOrAdd(sid, item)

			if count <= -1 then
				collectedInfo.count = collectedInfo.count + item.count

				if collectedInfo.count > item.count then
					self:__setLastError(NoticeDef.BAG_COUNT_NOT_ENOUGH)

					return false, self._lastError
				end
			else
				local countLeft = item.count - collectedInfo.count

				if count <= countLeft then
					collectedInfo.count = collectedInfo.count + count
					count = 0
				else
					collectedInfo.count = item.count
					count = count - countLeft
				end

				if count <= 0 then
					break
				end
			end
		end
	end

	if count > 0 then
		if count == expectedCount then
			self:__setLastError(NoticeDef.BAG_NOT_FOUND)
		else
			self:__setLastError(NoticeDef.BAG_COUNT_NOT_ENOUGH)
		end

		return false, self._lastError
	end

	return true
end

function ItemCollector:collectByID(id, count, source, includeLocked)
	local function filter(item)
		if not includeLocked and item:isStatusLocked() then
			return false
		end

		if not item:checkDel(source) then
			return false
		end

		return item.id == id
	end

	return self:collectByFilter(filter, count)
end

function ItemCollector:collectByIDWithBind(id, count, source, includeLocked, canDelExpired)
	local function filter(item)
		if not includeLocked and item:isStatusLocked() then
			return false
		end

		if not canDelExpired and not item:canUse() then
			return false
		end

		if not item:checkDel(source) then
			return false
		end

		return item.id == id
	end

	return self:collectByFilter(filter, count)
end

function ItemCollector:extractAll(source, includeLocked)
	local dict = self._dict

	if self._lastError or dict == nil then
		return nil, self._lastError
	end

	local items = {}

	for sid, info in pairs(self.__collected) do
		local item, errorNo = dict:takeN(sid, info.count, source, includeLocked)

		if item == nil then
			error(string.format("item not found when extracting from dict, %s", tostring(sid)))
		end

		table.insert(items, item)
	end

	if #items == 0 then
		return nil, NoticeDef.BAG_NOT_FOUND
	end

	return items
end

function ItemCollector:getLastError()
	return self._lastError
end

function ItemCollector:getCollected()
	if self:getLastError() then
		return function()
			return nil, nil
		end
	end

	local iter = pairs(self.__collected)
	local sid, info

	return function()
		sid, info = iter(self.__collected, sid)

		if info == nil then
			return nil, nil
		end

		return info.item, info.count
	end, iter, nil
end

function ItemCollector:failed()
	return self:getLastError() ~= nil
end

return ItemCollector
