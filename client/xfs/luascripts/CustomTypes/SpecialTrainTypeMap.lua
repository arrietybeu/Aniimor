-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\SpecialTrainTypeMap.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local SpecialTrainTypeMap = class.LiteClass("SpecialTrainTypeMap", CustomDict)

function SpecialTrainTypeMap:addCompleteCount(trainType)
	if not self[trainType] then
		self[trainType] = {}
	end

	self[trainType].completeCnt = self[trainType].completeCnt + 1
end

function SpecialTrainTypeMap:getCompleteCount(trainType)
	return self[trainType] and self[trainType].completeCnt or 0
end

function SpecialTrainTypeMap:isRewarded(trainType)
	if not self[trainType] then
		return false
	end

	return self[trainType].isRewarded
end

function SpecialTrainTypeMap:setRewarded(trainType)
	if not self[trainType] then
		self[trainType] = {}
	end

	self[trainType].isRewarded = true
end

function SpecialTrainTypeMap:checkCanReward(trainType, needCompleteCount)
	if not self[trainType] then
		return false
	end

	if self[trainType].isRewarded then
		return false
	end

	return needCompleteCount <= self[trainType].completeCnt
end

return SpecialTrainTypeMap
