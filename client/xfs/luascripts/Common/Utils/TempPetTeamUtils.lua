-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Utils\\TempPetTeamUtils.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Const = require("Common.Const.Const")
local TempPetTeamConst = require("Common.Const.TempPetTeamConst")
local RoomConst = require("Common.Const.RoomConst")
local SysConfigData = require("Data.sys_config_data")
local PvpTemplatePetConfigData = require("Data.pvp_template_pet_config_data")
local PvpTemplatePetAllConfigData = require("Data.pvp_template_pet_all_config_data")
local PvpTemplatePetSkillConfigData = require("Data.pvp_template_pet_skill_config_data")
local PvpPropIdOverrideData = require("Data.pvp_propId_ovrride_data")
local PetRobotData = require("Data.pet_robot_data")
local PropertyData = require("Data.property_data")
local PetData = require("Data.pet_data")
local CoreCarryData = require("Data.core_carry_data")
local AbilityConst = require("Common.Const.AbilityConst")
local AttributeConst = require("Common.Const.AttributeConst")
local AttributeGroupData = require("Data.attribute_group_data")
local Utils = require("Common.Utils.Utils")
local PetSkillData = require("Data.pet_skill_data")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local TempPetTeamUtils = {}
local StrategyConfig = TempPetTeamConst.StrategyConfig
local DefaultConfig = TempPetTeamConst.DefaultConfig

function TempPetTeamUtils.pickPositive(cfg, defCfg, key)
	local v = cfg[key]

	if v ~= nil then
		if type(v) == "number" and v ~= -1 and v > 0 then
			return v
		end

		return nil
	end

	v = defCfg[key]

	if type(v) == "number" and v ~= -1 and v > 0 then
		return v
	end

	return nil
end

function TempPetTeamUtils.pickNonEmptyTable(cfg, defCfg, key)
	local v = cfg[key]

	if v ~= nil then
		if type(v) == "table" and next(v) ~= nil then
			return v
		end

		return nil
	end

	v = defCfg[key]

	if type(v) == "table" and next(v) ~= nil then
		return v
	end

	return nil
end

function TempPetTeamUtils.applyScalar(cfg, defCfg, key, target)
	local val = TempPetTeamUtils.pickPositive(cfg, defCfg, key)

	if val ~= nil then
		target[key] = val
	end
end

function TempPetTeamUtils._applyExtraSpeciesToTempPet(tempPet, extraSpecies)
	local basePropertyList = tempPet.basePropertyList

	if basePropertyList == nil or extraSpecies == nil then
		return
	end

	for index, baseProp in ipairs(basePropertyList) do
		local speciesPropName = Utils.getPropSpeciesAttrName(index)
		local extraValue = speciesPropName and extraSpecies[speciesPropName]

		if extraValue ~= nil then
			baseProp.speciesPoint = basePropertyList:getSpeciesPoint(index) + extraValue
		end
	end
end

function TempPetTeamUtils.getField(teamType, field)
	local cfg = StrategyConfig[teamType]

	if cfg and cfg[field] ~= nil then
		return cfg[field]
	end

	return DefaultConfig[field]
end

function TempPetTeamUtils.conditionFairPvp(player)
	if player:isPvpDungeon() and player.roomType == RoomConst.RoomTypePVP1V1_Fair then
		return player.fairPvpSelectPets
	end
end

function TempPetTeamUtils.conditionUnfairPvp(player)
	if player:isPvpDungeon() and player.roomType == RoomConst.RoomTypePVP1V1_UnFair then
		return player.unfairPvpSelectPets
	end
end

function TempPetTeamUtils.conditionBossChallenge(player)
	if player.isBossChallengeDungeon and player:isBossChallengeDungeon() then
		return {}
	end
end

function TempPetTeamUtils.conditionCatchRogue(player)
	if player:isInCatchRogueSpace() then
		return player.catchRogueInfo:getValidPetList(player), {
			forceLevel = player.catchRogueInfo:getForcePetLevel(player)
		}
	end
end

function TempPetTeamUtils.conditionRobEgg(player)
	if player.space and player.space.needChangePetLevel and player.space:needChangePetLevel() then
		return player:getCurPetFormation(), {
			groupAllId = 2,
			forceLevel = SysConfigData.GrabeEggMultiPullLevel or 60,
			groupId = TempPetTeamConst.PVP_ROBEGG_GROUPID
		}
	end
