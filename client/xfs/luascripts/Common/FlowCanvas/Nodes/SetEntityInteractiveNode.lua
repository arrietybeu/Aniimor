-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\SetEntityInteractiveNode.lua

local Class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local SetEntityInteractiveNode = Class.LiteClass("SetEntityInteractiveNode", FlowNode)

function SetEntityInteractiveNode:ctor(nodeId, nodeData, graph)
	SetEntityInteractiveNode.super.ctor(self, nodeId, nodeData, graph)
end

function SetEntityInteractiveNode:registerPorts()
	self:addFlowInput("In", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)

	self.flowOut_Out = self:addFlowOutput("Out")
	self.valueInput_staticId = self:addValueInput("staticId")
	self.valueInput_enable = self:addValueInput("enable")
end

function SetEntityInteractiveNode:On_In_PortCalled(context, inputPortName)
	local staticId = self:getContextValue(context, self.valueInput_staticId)
	local enable = self:getContextValue(context, self.valueInput_enable)

	if staticId and staticId > 0 then
		local space = context:getSpace()
		local entity = space:getEntityByStaticId(staticId)

		if entity and entity.setLevelCondition then
			if enable then
				entity:setLevelCondition(Const.LEVEL_CONDITION_ON)
			else
				entity:setLevelCondition(Const.LEVEL_CONDITION_OFF)
			end
		end
	end

	self.flowOut_Out:call(context)
end

return SetEntityInteractiveNode
