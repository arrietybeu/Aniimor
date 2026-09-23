-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\ConditionTrigger\\CTFlow.lua

local lume = require("Core.Common.lume")
local AiConst = require("Common.Const.AiConst")
local CTRConst = require("Common.AICt.CTRConst")
local ListPool = require("Common.Container.ListPool")
local TablePool = require("Common.Container.TablePool")
local PlanPool = require("Common.AI.BehaviacAgent.Unit.Plan.PlanPool")
local CTRPool = require("Common.AICt.CTRPool")
local AIControllerUtils = require("Common.Utils.AIControllerUtils")
local CTUtils = require("Common.AI.ConditionTrigger.CTUtils")
local AIUtils = require("Common.Utils.AIUtils")
local TimerManager = require("Core.Timer.TimerManager")
local LoggerManager = require("Core.Log.LoggerManager")
local logger = LoggerManager.getLogger("CTFlow")
local CallbackHandlerNoGC = require("Core.Common.CallbackHandlerNoGC")
local Class = require("Core.Framework.Class")
local CTFlow = Class.LiteClass("CTFlow")
local __behavCounter = {}

local function __addCount(graphId)
	__behavCounter[graphId] = (__behavCounter[graphId] or 0) + 1
end

function CTFlow.ClearResult()
	__behavCounter = {}
end

function CTFlow.GetResult()
	local result = {}

	for k, v in pairs(__behavCounter) do
		result[#result + 1] = {
			behavId = k,
			count = v
		}
	end

	table.sort(result, function(a, b)
		return a.count > b.count
	end)

	return result
end

local function executeDebugFunc(graph, funcName, actorId)
	if graph and graph.debugMode and graph[funcName] then
		graph[funcName](actorId)
	end
end

function CTFlow:_initInner(owner, behavId, graphId, isAdditive)
	if self.__isAwake then
		logger:error("@LCL 重复激活了决策流, behavId: %s, graphId: %s", behavId, graphId)
	end

	self.__owner = owner
	self.__agent = owner.agent
	self.__actorId = owner.actorId
	self.__behaviourId = behavId
	self.__graphId = graphId
	self.__graph = CTUtils.getGraph(graphId)
	self.__isAdditive = isAdditive
	self.__isAwake = true
	self.__isActive = false
	self.__finishType = CTRConst.FlowFinishType.Break
	self.__finishFunc = nil
	self.__finishFuncObj = nil
	self.__context = TablePool.getTable(3)
	self.__tempListList = ListPool.getList(3)
	self.__interruptTempListList = ListPool.getList(3)
	self.__cacheMap = TablePool.getTable(3)
	self.__cacheTable = TablePool.getTable(3)
	self.__continueNodeId = nil
	self.__continueFlag = false
	self.__checkInterruptFlag = false
	self.__patrolPlan = nil
	self.__subFlow = nil
	self.__timerMap = TablePool.getTable(3)
	self.__activeCallback = nil
	self.__activeFailCallback = nil
	self.__inactiveCallback = nil
end

function CTFlow:initDebug(owner, behavId, graphId, isAdditive)
	self:_initInner(owner, behavId, graphId, isAdditive)
	executeDebugFunc(self.__graph, "startGraphAction", self.__actorId)
end

function CTFlow:init(owner, behavId, graphId, isAdditive)
	self:_initInner(owner, behavId, graphId, isAdditive)
end

function CTFlow:_disposeInner()
	if not self.__isAwake then
		return
	end

	self:clearTimer()
	self:clearSubFlow()
	self:clearPatrolPlan()
	self:setInactive()

	self.__continueNodeId = nil
	self.__continueFlag = false
	self.__checkInterruptFlag = false

	self:clearContext()
	self:clearInterruptTempList()
	self:clearTempList()
	self:clearCache()

	self.__owner = nil
	self.__agent = nil
	self.__actorId = nil
	self.__behaviourId = nil
	self.__graphId = nil
	self.__graph = nil
	self.__finishFunc = nil
	self.__finishFuncObj = nil
	self.__activeCallback = nil
	self.__activeFailCallback = nil
	self.__inactiveCallback = nil
	self.__isAwake = false

	CTUtils.ReturnFlow(self)
end

function CTFlow:disposeDebug()
	local graph = self.__graph
	local actorId = self.__actorId

	self:_disposeInner()
	executeDebugFunc(graph, "endGraphAction", actorId)
end

function CTFlow:dispose()
	self:_disposeInner()
