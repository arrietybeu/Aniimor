-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\ListenEnterMagnesisNode.lua

local Class = require("Core.Framework.Class")
local ServerEventConst = require("Const.ServerEventConst")
local ListenBaseNode = require("Common.FlowCanvas.Nodes.ListenBaseNode")
local ListenEnterMagnesisNode = Class.LiteClass("ListenLevelItemFieldChangeNode", ListenBaseNode)

function ListenEnterMagnesisNode:ctor(nodeId, nodeData, graph)
	ListenEnterMagnesisNode.super.ctor(self, nodeId, nodeData, graph)
end

function ListenEnterMagnesisNode:registerPorts()
	ListenEnterMagnesisNode.super.registerPorts(self)

	self.valueInput_StaticId = self:addValueInput("StaticId")
	self.flowOut_Out = self:addFlowOutput("Out")
end

function ListenEnterMagnesisNode:On_In_PortCalled(context, inputPortName)
	local space = context:getSpace()

	if not space then
		return
	end

	local staticId = self:getContextValue(context, self.valueInput_StaticId)
	local eventName = ServerEventConst.ENTER_MAGNESIS_CONTROL .. staticId

	local function listener(args)
		self.flowOut_Out:call(context)
	end

	self:addEventListen(context, eventName, listener)
end

return ListenEnterMagnesisNode
