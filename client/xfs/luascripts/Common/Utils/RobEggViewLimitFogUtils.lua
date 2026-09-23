-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Utils\\RobEggViewLimitFogUtils.lua

local DigongLightData = require("Data.digong_light_data")
local Const = require("Common.Const.Const")
local RobEggViewLimitFogUtils = {}
local HARD_LV = Const.DungeonDifficultLevel
local PARAM_KEYS = {
	[false] = {
		nearFog = "ViewLimitNearFog",
		pepsiPos = "pepsiPos",
		fogFadePower = "fogFadePower",
		color = "RGB",
		farFog = "ViewLimitFarFog"
	},
	[true] = {
		nearFog = "AfterViewLimitNearFog",
		pepsiPos = "pepsiPosAfter",
		fogFadePower = "fogFadePowerAfter",
		color = "RGBafter",
		farFog = "AfterViewLimitFarFog"
	}
}

function RobEggViewLimitFogUtils.getConfigByHardLv(hardLv)
	if not hardLv or hardLv <= HARD_LV.NORMAL then
		return DigongLightData.Normal
	elseif hardLv == HARD_LV.HARD then
		return DigongLightData.Hard
	elseif hardLv == HARD_LV.CHAOS then
		return DigongLightData.Chaos
	end

	return DigongLightData.Nightmare
end

function RobEggViewLimitFogUtils.getParams(hardLv, useAfter)
	local config = RobEggViewLimitFogUtils.getConfigByHardLv(hardLv)
	local keys = PARAM_KEYS[useAfter == true]

	if not config or not keys then
		return
	end

	local params = {
		nearFog = config[keys.nearFog],
		farFog = config[keys.farFog],
		color = config[keys.color],
		fogFadePower = config[keys.fogFadePower],
		pepsiPos = config[keys.pepsiPos]
	}

	if not params.nearFog or not params.farFog or not params.color or #params.color < 3 or not params.fogFadePower or not params.pepsiPos then
		return
	end

	return params
end

return RobEggViewLimitFogUtils
