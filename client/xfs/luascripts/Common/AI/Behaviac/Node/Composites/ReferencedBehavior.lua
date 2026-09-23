-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\Behaviac\\Node\\Composites\\ReferencedBehavior.lua

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
local ConstValueReader = require("Common.AI.Behaviac.Parser.ConstValueReader")
local Logging = common.d_log
local StringUtils = common.StringUtils
local BaseNode = require("Common.AI.Behaviac.Core.BaseNode")
local ReferencedBehavior = functions.class("ReferencedBehavior", BaseNode)

macros.ADD_BEHAVIAC_DYNAMIC_TYPE("ReferencedBehavior", ReferencedBehavior)
macros.BEHAVIAC_DECLARE_DYNAMIC_TYPE("ReferencedBehavior", "BaseNode")

local _M = ReferencedBehavior
local NodeParser = require("Common.AI.Behaviac.Parser.NodeParser")
local BehaviorTreeFactory = require("Common.AI.Behaviac.Parser.BehaviorTreeFactory")
local AgentMeta = require("Common.AI.Behaviac.Agent.AgentMeta")
local State = require("Common.AI.Behaviac.Fsm.State")
local debugger = require("Common.AI.Behaviac.Debugger")

function _M:ctor()
	_M.super.ctor(self)

	self.m_referenced_behavior_p = false
	self.m_referencedTreePath = false
	self.m_bHasEvents = false
	self.m_taskPrototype = false
	self.m_transitions = false
	self.m_taskPrototypeNode = false
end

function _M:release()
	_M.super.release(self)

	self.m_referenced_behavior_p = false
	self.m_taskPrototype = false
end

function _M:onLoading(version, agentType, properties)
	_M.super.onLoading(self, version, agentType, properties)

	local nameStr, valueStr, checkstr

	for _, p in ipairs(properties) do
		nameStr = p[1]
		valueStr = p[2]

		local valuetype = {}

		checkstr = valueStr

		if valueStr.func ~= nil then
			checkstr = valueStr.func
		else
			valuetype = valueStr.type
			checkstr = valueStr.value
		end

		if nameStr == "ReferenceBehavior" then
			local pParenthesis

			if type(checkstr) == "string" then
				pParenthesis = string.find(checkstr, "%(")
			end

			if not pParenthesis then
				self.m_referenced_behavior_p = NodeParser.parseProperty(valueStr)
			else
				self.m_referenced_behavior_p = NodeParser.parseMethod(valueStr)
			end
		elseif nameStr == "Task" then
			macros.BEHAVIAC_ASSERT(not StringUtils.isNullOrEmpty(valueStr))

			self.m_taskPrototype = NodeParser.parseTaskPrototype(valueStr)
		elseif nameStr == "subTreeProperties" then
			self.m_subTreeProperties = NodeParser.parseSubTreeProperty(valueStr)
		end
	end
end

function _M:setTaskParams(agent, tick, subTreeTick)
	if self.m_taskPrototype then
		self.m_taskPrototype:setTaskParams(agent, tick, subTreeTick)
	end
end

function _M:getReferencedTreeName(agent, tick)
	macros.BEHAVIAC_ASSERT(self.m_referenced_behavior_p, "[_M:getReferencedTreeName()] m_referenced_behavior_p")

	local name = self.m_referenced_behavior_p:getValue(agent, tick)

	if name then
		return StringUtils.trimEnclosedDoubleQuotes(name)
	end

	return false
end

function _M:getReferencedTreePath(agent, tick)
	self.m_referencedTreePath = false

	if self.m_referenced_behavior_p then
		local name, _ = _M.getReferencedTreeName(self, agent, tick)

		if not name then
			return self.m_referencedTreePath
		end

		self.m_referencedTreePath = AgentMeta.getBehaviorTreePath(name)

		local bHasEvents = true

		if not StringUtils.isNullOrEmpty(self.m_referencedTreePath) then
			local refBt = BehaviorTreeFactory.preloadBehaviorTree(self.m_referencedTreePath)

			if refBt then
				bHasEvents = refBt:hasEvents()
			end

			self.m_bHasEvents = self.m_bHasEvents or bHasEvents
		end
	end

	return self.m_referencedTreePath
end

function _M:attach(pAttachment, isPrecondition, isEffector, isTransition)
	if isTransition then
		macros.BEHAVIAC_ASSERT(not isEffector and not isPrecondition, "[_M:attach()] not isEffector and not isPrecondition")

		if not self.m_transitions then
			self.m_transitions = {}
		end

		table.insert(self.m_transitions, pAttachment)

		return
	end

	macros.BEHAVIAC_ASSERT(not isTransition, "[_M:attach()] isTransition")
	_M.super.attach(self, pAttachment, isPrecondition, isEffector, isTransition)
end

function _M:isReferencedBehavior()
	return true
end

function _M:isEndState()
	return false
end

function _M:init(tick)
	_M.super.init(self, tick)
	self:setNextStateId(tick, -1)
	self:setSubTreeTick(tick, false)
end

