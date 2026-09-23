-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GrabEggsCollection\\Component\\CollectionModelComponent.lua

local ClientUtils = require("Utils.ClientUtils")
local Class = require("Core.Framework.Class")
local RobEggBookCollectionData = require("Data.egg_book_Collection_data")
local CollectItemData = require("Data.collect_item_data")
local RobEggItemOut = require("Data.rob_egg_item_out")
local LuaUIUtils = require("Utils.LuaUIUtils")
local DoTweenAnimMgr = DoTweenAnimMgr
local TimerManager = require("Core.Timer.TimerManager")
local ClientSimpleVirtualEntity = require("Entities.ClientSimpleVirtualEntity")
local ClientConst = require("Const.ClientConst")
local Const = require("Common.Const.Const")
local ClientTextUtils = require("Utils.ClientTextUtils")
local RobEggCollectionDisplayModelUtils = require("Utils.RobEggCollectionDisplayModelUtils")
local ClientEffectUtils = require("Utils.ClientEffectUtils")
local RobEggCollectionDisplayEffectUtils = require("Utils.RobEggCollectionDisplayEffectUtils")
local UIConst = require("Const.UIConst")
local CollectionModelComponent = Class.LightClass("CollectionModelComponent")
local BASE_CASE_ID = 1001
local STAGE_NORMAL = 0
local HOVER_SCALE = 1.05
local SCALE_DURATION = 0.2
local CAMERA_MOVE_DURATION = 0.5
local CAMERA_FOCUS_OFFSET = Vector3(0, 0.5, 3)
local CAMERA_REPLACE_HORIZONTAL_OFFSET = -0.3
local CAMERA_FOCUS_OFFSET_OVERRIDES = {
	[100102] = {
		y = 0.3
	},
	[100103] = {
		y = 0.3
	},
	[100106] = {
		y = 0.3
	}
}
local MODEL_LOCAL_POSITION_OFFSET = Vector3(0, 0.01, 0)
local HOVER_UPDATE_INTERVAL = 0.1
local EFFECT_RETRY_MAX_COUNT = 30
local EFFECT_LOD_STABILIZE_COUNT = 5
local EFFECT_PLAY_DELAY_FRAME_COUNT = 2
local EFFECT_PLAY_STAGGER_FRAME_COUNT = 6
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
local COLLECTION_CLICK_WIDTH = 0.3
local COLLECTION_CLICK_HEIGHT = 0.4
local COLLECTION_CLICK_DEPTH = 0.3
local COLLECTION_BOUNDS_SIZE_SCALE_OVERRIDES = {
	[100103] = {
		y = 0.8,
		z = 0.8,
		x = 0.8
	}
}
local PLACE_TIP_PREFAB = "$UI_Node_GrabEggs_Collection_Placed.prefab"
local PLACE_TIP_WORLD_OFFSET = Vector3(0, 0, 0)
local PLACE_TIP_LOCAL_Y_OFFSET_OVERRIDES = {
	[100102] = 80
}
local SHOWCASE_APPEAR_EFFECT = "Eff_Env_GrabEggBattle_Collection_Showcase_Appear"
local CLICK_CANCEL_MOVE_DISTANCE = 20
local CLICK_CANCEL_MOVE_DISTANCE_SQR = CLICK_CANCEL_MOVE_DISTANCE * CLICK_CANCEL_MOVE_DISTANCE
local TOUCH_PHASE_BEGAN = 0
local TOUCH_PHASE_MOVED = 1
local TOUCH_PHASE_STATIONARY = 2
local TOUCH_PHASE_ENDED = 3
local TOUCH_PHASE_CANCELED = 4
local EffectLevelSettingType = typeof(CS.FunPlus.WorldX.GameApp.Effect.EffectLevelSetting)
local MeshRendererType = typeof(CS.UnityEngine.MeshRenderer)
local SkinnedMeshRendererType = typeof(CS.UnityEngine.SkinnedMeshRenderer)
local MeshColliderType = typeof(CS.UnityEngine.MeshCollider)
local ParticleSystemRendererType = typeof(CS.UnityEngine.ParticleSystemRenderer)

function CollectionModelComponent:ctor(scene, ctrl)
	self.scene = scene
	self.ctrl = ctrl
	self.slotModels = {}
	self.slotEntities = {}
	self.propsRoot = nil
	self.hoveredSlot = nil
	self.clickedSlot = nil
	self.originalScale = {}
	self.pressedSlot = nil
	self.pressedPointerId = nil
	self.pressedPointerSource = nil
	self.pressedPointerPosition = nil
	self.pressedPointerLatestPosition = nil
	self.pointerClickCanceled = false
	self.clickUpdateTimer = nil
	self.hoverUpdateTimer = nil
	self.interactionEnabled = true
	self.panelRedDot = nil
	self.placeTipMarkers = {}
	self.placeTipLoading = {}
	self.defaultCameraLocalPosition = nil
	self.defaultCameraLocalRotation = nil
	self.isMobile = pg.global.ui:runPlatformByMobile()
end

function CollectionModelComponent:init()
	if not self.scene or not self.scene:isReady() then
		return
	end

	if self.scene.rootTransform then
		self.propsRoot = self.scene.rootTransform:Find("Props")
	end

	if self.ctrl and self.ctrl.view then
		self.panelRedDot = self.ctrl.view.panelRedDot
	end

	self:cacheDefaultCameraTransform()
	self:startInputMonitoring()
end

function CollectionModelComponent:cacheDefaultCameraTransform()
	if not self.scene or not self.scene.camera then
		return
	end

	local cameraTransform = self.scene.camera.transform

	if not cameraTransform or UIUtils.IsNull(cameraTransform) then
		return
	end

	self.defaultCameraLocalPosition = cameraTransform.localPosition
	self.defaultCameraLocalRotation = cameraTransform.localRotation
end

function CollectionModelComponent:initSlots()
	if not self.propsRoot then
		return
	end

	for slotId, slotConfig in pairs(RobEggBookCollectionData) do
		if slotConfig.collectGroup == BASE_CASE_ID and slotConfig.location then
			local slotTransform = self:getSlotMountPoint(slotConfig)

			if slotTransform then
				self:refreshSlot(slotId, slotConfig, slotTransform)
			end
		end
	end

	self:refreshSlotLights()
	self:refreshSlotEffLights()
end

function CollectionModelComponent:getSlotMountPoint(slotConfig)
	if not self.propsRoot or not slotConfig or not slotConfig.location then
		return nil
	end

	local slotTransform = self.propsRoot:Find(slotConfig.location)

	if not slotTransform then
		return nil
	end

	local mountPoint = slotTransform:Find("Transform_" .. slotConfig.location)

	return mountPoint or slotTransform
end

function CollectionModelComponent:getSlotRootTransform(slotConfig)
	if not self.propsRoot or not slotConfig or not slotConfig.location then
		return nil
	end

	return self.propsRoot:Find(slotConfig.location)
end

function CollectionModelComponent:getSlotLightTransform(slotConfig)
	local slotTransform = self:getSlotRootTransform(slotConfig)

	if not slotTransform or not slotConfig or not slotConfig.location then
		return nil
	end

	return slotTransform:Find("Light_" .. slotConfig.location)
end

function CollectionModelComponent:getSlotEffLightTransform(slotConfig)
	local slotTransform = self:getSlotRootTransform(slotConfig)

	if not slotTransform then
		return nil
	end

	return slotTransform:Find("Eff_Light")
end

function CollectionModelComponent:getCollectionSlotList()
	local list = {}

	if not self.propsRoot then
		return list
	end

	local showCase = self:getShowCaseData()

	for slotId, slotConfig in pairs(RobEggBookCollectionData) do
		if slotConfig.collectGroup == BASE_CASE_ID and slotConfig.location then
			local slotTransform = self:getSlotMountPoint(slotConfig)

			if slotTransform then
				local slotItem = showCase and showCase[slotId]

				table.insert(list, {
					slotId = slotId,
					slotConfig = slotConfig,
					slotTransform = slotTransform,
					slotData = self.slotModels[slotTransform],
					slotItem = slotItem,
					hasItem = slotItem and slotItem.id and slotItem.id > 0
				})
			end
		end
	end

	table.sort(list, function(a, b)
		return (a.slotId or 0) < (b.slotId or 0)
	end)

	return list
end

