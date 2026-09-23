-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Scenes\\UIScenes\\PetTransmogScene.lua

local ClientUtils = require("Utils.ClientUtils")
local Class = require("Core.Framework.Class")
local UISceneBase = require("GameApp.UIScene.UISceneBase")
local ClientConst = require("Const.ClientConst")
local UIConst = require("Const.UIConst")
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")
local PetTransmogUtils = require("GameApp.PetTransmog.PetTransmogUtils")
local Time = require("Core.Common.Time")
local PlayableConst = require("Common.Const.PlayableConst")
local AnimationUtils = require("Common.Utils.AnimationUtils")
local FixedCameraMode = require("GameApp.Camera.CameraMode.FixedCameraMode")
local CameraConst = require("GameApp.Camera.CameraConst")
local Const = require("Common.Const.Const")
local TimerManager = require("Core.Timer.TimerManager")
local fingerGestures = fingerGestures
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local TRANSMOG_ENTITY_CACHE_MAX = 2
local TRANSMOG_ATTACH_PREFIX = "PetTransmog_"
local DEFAULT_PREVIEW_ANIM = "Idle"
local PREVIEW_ANIM_SYNC_THRESHOLD = 0.2
local SWITCH_READY_TIMEOUT = 1.5
local PetTransmogScene = Class.LightClass("PetTransmogScene", UISceneBase)

PetTransmogScene.SNAPSHOT_CROP_SCALE = 0.8
PetTransmogScene.SNAPSHOT_CROP_OFFSET_X = -0.01
PetTransmogScene.SNAPSHOT_CROP_OFFSET_Y = 0.04
PetTransmogScene.SNAPSHOT_EDGE_TRIM = 0.12
PetTransmogScene.SNAPSHOT_UI_HIDE_TIMEOUT = 5

function PetTransmogScene:onCtor()
	self.curEntityId = nil
	self.curEntityKey = nil
	self.entityCache = {}
	self.entityCacheOrder = {}
	self.switchSeq = 0
	self.previewAnimStartTime = nil
	self.previewAnimName = nil
	self.isSnapshotInputLocked = false
	self.pendingSwitchReadyCallback = nil
	self.switchReadyTimer = nil
end

function PetTransmogScene:setHairLayerCount(layerCount)
	UISceneBase.setHairLayerCount(self, layerCount)

	for _, entity in pairs(self.entityCache) do
		self:applyHairLayerCount(entity)
	end
end

function PetTransmogScene:onStart(param)
	self.objectReference = self.scene.transform:Find("Global"):GetComponent("ObjectReference")

	Vector3.enableCreateFromCache()

	self.scene.transform.position = Vector3(0, 500, 0)

	Vector3.disableCreateFromCache()

	self.camera = self.objectReference:GetRefValue("camera")
	self.entityRootTransform = self.objectReference:GetRefValue("entityRootTransform")

	self:initCameraMode()
	self:initGestures()
end

function PetTransmogScene:initGestures()
	self:claimGlobalGesture()
	fingerGestures.Active()
	fingerGestures.EnableTwist(false)
	fingerGestures.EnablePinch(false)

	function fingerGestures.luaOnSwipe(gesture)
		if self.isSnapshotInputLocked or gesture.pickedUIElement then
			return
		end

		self:rotateEntityBy(-gesture.deltaPosition.x * 0.2)
	end
end

function PetTransmogScene:addGamepadRotationBinding(gameObject)
	if not gameObject then
		return
	end

	local swipeModelGamepadBinding = KeyBindingPro.GetOrAddKeyBindingByName(gameObject, "swipeModelGamepad")

	swipeModelGamepadBinding.actionPath = "Hud/RightStickMove"
	swipeModelGamepadBinding.isVirtual = true

	function swipeModelGamepadBinding.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self.gamepadMoveVec2 = inputInfo.valueVec2
			self.gamepadMoveVec2.x = self.gamepadMoveVec2.x * 10
			self.gamepadMoveVec2.y = -self.gamepadMoveVec2.y * 10

			self:startGamepadPress()
		elseif inputInfo.phase == "Canceled" then
			self:endGamepadPress()
		end

		return true
	end
end

function PetTransmogScene:startGamepadPress()
	if self.gamepadPressTimer ~= nil then
		return
	end

	self.gamepadPressTimer = self:startTimer(function()
		self:inGamepadPressing()
	end, 0, true)
end

