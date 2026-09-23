-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\ActivityPopUtils.lua

local ActivityPopConst = require("Const.ActivityPopConst")
local ClientActivityUtils = require("Utils.ClientActivityUtils")
local Time = require("Core.Common.Time")
local TimeUtils = require("Common.Utils.TimeUtils")
local Utils = require("Common.Utils.Utils")
local FunctionEnum = require("Data.function_unlock_enum")
local GameEventData = require("Data.game_event_data")
local ClientConst = require("Const.ClientConst")
local Const = require("Common.Const.Const")
local LoggerManager = require("Core.Log.LoggerManager")
local logger = LoggerManager.getLogger("ActivityPopUtils")
local ActivityPopUtils = {}

function ActivityPopUtils._makePrefsKey(eventId, cooldownType, eventData)
	if cooldownType == ActivityPopConst.CooldownType.Once then
		return string.format(ClientConst.PrefKey.EventPopCooldownTypeOnce, eventId)
	elseif cooldownType == ActivityPopConst.CooldownType.Daily then
		return string.format(ClientConst.PrefKey.EventPopCooldownTypeDaily, eventId)
	elseif cooldownType == ActivityPopConst.CooldownType.Phase then
		return string.format(ClientConst.PrefKey.EventPopCooldownTypePhase, eventId, eventData.phase or 0)
	end

	return nil
end

function ActivityPopUtils.isInCooldown(eventId, cooldownType)
	cooldownType = cooldownType or ActivityPopConst.CooldownType.None

	if cooldownType == ActivityPopConst.CooldownType.None then
		return false
	end

	local eventData = GameEventData[eventId]

	if not eventData then
		return false
	end

	local key = ActivityPopUtils._makePrefsKey(eventId, cooldownType, eventData)

	if not key then
		logger:error("@ActivityPop activity popup cooldown type invalid eventId=%s type=%s", tostring(eventId), tostring(cooldownType))

		return false
	end

	local prefs = pg.global.prefsCacheUtils

	if cooldownType == ActivityPopConst.CooldownType.Daily then
		local currentDay = math.floor(TimeUtils.getAreaDayBegin(Time.secondCache) / Const.SECONDS_ONE_DAY)

		return prefs:getInt(key, -1) == currentDay
	end

	return prefs:getInt(key, 0) == 1
end

function ActivityPopUtils.markPopped(eventId, cooldownType)
	cooldownType = cooldownType or ActivityPopConst.CooldownType.None

	if cooldownType == ActivityPopConst.CooldownType.None then
		return
	end

	local eventData = GameEventData[eventId]

	if not eventData then
		return
	end

	local key = ActivityPopUtils._makePrefsKey(eventId, cooldownType, eventData)

	if not key then
		logger:error("@ActivityPop activity popup cooldown type invalid eventId=%s type=%s", tostring(eventId), tostring(cooldownType))

		return
	end

	local prefs = pg.global.prefsCacheUtils

	if cooldownType == ActivityPopConst.CooldownType.Daily then
		local currentDay = math.floor(TimeUtils.getAreaDayBegin(Time.secondCache) / Const.SECONDS_ONE_DAY)

		prefs:setInt(key, currentDay)
	else
		prefs:setInt(key, 1)
	end
end

function ActivityPopUtils._isInPopTime(eventData)
	local startTime = Utils.getConfigTimeOfArea(eventData, "PopStartDayTime")
	local endTime = Utils.getConfigTimeOfArea(eventData, "PopEndDayTime")
	local now = Time.secondCache

	return (not startTime or startTime <= now) and (not endTime or now < endTime)
end

function ActivityPopUtils._isActivityCenterUnlocked()
	if pg.me == nil then
		return false
	end

	if pg.me:checkFunctionShielded(FunctionEnum.ACTIVITYCENTER) then
		return false
	end

	return pg.me:checkFunctionUnlock(FunctionEnum.ACTIVITYCENTER)
end

function ActivityPopUtils._checkBusinessCondition(eventId, eventData)
	local target = ActivityPopConst.PopTarget[eventData.eventType]

	if not target or string.isNilOrEmpty(target.checker) then
		return true
	end

	local checker = ClientActivityUtils[target.checker]

	if type(checker) ~= "function" then
		logger:error("@ActivityPop activity popup checker missing eventId=%s checker=%s", tostring(eventId), tostring(target.checker))

		return false
	end

	return checker(eventId) == true
end

function ActivityPopUtils.collectPops()
	local result = {}

	if not ActivityPopUtils._isActivityCenterUnlocked() then
		return result
	end

	for eventId, eventData in pairs(GameEventData) do
		if eventData.needPop == 1 then
			local target = ActivityPopConst.PopTarget[eventData.eventType]

			if target == nil then
				logger:error("@ActivityPop activity popup target not registered eventId=%s eventType=%s", tostring(eventId), tostring(eventData.eventType))
			else
				local cooldown = target.cooldown or ActivityPopConst.CooldownType.None

				if ActivityPopUtils._isInPopTime(eventData) and ClientActivityUtils.isEventOpen(eventId) and ActivityPopUtils._checkBusinessCondition(eventId, eventData) and not ActivityPopUtils.isInCooldown(eventId, cooldown) and ActivityPopUtils:isPopSpaceScene() then
					result[#result + 1] = eventId
				end
			end
		end
	end

	table.sort(result, function(leftId, rightId)
		local leftRank = GameEventData[leftId].rank or math.huge
		local rightRank = GameEventData[rightId].rank or math.huge

		if leftRank == rightRank then
			return leftId < rightId
		end

		return leftRank < rightRank
	end)

	return result
end

function ActivityPopUtils:isPopSpaceScene()
	if not pg or not pg.me or not pg.me.space or not pg.me.space.sceneId then
		return false
	end

	local spaceType = Utils.getSpaceType(pg.me.space.sceneId)

	return spaceType == Const.SPACE_TYPE_TOWN or spaceType == Const.SPACE_TYPE_SINGLEWORLD
end

function ActivityPopUtils.hasPopByEventType(eventType, popQueue)
	popQueue = popQueue or ActivityPopUtils.collectPops()

	for _, eventId in ipairs(popQueue) do
		local eventData = GameEventData[eventId]

		if eventData and eventData.eventType == eventType then
			return true
		end
	end

	return false
end

return ActivityPopUtils
