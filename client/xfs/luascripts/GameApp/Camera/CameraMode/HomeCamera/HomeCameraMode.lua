-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Camera\\CameraMode\\HomeCamera\\HomeCameraMode.lua

local CameraMode = require("GameApp.Camera.CameraMode.CameraMode")
local CameraConst = require("GameApp.Camera.CameraConst")
local Class = require("Core.Framework.Class")
local HomelandConfigData = require("Data.homeland_config_data")
local HomeCameraMode = Class.OldLightClass("HomeCameraMode", CameraMode)

function HomeCameraMode:onCtor()
	self.moveBounds = nil
	self.minDistance = 10
	self.maxDistance = 50
	self.minSpeed = 2
	self.maxSpeed = 20
	self.cameraFov = 25

	self:initCameraMode()
end

function HomeCameraMode:getModeClass()
	return CS.FunPlus.WorldX.VirtualCamera.HomeEditorCamera
end

function HomeCameraMode:getCameraName()
	return CameraConst.CAMERA_NAME_HOME
end

function HomeCameraMode:GetPosition()
	return self.cameraMode.centerPosition
end

function HomeCameraMode:setMoveBounds(basePosition, baseRotation, bounds)
	self.moveBounds = bounds
	self.basePosition = basePosition
	self.baseRotation = baseRotation

	self.cameraMode:SetBaseTransform(basePosition, baseRotation)

	if self.moveBounds then
		self.cameraMode:SetMoveBounds(true, self.moveBounds[1], self.moveBounds[2], self.moveBounds[3], self.moveBounds[4])
	else
		self.cameraMode:SetMoveBounds(false, 0, 0, 0, 0)
	end
end

function HomeCameraMode:getPosition()
	return self.cameraMode.centerPosition
end

function HomeCameraMode:getRotationDir()
	return self.cameraMode.cameraController:GetControlDir()
end

function HomeCameraMode:setInitRotation(rotation)
	local eulerYaw = rotation:GetEulerAnglesY()

	self.cameraMode.cameraController:SetControlRotation(Quaternion.Euler(45, eulerYaw, 0))
end

function HomeCameraMode:setRotation(rotation)
	self.cameraMode.cameraController:SetControlRotation(rotation)
end

function HomeCameraMode:clampPosition(position, bounds)
	bounds = bounds or self.moveBounds

	if not bounds then
		return position:Clone()
	end

	local localToWorld = Matrix4x4.TRS(self.basePosition, self.baseRotation, Vector3.constOne)
	local localPosition = localToWorld.inverse:MultiplyPoint(position)

	localPosition.x = math.clamp(localPosition.x, bounds[1], bounds[2])
	localPosition.z = math.clamp(localPosition.z, bounds[3], bounds[4])

	return localToWorld:MultiplyPoint(localPosition)
end

function HomeCameraMode:setPosition(position, bounds)
	local centerPos = self:clampPosition(position, bounds)

	centerPos.y = self.basePosition.y
	self.cameraMode.centerPosition = centerPos
end

function HomeCameraMode:initCameraMode()
	local cameraPitchRange = HomelandConfigData.cameraPitchRange or {
		30,
		88
	}

	self.cameraMode.cameraController.minPitch = cameraPitchRange[1]
	self.cameraMode.cameraController.maxPitch = cameraPitchRange[2]
	self.cameraMode.fieldOfView = self.cameraFov

	self:setDistance((self.minDistance + self.maxDistance) * 0.5)
end

function HomeCameraMode:handleMove(x, y)
	self.cameraMode:SetMoveAxis(x, y)
end

function HomeCameraMode:zoomIn()
	self:setDistance(self.cameraMode.distance - 5)
	self:setOverlookDistance(self.cameraMode.overlookState.overlookDistance - 5)
end

function HomeCameraMode:zoomOut()
	self:setDistance(self.cameraMode.distance + 5)
	self:setOverlookDistance(self.cameraMode.overlookState.overlookDistance + 5)
end

function HomeCameraMode:handleZoom(delta)
	self:setDistance(self.cameraMode.distance + delta)
	self:setOverlookDistance(self.cameraMode.overlookState.overlookDistance + delta)
end

function HomeCameraMode:getDistance()
	return self.cameraMode.distance
end

function HomeCameraMode:setDistanceRange(min, max)
	self.minDistance = min
	self.maxDistance = max

	self:setDistance((self.minDistance + self.maxDistance) * 0.5)
end

function HomeCameraMode:setSpeedRange(min, max)
	self.minSpeed = min
	self.maxSpeed = max

	self:setDistance(self.cameraMode.distance)
end

function HomeCameraMode:setEditorFov(fov)
	self.cameraFov = fov
	self.cameraMode.fieldOfView = self.cameraFov
end

function HomeCameraMode:setHeightOffset(offset)
	self.cameraMode.heightOffset = offset
end

function HomeCameraMode:setGroundClearance(clearance)
	self.cameraMode.groundClearance = clearance
end

function HomeCameraMode:setDistance(distance)
	distance = math.clamp(distance, self.minDistance, self.maxDistance)
	self.cameraMode.distance = distance

	self:refreshMoveSpeed()
end

function HomeCameraMode:setOverlookDistance(distance)
	distance = math.clamp(distance, self.maxDistance - 15, self.maxDistance)
	self.cameraMode.overlookState.overlookDistance = distance

	self:refreshMoveSpeed()
end

function HomeCameraMode:refreshMoveSpeed()
	local distance = self.cameraMode.distance

	if self.isInOverlook then
		distance = self.cameraMode.overlookState.overlookDistance
	end

	local distRange = self.maxDistance - self.minDistance
	local t = distRange > 0 and (distance - self.minDistance) / distRange or 1

	self.cameraMode.moveSpeed = math.lerp(self.minSpeed, self.maxSpeed, t)
end

function HomeCameraMode:setOverlookMode(enabled)
	self.isInOverlook = enabled

	if enabled then
		self.cameraMode:SetInOverlookState(true, self.cameraMode.cameraController.maxPitch, self.maxDistance, 0.2)
	else
		local curDir = self.cameraMode.cameraController:GetControlDir()

		self.cameraMode.cameraController:SetControlDir(Vector3(45, curDir.y, 0))
		self.cameraMode:SetInOverlookState(false)
		self:setDistance((self.minDistance + self.maxDistance) * 0.5)
	end

	self:refreshMoveSpeed()
end

return HomeCameraMode
