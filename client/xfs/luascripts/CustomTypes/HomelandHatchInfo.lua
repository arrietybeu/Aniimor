-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\HomelandHatchInfo.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local PetHatchEggData = require("Data.pet_hatch_egg_data")
local NoticeDef = require("Common.NoticeDef")
local HomelandHatchInfo = class.LiteClass("HomelandHatchInfo", CustomDict)

function HomelandHatchInfo:startHatch(nowTime, snapshot, envFactor, homeCarRatio)
	self.item = snapshot
	self.status = Const.PET_BALL.HATCH_STATUS_START
	self.baseDuration = self:getBaseDuration()
	self.startTime = nowTime
	self.totalFixedReduction = 0
	self.totalTimeReductionRate = 0
	self.accumulatedProgress = 0
	self.lastRateChangeTime = nowTime
	self.currentEnvFactor = envFactor
	self.homeCarSpeedUpFactor = homeCarRatio
	self.endTime = self:_calcEstimatedEndTime(nowTime)
end

function HomelandHatchInfo:getItemId()
	return self.item.id
end

function HomelandHatchInfo:checkCanFondle(playerId)
	if self.status ~= Const.PET_BALL.HATCH_STATUS_START then
		return false, NoticeDef.ERROR_INVALID_STATUS
	end

	local petHatchEggData = PetHatchEggData[self.item.id]

	if not petHatchEggData then
		return false, NoticeDef.ERROR_CONFIG_NIL
	end

	local count = self.todayFondleByPlayerCount[playerId] or 0

	if count >= petHatchEggData.fondleByPlayerLimitDaily then
		return false, NoticeDef.HOMELAND_HATCH_FONDLE_COUNT_LIMIT_BY_ONEPLAYER
	end

	if self.todayTotalFondleCount >= petHatchEggData.fondleLimitTotalDaily then
		return false, NoticeDef.HOMELAND_HATCH_FONDLE_COUNT_LIMIT_BY_ALLPLAYER
	end

	return true, NoticeDef.SUCCESS
end

function HomelandHatchInfo:addFondleCount(playerId)
	if self.status ~= Const.PET_BALL.HATCH_STATUS_START then
		return
	end

	self.todayFondleByPlayerCount[playerId] = (self.todayFondleByPlayerCount[playerId] or 0) + 1
	self.todayTotalFondleCount = self.todayTotalFondleCount + 1
end

function HomelandHatchInfo:checkCanItemSpeedUp()
	if self.status ~= Const.PET_BALL.HATCH_STATUS_START then
		return false, NoticeDef.ERROR_INVALID_STATUS
	end

	local petHatchEggData = PetHatchEggData[self.item.id]

	if not petHatchEggData then
		return false, NoticeDef.ERROR_CONFIG_NIL
	end

	if self.itemSpeedUpCount >= petHatchEggData.itemSpeedUpLimit then
		return false, NoticeDef.HOMELAND_HATCH_ITEM_SPEED_UP_COUNT_LIMIT
	end

	return true, NoticeDef.SUCCESS
end

function HomelandHatchInfo:addItemSpeedUpCount()
	if self.status ~= Const.PET_BALL.HATCH_STATUS_START then
		return
	end

	self.itemSpeedUpCount = self.itemSpeedUpCount + 1
end

function HomelandHatchInfo:applyReduction(nowTime, fixedSecond, percentReduction, reason)
	if self.status ~= Const.PET_BALL.HATCH_STATUS_START then
		return
	end

	if reason == Const.HatchSpeedUpReason.monthcard and self.fixedReductionMap[reason] and self.fixedReductionMap[reason] > 0 then
		return
	end

	if not self:_isCompletedByReduction() then
		self.accumulatedProgress = self:_getCurrentProgress(nowTime)
	end

	self.totalFixedReduction = self.totalFixedReduction + (fixedSecond or 0)
	self.totalTimeReductionRate = self.totalTimeReductionRate + (percentReduction or 0)
	self.fixedReductionMap[reason] = (self.fixedReductionMap[reason] or 0) + (fixedSecond or 0)
	self.timeReductionRateMap[reason] = (self.timeReductionRateMap[reason] or 0) + (percentReduction or 0)
	self.lastRateChangeTime = nowTime
	self.endTime = self:_calcEstimatedEndTime(nowTime)
end

function HomelandHatchInfo:applyHomeCarSpeedUp(nowTime, homeCarSpeedUpFactor)
	if self.status ~= Const.PET_BALL.HATCH_STATUS_START then
		return
	end

	if not self:_isCompletedByReduction() then
		self.accumulatedProgress = self:_getCurrentProgress(nowTime)
	end

	self.homeCarSpeedUpFactor = homeCarSpeedUpFactor
	self.lastRateChangeTime = nowTime
	self.endTime = self:_calcEstimatedEndTime(nowTime)
