-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Camera\\CameraMode\\PhotoCamera\\PhotoCameraMode.lua

local CameraConst = require("GameApp.Camera.CameraConst")
local Class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local UIConst = require("Const.UIConst")
local StackFramingCameraMode = require("GameApp.Camera.CameraMode.StackFramingCameraMode")
local HotkeyConst = require("Const.HotkeyConst")
local PhotoCameraMode = Class.OldLightClass("PhotoCameraMode", StackFramingCameraMode)

function PhotoCameraMode:onCtor()
	StackFramingCameraMode.onCtor(self)

	self.stackCameraObj = nil
	self.fishEyeValue = 80
end

function PhotoCameraMode:getModeClass()
	return CS.FunPlus.WorldX.VirtualCamera.PhotoCameraMode
end

function PhotoCameraMode:getCameraPriority()
	return CameraConst.PRIORITY_PHOTO
end

function PhotoCameraMode:getCameraName()
	return CameraConst.CAMERA_NAME_PHOTO
end

function PhotoCameraMode:move(x, y, z)
	self.cameraMode:DoMove(x, y, z)
end

function PhotoCameraMode:rotate(x, y)
	self.cameraMode:DoRotate(x, y)
	self:rotateExtra()
end

function PhotoCameraMode:rotateExtra()
	if self.stackCameraObj ~= nil then
		local rot = self.stackCameraObj.transform.eulerAngles
		local euler = Quaternion.Euler(0, rot.y, 0)

		pg.me:faceToRotation(euler)
	end
end

function PhotoCameraMode:rotateZ(z)
	self.cameraMode:DoRotateZ(z)
end

function PhotoCameraMode:zoom(value)
	if self.openFishEyeState then
		return
	end

	self.cameraMode:SetFov(value)
end

function PhotoCameraMode:openFishEye()
	if self.openFishEyeState then
		return
	end

	self.oldFieldOfView = self.cameraMode.fieldOfView
	self.openFishEyeState = true

	self.cameraMode:SetFov(self.fishEyeValue)
end

function PhotoCameraMode:closeFishEye()
	if not self.openFishEyeState then
		return
	end

	self.openFishEyeState = false

	self.cameraMode:SetFov(self.oldFieldOfView)
end

function PhotoCameraMode:openFreeCamera()
	self:closeFishEye()
end

function PhotoCameraMode:reset()
	self.cameraMode:Reset()
end

function PhotoCameraMode:AsyncTrans(posX, posY, posZ, rotX, rotY, rotZ)
	self.cameraMode:AsyncTrans(posX, posY, posZ, rotX, rotY, rotZ)
end

function PhotoCameraMode:setMoveRange(centerTransform, bottomRadius, topRadius, height)
	if IsNil(centerTransform) then
		return
	end

	self.cameraMode:SetMoveRange(centerTransform, bottomRadius, topRadius, height, 0, 0.5, 0.3, 0.1, 0.1, 0.8, 0.8, 19)
end

function PhotoCameraMode:getFollowPosition()
	if self.isInFollowType then
		return pg.game.camera:getCameraPosition()
	end

	return self.cameraMode.followTransform.position
end

function PhotoCameraMode:getFollowEulerAngles()
	if self.isInFollowType then
		return Vector3.zero
	end

	return self.cameraMode.followTransform.eulerAngles
end

function PhotoCameraMode:setTarget(target, offset)
	self.cameraMode:SetTarget(target, offset)
end

function PhotoCameraMode:setTargetByActorId(actorId, offsetX, offsetY, offsetZ)
	self.cameraMode:SetTargetByActorId(actorId, offsetX or 0, offsetY or 0, offsetZ or 0)
end

function PhotoCameraMode:setEnableCameraLookAt(enable, entity)
	entity = entity or pg.me

	if entity then
		local lookAtComponent = entity.eModel.ikLookAtComponent

		if lookAtComponent then
			lookAtComponent.enableCameraLookAt = enable
		end
	end
end

function PhotoCameraMode:getLookAtPos(screenX, screenY, entity)
	if not entity then
		return nil
	end

	return self.cameraMode:GetLookAtPos(screenX, screenY, entity:getPosition())
end

function PhotoCameraMode:onRotate()
	if pg.global.ui:checkUIOpen(UIConst.UI_ID_PHOTO) then
		pg.global.ui.photo.photoFuncMenuUIComponent:setOpacity("rotate", true)
	end
end

function PhotoCameraMode:onRotateEnd()
	if pg.global.ui:checkUIOpen(UIConst.UI_ID_PHOTO) then
		pg.global.ui.photo.photoFuncMenuUIComponent:setOpacity("rotate", false)
		pg.global.ui.photo.photoComponent:tryUpdateFocusDis()
	end
end

function PhotoCameraMode:clearFollowType()
	if self.isInFollowType then
		self.cameraMode:ForceClearFollowType()
	end

	self.isInFollowType = false
end

function PhotoCameraMode:openFollowType()
	self.isInFollowType = true

	pg.game.camera:enablePhoto(false)
	pg.game.input:enableControlInput(true, HotkeyConst.INPUT_BLOCK_FLAG.Photo)
end

function PhotoCameraMode:closeFollowType()
	if not self.isInFollowType then
		return
	end

	self.isInFollowType = false

	pg.game.camera:enablePhoto(true)
	pg.game.input:enableControlInput(false, HotkeyConst.INPUT_BLOCK_FLAG.Photo)
end

return PhotoCameraMode
