-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AICt\\Nodes\\TickTrigger.lua

local CTRNode = require("Common.AICt.CTRNode")
local Class = require("Core.Framework.Class")
local TickTrigger = Class.LightClass("TickTrigger", CTRNode)

function TickTrigger:ctor(nodeId, nodeData, graph)
	CTRNode.ctor(self, nodeId, nodeData, graph)
end

function TickTrigger:registerPorts()
	self.flowOut = self:addFlowOutput("flowOut")
end

function TickTrigger:executeTrigger(flow)
	self:callFlowOut(self.flowOut, flow)
end

return TickTrigger
