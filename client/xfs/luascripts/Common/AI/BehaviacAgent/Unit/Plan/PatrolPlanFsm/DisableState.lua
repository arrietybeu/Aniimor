-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\BehaviacAgent\\Unit\\Plan\\PatrolPlanFsm\\DisableState.lua

local Class = require("Core.Framework.Class")
local State = require("Common.Container.FSM.State")
local DisableState = Class.LiteClass("DisableState", State)

function DisableState:onEnter(controller, oldState)
	DisableState.super.onEnter(self, controller, oldState)
	controller.patrolPlan:breakPlan()
end

return DisableState
