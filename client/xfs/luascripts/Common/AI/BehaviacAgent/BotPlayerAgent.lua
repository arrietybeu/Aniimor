-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\BehaviacAgent\\BotPlayerAgent.lua

local class = require("Core.Framework.Class")
local CombatAgent = require("Common.AI.BehaviacAgent.CombatAgent")
local IBotPlayerCombatComponent = require("Common.AI.BehaviacAgent.Unit.IBotPlayerCombatComponent")
local BehaviorPathMapData = require("Common.Data.BehaviacData.Meta.BehaviorPathMapData")
local IBotPlayerStateMachineComponent = require("Common.AI.BehaviacAgent.Unit.IBotPlayerStateMachineComponent")
local AiConst = require("Common.Const.AiConst")
local BotPlayerAgent = class.Class("BotPlayerAgent", CombatAgent)
local BotPlayerAgentUnits = {
	IBotPlayerStateMachineComponent,
	IBotPlayerCombatComponent
}

class.AddComponents(BotPlayerAgent, BotPlayerAgentUnits)

function BotPlayerAgent:ctor(entity)
	CombatAgent.ctor(self, entity)

	self.EAgentType = AiConst.EAgentType.BotPlayerAgent
end

function BotPlayerAgent:initBlackBoardProperties()
	CombatAgent.initBlackBoardProperties(self)

	local pdd = self.ent:getConfigData()

	self:setBlackBoardProperty("Param_ST_Idle", pdd.Param_ST_Player_Idle or BehaviorPathMapData.EnumMap[BehaviorPathMapData.EnumNameMap.PBT_Behav_Com_IdlePatrol])
	self:setBlackBoardProperty("Param_ST_AutoCombat", pdd.Param_ST_Player_AutoCombat or BehaviorPathMapData.EnumMap[BehaviorPathMapData.EnumNameMap.PBT_Noop])
	self:setBlackBoardProperty("combatTactic", AiConst.BotPlayerDefaultCombatTactic)
end

return BotPlayerAgent
