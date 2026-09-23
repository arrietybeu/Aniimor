-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AICt\\Nodes\\DoPatrolBehavior.lua

local Class = require("Core.Framework.Class")
local CTRNode = require("Common.AICt.CTRNode")
local CTRConst = require("Common.AICt.CTRConst")
local DoPatrolBehavior = Class.LightClass("DoPatrolBehavior", CTRNode)
local logger = require("Core.Log.LoggerManager").getLogger("DoPatrolBehavior")
local AiConst = require("Common.Const.AiConst")
local AIUtils = require("Common.Utils.AIUtils")
local Utils = require("Common.Utils.Utils")
local ResPointUtils = require("Common.Utils.ResPointUtils")
local PlanPool = require("Common.AI.BehaviacAgent.Unit.Plan.PlanPool")

function DoPatrolBehavior:ctor(nodeId, nodeData, graph)
	DoPatrolBehavior.super.ctor(self, nodeId, nodeData, graph)
end

function DoPatrolBehavior:registerPorts()
	self:addFlowInput("flowIn", function(flow)
		self:On_In_PortCalled(flow)
	end)

	self.flowOut = self:addFlowOutput("flowOut")

	local ports = self.nodeData._inputPortValues

	for k, _ in pairs(ports) do
		self[k] = self:addValueInput(k)
	end
end

function DoPatrolBehavior:onCallFlowInternal(flow)
	local cd = self:getInputValue(self.condition, flow) and not self:GetInterruptResult(flow)

	self:checkCondition(cd, flow)

	if not cd then
		return false
	end

	local patrolType = self.nodeData.patrolType
	local entityActorId = flow.context._entActorId
	local ent = pg.getEntityByActorId(entityActorId)
	local patrolId = self:getInputValue(self.patrolId, flow)
	local loopTime = self.loopTime and self:getInputValue(self.loopTime, flow) or 0
	local plan

	if patrolType == AiConst.PatrolType.Normal or patrolType == AiConst.PatrolType.Glide then
		if ent and patrolId > 0 then
			local behavId = flow.context._behaviorId

			plan = PlanPool.getNewPlan(AiConst.ParmonPlanType.PatrolPlan, ent.space.sceneId, patrolId, false, loopTime, behavId, ent.space.id)

			if plan then
				ent:setIgnoreAILod(plan:checkIgnoreAILod(), AiConst.IgnoreAILodReason.Route)
			end
		end
	elseif patrolType == AiConst.PatrolType.Climb then
		if ent then
			local behavId = flow.context._behaviorId
			local climbData, posX, posY, posZ, angleX, angleY, angleZ = AIUtils.getPatrolData(ent, patrolId)

			if climbData then
				plan = PlanPool.getNewPlan(AiConst.ParmonPlanType.ClimbPlan, posX, posY, posZ, angleX, angleY, angleZ, patrolId, climbData, behavId)
			end
		end
	elseif patrolType == AiConst.PatrolType.NPCLead then
		local leadActorId = self:getInputValue(self.leadActorId, flow)

		if leadActorId == 0 then
			leadActorId = Utils.getAuthorityPlayerActorId(ent)
		end

		local leadTargetEnt = pg.getEntityByActorId(leadActorId)

		if ent and patrolId > 0 and leadTargetEnt then
			local behavId = flow.context._behaviorId

			plan = PlanPool.getNewPlan(AiConst.ParmonPlanType.NPCLeadPlan, ent.space.sceneId, patrolId, behavId, leadActorId, ent.space.id)

			if plan then
				ent:setIgnoreAILod(plan:checkIgnoreAILod(), AiConst.IgnoreAILodReason.Route)
			end
		end
	end

	if plan then
		flow.context._plan = plan

		flow.context._plan:initPlan(ent)
		flow:setContinueNode(self)
		self:setEntRouteId(flow, patrolId)
	end

	return false
end

function DoPatrolBehavior:doFlowOut(flow)
	if flow.context._plan ~= nil and flow.context._plan:tryRunPlan() then
		flow:setContinueNode(self)

		return
	end

	self:onDispose(flow)
	DoPatrolBehavior.super.doFlowOut(self, flow)
end

function DoPatrolBehavior:onDispose(flow)
	if flow.context._plan ~= nil then
		PlanPool.returnPlan(flow.context._plan)

		flow.context._plan = nil

		self:setEntRouteId(flow, nil)
	end

	local entityActorId = flow.context._entActorId
	local ent = pg.getEntityByActorId(entityActorId)

	if ent then
		ent:setIgnoreAILod(false, AiConst.IgnoreAILodReason.Route)
	end
end

function DoPatrolBehavior:On_In_PortCalled(flow)
	if self:onCallFlowInternal(flow) == false then
		return
	end

	self:callFlowOut(self.flowOut, flow)
end

function DoPatrolBehavior:GetInterruptResult(flow)
	local interrupt = self:getInputValue(self.interrupt, flow)

	if interrupt then
		flow.__flowFinishType = CTRConst.FlowFinishType.Interrupt
	end

	return interrupt
end

function DoPatrolBehavior:setEntRouteId(flow, routeId)
	local entityActorId = flow.context._entActorId
	local ent = pg.getEntityByActorId(entityActorId)

	if ent then
		ent:setRouteId(routeId)
	end
end

return DoPatrolBehavior
