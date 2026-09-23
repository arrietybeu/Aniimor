-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Scenes\\UIScenes\\SoulEggEvolutionScene.lua

local Class = require("Core.Framework.Class")
local UISceneBase = require("GameApp.UIScene.UISceneBase")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local ClientUtils = require("Utils.ClientUtils")
local ClientConst = require("Const.ClientConst")
local Const = require("Common.Const.Const")
local LuaUIUtils = require("Utils.LuaUIUtils")
local TimerManager = require("Core.Timer.TimerManager")
local EffectConst = require("Const.EffectConst")
local EvolutionConst = require("Common.Const.EvolutionConst")
local Vector3 = Vector3
local Quaternion = Quaternion
local UI_SCENE_LAYER = ClientConst.LayerDefine.LAYER_UI_SCENE
local CAMERA_MOVE_TWEEN_ID = LuaUIUtils.TweenId("soulEggEvolutionCameraMove")
local CAMERA_MOVE_DURATION = 0.75
local CUBE_CACHE_LOCAL_POSITION = Vector3.New(0, -9999, 0)
local CUBE_MODEL_READY_TIMEOUT_SECONDS = 10
local SoulEggEvolutionScene = Class.LightClass("SoulEggEvolutionScene", UISceneBase)

function SoulEggEvolutionScene:onCtor()
	self._presentationReady = false
	self._presentationErrorReason = nil
	self._presentationToken = 0
	self._effectIds = {}
	self._cameraPresentationLocalPosition = nil
	self._cubeEntityPool = {}
	self._cubePoolInfoMap = {}
	self._cubePoolPreloadToken = 0
	self._cubePoolReadyCallback = nil
end

function SoulEggEvolutionScene:onStart()
	self._presentationReady = false
	self._presentationErrorReason = nil

	local globalTransform = self.scene and self.scene.transform:Find("Global")

	if IsNil(globalTransform) then
		self:_setPresentationError("missing-Global")

		return
	end

	self.objectReference = globalTransform:GetComponent("ObjectReference")

	if IsNil(self.objectReference) then
		self:_setPresentationError("missing-ObjectReference")

		return
	end

	self.camera = self.objectReference:GetRefValue("camera")
	self.globalTransform = globalTransform
	self.catchBallRootTransform = self.objectReference:GetRefValue("catchBallRootTransform")
	self.eggRootTransform = self.objectReference:GetRefValue("eggRootTransform")

	if IsNil(self.camera) or IsNil(self.catchBallRootTransform) or IsNil(self.eggRootTransform) then
		self:_setPresentationError(string.format("missing-reference camera=%s catchBallRoot=%s eggRoot=%s", tostring(self.camera), tostring(self.catchBallRootTransform), tostring(self.eggRootTransform)))

		return
	end

	local cameraTransform = self.camera.transform

	self._cameraInitialLocalPosition = cameraTransform.localPosition
	self._cameraInitialLocalRotation = cameraTransform.localRotation
	self._cameraPresentationLocalPosition = nil

	pg.global.cameraMgr:SetUISceneCamera(self.camera)

	self._presentationReady = true
end

function SoulEggEvolutionScene:_setPresentationError(reason)
	self._presentationReady = false
	self._presentationErrorReason = reason
end

function SoulEggEvolutionScene:isPresentationReady()
	return self._presentationReady == true and not self.expire and NotNil(self.camera) and NotNil(self.catchBallRootTransform) and NotNil(self.eggRootTransform)
end

function SoulEggEvolutionScene:getPresentationErrorReason()
	return self._presentationErrorReason
end

function SoulEggEvolutionScene:_isPresentationContextValid(presentationToken)
	return presentationToken == self._presentationToken and self:isPresentationReady() and self:checkLoadSucceed() and pg.game.uiScene:getScene(UISceneConst.SOUL_EGG_EVOLUTION_SCENE) == self
end

function SoulEggEvolutionScene:_attachEntity(entity, parentTransform)
	if not entity or not entity.eModel or IsNil(parentTransform) then
		if entity then
			ClientUtils.safeDestroy(entity)
		end

		return nil
	end

	local eModel = entity.eModel

	eModel:SetTransformParent(parentTransform, false)
	eModel:SetTransformLocalPosition()
	eModel:SetTransformLocalRotation(0, 0, 0, 1)

	eModel.enableCameraHitCheck = false

	entity:setModelLayer(UI_SCENE_LAYER)
	entity:setLodTickEnable(Const.LOD_TICK_KEY.DEFAULT, false)
	entity:setRendererLod(0)

	entity._soulEggDebugCamera = self.camera
	entity._soulEggDebugParentTransform = parentTransform

	return entity
