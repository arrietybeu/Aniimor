-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Ability\\CombatLogger.lua

local LoggerManager = require("Core.Log.LoggerManager")
local loggerIns = LoggerManager.getLogger("Combat")
local Switch = require("Core.Common.Switch")
local LoggerConst = require("Core.Log.LoggerConst")
local lume = require("Core.Common.lume")
local CombatLogger = {}

function CombatLogger.info(...)
	if Switch.CombatDebug then
		loggerIns:info(...)
	end
end

function CombatLogger.debug(...)
	if Switch.CombatDebug then
		loggerIns:debug(...)
	end
end

function CombatLogger.playerDebug(entity, ...)
	if entity and entity.enableCombatLog then
		local AbilityUtils = require("Common.Utils.AbilityUtils")
		local player = AbilityUtils.getPlayer(entity)

		if player then
			local args = {
				...
			}

			args[1] = args[1] .. " " .. player:repr()

			loggerIns:info(unpack(args))

			return
		end
	end

	if Switch.CombatDebug then
		loggerIns:debug(...)
	end
end

function CombatLogger.playerDebugEp(entity, ...)
	if entity and entity.enableCombatLog then
		local AbilityUtils = require("Common.Utils.AbilityUtils")
		local player = AbilityUtils.getPlayer(entity)

		if player then
			local args = {
				...
			}

			args[1] = args[1] .. " " .. player:repr()

			loggerIns:info(unpack(args))

			return
		end
	end

	if Switch.EPDebug then
		loggerIns:debug(...)
	end
end

function CombatLogger.error(...)
	if LoggerManager.checkLogger(LoggerConst.WARN) then
		if Switch.CombatDebug then
			loggerIns:error(...)

			return
		end

		loggerIns:warn(...)
	end
end

function CombatLogger.warn(...)
	if Switch.CombatDebug then
		loggerIns:warn(...)
	end
end

function CombatLogger.logException(...)
	loggerIns:error(...)
end

return CombatLogger
