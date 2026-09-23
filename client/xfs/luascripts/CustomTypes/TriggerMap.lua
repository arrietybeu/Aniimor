-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\TriggerMap.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local CustomDict = require("Core.PropertySync.CustomDict")
local logger = require("Core.Log.LoggerManager").getLogger("TriggerMap")
local Utils = require("Common.Utils.Utils")
local QuestConst = require("Common.Const.QuestConst")
local Bitset = require("Common.Bitset")
local TriggerConst = require("Common.Const.TriggerConst")
local TriggerUtils = require("Common.Utils.TriggerUtils")
local QuestCommonUtils = require("Common.Utils.QuestCommonUtils")
local ObjHelper = require("Common.ObjHelper")
local TriggerData = require("Data.trigger_data")
local TriggerNameData = require("Data.trigger_name_data")
local CustomTriggerData = require("Data.custom_trigger_data")
local CustomTriggerMapData = require("Data.custom_trigger_map_data")
local CustomDefaultRegisterMap = require("Data.custom_default_register_map")
local CustomVariableData = require("Common.Data.custom_variable_data")
local CustomTypeHelper = require("Core.PropertySync.CustomTypeHelper")
local band = bit.band
local lshift = bit.lshift
local rshift = bit.rshift
local MAGIC_DIGIT = Bitset.MAGIC_DIGIT
local MAGIC_NUM = Bitset.MAGIC_NUM
local GetProp = CustomTypeHelper.GetProp
local getBit = Bitset.getBit

local function getCustomTypeBit(customDict, bitIndex)
	if customDict == nil then
		return false
	end

	local idx = rshift(bitIndex, MAGIC_DIGIT) + 1
	local pos = band(bitIndex, MAGIC_NUM - 1)
	local byte = lshift(1, pos)

	return band(GetProp(customDict, idx) or 0, byte) ~= 0
end

local TriggerMap = class.LiteClass("TriggerMap", CustomDict)
local pairs = pairs
local ipairs = ipairs

if UNITY_EDITOR then
	local types = {
		ObjHelper.TYPE_PLAYER,
		ObjHelper.TYPE_PET_INFO
	}

	function TriggerMap:getObj()
		local obj = Utils.isPetInfoType(self._parent) and self._parent or self:getRootOwner()

		assert(ObjHelper.matchOneOf(obj, types))

		return obj
	end
else
	function TriggerMap:getObj()
		local obj = Utils.isPetInfoType(self._parent) and self._parent or self:getRootOwner()

		return obj
	end
end

function TriggerMap:getPlayer(needAlarm)
	local obj = self:getObj()

	if Utils.isPlayer(obj) then
		return obj
	elseif needAlarm then
		ALARM("not player")
	end

	return nil
end

function TriggerMap:getGmTriggerValue(trigger, triggerId)
	if not _G_IsDebugMode then
		return nil
	end

	return self.gmTriggerValue[trigger] and self.gmTriggerValue[trigger][triggerId]
end

function TriggerMap:setGmTriggerValue(trigger, triggerId, value)
	if not _G_IsDebugMode then
		return
	end

	self.gmTriggerValue[trigger] = self.gmTriggerValue[trigger] or {}
	self.gmTriggerValue[trigger][triggerId] = value

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		logger:debug("setGmTriggerValue: trigger=%d, triggerId=%d, value=%s", trigger, triggerId, tostring(value), ObjHelper.getObjRepr(self:getObj()))
	end
end

function TriggerMap:checkUseType(useType, userId)
	if TriggerConst.IS_PET_CONDTION[useType] then
		local obj = self:getObj()

		return Utils.isPetInfoType(obj) and (userId == 0 or obj.templateId == userId)
	else
		return true
	end
end

function TriggerMap:checkUseTypeByConfig(ctdd)
	if TriggerConst.IS_PET_CONDTION[ctdd.conditionUse] then
		local obj = self:getObj()
		local userId = ctdd.userId

		return Utils.isPetInfoType(obj) and (userId == 0 or obj.templateId == userId)
	else
		return true
	end
end

