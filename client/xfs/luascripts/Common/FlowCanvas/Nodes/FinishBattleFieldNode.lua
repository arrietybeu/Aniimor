-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\FinishBattleFieldNode.lua

local Class = require("Core.Framework.Class")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local FinishBattleFieldNode = Class.LiteClass("FinishBattleFieldNode", FlowNode)

function FinishBattleFieldNode:ctor(nodeId, nodeData, graph)
	FinishBattleFieldNode.super.ctor(self, nodeId, nodeData, graph)
end

function FinishBattleFieldNode:registerPorts()
	self:addFlowInput("In", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)

	self.flowOut_Out = self:addFlowOutput("Out")
	self.valueInput_battleFieldId = self:addValueInput("battleFieldId")
end

function FinishBattleFieldNode:On_In_PortCalled(context, inputPortName)
	local space = context:getSpace()
	local battleFieldId = self:getContextValue(context, self.valueInput_battleFieldId)
	local ent = space:getEntityByStaticId(battleFieldId)

	if ent then
		ent:onBattleFieldFinish()
	end

	self.flowOut_Out:call(context)
end

return FinishBattleFieldNode
