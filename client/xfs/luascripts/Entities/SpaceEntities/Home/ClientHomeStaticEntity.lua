-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\Home\\ClientHomeStaticEntity.lua

local Class = require("Core.Framework.Class")
local ClientHomeEntityBase = require("Entities.SpaceEntities.Home.ClientHomeEntityBase")
local VirtualEntUtils = require("Common.Utils.VirtualEntUtils")
local Const = require("Common.Const.Const")
local ClientConst = require("Const.ClientConst")
local ClientUtils = require("Utils.ClientUtils")
local ClientAoiComponent = require("Entities.SpaceEntities.CommonComponent.ClientAoiComponent")
local ClientModelBatchComponent = require("Entities.SpaceEntities.CommonComponent.ClientModelBatchComponent")
local ClientEntityEditorComponent = require("Entities.SpaceEntities.Home.ClientEntityEditorComponent")
local ClientHomeEditorComponent = require("Entities.SpaceEntities.Home.ClientHomeEditorComponent")
local ClientHomeEditorTopLogoComponent = require("Entities.SpaceEntities.Home.ClientHomeEditorTopLogoComponent")
local ClientHomeStaticEntity = Class.Class("ClientHomeStaticEntity", ClientHomeEntityBase)
local ClientHomeStaticEntityComponents = {
	ClientAoiComponent,
	ClientModelBatchComponent,
	ClientEntityEditorComponent,
	ClientHomeEditorComponent,
	ClientHomeEditorTopLogoComponent
}

Class.AddComponents(ClientHomeStaticEntity, ClientHomeStaticEntityComponents)

function ClientHomeStaticEntity:ctor(entityId)
	ClientHomeStaticEntity.super.ctor(self, entityId)
end

function ClientHomeStaticEntity:init(dict)
	if self.isClientEnt then
		self.actorId = VirtualEntUtils.getNewVirtualEntActorId()
		self.clenUsrType = Const.CLEN_USE_TYPE_HOME
	end

	self.skipAoiActor = true

	ClientHomeStaticEntity.super.init(self, dict)

	return true
end

function ClientHomeStaticEntity:start()
	ClientHomeStaticEntity.super.start(self)
end

function ClientHomeStaticEntity:initializeComponents()
	ClientHomeStaticEntity.super.initializeComponents(self)
	self:addEModelMonoComponent(Const.COMPONENT_IDX_PHYSX)
	self:addEModelComponent(Const.COMPONENT_IDX_ITEM)

	self.eModel.staticNoTick = true
end

function ClientHomeStaticEntity:refreshAppearance()
	ClientHomeStaticEntity.super.refreshAppearance(self)

	if self:hasEModelComponent(Const.COMPONENT_IDX_ITEM) then
		self:setEnableRendererBatch(self:checkEnableRendererBatch())

		local resId = self:getConfigData().prefabResID
		local modelScale = self:getConfigData().prefabScale or 1

		if resId then
			self:setScaleNumber(modelScale)
			self.eModel:SetModelResId(Const.COMPONENT_IDX_ITEM, resId, ClientConst.InstantiatePriority.Low, ClientConst.AsyncLoadPriority.Low)
		end
	end
end

function ClientHomeStaticEntity:checkEnableRendererBatch()
	return ClientUtils.checkEnableRendererBatch() and not self:getConfigData().disableRendererBatch
end

function ClientHomeStaticEntity:onItemModelLoaded()
	self.isModelLoaded = true

	self.eModel:SetHomeObjectCollider(Const.COMPONENT_IDX_PHYSX)
	self.eModel:SetTag(Const.COMPONENT_IDX_PHYSX, Const.TAG_ACTOR, self.actorId, 0)

	local modelText = self:getConfigData().modelText

	if modelText then
		local showText = pg.getLocalizationText(modelText)

		self.eModel.modelView:SetModelText(showText, ClientConst.ModelTextType.Default)
	end

	self:postComponentMethod("EVENT_onModelLoaded")
	self:setModelLoaded(true)
end

function ClientHomeStaticEntity:setScale(scale)
	self:setPositionAgentScale(scale.x, scale.y, scale.z)
	self:postComponentMethod("EVENT_onEntityScaleChanged")
end

function ClientHomeStaticEntity:getScale()
	return self:getPositionAgentScale()
end

function ClientHomeStaticEntity:onEntityPositionChanged()
	self:postComponentMethod("EVENT_onEntityPositionChanged")
	self:flushBatchRenderer()
end

function ClientHomeStaticEntity:getInteractionListData()
	return nil
end

function ClientHomeStaticEntity:interact(interactUnit)
	return
end

return ClientHomeStaticEntity
