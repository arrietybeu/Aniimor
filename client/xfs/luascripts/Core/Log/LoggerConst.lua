-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Log\\LoggerConst.lua

local phonestcore = require("phonestcore")
local LoggerConst = {
	ENABLE = true,
	TRACEBACK_PREFIX = " ",
	DEBUG = phonestcore.SPDLOG_LEVEL_DEBUG,
	INFO = phonestcore.SPDLOG_LEVEL_INFO,
	WARN = phonestcore.SPDLOG_LEVEL_WARN,
	ERROR = phonestcore.SPDLOG_LEVEL_ERROR,
	CURRENT_LEVEL = phonestcore.SPDLOG_LEVEL_DEBUG
}

return LoggerConst
