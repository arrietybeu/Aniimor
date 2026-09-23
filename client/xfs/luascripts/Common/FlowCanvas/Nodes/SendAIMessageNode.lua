-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\SendAIMessageNode.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local AIControllerUtils = require("Common.Utils.AIControllerUtils")
local Class = require("Core.Framework.Class")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local SendAIMessageNode = Class.LiteClass("SendAIMessageNode", FlowNode)

function SendAIMessageNode:ctor(nodeId, nodeData, graph)
	SendAIMessageNode.super.ctor(self, nodeId, nodeData, graph)
end

function SendAIMessageNode:registerPorts()
	self:addFlowInput("In", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)

	self.flowOut_Out = self:addFlowOutput("Out")
	self.valueInput_StaticId = self:addValueInput("StaticId")
	self.valueInput_Msg = self:addValueInput("Msg")
end

function SendAIMessageNode:On_In_PortCalled(context, inputPortName)
	local staticId = self:getContextValue(context, self.valueInput_StaticId)
	local msg = self:getContextValue(context, self.valueInput_Msg)

	if staticId and msg then
		local space = context:getSpace()

		if not space then
			return
		end

		local entity = space:getEntityByStaticId(staticId)

		if entity then
			AIControllerUtils.sendAIEvent(entity, "LevelMsgTrigger" .. msg, {
				filtKey = msg
			})
		elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("SendAIMessageNode entity nil. NodeId %s staticId %s msg %s", self.nodeId, staticId, msg)
		end

		self.flowOut_Out:call(context)
	end
end

return SendAIMessageNode
