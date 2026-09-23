-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\Behaviac\\Htn\\Task.lua

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
local Sequence = require("Common.AI.Behaviac.Node.Composites.Sequence")
local Task = functions.class("Task", Sequence)

macros.ADD_BEHAVIAC_DYNAMIC_TYPE("Task", Task)
macros.BEHAVIAC_DECLARE_DYNAMIC_TYPE("Task", "Sequence")

local _M = Task
local NodeParser = require("Common.AI.Behaviac.Parser.NodeParser")

function _M:ctor()
	_M.super.ctor(self)

	self.m_bHTN = false
	self.m_task = false
	self.m_planner = false
end

function _M:release()
	_M.super.release(self)

	self.m_task = false
	self.m_planner = false
end

function _M:onLoading(version, agentType, properties)
	_M.super.onLoading(self, version, agentType, properties)

	local nameStr, valueStr

	for _, p in ipairs(properties) do
		nameStr = p[1]
		valueStr = p[2]

		if nameStr == "Prototype" then
			self.m_task = NodeParser.parseMethod(valueStr)
		elseif nameStr == "IsHTN" then
			self.m_bHTN = valueStr == "true"
		end
	end
end

function _M:FindMethodIndex(method)
	if self.m_children then
		for i, oneChild in ipairs(self.m_children) do
			if oneChild == method then
				return i
			end
		end
	end

	return constInvalidChildIndex
end

function _M:isHTN()
	return self.m_bHTN
end

function _M:isTask()
	return true
end

function _M:init(tick)
	macros.BEHAVIAC_ASSERT(self:isTask(), "[_M:init()] node is not a task")

	if self:isHTN() then
		-- block empty
	else
		_M.super.init(self, tick)
	end
end

function _M:onEnter(agent, tick)
	self:setActiveChildIndex(tick, constInvalidChildIndex)

	return _M.super.onEnter(self, agent, tick)
end

function _M:onExit(agent, tick, status)
	return _M.super.onExit(self, agent, tick, status)
end

function _M:update(agent, tick, childStatus)
	local status = childStatus

	if childStatus == EBTStatus.BT_RUNNING then
		macros.BEHAVIAC_ASSERT(self:isTask(), "[_M:update()] node is not a task")

		if self:isHTN() then
			-- block empty
		else
			macros.BEHAVIAC_ASSERT(#self.m_children == 1)

			local pChild = self.m_children[1]

			status = tick:exec(pChild, agent)
		end
	end

	return status
end

return _M
