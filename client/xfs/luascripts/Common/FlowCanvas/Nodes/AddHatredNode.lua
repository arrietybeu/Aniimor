-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\AddHatredNode.lua

local Class = require("Core.Framework.Class")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local AddHatredNode = Class.LiteClass("AddHatredNode", FlowNode)

function AddHatredNode:ctor(nodeId, nodeData, graph)
	AddHatredNode.super.ctor(self, nodeId, nodeData, graph)
end

function AddHatredNode:registerPorts()
	AddHatredNode.super.registerPorts(self)
	self:addFlowInput("In", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)

	self.flowOut_Out = self:addFlowOutput("Out")
	self.valueInput_StaticId = self:addValueInput("StaticId")
	self.valueInput_HatredValue = self:addValueInput("HatredValue")
end

function AddHatredNode:On_In_PortCalled(context, inputPortName)
	local space = context:getSpace()

	if not space then
		return
	end

	local player = space and space:getMainPlayer()

	if not player then
		return
	end

	local staticId = self:getContextValue(context, self.valueInput_StaticId)
	local hatredValue = self:getContextValue(context, self.valueInput_HatredValue)
	local ent = space:getEntityByStaticId(staticId)

	if ent and ent.addHatred then
		ent:addHatred(player, hatredValue)
	end

	self.flowOut_Out:call(context)
end

return AddHatredNode
