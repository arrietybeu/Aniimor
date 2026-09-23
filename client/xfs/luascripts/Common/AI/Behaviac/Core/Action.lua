-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\Behaviac\\Core\\Action.lua

local enums = require("Common.AI.Behaviac.Enums")
local common = require("Common.AI.Behaviac.Common")
local macros = require("Common.AI.Behaviac.Macros")
local functions = require("Common.AI.Behaviac.Functions")
local AiConst = require("Common.Const.AiConst")
local EBTStatus = enums.EBTStatus
local ActionResumeType = enums.ActionResumeType
local btDebugger = require("Common.AI.Behaviac.Debug.btdebugger")
local AIUtils = require("Common.Utils.AIUtils")
local Leaf = require("Common.AI.Behaviac.Core.Leaf")
local Action = functions.class("Action", Leaf)

macros.ADD_BEHAVIAC_DYNAMIC_TYPE("Action", Action)
macros.BEHAVIAC_DECLARE_DYNAMIC_TYPE("Action", "Leaf")

local _M = Action
local NodeParser = require("Common.AI.Behaviac.Parser.NodeParser")

function _M:ctor()
	_M.super.ctor(self)

	self.m_method = false
	self.m_resumeType = ActionResumeType.BT_None
	self.m_method_resetState = false
	self.m_resultOption = EBTStatus.BT_INVALID
end

function _M:release()
	_M.super.release(self)

	self.m_method = false
end

function _M:onLoading(version, agentType, properties)
	_M.super.onLoading(self, version, agentType, properties)

	local nameStr, valueStr

	for _, p in ipairs(properties) do
		nameStr = p[1]
		valueStr = p[2]

		if nameStr == "Method" then
			self.m_method = NodeParser.parseMethod(valueStr)
			self.m_method_resetState = NodeParser.parseResetStateMethod(valueStr)
		elseif nameStr == "ResultOption" then
			if valueStr == "BT_INVALID" then
				self.m_resultOption = EBTStatus.BT_INVALID
			elseif valueStr == "BT_FAILURE" then
				self.m_resultOption = EBTStatus.BT_FAILURE
			elseif valueStr == "BT_RUNNING" then
				self.m_resultOption = EBTStatus.BT_RUNNING
			else
				self.m_resultOption = EBTStatus.BT_SUCCESS
			end
		elseif nameStr == "ResultResumeOption" then
			if valueStr == "BT_ResumeTree" then
				self.m_resumeType = ActionResumeType.BT_ResumeTree
			elseif valueStr == "BT_ResumeSelf" then
				self.m_resumeType = ActionResumeType.BT_ResumeSelf
			elseif valueStr == "BT_NextNode" then
				self.m_resumeType = ActionResumeType.BT_NextNode
			else
				self.m_resumeType = ActionResumeType.BT_None
			end
		end
	end
end

function _M:isAction()
	return true
end

function _M:onEnter(agent, tick)
	if self:checkHasResumeType() then
		self.m_method_resetState:runSpecialParam(agent, tick, AiConst.ResetStateType.enter)
	end

	self:recordDebugInfo(agent, tick)
	agent:addRunningAction(self, tick)
	self:setResumeType(tick, false)

	return true
end

function _M:onExit(agent, tick, status)
	if self:checkHasResumeType() then
		self.m_method_resetState:runSpecialParam(agent, tick, AiConst.ResetStateType.exit)
	end

	self:resetDebugInfo(agent, tick)
	agent:removeRunningAction(self)
	self:setResumeType(tick, false)

	return true
end

function _M:update(agent, tick, childStatus)
	macros.BEHAVIAC_ASSERT(self:isAction(), "[_M:update()] self:isAction()")

	local status = self:executeAction(agent, tick, childStatus)

	self:recordDebugInfo(agent, tick)

	return status
end

function _M:recordDebugInfo(agent, tick)
	if AIUtils.checkAINodeDebug(agent.ent.actorId) then
		local runningNodeMethod = self.m_method and (self.m_method:getMethodName() .. "(" .. self.m_method:getParamPropertiesDebugMsg(agent, tick)) .. ")" or "nil"
		local timeout = agent:_getLastCustomTimeout(runningNodeMethod) or "nil"

		agent:_debugSettingRunningAction("(" .. self.m_id .. ")" .. runningNodeMethod .. "(" .. timeout .. ")")
	end
end

function _M:resetDebugInfo(agent, tick)
	if AIUtils.checkAINodeDebug(agent.ent.actorId) then
		local runningNodeMethod = self.m_method and self.m_method:getMethodName() .. self.m_method:getParamPropertiesDebugMsg(agent, tick) or "nil"

		agent:_debugSettingRunningAction("【exit】" .. self.m_id .. "," .. runningNodeMethod)
	end
end

function _M:execute(agent, tick)
	local status = EBTStatus.BT_RUNNING

	if self.m_method then
		self.m_method:run(agent, tick)
	else
		status = self:evaluateImpl(agent, tick, EBTStatus.BT_RUNNING)
	end

	return self:statusModify(status)
end

function _M:executeAction(agent, tick, childStatus)
	local status = EBTStatus.BT_SUCCESS

	if self.m_method then
		if self.m_resultOption ~= EBTStatus.BT_INVALID then
			status = self.m_method:run(agent, tick)
		else
			if self:getResumeType(tick) then
				status = self:resumeAction(agent, tick)

				self:setResumeType(tick, false)

				if status ~= EBTStatus.BT_INVALID then
					return status
				end
			end

			local val = self.m_method:getValue(agent, tick)

			status = val and tonumber(val) or EBTStatus.BT_FAILURE
		end
	else
		status = self:evaluateImpl(agent, tick, childStatus)
	end

	return self:statusModify(status)
end

function _M:pauseAction(agent, tick)
	if self:getStatus(tick) == EBTStatus.BT_RUNNING then
		if self.m_resumeType == ActionResumeType.BT_NextNode or self.m_resumeType == ActionResumeType.BT_ResumeSelf then
			self.m_method_resetState:runSpecialParam(agent, tick, AiConst.ResetStateType.pause)
		end

		self:setResumeType(tick, self.m_resumeType)

		return self.m_resumeType
	end

	return false
end

function _M:resumeAction(agent, tick)
	local actionStatus = EBTStatus.BT_INVALID

	if self.m_resumeType == ActionResumeType.BT_ResumeSelf then
		if self.m_method_resetState:runSpecialParam(agent, tick, AiConst.ResetStateType.resume) then
			actionStatus = EBTStatus.BT_RUNNING
		end
	elseif self.m_resumeType == ActionResumeType.BT_NextNode then
		actionStatus = EBTStatus.BT_SUCCESS
	end

	return actionStatus
end

function _M:checkHasResumeType()
	return self.m_resumeType ~= ActionResumeType.BT_None
end

function _M:statusModify(status)
	if self.m_resultOption == EBTStatus.BT_INVALID then
		return status
	elseif self.m_method_resetState then
		return status == EBTStatus.BT_RUNNING and EBTStatus.BT_RUNNING or self.m_resultOption
	else
		return self.m_resultOption
	end
end

return _M
