-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Utils\\BiLogBasicUtils.lua

local AbilityConst = require("Common.Const.AbilityConst")
local AttributeConst = require("Common.Const.AttributeConst")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local PetAttributeCalcUtils = require("Common.Utils.PetAttributeCalcUtils")
local lume = require("Core.Common.lume")
local BiLogBasicUtils = {}

function BiLogBasicUtils:BuildPetInfoByPetInfo(player, petInfoSrc)
	if not player or not petInfoSrc then
		return nil
	end

	local petInfo = {}
	local attributeMap = PetAttributeCalcUtils.getAttributeMapByPetInfo(player, petInfoSrc)

	petInfo.pet_uid = petInfoSrc.id
	petInfo.pet_id = petInfoSrc.templateId
	petInfo.pet_lv = petInfoSrc.level
	petInfo.pet_cp = petInfoSrc:getCpValue()
	petInfo.pet_feature = petInfoSrc.characterInfo.curCharacter
	petInfo.pet_skill_1 = petInfoSrc.curAbilityMap[AbilityConst.WEAPON_SKILL_ABILITY] and petInfoSrc.curAbilityMap[AbilityConst.WEAPON_SKILL_ABILITY].abilityId or 0
	petInfo.pet_skill_2 = petInfoSrc.curAbilityMap[AbilityConst.WEAPON_SKILL_ABILITY2] and petInfoSrc.curAbilityMap[AbilityConst.WEAPON_SKILL_ABILITY2].abilityId or 0
	petInfo.pet_cri_rate = attributeMap[AttributeConst.crit_rate_v] or 0
	petInfo.pet_cri_damage = attributeMap[AttributeConst.crit_dmg_v] or 0
	petInfo.pet_final_species_list = {}

	local attriIds = {
		AttributeConst.hp_max_cur,
		AttributeConst.atk_cur,
		AttributeConst.bp_atk_cur,
		AttributeConst.def_cur,
		AttributeConst.def_mag_cur,
		AttributeConst.ep_regen_force_cur
	}

	for _, attriId in ipairs(attriIds) do
		local v = attributeMap[attriId] or 0

		v = math.floor(v)

		table.insert(petInfo.pet_final_species_list, v)
	end

	return petInfo
end

function BiLogBasicUtils:BuildPetPropChangeInfo(player, petInfoSrc)
	local basicInfo = self:BuildPetInfoByPetInfo(player, petInfoSrc)

	if not basicInfo then
		return nil
	end

	return {
		pet_lv = basicInfo.pet_lv,
		pet_cp = basicInfo.pet_cp,
		pet_final_species_list = basicInfo.pet_final_species_list,
		label = petInfoSrc.label or 0,
		overall_rating = petInfoSrc.propertyScoreStage or 0,
		shiny_style = petInfoSrc.shinyStyle or 0,
		prop_info = lume.map(petInfoSrc.basePropertyList, function(prop)
			return prop:getBaseIndividualLevel()
		end),
		talent_list = lume.map(petInfoSrc.talentList, function(talentInfo)
			return {
				talentInfo.templateId,
				talentInfo.propValues:getRawTable()
			}
		end)
	}
end

function BiLogBasicUtils:BuildPetInfo(petEnt)
	if not petEnt then
		return nil
	end

	return self:BuildPetInfoByPetInfo(AbilityUtils.getPlayer(petEnt), petEnt.petInfo)
end

function BiLogBasicUtils:BuildPetBasicInfo(logContent, player)
	local petInfos = {}

	for i, petId in ipairs(player.petPrepareList) do
		local petEnt = pg.getEntity(petId)
		local petInfo = self:BuildPetInfo(petEnt)

		if petInfo then
			petInfos[i] = petInfo
		end
	end

	logContent.pet_info_obj_group = petInfos
end

function BiLogBasicUtils:BuildPetBasicInfoWithoutEntity(logContent, player, customPetList)
	local petInfos = {}

	for i, petId in ipairs(customPetList or player.petPrepareList) do
		local petInfoSrc = player:getPetInfo(petId)
		local petInfo = self:BuildPetInfoByPetInfo(player, petInfoSrc)

		if petInfo then
			petInfos[i] = petInfo
		end
	end

	logContent.pet_info_obj_group = petInfos
end

function BiLogBasicUtils:logItemOverflow(player, overflowType, source, overFlowItems, overFlowPets)
	if not player or not player.BILogger then
		return
	end

	local hasItems = overFlowItems and next(overFlowItems) ~= nil
	local hasPets = overFlowPets and next(overFlowPets) ~= nil

	if not hasItems and not hasPets then
		return
	end

	local itemList = {}

	if hasItems then
		for itemId, numInfo in pairs(overFlowItems) do
			local total = 0

			if type(numInfo) == "table" then
				for _, n in pairs(numInfo) do
					total = total + (n or 0)
				end
			else
				total = numInfo or 0
			end

			if total > 0 then
				itemList[#itemList + 1] = {
					item_id = tostring(itemId),
					item_num = total
				}
			end
		end
	end

	local petAgg = {}

	if hasPets then
		for _, petInfo in pairs(overFlowPets) do
			local tid = petInfo and petInfo.templateId

			if tid and tid ~= 0 then
				petAgg[tid] = (petAgg[tid] or 0) + 1
			end
		end
	end

	local petList = {}

	for tid, n in pairs(petAgg) do
		petList[#petList + 1] = {
			pet_id = tostring(tid),
			pet_num = n
		}
	end

	player.BILogger:customeLog("item_overflow", {
		overflow_type = overflowType or "",
		source = source or 0,
		item_list = itemList,
		pet_list = petList
	})
end

return BiLogBasicUtils
