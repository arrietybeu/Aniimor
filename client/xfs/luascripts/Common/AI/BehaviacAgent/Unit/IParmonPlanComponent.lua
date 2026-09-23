-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\BehaviacAgent\\Unit\\IParmonPlanComponent.lua

local class = require("Core.Framework.Class")
local AIControllerUtils = require("Common.Utils.AIControllerUtils")
local enums = require("Common.AI.Behaviac.Enums")
local CTRPool = require("Common.AICt.CTRPool")
local EBTStatus = enums.EBTStatus
local ipairs = ipairs
local IParmonPlanComponent = class.Component("IParmonPlanComponent")

function IParmonPlanComponent:getParmonPlanSubtreePath()
	local curParmonPlan = self.ent:getCurrentAIParmonPlan()

	if not curParmonPlan then
		return false
	end

	return self:getBehaviorStateName()
end

function IParmonPlanComponent:tryRunParmonPlan()
	local curParmonPlan = self.ent:getCurrentAIParmonPlan()

	if not curParmonPlan then
		return false
	end

	return curParmonPlan:tryRunPlan()
end

function IParmonPlanComponent:breakParmonPlan(parmonPlanId)
	local curParmonPlan = self.ent:getCurrentAIParmonPlan()
	local curParmonPlanId = self:getParmonPlanID()

	if curParmonPlan and curParmonPlanId == parmonPlanId then
		curParmonPlan:breakPlan()

		return EBTStatus.BT_SUCCESS
	end

	return EBTStatus.BT_FAILURE
end

function IParmonPlanComponent:checkHasParmonPlan()
	return self.ent:getCurrentAIParmonPlan() ~= nil
end

function IParmonPlanComponent:checkAbortParmonPlan()
	local curParmonPlan = self.ent:getCurrentAIParmonPlan()

	if not curParmonPlan then
		return true
	end

	return curParmonPlan:checkAbortPlan()
end

function IParmonPlanComponent:getParmonPlanTgtId()
	local curParmonPlan = self.ent:getCurrentAIParmonPlan()
	local targetEntity = curParmonPlan and curParmonPlan:getTargetEntity()

	return targetEntity and targetEntity.actorId or 0
end

function IParmonPlanComponent:getParmonPlanID()
	local curParmonPlan = self.ent:getCurrentAIParmonPlan()

	return curParmonPlan and curParmonPlan:getID() or ""
end

function IParmonPlanComponent:doSendMessage(targetActorId, targetActorIdList, triggerName)
	local ent = pg.getEntityByActorId(targetActorId)

	if ent then
		local context = CTRPool.getContext()

		context.sourceActorId = self.ent.actorId

		AIControllerUtils.sendAIEvent(ent, triggerName, context)
	end

	if targetActorIdList ~= nil then
		for _, id in ipairs(targetActorIdList) do
			ent = pg.getEntityByActorId(id)

			if ent then
				local context = CTRPool.getContext()

				context.sourceActorId = self.ent.actorId

				AIControllerUtils.sendAIEvent(ent, triggerName, context)
			end
		end
	end

	return EBTStatus.BT_SUCCESS
end

return IParmonPlanComponent
