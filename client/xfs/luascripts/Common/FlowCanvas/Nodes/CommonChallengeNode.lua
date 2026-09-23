-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\CommonChallengeNode.lua

local Class = require("Core.Framework.Class")
local ListenBaseNode = require("Common.FlowCanvas.Nodes.ListenBaseNode")
local CommonChallengeNode = Class.LiteClass("CommonChallengeNode", ListenBaseNode)
local ServerEventConst = require("Const.ServerEventConst")
local Const = require("Common.Const.Const")

function CommonChallengeNode:ctor(nodeId, nodeData, graph)
	CommonChallengeNode.super.ctor(self, nodeId, nodeData, graph)
end

function CommonChallengeNode:registerPorts()
	CommonChallengeNode.super.registerPorts(self)
	self:addFlowInput("In", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)

	self.failRadius = self.nodeData.FailRadius
	self.valueInput_Duration = self:addValueInput("Duration")
	self.valueInput_DialogueGroupId = self:addValueInput("DialogueGroupId")
	self.valueInput_SpawnerIdList = self:addValueInput("SpawnerIdList")
	self.valueInput_Phase = self:addValueInput("Phase")
	self.valueInput_ChallengeId = self:addValueInput("ChallengeId")
	self.valueInput_Center = self:addValueInput("Center")
	self.valueInput_EthnicGroupList = self:addValueInput("EthnicGroupList")
	self.flowOut_Success = self:addFlowOutput("Success")
	self.flowOut_Fail = self:addFlowOutput("Fail")
end

function CommonChallengeNode:On_In_PortCalled(context, inputPortName)
	local space = context:getSpace()

	if not space then
		return
	end

	local sandboxId = context.sandboxId
	local sandbox = space.sandboxes[sandboxId]

	if not sandbox then
		return
	end

	sandbox:createGamePlay(Const.GAME_PLAY_COMMON_CHALLENGE, {
		failRadius = self.failRadius,
		center = self:getContextValue(context, self.valueInput_Center),
		duration = self:getContextValue(context, self.valueInput_Duration),
		dialogueGroupId = self:getContextValue(context, self.valueInput_DialogueGroupId),
		spawnerIdList = self:getContextValue(context, self.valueInput_SpawnerIdList),
		phase = self:getContextValue(context, self.valueInput_Phase),
		challengeId = self:getContextValue(context, self.valueInput_ChallengeId),
		ethnicGroupList = self:getContextValue(context, self.valueInput_EthnicGroupList)
	})

	local eventName = ServerEventConst.COMMON_CHALLENGE .. sandboxId

	local function listener(args)
		self:removeTimer(context)
		self:checkDoOnce(context)

		if args.result then
			self.flowOut_Success:call(context)
		else
			self.flowOut_Fail:call(context)
		end
	end

	self:addEventListen(context, eventName, listener)
end

return CommonChallengeNode