function CollectionModelComponent:getSlotModelRotation(slotTransform)
	local slotData = slotTransform and self.slotModels[slotTransform]
	local modelTransform = slotData and slotData.model and slotData.model.transform

	if not modelTransform or UIUtils.IsNull(modelTransform) then
		return nil
	end

	local eulerAngles = modelTransform.rotation.eulerAngles

	return {
		x = eulerAngles.x,
		y = eulerAngles.y,
		z = eulerAngles.z
	}
end

function CollectionModelComponent:getSlotModelScale(slotTransform)
	local slotData = slotTransform and self.slotModels[slotTransform]
	local modelTransform = slotData and slotData.model and slotData.model.transform

	if not modelTransform or UIUtils.IsNull(modelTransform) then
		return nil
	end

	local baseLocalScale = self.originalScale[slotTransform] or modelTransform.localScale.x or 1
	local parentTransform = modelTransform.parent
	local parentWorldScale = parentTransform and parentTransform.lossyScale or CS.UnityEngine.Vector3.one

	return {
		x = baseLocalScale * math.abs(parentWorldScale.x),
		y = baseLocalScale * math.abs(parentWorldScale.y),
		z = baseLocalScale * math.abs(parentWorldScale.z)
	}
end

function CollectionModelComponent:refreshSlot(slotId, slotConfig, slotTransform)
	local showCase = self:getShowCaseData()
	local slotItem = showCase and showCase[slotId]

	if slotItem and slotItem.id and slotItem.id > 0 then
		local templateId = self:getTemplateIdByItemId(slotItem.id)

		if templateId then
			local collectConfig = CollectItemData[templateId]
			local displayModelData = RobEggCollectionDisplayModelUtils.getModelData(slotItem.id)
			local modelResId = displayModelData and displayModelData.modelResId
			local slotData = self.slotModels[slotTransform]

			if slotData and slotData.itemId == slotItem.id and slotData.modelResId == modelResId then
				local entity = self.slotEntities[slotTransform]

				if entity then
					slotData.displayModelData = displayModelData
					slotData.playCosItemId = displayModelData.playCosItemId

					self:tryDisableItemEffectLod(slotTransform, entity)

					if collectConfig and not slotData.effectId then
						self:schedulePlaySlotEffect(slotTransform, entity, collectConfig.effect)
					end

					if collectConfig then
						self:scheduleApplySlotPreset(slotTransform, entity, collectConfig.PresetName)
					end
				end

				return
			end

			self:loadItemModel(slotTransform, slotItem, templateId, slotId)
		end
	else
		local slotData = self.slotModels[slotTransform]

		if slotData and slotData.lockModel == slotConfig.lockModel then
			local entity = self.slotEntities[slotTransform]

			if entity then
				self:tryDisableItemEffectLod(slotTransform, entity)
			end

			return
		end

		self:loadDefaultModel(slotTransform, slotConfig, slotId)
	end
end

function CollectionModelComponent:getTemplateIdByItemId(itemId)
	local itemOutCfg = RobEggItemOut[itemId]
	local inItemId = itemOutCfg and itemOutCfg.inid or itemId

	return inItemId
end

function CollectionModelComponent:getClickColliderSize(calculatedSize)
	return calculatedSize or CS.UnityEngine.Vector3(COLLECTION_CLICK_WIDTH, COLLECTION_CLICK_HEIGHT, COLLECTION_CLICK_DEPTH)
end

function CollectionModelComponent:getAdjustedBoundsSize(slotId, size)
	if not size then
		return nil
	end

	local scale = COLLECTION_BOUNDS_SIZE_SCALE_OVERRIDES[slotId]

	if not scale then
		return size
	end

	return CS.UnityEngine.Vector3(size.x * (scale.x or 1), size.y * (scale.y or 1), size.z * (scale.z or 1))
end

function CollectionModelComponent:getCameraFocusOffset(slotId)
	local override = CAMERA_FOCUS_OFFSET_OVERRIDES[slotId]

	return CS.UnityEngine.Vector3(override and override.x or CAMERA_FOCUS_OFFSET.x, override and override.y or CAMERA_FOCUS_OFFSET.y, override and override.z or CAMERA_FOCUS_OFFSET.z)
end

function CollectionModelComponent:disableModelMeshColliders(modelTransform)
	if not modelTransform or UIUtils.IsNull(modelTransform) then
		return
	end

	local meshColliders = modelTransform:GetComponentsInChildren(MeshColliderType, true)

	if not meshColliders then
		return
	end

	for i = 0, meshColliders.Length - 1 do
		local meshCollider = meshColliders[i]

		if meshCollider and not UIUtils.IsNull(meshCollider) then
			pcall(function()
				meshCollider.enabled = false
			end)
		end
	end
end

function CollectionModelComponent:addClickCollider(modelTransform, slotId)
	if not modelTransform or UIUtils.IsNull(modelTransform) then
		return nil
	end

	self:disableModelMeshColliders(modelTransform)

	local sphereColliderType = typeof(CS.UnityEngine.SphereCollider)
	local sphereCollider = modelTransform.gameObject:GetComponent(sphereColliderType)

	if sphereCollider and not UIUtils.IsNull(sphereCollider) then
		pcall(function()
			sphereCollider.enabled = false
		end)
	end

	local boxColliderType = typeof(CS.UnityEngine.BoxCollider)
	local collider = modelTransform.gameObject:GetComponent(boxColliderType)

	if not collider or UIUtils.IsNull(collider) then
		collider = modelTransform.gameObject:AddComponent(boxColliderType)
	end

	local size = self:getClickColliderSize()
	local center = CS.UnityEngine.Vector3(0, size.y * 0.5, 0)

	if collider and not UIUtils.IsNull(collider) then
		pcall(function()
			collider.isTrigger = true
			collider.enabled = true
			collider.center = center
			collider.size = size
		end)
	end

	return {
		boundsReady = false,
		component = collider,
		transform = modelTransform,
		center = center,
		size = size,
		slotId = slotId
	}
end

function CollectionModelComponent:getRendererBoundsTransform(renderer)
	if not renderer or IsNil(renderer) then
		return nil, nil
	end

	local ok, rootBone = pcall(function()
		return renderer.rootBone
	end)

	if ok and rootBone and not UIUtils.IsNull(rootBone) then
		return rootBone, "rootBone"
	end

	local rendererTransform = renderer.transform

	if rendererTransform and not UIUtils.IsNull(rendererTransform) then
		return rendererTransform, "renderer"
	end

	return nil, nil
end

function CollectionModelComponent:forEachRendererBoundsWorldCorner(renderer, callback)
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

function CollectionModelComponent:expandLocalBoundsByRenderers(modelTransform, renderers, boundsData, itemRootTransform)
	if not renderers then
		return boundsData
	end

	for i = 0, renderers.Length - 1 do
		local renderer = renderers[i]

		if not self:isRendererUnderEffectNode(renderer, itemRootTransform) then
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
	end

	return boundsData
end

function CollectionModelComponent:expandScreenBoundsByRenderers(renderers, camera, boundsData)
	if not renderers then
		return boundsData
	end

	for i = 0, renderers.Length - 1 do
		local renderer = renderers[i]

		self:forEachRendererBoundsWorldCorner(renderer, function(worldPoint)
			local screenPoint = UIUtils.WorldToScreenPoint(worldPoint, camera)

			if screenPoint then
				if not boundsData then
					boundsData = {
						minX = screenPoint.x,
						maxX = screenPoint.x,
						minY = screenPoint.y,
						maxY = screenPoint.y
					}
				else
					boundsData.minX = math.min(boundsData.minX, screenPoint.x)
					boundsData.maxX = math.max(boundsData.maxX, screenPoint.x)
					boundsData.minY = math.min(boundsData.minY, screenPoint.y)
					boundsData.maxY = math.max(boundsData.maxY, screenPoint.y)
				end
			end
		end)
	end

	return boundsData
end

function CollectionModelComponent:isBoundsSizeValid(size)
	if not size then
		return false
	end

	local maxReasonableSize = 20

	return size.x == size.x and size.y == size.y and size.z == size.z and size.x > 0.001 and size.y > 0.001 and size.z > 0.001 and maxReasonableSize > size.x and maxReasonableSize > size.y and maxReasonableSize > size.z
end

