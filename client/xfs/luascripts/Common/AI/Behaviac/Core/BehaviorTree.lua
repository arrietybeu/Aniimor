-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\Behaviac\\Core\\BehaviorTree.lua

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
local constBsonElementType = enums.constBsonElementType
local Logging = common.d_log
local StringUtils = common.StringUtils
local SingleChild = require("Common.AI.Behaviac.Core.SingleChild")
local BehaviorTree = functions.class("BehaviorTree", SingleChild)

macros.ADD_BEHAVIAC_DYNAMIC_TYPE("BehaviorTree", BehaviorTree)
macros.BEHAVIAC_DECLARE_DYNAMIC_TYPE("BehaviorTree", "SingleChild")

local _M = BehaviorTree
local NodeParser = require("Common.AI.Behaviac.Parser.NodeParser")
local NodeLoader = require("Common.AI.Behaviac.Parser.NodeLoader")
local AgentMeta = require("Common.AI.Behaviac.Agent.AgentMeta")
local bson = require("Common.AI.Behaviac.External.bson")
local BsonNodeLoader = require("Common.AI.Behaviac.Parser.BsonNodeLoader")
local debugger = require("Common.AI.Behaviac.Debugger")

function _M:ctor()
	_M.super.ctor(self)

	self.m_name = ""
	self.m_version = 0
	self.m_relativePath = ""
	self.m_domains = ""
	self.m_bIsFSM = false
	self.m_localProps = {}
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

		if nameStr == constBaseKeyStrDef.kStrDomains then
			self.m_domains = valueStr
		elseif nameStr == constBaseKeyStrDef.kStrDescriptorRefs then
			-- block empty
		end
	end
end

function _M:getName()
	return self.m_name
end

function _M:setName(name)
	self.m_name = name
end

function _M:getVersion()
	return self.m_version
end

function _M:setVersion(version)
	self.m_version = version
end

function _M:getRelativePath()
	return self.m_relativePath
end

function _M:setRelativePath(path)
	self.m_relativePath = path
end

function _M:getDomains()
	return self.m_domains
end

function _M:setDomains(domains)
	self.m_domains = domains
end

function _M:isFSM()
	return self.m_bIsFSM
end

function _M:load(treeData, behaviorTreePath)
	local behaviorEntry = treeData[constBaseKeyStrDef.kStrBehavior]

	if not behaviorEntry then
		Logging.error("[_M:load()] file(%s) is invalid!!!", behaviorTreePath)

		return
	end

	local name = behaviorEntry[constBaseKeyStrDef.kStrName]
	local agentType = behaviorEntry[constBaseKeyStrDef.kStrAgentType]
	local version = tonumber(behaviorEntry[constBaseKeyStrDef.kStrVersion]) or 0

	self:setName(name)
	self:setVersion(version)
	self:setRelativePath(behaviorTreePath)
	self:setClassNameString("BehaviorTree")
	self:setId(-1)

	if behaviorEntry.fsm == true then
		self.m_bIsFSM = true

		self:setClassNameString("FSM")
	end

	NodeLoader.loadPropertiesParsAttachmentsChildren(self, version, agentType, behaviorEntry)

	return true
end

function _M:isManagingChildrenAsSubTrees()
	return true
end

function _M:isBehaviorTree()
	return true
end

function _M:init(tick)
	_M.super.init(self, tick)
	self:instantiatePars(tick)
end

local function _onEnterDebug(node, agent, tick)
	if debugger.start_debug then
		debugger.lib.logJumpTree(agent, node:getName(), node:getVersion())
	end

	return true
end

local function _onEnter(node, agent, tick)
	return true
end

local function _onExitDebug(node, agent, tick, status)
	if debugger.start_debug then
		debugger.lib.logReturnTree(agent, node:getName())
	end

	return _M.super.onExit(node, agent, tick, status)
end

local function _onExit(node, agent, tick, status)
	return _M.super.onExit(node, agent, tick, status)
end

_M.onEnter = _onEnter
_M.onExit = _onExit

function _M.switchToDebugMode(debug)
	_M.onEnter = debug and _onEnterDebug or _onEnter
	_M.onExit = debug and _onExitDebug or _onExit
end

function _M:updateCurrent(agent, tick, childStatus)
	if self:isFSM() then
		return self:update(agent, tick, childStatus)
	else
		return _M.super.updateCurrent(self, agent, tick, childStatus)
	end
end

function _M:update(agent, tick, childStatus)
	if childStatus ~= EBTStatus.BT_RUNNING then
		return childStatus
	end

	local status = EBTStatus.BT_INVALID

	self:setEndStatus(tick, EBTStatus.BT_INVALID)

	status = _M.super.update(self, agent, tick, childStatus)

	local endStatus = self:getEndStatus(tick)

	if status == EBTStatus.BT_RUNNING and endStatus ~= EBTStatus.BT_INVALID then
		tick:endDo(self, agent, endStatus)

		return endStatus
	end

	return status
end

function _M:resume(agent, tick, status)
	return _M.super.resumeBranch(self, agent, tick, status)
end

function _M:instantiatePars(tick)
	if #self.m_localProps > 0 then
		tick:addLocalVariables(self.m_localProps)
	end
end

function _M:setEndStatus(tick, status)
	tick:setNodeMem("endStatus", status, self)
end

function _M:getEndStatus(tick)
	return tick:getNodeMem("endStatus", self)
end

return _M
