-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Scenes\\UIScenes\\PetManagementPreviewScene.lua

local ClientUtils = require("Utils.ClientUtils")
local Class = require("Core.Framework.Class")
local UISceneBase = require("GameApp.UIScene.UISceneBase")
local PetManagementPreviewScene = Class.LightClass("PetManagementPreviewScene", UISceneBase)
local ClientConst = require("Const.ClientConst")
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")
local PetTransmogUtils = require("GameApp.PetTransmog.PetTransmogUtils")
local PetJewelryOssCache = require("Utils.PetJewelryOssCache")
local AntialiasingMode = {
	FSR = 1,
	NONE = 0,
	TAA = 2
}

function PetManagementPreviewScene:onStart(param)
	self.curEntity = nil
	self.curPetId = nil

	self:initScene(param)
end

function PetManagementPreviewScene:initScene(param)
	self.textureWidth = 300
	self.textureHeight = 300

	if param and param.textureWidth then
		self.textureWidth = param.textureWidth
		self.textureHeight = param.textureHeight
	end

	local root = self.scene.transform:Find("Root")

	self.objectReference = root:GetComponent("ObjectReference")
	self.cameraCamera = self.objectReference:GetRefValue("cameraCamera")
	self.petPosTransform = self.objectReference:GetRefValue("petPosTransform")
	self.levelPetManagementEnvV2Transform = self.objectReference:GetRefValue("levelPetManagementEnvV2Transform")
	self.envVolumeV2Transform = self.objectReference:GetRefValue("envVolumeV2Transform")
	self.renderTexture = pg.global.uiMgr:GetRenderTextureWithPool(self.textureWidth, self.textureHeight, 24)
	self.cameraCamera.targetTexture = self.renderTexture
	self.cameraXCameraData = self.objectReference:GetRefValue("cameraXCameraData")

	if self.cameraXCameraData and self.cameraXCameraData.m_AntialiasingMode ~= AntialiasingMode.FSR then
		-- block empty
	end

	self.scene.transform.position = Vector3(0, 5000, 0)

	if param and param.useLocalEnv then
		-- block empty
	end
end

function PetManagementPreviewScene:setExRawImageProRef(rawImagePro, textureWidth, textureHeight)
	if not self.renderTexture then
		return
	end

	self:clearTexture()

	self.renderTexture = pg.global.uiMgr:GetRenderTextureWithPool(textureWidth, textureHeight, 24)
	self.cameraCamera.targetTexture = self.renderTexture
	rawImagePro.texture = self.renderTexture
	self.rawImagePro = rawImagePro
end

function PetManagementPreviewScene:reSetRawImageProRef()
	self:clearTexture()

	self.renderTexture = pg.global.uiMgr:GetRenderTextureWithPool(self.textureWidth, self.textureHeight, 24)
	self.cameraCamera.targetTexture = self.renderTexture
end

function PetManagementPreviewScene:setRawImageProRef(rawImagePro)
	if not self.renderTexture then
		return
	end

	rawImagePro.texture = self.renderTexture
	self.rawImagePro = rawImagePro
end

function PetManagementPreviewScene:refreshEntityRenderState(entity)
	if not entity then
		return
	end

	entity:setModelLayer(ClientConst.LayerDefine.LAYER_UI_SCENE)
	entity:setActive(ClientConst.MODEL_VISIBLE_KEY.UIScene, self.modelVisible ~= false)

	local modelShaderView = entity.eModel and entity.eModel.modelShaderView

	if modelShaderView then
		modelShaderView:MultiPassUseExtraConfig(0)
	end
end

function PetManagementPreviewScene:waitEntityModelLoaded(entity)
	if not entity then
		return
	end

	self:refreshEntityRenderState(entity)

	if entity.eModel.modelModelView.firstLoaded then
		return
	end

	function entity.modelLoadedCallback()
		if self.curEntity ~= entity then
			return
		end

		entity.modelLoadedCallback = nil

		self:refreshEntityRenderState(entity)
	end
end

function PetManagementPreviewScene:refreshPetJewelry(entity, petId, refreshNow)
	local request = {}

	self.petJewelryRefreshRequest = request

	local player = pg.me

	local function refresh()
		if self.petJewelryRefreshRequest ~= request or self.curEntity ~= entity or self.curPetId ~= petId or pg.me ~= player or not entity.eModel then
			return
		end

		entity.realPetId = petId
		entity.tempJewelryInfo = player.petJewelryInfos[petId]
		entity.petJewelryInfo = nil
		entity.useTempJewelrySnapshot = false

		entity:reloadAccessory()
		self:waitEntityModelLoaded(entity)
	end

	if not PetJewelryOssCache.isReady() then
		PetJewelryOssCache.ensureLoaded(refresh)
	elseif refreshNow then
		refresh()
	end