end

function HomelandHatchInfo:canBeAffectedByEnv()
	if self.status ~= Const.PET_BALL.HATCH_STATUS_START then
		return false
	end

	return true
end

function HomelandHatchInfo:onEnvironmentChanged(nowTime, envFactor)
	if self.status ~= Const.PET_BALL.HATCH_STATUS_START then
		return
	end

	if not self:_isCompletedByReduction() then
		self.accumulatedProgress = self:_getCurrentProgress(nowTime)
	end

	self.currentEnvFactor = envFactor or 0
	self.lastRateChangeTime = nowTime
	self.endTime = self:_calcEstimatedEndTime(nowTime)
end

function HomelandHatchInfo:_isCompletedByReduction()
	if self.totalFixedReduction >= self:getBaseDuration() then
		return true
	end

	if self.totalTimeReductionRate >= 1 then
		return true
	end

	return false
end

function HomelandHatchInfo:_getTargetWorkload()
	if self:_isCompletedByReduction() then
		return 0
	end

	return math.max(1, self:getBaseDuration() - self.totalFixedReduction)
end

function HomelandHatchInfo:_getCurrentWorkRate()
	if self:_isCompletedByReduction() then
		return 1
	end

	local denominator = 1 - self.totalTimeReductionRate

	if denominator <= 0 then
		return 1000000000
	end

	return (1 + self.currentEnvFactor + self.homeCarSpeedUpFactor) / denominator
end

function HomelandHatchInfo:_getCurrentProgress(nowTime)
	if self:_isCompletedByReduction() then
		return math.huge
	end

	local elapsedSeconds = nowTime - self.lastRateChangeTime

	return self.accumulatedProgress + elapsedSeconds * self:_getCurrentWorkRate()
end

function HomelandHatchInfo:_calcEstimatedEndTime(nowTime)
	if self:_isCompletedByReduction() then
		return nowTime
	end

	local currentProgress = self:_getCurrentProgress(nowTime)
	local targetWorkload = self:_getTargetWorkload()

	if targetWorkload <= currentProgress then
		return nowTime
	else
		local remaining = targetWorkload - currentProgress
		local rate = self:_getCurrentWorkRate()

		return nowTime + math.ceil(remaining / rate)
	end
end

function HomelandHatchInfo:getCompletionRatio(nowTime)
	if self:_isCompletedByReduction() then
		return 1
	end

	local progress = self:_getCurrentProgress(nowTime)
	local target = self:_getTargetWorkload()

	return math.min(1, progress / target)
end

function HomelandHatchInfo:onDayUpdate(nowTime)
	self.todayFondleByPlayerCount = {}
	self.todayTotalFondleCount = 0
	self.itemSpeedUpCount = 0

	self:_checkFinishHatch(nowTime)
end

function HomelandHatchInfo:refreshHatchStatus(nowTime)
	return self:_checkFinishHatch(nowTime)
end

function HomelandHatchInfo:getBaseDuration()
	local confData = PetHatchEggData[self.item.id]

	if not confData then
		return self.baseDuration
	end

	local configDuration = math.ceil(60 * confData.times)

	if self.baseDuration == 0 then
		self.baseDuration = configDuration
	end

	return configDuration
end

function HomelandHatchInfo:getEndTime()
	return self.endTime
end

function HomelandHatchInfo:_checkFinishHatch(nowTime)
	if self.status == Const.PET_BALL.HATCH_STATUS_START and nowTime >= self.endTime then
		self.status = Const.PET_BALL.HATCH_STATUS_SUCC

		return true, 0
	end

	if self.status == Const.PET_BALL.HATCH_STATUS_SUCC then
		return true, 0
	end

	return false, self.endTime
end

function HomelandHatchInfo:getClientHatchInfo()
	local item = self.item

	return {
		status = self.status,
		item = {
			genID = item.genID,
			id = item.id,
			count = item.count,
			status = item.status,
			useTimes = item.useTimes,
			extraProp = item.extraProp,
			props = item.props:getRawTable(),
			owner = item.owner
		},
		endTime = self.endTime,
		currentEnvFactor = self.currentEnvFactor,
		homeCarSpeedUpFactor = self.homeCarSpeedUpFactor,
		itemSpeedUpCount = self.itemSpeedUpCount,
		todayTotalFondleCount = self.todayTotalFondleCount,
		accumulatedProgress = self.accumulatedProgress,
		lastRateChangeTime = self.lastRateChangeTime,
		totalTimeReductionRate = self.totalTimeReductionRate,
		totalFixedReduction = self.totalFixedReduction
	}
end

return HomelandHatchInfo
