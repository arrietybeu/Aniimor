-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\HTN\\HomeLandHTNState.lua

local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local HomeObjectData = require("Data.home_object_data")
local HomeLandHTNState = {}

HomeLandHTNState.StateName = {
	TargetOrnamentId = 101,
	TargetOperId = 100,
	CloseToTransportTarget = 6,
	HasTransportTarget = 5,
	CloseToWorkPosition = 4,
	HasWorkTarget = 3,
	TargetStoreId = 102
}
HomeLandHTNState.StateFunction = {
	[HomeLandHTNState.StateName.HasWorkTarget] = function(entity, worldState)
		local operId = worldState[HomeLandHTNState.StateName.TargetOperId]

		return operId and operId >= Const.HOMELAND_FACILITY_OP_TYPE.MAX_OPER_STATE
	end,
	[HomeLandHTNState.StateName.CloseToWorkPosition] = function(entity, worldState)
		local ornamentId = worldState[HomeLandHTNState.StateName.TargetOrnamentId]

		if ornamentId and entity and entity.space then
			local ornament = entity.space.ornament[ornamentId]

			if ornament then
				local homeId = ornament.homeId
				local petWorkDistance = HomeObjectData[homeId].petWorkDistance
				local ornamentDist = HomeLandUtils.getSqrDistanceByOrnamentId(entity, ornamentId)
				local posCloseFlag = ornamentDist < petWorkDistance * petWorkDistance

				return posCloseFlag
			end
		end

		return false
	end,
	[HomeLandHTNState.StateName.HasTransportTarget] = function(entity, worldState)
		local operId = worldState[HomeLandHTNState.StateName.TargetOperId]

		return operId and operId == Const.HOMELAND_FACILITY_OP_TYPE.TRANSPORT
	end,
	[HomeLandHTNState.StateName.CloseToTransportTarget] = function(entity, worldState)
		local ornamentId = worldState[HomeLandHTNState.StateName.TargetOrnamentId]

		if ornamentId then
			local homeId = entity.space.ornament[ornamentId].homeId
			local petWorkDistance = HomeObjectData[homeId].petWorkDistance

			return HomeLandUtils.getSqrDistanceByOrnamentId(entity, ornamentId) < petWorkDistance * petWorkDistance
		end

		return false
	end
}

return HomeLandHTNState
