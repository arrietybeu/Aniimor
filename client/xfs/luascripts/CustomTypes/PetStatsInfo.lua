-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\PetStatsInfo.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local class = require("Core.Framework.Class")
local CustomDict = require("Core.PropertySync.CustomDict")
local Utils = require("Common.Utils.Utils")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local PetTalentData = require("Data.pet_talent_data")
local ItemData = require("Data.item_data")
local PetSkillData = require("Data.pet_skill_data")
local bit = bit
local PetStatsInfo = class.LiteClass("PetStatsInfo", CustomDict)

function PetStatsInfo:init(dict)
	dict = dict or {}

	CustomDict.init(self, dict)
end

function PetStatsInfo:resetStats()
	self.genderCount = {}
	self.raceCount = {}
	self.templateOwned = {}
	self.characterCount = {}
	self.scoreLabelCount = {}
	self.starHist = {}
	self.skillNumHist = {}
	self.levelHist = {}
	self.tmplLevelHist = {}
	self.talentRarityCount = {}
	self.individualLevelCount = {}
	self.skillUpgradeIndividualSkillCount = {}
	self.coreCarryCount = {}
	self.coreCarryQualityCount = {}
	self.petCount = 0
end

function PetStatsInfo.decrementCount(tbl, key)
	local val = tbl[key] or 0

	if val > 0 then
		val = val - 1

		if val == 0 then
			tbl[key] = nil
		else
			tbl[key] = val
		end
	end
end

function PetStatsInfo.incrementMapMapCount(tbl, key1, key2)
	if type(tbl[key1]) ~= "table" then
		tbl[key1] = {}
	end

	tbl[key1][key2] = (tbl[key1][key2] or 0) + 1
end

function PetStatsInfo.decrementMapMapCount(tbl, key1, key2)
	local subTbl = tbl[key1]

	if type(subTbl) ~= "table" then
		tbl[key1] = nil

		return
	end

	PetStatsInfo.decrementCount(subTbl, key2)

	if not next(subTbl) then
		tbl[key1] = nil
	end
end

function PetStatsInfo.getGenderKey(petInfo)
	return (petInfo.basePetPrototypeId or 0) * 10 + (petInfo.gender or 0)
end

function PetStatsInfo.isSpecialCharacter(petInfo)
	local characterInfo = petInfo.characterInfo

	if not characterInfo then
		return false
	end

	if characterInfo.isSpecialCharacter then
		return characterInfo:isSpecialCharacter()
	end

	return Utils.isSpecialCharacter(characterInfo.curCharacter)
end

function PetStatsInfo.getResonanceStage(petInfo)
	local resonanceInfo = petInfo.resonanceInfo

	return resonanceInfo and resonanceInfo.resonanceStage or 0
end

function PetStatsInfo.getSkillNum(petInfo)
	local unlockedAbilityMap = petInfo.unlockedAbilityMap

	if not unlockedAbilityMap then
		return 0
	end

	local count = 0

	if unlockedAbilityMap.items then
		for _, _ in unlockedAbilityMap:items() do
			count = count + 1
		end
	else
		for _, _ in pairs(unlockedAbilityMap) do
			count = count + 1
		end
	end

	return count
end

function PetStatsInfo.getIndividualLevelKey(propIndex, level)
	return tostring(propIndex or 0) .. "_" .. tostring(level or 0)
end

function PetStatsInfo.getPetMaxIndividualLevel(petInfo)
	local basePropertyList = petInfo and petInfo.basePropertyList

	if not basePropertyList then
		return 0
	end

	local maxLevel = 0
	local maxLevelLimit = Utils.getTotalIndividualLevelMax(0)

	if basePropertyList.items then
		for _, prop in basePropertyList:items() do
			maxLevel = math.max(maxLevel, prop.indLv or 0)

			if maxLevelLimit > 0 and maxLevelLimit <= maxLevel then
				break
			end
		end
	else
		for _, prop in pairs(basePropertyList) do
			maxLevel = math.max(maxLevel, prop.indLv or 0)

			if maxLevelLimit > 0 and maxLevelLimit <= maxLevel then
				break
			end
		end
	end

	return maxLevel
end

function PetStatsInfo.getPetIndividualLevelMap(petInfo)
	local levelMap = {}
	local basePropertyList = petInfo and petInfo.basePropertyList

	if not basePropertyList then
		return levelMap
	end

	local maxLevel = PetStatsInfo.getPetMaxIndividualLevel(petInfo)

	levelMap[PetStatsInfo.getIndividualLevelKey(0, maxLevel)] = true

	if basePropertyList.items then
		for propIndex, prop in basePropertyList:items() do
			levelMap[PetStatsInfo.getIndividualLevelKey(propIndex, prop.indLv or 0)] = true
		end
	else
		for propIndex, prop in pairs(basePropertyList) do
			propIndex = tonumber(propIndex)

			if propIndex then
				levelMap[PetStatsInfo.getIndividualLevelKey(propIndex, prop.indLv or 0)] = true
			end
		end
	end

	return levelMap
end

