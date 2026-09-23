-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Utils\\HomeLandUtils.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local lume = require("Core.Common.lume")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local SceneUtils = require("Common.Utils.SceneUtils")
local HomelandConfigData = require("Data.homeland_config_data")
local HomeWishingStarCollectionData = require("Data.home_wishing_star_collection_data")
local HomeObjectData = require("Data.home_object_data")
local HomeBuildData = require("Data.home_build_data")
local HomeBuildLinkData = require("Data.home_build_link_data")
local Time = require("Core.Common.Time")
local PetHatchEggData = require("Data.pet_hatch_egg_data")
local NoticeDef = require("Common.NoticeDef")
local PetBallConfigData = require("Data.pet_ball_config_data")
local ItemData = require("Data.item_data")
local HomeCampData = require("Data.home_camp_data")
local HomeCampCarData = require("Data.home_camp_car_data")
local HomeCarUpgradeData = require("Data.home_car_upgrade_data")
local HomeCarModifyModelData = require("Data.home_car_modify_model_data")
local HomeCarComponentUpgradeData = require("Data.home_car_component_upgrade_data")
local HomeCarComponentData = require("Data.home_car_component_data")
local HomeCarInternalModelData = require("Data.home_car_internal_model_data")
local HomeSceneToCampIdData = require("Data.home_scene_to_camp_id_data")
local TimerManager = require("Core.Timer.TimerManager")
local HomelandFacilityData = require("Data.homeland_facility_data")
local HomelandFormulaData = require("Data.homeland_formula_data")
local HomelandOperateData = require("Data.homeland_operate_data")
local HomelandFormulaPeriodData = require("Data.homeland_formula_period_data")
local HomelandFormulaRandomData = require("Data.homeland_formula_random_data")
local HomelandFormulaReverseData = require("Data.homeland_formula_random_reverse_data")
local HomeFacilityData = require("Data.homeland_facility_data")
local OrderLibData = require("Data.order_library_data")
local OrderRefreshData = require("Data.order_refresh_data")
local HomeOrderConst = require("Common.Const.HomeOrderConst")
local CommonSwitch = require("Common.CommonSwitch")
local HomelandZoneUnlockConfigData = require("Data.homeland_zone_unlock_config_data")
local NewHomelandZoneUnlockConfigData = require("Data.new_homeland_zone_unlock_config_data")
local HomelandAreaData = require("Data.homeland_area_data")
local HomeSeasonData = require("Data.home_season_data")
local HomeTrashData = require("Data.home_trash_data")
local NewHomeTrashData = require("Data.new_home_trash_data")
local HomeLeisureBehaviorData = require("Data.home_leisure_behavior_data")
local HomeHandbookCategoryDetailData = require("Data.home_handbook_category_detail")
local HomeHandbookSeasonData = require("Data.home_handbook_season_data")
local PetData = require("Data.pet_data")
local HomeLandUtils = {}

HomeLandUtils._loggedInvalidHomeVoucherRuleKeys = {}

local HATCHBOX_EFFECT_POSITION = Vector3.NewReadOnly(0, 1.33, 0.65)
local HOME_VOUCHER_PROGRESS_EPSILON = 1e-06
local math_ceil = math.ceil
local math_floor = math.floor
local math_max = math.max
local math_min = math.min

HomeLandUtils.ORNAMENT_SCALE_INT_BASE = 1000
HomeLandUtils.ORNAMENT_POSITION_INT_BASE = 100
HomeLandUtils.ORNAMENT_ROTATION_INT_BASE = 100
HomeLandUtils.ORNAMENT_POSITION_FIELDS = {
	"posX",
	"posY",
	"posZ"
}
HomeLandUtils.ORNAMENT_ROTATION_FIELDS = {
	"rotX",
	"rotY",
	"rotZ"
}
HomeLandUtils.ORNAMENT_SCALE_FIELDS = {
	"scaleX",
	"scaleY",
	"scaleZ"
}
HomeLandUtils.ORNAMENT_TRANSFORM_FIELDS = {
	"posX",
	"posY",
	"posZ",
	"rotX",
	"rotY",
	"rotZ",
	"scaleX",
	"scaleY",
	"scaleZ"
}
HomeLandUtils.HOME_VOUCHER_SECONDS_PER_DAY = 86400
HomeLandUtils.HOME_VOUCHER_APPEARANCE_TYPE = {
	FORM_QUALITY = 1,
	SHINY = 2
}
HomeLandUtils.tempAllocateInfo = {}

function HomeLandUtils.buildOrnamentPositionFields(position)
	if not position then
		return nil, nil, nil
	end

	local positionBase = HomeLandUtils.ORNAMENT_POSITION_INT_BASE

	return math.round((position[1] or 0) * positionBase), math.round((position[2] or 0) * positionBase), math.round((position[3] or 0) * positionBase)
end

function HomeLandUtils.buildOrnamentRotationFields(rotation)
	if not rotation then
		return nil, nil, nil
	end

	local eulerAngles = rotation.eulerAngles
	local rotationBase = HomeLandUtils.ORNAMENT_ROTATION_INT_BASE

	return math.floor(Utils.normalizeAngle(eulerAngles[1] or 0) * rotationBase), math.floor(Utils.normalizeAngle(eulerAngles[2] or 0) * rotationBase), math.floor(Utils.normalizeAngle(eulerAngles[3] or 0) * rotationBase)
end

function HomeLandUtils.buildOrnamentScaleFields(scale)
	if not scale then
		return nil, nil, nil
	end

	local scaleBase = HomeLandUtils.ORNAMENT_SCALE_INT_BASE

	return math.floor((scale[1] or 1) * scaleBase), math.floor((scale[2] or 1) * scaleBase), math.floor((scale[3] or 1) * scaleBase)
end

function HomeLandUtils.ornamentFieldsToPosition(ornamentInfo)
	local positionBase = HomeLandUtils.ORNAMENT_POSITION_INT_BASE

	return Vector3((ornamentInfo.posX or 0) / positionBase, (ornamentInfo.posY or 0) / positionBase, (ornamentInfo.posZ or 0) / positionBase)
end

function HomeLandUtils.buildOrnamentUpdateData(ornamentInfo)
	local upData = {}

	for _, name in ipairs(HomeLandUtils.ORNAMENT_TRANSFORM_FIELDS) do
		upData[name] = ornamentInfo[name]
	end

	return upData
end

function HomeLandUtils.fillOrnamentTransform(ornamentInfo, position, rotation, scale)
	if position then
		ornamentInfo.posX, ornamentInfo.posY, ornamentInfo.posZ = HomeLandUtils.buildOrnamentPositionFields(position)
	end

	if rotation then
		ornamentInfo.rotX, ornamentInfo.rotY, ornamentInfo.rotZ = HomeLandUtils.buildOrnamentRotationFields(rotation)
	end

	if scale then
		ornamentInfo.scaleX, ornamentInfo.scaleY, ornamentInfo.scaleZ = HomeLandUtils.buildOrnamentScaleFields(scale)
	end

	return ornamentInfo
end

function HomeLandUtils.normalizeOrnamentTransform(ornamentInfo, fallbackInfo)
	if not ornamentInfo then
		return
	end

	local rotationMod = 360 * HomeLandUtils.ORNAMENT_ROTATION_INT_BASE
	local scaleBase = HomeLandUtils.ORNAMENT_SCALE_INT_BASE

	for _, name in ipairs(HomeLandUtils.ORNAMENT_ROTATION_FIELDS) do
		local value = tonumber(ornamentInfo[name])

		if value == nil and fallbackInfo then
			value = tonumber(fallbackInfo[name])
		end

		ornamentInfo[name] = math.floor(value or 0) % rotationMod
	end

	for _, name in ipairs(HomeLandUtils.ORNAMENT_SCALE_FIELDS) do
		local value = tonumber(ornamentInfo[name])

		if (value == nil or value == 0) and fallbackInfo then
			value = tonumber(fallbackInfo[name])
		end

		if value == nil or value == 0 then
			value = scaleBase
		end

		ornamentInfo[name] = math.floor(value)
	end

	for _, name in ipairs(HomeLandUtils.ORNAMENT_POSITION_FIELDS) do
		local value = tonumber(ornamentInfo[name])

		if value == nil and fallbackInfo then
			value = tonumber(fallbackInfo[name])
		end

		ornamentInfo[name] = math.round(value or 0)
	end
end

function HomeLandUtils.checkHasOutput(facilityInfo)
	if not facilityInfo then
		return false
	end

	for _, itemNum in pairs(facilityInfo.outputMap) do
		if itemNum > 0 then
			return true
		end
	end

	return false
end

function HomeLandUtils.getFacilityTillOpId(space, ornamentId, ornamentInfo)
	if not ornamentInfo then
		if not space or not ornamentId or not space.ornament then
			return nil
		end

		ornamentInfo = space.ornament[ornamentId]
	end

	if not ornamentInfo then
		return nil
	end

	local homeObjData = HomeObjectData[ornamentInfo.homeId]
	local facilityData = homeObjData and HomelandFacilityData[homeObjData.facilityId]

	return facilityData and facilityData.tillState
end

function HomeLandUtils.isTillOperation(space, ornamentId, opId)
	return opId ~= nil and HomeLandUtils.getFacilityTillOpId(space, ornamentId) == opId
end

function HomeLandUtils.canTill(space, ornamentId, workUid)
	local facilityInfo = space.facility[ornamentId]

	if not facilityInfo or not workUid then
		return NoticeDef.HOME_CHECK_FAILED
	end

	if facilityInfo.formulaId == 0 then
		return NoticeDef.HOME_CHECK_FAILED
	end

	if facilityInfo.tilled then
		return NoticeDef.HOME_CHECK_FAILED
	end

	if facilityInfo.facilityStateInfo.ptype ~= Const.HOMELAND_PRODUCE_TYPE.TIME then
		return NoticeDef.HOME_CHECK_FAILED
	end

	if workUid == space.ownerUid then
		return NoticeDef.HOME_CHECK_FAILED
	end

	return NoticeDef.SUCCESS
end

function HomeLandUtils.hasLoosenableFacility(space, workUid)
	if not space or not space.facility then
		return false
	end

	for ornamentId, facilityInfo in pairs(space.facility) do
		if HomeLandUtils.isFacilityLoosenable(space, ornamentId, facilityInfo, workUid) then
			return true
		end
	end

	return false
end

function HomeLandUtils.isFacilityLoosenable(space, ornamentId, facilityInfo, workUid)
	if not space or not ornamentId or not facilityInfo or not workUid then
		return false
	end

	if not HomeLandUtils.getFacilityTillOpId(space, ornamentId) then
		return false
	end

	if HomeLandUtils.canTill(space, ornamentId, workUid) ~= NoticeDef.SUCCESS then
		return false
	end

	return not HomeLandUtils.isFacilityLoosening(space, ornamentId)
end

function HomeLandUtils.isFacilityLoosening(space, ornamentId)
	if not space or not ornamentId or not space.playerAllocation then
		return false
	end

	local tillOpId = HomeLandUtils.getFacilityTillOpId(space, ornamentId)

	if not tillOpId then
		return false
	end

	for _, allocationInfo in pairs(space.playerAllocation) do
		if allocationInfo.ornamentId == ornamentId and allocationInfo.opId == tillOpId then
			return true
		end
	end

	return false
end

function HomeLandUtils.isProduceAreaOrnament(ornamentInfo)
	return ornamentInfo and (ornamentInfo.areaId or Const.HOMELAND_AREA_TYPE.PRODUCE) == Const.HOMELAND_AREA_TYPE.PRODUCE
end

function HomeLandUtils.getHomePetAreaId(space, petId, petEnt)
	if not space or not petId then
		return nil
	end

	if petEnt and petEnt.space ~= space then
		petEnt = nil
	end

	local placeInfo = space.petsPlaceData and space.petsPlaceData[petId]
	local placeAreaId = placeInfo and placeInfo.areaId
	local entityAreaId = petEnt and petEnt.areaId

	if entityAreaId ~= nil and placeAreaId ~= nil and entityAreaId ~= placeAreaId then
		return nil
	end

	return placeAreaId ~= nil and placeAreaId or entityAreaId
end

function HomeLandUtils.isHomePetInProduceArea(space, petId)
	if not space or not space.petsPlaceData or not petId then
		return false
	end

	local placeInfo = space.petsPlaceData[petId]

	return placeInfo and placeInfo.areaId == Const.HOMELAND_AREA_TYPE.PRODUCE or false
end

