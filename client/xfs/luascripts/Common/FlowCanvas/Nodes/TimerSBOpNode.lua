-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\TimerSBOpNode.lua

local Class = require("Core.Framework.Class")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local SandboxConst = require("Common.Const.SandboxConst")
local TimerSBOpNode = Class.LiteClass("TimerSBOpNode", FlowNode)
local Op = {
	Stop = 1,
	Play = 0,
	Reset = 2
}

function TimerSBOpNode:ctor(nodeId, nodeData, graph)
	TimerSBOpNode.super.ctor(self, nodeId, nodeData, graph)
end

function TimerSBOpNode:registerPorts()
	self:addFlowInput("In", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)

	self.flowOut_Out = self:addFlowOutput("Out")
	self.flowOut_Finished = self:addFlowOutput("Finished")
	self.flowOut_Cancel = self:addFlowOutput("Cancel")
	self.valueInput_LevelItemId = self:addValueInput("levelItemId")
end

function TimerSBOpNode:On_In_PortCalled(context, inputPortName)
	local space = context:getSpace()

	if not space then
		return
	end

	local levelItemId = self:getContextValue(context, self.valueInput_LevelItemId)
	local op = self.nodeData.op
	local levelItem = space:getLevelItem(context.sandboxId, levelItemId)

	if levelItem.className ~= "TimerSB" then
		self.logger:error("TimerSBOpNode:On_In_PortCalled: levelItem is not a TimerSB, className: ", levelItem.className)
		self.flowOut_Out:call(context)

		return
	end

	if levelItem then
		if op == Op.Play then
			levelItem:play(function(isCancel)
				if isCancel then
					self.flowOut_Cancel:call(context)
				else
					self.flowOut_Finished:call(context)
				end
			end)
		elseif op == Op.Stop then
			levelItem:stop()
		elseif op == Op.Reset then
			levelItem:reset()
		else
			self.logger:error("TimerSBOpNode:On_In_PortCalled: unknown operation: ", op)
			self.flowOut_Out:call(context)

			return
		end

		self.flowOut_Out:call(context)
	end
end

return TimerSBOpNode
