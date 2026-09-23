-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Components\\AIGroupBehaviorComponent.lua

local Class = require("Core.Framework.Class")
local PerceptibilityConst = require("Common.Const.PerceptibilityConst")
local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Utils = require("Common.Utils.Utils")
local AiConst = require("Common.Const.AiConst")
local EntityTagData = require("Data.entity_tag_data")
local AIUtils = require("Common.Utils.AIUtils")
local EBTRootState = BaseEnum.EBTRootState
local AIGroupBehaviorComponent = Class.Component("AIGroupBehaviorComponent")

function AIGroupBehaviorComponent:ctor()
	self.GroupBehaviour = {}
end

function AIGroupBehaviorComponent:getCurrentGroupBehaviour()
	return self.GroupBehaviour.curGroupBehaviour
end

function AIGroupBehaviorComponent:isInGroupBehaviour(includePrepare)
	if self.GroupBehaviour.curGroupBehaviour then
		return includePrepare or self.GroupBehaviour.curGroupBehaviour:isRunning()
	end

	return false
end

function AIGroupBehaviorComponent:joinGroupBehaviour(behaviour)
	if not Utils.checkIsAuthorityMaster(self) then
		return false
	end

	self:exitCurrentGroupBehaviour()

	return behaviour:registerMember(self)
end

function AIGroupBehaviorComponent:onJoinGroupBehaviour(behaviour)
	self.GroupBehaviour.curGroupBehaviour = behaviour

	if self.setVisualPerceptibilityGroup and string.notNilOrEmpty(behaviour.overrideVisionArea) then
		self:setVisualPerceptibilityGroup(behaviour.overrideVisionArea)
	end

	self:postComponentMethod("onJoinGroupBehaviourFinish")
end

function AIGroupBehaviorComponent:exitCurrentGroupBehaviour()
	if self.GroupBehaviour.curGroupBehaviour == nil then
		return
	end

	self.GroupBehaviour.curGroupBehaviour:unregisterMember(self)
end

function AIGroupBehaviorComponent:onExitCurrentGroupBehaviour()
	self.GroupBehaviour.curGroupBehaviour = nil

	if self.setVisualPerceptibilityGroup then
		self:setVisualPerceptibilityGroup(PerceptibilityConst.PropertyName.visionAreaDefault)
	end

	self:postComponentMethod("onExitGroupBehaviourFinish")
end

function AIGroupBehaviorComponent:onAIPlanInit(planType, planId)
	if not self.GroupBehaviour.curGroupBehaviour then
		return
	end

	self.GroupBehaviour.curGroupBehaviour:onMemberPlanInit(self, planType, planId)
end

function AIGroupBehaviorComponent:onAIPlanFinish(planType, planId, finishType)
	if not self.GroupBehaviour.curGroupBehaviour then
		return
	end

	self.GroupBehaviour.curGroupBehaviour:onMemberPlanFinish(self, planType, planId, finishType)
end

function AIGroupBehaviorComponent:onAIStateChange(oldRootState, newRootState)
	if oldRootState ~= newRootState then
		self:exitCurrentGroupBehaviour()

		if newRootState == EBTRootState.ST_Root_Combat then
			AIUtils.joinGroupCombat(self, pg.getEntityByActorId(self:getAttackTargetActorId()))
		end
	end
end

function AIGroupBehaviorComponent:destroy()
	self:exitCurrentGroupBehaviour()
	AIUtils.leaveGroupCombat(self, pg.getEntityByActorId(self:getAttackTargetActorId()))
end

function AIGroupBehaviorComponent:onLockTargetChange(oldTargetActorId, targetActorId)
	if Utils.isPet(self) then
		Utils.addEntityTag(pg.getEntityByActorId(oldTargetActorId), EntityTagData.TE_Par_GroupCombat_TokenHolder.value)
	elseif Utils.isPuppet(self) then
		AIUtils.leaveGroupCombat(self, oldTargetActorId and pg.getEntityByActorId(oldTargetActorId))
		AIUtils.joinGroupCombat(self, pg.getEntityByActorId(targetActorId))
	end
end

function AIGroupBehaviorComponent:on_attackTargetActorId_changed(oldVal, newVal)
	AIUtils.leaveGroupCombat(self, oldVal and pg.getEntityByActorId(oldVal))
	AIUtils.joinGroupCombat(self, pg.getEntityByActorId(newVal))
end

function AIGroupBehaviorComponent:EVENT_BeTrapped()
	self:exitCurrentGroupBehaviour()

	if self:isInCombat() then
		AIUtils.leaveGroupCombat(self, pg.getEntityByActorId(self:getAttackTargetActorId()))
	end
end

function AIGroupBehaviorComponent:EVENT_CancelTrapped()
	if self:isInCombat() then
		AIUtils.joinGroupCombat(self, pg.getEntityByActorId(self:getAttackTargetActorId()))
	end
end

return AIGroupBehaviorComponent
