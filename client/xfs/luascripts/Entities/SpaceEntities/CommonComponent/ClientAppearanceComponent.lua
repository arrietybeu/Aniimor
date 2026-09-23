-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientAppearanceComponent.lua

local Class = require("Core.Framework.Class")
local ClientModelUtils = require("Utils.ClientModelUtils")
local AppearanceEffectUtils = require("Utils.AppearanceEffectUtils")
local Const = require("Const.Const")
local MessageName = require("Const.MessageName")
local PlayableConst = require("Common.Const.PlayableConst")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local AvatarUtils = require("Guis.Utils.AvatarUtils")
local AppearancePointEnum = require("Data.appearance_point_enum")
local WeaponData = require("Data.weapon_data")
local AppearanceFunctionData = require("Data.appearance_function_data")
local AppearanceData = require("Data.appearance_data")
local AppearanceSuitData = require("Data.appearance_suit_data")
local AvatarPresetData = require("Data.avatar_preset_data")
local ColorJewelryData = require("Data.appearance_color_jewelry_data")
local ItemConstSourceData = require("Data.item_const_source_data")
local vehicle_seat_data = require("Data.vehicle_seat_data")
local Utils = require("Common.Utils.Utils")
local GameConst = CS.FunPlus.WorldX.Const.GameConst
local Animator = CS.UnityEngine.Animator
local NotNil = NotNil
local pg = pg
local ToBool = ToBool
local TRIGGER_DEFAULT = "TriggerDefault"
local HIDE_REASON_MENU = "menu"
local HIDE_REASON_ABILITY_ST = "abilityST"
local HIDE_REASON_PLAYABLE_STATE = "playableState"
local VEHICLE_SEAT_DEFAULT_MODEL_ID = -1
local VEHICLE_SEAT_EXIT_CHECK_INTERVAL = 0.05
local SPECIAL_SUIT_FUNCTION_TYPE = 2
local ClientAppearanceComponent = Class.Component("ClientAppearanceComponent")

function ClientAppearanceComponent:init()
	self.appearanceEffectInfo = {}
	self.appearanceVisibleMap = {}
	self.dirtyFlags = {}
	self.fashionSwitchToPetEffectResId = nil
	self.fashionSwitchToPlayerEffectResId = nil
end

function ClientAppearanceComponent:applyAttachModelVisibility(res, visible)
	if not self.eModel or IsNil(self.eModel.modelView) then
		return
	end

	local modelView = self.eModel.modelView

	modelView:SetAttachModelVisible(res, visible)

	local modelInfo = modelView.modelInfo
	local attachModelInfos = modelInfo and modelInfo.attachModelInfos

	if not attachModelInfos then
		return
	end

	for _, attachInfo in pairs(attachModelInfos) do
		if attachInfo and attachInfo.resId == res and attachInfo.instanceId and attachInfo.instanceId ~= "" then
			attachInfo.visible = visible

			modelView:SetAttachVisibleByInstanceId(attachInfo.instanceId, visible)
		end
	end
end

function ClientAppearanceComponent:getAppearanceVisible(res)
	local reasons = self.appearanceVisibleMap[res]

	return type(reasons) ~= "table" or next(reasons) == nil
end

function ClientAppearanceComponent:setAppearanceVisible(res, visible, reason)
	if not self.appearanceVisibleMap[res] then
		self.appearanceVisibleMap[res] = {}
	end

	if visible then
		self.appearanceVisibleMap[res][reason] = nil
	else
		self.appearanceVisibleMap[res][reason] = true
	end

	local newVisible = self:getAppearanceVisible(res)

	self:applyAttachModelVisibility(res, newVisible)
end

function ClientAppearanceComponent:recordLoadedMakeUpTexture()
	if not self.isMainPlayer then
		return
	end

	local modelView = self.eModel.modelModelView

	if not modelView.partModel then
		return
	end

	modelView.partModel:RecordLoadedMakeUpTexture()
end

