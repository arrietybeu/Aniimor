-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\PetHandbookMap.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local lume = require("Core.Common.lume")
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local ObjHelper = require("Common.ObjHelper")
local TriggerConst = require("Common.Const.TriggerConst")
local PetResearchUtils = require("Common.Utils.PetResearchUtils")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local CommonSwitch = require("Common.CommonSwitch")
local PetResearchCountryLevelData = require("Data.pet_research_country_level_data")
local PetResearchCountryCollectData = require("Data.pet_research_country_collect_data")
local PetBasePrototypeToPrototypeMap = require("Data.pet_base_prototype_to_prototype_map")
local PetResearchCountrySpeciesCollectData = require("Data.pet_research_country_species_collect_data")
local PetHandbookConfigData = require("Data.pet_handbook_config_data")
local MapAreaConfigData = require("Data.map_area_config_data")
local PetHandbookMap = class.LiteClass("PetHandbookMap", CustomDict)

if UNITY_EDITOR then
	local types = {
		ObjHelper.TYPE_PLAYER
	}

	function PetHandbookMap:getObj()
		local obj = self:getRootOwner()

		assert(ObjHelper.matchOneOf(obj, types))

		return obj
	end
else
	function PetHandbookMap:getObj()
		local obj = self:getRootOwner()

		return obj
	end
end

function PetHandbookMap:getInfo(petPrototypeId, upsert)
	if self[petPrototypeId] == nil and upsert and pg.component == "game" then
		local initDict = PetResearchUtils.genPetHandbookInitDict(petPrototypeId)

		if self.buildPetHandbookInfoInitDict then
			initDict = self:buildPetHandbookInfoInitDict(initDict)
		end

		self[petPrototypeId] = initDict
		self.cachedTraitUnlockdCountMap = {}
	end

	return self[petPrototypeId]
end

function PetHandbookMap:getTotalKnownCount(countryId)
	return self:getCountByIdAndStateMask(0, Const.PET_HBMSK_KNOWN, countryId)
end

function PetHandbookMap:getTotalCatchedCount(countryId)
	return self:getCountByIdAndStateMask(0, Const.PET_HBMSK_CATCHED, countryId)
end

function PetHandbookMap:getTotalShinyKnownCount(countryId)
	return self:getCountByIdAndStateMask(0, Const.PET_HBMSK_SHINY_KNOWN, countryId)
end

function PetHandbookMap:getTotalShinyCatchedCount(countryId)
	return self:getCountByIdAndStateMask(0, Const.PET_HBMSK_SHINY_CATCHED, countryId)
end

function PetHandbookMap:getTotalResearchedCount(countryId)
	return self:getCountByIdAndStateMask(0, Const.PET_HBMSK_RESEARCHED, countryId)
end

function PetHandbookMap:getTotalRainbowKnownCount(countryId)
	return self:getCountByIdAndStateMask(0, Const.PET_HBMSK_RAINBOW_KNOWN, countryId)
end

function PetHandbookMap:getTotalRainbowCatchedCount(countryId)
	return self:getCountByIdAndStateMask(0, Const.PET_HBMSK_RAINBOW_CATCHED, countryId)
end

function PetHandbookMap:hasStateMask(petPrototypeId, mask, groupType)
	groupType = groupType or Const.GROUP_TYPE_ANY

	return Utils.getBoolByPetPrototypeIdAndGroupType(petPrototypeId, groupType, function(innerPetPrototypeId)
		local info = self:getInfo(innerPetPrototypeId)

		return info and info:hasStateMask(mask)
	end)
end

function PetHandbookMap:isKnown(petPrototypeId, groupType)
	return self:hasStateMask(petPrototypeId, Const.PET_HBMSK_KNOWN, groupType)
end

function PetHandbookMap:isCatched(petPrototypeId, groupType)
	return self:hasStateMask(petPrototypeId, Const.PET_HBMSK_CATCHED, groupType)
end

function PetHandbookMap:isAllResearch(petPrototypeId, groupType)
	return self:hasStateMask(petPrototypeId, Const.PET_HBMSK_RESEARCHED, groupType)
