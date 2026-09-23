-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\FishingCapturePetalSource\\FishingCapturePetalSourceModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local Time = require("Core.Common.Time")
local Utils = require("Common.Utils.Utils")
local ClientUtils = require("Utils.ClientUtils")
local ClientActivityUtils = require("Utils.ClientActivityUtils")
local ActivityConst = require("Common.Const.ActivityConst")
local FishingCaptureConst = require("Common.Const.FishingCaptureConst")
local GameEventData = require("Data.game_event_data")
local FishingCaptureActivityData = require("Data.fishing_capture_activity_data")
local FishingCapturePetalSourceData = require("Data.fishing_capture_petal_source_data")
local ItemData = require("Data.item_data")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local FishingCapturePetalSourceModel = Class.LightClass("FishingCapturePetalSourceModel", UIModel)

FishingCapturePetalSourceModel.GroupType = {
	Exploration = 2,
	Weekly = 1
}
FishingCapturePetalSourceModel.ChannelState = {
	Completed = 2,
	Locked = 1,
	Normal = 0
}
FishingCapturePetalSourceModel.Stage = FishingCaptureConst.ActivityStage
FishingCapturePetalSourceModel.ChannelCountdownType = {
	None = 0,
	Ended = 3,
	End = 2,
	Open = 1
}
FishingCapturePetalSourceModel.ChannelSortPriority = {
	[FishingCapturePetalSourceModel.ChannelState.Normal] = 1,
	[FishingCapturePetalSourceModel.ChannelState.Locked] = 2,
	[FishingCapturePetalSourceModel.ChannelState.Completed] = 3
}

function FishingCapturePetalSourceModel.resolveChannelState(conditionMet, now, startTime, endTime, current, target)
	if (tonumber(target) or 0) > 0 and (tonumber(current) or 0) >= tonumber(target) then
		return FishingCapturePetalSourceModel.ChannelState.Completed
	end

	if not conditionMet or startTime and now < startTime or endTime and endTime <= now then
		return FishingCapturePetalSourceModel.ChannelState.Locked
	end

	return FishingCapturePetalSourceModel.ChannelState.Normal
end

function FishingCapturePetalSourceModel.clampChannelCurrent(current, target)
	current = tonumber(current) or 0
	target = tonumber(target) or 0

	if target > 0 and target < current then
		return target
	end

	return current
end

function FishingCapturePetalSourceModel.resolveChannelCountdown(now, startTime, endTime)
	local Type = FishingCapturePetalSourceModel.ChannelCountdownType

	if startTime and now < startTime then
		return Type.Open, startTime
	end

	if endTime and endTime <= now then
		return Type.Ended, nil
	end

	if endTime then
		return Type.End, endTime
	end

	return Type.None, nil
end

function FishingCapturePetalSourceModel:ctor()
	self.info = {}
	self.fishingData = {}
	self.groups = self:buildGroups()
end

function FishingCapturePetalSourceModel.checkShowCondition(showCondition)
	if showCondition == nil or showCondition == 0 then
		return true
	end

	return ClientUtils.checkCondition(showCondition)
end

function FishingCapturePetalSourceModel._sortChannel(left, right)
	local leftPriority = FishingCapturePetalSourceModel.ChannelSortPriority[left.state] or math.huge
	local rightPriority = FishingCapturePetalSourceModel.ChannelSortPriority[right.state] or math.huge

	if leftPriority ~= rightPriority then
		return leftPriority < rightPriority
	end

	local leftSort = tonumber(left.sort) or 0
	local rightSort = tonumber(right.sort) or 0

	if leftSort ~= rightSort then
		return leftSort < rightSort
	end

	local leftId = tonumber(left.id)
	local rightId = tonumber(right.id)

	if leftId and rightId then
		return leftId < rightId
	end

	return tostring(left.id) < tostring(right.id)
end

