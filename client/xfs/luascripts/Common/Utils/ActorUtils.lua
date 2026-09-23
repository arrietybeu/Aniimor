-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Utils\\ActorUtils.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local AbilityConst = require("Common.Const.AbilityConst")
local EnumAbilityType = AbilityConst.EnumAbilityType
local Const = require("Common.Const.Const")
local CoreConst = require("Core.Common.Const")
local Class = require("Core.Framework.Class")
local petData = require("Data.pet_data")
local puppetData = require("Data.puppet_data")
local PetSkillData = require("Data.pet_skill_data")
local PetSkillLearnData = require("Data.pet_skill_learn_map")
local RpcMethod = require("Core.Common.RpcMethod")
local Utils = require("Common.Utils.Utils")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local lume = require("Core.Common.lume")
local pairs = pairs
local ActorUtils = {
	ActorSkillTemplates = {}
}

function ActorUtils.onForceResetPosition(actorId)
	local ent = pg.getEntityByActorId(actorId)

	if ent and ent.space and ent.resetPositionByNearPortal then
		ent:resetPositionByNearPortal()
	end
end

function ActorUtils.onTeleportPos(actorId, posX, posY, posZ)
	local ent = pg.getEntityByActorId(actorId)

	if ent then
		ent:onTeleport(Vector3(posX, posY, posZ))
	end
end

function ActorUtils.onMoveTile(actorId, tileX, tileZ)
	local ent = pg.getEntityByActorId(actorId)

	if ent then
		ent:onMoveTile(tileX, tileZ)
	end
end

function ActorUtils.onMarkerMoveTile(actorId, tileX, tileZ)
	local ent = pg.getEntityByActorId(actorId)

	if ent then
		ent:onMarkerMoveTile(tileX, tileZ)
	end
end

function ActorUtils.forceSyncRemotePlayer(actorId, protocolId, message)
	local ent = pg.getEntityByActorId(actorId)

	if ent then
		ent:forceSyncRemotePlayer(protocolId, message)
	end
end

local function enableAoiLevel()
	return pg.component == "game" and require("ServerSwitch").EnablePlayerAoiLevel
end

function ActorUtils.onEnterAOI(actorId, tgtId)
	local ent = pg.getEntityByActorId(actorId)

	if ent then
		if enableAoiLevel() and ent.actorType == Const.ACTOR_TYPE_PLAYER then
			ent:onEnterAOIWithLevel(tgtId, 0)

			return
		end

		ent:onEnterAOI(tgtId)
	end
end

function ActorUtils.onMultiEnterAOI(actorIdList, tgtId)
	for _, actorId in pairs(actorIdList) do
		local ent = pg.getEntityByActorId(actorId)

		if ent then
			ent:onEnterAOI(tgtId)
		end
	end
end

function ActorUtils.onLeaveAOI(actorId, tgtId)
	local ent = pg.getEntityByActorId(actorId)

	if ent then
		if enableAoiLevel() and ent.actorType == Const.ACTOR_TYPE_PLAYER then
			ent:onLeaveAOIWithLevel(tgtId, 0)

			return
		end

		ent:onLeaveAOI(tgtId)
	end
end

function ActorUtils.onMultiLeaveAOI(actorIdList, tgtId)
	for _, actorId in pairs(actorIdList) do
		local ent = pg.getEntityByActorId(actorId)

		if ent then
			ent:onLeaveAOI(tgtId)
		end
	end
end

function ActorUtils.onEnterTrap(actorId, tgtId, eventId)
	local ent = pg.getEntityByActorId(actorId)

	if ent then
		if enableAoiLevel() and ent.actorType == Const.ACTOR_TYPE_PLAYER and Const.TRAP_EVENT_TO_AOI_LEVEL[eventId] then
			ent:onEnterAOIWithLevel(tgtId, eventId)

			return
		end

		if ent.onEnterTrap then
			ent:onEnterTrap(tgtId, eventId)
		end

		ent:postComponentMethod("onEnterTrap", tgtId, eventId)
	end
end

function ActorUtils.onLeaveTrap(actorId, tgtId, eventId)
	local ent = pg.getEntityByActorId(actorId)

	if ent then
		if enableAoiLevel() and ent.actorType == Const.ACTOR_TYPE_PLAYER and Const.TRAP_EVENT_TO_AOI_LEVEL[eventId] then
			ent:onLeaveAOIWithLevel(tgtId, eventId)

			return
		end

		if ent.onLeaveTrap then
			ent:onLeaveTrap(tgtId, eventId)
		end

		ent:postComponentMethod("onLeaveTrap", tgtId, eventId)
	end