end

function PetHandbookMap:isShinyKnown(petPrototypeId, groupType)
	return self:hasStateMask(petPrototypeId, Const.PET_HBMSK_SHINY_KNOWN, groupType)
end

function PetHandbookMap:isShinyCatched(petPrototypeId, groupType)
	return self:hasStateMask(petPrototypeId, Const.PET_HBMSK_SHINY_CATCHED, groupType)
end

function PetHandbookMap:isEvolveGet(petPrototypeId, groupType)
	return self:hasStateMask(petPrototypeId, Const.PET_HBMSK_EVOLVE_GET, groupType)
end

function PetHandbookMap:isRainbowKnown(petPrototypeId, groupType)
	return self:hasStateMask(petPrototypeId, Const.PET_HBMSK_RAINBOW_KNOWN, groupType)
end

function PetHandbookMap:isRainbowCatched(petPrototypeId, groupType)
	return self:hasStateMask(petPrototypeId, Const.PET_HBMSK_RAINBOW_CATCHED, groupType)
end

function PetHandbookMap:isAvatarUnlock(petPrototypeId, subIndex, groupType)
	groupType = groupType or Const.GROUP_TYPE_ANY

	return Utils.getBoolByPetPrototypeIdAndGroupType(petPrototypeId, groupType, function(innerPetPrototypeId)
		local info = self[innerPetPrototypeId]

		return info and info:isAvatarUnlock(subIndex)
	end)
end

function PetHandbookMap:isBodyEntryUnlock(petPrototypeId, bodyEntryId, groupType)
	groupType = groupType or Const.GROUP_TYPE_ANY

	return Utils.getBoolByPetPrototypeIdAndGroupType(petPrototypeId, groupType, function(innerPetPrototypeId)
		local info = self[innerPetPrototypeId]
		local researchInfo = info and info:getResearchInfo(Const.PET_RESEARCH.KEY_BODY_ENTRY, bodyEntryId)

		return researchInfo and researchInfo:isUnlock()
	end)
end

function PetHandbookMap:getCountryInfo(countryId, upsert)
	if self.petCountryMap[countryId] == nil and upsert and pg.component == "game" then
		self.petCountryMap[countryId] = self.petCountryMap[countryId] or {}
	end

	return self.petCountryMap[countryId]
end

function PetHandbookMap:getAreaIsActive(areaId)
	local areaInfo = self:getCountryInfo(areaId)

	if areaInfo then
		return areaInfo.unlocked
	end

	return false
end

function PetHandbookMap:getResearchStatus(petPrototypeId, researchKey, subIndex)
	local handbookInfo = self:getInfo(petPrototypeId)

	if handbookInfo == nil then
		return Const.PET_RESEARCH.STATUS_INIT
	end

	local researchInfo = handbookInfo:getResearchInfo(researchKey, subIndex)

	if researchInfo == nil then
		return Const.PET_RESEARCH.STATUS_INIT
	end

	return researchInfo.status
end

function PetHandbookMap:isResearchUnlocked(petPrototypeId, researchKey, subIndex)
	return self:getResearchStatus(petPrototypeId, researchKey, subIndex) == Const.PET_RESEARCH.STATUS_DONE
end

function PetHandbookMap:getLevel(petPrototypeId)
	local info = self[petPrototypeId]

	return info and info.level or 0
end

function PetHandbookMap:getCountryTotalExp(countryId)
	local countryConfig = countryId > 0 and MapAreaConfigData[countryId]

	if not countryConfig or countryConfig.belongNation == nil then
		return 0
	end

	if not CommonSwitch.PetHandbookCache then
		return self:_getCountryTotalExp(countryId)
	end

	local value = self.cachedCountryTotalExpMap[countryId]

	if value == nil then
		value = self:_getCountryTotalExp(countryId)

		if pg.component == "game" then
			self.cachedCountryTotalExpMap[countryId] = value
		end
	end

	return value
end

