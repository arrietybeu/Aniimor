-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\CreateSandboxNode.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local ListenBaseNode = require("Common.FlowCanvas.Nodes.ListenBaseNode")
local ServerEventConst = require("Const.ServerEventConst")
local CreateSandboxNode = Class.LiteClass("CreateSandboxNode", ListenBaseNode)

function CreateSandboxNode:ctor(nodeId, nodeData, graph)
	CreateSandboxNode.super.ctor(self, nodeId, nodeData, graph)
end

function CreateSandboxNode:registerPorts()
	CreateSandboxNode.super.registerPorts(self)
	self:addFlowInput("In", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)

	self.valueInput_SandboxId = self:addValueInput("SandboxId")
	self.flowOut_Success = self:addFlowOutput("Success")
	self.flowOut_Fail = self:addFlowOutput("Fail")
end

function CreateSandboxNode:On_In_PortCalled(context, inputPortName)
	self.linkedSandboxId = self:getContextValue(context, self.valueInput_SandboxId)

	self:activeLinkedSandbox(context)
end

function CreateSandboxNode:activeLinkedSandbox(context)
	local space = context:getSpace()

	if not space then
		return
	end

	local sandboxId = context.sandboxId
	local sandbox = space.sandboxes[sandboxId]

	if not sandbox then
		return
	end

	if not self.linkedSandboxId or self.linkedSandboxId == 0 then
		return
	end

	local eventName = ServerEventConst.CREATE_SANDBOX .. sandboxId

	local function listener(args)
		self:removeTimer(context)
		self:checkDoOnce(context)
		self:closeLinkedSandbox(context)

		if args.result then
			self.flowOut_Success:call(context)
		else
			self.flowOut_Fail:call(context)
		end
	end

	self:addEventListen(context, eventName, listener)

	if space ~= nil and space.manualSandboxLoad and space.resetSandbox then
		space:resetSandbox(self.linkedSandboxId)
		space:manualSandboxLoad(self.linkedSandboxId)
	end
end

function CreateSandboxNode:closeLinkedSandbox(context)
	local space = context:getSpace()

	if not self.linkedSandboxId then
		return
	end

	if space ~= nil and space.manualSandboxUnLoad then
		space:manualSandboxUnLoad(self.linkedSandboxId)
	end
end

return CreateSandboxNode