end

function CTFlow:setActive()
	if self.__isActive then
		return
	end

	self.__isActive = true

	if self.__activeCallback then
		self.__activeCallback(self)
	end

	if self.__graph.executeStartTrigger then
		self.__graph.executeStartTrigger(self)
	end
end

function CTFlow:setActiveFail()
	if self.__isActive then
		return
	end

	if self.__activeFailCallback then
		self.__activeFailCallback(self)
	end
end

function CTFlow:setInactive()
	if not self.__isActive then
		return
	end

	if self.__graph.executeEndTrigger then
		self.__graph.executeEndTrigger(self)
	end

	if self.__inactiveCallback then
		self.__inactiveCallback(self, self.__finishType)
	end

	self.__isActive = false
end

function CTFlow:execute(triggerType, triggerName, context)
	if context then
		for k, v in pairs(context) do
			self.__context[k] = v
		end
	end

	local ret = false

	if triggerType == CTRConst.NodeBaseType.TickLodTrigger then
		ret = self.__graph.executeTickLodTrigger(self)
	elseif triggerType == CTRConst.NodeBaseType.EventTrigger then
		ret = self.__graph.executeEventTrigger(self, triggerName)
	elseif triggerType == CTRConst.NodeBaseType.MessageTrigger then
		ret = self.__graph.executeMessageTrigger(self, triggerName)
	end

	self:tryFinish(ret)
end

function CTFlow:executeContinue()
	self.__continueFlag = false

	if self.__subFlow then
		self.__subFlow:executeContinue()

		if self.__subFlow and not self.__subFlow:isFinish() then
			return true
		end
	end

	if self.__patrolPlan and self:continuePatrolPlan() then
		return true
	end

	local continueNodeId = self.__continueNodeId

	self.__continueNodeId = nil

	local ret = self.__graph.executeContinue(self, continueNodeId)

	self:tryFinish(ret)

	return not self:isFinish()
end

function CTFlow:executeSubFlow()
	local ret = self.__graph.executeSubFlow(self)

	self:tryFinish(ret)

	return ret
end

function CTFlow:getMacroValue(valueName)
	return self.__graph.getMacroValue(self, valueName)
end

