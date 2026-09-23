-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AICt\\CTRNode.lua

local Class = require("Core.Framework.Class")
local CTRNode = Class.LightClass("CTRNode")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("CTRNode")
local CTRFlowInput = require("Common.AICt.CTRFlowInput")
local CTRFlowOutput = require("Common.AICt.CTRFlowOutput")
local CTRValueInput = require("Common.AICt.CTRValueInput")
local CTRValueOutput = require("Common.AICt.CTRValueOutput")
local xpcall = xpcall
local traceback = debug.traceback

function CTRNode:ctor(nodeId, nodeData, graph)
	self.logger = logger
	self.nodeId = nodeId
	self.nodeData = nodeData
	self._inputPortValues = nodeData._inputPortValues or {}
	self.graph = graph
	self.inputPorts = {}
	self.outputPorts = {}
end

function CTRNode:registerPorts()
	return
end

function CTRNode:bindTo(targetNode, connectionData)
	local outputPort = self:getOutputPort(connectionData.sourcePortName)

	if outputPort == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("bindTo error: outputPort is nil", self.graph.graphId, self:getClassType(), inspect(connectionData))
		end

		return
	end

	local inputPort = targetNode:getInputPort(connectionData.targetPortName)

	outputPort:bindTo(inputPort)
end

function CTRNode:bindToValue(sourceNode, connectionData)
	local inputPort = self:getInputPort(connectionData.targetPortName)

	if inputPort == nil then
		return
	end

	local outputPort = sourceNode:getOutputPort(connectionData.sourcePortName)

	if outputPort == nil then
		return
	end

	inputPort:bindTo(outputPort)
end

function CTRNode:getOutputPort(name)
	return self.outputPorts[name]
end

function CTRNode:getInputPort(name)
	return self.inputPorts[name]
end

function CTRNode:addFlowInput(name, pointer)
	local input = CTRFlowInput.new(name, self.nodeId, pointer)

	self.inputPorts[name] = input

	return input
end

function CTRNode:addFlowOutput(name)
	local output = CTRFlowOutput.new(name, self.graph.graphId, self.nodeId)

	self.outputPorts[name] = output

	return output
end

function CTRNode:addValueInput(name)
	local input = CTRValueInput.new(name, self.nodeId, self._inputPortValues[name])

	self.inputPorts[name] = input

	return input
end

function CTRNode:addValueOutput(name, getter)
	local output = CTRValueOutput.new(name, self.nodeId, getter)

	self.outputPorts[name] = output

	return output
end

function CTRNode:doFlowOut(flow)
	if self.flowOut == nil then
		return
	end

	self:callFlowOut(self.flowOut, flow)
end

function CTRNode:checkCondition(condition, flow)
	if flow.__hasActivate then
		return
	end

	if not condition then
		flow:doStartFail()

		return
	end

	flow.__hasActivate = true

	flow:doStart()
end

local function tryFlowExec(flowOutPort, flow)
	return flowOutPort:call(flow)
end

function CTRNode:callFlowOut(flowOutPort, flow)
	if flow.__breakFlow then
		return
	end

	local status, res = xpcall(tryFlowExec, traceback, flowOutPort, flow)

	if not status and LoggerManager.checkLogger(LoggerConst.ERROR) then
		self.logger:error(string.format("GRAPH: 【%s】, CTRNode: 【%s】, Pos: 【%s】, StaticId: 【%s】 call flow out with error: %s", flow.graphId, self.nodeId, flow.__owner and inspect(flow.__owner:getPosition()) or "", flow.__owner and flow.__owner.staticId or "", res))
	end

	if self.graph.debugMode then
		self:executeNode({
			vPort = true,
			entityId = flow.context._entActorId,
			inputNodeId = flowOutPort:getInputPortNodeId(),
			outputNodeId = flowOutPort.nodeId,
			exception = not status,
			errorInfo = res,
			iPortName = flowOutPort:getInputPortName(),
			oPortName = flowOutPort.name
		})
	end

	return res
end

local function tryInputExec(inputPort, flow)
	return inputPort:getValue(flow)
end

function CTRNode:getInputValue(inputPort, flow)
	local isOk, result = xpcall(tryInputExec, traceback, inputPort, flow)

	if not isOk and LoggerManager.checkLogger(LoggerConst.ERROR) then
		self.logger:error(string.format("GRAPH: 【%s】, CTRNode: 【%s】, Pos: 【%s】, StaticId: 【%s】 call input value with error: %s", flow.graphId, self.nodeId, flow.__owner and inspect(flow.__owner:getPosition()) or "", flow.__owner and flow.__owner.staticId or "", result))
	end

	if self.graph.debugMode then
		self:executeNode({
			vPort = false,
			entityId = flow.context._entActorId,
			inputNodeId = inputPort.nodeId,
			outputNodeId = inputPort:getOutputPortNodeId(),
			exception = not isOk,
			errorInfo = result,
			value = inspect(result),
			iPortName = inputPort.name,
			oPortName = inputPort:getOutputPortName()
		})
	end

	return result
end

function CTRNode:executeNode(executeInfo)
	if self.graph == nil or self.graph.executeNodeAction == nil then
		return
	end

	if string.isNilOrEmpty(executeInfo.iPortName) or string.isNilOrEmpty(executeInfo.oPortName) then
		return
	end

	self.graph.executeNodeAction(executeInfo)
end

function CTRNode:onDispose(flow)
	return
end

return CTRNode
