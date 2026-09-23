-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\ClientSimpleVirtualEntityWithPhysics.lua

local Class = require("Core.Framework.Class")
local ClientSimpleVirtualEntity = require("Entities.ClientSimpleVirtualEntity")
local ClientPhysicsComponent = require("Entities.SpaceEntities.CommonComponent.ClientPhysicsComponent")
local ClientConst = require("Const.ClientConst")
local ClientSimpleVirtualEntityWithPhysics = Class.Class("ClientSimpleVirtualEntityWithPhysics", ClientSimpleVirtualEntity)
local ClientVirtualWithPhysicsComponents = {
	ClientPhysicsComponent
}

Class.AddComponents(ClientSimpleVirtualEntityWithPhysics, ClientVirtualWithPhysicsComponents)

function ClientSimpleVirtualEntityWithPhysics:initializeComponents()
	ClientSimpleVirtualEntityWithPhysics.super.initializeComponents(self)
end

function ClientSimpleVirtualEntityWithPhysics:postInitializeComponents()
	ClientSimpleVirtualEntityWithPhysics.super.postInitializeComponents(self)
end

return ClientSimpleVirtualEntityWithPhysics
