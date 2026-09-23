-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\Home\\ClientHomeEntityBase.lua

local Class = require("Core.Framework.Class")
local ClientModelEntity = require("Entities.ClientModelEntity")
local Const = require("Common.Const.Const")
local ClientHomelandComponent = require("Entities.SpaceEntities.Home.ClientHomelandComponent")
local ClientConst = require("Const.ClientConst")
local HomeObjectData = require("Data.home_object_data")
local ClientPhysicsComponent = require("Entities.SpaceEntities.CommonComponent.ClientPhysicsComponent")
local ClientHomeEntityBase = Class.Class("ClientHomeEntityBase", ClientModelEntity)
local ClientHomeEntityBaseComponents = {
	ClientHomelandComponent,
	ClientPhysicsComponent
}

Class.AddComponents(ClientHomeEntityBase, ClientHomeEntityBaseComponents)

function ClientHomeEntityBase:ctor(entityId)
	ClientHomeEntityBase.super.ctor(self, entityId)

	self.actorType = Const.ACTOR_TYPE_HOME_OBJECT
end

function ClientHomeEntityBase:init(dict)
	ClientHomeEntityBase.super.init(self, dict)
end

function ClientHomeEntityBase:start()
	ClientHomeEntityBase.super.start(self)
end

function ClientHomeEntityBase:initializeComponents()
	ClientHomeEntityBase.super.initializeComponents(self)
end

function ClientHomeEntityBase:destroy()
	ClientHomeEntityBase.super.destroy(self)
end

function ClientHomeEntityBase:getCsEntityType()
	return ClientConst.ENTITY_CS_TYPE.HOME
end

function ClientHomeEntityBase:getConfigData()
	return self:getHomelandConfigData()
end

function ClientHomeEntityBase:checkCanInteract(interactUnit)
	if not self.visible then
		return false
	end

	return true
end

function ClientHomeEntityBase:interact(interactUnit)
	return
end

return ClientHomeEntityBase
