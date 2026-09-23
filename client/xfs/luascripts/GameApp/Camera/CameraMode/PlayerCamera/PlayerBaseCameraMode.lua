-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Camera\\CameraMode\\PlayerCamera\\PlayerBaseCameraMode.lua

local CameraMode = require("GameApp.Camera.CameraMode.CameraMode")
local CameraConst = require("GameApp.Camera.CameraConst")
local Class = require("Core.Framework.Class")
local CameraData = require("Data.camera_data")
local TimerManager = require("Core.Timer.TimerManager")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local SysConfigData = require("Data.sys_config_data")
local Time = require("Core.Common.Time")
local PlayerBaseCameraMode = Class.OldLightClass("PlayerBaseCameraMode", CameraMode)
local TagMask = CS.FunPlus.WorldX.Animations.TagMask
local WaterDetectMode = CS.FunPlus.WorldX.VirtualCamera.WaterDetectMode

function PlayerBaseCameraMode:onCtor()
	CameraMode.onCtor(self)

	self.configData = CameraData.baseCamera or {}
	self.targetFov = self.configData.fieldOfView or 50
	self.fovSpeed = nil

	self:initBaseCamera()
end

function PlayerBaseCameraMode:getModeClass()
	return CS.FunPlus.WorldX.VirtualCamera.PlayerCameraMode
end

function PlayerBaseCameraMode:getCameraName()
	return CameraConst.CAMERA_NAME_PLAYER_BASE
end

function PlayerBaseCameraMode:getConfigData()
	return CameraData[CameraConst.CAMERA_NAME_PLAYER_BASE] or {}
end

function PlayerBaseCameraMode:initBaseCamera()
	self.cameraMode.overridePivot = false
	self.cameraMode.springArm.waterDetectMode = WaterDetectMode.BeyondWater
	self.cameraMode.springArm.waterDetectHeight = 2.5
	self.cameraMode.springArm.waterUpOffset = 0.03
	self.cameraMode.springArm.waterDownOffset = 0.03

	self:applyDistanceInfo(true)
	self:resetCameraDamp()
	self:resetCameraFov()
	self:resetPivotDamp()
end

function PlayerBaseCameraMode:onTargetChange(oldPlayer)
	self:resetPivotDamp()
	self:applyDistanceInfo()
end

function PlayerBaseCameraMode:applyDistanceInfo(instant)
	local baseDistance = self.configData.baseDistance or 5
	local minDistance = self.configData.minDistance or 1
	local space = pg.space or nil

	if space and space:isHomeland() then
		minDistance = 1
		baseDistance = 10
	elseif self.parent then
		local targetPlayer = self.parent.targetPlayer

		if targetPlayer then
			if targetPlayer.getOverrideDistanceInfo then
				baseDistance, minDistance = targetPlayer:getOverrideDistanceInfo()
			else
				local entConfigData = targetPlayer:getConfigData()

				baseDistance = entConfigData.baseDistance or baseDistance
				minDistance = entConfigData.minDistance or minDistance
			end
		end
	end

	if space and space:isSupportPetMode() then
		local scale = 1 + SysConfigData.cameraIndexIncreaseRateIn13Mode

		baseDistance = math.round(baseDistance * scale)
	end

	local blendTime = 0.3

	if instant then
		blendTime = -1
	end

	self.cameraMode:SetCameraDistanceInfo(baseDistance, minDistance, blendTime)
end

function PlayerBaseCameraMode:resetPivotDamp()
	self.cameraMode.pivotInterp.dampTime = Vector3(0, 0.5, 0)
	self.cameraMode.springArm.collideMinRadius = 0
end

function PlayerBaseCameraMode:setCameraDampOverride(dampOverrideInfo, resetDampDuration)
	self.dampOverrideInfo = dampOverrideInfo

	if dampOverrideInfo then
		self.dampOverrideInfoForReset = dampOverrideInfo
	end

	self.resetDampDuration = resetDampDuration or 0.5

	self:refreshCameraState()
end

function PlayerBaseCameraMode:applyOverrideDamp()
	local xDamp = self.dampOverrideInfo[1] or 2
	local yDamp = self.dampOverrideInfo[2] or 1.5
	local zDamp = self.dampOverrideInfo[3] or 1

	self.cameraMode.localOffsetDamper.farDistance = Vector3(1, 0, 2)
	self.cameraMode.localOffsetDamper.dampMulti = Vector3(xDamp, 0, zDamp)
	self.cameraMode.globalOffsetDamper.farDistance = Vector3(0, 1, 0)
	self.cameraMode.globalOffsetDamper.dampMulti = Vector3(0, yDamp, 0)
end

