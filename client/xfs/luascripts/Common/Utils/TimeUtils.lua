-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Utils\\TimeUtils.lua

local Time = require("Core.Common.Time")
local Const = require("Common.Const.Const")
local math_abs = math.abs
local TimeUtils = {}

function TimeUtils.getServerDayDiff(time1, time2)
	if not time1 or not time2 then
		return math.huge
	end

	local dayStartTime1 = TimeUtils.getServerDayBegin(time1)
	local dayStartTime2 = TimeUtils.getServerDayBegin(time2)

	return math_abs(dayStartTime2 - dayStartTime1) / Const.SECONDS_ONE_DAY
end

function TimeUtils.getOpenServerDay()
	if not Time.ServerOpenTime then
		return 0
	end

	local Utils = require("Common.Utils.Utils")

	if pg and pg.component == "game" then
		local day = (Time.secondCache - TimeUtils.getServerDayBegin(Time.ServerOpenTime)) / Const.SECONDS_ONE_DAY

		return math.floor(day)
	else
		local startTs = Utils.getSecondsDayStart()
		local areaOffset = Const.TIME_AREA_OFFSET_UTCO[Utils.getServerArea()]
		local openTimeShifted = Time.ServerOpenTime + areaOffset
		local openDayBegin = openTimeShifted - startTs - (openTimeShifted - startTs) % Const.SECONDS_ONE_DAY + startTs - areaOffset
		local day = (Time.secondCache - openDayBegin) / Const.SECONDS_ONE_DAY

		return math.floor(day)
	end
end

function TimeUtils.getAreaOpenDayBegin(openDays)
	if not Time.ServerOpenTime then
		return 0
	end

	openDays = openDays or 1

	local Utils = require("Common.Utils.Utils")
	local startTs = Utils.getSecondsDayStart()

	if pg and pg.component == "game" then
		if not Utils.isOverseas() then
			local openDayBegin = TimeUtils.getDayBegin(Time.ServerOpenTime - startTs) + startTs

			return openDayBegin + (openDays - 1) * Const.SECONDS_ONE_DAY
		else
			local areaOffset = Const.TIME_AREA_OFFSET_UTCO[Utils.getServerArea()]
			local openDayBegin = TimeUtils.getDayBegin(Time.ServerOpenTime + areaOffset - startTs) + startTs - areaOffset

			return openDayBegin + (openDays - 1) * Const.SECONDS_ONE_DAY
		end
	else
		local areaOffset = Const.TIME_AREA_OFFSET_UTCO[Utils.getServerArea()]
		local openTimeShifted = Time.ServerOpenTime + areaOffset
		local openDayBegin = openTimeShifted - startTs - (openTimeShifted - startTs) % Const.SECONDS_ONE_DAY + startTs - areaOffset

		return openDayBegin + (openDays - 1) * Const.SECONDS_ONE_DAY
	end
end

function TimeUtils.getAreaOpenDayEnd(openDays)
	local endTime = TimeUtils.getAreaOpenDayBegin(openDays) + Const.SECONDS_ONE_DAY - 1

	return endTime
end

function TimeUtils.getServerDayBegin(now)
	now = now or Time.secondCache

	local Utils = require("Common.Utils.Utils")
	local startTs = Utils.getSecondsDayStart()

	if pg and pg.component == "game" then
		return TimeUtils.getDayBegin(now - startTs) + startTs
	end

	local areaOffset = Const.TIME_AREA_OFFSET_UTCO[Utils.getServerArea()]

	if areaOffset == nil then
		return 0
	end

	local shifted = now + areaOffset - startTs

	return shifted - shifted % Const.SECONDS_ONE_DAY + startTs - areaOffset
end

function TimeUtils.getHourBegin(now)
	if not now or now <= 0 then
		return 0
	end

	local t = os.date("*t", now)

	return os.time({
		min = 0,
		sec = 0,
		year = t.year,
		month = t.month,
		day = t.day,
		hour = t.hour
	})
end

function TimeUtils.getDayBegin(now)
	if not now or now <= 0 then
		return 0
	end

	local t = os.date("*t", now)

	return os.time({
		min = 0,
		sec = 0,
		hour = 0,
		year = t.year,
		month = t.month,
		day = t.day
	})
end

function TimeUtils.getAreaDayDiff(time1, time2)
	if not time1 or not time2 then
		return math.huge
	end

	local dayStartTime1 = TimeUtils.getAreaDayBegin(time1)
	local dayStartTime2 = TimeUtils.getAreaDayBegin(time2)

	return math_abs(dayStartTime2 - dayStartTime1) / Const.SECONDS_ONE_DAY
