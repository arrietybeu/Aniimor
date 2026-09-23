-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Homeland\\HomelandPetLeisureManager.lua

local Class = require("Core.Framework.Class")
local lume = require("Core.Common.lume")
local Time = require("Core.Common.Time")
local Const = require("Common.Const.Const")
local NoticeDef = require("Common.NoticeDef")
local Utils = require("Common.Utils.Utils")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local HomeLeisureBehaviorData = require("Data.home_leisure_behavior_data")
local HomeObjectData = require("Data.home_object_data")
local HomelandPetLeisureManager = Class.LightClass("HomelandPetLeisureManager")

function HomelandPetLeisureManager:ctor(space)
	self.space = space
	self.revision = 0
	self.rideVehicleOrnamentIds = {}
	self.leisureAreaIds = {}
	self.nextPetLeisureCooldownCleanupTs = 0

	for petId, leisureInfo in pairs(space.leisureState) do
		self.revision = math.max(self.revision, leisureInfo.revision)
		self.leisureAreaIds[petId] = HomeLandUtils.getHomePetAreaId(space, petId)
	end

	for ornamentId in pairs(space.ornament) do
		self:onRideVehicleOrnamentChanged(ornamentId)
	end
end

function HomelandPetLeisureManager:destroy()
	self.rideVehicleOrnamentIds = nil
	self.leisureAreaIds = nil
	self.nextPetLeisureCooldownCleanupTs = nil
	self.space = nil
end

function HomelandPetLeisureManager.getPetLeisureCooldownKey(petId, leisureId)
	return petId .. ":" .. leisureId
end

function HomelandPetLeisureManager:clearPetLeisureCooldowns(petId)
	for leisureId in pairs(HomeLeisureBehaviorData) do
		local cooldownKey = HomelandPetLeisureManager.getPetLeisureCooldownKey(petId, leisureId)

		self.space.petLeisureCooldowns[cooldownKey] = nil
	end
end