function TriggerMap:isRegister(customDataId)
	local ctdd = CustomTriggerData[customDataId]

	if ctdd == nil then
		return false
	end

	if not self:checkUseType(ctdd.conditionUse, ctdd.userId) then
		return false
	end

	return getBit(self.registerCustomSet, customDataId) or CustomDefaultRegisterMap[customDataId] and not getBit(self.completeCustomSet, customDataId) or false
end

function TriggerMap:isRegisterFaster(customDataId)
	local ctdd = CustomTriggerData[customDataId]

	if ctdd == nil then
		return false
	end

	if not self:checkUseType(ctdd.conditionUse, ctdd.userId) then
		return false
	end

	return getCustomTypeBit(self.registerCustomSet, customDataId) or CustomDefaultRegisterMap[customDataId] and not getCustomTypeBit(self.completeCustomSet, customDataId) or false
end

function TriggerMap:getRegisterConfig(customDataId)
	local ctdd = CustomTriggerData[customDataId]

	if ctdd == nil then
		return
	end

	if not self:checkUseTypeByConfig(ctdd) then
		return
	end

	if getCustomTypeBit(self.registerCustomSet, customDataId) or CustomDefaultRegisterMap[customDataId] and not getCustomTypeBit(self.completeCustomSet, customDataId) then
		return ctdd
	end
end

function TriggerMap:isComplete(customDataId)
	return getBit(self.completeCustomSet, customDataId)
end

function TriggerMap:_isTriggerBlockedForGuidance(ctdd)
	local obj = self:getObj()

	return obj.isGuidancePlayer and ctdd.virtualPlayerEnable ~= 1
end

function TriggerMap:isCompleteOrMeetCondition(customDataId)
	local ctdd = CustomTriggerData[customDataId]

	if ctdd == nil then
		return false
	end

	local realSelf = self

	if not TriggerConst.IS_PET_CONDTION[ctdd.conditionUse] then
		local obj = self:getObj()

		realSelf = Utils.isPetInfoType(obj) and obj:getOwnerPlayer() and obj:getOwnerPlayer().triggerMap or self
	end

	if not realSelf:checkUseType(ctdd.conditionUse, ctdd.userId) then
		return false
	end

	if realSelf:_isTriggerBlockedForGuidance(ctdd) then
		return false
	end

	return realSelf:isComplete(customDataId) or realSelf:checkMeetCustomTrigger(ctdd)
end

local _emptyTable = {}
local _questTriggersName = {
	[TriggerConst.TRIGGER_REGTYPE_QUEST_OBJECTIVE] = "questObjectivesTriggers",
	[TriggerConst.TRIGGER_REGTYPE_QUEST_CLAIMCOND] = "questClaimTriggers",
	[TriggerConst.TRIGGER_REGTYPE_QUEST_RUNCOND] = "questRunTriggers",
	[TriggerConst.TRIGGER_REGTYPE_QUEST_COM_ACTION_OBJECTIVE] = "questComActionObjTriggers",
	[TriggerConst.TRIGGER_REGTYPE_QUEST_CLOSECOND] = "questCloseTriggers"
}

function TriggerMap:getQuestTriggersByType(triggerType)
	local name = _questTriggersName[triggerType]

	return self[name] or _emptyTable
end

function TriggerMap:getFinishCount(customDataId)
	return self.customCount[customDataId] or 0
end

