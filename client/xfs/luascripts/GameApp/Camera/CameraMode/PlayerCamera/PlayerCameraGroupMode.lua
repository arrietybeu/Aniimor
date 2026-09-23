-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Camera\\CameraMode\\PlayerCamera\\PlayerCameraGroupMode.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local ClientConst = require("Const.ClientConst")
local ClientUtils = require("Utils.ClientUtils")
local CameraConst = require("GameApp.Camera.CameraConst")
local CameraGroupMode = require("GameApp.Camera.CameraMode.CameraGroupMode")
local CameraData = require("Data.camera_data")
local SysConfigData = require("Data.sys_config_data")
local ClientSettingUtils = require("Utils.ClientSettingUtils")
local ClientSwitch = require("Common.ClientSwitch")
local PlayerAimCameraMode = require("GameApp.Camera.CameraMode.PlayerCamera.PlayerAimCameraMode")
local PlayerCatchCameraMode = require("GameApp.Camera.CameraMode.PlayerCamera.PlayerCatchCameraMode")
local PlayerMagnesisCameraMode = require("GameApp.Camera.CameraMode.PlayerCamera.PlayerMagnesisCameraMode")
local PlayerSneakCameraMode = require("GameApp.Camera.CameraMode.PlayerCamera.PlayerSneakCameraMode")
local PlayerFlyCameraMode = require("GameApp.Camera.CameraMode.PlayerCamera.PlayerFlyCameraMode")
local PlayerAnimCameraMode = require("GameApp.Camera.CameraMode.PlayerCamera.PlayerAnimCameraMode")
local PlayerFaceToCameraMode = require("GameApp.Camera.CameraMode.PlayerCamera.PlayerFaceToCameraMode")
local PlayerBaseCameraMode = require("GameApp.Camera.CameraMode.PlayerCamera.PlayerBaseCameraMode")
local PlayerClimbCameraMode = require("GameApp.Camera.CameraMode.PlayerCamera.PlayerClimbCameraMode")
local LockOnCameraMode = require("GameApp.Camera.CameraMode.LockCamera.LockOnCameraMode")
local ThirdPersonLockOnCameraMode = require("GameApp.Camera.CameraMode.PlayerCamera.ThirdPersonLockOnCameraMode")
local LockOnExtendCameraMode = require("GameApp.Camera.CameraMode.PlayerCamera.LockOnExtendCameraMode")
local NormalAttackLockOnCameraMode = require("GameApp.Camera.CameraMode.PlayerCamera.NormalAttackLockOnCameraMode")
local PlayerScrollCameraMode = require("GameApp.Camera.CameraMode.PlayerCamera.PlayerScrollCameraMode")
local PlayerGhostEyeCameraMode = require("GameApp.Camera.CameraMode.PlayerCamera.PlayerGhostEyeCameraMode")
local PlayerPeepCameraMode = require("GameApp.Camera.CameraMode.PlayerCamera.PlayerPeepCameraMode")
local PlayerRideDragonBossCameraMode = require("GameApp.Camera.CameraMode.PlayerCamera.PlayerRideDragonBossCameraMode")
local PlayerPaintAreaCameraMode = require("GameApp.Camera.CameraMode.PlayerCamera.PlayerPaintAreaCameraMode")
local PlayerGrabEggUndergroundPalaceCameraMode = require("GameApp.Camera.CameraMode.PlayerCamera.PlayerGrabEggUndergroundPalaceCameraMode")
local PlayerEggCarriedCameraMode = require("GameApp.Camera.CameraMode.PlayerCamera.PlayerEggCarriedCameraMode")
local PlayerAfkCameraMode = require("GameApp.Camera.CameraMode.PlayerCamera.PlayerAfkCameraMode")
local PlayerHomelandPetCameraMode = require("GameApp.Camera.CameraMode.PlayerCamera.PlayerHomelandPetCameraMode")
local Utils = require("Common.Utils.Utils")
local UIConst = require("Const.UIConst")
local Time = require("Core.Common.Time")
local TimerManager = require("Core.Timer.TimerManager")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local HotkeyConst = require("Const.HotkeyConst")
local VirtualCameraBlendFunction = CS.FunPlus.WorldX.VirtualCamera.VirtualCameraBlendFunction
local PlayerCameraGroupMode = Class.OldLightClass("PlayerCameraGroupMode", CameraGroupMode)
local CinemachineImpulseModifier = CS.FunPlus.WorldX.VirtualCamera.CinemachineImpulseModifier
local CameraShakeModifier = CS.FunPlus.WorldX.VirtualCamera.CameraShakeModifier
local CameraCommonModifier = CS.FunPlus.WorldX.VirtualCamera.CameraCommonModifier
local CameraFovModifier = CS.FunPlus.WorldX.VirtualCamera.CameraFovModifier
local CameraFovCurveModifier = CS.FunPlus.WorldX.VirtualCamera.CameraFovCurveModifier
local Vector3 = Vector3

local function isClimbCameraState(self, characterState)
	local targetPlayer = self.targetPlayer

	if targetPlayer then
		characterState = characterState or targetPlayer.characterState
	end

	if not targetPlayer then
		return false
	end

	return characterState == CharacterStateConst.CLIMBIDLE or characterState == CharacterStateConst.CLIMBMOVE or characterState == CharacterStateConst.CLIMBON or characterState == CharacterStateConst.CLIMBDASH
end

function PlayerCameraGroupMode:onCtor()
	CameraGroupMode.onCtor(self)
	self:initBaseInfo()

	self.isInAim = false
	self.lastInCombat = false
	self.lastAdjustEnemyTime = 0
	self.targetTrans = nil
	self.faceToEndTime = 0
	self.enableInputTime = 0
	self.enableAutoZoomAndRecenter = true
	self.minLightZoomValue = 0.3
	self.minLightAngleValue = 90
	self.maxLightZoomValue = 0.1
	self.maxLightAngleValue = 180
	self.lightZoomRate = 5
	self.lightAngleRate = 0.044
	self.pitchRecenterInfo = {}
	self.yawRecenterInfo = {}
	self.recenterAreaPitchInfo = {}
	self.recenterAreaYawInfo = {}
	self.recenterAreaValid = false
end

function PlayerCameraGroupMode:onDestroy()
	self.targetPlayer = nil
	self.targetTrans = nil
end

function PlayerCameraGroupMode:setActive(active)
	CameraGroupMode.setActive(self, active)

	if not active then
		self:cancelFaceToTarget()
		self:setEnableCameraLookAt(false)
	end
end

function PlayerCameraGroupMode:onSceneLoaded(sceneId, sceneName)
	self:resetCameraZoom(true)
end

function PlayerCameraGroupMode:onSceneUnloaded(sceneId, sceneName)
	self:resetCameraZoom(false)
end

