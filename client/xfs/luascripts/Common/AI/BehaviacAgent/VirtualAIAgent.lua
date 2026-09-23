-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\BehaviacAgent\\VirtualAIAgent.lua

local Class = require("Core.Framework.Class")
local CombatAgent = require("Common.AI.BehaviacAgent.CombatAgent")
local IPuppetStateMachineComponent = require("Common.AI.BehaviacAgent.Unit.IPuppetStateMachineComponent")
local IPuppetCombatComponent = require("Common.AI.BehaviacAgent.Unit.IPuppetCombatComponent")
local AiConst = require("Common.Const.AiConst")
local VirtualAIAgent = Class.Class("VirtualAIAgent", CombatAgent)
local VirtualAIAgentUnits = {
	IPuppetStateMachineComponent,
	IPuppetCombatComponent
}

function VirtualAIAgent:ctor()
	CombatAgent.ctor(self)

	self.EAgentType = AiConst.EAgentType.VirtualAIAgent
end

Class.AddComponents(VirtualAIAgent, VirtualAIAgentUnits)

return VirtualAIAgent
