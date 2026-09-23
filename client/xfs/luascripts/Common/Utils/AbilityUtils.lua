-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Utils\\AbilityUtils.lua

local AttributeConst = require("Common.Const.AttributeConst")
local Utils = require("Common.Utils.Utils")
local Class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local AbilityParamData = require("Data.ability_param_data")
local PetSkillData = require("Data.pet_skill_data")
local AbilityConst = require("Common.Const.AbilityConst")
local ListPool = require("Common.Container.ListPool")
local AbilityParamMapData = require("Common.Data.SkillBPData.abilityId2ParamId_BP")
local AbilityMapping_BP = require("Common.Data.SkillBPData.abilityMapping_BP")
local SysConfigData = require("Data.sys_config_data")
local AbilitySettingGlobalConstData = require("Data.ability_setting_global_const_data")
local AutoHitParamMappingData = require("Data.auto_hit_param_mapping_data")
local lume = require("Core.Common.lume")
local InteractTagData = require("Data.interact_tag_data")
local BuffConfigData = require("Data.buff_config_data")
local RandomBuffData = require("Data.random_buff_data")
local PetProtoTypeData = require("Data.pet_prototype_data")
local AbilityInteractTagBP = require("Common.Data.SkillBPData.ability_interact_tag_BP")
local PetTransmogSoltData = require("Data.pet_transmog_solt_data")
local PetTransmogSuitPerviewData = require("Data.pet_transmog_suit_perview_data")
local pg = pg
local Vector3 = Vector3
local ToBool = ToBool
local DefaultNullTable = AbilityConst.DEFAULT_NULL_TABLE
local AbilityUtils = Class.LiteClass("AbilityUtils")

function AbilityUtils.isRareAbilityId(abilityId, templateId)
	if not templateId then
		return false
	end

	local abilityParamId = AbilityUtils.getAbilityParamId(abilityId)
	local petSkill = PetSkillData[Utils.getBasePetPrototypeId(templateId)] or {}
	local psdd = petSkill[abilityParamId]

	if not psdd then
		for _, origData in pairs(petSkill) do
			if origData.enhancedSkillId == abilityParamId then
				return ToBool(origData.rarity)
			end
		end

		return false
	end

	return ToBool(psdd.rarity)
end

function AbilityUtils.isRareAbilityByParamId(abilityParamId, templateId)
	if not templateId then
		return false
	end

	local petSkill = PetSkillData[Utils.getBasePetPrototypeId(templateId)] or {}
	local psdd = petSkill[abilityParamId]

	if not psdd then
		for _, origData in pairs(petSkill) do
			if origData.enhancedSkillId == abilityParamId then
				return ToBool(origData.rarity)
			end
		end

		return false
	end

	return ToBool(psdd.rarity)
end

function AbilityUtils.getCoreAbilityIdByPetInfo(petInfo)
	local unlockedAbilityMap = petInfo.unlockedAbilityMap

	if not unlockedAbilityMap then
		return
	end

	local coreAbilityId

	for paramId, abilityInfo in pairs(unlockedAbilityMap) do
		local abilityId = AbilityUtils.getAbilityIdByParamId(petInfo.templateId, paramId)

		if abilityId and abilityId ~= 0 and ToInt(AbilityUtils.isRareAbilityId(abilityId, petInfo.templateId)) == 1 then
			coreAbilityId = abilityId

			return coreAbilityId, abilityInfo
		end
	end

	return coreAbilityId, nil
end

function AbilityUtils.getAbilityIdByParamId(petTemplateId, abilityParamId)
	local petPrototypeId = Utils.getPetPetPrototypeId(petTemplateId)
	local basePetPrototypeId = Utils.getBasePetPrototypeId(petPrototypeId)
	local abilityMap = AbilityMapping_BP[abilityParamId]

	if abilityMap then
		return abilityMap[basePetPrototypeId] or 0
	end

	return 0
end

function AbilityUtils.getAbilityParamId(abilityId, buffId)
	local data = pg.global.abilityMgr:getAbilityTemplate(abilityId)
	local id = data and data.abilityParamId or 0

	if id ~= 0 and buffId then
		id = BuffConfigData[buffId].abilityParamId or 0
	end

	return id
end

function AbilityUtils.getAbilityParamSkillType(abilityParamId)
	local abilityParam = AbilityParamData[abilityParamId]

	return abilityParam and abilityParam.skillType
end

function AbilityUtils.getBpAbilityType(abilityId)
	local abilityTemplate = pg.global.abilityMgr:getAbilityTemplate(abilityId)

	return abilityTemplate and abilityTemplate.abilityType or AbilityConst.EnumAbilityType.Attack
