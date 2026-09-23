-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Utils\\TimeTokenUtils.lua

local Time = require("Core.Common.Time")
local Utils = require("Common.Utils.Utils")
local TimeTokenData = require("Data.time_token_data")
local TimeTokenIndexData = require("Data.time_token_index_data")
local TimeTokenUtils = {}

function TimeTokenUtils.getConfig(tokenId)
	tokenId = tonumber(tokenId)

	if not tokenId then
		return nil
	end

	return TimeTokenData[tokenId]
end

function TimeTokenUtils.getTriggerTime(tokenId)
	tokenId = tonumber(tokenId)

	local tokenData = tokenId and TimeTokenData[tokenId]

	if not tokenData then
		return nil, string.format("time token config not found, tokenId=%s", tostring(tokenId))
	end

	local triggerTime = tonumber(Utils.getConfigTimeOfArea(tokenData, "time"))

	if not triggerTime or triggerTime <= 0 then
		return nil, string.format("time token timestamp invalid, tokenId=%s", tostring(tokenId))
	end

	return triggerTime
end

function TimeTokenUtils.getConditionId(tokenId)
	local tokenData = TimeTokenUtils.getConfig(tokenId)

	if not tokenData then
		return 0
	end

	return tonumber(tokenData.condition) or 0
end

function TimeTokenUtils.isTimeReached(tokenId, now)
	local triggerTime = TimeTokenUtils.getTriggerTime(tokenId)

	if not triggerTime then
		return false
	end

	now = now or Time.secondCache

	if triggerTime <= now then
		return true
	end

	return false
end

function TimeTokenUtils.isConditionMet(player, tokenId)
	if not player or not player.triggerMap then
		return false
	end

	local conditionId = TimeTokenUtils.getConditionId(tokenId)

	if conditionId <= 0 then
		return true
	end

	return player.triggerMap:isCompleteOrMeetCondition(conditionId)
end

function TimeTokenUtils.canTrigger(player, tokenId, now)
	if not TimeTokenUtils.isTimeReached(tokenId, now) then
		return false
	end

	if not TimeTokenUtils.isConditionMet(player, tokenId) then
		return false
	end

	return true
end

function TimeTokenUtils.getTokenIdsByCondition(conditionId)
	conditionId = tonumber(conditionId)

	return TimeTokenIndexData.conditionTokenMap[conditionId] or {}
end

function TimeTokenUtils.getAllTokenIds()
	return TimeTokenIndexData.allTokenIds or {}
end

return TimeTokenUtils