end

function TimeUtils.getAreaDayBegin(now)
	now = now or Time.secondCache

	local Utils = require("Common.Utils.Utils")

	if pg and pg.component == "game" then
		if not Utils.isOverseas() then
			return TimeUtils.getDayBegin(now)
		else
			local areaOffset = Const.TIME_AREA_OFFSET_UTCO[Utils.getServerArea()]

			return TimeUtils.getDayBegin(now + areaOffset) - areaOffset
		end
	else
		local areaOffset = Const.TIME_AREA_OFFSET_UTCO[Utils.getServerArea()]
		local shifted = now + areaOffset

		return shifted - shifted % Const.SECONDS_ONE_DAY - areaOffset
	end
end

function TimeUtils.getSecsFromDayBegOfLocalArea()
	local now = Time.secondCache

	if pg.component == "client" then
		return now - TimeUtils.getAreaDayBegin(now)
	end

	local offset = now - TimeUtils.getDayBegin(now)
	local Utils = require("Common.Utils.Utils")

	if Utils.isOverseas() then
		local areaNo = Utils.getServerArea()
		local fix = (offset + Const.TIME_AREA_OFFSET_UTCO[areaNo] + 86400) % 86400

		return fix
	end

	return offset
end

function TimeUtils.isInDailyOpenTime(openSec, closeSec)
	if not openSec or not closeSec then
		return true
	end

	local secOfDay = TimeUtils.getSecsFromDayBegOfLocalArea()

	if closeSec < openSec then
		return openSec <= secOfDay or secOfDay <= closeSec
	end

	return openSec <= secOfDay and secOfDay <= closeSec
end

function TimeUtils.getWeekDayOffArea(now)
	now = now or Time.secondCache

	local Utils = require("Common.Utils.Utils")

	if pg and pg.component == "game" then
		if not Utils.isOverseas() then
			return tonumber(os.date("%w", now))
		end

		local areaOffset = Const.TIME_AREA_OFFSET_UTCO[Utils.getServerArea()]

		return tonumber(os.date("%w", now + areaOffset))
	end

	local areaOffset = Const.TIME_AREA_OFFSET_UTCO[Utils.getServerArea()]

	return tonumber(os.date("!%w", now + areaOffset))
end

function TimeUtils.getWeekBegin(now)
	if not now or now <= 0 then
		return 0
	end

	local t = os.date("*t", now)
	local day_of_week = tonumber(os.date("%w", now))
	local days_to_monday = day_of_week == 0 and 6 or day_of_week - 1

	return os.time({
		min = 0,
		sec = 0,
		hour = 0,
		year = t.year,
		month = t.month,
		day = t.day - days_to_monday
	})
end

function TimeUtils.getAreaWeekBegin(now)
	now = now or Time.secondCache

	local Utils = require("Common.Utils.Utils")

	if pg and pg.component == "game" then
		if not Utils.isOverseas() then
			return TimeUtils.getWeekBegin(now)
		else
			local areaOffset = Const.TIME_AREA_OFFSET_UTCO[Utils.getServerArea()]

			return TimeUtils.getWeekBegin(now + areaOffset) - areaOffset
		end
	else
		local WEEK_ANCHOR_MONDAY = 4 * Const.SECONDS_ONE_DAY
		local areaOffset = Const.TIME_AREA_OFFSET_UTCO[Utils.getServerArea()]
		local shifted = now + areaOffset

		return shifted - WEEK_ANCHOR_MONDAY - (shifted - WEEK_ANCHOR_MONDAY) % Const.SECONDS_ONE_WEEK + WEEK_ANCHOR_MONDAY - areaOffset
	end
end

function TimeUtils.getMonthBegin(now)
	now = now or Time.secondCache

	local t = os.date("*t", now)

	return os.time({
		min = 0,
		day = 1,
		sec = 0,
		hour = 0,
		year = t.year,
		month = t.month
	})
end

function TimeUtils.getAreaMonthBegin(now)
	now = now or Time.secondCache

	local Utils = require("Common.Utils.Utils")

	if pg and pg.component == "game" then
		if not Utils.isOverseas() then
			return TimeUtils.getMonthBegin(now)
		else
			local areaOffset = Const.TIME_AREA_OFFSET_UTCO[Utils.getServerArea()]

			return TimeUtils.getMonthBegin(now + areaOffset) - areaOffset
		end
	end

	local areaOffset = Const.TIME_AREA_OFFSET_UTCO[Utils.getServerArea()]
	local shifted = now + areaOffset
	local t = os.date("!*t", shifted)
	local dayBegin = shifted - shifted % Const.SECONDS_ONE_DAY

	return dayBegin - (t.day - 1) * Const.SECONDS_ONE_DAY - areaOffset
