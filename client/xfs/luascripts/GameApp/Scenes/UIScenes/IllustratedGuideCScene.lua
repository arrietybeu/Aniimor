-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Scenes\\UIScenes\\IllustratedGuideCScene.lua

local ClientUtils = require("Utils.ClientUtils")
local Class = require("Core.Framework.Class")
local UISceneBase = require("GameApp.UIScene.UISceneBase")
local ClientSimpleVirtualEntity = require("Entities.ClientSimpleVirtualEntity")
local ClientConst = require("Const.ClientConst")
local RobEggCollectionDisplayModelUtils = require("Utils.RobEggCollectionDisplayModelUtils")
local ClientEffectUtils = require("Utils.ClientEffectUtils")
local RobEggCollectionDisplayEffectUtils = require("Utils.RobEggCollectionDisplayEffectUtils")
local Const = require("Common.Const.Const")
local TimerManager = require("Core.Timer.TimerManager")
local CollectItemData = require("Data.collect_item_data")
local RobEggBookCollectionData = require("Data.egg_book_Collection_data")
local Time = require("Core.Common.Time")
local EffectLevelSettingType = typeof(CS.FunPlus.WorldX.GameApp.Effect.EffectLevelSetting)
local MeshRendererType = typeof(CS.UnityEngine.MeshRenderer)
local SkinnedMeshRendererType = typeof(CS.UnityEngine.SkinnedMeshRenderer)
local ColliderType = typeof(CS.UnityEngine.Collider)
local DETAIL_MODEL_SCALE_MULTIPLIER = 2
local DETAIL_MODEL_CENTER_OFFSET_Y = 0.3
local DEFAULT_MIN_ZOOM = 0.7
local DEFAULT_MAX_ZOOM = 1.5
local MODEL_ROTATE_SPEED = 0.25
local MODEL_MAX_INERTIA_SPEED = 540
local MODEL_ROTATION_DECELERATION = 1200
local MODEL_ROTATION_STOP_SPEED = 2
local GAMEPAD_ROTATE_DELTA_PER_SECOND = 560
local GAMEPAD_ROTATE_DEAD_ZONE = 0.12
local GAMEPAD_ZOOM_SPEED = 0.8
local MOUSE_ZOOM_SPEED = 0.1
local TOUCH_ZOOM_SPEED = 0.002
local INITIAL_MODEL_ROTATION_Y = 270
local EFFECT_RETRY_MAX_COUNT = 30
local EFFECT_LOD_STABILIZE_COUNT = 5
local EFFECT_PLAY_DELAY_FRAME_COUNT = 2
local COMMON_MOUNT_EFFECT_REVEAL_TIMEOUT_FRAME_COUNT = 180
local PRESET_REAPPLY_FRAME_COUNTS = {
	2,
	6,
	12
}
local BOUNDS_REAPPLY_FRAME_COUNTS = {
	1,
	2,
	4,
	8,
	16,
	30
}
local TOUCH_PHASE_BEGAN = 0
local TOUCH_PHASE_MOVED = 1
local TOUCH_PHASE_STATIONARY = 2
local TOUCH_PHASE_ENDED = 3
local TOUCH_PHASE_CANCELED = 4
local IllustratedGuideCScene = Class.LightClass("IllustratedGuideCScene", UISceneBase)

function IllustratedGuideCScene:onCtor()
	self.sceneReady = false
	self.itemEntity = nil
	self.baseModelScale = 1
	self.baseModelScaleIsWorld = false
	self.currentZoom = 1
	self.minZoom = DEFAULT_MIN_ZOOM
	self.maxZoom = DEFAULT_MAX_ZOOM
	self.currentRotationX = 0
	self.currentRotationY = INITIAL_MODEL_ROTATION_Y
	self.currentRotationZ = 0
	self.modelPivotObject = nil
	self.modelPivotTransform = nil
	self.modelPivotInitialized = false
	self.defaultCameraPosition = nil
	self.defaultCameraOffset = nil
	self.isMobile = false
	self.lastMousePosition = nil
	self.lastTouchPosition = nil
	self.lastTouchFingerId = nil
	self.lastPinchDistance = nil
	self.rotationVelocity = CS.UnityEngine.Vector3.zero
	self.rotationPointerActive = false
	self.rotationInputAppliedThisFrame = false
	self.modelPivotRefreshVersion = 0
	self.gamepadRotateInput = CS.UnityEngine.Vector2.zero
	self.gamepadZoomInput = 0