function TriggerMap:getConditionValue(regType, templateId, pos)
	local value

	if regType == TriggerConst.TRIGGER_REGTYPE_CUSTOM then
		value = self.customCondition[TriggerConst.genCustomTriggerKey(templateId, pos)]
	elseif regType == TriggerConst.TRIGGER_REGTYPE_QUEST_OBJECTIVE then
		local player = self:getPlayer(true)

		if player ~= nil then
			local _, qData = QuestCommonUtils.getQuestData(player, templateId)

			if qData then
				_, value = qData:getConditionCnt(pos, QuestConst.QUEST_CONDTYPE.OBJECTIVE)
			end
		end
	elseif regType == TriggerConst.TRIGGER_REGTYPE_QUEST_CLAIMCOND then
		local player = self:getPlayer(true)

		if player ~= nil then
			local _, qData = QuestCommonUtils.getQuestData(player, templateId)

			if qData then
				_, value = qData:getConditionCnt(pos, QuestConst.QUEST_CONDTYPE.CLAIMCOND)
			end
		end
	elseif regType == TriggerConst.TRIGGER_REGTYPE_QUEST_RUNCOND then
		local player = self:getPlayer(true)

		if player ~= nil then
			local _, qData = QuestCommonUtils.getQuestData(player, templateId)

			if qData then
				_, value = qData:getConditionCnt(pos, QuestConst.QUEST_CONDTYPE.RUNCOND)
			end
		end
	elseif regType == TriggerConst.TRIGGER_REGTYPE_QUEST_COM_ACTION_OBJECTIVE then
		local player = self:getPlayer(true)

		if player ~= nil then
			local ca = player.questCompleteActions and player.questCompleteActions[templateId]

			if ca then
				_, value = ca:getConditionCnt(pos, QuestConst.QUEST_CONDTYPE.COM_ACTION_OBJECTIVE)
			end
		end
	elseif regType == TriggerConst.TRIGGER_REGTYPE_QUEST_CLOSECOND then
		local player = self:getPlayer(true)

		if player ~= nil then
			local closeData = player.questCloseConditions and player.questCloseConditions[templateId]

			if closeData then
				_, value = closeData:getConditionCnt(pos, QuestConst.QUEST_CONDTYPE.CLOSECOND)
			end
		end
	else
		ALARM("invalid regType")
	end

	return value or 0
end

function TriggerMap:setConditionValue(regType, templateId, pos, value)
	if regType == TriggerConst.TRIGGER_REGTYPE_CUSTOM then
		self.customCondition[TriggerConst.genCustomTriggerKey(templateId, pos)] = value
	elseif regType == TriggerConst.TRIGGER_REGTYPE_QUEST_OBJECTIVE then
		local player = self:getPlayer(true)

		if player ~= nil then
			local qdd, qData = QuestCommonUtils.getQuestData(player, templateId)

			if qData ~= nil then
				local objectives = qdd.objectives or {}

				qData:setObjective(pos, value, objectives, QuestConst.QUEST_CONDTYPE.OBJECTIVE)
			else
				player.logger:error("@quest TriggerMap/setConditionValue questId=%s objective nil qData %s", templateId, player:repr())
			end
		end
	elseif regType == TriggerConst.TRIGGER_REGTYPE_QUEST_CLAIMCOND then
		local player = self:getPlayer(true)

		if player ~= nil then
			local qdd, qData = QuestCommonUtils.getQuestData(player, templateId)

			if qData ~= nil then
				local claimConds = qdd.claimCond and qdd.claimCond.condition or {}

				qData:setObjective(pos, value, claimConds, QuestConst.QUEST_CONDTYPE.CLAIMCOND)
			else
				player.logger:error("@quest TriggerMap/setConditionValue questId=%s claimcond nil qData %s", templateId, player:repr())
			end
		end
	elseif regType == TriggerConst.TRIGGER_REGTYPE_QUEST_RUNCOND then
		local player = self:getPlayer(true)

		if player ~= nil then
			local qdd, qData = QuestCommonUtils.getQuestData(player, templateId)

			if qData ~= nil then
				local runConds = qdd.runCond and qdd.runCond.condition or {}

				qData:setObjective(pos, value, runConds, QuestConst.QUEST_CONDTYPE.RUNCOND)
			else
				player.logger:error("@quest TriggerMap/setConditionValue questId=%s runcond nil qData %s", templateId, player:repr())
			end
		end
	elseif regType == TriggerConst.TRIGGER_REGTYPE_QUEST_COM_ACTION_OBJECTIVE then
		local player = self:getPlayer(true)

		if player ~= nil then
			local qdd = QuestCommonUtils.getQuestData(player, templateId)
			local ca = player.questCompleteActions and player.questCompleteActions[templateId]

			if qdd and ca then
				local comActionObjcvs = qdd.comActionObjcvs or {}

				ca:setObjective(templateId, pos, value, comActionObjcvs)
			else
				player.logger:error("@quest TriggerMap/setConditionValue questId=%s actionObjective nil ca %s", templateId, player:repr())
			end
		end
	elseif regType == TriggerConst.TRIGGER_REGTYPE_QUEST_CLOSECOND then
		local player = self:getPlayer(true)

		if player ~= nil then
			local qdd = QuestCommonUtils.getQuestData(player, templateId)
			local closeData = player.questCloseConditions and player.questCloseConditions[templateId]
			local closeConds = qdd and qdd.closeCond and qdd.closeCond.condition or {}

			if qdd and closeData then
				closeData:setObjective(templateId, pos, value, closeConds)
			else
				player.logger:error("@quest TriggerMap/setConditionValue questId=%s closeCond nil data %s", templateId, player:repr())
			end
		end
	else
		ALARM("invalid regType")
	end

	return value or 0