end

function AbilityUtils.getAbilityElementType(abilityParamId)
	local abilityParam = AbilityParamData[abilityParamId]

	return abilityParam and abilityParam.elementType
end

function AbilityUtils:getNormalAttackAbilityId()
	if not pg.me then
		return nil
	end

	local isControllongPet = Utils.isPet(pg.pawn)

	if not isControllongPet then
		return pg.me:getSkillIdBySkillType(AbilityConst.PLAYER_ABILITY_TYPE.NORMAL)
	else
		return pg.pawn:getSkillIdByType(AbilityConst.WEAPON_NORMAL_ATK_ABILITY)
	end
end

function AbilityUtils.isGroupAttribute(attributeId)
	return attributeId >= AttributeConst.GROUP_BASE_XP_BIND_PLAYER_BEGIN and attributeId <= AttributeConst.GROUP_BASE_XP_BIND_PLAYER_END or attributeId >= AttributeConst.GROUP_BASE_SINGLE_BIND_PLAYER_BEGIN and attributeId <= AttributeConst.GROUP_BASE_SINGLE_BIND_PLAYER_END
end

function AbilityUtils.isTeamAttribute(attributeId)
	return attributeId >= AttributeConst.ep_max_cur and attributeId <= AttributeConst.ep_regen_p
end

function AbilityUtils.checkTargetSearchRange(abilityLevelTemplate, casterPos, targetPos, bodySize, bodyHeight, preferUseSearchRangeInParamData)
	if casterPos == nil or targetPos == nil or abilityLevelTemplate == nil then
		return false
	end

	local searchTargetRangeRadius = abilityLevelTemplate.searchTargetRangeRadius

	if preferUseSearchRangeInParamData then
		local paramData = AbilityParamData[abilityLevelTemplate.abilityParamId]

		if paramData and paramData.searchTargetRangeRadius then
			searchTargetRangeRadius = paramData.searchTargetRangeRadius
		end
	end

	searchTargetRangeRadius = searchTargetRangeRadius + 5

	local searchTargetRangeUp = abilityLevelTemplate.searchTargetRangeUp + 2
	local searchTargetRangeDown = abilityLevelTemplate.searchTargetRangeDown + 2
	local posDiffY = targetPos.y - casterPos.y

	if searchTargetRangeUp ~= nil and searchTargetRangeUp < posDiffY then
		return false
	end

	if searchTargetRangeDown ~= nil and bodyHeight + posDiffY < -searchTargetRangeDown then
		return false
	end

	if searchTargetRangeRadius ~= nil then
		local horDistance = Vector3.HoriSqrDistance(targetPos, casterPos)
		local distanceCheck = math.abs(searchTargetRangeRadius + bodySize)

		distanceCheck = distanceCheck * distanceCheck

		if distanceCheck < horDistance then
			return false
		end
	end

	return true
end

function AbilityUtils.getAbilityParamPower(abilityParam, entity)
	if entity and entity.forceAbilityPower then
		return entity.forceAbilityPower
	end

	if not abilityParam then
		return 1
	end

	if abilityParam.monPower ~= nil and entity and (entity.isMonsterAbilityMode or Utils.isPuppet(entity)) then
		return abilityParam.monPower
	end

	return abilityParam.power or 1
end

function AbilityUtils.getAbilityParamBpPower(abilityParam, entity)
	if abilityParam.monBpPower ~= nil and entity and not entity.isDummyClone and (entity.isMonsterAbilityMode or Utils.isPuppet(entity)) then
		return abilityParam.monBpPower
	end

	return abilityParam.bpPower
end

function AbilityUtils.getAbilityParamTpPower(abilityParam, entity)
	if abilityParam.monTpPower ~= nil and entity and (entity.isMonsterAbilityMode or Utils.isPuppet(entity)) then
		return abilityParam.monTpPower
	end

	return abilityParam.tpPower or 1
end

function AbilityUtils.getAbilityParamEpCost(abilityParam, entity)
	if abilityParam.monEpCost ~= nil and entity and (entity.isMonsterAbilityMode or Utils.isPuppet(entity)) then
		return abilityParam.monEpCost
	end

	return abilityParam.epCost or 0
end

function AbilityUtils.getAbilityParamSpCost(abilityParam, entity)
	return abilityParam.spCost or 0
end

