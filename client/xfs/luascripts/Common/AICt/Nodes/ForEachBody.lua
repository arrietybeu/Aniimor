-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AICt\\Nodes\\ForEachBody.lua

local CTRNode = require("Common.AICt.CTRNode")
local Class = require("Core.Framework.Class")
local ForEachBody = Class.LightClass("ForEachBody", CTRNode)

function ForEachBody:ctor(nodeId, nodeData, graph)
	CTRNode.ctor(self, nodeId, nodeData, graph)
end

function ForEachBody:registerPorts()
	self:addFlowInput("doIterator", function(flow)
		return self:On_doIterator_PortCalled(flow)
	end)

	self.valueInput_condition = self:addValueInput("condition")
end

function ForEachBody:On_doIterator_PortCalled(flow)
	return self:getInputValue(self.valueInput_condition, flow)
end

return ForEachBody
