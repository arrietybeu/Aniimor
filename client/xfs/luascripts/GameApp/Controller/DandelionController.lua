-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Controller\\DandelionController.lua

local Class = require("Core.Framework.Class")
local AbilityConst = require("Common.Const.AbilityConst")
local ControllerBase = require("GameApp.Controller.ControllerBase")
local BenchController = require("GameApp.Controller.BenchController")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local InputCommand = require("GameApp.Input.InputCommand")
local TimerManager = require("Core.Timer.TimerManager")
local NoticeDef = require("Common.NoticeDef")
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientConst = require("Const.ClientConst")
local Time = require("Core.Common.Time")
local PlayableConst = require("Common.Const.PlayableConst")
local pg = pg
local DandelionController = Class.LightClass("DandelionController", BenchController)

function DandelionController:ctor(pawn, vehicle)
	DandelionController.super.ctor(self, pawn, vehicle)

	if pawn.eModel then
		pawn.eModel:OnHandleMove(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, 0, 0, 0)
	end

	self.moving = false
end

function DandelionController:enter()
	pg.game.camera.playerCameraMode.defaultCamera:setDamperEnabled(false)

	self.mountDelay = self.controllerData.mountDelay or 0

	if self.mountDelay > 0 then
		self.mountDelayTimer = TimerManager.addTimer(self.mountDelay, function()
			if self.exited then
				return
			end

			self.vehicle:setIsKinematic(false, ClientConst.IsKinematicKey.Dandelion)
		end)
	else
		self.vehicle:setIsKinematic(false, ClientConst.IsKinematicKey.Dandelion)
	end
end

function DandelionController:exit()
	if self.mountDelayTimer then
		TimerManager.removeTimer(self.mountDelayTimer)

		self.mountDelayTimer = nil
	end

	self.exited = true

	self.vehicle:onVehicleMoveStateChanged(false)
	pg.game.camera.playerCameraMode.defaultCamera:setDamperEnabled(true)

	local ctrlData = self.controllerData

	if ctrlData.breakFogRadius and ctrlData.breakFogTime then
		facade:sendLuaEvent("setDandelionFogTime", ctrlData.breakFogRadius, ctrlData.breakFogTime)
	end
end

function DandelionController:onHandleMove(x, y, z)
	DandelionController.super.onHandleMove(self, x, y, z)

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

	local hasMoveInput = x ~= 0 or z ~= 0 or y ~= 0

	if not self.moving and hasMoveInput then
		pawn:playVehicleOverrideAnim({
			loopAnim = "Float_Forward"
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

return DandelionController
