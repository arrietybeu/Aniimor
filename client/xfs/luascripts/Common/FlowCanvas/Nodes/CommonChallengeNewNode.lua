-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\CommonChallengeNewNode.lua

local Class = require("Core.Framework.Class")
local ListenBaseNode = require("Common.FlowCanvas.Nodes.ListenBaseNode")
local CommonChallengeNewNode = Class.LiteClass("CommonChallengeNewNode", ListenBaseNode)
local ServerEventConst = require("Const.ServerEventConst")
local Const = require("Common.Const.Const")

function CommonChallengeNewNode:ctor(nodeId, nodeData, graph)
	CommonChallengeNewNode.super.ctor(self, nodeId, nodeData, graph)
end

function CommonChallengeNewNode:registerPorts()
	CommonChallengeNewNode.super.registerPorts(self)
	self:addFlowInput("In", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)

	self.failRadius = self.nodeData.FailRadius
	self.spawnerDict = self.nodeData.SpawnerDict
	self.linkedSandboxId = self.nodeData.SandboxId
	self.valueInput_Duration = self:addValueInput("Duration")
	self.valueInput_DialogueGroupId = self:addValueInput("DialogueGroupId")
	self.valueInput_Phase = self:addValueInput("Phase")
	self.valueInput_FailPhase = self:addValueInput("FailPhase")
	self.valueInput_ChallengeId = self:addValueInput("ChallengeId")
	self.valueInput_Center = self:addValueInput("Center")
	self.valueInput_ForbidCombat = self:addValueInput("ForbidCombat")
	self.valueInput_EthnicGroupList = self:addValueInput("EthnicGroupList")
	self.flowOut_Success = self:addFlowOutput("Success")
	self.flowOut_Fail = self:addFlowOutput("Fail")
end

function CommonChallengeNewNode:On_In_PortCalled(context, inputPortName)
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
		linkedSandboxId = self.linkedSandboxId,
		spawnerDict = self.spawnerDict,
		center = self:getContextValue(context, self.valueInput_Center),
		duration = self:getContextValue(context, self.valueInput_Duration),
		dialogueGroupId = self:getContextValue(context, self.valueInput_DialogueGroupId),
		phase = self:getContextValue(context, self.valueInput_Phase),
		failPhase = self:getContextValue(context, self.valueInput_FailPhase),
		challengeId = self:getContextValue(context, self.valueInput_ChallengeId),
		ethnicGroupList = self:getContextValue(context, self.valueInput_EthnicGroupList),
		forbidCombat = self:getContextValue(context, self.valueInput_ForbidCombat)
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

return CommonChallengeNewNode