function PlayerCameraGroupMode:onTransitionFromMode(fromCameraMode)
	if fromCameraMode then
		if fromCameraMode.cameraName == CameraConst.CAMERA_NAME_FIXED_WITH_TARGET or fromCameraMode.cameraName == CameraConst.CAMERA_NAME_ITEM_OBTAIN_FRONT then
			local fromCameraView = fromCameraMode:GetCameraView()
			local fromRotation = fromCameraView.rotation

			self.cameraMode.cameraController:SetControlRotation(fromRotation)
			self:zoomToValue(0.2, true)
		end

		if fromCameraMode.cameraName == CameraConst.CAMERA_NAME_ANIM or fromCameraMode.cameraName == CameraConst.CAMERA_NAME_LOW_PRIORITY_ANIM then
			if fromCameraMode.inheritDir then
				local fromCameraView = fromCameraMode:GetCameraView()
				local fromRotation = fromCameraView.rotation

				self.cameraMode.cameraController:SetControlRotation(fromRotation)
				self:zoomToValue(1, true)
			else
				self.cameraMode:ResetControlDir()
			end

			self.cameraMode:ResetAxisHelpers()
			self:zoomToValue(1, true)

			return true
		end

		if fromCameraMode.cameraName == "CutsceneCamera" then
			local fromCameraView = fromCameraMode:GetCameraView()
			local fromRotation = fromCameraView.rotation

			if fromCameraMode.resetDir then
				self.cameraMode:ResetControlDir()
			else
				self.cameraMode.cameraController:SetControlRotation(fromRotation)
			end

			self.cameraMode:ResetAxisHelpers()
			self:zoomToValue(1, true)

			return true
		end

		if fromCameraMode.cameraName == CameraConst.CAMERA_NAME_LEVEL then
			if fromCameraMode.ownerLua then
				if fromCameraMode.ownerLua.resetDir then
					self:resetCamera()

					return true
				end
			else
				self.cameraMode:ResetControlDir()

				return true
			end
		end

		if fromCameraMode.cameraName == CameraConst.CAMERA_NAME_FACE_TO then
			return true
		end

		if fromCameraMode.cameraName == CameraConst.CAMERA_NAME_COMBINE_CINEMACHINE then
			if fromCameraMode.blendOutInheritDir then
				local fromCameraView = fromCameraMode:GetCameraView()
				local fromRotation = fromCameraView.rotation

				self.cameraMode.cameraController:SetControlRotation(fromRotation)

				fromCameraMode.blendOutInheritDir = false
			end

			if fromCameraMode.blendOutTime >= 0 then
				self.cameraMode.blendTime = fromCameraMode.blendOutTime
				fromCameraMode.blendOutTime = -1
			end

			return true
		end

		if fromCameraMode.cameraName == CameraConst.QUICK_PHOTO_CAMERA_NAME then
			return true
		end

		if fromCameraMode.cameraName == CameraConst.CAMERA_NAME_PHOTO then
			return true
		end

		if fromCameraMode.cameraName == CameraConst.QUICK_PHOTO_FACE_TO_CAMERA_NAME then
			return true
		end

		if fromCameraMode.cameraName == CameraConst.CAMERA_NAME_LOCK_ON_EXTEND_CAMERA or fromCameraMode.cameraName == CameraConst.CAMERA_NAME_NORMAL_ATTACK_LOCK_ON_CAMERA then
			return true
		end

		if fromCameraMode.cameraName == CameraConst.CAMERA_NAME_PVP_LOADING then
			return true
		end

		if fromCameraMode.cameraName == CameraConst.CAMERA_NAME_HOME_GROUP then
			self.cameraMode:ResetControlDir()

			return true
		end
	end

	return false
end

function PlayerCameraGroupMode:onPostTransitionFromMode(fromCameraMode)
	local zoomValue = self.cameraMode.cameraZoom.targetZoomValue

	self:setZoomIndex(math.round(zoomValue * self.indexNum))

	self.extendCount = 0
end

function PlayerCameraGroupMode:getCameraName()
	return CameraConst.CAMERA_NAME_PLAYER
end

function PlayerCameraGroupMode:getConfigData()
	return CameraData[CameraConst.CAMERA_NAME_PLAYER] or {}
end

function PlayerCameraGroupMode:getModeClass()
	return CS.FunPlus.WorldX.VirtualCamera.PlayerCameraGroupMode
end

function PlayerCameraGroupMode:isInBaseCamera()
	return self.defaultCamera:isTop()
end

function PlayerCameraGroupMode:setZoomIndex(idx)
	local maxIdx = self:getMaxZoomIndex()

	if pg.pawn and pg.pawn.isMoving then
		local minIdx = self.configData.minIndexInMove or 0

		self.currIndex = math.clamp(idx, minIdx, maxIdx)
	else
		self.currIndex = math.min(idx, maxIdx)
	end
end

function PlayerCameraGroupMode:getZoomIndexNum()
	local indexNum = self.indexNum or (self.configData or EMPTY_TABLE).indexNum or 20

	return math.max(1, indexNum)
end

function PlayerCameraGroupMode:getBaseZoomIndexNum()
	return math.max(1, (self.configData or EMPTY_TABLE).indexNum or 20)
end

function PlayerCameraGroupMode:canApplyGmMaxZoomIndex()
	if not ClientSwitch.EnableGmCameraMaxZoomIndex then
		return false
	end

	return self:getZoomIndexNum() == self:getBaseZoomIndexNum()
end

function PlayerCameraGroupMode:getMobileMaxZoomIndexReduce()
	if not pg.global or not pg.global.ui or not pg.global.ui:runPlatformByMobile() then
		return 0
	end

	return math.max(0, SysConfigData.cameraMaxZoomIndexReduceMobile or 0)
end

function PlayerCameraGroupMode:getMinZoomIndexLimit()
	return math.max(1, (self.configData or EMPTY_TABLE).minIndexInMove or 1)
end

function PlayerCameraGroupMode:getMaxZoomIndex()
	local indexNum = self:getZoomIndexNum()
	local maxIdx

	if self:canApplyGmMaxZoomIndex() then
		maxIdx = ClientSwitch.GmCameraMaxZoomIndex or indexNum
	else
		maxIdx = indexNum - self:getMobileMaxZoomIndexReduce()
	end

	maxIdx = math.clamp(maxIdx, self:getMinZoomIndexLimit(), indexNum)
	self.maxZoomIndex = maxIdx

	return maxIdx
end

function PlayerCameraGroupMode:getMaxZoomValue()
	return self:getMaxZoomIndex() * 1 / self:getZoomIndexNum()
end

function PlayerCameraGroupMode:refreshZoomLimit()
	self:zoomToValue(self.cameraMode.cameraZoom.targetZoomValue)
end

function PlayerCameraGroupMode:OnCameraZoom(deltaZoom)
	local extendZoomValue = false

	self.isInZooming = false

	if pg.global.ui:runPlatformByMobile() and deltaZoom then
		local zoomSpeed = 1 / self.indexNum
		local curZoom = self.cameraMode.cameraZoom.targetZoomValue

		curZoom = curZoom + deltaZoom * zoomSpeed

		self:zoomToValue(curZoom)
	else
		local currIdx = self.currIndex

		if deltaZoom > 0 then
			extendZoomValue = self.currIndex >= self:getMaxZoomIndex()
			currIdx = currIdx + 1
		else
			currIdx = currIdx - 1
		end

		self:setZoomIndex(currIdx)
		self:updateZoom()
	end

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_PHOTO) then
		extendZoomValue = false
	end

	if extendZoomValue then
		self.extendCount = self.extendCount or 0
		self.extendCount = self.extendCount + 1

		if not pg.global.ui:runPlatformByMobile() and not pg.game.input:isUsingGamepad() and pg.game.camera.cameraZoomContext == HotkeyConst.ZoomContext.Input and self.extendCount > 1 and pg.me and pg.me.space and pg.me.space:isHomeland() and pg.me.space:isSelfHomeland(pg.me) then
			self:setZoomIndex(0)
			pg.global.ui.homelandEditor:open()
		end
	else
		self.extendCount = 0
	end
end

function PlayerCameraGroupMode:checkFadeOutHud()
	return false
end

function PlayerCameraGroupMode:OnCameraZoomingIn(delta, minZoom)
	self.isInZooming = true
	self.curZoomingValue = self.cameraMode.cameraZoom.targetZoomValue
	self.curMinZooming = minZoom
	self.curMaxZooming = nil
	self.zoomingDelta = delta and -delta or -0.5
end

function PlayerCameraGroupMode:OnCameraZoomingOut(delta, maxZoom)
	self.isInZooming = true
	self.curZoomingValue = self.cameraMode.cameraZoom.targetZoomValue
	self.curMaxZooming = maxZoom
	self.curMinZooming = nil
	self.zoomingDelta = delta or 0.5
end

function PlayerCameraGroupMode:OnCameraCancelZooming()
	self.isInZooming = false
	self.zoomingDelta = 0
end

function PlayerCameraGroupMode:refreshCameraZooming()
	if self.isInZooming then
		self.curZoomingValue = self.curZoomingValue + self.zoomingDelta * Time.unscaledDeltaTime
		self.curZoomingValue = math.clamp(self.curZoomingValue, 0, 1)

		if self.curMaxZooming then
			self.curZoomingValue = math.min(self.curZoomingValue, self.curMaxZooming)
		end

		if self.curMinZooming then
			self.curZoomingValue = math.max(self.curZoomingValue, self.curMinZooming)
		end

		self:zoomToValue(self.curZoomingValue, nil, true)
	end
end

