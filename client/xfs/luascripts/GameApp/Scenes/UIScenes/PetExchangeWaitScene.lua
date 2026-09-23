-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Scenes\\UIScenes\\PetExchangeWaitScene.lua

local ClientUtils = require("Utils.ClientUtils")
local Class = require("Core.Framework.Class")
local UISceneBase = require("GameApp.UIScene.UISceneBase")
local PetExchangeWaitScene = Class.LightClass("PetExchangeWaitScene", UISceneBase)
local ClientVirtualEntityUtils = require("Utils.ClientVirtualEntityUtils")
local ClientConst = require("Const.ClientConst")
local PetFirstShowData = require("Data.pet_first_show_data")
local Utils = require("Common.Utils.Utils")
local PetResearchUtils = require("Guis.Utils.PetResearchUtils")
local PetResearchContentData = require("Data.pet_research_content_data")
local AddressDataConst = require("Const.AddressDataConst")
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")
local PetTransmogUtils = require("GameApp.PetTransmog.PetTransmogUtils")

function PetExchangeWaitScene:onStart(param)
	self.leftEntity = nil
	self.leftEntityTId = nil
	self.rightEntity = nil
	self.rightEntityTId = nil
	self.rightUnknow = false

	self:initScene(param)
end

function PetExchangeWaitScene:initScene(param)
	self.rootTransform = self.scene.transform:Find("Root")
	self.objectReference = self.rootTransform:GetComponent("ObjectReference")
	self.leftCamera = self.objectReference:GetRefValue("leftCamera")
	self.rightCamera = self.objectReference:GetRefValue("rightCamera")
	self.leftPetTransform = self.objectReference:GetRefValue("leftPetTransform")
	self.rightPetTransform = self.objectReference:GetRefValue("rightPetTransform")
	self.leftRenderTexture = pg.global.uiMgr:GetRenderTextureWithPool(1920, 1080, 24)
	self.leftCamera.targetTexture = self.leftRenderTexture
end

function PetExchangeWaitScene:_transmogCacheKey(petTId, transmogInfo, label, shinyStyle)
	if not transmogInfo then
		return nil
	end

	local scheme = transmogInfo.scheme

	if transmogInfo.petId then
		local petInfo = PetTransmogUtils.getPetInfo(transmogInfo.petId)

		scheme = PetTransmogUtils.getSelectedScheme(petInfo)
	end

	local key = PetTransmogUtils.getSchemeModelCacheKey(petTId, scheme, label, shinyStyle)

	return string.format("%s_%s", key, transmogInfo.shinyEffectReplace or "")
end

function PetExchangeWaitScene:setLeftModel(petTId, rawImagePro, label, transmogInfo)
	if not self.leftRenderTexture then
		return
	end

	rawImagePro.texture = self.leftRenderTexture

	rawImagePro:SetActive(true)

	local transmogKey = self:_transmogCacheKey(petTId, transmogInfo, label, transmogInfo and transmogInfo.shinyStyle)

	if self.leftEntity and self.leftEntityTId == petTId and self.leftTransmogKey == transmogKey then
		return
	end

	if self.leftEntity then
		ClientUtils.safeDestroy(self.leftEntity)

		self.leftEntity = nil
		self.leftEntityTId = nil
	end

	local entity = self:previewPetByTId(petTId, self.leftPetTransform, false, nil, label, transmogInfo)

	if entity then
		self.leftEntity = entity
		self.leftEntityTId = petTId
		self.leftTransmogKey = transmogKey
		self.leftTransmogInfo = transmogInfo
		self.leftLabel = label
	end
end