function PetStatsInfo.getTalentRarityCounts(petInfo)
	local talentList = petInfo.talentList
	local rarityCounts = {
		[0] = 0
	}

	if not talentList then
		return rarityCounts
	end

	for _, talentInfo in ipairs(talentList) do
		rarityCounts[0] = rarityCounts[0] + 1

		local talentData = PetTalentData[talentInfo.templateId]
		local rarity = talentData and talentData.rarity or 0

		if rarity ~= 0 then
			rarityCounts[rarity] = (rarityCounts[rarity] or 0) + 1
		end
	end

	return rarityCounts
end

function PetStatsInfo.getCoreCarryQuality(coreCarryInfo)
	if not coreCarryInfo then
		return 0
	end

	if coreCarryInfo.getQuality then
		return coreCarryInfo:getQuality()
	end

	local itemId = coreCarryInfo.itemId or 0
	local itemCfg = ItemData[itemId]

	return itemCfg and itemCfg.quality or 0
end

function PetStatsInfo.getPetCoreCarryInfo(petInfo)
	if not petInfo then
		return nil
	end

	if petInfo.getCoreCarryInfo then
		return petInfo:getCoreCarryInfo()
	end

	return petInfo.coreCarryInfo
end

function PetStatsInfo:getPetSkillUpgradeIndividualSkillSet(player, petInfo)
	if not player or not petInfo then
		return 0, {}
	end

	local basePrototypeId = petInfo.basePetPrototypeId or Utils.getBasePetPrototypeId(petInfo.petPrototypeId or 0)

	if basePrototypeId == 0 then
		return 0, {}
	end

	local curAbilitySkillSet = {}

	for _, abilityInfo in pairs(petInfo.curAbilityMap or EMPTY_TABLE) do
		local abilityParamId = AbilityUtils.getAbilityParamId(abilityInfo.abilityId)

		if abilityParamId and abilityParamId ~= 0 then
			curAbilitySkillSet[abilityParamId] = true
		end
	end

	local skillSet = {}
	local unlockedAbilityMap = petInfo.unlockedAbilityMap or {}
	local petUpgradeMap = player.petSkillUpgradeMap[petInfo.id] or {}
	local skillDataMap = PetSkillData[basePrototypeId] or {}

	for enhancedSkillId, oldSkillId in pairs(petUpgradeMap) do
		local skillData = skillDataMap[oldSkillId]
		local hasEnhancedSkill = unlockedAbilityMap[enhancedSkillId] or curAbilitySkillSet[enhancedSkillId]

		if skillData and skillData.enhancedSkillId == enhancedSkillId and hasEnhancedSkill then
			skillSet[enhancedSkillId] = true
		end
	end

	return basePrototypeId, skillSet
end

function PetStatsInfo:addPetGenderStats(petInfo)
	local genderKey = PetStatsInfo.getGenderKey(petInfo)

	self.genderCount[genderKey] = (self.genderCount[genderKey] or 0) + 1
end

function PetStatsInfo:removePetGenderStats(petInfo)
	PetStatsInfo.decrementCount(self.genderCount, PetStatsInfo.getGenderKey(petInfo))
end

function PetStatsInfo:onPetGenderChange(oldPetInfo, petInfo)
	if not oldPetInfo or not petInfo then
		return
	end

	self:removePetGenderStats(oldPetInfo)
	self:addPetGenderStats(petInfo)
end

function PetStatsInfo:addPetRaceStats(petInfo)
	local basePetPrototypeId = petInfo.basePetPrototypeId or 0

	self.raceCount[basePetPrototypeId] = (self.raceCount[basePetPrototypeId] or 0) + 1
end

function PetStatsInfo:removePetRaceStats(petInfo)
	PetStatsInfo.decrementCount(self.raceCount, petInfo.basePetPrototypeId or 0)
end

function PetStatsInfo:onPetRaceChange(oldPetInfo, petInfo)
	if not oldPetInfo or not petInfo then
		return
	end

	self:removePetRaceStats(oldPetInfo)
	self:addPetRaceStats(petInfo)
end

function PetStatsInfo:addPetTemplateStats(petInfo)
	local templateId = petInfo.templateId or 0

	self.templateOwned[templateId] = (self.templateOwned[templateId] or 0) + 1
end

function PetStatsInfo:removePetTemplateStats(petInfo)
	PetStatsInfo.decrementCount(self.templateOwned, petInfo.templateId or 0)
end

function PetStatsInfo:onPetTemplateChange(oldPetInfo, petInfo)
	if not oldPetInfo or not petInfo then
		return
	end

	self:removePetTemplateStats(oldPetInfo)
	self:addPetTemplateStats(petInfo)
end

function PetStatsInfo:addPetSpecialCharacterStats(petInfo)
	local petPrototypeId = petInfo.petPrototypeId or 0

	if PetStatsInfo.isSpecialCharacter(petInfo) then
		if petPrototypeId ~= 0 then
			self.characterCount[petPrototypeId] = (self.characterCount[petPrototypeId] or 0) + 1
		end

		self.characterCount[0] = (self.characterCount[0] or 0) + 1
	end
