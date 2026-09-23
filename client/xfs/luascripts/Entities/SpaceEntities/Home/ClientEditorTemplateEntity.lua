-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\Home\\ClientEditorTemplateEntity.lua

local Class = require("Core.Framework.Class")
local ClientConst = require("Const.ClientConst")
local AddressDataConst = require("Const.AddressDataConst")
local ClientModelEntity = require("Entities.ClientModelEntity")
local Const = require("Common.Const.Const")
local HomeEditorUtils = CS.FunPlus.WorldX.Home.HomeEditorUtils
local ClientEntityEditorComponent = require("Entities.SpaceEntities.Home.ClientEntityEditorComponent")
local Utils = require("Common.Utils.Utils")
local ClientEditorTemplateEntity = Class.Class("ClientEditorTemplateEntity", ClientModelEntity)
local ClientHomeEditorTemplateEntityComponents = {
	ClientEntityEditorComponent
}

Class.AddComponents(ClientEditorTemplateEntity, ClientHomeEditorTemplateEntityComponents)

function ClientEditorTemplateEntity:ctor(entityId)
	ClientEditorTemplateEntity.super.ctor(self, entityId)

	self.actorType = Const.ACTOR_TYPE_VIRTUAL
end

function ClientEditorTemplateEntity:init(dict)
	local result = ClientEditorTemplateEntity.super.init(self, dict)

	self.baseTransMatrixInv = dict.baseTransMatrixInv
	self.templateData = dict.templateData or {}
	self.initPosition = dict.initPosition
	self.initRotation = dict.initRotation
	self.initScale = dict.initScale
	self.originEntity = dict.originEntity

	return result
end

function ClientEditorTemplateEntity:postInit(dict)
	ClientEditorTemplateEntity.super.postInit(self, dict)
end

function ClientEditorTemplateEntity:destroy()
	ClientEditorTemplateEntity.super.destroy(self)
end

function ClientEditorTemplateEntity:initializeComponents()
	self:setPosition(self.initPosition)
	self:setRotation(self.initRotation)

	if self.initScale then
		self:setScale(self.initScale)
	end

	self:postComponentMethod("EVENT_AddEComponent")
	self:addEModelMonoComponent(Const.COMPONENT_IDX_PHYSX)
	self:addEModelComponent(Const.COMPONENT_IDX_ITEM)
end

function ClientEditorTemplateEntity:refreshAppearance()
	ClientEditorTemplateEntity.super.refreshAppearance(self)
	self:onSetTemplateAppearance()
end

function ClientEditorTemplateEntity:onSetTemplateAppearance()
	local modelScale = self.templateData.prefabScale or 1

	self:setScaleNumber(modelScale)
	self.eModel:SetModelResId(Const.COMPONENT_IDX_ITEM, self.templateData.prefabResID, ClientConst.InstantiatePriority.Urgent, ClientConst.InstantiatePriority.High)
	self.eModel.shaderView:SetShadowType(ClientConst.ShaderViewShadowType.Dynamic)
end

function ClientEditorTemplateEntity:getBoundAreaRange(isLocal)
	local boundSize = self:getBoundSize()

	if not isLocal then
		Vector3.enableCreateFromCache()

		local rotation = self:getRotation()

		if self.baseTransMatrixInv then
			rotation = self.baseTransMatrixInv.rotation * rotation
		end

		local isVertical = Utils.checkRotationIsVertical(rotation)

		Vector3.disableCreateFromCache()

		if isVertical then
			return -boundSize[2] * 0.5, boundSize[2] * 0.5, -boundSize[1] * 0.5, boundSize[1] * 0.5
		end
	end

	return -boundSize[1] * 0.5, boundSize[1] * 0.5, -boundSize[2] * 0.5, boundSize[2] * 0.5, 0, self:getBoundHeight()
end

function ClientEditorTemplateEntity:getConfigData()
	return self.templateData
end

function ClientEditorTemplateEntity:onEntityPositionChanged()
	self:postComponentMethod("EVENT_onEntityPositionChanged")
end

function ClientEditorTemplateEntity:onItemModelLoaded()
	self.isModelLoaded = true

	self.eModel:SetHomeObjectTemplateCollider(Const.COMPONENT_IDX_PHYSX)
	self.eModel:SetTag(Const.COMPONENT_IDX_PHYSX, Const.TAG_ACTOR, self.actorId, 0)

	local modelText = self.templateData.modelText

	if modelText then
		local showText = pg.getLocalizationText(modelText)

		self.eModel.modelView:SetModelText(showText, ClientConst.ModelTextType.Default)
	end
end

function ClientEditorTemplateEntity:checkHitEntity(screenPos, hitEntities)
	if hitEntities then
		for _, ent in ipairs(hitEntities) do
			if ent == self then
				return true
			end
		end
	end

	return self:checkHitPositionInBounds(screenPos)
end

function ClientEditorTemplateEntity:checkHitPositionInBounds(screenPos)
	local valid, placePos = HomeEditorUtils.GetRaycastPlacePosition(screenPos, self:getPosition().y)

	if not valid then
		return false
	end

	local boundSize = self:getBaseBoundSize()
	local minX, maxX, minZ, maxZ = -boundSize[1] * 0.5, boundSize[1] * 0.5, -boundSize[2] * 0.5, boundSize[2] * 0.5
	local _lpx, _, _lpz = self.eModel:PositionAgentInverseTransformPointEx(placePos.x, placePos.y, placePos.z)

	return minX <= _lpx and _lpx <= maxX and minZ <= _lpz and _lpz <= maxZ
end

function ClientEditorTemplateEntity:setEditParent(parent)
	if self.editParent ~= parent then
		self.editParent = parent

		self:postComponentMethod("EVENT_onEditParentChanged")
	end
end

function ClientEditorTemplateEntity:getScale()
	return self:getPositionAgentScale()
end

function ClientEditorTemplateEntity:setScale(scale)
	self:setPositionAgentScale(scale.x, scale.y, scale.z)
	self:postComponentMethod("EVENT_onEntityScaleChanged")
end

return ClientEditorTemplateEntity
