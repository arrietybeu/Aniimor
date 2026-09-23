-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\FlowOutput.lua

local Class = require("Core.Framework.Class")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("FlowCanvas")
local FlowOutput = Class.LiteClass("FlowOutput")

function FlowOutput:ctor(name, graphId, nodeId)
	self.name = name
	self.graphId = graphId
	self.nodeId = nodeId
	self.pointer = nil
	self.outInPortName = ""
	self.nextNodeId = nil
end

function FlowOutput:bindTo(input, outInPortName, nextNodeId)
	self.pointer = input.pointer
	self.outInPortName = outInPortName
	self.nextNodeId = nextNodeId
end

function FlowOutput:call(context)
	if context._destroyed then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("FlowOutput:call context destroyed, skip. sandboxId=%s graphId=%s nodeId=%s portName=%s", context.sandboxId, self.graphId, self.nodeId, self.name)
		end

		return
	end

	if _G_IsDebugMode then
		local space = context:getSpace()

		if space and context:debugOpen() then
			local targetNodeId = self.nextNodeId or -1

			space:allClientsMsg("RPC_SC_DebugCallPort", self.graphId, self.nodeId, self.name, targetNodeId, self.outInPortName)
		end

		context:onNodeOutput(self.nodeId, self.nextNodeId, self.outInPortName)
	end

	if self.pointer then
		if _G_IsDebugMode then
			context:onNodeInput(self.nextNodeId, self.nodeId, self.name)

			local space = context:getSpace()

			if space and context:debugOpen() then
				local fromNodeId = self.nodeId or -1

				space:allClientsMsg("RPC_SC_DebugPortIn", self.graphId, self.nextNodeId, self.outInPortName, fromNodeId, self.name)
			end
		end

		self.pointer(context, self.outInPortName)
	end
end

return FlowOutput
