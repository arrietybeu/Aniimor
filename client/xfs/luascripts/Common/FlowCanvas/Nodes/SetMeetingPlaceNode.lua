-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\SetMeetingPlaceNode.lua

local Class = require("Core.Framework.Class")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local SandboxConst = require("Common.Const.SandboxConst")
local SetMeetingPlaceNode = Class.LiteClass("SetMeetingPlaceNode", FlowNode)

function SetMeetingPlaceNode:ctor(nodeId, nodeData, graph)
	SetMeetingPlaceNode.super.ctor(self, nodeId, nodeData, graph)
end

function SetMeetingPlaceNode:registerPorts()
	self:addFlowInput("In", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)

	self.flowOut_Out = self:addFlowOutput("Out")
	self.valueInput_LevelItemId = self:addValueInput("levelItemId")
end

function SetMeetingPlaceNode:On_In_PortCalled(context, inputPortName)
	local space = context:getSpace()

	if not space then
		return
	end

	local levelItemId = self:getContextValue(context, self.valueInput_LevelItemId)
	local levelItem = space:getLevelItem(context.sandboxId, levelItemId)

	if levelItem then
		if levelItem.teleport then
			levelItem:teleport()
		end

		self.flowOut_Out:call(context)
	end
end

return SetMeetingPlaceNode
