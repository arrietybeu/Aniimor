-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Trigger\\ChatTriggerSystem.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local SystemBase = require("GameApp.Core.SystemBase")
local Class = require("Core.Framework.Class")
local Time = require("Core.Common.Time")
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local LoggerManager = require("Core.Log.LoggerManager")
local logger = LoggerManager.getLogger("ChatTriggerSystem")
local SafeCallback = require("Core.Framework.SafeCallback")
local petChatTriggerData = require("Data.pet_chat_condition_data")
local petChatConditionParamsData = require("Data.pet_chat_condition_params_data")
local petChatData = require("Data.pet_chat_data")
local ChatTriggerSystem = Class.LightClass("ChatTriggerSystem", SystemBase)

function ChatTriggerSystem:onCtor()
	self.petChatTriggerInfo = {}

	for _, v in pairs(petChatTriggerData) do
		self.petChatTriggerInfo[v.TriggerName] = v
	end
end

function ChatTriggerSystem:onTrigger(trigger, triggerTargetActorId, triggerParams)
	SafeCallback(self._innerOnTrigger, self, trigger, triggerTargetActorId, triggerParams)
end

function ChatTriggerSystem:_innerOnTrigger(trigger, triggerTargetActorId, triggerParams)
	local targetEntity = pg.getEntityByActorId(triggerTargetActorId)

	if Utils.isPet(targetEntity) then
		self:_innerOnPetTrigger(trigger, targetEntity, triggerParams)
	end
end

function ChatTriggerSystem:_innerOnPetTrigger(trigger, targetEntity, triggerParams)
	local currentTrigger = self.petChatTriggerInfo[trigger]
	local triggerRet = true

	if currentTrigger and currentTrigger.conditionList then
		for tIndex, tConditionId in ipairs(currentTrigger.conditionList or EMPTY_TABLE) do
			local tConditionRet = true

			if currentTrigger.ConditionType == 0 then
				triggerRet = triggerRet and tConditionRet

				if not triggerRet then
					break
				end
			else
				if tIndex == 0 then
					triggerRet = false
				end

				triggerRet = triggerRet or tConditionRet

				if triggerRet then
					break
				end
			end
		end
	end

	if triggerRet then
		local tCurrentChatBehaivorId = 0

		for _, tChatBehaviorId in ipairs(currentTrigger.Behavior) do
			local tChatData = petChatData[tChatBehaviorId]

			if tChatData and tChatData.templateId == targetEntity.templateId then
				tCurrentChatBehaivorId = tChatBehaviorId

				break
			end
		end

		if LoggerManager.checkLogger(LoggerConst.INFO) then
			logger:info("调用PetChat接口: ", tCurrentChatBehaivorId)
		end

		if tCurrentChatBehaivorId ~= 0 and not targetEntity:isBTPaused() then
			-- block empty
		end
	end
end

function ChatTriggerSystem:getPetChatTriggerInfo(triggerName)
	return self.petChatTriggerInfo[triggerName]
end

return ChatTriggerSystem
