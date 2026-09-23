-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\Behaviac\\Fsm\\WaitTransition.lua

local enums = require("Common.AI.Behaviac.Enums")
local common = require("Common.AI.Behaviac.Common")
local macros = require("Common.AI.Behaviac.Macros")
local functions = require("Common.AI.Behaviac.Functions")
local EBTStatus = enums.EBTStatus
local ENodePhase = enums.ENodePhase
local ETransitionPhase = enums.ETransitionPhase
local Transition = require("Common.AI.Behaviac.Fsm.Transition")
local WaitTransition = functions.class("WaitTransition", Transition)
local _M = WaitTransition

function _M:evaluateWithStatus(agent, tick, status)
	return true
end

return _M