end

function PetStatsInfo:removePetSpecialCharacterStats(petInfo)
	local petPrototypeId = petInfo.petPrototypeId or 0

	if PetStatsInfo.isSpecialCharacter(petInfo) then
		if petPrototypeId ~= 0 then
			PetStatsInfo.decrementCount(self.characterCount, petPrototypeId)
		end

		PetStatsInfo.decrementCount(self.characterCount, 0)
	end
end

function PetStatsInfo:onSpecialCharacterChange(petInfo, oldCharacterId, newCharacterId)
	if not petInfo then
		return
	end

	oldCharacterId = oldCharacterId or 0
	newCharacterId = newCharacterId or 0

	if oldCharacterId == newCharacterId then
		return
	end

	local petPrototypeId = petInfo.petPrototypeId or 0

	if Utils.isSpecialCharacter(oldCharacterId) then
		if petPrototypeId ~= 0 then
			PetStatsInfo.decrementCount(self.characterCount, petPrototypeId)
		end

		PetStatsInfo.decrementCount(self.characterCount, 0)
	end

	if Utils.isSpecialCharacter(newCharacterId) then
		if petPrototypeId ~= 0 then
			self.characterCount[petPrototypeId] = (self.characterCount[petPrototypeId] or 0) + 1
		end

		self.characterCount[0] = (self.characterCount[0] or 0) + 1
	end
end

function PetStatsInfo:onPetSpecialCharacterChange(oldPetInfo, petInfo)
	if not oldPetInfo or not petInfo then
		return
	end

	self:removePetSpecialCharacterStats(oldPetInfo)
	self:addPetSpecialCharacterStats(petInfo)
end

function PetStatsInfo:addPetStarStats(petInfo)
	local petPrototypeId = petInfo.petPrototypeId or 0
	local resonanceStage = PetStatsInfo.getResonanceStage(petInfo)

	PetStatsInfo.incrementMapMapCount(self.starHist, 0, resonanceStage)

	if petPrototypeId ~= 0 then
		PetStatsInfo.incrementMapMapCount(self.starHist, petPrototypeId, resonanceStage)
	end
end

function PetStatsInfo:removePetStarStats(petInfo)
	local petPrototypeId = petInfo.petPrototypeId or 0
	local resonanceStage = PetStatsInfo.getResonanceStage(petInfo)

	PetStatsInfo.decrementMapMapCount(self.starHist, 0, resonanceStage)

	if petPrototypeId ~= 0 then
		PetStatsInfo.decrementMapMapCount(self.starHist, petPrototypeId, resonanceStage)
	end
end

function PetStatsInfo:onPetStarChange(oldPetInfo, petInfo)
	if not oldPetInfo or not petInfo then
		return
	end

	self:removePetStarStats(oldPetInfo)
	self:addPetStarStats(petInfo)
end

function PetStatsInfo:addPetScoreStats(petInfo)
	local propertyScoreStage = petInfo.propertyScoreStage or 0
	local label = petInfo.label or 0

	self.scoreLabelCount = self.scoreLabelCount or {}

	PetStatsInfo.incrementMapMapCount(self.scoreLabelCount, propertyScoreStage, 0)

	if label ~= 0 then
		PetStatsInfo.incrementMapMapCount(self.scoreLabelCount, propertyScoreStage, label)
	end
end

function PetStatsInfo:removePetScoreStats(petInfo)
	local propertyScoreStage = petInfo.propertyScoreStage or 0
	local label = petInfo.label or 0

	self.scoreLabelCount = self.scoreLabelCount or {}

	PetStatsInfo.decrementMapMapCount(self.scoreLabelCount, propertyScoreStage, 0)

	if label ~= 0 then
		PetStatsInfo.decrementMapMapCount(self.scoreLabelCount, propertyScoreStage, label)
	end
end

function PetStatsInfo:onPetScoreChange(oldPetInfo, petInfo)
	local oldStage = oldPetInfo and oldPetInfo.propertyScoreStage or 0
	local newStage = petInfo and petInfo.propertyScoreStage or 0
	local oldLabel = oldPetInfo and oldPetInfo.label or 0
	local newLabel = petInfo and petInfo.label or 0

	self:onScoreStageAndLabelChange(oldStage, newStage, oldLabel, newLabel)
end

function PetStatsInfo:addPetLevelStats(petInfo)
	local petPrototypeId = petInfo.petPrototypeId or 0
	local level = petInfo.level or 0

	PetStatsInfo.incrementMapMapCount(self.levelHist, 0, level)

	if petPrototypeId ~= 0 then
		PetStatsInfo.incrementMapMapCount(self.levelHist, petPrototypeId, level)
	end
end

function PetStatsInfo:removePetLevelStats(petInfo)
	local petPrototypeId = petInfo.petPrototypeId or 0
	local level = petInfo.level or 0

	PetStatsInfo.decrementMapMapCount(self.levelHist, 0, level)

	if petPrototypeId ~= 0 then
		PetStatsInfo.decrementMapMapCount(self.levelHist, petPrototypeId, level)
	end
