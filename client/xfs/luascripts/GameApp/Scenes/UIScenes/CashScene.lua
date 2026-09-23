-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Scenes\\UIScenes\\CashScene.lua

local ClientUtils = require("Utils.ClientUtils")
local Class = require("Core.Framework.Class")
local AvatarScene = require("GameApp.Scenes.UIScenes.AvatarScene")
local AvatarPresetData = require("Data.avatar_preset_data")
local PetData = require("Data.pet_data")
local UIConst = require("Const.UIConst")
local Const = require("Common.Const.Const")
local ClientSimpleVirtualPet = require("Entities.ClientSimpleVirtualPet")
local ClientVirtualEntityUtils = require("Utils.ClientVirtualEntityUtils")
local ShopConstantData = require("Data.shopmall_constant_data")
local Utils = require("Common.Utils.Utils")
local UIMirrorEntity = CS.FunPlus.WorldX.GUIS.Panels.UIMirrorEntity
local ClientHomeFurnitureStoreEntity = require("Entities.SpaceEntities.Home.ClientHomeFurnitureStoreEntity")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("CashScene-------------------")
local UIUtils = UIUtils
local CashScene = Class.LightClass("CashScene", AvatarScene)

function CashScene:onCtor()
	self._currentBgType = nil
	self._randomShopMirrorActive = false
	self._randomShopMirrorEntity = nil
	self._randomShopMirrorSourceEntity = nil
	self._randomShopMirrorModelingId = nil
	self._randomShopMirrorBound = false
	self._furnitureModels = {}
	self._furniturePreviewActive = false
	self._currentFurnitureModelResId = nil
	self._pendingFurnitureModelResId = nil
	self._currentEnvironmentIsBP = false
	self._cashShopExSceneActive = false
	self._activeCashShopExScene = nil
	self._cashShopExScenePendingBgType = nil
	self._cashShopExSceneTimelineContexts = {}
	self._currentHasModel = false
	self._bgSwitchToken = 0
end

function CashScene:_nextBgSwitchToken()
	self._bgSwitchToken = self._bgSwitchToken + 1

	return self._bgSwitchToken
end

CashScene.LIGHT_TYPE = {
	BOY = "boy",
	PET = "pet",
	GIRL = "girl"
}
CashScene.SCENE_IMAGE_PATH = "Assets/Res_BranchSync/Environment/UIscene/"
CashScene.SCENE_IMAGE_BASE_MATERIAL = "MI_LVUIMall_BackGround_Tanglang_B379FB01"
CashScene.SCENE_IMAGE_TOP_MATERIAL = "MI_LVUIMall_BackGround_Tanglang_Transparent_2B0C1510"
CashScene.RANDOM_SHOP_MIRROR_ENTITY_ID = "cash-shop-random-mirror"
CashScene.DEFAULT_PET_SELECTION_POSITION = {
	-0.49,
	-0.3,
	-4.96
}
CashScene.DEFAULT_FURNITURE_POSITION = {
	-0.49,
	1,
	-4.96
}

