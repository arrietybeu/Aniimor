-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientTriggerComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Time = require("Core.Common.Time")
local class = require("Core.Framework.Class")
local lume = require("Core.Common.lume")
local TimerManager = require("Core.Timer.TimerManager")
local CTRPool = require("Common.AICt.CTRPool")
local TriggerConst = require("Common.Const.TriggerConst")
local EventConst = require("Const.EventConst")
local Utils = require("Common.Utils.Utils")
local TriggerUtils = require("Common.Utils.TriggerUtils")
local QuestCommonUtils = require("Common.Utils.QuestCommonUtils")
local AIControllerUtils = require("Common.Utils.AIControllerUtils")
local CommonSwitch = require("Common.CommonSwitch")
local ClientSwitch = require("Common.ClientSwitch")
local CustomVariableData = require("Common.Data.custom_variable_data")
local TriggerData = require("Data.trigger_data")
local CustomTriggerData = require("Data.custom_trigger_data")
local CustomTriggerMapData = require("Data.custom_trigger_map_data")
local TriggerNameData = require("Data.trigger_name_data")
local CustomTypeHelper = require("Core.PropertySync.CustomTypeHelper")
local CUSTOM_TRIGGER_TARGET_POS = TriggerConst.CUSTOM_TRIGGER_TARGET_POS
local CUSTOM_TRIGGER_EXTAR_TARGET_POS = TriggerConst.CUSTOM_TRIGGER_EXTAR_TARGET_POS
local CUSTOM_TRIGGER_OPERATOR_POS = TriggerConst.CUSTOM_TRIGGER_OPERATOR_POS
local CUSTOM_TRIGGER_NUM_POS = TriggerConst.CUSTOM_TRIGGER_NUM_POS
local TRIGGER_REGTYPE_CUSTOM = TriggerConst.TRIGGER_REGTYPE_CUSTOM
local ONLY_CHECKING_TRIGGER = TriggerConst.ONLY_CHECKING_TRIGGER
local INVALID_POSITION_X = -99999

local function invalidatePositionTriggerCache(self)
	local cache = self.triggerDataCache

	if cache then
		cache.lastPosition[1] = INVALID_POSITION_X
	end
end

local ClientTriggerComponent = class.Component("ClientTriggerComponent")

function ClientTriggerComponent:ctor()
	self.clientCustomVariables = {}
	self.lastCachedCondValueTsMap = {}
end

function ClientTriggerComponent:onEnterSpace()
	self:startClientTriggerTick()
	invalidatePositionTriggerCache(self)
end

function ClientTriggerComponent:onPositionQuestObjectivesTriggerAdded()
	invalidatePositionTriggerCache(self)
end

function ClientTriggerComponent:onPositionQuestClaimTriggerAdded()
	invalidatePositionTriggerCache(self)
end

function ClientTriggerComponent:onPositionQuestRunTriggerAdded()
	invalidatePositionTriggerCache(self)
end

function ClientTriggerComponent:onPositionQuestComActionObjTriggerAdded()
	invalidatePositionTriggerCache(self)
end

function ClientTriggerComponent:onPositionQuestCloseTriggerAdded()
	invalidatePositionTriggerCache(self)
end

function ClientTriggerComponent:startClientTriggerTick()
	if self.checkTickTimer ~= nil then
		return
	end

	self.triggerDataCache = {
		lastCameraRotation = Quaternion.New(-999999, 0, 0),
		lastPosition = {
			INVALID_POSITION_X,
			0,
			0
		},
		lastNpcBehavStatus = self:_initNpcBehavStatusCache(),
		lastInsideGotoPos = {}
	}

	if not EnableBotTest then
		local _checkCount = 0

		self.checkTickTimer = self:addRepeatTimer(0.1, function()
			if not pg.me then
				return
			end

			_checkCount = _checkCount + 1

			if _checkCount == 1 then
				self:checkTriggerChestInDistance()
			elseif _checkCount == 2 then
				self:checkTriggerAngleOfView()
				self:checkTriggerPlayerNpcDistanceWhenCallFriend()
				self:checkTriggerPetHpPercentTime()
			elseif _checkCount == 3 then
				self:checkPetTeamSkillSkillType()
				self:checkAttributeCompare()
				self:checkTriggerSpPowerFull()
			elseif _checkCount == 4 then
				self:checkTriggerMeetParmon()
				self:checkTriggerNearParmon()
			elseif _checkCount == 5 then
				if not self:checkTriggerTargetGoToPosition() then
					_checkCount = 0
				end
			else
				self:checkTriggerTargetGoToPosition(true)

				_checkCount = 0
			end
		end)
	end
end

function ClientTriggerComponent:destroy()
	if self.checkTickTimer ~= nil then
		self:removeTimer(self.checkTickTimer)

		self.checkTickTimer = nil
	end
end

function ClientTriggerComponent:registerGuideTrigger(customDataId)
	self:serverMsg("RPC_CS_RegisterGuideTrigger", customDataId)
end

function ClientTriggerComponent:unregisterGuideTrigger(customDataId)
	self:serverMsg("RPC_CS_UnRegisterGuideTrigger", customDataId)
end

local function shouldCheckQuestCondition(name, triggerType, exists, isComplete)
	if not exists then
		return false
	end

	return not isComplete or name == "closeCond" and not TriggerUtils.isCountTrigger(triggerType)
end

local function _checkQuestCondDicts(questId, triggerType, regType, triggerId)
	local configs, qData = QuestCommonUtils.getQuestTriggerConfig(questId, triggerType)

	if not configs then
		return false
	end

	for name, list in pairs(configs) do
		if list[1] == regType then
			for i = 2, #list, 2 do
				if (list[i + 1][CUSTOM_TRIGGER_TARGET_POS] or 0) == triggerId then
					local exists, isComplete = QuestCommonUtils.getQuestRuntimeCondition(pg.me, questId, qData, name, list[i])

					if shouldCheckQuestCondition(name, triggerType, exists, isComplete) then
						return true
					end
				end
			end
		end
	end

	return false
end

local function genRegInfo(regType, templateId, pos)
	return {
		regType,
		templateId,
		pos
	}
end

local function parseRegInfo(regInfo)
	return regInfo[1], regInfo[2], regInfo[3]
end

local CLIENT_CACHE_TRIGGER_TYPE = {
	[TriggerConst.TRIGGER_TARGET_ATTRIBUTE_COMPARE] = true,
	[TriggerConst.TRIGGER_TARGET_CHEST_DISTANCE] = true
}
local EXPIRE_SECONDS = 2

function ClientTriggerComponent:tryUpdateCachedCondValue(regInfo, value)
	local regType, templateId, pos = regInfo[1], regInfo[2], regInfo[3]
	local valueIsMap = self.lastCachedCondValueTsMap
	local tmp = valueIsMap[regType] or {}

	valueIsMap[regType] = tmp

	local key = templateId * 16 + pos
	local valTsPair = tmp[key] or {}

	tmp[key] = valTsPair

	local oldValue, oldTs = valTsPair[1], valTsPair[2]
	local now = Time.realSecondCache
	local isExpiredOrNewSet = oldValue == nil or oldTs == nil or value ~= oldValue or now - oldTs > EXPIRE_SECONDS

	valTsPair[1] = value
	valTsPair[2] = now

	return isExpiredOrNewSet