end

function TempPetTeamUtils.conditionBossRush(player)
	if player.space and player.space:isBossRush() and Utils.isBotPlayer(player) then
		return player:getCurPetFormation(), {
			groupAllId = 3,
			groupId = TempPetTeamConst.PVP_BOSSRUSH_GROUPID
		}
	end
end

function TempPetTeamUtils.conditionNpcDuel(player)
	if player.space and player.space:isNpcDuel() and Utils.isBotPlayer(player) then
		return player:getCurPetFormation(), {
			isDefaultLevel = true
		}
	end
end

TempPetTeamUtils.ConditionMap = {
	[Const.PET_TEAM_TYPE_TMP_FAIR_PVP] = TempPetTeamUtils.conditionFairPvp,
	[Const.PET_TEAM_TYPE_TMP_UNFAIR_PVP] = TempPetTeamUtils.conditionUnfairPvp,
	[Const.PET_TEAM_TYPE_TMP_BOSS_CHALLENGE] = TempPetTeamUtils.conditionBossChallenge,
	[Const.PET_TEAM_TYPE_TMP_CATCH_ROGUE] = TempPetTeamUtils.conditionCatchRogue,
	[Const.PET_TEAM_TYPE_TMP_ROBEGG] = TempPetTeamUtils.conditionRobEgg,
	[Const.PET_TEM_TYPE_TMP_BOT_BOSSRUSH] = TempPetTeamUtils.conditionBossRush,
	[Const.PET_TEM_TYPE_TMP_BOT_NPCDUEL] = TempPetTeamUtils.conditionNpcDuel
}
TempPetTeamUtils.ResolvePriority = {
	Const.PET_TEAM_TYPE_TMP_FAIR_PVP,
	Const.PET_TEAM_TYPE_TMP_UNFAIR_PVP,
	Const.PET_TEAM_TYPE_TMP_BOSS_CHALLENGE,
	Const.PET_TEAM_TYPE_TMP_CATCH_ROGUE,
	Const.PET_TEAM_TYPE_TMP_ROBEGG,
	Const.PET_TEM_TYPE_TMP_BOT_BOSSRUSH,
	Const.PET_TEM_TYPE_TMP_BOT_NPCDUEL
}

function TempPetTeamUtils.resolve(player)
	for _, teamType in ipairs(TempPetTeamUtils.ResolvePriority) do
		local fn = TempPetTeamUtils.ConditionMap[teamType]

		if fn ~= nil then
			local idList, extraParams = fn(player)

			if idList ~= nil then
				return teamType, idList, extraParams
			end
		end
	end

	return nil
end

