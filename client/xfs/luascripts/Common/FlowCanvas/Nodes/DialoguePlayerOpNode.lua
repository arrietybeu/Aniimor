-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\DialoguePlayerOpNode.lua

local Class = require("Core.Framework.Class")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local SandboxConst = require("Common.Const.SandboxConst")
local DialoguePlayerOpNode = Class.LiteClass("DialoguePlayerOpNode", FlowNode)
local Op = {
	Play = 0,
	Stop = 1
}

function DialoguePlayerOpNode:ctor(nodeId, nodeData, graph)
	DialoguePlayerOpNode.super.ctor(self, nodeId, nodeData, graph)
end

function DialoguePlayerOpNode:registerPorts()
	self:addFlowInput("In", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)

	self.flowOut_Out = self:addFlowOutput("Out")
	self.flowOut_Finished = self:addFlowOutput("Finished")
	self.valueInput_LevelItemId = self:addValueInput("levelItemId")
	self.finishRetValueKey = "finishRetValue" .. self.nodeId

	self:addValueOutput("FinishRetValue", function(context)
		return context:getContextValue(self.finishRetValueKey)
	end)
end

function DialoguePlayerOpNode:On_In_PortCalled(context, inputPortName)
	local space = context:getSpace()

	if not space then
		return
	end

	local levelItemId = self:getContextValue(context, self.valueInput_LevelItemId)
	local op = self.nodeData.op
	local levelItem = space:getLevelItem(context.sandboxId, levelItemId)

	if levelItem.className ~= "DialoguePlayer" and levelItem.className ~= "TimelineContainer" then
		self.logger:error("DialoguePlayerOpNode:On_In_PortCalled: levelItem is not a DialoguePlayer, className: ", levelItem.className)
		self.flowOut_Out:call(context)

		return
	end

	if levelItem then
		if op == Op.Play then
			levelItem:play(function(result)
				context:setContextValue(self.finishRetValueKey, result)
				self.flowOut_Finished:call(context)
			end)
		elseif op == Op.Stop then
			levelItem:stop()
		else
			self.logger:error("DialoguePlayerOpNode:On_In_PortCalled: unknown operation: ", op)
			self.flowOut_Out:call(context)

			return
		end

		self.flowOut_Out:call(context)
	end
end

return DialoguePlayerOpNode
