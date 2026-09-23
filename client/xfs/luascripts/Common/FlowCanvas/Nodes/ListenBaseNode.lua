-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\ListenBaseNode.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local ListenBaseNode = Class.LiteClass("ListenBaseNode", FlowNode)

function ListenBaseNode:ctor(nodeId, nodeData, graph)
	ListenBaseNode.super.ctor(self, nodeId, nodeData, graph)
end

function ListenBaseNode:registerPorts()
	self.flowOut_TimeOut = self:addFlowOutput("TimeOut")
	self.valueInput_TimeOutSecond = self:addValueInput("TimeOutSecond")
	self.timerKey = self.nodeId .. "timer"
	self.valueInput_DoOnce = self:addValueInput("DoOnce")

	self:addFlowInput("In", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)
	self:addFlowInput("Cancel", function(context, inputPortName)
		self:On_Cancel_PortCalled(context, inputPortName)
	end)

	for _, field in pairs(self._outputPortValues) do
		local valueOutput = "valueOutput_" .. field

		self[valueOutput] = self:addValueOutput(field, function(context)
			local value = self:getContextValue(context, self[valueOutput])

			if not value then
				if LoggerManager.checkLogger(LoggerConst.WARN) then
					self.logger:warn("ListenerEventNode nodeId %s port %s", self.nodeId, field)
				end

				return
			end

			return value
		end)
	end
end

function ListenBaseNode:On_Cancel_PortCalled(context, inputPortName)
	self:removeListen(context)
	self:removeTimer(context)
end

function ListenBaseNode:On_In_PortCalled(context, inputPortName)
	return
end

function ListenBaseNode:removeListen(context)
	context:unregisterSpaceEventListeners(self.nodeId)
end

function ListenBaseNode:checkDoOnce(context)
	local doOnce = self:getContextValue(context, self.valueInput_DoOnce)

	if doOnce then
		self:removeListen(context)

		return true
	end

	return false
end

function ListenBaseNode:addEventListen(context, eventName, listener)
	local space = context:getSpace()

	if not space then
		return
	end

	self:addTimer(context)
	context:registerSpaceEventListener(self.nodeId, eventName, listener)
end

function ListenBaseNode:addTimer(context)
	local timer = context:getTimer(self.timerKey)
	local timeroutSecond = self:getContextValue(context, self.valueInput_TimeOutSecond)

	if timeroutSecond and timeroutSecond ~= 0 and not timer then
		context:addContextTimer(self.timerKey, timeroutSecond, self, "On_Timeout")
	end
end

function ListenBaseNode:removeTimer(context)
	context:removeContextTimer(self.timerKey, self.nodeId)
end

function ListenBaseNode:On_Timeout(context)
	local timer = context:getTimer(self.timerKey)

	if not timer then
		return
	end

	local doOnce = self:getContextValue(context, self.valueInput_DoOnce)

	if doOnce then
		self:removeListen(context)
	end

	self:removeTimer(context)
	self.flowOut_TimeOut:call(context)
end

function ListenBaseNode:onContextDestroy(context)
	if context then
		self:removeTimer(context)
	end

	ListenBaseNode.super.onContextDestroy(self, context)
end

return ListenBaseNode
