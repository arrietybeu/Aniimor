-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CashShop\\Component\\AvatarPreviewComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local GlobalData = require("Core.Client.GlobalData")
local UIComponent = require("Guis.Helper.UIComponent")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local UIConst = require("Const.UIConst")
local Const = require("Const.Const")
local EffectConst = require("Const.EffectConst")
local Utils = require("Common.Utils.Utils")
local ItemConst = require("Common.Const.ItemConst")
local AvatarUtils = require("Guis.Utils.AvatarUtils")
local AppearanceData = require("Data.appearance_data")
local AppearancePointEnum = require("Data.appearance_point_enum")
local AppearanceSuitData = require("Data.appearance_suit_data")
local AvatarHairSuitData = require("Data.avatar_hair_suit_data")
local AppearanceMakeupPresetData = require("Data.appearance_makeup_preset_data")
local AppearanceBackGroundData = require("Data.appearance_background_data")
local AppearanceJewelryPetData = require("Data.appearance_jewelry_pet_data")
local AppearanceActionData = require("Data.appearance_action_data")
local HomeObjectData = require("Data.home_object_data")
local ColorJewelryData = require("Data.appearance_color_jewelry_data")
local AvatarPresetData = require("Data.avatar_preset_data")
local PetData = require("Data.pet_data")
local ClientModelUtils = require("Utils.ClientModelUtils")
local AppearanceEffectUtils = require("Utils.AppearanceEffectUtils")
local ClientHomelandUtils = require("Utils.ClientHomelandUtils")
local MessageName = require("Const.MessageName")
local ItemUtils = require("Common.Utils.ItemUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PlayableConst = require("Common.Const.PlayableConst")
local ClientSimpleVirtualPlayer = require("Entities.ClientSimpleVirtualPlayer")
local ClientSimpleVirtualPet = require("Entities.ClientSimpleVirtualPet")
local AppearanceJewelryInfo = require("CustomTypes.AppearanceJewelryInfo")
local PetJewelryOssCache = require("Utils.PetJewelryOssCache")
local LoggerManager = require("Core.Log.LoggerManager")
local logger = LoggerManager.getLogger("TalentList")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local Animator = CS.UnityEngine.Animator
local logger = require("Core.Log.LoggerManager").getLogger("CashShopAvatarPreviewComponent")
local CAMERA_ZOOM_BINDING_NAMES = {
	"cameraZoom",
	"cameraZoomInGamepad",
	"cameraZoomOutGamepad"
}
local MODELING_PET_LOAD_TIMEOUT_SECONDS = 15
local avatarMgr = pg.global.avatarMgr
local AvatarPreviewComponent = Class.LightClass("AvatarPreviewComponent", UIComponent)

AvatarPreviewComponent.SUIT_POWER_INTERACTION_PET_ENTITY_ID = "cash-shop-suit-power-interaction-pet"

local SUIT_POWER_INTERACTION_DEFAULT_POS_ROT = {
	{
		{
			0,
			0,
			0
		},
		{
			0,
			-90,
			0
		}
	},
	{
		{
			0,
			0,
			0
		},
		{
			0,
			90,
			0
		}
	}
}

AvatarPreviewComponent.messages = {
	[MessageName.PET_BOX_SELECTED] = {
		"onPetBoxSelected"
	}
}

local APPEARANCE_TYPE = {
	SUIT = 5,
	MAKEUP = 4,
	HAIR = 3,
	CLOTHES = 2,
	ACCESSORY = 1
}
local DATA_TYPE_TO_ENUM = {
	APPEARANCE_TYPE.ACCESSORY,
	APPEARANCE_TYPE.CLOTHES,
	APPEARANCE_TYPE.HAIR,
	APPEARANCE_TYPE.MAKEUP
}

AvatarPreviewComponent.APPEARANCE_TYPE = APPEARANCE_TYPE

function AvatarPreviewComponent:onCtor(extInfo)
	self.sceneType = extInfo.sceneType or UISceneConst.CASH_SCENE
end

function AvatarPreviewComponent:initView()
	self.avatarScene = pg.game.uiScene:getScene(self.sceneType)
	self.curPresetKey = self.extInfo and self.extInfo.presetKey or pg.game.avatar:getPresetKey(pg.me)
	self.curPetId = nil
	self._petPreviewActive = false
	self.petAccessMap = {}
	self.petOriginalAccessMap = {}
	self._petPreviewSlots = {}
	self._suitPowerPreviewVersion = 0
	self._suitPowerEffectEntityId = nil
	self._suitPowerEffectId = nil
	self._suitPowerEffectKey = nil
	self._suitPowerEffectRawKey = nil
	self._suitPowerIdleEntityId = nil
	self._suitPowerInteractionManager = nil
	self._suitPowerInteractionSession = nil
	self._suitPowerInteractionContext = nil
	self._suitPowerInteractionPetTemplateId = nil
	self._suitPowerPendingInteraction = nil
	self._suitPowerInteractionRotationBlocked = false
	self._shopPreviewAnimationKey = nil
	self._gestureMaskTrans = nil
	self._lastPlayerPreviewEntityId = nil
	self._modelingPetLoadToken = 0
	self._modelingPetLoadTimerId = nil

	local disableCameraZoom = self.extInfo and self.extInfo.disableCameraZoom

	if not disableCameraZoom and self.avatarScene and self.avatarScene.addCameraZoomKeyBinding then
		self.avatarScene:addCameraZoomKeyBinding(self.view.gameObject, nil, function()
			return self:isModelRotationBlocked()
		end)
	end
end

function AvatarPreviewComponent:isModelRotationBlocked()
	if self._suitPowerInteractionRotationBlocked then
		return true
	end

	local curComponent = self.ctrl and self.ctrl.curComponent
	local isRandomShop = curComponent and curComponent.isRandomShopPageActive and curComponent:isRandomShopPageActive()

	if isRandomShop then
		return true
	end

	return false
end

function AvatarPreviewComponent:isGamepadModelRotationBlocked()
	return self:isModelRotationBlocked()
end

function AvatarPreviewComponent:onDestroy()
	self:_cancelModelingPetLoadTimeout()

	self._modelingPetLoadToken = (self._modelingPetLoadToken or 0) + 1
	self._facePreviewUndyedMode = nil

	self:clearSuitPowerPreviewState()

	self.avatarScene = nil

	UIComponent.onDestroy(self)
end

local clothStainBlockerInstalled = false

function AvatarPreviewComponent:_installCashShopClothStainBlocker()
	if clothStainBlockerInstalled then
		return
	end

	clothStainBlockerInstalled = true

	local origApplyClothStainInfo = ClientModelUtils.applyClothStainInfo

	function ClientModelUtils.applyClothStainInfo(entity, part, unit)
		if entity and entity._cashShopFaceUndyedActive then
			if entity.eModel and entity.eModel.modelShaderView then
				entity.eModel.modelShaderView:ApplyPreset(part, "Default1")
			end

			local modelView = entity.eModel and entity.eModel.modelModelView

			if modelView and modelView.shaderView then
				modelView.shaderView:ApplyPreset(part, "Default1")
			end

			return
		end

		return origApplyClothStainInfo(entity, part, unit)
	end
end

function AvatarPreviewComponent:setFacePreviewUndyedMode(enabled)
	local nextEnabled = enabled == true

	if self._facePreviewUndyedMode == nextEnabled then
		if nextEnabled then
			local entity = self.avatarScene and self.avatarScene:getCurEntity()

			if entity and not entity._cashShopFaceUndyedActive then
				self:_ensureFacePreviewUndyedHook(entity)
			end
		end

		return
	end

	self._facePreviewUndyedMode = nextEnabled

	if self.avatarScene then
		self:_uninstallFacePreviewUndyedHook(self.avatarScene:getEntity(self.curPresetKey))

		if self.templatePresetKey then
			self:_uninstallFacePreviewUndyedHook(self.avatarScene:getEntity(self.templatePresetKey))
		end
	end

	local entity = self.avatarScene and self.avatarScene:getCurEntity()

	if not entity then
		return
	end

	if nextEnabled then
		self:_ensureFacePreviewUndyedHook(entity)
	else
		self:_uninstallFacePreviewUndyedHook(entity)
	end
end

function AvatarPreviewComponent:_forEachClothesShaderView(entity, callback)
	if not entity or not entity.eModel or not callback then
		return
	end

	local modelView = entity.eModel.modelModelView
	local visited = {}

	local function visit(shaderView)
		if not shaderView or visited[shaderView] then
			return
		end

		visited[shaderView] = true

		callback(shaderView)
	end

	if modelView then
		visit(modelView.shaderView)
	end

	visit(entity.eModel.shaderView)
	visit(entity.eModel.modelShaderView)
end

function AvatarPreviewComponent:_collectEquippedClothesStainSlotIds(entity)
	local slotIds = {}
	local visited = {}

	local function addSlot(slotId)
		slotId = tonumber(slotId)

		if not slotId or slotId == 0 or visited[slotId] then
			return
		end

		visited[slotId] = true
		slotIds[#slotIds + 1] = slotId
	end

	for partId = AppearancePointEnum.Coat, AppearancePointEnum.Shoes do
		local clothesId

		if entity.getAppearanceConfigId then
			clothesId = entity:getAppearanceConfigId(partId, true, true)
		elseif entity.curShow and entity.curShow.customShow then
			clothesId = entity.curShow.customShow[partId]
		end

		if clothesId and clothesId ~= 0 then
			addSlot(partId)

			local clothesData = AppearanceData[clothesId] or {}

			for _, pointId in ipairs(clothesData.points or EMPTY_TABLE) do
				addSlot(pointId)
			end
		end
	end

	if #slotIds == 0 then
		for partId = AppearancePointEnum.Coat, AppearancePointEnum.Shoes do
			addSlot(partId)
		end
	end

	return slotIds
end

function AvatarPreviewComponent:_resetClothesStainToDefault(entity)
	if not entity or not entity.eModel then
		return
	end

	local modelView = entity.eModel.modelModelView

	if not modelView or not modelView.partModel then
		return
	end

	local stainSlotIds = self:_collectEquippedClothesStainSlotIds(entity)

	self:_forEachClothesShaderView(entity, function(shaderView)
		for _, slotId in ipairs(stainSlotIds) do
			if modelView.partModel:IsPartModelLoaded(slotId) then
				shaderView:ApplyPreset(slotId, "Default1")
			end
		end
	end)
end

function AvatarPreviewComponent:_resetHairCustomToDefault(entity)
	if not entity or not entity.eModel then
		return
	end

	local modelView = entity.eModel.modelModelView

	if not modelView or not modelView.modelInfo or not modelView.partModel then
		return
	end

	local hairSuitId = LuaUIUtils.tryGetEntityHairSuitId(entity)
	local hairSuitInfo = hairSuitId and AvatarHairSuitData[hairSuitId]

	if hairSuitInfo and avatarMgr.avatarHair then
		avatarMgr.avatarHair:SetAssetIdAndLoad(hairSuitInfo.assetId)
	end

	for partId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
		modelView.modelInfo:ParseHairCustomData(partId, "")
		modelView.modelInfo:ProcessHairCustomData(partId)

		if modelView.partModel:IsPartModelLoaded(partId) then
			modelView:ApplyHairCustomData(partId)
		end
	end

	if avatarMgr.avatarHair then
		local ok, err = xpcall(function()
			avatarMgr.avatarHair:InitColors()
		end, debug.traceback)

		if not ok then
			logger:warn("[CashShop] reset hair color failed: %s", tostring(err))
		end
	end
end

function AvatarPreviewComponent:_applyFacePreviewUndyedLook(entity)
	if not self._facePreviewUndyedMode or not entity or not entity.eModel then
		return
	end

	self:_resetClothesStainToDefault(entity)
	self:_resetHairCustomToDefault(entity)
end

function AvatarPreviewComponent:_installFacePreviewUndyedHook(entity)
	if not entity then
		return
	end

	self:_installCashShopClothStainBlocker()

	entity._cashShopFaceUndyedActive = true

	if not entity._cashShopOrigApplyPlayerClothStain and entity.applyPlayerClothStain then
		entity._cashShopOrigApplyPlayerClothStain = entity.applyPlayerClothStain

		local selfRef = self

		function entity.applyPlayerClothStain(ent)
			if not selfRef._facePreviewUndyedMode then
				return entity._cashShopOrigApplyPlayerClothStain(ent)
			end

			selfRef:_applyFacePreviewUndyedLook(ent)
		end
	end
end

function AvatarPreviewComponent:_uninstallFacePreviewUndyedHook(entity)
	if not entity then
		return
	end

	entity._cashShopFaceUndyedActive = nil

	if entity._cashShopOrigApplyPlayerClothStain then
		entity.applyPlayerClothStain = entity._cashShopOrigApplyPlayerClothStain
		entity._cashShopOrigApplyPlayerClothStain = nil
	end
end

function AvatarPreviewComponent:_ensureFacePreviewUndyedHook(entity)
	if not self._facePreviewUndyedMode or not entity then
		return
	end

	self:_installFacePreviewUndyedHook(entity)
	self:_applyFacePreviewUndyedLook(entity)
end

function AvatarPreviewComponent:registerGesture(maskTrans)
	if not self.avatarScene or not self.ctrl or not self.ctrl.uid then
		return
	end

	self._gestureMaskTrans = maskTrans

	local extraInfo = {
		maskRayBoxTrans = maskTrans,
		isModelRotationBlocked = function()
			return self:isModelRotationBlocked()
		end
	}

	self.avatarScene:registerGesture(self.ctrl.uid, extraInfo)
end

function AvatarPreviewComponent:unRegisterGesture()
	if not self.avatarScene or not self.ctrl or not self.ctrl.uid then
		return
	end

	self.avatarScene:unRegisterGesture(self.ctrl.uid)

	self._gestureMaskTrans = nil
end

function AvatarPreviewComponent:_setSuitPowerInteractionRotationBlocked(blocked)
	self._suitPowerInteractionRotationBlocked = blocked == true

	if not self._suitPowerInteractionRotationBlocked or not self.avatarScene then
		return
	end

	self.avatarScene.swipeStart = false

	if self.avatarScene.endPress then
		self.avatarScene:endPress()
	end

	if self._gestureMaskTrans and not IsNil(self._gestureMaskTrans) then
		self._gestureMaskTrans.localScale = Vector3.zero
	end
end

function AvatarPreviewComponent:setCameraZoomEnabled(enabled)
	if not self.view or IsNil(self.view.gameObject) then
		return
	end

	for _, bindingName in ipairs(CAMERA_ZOOM_BINDING_NAMES) do
		local binding = KeyBindingPro.GetKeyBindingByName(self.view.gameObject, bindingName)

		if binding then
			binding.enabled = enabled
		end
	end
end

function AvatarPreviewComponent:getAppearanceType(id)
	if AppearanceSuitData[id] then
		return APPEARANCE_TYPE.SUIT
	end

	if AvatarHairSuitData[id] then
		return APPEARANCE_TYPE.HAIR
	end

	if AppearanceMakeupPresetData[id] then
		return APPEARANCE_TYPE.MAKEUP
	end

	if AppearanceData[id] then
		return DATA_TYPE_TO_ENUM[AppearanceData[id].type]
	end

	return nil
end

function AvatarPreviewComponent:findMakeupReaction(originConfig, configId)
	for _, groupData in pairs(originConfig) do
		for _, reaction in ipairs(groupData.reactionList or EMPTY_TABLE) do
			if tonumber(reaction.configId) == configId then
				return groupData, reaction
			end
		end

		for _, kindData in pairs(groupData.kindList or EMPTY_TABLE) do
			for _, reaction in ipairs(kindData.reactionList or EMPTY_TABLE) do
				if tonumber(reaction.configId) == configId then
					return groupData, reaction
				end
			end
		end
	end

	return nil, nil
end

function AvatarPreviewComponent:equipMakeup(id)
	if not avatarMgr or not avatarMgr.avatarMakeup then
		return
	end

	local presetConfig = AppearanceMakeupPresetData[id]
	local makeupList = presetConfig and presetConfig.makeupList or {
		id
	}
	local makeupPresetKey = AvatarUtils.getCurrentPartAssetId(self.avatarScene, self.curPresetKey, "makeup")

	if not makeupPresetKey then
		return
	end

	local success, originConfig = pcall(require, string.format("Data.Avatar.makeup.makeup_%s_data", makeupPresetKey))

	if not success or not Utils.isTable(originConfig) then
		return
	end

	if presetConfig then
		avatarMgr.avatarMakeup:BeginMakeupSuitCommand()
		avatarMgr.avatarMakeup:ResetMakeupVisualStateBeforeImport()
	end

	for _, configId in ipairs(makeupList) do
		local groupData, reaction = self:findMakeupReaction(originConfig, tonumber(configId))

		if groupData and reaction then
			local isRatio = groupData.allowedMultiSelect ~= true

			if reaction.key_L and reaction.key_R then
				avatarMgr.avatarMakeup:SelectMakeup(reaction.key_L, true, isRatio)
				avatarMgr.avatarMakeup:SelectMakeup(reaction.key_R, true, isRatio)
			elseif reaction.key then
				avatarMgr.avatarMakeup:SelectMakeup(reaction.key, true, isRatio)
			end
		end
	end

	if presetConfig then
		avatarMgr.avatarMakeup:EndMakeupSuitCommand(id)
	end
end

function AvatarPreviewComponent:unEquipMakeup()
	self:_bindPlayerAvatarMgr()
end

function AvatarPreviewComponent:getSuitHideJewelryMap(suitData)
	local hideMap = {}

	if not suitData or not suitData.shopHideJewelryList then
		return hideMap
	end

	for _, appearanceId in ipairs(suitData.shopHideJewelryList) do
		hideMap[appearanceId] = true
	end

	return hideMap
end

function AvatarPreviewComponent:isSuitAppearanceHidden(hideMap, appearanceId)
	return appearanceId and hideMap and hideMap[appearanceId] == true
end

function AvatarPreviewComponent:_equipSuitJewelryList(entity, suitData, hideMap, isPreview)
	local usedSlots = {}

	for _, jewelryId in ipairs(suitData.shopJewelryList or EMPTY_TABLE) do
		if not self:isSuitAppearanceHidden(hideMap, jewelryId) then
			local data = AppearanceData[jewelryId]

			if data then
				local slotId = data.partId

				if not self:_isJewelrySlotAvailable(slotId, usedSlots) then
					slotId = nil

					for _, optionalSlotId in ipairs(data.optionalPoints or EMPTY_TABLE) do
						if self:_isJewelrySlotAvailable(optionalSlotId, usedSlots) then
							slotId = optionalSlotId

							break
						end
					end
				end

				if not slotId then
					for candidateSlotId = AppearancePointEnum.Jewelry1, AppearancePointEnum.Jewelry10 do
						if self:_isJewelrySlotAvailable(candidateSlotId, usedSlots) then
							slotId = candidateSlotId

							break
						end
					end
				end

				if slotId then
					usedSlots[slotId] = true

					if isPreview then
						entity:setCustomShowPreview(jewelryId, true, slotId)
					else
						entity:setCustomShow(jewelryId, true, slotId)
					end
				end
			end
		end
	end
end

function AvatarPreviewComponent:getPreviewAppearanceConfigId(entity, slotId, keepActualWhenPreviewMissing)
	local configId = entity:getAppearanceConfigId(slotId)
	local previewMap = entity.customShowPreview

	if not previewMap or not next(previewMap) then
		return configId
	end

	if previewMap[slotId] ~= nil then
		return previewMap[slotId]
	end

	if keepActualWhenPreviewMissing then
		return configId
	end

	return 0
end

function AvatarPreviewComponent:refreshAttachByServer(accessoryId, reactionKey)
	local lastInfos = pg.me and pg.me.jewelryLastInfos
	local lastInfoStr = lastInfos and lastInfos[accessoryId]

	if not accessoryId or not reactionKey or string.isNilOrEmpty(lastInfoStr) then
		return
	end

	local jewelryInfo = AppearanceJewelryInfo.new()

	jewelryInfo:toTable(accessoryId, lastInfoStr)

	local overrideResId = ""

	if jewelryInfo.colorJewelryId and jewelryInfo.colorJewelryId ~= 0 then
		local colorData = ColorJewelryData[jewelryInfo.colorJewelryId]

		if colorData then
			overrideResId = colorData.res
		end
	end

	avatarMgr.avatarMakeup:RefreshAttachByServer(reactionKey, jewelryInfo, overrideResId)
end

function AvatarPreviewComponent:previewEquip(id)
	local idType = self:getAppearanceType(id)

	if not idType then
		return
	end

	self._previewEquippedId = id

	if idType == APPEARANCE_TYPE.CLOTHES then
		self:equipClothes(id)
	elseif idType == APPEARANCE_TYPE.SUIT then
		self:equipSuit(id)
	elseif idType == APPEARANCE_TYPE.ACCESSORY then
		self:equipAccessory(id)
	elseif idType == APPEARANCE_TYPE.HAIR then
		self:equipHair(id)
	elseif idType == APPEARANCE_TYPE.MAKEUP then
		self:equipMakeup(id)
	end
end

function AvatarPreviewComponent:previewUnEquip(id)
	local idType = self:getAppearanceType(id)

	if not idType then
		return
	end

	if idType == APPEARANCE_TYPE.CLOTHES then
		self:unEquipClothes(id)
	elseif idType == APPEARANCE_TYPE.SUIT then
		self:unEquipSuit(id)
	elseif idType == APPEARANCE_TYPE.ACCESSORY then
		self:unEquipAccessory(id)
	elseif idType == APPEARANCE_TYPE.HAIR then
		self:unEquipHair()
	elseif idType == APPEARANCE_TYPE.MAKEUP then
		self:unEquipMakeup()
	end
end

function AvatarPreviewComponent:_clearPlayerPreview()
	if self:_isCurrentPetEntity() then
		self._previewEquippedId = nil

		local playerEntity = self.avatarScene:getEntity(self.curPresetKey)

		if not playerEntity or not playerEntity.cancelCustomShowPreview then
			return
		end

		for partId = AppearancePointEnum.Coat, AppearancePointEnum.Shoes do
			playerEntity:cancelCustomShowPreview(partId)
		end

		for partId = AppearancePointEnum.Jewelry1, AppearancePointEnum.Jewelry10 do
			playerEntity:cancelCustomShowPreview(partId)
		end

		for partId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
			playerEntity:cancelCustomShowPreview(partId)
		end

		return
	end

	if self._previewEquippedId then
		self:previewUnEquip(self._previewEquippedId)

		self._previewEquippedId = nil
	end

	local entity = self.avatarScene:getCurEntity()

	if not entity or not entity.cancelCustomShowPreview then
		return
	end

	for partId = AppearancePointEnum.Coat, AppearancePointEnum.Shoes do
		entity:cancelCustomShowPreview(partId)
	end

	for partId = AppearancePointEnum.Jewelry1, AppearancePointEnum.Jewelry10 do
		entity:cancelCustomShowPreview(partId)
	end

	for partId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
		entity:cancelCustomShowPreview(partId)
	end
end

function AvatarPreviewComponent:_getCurrentPetTemplateId()
	if not self.curPetId then
		return nil
	end

	local pInfo = pg.me:getPetInfo(self.curPetId)

	return pInfo and pInfo.templateId or nil
end

function AvatarPreviewComponent:_isCurrentPetEntity()
	local petTemplateId = self:_getCurrentPetTemplateId()

	return petTemplateId ~= nil and self.avatarScene:getCurEntityId() == petTemplateId
end

function AvatarPreviewComponent:_clearPetPreview()
	if self._petPreviewActive then
		self:clearPetAccessoryPreviewList()
	end
end

function AvatarPreviewComponent:clearPreviewState(mode)
	if not self.avatarScene then
		self._previewEquippedId = nil
		self.petAccessMap = {}
		self.petOriginalAccess = nil
		self.petOriginalAccessMap = {}
		self._petPreviewSlots = {}
		self._petPreviewActive = false

		return
	end

	mode = mode or "current"

	if mode == "all" then
		if self:_isCurrentPetEntity() then
			self:_clearPlayerPreview()
			self:_clearPetPreview()
		else
			self:_clearPetPreview()
			self:_clearPlayerPreview()
		end

		return
	end

	if mode == "pet" then
		self:_clearPetPreview()

		return
	end

	if mode == "player" then
		self:_clearPlayerPreview()

		return
	end

	if self:_isCurrentPetEntity() then
		self:_clearPetPreview()
	else
		self:_clearPlayerPreview()
	end
end

function AvatarPreviewComponent:clearAllPreview()
	self:clearPreviewState("current")
end

function AvatarPreviewComponent:commitPlayerAppearance(callback)
	local entity = self.avatarScene:getCurEntity()

	if not entity then
		return
	end

	for partId = AppearancePointEnum.Jewelry1, AppearancePointEnum.Jewelry10 do
		local previewId = self:getPreviewAppearanceConfigId(entity, partId, true)
		local actualId = entity:getAppearanceConfigId(partId)

		if previewId and previewId ~= actualId then
			if previewId == 0 then
				entity:cancelCustomShow(partId, true)
			else
				entity:setCustomShow(previewId, true, partId)
			end

			entity:cancelCustomShowPreview(partId)
		end
	end

	entity:syncToServer()

	if callback then
		callback()
	end
end

function AvatarPreviewComponent:equipClothes(clothesId)
	local entity = self.avatarScene:getCurEntity()
	local data = AppearanceData[clothesId]

	if not data then
		return
	end

	entity:setCustomShowPreview(clothesId, true)
	self:refreshClothes()
end

function AvatarPreviewComponent:unEquipClothes(clothesId)
	local entity = self.avatarScene:getCurEntity()
	local data = AppearanceData[clothesId] or {}

	if data.points then
		for _, point in ipairs(data.points) do
			entity:cancelCustomShowPreview(point)
		end
	end

	self:refreshClothes()
end

function AvatarPreviewComponent:refreshClothes()
	local entity = self.avatarScene:getCurEntity()
	local modelView = entity.eModel.modelModelView

	for partId = AppearancePointEnum.Coat, AppearancePointEnum.Shoes do
		local clothesId = self:getPreviewAppearanceConfigId(entity, partId, true)
		local data = AppearanceData[clothesId]

		ClientModelUtils.applyAppearancePart(entity, partId, clothesId, data and data.res)
	end

	ClientModelUtils.refreshModels(entity, modelView)

	if entity.applyPlayerHairCustomData and not self._facePreviewUndyedMode then
		entity:applyPlayerHairCustomData()
	end

	self:_ensureFacePreviewUndyedHook(entity)
end

function AvatarPreviewComponent:equipSuit(suitId)
	local entity = self.avatarScene:getCurEntity()
	local suitData = AppearanceSuitData[suitId]

	if not suitData then
		return
	end

	local hideMap = self:getSuitHideJewelryMap(suitData)

	for partId = AppearancePointEnum.Coat, AppearancePointEnum.Shoes do
		entity:cancelCustomShowPreview(partId, true)
	end

	for _, clothesId in ipairs(suitData.appearanceList or EMPTY_TABLE) do
		if not self:isSuitAppearanceHidden(hideMap, clothesId) then
			entity:setCustomShowPreview(clothesId, true)
		end
	end

	self:refreshClothes()

	if suitData.hair then
		if self:isSuitAppearanceHidden(hideMap, suitData.hair) then
			for partId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
				entity:cancelCustomShowPreview(partId, true)
			end

			self:refreshHair()
		else
			self:equipHair(suitData.hair)
		end
	end

	for partId = AppearancePointEnum.Jewelry1, AppearancePointEnum.Jewelry10 do
		entity:cancelCustomShowPreview(partId, true)
	end

	self:_equipSuitJewelryList(entity, suitData, hideMap, true)
	self:refreshAccessory()
end

function AvatarPreviewComponent:unEquipSuit(suitId)
	local entity = self.avatarScene:getCurEntity()
	local suitData = AppearanceSuitData[suitId]

	if not suitData then
		return
	end

	for partId = AppearancePointEnum.Coat, AppearancePointEnum.Shoes do
		entity:cancelCustomShowPreview(partId)
	end

	self:refreshClothes()

	if suitData.hair then
		for partId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
			entity:cancelCustomShowPreview(partId)
		end

		self:refreshHair()
	end

	for partId = AppearancePointEnum.Jewelry1, AppearancePointEnum.Jewelry10 do
		entity:cancelCustomShowPreview(partId)
	end

	self:refreshAccessory()
end

function AvatarPreviewComponent:equipAccessory(accessoryId, slotId)
	local entity = self.avatarScene:getCurEntity()
	local data = AppearanceData[accessoryId]

	if not data then
		return
	end

	slotId = slotId or self:_getAccessoryListSlot(data, {})

	if not slotId then
		return
	end

	entity:setCustomShowPreview(accessoryId, true, slotId)
	self:refreshAccessory()
end

function AvatarPreviewComponent:unEquipAccessory(accessoryId)
	local entity = self.avatarScene:getCurEntity()
	local data = AppearanceData[accessoryId]

	if not data then
		return
	end

	local slotId = data.partId or AppearancePointEnum.Jewelry1

	entity:cancelCustomShowPreview(slotId)
	self:refreshAccessory()
end

function AvatarPreviewComponent:refreshAccessory()
	local entity = self.avatarScene:getCurEntity()
	local modelView = entity.eModel.modelModelView

	modelView.modelInfo:RemoveAllAttach()

	local attachList = {}

	for partId = AppearancePointEnum.Jewelry1, AppearancePointEnum.Jewelry10 do
		local accessoryId = self:getPreviewAppearanceConfigId(entity, partId, true)
		local reactionKey = ClientModelUtils.selectAppearanceAccessory(entity, partId, accessoryId)

		if accessoryId and accessoryId ~= 0 then
			attachList[#attachList + 1] = {
				accessoryId = accessoryId,
				reactionKey = reactionKey
			}
		end
	end

	ClientModelUtils.refreshModels(entity, modelView)

	for _, attach in ipairs(attachList) do
		self:refreshAttachByServer(attach.accessoryId, attach.reactionKey)
	end

	if entity.applyPlayerHairCustomData and not self._facePreviewUndyedMode then
		entity:applyPlayerHairCustomData()
	end

	self:_ensureFacePreviewUndyedHook(entity)
end

function AvatarPreviewComponent:hidePlayerGiftAccessory(accessoryId)
	local entity = self.avatarScene and self.avatarScene:getCurEntity()

	if not entity or not accessoryId or not entity.eModel then
		return
	end

	local modelView = entity.eModel.modelModelView
	local reactionKey = ClientModelUtils.getAccessoryReactionKeyAndKindKey(accessoryId, modelView.modelInfo:GetMakeUpPartAssetId())
	local attachInfo = reactionKey and modelView.modelInfo:GetAttachModelInfo(reactionKey)

	if not attachInfo then
		return
	end

	for partId = AppearancePointEnum.Jewelry1, AppearancePointEnum.Jewelry10 do
		if entity.customShowPreview and entity.customShowPreview[partId] == accessoryId then
			entity:cancelCustomShowPreview(partId, true)
			AppearanceEffectUtils.setAppearance(entity, partId, nil)
		end
	end

	modelView:SetAttachVisibleByInstanceId(attachInfo.instanceId, false)

	if entity.refreshAppearanceAttachEffects then
		entity:refreshAppearanceAttachEffects()
	end

	if self.avatarScene and self.avatarScene.setPreviewEntityMirrorAttachVisible then
		self.avatarScene:setPreviewEntityMirrorAttachVisible(entity, attachInfo.instanceId, false)
	end
end

function AvatarPreviewComponent:_isJewelrySlotAvailable(slotId, usedSlots)
	if not slotId or slotId < AppearancePointEnum.Jewelry1 or slotId > AppearancePointEnum.Jewelry10 then
		return false
	end

	if LuaUIUtils.isAppearancePointHidden(slotId) then
		return false
	end

	return not usedSlots or not usedSlots[slotId]
end

function AvatarPreviewComponent:_getAccessoryListSlot(accessoryData, usedSlots)
	local slotId = accessoryData and accessoryData.partId

	if not self:_isJewelrySlotAvailable(slotId, usedSlots) then
		slotId = nil

		for _, optionalSlotId in ipairs(accessoryData and accessoryData.optionalPoints or {}) do
			if self:_isJewelrySlotAvailable(optionalSlotId, usedSlots) then
				slotId = optionalSlotId

				break
			end
		end
	end

	if not slotId then
		for candidateSlotId = AppearancePointEnum.Jewelry1, AppearancePointEnum.Jewelry10 do
			if self:_isJewelrySlotAvailable(candidateSlotId, usedSlots) then
				slotId = candidateSlotId

				break
			end
		end
	end

	return slotId
end

function AvatarPreviewComponent:applyPlayerAccessoryPreviewList(accessoryIds, isTemplate)
	local entity = self.avatarScene and self.avatarScene:getCurEntity()

	if not entity then
		return
	end

	for partId = AppearancePointEnum.Jewelry1, AppearancePointEnum.Jewelry10 do
		if isTemplate then
			entity:cancelCustomShow(partId, true)
		else
			entity:cancelCustomShowPreview(partId, true)
		end
	end

	local usedSlots = {}

	for _, accessoryId in ipairs(accessoryIds or {}) do
		local accessoryData = AppearanceData[accessoryId]

		if accessoryData and accessoryData.type == APPEARANCE_TYPE.ACCESSORY then
			local slotId = self:_getAccessoryListSlot(accessoryData, usedSlots)

			if slotId then
				usedSlots[slotId] = true

				if isTemplate then
					entity:setCustomShow(accessoryId, true, slotId)
				else
					entity:setCustomShowPreview(accessoryId, true, slotId)
				end
			end
		end
	end

	if isTemplate then
		self:refreshTemplateAccessory(entity)
	else
		self:refreshAccessory()
	end
end

function AvatarPreviewComponent:equipHair(hairId)
	AvatarUtils.equipHairSuit(self.curPresetKey, hairId, true)
end

function AvatarPreviewComponent:unEquipHair()
	local entity = self.avatarScene:getCurEntity()

	if not entity then
		return
	end

	for partId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
		entity:cancelCustomShowPreview(partId)
	end

	self:refreshHair()
end

function AvatarPreviewComponent:refreshHair()
	local entity = self.avatarScene:getCurEntity()
	local modelView = entity.eModel.modelModelView

	for partId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
		local configId = self:getPreviewAppearanceConfigId(entity, partId, true)
		local data = AppearanceData[configId]

		ClientModelUtils.applyAppearancePart(entity, partId, configId, data and data.res)
	end

	ClientModelUtils.refreshModels(entity, modelView)

	if entity.applyPlayerHairCustomData and not self._facePreviewUndyedMode then
		entity:applyPlayerHairCustomData()
	end

	self:_ensureFacePreviewUndyedHook(entity)
end

function AvatarPreviewComponent:_getSuitPowerPlayerEntity()
	if not self.avatarScene then
		return nil
	end

	local entity = self._lastPlayerPreviewEntityId and self.avatarScene:getEntity(self._lastPlayerPreviewEntityId) or nil

	if entity and entity.setFashionSwitchEffectResIds then
		return entity
	end

	entity = self.avatarScene:getCurEntity()

	if entity and entity.setFashionSwitchEffectResIds then
		return entity
	end

	entity = self.templatePresetKey and self.avatarScene:getEntity(self.templatePresetKey) or nil

	if entity and entity.setFashionSwitchEffectResIds then
		return entity
	end

	entity = self.curPresetKey and self.avatarScene:getEntity(self.curPresetKey) or nil

	if entity and entity.setFashionSwitchEffectResIds then
		return entity
	end

	return nil
end

function AvatarPreviewComponent:getSuitPowerPetTemplateId(functionData)
	if not functionData or not Utils.isTable(functionData.petId) then
		return nil
	end

	for _, petTemplateId in ipairs(functionData.petId) do
		petTemplateId = tonumber(petTemplateId)

		if petTemplateId and PetData[petTemplateId] then
			return petTemplateId
		end
	end

	return nil
end

function AvatarPreviewComponent:clearSuitPowerPreviewState()
	self._suitPowerPreviewVersion = (self._suitPowerPreviewVersion or 0) + 1

	self:_setSuitPowerInteractionRotationBlocked(false)

	if not self.avatarScene then
		return
	end

	if self._suitPowerInteractionManager and self._suitPowerInteractionSession then
		self._suitPowerInteractionManager:CancelInteraction(self._suitPowerInteractionSession)
	end

	self._suitPowerInteractionManager = nil
	self._suitPowerInteractionSession = nil
	self._suitPowerPendingInteraction = nil

	local effectEntity = self._suitPowerEffectEntityId and self.avatarScene:getEntity(self._suitPowerEffectEntityId) or nil

	if effectEntity then
		local stoppedByKey = false

		if self._suitPowerEffectKey and effectEntity.stopEffect then
			effectEntity:stopEffect(self._suitPowerEffectKey, true)

			stoppedByKey = true
		end

		if self._suitPowerEffectRawKey and self._suitPowerEffectRawKey ~= self._suitPowerEffectKey and effectEntity.stopEffect then
			effectEntity:stopEffect(self._suitPowerEffectRawKey, true)

			stoppedByKey = true
		end

		if not stoppedByKey and self._suitPowerEffectId and self._suitPowerEffectId ~= 0 and effectEntity.stopEffectById then
			effectEntity:stopEffectById(self._suitPowerEffectId)
		end
	end

	self._suitPowerEffectEntityId = nil
	self._suitPowerEffectId = nil
	self._suitPowerEffectKey = nil
	self._suitPowerEffectRawKey = nil

	local idleEntity = self._suitPowerIdleEntityId and self.avatarScene:getEntity(self._suitPowerIdleEntityId) or nil

	if idleEntity and idleEntity.eModel and idleEntity.hasEModelComponent and idleEntity:hasEModelComponent(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER) then
		idleEntity.eModel:SetOverrideIdleSpecial(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, 0)
	end

	self._suitPowerIdleEntityId = nil

	self:_stopSuitPowerInteraction(self._suitPowerInteractionContext)

	self._suitPowerInteractionContext = nil

	self.avatarScene:removeEntity(AvatarPreviewComponent.SUIT_POWER_INTERACTION_PET_ENTITY_ID)

	self._suitPowerInteractionPetTemplateId = nil

	local playerEntity = self:_getSuitPowerPlayerEntity()

	if playerEntity then
		playerEntity:setFashionSwitchEffectResIds(nil, nil)
	end
end

function AvatarPreviewComponent:_getSuitPowerRawEffectResId(effectResId)
	local resId = effectResId

	if string.sub(resId, 1, 1) ~= "$" then
		resId = "$" .. resId
	end

	if string.sub(resId, -7) ~= ".prefab" then
		resId = resId .. ".prefab"
	end

	return resId
end

function AvatarPreviewComponent:previewFashionSwitchEffect(functionData, isPetTarget)
	if not functionData or not self.avatarScene then
		return false
	end

	self:clearSuitPowerPreviewState()

	local playerEntity = self:_getSuitPowerPlayerEntity()

	if playerEntity then
		playerEntity:setFashionSwitchEffectResIds(functionData.petEffId, functionData.roleEffId)
	end

	local targetEntity = self.avatarScene:getCurEntity()
	local effectResId = isPetTarget and functionData.petEffId or functionData.roleEffId

	if not targetEntity or not targetEntity.playEffect or not effectResId or effectResId == "" then
		return false
	end

	local rawEffectResId = self:_getSuitPowerRawEffectResId(effectResId)

	if targetEntity.stopEffect then
		targetEntity:stopEffect(effectResId, true)

		if rawEffectResId ~= effectResId then
			targetEntity:stopEffect(rawEffectResId, true)
		end
	end

	local effectId = targetEntity:playEffect(effectResId)
	local effectKey = effectResId

	if (not effectId or effectId == 0) and targetEntity.playEffectRaw then
		effectKey = rawEffectResId
		effectId = targetEntity:playEffectRaw(effectKey, {
			mountType = EffectConst.MountType.Entity
		})
	end

	if not effectId or effectId == 0 then
		return false
	end

	self._suitPowerEffectEntityId = targetEntity.id
	self._suitPowerEffectId = effectId
	self._suitPowerEffectKey = effectKey
	self._suitPowerEffectRawKey = rawEffectResId

	return true
end

function AvatarPreviewComponent:previewPetIdle(functionData)
	if not functionData or not self.avatarScene or not functionData.petState or functionData.petState == "" then
		return false
	end

	local petEntity = self.avatarScene:getCurEntity()

	if not petEntity or not petEntity.isPet or not petEntity:isPet() then
		return false
	end

	if not petEntity:hasEModelComponent(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER) then
		petEntity:addEModelComponent(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER)
	end

	if not petEntity:hasEModelComponent(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER) then
		return false
	end

	self._suitPowerPreviewVersion = (self._suitPowerPreviewVersion or 0) + 1

	local previewVersion = self._suitPowerPreviewVersion

	self._suitPowerIdleEntityId = petEntity.id

	self.avatarScene:runWhenAnimatorReady(petEntity, function()
		if previewVersion ~= self._suitPowerPreviewVersion or self.avatarScene:getCurEntity() ~= petEntity then
			return
		end

		local stateKey = Animator.StringToHash(functionData.petState)

		petEntity.eModel:SetOverrideIdleSpecial(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, stateKey)
		petEntity:playAnimation(functionData.petState)
	end)

	return true
end

function AvatarPreviewComponent:previewPlayerPetInteraction(functionData, waitPlayerModelLoaded)
	if not functionData or not self.avatarScene then
		return false
	end

	local actionId = Utils.isTable(functionData.action) and tonumber(functionData.action[1]) or nil
	local actionData = actionId and AppearanceActionData[actionId] or nil

	if not actionData or not Utils.isTable(actionData.res1) or not Utils.isTable(actionData.res2) or string.isNilOrEmpty(actionData.res1[1]) or string.isNilOrEmpty(actionData.res2[1]) then
		return false
	end

	local playerAnimationKey = self:_getSuitPowerInteractionAnimationKey(actionData.res1, 1)
	local petAnimationKey = self:_getSuitPowerInteractionAnimationKey(actionData.res2, 1)

	if playerAnimationKey == 0 or petAnimationKey == 0 then
		return false
	end

	local petTemplateId = self:getSuitPowerPetTemplateId(functionData)

	if not petTemplateId then
		return false
	end

	local playerEntity = self:_getSuitPowerPlayerEntity()

	if not playerEntity then
		return false
	end

	self:clearSuitPowerPreviewState()

	local previewVersion = self._suitPowerPreviewVersion
	local petEntity = self:_createSuitPowerInteractionPet(petTemplateId)

	if not petEntity then
		return false
	end

	local pendingInteraction = {
		playerReady = false,
		petReady = false,
		previewVersion = previewVersion,
		actionData = actionData,
		playerEntity = playerEntity,
		petEntity = petEntity,
		playerAnimationKey = playerAnimationKey,
		petAnimationKey = petAnimationKey
	}

	self._suitPowerPendingInteraction = pendingInteraction

	if waitPlayerModelLoaded then
		self:_waitSuitPowerInteractionPlayerReady(playerEntity, pendingInteraction)
	else
		self:_markSuitPowerInteractionEntityReady(playerEntity, pendingInteraction, "playerReady")
	end

	self:_waitSuitPowerInteractionPetReady(petEntity, pendingInteraction)

	return true
end

function AvatarPreviewComponent:_createSuitPowerInteractionPet(petTemplateId)
	local entityId = AvatarPreviewComponent.SUIT_POWER_INTERACTION_PET_ENTITY_ID
	local petEntity = self.avatarScene:getEntity(entityId)

	if petEntity and self._suitPowerInteractionPetTemplateId ~= petTemplateId then
		self.avatarScene:removeEntity(entityId)

		petEntity = nil
	end

	self._suitPowerInteractionPetTemplateId = petTemplateId

	if not petEntity then
		petEntity = self.avatarScene:createEntity(entityId, ClientSimpleVirtualPet, {
			templateId = petTemplateId
		})

		petEntity:setConfigData(PetData[petTemplateId])
		petEntity.eModel:SetTransformParent(self.avatarScene.entityRootTransform, false)
		petEntity:setScaleNumber(PetData[petTemplateId].scale or 1)
		petEntity:setDisableEffectLod(true)

		petEntity.eModel.enableCameraHitCheck = false
	end

	self.avatarScene:showEntityWithId(entityId)

	return petEntity
end

function AvatarPreviewComponent:_markSuitPowerInteractionEntityReady(entity, pendingInteraction, readyField)
	self.avatarScene:runWhenAnimatorReady(entity, function()
		if self._suitPowerPendingInteraction ~= pendingInteraction then
			return
		end

		pendingInteraction[readyField] = true

		self:_tryStartSuitPowerInteraction(pendingInteraction)
	end)
end

function AvatarPreviewComponent:_waitSuitPowerInteractionPlayerReady(playerEntity, pendingInteraction)
	if self._suitPowerPendingInteraction ~= pendingInteraction then
		return
	end

	local modelPartModelAllLoaded = playerEntity.modelPartModelAllLoaded

	function playerEntity.modelPartModelAllLoaded()
		playerEntity.modelPartModelAllLoaded = modelPartModelAllLoaded

		if modelPartModelAllLoaded then
			modelPartModelAllLoaded()
		end

		if self._suitPowerPendingInteraction ~= pendingInteraction then
			return
		end

		self:_markSuitPowerInteractionEntityReady(playerEntity, pendingInteraction, "playerReady")
	end
end

function AvatarPreviewComponent:_waitSuitPowerInteractionPetReady(petEntity, pendingInteraction)
	if self._suitPowerPendingInteraction ~= pendingInteraction then
		return
	end

	if petEntity.isModelLoaded then
		self:_markSuitPowerInteractionEntityReady(petEntity, pendingInteraction, "petReady")

		return
	end

	function petEntity.modelLoadedCallback()
		petEntity.modelLoadedCallback = nil

		if self._suitPowerPendingInteraction ~= pendingInteraction then
			return
		end

		self:_markSuitPowerInteractionEntityReady(petEntity, pendingInteraction, "petReady")
	end
end

function AvatarPreviewComponent:_tryStartSuitPowerInteraction(pendingInteraction)
	if self._suitPowerPendingInteraction ~= pendingInteraction or not pendingInteraction.playerReady or not pendingInteraction.petReady then
		return false
	end

	local playerEntity = pendingInteraction.playerEntity
	local petEntity = pendingInteraction.petEntity

	if pendingInteraction.previewVersion ~= self._suitPowerPreviewVersion or self.avatarScene:getCurEntity() ~= playerEntity or self.avatarScene:getEntity(AvatarPreviewComponent.SUIT_POWER_INTERACTION_PET_ENTITY_ID) ~= petEntity then
		return false
	end

	self._suitPowerPendingInteraction = nil

	return self:_startSuitPowerInteraction(pendingInteraction.actionData, playerEntity, petEntity)
end

function AvatarPreviewComponent:_getSuitPowerInteractionAnimationKey(animationNames, index)
	local animationName = Utils.isTable(animationNames) and animationNames[index] or nil

	if not animationName or animationName == "" then
		return 0
	end

	return PlayableConst[animationName] or Animator.StringToHash(animationName)
end

function AvatarPreviewComponent:_getSuitPowerInteractionPosRot(actionData, index)
	local defaultPosRot = SUIT_POWER_INTERACTION_DEFAULT_POS_ROT[index]
	local configPosRot = actionData and Utils.isTable(actionData.posRot) and actionData.posRot[index] or nil
	local configPosition = Utils.isTable(configPosRot) and configPosRot[1] or nil
	local configRotation = Utils.isTable(configPosRot) and configPosRot[2] or nil
	local defaultPosition = defaultPosRot[1]
	local defaultRotation = defaultPosRot[2]

	return {
		tonumber(Utils.isTable(configPosition) and configPosition[1]) or defaultPosition[1],
		tonumber(Utils.isTable(configPosition) and configPosition[2]) or defaultPosition[2],
		tonumber(Utils.isTable(configPosition) and configPosition[3]) or defaultPosition[3]
	}, {
		tonumber(Utils.isTable(configRotation) and configRotation[1]) or defaultRotation[1],
		tonumber(Utils.isTable(configRotation) and configRotation[2]) or defaultRotation[2],
		tonumber(Utils.isTable(configRotation) and configRotation[3]) or defaultRotation[3]
	}
end

function AvatarPreviewComponent:_setSuitPowerInteractionPosRot(entity, position, rotation)
	if not entity or IsNil(entity.eModel) then
		return
	end

	entity.eModel:SetTransformLocalPosition(position[1], position[2], position[3])
	entity.eModel:SetTransformLocalEulerAngle(rotation[1], rotation[2], rotation[3])
end

function AvatarPreviewComponent:_getSuitPowerInteractionTransform(entity)
	if not entity or IsNil(entity.eModel) then
		return nil
	end

	local positionX, positionY, positionZ = entity.eModel:GetTransformLocalPosition()
	local rotationX, rotationY, rotationZ = entity.eModel:GetTransformLocalRotationEulerAngles()

	return {
		position = {
			positionX,
			positionY,
			positionZ
		},
		rotation = {
			rotationX,
			rotationY,
			rotationZ
		}
	}
end

function AvatarPreviewComponent:_stopSuitPowerInteraction(context)
	if not context then
		return
	end

	local playerEntity = context.playerEntity
	local petEntity = context.petEntity

	if playerEntity and context.playerAnimationLayer ~= nil then
		playerEntity:stopLayerAnimation(context.playerAnimationLayer, 0)
	elseif playerEntity and context.playerAnimationKey then
		playerEntity:stopAnimation(context.playerAnimationKey, 0)
	end

	if petEntity and context.petAnimationLayer ~= nil then
		petEntity:stopLayerAnimation(context.petAnimationLayer, 0)
	elseif petEntity and context.petAnimationKey then
		petEntity:stopAnimation(context.petAnimationKey, 0)
	end

	local playerTransform = context.playerTransform

	if playerTransform then
		self:_setSuitPowerInteractionPosRot(playerEntity, playerTransform.position, playerTransform.rotation)
	end

	if playerEntity and self.avatarScene:getCurEntity() == playerEntity then
		self:restoreShopPreviewAnimation(playerEntity)
	end
end

function AvatarPreviewComponent:restoreShopPreviewAnimation(entity)
	if not entity then
		return
	end

	if self._shopPreviewAnimationKey then
		self:_playShopAnimation(entity, self._shopPreviewAnimationKey)

		return
	end

	self.avatarScene:playIdleAnimation(entity, 0)
end

function AvatarPreviewComponent:_startSuitPowerInteraction(actionData, playerEntity, petEntity)
	local selfAnimationKey = self:_getSuitPowerInteractionAnimationKey(actionData.res1, 1)
	local petAnimationKey = self:_getSuitPowerInteractionAnimationKey(actionData.res2, 1)

	if selfAnimationKey == 0 or petAnimationKey == 0 then
		return false
	end

	local selfAnimationLoopKey = self:_getSuitPowerInteractionAnimationKey(actionData.res1, 2)
	local petAnimationLoopKey = self:_getSuitPowerInteractionAnimationKey(actionData.res2, 2)

	if selfAnimationLoopKey == 0 then
		selfAnimationLoopKey = selfAnimationKey
	end

	if petAnimationLoopKey == 0 then
		petAnimationLoopKey = petAnimationKey
	end

	local interactionManager = appFacade and appFacade.interactionAnimationManager or nil

	if not interactionManager then
		return false
	end

	local animParams = Utils.isTable(actionData.animParams) and actionData.animParams or nil
	local baseParams = animParams and animParams[1] or nil
	local interactionType = actionData.objectType == 1 and 3 or 2

	interactionType = Utils.isTable(baseParams) and tonumber(baseParams[1]) or interactionType

	local playerPosition, playerRotation = self:_getSuitPowerInteractionPosRot(actionData, 1)
	local petPosition, petRotation = self:_getSuitPowerInteractionPosRot(actionData, 2)
	local session = interactionManager:AcquireSetupSession(interactionType)

	if not session then
		return false
	end

	local playerTransform = self:_getSuitPowerInteractionTransform(playerEntity)

	if not playerTransform then
		interactionManager:CancelInteraction(session)

		return false
	end

	self:_setSuitPowerInteractionPosRot(playerEntity, playerPosition, playerRotation)
	self:_setSuitPowerInteractionPosRot(petEntity, petPosition, petRotation)

	local interactionContext = {
		playerEntity = playerEntity,
		petEntity = petEntity,
		playerTransform = playerTransform,
		playerAnimationKey = selfAnimationKey,
		petAnimationKey = petAnimationKey,
		playerAnimationLayer = playerEntity:getPlayableStateConfigLayer(selfAnimationKey),
		petAnimationLayer = petEntity:getPlayableStateConfigLayer(petAnimationKey)
	}

	session.self = playerEntity.eModel
	session.target = petEntity.eModel
	session.selfAnimKey = selfAnimationKey
	session.selfAnimLoopKey = selfAnimationLoopKey
	session.targetAnimKey = petAnimationKey
	session.targetAnimLoopKey = petAnimationLoopKey
	session.anchorWidth = Utils.isTable(baseParams) and tonumber(baseParams[2]) or 0
	session.anchorLength = Utils.isTable(baseParams) and tonumber(baseParams[3]) or 0
	session.selfPosX = playerPosition[1]
	session.selfPosZ = playerPosition[3]
	session.selfYaw = playerRotation[2]
	session.targetPosX = petPosition[1]
	session.targetPosZ = petPosition[3]
	session.targetYaw = petRotation[2]

	interactionManager:SetupWorldSpaceConfig(session)

	if interactionManager:StartInteraction(session) then
		self:_setSuitPowerInteractionRotationBlocked(true)

		self._suitPowerInteractionContext = interactionContext
		self._suitPowerInteractionManager = interactionManager
		self._suitPowerInteractionSession = session

		return true
	end

	interactionManager:CancelInteraction(session)
	self:_stopSuitPowerInteraction(interactionContext)

	return false
end

function AvatarPreviewComponent:_isPlayerMirrorEntity(entity)
	return entity and entity.copyEntity ~= nil
end

function AvatarPreviewComponent:_preparePlayerMirrorEntity()
	local presetKey = self.curPresetKey
	local entity = self.avatarScene:getEntity(presetKey)

	if entity and not self:_isPlayerMirrorEntity(entity) then
		self.avatarScene:removeEntity(presetKey)

		if self.templatePresetKey == presetKey then
			self.templatePresetKey = nil
		end
	end
end

function AvatarPreviewComponent:_prepareTemplateEntity(presetKey)
	local entity = self.avatarScene:getEntity(presetKey)

	if entity and self:_isPlayerMirrorEntity(entity) then
		self.avatarScene:removeEntity(presetKey)
	end
end

function AvatarPreviewComponent:hideAllEntities(keepEntityId)
	self:clearSuitPowerPreviewState()

	if self.avatarScene and self.avatarScene.hideFurnitureModel then
		self.avatarScene:hideFurnitureModel()
	end

	if self.curPresetKey ~= keepEntityId then
		self.avatarScene:hideEntityWithId(self.curPresetKey)
	end

	if self.curPetId then
		local pInfo = pg.me:getPetInfo(self.curPetId)

		if pInfo and pInfo.templateId ~= keepEntityId then
			self.avatarScene:hideEntityWithId(pInfo.templateId)
		end
	end

	if self.templatePresetKey and self.templatePresetKey ~= keepEntityId then
		self.avatarScene:hideEntityWithId(self.templatePresetKey)
	end

	if self._modelingPetTemplateId and self._modelingPetTemplateId ~= keepEntityId then
		self:_cancelModelingPetLoadTimeout()

		self._modelingPetLoadToken = (self._modelingPetLoadToken or 0) + 1

		local modelingPetEntity = self.avatarScene:getEntity(self._modelingPetTemplateId)

		if modelingPetEntity then
			modelingPetEntity.modelLoadedCallback = nil
		end

		if modelingPetEntity and not modelingPetEntity.isModelLoaded then
			self.avatarScene:removeEntity(self._modelingPetTemplateId)
		else
			self.avatarScene:hideEntityWithId(self._modelingPetTemplateId)
		end

		self._modelingPetTemplateId = nil
	end
end

function AvatarPreviewComponent:_cancelModelingPetLoadTimeout()
	if not self._modelingPetLoadTimerId then
		return
	end

	self:killTimer(self._modelingPetLoadTimerId)

	self._modelingPetLoadTimerId = nil
end

function AvatarPreviewComponent:_startModelingPetLoadTimeout(modelingId, entity, loadToken)
	self:_cancelModelingPetLoadTimeout()

	self._modelingPetLoadTimerId = self:startTimer(function()
		if self._modelingPetLoadToken ~= loadToken or self._modelingPetTemplateId ~= modelingId or not self.avatarScene then
			return
		end

		self._modelingPetLoadTimerId = nil

		if entity and entity.isModelLoaded then
			return
		end

		logger:error("CashShop modeling pet load timeout, modelingId=%s", tostring(modelingId))

		if entity then
			entity.modelLoadedCallback = nil
		end

		if self.avatarScene:getEntity(modelingId) == entity then
			self.avatarScene:removeEntity(modelingId)
		end

		self._modelingPetTemplateId = nil
	end, MODELING_PET_LOAD_TIMEOUT_SECONDS)
end

function AvatarPreviewComponent:showFurniture(furnitureItemId)
	local furnitureConfig = furnitureItemId and HomeObjectData[furnitureItemId]

	if not furnitureConfig or not self.avatarScene or not self.avatarScene.showFurnitureModel then
		return false
	end

	local previewData = ClientHomelandUtils.getPreviewDataByConfig(furnitureConfig, furnitureConfig.prefabResID)

	if not previewData then
		return false
	end

	self:setCameraZoomEnabled(true)
	self:hideAllEntities()

	return self.avatarScene:showFurnitureModel(previewData)
end

function AvatarPreviewComponent:showPlayer(animKey, cb)
	self._shopPreviewAnimationKey = animKey

	self:setCameraZoomEnabled(true)
	self:hideAllEntities()
	self:_preparePlayerMirrorEntity()

	self._lastPlayerPreviewEntityId = self.curPresetKey

	self.avatarScene:showAvatar(self.curPresetKey, function()
		self:_bindPlayerAvatarMgr()

		if cb then
			cb()
		end

		if animKey then
			self:_playShopAnimation(self.avatarScene:getCurEntity(), animKey)
		end

		self:_ensureFacePreviewUndyedHook(self.avatarScene:getCurEntity())
	end)
	self:setCameraModeFar()
end

function AvatarPreviewComponent:setCameraModeFar()
	if self.avatarScene.curCameraMode then
		self.avatarScene:setAvatarCameraModeFar()
	end
end

function AvatarPreviewComponent:showPlayerWithPreview(itemId, animKey, onLoaded)
	if itemId then
		local replacedTable = ItemUtils.getReplacedItemCountTable(pg.me, {
			[itemId] = 1
		})

		if replacedTable then
			local newId = next(replacedTable) or itemId

			itemId = newId
		end
	end

	self:showPlayer(animKey, function()
		if itemId then
			self:clearAllPreview()
			self:previewEquip(itemId)
		end

		if onLoaded then
			onLoaded()
		end
	end)
end

function AvatarPreviewComponent:showPet(petId, onLoaded)
	petId = petId or self.curPetId or pg.me:getFirstOrDefaultPetId()

	if not petId then
		return
	end

	local pInfo = pg.me:getPetInfo(petId)

	if not pInfo then
		return
	end

	self:setCameraZoomEnabled(true)
	self:hideAllEntities()

	if self.curPetId then
		local oldPInfo = pg.me:getPetInfo(self.curPetId)

		if oldPInfo and oldPInfo.templateId ~= pInfo.templateId then
			self.petAccessMap = {}
			self.petOriginalAccess = nil
			self.petOriginalAccessMap = {}
			self._petPreviewSlots = {}
			self._petPreviewActive = false

			self.avatarScene:destroyPet(oldPInfo.templateId)
		end
	end

	self.curPetId = petId

	local petBaseData = PetData[pInfo.templateId] or {}
	local scale = petBaseData.scale or 1
	local offset = petBaseData.offset or Vector3.zero

	self.avatarScene:showPetTemplate(pInfo, scale, offset)

	if onLoaded then
		local entity = self.avatarScene:getEntity(pInfo.templateId)

		if entity and entity.modelLoadedCallback then
			local modelLoadedCallback = entity.modelLoadedCallback

			function entity.modelLoadedCallback()
				modelLoadedCallback()
				onLoaded()
			end
		else
			onLoaded()
		end
	end
end

function AvatarPreviewComponent:openPetBox()
	pg.global.ui:open(UIConst.UI_ID_ACCESS_PET_BOX, {
		curPetId = self.curPetId,
		sceneType = self.sceneType,
		selectCallback = function(petId)
			self:showPet(petId)
		end
	})
end

function AvatarPreviewComponent:_bindTemplateAvatarMgr(presetKey, entity, initParts)
	if not presetKey or not entity or not entity.eModel then
		return
	end

	local presetData = pg.game.avatar:getAvatarPresetData(presetKey)

	if not presetData then
		return
	end

	avatarMgr:InitWorkSpace(presetKey, presetData.templateId, GlobalData.UserName)
	avatarMgr:SetAvatarInstance(entity.eModel)

	if initParts then
		avatarMgr:InitAvatarPart()

		if entity.refreshAppearance then
			entity:refreshAppearance()
		end

		avatarMgr:SetAvatarInstance(entity.eModel)
		avatarMgr:InitAvatarPart()
	end
end

function AvatarPreviewComponent:_syncPlayerHairColors(entity)
	if self._facePreviewUndyedMode then
		self:_applyFacePreviewUndyedLook(entity)

		return
	end

	if not entity or not entity.curShow then
		return
	end

	local hairSuitId = LuaUIUtils.tryGetEntityHairSuitId(pg.me)
	local hairSuitInfo = AvatarHairSuitData[hairSuitId]

	if hairSuitInfo and avatarMgr.avatarHair then
		avatarMgr.avatarHair:SetAssetIdAndLoad(hairSuitInfo.assetId)
		avatarMgr.avatarHair:InitColors()
	end

	for partId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
		ClientModelUtils.applyHairCustomData(entity, entity.curShow, partId)
	end
end

function AvatarPreviewComponent:_bindPlayerAvatarMgr()
	local presetKey = self.curPresetKey
	local entity = self.avatarScene:getEntity(presetKey)

	if not entity or not entity.eModel then
		return
	end

	local presetData = pg.game.avatar:getAvatarPresetData(presetKey)

	if not presetData then
		return
	end

	avatarMgr:InitWorkSpace(presetKey, presetData.templateId, GlobalData.UserName)
	avatarMgr:SetAvatarInstance(entity.eModel)
	avatarMgr:InitAvatarPart()
	self:_syncPlayerHairColors(entity)

	if entity.refreshAppearance then
		entity:refreshAppearance()
	end

	avatarMgr:SetAvatarInstance(entity.eModel)
	avatarMgr:InitAvatarPart()
	self:_syncPlayerHairColors(entity)

	pg.game.avatar.eyeNormalFixEntity = entity

	self:_ensureFacePreviewUndyedHook(entity)
end

function AvatarPreviewComponent:_setTemplateAvatarLoadRequest(entity, animKey, onLoaded)
	entity._cashShopTemplateAnimKey = animKey
	entity._cashShopTemplateOnLoaded = onLoaded
end

function AvatarPreviewComponent:_playShopAnimation(entity, animKey)
	if not entity or not animKey then
		return
	end

	self._shopPreviewAnimationKey = animKey

	entity:playAnimation(animKey, true, nil, true, PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY)
end

function AvatarPreviewComponent:_completeTemplateAvatarLoad(entity)
	local animKey = entity._cashShopTemplateAnimKey
	local onLoaded = entity._cashShopTemplateOnLoaded

	entity._cashShopTemplateAnimKey = nil
	entity._cashShopTemplateOnLoaded = nil

	if animKey then
		self:_playShopAnimation(entity, animKey)
	else
		self.avatarScene:playIdleAnimation(entity)
	end

	if onLoaded then
		onLoaded()
	end
end

function AvatarPreviewComponent:showTemplateAvatar(presetKey, animKey, onLoaded)
	if not presetKey or not pg.game.avatar:getAvatarPresetData(presetKey) then
		return
	end

	self._shopPreviewAnimationKey = animKey

	local reusableEntity

	if self.templatePresetKey == presetKey or not self.templatePresetKey then
		local entity = self.avatarScene:getEntity(presetKey)

		if entity and not self:_isPlayerMirrorEntity(entity) then
			reusableEntity = entity
		end
	end

	local isCurrentTemplate = reusableEntity ~= nil and self.avatarScene:getCurEntityId() == presetKey

	self:setCameraZoomEnabled(true)
	self:hideAllEntities(reusableEntity and presetKey or nil)

	self._lastPlayerPreviewEntityId = presetKey

	if reusableEntity then
		self.templatePresetKey = presetKey
		self.avatarScene.curEntityId = presetKey

		self.avatarScene:showEntityWithId(presetKey)
		self.avatarScene:setAvatarCameraModeFar()
		self.avatarScene:switchLight()

		if reusableEntity.modelPartModelAllLoaded then
			self:_setTemplateAvatarLoadRequest(reusableEntity, animKey, onLoaded)

			return
		end

		self:_bindTemplateAvatarMgr(presetKey, reusableEntity, not isCurrentTemplate)
		self:_ensureFacePreviewUndyedHook(reusableEntity)

		if animKey then
			self:_playShopAnimation(reusableEntity, animKey)
		end

		if onLoaded then
			onLoaded()
		end

		return
	end

	self:_prepareTemplateEntity(presetKey)

	if self.templatePresetKey then
		self.avatarScene:removeEntity(self.templatePresetKey)
	end

	self.templatePresetKey = presetKey

	local templateId = pg.game.avatar:getAvatarPresetData(presetKey).templateId

	avatarMgr:InitWorkSpace(presetKey, templateId, GlobalData.UserName)

	local initDict = {
		needFacialHighLight = true,
		useDefaultParts = true,
		templateId = templateId,
		avatarPresetKey = presetKey
	}
	local entity = self.avatarScene:createEntity(presetKey, ClientSimpleVirtualPlayer, initDict)

	entity.curShow = {}
	entity.curShow.customShow = setmetatable({}, {
		__newindex = function(t, key, value)
			rawset(t, key, value)
		end
	})

	entity.eModel:SetTransformParent(self.avatarScene.entityRootTransform, false)

	entity.eModel.enableCameraHitCheck = false

	entity:setDisableEffectLod(true)
	avatarMgr:SetAvatarInstance(entity.eModel)
	self:_setTemplateAvatarLoadRequest(entity, animKey, onLoaded)

	function entity.modelPartModelAllLoaded()
		entity.modelPartModelAllLoaded = nil

		if not self.avatarScene or self.templatePresetKey ~= presetKey or self.avatarScene:getEntity(presetKey) ~= entity then
			entity._cashShopTemplateAnimKey = nil
			entity._cashShopTemplateOnLoaded = nil

			return
		end

		self:_bindTemplateAvatarMgr(presetKey, entity, true)
		self:_ensureFacePreviewUndyedHook(entity)
		self.avatarScene:enableCameraMode(self.avatarScene.CAMERA.SIMPLE)
		self:_completeTemplateAvatarLoad(entity)
	end

	self.avatarScene.curEntityId = presetKey

	self:setCameraModeFar()
	self.avatarScene:switchLight()
end

function AvatarPreviewComponent:showPetByModelingId(modelingId, animKey, posXYZ, rotXYZ, scaleXYZ, onLoaded, petConfigData)
	local petBaseData = petConfigData or PetData[modelingId]

	if not modelingId or not petBaseData then
		return nil
	end

	self:setCameraZoomEnabled(false)
	self:hideAllEntities()

	self._modelingPetTemplateId = modelingId
	self._modelingPetLoadToken = (self._modelingPetLoadToken or 0) + 1

	local loadToken = self._modelingPetLoadToken
	local scale = petBaseData.scale or 1
	local offset = petBaseData.offset or Vector3.zero
	local fakeInfo = {
		templateId = modelingId,
		configData = petBaseData
	}

	self.avatarScene:showPetTemplate(fakeInfo, scale, offset)

	local entity = self.avatarScene:getEntity(modelingId)

	if not entity then
		logger:error("CashShop modeling pet entity create failed, modelingId=%s", tostring(modelingId))

		return nil
	end

	local originalTransform = self:getModelingPetTransform(modelingId)

	if posXYZ then
		entity.eModel:SetLocalPosition(posXYZ[1], posXYZ[2], posXYZ[3])
	end

	if rotXYZ then
		entity.eModel:SetTransformRotationByEulerAngle(rotXYZ[1], rotXYZ[2], rotXYZ[3])
	end

	if scaleXYZ then
		entity:setScaleNumber(scaleXYZ[1])
	end

	local avatarScene = self.avatarScene

	local function playRequestedAnimation()
		if not animKey then
			return
		end

		avatarScene:runWhenAnimatorReady(entity, function()
			if self.avatarScene ~= avatarScene or self._modelingPetTemplateId ~= modelingId or avatarScene:getEntity(modelingId) ~= entity then
				return
			end

			entity:playAnimation(animKey)
		end)
	end

	if entity.modelLoadedCallback then
		local orig = entity.modelLoadedCallback

		function entity.modelLoadedCallback()
			if self._modelingPetLoadToken ~= loadToken or self._modelingPetTemplateId ~= modelingId then
				entity.modelLoadedCallback = nil

				return
			end

			self:_cancelModelingPetLoadTimeout()
			orig()
			playRequestedAnimation()

			if onLoaded then
				onLoaded(entity)
			end
		end

		self:_startModelingPetLoadTimeout(modelingId, entity, loadToken)
	else
		self:_cancelModelingPetLoadTimeout()
		playRequestedAnimation()

		if onLoaded then
			onLoaded(entity)
		end
	end

	return entity, originalTransform
end

function AvatarPreviewComponent:getModelingPetTransform(modelingId)
	local entity = modelingId and self.avatarScene:getEntity(modelingId)

	if not entity or IsNil(entity.eModel) then
		return nil
	end

	local position = entity.eModel.transform.localPosition
	local rotationX, rotationY, rotationZ = entity.eModel:GetTransformRotationEulerAngles()

	return {
		position = {
			position.x,
			position.y,
			position.z
		},
		rotation = {
			rotationX,
			rotationY,
			rotationZ
		},
		scale = entity:getScaleNumber()
	}
end

function AvatarPreviewComponent:restoreModelingPetTransform(modelingId, transformInfo)
	local avatarScene = self.avatarScene

	if not modelingId or not transformInfo or not avatarScene then
		return false
	end

	local entity = avatarScene:getEntity(modelingId)

	if not entity or IsNil(entity.eModel) then
		return false
	end

	local position = transformInfo.position
	local rotation = transformInfo.rotation

	if position then
		entity.eModel:SetLocalPosition(position[1], position[2], position[3])
	end

	if rotation then
		entity.eModel:SetTransformRotationByEulerAngle(rotation[1], rotation[2], rotation[3])
	end

	if transformInfo.scale then
		entity:setScaleNumber(transformInfo.scale)
	end

	return true
end

function AvatarPreviewComponent:hideTemplateAvatar()
	if self.templatePresetKey then
		self.avatarScene:hideEntityWithId(self.templatePresetKey)
	end

	self.avatarScene:showAvatar(self.curPresetKey)
	self:setCameraModeFar()
end

function AvatarPreviewComponent:templateEquip(id)
	if not self.templatePresetKey then
		return
	end

	local entity = self.avatarScene:getCurEntity()

	if not entity then
		return
	end

	local idType = self:getAppearanceType(id)

	if idType == APPEARANCE_TYPE.CLOTHES then
		entity:setCustomShow(id, true)
		self:refreshTemplateClothes(entity)
	elseif idType == APPEARANCE_TYPE.SUIT then
		local suitData = AppearanceSuitData[id]

		if not suitData then
			return
		end

		local hideMap = self:getSuitHideJewelryMap(suitData)

		for partId = AppearancePointEnum.Coat, AppearancePointEnum.Shoes do
			entity:cancelCustomShow(partId, true)
		end

		for _, clothesId in ipairs(suitData.appearanceList or EMPTY_TABLE) do
			if not self:isSuitAppearanceHidden(hideMap, clothesId) then
				entity:setCustomShow(clothesId, true)
			end
		end

		self:refreshTemplateClothes(entity)

		if suitData.hair then
			if self:isSuitAppearanceHidden(hideMap, suitData.hair) then
				for partId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
					entity:cancelCustomShow(partId, true)
				end

				self:refreshTemplateHair(entity)
			else
				self:_templateEquipHair(entity, suitData.hair)
			end
		end

		for partId = AppearancePointEnum.Jewelry1, AppearancePointEnum.Jewelry10 do
			entity:cancelCustomShow(partId, true)
		end

		self:_equipSuitJewelryList(entity, suitData, hideMap, false)
		self:refreshTemplateAccessory(entity)
	elseif idType == APPEARANCE_TYPE.ACCESSORY then
		local data = AppearanceData[id]

		if not data then
			return
		end

		local slotId = self:_getAccessoryListSlot(data, {})

		if not slotId then
			return
		end

		entity:setCustomShow(id, true, slotId)
		self:refreshTemplateAccessory(entity)
	elseif idType == APPEARANCE_TYPE.HAIR then
		self:_templateEquipHair(entity, id)
	end
end

function AvatarPreviewComponent:templateUnEquip(id)
	if not self.templatePresetKey then
		return
	end

	local entity = self.avatarScene:getCurEntity()

	if not entity then
		return
	end

	local idType = self:getAppearanceType(id)

	if idType == APPEARANCE_TYPE.CLOTHES then
		local data = AppearanceData[id] or {}

		if data.points then
			for _, point in ipairs(data.points) do
				entity:cancelCustomShow(point, true)
			end
		end

		self:refreshTemplateClothes(entity)
	elseif idType == APPEARANCE_TYPE.SUIT then
		local suitData = AppearanceSuitData[id]

		for partId = AppearancePointEnum.Coat, AppearancePointEnum.Shoes do
			entity:cancelCustomShow(partId, true)
		end

		self:refreshTemplateClothes(entity)

		if suitData and suitData.hair then
			for partId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
				entity:cancelCustomShow(partId, true)
			end

			self:refreshTemplateHair(entity)
		end

		for partId = AppearancePointEnum.Jewelry1, AppearancePointEnum.Jewelry10 do
			entity:cancelCustomShow(partId, true)
		end

		self:refreshTemplateAccessory(entity)
	elseif idType == APPEARANCE_TYPE.ACCESSORY then
		local data = AppearanceData[id] or {}
		local slotId = data.partId

		if slotId then
			entity:cancelCustomShow(slotId, true)
		end

		self:refreshTemplateAccessory(entity)
	elseif idType == APPEARANCE_TYPE.HAIR then
		for partId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
			entity:cancelCustomShow(partId, true)
		end

		self:refreshTemplateHair(entity)
	end
end

function AvatarPreviewComponent:refreshTemplateClothes(entity)
	local modelView = entity.eModel.modelModelView

	for partId = AppearancePointEnum.Coat, AppearancePointEnum.Shoes do
		local clothesId = entity:getAppearanceConfigId(partId)
		local data = AppearanceData[clothesId]

		ClientModelUtils.applyAppearancePart(entity, partId, clothesId, data and data.res)
	end

	ClientModelUtils.refreshModels(entity, modelView)
	self:_ensureFacePreviewUndyedHook(entity)
end

function AvatarPreviewComponent:refreshTemplateHair(entity)
	local modelView = entity.eModel.modelModelView

	for partId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
		local configId = entity:getAppearanceConfigId(partId)
		local data = AppearanceData[configId]

		ClientModelUtils.applyAppearancePart(entity, partId, configId, data and data.res)
	end

	ClientModelUtils.refreshModels(entity, modelView)
	self:_ensureFacePreviewUndyedHook(entity)
end

function AvatarPreviewComponent:_templateEquipHair(entity, hairId)
	if not entity or not hairId then
		return
	end

	local modelInfo = entity.eModel.modelModelView.modelInfo
	local oldAssetId = modelInfo:GetOriginHairAssetId()
	local partItems = LuaUIUtils.getAllPartInSuit(hairId, oldAssetId)

	for partId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
		entity:cancelCustomShow(partId, true)

		local newConfigId = partItems[partId]

		if newConfigId and newConfigId ~= 0 then
			entity:setCustomShow(newConfigId, true, partId)
		end
	end

	self:refreshTemplateHair(entity)
end

function AvatarPreviewComponent:refreshTemplateAccessory(entity)
	local modelView = entity.eModel.modelModelView

	modelView.modelInfo:RemoveAllAttach()

	local attachList = {}

	for partId = AppearancePointEnum.Jewelry1, AppearancePointEnum.Jewelry10 do
		local accessoryId = entity:getAppearanceConfigId(partId)
		local reactionKey = ClientModelUtils.selectAppearanceAccessory(entity, partId, accessoryId)

		if accessoryId and accessoryId ~= 0 then
			attachList[#attachList + 1] = {
				accessoryId = accessoryId,
				reactionKey = reactionKey
			}
		end
	end

	ClientModelUtils.refreshModels(entity, modelView)

	for _, attach in ipairs(attachList) do
		self:refreshAttachByServer(attach.accessoryId, attach.reactionKey)
	end
end

function AvatarPreviewComponent:_getPetEntity()
	if not self.curPetId then
		return nil
	end

	local pInfo = pg.me:getPetInfo(self.curPetId)

	if not pInfo then
		return nil
	end

	return self.avatarScene:getEntity(pInfo.templateId)
end

function AvatarPreviewComponent:equipPetAccessory(accessoryId, slotIdx, skipRefresh)
	local entity = self:_getPetEntity()

	if not entity or not self.curPetId then
		return
	end

	local petAccessData = AppearanceJewelryPetData[accessoryId]

	if not petAccessData then
		return
	end

	slotIdx = slotIdx or 1

	local modelView = entity.eModel.modelModelView
	local modelInfo = modelView.modelInfo

	self.petOriginalAccessMap = self.petOriginalAccessMap or {}
	self._petPreviewSlots = self._petPreviewSlots or {}

	if self.petOriginalAccessMap[slotIdx] == nil then
		self:savePetOriginalAccess(slotIdx)
	end

	self.petAccessMap = self.petAccessMap or {}

	local oldInstanceId = self.petAccessMap[slotIdx]
	local originalAccess = self.petOriginalAccessMap[slotIdx]

	if not oldInstanceId and originalAccess then
		oldInstanceId = originalAccess.instanceId
	end

	if oldInstanceId then
		modelInfo:RemoveAttachInfoWithId(oldInstanceId)
	end

	ClientModelUtils.addPetDefaultModelAttach(entity, slotIdx, accessoryId)

	local previewInstanceId = string.format("%d_%d", slotIdx, accessoryId)

	self.petAccessMap[slotIdx] = previewInstanceId
	self._petPreviewSlots[slotIdx] = true
	self._petPreviewActive = true

	if not skipRefresh then
		ClientModelUtils.refreshModels(entity, modelView)
	end
end

function AvatarPreviewComponent:unEquipPetAccessory(slotIdx, skipRefresh)
	local entity = self:_getPetEntity()

	if not entity or not self.curPetId then
		return
	end

	slotIdx = slotIdx or 1

	local modelView = entity.eModel.modelModelView
	local modelInfo = modelView.modelInfo

	self.petAccessMap = self.petAccessMap or {}
	self._petPreviewSlots = self._petPreviewSlots or {}

	local previewInstanceId = self._petPreviewSlots[slotIdx] and self.petAccessMap[slotIdx] or nil

	if previewInstanceId then
		modelInfo:RemoveAttachInfoWithId(previewInstanceId)
		AppearanceEffectUtils.setPetAccessory(entity, slotIdx, nil)

		self.petAccessMap[slotIdx] = nil
	end

	self.petOriginalAccessMap = self.petOriginalAccessMap or {}

	local origInfo = self.petOriginalAccessMap[slotIdx]

	if origInfo then
		local scale = Vector3.New(origInfo.scale, origInfo.scale, origInfo.scale)

		modelInfo:AddAttachInfo(origInfo.resId, origInfo.instanceId, origInfo.attachHp, origInfo.localPosition, origInfo.localRotation, scale, false)
		AppearanceEffectUtils.setPetAccessory(entity, slotIdx, origInfo.accessoryId, origInfo.instanceId, origInfo.resId)

		self.petAccessMap[slotIdx] = origInfo.instanceId
	end

	self.petOriginalAccessMap[slotIdx] = nil
	self._petPreviewSlots[slotIdx] = nil
	self.petOriginalAccess = self.petOriginalAccessMap[1]
	self._petPreviewActive = next(self._petPreviewSlots) ~= nil

	if not skipRefresh then
		ClientModelUtils.refreshModels(entity, modelView)
	end
end

function AvatarPreviewComponent:clearPetAccessoryPreviewList(skipRefresh)
	local slots = {}

	for slotIdx in pairs(self._petPreviewSlots or {}) do
		slots[#slots + 1] = slotIdx
	end

	for _, slotIdx in ipairs(slots) do
		self:unEquipPetAccessory(slotIdx, true)
	end

	if not skipRefresh then
		local entity = self:_getPetEntity()

		if entity and entity.eModel and entity.eModel.modelModelView then
			ClientModelUtils.refreshModels(entity, entity.eModel.modelModelView)
		end
	end
end

function AvatarPreviewComponent:hidePetGiftAccessory(accessoryId)
	local entity = self:_getPetEntity()

	if not entity or not accessoryId or not entity.eModel then
		return
	end

	local modelView = entity.eModel.modelModelView

	for slotIdx in pairs(self._petPreviewSlots or {}) do
		local instanceId = string.format("%d_%d", slotIdx, accessoryId)

		if self.petAccessMap and self.petAccessMap[slotIdx] == instanceId then
			modelView:SetAttachVisibleByInstanceId(instanceId, false)
			AppearanceEffectUtils.setPetAccessory(entity, slotIdx, nil)

			if entity.refreshAppearanceAttachEffects then
				entity:refreshAppearanceAttachEffects()
			end

			if self.avatarScene and self.avatarScene.setPreviewEntityMirrorAttachVisible then
				self.avatarScene:setPreviewEntityMirrorAttachVisible(entity, instanceId, false)
			end

			return
		end
	end
end

function AvatarPreviewComponent:applyPetAccessoryPreviewList(accessoryIds)
	self:clearPetAccessoryPreviewList(true)

	for slotIdx, accessoryId in ipairs(accessoryIds or {}) do
		self:equipPetAccessory(accessoryId, slotIdx, true)
	end

	local entity = self:_getPetEntity()

	if entity and entity.eModel and entity.eModel.modelModelView then
		ClientModelUtils.refreshModels(entity, entity.eModel.modelModelView)
	end
end

function AvatarPreviewComponent:clearAllPetAccessory()
	local entity = self:_getPetEntity()

	if not entity or not self.petAccessMap then
		return
	end

	local modelView = entity.eModel.modelModelView
	local modelInfo = modelView.modelInfo

	for slotIdx, instanceId in pairs(self.petAccessMap) do
		modelInfo:RemoveAttachInfoWithId(instanceId)
		AppearanceEffectUtils.setPetAccessory(entity, slotIdx, nil)
	end

	self.petAccessMap = {}
	self.petOriginalAccess = nil
	self.petOriginalAccessMap = {}
	self._petPreviewSlots = {}
	self._petPreviewActive = false

	ClientModelUtils.refreshModels(entity, modelView)
end

function AvatarPreviewComponent:commitPetAccessory(genId, slotIdx, equipped, callback)
	if not self.curPetId then
		return
	end

	slotIdx = slotIdx or 1

	if not genId then
		local jerInfo = pg.me.petJewelryInfos[self.curPetId]

		if jerInfo and jerInfo.customShow then
			genId = jerInfo.customShow[slotIdx]
		end

		if not genId then
			return
		end
	end

	if equipped == nil then
		equipped = true
	end

	local setInfo = {
		{
			slotIdx,
			genId,
			equipped
		}
	}

	pg.me:serverMsg("RPC_CS_MultiSetPetJewelry", self.curPetId, setInfo, function(res)
		if callback then
			callback(res)
		end

		if res then
			self:syncPetAccessoryFromServer()
		end
	end)
end

function AvatarPreviewComponent:syncPetAccessoryFromServer()
	local entity = self:_getPetEntity()

	if entity and entity.eModel and entity.eModel.modelView and self.petAccessMap then
		local modelInfo = entity.eModel.modelView.modelInfo

		for _, instanceId in pairs(self.petAccessMap) do
			modelInfo:RemoveAttachInfoWithId(instanceId)
		end
	end

	self.petAccessMap = {}
	self.petOriginalAccess = nil
	self.petOriginalAccessMap = {}
	self._petPreviewSlots = {}
	self._petPreviewActive = false

	if not entity or not self.curPetId then
		return
	end

	local jerInfo = pg.me.petJewelryInfos and pg.me.petJewelryInfos[self.curPetId]

	entity.tempJewelryInfo = jerInfo
	entity.petJewelryInfo = jerInfo

	if entity.reloadAccessory then
		entity:reloadAccessory()
	end
end

function AvatarPreviewComponent:savePetOriginalAccess(slotIdx)
	self.petOriginalAccessMap = self.petOriginalAccessMap or {}

	local jerInfo = pg.me.petJewelryInfos and pg.me.petJewelryInfos[self.curPetId]

	if not jerInfo or not jerInfo.customShow then
		return
	end

	local genId = jerInfo.customShow[slotIdx]

	if not genId or genId == 0 then
		return
	end

	local accessoryId = self:getPetAccessoryIdByGenId(genId)
	local slotInfo = jerInfo[slotIdx]
	local serverData = accessoryId and PetJewelryOssCache.getSavedTransform(self.curPetId, accessoryId, slotInfo)

	if serverData and serverData.configId and serverData.configId ~= 0 then
		local petAccessData = AppearanceJewelryPetData[serverData.configId]

		if petAccessData then
			self.petOriginalAccessMap[slotIdx] = {
				accessoryId = serverData.configId,
				instanceId = string.format("%d_%d", slotIdx, serverData.configId),
				resId = petAccessData.res,
				attachHp = serverData.attachBone,
				localPosition = Vector3.New(serverData.posX, serverData.posY, serverData.posZ),
				localRotation = Vector3.New(serverData.rotX, serverData.rotY, serverData.rotZ),
				scale = serverData.scale
			}
			self.petOriginalAccess = self.petOriginalAccessMap[1]

			return
		end
	end

	if accessoryId then
		self.petOriginalAccessMap[slotIdx] = self:buildPetAttachInfo(accessoryId, slotIdx)
		self.petOriginalAccess = self.petOriginalAccessMap[1]
	end
end

function AvatarPreviewComponent:getPetAccessoryIdByGenId(genId)
	local itemBag = ItemUtils.getTypedBag(pg.me, ItemConst.INV_TYPE_PET_JEWELRY)
	local item = itemBag:get(genId)

	if item then
		return item.id
	end

	return nil
end

function AvatarPreviewComponent:buildPetAttachInfo(accessoryId, slotIdx)
	local pInfo = pg.me:getPetInfo(self.curPetId)
	local templateId = pInfo.templateId
	local petData = PetData[templateId]
	local refId = petData and petData.refId or templateId
	local attachInfo = pgUtils.GetAccessoryConfigFromLocal(templateId, accessoryId) or pgUtils.GetAccessoryConfigFromLocal(refId, accessoryId)
	local instanceId = string.format("%d_%d", slotIdx, accessoryId)

	if attachInfo then
		attachInfo.instanceId = instanceId
	else
		local entity = self:_getPetEntity()
		local adjustHeight = entity and entity.adjustHeight or 0
		local halfHeight = adjustHeight / 2

		attachInfo = {
			scale = 1,
			instanceId = instanceId,
			resId = AppearanceJewelryPetData[accessoryId].res,
			localPosition = Vector3.New(halfHeight, adjustHeight, 0),
			localRotation = Vector3.zero
		}
	end

	attachInfo.accessoryId = accessoryId

	return attachInfo
end

function AvatarPreviewComponent:buildTradeMarketPetAttachInfo(petTemplateId, accessoryId, slotIdx)
	local petData = PetData[petTemplateId]
	local refId = petData and petData.refId or petTemplateId
	local attachInfo = pgUtils.GetAccessoryConfigFromLocal(petTemplateId, accessoryId) or pgUtils.GetAccessoryConfigFromLocal(refId, accessoryId)

	if not attachInfo then
		return nil
	end

	attachInfo.instanceId = string.format("trade_market_%d_%d", slotIdx, accessoryId)

	return attachInfo
end

function AvatarPreviewComponent:clearTradeMarketPetAccessoryPreview()
	local previewInfo = self._tradeMarketPetAccessoryPreview

	if not previewInfo then
		return
	end

	local entity = self.avatarScene and self.avatarScene:getEntity(previewInfo.petTemplateId)

	if entity and entity.eModel and entity.eModel.modelView then
		local modelView = entity.eModel.modelView

		modelView.modelInfo:RemoveAttachInfoWithId(previewInfo.instanceId)
		AppearanceEffectUtils.setPetAccessory(entity, previewInfo.instanceId, nil)
		ClientModelUtils.refreshModels(entity, modelView)
	end

	self._tradeMarketPetAccessoryPreview = nil
end

function AvatarPreviewComponent:showTradeMarketPetAccessoryPreview(petTemplateId, accessoryId)
	if not petTemplateId or not AppearanceJewelryPetData[accessoryId] then
		return false
	end

	self:clearTradeMarketPetAccessoryPreview()
	self:showPetByModelingId(petTemplateId)
	self:setCameraZoomEnabled(true)

	local entity = self.avatarScene:getEntity(petTemplateId)

	if not entity or not entity.eModel or not entity.eModel.modelView then
		return false
	end

	local slotIdx = 1
	local attachInfo = self:buildTradeMarketPetAttachInfo(petTemplateId, accessoryId, slotIdx)

	if not attachInfo then
		return false
	end

	local modelView = entity.eModel.modelView
	local scale = Vector3.New(attachInfo.scale, attachInfo.scale, attachInfo.scale)

	modelView.modelInfo:AddAttachInfo(attachInfo.resId, attachInfo.instanceId, attachInfo.attachHp, attachInfo.localPosition, attachInfo.localRotation, scale, false)
	AppearanceEffectUtils.setPetAccessory(entity, attachInfo.instanceId, accessoryId, attachInfo.instanceId, attachInfo.resId)
	ClientModelUtils.refreshModels(entity, modelView)

	self._tradeMarketPetAccessoryPreview = {
		petTemplateId = petTemplateId,
		instanceId = attachInfo.instanceId
	}

	return true
end

function AvatarPreviewComponent:setBackground(bgId)
	if not self.avatarScene or not self.avatarScene.setBackground then
		return
	end

	self.avatarScene.disableBackground = false

	local bgData = AppearanceBackGroundData[bgId]

	if not bgData then
		return
	end

	self.avatarScene:setBackground(bgData.bgPrefab, bgId)

	self.avatarScene.disableBackground = true
end

function AvatarPreviewComponent:setBackgroundByPrefab(prefab)
	if not self.avatarScene or not self.avatarScene.setBackground then
		return
	end

	if not prefab then
		return
	end

	self.avatarScene.disableBackground = false

	self.avatarScene:setBackground(prefab)

	self.avatarScene.disableBackground = true
end

function AvatarPreviewComponent:playAnimation(animKey)
	local entity = self.avatarScene:getCurEntity()

	if not entity then
		return
	end

	self._shopPreviewAnimationKey = animKey

	entity:playAnimation(animKey)
end

function AvatarPreviewComponent:onPetBoxSelected(petId)
	self:showPet(petId)
end

return AvatarPreviewComponent