function AbilityUtils.getAbilityParamCd(abilityId, entity)
	local cd
	local abilityParam = pg.global.abilityMgr:getAbilityParamData(abilityId)

	if abilityParam.arkCd and entity:checkArkSceneState() then
		cd = abilityParam.arkCd
	elseif abilityParam.monCd ~= nil and entity and (entity.isMonsterAbilityMode or Utils.isPuppet(entity)) then
		cd = abilityParam.monCd
	else
		cd = abilityParam.cd or 0
	end

	local cdRatio = 1 - entity.actorCombatAttribute:getRawAttribValue(AttributeConst.common_skill_cd_dec_rate_v)

	if abilityParam.abilityEffectTags then
		if abilityParam.abilityEffectTags[AbilityConst.ABILITY_EFFECT_TAG_SHIELD] then
			cdRatio = cdRatio - entity.actorCombatAttribute:getRawAttribValue(AttributeConst.shield_skill_cd_dec_rate_v)
		elseif abilityParam.abilityEffectTags[AbilityConst.ABILITY_EFFECT_TAG_HEAL] then
			cdRatio = cdRatio - entity.actorCombatAttribute:getRawAttribValue(AttributeConst.heal_skill_cd_dec_rate_v)
		end
	end

	cd = math.max(0, cd * cdRatio)

	if cd == 0 and ToBool(entity.forceSetCDMap[abilityId]) then
		local ability = entity.abilityMap[abilityId]

		if ability.cdEndTime > entity:getGameTime() then
			cd = entity.forceSetCDMap[abilityId]
		end
	end

	return cd
end

function AbilityUtils.hasAbilityTag(abilityId, checkTag)
	local abilityParamData = pg.global.abilityMgr:getAbilityParamData(abilityId)
	local tags = abilityParamData and abilityParamData.tags

	for _, tag in ipairs(tags) do
		if tag == checkTag then
			return true
		end
	end

	return false
end

function AbilityUtils.checkBuffHasTag(buffId, checkTag)
	local buffCfg = BuffConfigData[buffId]
	local cfgTags = buffCfg and buffCfg.buffTag

	if cfgTags then
		for _, tagStr in ipairs(cfgTags) do
			local tagId = AbilityConst.BUFF_TAG_STR_2_INT[tagStr]

			if tagId == checkTag then
				return true
			end
		end
	else
		local buffLevelTemplate = pg.global.abilityMgr:getBuffTemplate(buffId)
		local tagIds = buffLevelTemplate.tags

		if ToBool(tagIds) then
			for _, tagId in ipairs(tagIds) do
				if tagId == checkTag then
					return true
				end
			end
		end
	end

	return false
end

function AbilityUtils.isChargeAbility(abilityId)
	local abilityTemplate = pg.global.abilityMgr:getAbilityTemplate(abilityId)

	return abilityTemplate and abilityTemplate.isCharge
end

function AbilityUtils.isAimAbility(abilityId)
	local abilityTemplate = pg.global.abilityMgr:getAbilityTemplate(abilityId)

	return abilityTemplate and abilityTemplate.isAim
end

function AbilityUtils.isGhostEyeAbility(abilityId)
	local abilityTemplate = pg.global.abilityMgr:getAbilityTemplate(abilityId)

	return abilityTemplate and abilityTemplate.isGhostEye
end

function AbilityUtils.isUltimateAbility(abilityId)
	local template = pg.global.abilityMgr:getAbilityTemplate(abilityId)

	return template and template.abilityType == AbilityConst.EnumAbilityType.Ultimate
end

function AbilityUtils.isNormalSkill(abilityId)
	local template = pg.global.abilityMgr:getAbilityTemplate(abilityId)

	return template and template.abilityType == AbilityConst.EnumAbilityType.Skill
end

function AbilityUtils.shouldRumble(abilityId)
	local template = pg.global.abilityMgr:getAbilityTemplate(abilityId)

	for _, abilityType in ipairs(SysConfigData.RUMBLE_ATTACK_TYPE) do
		if abilityType == template.abilityType then
			return true
		end
	end

	return false
end

function AbilityUtils.getAbilityName(abilityId)
	local abilityTemplate = pg.global.abilityMgr:getAbilityTemplate(abilityId)

	if abilityTemplate then
		local abilityParam = AbilityParamData[abilityTemplate.abilityParamId]

		return abilityParam and abilityParam.name
	end

	return nil
end

function AbilityUtils.getImpulseTypeByForce(forceLen)
	local index = 1

	while forceLen > AbilitySettingGlobalConstData.forceLevelRange[index] do
		if AbilitySettingGlobalConstData.forceLevelRange[index + 1] then
			index = index + 1
		else
			break
		end
	end

	return index - 1
end

function AbilityUtils.isNormalAttack(abilityId)
	local abilityTemplate = pg.global.abilityMgr:getAbilityTemplate(abilityId)

	return abilityTemplate and abilityTemplate.abilityType == AbilityConst.EnumAbilityType.Attack
