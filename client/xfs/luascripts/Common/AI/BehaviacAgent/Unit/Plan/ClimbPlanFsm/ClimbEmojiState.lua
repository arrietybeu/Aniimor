-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\BehaviacAgent\\Unit\\Plan\\ClimbPlanFsm\\ClimbEmojiState.lua

local Class = require("Core.Framework.Class")
local State = require("Common.Container.FSM.State")
local AIControllerUtils = require("Common.Utils.AIControllerUtils")
local CLIMB_STATE = require("Common.Const.AiConst").CLIMB_STATE
local TablePool = require("Common.Container.TablePool")
local BehaviorTreePlanUtils = require("Common.Utils.BehaviorTreePlanUtils")
local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local BehaviorPathMapData = require("Common.Data.BehaviacData.Meta.BehaviorPathMapData")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local ClimbType = require("Common.Const.AiConst").ClimbType
local ClimbEmojiState = Class.LiteClass("ClimbEmojiState", State)

function ClimbEmojiState:onEnter(controller, oldState)
	ClimbEmojiState.super.onEnter(self, controller, oldState)
	self:__exec(controller)
end

function ClimbEmojiState:onRun(controller)
	ClimbEmojiState.super.onRun(self, controller)
	self:__exec(controller)
end

function ClimbEmojiState:__exec(controller)
	local climbData = controller.climbPlan:getNextPointData(false)

	if climbData.climbType == ClimbType.ClimbEmoji then
		local subtreeParams = TablePool.getTable()

		controller.climbPlan:getNextPointData(true)

		subtreeParams.tEmojiBubbleKey = climbData.emoji
		subtreeParams.tEmojiBubbleTimeout = climbData.time

		BehaviorTreePlanUtils.startEcologyPlanByState(controller.climbPlan.targetEnt.agent, BehaviorPathMapData.EnumNameMap.PBT_ShowEmojiBubble, subtreeParams)
		TablePool.returnTable(subtreeParams)
	else
		controller:autoTransitClimbPlan()
	end
end

return ClimbEmojiState