function CollectionModelComponent:getModelLocalBounds(entity)
	local eModel = entity and entity.eModel
	local modelTransform = eModel and eModel.transform
	local itemModel = eModel and eModel.itemModel

	if not modelTransform or IsNil(itemModel) then
		return nil, nil
	end

	local itemRootTransform = itemModel.transform
	local skinnedRenderers = itemModel:GetComponentsInChildren(SkinnedMeshRendererType, true)
	local meshRenderers = itemModel:GetComponentsInChildren(MeshRendererType, true)
	local boundsData = self:expandLocalBoundsByRenderers(modelTransform, skinnedRenderers, nil, itemRootTransform)

	boundsData = boundsData or self:expandLocalBoundsByRenderers(modelTransform, meshRenderers, nil, itemRootTransform)

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

function CollectionModelComponent:isRendererUnderEffectNode(renderer, itemRootTransform)
	local currentTransform = renderer and renderer.transform

	while currentTransform and not UIUtils.IsNull(currentTransform) do
		local nodeName = string.lower(tostring(currentTransform.name or ""))

		if string.sub(nodeName, 1, 4) == "eff_" or string.find(nodeName, "effect", 1, true) or string.find(nodeName, "vfx", 1, true) then
			return true
		end

		if currentTransform == itemRootTransform then
			break
		end

		currentTransform = currentTransform.parent
	end

	return false
end

function CollectionModelComponent:appendSelectableBoundsRenderers(renderers, result, itemRootTransform)
	result = result or {}

	if not renderers then
		return result
	end

	for i = 0, renderers.Length - 1 do
		local renderer = renderers[i]

		if renderer and not IsNil(renderer) and not self:isRendererUnderEffectNode(renderer, itemRootTransform) then
			local valid = false

			pcall(function()
				local bounds = renderer.bounds
				local size = bounds and bounds.size

				valid = renderer.enabled == true and renderer.gameObject.activeInHierarchy == true and size and size.x > 0.001 and size.y > 0.001 and size.z > 0.001
			end)

			if valid then
				result[#result + 1] = renderer
			end
		end
	end

	return result
end

function CollectionModelComponent:getModelBoundsRenderers(entity)
	local itemModel = entity and entity.eModel and entity.eModel.itemModel

	if IsNil(itemModel) then
		return nil, nil
	end

	local itemRootTransform = itemModel.transform
	local renderers = self:appendSelectableBoundsRenderers(itemModel:GetComponentsInChildren(SkinnedMeshRendererType, true), nil, itemRootTransform)

	if #renderers > 0 then
		return renderers
	end

	renderers = self:appendSelectableBoundsRenderers(itemModel:GetComponentsInChildren(MeshRendererType, true), nil, itemRootTransform)

	if #renderers > 0 then
		return renderers
	end

	return nil
end

function CollectionModelComponent:updateClickColliderFromModelBounds(slotTransform, entity)
	if self.slotEntities[slotTransform] ~= entity then
		return false
	end

	local slotData = self.slotModels[slotTransform]
	local clickCollider = slotData and slotData.clickCollider
	local collider = clickCollider and clickCollider.component

	if not clickCollider or not collider or UIUtils.IsNull(collider) then
		return false
	end

	local boundsRenderers = self:getModelBoundsRenderers(entity)
	local center, calculatedSize = self:getModelLocalBounds(entity)

	if not boundsRenderers and (not center or not calculatedSize) then
		return false
	end

	local size = calculatedSize and self:getClickColliderSize(calculatedSize) or clickCollider.size

	size = self:getAdjustedBoundsSize(slotData.slotId, size)

	if center and size then
		collider.center = center
		collider.size = size
		clickCollider.center = center
		clickCollider.size = size
	end

	clickCollider.boundsRenderers = boundsRenderers
	collider.enabled = true
	clickCollider.boundsReady = true
	slotData.boundsReady = true

	local marker = self.placeTipMarkers[slotData.slotId]

	if marker and not UIUtils.IsNull(marker) then
		self:updatePlaceTipPosition(marker, slotTransform)
	end

	return true
end

function CollectionModelComponent:getSlotBoundsTopWorldPosition(slotTransform)
	if not slotTransform or UIUtils.IsNull(slotTransform) then
		return nil
	end

	local slotData = self.slotModels[slotTransform]
	local clickCollider = slotData and slotData.clickCollider

	if not clickCollider or clickCollider.boundsReady ~= true or not clickCollider.transform or UIUtils.IsNull(clickCollider.transform) then
		return slotTransform.position
	end

	local center = clickCollider.center or CS.UnityEngine.Vector3.zero
	local size = clickCollider.size or self:getClickColliderSize()
	local topLocalPosition = center + CS.UnityEngine.Vector3(0, size.y * 0.5, 0)

	return clickCollider.transform:TransformPoint(topLocalPosition)
end

function CollectionModelComponent:getSlotRendererTopScreenPosition(slotTransform, camera)
	local entity = slotTransform and self.slotEntities[slotTransform]
	local itemModel = entity and entity.eModel and entity.eModel.itemModel

	if IsNil(itemModel) then
		return nil
	end

	local boundsData = self:expandScreenBoundsByRenderers(itemModel:GetComponentsInChildren(MeshRendererType, true), camera)

	boundsData = self:expandScreenBoundsByRenderers(itemModel:GetComponentsInChildren(SkinnedMeshRendererType, true), camera, boundsData)

	if not boundsData then
		return nil
	end

	return CS.UnityEngine.Vector2((boundsData.minX + boundsData.maxX) * 0.5, boundsData.maxY)
end

function CollectionModelComponent:getSlotRendererBottomScreenPosition(slotTransform, camera)
	local entity = slotTransform and self.slotEntities[slotTransform]
	local itemModel = entity and entity.eModel and entity.eModel.itemModel

	if IsNil(itemModel) then
		return nil
	end

	local boundsData = self:expandScreenBoundsByRenderers(itemModel:GetComponentsInChildren(MeshRendererType, true), camera)

	boundsData = self:expandScreenBoundsByRenderers(itemModel:GetComponentsInChildren(SkinnedMeshRendererType, true), camera, boundsData)

	if not boundsData then
		return nil
	end

	return CS.UnityEngine.Vector2((boundsData.minX + boundsData.maxX) * 0.5, boundsData.minY)
end

function CollectionModelComponent:getSlotBoundsTopScreenPosition(slotTransform, camera)
	if not slotTransform or UIUtils.IsNull(slotTransform) then
		return nil
	end

	if not camera or UIUtils.IsNull(camera) then
		return nil
	end

	local slotData = self.slotModels[slotTransform]
	local clickCollider = slotData and slotData.clickCollider

	if not clickCollider or clickCollider.boundsReady ~= true or not clickCollider.transform or UIUtils.IsNull(clickCollider.transform) then
		return UIUtils.WorldToScreenPoint(slotTransform.position, camera)
	end

	local center = clickCollider.center or CS.UnityEngine.Vector3.zero
	local size = clickCollider.size or self:getClickColliderSize()
	local halfX = size.x * 0.5
	local halfY = size.y * 0.5
	local halfZ = size.z * 0.5
	local minScreenX, maxScreenX, topScreenY

	for xIndex = 0, 1 do
		local x = center.x + (xIndex == 0 and -halfX or halfX)

		for yIndex = 0, 1 do
			local y = center.y + (yIndex == 0 and -halfY or halfY)

			for zIndex = 0, 1 do
				local z = center.z + (zIndex == 0 and -halfZ or halfZ)
				local worldPoint = clickCollider.transform:TransformPoint(CS.UnityEngine.Vector3(x, y, z))
				local screenPoint = UIUtils.WorldToScreenPoint(worldPoint, camera)

				if screenPoint then
					minScreenX = minScreenX and math.min(minScreenX, screenPoint.x) or screenPoint.x
					maxScreenX = maxScreenX and math.max(maxScreenX, screenPoint.x) or screenPoint.x
					topScreenY = topScreenY and math.max(topScreenY, screenPoint.y) or screenPoint.y
				end
			end
		end
	end

	if not minScreenX or not maxScreenX or not topScreenY then
		return UIUtils.WorldToScreenPoint(slotTransform.position, camera)
	end

	return CS.UnityEngine.Vector2((minScreenX + maxScreenX) * 0.5, topScreenY)
end

function CollectionModelComponent:refreshClickColliderAfterModelLoaded(slotTransform, entity)
	if entity and entity.eModel and entity.eModel.transform then
		self:disableModelMeshColliders(entity.eModel.transform)
	end

	self:updateClickColliderFromModelBounds(slotTransform, entity)

	for _, frameCount in ipairs(BOUNDS_REAPPLY_FRAME_COUNTS) do
		TimerManager.addSpecificFrameCb(frameCount, false, function()
			if self.slotEntities[slotTransform] == entity then
				if entity and entity.eModel and entity.eModel.transform then
					self:disableModelMeshColliders(entity.eModel.transform)
				end

				self:updateClickColliderFromModelBounds(slotTransform, entity)
			end
		end)
	end
end

function CollectionModelComponent:disableItemEffectLod(entity)
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

function CollectionModelComponent:tryDisableItemEffectLod(slotTransform, entity, retryCount)
	if self.slotEntities[slotTransform] ~= entity then
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
		self:tryDisableItemEffectLod(slotTransform, entity, retryCount + 1)
	end)
