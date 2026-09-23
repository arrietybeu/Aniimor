-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\ListenerEventNode.lua

local Class = require("Core.Framework.Class")
local ListenBaseNode = require("Common.FlowCanvas.Nodes.ListenBaseNode")
local AccessControl = require("Core.Framework.AccessControl")
local EventStateCheck = require("Common.FlowCanvas.EventStateCheck")
local ListenerEventNode = Class.LiteClass("ListenerEventNode", ListenBaseNode)

function ListenerEventNode:ctor(nodeId, nodeData, graph)
	ListenerEventNode.super.ctor(self, nodeId, nodeData, graph)
end

function ListenerEventNode:registerPorts()
	ListenerEventNode.super.registerPorts(self)

	self.flowOut_Out = self:addFlowOutput("Out")
	self.valueInput_EventName = self:addValueInput("EventName")
	self.eventParams = self.nodeData.eventParams or {}
end

function ListenerEventNode:On_In_PortCalled(context, inputPortName)
	local space = context:getSpace()

	if not space then
		return
	end

	local eventName = self:getContextValue(context, self.valueInput_EventName) or self.nodeData.EventName
	local player = space.ownerPlayer

	if player then
		local func = EventStateCheck[eventName]

		if func and func(player, self.eventParams) then
			self.flowOut_Out:call(context)
		end
	end

	local function listener(args)
		args = args or {}

		for k, v in pairs(self.eventParams) do
			local confValue = args[k]

			if confValue ~= v then
				return
			end
		end

		for k, v in pairs(args) do
			if self[k] then
				self:setContextValue(context, self[k], v)
			end
		end

		self:removeTimer(context)
		self:checkDoOnce(context)
		self.flowOut_Out:call(context)
	end

	self:addEventListen(context, eventName, listener)
end

return ListenerEventNode
