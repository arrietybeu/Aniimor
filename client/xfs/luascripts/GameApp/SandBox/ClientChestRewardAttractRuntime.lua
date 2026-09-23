-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\ClientChestRewardAttractRuntime.lua

local Class = require("Core.Framework.Class")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local TimerManager = require("Core.Timer.TimerManager")
local PhysicsUtils = require("Common.Utils.PhysicsUtils")
local EffectConst = require("Const.EffectConst")
local Vector3 = Vector3
local logger = LoggerManager.getLogger("ClientChestRewardAttractRuntime", "Sandbox", LoggerConst.ERROR)
local TransformParabolaStoppableMotorType = CS.FunPlus.WorldX.GameApp.Effect.TransformParabolaStoppableMotor
local TransformBezierMotorType = CS.FunPlus.WorldX.GameApp.Effect.TransformBezierMotor
local ClientChestRewardAttractRuntime = Class.LightClass("ClientChestRewardAttractRuntime")

function ClientChestRewardAttractRuntime:ctor()
	self._activeVisuals = {}
	self._visualSeq = 0
	self._absorbBatches = {}
	self._chestRewardBatches = {}
	self._rewardTipBatches = {}
	self._batchSeq = 0
end

function ClientChestRewardAttractRuntime:_pickByQuality(map, quality, default)
	if map then
		local eff = map[quality]

		if eff and eff ~= "" then
			return eff
		end

		eff = map[1]

		if eff and eff ~= "" then
			return eff
		end
	end

	return default
end

function ClientChestRewardAttractRuntime:_rollDuration(minV, maxV)
	if not minV or not maxV then
		return minV or maxV or 0.5
	end

	if maxV <= minV then
		return minV
	end

	return minV + math.random() * (maxV - minV)
end

function ClientChestRewardAttractRuntime:_applyParabolaMotorOverride(effectInst, duration, gravityRatio, endPos)
	if not effectInst then
		return
	end

	local motor = effectInst:GetComponent(typeof(TransformParabolaStoppableMotorType))

	if not motor then
		return
	end

	if duration then
		motor.duration = duration
	end

	if gravityRatio then
		motor.gravityRatio = gravityRatio
	end

	if endPos then
		motor:SetEndPos(endPos)
	end
end

function ClientChestRewardAttractRuntime:_applyBezierMotorOverride(effectInst, duration, startUp, endUp, sideRandom)
	if not effectInst then
		return false
	end

	local motor = effectInst:GetComponent(typeof(TransformBezierMotorType))

	if not motor then
		return false
	end

	if duration then
		motor.duration = duration
	end

	if startUp then
		motor.startTangentUp = startUp
	end

	if endUp then
		motor.endTangentUp = endUp
	end

	if sideRandom then
		motor.sideRandom = sideRandom
	end

	return true
end

function ClientChestRewardAttractRuntime:_trailFallEffectOf(quality, cfg)
	return self:_pickByQuality(cfg.trailFallByQuality, quality, cfg.trailFallDefault)
end

function ClientChestRewardAttractRuntime:_trailAbsorbEffectOf(quality, cfg)
	return self:_pickByQuality(cfg.trailAbsorbByQuality, quality, cfg.trailAbsorbDefault)
end

function ClientChestRewardAttractRuntime:_pillarEffectOf(quality, cfg)
	return self:_pickByQuality(cfg.pillarByQuality, quality, cfg.pillarDefault)
end

function ClientChestRewardAttractRuntime:_absorbEffectOf(quality, cfg)
	return self:_pickByQuality(cfg.absorbEffectByQuality, quality, cfg.absorbEffectDefault)
end

function ClientChestRewardAttractRuntime:_allocVisualId()
	self._visualSeq = self._visualSeq + 1

	return self._visualSeq
end

function ClientChestRewardAttractRuntime:_allocBatchId()
	self._batchSeq = self._batchSeq + 1

	return self._batchSeq
end

function ClientChestRewardAttractRuntime:_getTipsCtrl()
	return pg and pg.global and pg.global.ui and pg.global.ui.tips