end

function CollectionModelComponent:tryPlaySlotEffect(slotTransform, entity, effect, retryCount)
	if not effect or effect == "" then
		return
	end

	if self.slotEntities[slotTransform] ~= entity then
		return
	end

	local slotData = self.slotModels[slotTransform]

	if not slotData or slotData.effectId then
		return
	end

	local effectId = entity:playEffect(effect, nil, true)

	if effectId and effectId ~= 0 then
		slotData.effectId = effectId

		return
	end

	retryCount = retryCount or 0

	if retryCount >= EFFECT_RETRY_MAX_COUNT then
		return
	end

	TimerManager.addNextFrameCb(function()
		self:tryPlaySlotEffect(slotTransform, entity, effect, retryCount + 1)
	end)
end

function CollectionModelComponent:getSlotPresentationDelayFrame(slotTransform)
	local slotData = self.slotModels[slotTransform]
	local slotId = slotData and slotData.slotId or 0

	return EFFECT_PLAY_DELAY_FRAME_COUNT + slotId % EFFECT_PLAY_STAGGER_FRAME_COUNT
end

function CollectionModelComponent:schedulePlaySlotEffect(slotTransform, entity, effect)
	if not effect or effect == "" then
		return
	end

	TimerManager.addSpecificFrameCb(self:getSlotPresentationDelayFrame(slotTransform), false, function()
		self:tryPlaySlotEffect(slotTransform, entity, effect)
	end)
end

function CollectionModelComponent:applySlotCommonMountEffects(slotTransform, entity)
	if self.slotEntities[slotTransform] ~= entity then
		return
	end

	local slotData = self.slotModels[slotTransform]
	local modelResId = slotData and slotData.modelResId

	if not modelResId or modelResId == "" then
		return
	end

	if not RobEggCollectionDisplayEffectUtils.hasCommonMountEffects(modelResId) then
		return
	end

	entity.eModel:SetActive(false)

	local revealed = false

	local function revealModel()
		if revealed or self.slotEntities[slotTransform] ~= entity then
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

function CollectionModelComponent:applySlotPreset(slotTransform, entity, presetNames)
	if self.slotEntities[slotTransform] ~= entity then
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

function CollectionModelComponent:scheduleApplySlotPreset(slotTransform, entity, presetNames)
	if not presetNames then
		return
	end

	local baseDelayFrame = self:getSlotPresentationDelayFrame(slotTransform)

	for _, frameCount in ipairs(PRESET_REAPPLY_FRAME_COUNTS) do
		TimerManager.addSpecificFrameCb(baseDelayFrame + frameCount, false, function()
			self:applySlotPreset(slotTransform, entity, presetNames)
		end)
	end
end

function CollectionModelComponent:playSlotAppearEffect(slotId)
	local slotConfig = slotId and RobEggBookCollectionData[slotId]
	local slotRootTransform = self:getSlotRootTransform(slotConfig)
	local slotMountTransform = self:getSlotMountPoint(slotConfig)

	if not slotRootTransform or UIUtils.IsNull(slotRootTransform) then
		return
	end

	local entity = slotMountTransform and self.slotEntities[slotMountTransform] or nil

	if entity then
		entity:playEffect(SHOWCASE_APPEAR_EFFECT, nil, true)

		return
	end

	if not pg.game or not pg.game.effect then
		return
	end

	pg.game.effect:playEffectOn(0, SHOWCASE_APPEAR_EFFECT, slotRootTransform)
end

function CollectionModelComponent:applyItemPresentation(slotTransform, entity, collectConfig)
	if self.slotEntities[slotTransform] ~= entity then
		return
	end

	self:tryDisableItemEffectLod(slotTransform, entity)
	self:refreshClickColliderAfterModelLoaded(slotTransform, entity)

	local slotData = self.slotModels[slotTransform]

	if not slotData or slotData.presentationApplied then
		return
	end

	slotData.presentationApplied = true

	self:applySlotCommonMountEffects(slotTransform, entity)
	self:schedulePlaySlotEffect(slotTransform, entity, collectConfig.effect)
	self:scheduleApplySlotPreset(slotTransform, entity, collectConfig.PresetName)
end

function CollectionModelComponent:loadItemModel(slotTransform, slotItem, templateId, slotId)
	if not templateId then
		return
	end

	local collectConfig = CollectItemData[templateId]

	if not collectConfig then
		return
	end

	local displayModelData = RobEggCollectionDisplayModelUtils.getModelData(slotItem.id)
	local modelResId = displayModelData and displayModelData.modelResId
	local modelScale = displayModelData and displayModelData.modelScale

	if not modelResId or modelResId == "" then
		return
	end

	self:clearSlotModel(slotTransform)

	local entity = ClientSimpleVirtualEntity.new()

	function entity.onItemModelLoaded(loadedEntity)
		self:applyItemPresentation(slotTransform, loadedEntity, collectConfig)
	end

	local configData = {}

	entity:setConfigData(configData)

	local initInfo = {
		templateId = templateId
	}

	entity:init(initInfo)
	entity:postInit(initInfo)
	entity:start()
	entity:setModelLayer(ClientConst.LayerDefine.LAYER_UI_SCENE)
	entity:setDisableEffectLod(true)
	entity:addEModelComponent(Const.COMPONENT_IDX_ITEM)

	if entity:hasEModelComponent(Const.COMPONENT_IDX_ITEM) then
		entity.eModel:SetTransformParent(slotTransform, false)
		entity.eModel:SetTransformLocalPosition(MODEL_LOCAL_POSITION_OFFSET.x, MODEL_LOCAL_POSITION_OFFSET.y, MODEL_LOCAL_POSITION_OFFSET.z)
		entity.eModel:SetTransformLocalRotation(0, 0, 0, 1)

		local finalScale = modelScale or 1

		entity.eModel:SetTransformLocalScale(finalScale, finalScale, finalScale)

		self.originalScale[slotTransform] = finalScale

		local clickCollider = self:addClickCollider(entity.eModel.transform, slotId)

		self.slotEntities[slotTransform] = entity
		self.slotModels[slotTransform] = {
			model = entity.eModel,
			clickCollider = clickCollider,
			slotId = slotId,
			itemId = slotItem.id,
			modelResId = modelResId,
			playCosItemId = displayModelData.playCosItemId,
			displayModelData = displayModelData
		}

		entity.eModel:SetModelResId(Const.COMPONENT_IDX_ITEM, modelResId)
	end
end

function CollectionModelComponent:loadDefaultModel(slotTransform, slotConfig, slotId)
	if not slotConfig.lockModel or slotConfig.lockModel == "" then
		return
	end

	self:clearSlotModel(slotTransform)

	local entity = ClientSimpleVirtualEntity.new()

	function entity.onItemModelLoaded(loadedEntity)
		if self.slotEntities[slotTransform] == loadedEntity then
			self:tryDisableItemEffectLod(slotTransform, loadedEntity)
			self:refreshClickColliderAfterModelLoaded(slotTransform, loadedEntity)
		end
	end

	local configData = {}

	entity:setConfigData(configData)

	local initInfo = {}

	entity:init(initInfo)
	entity:postInit(initInfo)
	entity:start()
	entity:setModelLayer(ClientConst.LayerDefine.LAYER_UI_SCENE)
	entity:setDisableEffectLod(true)
	entity:addEModelComponent(Const.COMPONENT_IDX_ITEM)

	if entity:hasEModelComponent(Const.COMPONENT_IDX_ITEM) then
		entity.eModel:SetTransformParent(slotTransform, false)
		entity.eModel:SetTransformLocalPosition(MODEL_LOCAL_POSITION_OFFSET.x, MODEL_LOCAL_POSITION_OFFSET.y, MODEL_LOCAL_POSITION_OFFSET.z)
		entity.eModel:SetTransformLocalRotation(0, 0, 0, 1)
		entity.eModel:SetTransformLocalScale()

		self.originalScale[slotTransform] = 1

		local clickCollider = self:addClickCollider(entity.eModel.transform, slotId)

		self.slotEntities[slotTransform] = entity
		self.slotModels[slotTransform] = {
			model = entity.eModel,
			clickCollider = clickCollider,
			slotId = slotId,
			lockModel = slotConfig.lockModel
		}

		entity.eModel:SetModelResId(Const.COMPONENT_IDX_ITEM, slotConfig.lockModel)
	end
