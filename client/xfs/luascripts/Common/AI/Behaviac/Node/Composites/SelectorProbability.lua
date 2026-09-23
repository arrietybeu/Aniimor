-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\Behaviac\\Node\\Composites\\SelectorProbability.lua

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
local SelectorProbability = functions.class("SelectorProbability", Composite)

macros.ADD_BEHAVIAC_DYNAMIC_TYPE("SelectorProbability", SelectorProbability)
macros.BEHAVIAC_DECLARE_DYNAMIC_TYPE("SelectorProbability", "Composite")

local _M = SelectorProbability
local NodeParser = require("Common.AI.Behaviac.Parser.NodeParser")

function _M:ctor()
	_M.super.ctor(self)

	self.m_randomGenerator = false
end

function _M:release()
	_M.super.release()

	self.m_randomGenerator = false
end

function _M:onLoading(version, agentType, properties)
	_M.super.onLoading(self, version, agentType, properties)

	local nameStr, valueStr

	for _, p in ipairs(properties) do
		nameStr = p[1]
		valueStr = p[2]

		if nameStr == "RandomGenerator" then
			if valueStr[0] ~= "" then
				self.m_randomGenerator = NodeParser.parseMethod(valueStr)
			end
		elseif nameStr == "UntilSuccessOrEnd" then
			self.m_bUntilSuccessOrEnd = valueStr or false
		end
	end
end

function _M:addChild(pBehavior)
	macros.BEHAVIAC_ASSERT(pBehavior:isDecoratorWeight(), "[_M:addChild()] pBehavior:isDecoratorWeight")
	_M.super.addChild(self, pBehavior)
end

function _M:isSelectorProbability()
	return true
end

function _M:isManagingChildrenAsSubTrees()
	return false
end

function _M:init(tick)
	_M.super.init(self, tick)
	self:setTotalSum(tick, 0)
	self:clearWeightingMap(tick)
end

function _M:onEnter(agent, tick)
	macros.BEHAVIAC_ASSERT(#self.m_children > 0, "[_M:onEnter()] #self.m_children > 0")
	self:setActiveChildIndex(tick, constInvalidChildIndex)

	local totalSum = 0

	self:clearWeightingMap(tick)

	for _, pChild in ipairs(self.m_children) do
		macros.BEHAVIAC_ASSERT(pChild:isDecoratorWeight(), "[_M:onEnter()] pChild:isDecoratorWeight")

		local weight = pChild:getWeightP(agent, tick)

		self:addWeightingMapWeight(tick, weight)

		totalSum = totalSum + weight
	end

	self:setTotalSum(tick, totalSum)

	local weightingMap = self:getWeightingMap(tick)

	macros.BEHAVIAC_ASSERT(#weightingMap == #self.m_children, "[_M:onEnter()] #weightingMap == self.m_children")

	return true
end

function _M:onExit(agent, tick, status)
	local activeChildIndex = self:getActiveChildIndex(tick)

	if activeChildIndex ~= constInvalidChildIndex then
		local pChild = self.m_children[activeChildIndex]

		pChild:onExit(agent, tick, status)
	end

	self:setActiveChildIndex(tick, constInvalidChildIndex)

	return true
end

function _M:update(agent, tick, childStatus)
	macros.BEHAVIAC_ASSERT(self:isSelectorProbability(), "[_M:update()] self:isSelectorProbability")

	if childStatus ~= EBTStatus.BT_RUNNING then
		return childStatus
	end

	local activeChildIndex = self:getActiveChildIndex(tick)
	local repeatTrySelector = false

	repeat
		if repeatTrySelector or activeChildIndex == constInvalidChildIndex then
			activeChildIndex = self:getSelectorProbabilityIndex(tick, agent)

			self:setActiveChildIndex(tick, activeChildIndex)
			self:setNilAlreadyTriedChildrenIndex(tick, activeChildIndex)

			repeatTrySelector = false
		end

		local status = EBTStatus.BT_RUNNING

		if activeChildIndex ~= constInvalidChildIndex then
			local pChild = self.m_children[activeChildIndex]

			status = tick:exec(pChild, agent)

			if status ~= EBTStatus.BT_FAILURE then
				return status
			end
		else
			status = EBTStatus.BT_FAILURE
		end

		if not self.m_bUntilSuccessOrEnd then
			return status
		end

		repeatTrySelector = true
	until activeChildIndex == constInvalidChildIndex

	return EBTStatus.BT_FAILURE
end

function _M:setTotalSum(tick, n)
	tick:setNodeMem("totalSum", n, self)
end

function _M:getTotalSum(tick)
	return tick:getNodeMem("totalSum", self)
end

function _M:clearWeightingMap(tick)
	local indexSet = self:getWeightingMap(tick)

	table.clearArray(indexSet)
end

function _M:addWeightingMapWeight(tick, weight)
	local weightingMap = self:getWeightingMap(tick)

	table.insert(weightingMap, weight)
end

function _M:getWeightingMap(tick)
	local indexSet = tick:getNodeMem("weightingMap", self)

	if indexSet == nil then
		indexSet = {}

		tick:setNodeMem("weightingMap", indexSet, self)
	end

	return indexSet
end

function _M:getSelectorProbabilityIndex(tick, agent)
	local weightingMap = self:getWeightingMap(tick)
	local chosen = self:getTotalSum(tick) * common.getRandomValue(self.m_randomGenerator, agent, tick)
	local sum = 0

	for i = 1, #self.m_children do
		local w = weightingMap[i]

		if w > 0 then
			sum = sum + w

			if chosen <= sum then
				return i
			end
		end
	end

	return constInvalidChildIndex
end

function _M:setNilAlreadyTriedChildrenIndex(tick, triedIndex)
	if triedIndex == constInvalidChildIndex then
		return
	end

	local weightingMap = self:getWeightingMap(tick)

	if weightingMap[triedIndex] > 0 then
		self:setTotalSum(tick, self:getTotalSum(tick) - weightingMap[triedIndex])

		weightingMap[triedIndex] = 0
	end
end

return _M