end

function ClientChestRewardAttractRuntime:_endRewardTipBatch(batchId)
	local batch = self._rewardTipBatches[batchId]

	if not batch then
		return
	end

	if batch.streamOpened then
		local tips = self:_getTipsCtrl()

		if tips and tips.endPropItemStreamBatch then
			tips:endPropItemStreamBatch(batchId)
		end
	end

	self._rewardTipBatches[batchId] = nil
end

function ClientChestRewardAttractRuntime:_showRewardTip(batchId, rewardBatchIndex)
	local batch = self._rewardTipBatches[batchId]
	local rewardBatch = batch and batch.rewardBatches[rewardBatchIndex]

	if not rewardBatch or rewardBatch.tipAppended then
		return false
	end

	rewardBatch.tipAppended = true

	if not batch.showTip then
		return false
	end

	if not batch.streamOpened then
		if logger and logger.warn then
			logger:warn("reward tip stream unavailable", batchId, rewardBatchIndex, rewardBatch.rewardId, rewardBatch.rewardNum)
		end

		return false
	end

	local tips = self:_getTipsCtrl()

	if not tips or not tips.appendPropItemStreamBatch then
		if logger and logger.warn then
			logger:warn("append reward tip api unavailable", batchId, rewardBatchIndex, rewardBatch.rewardId, rewardBatch.rewardNum)
		end

		return false
	end

	local appended = tips:appendPropItemStreamBatch(batchId, {
		id = rewardBatch.rewardId,
		num = rewardBatch.rewardNum,
		quality = rewardBatch.tipQuality
	}) == true

	if not appended and logger and logger.warn then
		logger:warn("append reward tip failed", batchId, rewardBatchIndex, rewardBatch.rewardId, rewardBatch.rewardNum)
	end

	return appended
end

function ClientChestRewardAttractRuntime:_finishRewardTipVisual(batchId, rewardBatchIndex)
	local batch = self._rewardTipBatches[batchId]
	local rewardBatch = batch and batch.rewardBatches[rewardBatchIndex]

	if not rewardBatch or not rewardBatch.dispatched then
		return
	end

	if batch.activeVisualCount > 0 then
		batch.activeVisualCount = batch.activeVisualCount - 1
	end

	if rewardBatch.settledCount < rewardBatch.particleCount then
		rewardBatch.settledCount = rewardBatch.settledCount + 1
	end

	if rewardBatch.settledCount >= rewardBatch.particleCount then
		self:_showRewardTip(batchId, rewardBatchIndex)
	end

	if batch.dispatchFinished and batch.activeVisualCount <= 0 then
		self:_endRewardTipBatch(batchId)
	end
end

function ClientChestRewardAttractRuntime:_finishRewardTipDispatch(batchId)
	local batch = self._rewardTipBatches[batchId]

	if not batch then
		return
	end

	batch.dispatchFinished = true

	if batch.activeVisualCount <= 0 then
		self:_endRewardTipBatch(batchId)
	end
end

function ClientChestRewardAttractRuntime:_onChestRewardTipTimer(batchId, rewardBatchIndex)
	local batch = self._rewardTipBatches[batchId]
	local rewardBatch = batch and batch.rewardBatches[rewardBatchIndex]

	if not batch or batch.tipMode ~= "timer" or not rewardBatch or rewardBatch.tipAppended then
		return
	end

	rewardBatch.tipTimerId = nil

	self:_showRewardTip(batchId, rewardBatchIndex)

	if batch.pendingTipCount > 0 then
		batch.pendingTipCount = batch.pendingTipCount - 1
	end

	if batch.dispatchFinished and batch.pendingTipCount <= 0 then
		self:_endRewardTipBatch(batchId)
	end
end

function ClientChestRewardAttractRuntime:_finishChestRewardTipDispatch(batchId)
	local batch = self._rewardTipBatches[batchId]

	if not batch or batch.tipMode ~= "timer" then
		return
	end

	batch.dispatchFinished = true

	if batch.pendingTipCount <= 0 then
		self:_endRewardTipBatch(batchId)
	end
