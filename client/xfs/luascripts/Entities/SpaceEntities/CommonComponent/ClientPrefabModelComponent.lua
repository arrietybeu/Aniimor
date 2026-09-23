-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientPrefabModelComponent.lua

local CommonConst = require("Common.Const.Const")
local Class = require("Core.Framework.Class")
local vehicle_seat_data = require("Data.vehicle_seat_data")
local ClientPrefabModelComponent = Class.Component("ClientPrefabModelComponent")

function ClientPrefabModelComponent:start()
	return
end

function ClientPrefabModelComponent:EVENT_AddEComponent()
	self:addEModelComponent(CommonConst.COMPONENT_IDX_ITEM)
end

function ClientPrefabModelComponent:loadPrefabModel(resId)
	self.eModel:SetModelResId(CommonConst.COMPONENT_IDX_ITEM, resId)
end

function ClientPrefabModelComponent:onItemModelLoaded()
	self.isModelLoaded = true

	if self.onPrefabModelLoaded then
		self:onPrefabModelLoaded()
	end

	self:postComponentMethod("EVENT_onModelLoaded")
	self:setModelLoaded(true)
end

function ClientPrefabModelComponent:EVENT_OnEnterVehicle(vehicle, seatId)
	local seatData = vehicle_seat_data[seatId]

	if not seatData then
		return
	end

	self:attach(vehicle.id, seatData.itemAttachId)
end

function ClientPrefabModelComponent:EVENT_OnExitVehicle(vehicle, seatId)
	self:detach()
end

return ClientPrefabModelComponent
