-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Homeland\\HomelandWishStarData.lua

local Const = require("Common.Const.Const")
local logger = require("Core.Log.LoggerManager").getLogger("HomelandWishStarData")
local MessageName = require("Const.MessageName")
local Time = require("Core.Common.Time")
local Utils = require("Common.Utils.Utils")
local HomelandConfigData = require("Data.homeland_config_data")
local HomelandWishStarData = {}

HomelandWishStarData.BUILD_AREA_ID = Const.HOMELAND_AREA_TYPE.BUILD
HomelandWishStarData.SECONDS_PER_DAY = 86400
HomelandWishStarData.COLLECT_PENDING_TIMEOUT_SECONDS = 10
HomelandWishStarData.CHANGE_REASON = {
	SERVER_SNAPSHOT = "serverSnapshot",
	PREVIEW_CLEARED = "previewCleared",
	PREVIEW_SNAPSHOT = "previewSnapshot",
	PREVIEW_COLLECTED = "previewCollected",
	RESET = "reset",
	SERVER_COLLECTED = "serverCollected"
}
HomelandWishStarData._serverSnapshot = nil
HomelandWishStarData._previewSnapshot = nil
HomelandWishStarData._serverCollectPending = false
HomelandWishStarData._serverCollectPendingStartTick = nil
HomelandWishStarData._snapshotCacheFrame = nil
HomelandWishStarData._snapshotCacheSpace = nil
HomelandWishStarData._snapshotCache = nil

function HomelandWishStarData._copyPreviewSnapshot(snapshot, allowDefaultTimestamp)
	if type(snapshot) ~= "table" then
		return nil, "snapshot_not_table"
	end

	if not HomelandWishStarData._isValidNonNegativeNumber(snapshot.current) then
		return nil, "invalid_current"
	end

	if not HomelandWishStarData._isValidNonNegativeNumber(snapshot.capacity) then
		return nil, "invalid_capacity"
	end

	if not HomelandWishStarData._isValidNonNegativeNumber(snapshot.efficiency) then
		return nil, "invalid_efficiency"
	end

	local timestamp = snapshot.timestamp

	if timestamp == nil and allowDefaultTimestamp then
		timestamp = Time.getSecond()
	end

	if not HomelandWishStarData._isValidNonNegativeNumber(timestamp) then
		return nil, "invalid_timestamp"
	end

	local petOutputs

	if snapshot.petOutputs ~= nil then
		if type(snapshot.petOutputs) ~= "table" then
			return nil, "pet_outputs_not_table"
		end

		petOutputs = {}

		for petId, outputInfo in pairs(snapshot.petOutputs) do
			if type(outputInfo) ~= "table" then
				return nil, "invalid_pet_output:" .. tostring(petId)
			end

			local copiedOutputInfo = {}

			for key, value in pairs(outputInfo) do
				copiedOutputInfo[key] = value
			end

			petOutputs[petId] = copiedOutputInfo
		end
	end

	local isProducing = snapshot.isProducing

	if isProducing == nil then
		isProducing = snapshot.active
	end

	if isProducing ~= nil and type(isProducing) ~= "boolean" then
		return nil, "invalid_is_producing"
	end

	return {
		current = math.min(snapshot.current, snapshot.capacity),
		capacity = snapshot.capacity,
		efficiency = snapshot.efficiency,
		timestamp = timestamp,
		petOutputs = petOutputs,
		isProducing = isProducing
	}
end

function HomelandWishStarData._invalidateSnapshotCache()
	HomelandWishStarData._snapshotCacheFrame = nil
	HomelandWishStarData._snapshotCacheSpace = nil
	HomelandWishStarData._snapshotCache = nil
end

function HomelandWishStarData._cacheSnapshot(space, snapshot)
	HomelandWishStarData._snapshotCacheFrame = Time.frameCount
	HomelandWishStarData._snapshotCacheSpace = space
	HomelandWishStarData._snapshotCache = snapshot

	return snapshot
end

function HomelandWishStarData._isValidNonNegativeNumber(value)
	return type(value) == "number" and value >= 0 and value < math.huge
