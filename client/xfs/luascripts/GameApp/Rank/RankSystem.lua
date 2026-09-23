-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Rank\\RankSystem.lua

local RankConst = require("Common.Const.RankConst")
local CallbackHandler = require("Core.Common.CallbackHandler")
local Class = require("Core.Framework.Class")
local LoggerManager = require("Core.Log.LoggerManager")
local MessageName = require("Const.MessageName")
local RankBaseData = require("Data.rank_base_data")
local SystemBase = require("GameApp.Core.SystemBase")
local Time = require("Core.Common.Time")
local logger = LoggerManager.getLogger("RankSystem")
local EMPTY_LIST = {}
local RankSystem = Class.LightClass("RankSystem", SystemBase)

local function getRankKey(rankId, tab1, tab2)
	return string.format("%s|%s|%s", rankId, tab1, tab2)
end

local function getPeriodRankId(rankSystem, rankId, tab1, tab2, periodRankId)
	return periodRankId or rankSystem:getCurrentRankId(rankId, tab1, tab2)
end

local function isCacheValid(updateTimes, rankKey, config)
	local updateTime = updateTimes[rankKey]

	if updateTime == nil then
		return false
	end

	return config.refreshType ~= 1 or Time.realSecondCache - updateTime < config.frequency
end

local function shouldRequestCache(updateTimes, requesting, rankKey, config)
	if requesting[rankKey] then
		return false
	end

	return not isCacheValid(updateTimes, rankKey, config)
end

function RankSystem:onCtor()
	self:onClear()
end

function RankSystem:onClear()
	self.rankData = {}
	self.selfRankData = {}
	self.rankTabMappings = {}
	self.rankTabMappingRequesting = {}
	self.rankTabMappingPendingRefreshes = {}
	self.rankKeysByRankId = {}
	self.rankUpdateTimes = {}
	self.rankRequesting = {}
end

function RankSystem:setRankData(rankId, periodRankId, rankData)
	self.rankUpdateTimes[periodRankId] = Time.realSecondCache
	self.rankData[periodRankId] = rankData

	facade:SendMessageCommand(MessageName.RANK_DATA_UPDATED, rankId)
end

function RankSystem:getCachedRankData(rankId, tab1, tab2, periodRankId)
	periodRankId = getPeriodRankId(self, rankId, tab1, tab2, periodRankId)

	return periodRankId and self.rankData[periodRankId] or EMPTY_LIST
end

function RankSystem:getCachedSelfRankData(rankId, tab1, tab2, periodRankId)
	periodRankId = getPeriodRankId(self, rankId, tab1, tab2, periodRankId)

	return periodRankId and self.selfRankData[periodRankId]
end

function RankSystem:refreshRankDataIfNeeded(rankId, tab1, tab2, config, periodRankId)
	local currentRankId = self:getCurrentRankId(rankId, tab1, tab2)
	local pendingPeriodRankId = periodRankId ~= currentRankId and periodRankId or nil
	local mappingReady = self:refreshRankTabMappingIfNeeded(rankId, tab1, tab2, config.frequency, pendingPeriodRankId)

	if mappingReady == false then
		return
	end

	self:refreshPeriodRankDataIfNeeded(rankId, tab1, tab2, config, periodRankId)
end

function RankSystem:refreshPeriodRankDataIfNeeded(rankId, tab1, tab2, config, periodRankId)
	periodRankId = getPeriodRankId(self, rankId, tab1, tab2, periodRankId)

	if periodRankId == nil then
		return
	end

	if not self:shouldRequestRankData(periodRankId, config) then
		return
	end

	if self:isRankDataCacheExpired(periodRankId, config) then
		self:invalidateRankCache(rankId)
	end

	self:requestRankData(rankId, tab1, tab2, config, periodRankId)
end

function RankSystem:isRankDataCacheExpired(periodRankId, config)
	local updateTime = self.rankUpdateTimes[periodRankId]

	return updateTime ~= nil and not isCacheValid(self.rankUpdateTimes, periodRankId, config)
end

