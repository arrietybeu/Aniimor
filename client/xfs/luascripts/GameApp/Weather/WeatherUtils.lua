-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Weather\\WeatherUtils.lua

local Class = require("Core.Framework.Class")
local UIConst = require("Const.UIConst")
local WeatherUtils = {}

function WeatherUtils:getWeatherStateName(weatherId)
	for key, value in pairs(UIConst.WeatherState) do
		if value == weatherId then
			return key
		end
	end

	return nil
end

return WeatherUtils
