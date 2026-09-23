-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\PetChallengeNode.lua

local Class = require("Core.Framework.Class")
local ListenBaseNode = require("Common.FlowCanvas.Nodes.ListenBaseNode")
local PetChallengeNode = Class.LiteClass("PetChallengeNode", ListenBaseNode)
local ServerEventConst = require("Const.ServerEventConst")
local Const = require("Common.Const.Const")

function PetChallengeNode:ctor(nodeId, nodeData, graph)
	PetChallengeNode.super.ctor(self, nodeId, nodeData, graph)
end

function PetChallengeNode:registerPorts()
	PetChallengeNode.super.registerPorts(self)
	self:addFlowInput("In", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)

	self.failRadius = self.nodeData.FailRadius
	self.valueInput_Duration = self:addValueInput("Duration")
	self.valueInput_DialogueGroupId = self:addValueInput("DialogueGroupId")
	self.valueInput_SheepSpawnerId = self:addValueInput("SheepSpawnerId")
	self.valueInput_SheepCount = self:addValueInput("SheepCount")
	self.valueInput_ChallengeId = self:addValueInput("ChallengeId")
	self.valueInput_Center = self:addValueInput("Center")
	self.flowOut_Success = self:addFlowOutput("Success")
	self.flowOut_Fail = self:addFlowOutput("Fail")
end

function PetChallengeNode:On_In_PortCalled(context, inputPortName)
	local space = context:getSpace()

	if not space then
		return
	end

	local sandboxId = context.sandboxId
	local sandbox = space.sandboxes[sandboxId]

	if not sandbox then
		return
	end

	sandbox:createGamePlay(Const.GAME_PLAY_PET_CHALLENGE, {
		failRadius = self.failRadius,
		center = self:getContextValue(context, self.valueInput_Center),
		duration = self:getContextValue(context, self.valueInput_Duration),
		dialogueGroupId = self:getContextValue(context, self.valueInput_DialogueGroupId),
		sheepSpawnerId = self:getContextValue(context, self.valueInput_SheepSpawnerId),
		sheepCount = self:getContextValue(context, self.valueInput_SheepCount),
		challengeId = self:getContextValue(context, self.valueInput_ChallengeId)
	})

	local eventName = ServerEventConst.PET_CHALLENGE .. sandboxId

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

return PetChallengeNode
