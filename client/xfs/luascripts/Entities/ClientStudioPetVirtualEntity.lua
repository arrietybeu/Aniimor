-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\ClientStudioPetVirtualEntity.lua

local Class = require("Core.Framework.Class")
local ClientSimpleVirtualEntity = require("Entities.ClientSimpleVirtualEntity")
local ClientModelUtils = require("Utils.ClientModelUtils")
local PetData = require("Data.pet_data")
local PetTransmogUtils = require("GameApp.PetTransmog.PetTransmogUtils")
local ClientPetAccessoryComponent = require("Entities.SpaceEntities.CommonComponent.ClientPetAccessoryComponent")
local ClientPhysicsComponent = require("Entities.SpaceEntities.CommonComponent.ClientPhysicsComponent")
local VirtualEntUtils = require("Common.Utils.VirtualEntUtils")
local Const = require("Common.Const.Const")
local ClientStudioPetVirtualEntity = Class.Class("ClientStudioPetVirtualEntity", ClientSimpleVirtualEntity)

local function isSameValue(left, right)
	if left == right then
		return true
	end

	if type(left) ~= "table" or type(right) ~= "table" then
		return false
	end

	for key, value in pairs(left) do
		if not isSameValue(value, right[key]) then
			return false
		end
	end

	for key, value in pairs(right) do
		if left[key] == nil and value ~= nil then
			return false
		end
	end

	return true
end

local ClientStudioPetComponents = {
	ClientPetAccessoryComponent,
	ClientPhysicsComponent
}

Class.AddComponents(ClientStudioPetVirtualEntity, ClientStudioPetComponents)

function ClientStudioPetVirtualEntity:init(dict)
	ClientStudioPetVirtualEntity.super.init(self, dict)

	self.actorId = VirtualEntUtils.getNewVirtualEntActorId()
	self.syncLoad = dict.syncLoad
	self.petJewelryInfo = dict.petJewelryInfo
	self.tempJewelryInfo = dict.tempJewelryInfo
	self.shinyEffectReplace = dict.shinyEffectReplace or ""
	self.realPetId = dict.realPetId
	self.ownerUid = dict.ownerUid
	self.useTempJewelrySnapshot = dict.useTempJewelrySnapshot
	self.master = pg.me
end

function ClientStudioPetVirtualEntity:updateStudioAppearance(label, gender, shinyStyle, tempJewelryInfo, shinyEffectReplace)
	shinyEffectReplace = shinyEffectReplace or ""

	local changed = self.label ~= label or self.gender ~= gender or self.shinyStyle ~= shinyStyle or self.shinyEffectReplace ~= shinyEffectReplace or not isSameValue(self.tempJewelryInfo, tempJewelryInfo)

	self.label = label
	self.gender = gender
	self.shinyStyle = shinyStyle
	self.tempJewelryInfo = tempJewelryInfo
	self.shinyEffectReplace = shinyEffectReplace

	return changed
end

function ClientStudioPetVirtualEntity:postInitializeComponents()
	ClientStudioPetVirtualEntity.super.postInitializeComponents(self)

	self.eModel.isMainAuthority = true
end

function ClientStudioPetVirtualEntity:isPet()
	return true
end

function ClientStudioPetVirtualEntity:getOwnerUid()
	return self.ownerUid
end

function ClientStudioPetVirtualEntity:getConfigData()
	if self.templateId then
		return PetData[self.templateId] or {}
	end

	return {}
end

function ClientStudioPetVirtualEntity:refreshAppearance()
	local configData = self:getConfigData()
	local modelView = self.eModel.modelModelView
	local displayLabel = PetTransmogUtils.getDisplayLabel(self.templateId, self.label)
	local effectPetInfo = {
		shinyEffectReplace = self.shinyEffectReplace
	}
	local extraData = ClientModelUtils.getModelExtraInfo(configData, displayLabel, self.gender, nil, nil, effectPetInfo)

	self:postComponentMethod("EVENT_OnMergeAppearanceData", configData, extraData)
	ClientModelUtils.applyModelAppearance(modelView.modelInfo, configData, extraData)

	modelView.modelInfo.physiqueModelInfo.isAlwaysAnimate = true

	self:postComponentMethod("Event_BeforeRefreshModels", modelView)
	ClientModelUtils.refreshModels(self, modelView)
	self:attachBaseEffects(extraData.attachEffects)
	self:postComponentMethod("EVENT_EnterScene")
	self:postComponentMethod("EVENT_RefreshPhysx")
	self:handlerCollision()
end

function ClientStudioPetVirtualEntity:handlerCollision()
	if not self.master then
		return
	end

	local collider = self.eModel:GetCollider(Const.COMPONENT_IDX_PHYSX)

	if collider then
		self.master.eModel:AddIgnoreCollider(Const.COMPONENT_MOTION, collider)
	end

	local curPet = self.master:getCurPetEntity()

	if not curPet then
		return
	end

	if collider then
		curPet.eModel:AddIgnoreCollider(Const.COMPONENT_MOTION, collider)
	end
end

return ClientStudioPetVirtualEntity
