-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Scenes\\UIScenes\\ModelScene.lua

local Class = require("Core.Framework.Class")
local FocusTargetCameraMode = require("GameApp.Camera.CameraMode.FocusTargetCameraMode")
local CameraConst = require("GameApp.Camera.CameraConst")
local UISceneBase = require("GameApp.UIScene.UISceneBase")
local ClientConst = require("Const.ClientConst")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local PlayableConst = require("Common.Const.PlayableConst")
local ClientSimpleVirtualPlayer = require("Entities.ClientSimpleVirtualPlayer")
local AppearanceCustomOne = require("CustomTypes.AppearanceCustomOne")
local ModelScene = Class.LightClass("ModelScene", UISceneBase)
local logger = require("Core.Log.LoggerManager").getLogger("Avatar")
local AvatarPresetData = require("Data.avatar_preset_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ID_ENTITY_ROTATION_TWEEN = "entityRotationTween"
local Quaternion = Quaternion

function ModelScene:onStart(info)
	self.objectReference = self.scene.transform:GetComponent("ObjectReference")
	self.camera = self.objectReference:GetRefValue("camera")
	self.entityRootTransform = self.objectReference:GetRefValue("entityRootTransform")
	self.boyLightTransform = self.objectReference:GetRefValue("boyLightTransform")
	self.girlLightTransform = self.objectReference:GetRefValue("girlLightTransform")
	self.pramonLightTransform = self.objectReference:GetRefValue("pramonLightTransform")
	self.type = info.type or ClientConst.ModelSceneType.ContinuousFrame
	self.rtWidth = info.rtWidth or Screen.width
	self.rtHeight = info.rtHeight or Screen.height
	self.cameraPresetKey = info.cameraPresetKey or FocusTargetCameraMode.CameraPresetKey.PlayerInfo
	self.skipDecalCombineReadyCheck = info.skipDecalCombineReadyCheck

	pg.global.cameraMgr:SetUISceneCamera(self.camera)
	self:initCameraMode()
end

function ModelScene:onDestroy()
	self:disableAllCameras()
	self:releaseRenderTexture()
end

function ModelScene:checkAllEntityReady(ignoreTimeout)
	local isReady = ModelScene.super.checkAllEntityReady(self, ignoreTimeout)

	if not isReady then
		return false
	end

	if self.skipDecalCombineReadyCheck then
		return true
	end

	local allEntities = self:getAllEntities()

	for _, entity in pairs(allEntities) do
		local isDecalCombineFinished = entity.eModel.shaderView:IsDecalCombineFinished()

		if not isDecalCombineFinished then
			return false
		end
	end

	return true
end

function ModelScene:initCameraMode()
	pg.game.camera:setUICameraObject(self.camera)

	self.cameraMode = FocusTargetCameraMode.new()

	pg.game.camera:addUICamera(self.cameraMode, CameraConst.PRIORITY_SIMPLE_CONTROL)
	self.cameraMode:setCameraName(CameraConst.CAMERA_NAME_FOCUS_TARGET)
end

function ModelScene:disableAllCameras()
	pg.game.camera:removeUICamera(self.cameraMode)
	pg.game.camera:setUIGroupActive(false)
end

function ModelScene:getRenderTexture()
	self.renderTexture = pg.global.uiMgr:GetRenderTextureWithPool(self.rtWidth, self.rtHeight, 24)
end

function ModelScene:releaseRenderTexture()
	if self.renderTexture ~= nil then
		pg.global.uiMgr:ReleaseRenderTextureWithPool(self.renderTexture)

		self.renderTexture = nil
	end
end

function ModelScene:releaseTexture()
	if self.texture ~= nil then
		pg.global.cameraMgr:DestroySnapShot()

		self.texture = nil
	end
end

function ModelScene:setRawImageProRef(rawImagePro)
	if not self.renderTexture then
		self:getRenderTexture()
	end

	self.rawImagePro = rawImagePro
	self.rawImagePro.texture = self.renderTexture
end

function ModelScene:draw()
	if self.type == ClientConst.ModelSceneType.SnapShot then
		pg.global.cameraMgr:SnapShotDelay(function(texture)
			self.rawImagePro.texture = texture
		end, self.camera, self.renderTexture)
	elseif self.type == ClientConst.ModelSceneType.ContinuousFrame then
		self.camera.targetTexture = self.renderTexture
	end
end

function ModelScene:showPlayerEntity(info, updateWhenOffscreen)
	if not info then
		return
	end

	self.updateWhenOffscreen = updateWhenOffscreen == true

	local allEntities = self:getAllEntities()

	for entityId, _ in pairs(allEntities) do
		if not info[entityId] then
			self:removeEntity(entityId)
		end
	end

	for playerId, entityInfo in pairs(info) do
		local entity = self:getEntity(playerId)

		if entity then
			self:showEntityWithId(playerId)
		else
			local initDict = {}

			if playerId == pg.me.uid then
				if pg.me.isDeformToPet and pg.me:isDeformToPet() then
					initDict = {
						templateId = pg.me.templateId,
						avatarPresetKey = pg.me.avatarPresetKey,
						avatarConfig = pg.me.avatarConfig,
						curShow = pg.me.curShow
					}
				else
					initDict.copyEntity = pg.me
				end
			else
				local presetKey = entityInfo.avatarPresetKey
				local presetData = pg.game.avatar:getAvatarPresetData(presetKey) or {}

				initDict = {
					templateId = presetData.templateId,
					avatarPresetKey = entityInfo.avatarPresetKey,
					avatarConfig = entityInfo.avatarConfig,
					curShow = AppearanceCustomOne(entityInfo.curShow)
				}
			end

			entity = self:createEntity(playerId, ClientSimpleVirtualPlayer, initDict)

			entity.eModel:SetTransformParent(self.entityRootTransform, false)

			local entityPos = entityInfo.pos

			if entityPos then
				entity:setPositionAgentLocalPos(entityPos[1], entityPos[2], entityPos[3])
			end

			entity.eModel:SetFacialStubEnabled(Const.COMPONENT_IDX_PLAYABLE, false)

			local state = entity:playRawAnimation(entityInfo.ani or "Show_Idle", 0, entityInfo.aniFrame or 0, entityInfo.aniFrame and 0 or 1)

			if state then
				state:RemoveAutoTransition()
				state:SetLogicLoop(false)
			end
		end
	end

	self.waitLoadEntity = true
end

function ModelScene:onAllEntityLoaded()
	local allEntities = self:getAllEntities()

	if self.updateWhenOffscreen then
		for _, entity in pairs(allEntities) do
			entity.eModel.modelModelView:EnableSkinnedMeshRendererUpdateWhenOffscreen()
		end
	end

	for _, entity in pairs(allEntities) do
		local lookAtComponent = entity.eModel.ikLookAtComponent

		if lookAtComponent then
			lookAtComponent.targetCamera = self.camera
			lookAtComponent.enableCameraLookAt = true
		end
	end

	self.cameraMode:enableCamera(true, self.cameraPresetKey, allEntities)
	self:draw()
end

function ModelScene:setEntityPos(entityId, posVec)
	if not entityId or not posVec then
		return
	end

	local entity = self:getEntity(entityId)

	if not entity then
		return
	end

	entity.eModel:SetTransformLocalPosition(posVec.x, posVec.y, posVec.z)
end

function ModelScene:setEntityRot(entityId, eulerY, duration)
	if not entityId or not eulerY then
		return
	end

	local entity = self:getEntity(entityId)

	if not entity then
		return
	end

	if duration then
		local _, eulerAngleY, _ = entity.eModel:GetTransformRotationEulerAngles()
		local from = Utils.normalizeAngle(eulerAngleY)
		local targetRotY = Utils.normalizeAngle(eulerY)
		local to = math.abs(targetRotY - from) > 180 and targetRotY + 360 or targetRotY

		DoTweenAnimMgr.DoFloat(entity.actorId, from, to, LuaUIUtils.TweenId(ID_ENTITY_ROTATION_TWEEN), duration, 0, CS.DG.Tweening.Ease.__CastFrom(1), function()
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

function ModelScene:playAnimation(entityId, key, fadeTime, offsetTime)
	if not entityId then
		return
	end

	local entity = self:getEntity(entityId)

	if not entity then
		return
	end

	entity:playRawAnimation(PlayableConst[key], fadeTime, offsetTime)
end

return ModelScene
