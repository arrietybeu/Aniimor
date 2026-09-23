-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\RandomIntNode.lua

local Class = require("Core.Framework.Class")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local RandomIntNode = Class.LiteClass("RandomIntNode", FlowNode)

function RandomIntNode:ctor(nodeId, nodeData, graph)
	RandomIntNode.super.ctor(self, nodeId, nodeData, graph)
end

function RandomIntNode:registerPorts()
	self.valueInput_Min = self:addValueInput("Min")
	self.valueInput_Max = self:addValueInput("Max")

	self:addValueOutput("Value", function(context)
		return self:Get_Value_Value(context)
	end)
end

function RandomIntNode:Get_Value_Value(context)
	local min = self:getContextValue(context, self.valueInput_Min)
	local max = self:getContextValue(context, self.valueInput_Max)

	return math.random(min, max - 1)
end

return RandomIntNode
