-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\Behaviac\\Node\\Composites\\SelectorLoop.lua

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
local SelectorLoop = functions.class("SelectorLoop", Composite)

macros.ADD_BEHAVIAC_DYNAMIC_TYPE("SelectorLoop", SelectorLoop)
macros.BEHAVIAC_DECLARE_DYNAMIC_TYPE("SelectorLoop", "Composite")

local _M = SelectorLoop
local NodeParser = require("Common.AI.Behaviac.Parser.NodeParser")

function _M:ctor()
	_M.super.ctor(self)

	self.m_bResetChildren = false
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

		if nameStr == "ResetChildren" then
			self.m_bResetChildren = valueStr == "true"

			break
		end
	end
end

function _M:isManagingChildrenAsSubTrees()
	return true
end

function _M:isSelectorLoop()
	return true
end

function _M:onEnter(agent, tick)
	self:setActiveChildIndex(tick, constInvalidChildIndex)

	return _M.super.onEnter(self, agent, tick)
end

function _M:updateCurrent(agent, tick, childStatus)
	return self:update(agent, tick, childStatus)
end

function _M:update(agent, tick, childStatus)
	local idx = 0
	local activeChildIndex = self:getActiveChildIndex(tick)

	if childStatus ~= EBTStatus.BT_RUNNING then
		macros.BEHAVIAC_ASSERT(activeChildIndex ~= constInvalidChildIndex, "[_M:update()] activeChildIndex ~= constInvalidChildIndex")

		if childStatus == EBTStatus.BT_SUCCESS then
			return EBTStatus.BT_SUCCESS
		elseif childStatus == EBTStatus.BT_FAILURE then
			idx = activeChildIndex
		else
			macros.BEHAVIAC_ASSERT(false)
		end
	end

	local index = -1

	for i = idx + 1, #self.m_children do
		local pChild = self.m_children[i]

		macros.BEHAVIAC_ASSERT(pChild:isWithPrecondition(), "[_M:update()] pChild:isWithPrecondition()")

		local pPrecondition = pChild:preconditionNode()
		local status = tick:exec(pPrecondition, agent)

		if status == EBTStatus.BT_SUCCESS then
			index = i

			break
		end
	end

	if index ~= -1 then
		if activeChildIndex ~= constInvalidChildIndex then
			local abortChild = activeChildIndex ~= index

			abortChild = abortChild or self.m_bResetChildren

			if abortChild then
				local pChild = self.m_children[activeChildIndex]

				macros.BEHAVIAC_ASSERT(pChild:isWithPrecondition(), "[_M:update()] pChild:isWithPrecondition()")
				pChild:abort(agent)
			end
		end

		for i = index, #self.m_children do
			local pChild = self.m_children[i]

			macros.BEHAVIAC_ASSERT(pChild:isWithPrecondition(), "[_M:update()] pChild:isWithPrecondition()")

			if index <= i then
				local pPrecondition = pChild:preconditionNode()
				local status = tick:exec(pPrecondition, agent)

				if status == EBTStatus.BT_SUCCESS then
					local pAction = pChild:actionNode()
					local s = tick:exec(pAction, agent)

					if s == EBTStatus.BT_RUNNING then
						activeChildIndex = i

						self:setActiveChildIndex(tick, activeChildIndex)
						pChild:setStatus(tick, EBTStatus.BT_RUNNING)

						return s
					else
						pChild:setStatus(tick, s)

						if s ~= EBTStatus.BT_FAILURE then
							macros.BEHAVIAC_ASSERT(s == EBTStatus.BT_RUNNING or s == EBTStatus.BT_SUCCESS, "[_M:update()] s == EBTStatus.BT_RUNNING or s == EBTStatus.BT_SUCCESS")

							return s
						end
					end
				end
			end
		end
	end

	return EBTStatus.BT_FAILURE
end

return _M