function PetHandbookMap:_getCountryTotalExp(countryId)
	local countryConfig = countryId > 0 and MapAreaConfigData[countryId]

	if not countryConfig or countryConfig.belongNation == nil then
		return 0
	end

	local totalExp = 0

	for petPrototypeId, info in self:items() do
		if Utils.isBasePetPrototypeId(petPrototypeId) and Utils.getPetCountryId(petPrototypeId) == countryId then
			totalExp = totalExp + info:getTotalExp()
		end
	end

	return totalExp
end

function PetHandbookMap:getCountryTotalLevel(countryId)
	local countryConfig = countryId > 0 and MapAreaConfigData[countryId]

	if not countryConfig or countryConfig.belongNation == nil then
		return 0, 0
	end

	local prcldd = PetResearchCountryLevelData[countryId]

	if prcldd == nil then
		return 0, 0
	end

	local curExp = self:getCountryTotalExp(countryId)
	local curLevel = 0

	while prcldd[curLevel] and curExp >= (prcldd[curLevel].needResearchPoint or 0) do
		curLevel = curLevel + 1
	end

	curLevel = curLevel - 1

	return curLevel, curExp - (prcldd[curLevel].needResearchPoint or 0)
end

function PetHandbookMap:getCountryTotalLevelDouble(countryId)
	local countryConfig = countryId > 0 and MapAreaConfigData[countryId]

	if not countryConfig or countryConfig.belongNation == nil then
		return 0
	end

	local level, exp = self:getCountryTotalLevel(countryId)
	local prcldd = PetResearchCountryLevelData[countryId]
	local maxExp = prcldd and prcldd[level] and prcldd[level].needResearchPoint or 0

	if maxExp == 0 then
		return level
	end

	return level + lume.clamp(exp / maxExp, 0, 1)
end

function PetHandbookMap:getMaxCountryTotalLevel()
	local maxLevel = 0

	for countryId, _ in pairs(PetResearchCountryLevelData) do
		local curLevel, _ = self:getCountryTotalLevel(countryId)

		maxLevel = math.max(maxLevel, curLevel)
	end

	return maxLevel
end

function PetHandbookMap:getCountryLevelRewardStatus(countryId, key)
	local countryConfig = countryId > 0 and MapAreaConfigData[countryId]

	if not countryConfig or countryConfig.belongNation == nil or not PetResearchCountryLevelData[countryId] then
		return Const.REWARD_STATUS_INIT
	end

	return self.petCountryMap[countryId] and self.petCountryMap[countryId].totalLevelRewardStatus[key] or Const.REWARD_STATUS_INIT
end

function PetHandbookMap:getFormKnownCount(countryId, petPrototypeId, onlySpecialForm)
	return self:getFormCountByIdAndStateMask(petPrototypeId, Const.PET_HBMSK_KNOWN, countryId, onlySpecialForm)
end

function PetHandbookMap:getFormCatchedCount(countryId, petPrototypeId, onlySpecialForm)
	return self:getFormCountByIdAndStateMask(petPrototypeId, Const.PET_HBMSK_CATCHED, countryId, onlySpecialForm)
end

function PetHandbookMap:getShinyFormKnownCount(countryId, petPrototypeId, onlySpecialForm)
	return self:getFormCountByIdAndStateMask(petPrototypeId, Const.PET_HBMSK_SHINY_KNOWN, countryId, onlySpecialForm)
end

function PetHandbookMap:getShinyFormCatchedCount(countryId, petPrototypeId, onlySpecialForm)
	return self:getFormCountByIdAndStateMask(petPrototypeId, Const.PET_HBMSK_SHINY_CATCHED, countryId, onlySpecialForm)
end

function PetHandbookMap:getRainbowFormKnownCount(countryId, petPrototypeId, onlySpecialForm)
	return self:getFormCountByIdAndStateMask(petPrototypeId, Const.PET_HBMSK_RAINBOW_KNOWN, countryId, onlySpecialForm)
end

function PetHandbookMap:getRainbowFormCatchedCount(countryId, petPrototypeId, onlySpecialForm)
	return self:getFormCountByIdAndStateMask(petPrototypeId, Const.PET_HBMSK_RAINBOW_CATCHED, countryId, onlySpecialForm)
