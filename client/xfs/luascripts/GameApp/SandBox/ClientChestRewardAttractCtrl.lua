-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\ClientChestRewardAttractCtrl.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local TimerManager = require("Core.Timer.TimerManager")
local Utils = require("Common.Utils.Utils")
local ItemUtils = require("Common.Utils.ItemUtils")
local SysConfigData = require("Data.sys_config_data")
local ItemData = require("Data.item_data")
local ClientChestRewardAttractRuntime = require("GameApp.Sandbox.ClientChestRewardAttractRuntime")
local Vector3 = Vector3
local logger = LoggerManager.getLogger("ChestRewardAttract", "Sandbox", LoggerConst.ERROR)
local DEFAULT_TRAIL_FALL_BY_QUALITY = {
	"Eff_PVE_Boss_Multiple_Battle_Trail_White_1",
	"Eff_PVE_Boss_Multiple_Battle_Trail_White_1",
	"Eff_PVE_Boss_Multiple_Battle_Trail_Blue_1",
	"Eff_PVE_Boss_Multiple_Battle_Trail_Blue_1",
	"Eff_PVE_Boss_Multiple_Battle_Trail_Gold_1"
}
local DEFAULT_TRAIL_ABSORB_BY_QUALITY = {
	"Eff_PVE_Boss_Multiple_Battle_Trail_White",
	"Eff_PVE_Boss_Multiple_Battle_Trail_White",
	"Eff_PVE_Boss_Multiple_Battle_Trail_Blue",
	"Eff_PVE_Boss_Multiple_Battle_Trail_Blue",
	"Eff_PVE_Boss_Multiple_Battle_Trail_Gold"
}
local DEFAULT_PILLAR_BY_QUALITY = {
	"Eff_PVE_Boss_Multiple_Battle_Gain_White",
	"Eff_PVE_Boss_Multiple_Battle_Gain_White",
	"Eff_PVE_Boss_Multiple_Battle_Gain_Blue",
	"Eff_PVE_Boss_Multiple_Battle_Gain_Blue",
	"Eff_PVE_Boss_Multiple_Battle_Gain_Gold"
}
local DEFAULT_ABSORB_EFFECT_BY_QUALITY = {
	"Eff_PVE_Boss_Multiple_Battle_Gain_White",
	"Eff_PVE_Boss_Multiple_Battle_Gain_White",
	"Eff_PVE_Boss_Multiple_Battle_Gain_Blue",
	"Eff_PVE_Boss_Multiple_Battle_Gain_Blue",
	"Eff_PVE_Boss_Multiple_Battle_Gain_Gold"
}
local DEFAULT = {
	absorbDurationMin = 0.5,
	stayDuration = 1,
	fallGravity = 20,
	fallDurationMax = 1,
	fallDurationMin = 0.5,
	radius = 1.5,
	absorbEffectDefault = "Eff_PVE_Boss_Multiple_Battle_Gain_White",
	pillarDefault = "Eff_PVE_Boss_Multiple_Battle_Gain_White",
	trailAbsorbDefault = "Eff_PVE_Boss_Multiple_Battle_Trail_White",
	trailFallDefault = "Eff_PVE_Boss_Multiple_Battle_Trail_White",
	absorbEffectOffsetY = 0.5,
	absorbSound = "SFX_UI_Reward_Pickup_Default",
	absorbSideRandom = 0.25,
	absorbEndUp = 0.4,
	absorbStartUp = 0.8,
	absorbDurationMax = 0.8
}
local ClientChestRewardAttractCtrl = {}
local Ctrl = ClientChestRewardAttractCtrl
local CHEST_REWARD_ATTRACT_MAX_PARTICLES = 128
local FULL_CHEST_PLAY_MODE = "full_chest"
local CHEST_REWARD_MOTION_CONFIG_FIELDS = {
	"radius",
	"fallDurationMin",
	"fallDurationMax",
	"fallGravity",
	"stayDuration",
	"absorbDurationMin",
	"absorbDurationMax",
	"absorbStartUp",
	"absorbEndUp",
	"absorbSideRandom"
}

function Ctrl._isFiniteNumber(value)
	return type(value) == "number" and value == value and value ~= math.huge and value ~= -math.huge
end

function Ctrl._isPositiveInteger(value)
	return Ctrl._isFiniteNumber(value) and value > 0 and value % 1 == 0
end