end

function PetStatsInfo:onPetPrototypeLevelChange(oldPetInfo, petInfo)
	if not oldPetInfo or not petInfo then
		return
	end

	self:removePetLevelStats(oldPetInfo)
	self:addPetLevelStats(petInfo)
end

function PetStatsInfo:addPetTemplateLevelStats(petInfo)
	local basePetPrototypeId = petInfo.basePetPrototypeId or 0
	local level = petInfo.level or 0

	PetStatsInfo.incrementMapMapCount(self.tmplLevelHist, 0, level)

	if basePetPrototypeId ~= 0 then
		PetStatsInfo.incrementMapMapCount(self.tmplLevelHist, basePetPrototypeId, level)
	end
end

function PetStatsInfo:removePetTemplateLevelStats(petInfo)
	local basePetPrototypeId = petInfo.basePetPrototypeId or 0
	local level = petInfo.level or 0

	PetStatsInfo.decrementMapMapCount(self.tmplLevelHist, 0, level)

	if basePetPrototypeId ~= 0 then
		PetStatsInfo.decrementMapMapCount(self.tmplLevelHist, basePetPrototypeId, level)
	end
end

function PetStatsInfo:onPetTemplateLevelChange(oldPetInfo, petInfo)
	if not oldPetInfo or not petInfo then
		return
	end

	self:removePetTemplateLevelStats(oldPetInfo)
	self:addPetTemplateLevelStats(petInfo)
end

function PetStatsInfo:onPetLevelChange(petInfo, oldLevel, newLevel)
	if not petInfo then
		return
	end

	oldLevel = oldLevel or 0
	newLevel = newLevel or 0

	if oldLevel == newLevel then
		return
	end

	local petPrototypeId = petInfo.petPrototypeId or 0

	PetStatsInfo.decrementMapMapCount(self.levelHist, 0, oldLevel)
	PetStatsInfo.incrementMapMapCount(self.levelHist, 0, newLevel)

	if petPrototypeId ~= 0 then
		PetStatsInfo.decrementMapMapCount(self.levelHist, petPrototypeId, oldLevel)
		PetStatsInfo.incrementMapMapCount(self.levelHist, petPrototypeId, newLevel)
	end

	local basePetPrototypeId = petInfo.basePetPrototypeId or 0

	PetStatsInfo.decrementMapMapCount(self.tmplLevelHist, 0, oldLevel)
	PetStatsInfo.incrementMapMapCount(self.tmplLevelHist, 0, newLevel)

	if basePetPrototypeId ~= 0 then
		PetStatsInfo.decrementMapMapCount(self.tmplLevelHist, basePetPrototypeId, oldLevel)
		PetStatsInfo.incrementMapMapCount(self.tmplLevelHist, basePetPrototypeId, newLevel)
	end
end

function PetStatsInfo:addPetIdentityStats(petInfo)
	self:addPetGenderStats(petInfo)
	self:addPetRaceStats(petInfo)
	self:addPetTemplateStats(petInfo)
	self:addPetSpecialCharacterStats(petInfo)
	self:addPetStarStats(petInfo)
end

function PetStatsInfo:removePetIdentityStats(petInfo)
	self:removePetGenderStats(petInfo)
	self:removePetRaceStats(petInfo)
	self:removePetTemplateStats(petInfo)
	self:removePetSpecialCharacterStats(petInfo)
	self:removePetStarStats(petInfo)
end

function PetStatsInfo:addPetSkillNumStats(petInfo)
	local skillNum = PetStatsInfo.getSkillNum(petInfo)
	local basePetPrototypeId = petInfo.basePetPrototypeId or 0

	PetStatsInfo.incrementMapMapCount(self.skillNumHist, 0, skillNum)

	if basePetPrototypeId ~= 0 then
		PetStatsInfo.incrementMapMapCount(self.skillNumHist, basePetPrototypeId, skillNum)
	end
end

function PetStatsInfo:removePetSkillNumStats(petInfo)
	local skillNum = PetStatsInfo.getSkillNum(petInfo)
	local basePetPrototypeId = petInfo.basePetPrototypeId or 0

	PetStatsInfo.decrementMapMapCount(self.skillNumHist, 0, skillNum)

	if basePetPrototypeId ~= 0 then
		PetStatsInfo.decrementMapMapCount(self.skillNumHist, basePetPrototypeId, skillNum)
	end
end

function PetStatsInfo:addPetTalentRarityStats(petInfo)
	local rarityCounts = PetStatsInfo.getTalentRarityCounts(petInfo)

	for rarity, count in pairs(rarityCounts) do
		PetStatsInfo.incrementMapMapCount(self.talentRarityCount, rarity, count)
	end
end

function PetStatsInfo:removePetTalentRarityStats(petInfo)
	local rarityCounts = PetStatsInfo.getTalentRarityCounts(petInfo)

	for rarity, count in pairs(rarityCounts) do
		PetStatsInfo.decrementMapMapCount(self.talentRarityCount, rarity, count)
	end
end