end

function TriggerMap:addConditionValue(regType, templateId, pos, value)
	local newValue = self:getConditionValue(regType, templateId, pos) + value

	self:setConditionValue(regType, templateId, pos, newValue)

	return newValue
end

function TriggerMap:getCurrentValueByCondition(cond, regType, templateId, pos)
	if cond == nil then
		cond = TriggerUtils.getConditionByRegInfo(regType, templateId, pos)
	end

	local trigger, triggerId, extraArg = TriggerConst.getTriggerInfo(cond, TriggerData)

	if trigger == nil then
		ALARM("invalid cond")

		return 0
	end

	if TriggerUtils.needRecordTriggerCount(trigger) then
		return self:getConditionValue(regType, templateId, pos)
	else
		return self:getCommonTriggerConditionValue(0, trigger, triggerId, extraArg)
	end
end

function TriggerMap:checkCurrentValueByCondition(cond, regType, templateId, pos)
	if cond == nil then
		cond = TriggerUtils.getConditionByRegInfo(regType, templateId, pos)
	end

	local operator = cond[TriggerConst.CUSTOM_TRIGGER_OPERATOR_POS]
	local dstCount = cond[TriggerConst.CUSTOM_TRIGGER_NUM_POS]
	local curCount = self:getCurrentValueByCondition(cond, regType, templateId, pos)

	return TriggerUtils.checkMeetOperator(curCount, dstCount, operator)
end

function TriggerMap:getConditionFinishCount(customDataId, pos)
	if not customDataId then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:error("getConditionFinishCount nil")
		end

		return 0
	end

	local ctdd = CustomTriggerData[customDataId]

	if ctdd == nil then
		return 0
	end

	return self:getCurrentValueByCondition(ctdd.condition[pos] or {}, TriggerConst.TRIGGER_REGTYPE_CUSTOM, customDataId, pos)
end

function TriggerMap:getConditionTargetCount(customDataId, pos)
	if not customDataId then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:error("getConditionTargetCount nil")
		end

		return 0
	end

	local ctdd = CustomTriggerData[customDataId]

	if ctdd == nil or not ctdd.condition or not ctdd.condition[pos] then
		return 0
	end

	return ctdd.condition[pos][TriggerConst.CUSTOM_TRIGGER_NUM_POS]
end

function TriggerMap:checkConditionFinishCount(customDataId, pos)
	local ctdd = CustomTriggerData[customDataId]

	if ctdd == nil then
		return false
	end

	return self:checkCurrentValueByCondition(ctdd.condition[pos] or {}, TriggerConst.TRIGGER_REGTYPE_CUSTOM, customDataId, pos)
end

