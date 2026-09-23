-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Utils\\ReplayUtils.lua

local LoggerConst = require("Core.Log.LoggerConst")
local ReplayUtils = {}
local LoggerManager = require("Core.Log.LoggerManager")
local logger = LoggerManager.getLogger("ReplayUtils")
local Version = require("Common.GameVersion")

function ReplayUtils.ParamsConvert(...)
	local paramsCount = select("#", ...)
	local params = {}

	for i = 1, paramsCount do
		params[i] = select(i, ...)

		if params[i] == nil and LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("replay参数不能为nil")
		end
	end

	return params
end

function ReplayUtils.checkVersion(version)
	return Version == version
end

return ReplayUtils