end

function ActorUtils.onCheckValidPos(actorId, platformId, posX, posY, posZ, oldPosX, oldPosY, oldPosZ)
	local ent = pg.getEntityByActorId(actorId)

	if ent and ent.onCheckValidPos then
		return ent:onCheckValidPos(platformId, posX, posY, posZ, oldPosX, oldPosY, oldPosZ)
	end

	return true
end

function ActorUtils.onSyncGhostPos(actorId, posX, posY, posZ)
	local ent = pg.getEntityByActorId(actorId)

	if ent then
		ent:onSyncGhostPos(posX, posY, posZ)
	end

	return true
end

function ActorUtils.onSyncGhostRot(actorId, rotX, rotY, rotZ, rotW)
	local ent = pg.getEntityByActorId(actorId)

	if ent then
		ent:onSyncGhostRot(rotX, rotY, rotZ, rotW)
	end

	return true
end

function ActorUtils.onSyncRegionMirrorSmoothMove(actorId, smoothMoveData)
	local ent = pg.getEntityByActorId(actorId)

	if ent then
		if ent.master then
			if ent.master.onSyncPetGhostSmoothMove then
				ent.master:onSyncPetGhostSmoothMove(ent.id, smoothMoveData)
			end
		elseif ent.onSyncPlayerGhostSmoothMove then
			ent:onSyncPlayerGhostSmoothMove(smoothMoveData)
		end
	end

	return true
end

function ActorUtils.onSyncPos(actorId, posX, posY, posZ)
	local ent = pg.getEntityByActorId(actorId)

	if ent then
		ent:onSyncPos(posX, posY, posZ)
	end
end

function ActorUtils.onSyncRot(actorId, rotX, rotY, rotZ, rotW)
	local ent = pg.getEntityByActorId(actorId)

	if ent then
		ent:onSyncRot(rotX, rotY, rotZ, rotW)
	end
end

