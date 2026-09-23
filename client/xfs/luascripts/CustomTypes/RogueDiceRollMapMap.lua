-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\RogueDiceRollMapMap.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local RogueDiceData = require("Data.rogue_dice_data")
local lume = require("Core.Common.lume")
local RogueDiceRollMapMap = class.LiteClass("RogueDiceRollMapMap", CustomDict)

function RogueDiceRollMapMap:getMaxPoint(diceRevertConfigData)
	local rangeData = diceRevertConfigData[1]

	if not rangeData then
		return 0
	end

	return rangeData.maxPoint
end

function RogueDiceRollMapMap:updateRollPoint(machineType, rangeId, newRollPoint)
	self[machineType] = self[machineType] or {}
	self[machineType][rangeId] = self[machineType][rangeId] or {}

	if self[machineType][rangeId][newRollPoint] then
		return false
	end

	self[machineType][rangeId][newRollPoint] = true

	return true
end

function RogueDiceRollMapMap:checkRollPointCountInRange(machineType, rangeId)
	if not self[machineType] or not self[machineType][rangeId] then
		return 0
	end

	return lume.count(self[machineType][rangeId])
end

return RogueDiceRollMapMap