end

function TimeUtils.getNextDayBegin(now)
	now = now or Time.secondCache

	local current_day_begin = TimeUtils.getDayBegin(now)

	return current_day_begin + 86400
end

function TimeUtils.getNextDayTimestamp(now, h, m, s)
	now = now or Time.secondCache

	local next_day_begin = TimeUtils.getNextDayBegin(now)
	local t = os.date("*t", next_day_begin)

	return os.time({
		year = t.year,
		month = t.month,
		day = t.day,
		hour = h,
		min = m,
		sec = s
	})
end

function TimeUtils.getAreaNextDayBegin(now)
	now = now or Time.secondCache

	local current_day_begin = TimeUtils.getAreaDayBegin(now)

	return current_day_begin + 86400
end

function TimeUtils.getAreaNextDayTimestamp(now, h, m, s)
	now = now or Time.secondCache

	local next_day_begin = TimeUtils.getAreaNextDayBegin(now)

	return next_day_begin + h * 3600 + m * 60 + s
end

function TimeUtils.getNextWeekBegin(now)
	now = now or Time.secondCache

	local current_week_begin = TimeUtils.getWeekBegin(now)

	return current_week_begin + 604800
end

function TimeUtils.getAreaNextWeekBegin(now)
	now = now or Time.secondCache

	local current_week_begin = TimeUtils.getAreaWeekBegin(now)

	return current_week_begin + 604800
end

function TimeUtils.getNextWeekTimestamp(now, d, h, m, s)
	local next_week_begin = TimeUtils.getNextWeekBegin(now)
	local t = os.date("*t", next_week_begin)

	return os.time({
		year = t.year,
		month = t.month,
		day = t.day + d - 1,
		hour = h,
		min = m,
		sec = s
	})
end

function TimeUtils.getAreaNextWeekTimestamp(now, d, h, m, s)
	now = now or Time.secondCache

	local next_week_begin = TimeUtils.getAreaNextWeekBegin(now)
	local tm = next_week_begin + (d - 1) * 86400 + h * 3600 + m * 60 + s

	return tm
end

function TimeUtils.getNextMonthBegin(now)
	local t = os.date("*t", now)
	local year, month = t.year, t.month

	if month == 12 then
		year = year + 1
		month = 1
	else
		month = month + 1
	end

	return os.time({
		min = 0,
		day = 1,
		sec = 0,
		hour = 0,
		year = year,
		month = month
	})
end

function TimeUtils.getAreaNextMonthTimestamp(now, day, h, m, s)
	local next_month_begin = TimeUtils.getAreaNextMonthBegin(now)

	return next_month_begin + (day - 1) * 86400 + h * 3600 + m * 60 + s
end

function TimeUtils.getAreaNextMonthBegin(now)
	now = now or Time.secondCache

	local Utils = require("Common.Utils.Utils")

	if pg and pg.component == "game" then
		if not Utils.isOverseas() then
			return TimeUtils.getNextMonthBegin(now)
		else
			local areaOffset = Const.TIME_AREA_OFFSET_UTCO[Utils.getServerArea()]

			return TimeUtils.getNextMonthBegin(now + areaOffset) - areaOffset
		end
	end

	local monthBegin = TimeUtils.getAreaMonthBegin(now)

	return TimeUtils.getAreaMonthBegin(monthBegin + 32 * Const.SECONDS_ONE_DAY)
end

function TimeUtils.getAreaCurOrNextDayResetTime(ref, h, m, s)
	ref = ref or Time.secondCache

	local candidate = TimeUtils.getAreaDayBegin(ref) + h * 3600 + m * 60 + s

	if candidate <= ref then
		candidate = TimeUtils.getAreaNextDayTimestamp(ref, h, m, s)
	end

	return candidate
end

function TimeUtils.getAreaCurOrNextWeekResetTime(ref, d, h, m, s)
	ref = ref or Time.secondCache

	local candidate = TimeUtils.getAreaWeekBegin(ref) + (d - 1) * 86400 + h * 3600 + m * 60 + s

	if candidate <= ref then
		candidate = TimeUtils.getAreaNextWeekTimestamp(ref, d, h, m, s)
	end

	return candidate
end