end

function SoulEggEvolutionScene:createSoulEggEntity(soulEggInfo, presentationOptions)
	if not self:isPresentationReady() or not soulEggInfo then
		return nil
	end

	self:removeSoulEggEntity()

	presentationOptions = presentationOptions or {}

	local onModelReady = presentationOptions.onModelReady
	local entityOptions = {}

	for key, value in pairs(presentationOptions) do
		entityOptions[key] = value
	end

	entityOptions.targetLayer = UI_SCENE_LAYER

	if onModelReady then
		function entityOptions.onModelReady(readyEntity)
			if self.soulEggEntity ~= readyEntity then
				readyEntity._pendingSoulEggModelReadyCallback = onModelReady

				return
			end

			onModelReady(readyEntity)
		end
	end

	local entity = ClientUtils.createSoulEggEvolutionEntity(soulEggInfo, Vector3.zero, Quaternion.identity, entityOptions)

	self.soulEggEntity = self:_attachEntity(entity, self.eggRootTransform)

	if self.soulEggEntity and self.soulEggEntity._pendingSoulEggModelReadyCallback then
		local callback = self.soulEggEntity._pendingSoulEggModelReadyCallback

		self.soulEggEntity._pendingSoulEggModelReadyCallback = nil

		callback(self.soulEggEntity)
	end

	return self.soulEggEntity
end

function SoulEggEvolutionScene:removeSoulEggEntity()
	local entity = self.soulEggEntity

	self.soulEggEntity = nil

	if entity then
		ClientUtils.safeDestroy(entity)
	end
end

function SoulEggEvolutionScene:createPetEntity(petInfo)
	if not self:isPresentationReady() or not petInfo then
		return nil
	end

	self:removePetEntity()

	local entity = ClientUtils.createEvolutionEntity(petInfo, Vector3.zero, Quaternion.identity, {
		targetLayer = UI_SCENE_LAYER
	})

	self.petEntity = self:_attachEntity(entity, self.eggRootTransform)

	return self.petEntity
end

function SoulEggEvolutionScene:removePetEntity()
	local entity = self.petEntity

	self.petEntity = nil

	if entity then
		ClientUtils.safeDestroy(entity)
	end
end

function SoulEggEvolutionScene:createCubeEntity(cubeInfo, resId, presentationOptions)
	if not self:isPresentationReady() or not cubeInfo or not resId then
		return nil
	end

	self:recycleCubeEntity()

	presentationOptions = presentationOptions or {}
	presentationOptions.targetLayer = UI_SCENE_LAYER

	local entity = ClientUtils.createFertilityCubeEntity(cubeInfo, resId, Vector3.zero, Quaternion.identity, presentationOptions)

	self.cubeEntity = self:_attachEntity(entity, self.catchBallRootTransform)
	self._activeCubePoolItemId = nil

	if self.cubeEntity and presentationOptions.onModelReady then
		self.cubeEntity:setCubeVisible(false)
	end

	return self.cubeEntity
end

function SoulEggEvolutionScene:removeCubeEntity()
	if self._activeCubePoolItemId then
		self:recycleCubeEntity()

		return
	end

	local entity = self.cubeEntity

	self.cubeEntity = nil

	if entity then
		ClientUtils.safeDestroy(entity)
	end
end