end

function ClientChestRewardAttractRuntime:_dispatchAbsorbBatchWave(batchId)
	local batch = self._absorbBatches[batchId]

	if not batch then
		return
	end

	local rewardBatchIndex = batch.nextWaveIndex
	local rewardId = batch.itemList[rewardBatchIndex]
	local qualityBatch = batch.qualityList[rewardBatchIndex]
	local rewardNum = batch.rewardNumList[rewardBatchIndex]
	local tipBatch = self._rewardTipBatches[batchId]
	local rewardBatch = {
		tipAppended = false,
		settledCount = 0,
		dispatched = true,
		rewardId = rewardId,
		rewardNum = rewardNum,
		tipQuality = batch.tipQualityList[rewardBatchIndex],
		particleCount = #qualityBatch
	}

	tipBatch.rewardBatches[rewardBatchIndex] = rewardBatch

	for _, quality in ipairs(qualityBatch) do
		tipBatch.activeVisualCount = tipBatch.activeVisualCount + 1

		local visualId = self:_allocVisualId()
		local item = {
			itemId = rewardId,
			quality = quality
		}

		self._activeVisuals[visualId] = {
			rewardTipBatchId = batchId,
			rewardBatchIndex = rewardBatchIndex,
			targetActorId = batch.targetActorId
		}

		self:_playAbsorbVisual(visualId, batch.startPos, item, batch.cfg, batch.absorbDuration, batch.targetActorId)
	end

	batch.nextWaveIndex = batch.nextWaveIndex + 1

	if batch.nextWaveIndex > #batch.itemList then
		if batch.timerId then
			TimerManager.removeTimer(batch.timerId)

			batch.timerId = nil
		end

		self._absorbBatches[batchId] = nil

		self:_finishRewardTipDispatch(batchId)
	end
end

function ClientChestRewardAttractRuntime:startAbsorbBatch(snapshot, cfg)
	local batchId = self:_allocBatchId()
	local streamOpened = false

	if snapshot.showTip then
		local tips = self:_getTipsCtrl()

		streamOpened = tips and tips.beginPropItemStreamBatch and tips:beginPropItemStreamBatch(batchId) == true

		if not streamOpened and logger and logger.warn then
			logger:warn("begin reward tip stream failed", batchId, snapshot.itemCount)
		end
	end

	self._rewardTipBatches[batchId] = {
		dispatchFinished = false,
		activeVisualCount = 0,
		showTip = snapshot.showTip,
		streamOpened = streamOpened == true,
		rewardBatches = {}
	}
	self._absorbBatches[batchId] = {
		nextWaveIndex = 1,
		itemList = snapshot.itemList,
		qualityList = snapshot.qualityList,
		rewardNumList = snapshot.rewardNumList,
		tipQualityList = snapshot.tipQualityList,
		startPos = snapshot.startPos,
		waveInterval = snapshot.waveInterval,
		absorbDuration = snapshot.absorbDuration,
		targetActorId = snapshot.targetActorId,
		cfg = cfg
	}

	self:_dispatchAbsorbBatchWave(batchId)

	local batch = self._absorbBatches[batchId]

	if batch then
		batch.timerId = TimerManager.addRepeatTimer(snapshot.waveInterval, function()
			self:_dispatchAbsorbBatchWave(batchId)
		end)
	end

	return batchId
end

