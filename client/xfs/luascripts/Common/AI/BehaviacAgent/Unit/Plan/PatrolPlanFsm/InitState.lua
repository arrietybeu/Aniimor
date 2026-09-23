-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\BehaviacAgent\\Unit\\Plan\\PatrolPlanFsm\\InitState.lua

local Class = require("Core.Framework.Class")
local State = require("Common.Container.FSM.State")
local InitState = Class.LiteClass("InitState", State)

function InitState:onEnter(controller, oldState)
	InitState.super.onEnter(self, controller, oldState)
	controller.patrolPlan:resetPlan()
end

return InitState