function HomelandPetLeisureManager:cleanupExpiredPetLeisureCooldowns(curTs)
	if curTs < self.nextPetLeisureCooldownCleanupTs then
		return
	end

	self.nextPetLeisureCooldownCleanupTs = curTs + Const.SECONDS_ONE_MINUTE

	local expiredCooldownKeys

	for cooldownKey, cooldownEndTs in pairs(self.space.petLeisureCooldowns) do
		if cooldownEndTs <= curTs then
			expiredCooldownKeys = expiredCooldownKeys or {}
			expiredCooldownKeys[#expiredCooldownKeys + 1] = cooldownKey
		end
	end

	if expiredCooldownKeys then
		for _, cooldownKey in ipairs(expiredCooldownKeys) do
			self.space.petLeisureCooldowns[cooldownKey] = nil
		end
	end
end

function HomelandPetLeisureManager:clearPetLeisureState(petId, curTs)
	local leisureInfo = self.space.leisureState[petId]

	if self.leisureAreaIds then
		self.leisureAreaIds[petId] = nil
	end

	if not leisureInfo then
		return
	end

	local leisureConfig = HomeLeisureBehaviorData[leisureInfo.leisureId]
	local petCooldownKey = HomelandPetLeisureManager.getPetLeisureCooldownKey(petId, leisureInfo.leisureId)

	if leisureConfig and leisureConfig.cd and leisureConfig.cd > 0 then
		self.space.petLeisureCooldowns[petCooldownKey] = (curTs or Time.getSecond()) + leisureConfig.cd
	else
		self.space.petLeisureCooldowns[petCooldownKey] = nil
	end

	if leisureConfig and leisureConfig.leisureType == Const.HOME_LEISURE_TYPE.RIDE then
		local petEnt = pg.getEntity(petId)
		local vehicleEnt = self.space:getServerEntityByOrnamentId(leisureInfo.vehicleOrnamentId)

		if petEnt and vehicleEnt and petEnt.onVehicleActorId == vehicleEnt.actorId then
			petEnt:dismountVehicle()
		end
	end

	self.space.leisureState[petId] = nil
end

function HomelandPetLeisureManager:clearAllPetLeisureState(curTs)
	curTs = curTs or Time.getSecond()

	local petIds = {}

	for petId in pairs(self.space.leisureState) do
		petIds[#petIds + 1] = petId
	end

	for _, petId in ipairs(petIds) do
		self:clearPetLeisureState(petId, curTs)
	end
end

function HomelandPetLeisureManager:clearPettingLeisureState(playFailedAnim)
	for petId in pairs(self.space.pets) do
		local leisureInfo = self.space.leisureState[petId]
		local leisureConfig = leisureInfo and HomeLeisureBehaviorData[leisureInfo.leisureId]

		if leisureConfig and leisureConfig.leisureType == Const.HOME_LEISURE_TYPE.PETTING then
			if playFailedAnim then
				self.space:allClientsMsg("RPC_SC_HomePettingLeisureFailed", petId)
			end

			self:clearPetLeisureState(petId)
		end
	end
end

function HomelandPetLeisureManager:removeRideVehicleOrnament(ornamentId)
	self.rideVehicleOrnamentIds[ornamentId] = nil

	local petIds = {}

	for petId, leisureInfo in pairs(self.space.leisureState) do
		if leisureInfo.vehicleOrnamentId == ornamentId then
			petIds[#petIds + 1] = petId
		end
	end

	for _, petId in ipairs(petIds) do
		self:clearPetLeisureState(petId)
	end
end

function HomelandPetLeisureManager:onRideVehicleOrnamentChanged(ornamentId, oldTemplateId)
	if oldTemplateId then
		local oldHomeObjectConfig = HomeObjectData[oldTemplateId]

		if not oldHomeObjectConfig then
			self.space.logger:error("onRideVehicleOrnamentChanged missing old home object config, ornamentId=%s, oldTemplateId=%s, %s", ornamentId, oldTemplateId, self.space:repr())
			self:removeRideVehicleOrnament(ornamentId)
		elseif oldHomeObjectConfig.subEntType == Const.HomelandEntSubType.Vehicle or oldHomeObjectConfig.subEntType == Const.HomelandEntSubType.FacilityVehicle then
			self:removeRideVehicleOrnament(ornamentId)
		end
	end

	local ornamentInfo = self.space.ornament[ornamentId]

	if not ornamentInfo then
		self.rideVehicleOrnamentIds[ornamentId] = nil

		return
	end

	local homeObjectConfig = HomeObjectData[ornamentInfo.homeId]

	if not homeObjectConfig then
		self.space.logger:error("onRideVehicleOrnamentChanged missing home object config, ornamentId=%s, homeId=%s, %s", ornamentId, tostring(ornamentInfo.homeId), self.space:repr())
		self:removeRideVehicleOrnament(ornamentId)

		return
	end

	local subEntType = homeObjectConfig.subEntType

	if subEntType == Const.HomelandEntSubType.Vehicle then
		self.rideVehicleOrnamentIds[ornamentId] = true
	else
		self.rideVehicleOrnamentIds[ornamentId] = nil
	end
end

function HomelandPetLeisureManager:onRideVehiclePositionChanged(ornamentId)
	if not self.rideVehicleOrnamentIds[ornamentId] then
		return
	end

	local petIds = {}

	for petId, leisureInfo in pairs(self.space.leisureState) do
		if leisureInfo.vehicleOrnamentId == ornamentId then
			petIds[#petIds + 1] = petId
		end
	end

	for _, petId in ipairs(petIds) do
		self:clearPetLeisureState(petId)
	end
end

function HomelandPetLeisureManager:onHomeLeisureFinished(petId, revision)
	local leisureInfo = self.space.leisureState[petId]

	if not leisureInfo or leisureInfo.revision ~= revision then
		return false
	end

	self:clearPetLeisureState(petId)

	return true
end

function HomelandPetLeisureManager:isRideVehicleValid(vehicleEnt, petAreaId)
	return vehicleEnt ~= nil and vehicleEnt.space == self.space and petAreaId ~= nil and vehicleEnt.areaId == petAreaId and not vehicleEnt.isHomeFacility
end

function HomelandPetLeisureManager:tryMountRideVehicle(petEnt, vehicleActorId, seatIndex, revision)
	local space = self.space
	local leisureInfo = space.leisureState[petEnt.id]
	local leisureConfig = leisureInfo and HomeLeisureBehaviorData[leisureInfo.leisureId]

	if not leisureInfo or leisureInfo.revision ~= revision or not leisureConfig or leisureConfig.leisureType ~= Const.HOME_LEISURE_TYPE.RIDE then
		return
	end

	local petAreaId = HomeLandUtils.getHomePetAreaId(space, petEnt.id, petEnt)
	local vehicleEnt = space:getServerEntityByOrnamentId(leisureInfo.vehicleOrnamentId)

	if petEnt.space ~= space or petEnt.onVehicleActorId ~= 0 or not self:isRideVehicleValid(vehicleEnt, petAreaId) or vehicleEnt.actorId ~= vehicleActorId or leisureInfo.vehicleSeatIndex ~= seatIndex then
		return
	end

	vehicleEnt:onEntityMount(petEnt, seatIndex)
end

function HomelandPetLeisureManager:isOwnerPlayerInPetArea(petAreaId)
	local ownerPlayer = self.space.ownerPlayer

	if not ownerPlayer or petAreaId == nil then
		return false
	end

	local areaInfo = self.space.areaInfoDict[petAreaId]

	if not areaInfo then
		return false
	end

	local areaRange = self.space:getAreaRange(petAreaId)

	if not areaRange then
		return false
	end

	local localPosition = areaInfo.baseRotation:Inverse():MulVec3(ownerPlayer:getPosition() - areaInfo.basePosition)

	return areaRange[1] <= localPosition.x and localPosition.x <= areaRange[2] and areaRange[3] <= localPosition.z and localPosition.z <= areaRange[4]
end

function HomelandPetLeisureManager:checkAndUpdatePetLeisure()
	local space = self.space
	local curTs = Time.getSecond()

	self:cleanupExpiredPetLeisureCooldowns(curTs)

	local isLeisureAreaSnapshotMigration = self.leisureAreaIds == nil

	if isLeisureAreaSnapshotMigration then
		self.leisureAreaIds = {}
		self.rideVehicleOrnamentIds = {}

		for ornamentId in pairs(space.ornament) do
			self:onRideVehicleOrnamentChanged(ornamentId)
		end
	end

	local petsToAllocateLeisure = {}
	local rideSeatReservations = {}
	local leisurePetCounts = {}
	local petAreaIds = {}
	local ownerInAreaCache = {}

	for petId, petInfo in pairs(space.pets) do
		local leisureInfo = space.leisureState[petId]
		local allocationInfo = space.allocation[petId]
		local petEnt = pg.getEntity(petId)
		local petAreaId = HomeLandUtils.getHomePetAreaId(space, petId, petEnt)

		petAreaIds[petId] = petAreaId

		local canEnterLeisure = petEnt ~= nil and petEnt.space == space and petAreaId ~= nil and Utils.checkHomePetStateValid(petInfo, space) and (not allocationInfo or allocationInfo.opId == Const.HOMELAND_FACILITY_OP_TYPE.NONE) and not petEnt:attaching()
		local leisureConfig = leisureInfo and HomeLeisureBehaviorData[leisureInfo.leisureId]
		local leisureType = leisureConfig and leisureConfig.leisureType
		local shouldPlayPettingSad = false
		local areaSnapshotMatched = self.leisureAreaIds[petId] == petAreaId

		if isLeisureAreaSnapshotMigration and self.leisureAreaIds[petId] == nil and leisureType == Const.HOME_LEISURE_TYPE.RIDE then
			areaSnapshotMatched = true
		end

		local isActive = canEnterLeisure and leisureInfo and leisureConfig ~= nil and areaSnapshotMatched

		if isActive and leisureType == Const.HOME_LEISURE_TYPE.RIDE then
			local ornamentId = leisureInfo.vehicleOrnamentId
			local seatIndex = leisureInfo.vehicleSeatIndex
			local vehicleEnt = space:getServerEntityByOrnamentId(ornamentId)
			local isRideSeatValid = self:isRideVehicleValid(vehicleEnt, petAreaId) and vehicleEnt.checkSeatForbidden ~= nil

			if isRideSeatValid then
				if petEnt.onVehicleActorId == vehicleEnt.actorId then
					local mountedSeatIndex = vehicleEnt:getSeatIndex(petEnt.actorId)

					if mountedSeatIndex > 0 then
						isRideSeatValid = Time.secondCache < petEnt.rideStartTime + leisureConfig.time

						if isRideSeatValid then
							seatIndex = mountedSeatIndex

							if leisureInfo.vehicleSeatIndex ~= seatIndex then
								leisureInfo.vehicleSeatIndex = seatIndex
							end
						end
					else
						isRideSeatValid = false
					end
				else
					isRideSeatValid = (petEnt.onVehicleActorId == 0 or false) and curTs < leisureInfo.startTs + Const.HOME_LEISURE_TIMEOUT and seatIndex > 0 and vehicleEnt:checkSeatForbidden(petEnt, seatIndex) == NoticeDef.VEHICLE_MOUNT_SUCCESS
				end
			end

			local reservedSeats = rideSeatReservations[ornamentId]
			local canReserveRideSeat = isRideSeatValid and (not reservedSeats or not reservedSeats[seatIndex])

			if canReserveRideSeat then
				if not reservedSeats then
					reservedSeats = {}
					rideSeatReservations[ornamentId] = reservedSeats
				end

				reservedSeats[seatIndex] = petId
			end

			isActive = canReserveRideSeat
		elseif isActive then
			local ownerInPetArea = ownerInAreaCache[petAreaId]

			if leisureType == Const.HOME_LEISURE_TYPE.PETTING and ownerInPetArea == nil then
				ownerInPetArea = self:isOwnerPlayerInPetArea(petAreaId)
				ownerInAreaCache[petAreaId] = ownerInPetArea
			end

			local leisureTimeout = leisureConfig.time or Const.HOME_LEISURE_TIMEOUT

			shouldPlayPettingSad = leisureType == Const.HOME_LEISURE_TYPE.PETTING and (curTs >= leisureInfo.startTs + leisureTimeout or not ownerInPetArea)
			isActive = curTs < leisureInfo.startTs + leisureTimeout and petEnt.onVehicleActorId == 0 and (leisureType ~= Const.HOME_LEISURE_TYPE.PETTING or ownerInPetArea)
		end

		if isActive and isLeisureAreaSnapshotMigration and self.leisureAreaIds[petId] == nil then
			self.leisureAreaIds[petId] = petAreaId
		end

		if isActive then
			leisurePetCounts[leisureInfo.leisureId] = (leisurePetCounts[leisureInfo.leisureId] or 0) + 1
		end

		if leisureInfo and not isActive then
			if shouldPlayPettingSad then
				self.space:allClientsMsg("RPC_SC_HomePettingLeisureFailed", petId)
			end

			self:clearPetLeisureState(petId, curTs)
		end

		if canEnterLeisure and not space.leisureState[petId] and petEnt.onVehicleActorId == 0 then
			petsToAllocateLeisure[petId] = petEnt
		end
	end

	for petId, petEnt in pairs(petsToAllocateLeisure) do
		local petAreaId = petAreaIds[petId]
		local rideOrnamentId, rideSeatIndex, rideTargetDistSqr

		for ornamentId in pairs(self.rideVehicleOrnamentIds) do
			local vehicleEnt = space:getServerEntityByOrnamentId(ornamentId)

			if self:isRideVehicleValid(vehicleEnt, petAreaId) and vehicleEnt.getValidSeatIndex then
				local reservedSeats = rideSeatReservations[ornamentId]
				local availableSeatIndex

				for _, seatIndex in ipairs(vehicleEnt:getValidSeatIndex(petEnt)) do
					if not reservedSeats or not reservedSeats[seatIndex] then
						availableSeatIndex = seatIndex

						break
					end
				end

				if availableSeatIndex then
					local distSqr = Vector3.HoriSqrDistance(petEnt:getPosition(), vehicleEnt:getPosition())

					if not rideTargetDistSqr or distSqr < rideTargetDistSqr then
						rideOrnamentId = ornamentId
						rideSeatIndex = availableSeatIndex
						rideTargetDistSqr = distSqr
					end
				end
			end
		end

		local leisureWeightTable = {}

		for leisureId, config in pairs(HomeLeisureBehaviorData) do
			local eventCooldownEndTs = self.space.leisureEventCooldowns[leisureId]

			if eventCooldownEndTs and (not config.eventCd or config.eventCd <= 0 or eventCooldownEndTs <= curTs) then
				self.space.leisureEventCooldowns[leisureId] = nil
				eventCooldownEndTs = nil
			end

			if eventCooldownEndTs or not config.eventCd or config.eventCd <= 0 then
				self.space.leisureEventAllocationCounts[leisureId] = nil
			end

			local petCooldownKey = HomelandPetLeisureManager.getPetLeisureCooldownKey(petId, leisureId)
			local cooldownEndTs = self.space.petLeisureCooldowns[petCooldownKey]

			if cooldownEndTs and (not config.cd or config.cd <= 0 or cooldownEndTs <= curTs) then
				self.space.petLeisureCooldowns[petCooldownKey] = nil
				cooldownEndTs = nil
			end

			local canSelect = eventCooldownEndTs == nil and cooldownEndTs == nil and (not config.limitPetNum or (leisurePetCounts[leisureId] or 0) < config.limitPetNum)

			if config.leisureType == Const.HOME_LEISURE_TYPE.PETTING then
				if canSelect then
					canSelect = ownerInAreaCache[petAreaId]

					if canSelect == nil then
						canSelect = self:isOwnerPlayerInPetArea(petAreaId)
						ownerInAreaCache[petAreaId] = canSelect
					end
				end
			elseif config.leisureType == Const.HOME_LEISURE_TYPE.RIDE then
				canSelect = canSelect and rideOrnamentId ~= nil
			end

			if canSelect then
				leisureWeightTable[leisureId] = config.weight or 0
			end
		end

		local selectedLeisureId = lume.weightedchoice(leisureWeightTable)

		if selectedLeisureId then
			self.revision = self.revision + 1

			if self.revision > Const.HOME_LEISURE_MAX_REVISION then
				self.revision = 1
			end

			local selectedConfig = HomeLeisureBehaviorData[selectedLeisureId]
			local isRide = selectedConfig.leisureType == Const.HOME_LEISURE_TYPE.RIDE

			space.leisureState[petId] = {
				leisureId = selectedLeisureId,
				vehicleOrnamentId = isRide and rideOrnamentId or 0,
				vehicleSeatIndex = isRide and rideSeatIndex or 0,
				startTs = curTs,
				revision = self.revision
			}
			self.leisureAreaIds[petId] = petAreaId
			leisurePetCounts[selectedLeisureId] = (leisurePetCounts[selectedLeisureId] or 0) + 1

			if selectedConfig.eventCd and selectedConfig.eventCd > 0 then
				local eventAllocationCount = (self.space.leisureEventAllocationCounts[selectedLeisureId] or 0) + 1

				self.space.leisureEventAllocationCounts[selectedLeisureId] = eventAllocationCount

				if not selectedConfig.limitPetNum or eventAllocationCount >= selectedConfig.limitPetNum then
					self.space.leisureEventCooldowns[selectedLeisureId] = curTs + selectedConfig.eventCd
					self.space.leisureEventAllocationCounts[selectedLeisureId] = nil
				end
			end

			if isRide then
				local reservedSeats = rideSeatReservations[rideOrnamentId]

				if not reservedSeats then
					reservedSeats = {}
					rideSeatReservations[rideOrnamentId] = reservedSeats
				end

				reservedSeats[rideSeatIndex] = petId
			end
		end
	end
end

return HomelandPetLeisureManager
