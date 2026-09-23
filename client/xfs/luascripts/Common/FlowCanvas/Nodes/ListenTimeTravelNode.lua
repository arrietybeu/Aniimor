-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\ListenTimeTravelNode.lua

local Class = require("Core.Framework.Class")
local ServerEventConst = require("Const.ServerEventConst")
local ListenBaseNode = require("Common.FlowCanvas.Nodes.ListenBaseNode")
local ListenTimeTravelNode = Class.LiteClass("ListenTimeTravelNode", ListenBaseNode)

function ListenTimeTravelNode:ctor(nodeId, nodeData, graph)
	ListenTimeTravelNode.super.ctor(self, nodeId, nodeData, graph)
end

function ListenTimeTravelNode:registerPorts()
	ListenTimeTravelNode.super.registerPorts(self)

	self.flowOut_Out = self:addFlowOutput("Out")
	self.State = self.nodeData.State or 0
end

function ListenTimeTravelNode:On_In_PortCalled(context, inputPortName)
	local space = context:getSpace()

	if not space then
		return
	end

	local eventName = ServerEventConst.TIME_TRAVEL .. self.State

	local function listener(args)
		self:removeTimer(context)
		self:checkDoOnce(context)
		self.flowOut_Out:call(context)
	end

	self:addEventListen(context, eventName, listener)
end

return ListenTimeTravelNode
