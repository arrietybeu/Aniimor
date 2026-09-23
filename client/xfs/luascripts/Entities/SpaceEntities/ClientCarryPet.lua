-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\ClientCarryPet.lua

local class = require("Core.Framework.Class")
local ClientPuppet = require("Entities.SpaceEntities.ClientPuppet")
local ClientBeCarryComponent = require("Entities.SpaceEntities.CommonComponent.ClientBeCarryComponent")
local PetInfo = require("CustomTypes.PetInfo")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local InteractionConst = require("Common.Const.InteractionConst")
local ClientCarryPet = class.Class("ClientCarryPet", ClientPuppet)
local CarryPetComponents = {
	ClientBeCarryComponent
}

class.AddComponents(ClientCarryPet, CarryPetComponents)

function ClientCarryPet:ctor(entityId)
	ClientCarryPet.super.ctor(self, entityId)

	self.isCarryPet = true
end

function ClientCarryPet:init(bdict)
	ClientCarryPet.super.init(self, bdict)

	self.petInfo = PetInfo(bdict.petInfo or {})

	return true
end

function ClientCarryPet:onModelRefreshed()
	ClientCarryPet.super.onModelRefreshed(self)

	if self.attachTargetId then
		local target = pg.getEntity(self.attachTargetId)

		if target and target.carryEnt ~= self then
			target:carryEntImp(self)
		end
	end
end

function ClientCarryPet:repr()
	return string.format("ClientCarryPet(entityId=%s, actorId=%d)", self.id, self.actorId or 0)
end

return ClientCarryPet
