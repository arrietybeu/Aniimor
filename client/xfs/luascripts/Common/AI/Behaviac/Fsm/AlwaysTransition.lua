-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\Behaviac\\Fsm\\AlwaysTransition.lua

local enums = require("Common.AI.Behaviac.Enums")
local common = require("Common.AI.Behaviac.Common")
local macros = require("Common.AI.Behaviac.Macros")
local functions = require("Common.AI.Behaviac.Functions")
local EBTStatus = enums.EBTStatus
local ENodePhase = enums.ENodePhase
local ETransitionPhase = enums.ETransitionPhase
local Transition = require("Common.AI.Behaviac.Fsm.Transition")
local AlwaysTransition = functions.class("AlwaysTransition", Transition)
local _M = AlwaysTransition

function _M:ctor()
	_M.super.ctor(self)

	self.m_transitionPhase = ETransitionPhase.ETP_Always
end

function _M:release()
	_M.super.release(self)
end

function _M:onLoading(version, agentType, properties)
	_M.super.onLoading(self, version, agentType, properties)

	local nameStr, valueStr

	for _, p in ipairs(properties) do
		nameStr = p[1]
		valueStr = p[2]

		if nameStr == "TransitionPhase" then
			if valueStr == "ETP_Exit" then
				self.m_transitionPhase = ETransitionPhase.ETP_Exit
			elseif valueStr == "ETP_Success" then
				self.m_transitionPhase = ETransitionPhase.ETP_Success
			elseif valueStr == "ETP_Failure" then
				self.m_transitionPhase = ETransitionPhase.ETP_Failure
			elseif valueStr == "ETP_Always" then
				self.m_transitionPhase = ETransitionPhase.ETP_Always
			else
				macros.BEHAVIAC_ASSERT(false)
			end
		end
	end
end

function _M:evaluateWithStatus(agent, tick, status)
	if self.m_transitionPhase == ETransitionPhase.ETP_Always then
		return true
	elseif status == EBTStatus.BT_SUCCESS and (self.m_transitionPhase == ETransitionPhase.ETP_Success or self.m_transitionPhase == ETransitionPhase.ETP_Exit) then
		return true
	elseif status == EBTStatus.BT_FAILURE and (self.m_transitionPhase == ETransitionPhase.ETP_Failure or self.m_transitionPhase == ETransitionPhase.ETP_Exit) then
		return true
	end

	return false
end

function _M:isGlobalTransition()
	return false
end

return _M