function PlayerCameraGroupMode:initBaseInfo()
	self:initCameraBase()
	self:resetRotateSpeed()
	self:resetCameraZoom(true)
	self:initSubCameraModes()
	self:initAxis()
	self:initModifiers()
	self:refreshMinMaxPitch()
end

function PlayerCameraGroupMode:initCameraBase()
	self.cameraMode.fieldOfView = self.configData.fieldOfView or 50
	self.cameraMode.followTarget.rotationSensitivity = Vector3(0.1, 0.1, 0.1)
end

function PlayerCameraGroupMode:resetRotateSpeed()
	local yawSpeed = self.configData.yawSpeed or 2.5
	local pitchSpeed = self.configData.pitchSpeed or 2.5
	local rate = ClientSettingUtils.get_cameraRotateRate()

	if self.configData.yawSpeedTable then
		yawSpeed = self.configData.yawSpeedTable[rate]
	end

	if self.configData.pitchSpeedTable then
		pitchSpeed = self.configData.pitchSpeedTable[rate]
	end

	self.cameraMode.cameraController.yawSpeed = yawSpeed
	self.cameraMode.cameraController.pitchSpeed = pitchSpeed
end

function PlayerCameraGroupMode:resetCameraZoom(resetDefaultZoom)
	local indexNum = 0

	if pg.me and pg.me.space and pg.me.space:isHomeland() then
		indexNum = 30
		self.cameraMode.cameraZoom.zoomDamp = 0.2
	else
		indexNum = math.max(1, self.configData.indexNum or 20)
		self.cameraMode.cameraZoom.zoomDamp = self.configData.zoomDamp or 0.3
	end

	local defaultIndex = self:getDefaultZoomIndex()

	if pg.me and pg.me.space and pg.me.space:isSupportPetMode() then
		local scale = 1 + SysConfigData.cameraIndexIncreaseRateIn13Mode

		indexNum = math.round(indexNum * scale)
		defaultIndex = math.round(defaultIndex * scale)
	end

	self.indexNum = indexNum

	if resetDefaultZoom then
		self:setZoomIndex(defaultIndex)
	end

	self.cameraMode.cameraZoom.defaultZoomValue = self.currIndex * 1 / self.indexNum

	self:updateZoom()

	if self.defaultCamera then
		self.defaultCamera:applyDistanceInfo()
	end
end

function PlayerCameraGroupMode:getAutoZoomRange()
	local autoZoomIndex = self:getDefaultZoomIndex()

	return autoZoomIndex * 1 / self.indexNum, autoZoomIndex * 1 / self.indexNum
end

function PlayerCameraGroupMode:getDefaultZoomIndex()
	if pg.me and pg.me.space and pg.me.space:isHomeland() then
		return 10
	end

	return self.configData.defaultIndex or 14
end

function PlayerCameraGroupMode:updateCurrZoomIndex()
	local ret, zoomIndex = self.cameraMode:TryGetCurrentZoomIndex(self.indexNum)

	if ret then
		self:setZoomIndex(zoomIndex)
	end

	if pg.pawn and pg.pawn.isMoving then
		local minIdx = self.configData.minIndexInMove or 0

		if minIdx > self.currIndex then
			self:OnCameraZoomingOut(nil, minIdx / self.indexNum)
		end
	end
end

function PlayerCameraGroupMode:updateZoom()
	local zoom = self.currIndex * 1 / self.indexNum

	self:zoomToValue(zoom)
end

function PlayerCameraGroupMode:setEnableCameraLookAt(enable)
	if pg.pawn and pg.pawn:hasEModelComponent(Const.COMPONENT_INDEX_IK) then
		local lookAtComponent = pg.pawn.eModel.ikLookAtComponent

		if lookAtComponent then
			lookAtComponent.enableCameraLookAt = enable
		end
	end
end

function PlayerCameraGroupMode:zoomToValue(zoomValue, force, isAutoZoom)
	if not isAutoZoom then
		self:OnCameraCancelZooming()
	end

	zoomValue = math.clamp(zoomValue, 0, self:getMaxZoomValue())

	self:setZoomIndex(math.round(zoomValue * self.indexNum))
	self.cameraMode.cameraZoom:ZoomTo(zoomValue, force or false)
	self:setEnableCameraLookAt(self.currIndex <= SysConfigData.lookatCameraDistanceIndex)
end

function PlayerCameraGroupMode:resetCameraDir()
	self.cameraMode:ResetControlDir()
end

function PlayerCameraGroupMode:resetCameraPlane()
	if pg.me then
		local cameraFarPlane = ClientUtils.getSceneFarPlane(pg.me.sceneId)

		if self.defaultCamera then
			self.defaultCamera:setFarPlane(cameraFarPlane)
		end
	end
end

function PlayerCameraGroupMode:resetCamera()
	self:resetCameraDir()
	self:resetCameraZoom(true)
	self:resetCameraPlane()
end

function PlayerCameraGroupMode:getRotation()
	return self.cameraMode:GetRotation()
end

function PlayerCameraGroupMode:getDir()
	return self.cameraMode:GetControlDir()
end

function PlayerCameraGroupMode:initSubCameraModes()
	self.defaultCamera = PlayerBaseCameraMode.new()

	self.defaultCamera:pushToParent(self, CameraConst.SUB_PRIORITY_PLAYER_BASE)

	self.defaultCamera.cameraMode.springArm.collideMinRadius = 0.02
	self.climbCamera = PlayerClimbCameraMode.new()

	self.climbCamera:pushToParent(self, CameraConst.SUB_PRIORITY_PLAYER_CLIMB)
	self.climbCamera:setActive(false)

	self.aimCamera = PlayerAimCameraMode.new()

	self.aimCamera:pushToParent(self, CameraConst.SUB_PRIORITY_PLAYER_AIM)
	self.aimCamera:setActive(false)

	self.catchCamera = PlayerCatchCameraMode.new()

	self.catchCamera:pushToParent(self, CameraConst.SUB_PRIORITY_PLAYER_CATCH)
	self.catchCamera:setActive(false, true)

	self.magnesisCamera = PlayerMagnesisCameraMode.new()

	self.magnesisCamera:pushToParent(self, CameraConst.SUB_PRIORITY_PLAYER_MAGNESIS)
	self.magnesisCamera:setActive(false)

	self.sneakCamera = PlayerSneakCameraMode.new()

	self.sneakCamera:pushToParent(self, CameraConst.SUB_PRIORITY_PLAYER_MAGNESIS)
	self.sneakCamera:setActive(false)

	self.flyCamera = PlayerFlyCameraMode.new()

	self.flyCamera:pushToParent(self, CameraConst.SUB_PRIORITY_PLAYER_FlY)
	self.flyCamera:setActive(false)

	self.localAnimCamera = PlayerAnimCameraMode.new()

	self.localAnimCamera:pushToParent(self, CameraConst.SUB_PRIORITY_PLAYER_ANIM)
	self.localAnimCamera:setActive(true)
	self.localAnimCamera:setAlignCamera(self.defaultCamera)

	self.faceToCamera = PlayerFaceToCameraMode.new()

	self.faceToCamera:pushToParent(self, CameraConst.SUB_PRIORITY_PLAYER_FACE_TO)
	self.faceToCamera:setActive(false)

	self.lockOnCamera = LockOnCameraMode()

	self.lockOnCamera:pushToParent(self, CameraConst.SUB_PRIORITY_PLAYER_LOCK_ON)

	self.thirdPersonLockOnCamera = ThirdPersonLockOnCameraMode.new()

	self.thirdPersonLockOnCamera:pushToParent(self, CameraConst.SUB_PRIORITY_PLAYER_LOCK_ON_THIRD_PERSON)

	self.lockOnExtendCamera = LockOnExtendCameraMode()

	self.lockOnExtendCamera:pushToParent(self, CameraConst.SUB_PRIORITY_PLAYER_LOCK_ON_EXTEND)
	self.lockOnExtendCamera:setActive(false)

	self.normalAttackLockOnCamera = NormalAttackLockOnCameraMode()

	self.normalAttackLockOnCamera:pushToParent(self, CameraConst.SUB_PRIORITY_PLAYER_NORMAL_ATTACK_LOCK_ON)
	self.normalAttackLockOnCamera:setActive(false)

	self.scrollCamera = PlayerScrollCameraMode.new()

	self.scrollCamera:pushToParent(self, CameraConst.SUB_PRIORITY_PLAYER_SCROLL)
	self.scrollCamera:setActive(false)

	self.ghostEyeCamera = PlayerGhostEyeCameraMode.new()

	self.ghostEyeCamera:pushToParent(self, CameraConst.SUB_PRIORITY_PLAYER_GHOST_EYE)
	self.ghostEyeCamera:setActive(false)

	self.peepCamera = PlayerPeepCameraMode.new()

	self.peepCamera:pushToParent(self, CameraConst.SUB_PRIORITY_PLAYER_PEEP)
	self.peepCamera:setActive(false)

	self.rideDragonBossCamera = PlayerRideDragonBossCameraMode.new()

	self.rideDragonBossCamera:pushToParent(self, CameraConst.SUB_PRIORITY_PLAYER_MAGNESIS)
	self.rideDragonBossCamera:setActive(false)

	self.paintAreaCamera = PlayerPaintAreaCameraMode.new()

	self.paintAreaCamera:pushToParent(self, CameraConst.SUB_PRIORITY_PLAYER_PAINT_AREA)
	self.paintAreaCamera:setActive(false)

	self.grabEggUdCamera = PlayerGrabEggUndergroundPalaceCameraMode.new()

	self.grabEggUdCamera:pushToParent(self, CameraConst.SUB_PRIORITY_PLAYER_BASE)
	self.grabEggUdCamera:setActive(false)

	self.eggCarriedCamera = PlayerEggCarriedCameraMode.new()

	self.eggCarriedCamera:pushToParent(self, CameraConst.SUB_PRIORITY_PLAYER_EGG_CARRIED)
	self.eggCarriedCamera:setActive(false)

	self.afkCamera = PlayerAfkCameraMode.new()

	self.afkCamera:pushToParent(self, CameraConst.SUB_PRIORITY_PLAYER_AFK)
	self.afkCamera:setActive(false)

	self.homelandPetCamera = PlayerHomelandPetCameraMode.new()

	self.homelandPetCamera:pushToParent(self, CameraConst.SUB_PRIORITY_PLAYER_HOMELAND_PET)
	self.homelandPetCamera:setActive(false)
	self:refreshCameraState()
