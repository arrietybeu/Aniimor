-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Scenes\\UIScenes\\VitalityScene.lua

local Class = require("Core.Framework.Class")
local AppearanceEffectUtils = require("Utils.AppearanceEffectUtils")
local GlobalData = require("Core.Client.GlobalData")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local AvatarCameraMode = require("GameApp.Camera.CameraMode.AvatarCameraMode")
local CameraConst = require("GameApp.Camera.CameraConst")
local UISceneBase = require("GameApp.UIScene.UISceneBase")
local ClientSimpleVirtualPlayer = require("Entities.ClientSimpleVirtualPlayer")
local ClientSimpleVirtualPet = require("Entities.ClientSimpleVirtualPet")
local AvatarUtils = require("Guis.Utils.AvatarUtils")
local AudioConst = require("Const.AudioConst")
local ClientConst = require("Const.ClientConst")
local EModelUtils = require("Entities.Utils.EModelUtils")
local Const = require("Common.Const.Const")
local UIConst = require("Const.UIConst")
local Utils = require("Common.Utils.Utils")
local PlayableConst = require("Common.Const.PlayableConst")
local ClientModelUtils = require("Utils.ClientModelUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local UIScenePreviewController = require("GameApp.Scenes.UIScenes.UIScenePreviewController")
local PetTransmogUtils = require("GameApp.PetTransmog.PetTransmogUtils")
local AppearanceData = require("Data.appearance_data")
local AppearancePointEnum = require("Data.appearance_point_enum")
local AvatarHairResIdToConfig = require("Data.avatar_hair_resId_to_config")
local AvatarHairSuitData = require("Data.avatar_hair_suit_data")
local AvatarPresetData = require("Data.avatar_preset_data")
local AppearanceSuitData = require("Data.appearance_suit_data")
local ColorJewelryData = require("Data.appearance_color_jewelry_data")
local VitalityScene = Class.LightClass("VitalityScene", UISceneBase)
local PetData = require("Data.pet_data")
local logger = require("Core.Log.LoggerManager").getLogger("VitalityScene")
local TimerManager = require("Core.Timer.TimerManager")
local ID_ENTITY_ROTATION = "entityRotationTween"
local ID_ARM_LEN = "armLenTween"
local ID_CAMERA_MOVE = "cameraMove"
local Vector3 = Vector3
local Quaternion = Quaternion
local GameConst = CS.FunPlus.WorldX.Const.GameConst
local avatarMgr = pg.global.avatarMgr
local fingerGestures = fingerGestures
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro

VitalityScene.AREA = {
	TOP = -20,
	BOTTOM = 20,
	MID = 0
}
VitalityScene.GAMEPAD_PRESS = {
	CAMERA_ZOOM = 1,
	SWIPE_MODEL = 0
}
VitalityScene.SCROLL_DURATION = 0.1
VitalityScene.CAMERA = {
	SIMPLE = "simple",
	PET = "pet",
	FIXED = "fixed"
}
VitalityScene.CONFIG = {
	[11] = {
		maxZoomOffsetY = 0.8,
		maxZoom = 7,
		minZoom = 1.3,
		minZoomOffsetY = {
			0.1,
			1.3
		},
		minZoomOffsetYSplit = {
			Chest = 1.1,
			Hair = 1.3,
			Foot = 0.1,
			Thigh = 0.4,
			Waist = 0.8
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
			Chest = 1.1,
			Hair = 1.4,
			Foot = 0.1,
			Thigh = 0.4,
			Waist = 0.7
		}
	}
}
VitalityScene.PET_CONFIG = {
	scale = 1,
	defaultY = 0.5,
	defaultZoom = 10,
	maxZoomOffsetY = 0.9,
	minZoom = 2.5,
	maxZoom = 10,
	minZoomOffsetY = {
		0.2,
		1.2
	}
}

function VitalityScene:onCtor()
	self.needShowAvatar = self.ctorParams and self.ctorParams.needShowAvatar
end

function VitalityScene:onStart()
	self.gestures = {}
	self.cameraModes = {}
	self.objectReference = self.scene.transform:Find("Global"):GetComponent("ObjectReference")

	Vector3.enableCreateFromCache()

	self.scene.transform.position = Vector3(0, 500, 0)

	Vector3.disableCreateFromCache()

	self.camera = self.objectReference:GetRefValue("camera")
	self.entityRootTransform = self.objectReference:GetRefValue("entityRootTransform")
	self.extraTransform = self.objectReference:GetRefValue("extraTransform")
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

	self:adaptVitalityBackgroundScale()

	self.nameObjectPool = {}
	self.previewSceneController = UIScenePreviewController.new(self)

	if pg.global.ui.login:checkUIOpen() then
		pg.global.ui.login:pauseVideo()
	end

	pg.game.input:setEnabledViewCtrl(false, ClientConst.ViewControl.APPEARANCE)
	pg.game.audio:playBgm("BGM_AppearanceSystem", AudioConst.BgmPriority.Avatar)
	self:initCameraModes()
	self:registerAutoSave()

	self.warmupTimer = TimerManager.addTimer(15, function()
		self.warmupTimer = nil

		pg.global.resMgr:StartStageWarmup(8000, "CreateRole", 5)
	end)
	self.pauseAutoSave = false
end

function VitalityScene:onDestroy()
	self:unRegisterAutoSave()

	if self.warmupTimer then
		TimerManager.removeTimer(self.warmupTimer)

		self.warmupTimer = nil
	end

	self:destroyPreviewController()

	if self.camera then
		self.camera.enabled = false
	end

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

	self.nameObjectPool = {}
	self.cameraModes = nil
	self.curEntityId = nil

	self:resetVitalityBackgroundScale()

	if self.curBgGo then
		self:resetSingleCameraParam(self.curBgGo)
		pg.global.resMgr:RemoveInstanceToCache(self.curBgGo)
	end

	self.curBgGo = nil
	self.bgId = nil
	self.bgResId = nil
end

function VitalityScene:adaptVitalityBackgroundScale()
	local canvasScaler = pg.global.uiMgr.uiRootCanvasRt:GetComponent("CanvasScaler")
	local referenceResolution = canvasScaler.referenceResolution
	local referenceAspect = referenceResolution.x / referenceResolution.y
	local currentAspect = Screen.width / Screen.height
	local coverScale = math.max(currentAspect / referenceAspect, referenceAspect / currentAspect)

	self.vitalityBgBaseScales = self.vitalityBgBaseScales or {}

	for _, transform in ipairs(self.vitalityBgs or {}) do
		local baseScale = self.vitalityBgBaseScales[transform]

		if not baseScale then
			local scale = transform.localScale

			baseScale = {
				x = scale.x,
				y = scale.y,
				z = scale.z
			}
			self.vitalityBgBaseScales[transform] = baseScale
		end

		transform.localScale = Vector3.New(baseScale.x * coverScale, baseScale.y * coverScale, baseScale.z)
	end
end

function VitalityScene:resetVitalityBackgroundScale()
	local baseScales = self.vitalityBgBaseScales or {}

	for transform, baseScale in pairs(baseScales) do
		transform.localScale = Vector3.New(baseScale.x, baseScale.y, baseScale.z)
	end

	self.vitalityBgBaseScales = nil
end

function VitalityScene:setVitalityBg(themeId)
	local index = themeId % 10

	for i = 1, #(self.vitalityBgs or {}) do
		if self.vitalityBgs[i] then
			self.vitalityBgs[i].gameObject:SetActiveEx(i == index)
		end
	end
end

function VitalityScene:setStageLight(index)
	if not self.stageLights or not self.stageLights[index] then
		self.stageLights = self.stageLights or {}
		self.stageLights[1] = self.stageLights[1] or self.objectReference:GetRefValue("01Transform")
		self.stageLights[2] = self.stageLights[2] or self.objectReference:GetRefValue("02Transform")
		self.stageLights[3] = self.stageLights[3] or self.objectReference:GetRefValue("03Transform")
		self.stageLights[4] = self.stageLights[4] or self.objectReference:GetRefValue("04Transform")
	end

	if self.stageLights[index] then
		self.stageLights[index].gameObject:SetActiveEx(true)
	end
end

function VitalityScene:disableCamera()
	self.camera.enabled = false
end

function VitalityScene:switchLight(noLogic)
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
			local bgRes, bgId = AvatarUtils.getCurSetBgRes(Const.APPEARANCE_BACKGROUND_TYPE.Player)

			self:setBackground(bgRes, bgId)
		end
	end
end

function VitalityScene:getPreviewCurrentEntity()
	return self:getCurEntity()
end

function VitalityScene:getPreviewCameraRootTransform()
	return self.entityRootTransform
end

function VitalityScene:getPreviewCameraConfig(modeName)
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

function VitalityScene:getPreviewDefaultModeName()
	return self.CAMERA.SIMPLE
end

function VitalityScene:getPreviewInitSpringArmLen()
	return 7
end

function VitalityScene:getPreviewInitVerticalOffset()
	return 0.8
end

function VitalityScene:rotatePreviewEntity(deltaAngle)
	local entity = self:getCurEntity()

	if entity and entity.eModel then
		entity.eModel:RotateAroundTransform(deltaAngle)
	end
end

function VitalityScene:adjustCameraConfigByBodySize()
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

function VitalityScene:setEntityPos(entityId, pos)
	local entity = self:getEntity(entityId)

	if entity then
		if pos then
			entity.eModel:SetTransformLocalPosition(pos.x, pos.y, pos.z)
		else
			entity.eModel:SetTransformLocalPosition()
		end
	end
end

function VitalityScene:setEntityRot(entityId, eulerY, duration)
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

function VitalityScene:setCurEntityRot(eulerY, duration)
	self:setEntityRot(self.curEntityId, eulerY, duration)
end

function VitalityScene:showAvatar(presetKey, onAvatarLoaded)
	self.curEntityId = presetKey

	self:switchLight()

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

function VitalityScene:doLoadedCallBack(succeed)
	if self.needShowAvatar then
		local presetKey = pg.game.avatar:getPresetKey(pg.me)

		self:showAvatar(presetKey, function()
			VitalityScene.super.doLoadedCallBack(self, succeed)
		end)
	else
		VitalityScene.super.doLoadedCallBack(self, succeed)
	end
end

function VitalityScene:showAvatarTemplate(presetKey, onAvatarLoaded, sync, force)
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

function VitalityScene:showClothes(defaultSuitId)
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

function VitalityScene:hideClothes()
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

function VitalityScene:playIdleAnimation(entity, fadeTime)
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

function VitalityScene:destroyPet(templateId)
	self:removeEntity(templateId)
end

function VitalityScene:showPetTemplate(petInfo, scale, offset, loadedCallback)
	local templateId = petInfo.templateId

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

		local didRefresh = PetTransmogUtils.applyAppliedTransmog(curEntity, petInfo.id, true)

		self:replayAfterTransmogRefresh(curEntity, didRefresh, function()
			if loadedCallback then
				loadedCallback(curEntity)
			end
		end)

		return
	end

	local initDict = {
		templateId = templateId,
		label = petInfo.label,
		shinyStyle = petInfo.shinyStyle,
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

			if loadedCallback then
				loadedCallback(curEntity)
			end
		end)

		curEntity.modelLoadedCallback = nil
	end
end

function VitalityScene:isSameEntity(entityId)
	return self.curEntityId == entityId
end

function VitalityScene:getCurEntity()
	return self:getEntity(self.curEntityId)
end

function VitalityScene:getCurEntityId()
	return self.curEntityId
end

function VitalityScene:getPresetData()
	return pg.game.avatar:getAvatarPresetData(self.curEntityId) or {}
end

function VitalityScene:removeEntity(entityId)
	VitalityScene.super.removeEntity(self, entityId)

	if self.curEntityId == entityId then
		self.curEntityId = nil
	end
end

function VitalityScene:changeHair(param)
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

function VitalityScene:getCurHairPartId(entityId, partId)
	local entity = self:getEntity(entityId)

	if not entity then
		return
	end

	local partModelInfo = entity.eModel.modelModelView.modelInfo.partModelInfo
	local resId = partModelInfo:GetPartResId(partId) or ""

	return AvatarHairResIdToConfig[resId]
end

function VitalityScene:getCurHairSuitId(entityId)
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

function VitalityScene:changeClothes(param)
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

function VitalityScene:playShowAnimation(entityId, key)
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

function VitalityScene:playCfgAnimation(entityId, key)
	local entity = self:getEntity(entityId)

	if not entity then
		return
	end

	entity:playCfgAnimation(key)
end

function VitalityScene:previewCustomClothes(entityId, outfitId)
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

function VitalityScene:previewCustomAccessory(entityId, outfitId)
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

			if attachInfo then
				AppearanceEffectUtils.setAppearance(entity, slotId, accessoryId, attachInfo.resId)
			end
		end
	end

	ClientModelUtils.addModelAttachList(modelView.modelInfo, attachInfoList)
end

function VitalityScene:refreshPartRendererVisible(entityId, actions)
	local entity = self:getEntity(entityId)

	if not entity then
		return
	end

	ClientModelUtils.applyPartRendererVisibility(entity, actions)
end

function VitalityScene:getCurClothesId(entityId, partId)
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

function VitalityScene:getCurSuitId(entityId)
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

function VitalityScene:switchCameraLookAt(enable)
	local entity = self:getCurEntity()

	if entity then
		local lookAtComponent = entity.eModel.ikLookAtComponent

		if lookAtComponent then
			lookAtComponent.targetCamera = self.camera
			lookAtComponent.enableCameraLookAt = enable
		end
	end
end

function VitalityScene:previewCustomShow(entityId, outfitId)
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

function VitalityScene:showNameBG(resId, localPosition, onResLoaded)
	if not IsNil(self.nameObjectPool[resId]) then
		self.nameObjectPool[resId]:SetActiveEx(true)
		Vector3.enableCreateFromCache()

		self.nameObjectPool[resId].transform.localPosition = localPosition or Vector3.zero

		Vector3.disableCreateFromCache()

		if onResLoaded then
			onResLoaded()
		end

		return
	end

	self:loadUISceneRes(resId, function(obj)
		obj.transform:SetParent(self.scene.transform)
		Vector3.enableCreateFromCache()

		obj.transform.localPosition = localPosition or Vector3.zero

		Vector3.disableCreateFromCache()

		self.nameObjectPool[resId] = obj

		if onResLoaded then
			onResLoaded()
		end
	end)
end

function VitalityScene:hideNameBG()
	for _, nameObject in pairs(self.nameObjectPool) do
		if not IsNil(nameObject) then
			nameObject:SetActiveEx(false)
		end
	end
end

function VitalityScene:playPosAnim(entity, animName, isLoop, finishedCallback)
	local res = entity:playAnimation(animName, false, nil, isLoop)

	if finishedCallback then
		res:AddEndCallback(finishedCallback)
	end
end

function VitalityScene:setPreviewCameraMode()
	self:doSpringArmTween(self.curCameraMode.cameraMode.maxZoom, 1)
	self:doVerticalTween(self.curCameraMode.maxZoomOffsetY, 1)
end

function VitalityScene:setTagCameraMode(callback, duration)
	duration = (duration or 2) - 0.5

	self:doSpringArmTween(2.5, duration)
	Vector3.enableCreateFromCache()

	local start = self.curCameraMode:getPivotOffset()

	self.tagAndNameOffset = start

	local to = Vector3.New(0, 1.2, 0)

	self:doMoveTween(start, to, duration, callback)
	Vector3.disableCreateFromCache(start, to)
end

function VitalityScene:setTipCameraMode(duration)
	local spring = 4
	local offset = Vector2.New(-0.6, 1.1)

	if duration then
		self:doSpringArmTween(spring, duration)
		Vector3.enableCreateFromCache()

		local start = self.curCameraMode:getPivotOffset()

		self:doMoveTween(start, offset, 1)
		Vector3.disableCreateFromCache(start)
	else
		self.curCameraMode:setSpringArmLen(spring)
		self.curCameraMode:moveCameraInVector(offset.x, offset.y)
	end
end

function VitalityScene:setAvatarCameraMode()
	self:doSpringArmTween(5, 1)
	Vector3.enableCreateFromCache()

	local start = self.curCameraMode:getPivotOffset()
	local to = self.tagAndNameOffset or Vector3.New(0, 1, 0)

	self:doMoveTween(start, to, 1)
	Vector3.disableCreateFromCache(start, to)
	self:enableCameraMode(self.CAMERA.SIMPLE)
end

function VitalityScene:setCameraRotationOffset(rotationOffsetY, duration)
	self:doRotationOffsetYTween(rotationOffsetY, duration or 0.2)
end

VitalityScene.cameraDuration = 1

function VitalityScene:reachMinZoom()
	return math.abs(self.curCameraMode:getSpringArmLen() - self.curCameraMode.cameraMode.minZoom) < 0.1
end

function VitalityScene:setAvatarCameraModeCloseHead()
	self:doSpringArmTween(self.curCameraMode.cameraMode.minZoom, self.cameraDuration)

	if self.curCameraMode.minZoomOffsetYSplit then
		self:doVerticalTween(self.curCameraMode.minZoomOffsetYSplit.Hair, self.cameraDuration, true)
	end
end

function VitalityScene:setAvatarCameraModeCloseToChest()
	self:doSpringArmTween(self.curCameraMode.cameraMode.minZoom, self.cameraDuration)

	if self.curCameraMode.minZoomOffsetYSplit then
		self:doVerticalTween(self.curCameraMode.minZoomOffsetYSplit.Chest, self.cameraDuration, true)
	end
end

function VitalityScene:setAvatarCameraModeCloseToWaist()
	self:doSpringArmTween(self.curCameraMode.cameraMode.minZoom, self.cameraDuration)

	if self.curCameraMode.minZoomOffsetYSplit then
		self:doVerticalTween(self.curCameraMode.minZoomOffsetYSplit.Waist, self.cameraDuration, true)
	end
end

function VitalityScene:setAvatarCameraModeCloseToThigh()
	self:doSpringArmTween(self.curCameraMode.cameraMode.minZoom, self.cameraDuration)

	if self.curCameraMode.minZoomOffsetYSplit then
		self:doVerticalTween(self.curCameraMode.minZoomOffsetYSplit.Thigh, self.cameraDuration, true)
	end
end

function VitalityScene:setAvatarCameraModeCloseToFoot()
	self:doSpringArmTween(self.curCameraMode.cameraMode.minZoom, self.cameraDuration)

	if self.curCameraMode.minZoomOffsetYSplit then
		self:doVerticalTween(self.curCameraMode.minZoomOffsetYSplit.Foot, self.cameraDuration, true)
	end
end

function VitalityScene:setAvatarCameraModeFar()
	self:doSpringArmTween(self.curCameraMode.cameraMode.maxZoom, self.cameraDuration)
	self:doVerticalTween(self.curCameraMode.maxZoomOffsetY, self.cameraDuration)
end

function VitalityScene:doSpringArmTween(to, duration)
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

function VitalityScene:doVerticalTween(to, duration, noConstrain)
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

function VitalityScene:doRotationOffsetYTween(to, duration)
	local from = self.curCameraMode.cameraMode.rotationOffset.y

	to = to or 0
	duration = duration or 1

	DoTweenAnimMgr.DoFloat(self.camera.gameObject, from, to, LuaUIUtils.TweenId(ID_ARM_LEN), duration, 0, CS.DG.Tweening.Ease.__CastFrom(1), function()
		return
	end, function(rotationOffsetY)
		Vector3.enableCreateFromCache()

		local offset = self.curCameraMode.cameraMode.rotationOffset

		self.curCameraMode.cameraMode.rotationOffset = Vector3(offset.x, rotationOffsetY, offset.z)

		Vector3.disableCreateFromCache()
	end, function()
		return
	end, false)
end

function VitalityScene:doMoveTween(start, to, duration, finished)
	start = start or Vector3.zero
	to = to or Vector3.zero
	duration = duration or 1

	DoTweenAnimMgr.DoVector3(self.camera.gameObject, LuaUIUtils.TweenId(ID_CAMERA_MOVE), start, to, duration, 0, CS.DG.Tweening.Ease.__CastFrom(1), function()
		return
	end, function(x, y, z)
		self.curCameraMode:moveCameraInVector(x, y)
	end, function()
		if finished then
			finished()
		end
	end)
end

function VitalityScene:onAllEntityLoaded()
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

function VitalityScene:registerAutoSave()
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

function VitalityScene:unRegisterAutoSave()
	if self.autoSaveTimer then
		TimerManager.removeTimer(self.autoSaveTimer)

		self.autoSaveTimer = nil
	end
end

function VitalityScene:setBackground(resId, bgId)
	if self.disableBackground then
		return
	end

	self.bgId = bgId

	if self.bgResId == resId then
		for i = 1, #(self.vitalityBgs or {}) do
			if self.vitalityBgs[i] then
				self.vitalityBgs[i].gameObject:SetActiveEx(i == self.bgId)
			end
		end

		return
	end

	self.bgResId = resId

	if self.curBgGo then
		self:resetVitalityBackgroundScale()
		self:resetSingleCameraParam(self.curBgGo)
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

		self:applySingleCameraParam(gameObj)
		Vector3.enableCreateFromCache()

		self.curBgGo.transform.localPosition = Vector3.zero

		Vector3.disableCreateFromCache()

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

		self:adaptVitalityBackgroundScale()

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

function VitalityScene:recordCurLight()
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

function VitalityScene:restorePrevLight(activatedLightTransform)
	if not activatedLightTransform then
		return
	end

	for _, lightTrans in pairs(activatedLightTransform) do
		if lightTrans then
			lightTrans.gameObject:SetActiveEx(true)
		end
	end
end

function VitalityScene:showPairLights(show)
	if self.twoLightTransform then
		self.twoLightTransform.gameObject:SetActiveEx(show)
	end
end

function VitalityScene:hideAllLights()
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

return VitalityScene
