-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientWaterStorageComponent.lua

local Class = require("Core.Framework.Class")
local Utils = require("Common.Utils.Utils")
local MessageName = require("Const.MessageName")
local Const = require("Common.Const.Const")
local AttributeConst = require("Common.Const.AttributeConst")
local ElementBuffData = require("Data.element_buff_data")
local PetData = require("Data.pet_data")
local PetProtoTypeData = require("Data.pet_prototype_data")
local AbilityParamData = require("Data.ability_param_data")
local EventConst = require("Const.EventConst")
local ClientWaterStorageComponent = Class.Component("ClientWaterStorageComponent")

function ClientWaterStorageComponent:ctor()
	self.element = 1
end

function ClientWaterStorageComponent:init(dict)
	if not self.isMainPet then
		return
	end

	self:buildConfigData()
end

function ClientWaterStorageComponent:start()
	if not self.isMainPet then
		return
	end

	self:buildConfigData()

	if not self.maxWater then
		return
	end

	self.actorCombatAttribute:setMaxWater(self.maxWater)
	self:recoveryExplore()
	self.actorCombatAttribute:registerAttributeNotify(AttributeConst.water_cur, self.onWaterCurChange)
	self:checkExploreTimer()
	self:computeExploreAddVal()
	self:bindExploreBuffChangeEvent()
end

function ClientWaterStorageComponent:bindExploreBuffChangeEvent()
	if self.exploreBuffChangeHandler ~= nil or self.eventEmitter == nil then
		return
	end

	function self.exploreBuffChangeHandler()
		self:computeExploreAddVal()
	end

	self.eventEmitter:addEventListener(EventConst.ON_BUFF_CHANGE, self.exploreBuffChangeHandler)
end

function ClientWaterStorageComponent:unbindExploreBuffChangeEvent()
	if self.exploreBuffChangeHandler == nil then
		return
	end

	if self.eventEmitter then
		self.eventEmitter:removeEventListener(EventConst.ON_BUFF_CHANGE, self.exploreBuffChangeHandler)
	end

	self.exploreBuffChangeHandler = nil
end

function ClientWaterStorageComponent:EVENT_onBindBuffChange(buffChangeData)
	if not self.isMainPet then
		return
	end

	if not self.maxWater then
		return
	end

	if buffChangeData == nil or buffChangeData.templateId == nil then
		return
	end

	local bindBuffCfg = ElementBuffData[self.element]
	local bindBuffId = bindBuffCfg and bindBuffCfg.buffId

	if self.isMainPet and bindBuffId == buffChangeData.templateId then
		self:computeExploreAddVal()
	end
end

function ClientWaterStorageComponent:buildConfigData()
	local petInfo = self:getBattlePetInfo()

	if petInfo == nil then
		return
	end

	local petProtoTypeData = PetProtoTypeData[petInfo.petPrototypeId or 0] or {}

	self.maxWater = petProtoTypeData.maxWater
	self.canUseVal = petProtoTypeData.waterMinRuling
	self.defaultAddVal = petProtoTypeData.selfRecover
	self.inBuffAddVal = petProtoTypeData.waterRecover
end

function ClientWaterStorageComponent:getWaterConfigData()
	if self.waterConfigData == nil then
		self.waterConfigData = {
			maxWater = self.maxWater,
			costVal = self.canUseVal,
			addVal = self.defaultAddVal,
			extraAddVal = self.inBuffAddVal
		}
	end

	return self.waterConfigData
end

function ClientWaterStorageComponent:getCurrentExploreBuffOwners()
	local mainPlayer = pg.me

	if mainPlayer then
		return {
			mainPlayer,
			self
		}
	end

	return {
		self
	}
end

