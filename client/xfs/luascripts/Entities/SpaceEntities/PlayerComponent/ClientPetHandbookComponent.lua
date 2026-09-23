-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientPetHandbookComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local lume = require("Core.Common.lume")
local class = require("Core.Framework.Class")
local PetProtoTypeData = require("Data.pet_prototype_data")
local PetResearchUtils = require("Guis.Utils.PetResearchUtils")
local MessageName = require("Const.MessageName")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local NoticeDef = require("Common.NoticeDef")
local PetResearchData = require("Data.pet_research_content_data")
local PetData = require("Data.pet_data")
local PetEvolveData = require("Data.pet_evolve_data")
local PetResearchTargetData = require("Data.pet_research_target_data")
local PetResearchResultData = require("Data.pet_research_result_data")
local PetResearchCountryLevelData = require("Data.pet_research_country_level_data")
local PetResearchCountryCollectData = require("Data.pet_research_country_collect_data")
local PetResearchCountrySpeciesCollectData = require("Data.pet_research_country_species_collect_data")
local PetBasePrototypeToPrototypeMap = require("Data.pet_base_prototype_to_prototype_map")
local PetResearchCountrySpeciesList = require("Data.pet_research_country_species_list")
local PetResearchCountryFormList = require("Data.pet_research_country_form_list")
local CountryAreaData = require("Data.country_area_data")
local PetTraitData = require("Data.pet_trait_data")
local MapBlockConfigData = require("Data.map_block_config_data")
local PetHandbookMap = require("CustomTypes.PetHandbookMap")
local CallbackHandler = require("Core.Common.CallbackHandler")
local bit = bit
local ClientPetHandbookComponent = class.Component("ClientPetHandbookComponent")

function ClientPetHandbookComponent:start()
	self:refreshCountryStarInfo()
end

function ClientPetHandbookComponent:ensurePetHandbookMap()
	if self.petHandbookMap == nil then
		self.petHandbookMap = PetHandbookMap({})
	end

	return self.petHandbookMap
end

function ClientPetHandbookComponent:getHandBookPatchKey(target, key)
	local classType = target and target.__ClassType
	local valueTypeDeclare = classType and classType.__ValueTypeDeclare__

	if valueTypeDeclare and valueTypeDeclare.intTypeKey then
		return tonumber(key) or key
	end

	return key
end

function ClientPetHandbookComponent:mergeHandBookValueMap(target, source)
	for key, value in pairs(source) do
		target[tonumber(key) or key] = value
	end
end

function ClientPetHandbookComponent:mergeHandBookValueMapMap(target, source)
	for key, value in pairs(source) do
		key = tonumber(key) or key
		target[key] = target[key] or {}

		self:mergeHandBookValueMap(target[key], value)
	end
end

function ClientPetHandbookComponent:getHandBookPatchDeclare(target, key)
	local classType = target.__ClassType
	local propDeclares = classType.__Name2PropertyDeclare__
	local declare = propDeclares[key]

	if declare == nil then
		declare = classType.__ValueTypeDeclare__
	end

	return declare
end

function ClientPetHandbookComponent:isHandBookPatchDictField(target, key)
	local declare = self:getHandBookPatchDeclare(target, key)

	return declare and declare.customClass and declare.customClass.__CUSTOM_DICT__
end

function ClientPetHandbookComponent:mergeHandBookPatchTable(target, source)
	for key, value in pairs(source) do
		key = self:getHandBookPatchKey(target, key)

		local targetValue = target[key]

		if value and targetValue and self:isHandBookPatchDictField(target, key) and next(value) ~= nil then
			self:mergeHandBookPatchTable(targetValue, value)
		else
			target[key] = value
		end
	end
end

function ClientPetHandbookComponent:getHandBookMapDTOData(data)
	local handbookData = data.petHandbookMap

	if handbookData then
		return handbookData
	end

	handbookData = Utils.deepCopyTable(data)
	handbookData.blockCatchRewardStatus = nil
	handbookData.blockCatchedPetMap = nil
	handbookData.displayPetFormMap = nil
	handbookData.displayPetLabelMap = nil
	handbookData.displayFormPetLabelMap = nil
	handbookData.displayPetFormByCountryMap = nil
	handbookData.displayFormPetLabelByCountryMap = nil
	handbookData.petHandbookDisplayMode = nil
	handbookData.petHandbookSortMode = nil

	return handbookData
end

function ClientPetHandbookComponent:applyHandBookFullData(data)
	self.petHandbookMap = PetHandbookMap(self:getHandBookMapDTOData(data))
	self.displayPetFormMap = Utils.deepCopyTable(data.displayPetFormMap or {})
	self.displayPetLabelMap = Utils.deepCopyTable(data.displayPetLabelMap or {})
	self.displayFormPetLabelMap = Utils.deepCopyTable(data.displayFormPetLabelMap or {})
	self.displayPetFormByCountryMap = Utils.deepCopyTable(data.displayPetFormByCountryMap or {})
	self.displayFormPetLabelByCountryMap = Utils.deepCopyTable(data.displayFormPetLabelByCountryMap or {})
	self.blockCatchRewardStatus = Utils.deepCopyTable(data.blockCatchRewardStatus or {})
	self.blockCatchedPetMap = Utils.deepCopyTable(data.blockCatchedPetMap or {})
	self.petHandbookDisplayMode = data.petHandbookDisplayMode
	self.petHandbookSortMode = data.petHandbookSortMode
