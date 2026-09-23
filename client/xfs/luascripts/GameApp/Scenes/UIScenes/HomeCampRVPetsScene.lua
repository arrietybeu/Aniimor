-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Scenes\\UIScenes\\HomeCampRVPetsScene.lua

local ClientUtils = require("Utils.ClientUtils")
local EMPTY_TABLE = require("Core.Common.EmptyTable")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("HomeCampRVPetsScene")
local AudioConst = require("Const.AudioConst")
local DoTweenAnimMgr = DoTweenAnimMgr
local PetResearchUtils = require("Guis.Utils.PetResearchUtils")
local Utils = require("Common.Utils.Utils")
local PetConfigData = require("Data.pet_config_data")
local Const = require("Common.Const.Const")
local PetEvolveData = require("Data.pet_evolve_data")
local PetEvolveCameraPosData = require("Data.pet_evolve_camera_pos_data")
local PetPrototypeData = require("Data.pet_prototype_data")
local PetResearchUtilsCommon = require("Common.Utils.PetResearchUtils")
local AddressDataConst = require("Const.AddressDataConst")
local PetEthnicData = require("Data.pet_ethnic_group_data")
local SysConfigData = require("Data.sys_config_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientVirtualEntityUtils = require("Utils.ClientVirtualEntityUtils")
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")
local PetJewelryOssCache = require("Utils.PetJewelryOssCache")
local ClientConst = require("Const.ClientConst")
local UIConst = require("Const.UIConst")
local Class = require("Core.Framework.Class")
local UISceneBase = require("GameApp.UIScene.UISceneBase")
local PlayableConst = require("Common.Const.PlayableConst")
local TimerManager = require("Core.Timer.TimerManager")
local ClientAbilityConst = require("Const.ClientAbilityConst")
local HomeCampRVPetsScene = Class.LightClass("HomeCampRVPetsScene", UISceneBase)
local Time = require("Core.Common.Time")
local PetManagementUtils = require("Utils.PetManagementUtils")
local HomelandConfigData = require("Data.homeland_config_data")
local DEF_HOME_CAMP_PET_UISCALE = 0.8
local HOME_CAMP_PET_X_SPACING = 0
local HOME_CAMP_PET_INIT_POS_X = 0
local MOVECAMERA_SECOND = 0.1

function HomeCampRVPetsScene:onStart()
	self.root = self.scene.transform:Find("Global")
	self.objectReference = self.root:GetComponent("ObjectReference")
	self.uICameraCamera = self.objectReference:GetRefValue("uICameraCamera")
	self.entPoolTransform = self.objectReference:GetRefValue("entPoolTransform")
	self.petsParentTransform = self.objectReference:GetRefValue("petsParentTransform")
	self.vCamerasParentTransform = self.objectReference:GetRefValue("vCamerasParentTransform")
	self.tent01Transform = self.objectReference:GetRefValue("tent01Transform")
	self.tent02Transform = self.objectReference:GetRefValue("tent02Transform")
	self.petTent01Transform = self.objectReference:GetRefValue("petTent01Transform")
	self.petTent02Transform = self.objectReference:GetRefValue("petTent02Transform")
	self.newPetsParentTransform = self.objectReference:GetRefValue("newPetsParentTransform")
	self.campPetsParentTransform = self.objectReference:GetRefValue("campPetsParentTransform")
	self.campPet1ParentTransform = self.objectReference:GetRefValue("campPet1ParentTransform")
	self.campPet2ParentTransform = self.objectReference:GetRefValue("campPet2ParentTransform")
	self.campPet3ParentTransform = self.objectReference:GetRefValue("campPet3ParentTransform")
	self.dispatchPetsParentTransform = self.objectReference:GetRefValue("dispatchPetsParentTransform")
	self.dispatchPet1ParentTransform = self.objectReference:GetRefValue("dispatchPet1ParentTransform")
	self.dispatchPet2ParentTransform = self.objectReference:GetRefValue("dispatchPet2ParentTransform")
	self.dispatchPet3ParentTransform = self.objectReference:GetRefValue("dispatchPet3ParentTransform")
	self.petShdow1 = self.objectReference:GetRefValue("petShdow1")
	self.petShdow2 = self.objectReference:GetRefValue("petShdow2")
	self.petShdow3 = self.objectReference:GetRefValue("petShdow3")

	local objectReference = self.objectReference

	self.petsShadowRoot01Transform = objectReference:GetRefValue("petsShadowRoot01Transform")
	self.petsShadowRoot02Transform = objectReference:GetRefValue("petsShadowRoot02Transform")
	self.petsRootTransform = objectReference:GetRefValue("petsRootTransform")
	self.petLeft01Transform = objectReference:GetRefValue("petLeft01Transform")
	self.petMid01Transform = objectReference:GetRefValue("petMid01Transform")
	self.petRight01Transform = objectReference:GetRefValue("petRight01Transform")
	self.petLeft02Transform = objectReference:GetRefValue("petLeft02Transform")
	self.petMid02Transform = objectReference:GetRefValue("petMid02Transform")
	self.petRight02Transform = objectReference:GetRefValue("petRight02Transform")

	self:init()
	pg.global.cameraMgr:SetUISceneCamera(self.uICameraCamera)
	pg.game.camera:setUICameraObject(self.uICameraCamera)

	self.m_sceneCreated = true
end

function HomeCampRVPetsScene:isCreated()
	return self.m_sceneCreated
end

function HomeCampRVPetsScene:onDestroy()
	self:destroyAllEnt()
	pg.game.audio:playAmb(nil, AudioConst.BgmPriority.PetDetailScene)
end

function HomeCampRVPetsScene:init()
	self.entPoolTable = {}
	self.cameraGoDict = {}
	self.cameraPosDict = {}
	self.bgEnvGos = {}
	self.curShowPetEntIds = {}
	self.posY = 5000
	self.outPos = Vector3(0, 9999, 0)
	self.centerPos = Vector3(0, self.posY, 0)
	self.scene.transform.position = self.centerPos

	local cameraNames = {
		"VCameraCampMgr",
		"VCameraPetsMgr"
	}

	for index, cName in pairs(cameraNames) do
		local vc = self.vCamerasParentTransform:Find(cName):GetComponent("RefVirtualCameraBehavior")

		self.cameraGoDict[index] = vc.gameObject
		self.cameraPosDict[index] = vc.transform.localPosition

		self.cameraGoDict[index]:SetActiveEx(false)

		self.bgEnvGos[index] = self.bgEnvGos[index] or {}

		table.insert(self.bgEnvGos[index], self["tent0" .. index .. "Transform"].gameObject)
		table.insert(self.bgEnvGos[index], self["petsShadowRoot0" .. index .. "Transform"].gameObject)
	end

	local campMgrIndex = UIConst.HOME_CAMP_MANAGER_PAGE_TYPE.CampMgr + 1
	local dispatchMgrIndex = UIConst.HOME_CAMP_MANAGER_PAGE_TYPE.DispatchMgr + 1

	self.m_petShadowTsMap = {
		[campMgrIndex] = {
			self.petLeft01Transform,
			self.petMid01Transform,
			self.petRight01Transform
		},
		[dispatchMgrIndex] = {
			self.petLeft02Transform,
			self.petMid02Transform,
			self.petRight02Transform
		}
	}
end

function HomeCampRVPetsScene:getPetPreviewExtraData(templateId, petInfo)
	local petId = petInfo and petInfo.id

	return {
		applyAnimController = true,
		useTransmogScheme = true,
		modelNeedBones = true,
		canAttachEffs = true,
		configData = ClientVirtualEntityUtils.getPetUISceneConfig(templateId),
		petInfo = petInfo,
		isCreateEntUsePetId = petId ~= nil,
		petId = petId,
		realPetId = petId,
		clearJewelryInfo = petId == nil,
		transmogPetId = petId
	}
end

function HomeCampRVPetsScene:getSimpleEnt(templateId, petInfo)
	return PetManagementDataHelper.previewPetModel(templateId, self.entPoolTransform, function(ent)
		ent:setScaleNumber(1)
		ent.eModel:SetTransformLocalPosition()

		ent.modelNeedBones = true
	end, self:getPetPreviewExtraData(templateId, petInfo))
end

function HomeCampRVPetsScene:setSceneDisplayPetsDisplay(isShow)
	if self.newPetsParentTransform then
		self.newPetsParentTransform.gameObject:SetActiveEx(isShow)
	end
end

function HomeCampRVPetsScene:setSceneDisplayPets(pageId, petIds)
	petIds = petIds or {}

	local petsLen = #petIds

	self.curShowPetEntIds = self.curShowPetEntIds or {}

	local curShowPetsLen = #self.curShowPetEntIds
	local maxLen = math.max(curShowPetsLen, petsLen)
	local toRemoveEntIds = {}
	local toAddEntIds = {}

	for i = 1, maxLen do
		local petId = petIds[i] or 0
		local curShowPetEntId = self.curShowPetEntIds[i] or 0

		if petId ~= curShowPetEntId then
			if curShowPetEntId ~= 0 then
				table.insert(toRemoveEntIds, curShowPetEntId)
			end

			if petId ~= 0 then
				table.insert(toAddEntIds, petId)
			end
		end
	end

	self.curShowPetEntIds = petIds
	self.selectedPageIndex = pageId + 1

	if toRemoveEntIds and next(toRemoveEntIds) or toAddEntIds and next(toAddEntIds) then
		self:recycleOtherEnts(toRemoveEntIds)
		self:setPetTransform(toAddEntIds)
		self:tryMoveCameraToTarget()
	else
		self:setPetTransform(toAddEntIds)
	end
end

function HomeCampRVPetsScene:getEntById(petEntId, label, gender)
	if petEntId then
		if self.entPoolTable[petEntId] then
			return self.entPoolTable[petEntId], false
		else
			local petInfo = pg.me:getPetInfo(petEntId)

			if not petInfo then
				return
			end

			local ent = self:getSimpleEnt(petInfo.templateId, petInfo)
			local eModel = ent and ent.eModel

			if eModel then
				eModel:SetTransformLocalPosition()
				eModel:SetTransformLocalRotation(0, 0, 0, 1)
				eModel:SetTransformLocalScale(0, 0, 0)
			end

			self.entPoolTable[petEntId] = ent

			return ent, true
		end
	end
end

function HomeCampRVPetsScene:setPetTransform(toAddEntIds)
	local additiveXSpace = HOME_CAMP_PET_INIT_POS_X
	local modelScale = HomelandConfigData.HOME_CAMP_PET_UISCALE or DEF_HOME_CAMP_PET_UISCALE
	local preSBodySize = 0
	local preX = 0
	local shadowTsMap = self.m_petShadowTsMap and self.m_petShadowTsMap[self.selectedPageIndex]

	for i, petId in ipairs(self.curShowPetEntIds) do
		local petInfo = pg.me:getPetInfo(petId)
		local curShowPetTemplateId = petInfo.templateId
		local curShowPetEntId = petId
		local ent, isNew = self:getEntById(curShowPetEntId, petInfo.label or 0, petInfo.gender or 0)

		self:refreshPetModelAppearance(curShowPetTemplateId, ent, petInfo.label or 0, petInfo.gender or 0, petInfo)

		local eModel = ent and ent.eModel

		if eModel then
			if isNew then
				ent:setActive(ClientConst.MODEL_VISIBLE_KEY.UIScene, false)
				eModel:SetTransformParent(self.newPetsParentTransform, false)
				eModel:SetTransformLocalScale(0, 0, 0)
			end

			ent:setActive(ClientConst.MODEL_VISIBLE_KEY.UIScene, true)

			local localPos = shadowTsMap and shadowTsMap[i] and shadowTsMap[i].localPosition or Vector3.zero

			eModel:SetTransformLocalPosition(localPos.x, localPos.y, localPos.z)
			eModel:SetTransformLocalScale(modelScale, modelScale, modelScale)
			ent.eModel:PlayDefaultAnimation(Const.COMPONENT_IDX_PLAYABLE, true)
		end
	end

	local petsLen = #self.curShowPetEntIds

	for i, shadowTs in pairs(shadowTsMap or EMPTY_TABLE) do
		shadowTs.gameObject:SetActiveEx(i <= petsLen)
	end
end

function HomeCampRVPetsScene:refreshPetModelAppearance(templateId, ent, label, gender, petInfo)
	if not ent then
		return
	end

	local eModel = ent.eModel

	if eModel then
		local researchContentData = PetResearchUtils.getPetResearchContent(templateId)
		local extraData = self:getPetPreviewExtraData(templateId, petInfo)

		extraData.label = label or 0
		extraData.gender = gender or researchContentData.gender or 0
		eModel.RootRotationScale = Vector3(0, 0, 0)
		ent.modelNeedBones = true

		PetManagementDataHelper.refreshPetModelAppearance(ent, templateId, extraData)
		ent:setModelVisible(ClientConst.MODEL_VISIBLE_KEY.UIScene, true)

		local shaderView = eModel.modelShaderView

		if shaderView then
			shaderView:SetMultiPassForce32Layer(true, ClientAbilityConst.MULTI_PASS_LAYER)
		end

		ent:setLodTickEnable(Const.LOD_TICK_KEY.DEFAULT, false)
		ent:setRendererLod(0)
		self:_refreshPetJewelryWhenReady(ent, extraData.realPetId)
	end
end

function HomeCampRVPetsScene:_refreshPetJewelryWhenReady(ent, petId)
	ent.petJewelryRefreshRequest = nil

	if not petId or PetJewelryOssCache.isReady() then
		return
	end

	local request = {}
	local player = pg.me

	ent.petJewelryRefreshRequest = request

	PetJewelryOssCache.ensureLoaded(function()
		if ent.petJewelryRefreshRequest ~= request or ent.realPetId ~= petId or pg.me ~= player or ent.destroyed or ent._isDestroyingEntity or not ent.eModel then
			return
		end

		ent.petJewelryRefreshRequest = nil
		ent.tempJewelryInfo = player.petJewelryInfos[petId]

		ent:reloadAccessory()
	end)
end

function HomeCampRVPetsScene:recycleOtherEnts(toRemoveEntIds)
	for k, v in pairs(self.entPoolTable) do
		if v and not table.contains(self.curShowPetEntIds, k) then
			v.petJewelryRefreshRequest = nil

			v:setActive(ClientConst.MODEL_VISIBLE_KEY.UIScene, false)
			v.eModel:SetTransformLocalScale(0, 0, 0)
		end
	end
end

function HomeCampRVPetsScene:destroyAllEnt()
	for _, ent in pairs(self.entPoolTable or EMPTY_TABLE) do
		ClientUtils.safeDestroy(ent)
	end
end

function HomeCampRVPetsScene:switchToPage(pageId, isForceSet)
	local pageIndex = pageId + 1

	if not isForceSet and self.selectedPageIndex == pageIndex then
		return
	end

	self.selectedPageIndex = pageIndex

	self:tryMoveCameraToTarget()
end

function HomeCampRVPetsScene:tryMoveCameraToTarget()
	if not self.selectedPageIndex or self.selectedPageIndex <= 0 then
		self:m_onCameraPosMoveEnd()

		return
	end

	for gosIndex, gos in ipairs(self.bgEnvGos) do
		if gos then
			for _, go in ipairs(gos) do
				if go then
					go:SetActiveEx(gosIndex == self.selectedPageIndex)
				end
			end
		end
	end

	local vcCamera = self.cameraGoDict[self.selectedPageIndex]

	if self.curVCamera ~= vcCamera then
		if self.curVCamera then
			self.curVCamera:SetActiveEx(false)
		end

		self.curVCamera = vcCamera

		if self.curVCamera then
			self.curVCamera:SetActiveEx(true)
		end
	end

	self:moveCameraPosToTarget()
end

function HomeCampRVPetsScene:moveCameraPosToTarget()
	if not self.curVCamera or not self.selectedPageIndex or self.selectedPageIndex <= 0 then
		return
	end

	local originPos = self.cameraPosDict[self.selectedPageIndex]
	local targetPos = Vector3(originPos.x, originPos.y, originPos.z)
	local tweenId = LuaUIUtils.TweenId("moveCameraPos" .. self.selectedPageIndex)

	DoTweenAnimMgr.Kill(self.curVCamera, tweenId, true)
	DoTweenAnimMgr.Move(self.curVCamera.transform, tweenId, targetPos, MOVECAMERA_SECOND, 0, CS.DG.Tweening.Ease.__CastFrom(1), function()
		self:m_onCameraPosMoveEnd()
	end)
end

function HomeCampRVPetsScene:m_onCameraPosMoveEnd()
	return
end

return HomeCampRVPetsScene