function Ctrl._getDenseArrayLength(value)
	if not Utils.isTable(value) then
		return nil
	end

	local count = 0
	local maxIndex = 0

	for key in pairs(value) do
		if type(key) ~= "number" or key < 1 or key % 1 ~= 0 then
			return nil
		end

		count = count + 1

		if maxIndex < key then
			maxIndex = key
		end
	end

	if count ~= maxIndex then
		return nil
	end

	return count
end

function Ctrl._warnInvalidAbsorbBatch(source, reason, batchCount, particleCount)
	if logger and logger.warn then
		logger:warn("invalid chest reward attract batch", source, reason, batchCount or 0, particleCount or 0)
	end
end

function Ctrl._copyLocalAbsorbStartPos(startPos)
	if startPos == nil then
		return nil
	end

	local ok, x, y, z = pcall(function()
		return startPos.x, startPos.y, startPos.z
	end)

	if not ok or not Ctrl._isFiniteNumber(x) or not Ctrl._isFiniteNumber(y) or not Ctrl._isFiniteNumber(z) then
		return nil
	end

	return {
		x = x,
		y = y,
		z = z
	}
end

function Ctrl._copySyncedAbsorbStartPos(startPos)
	local startPosCount = Ctrl._getDenseArrayLength(startPos)

	if startPosCount ~= 3 then
		return nil
	end

	local x = startPos[1]
	local y = startPos[2]
	local z = startPos[3]

	if not Ctrl._isFiniteNumber(x) or not Ctrl._isFiniteNumber(y) or not Ctrl._isFiniteNumber(z) then
		return nil
	end

	return {
		x = x,
		y = y,
		z = z
	}
end

function Ctrl._snapshotAbsorbBatch(itemList, qualityList, rewardNumList, tipQualityList, startPos, waveInterval, absorbDuration, showTip, targetActorId)
	local itemCount = Ctrl._getDenseArrayLength(itemList)
	local qualityCount = Ctrl._getDenseArrayLength(qualityList)
	local rewardNumCount = Ctrl._getDenseArrayLength(rewardNumList)
	local tipQualityCount = Ctrl._getDenseArrayLength(tipQualityList)

	if not itemCount or itemCount == 0 or qualityCount ~= itemCount or rewardNumCount ~= itemCount or tipQualityCount ~= itemCount then
		return nil, "batch_shape", itemCount
	end

	if not Ctrl._isFiniteNumber(waveInterval) or waveInterval < 0 then
		return nil, "wave_interval", itemCount
	end

	if not Ctrl._isFiniteNumber(absorbDuration) or absorbDuration <= 0 then
		return nil, "absorb_duration", itemCount
	end

	if type(showTip) ~= "boolean" then
		return nil, "show_tip", itemCount
	end

	if not Ctrl._isPositiveInteger(targetActorId) then
		return nil, "target_actor_id", itemCount
	end

	local startPosSnapshot = Ctrl._copyLocalAbsorbStartPos(startPos)

	if not startPosSnapshot then
		return nil, "start_pos", itemCount
	end

	local itemSnapshot = {}
	local qualitySnapshot = {}
	local rewardNumSnapshot = {}
	local tipQualitySnapshot = {}
	local totalParticleCount = 0

	for rewardBatchIndex = 1, itemCount do
		local itemId = itemList[rewardBatchIndex]
		local rewardNum = rewardNumList[rewardBatchIndex]
		local tipQuality = tipQualityList[rewardBatchIndex]

		if not Ctrl._isPositiveInteger(itemId) then
			return nil, "item_id", itemCount, totalParticleCount
		end

		if not Ctrl._isPositiveInteger(rewardNum) then
			return nil, "reward_num", itemCount, totalParticleCount
		end

		if not Ctrl._isPositiveInteger(tipQuality) then
			return nil, "tip_quality", itemCount, totalParticleCount
		end

		local qualityBatch = qualityList[rewardBatchIndex]
		local qualityBatchCount = Ctrl._getDenseArrayLength(qualityBatch)

		if not qualityBatchCount or qualityBatchCount == 0 then
			return nil, "particle_shape", itemCount, totalParticleCount
		end

		totalParticleCount = totalParticleCount + qualityBatchCount

		if totalParticleCount > CHEST_REWARD_ATTRACT_MAX_PARTICLES then
			return nil, "particle_limit", itemCount, totalParticleCount
		end

		local qualityBatchSnapshot = {}

		for particleIndex = 1, qualityBatchCount do
			local quality = qualityBatch[particleIndex]

			if not Ctrl._isPositiveInteger(quality) then
				return nil, "particle_quality", itemCount, totalParticleCount
			end

			qualityBatchSnapshot[particleIndex] = quality
		end

		itemSnapshot[rewardBatchIndex] = itemId
		qualitySnapshot[rewardBatchIndex] = qualityBatchSnapshot
		rewardNumSnapshot[rewardBatchIndex] = rewardNum
		tipQualitySnapshot[rewardBatchIndex] = tipQuality
	end

	return {
		itemList = itemSnapshot,
		qualityList = qualitySnapshot,
		rewardNumList = rewardNumSnapshot,
		tipQualityList = tipQualitySnapshot,
		startPos = Vector3(startPosSnapshot.x, startPosSnapshot.y, startPosSnapshot.z),
		waveInterval = waveInterval,
		absorbDuration = absorbDuration,
		showTip = showTip,
		targetActorId = targetActorId,
		itemCount = itemCount,
		particleCount = totalParticleCount
	}
