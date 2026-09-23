-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AICt\\CTRFlow.lua

local Class = require("Core.Framework.Class")
local CTRConst = require("Common.AICt.CTRConst")
local TimerManager = require("Core.Timer.TimerManager")
local ListPool = require("Common.Container.ListPool")
local TablePool = require("Common.Container.TablePool")
local lume = require("Core.Common.lume")
local CTRPool = require("Common.AICt.CTRPool")
local FlowFinishType = CTRConst.FlowFinishType
local CTRFlow = Class.LightClass("CTRFlow")
local InstanceId = 0
local CACHE_FLOW = {}

function CTRFlow:ctor(context, runGraph)
	self:init(context, runGraph)
end

function CTRFlow:initContext(context)
	table.clear(self.context)

	if context then
		for k, v in pairs(context) do
			self.context[k] = v
		end
	end
end

function CTRFlow:bindActorAndBehavior(actorId, behaviorId)
	self.context._entActorId = actorId
	self.context._behaviorId = behaviorId
	self._behaviourID = behaviorId
end

function CTRFlow:init(context, runGraph)
	self.context = self.context or {}

	self:initContext(context)

	self.graphId = runGraph.graphId

	if self.__cacheMap then
		self:clearCache()
	else
		self.__cacheMap = {}
		self.__cacheTable = {}
	end

	if self.__interruptTempListList then
		self:clearInterruptTempList()
	else
		self.__interruptTempListList = {}
	end

	if self.__tempListList then
		self:clearTempList()
	else
		self.__tempListList = {}
	end

	self.__checkInterruptFlag = false
	self.__instanceId = self:generateInstanceId()
	self.__breakFlow = false
	self._AdditiveFlow = false
	self.__subFlow = nil
	self.__holderGraph = runGraph
	self.__triggerName = nil
	self.__triggerType = nil
	self._continueNode = nil
	self._continueNodeFinishFlag = false
	self._finishedFunc = nil
	self._runningState = CTRConst.ExecutionTiming.Waiting
	self.__hasActivate = false
	self.__hasDisposed = false
	self.__checkAction = nil
	self.__checkFailAction = nil
	self.__disposeFunc = nil
	self.__flowFinishType = FlowFinishType.Break
	self.__owner = nil

	if self._timer_cache then
		table.clear(self._timer_cache)
	else
		self._timer_cache = {}
	end
end

function CTRFlow.GetFlow(context, runGraph)
	if #CACHE_FLOW > 0 then
		local flow = table.remove(CACHE_FLOW, 1)

		flow:init(context, runGraph)

		return flow
	end

	return CTRFlow.new(context, runGraph)
end

function CTRFlow:startFlow()
	self.__holderGraph:doStartGraph(self)
	self:continue()
end

function CTRFlow:continue()
	if self.__holderGraph == nil then
		self:dispose()

		return not self:checkIsFinished()
	end

	if self._continueNode == nil then
		self:switchState()

		return not self:checkIsFinished()
	end

	local continue = self._continueNode

	self._continueNode = nil
	self._continueNodeFinishFlag = false

	continue:doFlowOut(self)
	self:checkState()

	return not self:checkIsFinished()
end

function CTRFlow:switchState()
	if self._runningState == CTRConst.ExecutionTiming.Waiting then
		self:doMain()
	elseif self._runningState == CTRConst.ExecutionTiming.DoMainTrigger then
		self:doFinished()
	end

	self:checkState()
end

function CTRFlow:checkState()
	if self._continueNode == nil and self._runningState ~= CTRConst.ExecutionTiming.Disposed then
		self:switchState()
	end
end

function CTRFlow:doStart()
	if self.__checkAction then
		self.__checkAction(self)
	end

	if self.__holderGraph then
		self.__holderGraph:doStart(self)
	end
end

function CTRFlow:doStartFail()
	if self.__checkFailAction then
		self.__checkFailAction(self)
	end
end

function CTRFlow:doMain()
	self._runningState = CTRConst.ExecutionTiming.DoMainTrigger

	self.__holderGraph:doGraph(self)
end

function CTRFlow:doEnd()
	self.__holderGraph:doEnd(self)
end

function CTRFlow:doFinished()
	self._runningState = CTRConst.ExecutionTiming.Finished
	self.__flowFinishType = FlowFinishType.Finish

	if self._finishedFunc then
		self._finishedFunc()
	else
		self:dispose()
	end
end

