-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\PetInfo.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local lume = require("Core.Common.lume")
local logger = require("Core.Log.LoggerManager").getLogger("PetInfo")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local ItemUtils = require("Common.Utils.ItemUtils")
local ObjHelper = require("Common.ObjHelper")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local AttributeConst = require("Common.Const.AttributeConst")
local NoticeDef = require("Common.NoticeDef")
local SocialUtils = require("Common.Utils.SocialUtils")
local PetAttributeCalcUtils = require("Common.Utils.PetAttributeCalcUtils")
local PetData = require("Data.pet_data")
local PetEvolveData = require("Data.pet_evolve_data")
local PetResearchContentData = require("Data.pet_research_content_data")
local PetConfigData = require("Data.pet_config_data")
local PetPrototypeData = require("Data.pet_prototype_data")
local PetCharacterData = require("Data.pet_character_data")
local PetLevelData = require("Data.pet_level_data")
local PetSkillData = require("Data.pet_skill_data")
local PetBallConfigData = require("Data.pet_ball_config_data")
local HomeEventTypeData = require("Data.home_event_type_data")
local PetElementNameToId = require("Data.element_name_to_id")
local ExploreAbilityData = require("Data.explore_ability_data")
local math_floor = math.floor
local PetInfo = class.LiteClass("PetInfo", CustomDict)

function PetInfo:getObj()
	local obj = self:getRootOwner()

	if self._name == "shapeShiftPetInfo" then
		obj = obj.master
	end

	return obj
end

function PetInfo:getTransmogInfo()
	local obj = self:getObj()
	local transmogInfoMap = obj and obj.petTransmogInfoMap

	if not transmogInfoMap then
		return nil
	end

	return transmogInfoMap:getInfo(self.id)
end

function PetInfo:getSelectTransmogScheme()
	local transmogInfo = self:getTransmogInfo()

	if transmogInfo then
		return transmogInfo:getSelectedScheme()
	end

	local obj = self:getObj()

	if obj and obj.selectTransmogScheme then
		return obj.selectTransmogScheme
	end

	return nil
end

function PetInfo:init(dict)
	PetInfo.super.init(self, dict)
end

function PetInfo:repr()
	return string.format("PetInfo(templateId=%d, entityId=%s)", self.templateId, self.id)
end

function PetInfo:getConfigData()
	return PetData[self.templateId]
end

function PetInfo:getEthnicGroup()
	local pdd = PetData[self.templateId]

	return pdd and pdd.ethnicGroup or 0
end

function PetInfo:updatePetPrototypeId()
	local pdd = PetData[self.templateId]

	self.petPrototypeId = pdd and pdd.petPrototypeId or 0
	self.basePetPrototypeId = Utils.getBasePetPrototypeId(self.petPrototypeId)
end

function PetInfo:getEntity()
	local ent = pg.getEntity(self.id)

	return Utils.isPet(ent) and ent or nil
end

function PetInfo:getOwnerPlayer()
	return ObjHelper.validateObj(self:getObj(), ObjHelper.TYPE_PLAYER)
end

function PetInfo:getTotalExp()
	local total = 0

	for i = 1, self.level do
		local pdd = PetLevelData[i]

		total = total + (pdd and pdd.needExp or 0)
	end

	total = total + self.exp

	return total
end

function PetInfo:getElementTypes()
	local pdd = PetPrototypeData[self.petPrototypeId]

	return pdd and pdd.elementType or {}
end

