-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\BehaviacAgent\\Unit\\Plan\\PlanPool.lua

local AiConst = require("Common.Const.AiConst")
local PlanPool = {}
local availablePlans = {
	[AiConst.ParmonPlanType.EventPlan] = {},
	[AiConst.ParmonPlanType.PatrolPlan] = {},
	[AiConst.ParmonPlanType.ClimbPlan] = {},
	[AiConst.ParmonPlanType.NPCLeadPlan] = {}
}
local planNewFuncs = {
	[AiConst.ParmonPlanType.EventPlan] = function(...)
		return require("Common.AI.BehaviacAgent.Unit.Plan.EventPlan").new(...)
	end,
	[AiConst.ParmonPlanType.PatrolPlan] = function(...)
		return require("Common.AI.BehaviacAgent.Unit.Plan.PatrolPlan").new(...)
	end,
	[AiConst.ParmonPlanType.ClimbPlan] = function(...)
		return require("Common.AI.BehaviacAgent.Unit.Plan.ClimbPlan").new(...)
	end,
	[AiConst.ParmonPlanType.NPCLeadPlan] = function(...)
		return require("Common.AI.BehaviacAgent.Unit.Plan.NPCLeadPatrolPlan").new(...)
	end
}

function PlanPool.getNewPlan(type, ...)
	local newPlan

	if not availablePlans[type] or #availablePlans[type] <= 0 then
		newPlan = planNewFuncs[type]()
	else
		newPlan = table.remove(availablePlans[type])
	end

	local initSuccess = newPlan:recycleInit(...)

	if not initSuccess then
		PlanPool.returnPlan(newPlan)

		return
	end

	return newPlan
end

function PlanPool.returnPlan(plan)
	if not plan then
		return
	end

	plan:breakPlan()

	local type = plan:getPlanType()

	if not availablePlans[type] then
		return
	end

	table.insert(availablePlans[type], plan)
end

function PlanPool.clear()
	for _, plans in pairs(availablePlans) do
		table.clear(plans)
	end
end

return PlanPool