end

function PlayerCameraGroupMode:getBaseCameraDistance()
	local cameraView = self.defaultCamera.cameraMode:GetCameraView()

	return cameraView:GetArmLen()
end

function PlayerCameraGroupMode:initAxis()
	self.cameraMode.yawAxisHelper.axisRecenter.enable = false
	self.cameraMode.yawAxisHelper.axisRecenter.blendWaitTime = 1
	self.cameraMode.yawAxisHelper.axisRecenter.interpolator.dampTime = 2
	self.cameraMode.defaultYaw = 0
	self.cameraMode.pitchAxisHelper.axisRecenter.enable = false
	self.cameraMode.pitchAxisHelper.axisRecenter.blendWaitTime = self.configData.blendWaitTime or 1
	self.cameraMode.pitchAxisHelper.axisRecenter.interpolator.dampTime = self.configData.dampTime or 2
	self.cameraMode.defaultPitch = self.configData.recenterTarget or 6
	self.cameraMode.groundScaner.maxAngle = 30
	self.cameraMode.groundScaner.minAngle = -20
	self.cameraMode.groundScaner.rayNum = 4
	self.cameraMode.groundScaner.edgeDetectLength = 4
end

function PlayerCameraGroupMode:initModifiers()
	local cinemachineImpulseModifier = CinemachineImpulseModifier()

	self:addCameraModifier(cinemachineImpulseModifier, 10)

	local cameraShakeModifier = CameraShakeModifier()

	self:addCameraModifier(cameraShakeModifier, 11)

	self.commonModifier = CameraCommonModifier()

	self:addCameraModifier(self.commonModifier, 12)

	self.fovCurveModifier = CameraFovCurveModifier()

	self:addCameraModifier(self.fovCurveModifier, 13)

	self.fovModifier = CameraFovModifier()

	self:addCameraModifier(self.fovModifier, 14)
end

function PlayerCameraGroupMode:zoomIn()
	self.cameraMode:ZoomIn()
end

function PlayerCameraGroupMode:zoomOut()
	self.cameraMode:ZoomOut()
end

function PlayerCameraGroupMode:setInputEnable(enable)
	self.cameraMode.enableInput = enable
	self.enableInputTime = 0
end

function PlayerCameraGroupMode:setTarget(transform, blendTime)
	if NotNil(self.targetTrans) and self.targetTrans == transform then
		return
	end

	self.targetTrans = transform
	blendTime = blendTime or 0

	self.cameraMode.followTarget:SetTransformTarget(transform, blendTime)
end

function PlayerCameraGroupMode:setTargetByActorId(actorId, blendTime)
	local transform = CSEntityManager:GetPositionAgentByActorId(actorId)

	self:setTarget(transform, blendTime)
end

function PlayerCameraGroupMode:setPhysxTarget(transform, blendTime)
	if NotNil(self.targetTrans) and self.targetTrans == transform then
		return
	end

	self.targetTrans = transform
	blendTime = blendTime or 0

	self.cameraMode.followTarget:SetPhysxTarget(transform, blendTime)
end

function PlayerCameraGroupMode:setPhysxTargetByActorId(actorId, blendTime)
	local transform = CSEntityManager:GetPositionAgentByActorId(actorId)

	self:setPhysxTarget(transform, blendTime)
end

function PlayerCameraGroupMode:setTargetPlayer(player, blendTime)
	local oldPlayer = self.targetPlayer
	local targetChange = oldPlayer ~= player

	if targetChange then
		self:setEnableCameraHitCheck(true)
	end

	self.targetPlayer = player

	if player and player.eModel then
		if player.isPhysxPlayer then
			self:setPhysxTargetByActorId(player.actorId, blendTime)
		else
			self:setTargetByActorId(player.actorId, blendTime)
		end

		local nearHeight, farHeight, shoulderHeight = player:getCameraHeightInfo()

		self:setTargetHeight(nearHeight, farHeight, shoulderHeight)
	else
		self:setTarget(nil, blendTime)
	end

	if targetChange then
		self.defaultCamera:onTargetChange(oldPlayer)
		self:cancelFovCurveAnim()
		self:cancelPitchYawCurveAnim()
	end
end

function PlayerCameraGroupMode:refreshTargetPlayer()
	local player = self.targetPlayer

	if player and player.eModel then
		local nearHeight, farHeight, shoulderHeight = player:getCameraHeightInfo()

		if self.inAfk then
			local afkCameraNearHeight = player:getConfigData().afkCameraNearHeight

			if afkCameraNearHeight then
				nearHeight = afkCameraNearHeight
				farHeight = nearHeight
			end
		end

		self:setTargetHeight(nearHeight, farHeight, shoulderHeight)

		if self.inAfk then
			self.afkCamera:applyAfkDistanceInfo(true)
		else
			self.defaultCamera:applyDistanceInfo()
		end
	end
end

function PlayerCameraGroupMode:refreshCrouchHeight()
	local player = self.targetPlayer

	if player and player.eModel then
		local nearHeight, farHeight = player:getCrouchCameraHeightInfo()

		self:setTargetHeight(nearHeight, farHeight)
	end
end

function PlayerCameraGroupMode:setTargetHeight(nearHeight, farHeight, shoulderHeight)
	self.cameraMode.eyeHeight = nearHeight
	self.cameraMode.halfHeight = farHeight

	self.aimCamera:setTargetHeight(nearHeight, farHeight)
	self.grabEggUdCamera:setTargetHeight(nearHeight, farHeight, shoulderHeight)
end

function PlayerCameraGroupMode:getCameraPriority()
	return CameraConst.PRIORITY_PLAYER
end

function PlayerCameraGroupMode:tick()
	if not self.cameraMode then
		return
	end

	self:refreshCameraZooming()
	self:updateCurrZoomIndex()
	self:refreshCameraState()
	self:refreshCombatState()
	self:checkCameraFaceTo()
	self:checkCameraDistanceScale()
	self:checkEnableInput()
	self:refreshRecenterArea()

	if self.defaultCamera then
		self.defaultCamera:tick()
	end
end

