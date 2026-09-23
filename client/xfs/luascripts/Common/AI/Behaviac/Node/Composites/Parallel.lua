-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\Behaviac\\Node\\Composites\\Parallel.lua

local enums = require("Common.AI.Behaviac.Enums")
local common = require("Common.AI.Behaviac.Common")
local macros = require("Common.AI.Behaviac.Macros")
local functions = require("Common.AI.Behaviac.Functions")
local EBTStatus = enums.EBTStatus
local ENodePhase = enums.ENodePhase
local EPreconditionPhase = enums.EPreconditionPhase
local TriggerMode = enums.TriggerMode
local EOperatorType = enums.EOperatorType
local constSupportedVersion = enums.constSupportedVersion
local constInvalidChildIndex = enums.constInvalidChildIndex
local constBaseKeyStrDef = enums.constBaseKeyStrDef
local constPropertyValueType = enums.constPropertyValueType
local Logging = common.d_log
local StringUtils = common.StringUtils
local Composite = require("Common.AI.Behaviac.Core.Composite")
local Parallel = functions.class("Parallel", Composite)

macros.ADD_BEHAVIAC_DYNAMIC_TYPE("Parallel", Parallel)
macros.BEHAVIAC_DECLARE_DYNAMIC_TYPE("Parallel", "Composite")

local _M = Parallel
local NodeParser = require("Common.AI.Behaviac.Parser.NodeParser")
local EFAILURE_POLICY = {
	FAIL_ON_ONE = 0,
	FAIL_ON_ALL = 1
}
local ESUCCESS_POLICY = {
	SUCCEED_ON_ALL = 1,
	SUCCEED_ON_ONE = 0
}
local EEXIT_POLICY = {
	EXIT_NONE = 0,
	EXIT_ABORT_RUNNINGSIBLINGS = 1
}
local ECHILDFINISH_POLICY = {
	CHILDFINISH_LOOP = 1,
	CHILDFINISH_ONCE = 0
}

function _M:ctor()
	_M.super.ctor(self)

	self.m_failPolicy = EFAILURE_POLICY.FAIL_ON_ONE
	self.m_succeedPolicy = ESUCCESS_POLICY.SUCCEED_ON_ALL
	self.m_exitPolicy = EEXIT_POLICY.EXIT_NONE
	self.m_childFinishPolicy = ECHILDFINISH_POLICY.CHILDFINISH_LOOP
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

		if nameStr == "FailurePolicy" then
			if valueStr == "FAIL_ON_ONE" then
				self.m_failPolicy = EFAILURE_POLICY.FAIL_ON_ONE
			elseif valueStr == "FAIL_ON_ALL" then
				self.m_failPolicy = EFAILURE_POLICY.FAIL_ON_ALL
			else
				macros.BEHAVIAC_ASSERT(false, "[_M:onLoading()] FailurePolicy error value = %s", valueStr)
			end
		elseif nameStr == "SuccessPolicy" then
			if valueStr == "SUCCEED_ON_ONE" then
				self.m_succeedPolicy = ESUCCESS_POLICY.SUCCEED_ON_ONE
			elseif valueStr == "SUCCEED_ON_ALL" then
				self.m_succeedPolicy = ESUCCESS_POLICY.SUCCEED_ON_ALL
			else
				macros.BEHAVIAC_ASSERT(false, "[_M:onLoading()] SuccessPolicy error value = %s", valueStr)
			end
		elseif nameStr == "ExitPolicy" then
			if valueStr == "EXIT_NONE" then
				self.m_exitPolicy = EEXIT_POLICY.EXIT_NONE
			elseif valueStr == "EXIT_ABORT_RUNNINGSIBLINGS" then
				self.m_exitPolicy = EEXIT_POLICY.EXIT_ABORT_RUNNINGSIBLINGS
			else
				macros.BEHAVIAC_ASSERT(false, "[_M:onLoading()] ExitPolicy error value = %s", valueStr)
			end
		elseif nameStr == "ChildFinishPolicy" then
			if valueStr == "CHILDFINISH_ONCE" then
				self.m_childFinishPolicy = ECHILDFINISH_POLICY.CHILDFINISH_ONCE
			elseif valueStr == "CHILDFINISH_LOOP" then
				self.m_childFinishPolicy = ECHILDFINISH_POLICY.CHILDFINISH_LOOP
			else
				macros.BEHAVIAC_ASSERT(false, "[_M:onLoading()] ChildFinishPolicy error value = %s", valueStr)
			end
		end
	end
