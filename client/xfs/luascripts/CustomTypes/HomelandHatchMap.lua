-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\HomelandHatchMap.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local Time = require("Core.Common.Time")
local lume = require("Core.Common.lume")
local PetBallConfigData = require("Data.pet_ball_config_data")
local NoticeDef = require("Common.NoticeDef")
local FormulaData = require("Data.formula_data")
local PetHatchEggData = require("Data.pet_hatch_egg_data")
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local HomelandHatchMap = class.LiteClass("HomelandHatchMap", CustomDict)

function HomelandHatchMap:getHatchInfo(hatchOrnamentId)
	return self[hatchOrnamentId]
end

function HomelandHatchMap:checkCanStartHatch(hatchOrnamentId)
	if self[hatchOrnamentId] then
		return false, NoticeDef.ERROR_CLIENT_PARAM
	end

	if lume.tableLength(self) >= PetBallConfigData.homelandHatchMaxCountLimit then
		return false, NoticeDef.HOMELAND_HATCH_MAX_COUNT_LIMIT
	end

	return true, NoticeDef.SUCCESS
end

function HomelandHatchMap:startHatch(hatchOrnamentId, snapshot, ornamentEnvInfo, isCarSpeedUp, hatchAccelSeconds)
	local nowTime = Time.getSecond()
	local envFactor = self:_calcEnvFactor(ornamentEnvInfo, snapshot.id)
	local homeCarRatio = 0

	if isCarSpeedUp then
		homeCarRatio = PetBallConfigData.homelandHatchCarSpeedUpRatio or 0
	end

	self[hatchOrnamentId] = {}

	local hatchInfo = self[hatchOrnamentId]

	hatchInfo:startHatch(nowTime, snapshot, envFactor, homeCarRatio)

	if hatchAccelSeconds and lume.getMapLen(hatchAccelSeconds) > 0 then
		for reason, hatchAccelSecond in pairs(hatchAccelSeconds) do
			hatchInfo:applyReduction(nowTime, hatchAccelSecond, 0, reason)
		end

		hatchInfo:refreshHatchStatus(nowTime)
	end
end

function HomelandHatchMap:removeHatch(hatchOrnamentId)
	self[hatchOrnamentId] = nil
end

function HomelandHatchMap:checkCanFondle(hatchOrnamentId, playerId)
	if not self[hatchOrnamentId] then
		return false, NoticeDef.ERROR_CLIENT_PARAM
	end

	return self[hatchOrnamentId]:checkCanFondle(playerId)
end

function HomelandHatchMap:fondle(hatchOrnamentId, playerId, fixedReduction, timeRateReduction)
	if not self[hatchOrnamentId] then
		return false
	end

	local nowTime = Time.getSecond()

	self[hatchOrnamentId]:addFondleCount(playerId)
	self[hatchOrnamentId]:applyReduction(nowTime, fixedReduction, timeRateReduction, Const.HatchSpeedUpReason.stroke)
	self[hatchOrnamentId]:refreshHatchStatus(nowTime)

	return true
end

function HomelandHatchMap:checkCanItemSpeedUp(hatchOrnamentId)
	if not self[hatchOrnamentId] then
		return false, NoticeDef.ERROR_CLIENT_PARAM
	end

	return self[hatchOrnamentId]:checkCanItemSpeedUp()
end

function HomelandHatchMap:itemSpeedUp(hatchOrnamentId, fixedReduction, timeRateReduction)
	if not self[hatchOrnamentId] then
		return false
	end

	local nowTime = Time.getSecond()

	self[hatchOrnamentId]:addItemSpeedUpCount()
	self[hatchOrnamentId]:applyReduction(nowTime, fixedReduction, timeRateReduction, Const.HatchSpeedUpReason.item)
	self[hatchOrnamentId]:refreshHatchStatus(nowTime)

	return true
end

