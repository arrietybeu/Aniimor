-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\VehicleEntities\\ClientBonfire.lua

local class = require("Core.Framework.Class")
local ClientVehicle = require("Entities.SpaceEntities.VehicleEntities.ClientVehicle")
local Utils = require("Common.Utils.Utils")
local ResLoader = require("GameApp.ResLoad.ResLoader")
local AddressDataConst = require("Const.AddressDataConst")
local ClientAudioComponent = require("Entities.SpaceEntities.CommonComponent.ClientAudioComponent")
local ClientBonfire = class.Class("ClientBonfire", ClientVehicle)
local Components = {
	ClientAudioComponent
}

class.AddComponents(ClientBonfire, Components)

function ClientBonfire:ctor(entityId)
	ClientBonfire.super.ctor(self, entityId)
end

function ClientBonfire:init(bdict)
	ClientBonfire.super.init(self, bdict)

	self.entityCanMove = false

	return true
end

function ClientBonfire:repr()
	return string.format("ClientBonfire(entityId=%s, actorId=%d)", self.id, self.actorId)
end

function ClientBonfire:refreshAppearance()
	ClientBonfire.super.refreshAppearance(self)
	self:playSoundEvent("SFX_SceneObject_Bonfire_Loop")
end

function ClientBonfire:onEntityMount(entity, seatId)
	ClientBonfire.super.onEntityMount(self, entity, seatId)
	self.logger:debug("bonfire %s onEntityMount entity=%s seatId=%s", self:repr(), entity:repr(), seatId)
	self:playEffectRaw(AddressDataConst.BONFIRE_EFF, {
		scale = Vector3(0.5, 0.5, 0.5)
	})
	self:playSoundEvent("SFX_SceneObject_BlazingBonfire_effect")
end

return ClientBonfire
