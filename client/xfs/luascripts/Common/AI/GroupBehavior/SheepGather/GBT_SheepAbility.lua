-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\GroupBehavior\\SheepGather\\GBT_SheepAbility.lua

local Class = require("Core.Framework.Class")
local GroupBehaviourTacheBase = require("Common.AI.GroupBehavior.GroupBehaviourTacheBase")
local GroupBehaviourConst = require("Common.Const.GroupBehaviourConst")
local GBT_SheepAbility = Class.LiteClass("GBT_SheepAbility", GroupBehaviourTacheBase)

function GBT_SheepAbility:_execBreak(isNormalFinish)
	if self.isInBreak then
		return
	end

	self.isInBreak = true

	self.owner:unregisterAllMember()
	self.owner:stopBehaviour()
end

function GBT_SheepAbility:_getTriggerEventName(member)
	return GroupBehaviourConst.SheepGatherBCEventAbility
end

function GBT_SheepAbility:_getTriggerContext(member, context)
	context.targetActorId = self.owner.bindEnt:getMaxPerceptibility()
end

function GBT_SheepAbility:_getFinishBehavId(member)
	return GroupBehaviourConst.SheepGatherBehaviourID
end

function GBT_SheepAbility:onEnter(controller, oldState)
	self.owner:setAllMemberAttach(true)
	GroupBehaviourTacheBase.onEnter(self, controller, oldState)
end

function GBT_SheepAbility:_checkFinish()
	return next(self.finishFlags) ~= nil
end

return GBT_SheepAbility
