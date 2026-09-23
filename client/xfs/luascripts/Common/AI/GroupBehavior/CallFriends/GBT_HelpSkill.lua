-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\GroupBehavior\\CallFriends\\GBT_HelpSkill.lua

local Class = require("Core.Framework.Class")
local GroupBehaviourTacheBase = require("Common.AI.GroupBehavior.GroupBehaviourTacheBase")
local GroupBehaviourConst = require("Common.Const.GroupBehaviourConst")
local TacheDefine = GroupBehaviourConst.TacheDefine
local GBT_HelpSkill = Class.LiteClass("GBT_HelpSkill", GroupBehaviourTacheBase)

function GBT_HelpSkill:onMemberRemove(member)
	return
end

function GBT_HelpSkill:onMemberPlanFinish(member, planType, planId, isBreakFinish)
	if planId == self:_getFinishBehavId(member) then
		self.finishFlags[member.actorId] = true

		self:changeMemberToWait(member)
	end

	self:_tryFinish()
end

function GBT_HelpSkill:_execFinish()
	self.owner:resetChemSkillCastInfo()
	table.clear(self.finishFlags)
	self.owner:tryTransitionTo(TacheDefine.Formation)
end

function GBT_HelpSkill:_getTriggerEventName(member)
	return "CastSameTypeSkillMsgTrigger"
end

function GBT_HelpSkill:_getTriggerContext(member, context)
	local _, globalId, skillId = self.owner:getChemSkillCastInfo()
	local target = pg.getEntityByGlobalId(globalId)

	context.tSkillTargetActorId = target and target.actorId or 0
	context.tSkillId = skillId
end

function GBT_HelpSkill:_getFinishBehavId(member)
	return "BP_Wild_Recruit_CastSameTypeSkill"
end

return GBT_HelpSkill