end

function PetHandbookMap:getCountryCollectNum(countryId)
	local countryConfig = countryId > 0 and MapAreaConfigData[countryId]

	if not countryConfig or countryConfig.belongNation == nil then
		return 0
	end

	if not CommonSwitch.PetHandbookCache then
		return self:_getCountryCollectNum(countryId)
	end

	local value = self.cachedCountryCollectNumMap[countryId]

	if value == nil then
		value = self:_getCountryCollectNum(countryId)

		if pg.component == "game" then
			self.cachedCountryCollectNumMap[countryId] = value
		end
	end

	return value
end

function PetHandbookMap:_getCountryCollectNum(countryId)
	local countryConfig = countryId > 0 and MapAreaConfigData[countryId]

	if not countryConfig or countryConfig.belongNation == nil then
		return 0
	end

	local count = 0

	for petPrototypeId, info in self:items() do
		if Utils.getPetCountryId(petPrototypeId) == countryId and info:isCatched() then
			count = count + 1
		end
	end

	return count
end

function PetHandbookMap:getCountryCollectRate(countryId)
	local countryConfig = countryId > 0 and MapAreaConfigData[countryId]

	if not countryConfig or countryConfig.belongNation == nil then
		return 0
	end

	local collectNum = self:getCountryCollectNum(countryId)
	local maxCollectNum = PetHandbookConfigData.formCollectMaxMap[countryId] or 0

	if maxCollectNum == 0 then
		return 0
	end

	return collectNum / maxCollectNum
end

function PetHandbookMap:getCountryCollectLevel(countryId)
	local countryConfig = countryId > 0 and MapAreaConfigData[countryId]

	if not countryConfig or countryConfig.belongNation == nil then
		return 0, 0
	end

	local prcldd = PetResearchCountryCollectData[countryId]

	if prcldd == nil then
		return 0, 0
	end

	local curNum = self:getCountryCollectNum(countryId)
	local curLevel = 0

	while prcldd[curLevel] and curNum >= (prcldd[curLevel].collectNum or 0) do
		curLevel = curLevel + 1
	end

	curLevel = curLevel - 1

	return curLevel, curNum - (prcldd[curLevel].collectNum or 0)
end

function PetHandbookMap:getCountryCollectRewardStatus(countryId, key)
	local countryConfig = countryId > 0 and MapAreaConfigData[countryId]

	if not countryConfig or countryConfig.belongNation == nil or not PetResearchCountryCollectData[countryId] then
		return Const.REWARD_STATUS_INIT
	end

	return self.petCountryMap[countryId] and self.petCountryMap[countryId].collectLevelRewardStatus[key] or Const.REWARD_STATUS_INIT
end

function PetHandbookMap:getFormCountByIdAndStateMask(needPetPrototypeId, mask, needCountryId, onlySpecialForm, isRecalculting)
	needPetPrototypeId = needPetPrototypeId or 0
	mask = mask or 0

	if needCountryId ~= nil and needCountryId > 0 then
		local countryConfig = MapAreaConfigData[needCountryId]

		if not countryConfig or countryConfig.belongNation == nil then
			return 0
		end
	else
		needCountryId = nil
	end

	if not isRecalculting and needPetPrototypeId == 0 and mask ~= 0 and needCountryId ~= nil and not ToBool(onlySpecialForm) then
		local cachedCount = self.petCountryMap[needCountryId] and self.petCountryMap[needCountryId].stateMaskFormCountMap[mask]

		if cachedCount ~= nil then
			return cachedCount
		end
	end

	local count = 0

	if needPetPrototypeId == 0 then
		for petPrototypeId, info in self:items() do
			if (not ToBool(onlySpecialForm) or not Utils.isBasePetPrototypeId(petPrototypeId)) and (not needCountryId or Utils.getPetCountryId(petPrototypeId) == needCountryId) and info:hasStateMask(mask) then
				count = count + 1
			end
		end
	else
		local prototypeMap = PetBasePrototypeToPrototypeMap[Utils.getBasePetPrototypeId(needPetPrototypeId)] or {}

		for _, innerPetPrototypeId in ipairs(prototypeMap) do
			local info = self[innerPetPrototypeId]

			if info and (not ToBool(onlySpecialForm) or not Utils.isBasePetPrototypeId(innerPetPrototypeId)) and (not needCountryId or Utils.getPetCountryId(innerPetPrototypeId) == needCountryId) and info:hasStateMask(mask) then
				count = count + 1
			end
		end
	end

	return count