function RankSystem:refreshRankTabMappingIfNeeded(rankId, tab1, tab2, cacheDuration, periodRankId)
	local rankKey = getRankKey(rankId, tab1, tab2)
	local mappingValid = self:isRankTabMappingCacheValid(rankId, tab1, tab2, cacheDuration)

	if mappingValid then
		return true
	end

	self.rankTabMappingPendingRefreshes[rankKey] = {
		periodRankId = periodRankId
	}

	if self.rankTabMappingRequesting[rankKey] == true then
		return false
	end

	if pg.me == nil or pg.me.isGuidancePlayer then
		return false
	end

	self.rankTabMappingRequesting[rankKey] = true

	pg.me:getRankTabMapping(tostring(rankId), tostring(tab1), tostring(tab2), CallbackHandler(self, "onRankTabMappingResponse", rankId, tab1, tab2))

	return false
end

function RankSystem:onRankTabMappingResponse(rankId, tab1, tab2, retStatus, response)
	local rankKey = getRankKey(rankId, tab1, tab2)
	local pendingRefresh = self.rankTabMappingPendingRefreshes[rankKey]

	self.rankTabMappingRequesting[rankKey] = nil
	self.rankTabMappingPendingRefreshes[rankKey] = nil

	if retStatus == nil or not retStatus.status or response == nil then
		logger:error("onRankTabMappingResponse failed, rankKey=%s, error=%s", rankKey, retStatus and retStatus.errmsg or "empty response")

		return
	end

	local previousMapping = self.rankTabMappings[rankKey]
	local mappingChanged = previousMapping == nil or previousMapping.currentRankId ~= response.CurrentRankSetId or not table.equal(previousMapping.previousRankIds, response.PreviousRankSetIds)

	self.rankTabMappings[rankKey] = {
		currentRankId = response.CurrentRankSetId,
		previousRankIds = response.PreviousRankSetIds,
		updateTime = Time.realSecondCache
	}

	self:recordRankKey(rankId, rankKey)

	local periodRankId = pendingRefresh and pendingRefresh.periodRankId

	if mappingChanged then
		periodRankId = nil

		facade:SendMessageCommand(MessageName.RANK_TAB_MAPPING_UPDATED, {
			rankId = rankId,
			tab1 = tab1,
			tab2 = tab2
		})
	end

	self:refreshPeriodRankDataIfNeeded(rankId, tab1, tab2, self:getRankRequestConfig(rankId, tab1, tab2), periodRankId)
end

function RankSystem:recordRankKey(rankId, rankKey)
	local rankKeys = self.rankKeysByRankId[rankId]

	if rankKeys == nil then
		rankKeys = {}
		self.rankKeysByRankId[rankId] = rankKeys
	end

	rankKeys[rankKey] = true
end

function RankSystem:isRankDataRequesting(rankId, tab1, tab2, periodRankId)
	periodRankId = getPeriodRankId(self, rankId, tab1, tab2, periodRankId)

	return periodRankId ~= nil and self.rankRequesting[periodRankId] == true
end

function RankSystem:getRankRequestConfig(rankId, tab1, tab2)
	return RankBaseData[rankId][tab1][tab2]
end

function RankSystem:getCurrentRankId(rankId, tab1, tab2)
	local mapping = self.rankTabMappings[getRankKey(rankId, tab1, tab2)]
	local currentRankId = mapping and mapping.currentRankId

	return currentRankId ~= "" and currentRankId or nil
end

function RankSystem:getPreviousRankId(rankId, tab1, tab2)
	local mapping = self.rankTabMappings[getRankKey(rankId, tab1, tab2)]

	return mapping and mapping.previousRankIds[1]
end

function RankSystem:shouldRequestRankData(rankKey, config)
	return shouldRequestCache(self.rankUpdateTimes, self.rankRequesting, rankKey, config)
end

function RankSystem:requestRankData(rankId, tab1, tab2, config, periodRankId)
	if pg.me == nil or pg.me.isGuidancePlayer then
		return
	end

	local rankKey = getRankKey(rankId, tab1, tab2)

	periodRankId = getPeriodRankId(self, rankId, tab1, tab2, periodRankId)

	if periodRankId == nil then
		logger:error("requestRankData period rankId not found, rankKey=%s", rankKey)

		return
	end

	self.rankRequesting[periodRankId] = true

	pg.me:rangeRankMembers(periodRankId, 1, config.displayList, CallbackHandler(self, "onRankMembersResponse", rankId, periodRankId))