end

function CollectionModelComponent:clearSlotModel(slotTransform)
	local entity = self.slotEntities[slotTransform]

	if entity then
		RobEggCollectionDisplayEffectUtils.clearCommonMountEffects(entity)
		ClientUtils.safeDestroy(entity)

		self.slotEntities[slotTransform] = nil
	end

	self.slotModels[slotTransform] = nil
end

function CollectionModelComponent:resetSlotPresentationState(slotTransform)
	local slotData = self.slotModels[slotTransform]

	if not slotData then
		return
	end

	slotData.presentationApplied = nil
	slotData.effectId = nil
end

function CollectionModelComponent:resetAllSlotPresentationStates()
	for slotTransform, _ in pairs(self.slotModels) do
		self:resetSlotPresentationState(slotTransform)
	end
end

function CollectionModelComponent:getShowCaseData()
	if not pg.me or not pg.me.showCases then
		return nil
	end

	return pg.me.showCases[BASE_CASE_ID]
end

function CollectionModelComponent:isNormalStage()
	return not self.ctrl or self.ctrl.currentStage == STAGE_NORMAL
end

function CollectionModelComponent:hasPlacedItem(slotId)
	local showCase = self:getShowCaseData()
	local slotItem = showCase and (showCase[slotId] or showCase[tonumber(slotId)] or showCase[tostring(slotId)])

	return slotItem and slotItem.id and slotItem.id > 0
end

function CollectionModelComponent:hasAvailableBagItem(slotId)
	if not self.ctrl or not self.ctrl.model or not self.ctrl.model.getSlotItemData then
		return false
	end

	local slotItems = self.ctrl.model:getSlotItemData(slotId)

	return slotItems and #slotItems > 0
end

function CollectionModelComponent:shouldShowPlaceTip(slotId)
	return not self:hasPlacedItem(slotId) and self:hasAvailableBagItem(slotId)
end

function CollectionModelComponent:setNodeVisible(node, visible)
	if not node or UIUtils.IsNull(node) then
		return
	end

	visible = visible == true

	local gameObject = node.gameObject or node

	if not gameObject or UIUtils.IsNull(gameObject) then
		return
	end

	if gameObject.SetActiveEx then
		gameObject:SetActiveEx(visible)
	elseif gameObject and gameObject.SetActive then
		gameObject:SetActive(visible)
	end
end

function CollectionModelComponent:areAllCollectionSlotsPlaced()
	local hasCollectionSlot = false

	for slotId, slotConfig in pairs(RobEggBookCollectionData) do
		if slotConfig.collectGroup == BASE_CASE_ID and slotConfig.location then
			hasCollectionSlot = true

			if not self:hasPlacedItem(slotId) then
				return false
			end
		end
	end

	return hasCollectionSlot
end

function CollectionModelComponent:refreshSlotLights()
	if not self.propsRoot then
		return
	end

	local visible = self:areAllCollectionSlotsPlaced()

	for _, slotConfig in pairs(RobEggBookCollectionData) do
		if slotConfig.collectGroup == BASE_CASE_ID and slotConfig.location then
			self:setNodeVisible(self:getSlotLightTransform(slotConfig), visible)
		end
	end
end

function CollectionModelComponent:refreshSlotEffLights()
	if not self.propsRoot then
		return
	end

	for slotId, slotConfig in pairs(RobEggBookCollectionData) do
		if slotConfig.collectGroup == BASE_CASE_ID and slotConfig.location then
			local visible = self:hasPlacedItem(slotId)
			local effLightTransform = self:getSlotEffLightTransform(slotConfig)

			self:setNodeVisible(effLightTransform, visible)

			if visible and effLightTransform and not UIUtils.IsNull(effLightTransform) then
				local renderers = effLightTransform:GetComponentsInChildren(ParticleSystemRendererType, true)

				if renderers then
					for i = 0, renderers.Length - 1 do
						local renderer = renderers[i]

						if renderer and not UIUtils.IsNull(renderer) then
							renderer.enabled = true
						end
					end
				end
			end
		end
	end
end

function CollectionModelComponent:refreshPlaceTips()
	if not self.panelRedDot or not self.propsRoot then
		return
	end

	if not self:isNormalStage() then
		self:setPlaceTipsVisible(false)

		return
	end

	local activeSlotMap = {}

	for slotId, slotConfig in pairs(RobEggBookCollectionData) do
		if slotConfig.collectGroup == BASE_CASE_ID and slotConfig.location then
			local slotTransform = self:getSlotMountPoint(slotConfig)
			local hasPlacedItem = self:hasPlacedItem(slotId)
			local slotItems = self.ctrl and self.ctrl.model and self.ctrl.model.getSlotItemData and self.ctrl.model:getSlotItemData(slotId)
			local bagCount = slotItems and #slotItems or 0
			local shouldShow = slotTransform and not hasPlacedItem and bagCount > 0

			if shouldShow then
				activeSlotMap[slotId] = true

				self:createOrUpdatePlaceTip(slotId, slotTransform)
			end
		end
	end

	for slotId, _ in pairs(self.placeTipMarkers) do
		if not activeSlotMap[slotId] then
			self:destroyPlaceTip(slotId)
		end
	end
end

function CollectionModelComponent:createOrUpdatePlaceTip(slotId, slotTransform)
	local marker = self.placeTipMarkers[slotId]

	if marker and not UIUtils.IsNull(marker) then
		marker:SetActiveEx(true)
		self:updatePlaceTipPosition(marker, slotTransform)

		return
	end

	if self.placeTipLoading[slotId] then
		return
	end

	if not pg.global or not pg.global.resMgr then
		return
	end

	self.placeTipLoading[slotId] = pg.global.resMgr:GetInstanceFromCacheByLua(PLACE_TIP_PREFAB, function(go, userData)
		self.placeTipLoading[slotId] = nil

		if not go or UIUtils.IsNull(go) or not self.panelRedDot or UIUtils.IsNull(self.panelRedDot) then
			return
		end

		if not self:isNormalStage() or not self:shouldShowPlaceTip(slotId) then
			pg.global.resMgr:RemoveInstanceToCache(go, true)

			return
		end

		if not slotTransform or UIUtils.IsNull(slotTransform) then
			pg.global.resMgr:RemoveInstanceToCache(go, true)

			return
		end

		go.transform:SetParent(self.panelRedDot.transform, false)
		self:setPlaceTipTitle(go)
		go:SetActiveEx(true)

		self.placeTipMarkers[slotId] = go

		self:updatePlaceTipPosition(go, slotTransform)
	end, 1, nil, self.panelRedDot.transform)
end

function CollectionModelComponent:getTextComponent(view)
	if not view or UIUtils.IsNull(view) then
		return nil
	end

	local ok, component = pcall(function()
		return view:GetComponent("UBaseText")
	end)

	if ok and component and not UIUtils.IsNull(component) then
		return component
	end

	if view.gameObject and not UIUtils.IsNull(view.gameObject) then
		ok, component = pcall(function()
			return view.gameObject:GetComponent("UBaseText")
		end)

		if ok and component and not UIUtils.IsNull(component) then
			return component
		end
	end

	return view
end