function PetTransmogScene:inGamepadPressing()
	if not self.gamepadMoveVec2 then
		return
	end

	if math.abs(self.gamepadMoveVec2.y) > math.abs(self.gamepadMoveVec2.x) then
		-- block empty
	else
		local deltaAngle = -self.gamepadMoveVec2.x * 0.3

		self:rotateEntityBy(deltaAngle)
	end
end

function PetTransmogScene:endGamepadPress()
	if self.gamepadPressTimer == nil then
		return
	end

	self:killTimer(self.gamepadPressTimer)

	self.gamepadPressTimer = nil
end

function PetTransmogScene:disableGestures()
	if self:tryReleaseGlobalGesture() then
		fingerGestures.luaOnSwipe = nil

		fingerGestures.DeActive()
	end

	self:endGamepadPress()
end

function PetTransmogScene:initCameraMode()
	Vector3.enableCreateFromCache()

	self.cameraParam = {
		pos = self.camera.transform.position,
		rot = self.camera.transform.rotation,
		fov = self.camera.fieldOfView
	}

	Quaternion.removeTempQuaterion(self.cameraParam.rot)
	Vector3.disableCreateFromCache(self.cameraParam.pos)

	self.cameraMode = FixedCameraMode.new()

	self.cameraMode:setCameraName(CameraConst.CAMERA_NAME_FIXED)
	pg.game.camera:addUICamera(self.cameraMode, CameraConst.PRIORITY_FIXED)
	self:onInitCamera()
end

function PetTransmogScene:onInitCamera()
	if not self.camera or not self.cameraMode or not self.cameraParam then
		return
	end

	self.camera.gameObject:SetActiveEx(true)
	pg.global.cameraMgr:SetUISceneCamera(self.camera)
	pg.game.camera:setUICameraObject(self.camera)
	self.cameraMode:setFov(self.cameraParam.fov)
	self.cameraMode:setRotation(self.cameraParam.rot)
	self.cameraMode:setPosition(self.cameraParam.pos)
	self.cameraMode:setActive(true)
	pg.game.camera:setUIGroupActive(true)
end

function PetTransmogScene:onDestroy()
	self:disableGestures()

	if self.snapshotFrameId then
		TimerManager.delFrameCb(self.snapshotFrameId)

		self.snapshotFrameId = nil
	end

	if self.cameraMode then
		pg.game.camera:removeUICamera(self.cameraMode)

		self.cameraMode = nil
	end

	pg.game.camera:setUIGroupActive(false)
	pg.game.camera:setUICameraObject(nil)
	pg.global.cameraMgr:SetUISceneCamera(nil)

	if self.isSnapshotInputLocked then
		pg.global.ui:restoreAllUIByCustomKey(UIConst.UI_HIDE_KEY.PRESET_SNAPSHOT)
		pg.game.input:setEnabledViewCtrl(true, ClientConst.ViewControl.PRESET_SNAPSHOT)

		self.isSnapshotInputLocked = false
	end

	self:_finishPendingSwitchReady(false)
	self:clearAllEntities()
end

function PetTransmogScene:showPet(petId, force)
	if not petId then
		self:clearAllEntities()

		return
	end

	local pet = pg.me.pets[petId]

	if not pet then
		return
	end

	self:showPetWithTransmogScheme(pet.templateId, nil, pet, force)
end

function PetTransmogScene:showPetWithTransmogScheme(templateId, scheme, petInfo, force, onReady)
	if not templateId then
		self:clearAllEntities()

		if onReady then
			onReady(false)
		end

		return
	end

	local entityKey = PetTransmogUtils.getSchemeModelCacheKey(templateId, scheme, petInfo and petInfo.label, petInfo and petInfo.shinyStyle)

	if self.curEntityKey == entityKey and not force then
		self:_finishPendingSwitchReady(false)

		if onReady then
			onReady(true)
		end

		return
	end

	self.switchSeq = (self.switchSeq or 0) + 1

	local switchSeq = self.switchSeq

	self:_finishPendingSwitchReady(false)

	if onReady then
		self.pendingSwitchReadyCallback = onReady

		self:_startSwitchReadyTimeout(switchSeq)
	end

	local cached = self.entityCache and self.entityCache[entityKey]

	if cached and not force then
		self:_switchWhenEntityReady(switchSeq, entityKey, cached, templateId, nil, onReady)

		return
	end

	local entity = self:_createPetEntity(templateId, petInfo)

	if not entity then
		self:_finishPendingSwitchReady(false)

		return
	end

	if force and cached then
		if self.curEntity == cached then
			self.curEntity = nil
			self.curEntityId = nil
			self.curEntityKey = nil
		end

		ClientUtils.safeDestroy(cached)
	end

	self:_cacheEntity(entityKey, entity)

	local needWaitRefresh = self:_applyTransmogScheme(entity, templateId, scheme)

	self:_switchWhenEntityReady(switchSeq, entityKey, entity, templateId, needWaitRefresh, onReady)
