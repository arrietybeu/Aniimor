-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Camera\\CameraSystem.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local MessageName = require("Const.MessageName")
local SystemBase = require("GameApp.Core.SystemBase")
local Class = require("Core.Framework.Class")
local ClientConst = require("Const.ClientConst")
local CameraConst = require("GameApp.Camera.CameraConst")
local logger = LoggerManager.getLogger("CameraSystem")
local bit = require("bit")
local Utils = require("Common.Utils.Utils")
local CameraShakeData = require("Data.camera_shake_data")
local ClientUtils = require("Utils.ClientUtils")
local lume = require("Core.Common.lume")
local PlayerCameraGroupMode = require("GameApp.Camera.CameraMode.PlayerCamera.PlayerCameraGroupMode")
local AnimCameraMode = require("GameApp.Camera.CameraMode.AnimCameraMode")
local LowPriorityAnimCameraMode = require("GameApp.Camera.CameraMode.LowPriorityAnimCameraMode")
local CameraData = require("Data.camera_data")
local SysConfigData = require("Data.sys_config_data")
local BallDriveCameraMode = require("GameApp.Camera.CameraMode.BallDriveCameraMode")
local PhotoCameraMode = require("GameApp.Camera.CameraMode.PhotoCamera.PhotoCameraMode")
local VolumeEffectConst = require("Const.VolumeEffectConst")
local FixedCameraMode = require("GameApp.Camera.CameraMode.FixedCameraMode")
local FixedWithTargetCameraMode = require("GameApp.Camera.CameraMode.FixedWithTargetCameraMode")
local ItemObtainFrontCameraMode = require("GameApp.Camera.CameraMode.ItemObtainFrontCameraMode")
local PhotoFaceToCameraMode = require("GameApp.Camera.CameraMode.PhotoCamera.PhotoFaceToCameraMode")
local NpcInteractCameraMode = require("GameApp.Camera.CameraMode.NpcInteractCameraMode")
local NpcDialogueCameraMode = require("GameApp.Camera.CameraMode.NpcDialogueCameraMode")
local FocusTargetCameraMode = require("GameApp.Camera.CameraMode.FocusTargetCameraMode")
local KillBossCameraMode = require("GameApp.Camera.CameraMode.KillBossCameraMode")
local DigEggCameraMode = require("GameApp.Camera.CameraMode.DigEggCameraMode")
local PVPRewardCameraMode = require("GameApp.Camera.CameraMode.GameModeCamera.PVPRewardCameraMode")
local Time = require("Core.Common.Time")
local VolumeConfigData = require("Data.volume_config_data")
local AddressDataConst = require("Const.AddressDataConst")
local Const = require("Common.Const.Const")
local CameraSystem = Class.LightClass("CameraSystem", SystemBase)
local VirtualCameraBlendFunction = CS.FunPlus.WorldX.VirtualCamera.VirtualCameraBlendFunction

function CameraSystem:onCtor()
	self.targetPlayer = nil
	self.tempTargetPlayer = nil
	self.finalTargetPlayer = nil
	self.playerCameraMode = nil
	self.animCameraMode = nil
	self.lowPriorityAnimCameraMode = nil
	self.ballDriveCameraMode = nil
	self.photoCameraMode = nil
	self.npcInteractCameraMode = nil
	self.npcDialogueCameraMode = nil
	self.focusTargetCameraMode = nil
	self.killBossCamera = nil
	self.digEggCamera = nil
	self.itemObtainFrontCameraMode = nil
	self.cameraList = {}
	self.cameraPositionCache = Vector3.zero
	self.cameraAnimRequestId = 0
	self.cameraAnimRequestActive = false
	self.uiCameraGroup = nil
	self.uiCameraList = {}
	self.lateUpdateCallback = {}
	self.lateUpdateTimerId = 0
	self.dofOpenStates = {}
	self.dofVolumeObj = {}
	self.curDofState = false
	self.worldCameraDisableInfo = {}
	self.enableWorldCamera = true
	self.cameraRotationCache = Quaternion.NewReadOnly()
end

function CameraSystem:onInit()
	self:initCameraManager()
	self:initCullingMask()
	self:initCameraModes()
	self:initUICameraGroup()
	self:initCameraBlenderTime()
end

function CameraSystem:onClear()
	self:clearTargetPlayer(0)
	self:resetPlayerCameraModes()
	self:setDofEnable(CameraConst.DofStateKeys.ItemObtain, false)
end

function CameraSystem:onSceneLoaded(sceneId, sceneName)
	if self.playerCameraMode then
		self.playerCameraMode:onSceneLoaded(sceneId, sceneName)
	end
end

function CameraSystem:onSceneUnloaded(sceneId, sceneName)
	if self.playerCameraMode then
		self.playerCameraMode:onSceneUnloaded(sceneId, sceneName)
	end
end

function CameraSystem:initCameraManager()
	pg.global.cameraMgr.enableGroundScan = true

	pg.global.cameraMgr:SetLuaTable(self)
end

function CameraSystem:onDestroy()
	self:clearTargetPlayer(0)
	self:setDofEnable(CameraConst.DofStateKeys.ItemObtain, false)
	self:destroyAllUICamera()
	self:destroyUICameraGroup()
	self:destroyAllCamera()
end

function CameraSystem:getMessageBindMap()
	return {
		[MessageName.ON_ENTITY_DESTROY] = "onEntityDestroy",
		[MessageName.TIMESCALE_CHANGE] = "onTimeScaleChange",
		[MessageName.INPUT_DEVICE_CHANGED] = "onInputDeviceChange"
	}
end

function CameraSystem:tryResetWorldCameraEnable(reason)
	if self.worldCameraDisableInfo and self.worldCameraDisableInfo[reason] == false then
		self.worldCameraDisableInfo[reason] = nil
	end

	self:refreshWorldCameraEnable()
end

function CameraSystem:setWorldCameraEnable(enable, reason)
	reason = reason or ClientConst.CameraDisableReason.Default

	if not enable then
		self.worldCameraDisableInfo[reason] = false
	else
		self.worldCameraDisableInfo[reason] = nil
	end

	self:refreshWorldCameraEnable()
end

function CameraSystem:refreshWorldCameraEnable()
	local enableWorldCamera = true

	if next(self.worldCameraDisableInfo) then
		enableWorldCamera = false
	end

	if self.enableWorldCamera ~= enableWorldCamera then
		self.enableWorldCamera = enableWorldCamera

		pg.global.cameraMgr:SetWorldCameraEnable(enableWorldCamera)
	end
end

function CameraSystem:resetPlayerCameraModes()
	if self.playerCameraMode then
		self:removeCamera(self.playerCameraMode)

		self.playerCameraMode = nil
	end

	self.playerCameraMode = PlayerCameraGroupMode.new()

	self:addCamera(self.playerCameraMode)
end

