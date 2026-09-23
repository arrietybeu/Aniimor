-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AICt\\Nodes\\Not.lua

local CTRNode = require("Common.AICt.CTRNode")
local Class = require("Core.Framework.Class")
local Not = Class.LightClass("Not", CTRNode)

function Not:ctor(nodeId, nodeData, graph)
	CTRNode.ctor(self, nodeId, nodeData, graph)
end

function Not:registerPorts()
	self.valueInput_input = self:addValueInput("input")

	self:addValueOutput("out", function(vp)
		return self:Get_out_Value(vp)
	end)
end

function Not:Get_out_Value(flow)
	return not self:getInputValue(self.valueInput_input, flow)
end

return Not