function ClientChestRewardAttractRuntime:_dispatchChestRewardBatchWave(batchId)
	local batch = self._chestRewardBatches[batchId]

	if not batch then
		return
	end

	local rewardBatchIndex = batch.nextWaveIndex
	local rewardId = batch.itemList[rewardBatchIndex]
	local qualityBatch = batch.qualityList[rewardBatchIndex]
	local tipBatch = self._rewardTipBatches[batchId]

	if tipBatch then
		local rewardBatch = {
			tipAppended = false,
			rewardId = rewardId,
			rewardNum = batch.rewardNumList[rewardBatchIndex],
			tipQuality = batch.tipQualityList[rewardBatchIndex]
		}

		tipBatch.rewardBatches[rewardBatchIndex] = rewardBatch
		tipBatch.pendingTipCount = tipBatch.pendingTipCount + 1
		rewardBatch.tipTimerId = TimerManager.addTimer(batch.tipDelay, function()
			self:_onChestRewardTipTimer(batchId, rewardBatchIndex)
		end)
	end

	for _, quality in ipairs(qualityBatch) do
		self:_spawnOneVisual(batch.startPos, {
			itemId = rewardId,
			quality = quality
		}, batch.cfg, batch.targetActorId)
	end

	batch.nextWaveIndex = batch.nextWaveIndex + 1

	if batch.nextWaveIndex > #batch.itemList then
		if batch.timerId then
			TimerManager.removeTimer(batch.timerId)

			batch.timerId = nil
		end

		self._chestRewardBatches[batchId] = nil

		self:_finishChestRewardTipDispatch(batchId)
	end
end

function ClientChestRewardAttractRuntime:startChestRewardBatch(snapshot, cfg)
	local batchId = self:_allocBatchId()

	if snapshot.showTip then
		local tips = self:_getTipsCtrl()
		local streamOpened = tips and tips.beginPropItemStreamBatch and tips:beginPropItemStreamBatch(batchId) == true

		if not streamOpened and logger and logger.warn then
			logger:warn("begin reward tip stream failed", batchId, snapshot.itemCount)
		end

		self._rewardTipBatches[batchId] = {
			dispatchFinished = false,
			showTip = true,
			pendingTipCount = 0,
			tipMode = "timer",
			streamOpened = streamOpened == true,
			rewardBatches = {}
		}
	end

	self._chestRewardBatches[batchId] = {
		nextWaveIndex = 1,
		itemList = snapshot.itemList,
		qualityList = snapshot.qualityList,
		rewardNumList = snapshot.rewardNumList,
		tipQualityList = snapshot.tipQualityList,
		startPos = snapshot.startPos,
		waveInterval = snapshot.waveInterval,
		tipDelay = snapshot.tipDelay,
		targetActorId = snapshot.targetActorId,
		cfg = cfg
	}

	self:_dispatchChestRewardBatchWave(batchId)

	local batch = self._chestRewardBatches[batchId]

	if batch then
		batch.timerId = TimerManager.addRepeatTimer(snapshot.waveInterval, function()
			self:_dispatchChestRewardBatchWave(batchId)
		end)
	end

	return batchId
end

function ClientChestRewardAttractRuntime:playItems(chestPos, itemList, cfg, targetActorId)
	for _, item in ipairs(itemList) do
		self:_spawnOneVisual(chestPos, item, cfg, targetActorId)
	end
end

function ClientChestRewardAttractRuntime:cancelChestRewardBatch(batchId)
	local batch = self._chestRewardBatches[batchId]

	if not batch then
		return false
	end

	if batch.timerId then
		TimerManager.removeTimer(batch.timerId)

		batch.timerId = nil
	end

	self._chestRewardBatches[batchId] = nil

	self:_finishChestRewardTipDispatch(batchId)

	return true
end

function ClientChestRewardAttractRuntime:cancelAbsorbBatch(batchId)
	local batch = self._absorbBatches[batchId]

	if not batch then
		return false
	end

	if batch.timerId then
		TimerManager.removeTimer(batch.timerId)

		batch.timerId = nil
	end

	self._absorbBatches[batchId] = nil

	self:_finishRewardTipDispatch(batchId)

	return true
end