end

function ClientPetHandbookComponent:applyHandBookPatchData(data)
	local handbookData = data.petHandbookMap

	if handbookData then
		self:mergeHandBookPatchTable(self:ensurePetHandbookMap(), handbookData)
	end

	if data.displayPetFormMap ~= nil then
		self.displayPetFormMap = self.displayPetFormMap or {}

		self:mergeHandBookValueMap(self.displayPetFormMap, data.displayPetFormMap)
	end

	if data.displayPetLabelMap ~= nil then
		self.displayPetLabelMap = self.displayPetLabelMap or {}

		self:mergeHandBookValueMap(self.displayPetLabelMap, data.displayPetLabelMap)
	end

	if data.displayFormPetLabelMap ~= nil then
		self.displayFormPetLabelMap = self.displayFormPetLabelMap or {}

		self:mergeHandBookValueMap(self.displayFormPetLabelMap, data.displayFormPetLabelMap)
	end

	if data.displayPetFormByCountryMap ~= nil then
		self.displayPetFormByCountryMap = self.displayPetFormByCountryMap or {}

		self:mergeHandBookValueMapMap(self.displayPetFormByCountryMap, data.displayPetFormByCountryMap)
	end

	if data.displayFormPetLabelByCountryMap ~= nil then
		self.displayFormPetLabelByCountryMap = self.displayFormPetLabelByCountryMap or {}

		self:mergeHandBookValueMapMap(self.displayFormPetLabelByCountryMap, data.displayFormPetLabelByCountryMap)
	end

	if data.blockCatchRewardStatus ~= nil then
		self.blockCatchRewardStatus = self.blockCatchRewardStatus or {}

		self:mergeHandBookValueMapMap(self.blockCatchRewardStatus, data.blockCatchRewardStatus)
	end

	if data.blockCatchedPetMap ~= nil then
		self.blockCatchedPetMap = self.blockCatchedPetMap or {}

		self:mergeHandBookValueMapMap(self.blockCatchedPetMap, data.blockCatchedPetMap)
	end

	if data.petHandbookDisplayMode ~= nil then
		self.petHandbookDisplayMode = data.petHandbookDisplayMode
	end

	if data.petHandbookSortMode ~= nil then
		self.petHandbookSortMode = data.petHandbookSortMode
	end
end

function ClientPetHandbookComponent:sendHandBookPetRewardChangedMessage(petPrototypeId, petChanges)
	for level, newStatus in pairs(petChanges.levelRewardStatus or EMPTY_TABLE) do
		facade:sendMsgToUI(MessageName.PET_RESEARCH_LEVEL_REWARD_STATUS_CHANGE, {
			templateId = petPrototypeId,
			level = level,
			newStatus = newStatus
		})
	end

	if petChanges.rewardedTargetMap ~= nil then
		facade:sendMsgToUI(MessageName.PET_TOPIC_REWARD_CHANGED)
	end
end

function ClientPetHandbookComponent:sendHandBookCountryRewardChangedMessage(countryId, countryChanges)
	if countryChanges.totalLevelRewardStatus ~= nil or countryChanges.collectLevelRewardStatus ~= nil or countryChanges.speciesCollectLevelRewardStatus ~= nil then
		facade:sendMsgToUI(MessageName.PET_RESEARCH_COUNTRY_REWARD_STATUS_CHANGE, {
			countryId = countryId
		})
	end

	if countryChanges.collectLevelRewardStatus ~= nil or countryChanges.speciesCollectLevelRewardStatus ~= nil then
		facade:sendMsgToUI(MessageName.PET_RESEARCH_PROGRESS_REWARD_STATUS_CHANGE, {})
	end
end

function ClientPetHandbookComponent:sendHandBookChangedMessage(changes)
	if changes.blockCatchRewardStatus ~= nil or changes.blockCatchedPetMap ~= nil then
		facade:sendMsgToUI(MessageName.PET_AREA_REWARD_CHANGE)
	end

	local handbookChanges = changes.petHandbookMap or {}

	for petPrototypeId, petChanges in pairs(handbookChanges) do
		if petPrototypeId ~= "petCountryMap" then
			self:sendHandBookPetRewardChangedMessage(petPrototypeId, petChanges)
		end
	end

	for countryId, countryChanges in pairs(handbookChanges.petCountryMap or EMPTY_TABLE) do
		self:sendHandBookCountryRewardChangedMessage(countryId, countryChanges)
	end
end

function ClientPetHandbookComponent:applyHandBookData(data)
	self:applyHandBookFullData(data)
	self:refreshCountryStarInfo()
end

function ClientPetHandbookComponent:applyHandBookChanges(changes)
	if not changes or next(changes) == nil then
		return
	end

	self:applyHandBookPatchData(changes)
	self:refreshCountryStarInfo()
	self:sendHandBookChangedMessage(changes)
end

function ClientPetHandbookComponent:applyHandBookServiceResponse(response)
	if not response then
		return
	end

	if response.data then
		self:applyHandBookData(response.data)
	end

	if response.changes then
		self:applyHandBookChanges(response.changes)
	end
end

function ClientPetHandbookComponent:onHandBookServiceCallback(status, response, callback)
	if not status or not status.status then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			self.logger:warn("onHandBookServiceCallback failed status=%s response=%s", inspect(status), inspect(response))
		end

		if callback then
			callback(status, response)
		end

		return
	end

	if response and response.flag then
		self:applyHandBookServiceResponse(response)
	end

	if callback then
		callback(status, response)
	end