function CollectionModelComponent:setPlaceTipTitle(marker)
	if not marker or UIUtils.IsNull(marker) then
		return
	end

	local title
	local objectReference = marker:GetComponent("ObjectReference")

	if objectReference and not UIUtils.IsNull(objectReference) then
		title = objectReference:GetRefValue("title") or objectReference:GetRefValue("titleUText")
	end

	if not title and marker.transform then
		local titleTransform = marker.transform:Find("title")

		if titleTransform and not UIUtils.IsNull(titleTransform) then
			title = titleTransform.gameObject
		end
	end

	ClientTextUtils.setText(self:getTextComponent(title), pg.getGameString("GRAB_EGG_Collection_Unlock_Tip"))
end

function CollectionModelComponent:updatePlaceTipPosition(marker, slotTransform)
	if not marker or UIUtils.IsNull(marker) or not slotTransform or UIUtils.IsNull(slotTransform) then
		return
	end

	if not self.scene or not self.scene.camera or not self.panelRedDot then
		return
	end

	local screenPos = self:getSlotRendererBottomScreenPosition(slotTransform, self.scene.camera)

	screenPos = screenPos or UIUtils.WorldToScreenPoint(slotTransform.position + PLACE_TIP_WORLD_OFFSET, self.scene.camera)

	local _, localPos = CS.UnityEngine.RectTransformUtility.ScreenPointToLocalPointInRectangle(self.panelRedDot.transform, screenPos, CS.XGUI.UWidget.uiCamera)
	local slotData = self.slotModels[slotTransform]
	local slotId = slotData and slotData.slotId
	local yOffset = PLACE_TIP_LOCAL_Y_OFFSET_OVERRIDES[slotId] or 0

	localPos = localPos + CS.UnityEngine.Vector2(0, yOffset)
	marker.transform.localPosition = localPos
end

function CollectionModelComponent:setPlaceTipsVisible(visible)
	for _, marker in pairs(self.placeTipMarkers) do
		if marker and not UIUtils.IsNull(marker) then
			marker:SetActiveEx(visible == true)
		end
	end
end

function CollectionModelComponent:destroyPlaceTip(slotId)
	local marker = self.placeTipMarkers[slotId]

	if marker and not UIUtils.IsNull(marker) then
		if pg.global and pg.global.resMgr then
			pg.global.resMgr:RemoveInstanceToCache(marker, true)
		else
			CS.UnityEngine.Object.Destroy(marker)
		end
	end

	self.placeTipMarkers[slotId] = nil

	local taskId = self.placeTipLoading[slotId]

	if taskId and pg.global and pg.global.resMgr then
		pg.global.resMgr:TryCancelGOLoadAsyncTask(taskId)
	end

	self.placeTipLoading[slotId] = nil
end

function CollectionModelComponent:clearPlaceTips()
	for slotId, _ in pairs(self.placeTipMarkers) do
		self:destroyPlaceTip(slotId)
	end

	self.placeTipLoading = {}
end

function CollectionModelComponent:refreshAllSlots()
	if not self.propsRoot then
		return
	end

	for slotId, slotConfig in pairs(RobEggBookCollectionData) do
		if slotConfig.collectGroup == BASE_CASE_ID and slotConfig.location then
			local slotTransform = self:getSlotMountPoint(slotConfig)

			if slotTransform then
				self:refreshSlot(slotId, slotConfig, slotTransform)
			end
		end
	end

	self:refreshPlaceTips()
	self:refreshSlotLights()
	self:refreshSlotEffLights()
end

function CollectionModelComponent:destroy()
	self:stopInputMonitoring()
	self:clearPlaceTips()

	for _, entity in pairs(self.slotEntities) do
		RobEggCollectionDisplayEffectUtils.clearCommonMountEffects(entity)
		ClientUtils.safeDestroy(entity)
	end

	self.slotEntities = {}
	self.slotModels = {}
	self.originalScale = {}
	self.hoveredSlot = nil
	self.clickedSlot = nil
	self.scene = nil
	self.ctrl = nil
	self.propsRoot = nil
	self.panelRedDot = nil
end

function CollectionModelComponent:startInputMonitoring()
	if not self.interactionEnabled then
		return
	end

	if not self.scene or not self.scene.camera then
		return
	end

	if self.clickUpdateTimer or self.hoverUpdateTimer then
		return
	end

	self.clickUpdateTimer = TimerManager.addRepeatTimer(0, function()
		self:onClickUpdate()
	end)

	if not self.isMobile then
		self.hoverUpdateTimer = TimerManager.addRepeatTimer(HOVER_UPDATE_INTERVAL, function()
			self:onHoverUpdate()
		end)
	end
end

function CollectionModelComponent:stopInputMonitoring()
	if self.clickUpdateTimer then
		TimerManager.removeTimer(self.clickUpdateTimer)

		self.clickUpdateTimer = nil
	end

	if self.hoverUpdateTimer then
		TimerManager.removeTimer(self.hoverUpdateTimer)

		self.hoverUpdateTimer = nil
	end

	if self.updateTimer then
		TimerManager.removeTimer(self.updateTimer)

		self.updateTimer = nil
	end
end

function CollectionModelComponent:resetPointerClickState()
	self.pressedSlot = nil
	self.pressedPointerId = nil
	self.pressedPointerSource = nil
	self.pressedPointerPosition = nil
	self.pressedPointerLatestPosition = nil
	self.pointerClickCanceled = false
end

function CollectionModelComponent:isBlockingPopupOpen()
	local ui = pg and pg.global and pg.global.ui

	if not ui or not ui.checkUIShow then
		return false
	end

	return ui:checkUIShow(UIConst.UI_ID_COMMON_OBTAIN) == true or ui:checkUIShow(UIConst.UI_ID_COMMON_ITEM_TIP) == true
end

function CollectionModelComponent:setInteractionEnabled(enabled)
	self.interactionEnabled = enabled == true

	self:resetPointerClickState()

	if not self.interactionEnabled then
		local clickedSlot = self.clickedSlot

		self.clickedSlot = nil

		self:onSlotHoverExit(self.hoveredSlot)

		self.clickedSlot = clickedSlot

		self:stopInputMonitoring()

		return
	end

	self:startInputMonitoring()
end

function CollectionModelComponent:resetCamera(callback)
	if not self.scene or not self.scene.camera then
		if callback then
			callback()
		end

		return
	end

	local cameraTransform = self.scene.camera.transform

	if not cameraTransform or UIUtils.IsNull(cameraTransform) then
		if callback then
			callback()
		end

		return
	end

	if self.defaultCameraLocalRotation then
		cameraTransform.localRotation = self.defaultCameraLocalRotation
	end

	if not self.defaultCameraLocalPosition then
		if callback then
			callback()
		end

		return
	end

	DoTweenAnimMgr.Move(cameraTransform, LuaUIUtils.TweenId("camera_focus"), self.defaultCameraLocalPosition, CAMERA_MOVE_DURATION, 0, CS.DG.Tweening.Ease.__CastFrom(6), function()
		if self.defaultCameraLocalRotation then
			cameraTransform.localRotation = self.defaultCameraLocalRotation
		end

		if callback then
			callback()
		end
	end)
end

function CollectionModelComponent:getPointerRay(mousePos)
	if not self.scene or not self.scene:isReady() or not self.scene.camera then
		return nil, nil
	end

	local camera = self.scene.camera

	if not camera or UIUtils.IsNull(camera) then
		return nil, nil
	end

	if not mousePos then
		return nil, nil
	end

	if not camera.ScreenToWorldPoint then
		return nil, nil
	end

	local nearPoint = camera:ScreenToWorldPoint(Vector3.New(mousePos.x, mousePos.y, camera.nearClipPlane or 0.3))
	local farPoint = camera:ScreenToWorldPoint(Vector3.New(mousePos.x, mousePos.y, camera.farClipPlane or 1000))

	if not nearPoint or not farPoint then
		return nil, nil
	end

	return nearPoint, Vector3.Normalize(farPoint - nearPoint)
end

function CollectionModelComponent:getMouseButtonDown()
	local inputMgr = pg and pg.global and pg.global.inputMgr

	if not inputMgr then
		return false
	end

	local ok, isDown = pcall(function()
		return inputMgr:GetMouseButtonDown(0)
	end)

	return ok and isDown == true
end

function CollectionModelComponent:getMouseButtonUp()
	local inputMgr = pg and pg.global and pg.global.inputMgr

	if not inputMgr then
		return false
	end

	local ok, isUp = pcall(function()
		return inputMgr:GetMouseButtonUp(0)
	end)

	return ok and isUp == true
end

