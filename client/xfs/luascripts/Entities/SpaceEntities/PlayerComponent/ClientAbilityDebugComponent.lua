-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientAbilityDebugComponent.lua

local Class = require("Core.Framework.Class")
local ClientAbilityUtils = require("Utils.ClientAbilityUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local AbilityDebugTool = require("Common.Ability.AbilityDebugTool")
local GlobalData = require("Core.Client.GlobalData")
local BehaviorPathMapData = require("Common.Data.BehaviacData.Meta.BehaviorPathMapData")
local PuppetData = require("Data.puppet_data")
local PetData = require("Data.pet_data")
local PetRobotData = require("Data.pet_robot_data")
local ClientAbilityDebugComponent = Class.Component("ClientAbilityDebugComponent")
local ToBool = ToBool
local pg = pg
local PET_AUTO_COMBAT_BB_KEY = "Param_ST_AutoCombat"
local PET_AUTO_COMBAT_DATA_KEY = "Param_ST_Pet_AutoCombat"
local PET_AUTO_COMBAT_BT_PREFIX = "PBT_BotPet_AutoCombat"

function ClientAbilityDebugComponent:_applyAbilityAutoTestPetAiBtName(petId, petAiBtName)
	if not petAiBtName or petAiBtName == "" then
		return true
	end

	local pet = pg.getEntity(petId)

	if pet and not pet.agent and pet.createAIAgent then
		pet:createAIAgent()
	end

	if not pet or not pet.agent then
		return false
	end

	pet.agent:setBlackBoardProperty(PET_AUTO_COMBAT_BB_KEY, petAiBtName)

	if pg.logInfo() then
		self.logger:info("setAbilityAutoTestEnv override pet auto combat btName=%s", petAiBtName)
	end

	return true
end

function ClientAbilityDebugComponent:_isValidAbilityAutoTestPetAiBtName(petAiBtName)
	return petAiBtName == nil or petAiBtName == "" or BehaviorPathMapData.PathMap[petAiBtName] ~= nil and string.sub(petAiBtName, 1, string.len(PET_AUTO_COMBAT_BT_PREFIX)) == PET_AUTO_COMBAT_BT_PREFIX
end

function ClientAbilityDebugComponent:_resolveAbilityAutoTestPetTemplateId(petTemplateId, petRobotId)
	if not petRobotId or petRobotId == 0 then
		if not petTemplateId or petTemplateId == 0 then
			return nil, nil, "invalid petTemplateId"
		end

		return petTemplateId, ""
	end

	local petRobotData = PetRobotData[petRobotId]

	if not petRobotData then
		return nil, nil, "petRobotId not found in pet_robot_data"
	end

	local resolvedPetTemplateId = petRobotData.petID
	local petAiBtName = petRobotData[PET_AUTO_COMBAT_DATA_KEY] or ""

	if not resolvedPetTemplateId or resolvedPetTemplateId == 0 then
		return nil, nil, "invalid petID in pet_robot_data"
	end

	if not self:_isValidAbilityAutoTestPetAiBtName(petAiBtName) then
		return nil, nil, "invalid petAiBtName in pet_robot_data"
	end

	return resolvedPetTemplateId, petAiBtName
end

function ClientAbilityDebugComponent:RPC_SC_SetAbilityAutoTestPetAiBtName(petId, petAiBtName)
	local success = self:_isValidAbilityAutoTestPetAiBtName(petAiBtName) and self:_applyAbilityAutoTestPetAiBtName(petId, petAiBtName)

	if not success then
		self.logger:error("RPC_SC_SetAbilityAutoTestPetAiBtName failed", petId, petAiBtName)
	end
end

function ClientAbilityDebugComponent:RPC_SC_DebugCombatDamage(debugCombatData)
	if self.debugCombatCallback then
		if AbilityUtils.isNormalAttack(debugCombatData.abilityId) then
			debugCombatData.abilityId = debugCombatData.abilityId - debugCombatData.abilityId % 10
		end

		debugCombatData.parmonName = LuaUIUtils.getPetNameWithIdOrTmpId(debugCombatData.templateId)

		if PuppetData[debugCombatData.templateId] then
			debugCombatData.parmonName = pg.getLocalizationText(PuppetData[debugCombatData.templateId].name)
		end

		debugCombatData.abilityName = pg.getLocalizationText(AbilityUtils.getAbilityName(debugCombatData.abilityId))

		if not ToBool(debugCombatData.abilityName) and ToBool(debugCombatData.buffTemplateId) then
			debugCombatData.abilityName = pg.getLocalizationText(ClientAbilityUtils.getBuffName(debugCombatData.buffTemplateId))
			debugCombatData.abilityId = debugCombatData.buffTemplateId
		end

		if debugCombatData.targetTemplateId then
			debugCombatData.petName = LuaUIUtils.getPetNameWithIdOrTmpId(debugCombatData.targetTemplateId)
		end

		self.debugCombatCallback(debugCombatData)
	end
end

function ClientAbilityDebugComponent:RPC_SC_DebugRecoverEp(debugCombatData)
	if self.debugCombatCallback then
		if AbilityUtils.isNormalAttack(debugCombatData.abilityId) then
			debugCombatData.abilityId = debugCombatData.abilityId - debugCombatData.abilityId % 10
		end

		if debugCombatData.abilityId == 0 then
			debugCombatData.parmonName = ""
		end

		if PetData[debugCombatData.templateId] then
			debugCombatData.parmonName = pg.getLocalizationText(PetData[debugCombatData.templateId].name)
		end

		debugCombatData.abilityName = pg.getLocalizationText(AbilityUtils.getAbilityName(debugCombatData.abilityId))

		if not ToBool(debugCombatData.abilityName) and ToBool(debugCombatData.buffTemplateId) then
			debugCombatData.abilityName = pg.getLocalizationText(ClientAbilityUtils.getBuffName(debugCombatData.buffTemplateId))
			debugCombatData.abilityId = debugCombatData.buffTemplateId
		end

		if debugCombatData.targetTemplateId then
			debugCombatData.petName = LuaUIUtils.getPetNameWithIdOrTmpId(debugCombatData.targetTemplateId)
		end

		self.debugCombatCallback(debugCombatData)
	end
end

function ClientAbilityDebugComponent:setDebugCombatDataCallback(callback)
	self.debugCombatCallback = callback
end

function ClientAbilityDebugComponent:setAbilityAutoTestEnv(args)
	local isPet, petTemplateId, petPropTemplateId, petBuffId, puppetTemplateId, puppetPropTemplateId, puppetBuffId, duration, petRobotId = unpack(args)
	local resolvedPetTemplateId, petAiBtName, errReason = self:_resolveAbilityAutoTestPetTemplateId(petTemplateId, petRobotId)

	if not resolvedPetTemplateId then
		self.logger:error("setAbilityAutoTestEnv resolve pet failed", errReason, petTemplateId, petRobotId)

		return false
	end

	if petTemplateId == 0 then
		petTemplateId = resolvedPetTemplateId
	end

	local result = false

	for petId, petInfo in pairs(pg.me.pets) do
		if petInfo.templateId == petTemplateId then
			result = true
		end
	end

	if not result then
		pg.me.logger:error("setAbilityAutoTestEnv petTemplateId not found", petTemplateId)

		return false
	end

	self.logger:debug("aaa setAbilityAutoTestEnv", isPet, petTemplateId, petRobotId, petBuffId, petPropTemplateId, puppetTemplateId, puppetPropTemplateId, puppetBuffId, duration, petAiBtName)
	self:doGmCmd2("killEntInRange", {
		30,
		0
	})
	self:doGmCmd2("gotoByPos", {
		0,
		0,
		0
	})
	self:doGmCmd2("setAbilityAutoTestEnv", {
		petTemplateId,
		petPropTemplateId,
		petBuffId,
		puppetTemplateId,
		puppetPropTemplateId,
		puppetBuffId,
		isPet and 1 or 0,
		isPet and 0 or 1,
		petAiBtName or ""
	})

	return true
end

function ClientAbilityDebugComponent:stopAbilityAutoTest()
	self:doGmCmd2("killEntInRange", {
		300,
		0
	})
end

function ClientAbilityDebugComponent:getUserName()
	return GlobalData.UserName
end

return ClientAbilityDebugComponent
