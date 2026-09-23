-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Scenes\\UIScenes\\AvatarScene.lua

local Class = require("Core.Framework.Class")
local GlobalData = require("Core.Client.GlobalData")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local AvatarCameraMode = require("GameApp.Camera.CameraMode.AvatarCameraMode")
local StudioFreeCameraMode = require("GameApp.Camera.CameraMode.PhotoCamera.StudioFreeCameraMode")
local CameraConst = require("GameApp.Camera.CameraConst")
local UISceneBase = require("GameApp.UIScene.UISceneBase")
local ClientStudioPlayerVirtualEntity = require("Entities.ClientStudioPlayerVirtualEntity")
local ClientStudioPetVirtualEntity = require("Entities.ClientStudioPetVirtualEntity")
local ClientStudioOrnamentVirtualEntity = require("Entities.ClientStudioOrnamentVirtualEntity")
local ClientSimpleVirtualPet = require("Entities.ClientSimpleVirtualPet")
local AvatarUtils = require("Guis.Utils.AvatarUtils")
local AudioConst = require("Const.AudioConst")
local ClientConst = require("Const.ClientConst")
local Const = require("Common.Const.Const")
local UIConst = require("Const.UIConst")
local Utils = require("Common.Utils.Utils")
local EModelUtils = require("Entities.Utils.EModelUtils")
local PlayableConst = require("Common.Const.PlayableConst")
local ClientModelUtils = require("Utils.ClientModelUtils")
local AppearanceEffectUtils = require("Utils.AppearanceEffectUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PhotographyStudioUtils = require("Utils.PhotographyStudioUtils")
local UIScenePreviewController = require("GameApp.Scenes.UIScenes.UIScenePreviewController")
local AppearanceData = require("Data.appearance_data")
local AppearanceVariableData = require("Data.appearance_variable_data")
local AppearancePointEnum = require("Data.appearance_point_enum")
local AvatarHairResIdToConfig = require("Data.avatar_hair_resId_to_config")
local AvatarHairSuitData = require("Data.avatar_hair_suit_data")
local AvatarPresetData = require("Data.avatar_preset_data")
local AppearanceAction = require("Data.appearance_action_data")
local AppearanceSuitData = require("Data.appearance_suit_data")
local AppearanceBackgroundData = require("Data.appearance_background_data")
local ColorJewelryData = require("Data.appearance_color_jewelry_data")
local AppearanceCustomOne = require("CustomTypes.AppearanceCustomOne")
local AvatarScene = Class.LightClass("AvatarScene", UISceneBase)
local PetData = require("Data.pet_data")
local PhotoOrnamentData = require("Data.photo_ornament_data")
local PetAppearanceAction = require("Data.pet_appearance_action_data")
local PetTransmogUtils = require("GameApp.PetTransmog.PetTransmogUtils")
local logger = require("Core.Log.LoggerManager").getLogger("Avatar")
local TimerManager = require("Core.Timer.TimerManager")
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")
local Vector3 = Vector3
local Quaternion = Quaternion
local GameConst = CS.FunPlus.WorldX.Const.GameConst
local avatarMgr = pg.global.avatarMgr
local fingerGestures = fingerGestures
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local STUDIO_PLAYER_LIGHT = "Alight01"
local STUDIO_CAMERA_VOLUME_PRIORITY = 6
local EMPTY_TABLE = {}
local READONLY_EMPTY_TABLE = require("Core.Common.EmptyTable")

AvatarScene.AREA = {
	BOTTOM = 20,
	MID = 0,
	TOP = -20
}
AvatarScene.GAMEPAD_PRESS = {
	SWIPE_MODEL = 0,
	CAMERA_ZOOM = 1
}
AvatarScene.SCROLL_DURATION = 0.1
AvatarScene.CAMERA = {
	PET = "pet",
	FIXED = "fixed",
	SIMPLE = "simple"
}
AvatarScene.CONFIG = {
	[11] = {
		maxZoomOffsetY = 0.8,
		maxZoom = 7,
		minZoom = 1.3,
		minZoomVerticalMoveScale = 0.25,
		minZoomOffsetY = {
			0.1,
			1.3
		},
		minZoomOffsetYSplit = {
			Hair = 1.3,
			Foot = 0.1,
			Thigh = 0.4,
			Waist = 0.8,
			Chest = 1.1
		},
		maxZoomOffsetYRange = {
			0.7,
			1
		}
	},
	[21] = {
		maxZoomOffsetY = 0.8,
		maxZoom = 7,
		minZoom = 1.3,
		minZoomVerticalMoveScale = 0.25,
		minZoomOffsetY = {
			0.1,
			1.4
		},
		minZoomOffsetYSplit = {
			Hair = 1.4,
			Foot = 0.1,
			Thigh = 0.4,
			Waist = 0.7,
			Chest = 1.1
		},
		maxZoomOffsetYRange = {
			0.7,
			1
		}
	}
}
AvatarScene.PET_CONFIG = {
	maxZoomOffsetY = 0.9,
	maxZoom = 10,
	minZoom = 2.5,
	scale = 1,
	defaultY = 0.5,
	defaultZoom = 10,
	minZoomOffsetY = {
		0.2,
		1.2
	}
}

function AvatarScene:onCtor()
	self.needShowAvatar = self.ctorParams and self.ctorParams.needShowAvatar
end

function AvatarScene:onStart()
	self.gestures = {}
	self.cameraModes = {}

	local themeStudioUid = pg.me and pg.me.themePhotographyStudioUid

	if themeStudioUid and tostring(themeStudioUid) ~= "" then
		self.currentPhotographyStudioUid = tostring(themeStudioUid)
	end

	self.objectReference = self.scene.transform:Find("Global"):GetComponent("ObjectReference")
	self.scene.transform.position = Vector3(0, 500, 0)
	self.camera = self.objectReference:GetRefValue("camera")
	self.cameraBG = self.objectReference:GetRefValue("cameraBG")
	self.cameraPlayer = self.objectReference:GetRefValue("cameraPlayer")
	self.cameraHeadIcon = self.objectReference:GetRefValue("cameraHeadIcon")

	self:resetAuxCameras()

	self.uI3DRoot = self.objectReference:GetRefValue("3DUIRoot")
	self.entityRootTransform = self.objectReference:GetRefValue("entityRootTransform")
	self.extraTransform = self.objectReference:GetRefValue("extraTransform")
	self.cameraVolumeTransform = self.objectReference:GetRefValue("cameraVolumeTransform")
	self.light01Transform = self.objectReference:GetRefValue("01Transform")
	self.light02Transform = self.objectReference:GetRefValue("02Transform")
	self.light03Transform = self.objectReference:GetRefValue("03Transform")
	self.light04Transform = self.objectReference:GetRefValue("04Transform")
	self.vitality101Transform = self.objectReference:GetRefValue("101Transform")
	self.vitality102Transform = self.objectReference:GetRefValue("102Transform")
	self.vitality103Transform = self.objectReference:GetRefValue("103Transform")
	self.vitality104Transform = self.objectReference:GetRefValue("104Transform")
	self.vitality105Transform = self.objectReference:GetRefValue("105Transform")
	self.vitality106Transform = self.objectReference:GetRefValue("106Transform")
	self.vitality107Transform = self.objectReference:GetRefValue("107Transform")
	self.stageLights = {}
	self.stageLights[1] = self.light01Transform
	self.stageLights[2] = self.light02Transform
	self.stageLights[3] = self.light03Transform
	self.stageLights[4] = self.light04Transform

	for i = 1, #self.stageLights do
		if self.stageLights[i] then
			self.stageLights[i].gameObject:SetActiveEx(false)
		end
	end

	self.vitalityBgs = {}
	self.vitalityBgs[1] = self.vitality101Transform
	self.vitalityBgs[2] = self.vitality102Transform
	self.vitalityBgs[3] = self.vitality103Transform
	self.vitalityBgs[4] = self.vitality104Transform
	self.vitalityBgs[5] = self.vitality105Transform
	self.vitalityBgs[6] = self.vitality106Transform
	self.vitalityBgs[7] = self.vitality107Transform

	for i = 1, #self.vitalityBgs do
		if self.vitalityBgs[i] then
			self.vitalityBgs[i].gameObject:SetActiveEx(false)
		end
	end

	self.nameObjectPool = {}
	self.previewSceneController = UIScenePreviewController.new(self)

	if pg.global.ui.login:checkUIOpen() then
		pg.global.ui.login:pauseVideo()
	end

	pg.game.input:setEnabledViewCtrl(false, ClientConst.ViewControl.APPEARANCE)
	pg.game.audio:playBgm("BGM_AppearanceSystem", AudioConst.BgmPriority.Avatar)
	self:initCameraModes()
	self:registerAutoSave()
	TimerManager.addTimer(15, function()
		pg.global.resMgr:StartStageWarmup(8000, "CreateRole", 5)
	end)

	self.pauseAutoSave = false
	self.cameraLookAtEnabled = false
	self.useAvatarCustomDataCache = false
	self.useAvatarHairCustomDataCache = false
end

function AvatarScene:onDestroy()
	self:disableStudioFreeCamera()
	self:unRegisterAutoSave()
	self:destroyPreviewController()
	self:clearStudioDisplayCameraMode()
	self:resetAuxCameras()

	self.useAvatarCustomDataCache = false
	self.useAvatarHairCustomDataCache = false

	if pg.global.avatarMgr and pg.global.avatarMgr.ClearCachedAvatarCustomData then
		pg.global.avatarMgr:ClearCachedAvatarCustomData()
	end

	if pg.global.avatarMgr and pg.global.avatarMgr.ClearCachedAvatarHairCustomData then
		pg.global.avatarMgr:ClearCachedAvatarHairCustomData()
	end

	pg.game.avatar.eyeNormalFixEntity = nil

	pg.global.avatarMgr:ClearAvatar()
	pg.global.avatarMgr:ClearRuntimeDataPool()

	if pg.me then
		local ClientModelUtils = require("Utils.ClientModelUtils")

		ClientModelUtils.refreshAvatarMakeup(pg.me)
	end

	pg.game.input:setEnabledViewCtrl(true, ClientConst.ViewControl.APPEARANCE)
	pg.global.ui:restoreAllUIByCustomKey(UIConst.UI_HIDE_KEY.APPEARANCE)

	if not pg.global.ui:checkUIOpen(UIConst.UI_ID_CREATE_ROLE_TIMELINE) then
		pg.game.audio:playBgm(nil, AudioConst.BgmPriority.Avatar)
	end

	if pg.global.ui.login:checkUIOpen() then
		pg.global.ui.login:resumeVideo()
		pg.global.ui.login:resetLoginState()
	end

	self.nameObjectPool = {}
	self.cameraModes = nil
	self.curEntityId = nil
	self.pressTimer = nil

	if self.curBgGo then
		pg.global.resMgr:RemoveInstanceToCache(self.curBgGo)
	end

	self.curBgGo = nil
	self.bgId = nil
	self.bgResId = nil
end

function AvatarScene:setVitalityBg(themeId)
	local index = themeId % 10

	for i = 1, #(self.vitalityBgs or {}) do
		if self.vitalityBgs[i] then
			self.vitalityBgs[i].gameObject:SetActiveEx(i == index)
		end
	end
end

function AvatarScene:setStageLight(index)
	if self.stageLights[index] then
		self.stageLights[index].gameObject:SetActiveEx(true)
	end
end

function AvatarScene:disableCamera()
	self.camera.enabled = false
end

function AvatarScene:resetAuxCameras()
	if self.cameraBG then
		self.cameraBG.targetTexture = nil

		self.cameraBG.gameObject:SetActiveEx(false)
	end

	if self.cameraPlayer then
		self.cameraPlayer.targetTexture = nil

		self.cameraPlayer.gameObject:SetActiveEx(false)
	end

	if self.cameraHeadIcon then
		self.cameraHeadIcon.targetTexture = nil

		self.cameraHeadIcon.gameObject:SetActiveEx(false)
	end
end

function AvatarScene:switchLight(noLogic)
	if self.curEntityId then
		local presetData = pg.game.avatar:getAvatarPresetData(self.curEntityId)

		if presetData then
			local body = presetData.body

			if body and math.floor(body / 10) == 1 then
				if self.girlLightTransform then
					self.girlLightTransform.gameObject:SetActiveEx(true)
				end

				if self.boyLightTransform then
					self.boyLightTransform.gameObject:SetActiveEx(false)
				end

				if self.pramonLightTransform then
					self.pramonLightTransform.gameObject:SetActiveEx(false)
				end
			else
				if self.girlLightTransform then
					self.girlLightTransform.gameObject:SetActiveEx(false)
				end

				if self.boyLightTransform then
					self.boyLightTransform.gameObject:SetActiveEx(true)
				end

				if self.pramonLightTransform then
					self.pramonLightTransform.gameObject:SetActiveEx(false)
				end
			end
		end

		local petData = PetData[self.curEntityId]

		if petData then
			if self.girlLightTransform then
				self.girlLightTransform.gameObject:SetActiveEx(false)
			end

			if self.boyLightTransform then
				self.boyLightTransform.gameObject:SetActiveEx(false)
			end

			if self.pramonLightTransform then
				self.pramonLightTransform.gameObject:SetActiveEx(true)
			end
		end

		if not noLogic then
			local studioUid = self.currentPhotographyStudioUid

			if studioUid then
				if self:applyPhotographyStudioDisplayPreset(studioUid) then
					return
				end

				self:clearPhotographyStudioDisplayPreset()
				AvatarUtils.setThemePhotographyStudioUid("")
			end

			local bgRes, bgId = AvatarUtils.getCurSetBgRes(Const.APPEARANCE_BACKGROUND_TYPE.Player)

			self:setBackground(bgRes, bgId)
		end
	end
end

function AvatarScene:initCameraModes()
	if self.dontSetCamera then
		return
	end

	AvatarScene.super.initCameraModes(self)
end

function AvatarScene:getPreviewCurrentEntity()
	return self:getCurEntity()
end

function AvatarScene:getPreviewCameraRootTransform()
	return self.entityRootTransform
end

function AvatarScene:getPreviewCameraConfig(modeName)
	local cameraConfig = {}
	local presetData = pg.game.avatar:getAvatarPresetData(self.curEntityId) or {}
	local body = presetData.body or 11

	if modeName == self.CAMERA.SIMPLE then
		cameraConfig = Utils.deepCopyTable(self.CONFIG[body])
	elseif modeName == self.CAMERA.FIXED then
		cameraConfig = Utils.deepCopyTable(self.CONFIG[body])
		cameraConfig.minZoom = self.CONFIG[body].maxZoom
		cameraConfig.minZoomOffsetY = Vector2.New(self.CONFIG[body].maxZoomOffsetY, self.CONFIG[body].maxZoomOffsetY)
		cameraConfig.maxZoomOffsetY = self.CONFIG[body].maxZoomOffsetY
		cameraConfig.defaultZoom = self.CONFIG[body].maxZoom
		cameraConfig.defaultY = self.CONFIG[body].maxZoomOffsetY
	elseif modeName == self.CAMERA.PET then
		cameraConfig = self.PET_CONFIG
	else
		cameraConfig = nil
	end

	return cameraConfig
end

function AvatarScene:rotatePreviewEntity(deltaAngle)
	if self.studioFreeCameraMode then
		return
	end

	local entity = self:getCurEntity()

	if entity and entity.eModel then
		entity.eModel:RotateAroundTransform(deltaAngle)
	end
end

function AvatarScene:getPreviewDefaultModeName()
	return self.CAMERA.SIMPLE
end

function AvatarScene:getPreviewInitSpringArmLen()
	return 7
end

function AvatarScene:getPreviewInitVerticalOffset()
	return 0.8
end

function AvatarScene:adjustCameraConfigByBodySize()
	if not self.curCameraMode then
		return
	end

	local entity = self:getCurEntity()

	if not entity then
		return
	end

	local bodySize = entity:getModelScale()
	local cameraConfig = {}
	local presetData = pg.game.avatar:getAvatarPresetData(self.curEntityId) or {}
	local body = presetData.body or 11

	cameraConfig = Utils.deepCopyTable(self.CONFIG[body])
	cameraConfig.minZoomOffsetY = {
		cameraConfig.minZoomOffsetY[1],
		cameraConfig.minZoomOffsetY[2] * bodySize
	}
	cameraConfig.minZoomOffsetYSplit = {
		Hair = cameraConfig.minZoomOffsetYSplit.Hair * bodySize,
		Chest = cameraConfig.minZoomOffsetYSplit.Chest,
		Waist = cameraConfig.minZoomOffsetYSplit.Waist * bodySize,
		Thigh = cameraConfig.minZoomOffsetYSplit.Thigh,
		Foot = cameraConfig.minZoomOffsetYSplit.Foot
	}

	self.curCameraMode:resetAvatarCamera(self.entityRootTransform, cameraConfig)
end

function AvatarScene:saveCameraState(slot)
	if not self.curCameraMode then
		return nil
	end

	self.cameraStateSlots = self.cameraStateSlots or {}

	local state = self.curCameraMode:getCameraState()

	self.cameraStateSlots[slot or "default"] = state

	return state
end

function AvatarScene:restoreCameraState(slot)
	if not self.curCameraMode then
		return
	end

	self.cameraStateSlots = self.cameraStateSlots or {}

	local state = self.cameraStateSlots[slot or "default"]

	if state then
		self.curCameraMode:applyCameraState(state)
	end
end

function AvatarScene:applyCameraState(state)
	if not self.curCameraMode or not state then
		return
	end

	self.curCameraMode:applyCameraState(state)
end

function AvatarScene:getCameraState()
	if not self.curCameraMode then
		return nil
	end

	return self.curCameraMode:getCameraState()
end

function AvatarScene:setStudioCameraVolumeActive(active)
	self.studioCameraVolumeChangeId = (self.studioCameraVolumeChangeId or 0) + 1

	local changeId = self.studioCameraVolumeChangeId

	if active then
		local volume = self.cameraVolumeTransform:GetComponent(typeof(CS.UnityEngine.Rendering.Volume))

		if self.studioCameraVolumeOriginalPriority == nil then
			self.studioCameraVolumeOriginalPriority = volume.priority
		end

		volume.priority = STUDIO_CAMERA_VOLUME_PRIORITY

		self.cameraVolumeTransform.gameObject:SetActiveEx(true)

		return
	end

	TimerManager.addNextFrameCb(function()
		TimerManager.addNextFrameCb(function()
			if self.studioCameraVolumeChangeId ~= changeId or self.studioFreeCameraMode or self.studioDisplayCameraMode or IsNil(self.cameraVolumeTransform) then
				return
			end

			self.cameraVolumeTransform.gameObject:SetActiveEx(false)

			if self.studioCameraVolumeOriginalPriority ~= nil then
				local volume = self.cameraVolumeTransform:GetComponent(typeof(CS.UnityEngine.Rendering.Volume))

				volume.priority = self.studioCameraVolumeOriginalPriority
				self.studioCameraVolumeOriginalPriority = nil
			end
		end)
	end)
end

function AvatarScene:setStudioOutlineVolumeActive(active)
	if not self.studioOutlineVolumeComponent then
		if not active then
			return
		end

		local volume = self.cameraVolumeTransform:GetComponent(typeof(CS.UnityEngine.Rendering.Volume))
		local profile = volume.profile

		self.studioOutlineVolumeComponent = profile:Add(typeof(CS.XRender.Modules.PostProcess.Components.FluoroscopyComponent), true)
	end

	self.studioOutlineVolumeComponent.active = active
end

function AvatarScene:enableStudioFreeCamera()
	if self.studioFreeCameraMode then
		self.studioFreeCameraMode:setActive(true)

		return
	end

	self:clearStudioDisplayCameraMode()

	if IsNil(self.entityRootTransform) then
		return
	end

	local stackObj = CS.UnityEngine.GameObject("StudioFreeStackObj")

	stackObj.transform:SetParent(self.entityRootTransform, false)

	stackObj.transform.localPosition = Vector3.zero

	local rigidbody = stackObj:AddComponent(typeof(CS.UnityEngine.Rigidbody))

	rigidbody.useGravity = false
	rigidbody.constraints = 112
	rigidbody.isKinematic = true
	self.studioFreeStackObj = stackObj

	self:setStudioCameraVolumeActive(true)

	local mode = StudioFreeCameraMode.new()

	pg.game.camera:addUICamera(mode, CameraConst.PRIORITY_PHOTO)
	mode:setFollowTransform(stackObj.transform)

	self.studioFreeCameraMode = mode

	local entity = self:getCurEntity()

	mode:initPhotoCamera(self.camera, entity and entity.eModel and entity.eModel.transform)
	self:snapshotStudioDefaultPose()
	self:resetStudioFreeCameraToDefault()

	if self.curCameraMode then
		self.curCameraMode:setActive(false)
	end

	mode:setActive(true)
end

function AvatarScene:snapshotStudioDefaultPose()
	if self.camera and not IsNil(self.camera) then
		local camTrans = self.camera.transform
		local pos = camTrans.position
		local rot = camTrans.eulerAngles

		self.studioDefaultPose = {
			pos = {
				x = pos.x,
				y = pos.y,
				z = pos.z
			},
			rot = {
				x = rot.x,
				y = rot.y,
				z = rot.z
			},
			fov = self.curCameraMode and self.curCameraMode.cameraMode and self.curCameraMode.cameraMode.fieldOfView or nil
		}
	end
end

function AvatarScene:resetStudioFreeCameraToDefault()
	local mode = self.studioFreeCameraMode

	if not mode then
		return
	end

	if not self.studioDefaultPose then
		self:snapshotStudioDefaultPose()
	end

	local snap = self.studioDefaultPose

	if snap then
		mode:asyncTrans(snap.pos.x, snap.pos.y, snap.pos.z, snap.rot.x, snap.rot.y, snap.rot.z)

		if snap.fov then
			mode:zoom(snap.fov)
		end
	end
end

function AvatarScene:disableStudioFreeCamera()
	if self.studioFreeCameraMode then
		PhotographyStudioUtils.applyPostProcessingToCamera(self.studioFreeCameraMode, nil)
		PhotographyStudioUtils.applyLightingToCamera(self.studioFreeCameraMode, nil)
		self:setStudioPlayerDefaultLight(true)
		self.studioFreeCameraMode:releaseCameraLights()
		pg.game.camera:removeUICamera(self.studioFreeCameraMode)

		self.studioFreeCameraMode = nil
	end

	if self.studioFreeStackObj and not IsNil(self.studioFreeStackObj) then
		CS.UnityEngine.Object.Destroy(self.studioFreeStackObj)
	end

	self.studioFreeStackObj = nil
	self.studioDefaultPose = nil

	if not self.studioDisplayCameraMode then
		self:setStudioCameraVolumeActive(false)
	end

	if self.curCameraMode then
		self.curCameraMode:setActive(true)
	end
end

function AvatarScene:setStudioFreeCameraPose(pos, rot)
	if not self.studioFreeCameraMode or not pos or not rot then
		return
	end

	self.studioFreeCameraMode:setFollowLocalPose(pos, rot)
end

function AvatarScene:getStudioFreeCameraPose()
	if not self.studioFreeCameraMode then
		return nil, nil
	end

	return self.studioFreeCameraMode:getFollowLocalPose()
end

function AvatarScene:moveStudioFreeCamera(x, y, z)
	if self.studioFreeCameraMode then
		self.studioFreeCameraMode:move(x, y, z)
	end
end

function AvatarScene:rotateStudioFreeCamera(x, y)
	if self.studioFreeCameraMode then
		self.studioFreeCameraMode:rotate(x, y)
	end
end

function AvatarScene:setStudioFreeCameraMoveRange(bottomRadius, topRadius, height, minHeight)
	if not self.studioFreeCameraMode then
		return
	end

	local entity = self:getCurEntity()

	if not entity or not entity.eModel then
		return
	end

	self.studioFreeCameraMode:setMoveRange(entity.eModel.transform, bottomRadius or AppearanceVariableData.STUDIO_CAMERA_ADJUST_BOTTOM, topRadius or AppearanceVariableData.STUDIO_CAMERA_ADJUST_TOP, height or AppearanceVariableData.STUDIO_CAMERA_ADJUST_HEIGHT, minHeight)
end

function AvatarScene:applyStudioCameraCommon(common, ignoreUnlock)
	self:applyPhotographyStudioBackgroundLight(common and common.backgroundId, self.studioFreeCameraMode)

	local hasStudioLight = PhotographyStudioUtils.applyCommonToCamera(self.studioFreeCameraMode, common, ignoreUnlock)

	self:setStudioPlayerDefaultLight(not hasStudioLight)
end

function AvatarScene:applyPhotographyStudioBackgroundLight(bgId, mode)
	mode = mode or self.studioFreeCameraMode

	local cameraMode = mode and mode.cameraMode

	if not cameraMode or not cameraMode.SetUseWorldLightIntensity then
		return
	end

	local backgroundId = tonumber(bgId)
	local backgroundData = backgroundId and AppearanceBackgroundData[backgroundId]

	cameraMode:SetUseWorldLightIntensity(backgroundData and backgroundData.light == 1 or false)
end

function AvatarScene:setStudioPlayerDefaultLight(enable)
	local entity = self:getCurEntity()

	if not entity or not entity.eModel then
		return
	end

	if enable then
		pgUtils.EnablePlayerLight(entity.eModel, STUDIO_PLAYER_LIGHT)
	else
		pgUtils.DisablePlayerLight(entity.eModel, STUDIO_PLAYER_LIGHT)
	end
end

local function getPhotographyStudioUidKey(uid)
	if uid == nil then
		return nil
	end

	return tostring(uid)
end

function AvatarScene:getCurrentPhotographyStudioUid()
	return self.currentPhotographyStudioUid
end

function AvatarScene:setCurrentPhotographyStudioUid(studioUid)
	self.currentPhotographyStudioUid = studioUid
end

function AvatarScene:getPhotographyStudioMemberSet(studioUid)
	local result = {}
	local info = pg.me and pg.me:getStudioInfo(studioUid)

	if not info then
		return result
	end

	if info.masterUid then
		result[getPhotographyStudioUidKey(info.masterUid)] = true
	end

	for _, member in ipairs(info.members or READONLY_EMPTY_TABLE) do
		if member.uid then
			result[getPhotographyStudioUidKey(member.uid)] = true
		end
	end

	return result
end

function AvatarScene:applyPhotographyStudioDisplayPostProcessing(common)
	self:setStudioCameraVolumeActive(true)

	local mode = self.studioFreeCameraMode

	if not mode then
		mode = self.studioDisplayCameraMode

		if not mode then
			mode = StudioFreeCameraMode.new()

			mode:setActive(false)
			pg.game.camera:addUICamera(mode, CameraConst.PRIORITY_DEFAULT)

			local entity = self:getCurEntity()

			mode:initPhotoCamera(self.camera, entity and entity.eModel and entity.eModel.transform)

			self.studioDisplayCameraMode = mode
		end
	end

	self:applyPhotographyStudioBackgroundLight(common and common.backgroundId, mode)
	PhotographyStudioUtils.applyPostProcessingToCamera(mode, common)

	local hasStudioLight = PhotographyStudioUtils.applyLightingToCamera(mode, common)

	self:setStudioPlayerDefaultLight(not hasStudioLight)
end

function AvatarScene:clearStudioDisplayCameraMode()
	if self.studioDisplayCameraMode then
		self.studioDisplayCameraMode:releaseCameraLights()
		pg.game.camera:removeUICamera(self.studioDisplayCameraMode)

		self.studioDisplayCameraMode = nil
	end
end

function AvatarScene:setPhotographyStudioCharactersVisible(visible)
	self.photographyStudioCharactersVisible = visible

	if not visible then
		self:setStudioPlayerVisible(self:getCurEntityId(), true)
		self:clearStudioPlayers()
		self:clearStudioPets()
	end
end

function AvatarScene:applyPhotographyStudioFullPreview(studioUid, content, options)
	if type(content) ~= "table" then
		content = EMPTY_TABLE
	end

	if type(options) ~= "table" then
		options = EMPTY_TABLE
	end

	local common = PhotographyStudioUtils.ensureInitialCameraPreset(content)

	if type(common) ~= "table" then
		common = EMPTY_TABLE
	end

	local players = content.players

	if type(players) ~= "table" then
		players = EMPTY_TABLE
	end

	local masterUid = content.masterUid

	if masterUid == nil and pg.me then
		masterUid = pg.me:getStudioMasterUid(studioUid)
	end

	local masterUidKey = getPhotographyStudioUidKey(masterUid)
	local mainPlayerUidKey = getPhotographyStudioUidKey(options.mainPlayerUid)
	local mainEntityId = options.mainEntityId
	local showAllPlayers = options.showAllPlayers == true
	local memberSet = options.memberSet

	if type(memberSet) ~= "table" then
		memberSet = self:getPhotographyStudioMemberSet(studioUid)
	end

	local mainData, mainContentUid

	for uid, data in pairs(players) do
		if getPhotographyStudioUidKey(uid) == mainPlayerUidKey then
			mainData = data
			mainContentUid = uid

			break
		end
	end

	local function canDisplayPlayer(uid)
		local uidKey = getPhotographyStudioUidKey(uid)

		if showAllPlayers then
			return true
		end

		return uidKey and (uidKey == mainPlayerUidKey or memberSet[uidKey] == true)
	end

	self.currentPhotographyStudioUid = studioUid
	self.photographyStudioDisplayRequestId = (self.photographyStudioDisplayRequestId or 0) + 1

	local requestId = self.photographyStudioDisplayRequestId

	self:setPhotographyStudioCharactersVisible(true)

	local bgRes, bgId = AvatarUtils.getPhotographyStudioBackgroundRes(common.backgroundId)

	self:setBackground(bgRes, bgId)
	self:enableStudioFreeCamera()

	if mainEntityId then
		if type(mainData) == "table" then
			self:setStudioEntityLocalPos(mainEntityId, mainData.playerPos)
			self:setStudioEntityLocalRotY(mainEntityId, mainData.playerRot and mainData.playerRot.y)
		else
			self:setStudioEntityLocalPos(mainEntityId, Vector3.zero)
			self:setStudioEntityLocalRotY(mainEntityId, 0)
		end

		self:applyStudioPlayerPose(mainEntityId, mainData and mainData.playerPoseId or common.playerPoseId)
		self:applyStudioPlayerGaze(mainEntityId, mainData and mainData.gazeType or common.gazeType, mainData and mainData.gazePos or common.gazePos)
		self:setStudioPlayerVisible(mainEntityId, not mainData or mainData.visible ~= false)
	end

	local studioPlayers = {}

	for uid, data in pairs(players) do
		local isMainPlayer = getPhotographyStudioUidKey(uid) == mainPlayerUidKey

		if type(data) == "table" and canDisplayPlayer(uid) and (not isMainPlayer or not mainEntityId) then
			studioPlayers[#studioPlayers + 1] = {
				uid = uid,
				templateId = data.templateId,
				avatarPresetKey = data.avatarPresetKey,
				avatarConfig = data.avatarConfig,
				curShow = data.curShow,
				jewelryLastInfos = data.jewelryLastInfos,
				model = data.model,
				appearance = data.appearance,
				pos = data.playerPos,
				rot = data.playerRot and data.playerRot.y,
				playerPoseId = data.playerPoseId,
				gazeType = data.gazeType or common.gazeType,
				gazePos = data.gazePos or common.gazePos,
				visible = data.visible
			}
		end
	end

	local stableLightTargetEntity = mainEntityId and self:getEntity(mainEntityId)

	if stableLightTargetEntity and stableLightTargetEntity.eModel then
		self.studioFreeCameraMode:initPhotoCamera(self.camera, stableLightTargetEntity.eModel.transform)
	end

	self:syncStudioPlayers(studioPlayers, function(entity)
		if requestId ~= self.photographyStudioDisplayRequestId or getPhotographyStudioUidKey(self.currentPhotographyStudioUid) ~= getPhotographyStudioUidKey(studioUid) or not self.studioFreeCameraMode or getPhotographyStudioUidKey(entity.studioPlayerUid) ~= masterUidKey or not entity.eModel then
			return
		end

		self.studioFreeCameraMode:initPhotoCamera(self.camera, entity.eModel.transform)
		self:applyStudioCameraCommon(common, options.ignoreUnlock == true)
	end)

	local mainEntity

	if not mainEntityId and mainContentUid ~= nil then
		mainEntity = self:getEntity(mainContentUid)

		if mainEntity and options.useMainPlayerAsCurrent == true then
			self.curEntityId = mainContentUid
		end
	elseif mainEntityId then
		mainEntity = self:getEntity(mainEntityId)
	end

	local studioPets = {}

	for uid, data in pairs(players) do
		if type(data) == "table" and canDisplayPlayer(uid) and type(data.pets) == "table" then
			local ownerUid = getPhotographyStudioUidKey(uid)

			for _, petData in ipairs(data.pets) do
				if petData.petId then
					studioPets[#studioPets + 1] = {
						petId = petData.petId,
						ownerUid = ownerUid,
						pos = petData.pos,
						rotY = petData.rotY,
						petData = petData
					}
				end
			end
		end
	end

	self:syncStudioPets(studioPets)
	self:syncStudioOrnaments(common.ornaments, masterUid)

	local lightTargetEntity

	if masterUidKey == mainPlayerUidKey then
		lightTargetEntity = mainEntity
	else
		for uid, _ in pairs(players) do
			if getPhotographyStudioUidKey(uid) == masterUidKey then
				lightTargetEntity = self:getEntity(uid)

				break
			end
		end
	end

	if lightTargetEntity and lightTargetEntity.eModel then
		self.studioFreeCameraMode:initPhotoCamera(self.camera, lightTargetEntity.eModel.transform)
	end

	if common.cameraPos and common.cameraRot then
		self:setStudioFreeCameraPose(common.cameraPos, common.cameraRot)
	else
		self:resetStudioFreeCameraToDefault()
	end

	self:applyStudioCameraCommon(common, options.ignoreUnlock == true)

	return common, mainData, mainEntity
end

function AvatarScene:applyPhotographyStudioDisplayPreset(studioUid)
	if not AvatarUtils.canUsePhotographyStudio(studioUid) then
		return false
	end

	self.currentPhotographyStudioUid = studioUid
	self.photographyStudioDisplayRequestId = (self.photographyStudioDisplayRequestId or 0) + 1

	local requestId = self.photographyStudioDisplayRequestId
	local content = pg.me:getCachedPhotographyStudioContent(studioUid)

	if content then
		self:applyPhotographyStudioDisplayContent(studioUid, content)

		return true
	end

	pg.me:fetchStudioContent(studioUid, function(fetched, ok)
		if requestId ~= self.photographyStudioDisplayRequestId or getPhotographyStudioUidKey(self.currentPhotographyStudioUid) ~= getPhotographyStudioUidKey(studioUid) then
			return
		end

		if ok then
			self:applyPhotographyStudioDisplayContent(studioUid, fetched or {})
		end
	end)

	return true
end

function AvatarScene:applyPhotographyStudioDisplayContent(studioUid, content)
	if getPhotographyStudioUidKey(self.currentPhotographyStudioUid) ~= getPhotographyStudioUidKey(studioUid) then
		return
	end

	content = content or {}

	local common = content.common or {}
	local players = content.players or {}
	local bgRes, bgId = AvatarUtils.getPhotographyStudioBackgroundRes(common.backgroundId)

	self:setBackground(bgRes, bgId)
	self:applyPhotographyStudioDisplayPostProcessing(common)
	self:clearStudioPlayers()

	if self.photographyStudioCharactersVisible == false then
		self:clearStudioPets()
	else
		local selfUidKey = getPhotographyStudioUidKey(pg.me.uid)
		local memberSet = self:getPhotographyStudioMemberSet(studioUid)
		local studioPets = {}

		for uid, data in pairs(players) do
			local uidKey = getPhotographyStudioUidKey(uid)
			local isCurrentMember = uidKey and (uidKey == selfUidKey or memberSet[uidKey])

			if type(data) == "table" and isCurrentMember and type(data.pets) == "table" then
				for _, petData in ipairs(data.pets) do
					if petData.petId then
						studioPets[#studioPets + 1] = {
							petId = petData.petId,
							ownerUid = uidKey,
							pos = petData.pos,
							rotY = petData.rotY,
							petData = petData
						}
					end
				end
			end
		end

		self:syncStudioPets(studioPets)
	end

	self:syncStudioOrnaments(common.ornaments, content.masterUid or pg.me:getStudioMasterUid(studioUid))
end

function AvatarScene:clearPhotographyStudioDisplayPreset()
	self.currentPhotographyStudioUid = nil
	self.photographyStudioDisplayRequestId = (self.photographyStudioDisplayRequestId or 0) + 1

	self:clearStudioPlayers()
	self:clearStudioPets()
	self:clearStudioOrnaments()
	self:setStudioPlayerVisible(self:getCurEntityId(), true)
	self:applyStudioPlayerGaze(self:getCurEntityId(), nil)
	self:applyPhotographyStudioDisplayPostProcessing(nil)
	self:clearStudioDisplayCameraMode()

	if not self.studioFreeCameraMode then
		self:setStudioCameraVolumeActive(false)
	end
end

local function toNumberIfPossible(value)
	return tonumber(value) or value
end

local function getAvatarPresetKeyByTemplateId(templateId)
	if not templateId then
		return nil
	end

	templateId = toNumberIfPossible(templateId)

	for presetKey, presetData in pairs(AvatarPresetData) do
		if presetData.templateId == templateId then
			return presetKey
		end
	end

	return nil
end

local function resolveStudioPlayerModelData(data)
	local model = type(data.model) == "table" and data.model or {}
	local avatarPresetKey = toNumberIfPossible(data.avatarPresetKey or model.avatarPresetKey)
	local templateId = toNumberIfPossible(data.templateId or model.templateId)

	if not avatarPresetKey or not pg.game.avatar:getAvatarPresetData(avatarPresetKey) then
		avatarPresetKey = getAvatarPresetKeyByTemplateId(templateId)
	end

	local presetData = avatarPresetKey and pg.game.avatar:getAvatarPresetData(avatarPresetKey)

	if not presetData then
		return nil
	end

	if not templateId or templateId == 0 then
		templateId = presetData.templateId
	end

	local curShowData

	if type(data.curShow) == "table" then
		curShowData = PhotographyStudioUtils.deserializeJsonSafeTable(data.curShow)
	else
		curShowData = {
			customShow = {},
			hairInfo = {},
			clothesDesigns = {}
		}
	end

	local jewelryLastInfos

	if type(data.jewelryLastInfos) == "table" then
		jewelryLastInfos = PhotographyStudioUtils.deserializeJsonSafeTable(data.jewelryLastInfos)
	else
		jewelryLastInfos = {}
	end

	return {
		templateId = templateId,
		avatarPresetKey = avatarPresetKey,
		avatarConfig = data.avatarConfig or model.avatarConfig,
		curShow = AppearanceCustomOne(curShowData),
		jewelryLastInfos = jewelryLastInfos
	}
end

function AvatarScene:applyStudioPlayerReadyState(uid, entity, data, onLoaded)
	if self:getEntity(uid) ~= entity then
		return
	end

	if data.curShow and entity.curShow then
		for partId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
			ClientModelUtils.applyHairCustomData(entity, entity.curShow, partId)
		end
	end

	if entity.studioPlayerPoseId ~= data.playerPoseId then
		self:applyStudioPlayerPose(uid, data.playerPoseId)
	end

	self:applyStudioPlayerGaze(uid, data.gazeType, data.gazePos)
	self:setStudioPlayerVisible(uid, data.visible ~= false)

	if onLoaded then
		onLoaded(entity)
	end
end

function AvatarScene:setStudioPlayerVisible(entityId, visible)
	local entity = entityId and self:getEntity(entityId)

	if not entity then
		return
	end

	visible = visible ~= false
	entity.studioPlayerVisible = visible

	entity:setVisible(ClientConst.MODEL_VISIBLE_KEY.DEFAULT, visible)
end

function AvatarScene:isStudioPlayerVisible(entityId)
	local entity = entityId and self:getEntity(entityId)

	return entity ~= nil and entity.studioPlayerVisible ~= false
end

function AvatarScene:applyStudioPlayerAppearanceAndState(uid, entity, appearanceMap, force, data, onLoaded)
	if not entity.applyAppearanceMap then
		self:applyStudioPlayerReadyState(uid, entity, data, onLoaded)

		return
	end

	entity.pendingStudioPlayerReadyData = data
	entity.pendingStudioPlayerReadyCallback = onLoaded

	if entity.studioPlayerAnimatorReadyPending then
		entity:applyAppearanceMap(appearanceMap, force)

		return
	end

	local previousCallback = entity.onAnimatorReadyCallback
	local readyCallback

	function readyCallback()
		if previousCallback then
			previousCallback(entity)
		end

		entity.studioPlayerAnimatorReadyPending = nil

		local readyData = entity.pendingStudioPlayerReadyData
		local readyOnLoaded = entity.pendingStudioPlayerReadyCallback

		entity.pendingStudioPlayerReadyData = nil
		entity.pendingStudioPlayerReadyCallback = nil

		if readyData then
			self:applyStudioPlayerReadyState(uid, entity, readyData, readyOnLoaded)
		end
	end

	entity.studioPlayerAnimatorReadyPending = true
	entity.onAnimatorReadyCallback = readyCallback

	if entity:applyAppearanceMap(appearanceMap, force) then
		return
	end

	entity.studioPlayerAnimatorReadyPending = nil
	entity.pendingStudioPlayerReadyData = nil
	entity.pendingStudioPlayerReadyCallback = nil

	if entity.onAnimatorReadyCallback == readyCallback then
		entity.onAnimatorReadyCallback = previousCallback
	end

	self:applyStudioPlayerReadyState(uid, entity, data, onLoaded)
end

function AvatarScene:spawnStudioPlayer(uid, data, onLoaded)
	if not uid or not data then
		return nil
	end

	self.studioPlayerIds = self.studioPlayerIds or {}

	local appearanceMap = PhotographyStudioUtils.appearanceArrayToMap(data.appearance)
	local modelData = resolveStudioPlayerModelData(data)

	if not modelData then
		return nil
	end

	PhotographyStudioUtils.applyAppearanceMapToCurShow(modelData.curShow, appearanceMap)

	local existing = self:getEntity(uid)

	if existing and (existing.templateId ~= modelData.templateId or existing.avatarPresetKey ~= modelData.avatarPresetKey) then
		self:removeStudioPlayer(uid)

		existing = nil
	end

	if existing then
		self:showEntityWithId(uid)

		local avatarConfigChanged = existing.updateAvatarConfig and existing:updateAvatarConfig(modelData.avatarConfig)
		local customAppearanceChanged = existing.updateStudioCustomAppearance and existing:updateStudioCustomAppearance(modelData.curShow, modelData.jewelryLastInfos)

		self:setStudioEntityLocalPos(uid, data.pos)
		self:setStudioEntityLocalRotY(uid, data.rot)
		self:applyStudioPlayerAppearanceAndState(uid, existing, appearanceMap, avatarConfigChanged or customAppearanceChanged, data, onLoaded)

		return existing
	end

	local initDict = {
		templateId = modelData.templateId,
		avatarPresetKey = modelData.avatarPresetKey,
		avatarConfig = modelData.avatarConfig,
		curShow = modelData.curShow,
		jewelryLastInfos = modelData.jewelryLastInfos,
		studioPlayerUid = uid,
		ownerUid = uid,
		appearanceMap = appearanceMap,
		studioModelRefreshedCallback = onLoaded
	}
	local entity = self:createEntity(uid, ClientStudioPlayerVirtualEntity, initDict)

	self.studioPlayerIds[uid] = true

	entity.eModel:SetTransformParent(self.entityRootTransform, false)

	entity.eModel.enableCameraHitCheck = false

	entity:setDisableEffectLod(true)
	self:setStudioEntityLocalPos(uid, data.pos)
	self:setStudioEntityLocalRotY(uid, data.rot)
	self:setStudioPlayerVisible(uid, data.visible ~= false)

	function entity.modelPartModelAllLoaded()
		entity.modelPartModelAllLoaded = nil

		self:applyStudioPlayerAppearanceAndState(uid, entity, appearanceMap, true, data, onLoaded)
	end

	return entity
end

function AvatarScene:removeStudioPlayer(uid)
	if not uid then
		return
	end

	if self.studioPlayerPoseStates and self.studioPlayerPoseStates[uid] then
		self.studioPlayerPoseStates[uid]:SetLogicLoop(false)

		self.studioPlayerPoseStates[uid] = nil
	end

	self:removeEntity(uid)

	if self.studioPlayerIds then
		self.studioPlayerIds[uid] = nil
	end
end

function AvatarScene:syncStudioPlayers(players, onLoaded, refreshUidSet)
	if self.photographyStudioCharactersVisible == false then
		self:clearStudioPlayers()

		return
	end

	self.studioPlayerIds = self.studioPlayerIds or {}

	local keepUids = {}

	if type(players) == "table" then
		for _, data in ipairs(players) do
			local uid = data and data.uid

			if uid then
				local uidKey = getPhotographyStudioUidKey(uid)
				local entity = self:getEntity(uid)

				entity = refreshUidSet and not refreshUidSet[uidKey] and entity or self:spawnStudioPlayer(uid, data, onLoaded)

				if entity then
					entity.studioModelRefreshedCallback = onLoaded
					keepUids[uidKey] = true
				end
			end
		end
	end

	for uid, _ in pairs(self.studioPlayerIds) do
		if not keepUids[tostring(uid)] then
			self:removeStudioPlayer(uid)
		end
	end
end

function AvatarScene:clearStudioPlayers()
	if not self.studioPlayerIds then
		return
	end

	for uid, _ in pairs(self.studioPlayerIds) do
		self:removeStudioPlayer(uid)
	end

	self.studioPlayerIds = {}
end

function AvatarScene:beginStudioPlayerAppearanceRefresh(entityId)
	local entity = entityId and self:getEntity(entityId)

	if not entity or entity.studioSelfAppearanceRefreshPending then
		return
	end

	local previousCallback = entity.onAnimatorReadyCallback

	entity.studioSelfAppearanceRefreshPending = true

	function entity.onAnimatorReadyCallback()
		if previousCallback then
			previousCallback(entity)
		end

		if self:getEntity(entityId) ~= entity then
			return
		end

		entity.studioSelfAppearanceRefreshPending = nil

		local hasPendingPose = entity.hasPendingStudioSelfPose
		local pendingPoseId = entity.pendingStudioSelfPoseId
		local hasPendingGaze = entity.hasPendingStudioSelfGaze
		local pendingGazeType = entity.pendingStudioSelfGazeType
		local pendingGazePos = entity.pendingStudioSelfGazePos

		entity.hasPendingStudioSelfPose = nil
		entity.pendingStudioSelfPoseId = nil
		entity.hasPendingStudioSelfGaze = nil
		entity.pendingStudioSelfGazeType = nil
		entity.pendingStudioSelfGazePos = nil

		if hasPendingPose then
			self:applyStudioPlayerPose(entityId, pendingPoseId)
		end

		if hasPendingGaze then
			self:applyStudioPlayerGaze(entityId, pendingGazeType, pendingGazePos)
		end
	end
end

function AvatarScene:applyStudioPlayerPose(entityId, playerPoseId)
	local entity = entityId and self:getEntity(entityId)

	if not entity then
		return
	end

	if entity.studioSelfAppearanceRefreshPending then
		entity.hasPendingStudioSelfPose = true
		entity.pendingStudioSelfPoseId = playerPoseId

		return
	end

	self.studioPlayerPoseStates = self.studioPlayerPoseStates or {}

	if self.studioPlayerPoseStates[entityId] then
		self.studioPlayerPoseStates[entityId]:SetLogicLoop(false)

		self.studioPlayerPoseStates[entityId] = nil
	end

	entity.studioPlayerPoseId = playerPoseId

	local config = playerPoseId and AppearanceAction[playerPoseId]

	if not config then
		self:playIdleAnimation(entity)

		return
	end

	local aniLoop
	local res = config.res1

	if res and #res > 0 then
		aniLoop = #res == 3 and res[2] or res[1]
	end

	if config.photo == 2 then
		local ani = aniLoop or config.resLoop and PlayableConst[config.resLoop] or PlayableConst[config.res]

		if ani then
			local state = entity:playRawAnimation(ani, nil, 0, 1, nil, PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY)

			if state then
				state:SetLogicLoop(true)

				self.studioPlayerPoseStates[entityId] = state
			end
		end
	elseif config.photo == 1 then
		local ani = aniLoop or PlayableConst[config.res]
		local state = ani and entity:playAnimation(ani, true, nil, true, PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY)

		if state then
			self.studioPlayerPoseStates[entityId] = state
		end
	end
end

function AvatarScene:applyStudioPlayerGaze(entityId, gazeType, gazePos)
	local entity = entityId and self:getEntity(entityId)

	if not entity then
		return
	end

	if entity.studioSelfAppearanceRefreshPending then
		entity.hasPendingStudioSelfGaze = true
		entity.pendingStudioSelfGazeType = gazeType
		entity.pendingStudioSelfGazePos = gazePos

		return
	end

	if type(gazeType) == "userdata" then
		gazeType = gazeType:GetHashCode()
	else
		gazeType = tonumber(gazeType)
	end

	entity.studioPlayerGazeType = gazeType
	entity.studioPlayerGazePos = gazePos

	entity:cancelLookAtRole(gazeType == 1 and 0.5 or nil)

	if gazeType == 2 and not IsNil(self.camera) then
		entity:lookAtCamera(self.camera, false)
	elseif gazeType == 3 and gazePos and NotNil(self.entityRootTransform) then
		local worldPos = self.entityRootTransform:TransformPoint(Vector3(gazePos.x, gazePos.y, gazePos.z))

		entity:lookAtPos(worldPos, false)
	end
end

function AvatarScene:getStudioSelectableEntities()
	local list = {}
	local selfEntity = self:getCurEntity()

	if selfEntity and self:isStudioPlayerVisible(self:getCurEntityId()) then
		list[#list + 1] = selfEntity
	end

	if self.studioPlayerIds then
		for uid, _ in pairs(self.studioPlayerIds) do
			local entity = self:getEntity(uid)

			if entity and self:isStudioPlayerVisible(uid) then
				list[#list + 1] = entity
			end
		end
	end

	if self.studioPetKeys then
		for key, _ in pairs(self.studioPetKeys) do
			local entity = self:getEntity(key)

			if entity then
				list[#list + 1] = entity
			end
		end
	end

	if self.studioOrnamentKeys then
		for key, _ in pairs(self.studioOrnamentKeys) do
			local entity = self:getEntity(key)

			if entity then
				list[#list + 1] = entity
			end
		end
	end

	return list
end

local function getStudioOrnamentEntityId(ornamentId)
	return ornamentId and string.format("studioOrnament_%s", tostring(ornamentId)) or nil
end

function AvatarScene:spawnStudioOrnament(ornamentId, pos, rotY, ownerUid)
	ornamentId = tonumber(ornamentId)

	local configData = ornamentId and PhotoOrnamentData[ornamentId]

	if not configData or not configData.res then
		return nil, false
	end

	local key = getStudioOrnamentEntityId(ornamentId)

	self.studioOrnamentKeys = self.studioOrnamentKeys or {}

	local entity = self:getEntity(key)

	if entity then
		self.studioOrnamentKeys[key] = true
		entity.studioOrnamentEntityId = key

		if pos then
			self:setStudioEntityLocalPos(key, pos)
		end

		if rotY ~= nil then
			self:setStudioEntityLocalRotY(key, rotY)
		end

		return entity, false
	end

	entity = self:createEntity(key, ClientStudioOrnamentVirtualEntity, {
		ornamentId = ornamentId,
		ownerUid = ownerUid or pg.me.uid,
		configData = configData
	})
	entity.studioOrnamentEntityId = key
	self.studioOrnamentKeys[key] = true

	entity.eModel:SetTransformParent(self.entityRootTransform, false)

	entity.eModel.enableCameraHitCheck = false

	self:setStudioEntityLocalPos(key, pos or Vector3.zero)
	self:setStudioEntityLocalRotY(key, rotY or 0)

	return entity, true
end

function AvatarScene:syncStudioOrnaments(ornaments, ownerUid)
	self.studioOrnamentKeys = self.studioOrnamentKeys or {}

	local keepKeys = {}

	if type(ornaments) == "table" then
		for _, data in ipairs(ornaments) do
			local ornamentId = data and tonumber(data.ornamentId or data.id)
			local key = getStudioOrnamentEntityId(ornamentId)

			if key then
				local entity = self:spawnStudioOrnament(ornamentId, data.pos, data.rotY, ownerUid)

				if entity then
					keepKeys[key] = true
				end
			end
		end
	end

	for key, _ in pairs(self.studioOrnamentKeys) do
		if not keepKeys[key] then
			self:removeEntity(key)

			self.studioOrnamentKeys[key] = nil
		end
	end
end

function AvatarScene:getStudioOrnament(ornamentId)
	local key = getStudioOrnamentEntityId(ornamentId)

	return key and self:getEntity(key) or nil
end

function AvatarScene:removeStudioOrnament(ornamentId)
	local key = getStudioOrnamentEntityId(ornamentId)

	if not key or not self:getEntity(key) then
		return false
	end

	self:removeEntity(key)

	if self.studioOrnamentKeys then
		self.studioOrnamentKeys[key] = nil
	end

	return true
end

function AvatarScene:getStudioOrnaments()
	local result = {}

	for key, _ in pairs(self.studioOrnamentKeys or READONLY_EMPTY_TABLE) do
		local entity = self:getEntity(key)

		if entity then
			result[#result + 1] = entity
		end
	end

	return result
end

function AvatarScene:clearStudioOrnaments()
	for key, _ in pairs(self.studioOrnamentKeys or READONLY_EMPTY_TABLE) do
		self:removeEntity(key)
	end

	self.studioOrnamentKeys = {}
end

function AvatarScene:getStudioPetEntityId(petIdOrEntityId, ownerUid)
	local parsedOwnerUid, parsedPetId = PhotographyStudioUtils.parseStudioPetEntityId(petIdOrEntityId)

	if parsedPetId then
		return petIdOrEntityId, parsedOwnerUid, parsedPetId
	end

	if not petIdOrEntityId then
		return nil, nil, nil
	end

	local realOwnerUid = ownerUid or pg.me.uid

	return PhotographyStudioUtils.buildStudioPetEntityId(realOwnerUid, petIdOrEntityId), realOwnerUid, petIdOrEntityId
end

function AvatarScene:applyStudioPetPose(petIdOrEntityId, petPoseId, ownerUid)
	local key = self:getStudioPetEntityId(petIdOrEntityId, ownerUid)
	local entity = key and self:getEntity(key)

	if not entity then
		return
	end

	self.studioPetPoseStates = self.studioPetPoseStates or {}

	if self.studioPetPoseStates[key] then
		self.studioPetPoseStates[key]:SetLogicLoop(false)

		self.studioPetPoseStates[key] = nil
	end

	entity.studioPetPoseId = petPoseId

	local config = petPoseId and PetAppearanceAction[petPoseId]

	if not config then
		entity:playAnimation(PlayableConst.Idle, nil, nil, nil, PlayableConst.AnimationLayer.LAYER_FULLBODY)

		return
	end

	if config.photo == 2 then
		local ani = config.resLoop and PlayableConst[config.resLoop] or PlayableConst[config.res]

		if ani then
			local state = entity:playRawAnimation(ani, nil, 0, 1, nil, PlayableConst.AnimationLayer.LAYER_FULLBODY)

			if state then
				state:SetLogicLoop(true)

				self.studioPetPoseStates[key] = state
			end
		end
	elseif config.photo == 1 then
		local ani = PlayableConst[config.res]
		local aniLoop = config.resLoop and PlayableConst[config.resLoop]
		local state = ani and entity:playAnimation(ani, true, nil, false, PlayableConst.AnimationLayer.LAYER_FULLBODY)

		if state and aniLoop then
			entity:setAnimationSequence(state, state.Length - 0.2, function(stateTime)
				if stateTime > 0 then
					local loopState = entity:playAnimation(aniLoop, true, nil, false, PlayableConst.AnimationLayer.LAYER_FULLBODY)

					if loopState then
						loopState:SetLogicLoop(true)

						self.studioPetPoseStates[key] = loopState
					end
				end

				return true
			end)
		end
	end
end

function AvatarScene:applyStudioPetReadyState(key, entity, petData)
	if self:getEntity(key) ~= entity then
		return
	end

	local petPoseId = petData and petData.petPoseId

	if entity.studioPetPoseId ~= petPoseId then
		self:applyStudioPetPose(key, petPoseId)
	end

	self:applyStudioPetGaze(key, petData and petData.gazeType, petData and petData.gazePos)
end

function AvatarScene:applyStudioPetAppearanceAndState(key, entity, petId, petInfo, petData, appearanceChanged, isNew)
	entity.pendingStudioPetReadyData = petData or false

	local wasPending = entity.studioPetAnimatorReadyPending == true
	local previousCallback, readyCallback

	if not wasPending then
		previousCallback = entity.onAnimatorReadyCallback

		function readyCallback()
			if previousCallback then
				previousCallback(entity)
			end

			entity.studioPetAnimatorReadyPending = nil

			local readyData = entity.pendingStudioPetReadyData

			entity.pendingStudioPetReadyData = nil

			if readyData ~= nil then
				self:applyStudioPetReadyState(key, entity, readyData ~= false and readyData or nil)
			end
		end

		entity.studioPetAnimatorReadyPending = true
		entity.onAnimatorReadyCallback = readyCallback
	end

	local transmogChanged

	if petInfo then
		transmogChanged = PetTransmogUtils.applyAppliedTransmog(entity, petId, not isNew)
	else
		local scheme = petData and PhotographyStudioUtils.deserializeJsonSafeTable(petData.selectTransmogScheme)

		transmogChanged = PetTransmogUtils.applySchemeTransmog(entity, entity.templateId, scheme, true)
	end

	if appearanceChanged and not transmogChanged then
		entity:refreshAppearance()
	end

	if wasPending or transmogChanged or appearanceChanged then
		return
	end

	local modelView = entity.eModel and entity.eModel.modelModelView

	if isNew and (IsNil(modelView) or not modelView:IsAnimatorRead()) then
		return
	end

	entity.studioPetAnimatorReadyPending = nil
	entity.pendingStudioPetReadyData = nil

	if entity.onAnimatorReadyCallback == readyCallback then
		entity.onAnimatorReadyCallback = previousCallback
	end

	self:applyStudioPetReadyState(key, entity, petData)
end

function AvatarScene:spawnStudioPet(petId, ownerUid, pos, rotY, petData)
	if not petId then
		return nil
	end

	ownerUid = ownerUid or petData and petData.ownerUid or pg.me.uid

	local key = PhotographyStudioUtils.buildStudioPetEntityId(ownerUid, petId)

	self.studioPetKeys = self.studioPetKeys or {}

	local isSelfPet = tostring(ownerUid) == tostring(pg.me.uid)
	local petInfo = isSelfPet and pg.me:getPetInfo(petId) or nil
	local templateId = petInfo and petInfo.templateId or petData and petData.templateId

	if not templateId then
		return nil
	end

	local shinyEffectReplace = (petInfo or petData).shinyEffectReplace or ""
	local existing = self:getEntity(key)

	if existing and existing.templateId ~= templateId then
		self:removeStudioPet(petId, ownerUid)

		existing = nil
	end

	if existing then
		self.studioPetKeys[key] = true
		existing.studioPetId = existing.studioPetId or petId
		existing.studioPetEntityId = key
		existing.ownerUid = ownerUid or existing.ownerUid or pg.me.uid
		existing.useTempJewelrySnapshot = petInfo == nil and petData ~= nil

		local label = petInfo and petInfo.label or petData and petData.label or Const.PET_LABEL_MASK.NORMAL
		local gender = petInfo and petInfo.gender or petData and petData.gender
		local shinyStyle = petInfo and petInfo.shinyStyle or petData and petData.shinyStyle
		local jewelryInfo = petInfo and pg.me.petJewelryInfos and pg.me.petJewelryInfos[petId] or petData and PhotographyStudioUtils.deserializeJsonSafeTable(petData.petJewelryInfo)
		local appearanceChanged = existing.updateStudioAppearance and existing:updateStudioAppearance(label, gender, shinyStyle, jewelryInfo, shinyEffectReplace)

		if pos then
			self:setStudioEntityLocalPos(key, pos)
		end

		if rotY ~= nil then
			self:setStudioEntityLocalRotY(key, rotY)
		end

		self:applyStudioPetAppearanceAndState(key, existing, petId, petInfo, petData, appearanceChanged, false)

		return existing
	end

	local initDict = {
		templateId = templateId,
		label = petInfo and petInfo.label or petData and petData.label or Const.PET_LABEL_MASK.NORMAL,
		gender = petInfo and petInfo.gender or petData and petData.gender,
		shinyStyle = petInfo and petInfo.shinyStyle or petData and petData.shinyStyle,
		shinyEffectReplace = shinyEffectReplace,
		tempJewelryInfo = petInfo and pg.me.petJewelryInfos and pg.me.petJewelryInfos[petId] or petData and PhotographyStudioUtils.deserializeJsonSafeTable(petData.petJewelryInfo),
		useTempJewelrySnapshot = petInfo == nil and petData ~= nil,
		realPetId = petId,
		ownerUid = ownerUid or pg.me.uid
	}
	local entity = self:createEntity(key, ClientStudioPetVirtualEntity, initDict)

	entity.studioPetId = petId
	entity.studioPetEntityId = key
	self.studioPetKeys[key] = true

	entity:setConfigData(PetData[templateId] or {})
	entity.eModel:SetTransformParent(self.entityRootTransform, false)

	entity.eModel.enableCameraHitCheck = false

	entity:setDisableEffectLod(true)
	self:setStudioEntityLocalPos(key, pos or Vector3.zero)
	self:setStudioEntityLocalRotY(key, rotY or 0)
	self:applyStudioPetAppearanceAndState(key, entity, petId, petInfo, petData, false, true)

	return entity
end

function AvatarScene:syncStudioPets(pets, refreshOwnerUidSet)
	if self.photographyStudioCharactersVisible == false then
		self:clearStudioPets()

		return
	end

	self.studioPetKeys = self.studioPetKeys or {}

	local keepKeys = {}

	if type(pets) == "table" then
		for _, data in ipairs(pets) do
			local petId = data and data.petId

			if petId then
				local ownerUid = data.ownerUid or data.uid or pg.me.uid
				local key = PhotographyStudioUtils.buildStudioPetEntityId(ownerUid, petId)

				keepKeys[key] = true

				if not refreshOwnerUidSet or refreshOwnerUidSet[getPhotographyStudioUidKey(ownerUid)] or not self:getEntity(key) then
					self:spawnStudioPet(petId, ownerUid, data.pos, data.rotY, data.petData or data)
				end
			end
		end
	end

	for key, _ in pairs(self.studioPetKeys) do
		if not keepKeys[key] then
			self:removeEntity(key)

			self.studioPetKeys[key] = nil
		end
	end
end

function AvatarScene:applyStudioPetGaze(entityId, gazeType, gazePos)
	local entity = entityId and self:getEntity(entityId)

	if not entity then
		return
	end

	if type(gazeType) == "userdata" then
		gazeType = gazeType:GetHashCode()
	else
		gazeType = tonumber(gazeType)
	end

	gazeType = gazeType or 2
	entity.studioPetGazeType = gazeType
	entity.studioPetGazePos = gazePos

	entity:cancelLookAtRole(gazeType == 1 and 0.5 or nil)

	if gazeType == 2 and not IsNil(self.camera) then
		entity:lookAtCamera(self.camera, false)
	elseif gazeType == 3 and gazePos and NotNil(self.entityRootTransform) then
		local worldPos = self.entityRootTransform:TransformPoint(Vector3(gazePos.x, gazePos.y, gazePos.z))

		entity:lookAtPos(worldPos, false)
	end
end

function AvatarScene:removeStudioPet(petId, ownerUid)
	if not petId or not self.studioPetKeys then
		return
	end

	local key = self:getStudioPetEntityId(petId, ownerUid)

	if self.studioPetKeys[key] then
		if self.studioPetPoseStates and self.studioPetPoseStates[key] then
			self.studioPetPoseStates[key]:SetLogicLoop(false)

			self.studioPetPoseStates[key] = nil
		end

		self:removeEntity(key)

		self.studioPetKeys[key] = nil
	end
end

function AvatarScene:clearStudioPets()
	if not self.studioPetKeys then
		return
	end

	for key, _ in pairs(self.studioPetKeys) do
		if self.studioPetPoseStates and self.studioPetPoseStates[key] then
			self.studioPetPoseStates[key]:SetLogicLoop(false)

			self.studioPetPoseStates[key] = nil
		end

		self:removeEntity(key)
	end

	self.studioPetKeys = {}
	self.studioPetPoseStates = {}
end

function AvatarScene:getStudioPet(petId, ownerUid)
	if not petId then
		return nil
	end

	local key = self:getStudioPetEntityId(petId, ownerUid)

	return key and self:getEntity(key) or nil
end

function AvatarScene:setStudioPetLocalPos(petId, pos, ownerUid)
	if not petId then
		return
	end

	local key = self:getStudioPetEntityId(petId, ownerUid)

	self:setStudioEntityLocalPos(key, pos)
end

function AvatarScene:getStudioPetLocalPos(petId, ownerUid)
	if not petId then
		return nil
	end

	local key = self:getStudioPetEntityId(petId, ownerUid)

	return key and self:getStudioEntityLocalPos(key) or nil
end

function AvatarScene:setStudioPetLocalRotY(petId, eulerY, ownerUid)
	if not petId then
		return
	end

	local key = self:getStudioPetEntityId(petId, ownerUid)

	self:setStudioEntityLocalRotY(key, eulerY)
end

function AvatarScene:getStudioPetLocalRotY(petId, ownerUid)
	if not petId then
		return nil
	end

	local key = self:getStudioPetEntityId(petId, ownerUid)

	return key and self:getStudioEntityLocalRotY(key) or nil
end

function AvatarScene:setStudioEntityLocalPos(entityId, pos)
	local entity = self:getEntity(entityId)

	if entity and pos then
		entity:setPositionAgentLocalPos(pos.x, pos.y, pos.z)
	end
end

function AvatarScene:getStudioEntityLocalPos(entityId)
	local entity = self:getEntity(entityId)

	if not entity or not entity.eModel then
		return nil
	end

	local x, y, z = entity.eModel:GetPositionAgentLocalPosEx()

	return {
		x = x,
		y = y,
		z = z
	}
end

function AvatarScene:setStudioEntityLocalRotY(entityId, eulerY)
	local entity = self:getEntity(entityId)

	if entity and entity.eModel then
		entity.eModel:SetPositionAgentLocalEulerEx(0, eulerY or 0, 0)
	end
end

function AvatarScene:getStudioEntityLocalRotY(entityId)
	local entity = self:getEntity(entityId)

	if not entity or not entity.eModel then
		return nil
	end

	local _, y = entity.eModel:GetPositionAgentLocalEulerEx()

	return y
end

function AvatarScene:setEntityPos(entityId, pos)
	local entity = self:getEntity(entityId)

	if entity then
		if pos then
			entity.eModel:SetTransformLocalPosition(pos.x, pos.y, pos.z)
		else
			entity.eModel:SetTransformLocalPosition()
		end
	end
end

function AvatarScene:getEntityPos(entityId)
	local entity = self:getEntity(entityId)

	if entity and entity.eModel then
		local x, y, z = entity.eModel:GetTransformLocalPosition()

		return Vector3(x, y, z)
	end

	return nil
end

function AvatarScene:getEntityRotY(entityId)
	local entity = self:getEntity(entityId)

	if entity and entity.eModel then
		local x, y, z = entity.eModel:GetTransformRotationEulerAngles()

		return y
	end

	return nil
end

function AvatarScene:setEntityRot(entityId, eulerY, duration)
	local entity = self:getEntity(entityId)

	if not entity then
		return
	end

	eulerY = eulerY or 0

	if duration then
		local _, eulerAngleY, _ = entity.eModel:GetTransformRotationEulerAngles()
		local from = Utils.normalizeAngle(eulerAngleY)
		local targetRotY = Utils.normalizeAngle(eulerY)
		local to = math.abs(targetRotY - from) > 180 and targetRotY + 360 or targetRotY

		DoTweenAnimMgr.DoFloat(entity.actorId, from, to, LuaUIUtils.TweenId("entityRotationTween"), duration, 0, CS.DG.Tweening.Ease.__CastFrom(1), function()
			return
		end, function(value)
			entity.eModel:SetTransformRotationByEulerAngle(0, value, 0)
		end, function()
			return
		end, false)
	else
		entity.eModel:SetTransformRotationByEulerAngle(0, eulerY, 0)
	end
end

function AvatarScene:setCurEntityRot(eulerY, duration)
	self:setEntityRot(self.curEntityId, eulerY, duration)
end

local function syncAvatarSceneHairColors(entity)
	if not entity or not entity.curShow then
		return
	end

	local hairSuitId = LuaUIUtils.tryGetEntityHairSuitId(entity)
	local hairSuitInfo = AvatarHairSuitData[hairSuitId]

	if hairSuitInfo then
		avatarMgr.avatarHair:SetAssetIdAndLoad(hairSuitInfo.assetId)
		avatarMgr.avatarHair:InitColors()
	end

	for partId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
		ClientModelUtils.applyHairCustomData(entity, entity.curShow, partId)
	end
end

local function syncAvatarSceneFaceReaction(entity)
	if not entity or not entity.eModel then
		return
	end

	local modelView = entity.eModel.modelModelView

	if NotNil(modelView) then
		modelView:RefreshFaceSkeletonOnly()
	end
end

function AvatarScene:showAvatar(presetKey, onAvatarLoaded)
	self.curEntityId = presetKey

	self:switchLight()

	local curEntity = self:getEntity(presetKey)

	if curEntity then
		self:showEntityWithId(presetKey)
		self:enableCameraMode(self.CAMERA.SIMPLE)
		avatarMgr:SetAvatarInstance(curEntity.eModel)
		avatarMgr:InitAvatarPart()
		syncAvatarSceneHairColors(curEntity)
		syncAvatarSceneFaceReaction(curEntity)

		if onAvatarLoaded then
			onAvatarLoaded()
		end
	else
		pg.game.avatar.eyeNormalFixEntity = nil

		avatarMgr:ClearAvatar()

		local templateId = pg.game.avatar:getAvatarPresetData(presetKey).templateId

		avatarMgr:InitWorkSpace(presetKey, templateId, GlobalData.UserName)

		local initDict = {
			isAppearancePreview = true,
			needFacialHighLight = true,
			copyEntity = pg.me,
			studioPlayerUid = pg.me.uid,
			ownerUid = pg.me.uid
		}

		curEntity = self:createEntity(presetKey, ClientStudioPlayerVirtualEntity, initDict)

		for partId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
			curEntity.customShowPreview[partId] = curEntity.customShow[partId]
		end

		curEntity.eModel:SetTransformParent(self.entityRootTransform, false)

		curEntity.eModel.enableCameraHitCheck = false

		curEntity:setDisableEffectLod(true)

		function curEntity.modelPartModelAllLoaded()
			curEntity.modelPartModelAllLoaded = nil

			self:enableCameraMode(self.CAMERA.SIMPLE)
			self:playIdleAnimation(curEntity)

			local actions = {}

			table.insert(actions, {
				partId = GameConst.PART_TOP,
				slotId = GameConst.SLOT_BAG,
				visible = pg.me.curShow.isShowBag
			})
			self:refreshPartRendererVisible(presetKey, actions)
			avatarMgr:SetAvatarInstance(curEntity.eModel)
			avatarMgr:InitAvatarPart()
			syncAvatarSceneHairColors(curEntity)
			syncAvatarSceneFaceReaction(curEntity)

			pg.game.avatar.eyeNormalFixEntity = curEntity

			if onAvatarLoaded then
				onAvatarLoaded()
				self:recordInitialAvatarConfig()
			end
		end
	end
end

function AvatarScene:doLoadedCallBack(succeed)
	if self.needShowAvatar then
		local presetKey = pg.game.avatar:getPresetKey(pg.me)

		self:showAvatar(presetKey, function()
			AvatarScene.super.doLoadedCallBack(self, succeed)
		end)
	else
		AvatarScene.super.doLoadedCallBack(self, succeed)
	end
end

function AvatarScene:showAvatarTemplate(presetKey, onAvatarLoaded, sync, force)
	local presetData = pg.game.avatar:getAvatarPresetData(presetKey) or {}

	if self.curEntityId == presetKey and not force then
		return
	end

	pg.game.avatar.eyeNormalFixEntity = nil

	avatarMgr:ClearAvatar()

	local templateId = pg.game.avatar:getAvatarPresetData(presetKey).templateId

	avatarMgr:InitWorkSpace(presetKey, templateId, GlobalData.UserName)
	self:removeEntity(self.curEntityId)

	self.curEntityId = presetKey

	self:switchLight()

	local initDict = {
		useDefaultParts = true,
		isAppearancePreview = true,
		needFacialHighLight = true,
		templateId = templateId,
		avatarPresetKey = presetKey,
		studioPlayerUid = pg.me and pg.me.uid or 0,
		ownerUid = pg.me and pg.me.uid or 0
	}
	local curEntity = self:createEntity(presetKey, ClientStudioPlayerVirtualEntity, initDict)

	curEntity.curShow = {}
	curEntity.curShow.customShow = setmetatable({}, {
		__newindex = function(self, key, value)
			rawset(self, key, value)
		end
	})

	avatarMgr:SetAvatarInstance(curEntity.eModel)
	curEntity.eModel:SetTransformParent(self.entityRootTransform, false)

	curEntity.eModel.enableCameraHitCheck = false

	curEntity:setDisableEffectLod(true)

	function curEntity.modelPartModelAllLoaded()
		avatarMgr:InitAvatarPart()

		local loadedCallback = onAvatarLoaded

		curEntity.modelPartModelAllLoaded = nil

		curEntity:refreshAppearance()
		avatarMgr:SetAvatarInstance(curEntity.eModel)
		avatarMgr:InitAvatarPart()
		self:enableCameraMode(self.CAMERA.SIMPLE)
		self:playIdleAnimation(curEntity)

		pg.game.avatar.eyeNormalFixEntity = curEntity

		if loadedCallback then
			loadedCallback()
		end
	end

	local modelResData = AvatarUtils.getModelResData(curEntity, presetKey)

	for partId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
		local hairInfo = modelResData[partId] or {}

		pg.game.avatar:updateHairSelection(partId, hairInfo.configId, "showAvatarTemplate")
	end
end

function AvatarScene:showClothes(defaultSuitId)
	local entity = self:getCurEntity()
	local modelView = entity.eModel.modelView
	local partModelInfo = modelView.modelInfo.partModelInfo

	if entity.copyEntity and entity.getAppearanceConfigId then
		for slotId = AppearancePointEnum.Coat, AppearancePointEnum.Shoes do
			local clothesId = entity:getAppearanceConfigId(slotId)

			AppearanceEffectUtils.setAppearance(entity, slotId, clothesId)

			if clothesId and clothesId ~= 0 then
				local clothesData = AppearanceData[clothesId] or {}

				partModelInfo:ModifyPartItem(clothesData.res, Utils.deepCopyTable(clothesData.points))
			else
				local curResId = partModelInfo:GetPartResId(slotId)

				partModelInfo:RemovePartItem(curResId)
			end
		end
	elseif pg.me then
		for i = AppearancePointEnum.Coat, AppearancePointEnum.Shoes do
			local clothesId = pg.me.curShow.customShow[i]

			AppearanceEffectUtils.setAppearance(entity, i, clothesId)

			local clothesData = AppearanceData[clothesId] or {}

			partModelInfo:ModifyPartItem(clothesData.res, Utils.deepCopyTable(clothesData.points))
		end
	else
		local suitData = AppearanceSuitData[defaultSuitId] or {}

		for _, clothesId in ipairs(suitData.appearanceList) do
			AppearanceEffectUtils.setPartAppearance(entity, clothesId, true)

			local clothesData = AppearanceData[clothesId] or {}

			partModelInfo:ModifyPartItem(clothesData.res, Utils.deepCopyTable(clothesData.points))
		end
	end

	ClientModelUtils.refreshModels(entity, modelView)
end

function AvatarScene:hideClothes()
	local entity = self:getCurEntity()
	local modelView = entity.eModel.modelView
	local partModelInfo = modelView.modelInfo.partModelInfo

	for partId = AppearancePointEnum.Coat, AppearancePointEnum.Shoes do
		local clothesId = self:getCurClothesId(self.curEntityId, partId)

		if clothesId then
			local clothesData = AppearanceData[clothesId] or {}

			partModelInfo:RemovePartItem(clothesData.res)
		end
	end

	ClientModelUtils.refreshModels(entity, modelView)
end

function AvatarScene:playIdleAnimation(entity, fadeTime)
	if not entity then
		return
	end

	local curState = entity:getCurrentPlayableState(PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY)
	local newState = PlayableConst.Idle

	if entity.eModel:HasPlayableMotion(Const.COMPONENT_IDX_PLAYABLE, PlayableConst.Show_Idle) then
		newState = PlayableConst.Show_Idle

		entity.eModel:SetLayerDefaultAnimation(Const.COMPONENT_IDX_PLAYABLE, PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY, PlayableConst.Show_Idle)
	end

	if IsNil(curState) or curState.key ~= newState then
		entity:playRawAnimation(newState, fadeTime, 0, nil, nil, PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY)
	else
		entity:playRawAnimation(newState, 0, curState.Time, nil, nil, PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY)
	end
end

function AvatarScene:destroyPet(templateId)
	self:removeEntity(templateId)
end

function AvatarScene:showPetTemplate(petInfo, scale, offset)
	local templateId = petInfo.templateId
	local configData = petInfo.configData or PetData[templateId]
	local realPetId = petInfo.id and pg.me.pets[petInfo.id] and petInfo.id

	if templateId ~= self.curEntityId then
		self:hideEntityWithId(self.curEntityId)
	end

	self.curEntityId = templateId

	self:switchLight()

	local curEntity = self:getEntity(templateId)

	if curEntity then
		self:showEntityWithId(templateId)
		self:enableCameraMode(self.CAMERA.PET)
		self:setAvatarCameraModeFar()
	else
		local initDict = {
			templateId = templateId,
			configData = configData,
			label = petInfo.label,
			shinyStyle = petInfo.shinyStyle,
			gender = petInfo.gender,
			tempJewelryInfo = realPetId and pg.me.petJewelryInfos[realPetId],
			realPetId = realPetId,
			petInfo = petInfo
		}

		curEntity = self:createEntity(templateId, ClientSimpleVirtualPet, initDict)

		EModelUtils.setAgentPosition(curEntity, offset)
		curEntity:setScaleNumber(scale)
		curEntity.eModel:SetTransformParent(self.entityRootTransform, false)
		curEntity:setDisableEffectLod(true)

		curEntity.eModel.enableCameraHitCheck = false
	end

	local request = {}

	self.petAppearanceRequest = request
	curEntity.modelLoadedCallback = nil
	curEntity.onAnimatorReadyCallback = nil

	PetManagementDataHelper.refreshPetModelAppearance(curEntity, templateId, {
		useTransmogScheme = true,
		petInfo = petInfo,
		configData = configData,
		realPetId = realPetId,
		clearJewelryInfo = not realPetId,
		transmogPetId = realPetId,
		transmogScheme = petInfo.selectTransmogScheme,
		modelNeedBones = curEntity.modelNeedBones
	})

	local function isCurrentRequest()
		return self.petAppearanceRequest == request and self.curEntityId == templateId and self:getEntity(templateId) == curEntity and curEntity.realPetId == realPetId
	end

	local function onModelLoaded()
		if not isCurrentRequest() then
			return
		end

		curEntity.modelLoadedCallback = nil

		self:enableCameraMode(self.CAMERA.PET)
		self:setAvatarCameraModeFar()
		self:runWhenAnimatorReady(curEntity, function()
			if isCurrentRequest() then
				curEntity:playAnimation(PlayableConst.Idle)
			end
		end)
	end

	curEntity.modelLoadedCallback = onModelLoaded

	if curEntity.eModel.modelModelView.firstLoaded then
		onModelLoaded()
	end
end

function AvatarScene:isSameEntity(entityId)
	return self.curEntityId == entityId
end

function AvatarScene:getCurEntity()
	return self:getEntity(self.curEntityId)
end

function AvatarScene:getCurEntityId()
	return self.curEntityId
end

function AvatarScene:getPresetData()
	return pg.game.avatar:getAvatarPresetData(self.curEntityId) or {}
end

function AvatarScene:recordInitialAvatarConfig()
	if not avatarMgr then
		return
	end

	self.useAvatarCustomDataCache = false
	self.useAvatarHairCustomDataCache = false

	if avatarMgr.CacheCurrentAvatarCustomData and avatarMgr:CacheCurrentAvatarCustomData() then
		self.useAvatarCustomDataCache = true
	end

	if avatarMgr.CacheCurrentAvatarHairCustomData and avatarMgr:CacheCurrentAvatarHairCustomData() then
		self.useAvatarHairCustomDataCache = true
	end
end

function AvatarScene:hasAvatarConfigChanged()
	if not avatarMgr then
		return false
	end

	if self.useAvatarCustomDataCache and avatarMgr.HasCachedAvatarCustomDataChanged and avatarMgr:HasCachedAvatarCustomDataChanged() then
		return true
	end

	if not avatarMgr.GetCustomDataString then
		return false
	end

	return false
end

function AvatarScene:hasAvatarHairConfigChanged()
	if not avatarMgr then
		return false
	end

	if self.useAvatarHairCustomDataCache and avatarMgr.HasCachedAvatarHairCustomDataChanged then
		return avatarMgr:HasCachedAvatarHairCustomDataChanged()
	end

	return false
end

function AvatarScene:hasAvatarMakeUpConfigChanged()
	if not avatarMgr then
		return false
	end

	if self.useAvatarCustomDataCache and avatarMgr.HasOnlyCachedAvatarMakeupCustomDataChanged then
		return avatarMgr:HasOnlyCachedAvatarMakeupCustomDataChanged()
	end

	if not avatarMgr.GetCustomDataString then
		return false
	end

	return false
end

function AvatarScene:removeEntity(entityId)
	AvatarScene.super.removeEntity(self, entityId)

	if self.curEntityId == entityId then
		self.curEntityId = nil
	end
end

function AvatarScene:changeHair(param)
	require("Guis.Utils.AvatarUtils").cancelHairTie()

	local entity = self:getEntity(param.entityId)

	if not entity then
		return
	end

	local modelView = entity.eModel.modelView
	local partModelInfo = modelView.modelInfo.partModelInfo

	for _, info in ipairs(param) do
		if info.isApply then
			partModelInfo:ModifyPartItem(info.resId, {
				info.partId
			})
		else
			partModelInfo:RemovePartItem(info.resId)
		end
	end

	ClientModelUtils.refreshModels(entity, modelView)
end

function AvatarScene:getCurHairPartId(entityId, partId)
	local entity = self:getEntity(entityId)

	if not entity then
		return
	end

	local partModelInfo = entity.eModel.modelModelView.modelInfo.partModelInfo
	local resId = partModelInfo:GetPartResId(partId) or ""

	return AvatarHairResIdToConfig[resId]
end

function AvatarScene:getCurHairSuitId(entityId)
	local entity = self:getEntity(entityId)

	if not entity then
		return
	end

	local hairId
	local partModelInfo = entity.eModel.modelModelView.modelInfo.partModelInfo

	for partId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
		local resId = partModelInfo:GetPartResId(partId)

		if not string.isNilOrEmpty(resId) then
			local configId = AvatarHairResIdToConfig[resId]

			if configId then
				if not hairId then
					hairId = AppearanceData[configId].hairId
				elseif hairId ~= AppearanceData[configId].hairId then
					if LoggerManager.checkLogger(LoggerConst.ERROR) then
						logger:error(string.format("@sxy invalid equip: part %s is not in suit %s", id, hairId))
					end

					break
				end
			end
		end
	end

	return hairId
end

function AvatarScene:changeClothes(param)
	local entity = self:getEntity(param.entityId)

	if not entity then
		return
	end

	local modelView = entity.eModel.modelView
	local partModelInfo = modelView.modelInfo.partModelInfo

	for _, info in ipairs(param) do
		local clothesData = AppearanceData[info.clothesId] or {}
		local partId = clothesData.partId

		AppearanceEffectUtils.setPartAppearance(entity, info.clothesId, info.isApply)

		if info.isApply then
			entity.curShow.customShow[partId] = info.clothesId

			partModelInfo:ModifyPartItem(clothesData.res, Utils.deepCopyTable(clothesData.points))
		else
			entity.curShow.customShow[partId] = nil

			partModelInfo:RemovePartItem(clothesData.res)
		end
	end

	ClientModelUtils.refreshModels(entity, modelView)
end

function AvatarScene:playShowAnimation(entityId, key)
	local entity = self:getEntity(entityId)

	if not entity then
		return
	end

	local state = entity:getCurrentPlayableState(PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY)

	if IsNil(state) then
		entity:playRawAnimation(PlayableConst[key], nil, 0, nil, nil, PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY)
	elseif state.Key ~= PlayableConst[key] then
		entity:playAnimation(PlayableConst[key], true, nil, nil, PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY)
	else
		entity:playRawAnimation(PlayableConst[key], 0, state.Time, nil, nil, PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY)
	end
end

function AvatarScene:playCfgAnimation(entityId, key)
	local entity = self:getEntity(entityId)

	if not entity then
		return
	end

	entity:playCfgAnimation(key)
end

function AvatarScene:previewCustomClothes(entityId, outfitId)
	local entity = self:getEntity(entityId)

	if not entity then
		return
	end

	local partModelInfo = entity.eModel.modelView.modelInfo.partModelInfo

	for slotId = AppearancePointEnum.Coat, AppearancePointEnum.Shoes do
		local clothesId

		if outfitId then
			if pg.me.appearanceCustom[outfitId] then
				clothesId = pg.me.appearanceCustom[outfitId].customShow[slotId]
			end
		else
			clothesId = entity:getAppearanceConfigId(slotId)
		end

		AppearanceEffectUtils.setAppearance(entity, slotId, clothesId)

		if clothesId and clothesId ~= 0 then
			local clothesData = AppearanceData[clothesId] or {}

			partModelInfo:ModifyPartItem(clothesData.res, Utils.deepCopyTable(clothesData.points))
		else
			local curResId = partModelInfo:GetPartResId(slotId)

			partModelInfo:RemovePartItem(curResId)
		end
	end
end

function AvatarScene:previewCustomAccessory(entityId, outfitId)
	local entity = self:getEntity(entityId)

	if not entity then
		return
	end

	local modelView = entity.eModel.modelModelView

	modelView.modelInfo:ClearAttachInfo()

	local attachInfoList = {}
	local outfitCustom = outfitId and pg.me.appearanceCustom[outfitId]

	for slotId = AppearancePointEnum.Jewelry1, AppearancePointEnum.Jewelry10 do
		local accessoryId

		if outfitId then
			if outfitCustom then
				accessoryId = outfitCustom.customShow[slotId]
			end
		else
			accessoryId = entity:getAppearanceConfigId(slotId)
		end

		AppearanceEffectUtils.setAppearance(entity, slotId, nil)

		if accessoryId and accessoryId ~= 0 then
			local outfitJewelryInfo = outfitCustom and outfitCustom[slotId]
			local attachInfo = ClientModelUtils.getModelAttachInfo(pg.me, accessoryId, slotId, outfitJewelryInfo)

			table.insert(attachInfoList, attachInfo)
			AppearanceEffectUtils.setAppearance(entity, slotId, accessoryId, attachInfo.resId)
		end
	end

	ClientModelUtils.addModelAttachList(modelView.modelInfo, attachInfoList)
end

function AvatarScene:refreshPartRendererVisible(entityId, actions)
	local entity = self:getEntity(entityId)

	if not entity then
		return
	end

	ClientModelUtils.applyPartRendererVisibility(entity, actions)
end

function AvatarScene:getCurClothesId(entityId, partId)
	local entity = self:getEntity(entityId)

	if not entity then
		return
	end

	local partModelInfo = entity.eModel.modelModelView.modelInfo.partModelInfo
	local resId = partModelInfo:GetPartResId(partId)

	for id, appearanceData in pairs(AppearanceData) do
		if LuaUIUtils.isClothes(appearanceData.type) and not string.isNilOrEmpty(resId) and appearanceData.res == resId then
			if LuaUIUtils.isClothesBelongToSlot(id, partId) then
				return id
			end

			return nil
		end
	end
end

function AvatarScene:checkPartItemExists(entity, resId)
	if not entity or not resId then
		return false
	end

	local partModelInfo = entity.eModel.modelModelView.modelInfo.partModelInfo

	for partId = AppearancePointEnum.Coat, AppearancePointEnum.Shoes do
		local res = partModelInfo:GetPartResId(partId)

		if res == resId then
			return true
		end
	end

	for partId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
		local res = partModelInfo:GetPartResId(partId)

		if res == resId then
			return true
		end
	end

	for partId = AppearancePointEnum.Jewelry1, AppearancePointEnum.Jewelry10 do
		local res = partModelInfo:GetPartResId(partId)

		if res == resId then
			return true
		end
	end

	return false
end

function AvatarScene:getCurSuitId(entityId)
	local suitId
	local comparedList = {}

	for partId = AppearancePointEnum.Coat, AppearancePointEnum.Shoes do
		local clothesId = self:getCurClothesId(entityId, partId)

		if clothesId and not table.contains(comparedList, clothesId) then
			table.insert(comparedList, clothesId)
		end
	end

	for id, suitData in pairs(AppearanceSuitData) do
		if LuaUIUtils.tablesHaveSameElements(suitData.appearanceList, comparedList) then
			suitId = id

			break
		end
	end

	return suitId
end

function AvatarScene:switchCameraLookAt(enable)
	enable = enable and true or false
	self.cameraLookAtEnabled = enable

	local entity = self:getCurEntity()

	if not entity then
		return
	end

	if enable then
		local lookAtComponent = entity.eModel and entity.eModel.ikLookAtComponent

		if lookAtComponent then
			lookAtComponent.targetCamera = self.camera
			lookAtComponent.enableCameraLookAt = true

			entity.eModel:EnableRigComponent(Const.COMPONENT_INDEX_IK, lookAtComponent, true)
		end
	else
		local lookAtComponent = entity.eModel and entity.eModel.ikLookAtComponent

		if lookAtComponent then
			lookAtComponent.enableCameraLookAt = false
		end
	end
end

function AvatarScene:isCameraLookAtEnabled()
	return self.cameraLookAtEnabled == true
end

function AvatarScene:previewCustomShow(entityId, outfitId)
	local entity = self:getEntity(entityId)

	if not entity then
		return
	end

	entity.previewOutfitId = outfitId

	self:previewCustomClothes(entityId, outfitId)
	self:previewCustomAccessory(entityId, outfitId)
	ClientModelUtils.refreshModels(entity, entity.eModel.modelModelView)

	local function applyStain()
		ClientModelUtils.applyOutfitClothesStain(entity, outfitId)
	end

	applyStain()

	if entity.addTimer then
		entity:addTimer(0, applyStain)
	end
end

function AvatarScene:showNameBG(resId, localPosition, onResLoaded)
	if not IsNil(self.nameObjectPool[resId]) then
		self.nameObjectPool[resId]:SetActiveEx(true)

		self.nameObjectPool[resId].transform.localPosition = localPosition or Vector3.zero

		if onResLoaded then
			onResLoaded()
		end

		return
	end

	self:loadUISceneRes(resId, function(obj)
		obj.transform:SetParent(self.scene.transform)

		obj.transform.localPosition = localPosition or Vector3.zero
		self.nameObjectPool[resId] = obj

		if onResLoaded then
			onResLoaded()
		end
	end)
end

function AvatarScene:hideNameBG()
	for _, nameObject in pairs(self.nameObjectPool) do
		if not IsNil(nameObject) then
			nameObject:SetActiveEx(false)
		end
	end
end

function AvatarScene:playPosAnim(entity, animName, isLoop, finishedCallback)
	local res = entity:playAnimation(animName, false, nil, isLoop)

	if finishedCallback then
		res:AddEndCallback(finishedCallback)
	end
end

function AvatarScene:setPreviewCameraMode()
	self:doSpringArmTween(self.curCameraMode.cameraMode.maxZoom, 1)
	self:doVerticalTween(self.curCameraMode.maxZoomOffsetY, 1)
end

function AvatarScene:setTagCameraMode(callback, duration)
	duration = (duration or 2) - 0.5

	self:doSpringArmTween(2.5, duration)

	local start = self.curCameraMode:getPivotOffset()

	self.tagAndNameOffset = start

	local to = Vector3.New(0, 1.2, 0)

	self:doMoveTween(start, to, duration, callback)
end

function AvatarScene:setTipCameraMode(duration)
	local spring = 4
	local offset = Vector2.New(-0.6, 1.1)

	if duration then
		self:doSpringArmTween(spring, duration)

		local start = self.curCameraMode:getPivotOffset()

		self:doMoveTween(start, offset, 1)
	else
		self.curCameraMode:setSpringArmLen(spring)
		self.curCameraMode:moveCameraInVector(offset.x, offset.y)
	end
end

function AvatarScene:setAvatarCameraMode()
	self:doSpringArmTween(5, 1)

	local start = self.curCameraMode:getPivotOffset()
	local to = self.tagAndNameOffset or Vector3.New(0, 1, 0)

	self:doMoveTween(start, to, 1)
	self:enableCameraMode(self.CAMERA.SIMPLE)
end

function AvatarScene:setCameraRotationOffset(rotationOffsetY, duration)
	self:doRotationOffsetYTween(rotationOffsetY, duration or 0.2)
end

AvatarScene.cameraDuration = 1

function AvatarScene:reachMinZoom()
	return math.abs(self.curCameraMode:getSpringArmLen() - self.curCameraMode.cameraMode.minZoom) < 0.1
end

function AvatarScene:setAvatarCameraModeCloseHead()
	self:doSpringArmTween(self.curCameraMode.cameraMode.minZoom, self.cameraDuration)

	if self.curCameraMode.minZoomOffsetYSplit then
		self:doVerticalTween(self.curCameraMode.minZoomOffsetYSplit.Hair, self.cameraDuration, true)
	end
end

function AvatarScene:setAvatarCameraModeCloseToChest()
	self:doSpringArmTween(self.curCameraMode.cameraMode.minZoom, self.cameraDuration)

	if self.curCameraMode.minZoomOffsetYSplit then
		self:doVerticalTween(self.curCameraMode.minZoomOffsetYSplit.Chest, self.cameraDuration, true)
	end
end

function AvatarScene:setAvatarCameraModeCloseToWaist()
	self:doSpringArmTween(self.curCameraMode.cameraMode.minZoom, self.cameraDuration)

	if self.curCameraMode.minZoomOffsetYSplit then
		self:doVerticalTween(self.curCameraMode.minZoomOffsetYSplit.Waist, self.cameraDuration, true)
	end
end

function AvatarScene:setAvatarCameraModeCloseToThigh()
	self:doSpringArmTween(self.curCameraMode.cameraMode.minZoom, self.cameraDuration)

	if self.curCameraMode.minZoomOffsetYSplit then
		self:doVerticalTween(self.curCameraMode.minZoomOffsetYSplit.Thigh, self.cameraDuration, true)
	end
end

function AvatarScene:setAvatarCameraModeCloseToFoot()
	self:doSpringArmTween(self.curCameraMode.cameraMode.minZoom, self.cameraDuration)

	if self.curCameraMode.minZoomOffsetYSplit then
		self:doVerticalTween(self.curCameraMode.minZoomOffsetYSplit.Foot, self.cameraDuration, true)
	end
end

function AvatarScene:setAvatarCameraModeFar()
	if not self.curCameraMode then
		return
	end

	self:doSpringArmTween(self.curCameraMode.cameraMode.maxZoom, self.cameraDuration)
	self:doVerticalTween(self.curCameraMode.maxZoomOffsetY, self.cameraDuration, true)
end

function AvatarScene:doSpringArmTween(to, duration)
	local from = self.curCameraMode:getSpringArmLen()

	to = to or 0
	duration = duration or 1

	if DoTweenAnimMgr.IsTweening(self.camera.gameObject, LuaUIUtils.TweenId("armLenTween")) then
		DoTweenAnimMgr.Kill(self.camera.gameObject, LuaUIUtils.TweenId("armLenTween"))
	end

	DoTweenAnimMgr.DoFloat(self.camera.gameObject, from, to, LuaUIUtils.TweenId("armLenTween"), duration, 0, CS.DG.Tweening.Ease.__CastFrom(1), function()
		return
	end, function(len)
		self.curCameraMode:setSpringArmLen(len)
	end, function()
		return
	end, false)
end

function AvatarScene:doVerticalTween(to, duration, noConstrain)
	local from = self.curCameraMode.cameraMode.pivotOffset.y

	to = to or 0
	duration = duration or 1

	DoTweenAnimMgr.DoFloat(self.camera.gameObject, from, to, LuaUIUtils.TweenId("armLenTween"), duration, 0, CS.DG.Tweening.Ease.__CastFrom(1), function()
		return
	end, function(len)
		if noConstrain then
			self.curCameraMode:setPivotOffsetY(len)
		else
			self.curCameraMode:moveCameraInVertical(-len)
		end
	end, function()
		return
	end, false)
end

function AvatarScene:doRotationOffsetYTween(to, duration)
	local from = self.curCameraMode.cameraMode.rotationOffset.y

	to = to or 0
	duration = duration or 1

	DoTweenAnimMgr.DoFloat(self.camera.gameObject, from, to, LuaUIUtils.TweenId("armLenTween"), duration, 0, CS.DG.Tweening.Ease.__CastFrom(1), function()
		return
	end, function(rotationOffsetY)
		local offset = self.curCameraMode.cameraMode.rotationOffset

		self.curCameraMode.cameraMode.rotationOffset = Vector3(offset.x, rotationOffsetY, offset.z)
	end, function()
		return
	end, false)
end

function AvatarScene:doMoveTween(start, to, duration, finished)
	start = start or Vector3.zero
	to = to or Vector3.zero
	duration = duration or 1

	DoTweenAnimMgr.DoVector3(self.camera.gameObject, LuaUIUtils.TweenId("cameraMove"), start, to, duration, 0, CS.DG.Tweening.Ease.__CastFrom(1), function()
		return
	end, function(x, y, z)
		self.curCameraMode:moveCameraInVector(x, y)
	end, function()
		if finished then
			finished()
		end
	end)
end

function AvatarScene:onAllEntityLoaded()
	if self.waitFreezeEntity then
		local entity = self:getCurEntity()
		local state = entity:getCurrentPlayableState(PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY)
		local petData = PetData[self.curEntityId]

		if petData then
			state = entity:getCurrentPlayableState(PlayableConst.AnimationLayer.HUMAN_LAYER_BASE)
		end

		if state then
			state:SetSpeed(0)

			state.Time = 0

			local presetData = pg.game.avatar:getAvatarPresetData(self.curEntityId)

			if presetData then
				-- block empty
			end
		end

		self.waitFreezeEntity = false
	end
end

function AvatarScene:registerAutoSave()
	if pg.me then
		return
	end

	self:unRegisterAutoSave()

	self.autoSaveTimer = TimerManager.addRepeatTimer(5, function()
		if self.pauseAutoSave then
			return
		end

		local presetKey = self:getCurEntityId()

		AvatarUtils.saveCustomDataToDisk(presetKey)
	end)
end

function AvatarScene:unRegisterAutoSave()
	if self.autoSaveTimer then
		TimerManager.removeTimer(self.autoSaveTimer)

		self.autoSaveTimer = nil
	end
end

function AvatarScene:applyBackgroundTransform(gameObj, bgId)
	if IsNil(gameObj) then
		return
	end

	local backgroundId = tonumber(bgId)
	local backgroundData = backgroundId and AppearanceBackgroundData[backgroundId]
	local transformData = backgroundData and backgroundData.position
	local position = Utils.isTable(transformData) and transformData[1]
	local rotation = Utils.isTable(transformData) and transformData[2]
	local transform = gameObj.transform

	if Utils.isTable(position) then
		transform.localPosition = Vector3(tonumber(position[1]) or 0, tonumber(position[2]) or 0, tonumber(position[3]) or 0)
	else
		transform.localPosition = Vector3.zero
	end

	if Utils.isTable(rotation) then
		transform.localRotation = Quaternion.Euler(tonumber(rotation[1]) or 0, tonumber(rotation[2]) or 0, tonumber(rotation[3]) or 0)
	else
		transform.localRotation = Quaternion.identity
	end
end

function AvatarScene:setBackground(resId, bgId)
	if self.disableBackground then
		return
	end

	self.bgId = bgId

	if self.bgResId == resId and self.curBgGo then
		self:applyBackgroundTransform(self.curBgGo, bgId)

		for i = 1, #(self.vitalityBgs or {}) do
			if self.vitalityBgs[i] then
				self.vitalityBgs[i].gameObject:SetActiveEx(i == self.bgId)
			end
		end

		return
	end

	self.bgResId = resId

	if self.curBgGo then
		pg.global.resMgr:RemoveInstanceToCache(self.curBgGo)

		self.curBgGo = nil
	end

	local requestResId = resId
	local requestBgId = bgId

	pg.global.resMgr:GetInstanceFromCacheByLua(resId, function(gameObj, _)
		if self.bgResId ~= requestResId or self.bgId ~= requestBgId then
			pg.global.resMgr:RemoveInstanceToCache(gameObj)

			return
		end

		self.curBgGo = gameObj

		self:applyBackgroundTransform(self.curBgGo, requestBgId)

		local objectReference = gameObj.transform:Find("Global"):GetComponent("ObjectReference")
		local mPlane = objectReference:GetRefValue("mPlane")
		local vfxPlane = objectReference:GetRefValue("vfxPlane")
		local boyLightTransform = objectReference:GetRefValue("boyLightTransform")
		local girlLightTransform = objectReference:GetRefValue("girlLightTransform")
		local pramonLightTransform = objectReference:GetRefValue("pramonLightTransform")
		local twoLightTransform = objectReference:GetRefValue("twoLightTransform")
		local vitality101Transform = objectReference:GetRefValue("101Transform")
		local vitality102Transform = objectReference:GetRefValue("102Transform")
		local vitality103Transform = objectReference:GetRefValue("103Transform")
		local vitality104Transform = objectReference:GetRefValue("104Transform")
		local vitality105Transform = objectReference:GetRefValue("105Transform")
		local vitality106Transform = objectReference:GetRefValue("106Transform")
		local vitality107Transform = objectReference:GetRefValue("107Transform")

		self.vitalityBgs = {}
		self.vitalityBgs[1] = vitality101Transform
		self.vitalityBgs[2] = vitality102Transform
		self.vitalityBgs[3] = vitality103Transform
		self.vitalityBgs[4] = vitality104Transform
		self.vitalityBgs[5] = vitality105Transform
		self.vitalityBgs[6] = vitality106Transform
		self.vitalityBgs[7] = vitality107Transform

		for i = 1, #self.vitalityBgs do
			if self.vitalityBgs[i] then
				self.vitalityBgs[i].gameObject:SetActiveEx(i == self.bgId)
			end
		end

		if mPlane then
			self.mPlane = mPlane
		end

		if vfxPlane then
			self.vfxPlane = vfxPlane
		end

		if boyLightTransform then
			self.boyLightTransform = boyLightTransform
		end

		if girlLightTransform then
			self.girlLightTransform = girlLightTransform
		end

		if pramonLightTransform then
			self.pramonLightTransform = pramonLightTransform
		end

		if twoLightTransform then
			self.twoLightTransform = twoLightTransform

			self.twoLightTransform.gameObject:SetActiveEx(false)
		end

		self:switchLight(true)
		pgUtils.SetAllEffLodCamera(self.curBgGo.transform, self.camera)
	end, 1, nil, self.extraTransform, false, 0)
end

function AvatarScene:recordCurLight()
	local activatedLightTransform = {}

	if self.boyLightTransform and self.boyLightTransform.gameObject.activeSelf then
		activatedLightTransform[#activatedLightTransform + 1] = self.boyLightTransform
	end

	if self.girlLightTransform and self.girlLightTransform.gameObject.activeSelf then
		activatedLightTransform[#activatedLightTransform + 1] = self.girlLightTransform
	end

	if self.pramonLightTransform and self.pramonLightTransform.gameObject.activeSelf then
		activatedLightTransform[#activatedLightTransform + 1] = self.pramonLightTransform
	end

	return activatedLightTransform
end

function AvatarScene:restorePrevLight(activatedLightTransform)
	if not activatedLightTransform then
		return
	end

	for _, lightTrans in pairs(activatedLightTransform) do
		if lightTrans then
			lightTrans.gameObject:SetActiveEx(true)
		end
	end
end

function AvatarScene:showPairLights(show)
	if self.twoLightTransform then
		self.twoLightTransform.gameObject:SetActiveEx(show)
	end
end

function AvatarScene:hideAllLights()
	if self.girlLightTransform then
		self.girlLightTransform.gameObject:SetActiveEx(false)
	end

	if self.boyLightTransform then
		self.boyLightTransform.gameObject:SetActiveEx(false)
	end

	if self.pramonLightTransform then
		self.pramonLightTransform.gameObject:SetActiveEx(false)
	end

	if self.twoLightTransform then
		self.twoLightTransform.gameObject:SetActiveEx(false)
	end
end

return AvatarScene
