-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Scenes\\UIScenes\\BattlePassScene.lua

local Class = require("Core.Framework.Class")
local GlobalData = require("Core.Client.GlobalData")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local AvatarCameraMode = require("GameApp.Camera.CameraMode.AvatarCameraMode")
local CameraConst = require("GameApp.Camera.CameraConst")
local UISceneBase = require("GameApp.UIScene.UISceneBase")
local ClientSimpleVirtualPlayer = require("Entities.ClientSimpleVirtualPlayer")
local ClientSimpleVirtualPet = require("Entities.ClientSimpleVirtualPet")
local AudioConst = require("Const.AudioConst")
local ClientConst = require("Const.ClientConst")
local UIConst = require("Const.UIConst")
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local PlayableConst = require("Common.Const.PlayableConst")
local ClientModelUtils = require("Utils.ClientModelUtils")
local AppearanceEffectUtils = require("Utils.AppearanceEffectUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local UIScenePreviewController = require("GameApp.Scenes.UIScenes.UIScenePreviewController")
local EModelUtils = require("Entities.Utils.EModelUtils")
local AppearanceData = require("Data.appearance_data")
local AppearancePointEnum = require("Data.appearance_point_enum")
local AvatarHairResIdToConfig = require("Data.avatar_hair_resId_to_config")
local AvatarHairSuitData = require("Data.avatar_hair_suit_data")
local AvatarUtils = require("Guis.Utils.AvatarUtils")
local AvatarPresetData = require("Data.avatar_preset_data")
local BattlePassScene = Class.LightClass("BattlePassScene", UISceneBase)
local PetData = require("Data.pet_data")
local PetTransmogUtils = require("GameApp.PetTransmog.PetTransmogUtils")
local logger = require("Core.Log.LoggerManager").getLogger("Avatar")
local TimerManager = require("Core.Timer.TimerManager")
local ID_ENTITY_ROTATION = "entityRotationTween"
local ID_ARM_LEN = "armLenTween"
local Vector3 = Vector3
local Quaternion = Quaternion
local GameConst = CS.FunPlus.WorldX.Const.GameConst
local avatarMgr = pg.global.avatarMgr
local fingerGestures = fingerGestures
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro

BattlePassScene.AREA = {
	BOTTOM = 20,
	MID = 0,
	TOP = -20
}
BattlePassScene.GAMEPAD_PRESS = {
	CAMERA_ZOOM = 1,
	SWIPE_MODEL = 0
}
BattlePassScene.SCROLL_DURATION = 0.1
BattlePassScene.cameraDuration = 1
BattlePassScene.CAMERA = {
	PET = "pet",
	SIMPLE = "simple",
	FIXED = "fixed"
}
BattlePassScene.CONFIG = {
	[11] = {
		maxZoomOffsetY = 0.8,
		maxZoom = 7,
		minZoom = 1.3,
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
		}
	},
	[21] = {
		maxZoomOffsetY = 0.8,
		maxZoom = 7,
		minZoom = 1.3,
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
		}
	}
}
BattlePassScene.PET_CONFIG = {
	defaultY = 0.5,
	defaultZoom = 10,
	maxZoom = 10,
	minZoom = 2.5,
	maxZoomOffsetY = 0.9,
	scale = 1,
	minZoomOffsetY = {
		0.2,
		1.2
	}
}

function BattlePassScene:onCtor()
	self.needShowAvatar = self.ctorParams and self.ctorParams.needShowAvatar
end

function BattlePassScene:onStart()
	local isAppearanceOpen = pg.global.ui:checkUIOpen(UIConst.UI_ID_APPEARANCE_V2)

	if isAppearanceOpen then
		pg.global.ui:close(UIConst.UI_ID_APPEARANCE_V2)
	end

	self.gestures = {}
	self.cameraModes = {}
	self.objectReference = self.scene.transform:Find("Global"):GetComponent("ObjectReference")
	self.scene.transform.position = Vector3(0, 500, 0)
	self.camera = self.objectReference:GetRefValue("camera")
	self.uI3DRoot = self.objectReference:GetRefValue("3DUIRoot")
	self.entityRootTransform = self.objectReference:GetRefValue("entityRootTransform")
	self.previewSceneController = UIScenePreviewController.new(self)

	if pg.global.ui.login:checkUIOpen() then
		pg.global.ui.login:pauseVideo()
	end

	pg.game.input:setEnabledViewCtrl(false, ClientConst.ViewControl.APPEARANCE)
	self:initCameraModes()

	self.pauseAutoSave = false
end

function BattlePassScene:onDestroy()
	self:destroyPreviewController()

	pg.game.avatar.eyeNormalFixEntity = nil

	pg.global.avatarMgr:ClearAvatar()
	pg.global.avatarMgr:ClearRuntimeDataPool()
	pg.game.input:setEnabledViewCtrl(true, ClientConst.ViewControl.APPEARANCE)
	pg.global.ui:restoreAllUIByCustomKey(UIConst.UI_HIDE_KEY.APPEARANCE)
	pg.game.audio:playBgm(nil, AudioConst.BgmPriority.Avatar)

	if pg.global.ui.login:checkUIOpen() then
		pg.global.ui.login:resumeVideo()
		pg.global.ui.login:resetLoginState()
	end

	self.curEntityId = nil
	self.cameraModes = nil
	self.gestures = nil
	self.pressTimer = nil