end

function PetTransmogScene:_finishPendingSwitchReady(success)
	if self.switchReadyTimer then
		self:killTimer(self.switchReadyTimer)

		self.switchReadyTimer = nil
	end

	if not self.pendingSwitchReadyCallback then
		return
	end

	local callback = self.pendingSwitchReadyCallback

	self.pendingSwitchReadyCallback = nil

	callback(success)
end

function PetTransmogScene:_startSwitchReadyTimeout(switchSeq)
	if self.switchReadyTimer then
		self:killTimer(self.switchReadyTimer)

		self.switchReadyTimer = nil
	end

	local timerId

	timerId = self:startTimer(function()
		if self.timers then
			self.timers[timerId] = nil
		end

		self.switchReadyTimer = nil

		if self.switchSeq ~= switchSeq then
			return
		end

		self:_finishPendingSwitchReady(false)
	end, SWITCH_READY_TIMEOUT)
	self.switchReadyTimer = timerId
end

function PetTransmogScene:_createPetEntity(petTId, petInfo)
	if not petTId then
		return
	end

	local extraData = {
		isCreateEntUsePetInfo = petInfo ~= nil,
		label = PetTransmogUtils.getDisplayLabel(petTId, petInfo and petInfo.label or 0),
		gender = petInfo and petInfo.gender,
		shinyStyle = petInfo and petInfo.shinyStyle
	}

	return PetManagementDataHelper.previewPetModel(petTId, self.entityRootTransform, function(entity)
		if not entity then
			return
		end

		self:applyHairLayerCount(entity)
		entity:setDisableEffectLod(true)

		entity.eModel.enableCameraHitCheck = false

		entity:setModelVisible(ClientConst.MODEL_VISIBLE_KEY.UIScene, false)
	end, extraData)
end

function PetTransmogScene:_switchWhenEntityReady(switchSeq, entityKey, entity, templateId, waitNextRefresh, onReady)
	if not entity then
		if onReady then
			onReady(false)
		end

		return
	end

	local function notifyReady(success)
		if not onReady then
			return
		end

		local callback = onReady

		onReady = nil

		if self.pendingSwitchReadyCallback == callback then
			self:_finishPendingSwitchReady(success)
		end
	end

	local switch

	function switch()
		if self.switchSeq ~= switchSeq then
			if entity.modelLoadedCallback == switch then
				entity.modelLoadedCallback = nil
			end

			notifyReady(false)

			return
		end

		if not self.entityCache or self.entityCache[entityKey] ~= entity then
			if entity.modelLoadedCallback == switch then
				entity.modelLoadedCallback = nil
			end

			notifyReady(false)

			return
		end

		if entity.modelLoadedCallback == switch then
			entity.modelLoadedCallback = nil
		end

		if not self:_isEntityAnimatorReady(entity) then
			entity.petTransmogSwitchSeq = switchSeq

			function entity.onAnimatorReadyCallback(...)
				if entity.petTransmogSwitchSeq ~= switchSeq then
					return
				end

				switch(...)
			end

			return
		end

		self:_switchCurEntity(entityKey, entity, templateId, switchSeq)
		notifyReady(true)
	end

	if entity.isModelLoaded and not waitNextRefresh then
		switch()
	else
		entity.modelLoadedCallback = switch
	end
end

function PetTransmogScene:_isEntityAnimatorReady(entity)
	local modelView = entity and entity.eModel and entity.eModel.modelModelView

	return NotNil(modelView) and modelView:IsAnimatorRead()
end

function PetTransmogScene:_normalizePreviewAnimTime(time, length)
	if not time or time <= 0 then
		return 0
	end

	if length and length > 0 then
		return time % length
	end

	return time
end

function PetTransmogScene:_evaluatePlayable(entity)
	local hasPlayableComponent = entity and entity.hasEModelComponent and entity:hasEModelComponent(Const.COMPONENT_IDX_PLAYABLE)

	if not hasPlayableComponent then
		return false
	end

	entity.eModel:FastForward(Const.COMPONENT_IDX_PLAYABLE, 0)

	return true
