-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\ListenTideChangeNode.lua

local Class = require("Core.Framework.Class")
local ServerEventConst = require("Const.ServerEventConst")
local ListenBaseNode = require("Common.FlowCanvas.Nodes.ListenBaseNode")
local ListenTideChangeNode = Class.LiteClass("ListenTideChangeNode", ListenBaseNode)
local Utils = require("Common.Utils.Utils")

function ListenTideChangeNode:ctor(nodeId, nodeData, graph)
	ListenTideChangeNode.super.ctor(self, nodeId, nodeData, graph)
end

function ListenTideChangeNode:registerPorts()
	ListenTideChangeNode.super.registerPorts(self)

	self.flowOut_Out = self:addFlowOutput("Out")
	self.valueOutput_TideState = self:addValueOutput("TideState", function(context)
		return self:Get_TideState_Value(context)
	end)
end

function ListenTideChangeNode:Get_TideState_Value(context)
	return self:getContextValue(context, self.valueOutput_TideState)
end

function ListenTideChangeNode:On_In_PortCalled(context, inputPortName)
	local eventName = ServerEventConst.TIDE_CHANGE

	local function listener(args)
		self:removeTimer(context)
		self:checkDoOnce(context)

		local space = context:getSpace()

		if not space then
			return
		end

		local player = space:getMainPlayer()

		if not player then
			return
		end

		local tideStateId = 0

		if player ~= nil and Utils.getTideStateId then
			tideStateId = Utils.getTideStateId(player)
		end

		self:setContextValue(context, self.valueOutput_TideState, tideStateId)
		self.flowOut_Out:call(context)
	end

	self:addEventListen(context, eventName, listener)
end

return ListenTideChangeNode