end

function ClientPetHandbookComponent:callHandBookService(methodName, args, callback, options)
	return self:callService("HandBookService", methodName, args or {}, function(status, response)
		self:onHandBookServiceCallback(status, response, callback)
	end, options)
end

function ClientPetHandbookComponent:reqHandBookData(callback)
	self:callHandBookService("CS_GetHandBookData", {}, callback)
end

function ClientPetHandbookComponent:reqHandBookDataAfterLogin()
	if self.handBookDataRequestedAfterLogin then
		return
	end

	self.handBookDataRequestedAfterLogin = true

	self:ensurePetHandbookMap()
	self:reqHandBookData()
end

function ClientPetHandbookComponent:getPetHandbookInfo(petPrototypeId)
	return self.petHandbookMap and self.petHandbookMap[petPrototypeId]
end

function ClientPetHandbookComponent:getPetCountryInfo(countryId)
	return self.petHandbookMap and self.petHandbookMap.petCountryMap and self.petHandbookMap.petCountryMap[countryId]
end

function ClientPetHandbookComponent:hasPetStateMask(petPrototypeId, mask, groupType)
	groupType = groupType or Const.GROUP_TYPE_ANY

	return Utils.getBoolByPetPrototypeIdAndGroupType(petPrototypeId, groupType, function(innerPetPrototypeId)
		local info = self:getPetHandbookInfo(innerPetPrototypeId)

		return info and bit.band(info.stateMask or 0, mask) == mask
	end)
end

function ClientPetHandbookComponent:isPetKnown(petPrototypeId, groupType)
	return self:hasPetStateMask(petPrototypeId, Const.PET_HBMSK_KNOWN, groupType)
end

function ClientPetHandbookComponent:isPetCatched(petPrototypeId, groupType)
	return self:hasPetStateMask(petPrototypeId, Const.PET_HBMSK_CATCHED, groupType)
end

function ClientPetHandbookComponent:isPetAllResearch(petPrototypeId, groupType)
	return self:hasPetStateMask(petPrototypeId, Const.PET_HBMSK_RESEARCHED, groupType)
end

function ClientPetHandbookComponent:isPetResearched(petPrototypeId, groupType)
	return self:isPetAllResearch(petPrototypeId, groupType)
end

function ClientPetHandbookComponent:isPetShinyKnown(petPrototypeId, groupType)
	return self:hasPetStateMask(petPrototypeId, Const.PET_HBMSK_SHINY_KNOWN, groupType)
end

function ClientPetHandbookComponent:isPetShinyCatched(petPrototypeId, groupType)
	return self:hasPetStateMask(petPrototypeId, Const.PET_HBMSK_SHINY_CATCHED, groupType)
end

function ClientPetHandbookComponent:isPetRainbowCatched(petPrototypeId, groupType)
	return self:hasPetStateMask(petPrototypeId, Const.PET_HBMSK_RAINBOW_CATCHED, groupType)
end

function ClientPetHandbookComponent:isPetEvolveGet(petPrototypeId, groupType)
	return self:hasPetStateMask(petPrototypeId, Const.PET_HBMSK_EVOLVE_GET, groupType)
end

function ClientPetHandbookComponent:getPetTotalExp(petPrototypeId)
	local info = self:getPetHandbookInfo(petPrototypeId)
	local prcdd = PetResearchData[Utils.getBasePetPrototypeId(petPrototypeId)]

	if not info or not prcdd then
		return 0
	end

	local totalExp = info.exp or 0
	local needResearchPoint = prcdd.needResearchPoint or {}

	for i = 1, info.level or 0 do
		totalExp = totalExp + (needResearchPoint[i] or 0)
	end

	return totalExp
end

function ClientPetHandbookComponent:getCountryTotalExp(countryId)
	local cachedMap = self.petHandbookMap and self.petHandbookMap.cachedCountryTotalExpMap

	if cachedMap and cachedMap[countryId] then
		return cachedMap[countryId]
	end

	local totalExp = 0

	for _, basePetPrototypeId in ipairs(PetResearchCountrySpeciesList[countryId] or EMPTY_TABLE) do
		totalExp = totalExp + self:getPetTotalExp(basePetPrototypeId)
	end

	return totalExp
end

function ClientPetHandbookComponent:getPetHandbookCountryTotalExp(countryId)
	return self:getCountryTotalExp(countryId)
end

function ClientPetHandbookComponent:getCountryTotalLevel(countryId)
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

function ClientPetHandbookComponent:getPetHandbookCountryTotalLevel(countryId)
	return self:getCountryTotalLevel(countryId)
end

function ClientPetHandbookComponent:getPetHandbookMaxCountryTotalLevel()
	return self:ensurePetHandbookMap():getMaxCountryTotalLevel()
end

function ClientPetHandbookComponent:getCountrySpeciesCollectNum(countryId)
	local cachedMap = self.petHandbookMap and self.petHandbookMap.cachedCountrySpeciesCollectNumMap

	if cachedMap and cachedMap[countryId] then
		return cachedMap[countryId]
	end

	local count = 0

	for _, basePetPrototypeId in ipairs(PetResearchCountrySpeciesList[countryId] or EMPTY_TABLE) do
		if self:isPetCatched(basePetPrototypeId, Const.GROUP_TYPE_ANY) then
			count = count + 1
		end
	end

	return count
