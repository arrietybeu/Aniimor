-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\HomeCampUtils.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("HomeCampUtils")
local Const = require("Common.Const.Const")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")
local ClientTextUtils = require("Utils.ClientTextUtils")
local UIConst = require("Const.UIConst")
local PetLevelData = require("Data.pet_level_data")
local PetData = require("Data.pet_data")
local PetConfigData = require("Data.pet_config_data")
local PetDetailPropertyData = require("Data.pet_detail_property_data")
local PetPropLevelMaxData = require("Data.pet_prop_level_max")
local Utils = require("Common.Utils.Utils")
local AbilityConst = require("Common.Const.AbilityConst")
local TimerManager = require("Core.Timer.TimerManager")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local PetResearchContentData = require("Data.pet_research_content_data")
local Time = require("Core.Common.Time")
local PetResearchUtils = require("Guis.Utils.PetResearchUtils")
local MessageName = require("Const.MessageName")
local PetAvatarData = require("Data.pet_avatar_data")
local SkillTagData = require("Data.skill_tag_data")
local AddressDataConst = require("Const.AddressDataConst")
local Lume = require("Core.Common.lume")
local ClientConst = require("Const.ClientConst")
local PetAttrConvertData = require("Data.pet_attr_convert_data")
local AttributeConst = require("Common.Const.AttributeConst")
local CoreCarryData = require("Data.core_carry_data")
local AttributeGroupData = require("Data.attribute_group_data")
local PriProConst = require("Common.Const.PrimaryPropertyConst")
local PetDisplayAttrNames = require("Data.pet_display_attr_names")
local ResonanceData = require("Data.pet_resonance_data")
local FormulaData = require("Data.formula_data")
local NoticeDef = require("Common.NoticeDef")
local PetFamilyData = require("Data.pet_family_data")
local ItemUtils = require("Common.Utils.ItemUtils")
local PetDispatchData = require("Data.pet_dispatch_data")
local TimeUtils = require("Common.Utils.TimeUtils")
local HomeCampData = require("Data.home_camp_data")
local HomeCampUtils = {}
local string_format = string.format
local math_floor = math.floor
local CACHE_CAMP_CAR_DISPATCH_REWARD_ITEM_IDS = "CampCarDispatchRewardItemIds"

function HomeCampUtils.getCampPetDispatchSortTypes()
	if not PetDispatchData then
		return {}
	end

	local ret = {}

	for k, v in pairs(PetDispatchData) do
		ret[k] = {
			id = k,
			sort = v.sortId
		}
	end

	if not ret then
		return {}
	end

	table.sort(ret, function(a, b)
		return a.sort < b.sort
	end)

	local sortTypes = {}

	for _, v in pairs(ret) do
		if v and PetDispatchData[v.id] then
			local defCfg = PetDispatchData[v.id]

			sortTypes[#sortTypes + 1] = {
				id = v.id or -1,
				finishTimeSecond = defCfg.time or 0,
				nameKey = defCfg.name,
				iconUrl = defCfg.iconId or ""
			}
		end
	end

	return sortTypes
end

function HomeCampUtils.getCampPetsDispatchCfg(dispatchType)
	if not dispatchType then
		return nil
	end

	return PetDispatchData[dispatchType]
end

function HomeCampUtils.getCampDisplayExtraRewardList(campId)
	return (HomeCampData[campId] or EMPTY_TABLE).extraRewardItemList or {}
end

function HomeCampUtils.getCampPetsList(campCarEnt)
	if not campCarEnt then
		return {}
	end

	local petIds = campCarEnt:getCampCopyPetIds() or {}

	if not petIds or #petIds == 0 then
		return {}
	end

	local petsLen = #petIds
	local campPets = {}

	for idx = 1, petsLen do
		local petId = petIds[idx]
		local campPetInfo = campCarEnt:getCampPetInfo(petId)
		local petInfo = PetManagementDataHelper.setUpPetInfo(campPetInfo)

		petInfo.slotIdx = idx
		petInfo.tIndex = 0

		local dispatchState = campCarEnt:getCampPetDispatchState()

		petInfo.dispatchState = dispatchState

		HomeCampUtils.m_setCampPetsFacilityInfo(petInfo)

		campPets[idx] = petInfo
	end

	return campPets
end