function SoulEggEvolutionScene:preloadCubeEntities(cubeInfos, onAllReady)
	if not self:isPresentationReady() or not cubeInfos then
		if onAllReady then
			onAllReady(false)
		end

		return
	end

	self:_destroyCubeEntityPool()

	self._cubeEntityPool = {}
	self._cubePoolInfoMap = {}
	self._cubePoolPreloadToken = (self._cubePoolPreloadToken or 0) + 1
	self._cubePoolReadyCallback = onAllReady
	self._cubePoolPreloadList = {}
	self._cubePoolPreloadIndex = 1

	for _, cubeInfo in ipairs(cubeInfos) do
		if cubeInfo and cubeInfo.itemId and cubeInfo.resId and not self._cubePoolInfoMap[cubeInfo.itemId] then
			self._cubePoolInfoMap[cubeInfo.itemId] = cubeInfo
			self._cubePoolPreloadList[#self._cubePoolPreloadList + 1] = cubeInfo.itemId
		end
	end

	if #self._cubePoolPreloadList == 0 then
		self:_finishCubeEntityPreload(self._cubePoolPreloadToken, false)

		return
	end

	self:_preloadNextCubeEntity(self._cubePoolPreloadToken)
end

function SoulEggEvolutionScene:_preloadNextCubeEntity(preloadToken)
	if preloadToken ~= self._cubePoolPreloadToken or not self:isPresentationReady() then
		return
	end

	local itemId = self._cubePoolPreloadList and self._cubePoolPreloadList[self._cubePoolPreloadIndex]

	if not itemId then
		return
	end

	self._cubePoolPreloadIndex = self._cubePoolPreloadIndex + 1

	if not self._cubeEntityPool[itemId] then
		self:_createCubePoolEntry(itemId, ClientConst.InstantiatePriority.High)
	end

	self:_tryFinishCubeEntityPreload(preloadToken)
	TimerManager.addNextFrameCb(function()
		self:_preloadNextCubeEntity(preloadToken)
	end)
end

function SoulEggEvolutionScene:_createCubePoolEntry(itemId, instantiatePriority)
	local cubeInfo = self._cubePoolInfoMap and self._cubePoolInfoMap[itemId]

	if not cubeInfo or not cubeInfo.resId or not self.globalTransform then
		return nil
	end

	local entry = self._cubeEntityPool[itemId]

	if entry then
		return entry
	end

	entry = {
		state = "loading",
		modelReady = false,
		itemId = itemId
	}
	self._cubeEntityPool[itemId] = entry

	local presentationToken = self._presentationToken
	local preloadToken = self._cubePoolPreloadToken

	entry.entity = ClientUtils.createFertilityCubeEntity(cubeInfo, cubeInfo.resId, Vector3.zero, Quaternion.identity, {
		targetLayer = UI_SCENE_LAYER,
		instantiatePriority = instantiatePriority or ClientConst.InstantiatePriority.High,
		onModelReady = function(entity)
			if presentationToken ~= self._presentationToken then
				return
			end

			if not entry.entity then
				entry.pendingModelReadyEntity = entity

				return
			end

			self:_onCubePoolModelReady(itemId, entity)
		end
	})

	if not entry.entity then
		self._cubeEntityPool[itemId] = nil

		return nil
	end

	if self:_attachEntity(entry.entity, self.globalTransform) ~= entry.entity then
		self._cubeEntityPool[itemId] = nil

		return nil
	end

	self:_cacheCubeEntity(entry)

	if entry.pendingModelReadyEntity then
		local readyEntity = entry.pendingModelReadyEntity

		entry.pendingModelReadyEntity = nil

		self:_onCubePoolModelReady(itemId, readyEntity)
	end

	if not entry.modelReady then
		entry.modelReadyTimeout = TimerManager.addTimer(CUBE_MODEL_READY_TIMEOUT_SECONDS, function()
			entry.modelReadyTimeout = nil

			if presentationToken ~= self._presentationToken or self._cubeEntityPool[itemId] ~= entry or entry.modelReady then
				return
			end

			entry.modelReadyTimedOut = true

			self:_tryFinishCubeEntityPreload(preloadToken)
		end)
	end

	return entry
end

function SoulEggEvolutionScene:_tryFinishCubeEntityPreload(preloadToken)
	if preloadToken ~= self._cubePoolPreloadToken or not self._cubePoolReadyCallback then
		return
	end

	local preloadList = self._cubePoolPreloadList or {}

	for _, itemId in ipairs(preloadList) do
		local entry = self._cubeEntityPool and self._cubeEntityPool[itemId]

		if not entry then
			if (self._cubePoolPreloadIndex or 1) > #preloadList then
				self:_finishCubeEntityPreload(preloadToken, false)
			end

			return
		end

		if entry.modelReadyTimedOut then
			self:_finishCubeEntityPreload(preloadToken, false)

			return
		end

		if not entry.modelReady then
			return
		end
	end

	self:_finishCubeEntityPreload(preloadToken, true)
end

function SoulEggEvolutionScene:_finishCubeEntityPreload(preloadToken, success)
	if preloadToken ~= self._cubePoolPreloadToken then
		return
	end

	local callback = self._cubePoolReadyCallback

	self._cubePoolReadyCallback = nil

	if callback then
		callback(success)
	end
end

function SoulEggEvolutionScene:_clearCubeModelReadyTimeout(entry)
	if entry and entry.modelReadyTimeout then
		TimerManager.removeTimer(entry.modelReadyTimeout)

		entry.modelReadyTimeout = nil
	end
end

function SoulEggEvolutionScene:_onCubePoolModelReady(itemId, entity)
	local entry = self._cubeEntityPool and self._cubeEntityPool[itemId]

	if not entry or entry.entity and entry.entity ~= entity then
		return
	end

	entry.modelReady = true
	entry.modelReadyTimedOut = nil

	self:_clearCubeModelReadyTimeout(entry)

	if entry.state == "borrowed" and self.cubeEntity == entity then
		local onReady = entry.onReady

		entry.onReady = nil

		if onReady then
			onReady(entity)
		end
	else
		self:_cacheCubeEntity(entry)
	end

	self:_tryFinishCubeEntityPreload(self._cubePoolPreloadToken)
end

function SoulEggEvolutionScene:_cacheCubeEntity(entry)
	local entity = entry and entry.entity

	if not entity or not entity.eModel or IsNil(self.globalTransform) then
		return
	end

	entity:stopCubeEffect()
	entity.eModel:SetTransformParent(self.globalTransform, false)

	entity.eModel.transform.localPosition = CUBE_CACHE_LOCAL_POSITION

	entity:setCubeVisible(false)

	if entry.modelReady then
		entity:setCubePresentationActive(false)
	end

	entry.state = "idle"
end

function SoulEggEvolutionScene:borrowCubeEntity(itemId, onReady)
	if not itemId or not self:isPresentationReady() then
		return nil, false
	end

	local entry = self._cubeEntityPool and self._cubeEntityPool[itemId]

	entry = entry or self:_createCubePoolEntry(itemId, ClientConst.InstantiatePriority.Urgent)

	if not entry or not entry.entity then
		return nil, false
	end

	if self.cubeEntity and self.cubeEntity ~= entry.entity then
		self:recycleCubeEntity()
	end

	entry.state = "borrowed"

	if entry.modelReady then
		-- block empty
	end

	entry.onReady = onReady
	self.cubeEntity = entry.entity
	self._activeCubePoolItemId = itemId

	if self:_attachEntity(entry.entity, self.catchBallRootTransform) ~= entry.entity then
		entry.onReady = nil
		self.cubeEntity = nil
		self._activeCubePoolItemId = nil

		self:_cacheCubeEntity(entry)

		return nil, false
	end

	local modelView = entry.entity.eModel.modelModelView

	if NotNil(modelView) then
		modelView.instPriority = ClientConst.InstantiatePriority.Urgent
	end

	entry.entity:setCubeVisible(false)

	if entry.modelReady and not entry.entity:setCubePresentationActive(true) then
		entry.onReady = nil
		self.cubeEntity = nil
		self._activeCubePoolItemId = nil

		self:_cacheCubeEntity(entry)

		return nil, false
	end

	return entry.entity, entry.modelReady
end

function SoulEggEvolutionScene:recycleCubeEntity()
	local entity = self.cubeEntity
	local itemId = self._activeCubePoolItemId

	self.cubeEntity = nil
	self._activeCubePoolItemId = nil

	if not entity then
		return
	end

	local entry = itemId and self._cubeEntityPool and self._cubeEntityPool[itemId]

	if entry and entry.entity == entity then
		entry.onReady = nil

		self:_cacheCubeEntity(entry)
	else
		ClientUtils.safeDestroy(entity)
	end
end

function SoulEggEvolutionScene:_destroyCubeEntityPool()
	self._cubePoolPreloadToken = (self._cubePoolPreloadToken or 0) + 1
	self._cubePoolReadyCallback = nil

	local activeEntity = self.cubeEntity
	local activeInPool = false

	self.cubeEntity = nil
	self._activeCubePoolItemId = nil

	for _, entry in pairs(self._cubeEntityPool or {}) do
		if entry.entity == activeEntity then
			activeInPool = true
		end

		entry.onReady = nil

		self:_clearCubeModelReadyTimeout(entry)

		if entry.entity then
			ClientUtils.safeDestroy(entry.entity)

			entry.entity = nil
		end
	end

	if activeEntity and not activeInPool then
		ClientUtils.safeDestroy(activeEntity)
	end

	self._cubeEntityPool = {}
	self._cubePoolInfoMap = {}
	self._cubePoolPreloadList = nil
	self._cubePoolPreloadIndex = nil
end

function SoulEggEvolutionScene:_playEffectOnRoot(effectKey, parentTransform, extraInfo, forceSync)
	if not self:isPresentationReady() or IsNil(parentTransform) or not effectKey or effectKey == "" then
		return nil
	end

	local effectInfo = {}

	for key, value in pairs(extraInfo or {}) do
		effectInfo[key] = value
	end

	effectInfo.layer = UI_SCENE_LAYER

	local presentationToken = self._presentationToken
	local originalLoadCallback = effectInfo.loadCallback
	local effectId

	function effectInfo.loadCallback(effectItem)
		if not self:_isPresentationContextValid(presentationToken) then
			if effectId then
				pg.game.effect:stopEffect(nil, effectId)
			end

			return
		end

		if originalLoadCallback then
			originalLoadCallback(effectItem)
		end
	end

	effectId = pg.game.effect:playEffectOn(nil, effectKey, parentTransform, effectInfo, forceSync)

	if not effectId or effectId == 0 then
		return nil
	end

	if not self:_isPresentationContextValid(presentationToken) then
		pg.game.effect:stopEffect(nil, effectId)

		return nil
	end

	self._effectIds[effectId] = true

	return effectId
end

function SoulEggEvolutionScene:playEffectOnEggRoot(effectKey, extraInfo, forceSync)
	return self:_playEffectOnRoot(effectKey, self.eggRootTransform, extraInfo, forceSync)
end

function SoulEggEvolutionScene:playEffectOnCubeRoot(effectKey, extraInfo, forceSync)
	return self:_playEffectOnRoot(effectKey, self.catchBallRootTransform, extraInfo, forceSync)
end

function SoulEggEvolutionScene:_playRawEffectOnRoot(resId, parentTransform, extraInfo, forceSync)
	if not self:isPresentationReady() or IsNil(parentTransform) or not resId or resId == "" then
		return nil
	end

	local effectInfo = {}

	for key, value in pairs(extraInfo or {}) do
		effectInfo[key] = value
	end

	effectInfo.layer = UI_SCENE_LAYER
	effectInfo.targetTrans = parentTransform

	local presentationToken = self._presentationToken
	local originalLoadCallback = effectInfo.loadCallback
	local originalEndCallback = effectInfo.endCallback
	local effectId
	local loadFailed = false

	function effectInfo.loadCallback(effectItem)
		if not effectItem then
			loadFailed = true

			if effectId then
				self._effectIds[effectId] = nil
			end
		end

		if not self:_isPresentationContextValid(presentationToken) then
			if effectId and effectId ~= 0 then
				pg.game.effect:stopEffect(nil, effectId)
			end

			return
		end

		if originalLoadCallback then
			originalLoadCallback(effectItem)
		end
	end

	if originalEndCallback then
		function effectInfo.endCallback(effectItem)
			if effectId then
				self._effectIds[effectId] = nil
			end

			if self:_isPresentationContextValid(presentationToken) then
				originalEndCallback(effectItem)
			end
		end
	end

	local rawInfo = {
		staticSpeed = true,
		followType = 0,
		duration = -1,
		resID = resId,
		mountType = EffectConst.MountType.Custom,
		scale = {
			1,
			1,
			1
		}
	}
	local effectConfigInfo = pg.game.effect:createEffectConfigInfo(rawInfo, effectInfo)

	effectId = pg.global.effectMgr:PlayEffect(0, resId, effectConfigInfo, 0, forceSync or false)

	if not effectId or effectId == 0 then
		return nil
	end

	if loadFailed then
		return nil
	end

	if not self:_isPresentationContextValid(presentationToken) then
		pg.game.effect:stopEffect(nil, effectId)

		return nil
	end

	self._effectIds[effectId] = true

	return effectId
end

function SoulEggEvolutionScene:playRawEffectOnCubeRoot(resId, extraInfo, forceSync, parentTransform)
	return self:_playRawEffectOnRoot(resId, parentTransform or self.catchBallRootTransform, extraInfo, forceSync)
end

function SoulEggEvolutionScene:stopEffect(effectId)
	if not effectId then
		return
	end

	self._effectIds[effectId] = nil

	pg.game.effect:stopEffect(nil, effectId)
end

function SoulEggEvolutionScene:releaseEffect(effectId)
	if not effectId then
		return
	end

	self._effectIds[effectId] = nil

	pg.game.effect:stopEffect(nil, effectId, true)
end

function SoulEggEvolutionScene:clearEffects()
	local effectIds = self._effectIds

	self._effectIds = {}

	for effectId, _ in pairs(effectIds) do
		pg.game.effect:stopEffect(nil, effectId)
	end
end

function SoulEggEvolutionScene:_killCameraMoveTween()
	if IsNil(self.camera) then
		return
	end

	if DoTweenAnimMgr.IsTweening(self.camera.gameObject, CAMERA_MOVE_TWEEN_ID) then
		DoTweenAnimMgr.Kill(self.camera.gameObject, CAMERA_MOVE_TWEEN_ID, false)
	end
end

function SoulEggEvolutionScene:moveCameraToEggCenter(duration)
	if IsNil(self.camera) or IsNil(self.eggRootTransform) then
		return false
	end

	local cameraTransform = self.camera.transform
	local eggCameraPosition = cameraTransform:InverseTransformPoint(self.eggRootTransform.position)

	if eggCameraPosition.z <= 0 then
		return false
	end

	local targetWorldPosition = cameraTransform.position + cameraTransform.right * eggCameraPosition.x
	local cameraParent = cameraTransform.parent

	if IsNil(cameraParent) then
		self._cameraPresentationLocalPosition = targetWorldPosition
	else
		self._cameraPresentationLocalPosition = cameraParent:InverseTransformPoint(targetWorldPosition)
	end

	self:_killCameraMoveTween()
	DoTweenAnimMgr.GlobalMove(cameraTransform, CAMERA_MOVE_TWEEN_ID, targetWorldPosition, duration or CAMERA_MOVE_DURATION, 0, CS.DG.Tweening.Ease.__CastFrom(6), nil, nil, false)

	return true
end

function SoulEggEvolutionScene:moveCameraToEggCenterImmediate()
	if IsNil(self.camera) or IsNil(self.eggRootTransform) then
		return false
	end

	local cameraTransform = self.camera.transform
	local eggCameraPosition = cameraTransform:InverseTransformPoint(self.eggRootTransform.position)

	if eggCameraPosition.z <= 0 then
		return false
	end

	local targetWorldPosition = cameraTransform.position + cameraTransform.right * eggCameraPosition.x
	local cameraParent = cameraTransform.parent

	if IsNil(cameraParent) then
		self._cameraPresentationLocalPosition = targetWorldPosition
	else
		self._cameraPresentationLocalPosition = cameraParent:InverseTransformPoint(targetWorldPosition)
	end

	self:_killCameraMoveTween()

	cameraTransform.position = targetWorldPosition

	return true
end

function SoulEggEvolutionScene:moveCameraToEggCenterImmediateWorldSpace(offset)
	if IsNil(self.camera) or IsNil(self.eggRootTransform) then
		return false
	end

	local cameraTransform = self.camera.transform
	local eggWorldPos = self.eggRootTransform.position
	local cameraWorldPos = cameraTransform.position
	local targetWorldPosition = Vector3.New(eggWorldPos.x, cameraWorldPos.y, cameraWorldPos.z)

	if offset then
		local offsetY = offset.y or offset[2] or 0
		local offsetZ = offset.z or offset[3] or 0

		targetWorldPosition = Vector3.New(eggWorldPos.x, cameraWorldPos.y + offsetY, cameraWorldPos.z + offsetZ)
	end

	local cameraParent = cameraTransform.parent

	if IsNil(cameraParent) then
		self._cameraPresentationLocalPosition = targetWorldPosition
	else
		self._cameraPresentationLocalPosition = cameraParent:InverseTransformPoint(targetWorldPosition)
	end

	self:_killCameraMoveTween()

	cameraTransform.position = targetWorldPosition

	return true
end

function SoulEggEvolutionScene:setCameraOffsetKeepCentered(offset)
	if IsNil(self.camera) or not self._cameraInitialLocalPosition or IsNil(self.eggRootTransform) then
		return
	end

	local offsetY = offset and (offset.y or offset[2]) or 0
	local offsetZ = offset and (offset.z or offset[3]) or 0
	local cameraTransform = self.camera.transform
	local cameraWorldPos = cameraTransform.position
	local cameraForward = cameraTransform.forward
	local cameraUp = cameraTransform.up
	local targetWorldPos = cameraWorldPos - cameraForward * offsetZ + cameraUp * 0.71

	self:_killCameraMoveTween()

	cameraTransform.position = targetWorldPos

	local cameraParent = cameraTransform.parent

	if not IsNil(cameraParent) then
		self._cameraPresentationLocalPosition = cameraParent:InverseTransformPoint(targetWorldPos)
	else
		self._cameraPresentationLocalPosition = targetWorldPos
	end
end

function SoulEggEvolutionScene:setCameraOffset(offset)
	if IsNil(self.camera) or not self._cameraInitialLocalPosition then
		return
	end

	local x = offset and (offset.x or offset[1]) or 0
	local y = offset and (offset.y or offset[2]) or 0
	local z = offset and (offset.z or offset[3]) or 0
	local baseLocalPosition = self._cameraPresentationLocalPosition or self._cameraInitialLocalPosition

	self:_killCameraMoveTween()

	self.camera.transform.localPosition = baseLocalPosition + Vector3.New(x, y, z)
end

function SoulEggEvolutionScene:getIncubatePresentationPosition(stage, presentationType)
	if IsNil(self.camera) or IsNil(self.eggRootTransform) then
		return Vector3.zero, 1
	end

	if stage and stage >= 3 then
		local positionConfig = EvolutionConst.SoulEggEvolution.IncubatePresentationPosition.LargeStage
		local position = positionConfig[presentationType or "Model"] or positionConfig.Model

		return position, 1
	end

	local cameraConfig = EvolutionConst.SoulEggEvolution.IncubatePresentationCameraTarget.SmallStage
	local cameraParent = self.camera.transform.parent
	local targetCameraWorldPosition = IsNil(cameraParent) and cameraConfig or cameraParent:TransformPoint(cameraConfig)
	local currentCameraWorldPosition = self.camera.transform.position
	local targetEntityWorldPosition = self.eggRootTransform.position + currentCameraWorldPosition - targetCameraWorldPosition
	local targetLocalPosition = self.eggRootTransform:InverseTransformPoint(targetEntityWorldPosition)

	return targetLocalPosition, 1
end

function SoulEggEvolutionScene:applyIncubatePresentation(stage, entity)
	if not entity or not entity.eModel then
		return false
	end

	local targetLocalPosition, scale = self:getIncubatePresentationPosition(stage)

	entity.eModel:SetTransformLocalPosition(targetLocalPosition.x, targetLocalPosition.y, targetLocalPosition.z)
	entity.eModel:SetTransformLocalScale(scale, scale, scale)

	return true, targetLocalPosition, scale
end

function SoulEggEvolutionScene:resetCamera()
	self:_killCameraMoveTween()

	self._cameraPresentationLocalPosition = nil

	if IsNil(self.camera) then
		return
	end

	if self._cameraInitialLocalPosition then
		self.camera.transform.localPosition = self._cameraInitialLocalPosition
	end

	if self._cameraInitialLocalRotation then
		self.camera.transform.localRotation = self._cameraInitialLocalRotation
	end
end

function SoulEggEvolutionScene:resetPresentation()
	self._presentationToken = self._presentationToken + 1

	self:resetCamera()
	self:clearEffects()
	self:_destroyCubeEntityPool()
	self:removeSoulEggEntity()
	self:removePetEntity()
end

function SoulEggEvolutionScene:onDestroy()
	self:resetPresentation()

	self._presentationReady = false
	self._presentationErrorReason = "destroyed"

	pg.global.cameraMgr:SetUISceneCamera(nil)

	self.camera = nil
	self.globalTransform = nil
	self.catchBallRootTransform = nil
	self.eggRootTransform = nil
	self.objectReference = nil
	self._cameraInitialLocalPosition = nil
	self._cameraInitialLocalRotation = nil
	self._cameraPresentationLocalPosition = nil
end

return SoulEggEvolutionScene