end

function IllustratedGuideCScene:onStart(_param)
	self.rootTransform = self.scene.transform:Find("Global")
	self.objectReference = self.rootTransform:GetComponent("ObjectReference")
	self.camera = self.objectReference:GetRefValue("camera")
	self.itemParentTransform = self.objectReference:GetRefValue("petsParentTransform")

	if self.camera and self.itemParentTransform then
		self.defaultCameraPosition = self.camera.transform.position
		self.defaultCameraOffset = self.defaultCameraPosition - self.itemParentTransform.position
	end

	self.isMobile = pg.global.ui:runPlatformByMobile()
	self.sceneReady = true

	self:startTimer(function()
		self:onInteractionUpdate()
	end, 0, true)
end

function IllustratedGuideCScene:isReady()
	return self.sceneReady
end

function IllustratedGuideCScene:disableModelColliders(entity)
	local itemModel = entity and entity.eModel and entity.eModel.itemModel

	if IsNil(itemModel) then
		return false
	end

	local colliders = itemModel:GetComponentsInChildren(ColliderType, true)

	if not colliders then
		return false
	end

	for i = 0, colliders.Length - 1 do
		local collider = colliders[i]

		if NotNil(collider) then
			pcall(function()
				collider.enabled = false
			end)
		end
	end

	return colliders.Length > 0
end

function IllustratedGuideCScene:scheduleDisableModelColliders(entity)
	self:disableModelColliders(entity)

	for _, frameCount in ipairs(BOUNDS_REAPPLY_FRAME_COUNTS) do
		TimerManager.addSpecificFrameCb(frameCount, false, function()
			if self.itemEntity == entity then
				self:disableModelColliders(entity)
			end
		end)
	end
end

function IllustratedGuideCScene:disableItemEffectLod(entity)
	local itemModel = entity and entity.eModel and entity.eModel.itemModel

	if IsNil(itemModel) then
		return false
	end

	local effectLevelSettings = itemModel:GetComponentsInChildren(EffectLevelSettingType, true)

	if not effectLevelSettings then
		return false
	end

	for i = 0, effectLevelSettings.Length - 1 do
		local effectLevelSetting = effectLevelSettings[i]

		if NotNil(effectLevelSetting) then
			effectLevelSetting:IgnoreUnLoad()
			effectLevelSetting:SetEnableUpdate(false)
		end
	end

	return effectLevelSettings.Length > 0
end

function IllustratedGuideCScene:tryDisableItemEffectLod(entity, retryCount)
	if self.itemEntity ~= entity then
		return
	end

	retryCount = retryCount or 0

	local disabled = self:disableItemEffectLod(entity)

	if disabled and retryCount >= EFFECT_LOD_STABILIZE_COUNT then
		return
	end

	if retryCount >= EFFECT_RETRY_MAX_COUNT then
		return
	end

	TimerManager.addNextFrameCb(function()
		self:tryDisableItemEffectLod(entity, retryCount + 1)
	end)
end

function IllustratedGuideCScene:tryPlayDetailEffect(entity, effect, retryCount)
	if not effect or effect == "" then
		return
	end

	if self.itemEntity ~= entity or entity.detailEffectId then
		return
	end

	local effectId = entity:playEffect(effect, nil, true)

	if effectId and effectId ~= 0 then
		entity.detailEffectId = effectId

		return
	end

	retryCount = retryCount or 0

	if retryCount >= EFFECT_RETRY_MAX_COUNT then
		return
	end

	TimerManager.addNextFrameCb(function()
		self:tryPlayDetailEffect(entity, effect, retryCount + 1)
	end)
end

function IllustratedGuideCScene:schedulePlayDetailEffect(entity, effect)
	if not effect or effect == "" then
		return
	end

	TimerManager.addSpecificFrameCb(EFFECT_PLAY_DELAY_FRAME_COUNT, false, function()
		self:tryPlayDetailEffect(entity, effect)
	end)
end

