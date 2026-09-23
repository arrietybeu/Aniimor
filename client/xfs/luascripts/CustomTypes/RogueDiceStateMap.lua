-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\RogueDiceStateMap.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local SysConfigData = require("Data.sys_config_data")
local math_random = math.random
local max = math.max
local pairs = pairs
local RogueDiceStateMap = class.LiteClass("RogueDiceStateMap", CustomDict)

function RogueDiceStateMap:isDiceFinish(machineType)
	if not self[machineType] then
		return false
	end

	return self[machineType].isDiceFinish
end

function RogueDiceStateMap:setDiceFinish(machineType)
	if not self[machineType] then
		return false
	end

	self[machineType].isDiceFinish = true

	return true
end

function RogueDiceStateMap:isReward(machineType)
	if not self[machineType] then
		return false
	end

	return self[machineType].isReward
end

function RogueDiceStateMap:setDiceReward(machineType)
	if not self[machineType] then
		return false
	end

	self[machineType].isReward = true

	return true
end

function RogueDiceStateMap:setDiceScheme(machineType, schemeId)
	self[machineType] = self[machineType] or {}
	self[machineType].diceSchemeId = schemeId
end

function RogueDiceStateMap:getSchemeId(machineType)
	if not self[machineType] then
		return 0
	end

	return self[machineType].diceSchemeId
end

function RogueDiceStateMap:getNeedCost(machineType)
	if not self[machineType] then
		return false, 0
	end

	local diceSchemeId = self[machineType].diceSchemeId
	local costData = SysConfigData.diceMachineCost

	if costData == nil or costData[diceSchemeId] == nil or #costData[diceSchemeId] ~= 2 then
		return false, 0
	end

	local needCost = 0

	if self[machineType].diceRandomCount == 0 then
		needCost = costData[diceSchemeId][1]
	else
		needCost = costData[diceSchemeId][1] + self[machineType].diceRandomCount * costData[diceSchemeId][2]
	end

	return true, needCost
end

function RogueDiceStateMap:diceRoll(machineType, maxPoint)
	local rollPoint = math_random(6)

	return self:_diceRoll(machineType, maxPoint, rollPoint)
end

function RogueDiceStateMap:cheatDiceRoll(machineType, maxPoint, cheatRollPoint)
	return self:_diceRoll(machineType, maxPoint, cheatRollPoint)
end

function RogueDiceStateMap:_diceRoll(machineType, maxPoint, curRollPoint)
	local oldPoint = self[machineType].totalRollPoint
	local newTotal = oldPoint + curRollPoint
	local newFixTotal = newTotal

	if maxPoint < newTotal then
		local overflow = newTotal - maxPoint

		newFixTotal = max(0, maxPoint - overflow)
	else
		newFixTotal = newTotal
	end

	return curRollPoint, oldPoint, newFixTotal
end

function RogueDiceStateMap:updateDiceStateAfterRoll(machineType, newRollPoint)
	if not self[machineType] then
		return false
	end

	self[machineType].diceRandomCount = self[machineType].diceRandomCount + 1
	self[machineType].totalRollPoint = newRollPoint

	return true
end

function RogueDiceStateMap:clearStateData()
	for _, stateInfo in pairs(self) do
		stateInfo.diceRandomCount = 0
		stateInfo.totalRollPoint = 0
		stateInfo.isDiceFinish = false
	end
end

return RogueDiceStateMap
