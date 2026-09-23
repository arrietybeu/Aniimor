-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\PetManagementDataHelper.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Lume = require("Core.Common.lume")
local UIConst = require("Const.UIConst")
local PetData = require("Data.pet_data")
local PetAvatarData = require("Data.pet_avatar_data")
local PetSkillData = require("Data.pet_skill_data")
local AbilityParamData = require("Data.ability_param_data")
local SkillTagData = require("Data.skill_tag_data")
local AbilityConst = require("Common.Const.AbilityConst")
local PetCharacterData = require("Data.pet_character_data")
local PetResearchIdToNumber = require("Data.pet_research_id_to_number")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local PetPrototypeData = require("Data.pet_prototype_data")
local PetFormTypeData = require("Data.pet_form_type_data")
local Utils = require("Common.Utils.Utils")
local ItemUtils = require("Common.Utils.ItemUtils")
local ElementNameToId = require("Data.element_name_to_id")
local HomeAbilityData = require("Data.home_ability_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Const = require("Common.Const.Const")
local PetTransmogUtils = require("GameApp.PetTransmog.PetTransmogUtils")
local PetNatureData = require("Data.pet_nature_data")
local PetLevelData = require("Data.pet_level_data")
local PetTalentData = require("Data.pet_talent_data")
local AttributeConst = require("Common.Const.AttributeConst")
local PetPropLevelMaxData = require("Data.pet_prop_level_max")
local PetDetailPropertyData = require("Data.pet_detail_property_data")
local SysConfigData = require("Data.sys_config_data")
local PetConfigData = require("Data.pet_config_data")
local PetFamilyData = require("Data.pet_family_data")
local CoreCarryData = require("Data.core_carry_data")
local PetInfo = require("CustomTypes.PetInfo")
local NoticeDef = require("Common.NoticeDef")
local ClientConst = require("Const.ClientConst")
local Time = require("Core.Common.Time")
local ItemConst = require("Common.Const.ItemConst")
local AddressDataConst = require("Const.AddressDataConst")
local PetRenameValidator = require("Utils.PetRenameValidator")
local ClientTextUtils = require("Utils.ClientTextUtils")
local TimerManager = require("Core.Timer.TimerManager")
local IS_MOBILE = IS_MOBILE
local PetManagementDataHelper = {}

PetManagementDataHelper.PetCoreCarryContactHelpId = PetConfigData.PET_CORE_CARRY_CERT or 219
PetManagementDataHelper.BuffInfoToolTipType = {
	Buff = 1,
	Cultivate = 3,
	Quality = 2
}
PetManagementDataHelper.PROP_KEYS = {
	[Const.BASE_PROPERTY_HP_IDX] = {
		1,
		1
	},
	[Const.BASE_PROPERTY_ATK_IDX] = {
		2,
		1
	},
	[Const.BASE_PROPERTY_DEF_IDX] = {
		4,
		1
	},
	[Const.BASE_PROPERTY_EP_REGEN_FORCE_IDX] = {
		6,
		1
	},
	[Const.BASE_PROPERTY_DEF_MAG_IDX] = {
		5,
		1
	},
	[Const.BASE_PROPERTY_ATK_MAG_IDX] = {
		3,
		1
	}
}
PetManagementDataHelper.MAX_FIGHT_PETS_COUNT = 4
PetManagementDataHelper.RENAME_FOR_GROUP = 0
PetManagementDataHelper.RENAME_FOR_PET = 1
PetManagementDataHelper.RENAME_FOR_BOX = 2
PetManagementDataHelper.FULL_ROW_SLOT_COUNT = 6
PetManagementDataHelper.FULL_PAGE_SLOT_COUNT = 30
PetManagementDataHelper.MAX_EXPLORE_PETS_COUNT = 3
PetManagementDataHelper.SORT_IDX = {
	FEATURE = 7,
	TALENT = 6,
	LEVEL = 5,
	CP = 4,
	RARITY = 3,
	BOOK_NUM = 2,
	TIME = 1,
	FUNCTION_ID = 10,
	FAMILY = 9,
	EXPLORE = 8
}
PetManagementDataHelper.FUNCTION_ID_ORDER = {
	[UIConst.NEW_PET_BATTLE_TYPE.DPS] = 5,
	[UIConst.NEW_PET_BATTLE_TYPE.BREAK] = 4,
	[UIConst.NEW_PET_BATTLE_TYPE.SUP] = 3,
	[UIConst.NEW_PET_BATTLE_TYPE.HEAL] = 2,
	[UIConst.NEW_PET_BATTLE_TYPE.ENERGY] = 1
}
PetManagementDataHelper.SORT_TIER_FIELD_MAP = {
	FEATURE = "hasRareFeature",
	TALENT = "rating",
	LEVEL = "level",
	CP = "cp",
	RARITY = "labelScore",
	FUNCTION_ID = "functionIdScore",
	TIME = "reverseTime",
	BOOK_NUM = "bookNum"
}
PetManagementDataHelper.FUNCTION_ID_CP_FILTER_RATE_SAME_SPECIES = {
	[UIConst.NEW_PET_BATTLE_TYPE.DPS] = SysConfigData.IntelFilterSameSpeciesCpRateBelowHide_DPS,
	[UIConst.NEW_PET_BATTLE_TYPE.BREAK] = SysConfigData.IntelFilterSameSpeciesCpRateBelowHide_Break,
	[UIConst.NEW_PET_BATTLE_TYPE.SUP] = SysConfigData.IntelFilterSameSpeciesCpRateBelowHide_Sup,
	[UIConst.NEW_PET_BATTLE_TYPE.HEAL] = SysConfigData.IntelFilterSameSpeciesCpRateBelowHide_Heal,
	[UIConst.NEW_PET_BATTLE_TYPE.ENERGY] = SysConfigData.IntelFilterSameSpeciesCpRateBelowHide_Energy
}
PetManagementDataHelper.FUNCTION_ID_CP_FILTER_RATE_SAME_ROLE = {
	[UIConst.NEW_PET_BATTLE_TYPE.DPS] = SysConfigData.IntelFilterSameRoleCpRateBelowHide_DPS,
	[UIConst.NEW_PET_BATTLE_TYPE.BREAK] = SysConfigData.IntelFilterSameRoleCpRateBelowHide_Break,
	[UIConst.NEW_PET_BATTLE_TYPE.SUP] = SysConfigData.IntelFilterSameRoleCpRateBelowHide_Sup,
	[UIConst.NEW_PET_BATTLE_TYPE.HEAL] = SysConfigData.IntelFilterSameRoleCpRateBelowHide_Heal,
	[UIConst.NEW_PET_BATTLE_TYPE.ENERGY] = SysConfigData.IntelFilterSameRoleCpRateBelowHide_Energy
}
PetManagementDataHelper.FILTER_LABEL_TYPE = {
	[0] = 0,
	[PetManagementDataHelper.SORT_IDX.TIME] = 1,
	[PetManagementDataHelper.SORT_IDX.BOOK_NUM] = 1,
	[PetManagementDataHelper.SORT_IDX.RARITY] = 0,
	[PetManagementDataHelper.SORT_IDX.CP] = 0,
	[PetManagementDataHelper.SORT_IDX.LEVEL] = 1,
	[PetManagementDataHelper.SORT_IDX.TALENT] = 2,
	[PetManagementDataHelper.SORT_IDX.FEATURE] = 3,
	[PetManagementDataHelper.SORT_IDX.EXPLORE] = 0,
	[PetManagementDataHelper.SORT_IDX.FAMILY] = 0,
	[PetManagementDataHelper.SORT_IDX.FUNCTION_ID] = 4
}
PetManagementDataHelper.filter = {
	isBoss = false,
	isShiny = false,
	isNormal = false,
	keyword = "",
	isNotRareFeature = false,
	isRareFeature = false,
	isInHomeland = false,
	isInExplore = false,
	isNotInBattle = false,
	isInBattle = false,
	isNone = false,
	isSwim = false,
	isGlide = false,
	isClimb = false,
	isRating4 = false,
	isRating3 = false,
	isRating2 = false,
	isRating1 = false,
	isEnergy = false,
	isBreak = false,
	isHeal = false,
	isSup = false,
	isDPS = false,
	isFavoriteType10 = false,
	isFavoriteType9 = false,
	isFavoriteType8 = false,
	isFavoriteType7 = false,
	isFavoriteType6 = false,
	isFavoriteType5 = false,
	isFavoriteType4 = false,
	isFavoriteType3 = false,
	isFavoriteType2 = false,
	isFavoriteType1 = false,
	isFavoriteType0 = false,
	isDark = false,
	isRainbow = false,
	elements = {}
}
PetManagementDataHelper.CUR_PROP = {
	[Const.BASE_PROPERTY_HP_IDX] = AttributeConst.hp_max_cur,
	[Const.BASE_PROPERTY_ATK_IDX] = AttributeConst.atk_cur,
	[Const.BASE_PROPERTY_DEF_IDX] = AttributeConst.def_cur,
	[Const.BASE_PROPERTY_EP_REGEN_FORCE_IDX] = AttributeConst.ep_regen_force_cur,
	[Const.BASE_PROPERTY_DEF_MAG_IDX] = AttributeConst.def_mag_cur,
	[Const.BASE_PROPERTY_ATK_MAG_IDX] = AttributeConst.bp_atk_cur
}
PetManagementDataHelper.NEW_PROP_NAMES = {
	[Const.NEW_BASE_PRO_STR] = "ATTRIBUTE_ATTACK",
	[Const.NEW_BASE_PRO_VIT] = "ATTRIBUTE_HP",
	[Const.NEW_BASE_PRO_STA] = "ATTRIBUTE_DEFINE",
	[Const.NEW_BASE_PRO_SPI] = "ATTRIBUTE_SP_DEFINE",
	[Const.NEW_BASE_PRO_HST] = "ATTRIBUTE_RECOVER",
	[Const.NEW_BASE_PRO_IMP] = "ATTRIBUTE_NAT"
}
PetManagementDataHelper.FINAL_PROP_NAMES = {
	[Const.BASE_PROPERTY_HP_IDX] = "ATTRIBUTE_HP",
	[Const.BASE_PROPERTY_ATK_IDX] = "ATTRIBUTE_ATTACK",
	[Const.BASE_PROPERTY_DEF_IDX] = "ATTRIBUTE_DEFINE",
	[Const.BASE_PROPERTY_EP_REGEN_FORCE_IDX] = "ATTRIBUTE_RECOVER",
	[Const.BASE_PROPERTY_DEF_MAG_IDX] = "ATTRIBUTE_SP_DEFINE",
	[Const.BASE_PROPERTY_ATK_MAG_IDX] = "ATTRIBUTE_SP_ATTACK"
}
PetManagementDataHelper.SIMULATE_CAL_PROPS = {
	[Const.BASE_PROPERTY_HP_IDX] = {
		AttributeConst.hp_max_v,
		AttributeConst.hp_max_p
	},
	[Const.BASE_PROPERTY_ATK_IDX] = {
		AttributeConst.atk_v,
		AttributeConst.atk_p
	},
	[Const.BASE_PROPERTY_DEF_IDX] = {
		AttributeConst.def_v,
		AttributeConst.def_p
	},
	[Const.BASE_PROPERTY_EP_REGEN_FORCE_IDX] = {
		AttributeConst.ep_regen_force_v,
		AttributeConst.ep_regen_force_p
	},
	[Const.BASE_PROPERTY_DEF_MAG_IDX] = {
		AttributeConst.def_mag_v,
		AttributeConst.def_mag_p
	},
	[Const.BASE_PROPERTY_ATK_MAG_IDX] = {
		AttributeConst.atk_mag_v,
		AttributeConst.atk_mag_p
	}
}
PetManagementDataHelper.CoreCarryContactState = {
	Contacted = 2,
	NotContact = 1,
	Unlocked = 0
}
PetManagementDataHelper.CoreCarryCertifyActivationState = {
	Active = 0,
	Inactive = 1
}

local function getCoreCarryCertifyLevel(coreCarryInfo)
	if coreCarryInfo and coreCarryInfo.getLevelAndExp then
		return coreCarryInfo:getLevelAndExp()
	end

	return coreCarryInfo and coreCarryInfo.cLevel or 0
end

function PetManagementDataHelper.getPetBaseFormPet(petInfo)
	local petData = petInfo and PetData[petInfo.templateId]
	local baseFormPet = petData and petData.baseFormPet

	if type(baseFormPet) ~= "number" or baseFormPet == 0 then
		return nil, petData
	end

	return baseFormPet, petData
end

function PetManagementDataHelper.isCoreCarryCertified(coreCarryInfo)
	return coreCarryInfo ~= nil and type(coreCarryInfo.certifiedBaseFormPet) == "number" and coreCarryInfo.certifiedBaseFormPet ~= 0
end

function PetManagementDataHelper.isCoreCarryCertifiedForPet(petInfo, coreCarryInfo)
	local baseFormPet = PetManagementDataHelper.getPetBaseFormPet(petInfo)

	return baseFormPet ~= nil and PetManagementDataHelper.isCoreCarryCertified(coreCarryInfo) and coreCarryInfo.certifiedBaseFormPet == baseFormPet
end

function PetManagementDataHelper.getCoreCarryCertifyActivationState(coreCarryInfo, equipPetInfo)
	if PetManagementDataHelper.isCoreCarryCertifiedForPet(equipPetInfo, coreCarryInfo) then
		return PetManagementDataHelper.CoreCarryCertifyActivationState.Active
	end

	return PetManagementDataHelper.CoreCarryCertifyActivationState.Inactive
end

function PetManagementDataHelper.getCoreCarryCertifiedPetInfo(coreCarryInfo, equipPetInfo)
	if not PetManagementDataHelper.isCoreCarryCertified(coreCarryInfo) then
		return nil
	end

	if PetManagementDataHelper.isCoreCarryCertifiedForPet(equipPetInfo, coreCarryInfo) then
		return equipPetInfo
	end

	local targetBaseFormPet = coreCarryInfo.certifiedBaseFormPet

	for _, petInfo in pairs(pg.me and pg.me.pets or EMPTY_TABLE) do
		if PetManagementDataHelper.getPetBaseFormPet(petInfo) == targetBaseFormPet then
			return petInfo
		end
	end

	return nil
end

function PetManagementDataHelper.getCoreCarryCertifySkillPairByBaseFormPet(templateId)
	if type(templateId) ~= "number" or templateId == 0 then
		return nil, nil
	end

	local basePetPrototypeId = Utils.getBasePetPrototypeId(Utils.getPetPetPrototypeId(templateId))
	local skillDataMap = PetSkillData[basePetPrototypeId]

	if not skillDataMap then
		return nil, nil
	end

	local originParamId, enhancedParamId, minSkillOrder

	for skillParamId, skillData in pairs(skillDataMap) do
		local skillOrder = skillData and skillData.skillOrder or math.huge
		local candidateEnhancedParamId = skillData and skillData.enhancedSkillId

		if type(candidateEnhancedParamId) == "number" and candidateEnhancedParamId ~= 0 and (minSkillOrder == nil or skillOrder < minSkillOrder) then
			originParamId = skillParamId
			enhancedParamId = candidateEnhancedParamId
			minSkillOrder = skillOrder
		end
	end

	if not originParamId then
		return nil, nil
	end

	return LuaUIUtils.buildEnhancedSkillInfo(originParamId, templateId), LuaUIUtils.buildEnhancedSkillInfo(enhancedParamId, templateId)
end

function PetManagementDataHelper.getCoreCarryCertifySkillPair(coreCarryInfo)
	if not PetManagementDataHelper.isCoreCarryCertified(coreCarryInfo) then
		return nil, nil
	end

	return PetManagementDataHelper.getCoreCarryCertifySkillPairByBaseFormPet(coreCarryInfo.certifiedBaseFormPet)
end

function PetManagementDataHelper.getCoreCarryCertifyRequiredLevel(itemId)
	local coreCarryData = CoreCarryData[itemId]

	if not coreCarryData then
		return nil
	end

	local requiredLevel = coreCarryData.canBindPet or -1

	if type(requiredLevel) ~= "number" or requiredLevel < -1 then
		return nil
	end

	return requiredLevel
end

function PetManagementDataHelper.getCoreCarryCertifyDisplayState(coreCarryInfo)
	local requiredLevel = PetManagementDataHelper.getCoreCarryCertifyRequiredLevel(coreCarryInfo and coreCarryInfo.itemId)
	local coreCarryLevel = getCoreCarryCertifyLevel(coreCarryInfo)

	if PetManagementDataHelper.isCoreCarryCertified(coreCarryInfo) then
		return PetManagementDataHelper.CoreCarryContactState.Contacted, requiredLevel, coreCarryLevel
	end

	if requiredLevel == nil or requiredLevel == -1 or coreCarryLevel < requiredLevel then
		return PetManagementDataHelper.CoreCarryContactState.Unlocked, requiredLevel, coreCarryLevel
	end

	return PetManagementDataHelper.CoreCarryContactState.NotContact, requiredLevel, coreCarryLevel
end

function PetManagementDataHelper.getCoreCarryCertifyAdvancedLockInfo(coreCarryInfo)
	local state, requiredLevel, coreCarryLevel = PetManagementDataHelper.getCoreCarryCertifyDisplayState(coreCarryInfo)

	return state == PetManagementDataHelper.CoreCarryContactState.Unlocked and requiredLevel ~= nil and requiredLevel > 0 and coreCarryLevel < requiredLevel, requiredLevel
end

function PetManagementDataHelper.checkPetCoreCarryCertifyStage(petInfo)
	local baseFormPet = PetManagementDataHelper.getPetBaseFormPet(petInfo)

	if not baseFormPet then
		return nil, baseFormPet
	end

	return Utils.hasEnhancedSkillConfig(petInfo.templateId), baseFormPet
end

function PetManagementDataHelper.getCoreCarryCertifyCostDict(petInfo)
	local _, petData = PetManagementDataHelper.getPetBaseFormPet(petInfo)
	local familyData = petData and PetFamilyData[petData.ethnicGroup]
	local sourceCostDict = familyData and familyData.equipmentBindNeedItem

	if not Utils.isTable(sourceCostDict) or next(sourceCostDict) == nil then
		return nil
	end

	local costDict = {}

	for itemId, itemCount in pairs(sourceCostDict) do
		if type(itemId) ~= "number" or type(itemCount) ~= "number" or itemCount <= 0 then
			return nil
		end

		costDict[itemId] = itemCount
	end

	return costDict
end

function PetManagementDataHelper.init()
	PetManagementDataHelper.selectBoxId = nil
end

function PetManagementDataHelper.getPetName(petId, withoutSuffix)
	local pet = pg.me:getPetInfo(petId)

	if pet.customName and pet.customName ~= "" then
		return pet.customName
	end

	local pData = PetData[pet.templateId] or {}
	local name = ""

	if withoutSuffix then
		name = pg.getLocalizationTextWithoutSuffix(pData.name)
	else
		name = pg.getLocalizationText(pData.name)
	end

	return name
end

function PetManagementDataHelper.getVariantPetsByFriendUid(friendUid)
	local variantPets = {}
	local petIds = pg.me:getPetVariantIdsByFriendUid(friendUid)

	for _, petId in ipairs(petIds) do
		local pet = assert(pg.me.pets[petId] or pg.me.simplifyPets[petId], string.format("petVariantFriendMap pet not found, petId=%s", petId))

		variantPets[#variantPets + 1] = pet
	end

	return variantPets
end

function PetManagementDataHelper.getPetSource(petId)
	local pet = pg.me:getPetInfo(petId)

	if not pet then
		return ""
	end

	local exchangeFromUid = pg.me:getPetExchangeFromUid(pet)

	if not string.isNilOrEmpty(exchangeFromUid) then
		return exchangeFromUid
	end

	local giveFromUid = pg.me:getPetGiveFromUid(pet)

	if not string.isNilOrEmpty(giveFromUid) then
		return giveFromUid
	end

	return ""
end

function PetManagementDataHelper.getCurCharacter(petId)
	local pet = pg.me:getPetInfo(petId)
	local controlFeatureId = pet.characterInfo.curCharacter
	local featureInfo = PetCharacterData[controlFeatureId]

	if featureInfo then
		local feature = Lume.clone(featureInfo)

		feature.featureId = controlFeatureId

		return feature, controlFeatureId
	end
end

function PetManagementDataHelper.getPetSkillInfos(petId, type)
	local abilityType, ability

	if type == AbilityConst.EXPLORE_ABILITY then
		abilityType = AbilityConst.EXPLORE_ABILITY

		local curAbilityMap = pg.me:getPetInfo(petId).exploreAbilityList:getRawTable()

		if next(curAbilityMap) then
			ability = {
				abilityId = curAbilityMap[next(curAbilityMap)]
			}
		end
	else
		local curAbilityMap = pg.me:getPetInfo(petId).curAbilityMap

		abilityType = type
		ability = curAbilityMap[abilityType]
	end

	if ability then
		local abilityParamData = pg.global.abilityMgr:getAbilityParamData(ability.abilityId)
		local abilityInfo = Lume.clone(abilityParamData)

		abilityInfo.abilityId = ability.abilityId
		abilityInfo.abilityType = abilityType
		abilityInfo.isRare = ToInt(AbilityUtils.isRareAbilityId(ability.abilityId))

		local tagList = {}

		if abilityInfo.tags then
			for _, tagId in pairs(abilityInfo.tags) do
				tagList[#tagList + 1] = {
					tagName = SkillTagData[tagId].tagName
				}
			end
		end

		abilityInfo.tagList = tagList
		abilityInfo.typeName = pg.getGameString(AbilityConst.ABILITY_TYPE_NAME[abilityType])

		return abilityInfo
	end

	return nil
end

function PetManagementDataHelper.getSkillInfosByAbilityId(abilityId, abilityType)
	local abilityParamData = pg.global.abilityMgr:getAbilityParamData(abilityId)
	local abilityInfo = Lume.clone(abilityParamData)

	abilityInfo.abilityId = abilityId
	abilityInfo.abilityType = abilityType
	abilityInfo.isRare = ToInt(AbilityUtils.isRareAbilityId(abilityId)) == 1

	local tagList = {}

	if abilityInfo.tags then
		for _, tagId in pairs(abilityInfo.tags) do
			tagList[#tagList + 1] = {
				tagName = SkillTagData[tagId].tagName
			}
		end
	end

	abilityInfo.tagList = tagList
	abilityInfo.typeName = pg.getGameString(AbilityConst.ABILITY_TYPE_NAME[abilityType])

	return abilityInfo
end

function PetManagementDataHelper.getPetCustomName(petId)
	local pet = pg.me:getPetInfo(petId)

	return pet.customName or ""
end

function PetManagementDataHelper.getGroupNameInfo(groupIdx)
	local player = pg.me
	local pets = player.pets
	local prepare = player.prepareFormationList[groupIdx]
	local ret = {}

	ret.idx = groupIdx
	ret.customName = prepare.customName
	ret.pets = {}

	for i = 1, #prepare.formation do
		local pet = pets[prepare.formation[i]]
		local pData = PetData[pet.templateId] or {}
		local iconName = pData.iconName
		local label = pet.label
		local isShiny = Utils.isLabelShiny(label)
		local cp = pet:getCpValue()

		ret.pets[#ret.pets + 1] = {
			iconName = iconName,
			cp = cp,
			label = label,
			isShiny = isShiny
		}
	end

	return ret
end

function PetManagementDataHelper.getCurGroupName(groupId)
	local nameInfo = PetManagementDataHelper.getGroupNameInfo(groupId)

	if nameInfo.customName and nameInfo.customName ~= "" then
		return nameInfo.customName
	end

	return pg.getGameString("DEFAULT_GROUP_NAME") .. " " .. groupId
end

function PetManagementDataHelper.getGroupNameByIndex(index)
	local nameInfo = PetManagementDataHelper.getGroupNameInfo(index)

	if nameInfo.customName and nameInfo.customName ~= "" then
		return nameInfo.customName
	end

	return pg.getGameString("DEFAULT_GROUP_NAME") .. " " .. index
end

function PetManagementDataHelper.getBoxNameInfo(boxIdx)
	local petBoxMap = pg.me.petBoxMap
	local ret = {}

	ret.idx = boxIdx
	ret.customName = petBoxMap[boxIdx].customName
	ret.countNum = petBoxMap[boxIdx].count .. "/" .. petBoxMap[boxIdx].slotCount
	ret.count = petBoxMap[boxIdx].count
	ret.slotCount = petBoxMap[boxIdx].slotCount

	return ret
end

function PetManagementDataHelper.getCurBoxName(boxId)
	local nameInfo = PetManagementDataHelper.getBoxNameInfo(boxId)

	if nameInfo.customName and nameInfo.customName ~= "" then
		return nameInfo.customName
	end

	return pg.getGameString("DEFAULT_PET_BOX_NAME") .. " " .. boxId
end

function PetManagementDataHelper.trySyncRename(newName, renameType, id)
	if renameType == PetManagementDataHelper.RENAME_FOR_PET then
		pg.me:serverMsg("RPC_CS_CustomPetName", id, newName)
	elseif renameType == PetManagementDataHelper.RENAME_FOR_GROUP then
		pg.me:serverMsg("RPC_CS_RenamePrepareFormation", id, newName)
	elseif renameType == PetManagementDataHelper.RENAME_FOR_BOX then
		pg.me:serverMsg("RPC_CS_PetBoxRename", id, newName)
	end
end

function PetManagementDataHelper.showRename(inputId, renameType)
	if renameType == PetManagementDataHelper.RENAME_FOR_PET and not PetRenameValidator.canRenamePet() then
		pg.global.showBubbleMessage(NoticeDef.FORBID_CHANGE_PET_NAME)

		return
	end

	local title
	local id = inputId
	local text

	if renameType == PetManagementDataHelper.RENAME_FOR_PET then
		title = pg.getGameString("RENAME_TIPS_PET")
		text = PetManagementDataHelper.getPetName(id)
	elseif renameType == PetManagementDataHelper.RENAME_FOR_GROUP then
		title = pg.getGameString("RENAME_TIPS_GROUP")
		text = PetManagementDataHelper.getCurGroupName(id)
	elseif renameType == PetManagementDataHelper.RENAME_FOR_BOX then
		title = pg.getGameString("RENAME_TIPS_BOX")
		text = PetManagementDataHelper.getCurBoxName(id)
	end

	pg.global.ui.tips:showCommonInput(title, function(newName)
		if string.isNilOrEmpty(newName) or string.find(newName, "%s") then
			pg.global.showBubbleMessageRaw(pg.getGameString("NAME_NOT_VALID"))

			return true
		end

		PetManagementDataHelper.trySyncRename(newName, renameType, id)
	end, function()
		return
	end, {
		characterLimit = 14,
		text = text or ""
	})
end

function PetManagementDataHelper.getSelectBoxId()
	if not PetManagementDataHelper.selectBoxId then
		PetManagementDataHelper.selectBoxId = pg.me.petBoxMap.curIndex
	end

	return PetManagementDataHelper.selectBoxId
end

function PetManagementDataHelper.setSelectBoxId(boxId)
	PetManagementDataHelper.selectBoxId = boxId
end

function PetManagementDataHelper.getSwitchBoxPageIsPre(delta)
	if delta == nil or delta == 0 then
		return nil
	end

	return delta > 0
end

function PetManagementDataHelper.getActiveFormFilters(filterData)
	local formFilters = {}

	for key, value in pairs(filterData or EMPTY_TABLE) do
		if value == true and type(key) == "string" and string.match(key, "^isForm%d+$") then
			formFilters[key] = true
		end
	end

	return formFilters
end

function PetManagementDataHelper.appendFormFilters(filterData, formFilters)
	if not filterData or not formFilters then
		return
	end

	for key, value in pairs(formFilters) do
		if type(key) == "string" and string.match(key, "^isForm%d+$") then
			filterData[key] = value and true or false
		end
	end
end

function PetManagementDataHelper.getSelectedFormTypeMap(filters)
	local selectedFormTypeMap = {}
	local hasSelectedForm = false

	for key, value in pairs(filters or EMPTY_TABLE) do
		if value == true and type(key) == "string" then
			local formTypeId = string.match(key, "^isForm(%d+)$")

			if formTypeId then
				local id = tonumber(formTypeId)

				selectedFormTypeMap[id] = true
				hasSelectedForm = true

				for childId, childData in pairs(PetFormTypeData) do
					if childData.belong == id then
						selectedFormTypeMap[childId] = true
					end
				end
			end
		end
	end

	return selectedFormTypeMap, hasSelectedForm
end

function PetManagementDataHelper.initFilter(filter)
	if not filter then
		return
	end

	for key, _ in pairs(filter) do
		if type(key) == "string" and string.match(key, "^isForm%d+$") then
			filter[key] = nil
		end
	end

	filter.filterType = filter.filterType or UIConst.PET_SLOT_DISPLAY_TYPE.Normal
	filter.keyword = ""
	filter.isNormal = false
	filter.isShiny = false
	filter.isBoss = false
	filter.isRainbow = false
	filter.isDark = false

	for i = 0, 10 do
		filter["isFavoriteType" .. i] = false
	end

	filter.isDPS = false
	filter.isSup = false
	filter.isHeal = false
	filter.isBreak = false
	filter.isEnergy = false
	filter.isRating1 = false
	filter.isRating2 = false
	filter.isRating3 = false
	filter.isRating4 = false
	filter.isClimb = false
	filter.isGlide = false
	filter.isSwim = false
	filter.isNone = false
	filter.isInBattle = false
	filter.isNotInBattle = false
	filter.isInExplore = false

	if UIConst.PET_SLOT_DISPLAY_TYPE.Normal then
		-- block empty
	end

	filter.isInHomeland = nil
	filter.isRareFeature = false
	filter.isNotRareFeature = false
	filter.elements = {}
end

function PetManagementDataHelper.setFilter(data, filter)
	data = data or {}

	if filter == nil and PetManagementDataHelper.filter == nil then
		PetManagementDataHelper.filter = {}
	end

	filter = filter or PetManagementDataHelper.filter

	if not next(data) then
		PetManagementDataHelper.initFilter(filter)
	else
		PetManagementDataHelper.initFilter(filter)

		for i, v in pairs(data) do
			if i ~= "formFilters" then
				filter[i] = v
			end
		end

		PetManagementDataHelper.appendFormFilters(filter, data.formFilters)
	end
end

function PetManagementDataHelper.getSelectSortId()
	if not PetManagementDataHelper.selectSortId then
		PetManagementDataHelper.selectSortId = 0
	end

	return PetManagementDataHelper.selectSortId
end

function PetManagementDataHelper.getSortSwitchStatus()
	if PetManagementDataHelper.isDescending == nil then
		PetManagementDataHelper.isDescending = true
	end

	return PetManagementDataHelper.isDescending
end

function PetManagementDataHelper.filterTempProcess(baseFilter, reset)
	local filter = baseFilter

	if not filter then
		filter = {}

		PetManagementDataHelper.initFilter(filter)
	end

	filter.filterType = filter and filter.filterType or UIConst.PET_SLOT_DISPLAY_TYPE.Normal

	if not PetManagementDataHelper.recordFilter then
		PetManagementDataHelper.recordFilter = {}
	end

	local recordFilter = PetManagementDataHelper.recordFilter[filter.filterType] or nil

	if reset then
		if not recordFilter then
			return
		end

		PetManagementDataHelper.setFilter(recordFilter, baseFilter)

		return
	end

	PetManagementDataHelper.recordFilter[filter.filterType] = {
		filterType = filter.filterType,
		keyword = filter.keyword,
		isNormal = filter.isNormal,
		isShiny = filter.isShiny,
		isBoss = filter.isBoss,
		isRainbow = filter.isRainbow,
		isDark = filter.isDark,
		elements = filter.elements,
		isDPS = filter.isDPS,
		isSup = filter.isSup,
		isHeal = filter.isHeal,
		isTank = filter.isTank,
		isRating1 = filter.isRating1,
		isRating2 = filter.isRating2,
		isRating3 = filter.isRating3,
		isRating4 = filter.isRating4,
		isClimb = filter.isClimb,
		isGlide = filter.isGlide,
		isSwim = filter.isSwim,
		isNone = filter.isNone,
		isInBattle = filter.isInBattle,
		isNotInBattle = filter.isNotInBattle,
		isInExplore = filter.isInExplore,
		isInHomeland = filter.isInHomeland,
		isRareFeature = filter.isRareFeature,
		isNotRareFeature = filter.isNotRareFeature,
		formFilters = PetManagementDataHelper.getActiveFormFilters(filter)
	}

	if not filter.isNormal and not filter.isShiny and not filter.isBoss and not filter.isRainbow and not filter.isDark then
		filter.isNormal = true
		filter.isShiny = true
		filter.isBoss = true
		filter.isRainbow = true
		filter.isDark = true
	end

	local anyFavTypeSelected = false

	for i = 1, 10 do
		if filter["isFavoriteType" .. i] then
			anyFavTypeSelected = true

			break
		end
	end

	if not anyFavTypeSelected then
		for i = 0, 10 do
			filter["isFavoriteType" .. i] = true
		end
	end

	if not filter.isRating1 and not filter.isRating2 and not filter.isRating3 and not filter.isRating4 then
		filter.isRating1 = true
		filter.isRating2 = true
		filter.isRating3 = true
		filter.isRating4 = true
	end

	if not filter.isInBattle and not filter.isNotInBattle and not filter.isInExplore and (filter.isInHomeland == nil or not filter.isInHomeland) then
		filter.isInBattle = true
		filter.isNotInBattle = true
		filter.isInExplore = true

		if filter.isInHomeland ~= nil then
			filter.isInHomeland = true
		end
	end

	if not filter.isDPS and not filter.isSup and not filter.isHeal and not filter.isBreak and not filter.isEnergy then
		filter.isDPS = true
		filter.isSup = true
		filter.isHeal = true
		filter.isBreak = true
		filter.isEnergy = true
	end

	if not filter.elements or Lume.count(filter.elements) <= 0 then
		local allElements = {}

		if filter.filterType == UIConst.PET_SLOT_DISPLAY_TYPE.Normal then
			for k, _ in pairs(ElementNameToId) do
				if k ~= "null" then
					local d = {}

					d.name = k
					allElements[#allElements + 1] = d
				end
			end
		else
			for id, _ in pairs(HomeAbilityData) do
				if _ ~= "null" then
					local d = {}

					d.name = id
					allElements[#allElements + 1] = d
				end
			end
		end

		local temp = {}

		for _, v in pairs(allElements) do
			temp[v.name] = v.name
		end

		filter.elements = temp
	end

	baseFilter = filter
end

function PetManagementDataHelper.getLabelScore(label, templateId)
	local isShiny = Utils.isLabelShiny(label) and SysConfigData.LABEL_VALUE[1] or 0
	local isBoss = Utils.isLabelElite(label) and SysConfigData.LABEL_VALUE[4] or 0
	local isRainbow = Utils.isAnyRainbowTypeByTemplateId(templateId) and SysConfigData.LABEL_VALUE[99] or 0
	local isVariant = Utils.isLabelVariant(label) and SysConfigData.LABEL_VALUE[8] or 0

	return isShiny + isBoss + isRainbow + isVariant
end

function PetManagementDataHelper.sortTableBySortConditions(ret, filter)
	local sortCondition = PetManagementDataHelper.getSelectSortId()
	local isDescending = not PetManagementDataHelper.getSortSwitchStatus()
	local newT = {}

	for i = 1, #ret do
		if not ret[i].isEmpty then
			local num = #newT + 1

			newT[num] = {}

			for k, v in pairs(ret[i]) do
				newT[num][k] = v
			end

			if newT[num].isCatchReportingStatus then
				newT[num].cp = isDescending and math.maxInt or -math.maxInt
				newT[num].rating = isDescending and math.maxInt or -math.maxInt
			end
		end
	end

	local sortKeys = {
		[PetManagementDataHelper.SORT_IDX.TIME] = {
			"reverseTime",
			"cp",
			"labelScore",
			"rating",
			"level",
			"hasRareFeature"
		},
		[PetManagementDataHelper.SORT_IDX.BOOK_NUM] = {
			"bookNum",
			"cp",
			"labelScore",
			"rating",
			"level",
			"hasRareFeature",
			"reverseTime"
		},
		[PetManagementDataHelper.SORT_IDX.RARITY] = {
			"labelScore",
			"cp",
			"rating",
			"level",
			"hasRareFeature",
			"reverseTime"
		},
		[PetManagementDataHelper.SORT_IDX.CP] = {
			"cp",
			"labelScore",
			"rating",
			"level",
			"hasRareFeature",
			"reverseTime"
		},
		[PetManagementDataHelper.SORT_IDX.LEVEL] = {
			"level",
			"cp",
			"labelScore",
			"rating",
			"hasRareFeature",
			"reverseTime"
		},
		[PetManagementDataHelper.SORT_IDX.TALENT] = {
			"rating",
			"cp",
			"labelScore",
			"level",
			"hasRareFeature",
			"reverseTime"
		},
		[PetManagementDataHelper.SORT_IDX.FEATURE] = {
			"hasRareFeature",
			"cp",
			"labelScore",
			"rating",
			"level",
			"hasRareFeature",
			"reverseTime"
		},
		[PetManagementDataHelper.SORT_IDX.EXPLORE] = {
			"exploreSlotIndex",
			"highestExploreSkillLevel",
			"cp",
			"labelScore",
			"rating",
			"level",
			"hasRareFeature",
			"reverseTime"
		},
		[PetManagementDataHelper.SORT_IDX.FUNCTION_ID] = {
			"functionIdScore",
			"cp",
			"labelScore",
			"rating",
			"level",
			"hasRareFeature",
			"reverseTime"
		}
	}

	if sortCondition == PetManagementDataHelper.SORT_IDX.FAMILY then
		local petIds = {}
		local petIdToData = {}

		for i = 1, #newT do
			petIds[i] = newT[i].id
			petIdToData[newT[i].id] = newT[i]
		end

		pg.me.petBoxMap:sortPetIds(petIds, pg.me.pets, Const.PET_BOX_SORT.FAMILY, isDescending and 0 or 1)

		for i = 1, #petIds do
			newT[i] = petIdToData[petIds[i]]
		end
	elseif sortCondition ~= 0 then
		PetManagementDataHelper.templateFun(newT, isDescending, table.unpack(sortKeys[sortCondition] or {}))
	else
		newT = ret
	end

	if not filter then
		return newT
	end

	local resultRarity = {
		[2] = {},
		[3] = {},
		[4] = {},
		[5] = {}
	}
	local resultElement = {}
	local resultStatus = {}
	local resultRemains = {}

	for i = 1, #newT do
		local data = newT[i]
		local rarityMatchCount = PetManagementDataHelper.checkRarity(data, filter)

		if rarityMatchCount >= 2 then
			table.insert(resultRarity[rarityMatchCount], data)
		else
			local elementMatchCount = PetManagementDataHelper.checkElement(data, filter)

			if elementMatchCount >= 2 then
				table.insert(resultElement, data)
			else
				local statusMatchCount = PetManagementDataHelper.checkStatus(data, filter)

				if statusMatchCount >= 2 then
					table.insert(resultStatus, data)
				else
					table.insert(resultRemains, data)
				end
			end
		end
	end

	local result = {}

	for i = 5, 2, -1 do
		for j = 1, #resultRarity[i] do
			table.insert(result, resultRarity[i][j])
		end
	end

	for i = 1, #resultElement do
		table.insert(result, resultElement[i])
	end

	for i = 1, #resultStatus do
		table.insert(result, resultStatus[i])
	end

	for i = 1, #resultRemains do
		table.insert(result, resultRemains[i])
	end

	return result
end

function PetManagementDataHelper.templateFun(newT, isDescending, ...)
	local keys = {
		...
	}

	table.sort(newT, function(a, b)
		for _, key in ipairs(keys) do
			if a[key] ~= b[key] then
				if isDescending then
					return a[key] < b[key]
				else
					return a[key] > b[key]
				end
			end
		end

		return false
	end)
end

function PetManagementDataHelper.checkPetValidByFilter(pet, filters)
	local filterType = filters.filterType or UIConst.PET_SLOT_DISPLAY_TYPE.Normal
	local petName = PetManagementDataHelper.getPetName(pet.id)

	if not string.isNilOrEmpty(filters.keyword) and not string.find(string.split(pg.getLocalizationText(petName), "<")[1], filters.keyword) then
		return false
	end

	local pData = PetData[pet.templateId] or {}
	local include = false

	if filterType == UIConst.PET_SLOT_DISPLAY_TYPE.Normal then
		local _, elementNames = LuaUIUtils.getElementInfo(pData.elementType)

		for i = 1, #elementNames do
			if filters.elements[elementNames[i].element] ~= nil then
				include = true

				break
			end
		end
	elseif filterType == UIConst.PET_SLOT_DISPLAY_TYPE.Homeland then
		local homeAbility = pData.homeAbility

		if homeAbility and next(homeAbility) then
			for abilityId, lv in pairs(homeAbility) do
				if filters.elements[abilityId] ~= nil then
					include = true

					break
				end
			end
		end
	end

	if include == false then
		return false
	end

	local petExtra = PetManagementDataHelper.setUpPetInfo(pet)
	local selectedFormTypeMap, hasSelectedForm = PetManagementDataHelper.getSelectedFormTypeMap(filters)

	if hasSelectedForm then
		local petFormTypeId = Utils.getPetFormIdByTemplateId(pet.templateId)

		if not selectedFormTypeMap[petFormTypeId] then
			return false
		end
	end

	local petIsShiny = petExtra.isShiny
	local petIsBoss = petExtra.isBoss
	local petIsRainbow = petExtra.isRainbow
	local petIsBlackRainbow = petExtra.isBlackRainbow
	local petIsDark = petExtra.isDark
	local petIsNormal = not petIsShiny and not petIsBoss and not petIsRainbow and not petIsBlackRainbow and not petIsDark

	if filters.isNormal and petIsNormal then
		-- block empty
	elseif filters.isShiny and petIsShiny then
		-- block empty
	elseif filters.isBoss and petIsBoss then
		-- block empty
	elseif filters.isRainbow and (petIsRainbow or petIsBlackRainbow) then
		-- block empty
	elseif filters.isDark and petIsDark then
		-- block empty
	else
		return false
	end

	local petIsDPS = Utils.isMatchPetFuncType(petExtra.petType, UIConst.NEW_PET_BATTLE_TYPE.DPS)
	local petIsSup = Utils.isMatchPetFuncType(petExtra.petType, UIConst.NEW_PET_BATTLE_TYPE.SUP)
	local petIsHeal = Utils.isMatchPetFuncType(petExtra.petType, UIConst.NEW_PET_BATTLE_TYPE.HEAL)
	local petIsBreak = Utils.isMatchPetFuncType(petExtra.petType, UIConst.NEW_PET_BATTLE_TYPE.BREAK)
	local petIsEnergy = Utils.isMatchPetFuncType(petExtra.petType, UIConst.NEW_PET_BATTLE_TYPE.ENERGY)

	if filters.isDPS and petIsDPS then
		-- block empty
	elseif filters.isSup and petIsSup then
		-- block empty
	elseif filters.isHeal and petIsHeal then
		-- block empty
	elseif filters.isBreak and petIsBreak then
		-- block empty
	elseif filters.isEnergy and petIsEnergy then
		-- block empty
	else
		return false
	end

	local petFavoriteType = pet.favoriteType or 0

	if not filters["isFavoriteType" .. petFavoriteType] then
		return false
	end

	if petExtra.rating >= 0 then
		local petIsRating1 = petExtra.rating == 0
		local petIsRating2 = petExtra.rating == 1
		local petIsRating3 = petExtra.rating == 2
		local petIsRating4 = petExtra.rating == 3

		if filters.isRating1 and petIsRating1 then
			-- block empty
		elseif filters.isRating2 and petIsRating2 then
			-- block empty
		elseif filters.isRating3 and petIsRating3 then
			-- block empty
		elseif filters.isRating4 and petIsRating4 then
			-- block empty
		else
			return false
		end
	end

	local inBattle = petExtra.inBattle
	local notInBattle = not inBattle
	local inExplore = petExtra.inExplore
	local inHomeland = petExtra.isPutInHomeland

	if filters.isInBattle and inBattle then
		-- block empty
	elseif filters.isNotInBattle and notInBattle then
		-- block empty
	elseif filters.isInExplore and inExplore then
		-- block empty
	elseif filters.isInHomeland and inHomeland then
		-- block empty
	else
		return false
	end

	local filterExplores = {
		isClimb = filters.isClimb and 1 or nil,
		isGlide = filters.isGlide and 2 or nil,
		isSwim = filters.isSwim and 3 or nil,
		isNone = filters.isNone and 4 or nil
	}
	local explores = {}

	if petExtra.exploreSkillsLevel.canClimb then
		explores.isClimb = 1
	end

	if petExtra.exploreSkillsLevel.canGlide then
		explores.isGlide = 2
	end

	if petExtra.exploreSkillsLevel.canSwim then
		explores.isSwim = 3
	end

	if not petExtra.exploreSkillsLevel.canClimb and not petExtra.exploreSkillsLevel.canGlide and not petExtra.exploreSkillsLevel.canSwim then
		explores.isNone = 4
	end

	if filterExplores.isClimb == nil and filterExplores.isGlide == nil and filterExplores.isSwim == nil and filterExplores.isNone == nil then
		return true
	elseif filterExplores.isClimb ~= nil and filterExplores.isGlide == nil and filterExplores.isSwim == nil and filterExplores.isNone == nil then
		if not explores.isClimb then
			return false
		end
	elseif filterExplores.isClimb == nil and filterExplores.isGlide ~= nil and filterExplores.isSwim == nil and filterExplores.isNone == nil then
		if not explores.isGlide then
			return false
		end
	elseif filterExplores.isClimb == nil and filterExplores.isGlide == nil and filterExplores.isSwim ~= nil and filterExplores.isNone == nil then
		if not explores.isSwim then
			return false
		end
	elseif filterExplores.isClimb == nil and filterExplores.isGlide == nil and filterExplores.isSwim == nil and filterExplores.isNone ~= nil then
		if not explores.isNone then
			return false
		end
	elseif filterExplores.isClimb ~= nil and filterExplores.isGlide ~= nil and filterExplores.isSwim == nil and filterExplores.isNone == nil then
		if not explores.isClimb and not explores.isGlide then
			return false
		end
	elseif filterExplores.isClimb ~= nil and filterExplores.isGlide == nil and filterExplores.isSwim ~= nil and filterExplores.isNone == nil then
		if not explores.isClimb and not explores.isSwim then
			return false
		end
	elseif filterExplores.isClimb ~= nil and filterExplores.isGlide == nil and filterExplores.isSwim == nil and filterExplores.isNone ~= nil then
		if not explores.isClimb and not explores.isNone then
			return false
		end
	elseif filterExplores.isClimb == nil and filterExplores.isGlide ~= nil and filterExplores.isSwim ~= nil and filterExplores.isNone == nil then
		if not explores.isGlide and not explores.isSwim then
			return false
		end
	elseif filterExplores.isClimb == nil and filterExplores.isGlide ~= nil and filterExplores.isSwim == nil and filterExplores.isNone ~= nil then
		if not explores.isGlide and not explores.isNone then
			return false
		end
	elseif filterExplores.isClimb == nil and filterExplores.isGlide == nil and filterExplores.isSwim ~= nil and filterExplores.isNone ~= nil then
		if not explores.isSwim and not explores.isNone then
			return false
		end
	elseif filterExplores.isClimb ~= nil and filterExplores.isGlide ~= nil and filterExplores.isSwim ~= nil and filterExplores.isNone == nil then
		if not explores.isClimb and not explores.isGlide and not explores.isSwim then
			return false
		end
	elseif filterExplores.isClimb == nil and filterExplores.isGlide ~= nil and filterExplores.isSwim ~= nil and filterExplores.isNone ~= nil then
		if not explores.isGlide and not explores.isSwim and not explores.isNone then
			return false
		end
	elseif filterExplores.isClimb ~= nil and filterExplores.isGlide == nil and filterExplores.isSwim ~= nil and filterExplores.isNone ~= nil then
		if not explores.isClimb and not explores.isSwim and not explores.isNone then
			return false
		end
	elseif filterExplores.isClimb ~= nil and filterExplores.isGlide ~= nil and filterExplores.isSwim == nil and filterExplores.isNone ~= nil then
		if not explores.isClimb and not explores.isGlide and not explores.isNone then
			return false
		end
	elseif filterExplores.isClimb ~= nil and filterExplores.isGlide ~= nil and filterExplores.isSwim ~= nil and filterExplores.isNone ~= nil then
		return true
	end

	return true
end

function PetManagementDataHelper.getCpValue(petId)
	local pet = pg.me:getPetInfo(petId)

	return pet and pet:getCpValue() or 0
end

function PetManagementDataHelper.createPetInfoTipData(petInfo)
	local TmpPetTemplateData = require("Data.tmp_pet_template_data")
	local petData = PetData[petInfo.templateId] or {}
	local templateData = TmpPetTemplateData[petInfo.templateId]
	local elementNames = PetManagementDataHelper.getPetInfoTipElementNames(petInfo, petData)
	local breedTalent = PetManagementDataHelper.createPetInfoTipBreedTalent(petInfo)
	local controlFeatureId, featureInfo = PetManagementDataHelper.getPetInfoTipFeatureData(petInfo, templateData)
	local skillAbilityMap = PetManagementDataHelper.getPetInfoTipSkillAbilityMap(petInfo, templateData)
	local ratingString = petInfo.ratingString or petInfo.ratingStribng

	return {
		id = petInfo.id,
		name = LuaUIUtils.getPetNameByPetInfo(petInfo),
		isCatchReporting = petInfo.isCatchReporting or petInfo.isCatchReportingStatus,
		iconName = petData.iconName,
		label = petInfo.label,
		templateId = petInfo.templateId,
		elementNames = Utils.deepCopyTable(petInfo.elementNames or elementNames),
		cp = petInfo.cp,
		gender = petInfo.gender,
		level = petInfo.level,
		isShiny = Utils.isLabelShiny(petInfo.label),
		isBoss = Utils.isLabelElite(petInfo.label),
		isVariant = Utils.isLabelVariant(petInfo.label),
		isMagic = Utils.isLabelMagic(petInfo.label),
		isVariantInteractPet = petInfo.isVariantInteractPet,
		variantFriendUid = petInfo.variantFriendUid,
		variantTime = petInfo.variantTime,
		breedTalent = breedTalent,
		exp = petInfo.exp,
		basePropertyList = Utils.deepCopyTable(petInfo.basePropertyList),
		propertyEnhanced = Utils.deepCopyTable(petInfo.propertyEnhanced),
		calculatedAttributeMap = Utils.deepCopyTable(petInfo.calculatedAttributeMap),
		extraSrcMap = Utils.deepCopyTable(petInfo.extraSrcMap),
		featureInfo = featureInfo,
		controlFeatureId = controlFeatureId,
		skillAbilityMap = skillAbilityMap,
		skillPresetName = PetManagementDataHelper.getPetInfoTipSkillPresetName(petInfo),
		carryData = PetManagementDataHelper.getPetInfoTipCarryData(petInfo),
		pageIndex = petInfo.pageIndex,
		ratingString = ratingString,
		ratingStribng = ratingString,
		sourceDesc = petInfo.sourceDesc,
		time = petInfo.time,
		bookNum = petInfo.bookNum or PetResearchIdToNumber[petInfo.templateId],
		resonanceInfo = Utils.deepCopyTable(petInfo.resonanceInfo),
		selectTransmogScheme = Utils.deepCopyTable(petInfo.selectTransmogScheme)
	}
end

function PetManagementDataHelper.getPetInfoTipSkillPresetName(petInfo)
	if not string.isNilOrEmpty(petInfo.skillPresetName) then
		return petInfo.skillPresetName
	end

	local pet = petInfo._petInfo

	if not pet or not pet.curAbilityPreset then
		return ""
	end

	local abilityPreset = pet.abilityPresetMap and pet.abilityPresetMap[pet.curAbilityPreset]

	if abilityPreset and not string.isNilOrEmpty(abilityPreset.name) then
		return abilityPreset.name
	end

	return ClientTextUtils.concatByLanguage(pg.getGameString("ABILITY_PLAN"), pet.curAbilityPreset)
end

function PetManagementDataHelper.getPetInfoTipCarryData(petInfo)
	if petInfo.carryData then
		return Utils.deepCopyTable(petInfo.carryData)
	end

	local pet = petInfo._petInfo
	local petTrainingModel = pg.global.ui.petTrainingNew and pg.global.ui.petTrainingNew.model
	local carryData = pet and petTrainingModel and petTrainingModel:getPetEquipCarry(pet.id)

	if not carryData then
		return nil
	end

	return {
		itemId = carryData.itemId,
		icon = carryData.icon,
		name = carryData.name,
		cLevel = carryData.cLevel,
		quality = carryData.quality,
		isRecommend = LuaUIUtils.checkCarryIsRecommend(pet.id, carryData.itemId),
		assistCarryPosList = Utils.deepCopyTable(carryData.assistCarryPosList),
		assistCarryTypeList = Utils.deepCopyTable(carryData.assistCarryTypeList),
		assistUnlock = Utils.deepCopyTable(carryData.assistUnlock),
		slotUnlockLv = Utils.deepCopyTable(carryData.slotUnlockLv)
	}
end

function PetManagementDataHelper.getPetInfoTipSkillAbilityMap(petInfo, templateData)
	local skillAbilityMap = Utils.deepCopyTable(petInfo.skillAbilityMap)

	if Utils.isTable(skillAbilityMap) and next(skillAbilityMap) ~= nil then
		return skillAbilityMap
	end

	skillAbilityMap = PetManagementDataHelper.createPetInfoTipCurrentSkillAbilityMap(petInfo._petInfo)

	if skillAbilityMap and next(skillAbilityMap) ~= nil then
		return skillAbilityMap
	end

	return PetManagementDataHelper.createPetInfoTipDefaultSkillAbilityMap(templateData)
end

function PetManagementDataHelper.createPetInfoTipCurrentSkillAbilityMap(pet)
	if not pet or not pet.curAbilityMap then
		return nil
	end

	local exploreAbilityMap = pet.exploreAbilityList and pet.exploreAbilityList:getRawTable() or EMPTY_TABLE
	local _, exploreAbilityId = next(exploreAbilityMap)
	local skillAbilityMap = {
		ultimate = PetManagementDataHelper.getPetInfoTipAbilityId(pet.curAbilityMap[AbilityConst.ULTIMATE_ABILITY]),
		q = PetManagementDataHelper.getPetInfoTipAbilityId(pet.curAbilityMap[AbilityConst.WEAPON_SKILL_ABILITY]),
		e = PetManagementDataHelper.getPetInfoTipAbilityId(pet.curAbilityMap[AbilityConst.WEAPON_SKILL_ABILITY2]),
		explore = exploreAbilityId
	}

	return skillAbilityMap
end

function PetManagementDataHelper.getPetInfoTipAbilityId(ability)
	return ability and ability.abilityId or nil
end

function PetManagementDataHelper.createPetInfoTipDefaultSkillAbilityMap(templateData)
	if not templateData or not ToBool(templateData.useTemplateSkills) then
		return nil
	end

	local ActorUtils = require("Common.Utils.ActorUtils")
	local templateBaseId = templateData.templateBaseId
	local configAbilityMap = ActorUtils.genPvpAbility(templateBaseId)
	local petData = PetData[templateBaseId] or {}
	local exploreAbilityList = petData.exploreAbilityList or EMPTY_TABLE

	return {
		ultimate = PetManagementDataHelper.getPetInfoTipDefaultAbilityId(templateBaseId, configAbilityMap, AbilityConst.ULTIMATE_ABILITY),
		q = PetManagementDataHelper.getPetInfoTipDefaultAbilityId(templateBaseId, configAbilityMap, AbilityConst.WEAPON_SKILL_ABILITY),
		e = PetManagementDataHelper.getPetInfoTipDefaultAbilityId(templateBaseId, configAbilityMap, AbilityConst.WEAPON_SKILL_ABILITY2),
		explore = exploreAbilityList[1]
	}
end

function PetManagementDataHelper.getPetInfoTipDefaultAbilityId(templateId, configAbilityMap, abilityType)
	local abilityParamId = configAbilityMap[abilityType]

	if not abilityParamId then
		return nil
	end

	return AbilityUtils.getAbilityIdByParamId(templateId, abilityParamId)
end

function PetManagementDataHelper.getPetInfoTipElementNames(petInfo, petData)
	local petPrototypeId = Utils.getPetPetPrototypeId(petInfo.templateId)
	local prototypeData = PetPrototypeData[petPrototypeId] or {}
	local elementType = prototypeData.elementType or {}
	local _, elementNames = LuaUIUtils.getElementInfo(petData.elementType, ElementNameToId[elementType[1]])

	return elementNames
end

function PetManagementDataHelper.createPetInfoTipBreedTalent(petInfo)
	local breedTalent = Utils.deepCopyTable(petInfo.breedTalent) or {}

	if petInfo.talentList and not petInfo.breedTalent then
		for i = 1, #petInfo.talentList do
			local talentTemplateId = petInfo.talentList[i].templateId
			local talentData = PetTalentData[talentTemplateId]

			if talentData then
				breedTalent[#breedTalent + 1] = {
					name = talentData.talentName,
					icon = talentData.talentIcon,
					quality = talentData.rarity,
					id = talentTemplateId,
					group = talentData.group,
					desc = talentData.dec,
					homeDesc = talentData.homeDesc
				}
			end
		end

		table.sort(breedTalent, PetManagementDataHelper.comparePetInfoTipTalent)
	end

	for i = #breedTalent + 1, 4 do
		breedTalent[i] = {
			empty = true
		}
	end

	return breedTalent
end

function PetManagementDataHelper.comparePetInfoTipTalent(a, b)
	return a.id < b.id
end

function PetManagementDataHelper.getPetInfoTipFeatureData(petInfo, templateData)
	local controlFeatureId = petInfo.controlFeatureId

	if petInfo.characterInfo then
		controlFeatureId = petInfo.characterInfo.curCharacter
	end

	local featureInfo = Utils.deepCopyTable(petInfo.featureInfo)

	if Utils.isTable(featureInfo) and next(featureInfo) ~= nil then
		return controlFeatureId, featureInfo
	end

	if not controlFeatureId or controlFeatureId == 0 then
		controlFeatureId = templateData and templateData.defaultFeature
	end

	local characterData = PetCharacterData[controlFeatureId]

	if characterData then
		featureInfo = {
			rare = characterData.rare or 0,
			desc = characterData.desc,
			name = characterData.name,
			icon = characterData.icon,
			characterId = controlFeatureId
		}
	end

	return controlFeatureId, featureInfo
end

function PetManagementDataHelper.convertTableToPetInfo(petInfoTable)
	if not petInfoTable then
		return nil
	end

	local classType = Utils.isTable(petInfoTable) and rawget(petInfoTable, "__ClassType")

	if classType and classType.typeName == "PetInfo" then
		return petInfoTable
	end

	return PetInfo(petInfoTable)
end

function PetManagementDataHelper.setUpPetInfoByTable(petInfoTable)
	local petInfo = {
		isEmpty = petInfoTable == nil
	}

	if petInfo.isEmpty then
		return petInfo
	end

	local pet = PetManagementDataHelper.convertTableToPetInfo(petInfoTable)

	petInfo = pet:getRawTable()
	petInfo._petInfo = pet
	petInfo.isCatchReportingStatus = false

	local pData = PetData[pet.templateId] or {}

	petInfo.gender = pet.gender

	if pet.customName and pet.customName ~= "" then
		petInfo.name = pet.customName
	else
		petInfo.name = pg.getLocalizationText(pData.name)
	end

	petInfo.iconName = pData.iconName
	petInfo.cp = pet:getCpValue()
	petInfo.maxHp = 100
	petInfo.id = pet.id
	petInfo.label = pet.label
	petInfo.labelScore = PetManagementDataHelper.getLabelScore(pet.label, pet.templateId)
	petInfo.rating = pet:getPropRatingResult()
	petInfo.isBoss = Utils.isLabelElite(pet.label)
	petInfo.isMini = Utils.isLabelRainbow(pet.label)
	petInfo.isShiny = Utils.isLabelShiny(pet.label)
	petInfo.isVariant = Utils.isLabelVariant(pet.label)
	petInfo.isVariantInteractPet = pet.isVariantInteractPet
	petInfo.isRainbow = Utils.isRainbowTypeByTemplateId(pet.templateId)
	petInfo.isBlackRainbow = Utils.isBlackRainbowTypeByTemplateId(pet.templateId)
	petInfo.isDark = Utils.isLabelDark(pet.label)
	petInfo.labelInfo = {}
	petInfo.race = pData.species
	petInfo.nature = PetNatureData[pet.nature].name
	petInfo.maxExp = PetLevelData[math.min(pet.level + 1, table.maxn(PetLevelData))].needExp

	local petPrototypeId = Utils.getPetPetPrototypeId(pet.templateId)
	local prototypeData = PetPrototypeData[petPrototypeId] or {}
	local elementType = prototypeData.elementType or {}
	local elementIds, elementNames = LuaUIUtils.getElementInfo(pData.elementType, ElementNameToId[elementType[1]])

	petInfo.elementIds = elementIds
	petInfo.elementNames = elementNames
	petInfo.elementType = pData.elementType
	petInfo.time = pet.time
	petInfo.reverseTime = -pet.time
	petInfo.level = pet.level
	petInfo.templateId = pet.templateId
	petInfo.isFavorite = pet.isFavorite
	petInfo.inBattle = false
	petInfo.inExplore = false
	petInfo.customName = pet.customName
	petInfo.fetter = pet.fetter
	petInfo.height = pet.height
	petInfo.weight = pet.weight
	petInfo.canEvolve = false

	local petType = pData.functionId

	petInfo.petType = petType
	petInfo.petTypeUrl = PetConfigData.petFunctionIcon[petType]
	petInfo.exploreSkillsLevel = {
		canClimb = pData.canClimb ~= nil and pData.canClimb or nil,
		canGlide = pData.canGlide ~= nil and pData.canGlide or nil,
		canSwim = pData.canSwim ~= nil and pData.canSwim or nil
	}
	petInfo.climbLevel = petInfo.exploreSkillsLevel.canClimb or 0
	petInfo.glideLevel = petInfo.exploreSkillsLevel.canGlide or 0
	petInfo.swimLevel = petInfo.exploreSkillsLevel.canSwim or 0
	petInfo.exploreSkillIndexLevel = {
		petInfo.climbLevel,
		petInfo.glideLevel,
		petInfo.swimLevel
	}
	petInfo.bookNum = PetResearchIdToNumber[pet.templateId] or 999
	petInfo.ethnicGroup = pData.ethnicGroup

	if petInfo.characterInfo then
		local controlFeatureId = petInfo.characterInfo.curCharacter
		local featureInfo = PetCharacterData[controlFeatureId]

		if featureInfo then
			petInfo.featureInfo = {
				rare = featureInfo.rare or 0,
				desc = featureInfo.desc,
				name = featureInfo.name,
				icon = featureInfo.icon,
				characterId = controlFeatureId
			}
			petInfo.hasRareFeature = featureInfo.rare == 1 and 1 or 0
		else
			petInfo.featureInfo = featureInfo
			petInfo.hasRareFeature = 0
		end
	else
		petInfo.featureInfo = {}
		petInfo.hasRareFeature = 0
	end

	petInfo.breedTalent = {}

	local talentList = petInfo.talentList

	if talentList then
		for i = 1, #talentList do
			local talentTemplateId = talentList[i].templateId
			local talentData = talentTemplateId and PetTalentData[talentTemplateId]

			if talentData then
				petInfo.breedTalent[#petInfo.breedTalent + 1] = {
					name = talentData.talentName,
					icon = talentData.talentIcon,
					quality = talentData.rarity,
					id = talentTemplateId,
					group = talentData.group,
					desc = talentData.dec,
					homeDesc = talentData.homeDesc
				}
			end
		end

		table.sort(petInfo.breedTalent, function(a, b)
			return a.id < b.id
		end)
	end

	for i = #petInfo.breedTalent + 1, 4 do
		petInfo.breedTalent[i] = {
			empty = true
		}
	end

	petInfo.exploreSlotIndex = -1
	petInfo.highestExploreSkillLevel = math.max(petInfo.climbLevel, petInfo.glideLevel, petInfo.swimLevel)

	if petInfo.climbLevel > 0 then
		petInfo.exploreIndex = 2
	elseif petInfo.glideLevel > 0 then
		petInfo.exploreIndex = 1
	elseif petInfo.swimLevel > 0 then
		petInfo.exploreIndex = 0
	else
		petInfo.exploreIndex = -1
	end

	local nextLevelData = PetLevelData[pet.level + 1]
	local nextLevelExp = nextLevelData and nextLevelData.needExp or 0

	petInfo.expRate = nextLevelExp > 0 and petInfo.exp / nextLevelExp or 0

	return petInfo
end

function PetManagementDataHelper.setUpPetInfo(pet)
	local petInfo = {}

	petInfo.isEmpty = pet == nil

	if petInfo.isEmpty then
		return petInfo
	end

	petInfo = pet:getRawTable()
	petInfo._petInfo = pet
	petInfo.isCatchReportingStatus = pet:isCatchReporting()

	local pData = PetData[pet.templateId] or {}

	petInfo.gender = pet.gender
	petInfo.name = PetManagementDataHelper.getPetName(pet.id)
	petInfo.iconName = pData.iconName

	local cp = PetManagementDataHelper.getCpValue(pet.id)

	petInfo.cp = cp
	petInfo.maxHp = 100

	local labelInfo = {}

	petInfo.id = pet.id
	petInfo.label = pet.label
	petInfo.labelScore = PetManagementDataHelper.getLabelScore(pet.label, pet.templateId)
	petInfo.rating = pet:getPropRatingResult()
	petInfo.isBoss = Utils.isLabelElite(pet.label)
	petInfo.isMini = Utils.isLabelRainbow(pet.label)
	petInfo.isShiny = Utils.isLabelShiny(pet.label)
	petInfo.isDark = Utils.isLabelDark(pet.label)
	petInfo.isVariant = Utils.isLabelVariant(pet.label)
	petInfo.isVariantInteractPet = pet.isVariantInteractPet
	petInfo.isRainbow = Utils.isRainbowTypeByTemplateId(pet.templateId)
	petInfo.isBlackRainbow = Utils.isBlackRainbowTypeByTemplateId(pet.templateId)
	petInfo.labelInfo = labelInfo
	petInfo.race = pData.species
	petInfo.nature = PetNatureData[pet.nature].name
	petInfo.maxExp = PetLevelData[math.min(pet.level + 1, table.maxn(PetLevelData))].needExp

	local petPrototypeId = Utils.getPetPetPrototypeId(pet.templateId)
	local prototypeData = PetPrototypeData[petPrototypeId] or {}
	local elementType = prototypeData.elementType or {}
	local elementIds, elementNames = LuaUIUtils.getElementInfo(pData.elementType, ElementNameToId[elementType[1]])

	petInfo.elementIds = elementIds
	petInfo.elementNames = elementNames
	petInfo.elementType = pData.elementType
	petInfo.time = pet.time
	petInfo.reverseTime = -pet.time
	petInfo.level = pet.level
	petInfo.templateId = pet.templateId
	petInfo.isFavorite = pet.isFavorite
	petInfo.inBattle = pg.game.petManage:getPetIsInBattle(pet.id)
	petInfo.inExplore = Lume.find(pg.me.prepareFormationList[1].exploreFormation, pet.id) ~= nil
	petInfo.isPutInHomeland = pg.me:isPetPutInHomeland(pet)
	petInfo.customName = pet.customName
	petInfo.fetter = pet.fetter
	petInfo.height = pet.height
	petInfo.weight = pet.weight
	petInfo.templateId = pet.templateId
	petInfo.canEvolve = pet:canEvolveAny()

	local petType = PetData[pet.templateId].functionId

	petInfo.petType = petType
	petInfo.petTypeUrl = PetConfigData.petFunctionIcon[petType]
	petInfo.exploreSkillsLevel = {
		canClimb = pData.canClimb ~= nil and pData.canClimb or nil,
		canGlide = pData.canGlide ~= nil and pData.canGlide or nil,
		canSwim = pData.canSwim ~= nil and pData.canSwim or nil
	}
	petInfo.climbLevel = petInfo.exploreSkillsLevel.canClimb or 0
	petInfo.glideLevel = petInfo.exploreSkillsLevel.canGlide or 0
	petInfo.swimLevel = petInfo.exploreSkillsLevel.canSwim or 0
	petInfo.exploreSkillIndexLevel = {}
	petInfo.exploreSkillIndexLevel[1] = petInfo.climbLevel
	petInfo.exploreSkillIndexLevel[2] = petInfo.glideLevel
	petInfo.exploreSkillIndexLevel[3] = petInfo.swimLevel

	local num = 999

	if PetResearchIdToNumber[pet.templateId] then
		num = PetResearchIdToNumber[pet.templateId]
	end

	petInfo.bookNum = num
	petInfo.ethnicGroup = pData.ethnicGroup

	if petInfo.characterInfo then
		local controlFeatureId = petInfo.characterInfo.curCharacter
		local featureInfo = PetCharacterData[controlFeatureId]

		if featureInfo then
			petInfo.featureInfo = {
				rare = featureInfo.rare or 0,
				desc = featureInfo.desc,
				name = featureInfo.name,
				icon = featureInfo.icon,
				characterId = controlFeatureId
			}
			petInfo.hasRareFeature = featureInfo.rare == 1 and 1 or 0
		else
			petInfo.featureInfo = featureInfo
			petInfo.hasRareFeature = 0
		end
	else
		petInfo.featureInfo = {}
		petInfo.hasRareFeature = 0
	end

	petInfo.breedTalent = {}

	local talentList = petInfo.talentList

	if talentList then
		for i = 1, #talentList do
			local talentTemplateId = talentList[i].templateId

			if talentTemplateId and PetTalentData[talentTemplateId] then
				local name = PetTalentData[talentTemplateId].talentName
				local icon = PetTalentData[talentTemplateId].talentIcon
				local quality = PetTalentData[talentTemplateId].rarity
				local id = talentTemplateId
				local group = PetTalentData[talentTemplateId].group
				local desc = PetTalentData[talentTemplateId].dec
				local homeDesc = PetTalentData[talentTemplateId].homeDesc

				petInfo.breedTalent[#petInfo.breedTalent + 1] = {
					name = name,
					icon = icon,
					quality = quality,
					id = id,
					group = group,
					desc = desc,
					homeDesc = homeDesc
				}
			end
		end

		table.sort(petInfo.breedTalent, function(a, b)
			return a.id < b.id
		end)
	end

	for i = #petInfo.breedTalent + 1, 4 do
		petInfo.breedTalent[i] = {
			empty = true
		}
	end

	local slot = PetManagementDataHelper.checkPetInWhichExploreSlot(pet.id) or 4

	petInfo.exploreSlotIndex = 3 - slot
	petInfo.highestExploreSkillLevel = math.max(table.unpack({
		petInfo.climbLevel,
		petInfo.glideLevel,
		petInfo.swimLevel
	}))

	if petInfo.climbLevel > 0 then
		petInfo.exploreIndex = 2
	elseif petInfo.glideLevel > 0 then
		petInfo.exploreIndex = 1
	elseif petInfo.swimLevel > 0 then
		petInfo.exploreIndex = 0
	else
		petInfo.exploreIndex = -1
	end

	local nLv = pet.level + 1
	local nLvData = PetLevelData[nLv]

	if nLvData then
		petInfo.expRate = petInfo.exp / (nLvData.needExp or 0)
	else
		petInfo.expRate = 0
	end

	return petInfo
end

function PetManagementDataHelper.checkPetInWhichExploreSlot(petId)
	local explorePets = PetManagementDataHelper.getPetExploreGroupPetsInModel()

	for i = 1, #explorePets do
		if explorePets[i] == petId then
			return i
		end
	end

	return nil
end

function PetManagementDataHelper.getPetExploreGroupPetsInModel()
	local groupId = 1
	local groupInfo = pg.me.prepareFormationList[groupId] or {}
	local petIds = groupInfo.exploreFormation or {}

	petIds = petIds:getRawTable()

	local ret = {}

	if #petIds <= 0 then
		for _ = 1, PetManagementDataHelper.MAX_EXPLORE_PETS_COUNT do
			ret[#ret + 1] = ""
		end
	else
		for _, petId in pairs(petIds) do
			ret[#ret + 1] = petId
		end
	end

	return ret
end

function PetManagementDataHelper.getExploreGroupInfo()
	local petIds = PetManagementDataHelper.getPetExploreGroupPetsInModel()
	local player = pg.me
	local ret = {}

	for _, petId in pairs(petIds) do
		local pet, petInfo

		if petId == "" then
			petInfo = {}
			petInfo.empty = true
		else
			pet = player:getPetInfo(petId)
			petInfo = PetManagementDataHelper.setUpPetInfo(pet)
			petInfo.empty = false
		end

		ret[#ret + 1] = petInfo
	end

	return ret
end

function PetManagementDataHelper.getPetGroupPetsInModel(groupId)
	local groupInfo = pg.me.prepareFormationList[groupId] or {}
	local petIds = groupInfo.formation or {}

	return petIds:getRawTable()
end

function PetManagementDataHelper.getGroupInfoById(groupId)
	if groupId > Const.MAX_FORMATION_COUNT then
		return
	end

	local petIds = PetManagementDataHelper.getPetGroupPetsInModel(groupId)
	local player = pg.me
	local ret = {}

	for idx, petId in pairs(petIds) do
		local pet = player:getPetInfo(petId)
		local petInfo = PetManagementDataHelper.setUpPetInfo(pet)

		petInfo.index = idx
		petInfo.empty = false
		ret[#ret + 1] = petInfo
	end

	return ret
end

function PetManagementDataHelper.getSelectGroupId()
	if not PetManagementDataHelper.selectGroupId then
		PetManagementDataHelper.selectGroupId = pg.me.curPetFormationIndex
	end

	return PetManagementDataHelper.selectGroupId
end

function PetManagementDataHelper.getPetGroupPetsInModelByIndex(index)
	local petInfos = PetManagementDataHelper.getGroupInfoById(PetManagementDataHelper.getSelectGroupId())

	if petInfos[index] == nil then
		return nil
	end

	return petInfos[index].id
end

function PetManagementDataHelper.checkExposeFilter(filters)
	return filters and (filters.isRating1 or filters.isRating2 or filters.isRating3 or filters.isRating4) or false
end

function PetManagementDataHelper.getFilteredPetsInfo()
	PetManagementDataHelper.filterTempProcess(PetManagementDataHelper.filter)

	local tempFilter = Utils.deepCopyTable(PetManagementDataHelper.filter)
	local petBoxMap = pg.me.petBoxMap
	local pets = pg.me.pets
	local count = 1
	local ret = {}
	local excludeIds = PetManagementDataHelper.excludePetIds
	local recordFilter = PetManagementDataHelper.recordFilter and PetManagementDataHelper.recordFilter[PetManagementDataHelper.filter.filterType]
	local hasRatingFilter = PetManagementDataHelper.checkExposeFilter(recordFilter)

	for i = 1, #petBoxMap do
		local box = petBoxMap[i]
		local maxSlotCount = box.slotCount

		for j = 1, maxSlotCount do
			local boxPetId = box[j]
			local pet = pets[boxPetId]

			if pet ~= nil and (not excludeIds or not excludeIds[pet.id]) then
				local valid

				if PetManagementDataHelper.intelligentFilterPredicate then
					valid = PetManagementDataHelper.intelligentFilterPredicate(pet)
				else
					valid = PetManagementDataHelper.checkPetValidByFilter(pet, tempFilter)
				end

				if valid then
					local petInfo = PetManagementDataHelper.setUpPetInfo(pet)

					if not petInfo.isCatchReportingStatus or not hasRatingFilter then
						ret[count] = petInfo
						count = count + 1
					end
				end
			end
		end
	end

	ret = PetManagementDataHelper.sortTableBySortConditions(ret, PetManagementDataHelper.recordFilter[PetManagementDataHelper.filter.filterType])

	if #ret < PetManagementDataHelper.FULL_PAGE_SLOT_COUNT then
		for _ = #ret, PetManagementDataHelper.FULL_PAGE_SLOT_COUNT - 1 do
			ret[#ret + 1] = {
				isEmpty = true,
				tIndex = 1
			}
		end
	else
		local mod = #ret % PetManagementDataHelper.FULL_ROW_SLOT_COUNT

		if mod ~= 0 then
			local a = math.floor(#ret / PetManagementDataHelper.FULL_ROW_SLOT_COUNT)

			for _ = 1, (a + 1) * PetManagementDataHelper.FULL_ROW_SLOT_COUNT - #ret do
				ret[#ret + 1] = {
					isEmpty = true,
					tIndex = 1
				}
			end
		end
	end

	PetManagementDataHelper.filterTempProcess(PetManagementDataHelper.filter, true)

	return ret
end

function PetManagementDataHelper.getBoxInfoById(boxId)
	local petBoxMap = pg.me.petBoxMap

	if boxId > #petBoxMap then
		return
	end

	local sortCondition = PetManagementDataHelper.getSelectSortId()
	local excludeIds = PetManagementDataHelper.excludePetIds

	if sortCondition == 0 then
		local box = petBoxMap[boxId]
		local maxSlotCount = box.slotCount
		local pets = pg.me.pets
		local ret = {}

		for i = 1, maxSlotCount do
			local boxPetId = box[i]
			local pet = pets[boxPetId]

			if pet ~= nil and excludeIds and excludeIds[pet.id] then
				ret[i] = PetManagementDataHelper.setUpPetInfo(nil)
			else
				ret[i] = PetManagementDataHelper.setUpPetInfo(pet)
			end
		end

		ret = PetManagementDataHelper.sortTableBySortConditions(ret)

		return ret
	else
		local pets = pg.me.pets
		local count = 1
		local ret = {}

		for i = 1, #petBoxMap do
			local box = petBoxMap[i]
			local maxSlotCount = box.slotCount

			for j = 1, maxSlotCount do
				local boxPetId = box[j]
				local pet = pets[boxPetId]

				if pet ~= nil and (not excludeIds or not excludeIds[pet.id]) then
					local petInfo = PetManagementDataHelper.setUpPetInfo(pet)

					ret[count] = petInfo
					count = count + 1
				end
			end
		end

		ret = PetManagementDataHelper.sortTableBySortConditions(ret)

		return ret
	end
end

function PetManagementDataHelper.getBoxInfos()
	local boxInfos = {}
	local petBoxMapSequence = pg.me.petBoxMap.sequence:getRawTable()

	for idx = 1, #petBoxMapSequence do
		local boxInfo = PetManagementDataHelper.getBoxNameInfo(petBoxMapSequence[idx])

		boxInfos[idx] = boxInfo
	end

	return boxInfos
end

function PetManagementDataHelper.getIndividualLevel(petId)
	local pet = pg.me:getPetInfo(petId)

	if not pet then
		return {}
	end

	local baseProperty = pet.basePropertyList
	local templateId = pet.templateId
	local petData = PetData[templateId]

	if not petData then
		return {}
	end

	local recommend = petData.recommend_attr
	local ret = {}

	for i = Const.BASE_PROPERTY_HP_IDX, Const.BASE_PROPERTY_ATK_MAG_IDX do
		local property = baseProperty[i]
		local item = {
			baseLv = property:getBaseIndividualLevel(),
			indLv = property.indLv,
			iLvLn = property.iLvLn,
			individualLevelMax = PetPropLevelMaxData[i],
			isRecommend = LuaUIUtils.tableContains(recommend, i)
		}

		for j, v in pairs(PetDetailPropertyData) do
			local cData = v and v[1]

			if cData and cData.basePropIndex == i then
				item.name = pg.getLocalizationText(cData.propName)
				item.tIcon = string.sub(cData.icon, 2, string.len(cData.icon) - 4)
			end
		end

		ret[i] = item
	end

	return ret
end

function PetManagementDataHelper.checkRarity(data, filter)
	local count = 0

	if filter.isNormal and not data.isShiny and not data.isBoss and not data.isRainbow and not data.isBlackRainbow and not data.isDark then
		count = count + 1
	end

	if filter.isShiny and data.isShiny then
		count = count + 1
	end

	if filter.isBoss and data.isBoss then
		count = count + 1
	end

	if filter.isRainbow and (data.isRainbow or data.isBlackRainbow) then
		count = count + 1
	end

	if filter.isDark and data.isDark then
		count = count + 1
	end

	return count
end

function PetManagementDataHelper.checkElement(data, filter)
	local count = 0
	local pData = PetData[data.templateId] or {}
	local _, elementNames = LuaUIUtils.getElementInfo(pData.elementType)

	for i = 1, #elementNames do
		if filter.elements[elementNames[i].element] then
			count = count + 1
		end
	end

	return count
end

function PetManagementDataHelper.checkStatus(data, filter)
	local count = 0

	if filter.isInBattle and data.inBattle then
		count = count + 1
	end

	if filter.isNotInBattle and not data.inBattle then
		count = count + 1
	end

	if filter.isInExplore and data.inExplore then
		count = count + 1
	end

	if filter.isInHomeland and data.isPutInHomeland then
		count = count + 1
	end

	return count
end

function PetManagementDataHelper.containsAtLeastOneRarePet(petIds)
	local petInfos = {}

	for petId, _ in pairs(petIds) do
		petInfos[#petInfos + 1] = PetManagementDataHelper.setUpPetInfo(pg.me:getPetInfo(petId))
	end

	local function isRare(petInfo)
		return petInfo.isShiny or petInfo.isRainbow or petInfo.isBlackRainbow or petInfo.isVariant or petInfo.isBoss or petInfo.rating and petInfo.rating >= 2 or petInfo.hasRareFeature == 1
	end

	for _, petInfo in pairs(petInfos) do
		if isRare(petInfo) then
			return true
		end
	end

	return false
end

PetManagementDataHelper.RESONANCE_STATE = {
	MAXED = 3,
	WAIT_MAX_UP = 2,
	WAIT_MIN_UP = 1,
	NORMAL = 0
}
PetManagementDataHelper.TrainingConfig = {
	UISliderSectionCount = 5
}

local BoxTemp2Notice = {
	[Const.BOX_TEMP_LOCKED] = NoticeDef.BATTLEPASS_PET_BOX_LOCKED
}

function PetManagementDataHelper.sendSwitchPetBoxManualLocked(boxId, popupFunc)
	local boxPetInfo = pg.me.petBoxMap[boxId]

	if not boxPetInfo then
		return
	end

	local noticeId = PetManagementDataHelper.getTempLockPetBoxNoticeId(boxId)

	if noticeId and noticeId > 0 then
		pg.global.showBubbleMessageById(noticeId)

		return
	end

	if boxPetInfo:isManualLocked() == true then
		pg.me:serverMsg("RPC_CS_PetBoxSwitchLocked", boxId, not boxPetInfo:isManualLocked())
	elseif popupFunc then
		popupFunc()
	end
end

function PetManagementDataHelper.getTempLockPetBoxNoticeId(boxId)
	local petBoxInfo = pg.me.petBoxMap[boxId]

	if not petBoxInfo then
		return
	end

	local tempStatus = petBoxInfo.tempStatus or 0

	return BoxTemp2Notice[tempStatus]
end

PetManagementDataHelper.BoxLockState = {
	TEMP_LOCKED = 2,
	LOCKED = 1,
	UNLOCKED = 0
}

local function getItemTipInstance(invId, genID)
	local itemBag = invId and ItemUtils.getTypedBag(pg.me, invId)

	if not itemBag or not genID then
		return nil
	end

	if itemBag.get then
		return itemBag:get(genID)
	end

	return itemBag[genID]
end

local function getItemTipLockStatus(item, fallback)
	if item then
		if item.isStatusLocked then
			return item:isStatusLocked()
		end

		if item.hasStatus then
			return item:hasStatus(ItemConst.ITEM_STATUS_LOCKED)
		end
	end

	return fallback or false
end

function PetManagementDataHelper.refreshItemTipLockStatus(uWidget, param, isLocked)
	if not param then
		return
	end

	param.isLocked = isLocked

	if uWidget and (NotNil == nil or NotNil(uWidget)) then
		uWidget:TryChangePage("Lock", isLocked and 1 or 0)
	end
end

function PetManagementDataHelper.refreshItemTipLockStatusFromInventory(uWidget, param)
	if not param or param.invId == nil or param.genID == nil then
		return
	end

	local item = getItemTipInstance(param.invId, param.genID)

	if not item then
		return
	end

	local isLocked = getItemTipLockStatus(item, param.isLocked)

	PetManagementDataHelper.refreshItemTipLockStatus(uWidget, param, isLocked)
end

function PetManagementDataHelper.switchItemTipLockStatus(uWidget, param)
	if not param or param.invId == nil or param.genID == nil then
		return
	end

	local item = getItemTipInstance(param.invId, param.genID)

	if not item then
		return
	end

	local isLocked = not getItemTipLockStatus(item, param.isLocked)

	pg.me:serverMsg("RPC_CS_ModifyItemStatus", param.invId, {
		param.genID
	}, ItemConst.ITEM_STATUS_LOCKED, isLocked, function(retCode)
		if retCode then
			PetManagementDataHelper.refreshItemTipLockStatus(uWidget, param, isLocked)
		end
	end)
end

function PetManagementDataHelper.refreshPetModelAppearance(entity, petTId, extraData)
	if not entity or not entity.eModel then
		return
	end

	extraData = extraData or EMPTY_TABLE

	local ClientModelUtils = require("Utils.ClientModelUtils")
	local realPetId = extraData.realPetId or extraData.isCreateEntUsePetId and extraData.petId

	if extraData.clearJewelryInfo or extraData.useTempJewelrySnapshot then
		entity.realPetId = nil
		entity.petJewelryInfo = nil
		entity.tempJewelryInfo = extraData.useTempJewelrySnapshot and extraData.appearanceData or nil
		entity.useTempJewelrySnapshot = extraData.useTempJewelrySnapshot == true
	elseif realPetId then
		entity.realPetId = realPetId
		entity.petJewelryInfo = nil
		entity.tempJewelryInfo = pg.me.petJewelryInfos[realPetId]
		entity.useTempJewelrySnapshot = false
	end

	local sourcePetInfo = extraData.petInfo or extraData.isCreateEntUsePetId and pg.me.pets[extraData.petId]
	local configData = extraData.configData or entity:getConfigData()
	local label = extraData.label or sourcePetInfo and sourcePetInfo.label or 0
	local gender = extraData.gender or sourcePetInfo and sourcePetInfo.gender or 0
	local shinyStyle = extraData.shinyStyle or sourcePetInfo and sourcePetInfo.shinyStyle or 0
	local shinyEffectReplace = extraData.shinyEffectReplace or sourcePetInfo and sourcePetInfo.shinyEffectReplace
	local transmogPetId = extraData.transmogPetId or extraData.isCreateEntUsePetId and extraData.petId
	local transmogScheme = extraData.transmogScheme

	if transmogPetId then
		transmogScheme = PetTransmogUtils.getSelectedScheme(pg.me:getPetInfo(transmogPetId))
	end

	if Utils.isLabelShiny(entity.label) and (entity.label ~= label or (entity.shinyStyle or 0) ~= shinyStyle or entity.templateId ~= petTId) then
		entity:clearPetShinyAppearance()
	end

	entity:setConfigData(configData)

	entity.templateId = petTId
	entity.label = label
	entity.gender = gender
	entity.shinyStyle = shinyStyle
	entity.petInfo = (sourcePetInfo or not string.isNilOrEmpty(shinyEffectReplace)) and {
		templateId = petTId,
		label = label,
		gender = gender,
		shinyStyle = shinyStyle,
		shinyEffectReplace = shinyEffectReplace,
		selectTransmogScheme = transmogScheme
	} or nil
	entity.selectTransmogScheme = transmogScheme

	local dyeRefreshVersion = entity.parmonDyeRefreshVersion

	if transmogPetId then
		PetTransmogUtils.applyAppliedTransmog(entity, transmogPetId, true)
	elseif extraData.useTransmogScheme or transmogScheme then
		PetTransmogUtils.applySchemeTransmog(entity, petTId, transmogScheme, true, extraData.useTemplateFallback)
	end

	local modelView = entity.eModel.modelModelView
	local displayLabel = PetTransmogUtils.getDisplayLabel(petTId, label)
	local appearance = ClientModelUtils.getModelExtraInfo(configData, displayLabel, gender, extraData.canAttachEffs, nil, entity.petInfo)

	appearance.modelNeedBones = extraData.modelNeedBones

	entity:postComponentMethod("EVENT_OnMergeAppearanceData", configData, appearance)
	ClientModelUtils.applyModelAppearance(modelView.modelInfo, configData, appearance)

	modelView.modelInfo.physiqueModelInfo.isAlwaysAnimate = true

	entity:postComponentMethod("Event_BeforeRefreshModels", modelView)

	if extraData.applyAnimController then
		ClientModelUtils.applyAnimController(entity, entity.eModel, configData)
	end

	ClientModelUtils.refreshModels(entity, modelView)
	entity:attachBaseEffects(appearance.attachEffects, entity.isIgnoreEffectLod)

	if modelView.firstLoaded and entity.parmonDyeRefreshVersion == dyeRefreshVersion then
		ClientModelUtils.applyModelSwitchTag(entity)
		entity:refreshParmonDye()
	end

	entity:setModelLayer(ClientConst.LayerDefine.LAYER_UI_SCENE)
end

function PetManagementDataHelper.previewPetModel(petTId, parentTransform, injectResultFunc, extraData)
	if not petTId or petTId == 0 then
		return
	end

	local existEntity = extraData and extraData.existEntity
	local isCreateEntUsePetId = extraData and extraData.isCreateEntUsePetId
	local isCreateEntUsePetInfo = extraData and extraData.isCreateEntUsePetInfo
	local createPetId = extraData and extraData.petId
	local entity = existEntity
	local PetFirstShowData = require("Data.pet_first_show_data")
	local PetResearchUtils = require("Guis.Utils.PetResearchUtils")
	local referencePetTId = Utils.getRefIdByPetPrototypeId(petTId)
	local showData = PetFirstShowData[referencePetTId]
	local contentData = PetResearchUtils.getPetResearchContent(petTId)

	if not contentData and referencePetTId ~= petTId then
		contentData = PetResearchUtils.getPetResearchContent(referencePetTId)
	end

	local scaleFT = showData and showData.scaleFT or 1
	local offset = showData and showData.offset or {
		0,
		0,
		0
	}
	local scale = contentData and contentData.scale or 1
	local fixedScale = scaleFT * scale
	local appearance = extraData and extraData.appearance
	local appearanceData = extraData and extraData.appearanceData
	local petInfo = extraData and extraData.petInfo
	local label = extraData and extraData.label or petInfo and petInfo.label
	local shinyStyle = extraData and extraData.shinyStyle or petInfo and petInfo.shinyStyle
	local gender = extraData and extraData.gender or petInfo and petInfo.gender

	if not entity then
		local ClientVirtualEntityUtils = require("Utils.ClientVirtualEntityUtils")

		if isCreateEntUsePetInfo or petInfo and not isCreateEntUsePetId then
			if appearanceData == nil and not string.isNilOrEmpty(appearance) then
				appearanceData = string.toTable(decompressFromStr(appearance))
			end

			entity = ClientVirtualEntityUtils.createPetVirtualEntityWithDic(petTId, appearanceData, label, shinyStyle, gender, nil, petInfo)
		elseif isCreateEntUsePetId then
			entity = ClientVirtualEntityUtils.createPetVirtualEntityWithPetId(createPetId)
		else
			entity = ClientVirtualEntityUtils.createPetVirtualEntity(petTId, appearance, label, shinyStyle)
		end
	end

	if entity then
		entity.eModel:SetTransformParent(parentTransform)
		entity.eModel:SetTransformLocalPosition()
		entity.eModel:SetTransformLocalRotation(0, 0, 0, 1)
		entity.eModel:SetTransformLocalPosition(offset[1], offset[2], offset[3])
		entity:setScaleNumber(fixedScale)
		PetManagementDataHelper.refreshPetModelAppearance(entity, petTId, extraData)

		if injectResultFunc then
			injectResultFunc(entity)
		end
	end

	return entity
end

function PetManagementDataHelper.getPetHandbookMat()
	if IS_MOBILE then
		return AddressDataConst.UI_HANDBOOK_EVOLVE_UNKNOWN_MAT_MOBILE
	end

	return AddressDataConst.UI_HANDBOOK_EVOLVE_UNKNOWN_MAT
end

function PetManagementDataHelper.tryChangePetHeadBossTagPage(uButton, label)
	if IsNil(uButton) then
		return
	end

	uButton:TryChangePage("isBoss", 0)
end

function PetManagementDataHelper.getPetSkillMainElementId(petId)
	local petInfo = pg.me:getPetInfo(petId)

	if not petInfo then
		return
	end

	local skillData = PetSkillData[Utils.getRefIdByPetPrototypeId(petInfo.petPrototypeId)]

	if not skillData then
		return
	end

	local sortedSkillIds = {}

	for skillId in pairs(skillData) do
		table.insert(sortedSkillIds, skillId)
	end

	table.sort(sortedSkillIds)

	local normalSkillId

	for _, skillId in ipairs(sortedSkillIds) do
		local skillInfo = skillData[skillId]

		if skillInfo.abilityType == "ultimate" then
			local abilityParam = AbilityParamData[skillId]

			return abilityParam and abilityParam.elementType
		elseif not normalSkillId and skillInfo.abilityType == "normal" then
			normalSkillId = skillId
		end
	end

	if normalSkillId then
		local abilityParam = AbilityParamData[normalSkillId]

		return abilityParam and abilityParam.elementType
	end
end

function PetManagementDataHelper.getPetUnlockedSkillElementIdSet(petId)
	local elementTypeIds = {}
	local petInfo = pg.me:getPetInfo(petId)

	if not petInfo or not petInfo.unlockedAbilityMap then
		return elementTypeIds
	end

	for abilityParamId, _ in pairs(petInfo.unlockedAbilityMap) do
		local abilityParam = AbilityParamData[abilityParamId]
		local elementType = abilityParam and abilityParam.elementType

		if elementType and elementType ~= 0 then
			elementTypeIds[elementType] = true
		end
	end

	return elementTypeIds
end

function PetManagementDataHelper.setBoxSelectorLuaRenderPopup(boxSelector, options)
	if IsNil(boxSelector) then
		return
	end

	options = options or EMPTY_TABLE

	local boxInfos = options.boxInfos
	local boxNameContent = options.boxNameContent
	local selectBoxId = options.selectBoxId
	local isHideLockIcon = options.isHideLockIcon
	local canInteract = options.canInteract

	local function checkInteract()
		return canInteract == nil or canInteract() == true
	end

	function boxSelector.luaRenderPopup(popup, list)
		if options.onRenderPopup then
			options.onRenderPopup(popup, list)
		end

		local objectReference1 = popup:GetComponent("ObjectReference")
		local boxNameUText = objectReference1:GetRefValue("boxNameUText")

		ClientTextUtils.setText(boxNameUText, boxNameContent)

		function list.luaRenderItem(button, _, data)
			local objectReference = button:GetComponent("ObjectReference")
			local numUText = objectReference:GetRefValue("numUText")
			local nameUText = objectReference:GetRefValue("nameUText")
			local lockUButton1 = objectReference:GetRefValue("lockUButton1")
			local btnEditUButton = objectReference:GetRefValue("btnEditUButton")

			if options.renderItemLockState then
				options.renderItemLockState(button, lockUButton1, data.idx)
			end

			if isHideLockIcon ~= nil then
				button:TryChangePage("hideLockIcon", isHideLockIcon and 1 or 0)
				TimerManager.addNextFrameCb(function()
					if NotNil(btnEditUButton) then
						btnEditUButton:SetActive(not isHideLockIcon)
					end
				end)
			end

			ClientTextUtils.setText(numUText, data.countNum)

			if data.customName and data.customName ~= "" then
				ClientTextUtils.setText(nameUText, data.customName)
			else
				ClientTextUtils.setText(nameUText, pg.getGameString("DEFAULT_PET_BOX_NAME") .. " " .. data.idx)
			end

			function button.luaClick()
				if not checkInteract() then
					return
				end

				if options.onSelectBox then
					options.onSelectBox(data.idx)
				end
			end

			if isHideLockIcon then
				lockUButton1.luaClick = nil
				btnEditUButton.luaClick = nil
			else
				function lockUButton1.luaClick()
					if not checkInteract() then
						return
					end

					if options.onLockBox then
						options.onLockBox(data.idx)
					end
				end

				function btnEditUButton.luaClick()
					if not checkInteract() then
						return
					end

					if options.onRenameBox then
						options.onRenameBox(data.idx)
					end
				end
			end

			if options.onRenderItemExtra then
				options.onRenderItemExtra(data.idx, button)
			end

			local boxNoTs = button.transform and button.transform:Find("Item/Icon/PetNum")
			local boxNoUSDFText = boxNoTs and boxNoTs:GetComponent("USDFText")

			if NotNil(boxNoUSDFText) then
				ClientTextUtils.setText(boxNoUSDFText, tostring(data.idx))
			end
		end

		function list.luaFinishRender(subList)
			local btns = subList:GetAllButtons()

			for i = 0, btns.Length - 1 do
				local isSelected = btns[i].dataFromUList.idx == selectBoxId

				btns[i]:TryChangePage("button", isSelected and 5 or 0)

				if isSelected and options.selectItemOnFinishRender then
					subList:SelectItem(i)
				end
			end
		end

		list:SetList(boxInfos)
	end
end

return PetManagementDataHelper