function ClientWaterStorageComponent:computeExploreAddVal()
	local buffOwners = self:getCurrentExploreBuffOwners()
	local buffList = {}
	local bindBuffCfg = ElementBuffData[self.element]
	local bindBuffId = bindBuffCfg and bindBuffCfg.buffId
	local hasBindBuff = false

	for _, buffOwner in ipairs(buffOwners) do
		if buffOwner and buffOwner.actorBuff then
			local buff = buffOwner.actorBuff:findOneBuffByTemplateId(bindBuffId)

			if buff then
				hasBindBuff = true

				break
			end
		end
	end

	self.curAddVal = hasBindBuff and self.inBuffAddVal + self.defaultAddVal or self.defaultAddVal

	return buffList, buffOwners, hasBindBuff
end

function ClientWaterStorageComponent:onUpdateExplore()
	self.actorCombatAttribute:changeWater(self.curAddVal)

	self.curVal = self.actorCombatAttribute:getCurWater()
end

function ClientWaterStorageComponent:checkExploreTimer()
	if self:isFullExploreValue() then
		if self.exploreRecoveryTimer ~= nil then
			self:removeTimer(self.exploreRecoveryTimer)

			self.exploreRecoveryTimer = nil

			if self:checkMainControlPet() then
				facade:sendMsgToUI(MessageName.PET_EXPLORE_SKILL_VAL_STATE_CHANGED, 3)
			end
		end
	elseif self.exploreRecoveryTimer == nil then
		self.exploreRecoveryTimer = self:addRepeatTimer(1, function()
			self:onUpdateExplore()

			if self:checkMainControlPet() then
				facade:sendMsgToUI(MessageName.PET_EXPLORE_SKILL_VAL_STATE_CHANGED, 1)
			end
		end)
	end
end

function ClientWaterStorageComponent:isFullExploreValue()
	local curVal = self.actorCombatAttribute:getCurWater()
	local maxVal = self.actorCombatAttribute:getMaxWater()

	return maxVal <= curVal
end

function ClientWaterStorageComponent:onWaterCurChange(old, new)
	self.curVal = new

	self:checkExploreTimer()

	if self:checkMainControlPet() then
		facade:sendMsgToUI(MessageName.PET_EXPLORE_SKILL_VAL_CHANGED)
	end
end

function ClientWaterStorageComponent:checkCanCastExploreSkill()
	return self:getCurWaterVal() >= self.canUseVal
end

function ClientWaterStorageComponent:checkMainControlPet()
	if self.isMainPet and pg.pawn == self then
		return true
	end

	return false
end

function ClientWaterStorageComponent:getCurWaterVal()
	return self.actorCombatAttribute:getCurWater()
end

function ClientWaterStorageComponent:getCurWaterRecoveryVal()
	return self.curAddVal
end

function ClientWaterStorageComponent:costWater(value)
	if value > 0 then
		value = -value
	end

	if self.gmMode == Const.NO_COST_MODE then
		value = -1
	end

	self.actorCombatAttribute:changeWater(value)
end

function ClientWaterStorageComponent:recordExplore()
	if not pg.me:isInAnyFormation(self.id) then
		pg.me:setPetCurWater(self.id, 0)
	elseif self:isDead() then
		pg.me:setPetCurWater(self.id, nil)
	else
		local curVal = self:getCurWaterVal()

		pg.me:setPetCurWater(self.id, curVal)
	end
end

function ClientWaterStorageComponent:recoveryExplore()
	local maxVal = self.actorCombatAttribute:getMaxWater()
	local saveVal = pg.me:getPetCurWater(self.id, maxVal)

	self.actorCombatAttribute:setCurWater(saveVal)
	pg.me:setPetCurWater(self.id, nil)
end

function ClientWaterStorageComponent:destroy()
	if not self.isMainPet then
		return
	end

	if self.maxWater then
		self:recordExplore()
	end

	if self.exploreRecoveryTimer ~= nil then
		self:removeTimer(self.exploreRecoveryTimer)

		self.exploreRecoveryTimer = nil
	end

	if self.delayTimer ~= nil then
		self:removeTimer(self.delayTimer)

		self.delayTimer = nil
	end

	self:unbindExploreBuffChangeEvent()
end

return ClientWaterStorageComponent