function CTFlow:getTempList()
	local tab = ListPool.getList(3)

	if self.__checkInterruptFlag then
		self.__interruptTempListList[#self.__interruptTempListList + 1] = tab
	else
		self.__tempListList[#self.__tempListList + 1] = tab
	end

	return tab
end

function CTFlow:clearTempList()
	for _, list in ipairs(self.__tempListList) do
		ListPool.returnList(list, 3)
	end

	ListPool.returnList(self.__tempListList, 3)

	self.__tempListList = nil
end

function CTFlow:clearInterruptTempList()
	for _, list in ipairs(self.__interruptTempListList) do
		if self:checkIsInCache(list) then
			self.__tempListList[#self.__tempListList + 1] = list
		else
			ListPool.returnList(list, 3)
		end
	end

	ListPool.returnList(self.__interruptTempListList, 3)

	self.__interruptTempListList = nil
end

function CTFlow:resetInterruptTempList()
	self:clearInterruptTempList()

	self.__interruptTempListList = ListPool.getList(3)
end

function CTFlow:setContextValue(key, value)
	self.__context[key] = value
end

function CTFlow:getContextValue(key)
	return self.__context[key]
end

function CTFlow:clearContext()
	TablePool.returnTable(self.__context, 3)

	self.__context = nil
end

function CTFlow:setCache(nodeId, key, value)
	if self.__cacheMap[nodeId] == nil then
		self.__cacheMap[nodeId] = TablePool.getTable(3)
	end

	self.__cacheMap[nodeId][key] = value

	if type(value) == "table" then
		self.__cacheTable[value] = true
	end
end

function CTFlow:getCache(nodeId, key)
	if self.__cacheMap[nodeId] == nil then
		return nil
	end

	return self.__cacheMap[nodeId][key]
end

function CTFlow:clearCache()
	for _, tab in pairs(self.__cacheMap) do
		TablePool.returnTable(tab, 3)
	end

	TablePool.returnTable(self.__cacheMap, 3)
	TablePool.returnTable(self.__cacheTable, 3)

	self.__cacheMap = nil
	self.__cacheTable = nil
end

function CTFlow:checkIsInCache(tab)
	return self.__cacheTable[tab] ~= nil
end

function CTFlow:setContinue(nodeId)
	self.__continueNodeId = nodeId
	self.__continueFlag = false
end

function CTFlow:setContinueFlag()
	self.__continueFlag = true
end

function CTFlow:checkCanContinue()
	return self.__continueFlag and self.__continueNodeId
end

function CTFlow:checkInterrupt()
	if self.__continueNodeId == nil then
		return false
	end

	local interrupt

	if self.__subFlow then
		interrupt = self.__subFlow:checkInterrupt()
	else
		self.__checkInterruptFlag = true
		interrupt = self.__graph.checkInterrupt(self, self.__continueNodeId)
		self.__checkInterruptFlag = false

		self:resetInterruptTempList()
	end

	if interrupt then
		self.__finishType = CTRConst.FlowFinishType.Interrupt
	end

	return interrupt
end

function CTFlow:setFinishFunc(func, obj)
	self.__finishFunc = func
	self.__finishFuncObj = obj
end

function CTFlow:tryFinish(result)
	if not result then
		self:finish()

		return
	end

	local isFinish = self.__continueNodeId == nil

	if isFinish then
		self:finish()
	end
end

function CTFlow:finish()
	self.__finishType = CTRConst.FlowFinishType.Finish

	if self.__finishFunc then
		self.__finishFunc(self.__finishFuncObj)
	else
		self:dispose()
	end
end

function CTFlow:isFinish()
	return not self.__isAwake
end

function CTFlow:setPatrolPlan(patrolId, plan)
	if plan then
		self.__patrolPlan = plan

		self.__patrolPlan:initPlan(self.__owner)
		self.__owner:setRouteId(patrolId)
	end
end

function CTFlow:continuePatrolPlan()
	if not self.__patrolPlan:tryRunPlan() then
		self:clearPatrolPlan()

		return false
	end

	return true
end

function CTFlow:clearPatrolPlan()
	if self.__patrolPlan then
		self.__patrolPlan:destroy()
		PlanPool.returnPlan(self.__patrolPlan)

		self.__patrolPlan = nil

		self.__owner:setRouteId(nil)
		self.__owner:setIgnoreAILod(false, AiConst.IgnoreAILodReason.Route)
	end
end

function CTFlow:getSubMacro(graphName)
	return CTUtils.GetFlow(self.__owner, self.__behaviourId, graphName, self.__isAdditive)
end

function CTFlow:clearSubMacro(subFlow)
	subFlow:dispose()
end

function CTFlow:getSubFlow(graphName)
	if self.__subFlow then
		logger:error("[Graph:%s] - [SubGraph:%s] sub flow execute error!", self.__graphId, graphName)

		return
	end

	self.__subFlow = CTUtils.GetFlow(self.__owner, self.__behaviourId, graphName, self.__isAdditive)

	self.__subFlow:setFinishFunc(self.clearSubFlow, self)

	return self.__subFlow
end

function CTFlow:clearSubFlow()
	if self.__subFlow then
		self.__subFlow:dispose()

		self.__subFlow = nil
	end
end

function CTFlow:getMessageContext()
	local context = CTRPool.getContext()

	context.sourceActorId = self.__actorId

	return context
end

function CTFlow:sendMessage(targetActorId, messageName, ctrContext)
	TimerManager.addNextFrameCb(CallbackHandlerNoGC.new(self, self._innerSendMessage, targetActorId, messageName, ctrContext))
end

function CTFlow:_innerSendMessage(targetActorId, messageName, ctrContext)
	AIControllerUtils.sendAIEvent(pg.getEntityByActorId(targetActorId), messageName, ctrContext)
end

function CTFlow:addTimer(delay, table, funcName, ...)
	if not self.__timerMap then
		return
	end

	local func = CallbackHandlerNoGC.new(self, self._innerCallTimer, table, funcName, ...)
	local timerId = TimerManager.addTimer(delay, func:getFunction())

	self.__timerMap[timerId] = func
end

function CTFlow:_innerCallTimer(table, funcName, ...)
	table[funcName](...)
end

function CTFlow:clearTimer()
	for timerId, func in pairs(self.__timerMap) do
		TimerManager.removeTimer(timerId)
		lume.disposeItem(func)
	end

	TablePool.returnTable(self.__timerMap, 3)

	self.__timerMap = nil
end

function CTFlow:getValidActorId(actorId)
	if actorId == nil or actorId == 0 then
		return self.__actorId
	end

	return actorId
end

return CTFlow