function PetStatsInfo:addPetIndividualLevelStats(petInfo)
	self.individualLevelCount = self.individualLevelCount or {}

	local petPrototypeId = petInfo.petPrototypeId or 0
	local levelMap = PetStatsInfo.getPetIndividualLevelMap(petInfo)

	for levelKey in pairs(levelMap) do
		PetStatsInfo.incrementMapMapCount(self.individualLevelCount, 0, levelKey)

		if petPrototypeId ~= 0 then
			PetStatsInfo.incrementMapMapCount(self.individualLevelCount, petPrototypeId, levelKey)
		end
	end
end

function PetStatsInfo:removePetIndividualLevelStats(petInfo)
	self.individualLevelCount = self.individualLevelCount or {}

	local petPrototypeId = petInfo.petPrototypeId or 0
	local levelMap = PetStatsInfo.getPetIndividualLevelMap(petInfo)

	for levelKey in pairs(levelMap) do
		PetStatsInfo.decrementMapMapCount(self.individualLevelCount, 0, levelKey)

		if petPrototypeId ~= 0 then
			PetStatsInfo.decrementMapMapCount(self.individualLevelCount, petPrototypeId, levelKey)
		end
	end
end

function PetStatsInfo:onPetIndividualLevelChange(oldPetInfo, petInfo)
	self:removePetIndividualLevelStats(oldPetInfo)
	self:addPetIndividualLevelStats(petInfo)
end

function PetStatsInfo:addSkillUpgradeIndividualSkillSetStats(basePrototypeId, skillSet)
	basePrototypeId = basePrototypeId or 0

	if basePrototypeId == 0 or not skillSet or not next(skillSet) then
		return
	end

	self.skillUpgradeIndividualSkillCount = self.skillUpgradeIndividualSkillCount or {}

	PetStatsInfo.incrementMapMapCount(self.skillUpgradeIndividualSkillCount, 0, 0)
	PetStatsInfo.incrementMapMapCount(self.skillUpgradeIndividualSkillCount, basePrototypeId, 0)

	for enhancedSkillId in pairs(skillSet) do
		PetStatsInfo.incrementMapMapCount(self.skillUpgradeIndividualSkillCount, 0, enhancedSkillId)
		PetStatsInfo.incrementMapMapCount(self.skillUpgradeIndividualSkillCount, basePrototypeId, enhancedSkillId)
	end
end

function PetStatsInfo:removeSkillUpgradeIndividualSkillSetStats(basePrototypeId, skillSet)
	basePrototypeId = basePrototypeId or 0

	if basePrototypeId == 0 or not skillSet or not next(skillSet) then
		return
	end

	self.skillUpgradeIndividualSkillCount = self.skillUpgradeIndividualSkillCount or {}

	PetStatsInfo.decrementMapMapCount(self.skillUpgradeIndividualSkillCount, 0, 0)
	PetStatsInfo.decrementMapMapCount(self.skillUpgradeIndividualSkillCount, basePrototypeId, 0)

	for enhancedSkillId in pairs(skillSet) do
		PetStatsInfo.decrementMapMapCount(self.skillUpgradeIndividualSkillCount, 0, enhancedSkillId)
		PetStatsInfo.decrementMapMapCount(self.skillUpgradeIndividualSkillCount, basePrototypeId, enhancedSkillId)
	end
end

function PetStatsInfo:onSkillUpgradeIndividualSkillSetChange(oldBasePrototypeId, oldSkillSet, newBasePrototypeId, newSkillSet)
	self:removeSkillUpgradeIndividualSkillSetStats(oldBasePrototypeId, oldSkillSet)
	self:addSkillUpgradeIndividualSkillSetStats(newBasePrototypeId, newSkillSet)
end

function PetStatsInfo:addCoreCarryStats(coreCarryInfo)
	if not coreCarryInfo or coreCarryInfo.isValid and not coreCarryInfo:isValid() then
		return
	end

	local itemId = coreCarryInfo.itemId or 0

	if itemId == 0 then
		return
	end

	self.coreCarryCount[0] = (self.coreCarryCount[0] or 0) + 1
	self.coreCarryCount[itemId] = (self.coreCarryCount[itemId] or 0) + 1

	local quality = PetStatsInfo.getCoreCarryQuality(coreCarryInfo)

	if quality ~= 0 then
		self.coreCarryQualityCount[quality] = (self.coreCarryQualityCount[quality] or 0) + 1
	end
end

function PetStatsInfo:removeCoreCarryStats(coreCarryInfo)
	if not coreCarryInfo or coreCarryInfo.isValid and not coreCarryInfo:isValid() then
		return
	end

	local itemId = coreCarryInfo.itemId or 0

	if itemId == 0 then
		return
	end

	PetStatsInfo.decrementCount(self.coreCarryCount, 0)
	PetStatsInfo.decrementCount(self.coreCarryCount, itemId)

	local quality = PetStatsInfo.getCoreCarryQuality(coreCarryInfo)

	if quality ~= 0 then
		PetStatsInfo.decrementCount(self.coreCarryQualityCount, quality)
	end
end

