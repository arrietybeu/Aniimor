-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\Home\\ClientHomeEditorTemplateEntity.lua

local Class = require("Core.Framework.Class")
local ClientConst = require("Const.ClientConst")
local AddressDataConst = require("Const.AddressDataConst")
local ClientHomeEditorComponent = require("Entities.SpaceEntities.Home.ClientHomeEditorComponent")
local ClientHomeEditorTopLogoComponent = require("Entities.SpaceEntities.Home.ClientHomeEditorTopLogoComponent")
local ClientEditorTemplateEntity = require("Entities.SpaceEntities.Home.ClientEditorTemplateEntity")
local ClientEffectComponent = require("Entities.SpaceEntities.PlayerComponent.ClientEffectComponent")
local ClientEntityEditorComponent = require("Entities.SpaceEntities.Home.ClientEntityEditorComponent")
local ClientModelEntity = require("Entities.ClientModelEntity")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local HomeEditorUtils = CS.FunPlus.WorldX.Home.HomeEditorUtils
local ClientHomeTemplateEditorComponent = require("Entities.SpaceEntities.Home.ClientHomeTemplateEditorComponent")
local ClientAnimatorComponent = require("Entities.SpaceEntities.CommonComponent.ClientAnimatorComponent")
local ClientHomeEditorTemplateEntity = Class.Class("ClientHomeEditorTemplateEntity", ClientEditorTemplateEntity)
local ClientHomeEditorTemplateEntityComponents = {
	ClientHomeEditorComponent,
	ClientHomeEditorTopLogoComponent,
	ClientHomeTemplateEditorComponent,
	ClientAnimatorComponent
}

Class.AddComponents(ClientHomeEditorTemplateEntity, ClientHomeEditorTemplateEntityComponents)

function ClientHomeEditorTemplateEntity:ctor(entityId)
	ClientHomeEditorTemplateEntity.super.ctor(self, entityId)

	self.actorType = Const.ACTOR_TYPE_VIRTUAL
end

function ClientHomeEditorTemplateEntity:init(dict)
	local result = ClientHomeEditorTemplateEntity.super.init(self, dict)

	self.ornamentId = dict.ornamentId
	self.areaId = dict.areaId
	self.templateEntityType = dict.templateType
	self.virtualOrnamentInfo = dict.ornamentInfo
	self.homeTemplateId = dict.homeTemplateId
	self.originEntity = dict.originEntity
	self.isPreview = dict.isPreview
	self.editor = dict.editor

	if self.ornamentId and self.templateEntityType == Const.HomelandEntType.Ornament and not dict.isPreview then
		self.needEnvSimulate = true
	end

	return result
end

function ClientHomeEditorTemplateEntity:start()
	if self.needEnvSimulate then
		pg.game.home:registerVirtualHomeEnt(self.ornamentId, self)
		pg.game.home.editor.envEditor:addOrnament(self.ornamentId, self.virtualOrnamentInfo)
	end
end

function ClientHomeEditorTemplateEntity:destroy()
	if self.needEnvSimulate then
		pg.game.home.editor.envEditor:removeOrnament(self.ornamentId)
		pg.game.home:unregisterVirtualHomeEnt(self.ornamentId, self)
	end

	self:clearOverlapHint()
	ClientHomeEditorTemplateEntity.super.destroy(self)
end

function ClientHomeEditorTemplateEntity:onEntityPositionChanged()
	if self.needEnvSimulate then
		pg.game.home:onOrnamentPositionChanged(self.ornamentId, self, true)

		local px, py, pz = self.eModel:GetPositionAgentPosEx()
		local rx, ry, rz, rw = self.eModel:GetPositionAgentRotationEx()

		Vector3.enableCreateFromCache()
		HomeLandUtils.fillOrnamentTransform(self.virtualOrnamentInfo, self.editor:getLocalPosition(Vector3.New(px, py, pz)), self.editor:getLocalRotation(Quaternion(rx, ry, rz, rw)), nil)
		Vector3.disableCreateFromCache()
		pg.game.home.editor.envEditor:updateOrnament(self.ornamentId, self.virtualOrnamentInfo)
	end

	ClientHomeEditorTemplateEntity.super.onEntityPositionChanged(self)
end

function ClientHomeEditorTemplateEntity:onSetTemplateAppearance()
	if self.templateEntityType ~= Const.HomelandEntType.Pet then
		local modelScale = self.templateData.prefabScale or 1

		self:setScaleNumber(modelScale)
		self.eModel:SetModelResId(Const.COMPONENT_IDX_ITEM, self.templateData.prefabResID, ClientConst.InstantiatePriority.Urgent, ClientConst.InstantiatePriority.High)
	end

	self.eModel.shaderView:SetShadowType(ClientConst.ShaderViewShadowType.Dynamic)
end

function ClientHomeEditorTemplateEntity:getHomelandConfigData()
	return self.templateData
end

function ClientHomeEditorTemplateEntity:onItemModelLoaded()
	ClientHomeEditorTemplateEntity.super.onItemModelLoaded(self)

	if self.originEntity and self.originEntity._needStateInteraction and self.originEntity.isOrnamentSwitchOpen and self.originEntity:isOrnamentSwitchOpen() then
		local configData = self.templateData

		if configData and configData.interactiveOpenAnim then
			self:playAnimancerAnimAtEnd(configData.interactiveOpenAnim)
		end
	end

	self:postComponentMethod("EVENT_onModelLoaded")
	self:setModelLoaded(true)
end

return ClientHomeEditorTemplateEntity