function _M:onEvent(agent, tick, eventName, eventParams)
	local status = self:getStatus(tick)

	if status == EBTStatus.BT_RUNNING and self:hasEvents() then
		local subTreeTick = self:getSubTreeTick(tick)

		macros.BEHAVIAC_ASSERT(subTreeTick, "[_M:onEvent()] subTreeTick")

		local subTree = subTreeTick:getBt()

		if subTree:isFSM() then
			if not subTree.m_root:onEvent(agent, subTreeTick, eventName, eventParams) then
				return false
			end
		elseif not subTree:onEvent(agent, subTreeTick, eventName, eventParams) then
			return false
		end
	end

	return true
end

function _M:onEnter(agent, tick)
	local subTreeTick, pSubBt

	macros.BEHAVIAC_ASSERT(self:isReferencedBehavior(), "[_M:onEnter()] self:isReferencedBehavior")
	self:setNextStateId(tick, -1)

	local szTreePath = self:getReferencedTreePath(agent, tick)

	if not szTreePath then
		return false
	end

	subTreeTick = self:getSubTreeTick(tick)
	pSubBt = subTreeTick and subTreeTick:getBt()

	if szTreePath and (not pSubBt or szTreePath ~= pSubBt:getRelativePath()) then
		subTreeTick = agent:getCurTreeTick(szTreePath)

		if subTreeTick then
			self:setSubTreeTick(tick, subTreeTick)
		else
			return false
		end
	elseif subTreeTick then
		subTreeTick:reset(pSubBt, agent)
	end

	self:setTaskParams(agent, tick, subTreeTick)
	self:initReferenceBehaviorLocalParams(agent, tick)
	agent:addCurrentRunningTreeTick(subTreeTick)

	return true
end

function _M:onReset(agent, tick)
	self:abortSubtreeTick(agent, tick)

	return true
end

function _M:onExit(agent, tick, status)
	self:abortSubtreeTick(agent, tick)

	return true
end

function _M:update(agent, tick, childStatus)
	local subTreeTick = self:getSubTreeTick(tick)
	local pSubBt = subTreeTick and subTreeTick:getBt()
	local status = EBTStatus.BT_RUNNING

	if tick:getBt():isFSM() then
		local bTransitioned, nextStateId = State.s_updateGlobalTransitions(self, agent, tick, self.m_transitions, status)

		if not bTransitioned then
			status = subTreeTick:exec(pSubBt, agent)
			bTransitioned, nextStateId = State.s_updateAlwaysTransitions(self, agent, tick, self.m_transitions, status)
		end

		if bTransitioned then
			self:abortSubtreeTick(agent, tick)

			status = EBTStatus.BT_SUCCESS
		end

		self:setNextStateId(tick, nextStateId)
	elseif childStatus == EBTStatus.BT_RUNNING then
		status = subTreeTick:execWithChildStatus(pSubBt, agent, childStatus)
	else
		self:abortSubtreeTick(agent, tick)

		status = childStatus
	end

	return status
end

function _M:traverse(childFirst, handler, agent, tick, userData)
	if childFirst then
		local subTreeTick = self:getSubTreeTick(tick)
		local pSubBt = subTreeTick and subTreeTick:getBt()

		if pSubBt then
			pSubBt:traverse(childFirst, handler, agent, subTreeTick, userData)
		end

		handler(self, agent, tick, userData)
	elseif handler(self, agent, userData) then
		local subTreeTick = self:getSubTreeTick(tick)
		local pSubBt = subTreeTick and subTreeTick:getBt()

		if pSubBt then
			pSubBt:traverse(childFirst, handler, agent, subTreeTick, userData)
		end
	end
end

function _M:abortSubtreeTick(agent, tick)
	local subTreeTick = self:getSubTreeTick(tick)
	local pSubBt = subTreeTick and subTreeTick:getBt()

	if pSubBt then
		subTreeTick:abort(pSubBt, agent)
		agent:removeCurrentRunningTreeTick(subTreeTick)
		self:setNextStateId(tick, -1)
		agent:releaseTreeTick(subTreeTick)
		self:setSubTreeTick(tick, false)
	end
end

function _M:setNextStateId(tick, id)
	tick:setNodeMem("nextStateId", id, self)
end

function _M:getNextStateId(tick)
	return tick:getNodeMem("nextStateId", self)
end

function _M:setSubTreeTick(tick, subTree)
	tick:setNodeMem("subTreeTick", subTree, self)
end

function _M:getSubTreeTick(tick)
	return tick:getNodeMem("subTreeTick", self)
end

function _M:initReferenceBehaviorLocalParams(agent, tick)
	local params = agent:getSubTreeLocalParams()
	local subTreeTick = self:getSubTreeTick(tick)

	if params then
		for k, v in pairs(params) do
			subTreeTick:setLocalVariable(k, v)
		end
	end

	if self.m_subTreeProperties then
		for _, prop in ipairs(self.m_subTreeProperties) do
			subTreeTick:setLocalVariable(prop.Name, prop.Value:getValue(agent, tick))
		end
	end
end

return _M
