-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\ServerGraphStartNode.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local ServerGraphStartNode = Class.LiteClass("ServerGraphStartNode", FlowNode)

function ServerGraphStartNode:ctor(nodeId, nodeData, graph)
	ServerGraphStartNode.super.ctor(self, nodeId, nodeData, graph)
end

function ServerGraphStartNode:registerPorts()
	self.flowOut_Out = self:addFlowOutput("Out")
end

function ServerGraphStartNode:onGraphStart(context)
	self.flowOut_Out:call(context)
end

function ServerGraphStartNode:startCheckInfiniteLoop(context)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("checkInfiniteLoop", context.space.id, self.graph.graphId)
	end

	self:checkInfiniteLoop(context)
end

return ServerGraphStartNode
