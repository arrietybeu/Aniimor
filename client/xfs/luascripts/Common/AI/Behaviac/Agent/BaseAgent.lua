-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\Behaviac\\Agent\\BaseAgent.lua

local enums = require("Common.AI.Behaviac.Enums")
local common = require("Common.AI.Behaviac.Common")
local macros = require("Common.AI.Behaviac.Macros")
local functions = require("Common.AI.Behaviac.Functions")
local ConstValueReader = require("Common.AI.Behaviac.Parser.ConstValueReader")
local CallbackHandlerNoGC = require("Core.Common.CallbackHandlerNoGC")
local AiConst = require("Common.Const.AiConst")
local AIUtils = require("Common.Utils.AIUtils")
local LuaMethodEnum = require("Common.Const.luaMethodEnum")
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
local table_clear = table.clear
local Class = require("Core.Framework.Class")
local BaseAgent = Class.Class("BaseAgent")
local _M = BaseAgent
local AgentMeta = require("Common.AI.Behaviac.Agent.AgentMeta")
local Blackboard = require("Common.AI.Behaviac.Agent.Blackboard")
local Tick = require("Common.AI.Behaviac.Agent.Tick")
local BehaviorTreeFactory = require("Common.AI.Behaviac.Parser.BehaviorTreeFactory")
local debugger = require("Common.AI.Behaviac.Debugger")
local globalDeclare = require("Core.Framework.Global")
local lume = require("Core.Common.lume")
local ActionResumeType = enums.ActionResumeType
local TimerManager = require("Core.Timer.TimerManager")

_M.aiAgent = {}
_M.aiAgent.s_agent_index = 0
_M.aiAgent.s_agent_type_index = {}
_M.aiAgent.s_agent_behaviorTreeTick_pool = {}

function _M:ctor()
	self.m_id = -1
	self.m_bActive = false
	self.m_name = "FirstAgent_0_0"
	self.m_objectTypeName = "FirstAgent"
	self.m_agentName = "FirstAgent#FirstAgent_0_0"
	self.m_blackboard = Blackboard.new(self)
	self.m_ttStack = {}
	self.m_currentTreeTick = false
	self.m_referencetree = false
	self.m_currentRunningActionDic = {}
	self.m_behaviorTreeTickStack = {}
	self.m_subTreeParamData = {}
	self.EAgentType = AiConst.EAgentType.luaAgent
	self.bxNextTimerId = nil
end

function _M:init()
	self.m_blackboard:init()

	self.m_bActive = true
end

function _M:release()
	AgentMeta.unRegisterInstance(self:getInstanceName())

	self.m_id = -1
	self.m_bActive = false
	self.m_name = ""
	self.m_objectTypeName = ""
	self.m_agentName = ""

	self.m_blackboard:release()
	table_clear(self.m_ttStack)

	self.m_currentTreeTick = false
	self.m_referencetree = false

	table_clear(self.m_currentRunningActionDic)
	table_clear(self.m_behaviorTreeTickStack)
	table_clear(self.m_subTreeParamData)
	self:_releaseNextFrameResetCurrentTreeTick()
	self:postComponentMethod("onRelease")
end

function _M:initAgent(agentType, instanceName)
	if self.m_id < 0 and #agentType > 0 then
		self.m_id = _M.aiAgent.s_agent_index
		_M.aiAgent.s_agent_index = _M.aiAgent.s_agent_index + 1
		self.m_objectTypeName = agentType
		self.m_name = instanceName
		self.m_agentName = self:getObjectTypeName() .. "#" .. self:getInstanceName()

		AgentMeta.registerInstance(self:getInstanceName(), self)
	end

	return true
end

function _M:startAgent()
	self:postComponentMethod("onStartAgent")
end

function _M:getBlackBoardProperty(key)
	return self.m_blackboard.m_baseMemory[key]
end

function _M:setBlackBoardProperty(key, value)
	self.m_blackboard.m_baseMemory[key] = value
end

function _M:getLocalVariable(key)
	local curTreeTick = self:getCurrentRunningTreeTick()

	if curTreeTick then
		return curTreeTick:getLocalVariable(key)
	end
end

function _M:setLocalVariable(key, value, keyMustExist)
	local curTreeTick = self:getCurrentRunningTreeTick()

	if curTreeTick then
		return curTreeTick:setLocalVariable(key, value, keyMustExist)
	end

	return false
end