function HomeLandUtils.getHomeAbilityRequirement(space)
	local requirement = {}
	local facilityCountByTypeId = {}
	local facilityAbilitySet = {}
	local operateIds = {}
	local transportFacilityCount = 0
	local facilityRatioByTypeId = HomelandConfigData.homeFacilityAbilityRequirementRatio or {}
	local ornaments = space and space.ornament or {}
	local facilities = space and space.facility or {}

	for ornamentId, ornamentInfo in pairs(ornaments) do
		if HomeLandUtils.isProduceAreaOrnament(ornamentInfo) then
			local facilityId = Utils.getHomeObjectFacilityId(ornamentInfo.homeId)
			local facilityData = facilityId and HomelandFacilityData[facilityId]

			if facilityData then
				table.clear(facilityAbilitySet)
				table.clear(operateIds)

				local facilityInfo = facilities[ornamentId]
				local formulaId = facilityInfo and facilityInfo.formulaId
				local formulaData = formulaId and formulaId ~= 0 and HomelandFormulaData[formulaId]

				if formulaData then
					local preOperateList = formulaData.preOperateList

					if preOperateList then
						for _, operateId in ipairs(preOperateList) do
							operateIds[#operateIds + 1] = operateId
						end
					end

					local postOperateList = formulaData.postOperateList

					if postOperateList then
						for _, operateId in ipairs(postOperateList) do
							operateIds[#operateIds + 1] = operateId
						end
					end

					operateIds[#operateIds + 1] = formulaData.timerState
					operateIds[#operateIds + 1] = formulaData.envRequireOperate

					for _, operateId in ipairs(operateIds) do
						local operateData = HomelandOperateData[operateId]
						local homeAbility = operateData and operateData.homeAbility
						local abilityId = homeAbility and homeAbility[1]

						if abilityId then
							facilityAbilitySet[abilityId] = true
						end
					end
				end

				local facilityTypeId = facilityData.typeId
				local facilityCountByAbility = facilityCountByTypeId[facilityTypeId]

				if facilityRatioByTypeId[facilityTypeId] and not facilityCountByAbility then
					facilityCountByAbility = {}
					facilityCountByTypeId[facilityTypeId] = facilityCountByAbility
				end

				for abilityId in pairs(facilityAbilitySet) do
					if facilityCountByAbility then
						facilityCountByAbility[abilityId] = (facilityCountByAbility[abilityId] or 0) + 1
					else
						requirement[abilityId] = (requirement[abilityId] or 0) + 1
					end
				end

				local outputLimit = facilityData.outputLimit

				if formulaData and outputLimit and outputLimit > 0 then
					local transportThreshold = formulaData.transportThreshold

					if transportThreshold ~= nil then
						transportThreshold = math.min(transportThreshold, outputLimit)
					else
						transportThreshold = outputLimit * Const.HomeTransportThreshold
					end

					if transportThreshold > 0 then
						transportFacilityCount = transportFacilityCount + 1
					end
				end
			end
		end
	end

	for facilityTypeId, facilityCountByAbility in pairs(facilityCountByTypeId) do
		local facilityCountPerRequirement = math.max(facilityRatioByTypeId[facilityTypeId] or 1, 1)

		for abilityId, facilityCount in pairs(facilityCountByAbility) do
			requirement[abilityId] = (requirement[abilityId] or 0) + math.ceil(facilityCount / facilityCountPerRequirement)
		end
	end

	local transportFacilityCountPerRequirement = math.max(HomelandConfigData.homeTransportAbilityRequirementRatio or 1, 1)
	local transportOperateData = HomelandOperateData[Const.HOMELAND_FACILITY_OP_TYPE.TRANSPORT]
	local transportHomeAbility = transportOperateData and transportOperateData.homeAbility
	local transportAbilityId = transportHomeAbility and transportHomeAbility[1]

	if transportAbilityId and transportFacilityCount > 0 then
		requirement[transportAbilityId] = (requirement[transportAbilityId] or 0) + math.ceil(transportFacilityCount / transportFacilityCountPerRequirement)
	end

	return requirement
end

function HomeLandUtils.getHomePetOperIdAtFacility(space, ornamentId, petId, petPrototypeId)
	if not ornamentId then
		return Const.HOMELAND_FACILITY_OP_TYPE.NONE
	end

	if not HomeLandUtils.isHomePetInProduceArea(space, petId) then
		return Const.HOMELAND_FACILITY_OP_TYPE.NONE
	end

	local ornamentInfo = space.ornament[ornamentId]

	if not ornamentInfo then
		return Const.HOMELAND_FACILITY_OP_TYPE.NONE
	end

	if not HomeLandUtils.isProduceAreaOrnament(ornamentInfo) then
		return Const.HOMELAND_FACILITY_OP_TYPE.NONE
	end

	local facilityInfo = space.facility[ornamentId]

	if not facilityInfo then
		return Const.HOMELAND_FACILITY_OP_TYPE.NONE
	end

	local homeTemplateId = ornamentInfo.homeId
	local allocation = space.allocation

	if Utils.checkHomePetCanDoOperId(petPrototypeId, Const.HOMELAND_FACILITY_OP_TYPE.TRANSPORT) and HomeLandUtils.checkIsOverTransportThreshold(homeTemplateId, facilityInfo) and Utils.checkHasStoreOrnament(space) then
		if Utils.checkHasPetInTransport(allocation, ornamentId, petId) then
			return Const.HOMELAND_FACILITY_OP_TYPE.NONE
		end

		return Const.HOMELAND_FACILITY_OP_TYPE.TRANSPORT
	end

	if not Utils.checkHomeFacilityStateValid(facilityInfo) then
		return Const.HOMELAND_FACILITY_OP_TYPE.NONE
	end

	local isOverPetWorkMaxCount = Utils.checkOverHomePetWorkMaxCount(allocation, ornamentId, homeTemplateId, petId)

	if not isOverPetWorkMaxCount then
		for timerStateOp, _ in pairs(facilityInfo.timerStateMap) do
			if Utils.checkHomePetCanDoOperId(petPrototypeId, timerStateOp) then
				return timerStateOp
			end
		end

		if facilityInfo.disable then
			return Const.HOMELAND_FACILITY_OP_TYPE.NONE
		end

		local stateValid = true

		for _, state in pairs(Const.HOMELAND_CHECK_VALID_STATES) do
			if facilityInfo.extraStateMap[state] then
				stateValid = false

				break
			end
		end

		if stateValid and (facilityInfo.facilityStateInfo.ptype == Const.HOMELAND_PRODUCE_TYPE.WORKLOAD or facilityInfo.facilityStateInfo.ptype == Const.HOMELAND_PRODUCE_TYPE.ENV) and facilityInfo.facilityState > 0 and Utils.checkHomePetCanDoOperId(petPrototypeId, facilityInfo.facilityState) then
			return facilityInfo.facilityState
		end
	end

	return Const.HOMELAND_FACILITY_OP_TYPE.NONE
end

function HomeLandUtils.isMutationItem(itemId)
	local reverseInfo = HomelandFormulaReverseData[itemId]

	return reverseInfo ~= nil and reverseInfo.rType ~= 0
end

function HomeLandUtils.getMutationCollectType(itemId)
	local reverseInfo = HomelandFormulaReverseData[itemId]

	if reverseInfo == nil or reverseInfo.rType == 0 then
		return nil
	end

	local randomFormulaData = HomelandFormulaRandomData[reverseInfo.formulaId]

	if not randomFormulaData then
		return nil
	end

	local randomInfo = randomFormulaData[reverseInfo.rType]

	if not randomInfo then
		return nil
	end

	return randomInfo.collectType
end

function HomeLandUtils.isMutationCollectType(collectType)
	if type(collectType) ~= "number" then
		return false
	end

	for _, randomFormulaData in pairs(HomelandFormulaRandomData) do
		for randomType, randomInfo in pairs(randomFormulaData) do
			if randomType ~= 0 and randomInfo.collectType == collectType then
				return true
			end
		end
	end

	return false
end

function HomeLandUtils.sumAutoMutation(facilityInfo)
	local sum = 0

	if facilityInfo.specialOutputMap then
		for _, info in pairs(facilityInfo.specialOutputMap) do
			if info.mode == Const.HOME_MUTATION_MODE.AUTO then
				sum = sum + info.num
			end
		end
	end

	return sum
end

function HomeLandUtils.sumSpecialOutput(facilityInfo)
	local sum = 0

	if facilityInfo and facilityInfo.specialOutputMap then
		for _, info in pairs(facilityInfo.specialOutputMap) do
			sum = sum + (info.num or 0)
		end
	end

	return sum
end

function HomeLandUtils.checkIsOverTransportThreshold(homeTemplateId, facilityInfo)
	local facilityId = Utils.getHomeObjectFacilityId(homeTemplateId)
	local facilityData = HomelandFacilityData[facilityId]
	local curNum = 0

	for _, v in pairs(facilityInfo.outputMap) do
		curNum = curNum + v
	end

	curNum = curNum + HomeLandUtils.sumAutoMutation(facilityInfo)

	local ouputLimit = facilityData.outputLimit

	if not ouputLimit then
		return false
	end

	local transportThreshold = 0
	local formulaId = facilityInfo.formulaId

	if formulaId ~= 0 then
		local formulaData = HomelandFormulaData[formulaId]

		if formulaData.transportThreshold then
			transportThreshold = math.min(formulaData.transportThreshold, ouputLimit)
		else
			transportThreshold = ouputLimit * Const.HomeTransportThreshold
		end
	end

	if curNum > 0 and transportThreshold <= curNum then
		return true
	end

	return false
end

function HomeLandUtils.getHomePetOperIdAtFacilityPlus(space, ornamentId, petId)
	if not ornamentId then
		return Const.HOMELAND_FACILITY_OP_TYPE.NONE
	end

	if not HomeLandUtils.isHomePetInProduceArea(space, petId) then
		return Const.HOMELAND_FACILITY_OP_TYPE.NONE
	end

	local ornamentInfo = space.ornament[ornamentId]

	if not ornamentInfo then
		return Const.HOMELAND_FACILITY_OP_TYPE.NONE
	end

	if not HomeLandUtils.isProduceAreaOrnament(ornamentInfo) then
		return Const.HOMELAND_FACILITY_OP_TYPE.NONE
	end

	local facilityInfo = space.facility[ornamentId]

	if not facilityInfo then
		return Const.HOMELAND_FACILITY_OP_TYPE.NONE
	end

	local allocation = space.allocation
	local homeTemplateId = ornamentInfo.homeId
	local petInfo = space.pets[petId]
	local petPrototypeId = petInfo.templateId

	if Utils.checkHomePetCanDoOperId(petPrototypeId, Const.HOMELAND_FACILITY_OP_TYPE.TRANSPORT) and HomeLandUtils.checkIsOverTransportThreshold(homeTemplateId, facilityInfo) and Utils.checkHasStoreOrnament(space) then
		if Utils.checkHasPetInTransport(allocation, ornamentId, petId) then
			return Const.HOMELAND_FACILITY_OP_TYPE.NONE
		end

		return Const.HOMELAND_FACILITY_OP_TYPE.TRANSPORT
	end

	if not Utils.checkHomeFacilityStateValid(facilityInfo) then
		return Const.HOMELAND_FACILITY_OP_TYPE.NONE
	end

	local petAllocationDict = HomeLandUtils.tempAllocateInfo

	table.clear(petAllocationDict)

	local targetWorkOperId = HomeLandUtils.innerGetPetWorkOperId(petPrototypeId, facilityInfo)

	if targetWorkOperId ~= Const.HOMELAND_FACILITY_OP_TYPE.NONE then
		local curWorkCount, curWorkPosIndex = Utils.getHomeFacilityPetAllocationInfo(space, petId, ornamentId, petAllocationDict)
		local maxWorkCount = Utils.getFacilityMaxPetCount(homeTemplateId)

		if curWorkPosIndex ~= 0 then
			return targetWorkOperId, curWorkPosIndex, false, curWorkCount
		elseif curWorkCount < maxWorkCount then
			local posIndex = HomeLandUtils.getBestFitPosIndex(space, homeTemplateId, petId, petAllocationDict, targetWorkOperId)

			if posIndex > 0 then
				return targetWorkOperId, posIndex, false, curWorkCount
			end
		else
			local posIndex = HomeLandUtils.getBestFitReplacePosIndex(space, homeTemplateId, petId, petAllocationDict, targetWorkOperId)

			if posIndex > 0 then
				return targetWorkOperId, posIndex, true, curWorkCount
			end
		end
	end

	return Const.HOMELAND_FACILITY_OP_TYPE.NONE
end

function HomeLandUtils.getBestFitPosIndex(space, homeTemplateId, petId, petAllocationDict, targetWorkOperId)
	for i = 1, Const.MAX_FACILITY_PET_SLOTS do
		if not petAllocationDict[i] then
			return i
		end
	end

	return 0
end

function HomeLandUtils.getBestFitReplacePosIndex(space, homeTemplateId, petId, petAllocationDict, targetWorkOperId)
	local replaceIndex, replacePetWorkload
	local petInfo = space.pets[petId]
	local facilityId = Utils.getHomeObjectFacilityId(homeTemplateId)
	local curWorkload = Utils.calcHomePetTimeWorkload(petInfo, targetWorkOperId, facilityId, space:checkHomePetHasFood())

	for i = 1, Const.MAX_FACILITY_PET_SLOTS do
		local petAllocation = petAllocationDict[i]

		if petAllocation and petAllocation.opId == targetWorkOperId and not petAllocation.manual and curWorkload > petAllocation.workload and (replaceIndex == nil or replacePetWorkload > petAllocation.workload) then
			replaceIndex = i
			replacePetWorkload = petAllocation.workload
		end
	end

	return replaceIndex or 0
end

function HomeLandUtils.innerGetPetWorkOperId(petPrototypeId, facilityInfo)
	for timerStateOp, _ in pairs(facilityInfo.timerStateMap) do
		if Utils.checkHomePetCanDoOperId(petPrototypeId, timerStateOp) then
			return timerStateOp
		end
	end

	if facilityInfo.disable then
		return Const.HOMELAND_FACILITY_OP_TYPE.NONE
	end

	if (facilityInfo.facilityStateInfo.ptype == Const.HOMELAND_PRODUCE_TYPE.WORKLOAD or facilityInfo.facilityStateInfo.ptype == Const.HOMELAND_PRODUCE_TYPE.ENV) and facilityInfo.facilityState > 0 and Utils.checkHomePetCanDoOperId(petPrototypeId, facilityInfo.facilityState) then
		return facilityInfo.facilityState
	end

	return Const.HOMELAND_FACILITY_OP_TYPE.NONE
end

function HomeLandUtils.allocateHomePetWork(entity, ornamentId, operId)
	if Utils.checkClient() then
		entity.space:allocateHomePetWork(entity.id, ornamentId, operId)
	else
		entity.space:allocatePetWork(entity.id, ornamentId, operId)
	end
end

function HomeLandUtils.deAllocateHomePetWork(entity)
	if Utils.checkClient() then
		entity.space:deallocateHomePetWork(entity.id)
	else
		entity.space:deAllocatePetWork(entity.id)
	end
end

function HomeLandUtils.getPosRotByOrnamentId(entity, ornamentId, posIndex)
	local ornamentInfo = entity.space.ornament[ornamentId]
	local homeTemplateId = ornamentInfo.homeId
	local ornamentPos = ornamentInfo:getPosition()
	local ornamentRot = ornamentInfo:getRotation()
	local ornamentYaw = ornamentInfo:getYawAngle()
	local areaId = ornamentInfo.areaId or Const.HOMELAND_AREA_TYPE.PRODUCE

	if Utils.checkClient() then
		local areaRotation = pg.game.home:getAreaBaseRotation(areaId)
		local areaYaw = areaRotation and areaRotation:GetEulerAnglesY() or 0

		ornamentPos = pg.game.home:getWorldPosition(areaId, ornamentPos)
		ornamentRot = pg.game.home:getWorldRotation(areaId, ornamentRot)
		ornamentYaw = ornamentYaw + areaYaw
	elseif entity.space.getOrnamentWorldPosition and entity.space.getOrnamentWorldRotation then
		local areaRotation = entity.space:getOrnamentWorldRotation(areaId, Quaternion.identity)
		local areaYaw = areaRotation:GetEulerAnglesY()

		ornamentPos = entity.space:getOrnamentWorldPosition(areaId, ornamentPos)
		ornamentRot = entity.space:getOrnamentWorldRotation(areaId, ornamentRot)
		ornamentYaw = ornamentYaw + areaYaw
	end

	if posIndex == 0 then
		posIndex = 1
	end

	local homeObjectData = HomeObjectData[homeTemplateId]
	local attachPos = homeObjectData["attachPoint" .. posIndex]

	attachPos = attachPos or homeObjectData.attachPoint1

	local resultPos = ornamentPos
	local resultYaw = ornamentYaw

	if attachPos then
		local offset = Vector3(attachPos[1], attachPos[2], attachPos[3])

		resultPos = resultPos + ornamentRot * offset
		resultYaw = resultYaw + (attachPos[4] or 0)
	end

	return resultPos, resultYaw
end

function HomeLandUtils.getSqrDistanceByOrnamentId(entity, ornamentId)
	local pos = entity.space.ornament[ornamentId]:getPosition()
	local entityPos = entity:getPosition()
	local dx, dz = pos[1] - entityPos[1], pos[3] - entityPos[3]

	return dx * dx + dz * dz
end

function HomeLandUtils.getOrnamentPosById(entity, ornamentId)
	return entity.space.ornament[ornamentId]:getPosition()
end

function HomeLandUtils.getOrnamentPetWorkDistance(entity, ornamentId)
	local ornamentInfo = entity.space.ornament[ornamentId]
	local homeTemplateId = ornamentInfo.homeId
	local homeObjectData = HomeObjectData[homeTemplateId]

	return homeObjectData.petWorkDistance or 0
end

function HomeLandUtils.checkEntityIsFree(entity)
	local space = entity.space

	if Utils.isHomeCamp(space and space.spaceType) then
		return true
	end

	local petInfo = space.pets[entity.id]

	return HomeLandUtils.checkEntityIsFreeByPetInfo(petInfo, space)
end

function HomeLandUtils.checkEntityIsFreeByPetInfo(petInfo, space)
	if Utils.isHomeCamp(space and space.spaceType) then
		return true
	end

	if petInfo and Utils.checkHomePetStateValid(petInfo, space) then
		return space.allocation[petInfo.id] == nil or space.allocation[petInfo.id].opId == Const.HOMELAND_FACILITY_OP_TYPE.NONE
	end

	return false
end

function HomeLandUtils.getEntityAllocationInfo(entity)
	local space = entity.space

	if Utils.isHomeCamp(space and space.spaceType) then
		return nil
	end

	return space.allocation[entity.id]
end

function HomeLandUtils.parseHomelandKey(homelandKey)
	local res = string.split(homelandKey, "-")
	local serverId, uid = res[1], res[2]

	return tonumber(serverId), tostring(uid)
end

function HomeLandUtils.selectTargetWork(entity)
	local space = entity.space

	if Utils.isHomeCamp(space and space.spaceType) then
		return nil, nil
	end

	local allFacility = space.facility
	local petPrototypeId = entity.petPrototypeId
	local entityId = entity.id
	local currentAllocationInfo = HomeLandUtils.getEntityAllocationInfo(entity)
	local preferOrnamentId = currentAllocationInfo and currentAllocationInfo.ornamentId

	if allFacility[preferOrnamentId] then
		local operId = HomeLandUtils.getHomePetOperIdAtFacility(space, preferOrnamentId, entityId, petPrototypeId)

		if operId ~= Const.HOMELAND_FACILITY_OP_TYPE.NONE then
			return preferOrnamentId, operId
		end
	end

	local closeDistance = math.maxFloat
	local selectedOrnamentId, selectedOperId

	for ornamentId, facilityInfo in pairs(allFacility) do
		local operId = HomeLandUtils.getHomePetOperIdAtFacility(space, ornamentId, entityId, petPrototypeId)

		if operId ~= Const.HOMELAND_FACILITY_OP_TYPE.NONE then
			local dist = HomeLandUtils.getSqrDistanceByOrnamentId(entity, ornamentId)

			if dist < closeDistance then
				closeDistance = dist
				selectedOrnamentId = ornamentId
				selectedOperId = operId
			end
		end
	end

	return selectedOrnamentId, selectedOperId
end

function HomeLandUtils.hasEventData(entity)
	local space = entity.space

	if Utils.isHomeCamp(space and space.spaceType) then
		return false
	end

	return entity.petInfo and not Utils.checkHomePetStateValid(entity.petInfo, entity.space) and entity.petInfo:getHomeEventTypeData(entity.space)
end

function HomeLandUtils.hasAllocationInfo(entity)
	return entity.allocationInfo
end

function HomeLandUtils.checkOperIdIsMoving(operId)
	if operId == Const.HOMELAND_FACILITY_OP_TYPE.TRANSPORT or operId == Const.HOMELAND_FACILITY_OP_TYPE.GOTO_TRANSPORT or operId == Const.HOMELAND_FACILITY_OP_TYPE.TRANSPORT_TO_STORE or operId == Const.HOMELAND_FACILITY_OP_TYPE.MOVING then
		return true
	end

	return false
end

function HomeLandUtils.checkOperIdIsTransport(operId)
	if operId == Const.HOMELAND_FACILITY_OP_TYPE.TRANSPORT_TO_STORE then
		return true
	end

	return false
end

function HomeLandUtils.getPetMaxCount(space)
	return (HomelandConfigData.maxPetCount or 0) + (space.petExtraNum or 0)
end

function HomeLandUtils.getPetCurCount(space)
	local curCount = 0

	if not space.pets then
		return 0
	end

	for _, _ in pairs(space.pets) do
		curCount = curCount + 1
	end

	return curCount
end

function HomeLandUtils.getFormulaOutputMap(formulaData)
	local outputMap = {}

	if formulaData.outputs and next(formulaData.outputs) then
		for _, outputInfo in ipairs(formulaData.outputs) do
			outputMap[outputInfo[1]] = outputInfo[2]
		end
	end

	return outputMap
end

function HomeLandUtils.getFormulaOutputList(formulaData)
	local outputList = {}

	if formulaData.outputs and next(formulaData.outputs) then
		for _, outputInfo in ipairs(formulaData.outputs) do
			table.insert(outputList, {
				outputInfo[1],
				outputInfo[2]
			})
		end
	end

	return outputList
end

function HomeLandUtils.getDisplayOutputItemId(formulaData)
	if formulaData.outputs and next(formulaData.outputs) then
		return formulaData.outputs[1][1], formulaData.outputs[1][2]
	else
		return nil, nil
	end
end

function HomeLandUtils.getHomelandFormulaValidTimeRange(formulaId)
	local formulaData = HomelandFormulaData[formulaId]
	local timePeriodId = formulaData and formulaData.timePeriodId

	if not timePeriodId or timePeriodId == 0 then
		return nil, nil
	end

	local periodData = HomelandFormulaPeriodData[timePeriodId]

	if not periodData then
		return nil, nil
	end

	local seasonId = periodData.seasonId

	if seasonId and seasonId ~= 0 then
		local seasonData = HomeSeasonData[seasonId]

		if not seasonData then
			return nil, nil
		end

		return Utils.getConfigTimeOfAreaByData(seasonData.startDayTime, seasonData.startDayTimeRefId), Utils.getConfigTimeOfAreaByData(seasonData.endDayTime, seasonData.endDayTimeRefId)
	end

	local startTime = Utils.getConfigTimeOfAreaByData(periodData.startTime, periodData.startDayTimeRefId)
	local endTime = Utils.getConfigTimeOfAreaByData(periodData.endTime, periodData.endDayTimeRefId)

	if endTime and (periodData.istomorrow == true or periodData.istomorrow == 1) then
		endTime = endTime + Const.SECONDS_ONE_DAY
	end

	return startTime, endTime
end

function HomeLandUtils.getHomelandFormulaSeasonId(formulaId)
	local formulaData = HomelandFormulaData[formulaId]
	local timePeriodId = formulaData and formulaData.timePeriodId
	local periodData = timePeriodId and HomelandFormulaPeriodData[timePeriodId]

	if not periodData or periodData.periodType ~= 2 then
		return nil
	end

	local seasonId = periodData and periodData.seasonId

	return seasonId and seasonId ~= 0 and seasonId or nil
end

function HomeLandUtils.getHomelandFormulaSeasonModuleId(formulaId)
	if not HomeLandUtils.getHomelandFormulaSeasonId(formulaId) then
		return nil
	end

	local formulaData = HomelandFormulaData[formulaId]

	return formulaData and formulaData.tillRewardId and formulaData.tillRewardId > 0 and 3 or 4
end

function HomeLandUtils.isHomelandFormulaTimeValid(formulaId, timestamp)
	local formulaData = HomelandFormulaData[formulaId]

	if not formulaData then
		return false
	end

	if not formulaData.timePeriodId or formulaData.timePeriodId == 0 then
		return true
	end

	local startTime, endTime = HomeLandUtils.getHomelandFormulaValidTimeRange(formulaId)

	if not startTime or not endTime or endTime <= startTime then
		return false
	end

	timestamp = timestamp or Time.getSecond()

	return startTime <= timestamp and timestamp < endTime
end

function HomeLandUtils.getHomelandFormulaValidDuration(formulaId, fromTs, toTs)
	if not fromTs or not toTs or toTs <= fromTs then
		return 0
	end

	local formulaData = HomelandFormulaData[formulaId]

	if not formulaData then
		return 0
	end

	if not formulaData.timePeriodId or formulaData.timePeriodId == 0 then
		return toTs - fromTs
	end

	local startTime, endTime = HomeLandUtils.getHomelandFormulaValidTimeRange(formulaId)

	if not startTime or not endTime or endTime <= startTime then
		return 0
	end

	return math.max(math.min(toTs, endTime) - math.max(fromTs, startTime), 0)
end

function HomeLandUtils.getLevelFormulaList(homeTemplateId, facilityId, upgradeInfo)
	local formulaList = {}

	if not upgradeInfo then
		return formulaList
	end

	local facilityData = HomeFacilityData[facilityId]
	local nextFacilityData = HomeFacilityData[upgradeInfo.homeTemplateId]

	if not facilityData or not nextFacilityData then
		return formulaList
	end

	local curFormulaSet = {}

	for _, formulaId in ipairs(facilityData.formulaList or EMPTY_TABLE) do
		curFormulaSet[formulaId] = true
	end

	for _, formulaId in ipairs(nextFacilityData.formulaList or EMPTY_TABLE) do
		if not curFormulaSet[formulaId] then
			local formulaData = HomelandFormulaData[formulaId]

			if formulaData then
				local conditionLocked = false

				if formulaData.unlockCondition and not pg.me.triggerMap:isCompleteOrMeetCondition(formulaData.unlockCondition) then
					conditionLocked = true
				end

				local drawingLocked = not HomeLandUtils.isHomelandFormulaDrawingUnlocked(pg.me, formulaId)
				local defaultOutputItem, defaultOutputItemNum = HomeLandUtils.getDisplayOutputItemId(formulaData)

				table.insert(formulaList, {
					id = formulaData.previewItemId or defaultOutputItem,
					itemId = defaultOutputItem,
					formulaId = formulaId,
					conditionLocked = conditionLocked,
					drawingLocked = drawingLocked
				})
			end
		end
	end

	return formulaList
end

function HomeLandUtils.isElectricFormula(formulaId)
	local formulaData = HomelandFormulaData[formulaId] or {}
	local electricOperationId = HomelandConfigData.ElectricOperationId or 5002

	if formulaData.postOperateList and #formulaData.postOperateList == 1 and formulaData.postOperateList[1] == electricOperationId then
		return true
	end

	return false
end

function HomeLandUtils.isFieldOrWoodland(homeId)
	local facilityId = Utils.getHomeObjectFacilityId(homeId)

	if not facilityId then
		return false
	end

	local facilityData = HomelandFacilityData[facilityId]

	if not facilityData then
		return false
	end

	local fieldTypeId = HomelandConfigData.FieldTypeId or 1010000
	local woodlandTypeId = HomelandConfigData.WoodlandTypeId or 1010001
	local typeId = facilityData.typeId

	return typeId == fieldTypeId or typeId == woodlandTypeId
end

function HomeLandUtils.getHomePayOrderRefreshLimit(homeLevel)
	local orderRefreshData = OrderRefreshData[homeLevel]

	return orderRefreshData and orderRefreshData.costRefresh
end

function HomeLandUtils.isHomeOrderItem(itemId)
	if not itemId then
		return false
	end

	local rawShowList = pg.me.showList:getRawTable()

	for _, v in ipairs(rawShowList) do
		if v.orderStatus == HomeOrderConst.STATUS.Incomplete then
			local orderCfg = OrderLibData[v.orderId]

			if orderCfg then
				for i = 1, 3 do
					local unlockItem = orderCfg["unlockItem" .. i]

					if unlockItem and unlockItem[1] == itemId then
						return true
					end
				end
			end
		end
	end

	return false
end

function HomeLandUtils.getTempLevelText(level)
	if level == 1 then
		return pg.getGameString("TEMPERATURE_WARM")
	elseif level == 2 then
		return pg.getGameString("TEMPERATURE_HOT")
	elseif level == -1 then
		return pg.getGameString("TEMPERATURE_COLD")
	elseif level == -2 then
		return pg.getGameString("TEMPERATURE_FROZEN")
	elseif level == 0 then
		return pg.getGameString("TEMPERATURE_NORMAL")
	else
		return ""
	end
end

function HomeLandUtils.homeOrnamentHasAnim(config)
	if config.hasAnimator or config.startAnimName or config.workAnimName or config.endAnimName or config.noworkAnimName or config.produceAnim or config.resetWorkAnim or config.interactiveOpenAnim or config.interactiveCloseAnim then
		return true
	end

	return false
end

function HomeLandUtils.homeOrnamentHasAudio(config)
	if config.workSound or config.produceSound or config.openSound or config.closeSound or config.attachSound then
		return true
	end

	return false
end

function HomeLandUtils.homeOrnamentHasEffect(config)
	if config.produceEffect or config.startWorkEffects or config.workEffects or config.petWorkEffect then
		return true
	end

	return false
end

function HomeLandUtils.isHomeOrnamentPureStatic(config)
	if not config then
		return false
	end

	if config.actionPrototypeIds or config.needStateInteraction == 1 or config.needIndicatorIcon == 1 then
		return false
	end

	if HomeLandUtils.homeOrnamentHasAnim(config) or HomeLandUtils.homeOrnamentHasEffect(config) or HomeLandUtils.homeOrnamentHasAudio(config) then
		return false
	end

	return true
end

function HomeLandUtils.isHomeMusicPlayer(homeTemplateId)
	for _, configuredHomeId in ipairs(HomelandConfigData.homeSpInteractiveItem or EMPTY_TABLE) do
		if configuredHomeId == homeTemplateId then
			return true
		end
	end

	return false
end

function HomeLandUtils.isHomeGashapon(homeTemplateId)
	return HomelandConfigData.homeLotteryFurnitureId == homeTemplateId
end

function HomeLandUtils.getHatchBoxProgressRatioByOrnamentId(ornamentId)
	local hatchBoxInfo = HomeLandUtils.getHatchBoxInfo(ornamentId)

	if not hatchBoxInfo then
		return 0
	end

	return HomeLandUtils.getHatchBoxProgressRatio(hatchBoxInfo)
end

function HomeLandUtils.getHatchBoxProgressRatio(hatchBoxInfo)
	if not hatchBoxInfo or not hatchBoxInfo.item then
		return 0
	end

	local nowTime = Time.secondCache
	local currentEnvFactor = hatchBoxInfo.currentEnvFactor or 0
	local homeCarSpeedUpFactor = hatchBoxInfo.homeCarSpeedUpFactor or 0
	local accumulatedProgress = hatchBoxInfo.accumulatedProgress or 0
	local lastRateChangeTime = hatchBoxInfo.lastRateChangeTime or 0
	local totalTimeReductionRate = hatchBoxInfo.totalTimeReductionRate or 0
	local totalFixedReduction = hatchBoxInfo.totalFixedReduction or 0
	local itemId = hatchBoxInfo.item and hatchBoxInfo.item.id
	local eggCfg = PetHatchEggData[itemId]
	local baseDurSecond = (eggCfg and eggCfg.times or 0) * Const.SECONDS_ONE_MINUTE

	return HomeLandUtils.m_caltHatchBoxProgressRatio(nowTime, currentEnvFactor, accumulatedProgress, lastRateChangeTime, totalTimeReductionRate, totalFixedReduction, baseDurSecond)
end

function HomeLandUtils.getHatchBoxRealWorkRatio(ornamentId)
	local hatchBoxInfo = HomeLandUtils.getHatchBoxInfo(ornamentId)

	if not hatchBoxInfo then
		return 0
	end

	local totalTimeReductionRate = hatchBoxInfo.totalTimeReductionRate or 0
	local denominator = 1 - totalTimeReductionRate

	if denominator <= 0 then
		return 1
	end

	local currentEnvFactor = hatchBoxInfo.currentEnvFactor or 0
	local homeCarSpeedUpFactor = hatchBoxInfo.homeCarSpeedUpFactor or 0

	return (1 + currentEnvFactor + homeCarSpeedUpFactor) / denominator
end

function HomeLandUtils.getHatchEggRecommendEnvInfos(ornamentId)
	local hatchBoxInfo = HomeLandUtils.getHatchBoxInfo(ornamentId)
	local hatchBoxItemInfo = HomeLandUtils.getHatchBoxItemInfo(hatchBoxInfo)
	local nowTemp, nowLight = pg.game and pg.game.home and pg.game.home:getHatchBoxRecommendEnvInfoTL(ornamentId) or 0, 0
	local requireEnvs = hatchBoxItemInfo and hatchBoxItemInfo.requireEnvs or {}
	local recTemp = requireEnvs[1] or 0
	local recLight = requireEnvs[2] or 0
	local recommendInfos = {}
	local isHasRecommendEnvCfg = requireEnvs and #requireEnvs > 0
	local recommendEnvRatio = 0

	if isHasRecommendEnvCfg then
		recommendEnvRatio = HomeLandUtils.getHatchEggRecommendEnvRatio(nowTemp, nowLight, recTemp, recLight)

		local recommendInfo = {
			isTemperature = true,
			tIndex = 0,
			requireRate = recTemp,
			tempWorkRatio = recommendEnvRatio
		}

		table.insert(recommendInfos, recommendInfo)

		local recommendInfo = {
			isLight = true,
			tIndex = 0,
			requireRate = recLight,
			lightWorkRatio = recommendEnvRatio
		}

		table.insert(recommendInfos, recommendInfo)
	end

	return recommendInfos, recommendEnvRatio
end

function HomeLandUtils.getHatchBoxHatchedLeftSecondByOrnamentId(ornamentId)
	local hatchBoxInfo = HomeLandUtils.getHatchBoxInfo(ornamentId)

	if not hatchBoxInfo then
		return 0
	end

	return HomeLandUtils.getHatchBoxHatchedLeftSecond(hatchBoxInfo)
end

function HomeLandUtils.getHatchBoxHatchedLeftSecond(hatchBoxInfo)
	if not hatchBoxInfo or not hatchBoxInfo.item then
		return 0
	end

	local endTimeSecond = hatchBoxInfo and hatchBoxInfo.endTime or 0
	local nowTimeSecond = Time.secondCache
	local leftSecond = math.max(0, endTimeSecond - nowTimeSecond)

	return leftSecond
end

function HomeLandUtils.getHatchBoxCurrentEnvFactor(hatchBoxInfo)
	return hatchBoxInfo and hatchBoxInfo.currentEnvFactor or 0
end

function HomeLandUtils.getHatchBoxFondleInfo(hatchBoxInfo)
	local itemId = hatchBoxInfo and hatchBoxInfo.item and hatchBoxInfo.item.id

	if not itemId then
		return
	end

	local petHatchEggData = PetHatchEggData[itemId]
	local fondleByPlayerLimitDaily = petHatchEggData and petHatchEggData.fondleByPlayerLimitDaily or 0
	local fondleLimitTotalDaily = petHatchEggData and petHatchEggData.fondleLimitTotalDaily or 0
	local todaySelfHatchFondleCount = pg.me.todaySelfHatchFondleCount or 0
	local todayOtherHatchFondleCount = pg.me.todayOtherHatchFondleCount or 0
	local todayTotalFondleCount = hatchBoxInfo and hatchBoxInfo.todayTotalFondleCount or 0
	local selfHomeHatchFondleCount = PetBallConfigData and PetBallConfigData.selfHomeHatchFondleCount or 0
	local otherHomeHatchFondleCount = PetBallConfigData and PetBallConfigData.otherHomeHatchFondleCount or 0
	local isMeHomeland = pg.me.space:isSelfHomeland()
	local isCanFondle = false
	local showUIFondledCnt = isMeHomeland and todaySelfHatchFondleCount or todayOtherHatchFondleCount
	local showUILimitCnt = isMeHomeland and selfHomeHatchFondleCount or otherHomeHatchFondleCount
	local showUIRemainCnt = math.max(0, showUILimitCnt - showUIFondledCnt)

	if todayTotalFondleCount < fondleLimitTotalDaily then
		if isMeHomeland then
			if todaySelfHatchFondleCount < selfHomeHatchFondleCount then
				isCanFondle = true
			end
		elseif todayOtherHatchFondleCount < otherHomeHatchFondleCount then
			isCanFondle = true
		end
	end

	local ret = {
		fondleByPlayerLimitDaily = fondleByPlayerLimitDaily,
		fondleLimitTotalDaily = fondleLimitTotalDaily,
		todaySelfHatchFondleCount = todaySelfHatchFondleCount,
		todayOtherHatchFondleCount = todayOtherHatchFondleCount,
		todayTotalFondleCount = todayTotalFondleCount,
		isCanFondle = isCanFondle,
		selfHomeHatchFondleCount = selfHomeHatchFondleCount,
		otherHomeHatchFondleCount = otherHomeHatchFondleCount,
		showUIFondledCnt = showUIFondledCnt,
		showUILimitCnt = showUILimitCnt,
		showUIRemainCnt = showUIRemainCnt
	}

	return ret
end

function HomeLandUtils.getHatchBoxSpeedupInfo(hatchBoxInfo)
	local itemId = hatchBoxInfo and hatchBoxInfo.item and hatchBoxInfo.item.id

	if not itemId then
		return
	end

	local petHatchEggData = PetHatchEggData[itemId]
	local itemSpeedUpLimit = petHatchEggData and petHatchEggData.itemSpeedUpLimit or 0
	local curUsedCnt = hatchBoxInfo.itemSpeedUpCount or 0
	local ret = {
		dailyLimitCnt = itemSpeedUpLimit,
		curUsedCnt = curUsedCnt,
		remainCnt = itemSpeedUpLimit - curUsedCnt,
		isCanSpeedup = curUsedCnt < itemSpeedUpLimit
	}

	return ret
end

function HomeLandUtils.m_caltHatchBoxProgressRatio(nowTime, currentEnvFactor, accumulatedProgress, lastRateChangeTime, totalTimeReductionRate, totalFixedReduction, baseDurSecond)
	if baseDurSecond <= totalFixedReduction then
		return 1
	end

	if totalTimeReductionRate >= 1 then
		return 1
	end

	local elapsedSeconds = nowTime - lastRateChangeTime
	local denominator = 1 - totalTimeReductionRate

	if denominator <= 0 then
		return 1
	end

	local currentWorkRate = (1 + currentEnvFactor) / denominator
	local progress = accumulatedProgress + elapsedSeconds * currentWorkRate
	local target = math.max(1, baseDurSecond - totalFixedReduction)

	return math.min(1, progress / target)
end

function HomeLandUtils.showPauseHatchConfirm(okFunc)
	local ClientUtils = require("Utils.ClientUtils")

	ClientUtils.showConfirmRaw(pg.getGameString("RELEASE_WARN"), pg.getGameString("HATCH_PAUSE_CONFIRM"), okFunc, false)
end

function HomeLandUtils.getHatchBoxInfo(ornamentId)
	local hatchBoxInfo = pg.me and pg.me.space and pg.me.space:getHatchBoxInfo(ornamentId)

	return hatchBoxInfo
end

function HomeLandUtils.getHatchBoxItemInfo(ornamentId)
	local hatchBoxInfo = pg.me.space:getHatchBoxInfo(ornamentId)

	if not hatchBoxInfo or not hatchBoxInfo.item then
		return
	end

	local itemId = hatchBoxInfo.item.id
	local itemCfg = ItemData[itemId]
	local petHatchEggData = PetHatchEggData[itemId]

	if not petHatchEggData then
		return
	end

	local ret = {
		itemId = itemId,
		itemName = itemCfg and itemCfg.itemName,
		itemIcon = itemCfg and itemCfg.icon,
		requireEnvs = petHatchEggData and petHatchEggData.requireEnvs
	}
	local bindingId = itemCfg.bindingId
	local envObjTemplateId = Utils.getBindingSceneObjectId(itemId and bindingId or 0)

	ret.envObjTemplateId = envObjTemplateId or 0

	return ret
end

function HomeLandUtils.getHatchBoxChooseCubeItemInfo(ornamentId)
	local hatchBoxInfo = pg.me.space:getHatchBoxInfo(ornamentId)

	if not hatchBoxInfo or not hatchBoxInfo.item then
		return
	end

	local itemId = hatchBoxInfo.item.id
	local context = string.format("hatchOrnamentId=%s", tostring(ornamentId))
	local PetFertilityConst = require("Const.PetFertilityConst")
	local envObjTemplateId, prefabResID = Utils.getEggBindingSceneObjectIdByItemId(itemId, context, PetFertilityConst.fallbackEggResId)

	if not prefabResID or prefabResID == "" then
		return
	end

	if not Utils.isHatchEggRuntimeDataValid(hatchBoxInfo.item) then
		return
	end

	return {
		itemId = itemId,
		envObjTemplateId = envObjTemplateId,
		prefabResID = prefabResID
	}
end

function HomeLandUtils.getHatchBoxStatus(ornamentId)
	if not ornamentId or ornamentId <= 0 then
		return Const.HOME_HATCHBOX_STATUS.INIT
	end

	local hatchBoxInfo = pg.me.space:getHatchBoxInfo(ornamentId)

	if not hatchBoxInfo then
		return Const.HOME_HATCHBOX_STATUS.CAN_PLACE
	elseif hatchBoxInfo.status then
		if hatchBoxInfo.status == Const.PET_BALL.HATCH_STATUS_SUCC then
			return Const.HOME_HATCHBOX_STATUS.HATCHED
		elseif hatchBoxInfo.status == Const.PET_BALL.HATCH_STATUS_INIT then
			return Const.HOME_HATCHBOX_STATUS.CAN_PLACE
		elseif hatchBoxInfo.status == Const.PET_BALL.HATCH_STATUS_START then
			local nowTime = Time.secondCache

			if hatchBoxInfo.endTime and nowTime >= hatchBoxInfo.endTime then
				return Const.HOME_HATCHBOX_STATUS.HATCHED
			else
				return Const.HOME_HATCHBOX_STATUS.HATCHING
			end
		end
	end

	return Const.HOME_HATCHBOX_STATUS.CAN_PLACE
end

function HomeLandUtils.tryFondleHatchBox(ornamentId, isNotice)
	local hatchBoxInfo = pg.me.space:getHatchBoxInfo(ornamentId)
	local fondleInfo = HomeLandUtils.getHatchBoxFondleInfo(hatchBoxInfo)

	if fondleInfo and fondleInfo.isCanFondle then
		pg.me.space:reqHatchFondlePetEgg(ornamentId)

		return true
	end

	if isNotice then
		pg.global.showBubbleMessage(NoticeDef.HOMELAND_HATCH_FONDLE_COUNT_LIMIT)
	end

	return false
end

function HomeLandUtils.trySpeedUpHatchBox(ornamentId, itemId, genId, isNotice)
	local hatchBoxInfo = pg.me.space:getHatchBoxInfo(ornamentId)
	local speedupInfo = HomeLandUtils.getHatchBoxSpeedupInfo(hatchBoxInfo)

	if not speedupInfo or not speedupInfo.isCanSpeedup then
		if isNotice then
			pg.global.showBubbleMessage(NoticeDef.HOMELAND_HATCH_ITEM_SPEED_UP_COUNT_LIMIT)
		end

		return false
	end

	pg.me.space:reqItemSpeedUp(ornamentId, itemId, genId)

	return true
end

function HomeLandUtils.tryPauseCurHatch(ornamentId, isNotice)
	local curHatchBoxStatus = HomeLandUtils.getHatchBoxStatus(ornamentId)

	if curHatchBoxStatus == Const.HOME_HATCHBOX_STATUS.HATCHED then
		if isNotice then
			local ClientUtils = require("Utils.ClientUtils")

			ClientUtils.showBubbleMessageById()
			pg.global.showBubbleMessage(NoticeDef.HOMELAND_HATCH_EGG_HATCHED_CANTPAUSE)
		end

		return false
	end

	if curHatchBoxStatus == Const.HOME_HATCHBOX_STATUS.HATCHING then
		pg.me.space:reqQuitHatchPetEgg(ornamentId)

		return false
	end

	return true
end

function HomeLandUtils.tryOpenHatchBox(ornamentId)
	local curHatchBoxStatus = HomeLandUtils.getHatchBoxStatus(ornamentId)

	if curHatchBoxStatus == Const.HOME_HATCHBOX_STATUS.HATCHED then
		pg.me.space:reqGetHatchPetEgg(ornamentId)

		return true
	end

	return false
end

function HomeLandUtils.tryChangeHatchBoxEgg(ornamentId, eggItemId, genId)
	if not ornamentId then
		return false
	end

	local curHatchBoxStatus = HomeLandUtils.getHatchBoxStatus(ornamentId)

	if curHatchBoxStatus == Const.HOME_HATCHBOX_STATUS.CAN_PLACE and eggItemId and genId then
		pg.me.space:reqStartHatchPetEgg(ornamentId, eggItemId, genId)

		return true
	elseif curHatchBoxStatus == Const.HOME_HATCHBOX_STATUS.HATCHED then
		pg.me.space:reqGetHatchPetEgg(ornamentId)

		return true
	elseif curHatchBoxStatus == Const.HOME_HATCHBOX_STATUS.HATCHING then
		HomeLandUtils.showPauseHatchConfirm(function()
			HomeLandUtils.tryPauseCurHatch(ornamentId, true)
		end)

		return false
	end

	return false
end

function HomeLandUtils.openHatchBoxManagerPanel(ornamentId)
	local UIConst = require("Const.UIConst")
	local InteractionConst = require("Common.Const.InteractionConst")
	local param = {
		ornamentId = ornamentId,
		actionPrototypeId = InteractionConst.INTERACT_HOME_HATCHBOX_SUC
	}

	pg.global.ui:open(UIConst.UI_ID_INCUBATOR, param)
end

function HomeLandUtils.getHatchEggRecommendEnvRatio(inputTemp, inputLight, recTemp, recLight)
	if not PetBallConfigData.homelandHatchEnvFormulaId then
		return 0
	end

	local FormulaData = require("Data.formula_data")

	if not FormulaData[PetBallConfigData.homelandHatchEnvFormulaId] then
		return 0
	end

	return FormulaData[PetBallConfigData.homelandHatchEnvFormulaId].formula(inputTemp, inputLight, recTemp, recLight)
end

function HomeLandUtils.getHatchBoxAniInfo(status)
	local AddressDataConst = require("Const.AddressDataConst")
	local aniInfo = {}

	if status == Const.HOME_HATCHBOX_STATUS.HATCHED then
		aniInfo.aniName = "Ani_LVC_Egg_Incubator_Hatched"
		aniInfo.aniSecond = 1.3
		aniInfo.restart = true
		aniInfo.effectName = AddressDataConst.HOME_INCUBATOR_EFFECT_HATCHED
		aniInfo.effectPos = HATCHBOX_EFFECT_POSITION
		aniInfo.effectLifeTime = 3.5
		aniInfo.effectManulLoop = true
	elseif status == Const.HOME_HATCHBOX_STATUS.HATCHING then
		aniInfo.aniName = "Ani_LVC_Egg_Incubator_Hatching"
		aniInfo.aniSecond = 3
		aniInfo.restart = true
		aniInfo.effectName = AddressDataConst.HOME_INCUBATOR_EFFECT_HATCHING
		aniInfo.effectPos = HATCHBOX_EFFECT_POSITION
		aniInfo.effectLifeTime = 4
		aniInfo.effectManulLoop = true
	else
		aniInfo.aniName = "Ani_LVC_Egg_Incubator_Idle"
		aniInfo.aniSecond = 3
		aniInfo.restart = true
		aniInfo.effectName = AddressDataConst.HOME_INCUBATOR_EFFECT_IDLE
		aniInfo.effectPos = HATCHBOX_EFFECT_POSITION
		aniInfo.effectLifeTime = 6
		aniInfo.effectManulLoop = true
	end

	return aniInfo
end

function HomeLandUtils.clearHatchBoxLoopEffect(entComp)
	if not entComp then
		return
	end

	if entComp.delayEffectTimer then
		TimerManager.removeTimer(entComp.delayEffectTimer)

		entComp.delayEffectTimer = nil
	end

	if entComp.curHatchBoxEffectId and entComp.stopEffectById then
		entComp:stopEffectById(entComp.curHatchBoxEffectId, false, true)

		entComp.curHatchBoxEffectId = nil
	end
end

function HomeLandUtils.setHatchBoxLoopEffect(ent, effectName, pos, lifeTime, effectManulLoop)
	if not ent then
		return
	end

	local entEModel = ent.eModel

	if not entEModel then
		return
	end

	if ent.hasEModelComponent and not ent:hasEModelComponent(Const.COMPONENT_INDEX_ANIMATOR) then
		return
	end

	if not effectName then
		return
	end

	local EffectConst = require("Const.EffectConst")

	lifeTime = lifeTime or 3

	if ent.curHatchBoxEffectId and ent.stopEffectById then
		ent:stopEffectById(ent.curHatchBoxEffectId, false, true)

		ent.curHatchBoxEffectId = nil
	end

	if effectName and ent.playEffectRaw then
		ent.curHatchBoxEffectId = ent:playEffectRaw(effectName, {
			mountType = EffectConst.MountType.Model,
			position = pos or Vector3.constZero,
			rotation = {
				0,
				0,
				0,
				0
			}
		})

		if ent.delayEffectTimer then
			TimerManager.removeTimer(ent.delayEffectTimer)

			ent.delayEffectTimer = nil
		end

		if effectManulLoop then
			ent.delayEffectTimer = TimerManager.addTimer(lifeTime, function()
				ent.delayEffectTimer = nil

				if not ent or not ent.eModel then
					return
				end

				HomeLandUtils.setHatchBoxLoopEffect(ent, effectName, pos, lifeTime, effectManulLoop)
			end)
		end
	end
end

function HomeLandUtils.getHomeCampLineIdRange(staticId)
	local hcdd = HomeCampData[staticId]

	if not hcdd then
		return nil, nil
	end

	return hcdd.sublineMinNum, hcdd.sublineMaxNum
end

function HomeLandUtils.getCurHomeCampMainSceneId()
	return pg.me.curCampStaticId and HomeLandUtils.getHomeCampMainSceneId(pg.me.curCampStaticId) or 0
end

function HomeLandUtils.getHomeCampMainSceneId(staticId)
	local hcdd = HomeCampData[staticId]

	return hcdd and hcdd.sceneId and SceneUtils.getMainSceneId(hcdd.sceneId)
end

function HomeLandUtils.getHomeCampSceneId(staticId)
	local hcdd = HomeCampData[staticId]

	return hcdd and hcdd.sceneId
end

function HomeLandUtils.getHomeCampStaticId(sceneId)
	return HomeSceneToCampIdData[sceneId]
end

function HomeLandUtils.isHomeCampScene(sceneId)
	return HomeLandUtils.getHomeCampStaticId(sceneId) ~= nil
end

function HomeLandUtils.getHomeCampMaxLoginCount(staticId)
	local hcdd = HomeCampData[staticId]

	return hcdd and hcdd.carId and #hcdd.carId or 6
end

function HomeLandUtils.getHomeCampMaxEnterCount(staticId)
	local hcdd = HomeCampData[staticId]

	return hcdd and hcdd.maxEnterCount or 10
end

function HomeLandUtils.getCampCarIndex(lineInfo, uid)
	if not lineInfo or not lineInfo.loginUids then
		return nil
	end

	for index, loginUid in pairs(lineInfo.loginUids) do
		if loginUid == uid then
			return tonumber(index)
		end
	end
end

function HomeLandUtils.getCampCarTmplId(staticId, carIndex)
	local hcdd = HomeCampData[staticId]

	if not hcdd or not hcdd.carId then
		return nil
	end

	return hcdd.carId[carIndex]
end

function HomeLandUtils.getCampCarPortalId(templateId)
	local hccdd = HomeCampCarData[templateId]

	if not hccdd then
		return 0
	end

	return hccdd.transmitPointId or 0
end

function HomeLandUtils.getCampCarPosition(sceneId, templateId)
	local hccdd = HomeCampCarData[templateId]

	if not hccdd or not hccdd.carPosition then
		return nil
	end

	local sceneId = SceneUtils.getMainSceneId(sceneId)
	local pos, rot = SceneUtils.getCommonBasicsPosition(sceneId, hccdd.carPosition)

	return pos, rot
end

function HomeLandUtils.getCampCarEntId(uid)
	return string.format("campCar-%s", uid)
end

function HomeLandUtils.getCampCarEntity(uid)
	local entId = HomeLandUtils.getCampCarEntId(uid)

	return entId and pg.getEntity(entId)
end

function HomeLandUtils.getCarPetPointId(carTmplId)
	return HomeCampCarData[carTmplId] and HomeCampCarData[carTmplId].createPetPointId or 0
end

function HomeLandUtils.getCarPetMaxCount(carEnt)
	return (HomelandConfigData.initCarPetCount or 1) + (carEnt.petExtraNum or 0)
end

function HomeLandUtils.getCarDispatchReward(carEnt, specDispId, specCampId)
	local staticId = specCampId

	if not staticId or staticId == 0 then
		staticId = carEnt.dispatchInfo and carEnt.dispatchInfo.campId
	end

	if not staticId or staticId == 0 then
		staticId = carEnt.space and carEnt.space.staticId
	end

	local dispId = specDispId or carEnt.dispatchInfo and carEnt.dispatchInfo.dispId
	local hcdd = HomeCampData[staticId]
	local reward = hcdd and hcdd.rewards and hcdd.rewards[dispId]
	local multiples = #carEnt.petIds

	return reward, multiples
end

function HomeLandUtils.getCarDispatchPreviewRewardItemIds(carEnt)
	local staticId = carEnt.space and carEnt.space.staticId
	local hcdd = HomeCampData[staticId]

	return hcdd and hcdd.rewardItemList or {}
end

function HomeLandUtils.getCarDispatchBelongTypeRewardInfo(carEnt, dispatchId)
	local staticId = carEnt and carEnt.space and carEnt.space.staticId
	local hcdd = HomeCampData[staticId]
	local dropId = hcdd and hcdd.rewards and hcdd.rewards[dispatchId] or 0
	local itemDescKey = hcdd["rewardDes" .. dispatchId] or ""

	return {
		dropId = dropId,
		itemDescKey = itemDescKey
	}
end

function HomeLandUtils.getHomeSpace(ent)
	local space = ent.spaceType and ent or ent.space

	if not space then
		return nil
	elseif space.spaceType and Utils.isHomeland(space.spaceType) then
		return space
	elseif space.spaceType and Utils.isHomeCamp(space.spaceType) then
		return space
	end
end

function HomeLandUtils.getHomeEntity(ent, uid)
	local space = ent.spaceType and ent or ent.space

	if not space then
		return nil
	elseif space.spaceType and Utils.isHomeland(space.spaceType) then
		return space
	elseif space.spaceType and Utils.isHomeCamp(space.spaceType) then
		if ent.actorType and Utils.isCampCar(ent) then
			return ent
		else
			uid = uid or Utils.isPlayer(ent) and ent.uid or ent.ownerUid

			return HomeLandUtils.getCampCarEntity(uid)
		end
	end
end

function HomeLandUtils.getVisitorRecordCount()
	return HomelandConfigData.visitorRecordCount or 3
end

function HomeLandUtils.getCampSpaceKey(serverId, staticId, lineId)
	local sceneId = HomeLandUtils.getHomeCampSceneId(staticId) or 0

	return Utils.getSpaceInstanceServiceKey(serverId, "0", sceneId, lineId)
end

function HomeLandUtils.getCampLineId(spaceKey)
	local serverId, uid, sceneId, lineId = Utils.parseSpaceInstanceServiceKey(spaceKey)

	return lineId and tonumber(lineId) or 0
end

function HomeLandUtils.isHomeCampManager()
	local campInfo = pg.me:getPlayerHomeCampInfo()
	local campLineInfo = campInfo.lineInfo

	if not campLineInfo then
		return false
	end

	return pg.me.uid == campLineInfo.ownerUid
end

function HomeLandUtils.getCarGroupOrnamentCount()
	return pg.me:getCarGroupOrnamentCount()
end

function HomeLandUtils.isInHomeOrCamp()
	local space = pg.me and pg.me.space

	if not space then
		return false
	end

	local spaceType = space.spaceType

	return Utils.isHomeland(spaceType) or Utils.isHomeCamp(spaceType)
end

function HomeLandUtils.getHomeCarInfo()
	local homeCarInfo = pg.me.homeBasicInfo:getRawTable() or {}
	local curCampStaticId = pg.me.curCampStaticId
	local curCampLineId = pg.me.curCampLineId
	local campInfo = pg.me:getPlayerHomeCampInfo()
	local modelLevel = HomeLandUtils.getHomeCarModelLevel(homeCarInfo.level)
	local carCompsLevel = homeCarInfo.carCompsLevel or {}
	local info = {
		level = homeCarInfo.level or 1,
		upgradeEndTs = homeCarInfo.upgradeEndTs or 0,
		modelLevel = modelLevel,
		name = homeCarInfo.name or "",
		carCompsLevel = carCompsLevel,
		carShapeInfo = homeCarInfo.carShapeInfo,
		curCampStaticId = curCampStaticId,
		curCampLineId = curCampLineId,
		displayCode = campInfo.lineInfo and campInfo.lineInfo.displayCode
	}

	return info
end

function HomeLandUtils.isHomeCarComponentDefaultUnlock(tabId)
	local compIdUpgradeInfo = HomeCarComponentUpgradeData[tabId] or {}
	local subInfo = compIdUpgradeInfo[1] or {}

	return subInfo.defaultUnlock == 1
end

function HomeLandUtils.getHomeCarModelLevel(level)
	local level = level or 1
	local carUpgradeInfo = HomeCarUpgradeData[level] or {}

	return carUpgradeInfo.carModelLevel or 1
end

function HomeLandUtils.getHomeCarResInfo(partValue, modelLevel)
	if not partValue then
		return
	end

	modelLevel = modelLevel or 0

	local partTable = HomeCarModifyModelData[partValue]

	if partTable then
		local partInfo = partTable[modelLevel]

		partInfo = partInfo or partTable[0]

		return partInfo
	end
end

function HomeLandUtils.getHomeCarDecorationRes(level, floor)
	if not level or not level then
		return
	end

	local resInfo = HomeCarInternalModelData[level] or {}

	if floor == 1 then
		return resInfo.res1
	elseif floor == 2 then
		return resInfo.res2
	end
end

function HomeLandUtils.getHomeCarComponentInfo(tabId, level)
	local compIdBaseInfo = HomeCarComponentData[tabId]
	local compIdUpgradeInfo = HomeCarComponentUpgradeData[tabId] or {}
	local levelInfo = compIdUpgradeInfo[level]

	if compIdBaseInfo and levelInfo then
		local compName = pg.getLocalizationText(compIdBaseInfo.name)

		if pg.game.setting:getShowDebugId() then
			compName = compName .. " - " .. tabId
		end

		local info = {
			name = compName,
			detailInfo = levelInfo.levelDes,
			unlockItem = levelInfo.unlockItem or {},
			unlockCost = levelInfo.unlockCost,
			upgradeConditionsDes1 = levelInfo.upgradeConditionsDes1,
			upgradeConditions1 = levelInfo.upgradeConditions1,
			source1 = levelInfo.source1,
			upgradeConditionsDes2 = levelInfo.upgradeConditionsDes2,
			upgradeConditions2 = levelInfo.upgradeConditions2,
			source2 = levelInfo.source2,
			upgradeConditionsDes3 = levelInfo.upgradeConditionsDes3,
			upgradeConditions3 = levelInfo.upgradeConditions3,
			source3 = levelInfo.source3,
			functionUnlockDes = levelInfo.functionUnlockDes,
			carModuleResId = levelInfo.carModuleResId,
			minShowCarLevel = levelInfo.minShowCarLevel or 1,
			levelId = level,
			tabId = tabId,
			icon = compIdBaseInfo.partIcon,
			partTypeId = compIdBaseInfo.partTypeId,
			homeLevel = compIdBaseInfo.homeLevel,
			attachId = compIdBaseInfo.attachId,
			floor = compIdBaseInfo.floor
		}

		return info
	end

	return nil
end

function HomeLandUtils.getHomeCarCanUpgrade(data, triggerMap)
	if not data or not triggerMap then
		return false
	end

	for i = 1, 5 do
		local conditionId = data["upgradeConditions" .. i]

		if conditionId and conditionId > 0 and not triggerMap:isCompleteOrMeetCondition(conditionId) then
			return false, i, conditionId
		end
	end

	return true
end

function HomeLandUtils.homeOperationFinished(entity, ornamentId)
	if entity.space then
		if ornamentId == nil and entity.allocationInfo then
			ornamentId = entity.allocationInfo.ornamentId or 0
		end

		if entity.allocationInfo and entity.allocationInfo.opId == Const.HOMELAND_FACILITY_OP_TYPE.SPECIAL_AI_ACTION then
			entity:onSpecialPetActionFinished()
		end

		entity.space:homeOperationFinished(entity.id, ornamentId)
	end
end

function HomeLandUtils.homeLeisureFinished(entity, revision)
	if entity.space then
		entity:onLeisurePetActionFinished(revision)
		entity.space:homeLeisureFinished(entity.id, revision)
	end
end

function HomeLandUtils.tryMountHomeLeisureRide(entity, vehicleActorId, seatIndex, revision)
	if entity.space then
		entity.space:tryMountHomeLeisureRide(entity.id, vehicleActorId, seatIndex, revision)
	end
end

local function getHomeVehicleEntity(vehicleId)
	if vehicleId == nil then
		return nil
	end

	local entity = pg.getEntity(vehicleId)
	local numericId = tonumber(vehicleId)

	if not entity and numericId and pg.getEntityByActorId then
		entity = pg.getEntityByActorId(numericId)
	end

	if not entity and pg.me and pg.me.space and pg.me.space.getServerEntityByOrnamentId then
		entity = pg.me.space:getServerEntityByOrnamentId(numericId or vehicleId)
	end

	if not entity and pg.game and pg.game.home and pg.game.home.getHomeEntity then
		entity = pg.game.home:getHomeEntity(numericId or vehicleId)
	end

	return entity
end

function HomeLandUtils.getHomeVehicleSeatWorldPositionMap(vehicleId, attachType)
	local vehicle = getHomeVehicleEntity(vehicleId)

	if not vehicle then
		return {}, string.format("home vehicle not found, vehicleId=%s", tostring(vehicleId))
	end

	if type(vehicle.getSeatWorldPositionMap) ~= "function" then
		return {}, string.format("seat world position resolver unavailable, vehicleId=%s", tostring(vehicleId))
	end

	return vehicle:getSeatWorldPositionMap(attachType or "pet")
end

function HomeLandUtils.getHomePettingLeisureRevision(playerEntity, petEntity)
	local space = petEntity and petEntity.space

	if not space or not playerEntity.isMainPlayer or playerEntity.id ~= space.homeLandOwnerPlayerId or not Utils.isHomePet(petEntity) then
		return nil
	end

	local leisureState = space.leisureState
	local leisureInfo = leisureState and leisureState[petEntity.id]
	local leisureConfig = leisureInfo and HomeLeisureBehaviorData[leisureInfo.leisureId]

	if leisureConfig and leisureConfig.leisureType == Const.HOME_LEISURE_TYPE.PETTING then
		return leisureInfo.revision
	end
end

function HomeLandUtils.tryFinishHomePettingLeisure(playerEntity, petEntity, startSpace, revision)
	if not revision or petEntity.space ~= startSpace or not playerEntity.isMainPlayer or playerEntity.id ~= startSpace.homeLandOwnerPlayerId or not Utils.isHomePet(petEntity) then
		return
	end

	local leisureState = startSpace.leisureState
	local leisureInfo = leisureState and leisureState[petEntity.id]
	local leisureConfig = leisureInfo and HomeLeisureBehaviorData[leisureInfo.leisureId]

	if leisureInfo and leisureInfo.revision == revision and leisureConfig and leisureConfig.leisureType == Const.HOME_LEISURE_TYPE.PETTING then
		HomeLandUtils.homeLeisureFinished(petEntity, revision)
	end
end

function HomeLandUtils.getCampAddOnIds(space)
	local carCreatedMap = space.campCarCreatedMap

	if not carCreatedMap or not next(carCreatedMap) then
		return {}
	end

	local addOnIdSet = {}

	for uid, entId in pairs(carCreatedMap) do
		local carEnt = pg.getEntity(entId)

		if carEnt and carEnt.ornament then
			for _, ornamentInfo in pairs(carEnt.ornament) do
				local hodd = HomeObjectData[ornamentInfo.homeId]

				if hodd and hodd.addOnId and hodd.addOnId > 0 then
					addOnIdSet[hodd.addOnId] = true
				end
			end
		end
	end

	return lume.keys(addOnIdSet)
end

function HomeLandUtils.getCampAddOnIdsByOwner(space, ownerUid)
	if not space or not ownerUid or ownerUid == "" or not space.getCampCar then
		return {}
	end

	local carEnt = space:getCampCar(ownerUid)

	if not carEnt or not carEnt.ornament then
		return {}
	end

	local addOnIdSet = {}

	for _, ornamentInfo in pairs(carEnt.ornament) do
		local hodd = HomeObjectData[ornamentInfo.homeId]

		if hodd and hodd.addOnId and hodd.addOnId > 0 then
			addOnIdSet[hodd.addOnId] = true
		end
	end

	return lume.keys(addOnIdSet)
end

function HomeLandUtils.getCampAddOnIdsByOwnerFromCreatedMap(space, ownerUid)
	if not space or not ownerUid or ownerUid == "" then
		return {}
	end

	local carCreatedMap = space.campCarCreatedMap

	if not carCreatedMap or not next(carCreatedMap) then
		return {}
	end

	local carEntId = carCreatedMap[ownerUid] or carCreatedMap[tostring(ownerUid)]
	local carEnt = carEntId and pg.getEntity(carEntId)

	if not carEnt or not carEnt.ornament then
		return {}
	end

	local addOnIdSet = {}

	for _, ornamentInfo in pairs(carEnt.ornament) do
		local hodd = HomeObjectData[ornamentInfo.homeId]

		if hodd and hodd.addOnId and hodd.addOnId > 0 then
			addOnIdSet[hodd.addOnId] = true
		end
	end

	return lume.keys(addOnIdSet)
end

function HomeLandUtils.getCampAddOnOwnerNameFromCreatedMap(space, ownerUid)
	if not ownerUid or ownerUid == "" then
		return ""
	end

	local carEnt
	local carCreatedMap = space and space.campCarCreatedMap

	if carCreatedMap then
		local carEntId = carCreatedMap[ownerUid] or carCreatedMap[tostring(ownerUid)]

		carEnt = carEntId and pg.getEntity(carEntId)
	end

	if carEnt and carEnt.basicInfo and not string.isNilOrEmpty(carEnt.basicInfo.name) then
		return carEnt.basicInfo.name
	end

	if pg.game and pg.game.homeCar and pg.game.homeCar.getHomeCarGroup then
		local carGroup = pg.game.homeCar:getHomeCarGroup(ownerUid) or pg.game.homeCar:getHomeCarGroup(tostring(ownerUid))

		if carGroup and carGroup.basicInfo and not string.isNilOrEmpty(carGroup.basicInfo.name) then
			return carGroup.basicInfo.name
		end
	end

	return ""
end

function HomeLandUtils.checkHomeObjectCanAttach(homeTemplateId)
	local homeBuildData = HomeBuildData[homeTemplateId]

	if not homeBuildData then
		return false
	end

	if not homeBuildData.attachRoots then
		return false
	end

	return true
end

function HomeLandUtils.checkHomeObjectCanBeAttach(homeTemplateId)
	local homeBuildData = HomeBuildData[homeTemplateId]

	if not homeBuildData then
		return false
	end

	if not homeBuildData.attachPlanes then
		return false
	end

	return true
end

function HomeLandUtils.isAngleMultipleOf(angle, period, tolerance)
	local LINK_ANGLE_TOLERANCE = 0.5

	tolerance = tolerance or LINK_ANGLE_TOLERANCE

	local mod = Utils.normalizeAngle(angle) % period

	return mod <= tolerance or mod >= period - tolerance
end

function HomeLandUtils.checkHomeObjectLinkPosValid(position, rotation, scale)
	if scale and (scale[1] ~= 1 or scale[2] ~= 1 or scale[3] ~= 1) then
		return false
	end

	Vector3.enableCreateFromCache()

	local eulerAngles = rotation.eulerAngles
	local eulerX, eulerY, eulerZ = eulerAngles.x, eulerAngles.y, eulerAngles.z

	Vector3.disableCreateFromCache()

	if not HomeLandUtils.isAngleMultipleOf(eulerX, 360) or not HomeLandUtils.isAngleMultipleOf(eulerZ, 360) then
		return false
	end

	if not HomeLandUtils.isAngleMultipleOf(eulerY, 90) then
		return false
	end

	return true
end

function HomeLandUtils.checkHomeObjectCanLink(homeTemplateId)
	local homeBuildData = HomeBuildData[homeTemplateId]

	if not homeBuildData or not homeBuildData.linkTemplateId then
		return false
	end

	local linkData = HomeBuildLinkData[homeBuildData.linkTemplateId]

	if not linkData or not linkData.linkSockets then
		return false
	end

	return true
end

function HomeLandUtils.addFastFindAttachExtraInfo(ent, extraInfo)
	local homeTemplateId = ent.homeTemplateId

	extraInfo.canAttach = HomeLandUtils.checkHomeObjectCanBeAttach(homeTemplateId)
	extraInfo.canLink = HomeLandUtils.checkHomeObjectCanLink(homeTemplateId)

	local homeObjectInfo = HomeObjectData[homeTemplateId]

	if homeObjectInfo then
		extraInfo.height = homeObjectInfo.modelHeight
	end

	if ent.getScale then
		extraInfo.scale = ent:getScale()
	end
end

HomeLandUtils.HOME_FLOOR_SUB_TYPE = 401
HomeLandUtils.HOME_FLOOR_LIFT_HEIGHT = 0.12
HomeLandUtils.HOME_FLOOR_LIFT_QUERY_TOLERANCE = 0.5
HomeLandUtils.HOME_FLOOR_LIFT_EPSILON = 0.005

function HomeLandUtils.checkHomeObjectIsFloor(homeTemplateId)
	local homeObjectInfo = HomeObjectData[homeTemplateId]

	if not homeObjectInfo or homeObjectInfo.subType ~= HomeLandUtils.HOME_FLOOR_SUB_TYPE then
		return false
	end

	return homeObjectInfo.disableFloorBase ~= 1
end

function HomeLandUtils.checkHomeObjectFloorLift(homeTemplateId)
	local homeObjectInfo = HomeObjectData[homeTemplateId]

	if not homeObjectInfo or not homeObjectInfo.facilityId then
		return false
	end

	return homeObjectInfo.disableFloorLift ~= 1
end

local _homeFacilityPosFields = {
	"boardPosition",
	"ornamentCenter",
	"carPosition",
	"carPosition"
}

function HomeLandUtils.getHomeFacilityPointPose(playerEnt, facilityParam)
	playerEnt = playerEnt or pg.me

	if not playerEnt or not playerEnt.space then
		return false
	end

	facilityParam = tonumber(facilityParam) or 0

	if facilityParam < 1 or facilityParam > 4 then
		return false
	end

	local spaceType = playerEnt.space.spaceType
	local sceneId = SceneUtils.getMainSceneId(playerEnt.space.sceneId)
	local posId

	if Utils.isHomeCamp(spaceType) then
		local curCampCarId = playerEnt.getSelfHomeCampPlaceId and playerEnt:getSelfHomeCampPlaceId()

		if not curCampCarId or curCampCarId == 0 then
			return false
		end

		local campCarData = HomeCampCarData[curCampCarId]

		if not campCarData then
			return false
		end

		posId = campCarData[_homeFacilityPosFields[facilityParam]]
	elseif Utils.isHomeland(spaceType) then
		if facilityParam ~= 3 and facilityParam ~= 4 then
			return false
		end

		posId = HomeLandUtils.getHomelandCarPosition()
	else
		return false
	end

	if not posId then
		return false
	end

	local pos, rot = SceneUtils.getCommonBasicsPosition(sceneId, posId)

	if not pos then
		return false
	end

	if facilityParam == 4 then
		local offsetPos = HomelandConfigData.carInteractOffset or Const.HOME_CAMP_CAR_INTERACT_OFFSET

		pos = pos + rot:MulVec3(Vector3(offsetPos[1], offsetPos[2], offsetPos[3]))
	end

	return true, pos, rot or Quaternion.identity
end

function HomeLandUtils.getHomeFacilityEntity(playerEnt, facilityParam)
	playerEnt = playerEnt or pg.me

	if not playerEnt or not playerEnt.space then
		return nil
	end

	facilityParam = tonumber(facilityParam) or 0

	if facilityParam < 5 then
		return nil
	end

	local carGroup = pg.game.homeCar and pg.game.homeCar:getHomeCarGroup(playerEnt.uid)

	if carGroup and carGroup.ornamentEntities then
		for _, ent in pairs(carGroup.ornamentEntities) do
			if ent and ent.homeTemplateId == facilityParam then
				return ent
			end
		end
	end

	if pg.game.home and pg.game.home.homeEntities then
		for _, ent in pairs(pg.game.home.homeEntities) do
			if ent and ent.homeTemplateId == facilityParam then
				return ent
			end
		end
	end

	return nil
end

function HomeLandUtils.getOrnamentAreaIds(templateId)
	local homeObjectInfo = HomeObjectData[templateId]

	if homeObjectInfo and homeObjectInfo.homelandAreaIds then
		return homeObjectInfo.homelandAreaIds
	end

	return {
		0
	}
end

function HomeLandUtils.isOrnamentAreaAllowed(templateId, areaId)
	local areaIds = HomeLandUtils.getOrnamentAreaIds(templateId)

	for _, id in ipairs(areaIds) do
		if id == areaId then
			return true
		end
	end

	return false
end

function HomeLandUtils.isTypeAreaAllowed(typeId, areaId)
	local HomeTypeData = require("Data.home_type_data")
	local typeInfo = HomeTypeData[typeId]
	local areaIds = typeInfo and typeInfo.homelandAreaIds

	if not areaIds or next(areaIds) == nil then
		return true
	end

	for _, id in ipairs(areaIds) do
		if id == areaId then
			return true
		end
	end

	return false
end

function HomeLandUtils.getHomelandZoneUnlockData()
	if CommonSwitch.HOMELAND_NEW_MAP then
		return NewHomelandZoneUnlockConfigData
	end

	return HomelandZoneUnlockConfigData
end

function HomeLandUtils.getHomelandTrashData()
	if CommonSwitch.HOMELAND_NEW_MAP then
		return NewHomeTrashData
	end

	return HomeTrashData
end

function HomeLandUtils.getHomelandBreakPoints1()
	if CommonSwitch.HOMELAND_NEW_MAP then
		return HomelandConfigData.newhomePetBreakPoints1
	end

	return HomelandConfigData.homePetBreakPoints1
end

function HomeLandUtils.getHomelandBreakPoints2()
	if CommonSwitch.HOMELAND_NEW_MAP then
		return HomelandConfigData.newhomePetBreakPoints2
	end

	return HomelandConfigData.homePetBreakPoints2
end

function HomeLandUtils.getHomePetBreakTeleportPoint()
	if CommonSwitch.HOMELAND_NEW_MAP then
		return HomelandConfigData.newhomePetBreakTeleportPoint
	end

	return HomelandConfigData.homePetBreakTeleportPoint
end

function HomeLandUtils.getHomePetWelcomePoints()
	if CommonSwitch.HOMELAND_NEW_MAP then
		return HomelandConfigData.newhomePetWelcome
	end

	return HomelandConfigData.homePetWelcome
end

function HomeLandUtils.getHomeRewardBoxId()
	if CommonSwitch.HOMELAND_NEW_MAP then
		return HomelandConfigData.newhomeRewardboxId
	end

	return HomelandConfigData.homeRewardboxId
end

function HomeLandUtils.getTillRewardBoxId()
	if CommonSwitch.HOMELAND_NEW_MAP then
		return HomelandConfigData.newtillRewardboxId
	end

	return HomelandConfigData.tillRewardboxId
end

function HomeLandUtils.getTillGetChestConfig()
	if CommonSwitch.HOMELAND_NEW_MAP then
		return HomelandConfigData.newtillGetChestConfig
	end

	return HomelandConfigData.tillGetChestConfig
end

function HomeLandUtils.getCreatePetPointId(areaId)
	if CommonSwitch.HOMELAND_NEW_MAP then
		if areaId == Const.HOMELAND_AREA_TYPE.BUILD then
			local buildPointId = HomelandConfigData.newjianzaocreatePetPointId

			if buildPointId and buildPointId ~= 0 then
				return buildPointId
			end
		end

		return HomelandConfigData.newcreatePetPointId
	end

	return HomelandConfigData.createPetPointId
end

function HomeLandUtils.getHomelandCarPosition()
	if CommonSwitch.HOMELAND_NEW_MAP then
		return HomelandConfigData.newhomelandCarPosition
	end

	return HomelandConfigData.homelandCarPosition
end

function HomeLandUtils.isHomePetBoxAreaSupported(areaId)
	return Const.HOME_PET_BOX_SUPPORTED_AREA_SET[areaId] == true
end

function HomeLandUtils.canUseHomePetBoxArea(space, areaId)
	if not HomeLandUtils.isHomePetBoxAreaSupported(areaId) then
		return false
	end

	if areaId == Const.HOMELAND_AREA_TYPE.PRODUCE then
		return true
	end

	if not space or not space.unlockArea then
		return false
	end

	return space.unlockArea[areaId] == true
end

function HomeLandUtils.getAreaSeasonEndTime(areaId)
	local homeAreaData = HomelandAreaData[areaId]
	local homeSeason = homeAreaData and homeAreaData.homeSeason

	if not homeSeason then
		return nil
	end

	local seasonData = HomeSeasonData[homeSeason]

	if not seasonData then
		return nil
	end

	return Utils.getConfigTimeOfAreaByData(seasonData.endDayTime, seasonData.endDayTimeRefId)
end

function HomeLandUtils.isAreaOpenInSeason(areaId)
	local homeAreaData = HomelandAreaData[areaId]

	if not homeAreaData then
		return false
	end

	if homeAreaData.noOpen == 1 then
		return false
	end

	local homeSeason = homeAreaData.homeSeason

	if not homeSeason then
		return true
	end

	local seasonData = HomeSeasonData[homeSeason]

	if not seasonData or seasonData.seasonalPlotsEnable ~= 1 then
		return false
	end

	local startTime = Utils.getConfigTimeOfAreaByData(seasonData.startDayTime, seasonData.startDayTimeRefId)
	local endTime = Utils.getConfigTimeOfAreaByData(seasonData.endDayTime, seasonData.endDayTimeRefId)

	if not startTime or not endTime then
		return false
	end

	local now = Time.getSecond()

	return startTime <= now and now <= endTime
end

function HomeLandUtils.isAreaUnlock(playerEnt, areaId)
	if not playerEnt then
		return false
	end

	local homeAreaData = HomelandAreaData[areaId]

	if not homeAreaData then
		return true
	end

	if homeAreaData.isUnlock ~= 1 and homeAreaData.unlockCondition and homeAreaData.unlockCondition > 0 and not playerEnt.triggerMap:isCompleteOrMeetCondition(homeAreaData.unlockCondition) then
		return false
	end

	local homeSeason = homeAreaData.homeSeason

	if homeSeason then
		local seasonData = HomeSeasonData[homeSeason]
		local seasonCon = seasonData and seasonData.seasonalPlotsUnlockCon

		if seasonCon and not playerEnt.triggerMap:isCompleteOrMeetCondition(seasonCon) then
			return false
		end
	end

	return true
end

function HomeLandUtils.canResetToPortal(space, pointId)
	for areaId, areaData in pairs(HomelandAreaData) do
		if areaData.teleportPos == pointId then
			if areaData.noOpen == 1 then
				return false
			end

			if areaData.isUnlock == 1 then
				return true
			end

			return space.unlockArea ~= nil and space.unlockArea[areaId] == true
		end
	end

	return true
end

function HomeLandUtils.resolveHomeHandbookCategoryData(categoryId, seasonId)
	categoryId = tonumber(categoryId)

	if not categoryId then
		return nil, nil, nil
	end

	if seasonId then
		seasonId = tonumber(seasonId)

		local seasonData = HomeHandbookSeasonData[seasonId]

		if seasonData then
			return "season", seasonData, seasonId
		end

		return nil, nil, nil
	end

	local thirdData = HomeHandbookCategoryDetailData.third and HomeHandbookCategoryDetailData.third[categoryId]

	if thirdData then
		return "third", thirdData, nil
	end

	local secondData = HomeHandbookCategoryDetailData.second and HomeHandbookCategoryDetailData.second[categoryId]

	if secondData then
		return "second", secondData, nil
	end

	local firstData = HomeHandbookCategoryDetailData.first and HomeHandbookCategoryDetailData.first[categoryId]

	if firstData then
		return "first", firstData, nil
	end

	return nil, nil, nil
end

function HomeLandUtils.getHomeHandbookCategoryCollectStatus(playerEnt, categoryId, seasonId)
	if not playerEnt or not playerEnt.homeHandbookMap then
		return nil, "invalid player or homeHandbookMap"
	end

	categoryId = tonumber(categoryId)

	if not categoryId then
		return nil, "invalid categoryId"
	end

	local resolvedType, categoryData, actualSeasonId = HomeLandUtils.resolveHomeHandbookCategoryData(categoryId, seasonId)

	if not categoryData then
		return nil, "home handbook category not found"
	end

	local status = {
		missingCount = 0,
		collectedCount = 0,
		categoryType = resolvedType,
		categoryId = categoryId,
		seasonId = actualSeasonId,
		totalCount = #(categoryData.items or {}),
		configCount = categoryData.count or 0,
		configGrade = categoryData.grade or 0,
		collectedItems = {},
		missingItems = {},
		itemDetails = {}
	}

	for _, itemId in ipairs(categoryData.items or EMPTY_TABLE) do
		local itemInfo = playerEnt.homeHandbookMap[itemId]
		local itemCount = itemInfo and (itemInfo.count or 0) or 0
		local isCollected = itemInfo ~= nil

		if isCollected then
			status.collectedCount = status.collectedCount + 1
			status.collectedItems[#status.collectedItems + 1] = itemId
		else
			status.missingCount = status.missingCount + 1
			status.missingItems[#status.missingItems + 1] = itemId
		end

		status.itemDetails[#status.itemDetails + 1] = {
			itemId = itemId,
			collected = isCollected,
			count = itemCount
		}
	end

	return status
end

function HomeLandUtils.getHomelandHandbookCategoryCollectionInfo(playerEnt, categoryId, seasonId)
	local status, err = HomeLandUtils.getHomeHandbookCategoryCollectStatus(playerEnt, categoryId, seasonId)

	if not status then
		return nil
	end

	return {
		categoryId = status.categoryId,
		categoryType = status.categoryType,
		seasonId = status.seasonId,
		totalCount = status.totalCount,
		collectedCount = status.collectedCount,
		missingCount = status.missingCount,
		collectionRate = status.totalCount > 0 and string.format("%.2f%%", status.collectedCount / status.totalCount * 100) or "0%",
		collectedItems = status.collectedItems,
		missingItems = status.missingItems
	}
end

function HomeLandUtils.getCampCarPetComfortValue(petInfo)
	local formulaId = Const.FormulaId.CampCarPetComfort

	if not formulaId or formulaId == 0 then
		return 0
	end

	local formulaData = require("Data.formula_data")[formulaId]

	if not formulaData or type(formulaData.formula) ~= "function" then
		return 0
	end

	petInfo = petInfo or {}

	return tonumber(formulaData.formula(PetData[petInfo.templateId] and PetData[petInfo.templateId].comfortValue or 0, petInfo.label or 0, Utils.getPetFormQualityByTemplateId(petInfo.templateId) or 0, petInfo.propertyScoreStage or 0)) or 0
end

function HomeLandUtils.isHomelandFormulaDrawingUnlocked(player, formulaId)
	local data = HomelandFormulaData[formulaId]

	if not data then
		return false
	end

	local unlockItemId = data.unlockByItemId or 0

	return unlockItemId == 0 or player.unlockedHomelandFormulaMap[formulaId] == true
end

function HomeLandUtils.isHomelandFurnitureDrawingUnlocked(player, itemId)
	local data = HomeObjectData[itemId]

	if not data then
		return false
	end

	local unlockItemId = data.unlockByItemId or 0

	return unlockItemId == 0 or player.unlockedHomelandFurnitureMap[itemId] == true
end

function HomeLandUtils.calcHomeVoucherProgress(info, now)
	if not info then
		return 0
	end

	local progress = math_max(0, info.progress or 0)
	local lastSettleTs = info.lastSettleTs or 0
	local collectLimit = math_max(0, info.collectLimit or 0)
	local duration = math_max(0, now - lastSettleTs)

	if lastSettleTs > 0 and info.active and duration > 0 and (info.produceRate or 0) > 0 and collectLimit > 0 and progress < collectLimit then
		return math_min(collectLimit, progress + duration * info.produceRate)
	end

	return progress
end

function HomeLandUtils.calcHomeVoucherExpectedFullTs(info)
	if not info then
		return 0
	end

	local progress = math_max(0, info.progress or 0)
	local lastSettleTs = info.lastSettleTs or 0
	local collectLimit = math_max(0, info.collectLimit or 0)
	local produceRate = math_max(0, info.produceRate or 0)

	if lastSettleTs <= 0 or not info.active or produceRate <= 0 or collectLimit <= 0 or collectLimit <= progress + HOME_VOUCHER_PROGRESS_EPSILON then
		return 0
	end

	return lastSettleTs + math_ceil((collectLimit - progress) / produceRate)
end

function HomeLandUtils.isHomeVoucherFull(info)
	return info ~= nil and (info.collectLimit or 0) > 0 and (info.progress or 0) + HOME_VOUCHER_PROGRESS_EPSILON >= info.collectLimit
end

function HomeLandUtils.calcHomeVoucherCollectNum(progress)
	return math_floor(math_max(0, progress or 0) + HOME_VOUCHER_PROGRESS_EPSILON)
end

function HomeLandUtils.sortHomeVoucherAppearanceInfo(left, right)
	local leftSort = left.sort or 0
	local rightSort = right.sort or 0

	if leftSort == rightSort then
		return (left.id or 0) < (right.id or 0)
	end

	return leftSort < rightSort
end

function HomeLandUtils._isValidHomeVoucherAppearanceRuleNumber(value)
	return type(value) == "number" and value > -math.huge and value < math.huge
end

function HomeLandUtils.logInvalidHomeVoucherAppearanceRule(id, reason, value)
	local logKey = tostring(id) .. "|" .. reason .. "|" .. tostring(value)

	if HomeLandUtils._loggedInvalidHomeVoucherRuleKeys[logKey] then
		return
	end

	HomeLandUtils._loggedInvalidHomeVoucherRuleKeys[logKey] = true

	local message = "ignore invalid home voucher appearance rule, id=" .. tostring(id) .. ", reason=" .. reason .. ", value=" .. tostring(value)
	local packageInfo = rawget(_G, "package")
	local loggerManager = packageInfo and packageInfo.loaded and packageInfo.loaded["Core.Log.LoggerManager"]

	if loggerManager then
		local success, configLogger = pcall(loggerManager.getLogger, "HomeLandUtils")

		if success and configLogger and configLogger.error then
			success = pcall(configLogger.error, configLogger, "%s", message)

			if success then
				return
			end
		end
	end
end

function HomeLandUtils.getHomeVoucherAppearanceRules()
	local rawRules = HomeWishingStarCollectionData

	if rawRules == nil then
		return EMPTY_TABLE
	end

	if not Utils.isTable(rawRules) then
		HomeLandUtils.logInvalidHomeVoucherAppearanceRule(nil, "rules_not_table", rawRules)

		return EMPTY_TABLE
	end

	local candidates = {}

	for id, rule in pairs(rawRules) do
		local invalidReason, invalidValue

		if not HomeLandUtils._isValidHomeVoucherAppearanceRuleNumber(id) or id <= 0 or id ~= math_floor(id) then
			invalidReason = "invalid_id"
			invalidValue = id
		elseif not Utils.isTable(rule) then
			invalidReason = "rule_not_table"
			invalidValue = rule
		elseif rule.appearanceType ~= HomeLandUtils.HOME_VOUCHER_APPEARANCE_TYPE.FORM_QUALITY and rule.appearanceType ~= HomeLandUtils.HOME_VOUCHER_APPEARANCE_TYPE.SHINY then
			invalidReason = "invalid_appearance_type"
			invalidValue = rule.appearanceType
		elseif not HomeLandUtils._isValidHomeVoucherAppearanceRuleNumber(rule.appearanceValue) or rule.appearanceValue < 0 or rule.appearanceValue ~= math_floor(rule.appearanceValue) then
			invalidReason = "invalid_appearance_value"
			invalidValue = rule.appearanceValue
		elseif rule.appearanceType == HomeLandUtils.HOME_VOUCHER_APPEARANCE_TYPE.SHINY and rule.appearanceValue ~= 0 then
			invalidReason = "invalid_shiny_value"
			invalidValue = rule.appearanceValue
		elseif not HomeLandUtils._isValidHomeVoucherAppearanceRuleNumber(rule.rate) or rule.rate < 0 then
			invalidReason = "invalid_rate"
			invalidValue = rule.rate
		elseif not HomeLandUtils._isValidHomeVoucherAppearanceRuleNumber(rule.sort) then
			invalidReason = "invalid_sort"
			invalidValue = rule.sort
		end

		if invalidReason then
			HomeLandUtils.logInvalidHomeVoucherAppearanceRule(id, invalidReason, invalidValue)
		else
			candidates[#candidates + 1] = {
				id = id,
				appearanceType = rule.appearanceType,
				appearanceValue = rule.appearanceValue,
				rate = rule.rate,
				sort = rule.sort,
				icon = rule.icon,
				iconSmall = rule.iconSmall,
				iconBg = rule.iconBg
			}
		end
	end

	table.sort(candidates, HomeLandUtils.sortHomeVoucherAppearanceInfo)

	local result = {}
	local ruleIdsByAppearance = {}

	for _, rule in ipairs(candidates) do
		local ruleIdsByValue = ruleIdsByAppearance[rule.appearanceType]

		if not ruleIdsByValue then
			ruleIdsByValue = {}
			ruleIdsByAppearance[rule.appearanceType] = ruleIdsByValue
		end

		local existingRuleId = ruleIdsByValue[rule.appearanceValue]

		if existingRuleId then
			HomeLandUtils.logInvalidHomeVoucherAppearanceRule(rule.id, "duplicate_appearance", existingRuleId)
		else
			ruleIdsByValue[rule.appearanceValue] = rule.id
			result[rule.id] = rule
		end
	end

	return result
end

function HomeLandUtils.isHomeVoucherAppearanceRuleMatched(petInfo, rule)
	if not petInfo or not Utils.isTable(rule) then
		return false
	end

	if rule.appearanceType == HomeLandUtils.HOME_VOUCHER_APPEARANCE_TYPE.FORM_QUALITY then
		return Utils.getPetFormQualityByTemplateId(petInfo.templateId) == rule.appearanceValue
	end

	if rule.appearanceType == HomeLandUtils.HOME_VOUCHER_APPEARANCE_TYPE.SHINY then
		return rule.appearanceValue == 0 and Utils.isLabelShiny(petInfo.label)
	end

	return false
end

function HomeLandUtils.getHomeVoucherAppearanceInfos(petInfo)
	local result = {}

	for id, rule in pairs(HomeLandUtils.getHomeVoucherAppearanceRules()) do
		if HomeLandUtils.isHomeVoucherAppearanceRuleMatched(petInfo, rule) then
			result[#result + 1] = {
				id = id,
				appearanceType = rule.appearanceType,
				appearanceValue = rule.appearanceValue,
				rate = rule.rate,
				sort = rule.sort,
				icon = rule.icon,
				iconSmall = rule.iconSmall,
				iconBg = rule.iconBg
			}
		end
	end

	table.sort(result, HomeLandUtils.sortHomeVoucherAppearanceInfo)

	return result
end

function HomeLandUtils.calcHomeVoucherPetOutputPerDay(petInfo)
	local petData = petInfo and PetData[petInfo.templateId]
	local baseOutputPerSecond = math_max(0, petData and petData.homeVoucherProduceRate or 0)
	local baseOutputPerDay = baseOutputPerSecond * HomeLandUtils.HOME_VOUCHER_SECONDS_PER_DAY
	local outputPerDay = baseOutputPerDay
	local appearanceInfos = HomeLandUtils.getHomeVoucherAppearanceInfos(petInfo)

	for _, appearanceInfo in ipairs(appearanceInfos) do
		outputPerDay = outputPerDay * appearanceInfo.rate
	end

	return baseOutputPerDay, outputPerDay, appearanceInfos
end

function HomeLandUtils.calcBuildAreaHomePetVoucherRate(space)
	local petBoxMap = space and space.petBoxMap
	local buildBoxInfo = petBoxMap and petBoxMap[Const.HOMELAND_AREA_TYPE.BUILD]

	if not buildBoxInfo then
		return 0
	end

	local pets = space.pets
	local totalRatePerSecond = 0

	for _, petId in buildBoxInfo:items() do
		local petInfo = pets and pets[petId]

		if petInfo and Utils.checkHomePetStateValid(petInfo, space) then
			local _, outputPerDay = HomeLandUtils.calcHomeVoucherPetOutputPerDay(petInfo)

			totalRatePerSecond = totalRatePerSecond + outputPerDay / HomeLandUtils.HOME_VOUCHER_SECONDS_PER_DAY
		end
	end

	return totalRatePerSecond
end

function HomeLandUtils.calcHomeVoucherProduceRate(space, collectorCount)
	if math_max(0, collectorCount or 0) <= 0 then
		return 0
	end

	return HomeLandUtils.calcBuildAreaHomePetVoucherRate(space)
end

function HomeLandUtils.isHomeVoucherCollectorTemplate(homeTemplateId)
	local collectorHomeId = HomelandConfigData.homeVoucherCollectorHome

	return collectorHomeId ~= nil and homeTemplateId == collectorHomeId
end

function HomeLandUtils.isHomeVoucherCollectorOrnament(ornamentInfo)
	return ornamentInfo ~= nil and HomeLandUtils.isHomeVoucherCollectorTemplate(ornamentInfo.homeId) and ornamentInfo.areaId == Const.HOMELAND_AREA_TYPE.BUILD
end

return HomeLandUtils
