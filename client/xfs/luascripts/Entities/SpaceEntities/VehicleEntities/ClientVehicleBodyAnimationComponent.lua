-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\VehicleEntities\\ClientVehicleBodyAnimationComponent.lua

local Class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local ClientVehicleBodyAnimationComponent = Class.Component("ClientVehicleBodyAnimationComponent")
local VehicleNodeAnimationHelper = CS.FunPlus.WorldX.Utils.VehicleNodeAnimationHelper
local GROUP_RIDE = "ride"
local GROUP_MOVE = "move"

local function isVehicleBodyAnimationPassenger(passenger)
	return Utils.isPlayer(passenger) or Utils.isPet(passenger) or Utils.isHomePet(passenger)
end

local VehicleBodyAnimationState = {
	Ride = 1,
	Idle = 0,
	StoppingAtEnd = 3,
	Move = 2
}

function ClientVehicleBodyAnimationComponent:ctor()
	self.vehicleBodyAnimationState = VehicleBodyAnimationState.Idle
	self.vehicleBodyRideGroupConfigured = false
	self.vehicleBodyMoveGroupConfigured = false
	self.vehicleBodyEffectGroups = {}
	self.vehicleBodyEffectIds = {}
	self.vehicleBodyRideEffectsConfigured = false
	self.vehicleBodyMoveEffectsConfigured = false
	self.vehicleBodyMoving = false
	self.vehicleBodyAnimationStopTimer = nil
end

function ClientVehicleBodyAnimationComponent:init()
	return true
end

function ClientVehicleBodyAnimationComponent:on_vehicleBodyAnimationPassengerCount_changed(oldValue, newValue)
	if oldValue == 0 or newValue == 0 then
		self:refreshVehicleBodyPresentation()
	end
end

function ClientVehicleBodyAnimationComponent:refreshVehicleBodyPresentation()
	if not self.vehicleBodyModelReady or not self.eModel or IsNil(self.eModel.transform) then
		return
	end

	if self.vehicleBodyAnimationPassengerCount == 0 then
		self:requestVehicleBodyAnimationStop()

		return
	end

	local moving = self.vehicleBodyMoving and self:hasVehicleBodyGroup(GROUP_MOVE)
	local nextState = moving and VehicleBodyAnimationState.Move or VehicleBodyAnimationState.Ride

	if self.vehicleBodyAnimationState ~= nextState then
		self:playVehicleBodyGroup(moving and GROUP_MOVE or GROUP_RIDE)
	end
end

function ClientVehicleBodyAnimationComponent:configureVehicleBodyAnimationGroup(nodes, animations, groupName)
	if nodes == nil or animations == nil then
		return false
	end

	if #nodes == 0 or #nodes ~= #animations then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("vehicle body animation config pair invalid, vehicleId=%s, group=%s, nodeCount=%s, animationCount=%s", tostring(self.vehicleId), tostring(groupName), tostring(#nodes or nil), tostring(#animations or nil))
		end

		return false
	end

	for index, nodeName in ipairs(nodes) do
		local animationName = animations[index]

		if string.isNilOrEmpty(nodeName) or string.isNilOrEmpty(animationName) then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				self.logger:error("vehicle body animation config entry invalid, vehicleId=%s, group=%s, index=%s", tostring(self.vehicleId), tostring(groupName), tostring(index))
			end

			return false
		end
	end

	return VehicleNodeAnimationHelper.ConfigureGroup(self.eModel.transform, groupName, nodes, animations)
end

function ClientVehicleBodyAnimationComponent:configureVehicleBodyEffectGroup(effects, groupName)
	if effects == nil then
		self.vehicleBodyEffectGroups[groupName] = nil

		return false
	end

	if #effects == 0 then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("vehicle body effect config invalid, vehicleId=%s, group=%s", tostring(self.vehicleId), tostring(groupName))
		end

		self.vehicleBodyEffectGroups[groupName] = nil

		return false
	end

	local root = self.eModel.transform
	local bindings = {}

	for index, effectConfig in ipairs(effects) do
		local nodeName = effectConfig.nodeName or nil
		local effectKey = effectConfig.effectKey or nil
		local useRoot = nodeName == nil or type(nodeName) == "string" and string.isNilOrEmpty(nodeName)

		if not useRoot and type(nodeName) ~= "string" or type(effectKey) ~= "string" or string.isNilOrEmpty(effectKey) then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				self.logger:error("vehicle body effect config entry invalid, vehicleId=%s, group=%s, index=%s", tostring(self.vehicleId), tostring(groupName), tostring(index))
			end

			self.vehicleBodyEffectGroups[groupName] = nil

			return false
		end

		local target = useRoot and root or root:Find(nodeName)

		if IsNil(target) and not useRoot then
			target = root:FindRecursive(nodeName)
		end

		if IsNil(target) then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				self.logger:error("vehicle body effect node not found, vehicleId=%s, group=%s, index=%s, node=%s", tostring(self.vehicleId), tostring(groupName), tostring(index), tostring(nodeName))
			end

			self.vehicleBodyEffectGroups[groupName] = nil

			return false
		end

		bindings[#bindings + 1] = {
			effectKey = effectKey,
			target = target
		}
	end

	self.vehicleBodyEffectGroups[groupName] = bindings

	return true