end

function ClientPetHandbookComponent:getPetResearchInfo(petPrototypeId, researchKey, subIndex)
	local handbookInfo = self:getPetHandbookInfo(petPrototypeId)
	local keyMap = Const.PET_RESEARCHKEY_MAP[researchKey] or {}
	local researchInfoKey = keyMap[Const.PRM_PROPERTY]
	local researchInfo = handbookInfo and handbookInfo[researchInfoKey]

	if researchInfo and subIndex then
		researchInfo = researchInfo[subIndex]
	end

	return researchInfo
end

function ClientPetHandbookComponent:getPetResearchStatus(petPrototypeId, researchKey, subIndex)
	local researchInfo = self:getPetResearchInfo(petPrototypeId, researchKey, subIndex)

	if researchInfo == nil then
		return Const.PET_RESEARCH.STATUS_INIT
	end

	return researchInfo.status
end

function ClientPetHandbookComponent:isPetResearchUnlocked(petPrototypeId, researchKey, subIndex)
	return self:getPetResearchStatus(petPrototypeId, researchKey, subIndex) == Const.PET_RESEARCH.STATUS_DONE
end

function ClientPetHandbookComponent:getPetEvolveResearchInfoWithDefault(petPrototypeId, evolveId)
	local handbookInfo = self:getPetHandbookInfo(petPrototypeId)
	local researchInfo = handbookInfo and handbookInfo.evolveResearchMap and handbookInfo.evolveResearchMap[evolveId]

	if researchInfo == nil then
		researchInfo = PetResearchUtils.genEvolveResearchInfoInitDict(petPrototypeId, evolveId)
	end

	return researchInfo or {}
end

function ClientPetHandbookComponent:getFormCountByIdAndStateMask(needPetPrototypeId, mask, needCountryId, onlySpecialForm)
	needPetPrototypeId = needPetPrototypeId or 0
	mask = mask or 0

	local countryInfo = self:getPetCountryInfo(needCountryId)

	if needPetPrototypeId == 0 and mask ~= 0 and needCountryId ~= nil and not ToBool(onlySpecialForm) and countryInfo and countryInfo.stateMaskFormCountMap and countryInfo.stateMaskFormCountMap[mask] then
		return countryInfo.stateMaskFormCountMap[mask]
	end

	local count = 0

	if needPetPrototypeId == 0 then
		if needCountryId then
			for _, petPrototypeId in ipairs(PetResearchCountryFormList[needCountryId] or EMPTY_TABLE) do
				if not ToBool(onlySpecialForm) or not Utils.isBasePetPrototypeId(petPrototypeId) then
					local info = self:getPetHandbookInfo(petPrototypeId)

					if info and bit.band(info.stateMask or 0, mask) == mask then
						count = count + 1
					end
				end
			end
		else
			for petPrototypeId in pairs(PetProtoTypeData) do
				if not ToBool(onlySpecialForm) or not Utils.isBasePetPrototypeId(petPrototypeId) then
					local info = self:getPetHandbookInfo(petPrototypeId)

					if info and bit.band(info.stateMask or 0, mask) == mask then
						count = count + 1
					end
				end
			end
		end
	else
		local prototypeMap = PetBasePrototypeToPrototypeMap[Utils.getBasePetPrototypeId(needPetPrototypeId)] or {}

		for _, innerPetPrototypeId in ipairs(prototypeMap) do
			local info = self:getPetHandbookInfo(innerPetPrototypeId)

			if info and (not ToBool(onlySpecialForm) or not Utils.isBasePetPrototypeId(innerPetPrototypeId)) and (not needCountryId or Utils.getPetCountryId(innerPetPrototypeId) == needCountryId) and bit.band(info.stateMask or 0, mask) == mask then
				count = count + 1
			end
		end
	end

	return count
end

function ClientPetHandbookComponent:getSpeciesCountByIdAndStateMask(mask, needCountryId, needBasePetPrototypeId)
	needBasePetPrototypeId = Utils.getBasePetPrototypeId(needBasePetPrototypeId or 0)
	mask = mask or 0

	local countryInfo = self:getPetCountryInfo(needCountryId)

	if mask ~= 0 and needCountryId ~= nil and needBasePetPrototypeId == 0 and countryInfo and countryInfo.stateMaskSpeciesCountMap and countryInfo.stateMaskSpeciesCountMap[mask] then
		return countryInfo.stateMaskSpeciesCountMap[mask]
	end

	local count = 0

	if needBasePetPrototypeId == 0 then
		if needCountryId then
			for _, basePetPrototypeId in ipairs(PetResearchCountrySpeciesList[needCountryId] or EMPTY_TABLE) do
				if self:hasPetStateMask(basePetPrototypeId, mask, Const.GROUP_TYPE_ANY) then
					count = count + 1
				end
			end
		else
			local basePetPrototypeIdSet = {}

			for petPrototypeId, _ in pairs(PetProtoTypeData) do
				local info = self:getPetHandbookInfo(petPrototypeId)

				if info and bit.band(info.stateMask or 0, mask) == mask then
					local basePetPrototypeId = Utils.getBasePetPrototypeId(petPrototypeId)

					if not basePetPrototypeIdSet[basePetPrototypeId] then
						basePetPrototypeIdSet[basePetPrototypeId] = true
						count = count + 1
					end
				end
			end
		end
	elseif needCountryId == nil or Utils.checkPetHasFormInCountry(needBasePetPrototypeId, needCountryId) then
		local prototypeMap = PetBasePrototypeToPrototypeMap[needBasePetPrototypeId] or {}

		for _, prototypeId in ipairs(prototypeMap) do
			local info = self:getPetHandbookInfo(prototypeId)

			if info and bit.band(info.stateMask or 0, mask) == mask then
				count = 1

				break
			end
		end
	end

	return count
