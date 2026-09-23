-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\GetSandboxPhaseNode.lua

local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local Class = require("Core.Framework.Class")
local GetSandboxPhaseNode = Class.LiteClass("GetSandboxPhaseNode", FlowNode)

function GetSandboxPhaseNode:ctor(nodeId, nodeData, graph)
	FlowNode.ctor(self, nodeId, nodeData, graph)
end

function GetSandboxPhaseNode:registerPorts()
	self.sandboxId = self.nodeData.SandboxId or 0

	self:addValueOutput("Value", function(context)
		return self:Get_Value_Value(context)
	end)
end

function GetSandboxPhaseNode:Get_Value_Value(context)
	local sandboxId = self.sandboxId ~= 0 and self.sandboxId or context.sandboxId

	return context:getSandboxPhase(sandboxId)
end

return GetSandboxPhaseNode