function HomeCampUtils.getUICacheCampPetsList(cachePetIds, campCarEnt)
	cachePetIds = cachePetIds or {}

	if not next(cachePetIds) then
		return {}
	end

	local petsLen = #cachePetIds
	local campPets = {}

	for idx = 1, petsLen do
		local petId = cachePetIds[idx]
		local campPetInfo = pg.me and pg.me.pets[petId] or {}
		local petInfo = PetManagementDataHelper.setUpPetInfo(campPetInfo)

		petInfo.slotIdx = idx
		petInfo.tIndex = 0

		local dispatchState = campCarEnt and campCarEnt:getCampPetDispatchState() or UIConst.HOME_CAMP_DISPATCH_STATE.UnDispatch

		petInfo.dispatchState = dispatchState

		HomeCampUtils.m_setCampPetsFacilityInfo(petInfo)

		campPets[idx] = petInfo
	end

	return campPets
end

function HomeCampUtils.m_setCampPetsFacilityInfo(petInfo)
	local allocation = pg.space.allocation
	local facility = pg.space.facility
	local ornament = pg.space.ornament
	local petId = petInfo and petInfo.id

	if petId then
		local allocationInfo = allocation and allocation[petId]

		if allocationInfo then
			local ornamentId = allocationInfo.ornamentId
			local facilityInfo = facility and facility[ornamentId]

			if facilityInfo and facilityInfo.facilityState == allocationInfo.opId then
				local ornamentInfo = ornament and ornament[ornamentId]
				local homeTemplateID = ornamentInfo.homeId
				local facilityType = Utils.getHomeFacilityType(homeTemplateID)

				petInfo.isWorking = true
				petInfo.facilityType = facilityType
				petInfo.opId = allocationInfo.opId
				petInfo.workload = allocationInfo.workload
				petInfo.facilityInfo = facilityInfo
				petInfo.fitPersonality = allocationInfo.fitTalent
			end
		end
	end
end

