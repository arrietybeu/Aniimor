-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Net\\PhonestEnv.lua

local class = require("Core.Framework.Class")
local globalDeclare = require("Core.Framework.Global")
local CallbackManager = require("Core.Net.CallbackManager")
local HandlerManager = require("Core.Net.HandlerManager")
local CommonRepo = require("Core.Common.CommonRepo")
local PhonestEnv = class.Class("PhonestEnv")

local function ExceptionReport(err)
	CommonRepo.exceptionFunc(err)
end

function PhonestEnv.setDebugMode(debugMode)
	if debugMode then
		globalDeclare("_G_IsDebugMode", true)
	else
		globalDeclare("_G_IsDebugMode", false)
	end
end

function PhonestEnv.init(logLevel, enableTracyAutoInstrument)
	CallbackManager.init()
	HandlerManager.init()
	globalDeclare("tracy")
	globalDeclare("ExceptionReport", ExceptionReport)
	globalDeclare("jit")
	globalDeclare("UNITY_EDITOR")

	local TimerManager = require("Core.Timer.TimerManager")

	TimerManager.init()
	globalDeclare("inspect")

	inspect = require("Core.Common.inspect")

	globalDeclare("pm_lua_script_ptr")
	globalDeclare("bdd2DeepTable")
	globalDeclare("bddunpack")
	globalDeclare("bddnext")
	globalDeclare("stp")
	globalDeclare("BehaviorXUtils")

	BehaviorXUtils = require("Common.Utils.BehaviorXUtils")

	local phonestcore = require("phonestcore")

	if enableTracyAutoInstrument then
		phonestcore.enableTracyAutoInstrument(true)
	end

	PhonestEnv.logLevel = {
		TRACE = phonestcore.SPDLOG_LEVEL_TRACE,
		DEBUG = phonestcore.SPDLOG_LEVEL_DEBUG,
		INFO = phonestcore.SPDLOG_LEVEL_INFO,
		WARN = phonestcore.SPDLOG_LEVEL_WARN,
		ERROR = phonestcore.SPDLOG_LEVEL_ERROR
	}

	local LoggerManager = require("Core.Log.LoggerManager")
	local LoggerConst = require("Core.Log.LoggerConst")
	local logger = LoggerManager.getLogger("PhonestEnv")
	local phonestVersion = require("Core.Common.Version").ver

	if logLevel then
		local loglv = PhonestEnv.logLevel[logLevel]

		if loglv then
			LoggerManager.setLevel(loglv)

			if LoggerManager.checkLogger(LoggerConst.INFO) then
				logger:info("set log level to %s", logLevel)
			end
		else
			LoggerManager.setLevel(phonestcore.SPDLOG_LEVEL_INFO)

			if LoggerManager.checkLogger(LoggerConst.WARN) then
				logger:warn("get unknown logLevel %s, set log level to INFO", logLevel)
			end
		end
	end

	math.randomseed(phonestcore.getNanosecond())
	logger:info("phonest framework start with version %s , phonsetcore with version %s", phonestVersion, phonestcore.version())

	local BatchSync = require("Core.PropertySync.SyncStrategy.BatchSync")

	BatchSync.init()

	local CombineSync = require("Core.PropertySync.SyncStrategy.CombineSync")

	CombineSync.init()

	local FrameSync = require("Core.PropertySync.SyncStrategy.FrameSync")

	FrameSync.init()

	local Class = require("Core.Framework.Class")
	local ClassLogger = LoggerManager.getLogger("Class")

	Class.setLogger(ClassLogger)

	return true
end

return PhonestEnv
