-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\HomeCar\\ClientHomeCarTemplateEntity.lua

local Class = require("Core.Framework.Class")
local ClientConst = require("Const.ClientConst")
local ClientEditorTemplateEntity = require("Entities.SpaceEntities.Home.ClientEditorTemplateEntity")
local Const = require("Common.Const.Const")
local ClientHomeCarEditorComponent = require("Entities.SpaceEntities.HomeCar.ClientHomeCarEditorComponent")
local ClientHomeCarTemplateEditorComponent = require("Entities.SpaceEntities.HomeCar.ClientHomeCarTemplateEditorComponent")
local ClientAnimatorComponent = require("Entities.SpaceEntities.CommonComponent.ClientAnimatorComponent")
local ClientHomeCarTemplateEntity = Class.Class("ClientHomeCarTemplateEntity", ClientEditorTemplateEntity)
local ClientHomeCarTemplateEntityComponents = {
	ClientHomeCarEditorComponent,
	ClientHomeCarTemplateEditorComponent,
	ClientAnimatorComponent
}

Class.AddComponents(ClientHomeCarTemplateEntity, ClientHomeCarTemplateEntityComponents)

function ClientHomeCarTemplateEntity:ctor(entityId)
	ClientHomeCarTemplateEntity.super.ctor(self, entityId)

	self.actorType = Const.ACTOR_TYPE_VIRTUAL
end

function ClientHomeCarTemplateEntity:init(dict)
	local result = ClientHomeCarTemplateEntity.super.init(self, dict)

	self.ornamentId = dict.ornamentId
	self.areaId = dict.areaId
	self.playerUID = dict.playerUID
	self.homeTemplateId = dict.homeTemplateId
	self.originEntity = dict.originEntity
	self.isPreview = dict.isPreview
	self.editor = dict.editor
	self.carGroup = pg.game.homeCar:getHomeCarGroup(self.playerUID)

	return result
end

function ClientHomeCarTemplateEntity:start()
	self.carGroup:registerVirtualHomeEnt(self.ornamentId, self)
	ClientHomeCarTemplateEntity.super.start(self)
end

function ClientHomeCarTemplateEntity:destroy()
	if self.carGroup then
		self.carGroup:unregisterVirtualHomeEnt(self.ornamentId, self)
	end

	ClientHomeCarTemplateEntity.super.destroy(self)
end

function ClientHomeCarTemplateEntity:onEntityPositionChanged()
	if self.carGroup then
		self.carGroup:onOrnamentPositionChanged(self.ornamentId)
	end

	ClientHomeCarTemplateEntity.super.onEntityPositionChanged(self)
end

function ClientHomeCarTemplateEntity:onItemModelLoaded()
	ClientHomeCarTemplateEntity.super.onItemModelLoaded(self)

	if self.originEntity and self.originEntity._needStateInteraction and self.originEntity.isOrnamentSwitchOpen and self.originEntity:isOrnamentSwitchOpen() then
		local configData = self.templateData

		if configData and configData.interactiveOpenAnim then
			self:playAnimancerAnimAtEnd(configData.interactiveOpenAnim)
		end
	end

	self:postComponentMethod("EVENT_onModelLoaded")
	self:setModelLoaded(true)
end

function ClientHomeCarTemplateEntity:getHomelandConfigData()
	return self.templateData
end

return ClientHomeCarTemplateEntity
