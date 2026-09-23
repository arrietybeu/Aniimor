-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Camera\\CameraMode\\PlayerCamera\\PlayerAfkCameraMode.lua

local Class = require("Core.Framework.Class")
local CameraConst = require("GameApp.Camera.CameraConst")
local CameraData = require("Data.camera_data")
local ThirdPersonCameraMode = require("GameApp.Camera.CameraMode.ThirdPersonCameraMode")
local ClientAbilityConst = require("Const.ClientAbilityConst")
local Time = require("Core.Common.Time")
local PlayerAfkCameraMode = Class.OldLightClass("PlayerAfkCameraMode", ThirdPersonCameraMode)

function PlayerAfkCameraMode:onCtor()
	ThirdPersonCameraMode.onCtor(self)

	self.fxEntity = nil
	self.cameraMode.springArm.collideMinRadius = 0.02
	self.cameraMode.overridePivot = false
end

function PlayerAfkCameraMode:getModeClass()
	return CS.FunPlus.WorldX.VirtualCamera.PlayerCameraMode
end

function PlayerAfkCameraMode:getCameraName()
	return CameraConst.CAMERA_NAME_AFK
end

function PlayerAfkCameraMode:getConfigData()
	return CameraData[CameraConst.CAMERA_NAME_AFK] or {}
end

function PlayerAfkCameraMode:enter(petEntity)
	if not petEntity then
		return
	end

	local configData = petEntity:getConfigData() or {}
	local afkPitch = configData.afkPitch or 5
	local baseDistance = configData.baseDistanceAfk or configData.baseDistance or 5
	local minDistance = configData.minDistanceAfk or configData.minDistance or 1
	local controller = self.parent.cameraMode.cameraController

	controller.minPitch = afkPitch - 0.2
	controller.maxPitch = afkPitch + 0.2

	controller:SetControlDir(controller:GetControlDir())

	controller.clampPitchSpeed = 3

	self:setActive(true)
	self:_applyAfkVisualEffects(petEntity, true)
end

function PlayerAfkCameraMode:exit()
	self:_applyAfkVisualEffects(nil, false)
	self:setActive(false)
end

function PlayerAfkCameraMode:_applyAfkVisualEffects(petEntity, enable)
	pg.game.camera:setDofEnable(CameraConst.DofStateKeys.ParmonAfk, enable)

	local target = petEntity or self.fxEntity

	if target and target.eModel and target.eModel.modelModelView then
		local shaderView = target.eModel.modelShaderView

		if shaderView then
			shaderView:SetMultiPassForce32Layer(enable, ClientAbilityConst.MULTI_PASS_LAYER)
		end
	end

	if enable then
		self.fxEntity = petEntity
	else
		self.fxEntity = nil
	end
end

function PlayerAfkCameraMode:applyAfkDistanceInfo(instant)
	local baseDistance = self.configData.baseDistance or 5
	local minDistance = self.configData.minDistance or 1

	if self.parent then
		local targetPlayer = self.parent.targetPlayer

		if targetPlayer then
			local entConfigData = targetPlayer:getConfigData()

			baseDistance = entConfigData.baseDistanceAfk or entConfigData.baseDistance or baseDistance
			minDistance = entConfigData.minDistanceAfk or entConfigData.minDistance or minDistance
		end
	end

	local blendTime = 0.3

	if instant then
		blendTime = -1
	end

	self.cameraMode:SetCameraDistanceInfo(baseDistance, minDistance, blendTime)
end

function PlayerAfkCameraMode:onDestroy()
	if self.fxEntity then
		self:_applyAfkVisualEffects(nil, false)
	end
end

return PlayerAfkCameraMode