end

function PetManagementPreviewScene:previewPet(petId, force)
	local pet = petId and pg.me.pets[petId]
	local petTId = pet and pet.templateId
	local transmogKey = PetTransmogUtils.getSchemeModelCacheKey(petTId, PetTransmogUtils.getSelectedScheme(pet), pet and pet.label, pet and pet.shinyStyle)

	transmogKey = string.format("%s_%s_%s", transmogKey, pet and pet.gender or 0, pet and pet.shinyEffectReplace or "")

	if petId and self.curPetId == petId and self.curTransmogKey == transmogKey and not force then
		self:refreshPetJewelry(self.curEntity, petId, true)

		return
	end

	self:clear()

	if not petId then
		return
	end

	if not pet then
		return
	end

	local extraData = {
		isCreateEntUsePetId = pet ~= nil,
		petId = petId,
		transmogPetId = petId,
		petInfo = pet
	}

	PetManagementDataHelper.previewPetModel(petTId, self.petPosTransform, function(entity)
		if not entity then
			return
		end

		self.curEntity = entity
		self.curPetId = petId
		self.curTransmogKey = transmogKey

		self:waitEntityModelLoaded(entity)
		self:refreshPetJewelry(entity, petId, false)
	end, extraData)
end

function PetManagementPreviewScene:playPetIdle()
	if self.curEntity then
		self.curEntity:playAnimation("Idle")
	end
end

function PetManagementPreviewScene:setModelVisible(visible)
	self.modelVisible = visible

	if self.curEntity then
		self.curEntity:setActive(ClientConst.MODEL_VISIBLE_KEY.UIScene, visible)
	end
end

function PetManagementPreviewScene:previewPetByTId(petTId, force, transmogScheme, petInfo)
	local transmogKey = PetTransmogUtils.getSchemeModelCacheKey(petTId, transmogScheme, petInfo and petInfo.label, petInfo and petInfo.shinyStyle)

	transmogKey = string.format("%s_%s_%s", transmogKey, petInfo and petInfo.gender or 0, petInfo and petInfo.shinyEffectReplace or "")

	if self.curPetTId == petTId and self.curTransmogKey == transmogKey and not force then
		return
	end

	self:clear()

	local extraData = {
		useTemplateFallback = true,
		useTransmogScheme = true,
		petInfo = petInfo,
		transmogScheme = transmogScheme
	}

	PetManagementDataHelper.previewPetModel(petTId, self.petPosTransform, function(entity)
		if not entity then
			return
		end

		self.curEntity = entity
		self.curPetTId = petTId
		self.curTransmogKey = transmogKey

		self:waitEntityModelLoaded(entity)
	end, extraData)
end

function PetManagementPreviewScene:clear()
	self.petJewelryRefreshRequest = nil

	if self.curEntity then
		ClientUtils.safeDestroy(self.curEntity)

		self.curEntity = nil
		self.curPetId = nil
		self.curPetTId = nil
		self.curTransmogKey = nil
	end
end

function PetManagementPreviewScene:clearTexture()
	if self.renderTexture ~= nil then
		pg.global.uiMgr:ReleaseRenderTextureWithPool(self.renderTexture)

		self.renderTexture = nil
	end
end

function PetManagementPreviewScene:onDestroy()
	self:clearTexture()
	self:clear()
end

function PetManagementPreviewScene:entActive(active)
	self:setModelVisible(active)
end

function PetManagementPreviewScene:snapShotDraw()
	pg.global.cameraMgr:SnapShotDelay(function(texture)
		self.rawImagePro.texture = texture
	end, self.cameraCamera, self.renderTexture)
end

function PetManagementPreviewScene:setLocalEnv()
	self.levelPetManagementEnvV2Transform.gameObject:SetActiveEx(false)
	self.envVolumeV2Transform.gameObject:SetActiveEx(true)
end

function PetManagementPreviewScene:pauseTargetTexture()
	if NotNil(self.cameraCamera) then
		self.cameraCamera.targetTexture = nil
	end
end

function PetManagementPreviewScene:resumeTargetTexture()
	if NotNil(self.cameraCamera) and NotNil(self.renderTexture) then
		self.cameraCamera.targetTexture = self.renderTexture
	end
end

function PetManagementPreviewScene:enableCamera(enable)
	if self.cameraCamera then
		self.cameraCamera.gameObject:SetActiveEx(enable)
	end
end

return PetManagementPreviewScene
