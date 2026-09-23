-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\Home\\ClientHomelandWorkComponent.lua

local Class = require("Core.Framework.Class")
local HomeObjectData = require("Data.home_object_data")
local HomelandFacilityData = require("Data.homeland_facility_data")
local HomelandFormulaData = require("Data.homeland_formula_data")
local InteractionConst = require("Common.Const.InteractionConst")
local HomelandOperateData = require("Data.homeland_operate_data")
local ClientConst = require("Const.ClientConst")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local GlobalData = require("Core.Client.GlobalData")
local EventConst = require("Const.EventConst")
local AIUtils = require("Common.Utils.AIUtils")
local AiConst = require("Common.Const.AiConst")
local ClientHomelandWorkComponent = Class.Component("ClientHomelandWorkComponent")

function ClientHomelandWorkComponent:init(dict)
	if Utils.isHomePet(self) then
		AIUtils.pauseBt(self, AiConst.PauseBtReason.HomeInitPetData)
	end

	return true
end

function ClientHomelandWorkComponent:onEnterSpace()
	self:initAllocationData()
end

function ClientHomelandWorkComponent:initAllocationData()
	if self.space:isHomeland() then
		if Utils.isHomePet(self) then
			self.allocationInfo = GlobalData.Space.allocation[self.id]

			AIUtils.resumeBt(self, AiConst.PauseBtReason.HomeInitPetData)
		elseif Utils.isPlayer(self) then
			self.allocationInfo = GlobalData.Space.playerAllocation[self.id]
		end

		if self.allocationInfo then
			self.eventEmitter:emit(EventConst.HOMELAND_WORK_STATE_CHANGED)
		end
	else
		AIUtils.resumeBt(self, AiConst.PauseBtReason.HomeInitPetData)
	end
end

function ClientHomelandWorkComponent:setAllocationInfo(allocationInfo)
	self.allocationInfo = allocationInfo

	self.eventEmitter:emit(EventConst.HOMELAND_WORK_STATE_CHANGED)
	self:postComponentMethod("onHomelandAIPlanChanged")
end

function ClientHomelandWorkComponent:onTransportStart()
	self.eventEmitter:emit(EventConst.HOMELAND_TRANSPORT_STATE_CHANGED)
end

function ClientHomelandWorkComponent:onTransportEnd()
	self.eventEmitter:emit(EventConst.HOMELAND_TRANSPORT_STATE_CHANGED)
end

function ClientHomelandWorkComponent:onTransportChanged()
	self.eventEmitter:emit(EventConst.HOMELAND_TRANSPORT_STATE_CHANGED)
end

function ClientHomelandWorkComponent:RPC_SC_PetStartRestTeleportEffect()
	self.suppressNextHomeRestVehicleDropPosition = true

	if self.onVehicleActorId ~= 0 then
		return
	end

	self:playEffect("Eff_Switch_Hit")
end

function ClientHomelandWorkComponent:RPC_SC_PetEndRestTeleportEffect()
	self.suppressNextHomeRestVehicleDropPosition = nil
end

return ClientHomelandWorkComponent
