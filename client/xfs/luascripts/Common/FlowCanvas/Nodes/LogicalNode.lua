-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\LogicalNode.lua

local Class = require("Core.Framework.Class")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local SandboxConst = require("Common.Const.SandboxConst")
local LogicalNode = Class.LiteClass("LogicalNode", FlowNode)

function LogicalNode:ctor(nodeId, nodeData, graph)
	LogicalNode.super.ctor(self, nodeId, nodeData, graph)
end

function LogicalNode:registerPorts()
	local portCount = self.nodeData.portCount

	for i = 1, portCount do
		self["valueInput_" .. i] = self:addValueInput(tostring(i))
	end

	self:addValueOutput("Value", function(context)
		return self:Get_Value_Value(context)
	end)

	self.Operation = self.nodeData.Operation
end

function LogicalNode:Get_Value_Value(context)
	local portCount = self.nodeData.portCount
	local operation = self.Operation

	if operation == SandboxConst.LOGICAL.AND then
		local res = true

		for i = 1, portCount do
			local cur = self:getContextValue(context, self["valueInput_" .. i])
			local res = res and cur

			if not res then
				return res
			end
		end

		return res
	elseif operation == SandboxConst.LOGICAL.OR then
		local res = false

		for i = 1, portCount do
			local cur = self:getContextValue(context, self["valueInput_" .. i])
			local res = res or cur

			if res then
				return res
			end
		end

		return res
	else
		for i = 1, portCount do
			return not self:getContextValue(context, self["valueInput_" .. i])
		end
	end

	return false
end

return LogicalNode
