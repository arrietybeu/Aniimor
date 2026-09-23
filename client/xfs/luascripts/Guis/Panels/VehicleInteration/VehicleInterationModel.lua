-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\VehicleInteration\\VehicleInterationModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local VehicleInterationModel = Class.LightClass("VehicleInterationModel", UIModel)
local vehicleSeatData = require("Data.vehicle_seat_data")
local vehicleData = require("Data.vehicle_data")
local vehicleSeatSkillData = require("Data.vehicle_seat_skill_data")
local Const = require("Common.Const.Const")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Utils = require("Common.Utils.Utils")

function VehicleInterationModel:ctor()
	self.SEAT_ENTITY_TYPE = {
		PET = 2,
		PLAYER = 1,
		EMPTY = 0,
		OTHER_PET = 4,
		OTHER = 3
	}
	self.SEAT_TYPE = {
		All = 0,
		PLAYER = 1,
		PET = 2
	}
	self.SEAT_ACT_TYPE = {
		TICK = 2,
		EXCHANGE = 1,
		ENTER = 0,
		EXIT = 3
	}
end

local seatListData = {}

function VehicleInterationModel:getVehicleSeatList(vehicleId)
	seatListData = {}

	local temp = {}
	local seatData
	local curVehicle = pg.getEntity(vehicleId)

	if not curVehicle then
		return seatListData
	end

	local vehicleListTbData = curVehicle:getVehicleConfig()

	for i, v in ipairs(vehicleListTbData.seats) do
		temp = {
			seatId = v,
			vehicleId = vehicleId,
			cfgVehicleId = curVehicle.templateId or 0,
			vehicleActorId = curVehicle.actorId or 0
		}
		temp.actorId, temp.steatIndex = self:setActorIdBySeatId(curVehicle, temp.seatId)
		seatData = vehicleSeatData[v]
		temp.actorFilter = seatData.actorFilter or 0
		temp.forbidBigBodyLevel = seatData.forbidBigBodyLevel or false
		temp.skillGroup = seatData.skillGroup or {}
		temp.duration = vehicleListTbData.duration or 0
		temp.seatManage = vehicleListTbData.seatManage or 0
		temp.hideCountDown = vehicleListTbData.hideCountDown == 1 or false

		table.insert(seatListData, temp)
	end

	return seatListData
end

function VehicleInterationModel:setActorIdBySeatId(curVehicle, seatId)
	local actorId = 0
	local seatIndex = 0
	local seatDataMap = curVehicle.entityMap
	local seats = vehicleData[curVehicle.templateId].seats

	for k, v in pairs(seatDataMap) do
		if seats[v] and seatId == seats[v] then
			seatIndex = v
			actorId = k
		end
	end

	for i = 1, #seats do
		if seatId == seats[i] and seatIndex == 0 then
			seatIndex = i
		end
	end

	return actorId, seatIndex
end

local interListData = {}

function VehicleInterationModel:getVehicleSeatInterationList(seatId)
	interListData = {}

	local temp = {}
	local seatDataTb
	local myVehicleSeatId = pg.pawn.seatId

	if myVehicleSeatId == 0 then
		return interListData
	end

	for i, v in ipairs(seatListData) do
		if v.seatId == seatId then
			for j, w in ipairs(v.skillGroup) do
				seatDataTb = vehicleSeatSkillData[w]

				if seatDataTb then
					temp = {
						skillId = w or 0,
						vehicleSkill = seatDataTb.vehicleSkill or 0,
						name = seatDataTb.vehicleSkillName,
						icon = seatDataTb.vehicleSkillIcon
					}

					table.insert(interListData, temp)
				end
			end

			return interListData
		end
	end

	return interListData
end

function VehicleInterationModel:getSeatTypeBySeatId(seatId)
	for i, v in ipairs(seatListData) do
		if seatId == v.seatId then
			local forbidPlayer = bit.band(2^Const.ACTOR_TYPE_PLAYER, v.actorFilter) == 0
			local forbidPet = bit.band(2^Const.ACTOR_TYPE_PET, v.actorFilter) == 0

			if forbidPet == false and forbidPlayer == false then
				return self.SEAT_TYPE.All
			elseif forbidPet == true then
				return self.SEAT_TYPE.PLAYER
			elseif forbidPlayer == true then
				return self.SEAT_TYPE.PET
			end
		end
	end

	return self.SEAT_TYPE.All
end