end

function Ctrl._snapshotChestRewardMotionConfig(cfg)
	if not Utils.isTable(cfg) then
		return nil, "cfg_type"
	end

	local snapshot = {}

	for _, fieldName in ipairs(CHEST_REWARD_MOTION_CONFIG_FIELDS) do
		local value = cfg[fieldName]

		if not Ctrl._isFiniteNumber(value) then
			return nil, "cfg_" .. fieldName
		end

		snapshot[fieldName] = value
	end

	if snapshot.fallDurationMin > snapshot.fallDurationMax then
		return nil, "cfg_fall_duration_range"
	end

	if snapshot.absorbDurationMin > snapshot.absorbDurationMax then
		return nil, "cfg_absorb_duration_range"
	end

	return snapshot
end

function Ctrl._snapshotChestRewardBatch(itemList, qualityList, rewardNumList, tipQualityList, startPos, waveInterval, tipDelay, cfg, showTip, targetActorId)
	local itemCount = Ctrl._getDenseArrayLength(itemList)
	local qualityCount = Ctrl._getDenseArrayLength(qualityList)
	local rewardNumCount = Ctrl._getDenseArrayLength(rewardNumList)
	local tipQualityCount = Ctrl._getDenseArrayLength(tipQualityList)

	if not itemCount or itemCount == 0 or qualityCount ~= itemCount or rewardNumCount ~= itemCount or tipQualityCount ~= itemCount then
		return nil, "batch_shape", itemCount
	end

	if not Ctrl._isFiniteNumber(waveInterval) or waveInterval < 0 then
		return nil, "wave_interval", itemCount
	end

	if not Ctrl._isFiniteNumber(tipDelay) or tipDelay < 0 then
		return nil, "tip_delay", itemCount
	end

	if type(showTip) ~= "boolean" then
		return nil, "show_tip", itemCount
	end

	if not Ctrl._isPositiveInteger(targetActorId) then
		return nil, "target_actor_id", itemCount
	end

	local startPosSnapshot = Ctrl._copyLocalAbsorbStartPos(startPos)

	if not startPosSnapshot then
		return nil, "start_pos", itemCount
	end

	local motionCfgSnapshot, cfgReason = Ctrl._snapshotChestRewardMotionConfig(cfg)

	if not motionCfgSnapshot then
		return nil, cfgReason, itemCount
	end

	local itemSnapshot = {}
	local qualitySnapshot = {}
	local rewardNumSnapshot = {}
	local tipQualitySnapshot = {}
	local totalParticleCount = 0

	for rewardBatchIndex = 1, itemCount do
		local itemId = itemList[rewardBatchIndex]
		local rewardNum = rewardNumList[rewardBatchIndex]
		local tipQuality = tipQualityList[rewardBatchIndex]

		if not Ctrl._isPositiveInteger(itemId) then
			return nil, "item_id", itemCount, totalParticleCount
		end

		if not Ctrl._isPositiveInteger(rewardNum) then
			return nil, "reward_num", itemCount, totalParticleCount
		end

		if not Ctrl._isPositiveInteger(tipQuality) then
			return nil, "tip_quality", itemCount, totalParticleCount
		end

		local qualityBatch = qualityList[rewardBatchIndex]
		local qualityBatchCount = Ctrl._getDenseArrayLength(qualityBatch)

		if not qualityBatchCount or qualityBatchCount == 0 then
			return nil, "particle_shape", itemCount, totalParticleCount
		end

		totalParticleCount = totalParticleCount + qualityBatchCount

		if totalParticleCount > CHEST_REWARD_ATTRACT_MAX_PARTICLES then
			return nil, "particle_limit", itemCount, totalParticleCount
		end

		local qualityBatchSnapshot = {}

		for particleIndex = 1, qualityBatchCount do
			local quality = qualityBatch[particleIndex]

			if not Ctrl._isPositiveInteger(quality) then
				return nil, "particle_quality", itemCount, totalParticleCount
			end

			qualityBatchSnapshot[particleIndex] = quality
		end

		itemSnapshot[rewardBatchIndex] = itemId
		qualitySnapshot[rewardBatchIndex] = qualityBatchSnapshot
		rewardNumSnapshot[rewardBatchIndex] = rewardNum
		tipQualitySnapshot[rewardBatchIndex] = tipQuality
	end

	return {
		itemList = itemSnapshot,
		qualityList = qualitySnapshot,
		rewardNumList = rewardNumSnapshot,
		tipQualityList = tipQualitySnapshot,
		startPos = Vector3(startPosSnapshot.x, startPosSnapshot.y, startPosSnapshot.z),
		waveInterval = waveInterval,
		tipDelay = tipDelay,
		motionCfg = motionCfgSnapshot,
		showTip = showTip,
		targetActorId = targetActorId,
		itemCount = itemCount,
		particleCount = totalParticleCount
	}
