-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Utils\\VehicleUtils.lua

local Const = require("Common.Const.Const")
local vehicle_seat_data = require("Data.vehicle_seat_data")
local VehicleUtils = {}

function VehicleUtils.isPetOnlyVehicleConfig(vehicleConfig)
	local seats = vehicleConfig and vehicleConfig.seats

	if not seats or #seats == 0 then
		return false
	end

	local petActorFilter = 2^Const.ACTOR_TYPE_PET

	for _, seatId in ipairs(seats) do
		local seatConfig = vehicle_seat_data[seatId]

		if not seatConfig or seatConfig.actorFilter ~= petActorFilter or not seatConfig.petAttachId and not seatConfig.homePetAttachId then
			return false
		end
	end

	return true
end

function VehicleUtils.isPetOnlyVehicle(vehicle)
	if not vehicle or not vehicle.getVehicleConfig then
		return false
	end

	return VehicleUtils.isPetOnlyVehicleConfig(vehicle:getVehicleConfig())
end

return VehicleUtils
