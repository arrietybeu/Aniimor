-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Camera\\CameraMode\\AvatarCameraMode.lua

local CameraMode = require("GameApp.Camera.CameraMode.CameraMode")
local CameraConst = require("GameApp.Camera.CameraConst")
local ClientConst = require("Const.ClientConst")
local Class = require("Core.Framework.Class")
local AvatarCameraMode = Class.OldLightClass("AvatarCameraMode", CameraMode)

function AvatarCameraMode:onCtor()
	return
end

function AvatarCameraMode:resetAvatarCamera(followTarget, extraInfo)
	extraInfo = extraInfo or {}
	self.cameraMode.followTransform = followTarget
	self.cameraMode.zoomSpeed = extraInfo.zoomSpeed or 1
	self.cameraMode.fieldOfView = extraInfo.fov or 15
	self.sweepRate = extraInfo.sweepRate or Vector2(0.001, 0.002)
	self.minZoomVerticalMoveScale = extraInfo.minZoomVerticalMoveScale or 1

	self.cameraMode.cameraController:SetControlDir(Vector3(0, 180, 0))

	self.minZoomOffsetY = extraInfo.minZoomOffsetY
	self.minZoomOffsetYSplit = extraInfo.minZoomOffsetYSplit
	self.maxZoomOffsetY = extraInfo.maxZoomOffsetY
	self.maxZoomOffsetYRange = extraInfo.maxZoomOffsetYRange
	self.cameraMode.minZoom = extraInfo.minZoom
	self.cameraMode.maxZoom = extraInfo.maxZoom

	if extraInfo.defaultZoom then
		self.defaultZoom = extraInfo.defaultZoom

		self:setSpringArmLen(extraInfo.defaultZoom)
	end

	if extraInfo.defaultY then
		self.defaultY = extraInfo.defaultY

		self:moveCameraInVertical(extraInfo.defaultY)
	end
end

function AvatarCameraMode:getModeClass()
	return CS.FunPlus.WorldX.VirtualCamera.SimpleControlCameraMode
end

function AvatarCameraMode:getCameraPriority()
	return CameraConst.PRIORITY_FIXED
end

function AvatarCameraMode:getCameraName()
	return CameraConst.CAMERA_NAME_AVATAR
end

function AvatarCameraMode:getSpringArmLen()
	if not self.cameraMode then
		return self.defaultZoom
	end

	return self.cameraMode.springArm.targetArmLength
end

function AvatarCameraMode:setSpringArmLen(armLen)
	if not self.cameraMode then
		return
	end

	armLen = math.max(self.cameraMode.minZoom, armLen)
	armLen = math.min(self.cameraMode.maxZoom, armLen)
	self.cameraMode.springArm.targetArmLength = armLen
end

function AvatarCameraMode:getVerticalMoveScale()
	if not self.cameraMode then
		return 1
	end

	local minZoom = self.cameraMode.minZoom
	local maxZoom = self.cameraMode.maxZoom

	if not minZoom or not maxZoom or maxZoom <= minZoom then
		return 1
	end

	local zoom = self.cameraMode.springArm.targetArmLength
	local ratio = math.clamp((zoom - minZoom) / (maxZoom - minZoom), 0, 1)

	return math.lerp(self.minZoomVerticalMoveScale, 1, ratio)
end

function AvatarCameraMode:moveCameraInVertical(deltaY)
	if not self.cameraMode then
		return
	end

	local offsetY = self.cameraMode.pivotOffset.y - deltaY * self.sweepRate.y
	local zoom = self.cameraMode.springArm.targetArmLength
	local minZoom = self.cameraMode.minZoom
	local maxZoom = self.cameraMode.maxZoom

	if minZoom < maxZoom then
		local ratio = (zoom - minZoom) / (maxZoom - minZoom)
		local maxZoomOffsetMinY = self.maxZoomOffsetY
		local maxZoomOffsetMaxY = self.maxZoomOffsetY

		if self.maxZoomOffsetYRange then
			maxZoomOffsetMinY = self.maxZoomOffsetYRange[1] or maxZoomOffsetMinY
			maxZoomOffsetMaxY = self.maxZoomOffsetYRange[2] or maxZoomOffsetMaxY
		end

		local offsetMin = math.lerp(self.minZoomOffsetY[1], maxZoomOffsetMinY, ratio)

		offsetY = math.max(offsetMin, offsetY)

		local offsetMax = math.lerp(self.minZoomOffsetY[2], maxZoomOffsetMaxY, ratio)

		offsetY = math.min(offsetMax, offsetY)
	else
		offsetY = self.defaultY or 0
	end

	if self.cameraMode then
		local oldX = self.cameraMode.pivotOffset[1]

		self.cameraMode.pivotOffset = Vector3(oldX, offsetY, 0)
	end
end

function AvatarCameraMode:moveCameraInVector(dtx, dty)
	if self.cameraMode then
		self.cameraMode.pivotOffset = Vector3(dtx, dty, 0)
	end
end

function AvatarCameraMode:getPivotOffset()
	if not self.cameraMode then
		return self.defaultY
	end

	return self.cameraMode.pivotOffset
end

function AvatarCameraMode:getPivotOffsetY()
	if not self.cameraMode then
		return self.defaultY
	end

	return self.cameraMode.pivotOffset.y
end

function AvatarCameraMode:setPivotOffsetY(offsetY)
	if self.cameraMode == nil then
		return
	end

	local old = self.cameraMode.pivotOffset

	self.cameraMode.pivotOffset = Vector3(old.x, offsetY, old.z)
end

function AvatarCameraMode:setPivotOffsetX(offsetX)
	if self.cameraMode == nil then
		return
	end

	local old = self.cameraMode.pivotOffset

	self.cameraMode.pivotOffset = Vector3(offsetX, old.y, old.z)
end

function AvatarCameraMode:getControlDir()
	if self.cameraMode == nil then
		return nil
	end

	return self.cameraMode.cameraController:GetControlDir()
end

function AvatarCameraMode:setControlDir(dir)
	if self.cameraMode == nil or dir == nil then
		return
	end

	self.cameraMode.cameraController:SetControlDir(dir)
end

function AvatarCameraMode:getCameraState()
	if self.cameraMode == nil then
		return nil
	end

	local pivot = self.cameraMode.pivotOffset
	local dir = self.cameraMode.cameraController:GetControlDir()

	return {
		springArmLen = self.cameraMode.springArm.targetArmLength,
		pivotX = pivot.x,
		pivotY = pivot.y,
		dirX = dir and dir.x or 0,
		dirY = dir and dir.y or 180,
		dirZ = dir and dir.z or 0
	}
end

function AvatarCameraMode:applyCameraState(state)
	if self.cameraMode == nil or state == nil then
		return
	end

	if state.springArmLen ~= nil then
		self:setSpringArmLen(state.springArmLen)
	end

	if state.pivotX ~= nil and state.pivotY ~= nil then
		self:moveCameraInVector(state.pivotX, state.pivotY)
	end

	self.cameraMode.cameraController:SetControlDir(Vector3(state.dirX or 0, state.dirY or 180, state.dirZ or 0))
end

return AvatarCameraMode