end

function Ctrl._normalizeSyncedChestRewardBatch(payload)
	local itemCount = Ctrl._getDenseArrayLength(payload.itemList)

	if not itemCount or itemCount == 0 then
		return nil, "batch_shape", itemCount
	end

	local tipQualityList = {}

	for rewardBatchIndex = 1, itemCount do
		local itemId = payload.itemList[rewardBatchIndex]

		if not Ctrl._isPositiveInteger(itemId) then
			return nil, "item_id", itemCount
		end

		local itemConfig = ItemData[itemId]
		local defaultQuality = itemConfig and itemConfig.quality

		tipQualityList[rewardBatchIndex] = Ctrl._isPositiveInteger(defaultQuality) and defaultQuality or 1
	end

	local startPosSnapshot = Ctrl._copySyncedAbsorbStartPos(payload.startPos)

	if not startPosSnapshot then
		return nil, "start_pos", itemCount
	end

	return Ctrl._snapshotChestRewardBatch(payload.itemList, payload.qualityList, payload.rewardNumList, tipQualityList, Vector3(startPosSnapshot.x, startPosSnapshot.y, startPosSnapshot.z), payload.waveInterval, payload.tipDelay, payload.cfg, false, payload.targetActorId)
end

function Ctrl._normalizeSyncedAbsorbBatch(payload)
	if not Utils.isTable(payload) then
		return nil, "payload_type"
	end

	local itemCount = Ctrl._getDenseArrayLength(payload.itemList)
	local qualityCount = Ctrl._getDenseArrayLength(payload.qualityList)
	local rewardNumCount = Ctrl._getDenseArrayLength(payload.rewardNumList)

	if not itemCount or itemCount == 0 or qualityCount ~= itemCount or rewardNumCount ~= itemCount then
		return nil, "batch_shape", itemCount
	end

	if not Ctrl._isFiniteNumber(payload.waveInterval) or payload.waveInterval < 0 then
		return nil, "wave_interval", itemCount
	end

	if not Ctrl._isFiniteNumber(payload.absorbDuration) or payload.absorbDuration <= 0 then
		return nil, "absorb_duration", itemCount
	end

	if not Ctrl._isPositiveInteger(payload.targetActorId) then
		return nil, "target_actor_id", itemCount
	end

	local startPosSnapshot = Ctrl._copySyncedAbsorbStartPos(payload.startPos)

	if not startPosSnapshot then
		return nil, "start_pos", itemCount
	end

	local tipQualityList = payload.tipQualityList
	local tipQualityCount

	if tipQualityList ~= nil then
		tipQualityCount = Ctrl._getDenseArrayLength(tipQualityList)

		if tipQualityCount ~= itemCount then
			return nil, "tip_quality_shape", itemCount
		end
	end

	local itemSnapshot = {}
	local qualitySnapshot = {}
	local rewardNumSnapshot = {}
	local tipQualitySnapshot = {}
	local totalParticleCount = 0

	for rewardBatchIndex = 1, itemCount do
		local itemId = payload.itemList[rewardBatchIndex]

		if not Ctrl._isPositiveInteger(itemId) then
			return nil, "item_id", itemCount, totalParticleCount
		end

		local qualityBatch = payload.qualityList[rewardBatchIndex]
		local qualityBatchCount = Ctrl._getDenseArrayLength(qualityBatch)

		if not qualityBatchCount or qualityBatchCount == 0 then
			return nil, "particle_shape", itemCount, totalParticleCount
		end

		totalParticleCount = totalParticleCount + qualityBatchCount

		if totalParticleCount > CHEST_REWARD_ATTRACT_MAX_PARTICLES then
			return nil, "particle_limit", itemCount, totalParticleCount
		end

		local qualityBatchSnapshot = {}

		for particleIndex = 1, qualityBatchCount do
			local quality = qualityBatch[particleIndex]

			if not Ctrl._isPositiveInteger(quality) then
				return nil, "particle_quality", itemCount, totalParticleCount
			end

			qualityBatchSnapshot[particleIndex] = quality
		end

		local rewardNumBatch = payload.rewardNumList[rewardBatchIndex]
		local rewardBatchTotal

		if Ctrl._isPositiveInteger(rewardNumBatch) then
			rewardBatchTotal = rewardNumBatch
		else
			local rewardNumBatchCount = Ctrl._getDenseArrayLength(rewardNumBatch)

			if rewardNumBatchCount ~= qualityBatchCount then
				return nil, "reward_num_shape", itemCount, totalParticleCount
			end

			rewardBatchTotal = 0

			for particleIndex = 1, rewardNumBatchCount do
				local rewardNum = rewardNumBatch[particleIndex]

				if not Ctrl._isPositiveInteger(rewardNum) then
					return nil, "particle_reward_num", itemCount, totalParticleCount
				end

				rewardBatchTotal = rewardBatchTotal + rewardNum

				if not Ctrl._isFiniteNumber(rewardBatchTotal) then
					return nil, "reward_num_total", itemCount, totalParticleCount
				end
			end
		end

		local tipQuality

		if tipQualityList ~= nil then
			tipQuality = tipQualityList[rewardBatchIndex]

			if not Ctrl._isPositiveInteger(tipQuality) then
				return nil, "tip_quality", itemCount, totalParticleCount
			end
		else
			local itemConfig = ItemData[itemId]
			local defaultQuality = itemConfig and itemConfig.quality

			tipQuality = Ctrl._isPositiveInteger(defaultQuality) and defaultQuality or 1
		end

		itemSnapshot[rewardBatchIndex] = itemId
		qualitySnapshot[rewardBatchIndex] = qualityBatchSnapshot
		rewardNumSnapshot[rewardBatchIndex] = rewardBatchTotal
		tipQualitySnapshot[rewardBatchIndex] = tipQuality
	end

	return {
		showTip = false,
		itemList = itemSnapshot,
		qualityList = qualitySnapshot,
		rewardNumList = rewardNumSnapshot,
		tipQualityList = tipQualitySnapshot,
		startPos = Vector3(startPosSnapshot.x, startPosSnapshot.y, startPosSnapshot.z),
		waveInterval = payload.waveInterval,
		absorbDuration = payload.absorbDuration,
		targetActorId = payload.targetActorId,
		itemCount = itemCount,
		particleCount = totalParticleCount
	}
