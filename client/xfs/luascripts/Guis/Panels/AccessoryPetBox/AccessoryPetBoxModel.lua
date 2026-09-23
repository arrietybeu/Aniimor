-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\AccessoryPetBox\\AccessoryPetBoxModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local AccessoryPetBoxModel = Class.LightClass("AccessoryPetBoxModel", UIModel)
local LuaUIUtils = require("Utils.LuaUIUtils")
local PetPrototypeData = require("Data.pet_prototype_data")
local Utils = require("Common.Utils.Utils")
local PetData = require("Data.pet_data")
local Const = require("Common.Const.Const")
local ElementNameToId = require("Data.element_name_to_id")
local AttachPointData = require("Data.pet_appearance_point_data")
local ItemData = require("Data.item_data")
local PetNatureData = require("Data.pet_nature_data")
local PetLevelData = require("Data.pet_level_data")
local PetResearchIdToNumber = require("Data.pet_research_id_to_number")
local PetCharacterData = require("Data.pet_character_data")
local PetTalentData = require("Data.pet_talent_data")
local ItemConst = require("Common.Const.ItemConst")
local Lume = require("Core.Common.lume")
local ItemUtils = require("Common.Utils.ItemUtils")
local PetConfigData = require("Data.pet_config_data")
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")
local UIConst = require("Const.UIConst")

AccessoryPetBoxModel.CONTENT_TAB = {
	HAVE = "Have",
	LOCKED = "Locked",
	EMPTY = "Empty",
	EMPTY_NO_WORD = "EmptyNoWord"
}

function AccessoryPetBoxModel:getCurrencyData(itemIdList)
	local res = {}

	for _, itemId in ipairs(itemIdList) do
		res[#res + 1] = {
			count = ItemUtils.getItemCountById(pg.me, itemId),
			icon = LuaUIUtils.getIconByItemId(itemId)
		}
	end

	return res
end

function AccessoryPetBoxModel:fillEmptySlot(petsT, rowMaxSlot, screenMaxSlot)
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

function AccessoryPetBoxModel:setUpPetInfo(pet)
	local petInfo = {}

	petInfo.empty = pet == nil

	if petInfo.empty then
		return petInfo
	end

	petInfo = pet:getRawTable()
	petInfo._petInfo = pet

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
	petInfo.isVariant = Utils.isLabelVariant(pet.label)
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
		return a.quality > b.quality
	end)

	local slot = self:checkPetInWhichExploreSlot(pet.id) or 4

	petInfo.exploreSlotIndex = 3 - slot
	petInfo.highestExploreSkillLevel = table.maxn({
		petInfo.climbLevel,
		petInfo.glideLevel,
		petInfo.swimLevel
	})

	if petInfo.climbLevel > 0 then
		petInfo.exploreIndex = 2
	elseif petInfo.glideLevel > 0 then
		petInfo.exploreIndex = 1
	elseif petInfo.swimLevel > 0 then
		petInfo.exploreIndex = 0
	else
		petInfo.exploreIndex = -1
	end

	return petInfo
end

function AccessoryPetBoxModel:checkPetInWhichExploreSlot(petId)
	local explorePets = self:getPetExploreGroupPetsInModel()

	for i = 1, #explorePets do
		if explorePets[i] == petId then
			return i
		end
	end

	return nil
end

function AccessoryPetBoxModel:getCpValue(petId)
	local pet = pg.me:getPetInfo(petId)

	return pet and pet:getCpValue() or 0
end

function AccessoryPetBoxModel:getPetName(petId)
	local pet = pg.me:getPetInfo(petId)

	if pet.customName and pet.customName ~= "" then
		return pet.customName
	end

	local pData = PetData[pet.templateId] or {}
	local name = pData.name

	return name
end

function AccessoryPetBoxModel:getPetInfo(petId)
	local pet = pg.me:getPetInfo(petId)

	return self:setUpPetInfo(pet)