end

function HomelandWishStarData._getActiveSnapshot()
	return HomelandWishStarData._serverSnapshot or HomelandWishStarData._previewSnapshot
end

function HomelandWishStarData._getProjectedCurrentRaw(snapshot, timestamp)
	if snapshot.isProducing == false then
		return math.min(snapshot.current, snapshot.capacity)
	end

	local elapsedSeconds = math.max(timestamp - snapshot.timestamp, 0)
	local current = snapshot.current + snapshot.efficiency * elapsedSeconds / HomelandWishStarData.SECONDS_PER_DAY

	return math.min(current, snapshot.capacity)
end

function HomelandWishStarData._getProjectedCurrent(snapshot, timestamp)
	return math.floor(HomelandWishStarData._getProjectedCurrentRaw(snapshot, timestamp))
end

function HomelandWishStarData._notifyChanged(reason, collected, sourceEntityId)
	facade:sendMsgToUI(MessageName.HOMELAND_WISH_STAR_CHANGED, {
		reason = reason,
		collected = collected,
		sourceEntityId = sourceEntityId
	})
end

function HomelandWishStarData._clearExpiredCollectPending()
	if not HomelandWishStarData._serverCollectPending then
		if HomelandWishStarData._serverCollectPendingStartTick ~= nil then
			HomelandWishStarData._serverCollectPendingStartTick = nil

			return true
		end

		return false
	end

	local startTick = HomelandWishStarData._serverCollectPendingStartTick
	local currentTick = Time.getTickSecond()

	if type(startTick) ~= "number" or currentTick < startTick or currentTick - startTick >= HomelandWishStarData.COLLECT_PENDING_TIMEOUT_SECONDS then
		return HomelandWishStarData.clearCollectPending()
	end

	return false
end

function HomelandWishStarData._syncPreviewProductionState(hasBottle, hasBuildPets, timestamp)
	local snapshot = HomelandWishStarData._previewSnapshot

	if HomelandWishStarData._serverSnapshot or not snapshot then
		return
	end

	local shouldProduce = hasBottle and hasBuildPets and snapshot.efficiency > 0

	if snapshot.isProducing == nil then
		snapshot.isProducing = shouldProduce

		if not shouldProduce then
			snapshot.timestamp = timestamp
		end

		return
	end

	if snapshot.isProducing == shouldProduce then
		return
	end

	if snapshot.isProducing then
		snapshot.current = HomelandWishStarData._getProjectedCurrentRaw(snapshot, timestamp)
	end

	snapshot.timestamp = timestamp
	snapshot.isProducing = shouldProduce
end

function HomelandWishStarData.hasBottle(space)
	local ornament = space and space.ornament
	local collectorHomeId = HomelandConfigData.homeVoucherCollectorHome

	if not ornament or collectorHomeId == nil then
		return false
	end

	local player = pg.me
	local statOrnamentByArea = player and player.space == space and player.statOrnamentByArea
	local buildAreaStat = statOrnamentByArea and statOrnamentByArea[HomelandWishStarData.BUILD_AREA_ID]

	if buildAreaStat then
		return (buildAreaStat[collectorHomeId] or 0) > 0
	end

	for _, ornamentInfo in pairs(ornament) do
		if ornamentInfo.homeId == collectorHomeId and ornamentInfo.areaId == HomelandWishStarData.BUILD_AREA_ID then
			return true
		end
	end

	return false
end

function HomelandWishStarData.isProductiveBuildPet(space, petId)
	local petBoxMap = space and space.petBoxMap
	local pets = space and space.pets

	if not petBoxMap or not pets or not petId then
		return false
	end

	local areaId = petBoxMap:getPetIndex(petId)
	local petInfo = pets[petId]

	if areaId ~= HomelandWishStarData.BUILD_AREA_ID or not petInfo or type(space.getPetHomeEventInsId) ~= "function" then
		return false
	end

	local eventInsId = space:getPetHomeEventInsId(petId)

	if eventInsId ~= nil and eventInsId ~= "" then
		return false
	end

	return Utils.checkHomePetStateValid(petInfo, space)