function PetStatsInfo:addPetCoreCarryStats(petInfo)
	self:addCoreCarryStats(PetStatsInfo.getPetCoreCarryInfo(petInfo))
end

function PetStatsInfo:removePetCoreCarryStats(petInfo)
	self:removeCoreCarryStats(PetStatsInfo.getPetCoreCarryInfo(petInfo))
end

function PetStatsInfo:onCoreCarryChange(oldCoreCarryInfo, newCoreCarryInfo)
	if oldCoreCarryInfo == newCoreCarryInfo then
		return
	end

	self:removeCoreCarryStats(oldCoreCarryInfo)
	self:addCoreCarryStats(newCoreCarryInfo)
end

function PetStatsInfo:onAddPet(petInfo)
	local player = petInfo:getOwnerPlayer()

	self:addPetIdentityStats(petInfo)
	self:addPetScoreStats(petInfo)
	self:addPetSkillNumStats(petInfo)
	self:addPetTalentRarityStats(petInfo)
	self:addPetLevelStats(petInfo)
	self:addPetTemplateLevelStats(petInfo)
	self:addPetIndividualLevelStats(petInfo)

	local basePrototypeId, skillSet = self:getPetSkillUpgradeIndividualSkillSet(player, petInfo)

	self:addSkillUpgradeIndividualSkillSetStats(basePrototypeId, skillSet)
	self:addPetCoreCarryStats(petInfo)

	self.petCount = self.petCount + 1
end

function PetStatsInfo:onRemovePet(petInfo)
	local player = petInfo:getOwnerPlayer()

	self:removePetIdentityStats(petInfo)
	self:removePetScoreStats(petInfo)
	self:removePetSkillNumStats(petInfo)
	self:removePetTalentRarityStats(petInfo)
	self:removePetLevelStats(petInfo)
	self:removePetTemplateLevelStats(petInfo)
	self:removePetIndividualLevelStats(petInfo)

	local basePrototypeId, skillSet = self:getPetSkillUpgradeIndividualSkillSet(player, petInfo)

	self:removeSkillUpgradeIndividualSkillSetStats(basePrototypeId, skillSet)
	self:removePetCoreCarryStats(petInfo)

	self.petCount = self.petCount - 1
end

function PetStatsInfo:getGenderCount(prototypeId, gender)
	if prototypeId == 0 and gender == 0 then
		return self.petCount
	end

	if gender == 0 then
		local count = 0

		for key, val in pairs(self.genderCount) do
			if math.floor(key / 10) == prototypeId then
				count = count + val
			end
		end

		return count
	end

	if prototypeId == 0 then
		local count = 0

		for key, val in pairs(self.genderCount) do
			if key % 10 == gender then
				count = count + val
			end
		end

		return count
	end

	local key = prototypeId * 10 + gender

	return self.genderCount[key] or 0
end

function PetStatsInfo:hasRace(race)
	return (self.raceCount[race] or 0) > 0 and 1 or 0
end

function PetStatsInfo:hasTemplateId(templateId)
	return (self.templateOwned[templateId] or 0) > 0 and 1 or 0
end

function PetStatsInfo:getSpecialCharacterCount(petPrototypeId)
	return self.characterCount[petPrototypeId] or 0
end

function PetStatsInfo:getScoreCount(stage, rareLabel)
	if type(rareLabel) == "table" then
		rareLabel = rareLabel[1]
	end

	rareLabel = tonumber(rareLabel) or 0

	local labelCount = (self.scoreLabelCount or EMPTY_TABLE)[stage] or {}

	if rareLabel == 0 then
		return labelCount[0] or 0
	end

	local count = 0

	for label, labelPetCount in pairs(labelCount) do
		if label ~= 0 and bit.band(label, rareLabel) == rareLabel then
			count = count + labelPetCount
		end
	end

	return count
end

function PetStatsInfo:addCollectOnlyPetCount(basePetPrototypeId, label)
	basePetPrototypeId = basePetPrototypeId or 0
	label = label or 0
	self.collectOnlyPetCount = self.collectOnlyPetCount or {}

	PetStatsInfo.incrementMapMapCount(self.collectOnlyPetCount, 0, 0)

	if label ~= 0 then
		PetStatsInfo.incrementMapMapCount(self.collectOnlyPetCount, 0, label)
	end

	if basePetPrototypeId ~= 0 then
		PetStatsInfo.incrementMapMapCount(self.collectOnlyPetCount, basePetPrototypeId, 0)

		if label ~= 0 then
			PetStatsInfo.incrementMapMapCount(self.collectOnlyPetCount, basePetPrototypeId, label)
		end
	end
end

function PetStatsInfo:getCollectOnlyPetCount(basePetPrototypeId, rareLabel)
	if type(rareLabel) == "table" then
		rareLabel = rareLabel[1]
	end

	basePetPrototypeId = basePetPrototypeId or 0
	rareLabel = tonumber(rareLabel) or 0

	local labelCount = (self.collectOnlyPetCount or EMPTY_TABLE)[basePetPrototypeId] or {}

	if rareLabel == 0 then
		return labelCount[0] or 0
	end

	local count = 0

	for label, labelPetCount in pairs(labelCount) do
		if label ~= 0 and bit.band(label, rareLabel) == rareLabel then
			count = count + labelPetCount
		end
	end

	return count
