-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Utils\\ItemTTLUtils.lua

local LoggerManager = require("Core.Log.LoggerManager")
local Const = require("Common.Const.Const")
local ItemConst = require("Common.Const.ItemConst")
local TimeUtils = require("Common.Utils.TimeUtils")
local Utils = require("Common.Utils.Utils")
local logger = LoggerManager.getLogger("ItemTTLUtils")
local ItemTTLUtils = {
	STATE_EXPIRED = 3,
	STATE_ACTIVE = 2,
	STATE_NOT_STARTED = 1,
	STATE_NONE = 0,
	REMAINING_TEXT_STYLE = "Hint_BgD"
}

local function unwrapConfigValue(value)
	if type(value) ~= "table" then
		return value
	end

	return value[2] or value.value or value[1]
end

local function parseDateTime(value)
	value = unwrapConfigValue(value)

	if type(value) ~= "string" or value == "" then
		return nil, "empty date time"
	end

	local pattern = value:find("/", 1, true) and "(%d+)/(%d+)/(%d+)/(%d+):(%d+):(%d+)" or "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)"
	local timestamp = TimeUtils.utcStringToTimestamp(value, pattern)

	if not timestamp then
		return nil, "invalid date time: " .. value
	end

	return timestamp
end

local function parseClock(value)
	value = unwrapConfigValue(value)

	if type(value) ~= "string" or value == "" then
		return nil, "empty clock"
	end

	local hour, min, sec = value:match("^(%d+):(%d+):(%d+)$")

	hour, min, sec = tonumber(hour), tonumber(min), tonumber(sec)

	if not hour or hour > 23 or not min or min > 59 or not sec or sec > 59 then
		return nil, "invalid clock: " .. value
	end

	return hour * 3600 + min * 60 + sec
end

local function resolveInvId(item, invId)
	if invId ~= nil then
		return invId
	end

	return item:getInvID()
end

local function logTTLFailure(message, item, invId, reason)
	logger:error("%s, itemId=%s, genID=%s, invId=%s, reason=%s", message, tostring(item and item.id), tostring(item and item.genID), tostring(item and resolveInvId(item, invId)), tostring(reason))
end

local function projectRange(item, startTime, endTime)
	item.vaildStartTime = startTime
	item.vaildEndTime = endTime
end

local function persistAndProject(item, startTime, endTime)
	local props = item:getProps()

	if not props then
		return false, "missing props container"
	end

	startTime = ToInt(startTime)
	endTime = ToInt(endTime)
	props[ItemConst.ItemPropertyDef.TTL] = {
		startTime = startTime,
		endTime = endTime
	}

	projectRange(item, startTime, endTime)

	return true
end

local function calculateAndApply(item, itemCfg, acquiredAt, invId)
	local startTime, endTime, ttlError = ItemTTLUtils.calculateRange(itemCfg, acquiredAt)

	if ttlError then
		logTTLFailure("invalid item ttl config", item, invId, ttlError)

		return false, ttlError
	end

	local ok, persistError = persistAndProject(item, startTime, endTime)

	if not ok then
		logTTLFailure("item ttl persistence failed", item, invId, persistError)

		return false, persistError
	end

	return true
end

function ItemTTLUtils.calculateRange(itemCfg, acquiredAt)
	acquiredAt = acquiredAt or 0

	local ttlType = itemCfg and tonumber(itemCfg.ttlType) or 0

	if ttlType == 0 then
		return 0, 0
	end

	if ttlType == 1 then
		local duration = tonumber(itemCfg.ttlDuring) or 0

		if duration <= 0 then
			return 0, 0, "invalid ttlDuring"
		end

		return acquiredAt, acquiredAt + duration
	end

	if ttlType == 2 then
		local ttlStartRefId = itemCfg.ttlStartRefId
		local startTime, startError

		if ttlStartRefId and ttlStartRefId ~= 0 then
			startTime = Utils.getConfigTimeOfAreaByData(itemCfg.ttlStart, ttlStartRefId)

			if startTime then
				-- block empty
			end

			startError = "invalid ttlStartRefId"
		else
			startTime, startError = parseDateTime(itemCfg.ttlStart)
		end

		local ttlEndRefId = itemCfg.ttlEndRefId
		local endTime, endError

		if ttlEndRefId and ttlEndRefId ~= 0 then
			endTime = Utils.getConfigTimeOfAreaByData(itemCfg.ttlEnd, ttlEndRefId)

			if endTime then
				-- block empty
			end

			endError = "invalid ttlEndRefId"
		else
			endTime, endError = parseDateTime(itemCfg.ttlEnd)
		end

		if not startTime or not endTime or endTime <= startTime then
			return 0, 0, startError or endError or "invalid fixed time range"
		end

		return startTime, endTime
	end

	local clockSeconds, clockError = parseClock(itemCfg.ttlTime)

	if not clockSeconds then
		return 0, 0, clockError
	end

	if ttlType == 3 then
		local endTime = TimeUtils.getAreaDayBegin(acquiredAt) + clockSeconds

		if endTime <= acquiredAt then
			endTime = endTime + Const.SECONDS_ONE_DAY
		end

		return acquiredAt, endTime
	end

	if ttlType == 4 then
		local weekDay = tonumber(itemCfg.ttlWeekDay) or 0

		if weekDay < 1 or weekDay > 7 then
			return 0, 0, "invalid ttlWeekDay"
		end

		local endTime = TimeUtils.getAreaWeekBegin(acquiredAt) + (weekDay - 1) * Const.SECONDS_ONE_DAY + clockSeconds

		if endTime <= acquiredAt then
			endTime = endTime + Const.SECONDS_ONE_WEEK
		end

		return acquiredAt, endTime
	end

	return 0, 0, "invalid ttlType"
