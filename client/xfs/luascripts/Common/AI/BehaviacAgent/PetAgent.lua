-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\BehaviacAgent\\PetAgent.lua

local Class = require("Core.Framework.Class")
local CombatAgent = require("Common.AI.BehaviacAgent.CombatAgent")
local IPetCombatComponent = require("Common.AI.BehaviacAgent.Unit.IPetCombatComponent")
local IPetStateMachineComponent = require("Common.AI.BehaviacAgent.Unit.IPetStateMachineComponent")
local IPetMoveComponent = require("Common.AI.BehaviacAgent.Unit.IPetMoveComponent")
local IPetAnimationComponent = require("Common.AI.BehaviacAgent.Unit.IPetAnimationComponent")
local sysConfigData = require("Data.sys_config_data")
local BehaviorPathMapData = require("Common.Data.BehaviacData.Meta.BehaviorPathMapData")
local AiConst = require("Common.Const.AiConst")
local PetAgent = Class.Class("PetAgent", CombatAgent)
local PetAgentUnits = {
	IPetCombatComponent,
	IPetStateMachineComponent,
	IPetMoveComponent,
	IPetAnimationComponent
}

Class.AddComponents(PetAgent, PetAgentUnits)

function PetAgent:ctor()
	CombatAgent.ctor(self)

	self.EAgentType = AiConst.EAgentType.PetAgent
end

function PetAgent:initBlackBoardProperties()
	PetAgent.super.initBlackBoardProperties(self)

	local masterId = self.ent.masterActorId or pg.me.actorId

	self:setBlackBoardProperty("masterId", masterId)
	self:setBlackBoardProperty("guideTargetActorId", 0)

	local pdd = self.ent:getConfigData()
	local Param_ST_Pet_AutoCombat = pdd.Param_ST_Pet_AutoCombat

	if Param_ST_Pet_AutoCombat then
		self:setBlackBoardProperty("Param_ST_AutoCombat", Param_ST_Pet_AutoCombat)
	end

	self:setBlackBoardProperty("Param_ST_Idle", pdd.Param_ST_Idle or BehaviorPathMapData.EnumMap[BehaviorPathMapData.EnumNameMap.PBT_Noop])
	self:setBlackBoardProperty("isEnterCombatByInvadeMode", false)
	self:setBlackBoardProperty("afkFov", pdd.afkFov or sysConfigData.defaultAfkFov)
	self:setBlackBoardProperty("afkAnimLoopCount", pdd.afkAnimLoopCount or 2)
end

return PetAgent