function _M:traverseAllBlackboardProperties(handler)
	local tCurrentTick = self.m_currentTreeTick

	for k, v in pairs(tCurrentTick.m_blackboard.m_baseMemory) do
		handler(self, tostring(k), tostring(v))
	end

	local tCurrentBt, tCurrentTargetNode
	local deadCount = 0

	while true do
		tCurrentBt = tCurrentTick:getBt()
		tCurrentTargetNode = tCurrentBt:getCurrentVisitingNode(tCurrentTick)

		if tCurrentTargetNode then
			for k, v in pairs(tCurrentTick.m_blackboard:getMemory(tCurrentBt, tCurrentTargetNode)) do
				handler(self, tostring(k), tostring(v))
			end

			if tCurrentTargetNode:isReferencedBehavior() then
				tCurrentTick = tCurrentTargetNode:getSubTreeTick(tCurrentTick)
			elseif tCurrentTargetNode:isFSM() then
				local state = tCurrentTargetNode:getChildById(tCurrentTargetNode:getCurrentNodeId(tCurrentTick))

				if state:isReferencedBehavior() then
					tCurrentTick = state:getSubTreeTick(tCurrentTick)
				else
					break
				end
			else
				break
			end
		else
			break
		end

		if tCurrentTick == false or tCurrentTick == nil then
			break
		end

		deadCount = deadCount + 1

		if deadCount > 100 then
			Logging.error("travelAllBlackboardProperties dead loop!!")

			break
		end
	end
end

function _M:setAIBlackBoardProperties(properties)
	for _, v in ipairs(properties) do
		local value = v.defaultValue
		local notInit = Blackboard.get(self.m_blackboard, v.name) == nil

		if notInit then
			Blackboard.set(self.m_blackboard, v.name, value)
		end
	end
end

local function _btExecDebug(agent)
	if debugger.start_debug then
		debugger.lib.logFrames(agent)
		debugger.lib.handleRequests()
	end

	if agent.m_bActive then
		local s = agent:btExec_()

		while agent.m_referencetree and s == EBTStatus.BT_RUNNING do
			agent.m_referencetree = false
			s = agent:btExec_()
		end

		if debugger.start_debug then
			debugger.lib.logFrameEnd(agent)
		end

		return s
	end

	if debugger.start_debug then
		debugger.lib.logFrameEnd(agent)
	end

	return EBTStatus.BT_INVALID
end

local function _btExec(agent)
	if agent.m_bActive then
		agent.inBtExec = true

		local s = agent:btExec_()

		while agent.m_referencetree and s == EBTStatus.BT_RUNNING do
			agent.m_referencetree = false
			s = agent:btExec_()
		end

		agent.inBtExec = false

		return s
	end

	return EBTStatus.BT_INVALID
end

_M.btExec = _btExec

function _M:switchToDebugMode(debug)
	self:forceAttrRepeat("btExec")

	self.btExec = debug and _btExecDebug or _btExec

	self:clearAttrRepeat()
end

function _M:btExec_()
	if self.m_currentTreeTick then
		local pLast = self.m_currentTreeTick
		local pBt = self.m_currentTreeTick:getBt()
		local s = self.m_currentTreeTick:exec(pBt, self)

		while s ~= EBTStatus.BT_RUNNING do
			local len = #self.m_ttStack

			if len > 0 then
				local lastOne = self.m_ttStack[len]

				table.remove(self.m_ttStack, len)

				self.m_currentTreeTick = lastOne.tt

				local bExecCurrent = false

				if lastOne.triggerMode == TriggerMode.TM_Return then
					if not lastOne.triggerByEvent then
						if self.m_currentTreeTick ~= pLast then
							s = self.m_currentTreeTick:resume(self, s)
						end
					else
						bExecCurrent = true
					end
				else
					bExecCurrent = true
				end

				if bExecCurrent then
					pLast = self.m_currentTreeTick
					pBt = self.m_currentTreeTick:getBt()
					s = self.m_currentTreeTick:exec(pBt, self)

					break
				end
			else
				break
			end
		end

		if s ~= EBTStatus.BT_RUNNING then
			self.m_currentBlackboard = 0
		end

		return s
	end

	return EBTStatus.BT_INVALID
end

