-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\BehaviacAgent\\PetBallAgent.lua

local Class = require("Core.Framework.Class")
local CombatAgent = require("Common.AI.BehaviacAgent.CombatAgent")
local IPuppetStateMachineComponent = require("Common.AI.BehaviacAgent.Unit.IPuppetStateMachineComponent")
local IPuppetCombatComponent = require("Common.AI.BehaviacAgent.Unit.IPuppetCombatComponent")
local PetBallConfigData = require("Data.pet_ball_config_data")
local AiConst = require("Common.Const.AiConst")
local PetBallAgent = Class.Class("PetBallAgent", CombatAgent)
local PetBallAgentUnits = {
	IPuppetStateMachineComponent,
	IPuppetCombatComponent
}

Class.AddComponents(PetBallAgent, PetBallAgentUnits)

function PetBallAgent:ctor()
	CombatAgent.ctor(self)

	self.EAgentType = AiConst.EAgentType.PetBallAgent
end

function PetBallAgent:initBlackBoardProperties()
	PetBallAgent.super.initBlackBoardProperties(self)
	self:setBlackBoardProperty("patrolRange", PetBallConfigData.petBallPatrolRange)
end

return PetBallAgent
