-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\Behaviac\\Agent\\Tick.lua

local _M = {}
local enums = require("Common.AI.Behaviac.Enums")
local common = require("Common.AI.Behaviac.Common")
local macros = require("Common.AI.Behaviac.Macros")
local functions = require("Common.AI.Behaviac.Functions")
local Class = require("Core.Framework.Class")
local ListPool = require("Common.Container.ListPool")
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
local Tick = Class.OldLightClass("Tick")
local _M = Tick
local Blackboard = require("Common.AI.Behaviac.Agent.Blackboard")
local debugger = require("Common.AI.Behaviac.Debugger")

function _M:ctor(bt, blackboard, relativeTreePath)
	self.m_bt = bt
	self.m_blackboard = blackboard
	self.m_relativeTreePath = relativeTreePath
	self.m_tickMem = blackboard:getTreeMemory(self, relativeTreePath)
	self.m_localVars = {}
end

function _M:rebind(blackboard, relativeTreePath)
	self.m_blackboard = blackboard
	self.m_relativeTreePath = relativeTreePath
	self.m_tickMem = blackboard:getTreeMemory(self, relativeTreePath)

	table.clear(self.m_localVars)
end

function _M:init()
	self.m_bt:init(self)
end

function _M:exec(targetNode, agent)
	if EnableBotTest then
		return
	end

	local childStatus = EBTStatus.BT_RUNNING

	return self:execWithChildStatus(targetNode, agent, childStatus)
end

local function _testEnterNodeDebug(tick, node, agent, status)
	local bEnterResult = false

	if status == EBTStatus.BT_RUNNING then
		bEnterResult = true
	else
		status = EBTStatus.BT_INVALID
		bEnterResult = tick:onEnterAction(node, agent)
	end

	if bEnterResult and debugger.start_debug then
		debugger.lib.logUpdate(agent, node)
		debugger.lib.logVariables(agent)
	end

	return bEnterResult, status
end

local function _testEnterNode(tick, node, agent, status)
	if status == EBTStatus.BT_RUNNING then
		return true, status
	else
		return tick:onEnterAction(node, agent), EBTStatus.BT_INVALID
	end
end

_M._testEnterNodeImpl = _testEnterNode

function _M:execWithChildStatus(targetNode, agent, childStatus)
	local status = targetNode:getStatus(self)

	if _M._testEnterNodeImpl(self, targetNode, agent, status) then
		local bValid = self:checkParentUpdatePreconditions(targetNode, agent)

		if bValid then
			status = targetNode:updateCurrent(agent, self, childStatus)
		else
			status = EBTStatus.BT_FAILURE

			if targetNode:getCurrentVisitingNode(self) then
				targetNode:updateCurrent(agent, self, EBTStatus.BT_FAILURE)
			end
		end

		if status ~= EBTStatus.BT_RUNNING then
			self:onExitAction(targetNode, agent, status)
		else
			local tree = self:getTopManageBranchNode(targetNode)

			if tree then
				tree:markVisiting(self, targetNode)
			end
		end
	else
		status = EBTStatus.BT_FAILURE
	end

	targetNode:setStatus(self, status)

	return status
end

local tmpParentCheckList = {}

function _M:checkParentUpdatePreconditions(targetNode, agent)
	local bValid = true
	local bHasManagingParent = targetNode:getHasManagingParent(self)

	if bHasManagingParent then
		bHasManagingParent = false

		local kMaxParentsCount = 100
		local parentBranch = targetNode:getParent()

		table.insert(tmpParentCheckList, targetNode)

		while parentBranch do
			if kMaxParentsCount <= #tmpParentCheckList then
				Logging.error("[_M:checkParentUpdatePreconditions()] weird tree!")

				break
			end

			table.insert(tmpParentCheckList, parentBranch)

			if parentBranch:getCurrentVisitingNode(self) == targetNode then
				bHasManagingParent = true

				break
			end

			parentBranch = parentBranch:getParent()
		end

		if bHasManagingParent then
			for k = #tmpParentCheckList, 1, -1 do
				bValid = tmpParentCheckList[k]:checkPreconditions(agent, self, true)

				if not bValid then
					break
				end
			end
		end
	else
		bValid = targetNode:checkPreconditions(agent, self, true)
	end

	table.clear(tmpParentCheckList)

	return bValid
end

function _M:getTopManageBranchNode(targetNode)
	local node
	local parent = targetNode.m_parent

	while parent do
		if parent:isBehaviorTree() then
			node = parent

			break
		elseif parent and parent:isManagingChildrenAsSubTrees() then
			break
		elseif parent:isBranch() then
			node = parent
		else
			macros.BEHAVIAC_ASSERT(false, "[_M:getTopManageBranchNode()]")
		end

		parent = parent.m_parent
	end

	return node
end

local function _onEnterActionDebug(tick, targetNode, agent)
	local bResult = targetNode:checkPreconditions(agent, tick, false)

	if not bResult then
		return false
	else
		targetNode:setHasManagingParent(tick, false)
		targetNode:setCurrentVisitingNode(tick, false)

		bResult = targetNode:onEnter(agent, tick)

		if bResult and debugger.start_debug then
			debugger.lib.CHECK_BREAKPOINT(agent, targetNode, "enter", bResult)
			debugger.lib.logVariables(agent)
		end
	end

	return bResult
