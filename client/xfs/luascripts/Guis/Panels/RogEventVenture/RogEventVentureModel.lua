-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\RogEventVenture\\RogEventVentureModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local RogueDiceData = require("Data.rogue_dice_data")
local SysConfigData = require("Data.sys_config_data")
local RogEventVentureModel = Class.LightClass("RogEventVentureModel", UIModel)

function RogEventVentureModel:tryGetDiceSchemeId(machineType)
	local diceStateData = pg.me.rogueDiceStateData[machineType]

	return diceStateData and diceStateData.diceSchemeId
end

function RogEventVentureModel:initVentureData(machineType)
	local diceStateData = pg.me.rogueDiceStateData[machineType]

	if not diceStateData then
		return
	end

	local diceRollData = pg.me.rogueDiceRollData[machineType] or {}
	local diceSchemeId = diceStateData.diceSchemeId
	local diceConfig = RogueDiceData[diceSchemeId]

	if not diceConfig then
		return
	end

	local diceRandomCount = diceStateData.diceRandomCount or 0
	local totalRollPoint = diceStateData.totalRollPoint or 0
	local currentRewardIndex = 0
	local currentPointIndex = 0
	local pointState = {}
	local rewardState = {}
	local rewardCount = #diceConfig
	local pointIndex, diceRollSubData, pointIsPast

	for i = 1, rewardCount do
		local startPoint = diceConfig[i].startPoint
		local endPoint = diceConfig[i].endPoint
		local pointSubState = {}
		local getReward = false

		for j = startPoint, endPoint do
			pointIndex = j - startPoint + 1

			if j == totalRollPoint then
				currentRewardIndex = i
				currentPointIndex = pointIndex
			end

			pointIsPast = diceRollData[i] and diceRollData[i][j]
			pointSubState[pointIndex] = {
				state = pointIsPast ~= nil
			}

			if pointIsPast then
				getReward = true
			end
		end

		pointState[i] = pointSubState
		rewardState[i] = getReward
	end

	return diceSchemeId, diceRandomCount, totalRollPoint, currentRewardIndex, currentPointIndex, pointState, rewardState, rewardCount
end

function RogEventVentureModel:getRewardRenderData(diceSchemeId)
	local diceConfig = RogueDiceData[diceSchemeId]
	local rewardCount = #diceConfig
	local renderData = {}

	for lineIndex = rewardCount, 1, -1 do
		table.insert(renderData, {
			tIndex = lineIndex == rewardCount and 1 or 0,
			dropId = diceConfig[lineIndex].showRewardId,
			isTop = lineIndex == rewardCount,
			isDown = lineIndex == 1
		})
	end

	return renderData
end

function RogEventVentureModel:getCost(diceSchemeId, alreadyRollCount)
	local data = SysConfigData.diceMachineCost[diceSchemeId]

	if not data then
		return 0
	end

	return data[1] + data[2] * alreadyRollCount
end

function RogEventVentureModel:isDiceFinish(machineType)
	local diceStateData = pg.me.rogueDiceStateData[machineType]

	return diceStateData and diceStateData.isDiceFinish
end

function RogEventVentureModel:isRewardFinish(machineType)
	local diceStateData = pg.me.rogueDiceStateData[machineType]

	return diceStateData and diceStateData.isReward
end

return RogEventVentureModel
