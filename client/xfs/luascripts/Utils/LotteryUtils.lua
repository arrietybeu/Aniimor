-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\LotteryUtils.lua

local CommonSwitch = require("Common.CommonSwitch")
local Utils = require("Common.Utils.Utils")
local TimeUtils = require("Common.Utils.TimeUtils")
local GachaEntryData = require("Data.gacha_entry_data")
local LotteryUtils = {}

function LotteryUtils.isEnabled()
	return CommonSwitch.EnableGacha == true
end

function LotteryUtils.isOpen(drawId)
	if not LotteryUtils.isEnabled() then
		return false
	end

	drawId = tonumber(drawId)

	if not drawId or drawId <= 0 then
		return false
	end

	local entryConfig = GachaEntryData[drawId]

	if not Utils.isTable(entryConfig) then
		return false
	end

	local openTime = Utils.getConfigTimeOfArea(entryConfig, "openTime")
	local closeTime = Utils.getConfigTimeOfArea(entryConfig, "closeTime")

	if type(openTime) ~= "number" or type(closeTime) ~= "number" or closeTime < openTime then
		return false
	end

	return TimeUtils.isInRangeTimestamp(openTime, closeTime)
end

function LotteryUtils.getCurCanShareCount(drawId)
	drawId = tonumber(drawId)

	local gachaMap = pg.me and pg.me.gachaMap or nil
	local gachaBase = drawId and Utils.isTable(gachaMap) and gachaMap[drawId] or nil

	if not Utils.isTable(gachaBase) or type(gachaBase.getCurCanShareCount) ~= "function" then
		return 0
	end

	local count = tonumber(gachaBase:getCurCanShareCount()) or 0

	return math.max(math.floor(count), 0)
end

return LotteryUtils
