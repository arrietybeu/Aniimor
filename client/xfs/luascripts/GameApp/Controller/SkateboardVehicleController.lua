-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Controller\\SkateboardVehicleController.lua

local Class = require("Core.Framework.Class")
local BenchController = require("GameApp.Controller.BenchController")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local Const = require("Common.Const.Const")
local TimerManager = require("Core.Timer.TimerManager")
local ClientConst = require("Const.ClientConst")
local pg = pg
local SkateboardVehicleController = Class.LightClass("SkateboardVehicleController", BenchController)

function SkateboardVehicleController:ctor(pawn, vehicle)
	self.controllerData = {}
	self.controllerData.mountDelay = 0.5
	self.controllerData.drivePower = 30
	self.controllerData.antiGravityPercent = 1
	self.controllerData.ridingAntiGravity = 1.35

	SkateboardVehicleController.super.ctor(self, pawn, vehicle)

	if pawn.eModel then
		pawn.eModel:OnHandleMove(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, 0, 0, 0)
	end

	self.moving = false
end

function SkateboardVehicleController:isVehicle()
	return true
end

function SkateboardVehicleController:enter()
	self.exited = false

	if pg.game and pg.game.camera and pg.game.camera.playerCameraMode and pg.game.camera.playerCameraMode.defaultCamera then
		pg.game.camera.playerCameraMode.defaultCamera:setDamperEnabled(false)
	end

	self.mountDelay = self.controllerData.mountDelay or 0

	if self.mountDelay > 0 then
		self.mountDelayTimer = TimerManager.addTimer(self.mountDelay, function()
			if self.exited then
				return
			end

			self.vehicle:setIsKinematic(false, ClientConst.IsKinematicKey.SkateboardVehicle)
		end)
	else
		self.vehicle:setIsKinematic(false, ClientConst.IsKinematicKey.SkateboardVehicle)
	end
end

function SkateboardVehicleController:exit()
	if self.mountDelayTimer then
		TimerManager.removeTimer(self.mountDelayTimer)

		self.mountDelayTimer = nil
	end

	self.exited = true

	if self.moving and self:checkPawn() then
		self.pawn:stopVehicleSpecial()

		self.moving = false
	end

	if self.vehicle then
		self.vehicle:onVehicleMoveStateChanged(false)

		if NotNil(self.vehicle.featureVehicle) then
			self.vehicle.featureVehicle:Drive(0, 0)
		end

		self.vehicle:setIsKinematic(true, ClientConst.IsKinematicKey.SkateboardVehicle)
	end

	if pg.game and pg.game.camera and pg.game.camera.playerCameraMode and pg.game.camera.playerCameraMode.defaultCamera then
		pg.game.camera.playerCameraMode.defaultCamera:setDamperEnabled(true)
	end
end

function SkateboardVehicleController:onHandleMove(x, y, z)
	self.vehicle:getVehicleConfig().moveLeave = false

	SkateboardVehicleController.super.onHandleMove(self, x, y, z)

	if self.exited then
		return
	end

	if not self:checkPawn() then
		return
	end

	local pawn = self.pawn

	if pawn.characterState == CharacterStateConst.MOUNTENTER then
		return
	end

	if IsNil(self.vehicle.featureVehicle) then
		return
	end

	self.vehicle.featureVehicle:Drive(x, y)

	local hasMoveInput = x ~= 0 or y ~= 0 or z ~= 0

	if not self.moving and hasMoveInput then
		pawn:playVehicleOverrideAnim({
			startAnim = self.controllerData.startAnim,
			loopAnim = self.controllerData.loopAnim or "Skill_Skate_Move",
			endAnim = self.controllerData.endAnim
		})

		self.moving = true

		self.vehicle:onVehicleMoveStateChanged(true)
	elseif self.moving and not hasMoveInput then
		pawn:stopVehicleSpecial()

		self.moving = false

		self.vehicle:onVehicleMoveStateChanged(false)
	end

	if pawn.eModel then
		pawn.eModel:OnHandleMove(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, x, y, z)
	end
end

return SkateboardVehicleController
