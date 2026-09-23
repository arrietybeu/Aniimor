-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Utils\\LeylineFlowerUtils.lua

local LargeAreaIndexData = require("Data.scene_mark_point_large_area_index_data")
local RevertLargeAreaIndexData = require("Data.scene_mark_point_static_id_large_area_data")
local AreaRainbowPetLevelData = require("Data.area_rainbowPet_level_data")
local RainbowPetFreshData = require("Data.rainbowPet_fresh_data")
local LeylineFlowerConfigData = require("Data.leylineflower_config_data")
local LeylinetreePuppetData = require("Data.leylinetree_puppet_data")
local LeylineFlowerTributeData = require("Data.leylineflower_tribute_data")
local MapBlockData = require("Data.map_block_config_data")
local MapAreaData = require("Data.map_area_config_data")
local PuppetData = require("Data.puppet_data")
local LeylineFlowerConst = require("Common.Const.LeylineFlowerConst")
local LoggerManager = require("Core.Log.LoggerManager")
local logger = LoggerManager.getLogger("LeylineFlowerUtils")
local HiddenAreaRainbowPetFreshData = require("Data.hidden_area_rainbowPet_fresh_data")
local Time = require("Core.Common.Time")
local TimerManager = require("Core.Timer.TimerManager")
local SysConfigData = require("Data.sys_config_data")
local FormulaData = require("Data.formula_data")
local AttributeConst = require("Common.Const.AttributeConst")
local LeylineFlowerUtils = {}

LeylineFlowerUtils.INV_SLOT_COUNT_REQUIRED = 60

function LeylineFlowerUtils.calcRainbowEnergy(formulaId, catchCount, petStage, energyFix, multiplier)
	local formula = formulaId and FormulaData[formulaId]

	if not formula or not formula.formula then
		return nil
	end

	return formula.formula(catchCount, petStage) * ((energyFix or 0) + 1) * (multiplier or 1)
end

function LeylineFlowerUtils.getRainbowStageByEnergy(energy)
	energy = energy or 0

	local matchedStage
	local matchedNeed = -1

	for stage, cfg in pairs(AreaRainbowPetLevelData) do
		if energy >= cfg.rainbowEnergyNeed and matchedNeed < cfg.rainbowEnergyNeed then
			matchedStage = stage
			matchedNeed = cfg.rainbowEnergyNeed
		end
	end

	return matchedStage
end

function LeylineFlowerUtils.getTotalRainbowEnergy(flowerInfo)
	if not flowerInfo then
		return 0
	end

	local totalEnergy = flowerInfo.rainbowEnergy or 0
	local seasonEnergyMap = flowerInfo.seasonRainbowEnergyMap

	if not seasonEnergyMap then
		return totalEnergy
	end

	local rawSeasonEnergyMap = seasonEnergyMap

	if type(seasonEnergyMap.getRawTable) == "function" then
		rawSeasonEnergyMap = seasonEnergyMap:getRawTable()
	end

	for _, energy in pairs(rawSeasonEnergyMap) do
		totalEnergy = totalEnergy + (energy or 0)
	end

	return totalEnergy
end

function LeylineFlowerUtils.getRainbowDesc(smallAreaId)
	local rainbowStage = LeylineFlowerUtils.getRainbowStageBySmallAreaId(smallAreaId)
	local stageData = AreaRainbowPetLevelData[rainbowStage] or {}

	return pg.getLocalizationText(stageData.stageDesc or ""), pg.getLocalizationText(stageData.triggerRainbowProbDesc or "")
end

function LeylineFlowerUtils.getBlockIdByStaticId(sceneId, staticId)
	return RevertLargeAreaIndexData[staticId]
end

function LeylineFlowerUtils.getFlowerBlockInfo(sceneId, staticId, spaceId)
	local SceneUtils = require("Common.Utils.SceneUtils")
	local sceneEntityData = SceneUtils.getSceneEntityData(sceneId, spaceId)
	local entityData = sceneEntityData and sceneEntityData[staticId]

	if not entityData then
		return 0, 0
	end

	return entityData.largeAreaId or 0, entityData.levelAreaConfigId or 0