end

function ClientPetHandbookComponent:getResearchReportTotalPoint(countryId)
	local total = 0
	local countryInfo = self:getPetCountryInfo(countryId)

	for _, reportInfo in pairs(countryInfo and countryInfo.researchReportMap or EMPTY_TABLE) do
		total = total + (reportInfo.researchPoint or 0)
	end

	return total
end

function ClientPetHandbookComponent:getPetHandbookCountryReportPoint(countryId)
	return self:getResearchReportTotalPoint(countryId)
end

function ClientPetHandbookComponent:getPetHandbookAvatarResearchedCount(needBasePetPrototypeId, extraArg)
	local needLabel, needCountryId

	if extraArg ~= nil then
		if Utils.isTable(extraArg) then
			needLabel = extraArg[1]
			needCountryId = extraArg[2]
		else
			needLabel = extraArg
		end
	end

	if needLabel == 0 then
		needLabel = nil
	end

	return self:ensurePetHandbookMap():getAvatarResearchedCount(needBasePetPrototypeId, needLabel, needCountryId)
end

function ClientPetHandbookComponent:getPetHandbookCountByHistoryMaxLevelMin(needBasePetPrototypeId, needLevel)
	return self:ensurePetHandbookMap():getCountByHistoryMaxLevelMin(needBasePetPrototypeId, needLevel)
end

function ClientPetHandbookComponent:getPetHandbookCountByIdAndStateMask(needPetPrototypeId, mask, needCountryId, isRecalculting)
	return self:ensurePetHandbookMap():getCountByIdAndStateMask(needPetPrototypeId, mask, needCountryId, isRecalculting)
end

function ClientPetHandbookComponent:getPetHandbookCountByLevelMin(needPetPrototypeId, levelMin)
	return self:ensurePetHandbookMap():getCountByIdAndLevelMin(needPetPrototypeId, levelMin)
end

function ClientPetHandbookComponent:getPetHandbookHistoryMaxLevel(needBasePetPrototypeId)
	return self:ensurePetHandbookMap():getPetHistoryMaxLevel(needBasePetPrototypeId)
end

function ClientPetHandbookComponent:getPetHandbookTraitUnlockedCount(needBasePetPrototypeId, needTraitId)
	return self:ensurePetHandbookMap():getTraitUnlockedCount(needBasePetPrototypeId, needTraitId)
end

function ClientPetHandbookComponent:getPetHandbookSkillUnlockedCount(needBasePetPrototypeId, needRare)
	return self:ensurePetHandbookMap():getSkillUnlockedCount(needBasePetPrototypeId, needRare)
end

function ClientPetHandbookComponent:getPetHandbookBlockCatchedCount(blockId)
	local blockConfig = MapBlockConfigData[blockId]
	local petList = blockConfig and blockConfig.petList

	if not petList then
		return 0, 0
	end

	local catchedMap = self.blockCatchedPetMap and self.blockCatchedPetMap[blockId]
	local count = 0

	for _, petPrototypeId in ipairs(petList) do
		if catchedMap and catchedMap[petPrototypeId] and catchedMap[petPrototypeId].isCatched then
			count = count + 1
		end
	end

	return count, #petList
end

function ClientPetHandbookComponent:getPetHandbookBlockCatchedRate(blockId)
	local count, total = self:getPetHandbookBlockCatchedCount(blockId)

	return total > 0 and lume.round(count / total, 0.01) or 0
end

function ClientPetHandbookComponent:getPetHandbookExploreMapCoverCount(rate)
	local matchCount = 0

	for blockId, _ in pairs(self.blockCatchedPetMap or EMPTY_TABLE) do
		if rate <= self:getPetHandbookBlockCatchedRate(blockId) then
			matchCount = matchCount + 1
		end
	end

	return matchCount
end

function ClientPetHandbookComponent:getPetHandbookBlockCatchedPetInfo(blockId, petPrototypeId)
	if not self.blockCatchedPetMap then
		return
	end

	local catchedMap = self.blockCatchedPetMap[blockId]

	return catchedMap and catchedMap[petPrototypeId]
end

function ClientPetHandbookComponent:hasResearchPointParams(petPrototypeId, biSource, biParams)
	local info = self:getPetHandbookInfo(petPrototypeId)
	local typeInfo = info and info.researchPointMap and info.researchPointMap[biSource]

	if typeInfo == nil then
		return false
	end

	for _, param in ipairs(typeInfo.biParamsList or EMPTY_TABLE) do
		if table.equal(param, biParams) then
			return true
		end
	end

	return false
end

function ClientPetHandbookComponent:refreshCountryStarInfo()
	self.handbookCountryLevelInfo = {}

	for countryId, info in pairs(PetResearchCountryLevelData) do
		local level, exp = self:getCountryTotalLevel(countryId)
		local maxLevel = table.maxn(info)

		self.handbookCountryLevelInfo[countryId] = {
			level = level,
			exp = exp,
			maxLevel = maxLevel
		}
	end
end

