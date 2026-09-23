-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AICt\\Nodes\\DoAction.lua

local CTRNode = require("Common.AICt.CTRNode")
local Class = require("Core.Framework.Class")
local DoAction = Class.LightClass("DoAction", CTRNode)
local logger = require("Core.Log.LoggerManager").getLogger("DoAction")
local CTRConst = require("Common.AICt.CTRConst")
local ConditionUtils = require("Common.AICt.ConditionUtils")
local TablePool = require("Common.Container.TablePool")

function DoAction:ctor(nodeId, nodeData, graph)
	CTRNode.ctor(self, nodeId, nodeData, graph)
end

function DoAction:registerPorts()
	self:addFlowInput("flowIn", function(flow)
		self:On_In_PortCalled(flow)
	end)

	self.flowOut = self:addFlowOutput("flowOut")

	local ports = self.nodeData._inputPortValues

	for k, _ in pairs(ports) do
		self[k] = self:addValueInput(k)
	end
end

function DoAction:On_In_PortCalled(flow)
	if self:onCallFlowInternal(flow) == false then
		return
	end

	self:callFlowOut(self.flowOut, flow)
end

function DoAction:onCallFlowInternal(flow)
	local cd = self:getInputValue(self.condition, flow)

	self:checkCondition(cd, flow)

	if not cd then
		return false
	end

	local eName = self:getEventName()
	local context = TablePool.getTable(3)

	self:getContext(context, flow)
	ConditionUtils.DoEventFuc(eName, context)
	TablePool.returnTable(context, 3)
end

function DoAction:getEventName()
	return self.nodeData.eventName
end

function DoAction:getContext(context, flow)
	context._entActorId = flow.context._entActorId
	context._behaviorId = flow.context._behaviorId

	for k, _ in pairs(self.nodeData._inputPortValues) do
		if k ~= "condition" then
			context[k] = self:getInputValue(self[k], flow)
		end
	end

	if UNITY_EDITOR then
		context._curNodeId = self.nodeId
		context._curNodeActionEventName = self.nodeData.eventName
	end
end

return DoAction