function IllustratedGuideCScene:applyDetailCommonMountEffects(entity)
	if self.itemEntity ~= entity then
		return
	end

	local modelResId = entity.detailModelResId

	if not modelResId or modelResId == "" then
		return
	end

	if not RobEggCollectionDisplayEffectUtils.hasCommonMountEffects(modelResId) then
		return
	end

	entity.eModel:SetActive(false)

	local revealed = false

	local function revealModel()
		if revealed or self.itemEntity ~= entity then
			return
		end

		revealed = true

		if entity.eModel then
			entity.eModel:SetActive(true)
		end
	end

	TimerManager.addSpecificFrameCb(COMMON_MOUNT_EFFECT_REVEAL_TIMEOUT_FRAME_COUNT, false, revealModel)

	local effectStarted = RobEggCollectionDisplayEffectUtils.applyCommonMountEffects(entity, modelResId, revealModel)

	if not effectStarted then
		revealModel()
	end
end

function IllustratedGuideCScene:applyDetailPreset(entity, presetNames)
	if self.itemEntity ~= entity then
		return
	end

	local shaderView = entity.eModel and entity.eModel.shaderView

	if not shaderView or not presetNames then
		return
	end

	if type(presetNames) == "string" then
		ClientEffectUtils.PlayPreset(entity, presetNames, -1, false)
	elseif type(presetNames) == "table" then
		for _, presetName in pairs(presetNames) do
			ClientEffectUtils.PlayPreset(entity, presetName, -1, false)
		end
	end
end

function IllustratedGuideCScene:scheduleApplyDetailPreset(entity, presetNames)
	if not presetNames then
		return
	end

	for _, frameCount in ipairs(PRESET_REAPPLY_FRAME_COUNTS) do
		TimerManager.addSpecificFrameCb(EFFECT_PLAY_DELAY_FRAME_COUNT + frameCount, false, function()
			self:applyDetailPreset(entity, presetNames)
		end)
	end
end

function IllustratedGuideCScene:applyItemPresentation(entity, collectConfig)
	if self.itemEntity ~= entity then
		return
	end

	self:disableModelColliders(entity)
	self:tryDisableItemEffectLod(entity)

	if entity.detailPresentationApplied then
		return
	end

	entity.detailPresentationApplied = true

	self:applyDetailCommonMountEffects(entity)

	if not collectConfig then
		return
	end

	self:schedulePlayDetailEffect(entity, collectConfig.effect)
	self:applyDetailPreset(entity, collectConfig.PresetName)
	self:scheduleApplyDetailPreset(entity, collectConfig.PresetName)
end

function IllustratedGuideCScene:showItemModel(itemId, item, slotId, initialRotation, modelScale)
	if not itemId or not self.sceneReady or not self.itemParentTransform then
		return
	end

	self:destroyItemEntity()

	local displayModelData = RobEggCollectionDisplayModelUtils.getModelData(itemId)
	local modelResId = displayModelData and displayModelData.modelResId
	local templateId = displayModelData and displayModelData.inItemId
	local resolvedModelScale = modelScale or displayModelData and displayModelData.modelScale

	if not modelResId then
		return
	end

	local collectConfig = CollectItemData[templateId]
	local slotConfig = RobEggBookCollectionData[tonumber(slotId) or slotId]

	self.minZoom = slotConfig and slotConfig.minZoom or DEFAULT_MIN_ZOOM
	self.maxZoom = slotConfig and slotConfig.maxZoom or DEFAULT_MAX_ZOOM

	if self.minZoom > self.maxZoom then
		self.minZoom, self.maxZoom = self.maxZoom, self.minZoom
	end

	self.currentZoom = math.max(self.minZoom, math.min(self.maxZoom, 1))
	self.baseModelScale = resolvedModelScale or 1
	self.baseModelScaleIsWorld = type(modelScale) == "table"
	self.currentRotationX = initialRotation and initialRotation.x or 0
	self.currentRotationY = initialRotation and initialRotation.y or INITIAL_MODEL_ROTATION_Y
	self.currentRotationZ = initialRotation and initialRotation.z or 0

	self:resetInteractionState()
	self:createModelPivot()

	local entity = ClientSimpleVirtualEntity.new()

	function entity.onItemModelLoaded(loadedEntity)
		self:scheduleDisableModelColliders(loadedEntity)
		self:setupModelPivot(loadedEntity)
		self:scheduleRefreshModelPivot(loadedEntity)
		self:applyItemPresentation(loadedEntity, collectConfig)
	end

	entity:setConfigData({})

	local initInfo = {
		templateId = templateId
	}

	entity:init(initInfo)
	entity:postInit(initInfo)
	entity:start()
	entity:setModelLayer(ClientConst.LayerDefine.LAYER_UI_SCENE)
	entity:setDisableEffectLod(true)

	if not entity.eModel then
		ClientUtils.safeDestroy(entity)

		return
	end

	entity:addEModelComponent(Const.COMPONENT_IDX_ITEM)
	entity.eModel:SetTransformParent(self.modelPivotTransform or self.itemParentTransform, false)
	entity.eModel:SetTransformLocalPosition()

	entity.detailModelResId = modelResId
	entity.detailPlayCosItemId = displayModelData.playCosItemId
	entity.detailDisplayModelData = displayModelData
	self.itemEntity = entity

	self:applyModelRotation()
	self:applyModelScale()
	self:applyCameraZoom()
	entity.eModel:SetModelResId(Const.COMPONENT_IDX_ITEM, modelResId)
	entity.eModel:SetActive(true)
