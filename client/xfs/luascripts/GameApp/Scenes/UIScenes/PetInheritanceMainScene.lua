-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Scenes\\UIScenes\\PetInheritanceMainScene.lua

local ClientUtils = require("Utils.ClientUtils")
local Class = require("Core.Framework.Class")
local UISceneBase = require("GameApp.UIScene.UISceneBase")
local PetInheritanceMainScene = Class.LightClass("PetInheritanceMainScene", UISceneBase)
local ClientVirtualEntityUtils = require("Utils.ClientVirtualEntityUtils")
local ClientConst = require("Const.ClientConst")
local PetFirstShowData = require("Data.pet_first_show_data")
local Utils = require("Common.Utils.Utils")
local PetResearchUtils = require("Guis.Utils.PetResearchUtils")
local PetResearchContentData = require("Data.pet_research_content_data")
local AddressDataConst = require("Const.AddressDataConst")
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")
local PetTransmogUtils = require("GameApp.PetTransmog.PetTransmogUtils")
local PetJewelryOssCache = require("Utils.PetJewelryOssCache")
local ClientEffectUtils = require("Utils.ClientEffectUtils")
local ENABLE_CUT_PRESET = true
local CUT_PRESET_NAME = {
	right = "RTCutRight",
	left = "RTCutLeft"
}

function PetInheritanceMainScene:onStart(param)
	self.leftEntity = nil
	self.leftEntityTId = nil
	self.rightEntity = nil
	self.rightEntityTId = nil

	self:initScene(param)
end

function PetInheritanceMainScene:initScene(param)
	self.rootTransform = self.scene.transform:Find("Root")
	self.objectReference = self.rootTransform:GetComponent("ObjectReference")
	self.leftCamera = self.objectReference:GetRefValue("leftCamera")
	self.rightCamera = self.objectReference:GetRefValue("rightCamera")
	self.leftPetTransform = self.objectReference:GetRefValue("leftPetTransform")
	self.rightPetTransform = self.objectReference:GetRefValue("rightPetTransform")
	self.leftRenderTexture = pg.global.uiMgr:GetRenderTextureWithPool(1920, 1080, 24)
	self.leftCamera.targetTexture = self.leftRenderTexture
end

function PetInheritanceMainScene:_transmogCacheKey(petTId, petId, label, shinyStyle)
	local pet = petId and pg.me.pets[petId]
	local key = PetTransmogUtils.getSchemeModelCacheKey(petTId, PetTransmogUtils.getSelectedScheme(pet), label, shinyStyle)

	return string.format("%s_%s_%s", key, pet and pet.gender or 0, pet and pet.shinyEffectReplace or "")
end

function PetInheritanceMainScene:setLeftModel(petTId, rawImagePro, label, petId, extraData)
	if not self.leftRenderTexture then
		return
	end

	rawImagePro.texture = self.leftRenderTexture

	rawImagePro:SetActive(true)

	local transmogKey = self:_transmogCacheKey(petTId, petId, label, extraData and extraData.shinyStyle)

	if self.leftEntity and self.leftEntityTId == petTId and self.leftTransmogKey == transmogKey then
		self:previewPetByTId(petTId, self.leftPetTransform, self.leftEntity, label, petId, extraData, "left")

		return
	end

	if self.leftEntity then
		self:_unbindCutPreset(self.leftEntity)
		ClientUtils.safeDestroy(self.leftEntity)

		self.leftEntity = nil
		self.leftEntityTId = nil
		self.leftTransmogKey = nil
	end

	local entity = self:previewPetByTId(petTId, self.leftPetTransform, nil, label, petId, extraData, "left")

	if entity then
		self.leftEntity = entity
		self.leftEntityTId = petTId
		self.leftTransmogKey = transmogKey
	else
		rawImagePro:SetActive(false)
	end
end

function PetInheritanceMainScene:setRightModel(petTId, rawImagePro, label, petId, extraData)
	if not self.leftRenderTexture then
		return
	end

	rawImagePro.texture = self.leftRenderTexture

	rawImagePro:SetActive(true)

	local transmogKey = self:_transmogCacheKey(petTId, petId, label, extraData and extraData.shinyStyle)

	if self.rightEntity and self.rightEntityTId == petTId and self.rightTransmogKey == transmogKey then
		self:previewPetByTId(petTId, self.rightPetTransform, self.rightEntity, label, petId, extraData, "right")

		return
	end

	if self.rightEntity then
		self:_unbindCutPreset(self.rightEntity)
		ClientUtils.safeDestroy(self.rightEntity)

		self.rightEntity = nil
		self.rightEntityTId = nil
		self.rightTransmogKey = nil
	end

	local entity = self:previewPetByTId(petTId, self.rightPetTransform, nil, label, petId, extraData, "right")

	if entity then
		self.rightEntity = entity
		self.rightEntityTId = petTId
		self.rightTransmogKey = transmogKey
	else
		rawImagePro:SetActive(false)
	end
