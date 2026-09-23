-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Scenes\\UIScenes\\GrowGiftSelectScene.lua

local ClientUtils = require("Utils.ClientUtils")
local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local UISceneBase = require("GameApp.UIScene.UISceneBase")
local ClientConst = require("Const.ClientConst")
local Const = require("Common.Const.Const")
local ClientAbilityConst = require("Const.ClientAbilityConst")
local ClientModelUtils = require("Utils.ClientModelUtils")
local ClientSimpleVirtualEntity = require("Entities.ClientSimpleVirtualEntity")
local ActivityConst = require("Common.Const.ActivityConst")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local PetResearchUtils = require("Guis.Utils.PetResearchUtils")
local AddressDataConst = require("Const.AddressDataConst")
local UIScenePreviewController = require("GameApp.Scenes.UIScenes.UIScenePreviewController")
local UIMirrorEntity = CS.FunPlus.WorldX.GUIS.Panels.UIMirrorEntity
local PetProtoTypeData = require("Data.pet_prototype_data")
local EventGrowthGiftData = require("Data.event_growth_gitf_data")
local UI_SELECT_MODEL = AddressDataConst.UI_SELECT_MODEL
local UI_SELECT_MODEL_2 = AddressDataConst.UI_SELECT_MODEL_2
local GrowGiftSelectScene = Class.LightClass("GrowGiftSelectScene", UISceneBase)

GrowGiftSelectScene.CAMERA = {
	PET = "pet"
}
GrowGiftSelectScene.PET_CONFIG = {
	minZoom = 2.5,
	scale = 1,
	defaultY = 0.5,
	defaultZoom = 10,
	maxZoomOffsetY = 0.9,
	maxZoom = 10,
	minZoomOffsetY = {
		0.2,
		1.2
	}
}

function GrowGiftSelectScene:getSimpleEnt(templateId)
	local configData = PetProtoTypeData[templateId]
	local ent = ClientSimpleVirtualEntity.new()

	ent:setConfigData(configData)

	local initInfo = {
		isIgnoreEffectLod = true,
		templateId = templateId
	}

	ent:init(initInfo)
	ent:postInit(initInfo)
	ent:start()
	ent:setModelLayer(ClientConst.LayerDefine.LAYER_UI_SCENE)

	return ent
end

function GrowGiftSelectScene:onStart()
	self.rootTransform = self.scene.transform:Find("Global")
	self.objectReference = self.rootTransform:GetComponent("ObjectReference")
	self.camera = self.objectReference:GetRefValue("camera")
	self.uICameraCamera = self.camera
	self.petsParentTransform = self.objectReference:GetRefValue("petsParentTransform")
	self.mirrorPetsParentTransform = self.objectReference:GetRefValue("mirrorPetsParentTransform")
	self.previewSceneController = UIScenePreviewController.new(self)

	self:init()
	pg.game.input:setEnabledViewCtrl(false, ClientConst.ViewControl.APPEARANCE)
	self:initCameraModes()

	self.m_sceneCreated = true
end

function GrowGiftSelectScene:isCreated()
	return self.m_sceneCreated
end

function GrowGiftSelectScene:onDestroy()
	self:destroyPreviewController()
	pg.game.input:setEnabledViewCtrl(true, ClientConst.ViewControl.APPEARANCE)
	self:destroyAllEnt()

	self.m_sceneCreated = false
end

function GrowGiftSelectScene:destroyAllEnt()
	for _, ent in pairs(self.entPoolTable or EMPTY_TABLE) do
		ClientUtils.safeDestroy(ent)
	end

	for _, ent in pairs(self.mirrorEntPoolTable or EMPTY_TABLE) do
		ClientUtils.safeDestroy(ent)
	end

	self.entPoolTable = {}
	self.mirrorEntPoolTable = {}
	self.m_CoupleCacheMap = {}
end