function CollectionModelComponent:getMouseButton()
	local inputMgr = pg and pg.global and pg.global.inputMgr

	if not inputMgr then
		return false
	end

	local ok, isPressed = pcall(function()
		return inputMgr:GetMouseButton(0)
	end)

	return ok and isPressed == true
end

function CollectionModelComponent:getTouchInputEvent()
	local inputMgr = pg and pg.global and pg.global.inputMgr

	if not inputMgr then
		return nil
	end

	local okCount, touchCount = pcall(function()
		return inputMgr:GetTouchCount()
	end)

	if not okCount then
		return nil
	end

	touchCount = touchCount or 0

	if touchCount > 1 then
		return "cancel", nil, nil, "touch"
	end

	if touchCount <= 0 then
		if self.pressedPointerSource == "touch" then
			local lastPosition = self.pressedPointerLatestPosition or self.pressedPointerPosition

			return "up", lastPosition, self.pressedPointerId, "touch"
		end

		return nil
	end

	local touchIndex = 0
	local okPhase, phase = pcall(function()
		return inputMgr:GetTouchPhase(touchIndex)
	end)
	local okPosition, position = pcall(function()
		return inputMgr:GetTouchPosition(touchIndex)
	end)
	local okFingerId, fingerId = pcall(function()
		return inputMgr:GetTouchFingerId(touchIndex)
	end)

	if not okPhase or not okPosition or not okFingerId or not position or not fingerId or fingerId < 0 then
		return nil
	end

	local isTrackedTouch = self.pressedPointerSource == "touch" and self.pressedPointerId == fingerId

	if phase == TOUCH_PHASE_BEGAN then
		return "down", position, fingerId, "touch"
	elseif not isTrackedTouch and (phase == TOUCH_PHASE_MOVED or phase == TOUCH_PHASE_STATIONARY) then
		return "down", position, fingerId, "touch"
	elseif phase == TOUCH_PHASE_MOVED or phase == TOUCH_PHASE_STATIONARY then
		return "move", position, fingerId, "touch"
	elseif phase == TOUCH_PHASE_ENDED then
		return "up", position, fingerId, "touch"
	elseif phase == TOUCH_PHASE_CANCELED then
		return "cancel", position, fingerId, "touch"
	end

	return nil
end

function CollectionModelComponent:getMouseInputEvent()
	if not UnityInput then
		return nil
	end

	local mousePosition = UnityInput.mousePosition
	local isDown = self:getMouseButtonDown()
	local isUp = self:getMouseButtonUp()
	local isHeld = self:getMouseButton()

	if isDown then
		return "down", mousePosition, 0, "mouse"
	end

	if isUp then
		return "up", mousePosition, 0, "mouse"
	end

	if self.pressedPointerSource == "mouse" then
		if isHeld then
			return "move", mousePosition, 0, "mouse"
		end

		return "up", mousePosition, 0, "mouse"
	end

	if isHeld then
		return "down", mousePosition, 0, "mouse"
	end

	return nil
end

function CollectionModelComponent:getPointerInputEvent()
	local touchEvent, touchPosition, touchId, touchSource = self:getTouchInputEvent()

	if touchEvent then
		return touchEvent, touchPosition, touchId, touchSource
	end

	if self.pressedPointerSource == "touch" then
		return "cancel", nil, nil, "touch"
	end

	return self:getMouseInputEvent()
end

function CollectionModelComponent:isSamePressedPointer(pointerId, pointerSource)
	return self.pressedPointerId == pointerId and self.pressedPointerSource == pointerSource
end

function CollectionModelComponent:getPointerSlot()
	if not UnityInput then
		return nil
	end

	local mousePos = UnityInput.mousePosition

	if not mousePos then
		return nil
	end

	return self:getPointerSlotByPosition(mousePos)
end

function CollectionModelComponent:getPointerSlotByPosition(pointerPosition)
	local rayOrigin, rayDirection = self:getPointerRay(pointerPosition)

	if not rayOrigin or not rayDirection then
		return nil
	end

	return self:findSlotByClickCollider(rayOrigin, rayDirection, 1000)
end

function CollectionModelComponent:hasPointerMovedTooFar(pointerPosition)
	if not pointerPosition or not self.pressedPointerPosition then
		return false
	end

	local deltaX = (pointerPosition.x or 0) - (self.pressedPointerPosition.x or 0)
	local deltaY = (pointerPosition.y or 0) - (self.pressedPointerPosition.y or 0)

	return deltaX * deltaX + deltaY * deltaY > CLICK_CANCEL_MOVE_DISTANCE_SQR
end

function CollectionModelComponent:updateRayBoxDistanceByAxis(origin, direction, minValue, maxValue, minDistance, maxDistance)
	if math.abs(direction) < 1e-06 then
		if origin < minValue or maxValue < origin then
			return minDistance, maxDistance, false
		end

		return minDistance, maxDistance, true
	end

	local distance1 = (minValue - origin) / direction
	local distance2 = (maxValue - origin) / direction

	if distance2 < distance1 then
		distance1, distance2 = distance2, distance1
	end

	minDistance = math.max(minDistance, distance1)
	maxDistance = math.min(maxDistance, distance2)

	return minDistance, maxDistance, minDistance <= maxDistance
end

function CollectionModelComponent:getRayAxisAlignedBoundsDistance(rayOrigin, rayDirection, center, size, maxDistance)
	if not center or not size then
		return nil
	end

	local halfX = size.x * 0.5
	local halfY = size.y * 0.5
	local halfZ = size.z * 0.5
	local minDistance = 0
	local hit = true

	minDistance, maxDistance, hit = self:updateRayBoxDistanceByAxis(rayOrigin.x, rayDirection.x, center.x - halfX, center.x + halfX, minDistance, maxDistance)

	if not hit then
		return nil
	end

	minDistance, maxDistance, hit = self:updateRayBoxDistanceByAxis(rayOrigin.y, rayDirection.y, center.y - halfY, center.y + halfY, minDistance, maxDistance)

	if not hit then
		return nil
	end

	minDistance, maxDistance, hit = self:updateRayBoxDistanceByAxis(rayOrigin.z, rayDirection.z, center.z - halfZ, center.z + halfZ, minDistance, maxDistance)

	if not hit then
		return nil
	end

	return minDistance
end

function CollectionModelComponent:getRayBoxDistance(rayOrigin, rayDirection, clickCollider, maxDistance)
	if not clickCollider or not clickCollider.transform or UIUtils.IsNull(clickCollider.transform) then
		return nil
	end

	local localOrigin = clickCollider.transform:InverseTransformPoint(rayOrigin)
	local localEnd = clickCollider.transform:InverseTransformPoint(rayOrigin + rayDirection)
	local localDirection = localEnd - localOrigin

	return self:getRayAxisAlignedBoundsDistance(localOrigin, localDirection, clickCollider.center, clickCollider.size, maxDistance)
end

function CollectionModelComponent:getRayRendererBoundsDistance(rayOrigin, rayDirection, boundsRenderers, maxDistance, slotId)
	if not boundsRenderers then
		return nil
	end

	local nearestDistance = maxDistance
	local hasHit = false

	for _, renderer in ipairs(boundsRenderers) do
		local rendererBounds, rendererTransform
		local useLocalBounds = false
		local rendererValid = false

		if renderer and not IsNil(renderer) then
			pcall(function()
				rendererValid = renderer.enabled == true and renderer.gameObject.activeInHierarchy == true

				if rendererValid then
					rendererTransform = self:getRendererBoundsTransform(renderer)
				end
			end)
		end

		if rendererValid and rendererTransform and not UIUtils.IsNull(rendererTransform) then
			local ok, localBounds = pcall(function()
				return renderer.localBounds
			end)

			if ok and localBounds then
				rendererBounds = localBounds
				useLocalBounds = true
			end
		end

		if rendererValid and not rendererBounds then
			pcall(function()
				rendererBounds = renderer.bounds
			end)
		end

		if rendererValid and rendererBounds then
			local rendererBoundsSize = self:getAdjustedBoundsSize(slotId, rendererBounds.size)
			local boundsRayOrigin = rayOrigin
			local boundsRayDirection = rayDirection

			if useLocalBounds then
				boundsRayOrigin = rendererTransform:InverseTransformPoint(rayOrigin)

				local localEnd = rendererTransform:InverseTransformPoint(rayOrigin + rayDirection)

				boundsRayDirection = localEnd - boundsRayOrigin
			end

			local distance = self:getRayAxisAlignedBoundsDistance(boundsRayOrigin, boundsRayDirection, rendererBounds.center, rendererBoundsSize, nearestDistance)

			if distance and distance <= nearestDistance then
				nearestDistance = distance
				hasHit = true
			end
		end
	end

	return hasHit and nearestDistance or nil