function HomelandHatchMap:applyHomeCarSpeedUp(isCarSpeedUp)
	if not isCarSpeedUp then
		return
	end

	local ratio = PetBallConfigData.homelandHatchCarSpeedUpRatio or 0
	local nowTime = Time.getSecond()

	for _, hatchInfo in pairs(self) do
		hatchInfo:applyHomeCarSpeedUp(nowTime, ratio)
	end
end

function HomelandHatchMap:applyMonthCardSpeedUp(accelSecs)
	accelSecs = accelSecs or 0

	if accelSecs <= 0 then
		return
	end

	local nowTime = Time.getSecond()

	for _, hatchInfo in pairs(self) do
		hatchInfo:applyReduction(nowTime, accelSecs, 0, Const.HatchSpeedUpReason.monthcard)
		hatchInfo:refreshHatchStatus(nowTime)
	end
end

function HomelandHatchMap:refreshHatchStatus(nowTime)
	local nextRefreshTs = math.huge

	for _, hatchInfo in pairs(self) do
		local isFinish, endTime = hatchInfo:refreshHatchStatus(nowTime)

		if not isFinish then
			nextRefreshTs = math.min(nextRefreshTs, endTime)
		end
	end

	return nextRefreshTs
end

function HomelandHatchMap:canBeAffectedByEnv(hatchOrnamentId)
	if not self[hatchOrnamentId] then
		return false
	end

	return self[hatchOrnamentId]:canBeAffectedByEnv()
end

function HomelandHatchMap:changeEnvFactor(hatchOrnamentId, ornamentEnvInfo)
	if not self[hatchOrnamentId] then
		return false
	end

	local itemId = self[hatchOrnamentId]:getItemId()
	local newEnvFactor = self:_calcEnvFactor(ornamentEnvInfo, itemId)

	self[hatchOrnamentId]:onEnvironmentChanged(Time.getSecond(), newEnvFactor)

	return true
end

function HomelandHatchMap:_calcEnvFactor(ornamentEnvInfo, itemId)
	if not ornamentEnvInfo then
		return 0
	end

	if not PetBallConfigData.homelandHatchEnvFormulaId then
		return 0
	end

	if not FormulaData[PetBallConfigData.homelandHatchEnvFormulaId] then
		return 0
	end

	local configDat = PetHatchEggData[itemId]

	if not configDat then
		return 0
	end

	local requireTemperature, requireLight = Utils.safeUnpack(configDat.requireEnvs or {})

	return FormulaData[PetBallConfigData.homelandHatchEnvFormulaId].formula(ornamentEnvInfo.temperature, ornamentEnvInfo.light, requireTemperature or 0, requireLight or 0)
end

function HomelandHatchMap:getHatchNextRefreshTime()
	local nextRefreshTs = math.huge

	for _, hatchInfo in pairs(self) do
		if hatchInfo.status == Const.PET_BALL.HATCH_STATUS_START then
			nextRefreshTs = math.min(nextRefreshTs, hatchInfo:getEndTime())
		end
	end

	return nextRefreshTs
end

function HomelandHatchMap:getClientHatchInfo(hatchOrnamentId)
	if not self[hatchOrnamentId] then
		return {}
	end

	return self[hatchOrnamentId]:getClientHatchInfo()
end

function HomelandHatchMap:getClientFullHatchInfo()
	local fullHatchInfo = {}

	for k, v in pairs(self) do
		fullHatchInfo[k] = v:getClientHatchInfo()
	end

	return fullHatchInfo
end

function HomelandHatchMap:onDayUpdate()
	local nowTime = Time.getSecond()

	for k, v in pairs(self) do
		v:onDayUpdate(nowTime)
	end
end

function HomelandHatchMap:getAllHatchOrnamentId()
	local allHatchOrnamentId = {}

	for k, v in pairs(self) do
		table.insert(allHatchOrnamentId, k)
	end

	return allHatchOrnamentId
end

return HomelandHatchMap