function ActorUtils.genAbility(templateId, label, randomCount, extraRareCount, player)
	local petPrototypeId = Utils.getPetPetPrototypeId(templateId)
	local basePetPrototypeId = Utils.getBasePetPrototypeId(petPrototypeId)
	local result = {}
	local unlockedSkills = {}
	local settingPreset = {}
	local isPetSkillUnlock = Utils.isPetSkillUnlock
	local template = PetSkillLearnData[basePetPrototypeId]

	if template == nil then
		return result, unlockedSkills
	end

	local skillAbilitys = {}
	local visited = {}

	for _, abilityInfo in pairs(template.initAbilitys or EMPTY_TABLE) do
		local abilityParamId, skillIndex = unpack(abilityInfo)
		local abilityType = AbilityUtils.getAbilityParamSkillType(abilityParamId)

		if not visited[abilityParamId] then
			if abilityType == Const.SkillType.Normal and result[AbilityConst.WEAPON_NORMAL_ATK_ABILITY] == nil then
				result[AbilityConst.WEAPON_NORMAL_ATK_ABILITY] = abilityParamId
			elseif abilityType == Const.SkillType.Ultimate and result[AbilityConst.ULTIMATE_ABILITY] == nil then
				result[AbilityConst.ULTIMATE_ABILITY] = abilityParamId
			elseif abilityType == Const.SkillType.Chain and result[AbilityConst.CHAIN_ABILITY] == nil then
				result[AbilityConst.CHAIN_ABILITY] = abilityParamId
			elseif abilityType == Const.SkillType.Skill and isPetSkillUnlock(player, petPrototypeId, abilityParamId) then
				skillAbilitys[#skillAbilitys + 1] = abilityParamId

				if skillIndex == AbilityConst.WEAPON_SKILL_ABILITY or skillIndex == AbilityConst.WEAPON_SKILL_ABILITY2 then
					settingPreset[skillIndex] = abilityParamId
				end
			end
		end

		visited[abilityParamId] = true
	end

	local extraRareAbilitys = {}

	for abilityParamId, weight in pairs(template.extraRareAbilitys) do
		if isPetSkillUnlock(player, petPrototypeId, abilityParamId) then
			extraRareAbilitys[abilityParamId] = weight
		end
	end

	local randomAbilitys = {}
	local isShiny = Utils.isLabelShiny(label)
	local isElite = Utils.isLabelElite(label)

	for abilityParamId, weightAndRate in pairs(template.randomAbilitys) do
		if isPetSkillUnlock(player, petPrototypeId, abilityParamId) then
			local rate = 1
			local rateTable = weightAndRate[2] or {}

			if isShiny then
				rate = rateTable[Const.PET_LABEL_MASK.SHINY] or 1
			elseif isElite then
				rate = rateTable[Const.PET_LABEL_MASK.ELITE] or 1
			end

			randomAbilitys[abilityParamId] = weightAndRate[1] * rate
		end
	end

	local randomSkill

	randomCount = 2

	for i = 1, randomCount do
		if extraRareCount > 0 and lume.count(extraRareAbilitys) ~= 0 then
			extraRareCount = extraRareCount - 1
			randomSkill = lume.weightedchoice(extraRareAbilitys)

			if randomSkill then
				skillAbilitys[#skillAbilitys + 1] = randomSkill
				randomAbilitys[randomSkill] = nil
				extraRareAbilitys[randomSkill] = nil
			end
		elseif lume.count(randomAbilitys) ~= 0 then
			randomSkill = lume.weightedchoice(randomAbilitys)

			if randomSkill then
				skillAbilitys[#skillAbilitys + 1] = randomSkill
				randomAbilitys[randomSkill] = nil
			end
		end
	end

	local presetVisit = {}

	for index, abilityParamId in pairs(settingPreset) do
		presetVisit[abilityParamId] = true
		result[index] = abilityParamId
	end

	for _, abilityParamId in ipairs(skillAbilitys) do
		if isPetSkillUnlock(player, petPrototypeId, abilityParamId) then
			if result[AbilityConst.WEAPON_SKILL_ABILITY] == nil and not presetVisit[abilityParamId] then
				presetVisit[abilityParamId] = true
				result[AbilityConst.WEAPON_SKILL_ABILITY] = abilityParamId
			elseif result[AbilityConst.WEAPON_SKILL_ABILITY2] == nil and not presetVisit[abilityParamId] then
				presetVisit[abilityParamId] = true
				result[AbilityConst.WEAPON_SKILL_ABILITY2] = abilityParamId
			end

			unlockedSkills[#unlockedSkills + 1] = abilityParamId
		end
	end

	return result, unlockedSkills
end

function ActorUtils.genPvpAbility(templateId)
	local petPrototypeId = Utils.getPetPetPrototypeId(templateId)
	local basePetPrototypeId = Utils.getBasePetPrototypeId(petPrototypeId)
	local result = {}
	local unlockedSkills = {}
	local template = PetSkillLearnData[basePetPrototypeId]

	if template == nil then
		return result, unlockedSkills
	end

	local visited = {}

	for _, abilityInfo in pairs(template.initAbilitys or EMPTY_TABLE) do
		local abilityParamId, skillIndex = unpack(abilityInfo)
		local abilityType = AbilityUtils.getAbilityParamSkillType(abilityParamId)

		if not visited[abilityParamId] then
			if abilityType == Const.SkillType.Normal and result[AbilityConst.WEAPON_NORMAL_ATK_ABILITY] == nil then
				result[AbilityConst.WEAPON_NORMAL_ATK_ABILITY] = abilityParamId
			elseif abilityType == Const.SkillType.Ultimate and result[AbilityConst.ULTIMATE_ABILITY] == nil then
				result[AbilityConst.ULTIMATE_ABILITY] = abilityParamId
			elseif abilityType == Const.SkillType.Skill then
				unlockedSkills[#unlockedSkills + 1] = abilityParamId
			end
		end

		visited[abilityParamId] = true
	end

	for abilityParamId, index in pairs(template.pvpAbilitys or EMPTY_TABLE) do
		if index == 1 then
			result[AbilityConst.WEAPON_SKILL_ABILITY] = abilityParamId
		elseif index == 2 then
			result[AbilityConst.WEAPON_SKILL_ABILITY2] = abilityParamId
		end

		if not visited[abilityParamId] then
			unlockedSkills[#unlockedSkills + 1] = abilityParamId
		end

		visited[abilityParamId] = true
	end

	return result, unlockedSkills
end

return ActorUtils