end

function LeylineFlowerUtils.getStaticIdByBlockId(sceneId, blockId)
	return LargeAreaIndexData[blockId]
end

function LeylineFlowerUtils.getMeteorologyGroupBlockId(blockId)
	local visited = {}

	while blockId and not visited[blockId] do
		visited[blockId] = true

		local data = MapBlockData[blockId]
		local groupId = data and data.weatherGroupId

		if not groupId or groupId == blockId then
			break
		end

		blockId = groupId
	end

	return blockId
end

function LeylineFlowerUtils.getNourishMaxCount(player)
	local baseMaxCount = SysConfigData.LEYLINEFLOWER_NOURISH_MAXCOUNT

	if not baseMaxCount then
		return nil
	end

	local combatAttribute = player and player.actorCombatAttribute
	local extraMaxCount = combatAttribute and combatAttribute:getAttribValue(AttributeConst.nourish_max_v)

	return baseMaxCount + (extraMaxCount or 0)
end

function LeylineFlowerUtils.getAreaEthnicGroupList(blockId)
	local ethnicGroupList = {}
	local added = {}
	local staticId = blockId and LeylineFlowerUtils.getStaticIdByBlockId(nil, blockId)
	local flowerConfig = staticId and LeylineFlowerConfigData[staticId]

	if not flowerConfig then
		return ethnicGroupList
	end

	local turboRefreshIds = flowerConfig.turboRefreshId

	if not turboRefreshIds then
		logger:error("@leylineflower turboRefreshId nil, staticId:", staticId, "blockId:", blockId)

		return ethnicGroupList
	end

	for _, createId in ipairs(turboRefreshIds) do
		local createData = LeylinetreePuppetData[createId]
		local ethnicGroup = createData and createData.ethnicGroup

		if ethnicGroup and not added[ethnicGroup] then
			ethnicGroupList[#ethnicGroupList + 1] = ethnicGroup
			added[ethnicGroup] = true
		end
	end

	return ethnicGroupList
end

function LeylineFlowerUtils.getAreaEthnicGroups(blockId)
	local ethnicGroups = {}

	for _, ethnicGroup in ipairs(LeylineFlowerUtils.getAreaEthnicGroupList(blockId)) do
		ethnicGroups[ethnicGroup] = true
	end

	return ethnicGroups
end

function LeylineFlowerUtils.getTributeEthnicGroups(itemId)
	local ethnicGroups = {}
	local tributeData = LeylineFlowerTributeData[itemId]

	if not tributeData then
		return ethnicGroups
	end

	if tributeData.ethnicUps then
		for _, ethnicGroup in ipairs(tributeData.ethnicUps) do
			ethnicGroups[#ethnicGroups + 1] = ethnicGroup
		end
	end

	for index = 1, 5 do
		local ethnicGroup = tributeData["ethnicUp" .. index]

		if ethnicGroup then
			ethnicGroups[#ethnicGroups + 1] = ethnicGroup
		end
	end

	return ethnicGroups
end

function LeylineFlowerUtils.isTurboRefreshTribute(itemId)
	local tributeData = LeylineFlowerTributeData[itemId]

	return tributeData ~= nil and tributeData.turboRefreshId ~= nil
end

function LeylineFlowerUtils.filterEthnicGroupsByArea(ethnicGroups, areaEthnicGroups)
	local result = {}

	for _, ethnicGroup in ipairs(ethnicGroups) do
		if areaEthnicGroups[ethnicGroup] then
			result[#result + 1] = ethnicGroup
		end
	end

	return result
end

function LeylineFlowerUtils.isTributeUselessInArea(itemId, blockId)
	if LeylineFlowerUtils.isTurboRefreshTribute(itemId) then
		return false
	end

	local ethnicGroups = LeylineFlowerUtils.getTributeEthnicGroups(itemId)

	if #ethnicGroups == 0 then
		return false
	end

	local areaEthnicGroups = LeylineFlowerUtils.getAreaEthnicGroups(blockId)

	return #LeylineFlowerUtils.filterEthnicGroupsByArea(ethnicGroups, areaEthnicGroups) == 0
end

function LeylineFlowerUtils.getDisplayEthnicGroups(blockId, tributeItemId)
	if tributeItemId and LeylineFlowerUtils.isTurboRefreshTribute(tributeItemId) then
		return LeylineFlowerUtils.getTributeEthnicGroups(tributeItemId)
	end

	local tributeEthnicGroups = tributeItemId and LeylineFlowerUtils.getTributeEthnicGroups(tributeItemId)

	if tributeEthnicGroups and #tributeEthnicGroups > 0 then
		return LeylineFlowerUtils.filterEthnicGroupsByArea(tributeEthnicGroups, LeylineFlowerUtils.getAreaEthnicGroups(blockId))
	end

	return LeylineFlowerUtils.getAreaEthnicGroupList(blockId)
end

function LeylineFlowerUtils.getLeylineTreeIdByStaticId(sceneId, staticId)
	local blockId = LeylineFlowerUtils.getBlockIdByStaticId(sceneId, staticId)

	if not blockId then
		return nil
	end

	local blockData = MapBlockData[blockId]

	if not blockData then
		return nil
	end

	local areaData = MapAreaData[blockData.mapAreaId]

	if not areaData then
		return nil
	end

	local treeId = areaData.treeId

	if not treeId or treeId == 0 then
		return nil
	end

	return treeId
end

function LeylineFlowerUtils.getLargeAreaIdByEntityStaticId(sceneId, entityStaticId, spaceId)
	local SceneUtils = require("Common.Utils.SceneUtils")
	local entityData = SceneUtils.getSceneEntityData(sceneId, spaceId)
	local data = entityData and entityData[entityStaticId]

	if data and data.largeAreaId and data.largeAreaId ~= 0 then
		return data.largeAreaId
	end

	return nil
end

function LeylineFlowerUtils.getRainbowPetSpawnPosition(sceneId, pointId, spaceId)
	if not pointId then
		return nil
	end

	local SceneUtils = require("Common.Utils.SceneUtils")
	local pointData = SceneUtils.getSceneMarkPointData(sceneId, spaceId)
	local point = pointData and pointData[pointId]

	if not point then
		return nil
	end

	if point.markConfigId ~= LeylineFlowerConst.RAINBOW_PET_POINT_CONFIG_ID then
		return nil
	end

	return point.markPosition
end

function LeylineFlowerUtils.getRainbowStageBySmallAreaId(smallAreaId)
	local infoMap = pg.me.leylineFlowerInfoMap

	if not infoMap then
		return 1
	end

	local flowerId = LeylineFlowerUtils.getStaticIdByBlockId(nil, smallAreaId)

	if not flowerId then
		return 1
	end

	local leylineFlowerInfo = infoMap[flowerId]

	if not leylineFlowerInfo then
		return 1
	end

	return leylineFlowerInfo.rainbowStage or 1
end

function LeylineFlowerUtils.getRainbowPetData(staticId)
	local Utils = require("Common.Utils.Utils")
	local season = Utils.getCurrentSeasonStage()

	if not season then
		return
	end

	local seasonId = season.seasonId
	local freshData = RainbowPetFreshData[seasonId]

	if not freshData then
		logger:error("@leylineflower spawnRainbow seasonData nil, staticId:", staticId, "seasonId:", seasonId)

		return
	end

	local seasonStage = season.stageId
	local stageFreshData = freshData[seasonStage]

	if not stageFreshData then
		logger:error("@leylineflower spawnRainbow stageData nil, staticId:", staticId, "seasonId:", seasonId, "stage:", seasonStage)

		return
	end

	local flowerFreshData = stageFreshData[staticId]

	if not flowerFreshData then
		logger:error("@leylineflower spawnRainbow flowerData nil, staticId:", staticId, "seasonId:", seasonId, "stage:", seasonStage)

		return
	end

	return flowerFreshData
end

function LeylineFlowerUtils.getPuppetStageWithFallback(puppetTemplateId, contextStaticId)
	local pdd = PuppetData[puppetTemplateId]
	local stage = pdd and pdd.stage

	if not stage then
		logger:warn("@leylineflower puppet stage missing, fallback to 1, templateId:", puppetTemplateId, "staticId:", contextStaticId)

		stage = 1
	end

	return stage
end

function LeylineFlowerUtils.getActivityRainbowPetData(staticId)
	local Utils = require("Common.Utils.Utils")
	local flowersData = HiddenAreaRainbowPetFreshData[staticId]

	if not flowersData then
		return nil
	end

	local currentTime = Time.secondCache

	for num, petData in pairs(flowersData) do
		local startTime = Utils.getConfigTimeOfAreaByData(petData.PopStartDayTime)
		local endTime = Utils.getConfigTimeOfAreaByData(petData.PopEndDayTime)

		if startTime and endTime and startTime <= currentTime and currentTime <= endTime then
			return petData
		end
	end

	return nil
end

function LeylineFlowerUtils.getTreeRainbowSpawnData(staticId)
	local activityData = LeylineFlowerUtils.getActivityRainbowPetData(staticId)

	if activityData then
		return activityData.specialRainbowPetWorld, activityData.specialRainbowPetPoint
	end

	local seasonData = LeylineFlowerUtils.getRainbowPetData(staticId)

	if seasonData then
		return seasonData.rainbowPetWorld, seasonData.rainbowPetPoint
	end
end

local activeEffects = {}

function LeylineFlowerUtils.playEffect(pos, effectKey)
	if not pos or not effectKey or effectKey == "" then
		return nil
	end

	if not pg.game or not pg.game.effect then
		return nil
	end

	local effectId = pg.game.effect:playEffectAt(nil, effectKey, pos)

	if effectId and effectId ~= 0 then
		activeEffects[effectId] = true
	end

	return effectId
end

function LeylineFlowerUtils.playOneShotEffect(pos, effectKey)
	if not pos or type(effectKey) ~= "string" or effectKey == "" then
		return nil
	end

	if not pg.game or not pg.game.effect then
		return nil
	end

	local effectId = pg.game.effect:playEffectAt(nil, effectKey, pos)

	if not effectId or effectId == 0 then
		return nil
	end

	return effectId
end

function LeylineFlowerUtils.getEffectDuration(effectKey)
	if type(effectKey) ~= "string" or effectKey == "" then
		return nil
	end

	local EffectData = require("Data.effect_data")
	local effectConfigs = EffectData[effectKey]

	if not effectConfigs then
		return nil
	end

	local maxEndTime = 0

	for _, effectConfig in ipairs(effectConfigs) do
		local duration = tonumber(effectConfig.duration) or 0

		if duration <= 0 then
			return nil
		end

		local endTime = duration + (tonumber(effectConfig.delay) or 0)

		if maxEndTime < endTime then
			maxEndTime = endTime
		end
	end

	return maxEndTime > 0 and maxEndTime or nil
end

function LeylineFlowerUtils.getEffectResIdByValueRange(value, effectConfigs)
	if type(value) ~= "number" or type(effectConfigs) ~= "table" then
		return nil
	end

	local matchedUpperBound, matchedEffectResId, maxUpperBound, maxEffectResId

	for _, effectConfig in ipairs(effectConfigs) do
		if type(effectConfig) == "table" then
			local upperBound = tonumber(effectConfig[1])
			local effectResId = effectConfig[2]

			if upperBound and type(effectResId) == "string" and effectResId ~= "" then
				if not maxUpperBound or maxUpperBound < upperBound then
					maxUpperBound = upperBound
					maxEffectResId = effectResId
				end

				if value <= upperBound and (not matchedUpperBound or upperBound < matchedUpperBound) then
					matchedUpperBound = upperBound
					matchedEffectResId = effectResId
				end
			end
		end
	end

	return matchedEffectResId or maxEffectResId
end

function LeylineFlowerUtils.playRawEffect(pos, effectResId)
	if not pos or type(effectResId) ~= "string" or effectResId == "" then
		return nil
	end

	if not pg.game or not pg.game.effect then
		return nil
	end

	return pg.game.effect:playRawEffectAt(nil, effectResId, pos)
end

function LeylineFlowerUtils.stopEffect(effectId)
	if not effectId then
		return
	end

	if pg.game and pg.game.effect then
		pg.game.effect:stopEffect(0, effectId)
	end

	activeEffects[effectId] = nil
end

function LeylineFlowerUtils.stopAllEffects()
	for effectId in pairs(activeEffects) do
		if pg.game and pg.game.effect then
			pg.game.effect:stopEffect(0, effectId)
		end
	end

	activeEffects = {}
end

function LeylineFlowerUtils.getFlowerPositionByStaticId(staticId, sceneId, spaceId)
	if not staticId or not sceneId or not spaceId then
		return nil
	end

	local SceneUtils = require("Common.Utils.SceneUtils")
	local sceneEntityData = SceneUtils.getSceneEntityData(sceneId, spaceId)
	local entityData = sceneEntityData and sceneEntityData[staticId]

	if not entityData then
		return nil
	end

	local pos = entityData.position

	if not pos or #pos < 3 then
		return nil
	end

	return entityData.position
end

local cameraFocusData = {}

local function invokeCameraCallback(callback)
	if not callback then
		return true
	end

	local callbackResult
	local success, errorMessage = xpcall(function()
		callbackResult = callback()
	end, debug.traceback)

	if not success then
		logger:error(errorMessage)
	end

	return success, callbackResult
end

local function isPlayerInCombat()
	return pg.me and pg.me.isInCombat and pg.me:isInCombat()
end

local function abortCameraFocus(staticId, data)
	if not data or cameraFocusData[staticId] ~= data then
		return
	end

	if data.backBlendFinishTimerId then
		TimerManager.removeTimer(data.backBlendFinishTimerId)

		data.backBlendFinishTimerId = nil
	end

	cameraFocusData[staticId] = nil

	invokeCameraCallback(data.callbacks and data.callbacks.onCancelled)
end

local function waitForPlayerCameraReturn(staticId, data, backBlendTime)
	local finishTimerId

	finishTimerId = TimerManager.addTimer(math.max(backBlendTime or 0, 0), function()
		if cameraFocusData[staticId] ~= data or data.backBlendFinishTimerId ~= finishTimerId then
			return
		end

		data.backBlendFinishTimerId = nil

		local cameraSystem = pg.game and pg.game.camera
		local playerCameraMode = cameraSystem and cameraSystem.playerCameraMode

		if not playerCameraMode or not playerCameraMode:isTop() then
			abortCameraFocus(staticId, data)

			return
		end

		cameraFocusData[staticId] = nil

		invokeCameraCallback(data.callbacks and data.callbacks.onBackBlendFinished)
	end)
	data.backBlendFinishTimerId = finishTimerId
end

function LeylineFlowerUtils.focusCameraToPosition(staticId, targetPos, config, callbacks)
	if not staticId or not targetPos then
		return false
	end

	if not pg.game or not pg.game.camera or not pg.me or isPlayerInCombat() then
		return false
	end

	LeylineFlowerUtils.cancelCameraFocus(staticId)

	config = config or {}

	local focusDelay = config.focusDelay or 1
	local rotateTime = config.rotateTime or 1
	local heightOffset = config.heightOffset or 12
	local focusDuration = config.focusDuration or 2
	local backBlendTime = config.backBlendTime or 0.8
	local startFOV = config.startFOV or 40
	local endFOV = config.endFOV or 70

	callbacks = callbacks or {}

	local focusTimerId = TimerManager.addTimer(focusDelay, function()
		if not pg.game or not pg.game.camera or not pg.me or isPlayerInCombat() then
			abortCameraFocus(staticId, cameraFocusData[staticId])

			return
		end

		local playerPos = pg.me:getPosition()

		if not playerPos then
			abortCameraFocus(staticId, cameraFocusData[staticId])

			return
		end

		local canStartSuccess, canStart = invokeCameraCallback(callbacks.canStart)

		if not canStartSuccess or canStart == false then
			abortCameraFocus(staticId, cameraFocusData[staticId])

			return
		end

		local VirtualCameraBlendFunction = CS.FunPlus.WorldX.VirtualCamera.VirtualCameraBlendFunction
		local cameraPos = Vector3(playerPos[1], playerPos[2] + heightOffset, playerPos[3])
		local dirToTarget = (targetPos - cameraPos).normalized
		local targetRot = Quaternion.LookRotation(dirToTarget)
		local blendSuccess, blendError = xpcall(function()
			pg.game.camera:cameraBlendToFixed(cameraPos, targetRot, endFOV, rotateTime, function()
				pg.me:doEventByData({
					"startAIRemind",
					{
						116
					}
				})

				local backTimerId = TimerManager.addTimer(focusDuration, function()
					local data = cameraFocusData[staticId]

					if data then
						data.backTimerId = nil
					end

					if data and pg.game and pg.game.camera then
						pg.game.camera:cancelBlendToFixed(backBlendTime)
						invokeCameraCallback(callbacks.onBackBlendStarted)
						waitForPlayerCameraReturn(staticId, data, backBlendTime)
					else
						abortCameraFocus(staticId, data)
					end
				end)
				local data = cameraFocusData[staticId]

				if data then
					data.backTimerId = backTimerId
				end
			end, startFOV, {
				blendFunction = VirtualCameraBlendFunction.EaseInOut
			})
		end, debug.traceback)

		if not blendSuccess then
			logger:error("@leylineflower start camera blend failed: %s", tostring(blendError))
			abortCameraFocus(staticId, cameraFocusData[staticId])

			return
		end

		invokeCameraCallback(callbacks.onFocusStarted)

		local data = cameraFocusData[staticId]

		if data then
			data.focusTimerId = nil
		end
	end)

	cameraFocusData[staticId] = {
		pointId = callbacks.pointId,
		focusTimerId = focusTimerId,
		callbacks = callbacks
	}

	return true
end

function LeylineFlowerUtils.cancelCameraFocus(staticId, pointId)
	local data = cameraFocusData[staticId]

	if not data then
		return
	end

	if pointId ~= nil and data.pointId ~= nil and data.pointId ~= pointId then
		return
	end

	if data.focusTimerId then
		TimerManager.removeTimer(data.focusTimerId)
	end

	if data.backTimerId then
		TimerManager.removeTimer(data.backTimerId)
	end

	if data.backBlendFinishTimerId then
		TimerManager.removeTimer(data.backBlendFinishTimerId)
	end

	if pg.game and pg.game.camera then
		pg.game.camera:cancelBlendToFixed(0.3)
	end

	cameraFocusData[staticId] = nil

	invokeCameraCallback(data.callbacks and data.callbacks.onCancelled)
end

function LeylineFlowerUtils.stopAllCameraFocus()
	local staticIds = {}

	for staticId in pairs(cameraFocusData) do
		staticIds[#staticIds + 1] = staticId
	end

	for _, staticId in ipairs(staticIds) do
		LeylineFlowerUtils.cancelCameraFocus(staticId)
	end
end

return LeylineFlowerUtils