function TriggerMap:dumpCustomStatus(customDataId, pos)
	if not _G_IsDebugMode then
		return {}
	end

	local ctdd = CustomTriggerData[customDataId]

	if ctdd == nil then
		return {
			"invalid config"
		}
	end

	local res = {}

	res._data = string.format("id=%d, conditionUse=%s, userId=%s", customDataId, tostring(ctdd.conditionUse), tostring(ctdd.userId))
	res._time = ctdd.timeStatisticsType and string.format("type=%d, tLen=%s, tUnit=%s, tCnt=%d", ctdd.timeStatisticsType, tostring(ctdd.timeLength), tostring(ctdd.timeUnit), ctdd.timeStatisticsTimes or 1)

	if not self:checkUseType(ctdd.conditionUse, ctdd.userId) then
		res._repr = ObjHelper.getObjRepr(self:getObj())
		res.error = "invalid conditionUse type"

		return res
	end

	if pos == -1 then
		res.register = self:isRegister(customDataId)
		res.complete = self:isComplete(customDataId)
		res.completeOrMeetCondition = self:isCompleteOrMeetCondition(customDataId)
		res.conds = {}

		for idx, cond in ipairs(ctdd.condition) do
			local trigger, triggerId, extraArg, statisType = TriggerConst.getTriggerInfo(cond, TriggerData)
			local operator = cond[TriggerConst.CUSTOM_TRIGGER_OPERATOR_POS]
			local dstCount = cond[TriggerConst.CUSTOM_TRIGGER_NUM_POS]

			res.conds[idx] = {
				_base = string.format("[%d]%s", statisType, TriggerNameData[trigger]),
				_data = string.format("%d, %d, %s, op:%s, cnt:%s", trigger, triggerId, inspect(extraArg, {
					newline = " "
				}), tostring(operator), tostring(dstCount)),
				completeCondition = self:checkConditionFinishCount(customDataId, idx),
				finishCount = self:getConditionFinishCount(customDataId, idx)
			}
		end

		res.finishCount = self:getFinishCount(customDataId)

		if ctdd.timeStatisticsType then
			res.timeStaticCount = self.customTimeCondition[customDataId] or 0

			if ctdd.timeStatisticsType == TriggerConst.TIME_STATISTICS_TYPE.CONTINUOUS then
				res.timeStaticCountOneDay = self.dayCustomCondition[customDataId] or 0
			end
		end
	else
		res.completeCondition = self:checkConditionFinishCount(customDataId, pos)
		res.finishCount = self:getConditionFinishCount(customDataId, pos)
	end

	return res
end

function TriggerMap:getNpcBehaviorStatus(staticId, behaviorId)
	return self.npcBehaviorStatus[staticId] and self.npcBehaviorStatus[staticId][behaviorId] or -1
end

function TriggerMap:checkNeedAnyCondition(trigger)
	if trigger == TriggerConst.TRIGGER_TARGET_CHECK_CUSTOM_VARIABLE then
		return false
	end

	local ctdd = CustomTriggerMapData[trigger]

	if ctdd and ctdd[TriggerConst.TRIGGER_ID_ANY] then
		return true
	end

	if self.questRunTriggers[trigger] and self.questRunTriggers[trigger][TriggerConst.TRIGGER_ID_ANY] then
		return true
	end

	if self.questClaimTriggers[trigger] and self.questClaimTriggers[trigger][TriggerConst.TRIGGER_ID_ANY] then
		return true
	end

	if self.questObjectivesTriggers[trigger] and self.questObjectivesTriggers[trigger][TriggerConst.TRIGGER_ID_ANY] then
		return true
	end

	if self.questComActionObjTriggers[trigger] and self.questComActionObjTriggers[trigger][TriggerConst.TRIGGER_ID_ANY] then
		return true
	end

	if self.questCloseTriggers[trigger] and self.questCloseTriggers[trigger][TriggerConst.TRIGGER_ID_ANY] then
		return true
	end

	return false
end

function TriggerMap:getCommonTriggerConditionValue(addCnt, trigger, triggerId, extraArg, triggerParams)
	addCnt = addCnt or 0

	if _G_IsDebugMode then
		local gmCnt = self:getGmTriggerValue(trigger, triggerId)

		if gmCnt ~= nil then
			return gmCnt
		end
	end

	if pg.component == "game" and TriggerUtils.TRIGGER_CONDITION_FUNC_CLIENT_ONLY[trigger] or pg.component == "client" and TriggerUtils.TRIGGER_CONDITION_FUNC_SERVER_ONLY[trigger] then
		return addCnt
	end

	if TriggerUtils.isCountTrigger(trigger) then
		return TriggerUtils.getCountTriggerAddValue(addCnt, trigger, triggerParams, extraArg)
	else
		return TriggerUtils.getStatusTriggerCurValue(self:getObj(), trigger, triggerId, extraArg, triggerParams)
	end
