-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\ClientSimpleVirtualPet.lua

local Class = require("Core.Framework.Class")
local ClientSimpleVirtualEntity = require("Entities.ClientSimpleVirtualEntity")
local ClientModelUtils = require("Utils.ClientModelUtils")
local PetData = require("Data.pet_data")
local PetTransmogUtils = require("GameApp.PetTransmog.PetTransmogUtils")
local ClientPetAccessoryComponent = require("Entities.SpaceEntities.CommonComponent.ClientPetAccessoryComponent")
local ClientSimpleVirtualPet = Class.Class("ClientSimpleVirtualPet", ClientSimpleVirtualEntity)
local ClientVirtualPetComponents = {
	ClientPetAccessoryComponent
}

Class.AddComponents(ClientSimpleVirtualPet, ClientVirtualPetComponents)

function ClientSimpleVirtualPet:init(dict)
	ClientSimpleVirtualPet.super.init(self, dict)

	self.configData = dict.configData
	self.syncLoad = dict.syncLoad
	self.petJewelryInfo = dict.petJewelryInfo
	self.tempJewelryInfo = dict.tempJewelryInfo
	self.realPetId = dict.realPetId

	if dict.petInfo then
		self.petInfo = dict.petInfo
	end
end

function ClientSimpleVirtualPet:postInitializeComponents()
	ClientSimpleVirtualPet.super.postInitializeComponents(self)

	self.eModel.isMainAuthority = true
end

function ClientSimpleVirtualPet:isPet()
	return true
end

function ClientSimpleVirtualPet:getPetHeight()
	local petInfo = self.realPetId and pg.me and pg.me:getPetInfo(self.realPetId) or self.petInfo

	return petInfo and petInfo.height or self:getHeight()
end

function ClientSimpleVirtualPet:getConfigData()
	if self.configData then
		return self.configData
	end

	if self.templateId then
		return PetData[self.templateId] or {}
	end

	return {}
end

function ClientSimpleVirtualPet:refreshAppearance()
	local configData = self:getConfigData()
	local modelView = self.eModel.modelModelView
	local displayLabel = PetTransmogUtils.getDisplayLabel(self.templateId, self.label)
	local extraData = ClientModelUtils.getModelExtraInfo(configData, displayLabel, self.gender, nil, nil, self.petInfo)

	self:postComponentMethod("EVENT_OnMergeAppearanceData", configData, extraData)
	ClientModelUtils.applyModelAppearance(modelView.modelInfo, configData, extraData)

	modelView.modelInfo.physiqueModelInfo.isAlwaysAnimate = true

	self:postComponentMethod("Event_BeforeRefreshModels", modelView)
	ClientModelUtils.refreshModels(self, modelView)
	self:attachBaseEffects(extraData.attachEffects, self.isIgnoreEffectLod)
end

return ClientSimpleVirtualPet
