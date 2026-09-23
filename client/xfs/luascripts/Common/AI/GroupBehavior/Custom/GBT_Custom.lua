-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\GroupBehavior\\Custom\\GBT_Custom.lua

local Class = require("Core.Framework.Class")
local GroupBehaviourTacheBase = require("Common.AI.GroupBehavior.GroupBehaviourTacheBase")
local GroupBehaviourUtils = require("Common.Utils.GroupBehaviourUtils")
local AIControllerUtils = require("Common.Utils.AIControllerUtils")
local AiConst = require("Common.Const.AiConst")
local TimerManager = require("Core.Timer.TimerManager")
local SceneUtils = require("Common.Utils.SceneUtils")
local ECSConst = require("Const.ECSConst")
local CTRPool = require("Common.AICt.CTRPool")
local CallbackHandlerNoGC = require("Core.Common.CallbackHandlerNoGC")
local AIUtils = require("Common.Utils.AIUtils")
local lume = require("Core.Common.lume")
local GBT_Custom = Class.LiteClass("GBT_Custom", GroupBehaviourTacheBase)

function GBT_Custom:ctor(owner, stateKey, tacheData)
	GroupBehaviourTacheBase.ctor(self, owner, stateKey)

	self.tacheData = tacheData.functions
	self.timeoutTime = tacheData.timeout or self.timeoutTime
	self.conditionFuncTimerMap = {}
	self.conditionFuncFrameMap = {}
	self.finishBehavIds = {}
	self.finishFunc = nil
	self.tickFuncList = {}
end

function GBT_Custom:_preAddConditionFunc()
	for _, cFuncData in ipairs(self.tacheData) do
		if cFuncData.condition[1] == "behavEnd" then
			self:_addConditionFunc(cFuncData.condition, cFuncData.func, cFuncData.role, cFuncData.para, cFuncData.extraPara)
		end
	end
end

function GBT_Custom:_lateAddConditionFunc()
	for _, cFuncData in ipairs(self.tacheData) do
		if cFuncData.condition[1] ~= "behavEnd" then
			self:_addConditionFunc(cFuncData.condition, cFuncData.func, cFuncData.role, cFuncData.para, cFuncData.extraPara)
		end
	end
end

function GBT_Custom:onEnter(controller, oldState)
	GroupBehaviourTacheBase.onEnter(self, controller, oldState)
	self:_preAddConditionFunc()
	self:_lateAddConditionFunc()
end

function GBT_Custom:onRun(controller)
	local num = #self.tickFuncList

	for i = 1, num do
		local func = self.tickFuncList[i]

		if func then
			func()
		end
	end
end

function GBT_Custom:onExit(controller, nextState)
	GroupBehaviourTacheBase.onExit(self, controller, nextState)
	self:_removeConditionFuncTimer()
end

function GBT_Custom:_execStart()
	return
end

function GBT_Custom:_addConditionFunc(funcCondition, funcName, funcTarget, funcParam, funcExtraParam)
	local conditionName = funcCondition.conditionName
	local conditionParamObj = funcCondition.conditionParamObject
	local conditionParamList = funcCondition.conditionParamList

	if conditionName == "delayTime" then
		local delay = conditionParamObj and conditionParamObj[1]

		self:_addConditionFuncTimer(delay, CallbackHandlerNoGC.new(self, "_doConditionFunc", funcName, funcTarget, funcParam, funcExtraParam))
	elseif conditionName == "checkEnvObjChemState" then
		local staticId = conditionParamObj and conditionParamObj[1]
		local stateKey = conditionParamObj and conditionParamObj[2]

		self:_addConditionFuncTick(CallbackHandlerNoGC.new(self, "_tickCheckEnvObjChemState", funcName, funcTarget, funcParam, funcExtraParam, staticId, stateKey))
	elseif conditionName == "behavEnd" then
		local param = conditionParamList and conditionParamList[1]

		self:_setFinishBehavId(param)
		self:_setFinishFunc(CallbackHandlerNoGC.new(self, "_doConditionFunc", funcName, funcTarget, funcParam, funcExtraParam))
	else
		GroupBehaviourUtils.LogError("condition func conditionName error, conditionName: %s", tostring(conditionName))
	end
end

function GBT_Custom:_addConditionFuncTick(func)
	table.insert(self.tickFuncList, func)
end

function GBT_Custom:_addConditionFuncTimer(delayTime, func)
	if delayTime > 0 then
		local timerId = TimerManager.addTimer(delayTime, func:getFunction())

		self.conditionFuncTimerMap[timerId] = func
	else
		local frameId = TimerManager.addNextFrameCb(func:getFunction())

		self.conditionFuncFrameMap[frameId] = func
	end
end

function GBT_Custom:_removeConditionFuncTimer()
	for timerId, func in pairs(self.conditionFuncTimerMap) do
		TimerManager.removeTimer(timerId)
		lume.disposeItem(func)
	end

	for frameId, func in pairs(self.conditionFuncFrameMap) do
		TimerManager.delFrameCb(frameId)
		lume.disposeItem(func)
	end

	for _, func in ipairs(self.tickFuncList) do
		lume.disposeItem(func)
	end

	if self.finishFunc then
		lume.disposeItem(self.finishFunc)
	end

	table.clear(self.conditionFuncTimerMap)
	table.clear(self.conditionFuncFrameMap)
	table.clearArray(self.tickFuncList)

	self.finishFunc = nil
end