end

function AbilityUtils.getAttackDataImpulseId(attackData, isInAir)
	if attackData.hitParamMapSkillId then
		local mappingData = AutoHitParamMappingData[attackData.hitParamMapSkillId]

		return isInAir and mappingData.airImpulseId or mappingData.impulseId
	end

	if isInAir and ToBool(attackData.airImpulseId) then
		return attackData.airImpulseId
	end

	return attackData.impulseId
end

function AbilityUtils.getAttackDataHitFrameFreezeId(attackData)
	if attackData.hitParamMapSkillId then
		return AutoHitParamMappingData[attackData.hitParamMapSkillId].hitFrameFreezeId
	end

	return attackData.hitFrameFreezeId
end

function AbilityUtils.getAttackDataHitCameraShakeId(attackData)
	if attackData.hitParamMapSkillId then
		local hitParamMappingData = AutoHitParamMappingData[attackData.hitParamMapSkillId]

		return hitParamMappingData.hitCameraShakeId
	end

	return attackData.hitCameraShakeId
end

function AbilityUtils.getFollowingPhantomVisible(masterActorId, actionData)
	if actionData.ignoreCombat then
		return true
	end

	local masterEntity = pg.getEntityByActorId(masterActorId)

	if masterEntity then
		if not masterEntity:isInCombat() then
			return false
		end

		local curCombatPet = masterEntity:getCurPetEntity()

		if not curCombatPet then
			return false
		end

		local templateList = actionData.templateList

		for _, templateId in ipairs(templateList) do
			if templateId == curCombatPet.templateId then
				return false
			end
		end

		return true
	end

	return false
end

function AbilityUtils.getPlayer(ent)
	return Utils.getMasterPlayer(ent)
end

function AbilityUtils.getPet(ent)
	if not ent then
		return nil
	end

	if Utils.isPlayer(ent) then
		return ent:getCurPetEntity()
	end

	if Utils.isPet(ent) then
		return ent
	end

	if Utils.isPuppet(ent) or Utils.isCreation(ent) then
		return AbilityUtils.getPet(ent:getMasterEntity())
	end
end

function AbilityUtils.getPuppet(ent)
	if not ent then
		return nil
	end

	if Utils.isCreation(ent) then
		return AbilityUtils.getPuppet(ent:getMasterEntity())
	end

	local masterEntity = ent.getMasterEntity and ent:getMasterEntity()

	if masterEntity then
		return AbilityUtils.getPuppet(masterEntity)
	end

	if Utils.isPuppet(ent) then
		return ent
	end

	return nil
end

function AbilityUtils.isServerPuppetCreation(ent)
	if not ent then
		return false
	end

	if not Utils.isCreation(ent) then
		return false
	end

	local master = ent.getMasterEntity and ent:getMasterEntity() or nil

	if master and Utils.isServerPuppet(master) then
		return true
	end

	return false
end

function AbilityUtils.isExploreAbility(ent, abilityId)
	if ent.isEquipExploreAbility and ent:isEquipExploreAbility(abilityId) then
		return true
	end

	if ent.petInfo and (ent.petInfo.curAbilityMap[AbilityConst.EXPLORE_ABILITY] == abilityId or ent.petInfo.curAbilityMap[AbilityConst.EXPLORE_ABILITY2] == abilityId) then
		return true
	end

	return false
end

function AbilityUtils.findInteractAbility(entity, interactTag)
	if not interactTag or not entity then
		return 0
	end

	local abilityMgr = pg.global.abilityMgr
	local maxPow = -9999
	local interactAbilityId = 0
	local interactInfo = InteractTagData[interactTag]

	for abilityId, ability in pairs(entity.abilityMap) do
		if not ability.isSubAbility and not AbilityUtils.isUltimateAbility(abilityId) and AbilityUtils.checkAbilityNotInCd(abilityId, entity) then
			local abilityParamData = abilityMgr:getAbilityParamData(abilityId)
			local power = AbilityUtils.getAbilityParamPower(abilityParamData, entity)
			local interactTagList = AbilityInteractTagBP[abilityId]

			if interactTagList and lume.checkIntersectionList(interactTagList, interactInfo.abilityInteract) and maxPow < power then
				maxPow = power
				interactAbilityId = abilityId
			end
		end
	end

	return interactAbilityId
end