end

function AccessoryPetBoxModel:getBoxIdByBoxSequenceIndex(index)
	local boxId = pg.me.petBoxMap.sequence[index]

	return boxId
end

function AccessoryPetBoxModel:getBoxSequenceIndexByBoxId(boxId)
	for i = 1, #pg.me.petBoxMap.sequence do
		if boxId == pg.me.petBoxMap.sequence[i] then
			return i
		end
	end

	return nil
end

function AccessoryPetBoxModel:getBoxInfos()
	local boxInfos = {}
	local petBoxMapSequence = pg.me.petBoxMap.sequence:getRawTable()

	for idx = 1, #petBoxMapSequence do
		local boxInfo = self:getBoxNameInfo(petBoxMapSequence[idx])

		boxInfos[idx] = boxInfo
	end

	return boxInfos
end

function AccessoryPetBoxModel:getBoxNameInfo(boxIdx)
	local petBoxMap = pg.me.petBoxMap
	local ret = {}

	ret.idx = boxIdx
	ret.customName = petBoxMap[boxIdx].customName
	ret.countNum = petBoxMap[boxIdx].count .. "/" .. petBoxMap[boxIdx].slotCount
	ret.count = petBoxMap[boxIdx].count
	ret.slotCount = petBoxMap[boxIdx].slotCount

	return ret
end

function AccessoryPetBoxModel:getBoxInfoById(boxId, sortId, isDescending)
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
			local petInfo = self:setUpPetInfo(pet)

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
					local petInfo = self:setUpPetInfo(pet)

					ret[count] = petInfo
					count = count + 1
				end
			end
		end

		ret = self:sortTableBySortConditions(ret, sortId, isDescending)

		return ret
	end
end

function AccessoryPetBoxModel:getFilteredPetsInfo(sortId, isDescending, rowMaxSlot, screenMaxSlot)
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
				local petInfo = self:setUpPetInfo(pet)

				ret[count] = petInfo
				count = count + 1
			end
		end
	end

	ret = self:sortTableBySortConditions(ret, sortId, isDescending, self.recordFilter)

	self:fillEmptySlot(ret, rowMaxSlot, screenMaxSlot)
	self:filterTempProcess(true)

	return ret
end

function AccessoryPetBoxModel:filterTempProcess(reset)
	if reset then
		self:setFilter({
			keyword = self.recordFilter.keyword,
			isNormal = self.recordFilter.isNormal,
			isShiny = self.recordFilter.isShiny,
			isBoss = self.recordFilter.isBoss,
			isRainbow = self.recordFilter.isRainbow,
			isFavorite = self.recordFilter.isFavorite,
			isUnFavorite = self.recordFilter.isUnFavorite,
			elements = self.recordFilter.elements,
			isDPS = self.recordFilter.isDPS,
			isSup = self.recordFilter.isSup,
			isHeal = self.recordFilter.isHeal,
			isTank = self.recordFilter.isTank,
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
		})

		return
	end

	self.recordFilter = {
		keyword = self.filter.keyword,
		isNormal = self.filter.isNormal,
		isShiny = self.filter.isShiny,
		isBoss = self.filter.isBoss,
		isRainbow = self.filter.isRainbow,
		isFavorite = self.filter.isFavorite,
		isUnFavorite = self.filter.isUnFavorite,
		elements = self.filter.elements,
		isDPS = self.filter.isDPS,
		isSup = self.filter.isSup,
		isHeal = self.filter.isHeal,
		isTank = self.filter.isTank,
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
		isNotRareFeature = self.filter.isNotRareFeature
	}

	if not self.filter.isNormal and not self.filter.isShiny and not self.filter.isBoss and not self.filter.isRainbow then
		self.filter.isNormal = true
		self.filter.isShiny = true
		self.filter.isBoss = true
		self.filter.isRainbow = true
	end

	if not self.filter.isFavorite and not self.filter.isUnFavorite then
		self.filter.isFavorite = true
		self.filter.isUnFavorite = true
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

	if not self.filter.isDPS and not self.filter.isSup and not self.filter.isHeal and not self.filter.isTank then
		self.filter.isDPS = true
		self.filter.isSup = true
		self.filter.isHeal = true
		self.filter.isTank = true
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