end

function IllustratedGuideCScene:resetInteractionState()
	self.lastMousePosition = nil
	self.lastTouchPosition = nil
	self.lastTouchFingerId = nil
	self.lastPinchDistance = nil
end

function IllustratedGuideCScene:resetRotationInertia()
	self.rotationVelocity = CS.UnityEngine.Vector3.zero
	self.rotationPointerActive = false
	self.rotationInputAppliedThisFrame = false
end

function IllustratedGuideCScene:getItemTransform()
	local entity = self.itemEntity

	return entity and entity.eModel and entity.eModel.transform or nil
end

function IllustratedGuideCScene:getRotationTransform()
	return self.modelPivotTransform or self:getItemTransform()
end

function IllustratedGuideCScene:createModelPivot()
	if not self.itemParentTransform then
		return
	end

	local pivotObject = CS.UnityEngine.GameObject("CollectionDetailModelPivot")
	local pivotTransform = pivotObject.transform

	pivotTransform:SetParent(self.itemParentTransform, false)

	pivotTransform.localPosition = CS.UnityEngine.Vector3.zero
	pivotTransform.localRotation = CS.UnityEngine.Quaternion.identity
	pivotTransform.localScale = CS.UnityEngine.Vector3.one
	self.modelPivotObject = pivotObject
	self.modelPivotTransform = pivotTransform
	self.modelPivotInitialized = false
end

function IllustratedGuideCScene:getRendererBoundsTransform(renderer)
	if not renderer or IsNil(renderer) then
		return nil
	end

	local ok, rootBone = pcall(function()
		return renderer.rootBone
	end)

	if ok and rootBone and NotNil(rootBone) then
		return rootBone
	end

	local rendererTransform = renderer.transform

	if rendererTransform and NotNil(rendererTransform) then
		return rendererTransform
	end

	return nil
end

function IllustratedGuideCScene:forEachRendererBoundsWorldCorner(renderer, callback)
	if not renderer or IsNil(renderer) or not renderer.enabled or not callback then
		return
	end

	local isActive = true

	pcall(function()
		isActive = renderer.gameObject.activeInHierarchy
	end)

	if not isActive then
		return
	end

	local bounds, boundsTransform
	local ok, localBounds = pcall(function()
		return renderer.localBounds
	end)
	local rendererBoundsTransform = self:getRendererBoundsTransform(renderer)

	if ok and localBounds and rendererBoundsTransform then
		bounds = localBounds
		boundsTransform = rendererBoundsTransform
	else
		bounds = renderer.bounds
	end

	if not bounds then
		return
	end

	local boundsMin = bounds.min
	local boundsMax = bounds.max

	for xIndex = 0, 1 do
		local x = xIndex == 0 and boundsMin.x or boundsMax.x

		for yIndex = 0, 1 do
			local y = yIndex == 0 and boundsMin.y or boundsMax.y

			for zIndex = 0, 1 do
				local z = zIndex == 0 and boundsMin.z or boundsMax.z
				local point = CS.UnityEngine.Vector3(x, y, z)

				if boundsTransform then
					point = boundsTransform:TransformPoint(point)
				end

				callback(point)
			end
		end
	end
