-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AICt\\CTRGraph.lua

local Class = require("Core.Framework.Class")
local CTRGraph = Class.LightClass("CTRGraph")
local CTRConst = require("Common.AICt.CTRConst")
local CTRCommonNodeDefine = require("Common.AICt.CTRCommonNodeDefine")
local CTRCommonNode = require("Common.AICt.CTRCommonNode")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("CTRGraph")
local bit = bit

CTRGraph.Debug = {
	_ListenerActorId = 0
}
CTRGraph._cacheNodeClassPath = {}

function CTRGraph:ctor(graphId, graphData)
	self.nodes = {}
	self.triggers = {}
	self.tickTrigger = nil
	self.tickLodTrigger = nil
	self.bridgeTrigger = nil
	self.startTrigger = nil
	self.endTrigger = nil
	self.messageTriggers = {}
	self.debugMode = false
	self.startGraphAction = nil
	self.executeNodeAction = nil
	self.endGraphAction = nil

	self:init(graphId, graphData)
end

function CTRGraph:init(graphId, graphData)
	self.graphId = graphId
	self.nodes = {}
	self.blackBoards = graphData.blackBoards or {}

	for id, nodeData in pairs(graphData.nodes) do
		self:addNode(id, nodeData)
	end

	for _, connectionData in ipairs(graphData.connections) do
		self:addConnection(connectionData)
	end
end

function CTRGraph:destroy()
	for _, node in pairs(self.nodes) do
		if node.destroy then
			node:destroy()
		end
	end
end

function CTRGraph:addNode(nodeId, nodeData)
	local nodeClass

	if CTRCommonNodeDefine[nodeData.className] ~= nil then
		nodeClass = CTRCommonNode
	else
		local nodeClassName = nodeData.className

		if not CTRGraph._cacheNodeClassPath[nodeClassName] then
			CTRGraph._cacheNodeClassPath[nodeClassName] = "Common.AICt.Nodes." .. nodeData.className
		end

		nodeClass = require(CTRGraph._cacheNodeClassPath[nodeClassName])
	end

	local node = nodeClass.new(nodeId, nodeData, self)

	node:registerPorts()

	self.nodes[nodeId] = node

	self:parseNode(node)
end

function CTRGraph:parseNode(node)
	local nData = node.nodeData

	if nData.nodeTp == CTRConst.NodeBaseType.StartTrigger then
		if self.startTrigger ~= nil then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("CTRGraph【" .. self.graphId .. "】" .. "has multi startTrigger")
			end

			return
		end

		self.startTrigger = node
	elseif nData.nodeTp == CTRConst.NodeBaseType.EndTrigger then
		if self.endTrigger ~= nil then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("CTRGraph【" .. self.graphId .. "】" .. "has multi endTrigger")
			end

			return
		end

		self.endTrigger = node
	elseif nData.nodeTp == CTRConst.NodeBaseType.EventTrigger then
		local triggerName = node:getTriggerName()

		if triggerName ~= nil then
			self.triggers[triggerName] = node
		elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("CTRGraph【" .. self.graphId .. "】" .. "EventTriggerName is nil")
		end
	elseif nData.nodeTp == CTRConst.NodeBaseType.BridgeTrigger then
		if self.bridgeTrigger ~= nil then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("CTRGraph【" .. self.graphId .. "】" .. "has multi bridgeTrigger")
			end

			return
		end

		self.bridgeTrigger = node
	elseif nData.nodeTp == CTRConst.NodeBaseType.TickTrigger then
		if self.tickTrigger ~= nil then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("CTRGraph【" .. self.graphId .. "】" .. "has multi tickTrigger")
			end

			return
		end

		self.tickTrigger = node
	elseif nData.nodeTp == CTRConst.NodeBaseType.MessageTrigger then
		local triggerName = node:getTriggerName()

		if triggerName ~= nil then
			self.messageTriggers[triggerName] = node
		elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("CTRGraph【" .. self.graphId .. "】" .. "MessageTriggerName is nil")
		end
	elseif nData.nodeTp == CTRConst.NodeBaseType.TickLodTrigger then
		if self.tickLodTrigger ~= nil then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("CTRGraph【" .. self.graphId .. "】" .. "has multi tickLodTrigger")
			end

			return
		end

		self.tickLodTrigger = node
	end
end

function CTRGraph:addConnection(connectionData)
	local sourceNode = self.nodes[connectionData.sourceNode]
	local targetNode = self.nodes[connectionData.targetNode]

	if connectionData.isValuePort then
		targetNode:bindToValue(sourceNode, connectionData)
	else
		sourceNode:bindTo(targetNode, connectionData)
	end
end