function ClientPetHandbookComponent:onBlockCatchRewardStatus_changed(ov, nv)
	facade:sendMsgToUI(MessageName.PET_AREA_REWARD_CHANGE)
end

function ClientPetHandbookComponent:onBlockCatchedPetMap_changed(ov, nv)
	facade:sendMsgToUI(MessageName.PET_AREA_REWARD_CHANGE)
end

function ClientPetHandbookComponent:onPetHandbookLevelRewardStatus_changed(ov, nv, petTemplateId, level)
	facade:sendMsgToUI(MessageName.PET_RESEARCH_LEVEL_REWARD_STATUS_CHANGE, {
		templateId = petTemplateId,
		level = level,
		newStatus = nv
	})
end

function ClientPetHandbookComponent:onPetHandbookCollectLevelRewardStatus_changed(ov, nv, countryId)
	facade:sendMsgToUI(MessageName.PET_RESEARCH_PROGRESS_REWARD_STATUS_CHANGE, {})
end

function ClientPetHandbookComponent:RPC_SC_OnChangeDisplayPetForm(baseTemplateId, countryId, formTemplateId, label, shinyStyle)
	facade:sendMsgToUI(MessageName.PET_RESEARCH_FORM_DISPLAY_CHANGE, {
		templateId = baseTemplateId,
		countryId = countryId,
		formTemplateId = formTemplateId,
		label = label,
		shinyStyle = shinyStyle
	})
	pg.global.showBubbleMessageById(NoticeDef.PET_FORM_DISPLAY_APPLY)
end

function ClientPetHandbookComponent:onChangeDisplayPetFormResponse(status, response)
	local formByCountryMap = response and response.changes and response.changes.displayPetFormByCountryMap or {}

	for baseTemplateId, countryMap in pairs(formByCountryMap) do
		if Utils.isTable(countryMap) then
			for countryId, displayInfo in pairs(countryMap) do
				if Utils.isTable(displayInfo) then
					facade:sendMsgToUI(MessageName.PET_RESEARCH_FORM_DISPLAY_CHANGE, {
						templateId = tonumber(baseTemplateId) or baseTemplateId,
						countryId = tonumber(countryId) or countryId,
						formTemplateId = displayInfo.petPrototypeId,
						label = displayInfo.label or Const.PET_LABEL_MASK.NORMAL,
						shinyStyle = displayInfo.shinyStyle or 0
					})
					pg.global.showBubbleMessageById(NoticeDef.PET_FORM_DISPLAY_APPLY)
				end
			end
		end
	end
end

function ClientPetHandbookComponent:RPC_SC_ChangeDisplayPetLabel(formTemplateId, countryId, label, shinyStyle)
	facade:sendMsgToUI(MessageName.PET_RESEARCH_FORM_LABEL_DISPLAY_CHANGE, {
		formTemplateId = formTemplateId,
		countryId = countryId,
		label = label,
		shinyStyle = shinyStyle
	})
	pg.global.showBubbleMessageById(NoticeDef.PET_FORM_DISPLAY_APPLY)
end

function ClientPetHandbookComponent:onChangeDisplayPetLabelResponse(status, response)
	local labelByCountryMap = response and response.changes and response.changes.displayFormPetLabelByCountryMap or {}

	for formTemplateId, countryMap in pairs(labelByCountryMap) do
		if Utils.isTable(countryMap) then
			for countryId, displayInfo in pairs(countryMap) do
				if Utils.isTable(displayInfo) then
					facade:sendMsgToUI(MessageName.PET_RESEARCH_FORM_LABEL_DISPLAY_CHANGE, {
						formTemplateId = tonumber(formTemplateId) or formTemplateId,
						countryId = tonumber(countryId) or countryId,
						label = displayInfo.label or Const.PET_LABEL_MASK.NORMAL,
						shinyStyle = displayInfo.shinyStyle or 0
					})
					pg.global.showBubbleMessageById(NoticeDef.PET_FORM_DISPLAY_APPLY)
				end
			end
		end
	end
end

function ClientPetHandbookComponent:onPetHandbookCompletedTarget_entryAdded(index, nv, templateId, sn)
	if not nv then
		return
	end

	self:onPetHandbookCompletedTarget_changed(nil, nv, templateId, sn, index)
end

function ClientPetHandbookComponent:onPetHandbookCompletedTarget_changed(ov, nv, templateId, sn, index)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("onPetHandbookMapCompletedTarget_changed ov:%s, nv:%s templateId:%d sn:%d index:%d", inspect(ov), inspect(nv), templateId, sn, index)
	end

	local petHandbookInfo = pg.me.petHandbookMap[templateId] or {}
	local topicData = PetResearchTargetData[templateId][sn]
	local conditions = topicData.condition

	facade:sendMsgToUI(MessageName.PET_ACHIEVE_CHANGE, {
		templateId = templateId,
		sn = sn,
		title = PetResearchResultData.dataStatistic.title,
		index = index,
		nv = nv,
		tab = PetResearchUtils.TAB_IDX.TOPIC,
		level = petHandbookInfo.level or 0,
		exp = petHandbookInfo.exp or 0,
		researchPoint = PetResearchUtils.getRewardResearchPoint(conditions[index][3])
	})
end

function ClientPetHandbookComponent:RPC_SC_HandBookDataChanged(clientChanges)
	self:applyHandBookChanges(clientChanges)
end

