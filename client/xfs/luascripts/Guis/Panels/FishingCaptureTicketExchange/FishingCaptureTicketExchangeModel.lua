-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\FishingCaptureTicketExchange\\FishingCaptureTicketExchangeModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local FishingCaptureConst = require("Common.Const.FishingCaptureConst")
local ClientActivityUtils = require("Utils.ClientActivityUtils")
local GameEventData = require("Data.game_event_data")
local FishingCaptureActivityData = require("Data.fishing_capture_activity_data")
local ItemData = require("Data.item_data")
local ItemShowTypeData = require("Data.item_type_show_data")
local FishingCaptureTicketExchangeModel = Class.LightClass("FishingCaptureTicketExchangeModel", UIModel)

FishingCaptureTicketExchangeModel.CubeType = FishingCaptureConst.CubeType
FishingCaptureTicketExchangeModel.BuildState = FishingCaptureConst.SeasonCubeState
FishingCaptureTicketExchangeModel.SeekState = {
	Completed = 3,
	Available = 2,
	None = 1
}

function FishingCaptureTicketExchangeModel:ctor()
	self.info = {}
end

function FishingCaptureTicketExchangeModel.resolveBuildState(remainingCount, petalCount, cost)
	local State = FishingCaptureTicketExchangeModel.BuildState

	if remainingCount <= 0 then
		return State.Exhausted
	end

	if cost > 0 and cost <= petalCount then
		return State.CanBuild
	end

	return State.Insufficient
end

function FishingCaptureTicketExchangeModel.resolveSeekState(craftedCount, irisRewardReceived)
	local State = FishingCaptureTicketExchangeModel.SeekState

	if irisRewardReceived == true then
		return State.Completed
	end

	if (tonumber(craftedCount) or 0) >= 1 then
		return State.Available
	end

	return State.None
end

function FishingCaptureTicketExchangeModel:getActivityConfig()
	local eventData = GameEventData[self.info.eventId]

	return eventData and FishingCaptureActivityData[eventData.phase]
end

function FishingCaptureTicketExchangeModel:_buildCubeItem(itemId)
	local itemConfig = ItemData[itemId] or {}
	local itemShowType = ItemShowTypeData[itemConfig.displayType]
	local ownedCount = itemId and pg.me:getItemCountById(itemId) or 0

	return {
		id = itemId,
		ownedCount = ownedCount,
		nameId = itemConfig.itemName,
		typeNameId = itemShowType and itemShowType.type,
		descId = itemConfig.funcRep,
		icon = itemConfig.icon,
		quality = itemConfig.quality
	}
end

function FishingCaptureTicketExchangeModel:_buildIrisPage(activityConfig, petalCount)
	local cubeItemId = activityConfig.coincubeId
	local totalCount = math.max(tonumber(activityConfig.coincubenum) or 0, 0)
	local craftedCount = math.max(ClientActivityUtils.getFishingCaptureCubeExchangeCount(self.CubeType.LEGEND), 0)
	local remainingCount = math.max(totalCount - craftedCount, 0)
	local cost = math.max(tonumber(activityConfig.coincube) or 0, 0)

	return {
		cubeType = self.CubeType.LEGEND,
		cubeItem = self:_buildCubeItem(cubeItemId),
		keyPetType = activityConfig.keyPetType,
		cost = cost,
		craftedCount = craftedCount,
		remainingCount = remainingCount,
		totalCount = totalCount,
		actionState = self.resolveBuildState(remainingCount, petalCount, cost),
		seekState = self.resolveSeekState(craftedCount, ClientActivityUtils.getFishingCaptureIrisRewardReceived())
	}
end

function FishingCaptureTicketExchangeModel:_buildSeasonPage(activityConfig, petalCount)
	local cubeItemId = activityConfig.coinseasoncubeId
	local totalCount = math.max(tonumber(activityConfig.coinseasoncubenum) or 0, 0)
	local craftedCount = math.max(ClientActivityUtils.getFishingCaptureCubeExchangeCount(self.CubeType.SEASON), 0)
	local remainingCount = math.max(totalCount - craftedCount, 0)
	local cost = math.max(tonumber(activityConfig.coinseasoncube) or 0, 0)

	return {
		cubeType = self.CubeType.SEASON,
		cubeItem = self:_buildCubeItem(cubeItemId),
		cost = cost,
		craftedCount = craftedCount,
		remainingCount = remainingCount,
		totalCount = totalCount,
		actionState = self.resolveBuildState(remainingCount, petalCount, cost)
	}
end

function FishingCaptureTicketExchangeModel:buildData()
	local activityConfig = self:getActivityConfig() or {}
	local petalItemId = activityConfig.petalItemId
	local petalCount = petalItemId and pg.me:getItemCountById(petalItemId) or 0
	local displayStage = ClientActivityUtils.getFishingCaptureDisplayStage(self.info.eventId)
	local irisPage = self:_buildIrisPage(activityConfig, petalCount)
	local seasonPage = self:_buildSeasonPage(activityConfig, petalCount)

	return {
		eventId = self.info.eventId,
		stage = displayStage,
		petalItem = {
			id = petalItemId,
			count = petalCount
		},
		cubePages = {
			[self.CubeType.LEGEND] = irisPage,
			[self.CubeType.SEASON] = seasonPage
		}
	}
end

function FishingCaptureTicketExchangeModel:refreshData()
	self.data = self:buildData()
end

function FishingCaptureTicketExchangeModel:setInfo(info)
	self.info = {}

	if info and info.eventId then
		self.info.eventId = info.eventId
	end

	if info and info.cubeType then
		self.info.cubeType = info.cubeType
	end

	self:refreshData()
end

function FishingCaptureTicketExchangeModel:getInfo()
	return self.info
end

function FishingCaptureTicketExchangeModel:getData()
	return self.data
end

return FishingCaptureTicketExchangeModel
