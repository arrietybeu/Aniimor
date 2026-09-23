-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AICt\\Nodes\\WaitExecute.lua

local CTRNode = require("Common.AICt.CTRNode")
local Class = require("Core.Framework.Class")
local WaitExecute = Class.LightClass("WaitExecute", CTRNode)
local CallbackHandlerNoGC = require("Core.Common.CallbackHandlerNoGC")
local TimerManager = require("Core.Timer.TimerManager")

function WaitExecute:ctor(nodeId, nodeData, graph)
	CTRNode.ctor(self, nodeId, nodeData, graph)
end

function WaitExecute:registerPorts()
	self:addFlowInput("flowIn", function(flow)
		self:On_flowIn_PortCalled(flow)
	end)

	self.flowOut_flowOut = self:addFlowOutput("flowOut")
	self.flowOut_waitFlowOut = self:addFlowOutput("waitFlowOut")
	self.valueInput_waitTime = self:addValueInput("waitTime")
end

function WaitExecute:On_flowIn_PortCalled(flow)
	self:callFlowOut(self.flowOut_flowOut, flow)

	local waitTime = self:getInputValue(self.valueInput_waitTime, flow)
	local func = CallbackHandlerNoGC.new(self, "callFlowOut", self.flowOut_waitFlowOut, flow)
	local timerId = TimerManager.addTimer(waitTime, func:getFunction())

	flow:addTimer(timerId, func)
end

return WaitExecute
