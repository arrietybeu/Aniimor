-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\Home\\ClientHomeFacilityVehicle.lua

local Class = require("Core.Framework.Class")
local ClientHomeFacility = require("Entities.SpaceEntities.Home.ClientHomeFacility")
local ClientSeatComponent = require("Entities.SpaceEntities.CommonComponent.ClientSeatComponent")
local ClientHomeVehicleComponent = require("Entities.SpaceEntities.Home.ClientHomeVehicleComponent")
local BenchController = require("GameApp.Controller.BenchController")
local ClientHomeFacilityVehicle = Class.Class("ClientHomeFacilityVehicle", ClientHomeFacility)
local Components = {
	ClientSeatComponent,
	ClientHomeVehicleComponent
}

Class.AddComponents(ClientHomeFacilityVehicle, Components)

function ClientHomeFacilityVehicle:ctor(entityId)
	ClientHomeFacilityVehicle.super.ctor(self, entityId)

	self.isClientEnt = false
end

function ClientHomeFacilityVehicle:init(initInfo)
	local result = ClientHomeFacilityVehicle.super.init(self, initInfo)

	return result
end

function ClientHomeFacilityVehicle:getActorController(player)
	return BenchController.new(player, self)
end

return ClientHomeFacilityVehicle
