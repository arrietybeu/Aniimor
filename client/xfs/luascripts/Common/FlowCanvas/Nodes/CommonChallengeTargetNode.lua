-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\CommonChallengeTargetNode.lua

local Class = require("Core.Framework.Class")
local ListenBaseNode = require("Common.FlowCanvas.Nodes.ListenBaseNode")
local CommonChallengeTargetNode = Class.LiteClass("CommonChallengeTargetNode", ListenBaseNode)
local ServerEventConst = require("Const.ServerEventConst")
local Const = require("Common.Const.Const")

function CommonChallengeTargetNode:ctor(nodeId, nodeData, graph)
	CommonChallengeTargetNode.super.ctor(self, nodeId, nodeData, graph)
end

function CommonChallengeTargetNode:registerPorts()
	CommonChallengeTargetNode.super.registerPorts(self)
	self:addFlowInput("In", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)

	self.curPhase = 1

	self:addValueOutput("Value", function(context, inputPortName)
		return self.curPhase
	end)

	self.failRadius = self.nodeData.FailRadius
	self.valueInput_DialogueGroupId = self:addValueInput("DialogueGroupId")
	self.valueInput_Phase = self:addValueInput("Phase")
	self.valueInput_FailPhase = self:addValueInput("FailPhase")
	self.valueInput_ChallengeId = self:addValueInput("ChallengeId")
	self.valueInput_Center = self:addValueInput("Center")
	self.valueInput_ForbidCombat = self:addValueInput("ForbidCombat")
	self.valueInput_EthnicGroupList = self:addValueInput("EthnicGroupList")
	self.flowOut_Success = self:addFlowOutput("Success")
	self.flowOut_Fail = self:addFlowOutput("Fail")
	self.flowOut_NextPhase = self:addFlowOutput("NextPhase")
end

function CommonChallengeTargetNode:On_In_PortCalled(context, inputPortName)
	local space = context:getSpace()

	if not space then
		return
	end

	local sandboxId = context.sandboxId
	local sandbox = space.sandboxes[sandboxId]

	if not sandbox then
		return
	end

	self.curPhase = 1

	sandbox:createGamePlay(Const.GAME_PLAY_TARGET_COMMON_CHALLENGE, {
		failRadius = self.failRadius,
		center = self:getContextValue(context, self.valueInput_Center),
		dialogueGroupId = self:getContextValue(context, self.valueInput_DialogueGroupId),
		phase = self:getContextValue(context, self.valueInput_Phase),
		failPhase = self:getContextValue(context, self.valueInput_FailPhase),
		challengeId = self:getContextValue(context, self.valueInput_ChallengeId),
		ethnicGroupList = self:getContextValue(context, self.valueInput_EthnicGroupList),
		forbidCombat = self:getContextValue(context, self.valueInput_ForbidCombat),
		curPhase = self.curPhase
	})

	self.successPhase = self:getContextValue(context, self.valueInput_Phase)
	self.failPhase = self:getContextValue(context, self.valueInput_FailPhase)

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

	local eventName2 = ServerEventConst.NEXT_PHASE .. sandboxId

	local function listener2(args)
		if args.phase < self.successPhase and args.phase >= self.curPhase then
			self.curPhase = args.phase

			self.flowOut_NextPhase:call(context)
		end
	end

	self:addEventListen(context, eventName2, listener2)
end

return CommonChallengeTargetNode
