-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Camera\\CameraMode\\FocusTargetCameraMode.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local CameraMode = require("GameApp.Camera.CameraMode.CameraMode")
local CameraConst = require("GameApp.Camera.CameraConst")
local CameraData = require("Data.camera_data")
local Class = require("Core.Framework.Class")
local FocusTargetCameraMode = Class.OldLightClass("FocusTargetCameraMode", CameraMode)

FocusTargetCameraMode.CameraPresetKey = {
	PlayerInfo = 1,
	FriendshipUp = 2
}
FocusTargetCameraMode.CameraPreset = {
	{
		yaw = 0,
		pitch = 0,
		fov = 20,
		distance = 2.6,
		bvScreenPosY = 0.1,
		bvScreenPosX = 0.5
	},
	{
		yaw = 0,
		pitch = 0,
		fov = 30,
		distance = 1.2,
		bvScreenPosY = 0,
		bvScreenPosX = 0.5
	}
}

function FocusTargetCameraMode:onCtor()
	CameraMode.onCtor(self)

	self.focusCameraKey = 0
end

function FocusTargetCameraMode:_nextKey()
	self.focusCameraKey = self.focusCameraKey + 1

	return self.focusCameraKey
end

function FocusTargetCameraMode:onDestroy()
	self.cameraMode:RemoveAllEntities()
	CameraMode.onDestroy(self)
end

function FocusTargetCameraMode:getModeClass()
	return CS.FunPlus.WorldX.VirtualCamera.FocusTargetCameraMode
end

function FocusTargetCameraMode:getCameraPriority()
	return CameraConst.PRIORITY_DEFAULT
end

function FocusTargetCameraMode:getCameraName()
	return CameraConst.CAMERA_NAME_FOCUS_TARGET
end

function FocusTargetCameraMode:getConfigData()
	return CameraData[CameraConst.CAMERA_NAME_FOCUS_TARGET] or {}
end

function FocusTargetCameraMode:enableCamera(active, presetName, entities)
	if active then
		if self:playCameraPreset(presetName, entities) then
			self:setActive(active)
		end
	else
		self.cameraMode:SwitchToTransitionOutState()
		self:setActive(active)
	end
end

function FocusTargetCameraMode:enableCustomCamera(active, entities, cameraParam)
	if active then
		if self:playCustomCamera(entities, cameraParam) then
			self:setActive(true)
		end
	else
		self.cameraMode:SwitchToTransitionOutState()
		self:setActive(false)
	end
end

function FocusTargetCameraMode:playCameraPreset(presetName, entities)
	local configData = self.CameraPreset[presetName]

	if not configData then
		return false
	end

	self.cameraMode:RemoveAllEntities()

	for id, entity in pairs(entities) do
		if entity and entity.eModel then
			self.cameraMode:AddEntity(id, entity.eModel)
		end
	end

	self.cameraMode:SolveTargetCameraStateByScreenPos(presetName, Vector2(configData.bvScreenPosX, configData.bvScreenPosY), configData.fov, configData.distance, configData.pitch, configData.yaw)

	self.cameraMode.defaultBlendTime = 0

	return true
end

function FocusTargetCameraMode:playCustomCamera(entities, cameraParam)
	cameraParam = cameraParam or {}

	self.cameraMode:RemoveAllEntities()

	local hasEntity = false

	for id, entity in pairs(entities or EMPTY_TABLE) do
		if entity and entity.eModel then
			self.cameraMode:AddEntity(id, entity.eModel)

			hasEntity = true
		end
	end

	if not hasEntity then
		return false
	end

	if cameraParam.position and cameraParam.rotation then
		self.cameraMode.fieldOfView = cameraParam.fov or 48

		self.cameraMode:SetPosition(cameraParam.position)
		self.cameraMode:SetRotation(cameraParam.rotation)
	else
		self.cameraMode:SolveTargetCameraStateByScreenPos(self:_nextKey(), cameraParam.bvScreenPos or Vector2(0.5, 0.08), cameraParam.fov or 48, cameraParam.distance or 9, cameraParam.pitch or 4, cameraParam.yaw or 22)
	end

	self.cameraMode.defaultBlendTime = cameraParam.blendTime or 0.8

	return true
end

return FocusTargetCameraMode