function ClientChestRewardAttractRuntime:cleanup()
	for batchId, batch in pairs(self._chestRewardBatches) do
		if batch and batch.timerId then
			TimerManager.removeTimer(batch.timerId)

			batch.timerId = nil
		end

		self:_finishChestRewardTipDispatch(batchId)
	end

	self._chestRewardBatches = {}

	for batchId, batch in pairs(self._absorbBatches) do
		if batch and batch.timerId then
			TimerManager.removeTimer(batch.timerId)

			batch.timerId = nil
		end

		self:_finishRewardTipDispatch(batchId)
	end

	self._absorbBatches = {}

	local activeVisualIds = {}

	for visualId in pairs(self._activeVisuals) do
		table.insert(activeVisualIds, visualId)
	end

	for _, visualId in ipairs(activeVisualIds) do
		local rec = self._activeVisuals[visualId]

		if rec then
			self._activeVisuals[visualId] = nil

			if rec.fallEffId and pg.game and pg.game.effect then
				local fallEffId = rec.fallEffId

				rec.fallEffId = nil

				pcall(function()
					pg.game.effect:stopEffect(0, fallEffId, false, true)
				end)
			end

			if rec.marker then
				CS.UnityEngine.Object.Destroy(rec.marker)

				rec.marker = nil
			end

			if rec.pillarEffId then
				pg.game.effect:stopEffect(0, rec.pillarEffId, false, true)

				rec.pillarEffId = nil
			end

			if rec.timer then
				TimerManager.removeTimer(rec.timer)

				rec.timer = nil
			end

			if rec.absorbTimeoutTimer then
				TimerManager.removeTimer(rec.absorbTimeoutTimer)

				rec.absorbTimeoutTimer = nil
			end

			if rec.absorbEffId and pg.game and pg.game.effect then
				pcall(function()
					pg.game.effect:stopEffect(0, rec.absorbEffId, false, true)
				end)

				rec.absorbEffId = nil
			end

			if rec.rewardTipBatchId ~= nil then
				self:_finishRewardTipVisual(rec.rewardTipBatchId, rec.rewardBatchIndex)
			end
		end
	end

	self._activeVisuals = {}

	local remainingBatchIds = {}

	for batchId in pairs(self._rewardTipBatches) do
		table.insert(remainingBatchIds, batchId)
	end

	for _, batchId in ipairs(remainingBatchIds) do
		local batch = self._rewardTipBatches[batchId]

		if batch then
			if batch.tipMode == "timer" then
				batch.dispatchFinished = true

				local rewardBatchIndexes = {}

				for rewardBatchIndex in pairs(batch.rewardBatches) do
					table.insert(rewardBatchIndexes, rewardBatchIndex)
				end

				for _, rewardBatchIndex in ipairs(rewardBatchIndexes) do
					local rewardBatch = batch.rewardBatches[rewardBatchIndex]

					if rewardBatch and not rewardBatch.tipAppended then
						if rewardBatch.tipTimerId then
							TimerManager.removeTimer(rewardBatch.tipTimerId)

							rewardBatch.tipTimerId = nil
						end

						self:_onChestRewardTipTimer(batchId, rewardBatchIndex)
					end
				end
			else
				batch.dispatchFinished = true

				for rewardBatchIndex, rewardBatch in pairs(batch.rewardBatches) do
					if rewardBatch.dispatched and rewardBatch.settledCount < rewardBatch.particleCount then
						rewardBatch.settledCount = rewardBatch.particleCount

						self:_showRewardTip(batchId, rewardBatchIndex)
					end
				end

				self:_endRewardTipBatch(batchId)
			end
		end
	end

	self._rewardTipBatches = {}
end