function AbilityUtils.searchClosestEntity(ownerEntity, radius, relation, heightDown, heightUp, filterCondition, checkValidLock, combatContext, checkValidPlayer)
	heightDown = heightDown or radius
	heightUp = heightUp or radius

	local searchUsrType = checkValidPlayer and Const.SEARCH_USR_TYPE_SENSOR or Const.SEARCH_USR_TYPE_ACTOR_CREATION
	local actorIds = ListPool.getList(3)
	local searchCnt = 0

	if ownerEntity.isSummon == false then
		local masterEntity = ownerEntity:getMasterEntity()

		if masterEntity then
			searchCnt = masterEntity:entitiesInRangeWithTable(radius + 3, searchUsrType, 30, actorIds, true)
		end
	else
		searchCnt = ownerEntity:entitiesInRangeWithTable(radius + 3, searchUsrType, 30, actorIds, true)
	end

	local pos = ownerEntity:getPosition()
	local abilityMgr = pg.global.abilityMgr
	local resultEnt

	for i = 1, searchCnt do
		local ent = pg.getEntityByActorId(actorIds[i])

		if ent then
			local entPos = ent:getPosition()
			local horiSqrDis = Vector3.HoriSqrDistance(pos, entPos)

			if Utils.checkRelation(ownerEntity, ent, relation) and horiSqrDis <= radius * radius and entPos.y - heightDown < pos.y and pos.y < entPos.y + heightUp then
				local isValidTarget = true

				if checkValidPlayer then
					isValidTarget = Utils.checkValidPlayer(ent)
				else
					isValidTarget = checkValidLock == false or Utils.checkValidLock(ent, true)
				end

				if isValidTarget then
					if filterCondition then
						local runtimeTargetInfo = abilityMgr.runtimeTargetInfoPool:getWithCtor(true, actorIds[i])
						local guardValue = abilityMgr.guardValuePool:getWithCtor(true, combatContext, "runtimeTargetInfo", runtimeTargetInfo)

						if ownerEntity.combatAction:doActionById(filterCondition, combatContext) then
							resultEnt = ent
						end

						abilityMgr.guardValuePool:returnObject(guardValue)
						abilityMgr.runtimeTargetInfoPool:returnObject(runtimeTargetInfo)
					else
						resultEnt = ent
					end
				end
			end
		end

		if resultEnt then
			break
		end
	end

	ListPool.returnList(actorIds, 3)

	return resultEnt
end

function AbilityUtils.searchRandomEntity(ownerEntity, radius, relation, heightDown, heightUp, filterCondition, checkValidLock, combatContext, checkValidPlayer)
	heightDown = heightDown or radius
	heightUp = heightUp or radius

	local searchUsrType = checkValidPlayer and Const.SEARCH_USR_TYPE_SENSOR or Const.SEARCH_USR_TYPE_ACTOR_CREATION
	local actorIds = ListPool.getList(3)
	local randomList = ListPool.getList(3)
	local searchCnt = 0

	if ownerEntity.isSummon == false then
		local masterEntity = ownerEntity:getMasterEntity()

		if masterEntity then
			searchCnt = masterEntity:entitiesInRangeWithCache(radius + 3, searchUsrType, actorIds)
		end
	else
		searchCnt = ownerEntity:entitiesInRangeWithCache(radius + 3, searchUsrType, actorIds)
	end

	local pos = ownerEntity:getPosition()
	local abilityMgr = pg.global.abilityMgr
	local resultEnt

	for i = 1, searchCnt do
		local ent = pg.getEntityByActorId(actorIds[i])

		if ent then
			local entPos = ent:getPosition()
			local horiSqrDis = Vector3.HoriSqrDistance(pos, entPos)

			if Utils.checkRelation(ownerEntity, ent, relation) and horiSqrDis <= radius * radius and entPos.y - heightDown < pos.y and pos.y < entPos.y + heightUp then
				local isValidTarget = true

				if checkValidPlayer then
					isValidTarget = Utils.checkValidPlayer(ent)
				else
					isValidTarget = Utils.checkValidTarget(ent, ownerEntity) and (checkValidLock == false or Utils.checkValidLock(ent, true))
				end

				if isValidTarget then
					if filterCondition then
						local runtimeTargetInfo = abilityMgr.runtimeTargetInfoPool:getWithCtor(true, actorIds[i])
						local guardValue = abilityMgr.guardValuePool:getWithCtor(true, combatContext, "runtimeTargetInfo", runtimeTargetInfo)

						if ownerEntity.combatAction:doActionById(filterCondition, combatContext) then
							table.insert(randomList, actorIds[i])
						end

						abilityMgr.guardValuePool:returnObject(guardValue)
						abilityMgr.runtimeTargetInfoPool:returnObject(runtimeTargetInfo)
					else
						table.insert(randomList, actorIds[i])
					end
				end
			end
		end
	end

	if #randomList > 0 then
		resultEnt = pg.getEntityByActorId(lume.randomchoice(randomList))
	end

	ListPool.returnList(actorIds, 3)
	ListPool.returnList(randomList, 3)

	return resultEnt
