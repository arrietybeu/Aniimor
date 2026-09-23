-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\CheckQuestTriggerNode.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local CheckQuestTriggerNode = Class.LiteClass("CheckQuestTriggerNode", FlowNode)
local TriggerUtils = require("Common.Utils.TriggerUtils")

function CheckQuestTriggerNode:ctor(nodeId, nodeData, graph)
	CheckQuestTriggerNode.super.ctor(self, nodeId, nodeData, graph)
end

function CheckQuestTriggerNode:registerPorts()
	self:addFlowInput("Check", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)

	self.flowOut_Pass = self:addFlowOutput("Pass")
	self.flowOut_Failed = self:addFlowOutput("Failed")
	self.valueInput_Condition = self:addValueInput("condition")
end

function CheckQuestTriggerNode:On_In_PortCalled(context, inputPortName)
	local space = context:getSpace()
	local condition = self:getContextValue(context, self.valueInput_Condition)

	if not space or not condition then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("QuestTriggerNode:On_Check_PortCalled invalid param:", self.nodeId, condition)
		end

		self.flowOut_Failed:call(context)

		return
	end

	local mainPlayer = space.getMainPlayer and space:getMainPlayer()

	if mainPlayer then
		if TriggerUtils.checkSingleStatusCondition(mainPlayer, condition) then
			self.flowOut_Pass:call(context)
		else
			self.flowOut_Failed:call(context)
		end
	else
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("QuestTriggerNode:space.getMainPlayer is nil:", self.nodeId)
		end

		self.flowOut_Failed:call(context)
	end
end

return CheckQuestTriggerNode