end

Ctrl._registered = {}
Ctrl._pendingItems = {}
Ctrl._runtime = nil

function Ctrl._getRuntime()
	if not Ctrl._runtime then
		Ctrl._runtime = ClientChestRewardAttractRuntime()
	end

	return Ctrl._runtime
end

function Ctrl._enqueuePending(chestTemplateId, idNumDict)
	if not chestTemplateId then
		return
	end

	Ctrl._pendingItems[chestTemplateId] = Ctrl._pendingItems[chestTemplateId] or {}

	local queue = Ctrl._pendingItems[chestTemplateId]
	local entry = {
		chestTemplateId = chestTemplateId,
		idNumDict = idNumDict
	}

	entry.timer = TimerManager.addTimer(0.3, function()
		local q = Ctrl._pendingItems[chestTemplateId]

		if not q then
			return
		end

		for i = 1, #q do
			if q[i] == entry then
				table.remove(q, i)

				if #q == 0 then
					Ctrl._pendingItems[chestTemplateId] = nil
				end

				break
			end
		end
	end)

	table.insert(queue, entry)
end

function Ctrl._clearAllPending()
	if not Ctrl._pendingItems then
		return
	end

	for _, queue in pairs(Ctrl._pendingItems) do
		if queue then
			for _, entry in ipairs(queue) do
				if entry and entry.timer then
					TimerManager.removeTimer(entry.timer)

					entry.timer = nil
				end
			end
		end
	end

	Ctrl._pendingItems = {}