end

function AbilityUtils.isRogueEquip(buffId)
	return RandomBuffData[buffId] and RandomBuffData[buffId].buffRarity >= 2
end

function AbilityUtils.getAbilityInfoByKeyStr(keyStr, ent)
	if not ent then
		return nil
	end

	if Utils.isPlayer(ent) then
		local key = AbilityConst.PLAYER_ABILITY_KEY_STR_TO_TYPE[keyStr]

		if not key then
			return nil
		end

		return ent.curAbilityMap[key]
	elseif Utils.isPet(ent) then
		local key = AbilityConst.PET_ABILITY_KEY_STR_TO_TYPE[keyStr]

		if not key then
			return nil
		end

		return ent.petInfo.curAbilityMap[key]
	end

	return nil
end

function AbilityUtils.getBuffMaxLayer(buffId)
	if not buffId then
		return 1
	end

	local configMaxLayer = BuffConfigData[buffId] and BuffConfigData[buffId].maxLayer

	return configMaxLayer or 1
end

function AbilityUtils.getHitEventName(combatContext, projectileInsId)
	local eventName = string.format("%s_i%d_e%s_t%d_p%s", table.concat(combatContext.nodeStack, ","), combatContext.iterNumber or -1, combatContext.timelineEventStr or "", combatContext.targetIndex or -1, projectileInsId or "")

	return eventName
end

function AbilityUtils.getRogueEpCost(abilityParamData, masterEntity)
	if masterEntity and Utils.isSpaceRogueDungeon(masterEntity.space and masterEntity.space.spaceType) and abilityParamData.rogueEp then
		return abilityParamData.rogueEp * (1 + masterEntity.actorCombatAttribute:getRawAttribValue(AttributeConst.rogue_ep_cost_ratio))
	end
end

function AbilityUtils.getRogueEp(masterEntity)
	if masterEntity and Utils.isSpaceRogueDungeon(masterEntity.space and masterEntity.space.spaceType) then
		return masterEntity.rogueCombatData[AbilityConst.ROGUE_BATTLE_DATA_KEY.SKILL_EP] or 0
	end

	return 0
end

function AbilityUtils.isVector3(data)
	return Utils.isTable(data) and #data >= 3 and data.w == nil and (data.x ~= nil or type(data[1]) == "number")
end

function AbilityUtils.getAbilityMap(ent, excludeUltimate)
	if Utils.isPet(ent) then
		return ent:getCarrySkillMap(excludeUltimate) or DefaultNullTable
	else
		return ent.abilityMap or DefaultNullTable
	end
end

function AbilityUtils.checkAbilityNotInCd(abilityId, ent)
	local skill = ent:getAbility(abilityId)

	if skill then
		return not skill:isInCd()
	end

	return false
end

function AbilityUtils.checkCanUseSkillByCost(skillId, ent, isAI)
	if skillId == 0 then
		return false
	end

	if Utils.isPuppet(ent) then
		return true
	end

	local abilityType = pg.global.abilityMgr:getAbilityTemplate(skillId).abilityType

	if abilityType == AbilityConst.EnumAbilityType.Skill then
		local myEp = ent.actorCombatAttribute:getEp()
		local abilityParamData = pg.global.abilityMgr:getAbilityParamData(skillId)
		local skillCostEp = isAI and abilityParamData.aiEpCostCondition or abilityParamData.epCost

		return skillCostEp <= myEp
	elseif abilityType == AbilityConst.EnumAbilityType.Ultimate then
		local mySP = ent.actorCombatAttribute:getSp()

		return mySP >= pg.global.abilityMgr:getAbilityParamData(skillId).spCost
	else
		return true
	end
end

function AbilityUtils.checkAbilityInFeatures(skillId, featureId, useAIWeight)
	local abilityTemplate = pg.global.abilityMgr:getAbilityTemplate(skillId)

	if useAIWeight then
		local aiWeight = abilityTemplate.aiSelectWeight or 0

		if aiWeight < math.epsilon then
			return false
		end
	end

	local abilityParamData = pg.global.abilityMgr:getAbilityParamData(skillId).abilityFeatureList or DefaultNullTable

	for _, value in ipairs(abilityParamData) do
		if value == featureId then
			return true
		end
	end

	return false
end

function AbilityUtils.checkPetHasSupportTag(petEnt, supportTag)
	if petEnt and Utils.isPet(petEnt) then
		return petEnt:getConfigData().functionId == supportTag
	end

	return false