function GrowGiftSelectScene:init()
	self.outPos = Vector3(0, 9999, 0)
	self.entPoolTable = {}
	self.mirrorEntPoolTable = {}
	self.m_CoupleCacheMap = {}
	self.displayRequestId = 0
end

function GrowGiftSelectScene:getEntById(templateId)
	if not templateId then
		return nil, false
	end

	if self.entPoolTable[templateId] then
		return self.entPoolTable[templateId], false
	end

	local ent = self:getSimpleEnt(templateId)

	self.entPoolTable[templateId] = ent

	return ent, true
end

function GrowGiftSelectScene:getMirrorEntById(templateId)
	if not templateId then
		return nil, false
	end

	if self.mirrorEntPoolTable[templateId] then
		return self.mirrorEntPoolTable[templateId], false
	end

	local ent = self:getSimpleEnt(templateId)

	self.mirrorEntPoolTable[templateId] = ent

	return ent, true
end

function GrowGiftSelectScene:getCurEntity()
	if not self.curShowPetTemplateId then
		return nil
	end

	return self.entPoolTable and self.entPoolTable[self.curShowPetTemplateId]
end

function GrowGiftSelectScene:getPreviewDefaultModeName()
	return self.CAMERA.PET
end

function GrowGiftSelectScene:getPetLocalPosition()
	local actData = ActivityUtils.getActivityData(pg.me, ActivityConst.EventType.GrowthGift)
	local phase = actData and actData.activityBase and actData.activityBase.activityPhase
	local actCfg = phase and EventGrowthGiftData[phase]
	local petPos = actCfg and actCfg.petPos

	if not petPos then
		return Vector3.zero
	end

	return Vector3(petPos[1] or 0, petPos[2] or 0, petPos[3] or 0)
end

function GrowGiftSelectScene:rotatePreviewEntity(deltaAngle)
	local ent = self:getCurEntity()

	if ent and ent.eModel then
		ent.eModel:RotateAroundTransform(deltaAngle)
	end

	local mirrorEnt = self.mirrorEntPoolTable and self.mirrorEntPoolTable[self.curShowPetTemplateId]

	if mirrorEnt and mirrorEnt.eModel then
		mirrorEnt.eModel:RotateAroundTransform(deltaAngle)
	end
end

function GrowGiftSelectScene:selectPetEvolve(templateId)
	local ent = self.entPoolTable[templateId]

	if ent then
		local shaderView = ent.eModel.modelShaderView

		self:clearSelectPetEvolve()

		if shaderView then
			shaderView:ChangeEffectMaterial({
				UI_SELECT_MODEL,
				UI_SELECT_MODEL_2
			})

			self.selectedEnt = ent
		end
	end
end

function GrowGiftSelectScene:selectMirrorPetEvolve(templateId)
	local ent = self.mirrorEntPoolTable[templateId]

	if ent then
		local shaderView = ent.eModel.modelShaderView

		self:clearSelectPetEvolve()

		if shaderView then
			shaderView:ChangeEffectMaterial({
				UI_SELECT_MODEL,
				UI_SELECT_MODEL_2
			})

			self.selectedEnt = ent
		end
	end
end

function GrowGiftSelectScene:clearSelectPetEvolve()
	if self.selectedEnt then
		local eModel = self.selectedEnt.eModel
		local shaderView = eModel and eModel.modelShaderView

		if shaderView then
			shaderView:ResetMaterial()
		end
	end

	self.selectedEnt = nil
end

function GrowGiftSelectScene:getAppearanceCacheKey(templateId, label, gender, modelNeedBones)
	return string.format("%s_%s_%s_%s", templateId or 0, label or 0, gender or 0, ToBool(modelNeedBones) and 1 or 0)
end