end

function PetStatsInfo:getStarCountMin(petPrototypeId, stage)
	petPrototypeId = petPrototypeId or 0
	stage = stage or 0

	local stageCount = self.starHist[petPrototypeId]

	if type(stageCount) ~= "table" then
		return 0
	end

	local count = 0

	for resonanceStage, val in pairs(stageCount) do
		if stage <= resonanceStage then
			count = count + val
		end
	end

	return count
end

function PetStatsInfo:getSkillNumCountMin(basePetPrototypeId, skillNum)
	basePetPrototypeId = basePetPrototypeId or 0
	skillNum = skillNum or 0

	local skillNumCount = self.skillNumHist[basePetPrototypeId]

	if type(skillNumCount) ~= "table" then
		return 0
	end

	local count = 0

	for curSkillNum, val in pairs(skillNumCount) do
		if skillNum <= curSkillNum then
			count = count + val
		end
	end

	return count
end

function PetStatsInfo:getTalentRarityCountMin(rarity, attrCount)
	rarity = rarity or 0
	attrCount = attrCount or 0

	if attrCount <= 0 then
		return self.petCount
	end

	local attrCountMap = self.talentRarityCount[rarity]

	if type(attrCountMap) ~= "table" then
		return 0
	end

	local count = 0

	for curAttrCount, val in pairs(attrCountMap) do
		if attrCount <= curAttrCount then
			count = count + val
		end
	end

	return count
end

function PetStatsInfo:getCoreCarryCount(itemId, quality)
	itemId = itemId or 0
	quality = quality or 0

	if Utils.isTable(quality) then
		if not next(quality) then
			quality = 0
		elseif itemId == 0 then
			local count = 0
			local qualitySet = {}

			for _, needQuality in ipairs(quality) do
				if needQuality == 0 then
					return self.coreCarryCount[0] or 0
				end

				if not qualitySet[needQuality] then
					qualitySet[needQuality] = true
					count = count + (self.coreCarryQualityCount[needQuality] or 0)
				end
			end

			return count
		else
			local count = self.coreCarryCount[itemId] or 0
			local itemCfg = ItemData[itemId]

			if not itemCfg then
				return 0
			end

			for _, needQuality in ipairs(quality) do
				if needQuality == 0 or itemCfg.quality == needQuality then
					return count
				end
			end

			return 0
		end
	end

	if itemId == 0 then
		if quality == 0 then
			return self.coreCarryCount[0] or 0
		end

		return self.coreCarryQualityCount[quality] or 0
	end

	local count = self.coreCarryCount[itemId] or 0

	if quality == 0 then
		return count
	end

	local itemCfg = ItemData[itemId]

	return itemCfg and itemCfg.quality == quality and count or 0
end

function PetStatsInfo:getPetIndividualLevelCountMin(petPrototypeId, propIndex, minLevel)
	petPrototypeId = petPrototypeId or 0
	propIndex = propIndex or 0
	minLevel = minLevel or 0

	local levelCountMap = self.individualLevelCount[petPrototypeId]

	if not levelCountMap then
		return 0
	end

	local count = 0
	local maxLevel = Utils.getTotalIndividualLevelMax(propIndex)

	for level = minLevel, maxLevel do
		local levelKey = PetStatsInfo.getIndividualLevelKey(propIndex, level)

		count = count + (levelCountMap[levelKey] or 0)
	end

	return count
end

function PetStatsInfo:getSkillUpgradeIndividualCount(basePrototypeId, enhancedSkillIds)
	basePrototypeId = basePrototypeId or 0

	local skillUpgradeIndividualSkillCount = self.skillUpgradeIndividualSkillCount or {}
	local skillCountMap = skillUpgradeIndividualSkillCount[basePrototypeId]

	if type(skillCountMap) ~= "table" then
		return 0
	end

	if type(enhancedSkillIds) == "number" then
		return skillCountMap[enhancedSkillIds] or 0
	end

	if not enhancedSkillIds or #enhancedSkillIds == 0 then
		return skillCountMap[0] or 0
	end

	local count = 0

	for _, enhancedSkillId in ipairs(enhancedSkillIds) do
		count = count + (skillCountMap[enhancedSkillId] or 0)
	end

	return count
end

function PetStatsInfo:getPetLevelCountMin(petPrototypeId, level)
	petPrototypeId = petPrototypeId or 0
	level = level or 0

	local levelCountMap = self.levelHist[petPrototypeId]

	if type(levelCountMap) ~= "table" then
		return 0
	end

	local count = 0

	for curLevel, val in pairs(levelCountMap) do
		if level <= curLevel then
			count = count + val
		end
	end

	return count
end

