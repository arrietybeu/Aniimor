-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\PetVariant\\PetVariantEntity.lua

local Events = require("Common.Container.Events")
local AddressDataConst = require("Const.AddressDataConst")
local EffectConst = require("Const.EffectConst")
local Class = require("Core.Framework.Class")
local ClientSimpleVirtualPet = require("Entities.ClientSimpleVirtualPet")
local ClientModelUtils = require("Utils.ClientModelUtils")
local PetTransmogUtils = require("GameApp.PetTransmog.PetTransmogUtils")
local PetVariantEntity = Class.Class("PetVariantEntity", ClientSimpleVirtualPet)

function PetVariantEntity:ctor(entityId)
	PetVariantEntity.super.ctor(self, entityId)

	self.eventEmitter = Events.new()
end

function PetVariantEntity:init(dict)
	PetVariantEntity.super.init(self, dict)

	self.petInfo = dict.petInfo
	self.space = pg.space
	self.petVariantNameVisible = false
	self.petVariantNamePage = 0
end

function PetVariantEntity:refreshAppearance()
	local configData = self:getConfigData()
	local modelView = self.eModel.modelModelView
	local rawLabel = self.label or 0
	local modelLabel = PetTransmogUtils.getDisplayLabel(self.templateId, rawLabel)
	local hasShinyEffectReplace = self.petInfo and not string.isNilOrEmpty(self.petInfo.shinyEffectReplace)
	local effectLabel = hasShinyEffectReplace and rawLabel or modelLabel
	local extraData = ClientModelUtils.getModelExtraInfo(configData, effectLabel, self.gender, nil, nil, self.petInfo)

	extraData.prefabResID = ClientModelUtils.getModelPrefabResId(configData, modelLabel, self.gender)

	self:postComponentMethod("EVENT_OnMergeAppearanceData", configData, extraData)
	ClientModelUtils.applyModelAppearance(modelView.modelInfo, configData, extraData)

	modelView.modelInfo.physiqueModelInfo.isAlwaysAnimate = true

	self:postComponentMethod("Event_BeforeRefreshModels", modelView)
	modelView:RefreshModels()
	self:attachBaseEffects(extraData.attachEffects, self.isIgnoreEffectLod)
end

function PetVariantEntity:showNormalName()
	self.petVariantNameVisible = true

	self:_setVariantNamePage(0)
end

function PetVariantEntity:_setVariantNamePage(page)
	self.petVariantNamePage = page

	if self.petVariantNamePageChangedCallback then
		self.petVariantNamePageChangedCallback()
	end
end

function PetVariantEntity:switchToVariantName()
	self:_setVariantNamePage(1)
end

function PetVariantEntity:playVariantHeartBoomEffect()
	if not self.eModel or IsNil(self.eModel.transform) then
		return
	end

	self:playEffectRaw(AddressDataConst.PET_VARIANT_HEART_BOOM_EFFECT, {
		duration = 5,
		mountType = EffectConst.MountType.Custom,
		targetTrans = self.eModel.transform
	})
end

return PetVariantEntity
