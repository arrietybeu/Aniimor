-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AICt\\Nodes\\TickLodTrigger.lua

local CTRNode = require("Common.AICt.CTRNode")
local Class = require("Core.Framework.Class")
local TickLodTrigger = Class.LightClass("TickLodTrigger", CTRNode)

function TickLodTrigger:ctor(nodeId, nodeData, graph)
	CTRNode.ctor(self, nodeId, nodeData, graph)
end

function TickLodTrigger:registerPorts()
	self.flowOut = self:addFlowOutput("flowOut")
end

function TickLodTrigger:executeTrigger(flow)
	self:callFlowOut(self.flowOut, flow)
end

return TickLodTrigger
