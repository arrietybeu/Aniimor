-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\PlayerActivityBattlePass.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local ActivityConst = require("Common.Const.ActivityConst")
local SysConfigData = require("Data.sys_config_data")
local PlayerActivityBattlePass = class.LiteClass("PlayerActivityBattlePass", CustomDict)

function PlayerActivityBattlePass:getCycleRewardState(bpLevel)
	local freeRewardState = ActivityConst.TaskState.UnFinished
	local advaRewardState = ActivityConst.TaskState.UnFinished
	local bpMaxLevel = math.floor(tonumber(SysConfigData.BATTLE_PASS_LEVEL_UP_MAX) or 70)
	local loopLevelLimit = math.floor(tonumber(SysConfigData.LOOP_LEVEL_LIMITS) or bpMaxLevel)

	loopLevelLimit = math.max(bpMaxLevel, loopLevelLimit)

	if type(bpLevel) ~= "number" or bpLevel < bpMaxLevel or loopLevelLimit < bpLevel then
		return freeRewardState, advaRewardState
	end

	if bpLevel > self.bpLevel then
		return freeRewardState, advaRewardState
	end

	freeRewardState = ActivityConst.TaskState.Finihed_CanRecv
	advaRewardState = ActivityConst.TaskState.Finihed_CanRecv

	if bpLevel <= self.cycleRewardRecvMaxLvFree then
		freeRewardState = ActivityConst.TaskState.Received
	end

	if self.bpGear >= ActivityConst.BattlePassGear.Pay1 then
		advaRewardState = ActivityConst.TaskState.Finihed_CanRecv

		if bpLevel <= self.cycleRewardRecvMaxLvAdvance then
			advaRewardState = ActivityConst.TaskState.Received
		end
	else
		advaRewardState = ActivityConst.TaskState.UnFinished
	end

	return freeRewardState, advaRewardState
end

return PlayerActivityBattlePass