function AccessoryPetBoxModel:getAllElementsInfo()
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

function AccessoryPetBoxModel:sortTableBySortConditions(ret, sortId, isDescending, filter)
	local newT = {}

	for i = 1, #ret do
		if not ret[i].empty then
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

function AccessoryPetBoxModel:checkPetValidByFilter(pet, filters)
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

	local petExtra = self:setUpPetInfo(pet)
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

	local filterCollects = {
		isCollected = filters.isFavorite and 1 or nil,
		isUnCollected = filters.isUnFavorite and 2 or nil
	}

	if not LuaUIUtils.tableContains(filterCollects, pet.isFavorite and 1 or 2) then
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

function AccessoryPetBoxModel:getFilter()
	if self.filter == nil then
		self.filter = {
			isTank = false,
			isHeal = false,
			isSup = false,
			isBoss = false,
			isUnFavorite = false,
			isNormal = false,
			keyword = "",
			isRating1 = false,
			isFavorite = false,
			isClimb = false,
			isDPS = false,
			isNotRareFeature = false,
			isRareFeature = false,
			isInHomeland = false,
			isInExplore = false,
			isNotInBattle = false,
			isInBattle = false,
			isNone = false,
			isSwim = false,
			isGlide = false,
			isRainbow = false,
			isRating4 = false,
			isRating3 = false,
			isRating2 = false,
			isShiny = false,
			elements = {}
		}
	end

	return self.filter
end

function AccessoryPetBoxModel:setFilter(data)
	self.filter = {
		keyword = data.keyword or "",
		isNormal = data.isNormal or false,
		isShiny = data.isShiny or false,
		isBoss = data.isBoss or false,
		isRainbow = data.isRainbow or false,
		isFavorite = data.isFavorite or false,
		isUnFavorite = data.isUnFavorite or false,
		isDPS = data.isDPS or false,
		isSup = data.isSup or false,
		isHeal = data.isHeal or false,
		isTank = data.isTank or false,
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
end

function AccessoryPetBoxModel:getPetExploreGroupPetsInModel(groupId)
	groupId = 1

	local groupInfo = pg.me.prepareFormationList[groupId] or {}
	local petIds = groupInfo.exploreFormation or {}

	petIds = petIds:getRawTable()

	return petIds
end

function AccessoryPetBoxModel:getAccessDataList(petId)
	local accesses = pg.me.petJewelryInfos[petId]
	local res = {}
	local maxSlot = table.nums(AttachPointData)

	for slot = 1, maxSlot do
		local item
		local genId = accesses and accesses.customShow[slot]

		if genId and genId ~= 0 then
			local accessoryId = self:getAccessTempIdWithGenId(genId)

			item = {
				empty = false,
				slot = slot,
				accessoryId = accessoryId
			}
			item.state = self.CONTENT_TAB.HAVE

			local itemData = ItemData[item.accessoryId]

			if itemData then
				item.icon = itemData.icon
				item.name = itemData.itemName
				item.quality = itemData.quality
			end
		else
			item = {
				empty = true,
				slot = slot
			}
			item.state = self.CONTENT_TAB.EMPTY_NO_WORD
		end

		res[#res + 1] = item
	end

	return res
end

function AccessoryPetBoxModel:getAccessTempIdWithGenId(genId)
	local allAccess = ItemUtils.getTypedBag(pg.me, ItemConst.INV_TYPE_PET_JEWELRY)

	return allAccess[genId] and allAccess[genId].id
end

return AccessoryPetBoxModel
