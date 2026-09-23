-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\ClientVirtualTarget.lua

local Class = require("Core.Framework.Class")
local VirtualEntUtils = require("Common.Utils.VirtualEntUtils")
local ClientEntity = require("Core.Client.ClientEntity")
local Const = require("Common.Const.Const")
local ClientPosRotComponent = require("Entities.SpaceEntities.CommonComponent.ClientPosRotComponent")
local ClientAoiComponent = require("Entities.SpaceEntities.CommonComponent.ClientAoiComponent")
local ClientVirtualTarget = Class.Class("ClientVirtualTarget", ClientEntity)
local ClientVirtualNpcComponents = {
	ClientPosRotComponent,
	ClientAoiComponent
}

Class.AddComponents(ClientVirtualTarget, ClientVirtualNpcComponents)

function ClientVirtualTarget:init(dict)
	self.actorId = VirtualEntUtils.getNewVirtualEntActorId()
	self.actorType = Const.ACTOR_TYPE_VIRTUAL

	ClientVirtualTarget.super.init(self, dict)

	self.isVirtualTarget = true
	self.camp = 3001

	return true
end

function ClientVirtualTarget:canBeLocked(dict)
	return true
end

function ClientVirtualTarget:getLockPosition()
	return self:getPosition()
end

function ClientVirtualTarget:getLockPartPosition()
	return self:getPosition()
end

return ClientVirtualTarget
