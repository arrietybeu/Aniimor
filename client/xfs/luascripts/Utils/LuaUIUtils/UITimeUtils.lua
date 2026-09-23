-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\LuaUIUtils\\UITimeUtils.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local ClientConst = require("Const.ClientConst")
local logger = LoggerManager.getLogger("LuaUIUtils")
local Time = require("Core.Common.Time")
local ClientTextUtils = require("Utils.ClientTextUtils")
local UIConst = require("Const.UIConst")
local Utils = require("Common.Utils.Utils")
local TimeUtils = require("Common.Utils.TimeUtils")
local Const = require("Common.Const.Const")
local PlayerForbidConst = require("Common.Const.PlayerForbidConst")
local concatCountDownUnitsByLanguage = ClientTextUtils.concatCountDownUnitsByLanguage
local AREA_DATE_TIME_PATTERN = "(%d+)/(%d+)/(%d+)/(%d+):(%d+):(%d+)"

return function(LuaUIUtils)
	function LuaUIUtils.getAreaTimeConfigTimestamp(areaTimeList)
		local areaTimeConfig = areaTimeList and areaTimeList[1]

		if type(areaTimeConfig) ~= "table" then
			return 0
		end

		local areaNo = Utils.getServerArea()
		local generatedTimestamp = tonumber(areaTimeConfig[tostring(areaNo)])

		if generatedTimestamp then
			return generatedTimestamp
		end

		local timeType = tonumber(areaTimeConfig[1])
		local timeString = areaTimeConfig[2]

		if not timeType or type(timeString) ~= "string" or timeString == "" then
			return 0
		end

		local timestamp = TimeUtils.configStringToTimestampByType(timeType, timeString, AREA_DATE_TIME_PATTERN)

		return tonumber(timestamp) or 0
	end

	function LuaUIUtils.checkFeatureForbid(forbidType)
		local forbidEndTs = pg.me.featureForbidEndTsMap[forbidType]

		if forbidEndTs == PlayerForbidConst.FORBID_END_TS.PERMANENT then
			pg.global.showBubbleMessageRaw(pg.getGameString("PLAYER_PERMISSION_LIMITED"))

			return true
		end

		if forbidEndTs and forbidEndTs > Time.getSecond() then
			local timeText = LuaUIUtils.timeStampToUtcString(forbidEndTs, UIConst.TargetTimeType.Long)

			pg.global.showBubbleMessageRaw(pg.getFormatText(pg.getGameString("PLAYER_PERMISSION_LIMITED_UNTIL"), timeText))

			return true
		end

		return false
	end

	function LuaUIUtils.getCountDownFormateTextEx(seconds)
		local hour = math.floor(seconds / 3600)
		local t = seconds % 3600
		local minutes = math.floor(t / 60)
		local remainingSeconds = t % 60

		if hour > 0 then
			return string.format("%d:%02d:%02d", hour, minutes, remainingSeconds)
		end

		if minutes > 0 then
			return string.format("%d:%02d", minutes, remainingSeconds)
		end

		return string.format("%d", remainingSeconds)
	end

	function LuaUIUtils.getLoginWaitingCountDownFormateText(seconds)
		local hour = math.floor(seconds / 3600)
		local minute = math.floor(seconds / 60)
		local timeText = ""

		if hour >= 24 then
			timeText = pg.getGameString("OVER_TWENTY_FOUR_HOUR")
		elseif minute < 1 then
			timeText = pg.getGameString("LESS_THAN_ONE_MINUTE")
		else
			local remainMinute = minute - hour * 60

			if hour > 0 then
				timeText = concatCountDownUnitsByLanguage(hour, pg.getGameString("HOUR_HOME"), remainMinute, pg.getGameString("MINUTE_HOME"))
			else
				timeText = concatCountDownUnitsByLanguage(remainMinute, pg.getGameString("MINUTE_HOME"))
			end
		end

		return timeText
	end

	function LuaUIUtils.getCountDownFormateText(seconds, includeHour)
		if not includeHour then
			local minutes = math.floor(seconds / 60)
			local remainingSeconds = seconds % 60

			return string.format("%02d:%02d", minutes, remainingSeconds)
		else
			local hour = math.floor(seconds / 3600)
			local t = seconds % 3600
			local minutes = math.floor(t / 60)
			local remainingSeconds = t % 60

			return string.format("%02d:%02d:%02d", hour, minutes, remainingSeconds)
		end
	end

	function LuaUIUtils.formatDuration(seconds)
		local hours = math.floor(seconds / 3600)
		local minutes = math.floor(seconds % 3600 / 60)
		local secs = seconds % 60

		return string.format("%02d:%02d:%02d", hours, minutes, secs)
	end

	function LuaUIUtils.commonShowCountDown(id, time, title, cb)
		pg.global.ui.tips:showCountDown(time, id, {
			infoText = pg.getLocalizationText(title),
			finishCb = cb
		})
	end

	function LuaUIUtils.commonHideCountDown(id)
		pg.global.ui.tips:hideCountDown(id)
	end

	function LuaUIUtils.isUseHour24()
		local curLanguage = pg.languageType or 0

		return curLanguage == ClientConst.LANGUAGE_TYPE_MAP.zh_CN or curLanguage == ClientConst.LANGUAGE_TYPE_MAP.ko_KR or curLanguage == ClientConst.LANGUAGE_TYPE_MAP.ja_JP
	end

	function LuaUIUtils.addTimeZoneString(timeStr)
		local timeZoneText = Const.SERVER_TIME_ZONE_TEXT[Utils.getServerArea()]

		if not timeZoneText or timeZoneText == "" then
			return timeStr
		end

		return timeStr .. timeZoneText
	end

	function LuaUIUtils.timeStampToUtcString(timestamp, timeType, addTimeZone, timeTableOverride)
		if timestamp <= 0 then
			return ""
		end

		if timeType == nil then
			timeType = UIConst.TargetTimeType.Long
		end

		if addTimeZone == nil then
			addTimeZone = true
		end

		local timeString
		local timeTable = timeTableOverride or os.date("*t", timestamp)

		if LuaUIUtils.isUseHour24() then
			if timeTable.sec == 0 then
				timeString = string.format("%02d:%02d", timeTable.hour, timeTable.min)
			else
				timeString = string.format("%02d:%02d:%02d", timeTable.hour, timeTable.min, timeTable.sec)
			end

			if timeType == UIConst.TargetTimeType.Long then
				local dateStr = string.format("%04d/%02d/%02d", timeTable.year, timeTable.month, timeTable.day)

				timeString = string.format("%s %s", dateStr, timeString)
			elseif timeType == UIConst.TargetTimeType.MonthDay then
				local dateStr = string.format("%02d/%02d", timeTable.month, timeTable.day)

				timeString = string.format("%s %s", dateStr, timeString)
			end
		else
			local hour12 = timeTable.hour % 12

			if hour12 == 0 then
				hour12 = 12
			end

			local ampm = timeTable.hour < 12 and "AM" or "PM"

			if timeTable.sec == 0 then
				timeString = string.format("%02d:%02d %s", hour12, timeTable.min, ampm)
			else
				timeString = string.format("%02d:%02d:%02d %s", hour12, timeTable.min, timeTable.sec, ampm)
			end

			if timeType == UIConst.TargetTimeType.Long then
				local dateStr = string.format("%02d/%02d/%04d", timeTable.month, timeTable.day, timeTable.year)

				timeString = string.format("%s %s", dateStr, timeString)
			elseif timeType == UIConst.TargetTimeType.MonthDay then
				local dateStr = string.format("%02d/%02d", timeTable.month, timeTable.day)

				timeString = string.format("%s %s", dateStr, timeString)
			end
		end

		if addTimeZone then
			return LuaUIUtils.addTimeZoneString(timeString)
		else
			return timeString or ""
		end
	end

	local function getSystemLocalUtcOffsetSeconds(timestamp)
		if pgUtils and pgUtils.GetLocalUtcOffsetSeconds then
			local success, utcOffsetSeconds = pcall(pgUtils.GetLocalUtcOffsetSeconds, timestamp)

			if success and tonumber(utcOffsetSeconds) then
				return tonumber(utcOffsetSeconds)
			end
		end

		local success, utcOffsetSeconds = pcall(function()
			local system = CS and CS.System
			local timeZoneInfo = system and system.TimeZoneInfo
			local dateTimeOffset = system and system.DateTimeOffset

			if not timeZoneInfo or not dateTimeOffset then
				return nil
			end

			timeZoneInfo.ClearCachedData()

			local utcInstant = CS.System.DateTimeOffset.FromUnixTimeSeconds(timestamp)

			return timeZoneInfo.Local:GetUtcOffset(utcInstant).TotalSeconds
		end)

		if success and tonumber(utcOffsetSeconds) then
			return tonumber(utcOffsetSeconds)
		end

		if LoggerManager.checkLogger and LoggerManager.checkLogger(LoggerConst.ERROR) and logger.error then
			logger:error("failed to read current system timezone; falling back to cached local timezone")
		end

		return nil
	end

	local function addSystemTimeZoneString(timeString, utcOffsetSeconds)
		local absoluteMinutes = math.floor(math.abs(utcOffsetSeconds) / 60)
		local offsetHours = math.floor(absoluteMinutes / 60)
		local offsetMinutes = absoluteMinutes % 60
		local sign = utcOffsetSeconds < 0 and "-" or "+"
		local timeZoneText = string.format(" UTC%s%d", sign, offsetHours)

		if offsetMinutes > 0 then
			timeZoneText = string.format("%s:%02d", timeZoneText, offsetMinutes)
		end

		return timeString .. timeZoneText
	end

	function LuaUIUtils.timeStampToSystemLocalString(timestamp, timeType, addTimeZone)
		if timestamp <= 0 then
			return ""
		end

		local utcOffsetSeconds = getSystemLocalUtcOffsetSeconds(timestamp)

		if not utcOffsetSeconds then
			return LuaUIUtils.timeStampToUtcString(timestamp, timeType, false)
		end

		if addTimeZone == nil then
			addTimeZone = true
		end

		local localTimeTable = os.date("!*t", timestamp + utcOffsetSeconds)
		local timeString = LuaUIUtils.timeStampToUtcString(timestamp, timeType, false, localTimeTable)

		if addTimeZone then
			return addSystemTimeZoneString(timeString, utcOffsetSeconds)
		end

		return timeString
	end

	function LuaUIUtils.timeStrToUtcString(timeStr, timeType, addTimeZone)
		if type(timeStr) ~= "string" or timeStr == "" then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("timeStrError")
			end

			return ""
		end

		local hour, minute = string.match(timeStr, "^(%d%d?):(%d%d?)$")

		if not hour or not minute then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("timeStrError")
			end

			return ""
		end

		if addTimeZone == nil then
			addTimeZone = true
		end

		hour = tonumber(hour)
		minute = tonumber(minute)

		if hour < 0 or hour > 23 or minute < 0 or minute > 59 then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("timeStrError")
			end

			return ""
		end

		local timeString

		if LuaUIUtils.isUseHour24() then
			timeString = string.format("%02d:%02d", hour, minute)
		else
			local hour12 = hour % 12

			if hour12 == 0 then
				hour12 = 12
			end

			local ampm = hour < 12 and "AM" or "PM"

			timeString = string.format("%02d:%02d %s", hour12, minute, ampm)
		end

		if addTimeZone then
			return LuaUIUtils.addTimeZoneString(timeString)
		else
			return timeString or ""
		end
	end

	function LuaUIUtils.getCountDownString(seconds, timeType, addTime, dontShowTimeStr)
		seconds = math.max(0, seconds)

		local days = math.floor(seconds / 86400)

		seconds = seconds % 86400

		local hours = math.floor(seconds / 3600)

		seconds = seconds % 3600

		local minutes = math.floor(seconds / 60)

		seconds = seconds % 60
		seconds = math.floor(seconds)

		local dayL10n = pg.getGameString("DAY")
		local hourL10n = pg.getGameString("HOUR")
		local minuteL10n = pg.getGameString("MINUTE")
		local secondL10n = pg.getGameString("SECOND")

		if timeType == UIConst.TimeType.Full then
			return concatCountDownUnitsByLanguage(days, dayL10n, hours, hourL10n, minutes, minuteL10n, seconds, secondL10n)
		end

		if timeType == UIConst.TimeType.OneTime then
			if days >= 1 then
				if addTime then
					return concatCountDownUnitsByLanguage(days, dayL10n)
				else
					return concatCountDownUnitsByLanguage("{0}", dayL10n)
				end
			elseif hours >= 1 then
				if addTime then
					return concatCountDownUnitsByLanguage(hours, hourL10n)
				else
					return concatCountDownUnitsByLanguage("{1}", hourL10n)
				end
			elseif minutes >= 1 then
				if addTime then
					return concatCountDownUnitsByLanguage(minutes, minuteL10n)
				else
					return concatCountDownUnitsByLanguage("{2}", minuteL10n)
				end
			elseif addTime then
				return concatCountDownUnitsByLanguage(seconds, secondL10n)
			else
				return concatCountDownUnitsByLanguage("{3}", secondL10n)
			end
		end

		if days > 0 then
			if addTime then
				return concatCountDownUnitsByLanguage(days, dayL10n, hours, hourL10n)
			else
				return concatCountDownUnitsByLanguage("{0}", dayL10n, "{1}", hourL10n)
			end
		elseif hours > 0 then
			if addTime then
				return concatCountDownUnitsByLanguage(hours, hourL10n, minutes, minuteL10n)
			else
				return concatCountDownUnitsByLanguage("{1}", hourL10n, "{2}", minuteL10n)
			end
		elseif minutes > 0 then
			if dontShowTimeStr then
				return addTime and string.format("%d:%02d", minutes, seconds) or "{2}:{3}"
			elseif addTime then
				return concatCountDownUnitsByLanguage(minutes, minuteL10n, seconds, secondL10n)
			else
				return concatCountDownUnitsByLanguage("{2}", minuteL10n, "{3}", secondL10n)
			end
		elseif dontShowTimeStr then
			return addTime and tostring(seconds) or "{3}"
		elseif addTime then
			return concatCountDownUnitsByLanguage(seconds, secondL10n)
		else
			return concatCountDownUnitsByLanguage("{3}", secondL10n)
		end
	end

	function LuaUIUtils.getLastTimeStr(time)
		if time == nil then
			return ""
		end

		local interval = math.max(0, Time.secondCache - time)
		local baseText0 = pg.getGameString("CHAT_OFFLINE_TIME_0")
		local baseText1 = pg.getGameString("CHAT_OFFLINE_TIME_1")
		local baseText2 = pg.getGameString("CHAT_OFFLINE_TIME_2")
		local baseText3 = pg.getGameString("CHAT_OFFLINE_TIME_3")

		if interval < 60 then
			return string.gsub(baseText0, "{0}", 1)
		elseif interval < 3600 then
			local lastTime = math.floor(interval / 60)

			return string.gsub(baseText1, "{0}", lastTime)
		elseif interval < 86400 then
			local lastTime = math.floor(interval / 60 / 60)

			return string.gsub(baseText2, "{0}", lastTime)
		elseif interval < 604800 then
			local lastTime = math.floor(interval / 60 / 60 / 24)

			return string.gsub(baseText3, "{0}", lastTime)
		else
			return string.gsub(baseText3, "{0}", 7)
		end
	end

	function LuaUIUtils.setCountDownTime(uCountDown, countDownTime, showType, totalTime, dontShowTimeStr, directTime, concatTextKey)
		local remainTime = countDownTime

		if not directTime then
			remainTime = countDownTime - Time.getSecond()
		end

		if remainTime > 0 then
			local timeStr = LuaUIUtils.getCountDownString(remainTime, showType, false, dontShowTimeStr)

			if concatTextKey then
				local concatText = pg.getGameString(concatTextKey)

				if string.find(concatText, "{0}", 1, true) then
					timeStr = pg.getFormatText(concatText, timeStr)
				else
					timeStr = concatText .. timeStr
				end
			end

			uCountDown.formatText = timeStr

			if totalTime then
				uCountDown:Play(remainTime, totalTime)
			else
				uCountDown:Play(remainTime)
			end
		end
	end

	function LuaUIUtils.timePeriodToUtcString(timePeriodTex, timeType)
		if not timePeriodTex or timePeriodTex == "" then
			return ""
		end

		local startTime, endTime = string.match(timePeriodTex, "([%d:]+)%s*%-%s*([%d:]+)")

		if not startTime or not endTime then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("timeStr Error")
			end

			return timePeriodTex
		end

		local processedStart = LuaUIUtils.timeStrToUtcString(startTime, timeType, false)
		local processedEnd = LuaUIUtils.timeStrToUtcString(endTime, timeType, false)

		return processedStart .. " - " .. processedEnd
	end

	function LuaUIUtils.formatTimeRange(startTs, endTs)
		if not startTs or startTs <= 0 then
			return ""
		end

		if not endTs or endTs <= 0 then
			return ""
		end

		local st = os.date("*t", startTs)
		local et = os.date("*t", endTs)
		local startDate = string.format("%04d-%02d-%02d", st.year, st.month, st.day)
		local startTime = string.format("%02d:%02d", st.hour, st.min)
		local endDate = string.format("%04d-%02d-%02d", et.year, et.month, et.day)
		local endTime = string.format("%02d:%02d", et.hour, et.min)

		if startDate == endDate then
			return string.format("%s %s ~ %s", startDate, startTime, endTime)
		else
			return string.format("%s %s ~ %s %s", startDate, startTime, endDate, endTime)
		end
	end
end