function CashScene:_getShopDisplayPosition(configKey, defaultPosition)
	local config = ShopConstantData[configKey]
	local configPosition = config and config.number or nil

	if Utils.isTable(configPosition) then
		local positionX = tonumber(configPosition[1])
		local positionY = tonumber(configPosition[2])
		local positionZ = tonumber(configPosition[3])

		if positionX and positionY and positionZ then
			return {
				positionX,
				positionY,
				positionZ
			}
		end
	elseif type(configPosition) == "string" then
		local position = {}

		for value in string.gmatch(configPosition, "[-+]?%d+%.?%d*") do
			position[#position + 1] = tonumber(value)
		end

		if position[1] and position[2] and position[3] then
			return position
		end
	end

	return defaultPosition
end

function CashScene:_setEntityRootPositionOverride(contextField, active, configKey, defaultPosition)
	local context = self[contextField]

	if not active then
		if context and not IsNil(context.root) then
			context.root.localPosition = Vector3.New(context.position[1], context.position[2], context.position[3])
		end

		self[contextField] = nil

		return
	end

	if context or IsNil(self.entityRootTransform) then
		return
	end

	local originalPosition = self.entityRootTransform.localPosition

	self[contextField] = {
		root = self.entityRootTransform,
		position = {
			originalPosition.x,
			originalPosition.y,
			originalPosition.z
		}
	}

	local position = self:_getShopDisplayPosition(configKey, defaultPosition)

	self.entityRootTransform.localPosition = Vector3.New(position[1], position[2], position[3])
end

function CashScene:setPetSelectionPositionActive(active)
	self:_setEntityRootPositionOverride("_petSelectionRootPositionContext", active, "petPos", CashScene.DEFAULT_PET_SELECTION_POSITION)
end

function CashScene:setAccessoryPackagePetPositionActive(active)
	self:_setEntityRootPositionOverride("_accessoryPackagePetRootPositionContext", active, "petPos", CashScene.DEFAULT_PET_SELECTION_POSITION)
end

function CashScene:_setFurniturePositionActive(active)
	self:_setEntityRootPositionOverride("_furnitureRootPositionContext", active, "furniturePos", CashScene.DEFAULT_FURNITURE_POSITION)
end

function CashScene:onStart()
	local isAppearanceOpen = pg.global.ui:checkUIOpen(UIConst.UI_ID_APPEARANCE_V2) or pg.global.ui:checkUIOpen(UIConst.UI_ID_AVATAR) or pg.global.ui:checkUIOpen(UIConst.UI_ID_WORKSHOP_DESIGN) or pg.global.ui:checkUIOpen(UIConst.UI_ID_WORKSHOP_COSTUME_STAIN)

	if isAppearanceOpen then
		pg.global.ui:close(UIConst.UI_ID_APPEARANCE_V2)
		pg.global.ui:close(UIConst.UI_ID_AVATAR)
		pg.global.ui:close(UIConst.UI_ID_WORKSHOP_DESIGN)
		pg.global.ui:close(UIConst.UI_ID_WORKSHOP_COSTUME_STAIN)
	end

	self.dontSetCamera = true

	AvatarScene.onStart(self)

	self.defaultEntityRootTransform = self.entityRootTransform

	local objectReference = self.scene.transform:Find("Global"):GetComponent("ObjectReference")

	self.boyLight = objectReference:GetRefValue("boyLight")
	self.girlLight = objectReference:GetRefValue("girlLight")
	self.petLight = objectReference:GetRefValue("petLight")
	self.exclusiveTransform = objectReference:GetRefValue("exclusiveTransform")
	self.exclusiveBaseXRender = objectReference:GetRefValue("exclusiveBaseXRender")
	self.exclusiveTopXRender = objectReference:GetRefValue("exclusiveTopXRender")
	self.normalBG = objectReference:GetRefValue("normalBG")
	self.normalBGAnim = objectReference:GetRefValue("normalBGAnim")

	self.exclusiveTransform.gameObject:SetActiveEx(false)
	self.exclusiveBaseXRender.gameObject:SetActiveEx(true)
	self.exclusiveTopXRender.gameObject:SetActiveEx(true)

	self.normalEnv = objectReference:GetRefValue("normalEnv")
	self.BPEnv = objectReference:GetRefValue("BPEnv")
	self.entityRootMirrorTransform = objectReference:GetRefValue("entityRootMirrorTransform")

	if self.entityRootMirrorTransform then
		self.entityRootMirrorTransform.gameObject:SetActiveEx(false)
	end

	self:switchEnvironment(false)
end

function CashScene:onDestroy()
	self:clearCashShopExSceneTimelineEntities(false)
	self:setCashShopExSceneActive(false)
	self:hideRandomShopMirrorPet()

	if self._furnitureModels then
		for _, entity in pairs(self._furnitureModels) do
			entity.modelLoadedCallback = nil

			ClientUtils.safeDestroy(entity)
		end

		table.clear(self._furnitureModels)
	end

	self._furnitureModels = nil
	self.defaultEntityRootTransform = nil

	AvatarScene.onDestroy(self)
end

function CashScene:createCashShopExSceneTimelineEntity()
	local sourceEntity = self:getCurEntity()

	if not sourceEntity or IsNil(sourceEntity.eModel) then
		return nil
	end

	local timelineEntity = ClientVirtualEntityUtils.copySimpleVirtualPlayerFrom({
		isIgnoreEffectLod = true,
		syncLoad = true,
		copyEntity = sourceEntity
	})

	if not timelineEntity or IsNil(timelineEntity.eModel) then
		return nil
	end

	timelineEntity.eModel:SetTransformParent(self.entityRootTransform, false)
	self:_resetEntityTransform(timelineEntity)

	timelineEntity.eModel.enableCameraHitCheck = false

	timelineEntity:setDisableEffectLod(true)
	timelineEntity.eModel:SetModelVisible(false)

	local timelineContext = {
		sourceEntity = sourceEntity,
		timelineEntity = timelineEntity
	}

	self._cashShopExSceneTimelineContexts[timelineContext] = true

	return timelineContext
end

function CashScene:activateCashShopExSceneTimelineEntity(timelineContext)
	if not timelineContext or not self._cashShopExSceneTimelineContexts[timelineContext] then
		return false
	end

	local sourceEntity = timelineContext.sourceEntity
	local timelineEntity = timelineContext.timelineEntity

	if not sourceEntity or IsNil(sourceEntity.eModel) or not timelineEntity or IsNil(timelineEntity.eModel) then
		return false
	end

	sourceEntity.eModel:SetModelVisible(false)
	timelineEntity.eModel:SetModelVisible(true)

	timelineContext.active = true

	return true
end

function CashScene:destroyCashShopExSceneTimelineEntity(timelineContext, restoreSource)
	if not timelineContext or timelineContext.destroyed then
		return
	end

	timelineContext.destroyed = true
	self._cashShopExSceneTimelineContexts[timelineContext] = nil

	local timelineEntity = timelineContext.timelineEntity

	timelineContext.timelineEntity = nil

	if timelineEntity then
		timelineEntity:destroy()
	end

	local sourceEntity = timelineContext.sourceEntity

	timelineContext.sourceEntity = nil

	if restoreSource and timelineContext.active and sourceEntity and not IsNil(sourceEntity.eModel) then
		sourceEntity.eModel:SetModelVisible(true)
	end
end

function CashScene:clearCashShopExSceneTimelineEntities(restoreSource)
	local timelineContexts = {}

	for timelineContext in pairs(self._cashShopExSceneTimelineContexts) do
		timelineContexts[#timelineContexts + 1] = timelineContext
	end

	for _, timelineContext in ipairs(timelineContexts) do
		self:destroyCashShopExSceneTimelineEntity(timelineContext, restoreSource)
	end
end

function CashScene:_syncRandomShopMirrorTransform()
	local sourceEntity = self._randomShopMirrorSourceEntity
	local mirrorEntity = self._randomShopMirrorEntity

	if not sourceEntity or IsNil(sourceEntity.eModel) or not mirrorEntity or IsNil(mirrorEntity.eModel) then
		return
	end

	local position = sourceEntity.eModel.transform.localPosition
	local rotationX, rotationY, rotationZ = sourceEntity.eModel:GetTransformRotationEulerAngles()

	mirrorEntity.eModel:SetLocalPosition(position.x, position.y, position.z)
	mirrorEntity.eModel:SetTransformRotationByEulerAngle(rotationX, rotationY, rotationZ)
	mirrorEntity:setScaleNumber(sourceEntity:getScaleNumber())
end

function CashScene:_tryBindRandomShopMirrorEntity()
	if not self._randomShopMirrorActive or self._randomShopMirrorBound then
		return false
	end

	local sourceEntity = self._randomShopMirrorSourceEntity
	local mirrorEntity = self._randomShopMirrorEntity
	local sourceSkeleton = sourceEntity and sourceEntity.eModel and sourceEntity.eModel.modelSkeletonView and sourceEntity.eModel.modelSkeletonView.skeletonRoot
	local mirrorSkeleton = mirrorEntity and mirrorEntity.eModel and mirrorEntity.eModel.modelSkeletonView and mirrorEntity.eModel.modelSkeletonView.skeletonRoot

	if not sourceSkeleton or not mirrorSkeleton then
		return false
	end

	UIMirrorEntity.Create(mirrorEntity.eModel.animator, sourceEntity.eModel.animator)

	self._randomShopMirrorBound = true

	return true
end

function CashScene:showRandomShopMirrorPet(sourceEntity, modelingId, petConfigData)
	if not sourceEntity or IsNil(sourceEntity.eModel) or not modelingId or not petConfigData or string.isNilOrEmpty(petConfigData.prefabResID) or IsNil(self.entityRootMirrorTransform) then
		return false
	end

	if self._randomShopMirrorEntity and self._randomShopMirrorModelingId ~= modelingId then
		self:removeEntity(CashScene.RANDOM_SHOP_MIRROR_ENTITY_ID)

		self._randomShopMirrorEntity = nil
	end

	self._randomShopMirrorActive = true
	self._randomShopMirrorSourceEntity = sourceEntity
	self._randomShopMirrorModelingId = modelingId
	self._randomShopMirrorBound = false

	self.entityRootMirrorTransform.gameObject:SetActiveEx(true)

	local mirrorEntity = self._randomShopMirrorEntity

	if not mirrorEntity then
		local initInfo = {
			templateId = modelingId,
			configData = petConfigData
		}

		mirrorEntity = self:createEntity(CashScene.RANDOM_SHOP_MIRROR_ENTITY_ID, ClientSimpleVirtualPet, initInfo)

		mirrorEntity:setDisableEffectLod(true)

		mirrorEntity.eModel.enableCameraHitCheck = false
		self._randomShopMirrorEntity = mirrorEntity

		function mirrorEntity.modelLoadedCallback()
			mirrorEntity.modelLoadedCallback = nil

			if not self._randomShopMirrorActive or self._randomShopMirrorEntity ~= mirrorEntity then
				return
			end

			mirrorEntity.eModel:PlayDefaultAnimation(Const.COMPONENT_IDX_PLAYABLE, true)
			self:_syncRandomShopMirrorTransform()
			self:_tryBindRandomShopMirrorEntity()
		end
	end

	mirrorEntity.eModel:SetTransformParent(self.entityRootMirrorTransform, false)
	mirrorEntity.eModel:SetActive(true)
	self:_syncRandomShopMirrorTransform()
	self:_tryBindRandomShopMirrorEntity()

	return true
end

function CashScene:hideRandomShopMirrorPet()
	self._randomShopMirrorActive = false

	if self.entityRootMirrorTransform then
		self.entityRootMirrorTransform.gameObject:SetActiveEx(false)
	end

	local mirrorEntity = self._randomShopMirrorEntity

	if mirrorEntity then
		mirrorEntity.modelLoadedCallback = nil

		self:removeEntity(CashScene.RANDOM_SHOP_MIRROR_ENTITY_ID)
	end

	self._randomShopMirrorEntity = nil
	self._randomShopMirrorSourceEntity = nil
	self._randomShopMirrorModelingId = nil
	self._randomShopMirrorBound = false
end

function CashScene:rotatePreviewEntity(deltaAngle)
	if self._furniturePreviewActive and self._currentFurnitureModelResId then
		local entity = self._furnitureModels and self._furnitureModels[self._currentFurnitureModelResId]
		local itemModel = entity and entity.eModel and entity.eModel.itemModel

		if itemModel then
			local rotation = itemModel.transform.localRotation.eulerAngles

			itemModel.transform.localRotation = Quaternion.Euler(rotation.x, rotation.y + deltaAngle, rotation.z)
		end

		return
	end

	AvatarScene.rotatePreviewEntity(self, deltaAngle)

	if self._randomShopMirrorActive then
		local mirrorEntity = self._randomShopMirrorEntity

		if mirrorEntity and not IsNil(mirrorEntity.eModel) then
			mirrorEntity.eModel:RotateAroundTransform(deltaAngle)
		end
	end
end

function CashScene:showFurnitureModel(previewData)
	local resId = previewData and previewData.modelResId

	if not resId then
		return false
	end

	self:hideFurnitureModel()
	self:_setFurniturePositionActive(true)

	self._furniturePreviewActive = true
	self._pendingFurnitureModelResId = resId

	local entity = self._furnitureModels[resId]

	if entity then
		if entity.modelReady then
			self:_showFurnitureEntity(resId, previewData)
		end

		return true
	end

	entity = ClientHomeFurnitureStoreEntity.new()
	self._furnitureModels[resId] = entity

	entity:setConfigData(previewData)
	entity:setModelLayer()

	function entity.modelLoadedCallback()
		entity.modelReady = true

		if not self._furniturePreviewActive or self._pendingFurnitureModelResId ~= resId then
			if not IsNil(entity.eModel) then
				entity.eModel:SetActive(false)
			end

			return
		end

		self:_showFurnitureEntity(resId, previewData)
	end

	entity:start()

	local initInfo = {}

	entity:init(initInfo)
	entity:postInit(initInfo)

	return true
end

function CashScene:_showFurnitureEntity(resId, previewData)
	local entity = self._furnitureModels and self._furnitureModels[resId]

	if not entity or IsNil(entity.eModel) then
		return
	end

	self._currentFurnitureModelResId = resId

	entity:setConfigData(previewData)
	entity.eModel:SetActive(true)
	entity.eModel:SetTransformParent(self.entityRootTransform, false)
	entity.eModel:SetTransformLocalPosition()
	entity:setScaleNumber(previewData.modelScale or 1)

	local itemModel = entity.eModel.itemModel

	if itemModel then
		local positionOffset = previewData.positionOffset or {
			0,
			0,
			0
		}
		local modelRotationInit = previewData.modelRotationInit or {
			0,
			0,
			0
		}

		itemModel.transform.localPosition = Vector3.New(positionOffset[1] or 0, positionOffset[2] or 0, positionOffset[3] or 0)
		itemModel.transform.localRotation = Quaternion.Euler(modelRotationInit[1] or 0, modelRotationInit[2] or 0, modelRotationInit[3] or 0)
	end

	if self.enableCameraMode then
		self:enableCameraMode(self.CAMERA.SIMPLE)
	end

	if self.setAvatarCameraModeFar then
		self:setAvatarCameraModeFar()
	end

	self:hideAllRoleLights()
end

function CashScene:hideFurnitureModel()
	self._furniturePreviewActive = false

	local resId = self._currentFurnitureModelResId or self._pendingFurnitureModelResId

	self._pendingFurnitureModelResId = nil

	local entity = resId and self._furnitureModels and self._furnitureModels[resId]

	if entity and not IsNil(entity.eModel) then
		entity.eModel:SetActive(false)
	end

	self._currentFurnitureModelResId = nil

	self:_setFurniturePositionActive(false)
end

function CashScene:getPreviewCurrentEntity()
	if self._furniturePreviewActive and self._currentFurnitureModelResId then
		return self._furnitureModels and self._furnitureModels[self._currentFurnitureModelResId]
	end

	return AvatarScene.getPreviewCurrentEntity(self)
end

function CashScene:switchEnvironment(isBP)
	self._currentEnvironmentIsBP = isBP == true

	if self._cashShopExSceneActive then
		if self.normalEnv then
			self.normalEnv.gameObject:SetActiveEx(false)
		end

		if self.BPEnv then
			self.BPEnv.gameObject:SetActiveEx(false)
		end

		return
	end

	if self.normalEnv then
		self.normalEnv.gameObject:SetActiveEx(not isBP)
	end

	if self.BPEnv then
		self.BPEnv.gameObject:SetActiveEx(isBP == true)
	end
end

function CashScene:_hideAllBg(token)
	if self.normalBG then
		self.normalBG.gameObject:SetActiveEx(true)
	end

	if self.normalBGAnim then
		UIUtils.PlayAnimation(self.normalBGAnim, "VX_Ani_MallBg_In", function()
			if token ~= self._bgSwitchToken then
				return
			end

			if self.exclusiveTransform then
				self.exclusiveTransform.gameObject:SetActiveEx(false)
			end
		end)
	elseif self.exclusiveTransform then
		self.exclusiveTransform.gameObject:SetActiveEx(false)
	end
end

function CashScene:_applyBgImmediately(bgType, token)
	self:_hideAllBg(token)

	self._currentBgType = bgType
end

function CashScene:_playDynamicBg(uiBack)
	self.exclusiveTransform.gameObject:SetActiveEx(true)

	if not self.exclusiveTopXRender then
		return
	end

	UIUtils.PlayPMOfGameObjectByPMName(self.exclusiveTopXRender.gameObject, "Eff_Background_Lightsweep_01", CashScene.SCENE_IMAGE_PATH .. uiBack, 1.2, CashScene.SCENE_IMAGE_TOP_MATERIAL)
end

function CashScene:switchBackground(uiBack)
	if uiBack and type(uiBack) == "string" then
		uiBack = uiBack:gsub("^%s*%$", "")
	end

	if self._cashShopExSceneActive then
		self._cashShopExScenePendingBgType = uiBack

		return
	end

	if uiBack == self._currentBgType then
		return
	end

	local token = self:_nextBgSwitchToken()

	if uiBack == nil then
		self:_hideAllBg(token)

		self._currentBgType = nil

		return
	end

	if uiBack == 3 then
		self:_applyBgImmediately(3, token)

		return
	end

	if not self.exclusiveTransform then
		return
	end

	self.exclusiveTransform.gameObject:SetActiveEx(true)

	local transitionDuration = self._currentBgType and 3.2 or 0
	local normalBGShowing = self._currentBgType == nil or self._currentBgType == 3

	if self._currentBgType == 3 then
		self.exclusiveBaseXRender.gameObject:SetActiveEx(false)
		UIUtils.PlayPMOfGameObjectByPMName(self.exclusiveTopXRender.gameObject, "Eff_Background_Lightsweep_01", CashScene.SCENE_IMAGE_PATH .. uiBack, transitionDuration, CashScene.SCENE_IMAGE_TOP_MATERIAL)
	else
		if self._currentBgType then
			UIUtils.PlayPMOfGameObjectByPMName(self.exclusiveBaseXRender.gameObject, "Eff_Background_Lightsweep_01", CashScene.SCENE_IMAGE_PATH .. self._currentBgType, 0, CashScene.SCENE_IMAGE_BASE_MATERIAL)
		end

		UIUtils.PlayPMOfGameObjectByPMName(self.exclusiveTopXRender.gameObject, "Eff_Background_Lightsweep_01", CashScene.SCENE_IMAGE_PATH .. uiBack, transitionDuration, CashScene.SCENE_IMAGE_TOP_MATERIAL)
	end

	if normalBGShowing and self.normalBGAnim then
		UIUtils.PlayAnimation(self.normalBGAnim, "VX_Ani_MallBg_Out", function()
			self.exclusiveBaseXRender.gameObject:SetActiveEx(true)

			if token ~= self._bgSwitchToken then
				return
			end

			if self.normalBG then
				self.normalBG.gameObject:SetActiveEx(false)
			end
		end)
	elseif normalBGShowing and self.normalBG then
		self.normalBG.gameObject:SetActiveEx(false)
	end

	self._currentBgType = uiBack
end

function CashScene:hideAllRoleLights()
	if self.boyLight then
		self.boyLight.gameObject:SetActiveEx(false)
	end

	if self.girlLight then
		self.girlLight.gameObject:SetActiveEx(false)
	end

	if self.petLight then
		self.petLight.gameObject:SetActiveEx(false)
	end
end

function CashScene:syncLight(hasModel)
	self._currentHasModel = hasModel == true

	if self._cashShopExSceneActive then
		self:hideAllRoleLights()
		self:_syncCashShopExSceneLight(hasModel)

		return
	end

	if self._furniturePreviewActive then
		self:hideAllRoleLights()

		return
	end

	if hasModel then
		self:switchLight()
	else
		self:hideAllRoleLights()
	end
end

function CashScene:_syncCashShopExSceneLight(hasModel)
	local exScene = self._activeCashShopExScene

	if not exScene or not exScene.syncLight then
		return
	end

	if hasModel ~= true or self._furniturePreviewActive or not self.curEntityId then
		exScene:syncLight(false)

		return
	end

	local presetData = pg.game.avatar:getAvatarPresetData(self.curEntityId)

	if not presetData then
		exScene:syncLight(PetData[self.curEntityId] ~= nil, false)

		return
	end

	local body = tonumber(presetData.body)
	local isFemale = body == nil or math.floor(body / 10) == 1

	exScene:syncLight(true, isFemale)
end

function CashScene:switchLight()
	if self._furniturePreviewActive then
		self:hideAllRoleLights()

		return
	end

	if self._cashShopExSceneActive then
		self:_moveCurrentEntityToRoot(self.entityRootTransform)
		self:hideAllRoleLights()
		self:_syncCashShopExSceneLight(true)

		return
	end

	if not self.curEntityId then
		return
	end

	local presetData = pg.game.avatar:getAvatarPresetData(self.curEntityId)

	if presetData then
		local body = presetData.body
		local isFemale = body and math.floor(body / 10) == 1

		if self.boyLight then
			self.boyLight.gameObject:SetActiveEx(not isFemale)
		end

		if self.girlLight then
			self.girlLight.gameObject:SetActiveEx(isFemale == true)
		end

		if self.petLight then
			self.petLight.gameObject:SetActiveEx(false)
		end

		return
	end

	local petData = PetData[self.curEntityId]

	if petData then
		if self.boyLight then
			self.boyLight.gameObject:SetActiveEx(false)
		end

		if self.girlLight then
			self.girlLight.gameObject:SetActiveEx(false)
		end

		if self.petLight then
			self.petLight.gameObject:SetActiveEx(true)
		end
	end
end

function CashScene:_resetEntityTransform(entity)
	if not entity or IsNil(entity.eModel) then
		return
	end

	entity.eModel:SetTransformLocalPosition()
	entity.eModel:SetTransformLocalRotation(0, 0, 0, 1)
end

function CashScene:_moveCurrentEntityToRoot(entityRootTransform)
	if IsNil(entityRootTransform) then
		return
	end

	local entity = self:getCurEntity()

	if not entity or IsNil(entity.eModel) then
		return
	end

	entity.eModel:SetTransformParent(entityRootTransform, false)
	self:_resetEntityTransform(entity)
end

function CashScene:resetCashShopExSceneEntity(timelineContext, restoreSource)
	restoreSource = restoreSource ~= false

	local restoreCurrentEntity = restoreSource and (not timelineContext or timelineContext.active)
	local sourceEntity = timelineContext and timelineContext.sourceEntity

	if timelineContext then
		self:destroyCashShopExSceneTimelineEntity(timelineContext, restoreSource)
	else
		self:clearCashShopExSceneTimelineEntities(restoreSource)
	end

	if not restoreCurrentEntity then
		return
	end

	local entity = sourceEntity or self:getCurEntity()

	if not entity or IsNil(entity.eModel) then
		return
	end

	if sourceEntity and sourceEntity ~= self:getCurEntity() then
		return
	end

	entity.eModel:SetModelVisible(true)
	self:_moveCurrentEntityToRoot(self.entityRootTransform)
end

function CashScene:_moveAllEntitiesToRoot(entityRootTransform)
	if IsNil(entityRootTransform) then
		return false
	end

	local reapplyAccessoryPackagePetPosition = self._accessoryPackagePetRootPositionContext ~= nil
	local reapplyFurniturePosition = self._furnitureRootPositionContext ~= nil

	if reapplyFurniturePosition then
		self:_setFurniturePositionActive(false)
	end

	if reapplyAccessoryPackagePetPosition then
		self:setAccessoryPackagePetPositionActive(false)
	end

	self.entityRootTransform = entityRootTransform

	if reapplyAccessoryPackagePetPosition then
		self:setAccessoryPackagePetPositionActive(true)
	end

	if reapplyFurniturePosition then
		self:_setFurniturePositionActive(true)
	end

	for _, entity in pairs(self:getAllEntities()) do
		if entity and not IsNil(entity.eModel) then
			entity.eModel:SetTransformParent(entityRootTransform, false)
		end
	end

	for timelineContext in pairs(self._cashShopExSceneTimelineContexts or {}) do
		local timelineEntity = timelineContext and timelineContext.timelineEntity

		if timelineEntity and not IsNil(timelineEntity.eModel) then
			timelineEntity.eModel:SetTransformParent(entityRootTransform, false)
		end
	end

	self:_moveCurrentEntityToRoot(entityRootTransform)

	return true
end

function CashScene:setCashShopExSceneActive(active, entityRootTransform, exScene)
	active = active == true

	if active and IsNil(entityRootTransform) then
		logger:error("激活商城特殊商品 UI 场景失败：entityRootTransform 为空")

		return false
	end

	if active and exScene then
		self._activeCashShopExScene = exScene
	end

	if self._cashShopExSceneActive == active then
		if active then
			self:_moveAllEntitiesToRoot(entityRootTransform)
			self:switchEnvironment(self._currentEnvironmentIsBP)

			if self.normalBG then
				self.normalBG.gameObject:SetActiveEx(false)
			end

			if self.exclusiveTransform then
				self.exclusiveTransform.gameObject:SetActiveEx(false)
			end

			self:hideAllRoleLights()
			self:_syncCashShopExSceneLight(self._currentHasModel)
		end

		return true
	end

	self._cashShopExSceneActive = active

	if active then
		self:_moveAllEntitiesToRoot(entityRootTransform)

		self._cashShopExScenePendingBgType = self._currentBgType

		self:switchEnvironment(self._currentEnvironmentIsBP)

		if self.normalBG then
			self.normalBG.gameObject:SetActiveEx(false)
		end

		if self.exclusiveTransform then
			self.exclusiveTransform.gameObject:SetActiveEx(false)
		end

		self:hideAllRoleLights()
		self:_syncCashShopExSceneLight(self._currentHasModel)

		return true
	end

	self:_syncCashShopExSceneLight(false)

	self._activeCashShopExScene = nil

	self:_moveAllEntitiesToRoot(self.defaultEntityRootTransform)
	self:switchEnvironment(self._currentEnvironmentIsBP)

	local targetBgType = self._cashShopExScenePendingBgType

	self._cashShopExScenePendingBgType = nil

	if targetBgType == nil then
		self._currentBgType = nil

		self:_hideAllBg(self:_nextBgSwitchToken())
	else
		self._currentBgType = nil

		self:switchBackground(targetBgType)
	end

	self:syncLight(self._currentHasModel)

	return true
end

return CashScene