function TimeUtils.getAreaCurOrNextMonthResetTime(ref, day, h, m, s)
	ref = ref or Time.secondCache

	local candidate = TimeUtils.getAreaMonthBegin(ref) + (day - 1) * 86400 + h * 3600 + m * 60 + s

	if candidate <= ref then
		candidate = TimeUtils.getAreaNextMonthTimestamp(ref, day, h, m, s)
	end

	return candidate
end

function TimeUtils.stringToTimestamp(timeString)
	if not timeString or timeString == "" then
		return 0
	end

	local pattern = "(%d+):(%d+):(%d+)"
	local hour, min, sec = timeString:match(pattern)

	if not hour or not min or not sec then
		return nil, "Invalid time format"
	end

	local now = Time.secondCache
	local t = os.date("*t", now)
	local timeStamp = os.time({
		year = t.year,
		month = t.month,
		day = t.day,
		hour = tonumber(hour),
		min = tonumber(min),
		sec = tonumber(sec)
	})

	if pg and pg.component == "game" then
		return timeStamp
	else
		local GlobalData = require("Core.Client.GlobalData")
		local zoneTime = os.difftime(os.time(), os.time(os.date("!*t", os.time())))

		return timeStamp - (GlobalData.ZoneTime - zoneTime)
	end
end

function TimeUtils.stringToAreaTimestamp(timeString)
	local Utils = require("Common.Utils.Utils")
	local isServer = pg and pg.component == "game"

	if isServer and not Utils.isOverseas() then
		return TimeUtils.stringToTimestamp(timeString)
	end

	if not timeString or timeString == "" then
		return 0
	end

	local pattern = "(%d+):(%d+):(%d+)"
	local hour, min, sec = timeString:match(pattern)

	if not hour or not min or not sec then
		return nil, "Invalid time format"
	end

	local now = Time.secondCache

	hour, min, sec = tonumber(hour), tonumber(min), tonumber(sec)

	if not isServer then
		return TimeUtils.getAreaDayBegin(now) + hour * 3600 + min * 60 + sec
	end

	local areaOffset = Const.TIME_AREA_OFFSET_UTCO[Utils.getServerArea()]
	local t = os.date("*t", now + areaOffset)
	local timeStamp = os.time({
		year = t.year,
		month = t.month,
		day = t.day,
		hour = hour,
		min = min,
		sec = sec
	})

	return timeStamp - areaOffset
end

function TimeUtils.utcStringToTimestamp(timeString, pattern)
	if not timeString or timeString == "" then
		return 0
	end

	pattern = pattern or "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)"

	local year, month, day, hour, min, sec = timeString:match(pattern)

	if not year or not month or not day or not hour or not min or not sec then
		return nil, "Invalid time format"
	end

	local timeStamp = os.time({
		year = tonumber(year),
		month = tonumber(month),
		day = tonumber(day),
		hour = tonumber(hour),
		min = tonumber(min),
		sec = tonumber(sec)
	})

	if pg and pg.component == "game" then
		return timeStamp
	else
		local GlobalData = require("Core.Client.GlobalData")
		local zoneTime = os.difftime(os.time(), os.time(os.date("!*t", os.time())))

		return timeStamp - (GlobalData.ZoneTime - zoneTime)
	end
end

function TimeUtils.timeStampToUtcString(timeStamp)
	if pg and pg.component == "game" then
		return os.date("%Y-%m-%d %H:%M:%S", timeStamp)
	end

	local str = os.date("%Y-%m-%d %H:%M:%S", timeStamp)

	return str
end

local function _parseDateTime(timeString, pattern)
	pattern = pattern or "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)"

	local y, mo, d, h, mi, s = timeString:match(pattern)

	if not y or not mo or not d or not h or not mi or not s then
		return nil, "Invalid time format"
	end

	return tonumber(y), tonumber(mo), tonumber(d), tonumber(h), tonumber(mi), tonumber(s)
end

function TimeUtils.stringToTimestampByUtcOffset(timeString, utcOffsetSeconds, pattern)
	if not timeString or timeString == "" then
		return 0
	end

	local y, mo, d, h, mi, s = _parseDateTime(timeString, pattern)

	if not y then
		return nil, "Invalid time format"
	end

	local timeTable = {
		year = y,
		month = mo,
		day = d,
		hour = h,
		min = mi,
		sec = s
	}
	local localTs = os.time(timeTable)
	local localOffset = os.difftime(os.time(), os.time(os.date("!*t", os.time())))

	return localTs - (utcOffsetSeconds - localOffset)
end

