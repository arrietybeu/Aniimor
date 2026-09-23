-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Scenes\\UIScenes\\UIScenePreviewController.lua

local Class = require("Core.Framework.Class")
local AvatarCameraMode = require("GameApp.Camera.CameraMode.AvatarCameraMode")
local CameraConst = require("GameApp.Camera.CameraConst")
local Utils = require("Common.Utils.Utils")
local AvatarPresetData = require("Data.avatar_preset_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local UIScenePreviewController = Class.LightClass("UIScenePreviewController")
local ID_ARM_LEN = "armLenTween"
local ID_CAMERA_AREA = "cameraAreaTween"
local Vector3 = Vector3
local fingerGestures = fingerGestures
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro

UIScenePreviewController.AREA = {
	BOTTOM = 20,
	MID = 0,
	TOP = -20
}
UIScenePreviewController.GAMEPAD_PRESS = {
	CAMERA_ZOOM = 1,
	SWIPE_MODEL = 0
}
UIScenePreviewController.SCROLL_DURATION = 0.1

function UIScenePreviewController:ctor(scene)
	self.scene = scene
end

function UIScenePreviewController:ensureRuntimeData()
	local scene = self.scene

	scene.gestures = scene.gestures or {}
	scene.cameraModes = scene.cameraModes or {}
end

function UIScenePreviewController:getPreviewCamera()
	local scene = self.scene

	return scene.camera or scene.uICameraCamera
end

function UIScenePreviewController:getPreviewCurrentEntity()
	local scene = self.scene

	if scene.getPreviewCurrentEntity then
		return scene:getPreviewCurrentEntity()
	end

	if scene.getCurEntity then
		return scene:getCurEntity()
	end

	if scene.curShowPetTemplateId and scene.entPoolTable then
		return scene.entPoolTable[scene.curShowPetTemplateId]
	end

	return nil
end

function UIScenePreviewController:getPreviewCameraRootTransform()
	local scene = self.scene

	if scene.getPreviewCameraRootTransform then
		return scene:getPreviewCameraRootTransform()
	end

	return scene.entityRootTransform or scene.petsParentTransform
end

function UIScenePreviewController:getDefaultCameraModeName()
	local scene = self.scene

	if scene.getPreviewDefaultModeName then
		return scene:getPreviewDefaultModeName()
	end

	if scene.CAMERA and scene.CAMERA.SIMPLE then
		return scene.CAMERA.SIMPLE
	end

	if scene.CAMERA and scene.CAMERA.PET then
		return scene.CAMERA.PET
	end

	return nil
end

function UIScenePreviewController:getInitSpringArmLen()
	local scene = self.scene

	if scene.getPreviewInitSpringArmLen then
		return scene:getPreviewInitSpringArmLen()
	end

	local defaultModeName = self:getDefaultCameraModeName()

	if scene.CAMERA and scene.CAMERA.PET and defaultModeName == scene.CAMERA.PET then
		local petConfig = self:getPreviewCameraConfig(defaultModeName)

		return petConfig and petConfig.defaultZoom or nil
	end

	return 7
end

function UIScenePreviewController:getInitVerticalOffset()
	local scene = self.scene

	if scene.getPreviewInitVerticalOffset then
		return scene:getPreviewInitVerticalOffset()
	end

	local defaultModeName = self:getDefaultCameraModeName()

	if scene.CAMERA and scene.CAMERA.PET and defaultModeName == scene.CAMERA.PET then
		local petConfig = self:getPreviewCameraConfig(defaultModeName)

		return petConfig and petConfig.defaultY or nil
	end

	return 0.8
end

function UIScenePreviewController:getPreviewCameraConfig(modeName)
	local scene = self.scene

	if scene.getPreviewCameraConfig then
		return scene:getPreviewCameraConfig(modeName)
	end

	if scene.CAMERA and scene.CAMERA.PET and modeName == scene.CAMERA.PET then
		return scene.PET_CONFIG
	end

	if not scene.CONFIG then
		return nil
	end

	local presetData = pg.game.avatar:getAvatarPresetData(scene.curEntityId) or {}
	local body = presetData.body or 11
	local baseConfig = scene.CONFIG[body]

	if not baseConfig then
		return nil
	end

	local cameraConfig = Utils.deepCopyTable(baseConfig)

	if scene.CAMERA and scene.CAMERA.FIXED and modeName == scene.CAMERA.FIXED then
		cameraConfig.minZoom = baseConfig.maxZoom
		cameraConfig.minZoomOffsetY = Vector2.New(baseConfig.maxZoomOffsetY, baseConfig.maxZoomOffsetY)
		cameraConfig.maxZoomOffsetY = baseConfig.maxZoomOffsetY
		cameraConfig.defaultZoom = baseConfig.maxZoom
		cameraConfig.defaultY = baseConfig.maxZoomOffsetY
	end

	return cameraConfig
end

function UIScenePreviewController:createCameraMode(modeName, cameraName)
	local scene = self.scene

	if scene.cameraModes[modeName] then
		return
	end

	local cameraMode = AvatarCameraMode.new()

	pg.game.camera:addUICamera(cameraMode, CameraConst.PRIORITY_SIMPLE_CONTROL)
	cameraMode:setCameraName(cameraName)

	scene.cameraModes[modeName] = cameraMode
end

function UIScenePreviewController:initCameraModes()
	self:ensureRuntimeData()

	local scene = self.scene
	local camera = self:getPreviewCamera()

	if not camera then
		return
	end

	pg.game.camera:setUICameraObject(camera)

	if scene.CAMERA and scene.CAMERA.SIMPLE then
		self:createCameraMode(scene.CAMERA.SIMPLE, CameraConst.CAMERA_NAME_AVATAR)
	end

	if scene.CAMERA and scene.CAMERA.FIXED then
		self:createCameraMode(scene.CAMERA.FIXED, CameraConst.CAMERA_NAME_FIXED_AVATAR)
	end

	if scene.CAMERA and scene.CAMERA.PET then
		self:createCameraMode(scene.CAMERA.PET, CameraConst.CAMERA_NAME_PET)
	end

	pg.game.camera:setUIGroupActive(true)

	local defaultModeName = self:getDefaultCameraModeName()

	if not defaultModeName then
		return
	end

	self:enableCameraMode(defaultModeName)

	if scene.curCameraMode then
		local initSpringArmLen = self:getInitSpringArmLen()

		if initSpringArmLen ~= nil then
			scene.curCameraMode:setSpringArmLen(initSpringArmLen)
		end

		local initVerticalOffset = self:getInitVerticalOffset()

		if initVerticalOffset ~= nil then
			scene.curCameraMode:moveCameraInVertical(initVerticalOffset)
		end
	end
end

function UIScenePreviewController:enableCameraMode(modeName)
	self:ensureRuntimeData()

	local scene = self.scene

	for name, cameraMode in pairs(scene.cameraModes) do
		if name == modeName then
			scene.curCameraMode = cameraMode

			cameraMode:setActive(true)

			local cameraConfig = self:getPreviewCameraConfig(modeName)
			local cameraRootTransform = self:getPreviewCameraRootTransform()

			if cameraRootTransform and cameraConfig then
				cameraMode:resetAvatarCamera(cameraRootTransform, cameraConfig)
			end
		else
			cameraMode:setActive(false)
		end
	end
end

function UIScenePreviewController:disableAllCameras()
	local scene = self.scene

	if not scene.cameraModes then
		pg.game.camera:setUIGroupActive(false)

		return
	end

	for _, cameraMode in pairs(scene.cameraModes) do
		pg.game.camera:removeUICamera(cameraMode)
	end

	pg.game.camera:setUIGroupActive(false)
end

function UIScenePreviewController:startPress(pressFunc, delta, offset)
	local scene = self.scene

	if scene.pressTimer ~= nil then
		return
	end

	scene.pressTimer = scene:startTimer(function()
		self:inPressing(pressFunc, delta, offset)
	end, 0, true)
end

function UIScenePreviewController:inPressing(pressFunc, delta, offset)
	if pressFunc == self.GAMEPAD_PRESS.CAMERA_ZOOM then
		self:cameraZoomIn(delta, offset)
	elseif pressFunc == self.GAMEPAD_PRESS.SWIPE_MODEL then
		self:swipeModel(self.scene.moveVec2)
	end
end

function UIScenePreviewController:endPress()
	local scene = self.scene

	if scene.pressTimer == nil then
		return
	end

	scene:killTimer(scene.pressTimer)

	scene.pressTimer = nil
end

function UIScenePreviewController:addCameraZoomKeyBinding(gameObject, callback, isModelRotationBlocked)
	local cameraZoomBinding = KeyBindingPro.GetOrAddKeyBindingByName(gameObject, "cameraZoom")

	cameraZoomBinding.actionPath = "Camera/CameraZoom"
	cameraZoomBinding.isVirtual = true

	function cameraZoomBinding.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			if callback then
				callback(inputInfo)
			else
				local uiMgr = pg.global.uiMgr
				local canvasSize = uiMgr.uiRootCanvasSize
				local delta = -inputInfo.valueVec2.y

				if delta < 0 then
					local canvasPos = uiMgr:ScenePositionToCanvasPosition(UnityInput.mousePosition)
					local offset = 0

					if canvasPos.y > canvasSize.y * 0.6 then
						offset = self.AREA.TOP
					elseif canvasPos.y > canvasSize.y * 0.3 then
						offset = self.AREA.MID
					else
						offset = self.AREA.BOTTOM
					end

					self:cameraZoomIn(delta, offset)
				else
					self:cameraZoomIn(delta)
				end
			end
		end

		return true
	end

	local cameraZoomInGamepadBinding = KeyBindingPro.GetOrAddKeyBindingByName(gameObject, "cameraZoomInGamepad")

	cameraZoomInGamepadBinding.actionPath = "Hud/GamepadZoomIn"
	cameraZoomInGamepadBinding.isVirtual = true

	function cameraZoomInGamepadBinding.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			if callback then
				callback(inputInfo)
			else
				self:startPress(self.GAMEPAD_PRESS.CAMERA_ZOOM, -0.5)
			end
		elseif inputInfo.phase == "Canceled" then
			self:endPress()
		end

		return true
	end

	local cameraZoomOutGamepadBinding = KeyBindingPro.GetOrAddKeyBindingByName(gameObject, "cameraZoomOutGamepad")

	cameraZoomOutGamepadBinding.actionPath = "Hud/GamepadZoomOut"
	cameraZoomOutGamepadBinding.isVirtual = true

	function cameraZoomOutGamepadBinding.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			if callback then
				callback(inputInfo)
			else
				self:startPress(self.GAMEPAD_PRESS.CAMERA_ZOOM, 0.5)
			end
		elseif inputInfo.phase == "Canceled" then
			self:endPress()
		end

		return true
	end

	local swipeModelGamepadBinding = KeyBindingPro.GetOrAddKeyBindingByName(gameObject, "swipeModelGamepad")

	swipeModelGamepadBinding.actionPath = "Hud/RightStickMove"
	swipeModelGamepadBinding.isVirtual = true

	function swipeModelGamepadBinding.luaTrigger(inputInfo)
		if isModelRotationBlocked and isModelRotationBlocked() then
			self:endPress()

			return false
		end

		if inputInfo.phase == "Performed" then
			if callback then
				callback(inputInfo)
			else
				self.scene.moveVec2 = inputInfo.valueVec2
				self.scene.moveVec2.x = self.scene.moveVec2.x * 10
				self.scene.moveVec2.y = -self.scene.moveVec2.y * 10

				self:startPress(self.GAMEPAD_PRESS.SWIPE_MODEL)
			end
		elseif inputInfo.phase == "Canceled" then
			self:endPress()
		end

		return true
	end
end

function UIScenePreviewController:registerGesture(uiId, extraInfo)
	self:ensureRuntimeData()

	local scene = self.scene

	scene.gestures[uiId] = true

	if not Utils.isEmptyTable(scene.gestures) then
		scene:claimGlobalGesture()
		fingerGestures.Active()
		fingerGestures.EnableTwist(false)
		fingerGestures.EnablePinch(true)

		if extraInfo and extraInfo.maskRayBoxTrans and not IsNil(extraInfo.maskRayBoxTrans) then
			extraInfo.maskRayBoxTrans.localScale = Vector3.zero
		end

		scene.muteRotate = false

		function fingerGestures.luaOnTouchUp2Fingers()
			scene.muteRotate = false
		end

		function fingerGestures.luaOnSwipeStart(gesture)
			if self:isModelRotationBlocked(extraInfo) then
				scene.swipeStart = false

				if extraInfo and extraInfo.maskRayBoxTrans and not IsNil(extraInfo.maskRayBoxTrans) then
					extraInfo.maskRayBoxTrans.localScale = Vector3.zero
				end

				return
			end

			if scene.muteRotate then
				return
			end

			if gesture.pickedUIElement and gesture.pickedUIElement.name == "GestureRayBox" then
				scene.swipeStart = true

				if extraInfo and extraInfo.maskRayBoxTrans and not IsNil(extraInfo.maskRayBoxTrans) then
					extraInfo.maskRayBoxTrans.localScale = Vector3.one
				end
			end
		end

		function fingerGestures.luaOnSwipe(gesture)
			if self:isModelRotationBlocked(extraInfo) then
				scene.swipeStart = false

				if extraInfo and extraInfo.maskRayBoxTrans and not IsNil(extraInfo.maskRayBoxTrans) then
					extraInfo.maskRayBoxTrans.localScale = Vector3.zero
				end

				return
			end

			if scene.muteRotate then
				return
			end

			if scene.swipeStart then
				self:swipeModel(gesture.deltaPosition, extraInfo)
			end
		end

		function fingerGestures.luaOnSwipeEnd()
			scene.swipeStart = false

			if extraInfo and extraInfo.maskRayBoxTrans and not IsNil(extraInfo.maskRayBoxTrans) then
				extraInfo.maskRayBoxTrans.localScale = Vector3.zero
			end
		end

		function fingerGestures.luaOnPinchIn(gesture)
			if gesture.touchCount >= 2 then
				scene.muteRotate = true

				self:cameraZoomIn(gesture.deltaPinch * 0.06)
			end
		end

		function fingerGestures.luaOnPinchOut(gesture)
			if gesture.touchCount >= 2 then
				scene.muteRotate = true

				self:cameraZoomIn(-gesture.deltaPinch * 0.06, self.AREA.TOP)
			end
		end
	end
end

function UIScenePreviewController:isModelRotationBlocked(extraInfo)
	return extraInfo and extraInfo.isModelRotationBlocked and extraInfo.isModelRotationBlocked() == true
end

function UIScenePreviewController:unRegisterGesture(uiId, force)
	local scene = self.scene

	if scene.gestures then
		scene.gestures[uiId] = nil

		if force then
			scene.gestures = {}
		end
	end

	if scene.gestures and Utils.isEmptyTable(scene.gestures) then
		if scene:tryReleaseGlobalGesture() then
			fingerGestures.DeActive()
		end

		scene.muteRotate = false

		local mobileOperateCtrl = pg.global.ui.mobileOperate

		if mobileOperateCtrl and mobileOperateCtrl.moveJoyStick then
			mobileOperateCtrl.moveJoyStick:initGesture()
		end
	end
end

function UIScenePreviewController:cameraZoomIn(delta, area)
	local scene = self.scene
	local entity = self:getPreviewCurrentEntity()

	if entity == nil or scene.curCameraMode == nil then
		return
	end

	area = area or self.AREA.MID

	local from = scene.curCameraMode:getSpringArmLen()
	local to = from + delta
	local camera = self:getPreviewCamera()

	if not camera then
		return
	end

	if DoTweenAnimMgr.IsTweening(camera.gameObject, LuaUIUtils.TweenId(ID_ARM_LEN)) then
		DoTweenAnimMgr.Kill(camera.gameObject, LuaUIUtils.TweenId(ID_ARM_LEN))
	end

	if DoTweenAnimMgr.IsTweening(camera.gameObject, LuaUIUtils.TweenId(ID_CAMERA_AREA)) then
		DoTweenAnimMgr.Kill(camera.gameObject, LuaUIUtils.TweenId(ID_CAMERA_AREA))
	end

	DoTweenAnimMgr.DoFloat(camera.gameObject, from, to, LuaUIUtils.TweenId(ID_CAMERA_AREA), self.SCROLL_DURATION, 0, CS.DG.Tweening.Ease.__CastFrom(1), function()
		return
	end, function(len)
		scene.curCameraMode:setSpringArmLen(len)

		local verticalMoveScale = scene.curCameraMode.getVerticalMoveScale and scene.curCameraMode:getVerticalMoveScale() or 1

		scene.curCameraMode:moveCameraInVertical(area * verticalMoveScale)
	end, function()
		return
	end, false)
end

function UIScenePreviewController:swipeModel(moveVector2)
	local scene = self.scene
	local entity = self:getPreviewCurrentEntity()

	if entity == nil then
		return
	end

	if math.abs(moveVector2.y) > math.abs(moveVector2.x) then
		if scene.curCameraMode then
			local verticalMoveScale = scene.curCameraMode.getVerticalMoveScale and scene.curCameraMode:getVerticalMoveScale() or 1

			scene.curCameraMode:moveCameraInVertical(moveVector2.y * verticalMoveScale)
		end
	else
		self:rotatePreviewEntity(-moveVector2.x * 0.3)
	end
end

function UIScenePreviewController:rotatePreviewEntity(deltaAngle)
	local scene = self.scene

	if scene.rotatePreviewEntity then
		scene:rotatePreviewEntity(deltaAngle)

		return
	end

	local entity = self:getPreviewCurrentEntity()

	if entity and entity.eModel then
		entity.eModel:RotateAroundTransform(deltaAngle)
	end
end

function UIScenePreviewController:setPivotOffsetX(offsetX)
	local scene = self.scene

	if scene.curCameraMode == nil then
		return
	end

	scene.curCameraMode:setPivotOffsetX(offsetX)
end

function UIScenePreviewController:onDestroy()
	local scene = self.scene

	self:endPress()
	self:disableAllCameras()

	if scene and scene:tryReleaseGlobalGesture() then
		fingerGestures.DeActive()
	end
end

return UIScenePreviewController