end

function CollectionModelComponent:findSlotByClickCollider(rayOrigin, rayDirection, maxDistance)
	local nearestSlot
	local nearestDistance = maxDistance

	for slotTransform, slotData in pairs(self.slotModels) do
		local clickCollider = slotData.clickCollider
		local boundsRenderers = clickCollider and clickCollider.boundsRenderers
		local distance

		if boundsRenderers and #boundsRenderers > 0 then
			distance = self:getRayRendererBoundsDistance(rayOrigin, rayDirection, boundsRenderers, nearestDistance, slotData.slotId)
		end

		local collider = clickCollider and clickCollider.component
		local colliderValid = true

		if collider and not UIUtils.IsNull(collider) then
			local ok, enabled, isTrigger = pcall(function()
				return collider.enabled, collider.isTrigger
			end)

			colliderValid = not ok or enabled and isTrigger
		end

		if not boundsRenderers and clickCollider and colliderValid then
			distance = self:getRayBoxDistance(rayOrigin, rayDirection, clickCollider, nearestDistance)
		end

		if distance and distance <= nearestDistance then
			nearestDistance = distance
			nearestSlot = slotTransform
		end
	end

	return nearestSlot
end

function CollectionModelComponent:onSlotHoverEnter(slotTransform)
	if not slotTransform then
		return
	end

	if slotTransform == self.clickedSlot then
		return
	end

	self.hoveredSlot = slotTransform

	local slotData = self.slotModels[slotTransform]

	if slotData and slotData.model then
		local originalScale = self.originalScale[slotTransform] or 1
		local targetScale = originalScale * HOVER_SCALE
		local tweenId = LuaUIUtils.TweenId("slot_hover_" .. tostring(slotTransform))

		DoTweenAnimMgr.Scale(slotData.model.transform, tweenId, CS.UnityEngine.Vector3(targetScale, targetScale, targetScale), SCALE_DURATION, 0, CS.DG.Tweening.Ease.__CastFrom(6), function()
			return
		end)
	end
end

function CollectionModelComponent:onSlotHoverExit(slotTransform)
	if not slotTransform then
		return
	end

	if slotTransform == self.clickedSlot then
		return
	end

	if self.hoveredSlot == slotTransform then
		self.hoveredSlot = nil
	end

	local slotData = self.slotModels[slotTransform]

	if slotData and slotData.model then
		local originalScale = self.originalScale[slotTransform] or 1
		local tweenId = LuaUIUtils.TweenId("slot_hover_" .. tostring(slotTransform))

		DoTweenAnimMgr.Scale(slotData.model.transform, tweenId, CS.UnityEngine.Vector3(originalScale, originalScale, originalScale), SCALE_DURATION, 0, CS.DG.Tweening.Ease.__CastFrom(6), function()
			return
		end)
	end
end

function CollectionModelComponent:getCameraFocusPosition(slotTransform, slotData, additionalOffset)
	if not self.scene or not self.scene.rootTransform or not slotTransform then
		return nil
	end

	local rootTransform = self.scene.rootTransform
	local slotLocalPos = rootTransform:InverseTransformPoint(slotTransform.position)
	local focusOffset = self:getCameraFocusOffset(slotData and slotData.slotId)

	if additionalOffset then
		focusOffset = focusOffset + additionalOffset
	end

	return rootTransform:TransformPoint(slotLocalPos + focusOffset)
end

function CollectionModelComponent:focusSlot(slotTransform, slotData, additionalOffset)
	if not slotTransform then
		return
	end

	slotData = slotData or self.slotModels[slotTransform]

	if not slotData then
		return
	end

	self.clickedSlot = slotTransform

	if not self.scene or not self.scene.camera then
		self.clickedSlot = nil

		return
	end

	local cameraTransform = self.scene.camera.transform

	if not cameraTransform or UIUtils.IsNull(cameraTransform) then
		self.clickedSlot = nil

		return
	end

	local targetCameraPos = self:getCameraFocusPosition(slotTransform, slotData, additionalOffset)

	if not targetCameraPos then
		self.clickedSlot = nil

		return
	end

	local cameraParent = cameraTransform.parent
	local targetCameraLocalPos = targetCameraPos

	if cameraParent and not UIUtils.IsNull(cameraParent) then
		targetCameraLocalPos = cameraParent:InverseTransformPoint(targetCameraPos)
	end

	DoTweenAnimMgr.Move(cameraTransform, LuaUIUtils.TweenId("camera_focus"), targetCameraLocalPos, CAMERA_MOVE_DURATION, 0, CS.DG.Tweening.Ease.__CastFrom(6), function()
		self.clickedSlot = nil
	end)
end

function CollectionModelComponent:focusSlotForReplace(slotTransform, slotData)
	self:focusSlot(slotTransform, slotData, CS.UnityEngine.Vector3(CAMERA_REPLACE_HORIZONTAL_OFFSET, 0, 0))
end

function CollectionModelComponent:onSlotClick(slotTransform)
	if not slotTransform then
		return
	end

	local slotData = self.slotModels[slotTransform]

	if not slotData or not slotData.model then
		return
	end

	local shouldFocus = true

	if self.ctrl and self.ctrl.onCollectionSlotClick then
		shouldFocus = self.ctrl:onCollectionSlotClick(slotTransform, slotData)
	end

	if shouldFocus == false then
		return
	end

	self:focusSlot(slotTransform, slotData)
end

function CollectionModelComponent:triggerSlotClick(slotTransform)
	self:onSlotClick(slotTransform)
end

function CollectionModelComponent:syncHoverSlot(slotTransform)
	if slotTransform then
		if slotTransform ~= self.hoveredSlot then
			self:onSlotHoverExit(self.hoveredSlot)
			self:onSlotHoverEnter(slotTransform)
		end

		return
	end

	self:onSlotHoverExit(self.hoveredSlot)
end

function CollectionModelComponent:onClickUpdate()
	if not self.interactionEnabled then
		return
	end

	if self:isBlockingPopupOpen() then
		self:resetPointerClickState()

		return
	end

	local eventType, pointerPosition, pointerId, pointerSource = self:getPointerInputEvent()

	if not eventType then
		return
	end

	if eventType == "cancel" then
		self:resetPointerClickState()

		return
	end

	if eventType == "down" then
		self.pressedPointerId = pointerId
		self.pressedPointerSource = pointerSource
		self.pressedPointerPosition = pointerPosition
		self.pressedPointerLatestPosition = pointerPosition
		self.pointerClickCanceled = false
		self.pressedSlot = self:getPointerSlotByPosition(pointerPosition)

		if self.pressedSlot and not self.isMobile then
			self:syncHoverSlot(self.pressedSlot)
		end

		return
	end

	if eventType == "move" then
		local samePointer = self:isSamePressedPointer(pointerId, pointerSource)

		if samePointer then
			self.pressedPointerLatestPosition = pointerPosition
		end

		if samePointer and self:hasPointerMovedTooFar(pointerPosition) then
			self.pointerClickCanceled = true
		end

		return
	end

	if eventType ~= "up" then
		return
	end

	if self.pressedPointerId ~= nil and not self:isSamePressedPointer(pointerId, pointerSource) then
		return
	end

	local pressedSlot = self.pressedSlot
	local pointerClickCanceled = self.pointerClickCanceled or self:hasPointerMovedTooFar(pointerPosition)

	self:resetPointerClickState()

	if pointerClickCanceled or not pressedSlot then
		return
	end

	if not self.isMobile then
		self:syncHoverSlot(pressedSlot)
	end

	self:onSlotClick(pressedSlot)
end

function CollectionModelComponent:onHoverUpdate()
	if not self.interactionEnabled then
		return
	end

	if self:isBlockingPopupOpen() then
		self:syncHoverSlot(nil)

		return
	end

	if pg and pg.game and pg.game.input and pg.game.input.isUsingGamepad and pg.game.input:isUsingGamepad() then
		return
	end

	self:syncHoverSlot(self:getPointerSlot())
end

return CollectionModelComponent
