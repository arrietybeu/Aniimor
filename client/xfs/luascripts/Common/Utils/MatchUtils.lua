-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Utils\\MatchUtils.lua

local Const = require("Common.Const.Const")
local LevelData = require("Data.level_data")
local MatchConfigData = require("Data.match_data")
local MatchRequirementData = require("Data.match_requirement_data")
local PlatformUtils = require("Common.Utils.PlatformUtils")
local MatchUtils = {}

function MatchUtils.buildMatchHashKey(dungeonId, hardLv, playerInfo)
	assert(dungeonId ~= nil, "dungeonId is required")
	assert(hardLv ~= nil, "hardLv is required")

	local parts = {
		tostring(dungeonId),
		tostring(hardLv)
	}

	if playerInfo and PlatformUtils.normalizeAllowCrossNetwork(playerInfo) == false then
		parts[#parts + 1] = PlatformUtils.normalizePlatformFamily(playerInfo)
	end

	return table.concat(parts, "_")
end

function MatchUtils.buildMatchHashKeyWithDungeonPlayId(dungeonPlayId, playerInfo)
	assert(dungeonPlayId ~= nil, "dungeonPlayId is required")

	local parts = {
		dungeonPlayId
	}

	if playerInfo and PlatformUtils.normalizeAllowCrossNetwork(playerInfo) == false then
		parts[#parts + 1] = PlatformUtils.normalizePlatformFamily(playerInfo)
	end

	return table.concat(parts, "_")
end

function MatchUtils.parseMatchHashKey(key)
	local i = key:find("_", 1, true)

	if not i then
		return 0, 0, ""
	end

	local j = key:find("_", i + 1, true)
	local dungeonId = ToInt(key:sub(1, i - 1))

	if not j then
		local hardLv = ToInt(key:sub(i + 1))

		return dungeonId, hardLv, ""
	end

	local hardLv = ToInt(key:sub(i + 1, j - 1))
	local platformFamily = key:sub(j + 1)

	return dungeonId, hardLv, platformFamily
end

function MatchUtils.getDungeonHardKey(key)
	local i = string.find(key, "_", 1, true)

	if not i then
		return key
	end

	local j = string.find(key, "_", i + 1, true)

	if not j then
		return key
	end

	return string.sub(key, 1, j - 1)
end

function MatchUtils.getMatchConfigId(dungeonId)
	return LevelData[dungeonId].matchId or 0
end

function MatchUtils.getMatchConfig(dungeonId)
	local matchId = LevelData[dungeonId].matchId or 0

	return MatchConfigData[matchId]
end

function MatchUtils.getMatchRequirementsConfig(dungeonId)
	local matchConfig = MatchUtils.getMatchConfig(dungeonId) or {}
	local planId = matchConfig.campPlan or 0

	if matchConfig.type == Const.MATCH_CONFIG_TYPE.TEAM then
		planId = matchConfig.memberPlan or 0
	end

	return MatchRequirementData[planId]
end

function MatchUtils.getMatchRequirementsConfigByMatchConfig(matchConfig)
	local planId = matchConfig.campPlan or 0

	if matchConfig.type == Const.MATCH_CONFIG_TYPE.TEAM then
		planId = matchConfig.memberPlan or 0
	end

	return MatchRequirementData[planId]
end

function MatchUtils.isNeedConfirmForMatched(dungeonSceneId)
	local levelData = LevelData[dungeonSceneId]

	if not levelData then
		return true
	end

	local matchId = levelData.matchId or 0
	local matchConfig = MatchConfigData[matchId]

	if not matchConfig then
		return true
	end

	if matchConfig.type == Const.MATCH_CONFIG_TYPE.DUNGEON then
		return false
	end

	return true
end

return MatchUtils