function TimeUtils.configStringToTimestampByType(timeType, timeString, pattern)
	local Utils = require("Common.Utils.Utils")

	if timeType == 1 then
		local areaOffset = Const.TIME_AREA_OFFSET_UTCO[Utils.getServerArea()] or 0

		return TimeUtils.stringToTimestampByUtcOffset(timeString, areaOffset, pattern)
	elseif timeType == 2 then
		return TimeUtils.stringToTimestampByUtcOffset(timeString, 28800, pattern)
	else
		return nil, "Invalid timeType"
	end
end

function TimeUtils.isTimeInRange(startTimeString, endTimeString)
	local curTime = Time.secondCache

	if not string.isNilOrEmpty(startTimeString) and curTime < TimeUtils.utcStringToTimestamp(startTimeString) then
		return false
	end

	if not string.isNilOrEmpty(endTimeString) and curTime > TimeUtils.utcStringToTimestamp(endTimeString) then
		return false
	end

	return true
end

function TimeUtils.isInRangeTimestamp(startTime, endTime)
	local curTime = Time.secondCache

	if startTime ~= nil and curTime < startTime then
		return false
	end

	if endTime ~= nil and endTime < curTime then
		return false
	end

	return true
end

function TimeUtils.timeToFormatString(seconds)
	if seconds < 0 then
		seconds = 0
	end

	return os.date("%M:%S", seconds)
end

function TimeUtils.timeToFormatString2(seconds)
	if seconds < 0 then
		seconds = 0
	end

	return os.date("%H:%M:%S", seconds)
end

function TimeUtils.timeToFormatString3(seconds)
	if seconds < 0 then
		seconds = 0
	end

	return os.date("%H:%M", seconds)
end

function TimeUtils.timeStringToHM(timeString)
	if not timeString or timeString == "" then
		return ""
	end

	local h, m = timeString:match("(%d+):(%d+)")

	if h and m then
		return string.format("%02d:%02d", tonumber(h), tonumber(m))
	end

	return timeString
end

function TimeUtils.timeToFormatString4(seconds)
	if seconds < 0 then
		seconds = 0
	end

	return os.date("%Y-%m-%d %H:%M", seconds)
end

function TimeUtils.timeToFormatStringSpecial(seconds)
	if seconds < 0 then
		seconds = 0
	end

	return os.date("%Y-%m-%d", seconds)
end

function TimeUtils.timeToFormatStringSpecial2(seconds)
	if seconds < 0 then
		seconds = 0
	end

	return os.date("%Y-%m-%d %H:%M:%S", seconds)
end

function TimeUtils.timeToFormatString3IgnoreTimeZone(seconds)
	if seconds < 0 then
		seconds = 0
	end

	return os.date("!%H:%M", seconds)
end

function TimeUtils.timeToFormatStringHHMMSS(seconds)
	if seconds < 0 then
		seconds = 0
	end

	local hours = math.floor(seconds / 3600)
	local minutes = math.floor(seconds % 3600 / 60)

	seconds = seconds % 60

	return string.format("%02d:%02d:%02d", hours, minutes, seconds)
end

function TimeUtils.timeToFormatStringHHMM(seconds)
	if seconds < 0 then
		seconds = 0
	end

	local hours = math.floor(seconds / 3600)
	local minutes = math.floor(seconds % 3600 / 60)

	return string.format("%02d:%02d", hours, minutes)
end

function TimeUtils.getServerNextDayBegin(now)
	return TimeUtils.getServerDayBegin(now) + 86400
end

function TimeUtils.getFormatStringDay(seconds)
	local dayL10nTxt = pg.getGameString("DAY") or "DAY"

	return string.format("%s%s", math.round(math.max(0, seconds or 0) / 86400), dayL10nTxt)
end

function TimeUtils.getRemainTimeShort(remainTime)
	remainTime = math.max(remainTime or 0, 0)

	local d = pg.getGameString("DAY")
	local h = pg.getGameString("HOUR")
	local m = pg.getGameString("MINUTE")
	local days = math.floor(remainTime / Const.SECONDS_ONE_DAY)
	local hours = math.floor(remainTime / Const.SECONDS_ONE_HOUR)
	local minutes = math.floor(remainTime % Const.SECONDS_ONE_HOUR / Const.SECONDS_ONE_MINUTE)

	if remainTime > Const.SECONDS_ONE_DAY then
		local formatText = string.format("{0}%s{1}%s", d, h)

		return pg.getFormatText(formatText, days, hours % 24)
	else
		local formatText = string.format("{0}%s{1}%s", h, m)

		return pg.getFormatText(formatText, hours, minutes)
	end
end

return TimeUtils
