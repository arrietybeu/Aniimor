-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\VehicleEntities\\ClientBench.lua

local class = require("Core.Framework.Class")
local ClientVehicle = require("Entities.SpaceEntities.VehicleEntities.ClientVehicle")
local InteractionConst = require("Common.Const.InteractionConst")
local interactData = require("Data.interact_data")
local SysEventData = require("Data.sys_event_data")
local GameStringConfigData = require("Data.gamestring_config_data")
local MessageName = require("Const.MessageName")
local AddressDataConst = require("Const.AddressDataConst")
local VehicleInteractUtils = require("Entities.SpaceEntities.VehicleEntities.VehicleInteractUtils")
local lume = require("Core.Common.lume")
local ClientBench = class.Class("ClientBench", ClientVehicle)
local VEHICLE_PLAY_STATE_NONE = 0
local VEHICLE_PLAY_STATE_CHOICE = 1
local VEHICLE_PLAY_STATE_PLAYING = 2
local VEHICLE_PLAY_RETURN_STYLE_ID = 52

function ClientBench:isValidShowReturnValue(value)
	return type(value) == "boolean" or value == 0 or value == 1
end

function ClientBench:toShowReturn(value)
	return value == true or value == 1
end

local Components = {}

class.AddComponents(ClientBench, Components)

function ClientBench:ctor(entityId)
	ClientBench.super.ctor(self, entityId)
end

function ClientBench:init(bdict)
	ClientBench.super.init(self, bdict)

	self.seatSkillEventId = nil
	self.entityCanMove = false
	self.playInteractDataList = {}
	self.vehiclePlayState = VEHICLE_PLAY_STATE_NONE
	self.activePlayInteractData = nil
	self.pendingRestorePlayInteraction = false
	self.returnInteractData = {
		actionPrototypeId = VEHICLE_PLAY_RETURN_STYLE_ID,
		overrideType = InteractionConst.INTERACTION_TYPE_QUICK_PHOTO,
		globalId = string.format("%s_vehicle_play_return", tostring(self:getGlobalId())),
		actionName = GameStringConfigData.BACK_TO_PRE.desc,
		iconId = AddressDataConst.UI_EXIT_INTERACT_ICON,
		interactFunc = function()
			self:returnFromPlayInteraction()
		end,
		canInteractiveFunc = function()
			return pg.pawn and pg.pawn:RIDING_ST()
		end
	}

	return true
end

function ClientBench:onDoSkill1()
	local eventId = self.seatSkillEventId

	if eventId and eventId > 0 then
		pg.me:doEvent(eventId)
	end
end

function ClientBench:logVehiclePlayConfigError(message)
	if self.logger then
		self.logger:error("vehicle play interact config error, vehicleId=%s, %s", tostring(self.vehicleId), message)
	end
end

function ClientBench:createPlayInteractData(interactId, eventId, displayOrder, separateRoot, showReturn)
	local globalId = self:getGlobalId()

	if separateRoot then
		globalId = string.format("%s_vehicle_play_choice_%s", tostring(globalId), tostring(displayOrder))
	end

	local data = {
		actionPrototypeId = interactId,
		overrideType = InteractionConst.INTERACTION_TYPE_QUICK_PHOTO,
		globalId = globalId,
		eventId = eventId,
		displayOrder = displayOrder,
		showReturn = showReturn,
		canInteractiveFunc = function()
			return pg.pawn and pg.pawn:RIDING_ST()
		end
	}

	function data.interactFunc()
		self:selectPlayInteraction(data)
	end

	return data
end