end

function Ctrl._loadConfig()
	local cfg = {
		radius = SysConfigData.chestRewardAttractDefaultRadius or DEFAULT.radius,
		fallDurationMin = SysConfigData.chestRewardAttractFallDurationMin or DEFAULT.fallDurationMin,
		fallDurationMax = SysConfigData.chestRewardAttractFallDurationMax or DEFAULT.fallDurationMax,
		fallGravity = SysConfigData.chestRewardAttractFallGravity or DEFAULT.fallGravity,
		stayDuration = SysConfigData.chestRewardAttractStayDuration or DEFAULT.stayDuration,
		absorbDurationMin = SysConfigData.chestRewardAttractAbsorbDurationMin or DEFAULT.absorbDurationMin,
		absorbDurationMax = SysConfigData.chestRewardAttractAbsorbDurationMax or DEFAULT.absorbDurationMax,
		absorbStartUp = SysConfigData.chestRewardAttractAbsorbStartUp or DEFAULT.absorbStartUp,
		absorbEndUp = SysConfigData.chestRewardAttractAbsorbEndUp or DEFAULT.absorbEndUp,
		absorbSideRandom = SysConfigData.chestRewardAttractAbsorbSideRandom or DEFAULT.absorbSideRandom,
		absorbSound = SysConfigData.chestRewardAttractAbsorbSound or DEFAULT.absorbSound,
		trailFallByQuality = SysConfigData.chestRewardAttractTrailFallByQuality or DEFAULT_TRAIL_FALL_BY_QUALITY,
		trailFallDefault = SysConfigData.chestRewardAttractTrailFallDefault or DEFAULT.trailFallDefault,
		trailAbsorbByQuality = SysConfigData.chestRewardAttractTrailAbsorbByQuality or DEFAULT_TRAIL_ABSORB_BY_QUALITY,
		trailAbsorbDefault = SysConfigData.chestRewardAttractTrailAbsorbDefault or DEFAULT.trailAbsorbDefault,
		pillarByQuality = SysConfigData.chestRewardAttractPillarByQuality or DEFAULT_PILLAR_BY_QUALITY,
		pillarDefault = SysConfigData.chestRewardAttractPillarDefault or DEFAULT.pillarDefault,
		absorbEffectByQuality = SysConfigData.chestRewardAttractAbsorbEffectByQuality or DEFAULT_ABSORB_EFFECT_BY_QUALITY,
		absorbEffectDefault = SysConfigData.chestRewardAttractAbsorbEffectDefault or DEFAULT.absorbEffectDefault,
		absorbEffectOffsetY = SysConfigData.chestRewardAttractAbsorbEffectOffsetY or DEFAULT.absorbEffectOffsetY
	}

	return cfg
end

function Ctrl._mergeChestRewardMotionConfig(motionCfg)
	local cfg = Ctrl._loadConfig()

	for _, fieldName in ipairs(CHEST_REWARD_MOTION_CONFIG_FIELDS) do
		cfg[fieldName] = motionCfg[fieldName]
	end

	return cfg
end

function Ctrl.register(chestEnt)
	if not chestEnt then
		return
	end

	local tid = chestEnt.templateId

	if not tid then
		return
	end

	Ctrl._registered[tid] = Ctrl._registered[tid] or {}

	table.insert(Ctrl._registered[tid], {
		chestId = chestEnt.id,
		chestPos = chestEnt:getPosition(),
		templateId = tid
	})

	local pendingQ = Ctrl._pendingItems[tid]

	if pendingQ and #pendingQ > 0 then
		local pending = table.remove(pendingQ, 1)

		if #pendingQ == 0 then
			Ctrl._pendingItems[tid] = nil
		end

		if pending.timer then
			TimerManager.removeTimer(pending.timer)

			pending.timer = nil
		end

		Ctrl.fireWithItems(pending.chestTemplateId, pending.idNumDict)
	end
end

