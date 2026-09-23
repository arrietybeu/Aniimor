-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\GroupBehavior\\SheepGather\\GBT_SheepGather.lua

local Class = require("Core.Framework.Class")
local GroupBehaviourTacheBase = require("Common.AI.GroupBehavior.GroupBehaviourTacheBase")
local GroupBehaviourConst = require("Common.Const.GroupBehaviourConst")
local GBT_SheepGather = Class.LiteClass("GBT_SheepGather", GroupBehaviourTacheBase)

function GBT_SheepGather:_execBreak(isNormalFinish)
	if self.isInBreak then
		return
	end

	self.isInBreak = true

	self.owner:unregisterAllMember()
	self.owner:stopBehaviour()
end

function GBT_SheepGather:_getTriggerEventName(member)
	return GroupBehaviourConst.SheepGatherBCEventGather
end

function GBT_SheepGather:_getTriggerContext(member, context)
	context.memberIndex = self:getMemberIndex(member)
	context.targetActorId = self.owner.bindEnt.actorId
end

function GBT_SheepGather:_getFinishBehavId(member)
	return GroupBehaviourConst.SheepGatherBehaviourID
end

return GBT_SheepGather
