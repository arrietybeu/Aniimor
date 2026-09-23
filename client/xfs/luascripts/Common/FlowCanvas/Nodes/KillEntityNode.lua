-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\KillEntityNode.lua

local Class = require("Core.Framework.Class")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local KillEntityNode = Class.LiteClass("KillEntityNode", FlowNode)
local Utils = require("Common.Utils.Utils")

function KillEntityNode:ctor(nodeId, nodeData, graph)
	KillEntityNode.super.ctor(self, nodeId, nodeData, graph)
end

function KillEntityNode:registerPorts()
	self:addFlowInput("In", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)

	self.flowOut_Out = self:addFlowOutput("Out")
	self.valueInput_staticId = self:addValueInput("staticId")
end

function KillEntityNode:On_In_PortCalled(context, inputPortName)
	local staticId = self:getContextValue(context, self.valueInput_staticId)

	if staticId then
		local space = context:getSpace()
		local ent = space:getEntityByStaticId(staticId)

		if ent then
			if ent.doDeath then
				ent:doDeath()
			elseif Utils.checkClient() then
				local ClientUtils = require("Utils.ClientUtils")

				ClientUtils.safeDestroy(ent)
			else
				ent:destroy()
			end
		end
	end

	self.flowOut_Out:call(context)
end

return KillEntityNode
