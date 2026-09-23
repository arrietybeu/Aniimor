-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Container\\FSM\\State.lua

local Class = require("Core.Framework.Class")
local State = Class.LiteClass("State")

function State:ctor(stateEnum)
	self._stateEnum = stateEnum
end

function State:onEnter(controller, oldState)
	return
end

function State:onRun(controller)
	return
end

function State:onExit(controller, nextState)
	return
end

function State:getStateName()
	return self._stateEnum
end

return State
