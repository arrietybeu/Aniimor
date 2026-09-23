-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Scenes\\UIScenes\\CalcinationScene.lua

local ClientUtils = require("Utils.ClientUtils")
local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local UISceneBase = require("GameApp.UIScene.UISceneBase")
local ClientSimpleVirtualEntity = require("Entities.ClientSimpleVirtualEntity")
local ClientConst = require("Const.ClientConst")
local RobEggCollectionVisualUtils = require("Utils.RobEggCollectionVisualUtils")
local Const = require("Common.Const.Const")
local LuaUIUtils = require("Utils.LuaUIUtils")
local DoTweenAnimMgr = DoTweenAnimMgr
local EffectLevelSettingType = typeof(CS.FunPlus.WorldX.GameApp.Effect.EffectLevelSetting)
local CALCINATION_CAMERA_TWEEN_ID = LuaUIUtils.TweenId("calcinationPerformanceCamera")
local CALCINATION_CAMERA_ROTATE_TWEEN_ID = LuaUIUtils.TweenId("calcinationPerformanceCameraRotate")
local CalcinationScene = Class.LightClass("CalcinationScene", UISceneBase)

function CalcinationScene:onCtor()
	self.sceneReady = false
	self.entPool = {}
	self.currentItemId = nil
end

function CalcinationScene:onStart(param)
	self.rootTransform = self.scene.transform:Find("Global")
	self.objectReference = self.rootTransform:GetComponent("ObjectReference")
	self.camera = self.objectReference:GetRefValue("camera")
	self.itemParentTransform = self.objectReference:GetRefValue("petsParentTransform")
	self.mirrorParentTransform = self.objectReference:GetRefValue("mirrorPetsParentTransform")
	self.sceneReady = true
end

function CalcinationScene:isReady()
	return self.sceneReady
end

function CalcinationScene:startCalcinationPerformance(fovScale, duration)
	if not self.sceneReady or IsNil(self.camera) then
		return
	end

	self:stopCalcinationPerformance(0, true)

	self.calcinationDefaultCameraFov = self.camera.fieldOfView

	local cameraTransform = self.camera.transform
	local defaultRotation = cameraTransform.rotation

	self.calcinationDefaultCameraRotation = Quaternion(defaultRotation.x, defaultRotation.y, defaultRotation.z, defaultRotation.w)

	local focusPosition = NotNil(self.itemParentTransform) and self.itemParentTransform.position or nil

	if focusPosition then
		local targetRotation = Quaternion.LookRotation(focusPosition - cameraTransform.position, Vector3.up)
		local fromRotation = self.calcinationDefaultCameraRotation

		DoTweenAnimMgr.DoFloat(self.camera.gameObject, 0, 1, CALCINATION_CAMERA_ROTATE_TWEEN_ID, duration or 0, 0, CS.DG.Tweening.Ease.__CastFrom(6), nil, function(value)
			if self.sceneReady and NotNil(self.camera) then
				cameraTransform.rotation = Quaternion.Slerp(fromRotation, targetRotation, value)
			end
		end, nil, false)
	end

	local fromFov = self.calcinationDefaultCameraFov
	local targetFov = math.max(1, fromFov * (fovScale or 1))

	DoTweenAnimMgr.DoFloat(self.camera.gameObject, fromFov, targetFov, CALCINATION_CAMERA_TWEEN_ID, duration or 0, 0, CS.DG.Tweening.Ease.__CastFrom(6), nil, function(value)
		if self.sceneReady and NotNil(self.camera) then
			self.camera.fieldOfView = value
		end
	end, nil, false)
end

function CalcinationScene:playCalcinationPerformanceEffect(tagData, isStrong)
	return
end

function CalcinationScene:stopCalcinationPerformanceEffect()
	return
end

