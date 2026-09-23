-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\ConsoleUtils.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local logger = LoggerManager.getLogger("ConsoleUtils")
local ConsoleUtils = Class.LightClass("ConsoleUtils")

function ConsoleUtils.init()
	pg.global.debug_preimport_modules = pg.global.debug_preimport_modules or setmetatable({}, {
		__index = _G
	})
end

function ConsoleUtils.createDebugConsoleClient(str)
	if #str > 1 and string.byte(str, 1, 2) == 61 then
		local printFmt = "print(pg.global.debug_client.inspect(%s, {['depth']=1}))"

		str = string.format(printFmt, string.sub(str, 2))
	end

	if not pg.global.debug_client then
		local locals = {}

		setmetatable(locals, {
			__mode = "kv",
			__index = pg.global.debug_preimport_modules
		})

		pg.global.debug_client = {}
		pg.global.debug_client._local = {
			isInTelnetConsole = true
		}

		table.merge(pg.global.debug_client._local, require("Common.Utils.Utils").getTelnetExtraLocals())
		setmetatable(pg.global.debug_client._local, {
			__mode = "kv",
			__index = locals
		})

		pg.global.debug_client.inspect = require("Core.Common.inspect")

		function pg.global.debug_client.co()
			local output_str
			local oldPrint = _G.print

			local function feedback_print(...)
				output_str = ""

				local len = select("#", ...)

				for i = 1, len do
					local v = select(i, ...)

					if i == len then
						output_str = output_str .. tostring(v)
					else
						output_str = output_str .. tostring(v) .. "\t"
					end
				end

				output_str = string.gsub(output_str, "\n", "\r\n")

				pg.global.socketMgr:SendString(output_str .. "\r\n")

				return output_str
			end

			local function debug_print(...)
				oldPrint(...)

				return feedback_print(...)
			end

			local function error_print(...)
				if LoggerManager.checkLogger(LoggerConst.ERROR) then
					logger:error(...)
				end

				return feedback_print(...)
			end

			local res, msg = loadstring(string.format("                    local pg = require('Pg')\n                    local dm = require(\"Common.DebugManager\")\n                    local em = require(\"Core.Common.EntityManager\")\n\n                    local ActorManager = require(\"Core.Common.ActorManager\")\n                    local ents = ActorManager.entities\n                    setfenv(1, pg.global.debug_client._local)\n                    local temp = %s\n                    if temp ~= nil then\n                        print(pg.global.debug_client.inspect(temp, {['depth']=dm.getDepth(), ['nometa']=dm.getNoMeta()}))\n                    end\n                ", pg.global.debug_client.str))

			if res ~= nil then
				msg = nil

				rawset(_G, "print", debug_print)
				xpcall(res, function(msg, outputStr)
					msg = debug.traceback(msg, 3)
					outputStr = error_print(msg)

					return msg, outputStr
				end)
				rawset(_G, "print", oldPrint)
			else
				local res1

				res1, msg = loadstring(string.format("                        local Pg = require('Pg')\n                        local dm = require(\"Common.DebugManager\")\n                        local em = require(\"Core.Common.EntityManager\")\n                        local ActorManager = require(\"Core.Common.ActorManager\")\n                        local ents = ActorManager.entities\n                        setfenv(1,pg.global.debug_client._local)\n                            %s\n                        local debugId=1\n                        while true do\n                            local name, value = debug.getlocal(1, debugId)\n                            if not name then break end\n                            rawset(pg.global.debug_client._local,name,value)\n                            debugId = debugId + 1\n                        end\n                        ", pg.global.debug_client.str))

				if res1 ~= nil then
					msg = nil

					rawset(_G, "print", debug_print)
					xpcall(res1, function(msg)
						msg = debug.traceback(msg, 3)

						error_print(msg)

						return msg
					end)
					rawset(_G, "print", oldPrint)
				end
			end

			return msg, output_str
		end
	end

	pg.global.debug_client.str = str

	local msg, outputStr = pg.global.debug_client.co()

	if msg then
		pg.global.socketMgr:SendString(msg)
	end

	pg.global.socketMgr:SendString(">")

	return outputStr
end

function ConsoleUtils.onSocketConnected()
	pg.global.debug_client = nil
	pg.debug = pg.debug or {}
	pg.debug.stack = pg.debug.stack or function(val)
		pg.global.socketMgr.stackTrace = (val == nil and {
			not pg.global.socketMgr.stackTrace
		} or {
			val
		})[1]
	end
	pg.debug.log = pg.debug.log or function(val)
		pg.global.socketMgr.logTrace = (val == nil and {
			not pg.global.socketMgr.logTrace
		} or {
			val
		})[1]
	end
	pg.debug.full = pg.debug.full or function(val)
		pg.global.socketMgr:SendFullLog()
	end
	pg.global.socketMgr.stackTrace = false
	pg.global.socketMgr.logTrace = false
end

function ConsoleUtils.onSocketData(msg)
	local outputStr = ConsoleUtils.createDebugConsoleClient(msg)

	return outputStr
end

return ConsoleUtils