function TempPetTeamUtils.buildDefault(player, idList, extraParams)
	local forceLevel = extraParams and extraParams.forceLevel

	for _, tmpId in ipairs(idList or EMPTY_TABLE) do
		local petId

		if type(tmpId) == "number" then
			petId = player:addTempPetById(tmpId)
		else
			petId = player:addTempPetByPetId(tmpId)
		end

		if petId ~= nil then
			player.tempFormation:insert(#player.tempFormation + 1, petId)

			if forceLevel and forceLevel > 0 then
				player.tempPets[petId]:tmpPetForceSetLevel(forceLevel)
			end
		end

		player.logger:debug("add temp pet, tempId=%s, petId=%s, forceLevel=%s", tostring(tmpId), petId, tostring(forceLevel), player:repr())
	end
end

function TempPetTeamUtils.buildFairPvp(player, idList, extraParams)
	for _, templateId in ipairs(idList or EMPTY_TABLE) do
		if templateId ~= 0 then
			local petId = player:addTempPetFairPvp(templateId)

			if petId ~= nil then
				player.tempFormation:insert(#player.tempFormation + 1, petId)
			else
				player.logger:error("add temp pet failed, templateId=%d", templateId, player:repr())
			end
		end
	end
end

function TempPetTeamUtils.buildUnfairPvp(player, idList, extraParams)
	for _, pvpPetId in ipairs(idList or EMPTY_TABLE) do
		if pvpPetId ~= "" and player.pets[pvpPetId] then
			local petId = player:addTempPetUnFairPvp(pvpPetId)

			if petId ~= nil then
				player.tempFormation:insert(#player.tempFormation + 1, petId)
			else
				player.logger:error("add temp pet failed, pvpPetId = %s", pvpPetId, player:repr())
			end
		end
	end
end

function TempPetTeamUtils.buildBossChallenge(player, idList, extraParams)
	local curFormation = player:getCurPetFormation()

	for _, petPrepareId in ipairs(curFormation) do
		local petId = player:addTempBossChallengePets(petPrepareId)

		if petId ~= nil then
			player.tempFormation:insert(#player.tempFormation + 1, petId)
		else
			player.logger:error("add temp pet failed, petId=%s", tostring(petPrepareId), player:repr())
		end
	end
end

function TempPetTeamUtils.applyPvpTemplateConfig(player, petId, tempPet, cfg, extraParams)
	cfg = cfg or {}

	local defaultGroup = PvpTemplatePetConfigData[TempPetTeamConst.PVP_DEFAULT_GROUPID] or {}
	local defCfg = tempPet and defaultGroup[tempPet.templateId] or {}
	local isDefaultLevel = extraParams and extraParams.isDefaultLevel

	if isDefaultLevel ~= true then
		local forceLevel = extraParams and extraParams.forceLevel

		if forceLevel and forceLevel > 0 then
			tempPet.level = forceLevel
		else
			TempPetTeamUtils.applyScalar(cfg, defCfg, "level", tempPet)
		end
	end

	TempPetTeamUtils.applyScalar(cfg, defCfg, "nature", tempPet)

	if tempPet.resonanceInfo then
		TempPetTeamUtils.applyScalar(cfg, defCfg, "resonanceStage", tempPet.resonanceInfo)
		TempPetTeamUtils.applyScalar(cfg, defCfg, "resonanceLevel", tempPet.resonanceInfo)
	end

	local pvpPropIdKey = TempPetTeamUtils.pickPositive(cfg, defCfg, "propid")

	pvpPropIdKey = extraParams and extraParams.propid or pvpPropIdKey

	local overrideTable = pvpPropIdKey and PvpPropIdOverrideData[pvpPropIdKey]
	local petData = overrideTable and PetData[tempPet.templateId]
	local finalPropId = petData and petData.functionId and overrideTable[petData.functionId]

	if finalPropId and tempPet.basePropertyList then
		local finalPropdd = PropertyData[finalPropId] or {}

		for i, baseProp in ipairs(tempPet.basePropertyList) do
			local propName = Utils.getPropSpeciesAttrName(i)

			if propName then
				baseProp.speciesPoint = (petData[propName] or 0) + (finalPropdd[propName] or 0)
			end
		end
	end

	local extraSpecies = TempPetTeamUtils.pickNonEmptyTable(cfg, defCfg, "extraSpecies")

	TempPetTeamUtils._applyExtraSpeciesToTempPet(tempPet, extraSpecies)

	local talentPointMap = TempPetTeamUtils.pickNonEmptyTable(cfg, defCfg, "talentPointMap")
	local anyTalentApplied = false

	if talentPointMap then
		for i, val in ipairs(talentPointMap) do
			local baseProp = tempPet.basePropertyList[i]

			if baseProp and val and val ~= -1 then
				baseProp:modifyLevelByLearn(val)

				anyTalentApplied = true
			end
		end
	end

	if anyTalentApplied then
		tempPet.propertyScoreStage = 0
	end

	tempPet.basePropertyList:refreshTotal()

	if tempPet.resonanceInfo and tempPet.resonanceInfo.updateResonance then
		tempPet.resonanceInfo:updateResonance(tempPet)
	end

	local extraProps = TempPetTeamUtils.pickNonEmptyTable(cfg, defCfg, "extraProps")

	if extraProps then
		TempPetTeamUtils.collectExtraPropsToTempPetAttr(player, petId, AbilityConst.ATTRIBUTE_SRC_TYPE_PVP_TEMPLATE_EXTRA, 0, extraProps)
	end

	local basePetPrototypeId = Utils.getBasePetPrototypeId(tempPet.petPrototypeId)
	local psdd = PetSkillData[basePetPrototypeId] or {}
	local newId = 0
	local oldId = 0

	for sId, sdd in pairs(psdd) do
		if sdd.enhancedSkillId and sdd.enhancedSkillId ~= 0 then
			newId = sdd.enhancedSkillId
			oldId = sId

			break
		end
	end

	if newId ~= 0 then
		local enhancedSkillType = TempPetTeamUtils.pickPositive(cfg, defCfg, "enhancedSkill")

		if not enhancedSkillType then
			if tempPet.unlockedAbilityMap[newId] then
				local unlockedInfo = tempPet.unlockedAbilityMap[newId]
				local newAbilityId = AbilityUtils.getAbilityIdByParamId(tempPet.templateId, newId)
				local oldAbilityId = AbilityUtils.getAbilityIdByParamId(tempPet.templateId, oldId)

				if not tempPet.unlockedAbilityMap[oldId] then
					tempPet.unlockedAbilityMap[oldId] = unlockedInfo
				end

				tempPet.unlockedAbilityMap[newId] = nil

				if tempPet.curAbilityMap then
					for slot, curInfo in pairs(tempPet.curAbilityMap) do
						if curInfo.abilityId == newAbilityId then
							curInfo.abilityId = oldAbilityId
						end
					end
				end
			end
		elseif enhancedSkillType == 1 then
			local newAbilityId = AbilityUtils.getAbilityIdByParamId(tempPet.templateId, newId)

			if not tempPet.unlockedAbilityMap[newId] then
				local unlockedInfo = tempPet.unlockedAbilityMap[oldId]
				local oldAbilityId = AbilityUtils.getAbilityIdByParamId(tempPet.templateId, oldId)

				if unlockedInfo then
					tempPet.unlockedAbilityMap[newId] = unlockedInfo
					tempPet.unlockedAbilityMap[oldId] = nil
				end

				if tempPet.curAbilityMap then
					for slot, curInfo in pairs(tempPet.curAbilityMap) do
						if curInfo.abilityId == oldAbilityId then
							curInfo.abilityId = newAbilityId
						end
					end
				end
			end
		end
	end

	if pvpPropIdKey ~= nil then
		player.tempPetExtraAttr[petId] = player.tempPetExtraAttr[petId] or {}
		player.tempPetExtraAttr[petId].propId = pvpPropIdKey
	end
end

function TempPetTeamUtils.collectExtraPropsToTempPetAttr(player, petId, srcType, srcId, extraProps)
	local attr = player.tempPetExtraAttr[petId] or {}

	player.tempPetExtraAttr[petId] = attr

	local PROPS_KEY = TempPetTeamConst.EXTRA_ATTR_KEY_PROPS
	local PROP_GROUPS_KEY = TempPetTeamConst.EXTRA_ATTR_KEY_PROP_GROUPS
	local propsBySrcId, groupsBySrcId

	for key, value in pairs(extraProps) do
		if type(key) == "string" and AttributeConst[key] then
			if not propsBySrcId then
				local props = attr[PROPS_KEY] or {}

				attr[PROPS_KEY] = props

				local byType = props[srcType] or {}

				props[srcType] = byType
				propsBySrcId = byType[srcId] or {}
				byType[srcId] = propsBySrcId
			end

			propsBySrcId[key] = value + (propsBySrcId[key] or 0)
		elseif type(key) == "number" and AttributeGroupData[key] then
			if not groupsBySrcId then
				local groups = attr[PROP_GROUPS_KEY] or {}

				attr[PROP_GROUPS_KEY] = groups

				local byType = groups[srcType] or {}

				groups[srcType] = byType
				groupsBySrcId = byType[srcId] or {}
				byType[srcId] = groupsBySrcId
			end

			groupsBySrcId[key] = value + (groupsBySrcId[key] or 0)
		else
			player.logger:error("collectExtraPropsToTempPetAttr invalid key type=%s key=%s", type(key), tostring(key), player:repr())
		end
	end
end

function TempPetTeamUtils.applyCarryCoreItemConfig(player, petId, tempPet, cfg, extraParams)
	cfg = cfg or {}

	local defaultGroup = PvpTemplatePetConfigData[TempPetTeamConst.PVP_DEFAULT_GROUPID] or {}
	local defCfg = tempPet and defaultGroup[tempPet.templateId] or {}
	local mode = cfg.isCarrryCoreItem or defCfg.isCarrryCoreItem or TempPetTeamConst.CARRY_MODE_DEFAULT

	if mode == TempPetTeamConst.CARRY_MODE_DEFAULT then
		return
	end

	local itemId

	if mode == TempPetTeamConst.CARRY_MODE_BUFF_ONLY then
		local carryPosMap = player.tempPetCoreCarryPosMap
		local coreCarryInfo = tempPet and carryPosMap and carryPosMap:getItemInfo(petId)

		itemId = coreCarryInfo and coreCarryInfo.itemId
	end

	if player.clearTempPetCoreCarryPos then
		player:clearTempPetCoreCarryPos(petId)
	end

	if mode == TempPetTeamConst.CARRY_MODE_BUFF_ONLY and itemId then
		local buffIds = TempPetTeamUtils.collectCoreCarryBuffOnlyIds(itemId)

		if #buffIds > 0 then
			player.tempPetExtraAttr[petId] = player.tempPetExtraAttr[petId] or {}
			player.tempPetExtraAttr[petId][TempPetTeamConst.EXTRA_ATTR_KEY_BUFF_IDS] = buffIds
		end
	end
end

function TempPetTeamUtils.buildBossRushTemplateTeam(player, idList, extraParams)
	extraParams = extraParams or {}

	local groupId = extraParams.groupId or TempPetTeamConst.PVP_DEFAULT_GROUPID
	local groupAllId = extraParams.groupAllId or nil
	local groupAllData = groupAllId and PvpTemplatePetAllConfigData[groupAllId] or {}

	groupId = groupAllData and groupAllData.group or groupId

	local groupData = PvpTemplatePetConfigData[groupId] or {}

	for _, petId in ipairs(idList or EMPTY_TABLE) do
		if petId ~= "" and player.pets[petId] then
			local realPetInfo = player.pets[petId]

			player.tempPets[petId] = realPetInfo:getRawTable()

			player:copyBagPetCoreCarryPosToTemp(petId)

			player.tempPets[petId].tmpTemplateId = -1

			local tempPetInfo = player.tempPets[petId]
			local basePetPrototypeId = realPetInfo.basePetPrototypeId
			local cfg

			extraParams.propid = groupAllData and groupAllData.propid or nil

			if realPetInfo.botTemplateId ~= 0 then
				local petBotInfo = PetRobotData[realPetInfo.botTemplateId]

				if petBotInfo ~= nil then
					local petBotGroupId = petBotInfo.pvpGroupID
					local petBotGroupAllId = petBotInfo.pvpGroupAllID or nil
					local petBotGroupAllData = petBotGroupAllId and PvpTemplatePetAllConfigData[petBotGroupAllId] or {}

					petBotGroupId = petBotGroupAllData and petBotGroupAllData.group or petBotGroupId

					local petBotGroupData = PvpTemplatePetConfigData[petBotGroupId] or {}

					cfg = petBotGroupData[basePetPrototypeId]
					extraParams.propid = petBotGroupAllData and petBotGroupAllData.propid or extraParams.propid

					local botPetSkillGoups = PvpTemplatePetSkillConfigData[basePetPrototypeId]

					if botPetSkillGoups ~= nil then
						local botSkillInfo = botPetSkillGoups[petBotInfo.skillGroupID]

						if botSkillInfo ~= nil then
							tempPetInfo:refreshAbilitys(botSkillInfo.skillList, botSkillInfo.UltimateList)
						end
					end
				else
					player.logger:error("add temp pet error, pvppetBotId = %s", tempPetInfo.botTemplateId, player:repr())
				end
			end

			if cfg == nil then
				cfg = groupData[basePetPrototypeId]
			end

			TempPetTeamUtils.applyPvpTemplateConfig(player, petId, tempPetInfo, cfg, extraParams)
			TempPetTeamUtils.applyCarryCoreItemConfig(player, petId, tempPetInfo, cfg, extraParams)
			player.tempFormation:insert(#player.tempFormation + 1, petId)
		else
			player.logger:error("buildPvpTemplateTeam failed, invalid petId=%s", tostring(petId), player:repr())
		end
	end
end

function TempPetTeamUtils.buildPvpTemplateTeam(player, idList, extraParams)
	extraParams = extraParams or {}

	local groupId = extraParams.groupId or TempPetTeamConst.PVP_DEFAULT_GROUPID
	local groupAllId = extraParams.groupAllId or nil
	local groupAllData = groupAllId and PvpTemplatePetAllConfigData[groupAllId] or {}

	groupId = groupAllData and groupAllData.group or groupId

	local groupData = PvpTemplatePetConfigData[groupId] or {}

	for _, petId in ipairs(idList or EMPTY_TABLE) do
		if petId ~= "" and player.pets[petId] then
			local realPetInfo = player.pets[petId]

			player.tempPets[petId] = realPetInfo:getRawTable()

			player:copyBagPetCoreCarryPosToTemp(petId)

			player.tempPets[petId].tmpTemplateId = -1

			local tempPetInfo = player.tempPets[petId]
			local basePetPrototypeId = realPetInfo.basePetPrototypeId
			local cfg

			extraParams.propid = groupAllData and groupAllData.propid or nil

			if realPetInfo.botTemplateId ~= 0 then
				local petBotInfo = PetRobotData[realPetInfo.botTemplateId]

				if petBotInfo ~= nil then
					local petBotGroupId = petBotInfo.pvpGroupID
					local petBotGroupAllId = petBotInfo.pvpGroupAllID or nil
					local petBotGroupAllData = petBotGroupAllId and PvpTemplatePetAllConfigData[petBotGroupAllId] or {}

					petBotGroupId = petBotGroupAllData and petBotGroupAllData.group or petBotGroupId

					local petBotGroupData = PvpTemplatePetConfigData[petBotGroupId] or {}

					cfg = petBotGroupData[basePetPrototypeId]
					extraParams.propid = petBotGroupAllData and petBotGroupAllData.propid or extraParams.propid

					local botPetSkillGoups = PvpTemplatePetSkillConfigData[basePetPrototypeId]

					if botPetSkillGoups ~= nil then
						local botSkillInfo = botPetSkillGoups[petBotInfo.skillGroupID]

						if botSkillInfo ~= nil then
							tempPetInfo:refreshAbilitys(botSkillInfo.skillList, botSkillInfo.UltimateList)
						end
					end
				else
					player.logger:error("add temp pet error, pvppetBotId = %s", tempPetInfo.botTemplateId, player:repr())
				end
			end

			if cfg == nil then
				cfg = groupData[basePetPrototypeId]
			end

			TempPetTeamUtils.applyPvpTemplateConfig(player, petId, tempPetInfo, cfg, extraParams)
			TempPetTeamUtils.applyCarryCoreItemConfig(player, petId, tempPetInfo, cfg, extraParams)
			player.tempFormation:insert(#player.tempFormation + 1, petId)
		else
			player.logger:error("buildPvpTemplateTeam failed, invalid petId=%s", tostring(petId), player:repr())
		end
	end
end

TempPetTeamUtils.BuildTeamMap = {
	[Const.PET_TEAM_TYPE_TMP_FAIR_PVP] = TempPetTeamUtils.buildFairPvp,
	[Const.PET_TEAM_TYPE_TMP_UNFAIR_PVP] = TempPetTeamUtils.buildUnfairPvp,
	[Const.PET_TEAM_TYPE_TMP_BOSS_CHALLENGE] = TempPetTeamUtils.buildBossChallenge,
	[Const.PET_TEAM_TYPE_TMP_ROBEGG] = TempPetTeamUtils.buildPvpTemplateTeam,
	[Const.PET_TEM_TYPE_TMP_BOT_BOSSRUSH] = TempPetTeamUtils.buildBossRushTemplateTeam,
	[Const.PET_TEM_TYPE_TMP_BOT_NPCDUEL] = TempPetTeamUtils.buildPvpTemplateTeam
}

function TempPetTeamUtils.buildTeam(teamType, player, idList, extraParams)
	local func = TempPetTeamUtils.BuildTeamMap[teamType] or TempPetTeamUtils.buildDefault

	func(player, idList, extraParams)
end

function TempPetTeamUtils.applyExtraProps(ownerEntity, props)
	if ownerEntity.isFakeActor then
		return
	end

	for srcType, srcIdMap in pairs(props) do
		for srcId, attrs in pairs(srcIdMap) do
			local realSrcId = srcId == 0 and ownerEntity.actorId or srcId

			for propName, propValue in pairs(attrs) do
				local attrId = AttributeConst[propName]

				if not attrId then
					ownerEntity.logger:error("applyExtraProps unknown propName=%s", tostring(propName), ownerEntity:repr())
				else
					ownerEntity.actorAttributeApplicator:changeAttrib(srcType, realSrcId, attrId, propValue, {})
				end
			end
		end
	end
end

function TempPetTeamUtils.applyExtraPropGroups(ownerEntity, propGroups)
	if ownerEntity.isFakeActor then
		return
	end

	for srcType, srcIdMap in pairs(propGroups) do
		for srcId, groups in pairs(srcIdMap) do
			local realSrcId = srcId == 0 and ownerEntity.actorId or srcId

			for groupId, propValue in pairs(groups) do
				ownerEntity.actorAttributeApplicator:changeAttribGroup(srcType, realSrcId, groupId, propValue, {})
			end
		end
	end
end

function TempPetTeamUtils.applyExtraBuffs(ownerEntity, buffIds)
	if ownerEntity.isFakeActor then
		return
	end

	local overrideData = {
		duration = -1,
		specialType = AbilityConst.BUFF_SPECIAL_TYPES.CORE_CARRY
	}

	for _, buffId in ipairs(buffIds) do
		local buff = ownerEntity:addBuff(buffId, overrideData)

		if not buff then
			ownerEntity.logger:error("applyExtraBuffs add buff failed, buffId=%d", buffId, ownerEntity:repr())
		end
	end
end

TempPetTeamUtils.ApplyExtraAttrFnMap = {
	[TempPetTeamConst.EXTRA_ATTR_KEY_PROPS] = TempPetTeamUtils.applyExtraProps,
	[TempPetTeamConst.EXTRA_ATTR_KEY_PROP_GROUPS] = TempPetTeamUtils.applyExtraPropGroups,
	[TempPetTeamConst.EXTRA_ATTR_KEY_BUFF_IDS] = TempPetTeamUtils.applyExtraBuffs
}

function TempPetTeamUtils.activateTempPetExtraAttr(ownerEntity)
	local player = ownerEntity.master
	local petInfo = ownerEntity.petInfo

	if not player or not petInfo or not player.tempPetExtraAttr then
		return
	end

	local extra = player.tempPetExtraAttr[petInfo.id]

	if not extra then
		return
	end

	for key, fn in ipairs(TempPetTeamUtils.ApplyExtraAttrFnMap) do
		local data = extra[key]

		if data ~= nil then
			fn(ownerEntity, data)
		end
	end
end

function TempPetTeamUtils.collectCoreCarryBuffOnlyIds(itemId)
	local buffIds = {}
	local ccdd = CoreCarryData[itemId]

	if not ccdd then
		return buffIds
	end

	if ccdd.buffId then
		for _, buffId in ipairs(ccdd.buffId) do
			buffIds[#buffIds + 1] = buffId
		end
	end

	if ccdd.energyEffects then
		for i = 1, 2 do
			local energyEffect = ccdd.energyEffects[i]

			if energyEffect and energyEffect[2] then
				for _, buffId in ipairs(energyEffect[2]) do
					buffIds[#buffIds + 1] = buffId
				end
			end
		end
	end

	return buffIds
end

function TempPetTeamUtils.getOveridePropIdByEntity(ownerEntity)
	local player = ownerEntity.master
	local petInfo = ownerEntity.petInfo

	if not player or not petInfo then
		return
	end

	local extra = player.tempPetExtraAttr[petInfo.id]
	local propId = extra and extra.propId
	local overrideTable = propId and PvpPropIdOverrideData[propId]

	if not overrideTable then
		return
	end

	local petData = petInfo:getConfigData()
	local functionId = petData and petData.functionId

	if not functionId then
		return
	end

	return overrideTable[functionId]
end

return TempPetTeamUtils