function CalcinationScene:stopCalcinationPerformance(duration, immediate)
	self:stopCalcinationPerformanceEffect()

	if IsNil(self.camera) then
		self.calcinationDefaultCameraFov = nil
		self.calcinationDefaultCameraRotation = nil

		return
	end

	DoTweenAnimMgr.Kill(self.camera.gameObject, CALCINATION_CAMERA_TWEEN_ID, false)
	DoTweenAnimMgr.Kill(self.camera.gameObject, CALCINATION_CAMERA_ROTATE_TWEEN_ID, false)

	local defaultFov = self.calcinationDefaultCameraFov
	local defaultRotation = self.calcinationDefaultCameraRotation

	if not defaultFov and not defaultRotation then
		return
	end

	if immediate or not duration or duration <= 0 then
		if defaultFov then
			self.camera.fieldOfView = defaultFov
		end

		if defaultRotation then
			self.camera.transform.rotation = defaultRotation
		end

		self.calcinationDefaultCameraFov = nil
		self.calcinationDefaultCameraRotation = nil

		return
	end

	if defaultFov then
		local fromFov = self.camera.fieldOfView

		DoTweenAnimMgr.DoFloat(self.camera.gameObject, fromFov, defaultFov, CALCINATION_CAMERA_TWEEN_ID, duration, 0, CS.DG.Tweening.Ease.__CastFrom(6), function()
			if self.sceneReady and NotNil(self.camera) then
				self.camera.fieldOfView = defaultFov
			end

			if self.calcinationDefaultCameraFov == defaultFov then
				self.calcinationDefaultCameraFov = nil
			end
		end, function(value)
			if self.sceneReady and NotNil(self.camera) then
				self.camera.fieldOfView = value
			end
		end, nil, false)
	end

	if defaultRotation then
		local cameraTransform = self.camera.transform
		local currentRotation = cameraTransform.rotation
		local fromRotation = Quaternion(currentRotation.x, currentRotation.y, currentRotation.z, currentRotation.w)

		DoTweenAnimMgr.DoFloat(self.camera.gameObject, 0, 1, CALCINATION_CAMERA_ROTATE_TWEEN_ID, duration, 0, CS.DG.Tweening.Ease.__CastFrom(6), function()
			if self.sceneReady and NotNil(self.camera) then
				cameraTransform.rotation = defaultRotation
			end

			if self.calcinationDefaultCameraRotation == defaultRotation then
				self.calcinationDefaultCameraRotation = nil
			end
		end, function(value)
			if self.sceneReady and NotNil(self.camera) then
				cameraTransform.rotation = Quaternion.Slerp(fromRotation, defaultRotation, value)
			end
		end, nil, false)
	end
end

function CalcinationScene:disableItemEffectLod(entity)
	local itemModel = entity and entity.eModel and entity.eModel.itemModel

	if IsNil(itemModel) then
		return
	end

	local effectLevelSettings = itemModel:GetComponentsInChildren(EffectLevelSettingType, true)

	if not effectLevelSettings then
		return
	end

	for i = 0, effectLevelSettings.Length - 1 do
		local effectLevelSetting = effectLevelSettings[i]

		if NotNil(effectLevelSetting) then
			effectLevelSetting:IgnoreUnLoad()
			effectLevelSetting:SetEnableUpdate(false)
		end
	end
end

function CalcinationScene:showItemModel(itemId, item, nextAffixData)
	if not itemId or not self.sceneReady then
		return
	end

	if self.currentItemId and self.entPool[self.currentItemId] then
		local ent = self.entPool[self.currentItemId]

		if ent.eModel then
			ent.eModel:SetActive(false)
		end
	end

	local visualData = RobEggCollectionVisualUtils.getVisualData(item or itemId, nextAffixData)
	local modelResId = visualData.modelResId
	local modelScale = visualData.modelScale
	local variantModelId = visualData.variantModelId
	local itemParameter = visualData.itemParameter
	local itemGenID = item and item.genID
	local pooledEntity = self.entPool[itemId]

	if pooledEntity and itemGenID and pooledEntity.calcinationItemGenID == itemGenID and pooledEntity.calcinationVariantModelId and not variantModelId then
		modelResId = pooledEntity.calcinationModelResId
		modelScale = pooledEntity.calcinationModelScale or modelScale
		variantModelId = pooledEntity.calcinationVariantModelId
		visualData.modelResId = modelResId
		visualData.modelScale = modelScale
		visualData.variantModelId = variantModelId
	end

	if pooledEntity and pooledEntity.calcinationModelResId ~= modelResId then
		self:removeEntity(itemId)
	end

	local entity, isNew = self:getOrCreateItemEntity(itemId)

	if entity and entity.eModel then
		entity.calcinationVisualData = visualData

		if isNew then
			self:loadItemModel(entity, modelResId, modelScale, variantModelId, itemGenID, itemParameter)
		else
			self:applyItemDisplayTransform(entity, modelScale, itemParameter)
			entity.eModel:SetActive(true)
			RobEggCollectionVisualUtils.refreshEntity(entity, entity.calcinationVisualData, nil, true)
			self:disableItemEffectLod(entity)

			entity.calcinationVariantModelId = variantModelId
			entity.calcinationItemGenID = itemGenID
		end

		self.currentItemId = itemId
	end
