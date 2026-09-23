-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\CheckPlayerStateNode.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local CheckPlayerStateNode = Class.LiteClass("CheckPlayerStateNode", FlowNode)

function CheckPlayerStateNode:ctor(nodeId, nodeData, graph)
	CheckPlayerStateNode.super.ctor(self, nodeId, nodeData, graph)
end

function CheckPlayerStateNode:registerPorts()
	self:addFlowInput("In", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)

	self.State = self.nodeData.State
	self.flowOut_True = self:addFlowOutput("True")
	self.flowOut_False = self:addFlowOutput("False")
end

function CheckPlayerStateNode:On_In_PortCalled(context, inputPortName)
	local state = self.State

	if not state then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("CheckPlayerStateNode:On_In_PortCalled State error")
		end

		return
	end

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("CheckPlayerStateNode state %s", state)
	end

	local space = context:getSpace()

	if space.ownerPlayer:CHECK_ST(state) then
		self.flowOut_True:call(context)
	else
		self.flowOut_False:call(context)
	end
end

return CheckPlayerStateNode