end

function IllustratedGuideCScene:expandLocalBoundsByRenderers(modelTransform, renderers, boundsData)
	if not renderers then
		return boundsData
	end

	for i = 0, renderers.Length - 1 do
		local renderer = renderers[i]

		self:forEachRendererBoundsWorldCorner(renderer, function(worldPoint)
			local localPoint = modelTransform:InverseTransformPoint(worldPoint)

			if not boundsData then
				boundsData = {
					minX = localPoint.x,
					minY = localPoint.y,
					minZ = localPoint.z,
					maxX = localPoint.x,
					maxY = localPoint.y,
					maxZ = localPoint.z
				}
			else
				boundsData.minX = math.min(boundsData.minX, localPoint.x)
				boundsData.minY = math.min(boundsData.minY, localPoint.y)
				boundsData.minZ = math.min(boundsData.minZ, localPoint.z)
				boundsData.maxX = math.max(boundsData.maxX, localPoint.x)
				boundsData.maxY = math.max(boundsData.maxY, localPoint.y)
				boundsData.maxZ = math.max(boundsData.maxZ, localPoint.z)
			end
		end)
	end

	return boundsData
end

function IllustratedGuideCScene:isBoundsSizeValid(size)
	if not size then
		return false
	end

	local maxReasonableSize = 20

	return size.x == size.x and size.y == size.y and size.z == size.z and size.x > 0.001 and size.y > 0.001 and size.z > 0.001 and maxReasonableSize > size.x and maxReasonableSize > size.y and maxReasonableSize > size.z
end

function IllustratedGuideCScene:getModelLocalBounds(entity)
	local eModel = entity and entity.eModel
	local modelTransform = eModel and eModel.transform
	local itemModel = eModel and eModel.itemModel

	if not modelTransform or IsNil(itemModel) then
		return nil, nil
	end

	local boundsData = self:expandLocalBoundsByRenderers(modelTransform, itemModel:GetComponentsInChildren(MeshRendererType, true))

	boundsData = self:expandLocalBoundsByRenderers(modelTransform, itemModel:GetComponentsInChildren(SkinnedMeshRendererType, true), boundsData)

	if not boundsData then
		return nil, nil
	end

	local center = CS.UnityEngine.Vector3((boundsData.minX + boundsData.maxX) * 0.5, (boundsData.minY + boundsData.maxY) * 0.5, (boundsData.minZ + boundsData.maxZ) * 0.5)
	local size = CS.UnityEngine.Vector3(math.max(boundsData.maxX - boundsData.minX, 0.01), math.max(boundsData.maxY - boundsData.minY, 0.01), math.max(boundsData.maxZ - boundsData.minZ, 0.01))

	if not self:isBoundsSizeValid(size) then
		return nil, nil
	end

	return center, size
end

function IllustratedGuideCScene:getModelPivotTargetPosition()
	if not self.itemParentTransform then
		return nil
	end

	return self.itemParentTransform.position + CS.UnityEngine.Vector3(0, DETAIL_MODEL_CENTER_OFFSET_Y, 0)
end

function IllustratedGuideCScene:refreshModelPivotFromBounds(entity)
	if self.itemEntity ~= entity or not self.modelPivotTransform then
		return
	end

	local itemTransform = self:getItemTransform()
	local center = self:getModelLocalBounds(entity)
	local targetPosition = self:getModelPivotTargetPosition()

	if not itemTransform or not center or not targetPosition then
		return
	end

	local boundsCenterWorld = itemTransform:TransformPoint(center)

	itemTransform:SetParent(self.itemParentTransform, true)

	self.modelPivotTransform.position = boundsCenterWorld

	itemTransform:SetParent(self.modelPivotTransform, true)

	self.modelPivotTransform.position = targetPosition
	self.modelPivotInitialized = true

	self:applyModelScale()

	if self.defaultCameraPosition then
		self.defaultCameraOffset = self.defaultCameraPosition - self.modelPivotTransform.position

		self:applyCameraZoom()
	end
end

function IllustratedGuideCScene:setupModelPivot(entity)
	if self.modelPivotInitialized then
		return
	end

	self:refreshModelPivotFromBounds(entity)
end