function PetStatsInfo:getPetTemplateMaxLevel(basePetPrototypeId)
	basePetPrototypeId = basePetPrototypeId or 0

	local levelCountMap = self.tmplLevelHist[basePetPrototypeId]

	if type(levelCountMap) ~= "table" then
		return 0
	end

	local maxLevel = 0

	for level, count in pairs(levelCountMap) do
		if count > 0 and maxLevel < level then
			maxLevel = level
		end
	end

	return maxLevel
end

function PetStatsInfo:onScoreStageAndLabelChange(oldStage, newStage, oldLabel, newLabel)
	oldStage = oldStage or 0
	newStage = newStage or 0
	oldLabel = oldLabel or 0
	newLabel = newLabel or 0

	if oldStage == newStage and oldLabel == newLabel then
		return
	end

	self.scoreLabelCount = self.scoreLabelCount or {}

	if oldStage ~= newStage then
		PetStatsInfo.decrementMapMapCount(self.scoreLabelCount, oldStage, 0)
		PetStatsInfo.incrementMapMapCount(self.scoreLabelCount, newStage, 0)
	end

	if oldLabel ~= 0 then
		PetStatsInfo.decrementMapMapCount(self.scoreLabelCount, oldStage, oldLabel)
	end

	if newLabel ~= 0 then
		PetStatsInfo.incrementMapMapCount(self.scoreLabelCount, newStage, newLabel)
	end
end

function PetStatsInfo:onScoreStageChange(oldStage, newStage, label)
	self:onScoreStageAndLabelChange(oldStage, newStage, label, label)
end

function PetStatsInfo:onScoreLabelChange(stage, oldLabel, newLabel)
	self:onScoreStageAndLabelChange(stage, stage, oldLabel, newLabel)
end

function PetStatsInfo:onStarStageChange(petPrototypeId, oldStage, newStage)
	petPrototypeId = petPrototypeId or 0
	oldStage = oldStage or 0
	newStage = newStage or 0

	if oldStage == newStage then
		return
	end

	PetStatsInfo.decrementMapMapCount(self.starHist, 0, oldStage)
	PetStatsInfo.incrementMapMapCount(self.starHist, 0, newStage)

	if petPrototypeId ~= 0 then
		PetStatsInfo.decrementMapMapCount(self.starHist, petPrototypeId, oldStage)
		PetStatsInfo.incrementMapMapCount(self.starHist, petPrototypeId, newStage)
	end
end

function PetStatsInfo:onSkillNumChange(oldBasePetPrototypeId, oldSkillNum, newBasePetPrototypeId, newSkillNum)
	oldBasePetPrototypeId = oldBasePetPrototypeId or 0
	oldSkillNum = oldSkillNum or 0
	newBasePetPrototypeId = newBasePetPrototypeId or 0
	newSkillNum = newSkillNum or 0

	if oldBasePetPrototypeId == newBasePetPrototypeId and oldSkillNum == newSkillNum then
		return
	end

	PetStatsInfo.decrementMapMapCount(self.skillNumHist, 0, oldSkillNum)
	PetStatsInfo.incrementMapMapCount(self.skillNumHist, 0, newSkillNum)

	if oldBasePetPrototypeId ~= 0 then
		PetStatsInfo.decrementMapMapCount(self.skillNumHist, oldBasePetPrototypeId, oldSkillNum)
	end

	if newBasePetPrototypeId ~= 0 then
		PetStatsInfo.incrementMapMapCount(self.skillNumHist, newBasePetPrototypeId, newSkillNum)
	end
end

function PetStatsInfo:onPetSkillNumChange(oldPetInfo, petInfo)
	if not oldPetInfo or not petInfo then
		return
	end

	self:onSkillNumChange(oldPetInfo.basePetPrototypeId, PetStatsInfo.getSkillNum(oldPetInfo), petInfo.basePetPrototypeId, PetStatsInfo.getSkillNum(petInfo))
end

function PetStatsInfo:onPetTalentRarityChange(oldPetInfo, petInfo)
	if not oldPetInfo or not petInfo then
		return
	end

	self:removePetTalentRarityStats(oldPetInfo)
	self:addPetTalentRarityStats(petInfo)
end

function PetStatsInfo:onPetIdentityChange(oldPetInfo, petInfo)
	if not oldPetInfo or not petInfo then
		return
	end

	self:onPetGenderChange(oldPetInfo, petInfo)
	self:onPetRaceChange(oldPetInfo, petInfo)
	self:onPetTemplateChange(oldPetInfo, petInfo)
	self:onPetSpecialCharacterChange(oldPetInfo, petInfo)
	self:onPetStarChange(oldPetInfo, petInfo)
end

function PetStatsInfo:onPetChange(oldPetInfo, petInfo)
	self:onPetIdentityChange(oldPetInfo, petInfo)
	self:onPetScoreChange(oldPetInfo, petInfo)
	self:onPetSkillNumChange(oldPetInfo, petInfo)
	self:onPetTalentRarityChange(oldPetInfo, petInfo)
	self:onPetPrototypeLevelChange(oldPetInfo, petInfo)
	self:onPetTemplateLevelChange(oldPetInfo, petInfo)
	self:onPetIndividualLevelChange(oldPetInfo, petInfo)
end

return PetStatsInfo