function HomeCampUtils.getCampPetsOffLineInfo(petIds)
	if not petIds or not next(petIds) then
		return {}
	end

	local retPetsInfo = {}

	for idx = 1, #petIds do
		local petId = petIds[idx]
		local pet = pg.me and pg.me.pets[petId]

		if pet then
			local petInfo = PetManagementDataHelper.setUpPetInfo(pet)

			HomeCampUtils.m_setCampPetsFacilityInfo(petInfo)

			retPetsInfo[#retPetsInfo + 1] = petInfo
		end
	end

	return retPetsInfo
end

function HomeCampUtils.getPlayerCarPetsDispatchState(carEnt)
	return carEnt and carEnt:getCampPetDispatchState() or UIConst.HOME_CAMP_DISPATCH_STATE.UnDispatch
end

function HomeCampUtils.setCampPreSelectedDispatchedId(id)
	HomeCampUtils.m_preSelectedDispatchedId = id
end

function HomeCampUtils.getCampPreSelectedDispatchedId()
	return HomeCampUtils.m_preSelectedDispatchedId or 1
end

function HomeCampUtils.getClientCachedRewardItemIds(itemId)
	local recordPath = string_format("%s_%d", CACHE_CAMP_CAR_DISPATCH_REWARD_ITEM_IDS, itemId)
	local oldNum = pg.global.prefsCacheUtils:getInt(recordPath, 0, ClientConst.CACHE_TYPE_FLAG.USER)

	return oldNum
end

function HomeCampUtils.setClientCachedRewardItemIds(itemId, num)
	local recordPath = string_format("%s_%d", CACHE_CAMP_CAR_DISPATCH_REWARD_ITEM_IDS, itemId)

	pg.global.prefsCacheUtils:setInt(recordPath, num, ClientConst.CACHE_TYPE_FLAG.USER)
end

function HomeCampUtils.setPreDispatchRewardItems(itemCountTable, idNumsListDict)
	HomeCampUtils.m_preDispatchRewardItems = itemCountTable or {}
	HomeCampUtils.m_preDispatchRewardIdNumsListDict = idNumsListDict or {}

	for itemId, num in pairs(itemCountTable or EMPTY_TABLE) do
		HomeCampUtils.setClientCachedRewardItemIds(itemId, num or 1)
	end
end

function HomeCampUtils.getPreDispatchRewardItems()
	return HomeCampUtils.m_preDispatchRewardItems or {}
end

function HomeCampUtils.getPreDispatchRewardIdNumsListDict()
	return HomeCampUtils.m_preDispatchRewardIdNumsListDict or {}
end

function HomeCampUtils.setPreDispatchId(dispatchId)
	HomeCampUtils.m_preDispatchId = dispatchId
end

function HomeCampUtils.getPreDispatchId()
	return HomeCampUtils.m_preDispatchId or 1
end

function HomeCampUtils.setPreDispatchCampId(campId)
	HomeCampUtils.m_preDispatchCampId = campId
end

function HomeCampUtils.getPreDispatchCampId()
	return HomeCampUtils.m_preDispatchCampId or pg.me and pg.me.curCampStaticId or 0
end

function HomeCampUtils.tryOpenFinishDispatchDialog()
	local uid = pg.me and pg.me.uid
	local entId = string.format("campCar-%s", uid)
	local campCarEnt = entId and pg.getEntity(entId)
	local petIds = campCarEnt and campCarEnt:getCampPetIds() or {}
	local dispatchId = HomeCampUtils.getPreDispatchId()
	local campId = HomeCampUtils.getPreDispatchCampId()
	local reward, multiplies = HomeCampUtils.getCarDispatchReward(campCarEnt, dispatchId, campId)
	local params = {
		petIds = petIds,
		dispatchId = dispatchId,
		reward = reward,
		multiplies = multiplies
	}

	pg.global.ui:open(UIConst.HOME_CAR_CAM_DISPATCH_REWARDS, params)
end

function HomeCampUtils.getCarDispatchCampId(carEnt, specCampId)
	local staticId = specCampId

	if not staticId or staticId == 0 then
		staticId = carEnt.dispatchInfo and carEnt.dispatchInfo.campId
	end

	if not staticId or staticId == 0 then
		staticId = carEnt.space and carEnt.space.staticId
	end

	return staticId
end

function HomeCampUtils.getCarDispatchReward(carEnt, specDispId, specCampId)
	local staticId = HomeCampUtils.getCarDispatchCampId(carEnt, specCampId)
	local dispId = specDispId or carEnt.dispatchInfo and carEnt.dispatchInfo.dispId
	local hcdd = HomeCampData[staticId]
	local reward = hcdd and hcdd.rewards and hcdd.rewards[dispId]
	local multiples = #carEnt.petIds

	return reward, multiples
end

function HomeCampUtils.getCarDispatchPreviewRewardItemIds(carEnt, specCampId)
	local staticId = HomeCampUtils.getCarDispatchCampId(carEnt, specCampId)
	local hcdd = HomeCampData[staticId]

	return hcdd and hcdd.rewardItemList or {}
end

function HomeCampUtils.getCarDispatchBelongTypeRewardInfo(carEnt, dispatchId, specCampId)
	local staticId = HomeCampUtils.getCarDispatchCampId(carEnt, specCampId)
	local hcdd = HomeCampData[staticId]
	local dropId = hcdd and hcdd.rewards and hcdd.rewards[dispatchId] or 0
	local itemDescKey = hcdd["rewardDes" .. dispatchId] or ""

	return {
		dropId = dropId,
		itemDescKey = itemDescKey
	}
end

function HomeCampUtils.setCacheHomeCampPetIds(petIds)
	HomeCampUtils.m_cacheHomeCampPetIds = petIds or {}
end

function HomeCampUtils.isInCacheHomeCampPetIds(petId)
	local cacheHomeCampPetIds = HomeCampUtils.m_cacheHomeCampPetIds

	for _, id in ipairs(cacheHomeCampPetIds) do
		if id == petId then
			return true
		end
	end

	return false
end

function HomeCampUtils.isInCacheRemoveHomeCampPetIds(petId, campCarEnt)
	if not petId then
		return false
	end

	if not campCarEnt then
		return false
	end

	local realCampPetIds = campCarEnt:getCampCopyPetIds() or {}

	if not realCampPetIds or #realCampPetIds == 0 then
		return false
	end

	local realCampPetIds2Index = {}

	for idx = 1, #realCampPetIds do
		local id = realCampPetIds[idx]

		realCampPetIds2Index[id] = idx
	end

	local cacheHomeCampPetIds = HomeCampUtils.m_cacheHomeCampPetIds
	local cacheHomeCampPetIds2Index = {}

	for idx = 1, #cacheHomeCampPetIds do
		local id = cacheHomeCampPetIds[idx]

		cacheHomeCampPetIds2Index[id] = idx
	end

	if realCampPetIds2Index[petId] and not cacheHomeCampPetIds2Index[petId] then
		return true
	end

	return false
end

function HomeCampUtils.getIsGainedTheDispatchItem(itemId)
	local function finalCheck(itemId)
		return HomeCampUtils.getClientCachedRewardItemIds(itemId) > 0
	end

	return ItemUtils.getIsGainedTheItem(itemId, finalCheck)
end

function HomeCampUtils.trySetUnknownDispatchItem(rewardTable, isHomeCampMark)
	if not rewardTable or #rewardTable == 0 then
		return
	end

	if not isHomeCampMark then
		return
	end

	for _, item in ipairs(rewardTable) do
		local itemId = item.id

		if itemId and not HomeCampUtils.getIsGainedTheDispatchItem(itemId) then
			item.isUnknow = true
			item.iconUrl = AddressDataConst.HOME_CAR_CAMP_ITEM_UNKNOWN_URL
		end
	end
end

return HomeCampUtils