function IllustratedGuideCScene:scheduleRefreshModelPivot(entity)
	self.modelPivotRefreshVersion = (self.modelPivotRefreshVersion or 0) + 1

	local refreshVersion = self.modelPivotRefreshVersion

	for _, frameCount in ipairs(BOUNDS_REAPPLY_FRAME_COUNTS) do
		TimerManager.addSpecificFrameCb(frameCount, false, function()
			if self.modelPivotRefreshVersion ~= refreshVersion then
				return
			end

			self:refreshModelPivotFromBounds(entity)
		end)
	end
end

function IllustratedGuideCScene:applyModelScale()
	local itemTransform = self:getItemTransform()

	if not itemTransform then
		return
	end

	if not self.baseModelScaleIsWorld then
		itemTransform.localScale = CS.UnityEngine.Vector3.one * self.baseModelScale * DETAIL_MODEL_SCALE_MULTIPLIER

		return
	end

	local worldScale = self.baseModelScale
	local worldScaleX = (worldScale.x or 1) * DETAIL_MODEL_SCALE_MULTIPLIER
	local worldScaleY = (worldScale.y or worldScale.x or 1) * DETAIL_MODEL_SCALE_MULTIPLIER
	local worldScaleZ = (worldScale.z or worldScale.x or 1) * DETAIL_MODEL_SCALE_MULTIPLIER
	local parentTransform = itemTransform.parent
	local parentWorldScale = parentTransform and parentTransform.lossyScale or CS.UnityEngine.Vector3.one
	local parentScaleX = math.max(math.abs(parentWorldScale.x), 0.0001)
	local parentScaleY = math.max(math.abs(parentWorldScale.y), 0.0001)
	local parentScaleZ = math.max(math.abs(parentWorldScale.z), 0.0001)

	itemTransform.localScale = CS.UnityEngine.Vector3(worldScaleX / parentScaleX, worldScaleY / parentScaleY, worldScaleZ / parentScaleZ)
end

function IllustratedGuideCScene:applyCameraZoom()
	if not self.camera or not self.itemParentTransform or not self.defaultCameraOffset then
		return
	end

	local zoomTargetPosition = self.modelPivotInitialized and self.modelPivotTransform.position or self.itemParentTransform.position

	self.camera.transform.position = zoomTargetPosition + self.defaultCameraOffset * (1 / self.currentZoom)
end

function IllustratedGuideCScene:setZoom(zoom)
	self.currentZoom = math.max(self.minZoom, math.min(self.maxZoom, zoom))

	self:applyCameraZoom()
end

function IllustratedGuideCScene:addZoom(delta)
	if delta ~= 0 then
		self:setZoom(self.currentZoom + delta)
	end
end

function IllustratedGuideCScene:setGamepadRotateInput(inputVec)
	if not inputVec then
		self.gamepadRotateInput = CS.UnityEngine.Vector2.zero

		return
	end

	local x = inputVec.x or 0
	local y = inputVec.y or 0

	if x * x + y * y < GAMEPAD_ROTATE_DEAD_ZONE * GAMEPAD_ROTATE_DEAD_ZONE then
		self.gamepadRotateInput = CS.UnityEngine.Vector2.zero

		return
	end

	self.gamepadRotateInput = CS.UnityEngine.Vector2(x, y)
end

function IllustratedGuideCScene:setGamepadZoomInput(zoomInput)
	self.gamepadZoomInput = zoomInput or 0
end

function IllustratedGuideCScene:resetGamepadInput()
	self.gamepadRotateInput = CS.UnityEngine.Vector2.zero
	self.gamepadZoomInput = 0
end

function IllustratedGuideCScene:applyModelRotation()
	local rotationTransform = self:getRotationTransform()

	if not rotationTransform then
		return
	end

	rotationTransform.rotation = CS.UnityEngine.Quaternion.Euler(self.currentRotationX, self.currentRotationY, self.currentRotationZ)
end

function IllustratedGuideCScene:applyWorldRotation(rotationAxis, angle)
	local rotationTransform = self:getRotationTransform()

	if not rotationTransform or not rotationAxis or angle == 0 then
		return
	end

	rotationTransform:RotateAround(rotationTransform.position, rotationAxis, angle)
end

