-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Scenes\\UIScenes\\CashShopExScene.lua

local Class = require("Core.Framework.Class")
local UISceneBase = require("GameApp.UIScene.UISceneBase")
local LoggerManager = require("Core.Log.LoggerManager")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ShopConstantData = require("Data.shopmall_constant_data")
local logger = LoggerManager.getLogger("CashShopExScene")
local CAMERA_BLEND_DURATION = 0.5
local CAMERA_MOVE_TWEEN_ID = LuaUIUtils.TweenId("cashShopExSceneCameraMove")
local CAMERA_ROTATE_TWEEN_ID = LuaUIUtils.TweenId("cashShopExSceneCameraRotate")
local CAMERA_FOV_TWEEN_ID = LuaUIUtils.TweenId("cashShopExSceneCameraFov")
local CAMERA_ORTHOGRAPHIC_TWEEN_ID = LuaUIUtils.TweenId("cashShopExSceneCameraOrthographic")
local CashShopExScene = Class.LightClass("CashShopExScene", UISceneBase)

function CashShopExScene:onStart()
	local globalTransform = self.scene and self.scene.transform:Find("Global")

	self.objectReference = globalTransform and globalTransform:GetComponent("ObjectReference")

	if IsNil(self.objectReference) then
		logger:error("商城特殊商品 UI 场景缺少 Global/ObjectReference, res=%s", tostring(self.resId))

		return
	end

	self.camera = self.objectReference:GetRefValue("camera")
	self.entityRootTransform = self.objectReference:GetRefValue("entityRootTransform")
	self.boyLight = self.objectReference:GetRefValue("boyLight")
	self.girlLight = self.objectReference:GetRefValue("girlLight")

	self:syncLight(false)

	if NotNil(self.camera) then
		self.cameraPosition = self.camera.transform.position
		self.cameraRotation = self.camera.transform.rotation
		self.cameraLocalEulerAngles = self.camera.transform.localEulerAngles
		self.cameraFieldOfView = self.camera.fieldOfView
		self.cameraOrthographicSize = self.camera.orthographicSize
		self.cameraEnabled = self.camera.enabled
	else
		logger:error("商城特殊商品 UI 场景缺少 camera, res=%s", tostring(self.resId))
	end

	if IsNil(self.entityRootTransform) then
		logger:error("商城特殊商品 UI 场景缺少 entityRootTransform, res=%s", tostring(self.resId))
	end
end

function CashShopExScene:syncLight(hasModel, isFemale)
	hasModel = hasModel == true

	if NotNil(self.boyLight) then
		self.boyLight.gameObject:SetActiveEx(hasModel and isFemale ~= true)
	end

	if NotNil(self.girlLight) then
		self.girlLight.gameObject:SetActiveEx(hasModel and isFemale == true)
	end
end

function CashShopExScene:checkSceneValid()
	return NotNil(self.camera) and NotNil(self.entityRootTransform)
end

function CashShopExScene:getEntityRootTransform()
	return self.entityRootTransform
end

function CashShopExScene:getCamera()
	return self.camera
end

function CashShopExScene:beginTimelineCamera()
	if IsNil(self.camera) then
		return false
	end

	self:resetCamera()

	local vcManager = pg.global.cameraMgr.vcManager
	local rootGroup = vcManager and vcManager.rootGroup

	if rootGroup == nil then
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

function CashShopExScene:resetTimelineCameraBlend()
	local vcManager = pg.global.cameraMgr.vcManager
	local ownsOutput = vcManager ~= nil and self.timelineRootGroup ~= nil and vcManager.rootGroup == self.timelineRootGroup and self.timelineRootGroup.targetCamera == self.camera

	if not ownsOutput then
		return
	end

	local rootCameraGroup = vcManager.rootCameraGroup

	if rootCameraGroup then
		rootCameraGroup:ResetBlendStack()
	end
end

function CashShopExScene:stopCameraBlend()
	self.cameraBlendSerial = (self.cameraBlendSerial or 0) + 1
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

function CashShopExScene:releaseTimelineCamera()
	self:resetTimelineCameraBlend()

	local rootGroup = self.timelineRootGroup

	if rootGroup and rootGroup.targetCamera == self.camera then
		rootGroup.targetCamera = self.timelineOriginalOutputCamera
	end

	self.timelineRootGroup = nil
	self.timelineOriginalOutputCamera = nil
end

function CashShopExScene:finishTimelineCamera()
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

function CashShopExScene:blendTimelineCameraToDefault()
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

	local serial = self.cameraBlendSerial
	local ease = CS.DG.Tweening.Ease.__CastFrom(1)
	local blendConfig = ShopConstantData.blend_duration
	local configuredDuration = blendConfig and tonumber(blendConfig.number)
	local blendDuration = configuredDuration and configuredDuration >= 0 and configuredDuration or CAMERA_BLEND_DURATION

	DoTweenAnimMgr.GlobalMove(camera.transform, CAMERA_MOVE_TWEEN_ID, self.cameraPosition, blendDuration, 0, ease, nil, function()
		if self.cameraBlendSerial == serial then
			self:resetCamera()
		end
	end)
	DoTweenAnimMgr.Rotate(camera.transform, CAMERA_ROTATE_TWEEN_ID, self.cameraLocalEulerAngles, blendDuration, 0, ease, nil)
	DoTweenAnimMgr.Scalar(camera.transform, CAMERA_FOV_TWEEN_ID, pose.fieldOfView, self.cameraFieldOfView, blendDuration, 0, ease, function(value)
		if self.cameraBlendSerial == serial and NotNil(self.camera) then
			self.camera.fieldOfView = value
		end
	end)
	DoTweenAnimMgr.Scalar(camera.transform, CAMERA_ORTHOGRAPHIC_TWEEN_ID, pose.orthographicSize, self.cameraOrthographicSize, blendDuration, 0, ease, function(value)
		if self.cameraBlendSerial == serial and NotNil(self.camera) then
			self.camera.orthographicSize = value
		end
	end)
end

function CashShopExScene:endTimelineCamera()
	self:releaseTimelineCamera()
	self:resetCamera()
end

function CashShopExScene:resetCamera()
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

function CashShopExScene:onDestroy()
	self:syncLight(false)
	self:endTimelineCamera()

	self.camera = nil
	self.cameraPosition = nil
	self.cameraRotation = nil
	self.cameraLocalEulerAngles = nil
	self.cameraFieldOfView = nil
	self.cameraOrthographicSize = nil
	self.cameraEnabled = nil
	self.timelineRootGroup = nil
	self.timelineOriginalOutputCamera = nil
	self.entityRootTransform = nil
	self.boyLight = nil
	self.girlLight = nil
	self.objectReference = nil
end

return CashShopExScene
