-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\Behaviac\\Core\\BaseNode.lua

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
local BaseNode = functions.class("BaseNode")

macros.ADD_BEHAVIAC_DYNAMIC_TYPE("BaseNode", BaseNode)

local _M = BaseNode

function _M:ctor()
	self.m_nodeClassName = ""
	self.m_id = 0
	self.m_agentType = ""
	self.m_bHasEvents = false
	self.m_children = false
	self.m_preconditions = {}
	self.m_effectors = {}
	self.m_events = {}
	self.m_customCondition = false
	self.m_parent = false
	self.m_loadAttachment = false
	self.m_enterPrecond = 0
	self.m_updatePrecond = 0
	self.m_bothPrecond = 0
	self.m_successEffectors = 0
	self.m_failureEffectors = 0
	self.m_bothEffectors = 0

	function self.m_loaderCallback()
		return
	end

	self.m_nodeFactory = require("Common.AI.Behaviac.Parser.NodeFactory")
end

function _M:release()
	self:clear()
end

function _M:clear()
	if self.m_children then
		for _, child in ipairs(self.m_children) do
			child:release()
		end

		self.m_children = false
	end

	if self.m_customCondition then
		self.m_customCondition:release()

		self.m_customCondition = false
	end
end

function _M:onLoading(version, agentType, properties)
	self:m_loaderCallback(version, agentType, properties)
end

function _M:attach(attachmentNode, isPrecondition, isEffector, isTransition)
	macros.BEHAVIAC_ASSERT(isTransition == false, "isTransition must be false")

	if isPrecondition then
		macros.BEHAVIAC_ASSERT(not isEffector)
		macros.BEHAVIAC_ASSERT(attachmentNode)
		table.insert(self.m_preconditions, attachmentNode)

		local phase = attachmentNode:getPhase()

		if phase == EPreconditionPhase.E_ENTER then
			self.m_enterPrecond = self.m_enterPrecond + 1
		elseif phase == EPreconditionPhase.E_UPDATE then
			self.m_updatePrecond = self.m_updatePrecond + 1
		elseif phase == EPreconditionPhase.E_BOTH then
			self.m_bothPrecond = self.m_bothPrecond + 1
		else
			macros.BEHAVIAC_ASSERT(false, "[_M:attach()] isPrecondition error EPreconditionPhase = %d", phase)
		end
	elseif isEffector then
		macros.BEHAVIAC_ASSERT(not isPrecondition)
		macros.BEHAVIAC_ASSERT(attachmentNode)
		table.insert(self.m_effectors, attachmentNode)

		local phase = attachmentNode:getPhase()

		if phase == ENodePhase.E_SUCCESS then
			self.m_successEffectors = self.m_successEffectors + 1
		elseif phase == ENodePhase.E_FAILURE then
			self.m_failureEffectors = self.m_failureEffectors + 1
		elseif phase == ENodePhase.E_BOTH then
			self.m_bothEffectors = self.m_bothEffectors + 1
		else
			macros.BEHAVIAC_ASSERT(false, "[_M:attach()] isEffector error ENodePhase = %d", phase)
		end
	else
		table.insert(self.m_events, attachmentNode)
	end
end

function _M:combineResults(firstValidPrecond, lastCombineValue, precond, taskBoolean)
	if firstValidPrecond then
		firstValidPrecond = false
		lastCombineValue = taskBoolean
	else
		local andOp = precond:isAnd()

		if andOp then
			lastCombineValue = lastCombineValue and taskBoolean
		else
			lastCombineValue = lastCombineValue or taskBoolean
		end
	end

	return firstValidPrecond, lastCombineValue
end

function _M:hasEvents()
	return self.m_bHasEvents
end

function _M:setEvents(hasEvents)
	self.m_bHasEvents = hasEvents
end

function _M:setClassNameString(nodeClassName)
	self.m_nodeClassName = nodeClassName
end

function _M:getClassNameString()
	return self.m_nodeClassName
end

function _M:setId(id)
	self.m_id = id
end

function _M:getId()
	return self.m_id
end

function _M:setAgentType(agentType)
	self.m_agentType = agentType
end

function _M:getAgentType()
	return self.m_agentType
end

function _M:setParent(parentNode)
	self.m_parent = parentNode
end

function _M:getParent()
	return self.m_parent
end

function _M:getRoot()
	local node = self

	while node.m_parent do
		node = node.m_parent
	end

	macros.BEHAVIAC_ASSERT(node.isBehaviorTree(), "[_M:getParent()] root must be BehaviorTree!!!")

	return node
end

function _M:getChildrenCount()
	if self.m_children then
		return #self.m_children
	else
		return 0
	end
end

function _M:addChild(childNode)
	childNode.m_parent = self

	if not self.m_children then
		self.m_children = {}
	end

	table.insert(self.m_children, childNode)
end

function _M:getChild(index)
	if self.m_children then
		return self.m_children[index]
	else
		return false
	end