function ClientChestRewardAttractRuntime:_spawnOneVisual(chestPos, item, cfg, targetActorId)
	if not chestPos then
		return
	end

	local visualId = self:_allocVisualId()
	local angle = math.random() * 2 * math.pi
	local r = math.sqrt(math.random()) * cfg.radius
	local landPos = Vector3(chestPos.x + r * math.cos(angle), chestPos.y, chestPos.z + r * math.sin(angle))

	if PhysicsUtils and PhysicsUtils.getGroundPos then
		local groundPos, hit = PhysicsUtils.getGroundPos(Vector3(landPos.x, landPos.y + 2, landPos.z), 5)

		if hit and groundPos then
			landPos = groundPos
		end
	end

	local marker = CS.UnityEngine.GameObject("ChestRewardMarker_" .. tostring(visualId))

	marker.transform.position = landPos

	local trailEff = self:_trailFallEffectOf(item.quality, cfg)

	if not trailEff or trailEff == "" then
		if logger and logger.warn then
			logger:warn("trail effect missing", item.itemId, item.quality)
		end

		CS.UnityEngine.Object.Destroy(marker)

		return
	end

	local fallDur = self:_rollDuration(cfg.fallDurationMin, cfg.fallDurationMax)

	self._activeVisuals[visualId] = {
		marker = marker,
		targetActorId = targetActorId
	}

	local extraInfo = {
		position = chestPos,
		rotation = Vector3.zero,
		followType = EffectConst.FollowType.Global,
		mountType = EffectConst.MountType.Motor,
		targetTrans = marker.transform,
		endCallback = function()
			self:_onLand(visualId, landPos, item, cfg)
		end,
		loadCallback = function(effectItem)
			if not self._activeVisuals[visualId] then
				return
			end

			if not effectItem or not effectItem.effectObj then
				return
			end

			self:_applyParabolaMotorOverride(effectItem.effectObj, fallDur, cfg.fallGravity, landPos)
		end
	}
	local fallEffId = pg.game.effect:playEffect(0, trailEff, extraInfo)
	local rec = self._activeVisuals[visualId]

	if rec and not rec.landed then
		rec.fallEffId = fallEffId
	end

	return visualId
end

function ClientChestRewardAttractRuntime:_onLand(visualId, landPos, item, cfg)
	local rec = self._activeVisuals[visualId]

	if not rec then
		return
	end

	if rec.landed then
		return
	end

	rec.landed = true
	rec.fallEffId = nil

	if rec.marker then
		CS.UnityEngine.Object.Destroy(rec.marker)

		rec.marker = nil
	end

	local pillarEff = self:_pillarEffectOf(item.quality, cfg)

	if pillarEff and pillarEff ~= "" then
		rec.pillarEffId = pg.game.effect:playEffectAt(0, pillarEff, landPos)
	elseif logger and logger.warn then
		logger:warn("pillar effect missing", item.itemId, item.quality)
	end

	rec.timer = TimerManager.addTimer(cfg.stayDuration, function()
		self:_onStayDone(visualId, landPos, item, cfg)
	end)
end

function ClientChestRewardAttractRuntime:_getAbsorbTarget(targetActorId)
	if pg.me and pg.me.actorId == targetActorId then
		return pg.me
	end

	if pg and pg.getEntityByActorId then
		return pg.getEntityByActorId(targetActorId)
	end

	return nil
end

function ClientChestRewardAttractRuntime:_settleFailedAbsorbVisual(visualId)
	local rec = self._activeVisuals[visualId]

	if not rec then
		return false
	end

	self._activeVisuals[visualId] = nil

	if rec.absorbTimeoutTimer then
		TimerManager.removeTimer(rec.absorbTimeoutTimer)

		rec.absorbTimeoutTimer = nil
	end

	if rec.absorbEffId and pg.game and pg.game.effect then
		pcall(function()
			pg.game.effect:stopEffect(0, rec.absorbEffId, false, true)
		end)

		rec.absorbEffId = nil
	end

	if rec.rewardTipBatchId ~= nil then
		self:_finishRewardTipVisual(rec.rewardTipBatchId, rec.rewardBatchIndex)
	end

	return true
end

