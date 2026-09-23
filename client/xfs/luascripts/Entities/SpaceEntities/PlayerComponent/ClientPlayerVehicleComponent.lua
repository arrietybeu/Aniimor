-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientPlayerVehicleComponent.lua

local class = require("Core.Framework.Class")
local Utils = require("Common.Utils.Utils")
local UIConst = require("Const.UIConst")
local Const = require("Common.Const.Const")
local ClientPlayerVehicleComponent = class.Component("ClientPlayerVehicleComponent")

function ClientPlayerVehicleComponent:ctor()
	self._inRidingMap = {}
end

function ClientPlayerVehicleComponent:registerInRiding(ent, vehicle)
	if ent.authority ~= Const.AUTHORITY_MASTER then
		return
	end

	if not Utils.isPet(ent) and not Utils.isPlayer(ent) then
		return
	end

	self._inRidingMap[ent.id] = vehicle

	self:refreshInRiding()
end

function ClientPlayerVehicleComponent:unregisterInRiding(ent)
	if not ent.authority == Const.AUTHORITY_MASTER then
		return
	end

	if not Utils.isPet(ent) and not Utils.isPlayer(ent) then
		return
	end

	self._inRidingMap[ent.id] = nil

	self:refreshInRiding()
end

function ClientPlayerVehicleComponent:refreshInRiding()
	local entId = next(self._inRidingMap)
	local vehicle = self._inRidingMap[entId]

	if self.lastVehicle ~= vehicle then
		if vehicle ~= nil then
			if vehicle.getActorController then
				pg.game.controller:switchController(vehicle:getActorController(self))
			end

			vehicle:enterControl()
			pg.global.ui:open(UIConst.UI_ID_VEHICLE_INTERATION_PANEL, {
				vehicleId = vehicle.id
			})
		else
			pg.game.controller:resetController()

			if self.lastVehicle then
				self.lastVehicle:exitControl()
			end

			pg.global.ui:close(UIConst.UI_ID_VEHICLE_INTERATION_PANEL)
		end

		self.lastVehicle = vehicle
	end
end

function ClientPlayerVehicleComponent:destroy()
	pg.game.controller:resetController()

	if self.lastVehicle then
		self.lastVehicle:exitControl()

		self.lastVehicle = nil
	end

	pg.global.ui:close(UIConst.UI_ID_VEHICLE_INTERATION_PANEL)
end

function ClientPlayerVehicleComponent:forceDetachVehicleOnTeleport()
	local detached = false

	local function tryDismount(vehicle)
		if vehicle ~= nil and vehicle.featureVehicle and NotNil(vehicle.featureVehicle) then
			vehicle.featureVehicle:OnDismount()

			detached = true
		end
	end

	for _, vehicle in pairs(self._inRidingMap) do
		tryDismount(vehicle)
	end

	local curController = pg.game and pg.game.controller and pg.game.controller.curController

	if curController and curController.vehicle then
		tryDismount(curController.vehicle)
	end

	if self.isControllingPet and self:isControllingPet() and self.getCurPetEntity then
		local petEntity = self:getCurPetEntity()

		if petEntity and petEntity.attaching and petEntity:attaching() and petEntity.detach then
			petEntity:detach()

			detached = true
		end
	end

	if not detached then
		if self.clearVehicleSeatAppearances then
			self:clearVehicleSeatAppearances()
		end

		return
	end

	self._inRidingMap = {}

	self:refreshInRiding()

	if self.clearVehicleSeatAppearances then
		self:clearVehicleSeatAppearances()
	end
end

function ClientPlayerVehicleComponent:isRidingDandelion()
	local flag = false

	if pg.me.onVehicleActorId <= 0 then
		return flag
	end

	local curVehicle = pg.getEntityByActorId(tonumber(pg.me.onVehicleActorId))

	if curVehicle and curVehicle:getConfigData().vehicleType == "Dandelion" then
		flag = true
	end

	return flag
end

return ClientPlayerVehicleComponent