end

function AbilityUtils.getAbilityEp(abilityId, ent)
	local abilityParamData = pg.global.abilityMgr:getAbilityParamData(abilityId)

	return abilityParamData and AbilityUtils.getAbilityParamEpCost(abilityParamData, ent) or 0
end

function AbilityUtils.trySwitchSupportPet(playerEnt, petIdx)
	if not petIdx then
		return false
	end

	local isBotPlayer = Utils.isBotPlayer(playerEnt)
	local isNormalPlayer = Utils.isPlayer(playerEnt)

	if not playerEnt or not isBotPlayer and not isNormalPlayer then
		return false
	end

	if Utils.checkClient() then
		if isBotPlayer then
			playerEnt:serverMsg("RPC_CS_BotTrySwitchToSupportPet", petIdx)
		else
			local petEntId = playerEnt.petPrepareList[petIdx]
			local petEntity = petEntId and pg.getEntity(petEntId)

			if not petEntity then
				return false
			end

			playerEnt:switchToPetByIndex(petIdx, true, petEntity.coreAbilityId)
		end

		return true
	elseif isBotPlayer then
		return playerEnt:botTrySwitchToSupportPet(petIdx)
	else
		local petEntId = playerEnt.petPrepareList[petIdx]
		local petEntity = petEntId and pg.getEntity(petEntId)

		if petEntity then
			local coreAbilityId = petEntity.coreAbilityId
			local success, abilityId = playerEnt:checkUseAppearAbility(petIdx, petEntId, coreAbilityId)

			if success then
				local showRet = playerEnt:showPetById(petEntId, Const.EVENT_SHOW_PET)

				if showRet and ToBool(abilityId) then
					local lockedActorId = ToBool(playerEnt.lockedActorId) and playerEnt.lockedActorId or nil

					petEntity:serverCastAbility(abilityId, lockedActorId)

					return true
				end
			end
		end
	end

	return false
end

function AbilityUtils.trySwitchPet(playerEnt, petIdx)
	if not petIdx then
		return false
	end

	local isBotPlayer = Utils.isBotPlayer(playerEnt)
	local isNormalPlayer = Utils.isPlayer(playerEnt)

	if not playerEnt or not isBotPlayer and not isNormalPlayer then
		return false
	end

	if Utils.checkClient() then
		if isBotPlayer then
			playerEnt:serverMsg("RPC_CS_BotTrySwitchPet", petIdx)
		else
			playerEnt:switchToPetByIndex(petIdx, true)
		end

		return true
	elseif isBotPlayer then
		return playerEnt:botTrySwitchPet(playerEnt.petPrepareList[petIdx])
	else
		local petEntId = playerEnt.petPrepareList[petIdx]

		return playerEnt:showPetById(petEntId, Const.EVENT_SHOW_PET)
	end

	return false
end

function AbilityUtils.getHpPercent(ent)
	return ent.actorCombatAttribute:getHpRatio()
end

function AbilityUtils.checkEntityIsDead(entity)
	return entity.isDead and entity:isDead() or entity.FALLEN_ST and entity:FALLEN_ST()
end

function AbilityUtils.isUseWaterExploreAbility(entity, abilityId)
	if not Utils.isPet(entity) then
		return false
	end

	local petInfo = entity:getBattlePetInfo()

	if petInfo == nil then
		return false
	end

	local petProtoTypeData = PetProtoTypeData[petInfo.petPrototypeId or 0]

	if not petProtoTypeData then
		return false
	end

	local abilityParamData = pg.global.abilityMgr:getAbilityParamData(abilityId)

	if abilityParamData and abilityParamData.skillType == Const.SkillType.Explore and petProtoTypeData.maxWater and petProtoTypeData.maxWater > 0 then
		return true
	end

	return false
end

function AbilityUtils.isShowWaterStorage(entity)
	if not Utils.isPet(entity) then
		return false
	end

	local petInfo = entity:getBattlePetInfo()

	if petInfo == nil then
		return false
	end

	local petProtoTypeData = PetProtoTypeData[petInfo.petPrototypeId or 0]

	if not petProtoTypeData then
		return false
	end

	return petProtoTypeData and petProtoTypeData.maxWater and petProtoTypeData.maxWater > 0
end

function AbilityUtils.getAbilityParamWaterCost(entity, abilityId)
	if not AbilityUtils.isUseWaterExploreAbility(entity, abilityId) then
		return 0
	end

	local petInfo = entity:getBattlePetInfo()
	local petProtoTypeData = PetProtoTypeData[petInfo.petPrototypeId or 0]

	return petProtoTypeData.waterMinRuling or 0
