-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\BehaviacAgent\\Unit\\Plan\\NPCLeadPatrolPlan.lua

local class = require("Core.Framework.Class")
local NPCLeadPatrolPlanFsm = require("Common.AI.BehaviacAgent.Unit.Plan.NPCLeadPatrolPlanFsm.NPCLeadPatrolPlanFsm")
local PatrolPlan = require("Common.AI.BehaviacAgent.Unit.Plan.PatrolPlan")
local PATROL_STATE = require("Common.Const.AiConst").PATROL_STATE
local NPCLeadPatrolPlan = class.LightClass("NPCLeadPatrolPlan", PatrolPlan)

function NPCLeadPatrolPlan:recycleInit(sceneId, routeId, behaviorId, leadTargetActorId, spaceId)
	PatrolPlan.recycleInit(self, sceneId, routeId, false, 1, behaviorId, spaceId)

	self.leadTargetActorId = leadTargetActorId

	return true
end

function NPCLeadPatrolPlan:initPlan(entity)
	PatrolPlan.super.initPlan(self, entity)

	if not self.PatrolPlanFsm then
		self.PatrolPlanFsm = NPCLeadPatrolPlanFsm.new(self)
	end

	self:registerEntity(entity)
	self.PatrolPlanFsm:start(PATROL_STATE.Init)
	self.PatrolPlanFsm:transitionTo(PATROL_STATE.Patrol)

	return true
end

return NPCLeadPatrolPlan