function CameraSystem:initCameraModes()
	self.playerCameraMode = PlayerCameraGroupMode.new()

	self:addCamera(self.playerCameraMode)

	self.animCameraMode = AnimCameraMode.new()

	self:addCamera(self.animCameraMode)

	self.lowPriorityAnimCameraMode = LowPriorityAnimCameraMode.new()

	self:addCamera(self.lowPriorityAnimCameraMode)

	self.ballDriveCameraMode = BallDriveCameraMode.new()

	self.ballDriveCameraMode:setActive(false)
	self:addCamera(self.ballDriveCameraMode)
	self:initPhotoCamera()

	self.npcInteractCameraMode = NpcInteractCameraMode.new()

	self.npcInteractCameraMode:setActive(false)
	self.npcInteractCameraMode:setCameraName(CameraConst.CAMERA_NAME_NPC_INTERACT)
	self:addCamera(self.npcInteractCameraMode, CameraConst.PRIORITY_NPC_INTERACT_CAMERA)

	self.npcDialogueCameraMode = NpcDialogueCameraMode.new()

	self.npcDialogueCameraMode:setActive(false)
	self.npcDialogueCameraMode:setCameraName(CameraConst.CAMERA_NAME_NPC_DIALOGUE)
	self:addCamera(self.npcDialogueCameraMode, CameraConst.PRIORITY_NPC_DIALOGUE_CAMERA)

	self.focusTargetCameraMode = FocusTargetCameraMode.new()

	self.focusTargetCameraMode:setActive(false)
	self.focusTargetCameraMode:setCameraName(CameraConst.CAMERA_NAME_FOCUS_TARGET)
	self:addCamera(self.focusTargetCameraMode, CameraConst.PRIORITY_NPC_DIALOGUE_CAMERA)

	self.killBossCamera = KillBossCameraMode.new()

	self.killBossCamera:setActive(false)
	self.killBossCamera:setCameraName(CameraConst.CAMERA_NAME_KILL_BOSS)
	self:addCamera(self.killBossCamera, CameraConst.PRIORITY_KILL_BOSS)

	self.digEggCamera = DigEggCameraMode.new()

	self.digEggCamera:setActive(false)
	self.digEggCamera:setCameraName(CameraConst.CAMERA_NAME_DIG_EGG)
	self:addCamera(self.digEggCamera, CameraConst.PRIORITY_DIG_EGG)
end

function CameraSystem:initPhotoCamera()
	self.photoCameraMode = PhotoCameraMode.new()

	self.photoCameraMode:setActive(false)
	self:addCamera(self.photoCameraMode)

	self.quickPhotoCameraMode = FixedCameraMode.new()

	self.quickPhotoCameraMode:setActive(false)
	self.quickPhotoCameraMode:setCameraName(CameraConst.QUICK_PHOTO_CAMERA_NAME)
	self:addCamera(self.quickPhotoCameraMode, CameraConst.PRIORITY_QUICK_PHOTO_CAMERA)

	self.quickPhotoFaceToCamera = PhotoFaceToCameraMode.new()

	self.quickPhotoFaceToCamera:setActive(false)
	self:addCamera(self.quickPhotoFaceToCamera, CameraConst.PRIORITY_QUICK_PHOTO_CAMERA)
end

function CameraSystem:initCameraBlenderTime()
	self.pvpTeamBlendTime = 0.6
	self.ghostEyeBlendTime = 0.5
end

function CameraSystem:onPlayerInit(player)
	self.playerCameraMode:setActive(true)
end

function CameraSystem:onPlayerDestroy(player)
	self:clearTargetPlayer(0)

	if not pg.me and self.playerCameraMode then
		self.playerCameraMode:setActive(false)
	end
end

function CameraSystem:destroyAllCamera()
	for _, camera in pairs(self.cameraList) do
		if camera ~= nil then
			camera:dispose()
		end
	end

	self.cameraList = {}
end

function CameraSystem:addLateUpdateTimer(func)
	self.lateUpdateTimerId = self.lateUpdateTimerId + 1
	self.lateUpdateCallback[self.lateUpdateTimerId] = func

	return self.lateUpdateTimerId
end

function CameraSystem:removeLateUpdateTimer(timerId)
	self.lateUpdateCallback[timerId] = nil
end

function CameraSystem:onInputDeviceChange()
	self.playerCameraMode.catchCamera:onInputDeviceChange()
end

function CameraSystem:onTick()
	if self.playerCameraMode then
		self.playerCameraMode:tick()
	end

	local curTime = Time.realSecondCache

	if not self.nextIntervalTickTimer or curTime >= self.nextIntervalTickTimer then
		self.nextIntervalTickTimer = curTime + 0.2

		self:onLowIntervalTick()
	end
end

function CameraSystem:onLowIntervalTick()
	self:checkZoomUpdateWeather()
end

function CameraSystem:checkZoomUpdateWeather()
	local openDof = self:isInBaseCamera() and self.playerCameraMode.cameraMode.cameraZoom.zoomValue < 0.1 and not self.playerCameraMode:checkInAfk()

	self:setDofEnable(CameraConst.DofStateKeys.PlayerZoomValue, openDof)
end

function CameraSystem:setDofEnable(key, enable)
	self.dofOpenStates[key] = enable

	if self.dofOpenStates[key] and self.dofVolumeObj[key] == nil then
		self.dofVolumeObj[key] = pgUtils.CreateDofVolume(key)
	elseif not self.dofOpenStates[key] and self.dofVolumeObj[key] then
		CS.UnityEngine.GameObject.Destroy(self.dofVolumeObj[key])

		self.dofVolumeObj[key] = nil
	end

	self:refreshDofOpenState()

	return self.dofVolumeObj[key]
end

function CameraSystem:getDof(key)
	if self.dofOpenStates[key] and self.dofVolumeObj[key] == nil then
		return nil
	end

	return self.dofVolumeObj[key]
end

function CameraSystem:refreshDofOpenState()
	local openDof = false

	for _, state in pairs(self.dofOpenStates) do
		if state then
			openDof = true

			break
		end
	end

	if openDof ~= self.curDofState then
		self.curDofState = openDof

		pgUtils.SetDofEnable(openDof, self:getVideoQuality())
	end
end

function CameraSystem:getVideoQuality()
	if self.dofOpenStates[CameraConst.DofStateKeys.FuncMenu] or self.dofOpenStates[CameraConst.DofStateKeys.ItemObtain] then
		return Const.VIDEO_QUALITY.HIGH
	end

	return pg.game.setting:getVideoQuality()
end

function CameraSystem:onCameraManagerLateUpdate()
	local sampleOn = SampleUtils.sampleOn()

	if sampleOn then
		SampleUtils.beginSample("CameraSystem.onCameraManagerLateUpdate")
	end

	for _, func in pairs(self.lateUpdateCallback) do
		if sampleOn then
			SampleUtils.beginSample(SampleUtils.showSampleDesc(func))
		end

		ClientUtils.tryWithLogError(func)

		if sampleOn then
			SampleUtils.endSample()
		end
	end

	if sampleOn then
		SampleUtils.endSample()
	end
end

function CameraSystem:getOrCreateSubCameraGroup(groupName)
	local subGroup = pg.global.cameraMgr.vcManager:GetOrCreateSubCameraGroup(groupName)

	return subGroup
end

function CameraSystem:destroySubCameraGroup(groupName)
	pg.global.cameraMgr.vcManager:RemoveSubCameraGroup(groupName)
end

function CameraSystem:setFocusCameraGroup(groupName)
	pg.global.cameraMgr.vcManager:SetFocusGroup(groupName)
end

