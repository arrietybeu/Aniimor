-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\ListenInteractTriggerNode.lua

local Class = require("Core.Framework.Class")
local ServerEventConst = require("Const.ServerEventConst")
local ListenBaseNode = require("Common.FlowCanvas.Nodes.ListenBaseNode")
local ListenInteractTriggerNode = Class.LiteClass("ListenInteractTriggerNode", ListenBaseNode)

function ListenInteractTriggerNode:ctor(nodeId, nodeData, graph)
	ListenInteractTriggerNode.super.ctor(self, nodeId, nodeData, graph)
end

function ListenInteractTriggerNode:registerPorts()
	ListenInteractTriggerNode.super.registerPorts(self)

	self.flowOut_Out = self:addFlowOutput("Out")
	self.flowOut_OnTrigger = self:addFlowOutput("OnTrigger")
	self.valueInput_InteractId = self:addValueInput("InteractId")
	self.valueInput_State = self:addValueInput("State")
end

function ListenInteractTriggerNode:On_In_PortCalled(context, inputPortName)
	local interactId = self:getContextValue(context, self.valueInput_InteractId)
	local state = self:getContextValue(context, self.valueInput_State)
	local eventName = ServerEventConst.LEVELITEM_INTERACT_TRIGGER .. interactId

	local function listener(args)
		if args.state == state then
			self.flowOut_OnTrigger:call(context)
		end
	end

	self:addEventListen(context, eventName, listener)
	self.flowOut_Out:call(context)
end

return ListenInteractTriggerNode
