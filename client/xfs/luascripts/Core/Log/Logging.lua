-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Log\\Logging.lua

local phonestcore = require("phonestcore")
local Switch = require("Core.Common.Switch")
local type, table, string, _tostring, tonumber = type, table, string, tostring, tonumber
local error = error
local format = string.format
local pairs = pairs
local ipairs = ipairs
local LoggerConst = require("Core.Log.LoggerConst")
local luaUtil

if UNITY_EDITOR then
	luaUtil = CS.FunPlus.WorldX.Utils.LuaUtils
end

local logging = {}

local function LOG_MSG(self, level, ...)
	if not LoggerConst.ENABLE or level < LoggerConst.CURRENT_LEVEL then
		return
	end

	local extra

	if Switch.OpenErrorTraceback and level == LoggerConst.ERROR and os.getenv("DEPLOY") ~= "kube" then
		extra = debug.traceback(LoggerConst.TRACEBACK_PREFIX, self.stackLen)
		extra = "\nlog_error_stack" .. string.sub(extra, 18)
	else
		local info = debug.getinfo(self.stackLen)
		local functionName = info and info.name or ""

		extra = string.format("[%s]     %s:%s", functionName, info.short_src, info.currentline)
	end

	return self:append(level, extra, ...)
end

local function disable_level()
	return
end

local function assert(exp, ...)
	if exp then
		return exp, ...
	end

	error(format(...), 2)
end

local logger_mt = {}

function logger_mt:debug(...)
	return LOG_MSG(self, LoggerConst.DEBUG, ...)
end

function logger_mt:info(...)
	return LOG_MSG(self, LoggerConst.INFO, ...)
end

function logger_mt:warn(...)
	return LOG_MSG(self, LoggerConst.WARN, ...)
end

function logger_mt:error(...)
	return LOG_MSG(self, LoggerConst.ERROR, ...)
end

function logger_mt:log(level, ...)
	if level < LoggerConst.CURRENT_LEVEL then
		return
	end

	return LOG_MSG(self, level, ...)
end

function logger_mt:allow(tag)
	return luaUtil and luaUtil.AllowTag(tag)
end

function logger_mt:log2Tag(tag, ...)
	if luaUtil and luaUtil.AllowTag(tag) then
		self:debug(...)
	end
end

function logging.new(append)
	if type(append) ~= "function" then
		return nil, "Appender must be a function."
	end

	local stackLen = 3
	local delta = jit and 1 or 0
	local logger = {}

	logger.append = append
	logger.stackLen = stackLen - delta

	setmetatable(logger, {
		__index = logger_mt
	})

	logger.concat = {}
	logger.concat[1] = "["
	logger.concat[3] = "]\t"
	logger.concat[5] = "\t"
	logger.concat[6] = "["
	logger.concat[8] = "]"

	return logger
end

function logging:prepareLogMsgForHook(name, extra, ...)
	local cons = self.concat

	cons[2] = name
	cons[4] = phonestcore.logFormat(...)

	if extra then
		cons[7] = extra
	end

	local ret = table.concat(cons, "")

	cons[2] = nil
	cons[4] = nil
	cons[7] = nil

	return ret
end

local function tostring(value)
	local str = ""

	if type(value) ~= "table" then
		if type(value) == "string" then
			str = string.format("%q", value)
		else
			str = _tostring(value)
		end
	else
		local auxTable = {}

		for key in pairs(value) do
			if tonumber(key) ~= key then
				table.insert(auxTable, key)
			else
				table.insert(auxTable, tostring(key))
			end
		end

		table.sort(auxTable)

		str = str .. "{"

		local separator = ""
		local entry = ""

		for _, fieldName in ipairs(auxTable) do
			if tonumber(fieldName) and tonumber(fieldName) > 0 then
				entry = tostring(value[tonumber(fieldName)])
			else
				entry = fieldName .. " = " .. tostring(value[fieldName])
			end

			str = str .. separator .. entry
			separator = ", "
		end

		str = str .. "}"
	end

	return str
end

logging.tostring = tostring

function logging.console(logPattern)
	return
end

return logging
