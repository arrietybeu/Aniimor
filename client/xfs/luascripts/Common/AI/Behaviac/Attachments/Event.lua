-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\Behaviac\\Attachments\\Event.lua

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
local Condition = require("Common.AI.Behaviac.Core.Condition")
local Event = functions.class("Event", Condition)

macros.ADD_BEHAVIAC_DYNAMIC_TYPE("Event", Event)
macros.BEHAVIAC_DECLARE_DYNAMIC_TYPE("Event", "Condition")

local _M = Event
local NodeParser = require("Common.AI.Behaviac.Parser.NodeParser")
local BehaviorTreeFactory = require("Common.AI.Behaviac.Parser.BehaviorTreeFactory")
local AgentMeta = require("Common.AI.Behaviac.Agent.AgentMeta")

function _M:ctor()
	_M.super.ctor(self)

	self.m_event = false
	self.m_eventName = ""
	self.m_triggerMode = TriggerMode.TM_Transfer
	self.m_bTriggeredOnce = false
	self.m_bHasEvents = true
	self.m_referencedTreeName = ""
	self.m_referencedTreePath = ""
end

function _M:release()
	_M.super.release()
end

function _M:onLoading(version, agentType, properties)
	_M.super.onLoading(self, version, agentType, properties)

	local nameStr, valueStr

	for _, p in ipairs(properties) do
		nameStr = p[1]
		valueStr = p[2]

		if nameStr == "Task" then
			self.m_event, self.m_eventName = NodeParser.parseMethodOutMethodName(valueStr)
		elseif nameStr == "ReferenceFilename" then
			self.m_referencedTreeName = valueStr

			BehaviorTreeFactory.preloadBehaviorTree(self.m_referencedTreeName)
		elseif nameStr == "TriggeredOnce" then
			if valueStr == "true" then
				self.m_bTriggeredOnce = true
			end
		elseif nameStr == "TriggerMode" then
			if valueStr == "Transfer" then
				self.m_triggerMode = TriggerMode.TM_Transfer
			elseif valueStr == "Return" then
				self.m_triggerMode = TriggerMode.TM_Return
			else
				macros.BEHAVIAC_ASSERT(false, "unrecognised trigger mode %s", valueStr)
			end
		end
	end
end

function _M:getEventName()
	return self.m_eventName
end

function _M:triggeredOnce()
	return self.m_bTriggeredOnce
end

function _M:getTriggerMode()
	return self.m_triggerMode
end

function _M:referencedTreePath()
	return self.m_referencedTreePath
end

function _M:switchTo(agent, eventParams)
	if not StringUtils.isNullOrEmpty(self.m_referencedTreePath) and agent then
		local subTreeTick = agent:btEventTree(self.m_referencedTreePath, self.m_triggerMode)

		subTreeTick:addLocalVariables(eventParams)
		agent:btExec()
	end
end

function _M:isEvent()
	return true
end

function _M:init(tick)
	_M.super.init(self, tick)
end

function _M:onEnter(agent, tick)
	return true
end

function _M:onExit(agent, tick, status)
	return true
end

function _M:traverse(childFirst, handler, agent, tick, userData)
	handler(self, agent, tick, userData)
end

function _M:update(agent, tick, childStatus)
	macros.BEHAVIAC_ASSERT(self:isEvent(), "[_M:update()] self:isEvent()")

	if not StringUtils.isNullOrEmpty(self.m_referencedTreePath) and agent then
		agent:btEventTree(self.m_referencedTreePath, self.m_triggerMode)
		agent:btexec()
	end

	return EBTStatus.BT_SUCCESS
end

return _M
