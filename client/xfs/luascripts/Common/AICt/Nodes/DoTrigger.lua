-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AICt\\Nodes\\DoTrigger.lua

local CTRNode = require("Common.AICt.CTRNode")
local Class = require("Core.Framework.Class")
local DoTrigger = Class.LightClass("DoTrigger", CTRNode)
local CTRConst = require("Common.AICt.CTRConst")
local logger = require("Core.Log.LoggerManager").getLogger("DoTrigger")
local ConditionUtils = require("Common.AICt.ConditionUtils")
local TablePool = require("Common.Container.TablePool")

function DoTrigger:ctor(nodeId, nodeData, graph)
	CTRNode.ctor(self, nodeId, nodeData, graph)
end

function DoTrigger:registerPorts()
	self:addFlowInput("flowIn", function(flow)
		self:On_In_PortCalled(flow)
	end)

	self.flowOut = self:addFlowOutput("flowOut")

	local ports = self.nodeData._inputPortValues

	for k, _ in pairs(ports) do
		self[k] = self:addValueInput(k)
	end
end

function DoTrigger:On_In_PortCalled(flow)
	if self:onCallFlowInternal(flow) == false then
		return
	end

	self:callFlowOut(self.flowOut, flow)
end

function DoTrigger:onCallFlowInternal(flow)
	local cd = self:getInputValue(self.condition, flow)

	self:checkCondition(cd, flow)

	if not cd then
		return false
	end

	local targetActorId
	local context = TablePool.getTable()

	for k, _ in pairs(self.nodeData._inputPortValues) do
		if k == "target" then
			targetActorId = self:getInputValue(self[k], flow)
		elseif k ~= "condition" then
			context[k] = self:getInputValue(self[k], flow)
		end
	end

	ConditionUtils.DoTrigger(targetActorId, self.nodeData.triggerName, context)
	TablePool.returnTable(context)
end

return DoTrigger
