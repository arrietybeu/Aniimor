-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\PeriodicTriggerNode.lua

local Class = require("Core.Framework.Class")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local PeriodicTriggerNode = Class.LiteClass("PeriodicTriggerNode", FlowNode)

function PeriodicTriggerNode:ctor(nodeId, nodeData, graph)
	PeriodicTriggerNode.super.ctor(self, nodeId, nodeData, graph)
end

function PeriodicTriggerNode:registerPorts()
	self:addFlowInput("Start", function(context, inputPortName)
		self:On_Start_PortCalled(context, inputPortName)
	end)
	self:addFlowInput("Stop", function(context, inputPortName)
		self:On_Stop_PortCalled(context, inputPortName)
	end)

	self.valueOutput_Count = self:addValueOutput("Count", function(context)
		return self:Get_Count_Value(context)
	end)
	self.flowOut_Out = self:addFlowOutput("Out")
	self.flowOut_Trigger = self:addFlowOutput("Trigger")
	self.valueInput_CD = self:addValueInput("CD")
	self.valueInput_AllowRestart = self:addValueInput("AllowRestart")
	self.valueInput_MaxCount = self:addValueInput("MaxCount")
	self.periodicTimer = "periodicTimer" .. self.nodeId
end

function PeriodicTriggerNode:On_Periodic(context)
	local count = self:getContextValue(context, self.valueOutput_Count) or 1
	local maxCount = self:getContextValue(context, self.valueInput_MaxCount) or -1

	if maxCount == -1 or count <= maxCount then
		self.flowOut_Trigger:call(context)

		if count == maxCount then
			context:removeContextTimer(self.periodicTimer)
		end

		count = count + 1

		self:setContextValue(context, self.valueOutput_Count, count)
	else
		context:removeContextTimer(self.periodicTimer)
	end
end

function PeriodicTriggerNode:On_Start_PortCalled(context, inputPortName)
	local allowRestart = self:getContextValue(context, self.valueInput_AllowRestart) or false
	local cd = self:getContextValue(context, self.valueInput_CD)

	if not cd or cd == 0 then
		return
	end

	local count = self:getContextValue(context, self.valueOutput_Count) or 0

	if count == 0 then
		self:setContextValue(context, self.valueOutput_Count, 1)
	end

	if allowRestart then
		context:removeContextTimer(self.periodicTimer)
		self:setContextValue(context, self.valueOutput_Count, 1)
		context:addContextRepeatTimer(self.periodicTimer, cd, self, "On_Periodic")
	else
		local timer = context:getTimer(self.periodicTimer)

		if not timer then
			self:setContextValue(context, self.valueOutput_Count, 1)
			context:addContextRepeatTimer(self.periodicTimer, cd, self, "On_Periodic")
		end
	end

	self.flowOut_Out:call(context)
end

function PeriodicTriggerNode:On_Stop_PortCalled(context, inputPortName)
	context:removeContextTimer(self.periodicTimer)
	self:setContextValue(context, self.valueOutput_Count, 1)
end

function PeriodicTriggerNode:Get_Count_Value(context)
	return self:getContextValue(context, self.valueOutput_Count)
end

return PeriodicTriggerNode