function Ctrl.fireWithItems(chestTemplateId, idNumDict)
	if not chestTemplateId then
		return
	end

	local regQ = Ctrl._registered[chestTemplateId]

	if not regQ or #regQ == 0 then
		Ctrl._enqueuePending(chestTemplateId, idNumDict)

		return
	end

	local reg = table.remove(regQ, 1)

	if #regQ == 0 then
		Ctrl._registered[chestTemplateId] = nil
	end

	if not idNumDict then
		return
	end

	local itemList = {}

	for itemId, numInfo in pairs(idNumDict) do
		local count

		if ItemUtils and ItemUtils.getItemCountFromNumInfo then
			count = ItemUtils.getItemCountFromNumInfo(numInfo)
		else
			count = type(numInfo) == "number" and numInfo or 0
		end

		if count and count > 0 then
			local quality = (ItemData[itemId] or EMPTY_TABLE).quality or 1

			table.insert(itemList, {
				itemId = itemId,
				count = count,
				quality = quality
			})
		end
	end

	local chestPos = reg.chestPos

	if #itemList == 0 or not chestPos then
		return
	end

	local cfg = Ctrl._loadConfig()

	Ctrl._getRuntime():playItems(chestPos, itemList, cfg)
end

function Ctrl._playAbsorbBatchLocal(itemList, qualityList, rewardNumList, tipQualityList, startPos, waveInterval, absorbDuration, showTip, targetActorId)
	local snapshot, reason, batchCount, particleCount = Ctrl._snapshotAbsorbBatch(itemList, qualityList, rewardNumList, tipQualityList, startPos, waveInterval, absorbDuration, showTip, targetActorId)

	if not snapshot then
		Ctrl._warnInvalidAbsorbBatch("local", reason, batchCount, particleCount)

		return nil
	end

	local cfg = Ctrl._loadConfig()

	cfg.absorbDurationMin = snapshot.absorbDuration
	cfg.absorbDurationMax = snapshot.absorbDuration

	return Ctrl._getRuntime():startAbsorbBatch(snapshot, cfg), snapshot
end

function Ctrl._buildChestRewardAttractSyncPayload(snapshot)
	local payload = {
		itemList = {},
		qualityList = {},
		rewardNumList = {},
		startPos = {
			snapshot.startPos.x,
			snapshot.startPos.y,
			snapshot.startPos.z
		},
		waveInterval = snapshot.waveInterval,
		absorbDuration = snapshot.absorbDuration
	}

	for rewardBatchIndex = 1, snapshot.itemCount do
		payload.itemList[rewardBatchIndex] = snapshot.itemList[rewardBatchIndex]
		payload.qualityList[rewardBatchIndex] = {}

		for particleIndex, quality in ipairs(snapshot.qualityList[rewardBatchIndex]) do
			payload.qualityList[rewardBatchIndex][particleIndex] = quality
		end

		payload.rewardNumList[rewardBatchIndex] = snapshot.rewardNumList[rewardBatchIndex]
	end

	return payload
end

function Ctrl._buildFullChestRewardSyncPayload(snapshot)
	local payload = {
		playMode = FULL_CHEST_PLAY_MODE,
		itemList = {},
		qualityList = {},
		rewardNumList = {},
		startPos = {
			snapshot.startPos.x,
			snapshot.startPos.y,
			snapshot.startPos.z
		},
		waveInterval = snapshot.waveInterval,
		tipDelay = snapshot.tipDelay,
		cfg = {}
	}

	for rewardBatchIndex = 1, snapshot.itemCount do
		payload.itemList[rewardBatchIndex] = snapshot.itemList[rewardBatchIndex]
		payload.qualityList[rewardBatchIndex] = {}

		for particleIndex, quality in ipairs(snapshot.qualityList[rewardBatchIndex]) do
			payload.qualityList[rewardBatchIndex][particleIndex] = quality
		end

		payload.rewardNumList[rewardBatchIndex] = snapshot.rewardNumList[rewardBatchIndex]
	end

	for _, fieldName in ipairs(CHEST_REWARD_MOTION_CONFIG_FIELDS) do
		payload.cfg[fieldName] = snapshot.motionCfg[fieldName]
	end

	return payload
end