function PlayerCameraGroupMode:getCameraDirToPlayerDirAngle()
	Vector3.enableCreateFromCache()

	local cameraDir = self:getRotation() * Vector3.forward
	local playerDir = pg.me:getForward()
	local result = ClientUtils.calVectorAngle(cameraDir.x, 0, cameraDir.z, playerDir.x, 0, playerDir.z)

	Vector3.disableCreateFromCache()

	return result
end

function PlayerCameraGroupMode:refreshPlayerLight()
	if pg.me then
		if not Utils.isSceneWorld() then
			pg.me.eModel.modelModelView:SetLightIntensity(0)

			return
		end

		local cameraDir = self:getRotation() * Vector3.forward
		local playerDir = pg.me:getForward()
		local angle = ClientUtils.calVectorAngle(cameraDir.x, 0, cameraDir.z, playerDir.x, 0, playerDir.z)
		local zoom = self.cameraMode.cameraZoom.zoomValue

		if zoom > self.minLightZoomValue or angle < self.minLightAngleValue then
			pg.me.eModel.modelModelView:SetLightIntensity(0)
		elseif zoom > self.maxLightZoomValue and zoom <= self.minLightZoomValue then
			local angleEffect = math.min(1, (angle - self.minLightAngleValue) * self.lightAngleRate)
			local zoomEffect = math.min(1, (self.minLightZoomValue - zoom) * self.lightZoomRate)

			pg.me.eModel.modelModelView:SetLightIntensity(math.max(zoomEffect * angleEffect, 0.1))
		else
			local angleEffect = math.min(1, (angle - self.minLightAngleValue) * self.lightAngleRate)

			pg.me.eModel.modelModelView:SetLightIntensity(1 * angleEffect)
		end
	end
end

function PlayerCameraGroupMode:refreshCameraState()
	if self.targetPlayer == nil or self.targetPlayer.isDestroyed then
		return
	end

	local p = self.targetPlayer

	self:updateTargetCharacterState()
	self.catchCamera:update(p)
end

function PlayerCameraGroupMode:refreshMinMaxPitch()
	if not self.cameraMode then
		return
	end

	if self.isInAim then
		local minPitch, maxPitch = self.aimCamera:getMinMaxPitch()

		self.cameraMode.cameraController.minPitch = minPitch
		self.cameraMode.cameraController.maxPitch = maxPitch
	elseif self.catchCamera:isActive() then
		self.cameraMode.cameraController.minPitch = -50
		self.cameraMode.cameraController.maxPitch = 60
	elseif self.magnesisCamera:isActive() then
		local minPitch, maxPitch = self.magnesisCamera:getMinMaxPitch()

		self.cameraMode.cameraController.minPitch = minPitch
		self.cameraMode.cameraController.maxPitch = maxPitch
	else
		self.cameraMode.cameraController.minPitch = -80
		self.cameraMode.cameraController.maxPitch = 80
	end
end

function PlayerCameraGroupMode:updateTargetCharacterState()
	if not self.enableAutoZoomAndRecenter then
		return
	end

	local enableRecenter = false
	local doSmoothZoom = false

	if pg.me and pg.me.space and pg.me.space:isHomeland() then
		enableRecenter = false
		doSmoothZoom = false
	elseif self.targetPlayer and self.defaultCamera:isTop() then
		local characterState = self.targetPlayer.characterState

		if CharacterStateConst.isChildOfState(characterState, CharacterStateConst.DASH) or CharacterStateConst.isChildOfState(characterState, CharacterStateConst.SPRINT) or CharacterStateConst.isChildOfState(characterState, CharacterStateConst.WALK) or CharacterStateConst.isChildOfState(characterState, CharacterStateConst.RUN) then
			enableRecenter = true

			if self:isInCombat() then
				-- block empty
			else
				doSmoothZoom = true

				local minZoom, maxZoom = self:getAutoZoomRange()

				self:setAutoZoom(minZoom, maxZoom)
			end
		end
	end

	if enableRecenter then
		self:setPitchRecenterInfo(CameraConst.PlayerCameraRecenterReason.CharacterState, CameraConst.DefaultRecenterData)
	else
		self:setPitchRecenterInfo(CameraConst.PlayerCameraRecenterReason.CharacterState, nil)
	end

	self.cameraMode.cameraZoom:SetEnableAutoZoom(doSmoothZoom)
end

function PlayerCameraGroupMode:setEnableAutoZoomAndRecenter(enabled)
	self.enableAutoZoomAndRecenter = enabled

	self.cameraMode.cameraZoom:SetEnableAutoZoom(enabled)
end

function PlayerCameraGroupMode:canAutoZoom()
	return self.enabledAutoZoom
end

function PlayerCameraGroupMode:onPlayerStateChange()
	self.defaultCamera:onPlayerStateChange()

	local characterState = self.targetPlayer and self.targetPlayer.characterState or nil
	local isFlying = characterState and CharacterStateConst.isChildOfState(characterState, CharacterStateConst.FLYING) or false

	if self.isFlying ~= isFlying then
		self.isFlying = isFlying

		self:refreshCameraDistanceScale()
	end

	if self.climbCamera then
		self.climbCamera:setActive(isClimbCameraState(self, characterState))
	end
end

function PlayerCameraGroupMode:onPlayerBaseLayerTagChange()
	self:onPlayerStateChange()
end

function PlayerCameraGroupMode:isInCombat()
	local me = pg.me

	return me and me:isInCombat()
end

function PlayerCameraGroupMode:onCameraEvent(params)
	local eventName = params[1]

	if eventName == "ChangeFov" then
		local fov = tonumber(params[2])
		local blendTime = tonumber(params[3] or 2)

		self:blendToFov(fov, blendTime)

		return true, "ResetFov"
	elseif eventName == "ResetFov" then
		local blendTime = tonumber(params[2] or 2)

		self:cancelFovBlend(blendTime)

		return false, "ResetFov"
	elseif eventName == "SetDamp" then
		local overrideDampInfo = {
			tonumber(params[2]),
			tonumber(params[3]),
			tonumber(params[4])
		}

		self.defaultCamera:setCameraDampOverride(overrideDampInfo)

		return true, "ResetDamp"
	elseif eventName == "ResetDamp" then
		local resetDampDuration = tonumber(params[2]) or 1

		self.defaultCamera:setCameraDampOverride(nil, resetDampDuration)

		return false, "ResetDamp"
	elseif eventName == "SetZoom" then
		local minZoom = tonumber(params[2])
		local maxZoom = tonumber(params[3])
		local dampTime = tonumber(params[4]) or 1

		self:setZoom(minZoom, maxZoom, dampTime)

		return false
	end
end

function PlayerCameraGroupMode:setAutoZoom(minZoom, maxZoom, damptime, waitTime)
	damptime = damptime or 4
	waitTime = waitTime or 2

	self.cameraMode.cameraZoom:SetAutoZoom(minZoom, maxZoom, damptime, waitTime)
end

function PlayerCameraGroupMode:setPitchRecenterInfo(reason, recenterInfo, forceRefresh)
	reason = reason or CameraConst.PlayerCameraRecenterReason.Default

	if forceRefresh or self.pitchRecenterInfo[reason] ~= recenterInfo then
		self.pitchRecenterInfo[reason] = recenterInfo

		self:refreshCameraPitchRecenter()
	end
end

function PlayerCameraGroupMode:refreshCameraPitchRecenter()
	local recenterInfo

	for i = CameraConst.PlayerCameraRecenterReason.Max, 1, -1 do
		recenterInfo = self.pitchRecenterInfo[i]

		if recenterInfo then
			break
		end
	end

	if recenterInfo then
		self.cameraMode.recenterPitch = recenterInfo.targetValue or self.configData.recenterTarget or 6
		self.cameraMode.pitchAxisHelper.axisRecenter.blendWaitTime = recenterInfo.blendWaitTime or self.configData.blendWaitTime or 1
		self.cameraMode.pitchAxisHelper.axisRecenter.interpolator.dampTime = recenterInfo.dampTime or self.configData.dampTime or 2
		self.cameraMode.pitchAxisHelper.axisRecenter.enable = true

		if recenterInfo.enableGroundScan then
			self:setEnableGroundScan(true)
		else
			self:setEnableGroundScan(false)
		end
	else
		self.cameraMode.pitchAxisHelper.axisRecenter.enable = false

		self:setEnableGroundScan(false)
	end
