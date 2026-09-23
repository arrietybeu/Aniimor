-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\ClientResPointEntity.lua

local Class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local ClientEntity = require("Core.Client.ClientEntity")
local ClientPosRotComponent = require("Entities.SpaceEntities.CommonComponent.ClientPosRotComponent")
local ClientAoiComponent = require("Entities.SpaceEntities.CommonComponent.ClientAoiComponent")
local ClientAuthorityComponent = require("Entities.SpaceEntities.CommonComponent.ClientAuthorityComponent")
local ClientResPointComponent = require("Entities.SpaceEntities.CommonComponent.ClientResPointComponent")
local ClientLODComponent = require("Entities.SpaceEntities.CommonComponent.ClientLODComponent")
local ClientResPointEntity = Class.Class("ClientResPointEntity", ClientEntity)
local ClientResPointComponents = {
	ClientPosRotComponent,
	ClientLODComponent,
	ClientAoiComponent,
	ClientAuthorityComponent,
	ClientResPointComponent
}

Class.AddComponents(ClientResPointEntity, ClientResPointComponents)

function ClientResPointEntity:ctor(entityId)
	ClientResPointEntity.super.ctor(self, entityId)

	self.actorType = Const.ACTOR_TYPE_RESPOINT
end

function ClientResPointEntity:init(initInfo)
	ClientResPointEntity.super.init(self, initInfo)

	self.staticId = initInfo.staticId
	self.entityCanMove = false

	return true
end

function ClientResPointEntity:onEnterSpace()
	self:postComponentMethod("onEnterSpace")
end

function ClientResPointEntity:onLeaveSpace()
	self:postComponentMethod("onLeaveSpace")
end

return ClientResPointEntity
