-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\MathNode.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local MathNode = Class.LiteClass("MathNode", FlowNode)
local math = math
local MathOp = {
	function(a, b)
		return a + b
	end,
	function(a, b)
		return a - b
	end,
	function(a, b)
		return a * b
	end,
	function(a, b)
		return a / b
	end,
	function(a, b)
		return a % b
	end,
	function(a, b)
		return math.floor(a / b)
	end,
	function(a, b)
		return math.ceil(a / b)
	end,
	function(a, b)
		return b < a
	end,
	function(a, b)
		return b <= a
	end,
	function(a, b)
		return a == b
	end,
	function(a, b)
		return a < b
	end,
	function(a, b)
		return a <= b
	end
}

function MathNode:ctor(nodeId, nodeData, graph)
	MathNode.super.ctor(self, nodeId, nodeData, graph)
end

function MathNode:registerPorts()
	self.valueInput_InputA = self:addValueInput("InputA")
	self.valueInput_InputB = self:addValueInput("InputB")

	self:addValueOutput("Value", function(context)
		return self:Get_Value_Value(context)
	end)

	self.Operation = self.nodeData.Operation or 0
end

function MathNode:Get_Value_Value(context)
	local func = MathOp[self.Operation]

	if not func then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			self.logger:info("MathNode:Get_Value_Value %s %s", self.nodeId, self.Operation)
		end

		return
	end

	local a = self:getContextValue(context, self.valueInput_InputA)
	local b = self:getContextValue(context, self.valueInput_InputB)

	return func(a, b)
end

return MathNode