end

function HomelandWishStarData.getBuildPetCounts(space)
	local petBoxMap = space and space.petBoxMap
	local pets = space and space.pets
	local buildBoxInfo = petBoxMap and petBoxMap[HomelandWishStarData.BUILD_AREA_ID]

	if not buildBoxInfo or not pets or type(space.getPetHomeEventInsId) ~= "function" then
		return 0, 0
	end

	local totalBuildPetCount = 0
	local productiveBuildPetCount = 0

	for _, petId in buildBoxInfo:items() do
		totalBuildPetCount = totalBuildPetCount + 1

		local petInfo = pets[petId]
		local eventInsId = petInfo and space:getPetHomeEventInsId(petId)

		if petInfo and (eventInsId == nil or eventInsId == "") and Utils.checkHomePetStateValid(petInfo, space) then
			productiveBuildPetCount = productiveBuildPetCount + 1
		end
	end

	return totalBuildPetCount, productiveBuildPetCount
end

function HomelandWishStarData.hasBuildPets(space)
	local _, productiveBuildPetCount = HomelandWishStarData.getBuildPetCounts(space)

	return productiveBuildPetCount > 0
end

function HomelandWishStarData.getSnapshot(space)
	HomelandWishStarData._clearExpiredCollectPending()

	if HomelandWishStarData._snapshotCacheFrame == Time.frameCount and HomelandWishStarData._snapshotCacheSpace == space then
		return HomelandWishStarData._snapshotCache
	end

	local hasBottle = HomelandWishStarData.hasBottle(space)
	local activeSnapshot = HomelandWishStarData._getActiveSnapshot()
	local totalBuildPetCount, productiveBuildPetCount

	if HomelandWishStarData._serverSnapshot and activeSnapshot.totalBuildPetCount ~= nil and activeSnapshot.productiveBuildPetCount ~= nil then
		totalBuildPetCount = activeSnapshot.totalBuildPetCount
		productiveBuildPetCount = activeSnapshot.productiveBuildPetCount
	else
		totalBuildPetCount, productiveBuildPetCount = HomelandWishStarData.getBuildPetCounts(space)
	end

	local hasBuildPets = productiveBuildPetCount > 0
	local timestamp = Time.getSecond()

	HomelandWishStarData._syncPreviewProductionState(hasBottle, hasBuildPets, timestamp)

	local snapshot = HomelandWishStarData._getActiveSnapshot()

	if not snapshot then
		return HomelandWishStarData._cacheSnapshot(space, {
			canCollect = false,
			isFull = false,
			hasData = false,
			hasBottle = hasBottle,
			hasBuildPets = hasBuildPets,
			totalBuildPetCount = totalBuildPetCount,
			productiveBuildPetCount = productiveBuildPetCount,
			isCollectPending = HomelandWishStarData._serverCollectPending
		})
	end

	local current = HomelandWishStarData._getProjectedCurrent(snapshot, timestamp)
	local isFull = snapshot.capacity > 0 and current >= snapshot.capacity
	local isCollectPending = HomelandWishStarData._serverCollectPending

	return HomelandWishStarData._cacheSnapshot(space, {
		hasData = true,
		current = current,
		capacity = snapshot.capacity,
		efficiency = snapshot.efficiency,
		hasBottle = hasBottle,
		hasBuildPets = hasBuildPets,
		totalBuildPetCount = totalBuildPetCount,
		productiveBuildPetCount = productiveBuildPetCount,
		isFull = isFull,
		isCollectPending = isCollectPending,
		canCollect = hasBottle and current > 0 and not isCollectPending
	})
end