end

function PetInheritanceMainScene:previewPetByTId(petTId, parent, entity, label, petId, extraData, side)
	if not petTId or petTId == 0 then
		return
	end

	local extraData = {
		label = label,
		existEntity = entity,
		isCreateEntUsePetId = petId ~= nil,
		petId = petId,
		clearJewelryInfo = petId == nil,
		transmogPetId = petId,
		petInfo = extraData,
		shinyStyle = extraData and extraData.shinyStyle
	}
	local resultEntity = PetManagementDataHelper.previewPetModel(petTId, parent, function(entity)
		entity.eModel.modelShaderView:MultiPassUseExtraConfig(0)
		self:_bindCutPreset(entity, side)
		self:_refreshPetJewelryWhenReady(entity, petId)
	end, extraData)

	return resultEntity
end

function PetInheritanceMainScene:_refreshPetJewelryWhenReady(entity, petId)
	entity.petJewelryRefreshRequest = nil

	if not petId or PetJewelryOssCache.isReady() then
		return
	end

	local request = {}
	local player = pg.me

	entity.petJewelryRefreshRequest = request

	PetJewelryOssCache.ensureLoaded(function()
		if entity.petJewelryRefreshRequest ~= request or entity.realPetId ~= petId or pg.me ~= player or entity.destroyed or entity._isDestroyingEntity or not entity.eModel then
			return
		end

		entity.petJewelryRefreshRequest = nil
		entity.tempJewelryInfo = player.petJewelryInfos[petId]

		entity:reloadAccessory()
	end)
end

function PetInheritanceMainScene:_bindCutPreset(entity, side)
	if not ENABLE_CUT_PRESET then
		return
	end

	local presetName = CUT_PRESET_NAME[side]

	if not presetName or not entity then
		return
	end

	local modelView = entity.eModel and entity.eModel.modelModelView

	if IsNil(modelView) then
		return
	end

	local function playCutPreset()
		ClientEffectUtils.PlayPreset(entity, presetName, -1, false)
	end

	modelView.luaOnModelRefreshFinshed = playCutPreset

	playCutPreset()
end

function PetInheritanceMainScene:_unbindCutPreset(entity)
	if not ENABLE_CUT_PRESET then
		return
	end

	if not entity then
		return
	end

	local modelView = entity.eModel and entity.eModel.modelModelView

	if NotNil(modelView) then
		modelView.luaOnModelRefreshFinshed = nil
	end
end

function PetInheritanceMainScene:disableEntUnknown(ent)
	local modelShaderView = ent.eModel.modelShaderView

	modelShaderView:SetOverrideMaterial("")
	modelShaderView:SetMultiPassRenderEnable(true)
end

function PetInheritanceMainScene:clear()
	if self.leftRenderTexture ~= nil then
		pg.global.uiMgr:ReleaseRenderTextureWithPool(self.leftRenderTexture)

		self.leftRenderTexture = nil
	end

	if self.leftEntity then
		self:_unbindCutPreset(self.leftEntity)
		ClientUtils.safeDestroy(self.leftEntity)

		self.leftEntity = nil
		self.leftEntityTId = nil
		self.leftTransmogKey = nil
	end

	if self.rightEntity then
		self:_unbindCutPreset(self.rightEntity)
		ClientUtils.safeDestroy(self.rightEntity)

		self.rightEntity = nil
		self.rightEntityTId = nil
		self.rightTransmogKey = nil
	end
end

function PetInheritanceMainScene:onDestroy()
	self:clear()
end

function PetInheritanceMainScene:pauseRenderTexture()
	if NotNil(self.leftCamera) then
		self.leftCamera.targetTexture = nil
	end
end

function PetInheritanceMainScene:resumeRenderTexture()
	if NotNil(self.leftCamera) and NotNil(self.leftRenderTexture) then
		self.leftCamera.targetTexture = self.leftRenderTexture
	end
end

return PetInheritanceMainScene