end

function PlayerCameraGroupMode:setYawRecenterInfo(reason, recenterInfo, forceRefresh)
	reason = reason or CameraConst.PlayerCameraRecenterReason.Default

	if forceRefresh or self.yawRecenterInfo[reason] ~= recenterInfo then
		self.yawRecenterInfo[reason] = recenterInfo

		self:refreshCameraYawRecenter()
	end
end

function PlayerCameraGroupMode:refreshCameraYawRecenter()
	local recenterInfo

	for i = CameraConst.PlayerCameraRecenterReason.Max, 1, -1 do
		recenterInfo = self.yawRecenterInfo[i]

		if recenterInfo then
			break
		end
	end

	if recenterInfo then
		self.cameraMode.recenterYaw = recenterInfo.targetValue or 0
		self.cameraMode.yawAxisHelper.axisRecenter.blendWaitTime = recenterInfo.blendWaitTime or self.configData.blendWaitTime or 1
		self.cameraMode.yawAxisHelper.axisRecenter.interpolator.dampTime = recenterInfo.dampTime or 1
		self.cameraMode.yawAxisHelper.axisRecenter.enable = true
	else
		self.cameraMode.yawAxisHelper.axisRecenter.enable = false
	end
end

function PlayerCameraGroupMode:refreshRecenterArea()
	if not self.lastRefreshRecenterAreaTime or Time.realSecondCache - self.lastRefreshRecenterAreaTime > 0.2 then
		self.lastRefreshRecenterAreaTime = Time.realSecondCache

		local centerInfo = pg.global.cameraMgr:QueryCameraRecenterInfo()

		if centerInfo then
			self.recenterAreaValid = true
			self.recenterAreaPitchInfo.targetValue = centerInfo.pitch
			self.recenterAreaYawInfo.targetValue = centerInfo.yaw
			self.recenterAreaYawInfo.dampTime = SysConfigData.recenterYawDampTime or 0.3
			self.recenterAreaPitchInfo.dampTime = SysConfigData.recenterPitchDampTime or 0.4
		else
			self.recenterAreaValid = false
		end
	end

	local enableRecenter = false

	if self.targetPlayer and self.defaultCamera:isTop() then
		enableRecenter = self.recenterAreaValid
	end

	if enableRecenter then
		self:setPitchRecenterInfo(CameraConst.PlayerCameraRecenterReason.RecenterArea, self.recenterAreaPitchInfo, true)
		self:setYawRecenterInfo(CameraConst.PlayerCameraRecenterReason.RecenterArea, self.recenterAreaYawInfo, true)
	else
		self:setPitchRecenterInfo(CameraConst.PlayerCameraRecenterReason.RecenterArea, nil)
		self:setYawRecenterInfo(CameraConst.PlayerCameraRecenterReason.RecenterArea, nil)
	end
end

function PlayerCameraGroupMode:setInAim(isInAim, aimParam, alwaysLookForward)
	if isInAim then
		self:interruptNormalAttackLockOnCamera()
	end

	self.isInAim = isInAim
	aimParam = aimParam or {}

	if isInAim then
		self.aimCamera:setCameraParam(aimParam)
	end

	self.aimCamera:setActive(self.isInAim)

	if isInAim then
		self:setEnableCameraHitCheck(not aimParam.disableCameraHitCheck)
	else
		self:setEnableCameraHitCheck(true)
	end

	self:refreshMinMaxPitch()

	if alwaysLookForward ~= nil then
		pg.pawn.eModel.AlwaysLookForward = alwaysLookForward
	else
		pg.pawn.eModel.AlwaysLookForward = self.isInAim
	end

	if not isInAim then
		pg.pawn.eModel.AlwaysLookScreenCenter = false

		local lockHelper = pg.game.controller and pg.game.controller.lockHelper

		if lockHelper and lockHelper.isUseLockOnExtendCamera and ToBool(lockHelper.forceLockActorId) then
			local targetEnt = pg.getEntityByActorId(lockHelper.forceLockActorId)

			if targetEnt then
				self:setLockOnCameraTarget(targetEnt, lockHelper.forceLockPartId)
			end
		end
	end
end

function PlayerCameraGroupMode:setLockOnCameraTarget(targetEnt, partId)
	if targetEnt and ToBool(pg.game.controller.lockHelper.forceLockActorId) then
		self.normalAttackLockOnCamera:deactivate()
	end

	self.lockOnExtendCamera.cameraMode.isForceLockTarget = pg.game.controller.lockHelper.isUseLockOnCamera
	partId = partId or 0

	if targetEnt then
		local player = pg.me

		self.lockOnExtendCamera.cameraMode.lookOffset = Vector3(0, player.eModel.height * 0.5, 0)

		self.lockOnExtendCamera.cameraMode:SetFollowByActorId(pg.me.actorId)

		if targetEnt.eModel and targetEnt.eModel:CheckPositionAgent() then
			self.lockOnExtendCamera.cameraMode:SetLockTargetByActorId(targetEnt.actorId, targetEnt.eModel.height)
			self.lockOnExtendCamera:setActive(true)
		elseif self.lockOnExtendCamera:isActive() then
			self.lockOnExtendCamera:setActive(false)
		end
	elseif self.lockOnExtendCamera:isActive() then
		self.lockOnExtendCamera:setActive(false)
	end
end

function PlayerCameraGroupMode:onNormalAttackStart(targetEnt)
	local abilityMgr = pg.global.abilityMgr

	if self.isInAim or abilityMgr and abilityMgr.isPlayingCutScene or pg.game.camera:isCameraAnimActive() then
		self:interruptNormalAttackLockOnCamera()

		return
	end

	local lockHelper = pg.game.controller.lockHelper

	if ToBool(lockHelper.forceLockActorId) or not pg.game.setting:getAutoCameraWhenNoLock() then
		self.normalAttackLockOnCamera:deactivate()

		return
	end

	self.normalAttackLockOnCamera:activateForTarget(targetEnt)
end

function PlayerCameraGroupMode:interruptNormalAttackLockOnCamera()
	if self.normalAttackLockOnCamera then
		self.normalAttackLockOnCamera:deactivate(0)
	end
end

function PlayerCameraGroupMode:onMouseViewInput(mouseDelta)
	if mouseDelta.x == 0 and mouseDelta.y == 0 then
		return
	end

	local normalAttackCamera = self.normalAttackLockOnCamera

	if normalAttackCamera and normalAttackCamera:isActive() then
		if normalAttackCamera:shouldExitOnMouseInput(mouseDelta) then
			self:onManualViewInput()
		end

		return
	end

	self:onManualViewInput()
end

function PlayerCameraGroupMode:onManualViewInput()
	self.normalAttackLockOnCamera:interruptByManualInput()
end

function PlayerCameraGroupMode:onMoveInput(x, y)
	if (x ~= 0 or y ~= 0) and self.normalAttackLockOnCamera:isActive() then
		self.normalAttackLockOnCamera:deactivate()
	end
end

function PlayerCameraGroupMode:testLockOn()
	local obj = GameObject.CreatePrimitive(3)

	obj.name = "lockOnCube"

	local _px, _py, _pz = pg.me.eModel:GetPositionAgentPosEx()
	local _fx, _fy, _fz = pg.me.eModel:GetPositionAgentAxisEx(2)

	obj.transform.position = Vector3.New(_px + _fx * 3, _py + _fy * 3, _pz + _fz * 3)
	self.lockOnExtendCamera.cameraMode.lookOffset = Vector3(0, 0.5, 0)

	self.lockOnExtendCamera.cameraMode:SetFollowByActorId(pg.me.actorId)
	self.lockOnExtendCamera.cameraMode:SetLockTarget(obj)
	self.lockOnExtendCamera:setActive(true)
end

function PlayerCameraGroupMode:setPeepCameraArgs(fieldOfView, minPitch, maxPitch, minYaw, maxYaw, targetPos, targetRot)
	self.peepCamera:setCameraParams(fieldOfView, minPitch, maxPitch, minYaw, maxYaw, targetPos, targetRot)
end

