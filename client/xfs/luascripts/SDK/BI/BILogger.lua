-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\BI\\BILogger.lua

local class = require("Core.Framework.Class")
local LoggerManager = require("Core.Log.LoggerManager")
local normalLogger = LoggerManager.getLogger("BILogger")
local Switch = require("Core.Common.Switch")
local BILogger = class.OldLightClass("BILogger", nil, true)

function BILogger:ctor()
	return
end

function BILogger:customeLog(logName, detail, eventType)
	pg.global.sdkManager:tracking(logName, eventType or 1, detail)

	if Switch.BI_LOG then
		normalLogger:info("[BI]\t[CUSTOM] [%s] [%s]", logName, inspect(detail))
	end
end

return BILogger