function GrowGiftSelectScene:refreshPetModelAppearance(templateId, ent, label, gender, modelNeedBones, onRefreshFinished)
	if not ent then
		return
	end

	local eModel = ent.eModel

	if eModel then
		local appearanceKey = self:getAppearanceCacheKey(templateId, label, gender, modelNeedBones)

		if ent.growGiftAppearanceKey == appearanceKey then
			if onRefreshFinished then
				onRefreshFinished()
			end

			return
		end

		local petData = PetProtoTypeData[templateId]
		local modelView = eModel.modelModelView
		local researchContentData = PetResearchUtils.getPetResearchContent(templateId)
		local extraData

		if gender then
			extraData = ClientModelUtils.getModelExtraInfo(petData, label or 0, gender, false)
		else
			extraData = ClientModelUtils.getModelExtraInfo(petData, label or 0, researchContentData.gender or 0, false)
		end

		extraData.modelNeedBones = ToBool(modelNeedBones)

		ClientModelUtils.applyModelAppearance(modelView.modelInfo, petData, extraData)

		eModel.RootRotationScale = Vector3(0, 0, 0)

		ClientModelUtils.applyAnimController(ent, eModel, petData)

		function modelView.luaOnModelRefreshFinshed()
			ent.growGiftAppearanceKey = appearanceKey

			if onRefreshFinished then
				onRefreshFinished()
			end
		end

		modelView:RefreshModels()

		local shaderView = eModel.modelShaderView

		if shaderView then
			shaderView:SetMultiPassForce32Layer(true, ClientAbilityConst.MULTI_PASS_LAYER)
		end

		ent:setLodTickEnable(Const.LOD_TICK_KEY.DEFAULT, false)
		ent:setRendererLod(0)
	elseif onRefreshFinished then
		onRefreshFinished()
	end
end

function GrowGiftSelectScene:setSceneDisplayPet(petId)
	local petInfo = pg.me:getPetInfo(petId)

	if not petInfo then
		return
	end

	self.curShowPetTemplateId = petInfo.templateId
	self.curShowPetEntId = petInfo.id
	self.curShowPetLabel = petInfo.label or 0
	self.curShowPetGender = petInfo.gender or 0
	self.petId = petId

	self:setPetTransform()
end

function GrowGiftSelectScene:setSceneDisplayTemplate(templateId, label, gender)
	if not templateId then
		return
	end

	self.curShowPetTemplateId = templateId
	self.curShowPetEntId = nil
	self.curShowPetLabel = label or 0
	self.curShowPetGender = gender or 0
	self.petId = nil

	self:setPetTransform()
end

function GrowGiftSelectScene:setPetTransform()
	self.displayRequestId = self.displayRequestId + 1

	local requestId = self.displayRequestId

	self:recycleOtherEnts(true)

	local label = self.curShowPetLabel or 0
	local gender = self.curShowPetGender or 0
	local petLocalPosition = self:getPetLocalPosition()

	if self.m_CoupleCacheMap then
		self.m_CoupleCacheMap[self.curShowPetTemplateId] = nil
	end

	local ent = self:getEntById(self.curShowPetTemplateId)
	local eModel = ent and ent.eModel

	if eModel then
		self:selectPetEvolve(self.curShowPetTemplateId)
		self:setPetActive(ent, false)
		eModel:SetTransformParent(self.petsParentTransform, false)
		eModel:SetTransformLocalRotation(0, 0, 0, 1)
		eModel:SetTransformLocalScale()
		eModel:PlayDefaultAnimation(Const.COMPONENT_IDX_PLAYABLE, true)

		local originModelView = eModel.modelModelView

		self:refreshPetModelAppearance(self.curShowPetTemplateId, ent, label, gender, true)

		if originModelView then
			function originModelView.luaOnModelRefreshFinshed()
				self:m_tryAddCoupleEntities()
			end
		end

		self:setPetActive(ent, true, petLocalPosition)
	end

	local mirrorEnt = self:getMirrorEntById(self.curShowPetTemplateId)
	local mirrorEModel = mirrorEnt and mirrorEnt.eModel

	if mirrorEModel then
		self:selectMirrorPetEvolve(self.curShowPetTemplateId)
		self:setPetActive(mirrorEnt, false)
		mirrorEModel:SetTransformParent(self.mirrorPetsParentTransform, false)
		mirrorEModel:SetTransformLocalRotation(0, 0, 0, 1)
		mirrorEModel:SetTransformLocalScale()
		mirrorEModel:PlayDefaultAnimation(Const.COMPONENT_IDX_PLAYABLE, true)

		local mirrorModelView = mirrorEModel.modelModelView

		self:refreshPetModelAppearance(self.curShowPetTemplateId, mirrorEnt, label, gender, true)

		if mirrorModelView then
			function mirrorModelView.luaOnModelRefreshFinshed()
				self:m_tryAddCoupleEntities()
			end
		end

		self:setPetActive(mirrorEnt, true, petLocalPosition)
	end

	self:m_tryAddCoupleEntities()
