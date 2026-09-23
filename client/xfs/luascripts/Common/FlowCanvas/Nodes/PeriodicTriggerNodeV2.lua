-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\PeriodicTriggerNodeV2.lua

local Class = require("Core.Framework.Class")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local PeriodicTriggerNodeV2 = Class.LiteClass("PeriodicTriggerNode", FlowNode)

function PeriodicTriggerNodeV2:ctor(nodeId, nodeData, graph)
	PeriodicTriggerNodeV2.super.ctor(self, nodeId, nodeData, graph)
end

function PeriodicTriggerNodeV2:registerPorts()
	self:addFlowInput("In", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)
	self:addFlowInput("Cancel", function(context, inputPortName)
		self:On_Cancel_PortCalled(context, inputPortName)
	end)

	self.flowOut_Out = self:addFlowOutput("Out")

	local count = self.nodeData.count or 1

	for i = 1, count do
		self["flowOut_" .. i] = self:addFlowOutput(tostring(i))
	end

	self.valueInput_CD = self:addValueInput("CD")
	self.valueInput_AllowRestart = self:addValueInput("AllowRestart")
	self.periodicTimer = "periodicTimer" .. self.nodeId
	self.curPeriodicIndex = "curPeriodicIndex" .. self.nodeId
end

function PeriodicTriggerNodeV2:On_Periodic(context)
	local curPeriodicIndex = context:getContextValue(self.curPeriodicIndex) or 1
	local maxCount = self.nodeData.count or 1

	if curPeriodicIndex <= maxCount then
		if self["flowOut_" .. curPeriodicIndex] then
			self["flowOut_" .. curPeriodicIndex]:call(context)
		end

		curPeriodicIndex = curPeriodicIndex == maxCount and 1 or curPeriodicIndex + 1

		context:setContextValue(self.curPeriodicIndex, curPeriodicIndex)
	end
end

function PeriodicTriggerNodeV2:On_In_PortCalled(context, inputPortName)
	local allowRestart = self:getContextValue(context, self.valueInput_AllowRestart) or false
	local cd = self:getContextValue(context, self.valueInput_CD)

	if not cd or cd == 0 then
		return
	end

	if allowRestart then
		context:removeContextTimer(self.periodicTimer)
		context:setContextValue(self.curPeriodicIndex, 1)
		context:addContextRepeatTimer(self.periodicTimer, cd, self, "On_Periodic")
	else
		local timer = context:getTimer(self.periodicTimer)

		if not timer then
			context:setContextValue(self.curPeriodicIndex, 1)
			context:addContextRepeatTimer(self.periodicTimer, cd, self, "On_Periodic")
		end
	end

	self.flowOut_Out:call(context)
end

function PeriodicTriggerNodeV2:On_Cancel_PortCalled(context, inputPortName)
	context:removeContextTimer(self.periodicTimer)
	context:setContextValue(self.curPeriodicIndex, 0)
end

return PeriodicTriggerNodeV2