end

function PetTransmogScene:_getLoopTimeDiff(a, b, length)
	local diff = math.abs((a or 0) - (b or 0))

	if length and length > 0 then
		diff = diff % length
		diff = math.min(diff, length - diff)
	end

	return diff
end

function PetTransmogScene:_switchCurEntity(entityKey, entity, templateId, switchSeq)
	if self.curEntity and self.curEntity ~= entity then
		self:_capturePreviewAnimation(self.curEntity)
		self.curEntity:setModelVisible(ClientConst.MODEL_VISIBLE_KEY.UIScene, false)
		self.curEntity:setActive(ClientConst.MODEL_VISIBLE_KEY.UIScene, false)
	end

	self.curEntity = entity
	self.curEntityId = templateId
	self.curEntityKey = entityKey

	entity:setActive(ClientConst.MODEL_VISIBLE_KEY.UIScene, true)
	self:_syncEntityAnimation(entity, switchSeq)
	entity:setModelVisible(ClientConst.MODEL_VISIBLE_KEY.UIScene, true)
end

function PetTransmogScene:_capturePreviewAnimation(entity)
	if not entity then
		return
	end

	local animTime

	if entity.getCurrentPlayableState then
		local state = entity:getCurrentPlayableState(PlayableConst.AnimationLayer.LAYER_FULLBODY)

		if NotNil(state) then
			animTime = state.Time
		end
	end

	if not animTime then
		local now = Time.getTickSecond()

		animTime = self.previewAnimStartTime and now - self.previewAnimStartTime or 0
	end

	self.previewAnimName = DEFAULT_PREVIEW_ANIM
	self.previewAnimTime = animTime
	self.previewAnimCaptureTime = Time.getTickSecond()
end

function PetTransmogScene:_syncEntityAnimation(entity, switchSeq)
	if not entity then
		return
	end

	local now = Time.getTickSecond()

	if not self.previewAnimStartTime then
		self.previewAnimStartTime = now
	end

	local function sync()
		if self.switchSeq ~= switchSeq or self.curEntity ~= entity then
			return
		end

		local animName = self.previewAnimName or DEFAULT_PREVIEW_ANIM
		local rawElapsed = self.previewAnimTime

		if rawElapsed ~= nil then
			rawElapsed = rawElapsed + (Time.getTickSecond() - (self.previewAnimCaptureTime or Time.getTickSecond()))
		else
			rawElapsed = Time.getTickSecond() - self.previewAnimStartTime
		end

		if rawElapsed < 0 then
			rawElapsed = 0
		end

		if entity.playRawAnimation then
			local animKey = AnimationUtils.getID(animName)
			local state = entity.getCurrentPlayableState and entity:getCurrentPlayableState(PlayableConst.AnimationLayer.LAYER_FULLBODY) or nil
			local elapsed = rawElapsed

			if NotNil(state) then
				elapsed = self:_normalizePreviewAnimTime(rawElapsed, state.Length)

				local stateKey = state.Key or state.key
				local curTime = self:_normalizePreviewAnimTime(state.Time, state.Length)
				local diff = self:_getLoopTimeDiff(curTime, elapsed, state.Length)

				if stateKey ~= animKey or diff > PREVIEW_ANIM_SYNC_THRESHOLD then
					state = entity:playRawAnimation(animName, 0, elapsed, nil, nil, PlayableConst.AnimationLayer.LAYER_FULLBODY)

					if NotNil(state) then
						elapsed = self:_normalizePreviewAnimTime(rawElapsed, state.Length)
						state.Time = elapsed
					end
				else
					elapsed = curTime
				end
			else
				state = entity:playRawAnimation(animName, 0, elapsed, nil, nil, PlayableConst.AnimationLayer.LAYER_FULLBODY)

				if NotNil(state) then
					elapsed = self:_normalizePreviewAnimTime(rawElapsed, state.Length)
					state.Time = elapsed
				end
			end

			if state and animName == DEFAULT_PREVIEW_ANIM then
				state:SetLogicLoop(true)
			end

			self:_evaluatePlayable(entity)
		end
	end

	sync()

	local oldAnimatorReadyCallback = entity.onAnimatorReadyCallback

	if oldAnimatorReadyCallback == entity.petTransmogAnimSyncCallback then
		oldAnimatorReadyCallback = nil
	end

	entity.petTransmogAnimSyncSeq = switchSeq

	function entity.petTransmogAnimSyncCallback(...)
		if entity.petTransmogAnimSyncSeq ~= switchSeq then
			return
		end

		if oldAnimatorReadyCallback then
			oldAnimatorReadyCallback(...)
		end

		sync()
	end

	entity.onAnimatorReadyCallback = entity.petTransmogAnimSyncCallback