function ClientBench:buildLegacyPlayInteraction(vehicleData, interactId)
	local events = VehicleInteractUtils.toConfigList(vehicleData.events)
	local eventWeights = VehicleInteractUtils.toConfigList(vehicleData.eventWeights)

	if events == nil or #events == 0 then
		return
	end

	if eventWeights == nil or #events ~= #eventWeights then
		self:logVehiclePlayConfigError("events and eventWeights count must match in single interact mode")

		return
	end

	local totalWeight = 0

	for _, weight in ipairs(eventWeights) do
		if type(weight) ~= "number" or weight < 0 then
			self:logVehiclePlayConfigError("eventWeights must contain non-negative numbers")

			return
		end

		totalWeight = totalWeight + weight
	end

	if totalWeight <= 0 then
		self:logVehiclePlayConfigError("eventWeights total must be greater than zero")

		return
	end

	local eventId = lume.weightRandomChoiceOne(events, eventWeights)

	if not eventId or eventId <= 0 then
		return
	end

	if not SysEventData[eventId] then
		self:logVehiclePlayConfigError(string.format("eventId=%s does not exist", tostring(eventId)))

		return
	end

	local showReturnList = VehicleInteractUtils.toConfigList(vehicleData.playInteractShowReturn)
	local showReturnValue

	if showReturnList ~= nil then
		if #showReturnList ~= 1 then
			self:logVehiclePlayConfigError("playInteractShowReturn count must be one in single interact mode")

			return
		end

		showReturnValue = showReturnList[1]
	end

	if showReturnValue ~= nil and not self:isValidShowReturnValue(showReturnValue) then
		self:logVehiclePlayConfigError("playInteractShowReturn must be 0, 1 or boolean")

		return
	end

	local showReturn = showReturnValue ~= nil and self:toShowReturn(showReturnValue)

	self.playInteractDataList[1] = self:createPlayInteractData(interactId, eventId, 1, false, showReturn)
end

