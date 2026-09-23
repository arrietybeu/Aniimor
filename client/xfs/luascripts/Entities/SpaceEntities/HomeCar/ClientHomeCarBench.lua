-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\HomeCar\\ClientHomeCarBench.lua

local Class = require("Core.Framework.Class")
local ClientHomeCarOrnamentComponent = require("Entities.SpaceEntities.HomeCar.ClientHomeCarOrnamentComponent")
local ClientBench = require("Entities.SpaceEntities.VehicleEntities.ClientBench")
local ClientHomeCarEditorComponent = require("Entities.SpaceEntities.HomeCar.ClientHomeCarEditorComponent")
local ClientEntityEditorComponent = require("Entities.SpaceEntities.Home.ClientEntityEditorComponent")
local ClientConst = require("Const.ClientConst")
local HomelandConfigData = require("Data.homeland_config_data")
local CustomTriggerData = require("Data.custom_trigger_data")
local HomeObjectData = require("Data.home_object_data")
local TimerManager = require("Core.Timer.TimerManager")
local UIConst = require("Const.UIConst")
local OpDef = require("Common.OpDef")
local NoticeDef = require("Common.NoticeDef")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local Time = require("Core.Common.Time")
local ClientHomeCarBench = Class.Class("ClientHomeCarBench", ClientBench)
local ClientHomeCarComponents = {
	ClientHomeCarOrnamentComponent,
	ClientEntityEditorComponent,
	ClientHomeCarEditorComponent
}

Class.AddComponents(ClientHomeCarBench, ClientHomeCarComponents)

function ClientHomeCarBench:postInit(bdict)
	local ret = ClientHomeCarBench.super.postInit(self, bdict)
	local homeObjectConfig = self.homeTemplateId and HomeObjectData[self.homeTemplateId]

	if homeObjectConfig and homeObjectConfig.needIndicatorIcon == 1 then
		self.forbiddenTopLogo = false
		self.topLogoType = ClientConst.TopLogoType.InteractableObject
		self.overrideTopLogoEnterDistance = HomelandConfigData.IndicatorIconDisplayArea or 10
		self.indicatorIconHeight = homeObjectConfig and homeObjectConfig.IndicatorIconHeight
	else
		self.forbiddenTopLogo = true
	end

	return ret
end

function ClientHomeCarBench:onEntityPositionChanged()
	self:postComponentMethod("EVENT_onEntityPositionChanged")
end

function ClientHomeCarBench:onEnterControl()
	ClientHomeCarBench.super.onEnterControl(self)
	self:tryStartCampAddOnTimer()
end

function ClientHomeCarBench:onExitControl()
	self:stopCampAddOnTimer()
	ClientHomeCarBench.super.onExitControl(self)
end

function ClientHomeCarBench:tryStartCampAddOnTimer()
	if not self.space or not self.space.isHomeCamp or not self.space:isHomeCamp() then
		return
	end

	local ownerUid = self:getCampAddOnOwnerUid()

	if not ownerUid then
		return
	end

	local addOnIds = HomeLandUtils.getCampAddOnIdsByOwnerFromCreatedMap(self.space, ownerUid) or {}

	if #addOnIds <= 0 then
		return
	end

	self:startCampAddOnTimer(ownerUid)
end

function ClientHomeCarBench:getCampAddOnOwnerUid()
	local ownerUid = self.playerUID

	if not ownerUid or ownerUid == "" then
		ownerUid = self.carGroup and self.carGroup.playerUID
	end

	return ownerUid
end

function ClientHomeCarBench:getCampAddOnGainSeconds()
	local triggerId = HomelandConfigData.campAddOnGainTriggerId
	local triggerConfig = triggerId and CustomTriggerData[triggerId]
	local conditionList = triggerConfig and triggerConfig.condition

	if not conditionList then
		return
	end

	for _, conditionInfo in ipairs(conditionList) do
		if conditionInfo and conditionInfo[1] == "homeCampAddOnGainSeconds" then
			local totalSec = conditionInfo[2]

			if type(totalSec) == "number" and totalSec > 0 then
				return totalSec
			end
		end
	end
end