function ClientChestRewardAttractRuntime:_playAbsorbVisual(visualId, startPos, item, cfg, absorbDuration, targetActorId)
	local rec = self._activeVisuals[visualId]

	if not rec then
		return false
	end

	local target = self:_getAbsorbTarget(targetActorId)

	if not target or not target.eModel or not target.eModel:CheckPositionAgent() then
		self:_settleFailedAbsorbVisual(visualId)

		return false
	end

	local trailEff = self:_trailAbsorbEffectOf(item.quality, cfg)

	if not trailEff or trailEff == "" then
		self:_settleFailedAbsorbVisual(visualId)

		return false
	end

	local playerHeight = 0

	if target.getHeight then
		playerHeight = target:getHeight() or 0
	end

	local extraInfo = {
		position = startPos,
		rotation = Vector3.zero,
		followType = EffectConst.FollowType.Global,
		mountType = EffectConst.MountType.Motor,
		targetTransActorId = targetActorId,
		targetTransOffset = Vector3(0, playerHeight * 0.5, 0),
		endCallback = function()
			self:_onAbsorbDone(visualId, item, cfg, targetActorId)
		end,
		loadCallback = function(effectItem)
			local activeRec = self._activeVisuals[visualId]

			if not activeRec then
				return
			end

			local currentTarget = self:_getAbsorbTarget(targetActorId)

			if not effectItem or not effectItem.effectObj or not currentTarget or not currentTarget.eModel or not currentTarget.eModel:CheckPositionAgent() then
				self:_settleFailedAbsorbVisual(visualId)

				return
			end

			local motorApplied = self:_applyBezierMotorOverride(effectItem.effectObj, absorbDuration, cfg.absorbStartUp, cfg.absorbEndUp, cfg.absorbSideRandom)

			if not motorApplied then
				self:_settleFailedAbsorbVisual(visualId)
			end
		end
	}

	if not pg.game or not pg.game.effect or not pg.game.effect.playEffect then
		self:_settleFailedAbsorbVisual(visualId)

		return false
	end

	local played, effectId = pcall(function()
		return pg.game.effect:playEffect(0, trailEff, extraInfo)
	end)

	if not played or not effectId or effectId == 0 then
		self:_settleFailedAbsorbVisual(visualId)

		if logger and logger.warn then
			logger:warn("play absorb visual failed", visualId, item.itemId, item.quality, targetActorId, effectId)
		end

		return false
	end

	rec = self._activeVisuals[visualId]

	if not rec then
		pcall(function()
			pg.game.effect:stopEffect(0, effectId, false, true)
		end)

		return false
	end

	rec.absorbEffId = effectId
	rec.absorbTimeoutTimer = TimerManager.addTimer(absorbDuration + 1, function()
		self:_settleFailedAbsorbVisual(visualId)
	end)

	return true
end

function ClientChestRewardAttractRuntime:_onStayDone(visualId, landPos, item, cfg)
	local rec = self._activeVisuals[visualId]

	if not rec then
		return
	end

	if rec.pillarEffId then
		pg.game.effect:stopEffect(0, rec.pillarEffId, false, true)

		rec.pillarEffId = nil
	end

	rec.timer = nil

	local absorbDur = self:_rollDuration(cfg.absorbDurationMin, cfg.absorbDurationMax)
	local targetActorId = rec.targetActorId or pg.me and pg.me.actorId

	self:_playAbsorbVisual(visualId, landPos, item, cfg, absorbDur, targetActorId)
end

function ClientChestRewardAttractRuntime:_onAbsorbDone(visualId, item, cfg, targetActorId)
	local rec = self._activeVisuals[visualId]

	if not rec then
		return
	end

	self._activeVisuals[visualId] = nil

	if rec.absorbTimeoutTimer then
		TimerManager.removeTimer(rec.absorbTimeoutTimer)

		rec.absorbTimeoutTimer = nil
	end

	rec.absorbEffId = nil

	if rec.rewardTipBatchId ~= nil then
		self:_finishRewardTipVisual(rec.rewardTipBatchId, rec.rewardBatchIndex)
	end

	local target = self:_getAbsorbTarget(targetActorId)

	if target and target.eModel and target.eModel:CheckPositionAgent() then
		local absorbEff = self:_absorbEffectOf(item.quality, cfg)

		if absorbEff and absorbEff ~= "" then
			local playerHeight = 0

			if target.getHeight then
				playerHeight = target:getHeight() or 0
			end

			target:playEffect(absorbEff, {
				position = Vector3(0, playerHeight * cfg.absorbEffectOffsetY, 0)
			})
		end
	end

	if pg.me and cfg.absorbSound and cfg.absorbSound ~= "" then
		pg.game.audio:playEvent(cfg.absorbSound)
	end
end

return ClientChestRewardAttractRuntime
