-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Graph.lua

local Class = require("Core.Framework.Class")
local GraphContext = require("Common.FlowCanvas.GraphContext")
local Graph = Class.LiteClass("Graph")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local SafeCallback = require("Core.Framework.SafeCallback")
local logger = LoggerManager.getLogger("FlowCanvas")

function Graph:ctor(graphId, graphData)
	self.nodes = {}
	self.startNodes = {}
	self.blackboard = {}
	self.debugSwitch = false

	self:init(graphId, graphData)
end

function Graph:init(graphId, graphData)
	self.graphId = graphId
	self.nodes = {}
	self.blackboard = graphData.blackboard or {}
	self.md5 = graphData.md5

	for id, nodeData in pairs(graphData.nodes) do
		self:addNode(id, nodeData)
	end

	for _, connectionData in ipairs(graphData.connections) do
		self:addConnection(connectionData)
	end

	self.blackboard = graphData.blackboard or {}
end

function Graph:onContextDestroy(context)
	for _, node in pairs(self.nodes) do
		if node.onContextDestroy then
			SafeCallback(node.onContextDestroy, node, context)
		end
	end
end

function Graph:destroy()
	for _, node in pairs(self.nodes) do
		if node.destroy then
			node:destroy()
		end
	end
end

function Graph:addNode(nodeId, nodeData)
	if not nodeData.className then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("nodeData className nil", self.graphId, nodeId)
		end

		return
	end

	if nodeData.className == "ClientNode" then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("nodeData className ClientNode not exist.", self.graphId, nodeId)
		end

		return
	end

	local status, nodeClass = pcall(require, "Common.FlowCanvas.Nodes." .. nodeData.className)

	if not status then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("can't find node class ", self.graphId, nodeId, nodeData.className)
		end

		return
	end

	local node = nodeClass.new(nodeId, nodeData, self)

	self.nodes[nodeId] = node

	if nodeData.className == "ServerGraphStartNode" then
		self.startNodes[nodeId] = node
	end
end

function Graph:addConnection(connectionData)
	local sourceNode = self.nodes[connectionData.sourceNode]
	local targetNode = self.nodes[connectionData.targetNode]

	if sourceNode and targetNode then
		if connectionData.isValuePort then
			targetNode:bindToValue(sourceNode, connectionData)
		else
			sourceNode:bindTo(targetNode, connectionData)
		end
	end
end

function Graph:startGraph(context)
	for _, node in pairs(self.startNodes) do
		node:onGraphStart(context)
	end
end

function Graph:getBlackBoard(key)
	return self.blackboard[key]
end

function Graph:debugCallNode(nodeId, context)
	local node = self.nodes[nodeId]

	if node then
		node:debugCalled(context)
	end
end

function Graph:checkInfiniteLoop(space, sandboxId)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		logger:debug("checkInfiniteLoop graphId:%s sandboxId:%s", self.graphId, sandboxId, space:repr())
	end

	local context = space:getGraphContext(self.graphId)

	if context then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("checkInfiniteLoop %s graph is running.", self.graphId)
		end

		return
	end

	local context = GraphContext.new(space, self, sandboxId)

	for _, node in pairs(self.startNodes) do
		node:startCheckInfiniteLoop(context)
	end
end

return Graph