function ClientHomeCarBench:startCampAddOnTimer(ownerUid)
	self:stopCampAddOnTimer()

	local totalSec = self:getCampAddOnGainSeconds()

	if not totalSec or totalSec <= 0 then
		return
	end

	self.campAddOnPassedSec = 0
	self.campAddOnClaimed = false
	self.campAddOnEndTime = Time.getSecond() + totalSec

	pg.global.ui.stationBuffCountDown:initProgress(0, totalSec, function()
		self:onCampAddOnTimerFinished(ownerUid)
	end)
	pg.global.ui:open(UIConst.UI_ID_STATION_BUFF_COUNTDOWN)

	if pg.global.ui.VehicleInteration and pg.global.ui.VehicleInteration.setCampAddOnCountTimeInfo then
		pg.global.ui.VehicleInteration:setCampAddOnCountTimeInfo(0, totalSec)
	end

	self.campAddOnTimerId = TimerManager.addRepeatTimer(1, function()
		self.campAddOnPassedSec = (self.campAddOnPassedSec or 0) + 1

		if pg.global.ui.VehicleInteration and pg.global.ui.VehicleInteration.setCampAddOnCountTimeInfo then
			pg.global.ui.VehicleInteration:setCampAddOnCountTimeInfo(self.campAddOnPassedSec, totalSec)
		end
	end)
end

function ClientHomeCarBench:stopCampAddOnTimer()
	if self.campAddOnTimerId then
		TimerManager.removeTimer(self.campAddOnTimerId)

		self.campAddOnTimerId = nil
	end

	self.campAddOnPassedSec = 0
	self.campAddOnEndTime = nil

	pg.global.ui:close(UIConst.UI_ID_STATION_BUFF_COUNTDOWN)

	if pg.global.ui.VehicleInteration and pg.global.ui.VehicleInteration.clearCampAddOnCountTimeInfo then
		pg.global.ui.VehicleInteration:clearCampAddOnCountTimeInfo()
	end

	self.campAddOnClaimed = false
end

function ClientHomeCarBench:onCampAddOnTimerFinished(ownerUid)
	if not self.campAddOnTimerId or not self.campAddOnEndTime or Time.getSecond() < self.campAddOnEndTime then
		return
	end

	if self.campAddOnClaimed then
		return
	end

	self.campAddOnClaimed = true

	if self.campAddOnTimerId then
		TimerManager.removeTimer(self.campAddOnTimerId)

		self.campAddOnTimerId = nil
	end

	self.campAddOnEndTime = nil

	if pg.global.ui.VehicleInteration and pg.global.ui.VehicleInteration.clearCampAddOnCountTimeInfo then
		pg.global.ui.VehicleInteration:clearCampAddOnCountTimeInfo()
	end

	if not ownerUid or ownerUid == "" then
		ownerUid = self:getCampAddOnOwnerUid()
	end

	if not ownerUid then
		return
	end

	local addOnIds = HomeLandUtils.getCampAddOnIdsByOwnerFromCreatedMap(self.space, ownerUid) or {}

	if #addOnIds <= 0 then
		return
	end

	pg.me:requestHomeCampOp(OpDef.OP.CS_HC_RefreshAddOns, {
		ownerUid = ownerUid
	}, function(noticeId, noticeArgs)
		if noticeId == NoticeDef.SUCCESS then
			local gainedOwnerUid = noticeArgs and noticeArgs.ownerUid or ownerUid
			local gainedOwnerName = noticeArgs and noticeArgs.ownerName

			if string.isNilOrEmpty(gainedOwnerName) then
				gainedOwnerName = HomeLandUtils.getCampAddOnOwnerNameFromCreatedMap(self.space, gainedOwnerUid)
			end

			self:onCampAddOnGained(gainedOwnerUid, gainedOwnerName)
		end
	end)
end

function ClientHomeCarBench:onCampAddOnGained(ownerUid, ownerName)
	if pg.me and pg.me.onCampBuffGained then
		pg.me:onCampBuffGained({
			ownerUid = ownerUid,
			ownerName = ownerName
		})
	end
end

function ClientHomeCarBench:destroy()
	self:stopCampAddOnTimer()
	ClientHomeCarBench.super.destroy(self)
end

return ClientHomeCarBench