end

function CalcinationScene:loadItemModel(entity, modelResId, modelScale, variantModelId, itemGenID, itemParameter)
	if not entity or not entity.eModel then
		return
	end

	if not modelResId then
		return
	end

	if entity.eModel then
		entity.eModel:SetModelResId(Const.COMPONENT_IDX_ITEM, modelResId)
		self:applyItemDisplayTransform(entity, modelScale, itemParameter)

		entity.calcinationModelResId = modelResId
		entity.calcinationModelScale = modelScale
		entity.calcinationVariantModelId = variantModelId
		entity.calcinationItemGenID = itemGenID

		entity.eModel:SetActive(true)
	end
end

function CalcinationScene:applyItemDisplayTransform(entity, modelScale, itemParameter)
	if not entity or not entity.eModel then
		return
	end

	entity.eModel:SetTransformParent(self.itemParentTransform, false)

	if itemParameter then
		entity.eModel:SetTransformLocalPosition(itemParameter[1] or 0, itemParameter[2] or 0, itemParameter[3] or 0)
		entity.eModel:SetTransformLocalEulerAngle(itemParameter[4] or 0, itemParameter[5] or 0, itemParameter[6] or 0)
	else
		entity.eModel:SetTransformLocalPosition()
		entity.eModel:SetTransformLocalEulerAngle(0, 90, 0)
	end

	modelScale = modelScale or 1

	entity.eModel:SetTransformLocalScale(modelScale, modelScale, modelScale)
end

function CalcinationScene:getOrCreateItemEntity(itemId)
	if self.entPool[itemId] then
		return self.entPool[itemId], false
	end

	local entity = ClientSimpleVirtualEntity.new()

	function entity.onItemModelLoaded(loadedEntity)
		RobEggCollectionVisualUtils.refreshEntity(loadedEntity, loadedEntity.calcinationVisualData, nil, true)
		self:disableItemEffectLod(loadedEntity)
	end

	local configData = {}

	entity:setConfigData(configData)

	local initInfo = {
		templateId = itemId
	}

	entity:init(initInfo)
	entity:postInit(initInfo)
	entity:start()
	entity:setModelLayer(ClientConst.LayerDefine.LAYER_UI_SCENE)
	entity:setDisableEffectLod(true)

	if entity.eModel then
		entity:addEModelComponent(Const.COMPONENT_IDX_ITEM)
	end

	self.entPool[itemId] = entity

	return entity, true
end

function CalcinationScene:removeEntity(itemId)
	local entity = self.entPool[itemId]

	if entity then
		ClientUtils.safeDestroy(entity)

		self.entPool[itemId] = nil
	end

	if self.currentItemId == itemId then
		self.currentItemId = nil
	end
end

function CalcinationScene:hideCurrentModel()
	if self.currentItemId and self.entPool[self.currentItemId] then
		local ent = self.entPool[self.currentItemId]

		if ent.eModel then
			ent.eModel:SetActive(false)
		end
	end

	self.currentItemId = nil
end

function CalcinationScene:onDestroy()
	self:stopCalcinationPerformance(0, true)
	self:destroyAllItemEntity()

	self.sceneReady = false
end

function CalcinationScene:destroyAllItemEntity()
	for itemId, entity in pairs(self.entPool or EMPTY_TABLE) do
		ClientUtils.safeDestroy(entity)
	end

	self.entPool = {}
	self.currentItemId = nil
end

return CalcinationScene