function HomelandWishStarData.setServerSnapshot(current, capacity, produceRatePerSecond, timestamp, isProducing, petOutputs)
	if not HomelandWishStarData._isValidNonNegativeNumber(current) or not HomelandWishStarData._isValidNonNegativeNumber(capacity) or not HomelandWishStarData._isValidNonNegativeNumber(produceRatePerSecond) or not HomelandWishStarData._isValidNonNegativeNumber(timestamp) or type(isProducing) ~= "boolean" or type(petOutputs) ~= "table" then
		logger:error("ignore invalid home voucher snapshot scalars")

		return false
	end

	local convertedPetOutputs = {}
	local totalBuildPetCount = 0
	local productiveBuildPetCount = 0

	for petId, outputInfo in pairs(petOutputs) do
		local baseOutputPerSecond = type(outputInfo) == "table" and outputInfo.baseOutputPerSecond or nil
		local outputPerSecond = type(outputInfo) == "table" and outputInfo.outputPerSecond or nil

		if type(petId) ~= "string" and type(petId) ~= "number" or not HomelandWishStarData._isValidNonNegativeNumber(baseOutputPerSecond) or not HomelandWishStarData._isValidNonNegativeNumber(outputPerSecond) or outputInfo.appearanceInfos ~= nil and type(outputInfo.appearanceInfos) ~= "table" then
			logger:error("ignore invalid home voucher pet output, petId=%s", tostring(petId))

			return false
		end

		totalBuildPetCount = totalBuildPetCount + 1

		if outputPerSecond > 0 then
			productiveBuildPetCount = productiveBuildPetCount + 1
		end

		local convertedAppearanceInfos

		if outputInfo.appearanceInfos then
			convertedAppearanceInfos = {}

			for _, appearanceInfo in ipairs(outputInfo.appearanceInfos) do
				if type(appearanceInfo) ~= "table" or type(appearanceInfo.id) ~= "string" and type(appearanceInfo.id) ~= "number" or type(appearanceInfo.appearanceType) ~= "number" or type(appearanceInfo.appearanceValue) ~= "number" or not HomelandWishStarData._isValidNonNegativeNumber(appearanceInfo.rate) or type(appearanceInfo.sort) ~= "number" then
					logger:error("ignore invalid home voucher appearance info, petId=%s", tostring(petId))

					return false
				end

				convertedAppearanceInfos[#convertedAppearanceInfos + 1] = {
					id = appearanceInfo.id,
					appearanceType = appearanceInfo.appearanceType,
					appearanceValue = appearanceInfo.appearanceValue,
					rate = appearanceInfo.rate,
					sort = appearanceInfo.sort
				}
			end
		end

		convertedPetOutputs[petId] = {
			baseOutput = baseOutputPerSecond * HomelandWishStarData.SECONDS_PER_DAY,
			output = outputPerSecond * HomelandWishStarData.SECONDS_PER_DAY,
			appearanceInfos = convertedAppearanceInfos
		}
	end

	HomelandWishStarData._serverSnapshot = {
		current = math.min(current, capacity),
		capacity = capacity,
		efficiency = produceRatePerSecond * HomelandWishStarData.SECONDS_PER_DAY,
		timestamp = timestamp,
		petOutputs = convertedPetOutputs,
		isProducing = isProducing,
		totalBuildPetCount = totalBuildPetCount,
		productiveBuildPetCount = productiveBuildPetCount
	}
	HomelandWishStarData._previewSnapshot = nil

	HomelandWishStarData._invalidateSnapshotCache()
	HomelandWishStarData._notifyChanged(HomelandWishStarData.CHANGE_REASON.SERVER_SNAPSHOT)

	return true
end

function HomelandWishStarData.setPreviewSnapshot(snapshot)
	if HomelandWishStarData._serverSnapshot then
		return false
	end

	local previewSnapshot, invalidReason = HomelandWishStarData._copyPreviewSnapshot(snapshot, true)

	if not previewSnapshot then
		logger:error("ignore invalid home voucher preview snapshot, reason=%s", tostring(invalidReason))

		return false
	end

	previewSnapshot.isProducing = false
	HomelandWishStarData._previewSnapshot = previewSnapshot

	HomelandWishStarData._invalidateSnapshotCache()
	HomelandWishStarData._notifyChanged(HomelandWishStarData.CHANGE_REASON.PREVIEW_SNAPSHOT)

	return true
