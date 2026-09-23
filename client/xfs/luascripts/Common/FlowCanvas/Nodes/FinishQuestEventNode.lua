-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\FinishQuestEventNode.lua

local Class = require("Core.Framework.Class")
local ServerEventConst = require("Const.ServerEventConst")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local FinishQuestEventNode = Class.LiteClass("FinishQuestEventNode", FlowNode)
local TriggerConst = require("Common.Const.TriggerConst")
local QuestEventData = require("Data.quest_event_data")

function FinishQuestEventNode:ctor(nodeId, nodeData, graph)
	FinishQuestEventNode.super.ctor(self, nodeId, nodeData, graph)
end

function FinishQuestEventNode:registerPorts()
	self.flowOut_Out = self:addFlowOutput("Out")
	self.valueInput_EventId = self:addValueInput("EventId")

	self:addFlowInput("In", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)
end

function FinishQuestEventNode:On_In_PortCalled(context, inputPortName)
	local eventId = self:getContextValue(context, self.valueInput_EventId)
	local sandboxId = context.sandboxId
	local space, player = self:_getSpaceAndPlayer(context)

	if not space then
		self.logger:info("@node FinishQuestEventNode/On_In_PortCalled space is nil eventId=%s sandboxId=%s", eventId, sandboxId)

		return
	end

	if not player then
		self.logger:info("@node FinishQuestEventNode/On_In_PortCalled main player is nil eventId=%s sandboxId=%s", eventId, sandboxId)

		return
	end

	local questEventData = QuestEventData[eventId]

	if not questEventData or questEventData.sandboxId ~= sandboxId then
		self.logger:error("@node FinishQuestEventNode/On_In_PortCalled eventId=%s not match sandboxId=%s", eventId, sandboxId)

		return
	end

	player:setSandboxFinishQuestEvent(sandboxId, eventId)
	player.triggerMap:onTrigger(TriggerConst.TRIGGER_TARGET_SANDBOX_QUEST_EVENT, sandboxId)
	self.flowOut_Out:call(context)
end

function FinishQuestEventNode:_getSpaceAndPlayer(context)
	local space = context:getSpace()

	if not space then
		return
	end

	local player = space:getMainPlayer()

	if not player then
		return
	end

	return space, player
end

return FinishQuestEventNode
