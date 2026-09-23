-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\ServerDoAiBehaviourNode.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local AIControllerUtils = require("Common.Utils.AIControllerUtils")
local Class = require("Core.Framework.Class")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local AccessControl = require("Core.Framework.AccessControl")
local ServerDoAiBehaviourNode = Class.LiteClass("ServerDoAiBehaviourNode", FlowNode)
local Utils = require("Common.Utils.Utils")

function ServerDoAiBehaviourNode:ctor(nodeId, nodeData, graph)
	ServerDoAiBehaviourNode.super.ctor(self, nodeId, nodeData, graph)
end

function ServerDoAiBehaviourNode:registerPorts()
	self:addFlowInput("In", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)

	self.flowOut_Out = self:addFlowOutput("Out")
	self.staticId = self.nodeData.staticId
	self.behaviour = self.nodeData.behaviour
	self.paramDatas = Utils.deepCopyTable(self.nodeData.paramDatas) or {}
end

function ServerDoAiBehaviourNode:On_In_PortCalled(context, inputPortName)
	if self.staticId and self.behaviour and self.paramDatas then
		local space = context:getSpace()

		if not space then
			return
		end

		local entity = space:getEntityByStaticId(self.staticId)

		if not entity then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				self.logger:error("ServerDoAiBehaviourNode entity nil.sandboxId %s nodeId %s staticId %s behaviour %s", context.sandboxId, self.nodeId, self.staticId, self.behaviour)
			end

			return
		end

		if Utils.isSimpleMoveNpc(entity) then
			if self.behaviour == "LevelMsg_Route" then
				entity:clientMsg("RPC_SC_StartRouteById", self.paramDatas.routeId, self.paramDatas.loopTime)
			elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
				self.logger:error("@cyj ServerDoAiBehaviourNode simpleNpc entity 只支持SimpleRoute sandboxId %s nodeId %s staticId %s behaviour %s", context.sandboxId, self.nodeId, self.staticId, self.behaviour)
			end
		else
			AIControllerUtils.sendAIEvent(entity, self.behaviour, self.paramDatas)
		end

		self.flowOut_Out:call(context)
	end
end

return ServerDoAiBehaviourNode
