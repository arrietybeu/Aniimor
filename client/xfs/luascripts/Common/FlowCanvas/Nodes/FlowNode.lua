-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\FlowNode.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local FlowInput = require("Common.FlowCanvas.FlowInput")
local FlowOutput = require("Common.FlowCanvas.FlowOutput")
local ValueInput = require("Common.FlowCanvas.ValueInput")
local ValueOutput = require("Common.FlowCanvas.ValueOutput")
local Class = require("Core.Framework.Class")
local FlowNode = Class.LiteClass("FlowNode")
local inspect = require("Core.Common.inspect")
local logger = LoggerManager.getLogger("FlowCanvas")
local pairs = pairs

function FlowNode:ctor(nodeId, nodeData, graph)
	self.logger = logger
	self.nodeId = nodeId
	self.nodeData = nodeData
	self._inputPortValues = nodeData._inputPortValues or {}
	self._outputPortValues = nodeData._outputPortValues or {}
	self.graph = graph
	self.inputPorts = {}
	self.outputPorts = {}
	self.uid = nodeData.uid

	self:registerPorts()
end

function FlowNode:registerPorts()
	return
end

function FlowNode:onContextDestroy(context)
	return
end

function FlowNode:destroy()
	self.logger = nil
	self.nodeData = nil
	self._inputPortValues = nil
	self._outputPortValues = nil
	self.graph = nil
	self.inputPorts = nil
	self.outputPorts = nil
end

function FlowNode:bindTo(targetNode, connectionData)
	local outputPort = self:getOutputPort(connectionData.sourcePortName)

	if outputPort == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("bindTo error: outputPort is nil", self:getClassType(), inspect(connectionData))
		end

		return
	end

	local inputPort = targetNode:getInputPort(connectionData.targetPortName)

	outputPort:bindTo(inputPort, connectionData.targetPortName, targetNode.nodeId)
end

function FlowNode:bindToValue(sourceNode, connectionData)
	local inputPort = self:getInputPort(connectionData.targetPortName)

	if inputPort == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("bindToValue error: inputPort is nil", self:getClassType(), inspect(connectionData))
		end

		return
	end

	local outputPort = sourceNode:getOutputPort(connectionData.sourcePortName)

	inputPort:bindTo(outputPort, sourceNode.nodeId)
end

function FlowNode:getOutputPort(name)
	return self.outputPorts[name]
end

function FlowNode:getInputPort(name)
	return self.inputPorts[name]
end

function FlowNode:addFlowInput(name, pointer)
	local input = FlowInput.new(name, pointer)

	self.inputPorts[name] = input

	return input
end

function FlowNode:addFlowOutput(name)
	local output = FlowOutput.new(name, self.graph.graphId, self.nodeId)

	self.outputPorts[name] = output

	return output
end

function FlowNode:addValueInput(name)
	local input = ValueInput.new(name, self._inputPortValues[name])

	self.inputPorts[name] = input

	return input
end

function FlowNode:addValueOutput(name, getter)
	local output = ValueOutput.new(name, getter)

	self.outputPorts[name] = output

	return output
end

function FlowNode:genPortKey(port)
	return port.name .. self.nodeId
end

function FlowNode:setContextValue(context, port, value)
	context:setContextValue(self:genPortKey(port), value)
end

function FlowNode:getContextValue(context, port)
	local key = self:genPortKey(port)

	if port:getClassType() == "ValueInput" then
		if port.isClient then
			return context:getContextValue(key)
		end

		if port.getter then
			return port.getter(context)
		else
			return port.serializedValue
		end
	elseif port:getClassType() == "ValueOutput" then
		return context:getContextValue(key)
	end
end

function FlowNode:debugCalled(context)
	for portName, outPut in pairs(self.outputPorts) do
		if outPut:getClassType() == "FlowOutput" then
			if self.removeTimer then
				self:removeTimer(context)
			end

			if self.checkDoOnce then
				self:checkDoOnce(context)
			end

			if outPut.pointer then
				outPut:call(context)
			end
		end

		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			logger:debug("debugCalled node:%s nodeId: %s portName: %s", self:getClassType(), self.nodeId, portName)
		end
	end
end

function FlowNode:checkInfiniteLoop(context)
	local graph = self.graph
	local nextNodes = {}

	for _, outPut in pairs(self.outputPorts) do
		if outPut:getClassType() == "FlowOutput" then
			if self.removeTimer then
				self:removeTimer(context)
			end

			if self.checkDoOnce then
				self:checkDoOnce(context)
			end

			if outPut.pointer then
				outPut:call(context)

				local node = graph.nodes[outPut.nextNodeId]

				if node and not nextNodes[outPut.nextNodeId] then
					nextNodes[outPut.nextNodeId] = node
				end
			end
		end
	end

	for _, node in pairs(nextNodes) do
		node:checkInfiniteLoop(context)
	end
end

return FlowNode
