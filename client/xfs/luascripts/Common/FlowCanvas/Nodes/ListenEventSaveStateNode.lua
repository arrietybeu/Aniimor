-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\ListenEventSaveStateNode.lua

local Class = require("Core.Framework.Class")
local ListenBaseNode = require("Common.FlowCanvas.Nodes.ListenBaseNode")
local AccessControl = require("Core.Framework.AccessControl")
local EventStateCheck = require("Common.FlowCanvas.EventStateCheck")
local ListenEventSaveStateNode = Class.LiteClass("ListenEventSaveStateNode", ListenBaseNode)

function ListenEventSaveStateNode:ctor(nodeId, nodeData, graph)
	ListenEventSaveStateNode.super.ctor(self, nodeId, nodeData, graph)
end

function ListenEventSaveStateNode:registerPorts()
	ListenEventSaveStateNode.super.registerPorts(self)

	self.flowOut_Out = self:addFlowOutput("Out")
	self.flowOut_Init = self:addFlowOutput("Init")
	self.valueInput_EventName = self:addValueInput("EventName")
	self.eventParams = self.nodeData.eventParams or {}
	self.firstIn = "firstIn" .. self.nodeId
end

function ListenEventSaveStateNode:On_In_PortCalled(context, inputPortName)
	local uid = self.uid

	if not uid then
		return
	end

	local space = context:getSpace()

	if not space then
		return
	end

	local sandboxId = context.sandboxId
	local sandbox = space.sandboxes[sandboxId]

	if not sandbox then
		return
	end

	local firstIn = context:getContextValue(self.firstIn)

	if sandbox.eventState[uid] and not firstIn then
		context:setContextValue(self.firstIn, true)
		self.flowOut_Init:call(context)
	end

	local eventName = self:getContextValue(context, self.valueInput_EventName)

	if not eventName then
		return
	end

	local player = space.ownerPlayer

	if player then
		local func = EventStateCheck[eventName]

		if func and func(player, self.eventParams) then
			self.flowOut_Out:call(context)
		end
	end

	local function listener(args)
		args = args or {}

		if args.sandboxId and args.sandboxId ~= sandboxId then
			return
		end

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

		sandbox.eventState[uid] = true

		space:saveSandboxEventState(sandboxId)
		self:removeTimer(context)
		self:checkDoOnce(context)
		self.flowOut_Out:call(context)
	end

	self:addEventListen(context, eventName, listener)
end

return ListenEventSaveStateNode