function PetInfo:getElementTypeIds()
	local pdd = PetPrototypeData[self.petPrototypeId]
	local elementTypeNameList = pdd and pdd.elementType or {}
	local elementTypeIds = {}

	for _, element in pairs(elementTypeNameList) do
		local elementTypeId = PetElementNameToId[element] or 0

		if elementTypeId > 0 then
			elementTypeIds[#elementTypeIds + 1] = elementTypeId
		end
	end

	return elementTypeIds
end

function PetInfo:checkHasElementType(elementTypeId)
	if not elementTypeId then
		return false
	end

	local petElementTypeIds = self:getElementTypeIds()
	local k = lume.findInList(petElementTypeIds, elementTypeId)

	return k and k > 0
end

function PetInfo:getFormId()
	return Utils.getPetFormIdByPrototypeId(self.petPrototypeId)
end

function PetInfo:checkCanExplore(explore)
	if not explore or not ExploreAbilityData[explore] then
		return false
	end

	local cfg = PetPrototypeData[self.petPrototypeId] or {}

	return cfg[explore] and cfg[explore] >= 1
end

function PetInfo:isInReportList()
	local player = self:getOwnerPlayer()

	if player == nil then
		return false
	end

	return lume.match(player.catchPetsInfoReportList or {}, function(reportPetInfo)
		return reportPetInfo.petId == self.id
	end) ~= nil
end

function PetInfo:getCpValue()
	return Utils.getCpValue(self)
end

function PetInfo:getCpValueWithLevel(level)
	return Utils.getCpValue(self, level)
end

function PetInfo:getCpValueForRank(orderType)
	if self:isInReportList() then
		if orderType == 0 then
			return 9999999999999
		else
			return 0
		end
	end

	return Utils.getCpValue(self)
end

function PetInfo:getTimeForRank(orderType)
	return self.time
end

function PetInfo:isCatchReporting()
	local player = self:getOwnerPlayer()

	if player == nil then
		return false
	end

	return lume.match(player.catchPetsInfoReportList, function(catchPetInfo)
		return catchPetInfo.petId == self.id
	end) ~= nil
end

function PetInfo:getNumberId()
	local prcdd = PetResearchContentData[Utils.getBasePetPrototypeId(self.petPrototypeId)]

	return prcdd and prcdd.number or 0
end

function PetInfo:getNumberIdForRank(orderType)
	local prcdd = PetResearchContentData[Utils.getBasePetPrototypeId(self.petPrototypeId)]

	return prcdd and prcdd.number or 0
end

function PetInfo:hasAbility(abilityParamId)
	return self.unlockedAbilityMap[abilityParamId] ~= nil
end

function PetInfo:hasAbilityOrEnhanced(abilityParamId)
	if self:hasAbility(abilityParamId) then
		return true
	end

	local basePetPrototypeId = Utils.getBasePetPrototypeId(self.petPrototypeId)
	local skillData = PetSkillData[basePetPrototypeId] and PetSkillData[basePetPrototypeId][abilityParamId]
	local enhancedSkillId = skillData and skillData.enhancedSkillId

	return enhancedSkillId and self:hasAbility(enhancedSkillId) or false
end

function PetInfo:canEvolveBranch(branchId, skipItemCondition)
	local pedd = PetEvolveData[self.petPrototypeId] and PetEvolveData[self.petPrototypeId][branchId]
	local petTemplateId = pedd and PetPrototypeData[pedd.targetPetId] and PetPrototypeData[pedd.targetPetId].defaultPet
	local petPrototypeId = Utils.getPetPetPrototypeId(petTemplateId)
	local pddNext = PetData[petTemplateId]

	if pddNext == nil then
		return false
	end

	local player = self:getObj()

	if player == nil or not Utils.isPlayer(player) then
		return false
	end

	local handbookInfo = player.petHandbookMap[self.petPrototypeId]
	local evolveResearchInfo = handbookInfo and handbookInfo:getEvolveResearchInfoWithDefault(branchId)

	if evolveResearchInfo == nil or evolveResearchInfo.status < Const.PET_RESEARCH.STATUS_CLUE then
		return false
	end

	if not skipItemCondition and ItemUtils.getEvolveNeedItemResult(player, pedd.itemConditions) == false then
		return false
	end

	local targetHandbookInfo = player.petHandbookMap[petPrototypeId]

	if (not targetHandbookInfo or not targetHandbookInfo:isEvolveGet()) and pedd.normalCondition0 then
		local needCond = pedd.normalCondition0[Const.PET_EVOLVE_NORMAL_COND_POS_COND]

		if not player.triggerMap:isCompleteOrMeetCondition(needCond) then
			return false
		end
	end

	for _, needCondData in pairs(pedd.normalConditions or EMPTY_TABLE) do
		local needCond = needCondData[Const.PET_EVOLVE_NORMAL_COND_POS_COND]

		if not self.triggerMap:isCompleteOrMeetCondition(needCond) then
			return false
		end
	end

	return true
end

function PetInfo:getEvolveBranchesInfo()
	local branchesCfg = PetEvolveData[self.petPrototypeId] and PetEvolveData[self.petPrototypeId]

	if branchesCfg == nil then
		return
	end

	local player = self:getObj()
	local handbookInfo = player.petHandbookMap[self.petPrototypeId]
	local retInfo = {}

	for branchId, branchCfg in pairs(branchesCfg) do
		local canEvolve = self:canEvolveBranch(branchId)
		local evolveResearchInfo = handbookInfo and handbookInfo:getEvolveResearchInfoWithDefault(branchId)
		local isEvoleved = evolveResearchInfo ~= nil and evolveResearchInfo.status >= Const.PET_RESEARCH.STATUS_SHOW
		local isReachedExcludeWhiteConds = false

		if not canEvolve then
			isReachedExcludeWhiteConds = self:checkIsReachedExcludeWhiteConds(branchId)
		end

		retInfo[branchId] = {
			canEvolve = canEvolve,
			isEvoleved = isEvoleved,
			isReachedExcludeWhiteConds = isReachedExcludeWhiteConds,
			branchId = branchId
		}
	end

	return retInfo
end

function PetInfo:getEvolveBranchesStatus(refInfo)
	refInfo = refInfo or {}

	local UIConst = require("Const.UIConst")
	local allBranchesInfo = self:getEvolveBranchesInfo()

	if allBranchesInfo == nil or not next(allBranchesInfo) then
		return UIConst.EvolveStatus.CANNOT_EVOLVE
	end

	local isExistCanEvolve = false

	for _, branchInfo in pairs(allBranchesInfo) do
		isExistCanEvolve = isExistCanEvolve or branchInfo.canEvolve

		if branchInfo.canEvolve and not branchInfo.isEvoleved then
			refInfo.branchId = branchInfo.branchId

			return UIConst.EvolveStatus.CAN_EVOLVE_FIRST
		end
	end

	local retStatus = isExistCanEvolve and UIConst.EvolveStatus.CAN_EVOLVE_NOT_FIRST or UIConst.EvolveStatus.CANNOT_EVOLVE

	return retStatus
end

function PetInfo:checkIsReachedExcludeWhiteConds(branchId)
	local player = self:getObj()
	local pedd = PetEvolveData[self.petPrototypeId] and PetEvolveData[self.petPrototypeId][branchId]
	local petTemplateId = pedd and PetPrototypeData[pedd.targetPetId] and PetPrototypeData[pedd.targetPetId].defaultPet
	local petPrototypeId = Utils.getPetPetPrototypeId(petTemplateId)
	local targetHandbookInfo = player.petHandbookMap[petPrototypeId]
	local whiteConditionIds = pedd.grayConditionsExclude

	if not whiteConditionIds or not next(whiteConditionIds) then
		return false
	end

	local normalCondition0 = pedd.normalCondition0
	local normalConditions = pedd.normalConditions

	if not normalCondition0 and (not normalConditions or not next(normalConditions)) then
		return false
	end

	local excludeWhiteNormalCondIds = {}

	for _, condData in pairs(normalConditions or EMPTY_TABLE) do
		local condId = condData[Const.PET_EVOLVE_NORMAL_COND_POS_COND]

		if not table.contains(whiteConditionIds, condId) then
			excludeWhiteNormalCondIds[#excludeWhiteNormalCondIds + 1] = condId
		end
	end

	local isExistNotReachedCond0 = false
	local isExistNotReachedNormalCond = false

	if (not targetHandbookInfo or not targetHandbookInfo:isEvolveGet()) and pedd.normalCondition0 then
		local needCond = pedd.normalCondition0[Const.PET_EVOLVE_NORMAL_COND_POS_COND]

		if not player.triggerMap:isCompleteOrMeetCondition(needCond) then
			isExistNotReachedCond0 = true
		end
	end

	for _, needCondData in pairs(pedd.normalConditions or EMPTY_TABLE) do
		local needCond = needCondData[Const.PET_EVOLVE_NORMAL_COND_POS_COND]

		if table.contains(excludeWhiteNormalCondIds, needCond) and not self.triggerMap:isCompleteOrMeetCondition(needCond) then
			isExistNotReachedNormalCond = true
		end
	end

	if not isExistNotReachedCond0 and not isExistNotReachedNormalCond then
		return true
	end

	return false
end

function PetInfo:canEvolveAny(skipItemCondition)
	for branchId, _ in pairs(PetEvolveData[self.petPrototypeId] or EMPTY_TABLE) do
		if self:canEvolveBranch(branchId, skipItemCondition) then
			return true
		end
	end

	return false
end

function PetInfo:dumpEvolveConditionStatus()
	if not _G_IsDebugMode then
		return {}
	end

	local player = self:getObj()
	local res = {}

	for branchId, _ in pairs(PetEvolveData[self.petPrototypeId] or EMPTY_TABLE) do
		res[branchId] = res[branchId] or {}

		local pedd = PetEvolveData[self.petPrototypeId][branchId]
		local handbookInfo = player.petHandbookMap[self.petPrototypeId]
		local evolveResearchInfo = handbookInfo and handbookInfo:getEvolveResearchInfoWithDefault(branchId)

		res[branchId].routeState = evolveResearchInfo and evolveResearchInfo.status
		res[branchId].routeStateSuccess = evolveResearchInfo and evolveResearchInfo.status >= Const.PET_RESEARCH.STATUS_CLUE
		res[branchId].cfgItems = res[branchId].cfgItems or {}

		for idx, needItemData in ipairs(pedd.itemConditions or EMPTY_TABLE) do
			local needItem = needItemData[Const.PET_EVOLVE_ITEM_COND_POS_ITEM]

			res[branchId].cfgItems[idx] = {
				need = {
					needItem[1],
					needItem[2]
				},
				status = ItemUtils.getItemCountById(player, needItem[1]) >= needItem[2]
			}
		end

		res[branchId].altItems = res[branchId].altItems or {}

		local itemRet, idNumDict = ItemUtils.getEvolveNeedItemResult(player, pedd.itemConditions)

		res[branchId].altItems.itemRet = itemRet
		res[branchId].altItems.items = {}

		for itemId, itemCount in pairs(idNumDict) do
			res[branchId].altItems.items[itemId] = {
				needCount = itemCount,
				hasCount = ItemUtils.getItemCountById(player, itemId)
			}
		end

		res[branchId].conds = res[branchId].conds or {}

		if pedd.normalCondition0 then
			local targetPetTemplateId = pedd and PetPrototypeData[pedd.targetPetId] and PetPrototypeData[pedd.targetPetId].defaultPet
			local targetPetPrototypeId = Utils.getPetPetPrototypeId(targetPetTemplateId)
			local targetHandbookInfo = player.petHandbookMap[targetPetPrototypeId]
			local needCond = pedd.normalCondition0[Const.PET_EVOLVE_NORMAL_COND_POS_COND]

			res[branchId].conds[0] = {
				need = needCond,
				isEvolveGet = targetHandbookInfo and targetHandbookInfo:isEvolveGet() or false,
				CondRealstatus = self.triggerMap:isCompleteOrMeetCondition(needCond)
			}
		end

		for idx, needCondData in ipairs(pedd.normalConditions or EMPTY_TABLE) do
			local needCond = needCondData[Const.PET_EVOLVE_NORMAL_COND_POS_COND]

			res[branchId].conds[idx] = {
				need = needCond,
				status = self.triggerMap:isCompleteOrMeetCondition(needCond)
			}
		end
	end

	return res
end

function PetInfo:getPropRatingResult()
	local stage = self.propertyScoreStage or 1
	local pageIndex = stage - 1
	local ratingStr = Const.STAGE_TO_RATING_STR[stage] or ""

	return pageIndex, ratingStr
end

function PetInfo.staticGetPropRatingResult(decodeInfo)
	local pageIndex = decodeInfo and decodeInfo.pageIndex or 0
	local ratingStr = decodeInfo and decodeInfo.ratingString or ""

	return pageIndex, ratingStr
end

function PetInfo:getPropRatingResultForRank(orderType)
	if self:isInReportList() then
		if orderType == 0 then
			return 9999999999999
		else
			return -1
		end
	end

	local stage = self.propertyScoreStage or 1

	return stage
end

function PetInfo:getLevelForRank(orderType)
	return self.level
end

function PetInfo:getRareAbilityOrCharacterCount()
	local count = 0
	local isRareAbilityByParamId = AbilityUtils.isRareAbilityByParamId

	for abilityParamId, _ in self.unlockedAbilityMap:items() do
		if isRareAbilityByParamId(abilityParamId, self.templateId) then
			count = count + 1
		end
	end

	local pcdd = PetCharacterData[self.characterInfo.curCharacter]

	if ToBool(pcdd and pcdd.rare) then
		count = count + 1
	end

	return count
end

function PetInfo:_getExpResetItems(ratio)
	ratio = ratio or 0

	local res = {}

	if ratio <= 0 then
		return res
	end

	local player = self:getOwnerPlayer()

	if player == nil then
		logger:error("PetInfo:_getExpResetItems failed, player is nil")

		return res
	end

	local itemExpList = lume.imap(PetConfigData.releasePetExpItemIdList or {}, function(itemId)
		return {
			itemId,
			ItemUtils.getItemPetExp(player, itemId)
		}
	end)

	itemExpList = lume.sort(itemExpList, function(a, b)
		return a[2] > b[2]
	end)

	local totalExp = self.expFromItem
	local remainingExp = totalExp * ratio

	for i, itemExp in ipairs(itemExpList) do
		local itemId, exp = itemExp[1], itemExp[2]

		if exp > 0 then
			local count = 0

			if exp <= remainingExp then
				count = math.safe_floor(remainingExp / exp)

				ItemUtils.addItemInfoToRet(res, itemId, count, Const.INV_BOUND_TYPE_BOUND)

				remainingExp = remainingExp - count * exp
			end
		end
	end

	return res
end

function PetInfo:_getBreakResetItems(ratio)
	ratio = ratio or 0
	ratio = lume.clamp(ratio, 0, 1)

	local res = {}
	local itemIds = Utils.getBreakthroughItems(self.templateId)

	if itemIds == nil then
		return res
	end

	local itemCounts = {}

	for i = self.levelOnCreate, self.level do
		local pldNext = PetLevelData[i + 1]
		local needPayback = false

		if pldNext and pldNext.breakthroughItemNums then
			needPayback = i < self.level or not self.needBreakthrough
		end

		if needPayback then
			for idx, _ in ipairs(itemIds) do
				itemCounts[idx] = (itemCounts[idx] or 0) + (pldNext.breakthroughItemNums[idx] or 0)
			end
		end
	end

	for idx, itemId in ipairs(itemIds) do
		local itemCount = itemCounts[idx] or 0

		if itemCount > 0 then
			local count = math.safe_floor(itemCount * ratio)

			ItemUtils.addItemInfoToRet(res, itemId, count, Const.INV_BOUND_TYPE_BOUND)
		end
	end

	return res
end

function PetInfo:getLevelExpResetPayback()
	local res = {}
	local expItemRatio = PetConfigData.releasePetExpItemRatio or 0

	if expItemRatio > 0 then
		local expResetItems = self:_getExpResetItems(expItemRatio)

		ItemUtils.mergeItemInfoResult(res, expResetItems)
	end

	local breakItemRatio = PetConfigData.releasePetBreakthroughRatio or 0

	if breakItemRatio > 0 then
		local breakResetItems = self:_getBreakResetItems(breakItemRatio)

		ItemUtils.mergeItemInfoResult(res, breakResetItems)
	end

	return res
end

function PetInfo:getResonanceItemsBack()
	local res = Utils.calcPetResonanceCost(self, self.resonanceInfo.resonanceStage, self.resonanceInfo.resonanceLevel)
	local rate = PetConfigData.releasePetResonanceRatio or 1
	local items = {}

	for i, _ in pairs(res) do
		ItemUtils.addItemInfoToRet(items, i, math_floor(res[i] * rate), Const.INV_BOUND_TYPE_BOUND)
	end

	return items
end

function PetInfo:getHomeEventInfo(homeSpace)
	if not homeSpace or not Utils.isHomeland(homeSpace.spaceType) or not homeSpace.getPetHomeEventInsId then
		return nil
	end

	local eventInsId = homeSpace:getPetHomeEventInsId(self.id)

	return homeSpace.homeEventMap[eventInsId]
end

function PetInfo:getHomeEventTypeData(homeSpace)
	if not homeSpace or not Utils.isHomeland(homeSpace.spaceType) then
		return nil
	end

	local eventInfo = self:getHomeEventInfo(homeSpace)

	if eventInfo then
		return eventInfo:getEventTypeData()
	end

	return nil
end

function PetInfo:getHomeEventPetStatus(homeSpace)
	if not homeSpace or not Utils.isHomeland(homeSpace.spaceType) then
		return nil
	end

	local eventTypeData = self:getHomeEventTypeData(homeSpace)

	return eventTypeData and eventTypeData.petStatus
end

local function getCoreCarryPosMap(petInfo)
	local player = petInfo:getOwnerPlayer()

	if not player then
		return nil
	end

	if player.tempPets and player.tempPets[petInfo.id] == petInfo then
		return player.tempPetCoreCarryPosMap
	end

	if player.pets and player.pets[petInfo.id] == petInfo then
		return player.petCoreCarryPosMap
	end

	return nil
end

function PetInfo:getCoreCarryItem()
	local carryPosMap = getCoreCarryPosMap(self)

	return carryPosMap and carryPosMap:getItem(self.id) or nil
end

function PetInfo:getCoreCarryInfo()
	local carryPosMap = getCoreCarryPosMap(self)

	return carryPosMap and carryPosMap:getItemInfo(self.id) or nil
end

function PetInfo.getBodyEntryList(selfInfo)
	return {}
end

function PetInfo.checkBreed(selfInfo)
	if selfInfo.level < PetBallConfigData.breedPetLvLimit then
		return false, NoticeDef.ERROR_1
	end

	if selfInfo.breedCount >= PetBallConfigData.canBreedingTimes then
		return false, NoticeDef.ERROR_2
	end

	if selfInfo.gender ~= Const.GENDER_TYPE_MALE and selfInfo.gender ~= Const.GENDER_TYPE_FEMALE then
		return false, NoticeDef.ERROR_3
	end

	return true, nil
end

function PetInfo.getBreedQueryInfo(selfInfo)
	return {
		templateId = selfInfo.templateId,
		basePetPrototypeId = selfInfo.basePetPrototypeId,
		level = selfInfo.level,
		gender = selfInfo.gender,
		breedCount = selfInfo.breedCount
	}
end

function PetInfo.checkBreedByQuery(selfInfo, queryInfo)
	local ok, err = PetInfo.checkBreed(selfInfo)

	if not ok then
		return false, NoticeDef.ERROR_1
	end

	if selfInfo.basePetPrototypeId ~= queryInfo.basePetPrototypeId then
		return false, NoticeDef.ERROR_2
	end

	if selfInfo.gender == Const.GENDER_TYPE_MALE and queryInfo.gender ~= Const.GENDER_TYPE_FEMALE then
		return false, NoticeDef.ERROR_3
	end

	if selfInfo.gender == Const.GENDER_TYPE_FEMALE and queryInfo.gender ~= Const.GENDER_TYPE_MALE then
		return false, NoticeDef.ERROR_4
	end

	return true, nil
end

function PetInfo.genBreedEggInfo(player, selfInfo, otherUid, otherInfo, selectInfo)
	local breedSource = SocialUtils.genBreedSource(selfInfo.templateId, otherUid, otherInfo.templateId)
	local father = selfInfo.gender == Const.GENDER_TYPE_MALE and selfInfo or otherInfo
	local mother = selfInfo.gender == Const.GENDER_TYPE_FEMALE and selfInfo or otherInfo
	local newTemplateId, isMutationTemplateId = SocialUtils.breedGenEggTemplateId(father, mother, selectInfo.itemId, player)
	local newLabel, isMutationLabel = SocialUtils.breedGenEggLabel(father, mother, selectInfo.itemId)
	local newFeature, isMutationFeature = SocialUtils.breedGenEggFeature(father, mother, newTemplateId, newLabel)
	local newBaseProps, isMutationBaseProps = SocialUtils.breedGenEggBaseProps(father, mother, selectInfo.itemId, selectInfo.propPetId)
	local eggInfo = {
		isMutation = isMutationTemplateId or isMutationLabel or isMutationFeature or isMutationBaseProps,
		breedSource = breedSource,
		templateId = newTemplateId,
		label = newLabel,
		characterId = newFeature,
		basePropertyindividualLevelList = newBaseProps
	}

	return eggInfo
end

function PetInfo.genInitDictFromBreedEggInfo(eggInfo)
	local individualLevelInfo = {}
	local basePropertyList = require("CustomTypes.BasePropertyList").genInitDict(ObjHelper.TYPE_PET_INFO, PetData[eggInfo.templateId], eggInfo.basePropertyindividualLevelList, nil, individualLevelInfo)
	local initInfo = {
		propertyEnhancedCount = 0,
		breedSource = eggInfo.breedSource,
		templateId = eggInfo.templateId,
		label = eggInfo.label,
		characterInfo = {
			characterList = {
				eggInfo.characterId
			},
			curCharacter = eggInfo.characterId
		},
		basePropertyList = basePropertyList
	}

	if individualLevelInfo.propertyScoreStage then
		initInfo.propertyScoreStage = individualLevelInfo.propertyScoreStage
	end

	return initInfo
end

function PetInfo.genInitDictFromDispatchEggInfo(eggInfo)
	if not eggInfo or not PetData[eggInfo.templateId] then
		return nil
	end

	local initInfo = {
		propertyEnhancedCount = 0,
		templateId = eggInfo.templateId,
		label = eggInfo.label or Const.PET_LABEL_MASK.NORMAL,
		shinyStyle = eggInfo.shinyStyle
	}

	if eggInfo.basePropertyindividualLevelList then
		local individualLevelInfo = {
			individualLevelList = eggInfo.basePropertyindividualLevelList
		}
		local basePropertyList = require("CustomTypes.BasePropertyList").genInitDict(ObjHelper.TYPE_PET_INFO, PetData[eggInfo.templateId], nil, {}, individualLevelInfo)

		initInfo.basePropertyList = basePropertyList
		initInfo.propertyScoreStage = eggInfo.propertyScoreStage or Utils.getBaseIndividualInitStageNew(basePropertyList, eggInfo.templateId, 0)
	end

	return initInfo
end

function PetInfo:getCurrTransmogMaxSlotType()
	local maxSlotType = 0
	local transmogInfo = self:getTransmogInfo()
	local unlockSlots = transmogInfo and transmogInfo.transmogUnlockSolts

	for _, holeId in ipairs(unlockSlots or EMPTY_TABLE) do
		if holeId and maxSlotType < holeId then
			maxSlotType = holeId
		end
	end

	return maxSlotType
end

function PetInfo:dumpAttr()
	local res = {}
	local attributeMap = PetAttributeCalcUtils.getAttributeMapByPetInfo(self:getOwnerPlayer(), self)

	for attrId, attrValue in pairs(attributeMap) do
		res[AttributeConst.ID2NAME[attrId]] = attrValue
	end

	return res
end

function PetInfo:dumpProp()
	local res = {}

	for index, _ in self.basePropertyList:items() do
		res[Utils.getPropFinalAttrName(index)] = self.basePropertyList:getTotal(index)
	end

	return res
end

function PetInfo:hasTalent(talentId)
	if not self.talentList then
		return false
	end

	for _, talentInfo in ipairs(self.talentList) do
		if talentInfo.templateId == talentId then
			return true
		end
	end

	return false
end

function PetInfo:dump(simple)
	local player = self:getObj()
	local indexStr = "0_0"

	if player and player.petBoxMap then
		local indexBox, indexSlot = player.petBoxMap:getPetIndex(self.id)

		if indexBox and indexSlot then
			indexStr = string.format("%d_%d", indexBox, indexSlot)
		end
	end

	return {
		_index = indexStr,
		_repr = self:repr(),
		gender = self.gender,
		curCharacter = self.characterInfo.curCharacter,
		attr = not simple and self:dumpAttr() or nil,
		prop = not simple and self:dumpProp() or nil
	}
end

return PetInfo
