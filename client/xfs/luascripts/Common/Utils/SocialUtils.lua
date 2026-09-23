-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Utils\\SocialUtils.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local lume = require("Core.Common.lume")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local ItemConst = require("Common.Const.ItemConst")
local ItemUtils = require("Common.Utils.ItemUtils")
local PetData = require("Data.pet_data")
local PetBallConfigData = require("Data.pet_ball_config_data")
local PetPrototypeData = require("Data.pet_prototype_data")
local PetBasePrototypeToPrototypeMap = require("Data.pet_base_prototype_to_prototype_map")
local SocialUtils = {}

function SocialUtils.genBreedSource(selfTemplateId, otherUid, otherTemplateId)
	return string.format("%s_%s_%s", selfTemplateId, otherUid, otherTemplateId)
end

function SocialUtils.parseBreedSource(breedSource)
	local selfTemplateId, otherUid, otherTemplateId = unpack(string.split(breedSource, "_"), 1, 3)

	return selfTemplateId, otherUid, otherTemplateId
end

function SocialUtils.breedGenEggTemplateId(fatherInfo, motherInfo, itemId, player)
	local resTemplateId, isMutation = 0, false

	local function getValidDefaultPet(prototypeId)
		local pptdd = PetPrototypeData[prototypeId]
		local templateId = pptdd and pptdd.defaultPet

		if templateId and PetData[templateId] then
			return templateId
		end
	end

	local geneticIds = {
		fatherInfo.petPrototypeId,
		motherInfo.petPrototypeId
	}
	local geneticId = Utils.randomByExtractMode(Const.EXTRACT_MODE_PROPORTION_OVERFLOW, geneticIds, function(v)
		local pptdd = PetPrototypeData[v] or {}

		if Utils.isRainbowType(v) and ItemUtils.checkSType(itemId, ItemConst.USEITEM_TYPE_BREED_RAINBOW) then
			return 1
		end

		return pptdd.geneticProb or 0
	end)

	if geneticId then
		resTemplateId = getValidDefaultPet(geneticId)

		if resTemplateId then
			return resTemplateId, isMutation
		end
	end

	local basePetPrototypeId = fatherInfo.basePetPrototypeId
	local randomIds = PetBasePrototypeToPrototypeMap[basePetPrototypeId] or {}
	local randomId = Utils.randomByExtractMode(Const.EXTRACT_MODE_PROPORTION, randomIds, function(v)
		local pptdd = PetPrototypeData[v] or {}

		if not getValidDefaultPet(v) then
			return 0
		end

		if ToBool(pptdd.isNeedOwn) and not player.petHandbookMap:isCatched(v, Const.GROUP_TYPE_SELF) then
			return 0
		end

		return pptdd.breedRandomProb or 0
	end)

	if randomId then
		resTemplateId = getValidDefaultPet(randomId)
		isMutation = ToBool(PetPrototypeData[randomId].isRareForm)
	end

	if not resTemplateId or not PetData[resTemplateId] then
		if fatherInfo.templateId and PetData[fatherInfo.templateId] then
			resTemplateId = fatherInfo.templateId
		elseif motherInfo.templateId and PetData[motherInfo.templateId] then
			resTemplateId = motherInfo.templateId
		else
			resTemplateId = getValidDefaultPet(fatherInfo.petPrototypeId) or getValidDefaultPet(motherInfo.petPrototypeId) or 0
		end

		isMutation = false
	end

	return resTemplateId, isMutation
end

function SocialUtils.breedGenEggLabel(fatherInfo, motherInfo, itemId)
	local resLabel, isMutation = 0, false

	local function tryAddLabelMask(mask, geneticProb, randomProb, sType)
		local parentLabels = {
			fatherInfo.label,
			motherInfo.label
		}
		local geneticRatio = 0

		for _, parentLabel in ipairs(parentLabels) do
			if bit.band(parentLabel, mask) ~= 0 then
				if sType and ItemUtils.checkSType(itemId, sType) then
					geneticRatio = 1

					break
				end

				geneticRatio = geneticRatio + geneticProb
			end
		end

		if geneticRatio > math.random() then
			resLabel = bit.bor(resLabel, mask)

			return
		end

		if randomProb > math.random() then
			resLabel = bit.bor(resLabel, mask)
			isMutation = true

			return
		end
	end

	local pbcdd = PetBallConfigData

	tryAddLabelMask(Const.PET_LABEL_MASK.SHINY, pbcdd.shinyGeneticProb, pbcdd.shinyBreedRandomProb, ItemConst.USEITEM_TYPE_BREED_SHINY)
	tryAddLabelMask(Const.PET_LABEL_MASK.ELITE, pbcdd.eliteGeneticProb, pbcdd.eliteBreedRandomProb, nil)
	tryAddLabelMask(Const.PET_LABEL_MASK.VARIANT, pbcdd.variantGeneticProb, pbcdd.variantBreedRandomProb, nil)

	return resLabel, isMutation
end

function SocialUtils.breedGenEggFeature(fatherInfo, motherInfo, childTemplateId, childLabel)
	local resCharacterId
	local childConfig = PetData[childTemplateId]

	if not childConfig then
		return resCharacterId, false
	end

	local validIds = Utils.getValidCharacterListByConfig(childConfig, nil, childLabel)
	local fatherId = fatherInfo.characterInfo.curCharacter
	local motherId = motherInfo.characterInfo.curCharacter
	local geneticId = math.random() < 0.5 and fatherId or motherId

	if lume.find(validIds, geneticId) then
		resCharacterId = geneticId
	else
		resCharacterId = validIds[1]
	end

	return resCharacterId, false
end

function SocialUtils.breedGenEggBaseProps(fatherInfo, motherInfo, itemId, propPetId)
	local resIndividualLevelList = {}
	local fatherIndividualLevelList = require("CustomTypes.BasePropertyList").getBaseIndividualLevels(fatherInfo.basePropertyList, true)
	local motherIndividualLevelList = require("CustomTypes.BasePropertyList").getBaseIndividualLevels(motherInfo.basePropertyList, true)

	if ItemUtils.checkSType(itemId, ItemConst.USEITEM_TYPE_BREED_PROP) then
		resIndividualLevelList = propPetId == fatherInfo.id and fatherIndividualLevelList or motherIndividualLevelList or {}
	end

	for index, _ in ipairs(fatherIndividualLevelList) do
		local level = math.random(fatherIndividualLevelList[index], motherIndividualLevelList[index])

		resIndividualLevelList[index] = math.round(level)
	end

	return resIndividualLevelList
end

function SocialUtils.breedGenEggBodyEntries(fatherInfo, motherInfo, player)
	return {}, false
end

return SocialUtils