function PetExchangeWaitScene:setRightModel(petTId, isUnknow, rawImagePro, label, transmogInfo)
	if not self.leftRenderTexture then
		return
	end

	rawImagePro.texture = self.leftRenderTexture

	rawImagePro:SetActive(true)

	local transmogKey = self:_transmogCacheKey(petTId, transmogInfo, label, transmogInfo and transmogInfo.shinyStyle)

	if self.rightEntity and self.rightEntityTId == petTId and self.rightUnknow == isUnknow and self.rightTransmogKey == transmogKey then
		return
	end

	if self.rightEntity then
		ClientUtils.safeDestroy(self.rightEntity)

		self.rightEntity = nil
		self.rightEntityTId = nil
	end

	local entity = self:previewPetByTId(petTId, self.rightPetTransform, isUnknow, nil, label, transmogInfo)

	if entity then
		self.rightEntity = entity
		self.rightEntityTId = petTId
		self.rightUnknow = isUnknow
		self.rightTransmogKey = transmogKey
		self.rightTransmogInfo = transmogInfo
		self.rightLabel = label
	end
end

function PetExchangeWaitScene:previewPetByTId(petTId, parent, isUnknow, entity, label, transmogInfo)
	local useScheme = transmogInfo ~= nil and transmogInfo.petId == nil
	local extraData = {
		label = label,
		existEntity = entity,
		transmogPetId = transmogInfo and transmogInfo.petId,
		transmogScheme = transmogInfo and transmogInfo.scheme,
		useTransmogScheme = useScheme,
		shinyStyle = transmogInfo and transmogInfo.shinyStyle,
		shinyEffectReplace = transmogInfo and transmogInfo.shinyEffectReplace
	}
	local retEntity = PetManagementDataHelper.previewPetModel(petTId, parent, function(retEntity)
		if not retEntity then
			return
		end

		retEntity.eModel.modelShaderView:MultiPassUseExtraConfig(0)

		if isUnknow then
			self:showEntUnknown(retEntity)
		end
	end, extraData)

	return retEntity
end

function PetExchangeWaitScene:showEntUnknown(ent)
	local modelShaderView = ent.eModel.modelShaderView

	modelShaderView:SetOverrideMaterial(PetManagementDataHelper.getPetHandbookMat())
	modelShaderView:SetMultiPassRenderEnable(false)
end

function PetExchangeWaitScene:disableEntUnknown(ent)
	local modelShaderView = ent.eModel.modelShaderView

	modelShaderView:SetOverrideMaterial("")
	modelShaderView:SetMultiPassRenderEnable(true)
end

function PetExchangeWaitScene:showPetDownEffect()
	if self.leftEntity then
		ClientEffectUtils.PlayPreset(self.leftEntity, "ParmonExchangeDown", 3, false)
	end

	if self.rightEntity then
		ClientEffectUtils.PlayPreset(self.rightEntity, "ParmonExchangeDown", 3, false)
	end
end

function PetExchangeWaitScene:exchangePet()
	self:previewPetByTId(self.leftEntityTId, self.rightPetTransform, false, self.leftEntity, self.leftLabel, self.leftTransmogInfo)
	self:previewPetByTId(self.rightEntityTId, self.leftPetTransform, false, self.rightEntity, self.rightLabel, self.rightTransmogInfo)
end

function PetExchangeWaitScene:showPetUpEffect()
	if self.leftEntity then
		ClientEffectUtils.PlayPreset(self.leftEntity, "ParmonExchangeUp", 3, false)
	end

	if self.rightEntity then
		ClientEffectUtils.PlayPreset(self.rightEntity, "ParmonExchangeUp", 3, false)
	end
end

function PetExchangeWaitScene:clear()
	if self.leftRenderTexture ~= nil then
		pg.global.uiMgr:ReleaseRenderTextureWithPool(self.leftRenderTexture)

		self.leftRenderTexture = nil
	end

	if self.leftEntity then
		ClientUtils.safeDestroy(self.leftEntity)

		self.leftEntity = nil
		self.leftEntityTId = nil
		self.leftTransmogKey = nil
	end

	if self.rightEntity then
		ClientUtils.safeDestroy(self.rightEntity)

		self.rightEntity = nil
		self.rightEntityTId = nil
		self.rightTransmogKey = nil
	end
end

function PetExchangeWaitScene:onDestroy()
	self:clear()
end

return PetExchangeWaitScene