end

function PetHandbookMap:getKnownSpeciesCount(countryId)
	return self:getSpeciesCountByIdAndStateMask(Const.PET_HBMSK_KNOWN, countryId)
end

function PetHandbookMap:getCatchedSpeciesCount(countryId)
	return self:getSpeciesCountByIdAndStateMask(Const.PET_HBMSK_CATCHED, countryId)
end

function PetHandbookMap:getKnownShinySpeciesCount(countryId)
	return self:getSpeciesCountByIdAndStateMask(Const.PET_HBMSK_SHINY_KNOWN, countryId)
end

function PetHandbookMap:getCatchedShinySpeciesCount(countryId)
	return self:getSpeciesCountByIdAndStateMask(Const.PET_HBMSK_SHINY_CATCHED, countryId)
end

function PetHandbookMap:getKnownRainbowSpeciesCount(countryId)
	return self:getSpeciesCountByIdAndStateMask(Const.PET_HBMSK_RAINBOW_KNOWN, countryId)
end

function PetHandbookMap:getCatchedRainbowSpeciesCount(countryId)
	return self:getSpeciesCountByIdAndStateMask(Const.PET_HBMSK_RAINBOW_CATCHED, countryId)
end

function PetHandbookMap:getCountrySpeciesCollectNum(countryId)
	local countryConfig = countryId > 0 and MapAreaConfigData[countryId]

	if not countryConfig or countryConfig.belongNation == nil then
		return 0
	end

	if not CommonSwitch.PetHandbookCache then
		return self:_getCountrySpeciesCollectNum(countryId)
	end

	local value = self.cachedCountrySpeciesCollectNumMap[countryId]

	if value == nil then
		value = self:_getCountrySpeciesCollectNum(countryId)

		if pg.component == "game" then
			self.cachedCountrySpeciesCollectNumMap[countryId] = value
		end
	end

	return value
end

function PetHandbookMap:_getCountrySpeciesCollectNum(countryId)
	local countryConfig = countryId > 0 and MapAreaConfigData[countryId]

	if not countryConfig or countryConfig.belongNation == nil then
		return 0
	end

	local count = 0
	local seen = {}

	for petPrototypeId, info in self:items() do
		local basePetPrototypeId = Utils.getBasePetPrototypeId(petPrototypeId)

		if Utils.getPetCountryId(petPrototypeId) == countryId and info:isCatched() and not seen[basePetPrototypeId] then
			seen[basePetPrototypeId] = true
			count = count + 1
		end
	end

	return count
end

function PetHandbookMap:getCountrySpeciesCollectRate(countryId)
	local countryConfig = countryId > 0 and MapAreaConfigData[countryId]

	if not countryConfig or countryConfig.belongNation == nil then
		return 0
	end

	local collectNum = self:getCountrySpeciesCollectNum(countryId)
	local maxCollectNum = PetHandbookConfigData.speciesCollectMaxMap[countryId] or 0

	if maxCollectNum == 0 then
		return 0
	end

	return collectNum / maxCollectNum
end

function PetHandbookMap:getCountrySpeciesCollectLevel(countryId)
	local countryConfig = countryId > 0 and MapAreaConfigData[countryId]

	if not countryConfig or countryConfig.belongNation == nil then
		return 0, 0
	end

	local prcldd = PetResearchCountrySpeciesCollectData[countryId]

	if prcldd == nil then
		return 0, 0
	end

	local curNum = self:getCountrySpeciesCollectNum(countryId)
	local curLevel = 0

	while prcldd[curLevel] and curNum >= (prcldd[curLevel].collectNum or 0) do
		curLevel = curLevel + 1
	end

	curLevel = curLevel - 1

	return curLevel, curNum - (prcldd[curLevel].collectNum or 0)
