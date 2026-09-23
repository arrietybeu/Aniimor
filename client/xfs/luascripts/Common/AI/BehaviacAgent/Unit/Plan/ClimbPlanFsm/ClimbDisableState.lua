-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\BehaviacAgent\\Unit\\Plan\\ClimbPlanFsm\\ClimbDisableState.lua

local Class = require("Core.Framework.Class")
local State = require("Common.Container.FSM.State")
local AIControllerUtils = require("Common.Utils.AIControllerUtils")
local CLIMB_STATE = require("Common.Const.AiConst").CLIMB_STATE
local TablePool = require("Common.Container.TablePool")
local BehaviorTreePlanUtils = require("Common.Utils.BehaviorTreePlanUtils")
local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local BehaviorPathMapData = require("Common.Data.BehaviacData.Meta.BehaviorPathMapData")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local Vectorpool = require("Common.Container.VectorPool")
local QuaternionPool = require("Common.Container.QuaternionPool")
local ClimbDisableState = Class.LiteClass("ClimbDisableState", State)

function ClimbDisableState:onEnter(controller, oldState)
	ClimbDisableState.super.onEnter(self, controller, oldState)
	controller.climbPlan:breakPlan()
end

return ClimbDisableState
