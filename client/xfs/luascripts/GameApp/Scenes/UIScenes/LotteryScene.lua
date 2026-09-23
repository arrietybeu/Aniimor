-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Scenes\\UIScenes\\LotteryScene.lua

local Class = require("Core.Framework.Class")
local AvatarScene = require("GameApp.Scenes.UIScenes.AvatarScene")
local UIScenePreviewController = require("GameApp.Scenes.UIScenes.UIScenePreviewController")
local ClientModelUtils = require("Utils.ClientModelUtils")
local ClientVirtualEntityUtils = require("Utils.ClientVirtualEntityUtils")
local TimerManager = require("Core.Timer.TimerManager")
local PlayableConst = require("Const.PlayableConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PetData = require("Data.pet_data")
local logger = require("Core.Log.LoggerManager").getLogger("LotteryScene")
local CAMERA_BLEND_DURATION = 0.5
local CAMERA_MOVE_TWEEN_ID = LuaUIUtils.TweenId("lotterySceneCameraMove")
local CAMERA_ROTATE_TWEEN_ID = LuaUIUtils.TweenId("lotterySceneCameraRotate")
local CAMERA_FOV_TWEEN_ID = LuaUIUtils.TweenId("lotterySceneCameraFov")
local CAMERA_ORTHOGRAPHIC_TWEEN_ID = LuaUIUtils.TweenId("lotterySceneCameraOrthographic")
local LotteryScene = Class.LightClass("LotteryScene", AvatarScene)

function LotteryScene:onStart()
	self._timelineSerial = 0
	self._activeTimelineSerial = nil
	self._destroyed = false
	self._avatarReady = false
	self.gestures = {}
	self.cameraModes = {}
	self.dontSetCamera = true

	local globalTransform = self.scene and self.scene.transform:Find("Global")

	self.objectReference = globalTransform and globalTransform:GetComponent("ObjectReference")

	if IsNil(self.objectReference) then
		logger:error("抽奖 UI 场景缺少 Global/ObjectReference, res=%s", tostring(self.resId))

		return
	end

	self.camera = self.objectReference:GetRefValue("camera")
	self.entityRootTransform = self.objectReference:GetRefValue("entityRootTransform")
	self.boyLight = self.objectReference:GetRefValue("boyLight")
	self.girlLight = self.objectReference:GetRefValue("girlLight")

	if NotNil(self.camera) then
		self.cameraPosition = self.camera.transform.position
		self.cameraRotation = self.camera.transform.rotation
		self.cameraLocalEulerAngles = self.camera.transform.localEulerAngles
		self.cameraFieldOfView = self.camera.fieldOfView
		self.cameraOrthographicSize = self.camera.orthographicSize
		self.cameraEnabled = self.camera.enabled
	else
		logger:error("抽奖 UI 场景缺少 camera, res=%s", tostring(self.resId))
	end

	if IsNil(self.entityRootTransform) then
		logger:error("抽奖 UI 场景缺少 entityRootTransform, res=%s", tostring(self.resId))
	end

	self.nameObjectPool = {}
	self.previewSceneController = UIScenePreviewController.new(self)

	self:initCameraModes()
end

function LotteryScene:switchLight()
	AvatarScene.switchLight(self, true)

	local presetData = self.curEntityId and pg.game.avatar:getAvatarPresetData(self.curEntityId)

	if not presetData and (not self.curEntityId or not PetData[self.curEntityId]) then
		return
	end

	local body = presetData and tonumber(presetData.body)
	local isFemale = body and math.floor(body / 10) == 1

	if NotNil(self.boyLight) then
		self.boyLight.gameObject:SetActiveEx(not isFemale)
	end

	if NotNil(self.girlLight) then
		self.girlLight.gameObject:SetActiveEx(isFemale == true)
	end
end

function LotteryScene:setAvatarReady(ready)
	self._avatarReady = ready == true

	if not self._avatarReady or not self._playEntranceOnAvatarReady then
		return
	end

	self._playEntranceOnAvatarReady = false

	self:playEntranceTimeline()
end

function LotteryScene:isEntranceTimelinePlaying()
	return self._activeTimelineSerial ~= nil
end

function LotteryScene:rotatePreviewEntity(deltaAngle)
	if self._activeTimelineSerial then
		return
	end

	AvatarScene.rotatePreviewEntity(self, deltaAngle)
end

function LotteryScene:setPreviewAnimationKey(animKey)
	self._previewAnimationKey = animKey
end

function LotteryScene:playPreviewAnimation(entity)
	if not entity then
		return
	end

	if self._previewAnimationKey then
		entity:playAnimation(self._previewAnimationKey, true, nil, true, PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY)

		return
	end

	self:playIdleAnimation(entity, 0)
end

function LotteryScene:restorePreviewAnimation()
	if self._activeTimelineSerial then
		return
	end

	local entity = self:getCurEntity()

	if not entity then
		return
	end

	self:runWhenAnimatorReady(entity, function()
		if self._destroyed or self._activeTimelineSerial or self:getCurEntity() ~= entity then
			return
		end

		self:playPreviewAnimation(entity)
	end)
end

function LotteryScene:resetPreviewEntity()
	local entity = self:getCurEntity()

	if not entity or IsNil(entity.eModel) or IsNil(self.entityRootTransform) then
		return
	end

	entity.eModel:SetTransformParent(self.entityRootTransform, false)
	entity.eModel:SetTransformLocalPosition()
	entity.eModel:SetTransformLocalRotation(0, 0, 0, 1)
	entity.eModel:SetTransformLocalScale()

	self._resultPreviewRotationRange = nil

	self:playPreviewAnimation(entity)
end

function LotteryScene:setResultPreviewTransform(transformData)
	local entity = self:getCurEntity()

	if not entity or IsNil(entity.eModel) or IsNil(self.entityRootTransform) or not transformData then
		return false
	end

	local position = transformData.position
	local rotation = transformData.rotation
	local scale = transformData.scale

	if not position or not rotation or not scale then
		return false
	end

	entity.eModel:SetTransformParent(self.entityRootTransform, false)
	entity.eModel:SetTransformLocalPosition(position[1], position[2], position[3])
	entity.eModel:SetTransformRotationByEulerAngle(rotation[1], rotation[2], rotation[3])
	entity.eModel:SetTransformLocalScale(scale[1], scale[2], scale[3])

	self._resultPreviewRotationRange = {
		min = rotation,
		max = transformData.maxRotation
	}

	return true
end

function LotteryScene:setEntranceTimeline(timelineRes)
	if type(timelineRes) == "string" then
		timelineRes = timelineRes:match("^%s*(.-)%s*$")
	end

	if timelineRes == "" or timelineRes == "0" then
		timelineRes = nil
	end

	if self._entranceTimelineRes == timelineRes then
		return
	end

	self:stopEntranceTimeline()

	self._entranceTimelineRes = timelineRes
end

function LotteryScene:setEntranceTimelineEndCallback(callback)
	self._entranceTimelineEndCallback = callback
end

function LotteryScene:setEntranceTimelinePlayedCallback(callback)
	self._entranceTimelinePlayedCallback = callback
end

function LotteryScene:beginTimelineCamera()
	if IsNil(self.camera) then
		return false
	end

	self:resetCamera()

	local vcManager = pg.global.cameraMgr.vcManager
	local rootGroup = vcManager and vcManager.rootGroup

	if not rootGroup then
		return false
	end

	if self.timelineRootGroup ~= rootGroup then
		self:endTimelineCamera()

		self.timelineRootGroup = rootGroup
		self.timelineOriginalOutputCamera = rootGroup.targetCamera
	end

	rootGroup.targetCamera = self.camera

	self:resetTimelineCameraBlend()

	return true
end

function LotteryScene:resetTimelineCameraBlend()
	local vcManager = pg.global.cameraMgr.vcManager
	local ownsOutput = vcManager and self.timelineRootGroup and vcManager.rootGroup == self.timelineRootGroup and self.timelineRootGroup.targetCamera == self.camera

	if ownsOutput and vcManager.rootCameraGroup then
		vcManager.rootCameraGroup:ResetBlendStack()
	end
end

function LotteryScene:stopCameraBlend()
	self.cameraBlendSerial = (self.cameraBlendSerial or 0) + 1
	self._cameraBlending = false
	self.timelineEndCameraPose = nil

	if IsNil(self.camera) then
		return
	end

	local cameraObject = self.camera.gameObject

	DoTweenAnimMgr.Kill(cameraObject, CAMERA_MOVE_TWEEN_ID, false)
	DoTweenAnimMgr.Kill(cameraObject, CAMERA_ROTATE_TWEEN_ID, false)
	DoTweenAnimMgr.Kill(cameraObject, CAMERA_FOV_TWEEN_ID, false)
	DoTweenAnimMgr.Kill(cameraObject, CAMERA_ORTHOGRAPHIC_TWEEN_ID, false)
end

function LotteryScene:releaseTimelineCamera()
	self:resetTimelineCameraBlend()

	local rootGroup = self.timelineRootGroup

	if rootGroup and rootGroup.targetCamera == self.camera then
		rootGroup.targetCamera = self.timelineOriginalOutputCamera
	end

	self.timelineRootGroup = nil
	self.timelineOriginalOutputCamera = nil
end

function LotteryScene:finishTimelineCamera()
	if IsNil(self.camera) then
		self:endTimelineCamera()

		return
	end

	self:stopCameraBlend()

	self.timelineEndCameraPose = {
		position = self.camera.transform.position,
		localRotation = self.camera.transform.localRotation,
		fieldOfView = self.camera.fieldOfView,
		orthographicSize = self.camera.orthographicSize
	}

	self:releaseTimelineCamera()
	self.camera.gameObject:SetActiveEx(true)

	self.camera.enabled = self.cameraEnabled
	self.camera.transform.position = self.timelineEndCameraPose.position
	self.camera.transform.localRotation = self.timelineEndCameraPose.localRotation
	self.camera.fieldOfView = self.timelineEndCameraPose.fieldOfView
	self.camera.orthographicSize = self.timelineEndCameraPose.orthographicSize
end

function LotteryScene:blendTimelineCameraToDefault()
	local pose = self.timelineEndCameraPose

	if not pose or IsNil(self.camera) then
		self:resetCamera()

		return
	end

	self.timelineEndCameraPose = nil

	local camera = self.camera

	camera.transform.position = pose.position
	camera.transform.localRotation = pose.localRotation
	camera.fieldOfView = pose.fieldOfView
	camera.orthographicSize = pose.orthographicSize
	self._cameraBlending = true

	local serial = self.cameraBlendSerial
	local ease = CS.DG.Tweening.Ease.__CastFrom(1)

	DoTweenAnimMgr.GlobalMove(camera.transform, CAMERA_MOVE_TWEEN_ID, self.cameraPosition, CAMERA_BLEND_DURATION, 0, ease, nil, function()
		if self.cameraBlendSerial == serial then
			self:resetCamera()
		end
	end)
	DoTweenAnimMgr.Rotate(camera.transform, CAMERA_ROTATE_TWEEN_ID, self.cameraLocalEulerAngles, CAMERA_BLEND_DURATION, 0, ease, nil)
	DoTweenAnimMgr.Scalar(camera.transform, CAMERA_FOV_TWEEN_ID, pose.fieldOfView, self.cameraFieldOfView, CAMERA_BLEND_DURATION, 0, ease, function(value)
		if self.cameraBlendSerial == serial and NotNil(self.camera) then
			self.camera.fieldOfView = value
		end
	end)
	DoTweenAnimMgr.Scalar(camera.transform, CAMERA_ORTHOGRAPHIC_TWEEN_ID, pose.orthographicSize, self.cameraOrthographicSize, CAMERA_BLEND_DURATION, 0, ease, function(value)
		if self.cameraBlendSerial == serial and NotNil(self.camera) then
			self.camera.orthographicSize = value
		end
	end)
end

function LotteryScene:endTimelineCamera()
	self:releaseTimelineCamera()
	self:resetCamera()
end

function LotteryScene:resetCamera()
	self:stopCameraBlend()

	if IsNil(self.camera) then
		return
	end

	self.camera.gameObject:SetActiveEx(true)

	self.camera.enabled = self.cameraEnabled

	if self.cameraPosition then
		self.camera.transform.position = self.cameraPosition
	end

	if self.cameraRotation then
		self.camera.transform.rotation = self.cameraRotation
	end

	if self.cameraFieldOfView then
		self.camera.fieldOfView = self.cameraFieldOfView
	end

	if self.cameraOrthographicSize then
		self.camera.orthographicSize = self.cameraOrthographicSize
	end
end

function LotteryScene:onEntranceTimelineCreated(cutscene, timelineSerial)
	if timelineSerial ~= self._activeTimelineSerial or self._destroyed then
		return
	end

	self._entranceCutscene = cutscene

	local timelineContext = self._entranceTimelineContext
	local sourceEntity = timelineContext and timelineContext.sourceEntity
	local timelineEntity = timelineContext and timelineContext.timelineEntity

	if not sourceEntity or sourceEntity ~= self:getCurEntity() or IsNil(sourceEntity.eModel) or not timelineEntity or IsNil(timelineEntity.eModel) then
		self:stopEntranceTimeline()

		return
	end

	local presetData = self:getPresetData()
	local body = presetData and tonumber(presetData.body)
	local isFemale = body == nil or math.floor(body / 10) == 1

	cutscene.cutscene:SetGroupActiveWithName("BOY", not isFemale)
	cutscene.cutscene:SetGroupActiveWithName("GIRL", isFemale)
	sourceEntity.eModel:SetModelVisible(false)
	timelineEntity.eModel:SetModelVisible(true)

	if not self:beginTimelineCamera() then
		logger:error("抽奖入场 Timeline 无法接管场景相机, timeline=%s", tostring(self._entranceTimelineRes))
		self:stopEntranceTimeline()

		return
	end

	local rootObject = cutscene and cutscene.cutscene and cutscene.cutscene.rootObject

	if rootObject and NotNil(self.camera) then
		pgUtils.SetAllEffLodCamera(rootObject.transform, self.camera)
	end
end

function LotteryScene:destroyEntranceTimelineEntity(timelineContext)
	if not timelineContext or timelineContext.destroyed then
		return
	end

	timelineContext.destroyed = true

	local timelineEntity = timelineContext.timelineEntity

	timelineContext.timelineEntity = nil

	if timelineEntity then
		timelineEntity:destroy()
	end

	local sourceEntity = timelineContext.sourceEntity

	timelineContext.sourceEntity = nil

	if sourceEntity and sourceEntity == self:getCurEntity() and NotNil(sourceEntity.eModel) then
		sourceEntity.eModel:SetModelVisible(true)
	end
end

function LotteryScene:onEntranceTimelinePlayed(cutscene, timelineSerial)
	if timelineSerial ~= self._activeTimelineSerial or self._entranceCutscene ~= cutscene or not self.timelineRootGroup then
		if cutscene then
			pg.game.cutscene:stopCutscene(cutscene.id)
		end

		return
	end

	if self._entranceTimelinePlayedCallback then
		self._entranceTimelinePlayedCallback()
	end
end

function LotteryScene:onEntranceTimelineEnd(timelineSerial, timelineContext)
	if timelineSerial ~= self._activeTimelineSerial then
		self:destroyEntranceTimelineEntity(timelineContext)

		return
	end

	self._entranceCutscene = nil
	self._activeTimelineSerial = nil
	self._entranceTimelineContext = nil

	if self._entranceTimelineEndCallback then
		self._entranceTimelineEndCallback()
	end

	local cameraBlendSerial

	if self.timelineRootGroup then
		self:finishTimelineCamera()

		cameraBlendSerial = self.cameraBlendSerial
	else
		self:endTimelineCamera()
	end

	TimerManager.addNextFrameCb(function()
		self:destroyEntranceTimelineEntity(timelineContext)

		if self._destroyed or self._activeTimelineSerial then
			return
		end

		if cameraBlendSerial and self.cameraBlendSerial == cameraBlendSerial then
			self:blendTimelineCameraToDefault()
		end

		self:resetPreviewEntity()
	end)
end

function LotteryScene:playEntranceTimeline()
	local timelineRes = self._entranceTimelineRes

	if not timelineRes then
		return false
	end

	if not self._avatarReady then
		self._playEntranceOnAvatarReady = true

		return true
	end

	if not self.enable then
		self._playEntranceOnActive = true

		return true
	end

	self._playEntranceOnActive = false

	if IsNil(self.camera) or IsNil(self.entityRootTransform) then
		logger:error("抽奖入场 Timeline 播放条件不足, timeline=%s", tostring(timelineRes))

		return false
	end

	self:stopEntranceTimeline()

	self._timelineSerial = (self._timelineSerial or 0) + 1

	local timelineSerial = self._timelineSerial

	self._activeTimelineSerial = timelineSerial

	local sourceEntity = self:getCurEntity()

	if not sourceEntity or IsNil(sourceEntity.eModel) then
		self._activeTimelineSerial = nil

		return false
	end

	local timelineEntity = ClientVirtualEntityUtils.copySimpleVirtualPlayerFrom({
		isIgnoreEffectLod = true,
		syncLoad = true,
		copyEntity = sourceEntity
	})

	if not timelineEntity or IsNil(timelineEntity.eModel) then
		self._activeTimelineSerial = nil

		return false
	end

	timelineEntity.eModel:SetTransformParent(self.entityRootTransform, false)
	timelineEntity.eModel:SetTransformLocalPosition()
	timelineEntity.eModel:SetTransformLocalRotation(0, 0, 0, 1)
	timelineEntity.eModel:SetTransformLocalScale()

	timelineEntity.eModel.enableCameraHitCheck = false

	timelineEntity:setDisableEffectLod(true)
	timelineEntity.eModel:SetModelVisible(false)

	local timelineContext = {
		sourceEntity = sourceEntity,
		timelineEntity = timelineEntity
	}

	self._entranceTimelineContext = timelineContext

	local cutscene = pg.game.cutscene:playCutscene(self.name .. "EntranceTimeline" .. tostring(timelineSerial), timelineRes, self.entityRootTransform.position, self.entityRootTransform.rotation, nil, true, {
		applySoundListener = false,
		bindEntity = timelineEntity,
		createCallback = function(createdCutscene)
			self:onEntranceTimelineCreated(createdCutscene, timelineSerial)
		end,
		endCallback = function()
			self:onEntranceTimelineEnd(timelineSerial, timelineContext)
		end
	}, nil, function(playingCutscene)
		self:onEntranceTimelinePlayed(playingCutscene, timelineSerial)
	end)

	if not cutscene then
		self._activeTimelineSerial = nil
		self._entranceTimelineContext = nil

		self:destroyEntranceTimelineEntity(timelineContext)
		logger:error("抽奖入场 Timeline 创建失败, timeline=%s", tostring(timelineRes))

		return false
	end

	if self._activeTimelineSerial == timelineSerial then
		self._entranceCutscene = cutscene
	end

	return true
end

function LotteryScene:stopEntranceTimeline(blendCamera)
	local hadPendingTimeline = self._activeTimelineSerial ~= nil or self._playEntranceOnActive == true or self._playEntranceOnAvatarReady == true

	self._playEntranceOnActive = false
	self._playEntranceOnAvatarReady = false

	local cutscene = self._entranceCutscene
	local timelineContext = self._entranceTimelineContext
	local shouldBlendCamera = blendCamera == true and cutscene ~= nil and self.timelineRootGroup ~= nil and not self._destroyed

	self._entranceCutscene = nil
	self._entranceTimelineContext = nil
	self._activeTimelineSerial = nil

	local cameraBlendSerial

	if shouldBlendCamera then
		self:finishTimelineCamera()

		cameraBlendSerial = self.cameraBlendSerial
	end

	if cutscene then
		pg.game.cutscene:stopCutscene(cutscene.id)
	end

	self:destroyEntranceTimelineEntity(timelineContext)

	if cameraBlendSerial then
		TimerManager.addNextFrameCb(function()
			if self._destroyed or not self.enable or self._activeTimelineSerial or self.cameraBlendSerial ~= cameraBlendSerial then
				return
			end

			self:blendTimelineCameraToDefault()
		end)
	elseif not blendCamera or not self.timelineEndCameraPose and not self._cameraBlending then
		self:endTimelineCamera()
	end

	self:resetPreviewEntity()

	if hadPendingTimeline and self._entranceTimelineEndCallback then
		self._entranceTimelineEndCallback()
	end
end

function LotteryScene:onActiveChanged(active)
	if active then
		if self._playEntranceOnActive then
			self:playEntranceTimeline()
		end

		return
	end

	self:stopEntranceTimeline()
end

function LotteryScene:onDestroy()
	self._destroyed = true

	self:stopEntranceTimeline()

	self._playEntranceOnAvatarReady = false
	self._avatarReady = false

	self:destroyPreviewController()

	pg.game.avatar.eyeNormalFixEntity = nil

	if pg.global.avatarMgr then
		if pg.global.avatarMgr.ClearCachedAvatarCustomData then
			pg.global.avatarMgr:ClearCachedAvatarCustomData()
		end

		if pg.global.avatarMgr.ClearCachedAvatarHairCustomData then
			pg.global.avatarMgr:ClearCachedAvatarHairCustomData()
		end

		pg.global.avatarMgr:ClearAvatar()
		pg.global.avatarMgr:ClearRuntimeDataPool()
	end

	if pg.me then
		ClientModelUtils.refreshAvatarMakeup(pg.me)
	end

	self._entranceTimelineRes = nil
	self._entranceTimelinePlayedCallback = nil
	self._entranceTimelineEndCallback = nil
	self._previewAnimationKey = nil
	self.camera = nil
	self.cameraPosition = nil
	self.cameraRotation = nil
	self.cameraLocalEulerAngles = nil
	self.cameraFieldOfView = nil
	self.cameraOrthographicSize = nil
	self.cameraEnabled = nil
	self.entityRootTransform = nil
	self.objectReference = nil
end

return LotteryScene