end

function HomelandWishStarData.clearPreviewSnapshot()
	if not HomelandWishStarData._previewSnapshot then
		return false
	end

	HomelandWishStarData._previewSnapshot = nil

	HomelandWishStarData._invalidateSnapshotCache()
	HomelandWishStarData._notifyChanged(HomelandWishStarData.CHANGE_REASON.PREVIEW_CLEARED)

	return true
end

function HomelandWishStarData.collectLocallyForPreview(sourceEntityId)
	if HomelandWishStarData._serverSnapshot or not HomelandWishStarData._previewSnapshot then
		return nil
	end

	local timestamp = Time.getSecond()
	local collected = HomelandWishStarData._getProjectedCurrent(HomelandWishStarData._previewSnapshot, timestamp)

	HomelandWishStarData._previewSnapshot.current = 0
	HomelandWishStarData._previewSnapshot.timestamp = timestamp

	HomelandWishStarData._invalidateSnapshotCache()
	HomelandWishStarData._notifyChanged(HomelandWishStarData.CHANGE_REASON.PREVIEW_COLLECTED, collected, sourceEntityId)

	return collected
end

function HomelandWishStarData.clearCollectPending()
	local changed = HomelandWishStarData._serverCollectPending or HomelandWishStarData._serverCollectPendingStartTick ~= nil

	HomelandWishStarData._serverCollectPending = false
	HomelandWishStarData._serverCollectPendingStartTick = nil

	if changed then
		HomelandWishStarData._invalidateSnapshotCache()
	end

	return changed
end

function HomelandWishStarData.prepareCollect(space, sourceEntityId)
	HomelandWishStarData._clearExpiredCollectPending()

	if HomelandWishStarData._serverCollectPending then
		return false, false, "pending"
	end

	local snapshot = HomelandWishStarData.getSnapshot(space)

	if HomelandWishStarData._previewSnapshot and not HomelandWishStarData._serverSnapshot then
		if not snapshot.hasData or not snapshot.canCollect then
			return false, false, "empty"
		end

		local collected = HomelandWishStarData.collectLocallyForPreview(sourceEntityId)

		if collected ~= nil and collected > 0 then
			return true, false
		end

		return false, false, "empty"
	end

	HomelandWishStarData._serverCollectPending = true
	HomelandWishStarData._serverCollectPendingStartTick = Time.getTickSecond()

	HomelandWishStarData._invalidateSnapshotCache()

	return true, true
end

function HomelandWishStarData.notifyServerCollected(collected, sourceEntityId)
	HomelandWishStarData.clearCollectPending()

	if type(collected) ~= "number" or collected <= 0 then
		return false
	end

	HomelandWishStarData._notifyChanged(HomelandWishStarData.CHANGE_REASON.SERVER_COLLECTED, collected, sourceEntityId)

	return true
end

function HomelandWishStarData.reset()
	HomelandWishStarData._serverSnapshot = nil
	HomelandWishStarData._previewSnapshot = nil
	HomelandWishStarData._serverCollectPending = false
	HomelandWishStarData._serverCollectPendingStartTick = nil

	HomelandWishStarData._invalidateSnapshotCache()
	HomelandWishStarData._notifyChanged(HomelandWishStarData.CHANGE_REASON.RESET)
end

function HomelandWishStarData.getPetOutputInfo(petOrId)
	local petId = type(petOrId) == "table" and petOrId.id or petOrId
	local snapshot = HomelandWishStarData._getActiveSnapshot()
	local outputInfo = snapshot and snapshot.petOutputs and snapshot.petOutputs[petId]

	if not outputInfo or type(outputInfo.output) ~= "number" or type(outputInfo.baseOutput) ~= "number" then
		return {
			hasData = false,
			appearanceInfos = outputInfo and outputInfo.appearanceInfos or nil
		}
	end

	return {
		hasData = true,
		output = outputInfo.output,
		baseOutput = outputInfo.baseOutput,
		appearanceInfos = outputInfo.appearanceInfos
	}
end

return HomelandWishStarData
