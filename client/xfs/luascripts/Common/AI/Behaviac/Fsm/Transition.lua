-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\Behaviac\\Fsm\\Transition.lua

local enums = require("Common.AI.Behaviac.Enums")
local common = require("Common.AI.Behaviac.Common")
local macros = require("Common.AI.Behaviac.Macros")
local functions = require("Common.AI.Behaviac.Functions")
local EBTStatus = enums.EBTStatus
local ENodePhase = enums.ENodePhase
local ETransitionPhase = enums.ETransitionPhase
local StartCondition = require("Common.AI.Behaviac.Fsm.StartCondition")
local Transition = functions.class("transition", StartCondition)
local _M = Transition

function _M:isGlobalTransition()
	return true
end

return _M
