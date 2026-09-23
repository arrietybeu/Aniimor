-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\RankUtils.lua

local ServiceUtils = require("Common.Utils.ServiceUtils")
local GlobalData = require("Core.Client.GlobalData")
local LoggerManager = require("Core.Log.LoggerManager")
local RankUtils = {}
local EMPTY_LIST = {}
local logger = LoggerManager.getLogger("RankUtils")

local function getRankClusterId()
	local serverId = GlobalData.ServerId

	if _G_IsDebugMode == true then
		return tostring(serverId or "")
	end

	return ""
end

RankUtils.getRankClusterId = getRankClusterId

local function isInvalidResponse(retStatus, response)
	return retStatus == nil or not retStatus.status or response == nil
end

local function getRankValue(rankData)
	local rank = rankData and tonumber(rankData.Rank)

	return rank and rank > 0 and rank or -1
end

local function findMemberRankData(rankList, memberId)
	for _, rankData in ipairs(rankList) do
		if tostring(rankData.MemberId) == memberId then
			return rankData
		end
	end
end

function RankUtils.queryRankMembers(rankId, memberIds, callback)
	ServiceUtils.callService("RankService", "queryRankMembers", {
		rankId,
		memberIds
	}, callback, {
		hint = rankId
	})
end

function RankUtils.rangeRankMembers(rankId, low, high, callback)
	ServiceUtils.callService("RankService", "rangeRankMembers", {
		rankId,
		low,
		high
	}, callback, {
		hint = rankId
	})
end

function RankUtils.getRankTabMapping(rankId, tab1, tab2, callback)
	ServiceUtils.callService("RankService", "getRankTabMapping", {
		rankId,
		tab1,
		tab2,
		getRankClusterId()
	}, callback, {
		hint = rankId
	})
end

function RankUtils.getRankTabMappingList(callback)
	ServiceUtils.callService("RankService", "getRankTabMappingList", {
		getRankClusterId()
	}, callback, {
		hint = "rank_tab_mapping_list"
	})
end

function RankUtils.markRankCacheInvalid(rankId)
	local rankSystem = pg.game and pg.game.rank

	if rankSystem == nil then
		return false
	end

	return rankSystem:invalidateRankCache(rankId)
end

function RankUtils.queryMemberRank(rankId, tab1, tab2, memberId, callback)
	if callback == nil then
		return
	end

	local memberIdValue = tostring(memberId)
	local rankSystem = pg.game.rank

	if rankSystem ~= nil then
		local config = rankSystem:getRankRequestConfig(rankId, tab1, tab2)

		if config ~= nil and rankSystem:isRankCacheValid(rankId, tab1, tab2, config) then
			if pg.me ~= nil and tostring(pg.me.uid) == memberIdValue then
				local selfRankData = rankSystem:getCachedSelfRankData(rankId, tab1, tab2)

				if selfRankData ~= nil then
					callback(getRankValue(selfRankData))

					return
				end
			end

			local rankList = rankSystem:getCachedRankData(rankId, tab1, tab2)

			callback(getRankValue(findMemberRankData(rankList, memberIdValue)))

			return
		end
	end

	local logicalRankId = tostring(rankId)
	local tab1Value = tostring(tab1)
	local tab2Value = tostring(tab2)

	RankUtils.getRankTabMapping(logicalRankId, tab1Value, tab2Value, function(mappingStatus, mappingResponse)
		if isInvalidResponse(mappingStatus, mappingResponse) then
			callback(nil)

			return
		end

		local periodRankId = mappingResponse.CurrentRankSetId

		if periodRankId == nil or periodRankId == "" then
			callback(nil)

			return
		end

		RankUtils.queryRankMembers(periodRankId, {
			memberIdValue
		}, function(rankStatus, rankResponse)
			if isInvalidResponse(rankStatus, rankResponse) then
				callback(nil)

				return
			end

			local rankData = findMemberRankData(rankResponse.RankList or EMPTY_LIST, memberIdValue)

			callback(getRankValue(rankData))
		end)
	end)
end

return RankUtils
