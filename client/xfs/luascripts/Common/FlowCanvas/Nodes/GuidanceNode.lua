-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\GuidanceNode.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local GuidanceNode = Class.LiteClass("GuidanceNode", FlowNode)

function GuidanceNode:ctor(nodeId, nodeData, graph)
	GuidanceNode.super.ctor(self, nodeId, nodeData, graph)
end

function GuidanceNode:registerPorts()
	self.valueInput_TimeOutSecond = self:addValueInput("TimeOutSecond")
	self.timerKey = self.nodeId .. "timer"
	self.flowOut_Out = self:addFlowOutput("Out")
	self.finish_Out = self:addFlowOutput("Finish")
	self.valueInput_GuidanceId = self:addValueInput("GuidanceId")

	self:addFlowInput("In", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)
end

function GuidanceNode:On_In_PortCalled(context, inputPortName)
	local guidanceId = self:getContextValue(context, self.valueInput_GuidanceId)

	for _, player in pairs(context:getGraphPlayers()) do
		player:startGuidanceRecord(guidanceId)
	end

	self.flowOut_Out:call(context)

	local function listener(args)
		self:removeTimer(context)
		self:removeListen(context)
		self.finish_Out:call(context)
	end

	self:addEventListen(context, "finishGuidance", listener)
end

function GuidanceNode:addEventListen(context, eventName, listener)
	local space = context:getSpace()

	if not space then
		return
	end

	self:addTimer(context)
	context:registerSpaceEventListener(self.nodeId, eventName, listener)
end

function GuidanceNode:removeListen(context)
	context:unregisterSpaceEventListeners(self.nodeId)
end

function GuidanceNode:addTimer(context)
	local timer = context:getTimer(self.timerKey)
	local timeroutSecond = self:getContextValue(context, self.valueInput_TimeOutSecond)

	if timeroutSecond and timeroutSecond ~= 0 and not timer then
		context:addContextTimer(self.timerKey, timeroutSecond, self, "On_Timeout")
	end
end

function GuidanceNode:removeTimer(context)
	context:removeContextTimer(self.timerKey, self.nodeId)
end

function GuidanceNode:On_Timeout(context)
	local timer = context:getTimer(self.timerKey)

	if not timer then
		return
	end

	self:removeListen(context)
	self:removeTimer(context)
	self.finish_Out:call(context)
end

function GuidanceNode:onContextDestroy(context)
	if context then
		self:removeTimer(context)
	end

	GuidanceNode.super.onContextDestroy(self, context)
end

return GuidanceNode
