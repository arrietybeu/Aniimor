-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Evolution\\SoulEggEvolutionSystem.lua

local SystemBase = require("GameApp.Core.SystemBase")
local Class = require("Core.Framework.Class")
local ClientConst = require("Const.ClientConst")
local LoggerManager = require("Core.Log.LoggerManager")
local UIConst = require("Const.UIConst")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local TimerManager = require("Core.Timer.TimerManager")
local SoulEggEvolutionConst = require("Common.Const.EvolutionConst").SoulEggEvolution
local LoggerConst = require("Core.Log.LoggerConst")
local Utils = require("Common.Utils.Utils")
local logger = LoggerManager.getLogger("SoulEggEvolutionSystem")
local AudioConst = require("Const.AudioConst")
local CaptureUtils = require("Utils.CaptureUtils")
local ClientEffectUtils = require("Utils.ClientEffectUtils")
local PetFertilityConst = require("Const.PetFertilityConst")
local PetTransmogUtils = require("GameApp.PetTransmog.PetTransmogUtils")
local PetCubeItemData = require("Data.pet_hatch_egg_cube_data")
local PetEvolveData = require("Data.pet_evolve_data")
local PetTalentRandomGroupData = require("Data.pet_talent_random_group_data")
local ShopClassifyData = require("Data.shop_classify_data")
local MessageName = require("Const.MessageName")
local EvolutionSucConst = SoulEggEvolutionConst.EvolutionSuccess
local Vector3 = Vector3
local GameObject = CS.UnityEngine.GameObject
local PARTICLE_SYSTEM_STOP_EMITTING_AND_CLEAR = CS.UnityEngine.ParticleSystemStopBehavior.StopEmittingAndClear
local HOST_READY_TIMEOUT_SECONDS = 15
local SOUL_EGG_BREAK_LOAD_TIMEOUT_SECONDS = 5
local SOUL_EGG_MODEL_READY_TIMEOUT_SECONDS = 10
local SOUL_EGG_EXIT_SHOW_DURATION_SECONDS = 0.8
local SOURCE_JUMP_OPEN_TIMEOUT_SECONDS = 1
local SOURCE_JUMP_LOAD_TIMEOUT_SECONDS = 15
local SOURCE_JUMP_LOAD_POLL_INTERVAL_SECONDS = 0.1
local MAX_RECORDED_TIPS = 10
local ENABLE_CHOOSE_CUBE_EGG_OUT_EFFECT = false
local CUBE_SWITCH_EFFECT_PRELOAD_TIMEOUT_SECONDS = 10
local CHOOSE_CUBE_BACKGROUND_EFFECT_TIMEOUT_SECONDS = 10
local CHOOSE_CUBE_BACKGROUND_PREWARM_LOCAL_Z = -99
local CHOOSE_CUBE_BACKGROUND_VISIBLE_LOCAL_Z = 0
local CHOOSE_EGG_BACKGROUND_LOCAL_X = 0
local CHOOSE_CUBE_LINK_EGG_WORLD_Z_OFFSET = -0.18
local CHOOSE_CUBE_LINK_CUBE_WORLD_Z_OFFSET = 0.01
local CHOOSE_CUBE_LINK_HIDDEN_WORLD_POS = Vector3(0, -9999, 0)
local MAX_PENDING_HATCH_REQUESTS = 16
local HATCH_OVERLAY_UI_IDS = {
	UIConst.UI_ID_PET_FERTILITY_CHOOSE_BALL,
	UIConst.UI_ID_PET_FERTILITY_INCUBATE,
	UIConst.UI_ID_PET_FERTILITY_INCUBATE_RESULT,
	UIConst.UI_ID_PET_FERTILITY_POPUP_CHOOSE_BALL
}
local SoulEggEvolutionSystem = Class.LightClass("SoulEggEvolutionSystem", SystemBase)

function SoulEggEvolutionSystem:getMessageBindMap()
	return {
		[MessageName.UI_ON_OPEN] = "onUIOpen",
		[MessageName.UI_ON_CLOSE] = "onUIClose"
	}
end

function SoulEggEvolutionSystem:onCtor()
	SoulEggEvolutionSystem.super.onCtor(self)

	self.soulEggEvolutionTimerList = {}
	self._tipsInfoList = nil
	self._recordedTipsReadyToShow = false
	self._isInEggTouchPlaying = false
	self._isInEvolution = false
	self._runToken = 0
	self._pendingHatchRequests = {}
	self._cubeSwitchEffectPreloadToken = 0
	self._cubeSwitchContext = nil
	self._sourceJumpTargetUIId = nil
	self._sourceJumpRunToken = nil
	self._sourceJumpTargetOpened = false
	self._sourceJumpOpenWatchdogTimer = nil
	self._sourceJumpLoadingWaited = false
	self._sourceJumpLoadWatchdogRemaining = 0
end

function SoulEggEvolutionSystem:_getChooseCubePreloadInfos()
	local cubeInfos = {}

	for itemId, cubeCfg in pairs(PetCubeItemData or {}) do
		local ballCfg = CaptureUtils.getBallCfg(itemId)
		local talentGroup = ballCfg and ballCfg.randomTalentGroup

		if ballCfg and ballCfg.model and (not talentGroup or PetTalentRandomGroupData[talentGroup]) then
			cubeInfos[#cubeInfos + 1] = {
				itemId = itemId,
				resId = ballCfg.model,
				sort = cubeCfg.sort or 0
			}
		end
	end

	table.sort(cubeInfos, function(a, b)
		if a.sort ~= b.sort then
			return a.sort < b.sort
		end

		return a.itemId < b.itemId
	end)

	return cubeInfos
end

function SoulEggEvolutionSystem:_getChooseCubeFxGroups(cubeInfos)
	local cubeFxGroups = {}

	for _, cubeInfo in ipairs(cubeInfos or {}) do
		local cubeFxs = self:getCubeFxsByCubeItemId(cubeInfo.itemId)

		if cubeFxs and cubeFxs.fxGroupKey ~= nil then
			cubeFxGroups[cubeFxs.fxGroupKey] = cubeFxs
		end
	end

	return cubeFxGroups
end

function SoulEggEvolutionSystem:_preloadChooseCubeEffects(cubeFxGroups)
	if self._chooseCubePreloadEffects then
		return
	end

	local preloadEffects = {}

	for _, cubeFxs in pairs(cubeFxGroups or {}) do
		for _, fxKey in ipairs({
			cubeFxs.CubeInKey,
			cubeFxs.CubeOutKey,
			cubeFxs.EggInKey,
			cubeFxs.EggOutKey
		}) do
			local resId = fxKey and PetFertilityConst.FxResIds[fxKey]

			if resId and not preloadEffects[resId] then
				pg.global.effectMgr:PreLoadEffect(resId)

				preloadEffects[resId] = true
			end
		end
	end

	local switchFxResId = PetFertilityConst.FxResIds[PetFertilityConst.FxKeys.AllCubeSwitch]

	if switchFxResId and not preloadEffects[switchFxResId] then
		pg.global.effectMgr:PreLoadEffect(switchFxResId)

		preloadEffects[switchFxResId] = true
	end

	self._chooseCubePreloadEffects = preloadEffects
end

function SoulEggEvolutionSystem:_releaseChooseCubeEffects()
	local preloadEffects = self._chooseCubePreloadEffects

	if not preloadEffects then
		return
	end

	self._chooseCubePreloadEffects = nil

	for resId, _ in pairs(preloadEffects) do
		pg.global.effectMgr:UnPreLoadEffect(resId)
	end
end

function SoulEggEvolutionSystem:_clearCubeSwitchDelayTimer()
	if self.delayClearOldTimer then
		TimerManager.removeTimer(self.delayClearOldTimer)

		self.delayClearOldTimer = nil
	end

	if self._cubeSwitchOutDelayTimer then
		TimerManager.removeTimer(self._cubeSwitchOutDelayTimer)

		self._cubeSwitchOutDelayTimer = nil
	end
end

function SoulEggEvolutionSystem:_clearCubeSwitchEffectHideTimer()
	if self._cubeSwitchEffectHideTimer then
		TimerManager.removeTimer(self._cubeSwitchEffectHideTimer)

		self._cubeSwitchEffectHideTimer = nil
	end
end

function SoulEggEvolutionSystem:_clearCubeSwitchEffectPreload()
	self._cubeSwitchEffectPreloadToken = (self._cubeSwitchEffectPreloadToken or 0) + 1
	self._cubeSwitchEffectPreloadPending = false
	self._cubeSwitchEffectPreloadCallback = nil

	if self._cubeSwitchEffectPreloadTimer then
		TimerManager.removeTimer(self._cubeSwitchEffectPreloadTimer)

		self._cubeSwitchEffectPreloadTimer = nil
	end
end

function SoulEggEvolutionSystem:_clearChooseCubeBackgroundEffectPreload()
	self._chooseCubeBackgroundEffectPreloadToken = (self._chooseCubeBackgroundEffectPreloadToken or 0) + 1

	if self._chooseCubeBackgroundEffectPreloadTimer then
		TimerManager.removeTimer(self._chooseCubeBackgroundEffectPreloadTimer)

		self._chooseCubeBackgroundEffectPreloadTimer = nil
	end
end

local function createChooseCubeEffectHolder(name, parentTransform, localPositionX)
	if IsNil(parentTransform) then
		return nil
	end

	local holder = GameObject(name)

	holder.transform:SetParent(parentTransform, false)

	holder.transform.localPosition = Vector3(localPositionX or 0, 0, CHOOSE_CUBE_BACKGROUND_PREWARM_LOCAL_Z)
	holder.transform.localRotation = Quaternion.identity
	holder.transform.localScale = Vector3.one

	return holder
end

local function destroyChooseCubeEffectHolder(holder)
	if IsNil(holder) then
		return
	end

	holder:SetActiveEx(false)
	GameObject.Destroy(holder)
end

