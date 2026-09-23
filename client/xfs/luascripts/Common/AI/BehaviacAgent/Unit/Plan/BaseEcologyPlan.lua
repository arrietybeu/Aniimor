-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\BehaviacAgent\\Unit\\Plan\\BaseEcologyPlan.lua

local class = require("Core.Framework.Class")
local AiConst = require("Common.Const.AiConst")
local BaseEcologyPlan = class.LightClass("BaseEcologyPlan")
local AIUtils = require("Common.Utils.AIUtils")
local CTRConst = require("Common.AICt.CTRConst")

function BaseEcologyPlan:ctor()
	return
end

function BaseEcologyPlan:getPriority()
	return AiConst.DEFAULT_PLAN_MIN_PRIORITY
end

function BaseEcologyPlan:initPlan(entity)
	return true
end

function BaseEcologyPlan:tryRunPlan()
	return false
end

function BaseEcologyPlan:getInterruptType()
	return AiConst.AIBeInterruptedType.CanInterruptedByHighPriority
end

function BaseEcologyPlan:breakPlan()
	return
end

function BaseEcologyPlan:destroy()
	return
end

function BaseEcologyPlan:getID()
	return ""
end

function BaseEcologyPlan:checkAbortPlan()
	return false
end

function BaseEcologyPlan:checkCanBreakByNewPlan(plan)
	return AIUtils.checkAIPlanCanBreakByPriority(self, plan:getPriority(), plan:getID())
end

function BaseEcologyPlan:checkIgnoreAILod()
	return false
end

function BaseEcologyPlan:getTargetEntity()
	return nil
end

function BaseEcologyPlan:setTargetEntity(entity)
	return
end

function BaseEcologyPlan:getPlanType()
	return AiConst.ParmonPlanType.None
end

function BaseEcologyPlan:getPlanTagList()
	return
end

function BaseEcologyPlan:checkPlanBehavTag(tagName)
	local tagList = self:getPlanTagList()

	if tagList then
		for _, tag in ipairs(tagList) do
			if tag == tagName then
				return true
			end
		end
	end

	return false
end

function BaseEcologyPlan:tickCheckPlanInterrupt()
	return false
end

function BaseEcologyPlan:isSamePlan(targetPlan)
	return self:getPlanType() == targetPlan:getPlanType() and self:getID() == targetPlan:getID()
end

function BaseEcologyPlan:getPlanCD()
	return
end

function BaseEcologyPlan:isGroupBehav()
	return false
end

function BaseEcologyPlan:getFlowFinishType()
	return CTRConst.FlowFinishType.Finish
end

function BaseEcologyPlan:recycleInit()
	return true
end

return BaseEcologyPlan
