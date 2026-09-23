-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Camera\\CameraMode\\PlayerCamera\\PlayerHomelandPetCameraMode.lua

local Class = require("Core.Framework.Class")
local CameraConst = require("GameApp.Camera.CameraConst")
local HotkeyConst = require("Const.HotkeyConst")
local SimpleControlCameraMode = require("GameApp.Camera.CameraMode.SimpleControlCameraMode")
local Utils = require("Common.Utils.Utils")
local PlayerHomelandPetCameraMode = Class.OldLightClass("PlayerHomelandPetCameraMode", SimpleControlCameraMode)

PlayerHomelandPetCameraMode.DEFAULT_BLEND_TIME = 0.35
PlayerHomelandPetCameraMode.DEFAULT_FIELD_OF_VIEW = 50
PlayerHomelandPetCameraMode.DEFAULT_PITCH = 5
PlayerHomelandPetCameraMode.DEFAULT_MIN_DISTANCE = 0.5
PlayerHomelandPetCameraMode.DEFAULT_DISTANCE = 2.5
PlayerHomelandPetCameraMode.DEFAULT_ZOOM_SPEED = 0.75
PlayerHomelandPetCameraMode.INITIAL_FRONT_YAW_OFFSET = 180

function PlayerHomelandPetCameraMode:onCtor()
	SimpleControlCameraMode.onCtor(self)

	self.cameraMode.useFollowTransformRotation = false
	self.cameraMode.defaultBlendTime = self.DEFAULT_BLEND_TIME
	self.cameraMode.fieldOfView = self.DEFAULT_FIELD_OF_VIEW
	self.cameraMode.zoomSpeed = self.DEFAULT_ZOOM_SPEED
	self.cameraMode.springArm.collideMinRadius = 0.02
	self.cameraMode.springArm.waterDetectMode = CS.FunPlus.WorldX.VirtualCamera.WaterDetectMode.BeyondWater
end

function PlayerHomelandPetCameraMode:setActive(isActive)
	SimpleControlCameraMode.setActive(self, isActive)
	pg.game.input:enableControlInput(not isActive, HotkeyConst.INPUT_BLOCK_FLAG.HomelandPetCamera)
end

function PlayerHomelandPetCameraMode:onDestroy()
	self:setActive(false)
	SimpleControlCameraMode.onDestroy(self)
end

function PlayerHomelandPetCameraMode:getCameraName()
	return CameraConst.CAMERA_NAME_HOMELAND_PET
end

function PlayerHomelandPetCameraMode:setPetTarget(actorId)
	if type(actorId) ~= "number" or actorId <= 0 then
		return false
	end

	local petEntity = pg.getEntityByActorId(actorId)

	if not petEntity or petEntity.isDestroyed or not Utils.isHomePet(petEntity) then
		return false
	end

	local targetTransform = CSEntityManager:GetPositionAgentByActorId(actorId)

	if IsNil(targetTransform) then
		return false
	end

	local configData = petEntity:getConfigData() or {}
	local pivotHeight = configData.afkCameraNearHeight or configData.modelHeight or petEntity.bodyHeight or 1
	local minDistance = self.DEFAULT_MIN_DISTANCE
	local targetDistance = self.DEFAULT_DISTANCE

	self.cameraMode.fieldOfView = configData.afkFov or self.DEFAULT_FIELD_OF_VIEW
	self.cameraMode.minZoom = minDistance
	self.cameraMode.maxZoom = targetDistance
	self.cameraMode.springArm.targetArmLength = targetDistance

	local _, targetYaw = targetTransform:GetEulerAnglesEx()
	local controlDir = self.parent.cameraMode:GetControlDir()

	controlDir.x = configData.afkPitch or self.DEFAULT_PITCH
	controlDir.y = targetYaw + self.INITIAL_FRONT_YAW_OFFSET

	self.cameraMode.cameraController:SetControlDir(controlDir)
	self:setCameraTarget(targetTransform)

	self.cameraMode.pivotOffset = Vector3(0, pivotHeight, 0)

	return true
end

return PlayerHomelandPetCameraMode