function IllustratedGuideCScene:rotateModel(deltaX, deltaY)
	deltaX = deltaX or 0
	deltaY = deltaY or 0

	local rotationTransform = self:getRotationTransform()
	local cameraTransform = self.camera and self.camera.transform

	if not rotationTransform or not cameraTransform or deltaX == 0 and deltaY == 0 then
		return
	end

	local dragDistance = math.sqrt(deltaX * deltaX + deltaY * deltaY)
	local rotationAxis = cameraTransform.right * deltaY - cameraTransform.up * deltaX

	rotationAxis = rotationAxis.normalized

	local rotationAngle = dragDistance * MODEL_ROTATE_SPEED

	self:applyWorldRotation(rotationAxis, rotationAngle)

	local deltaTime = Time.unscaledDeltaTime

	if deltaTime and deltaTime > 0 then
		local inertiaSpeed = math.min(rotationAngle / deltaTime, MODEL_MAX_INERTIA_SPEED)

		self.rotationVelocity = rotationAxis * inertiaSpeed
	end

	self.rotationInputAppliedThisFrame = true
end

function IllustratedGuideCScene:onGamepadInteractionUpdate(deltaTime)
	if not deltaTime or deltaTime <= 0 then
		return
	end

	local rotateInput = self.gamepadRotateInput
	local rotateX = rotateInput and rotateInput.x or 0
	local rotateY = rotateInput and rotateInput.y or 0

	if rotateX * rotateX + rotateY * rotateY > GAMEPAD_ROTATE_DEAD_ZONE * GAMEPAD_ROTATE_DEAD_ZONE then
		self.rotationPointerActive = true

		self:rotateModel(rotateX * GAMEPAD_ROTATE_DELTA_PER_SECOND * deltaTime, rotateY * GAMEPAD_ROTATE_DELTA_PER_SECOND * deltaTime)
	end

	local zoomInput = self.gamepadZoomInput or 0

	if zoomInput ~= 0 then
		self:addZoom(zoomInput * GAMEPAD_ZOOM_SPEED * deltaTime)
	end
end

function IllustratedGuideCScene:updateRotationInertia(deltaTime)
	if not deltaTime or deltaTime <= 0 then
		return
	end

	local speed = self.rotationVelocity.magnitude

	if speed <= MODEL_ROTATION_STOP_SPEED then
		self.rotationVelocity = CS.UnityEngine.Vector3.zero

		return
	end

	local rotationAxis = self.rotationVelocity.normalized

	if not self.rotationPointerActive then
		self:applyWorldRotation(rotationAxis, speed * deltaTime)
	elseif self.rotationInputAppliedThisFrame then
		return
	end

	local nextSpeed = math.max(0, speed - MODEL_ROTATION_DECELERATION * deltaTime)

	self.rotationVelocity = rotationAxis * nextSpeed
end

function IllustratedGuideCScene:onMouseInteractionUpdate(inputMgr)
	local scrollDelta = inputMgr:GetMouseScrollDelta()

	if scrollDelta ~= 0 then
		self:addZoom(scrollDelta * MOUSE_ZOOM_SPEED)
	end

	local mousePosition = UnityInput.mousePosition

	if inputMgr:GetMouseButtonDown(0) then
		self:resetRotationInertia()

		self.rotationPointerActive = true
		self.lastMousePosition = mousePosition

		return
	end

	if inputMgr:GetMouseButtonUp(0) then
		self.lastMousePosition = nil

		return
	end

	if not inputMgr:GetMouseButton(0) then
		self.lastMousePosition = nil

		return
	end

	self.rotationPointerActive = true

	if self.lastMousePosition then
		self:rotateModel(mousePosition.x - self.lastMousePosition.x, mousePosition.y - self.lastMousePosition.y)
	end

	self.lastMousePosition = mousePosition
end

function IllustratedGuideCScene:getTouchInfo(inputMgr, index)
	local fingerId = inputMgr:GetTouchFingerId(index)

	if fingerId < 0 then
		return nil
	end

	return {
		fingerId = fingerId,
		phase = inputMgr:GetTouchPhase(index),
		position = inputMgr:GetTouchPosition(index)
	}
end

