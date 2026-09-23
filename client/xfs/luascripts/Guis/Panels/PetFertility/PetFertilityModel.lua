-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetFertility\\PetFertilityModel.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("PetFertilityModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local Utils = require("Common.Utils.Utils")
local PetData = require("Data.pet_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Lume = require("Core.Common.lume")
local ItemConst = require("Common.Const.ItemConst")
local ItemUtils = require("Common.Utils.ItemUtils")
local PetResearchContentData = require("Data.pet_research_content_data")
local ItemData = require("Data.item_data")
local PetTalentData = require("Data.pet_talent_data")
local Const = require("Common.Const.Const")
local ElementNameToId = require("Data.element_name_to_id")
local PetCharacterData = require("Data.pet_character_data")
local PetFeedItemData = require("Data.pet_feed_item_data")
local Time = require("Core.Common.Time")
local NoticeDef = require("Common.NoticeDef")
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")
local UIConst = require("Const.UIConst")
local PetFertilityModel = Class.LightClass("PetFertilityModel", UIModel)

PetFertilityModel.MAX_EXPLORE_PETS_COUNT = 3
PetFertilityModel.TASTE_LEVEL = {
	HATE = 1,
	NONE = 0,
	FAVORITE = 4,
	LIKE = 3,
	NORMAL = 2
}
PetFertilityModel.FOOD_TYPE = {
	[0] = 0,
	5,
	1,
	3,
	6,
	2,
	4
}
PetFertilityModel.TIMELINE_INDEX = {
	UnFold2 = 10,
	Fold3 = 9,
	UnFold3 = 8,
	Fold4 = 7,
	UnFold4 = 6,
	FocusFHReverse = 5,
	FocusGJReverse = 4,
	FocusFYReverse = 3,
	FocusFH = 2,
	FocusGJ = 1,
	FocusFY = 0,
	Begin = 27,
	Slide2Chaos = 26,
	Slide3Chaos = 25,
	Slide4Chaos = 24,
	FocusGJRightReverse = 23,
	FocusGJLeftReverse = 22,
	FocusGJRight = 21,
	FocusGJLeft = 20,
	SlideRight2 = 19,
	SlideLeft2 = 18,
	SlideRight3 = 17,
	SlideLeft3 = 16,
	SlideRight4Plus = 15,
	SlideLeft4Plus = 14,
	Fold1 = 13,
	UnFold1 = 12,
	Fold2 = 11
}

function PetFertilityModel:getActiveFormFilters(filterData)
	local formFilters = {}

	for key, value in pairs(filterData or EMPTY_TABLE) do
		if value == true and type(key) == "string" and string.match(key, "^isForm%d+$") then
			formFilters[key] = true
		end
	end

	return formFilters
end

function PetFertilityModel:appendFormFilters(filterData, formFilters)
	if not filterData or not formFilters then
		return
	end

	for key, value in pairs(formFilters) do
		if type(key) == "string" and string.match(key, "^isForm%d+$") then
			filterData[key] = value and true or false
		end
	end
end

function PetFertilityModel:getSelectedFormTypeMap(filters)
	return PetManagementDataHelper.getSelectedFormTypeMap(filters)
end

function PetFertilityModel:fillEmptySlot(petsT, rowMaxSlot, screenMaxSlot)
	local tCount = Lume.count(petsT)

	if tCount < screenMaxSlot then
		for i = 1, screenMaxSlot - tCount do
			petsT[#petsT + 1] = {
				empty = true
			}
		end

		return
	end

	local mod = tCount % rowMaxSlot

	if mod <= 0 then
		return
	end

	local gap = rowMaxSlot - mod

	for i = 1, gap do
		petsT[#petsT + 1] = {
			empty = true
		}
	end
end

function PetFertilityModel:getCpValue(petId)
	local pet = pg.me:getPetInfo(petId)

	return pet and pet:getCpValue() or 0
end

function PetFertilityModel:getPetName(petId)
	local pet = pg.me:getPetInfo(petId)

	if pet.customName and pet.customName ~= "" then
		return pet.customName
	end

	local pData = PetData[pet.templateId] or {}
	local name = pData.name

	return name
end

function PetFertilityModel:getPetInfo(petId)
	local pet = pg.me:getPetInfo(petId)

	return pg.global.ui.petManagement.model:setUpPetInfo(pet)
end

function PetFertilityModel:getPlayerMaxEggCustomTalentCount()
	local customTalentCount = 4

	if customTalentCount <= 0 then
		customTalentCount = 1
	end

	return customTalentCount
end

function PetFertilityModel:getBoxIdByBoxSequenceIndex(index)
	local boxId = pg.me.petBoxMap.sequence[index]

	return boxId
end

function PetFertilityModel:getBoxSequenceIndexByBoxId(boxId)
	for i = 1, #pg.me.petBoxMap.sequence do
		if boxId == pg.me.petBoxMap.sequence[i] then
			return i
		end
	end

	return nil
end

function PetFertilityModel:getBoxInfos()
	local boxInfos = {}
	local petBoxMapSequence = pg.me.petBoxMap.sequence:getRawTable()

	for idx = 1, #petBoxMapSequence do
		local boxInfo = self:getBoxNameInfo(petBoxMapSequence[idx])

		boxInfos[idx] = boxInfo
	end

	return boxInfos
end

function PetFertilityModel:getBoxNameInfo(boxIdx)
	local petBoxMap = pg.me.petBoxMap
	local ret = {}

	ret.idx = boxIdx
	ret.customName = petBoxMap[boxIdx].customName
	ret.countNum = petBoxMap[boxIdx].count .. "/" .. petBoxMap[boxIdx].slotCount
	ret.count = petBoxMap[boxIdx].count
	ret.slotCount = petBoxMap[boxIdx].slotCount

	return ret
end

function PetFertilityModel:getBoxInfoById(boxId, sortId, isDescending)
	local petBoxMap = pg.me.petBoxMap

	if boxId > #petBoxMap then
		return
	end

	if sortId == 0 then
		local box = petBoxMap[boxId]
		local maxSlotCount = box.slotCount
		local pets = pg.me.pets
		local ret = {}

		for i = 1, maxSlotCount do
			local boxPetId = box[i]
			local pet = pets[boxPetId]
			local petInfo = pg.global.ui.petManagement.model:setUpPetInfo(pet)

			ret[i] = petInfo
		end

		ret = self:sortTableBySortConditions(ret, sortId, isDescending)

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

				if pet ~= nil then
					local petInfo = pg.global.ui.petManagement.model:setUpPetInfo(pet)

					ret[count] = petInfo
					count = count + 1
				end
			end
		end

		ret = self:sortTableBySortConditions(ret, sortId, isDescending)

		return ret
	end
end

function PetFertilityModel:checkExposeFilter(filters)
	if not filters.isRating1 or not filters.isRating2 or not filters.isRating3 or not filters.isRating4 then
		return true
	end

	return false
end

function PetFertilityModel:getFilteredPetsInfo(sortId, isDescending, rowMaxSlot, screenMaxSlot)
	self:filterTempProcess()

	local filters = self:getFilter()
	local tempFilter = Utils.deepCopyTable(filters)
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

			if pet ~= nil and not pet:isCatchReporting() and self:checkPetValidByFilter(pet, tempFilter) then
				local petInfo = pg.global.ui.petManagement.model:setUpPetInfo(pet)

				if not petInfo.isCatchReportingStatus or not self:checkExposeFilter(tempFilter) then
					ret[count] = petInfo
					count = count + 1
				end
			end
		end
	end

	ret = self:sortTableBySortConditions(ret, sortId, isDescending, self.recordFilter)

	self:fillEmptySlot(ret, rowMaxSlot, screenMaxSlot)
	self:filterTempProcess(true)

	return ret
end

function PetFertilityModel:filterTempProcess(reset)
	if reset then
		local resetFilter = {
			keyword = self.recordFilter.keyword,
			isNormal = self.recordFilter.isNormal,
			isShiny = self.recordFilter.isShiny,
			isBoss = self.recordFilter.isBoss,
			isRainbow = self.recordFilter.isRainbow,
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

		for i = 1, 10 do
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

	for i = 1, 10 do
		local k = "isFavoriteType" .. i

		self.recordFilter[k] = self.filter[k]
	end

	if not self.filter.isNormal and not self.filter.isShiny and not self.filter.isBoss and not self.filter.isRainbow then
		self.filter.isNormal = true
		self.filter.isShiny = true
		self.filter.isBoss = true
		self.filter.isRainbow = true
	end

	local anyFavTypeSelected = false

	for i = 1, 10 do
		if self.filter["isFavoriteType" .. i] then
			anyFavTypeSelected = true

			break
		end
	end

	if not anyFavTypeSelected then
		for i = 1, 10 do
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

function PetFertilityModel:getAllElementsInfo()
	local data = {}

	for k, _ in pairs(ElementNameToId) do
		if k ~= "null" then
			local d = {}

			d.name = k
			data[#data + 1] = d
		end
	end

	return data
end

function PetFertilityModel:sortTableBySortConditions(ret, sortId, isDescending, filter)
	local newT = {}

	for i = 1, #ret do
		if not ret[i].isEmpty then
			local num = #newT + 1

			newT[num] = ret[i]
		end
	end

	isDescending = not isDescending

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
		}
	}

	if sortId ~= 0 then
		PetManagementDataHelper.templateFun(newT, isDescending, table.unpack(sortKeys[sortId] or {}))
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

function PetFertilityModel:checkPetValidByFilter(pet, filters)
	local petName = self:getPetName(pet.id)

	if not string.isNilOrEmpty(filters.keyword) and not string.find(string.split(pg.getLocalizationText(petName), "<")[1], filters.keyword) then
		return false
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

	local petExtra = pg.global.ui.petManagement.model:setUpPetInfo(pet)
	local selectedFormTypeMap, hasSelectedForm = self:getSelectedFormTypeMap(filters)

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
	local petIsNormal = not petIsShiny and not petIsBoss and not petIsRainbow and not petIsBlackRainbow

	if filters.isNormal and petIsNormal then
		-- block empty
	elseif filters.isShiny and petIsShiny then
		-- block empty
	elseif filters.isBoss and petIsBoss then
		-- block empty
	elseif filters.isRainbow and (petIsRainbow or petIsBlackRainbow) then
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

function PetFertilityModel:getFilter()
	if self.filter == nil then
		self.filter = {
			isRating4 = false,
			isRating3 = false,
			isRating2 = false,
			isRating1 = false,
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
			isRainbow = false,
			isBoss = false,
			isShiny = false,
			isNormal = false,
			keyword = "",
			elements = {}
		}
	end

	return self.filter
end

function PetFertilityModel:setFilter(data)
	data = data or {}
	self.filter = {
		keyword = data.keyword or "",
		isNormal = data.isNormal or false,
		isShiny = data.isShiny or false,
		isBoss = data.isBoss or false,
		isRainbow = data.isRainbow or false,
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

	for i = 1, 10 do
		local k = "isFavoriteType" .. i

		self.filter[k] = data[k] or false
	end

	self:appendFormFilters(self.filter, data)
	self:appendFormFilters(self.filter, data.formFilters)
end

function PetFertilityModel:refreshPetBallInfoData()
	self.petBallMap = {}

	local playerPetBallMap = pg.me.petBallMap

	if playerPetBallMap == nil then
		return
	end

	for petBallId, petBallInfo in playerPetBallMap:items() do
		local tempItem = {}

		tempItem.petBallId = petBallId
		tempItem.petBallInfo = petBallInfo
		self.petBallMap[#self.petBallMap + 1] = tempItem
	end

	table.sort(self.petBallMap, function(a, b)
		if a.petBallInfo.createTime == b.petBallInfo.createTime then
			return a.petBallId < b.petBallId
		else
			return a.petBallInfo.createTime < b.petBallInfo.createTime
		end
	end)
end

function PetFertilityModel:getBallIndexByPetBallId(petBallId)
	for k, v in pairs(self.petBallMap) do
		if v.petBallId == petBallId then
			return k
		end
	end

	return nil
end

function PetFertilityModel:getCurPetBallIndex()
	if self.curSelectedPetBallIndex then
		return self.curSelectedPetBallIndex
	end

	local playerPetBallMap = pg.me.petBallMap

	if playerPetBallMap == nil then
		return 1
	end

	self.curSelectedPetBallIndex = self:getBallIndexByPetBallId(playerPetBallMap.curIndex)

	return self.curSelectedPetBallIndex or 1
end

function PetFertilityModel:getCurrentPetBallId()
	local petBallIndex = self:getCurPetBallIndex()

	if not petBallIndex then
		return nil
	end

	if not self.petBallMap[petBallIndex] then
		return nil
	end

	return self.petBallMap[petBallIndex].petBallId
end

function PetFertilityModel:setCurPetBallIndex(petBallIndex)
	local info = self:getPetBallInfoByBallIndex(petBallIndex)

	if not info or not info.petBallId then
		return
	end

	self.curSelectedPetBallIndex = petBallIndex

	pg.me:serverMsg("RPC_CS_PetBallSetCurIndex", info.petBallId)
end

function PetFertilityModel:getPetBallInfoByBallIndex(petBallIndex)
	return self.petBallMap[petBallIndex]
end

function PetFertilityModel:isBallContainsPet(petBallIndex)
	local info = self:getPetBallInfoByBallIndex(petBallIndex)

	if not info or not info.petBallInfo or not info.petBallInfo.petId or info.petBallInfo.petId == "" then
		return false
	end

	return true
end

function PetFertilityModel:getPetBallPetInfo(petBallIndex)
	local info = self:getPetBallInfoByBallIndex(petBallIndex)

	if not info or not info.petBallInfo or not info.petBallInfo.petId or info.petBallInfo.petId == "" then
		return nil
	end

	local petInfo = self:getPetInfo(info.petBallInfo.petId)

	return petInfo
end

function PetFertilityModel:getPetBallName(petBallIndex)
	local info = self:getPetBallInfoByBallIndex(petBallIndex)

	if not info or not info.petBallInfo or not info.petBallInfo.customName or info.petBallInfo.customName == "" then
		return pg.getGameString("PET_BALL")
	end

	return pg.getLocalizationText(info.petBallInfo.customName)
end

function PetFertilityModel:getPetBallCount()
	if not self.petBallMap then
		return 0
	end

	return #self.petBallMap
end

function PetFertilityModel:getPetBallCountDotListData()
	local temp = {}

	for i = 1, self:getPetBallCount() do
		temp[#temp + 1] = {}
	end

	return temp
end

function PetFertilityModel:checkPetExistsInAnyPetBallExceptSpecificPetBall(petId, petBallIndex)
	for k, v in pairs(self.petBallMap) do
		if k ~= petBallIndex and v.petBallInfo.petId == petId then
			return true
		end
	end

	return false
end

function PetFertilityModel:checkMainPetTasteLevel(item, petId)
	if not petId or petId == "" then
		return self.TASTE_LEVEL.NONE
	end

	local templateId = pg.me:getPetInfo(petId).templateId
	local researchContentData = PetResearchContentData[templateId]

	if researchContentData == nil then
		return self.TASTE_LEVEL.NONE
	elseif item.foodType == researchContentData.likeFood then
		return self.TASTE_LEVEL.LIKE
	elseif item.foodType == researchContentData.hateFood then
		return self.TASTE_LEVEL.HATE
	elseif item.itemId == researchContentData.mostLikeFood then
		return self.TASTE_LEVEL.FAVORITE
	else
		return self.TASTE_LEVEL.NORMAL
	end
end

function PetFertilityModel:getAllEggs()
	if pg.space:isGrabEgg() then
		local eggs = pg.me:grabEgg_getEggs()
		local ret = {}

		for _, egg in ipairs(eggs) do
			local temp = self:getInfoByItem(egg)

			if temp then
				ret[#ret + 1] = temp
			end
		end

		return ret
	else
		return self:getAllEggInfo()
	end
end

function PetFertilityModel:getAllEggInfo()
	local ret = {}

	ItemUtils.eachSupportedTypedBag(pg.me, function(_, itemBag)
		for _, packSlot in itemBag:items() do
			local temp = self:getInfoByItem(packSlot)

			if temp then
				ret[#ret + 1] = temp
			end
		end
	end)

	if self.hatchSortId == 1 then
		table.sort(ret, function(a, b)
			if self.hatchIsDescending then
				return a.id > b.id
			else
				return a.id < b.id
			end
		end)
	elseif self.hatchSortId == 2 then
		table.sort(ret, function(a, b)
			if self.hatchIsDescending then
				return a.quality > b.quality
			else
				return a.quality < b.quality
			end
		end)
	end

	return ret
end

function PetFertilityModel:getHatchSlotDataList(spawnerId)
	local hatchSlotMap

	if pg.space:isGrabEgg() then
		hatchSlotMap = pg.me:grabEgg_getHatchEggInfo(spawnerId)
	else
		hatchSlotMap = pg.me.hatchSlotMap:getRawTable()
	end

	return hatchSlotMap
end

function PetFertilityModel:getHatchSlotEggItemInfo(slotInfo)
	return self:getInfoByItem(slotInfo.item)
end

function PetFertilityModel:getInfoByItem(item)
	local ret

	if Utils.isBreedPetEgg(item.id) then
		local extraProp = item:getExtraProp()

		if not extraProp or not next(extraProp) then
			return ret
		end

		local featureInfo = PetCharacterData[extraProp.characterId]
		local featureInfoNew = {}

		if featureInfo then
			featureInfoNew = {
				rare = featureInfo.rare or 0,
				desc = featureInfo.desc,
				name = featureInfo.name,
				icon = featureInfo.icon,
				characterId = extraProp.characterId
			}
		else
			featureInfoNew = featureInfo
		end

		local breedTalent = {}
		local talentList = extraProp.talentIds

		for i = 1, #talentList do
			local talentTemplateId = talentList[i]

			if talentTemplateId then
				local name = PetTalentData[talentTemplateId].talentName
				local icon = PetTalentData[talentTemplateId].talentIcon
				local quality = PetTalentData[talentTemplateId].rarity
				local id = talentTemplateId
				local group = PetTalentData[talentTemplateId].group
				local desc = PetTalentData[talentTemplateId].dec

				breedTalent[#breedTalent + 1] = {
					name = name,
					icon = icon,
					quality = quality,
					id = id,
					group = group,
					desc = desc
				}
			end
		end

		table.sort(breedTalent, function(a, b)
			return a.id < b.id
		end)

		ret = {
			isHatching = false,
			isNormalEgg = false,
			genId = item.genID,
			id = item.id,
			count = item.count,
			icon = ItemData[item.id].icon,
			quality = ItemData[item.id].quality,
			eggName = ItemData[item.id].itemName,
			eggDes = ItemData[item.id].itemDes,
			funcRep = ItemData[item.id].funcRep,
			basePropertyIndividualLevelList = extraProp.basePropertyIndividualLevelList,
			characterId = extraProp.characterId,
			talentIds = extraProp.talentIds,
			templateId = extraProp.templateId,
			petName = PetData[extraProp.templateId].name,
			petIcon = PetData[extraProp.templateId].iconName,
			templateIdFather = extraProp.templateIdFather,
			templateIdMother = extraProp.templateIdMother,
			label = extraProp.label,
			gender = extraProp.gender,
			isShiny = Utils.isLabelShiny(extraProp.label),
			featureInfo = featureInfoNew,
			breedTalent = breedTalent,
			isLock = item:isStatusLocked()
		}
	elseif Utils.isNormalPetEgg(item.id) then
		ret = {
			isNormalEgg = true,
			isHatching = false,
			genId = item.genID,
			id = item.id,
			count = item.count,
			icon = ItemData[item.id].icon,
			quality = ItemData[item.id].quality,
			eggName = ItemData[item.id].itemName,
			eggDes = ItemData[item.id].itemDes,
			funcRep = ItemData[item.id].funcRep,
			isLock = item.isStatusLocked and item:isStatusLocked() or false
		}
	end

	return ret
end

function PetFertilityModel:getHatchEggSortInfo()
	return {
		{
			name = pg.getGameString("DEFAULT_SORT")
		},
		{
			name = pg.getGameString("QUALITY")
		}
	}
end

function PetFertilityModel:setHatchSortId(hatchSortId)
	self.hatchSortId = hatchSortId
end

function PetFertilityModel:setHatchDescending(hatchIsDescending)
	self.hatchIsDescending = hatchIsDescending
end

function PetFertilityModel:getFoodItemsInfo()
	local ret = {}
	local player = pg.me
	local bag = ItemUtils.getTypedBag(player, ItemConst.INV_TYPE_COMMON) or {}
	local petBallId = self:getCurrentPetBallId()
	local petBallIdx = self:getCurPetBallIndex()
	local ballInfo = self:getPetBallInfoByBallIndex(petBallIdx)
	local petId = ballInfo and ballInfo.petBallInfo.petId or nil

	for itemId, feedData in pairs(PetFeedItemData) do
		if not feedData.matchBallId or table.contains(feedData.matchBallId, petBallIdx) then
			local data = ItemData[itemId]
			local item = {}

			item.itemId = itemId
			item.name = data.itemName
			item.funcSimpleRep = data.funcSimpleRep
			item.funcRep = data.funcRep
			item.quality = data.quality
			item.displayType = data.displayType
			item.icon = LuaUIUtils.getIconByIconId(data.icon)
			item.source = data.source
			item.tasteLevel = item.foodType ~= nil and self:checkMainPetTasteLevel(item, petId) or self.TASTE_LEVEL.NONE
			item.count = 0
			item.include = 0

			for _, packSlot in bag:items() do
				if itemId == packSlot.id then
					item.count = packSlot.count
					item.include = 1

					break
				end
			end

			ret[#ret + 1] = item
		end
	end

	table.sort(ret, function(l, r)
		if l.include ~= r.include then
			return l.include > r.include
		end

		if l.tasteLevel ~= r.tasteLevel then
			return l.tasteLevel > r.tasteLevel
		end

		if l.itemId ~= r.itemId then
			return l.itemId < r.itemId
		end

		return false
	end)

	return ret
end

function PetFertilityModel:setPetFood(itemId, itemCount, cb)
	local key = self:getCurrentPetBallId()
	local itemId = itemId
	local itemCount = itemCount

	pg.me:serverMsg("RPC_CS_PetBalladdExpAction", key, itemId, itemCount, function(noticeId, noticeArg)
		if noticeId == NoticeDef.SUCCESS and cb then
			cb()
		end
	end)
end

function PetFertilityModel:getCurPetBallExpActionStatus()
	local curPetBallInfo = self:getPetBallInfoByBallIndex(self:getCurPetBallIndex())

	if not curPetBallInfo then
		return
	end

	return curPetBallInfo.petBallInfo.expActionStatus
end

function PetFertilityModel:getCurPetBallExpActionList()
	local curPetBallInfo = self:getPetBallInfoByBallIndex(self:getCurPetBallIndex())

	if not curPetBallInfo then
		return
	end

	local expActionList = curPetBallInfo.petBallInfo.expActionList:getRawTable()

	return expActionList
end

function PetFertilityModel:getTotalTimeByExpActionList()
	local curPetBallInfo = self:getPetBallInfoByBallIndex(self:getCurPetBallIndex())

	if not curPetBallInfo then
		return
	end

	local expActionList = curPetBallInfo.petBallInfo.expActionList:getRawTable()
	local nextTs = curPetBallInfo.petBallInfo.expNextRefreshTs
	local totalTime = 0
	local remainTime = 0

	for i = 1, #expActionList do
		local expAction = expActionList[i]
		local itemId = expAction.itemId
		local itemCount = expAction.itemCount
		local finishCount = expAction.finishCount
		local addCount = itemCount * Utils.getExpActionCount(itemId) - finishCount

		if i == 1 then
			addCount = addCount - 1
		end

		local costTime = addCount * Utils.getExpActionTime(itemId)

		totalTime = totalTime + itemCount * Utils.getExpActionCount(itemId) * Utils.getExpActionTime(itemId)

		if i == 1 then
			costTime = costTime + (nextTs - Time.secondCache)
		end

		remainTime = remainTime + costTime
	end

	remainTime = math.min(remainTime, totalTime)

	return remainTime, totalTime
end

function PetFertilityModel:getTotalExpByExpActionList()
	local curPetBallInfo = self:getPetBallInfoByBallIndex(self:getCurPetBallIndex())
	local petInfo = self:getPetBallPetInfo(self:getCurPetBallIndex())

	if not curPetBallInfo then
		return
	end

	local expActionList = curPetBallInfo.petBallInfo.expActionList:getRawTable() or {}
	local expPer = Utils.getPetBallExpNum(curPetBallInfo.petBallInfo.templateId, petInfo.level)
	local totalExp = 0
	local remainExp = 0

	for i = 1, #expActionList do
		local expAction = expActionList[i]
		local itemId = expAction.itemId
		local itemCount = expAction.itemCount
		local finishCount = expAction.finishCount
		local addCount = itemCount * Utils.getExpActionCount(itemId) - finishCount
		local t = expPer * itemCount * Utils.getExpActionCount(itemId)
		local r = expPer * addCount

		totalExp = totalExp + t
		remainExp = remainExp + r
	end

	return remainExp, totalExp
end

function PetFertilityModel:getTotalExpByFeedItem(itemId, itemCount)
	local expTotal = 0
	local petInfo = self:getPetBallPetInfo(self:getCurPetBallIndex())
	local petBallInfo = self:getPetBallInfoByBallIndex(self:getCurPetBallIndex())
	local expMaxAdd = Utils.getPetExpMaxAdd(pg.me, petInfo.id)
	local expPer = Utils.getPetBallExpNum(petBallInfo.petBallInfo.templateId, petInfo.level)
	local interval, addCount = Utils.getExpActionTime(itemId), Utils.getExpActionCount(itemId)

	if interval == 0 or addCount == 0 then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("挂机喂食配置 配置错误 预览经验计算失败")
		end

		return
	end

	local realAddCount = itemCount * addCount

	expTotal = realAddCount * expPer

	return expTotal
end

function PetFertilityModel:getAddItemMaxValue(itemId, bagCount)
	local petInfo = self:getPetBallPetInfo(self:getCurPetBallIndex())
	local petBallInfo = self:getPetBallInfoByBallIndex(self:getCurPetBallIndex())
	local expMaxAdd = Utils.getPetExpMaxAdd(pg.me, petInfo.id)
	local expActionRemainExp = self:getTotalExpByExpActionList()
	local expPer = Utils.getPetBallExpNum(petBallInfo.petBallInfo.templateId, petInfo.level)
	local addCount = Utils.getExpActionCount(itemId)
	local result

	if expActionRemainExp < expMaxAdd then
		local needExp = expMaxAdd - expActionRemainExp
		local settleCount = math.ceil(needExp / expPer)

		result = math.min(bagCount, math.ceil(settleCount / addCount))
	else
		result = bagCount
	end

	return result
end

return PetFertilityModel