function ClientBench:buildMultiplePlayInteractions(interactIds, events, showReturnList)
	events = VehicleInteractUtils.toConfigList(events)
	showReturnList = VehicleInteractUtils.toConfigList(showReturnList)

	if events == nil then
		self:logVehiclePlayConfigError("events must be an array in multiple interact mode")

		return
	end

	if #interactIds ~= #events then
		self:logVehiclePlayConfigError(string.format("interact count=%s does not match event count=%s", tostring(#interactIds), tostring(#events)))

		return
	end

	if showReturnList ~= nil then
		if #showReturnList ~= #interactIds then
			self:logVehiclePlayConfigError(string.format("playInteractShowReturn count must match interact count=%s", tostring(#interactIds)))

			return
		end

		for _, showReturnValue in ipairs(showReturnList) do
			if not self:isValidShowReturnValue(showReturnValue) then
				self:logVehiclePlayConfigError("playInteractShowReturn must contain only 0, 1 or boolean")

				return
			end
		end
	end

	local usedInteractIds = {}

	for index, interactId in ipairs(interactIds) do
		local eventId = events[index]

		if type(eventId) ~= "number" or eventId < 0 then
			self:logVehiclePlayConfigError(string.format("invalid eventId=%s", tostring(eventId)))

			self.playInteractDataList = {}

			return
		end

		if usedInteractIds[interactId] then
			self:logVehiclePlayConfigError(string.format("duplicate interactId=%s", tostring(interactId)))

			self.playInteractDataList = {}

			return
		end

		if not interactData[interactId] then
			self:logVehiclePlayConfigError(string.format("interactId=%s does not exist", tostring(interactId)))

			self.playInteractDataList = {}

			return
		end

		if eventId ~= 0 and not SysEventData[eventId] then
			self:logVehiclePlayConfigError(string.format("eventId=%s does not exist", tostring(eventId)))

			self.playInteractDataList = {}

			return
		end

		usedInteractIds[interactId] = true

		local showReturn = showReturnList ~= nil and self:toShowReturn(showReturnList[index])

		self.playInteractDataList[index] = self:createPlayInteractData(interactId, eventId, index, true, showReturn)
	end
end

function ClientBench:rebuildPlayInteractDataList()
	self.playInteractDataList = {}

	local vehicleData = self:getVehicleConfig()
	local interactIds = VehicleInteractUtils.toInteractIdList(vehicleData.playInteractId)

	if #interactIds == 0 then
		local events = VehicleInteractUtils.toConfigList(vehicleData.events)
		local eventWeights = VehicleInteractUtils.toConfigList(vehicleData.eventWeights)

		if events and eventWeights and #events == #eventWeights and #events > 0 then
			self.seatSkillEventId = lume.weightRandomChoiceOne(events, eventWeights)
		end

		return
	end

	if #interactIds == 1 then
		if not interactData[interactIds[1]] then
			self:logVehiclePlayConfigError(string.format("interactId=%s does not exist", tostring(interactIds[1])))

			return
		end

		self:buildLegacyPlayInteraction(vehicleData, interactIds[1])

		return
	end

	self:buildMultiplePlayInteractions(interactIds, vehicleData.events or {}, vehicleData.playInteractShowReturn)
end

function ClientBench:enterPlayInteractionChoice()
	if #self.playInteractDataList == 0 then
		self.vehiclePlayState = VEHICLE_PLAY_STATE_NONE

		return
	end

	self.vehiclePlayState = VEHICLE_PLAY_STATE_CHOICE

	if #self.playInteractDataList == 1 then
		facade:SendMessageCommand(MessageName.ENTER_TRIGGER, self.playInteractDataList[1])
	else
		facade:SendMessageCommand(MessageName.ENTER_TRIGGER_MULTI_INTERACT, self.playInteractDataList)
	end
end

function ClientBench:leavePlayInteractionChoice()
	if #self.playInteractDataList == 0 then
		return
	end

	if #self.playInteractDataList == 1 then
		facade:SendMessageCommand(MessageName.LEAVE_TRIGGER, self.playInteractDataList[1])
	else
		facade:SendMessageCommand(MessageName.LEAVE_TRIGGER_MULTI_INTERACT, self.playInteractDataList)
	end
end

function ClientBench:selectPlayInteraction(playData)
	if self.vehiclePlayState ~= VEHICLE_PLAY_STATE_CHOICE then
		return
	end

	local showReturn = playData.showReturn == true

	if showReturn then
		self:leavePlayInteractionChoice()

		self.vehiclePlayState = VEHICLE_PLAY_STATE_PLAYING
		self.activePlayInteractData = playData
	end

	local config = interactData[playData.actionPrototypeId]

	if config and pg.me then
		pg.me:playVehicleOverrideAnim(config)
	end

	if playData.eventId and playData.eventId > 0 and pg.me then
		pg.me:doEvent(playData.eventId)
	end

	if showReturn and self.vehiclePlayState == VEHICLE_PLAY_STATE_PLAYING then
		facade:SendMessageCommand(MessageName.ENTER_TRIGGER, self.returnInteractData)
	end
end

function ClientBench:returnFromPlayInteraction()
	if self.vehiclePlayState ~= VEHICLE_PLAY_STATE_PLAYING then
		return
	end

	facade:SendMessageCommand(MessageName.LEAVE_TRIGGER, self.returnInteractData)

	self.pendingRestorePlayInteraction = true

	if pg.me then
		pg.me:stopVehicleSpecial()
	end
end

function ClientBench:onVehicleMountLoopEntered(passenger, sessionId)
	ClientBench.super.onVehicleMountLoopEntered(self, passenger, sessionId)

	if not self.pendingRestorePlayInteraction then
		return
	end

	self.pendingRestorePlayInteraction = false

	if self.vehiclePlayState ~= VEHICLE_PLAY_STATE_PLAYING then
		return
	end

	self.activePlayInteractData = nil

	self:enterPlayInteractionChoice()
end

function ClientBench:clearVehiclePlayInteraction()
	self.seatSkillEventId = nil

	if self.vehiclePlayState == VEHICLE_PLAY_STATE_CHOICE then
		self:leavePlayInteractionChoice()
	elseif self.vehiclePlayState == VEHICLE_PLAY_STATE_PLAYING and not self.pendingRestorePlayInteraction then
		facade:SendMessageCommand(MessageName.LEAVE_TRIGGER, self.returnInteractData)
	end

	self.pendingRestorePlayInteraction = false

	if pg.me then
		pg.me:stopVehicleSpecial()
	end

	self.vehiclePlayState = VEHICLE_PLAY_STATE_NONE
	self.activePlayInteractData = nil
end

function ClientBench:onEnterControl()
	ClientBench.super.onEnterControl(self)
	self:rebuildPlayInteractDataList()
	self:enterPlayInteractionChoice()
end

function ClientBench:onExitControl()
	self:clearVehiclePlayInteraction()
	ClientBench.super.onExitControl(self)
end

function ClientBench:destroy()
	self:clearVehiclePlayInteraction()
	ClientBench.super.destroy(self)
end

return ClientBench