function PlayerCameraGroupMode:enablePeep(enable)
	self.peepCamera:setActive(enable)
	self:setEnableCameraHitCheck(not enable)
	self:refreshCameraState()
	self:refreshMinMaxPitch()
end

function PlayerCameraGroupMode:enableHomelandPetCamera(enable, actorId)
	if enable and not self.homelandPetCamera:setPetTarget(actorId) then
		return false
	end

	self.homelandPetCamera:setActive(enable)

	return true
end

function PlayerCameraGroupMode:enableCatch(enable)
	self.catchCamera:setActive(enable)
	self.flyCamera:onCatchEnable(enable)
	self:setEnableCameraHitCheck(true)
	self:refreshCameraState()
	self:refreshMinMaxPitch()
end

function PlayerCameraGroupMode:enablePaintArea(enable)
	self.paintAreaCamera:setActive(enable)
	self:setEnableCameraHitCheck(not enable)
	self:refreshCameraState()
	self:refreshMinMaxPitch()
end

function PlayerCameraGroupMode:setPaintAreaCameraArgs(fieldOfView, targetArmLength, blendTime)
	self.paintAreaCamera:setCameraParams(fieldOfView, targetArmLength, blendTime)
end

function PlayerCameraGroupMode:enableMagnesisCameraMode(enable)
	self.magnesisCamera:setActive(enable)
	self:setEnableCameraHitCheck(true)
	self:refreshCameraState()
	self:refreshMinMaxPitch()
end

function PlayerCameraGroupMode:enableSneakCameraMode(enable)
	if self.sneakCamera.cameraMode.isActive == enable then
		return
	end

	self.sneakCamera:setActive(enable)

	if enable then
		self.sneakCamera:fromCamera(self.defaultCamera.cameraMode)
	end

	self:refreshCameraState()
	self:refreshMinMaxPitch()
end

function PlayerCameraGroupMode:enableScroll(enable)
	self.scrollCamera:enableScrollCameraMode(enable)
	self:setEnableCameraHitCheck(not enable)
	self:refreshCameraState()
	self:refreshMinMaxPitch()
end

function PlayerCameraGroupMode:enableGhostEye(enable)
	self.ghostEyeCamera:setActive(enable)
	self:refreshCameraState()
	self:refreshMinMaxPitch()
end

function PlayerCameraGroupMode:enableRideDragonBossCameraMode(enable)
	self.rideDragonBossCamera:setActive(enable)
	self:setEnableCameraHitCheck(not enable)
	self:refreshCameraState()
	self:refreshMinMaxPitch()
end

function PlayerCameraGroupMode:enableGrabEggUdCameraMode(enable)
	self.grabEggUdCamera:setActive(enable)
	self:setEnableCameraHitCheck(not enable)
	self:refreshCameraState()
	self:refreshMinMaxPitch()
end

function PlayerCameraGroupMode:enableEggCarriedCameraMode(enable, followTransform)
	if enable then
		self.eggCarriedCamera:setFollowTarget(followTransform)
	else
		self.eggCarriedCamera:setFollowTarget(nil)
	end

	self.eggCarriedCamera:setActive(enable)
	self:setEnableCameraHitCheck(not enable)
	self:refreshCameraState()
	self:refreshMinMaxPitch()
end

function PlayerCameraGroupMode:setEnableCameraHitCheck(enable)
	if not self.targetPlayer then
		return
	end

	local eModel = self.targetPlayer.eModel

	if not eModel then
		return
	end

	eModel.enableCameraHitCheck = enable
end

function PlayerCameraGroupMode:middleView()
	self.cameraMode:BlendToCenter(1)
end

function PlayerCameraGroupMode:doClimbRecenter()
	self.cameraMode:BlendToLocal(0, 0, 0.7, true, 2)
end

function PlayerCameraGroupMode:refreshCombatState()
	local p = self.targetPlayer

	if p == nil then
		return
	end

	local isInCombat = self:isInCombat()

	if isInCombat ~= self.lastInCombat then
		self.lastInCombat = isInCombat

		self:onCombatStageChange()
	end
end

function PlayerCameraGroupMode:onCombatStageChange()
	self:refreshCameraDistanceScale()
end

function PlayerCameraGroupMode:overrideCameraDistanceScale(distanceScale, maxTime)
	self.overrideDistanceScale = distanceScale

	if maxTime then
		self.overrideDistanceScaleEndTime = Time.realSecondCache + maxTime
	else
		self.overrideDistanceScaleEndTime = nil
	end

	self:refreshCameraDistanceScale()
end

function PlayerCameraGroupMode:resetCameraDistanceScale()
	self.overrideDistanceScale = nil
	self.overrideDistanceScaleEndTime = nil

	self:refreshCameraDistanceScale()
end

function PlayerCameraGroupMode:checkCameraDistanceScale()
	if self.overrideDistanceScale and self.overrideDistanceScaleEndTime and self.overrideDistanceScaleEndTime < Time.realSecondCache then
		self:resetCameraDistanceScale()
	end
end

function PlayerCameraGroupMode:getGmDistanceScaleFactor()
	if not ClientSwitch.EnableGmCameraDistanceScale then
		return 1
	end

	return ClientSwitch.GmCameraDistanceScale or 1
end

function PlayerCameraGroupMode:refreshCameraDistanceScale()
	local baseScale = 1

	if self.overrideDistanceScale then
		baseScale = self.overrideDistanceScale
	elseif self:isInCombat() or self.isFlying then
		baseScale = CameraConst.CAMERA_ARM_LENGTH_SCALE_IN_COMBAT
	end

	local targetDistanceScale = baseScale * self:getGmDistanceScaleFactor()
	local curScale = self.cameraMode:GetTargetDistanceScale()

	if math.abs(curScale - targetDistanceScale) > 0.01 then
		self:OnCameraCancelZooming()

		if baseScale ~= 1 then
			self.cameraMode:SetTargetDistanceScale(targetDistanceScale, 2)
			self.cameraMode.cameraZoom:SetBlendTo(self:getMaxZoomValue(), CameraConst.CAMERA_DAMP_INTO_COMBAT)
		else
			self.cameraMode:SetTargetDistanceScale(targetDistanceScale, 4)
			self.cameraMode.cameraZoom:CancelBlend()
		end
	end
end

function PlayerCameraGroupMode:onLockEnemy(ent)
	if ent == nil then
		return
	end

	local p = self.targetPlayer
	local checkDis = 4
	local now = Time.realSecondCache * 1000
	local inputInterval = 1.5
	local recenterInterval = 2

	if now - self.lastAdjustEnemyTime > recenterInterval * 1000 then
		local position = ent:getPosition()

		if not (checkDis > utils.squareDist(position, p:getPosition())) then
			return
		end

		local entPos = Vector3(position[1], position[2], position[3])
		local noInputTime = self.cameraMode.noInputTotalTime

		if inputInterval < noInputTime then
			self.cameraMode:AutoFaceToNearTarget(entPos, 6, 50, 25, 15, 10)

			self.lastAdjustEnemyTime = now
		end
	end
end

function PlayerCameraGroupMode:setEnableGroundScan(enable)
	self.cameraMode.groundScaner.enable = enable
end

function PlayerCameraGroupMode:setZoom(minZoom, maxZoom, dampValue)
	local targetZoom = self.cameraMode.cameraZoom.zoomValue
	local needSet = false

	if targetZoom < minZoom then
		targetZoom = minZoom
		needSet = true
	end

	if maxZoom < targetZoom then
		targetZoom = maxZoom
		needSet = true
	end

	if needSet then
		self.cameraMode.cameraZoom:SetBlendTo(targetZoom, dampValue)
	end
end

function PlayerCameraGroupMode:focusTo(targetPos, yOffset)
	yOffset = yOffset or 2

	self.cameraMode:FocusTo(targetPos, yOffset, 0.5)
end

function PlayerCameraGroupMode:checkCameraFaceTo()
	if self.faceToEndTime > 0 then
		local now = Time.realSecondCache

		if now > self.faceToEndTime then
			self:cancelFaceToTarget()

			self.faceToEndTime = 0
		end
	end
end

function PlayerCameraGroupMode:FaceToTarget(targetPos, heightDelta, maxLockTime)
	maxLockTime = maxLockTime or 10

	local now = Time.realSecondCache

	self.faceToEndTime = now + maxLockTime

	self.faceToCamera:setTargetPosition(targetPos, heightDelta)
	self.faceToCamera:setActive(true)
