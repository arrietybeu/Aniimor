-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\GroupBehavior\\CallFriends\\GBT_Formation.lua

local Class = require("Core.Framework.Class")
local GroupBehaviourTacheBase = require("Common.AI.GroupBehavior.GroupBehaviourTacheBase")
local GroupBehaviourConst = require("Common.Const.GroupBehaviourConst")
local TacheDefine = GroupBehaviourConst.TacheDefine
local GBT_Formation = Class.LiteClass("GBT_Formation", GroupBehaviourTacheBase)

function GBT_Formation:ctor(owner, stateKey)
	GroupBehaviourTacheBase.ctor(self, owner, stateKey)

	self.timeoutTime = -1
	self.envObj = nil
	self.playerIndex = -1

	local LuaCSharpArr = require("Utils.LuaCSharpArr")

	self.positions = LuaCSharpArr.New(24)
	self.positionsAccess = self.positions:GetCSharpAccess()
	self.posCount = 0
	self.posArray = {}
end

function GBT_Formation:onDestroy()
	GroupBehaviourTacheBase.onDestroy(self)

	self.positionsAccess = nil

	self.positions:DestroyCSharpAccess()
end

function GBT_Formation:_execStart()
	return
end

function GBT_Formation:onEnter(controller, oldState)
	GroupBehaviourTacheBase.onEnter(self, controller, oldState)

	self.envObj = nil
	self.playerIndex = -1
end

function GBT_Formation:onMemberAdd(member)
	self:_relocationSlaves()
end

function GBT_Formation:onMemberRemove(member)
	self:_relocationSlaves()
end

function GBT_Formation:onMemberPlanInit(member, planType, planId)
	return
end

function GBT_Formation:onMemberPlanFinish(member, planType, planId)
	return
end

function GBT_Formation:onRun()
	local envObj = self.owner:getClosestCallFriendEnvObj()

	if not envObj then
		self.owner:tryTransitionTo(TacheDefine.QueueFollow)

		return
	end

	local isCastSkill, _, _ = self.owner:getChemSkillCastInfo()

	if isCastSkill then
		self.owner:tryTransitionTo(TacheDefine.HelpSkill)

		return
	end

	if self.envObj ~= envObj then
		self.envObj = envObj
		self.playerIndex = -1
		self.posCount = self.envObj.eModel:GetInteractPositions(self.positionsAccess)

		for i = 1, self.posCount do
			if self.posArray[i] == nil then
				self.posArray[i] = Vector3(self.positions[i * 3 - 2], self.positions[i * 3 - 1], self.positions[i * 3])
			else
				self.posArray[i]:Set(self.positions[i * 3 - 2], self.positions[i * 3 - 1], self.positions[i * 3])
			end
		end
	end

	if self.posCount > 0 then
		self:_relocationPlayer()
	end
end

function GBT_Formation:_relocationPlayer()
	local closestIndex = -1
	local closestSqrDist = 999999
	local playerPos = self.owner.bindEnt:getPosition()

	for i = 1, self.posCount do
		local sqrDist = Vector3.SqrDistance(playerPos, self.posArray[i])

		if sqrDist < closestSqrDist then
			closestSqrDist = sqrDist
			closestIndex = i
		end
	end

	if self.playerIndex ~= closestIndex then
		self.playerIndex = closestIndex

		self:_relocationSlaves()
	end
end

function GBT_Formation:_relocationSlaves()
	self:_execTriggerToAllMember()
end

function GBT_Formation:_getTriggerEventName(member)
	return "RecruitMoveToPointMsgTrigger"
end

function GBT_Formation:_getTriggerContext(member, context)
	local memberIndex = self:getMemberIndex(member)
	local posIndex = (self.playerIndex + (memberIndex - 1)) % self.posCount + 1

	context.movePos = self.posArray[posIndex]
	context.turnPos = self.envObj:getPosition()
	context.index = posIndex
end

return GBT_Formation
