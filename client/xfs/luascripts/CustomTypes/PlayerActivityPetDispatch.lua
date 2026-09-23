-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\PlayerActivityPetDispatch.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local Time = require("Core.Common.Time")
local TimeUtils = require("Common.Utils.TimeUtils")
local PlayerActivityPetDispatch = class.LiteClass("PlayerActivityPetDispatch", CustomDict)

function PlayerActivityPetDispatch:canTabOpen(startTime, endTime)
	local rewardAllRecvedTm = self.rewardAllRecvedTm

	if rewardAllRecvedTm > 0 and startTime and startTime > 0 and endTime and endTime > 0 and startTime <= rewardAllRecvedTm and rewardAllRecvedTm < endTime then
		local now = Time.secondCache

		if startTime <= now and now < endTime and TimeUtils.getServerDayDiff(rewardAllRecvedTm, now) >= 1 then
			return false
		end
	end

	return true
end

function PlayerActivityPetDispatch:canOpen(startTime, endTime)
	local rewardAllRecvedTm = self.rewardAllRecvedTm

	if rewardAllRecvedTm > 0 and startTime and startTime > 0 and endTime and endTime > 0 and startTime <= rewardAllRecvedTm and rewardAllRecvedTm < endTime then
		local now = Time.secondCache

		if startTime <= now and now < endTime and TimeUtils.getServerDayDiff(rewardAllRecvedTm, now) >= 1 then
			return false
		end
	end

	return true
end

return PlayerActivityPetDispatch