function ClientAppearanceComponent:on_color_accessory_unlock(k, v)
	if v == false then
		return
	end

	local idNumDict = {}

	idNumDict[k] = {
		[Const.INV_BOUND_TYPE_INSENSITIVE] = 1
	}

	facade:sendMsgToUI(MessageName.ON_NOTIFY_ITEM, {
		idNumDict,
		ItemConstSourceData.ITEM_SOURCE_EVENT_FULL_SCREEN
	})
end

function ClientAppearanceComponent:on_curShow_color_accessory_changed(ov, nv)
	local accessoryId

	if nv == 0 then
		accessoryId = ColorJewelryData[ov].originalJewelryId

		local oldResId = ColorJewelryData[ov].res

		ClientModelUtils.removeModelAttach(self.eModel.modelView.modelInfo, oldResId)
	else
		accessoryId = ColorJewelryData[nv].originalJewelryId

		local oldResId = AppearanceData[accessoryId].res

		ClientModelUtils.removeModelAttach(self.eModel.modelView.modelInfo, oldResId)
	end

	local attachInfo = ClientModelUtils.getModelAttachInfo(self, accessoryId)

	attachInfo.resId = ClientModelUtils.getModelResId(accessoryId, nv)

	ClientModelUtils.addModelAttach(self.eModel.modelView.modelInfo, attachInfo)
	self:markDirty(AvatarUtils.PROPERTY.REFRESH_MODELS)
end

function ClientAppearanceComponent:on_fashion_score_changed(ov, nv)
	facade:SendMessageCommand(MessageName.ON_AVATAR_FASHION_SCORE_CHANGED, {
		oldValue = ov,
		newValue = nv
	})
end

function ClientAppearanceComponent:on_appearanceBackgrounds_changed(oldVal, newVal)
	if self ~= pg.me then
		return
	end

	facade:SendMessageCommand(MessageName.PHOTO_ASSET_UNLOCK_CHANGED)
end

function ClientAppearanceComponent:on_avatar_config_changed(ov, nv)
	local modelView = self.eModel.modelModelView

	modelView.modelInfo:ParseCustomData(decompressFromStr(nv))

	local partChanged = modelView.modelInfo:ApplyCustomPartAssetIds()

	modelView.modelInfo:ProcessCustomData()

	if partChanged then
		modelView.modelInfo:ParseToModelInfo()
	end

	modelView.forceLoadPart = true

	self:refreshAppearance()
	modelView:RefreshDecal()
	modelView:RefreshMakeup()

	modelView.forceLoadPart = false
end

function ClientAppearanceComponent:onAttachChanged(key)
	local resId = AppearanceData[key].res

	ClientModelUtils.removeModelAttach(self.eModel.modelView.modelInfo, resId)

	local attachInfo = ClientModelUtils.getModelAttachInfo(self, key)

	ClientModelUtils.addModelAttach(self.eModel.modelView.modelInfo, attachInfo)
	self:markDirty(AvatarUtils.PROPERTY.REFRESH_MODELS)
end

function ClientAppearanceComponent:on_jewelryLastInfos_changed(ov, nv, key)
	self:onAttachChanged(key)
end

function ClientAppearanceComponent:on_jewelryLastInfos_add(key, value)
	self:onAttachChanged(key)
end