function CameraSystem:addCamera(camera, priority)
	self.cameraList[#self.cameraList + 1] = camera

	camera:pushToParent(nil, priority)
end

function CameraSystem:removeCamera(camera)
	if not camera then
		return
	end

	for i, cam in ipairs(self.cameraList) do
		if cam == camera then
			table.remove(self.cameraList, i)

			break
		end
	end

	camera:dispose()
end

function CameraSystem:initUICameraGroup()
	self.uiCameraGroup = self:getOrCreateSubCameraGroup(CameraConst.CAMERA_GROUP_UI)

	self:initUICameraModes()
end

function CameraSystem:resetUICameraBlendStack()
	self.uiCameraGroup.cameraGroup:ResetBlendStack()
end

function CameraSystem:destroyUICameraGroup()
	self:destroySubCameraGroup(CameraConst.CAMERA_GROUP_UI)
end

function CameraSystem:setUIGroupActive(active)
	if active then
		self:setFocusCameraGroup(CameraConst.CAMERA_GROUP_UI)
	else
		self:setFocusCameraGroup(nil)
	end
end

function CameraSystem:initUICameraModes()
	self.uiAnimCameraMode = AnimCameraMode.new()

	self:addUICamera(self.uiAnimCameraMode)
end

function CameraSystem:setUICameraObject(uiCamera)
	self.uiCameraGroup.targetCamera = uiCamera
end

function CameraSystem:addUICamera(camera, priority)
	self.uiCameraList[#self.uiCameraList + 1] = camera

	local UIFarPlane = 10000

	camera.cameraMode.farPlane = UIFarPlane

	camera:pushToParent(self.uiCameraGroup.cameraGroup, priority)
end

function CameraSystem:removeUICamera(camera)
	if not camera then
		return
	end

	for i, cam in ipairs(self.uiCameraList) do
		if cam == camera then
			table.remove(self.uiCameraList, i)

			break
		end
	end

	camera:dispose()
end

function CameraSystem:destroyAllUICamera()
	for _, camera in pairs(self.uiCameraList) do
		if camera ~= nil then
			camera:dispose()
		end
	end

	self.uiCameraList = {}
end

function CameraSystem:isInBaseCamera()
	return self.playerCameraMode:isTop() and self.playerCameraMode:isInBaseCamera()
end

function CameraSystem:enableBallDrive(enable, trans)
	if enable then
		self.ballDriveCameraMode:setActive(true)

		self.ballDriveCameraMode.cameraMode.followTransform = trans
	else
		self.ballDriveCameraMode:setActive(false)
	end
end

function CameraSystem:enablePhoto(enable, preset)
	if enable then
		if self.stackCameraObj == nil then
			self.stackCameraObj = CS.UnityEngine.GameObject("StackCameraObj")
			self.stackCameraObj.layer = ClientConst.LayerDefine.LAYER_ENTITY
		end

		local rigidbody = self.stackCameraObj:AddComponent(typeof(CS.UnityEngine.Rigidbody))

		rigidbody.useGravity = false
		rigidbody.constraints = 112
		self.photoCameraMode.cameraMode.followTransform = self.stackCameraObj.transform

		self:syncPhotoCameraRotateSpeed(self.photoCameraMode.cameraMode)

		local playerTrans = CSEntityManager:GetPositionAgentByActorId(pg.me.actorId)

		if preset then
			self.photoCameraMode:AsyncTrans(preset.cameraPos.x, preset.cameraPos.y, preset.cameraPos.z, preset.cameraRot.x, preset.cameraRot.y, preset.cameraRot.z)
		else
			local playerCameraRotation = self.playerCameraMode:getRotation()

			self.photoCameraMode:AsyncTrans(playerTrans.position.x, playerTrans.position.y + 2, playerTrans.position.z, playerCameraRotation.eulerAngles.x, playerCameraRotation.eulerAngles.y, playerCameraRotation.eulerAngles.z)
		end

		local isControllingPet = pg.game.controller:isInControlEnt()
		local moveRangeBottomRadius = 15
		local moveRangeTopRadius = 10
		local moveRangeHeight = 10
		local nearHeight, farHeight = pg.pawn:getCameraHeightInfo()
		local selfieMoveX = 0.5
		local selfieMoveY = 0.3
		local selfieOffsetX = 0.1
		local selfieOffsetY = 0.1
		local selfieOffsetZ = isControllingPet and 2 or 0.8
		local selfieMoveRidus = isControllingPet and 2 or 0.8
		local selfieMoveAngleRange = 19

		self.photoCameraMode.cameraMode:SetMoveRange(playerTrans, moveRangeBottomRadius, moveRangeTopRadius, moveRangeHeight, nearHeight, selfieMoveX, selfieMoveY, selfieOffsetX, selfieOffsetY, selfieOffsetZ, selfieMoveRidus, selfieMoveAngleRange)
		self.photoCameraMode:setActive(true)
	else
		self.photoCameraMode:setActive(false)
		CS.UnityEngine.Object.Destroy(self.stackCameraObj)

		self.stackCameraObj = nil
	end

	self.photoCameraMode.stackCameraObj = self.stackCameraObj
end

function CameraSystem:syncPhotoCameraRotateSpeed(photoCameraMode)
	local playerMode = self.playerCameraMode and self.playerCameraMode.cameraMode
	local controller = playerMode and playerMode.cameraController

	if not photoCameraMode or not controller then
		return
	end

	photoCameraMode.pitchSpeed = controller.yawSpeed
	photoCameraMode.yawSpeed = controller.pitchSpeed
end

function CameraSystem:enableNpcInteract(enable)
	self.npcInteractCameraMode:enableCamera(enable)
end

function CameraSystem:enableNpcDialogue(enable, presetName, targetEntity, callback, extraInfo)
	self.npcDialogueCameraMode:enableCamera(enable, presetName, targetEntity, callback, extraInfo)
end

function CameraSystem:enableFocusTarget(enable, entities, cameraParam)
	self.focusTargetCameraMode:enableCustomCamera(enable, entities, cameraParam)
end

function CameraSystem:lookAtTargetNpc(from, to)
	local distance = SysConfigData.dialogueCameraDis or 3
	local offsetPitch = SysConfigData.dialogueCameraOffsetPitch or 0
	local offsetYaw = SysConfigData.dialogueCameraOffsetYaw or 0
	local faceDir = to:getPosition() - from:getPosition()
	local deltaDis = faceDir:Magnitude()

	faceDir:SetNormalize()

	local toTransform = CSEntityManager:GetPositionAgentByActorId(to.actorId)
	local fromTransform = CSEntityManager:GetPositionAgentByActorId(from.actorId)

	if self.npcDialogueCameraMode.cameraMode.targetNpc == toTransform then
		return
	end

	if Utils.isPlayer(from) then
		self.npcDialogueCameraMode.cameraMode.targetNpc = toTransform
	else
		self.npcDialogueCameraMode.cameraMode.targetNpc = fromTransform
		offsetYaw = -offsetYaw
	end

	local rotation = Quaternion.LookRotation(faceDir, Vector3.up)

	if ToBool(offsetPitch) then
		rotation:Copy(rotation * Quaternion.AngleAxis(offsetPitch, Vector3.left))
	end

	if ToBool(offsetYaw) then
		rotation:Copy(rotation * Quaternion.AngleAxis(offsetYaw, Vector3.up))
	end

	self.npcDialogueCameraMode:setCameraOffset(0, from:getTopLogoHeight() * 0.5)
	self.npcDialogueCameraMode:setCameraDistance(distance * from:getTopLogoHeight() * 0.6)
	self.npcDialogueCameraMode:setRotation(rotation)
end

function CameraSystem:getTargetPlayer()
	if self.tempTargetPlayer then
		return self.tempTargetPlayer
	end

	if self.targetPlayer then
		return self.targetPlayer
	end

	return nil
end

function CameraSystem:clearTargetPlayer(blendTime)
	local hadTarget = self.targetPlayer ~= nil or self.tempTargetPlayer ~= nil or self.finalTargetPlayer ~= nil or self.playerCameraMode and self.playerCameraMode.targetPlayer ~= nil

	self.targetPlayer = nil
	self.tempTargetPlayer = nil

	if self.playerCameraMode and hadTarget then
		self:applyTargetPlayer(nil, blendTime or 0)
	else
		self.finalTargetPlayer = nil
	end
end

function CameraSystem:setTempTargetPlayer(player, blendTime)
	self.tempTargetPlayer = player

	local targetPlayer = self:getTargetPlayer()

	if self.finalTargetPlayer ~= targetPlayer then
		self:applyTargetPlayer(targetPlayer, blendTime)
	end
end

function CameraSystem:setTargetPlayer(player, blendTime)
	self.targetPlayer = player

	local targetPlayer = self:getTargetPlayer()

	if self.finalTargetPlayer ~= targetPlayer then
		self:applyTargetPlayer(targetPlayer, blendTime)
	end
end

function CameraSystem:onPlayerCharacterStateChange(oldState, newState)
	self.playerCameraMode:onPlayerStateChange()
end

function CameraSystem:onPlayerBaseLayerTagChange()
	self.playerCameraMode:onPlayerStateChange()
end

function CameraSystem:applyTargetPlayer(targetPlayer, blendTime)
	self.finalTargetPlayer = targetPlayer

	self.playerCameraMode:setTargetPlayer(targetPlayer, blendTime)
	self.playerCameraMode:onPlayerStateChange()
	facade:SendMessageCommand(MessageName.ON_CAMERA_TARGET_CHANGE)
end

function CameraSystem:refreshTargetPlayer()
	self.playerCameraMode:refreshTargetPlayer()
end

function CameraSystem:onEntityDestroy(entId)
	local targetChanged = false

	if self.targetPlayer and self.targetPlayer.id == entId then
		self.targetPlayer = nil
		targetChanged = true
	end

	if self.tempTargetPlayer and self.tempTargetPlayer.id == entId then
		self.tempTargetPlayer = nil
		targetChanged = true
	end

	if self.finalTargetPlayer and self.finalTargetPlayer.id == entId then
		targetChanged = true
	end

	if targetChanged then
		self:applyTargetPlayer(self:getTargetPlayer(), 0)
	end
end

function CameraSystem:zoom(zoomDelta, context)
	self.cameraZoomContext = context

	pg.global.cameraMgr.vcManager:HandleCommand(vcCommand.Zoom, zoomDelta)
end

function CameraSystem:startZoomingIn()
	self.cameraZoomContext = nil

	pg.global.cameraMgr.vcManager:HandleCommand(vcCommand.ZoomingIn)
end

function CameraSystem:startZoomingOut()
	self.cameraZoomContext = nil

	pg.global.cameraMgr.vcManager:HandleCommand(vcCommand.ZoomingOut)
end

function CameraSystem:cancelZooming()
	self.cameraZoomContext = nil

	pg.global.cameraMgr.vcManager:HandleCommand(vcCommand.CancelZooming)
end

function CameraSystem:middleView()
	local lockHelper = pg.game.controller.lockHelper

	if self.playerCameraMode:isActivated() and ToBool(lockHelper.forceLockActorId) then
		local targetEnt = pg.getEntityByActorId(lockHelper.forceLockActorId)

		if targetEnt then
			self.playerCameraMode:focusTo(lockHelper:getLockPos(lockHelper.forceLockActorId, lockHelper.forceLockPartId), 0)

			return
		end
	end

	pg.global.cameraMgr.vcManager:HandleCommand(vcCommand.Recenter, 1)
end

function CameraSystem:focusToTarget(targetEnt)
	if not targetEnt then
		return
	end

	local targetPos = targetEnt:getPosition():Clone()

	targetPos.y = targetPos.y + targetEnt:getHeight() * 0.6

	self.playerCameraMode:focusTo(targetPos)
end

function CameraSystem:initCullingMask()
	pg.global.cameraMgr.maskController:HideLayer(ClientConst.LayerDefine.LAYER_UI, CameraConst.HIDE_CAMERA_FLAG.Default)
	pg.global.cameraMgr.maskController:HideLayer(ClientConst.LayerDefine.LAYER_UI_SCENE, CameraConst.HIDE_CAMERA_FLAG.Default)
end

function CameraSystem:hideEntity(controllerId)
	controllerId = controllerId or CameraConst.HIDE_CAMERA_FLAG.Default

	pg.global.cameraMgr.maskController:HideLayer(ClientConst.LayerDefine.LAYER_ENTITY, controllerId)
end

function CameraSystem:restoreEntity(controllerId)
	controllerId = controllerId or CameraConst.HIDE_CAMERA_FLAG.Default

	pg.global.cameraMgr.maskController:ShowLayer(ClientConst.LayerDefine.LAYER_ENTITY, controllerId)
end

function CameraSystem:setLayerFlag(controllerId, layerFlag)
	controllerId = controllerId or CameraConst.HIDE_CAMERA_FLAG.Default

	pg.global.cameraMgr.maskController:SetLayerHideFlag(layerFlag, controllerId)
end

function CameraSystem:setAbsolutelyControlMode(controllerId, layerValue, controlMode)
	if controlMode then
		pg.global.cameraMgr.maskController:ControlLayer(layerValue, controllerId)
	else
		pg.global.cameraMgr.maskController:UnControlLayer(controllerId)
	end
end

function CameraSystem:setVegetationShowMode(isShow)
	pg.global.cameraMgr.showVegetationMode = isShow
end

function CameraSystem:playCameraAnim(animResId, blendInTime, blendOutTime, inheritDir, cameraOffset, pivotOffset, checkStartCollide, checkCollide, modelScale, endCb, forceSync)
	if self.targetPlayer then
		self:playCameraAnimByEntity(self.targetPlayer, animResId, blendInTime, blendOutTime, inheritDir, cameraOffset, pivotOffset, checkStartCollide, checkCollide, modelScale, endCb, forceSync)
	end
end

function CameraSystem:playCameraAnimByEntity(targetEntity, animResId, blendInTime, blendOutTime, inheritDir, cameraOffset, pivotOffset, checkStartCollide, checkCollide, modelScale, endCb, forceSync)
	if self.animCameraMode and targetEntity then
		local baseTransform = CSEntityManager:GetPositionAgentByActorId(targetEntity.actorId)

		blendInTime = blendInTime or 0
		blendOutTime = blendOutTime or 1

		if inheritDir == nil then
			inheritDir = true
		end

		local scale = modelScale and modelScale or 1

		cameraOffset = cameraOffset or Vector3(0, 0, 0)
		self.cameraAnimRequestId = self.cameraAnimRequestId + 1

		local requestId = self.cameraAnimRequestId

		self.cameraAnimRequestActive = true

		local function cameraAnimEndCb()
			if self.cameraAnimRequestId == requestId then
				self.cameraAnimRequestActive = false
			end

			if endCb then
				endCb()
			end
		end

		self.animCameraMode:playCameraAnim(baseTransform, targetEntity, animResId, blendInTime, blendOutTime, inheritDir, cameraOffset, pivotOffset, checkStartCollide, checkCollide, scale, cameraAnimEndCb, forceSync)
	end
end

function CameraSystem:isCameraAnimActive()
	local active = self.cameraAnimRequestActive or self.animCameraMode and self.animCameraMode:isBlending()

	return active
end

function CameraSystem:stopCameraAnim()
	self.cameraAnimRequestId = self.cameraAnimRequestId + 1
	self.cameraAnimRequestActive = false

	if self.animCameraMode then
		self.animCameraMode:stopCameraAnim()
	end
end

function CameraSystem:setAnimCameraTime(time)
	if self.animCameraMode then
		self.animCameraMode:setTime(time)
	end
end

function CameraSystem:fastForwardCameraAnim(time)
	if self.animCameraMode then
		self.animCameraMode:fastForward(time)
	end
end

function CameraSystem:setCameraOffset(cameraOffset)
	if self.animCameraMode and self.targetPlayer.id == pg.pawn.id then
		self.animCameraMode:setCameraOffset(cameraOffset)
	end
end

function CameraSystem:refreshCameraState(entity)
	if not self.targetPlayer then
		return
	end

	if entity.id == self.targetPlayer.id then
		self.playerCameraMode:refreshCameraState()
	end
end

function CameraSystem:onSkillLockTarget(target)
	self.playerCameraMode:onLockEnemy(target)
end

function CameraSystem:cameraFaceToTarget(targetEnt, heightOffset, maxLockTime)
	if not targetEnt or not targetEnt.eModel then
		self.playerCameraMode:cancelFaceToTarget()

		return
	end

	local targetTransform = CSEntityManager:GetPositionAgentByActorId(targetEnt.actorId)

	self.playerCameraMode:FaceToTargetTransform(targetTransform, heightOffset, maxLockTime)
end

function CameraSystem:playCameraShake(ent, shakeInfo)
	if not shakeInfo then
		return
	end

	local shakeRadius = shakeInfo.shakeRadius or -1
	local shakeDissipation = shakeInfo.shakeDissipation or 28
	local shakeTime = shakeInfo.shakeTime or 0.5
	local shakeKeepTime = shakeInfo.shakeKeepTime or 0.1
	local shakePos = shakeInfo.shakePos or {
		0,
		0,
		0
	}
	local shakeType = shakeInfo.shakeType or CameraConst.CameraShakeType.Circular
	local shakeItem

	if shakeType == CameraConst.CameraShakeType.Circular then
		shakeItem = CS.FunPlus.WorldX.VirtualCamera.CircularCameraShake()

		local shakeFrequency = shakeInfo.shakeFrequency or 6
		local shakeAmplitude = shakeInfo.shakeAmplitude or 0.5
		local offset = shakeInfo.offset or 1
		local shakeDir = shakeInfo.shakeDir or {
			0,
			0,
			1
		}

		shakeItem.shakeFrequency = shakeFrequency
		shakeItem.shakeAmplitude = shakeAmplitude
		shakeItem.shakeBias = offset
		shakeItem.shakeDir = Vector3(shakeDir[1], shakeDir[2], shakeDir[3])
		shakeItem.random = shakeInfo.random or false

		local dirMode = shakeInfo.dirMode or ClientConst.ImpluseMode.Camera

		if dirMode == ClientConst.ImpluseMode.World then
			shakeItem.playSpace = CS.FunPlus.WorldX.VirtualCamera.CameraShakePlaySpace.World
		elseif dirMode == ClientConst.ImpluseMode.Actor then
			shakeItem.playSpace = CS.FunPlus.WorldX.VirtualCamera.CameraShakePlaySpace.World

			if ent then
				shakeItem.shakeDir = ent:getPositionAgentRotation() * shakeItem.shakeDir
			end
		else
			shakeItem.playSpace = CS.FunPlus.WorldX.VirtualCamera.CameraShakePlaySpace.CameraLocal
		end
	elseif shakeType == CameraConst.CameraShakeType.ShakeAnim then
		shakeItem = CS.FunPlus.WorldX.VirtualCamera.AnimCameraShake()

		local cameraShakeAnimName = shakeInfo.cameraShakeAnimName or ""

		shakeItem:SetShakeAsset(cameraShakeAnimName)
	elseif shakeType == CameraConst.CameraShakeType.PerlinNoise then
		local noisePosAmplitudes = shakeInfo.noisePosAmplitudes or {
			0,
			0,
			0
		}
		local noiseRotAmplitudes = shakeInfo.noiseRotAmplitudes or {
			0,
			0,
			0
		}
		local noisePosSeeds = shakeInfo.noisePosSeeds or {
			0,
			0,
			0
		}
		local noiseRotSeeds = shakeInfo.noisePosSeeds or {
			0,
			0,
			0
		}

		shakeItem = CS.FunPlus.WorldX.VirtualCamera.PerlinNoiseCameraShake()
		shakeItem.shakeFrequency = shakeInfo.shakeFrequency or 6
		shakeItem.noisePosAmplitudes = Vector3(noisePosAmplitudes[1], noisePosAmplitudes[2], noisePosAmplitudes[3])
		shakeItem.noiseRotAmplitudes = Vector3(noiseRotAmplitudes[1], noiseRotAmplitudes[2], noiseRotAmplitudes[3])
		shakeItem.noisePosSeeds = Vector3(noisePosSeeds[1], noisePosSeeds[2], noisePosSeeds[3])
		shakeItem.noiseRotSeeds = Vector3(noiseRotSeeds[1], noiseRotSeeds[2], noiseRotSeeds[3])
	else
		return
	end

	shakeItem.shakePos = Vector3(shakePos[1], shakePos[2], shakePos[3] or 0)
	shakeItem.decayTime = shakeTime
	shakeItem.sustainTime = shakeKeepTime
	shakeItem.shakeRadius = shakeRadius
	shakeItem.shakeDissipation = shakeDissipation

	if shakeInfo.affectCameraAnim then
		shakeItem:AddFlag(CS.FunPlus.WorldX.VirtualCamera.CameraShakeFlag.AffectCameraAim)
	end

	pg.global.cameraImpulseMgr:StartCameraShake(shakeItem)
end

function CameraSystem:playCameraShakeById(ent, impulseId)
	local cameraShakeData = CameraShakeData[impulseId]

	if not cameraShakeData then
		return false
	end

	ent = ent or pg.pawn

	local shakeInfo = {}

	table.merge(shakeInfo, cameraShakeData)

	shakeInfo.shakePos = ent:getPosition()
	shakeInfo.affectCameraAnim = true

	pg.game.camera:playCameraShake(ent, shakeInfo)
end

function CameraSystem:triggerCameraImpulse(ent, impulseInfo)
	if not impulseInfo then
		return
	end

	local noiseX = Vector3(0, 0, 0)
	local noiseY = Vector3(impulseInfo.shakeFrequency or 6, impulseInfo.shakeAmplitude, impulseInfo.offset or 1)
	local noiseZ = Vector3(0, 0, 0)
	local force = impulseInfo.force or 1
	local dir = impulseInfo.forceDir or {
		0,
		1,
		0
	}
	local velocity = Vector3(dir[1], dir[2], dir[3])
	local dirMode = impulseInfo.dirMode or ClientConst.ImpluseMode.World

	if dirMode == ClientConst.ImpluseMode.Actor then
		if ent == nil then
			return
		end

		velocity = ent:getPositionAgentRotation() * velocity
	end

	velocity = Vector3.Normalize(velocity) * force

	local shakeTime = impulseInfo.shakeTime or 0.2
	local radius = impulseInfo.shakeRadius or 2
	local randomShake = impulseInfo.random or false
	local dissipationDistance = impulseInfo.shakeDissipation or 28
	local shakePos = impulseInfo.shakePos

	if shakePos == nil then
		if ent.eModel then
			shakePos = ent:getPositionAgentPosition()
		else
			return
		end
	else
		shakePos = Vector3(shakePos[1], shakePos[2], shakePos[3])
	end

	pg.global.cameraImpulseMgr:AddImpulse(shakePos, velocity, shakeTime, radius, dissipationDistance, noiseX, noiseY, noiseZ, randomShake)
end

function CameraSystem:setTimeScale(timeScale)
	pg.global.cameraMgr:SetTimeScale(timeScale)
end

function CameraSystem:playRadialBlur(configName, duration)
	pg.global.cameraMgr:StartRadialBlur(configName or AddressDataConst.AE_RADIAL_BLUR_DEFAULT, duration or -1)
end

function CameraSystem:stopRadialBlur()
	pg.global.cameraMgr:StopRadialBlur()
end

function CameraSystem:stopVignette()
	pg.global.cameraMgr:StopVignette()
end

function CameraSystem:onTimeScaleChange(timeScale)
	if timeScale >= 0.999 then
		-- block empty
	end
end

function CameraSystem:getCameraPosition()
	local pos = self.cameraPositionCache

	if self.lastCacheFrame ~= Time.unityFrameCount then
		self.lastCacheFrame = Time.unityFrameCount

		local x, y, z = pg.global.cameraMgr:GetWorldCameraPositionEx()

		Vector3.Set(pos, x, y, z)
	end

	return pos
end

function CameraSystem:getCameraRotation()
	local rotation = self.cameraRotationCache

	if self.lastCacheRotFrame ~= Time.unityFrameCount then
		self.lastCacheRotFrame = Time.unityFrameCount

		local x, y, z, w = pg.global.cameraMgr:GetWorldCameraRotationEx()

		Quaternion.refreshReadOnly(rotation, x, y, z, w)
	end

	return rotation
end

function CameraSystem:getSceneViewPos()
	if pg.global.cameraMgr.uiSceneCameraInst then
		return pg.global.cameraMgr.uiSceneCameraInst.transform.position
	else
		return self:getCameraPosition()
	end
end

function CameraSystem:getCameraFarPlane()
	return pg.global.cameraMgr:GetWorldCameraFarPlane()
end

function CameraSystem:getCameraFov()
	return pg.global.cameraMgr:GetWorldCameraFov()
end

function CameraSystem:checkInViewport(targetPos)
	local x, y, z = pg.global.cameraMgr:GetTargetViewportPosXYZ(targetPos[1], targetPos[2], targetPos[3])

	if x < 0.9 and x > 0.1 and y < 0.9 and y > 0.1 and z > 0 then
		return true
	end

	return false
end

function CameraSystem:checkInViewportCenter(targetPos)
	local x, y, z = pg.global.cameraMgr:GetTargetViewportPosXYZ(targetPos[1], targetPos[2], targetPos[3])

	if x < 0.8 and x > 0.2 and y < 0.85 and y > 0.15 and z > 0 then
		return true
	end

	return false
end

function CameraSystem:checkInViewportFull(targetPos)
	local x, y, z = pg.global.cameraMgr:GetTargetViewportPosXYZ(targetPos[1], targetPos[2], targetPos[3])

	if x < 1 and x > 0 and y < 1 and y > 0 and z > 0 then
		return true
	end

	return false
end

function CameraSystem:getCameraBlendTime(fromCam, toCame)
	local fromKey = fromCam and fromCam.cameraName or ""
	local toKey = toCame and toCame.cameraName or ""

	if toKey == "CutsceneCamera" then
		return toCame.defaultBlendTime
	end

	if fromKey == "CutsceneCamera" then
		return fromCam.defaultBlendTime
	end

	if toKey == CameraConst.CAMERA_NAME_AVATAR then
		return 0
	end

	if toKey == CameraConst.CAMERA_NAME_STUDIO_FREE then
		return 0
	end

	if toKey == CameraConst.CAMERA_NAME_CAMERA_PUZZLE then
		return toCame.defaultBlendTime
	end

	if fromKey == CameraConst.CAMERA_NAME_CAMERA_PUZZLE then
		return fromCam.defaultBlendTime
	end

	if fromKey == CameraConst.CAMERA_NAME_HOME_GROUP then
		return 0
	end

	if fromKey == CameraConst.CAMERA_NAME_TEAM_ROOM or toKey == CameraConst.CAMERA_NAME_TEAM_ROOM then
		return 0
	end

	if toKey == CameraConst.CAMERA_NAME_ANIM then
		return toCame.blendInTime
	end

	if fromKey == CameraConst.CAMERA_NAME_ANIM then
		return fromCam.blendOutTime
	end

	if toKey == CameraConst.CAMERA_NAME_GROUP_SING then
		return toCame.blendInTime
	end

	if fromKey == CameraConst.CAMERA_NAME_GROUP_SING then
		return fromCam.blendOutTime
	end

	if toKey == CameraConst.CAMERA_NAME_LEVEL then
		return toCame.defaultBlendTime
	end

	if fromKey == CameraConst.CAMERA_NAME_LEVEL then
		return fromCam.defaultBlendTime
	end

	if fromKey == CameraConst.CAMERA_NAME_AIM then
		return fromCam.defaultBlendTime
	end

	if toKey == CameraConst.CAMERA_NAME_AIM then
		return toCame.defaultBlendTime
	end

	if fromKey == CameraConst.CAMERA_NAME_NORMAL_ATTACK_LOCK_ON_CAMERA then
		local ownerLua = fromCam.ownerLua

		return ownerLua and ownerLua.exitBlendTime or fromCam.defaultBlendTime
	end

	if toKey == CameraConst.CAMERA_NAME_PVP_LOADING or fromKey == CameraConst.CAMERA_NAME_PVP_LOADING then
		return self.pvpTeamBlendTime
	end

	if fromKey == CameraConst.CAMERA_NAME_CATCH or toKey == CameraConst.CAMERA_NAME_CATCH then
		return 0.4
	end

	if fromKey == CameraConst.CAMERA_NAME_PVP_REWARD or toKey == CameraConst.CAMERA_NAME_PVP_REWARD then
		return 0.8
	end

	if toKey == CameraConst.CAMERA_NAME_FIXED or fromKey == CameraConst.CAMERA_NAME_FIXED then
		return 0
	end

	if fromKey == CameraConst.CAMERA_NAME_GHOST_EYE or toKey == CameraConst.CAMERA_NAME_GHOST_EYE then
		return self.ghostEyeBlendTime
	end

	if fromKey == CameraConst.CAMERA_NAME_FIXED_WITH_TARGET then
		return fromCam.defaultBlendTime
	end

	if toKey == CameraConst.CAMERA_NAME_DIALOGUE_GRAPH then
		return toCame.defaultBlendTime
	end

	if fromKey == CameraConst.CAMERA_NAME_DIALOGUE_GRAPH and fromCam.defaultBlendTime ~= 0 then
		return fromCam.defaultBlendTime
	end

	if toKey == CameraConst.CAMERA_NAME_CATCH then
		return 1.5
	end

	if toKey == CameraConst.CAMERA_NAME_CLIMB or fromKey == CameraConst.CAMERA_NAME_CLIMB then
		return 0.5
	end

	return -1
end

function CameraSystem:addVolumeEffect(index)
	local data = VolumeConfigData[index]

	if data then
		local priority = data.priority
		local resId = data.resId

		pg.global.cameraMgr:AddVolumeEffect(priority, resId, data.lerpTime or -1)
	end
end

function CameraSystem:enableVolumeEffect(index, enable)
	local data = VolumeConfigData[index]

	if data then
		local resId = data.resId

		pg.global.cameraMgr:EnableVolumeEffect(resId, enable)
	end
end

function CameraSystem:delVolumeEffect(index)
	local volumeConfig = VolumeConfigData[index]

	if volumeConfig then
		local resId = volumeConfig.resId

		pg.global.cameraMgr:DelVolumeEffect(resId)
	end
end

function CameraSystem:addSceneDim(darkenValue)
	pg.global.cameraMgr:AddSceneDim(darkenValue)
end

function CameraSystem:delSceneDim()
	pg.global.cameraMgr:DelSceneDim()
end

function CameraSystem:startScanScene(duration)
	local pawn = pg.pawn

	if pawn then
		pg.global.cameraMgr:StartScanScene(duration, pawn:getPosition())
	end
end

function CameraSystem:stopScanScene()
	pg.global.cameraMgr:StopScanScene()
end

function CameraSystem:closePVPLoadingCamera(blendTime)
	if self.pvpLoadingCameraMode == nil then
		return
	end

	self.pvpLoadingCameraMode:setActive(false)

	self.pvpTeamBlendTime = blendTime or 0.6
end

function CameraSystem:startPVPLoadingCameraFix(pos, rotation, fov, blendTime)
	if self.pvpLoadingCameraMode == nil then
		self.pvpLoadingCameraMode = FixedCameraMode.new()

		self.pvpLoadingCameraMode:setActive(false)
		self.pvpLoadingCameraMode:setCameraName(CameraConst.CAMERA_NAME_PVP_LOADING)
		self:addCamera(self.pvpLoadingCameraMode, CameraConst.PRIORITY_PVP_LOADING)
	end

	self.pvpLoadingCameraMode:setPosition(pos)
	self.pvpLoadingCameraMode:setRotation(rotation)
	self.pvpLoadingCameraMode:setFov(fov)
	self.pvpLoadingCameraMode:setActive(true)

	self.pvpTeamBlendTime = blendTime or 0.6
end

function CameraSystem:startPVPRewardCamera(pos, rotation, fov)
	if self.pvpRewardCameraMode == nil then
		self.pvpRewardCameraMode = FixedCameraMode.new()

		self.pvpRewardCameraMode:setActive(false)
		self.pvpRewardCameraMode:setCameraName(CameraConst.CAMERA_NAME_PVP_REWARD)
		self:addCamera(self.pvpRewardCameraMode, CameraConst.PRIORITY_PVP_REWARD)
	end

	self.pvpRewardCameraMode:setPosition(pos)
	self.pvpRewardCameraMode:setRotation(rotation)
	self.pvpRewardCameraMode:setFov(fov)
	self.pvpRewardCameraMode:setActive(true)
end

function CameraSystem:closePVPRewardCamera()
	if self.pvpRewardCameraMode == nil then
		return
	end

	self.pvpRewardCameraMode:setActive(false)
end

function CameraSystem:startFixedCamera(pos, rotation, fov)
	if self.defaultFixedCamera == nil then
		self.defaultFixedCamera = FixedCameraMode.new()

		self.defaultFixedCamera:setActive(false)
		self.defaultFixedCamera:setCameraName(CameraConst.CAMERA_NAME_FIXED)
		self:addCamera(self.defaultFixedCamera, CameraConst.PRIORITY_FIXED)
	end

	self.defaultFixedCamera:setPosition(pos)
	self.defaultFixedCamera:setRotation(rotation)
	self.defaultFixedCamera:setFov(fov)
	self.defaultFixedCamera:setActive(true)
end

function CameraSystem:closeFixedCamera()
	if self.defaultFixedCamera == nil then
		return
	end

	self.defaultFixedCamera:setActive(false)
end

function CameraSystem:closeTeamRoomCamera()
	if self.teamRoomCameraMode then
		self.teamRoomCameraMode:setActive(false)
		self:removeCamera(self.teamRoomCameraMode)
	end

	self.teamRoomCameraMode = nil
end

function CameraSystem:startTeamRoomCameraFix(pos, rotation, fov)
	if self.teamRoomCameraMode == nil then
		self.teamRoomCameraMode = FixedCameraMode.new()

		self.teamRoomCameraMode:setActive(false)
		self.teamRoomCameraMode:setCameraName(CameraConst.CAMERA_NAME_TEAM_ROOM)
		self:addCamera(self.teamRoomCameraMode, CameraConst.PRIORITY_TEAM_ROOM)
	end

	self.teamRoomCameraMode:setPosition(pos)
	self.teamRoomCameraMode:setRotation(rotation)
	self.teamRoomCameraMode:setFov(fov)
	self.teamRoomCameraMode:setActive(true)
end

function CameraSystem:closeQuickPhotoCamera()
	self.quickPhotoCameraMode:setActive(false)
	self.quickPhotoFaceToCamera:setActive(false)
end

function CameraSystem:startQuickPhotoCameraFix(pos, rotation, fov)
	self.quickPhotoCameraMode:setPosition(pos)
	self.quickPhotoCameraMode:setRotation(rotation)
	self.quickPhotoCameraMode:setFov(fov)
	self.quickPhotoCameraMode:setActive(true)
end

function CameraSystem:startQuickPhotoFaceTo(transform, offset, rotation, distance)
	self.quickPhotoFaceToCamera:setTargetTransform(transform, offset, rotation, distance)
	self.quickPhotoFaceToCamera:setActive(true)
end

function CameraSystem:startQuickPhotoFaceToByActorId(actorId, offset, rotation, distance)
	local transform = actorId and actorId ~= 0 and CSEntityManager:GetPositionAgentByActorId(actorId) or nil

	self:startQuickPhotoFaceTo(transform, offset, rotation, distance)
end

function CameraSystem:setQuickPhotoFinishBlendCb(cb)
	self.quickPhotoCameraMode:setFinishBlendCb(cb)
	self.quickPhotoFaceToCamera:setFinishBlendCb(cb)
end

function CameraSystem:cameraBlendToFixed(pos, rotation, fov, blendTime, callback, cancelCallback, extraParam)
	if self.fixedCameraMode ~= nil then
		self.fixedCameraMode:onCanceled()
		self.fixedCameraMode:setFinishBlendCb(nil)
		self:removeCamera(self.fixedCameraMode)
	end

	extraParam = extraParam or {}
	self.fixedCameraMode = FixedCameraMode.new()
	self.fixedCameraMode.cameraId = extraParam.cameraId

	self.fixedCameraMode:setPosition(pos or Vector3.zero)
	self.fixedCameraMode:setRotation(rotation or Quaternion.identity)
	self.fixedCameraMode:setCameraName(CameraConst.CAMERA_NAME_LEVEL)

	self.fixedCameraMode.cameraMode.defaultBlendTime = blendTime

	self.fixedCameraMode:setFov(fov)
	self.fixedCameraMode:setFinishBlendCb(callback)
	self.fixedCameraMode:setCancelBlendCb(cancelCallback)

	self.fixedCameraMode.blendFunction = extraParam.blendFunction or VirtualCameraBlendFunction.EaseOut
	self.fixedCameraMode.blendExponent = extraParam.blendExponent or 2

	self.fixedCameraMode:setEnableShake(extraParam.enableShake)
	self:addCamera(self.fixedCameraMode, CameraConst.PRIORITY_FIXED)
end

function CameraSystem:cancelBlendToFixed(blendTime, resetDir, extraParam)
	extraParam = extraParam or {}

	if self.fixedCameraMode ~= nil then
		if extraParam.cameraId and self.fixedCameraMode.cameraId ~= extraParam.cameraId then
			return
		end

		local curCamera = self.fixedCameraMode

		self.fixedCameraMode = nil

		curCamera:onCanceled()

		curCamera.cameraMode.defaultBlendTime = blendTime
		curCamera.resetDir = resetDir

		self:removeCamera(curCamera)
	end
end

function CameraSystem:cameraBlendToFixedWithTargetByActorId(pos, rot, fov, actorId, blendTime, callback, extraParam)
	local target = actorId and actorId ~= 0 and CSEntityManager:GetPositionAgentByActorId(actorId) or nil

	self:cameraBlendToFixedWithTarget(pos, rot, fov, target, blendTime, callback, extraParam)
end

function CameraSystem:cameraBlendToFixedWithTarget(pos, rot, fov, target, blendTime, callback, extraParam)
	if self.itemObtainFrontCameraMode ~= nil then
		self.itemObtainFrontCameraMode:setFinishBlendCb(nil)
		self:removeCamera(self.itemObtainFrontCameraMode)
		self.itemObtainFrontCameraMode:blendOut(0)

		self.itemObtainFrontCameraMode = nil

		self:setDofEnable(CameraConst.DofStateKeys.ItemObtain, false)
	end

	if self.fixedWithTargetCameraMode ~= nil then
		self.fixedWithTargetCameraMode:setFinishBlendCb(nil)
		self:removeCamera(self.fixedWithTargetCameraMode)
		self.fixedWithTargetCameraMode:blendOut(0)
	end

	extraParam = extraParam or {}
	self.fixedWithTargetCameraMode = FixedWithTargetCameraMode.new()

	self.fixedWithTargetCameraMode:setCameraName(CameraConst.CAMERA_NAME_FIXED_WITH_TARGET)

	self.fixedWithTargetCameraMode.cameraMode.defaultBlendTime = blendTime

	self.fixedWithTargetCameraMode:setFinishBlendCb(callback)

	self.fixedWithTargetCameraMode.cameraMode.blendFunction = extraParam.blendFunction or VirtualCameraBlendFunction.EaseOut
	self.fixedWithTargetCameraMode.cameraMode.blendExponent = extraParam.blendExponent or 2
	self.fixedWithTargetCameraMode.cameraMode.inheritDir = extraParam.inheritDir or false
	self.fixedWithTargetCameraMode.cameraMode.pivotOffset = extraParam.pivotOffset or Vector3.zero

	self.fixedWithTargetCameraMode:setCameraInfo(pos, rot, fov, target)
	self:addCamera(self.fixedWithTargetCameraMode, CameraConst.PRIORITY_FIXED_WITH_TARGET)
end

function CameraSystem:cancelBlendToFixedWithTarget(blendTime)
	if self.fixedWithTargetCameraMode ~= nil then
		self.fixedWithTargetCameraMode.cameraMode.defaultBlendTime = blendTime

		self:removeCamera(self.fixedWithTargetCameraMode)
	end

	self.fixedWithTargetCameraMode = nil
end

function CameraSystem:modifyFixedWithTargetDist(distance, deltaTime, ease, needResolveCollisions)
	if self.fixedWithTargetCameraMode ~= nil then
		self.fixedWithTargetCameraMode:blendToDistance(distance, deltaTime, ease, needResolveCollisions)
	end
end

function CameraSystem:openBadgeObtainCamera()
	local nearHeight, farHeight = pg.pawn:getCameraHeightInfo()
	local offset = pg.pawn:getConfigData().funcMenuCameraOffsetFront

	offset = offset or {
		0,
		0,
		0
	}

	local pivotOffset = Vector3(offset[1], offset[2] + nearHeight, offset[3])
	local isControllingPet = pg.game.controller:isInControlEnt()
	local cameraPos = Vector3(-0.2, 0.08, 1.2)
	local cameraRot = Vector3(10, 180, 0)
	local fov = pg.global.cameraMgr.vcManager:GetFuncMenuFrontFov(isControllingPet)

	self:cameraBlendToFixedWithTargetByActorId(cameraPos, cameraRot, fov, pg.me.actorId, 0.65, function()
		pg.me.eModel.modelModelView:SetLightIntensity(1)
	end, {
		inheritDir = false,
		blendExponent = 4,
		pivotOffset = pivotOffset,
		blendFunction = VirtualCameraBlendFunction.EaseOut
	})
	self:setDofEnable(CameraConst.DofStateKeys.BadgeObtain, true)
end

function CameraSystem:closeBadgeObtainCamera(blendTime)
	self:setDofEnable(CameraConst.DofStateKeys.BadgeObtain, false)
	self:cancelBlendToFixedWithTarget(blendTime)
end

function CameraSystem:getCameraCurve(curveName)
	return pg.global.cameraMgr:GetConfigCurve(curveName)
end

function CameraSystem:overrideCameraDistanceScale(distanceScale, maxTime)
	self.playerCameraMode:overrideCameraDistanceScale(distanceScale, maxTime)
end

function CameraSystem:resetCameraDistanceScale()
	self.playerCameraMode:resetCameraDistanceScale()
end

function CameraSystem:refreshCameraDistanceScale()
	if self.playerCameraMode then
		self.playerCameraMode:refreshCameraDistanceScale()
	end
end

function CameraSystem:refreshCameraZoomLimit()
	if self.playerCameraMode then
		self.playerCameraMode:refreshZoomLimit()
	end
end

function CameraSystem:onDisconnected()
	self.playerCameraMode:onDisconnected()
end

return CameraSystem