function FishingCapturePetalSourceModel:buildGroups()
	local groups = {
		{
			groupType = FishingCapturePetalSourceModel.GroupType.Weekly,
			channels = {},
			locked = self.displayStage == FishingCapturePetalSourceModel.Stage.FlowerGathering,
			unlockTime = self.stageTwoStartTime
		},
		{
			locked = false,
			groupType = FishingCapturePetalSourceModel.GroupType.Exploration,
			channels = {}
		}
	}
	local groupByType = {
		[FishingCapturePetalSourceModel.GroupType.Weekly] = groups[1],
		[FishingCapturePetalSourceModel.GroupType.Exploration] = groups[2]
	}
	local channelConfigs = FishingCapturePetalSourceData[self.info.eventId] or {}
	local rewardStatistics = self.fishingData.rewardStatistics or {}
	local now = Time.secondCache

	for channelSourceId, channelConfigList in pairs(channelConfigs) do
		for configIndex, channelConfig in ipairs(channelConfigList) do
			local groupType = channelConfig.tab
			local current = FishingCapturePetalSourceModel.clampChannelCurrent(rewardStatistics[channelConfig.logtype], channelConfig.logassign)
			local startTime = Utils.getConfigTimeOfArea(channelConfig, "tabStartDayTime")
			local endTime = Utils.getConfigTimeOfArea(channelConfig, "tabEndDayTime")
			local conditionMet = FishingCapturePetalSourceModel.checkShowCondition(channelConfig.showCondition)
			local state = FishingCapturePetalSourceModel.resolveChannelState(conditionMet, now, startTime, endTime, current, channelConfig.logassign)
			local countdownType, countdownTarget = FishingCapturePetalSourceModel.resolveChannelCountdown(now, startTime, endTime)
			local group = groupByType[groupType]

			group.channels[#group.channels + 1] = {
				id = channelConfig.logtype,
				groupType = groupType,
				nameId = channelConfig.name,
				icon = channelConfig.icon,
				current = current,
				target = channelConfig.logassign,
				state = state,
				sort = channelConfig.sort or channelConfig.logtype or configIndex,
				sourceId = channelConfig.configsource,
				conditionMet = conditionMet,
				conditionText = channelConfig.conditionText,
				logText = channelConfig.logtext,
				countdownType = countdownType,
				countdownTarget = countdownTarget,
				newRedDot = groupType == self.GroupType.Weekly and tonumber(channelConfig.logtype) == 10 and state == self.ChannelState.Normal and ClientActivityUtils._getFishingCaptureNewState(self.info.eventId, ClientActivityUtils.FishingCaptureRedDotName.WeeklyItem, channelConfig.logtype) or false
			}
		end
	end

	for _, group in ipairs(groups) do
		table.sort(group.channels, FishingCapturePetalSourceModel._sortChannel)
	end

	return groups
end

function FishingCapturePetalSourceModel.buildItemInfo(eventId)
	local eventData = GameEventData and GameEventData[eventId]
	local activityData = eventData and FishingCaptureActivityData and FishingCaptureActivityData[eventData.phase]
	local petalItemId = activityData and activityData.petalItemId
	local itemData = petalItemId and ItemData and ItemData[petalItemId] or {}
	local count = ClientActivityUtils.getFishingCapturePetalTotalCnt()

	return {
		id = petalItemId,
		nameId = itemData.itemName,
		descId = itemData.itemDes or itemData.funcRep,
		icon = itemData.icon,
		count = count
	}
end

function FishingCapturePetalSourceModel:refreshData()
	local eventId = self.info.eventId

	self.fishingData = ActivityUtils.getActivityData(pg.me, ActivityConst.EventType.FishingCapture) or {}
	self.displayStage, self.stageTwoStartTime = ClientActivityUtils.getFishingCaptureDisplayStage(eventId)
	self.groups = self:buildGroups()
	self.itemInfo = FishingCapturePetalSourceModel.buildItemInfo(eventId)
end

function FishingCapturePetalSourceModel:setInfo(info)
	self.info = {}

	if type(info) == "table" and info.eventId ~= nil then
		self.info.eventId = info.eventId
	end

	self:refreshData()
end

function FishingCapturePetalSourceModel:getVisibleGroups()
	local visibleGroups = {}

	for _, group in ipairs(self.groups) do
		if #group.channels > 0 then
			visibleGroups[#visibleGroups + 1] = group
		end
	end

	return visibleGroups
end

function FishingCapturePetalSourceModel:getItemInfo()
	return self.itemInfo
end

function FishingCapturePetalSourceModel:getInfo()
	return self.info
end

function FishingCapturePetalSourceModel:getGroups()
	return self.groups
end

function FishingCapturePetalSourceModel:getGroup(groupType)
	for _, group in ipairs(self.groups) do
		if group.groupType == groupType then
			return group
		end
	end

	return nil
end

return FishingCapturePetalSourceModel