end

function _M:parallelUpdate(agent, tick, children)
	local sawSuccess = false
	local sawFail = false
	local sawRunning = false
	local sawAllFails = true
	local sawAllSuccess = true
	local bLoop = self.m_childFinishPolicy == ECHILDFINISH_POLICY.CHILDFINISH_LOOP

	for _, pChild in ipairs(children) do
		local treeStatus = pChild:getStatus(tick)

		if bLoop or treeStatus == EBTStatus.BT_RUNNING or treeStatus == EBTStatus.BT_INVALID then
			local status = tick:exec(pChild, agent)

			if status == EBTStatus.BT_FAILURE then
				sawFail = true
				sawAllSuccess = false
			elseif status == EBTStatus.BT_SUCCESS then
				sawSuccess = true
				sawAllFails = false
			elseif status == EBTStatus.BT_RUNNING then
				sawRunning = true
				sawAllFails = false
				sawAllSuccess = false
			end
		elseif treeStatus == EBTStatus.BT_SUCCESS then
			sawSuccess = true
			sawAllFails = false
		else
			macros.BEHAVIAC_ASSERT(treeStatus == EBTStatus.BT_FAILURE)

			sawFail = true
			sawAllSuccess = false
		end
	end

	local status = sawRunning and EBTStatus.BT_RUNNING or EBTStatus.BT_FAILURE

	if self.m_failPolicy == EFAILURE_POLICY.FAIL_ON_ALL and sawAllFails or self.m_failPolicy == EFAILURE_POLICY.FAIL_ON_ONE and sawFail then
		status = EBTStatus.BT_FAILURE
	elseif self.m_succeedPolicy == ESUCCESS_POLICY.SUCCEED_ON_ALL and sawAllSuccess or self.m_succeedPolicy == ESUCCESS_POLICY.SUCCEED_ON_ONE and sawSuccess then
		status = EBTStatus.BT_SUCCESS
	end

	if self.m_exitPolicy == EEXIT_POLICY.EXIT_ABORT_RUNNINGSIBLINGS and (status == EBTStatus.BT_FAILURE or status == EBTStatus.BT_SUCCESS) then
		for _, pChild in ipairs(children) do
			tick:abort(pChild, agent)
		end
	end

	return status
end

function _M:isManagingChildrenAsSubTrees()
	return true
end

function _M:setPolicy(failPolicy, successPolicy, exitPolicty)
	if not failPolicy then
		failPolicy = EFAILURE_POLICY.FAIL_ON_ALL

		Logging.error("[_M:setPolicy()] failPolicy default is = FAIL_ON_ALL")
	end

	if not successPolicy then
		successPolicy = ESUCCESS_POLICY.SUCCEED_ON_ALL

		Logging.error("[_M:setPolicy()] successPolicy default is = SUCCEED_ON_ALL")
	end

	if not exitPolicty then
		exitPolicty = EEXIT_POLICY.EXIT_NONE

		Logging.error("[_M:setPolicy()] exitPolicty default is = EXIT_NONE")
	end

	self.m_failPolicy = failPolicy
	self.m_succeedPolicy = successPolicy
	self.m_exitPolicy = exitPolicty
end

function _M:isParallel()
	return true
end

function _M:onEnter(agent, tick)
	for _, pChild in ipairs(self.m_children) do
		pChild:setStatus(tick, EBTStatus.BT_INVALID)
	end

	return true
end

function _M:onExit(agent, tick, status)
	if self:isManagingChildrenAsSubTrees() then
		tick:abort(self, agent)
	end

	return true
end

function _M:updateCurrent(agent, tick, childStatus)
	return self:update(agent, tick, childStatus)
end

function _M:update(agent, tick, childStatus)
	return self:parallelUpdate(agent, tick, self.m_children)
end

return _M
