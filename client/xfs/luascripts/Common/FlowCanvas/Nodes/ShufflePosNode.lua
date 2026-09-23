-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\ShufflePosNode.lua

local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local Class = require("Core.Framework.Class")
local ShufflePosNode = Class.LiteClass("ShufflePosNode", FlowNode)

function ShufflePosNode:ctor(nodeId, nodeData, graph)
	FlowNode.ctor(self, nodeId, nodeData, graph)

	local portCount = self.nodeData.portCount or 6

	for i = 1, portCount do
		self["Get_Value" .. i] = function(node, context)
			return self:getContextValue(context, node, node["valueOutput" .. i])
		end
	end
end

function ShufflePosNode:registerPorts()
	self:addFlowInput("In", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)

	self.flowOut_Out = self:addFlowOutput("Out")

	local portCount = self.nodeData.portCount or 6

	for i = 1, portCount do
		self["valueInput_" .. i] = self:addValueInput(tostring(i))
		self["valueOutput_" .. i] = self:addValueOutput(i, function(context)
			return self["Get_Value_" .. i](self, context)
		end)
	end
end

function ShufflePosNode:On_In_PortCalled(context, inputPortName)
	local list = {}
	local portCount = self.nodeData.portCount or 6

	for i = 1, portCount do
		list[#list + 1] = self:getContextValue(context, self["valueInput_" .. i])
	end

	for i = #list, 2, -1 do
		local j = math.random(i)

		list[i], list[j] = list[j], list[i]
	end

	for i = 1, portCount do
		context:setValue(self["valueOutput_" .. i], list[i])
	end

	self.flowOut_Out:call(context)
end

return ShufflePosNode