function ClientPetHandbookComponent:RPC_SC_ClearPetHandbookData()
	self:applyHandBookData({
		petHandbookDisplayMode = 0,
		petHandbookSortMode = 0,
		petHandbookMap = {},
		displayPetFormMap = {},
		displayPetLabelMap = {},
		displayFormPetLabelMap = {},
		displayPetFormByCountryMap = {},
		displayFormPetLabelByCountryMap = {},
		blockCatchRewardStatus = {},
		blockCatchedPetMap = {}
	})
	facade:sendMsgToUI(MessageName.PET_AREA_REWARD_CHANGE)
end

function ClientPetHandbookComponent:onPetHandbookExp_changed(ov, nv, templateId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("onPetHandbookExp_changed ov:%s, nv:%s templateId:%d", inspect(ov), inspect(nv), templateId)
	end
end

function ClientPetHandbookComponent:onPetHandbookStateMask_changed(ov, nv, protoTypeId)
	local petHandbookInfo = self.petHandbookMap[protoTypeId]
	local preNewKnow = not petHandbookInfo:hasStateMask(Const.PET_HBMSK_CATCHED, ov) and not petHandbookInfo:hasStateMask(Const.PET_HBMSK_KNOWN, ov)
	local curNewKnow = not petHandbookInfo:hasStateMask(Const.PET_HBMSK_CATCHED, nv) and not petHandbookInfo:hasStateMask(Const.PET_HBMSK_KNOWN, nv)

	if preNewKnow ~= curNewKnow then
		facade:sendMsgToUI(MessageName.ON_NEW_KNOW_CHANGED, {
			templateId = protoTypeId
		})
	end

	local diffMask = bit.bxor(ov, nv)

	for _, singleMask in pairs(lume.parseMaskToList(diffMask)) do
		if singleMask == Const.PET_HBMSK_KNOWN and bit.band(nv or 0, Const.PET_HBMSK_KNOWN) == Const.PET_HBMSK_KNOWN then
			self:onPetHandbookKnown(protoTypeId)
		elseif singleMask == Const.PET_HBMSK_CATCHED and bit.band(nv or 0, Const.PET_HBMSK_CATCHED) == Const.PET_HBMSK_CATCHED then
			self:onPetHandbookCatched(protoTypeId)
		end
	end
end

function ClientPetHandbookComponent:onPetHandbookKnown(protoTypeId)
	self.logger:debug("onPetHandbookKnown protoTypeId:%d", protoTypeId)
end

function ClientPetHandbookComponent:onPetHandbookCatched(protoTypeId)
	self.logger:debug("onPetHandbookCatched protoTypeId:%d", protoTypeId)

	local baseId = Utils.getBasePetPrototypeId(protoTypeId)

	if baseId ~= protoTypeId then
		local petName = PetProtoTypeData[baseId].name
		local soulEggEvolution = pg.game.soulEggEvolution
		local tipsInfo = {
			delay = 0.5,
			duration = 5,
			desc = pg.getFormatText(pg.getGameString("FORM_COLLECT_UP"), pg.getLocalizationText(petName))
		}

		if soulEggEvolution and soulEggEvolution:shouldRecordTipsUntilEvolutionClose() then
			soulEggEvolution:recordTips(tipsInfo)
		else
			pg.global.ui.tips:showTextTipByArgs(tipsInfo)
		end
	end
end

function ClientPetHandbookComponent:RPC_SC_PetUnlockTraitResearch(templateId, traitId)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("RPC_SC_PetUnlockTraitResearch templateId:%d traitId:%d", templateId, traitId)
	end

	self:unlockTraitResearch(templateId, traitId)
end

function ClientPetHandbookComponent:unlockTraitResearch(templateId, traitId)
	local traitData = PetTraitData[templateId] and PetTraitData[templateId][traitId] or {}
	local researchResultData = PetResearchResultData.traits or {}

	if not Utils.isEmptyTable(traitData) and (traitData.banFeedBack == nil or traitData.banFeedBack ~= 1) and traitData.traitsName and traitData.traitsDesc then
		local info = {
			templateId = templateId,
			title = traitData.traitsName or "",
			researchPageIdx = researchResultData.researchPageIdx or 0,
			researchPoint = traitData.reward or 0,
			desc = traitData.traitsDesc or "",
			tab = PetResearchUtils.TAB_IDX.SURVEY
		}

		facade:sendMsgToUI(MessageName.PET_RESEARCH_CHANGE, info)
		facade:sendMsgToUI(MessageName.PHOTO_TRAIT_RESEARCH, {
			templateId = templateId,
			traitId = traitId,
			traitInfo = info
		})
	elseif LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug(string.format("PetTraitData>>templateId:%s, traitId:%s", templateId, traitId))
	end
end

function ClientPetHandbookComponent:RPC_SC_PetUnlockEvolveResearch(templateId, evolveId)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("RPC_SC_PetUnlockEvolveResearch templateId:%d evolveId:%d", templateId, evolveId)
	end
end

function ClientPetHandbookComponent:unlockEvolveResearch(templateId, evolveId)
	local evolveData = PetEvolveData[templateId] and PetEvolveData[templateId][evolveId] or {}
	local petData = PetData[evolveData.targetPetId] or {}

	if evolveData and not Utils.isEmptyTable(evolveData) then
		local info = {
			templateId = templateId,
			researchPoint = evolveData.reward or 0,
			iconId = LuaUIUtils.getPetIcon(petData.iconName, LuaUIUtils.PET_ICON) or "",
			desc = evolveData.simpleDesc or "",
			targetName = petData.name,
			title = pg.getFormatText(pg.getGameString("UNLOCK_EVOLVE"), pg.getLocalizationText(petData.name)),
			evolveId = evolveId,
			subPageIdx = PetResearchUtils.TAB_IDX.EVOLUTION
		}

		facade:sendMsgToUI(MessageName.PET_RESEARCH_CHANGE, info)
	elseif LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug(string.format("PetEvolveData>>templateId:%s, evolveId:%s", templateId, evolveId))
	end
end

function ClientPetHandbookComponent:RPC_SC_PetUnlockSingleResearch(petTemplateId, researchKey, subIndex)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("RPC_SC_PetUnlockSingleResearch", petTemplateId, researchKey, subIndex)
	end
end

function ClientPetHandbookComponent:RPC_SC_OnPetHandbookAddResearchExp(petTemplateId, level, exp, level_before, exp_before)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("RPC_SC_OnPetHandbookAddResearchExp", petTemplateId, level, exp, level_before, exp_before)
	end

	local countryId = PetResearchData[petTemplateId].countryId or 300001
	local curLevel, curExp = self:getCountryTotalLevel(countryId)
	local preCountryInfo = self.handbookCountryLevelInfo[countryId] or {}
	local maxLevel = preCountryInfo.maxLevel or 0

	self.handbookCountryLevelInfo[countryId] = {
		level = curLevel,
		exp = curExp,
		maxLevel = maxLevel
	}
end

function ClientPetHandbookComponent:onPetCountryMap_changed(ov, nv, countryId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("onPetCountryMap_changed ov:%s, nv:%s ", ov, nv, countryId)
	end

	facade:sendMsgToUI(MessageName.PET_RESEARCH_COUNTRY_REWARD_STATUS_CHANGE, {
		countryId = countryId
	})
end

function ClientPetHandbookComponent:RPC_SC_UnlockBattleResearchEvent(petTemplateId, abilityParamId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("RPC_SC_UnlockBattleResearchEvent petTemplateId:%s, abilityParamId:%s ", petTemplateId, abilityParamId)
	end

	facade:sendMsgToUI(MessageName.PET_RESEARCH_SKILL_UNLOCK_BY_ITEM, {
		sunPageIdx = 1,
		templateId = petTemplateId,
		abilityParamId = abilityParamId
	})
end

function ClientPetHandbookComponent:getPetAreaReward(smallAreaId, index)
	self:serverMsg("RPC_CS_GetBlockCatchReward", smallAreaId, index)
end

function ClientPetHandbookComponent:getPetResearchLevelReward(petTemplateId, level)
	self:serverMsg("RPC_CS_GetPetResearchLevelReward", petTemplateId, level)
end

function ClientPetHandbookComponent:getAllPetResearchLevelReward()
	self:serverMsg("RPC_CS_GetAllPetResearchLevelReward")
end

function ClientPetHandbookComponent:getPetHandbookCountryLevelReward(countryId, star)
	self:serverMsg("RPC_CS_GetPetHandbookCountryLevelReward", countryId, star)
end

function ClientPetHandbookComponent:getPetHandbookCountryCollectReward(countryId, star)
	self:serverMsg("RPC_CS_GetPetHandbookCountryCollectReward", countryId, star)
end

function ClientPetHandbookComponent:getPetHandbookSpeciesCollectReward(countryId, star)
	self:serverMsg("RPC_CS_GetPetHandbookSpeciesCollectReward", countryId, star)
end

function ClientPetHandbookComponent:reportPetResearch(countryId)
	self:serverMsg("RPC_CS_PetResearchReport", countryId)
end

function ClientPetHandbookComponent:changeDisplayPetForm(baseTemplateId, countryId, formTemplateId, label, shinyStyle)
	shinyStyle = label == Const.PET_LABEL_MASK.SHINY and (shinyStyle or 0) or 0

	self:serverMsg("RPC_CS_ChangeDisplayPetForm", baseTemplateId, countryId, formTemplateId, label, shinyStyle)
end

function ClientPetHandbookComponent:changeDisplayPetLabel(formTemplateId, countryId, label, shinyStyle)
	shinyStyle = label == Const.PET_LABEL_MASK.SHINY and (shinyStyle or 0) or 0

	self:serverMsg("RPC_CS_ChangeDisplayPetLabel", formTemplateId, countryId, label, shinyStyle)
end

function ClientPetHandbookComponent:onAreaActiveChanged(ov, nv)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("onAreaActiveChanged old value:%s, new value:%s ", ov, nv)
	end

	facade:sendMsgToUI(MessageName.PET_RESEARCH_AREA_ACTIVE_CHANGED)
end

function ClientPetHandbookComponent:onRewardTargetMapChanged(ov, nv, templateId, sn, index)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("onRewardTargetMapChanged old value:%s, new value:%s ", ov, nv)
	end
end

function ClientPetHandbookComponent:reqGetPetTopicRewards(data)
	self:serverMsg("RPC_CS_PetResearchTargetsReward", data, CallbackHandler(self, "onTopicRewardGet"))

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("reqGetPetTopicRewards")
	end
end

function ClientPetHandbookComponent:onTopicRewardGet()
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("onTopicRewardGet")
	end

	facade:sendMsgToUI(MessageName.PET_TOPIC_REWARD_CHANGED)
end

return ClientPetHandbookComponent