end

function PetHandbookMap:getCountrySpeciesCollectRewardStatus(countryId, key)
	local countryConfig = countryId > 0 and MapAreaConfigData[countryId]

	if not countryConfig or countryConfig.belongNation == nil or not PetResearchCountrySpeciesCollectData[countryId] then
		return Const.REWARD_STATUS_INIT
	end

	return self.petCountryMap[countryId] and self.petCountryMap[countryId].speciesCollectLevelRewardStatus[key] or Const.REWARD_STATUS_INIT
end

function PetHandbookMap:getSpeciesCountByIdAndStateMask(mask, needCountryId, isRecalculting, player, needBasePetPrototypeId)
	needBasePetPrototypeId = Utils.getBasePetPrototypeId(needBasePetPrototypeId or 0)
	mask = mask or 0

	if needCountryId ~= nil and needCountryId > 0 then
		local countryConfig = MapAreaConfigData[needCountryId]

		if not countryConfig or countryConfig.belongNation == nil then
			return 0
		end
	else
		needCountryId = nil
	end

	if not isRecalculting and mask ~= 0 and needCountryId ~= nil and needBasePetPrototypeId == 0 then
		local cachedCount = self.petCountryMap[needCountryId] and self.petCountryMap[needCountryId].stateMaskSpeciesCountMap[mask]

		if cachedCount ~= nil then
			return cachedCount
		end
	end

	local subSpeciesCountMap = {}
	local count = 0

	if needBasePetPrototypeId == 0 then
		for petPrototypeId, info in self:items() do
			local basePetPrototypeId = Utils.getBasePetPrototypeId(petPrototypeId)

			if info:hasStateMask(mask) and (needCountryId == nil or Utils.getPetCountryId(petPrototypeId) == needCountryId) then
				if not subSpeciesCountMap[basePetPrototypeId] then
					count = count + 1
				end

				subSpeciesCountMap[basePetPrototypeId] = (subSpeciesCountMap[basePetPrototypeId] or 0) + 1
			end
		end
	else
		local prototypeMap = PetBasePrototypeToPrototypeMap[needBasePetPrototypeId] or {}

		for _, prototypeId in ipairs(prototypeMap) do
			if self[prototypeId] then
				local info = self[prototypeId]

				if info:hasStateMask(mask) and (needCountryId == nil or Utils.getPetCountryId(prototypeId) == needCountryId) then
					if not subSpeciesCountMap[needBasePetPrototypeId] then
						count = count + 1
					end

					subSpeciesCountMap[needBasePetPrototypeId] = (subSpeciesCountMap[needBasePetPrototypeId] or 0) + 1
				end
			end
		end
	end

	assert(lume.tableLength(subSpeciesCountMap) == count)

	return count
end