function CTRFlow:addSubFlow(context, runGraph)
	local subFlow = CTRFlow.GetFlow(context, runGraph)

	subFlow:bindActorAndBehavior(context._entActorId, context._behaviorId)

	subFlow.__triggerType = CTRConst.NodeBaseType.BridgeTrigger
	self.__subFlow = subFlow

	subFlow:startFlow()
end

function CTRFlow:setCacheValue(cacheNodeId, key, value)
	if self.__cacheMap[cacheNodeId] == nil then
		self.__cacheMap[cacheNodeId] = TablePool.getTable(3)
	end

	self.__cacheMap[cacheNodeId][key] = value

	if type(value) == "table" then
		self.__cacheTable[value] = true
	end
end

function CTRFlow:getCacheValue(cacheNodeId, key)
	if self.__cacheMap[cacheNodeId] == nil then
		return nil
	end

	return self.__cacheMap[cacheNodeId][key]
end

function CTRFlow:clearCache()
	for _, tab in pairs(self.__cacheMap) do
		TablePool.returnTable(tab, 3)
	end

	table.clear(self.__cacheMap)
	table.clear(self.__cacheTable)
end

function CTRFlow:checkIsInCache(tab)
	return self.__cacheTable[tab] ~= nil
end

function CTRFlow:getTempList()
	local tab = ListPool.getList(3)

	if self.__checkInterruptFlag then
		self.__interruptTempListList[#self.__interruptTempListList + 1] = tab
	else
		self.__tempListList[#self.__tempListList + 1] = tab
	end

	return tab
end

function CTRFlow:clearTempList()
	for _, tab in ipairs(self.__tempListList) do
		ListPool.returnList(tab, 3)
	end

	table.clearArray(self.__tempListList)
end

function CTRFlow:clearInterruptTempList()
	for _, tab in ipairs(self.__interruptTempListList) do
		if self:checkIsInCache(tab) then
			self.__tempListList[#self.__tempListList + 1] = tab
		else
			ListPool.returnList(tab, 3)
		end
	end

	table.clearArray(self.__interruptTempListList)
end

function CTRFlow:addTimer(timerId, func)
	self._timer_cache[timerId] = func
end

function CTRFlow:checkIsFinished()
	return self._runningState == CTRConst.ExecutionTiming.Finished or self._runningState == CTRConst.ExecutionTiming.Disposed
end

function CTRFlow:checkInterruptable()
	if self._continueNode == nil then
		return false
	end

	if self._continueNode.GetInterruptResult == nil then
		return false
	end

	self.__checkInterruptFlag = true

	local interrupt = self._continueNode:GetInterruptResult(self)

	self.__checkInterruptFlag = false

	self:clearInterruptTempList()

	return interrupt
end

function CTRFlow:setContinueNode(node)
	self._continueNode = node
	self._continueNodeFinishFlag = false
end

function CTRFlow:setContinueFlag(flag)
	self._continueNodeFinishFlag = flag
end

function CTRFlow:checkCanContinue()
	return self._continueNode ~= nil and self._continueNodeFinishFlag
end

function CTRFlow:dispose()
	if self._continueNode then
		self._continueNode:onDispose(self)
	end

	if self.__hasActivate then
		self:doEnd()
	end

	if self.__disposeFunc and self.__hasActivate then
		self.__disposeFunc(self, self.__flowFinishType)
	end

	self.__subFlow = nil
	self.__disposeFunc = nil
	self._finishedFunc = nil

	self.__holderGraph:doFinished(self)

	self._runningState = CTRConst.ExecutionTiming.Disposed
	self.__holderGraph = nil
	self._continueNode = nil
	self._continueNodeFinishFlag = false
	self.__breakFlow = true
	self.__hasActivate = false
	self.__hasDisposed = true

	for timerId, func in pairs(self._timer_cache) do
		TimerManager.removeTimer(timerId)
		lume.disposeItem(func)
	end

	table.clear(self.context)
	self:clearCache()
	self:clearInterruptTempList()
	self:clearTempList()
	self:recycleFlow()
end

function CTRFlow:recycleFlow()
	if #CACHE_FLOW > 200 then
		-- block empty
	else
		table.insert(CACHE_FLOW, self)
	end
end

function CTRFlow:generateInstanceId()
	if InstanceId > math.maxInt then
		InstanceId = 0
	end

	InstanceId = InstanceId + 1

	return InstanceId
end

return CTRFlow