end

function GrowGiftSelectScene:m_tryAddCoupleEntities()
	self.m_CoupleCacheMap = self.m_CoupleCacheMap or {}

	for k, v in pairs(self.entPoolTable) do
		if v and not self.m_CoupleCacheMap[k] then
			local mirrorEnt = self.mirrorEntPoolTable and self.mirrorEntPoolTable[k]

			if mirrorEnt then
				local oSkt = v.eModel and v.eModel.modelSkeletonView and v.eModel.modelSkeletonView.skeletonRoot
				local mSkt = mirrorEnt.eModel and mirrorEnt.eModel.modelSkeletonView and mirrorEnt.eModel.modelSkeletonView.skeletonRoot

				if oSkt and mSkt then
					UIMirrorEntity.Create(mirrorEnt.eModel.animator, v.eModel.animator)

					self.m_CoupleCacheMap[k] = true
				end
			end
		end
	end
end

function GrowGiftSelectScene:setPetRootActive(isActive)
	local localPos = isActive and Vector3(0.048, 0, 0.096) or self.outPos

	self.petsParentTransform.localPosition = localPos
	self.mirrorPetsParentTransform.localPosition = localPos
end

function GrowGiftSelectScene:playShinnyPreset(templateId, shinnyEffect)
	if not shinnyEffect then
		return
	end

	self:playShinnyPresetForEntTable(self.entPoolTable, templateId, shinnyEffect)
	self:playShinnyPresetForEntTable(self.mirrorEntPoolTable, templateId, shinnyEffect)
end

function GrowGiftSelectScene:playShinnyPresetForEntTable(entTable, templateId, shinnyEffect)
	local ent = entTable and entTable[templateId]
	local shaderView = ent and ent.eModel and ent.eModel.shaderView

	if shaderView then
		ClientEffectUtils.PlayPreset(ent, shinnyEffect, -1, false)
	end
end

function GrowGiftSelectScene:setPetActive(petEnt, isActive, activeLocalPosition)
	if petEnt and petEnt.eModel then
		petEnt:setModelVisible(ClientConst.MODEL_VISIBLE_KEY.UIScene, isActive)

		if isActive then
			if activeLocalPosition then
				petEnt.eModel:SetTransformLocalPosition(activeLocalPosition.x, activeLocalPosition.y, activeLocalPosition.z)
			else
				petEnt.eModel:SetTransformLocalPosition()
			end
		else
			petEnt.eModel:SetTransformLocalPosition(self.outPos.x, self.outPos.y, self.outPos.z)
		end
	end
end

function GrowGiftSelectScene:recycleOtherEnts(includeCurrent)
	for k, v in pairs(self.entPoolTable) do
		if v and (includeCurrent or k ~= self.curShowPetTemplateId) then
			v.eModel:SetTransformLocalScale(0, 0, 0)
			self:setPetActive(v, false)
		end
	end

	for k, v in pairs(self.mirrorEntPoolTable) do
		if v and (includeCurrent or k ~= self.curShowPetTemplateId) then
			v.eModel:SetTransformLocalScale(0, 0, 0)
			self:setPetActive(v, false)
		end
	end
end

return GrowGiftSelectScene