function GBT_Custom:_tickCheckEnvObjChemState(funcName, funcTarget, funcParam, funcExtraParam, staticId, stateKey)
	local globalId = SceneUtils.getEnvIdByStaticId(staticId)
	local ent = pg.getEntityByGlobalId(globalId)

	if ent and AIUtils.checkChemStateAndAbility(stateKey) then
		self:_doConditionFunc(funcName, funcTarget, funcParam, funcExtraParam)
	end
end

function GBT_Custom:_doConditionFunc(funcName, funcTarget, funcParam, funcExtraParam)
	if self[funcName] == nil then
		GroupBehaviourUtils.LogError("condition func funcName error, funcName: %s", tostring(funcName))

		return
	end

	self[funcName](self, funcTarget, funcParam, funcExtraParam)
end

function GBT_Custom:_setFinishBehavId(behavIdParam)
	table.clear(self.finishBehavIds)

	if type(behavIdParam) == "string" then
		for i = 1, self.owner.maxMemberCount do
			self.finishBehavIds[i] = behavIdParam
		end

		self:_postProcessFinishBehavId()
	elseif type(behavIdParam) == "table" then
		table.merge(self.finishBehavIds, behavIdParam)
	elseif self.owner.parmonBehavId ~= nil then
		for i = 1, self.owner.maxMemberCount do
			self.finishBehavIds[i] = self.owner.parmonBehavId
		end

		self:_postProcessFinishBehavId()
	else
		GroupBehaviourUtils.LogError("behavEnd param error, param: %s", tostring(behavIdParam))
	end
end

function GBT_Custom:_getFinishBehavId(member)
	return self.finishBehavIds[self:getMemberIndex(member)]
end

function GBT_Custom:_setFinishFunc(func)
	self.finishFunc = func
end

function GBT_Custom:_checkFinish()
	for _, member in pairs(self.owner.members) do
		if string.notNilOrEmpty(self:_getFinishBehavId(member)) and not self.finishFlags[member.actorId] then
			return false
		end
	end

	return true
end

function GBT_Custom:_execFinish()
	table.clear(self.finishFlags)

	if self.finishFunc ~= nil then
		self.finishFunc()
	end
end

function GBT_Custom:_sendTrigger(targetEnt, eventName, context)
	GroupBehaviourUtils.LogWithTache(self, "\tsend trigger, actorId: %d, eventName: %s, context: %s", targetEnt.actorId, eventName, inspect(context))
	AIControllerUtils.sendAIEvent(targetEnt, eventName, context)
end

local function _checkFuncTarget(funcTarget, memberType)
	if funcTarget == nil or memberType == nil then
		return false
	end

	if type(funcTarget) == "table" then
		for _, target in ipairs(funcTarget) do
			if target == memberType then
				return true
			end
		end

		return false
	else
		return funcTarget == "all" or funcTarget == memberType
	end
end

function GBT_Custom:_postProcessFinishBehavId()
	local valid = {}

	for i = 1, self.owner.maxMemberCount do
		local memberType = self.owner.memberData[i].roleType

		for _, cFuncData in ipairs(self.tacheData) do
			if _checkFuncTarget(cFuncData.role, memberType) then
				valid[i] = true

				break
			end
		end
	end

	for i = 1, self.owner.maxMemberCount do
		if not valid[i] then
			self.finishBehavIds[i] = nil
		end
	end
end

function GBT_Custom:sendTrigger_ResPoint(funcTarget, funcParam, funcExtraParam)
	local resPoint = self:getBindResPoint()
	local usedPortId = {}

	for i = 1, self.owner.maxMemberCount do
		local memberType = self.owner.memberData[i].roleType
		local member = self.owner.members[i]

		if member and _checkFuncTarget(funcTarget, memberType) then
			local minPortId, minSqrDist
			local memberPos = member:getPosition()

			for idx, port in pairs(resPoint.ports) do
				if not usedPortId[idx] and not port:isFull() then
					local sqrDist = Vector3.HoriSqrDistance(memberPos, port:getWorldPosition())

					if minSqrDist == nil or sqrDist < minSqrDist then
						minSqrDist = sqrDist
						minPortId = idx
					end
				end
			end

			if minPortId then
				usedPortId[minPortId] = true

				local context = CTRPool.getContext()

				context.tPointId = resPoint:getFixPointId()
				context.tPortId = minPortId
				context.tRoleIndex = i

				table.merge(context, funcExtraParam or AiConst.DefaultNullTable)
				self:_sendTrigger(member, funcParam, context)
			end
		end
	end
end

function GBT_Custom:sendTrigger_Perform(funcTarget, funcParam, funcExtraParam)
	for i = 1, self.owner.maxMemberCount do
		local memberType = self.owner.memberData[i].roleType
		local member = self.owner.members[i]

		if member and _checkFuncTarget(funcTarget, memberType) then
			local context = CTRPool.getContext()

			context.tMemberIndex = self:getMemberIndex(member)
			context.tTriggerCount = funcParam

			table.merge(context, funcExtraParam or AiConst.DefaultNullTable)
			self:_sendTrigger(member, funcParam, context)
		end
	end
end

function GBT_Custom:sendTrigger_Common(funcTarget, funcParam, funcExtraParam)
	for i = 1, self.owner.maxMemberCount do
		local memberType = self.owner.memberData[i].roleType
		local member = self.owner.members[i]

		if member and _checkFuncTarget(funcTarget, memberType) then
			local context = CTRPool.getContext()

			context.tRoleIndex = i

			table.merge(context, funcExtraParam or AiConst.DefaultNullTable)
			self:_sendTrigger(member, funcParam, context)
		end
	end
end

function GBT_Custom:goToNextStage(funcTarget, funcParam, funcExtraParam)
	GroupBehaviourTacheBase._execFinish(self)
end

return GBT_Custom
