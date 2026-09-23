-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\ListenTriggerNode.lua

local Class = require("Core.Framework.Class")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local SandboxListenBaseNode = require("Common.FlowCanvas.Nodes.SandboxListenBaseNode")
local ListenTriggerNode = Class.LiteClass("ListenTriggerNode", SandboxListenBaseNode)
local SceneUtils = require("Common.Utils.SceneUtils")
local ServerEventConst = require("Const.ServerEventConst")

function ListenTriggerNode:ctor(nodeId, nodeData, graph)
	ListenTriggerNode.super.ctor(self, nodeId, nodeData, graph)
end

function ListenTriggerNode:registerPorts()
	ListenTriggerNode.super.registerPorts(self)

	self.flowOut_Enter = self:addFlowOutput("OnEnter")
	self.flowOut_Exit = self:addFlowOutput("OnExit")
	self.valueInput_LevelItemId = self:addValueInput("levelItemId")
	self.valueOutput_actorId = self:addValueOutput("actorId", function(flow)
		return self:getContextValue(flow, self.valueOutput_actorId) or -1
	end)
	self.valueOutput_entityId = self:addValueOutput("entityId", function(flow)
		return self:getContextValue(flow, self.valueOutput_entityId)
	end)
end

function ListenTriggerNode:On_In_PortCalled(context, inputPortName)
	local space = context:getSpace()

	if not space then
		return
	end

	local sandboxId = context.sandboxId
	local sandbox = space.sandboxes[sandboxId]

	if not sandbox then
		return
	end

	local levelItemId = self:getContextValue(context, self.valueInput_LevelItemId)

	local function listener(lid, isEnter, actorId)
		if lid ~= levelItemId then
			return
		end

		self:removeTimer(context)
		self:checkDoOnce(context)
		self:setContextValue(context, self.valueOutput_actorId, actorId)

		local ent = pg.getEntityByActorId(actorId)

		self:setContextValue(context, self.valueOutput_entityId, ent and ent.id)

		if isEnter then
			self.flowOut_Enter:call(context)
		else
			self.flowOut_Exit:call(context)
		end
	end

	self:addSbEventListen(context, "TRIGGER_ENTER", listener)
end

return ListenTriggerNode
