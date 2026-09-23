-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\HomeCar\\ClientHomeCarOrnamentBase.lua

local Class = require("Core.Framework.Class")
local ClientModelEntity = require("Entities.ClientModelEntity")
local Const = require("Common.Const.Const")
local ClientConst = require("Const.ClientConst")
local ClientEffectComponent = require("Entities.SpaceEntities.PlayerComponent.ClientEffectComponent")
local ClientAudioComponent = require("Entities.SpaceEntities.CommonComponent.ClientAudioComponent")
local ClientPhysicsComponent = require("Entities.SpaceEntities.CommonComponent.ClientPhysicsComponent")
local ClientHomeCarOrnamentComponent = require("Entities.SpaceEntities.HomeCar.ClientHomeCarOrnamentComponent")
local ClientEntityEditorComponent = require("Entities.SpaceEntities.Home.ClientEntityEditorComponent")
local ClientHomeCarOrnamentBase = Class.Class("ClientHomeCarOrnamentBase", ClientModelEntity)
local ClientHomeCarEntityBaseComponents = {
	ClientEffectComponent,
	ClientAudioComponent,
	ClientEntityEditorComponent,
	ClientHomeCarOrnamentComponent,
	ClientPhysicsComponent
}

Class.AddComponents(ClientHomeCarOrnamentBase, ClientHomeCarEntityBaseComponents)

function ClientHomeCarOrnamentBase:ctor(entityId)
	ClientHomeCarOrnamentBase.super.ctor(self, entityId)

	self.actorType = Const.ACTOR_TYPE_HOME_OBJECT
end

function ClientHomeCarOrnamentBase:init(dict)
	ClientHomeCarOrnamentBase.super.init(self, dict)
end

function ClientHomeCarOrnamentBase:start()
	ClientHomeCarOrnamentBase.super.start(self)
end

function ClientHomeCarOrnamentBase:initializeComponents()
	ClientHomeCarOrnamentBase.super.initializeComponents(self)
end

function ClientHomeCarOrnamentBase:destroy()
	ClientHomeCarOrnamentBase.super.destroy(self)
end

function ClientHomeCarOrnamentBase:getCsEntityType()
	return ClientConst.ENTITY_CS_TYPE.HOME
end

function ClientHomeCarOrnamentBase:checkCanInteract(interactUnit)
	if not self.visible then
		return false
	end

	return true
end

function ClientHomeCarOrnamentBase:getConfigData()
	return self:getHomelandConfigData()
end

function ClientHomeCarOrnamentBase:interact(interactUnit)
	return
end

return ClientHomeCarOrnamentBase
