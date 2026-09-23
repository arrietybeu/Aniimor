-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\PetTriggerMap.lua

local class = require("Core.Framework.Class")
local Bitset = require("Common.Bitset")
local Const = require("Common.Const.Const")
local TriggerConst = require("Common.Const.TriggerConst")
local TriggerMap = require("CustomTypes.TriggerMap")
local CustomTriggerData = require("Data.custom_trigger_data")
local CustomTriggerMapData = require("Data.custom_trigger_map_data")
local CustomDefaultRegisterMap = require("Data.custom_default_register_map")
local getBit = Bitset.getBit
local setBit = Bitset.setBit
local clrBit = Bitset.clrBit
local ipairs = ipairs
local UNSUPPORTED_PET_TRIGGER_ID = 200
local PetTriggerMap = class.LiteClass("PetTriggerMap", TriggerMap)

function PetTriggerMap:isSupportedCustomTrigger(customDataId, ctdd)
	ctdd = ctdd or CustomTriggerData[customDataId]

	return customDataId ~= UNSUPPORTED_PET_TRIGGER_ID and ctdd ~= nil and TriggerConst.IS_PET_CONDTION[ctdd.conditionUse] == true and ctdd.timeStatisticsType == nil and (ctdd.triggerTimes == nil or ctdd.triggerTimes == 1)
end

function PetTriggerMap:isRegister(customDataId)
	local ctdd = CustomTriggerData[customDataId]

	if not self:isSupportedCustomTrigger(customDataId, ctdd) or not self:checkUseType(ctdd.conditionUse, ctdd.userId) or not CustomDefaultRegisterMap[customDataId] then
		return false
	end

	return not getBit(self.completeCustomSet, customDataId)
end

function PetTriggerMap:isRegisterFaster(customDataId)
	return self:isRegister(customDataId)
end

function PetTriggerMap:getRegisterConfig(customDataId)
	if self:isRegister(customDataId) then
		return CustomTriggerData[customDataId]
	end
end

function PetTriggerMap:isComplete(customDataId)
	if not self:isSupportedCustomTrigger(customDataId) then
		return false
	end

	return getBit(self.completeCustomSet, customDataId)
end

function PetTriggerMap:isCompleteOrMeetCondition(customDataId)
	local ctdd = CustomTriggerData[customDataId]

	if customDataId == UNSUPPORTED_PET_TRIGGER_ID or not ctdd then
		return false
	end

	if TriggerConst.IS_PET_CONDTION[ctdd.conditionUse] and not self:isSupportedCustomTrigger(customDataId, ctdd) then
		return false
	end

	return PetTriggerMap.super.isCompleteOrMeetCondition(self, customDataId)
end

function PetTriggerMap:getFinishCount(customDataId)
	return 0
end

function PetTriggerMap:checkNeedAnyCondition(trigger)
	if trigger == TriggerConst.TRIGGER_TARGET_CHECK_CUSTOM_VARIABLE then
		return false
	end

	local customRegisterIds = CustomTriggerMapData[trigger] and CustomTriggerMapData[trigger][TriggerConst.TRIGGER_ID_ANY] or {}

	for _, registerId in ipairs(customRegisterIds) do
		local customDataId = TriggerConst.parseCustomTriggerKey(registerId)

		if self:isRegister(customDataId) then
			return true
		end
	end

	return false
end

function PetTriggerMap:isRegisterTriggerType(triggerType, triggerId)
	local customRegisterIds = CustomTriggerMapData[triggerType] and CustomTriggerMapData[triggerType][triggerId] or {}

	for _, registerId in ipairs(customRegisterIds) do
		local customDataId = TriggerConst.parseCustomTriggerKey(registerId)

		if self:isRegister(customDataId) then
			return true
		end
	end

	if triggerId ~= TriggerConst.TRIGGER_ID_ANY then
		return self:isRegisterTriggerType(triggerType, TriggerConst.TRIGGER_ID_ANY)
	end

	return false
end

function PetTriggerMap:_doTrigger(trigger, triggerId, cnt, triggerParams)
	cnt = self:getCommonTriggerConditionValue(cnt, trigger, triggerId, nil, triggerParams) or 0

	local customRegisterIds = CustomTriggerMapData[trigger] and CustomTriggerMapData[trigger][triggerId] or {}

	for _, registerId in ipairs(customRegisterIds) do
		local customDataId, triggerPos = TriggerConst.parseCustomTriggerKey(registerId)

		if self:isRegister(customDataId) then
			self:_onCustomTrigger(customDataId, triggerPos, trigger, triggerId, cnt, triggerParams)
		end
	end
end

function PetTriggerMap:registerCustomTrigger(customDataId)
	if not self:isSupportedCustomTrigger(customDataId) then
		return
	end

	return PetTriggerMap.super.registerCustomTrigger(self, customDataId)
end

function PetTriggerMap:unregisterCustomTrigger(customDataId, keepCount)
	local ctdd = CustomTriggerData[customDataId]

	if not self:isSupportedCustomTrigger(customDataId, ctdd) or not self:checkUseType(ctdd.conditionUse, ctdd.userId) then
		return
	end

	for pos in ipairs(ctdd.condition) do
		local key = TriggerConst.genCustomTriggerKey(customDataId, pos)

		if not keepCount and self.customCondition[key] then
			self.customCondition[key] = nil
		end
	end
end

function PetTriggerMap:resetCustomDataByIds(ids)
	for _, customDataId in ipairs(ids) do
		if self:isSupportedCustomTrigger(customDataId) then
			clrBit(self.completeCustomSet, customDataId)
			self:unregisterCustomTrigger(customDataId)
		end
	end
end

function PetTriggerMap:completeCustomTrigger(customDataId, ctdd, count)
	ctdd = ctdd or CustomTriggerData[customDataId]

	if not self:isSupportedCustomTrigger(customDataId, ctdd) or not self:checkUseType(ctdd.conditionUse, ctdd.userId) then
		return
	end

	self:setCompletedCustomTrigger(customDataId)

	local eventContext = {
		source = Const.ESM_CUSTOM_CONDITION,
		userId = ctdd.userId,
		customId = customDataId
	}

	self:doCustomEvents(ctdd.comEvent, ctdd.event, ctdd.eventBranchs, eventContext)
	self:asyncOnTrigger(TriggerConst.TRIGGER_TARGET_CUSTOM_ACTION, customDataId, 1)
end

function PetTriggerMap:setCompletedCustomTrigger(customDataId, notSetBit)
	if not self:isSupportedCustomTrigger(customDataId) then
		return
	end

	if not notSetBit then
		setBit(self.completeCustomSet, customDataId)
	end

	self:unregisterCustomTrigger(customDataId)
end

function PetTriggerMap:getGmTriggerValue()
	return nil
end

return PetTriggerMap