end

function AbilityUtils.setAbilityInvalidTarget(entity, reason, invalid)
	if not entity or not reason then
		return
	end

	if not entity.invalidTargetMap then
		entity.invalidTargetMap = {}
	end

	if entity.invalidTargetMap[reason] ~= invalid then
		if invalid then
			entity.invalidTargetMap[reason] = true
			entity.isAbilityInvalidTarget = true
		else
			entity.invalidTargetMap[reason] = nil
			entity.isAbilityInvalidTarget = next(entity.invalidTargetMap) ~= nil
		end
	end
end

function AbilityUtils.setAbilityInvalidLock(entity, reason, invalid)
	if not entity or not reason then
		return
	end

	if not entity.invalidLockMap then
		entity.invalidLockMap = {}
	end

	if entity.invalidLockMap[reason] ~= invalid then
		if invalid then
			entity.invalidLockMap[reason] = true
			entity.isInValidLockTarget = true
		else
			entity.invalidLockMap[reason] = nil
			entity.isInValidLockTarget = next(entity.invalidLockMap) ~= nil
		end
	end
end

function AbilityUtils.getAbilityParamCdForUI(abilityId, entity)
	local cd

	if ToBool(entity.forceSetCDMap[abilityId]) then
		local ability = entity.abilityMap[abilityId]

		if ability.cdEndTime > entity:getGameTime() then
			cd = entity.forceSetCDMap[abilityId]

			return cd
		end
	end

	cd = AbilityUtils.getAbilityParamCd(abilityId, entity)

	return cd
end

function AbilityUtils.isPetTransmogSchemeFlashEffectEnabled(templateId, scheme)
	local holeIds = scheme and scheme.holeIds
	local flashSlotId = holeIds and holeIds[Const.PetTransmogSlotType.Flash]

	if not flashSlotId then
		return false
	end

	local cfg = PetTransmogSoltData[flashSlotId]

	return cfg ~= nil and cfg.type == Const.PetTransmogSlotType.Flash and cfg.effectSwitch == 1 and (not cfg.petId or tostring(cfg.petId) == tostring(templateId))
end

function AbilityUtils.getSuitId(ent, effective)
	local scheme = effective or ent and ent.selectTransmogScheme

	if scheme == nil and ent and ent.petInfo and ent.petInfo.getSelectTransmogScheme then
		scheme = ent.petInfo:getSelectTransmogScheme()
	end

	if scheme == nil then
		local pet = AbilityUtils.getPet(ent)

		if pet and ent.basePetPrototypeId and ent.basePetPrototypeId == pet.basePetPrototypeId then
			scheme = pet.selectTransmogScheme

			if scheme == nil and pet.petInfo and pet.petInfo.getSelectTransmogScheme then
				scheme = pet.petInfo:getSelectTransmogScheme()
			end
		end
	end

	if not scheme then
		return nil
	end

	local holeIds = scheme.holeIds

	if not holeIds then
		return nil
	end

	local configData = ent.getConfigData and ent:getConfigData() or nil
	local templateId = configData and configData.templateId or ent.templateId or ent.petInfo and ent.petInfo.templateId

	if not AbilityUtils.isPetTransmogSchemeFlashEffectEnabled(templateId, scheme) then
		return nil
	end

	local suitMap = templateId and PetTransmogSuitPerviewData[templateId]

	if not suitMap then
		return nil
	end

	for _, slotId in pairs(holeIds) do
		local cfg = PetTransmogSoltData[slotId]

		if cfg and cfg.suitId and suitMap[cfg.suitId] then
			return cfg.suitId
		end
	end

	return nil
end

function AbilityUtils.isAiPet(entity)
	if not entity then
		return false
	end

	return entity.isAIRunning and entity:isAIRunning() or Utils.isBotPet(entity)
end

function AbilityUtils.isRangePet(ent)
	return Utils.isPet(ent) and ent:getTemplateData().range == 1
end

function AbilityUtils.isAttackAbility(abilityId)
	return AbilityUtils.isNormalAttack(abilityId) or AbilityUtils.checkAbilityInFeatures(abilityId, 0, false)
end

function AbilityUtils.isBuffForbidSwitchPet(buffTemplate)
	local buffTags = buffTemplate and buffTemplate.tags

	if not buffTags then
		return false
	end

	for i = 1, #buffTags do
		local tag = buffTags[i]

		if AbilityConst.FORBID_SWITCH_PET_BUFF_TAGS[tag] then
			return true
		end
	end

	return false
end

return AbilityUtils
