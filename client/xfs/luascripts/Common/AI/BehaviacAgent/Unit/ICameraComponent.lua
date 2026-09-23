-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\BehaviacAgent\\Unit\\ICameraComponent.lua

local Class = require("Core.Framework.Class")
local enums = require("Common.AI.Behaviac.Enums")
local Utils = require("Common.Utils.Utils")
local EBTStatus = enums.EBTStatus
local ICameraComponent = Class.Component("ICameraComponent")

function ICameraComponent:setEnableDof(enable)
	if Utils.checkClient() then
		local CameraConst = require("GameApp.Camera.CameraConst")
		local ClientAbilityConst = require("Const.ClientAbilityConst")

		if enable then
			self.ent.eModel.modelShaderView:SetMultiPassForce32Layer(true, ClientAbilityConst.MULTI_PASS_LAYER)
		else
			self.ent.eModel.modelShaderView:SetMultiPassForce32Layer(false, ClientAbilityConst.MULTI_PASS_LAYER)
		end

		pg.game.camera:setDofEnable(CameraConst.DofStateKeys.Dialogue, enable)
	end

	return EBTStatus.BT_SUCCESS
end

function ICameraComponent:setCameraZoomingIn(delta)
	if Utils.checkClient() then
		pg.game.camera.playerCameraMode:OnCameraZoomingIn(delta)
	end

	return EBTStatus.BT_SUCCESS
end

function ICameraComponent:setCameraZoomingOut(delta)
	if Utils.checkClient() then
		pg.game.camera.playerCameraMode:OnCameraZoomingOut(delta)
	end

	return EBTStatus.BT_SUCCESS
end

function ICameraComponent:getCameraYawAngle()
	if Utils.checkClient() then
		Vector3.enableCreateFromCache()

		local ret = pg.game.camera.playerCameraMode.defaultCamera.cameraMode:GetControlRotation().eulerAngles.y

		Vector3.disableCreateFromCache()

		return ret
	end

	return 0
end

function ICameraComponent:setAfkCamera(delta)
	if Utils.checkClient() then
		pg.game.camera.playerCameraMode:enterAfk(delta or 1)
	end

	return EBTStatus.BT_SUCCESS
end

function ICameraComponent:playFovCurveAnim(fovCurveName, blendInTime, duration, blendOutTime)
	if Utils.checkClient() then
		pg.game.camera.playerCameraMode:playFovCurveAnim(fovCurveName, blendInTime, duration, blendOutTime)
	end

	return EBTStatus.BT_SUCCESS
end

function ICameraComponent:cancelFovCurveAnim()
	if Utils.checkClient() then
		pg.game.camera.playerCameraMode:cancelFovCurveAnim()
	end

	return EBTStatus.BT_SUCCESS
end

function ICameraComponent:blendToFov(fov, blendTime, blendType)
	if Utils.checkClient() then
		pg.game.camera.playerCameraMode:blendToFov(fov, blendTime, blendType)
	end

	return EBTStatus.BT_SUCCESS
end

function ICameraComponent:cancelFovBlend(blendOutTime, blendType)
	if Utils.checkClient() then
		pg.game.camera.playerCameraMode:cancelFovBlend(blendOutTime, blendType)
	end

	return EBTStatus.BT_SUCCESS
end

function ICameraComponent:setAFKScreen(enable)
	if Utils.checkClient() then
		local afkScreenDist = self.ent:getConfigData().afkScreenDist

		if afkScreenDist then
			if enable then
				Vector3.enableCreateFromCache()

				local curForward = self.ent:getRotation():Forward()
				local planeDist = self.ent:getPosition() + curForward * afkScreenDist * self.ent.curModelScale
				local normal = curForward

				self.ent.eModel.modelShaderView:SetAFKBodyScreenDeform(true, planeDist[1], planeDist[2], planeDist[3], normal[1], normal[2], normal[3])
				Vector3.disableCreateFromCache()
			else
				self.ent.eModel.modelShaderView:SetAFKBodyScreenDeform(false)
			end
		end
	end

	return EBTStatus.BT_SUCCESS
end

function ICameraComponent:lookAtEntity(actorId, force)
	if Utils.checkClient() then
		self.ent:lookAtRole(pg.getEntityByActorId(actorId), force)
	end

	return EBTStatus.BT_SUCCESS
end

function ICameraComponent:cancelLookAtEntity()
	if Utils.checkClient() then
		self.ent:cancelLookAtRole()
	end

	return EBTStatus.BT_SUCCESS
end

return ICameraComponent
