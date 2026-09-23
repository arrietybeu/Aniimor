-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Camera\\CameraMode\\NpcDialogueCameraMode.lua

local CameraMode = require("GameApp.Camera.CameraMode.CameraMode")
local CameraConst = require("GameApp.Camera.CameraConst")
local ClientConst = require("Const.ClientConst")
local CameraData = require("Data.camera_data")
local DialogCameraPreset = require("Common.Const.DialogueCameraPreset")
local Class = require("Core.Framework.Class")
local Utils = require("Common.Utils.Utils")
local DialogueConst = require("Const.DialogueConst")
local PuppetData = require("Data.puppet_data")
local ToBool = ToBool
local VirtualCameraBlendFunction = CS.FunPlus.WorldX.VirtualCamera.VirtualCameraBlendFunction
local NpcDialogueCameraMode = Class.OldLightClass("NpcDialogueCameraMode", CameraMode)

NpcDialogueCameraMode.CAMERA_PRESET_FUNC = {
	[ClientConst.DialogueCameraPreset.FocusToTarget] = "playFocusToTarget",
	[ClientConst.DialogueCameraPreset.PlayCameraAnim] = "playCameraAnim"
}

function NpcDialogueCameraMode:onCtor()
	CameraMode.onCtor(self)
end

function NpcDialogueCameraMode:getModeClass()
	return CS.FunPlus.WorldX.VirtualCamera.NpcDialogueCameraMode
end

function NpcDialogueCameraMode:getCameraPriority()
	return CameraConst.PRIORITY_NPC_DIALOGUE_CAMERA
end

function NpcDialogueCameraMode:getCameraName()
	return CameraConst.CAMERA_NAME_NPC_DIALOGUE
end

function NpcDialogueCameraMode:getConfigData()
	return CameraData[CameraConst.CAMERA_NAME_NPC_DIALOGUE] or {}
end

function NpcDialogueCameraMode:enableCamera(active, presetName, targetEntity, callback, extraInfo)
	if active then
		local func = self.CAMERA_PRESET_FUNC[presetName]

		if func and self[func] then
			if self[func](self, presetName, targetEntity, callback, extraInfo) then
				pg.game.input:temporarilyDisableViewControl(9999)
				self:setActive(active)
			end
		elseif self:playCameraPreset(presetName, targetEntity, callback, extraInfo) then
			pg.game.input:temporarilyDisableViewControl(9999)
			self:setActive(active)
		end
	else
		self.cameraMode:SwitchToTransitionOutState()
		self:setActive(active)
		pg.game.input:cancelTemporarilyDisableViewControl()
	end
end

function NpcDialogueCameraMode:setTargetPosition(position)
	if self.cameraMode then
		self.cameraMode:SetTargetPosition(position)
	end
end

function NpcDialogueCameraMode:setTargetRotation(rotation)
	if self.cameraMode then
		self.cameraMode:SetTargetRotation(rotation)
	end
end

function NpcDialogueCameraMode:setTargetFov(fov)
	if self.cameraMode then
		self.cameraMode:SetTargetFov(fov)
	end
end

function NpcDialogueCameraMode:playFocusToTarget(presetName, targetEntity, callback, extraInfo)
	if not targetEntity then
		return false
	end

	self.cameraMode.needProgramControlTransition = false
	self.cameraMode.callback = callback

	local offset = targetEntity:getRotation():MulVec3(Vector3(0, 1.5, 3))
	local distance = (targetEntity:getPosition() - pg.pawn:getPosition()):Magnitude()

	self.cameraMode:SetPosition(targetEntity:getPosition() + offset)

	local dir = offset:Normalize()

	self.cameraMode:SetRotation(Quaternion.LookRotation(-dir, Vector3.up))

	self.cameraMode.defaultBlendTime = distance / 9
	self.blendFunction = VirtualCameraBlendFunction.EaseOut
	self.blendExponent = 2

	return true
end

function NpcDialogueCameraMode:playCameraPreset(presetName, targetEntity, callback, extraInfo)
	local configData = DialogCameraPreset[presetName]

	if not configData then
		return false
	end

	if targetEntity and targetEntity.eModel then
		self.cameraMode.targetNpc = targetEntity.eModel

		local isNpcInBv = extraInfo and extraInfo.isNpcInBv or true

		if extraInfo and extraInfo.needTransition then
			self.cameraMode.needProgramControlTransition = true

			self.cameraMode:TransitionToTargetCameraStateByScreenPos(presetName, Vector2(configData.fvScreenPosX, configData.fvScreenPosY), Vector2(configData.bvScreenPosX, configData.bvScreenPosY), configData.fov, configData.yaw, isNpcInBv)
		else
			self.cameraMode.needProgramControlTransition = false

			self.cameraMode:SolveTargetCameraStateByScreenPos(presetName, Vector2(configData.fvScreenPosX, configData.fvScreenPosY), Vector2(configData.bvScreenPosX, configData.bvScreenPosY), configData.fov, configData.yaw, isNpcInBv)
		end
	else
		self.cameraMode.needProgramControlTransition = false

		self.cameraMode:SolveTargetCameraStateByScreenPos(presetName, Vector2(configData.bvScreenPosX, configData.bvScreenPosY), configData.fov, configData.distance, configData.pitch, configData.yaw)
	end

	self.cameraMode.defaultBlendTime = 0
	self.cameraMode.callback = callback

	return true
end

function NpcDialogueCameraMode:playCameraAnim(presetName, targetEntity, callback, extraInfo)
	local animResId = extraInfo and extraInfo.animResId
	local baseTransform = extraInfo and extraInfo.baseTransform
	local baseTransformActorId = extraInfo and extraInfo.baseTransformActorId
	local initRotation = extraInfo and extraInfo.initRotation or Quaternion.identity

	if string.isNilOrEmpty(animResId) then
		return false
	end

	if baseTransform == nil and baseTransformActorId ~= nil then
		baseTransform = CSEntityManager:GetPositionAgentByActorId(baseTransformActorId)
	end

	if baseTransform == nil then
		return false
	end

	self.cameraMode.needProgramControlTransition = false
	self.cameraMode.defaultBlendTime = 0

	self.cameraMode:PlayCameraAnim(animResId, baseTransform, initRotation, false)

	return true
end

function NpcDialogueCameraMode:enableFreedomCamera(enable, initRot, focusPos, zoomMin, zoomMax, distance, fov)
	if self.cameraMode.isActive == enable then
		return
	end

	self.cameraMode:EnableFreedomCameraMode(focusPos, initRot, zoomMin, zoomMax, distance)

	self.cameraMode.fieldOfView = fov
	self.cameraMode.defaultBlendTime = 0.5

	self:setActive(enable)
end

function NpcDialogueCameraMode:handleCameraZoom(zoomValue)
	if zoomValue > 0.01 or zoomValue < -0.01 then
		self.cameraMode:HandleZoom(-zoomValue)
	end
end

function NpcDialogueCameraMode:onFreedomCameraDrag(x, y)
	if x ~= 0 then
		self.cameraMode:HandleRotationByHand(x, y)
	end
end

function NpcDialogueCameraMode:enableFreedomCameraAutoRotation(enable)
	self.cameraMode.enableAutoRotation = enable

	if enable then
		self.cameraMode:HandleRotationByHand(0, 0)
	end
end

return NpcDialogueCameraMode
