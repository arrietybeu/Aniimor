-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AICt\\Nodes\\EndTrigger.lua

local CTRNode = require("Common.AICt.CTRNode")
local Class = require("Core.Framework.Class")
local CTRConst = require("Common.AICt.CTRConst")
local EndTrigger = Class.LightClass("EndTrigger", CTRNode)

function EndTrigger:ctor(nodeId, nodeData, graph)
	CTRNode.ctor(self, nodeId, nodeData, graph)
end

function EndTrigger:registerPorts()
	self.flowOut = self:addFlowOutput("flowOut")

	self:addValueOutput("isBreakFinish", function(flow)
		return flow.__flowFinishType == CTRConst.FlowFinishType.Break
	end)
	self:addValueOutput("isInterruptFinish", function(flow)
		return flow.__flowFinishType == CTRConst.FlowFinishType.Interrupt
	end)
end

function EndTrigger:executeTrigger(flow)
	self:callFlowOut(self.flowOut, flow)
end

return EndTrigger