end

local function collectVehicleBodyPreloadEffects(effects, effectKeys, usedEffectKeys)
	if not effects then
		return
	end

	for _, effectConfig in ipairs(effects) do
		local effectKey = effectConfig.effectKey

		if type(effectKey) == "string" and not string.isNilOrEmpty(effectKey) and not usedEffectKeys[effectKey] then
			usedEffectKeys[effectKey] = true
			effectKeys[#effectKeys + 1] = effectKey
		end
	end
end

function ClientVehicleBodyAnimationComponent:getPreloadEffects()
	local config = self:getVehicleConfig()
	local effectKeys = {}
	local usedEffectKeys = {}

	collectVehicleBodyPreloadEffects(config.rideBodyEffects, effectKeys, usedEffectKeys)
	collectVehicleBodyPreloadEffects(config.moveBodyEffects, effectKeys, usedEffectKeys)

	return #effectKeys > 0 and effectKeys or nil
end

function ClientVehicleBodyAnimationComponent:stopVehicleBodyEffects()
	for _, effectId in ipairs(self.vehicleBodyEffectIds) do
		self:stopEffectById(effectId)
	end

	self.vehicleBodyEffectIds = {}
end

function ClientVehicleBodyAnimationComponent:playVehicleBodyEffectGroup(groupName)
	self:stopVehicleBodyEffects()

	local bindings = self.vehicleBodyEffectGroups[groupName]

	if not bindings then
		return false
	end

	local effectIds = self.vehicleBodyEffectIds
	local eModel = self.eModel
	local visible = self.visible ~= false

	for _, binding in ipairs(bindings) do
		if NotNil(binding.target) then
			local effectId = self:playEffectOn(binding.effectKey, nil, binding.target)

			if effectId and effectId ~= 0 then
				effectIds[#effectIds + 1] = effectId

				eModel:SetEffectVisibleById(Const.COMPONENT_INDEX_EFFECT, effectId, visible)
			end
		end
	end

	return #effectIds > 0
end

function ClientVehicleBodyAnimationComponent:hasVehicleBodyGroup(groupName)
	if groupName == GROUP_MOVE then
		return self.vehicleBodyMoveGroupConfigured or self.vehicleBodyMoveEffectsConfigured
	end

	return self.vehicleBodyRideGroupConfigured or self.vehicleBodyRideEffectsConfigured
end

function ClientVehicleBodyAnimationComponent:playVehicleBodyGroup(groupName)
	if not self.eModel or IsNil(self.eModel.transform) then
		return false
	end

	if self.vehicleBodyAnimationStopTimer then
		self:removeTimer(self.vehicleBodyAnimationStopTimer)

		self.vehicleBodyAnimationStopTimer = nil
	end

	local animationConfigured = self.vehicleBodyRideGroupConfigured

	if groupName == GROUP_MOVE then
		animationConfigured = self.vehicleBodyMoveGroupConfigured
	end

	local animationPlayed = animationConfigured and VehicleNodeAnimationHelper.PlayGroup(self.eModel.transform, groupName, true) or false
	local effectPlayed = self:playVehicleBodyEffectGroup(groupName)

	if not animationPlayed and not effectPlayed then
		return false
	end

	self.vehicleBodyAnimationState = groupName == GROUP_MOVE and VehicleBodyAnimationState.Move or VehicleBodyAnimationState.Ride

	return true
end

function ClientVehicleBodyAnimationComponent:EVENT_onModelLoaded()
	if not self.eModel or IsNil(self.eModel.transform) then
		return
	end

	self:finishVehicleBodyAnimationStop()
	VehicleNodeAnimationHelper.Clear(self.eModel.transform)

	self.vehicleBodyEffectGroups = {}
	self.vehicleBodyEffectIds = {}
	self.vehicleBodyAnimationState = VehicleBodyAnimationState.Idle

	local config = self:getVehicleConfig()

	self.vehicleBodyRideGroupConfigured = self:configureVehicleBodyAnimationGroup(config.rideBodyAnimNodeNames, config.rideBodyAnimNames, GROUP_RIDE)
	self.vehicleBodyMoveGroupConfigured = self:configureVehicleBodyAnimationGroup(config.moveBodyAnimNodeNames, config.moveBodyAnimNames, GROUP_MOVE)
	self.vehicleBodyRideEffectsConfigured = self:configureVehicleBodyEffectGroup(config.rideBodyEffects, GROUP_RIDE)
	self.vehicleBodyMoveEffectsConfigured = self:configureVehicleBodyEffectGroup(config.moveBodyEffects, GROUP_MOVE)
	self.vehicleBodyModelReady = true

	self:refreshVehicleBodyPresentation()
end

function ClientVehicleBodyAnimationComponent:EVENT_OnVehiclePassengerEnterFinished(passenger, sessionId)
	if isVehicleBodyAnimationPassenger(passenger) then
		passenger:reportVehicleBodyAnimationPhase(self.actorId, sessionId, true)
	end
end

function ClientVehicleBodyAnimationComponent:EVENT_OnVehiclePassengerExitFinished(passenger, sessionId)
	if isVehicleBodyAnimationPassenger(passenger) then
		passenger:reportVehicleBodyAnimationPhase(self.actorId, sessionId, false)
	end
end

function ClientVehicleBodyAnimationComponent:setVehicleBodyMoving(isMoving)
	local nextMoving = isMoving == true

	if self.vehicleBodyMoving == nextMoving then
		return
	end

	self.vehicleBodyMoving = nextMoving

	if self.vehicleBodyAnimationPassengerCount <= 0 or not self.eModel then
		return
	end

	if self.vehicleBodyMoving and self:hasVehicleBodyGroup(GROUP_MOVE) then
		self:playVehicleBodyGroup(GROUP_MOVE)

		return
	end

	if not self.vehicleBodyMoving and self:hasVehicleBodyGroup(GROUP_RIDE) and self.vehicleBodyAnimationState == VehicleBodyAnimationState.Move then
		self:playVehicleBodyGroup(GROUP_RIDE)
	end
end

function ClientVehicleBodyAnimationComponent:requestVehicleBodyAnimationStop()
	if self.vehicleBodyAnimationState == VehicleBodyAnimationState.Idle or not self.eModel then
		return
	end

	if not VehicleNodeAnimationHelper.RequestStopAtEnd(self.eModel.transform) then
		self:finishVehicleBodyAnimationStop()

		return
	end

	self.vehicleBodyAnimationState = VehicleBodyAnimationState.StoppingAtEnd

	if self.vehicleBodyAnimationStopTimer then
		self:removeTimer(self.vehicleBodyAnimationStopTimer)
	end

	self.vehicleBodyAnimationStopTimer = self:addRepeatTimer(0.05, function()
		if not self.eModel or not VehicleNodeAnimationHelper.IsStopping(self.eModel.transform) then
			self:finishVehicleBodyAnimationStop()
		end
	end)
end

function ClientVehicleBodyAnimationComponent:finishVehicleBodyAnimationStop()
	if self.vehicleBodyAnimationStopTimer then
		self:removeTimer(self.vehicleBodyAnimationStopTimer)

		self.vehicleBodyAnimationStopTimer = nil
	end

	self:stopVehicleBodyEffects()

	self.vehicleBodyAnimationState = VehicleBodyAnimationState.Idle
end

function ClientVehicleBodyAnimationComponent:canMountByBodyAnimation()
	if self.vehicleBodyAnimationState ~= VehicleBodyAnimationState.StoppingAtEnd then
		return true
	end

	if not self.eModel or not VehicleNodeAnimationHelper.IsStopping(self.eModel.transform) then
		self:finishVehicleBodyAnimationStop()

		return true
	end

	return false
end

function ClientVehicleBodyAnimationComponent:preDestroy()
	self.vehicleBodyModelReady = false

	self:finishVehicleBodyAnimationStop()

	if self.eModel and NotNil(self.eModel.transform) then
		VehicleNodeAnimationHelper.Clear(self.eModel.transform)
	end
end

function ClientVehicleBodyAnimationComponent:destroy()
	self.vehicleBodyEffectGroups = {}
end

return ClientVehicleBodyAnimationComponent
