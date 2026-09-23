-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\PlayerActivityFishingCapture.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local GameEventData = require("Data.game_event_data")
local PlayerActivityFishingCapture = class.LiteClass("PlayerActivityFishingCapture", CustomDict)

function PlayerActivityFishingCapture:getRewardStatistics()
	return self.rewardStatistics or {}
end

function PlayerActivityFishingCapture:getCurPhase()
	if not self.activityBase then
		return 0
	end

	local activityCfg = GameEventData[self.activityBase.activityId]

	return activityCfg and activityCfg.phase or 0
end

function PlayerActivityFishingCapture:hasReceivedIrisReward()
	return self.irisRewardReceived
end

function PlayerActivityFishingCapture:setReceivedIrisReward(received)
	self.irisRewardReceived = received

	return true
end

function PlayerActivityFishingCapture:getTotalIrisNum()
	return self.totalIrisNum
end

return PlayerActivityFishingCapture