end

function BattlePassScene:disableCamera()
	self.camera.enabled = false
end

function BattlePassScene:setEntityPos(entityId, pos)
	local entity = self:getEntity(entityId)

	if entity then
		if pos then
			entity.eModel:SetTransformLocalPosition(pos.x, pos.y, pos.z)
		else
			entity.eModel:SetTransformLocalPosition()
		end
	end
end

function BattlePassScene:setEntityRot(entityId, eulerY, duration)
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

		DoTweenAnimMgr.DoFloat(entity.actorId, from, to, LuaUIUtils.TweenId(ID_ENTITY_ROTATION), duration, 0, CS.DG.Tweening.Ease.__CastFrom(1), function()
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

function BattlePassScene:setCurEntityRot(eulerY, duration)
	self:setEntityRot(self.curEntityId, eulerY, duration)
end

function BattlePassScene:showAvatar(presetKey, onAvatarLoaded)
	self.curEntityId = presetKey

	local curEntity = self:getEntity(presetKey)

	if curEntity then
		self:showEntityWithId(presetKey)
		self:enableCameraMode(self.CAMERA.SIMPLE)

		if onAvatarLoaded then
			onAvatarLoaded()
		end
	else
		pg.game.avatar.eyeNormalFixEntity = nil

		avatarMgr:ClearAvatar()

		local templateId = pg.game.avatar:getAvatarPresetData(presetKey).templateId

		avatarMgr:InitWorkSpace(presetKey, templateId, GlobalData.UserName)

		local initDict = {
			needFacialHighLight = true,
			copyEntity = pg.me
		}

		curEntity = self:createEntity(presetKey, ClientSimpleVirtualPlayer, initDict)

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

			local modelView = curEntity.eModel.modelModelView

			avatarMgr:SetAvatarInstance(curEntity.eModel)
			avatarMgr:InitAvatarPart()

			local hairSuitId = LuaUIUtils.tryGetEntityHairSuitId(pg.me)
			local hairSuitInfo = AvatarHairSuitData[hairSuitId]

			if hairSuitInfo then
				avatarMgr.avatarHair:SetAssetIdAndLoad(hairSuitInfo.assetId)
				avatarMgr.avatarHair:InitColors()
			end

			pg.game.avatar.eyeNormalFixEntity = curEntity

			if onAvatarLoaded then
				onAvatarLoaded()
			end
		end
	end
end

function BattlePassScene:doLoadedCallBack(succeed)
	if self.needShowAvatar then
		local presetKey = pg.game.avatar:getPresetKey(pg.me)

		self:showAvatar(presetKey, function()
			BattlePassScene.super.doLoadedCallBack(self, succeed)
		end)
	else
		BattlePassScene.super.doLoadedCallBack(self, succeed)
	end
end

function BattlePassScene:showAvatarTemplate(presetKey, onAvatarLoaded, sync, force)
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

	local initDict = {
		needFacialHighLight = true,
		useDefaultParts = true,
		templateId = templateId,
		avatarPresetKey = presetKey
	}
	local curEntity = self:createEntity(presetKey, ClientSimpleVirtualPlayer, initDict)

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
		self:enableCameraMode(self.CAMERA.SIMPLE)
		self:playIdleAnimation(curEntity)

		pg.game.avatar.eyeNormalFixEntity = curEntity

		if onAvatarLoaded then
			onAvatarLoaded()
		end

		curEntity.modelPartModelAllLoaded = nil
	end

	local modelResData = AvatarUtils.getModelResData(curEntity, presetKey)

	for partId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
		local hairInfo = modelResData[partId] or {}

		pg.game.avatar:updateHairSelection(partId, hairInfo.configId, "showAvatarTemplate")
	end
end

function BattlePassScene:playIdleAnimation(entity, fadeTime)
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

function BattlePassScene:destroyPet(templateId)
	self:removeEntity(templateId)
end

function BattlePassScene:showPetTemplate(petInfo, scale, offset)
	local templateId = petInfo.templateId

	if templateId ~= self.curEntityId then
		self:hideEntityWithId(self.curEntityId)
	end

	self.curEntityId = templateId

	local curEntity = self:getEntity(templateId)

	if curEntity then
		self:showEntityWithId(templateId)
		self:enableCameraMode(self.CAMERA.PET)
		self:setAvatarCameraModeFar()

		if PetTransmogUtils.applyAppliedTransmog(curEntity, petInfo.id, true) then
			self:replayAfterTransmogRefresh(curEntity, true, function()
				curEntity:playAnimation(PlayableConst.Idle)
			end)
		end

		return
	end

	local initDict = {
		templateId = templateId,
		label = petInfo.label,
		gender = petInfo.gender,
		tempJewelryInfo = pg.me.petJewelryInfos[petInfo.id]
	}

	curEntity = self:createEntity(templateId, ClientSimpleVirtualPet, initDict)

	curEntity:setConfigData(PetData[templateId])
	PetTransmogUtils.applyAppliedTransmog(curEntity, petInfo.id)
	EModelUtils.setAgentPosition(curEntity, offset)
	curEntity:setScaleNumber(scale)
	curEntity.eModel:SetTransformParent(self.entityRootTransform, false)
	curEntity:setDisableEffectLod(true)

	curEntity.eModel.enableCameraHitCheck = false

	function curEntity.modelLoadedCallback()
		self:enableCameraMode(self.CAMERA.PET)
		self:setAvatarCameraModeFar()
		self:runWhenAnimatorReady(curEntity, function()
			curEntity:playAnimation(PlayableConst.Idle)
		end)

		curEntity.modelLoadedCallback = nil
	end
end

function BattlePassScene:isSameEntity(entityId)
	return self.curEntityId == entityId
end

function BattlePassScene:getCurEntity()
	return self:getEntity(self.curEntityId)
end

function BattlePassScene:getCurEntityId()
	return self.curEntityId
end

function BattlePassScene:getPresetData()
	return pg.game.avatar:getAvatarPresetData(self.curEntityId) or {}
end

function BattlePassScene:removeEntity(entityId)
	BattlePassScene.super.removeEntity(self, entityId)

	if self.curEntityId == entityId then
		self.curEntityId = nil
	end
end

function BattlePassScene:changeHair(param)
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

function BattlePassScene:getCurHairPartId(entityId, partId)
	local entity = self:getEntity(entityId)

	if not entity then
		return
	end

	local partModelInfo = entity.eModel.modelModelView.modelInfo.partModelInfo
	local resId = partModelInfo:GetPartResId(partId) or ""

	return AvatarHairResIdToConfig[resId]
end

function BattlePassScene:getCurHairSuitId(entityId)
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

function BattlePassScene:changeClothes(param)
	local entity = self:getEntity(param.entityId)

	if not entity then
		return
	end

	local modelView = entity.eModel.modelView
	local partModelInfo = modelView.modelInfo.partModelInfo

	for _, info in ipairs(param) do
		local clothesData = AppearanceData[info.clothesId] or {}

		AppearanceEffectUtils.setPartAppearance(entity, info.clothesId, info.isApply)

		local partId = clothesData.partId

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

function BattlePassScene:playShowAnimation(entityId, key)
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

function BattlePassScene:playCfgAnimation(entityId, key)
	local entity = self:getEntity(entityId)

	if not entity then
		return
	end

	entity:playCfgAnimation(key)
end

function BattlePassScene:refreshPartRendererVisible(entityId, actions)
	local entity = self:getEntity(entityId)

	if not entity then
		return
	end

	ClientModelUtils.applyPartRendererVisibility(entity, actions)
end

function BattlePassScene:switchCameraLookAt(enable)
	local entity = self:getCurEntity()

	if entity then
		local lookAtComponent = entity.eModel.ikLookAtComponent

		if lookAtComponent then
			lookAtComponent.targetCamera = self.camera
			lookAtComponent.enableCameraLookAt = enable
		end
	end
end

function BattlePassScene:playPosAnim(entity, animName, isLoop, finishedCallback)
	local res = entity:playAnimation(animName, false, nil, isLoop)

	if finishedCallback then
		res:AddEndCallback(finishedCallback)
	end
end

function BattlePassScene:setAvatarCameraModeFar()
	if self.curCameraMode == nil then
		return
	end

	self:doSpringArmTween(self.curCameraMode.cameraMode.maxZoom, self.cameraDuration)
	self:doVerticalTween(self.curCameraMode.maxZoomOffsetY, self.cameraDuration)
end

function BattlePassScene:doSpringArmTween(to, duration)
	local from = self.curCameraMode:getSpringArmLen()

	to = to or 0
	duration = duration or 1

	if DoTweenAnimMgr.IsTweening(self.camera.gameObject, LuaUIUtils.TweenId(ID_ARM_LEN)) then
		DoTweenAnimMgr.Kill(self.camera.gameObject, LuaUIUtils.TweenId(ID_ARM_LEN))
	end

	DoTweenAnimMgr.DoFloat(self.camera.gameObject, from, to, LuaUIUtils.TweenId(ID_ARM_LEN), duration, 0, CS.DG.Tweening.Ease.__CastFrom(1), function()
		return
	end, function(len)
		self.curCameraMode:setSpringArmLen(len)
	end, function()
		return
	end, false)
end

function BattlePassScene:doVerticalTween(to, duration, noConstrain)
	local from = self.curCameraMode.cameraMode.pivotOffset.y

	to = to or 0
	duration = duration or 1

	DoTweenAnimMgr.DoFloat(self.camera.gameObject, from, to, LuaUIUtils.TweenId(ID_ARM_LEN), duration, 0, CS.DG.Tweening.Ease.__CastFrom(1), function()
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

function BattlePassScene:onAllEntityLoaded()
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

return BattlePassScene
