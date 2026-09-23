-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientRankComponent.lua

local CallbackHandler = require("Core.Common.CallbackHandler")
local Class = require("Core.Framework.Class")
local RankUtils = require("Utils.RankUtils")
local ClientRankComponent = Class.Component("ClientRankComponent")

function ClientRankComponent:getRankTabMapping(rankId, tab1, tab2, callback)
	self:callService("RankService", "getRankTabMapping", {
		rankId,
		tab1,
		tab2,
		RankUtils.getRankClusterId()
	}, CallbackHandler(self, "_rankTabMappingCallback", callback), {
		hint = rankId
	})
end

function ClientRankComponent:getRankTabMappingList(callback)
	self:callService("RankService", "getRankTabMappingList", {
		RankUtils.getRankClusterId()
	}, CallbackHandler(self, "_rankTabMappingCallback", callback), {
		hint = "rank_tab_mapping_list"
	})
end

function ClientRankComponent:_rankTabMappingCallback(callback, retStatus, response)
	if callback then
		callback(retStatus, response)
	end
end

function ClientRankComponent:queryRankMembers(rankId, memberIds, callback)
	self:callService("RankService", "queryRankMembers", {
		rankId,
		memberIds
	}, CallbackHandler(self, "_rankMembersCallback", callback), {
		hint = rankId
	})
end

function ClientRankComponent:_rankMembersCallback(callback, retStatus, response)
	if callback then
		callback(retStatus, response)
	end
end

function ClientRankComponent:rangeRankMembers(rankId, low, high, callback)
	self:callService("RankService", "rangeRankMembers", {
		rankId,
		low,
		high
	}, CallbackHandler(self, "_rankMembersCallback", callback), {
		hint = rankId
	})
end

return ClientRankComponent