end

local function _addCheckingQuestCondDicts(res, reg, onlyCheckingFlags, questId, triggerType, regType, triggerId)
	local configs, qData = QuestCommonUtils.getQuestTriggerConfig(questId, triggerType)

	if not configs then
		return false
	end

	for name, list in pairs(configs) do
		if list[1] == regType then
			for i = 2, #list, 2 do
				local cond = list[i + 1]

				if (cond[CUSTOM_TRIGGER_TARGET_POS] or 0) == triggerId then
					local key = list[i]
					local exists, isComplete = QuestCommonUtils.getQuestRuntimeCondition(pg.me, questId, qData, name, key)

					if shouldCheckQuestCondition(name, triggerType, exists, isComplete) then
						res[#res + 1] = cond
						onlyCheckingFlags[#onlyCheckingFlags + 1] = false

						if reg then
							reg[#reg + 1] = genRegInfo(regType, questId, key)
						end
					end
				end
			end
		end
	end
end

local function _addCheckingCustomCondDicts(res, reg, onlyCheckingFlags, customDataId, triggerPos)
	local ctdd = CustomTriggerData[customDataId]
	local condDict = ctdd.condition[triggerPos]

	res[#res + 1] = condDict
	onlyCheckingFlags[#onlyCheckingFlags + 1] = ONLY_CHECKING_TRIGGER[ctdd.conditionUse] or false

	if reg ~= nil then
		reg[#reg + 1] = genRegInfo(TRIGGER_REGTYPE_CUSTOM, customDataId, triggerPos)
	end
end

local function needCollectCondRegInfo(triggerType)
	return TriggerUtils.usePresetConditionValue(triggerType) or CLIENT_CACHE_TRIGGER_TYPE[triggerType]
end

function ClientTriggerComponent:hasCondition(triggerType, triggerId)
	local triggerMap = self.triggerMap
	local getQuestTriggersByType = triggerMap.getQuestTriggersByType

	for questTiggerType = TriggerConst.TRIGGER_QUEST_INDEX_START, TriggerConst.TRIGGER_QUEST_INDEX_END do
		local questTriggers = getQuestTriggersByType(triggerMap, questTiggerType)

		if questTriggers ~= nil then
			for id, questRegisterIds in questTriggers:fast_items() do
				if triggerId == nil or id == triggerId then
					for questId, _ in questRegisterIds:fast_items() do
						if _checkQuestCondDicts(questId, triggerType, questTiggerType, id) then
							return true
						end
					end
				end
			end
		end
	end

	local parseCustomTriggerKey = TriggerConst.parseCustomTriggerKey
	local customRegisterIdsAll = CustomTriggerMapData[triggerType]

	if customRegisterIdsAll ~= nil then
		for id, customRegisterIds in pairs(customRegisterIdsAll) do
			if triggerId == nil or id == triggerId then
				for _, regId in ipairs(customRegisterIds) do
					local customDataId, _ = parseCustomTriggerKey(regId)

					if self.triggerMap:isRegisterFaster(customDataId) then
						return true
					end
				end
			end
		end
	end

	return false
end

local parseCustomTriggerKey = TriggerConst.parseCustomTriggerKey

function ClientTriggerComponent:getCheckingCondDicts(triggerType, triggerId)
	local res, reg, onlyCheckingFlags = {}, nil, {}

	if needCollectCondRegInfo(triggerType) then
		reg = {}
	end

	local triggerMap = self.triggerMap

	if not triggerMap then
		return res, reg, onlyCheckingFlags
	end

	if triggerId ~= TriggerConst.TRIGGER_ID_ANY and triggerMap:checkNeedAnyCondition(triggerType) then
		local anyRes, anyReg, anyOnlyCheckingFlags = self:getCheckingCondDicts(triggerType, TriggerConst.TRIGGER_ID_ANY)

		lume.append(res, anyRes)
		lume.append(onlyCheckingFlags, anyOnlyCheckingFlags)

		if reg ~= nil then
			lume.append(reg, anyReg)
		end
	end

	local getQuestTriggersByType = triggerMap.getQuestTriggersByType

	for questTiggerType = TriggerConst.TRIGGER_QUEST_INDEX_START, TriggerConst.TRIGGER_QUEST_INDEX_END do
		local questTriggers = getQuestTriggersByType(triggerMap, questTiggerType)
		local questRegisterIds = questTriggers[triggerType] and questTriggers[triggerType][triggerId]

		if questRegisterIds ~= nil then
			for questId, _ in questRegisterIds:fast_items() do
				_addCheckingQuestCondDicts(res, reg, onlyCheckingFlags, questId, triggerType, questTiggerType, triggerId)
			end
		end
	end

	local customRegisterIds = CustomTriggerMapData[triggerType] and CustomTriggerMapData[triggerType][triggerId]

	if customRegisterIds ~= nil then
		for _, regId in ipairs(customRegisterIds) do
			local customDataId, triggerPos = parseCustomTriggerKey(regId)

			if triggerMap:isRegisterFaster(customDataId) then
				_addCheckingCustomCondDicts(res, reg, onlyCheckingFlags, customDataId, triggerPos)
			end
		end
	end

	return res, reg, onlyCheckingFlags
end

local parseCustomTriggerKey = TriggerConst.parseCustomTriggerKey

function ClientTriggerComponent:getAllCheckingCondDicts(triggerType)
	local resAll, regAll, onlyCheckingFlagsAll = {}, nil, {}
	local triggerMap = self.triggerMap

	if needCollectCondRegInfo(triggerType) then
		regAll = {}

		local getQuestTriggersByType = triggerMap.getQuestTriggersByType

		for questTiggerType = TriggerConst.TRIGGER_QUEST_INDEX_START, TriggerConst.TRIGGER_QUEST_INDEX_END do
			local questTriggers = getQuestTriggersByType(triggerMap, questTiggerType)

			questTriggers = CustomTypeHelper.GetProp(questTriggers, triggerType)

			if questTriggers ~= nil then
				for triggerId, questRegisterIds in questTriggers:fast_items() do
					for questId, _ in questRegisterIds:fast_items() do
						local resTrigger = resAll[triggerId] or {}

						resAll[triggerId] = resTrigger

						local onleyCheckFlags = onlyCheckingFlagsAll[triggerId] or {}

						onlyCheckingFlagsAll[triggerId] = onleyCheckFlags

						local regTrigger = regAll[triggerId] or {}

						regAll[triggerId] = regTrigger

						_addCheckingQuestCondDicts(resTrigger, regTrigger, onleyCheckFlags, questId, triggerType, questTiggerType, triggerId)
					end
				end
			end
		end

		local customRegisterIdsAll = CustomTriggerMapData[triggerType]

		if customRegisterIdsAll ~= nil then
			for triggerId, customRegisterIds in pairs(customRegisterIdsAll) do
				if #customRegisterIds > 1 then
					local resTrigger = resAll[triggerId] or {}

					resAll[triggerId] = resTrigger

					local onleyCheckFlags = onlyCheckingFlagsAll[triggerId] or {}

					onlyCheckingFlagsAll[triggerId] = onleyCheckFlags

					local regTrigger = regAll[triggerId] or {}

					regAll[triggerId] = regTrigger

					for _, regId in ipairs(customRegisterIds) do
						local customDataId, triggerPos = parseCustomTriggerKey(regId)

						if triggerMap:isRegisterFaster(customDataId) then
							_addCheckingCustomCondDicts(resTrigger, regTrigger, onleyCheckFlags, customDataId, triggerPos)
						end
					end
				else
					for _, regId in ipairs(customRegisterIds) do
						local resTrigger = resAll[triggerId] or {}

						resAll[triggerId] = resTrigger

						local onleyCheckFlags = onlyCheckingFlagsAll[triggerId] or {}

						onlyCheckingFlagsAll[triggerId] = onleyCheckFlags

						local regTrigger = regAll[triggerId] or {}

						regAll[triggerId] = regTrigger

						local customDataId, triggerPos = parseCustomTriggerKey(regId)

						if triggerMap:isRegisterFaster(customDataId) then
							_addCheckingCustomCondDicts(resTrigger, regTrigger, onleyCheckFlags, customDataId, triggerPos)
						end
					end
				end
			end
		end
	else
		local getQuestTriggersByType = triggerMap.getQuestTriggersByType

		for questTiggerType = TriggerConst.TRIGGER_QUEST_INDEX_START, TriggerConst.TRIGGER_QUEST_INDEX_END do
			local questTriggers = getQuestTriggersByType(triggerMap, questTiggerType)

			questTriggers = CustomTypeHelper.GetProp(questTriggers, triggerType)

			if questTriggers ~= nil then
				for triggerId, questRegisterIds in questTriggers:fast_items() do
					for questId, _ in questRegisterIds:fast_items() do
						local resTrigger = resAll[triggerId] or {}

						resAll[triggerId] = resTrigger

						local onleyCheckFlags = onlyCheckingFlagsAll[triggerId] or {}

						onlyCheckingFlagsAll[triggerId] = onleyCheckFlags

						_addCheckingQuestCondDicts(resTrigger, nil, onleyCheckFlags, questId, triggerType, questTiggerType, triggerId)
					end
				end
			end
		end

		local customRegisterIdsAll = CustomTriggerMapData[triggerType]

		if customRegisterIdsAll ~= nil then
			for triggerId, customRegisterIds in pairs(customRegisterIdsAll) do
				if #customRegisterIds > 1 then
					local resTrigger = resAll[triggerId] or {}

					resAll[triggerId] = resTrigger

					local onleyCheckFlags = onlyCheckingFlagsAll[triggerId] or {}

					onlyCheckingFlagsAll[triggerId] = onleyCheckFlags

					for _, regId in ipairs(customRegisterIds) do
						local customDataId, triggerPos = parseCustomTriggerKey(regId)

						if triggerMap:isRegisterFaster(customDataId) then
							_addCheckingCustomCondDicts(resTrigger, nil, onleyCheckFlags, customDataId, triggerPos)
						end
					end
				else
					for _, regId in ipairs(customRegisterIds) do
						local resTrigger = resAll[triggerId] or {}

						resAll[triggerId] = resTrigger

						local onleyCheckFlags = onlyCheckingFlagsAll[triggerId] or {}

						onlyCheckingFlagsAll[triggerId] = onleyCheckFlags

						local customDataId, triggerPos = parseCustomTriggerKey(regId)

						if triggerMap:isRegisterFaster(customDataId) then
							_addCheckingCustomCondDicts(resTrigger, nil, onleyCheckFlags, customDataId, triggerPos)
						end
					end
				end
			end
		end
	end

	return resAll, regAll, onlyCheckingFlagsAll
end

local getCountTriggerAddValue = TriggerUtils.getCountTriggerAddValue
local getStatusTriggerCurValue = TriggerUtils.getStatusTriggerCurValue
local isCountTrigger = TriggerUtils.isCountTrigger

local function getConditionValue(player, condRegInfo)
	if condRegInfo == nil then
		return 0
	end

	return player.triggerMap:getConditionValue(condRegInfo[1], condRegInfo[2], condRegInfo[3])
end

local function isOnlyCheckingRegInfo(condRegInfo)
	if condRegInfo == nil then
		return false
	end

	if condRegInfo[1] ~= TRIGGER_REGTYPE_CUSTOM then
		return false
	end

	local ctdd = CustomTriggerData[condRegInfo[2]]

	return ctdd and ONLY_CHECKING_TRIGGER[ctdd.conditionUse] or false
end

function ClientTriggerComponent:_triggerCondDictCount(cond, triggerType, count, triggerParams)
	local extraArg = cond[CUSTOM_TRIGGER_EXTAR_TARGET_POS]
	local addCount = getCountTriggerAddValue(count, triggerType, triggerParams, extraArg)

	return addCount ~= 0
end

function ClientTriggerComponent:_triggerCondDict(cond, triggerType, triggerParams, condRegInfo, onlyChecking)
	local needNotifyServer = false
	local arg = cond[CUSTOM_TRIGGER_TARGET_POS]
	local extraArg = cond[CUSTOM_TRIGGER_EXTAR_TARGET_POS]
	local curCount = getStatusTriggerCurValue(self, triggerType, arg, extraArg, triggerParams)

	if condRegInfo then
		if CLIENT_CACHE_TRIGGER_TYPE[triggerType] and self:tryUpdateCachedCondValue(condRegInfo, curCount) then
			needNotifyServer = true
		end

		if TriggerUtils.TRIGGER_CONDITION_FUNC_CLIENT_ONLY[triggerType] and TriggerUtils.usePresetConditionValue(triggerType) and getConditionValue(self, condRegInfo) ~= curCount then
			self:_onClientSetConditionValue(condRegInfo, curCount)

			needNotifyServer = true
		end
	else
		local operator = cond[CUSTOM_TRIGGER_OPERATOR_POS]
		local dstCount = cond[CUSTOM_TRIGGER_NUM_POS]

		needNotifyServer = TriggerUtils.checkMeetOperator(curCount, dstCount, operator)
	end

	needNotifyServer = needNotifyServer and not onlyChecking and not isOnlyCheckingRegInfo(condRegInfo)

	return needNotifyServer
end

function ClientTriggerComponent:_triggerCondDictReg(cond, triggerType, triggerParams, onlyChecking, condRegInfo)
	local needNotifyServer = false
	local arg = cond[CUSTOM_TRIGGER_TARGET_POS]
	local extraArg = cond[CUSTOM_TRIGGER_EXTAR_TARGET_POS]
	local curCount = getStatusTriggerCurValue(self, triggerType, arg, extraArg, triggerParams)

	if CLIENT_CACHE_TRIGGER_TYPE[triggerType] and self:tryUpdateCachedCondValue(condRegInfo, curCount) then
		needNotifyServer = true
	end

	if TriggerUtils.TRIGGER_CONDITION_FUNC_CLIENT_ONLY[triggerType] and TriggerUtils.usePresetConditionValue(triggerType) and getConditionValue(self, condRegInfo) ~= curCount then
		self:_onClientSetConditionValue(condRegInfo, curCount)

		needNotifyServer = true
	end

	needNotifyServer = needNotifyServer and not onlyChecking and not isOnlyCheckingRegInfo(condRegInfo)

	return needNotifyServer
end

function ClientTriggerComponent:_triggerCondDictNoReg(cond, triggerType, triggerParams, isComplete, onlyChecking)
	local arg = cond[CUSTOM_TRIGGER_TARGET_POS]
	local extraArg = cond[CUSTOM_TRIGGER_EXTAR_TARGET_POS]
	local curCount = getStatusTriggerCurValue(self, triggerType, arg, extraArg, triggerParams)
	local operator = cond[CUSTOM_TRIGGER_OPERATOR_POS]
	local dstCount = cond[CUSTOM_TRIGGER_NUM_POS]
	local meetOpeartor = TriggerUtils.checkMeetOperator(curCount, dstCount, operator)
	local needNotifyServer = (meetOpeartor or isComplete == true) and not onlyChecking

	return needNotifyServer
end

function ClientTriggerComponent:_onClientSetConditionValue(condRegInfo, value)
	local regType, templateId, pos = parseRegInfo(condRegInfo)

	if regType == nil then
		return
	end

	value = ToInt(value)

	local currentValue = self.triggerMap:getConditionValue(regType, templateId, pos)

	if currentValue == value then
		return
	end

	self:serverMsg("RPC_CS_OnClientSetConditionValue", regType, templateId, pos, value)
end

function ClientTriggerComponent:_onClientTrigger(triggerType, triggerId, count, triggerParams)
	triggerId = triggerId or TriggerConst.TRIGGER_ID_ANY
	count = count or 1

	self:serverMsg("RPC_CS_OnClientTrigger", triggerType, triggerId, count, {
		triggerParams
	})
end

function ClientTriggerComponent:tryClientTriggerAllOld(triggerType, count, triggerParams)
	if triggerType == nil then
		return
	end

	count = count or 0

	local allCondDicts, allRegInfos, allOnlyCheckingFlags = self:getAllCheckingCondDicts(triggerType)

	if CommonSwitch.TriggerDebugLog or ClientSwitch.TriggerDebugLog then
		local commonValue = self.triggerMap:getCommonTriggerConditionValue(count, triggerType, 0, nil, triggerParams)

		self.logger:debug("tryClientTriggerAll, triggerType=%d, count=%s, triggerName=%s, triggerParams=%s, allCondDicts=%s, allRegInfos=%s, allOnlyCheckingFlags=%s", triggerType, string.format("%d(%d)", count, commonValue), string.format("%s", TriggerNameData[triggerType] or ""), inspect(triggerParams), inspect(allCondDicts), inspect(allRegInfos), inspect(allOnlyCheckingFlags))
	end

	if allCondDicts == nil or not next(allCondDicts) then
		return
	end

	if isCountTrigger(triggerType) == false then
		if allRegInfos then
			for triggerId, condDicts in pairs(allCondDicts) do
				local needNotifyServer = false
				local regInfos = allRegInfos[triggerId]
				local allOnlyCheckingFlag = allOnlyCheckingFlags[triggerId]

				for index, cond in pairs(condDicts) do
					local onlyChecking = allOnlyCheckingFlag and allOnlyCheckingFlag[index]
					local success = self:_triggerCondDict(cond, triggerType, triggerParams, regInfos and regInfos[index], onlyChecking)

					needNotifyServer = needNotifyServer or success
				end

				if needNotifyServer then
					self:_onClientTrigger(triggerType, triggerId, count, triggerParams)
				end
			end
		else
			for triggerId, condDicts in pairs(allCondDicts) do
				local needNotifyServer = false
				local allOnlyCheckingFlag = allOnlyCheckingFlags[triggerId]

				for index, cond in pairs(condDicts) do
					local onlyChecking = allOnlyCheckingFlag and allOnlyCheckingFlag[index]
					local success = self:_triggerCondDict(cond, triggerType, triggerParams, nil, onlyChecking)

					needNotifyServer = needNotifyServer or success
				end

				if needNotifyServer then
					self:_onClientTrigger(triggerType, triggerId, count, triggerParams)
				end
			end
		end
	else
		for triggerId, condDicts in pairs(allCondDicts) do
			for index, cond in pairs(condDicts) do
				local success = self:_triggerCondDictCount(cond, triggerType, count, triggerParams)

				if success then
					self:_onClientTrigger(triggerType, triggerId, count, triggerParams)

					break
				end
			end
		end
	end
end

function ClientTriggerComponent:getAllCheckingCondDictsDirects(triggerType)
	local allCondDicts, allRegInfos, allOnlyCheckingFlags = {}, nil, {}
	local triggerMap = self.triggerMap

	if needCollectCondRegInfo(triggerType) then
		allRegInfos = {}

		local getQuestTriggersByType = triggerMap.getQuestTriggersByType

		for questTiggerType = TriggerConst.TRIGGER_QUEST_INDEX_START, TriggerConst.TRIGGER_QUEST_INDEX_END do
			local questTriggers = getQuestTriggersByType(triggerMap, questTiggerType)

			questTriggers = CustomTypeHelper.GetProp(questTriggers, triggerType)

			if questTriggers ~= nil then
				for triggerId, questRegisterIds in questTriggers:fast_items() do
					for questId, _ in questRegisterIds:fast_items() do
						local resTrigger = allCondDicts[triggerId] or {}

						allCondDicts[triggerId] = resTrigger

						local onleyCheckFlags = allOnlyCheckingFlags[triggerId] or {}

						allOnlyCheckingFlags[triggerId] = onleyCheckFlags

						local regTrigger = allRegInfos[triggerId] or {}

						allRegInfos[triggerId] = regTrigger

						_addCheckingQuestCondDicts(resTrigger, regTrigger, onleyCheckFlags, questId, triggerType, questTiggerType, triggerId)
					end
				end
			end
		end

		local customRegisterIdsAll = CustomTriggerMapData[triggerType]

		if customRegisterIdsAll ~= nil then
			for triggerId, customRegisterIds in pairs(customRegisterIdsAll) do
				if #customRegisterIds > 1 then
					local resTrigger = allCondDicts[triggerId] or {}

					allCondDicts[triggerId] = resTrigger

					local onleyCheckFlags = allOnlyCheckingFlags[triggerId] or {}

					allOnlyCheckingFlags[triggerId] = onleyCheckFlags

					local regTrigger = allRegInfos[triggerId] or {}

					allRegInfos[triggerId] = regTrigger

					for _, regId in ipairs(customRegisterIds) do
						local customDataId, triggerPos = parseCustomTriggerKey(regId)

						if triggerMap:isRegisterFaster(customDataId) then
							_addCheckingCustomCondDicts(resTrigger, regTrigger, onleyCheckFlags, customDataId, triggerPos)
						end
					end
				else
					for _, regId in ipairs(customRegisterIds) do
						local resTrigger = allCondDicts[triggerId] or {}

						allCondDicts[triggerId] = resTrigger

						local onleyCheckFlags = allOnlyCheckingFlags[triggerId] or {}

						allOnlyCheckingFlags[triggerId] = onleyCheckFlags

						local regTrigger = allRegInfos[triggerId] or {}

						allRegInfos[triggerId] = regTrigger

						local customDataId, triggerPos = parseCustomTriggerKey(regId)

						if triggerMap:isRegisterFaster(customDataId) then
							_addCheckingCustomCondDicts(resTrigger, regTrigger, onleyCheckFlags, customDataId, triggerPos)
						end
					end
				end
			end
		end
	else
		local getQuestTriggersByType = triggerMap.getQuestTriggersByType

		for questTiggerType = TriggerConst.TRIGGER_QUEST_INDEX_START, TriggerConst.TRIGGER_QUEST_INDEX_END do
			local questTriggers = getQuestTriggersByType(triggerMap, questTiggerType)

			questTriggers = CustomTypeHelper.GetProp(questTriggers, triggerType)

			if questTriggers ~= nil then
				for triggerId, questRegisterIds in questTriggers:fast_items() do
					for questId, _ in questRegisterIds:fast_items() do
						local resTrigger = allCondDicts[triggerId] or {}

						allCondDicts[triggerId] = resTrigger

						local onleyCheckFlags = allOnlyCheckingFlags[triggerId] or {}

						allOnlyCheckingFlags[triggerId] = onleyCheckFlags

						_addCheckingQuestCondDicts(resTrigger, nil, onleyCheckFlags, questId, triggerType, questTiggerType, triggerId)
					end
				end
			end
		end

		local customRegisterIdsAll = CustomTriggerMapData[triggerType]

		if customRegisterIdsAll ~= nil then
			for triggerId, customRegisterIds in pairs(customRegisterIdsAll) do
				if #customRegisterIds > 1 then
					local resTrigger = allCondDicts[triggerId] or {}

					allCondDicts[triggerId] = resTrigger

					local onleyCheckFlags = allOnlyCheckingFlags[triggerId] or {}

					allOnlyCheckingFlags[triggerId] = onleyCheckFlags

					for _, regId in ipairs(customRegisterIds) do
						local customDataId, triggerPos = parseCustomTriggerKey(regId)

						if triggerMap:isRegisterFaster(customDataId) then
							_addCheckingCustomCondDicts(resTrigger, nil, onleyCheckFlags, customDataId, triggerPos)
						end
					end
				else
					for _, regId in ipairs(customRegisterIds) do
						local resTrigger = allCondDicts[triggerId] or {}

						allCondDicts[triggerId] = resTrigger

						local onleyCheckFlags = allOnlyCheckingFlags[triggerId] or {}

						allOnlyCheckingFlags[triggerId] = onleyCheckFlags

						local customDataId, triggerPos = parseCustomTriggerKey(regId)

						if triggerMap:isRegisterFaster(customDataId) then
							_addCheckingCustomCondDicts(resTrigger, nil, onleyCheckFlags, customDataId, triggerPos)
						end
					end
				end
			end
		end
	end

	return allCondDicts, allRegInfos, allOnlyCheckingFlags
end

local _pendingTriggerIds = {}

local function beginClientTriggerAllCount()
	for triggerId in pairs(_pendingTriggerIds) do
		_pendingTriggerIds[triggerId] = nil
	end
end

local function pendClientTriggerCount(triggerId)
	_pendingTriggerIds[triggerId] = true
end

function ClientTriggerComponent:_flushClientTriggerAllCount(triggerType, count, triggerParams)
	local pending = _pendingTriggerIds
	local anyTriggerId = TriggerConst.TRIGGER_ID_ANY

	if pending[anyTriggerId] then
		local hasConcreteTriggerId = false

		for triggerId in pairs(pending) do
			if triggerId ~= anyTriggerId then
				hasConcreteTriggerId = true

				break
			end
		end

		if hasConcreteTriggerId and self.triggerMap:checkNeedAnyCondition(triggerType) then
			pending[anyTriggerId] = nil
		end
	end

	for triggerId in pairs(pending) do
		self:_onClientTrigger(triggerType, triggerId, count, triggerParams)
	end
end

function ClientTriggerComponent:tryClientTriggerAll(triggerType, count, triggerParams)
	SampleUtils.beginSampleEx(triggerType)

	count = count or 0

	if isCountTrigger(triggerType) == false then
		if needCollectCondRegInfo(triggerType) then
			self:tryClientTriggerAllReg(triggerType, count, triggerParams)
		else
			self:tryClientTriggerAllNoReg(triggerType, count, triggerParams)
		end
	else
		self:tryClientTriggerAllCount(triggerType, count, triggerParams)
	end

	SampleUtils.endSampleEx()
end

function ClientTriggerComponent:_triggerQuestCondCount(questId, triggerType, count, triggerParams, regType, triggerId)
	local configs, qData = QuestCommonUtils.getQuestTriggerConfig(questId, triggerType)

	if not configs then
		return false
	end

	for name, list in pairs(configs) do
		if list[1] == regType then
			for i = 2, #list, 2 do
				local cond = list[i + 1]

				if (cond[CUSTOM_TRIGGER_TARGET_POS] or 0) == triggerId then
					local exists, isComplete = QuestCommonUtils.getQuestRuntimeCondition(pg.me, questId, qData, name, list[i])

					if shouldCheckQuestCondition(name, triggerType, exists, isComplete) then
						local success = self:_triggerCondDictCount(cond, triggerType, count, triggerParams)

						if success then
							return true
						end
					end
				end
			end
		end
	end

	return false
end

function ClientTriggerComponent:_triggerCustomCondCount(customDataId, triggerPos, triggerType, count, triggerParams)
	local ctdd = CustomTriggerData[customDataId]
	local condDict = ctdd.condition[triggerPos]

	return self:_triggerCondDictCount(condDict, triggerType, count, triggerParams)
end

function ClientTriggerComponent:tryClientTriggerAllCount(triggerType, count, triggerParams)
	beginClientTriggerAllCount()

	local triggerMap = self.triggerMap
	local getQuestTriggersByType = triggerMap.getQuestTriggersByType

	for questTiggerType = TriggerConst.TRIGGER_QUEST_INDEX_START, TriggerConst.TRIGGER_QUEST_INDEX_END do
		local questTriggers = getQuestTriggersByType(triggerMap, questTiggerType)

		questTriggers = CustomTypeHelper.GetProp(questTriggers, triggerType)

		if questTriggers ~= nil then
			for triggerId, questRegisterIds in questTriggers:fast_items() do
				for questId, _ in questRegisterIds:fast_items() do
					local success = self:_triggerQuestCondCount(questId, triggerType, count, triggerParams, questTiggerType, triggerId)

					if success then
						pendClientTriggerCount(triggerId)

						break
					end
				end
			end
		end
	end

	local customRegisterIdsAll = CustomTriggerMapData[triggerType]

	if customRegisterIdsAll ~= nil then
		local isRegisterFaster = triggerMap.isRegisterFaster

		for triggerId, customRegisterIds in pairs(customRegisterIdsAll) do
			for _, regId in ipairs(customRegisterIds) do
				local customDataId, triggerPos = parseCustomTriggerKey(regId)

				if isRegisterFaster(triggerMap, customDataId) then
					local success = self:_triggerCustomCondCount(customDataId, triggerPos, triggerType, count, triggerParams)

					if success then
						pendClientTriggerCount(triggerId)

						break
					end
				end
			end
		end
	end

	self:_flushClientTriggerAllCount(triggerType, count, triggerParams)
end

local _tmpReg = {}

local function genTempRegInfo(regType, templateId, pos)
	_tmpReg[1] = regType
	_tmpReg[2] = templateId
	_tmpReg[3] = pos

	return _tmpReg
end

function ClientTriggerComponent:_triggerQuestCondReg(questId, triggerType, triggerParams, regType, triggerId)
	local configs, qData = QuestCommonUtils.getQuestTriggerConfig(questId, triggerType)

	if not configs then
		return false
	end

	local needNotifyServer = false

	for name, list in pairs(configs) do
		if list[1] == regType then
			for i = 2, #list, 2 do
				local cond = list[i + 1]

				if (cond[CUSTOM_TRIGGER_TARGET_POS] or 0) == triggerId then
					local key = list[i]
					local exists, isComplete = QuestCommonUtils.getQuestRuntimeCondition(pg.me, questId, qData, name, key)

					if shouldCheckQuestCondition(name, triggerType, exists, isComplete) then
						local reg = genTempRegInfo(regType, questId, key)
						local success = self:_triggerCondDictReg(cond, triggerType, triggerParams, false, reg)

						needNotifyServer = needNotifyServer or success
					end
				end
			end
		end
	end

	return needNotifyServer
end

function ClientTriggerComponent:tryClientTriggerAllReg(triggerType, count, triggerParams)
	local triggerMap = self.triggerMap
	local getQuestTriggersByType = triggerMap.getQuestTriggersByType
	local pendingTriggerIds

	for questTiggerType = TriggerConst.TRIGGER_QUEST_INDEX_START, TriggerConst.TRIGGER_QUEST_INDEX_END do
		local questTriggers = getQuestTriggersByType(triggerMap, questTiggerType)

		questTriggers = CustomTypeHelper.GetProp(questTriggers, triggerType)

		if questTriggers ~= nil then
			for triggerId, questRegisterIds in questTriggers:fast_items() do
				local needNotifyServer = false

				for questId, _ in questRegisterIds:fast_items() do
					local success = self:_triggerQuestCondReg(questId, triggerType, triggerParams, questTiggerType, triggerId)

					needNotifyServer = needNotifyServer or success
				end

				if needNotifyServer then
					pendingTriggerIds = pendingTriggerIds or {}
					pendingTriggerIds[triggerId] = true
				end
			end
		end
	end

	local customRegisterIdsAll = CustomTriggerMapData[triggerType]

	if customRegisterIdsAll ~= nil then
		local getRegisterConfig = triggerMap.getRegisterConfig

		for triggerId, customRegisterIds in pairs(customRegisterIdsAll) do
			local needNotifyServer = false

			for _, regId in ipairs(customRegisterIds) do
				local customDataId, triggerPos = parseCustomTriggerKey(regId)
				local ctdd = getRegisterConfig(triggerMap, customDataId)

				if ctdd then
					local condDict = ctdd.condition[triggerPos]
					local reg = genTempRegInfo(TRIGGER_REGTYPE_CUSTOM, customDataId, triggerPos)
					local success = self:_triggerCondDictReg(condDict, triggerType, triggerParams, ONLY_CHECKING_TRIGGER[ctdd.conditionUse], reg)

					needNotifyServer = needNotifyServer or success
				end
			end

			if needNotifyServer then
				pendingTriggerIds = pendingTriggerIds or {}
				pendingTriggerIds[triggerId] = true
			end
		end
	end

	if pendingTriggerIds ~= nil then
		for triggerId in pairs(pendingTriggerIds) do
			self:_onClientTrigger(triggerType, triggerId, count, triggerParams)
		end
	end
end

function ClientTriggerComponent:_triggerQuestCondNoReg(questId, triggerType, triggerParams, regType, triggerId)
	local configs, qData = QuestCommonUtils.getQuestTriggerConfig(questId, triggerType)

	if not configs then
		return false
	end

	for name, list in pairs(configs) do
		if list[1] == regType then
			for i = 2, #list, 2 do
				local cond = list[i + 1]

				if (cond[CUSTOM_TRIGGER_TARGET_POS] or 0) == triggerId then
					local exists, isComplete = QuestCommonUtils.getQuestRuntimeCondition(pg.me, questId, qData, name, list[i])

					if exists then
						local success = self:_triggerCondDictNoReg(cond, triggerType, triggerParams, isComplete, false)

						if success then
							return true
						end
					end
				end
			end
		end
	end

	return false
end

function ClientTriggerComponent:tryClientTriggerAllNoReg(triggerType, count, triggerParams)
	local triggerMap = self.triggerMap
	local getQuestTriggersByType = triggerMap.getQuestTriggersByType
	local args = TriggerUtils.TRIGGER_CUSTOM_CLIENT_ONLY[triggerType]

	if args and args.questFastFilter then
		local questFastFilter = args.questFastFilter

		for questTiggerType = TriggerConst.TRIGGER_QUEST_INDEX_START, TriggerConst.TRIGGER_QUEST_INDEX_END do
			local questTriggers = getQuestTriggersByType(triggerMap, questTiggerType)

			questTriggers = CustomTypeHelper.GetProp(questTriggers, triggerType)

			if questTriggers ~= nil then
				for triggerId, questRegisterIds in questTriggers:fast_items() do
					if questFastFilter(triggerId) then
						local needNotifyServer = false

						for questId, _ in questRegisterIds:fast_items() do
							local success = self:_triggerQuestCondNoReg(questId, triggerType, triggerParams, questTiggerType, triggerId)

							needNotifyServer = needNotifyServer or success
						end

						if needNotifyServer then
							self:_onClientTrigger(triggerType, triggerId, count, triggerParams)
						end
					end
				end
			end
		end
	else
		for questTiggerType = TriggerConst.TRIGGER_QUEST_INDEX_START, TriggerConst.TRIGGER_QUEST_INDEX_END do
			local questTriggers = getQuestTriggersByType(triggerMap, questTiggerType)

			questTriggers = CustomTypeHelper.GetProp(questTriggers, triggerType)

			if questTriggers ~= nil then
				for triggerId, questRegisterIds in questTriggers:fast_items() do
					local needNotifyServer = false

					for questId, _ in questRegisterIds:fast_items() do
						local success = self:_triggerQuestCondNoReg(questId, triggerType, triggerParams, questTiggerType, triggerId)

						needNotifyServer = needNotifyServer or success
					end

					if needNotifyServer then
						self:_onClientTrigger(triggerType, triggerId, count, triggerParams)
					end
				end
			end
		end
	end

	local customRegisterIdsAll = CustomTriggerMapData[triggerType]

	if customRegisterIdsAll ~= nil then
		if args then
			local filterArgs = args.generateFilters(triggerType, customRegisterIdsAll)
			local fastFilter = args.fastFilter
			local getRegisterConfig = triggerMap.getRegisterConfig

			for triggerId, customRegisterIds in pairs(customRegisterIdsAll) do
				local filterArg = filterArgs[triggerId]

				if not filterArg or fastFilter(filterArg) then
					local needNotifyServer = false

					for i = 1, #customRegisterIds do
						local regId = customRegisterIds[i]
						local customDataId, triggerPos = parseCustomTriggerKey(regId)
						local ctdd = getRegisterConfig(triggerMap, customDataId)

						if ctdd then
							local condDict = ctdd.condition[triggerPos]
							local success = self:_triggerCondDictNoReg(condDict, triggerType, triggerParams, nil, ONLY_CHECKING_TRIGGER[ctdd.conditionUse])

							needNotifyServer = needNotifyServer or success
						end
					end

					if needNotifyServer then
						self:_onClientTrigger(triggerType, triggerId, count, triggerParams)
					end
				end
			end
		else
			local getRegisterConfig = triggerMap.getRegisterConfig

			for triggerId, customRegisterIds in pairs(customRegisterIdsAll) do
				local needNotifyServer = false

				for i = 1, #customRegisterIds do
					local regId = customRegisterIds[i]
					local customDataId, triggerPos = parseCustomTriggerKey(regId)
					local ctdd = getRegisterConfig(triggerMap, customDataId)

					if ctdd then
						local condDict = ctdd.condition[triggerPos]
						local success = self:_triggerCondDictNoReg(condDict, triggerType, triggerParams, nil, ONLY_CHECKING_TRIGGER[ctdd.conditionUse])

						needNotifyServer = needNotifyServer or success
					end
				end

				if needNotifyServer then
					self:_onClientTrigger(triggerType, triggerId, count, triggerParams)
				end
			end
		end
	end
end

function ClientTriggerComponent:tryClientTrigger(triggerType, triggerId, count, triggerParams)
	if triggerType == nil or triggerId == nil then
		return
	end

	count = count or 0

	local condDicts, regInfos, onlyCheckingFlags = self:getCheckingCondDicts(triggerType, triggerId)

	if CommonSwitch.TriggerDebugLog or ClientSwitch.TriggerDebugLog then
		local commonValue = self.triggerMap:getCommonTriggerConditionValue(count, triggerType, triggerId, nil, triggerParams)

		self.logger:debug("tryClientTrigger, triggerType=%d, triggerId=%d, count=%s, triggerName=%s, triggerParams=%s, condDicts=%s, regInfos=%s, onlyCheckingFlags=%s", triggerType, triggerId, string.format("%d(%d)", count, commonValue), string.format("%s", TriggerNameData[triggerType] or ""), inspect(triggerParams), inspect(condDicts), inspect(regInfos), inspect(onlyCheckingFlags))
	end

	if condDicts == nil or not next(condDicts) then
		return
	end

	if isCountTrigger(triggerType) == false then
		local needNotifyServer = false

		for index, cond in pairs(condDicts) do
			local onlyChecking = onlyCheckingFlags and onlyCheckingFlags[index]
			local success = self:_triggerCondDict(cond, triggerType, triggerParams, regInfos and regInfos[index], onlyChecking)

			needNotifyServer = needNotifyServer or success
		end

		if needNotifyServer then
			self:_onClientTrigger(triggerType, triggerId, count, triggerParams)
		end
	else
		for index, cond in pairs(condDicts) do
			local success = self:_triggerCondDictCount(cond, triggerType, count, triggerParams)

			if success then
				self:_onClientTrigger(triggerType, triggerId, count, triggerParams)

				break
			end
		end
	end
end

function ClientTriggerComponent:checkTriggerTargetGoToPosition(otherPosition)
	if not otherPosition then
		local curPosition = self:getPosition()
		local lastPos = self.triggerDataCache.lastPosition

		if lastPos[1] == curPosition[1] and lastPos[2] == curPosition[2] and lastPos[3] == curPosition[3] then
			return false
		end

		lastPos[1] = curPosition[1]
		lastPos[2] = curPosition[2]
		lastPos[3] = curPosition[3]
	end

	if otherPosition then
		self:checkTrigger_TRIGGER_TARGET_CONTROL_GOTO_POSITION()
		self:checkTrigger_TRIGGER_PET_RACE_POSITION()
		self:checkTrigger_TRIGGER_CONTROL_GOTO_POSITION_PET()
		self:checkTrigger_TRIGGER_TARGET_ARRIVE_HOME_CAR_POSITION()
	else
		self:checkTrigger_TRIGGER_TARGET_GOTO_POSITION()
	end

	return true
end

function ClientTriggerComponent:checkTrigger_TRIGGER_TARGET_GOTO_POSITION()
	local space = pg.me.space

	if not space then
		return
	end

	TriggerUtils.ClientOnSceneLoad(space.sceneId)
	self:tryClientTriggerAll(TriggerConst.TRIGGER_TARGET_GOTO_POSITION)
	self:_scanGotoPositionLeave()
end

function ClientTriggerComponent:_scanGotoPositionLeave()
	local cache = self.triggerDataCache
	local lastInside = cache.lastInsideGotoPos
	local space = pg.me.space
	local sceneId = space and space.sceneId

	if cache.lastGotoSceneId ~= sceneId then
		cache.lastGotoSceneId = sceneId
		lastInside = {}
		cache.lastInsideGotoPos = lastInside
	end

	local curInside
	local triggerType = TriggerConst.TRIGGER_TARGET_GOTO_POSITION
	local triggerMap = self.triggerMap
	local getQuestTriggersByType = triggerMap.getQuestTriggersByType

	for questTiggerType = TriggerConst.TRIGGER_QUEST_INDEX_START, TriggerConst.TRIGGER_QUEST_INDEX_END do
		local questTriggers = getQuestTriggersByType(triggerMap, questTiggerType)

		questTriggers = CustomTypeHelper.GetProp(questTriggers, triggerType)

		if questTriggers ~= nil then
			for triggerId in questTriggers:fast_items() do
				if triggerId ~= TriggerConst.TRIGGER_ID_ANY and Utils.checkPositionMatchClient(triggerId) then
					curInside = curInside or {}
					curInside[triggerId] = true
				end
			end
		end
	end

	for posId in pairs(lastInside) do
		if not curInside or not curInside[posId] then
			self:_onClientTrigger(triggerType, posId, 0, nil)
		end
	end

	self.triggerDataCache.lastInsideGotoPos = curInside or {}
end

function ClientTriggerComponent:checkTrigger_TRIGGER_TARGET_CONTROL_GOTO_POSITION()
	self:tryClientTriggerAll(TriggerConst.TRIGGER_TARGET_CONTROL_GOTO_POSITION)
end

function ClientTriggerComponent:checkTrigger_TRIGGER_PET_RACE_POSITION()
	self:tryClientTriggerAll(TriggerConst.TRIGGER_PET_RACE_POSITION)
end

function ClientTriggerComponent:checkTrigger_TRIGGER_CONTROL_GOTO_POSITION_PET()
	self:tryClientTriggerAll(TriggerConst.TRIGGER_CONTROL_GOTO_POSITION_PET)
end

function ClientTriggerComponent:checkTrigger_TRIGGER_TARGET_ARRIVE_HOME_CAR_POSITION()
	self:tryClientTriggerAll(TriggerConst.TRIGGER_TARGET_ARRIVE_HOME_CAR_POSITION)
end

function ClientTriggerComponent:checkTriggerMeetParmon()
	self:tryClientTriggerAll(TriggerConst.TRIGGER_TARGET_MEET_PET)
end

function ClientTriggerComponent:checkTriggerNearParmon()
	self:tryClientTriggerAll(TriggerConst.TRIGGER_TARGET_NEAR_PET)
end

function ClientTriggerComponent:checkTriggerAngleOfView()
	local curRotation = pg.game.camera:getCameraRotation()
	local lastCameraRotation = self.triggerDataCache.lastCameraRotation

	if lastCameraRotation[1] == -999999 then
		Quaternion.Copy(lastCameraRotation, curRotation)

		return
	end

	if lastCameraRotation == curRotation then
		return
	end

	local angle = Quaternion.Angle(curRotation, lastCameraRotation)

	Quaternion.Copy(lastCameraRotation, curRotation)
	self:tryClientTriggerAll(TriggerConst.TRIGGER_TARGET_ANGLE_OF_VIEW, nil, angle)
end

function ClientTriggerComponent:checkTriggerPlayerNpcDistanceWhenCallFriend()
	self:tryClientTriggerAll(TriggerConst.TRIGGER_TARGET_DISTANCE_PLAYER_NPC_CALLFRIEND)
end

function ClientTriggerComponent:checkTriggerPetHpPercentTime()
	self:tryClientTriggerAll(TriggerConst.TRIGGER_TARGET_PET_HP_PERCENT_TIME)
end

function ClientTriggerComponent:setFogShiningValue(shiningId, value)
	if not shiningId then
		return
	end

	self.fogShiningDict = self.fogShiningDict or {}

	if not value or value <= 0 then
		self.fogShiningDict[shiningId] = nil
	else
		self.fogShiningDict[shiningId] = value
	end

	self:refreshFogShingValue()
end

function ClientTriggerComponent:checkTriggerChestInDistance()
	self:tryClientTriggerAll(TriggerConst.TRIGGER_TARGET_CHEST_DISTANCE)
end

function ClientTriggerComponent:checkTriggerCatchPetLevelGap(targetLevel, targetBaseFormPet)
	self:tryClientTriggerAll(TriggerConst.TRIGGER_TARGET_CATCH_PET_LEVELGAP, nil, {
		targetLevel,
		targetBaseFormPet
	})
end

function ClientTriggerComponent:checkPetTeamSkillSkillType()
	self:tryClientTriggerAll(TriggerConst.TRIGGER_TARGET_PET_TEAM_SKILL_TYPE)
end

function ClientTriggerComponent:checkAttributeCompare()
	if not self.lockedActorId or self.lockedActorId == 0 then
		return
	end

	self:tryClientTriggerAll(TriggerConst.TRIGGER_TARGET_ATTRIBUTE_COMPARE)
end

function ClientTriggerComponent:checkTriggerSpPowerFull()
	if not self.spFullTs then
		return
	end

	self:tryClientTriggerAll(TriggerConst.TRIGGER_TARGET_SP_POWER_FULL)
end

function ClientTriggerComponent:refreshFogShingValue()
	local fogShingValue = 0

	for _, value in pairs(self.fogShiningDict) do
		if fogShingValue < value then
			fogShingValue = value
		end
	end

	self.fogShingValue = fogShingValue

	facade:sendLuaEvent("refreshFogShingValue", fogShingValue)
end

function ClientTriggerComponent:getFogShiningValue()
	return self.fogShingValue
end

function ClientTriggerComponent:on_triggerMap_customVariables_entry_added(k, v)
	self.eventEmitter:emit(EventConst.ON_MAIN_PLAYER_CUSTOM_VARIABLE_CHANGED, k, -1, v)
end

function ClientTriggerComponent:on_triggerMap_customVariables_entry_deleted(k, v)
	self.eventEmitter:emit(EventConst.ON_MAIN_PLAYER_CUSTOM_VARIABLE_CHANGED, k, v, -1)
end

function ClientTriggerComponent:on_triggerMap_customVariables_item_changed(oldVal, newVal, k)
	self.eventEmitter:emit(EventConst.ON_MAIN_PLAYER_CUSTOM_VARIABLE_CHANGED, k, oldVal, newVal)
end

function ClientTriggerComponent:requestSetCustomVariable(key, val)
	self:serverMsg("RPC_CS_SetCustomVariable", key, val)
end

function ClientTriggerComponent:_initNpcBehavStatusCache()
	local cache = {}

	for staticId, varTable in pairs(pg.me.triggerMap.npcBehaviorStatus) do
		local tab = {}

		table.merge(tab, varTable)

		cache[staticId] = tab
	end

	return cache
end

function ClientTriggerComponent:on_triggerMap_npcBehaviorStatus_item_changed(oldVal, newVal, staticId)
	local cacheVarTable = self.triggerDataCache.lastNpcBehavStatus[staticId]

	if cacheVarTable == nil then
		self.triggerDataCache.lastNpcBehavStatus[staticId] = {}
		cacheVarTable = self.triggerDataCache.lastNpcBehavStatus[staticId]
	end

	local realVarTable = pg.me.triggerMap.npcBehaviorStatus[staticId]

	for key, realVar in pairs(realVarTable) do
		local cacheVar = cacheVarTable[key] or -1

		if realVar ~= cacheVar then
			cacheVarTable[key] = realVar

			local ent = pg.me.space:getEntityByStaticId(staticId)

			if ent then
				local context = CTRPool.getContext()

				context.tKey = key
				context.tOldValue = cacheVar
				context.tNewValue = realVar
				context.tIsInit = false

				AIControllerUtils.sendAIEvent(ent, "NpcStatusChangeTrigger", context)
			end
		end
	end
end

function ClientTriggerComponent:requestSetNpcBehaviorStatus(staticId, key, val, forceRefresh)
	self:serverMsg("RPC_CS_SetNpcBehaviorStatus", staticId or 0, key or 0, val or 0, forceRefresh or false)
end

function ClientTriggerComponent:setClientCustomVariable(triggerId, value)
	local curValue = self:getClientCustomVariable(triggerId)

	if value ~= curValue then
		self.clientCustomVariables[triggerId] = value
	end
end

function ClientTriggerComponent:getClientCustomVariable(triggerId)
	local cvdd = CustomVariableData[triggerId]

	if not cvdd then
		return false
	end

	if self.clientCustomVariables[triggerId] ~= nil then
		return self.clientCustomVariables[triggerId]
	end

	return cvdd.initalValue or 0
end

return ClientTriggerComponent
