-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetRecommendBatchCarry\\PetRecommendBatchCarryModel.lua

local logger = require("Core.Log.LoggerManager").getLogger("PetRecommendBatchCarryModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local Utils = require("Common.Utils.Utils")
local ItemUtils = require("Common.Utils.ItemUtils")
local PetRecommendBatchCarryModel = Class.LightClass("PetRecommendBatchCarryModel", UIModel)
local PetConfigData = require("Data.pet_config_data")
local DEFAULT_SLOT_COUNT = 6

local function isSameItemPos(actualPos, plannedPos)
	local isActualValid = actualPos and actualPos:isValid() or false
	local isPlannedValid = plannedPos and plannedPos[1] ~= 0 and plannedPos[2] ~= 0 or false

	if not isActualValid or not isPlannedValid then
		return isActualValid == isPlannedValid
	end

	return actualPos:equal(plannedPos[1], plannedPos[2])
end

local RECOMMEND_TYPE_ORDER = {
	0,
	1
}

function PetRecommendBatchCarryModel:getPetRecommendList(petId)
	local petInfo = pg.me:getPetInfo(petId)

	if not petInfo then
		return nil
	end

	local raw = Utils.getRecommendCarrySetList(pg.me, petInfo.petPrototypeId, petInfo) or {}
	local byType = {}

	for _, plan in ipairs(raw) do
		byType[plan.recommendType] = plan
	end

	local existCount = 0

	for _, rt in ipairs(RECOMMEND_TYPE_ORDER) do
		if byType[rt] then
			existCount = existCount + 1
		end
	end

	if existCount == 0 then
		return nil
	end

	local isSingle = existCount == 1
	local result = {}

	for _, rt in ipairs(RECOMMEND_TYPE_ORDER) do
		local plan = byType[rt]

		if plan then
			plan.tIndex = 1

			if isSingle then
				plan.recommendRatio = PetConfigData.PET_RECOMMEND_CARRY_RATIO_1 and 100 or nil
			end

			self:m_preparePlan(plan)

			result[#result + 1] = plan
		end
	end

	return result
end

function PetRecommendBatchCarryModel:m_preparePlan(plan)
	if plan.isApplied then
		local appliedSuits = plan.appliedSuits or {}
		local appliedItemIds = appliedSuits.appliedItemIds or {}

		if appliedItemIds[1] and appliedItemIds[1] ~= 0 then
			plan.carryItemData = {
				id = appliedItemIds[1]
			}
		end

		plan.slotCount = DEFAULT_SLOT_COUNT

		local gemItems = {}

		for slot = 1, DEFAULT_SLOT_COUNT do
			local itemId = appliedItemIds[slot + 1]

			gemItems[slot] = itemId and itemId ~= 0 and {
				id = itemId
			} or false
		end

		plan.gemItemList = gemItems
	else
		if plan.coreCarryPos then
			plan.carryItemData = ItemUtils.getItem(pg.me, plan.coreCarryPos[1], plan.coreCarryPos[2])
		end

		plan.slotCount = DEFAULT_SLOT_COUNT

		local gemItems = {}
		local assistList = plan.assistCarryPosList or {}

		for i = 1, DEFAULT_SLOT_COUNT do
			local pos = assistList[i]

			if pos then
				gemItems[i] = ItemUtils.getItem(pg.me, pos[1], pos[2]) or false
			else
				gemItems[i] = false
			end
		end

		plan.gemItemList = gemItems
	end
end

function PetRecommendBatchCarryModel:isApplied(petId, planData)
	if not petId or not planData then
		return false
	end

	local petInfo = pg.me:getPetInfo(petId)

	if not petInfo then
		return false
	end

	local recommendInfoMap = pg.me.petCarryRecommendInfoMap
	local recommendInfo = recommendInfoMap and recommendInfoMap:getValidRecommendInfo(petId)

	if recommendInfo and recommendInfo.appliedType == planData.recommendType + 1 then
		return true
	end

	local carryPosMap

	if pg.me.tempPets and pg.me.tempPets[petId] == petInfo then
		carryPosMap = pg.me.tempPetCoreCarryPosMap
	elseif pg.me.pets and pg.me.pets[petId] == petInfo then
		carryPosMap = pg.me.petCoreCarryPosMap
	end

	local coreCarryPos = carryPosMap and carryPosMap:getItemPos(petId)

	if not isSameItemPos(coreCarryPos, planData.coreCarryPos) then
		return false
	end

	local coreCarryInfo = petInfo:getCoreCarryInfo()

	if not coreCarryInfo then
		return false
	end

	local actualAssists = coreCarryInfo.assistCarryPosList or {}
	local plannedAssists = planData.assistCarryPosList or {}

	for slot = 1, DEFAULT_SLOT_COUNT do
		if not isSameItemPos(actualAssists[slot], plannedAssists[slot]) then
			return false
		end
	end

	return true
end

function PetRecommendBatchCarryModel:getAppliedItemIds(petId)
	if not petId then
		return {}
	end

	local recommendInfoMap = pg.me.petCarryRecommendInfoMap
	local recommendInfo = recommendInfoMap and recommendInfoMap:getValidRecommendInfo(petId)

	return recommendInfo and recommendInfo.appliedItemIds or {}
end

function PetRecommendBatchCarryModel:checkApplicable(petId, planData)
	if not planData or not planData.coreCarryPos then
		return false
	end

	local plannedCore = planData.coreCarryPos
	local coreItem = ItemUtils.getItem(pg.me, plannedCore[1], plannedCore[2])
	local coreInfo = coreItem and ItemUtils.getPropertyWithType(coreItem)

	if not coreInfo or not coreInfo:isValid() then
		return false
	end

	if coreInfo.ownerPetId ~= "" and coreInfo.ownerPetId ~= petId then
		return false
	end

	local plannedAssists = planData.assistCarryPosList or {}

	for _, assistPos in pairs(plannedAssists) do
		local assistItem = ItemUtils.getItem(pg.me, assistPos[1], assistPos[2])
		local assistInfo = assistItem and ItemUtils.getPropertyWithType(assistItem)

		if not assistInfo or not assistInfo:isValid() then
			return false
		end
	end

	return true
end

return PetRecommendBatchCarryModel