function IllustratedGuideCScene:onSingleTouchUpdate(touch)
	self.lastPinchDistance = nil

	if touch.phase == TOUCH_PHASE_BEGAN or self.lastTouchFingerId ~= touch.fingerId then
		self:resetRotationInertia()

		self.rotationPointerActive = true
		self.lastTouchPosition = touch.position
		self.lastTouchFingerId = touch.fingerId

		return
	end

	if touch.phase == TOUCH_PHASE_MOVED or touch.phase == TOUCH_PHASE_STATIONARY then
		self.rotationPointerActive = true

		if self.lastTouchPosition then
			self:rotateModel(touch.position.x - self.lastTouchPosition.x, touch.position.y - self.lastTouchPosition.y)
		end

		self.lastTouchPosition = touch.position

		return
	end

	if touch.phase == TOUCH_PHASE_ENDED or touch.phase == TOUCH_PHASE_CANCELED then
		self.rotationPointerActive = false
		self.lastTouchPosition = nil
		self.lastTouchFingerId = nil
	end
end

function IllustratedGuideCScene:onPinchUpdate(firstTouch, secondTouch)
	self.lastTouchPosition = nil
	self.lastTouchFingerId = nil

	local deltaX = firstTouch.position.x - secondTouch.position.x
	local deltaY = firstTouch.position.y - secondTouch.position.y
	local pinchDistance = math.sqrt(deltaX * deltaX + deltaY * deltaY)

	if self.lastPinchDistance then
		self:addZoom((pinchDistance - self.lastPinchDistance) * TOUCH_ZOOM_SPEED)
	end

	self.lastPinchDistance = pinchDistance
end

function IllustratedGuideCScene:onTouchInteractionUpdate(inputMgr)
	local touchCount = inputMgr:GetTouchCount()

	if touchCount == 2 then
		self:resetRotationInertia()

		local firstTouch = self:getTouchInfo(inputMgr, 0)
		local secondTouch = self:getTouchInfo(inputMgr, 1)

		if firstTouch and secondTouch then
			self:onPinchUpdate(firstTouch, secondTouch)
		else
			self:resetInteractionState()
		end

		return
	end

	if touchCount > 2 then
		self:resetRotationInertia()
		self:resetInteractionState()

		return
	end

	if touchCount == 1 then
		local touch = self:getTouchInfo(inputMgr, 0)

		if touch then
			self:onSingleTouchUpdate(touch)
		else
			self:resetInteractionState()
		end

		return
	end

	self:resetInteractionState()
end

function IllustratedGuideCScene:onInteractionUpdate()
	if not self.enable or not self:getItemTransform() then
		self:resetInteractionState()
		self:resetRotationInertia()

		return
	end

	local inputMgr = pg and pg.global and pg.global.inputMgr

	if not inputMgr then
		self:resetRotationInertia()

		return
	end

	self.rotationPointerActive = false
	self.rotationInputAppliedThisFrame = false

	if self.isMobile then
		self:onTouchInteractionUpdate(inputMgr)
	else
		self:onMouseInteractionUpdate(inputMgr)
	end

	local deltaTime = Time.unscaledDeltaTime

	self:onGamepadInteractionUpdate(deltaTime)
	self:updateRotationInertia(deltaTime)
end

function IllustratedGuideCScene:destroyItemEntity()
	self.modelPivotRefreshVersion = (self.modelPivotRefreshVersion or 0) + 1

	if self.itemEntity then
		RobEggCollectionDisplayEffectUtils.clearCommonMountEffects(self.itemEntity)
		ClientUtils.safeDestroy(self.itemEntity)

		self.itemEntity = nil
	end

	if self.modelPivotObject and NotNil(self.modelPivotObject) then
		CS.UnityEngine.Object.Destroy(self.modelPivotObject)
	end

	self.modelPivotObject = nil
	self.modelPivotTransform = nil
	self.modelPivotInitialized = false

	if self.camera and self.defaultCameraPosition then
		self.camera.transform.position = self.defaultCameraPosition
	end

	if self.defaultCameraPosition and self.itemParentTransform then
		self.defaultCameraOffset = self.defaultCameraPosition - self.itemParentTransform.position
	end

	self:resetInteractionState()
	self:resetRotationInertia()
	self:resetGamepadInput()
end

function IllustratedGuideCScene:onDestroy()
	self:destroyItemEntity()

	self.sceneReady = false
	self.defaultCameraPosition = nil
	self.defaultCameraOffset = nil
	self.itemParentTransform = nil
end

return IllustratedGuideCScene
