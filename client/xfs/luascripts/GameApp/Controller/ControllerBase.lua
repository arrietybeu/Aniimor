-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Controller\\ControllerBase.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local logger = LoggerManager.getLogger("ControllerBase")
local ControllerBase = Class.LightClass("ControllerBase")

function ControllerBase:ctor()
	return
end

function ControllerBase:enter()
	return
end

function ControllerBase:dumb(key, ...)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		logger:debug("Unhandled command: ", key, ...)
	end
end

function ControllerBase:onHandleMove(x, y, z)
	return
end

function ControllerBase:onHandleJump(isPress)
	return
end

function ControllerBase:useSkill(skillId, abilityType, hideMsg, extraInfo)
	return
end

function ControllerBase:onHandleDash(isPress)
	return
end

function ControllerBase:onHandleQuickCapture(entId)
	return
end

function ControllerBase:onHandleBossCapture(endId)
	return
end

function ControllerBase:onHandleCrouch(isPress)
	return
end

function ControllerBase:onHandleSwitchCatchMode()
	return
end

function ControllerBase:setCatchModeEnable(enable)
	return
end

function ControllerBase:exit()
	return
end

return ControllerBase