end

function _M:getChildById(nodeId)
	if not self.m_children then
		return false
	end

	for _, child in ipairs(self.m_children) do
		if child:getId() == nodeId then
			return child
		end
	end

	return false
end

function _M:setCustomCondition(node)
	self.m_customCondition = node
end

function _M:loadLocal(version, agentType, dataEntry)
	return
end

function _M:isManagingChildrenAsSubTrees()
	return false
end

function _M:isBehaviorTree()
	return false
end

function _M:isBranch()
	return false
end

function _M:isEvent()
	return false
end

function _M:isAnd()
	return false
end

function _M:isReferencedBehavior()
	return false
end

function _M:isState()
	return false
end

function _M:isFSM()
	return false
end

function _M:isDecorator()
	return false
end

function _M:init(tick)
	self:setStatus(tick, EBTStatus.BT_INVALID)
	self:setHasManagingParent(tick, false)
end

function _M:onReset(agent, tick)
	return true
end

function _M:onEnter(agent, tick)
	return true
end

function _M:onExit(agent, tick, status)
	return true
end

function _M:onEvent(agent, tick, eventName, eventParams)
	local status = self:getStatus(tick)

	if status == EBTStatus.BT_RUNNING and self:hasEvents() and not self:checkEvents(agent, tick, eventName, eventParams) then
		return false
	end

	return true
end

function _M:applyEffects(agent, tick, phase)
	if #self.m_effectors == 0 then
		return
	end

	if self.m_bothEffectors == 0 then
		if phase == ENodePhase.E_SUCCESS and self.m_successEffectors == 0 then
			return
		end

		if phase == ENodePhase.E_FAILURE and self.m_failureEffectors == 0 then
			return
		end
	end

	for _, effector in ipairs(self.m_effectors) do
		local ph = effector:getPhase()

		if phase == ENodePhase.E_BOTH or ph == ENodePhase.E_BOTH or ph == phase then
			effector:evaluate(agent, tick)
		end
	end
end

function _M:checkPreconditions(agent, tick, isAlive)
	local phase = isAlive and EPreconditionPhase.E_UPDATE or EPreconditionPhase.E_ENTER

	if #self.m_preconditions == 0 then
		return true
	end

	if self.m_bothPrecond == 0 then
		if phase == EPreconditionPhase.E_ENTER and self.m_enterPrecond == 0 then
			return true
		end

		if phase == EPreconditionPhase.E_UPDATE and self.m_updatePrecond == 0 then
			return true
		end
	end

	local firstValidPrecond = true
	local lastCombineValue = false

	for _, precond in ipairs(self.m_preconditions) do
		local ph = precond:getPhase()

		if ph == EPreconditionPhase.E_BOTH or ph == phase then
			local taskBoolean = precond:evaluate(agent, tick)

			firstValidPrecond, lastCombineValue = self:combineResults(firstValidPrecond, lastCombineValue, precond, taskBoolean)
		end
	end

	return lastCombineValue
end

function _M:checkEvents(agent, tick, eventName, eventParams)
	if #self.m_events > 0 then
		for _, event in ipairs(self.m_events) do
			if event:isEvent() and not StringUtils.isNullOrEmpty(eventName) then
				local en = event:getEventName()

				if not StringUtils.isNullOrEmpty(en) and en == eventName then
					event:switchTo(agent, eventParams)

					if event:triggeredOnce() then
						return false
					end
				end
			end
		end
	end

	return true
end

function _M:updateCurrent(agent, tick, childStatus)
	return self:update(agent, tick, childStatus)
end

function _M:update(agent, tick, childStatus)
	return EBTStatus.BT_SUCCESS
end

function _M:evaluate(agent, tick)
	Logging.error("[_M:evaluate()] must be inheritance, Only Condition/Sequence/And/Or allowed")

	return false
end

function _M:evaluteCustomCondition(agent, tick)
	if self.m_customCondition then
		return self.m_customCondition:evaluate(agent, tick)
	end

	return false
end

function _M:evaluateImpl(agent, tick, childrenStatus)
	return EBTStatus.BT_FAILURE
end

function _M:setStatus(tick, status)
	tick:setNodeMem("status", status, self)
end

function _M:getStatus(tick)
	return tick:getNodeMem("status", self)
end

function _M:setResumeType(tick, resumeType)
	tick:setNodeMem("resumeType", resumeType, self)
end

function _M:getResumeType(tick)
	return tick:getNodeMem("resumeType", self)
end

function _M:setHasManagingParent(tick, bHasManagingParent)
	tick:setNodeMem("hasManagingParent", bHasManagingParent, self)
end

function _M:getHasManagingParent(tick)
	return tick:getNodeMem("hasManagingParent", self)
end

function _M:setCurrentVisitingNode(tick, visitingNode)
	return
end

function _M:getCurrentVisitingNode(tick)
	return
end

return _M
