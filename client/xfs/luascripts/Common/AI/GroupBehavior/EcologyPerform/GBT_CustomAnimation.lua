-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\GroupBehavior\\EcologyPerform\\GBT_CustomAnimation.lua

local Class = require("Core.Framework.Class")
local GroupBehaviourTacheBase = require("Common.AI.GroupBehavior.GroupBehaviourTacheBase")
local GBT_CustomAnimation = Class.LiteClass("GBT_CustomAnimation", GroupBehaviourTacheBase)

function GBT_CustomAnimation:onEnter(controller, oldState)
	GroupBehaviourTacheBase.onEnter(self, controller, oldState)

	self.triggerCount = 1
end

function GBT_CustomAnimation:_execFinish()
	table.clear(self.finishFlags)
	self:_removeTimeoutTimer()
	self:_initTimeoutTimer()

	self.triggerCount = self.triggerCount + 1

	self:_execTriggerToAllMember()
end

function GBT_CustomAnimation:_getTriggerEventName(member)
	return "GBTrigger_Test_CustomAnimation"
end

function GBT_CustomAnimation:_getTriggerContext(member, context)
	context.tMemberIndex = self:getMemberIndex(member)
	context.tTriggerCount = self.triggerCount
end

function GBT_CustomAnimation:_getFinishBehavId(member)
	return "BP_Wild_Com_Test_GroupBehav_CustomAnimation"
end

return GBT_CustomAnimation
