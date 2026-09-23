-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\ListenSludgeClearPercentNode.lua

local Class = require("Core.Framework.Class")
local SandboxListenBaseNode = require("Common.FlowCanvas.Nodes.SandboxListenBaseNode")
local ServerEventConst = require("Const.ServerEventConst")
local ListenSludgeClearPercentNode = Class.LiteClass("ListenSludgeClearPercentNode", SandboxListenBaseNode)

function ListenSludgeClearPercentNode:ctor(nodeId, nodeData, graph)
	ListenSludgeClearPercentNode.super.ctor(self, nodeId, nodeData, graph)
end

function ListenSludgeClearPercentNode:registerPorts()
	ListenSludgeClearPercentNode.super.registerPorts(self)

	self.flowOut_Below = self:addFlowOutput("OnBelow")
	self.valueInput_LevelItemId = self:addValueInput("levelItemId")
	self.valueInput_Percent = self:addValueInput("percent")
	self.valueOutput_ClearPercent = self:addValueOutput("clearPercent", function(flow)
		return self:getContextValue(flow, self.valueOutput_ClearPercent) or 0
	end)
	self.wasBelowKey = "wasBelow" .. self.nodeId
end

function ListenSludgeClearPercentNode:On_In_PortCalled(context, inputPortName)
	local space = context:getSpace()

	if not space then
		return
	end

	local sandboxId = context.sandboxId
	local sandbox = space.sandboxes[sandboxId]

	if not sandbox then
		return
	end

	local levelItemId = self:getContextValue(context, self.valueInput_LevelItemId)
	local threshold = self:getContextValue(context, self.valueInput_Percent) or 0

	context:setContextValue(self.wasBelowKey, false)

	local function listener(lid, clearPercent)
		if lid ~= levelItemId then
			return
		end

		self:setContextValue(context, self.valueOutput_ClearPercent, clearPercent)

		local isBelow = clearPercent < threshold
		local wasBelow = context:getContextValue(self.wasBelowKey)

		if isBelow and not wasBelow then
			context:setContextValue(self.wasBelowKey, true)
			self:removeTimer(context)
			self:checkDoOnce(context)
			self.flowOut_Below:call(context)
		elseif not isBelow and wasBelow then
			context:setContextValue(self.wasBelowKey, false)
		end
	end

	self:addSbEventListen(context, ServerEventConst.SLUDGE_CLEAR_PERCENT_CHANGE, listener)
end

return ListenSludgeClearPercentNode