end

function ItemTTLUtils.isEnabled(itemCfg)
	return itemCfg and (tonumber(itemCfg.ttlType) or 0) > 0
end

function ItemTTLUtils.initializeForNewItem(item, itemCfg, acquiredAt, invId)
	if not ItemTTLUtils.isEnabled(itemCfg) then
		projectRange(item, 0, 0)

		return true
	end

	return calculateAndApply(item, itemCfg, acquiredAt, invId)
end

function ItemTTLUtils.restoreFromProps(item, itemCfg, acquiredAt, invId)
	if not ItemTTLUtils.isEnabled(itemCfg) then
		projectRange(item, 0, 0)

		return true
	end

	local props = item:getProps()
	local ttlData = props[ItemConst.ItemPropertyDef.TTL]

	if ttlData ~= nil then
		local ttlError
		local startTime, endTime = 0, 0

		if type(ttlData) ~= "table" then
			ttlError = "ttl is not a table"
		else
			startTime = ToInt(ttlData.startTime)
			endTime = ToInt(ttlData.endTime)

			if endTime <= startTime then
				ttlError = "endTime must be greater than startTime"
			end
		end

		if not ttlError then
			projectRange(item, startTime, endTime)

			return true
		end

		logTTLFailure("corrupt item ttl data", item, invId, ttlError)
	end

	return calculateAndApply(item, itemCfg, acquiredAt, invId)
end

function ItemTTLUtils.getState(item, now)
	if not item then
		return ItemTTLUtils.STATE_NONE
	end

	now = tonumber(now) or 0

	local startTime = tonumber(item.vaildStartTime) or 0
	local endTime = tonumber(item.vaildEndTime) or 0

	if startTime <= 0 and endTime <= 0 then
		return ItemTTLUtils.STATE_NONE
	end

	if startTime > 0 and now < startTime then
		return ItemTTLUtils.STATE_NOT_STARTED
	end

	if endTime > 0 and endTime <= now then
		return ItemTTLUtils.STATE_EXPIRED
	end

	return ItemTTLUtils.STATE_ACTIVE
end

function ItemTTLUtils.shouldHideUseButton(state, ttlChangeItem)
	return state == ItemTTLUtils.STATE_NOT_STARTED or state == ItemTTLUtils.STATE_EXPIRED
end

function ItemTTLUtils.shouldHideCompoundButton(state, ttlChangeItem)
	if state == ItemTTLUtils.STATE_NOT_STARTED then
		return true
	end

	return state == ItemTTLUtils.STATE_EXPIRED and (tonumber(ttlChangeItem) or 0) > 0
end

function ItemTTLUtils.getTTLStatusTextKey(state)
	if state == ItemTTLUtils.STATE_NOT_STARTED then
		return "AVAILABLE_TIME"
	end

	if state == ItemTTLUtils.STATE_ACTIVE then
		return "UNAVAILABLE_TIME"
	end

	if state == ItemTTLUtils.STATE_EXPIRED then
		return "EXPIRED"
	end
end

function ItemTTLUtils.formatTTLRemainingText(text)
	return string.format("<style=%s>%s</style>", ItemTTLUtils.REMAINING_TEXT_STYLE, tostring(text or ""))
end

function ItemTTLUtils.isExpired(item, now)
	return ItemTTLUtils.getState(item, now) == ItemTTLUtils.STATE_EXPIRED
end

function ItemTTLUtils.canStack(left, right, now)
	if not left or not right or (left.vaildEndTime or 0) ~= (right.vaildEndTime or 0) then
		return false
	end

	if (left.vaildStartTime or 0) == (right.vaildStartTime or 0) then
		return true
	end

	if not now then
		return false
	end

	local leftState = ItemTTLUtils.getState(left, now)
	local rightState = ItemTTLUtils.getState(right, now)

	return leftState == rightState and (leftState == ItemTTLUtils.STATE_ACTIVE or leftState == ItemTTLUtils.STATE_EXPIRED)
end

return ItemTTLUtils
