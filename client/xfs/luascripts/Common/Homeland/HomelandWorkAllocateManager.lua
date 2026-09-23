-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Homeland\\HomelandWorkAllocateManager.lua

local Class = require("Core.Framework.Class")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local EventConst = require("Const.EventConst")
local Const = require("Common.Const.Const")
local HomelandFormulaData = require("Data.homeland_formula_data")
local HomelandFacilityData = require("Data.homeland_facility_data")
local Utils = require("Common.Utils.Utils")
local HomeObjectData = require("Data.home_object_data")
local HomelandOperateData = require("Data.homeland_operate_data")
local PetData = require("Data.pet_data")
local HomelandWorkAllocateManager = Class.LightClass("HomelandWorkAllocateManager")

function HomelandWorkAllocateManager:ctor(space)
	self.space = space
	self.tempCalcAllocateResult = {}
end

function HomelandWorkAllocateManager:destroy()
	self.space = nil
end

function HomelandWorkAllocateManager:checkAndAllocateFreePetWork(directToWork)
	local maxPassCount = 1
	local petsIterator = pairs
	local petsIteratorState = self.space.pets

	if directToWork then
		local produceAreaPetIds = {}

		for petId in pairs(self.space.pets) do
			if HomeLandUtils.isHomePetInProduceArea(self.space, petId) then
				produceAreaPetIds[#produceAreaPetIds + 1] = petId
			end
		end

		petsIterator = ipairs
		petsIteratorState = produceAreaPetIds
		maxPassCount = #produceAreaPetIds * #produceAreaPetIds + 1
	end

	for _ = 1, maxPassCount do
		local allocationChanged = false

		for petKey, petValue in petsIterator(petsIteratorState) do
			local petId = directToWork and petValue or petKey
			local petInfo = directToWork and self.space.pets[petId] or petValue
			local petEnt = pg.getEntity(petId)

			if petEnt and (directToWork or HomeLandUtils.isHomePetInProduceArea(self.space, petId)) and petInfo and Utils.checkHomePetStateValid(petInfo, self.space) then
				local currentAllocationInfo = self.space.allocation[petId]

				if not currentAllocationInfo or currentAllocationInfo.opId == 0 then
					local ornamentId, opId, posIndex = self:calcAndGetPetBestFitAllocateWork(petEnt, petId)

					if ornamentId and opId then
						local allocateOpId = Const.HOMELAND_FACILITY_OP_TYPE.MOVING

						if directToWork and opId ~= Const.HOMELAND_FACILITY_OP_TYPE.TRANSPORT then
							allocateOpId = opId
						elseif opId == Const.HOMELAND_FACILITY_OP_TYPE.TRANSPORT then
							allocateOpId = Const.HOMELAND_FACILITY_OP_TYPE.GOTO_TRANSPORT
						end

						if self:doAllocatePetWork(petId, ornamentId, allocateOpId, posIndex) then
							allocationChanged = true
						end
					end
				end
			end
		end

		if not directToWork or not allocationChanged then
			break
		end
	end
end

function HomelandWorkAllocateManager:doAllocatePetWork(petId, ornamentId, opId, posIndex)
	return self.space:allocatePetWork(petId, ornamentId, opId, posIndex)
end

function HomelandWorkAllocateManager:calcAndGetPetBestFitAllocateWork(petEnt, petId, forceRecalc)
	table.clear(self.tempCalcAllocateResult)

	if not HomeLandUtils.isHomePetInProduceArea(self.space, petId) then
		return nil, nil, nil
	end

	local allFacility = self.space.facility
	local currentAllocationInfo = self.space.allocation[petId]

	if not forceRecalc and currentAllocationInfo and currentAllocationInfo.opId ~= 0 then
		return currentAllocationInfo.ornamentId, currentAllocationInfo.opId, currentAllocationInfo.posIndex
	end

	if not petEnt then
		return nil, nil, nil
	end

	local lastOrnamentId = currentAllocationInfo and currentAllocationInfo.ornamentId
	local petInfo = self.space.pets[petId]

	for ornamentId, facilityInfo in pairs(allFacility) do
		local opId, posIndex, isReplace, curWorkCount = HomeLandUtils.getHomePetOperIdAtFacilityPlus(self.space, ornamentId, petId)

		if opId ~= Const.HOMELAND_FACILITY_OP_TYPE.NONE then
			local isOnlyCurrentPet = currentAllocationInfo and currentAllocationInfo.opId ~= 0 and currentAllocationInfo.ornamentId == ornamentId and curWorkCount == 1

			if self:tryUpdateTargetAllocation(petEnt, petInfo, self.tempCalcAllocateResult, ornamentId, opId, isReplace, curWorkCount, lastOrnamentId, isOnlyCurrentPet) then
				self.tempCalcAllocateResult.posIndex = posIndex
				self.tempCalcAllocateResult.ornamentId = ornamentId
				self.tempCalcAllocateResult.opId = opId
			end
		end
	end

	return self.tempCalcAllocateResult.ornamentId, self.tempCalcAllocateResult.opId, self.tempCalcAllocateResult.posIndex
end

function HomelandWorkAllocateManager:tryUpdateTargetAllocation(petEnt, petInfo, targetAllocation, ornamentId, operId, isReplace, curWorkCount, lastOrnamentId, isOnlyCurrentPet)
	local result = false
	local curPriority = targetAllocation.priority or -1
	local curFacilityPriority = targetAllocation.facilityPriority or -1
	local newPriority = 0

	curWorkCount = curWorkCount or 0

	if operId == Const.HOMELAND_FACILITY_OP_TYPE.TRANSPORT then
		newPriority = 100000
	elseif operId == Const.HOMELAND_FACILITY_OP_TYPE.CLEAN then
		newPriority = 200000
	else
		if not isReplace then
			newPriority = newPriority + 10000
		end

		if curWorkCount == 0 or isOnlyCurrentPet then
			newPriority = newPriority + 1000
		end
	end

	if newPriority < curPriority then
		return false
	elseif curPriority < newPriority then
		result = true
	end

	local ornamentInfo = self.space.ornament[ornamentId]
	local facilityId = Utils.getHomeObjectFacilityId(ornamentInfo.homeId)
	local operWeight = self:getOperWeightPriority(operId)
	local curOperWeight = targetAllocation.operWeight or -1

	if not result and operWeight < curOperWeight then
		return false
	elseif curOperWeight < operWeight then
		result = true
	end

	local operPriority = self:getOperPriority(petInfo, operId, facilityId)
	local curOperPriority = targetAllocation.operPriority or -1

	if not result and operPriority < curOperPriority then
		return false
	elseif curOperPriority < operPriority then
		result = true
	end

	local homeFacilityData = HomelandFacilityData[facilityId]
	local newFacilityPriority = homeFacilityData.priority or 0

	if not result and newFacilityPriority < curFacilityPriority then
		return false
	elseif curFacilityPriority < newFacilityPriority then
		result = true
	end

	if not result and lastOrnamentId and lastOrnamentId ~= 0 then
		if ornamentId == lastOrnamentId and targetAllocation.ornamentId ~= lastOrnamentId then
			result = true
		elseif ornamentId ~= lastOrnamentId and targetAllocation.ornamentId == lastOrnamentId then
			return false
		end
	end

	local distSqr

	if not result then
		distSqr = HomeLandUtils.getSqrDistanceByOrnamentId(petEnt, ornamentId)

		local curSqr = targetAllocation.distSqr

		if not curSqr then
			curSqr = HomeLandUtils.getSqrDistanceByOrnamentId(petEnt, targetAllocation.ornamentId)
			targetAllocation.distSqr = curSqr
		end

		if distSqr < curSqr then
			result = true
		end
	end

	if result then
		targetAllocation.priority = newPriority
		targetAllocation.facilityPriority = newFacilityPriority
		targetAllocation.operWeight = operWeight
		targetAllocation.operPriority = operPriority
		targetAllocation.ornamentId = ornamentId
		targetAllocation.opId = operId
		targetAllocation.distSqr = distSqr
	end

	return result
end

function HomelandWorkAllocateManager:getOperWeightPriority(operId)
	local operInfo = HomelandOperateData[operId] or {}

	return operInfo.priority or 0
end

function HomelandWorkAllocateManager:getOperPriority(petInfo, operId, facilityId)
	if operId == Const.HOMELAND_FACILITY_OP_TYPE.CLEAN then
		return 10000
	end

	if operId == Const.HOMELAND_FACILITY_OP_TYPE.TRANSPORT then
		return 5000
	end

	local pdd = PetData[petInfo.templateId] or {}
	local petAbilityLv = pdd.homeAbility[operId] or 0
	local operInfo = HomelandOperateData[operId]
	local needAbilityLv = 0

	if operInfo.homeAbility then
		needAbilityLv = operInfo.homeAbility[2] or 0
	end

	return petAbilityLv * 10 + needAbilityLv
end

function HomelandWorkAllocateManager:onHomeOperationFinished(petId, ornamentId)
	local allocation = self.space.allocation[petId]

	if allocation and allocation.ornamentId ~= 0 and (ornamentId == 0 or allocation.ornamentId == ornamentId) then
		if allocation.opId == Const.HOMELAND_FACILITY_OP_TYPE.TRANSPORT_TO_STORE then
			self.space:deAllocatePetWork(petId, ornamentId)
		elseif allocation.opId == Const.HOMELAND_FACILITY_OP_TYPE.GOTO_TRANSPORT then
			self:doAllocatePetWork(petId, allocation.ornamentId, Const.HOMELAND_FACILITY_OP_TYPE.TRANSPORT, 1)
		elseif allocation.opId == Const.HOMELAND_FACILITY_OP_TYPE.MOVING then
			local opId, posIndex, isReplace, curWorkCount = HomeLandUtils.getHomePetOperIdAtFacilityPlus(self.space, allocation.ornamentId, petId)

			if opId ~= Const.HOMELAND_FACILITY_OP_TYPE.NONE then
				self:doAllocatePetWork(petId, allocation.ornamentId, opId, posIndex)
			else
				self.space:deAllocatePetWork(petId, ornamentId)
			end
		end
	end
end

return HomelandWorkAllocateManager
