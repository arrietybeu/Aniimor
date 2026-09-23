-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AICt\\Nodes\\StartTrigger.lua

local CTRNode = require("Common.AICt.CTRNode")
local Class = require("Core.Framework.Class")
local StartTrigger = Class.LightClass("StartTrigger", CTRNode)

function StartTrigger:ctor(nodeId, nodeData, graph)
	CTRNode.ctor(self, nodeId, nodeData, graph)
end

function StartTrigger:registerPorts()
	self.flowOut = self:addFlowOutput("flowOut")
end

function StartTrigger:executeTrigger(flow)
	self:callFlowOut(self.flowOut, flow)
end

return StartTrigger
