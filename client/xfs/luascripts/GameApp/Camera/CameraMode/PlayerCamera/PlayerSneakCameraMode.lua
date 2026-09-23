-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Camera\\CameraMode\\PlayerCamera\\PlayerSneakCameraMode.lua

local Class = require("Core.Framework.Class")
local CameraConst = require("GameApp.Camera.CameraConst")
local CameraData = require("Data.camera_data")
local ThirdPersonCameraMode = require("GameApp.Camera.CameraMode.ThirdPersonCameraMode")
local PlayerSneakCameraMode = Class.OldLightClass("PlayerSneakCameraMode", ThirdPersonCameraMode)
local WaterDetectMode = CS.FunPlus.WorldX.VirtualCamera.WaterDetectMode

function PlayerSneakCameraMode:onCtor()
	ThirdPersonCameraMode.onCtor(self)

	local mode = self.cameraMode
	local springArm = mode.springArm

	mode.minPitchOnChannel = -1
	mode.maxPitchOnChannel = 0
	mode.pivotOffsetOnChannel = Vector3(0, 0.2, 0)
	springArm.collideMinRadius = 0.19
	springArm.waterDownOffset = -0.2
	springArm.waterDetectMode = WaterDetectMode.BelowSolid
	springArm.layerWater = CS.FunPlus.WorldX.Const.LayerDefine.STABLE_GROUND_LAYERS
end

function PlayerSneakCameraMode:fromCamera(camera)
	if not camera then
		return
	end

	local mode = self.cameraMode
	local springArm = mode.springArm
	local controller = mode.cameraController

	mode.fieldOfView = camera.fieldOfView
	mode.targetShoulder = camera.shoulder
	mode.targetPivotOffset = camera.pivotOffset
	mode.pivotOffsetOutChannel = camera.pivotOffset
	mode.minPitch = -10
	mode.maxPitch = 80
	mode.nearDump = 0
	mode.nearDumpInOutChannel = 2
	mode.moveStepSpeed = 3
	mode.pitchLerpSpeed = 60
	springArm.cameraRadius = 0.1
	springArm.nearDamp = 0
	springArm.farDamp = 0.8

	local armLen = camera.springArm.targetArmLength

	if armLen < 4.5 then
		springArm.targetArmLength = 4.5
	else
		springArm.targetArmLength = armLen
	end

	springArm.waterDetectHeight = 1

	if pg.pawn.inShortHole then
		self:enterShortHole()
	end
end

function PlayerSneakCameraMode:enterShortHole()
	local mode = self.cameraMode
	local springArm = mode.springArm

	mode.minPitch = -1
	mode.maxPitch = 0
	springArm.targetArmLength = 2
	springArm.keepBelowSolidDetection = true
end

function PlayerSneakCameraMode:leaveShortHole()
	local mode = self.cameraMode
	local springArm = mode.springArm

	mode.minPitch = -10
	mode.maxPitch = 80
	springArm.targetArmLength = 4.5
	springArm.nearDamp = 0
	springArm.keepBelowSolidDetection = false
end

function PlayerSneakCameraMode:getModeClass()
	return CS.FunPlus.WorldX.VirtualCamera.SneakCameraMode
end

function PlayerSneakCameraMode:getCameraName()
	return CameraConst.CAMERA_NAME_SNEAK
end

function PlayerSneakCameraMode:getConfigData()
	return CameraData[CameraConst.CAMERA_NAME_SNEAK] or {}
end

return PlayerSneakCameraMode