function PlayerBaseCameraMode:resetCameraDamp()
	self.cameraMode.localOffsetDamper.blinkDistance = 5
	self.cameraMode.localOffsetDamper.dampTime = Vector3(5, 5, 5)
	self.cameraMode.localOffsetDamper.farDampTime = Vector3(0.1, 0.1, 0.1)
	self.cameraMode.localOffsetDamper.farDistance = Vector3(1, 0, 2)
	self.cameraMode.globalOffsetDamper.blinkDistance = 5
	self.cameraMode.globalOffsetDamper.dampTime = Vector3(5, 5, 5)
	self.cameraMode.globalOffsetDamper.farDampTime = Vector3(0.1, 0.1, 0.1)
	self.cameraMode.globalOffsetDamper.farDistance = Vector3(0, 1, 0)

	if self.dampOverrideInfoForReset then
		local xDamp = self.dampOverrideInfoForReset[1]
		local yDamp = self.dampOverrideInfoForReset[2]
		local zDamp = self.dampOverrideInfoForReset[3]
		local weight = 0

		self.resetTimer = TimerManager.addRepeatTimer(0, function()
			self.cameraMode.localOffsetDamper.dampMulti = Vector3(math.lerp(xDamp, 2, weight), 0, math.lerp(zDamp, 1, weight))
			self.cameraMode.globalOffsetDamper.dampMulti = Vector3(0, math.lerp(yDamp, 1.5, weight), 0)
			weight = weight + 1 / self.resetDampDuration * Time.deltaTime

			if weight >= 1 then
				TimerManager.removeTimer(self.resetTimer)
			end
		end)
		self.dampOverrideInfoForReset = nil
	else
		self.cameraMode.localOffsetDamper.dampMulti = Vector3(2, 0, 1)
		self.cameraMode.globalOffsetDamper.dampMulti = Vector3(0, 1.5, 0)
	end
end

function PlayerBaseCameraMode:setGlideDamp()
	self.cameraMode.localOffsetDamper.dampMulti = Vector3(0, 0, 1)
	self.cameraMode.localOffsetDamper.farDistance = Vector3(0, 0, 0.5)
	self.cameraMode.globalOffsetDamper.dampMulti = Vector3(0, 0, 0)
	self.cameraMode.globalOffsetDamper.farDistance = Vector3(0, 0, 0)
end

function PlayerBaseCameraMode:tick()
	local deltaTime = Time.deltaTime

	self:processFov(deltaTime)
end

function PlayerBaseCameraMode:processFov(deltaTime)
	if self.fovSpeed == nil then
		self.cameraMode.fieldOfView = self.targetFov

		return
	end

	local currFov = self.cameraMode.fieldOfView
	local fovSpeed = deltaTime * self.fovSpeed
	local fovDiff = self.targetFov - currFov

	if self.fovSpeed == 0 or fovSpeed > math.abs(fovDiff) then
		self.cameraMode.fieldOfView = self.targetFov
		self.fovSpeed = nil
	else
		local sign = 1

		if fovDiff < 0 then
			sign = -1
		end

		self.cameraMode.fieldOfView = currFov + fovSpeed * sign
	end
end

function PlayerBaseCameraMode:resetCameraFov(fovSpeed)
	self.targetFov = self.configData.fieldOfView or 50
	self.fovSpeed = fovSpeed
end

function PlayerBaseCameraMode:setCameraFov(fov, fovSpeed)
	self.targetFov = fov
	self.fovSpeed = fovSpeed
end

function PlayerBaseCameraMode:addCollideMinRadius()
	return
end

function PlayerBaseCameraMode:onPlayerStateChange()
	self:refreshCameraState()
end

function PlayerBaseCameraMode:refreshCameraState()
	local playerState = 0
	local targetPlayer = self.parent.targetPlayer

	if targetPlayer then
		playerState = targetPlayer.characterState or 0
	end

	self:updateCameraFocusBone()
	self:refreshCameraDampByState(playerState)
end

function PlayerBaseCameraMode:refreshCameraDampByState(playerState)
	if self.dampOverrideInfo then
		self:applyOverrideDamp()
	elseif CharacterStateConst.isChildOfState(playerState, CharacterStateConst.GLIDING) then
		self:setGlideDamp()
	else
		self:resetCameraDamp()
	end
end

function PlayerBaseCameraMode:setDamperEnabled(enabled)
	self.cameraMode.localOffsetDamper.enable = enabled
	self.cameraMode.globalOffsetDamper.enable = enabled
end

function PlayerBaseCameraMode:updateCameraFocusBone()
	local targetPlayer = self.parent.targetPlayer

	if not targetPlayer then
		return false
	end
end

function PlayerBaseCameraMode:setFarPlane(value)
	if self.cameraMode then
		self.cameraMode.farPlane = value
	end
end

function PlayerBaseCameraMode:setTargetShoulder(shoulder, speed)
	self.cameraMode.targetShoulder = shoulder or Vector3.zero

	if speed ~= nil then
		self.cameraMode.transitionSpeed = speed
	end
end

return PlayerBaseCameraMode