function CTRGraph:getTriggerNameList(refList)
	for k, _ in pairs(self.triggers) do
		refList[#refList + 1] = k
	end

	return refList
end

function CTRGraph:getTickTrigger()
	if self.tickTrigger == nil then
		return nil
	end

	return self.tickTrigger.nodeData
end

function CTRGraph:getTickLodTrigger()
	if self.tickLodTrigger == nil then
		return nil
	end

	return self.tickLodTrigger.nodeData
end

function CTRGraph:getMessageTriggerNameList(refList)
	for k, _ in pairs(self.messageTriggers) do
		refList[#refList + 1] = k
	end

	return refList
end

function CTRGraph:doStartGraph(flow)
	if self.debugMode then
		self:startDebugFrame(flow)
	end
end

function CTRGraph:doStart(flow)
	if self.startTrigger then
		self.startTrigger:executeTrigger(flow)
	end
end

function CTRGraph:doGraph(flow)
	if flow.__triggerType == CTRConst.NodeBaseType.MessageTrigger then
		self:doMessageTrigger(flow, flow.__triggerName)
	elseif flow.__triggerType == CTRConst.NodeBaseType.EventTrigger then
		self:doEventTrigger(flow, flow.__triggerName)
	elseif flow.__triggerType == CTRConst.NodeBaseType.TickTrigger then
		self:doTickTrigger(flow)
	elseif flow.__triggerType == CTRConst.NodeBaseType.TickLodTrigger then
		self:doTickLodTrigger(flow)
	elseif flow.__triggerType == CTRConst.NodeBaseType.BridgeTrigger then
		self:doBridgeTrigger(flow)
	end
end

function CTRGraph:doEnd(flow)
	if self.endTrigger then
		self.endTrigger:executeTrigger(flow)
	end
end

function CTRGraph:doFinished(flow)
	if self.Debug.recorderCallback and flow.context._entActorId == self.Debug._ListenerActorId then
		local debugInfo = self:getDebugInfo(flow.__triggerType)

		debugInfo.triggerSuccess = tostring(flow.__hasActivate)
		debugInfo.executeSuccess = tostring(flow.__hasActivate)

		CTRGraph.Debug.recorderCallback(self.graphId, debugInfo)
	end

	if self.debugMode then
		self:endDebugFrame(flow.context)
	end
end

function CTRGraph:doEventTrigger(flow, triggerName)
	if string.isNilOrEmpty(triggerName) then
		return
	end

	local ti = self.triggers[triggerName]

	if ti == nil then
		return
	end

	ti:executeTrigger(flow)
end

function CTRGraph:doMessageTrigger(flow, messageName)
	if string.isNilOrEmpty(messageName) then
		return
	end

	local ti = self.messageTriggers[messageName]

	if ti == nil then
		return
	end

	ti:executeTrigger(flow)
end

function CTRGraph:doTickTrigger(flow)
	if self.tickTrigger == nil then
		return
	end

	self.tickTrigger:executeTrigger(flow)
end

function CTRGraph:doTickLodTrigger(flow)
	if self.tickLodTrigger == nil then
		return
	end

	self.tickLodTrigger:executeTrigger(flow)
end

function CTRGraph:doBridgeTrigger(flow)
	if self.bridgeTrigger == nil then
		return
	end

	self.bridgeTrigger:executeTrigger(flow)
end

function CTRGraph:onGetInterruptResult(interruptId, context)
	local bNode = self.nodes[interruptId]

	if bNode == nil then
		return false
	end

	return bNode:GetInterruptResult(context)
end

function CTRGraph:onGetConditionGraphPortRes(flow, pName)
	local macroOut = self:findNodeByType("MacroOut")

	if macroOut == nil then
		return false
	end

	return macroOut:getPortValue(flow, pName)
end

function CTRGraph:findNodeByType(className)
	for _, v in pairs(self.nodes) do
		if v.nodeData.className == className then
			return v
		end
	end

	return nil
end

function CTRGraph:findNodeById(nodeId)
	return self.nodes[nodeId]
end

function CTRGraph:getBlackBoard(paramName)
	return self.blackBoards[paramName]
end

function CTRGraph:getDebugInfo(triggerType)
	local res = {
		triggerTp = 0
	}
	local triggers = {}

	res.triggers = triggers

	if triggerType == CTRConst.NodeBaseType.EventTrigger then
		for _, v in pairs(self.triggers) do
			table.insert(triggers, v.nodeData.triggerName or v.nodeData.behaviourName)
		end

		res.triggerTp = bit.bor(res.triggerTp, bit.lshift(1, 0))
	elseif triggerType == CTRConst.NodeBaseType.MessageTrigger then
		for _, v in pairs(self.messageTriggers) do
			table.insert(triggers, v.nodeData.triggerName or v.nodeData.behaviourName)
		end

		res.triggerTp = bit.bor(res.triggerTp, bit.lshift(1, 2))
	elseif triggerType == CTRConst.NodeBaseType.TickTrigger or triggerType == CTRConst.NodeBaseType.TickLodTrigger then
		res.triggerTp = bit.bor(res.triggerTp, bit.lshift(1, 1))

		if self.tickTrigger then
			table.insert(triggers, self.tickTrigger.nodeData.className)
		end

		if self.tickLodTrigger then
			table.insert(triggers, self.tickLodTrigger.nodeData.className)
		end
	end

	return res
end

function CTRGraph:setDebugMode(mode)
	self.debugMode = mode
end

function CTRGraph:bindToCSharpGraphFunc(startGraphAction, executeNodeAction, endGraphAction)
	self.startGraphAction = startGraphAction
	self.executeNodeAction = executeNodeAction
	self.endGraphAction = endGraphAction
end

function CTRGraph:isDebugMode()
	return self.debugMode
end

function CTRGraph:startDebugFrame(flow)
	if self.startGraphAction == nil then
		return
	end

	self.startGraphAction(flow.context._entActorId)
end

function CTRGraph:endDebugFrame(context)
	if self.endGraphAction == nil then
		return
	end

	self.endGraphAction(context._entActorId)
end

return CTRGraph
