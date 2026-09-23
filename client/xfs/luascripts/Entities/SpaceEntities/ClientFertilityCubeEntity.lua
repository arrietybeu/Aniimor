-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\ClientFertilityCubeEntity.lua

local Class = require("Core.Framework.Class")
local ClientVirtualEntity = require("Entities.ClientVirtualEntity")
local ClientConst = require("Const.ClientConst")
local MessageName = require("Const.MessageName")
local ClientModelComponent = require("Entities.SpaceEntities.CommonComponent.ClientModelComponent")
local ClientAnimatorComponent = require("Entities.SpaceEntities.CommonComponent.ClientAnimatorComponent")
local EnvObjData = require("Data.envobj_data")
local SoulEggEvolutionConst = require("Common.Const.EvolutionConst").SoulEggEvolution
local AddressDataConst = require("Const.AddressDataConst")
local ClientModelUtils = require("Utils.ClientModelUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ResLoader = require("GameApp.ResLoad.ResLoader")
local PetCubeItemData = require("Data.pet_hatch_egg_cube_data")
local ID_EVO_SCENE_MOVE_CAMERA = "evoSceneMoveCamera"
local CUBE_PREFAB_ROOT_PATH = "E_P_Item_Catch_CatchBall_ShinyChampionBall"
local CUBE_BONE_PATH = CUBE_PREFAB_ROOT_PATH .. "/Bone_Root/Bone_001"
local BUILT_IN_SHINY_CUBE_MODEL_PATH = CUBE_PREFAB_ROOT_PATH .. "/M_Item_Catch_CatchBall_FeatherBall"
local SHINY_CUBE_PREFAB_RES_ID = "$P_Item_Catch_CatchBall_ShinyChampionBall_Throw.prefab"
local DYNAMIC_CUBE_MODEL_SCALE = 1.3333333333333333
local ClientFertilityCubeEntity = Class.Class("ClientFertilityCubeEntity", ClientVirtualEntity)
local ClientVirtualComponents = {
	ClientModelComponent,
	ClientAnimatorComponent
}

Class.AddComponents(ClientFertilityCubeEntity, ClientVirtualComponents)

function ClientFertilityCubeEntity:_restoreDynamicCubeRuntimeState()
	local state = self._dynamicCubeRuntimeState

	if not state then
		return
	end

	for _, item in ipairs(state.rootComponents) do
		if not IsNil(item.component) then
			item.component.enabled = item.enabled
		end
	end

	for _, item in ipairs(state.animators) do
		if not IsNil(item.component) then
			item.component.enabled = item.enabled
		end
	end

	for _, item in ipairs(state.rigidbodies) do
		if not IsNil(item.component) then
			item.component.isKinematic = item.isKinematic
			item.component.useGravity = item.useGravity
		end
	end

	for _, item in ipairs(state.colliders) do
		if not IsNil(item.component) then
			item.component.enabled = item.enabled
		end
	end

	for _, item in ipairs(state.layers) do
		if not IsNil(item.gameObject) then
			item.gameObject.layer = item.layer
		end
	end

	self._dynamicCubeRuntimeState = nil
end

function ClientFertilityCubeEntity:_clearDynamicCubeModel()
	local go = self._dynamicCubeModel

	if not IsNil(go) then
		go:SetActiveEx(false)
		go.transform:SetLocalScaleEx(1, 1, 1)
	end

	self:_restoreDynamicCubeRuntimeState()

	if self._dynamicCubeLoader then
		self._dynamicCubeLoader:destroy()

		self._dynamicCubeLoader = nil
	end

	self._dynamicCubeModel = nil
end

function ClientFertilityCubeEntity:_setDynamicCubeModelLayer(layer)
	local go = self._dynamicCubeModel

	if IsNil(go) then
		return
	end

	local UNITY_TRANSFORM_TYPE = typeof(CS.UnityEngine.Transform)
	local transforms = go:GetComponentsInChildren(UNITY_TRANSFORM_TYPE, true)

	for i = 0, transforms.Length - 1 do
		local transform = transforms[i]

		if not IsNil(transform) then
			transform.gameObject.layer = layer
		end
	end
end

function ClientFertilityCubeEntity:_refreshDynamicCubePresentation()
	local go = self._dynamicCubeModel

	if IsNil(go) then
		return
	end

	local visible = self._cubeVisible == true
	local layer = visible and (self._presentationLayer or ClientConst.LayerDefine.LAYER_CUTSCENE) or ClientConst.LayerDefine.LAYER_DEFAULT

	self:_setDynamicCubeModelLayer(layer)
	go:SetActiveEx(visible)
end

function ClientFertilityCubeEntity:_notifyCubeModelReady()
	if self.destroyed or self._cubeModelReady then
		return
	end

	self._cubeModelReady = true
	self.onSkeletonLoadedCallback = nil
	self._cubeRendererInitializationPendingVersion = nil

	local callback = self._cubeModelReadyCallback

	self._cubeModelReadyCallback = nil

	if callback then
		callback(self)
	end
end

function ClientFertilityCubeEntity:_armCubeRendererInitialization(loadVersion)
	function self.onSkeletonLoadedCallback()
		if self.destroyed or loadVersion ~= self._dynamicCubeLoadVersion then
			return
		end

		self._cubeRendererInitializationPendingVersion = loadVersion

		local modelView = self.eModel and self.eModel.modelModelView or nil

		if not IsNil(modelView) then
			modelView:SetModelActive(true)
		end

		self:setCubePresentationActive(true)
		self:_setBuiltInShinyCubeModelActive(true)
	end
end

function ClientFertilityCubeEntity:setCubeModel(info, resId, presentationOptions)
	self._presentationLayer = presentationOptions and presentationOptions.targetLayer or ClientConst.LayerDefine.LAYER_CUTSCENE
	self._cubeItemId = info and info.itemId
	self._cubeModelReady = false
	self._cubeModelReadyCallback = presentationOptions and presentationOptions.onModelReady or nil
	self._cubeVisible = false
	self._dynamicCubeLoadVersion = (self._dynamicCubeLoadVersion or 0) + 1

	local loadVersion = self._dynamicCubeLoadVersion

	self.onSkeletonLoadedCallback = nil
	self._cubeRendererInitializationPendingVersion = nil

	self:_clearDynamicCubeModel()

	self._dynamicCubePrefabResID = resId
	self._useBuiltInShinyCubeModel = resId == SHINY_CUBE_PREFAB_RES_ID

	if not resId or resId == "" then
		return
	end

	local modelView = self.eModel.modelModelView
	local extraInfo = {
		prefabResID = AddressDataConst.NEW_FERTILITY_CUBEFX_GENERAL_CUBE_IN,
		modelScale = info and info.scale
	}

	self:_armCubeRendererInitialization(loadVersion)
	ClientModelUtils.applyModelAppearance(modelView.modelInfo, nil, extraInfo)
	modelView:RefreshModels()
	self:setModelLayer(ClientConst.LayerDefine.LAYER_DEFAULT)
	self:refreshModelScale()
	self:_ensureDynamicCubeLoad(loadVersion)
end

function ClientFertilityCubeEntity:getCubeBoneTransform()
	local modelSkeletonView = self.eModel and self.eModel.modelSkeletonView

	if not modelSkeletonView then
		return nil
	end

	local skeletonRoot = modelSkeletonView.skeletonRoot

	if IsNil(skeletonRoot) then
		return nil
	end

	return skeletonRoot:Find(CUBE_BONE_PATH)
end

function ClientFertilityCubeEntity:_applyCubeSkeletonRotation()
	local bone001Ts = self:getCubeBoneTransform()

	if IsNil(bone001Ts) then
		return false
	end

	local cubeRotateTs = bone001Ts:GetChild(0)

	if IsNil(cubeRotateTs) then
		return false
	end

	local cubeRotation = PetCubeItemData[self._cubeItemId] and PetCubeItemData[self._cubeItemId].cubeRotation or {
		0,
		0,
		0
	}

	cubeRotateTs:SetLocalEulerAnglesEx(cubeRotation[1], cubeRotation[2], cubeRotation[3])

	return true
end

function ClientFertilityCubeEntity:_setBuiltInShinyCubeModelActive(active)
	local modelSkeletonView = self.eModel and self.eModel.modelSkeletonView

	if not modelSkeletonView then
		return false
	end

	local skeletonRoot = modelSkeletonView.skeletonRoot

	if IsNil(skeletonRoot) then
		return false
	end

	local modelNode = skeletonRoot:Find(BUILT_IN_SHINY_CUBE_MODEL_PATH)

	if IsNil(modelNode) then
		return false
	end

	modelNode.gameObject:SetActiveEx(active)

	return true
end

function ClientFertilityCubeEntity:setCubePresentationActive(active)
	local modelSkeletonView = self.eModel and self.eModel.modelSkeletonView

	if not modelSkeletonView then
		return false
	end

	local skeletonRoot = modelSkeletonView.skeletonRoot

	if IsNil(skeletonRoot) then
		return false
	end

	skeletonRoot.gameObject:SetActiveEx(active)

	return true
end

function ClientFertilityCubeEntity:onModelRefreshed()
	self._cubeRendererInitializationPendingVersion = nil

	local targetLayer = self._cubeVisible == true and (self._presentationLayer or ClientConst.LayerDefine.LAYER_CUTSCENE) or ClientConst.LayerDefine.LAYER_DEFAULT

	self:setModelLayer(targetLayer)
	ClientFertilityCubeEntity.super.onModelRefreshed(self)
	self:_ensureDynamicCubeLoad(self._dynamicCubeLoadVersion)
end

function ClientFertilityCubeEntity:_ensureDynamicCubeLoad(loadVersion)
	if self.destroyed or loadVersion ~= self._dynamicCubeLoadVersion then
		return
	end

	if self._cubeRendererInitializationPendingVersion == loadVersion or self._cubeModelReady or self._dynamicCubeLoader or not IsNil(self._dynamicCubeModel) then
		return
	end

	if self._useBuiltInShinyCubeModel then
		if self:_setBuiltInShinyCubeModelActive(true) then
			self:_notifyCubeModelReady()
		end

		return
	end

	self:_setBuiltInShinyCubeModelActive(false)

	local prefabResID = self._dynamicCubePrefabResID
	local boneNode = self:getCubeBoneTransform()

	if not prefabResID or prefabResID == "" then
		return
	end

	if IsNil(boneNode) then
		return
	end

	self:_loadDynamicCubeModel(loadVersion)
end

function ClientFertilityCubeEntity:_captureDynamicCubeRuntimeState(go)
	local UNITY_TRANSFORM_TYPE = typeof(CS.UnityEngine.Transform)
	local UNITY_ANIMATOR_TYPE = typeof(CS.UnityEngine.Animator)
	local UNITY_RIGIDBODY_TYPE = typeof(CS.UnityEngine.Rigidbody)
	local UNITY_COLLIDER_TYPE = typeof(CS.UnityEngine.Collider)
	local UNITY_MONO_BEHAVIOUR_TYPE = typeof(CS.UnityEngine.MonoBehaviour)
	local CUBE_THROW_COMPONENT_TYPES = {
		typeof(CS.FunPlus.WorldX.FlowCanvas.WxFlowScriptController),
		typeof(CS.NodeCanvas.Framework.Blackboard),
		typeof(CS.FunPlus.WorldX.GameApp.Capture.CatchBall)
	}
	local state = {
		rootComponents = {},
		animators = {},
		rigidbodies = {},
		colliders = {},
		layers = {}
	}
	local allowedRootComponents = {}

	for _, componentType in ipairs(CUBE_THROW_COMPONENT_TYPES) do
		local component = go:GetComponent(componentType)

		if IsNil(component) then
			return nil
		end

		allowedRootComponents[#allowedRootComponents + 1] = component
		state.rootComponents[#state.rootComponents + 1] = {
			component = component,
			enabled = component.enabled
		}
	end

	local rootBehaviours = go:GetComponents(UNITY_MONO_BEHAVIOUR_TYPE)

	for i = 0, rootBehaviours.Length - 1 do
		local component = rootBehaviours[i]
		local isAllowed = false

		for _, allowedComponent in ipairs(allowedRootComponents) do
			if component == allowedComponent then
				isAllowed = true

				break
			end
		end

		if not IsNil(component) and not isAllowed then
			return nil
		end
	end

	local animators = go:GetComponentsInChildren(UNITY_ANIMATOR_TYPE, true)

	for i = 0, animators.Length - 1 do
		local component = animators[i]

		if not IsNil(component) then
			state.animators[#state.animators + 1] = {
				component = component,
				enabled = component.enabled
			}
		end
	end

	local rigidbodies = go:GetComponentsInChildren(UNITY_RIGIDBODY_TYPE, true)

	for i = 0, rigidbodies.Length - 1 do
		local component = rigidbodies[i]

		if not IsNil(component) then
			state.rigidbodies[#state.rigidbodies + 1] = {
				component = component,
				isKinematic = component.isKinematic,
				useGravity = component.useGravity
			}
		end
	end

	local colliders = go:GetComponentsInChildren(UNITY_COLLIDER_TYPE, true)

	for i = 0, colliders.Length - 1 do
		local component = colliders[i]

		if not IsNil(component) then
			state.colliders[#state.colliders + 1] = {
				component = component,
				enabled = component.enabled
			}
		end
	end

	local transforms = go:GetComponentsInChildren(UNITY_TRANSFORM_TYPE, true)

	for i = 0, transforms.Length - 1 do
		local transform = transforms[i]

		if not IsNil(transform) then
			state.layers[#state.layers + 1] = {
				gameObject = transform.gameObject,
				layer = transform.gameObject.layer
			}
		end
	end

	return state
end

function ClientFertilityCubeEntity:_disableDynamicCubeRuntimeState(state)
	for _, item in ipairs(state.rootComponents) do
		item.component.enabled = false
	end

	for _, item in ipairs(state.animators) do
		item.component.enabled = false
	end

	for _, item in ipairs(state.rigidbodies) do
		item.component.isKinematic = true
		item.component.useGravity = false
	end

	for _, item in ipairs(state.colliders) do
		item.component.enabled = false
	end
end

function ClientFertilityCubeEntity:_rejectDynamicCubeModel(loader)
	loader:clear()

	if self._dynamicCubeLoader == loader then
		self._dynamicCubeLoader = nil
	end
end

function ClientFertilityCubeEntity:_loadDynamicCubeModel(loadVersion)
	local prefabResID = self._dynamicCubePrefabResID
	local loader = ResLoader.new()

	self._dynamicCubeLoader = loader

	loader:load(prefabResID, function(go)
		local isStale = self.destroyed or loadVersion ~= self._dynamicCubeLoadVersion or self._dynamicCubeLoader ~= loader

		if isStale then
			loader:clear()

			return
		end

		if IsNil(go) then
			self:_rejectDynamicCubeModel(loader)

			return
		end

		go:SetActiveEx(false)

		local currentBoneNode = self:getCubeBoneTransform()

		if IsNil(currentBoneNode) then
			self:_rejectDynamicCubeModel(loader)

			return
		end

		local runtimeState = self:_captureDynamicCubeRuntimeState(go)

		if not runtimeState then
			self:_rejectDynamicCubeModel(loader)

			return
		end

		self:_disableDynamicCubeRuntimeState(runtimeState)
		go.transform:SetParent(currentBoneNode, false)
		go.transform:SetLocalPositionEx(0, 0, 0)
		self:_applyCubeSkeletonRotation()
		go.transform:SetLocalScaleEx(DYNAMIC_CUBE_MODEL_SCALE, DYNAMIC_CUBE_MODEL_SCALE, DYNAMIC_CUBE_MODEL_SCALE)

		self._dynamicCubeRuntimeState = runtimeState
		self._dynamicCubeModel = go

		self:_refreshDynamicCubePresentation()
		self:_notifyCubeModelReady()
	end)
end

function ClientFertilityCubeEntity:setCubeVisible(visible)
	self._cubeVisible = visible

	if self.eModel == nil then
		return
	end

	self.eModel.modelShaderView:SetVisibleByMaterial(visible)

	if self._cubeModelReady then
		self.eModel.modelModelView:SetSkeViewIsKinematic(true)
	end

	if not visible then
		self:setModelLayer(ClientConst.LayerDefine.LAYER_DEFAULT)
		self:hideEffect()
	else
		self:setModelLayer(self._presentationLayer)
		self:showEffect()
	end

	self:_refreshDynamicCubePresentation()
end

function ClientFertilityCubeEntity:playCubeEffect(fxKey, extraInfo)
	if not self.eModel then
		return
	end

	self._cubeFxLoadIds = self._cubeFxLoadIds or {}

	local fxId = self._cubeFxLoadIds[fxKey]

	if not fxId then
		local parentT = self.eModel.transform:Find("PlayerBody")

		if IsNil(parentT) then
			return
		end

		self._cubeFxLoadIds[fxKey] = self:playEffectOn(fxKey, extraInfo, parentT, true)
	end
end

function ClientFertilityCubeEntity:destroy()
	ClientFertilityCubeEntity.super.destroy(self)
end

function ClientFertilityCubeEntity:preDestroy()
	self._dynamicCubeLoadVersion = (self._dynamicCubeLoadVersion or 0) + 1

	self:stopCubeEffect()

	self.onSkeletonLoadedCallback = nil
	self._cubeRendererInitializationPendingVersion = nil
	self._cubeModelReadyCallback = nil

	self:_clearDynamicCubeModel()

	self._dynamicCubePrefabResID = nil
	self._useBuiltInShinyCubeModel = nil
	self._cubeItemId = nil

	ClientFertilityCubeEntity.super.preDestroy(self)
end

function ClientFertilityCubeEntity:stopCubeEffect()
	if self._cubeFxLoadIds and next(self._cubeFxLoadIds) then
		for _, fxId in pairs(self._cubeFxLoadIds) do
			self:stopEffectById(fxId)
		end
	end

	self._cubeFxLoadIds = nil
end

function ClientFertilityCubeEntity:playEnterShow()
	self:setAnimatorTrigger("Start")
end

function ClientVirtualComponents:playOutShow()
	return
end

function ClientVirtualComponents:tweenScaleCubeEntity(moveDelta)
	return
end

return ClientFertilityCubeEntity
