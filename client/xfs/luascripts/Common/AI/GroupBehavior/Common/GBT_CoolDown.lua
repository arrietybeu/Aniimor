-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\GroupBehavior\\Common\\GBT_CoolDown.lua

local Class = require("Core.Framework.Class")
local GroupBehaviourTacheBase = require("Common.AI.GroupBehavior.GroupBehaviourTacheBase")
local TimerManager = require("Core.Timer.TimerManager")
local GBT_CoolDown = Class.LiteClass("GBT_CoolDown", GroupBehaviourTacheBase)

function GBT_CoolDown:ctor(owner, stateKey)
	GroupBehaviourTacheBase.ctor(self, owner, stateKey)

	self.timeoutTime = -1
	self.cdTimerId = nil
end

function GBT_CoolDown:onEnter(controller, oldState)
	GroupBehaviourTacheBase.onEnter(self, controller, oldState)

	local cdTime = self.owner:getCdTime()

	if cdTime > 0 then
		self.cdTimerId = TimerManager.addTimer(cdTime, function()
			self:_execFinish()
		end)
	else
		self:_execFinish()
	end
end

function GBT_CoolDown:onExit(controller, nextState)
	GroupBehaviourTacheBase.onExit(self, controller, nextState)

	if self.cdTimerId ~= nil then
		TimerManager.removeTimer(self.cdTimerId)

		self.cdTimerId = nil
	end
end

function GBT_CoolDown:_execStart()
	return
end

function GBT_CoolDown:onMemberAdd(member)
	return
end

function GBT_CoolDown:onMemberRemove(member)
	return
end

function GBT_CoolDown:onMemberPlanInit(member, planType, planId)
	return
end

function GBT_CoolDown:onMemberPlanFinish(member, planType, planId)
	return
end

return GBT_CoolDown