end

local function _onEnterAction(tick, targetNode, agent)
	local bResult = targetNode:checkPreconditions(agent, tick, false)

	if not bResult then
		return false
	else
		targetNode:setHasManagingParent(tick, false)
		targetNode:setCurrentVisitingNode(tick, false)

		return targetNode:onEnter(agent, tick)
	end
end

local function _onExitActionDebug(tick, targetNode, agent, status)
	targetNode:onExit(agent, tick, status)

	local phase = ENodePhase.E_SUCCESS

	if status == EBTStatus.BT_FAILURE then
		phase = ENodePhase.E_FAILURE
	else
		macros.BEHAVIAC_ASSERT(status == EBTStatus.BT_SUCCESS, string.format("[onExitAction] status (%d) must be EBTStatus.BT_SUCCESS or EBTStatus.BT_FAILURE", status))
	end

	targetNode:applyEffects(agent, tick, phase)

	if debugger.start_debug then
		if status == EBTStatus.BT_SUCCESS then
			debugger.lib.CHECK_BREAKPOINT(agent, targetNode, "exit", true)
		else
			debugger.lib.CHECK_BREAKPOINT(agent, targetNode, "exit", false)
		end

		debugger.lib.logVariables(agent)
	end
end

local function _onExitAction(tick, targetNode, agent, status)
	targetNode:onExit(agent, tick, status)

	local phase = status == EBTStatus.BT_FAILURE and ENodePhase.E_FAILURE or ENodePhase.E_SUCCESS

	targetNode:applyEffects(agent, tick, phase)
end

function _M.onResetAction(tick, targetNode, agent, status)
	targetNode:onReset(agent, tick, status)
end

_M.onEnterAction = _onEnterAction
_M.onExitAction = _onExitAction

function _M.switchToDebugMode(debug)
	_M:forceAttrRepeat("onEnterAction")
	_M:forceAttrRepeat("onExitAction")
	_M:forceAttrRepeat("_testEnterNodeImpl")

	_M.onEnterAction = debug and _onEnterActionDebug or _onEnterAction
	_M.onExitAction = debug and _onExitActionDebug or _onExitAction
	_M._testEnterNodeImpl = debug and _testEnterNodeDebug or _testEnterNode

	_M:clearAttrRepeat()
end

local function _getRunningNodesHandler(node, agent, tick, retNodes)
	local status = node:getStatus(tick)

	if status == EBTStatus.BT_RUNNING then
		table.insert(retNodes, node)
	end

	return true
end

function _M:getRunningNodes(targetNode, onlyLeaves)
	if onlyLeaves == nil then
		onlyLeaves = true
	end

	local nodes = {}

	targetNode:traverse(true, _getRunningNodesHandler, nil, self, nodes)

	if onlyLeaves and #nodes > 0 then
		local leaves = {}

		for _, one in ipairs(nodes) do
			if one:isLeaf() then
				table.insert(leaves, one)
			end
		end

		return leaves
	end

	return nodes
end

local function _abortHandler(node, agent, tick, userData)
	local status = node:getStatus(tick)

	node:setStatus(tick, EBTStatus.BT_INVALID)

	if status == EBTStatus.BT_RUNNING then
		tick:onExitAction(node, agent, EBTStatus.BT_FAILURE)
	end

	node:setCurrentVisitingNode(tick, false)

	return true
end

function _M:abort(targetNode, agent)
	if targetNode:getStatus(self) ~= EBTStatus.BT_RUNNING then
		return
	end

	targetNode:traverse(true, _abortHandler, agent, self, nil)
end

local function _resetHandler(node, agent, tick, userData)
	local status = node:getStatus(tick)

	if status == EBTStatus.BT_RUNNING then
		tick:onResetAction(node, agent, userData)
	end

	node:setStatus(tick, EBTStatus.BT_INVALID)
	node:setCurrentVisitingNode(tick, false)
	node:onReset(agent, tick)

	return true
end

function _M:reset(targetNode, agent)
	if targetNode:getStatus(self) ~= EBTStatus.BT_RUNNING then
		return
	end

	targetNode:traverse(true, _resetHandler, agent, self, nil)
end

local function _endHandler(node, agent, tick, userData)
	local status = node:getStatus(tick)

	if status == EBTStatus.BT_RUNNING or status == EBTStatus.BT_INVALID then
		tick:onExitAction(node, agent, userData)
		node:setStatus(tick, userData)
		node:setCurrentVisitingNode(tick, false)
	end

	return true
end

function _M:endDo(targetNode, agent, status)
	targetNode:traverse(true, _endHandler, agent, self, status)
end

function _M:getBt()
	return self.m_bt
end

function _M:setNodeMem(key, value, node)
	Blackboard.s_setTreeNode(self.m_tickMem, key, value, node)
end

function _M:getNodeMem(key, node)
	return Blackboard.s_getTreeNode(self.m_tickMem, key, node)
end

function _M:setLocalVariable(varName, var, keyMustExist)
	if keyMustExist and self.m_localVars[varName] == nil then
		return false
	end

	self.m_localVars[varName] = var

	return true
end

function _M:addLocalVariables(vars)
	for _, v in ipairs(vars) do
		self.m_localVars[v[1]] = v[2]
	end
end

function _M:getLocalVariable(varName)
	return self.m_localVars[varName]
end

return _M