function ClientAppearanceComponent:on_curShow_customShow_changed(ov, nv, key)
	local modelInfo = self.eModel.modelView.modelInfo
	local isClothes = key >= AppearancePointEnum.Coat and key <= AppearancePointEnum.Shoes
	local isHair = key >= AppearancePointEnum.Fringe and key <= AppearancePointEnum.Plait

	if isClothes or isHair then
		if AppearanceData[ov] then
			ClientModelUtils.removeModelPart(modelInfo, ov)
		end

		if AppearanceData[nv] then
			ClientModelUtils.addModelPart(modelInfo, nv)
		end

		if isClothes and self._stainInitializedSlots then
			self._stainInitializedSlots[key] = nil
		end
	end

	if key >= AppearancePointEnum.Jewelry1 and key <= AppearancePointEnum.Jewelry10 then
		if ov and ov ~= 0 then
			ClientModelUtils.removeModelAttach(modelInfo, AppearanceData[ov].res)
		end

		if nv and nv ~= 0 then
			local attachInfo = ClientModelUtils.getModelAttachInfo(self, nv, key)

			ClientModelUtils.addModelAttach(modelInfo, attachInfo)
		end
	end

	if key >= AppearancePointEnum.FootPrint and key <= AppearancePointEnum.Effect then
		local oldAttachInfo = ClientModelUtils.getPeripheralAttachInfo(self, ov)

		if oldAttachInfo then
			ClientModelUtils.removeModelAttach(modelInfo, oldAttachInfo.instanceId or oldAttachInfo.resId)
		end

		local newAttachInfo = ClientModelUtils.getPeripheralAttachInfo(self, nv)

		if newAttachInfo then
			ClientModelUtils.addModelAttach(modelInfo, newAttachInfo)
		end

		if key == AppearancePointEnum.FootPrint then
			self:refreshFootPrintVisible()
		elseif key == AppearancePointEnum.HandHeld and not self.isMainPlayer and self.singleActionState and self.singleActionState > 0 and self.tryRefreshInteractionAction then
			self:tryRefreshInteractionAction()
		end
	end

	self:markDirty(AvatarUtils.PROPERTY.REFRESH_MODELS)
end

function ClientAppearanceComponent:applyVehicleSeatAppearanceToModel(modelInfo)
	if self.vehicleSeatShowDefaultModel then
		AppearanceEffectUtils.replaceRange(self, AppearancePointEnum.Coat, AppearancePointEnum.Shoes)

		for partId = AppearancePointEnum.Coat, AppearancePointEnum.Shoes do
			local partResId = modelInfo.partModelInfo:GetPartResId(partId)

			if not string.isNilOrEmpty(partResId) then
				modelInfo.partModelInfo:RemovePartItem(partResId)
			end
		end

		return
	end

	if not self.vehicleSeatAppearanceIds then
		return
	end

	for _, appearanceId in ipairs(self.vehicleSeatAppearanceIds) do
		ClientModelUtils.addModelPart(modelInfo, appearanceId)
		AppearanceEffectUtils.setPartAppearance(self, appearanceId, true)
	end
end

