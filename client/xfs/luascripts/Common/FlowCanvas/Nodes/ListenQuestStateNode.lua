-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\ListenQuestStateNode.lua

local Class = require("Core.Framework.Class")
local ServerEventConst = require("Const.ServerEventConst")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local ListenQuestStateNode = Class.LiteClass("ListenQuestStateNode", FlowNode)
local QuestConst = require("Common.Const.QuestConst")
local QuestBase = require("Data.Quest.quest_base")

function ListenQuestStateNode:ctor(nodeId, nodeData, graph)
	ListenQuestStateNode.super.ctor(self, nodeId, nodeData, graph)
end

function ListenQuestStateNode:registerPorts()
	self.flowOut_Out = self:addFlowOutput("Out")
	self.flowOut_Init = self:addFlowOutput("Init")
	self.valueInput_QuestId = self:addValueInput("QuestId")

	self:addFlowInput("In", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)

	self.valueOutput_State = self:addValueOutput("State", function(context)
		return self:Get_State_Value(context)
	end)
end

function ListenQuestStateNode:Get_State_Value(context)
	local sandboxId = context.sandboxId
	local questId = self:getContextValue(context, self.valueInput_QuestId)

	if questId == nil then
		self.logger:error("@node ListenQuestStateNode/Get_State_Value questId is nil questId=%s sandboxId=%s", questId, sandboxId)

		return
	end

	local _, player = self:_getSpaceAndPlayer(context)

	if not player then
		self.logger:info("@node ListenQuestStateNode/Get_State_Value main player is nil questId=%s sandboxId=%s", questId, sandboxId)

		return
	end

	local qState, _ = player:_getQuestState(questId)

	self.logger:debug("@node ListenQuestStateNode/Get_State_Value questId=%s state=%s sandboxId=%s", questId, qState, sandboxId)

	return qState
end

function ListenQuestStateNode:On_In_PortCalled(context, inputPortName)
	local questId = self:getContextValue(context, self.valueInput_QuestId)
	local qdd = QuestBase[questId]

	if qdd == nil then
		self.logger:error("@node ListenQuestStateNode/On_In_PortCalled quest base is nil questId=%s", questId)

		return
	end

	local sandboxId = context.sandboxId
	local space, player = self:_getSpaceAndPlayer(context)

	if not space then
		self.logger:info("@node ListenQuestStateNode/On_In_PortCalled space is nil questId=%s sandboxId=%s", questId, sandboxId)

		return
	end

	if not player then
		self.logger:info("@node ListenQuestStateNode/On_In_PortCalled main player is nil questId=%s sandboxId=%s", questId, sandboxId)

		return
	end

	local stateBefore = player:_getQuestState(questId)

	self.flowOut_Init:call(context)

	local function listener(args)
		if args.questId ~= questId then
			return
		end

		local innerSpace, innerPlayer = self:_getSpaceAndPlayer(context)

		if not innerSpace or not innerPlayer then
			self.logger:error("@node ListenQuestStateNode/On_In_PortCalled callback space or main player is nil questId=%s sandboxId=%s", questId, sandboxId)

			return
		end

		self:_onQuestStateChange(context, args.questId, sandboxId, args.state, innerPlayer)
	end

	local questEventName = ServerEventConst.QUEST_STATE_CHANGE .. questId

	self:addEventListen(context, questEventName, listener)

	local _, curPlayer = self:_getSpaceAndPlayer(context)

	if curPlayer then
		local stateAfter = curPlayer:_getQuestState(questId)

		if stateAfter ~= stateBefore then
			self:_onQuestStateChange(context, questId, sandboxId, stateAfter, curPlayer)
		end
	end
end

function ListenQuestStateNode:_onQuestStateChange(context, questId, sandboxId, qState, player)
	self.flowOut_Out:call(context)
end

function ListenQuestStateNode:_getSpaceAndPlayer(context)
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

function ListenQuestStateNode:addEventListen(context, eventName, listener)
	local space = context:getSpace()

	if not space then
		return
	end

	context:registerSpaceEventListener(self.nodeId, eventName, listener)
end

function ListenQuestStateNode:removeListen(context)
	context:unregisterSpaceEventListeners(self.nodeId)
end

return ListenQuestStateNode