end

function PlayerCameraGroupMode:FaceToTargetTransform(targetTrans, heightDelta, maxLockTime, shoulder)
	maxLockTime = maxLockTime or 10

	local now = Time.realSecondCache

	self.faceToEndTime = now + maxLockTime

	self.faceToCamera:setTargetTransform(targetTrans, heightDelta, shoulder)
	self.faceToCamera:setActive(true)
end

function PlayerCameraGroupMode:FaceToTargetTransformByActorId(actorId, heightDelta, maxLockTime, shoulder)
	local targetTrans = CSEntityManager:GetPositionAgentByActorId(actorId)

	self:FaceToTargetTransform(targetTrans, heightDelta, maxLockTime, shoulder)
end

function PlayerCameraGroupMode:faceToTargetTransfomWithTargetShoulder(targetTrans, heightDelta, maxLockTime, targetShoulder, transitionSpeed, rotSpeedCurve, resetOnFinish)
	maxLockTime = maxLockTime or 10

	local now = Time.realSecondCache

	self.faceToEndTime = now + maxLockTime
	self.faceToCamera.resetOnFinish = resetOnFinish

	self.faceToCamera:setTargetTransformWithTargetShoulder(targetTrans, heightDelta, targetShoulder, transitionSpeed, rotSpeedCurve)
	self.faceToCamera:setActive(true)
end

function PlayerCameraGroupMode:cancelFaceToTarget()
	if self.faceToCamera:isActive() then
		self.faceToCamera:setActive(false)
		self.faceToCamera:cancelFaceToTarget()

		if self.faceToCamera.resetOnFinish == nil or self.faceToCamera.resetOnFinish then
			self.cameraMode:ResetAxisHelpers()
			self.cameraMode:BlendToPitch(self.cameraMode.groundAngle + self.cameraMode.defaultPitch, 0)
		end
	end

	self.faceToEndTime = 0
end

function PlayerCameraGroupMode:lockOnTargetThirdPerson(targetEnt, shoulder, pitch)
	self.thirdPersonLockOnCamera:setLockEnt(targetEnt, shoulder, pitch)
end

function PlayerCameraGroupMode:tempBlockInput(blockInputTime)
	self:setInputEnable(false)

	local now = Time.realSecondCache * 1000

	self.enableInputTime = now + blockInputTime * 1000
end

function PlayerCameraGroupMode:checkEnableInput()
	local now = Time.realSecondCache * 1000

	if self.enableInputTime ~= 0 and now > self.enableInputTime then
		self:setInputEnable(true)
	end
end

function PlayerCameraGroupMode:playPitchYawCurveAnim(blendInTime, duration, pitchCurve, yawCurve)
	self.cameraMode:PlayPitchCurveAnim(pitchCurve, blendInTime, duration)
	self.cameraMode:PlayYawCurveAnim(yawCurve, blendInTime, duration)
end

function PlayerCameraGroupMode:cancelPitchYawCurveAnim()
	self.cameraMode:CancelPitchCurveAnim()
	self.cameraMode:CancelYawCurveAnim()
end

function PlayerCameraGroupMode:setYawSpeedAndPitchSpeedRatio(yawSpeedRatio, pitchSpeedRatio)
	self.cameraMode.cameraController.yawSpeedRatio = yawSpeedRatio or 1
	self.cameraMode.cameraController.pitchSpeedRatio = pitchSpeedRatio or 1
end

function PlayerCameraGroupMode:resetSpeedAndPitchSpeedRatio()
	self.cameraMode.cameraController.yawSpeedRatio = 1
	self.cameraMode.cameraController.pitchSpeedRatio = 1
end

function PlayerCameraGroupMode:setPlayerCameraTargetShoulder(targetShoulder, transitionSpeed)
	self.defaultCamera:setTargetShoulder(targetShoulder, transitionSpeed)
end

function PlayerCameraGroupMode:playFovCurveAnim(fovCurve, blendInTime, duration, blendOutTime, forbidFovCameraOnRepeat)
	self.fovCurveModifier:StartPlayCurveAnim(fovCurve, blendInTime, duration, blendOutTime, forbidFovCameraOnRepeat == 1)
end

function PlayerCameraGroupMode:cancelFovCurveAnim()
	self.fovCurveModifier:CancelAnim()
end

function PlayerCameraGroupMode:startFadeCurveAnim(targetWeight, fadeTime)
	self.fovCurveModifier:StartFadeAnim(targetWeight, fadeTime)
end

function PlayerCameraGroupMode:blendToPitch(targetPitch, dampTime)
	self.cameraMode:BlendToPitch(targetPitch, dampTime, false, dampTime)
end

function PlayerCameraGroupMode:setLockOnCameraExtraYAngle(extraAngle, keepTime)
	self.lockOnExtendCamera:setTargetExtraAngle(extraAngle, keepTime)
end

function PlayerCameraGroupMode:resetLockOnCameraExtraYAngle()
	self.lockOnExtendCamera:resetTargetExtraAngle()
end

function PlayerCameraGroupMode:checkInAfk()
	return self.inAfk or self.isExitingAfk
end

function PlayerCameraGroupMode:enterAfk(delta)
	self.inAfk = true

	self:refreshTargetPlayer()
	self:OnCameraZoomingIn(0.2)

	local petEntity = pg.pawn

	if Utils.isPlayer(petEntity) then
		petEntity = petEntity:getCurPetEntity()
	end

	self.afkCamera:enter(petEntity)
end

function PlayerCameraGroupMode:exitAfk(delta)
	self:refreshTargetPlayer()
	self.afkCamera:exit()
	self:OnCameraZoomingOut(1)

	self.cameraMode.cameraController.clampPitchSpeed = 0

	self:refreshMinMaxPitch()

	self.isExitingAfk = true

	TimerManager.addTimer(delta, function()
		self.isExitingAfk = false
	end)
end

function PlayerCameraGroupMode:enterAfkMode()
	if self.inAfk then
		return
	end

	self.inAfk = true

	local curPet = pg.pawn

	if Utils.isPlayer(pg.pawn) then
		curPet = pg.pawn:getCurPetEntity()
	end

	curPet:postComponentMethod("onEnterAfkMode")
	pg.global.ui:hideAllUIByCustomKey(UIConst.UI_HIDE_KEY.AFK, {
		[UIConst.UI_ID_SCREEN_EFFECT] = true
	})
end

function PlayerCameraGroupMode:exitAfkMode()
	if not self.inAfk then
		return
	end

	self.inAfk = false

	local curPet = pg.pawn

	if Utils.isPlayer(pg.pawn) then
		curPet = pg.pawn:getCurPetEntity()
	end

	if curPet then
		curPet:postComponentMethod("onExitAfkMode")
	end

	self:exitAfk(1)
	pg.global.ui:restoreAllUIByCustomKey(UIConst.UI_HIDE_KEY.AFK)
	pg.pawn:stopCfgAnimation()
	self:cancelFovBlend(1.5)
end

function PlayerCameraGroupMode:blendToDistance(targetDistance, blendTime, ease)
	self.commonModifier:BlendToDistance(targetDistance, blendTime, ease)
end

function PlayerCameraGroupMode:blendOut(blendTime)
	self.commonModifier:BlendOut(blendTime)
end

function PlayerCameraGroupMode:blendToFov(fov, blendTime, blendFunc, blendExponent)
	blendFunc = blendFunc or VirtualCameraBlendFunction.Linear
	blendExponent = blendExponent or 2

	self.fovModifier:BlendToValue(fov, blendTime, blendFunc, blendExponent)
end

function PlayerCameraGroupMode:cancelFovBlend(blendOutTime, blendFunc, blendExponent)
	blendFunc = blendFunc or VirtualCameraBlendFunction.Linear
	blendExponent = blendExponent or 2

	self.fovModifier:StopBlend(blendOutTime, blendFunc, blendExponent)
end

function PlayerCameraGroupMode:onDisconnected()
	self:exitAfkMode()
end

function PlayerCameraGroupMode:setRotation(rot)
	self.cameraMode.cameraController:SetControlRotation(rot)
end

return PlayerCameraGroupMode