function _M:_btSetCurrent(treeEnumName, triggerMode, byEvent)
	if self.m_currentTreeTick then
		if triggerMode == TriggerMode.TM_Return then
			local item = {
				tt = self.m_currentTreeTick,
				triggerMode = triggerMode,
				triggerByEvent = byEvent
			}

			macros.BEHAVIAC_ASSERT(#self.m_ttStack < 200, "recursive?")
			table.insert(self.m_ttStack, item)
		else
			local pBt = self.m_currentTreeTick:getBt()

			self.m_currentTreeTick:abort(pBt, self)
			self.m_currentTreeTick:reset(pBt, self)
		end
	end

	local referenceTreePath = AgentMeta.getBehaviorTreePath(treeEnumName)
	local pTick

	if triggerMode == TriggerMode.TM_Reload then
		BehaviorTreeFactory.clearCache(referenceTreePath)

		pTick = self:btCreateTreeTick(referenceTreePath)
	else
		pTick = self:getCurTreeTick(referenceTreePath)
	end

	if not pTick then
		self.m_currentTreeTick = false

		return false
	end

	self.m_currentTreeTick = pTick

	self:initAgent(pTick:getBt():getAgentType(), self.ent.actorId)
	self:addCurrentRunningTreeTick(pTick)

	return pTick
end

function _M:getCurTreeTick(relativeTreePath)
	if relativeTreePath == nil then
		return false
	end

	if not _M.aiAgent.s_agent_behaviorTreeTick_pool[relativeTreePath] then
		_M.aiAgent.s_agent_behaviorTreeTick_pool[relativeTreePath] = {}
	end

	local tRelativePathTreeTick = _M.aiAgent.s_agent_behaviorTreeTick_pool[relativeTreePath]

	if #tRelativePathTreeTick > 0 then
		local pTick = tRelativePathTreeTick[#tRelativePathTreeTick]

		table.remove(tRelativePathTreeTick, #tRelativePathTreeTick)
		pTick:rebind(self.m_blackboard, relativeTreePath)
		pTick:init()

		return pTick
	else
		return self:btCreateTreeTick(relativeTreePath)
	end
end

function _M:releaseTreeTick(tick)
	if tick then
		local pBt = tick:getBt()
		local treeName = pBt:getRelativePath()

		if not _M.aiAgent.s_agent_behaviorTreeTick_pool[treeName] then
			_M.aiAgent.s_agent_behaviorTreeTick_pool[treeName] = {}
		end

		self.m_blackboard:clearTreeMemory(tick)
		table.insert(_M.aiAgent.s_agent_behaviorTreeTick_pool[treeName], tick)
	end
end

function _M.clearAllTreeTickPool()
	if not _M.aiAgent.s_agent_behaviorTreeTick_pool then
		return
	end

	table_clear(_M.aiAgent.s_agent_behaviorTreeTick_pool)
end

function _M:btSetCurrent(relativeTreePath)
	return self:_btSetCurrent(relativeTreePath, TriggerMode.TM_Transfer, false)
end

function _M:btReferenceTree(relativeTreePath)
	self.m_referencetree = true

	return self:_btSetCurrent(relativeTreePath, TriggerMode.TM_Return, false)
end

function _M:btEventTree(relativeTreePath, triggerMode)
	return self:_btSetCurrent(relativeTreePath, triggerMode, true)
end

function _M:btOnEvent(eventName, eventParams)
	if self.m_currentTreeTick then
		local tCurrentTick = self.m_currentTreeTick
		local pBt = tCurrentTick:getBt()

		pBt:onEvent(self, tCurrentTick, eventName, eventParams)
	end
end

function _M:btCreateTreeTick(relativeTreePath)
	local bt = BehaviorTreeFactory.preloadBehaviorTree(relativeTreePath)

	if not bt then
		return nil
	end

	local tick = Tick.new(bt, self.m_blackboard, relativeTreePath)

	tick:init()

	return tick
end

function _M:fireEvent(eventName, ...)
	local eventParams = {}
	local nargs = select("#", ...)

	for i = 1, nargs do
		local param = select(i, ...)
		local paramName = enums.BEHAVIAC_LOCAL_TASK_PARAM_PRE .. tostring(i - 1)

		table.insert(eventParams, {
			paramName,
			param
		})
	end

	self:btOnEvent(eventName, eventParams)
end

function _M:getInstanceName()
	return self.m_name
end

function _M:getObjectTypeName()
	return self.m_objectTypeName
end

function _M:getDebugAgentName()
	if string.isNilOrEmpty(self.m_agentName) then
		self.m_agentName = self:getObjectTypeName() .. "#" .. self:getInstanceName()
	end

	return self.m_agentName
end

function _M:isActive()
	return self.m_bActive
end

function _M:_resetCurrentTreeTick()
	self.bxNextTimerId = nil

	if AIUtils.checkOpenCPP() then
		if self.ent then
			pg.world.resetBXAgentCurrentTree(self.ent.actorId)
		end
	else
		if self.m_currentTreeTick then
			local pBt = self.m_currentTreeTick:getBt()

			self.m_currentTreeTick:abort(pBt, self)
		end

		self:clearRunningActionDic()
	end
end

function _M:resetCurrentTreeTick()
	if self.inBtExec then
		self:_addNextFrameResetCurrentTreeTick()
	else
		self:_resetCurrentTreeTick()
	end
end

function _M:_addNextFrameResetCurrentTreeTick()
	self:_releaseNextFrameResetCurrentTreeTick()

	self.bxNextTimerId = TimerManager.addNextFrameCb(CallbackHandlerNoGC.new(self, self._resetCurrentTreeTick))
end

function _M:_releaseNextFrameResetCurrentTreeTick()
	if self.bxNextTimerId then
		TimerManager.delFrameCb(self.bxNextTimerId)

		self.bxNextTimerId = nil
	end
end

function _M:getCurrentTreeTick()
	return self.m_currentTreeTick
end

function _M:getCurrentRunningTreeTick()
	return self.m_behaviorTreeTickStack[#self.m_behaviorTreeTickStack]
end

function _M:addCurrentRunningTreeTick(tick)
	table.insert(self.m_behaviorTreeTickStack, tick)
end

function _M:removeCurrentRunningTreeTick(tick)
	if self.m_behaviorTreeTickStack[#self.m_behaviorTreeTickStack] ~= tick then
		Logging.error("removeCurrentRunningTreeTick error")

		return
	end

	table.remove(self.m_behaviorTreeTickStack, #self.m_behaviorTreeTickStack)
end

function _M:addRunningAction(action, tick)
	self.m_currentRunningActionDic[action] = tick
end

function _M:removeRunningAction(action)
	self.m_currentRunningActionDic[action] = nil
end

function _M:clearRunningActionDic()
	self.m_currentRunningActionDic = {}
end

function _M:pauseRunningAction()
	if AIUtils.checkOpenCPP() then
		pg.world.pauseBXAgent(self.ent.actorId)
	else
		local tActionResumeTree = false

		for _action, _tick in pairs(self.m_currentRunningActionDic) do
			if _action:pauseAction(self, _tick) == ActionResumeType.BT_ResumeTree then
				tActionResumeTree = true
			end
		end

		if tActionResumeTree then
			self:resetCurrentTreeTick()
		end
	end

	self:postComponentMethod("onPauseAgent")
end

function _M:resumeRunningAction()
	self:postComponentMethod("onResumeAgent")
end

function _M:bxPauseUnityEditor()
	if UNITY_EDITOR then
		appFacade.PauseUnity()
	end
end

function _M:bxCall(methodIndex, ...)
	local methodName = LuaMethodEnum[methodIndex]

	return self[methodName](self, ...)
end

if UNITY_EDITOR then
	function _M:bxCallDebug(nodeId, methodIndex, ...)
		local methodName = LuaMethodEnum[methodIndex]

		if AIUtils.checkAINodeDebug(self.ent.actorId) then
			local isRunningNode = LuaMethodEnum[methodIndex + AiConst.LuaMethodResetStateOffset]

			if isRunningNode then
				local args = {
					...
				}

				for i = 1, #args do
					args[i] = tostring(args[i])
				end

				self:_debugSettingRunningAction("(" .. nodeId .. ")" .. methodName .. "(" .. table.concat(args, ", ") .. ")")
			end
		end

		return self[methodName](self, ...)
	end
else
	function _M:bxCallDebug(nodeId, methodIndex, ...)
		return self[LuaMethodEnum[methodIndex]](self, ...)
	end
end

function _M:setSubTreeLocalParams(params)
	self:clearSubTreeLocalParams()

	if not params then
		return
	end

	local val = self.m_subTreeParamData

	for k, v in pairs(params) do
		val[k] = v
	end
end

function _M:addSubTreeLocalParam(key, value)
	self.m_subTreeParamData[key] = value
end

function _M:clearSubTreeLocalParams()
	local val = self.m_subTreeParamData

	if val then
		table_clear(val)
	end
end

function _M:getSubTreeLocalParams()
	return self.m_subTreeParamData
end

function _M:existSubtreeLocalParam(subTreeId, key)
	return self.m_subTreeParamData[key] ~= nil
end

function _M:getSubtreeLocalParamByKey(subTreeId, key)
	return self.m_subTreeParamData[key]
end

return _M