function VehicleInterationModel:getSeatOwnState(seatId)
	local myVehicleId = pg.pawn.onVehicleActorId
	local myVehicleSeatId = pg.pawn.seatId
	local petVehicleSeatId = 0
	local petVehicleId = 0

	if pg.me:getCurPetEntity() then
		petVehicleId = pg.me:getCurPetEntity().onVehicleActorId
		petVehicleSeatId = pg.me:getCurPetEntity().seatId
	end

	local seatState = self.SEAT_ENTITY_TYPE.EMPTY

	for i, v in ipairs(seatListData) do
		if seatId == v.seatId and myVehicleId == v.vehicleActorId then
			if v.actorId == 0 then
				seatState = self.SEAT_ENTITY_TYPE.EMPTY
			elseif pg.pawn.actorId == v.actorId then
				seatState = self.SEAT_ENTITY_TYPE.PLAYER
			elseif pg.me:getCurPetEntity() and pg.me:getCurPetEntity().actorId == v.actorId then
				seatState = self.SEAT_ENTITY_TYPE.PET
			else
				local curAntity = pg.getEntityByActorId(v.actorId)

				if curAntity then
					seatState = Utils.isPet(curAntity) and self.SEAT_ENTITY_TYPE.OTHER_PET or self.SEAT_ENTITY_TYPE.OTHER
				end
			end

			return seatState
		end
	end

	return seatState
end

function VehicleInterationModel:getSeatSelBtnList(seatId, steatIndex)
	local seatSelList = {}
	local seatState = self:getSeatOwnState(seatId)
	local seatType = self:getSeatTypeBySeatId(seatId)

	if self.SEAT_ENTITY_TYPE.OTHER == seatState or self.SEAT_ENTITY_TYPE.OTHER_PET == seatState then
		-- block empty
	else
		if self.SEAT_ENTITY_TYPE.EMPTY == seatState then
			seatSelList = {
				{
					name = pg.getGameString("VEHICLE_SEAT_ENTER"),
					seat = self.SEAT_ACT_TYPE.ENTER,
					seatId = seatId,
					steatIndex = steatIndex
				}
			}
		elseif self.SEAT_ENTITY_TYPE.PLAYER == seatState then
			seatSelList = {
				{
					name = pg.getGameString("VEHICLE_SEAT_EXIT"),
					seat = self.SEAT_ACT_TYPE.EXIT,
					seatId = seatId,
					steatIndex = steatIndex
				}
			}
		elseif self.SEAT_ENTITY_TYPE.PET == seatState then
			if seatType == self.SEAT_TYPE.PET then
				seatSelList = {
					{
						name = pg.getGameString("VEHICLE_SEAT_EXIT"),
						seat = self.SEAT_ACT_TYPE.TICK,
						seatId = seatId,
						steatIndex = steatIndex
					}
				}
			else
				seatSelList = {
					{
						name = pg.getGameString("VEHICLE_SEAT_EXCHANGE"),
						seat = self.SEAT_ACT_TYPE.EXCHANGE,
						seatId = seatId,
						steatIndex = steatIndex
					},
					{
						name = pg.getGameString("VEHICLE_SEAT_EXIT"),
						seat = self.SEAT_ACT_TYPE.TICK,
						seatId = seatId,
						steatIndex = steatIndex
					}
				}
			end
		end

		return seatSelList
	end
end

function VehicleInterationModel:getVehicleDurationTime(vehicleId)
	local curVehicle = pg.getEntity(vehicleId)

	if curVehicle then
		local vehicleListTbData = curVehicle:getVehicleConfig()

		return vehicleListTbData.duration or 0, vehicleListTbData.rideDuration or 0, vehicleListTbData.hideCountDown == 1 or false
	end

	return 0, 0, false
end

function VehicleInterationModel:getVehicleCanLeaveSeat(vehicleId)
	local curVehicle = pg.getEntity(vehicleId)

	if curVehicle then
		local vehicleListTbData = curVehicle:getVehicleConfig()

		return vehicleListTbData.canLeaveSeat == 1 and true or false
	end

	return true
end

function VehicleInterationModel:getVehicleSeatManage(vehicleId)
	local curVehicle = pg.getEntity(vehicleId)

	if curVehicle then
		local vehicleListTbData = curVehicle:getVehicleConfig()

		return vehicleListTbData.seatManage == 1 and true or false
	end

	return false
end

function VehicleInterationModel:getVehicleName(vehicleId)
	local curVehicle = pg.getEntity(vehicleId)

	if curVehicle then
		local vehicleListTbData = curVehicle:getVehicleConfig()

		return vehicleListTbData.name
	end
end

return VehicleInterationModel
