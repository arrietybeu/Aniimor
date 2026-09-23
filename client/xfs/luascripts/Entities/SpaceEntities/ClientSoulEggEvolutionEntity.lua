-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\ClientSoulEggEvolutionEntity.lua

local Class = require("Core.Framework.Class")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local ClientVirtualEntity = require("Entities.ClientVirtualEntity")
local ClientConst = require("Const.ClientConst")
local MessageName = require("Const.MessageName")
local ClientModelComponent = require("Entities.SpaceEntities.CommonComponent.ClientModelComponent")
local ClientAnimatorComponent = require("Entities.SpaceEntities.CommonComponent.ClientAnimatorComponent")
local EnvObjData = require("Data.envobj_data")
local SoulEggEvolutionConst = require("Common.Const.EvolutionConst").SoulEggEvolution
local AddressDataConst = require("Const.AddressDataConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ResLoader = require("GameApp.ResLoad.ResLoader")
local PetFertilityConst = require("Const.PetFertilityConst")
local ID_EVO_SCENE_MOVE_MODEL = "evoSceneMoveModel"
local SOUL_EGG_PREFAB_ROOT_PATH = "SoulEggShellRoot"
local SOUL_EGG_BONE_PATH = SOUL_EGG_PREFAB_ROOT_PATH .. "/Bone_Root/Bone001"
local BUILT_IN_SOUL_EGG_MODEL_PATH = SOUL_EGG_PREFAB_ROOT_PATH .. "/M_Item_ParmonEgg_General_560331"
local ClientSoulEggEvolutionEntity = Class.Class("ClientSoulEggEvolutionEntity", ClientVirtualEntity)
local ClientVirtualComponents = {
	ClientModelComponent,
	ClientAnimatorComponent
}

Class.AddComponents(ClientSoulEggEvolutionEntity, ClientVirtualComponents)

function ClientSoulEggEvolutionEntity:_clearDynamicEggModel()
	if self._dynamicEggLoader then
		self._dynamicEggLoader:destroy()

		self._dynamicEggLoader = nil
	end

	self._dynamicEggModel = nil
end

function ClientSoulEggEvolutionEntity:_setDynamicEggModelLayer(layer)
	local go = self._dynamicEggModel

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

function ClientSoulEggEvolutionEntity:_refreshDynamicEggPresentation()
	local go = self._dynamicEggModel

	if IsNil(go) then
		return
	end

	local visible = self._evolutionVisible ~= false
	local layer = visible and (self._presentationLayer or ClientConst.LayerDefine.LAYER_CUTSCENE) or ClientConst.LayerDefine.LAYER_DEFAULT

	self:_setDynamicEggModelLayer(layer)
	go:SetActiveEx(visible)
end

function ClientSoulEggEvolutionEntity:_notifySoulEggModelReady()
	if self.destroyed or self._soulEggModelReady then
		return
	end

	self._soulEggModelReady = true

	local callback = self._soulEggModelReadyCallback

	self._soulEggModelReadyCallback = nil

	if callback then
		callback(self)
	end
end

function ClientSoulEggEvolutionEntity:setSoulEggAvatar(info, presentationOptions)
	self._presentationLayer = presentationOptions and presentationOptions.targetLayer or ClientConst.LayerDefine.LAYER_CUTSCENE
	self._soulEggModelReady = false
	self._soulEggModelReadyCallback = presentationOptions and presentationOptions.onModelReady
	self.inSoulEggSystem = info and info.inSoulEggSystem
	self._evolutionVisible = true
	self._dynamicEggLoadVersion = (self._dynamicEggLoadVersion or 0) + 1

	local loadVersion = self._dynamicEggLoadVersion

	self:_clearDynamicEggModel()

	local templateId = info and info.templateId
	local soulEggData = templateId and EnvObjData[templateId]
	local dynamicPrefabResID = info and info.prefabResID

	if type(dynamicPrefabResID) ~= "string" or dynamicPrefabResID == "" then
		dynamicPrefabResID = soulEggData and soulEggData.prefabResID
	end

	if type(dynamicPrefabResID) ~= "string" or dynamicPrefabResID == "" then
		dynamicPrefabResID = PetFertilityConst.fallbackEggResId
	end

	self._dynamicEggPrefabResID = dynamicPrefabResID
	self._dynamicEggRotX = soulEggData and soulEggData.petHatchUISceneRotX

	if not dynamicPrefabResID or dynamicPrefabResID == "" then
		return
	end

	local modelConfigData = soulEggData or {}

	self:setConfigData(modelConfigData)

	local modelView = self.eModel.modelModelView
	local ClientModelUtils = require("Utils.ClientModelUtils")
	local extraInfo = {
		prefabResID = AddressDataConst.NEW_UI_INCUBATOR_EGG_PREFAB_RES
	}

	ClientModelUtils.applyModelAppearance(modelView.modelInfo, modelConfigData, extraInfo)
	modelView:RefreshModels()
	self:setModelLayer(self._presentationLayer)
	self:refreshModelScale()
	self:_ensureSoulEggModelLoad(loadVersion)
end

function ClientSoulEggEvolutionEntity:getSoulEggPresentationRootTransform()
	if not self.eModel or not self.eModel.modelSkeletonView then
		return nil
	end

	local skeletonRoot = self.eModel.modelSkeletonView.skeletonRoot

	if IsNil(skeletonRoot) then
		return nil
	end

	return skeletonRoot
end

function ClientSoulEggEvolutionEntity:_applySoulEggPresentationTransform()
	local presentationRoot = self:getSoulEggPresentationRootTransform()

	if IsNil(presentationRoot) then
		return false
	end

	local transformConfig = PetFertilityConst.ChooseCubeggTransConfigs
	local localPosX, localPosY, localPosZ = transformConfig.localPos[1], transformConfig.localPos[2], transformConfig.localPos[3]
	local localScale = transformConfig.localScale

	presentationRoot:SetLocalPositionEx(localPosX, localPosY, localPosZ)
	presentationRoot:SetLocalScaleEx(localScale, localScale, localScale)

	return true
end

function ClientSoulEggEvolutionEntity:getSoulEggBoneTransform()
	if not self.eModel or not self.eModel.modelSkeletonView then
		return nil
	end

	local skeletonRoot = self.eModel.modelSkeletonView.skeletonRoot

	if IsNil(skeletonRoot) then
		return nil
	end

	return skeletonRoot:Find(SOUL_EGG_BONE_PATH)
end

function ClientSoulEggEvolutionEntity:_setBuiltInSoulEggModelActive(active)
	if not self.eModel or not self.eModel.modelSkeletonView then
		return false
	end

	local skeletonRoot = self.eModel.modelSkeletonView.skeletonRoot

	if IsNil(skeletonRoot) then
		return false
	end

	local modelNode = skeletonRoot:Find(BUILT_IN_SOUL_EGG_MODEL_PATH)

	if IsNil(modelNode) then
		return false
	end

	modelNode.gameObject:SetActiveEx(active)

	return true
end

function ClientSoulEggEvolutionEntity:onModelRefreshed()
	local targetLayer = self._evolutionVisible == false and ClientConst.LayerDefine.LAYER_DEFAULT or self._presentationLayer or ClientConst.LayerDefine.LAYER_CUTSCENE

	self:setModelLayer(targetLayer)
	facade:SendMessageCommand(MessageName.ON_MODEL_REFRESHED, self.id)
	self:_ensureSoulEggModelLoad(self._dynamicEggLoadVersion)
end

function ClientSoulEggEvolutionEntity:_ensureSoulEggModelLoad(loadVersion)
	if self.destroyed or loadVersion ~= self._dynamicEggLoadVersion then
		return
	end

	if not self:_applySoulEggPresentationTransform() then
		return
	end

	self:_setBuiltInSoulEggModelActive(false)

	if self._soulEggModelReady or self._dynamicEggLoader or not IsNil(self._dynamicEggModel) then
		return
	end

	local prefabResID = self._dynamicEggPrefabResID

	if not prefabResID or prefabResID == "" then
		return
	end

	if IsNil(self:getSoulEggBoneTransform()) then
		return
	end

	self:_loadDynamicEggModel(loadVersion)
end

function ClientSoulEggEvolutionEntity:_loadDynamicEggModel(loadVersion)
	local prefabResID = self._dynamicEggPrefabResID
	local boneNode = self:getSoulEggBoneTransform()

	if not prefabResID or prefabResID == "" or IsNil(boneNode) then
		return
	end

	local loader = ResLoader.new()

	self._dynamicEggLoader = loader

	loader:load(prefabResID, function(go)
		local isStale = self.destroyed or loadVersion ~= self._dynamicEggLoadVersion or self._dynamicEggLoader ~= loader

		if isStale then
			loader:clear()

			return
		end

		if IsNil(go) then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				self.logger:error("%s dynamic soul egg model load failed, prefabResID=%s, templateId=%s, loadVersion=%s", self:repr(), tostring(prefabResID), tostring(self.templateId), tostring(loadVersion))
			end

			loader:clear()

			if self._dynamicEggLoader == loader then
				self._dynamicEggLoader = nil
			end

			return
		end

		local currentBoneNode = self:getSoulEggBoneTransform()

		if IsNil(currentBoneNode) then
			loader:clear()

			if self._dynamicEggLoader == loader then
				self._dynamicEggLoader = nil
			end

			return
		end

		go.transform:SetParent(currentBoneNode, false)
		go.transform:SetLocalPositionEx(0, 0, 0)

		local rot = PetFertilityConst.ChooseCubeggTransConfigs.localRot

		go.transform:SetLocalEulerAnglesEx(self._dynamicEggRotX and self._dynamicEggRotX or rot[1], rot[2], rot[3])
		go.transform:SetLocalScaleEx(1, 1, 1)

		self._dynamicEggModel = go

		self:_refreshDynamicEggPresentation()
		self:_notifySoulEggModelReady()
	end)
end

function ClientSoulEggEvolutionEntity:setEvolutionVisible(visible)
	self._evolutionVisible = visible

	if self.eModel == nil then
		return
	end

	self.eModel.modelShaderView:SetVisibleByMaterial(visible)

	if not visible then
		self:setModelLayer(ClientConst.LayerDefine.LAYER_DEFAULT)
		self:hideEffect()
	else
		self:setModelLayer(self._presentationLayer)
		self:showEffect()
	end

	self:_refreshDynamicEggPresentation()
end

function ClientSoulEggEvolutionEntity:setCameraOffset(offsetY)
	local cameraOffset = Vector3.New(0, offsetY, 0)

	pg.game.camera:setCameraOffset(cameraOffset)
end

function ClientSoulEggEvolutionEntity:getHeight()
	return 0.3
end

function ClientSoulEggEvolutionEntity:playDelayEffect(time, effectName)
	self:addTimer(time, function()
		self:playEffect(effectName)
	end)
end

function ClientSoulEggEvolutionEntity:hideDelay(time)
	self:addTimer(time, function()
		self:setEvolutionVisible(false)
	end)
end

function ClientSoulEggEvolutionEntity:playEnterShow()
	self:setAnimatorTrigger("Long")
end

function ClientSoulEggEvolutionEntity:playExitShow()
	self:addTimer(0.4, function()
		self:setAnimatorTrigger("Fast")
	end)
end

function ClientSoulEggEvolutionEntity:playEggBrokenEffect(index)
	if index == 0 and not self._eggBrokenEffectId then
		local extraInfo = {
			layer = self._presentationLayer
		}
		local parentT = self:getChooseCubeEffectParentTransform()

		if IsNil(parentT) then
			return
		end

		self._eggBrokenEffectId = self:playEffectOn(SoulEggEvolutionConst.EggBrokenEffectKey, extraInfo, parentT, true)

		local eggBrokenEffectTransform = self:getEffectTransform(self._eggBrokenEffectId)

		if eggBrokenEffectTransform then
			local effectLevelSetComop = eggBrokenEffectTransform:GetComponent("EffectLevelSetting")

			if effectLevelSetComop then
				effectLevelSetComop:IgnoreUnLoad()
				effectLevelSetComop:SetEnableUpdate(false)
			end
		end

		if not IsNil(eggBrokenEffectTransform) then
			self._eggBrokenGoList = {}

			for i = 1, 4 do
				local go = eggBrokenEffectTransform:Find("Eff_UI_SoulEgg_Open/All/0" .. i).gameObject

				if not IsNil(go) then
					go:SetActiveEx(false)
					table.insert(self._eggBrokenGoList, go)
				end
			end
		end
	elseif self._eggBrokenEffectId then
		local go = self._eggBrokenGoList[index]

		if not IsNil(go) then
			go:SetActiveEx(true)
		end

		self:setAnimatorTrigger("Shake")
	end
end

function ClientSoulEggEvolutionEntity:getChooseCubeEffectParentTransform()
	return self:getSoulEggBoneTransform()
end

function ClientSoulEggEvolutionEntity:playChooseCubeEffect(fxKey, extraInfo, parentT, loadedCb, catchBallRootTs)
	self._chooseCubeFxIds = self._chooseCubeFxIds or {}

	local fxId = self._chooseCubeFxIds[fxKey]

	if fxId == 0 then
		self._chooseCubeFxIds[fxKey] = nil
		fxId = nil
	end

	if not fxId then
		parentT = parentT or self:getChooseCubeEffectParentTransform()

		if IsNil(parentT) then
			return nil
		end

		fxId = self:playEffectOn(fxKey, extraInfo, parentT, true)

		if not fxId or fxId == 0 then
			return nil
		end

		self._chooseCubeFxIds[fxKey] = fxId

		if loadedCb then
			local fxTs = self:getEffectTransform(self._chooseCubeFxIds[fxKey])

			loadedCb(fxTs, parentT, catchBallRootTs)
		end
	end

	return fxId
end

function ClientSoulEggEvolutionEntity:stopEggBrokenEffect()
	if self._eggBrokenEffectId then
		self:stopEffectById(self._eggBrokenEffectId)

		self._eggBrokenEffectId = nil
	end
end

function ClientSoulEggEvolutionEntity:destroy()
	ClientSoulEggEvolutionEntity.super.destroy(self)
end

function ClientSoulEggEvolutionEntity:preDestroy()
	self._dynamicEggLoadVersion = (self._dynamicEggLoadVersion or 0) + 1
	self._soulEggModelReadyCallback = nil

	self:_clearDynamicEggModel()

	self._dynamicEggPrefabResID = nil
	self._dynamicEggRotX = nil

	if self._eggBrokenEffectId then
		self:stopEffectById(self._eggBrokenEffectId)

		self._eggBrokenEffectId = nil
	end

	self._eggBrokenGoList = nil

	self:stopChooseCubeEffect()
	ClientSoulEggEvolutionEntity.super.preDestroy(self)
end

function ClientSoulEggEvolutionEntity:stopChooseCubeEffect()
	if self._chooseCubeFxIds and next(self._chooseCubeFxIds) then
		for _, fxId in pairs(self._chooseCubeFxIds) do
			self:stopEffectById(fxId)
		end
	end

	self._chooseCubeFxIds = nil
end

function ClientSoulEggEvolutionEntity:tweenMove(moveDelta)
	if not moveDelta then
		return
	end

	local eModel = self.eModel

	if not eModel then
		return
	end

	local oriPosX, oriPosY, oriPosZ = eModel:GetTransformPosition()
	local targetPos = Vector3.New(oriPosX + moveDelta.x, oriPosY + moveDelta.y, oriPosZ + moveDelta.z)

	DoTweenAnimMgr.GlobalMove(self.actorId, LuaUIUtils.TweenId(ID_EVO_SCENE_MOVE_MODEL), targetPos, 0.75, 0, CS.DG.Tweening.Ease.__CastFrom(6), nil, nil, false)
end

return ClientSoulEggEvolutionEntity
