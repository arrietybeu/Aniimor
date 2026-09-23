-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\SpaceFurniture\\ClientSpaceFurnitureVehicle.lua

local Class = require("Core.Framework.Class")
local ClientBench = require("Entities.SpaceEntities.VehicleEntities.ClientBench")
local ClientModelEntity = require("Entities.ClientModelEntity")
local Const = require("Common.Const.Const")
local ClientConst = require("Const.ClientConst")
local ClientUtils = require("Utils.ClientUtils")
local HomeObjectData = require("Data.home_object_data")
local HomelandConfigData = require("Data.homeland_config_data")
local ClientModelBatchComponent = require("Entities.SpaceEntities.CommonComponent.ClientModelBatchComponent")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientSpaceFurnitureVehicle = Class.Class("ClientSpaceFurnitureVehicle", ClientBench)

ClientSpaceFurnitureVehicle.BORN_SCALE_TWEEN_ID = "spaceFurnitureVehicleBornScale"
ClientSpaceFurnitureVehicle.BORN_SCALE_DURATION = 0.2

local ClientSpaceFurnitureVehicleComponents = {
	ClientModelBatchComponent
}

Class.AddComponents(ClientSpaceFurnitureVehicle, ClientSpaceFurnitureVehicleComponents)

function ClientSpaceFurnitureVehicle:ctor(entityId)
	ClientSpaceFurnitureVehicle.super.ctor(self, entityId)

	self.hasPlayedBornScaleAnim = false
	self.bornScaleTarget = 1
end

function ClientSpaceFurnitureVehicle:init(dict)
	if self.homeTemplateId == nil and dict.homeTemplateId ~= nil then
		rawset(self, "homeTemplateId", dict.homeTemplateId)
	end

	if self.ownerUid == nil and dict.ownerUid ~= nil then
		rawset(self, "ownerUid", dict.ownerUid)
	end

	return ClientSpaceFurnitureVehicle.super.init(self, dict)
end

function ClientSpaceFurnitureVehicle:postInit(dict)
	local ret = ClientSpaceFurnitureVehicle.super.postInit(self, dict)
	local homeObjectConfig = self.homeTemplateId and HomeObjectData[self.homeTemplateId]

	if homeObjectConfig and homeObjectConfig.needIndicatorIcon == 1 then
		self.forbiddenTopLogo = false
		self.topLogoType = ClientConst.TopLogoType.InteractableObject
		self.overrideTopLogoEnterDistance = HomelandConfigData.IndicatorIconDisplayArea or 10
		self.indicatorIconHeight = homeObjectConfig.IndicatorIconHeight
	end

	return ret
end

function ClientSpaceFurnitureVehicle:initializeComponents()
	ClientSpaceFurnitureVehicle.super.initializeComponents(self)
	self:addEModelMonoComponent(Const.COMPONENT_IDX_PHYSX)
	self:addEModelComponent(Const.COMPONENT_IDX_ITEM)
end

function ClientSpaceFurnitureVehicle:getConfigData()
	if self.homeTemplateId then
		return HomeObjectData[self.homeTemplateId] or {}
	end

	return {}
end

function ClientSpaceFurnitureVehicle:refreshAppearance()
	local configData = self:getConfigData()
	local resId = configData.prefabResID

	if resId then
		ClientModelEntity.refreshAppearance(self)

		if self:hasEModelComponent(Const.COMPONENT_IDX_ITEM) then
			self:setScaleNumber(0)
			self:setEnableRendererBatch(self:checkEnableRendererBatch())

			self.bornScaleTarget = configData.prefabScale or 1

			self.eModel:SetModelResId(Const.COMPONENT_IDX_ITEM, resId, ClientConst.InstantiatePriority.Low, ClientConst.AsyncLoadPriority.Low)
		end

		return
	end

	ClientSpaceFurnitureVehicle.super.refreshAppearance(self)
end

function ClientSpaceFurnitureVehicle:checkEnableRendererBatch()
	return ClientUtils.checkEnableRendererBatch() and not self:getConfigData().disableRendererBatch
end

function ClientSpaceFurnitureVehicle:onItemModelLoaded()
	self.isModelLoaded = true

	if self.onPrefabModelLoaded then
		self:onPrefabModelLoaded()
	end

	self.eModel:SetHomeObjectCollider(Const.COMPONENT_IDX_PHYSX)
	self.eModel:SetTag(Const.COMPONENT_IDX_PHYSX, Const.TAG_ACTOR, self.actorId, 0)

	local modelText = self:getConfigData().modelText

	if modelText then
		self.eModel.modelView:SetModelText(pg.getLocalizationText(modelText), ClientConst.ModelTextType.Default)
	end

	self:playBornScaleAnim()
	self:postComponentMethod("EVENT_onModelLoaded")
	self:setModelLoaded(true)
end

function ClientSpaceFurnitureVehicle:playBornScaleAnim()
	if self.hasPlayedBornScaleAnim then
		return
	end

	if not self.eModel then
		return
	end

	self.hasPlayedBornScaleAnim = true

	local targetScale = self.bornScaleTarget or self:getConfigData().prefabScale or 1

	DoTweenAnimMgr.Kill(self.actorId, LuaUIUtils.TweenId(self.BORN_SCALE_TWEEN_ID), true)
	DoTweenAnimMgr.DoFloat(self.actorId, 0, targetScale, LuaUIUtils.TweenId(self.BORN_SCALE_TWEEN_ID), self.BORN_SCALE_DURATION, 0, CS.DG.Tweening.Ease.__CastFrom(Const.DoTweenEaseType.OutBack), function()
		return
	end, function(value)
		self:setScaleNumber(value)
	end, function()
		return
	end, false)
end

function ClientSpaceFurnitureVehicle:destroyEntity(reason, delay)
	if pg.me then
		pg.me:serverMsg("RPC_CS_RecycleWorldFurniture")
	end
end

return ClientSpaceFurnitureVehicle