function ClientAppearanceComponent:resolveVehicleSeatAppearanceIds(configIds)
	local ids = type(configIds) == "table" and configIds or {
		configIds
	}
	local result = {}
	local presetKey = pg.game and pg.game.avatar and pg.game.avatar:getPresetKey(self) or self.avatarPresetKey
	local body = presetKey and AvatarPresetData[presetKey] and AvatarPresetData[presetKey].body

	local function isBodyMatched(config)
		if not body or not config.body or #config.body == 0 then
			return true
		end

		for _, configBody in ipairs(config.body) do
			if configBody == body then
				return true
			end
		end

		return false
	end

	for _, configId in ipairs(ids) do
		local appearanceData = AppearanceData[configId]

		if appearanceData and appearanceData.points and #appearanceData.points > 0 and isBodyMatched(appearanceData) then
			result[#result + 1] = configId
		else
			local suitData = AppearanceSuitData[configId]
			local suitAppearances = suitData and isBodyMatched(suitData) and suitData.appearanceList or {}

			for _, appearanceId in ipairs(suitAppearances) do
				local suitAppearanceData = AppearanceData[appearanceId]

				if suitAppearanceData and suitAppearanceData.points and #suitAppearanceData.points > 0 and isBodyMatched(suitAppearanceData) then
					result[#result + 1] = appearanceId
				end
			end
		end
	end

	return result
end

function ClientAppearanceComponent:setVehicleSeatAppearances(appearanceIds, showDefaultModel)
	self:stopVehicleSeatAppearanceRestoreTimer()

	self.pendingClearVehicleSeatAppearances = nil
	self.vehicleSeatAppearanceIds = appearanceIds
	self.vehicleSeatShowDefaultModel = showDefaultModel

	if self.refreshModel and self.eModel then
		self:refreshModel()
	end
end

function ClientAppearanceComponent:clearVehicleSeatAppearances()
	self:stopVehicleSeatAppearanceRestoreTimer()

	self.pendingClearVehicleSeatAppearances = nil

	if not self.vehicleSeatAppearanceIds and not self.vehicleSeatShowDefaultModel then
		return
	end

	self.vehicleSeatAppearanceIds = nil
	self.vehicleSeatShowDefaultModel = nil

	if self.refreshModel and self.eModel then
		self:refreshModel()
	end
end

function ClientAppearanceComponent:stopVehicleSeatAppearanceRestoreTimer()
	if self.vehicleSeatAppearanceRestoreTimerId then
		self:removeTimer(self.vehicleSeatAppearanceRestoreTimerId)

		self.vehicleSeatAppearanceRestoreTimerId = nil
	end
end

function ClientAppearanceComponent:waitRemoteVehicleSeatExitAnimation(attachData)
	self:stopVehicleSeatAppearanceRestoreTimer()

	local exitAnimKey = PlayableConst[attachData.exitAnim]
	local enterAnimKey = PlayableConst[attachData.enterAnim]
	local loopAnimKey = PlayableConst[attachData.loopAnim]
	local loopAnimAlterKey = PlayableConst[attachData.loopAnimAlter]
	local baseLayer = PlayableConst.AnimationLayer.HUMAN_LAYER_BASE
	local timerId

	timerId = self:addRepeatTimer(VEHICLE_SEAT_EXIT_CHECK_INTERVAL, function()
		if self.vehicleSeatAppearanceRestoreTimerId ~= timerId then
			return
		end

		local state = self:getCurrentPlayableState(baseLayer)

		if state and state.IsPlaying then
			local animKey = state.Key

			if animKey == exitAnimKey then
				local length = state.Length

				if length <= 0 or length > state.Time then
					return
				end
			elseif animKey == enterAnimKey or animKey == loopAnimKey or animKey == loopAnimAlterKey then
				return
			end
		end

		self:clearVehicleSeatAppearances()
	end)
	self.vehicleSeatAppearanceRestoreTimerId = timerId
end

function ClientAppearanceComponent:EVENT_OnEnterVehicle(vehicle, seatId)
	if not Utils.isPlayer(self) then
		return
	end

	local seatData = vehicle_seat_data[seatId]
	local appearanceIds = seatData and seatData.appearanceIds

	if appearanceIds and appearanceIds[1] == VEHICLE_SEAT_DEFAULT_MODEL_ID then
		self:setVehicleSeatAppearances(nil, true)

		return
	end

	local resolvedIds = appearanceIds and self:resolveVehicleSeatAppearanceIds(appearanceIds) or {}

	if #resolvedIds == 0 then
		self:clearVehicleSeatAppearances()

		return
	end

	self:setVehicleSeatAppearances(resolvedIds)
end

function ClientAppearanceComponent:EVENT_OnExitVehicle(vehicle, seatId)
	if not self.vehicleSeatAppearanceIds and not self.vehicleSeatShowDefaultModel then
		return
	end

	local attachData = self.getSeatAttachData and self:getSeatAttachData(seatId)
	local waitExitAnim = attachData and not string.isNilOrEmpty(attachData.exitAnim)

	if waitExitAnim then
		self.pendingClearVehicleSeatAppearances = true

		if not self.isMainAuthority then
			self:waitRemoteVehicleSeatExitAnimation(attachData)
		end

		return
	end

	self:clearVehicleSeatAppearances()
end

function ClientAppearanceComponent:on_curShow_hairInfo_add(k, v)
	self:markDirty(AvatarUtils.PROPERTY.CUSTOM_HAIR)
end

function ClientAppearanceComponent:on_curShow_hairInfo_changed(ov, nv, key)
	self:markDirty(AvatarUtils.PROPERTY.CUSTOM_HAIR)
end

function ClientAppearanceComponent:on_curShow_hairInfo_delete(k, v)
	self:markDirty(AvatarUtils.PROPERTY.CUSTOM_HAIR)
end

function ClientAppearanceComponent:on_curShow_clothesDesign_add(k, v)
	ClientModelUtils.applyClothStainInfo(self, k, v)
end

function ClientAppearanceComponent:on_curShow_clothesDesign_changed(ov, nv, key)
	ClientModelUtils.applyClothStainInfo(self, key, nv)
end

function ClientAppearanceComponent:on_curShow_clothesDesign_delete(k, v)
	self.eModel.modelShaderView:ApplyPreset(k)
end

function ClientAppearanceComponent:on_curShow_suitId_changed(oldV, newV)
	self:refreshSuitIdleSpecial()

	if pg.me then
		pg.me:refreshSuitPowerFunction()
	end

	facade:SendMessageCommand(MessageName.APPEARANCE_CUR_SUIT_ID_CHANGED)
end

function ClientAppearanceComponent:on_curShow_isShowBag_changed(ov, nv)
	local actions = {
		{
			partId = GameConst.PART_TOP,
			slotId = GameConst.SLOT_BAG,
			visible = nv
		}
	}

	ClientModelUtils.applyPartRendererVisibility(self, actions)
end

function ClientAppearanceComponent:EVENT_OnModelRefreshed()
	if not self.eModel or IsNil(self.eModel.modelView) then
		return
	end

	if self.isAppearancePreview or self.studioPlayerUid then
		self:setRendererLod(0)
	end

	for res, reasons in pairs(self.appearanceVisibleMap or {}) do
		if type(reasons) == "table" and next(reasons) ~= nil then
			self:applyAttachModelVisibility(res, false)
		end
	end
end

function ClientAppearanceComponent:EVENT_OnAnimatorReady()
	self:refreshAppearanceFunction()
	ClientModelUtils.refreshAvatarMakeup(self)
	self:recordLoadedMakeUpTexture()
end

function ClientAppearanceComponent:refreshAppearanceFunction()
	self.eModel:SetExtraLayerDefaultAnimation(Const.COMPONENT_IDX_PLAYABLE, "GenFace_", 0)
	self.eModel:ClearIdleSpecialState(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER)

	if self.curShow then
		for partId = AppearancePointEnum.Jewelry1, AppearancePointEnum.Jewelry10 do
			self:innerRefreshAppearanceFunction(partId)
		end

		for partId = AppearancePointEnum.Coat, AppearancePointEnum.Shoes do
			self:innerRefreshAppearanceFunction(partId)
		end
	end

	self:refreshSuitIdleSpecial()

	if pg.me then
		pg.me:refreshSuitPowerFunction()
	end
end

function ClientAppearanceComponent:isCurrentPetSupportedBySuitPower(functionData, curCombatPetId)
	if not functionData or not Utils.isTable(functionData.petId) then
		return false
	end

	curCombatPetId = curCombatPetId or self.curCombatPetId

	local petInfo = self.getPetInfo and self:getPetInfo(curCombatPetId) or nil
	local currentPetTemplateId = tonumber(petInfo and petInfo.templateId)

	if not currentPetTemplateId then
		local currentPetEntity = self.getCurPetEntity and self:getCurPetEntity(curCombatPetId) or nil

		currentPetTemplateId = tonumber(currentPetEntity and currentPetEntity.templateId)
	end

	if not currentPetTemplateId then
		return false
	end

	for _, petId in ipairs(functionData.petId) do
		if tonumber(petId) == currentPetTemplateId then
			return true
		end
	end

	return false
end

function ClientAppearanceComponent:getActiveSuitPowerFunctionData(curCombatPetId)
	local curShow = self.curShow
	local suitId = tonumber(curShow and curShow.suitId) or 0
	local functionData = suitId ~= 0 and AppearanceFunctionData[suitId] or nil

	if not functionData or tonumber(functionData.type) ~= SPECIAL_SUIT_FUNCTION_TYPE or not self:isCurrentPetSupportedBySuitPower(functionData, curCombatPetId) then
		return nil
	end

	return functionData
end

function ClientAppearanceComponent:getSuitIdleSpecialStateKey()
	local curShow = self.curShow
	local suitId = tonumber(curShow and curShow.suitId) or 0

	if suitId == 0 then
		return 0
	end

	local functionData = AppearanceFunctionData[suitId]
	local idleSpecial = functionData and functionData.idleSpecial

	if string.isNilOrEmpty(idleSpecial) then
		return 0
	end

	return PlayableConst[idleSpecial] or 0
end

function ClientAppearanceComponent:applyIdleSpecialOverride(suitPowerFunctionData)
	if IsNil(self.eModel) then
		return
	end

	if self.isAppearancePreview or self.studioPlayerUid then
		return
	end

	if not self.hasEModelComponent or not self:hasEModelComponent(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER) then
		return
	end

	local petState = suitPowerFunctionData and suitPowerFunctionData.petState
	local stateKey = string.isNilOrEmpty(petState) and 0 or Animator.StringToHash(petState)

	if stateKey == 0 then
		stateKey = self:getSuitIdleSpecialStateKey()
	end

	self.eModel:SetOverrideIdleSpecial(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, stateKey)
end

function ClientAppearanceComponent:refreshSuitIdleSpecial()
	self:applyIdleSpecialOverride(self:getActiveSuitPowerFunctionData())
end

function ClientAppearanceComponent:refreshSuitPowerFunction(curCombatPetId)
	local functionData = self:getActiveSuitPowerFunctionData(curCombatPetId)

	self:setFashionSwitchEffectResIds(functionData and functionData.petEffId, functionData and functionData.roleEffId)
	self:applyIdleSpecialOverride(functionData)
end

function ClientAppearanceComponent:innerRefreshAppearanceFunction(partId)
	local configId = self.curShow.customShow[partId]

	if self.getAppearanceConfigId then
		configId = self:getAppearanceConfigId(partId, true, true)
	end

	if configId and configId ~= 0 then
		self:addAppearanceFunction(configId)
		self:refreshAppearanceAnimatorTrigger(configId)
	end
end

function ClientAppearanceComponent:addAppearanceFunction(configId)
	if not configId or configId == 0 then
		return
	end

	local appearanceFunctionData = AppearanceFunctionData[configId]

	if not appearanceFunctionData then
		return
	end

	local colorJewelryId = ClientModelUtils.getColorJewelryId(self.curShow, configId)
	local resId = ClientModelUtils.getModelResId(configId, colorJewelryId)

	if appearanceFunctionData.idleSpecial and self.eModel then
		local stateKey = PlayableConst[appearanceFunctionData.idleSpecial]

		if stateKey then
			self.eModel:AddIdleSpecialState(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, stateKey)
		end
	end

	if appearanceFunctionData.sound and self.eModel and NotNil(self.eModel.modelView) then
		local go = self.eModel.modelView:GetAttachModelGOByRes(resId)

		if go then
			pg.game.audio:playEvent(appearanceFunctionData.sound, go)
		end
	end

	if appearanceFunctionData.emoji and self.eModel then
		self.eModel:SetExtraLayerDefaultAnimation(Const.COMPONENT_IDX_PLAYABLE, "GenFace_", PlayableConst[appearanceFunctionData.emoji])
	end
end

function ClientAppearanceComponent:removeAppearanceFunction(key)
	return
end

function ClientAppearanceComponent:markDirty(flag)
	self.dirtyFlags[flag] = true
end

function ClientAppearanceComponent:checkAndResetDirty(flag)
	if self.dirtyFlags[flag] then
		self.dirtyFlags[flag] = nil

		return true
	end

	return false
end

function ClientAppearanceComponent:tick()
	if self:checkAndResetDirty(AvatarUtils.PROPERTY.REFRESH_MODELS) then
		if self.delayRecordHairInfo then
			pg.me:serverMsg("RPC_CS_UpdateAppearanceCustom", "curShow", self.delayRecordHairInfo.index, true, self.delayRecordHairInfo.hairCustomData)

			self.delayRecordHairInfo = nil
		end

		AvatarUtils.refreshWithCustomData(self.eModel.modelView, self)
	end

	if self:checkAndResetDirty(AvatarUtils.PROPERTY.CUSTOM_HAIR) then
		self:applyPlayerHairCustomData()
	end
end

function ClientAppearanceComponent:onEnterCombat()
	if self.curShow == nil then
		return
	end

	for partId = AppearancePointEnum.Jewelry1, AppearancePointEnum.Jewelry10 do
		local configId = self.curShow.customShow[partId]

		if configId and configId ~= 0 then
			self:refreshAppearanceAnimatorTrigger(configId)
		end
	end

	for partId = AppearancePointEnum.Coat, AppearancePointEnum.Shoes do
		local configId = self.curShow.customShow[partId]

		if configId and configId ~= 0 then
			self:refreshAppearanceAnimatorTrigger(configId)
		end
	end
end

function ClientAppearanceComponent:onLeaveCombat()
	if self.curShow == nil then
		return
	end

	for partId = AppearancePointEnum.Jewelry1, AppearancePointEnum.Jewelry10 do
		local configId = self.curShow.customShow[partId]

		if configId and configId ~= 0 then
			self:refreshAppearanceAnimatorTrigger(configId)
		end
	end

	for partId = AppearancePointEnum.Coat, AppearancePointEnum.Shoes do
		local configId = self.curShow.customShow[partId]

		if configId and configId ~= 0 then
			self:refreshAppearanceAnimatorTrigger(configId)
		end
	end
end

function ClientAppearanceComponent:refreshAppearanceAnimatorTrigger(configId)
	local appearanceFunctionData = AppearanceFunctionData[configId]

	if not appearanceFunctionData then
		return
	end

	local colorJewelryId = ClientModelUtils.getColorJewelryId(self.curShow, configId)

	if ToBool(appearanceFunctionData.animatorTrigger) then
		local triggerName = TRIGGER_DEFAULT

		if appearanceFunctionData.enterCombatTrigger and self:isInCombat() then
			triggerName = appearanceFunctionData.animatorTrigger
		end

		self.eModel.modelView:SetAttachModelAnimationTrigger(ClientModelUtils.getModelResId(configId, colorJewelryId), triggerName)
	end
end

function ClientAppearanceComponent:refreshAppearanceCollideMenu(value)
	for partId = AppearancePointEnum.Jewelry1, AppearancePointEnum.Jewelry10 do
		self:innerRefreshAppearanceCollideMenu(partId, value)
	end

	for partId = AppearancePointEnum.Coat, AppearancePointEnum.Shoes do
		self:innerRefreshAppearanceCollideMenu(partId, value)
	end
end

function ClientAppearanceComponent:innerRefreshAppearanceCollideMenu(partId, value)
	local configId = self.curShow.customShow[partId]

	if configId and configId ~= 0 then
		local appearanceFunctionData = AppearanceFunctionData[configId]

		if not appearanceFunctionData then
			return
		end

		if ToBool(appearanceFunctionData.collideMenu) then
			local colorJewelryId = ClientModelUtils.getColorJewelryId(self.curShow, configId)
			local resId = ClientModelUtils.getModelResId(configId, colorJewelryId)

			self:setAppearanceVisible(resId, not value, HIDE_REASON_MENU)
		end
	end
end

function ClientAppearanceComponent:EVENT_AbilityStateChange(value, abilityId)
	for partId = AppearancePointEnum.Jewelry1, AppearancePointEnum.Jewelry10 do
		local configId = self.curShow.customShow[partId]

		if configId and configId ~= 0 then
			local appearanceFunctionData = AppearanceFunctionData[configId]

			if not appearanceFunctionData then
				return
			end

			if ToBool(appearanceFunctionData.hideAbilities) and (appearanceFunctionData.hideAbilities[-1] or appearanceFunctionData.hideAbilities[abilityId]) then
				local colorJewelryId = ClientModelUtils.getColorJewelryId(self.curShow, configId)
				local resId = ClientModelUtils.getModelAttachResId(configId, colorJewelryId)

				self:setAppearanceVisible(resId, not value, HIDE_REASON_ABILITY_ST)
			end
		end
	end
end

function ClientAppearanceComponent:EVENT_OnCharacterStateChange(oldState, newState)
	local shouldRestoreAppearance = self.isMainAuthority and self.pendingClearVehicleSeatAppearances and CharacterStateConst.isChildOfState(oldState, CharacterStateConst.MOUNTING) and not CharacterStateConst.isChildOfState(newState, CharacterStateConst.MOUNTING)

	if shouldRestoreAppearance then
		self:clearVehicleSeatAppearances()
	end

	local newStateName = CharacterStateConst[newState].name

	for partId = AppearancePointEnum.Jewelry1, AppearancePointEnum.Jewelry10 do
		local configId = self.curShow.customShow[partId]

		if configId and configId ~= 0 then
			local appearanceFunctionData = AppearanceFunctionData[configId]

			if not appearanceFunctionData then
				return
			end

			if ToBool(appearanceFunctionData.hideStates) then
				local isVisible = not appearanceFunctionData.hideStates[newStateName]
				local colorJewelryId = ClientModelUtils.getColorJewelryId(self.curShow, configId)
				local resId = ClientModelUtils.getModelResId(configId, colorJewelryId)

				self:setAppearanceVisible(resId, isVisible, HIDE_REASON_PLAYABLE_STATE)
			end
		end
	end
end

function ClientAppearanceComponent:onPartModelAllLoaded()
	local partVisibleList = ClientModelUtils.getPartRendererVisibilityList(self)

	ClientModelUtils.applyPartRendererVisibility(self, partVisibleList)
	ClientModelUtils.refreshAvatarMakeup(self)
	facade:SendMessageCommand(MessageName.ON_PART_MODEL_ALL_LOADED, self.id)

	if self.modelPartModelAllLoaded then
		self.modelPartModelAllLoaded()
	end

	self:applyPlayerClothStain()
end

function ClientAppearanceComponent:applyPlayerClothStain()
	if not self.eModel or not self.curShow then
		return
	end

	if self.previewOutfitId then
		ClientModelUtils.applyOutfitClothesStain(self, self.previewOutfitId)

		return
	end

	if self.customShowPreview and next(self.customShowPreview) and self.getAppearanceConfigId then
		AvatarUtils.applyEquippedClothesStain(self, true, true)

		return
	end

	ClientModelUtils.applyClothesStainInfo(self, self.curShow)

	if not self._stainInitializedSlots then
		self._stainInitializedSlots = {}
	end

	local modelView = self.eModel.modelModelView

	for partId = AppearancePointEnum.Coat, AppearancePointEnum.Shoes do
		local clothesId = self.curShow.customShow[partId]

		if clothesId and clothesId ~= 0 and not self._stainInitializedSlots[partId] then
			self._stainInitializedSlots[partId] = true

			local appearanceInfo = pg.me and pg.me.appearanceInfo
			local appUnit = appearanceInfo and appearanceInfo[clothesId]
			local designIndex = appUnit and appUnit.designIndex or 0

			if designIndex == 0 and (not self.curShow.clothesDesigns or not self.curShow.clothesDesigns[partId]) and modelView.partModel:IsPartModelLoaded(partId) then
				modelView.shaderView:ApplyPreset(partId, "Default1")
			end
		end
	end
end

function ClientAppearanceComponent:applyPlayerHairCustomData()
	if not self.eModel or not self.curShow then
		return
	end

	for partId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
		ClientModelUtils.applyHairCustomData(self, self.curShow, partId)
	end
end

function ClientAppearanceComponent:setFashionSwitchEffectResIds(switchToPetEffectResId, switchToPlayerEffectResId)
	if string.isNilOrEmpty(switchToPetEffectResId) then
		-- block empty
	end

	self.fashionSwitchToPetEffectResId = switchToPetEffectResId

	if string.isNilOrEmpty(switchToPlayerEffectResId) then
		-- block empty
	end

	self.fashionSwitchToPlayerEffectResId = switchToPlayerEffectResId
end

function ClientAppearanceComponent:getFashionSwitchToPetEffectResId()
	return self.fashionSwitchToPetEffectResId
end

function ClientAppearanceComponent:getFashionSwitchToPlayerEffectResId()
	return self.fashionSwitchToPlayerEffectResId
end

function ClientAppearanceComponent:destroy()
	self.appearanceEffectInfo = nil

	self:stopVehicleSeatAppearanceRestoreTimer()
end

return ClientAppearanceComponent