end

function PetTransmogScene:_applyTransmogScheme(entity, templateId, scheme)
	if not entity or not entity.eModel then
		return false
	end

	local transmogData, transmogShinyEffectId = PetTransmogUtils.getSchemeTransmogData(templateId, scheme)

	if transmogData and entity.setTransmogData then
		entity:setTransmogData(transmogData, transmogShinyEffectId)

		return true
	end

	local modelView = entity.eModel.modelModelView
	local modelInfo = modelView and modelView.modelInfo

	if not modelView or not modelInfo then
		return false
	end

	local modelPaths = PetTransmogUtils.getSchemeModelPaths(templateId, scheme)

	if not modelPaths or #modelPaths <= 0 then
		return false
	end

	modelView:InitAttachModel()
	Vector3.enableCreateFromCache()

	for _, data in ipairs(modelPaths) do
		if not data.isBaseModel then
			local instanceId = string.format("%s%s_%s", TRANSMOG_ATTACH_PREFIX, tostring(data.holeIndex), tostring(data.slotId))

			modelInfo:AddAttachInfo(data.path, instanceId, data.attachHp, Vector3.zero, Vector3.zero, Vector3.one)
		end
	end

	Vector3.disableCreateFromCache()
	modelView:RefreshModels()

	return true
end

function PetTransmogScene:_cacheEntity(entityKey, entity)
	self.entityCache = self.entityCache or {}
	self.entityCacheOrder = self.entityCacheOrder or {}

	for i = #self.entityCacheOrder, 1, -1 do
		if self.entityCacheOrder[i] == entityKey then
			table.remove(self.entityCacheOrder, i)
		end
	end

	self.entityCache[entityKey] = entity
	self.entityCacheOrder[#self.entityCacheOrder + 1] = entityKey

	self:_trimEntityCache()
end

function PetTransmogScene:_trimEntityCache()
	if not self.entityCacheOrder then
		return
	end

	while #self.entityCacheOrder > TRANSMOG_ENTITY_CACHE_MAX do
		local removeKey = table.remove(self.entityCacheOrder, 1)

		if removeKey == self.curEntityKey then
			self.entityCacheOrder[#self.entityCacheOrder + 1] = removeKey
		else
			local entity = self.entityCache and self.entityCache[removeKey]

			if entity then
				ClientUtils.safeDestroy(entity)

				self.entityCache[removeKey] = nil
			end
		end
	end
end

function PetTransmogScene:playPetIdleSpecial()
	if self.curEntity then
		self.previewAnimStartTime = Time.getTickSecond()
		self.previewAnimName = DEFAULT_PREVIEW_ANIM
		self.previewAnimTime = 0
		self.previewAnimCaptureTime = self.previewAnimStartTime

		local state = self.curEntity:playAnimation(DEFAULT_PREVIEW_ANIM, false)

		if state then
			state:SetLogicLoop(true)
		end
	end
end

function PetTransmogScene:setEntityRot(eulerY)
	if self.curEntity then
		Vector3.enableCreateFromCache()

		local localRotation = Quaternion.Euler(0, eulerY or 0, 0)

		self.curEntity.eModel:SetTransformLocalRotation(localRotation.x, localRotation.y, localRotation.z, localRotation.w)
		Vector3.disableCreateFromCache()
	end
end

function PetTransmogScene:rotateEntityBy(deltaY)
	if self.curEntity and deltaY and deltaY ~= 0 then
		self.curEntity.eModel.transform:Rotate(0, deltaY, 0)
	end
end

function PetTransmogScene:setModelVisible(visible)
	if self.curEntity then
		self.curEntity:setModelVisible(ClientConst.MODEL_VISIBLE_KEY.UIScene, visible)
	end
end

function PetTransmogScene:getCurEntity()
	return self.curEntity
end

function PetTransmogScene:getCurEntityId()
	return self.curEntityId
end

function PetTransmogScene:clearCurEntity()
	self:_finishPendingSwitchReady(false)

	if self.curEntity then
		ClientUtils.safeDestroy(self.curEntity)

		if self.curEntityKey and self.entityCache then
			self.entityCache[self.curEntityKey] = nil
		end

		if self.curEntityKey and self.entityCacheOrder then
			for i = #self.entityCacheOrder, 1, -1 do
				if self.entityCacheOrder[i] == self.curEntityKey then
					table.remove(self.entityCacheOrder, i)
				end
			end
		end

		self.curEntity = nil
	end

	self.curEntityId = nil
	self.curEntityKey = nil
	self.previewAnimStartTime = nil
	self.previewAnimName = nil
	self.previewAnimTime = nil
	self.previewAnimCaptureTime = nil
end

function PetTransmogScene:clearAllEntities()
	self:_finishPendingSwitchReady(false)

	if self.entityCache then
		for _, entity in pairs(self.entityCache) do
			if entity then
				ClientUtils.safeDestroy(entity)
			end
		end
	elseif self.curEntity then
		ClientUtils.safeDestroy(self.curEntity)
	end

	self.curEntity = nil
	self.curEntityId = nil
	self.curEntityKey = nil
	self.previewAnimStartTime = nil
	self.previewAnimName = nil
	self.previewAnimTime = nil
	self.previewAnimCaptureTime = nil
	self.entityCache = {}
	self.entityCacheOrder = {}
end

function PetTransmogScene:snapShot(callback)
	pg.global.ui:hideAllUIByCustomKey(UIConst.UI_HIDE_KEY.PRESET_SNAPSHOT, nil, self.SNAPSHOT_UI_HIDE_TIMEOUT)
	pg.game.input:setEnabledViewCtrl(false, ClientConst.ViewControl.PRESET_SNAPSHOT)

	self.isSnapshotInputLocked = true

	self:setEntityRot(0)

	if not self.camera then
		pg.global.ui:restoreAllUIByCustomKey(UIConst.UI_HIDE_KEY.PRESET_SNAPSHOT)
		pg.game.input:setEnabledViewCtrl(true, ClientConst.ViewControl.PRESET_SNAPSHOT)

		self.isSnapshotInputLocked = false

		if callback then
			callback(nil)
		end

		return
	end

	local entity = self.curEntity

	self:_setEntitySpring(entity, false)

	self.snapshotFrameId = TimerManager.addNextFrameCb(function()
		self.snapshotFrameId = nil

		self:_doCaptureScreen(entity, callback)
	end)
end

function PetTransmogScene:_setEntitySpring(entity, open)
	if not entity then
		return
	end

	local eModel = entity.eModel

	if not eModel or IsNil(eModel.modelModelView) or IsNil(eModel.modelRoot) then
		return
	end

	if open then
		eModel.modelModelView:OpenBoneSpring(eModel.modelRoot)
	else
		eModel.modelModelView:CloseBoneSpring(eModel.modelRoot)
	end
end

function PetTransmogScene:_doCaptureScreen(entity, callback)
	local effectiveCropScale = self.SNAPSHOT_CROP_SCALE * (1 - self.SNAPSHOT_EDGE_TRIM * 2)
	local snapSize = math.floor(Screen.height * effectiveCropScale)

	if snapSize <= 0 then
		snapSize = 512
	end

	local sizeDelta = Vector2.New(snapSize, snapSize)
	local position = Vector2.New((Screen.width - snapSize) / 2 + Screen.width * self.SNAPSHOT_CROP_OFFSET_X, (Screen.height - snapSize) / 2 + Screen.height * self.SNAPSHOT_CROP_OFFSET_Y)

	pg.global.mobileCameraMgr:CaptureScreenDelaySave(function(sprite)
		pg.global.ui:restoreAllUIByCustomKey(UIConst.UI_HIDE_KEY.PRESET_SNAPSHOT)
		pg.game.input:setEnabledViewCtrl(true, ClientConst.ViewControl.PRESET_SNAPSHOT)

		self.isSnapshotInputLocked = false

		self:_setEntitySpring(entity, true)
		pg.me:addPhotoImgSprite(sprite, function(imageKey, success)
			pg.global.mobileCameraMgr:DestroySpriteTexture(sprite)

			if not success then
				pg.global.ui.tips:showTextTip(pg.getGameString("VERIFY_PIC_UPLOAD_FAIL"))

				return
			end

			if callback then
				callback(imageKey)
			end
		end)
	end, position, sizeDelta, 1, false)
end

return PetTransmogScene