end

function TriggerMap.checkMeetOperator(curCount, needCount, operator)
	return TriggerUtils.checkMeetOperator(curCount, needCount, operator)
end

function TriggerMap:checkMeetCustomTrigger(ctdd, triggerPos)
	local conditionExpression = ctdd.conditionExpression
	local req = {}
	local flag

	for i, triggerCondition in ipairs(ctdd.condition) do
		flag = conditionExpression[i]

		if flag == nil then
			return false
		end

		if flag > 1 and not req[flag - 1] then
			return false
		end

		if triggerPos and triggerPos == i then
			req[flag] = true
		elseif not req[flag] and self:checkCurrentValueByCondition(triggerCondition, TriggerConst.TRIGGER_REGTYPE_CUSTOM, ctdd.id, i) then
			req[flag] = true
		end
	end

	return req[flag] or false
end

function TriggerMap:checkMeetCustomTriggerWithoutMain(ctdd)
	local conditionExpression = ctdd.conditionExpression
	local condition = ctdd.condition
	local req = {}
	local pos1Flag = conditionExpression[1]

	if pos1Flag then
		local hasOtherInPos1Flag = false

		for i = 2, #condition do
			if conditionExpression[i] == pos1Flag then
				hasOtherInPos1Flag = true

				break
			end
		end

		if not hasOtherInPos1Flag then
			req[pos1Flag] = true
		end
	end

	local flag

	for i = 2, #condition do
		flag = conditionExpression[i]

		if flag == nil then
			return false
		end

		if flag > 1 and not req[flag - 1] then
			return false
		end

		if not req[flag] and self:checkCurrentValueByCondition(condition[i], TriggerConst.TRIGGER_REGTYPE_CUSTOM, ctdd.id, i) then
			req[flag] = true
		end
	end

	return req[flag] or false
end

function TriggerMap:_checkCustomVariable(id)
	local cvdd = CustomVariableData[id]

	if not cvdd then
		return false
	end

	self.customVariables[id] = self.customVariables[id] or cvdd.initalValue or 0

	return true
end

function TriggerMap:getCustomVariable(id)
	if self:_checkCustomVariable(id) == false then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("invlaid custom variable, return 0, id=%d", id)
		end

		return 0
	end

	return self.customVariables[id] or 0
end

function TriggerMap:isRegisterTriggerType(triggerType, triggerId)
	local customRegisterIds = CustomTriggerMapData[triggerType] and CustomTriggerMapData[triggerType][triggerId] or {}
	local registerCustomSet = self.registerCustomSet
	local completeCustomSet = self.completeCustomSet

	for _, reId in ipairs(customRegisterIds) do
		local customDataId, _ = TriggerConst.parseCustomTriggerKey(reId)

		if getBit(registerCustomSet, customDataId) or CustomDefaultRegisterMap[customDataId] and not getBit(completeCustomSet, customDataId) then
			return true
		end
	end

	if triggerId ~= 0 then
		return self:isRegisterTriggerType(triggerType, 0)
	end

	return false
end

function TriggerMap:addTriggerCurrentCount(triggerConstId, subKey, count)
	local addCount = count or 1

	if not self.triggerCurrentCountInfo[triggerConstId] then
		self.triggerCurrentCountInfo[triggerConstId] = {}
	end

	self.triggerCurrentCountInfo[triggerConstId][subKey] = (self.triggerCurrentCountInfo[triggerConstId][subKey] or 0) + addCount
end

function TriggerMap:getTriggerCurrentCount(triggerConstId, subKey)
	if not self.triggerCurrentCountInfo[triggerConstId] then
		return nil
	end

	if subKey == 0 then
		local sum = 0

		for _, v in pairs(self.triggerCurrentCountInfo[triggerConstId]) do
			sum = sum + v
		end

		return sum
	else
		if not self.triggerCurrentCountInfo[triggerConstId][subKey] then
			return nil
		end

		return self.triggerCurrentCountInfo[triggerConstId][subKey]
	end
end

return TriggerMap
