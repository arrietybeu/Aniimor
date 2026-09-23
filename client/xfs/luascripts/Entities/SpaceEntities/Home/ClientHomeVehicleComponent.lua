-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\Home\\ClientHomeVehicleComponent.lua

local Class = require("Core.Framework.Class")
local InteractionConst = require("Common.Const.InteractionConst")
local HomelandOperateData = require("Data.homeland_operate_data")
local VehicleInteractUtils = require("Entities.SpaceEntities.VehicleEntities.VehicleInteractUtils")
local ClientHomeVehicleComponent = Class.Component("ClientHomeVehicleComponent")

function ClientHomeVehicleComponent:EVENT_InitInteractionList()
	self.interactionListData = self.interactionListData or {}

	local vehicleConfig = self:getVehicleConfig()
	local playInteractIds = VehicleInteractUtils.toInteractIdList(vehicleConfig.playInteractId)
	local vehicleInteractId = playInteractIds[1]

	vehicleInteractId = vehicleInteractId or vehicleConfig.enterInteractId

	local homelandConfigData = self:getHomelandConfigData()

	if vehicleInteractId then
		self.homeVehicleInteractData = {
			checkEntity = true,
			skipHomelandCheck = true,
			actionPrototypeId = vehicleInteractId,
			overrideType = InteractionConst.INTERACTION_TYPE_SWITCH,
			globalId = self:getGlobalId(),
			overrideInteractDis = homelandConfigData.interactDistance,
			interactFunc = function()
				self:playerMountHomeVehicle()
			end,
			canInteractiveFunc = function()
				return self:checkCanEnterHomeVehicle()
			end
		}

		table.insert(self.interactionListData, self.homeVehicleInteractData)
	end
end

function ClientHomeVehicleComponent:EVENT_AnimancerAnimUpdate()
	if self.eModel and self.facilityWorkState then
		self:syncChildMountAnimState()
	end
end

function ClientHomeVehicleComponent:getMountAnimSyncState()
	return self:getCurNamedAnimancerState()
end

function ClientHomeVehicleComponent:checkCanEnterHomeVehicle()
	if not pg.me:checkEnterVehicle(true, self:getVehicleConfig().enterConflictType) then
		return false
	end

	local facilityInfo = self.facilityInfo

	if not facilityInfo then
		return false
	end

	local curOpId = facilityInfo.facilityState
	local operationData = HomelandOperateData[curOpId] or {}

	if operationData.playerCanDo then
		local requireOps = self:getRequireOperIds()

		if table.contains(requireOps, curOpId) then
			return true
		end
	end

	return false
end

function ClientHomeVehicleComponent:playerMountHomeVehicle()
	self:tryMount(pg.pawn)
end

return ClientHomeVehicleComponent