function Ctrl.playChestRewardBatch(itemList, qualityList, rewardNumList, tipQualityList, startPos, waveInterval, tipDelay, cfg, showTip, enableSync)
	if not pg.me then
		return nil
	end

	if type(enableSync) ~= "boolean" then
		Ctrl._warnInvalidAbsorbBatch("full_chest_local", "enable_sync")

		return nil
	end

	local snapshot, reason, batchCount, particleCount = Ctrl._snapshotChestRewardBatch(itemList, qualityList, rewardNumList, tipQualityList, startPos, waveInterval, tipDelay, cfg, showTip, pg.me.actorId)

	if not snapshot then
		Ctrl._warnInvalidAbsorbBatch("full_chest_local", reason, batchCount, particleCount)

		return nil
	end

	local cfgSnapshot = Ctrl._mergeChestRewardMotionConfig(snapshot.motionCfg)
	local batchId = Ctrl._getRuntime():startChestRewardBatch(snapshot, cfgSnapshot)

	if enableSync then
		pg.me:serverMsg("RPC_CS_PlayChestRewardAttract", Ctrl._buildFullChestRewardSyncPayload(snapshot))
	end

	return batchId
end

function Ctrl.playAbsorbBatch(itemList, qualityList, rewardNumList, tipQualityList, startPos, waveInterval, absorbDuration, showTip, enableSync)
	if not pg.me then
		return nil
	end

	if type(enableSync) ~= "boolean" then
		Ctrl._warnInvalidAbsorbBatch("local", "enable_sync")

		return nil
	end

	local batchId, snapshot = Ctrl._playAbsorbBatchLocal(itemList, qualityList, rewardNumList, tipQualityList, startPos, waveInterval, absorbDuration, showTip, pg.me.actorId)

	if not batchId then
		return nil
	end

	if enableSync then
		local payload = Ctrl._buildChestRewardAttractSyncPayload(snapshot)

		pg.me:serverMsg("RPC_CS_PlayChestRewardAttract", payload)
	end

	return batchId
end

function Ctrl.playSyncedAbsorbBatch(payload)
	if not Utils.isTable(payload) then
		Ctrl._warnInvalidAbsorbBatch("sync", "payload_type")

		return nil
	end

	if payload.playMode == FULL_CHEST_PLAY_MODE then
		local fullSnapshot, fullReason, fullBatchCount, fullParticleCount = Ctrl._normalizeSyncedChestRewardBatch(payload)

		if not fullSnapshot then
			Ctrl._warnInvalidAbsorbBatch("full_chest_sync", fullReason, fullBatchCount, fullParticleCount)

			return nil
		end

		local cfg = Ctrl._mergeChestRewardMotionConfig(fullSnapshot.motionCfg)

		return Ctrl._getRuntime():startChestRewardBatch(fullSnapshot, cfg)
	end

	if payload.playMode ~= nil then
		Ctrl._warnInvalidAbsorbBatch("sync", "play_mode")

		return nil
	end

	local snapshot, reason, batchCount, particleCount = Ctrl._normalizeSyncedAbsorbBatch(payload)

	if not snapshot then
		Ctrl._warnInvalidAbsorbBatch("sync", reason, batchCount, particleCount)

		return nil
	end

	local cfg = Ctrl._loadConfig()

	cfg.absorbDurationMin = snapshot.absorbDuration
	cfg.absorbDurationMax = snapshot.absorbDuration

	return Ctrl._getRuntime():startAbsorbBatch(snapshot, cfg)
end

function Ctrl.cancelChestRewardBatch(batchId)
	if not Ctrl._runtime then
		return false
	end

	return Ctrl._runtime:cancelChestRewardBatch(batchId)
end

function Ctrl.cancelAbsorbBatch(batchId)
	if not Ctrl._runtime then
		return false
	end

	return Ctrl._runtime:cancelAbsorbBatch(batchId)
end

function Ctrl.getShowDelay(chestTemplateId)
	local cfg = Ctrl._loadConfig()

	return cfg.fallDurationMax + cfg.stayDuration + cfg.absorbDurationMax
end

function Ctrl.cleanupAll()
	if Ctrl._runtime then
		Ctrl._runtime:cleanup()
	end

	Ctrl._registered = {}

	Ctrl._clearAllPending()
end

function Ctrl.onChestDestroyed(chestId)
	if not chestId then
		return
	end

	for tid, queue in pairs(Ctrl._registered) do
		if queue then
			for i = #queue, 1, -1 do
				if queue[i] and queue[i].chestId == chestId then
					table.remove(queue, i)
				end
			end

			if #queue == 0 then
				Ctrl._registered[tid] = nil
			end
		end
	end
end

return ClientChestRewardAttractCtrl