local function collectChooseCubeOneShotParticleSystems(effectObject)
	local oneShotParticleSystems = {}

	if IsNil(effectObject) then
		return oneShotParticleSystems
	end

	local ParticleSystemType = typeof(CS.UnityEngine.ParticleSystem)
	local particleSystems = effectObject:GetComponentsInChildren(ParticleSystemType, true)

	if not particleSystems then
		return oneShotParticleSystems
	end

	for i = 0, particleSystems.Length - 1 do
		local particleSystem = particleSystems[i]

		if particleSystem and NotNil(particleSystem) then
			local mainModule = particleSystem.main

			if not mainModule.loop then
				oneShotParticleSystems[#oneShotParticleSystems + 1] = particleSystem
			end
		end
	end

	return oneShotParticleSystems
end

local function replayChooseCubeOneShotParticleSystems(oneShotParticleSystems)
	for _, particleSystem in ipairs(oneShotParticleSystems or {}) do
		if particleSystem and NotNil(particleSystem) then
			particleSystem:Stop(false, PARTICLE_SYSTEM_STOP_EMITTING_AND_CLEAR)
			particleSystem:Play(false)
		end
	end
end

local function stopChooseCubeOneShotParticleSystems(oneShotParticleSystems)
	for _, particleSystem in ipairs(oneShotParticleSystems or EMPTY_TABLE) do
		if particleSystem and NotNil(particleSystem) then
			particleSystem:Stop(false, PARTICLE_SYSTEM_STOP_EMITTING_AND_CLEAR)
		end
	end
end

function SoulEggEvolutionSystem:_hideCubeSwitchEffect()
	local entry = self._cubeSwitchEffectEntry

	if not entry or IsNil(entry.holder) then
		return
	end

	entry.holder.transform.localPosition = Vector3(0, 0, CHOOSE_CUBE_BACKGROUND_PREWARM_LOCAL_Z)

	stopChooseCubeOneShotParticleSystems(entry.particleSystems)
end

function SoulEggEvolutionSystem:_replayCubeSwitchEffect()
	local entry = self._cubeSwitchEffectEntry

	if not entry or IsNil(entry.effectObject) or IsNil(entry.holder) or not entry.particleSystems then
		return false
	end

	entry.holder.transform.localPosition = Vector3(0, 0, CHOOSE_CUBE_BACKGROUND_VISIBLE_LOCAL_Z)

	replayChooseCubeOneShotParticleSystems(entry.particleSystems)

	return true
end

function SoulEggEvolutionSystem:_scheduleCubeSwitchEffectHide()
	self:_clearCubeSwitchEffectHideTimer()

	local duration = PetFertilityConst.CubeSwitchEffectTime

	if not duration or duration <= 0 then
		self:_hideCubeSwitchEffect()

		return
	end

	local timerId

	timerId = TimerManager.addTimer(duration, function()
		if self._cubeSwitchEffectHideTimer ~= timerId then
			return
		end

		self._cubeSwitchEffectHideTimer = nil

		self:_hideCubeSwitchEffect()
	end)
	self._cubeSwitchEffectHideTimer = timerId
end

function SoulEggEvolutionSystem:_cancelCubeSwitch()
	self:_clearCubeSwitchDelayTimer()
	self:_clearCubeSwitchEffectHideTimer()

	self._cubeSwitchContext = nil

	self:_hideCubeSwitchEffect()
end

function SoulEggEvolutionSystem:_releaseCubeSwitchEffect()
	self:_clearCubeSwitchEffectPreload()
	self:_cancelCubeSwitch()

	local entry = self._cubeSwitchEffectEntry

	self._cubeSwitchEffectEntry = nil

	if not entry then
		return
	end

	if entry.effectId and entry.scene and not entry.scene.expire then
		entry.scene:releaseEffect(entry.effectId)
	end

	destroyChooseCubeEffectHolder(entry.holder)
end

function SoulEggEvolutionSystem:_completeCubeSwitchEffectPreload(preloadToken, success)
	if preloadToken ~= self._cubeSwitchEffectPreloadToken or not self._cubeSwitchEffectPreloadPending then
		return
	end

	self._cubeSwitchEffectPreloadPending = false

	if self._cubeSwitchEffectPreloadTimer then
		TimerManager.removeTimer(self._cubeSwitchEffectPreloadTimer)

		self._cubeSwitchEffectPreloadTimer = nil
	end

	local callback = self._cubeSwitchEffectPreloadCallback

	self._cubeSwitchEffectPreloadCallback = nil

	if not success then
		local entry = self._cubeSwitchEffectEntry

		self._cubeSwitchEffectEntry = nil

		if entry then
			if entry.effectId and entry.scene and not entry.scene.expire then
				entry.scene:releaseEffect(entry.effectId)
			end

			destroyChooseCubeEffectHolder(entry.holder)
		end
	end

	if callback then
		callback(success)
	end
end

function SoulEggEvolutionSystem:_preloadCubeSwitchEffect(runToken, scene, onComplete)
	self:_releaseCubeSwitchEffect()

	local preloadToken = self._cubeSwitchEffectPreloadToken

	self._cubeSwitchEffectPreloadPending = true
	self._cubeSwitchEffectPreloadCallback = onComplete

	local holder = createChooseCubeEffectHolder("ChooseCubeSwitchEffect", scene.catchBallRootTransform)

	if not holder then
		self:_completeCubeSwitchEffectPreload(preloadToken, false)

		return
	end

	local entry = {
		holder = holder,
		scene = scene
	}

	self._cubeSwitchEffectEntry = entry

	local switchFxResId = PetFertilityConst.FxResIds[PetFertilityConst.FxKeys.AllCubeSwitch]

	if not switchFxResId then
		self:_completeCubeSwitchEffectPreload(preloadToken, false)

		return
	end

	local switchFxInfo = self:getDefaultFxExtraInfo()

	switchFxInfo.scale = PetFertilityConst.CubeSwitchEffectScale

	local cubeWorldPos = scene.catchBallRootTransform.position
	local switchEffectOffsetPos = PetFertilityConst.CubeSwitchEffectOffsetPos

	switchFxInfo.position = switchEffectOffsetPos

	local defaultSwitchLoadCallback = switchFxInfo.loadCallback

	function switchFxInfo.loadCallback(effectItem)
		if preloadToken ~= self._cubeSwitchEffectPreloadToken or not self._cubeSwitchEffectPreloadPending then
			return
		end

		if defaultSwitchLoadCallback then
			defaultSwitchLoadCallback(effectItem)
		end

		if not self:_isRunContextValid(runToken, scene) or not effectItem or IsNil(effectItem.effectObj) then
			self:_completeCubeSwitchEffectPreload(preloadToken, false)

			return
		end

		entry.effectObject = effectItem.effectObj
		entry.particleSystems = collectChooseCubeOneShotParticleSystems(effectItem.effectObj)

		if #entry.particleSystems == 0 then
			self:_completeCubeSwitchEffectPreload(preloadToken, false)

			return
		end

		self:_hideCubeSwitchEffect()
		self:_completeCubeSwitchEffectPreload(preloadToken, true)
	end

	local effectId = scene:playRawEffectOnCubeRoot(switchFxResId, switchFxInfo, true, holder.transform)

	entry.effectId = effectId

	if self._cubeSwitchEffectEntry ~= entry then
		if effectId and effectId ~= 0 and not scene.expire then
			scene:releaseEffect(effectId)
		end

		return
	end

	if not effectId or effectId == 0 then
		self:_completeCubeSwitchEffectPreload(preloadToken, false)

		return
	end

	if self._cubeSwitchEffectPreloadPending then
		self._cubeSwitchEffectPreloadTimer = TimerManager.addTimer(CUBE_SWITCH_EFFECT_PRELOAD_TIMEOUT_SECONDS, function()
			self:_completeCubeSwitchEffectPreload(preloadToken, false)
		end)
	end
end

local function findChooseCubeBackgroundLineRenderer(effectTransform)
	if IsNil(effectTransform) then
		return nil
	end

	local searchRootTs = effectTransform:Find("All")

	if IsNil(searchRootTs) then
		searchRootTs = effectTransform
	end

	local LineRendererType = typeof(CS.UnityEngine.LineRenderer)
	local lineRenderer = searchRootTs:GetComponentInChildren(LineRendererType, true)

	if IsNil(lineRenderer) and searchRootTs ~= effectTransform then
		lineRenderer = effectTransform:GetComponentInChildren(LineRendererType, true)
	end

	return lineRenderer
end

local function getChooseCubeBackgroundLinePositions(sceneEggTs, catchBallRootTs)
	if IsNil(sceneEggTs) or IsNil(catchBallRootTs) then
		return nil, nil
	end

	local eggPosition = sceneEggTs.position
	local catchBallPosition = catchBallRootTs.position
	local eggWorldPosition = Vector3(eggPosition.x, eggPosition.y, eggPosition.z + CHOOSE_CUBE_LINK_EGG_WORLD_Z_OFFSET)
	local catchBallWorldPosition = Vector3(catchBallPosition.x, catchBallPosition.y, catchBallPosition.z + CHOOSE_CUBE_LINK_CUBE_WORLD_Z_OFFSET)

	return eggWorldPosition, catchBallWorldPosition
end

local function setChooseCubeBackgroundLineVisible(lineRenderer, visible, sceneEggTs, catchBallRootTs)
	if IsNil(lineRenderer) then
		return
	end

	local eggWorldPosition, catchBallWorldPosition

	if visible then
		eggWorldPosition, catchBallWorldPosition = getChooseCubeBackgroundLinePositions(sceneEggTs, catchBallRootTs)
	end

	if not eggWorldPosition or not catchBallWorldPosition then
		eggWorldPosition = CHOOSE_CUBE_LINK_HIDDEN_WORLD_POS
		catchBallWorldPosition = CHOOSE_CUBE_LINK_HIDDEN_WORLD_POS
	end

	lineRenderer:SetPosition(0, eggWorldPosition)
	lineRenderer:SetPosition(1, catchBallWorldPosition)
end

local function onChooseCubeBackgroundLineLoaded(effectTransform, sceneEggTs, catchBallRootTs)
	local lineRenderer = findChooseCubeBackgroundLineRenderer(effectTransform)

	setChooseCubeBackgroundLineVisible(lineRenderer, true, sceneEggTs, catchBallRootTs)
end

function SoulEggEvolutionSystem:_releaseChooseCubeBackgroundEffects()
	self:_clearChooseCubeBackgroundEffectPreload()

	local effectPool = self._chooseCubeBackgroundEffectPool

	self._chooseCubeBackgroundEffectPool = nil
	self._activeChooseCubeFxGroupKey = nil

	if not effectPool then
		return
	end

	local scene = self.evolutionScene

	if scene and not scene.expire then
		for _, poolEntry in pairs(effectPool) do
			scene:releaseEffect(poolEntry.cubeEffectId)
		end
	end

	if self.soulEggEntity then
		self.soulEggEntity:stopChooseCubeEffect()
	end

	for _, poolEntry in pairs(effectPool) do
		destroyChooseCubeEffectHolder(poolEntry.cubeEffectHolder)
		destroyChooseCubeEffectHolder(poolEntry.eggEffectHolder)
		destroyChooseCubeEffectHolder(poolEntry.eggOutEffectHolder)
	end
end

function SoulEggEvolutionSystem:_preloadChooseCubeBackgroundEffects(runToken, scene, eggEntity, cubeFxGroups, onComplete)
	self:_releaseChooseCubeBackgroundEffects()

	local preloadToken = self._chooseCubeBackgroundEffectPreloadToken
	local effectPool = {}

	self._chooseCubeBackgroundEffectPool = effectPool
	self._activeChooseCubeFxGroupKey = nil

	local building = true
	local completed = false
	local preloadFailed = false
	local expectedCount = 0
	local loadedCount = 0
	local loadedEffectMap = {}

	local function finish(success)
		if completed or preloadToken ~= self._chooseCubeBackgroundEffectPreloadToken then
			return
		end

		completed = true

		if self._chooseCubeBackgroundEffectPreloadTimer then
			TimerManager.removeTimer(self._chooseCubeBackgroundEffectPreloadTimer)

			self._chooseCubeBackgroundEffectPreloadTimer = nil
		end

		if onComplete then
			onComplete(success)
		end
	end

	local function tryFinish()
		if not building and preloadFailed then
			finish(false)
		elseif not building and loadedCount == expectedCount then
			finish(expectedCount > 0)
		end
	end

	local function markFailed()
		preloadFailed = true

		tryFinish()
	end

	local function makeLoadCallback(effectTag, onLoaded)
		return function(effectItem)
			if completed or preloadToken ~= self._chooseCubeBackgroundEffectPreloadToken then
				return
			end

			if not effectItem or IsNil(effectItem.effectObj) then
				markFailed()

				return
			end

			if loadedEffectMap[effectTag] then
				return
			end

			loadedEffectMap[effectTag] = true
			loadedCount = loadedCount + 1

			if onLoaded then
				onLoaded(effectItem.effectObj)
			end

			tryFinish()
		end
	end

	if IsNil(scene.eggRootTransform) then
		building = false

		finish(false)

		return
	end

	self._chooseCubeBackgroundEffectPreloadTimer = TimerManager.addTimer(CHOOSE_CUBE_BACKGROUND_EFFECT_TIMEOUT_SECONDS, function()
		finish(false)
	end)

	for fxGroupKey, cubeFxs in pairs(cubeFxGroups or {}) do
		local cubeInFxResId = cubeFxs.CubeInKey and PetFertilityConst.FxResIds[cubeFxs.CubeInKey]
		local eggInFxKey = cubeFxs.EggInKey
		local eggOutFxKey = cubeFxs.EggOutKey

		if not cubeInFxResId or not eggInFxKey or not eggOutFxKey then
			building = false

			finish(false)

			return
		end

		local poolEntry = {
			eggInFxKey = eggInFxKey,
			eggOutFxKey = eggOutFxKey,
			cubeEffectHolder = createChooseCubeEffectHolder("ChooseCubeBackground_" .. tostring(fxGroupKey), scene.catchBallRootTransform),
			eggEffectHolder = createChooseCubeEffectHolder("ChooseEggBackground_" .. tostring(fxGroupKey), scene.eggRootTransform, CHOOSE_EGG_BACKGROUND_LOCAL_X),
			eggOutEffectHolder = createChooseCubeEffectHolder("ChooseEggOutBackground_" .. tostring(fxGroupKey), scene.eggRootTransform)
		}

		if not poolEntry.cubeEffectHolder or not poolEntry.eggEffectHolder or not poolEntry.eggOutEffectHolder then
			destroyChooseCubeEffectHolder(poolEntry.cubeEffectHolder)
			destroyChooseCubeEffectHolder(poolEntry.eggEffectHolder)
			destroyChooseCubeEffectHolder(poolEntry.eggOutEffectHolder)

			building = false

			finish(false)

			return
		end

		effectPool[fxGroupKey] = poolEntry
		expectedCount = expectedCount + 1

		local cubeEffectInfo = self:getDefaultFxExtraInfo()
		local defaultCubeLoadCallback = cubeEffectInfo.loadCallback
		local onCubeLoaded = makeLoadCallback("cube:" .. tostring(fxGroupKey), function(effectObject)
			poolEntry.cubeEffectObject = effectObject
			poolEntry.cubeEnterParticleSystems = collectChooseCubeOneShotParticleSystems(effectObject)
		end)

		function cubeEffectInfo.loadCallback(effectItem)
			if defaultCubeLoadCallback then
				defaultCubeLoadCallback(effectItem)
			end

			onCubeLoaded(effectItem)
		end

		poolEntry.cubeEffectId = scene:playRawEffectOnCubeRoot(cubeInFxResId, cubeEffectInfo, true, poolEntry.cubeEffectHolder.transform)

		if not poolEntry.cubeEffectId then
			building = false

			finish(false)

			return
		end

		if preloadFailed then
			building = false

			finish(false)

			return
		end

		expectedCount = expectedCount + 1

		local eggEffectInfo = self:getDefaultFxExtraInfo()

		eggEffectInfo.position = cubeFxs.EggInPos

		local defaultEggLoadCallback = eggEffectInfo.loadCallback
		local onEggLoaded = makeLoadCallback("egg:" .. tostring(fxGroupKey), function(effectObject)
			poolEntry.eggEffectObject = effectObject
			poolEntry.eggEnterParticleSystems = collectChooseCubeOneShotParticleSystems(effectObject)
			poolEntry.eggLinkLineRenderer = findChooseCubeBackgroundLineRenderer(effectObject.transform)

			setChooseCubeBackgroundLineVisible(poolEntry.eggLinkLineRenderer, false)
		end)

		function eggEffectInfo.loadCallback(effectItem)
			if defaultEggLoadCallback then
				defaultEggLoadCallback(effectItem)
			end

			onEggLoaded(effectItem)
		end

		poolEntry.eggEffectId = eggEntity:playChooseCubeEffect(eggInFxKey, eggEffectInfo, poolEntry.eggEffectHolder.transform)

		if not poolEntry.eggEffectId or poolEntry.eggEffectId == 0 then
			building = false

			finish(false)

			return
		end

		if preloadFailed then
			building = false

			finish(false)

			return
		end

		expectedCount = expectedCount + 1

		local eggOutEffectInfo = self:getDefaultFxExtraInfo()

		eggOutEffectInfo.position = cubeFxs.EggOutPos

		local defaultEggOutLoadCallback = eggOutEffectInfo.loadCallback
		local onEggOutLoaded = makeLoadCallback("eggOut:" .. tostring(fxGroupKey), function(effectObject)
			poolEntry.eggOutEffectObject = effectObject
			poolEntry.eggOutParticleSystems = collectChooseCubeOneShotParticleSystems(effectObject)
			poolEntry.eggOutLinkLineRenderer = findChooseCubeBackgroundLineRenderer(effectObject.transform)

			setChooseCubeBackgroundLineVisible(poolEntry.eggOutLinkLineRenderer, false)
		end)

		function eggOutEffectInfo.loadCallback(effectItem)
			if defaultEggOutLoadCallback then
				defaultEggOutLoadCallback(effectItem)
			end

			onEggOutLoaded(effectItem)
		end

		poolEntry.eggOutEffectId = eggEntity:playChooseCubeEffect(eggOutFxKey, eggOutEffectInfo, poolEntry.eggOutEffectHolder.transform)

		if not poolEntry.eggOutEffectId or poolEntry.eggOutEffectId == 0 then
			building = false

			finish(false)

			return
		end

		if preloadFailed then
			building = false

			finish(false)

			return
		end
	end

	building = false

	tryFinish()
end

function SoulEggEvolutionSystem:_setChooseCubeBackgroundEffectsVisible(fxGroupKey)
	local effectPool = self._chooseCubeBackgroundEffectPool
	local scene = self.evolutionScene
	local eggEntity = self.soulEggEntity

	if not effectPool or not scene or scene.expire or not eggEntity then
		return false
	end

	if fxGroupKey ~= nil and not effectPool[fxGroupKey] then
		self:_releaseChooseCubeBackgroundEffects()

		return false
	end

	for _, poolEntry in pairs(effectPool) do
		if IsNil(poolEntry.cubeEffectObject) or IsNil(poolEntry.eggEffectObject) or IsNil(poolEntry.eggOutEffectObject) or IsNil(poolEntry.cubeEffectHolder) or IsNil(poolEntry.eggEffectHolder) or IsNil(poolEntry.eggOutEffectHolder) then
			self:_releaseChooseCubeBackgroundEffects()

			return false
		end
	end

	for groupKey, poolEntry in pairs(effectPool) do
		local visible = groupKey == fxGroupKey
		local holderLocalZ = visible and CHOOSE_CUBE_BACKGROUND_VISIBLE_LOCAL_Z or CHOOSE_CUBE_BACKGROUND_PREWARM_LOCAL_Z

		poolEntry.cubeEffectHolder.transform.localPosition = Vector3(0, 0, holderLocalZ)
		poolEntry.eggEffectHolder.transform.localPosition = Vector3(CHOOSE_EGG_BACKGROUND_LOCAL_X, 0, holderLocalZ)
		poolEntry.eggOutEffectHolder.transform.localPosition = Vector3(0, 0, CHOOSE_CUBE_BACKGROUND_PREWARM_LOCAL_Z)

		setChooseCubeBackgroundLineVisible(poolEntry.eggLinkLineRenderer, visible, scene.eggRootTransform, scene.catchBallRootTransform)
		setChooseCubeBackgroundLineVisible(poolEntry.eggOutLinkLineRenderer, false)
	end

	self._activeChooseCubeFxGroupKey = fxGroupKey

	return true
end

function SoulEggEvolutionSystem:_replayChooseCubeBackgroundEnterEffects(fxGroupKey)
	local effectPool = self._chooseCubeBackgroundEffectPool
	local poolEntry = effectPool and effectPool[fxGroupKey]

	if not poolEntry then
		return
	end

	replayChooseCubeOneShotParticleSystems(poolEntry.cubeEnterParticleSystems)
	replayChooseCubeOneShotParticleSystems(poolEntry.eggEnterParticleSystems)
end

function SoulEggEvolutionSystem:_hideChooseCubeBackgroundExitEffects()
	for _, poolEntry in pairs(self._chooseCubeBackgroundEffectPool or {}) do
		if NotNil(poolEntry.eggOutEffectHolder) then
			poolEntry.eggOutEffectHolder.transform.localPosition = Vector3(0, 0, CHOOSE_CUBE_BACKGROUND_PREWARM_LOCAL_Z)
		end

		setChooseCubeBackgroundLineVisible(poolEntry.eggOutLinkLineRenderer, false)
	end
end

function SoulEggEvolutionSystem:_playChooseCubeBackgroundExitEffect(fxGroupKey)
	local effectPool = self._chooseCubeBackgroundEffectPool
	local poolEntry = effectPool and effectPool[fxGroupKey]

	if not poolEntry or IsNil(poolEntry.eggOutEffectObject) or IsNil(poolEntry.eggOutEffectHolder) then
		if effectPool then
			self:_releaseChooseCubeBackgroundEffects()
		end

		return false
	end

	if not self:_setChooseCubeBackgroundEffectsVisible(nil) then
		return false
	end

	poolEntry.eggOutEffectHolder.transform.localPosition = Vector3(0, 0, CHOOSE_CUBE_BACKGROUND_VISIBLE_LOCAL_Z)

	local scene = self.evolutionScene

	setChooseCubeBackgroundLineVisible(poolEntry.eggOutLinkLineRenderer, true, scene.eggRootTransform, scene.catchBallRootTransform)
	replayChooseCubeOneShotParticleSystems(poolEntry.eggOutParticleSystems)

	return true
end

function SoulEggEvolutionSystem:isInEvolution()
	return self._isInEvolution
end

function SoulEggEvolutionSystem:applyPetTransmog(entity, petInfo)
	if entity and petInfo and petInfo.id then
		PetTransmogUtils.applyAppliedTransmog(entity, petInfo.id)
	end
end

function SoulEggEvolutionSystem:getEvolutionPresentationStage(petInfo)
	local templateId = petInfo and petInfo.templateId or 0
	local petPrototypeId = Utils.getPetPetPrototypeId(templateId)
	local petEvolveData = PetEvolveData[petPrototypeId]
	local stageData = petEvolveData and petEvolveData[1]
	local stage = stageData and stageData.stage or petInfo and petInfo.stage or 1

	return templateId, stage
end

function SoulEggEvolutionSystem:_getRegisteredEvolutionScene()
	return pg.game.uiScene:getScene(UISceneConst.SOUL_EGG_EVOLUTION_SCENE)
end

function SoulEggEvolutionSystem:_isRunContextValid(runToken, scene)
	return runToken == self._runToken and self._isInEvolution == true and scene ~= nil and self.evolutionScene == scene and not scene.expire and scene == self:_getRegisteredEvolutionScene() and scene:checkLoadSucceed() and scene:isPresentationReady()
end

function SoulEggEvolutionSystem:_makeRunGuardedCallback(callback, runToken, scene)
	local capturedRunToken = runToken or self._runToken
	local capturedScene = scene or self.evolutionScene

	return function(...)
		if not self:_isRunContextValid(capturedRunToken, capturedScene) then
			return
		end

		return callback(...)
	end
end

function SoulEggEvolutionSystem:_deferOverlayCloseCheck(runToken, scene, reason, allowClose)
	if not self:_isRunContextValid(runToken, scene) then
		return
	end

	self:playTimer(0, function()
		if allowClose and allowClose() then
			return
		end

		self:_abortRun(runToken, reason)
	end, runToken, scene)
end

function SoulEggEvolutionSystem:_abortRun(runToken, reason)
	if runToken ~= self._runToken or not self._isInEvolution then
		return
	end

	self:resetSoulEggSystem()
end

function SoulEggEvolutionSystem:_clearHostReadyTimer()
	if self._hostReadyTimer then
		TimerManager.removeTimer(self._hostReadyTimer)

		self._hostReadyTimer = nil
	end
end

function SoulEggEvolutionSystem:_clearSourceJumpOpenWatchdog()
	if self._sourceJumpOpenWatchdogTimer then
		TimerManager.removeTimer(self._sourceJumpOpenWatchdogTimer)

		self._sourceJumpOpenWatchdogTimer = nil
	end
end

function SoulEggEvolutionSystem:_clearChooseCubeSourceJumpState()
	self:_clearSourceJumpOpenWatchdog()

	self._sourceJumpTargetUIId = nil
	self._sourceJumpRunToken = nil
	self._sourceJumpTargetOpened = false
	self._sourceJumpLoadingWaited = false
	self._sourceJumpLoadWatchdogRemaining = 0
end

function SoulEggEvolutionSystem:_fallbackChooseCubeSourceJump()
	self:_clearChooseCubeSourceJumpState()

	local chooseBallCtrl = pg.global.ui:tryGetCtrlByUid(UIConst.UI_ID_PET_FERTILITY_CHOOSE_BALL)

	if chooseBallCtrl and chooseBallCtrl:checkUIOpen() then
		chooseBallCtrl:closeForSourceJump()
	end
end

function SoulEggEvolutionSystem:_startSourceJumpOpenWatchdog(delay)
	local targetUIId = self._sourceJumpTargetUIId
	local sourceJumpRunToken = self._sourceJumpRunToken

	if not targetUIId or sourceJumpRunToken == nil then
		return
	end

	self:_clearSourceJumpOpenWatchdog()

	self._sourceJumpOpenWatchdogTimer = TimerManager.addTimer(delay, function()
		self._sourceJumpOpenWatchdogTimer = nil

		if self._sourceJumpTargetUIId ~= targetUIId or self._sourceJumpRunToken ~= sourceJumpRunToken or self._sourceJumpTargetOpened then
			return
		end

		local targetCtrl = pg.global.ui:tryGetCtrlByUid(targetUIId)

		if self._sourceJumpLoadingWaited then
			self._sourceJumpLoadWatchdogRemaining = self._sourceJumpLoadWatchdogRemaining - delay

			if targetCtrl and targetCtrl._inloadUIScene and self._sourceJumpLoadWatchdogRemaining > 0 then
				self:_startSourceJumpOpenWatchdog(SOURCE_JUMP_LOAD_POLL_INTERVAL_SECONDS)

				return
			end
		elseif targetCtrl and targetCtrl._inloadUIScene then
			self._sourceJumpLoadingWaited = true
			self._sourceJumpLoadWatchdogRemaining = SOURCE_JUMP_LOAD_TIMEOUT_SECONDS

			self:_startSourceJumpOpenWatchdog(SOURCE_JUMP_LOAD_POLL_INTERVAL_SECONDS)

			return
		end

		self:_fallbackChooseCubeSourceJump()
	end)
end

function SoulEggEvolutionSystem:_clearSoulEggBreakLoadWatchdog()
	if self._soulEggBreakLoadWatchdogTimer then
		TimerManager.removeTimer(self._soulEggBreakLoadWatchdogTimer)

		self._soulEggBreakLoadWatchdogTimer = nil
	end
end

function SoulEggEvolutionSystem:_startHostReadyWatchdog(runToken)
	self:_clearHostReadyTimer()

	self._hostReadyTimer = TimerManager.addTimer(HOST_READY_TIMEOUT_SECONDS, function()
		self._hostReadyTimer = nil

		if runToken == self._runToken and self._isInEvolution then
			self:_abortRun(runToken, "host-ready-timeout")
		end
	end)
end

function SoulEggEvolutionSystem:_registerPendingHatchRequest(runToken)
	local eggItemId = self._soulEggInfo and self._soulEggInfo.eggItemId

	if not eggItemId or eggItemId <= 0 then
		return
	end

	local requests = self._pendingHatchRequests or {}

	self._pendingHatchRequests = requests
	requests[#requests + 1] = {
		runToken = runToken,
		chooseEpoch = self:getChooseEpoch(),
		eggItemId = eggItemId
	}

	while #requests > MAX_PENDING_HATCH_REQUESTS do
		table.remove(requests, 1)
	end
end

function SoulEggEvolutionSystem:discardPendingHatchRequest(chooseEpoch)
	local requests = self._pendingHatchRequests or {}

	for index = #requests, 1, -1 do
		if requests[index].chooseEpoch == chooseEpoch then
			table.remove(requests, index)
		end
	end
end

function SoulEggEvolutionSystem:_consumePendingHatchRequest(eggItemId)
	local requests = self._pendingHatchRequests or {}

	for index, request in ipairs(requests) do
		if request.eggItemId == eggItemId then
			table.remove(requests, index)

			return request
		end
	end

	return nil
end

function SoulEggEvolutionSystem:_openEvolutionSceneHost(runToken, readyCallback)
	local openedScene

	self:_startHostReadyWatchdog(runToken)
	pg.global.ui:open(UIConst.UI_ID_PET_FERTILITY_HATCH_SCENE_HOST, {
		runToken = runToken
	}, function()
		if runToken ~= self._runToken or not self._isInEvolution then
			return
		end

		self:_clearHostReadyTimer()

		openedScene = self:_getRegisteredEvolutionScene()
		self.evolutionScene = openedScene

		if not self:_isRunContextValid(runToken, openedScene) then
			local reason = openedScene and openedScene:getPresentationErrorReason() or "scene-not-registered"

			self:_abortRun(runToken, reason)

			return
		end

		readyCallback(openedScene)
	end, function()
		if runToken ~= self._runToken or not self._isInEvolution then
			return
		end

		self:_abortRun(runToken, "host-closed")
	end)
end

function SoulEggEvolutionSystem:_closeEvolutionOverlays()
	for _, uiId in ipairs(HATCH_OVERLAY_UI_IDS) do
		local ctrl = pg.global.ui:tryGetCtrlByUid(uiId)

		if ctrl and (ctrl:checkUIOpen() or ctrl._inloadUIScene) then
			pg.global.ui:closeImmediately(uiId)
		end
	end
end

function SoulEggEvolutionSystem:_closeEvolutionSceneHost()
	local ctrl = pg.global.ui:tryGetCtrlByUid(UIConst.UI_ID_PET_FERTILITY_HATCH_SCENE_HOST)

	if ctrl and (ctrl:checkUIOpen() or ctrl._inloadUIScene) then
		pg.global.ui:closeImmediately(UIConst.UI_ID_PET_FERTILITY_HATCH_SCENE_HOST)
	end
end

function SoulEggEvolutionSystem:resetSoulEggSystem(skipPreviewCameraRestore, deferRecordedTips)
	local previousRunToken = self._runToken

	self._runToken = previousRunToken + 1

	self:_clearHostReadyTimer()
	self:_clearSourceJumpOpenWatchdog()
	self:_clearSoulEggBreakLoadWatchdog()
	self:_releaseChooseCubeBackgroundEffects()
	self:_releaseCubeSwitchEffect()

	if skipPreviewCameraRestore ~= true then
		pg.game.petBall:setPreviewCameraEnabled(true)
	end

	self:setUIVisible(true)

	self._sourceJumpTargetUIId = nil
	self._sourceJumpRunToken = nil
	self._sourceJumpTargetOpened = false
	self._sourceJumpLoadingWaited = false
	self._sourceJumpLoadWatchdogRemaining = 0

	for i = 1, #self.soulEggEvolutionTimerList do
		TimerManager.removeTimer(self.soulEggEvolutionTimerList[i])
	end

	table.clearArray(self.soulEggEvolutionTimerList)

	self._cubeSwitchToken = (self._cubeSwitchToken or 0) + 1

	local scene = self.evolutionScene

	self:_clearCubeMappedEffect()
	self:_clearEggChooseCubeFxs()

	self.evolutionScene = nil

	if scene and not scene.expire then
		scene:resetPresentation()
	end

	self:_releaseSoulEggBreakEffect()
	self:_releasePetSuccessEffects()
	self:_releaseChooseCubeEffects()

	self.soulEggEntity = nil
	self.petEvolveVirtualEntity = nil
	self._cacheCubeFxsInfo = {}
	self.bgEffectId = nil
	self.petSuccessEffectId = nil
	self.petSuccessBgEffectId = nil
	self.soulEggBreakEffectId = nil
	self._soulEggBreakStartedRunToken = nil
	self._soulEggBreakFinishedRunToken = nil
	self._petEvolutionStartedRunToken = nil

	self:_closeEvolutionOverlays()
	self:_closeEvolutionSceneHost()
	pg.game.audio:playBgm(nil, AudioConst.BgmPriority.Cutscene)

	if self._soulEggInfo and self._soulEggInfo.closeAction then
		self._soulEggInfo.closeAction()
	end

	self._soulEggInfo = nil
	self._newEntityInfo = nil
	self._cubeChooseInfo = nil

	self:_finalizeRecordedTipsForReset(deferRecordedTips)

	self._waitingHatchRPC = false
	self._chooseConfirmed = false
	self._isInEvolution = false
	self._isInEggTouchPlaying = false
	self._incubateTransitionStarted = false
	self._isSkip = false
	self._loading = false
end

function SoulEggEvolutionSystem:cancelChooseCube()
	self:resetSoulEggSystem()
end

function SoulEggEvolutionSystem:cancelChooseCubeForSourceJump()
	self:resetSoulEggSystem(true)
end

function SoulEggEvolutionSystem:_getSourceTargetUIId(sourceData)
	local param = sourceData and sourceData.param

	if not Utils.isTable(param) then
		return nil
	end

	local targetParam = param[2]

	if param[1] == "openUI" then
		if not Utils.isTable(targetParam) then
			return nil
		end

		return targetParam[1]
	end

	if param[1] ~= "shop" or not Utils.isTable(targetParam) then
		return nil
	end

	local shopClassCfg = ShopClassifyData[targetParam[1]]

	if not shopClassCfg or shopClassCfg.type ~= 1 then
		return nil
	end

	return UIConst.UI_ID_SHOP_MAIN
end

function SoulEggEvolutionSystem:beginChooseCubeSourceJump(sourceData)
	if not self._isInEvolution or self._waitingHatchRPC then
		return false
	end

	local targetUIId = self:_getSourceTargetUIId(sourceData)

	if not targetUIId then
		return false
	end

	local chooseBallCtrl = pg.global.ui:tryGetCtrlByUid(UIConst.UI_ID_PET_FERTILITY_CHOOSE_BALL)

	if not chooseBallCtrl or not chooseBallCtrl:checkUIOpen() then
		return false
	end

	self:_clearSourceJumpOpenWatchdog()

	self._sourceJumpTargetUIId = targetUIId
	self._sourceJumpRunToken = self._runToken
	self._sourceJumpTargetOpened = false
	self._sourceJumpLoadingWaited = false
	self._sourceJumpLoadWatchdogRemaining = 0

	chooseBallCtrl:setUIHide(UIConst.UI_HIDE_KEY.PET_FERTILITY_CHOOSE_CUBE_SOURCE_JUMP, true)
	self:setUIVisible(true)

	local targetCtrl = pg.global.ui:tryGetCtrlByUid(targetUIId)

	if targetCtrl and targetCtrl:checkUIOpen() then
		self._sourceJumpTargetOpened = true

		return true
	end

	self:_startSourceJumpOpenWatchdog(SOURCE_JUMP_OPEN_TIMEOUT_SECONDS)

	return true
end

function SoulEggEvolutionSystem:onUIOpen(uiId)
	if uiId ~= self._sourceJumpTargetUIId or self._sourceJumpRunToken ~= self._runToken then
		return
	end

	self._sourceJumpTargetOpened = true
	self._sourceJumpLoadingWaited = false
	self._sourceJumpLoadWatchdogRemaining = 0

	self:_clearSourceJumpOpenWatchdog()
end

function SoulEggEvolutionSystem:onUIClose(uiId)
	if uiId ~= self._sourceJumpTargetUIId then
		return
	end

	local sourceJumpRunToken = self._sourceJumpRunToken
	local sourceJumpTargetOpened = self._sourceJumpTargetOpened

	self:_clearSourceJumpOpenWatchdog()

	self._sourceJumpTargetUIId = nil
	self._sourceJumpRunToken = nil
	self._sourceJumpTargetOpened = false
	self._sourceJumpLoadingWaited = false
	self._sourceJumpLoadWatchdogRemaining = 0

	if not sourceJumpTargetOpened then
		if sourceJumpRunToken == self._runToken and self._isInEvolution and not self._waitingHatchRPC then
			local chooseBallCtrl = pg.global.ui:tryGetCtrlByUid(UIConst.UI_ID_PET_FERTILITY_CHOOSE_BALL)

			if chooseBallCtrl and chooseBallCtrl:checkUIOpen() then
				chooseBallCtrl:closeForSourceJump()
			end
		end

		return
	end

	if sourceJumpRunToken ~= self._runToken or not self._isInEvolution or self._waitingHatchRPC then
		return
	end

	local chooseBallCtrl = pg.global.ui:tryGetCtrlByUid(UIConst.UI_ID_PET_FERTILITY_CHOOSE_BALL)

	if not chooseBallCtrl or not chooseBallCtrl:checkUIOpen() then
		return
	end

	self:setUIVisible(false)
	chooseBallCtrl:setUIHide(UIConst.UI_HIDE_KEY.PET_FERTILITY_CHOOSE_CUBE_SOURCE_JUMP, false)
end

function SoulEggEvolutionSystem:getChooseEpoch()
	return self._chooseEpoch or 0
end

function SoulEggEvolutionSystem:startSoulEggChooseCube(soulEggInfo, cubeChooseInfo)
	self:resetSoulEggSystem(nil, true)
	self:resetChooseCubeInfos()

	self._chooseEpoch = (self._chooseEpoch or 0) + 1

	pg.game.petBall:setPreviewCameraEnabled(false)

	self._soulEggInfo = soulEggInfo
	self._cubeChooseInfo = cubeChooseInfo
	self._isInEvolution = true

	local cubePreloadInfos = self:_getChooseCubePreloadInfos()
	local cubeFxGroups = self:_getChooseCubeFxGroups(cubePreloadInfos)

	self:_preloadSoulEggBreakEffect()
	self:_preloadChooseCubeEffects(cubeFxGroups)

	local runToken = self._runToken

	self:_openEvolutionSceneHost(runToken, function(scene)
		if not self:_isRunContextValid(runToken, scene) then
			return
		end

		local cubeModelsReady = false
		local backgroundEffectsReady = false
		local switchEffectReady = false
		local chooseBallOpened = false
		local eggModelReady = false

		local function tryOpenChooseBall()
			if chooseBallOpened or not cubeModelsReady or not backgroundEffectsReady or not switchEffectReady then
				return
			end

			if not self:_isRunContextValid(runToken, scene) then
				return
			end

			chooseBallOpened = true

			self:onCubeChooseLoaded(runToken, scene)
		end

		self:_preloadCubeSwitchEffect(runToken, scene, function()
			if not self:_isRunContextValid(runToken, scene) then
				return
			end

			switchEffectReady = true

			tryOpenChooseBall()
		end)

		self.soulEggEntity = scene:createSoulEggEntity(soulEggInfo, {
			onModelReady = function(eggEntity)
				eggModelReady = true

				TimerManager.addNextFrameCb(function()
					if not self:_isRunContextValid(runToken, scene) or self.soulEggEntity ~= eggEntity then
						return
					end

					self:playEggBroken(0)
					self:_preloadChooseCubeBackgroundEffects(runToken, scene, eggEntity, cubeFxGroups, function(success)
						if not self:_isRunContextValid(runToken, scene) then
							return
						end

						if not success then
							self:_releaseChooseCubeBackgroundEffects()

							backgroundEffectsReady = true

							tryOpenChooseBall()

							return
						end

						backgroundEffectsReady = true

						tryOpenChooseBall()
					end)
				end)
			end
		})

		if not self.soulEggEntity then
			self:_abortRun(runToken, "create-egg-failed")

			return
		end

		self:playTimer(SOUL_EGG_MODEL_READY_TIMEOUT_SECONDS, function()
			if not eggModelReady then
				self:_abortRun(runToken, "preload-egg-model-failed")
			end
		end, runToken, scene)
		scene:preloadCubeEntities(cubePreloadInfos, function(success)
			if not self:_isRunContextValid(runToken, scene) then
				return
			end

			if not success then
				self:_abortRun(runToken, "preload-cube-model-failed")

				return
			end

			cubeModelsReady = true

			tryOpenChooseBall()
		end)
	end)
end

function SoulEggEvolutionSystem:startSoulEggEvolution(soulEggInfo, newEntityInfo)
	local incomingEggItemId = soulEggInfo and soulEggInfo.eggItemId

	if incomingEggItemId and incomingEggItemId > 0 then
		local pendingRequest = self:_consumePendingHatchRequest(incomingEggItemId)

		if pendingRequest then
			local matchesCurrentRun = pendingRequest.runToken == self._runToken and pendingRequest.chooseEpoch == self:getChooseEpoch() and self._waitingHatchRPC == true

			if not matchesCurrentRun then
				return
			end
		elseif self._waitingHatchRPC then
			return
		end
	end

	if self._waitingHatchRPC and self._isInEvolution then
		local runToken = self._runToken
		local scene = self.evolutionScene

		if not self:_isRunContextValid(runToken, scene) then
			self:_abortRun(runToken, "rpc-continuation-scene-invalid")

			return
		end

		self:_continueWithPetEntity(soulEggInfo, newEntityInfo, runToken, scene)

		return
	end

	self:resetSoulEggSystem(nil, true)

	self._isInEggTouchPlaying = true

	pg.game.petBall:setPreviewCameraEnabled(false)

	self._newEntityInfo = newEntityInfo
	self._soulEggInfo = soulEggInfo
	self._isInEvolution = true

	self:_preloadSoulEggBreakEffect()
	self:_preloadPetSuccessEffects()

	local runToken = self._runToken

	self:_openEvolutionSceneHost(runToken, function(scene)
		if not self:_isRunContextValid(runToken, scene) then
			return
		end

		local eggModelReady = false

		self.soulEggEntity = scene:createSoulEggEntity(soulEggInfo, {
			onModelReady = function(eggEntity)
				eggModelReady = true

				TimerManager.addNextFrameCb(function()
					if not self:_isRunContextValid(runToken, scene) or self.soulEggEntity ~= eggEntity then
						return
					end

					self:playEggBroken(0)
					self:onAllLoaded(runToken, scene)
				end)
			end
		})
		self.petEvolveVirtualEntity = scene:createPetEntity(newEntityInfo)

		if not self.soulEggEntity or not self.petEvolveVirtualEntity then
			self:_abortRun(runToken, "create-incubate-entity-failed")

			return
		end

		self:playTimer(SOUL_EGG_MODEL_READY_TIMEOUT_SECONDS, function()
			if not eggModelReady then
				self:_abortRun(runToken, "incubate-egg-model-failed")
			end
		end, runToken, scene)
		self:applyPetTransmog(self.petEvolveVirtualEntity, newEntityInfo)
		self.petEvolveVirtualEntity:setEvolutionVisible(false)
	end)
end

function SoulEggEvolutionSystem:_continueWithPetEntity(soulEggInfo, newEntityInfo, runToken, scene)
	if not self:_isRunContextValid(runToken, scene) then
		self:_abortRun(runToken, "rpc-continuation-invalid")

		return
	end

	self._waitingHatchRPC = false
	self._cubeChooseInfo = nil
	self._isInEggTouchPlaying = true
	self._newEntityInfo = newEntityInfo

	self:_preloadPetSuccessEffects()

	if soulEggInfo then
		self._soulEggInfo = soulEggInfo
	end

	self:_releaseChooseCubeBackgroundEffects()
	self:_releaseCubeSwitchEffect()
	self:_clearCubeEntityAndEffect()

	self.petEvolveVirtualEntity = scene:createPetEntity(newEntityInfo)

	if not self.petEvolveVirtualEntity then
		self:_abortRun(runToken, "create-pet-failed")

		return
	end

	self:applyPetTransmog(self.petEvolveVirtualEntity, newEntityInfo)
	self.petEvolveVirtualEntity:setEvolutionVisible(false)

	local eggEntity = self.soulEggEntity

	if not eggEntity then
		self:_abortRun(runToken, "exit-show-egg-missing")

		return
	end

	eggEntity:playExitShow()
	self:playTimer(SOUL_EGG_EXIT_SHOW_DURATION_SECONDS, function()
		if self.soulEggEntity ~= eggEntity then
			self:_abortRun(runToken, "exit-show-egg-changed")

			return
		end

		self:onAllLoaded(runToken, scene)
	end, runToken, scene)
end

function SoulEggEvolutionSystem:onTick()
	if self._isInEvolution and self._isSkip and pg.global.ui and pg.global.ui:checkUIShow(UIConst.UI_ID_PET_FERTILITY_INCUBATE_RESULT) then
		self:clearSoulEgg()
	end
end

function SoulEggEvolutionSystem:_scheduleSoulEggEnterShow(runToken, scene)
	local eggEntity = self.soulEggEntity

	if not eggEntity or eggEntity._soulEggEnterShowScheduled then
		return
	end

	eggEntity._soulEggEnterShowScheduled = true

	TimerManager.addNextFrameCb(function()
		if not self:_isRunContextValid(runToken, scene) or self.soulEggEntity ~= eggEntity then
			return
		end

		eggEntity:playEnterShow()
	end)
end

function SoulEggEvolutionSystem:onCubeChooseLoaded(runToken, scene)
	if not self:_isRunContextValid(runToken, scene) or not self._cubeChooseInfo then
		self:_abortRun(runToken, "choose-overlay-context-invalid")

		return
	end

	self:setUIVisible(false)
	pg.global.ui:open(UIConst.UI_ID_PET_FERTILITY_CHOOSE_BALL, {
		eggItemId = self._soulEggInfo and self._soulEggInfo.eggItemId or 0,
		slotIndex = self._cubeChooseInfo.slotIndex,
		onConfirm = self:_makeRunGuardedCallback(function(cubeItemId)
			self._waitingHatchRPC = true
			self._chooseConfirmed = true
			self._isInEggTouchPlaying = true

			self:_registerPendingHatchRequest(runToken)

			if self._cubeChooseInfo and self._cubeChooseInfo.onConfirm then
				self._cubeChooseInfo.onConfirm(cubeItemId)
			end
		end, runToken, scene),
		onCancel = self:_makeRunGuardedCallback(function(isSourceJump)
			if self._waitingHatchRPC then
				return
			end

			local cb = self._cubeChooseInfo and self._cubeChooseInfo.onCancel

			if isSourceJump then
				self:cancelChooseCubeForSourceJump()
			else
				self:cancelChooseCube()
			end

			if cb then
				cb(isSourceJump)
			end
		end, runToken, scene)
	}, self:_makeRunGuardedCallback(function()
		self:_scheduleSoulEggEnterShow(runToken, scene)
	end, runToken, scene), function()
		self:_deferOverlayCloseCheck(runToken, scene, "choose-overlay-closed", function()
			return self._chooseConfirmed == true
		end)
	end)
end

function SoulEggEvolutionSystem:onAllLoaded(runToken, scene)
	if not self:_isRunContextValid(runToken, scene) then
		self:_abortRun(runToken, "incubate-overlay-context-invalid")

		return
	end

	scene:moveCameraToEggCenter()

	self._isInEggTouchPlaying = true
	self._incubateTransitionStarted = false

	self:_preloadSoulEggBreakEffect()
	pg.global.ui:open(UIConst.UI_ID_PET_FERTILITY_INCUBATE, {
		closeCallBack = self:_makeRunGuardedCallback(function()
			self._incubateTransitionStarted = true

			self:onEggTouchFinish(runToken, scene)
		end, runToken, scene),
		skipCloseCallBack = self:_makeRunGuardedCallback(function()
			self._incubateTransitionStarted = true

			self:onEggTouchSkip(runToken, scene)
		end, runToken, scene),
		petInfo = self._newEntityInfo,
		isGrabEgg = self._soulEggInfo and self._soulEggInfo.isGrabEgg
	}, self:_makeRunGuardedCallback(function()
		self:_scheduleSoulEggEnterShow(runToken, scene)
	end, runToken, scene), function()
		self:_deferOverlayCloseCheck(runToken, scene, "incubate-overlay-closed", function()
			return self._incubateTransitionStarted == true
		end)
	end)
	self:setUIVisible(false)
end

function SoulEggEvolutionSystem:preloadAnimations()
	if not self.petEvolveVirtualEntity then
		return
	end

	local aniList = {}

	aniList[#aniList + 1] = "Idle"

	for _, aniInfo in ipairs(SoulEggEvolutionConst.EvolutionAnimation.animStateList) do
		if type(aniInfo) == "string" then
			aniList[#aniList + 1] = aniInfo
		elseif type(aniInfo) == "table" then
			for _, ani in ipairs(aniInfo) do
				if type(ani) == "string" then
					aniList[#aniList + 1] = ani
				end
			end
		end
	end

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info(string.format("SoulEggEvolutionSystem:preloadAnimations ! aniList:{%s}", inspect(aniList)))
	end

	self.petEvolveVirtualEntity:preloadAnimations(aniList)
end

function SoulEggEvolutionSystem:_preloadSoulEggBreakEffect()
	if self._soulEggBreakEffectPreloaded then
		return
	end

	pg.game.effect:preloadEntityEffect(self, SoulEggEvolutionConst.SoulEggBreakEffect.effectName)

	self._soulEggBreakEffectPreloaded = true
end

function SoulEggEvolutionSystem:_releaseSoulEggBreakEffect()
	if not self._soulEggBreakEffectPreloaded then
		return
	end

	pg.game.effect:unPreloadEntityEffect(self, SoulEggEvolutionConst.SoulEggBreakEffect.effectName)

	self._soulEggBreakEffectPreloaded = nil
end

function SoulEggEvolutionSystem:_preloadPetSuccessEffects()
	if self._petSuccessEffectPreloadKeys or not self._newEntityInfo then
		return
	end

	local isShiny = Utils.isLabelShiny(self._newEntityInfo.label)
	local successEffectKey = isShiny and EvolutionSucConst.shinyEffectName or EvolutionSucConst.normalEffectName
	local successBgEffectKey = isShiny and EvolutionSucConst.shinyBgEffectName or EvolutionSucConst.normalBgEffectName
	local preloadKeys = {}

	for _, effectKey in pairs({
		successEffectKey,
		successBgEffectKey
	}) do
		if effectKey and effectKey ~= "" and not preloadKeys[effectKey] then
			pg.game.effect:preloadEntityEffect(self, effectKey)

			preloadKeys[effectKey] = true
		end
	end

	self._petSuccessEffectPreloadKeys = preloadKeys
end

function SoulEggEvolutionSystem:_releasePetSuccessEffects()
	if not self._petSuccessEffectPreloadKeys then
		return
	end

	for effectKey in pairs(self._petSuccessEffectPreloadKeys) do
		pg.game.effect:unPreloadEntityEffect(self, effectKey)
	end

	self._petSuccessEffectPreloadKeys = nil
end

function SoulEggEvolutionSystem:_openIncubateResult(needDelay, runToken, scene)
	if not self:_isRunContextValid(runToken, scene) then
		return
	end

	pg.global.ui:open(UIConst.UI_ID_PET_FERTILITY_INCUBATE_RESULT, {
		closeCallback = self:_makeRunGuardedCallback(function()
			self:resetSoulEggSystem()
		end, runToken, scene),
		petInfo = self._newEntityInfo,
		needDelay = needDelay,
		isGrabEgg = self._soulEggInfo and self._soulEggInfo.isGrabEgg
	}, nil, function()
		self:_deferOverlayCloseCheck(runToken, scene, "result-overlay-closed")
	end)
end

function SoulEggEvolutionSystem:onEggTouchFinish(runToken, scene)
	if not self:_isRunContextValid(runToken, scene) then
		return
	end

	self:_finishEggTouchPlaying()
	self:playTimer(SoulEggEvolutionConst.IncubateResultShowTime, function()
		self:_openIncubateResult(true, runToken, scene)
	end, runToken, scene)
	self:playSoulEggEvolution(runToken, scene, true)
end

function SoulEggEvolutionSystem:onEggTouchSkip(runToken, scene)
	if not self:_isRunContextValid(runToken, scene) or not self.petEvolveVirtualEntity then
		return
	end

	self._isSkip = true

	self:_finishEggTouchPlaying()
	self:playSoulEggEvolution(runToken, scene, false)
end

function SoulEggEvolutionSystem:playSoulEggEvolution(runToken, scene, needDelay)
	runToken = runToken or self._runToken
	scene = scene or self.evolutionScene

	if not self:_isRunContextValid(runToken, scene) or not self.soulEggEntity then
		return
	end

	if self._soulEggBreakStartedRunToken == runToken then
		return
	end

	self._soulEggBreakStartedRunToken = runToken

	self.soulEggEntity:setEvolutionVisible(true)

	local isBreakEffectLoaded = false

	self:playTimer(SoulEggEvolutionConst.SoulEggBreakEffect.startTime, function()
		local fxExtraInfo = self:getDefaultFxExtraInfo()

		fxExtraInfo.position.y = SoulEggEvolutionConst.SoulEggBreakEffect.posY
		fxExtraInfo.scale = SoulEggEvolutionConst.SoulEggBreakEffect.scale
		fxExtraInfo.duration = SoulEggEvolutionConst.SoulEggBreakEffect.effectDuration
		fxExtraInfo.forceLodLevel = SoulEggEvolutionConst.SoulEggBreakEffect.forceLodLevel

		local originalLoadCallback = fxExtraInfo.loadCallback

		fxExtraInfo.loadCallback = self:_makeRunGuardedCallback(function(effectItem)
			if self._soulEggBreakFinishedRunToken == runToken then
				return
			end

			if isBreakEffectLoaded then
				return
			end

			isBreakEffectLoaded = true

			self:_clearSoulEggBreakLoadWatchdog()

			if originalLoadCallback then
				originalLoadCallback(effectItem)
			end

			self:playTimer(SoulEggEvolutionConst.SoulEggBreakEffect.petShowTime, function()
				if self.soulEggEntity then
					self.soulEggEntity:stopEggBrokenEffect()
				end

				self:clearSoulEgg()
				self:_startPetEvolutionOnce(runToken, scene, needDelay)
			end, runToken, scene)
			self:playTimer(SoulEggEvolutionConst.SoulEggBreakEffect.cleanupTime, function()
				self:_finishSoulEggBreak(runToken, scene, needDelay)
			end, runToken, scene)
		end, runToken, scene)
		fxExtraInfo.endCallback = self:_makeRunGuardedCallback(function()
			self:_finishSoulEggBreak(runToken, scene, needDelay)
		end, runToken, scene)
		self.soulEggBreakEffectId = scene:playEffectOnEggRoot(SoulEggEvolutionConst.SoulEggBreakEffect.effectName, fxExtraInfo, true)

		if not self.soulEggBreakEffectId or self.soulEggBreakEffectId == 0 then
			self:_finishSoulEggBreak(runToken, scene, needDelay)

			return
		end

		if not isBreakEffectLoaded then
			self._soulEggBreakLoadWatchdogTimer = TimerManager.addTimer(SOUL_EGG_BREAK_LOAD_TIMEOUT_SECONDS, function()
				self._soulEggBreakLoadWatchdogTimer = nil

				if not isBreakEffectLoaded then
					if LoggerManager.checkLogger(LoggerConst.ERROR) then
						logger:error("SoulEggEvolutionSystem: soul egg break effect load timeout")
					end

					self:_finishSoulEggBreak(runToken, scene, needDelay)
				end
			end)
		end

		pg.game.audio:playEvent("SFX_UI_Incubate_EggHatch")
	end, runToken, scene)
end

function SoulEggEvolutionSystem:_startPetEvolutionOnce(runToken, scene, needDelay)
	if not self:_isRunContextValid(runToken, scene) or not self.petEvolveVirtualEntity or self._petEvolutionStartedRunToken == runToken then
		return
	end

	self._petEvolutionStartedRunToken = runToken

	self:playPetEvolution(runToken, scene)

	if needDelay == false then
		self:_openIncubateResult(false, runToken, scene)
	end
end

function SoulEggEvolutionSystem:_finishSoulEggBreak(runToken, scene, needDelay)
	if self._soulEggBreakFinishedRunToken == runToken or not self:_isRunContextValid(runToken, scene) then
		return
	end

	self._soulEggBreakFinishedRunToken = runToken

	self:_clearSoulEggBreakLoadWatchdog()

	if self.soulEggBreakEffectId and self.soulEggBreakEffectId ~= 0 then
		scene:stopEffect(self.soulEggBreakEffectId)
	end

	self.soulEggBreakEffectId = nil

	if self.soulEggEntity then
		self.soulEggEntity:stopEggBrokenEffect()
	end

	self:clearSoulEgg()
end

function SoulEggEvolutionSystem:playPetEvolution(runToken, scene)
	runToken = runToken or self._runToken
	scene = scene or self.evolutionScene

	if not self:_isRunContextValid(runToken, scene) or not self.petEvolveVirtualEntity then
		return
	end

	pg.game.audio:playBgm("BGM_UI_Incubate_Hatched", AudioConst.BgmPriority.Cutscene)

	local _, presentationStage = self:getEvolutionPresentationStage(self._newEntityInfo)

	scene:applyIncubatePresentation(presentationStage, self.petEvolveVirtualEntity)
	self.petEvolveVirtualEntity:setEvolutionVisible(true)

	local cfg = SoulEggEvolutionConst.EvolutionAnimation.animStateList[math.random(1, #SoulEggEvolutionConst.EvolutionAnimation.animStateList)]
	local cfgType = type(cfg)

	if cfgType == "string" then
		self.petEvolveVirtualEntity:playDelayAnimation(SoulEggEvolutionConst.EvolutionAnimation.startTime, cfg, true)
	elseif cfgType == "table" then
		self.petEvolveVirtualEntity:playDelayCfgAnimation(SoulEggEvolutionConst.EvolutionAnimation.startTime, cfg)
	end

	local isShiny = Utils.isLabelShiny(self._newEntityInfo.label)

	self:playTimer(EvolutionSucConst.startTime, function()
		local effKey = isShiny and EvolutionSucConst.shinyEffectName or EvolutionSucConst.normalEffectName
		local successFxInfo = self:getDefaultFxExtraInfo()

		successFxInfo.startTime = EvolutionSucConst.prewarmTime
		successFxInfo.forceLodLevel = EvolutionSucConst.forceLodLevel

		local presentationPosition, presentationScale = scene:getIncubatePresentationPosition(presentationStage, "SuccessEffect")

		successFxInfo.position = presentationPosition
		successFxInfo.scale = presentationScale
		self.petSuccessEffectId = scene:playEffectOnEggRoot(effKey, successFxInfo)
	end, runToken, scene)
	self:playTimer(SoulEggEvolutionConst.EvolutionPetShowTime, function()
		self:_finishEggTouchPlaying()

		local effKey = isShiny and EvolutionSucConst.shinyBgEffectName or EvolutionSucConst.normalBgEffectName
		local successBgFxInfo = self:getDefaultFxExtraInfo()

		successBgFxInfo.forceLodLevel = EvolutionSucConst.forceLodLevel

		local presentationPosition, presentationScale = scene:getIncubatePresentationPosition(presentationStage, "SuccessBackgroundEffect")

		successBgFxInfo.position = presentationPosition
		successBgFxInfo.scale = presentationScale
		self.petSuccessBgEffectId = scene:playEffectOnEggRoot(effKey, successBgFxInfo)

		pg.game.audio:playEvent("SFX_UI_Incubate_LightEffects")
	end, runToken, scene)
end

function SoulEggEvolutionSystem:setUIVisible(visible)
	if not self:isInEvolution() then
		return
	end

	if visible then
		pg.global.ui:restoreAllUIByCustomKey(UIConst.UI_HIDE_KEY.PET_EVOLVE)
	else
		pg.global.ui:hideAllUIByCustomKey(UIConst.UI_HIDE_KEY.PET_EVOLVE, SoulEggEvolutionConst.UIWhileList)
	end
end

function SoulEggEvolutionSystem:clearEffect()
	local scene = self.evolutionScene

	self.bgEffectId = nil

	if self.petSuccessEffectId then
		if scene and not scene.expire then
			scene:stopEffect(self.petSuccessEffectId)
		end

		self.petSuccessEffectId = nil
	end

	if self.petSuccessBgEffectId then
		if scene and not scene.expire then
			scene:stopEffect(self.petSuccessBgEffectId)
		end

		self.petSuccessBgEffectId = nil
	end

	if self.soulEggBreakEffectId then
		if scene and not scene.expire then
			scene:stopEffect(self.soulEggBreakEffectId)
		end

		self.soulEggBreakEffectId = nil
	end
end

function SoulEggEvolutionSystem:clearSoulEgg()
	local scene = self.evolutionScene

	self.soulEggEntity = nil

	if scene and not scene.expire then
		scene:removeSoulEggEntity()
	end
end

function SoulEggEvolutionSystem:clearPetEvolveEntity()
	local scene = self.evolutionScene

	self.petEvolveVirtualEntity = nil

	if scene and not scene.expire then
		scene:removePetEntity()
	end
end

function SoulEggEvolutionSystem:clearEvolutionScene()
	self._cubeSwitchToken = (self._cubeSwitchToken or 0) + 1

	self:_releaseCubeSwitchEffect()
	self:_releaseChooseCubeBackgroundEffects()

	local scene = self.evolutionScene

	self.evolutionScene = nil

	if scene and not scene.expire then
		scene:resetPresentation()
	end
end

function SoulEggEvolutionSystem:playPetDetail(isOpen)
	local runToken = self._runToken
	local scene = self.evolutionScene

	if not self:_isRunContextValid(runToken, scene) or not self.petEvolveVirtualEntity then
		return
	end

	if isOpen then
		local cfg = SoulEggEvolutionConst.EvolutionAnimation.animStateList[math.random(1, #SoulEggEvolutionConst.EvolutionAnimation.animStateList)]
		local cfgType = type(cfg)

		if cfgType == "string" then
			local state = self.petEvolveVirtualEntity:playAnimation(cfg)

			state:AddAutoTransition(0)
		elseif cfgType == "table" then
			self.petEvolveVirtualEntity:playCfgAnimation(cfg)
		end
	end
end

function SoulEggEvolutionSystem:playEggBroken(index)
	if self.soulEggEntity then
		self.soulEggEntity:playEggBrokenEffect(index)
	elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error(string.format("SoulEggEvolutionSystem:playEggBrokenEffect Failed! soulEggEntity is nil!"))
	end
end

function SoulEggEvolutionSystem:playTimer(delay, func, runToken, scene)
	local capturedRunToken = runToken or self._runToken
	local capturedScene = scene or self.evolutionScene
	local timerId = TimerManager.addTimer(delay, function()
		if self:_isRunContextValid(capturedRunToken, capturedScene) then
			func()
		end
	end)

	self.soulEggEvolutionTimerList[#self.soulEggEvolutionTimerList + 1] = timerId
end

function SoulEggEvolutionSystem:getDefaultFxExtraInfo()
	local newFxExtraInfo = {
		duration = -1,
		layer = ClientConst.LayerDefine.LAYER_UI_SCENE,
		position = Vector3(0, 0, 0),
		rotation = Quaternion.identity,
		loadCallback = function(effectItem)
			local effectTs = effectItem and effectItem.effectTrans

			if NotNil(effectTs) then
				local fxSetComp = effectTs:GetComponent("EffectLevelSetting")

				if fxSetComp then
					fxSetComp:IgnoreUnLoad()
					fxSetComp:SetEnableUpdate(false)
				end
			end
		end
	}

	return newFxExtraInfo
end

function SoulEggEvolutionSystem:onSelectedCube(cubeItemId)
	if not self:_isRunContextValid(self._runToken, self.evolutionScene) then
		return
	end

	if not cubeItemId then
		self:_clearCubeEntityAndEffect()

		return
	end

	self:_setCubeEntityAndEffect(cubeItemId, ENABLE_CHOOSE_CUBE_EGG_OUT_EFFECT)
end

function SoulEggEvolutionSystem:_createSelectedCube(cubeItemId)
	local cubeFxs = self:getCubeFxsByCubeItemId(cubeItemId)

	self:_clearCubeFxs()
	self:_clearCubeMappedEffect()
	self:_hideChooseCubeBackgroundExitEffects()
	self:_clearCubeEntity()
	self:_clearEggChooseCubeFxs()

	self._cacheCubeFxsInfo = {
		fxGroupKey = cubeFxs.fxGroupKey,
		rawCubeFxs = cubeFxs
	}

	self:_createCubeEntityAndInEffect(cubeItemId, self:getDefaultFxExtraInfo())
end

function SoulEggEvolutionSystem:_isCubeSwitchContextValid(context)
	return context ~= nil and self._cubeSwitchContext == context and context.switchToken == self._cubeSwitchToken and self:_isRunContextValid(context.runToken, context.scene) and self._cacheCubeFxsInfo and self._cacheCubeFxsInfo.cubeEntity == context.oldCubeEntity
end

function SoulEggEvolutionSystem:_playOldCubeExit(context)
	if context.oldExitStarted or not self:_isCubeSwitchContextValid(context) then
		return false
	end

	context.oldExitStarted = true

	local isExitPlaying = false
	local oldRawCubeFx = context.oldRawCubeFx
	local oldCubeEntity = context.oldCubeEntity

	if oldRawCubeFx.CubeOutKey then
		local cubeOutFxInfo = self:getDefaultFxExtraInfo()

		cubeOutFxInfo.duration = PetFertilityConst.CubeOutTweenTime

		function cubeOutFxInfo.endCallback()
			if self:_isCubeSwitchContextValid(context) then
				oldCubeEntity:setCubeVisible(false)
			end
		end

		oldCubeEntity:playCubeEffect(oldRawCubeFx.CubeOutKey, cubeOutFxInfo)

		isExitPlaying = true
	end

	if context.shouldPlayEggOutEffect then
		local isEggOutPlaying = self:_playChooseCubeBackgroundExitEffect(context.oldFxGroupKey)

		if not isEggOutPlaying then
			self:_clearCubeMappedEffect()
			self:_clearEggChooseCubeFxs()

			if oldRawCubeFx.EggOutKey and self.soulEggEntity then
				local eggOutFxInfo = self:getDefaultFxExtraInfo()

				eggOutFxInfo.duration = PetFertilityConst.CubeOutTweenTime
				eggOutFxInfo.position = oldRawCubeFx.EggOutPos

				local eggOutEffectId = self.soulEggEntity:playChooseCubeEffect(oldRawCubeFx.EggOutKey, eggOutFxInfo, context.scene.eggRootTransform, onChooseCubeBackgroundLineLoaded, context.scene.catchBallRootTransform)

				isEggOutPlaying = eggOutEffectId ~= nil and eggOutEffectId ~= 0
			end
		end

		isExitPlaying = isExitPlaying or isEggOutPlaying
	end

	return isExitPlaying
end

function SoulEggEvolutionSystem:_scheduleCubeSwitchOldExit(context)
	if self._cubeSwitchOutDelayTimer then
		TimerManager.removeTimer(self._cubeSwitchOutDelayTimer)

		self._cubeSwitchOutDelayTimer = nil
	end

	local timerId

	timerId = TimerManager.addTimer(PetFertilityConst.CubeSwitchOutDelayTime, function()
		if self._cubeSwitchOutDelayTimer == timerId then
			self._cubeSwitchOutDelayTimer = nil
		end

		self:_playOldCubeExit(context)
	end)
	self._cubeSwitchOutDelayTimer = timerId
end

function SoulEggEvolutionSystem:_scheduleCubeSwitchFinish(context, waitDuration)
	if self.delayClearOldTimer then
		TimerManager.removeTimer(self.delayClearOldTimer)

		self.delayClearOldTimer = nil
	end

	if not waitDuration or waitDuration <= 0 then
		self:_finishCubeSwitch(context)

		return
	end

	local timerId

	timerId = TimerManager.addTimer(waitDuration, function()
		if self.delayClearOldTimer == timerId then
			self.delayClearOldTimer = nil
		end

		self:_finishCubeSwitch(context)
	end)
	self.delayClearOldTimer = timerId
end

function SoulEggEvolutionSystem:_finishCubeSwitch(context)
	if not self:_isCubeSwitchContextValid(context) then
		return
	end

	local cubeItemId = context.cubeItemId

	self:_clearCubeSwitchDelayTimer()

	self._cubeSwitchContext = nil

	self:_createSelectedCube(cubeItemId)
end

function SoulEggEvolutionSystem:_startCubeSwitch(context)
	if self:_replayCubeSwitchEffect() then
		self:_scheduleCubeSwitchOldExit(context)
		self:_scheduleCubeSwitchEffectHide()
		self:_scheduleCubeSwitchFinish(context, PetFertilityConst.CubeSwitchNewCubeDelayTime)

		return
	end

	local shouldWaitForOutEffect = self:_playOldCubeExit(context)
	local waitDuration = shouldWaitForOutEffect and PetFertilityConst.CubeOutTweenTime or 0

	self:_scheduleCubeSwitchFinish(context, waitDuration)
end

function SoulEggEvolutionSystem:_setCubeEntityAndEffect(cubeItemId, shouldPlayEggOutEffect)
	shouldPlayEggOutEffect = shouldPlayEggOutEffect ~= false

	local runToken = self._runToken
	local scene = self.evolutionScene

	if not self:_isRunContextValid(runToken, scene) then
		return
	end

	local activeContext = self._cubeSwitchContext

	if activeContext and self:_isCubeSwitchContextValid(activeContext) then
		activeContext.cubeItemId = cubeItemId

		return
	elseif activeContext then
		self:_cancelCubeSwitch()
	end

	self._cacheCubeFxsInfo = self._cacheCubeFxsInfo or {}

	local oldFxGroupKey = self._cacheCubeFxsInfo.fxGroupKey
	local oldRawCubeFx = self._cacheCubeFxsInfo.rawCubeFxs
	local oldCubeEntity = self._cacheCubeFxsInfo.cubeEntity

	self._cubeSwitchToken = (self._cubeSwitchToken or 0) + 1

	if oldFxGroupKey == nil or not oldRawCubeFx or not oldCubeEntity then
		self:_createSelectedCube(cubeItemId)

		return
	end

	self:_clearCubeFxs()
	self:_clearCubeMappedEffect(true)

	local context = {
		cubeItemId = cubeItemId,
		oldCubeEntity = oldCubeEntity,
		oldFxGroupKey = oldFxGroupKey,
		oldRawCubeFx = oldRawCubeFx,
		runToken = runToken,
		scene = scene,
		shouldPlayEggOutEffect = shouldPlayEggOutEffect,
		switchToken = self._cubeSwitchToken
	}

	self._cubeSwitchContext = context

	self:_startCubeSwitch(context)
end

function SoulEggEvolutionSystem:_createCubeEntityAndInEffect(cubeItemId, extraInfo)
	local scene = self.evolutionScene
	local runToken = self._runToken

	if not self:_isRunContextValid(runToken, scene) then
		return
	end

	local localCacheCubeFxsInfo = {}
	local ballCfg, ballCfgId = CaptureUtils.getBallCfg(cubeItemId)
	local cubeFxs = self:getCubeFxsByCubeItemId(cubeItemId)
	local cubeSwitchToken = self._cubeSwitchToken

	local function isCubeInEffectsContextValid(cubeEntity)
		return cubeSwitchToken == self._cubeSwitchToken and self:_isRunContextValid(runToken, scene) and self._cacheCubeFxsInfo and self._cacheCubeFxsInfo.cubeEntity == cubeEntity and scene.cubeEntity == cubeEntity
	end

	local function playCubeInEffectsNow(cubeEntity)
		cubeEntity:playEnterShow()
		cubeEntity:setCubeVisible(true)

		if self:_setChooseCubeBackgroundEffectsVisible(cubeFxs.fxGroupKey) then
			self:_replayChooseCubeBackgroundEnterEffects(cubeFxs.fxGroupKey)
		else
			local cubeInFxResId = cubeFxs and PetFertilityConst.FxResIds[cubeFxs.CubeInKey]

			if cubeInFxResId then
				self._cubeMappedEffectId = scene:playRawEffectOnCubeRoot(cubeInFxResId, self:getDefaultFxExtraInfo(), true)
			end

			local eggEntity = self.soulEggEntity

			if eggEntity and cubeFxs and cubeFxs.EggInKey then
				local eggInFxEInfo = self:getDefaultFxExtraInfo()

				eggInFxEInfo.position = {
					CHOOSE_EGG_BACKGROUND_LOCAL_X,
					0,
					0
				}

				eggEntity:playChooseCubeEffect(cubeFxs.EggInKey, eggInFxEInfo, scene.eggRootTransform, onChooseCubeBackgroundLineLoaded, scene.catchBallRootTransform)
			end
		end
	end

	local function playCubeInEffects(cubeEntity)
		if not isCubeInEffectsContextValid(cubeEntity) then
			return
		end

		TimerManager.addNextFrameCb(function()
			if not isCubeInEffectsContextValid(cubeEntity) then
				return
			end

			playCubeInEffectsNow(cubeEntity)
		end)
	end

	if ballCfg and ballCfg.model then
		local cubeEntity, isModelReady = scene:borrowCubeEntity(cubeItemId, playCubeInEffects)

		localCacheCubeFxsInfo.cubeEntity = cubeEntity
		self._cacheCubeFxsInfo = self._cacheCubeFxsInfo or {}
		self._cacheCubeFxsInfo.cubeEntity = cubeEntity

		if not cubeEntity then
			local cubeModelInfo = {
				itemId = cubeItemId,
				scale = extraInfo and extraInfo.scale
			}

			localCacheCubeFxsInfo.cubeEntity = scene:createCubeEntity(cubeModelInfo, ballCfg.model, {
				onModelReady = playCubeInEffects
			})
			self._cacheCubeFxsInfo.cubeEntity = localCacheCubeFxsInfo.cubeEntity
			isModelReady = localCacheCubeFxsInfo.cubeEntity and localCacheCubeFxsInfo.cubeEntity._cubeModelReady
		end

		if localCacheCubeFxsInfo.cubeEntity and isModelReady then
			playCubeInEffects(localCacheCubeFxsInfo.cubeEntity)
		end
	end

	self._cacheCubeFxsInfo = self._cacheCubeFxsInfo or {}
	self._cacheCubeFxsInfo.cubeEntity = localCacheCubeFxsInfo.cubeEntity
end

function SoulEggEvolutionSystem:_clearCubeEntityAndEffect()
	self._cubeSwitchToken = (self._cubeSwitchToken or 0) + 1

	self:_cancelCubeSwitch()
	self:_hideChooseCubeBackgroundExitEffects()
	self:_clearCubeFxs()
	self:_clearCubeMappedEffect()
	self:_clearCubeEntity()
	self:_clearEggChooseCubeFxs()

	self._cacheCubeFxsInfo = {}
end

function SoulEggEvolutionSystem:_clearCubeEntity()
	if self._cacheCubeFxsInfo then
		self._cacheCubeFxsInfo.cubeEntity = nil
	end

	local scene = self.evolutionScene

	if scene and not scene.expire then
		scene:recycleCubeEntity()
	end
end

function SoulEggEvolutionSystem:_clearEggChooseCubeFxs()
	if self._chooseCubeBackgroundEffectPool then
		return
	end

	if self.soulEggEntity then
		self.soulEggEntity:stopChooseCubeEffect()
	end
end

function SoulEggEvolutionSystem:_clearCubeFxs()
	if self._cacheCubeFxsInfo and self._cacheCubeFxsInfo.cubeEntity then
		self._cacheCubeFxsInfo.cubeEntity:stopCubeEffect()
	end
end

function SoulEggEvolutionSystem:_clearCubeMappedEffect(keepEggBackgroundVisible)
	if self._chooseCubeBackgroundEffectPool then
		if keepEggBackgroundVisible then
			for _, poolEntry in pairs(self._chooseCubeBackgroundEffectPool) do
				if NotNil(poolEntry.cubeEffectHolder) then
					poolEntry.cubeEffectHolder.transform.localPosition = Vector3(0, 0, CHOOSE_CUBE_BACKGROUND_PREWARM_LOCAL_Z)
				end
			end
		else
			self:_setChooseCubeBackgroundEffectsVisible(nil)
		end

		return
	end

	local effectId = self._cubeMappedEffectId

	self._cubeMappedEffectId = nil

	local scene = self.evolutionScene

	if effectId and scene and not scene.expire then
		scene:stopEffect(effectId)
	end
end

function SoulEggEvolutionSystem:resetChooseCubeInfos()
	self._cacheCubeFxsInfo = {}
end

function SoulEggEvolutionSystem:getCubeFxsByCubeItemId(itemId)
	local cubeBallCfg = CaptureUtils.getFetilityCubeCfg(itemId)
	local linkEffectId = cubeBallCfg and cubeBallCfg.linkEffect or 0
	local fxGroupKey = PetFertilityConst.FxGroupKeys[linkEffectId] or PetFertilityConst.PetFertilityCubeIds.GeneralCubeItemId
	local cubeFxs = PetFertilityConst.ChooseCubeFxs[fxGroupKey]

	return cubeFxs or {}
end

function SoulEggEvolutionSystem:isInEggTouchPlaying()
	return self._isInEggTouchPlaying
end

function SoulEggEvolutionSystem:shouldRecordTipsUntilEvolutionClose()
	return self._isInEggTouchPlaying or self._recordedTipsReadyToShow == true
end

function SoulEggEvolutionSystem:recordTips(tipsInfo)
	self._tipsInfoList = self._tipsInfoList or {}

	table.insert(self._tipsInfoList, tipsInfo)

	while #self._tipsInfoList > MAX_RECORDED_TIPS do
		table.remove(self._tipsInfoList, 1)
	end
end

function SoulEggEvolutionSystem:showRecordTips()
	while self._tipsInfoList and #self._tipsInfoList > 0 do
		local tipsInfo = table.remove(self._tipsInfoList, 1)

		pg.global.ui.tips:showTextTipByArgs(tipsInfo)
	end

	self._tipsInfoList = nil
end

function SoulEggEvolutionSystem:_finishEggTouchPlaying()
	self._isInEggTouchPlaying = false
	self._recordedTipsReadyToShow = true
end

function SoulEggEvolutionSystem:_flushRecordedTips()
	if not self._recordedTipsReadyToShow and (not self._tipsInfoList or #self._tipsInfoList <= 0) then
		return
	end

	self._recordedTipsReadyToShow = false

	self:showRecordTips()
end

function SoulEggEvolutionSystem:_finalizeRecordedTipsForReset(deferRecordedTips)
	if deferRecordedTips then
		return
	end

	self:_flushRecordedTips()

	self._tipsInfoList = nil
	self._recordedTipsReadyToShow = false
end

return SoulEggEvolutionSystem
