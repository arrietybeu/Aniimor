-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetManagement\\PetManagementModel.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local UIModel = require("Guis.UIModel")
local Lume = require("Core.Common.lume")
local PetData = require("Data.pet_data")
local PetPrototypeData = require("Data.pet_prototype_data")
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local UIConst = require("Const.UIConst")
local Class = require("Core.Framework.Class")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PetEvolveData = require("Data.pet_evolve_data")
local PetTalentData = require("Data.pet_talent_data")
local PetResearchIdToNumber = require("Data.pet_research_id_to_number")
local GameConst = require("Common.Const.Const")
local PetLevelData = require("Data.pet_level_data")
local SkillTagData = require("Data.skill_tag_data")
local PetNatureData = require("Data.pet_nature_data")
local AbilityConst = require("Common.Const.AbilityConst")
local ElementNameToId = require("Data.element_name_to_id")
local PetCharacterData = require("Data.pet_character_data")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local PetSkillData = require("Data.pet_skill_data")
local PetManagementModel = Class.LightClass("PetManagementModel", UIModel)
local RedDotConst = require("Const.RedDotConst")
local PetConfigData = require("Data.pet_config_data")
local NoticeDef = require("Common.NoticeDef")
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")
local PetManagementUtils = require("Utils.PetManagementUtils")
local SysConfigData = require("Data.sys_config_data")
local RogueUtils = require("Utils.RogueUtils")

local function getPetBoxById(boxId)
	local petBoxMap = pg and pg.me and pg.me.petBoxMap

	if not petBoxMap or not boxId then
		return nil
	end

	return petBoxMap[boxId]
end

PetManagementModel.FULL_ROW_SLOT_COUNT = 6
PetManagementModel.FULL_PAGE_SLOT_COUNT = 30
PetManagementModel.FULL_BOX_COUNT = 24
PetManagementModel.ATTR_TYPE_ALL = 0
PetManagementModel.ATTR_TYPE_SPECIES = 1
PetManagementModel.ATTR_TYPE_TALENT = 2
PetManagementModel.RENAME_FOR_GROUP = 0
PetManagementModel.RENAME_FOR_PET = 1
PetManagementModel.RENAME_FOR_BOX = 2
PetManagementModel.SKILL_NAME = {
	normal = "ABILITY_NAME_NORMAL",
	ultimate = "ABILITY_NAME_ULTIMATE",
	skill = "ABILITY_NAME_SKILL",
	appear = "ABILITY_NAME_APPEAR"
}
PetManagementModel.MAX_EXPLORE_PETS_COUNT = 3

function PetManagementModel:ctor()
	self.petMaxLevel = table.maxn(PetLevelData)

	self:getFilter()
end

function PetManagementModel:getActiveFormFilters(filterData)
	local formFilters = {}

	for key, value in pairs(filterData or EMPTY_TABLE) do
		if value == true and type(key) == "string" and string.match(key, "^isForm%d+$") then
			formFilters[key] = true
		end
	end

	return formFilters
end

function PetManagementModel:appendFormFilters(filterData, formFilters)
	if not filterData or not formFilters then
		return
	end

	for key, value in pairs(formFilters) do
		if type(key) == "string" and string.match(key, "^isForm%d+$") then
			filterData[key] = value and true or false
		end
	end
end

function PetManagementModel:getSelectedFormTypeMap(filters)
	return PetManagementDataHelper.getSelectedFormTypeMap(filters)
end

