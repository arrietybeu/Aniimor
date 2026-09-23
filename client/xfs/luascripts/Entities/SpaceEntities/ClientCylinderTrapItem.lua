-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\ClientCylinderTrapItem.lua

local ClientModelEntity = require("Entities.ClientModelEntity")
local Class = require("Core.Framework.Class")
local ClientAoiComponent = require("Entities.SpaceEntities.CommonComponent.ClientAoiComponent")
local ClientDebugComponent = require("Entities.SpaceEntities.PlayerComponent.ClientDebugComponent")
local ClientCylinderTrapItem = Class.Class("ClientCylinderTrapItem", ClientModelEntity)
local components = {
	ClientAoiComponent
}

function ClientCylinderTrapItem:ctor(entityId)
	ClientCylinderTrapItem.super.ctor(self, entityId)

	self.isClientEnt = false
end

Class.AddComponents(ClientCylinderTrapItem, components)

return ClientCylinderTrapItem