end

function RankSystem:onRankMembersResponse(rankId, periodRankId, retStatus, response)
	self:onSetRankMembers(rankId, periodRankId, retStatus, response)

	if self.selfRankData[periodRankId] == nil then
		pg.me:queryRankMembers(periodRankId, {
			pg.me.uid
		}, CallbackHandler(self, "onUpdateSelfRank", rankId, periodRankId))
	end
end

function RankSystem:onSetRankMembers(rankId, periodRankId, retStatus, response)
	if retStatus == nil or not retStatus.status or response == nil then
		self.rankRequesting[periodRankId] = nil

		logger:error("onRankMembersResponse failed, periodRankId=%s, error=%s", periodRankId, retStatus and retStatus.errmsg or "empty response")

		return
	end

	local rankList = response.RankList or EMPTY_LIST

	self.selfRankData[periodRankId] = self:getMemberRankData(rankList, pg.me.uid)
	self.rankRequesting[periodRankId] = nil

	self:setRankData(rankId, periodRankId, rankList)
end

function RankSystem:onUpdateSelfRank(rankId, periodRankId, retStatus, response)
	if retStatus == nil or not retStatus.status or response == nil then
		self.rankRequesting[periodRankId] = nil

		logger:error("onUpdateSelfRank failed, periodRankId=%s, error=%s", periodRankId, retStatus and retStatus.errmsg or "empty response")

		return
	end

	local rankList = response.RankList or EMPTY_LIST

	self.selfRankData[periodRankId] = self:getMemberRankData(rankList, pg.me.uid)

	facade:SendMessageCommand(MessageName.SELF_RANK_DATA_UPDATED, rankId)
end

function RankSystem:getMemberRankData(rankList, queriedMemberId)
	local memberRankData

	for _, rankData in ipairs(rankList) do
		local isHigherRank = memberRankData == nil or rankData.Rank < memberRankData.Rank

		if self:isMemberRankData(rankData, queriedMemberId) and isHigherRank then
			memberRankData = rankData
		end
	end

	return memberRankData
end

function RankSystem:isMemberRankData(rankData, queriedMemberId)
	if rankData.MemberId == queriedMemberId then
		return true
	end

	return self:isTeamMemberRankData(rankData, queriedMemberId)
end

function RankSystem:isTeamMemberRankData(rankData, queriedMemberId)
	local rankInfo = rankData.Info
	local teamInfo = rankInfo[tostring(RankConst.ShowEnum.TeamInfo)]

	if teamInfo == nil then
		return false
	end

	for _, memberInfo in ipairs(teamInfo.members) do
		if memberInfo.uid == queriedMemberId then
			return true
		end
	end

	return false
end

function RankSystem:isRankTabMappingCacheValid(rankId, tab1, tab2, cacheDuration)
	local mapping = self.rankTabMappings[getRankKey(rankId, tab1, tab2)]

	return mapping ~= nil and mapping.updateTime ~= nil and cacheDuration > Time.realSecondCache - mapping.updateTime
end

function RankSystem:isRankCacheValid(rankId, tab1, tab2, config)
	if not self:isRankTabMappingCacheValid(rankId, tab1, tab2, config.frequency) then
		return false
	end

	local periodRankId = getPeriodRankId(self, rankId, tab1, tab2)

	return periodRankId ~= nil and self.rankData[periodRankId] ~= nil and isCacheValid(self.rankUpdateTimes, periodRankId, config)
end

function RankSystem:invalidateRankCache(rankId)
	local rankKeys = self.rankKeysByRankId[rankId]

	if rankKeys == nil then
		return false
	end

	for rankKey in pairs(rankKeys) do
		local mapping = self.rankTabMappings[rankKey]
		local periodRankId = mapping.currentRankId

		if periodRankId ~= nil and periodRankId ~= "" then
			self.rankUpdateTimes[periodRankId] = nil
		end

		for _, previousRankId in ipairs(mapping.previousRankIds) do
			self.rankUpdateTimes[previousRankId] = nil
		end
	end

	return true
end

return RankSystem