function PetHandbookMap:getCountByIdAndLevelMin(needPetPrototypeId, levelMin)
	local count = 0

	levelMin = levelMin or 0

	if needPetPrototypeId == 0 then
		local ids = {}

		for innerPrototypeId, info in self:items() do
			if levelMin == 0 or levelMin <= info.level then
				ids[#ids + 1] = innerPrototypeId
			end
		end

		count = Utils.getBasePetPrototypeIdCount(ids)
	else
		count = Utils.getBoolByPetPrototypeIdAndGroupType(needPetPrototypeId, Const.GROUP_TYPE_BASE, function(innerPetPrototypeId)
			local info = self[innerPetPrototypeId]

			return info and (levelMin == 0 or info.level >= levelMin)
		end) and 1 or 0
	end

	return count
end

function PetHandbookMap:getCountByIdAndStateMask(needPetPrototypeId, mask, needCountryId, isRecalculting)
	needPetPrototypeId = needPetPrototypeId or 0
	mask = mask or 0

	if needCountryId ~= nil and needCountryId > 0 then
		local countryConfig = MapAreaConfigData[needCountryId]

		if not countryConfig or countryConfig.belongNation == nil then
			return 0
		end
	else
		needCountryId = nil
	end

	if not isRecalculting and needPetPrototypeId == 0 and mask ~= 0 and needCountryId ~= nil then
		local cachedCount = self.petCountryMap[needCountryId] and self.petCountryMap[needCountryId].stateMaskCountMap[mask]

		if cachedCount ~= nil then
			return cachedCount
		end
	end

	local count = 0

	if needPetPrototypeId == 0 then
		local baseSet = {}

		for petPrototypeId, info in self:items() do
			if info:hasStateMask(mask) and (needCountryId == nil or Utils.getPetCountryId(petPrototypeId) == needCountryId) then
				local basePetPrototypeId = Utils.getBasePetPrototypeId(petPrototypeId)

				if not baseSet[basePetPrototypeId] then
					baseSet[basePetPrototypeId] = true
					count = count + 1
				end
			end
		end
	else
		count = Utils.getBoolByPetPrototypeIdAndGroupType(needPetPrototypeId, Const.GROUP_TYPE_ANY, function(innerPetPrototypeId)
			local info = self[innerPetPrototypeId]

			return info and info:hasStateMask(mask) and (needCountryId == nil or Utils.getPetCountryId(innerPetPrototypeId) == needCountryId)
		end) and 1 or 0
	end

	return count
end

function PetHandbookMap:getTraitUnlockedCount(needBasePetPrototypeId, needTraitId)
	needBasePetPrototypeId = needBasePetPrototypeId or 0
	needTraitId = needTraitId or 0

	if not CommonSwitch.PetHandbookCache or needTraitId ~= 0 then
		return self:_getTraitUnlockedCount(needBasePetPrototypeId, needTraitId)
	end

	local key1, key2 = needBasePetPrototypeId, needTraitId
	local value = self.cachedTraitUnlockdCountMap[key1] and self.cachedTraitUnlockdCountMap[key1][key2]

	if value == nil then
		value = self:_getTraitUnlockedCount(key1, key2)

		if pg.component == "game" then
			self.cachedTraitUnlockdCountMap[key1] = self.cachedTraitUnlockdCountMap[key1] or {}
			self.cachedTraitUnlockdCountMap[key1][key2] = value or 0
		end
	end

	return value
end

function PetHandbookMap:_getTraitUnlockedCount(needBasePetPrototypeId, needTraitId)
	local count = 0

	if needBasePetPrototypeId == 0 then
		for petPrototypeId, info in self:items() do
			if Utils.isBasePetPrototypeId(petPrototypeId) then
				count = count + info:getTraitResearchUnlockedCount(needTraitId)
			end
		end
	else
		count = Utils.getValueByPetPrototypeIdAndMergeType(needBasePetPrototypeId, Const.MERGE_TYPE_BASE, function(innerPetPrototypeId)
			local info = self[innerPetPrototypeId]

			return info and info:getTraitResearchUnlockedCount(needTraitId)
		end)
	end

	return count
end

function PetHandbookMap:getSkillUnlockedCount(needBasePetPrototypeId, needRare)
	local count = 0

	needRare = needRare or -1

	if needBasePetPrototypeId == 0 then
		for innerPetPrototypeId, info in self:items() do
			if Utils.isBasePetPrototypeId(innerPetPrototypeId) then
				count = count + info:getSkillUnlockedCount(needRare)
			end
		end
	else
		count = Utils.getValueByPetPrototypeIdAndMergeType(needBasePetPrototypeId, Const.MERGE_TYPE_BASE, function(innerPetPrototypeId)
			local info = self[innerPetPrototypeId]

			return info and info:getSkillUnlockedCount(needRare)
		end)
	end

	return count
end

function PetHandbookMap:getAvatarResearchedCount(needBasePetPrototypeId, needLabel, needCountryId)
	local count = 0

	needLabel = needLabel or -1

	if needCountryId ~= nil and needCountryId > 0 then
		local countryConfig = MapAreaConfigData[needCountryId]

		if not countryConfig or countryConfig.belongNation == nil then
			return 0
		end
	else
		needCountryId = nil
	end

	if needBasePetPrototypeId == 0 then
		for petPrototypeId, info in self:items() do
			if needCountryId == nil or Utils.getPetCountryId(petPrototypeId) == needCountryId then
				local researchedCount = info:getAvatarResearchedCount(needLabel)

				if researchedCount > 0 then
					count = count + 1
				end
			end
		end
	else
		count = Utils.getValueByPetPrototypeIdAndMergeType(needBasePetPrototypeId, Const.MERGE_TYPE_SUM, function(innerPetPrototypeId)
			local info = self[innerPetPrototypeId]
			local countryMatched = needCountryId == nil or Utils.getPetCountryId(innerPetPrototypeId) == needCountryId

			if info and countryMatched and info:getAvatarResearchedCount(needLabel) > 0 then
				return 1
			end

			return 0
		end)
	end

	return count
end

function PetHandbookMap:getCountByHistoryMaxLevelMin(needBasePetPrototypeId, needLevel)
	local count = 0

	needLevel = needLevel or 0

	if needBasePetPrototypeId == 0 then
		local ids = {}

		for petPrototypeId, info in self:items() do
			if needLevel <= info.petMaxLevel then
				ids[#ids + 1] = petPrototypeId
			end
		end

		count = Utils.getBasePetPrototypeIdCount(ids)
	else
		count = Utils.getValueByPetPrototypeIdAndMergeType(needBasePetPrototypeId, Const.MERGE_TYPE_BASE, function(innerPetPrototypeId)
			local info = self[innerPetPrototypeId]

			return info and info.petMaxLevel >= needLevel and 1 or 0
		end)
	end

	return count
end

function PetHandbookMap:getPetHistoryMaxLevel(needBasePetPrototypeId)
	local resLevel = 0

	if needBasePetPrototypeId == 0 then
		for _, info in self:items() do
			resLevel = math.max(resLevel, info.petMaxLevel)
		end
	else
		resLevel = Utils.getValueByPetPrototypeIdAndMergeType(needBasePetPrototypeId, Const.MERGE_TYPE_MAX, function(innerPetPrototypeId)
			local info = self[innerPetPrototypeId]

			return info and info.petMaxLevel
		end)
	end

	return resLevel
end

function PetHandbookMap:getReportResearchPointTotal()
	local total = 0

	for petPrototypeId, info in self:items() do
		if Utils.isBasePetPrototypeId(petPrototypeId) then
			for subType, typeInfo in info.researchPointMap:items() do
				total = total + typeInfo.researchPoint
			end
		end
	end

	return total
end

function PetHandbookMap:dumpReportResearchPointTotal()
	local res = {}

	for petPrototypeId, info in self:items() do
		if Utils.isBasePetPrototypeId(petPrototypeId) then
			res[petPrototypeId] = res[petPrototypeId] or {}

			for subType, typeInfo in info.researchPointMap:items() do
				res[petPrototypeId][subType] = string.format("count=%d point=%d", typeInfo.researchCount, typeInfo.researchPoint)
				res[petPrototypeId].total = (res[petPrototypeId].total or 0) + typeInfo.researchPoint
			end

			res.total = (res.total or 0) + (res[petPrototypeId].total or 0)
		end
	end

	return res
end

function PetHandbookMap:dump(onlyPrint, onlyBase)
	local res = {}
	local resReporting = self:dumpReportResearchPointTotal()

	for petPrototypeId, info in self:items() do
		if not onlyBase or Utils.isBasePetPrototypeId(petPrototypeId) then
			res[petPrototypeId] = info:dump()
			res[petPrototypeId].reportingInfo = table.tostring(resReporting[petPrototypeId] or {})
		end
	end

	if onlyPrint then
		print(inspect(res, {
			depth = 5
		}))
	else
		return res
	end
end

return PetHandbookMap
