-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AICt\\CTRFlowOutput.lua

local Class = require("Core.Framework.Class")
local CTRFlowOutput = Class.LightClass("CTRFlowOutput")

function CTRFlowOutput:ctor(name, graphId, nodeId)
	self.name = name
	self.input = nil
	self.graphId = graphId
	self.nodeId = nodeId
	self.pointer = nil
end

function CTRFlowOutput:bindTo(input)
	self.pointer = input.pointer
	self.input = input
end

function CTRFlowOutput:call(flow)
	if self.pointer then
		return self.pointer(flow)
	end
end

function CTRFlowOutput:getInputPortNodeId()
	return self.input and self.input.nodeId or 0
end

function CTRFlowOutput:getInputPortName()
	return self.input and self.input.name or ""
end

return CTRFlowOutput