function PetManagementModel:getGroupInfoById(groupId)
	if groupId > Const.MAX_FORMATION_COUNT then
		return
	end

	local petIds = self:getPetGroupPetsInModel(groupId)
	local player = pg.me
	local ret = {}

	for idx, petId in pairs(petIds) do
		local pet = player:getPetInfo(petId)
		local petInfo = self:setUpPetInfo(pet)

		petInfo.index = idx
		petInfo.empty = false
		ret[#ret + 1] = petInfo
	end

	return ret
end

function PetManagementModel:getSupportGroupInfoById(groupId)
	if groupId > Const.MAX_FORMATION_COUNT then
		return
	end

	local petIds = self:getPetGroupPetsInModel(groupId)
	local player = pg.me
	local ret = {
		{
			tIndex = 0,
			title = pg.getGameString("SUPPORT_TEAM_TITLE_1")
		}
	}

	if not next(petIds) then
		ret[#ret + 1] = {
			empty = true,
			tIndex = 1
		}
		ret[#ret + 1] = {
			tIndex = 0,
			title = pg.getGameString("SUPPORT_TEAM_TITLE_2")
		}
		ret[#ret + 1] = {
			empty = true,
			tIndex = 2
		}
		ret[#ret + 1] = {
			empty = true,
			tIndex = 2
		}
		ret[#ret + 1] = {
			empty = true,
			tIndex = 2
		}

		return ret
	end

	for idx, petId in pairs(petIds) do
		local pet = player:getPetInfo(petId)
		local petInfo = self:setUpPetInfo(pet)

		petInfo.index = idx
		petInfo.empty = false

		if idx == 1 then
			petInfo.tIndex = 1
			ret[#ret + 1] = petInfo
			ret[#ret + 1] = {
				tIndex = 0,
				title = pg.getGameString("SUPPORT_TEAM_TITLE_2")
			}
		else
			petInfo.tIndex = 2
			ret[#ret + 1] = petInfo
		end
	end

	local tCount = Lume.count(petIds)

	if tCount < 4 then
		for _ = 1, 4 - tCount do
			local t = {}

			t.empty = true
			t.tIndex = 2
			ret[#ret + 1] = t
		end
	end

	return ret
end

function PetManagementModel:getCurrentGroupInfo()
	local groupId = self:getSelectGroupId()

	return self:getGroupInfoById(groupId)
end

function PetManagementModel:getSinglePetInfo(petId)
	if not petId then
		return nil
	end

	local pet = pg.me:getPetInfo(petId)
	local petInfo = self:setUpPetInfo(pet)

	return petInfo
end

function PetManagementModel:checkPetInCurGroup(petId)
	local groupId = self:getSelectGroupId()
	local petIds = self:getPetGroupPetsInModel(groupId)

	for _, v in ipairs(petIds) do
		if v == petId then
			return true
		end
	end

	return false
end

function PetManagementModel:getExploreGroupInfoById(groupId)
	if groupId > Const.MAX_FORMATION_COUNT then
		return
	end

	local petIds = self:getPetExploreGroupPetsInModel(groupId)
	local player = pg.me
	local ret = {}

	for _, petId in pairs(petIds) do
		local pet, petInfo

		if petId == "" then
			petInfo = {}
			petInfo.empty = true
		else
			pet = player:getPetInfo(petId)
			petInfo = self:setUpPetInfo(pet)
			petInfo.empty = false
		end

		ret[#ret + 1] = petInfo
	end

	return ret
end

function PetManagementModel:getPetGroupPetsInModelByIndex(index)
	local petInfos = self:getGroupInfoById(self:getSelectGroupId())

	if petInfos[index] == nil then
		return nil
	end

	return petInfos[index].id
end

function PetManagementModel:getPetExploreGroupPetsInModelByIndex(index)
	local petInfos = self:getExploreGroupInfoById(self:getSelectGroupId())

	if petInfos[index] == nil then
		return nil
	end

	if petInfos[index].empty == true then
		return nil
	end

	return petInfos[index].id
end

function PetManagementModel:clearOnDismiss()
	self:setCurSelectPetId()
end

function PetManagementModel:getBoxInfoById(boxId, isHoverIn)
	local petBoxMap = pg and pg.me and pg.me.petBoxMap

	if not petBoxMap or not boxId or boxId > #petBoxMap then
		return
	end

	local sortCondition = self:getSelectSortId()

	if sortCondition == 0 or isHoverIn then
		local box = petBoxMap[boxId]

		if not box then
			return
		end

		local maxSlotCount = box.slotCount
		local pets = pg.me.pets
		local ret = {}

		for i = 1, maxSlotCount do
			local boxPetId = box[i]
			local pet = pets[boxPetId]
			local petInfo = self:setUpPetInfo(pet)

			ret[i] = petInfo
		end

		if isHoverIn then
			return ret
		end

		ret = self:sortTableBySortConditions(ret)

		return ret
	else
		local pets = pg.me.pets
		local count = 1
		local ret = {}

		for i = 1, #petBoxMap do
			local box = petBoxMap[i]

			if box then
				local maxSlotCount = box.slotCount

				for j = 1, maxSlotCount do
					local boxPetId = box[j]
					local pet = pets[boxPetId]

					if pet ~= nil then
						local petInfo = self:setUpPetInfo(pet)

						ret[count] = petInfo
						count = count + 1
					end
				end
			end
		end

		ret = self:sortTableBySortConditions(ret)

		return ret
	end
end

function PetManagementModel:countTotalPets()
	local total = 0
	local petBoxMap = pg.me.petBoxMap

	for i = 1, #petBoxMap do
		local box = petBoxMap[i]
		local boxCount = box.count

		total = total + boxCount
	end

	return total
end

function PetManagementModel:checkExposeFilter(filters)
	return filters and (filters.isRating1 or filters.isRating2 or filters.isRating3 or filters.isRating4) or false
end

function PetManagementModel:checkPetValidByFilterAndRecommend(pet, tempFilter, selectedFormTypeMap, hasSelectedForm)
	if self.inAutoFilterMode and (self.intelligentCommonTemplateIds and self.intelligentCommonTemplateIds[pet.templateId] == true or self.intelligentRecommendTemplateIds and self.intelligentRecommendTemplateIds[pet.templateId] == true) then
		return true
	end

	return self:checkPetValidByFilter(pet, tempFilter, selectedFormTypeMap, hasSelectedForm)
end

function PetManagementModel:getFilteredPetsInfo()
	self:filterTempProcess()

	local filters = self:getFilter()
	local tempFilter = Utils.deepCopyTable(filters)
	local selectedFormTypeMap, hasSelectedForm = self:getSelectedFormTypeMap(tempFilter)
	local hasRatingFilter = self:checkExposeFilter(self.recordFilter)
	local petBoxMap = pg.me.petBoxMap
	local pets = pg.me.pets
	local count = 1
	local ret = {}

	for i = 1, #petBoxMap do
		local box = petBoxMap[i]
		local maxSlotCount = box.slotCount

		for j = 1, maxSlotCount do
			local boxPetId = box[j]
			local pet = pets[boxPetId]

			if pet ~= nil then
				local valid, petInfo = self:checkPetValidByFilterAndRecommend(pet, tempFilter, selectedFormTypeMap, hasSelectedForm)

				if valid then
					petInfo = petInfo or self:setUpPetInfo(pet)

					if not petInfo.isCatchReportingStatus or not hasRatingFilter then
						ret[count] = petInfo
						count = count + 1
					end
				end
			end
		end
	end

	if self.inAutoFilterMode then
		local function sortFunc(a, b)
			return a.cp > b.cp
		end

		local roleMaxCp = {}
		local countLimitRet = {}

		for _, petInfo in ipairs(ret) do
			local petPrototypeId = Utils.getPetPetPrototypeId(petInfo.templateId)
			local prototypeData = PetPrototypeData[petPrototypeId] or {}
			local baseFormPet = prototypeData.baseFormPet or petPrototypeId

			if countLimitRet[baseFormPet] == nil then
				countLimitRet[baseFormPet] = {}
			end

			table.insert(countLimitRet[baseFormPet], petInfo)

			if not roleMaxCp[petInfo.petType] or roleMaxCp[petInfo.petType] < petInfo.cp then
				roleMaxCp[petInfo.petType] = petInfo.cp
			end
		end

		for baseFormPet, petInfos in pairs(countLimitRet) do
			table.sort(petInfos, sortFunc)

			local rate1 = PetManagementDataHelper.FUNCTION_ID_CP_FILTER_RATE_SAME_SPECIES[petInfos[1].petType]
			local cpLimit1 = petInfos[1].cp * rate1
			local rate2 = PetManagementDataHelper.FUNCTION_ID_CP_FILTER_RATE_SAME_ROLE[petInfos[1].petType]
			local cpLimit2 = (roleMaxCp[petInfos[1].petType] or 1) * rate2
			local countLimit = SysConfigData.IntelFilterSameSpeciesNumLimit

			for i = 1, #petInfos do
				if cpLimit1 > petInfos[i].cp or cpLimit2 > petInfos[i].cp then
					countLimit = math.min(i - 1, countLimit)

					break
				end
			end

			for i = #petInfos, countLimit + 1, -1 do
				table.remove(petInfos, i)
			end
		end

		ret = {}

		for _, petInfos in pairs(countLimitRet) do
			for _, petInfo in ipairs(petInfos) do
				table.insert(ret, petInfo)
			end
		end
	end

	ret = self:sortTableBySortConditions(ret, self.recordFilter)

	if #ret < self.FULL_PAGE_SLOT_COUNT then
		for i = #ret, self.FULL_PAGE_SLOT_COUNT - 1 do
			ret[#ret + 1] = {
				tIndex = 1,
				isEmpty = true
			}
		end
	else
		local mod = #ret % self.FULL_ROW_SLOT_COUNT

		if mod ~= 0 then
			local a = math.floor(#ret / self.FULL_ROW_SLOT_COUNT)

			for i = 1, (a + 1) * self.FULL_ROW_SLOT_COUNT - #ret do
				ret[#ret + 1] = {
					tIndex = 1,
					isEmpty = true
				}
			end
		end
	end

	self:filterTempProcess(true)

	return ret
end

function PetManagementModel:filterTempProcess(reset)
	if reset then
		local resetFilter = {
			keyword = self.recordFilter.keyword,
			isNormal = self.recordFilter.isNormal,
			isShiny = self.recordFilter.isShiny,
			isBoss = self.recordFilter.isBoss,
			isRainbow = self.recordFilter.isRainbow,
			isDark = self.recordFilter.isDark,
			elements = self.recordFilter.elements,
			isDPS = self.recordFilter.isDPS,
			isSup = self.recordFilter.isSup,
			isHeal = self.recordFilter.isHeal,
			isBreak = self.recordFilter.isBreak,
			isEnergy = self.recordFilter.isEnergy,
			isRating1 = self.recordFilter.isRating1,
			isRating2 = self.recordFilter.isRating2,
			isRating3 = self.recordFilter.isRating3,
			isRating4 = self.recordFilter.isRating4,
			isClimb = self.recordFilter.isClimb,
			isGlide = self.recordFilter.isGlide,
			isSwim = self.recordFilter.isSwim,
			isNone = self.recordFilter.isNone,
			isInBattle = self.recordFilter.isInBattle,
			isNotInBattle = self.recordFilter.isNotInBattle,
			isInExplore = self.recordFilter.isInExplore,
			isInHomeland = self.recordFilter.isInHomeland,
			isRareFeature = self.recordFilter.isRareFeature,
			isNotRareFeature = self.recordFilter.isNotRareFeature
		}

		for i = 0, 10 do
			local k = "isFavoriteType" .. i

			resetFilter[k] = self.recordFilter[k]
		end

		self:appendFormFilters(resetFilter, self.recordFilter.formFilters)
		self:setFilter(resetFilter)

		return
	end

	self.recordFilter = {
		keyword = self.filter.keyword,
		isNormal = self.filter.isNormal,
		isShiny = self.filter.isShiny,
		isBoss = self.filter.isBoss,
		isRainbow = self.filter.isRainbow,
		isDark = self.filter.isDark,
		elements = self.filter.elements,
		isDPS = self.filter.isDPS,
		isSup = self.filter.isSup,
		isHeal = self.filter.isHeal,
		isBreak = self.filter.isBreak,
		isEnergy = self.filter.isEnergy,
		isRating1 = self.filter.isRating1,
		isRating2 = self.filter.isRating2,
		isRating3 = self.filter.isRating3,
		isRating4 = self.filter.isRating4,
		isClimb = self.filter.isClimb,
		isGlide = self.filter.isGlide,
		isSwim = self.filter.isSwim,
		isNone = self.filter.isNone,
		isInBattle = self.filter.isInBattle,
		isNotInBattle = self.filter.isNotInBattle,
		isInExplore = self.filter.isInExplore,
		isInHomeland = self.filter.isInHomeland,
		isRareFeature = self.filter.isRareFeature,
		isNotRareFeature = self.filter.isNotRareFeature,
		formFilters = self:getActiveFormFilters(self.filter)
	}

	for i = 0, 10 do
		local k = "isFavoriteType" .. i

		self.recordFilter[k] = self.filter[k]
	end

	if not self.filter.isNormal and not self.filter.isShiny and not self.filter.isBoss and not self.filter.isRainbow and not self.filter.isDark then
		self.filter.isNormal = true
		self.filter.isShiny = true
		self.filter.isBoss = true
		self.filter.isRainbow = true
		self.filter.isDark = true
	end

	local anyFavTypeSelected = false

	for i = 1, 10 do
		if self.filter["isFavoriteType" .. i] then
			anyFavTypeSelected = true

			break
		end
	end

	if not anyFavTypeSelected then
		for i = 0, 10 do
			self.filter["isFavoriteType" .. i] = true
		end
	end

	if not self.filter.isRating1 and not self.filter.isRating2 and not self.filter.isRating3 and not self.filter.isRating4 then
		self.filter.isRating1 = true
		self.filter.isRating2 = true
		self.filter.isRating3 = true
		self.filter.isRating4 = true
	end

	if not self.filter.isInBattle and not self.filter.isNotInBattle and not self.filter.isInExplore and not self.filter.isInHomeland then
		self.filter.isInBattle = true
		self.filter.isNotInBattle = true
		self.filter.isInExplore = true
		self.filter.isInHomeland = true
	end

	if not self.filter.isDPS and not self.filter.isSup and not self.filter.isHeal and not self.filter.isBreak and not self.filter.isEnergy then
		self.filter.isDPS = true
		self.filter.isSup = true
		self.filter.isHeal = true
		self.filter.isBreak = true
		self.filter.isEnergy = true
	end

	if not self.filter.elements or Lume.count(self.filter.elements) <= 0 then
		local allElements = self:getAllElementsInfo()
		local temp = {}

		for _, v in pairs(allElements) do
			temp[v.name] = v.name
		end

		self.filter.elements = temp
	end
end

function PetManagementModel:sortTableBySortConditions(ret, filter)
	local sortCondition = self:getSelectSortId()
	local isDescending = not self:getSortSwitchStatus()
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

	if self.intelligentSortKeys then
		PetManagementDataHelper.templateFun(newT, isDescending, table.unpack(self.intelligentSortKeys))
	elseif sortCondition == PetManagementDataHelper.SORT_IDX.FAMILY then
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

	if not filter or self.inAutoFilterMode then
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

function PetManagementModel:checkPetValidByFilter(pet, filters, selectedFormTypeMap, hasSelectedForm)
	if not string.isNilOrEmpty(filters.keyword) then
		local petName = self:getPetName(pet.id)

		if not string.find(string.split(pg.getLocalizationText(petName), "<")[1], filters.keyword) then
			return false
		end
	end

	local pData = PetData[pet.templateId] or {}
	local _, elementNames = LuaUIUtils.getElementInfo(pData.elementType)
	local include = false

	for i = 1, #elementNames do
		if filters.elements[elementNames[i].element] ~= nil then
			include = true

			break
		end
	end

	if include == false then
		return false
	end

	if selectedFormTypeMap == nil then
		selectedFormTypeMap, hasSelectedForm = self:getSelectedFormTypeMap(filters)
	end

	if hasSelectedForm then
		local petFormTypeId = Utils.getPetFormIdByTemplateId(pet.templateId)

		if not selectedFormTypeMap[petFormTypeId] then
			return false
		end
	end

	local petExtra = self:setUpPetInfo(pet)
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
	elseif filters.isRainbow and petIsRainbow then
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

	local petFavoriteType = pet.favoriteType or 1

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
		return true, petExtra
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
		return true, petExtra
	end

	return true, petExtra
end

function PetManagementModel:getPetGroupPetsInModel(groupId)
	local groupInfo = pg.me.prepareFormationList[groupId] or {}
	local petIds = groupInfo.formation or {}

	return petIds:getRawTable()
end

function PetManagementModel:getPetExploreGroupPetsInModel(groupId)
	groupId = 1

	local groupInfo = pg.me.prepareFormationList[groupId] or {}
	local petIds = groupInfo.exploreFormation or {}

	petIds = petIds:getRawTable()

	local ret = {}

	if #petIds <= 0 then
		for i = 1, self.MAX_EXPLORE_PETS_COUNT do
			ret[#ret + 1] = ""
		end
	else
		for _, petId in pairs(petIds) do
			ret[#ret + 1] = petId
		end
	end

	return ret
end

function PetManagementModel:checkPetInWhichExploreSlot(petId)
	local explorePets = self:getPetExploreGroupPetsInModel()

	for i = 1, #explorePets do
		if explorePets[i] == petId then
			return i
		end
	end

	return nil
end

function PetManagementModel:getSelectGroupId()
	if not self.selectGroupId then
		self.selectGroupId = pg.me.curPetFormationIndex
	end

	return self.selectGroupId
end

function PetManagementModel:checkSelectGroupIdIsFight()
	return self.selectGroupId == pg.me.curPetFormationIndex
end

function PetManagementModel:setSelectGroupId(groupId)
	self.selectGroupId = groupId
end

function PetManagementModel:getSelectBoxId()
	if not self.selectBoxId then
		self.selectBoxId = pg.me.petBoxMap.curIndex
	end

	return self.selectBoxId
end

function PetManagementModel:setSelectBoxId(boxId)
	self.selectBoxId = boxId

	pg.me:serverMsg("RPC_CS_PetBoxSetCurIndex", boxId)
end

function PetManagementModel:getSelectSortId()
	if not self.selectSortId then
		self.selectSortId = 0
	end

	return self.selectSortId
end

function PetManagementModel:setSelectSortId(sortId)
	self.selectSortId = sortId
end

function PetManagementModel:getSortSwitchStatus()
	if self.isDescending == nil then
		self.isDescending = true
	end

	return self.isDescending
end

function PetManagementModel:setSortSwitchStatus(isDescending)
	self.isDescending = isDescending
end

function PetManagementModel:getFilter()
	if self.filter == nil then
		self.filter = {
			isRating3 = false,
			isRating2 = false,
			isRating1 = false,
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
			isEnergy = false,
			isBreak = false,
			isHeal = false,
			isSup = false,
			isDPS = false,
			isDark = false,
			isRainbow = false,
			isBoss = false,
			isShiny = false,
			isNormal = false,
			keyword = "",
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
			isRating4 = false,
			elements = {}
		}
	end

	return self.filter
end

function PetManagementModel:setFilter(data)
	data = data or {}
	self.filter = {
		keyword = data.keyword or "",
		isNormal = data.isNormal or false,
		isShiny = data.isShiny or false,
		isBoss = data.isBoss or false,
		isRainbow = data.isRainbow or false,
		isDark = data.isDark or false,
		isDPS = data.isDPS or false,
		isSup = data.isSup or false,
		isHeal = data.isHeal or false,
		isBreak = data.isBreak or false,
		isEnergy = data.isEnergy or false,
		isRating1 = data.isRating1 or false,
		isRating2 = data.isRating2 or false,
		isRating3 = data.isRating3 or false,
		isRating4 = data.isRating4 or false,
		isClimb = data.isClimb or false,
		isGlide = data.isGlide or false,
		isSwim = data.isSwim or false,
		isNone = data.isNone or false,
		isInBattle = data.isInBattle or false,
		isNotInBattle = data.isNotInBattle or false,
		isInExplore = data.isInExplore or false,
		isInHomeland = data.isInHomeland or false,
		isRareFeature = data.isRareFeature or false,
		isNotRareFeature = data.isNotRareFeature or false,
		elements = data.elements or {}
	}

	for i = 0, 10 do
		local k = "isFavoriteType" .. i

		self.filter[k] = data[k] or false
	end

	self:appendFormFilters(self.filter, data)
	self:appendFormFilters(self.filter, data.formFilters)
end

function PetManagementModel:applyIntelligentFilter(filterId)
	local IntelligentFilterData = require("Data.intelligent_filter_data")
	local cfg = IntelligentFilterData[filterId]

	if not cfg then
		return false
	end

	local filter = Utils.deepCopyTable(PetManagementDataHelper.filter) or {}
	local rarityMap = {
		rainbow = "isRainbow",
		boss = "isBoss",
		shiny = "isShiny",
		normal = "isNormal",
		dark = "isDark"
	}

	if cfg.rarity then
		for _, v in ipairs(cfg.rarity) do
			local key = rarityMap[string.lower(v)]

			if key then
				filter[key] = true
			end
		end
	end

	if cfg.element then
		filter.elements = {}

		for _, v in ipairs(cfg.element) do
			filter.elements[v] = v
		end
	end

	if cfg.talentType then
		for _, v in ipairs(cfg.talentType) do
			filter["isRating" .. v] = true
		end
	end

	local funcMap = {
		Sup = "isSup",
		Break = "isBreak",
		Energy = "isEnergy",
		DPS = "isDPS",
		Heal = "isHeal"
	}

	if cfg.functionId then
		for _, v in ipairs(cfg.functionId) do
			local key = funcMap[v]

			if key then
				filter[key] = true
			end
		end
	end

	self:setFilter(filter)

	self.intelligentCommonTemplateIds = PetManagementUtils.buildCommonPetTemplateIdSet(cfg.commonPetRef)
	self.intelligentRecommendTemplateIds = PetManagementUtils.buildRecommendPetTemplateIdSet(cfg.recommendPetRef)

	if cfg.orderTier and #cfg.orderTier > 0 then
		local fieldMap = PetManagementDataHelper.SORT_TIER_FIELD_MAP
		local tailFields = {
			"labelScore",
			"rating",
			"level",
			"hasRareFeature",
			"reverseTime"
		}
		local usedFields = {}
		local sortKeys = {}

		for _, tierName in ipairs(cfg.orderTier) do
			local field = fieldMap[tierName]

			if field and not usedFields[field] then
				table.insert(sortKeys, field)

				usedFields[field] = true
			end
		end

		for _, field in ipairs(tailFields) do
			if not usedFields[field] then
				table.insert(sortKeys, field)
			end
		end

		self.intelligentSortKeys = sortKeys

		local firstTierName = cfg.orderTier[1]
		local sortIdx = PetManagementDataHelper.SORT_IDX[firstTierName] or PetManagementDataHelper.SORT_IDX.FUNCTION_ID

		self:setSelectSortId(sortIdx)
	end

	return true
end

function PetManagementModel:clearIntelligentFilter()
	self.intelligentSortKeys = nil
	self.intelligentRecommendTemplateIds = nil
	self.intelligentCommonTemplateIds = nil
end

function PetManagementModel:getAllElementsInfo()
	local data = {}

	for k, v in pairs(ElementNameToId) do
		if k ~= "null" then
			local d = {}

			d.name = k
			data[#data + 1] = d
		end
	end

	return data
end

function PetManagementModel:parsePetInfo(petId)
	return pg.me:getPetInfo(petId)
end

function PetManagementModel:getPetIconName(pet)
	if not pet or not pet.templateId then
		return ""
	end

	local pData = PetData[pet.templateId] or {}

	return pData.iconName
end

function PetManagementModel:setUpPetInfo(pet)
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
	petInfo.name = self:getPetName(pet.id)
	petInfo.iconName = pData.iconName

	local cp = self:getCpValue(pet.id)

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
	petInfo.isRainbow = Utils.isRainbowTypeByTemplateId(pet.templateId)
	petInfo.isBlackRainbow = Utils.isBlackRainbowTypeByTemplateId(pet.templateId)
	petInfo.formQuality = Utils.getPetFormQualityByTemplateId(pet.templateId)
	petInfo.labelInfo = labelInfo
	petInfo.race = pData.species

	local natureIndex = pet.nature or 0

	petInfo.nature = PetNatureData[natureIndex] and PetNatureData[natureIndex].name or ""
	petInfo.maxExp = self:getCurMaxExp(pet.level)
	petInfo.bodySizeType = pet.bodySizeType

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
	petInfo.favoriteType = pet.favoriteType
	petInfo.isValidFavorite = pet.favoriteType > 0
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
	petInfo.functionIdScore = PetManagementDataHelper.FUNCTION_ID_ORDER[petType] or 99
	petInfo.exploreSkillsLevel = {
		canClimb = pData.canClimb ~= nil and pData.canClimb or nil,
		canGlide = pData.canFly ~= nil and pData.canFly or nil,
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

	petInfo.breedTalent = {}

	local talentList = petInfo.talentList

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

	for i = #petInfo.breedTalent + 1, 4 do
		petInfo.breedTalent[i] = {
			empty = true
		}
	end

	local slot = self:checkPetInWhichExploreSlot(pet.id) or 4

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

function PetManagementModel:getCpValue(petId)
	local pet = pg.me:getPetInfo(petId)

	return pet and pet:getCpValue() or 0
end

function PetManagementModel:getCurMaxExp(level)
	return PetLevelData[math.min(level + 1, self.petMaxLevel)].needExp
end

function PetManagementModel:trySyncRename(newName, renameType, id)
	if renameType == self.RENAME_FOR_PET then
		if not self.curSelectPetId then
			return
		end

		pg.me:serverMsg("RPC_CS_CustomPetName", id, newName)
	elseif renameType == self.RENAME_FOR_GROUP then
		pg.me:serverMsg("RPC_CS_RenamePrepareFormation", id, newName)
	elseif renameType == self.RENAME_FOR_BOX then
		pg.me:serverMsg("RPC_CS_PetBoxRename", id, newName)
	end
end

function PetManagementModel:getCurCharacter(petId)
	local pet = pg.me:getPetInfo(petId)
	local controlFeatureId = pet.characterInfo.curCharacter
	local featureInfo = PetCharacterData[controlFeatureId]

	if featureInfo then
		local feature = Lume.clone(featureInfo)

		feature.featureId = controlFeatureId

		return feature, controlFeatureId
	end
end

function PetManagementModel:getPetSkillInfos(petId, type)
	local abilityType, ability
	local petInfo = pg.me:getPetInfo(petId)

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
		abilityInfo.isRare = AbilityUtils.isRareAbilityId(ability.abilityId, petInfo.templateId)
		abilityInfo.isUltimate = abilityParamData.skillType == 4

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

		local paramId = AbilityUtils.getAbilityParamId(abilityInfo.abilityId)

		abilityInfo.paramId = paramId

		local basePetPrototypeId = Utils.getRefIdByPetPrototypeId(petInfo.petPrototypeId)
		local skData = PetSkillData[basePetPrototypeId]
		local originParamId = paramId
		local psdd = skData and skData[paramId]

		if not psdd and skData then
			for origId, origData in pairs(skData) do
				if origData.enhancedSkillId == paramId then
					originParamId = origId
					psdd = origData

					break
				end
			end
		end

		abilityInfo.originParamId = originParamId

		local hasGlazePath = psdd and psdd.enhancedSkillId and true or false

		abilityInfo.hasGlazePath = hasGlazePath

		if hasGlazePath then
			abilityInfo.enhancedSkillId = psdd.enhancedSkillId
			abilityInfo.glazeConsume = psdd.upgradeConsume or PetConfigData.skillUpgradeConsume

			local alreadyGlazed = originParamId ~= paramId or petInfo.unlockedAbilityMap[psdd.enhancedSkillId] ~= nil

			abilityInfo.alreadyGlazed = alreadyGlazed
			abilityInfo.canGlaze = petInfo.unlockedAbilityMap[originParamId] ~= nil and not alreadyGlazed
		else
			abilityInfo.canGlaze = false
		end

		return abilityInfo
	end

	return nil
end

function PetManagementModel:getGroupNameInfo(groupIdx)
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
		local gender = pet.gender
		local isShiny = Utils.isLabelShiny(label)
		local cp = self:getCpValue(pet.id)

		ret.pets[#ret.pets + 1] = {
			iconName = iconName,
			cp = cp,
			label = label,
			gender = gender,
			isShiny = isShiny,
			id = pet.id
		}
	end

	return ret
end

function PetManagementModel:getBoxNameInfo(boxIdx)
	local petBoxMap = pg.me.petBoxMap
	local ret = {}

	ret.idx = boxIdx
	ret.customName = petBoxMap[boxIdx].customName
	ret.countNum = petBoxMap[boxIdx].count .. "/" .. petBoxMap[boxIdx].slotCount
	ret.count = petBoxMap[boxIdx].count
	ret.slotCount = petBoxMap[boxIdx].slotCount

	return ret
end

function PetManagementModel:getGroupInfos()
	local groupInfos = {}

	for idx = 1, Const.MAX_FORMATION_COUNT do
		local groupInfo = {
			idx = idx
		}

		groupInfos[idx] = groupInfo
	end

	return groupInfos
end

function PetManagementModel:getBoxInfos()
	local boxInfos = {}
	local petBoxMapSequence = pg.me.petBoxMap.sequence:getRawTable()

	for idx = 1, #petBoxMapSequence do
		local boxInfo = self:getBoxNameInfo(petBoxMapSequence[idx])

		boxInfos[idx] = boxInfo
	end

	return boxInfos
end

function PetManagementModel:getSortInfos()
	local sortInfos = {}
	local sortInfo1 = {}

	sortInfo1.idx = 1
	sortInfo1.name = pg.getGameString("SORT_TYPE_1")

	local sortInfo2 = {}

	sortInfo2.idx = 2
	sortInfo2.name = pg.getGameString("SORT_TYPE_4")

	local sortInfo3 = {}

	sortInfo3.idx = 3
	sortInfo3.name = pg.getGameString("SORT_TYPE_2")

	local sortInfo4 = {}

	sortInfo4.idx = 4
	sortInfo4.name = pg.getGameString("SORT_TYPE_5")
	sortInfos[1] = sortInfo1
	sortInfos[2] = sortInfo2
	sortInfos[3] = sortInfo3
	sortInfos[4] = sortInfo4

	return sortInfos
end

function PetManagementModel:modifyPrepareFormation(oldUuid, newUuid)
	if oldUuid == newUuid then
		return
	end

	local player = pg.me

	if player:isInCombat() then
		pg.global.showBubbleMessageRaw(pg.getGameString("IN_COMBAT_SWITCH_PET_TIP"))

		return
	end

	local selectId = self:getSelectGroupId()
	local petIds = self:getPetGroupPetsInModel(selectId)
	local isNew = self:checkIsNewUuid(petIds, newUuid)

	if not newUuid then
		local temp = {}

		for _, uuid in pairs(petIds) do
			if uuid ~= oldUuid then
				temp[#temp + 1] = uuid
			end
		end

		petIds = temp
	elseif #petIds < GameConst.PET_PREPARE_NUM_LIMIT and (oldUuid == "DragArea" or oldUuid == "empty") then
		if isNew then
			petIds[#petIds + 1] = newUuid
		end
	elseif self:checkInCurrentFight(oldUuid) then
		for idx, uuid in pairs(petIds) do
			if uuid == oldUuid then
				petIds[idx] = newUuid
			end

			if uuid == newUuid then
				petIds[idx] = oldUuid
			end
		end
	end

	if newUuid then
		local petInfo = player:getPetInfo(newUuid)

		if not petInfo then
			return
		end

		if player:isPetPutInHomeland(petInfo) then
			pg.global.showBubbleMessage(NoticeDef.HOME_ERROR_PET_IN_HOMELAND)

			return
		end
	end

	pg.me:serverMsg("RPC_CS_ModifyPrepareFormation", selectId, petIds, true)
end

function PetManagementModel:modifyExplorePrepareFormation(index, newId)
	local player = pg.me

	if player:isInCombat() then
		pg.global.showBubbleMessageRaw(pg.getGameString("IN_COMBAT_SWITCH_PET_TIP"))

		return
	end

	if player.inExploreState then
		pg.global.showBubbleMessageRaw(pg.getGameString("IN_EXPLORE_SWITCH_PET_TIP"))

		return
	end

	local selectId = 1
	local petIds = self:getPetExploreGroupPetsInModel(selectId)

	petIds[index] = newId

	if not string.isNilOrEmpty(newId) then
		local petInfo = player:getPetInfo(newId)

		if not petInfo then
			return
		end

		if player:isPetPutInHomeland(petInfo) then
			pg.global.showBubbleMessage(NoticeDef.HOME_ERROR_PET_IN_HOMELAND)

			return
		end
	end

	pg.me:serverMsg("RPC_CS_ModifyPrepareFormation", selectId, petIds, false)
end

function PetManagementModel:checkTryToGroup(dropName)
	return self:checkInCurrentFight(dropName) or dropName == "empty"
end

function PetManagementModel:syncFightGroup()
	local player = pg.me
	local pets = player.pets
	local prepare = player.prepareFormationList[self.selectGroupId]

	for i = 1, #prepare.formation do
		local pet = pets[prepare.formation[i]]

		if not player:checkCanControlPetWithEnoughSpaceByTemplateId(pet.templateId) then
			return
		end
	end

	pg.me:serverMsg("RPC_CS_SelectPrepareFormation", self.selectGroupId)
end

function PetManagementModel:checkInCurrentFight(petId)
	local selectId = self:getSelectGroupId()
	local petIds = self:getPetGroupPetsInModel(selectId)

	for _, pId in pairs(petIds) do
		if pId == petId then
			return true
		end
	end

	return false
end

function PetManagementModel:switchPreparePet(petId1, petId2)
	local selectId = self:getSelectGroupId()
	local petIds = self:getPetGroupPetsInModel(selectId)

	for idx, petId in pairs(petIds) do
		if petId == petId1 then
			petIds[idx] = petId2
		end

		if petId == petId2 then
			petIds[idx] = petId1
		end
	end

	pg.me:serverMsg("RPC_CS_ModifyPrepareFormation", selectId, petIds, true)
end

function PetManagementModel:switchExplorePreparePet(index1, index2)
	local selectId = self:getSelectGroupId()
	local petIds = self:getPetExploreGroupPetsInModel(selectId)
	local petId1 = petIds[index1]
	local petId2 = petIds[index2]

	petIds[index1] = petId2
	petIds[index2] = petId1

	pg.me:serverMsg("RPC_CS_ModifyPrepareFormation", selectId, petIds, false)
end

function PetManagementModel:setCurSelectPetId(petId)
	self.curSelectPetId = petId
end

function PetManagementModel:getCurPetName()
	if self.curSelectPetId then
		return self:getPetName(self.curSelectPetId)
	end
end

function PetManagementModel:getPetName(petId, withoutSuffix)
	local pet = pg.me:getPetInfo(petId)

	if not pet then
		return ""
	end

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

function PetManagementModel:getPetCustomName(petId)
	local pet = pg.me:getPetInfo(petId)

	return pet.customName or ""
end

function PetManagementModel:getCurGroupName()
	local nameInfo = self:getGroupNameInfo(self.selectGroupId)

	if nameInfo.customName and nameInfo.customName ~= "" then
		return nameInfo.customName
	end

	return pg.getGameString("DEFAULT_GROUP_NAME") .. " " .. self.selectGroupId
end

function PetManagementModel:getGroupNameByIndex(index)
	local nameInfo = self:getGroupNameInfo(index)

	if nameInfo.customName and nameInfo.customName ~= "" then
		return nameInfo.customName
	end

	return pg.getGameString("DEFAULT_GROUP_NAME") .. " " .. index
end

function PetManagementModel:getCurBoxName()
	local nameInfo = self:getBoxNameInfo(self.selectBoxId)

	if nameInfo.customName and nameInfo.customName ~= "" then
		return nameInfo.customName
	end

	return pg.getGameString("DEFAULT_PET_BOX_NAME") .. " " .. self.selectBoxId
end

function PetManagementModel:getBoxNameById(id)
	local nameInfo = self:getBoxNameInfo(id)

	if nameInfo.customName and nameInfo.customName ~= "" then
		return nameInfo.customName
	end

	return pg.getGameString("DEFAULT_PET_BOX_NAME") .. " " .. id
end

function PetManagementModel:findPetIdByBoxIndexAndSlotIndex(boxIndex, slotIndex)
	local petBox = getPetBoxById(boxIndex)

	if not petBox or not slotIndex or slotIndex > petBox.slotCount then
		return nil
	end

	return petBox[slotIndex]
end

function PetManagementModel:getBoxSequenceInfo()
	local boxSequenceInfos = {}
	local sequence = pg.me.petBoxMap.sequence

	for i = 1, #sequence do
		local seqId = {}

		seqId.index = sequence[i]
		boxSequenceInfos[i] = seqId
	end

	return boxSequenceInfos
end

function PetManagementModel:getFirstValidSlotByBoxId(boxId)
	local box = getPetBoxById(boxId)

	if not box then
		return nil
	end

	if box.slotCount == box.count then
		return nil
	end

	for i = 1, box.slotCount do
		if box[i] == nil then
			return i
		end
	end

	return nil
end

function PetManagementModel:checkBoxIsFull(boxId)
	local box = getPetBoxById(boxId)

	if not box then
		return true
	end

	return box.count >= PetManagementModel.FULL_BOX_COUNT
end

function PetManagementModel:checkBoxContainsPet(boxId, petId)
	local box = getPetBoxById(boxId)

	if not box then
		return false
	end

	if box.count <= 0 then
		return false
	end

	for i = 1, box.slotCount do
		if box[i] == petId then
			return true
		end
	end

	return false
end

function PetManagementModel:findBoxIdByPetId(petId)
	local petBoxMap = pg and pg.me and pg.me.petBoxMap or {}

	for i = 1, #petBoxMap do
		local box = petBoxMap[i]

		if box then
			local maxSlotCount = box.slotCount

			for j = 1, maxSlotCount do
				if box[j] == petId then
					return i, j
				end
			end
		end
	end

	return nil
end

function PetManagementModel:findPetIdByTemplateId(templateId)
	if not templateId then
		return nil
	end

	local petBoxMap = pg and pg.me and pg.me.petBoxMap or {}
	local pets = pg and pg.me and pg.me.pets or {}

	for i = 1, #petBoxMap do
		local box = petBoxMap[i]

		if box then
			local maxSlotCount = box.slotCount

			for j = 1, maxSlotCount do
				local boxPetId = box[j]
				local pet = boxPetId and pets[boxPetId]

				if pet and pet.templateId == templateId then
					return boxPetId, i, j
				end
			end
		end
	end

	return nil
end

function PetManagementModel:getRemainSlotsCountByBoxId(boxId)
	local box = getPetBoxById(boxId)

	if not box then
		return 0
	end

	return box.slotCount - box.count
end

function PetManagementModel:getSlotsIndexByNumRequired(boxId, num, startIndex)
	local box = getPetBoxById(boxId)

	if not box or not num or num <= 0 or not startIndex then
		return {}
	end

	local maxSlotCount = box.slotCount
	local slots = {}

	slots[#slots + 1] = startIndex

	if num <= #slots then
		return slots
	end

	for i = startIndex + 1, maxSlotCount do
		if not box[i] then
			slots[#slots + 1] = i

			if num <= #slots then
				break
			end
		end
	end

	if num > #slots then
		for i = 1, maxSlotCount do
			if not box[i] then
				slots[#slots + 1] = i

				if num <= #slots then
					return slots
				end
			end
		end
	else
		return slots
	end
end

function PetManagementModel:checkIsNewUuid(petids, newUuid)
	local isNew = true

	for _, uuid in pairs(petids) do
		if newUuid == uuid then
			isNew = false

			break
		end
	end

	return isNew
end

function PetManagementModel:checkIfOnlyOnePetLeft()
	local count = 0
	local petBoxMap = pg.me.petBoxMap

	for i = 1, #petBoxMap do
		count = count + petBoxMap[i].count
	end

	return count == 1
end

function PetManagementModel:checkPetExistsInAnyPetBall(petId)
	local petBallMap = pg.me.petBallMap

	if petBallMap == nil then
		return false
	end

	for k, v in pairs(petBallMap) do
		if Utils.isTable(v) and (petBallMap[k].petId == petId or petBallMap[k].subPetId == petId) then
			return true
		end
	end

	return false
end

function PetManagementModel:checkEvolveBtnValid(petTemplateId, canEvolve)
	if not petTemplateId then
		return false
	end

	if PetEvolveData[petTemplateId] and PetEvolveData[petTemplateId][1] and PetEvolveData[petTemplateId][1].targetPetId then
		return canEvolve
	else
		return false
	end
end

function PetManagementModel:redDot_SetPetRedDot(boxId, petId, button, isShow)
	pg.global.setRedDot(string.format(RedDotConst.RedDotPath.PET_MANAGER_PET_LIST_ITEM, boxId, petId), button, isShow, RedDotConst.RedDotStyle.NEW)
end

function PetManagementModel:redDot_SetBoxRedDot(boxId, button)
	pg.global.setPreViewRedDot(string.format(RedDotConst.RedDotPath.PET_MANAGER_BOX_LIST_ITEM, boxId), button, function()
		return self:redDot_CheckBoxShowState(boxId)
	end)
end

function PetManagementModel:redDot_CheckBoxShowState(boxId)
	local petBoxMap = pg.me.petBoxMap
	local box = petBoxMap[boxId]

	for i = 1, box.slotCount do
		local petId = box[i]

		if petId and self:redDot_GetPetState(petId) then
			return RedDotConst.RedDotStyle.NEW
		end
	end

	return RedDotConst.RedDotStyle.NONE
end

function PetManagementModel:redDot_GetPetState(petId)
	local isNewPet = pg.me:getRedDotRecord(Const.CLIENT_KEY.PET_NEW_RED_DOT, petId, false)

	return isNewPet
end

function PetManagementModel:redDot_RecordPetState(petId)
	if pg.game.petManage:shouldSkipPetRedDotRecord(pg.me, petId) then
		return
	end

	pg.me:setRedDotRecord(Const.CLIENT_KEY.PET_NEW_RED_DOT, petId, nil)
end

function PetManagementModel:redDot_DeletePetState(petId)
	if pg.game.petManage:shouldSkipPetRedDotRecord(pg.me, petId) then
		return
	end

	pg.me:setRedDotRecord(Const.CLIENT_KEY.PET_NEW_RED_DOT, petId, nil)
end

function PetManagementModel:redDot_refreshSlot(boxId, petId)
	pg.global.refreshRedDotState(string.format(RedDotConst.RedDotPath.PET_MANAGER_PET_LIST_ITEM, boxId, petId))
end

function PetManagementModel:redDot_Save()
	pg.global.prefsCacheUtils:save()
end

function PetManagementModel:redDot_JointPetEvoNewKey(petTemplateId, branchId)
	return "evo" .. petTemplateId .. "_" .. branchId
end

function PetManagementModel:redDot_GetPetEvoNewState(petTemplateId, branchId)
	local isNewPet = pg.me:getRedDotRecord(Const.CLIENT_KEY.PET_EVOLVE_RED_DOT, self:redDot_JointPetEvoNewKey(petTemplateId, branchId), true)

	return isNewPet
end

function PetManagementModel:redDot_SetPetEvoNewRedDot(petTemplateId, branchId, button, isShow)
	pg.global.setRedDot(string.format(RedDotConst.RedDotPath.PET_CAN_EVOLVE_NEW, petTemplateId, branchId), button, isShow, RedDotConst.RedDotStyle.NEW)
end

function PetManagementModel:redDot_RecordPetEvoNewState(petTemplateId, branchId)
	pg.me:setRedDotRecord(Const.CLIENT_KEY.PET_EVOLVE_RED_DOT, self:redDot_JointPetEvoNewKey(petTemplateId, branchId), false)
end

function PetManagementModel:recyclePet(petList)
	local petManage = pg.game.petManage

	if pg.me.isRecycling or petManage:hasRecyclingPet(petList) then
		return
	end

	petManage:markRecyclingPets(petList)
	pg.me:refreshRecyclingStatus(true)
	pg.me:serverMsg("RPC_CS_RecyclePet", petList, function(noticeId)
		pg.me:refreshRecyclingStatus(false)

		if noticeId ~= NoticeDef.SUCCESS then
			petManage:unmarkRecyclingPets(petList)
		end
	end)
end

function PetManagementModel:containsAllElements(petInfos, tableB)
	local elementSet = {}

	for _, data in pairs(petInfos) do
		if data.id then
			local lockStatus = self:getLockStatus(data)
			local isValidFavorite = lockStatus.favoriteType > 0

			if not isValidFavorite and not lockStatus.inBattle and not lockStatus.inExplore and not lockStatus.isSpecial and not lockStatus.isInHomeland and not lockStatus.isActivityDipatching and not lockStatus.inRogue then
				elementSet[data.id] = true
			end
		end
	end

	for petId, _ in pairs(elementSet) do
		if not tableB[petId] then
			return false
		end
	end

	return true
end

function PetManagementModel:getLockStatus(data)
	local temp = {}
	local petInfo = pg.me:getPetInfo(data.id, true)
	local isFavorite = petInfo and petInfo.isFavorite or false
	local favoriteType = petInfo and petInfo.favoriteType or 0
	local inBattle = pg.game.petManage:getPetIsInBattle(data.id, true)
	local inExplore = false
	local inRogue = RogueUtils.isPetInRogue(data.id)

	for _, v in pairs(self:getExploreGroupInfoById(self:getSelectGroupId())) do
		if v.id == data.id then
			inExplore = true

			break
		end
	end

	temp.isFavorite = isFavorite
	temp.favoriteType = favoriteType
	temp.isValidFavorite = favoriteType > 0
	temp.inBattle = inBattle
	temp.inExplore = inExplore
	temp.isSpecial = not petInfo or LuaUIUtils.tableContains(PetConfigData.forbidReleasePet, data.templateId)
	temp.isInHomeland = petInfo and pg.me:isPetPutInHomeland(petInfo) or false
	temp.isActivityDipatching = petInfo and pg.me:isPetActivityDispatching(petInfo) or false
	temp.inRogue = inRogue

	return temp
end

function PetManagementModel:resetOnDestroy(boxIdRecord)
	self.isPvp = false
	self.curSelectPetId = nil
	self.selectBoxId = nil

	if boxIdRecord then
		self:setSelectBoxId(boxIdRecord)
	end
end

function PetManagementModel:getTopRightTabUListData(isHideOtherTab)
	if self.m_topRightTabList then
		return self.m_topRightTabList
	end

	local tabList = {}
	local EPages = UIConst.PetMgrTabType
	local ENames = UIConst.PetMgrTabType2Name
	local tabCfgList = {
		{
			nameKey = "BATTLE",
			tab = EPages.BATTLE,
			tabName = ENames[EPages.BATTLE],
			condition = function(mIsHideOtherTab)
				return true
			end
		},
		{
			nameKey = "EXPLORE",
			tab = EPages.EXPLORE,
			tabName = ENames[EPages.EXPLORE],
			condition = function(mIsHideOtherTab)
				return not mIsHideOtherTab
			end
		}
	}

	for cfgIdx, cfg in ipairs(tabCfgList) do
		if cfg and cfg.condition then
			local isShow = cfg.condition(isHideOtherTab)

			if isShow then
				table.insert(tabList, cfg)
			end
		end
	end

	local validTabLen = #tabList

	for idx, tab in ipairs(tabList) do
		local tIndex = 1

		if idx == 1 then
			tIndex = 0
		elseif idx == validTabLen then
			tIndex = 2
		end

		tabList[idx] = {
			tab = tab.tab,
			tabName = tab.tabName,
			name = pg.getGameString(tab.nameKey),
			nameKey = tab.nameKey,
			tIndex = tIndex
		}
	end

	self.m_topRightTabList = tabList

	return tabList
end

function PetManagementModel:initBoxManualLockStatues()
	self.recordBoxManualLockStatus = {}

	local petBoxMap = pg.me.petBoxMap or {}

	for i = 1, #petBoxMap do
		local box = petBoxMap[i]
		local manualLockedStatusCode = box:isManualLocked() and 1 or 0

		self.recordBoxManualLockStatus[i] = manualLockedStatusCode
	end
end

function PetManagementModel:getBoxManualRecordStatusByIndex(boxId)
	if not boxId or boxId <= 0 or not self.recordBoxManualLockStatus or boxId > #self.recordBoxManualLockStatus then
		return 0
	end

	return self.recordBoxManualLockStatus[boxId] or 0
end

function PetManagementModel:setBoxManualRecordStatusByIndex(boxId, status)
	if not boxId or boxId <= 0 or not self.recordBoxManualLockStatus or boxId > #self.recordBoxManualLockStatus then
		return
	end

	self.recordBoxManualLockStatus[boxId] = status
end

return PetManagementModel
