-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\AppearanceV2\\Component\\PlayerHandheldComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local LuaUIUtils = require("Utils.LuaUIUtils")
local RedDotConst = require("Const.RedDotConst")
local Const = require("Common.Const.Const")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local HandheldAppearanceUIUtils = require("Utils.HandheldAppearanceUIUtils")
local HandheldAppearanceUtils = require("Utils.HandheldAppearanceUtils")
local ClientModelUtils = require("Utils.ClientModelUtils")
local ItemData = require("Data.item_data")
local AppearancePointEnum = require("Data.appearance_point_enum")
local AppearanceActionData = require("Data.appearance_action_data")
local PlayableConst = require("Common.Const.PlayableConst")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local TimerManager = require("Core.Timer.TimerManager")
local PlayerHandheldComponent = Class.LightClass("PlayerHandheldComponent", UIComponent)
local HANDHELD_PRELOAD_INTERVAL = 0.05
local HANDHELD_PRELOAD_TIMEOUT = 2
local PERIPHERAL_PREVIEW_REPLAY_LEAD_TIME = 0.05
local PERIPHERAL_PREVIEW_STATE_POLL_INTERVAL = 0.05
local PERIPHERAL_PREVIEW_STATE_POLL_TIMEOUT = 2
local FOOTPRINT_ACTION_HIDE_REASON = "appearance_handheld_footprint_action"

function PlayerHandheldComponent:findObjects()
	self.rootUComponent = self.ctrl.rootUComponent
end

function PlayerHandheldComponent:initView()
	self.avatarScene = pg.game.uiScene:getScene(UISceneConst.AVATAR_SCENE)
	self.slotOptionComponent = self.ctrl.slotOptionComponent
	self.previewPoints = {}
end

function PlayerHandheldComponent:onEnterPage()
	self.isActive = true
	self.previewPoints = {}

	local entity = self:getEntity()

	if entity then
		entity._appearanceHandheldPreviewComponent = self
	end

	self.rootUComponent:TryChangePage("State", "Normal")
	self.slotOptionComponent:setFilterRule({
		{
			filterBy = -1,
			text = pg.getGameString("ALL")
		}
	})
	self.slotOptionComponent:reset()

	local slots = self:initSlotList()

	if #slots > 0 then
		self.slotOptionComponent.slotUList:SelectItem(0)
	elseif #slots == 0 then
		self.slotOptionComponent.optionUList:SetList({})
	end

	self.avatarScene:setAvatarCameraModeFar()
end

function PlayerHandheldComponent:setFootprintEffectVisible(visible)
	local entity = self:getEntity()

	if not entity then
		return false
	end

	local previewId = self.previewPoints and self.previewPoints[AppearancePointEnum.FootPrint] or 0
	local configId = previewId > 0 and previewId or self:getEquippedId(AppearancePointEnum.FootPrint, false)
	local attachInfo = configId and ClientModelUtils.getPeripheralAttachInfo(entity, configId) or nil
	local resId = attachInfo and attachInfo.resId or nil

	if (not resId or resId == "") and not visible then
		resId = self.footprintResource or self.footprintHiddenResource
	end

	if not resId or resId == "" then
		return false
	end

	if entity.setAppearanceVisible then
		entity:setAppearanceVisible(resId, visible, FOOTPRINT_ACTION_HIDE_REASON)
	end

	local finalVisible = visible

	if entity.getAppearanceVisible then
		finalVisible = entity:getAppearanceVisible(resId)
	end

	if entity.eModel and entity.eModel.modelView then
		local modelView = entity.eModel.modelView

		if attachInfo and attachInfo.instanceId and modelView.SetAttachVisibleByInstanceId then
			modelView:SetAttachVisibleByInstanceId(attachInfo.instanceId, finalVisible)
		else
			modelView:SetAttachModelVisible(resId, finalVisible)
		end
	end

	self.footprintResource = resId

	if visible then
		-- block empty
	end

	self.footprintHiddenResource = resId

	return true
end

function PlayerHandheldComponent:addListener()
	return
end

function PlayerHandheldComponent:removeListener()
	self:stopPeripheralPreviewAnimation()
	HandheldAppearanceUtils.clear(self:getEntity())
	self:restoreEquippedAppearance()
	self:setFootprintEffectVisible(true)

	self.isActive = false
end

function PlayerHandheldComponent:onPageClose()
	self:stopPeripheralPreviewAnimation()
	self:restoreEquippedAppearance()
	self:setFootprintEffectVisible(false)

	local entity = self:getEntity()

	if entity and entity._appearanceHandheldPreviewComponent == self then
		entity._appearanceHandheldPreviewComponent = nil
	end

	HandheldAppearanceUtils.clear(entity)

	self.isActive = false
end

function PlayerHandheldComponent:onDestroy()
	self:onPageClose()
	UIComponent.onDestroy(self)
end

function PlayerHandheldComponent:getEntity()
	return self.avatarScene and self.avatarScene:getCurEntity() or nil
end

function PlayerHandheldComponent:getBodyType()
	local presetKey = self.ctrl.curPresetKey
	local presetData = presetKey and pg.game.avatar:getAvatarPresetData(presetKey) or nil

	return presetData and presetData.body or nil
end

function PlayerHandheldComponent:getEquippedId(pointId, applyPreview)
	local entity = self:getEntity()

	if entity and entity.getAppearanceConfigId then
		return entity:getAppearanceConfigId(pointId, applyPreview == true, true) or 0
	end

	local customShow = entity and entity.curShow and entity.curShow.customShow

	return customShow and customShow[pointId] or 0
end

function PlayerHandheldComponent:initSlotList(selectedPointId, selectedEquippedId)
	local slots = self.model:getPeripheralPointList(self:getBodyType(), function(pointId)
		return self:getEquippedId(pointId, false)
	end)

	for _, slot in ipairs(slots) do
		local equippedId

		if selectedPointId and slot.slotId == selectedPointId and selectedEquippedId ~= nil then
			equippedId = selectedEquippedId or 0
		else
			equippedId = self:getEquippedId(slot.slotId, false) or 0
		end

		local equippedConfig = equippedId > 0 and self:getConfig(equippedId) or nil

		if equippedConfig then
			slot.state = LuaUIUtils.SLOT_STATE.HAVE
			slot.icon = equippedConfig.icon or slot.icon
			slot.quality = equippedConfig.quality or slot.quality or 0
			slot.appearanceId = equippedId
		else
			slot.state = LuaUIUtils.SLOT_STATE.EMPTY
		end

		slot.slotIcon = slot.icon
		slot.text = pg.getLocalizationText(slot.text)
	end

	self.slotOptionComponent.slotUList:SetList(slots)

	if selectedPointId then
		for index, slot in ipairs(slots) do
			if slot.slotId == selectedPointId then
				self.slotOptionComponent.slotUList:SelectItem(index - 1)

				break
			end
		end
	end

	return slots
end

function PlayerHandheldComponent:onSlotSelectedChanged(data)
	if not data then
		return
	end

	local nextPointId = data.slotId

	self:stopPeripheralPreviewAnimation()
	self:restoreEquippedAppearance()

	if nextPointId ~= AppearancePointEnum.FootPrint then
		self:setFootprintEffectVisible(true)
	end

	self.activePointId = nextPointId

	local selected = self:initOptionList()

	self:playPointPreview(self.activePointId, selected, false)
end

function PlayerHandheldComponent:onSlotClicked(oldData, data)
	return
end

function PlayerHandheldComponent:onOptionSelectedChanged(data)
	self.currentOptionData = data

	self:refreshPeripheralDetail(data)
end

function PlayerHandheldComponent:refreshOptionListPreview(filterFunc)
	local previousId = self.currentOptionData and (self.currentOptionData.handheldId or self.currentOptionData.itemId)
	local selected = self:initOptionList(filterFunc)

	if self.activePointId ~= AppearancePointEnum.HandHeld then
		return selected
	end

	local selectedId = selected and (selected.handheldId or selected.itemId)

	if selectedId == previousId then
		return selected
	end

	self:stopPeripheralPreviewAnimation()

	if selected then
		self:playPointPreview(self.activePointId, selected, false)
	end

	return selected
end

function PlayerHandheldComponent:onFilterSelectedChanged(slotData, filterFunc)
	self.filterFunc = filterFunc

	self:refreshOptionListPreview(filterFunc)
end

function PlayerHandheldComponent:onFilterClicked(slotData, filterFunc)
	self.filterFunc = filterFunc

	self:refreshOptionListPreview(filterFunc)
end

function PlayerHandheldComponent:onSearchChanged(slotData, filterFunc)
	self.filterFunc = filterFunc

	self:refreshOptionListPreview(filterFunc)
end

function PlayerHandheldComponent:initOptionList(filterFunc)
	filterFunc = filterFunc or self.filterFunc
	self.currentOptionData = nil

	local pointId = self.activePointId

	if not pointId then
		self.slotOptionComponent.optionUList:SetList({})

		return
	end

	local equippedId = self:getEquippedId(pointId, false)
	local options = self.model:getPeripheralInfoList(pointId, self:getBodyType(), equippedId, filterFunc)

	self.slotOptionComponent.optionUList:SetList(options)

	for index, option in ipairs(options) do
		if option.handheldId == equippedId then
			self.slotOptionComponent.optionUList:SelectItem(index - 1)
			self:refreshPeripheralDetail(option)

			self.currentOptionData = option

			return option
		end
	end

	if #options > 0 then
		local defaultIndex = 1

		if pointId == AppearancePointEnum.HandHeld then
			for index, option in ipairs(options) do
				if option.claimed then
					defaultIndex = index

					break
				end
			end
		end

		local defaultOption = options[defaultIndex]

		self.slotOptionComponent.optionUList:SelectItem(defaultIndex - 1)
		self:refreshPeripheralDetail(defaultOption)

		self.currentOptionData = defaultOption

		return defaultOption
	end

	return nil
end

function PlayerHandheldComponent:onOptionClicked(slotData, oldData, data, button)
	local pointId = data and data.pointId or self.activePointId
	local entity = self:getEntity()

	if not pointId or not entity then
		return
	end

	local equippedId = self:getEquippedId(pointId, pointId == AppearancePointEnum.HandHeld)
	local decision = HandheldAppearanceUIUtils.resolveSelection(equippedId, data)
	local previewId = self.previewPoints and self.previewPoints[pointId] or 0

	if decision.action == "KEEP" and data and data.isEmpty and previewId > 0 then
		decision = {
			action = "CLEAR_PREVIEW"
		}
	end

	if decision.action == "IGNORE" then
		return
	end

	if pointId == AppearancePointEnum.FootPrint then
		if decision.action == "UNEQUIP" or decision.action == "CLEAR_PREVIEW" then
			self:setFootprintEffectVisible(false)
		elseif decision.action ~= "KEEP" then
			self:setFootprintEffectVisible(true)
		end
	end

	if decision.action == "UNEQUIP" then
		entity:cancelCustomShowPreview(pointId, true)
		entity:setCustomShow(0, true, pointId)

		self.previewPoints[pointId] = nil
	elseif decision.action == "CLEAR_PREVIEW" then
		entity:cancelCustomShowPreview(pointId)

		self.previewPoints[pointId] = nil
	elseif decision.action == "KEEP" then
		-- block empty
	elseif decision.action == "EQUIP" then
		entity:cancelCustomShowPreview(pointId, true)
		entity:setCustomShow(data.handheldId, true, pointId)

		self.previewPoints[pointId] = nil
	elseif decision.action == "PREVIEW" then
		entity:setCustomShowPreview(data.handheldId, true, pointId)

		self.previewPoints[pointId] = data.handheldId
	else
		entity:cancelCustomShowPreview(pointId, true)

		self.previewPoints[pointId] = nil
	end

	local handheldUnequipped = decision.action == "UNEQUIP" and pointId == AppearancePointEnum.HandHeld

	if handheldUnequipped then
		self:stopPeripheralPreviewAnimation()
		HandheldAppearanceUtils.clear(entity)
	end

	if pointId ~= AppearancePointEnum.HandHeld and decision.action ~= "KEEP" then
		self:refreshPeripheralModel()
	end

	self:refreshPeripheralDetail(data)

	if data.claimed and data.showRedDot then
		local treePath = string.format(RedDotConst.RedDotPath.APPEARANCE_OPTION_LIST_ITEM, data.itemId)

		pg.me:setRedDotRecord(Const.CLIENT_KEY.APPEARANCE_RED_DOT, treePath, false)

		data.showRedDot = false

		local optionUList = self.slotOptionComponent.optionUList

		optionUList:RefreshElement(optionUList:GetChildIndex(button))
	end

	if decision.action == "KEEP" then
		if pointId == AppearancePointEnum.Effect then
			return self:playPointPreview(pointId, data, true)
		end

		return true
	end

	local previewData = data

	if decision.action == "EQUIP" or decision.action == "UNEQUIP" then
		local selectedEquippedId = decision.action == "UNEQUIP" and 0 or data.handheldId

		self:initSlotList(pointId, selectedEquippedId)

		previewData = self:initOptionList() or self.currentOptionData
	end

	if decision.action == "UNEQUIP" then
		if not handheldUnequipped then
			self:stopPeripheralPreviewAnimation()
		end

		if pointId == AppearancePointEnum.HandHeld then
			self:refreshPeripheralDetail({
				isEmpty = true
			})

			return true
		end
	end

	self:playPointPreview(pointId, previewData, true)
end

function PlayerHandheldComponent:cancelHandheldPreload()
	if self.handheldPreloadTimer then
		TimerManager.removeTimer(self.handheldPreloadTimer)

		self.handheldPreloadTimer = nil
	end

	local entity = self.handheldPreloadEntity or self:getEntity()

	if entity and self.handheldPreloadResource and entity.extraUnPreloadEffect then
		entity:extraUnPreloadEffect(self.handheldPreloadResource)
	end

	self.handheldPreloadEntity = nil
	self.handheldPreloadResource = nil
	self.handheldPreloadGeneration = (self.handheldPreloadGeneration or 0) + 1
end

function PlayerHandheldComponent:isHandheldPreloaded(entity, resource)
	if not entity or not entity.isEffectPreloaded then
		return true
	end

	local ok, ready = pcall(entity.isEffectPreloaded, entity, resource)

	return ok and ready == true
end

function PlayerHandheldComponent:stopPeripheralPreviewAnimation()
	self:cancelHandheldPreload()

	if self.peripheralPreviewReplayTimer then
		TimerManager.removeTimer(self.peripheralPreviewReplayTimer)

		self.peripheralPreviewReplayTimer = nil
	end

	self.peripheralPreviewAnimationGeneration = (self.peripheralPreviewAnimationGeneration or 0) + 1

	local entity = self:getEntity()

	HandheldAppearanceUtils.clearPreviewEffectContext(entity)

	if not self.peripheralPreviewAnimationPlaying then
		return false
	end

	local state = self.peripheralPreviewAnimationState

	if state and state.SetLogicLoop then
		state:SetLogicLoop(false)
	end

	if entity then
		entity:stopAllAnimationEventEffects()
		self.avatarScene:playIdleAnimation(entity)
	end

	self.peripheralPreviewAnimationState = nil
	self.peripheralPreviewAnimationPlaying = false

	return true
end

function PlayerHandheldComponent:schedulePeripheralPreviewReplay(entity, state, animationKey, effectContext, generation)
	if not state then
		return false
	end

	local function isCurrentPreview()
		return generation == self.peripheralPreviewAnimationGeneration and self.peripheralPreviewAnimationPlaying and self.peripheralPreviewAnimationState == state and self:getEntity() == entity
	end

	local function scheduleEndFallback()
		if not state.AddEndCallback then
			return false
		end

		if state.AddAutoTransition then
			state:AddAutoTransition(0)
		end

		state:AddEndCallback(function(reason)
			if reason == PlayableConst.END_REASON.PLAYBACK and isCurrentPreview() then
				self:playLoopAnimation(animationKey, effectContext, true, generation)
			end
		end)

		return true
	end

	local elapsed = 0

	local function scheduleReplayTimer()
		self.peripheralPreviewReplayTimer = nil

		if not isCurrentPreview() then
			return
		end

		local length = state.Length or 0

		if length > 0 then
			local delay = math.max(length - elapsed - PERIPHERAL_PREVIEW_REPLAY_LEAD_TIME, PERIPHERAL_PREVIEW_STATE_POLL_INTERVAL)

			self.peripheralPreviewReplayTimer = TimerManager.addTimer(delay, function()
				self.peripheralPreviewReplayTimer = nil

				if isCurrentPreview() then
					self:playLoopAnimation(animationKey, effectContext, true, generation)
				end
			end)

			return
		end

		elapsed = elapsed + PERIPHERAL_PREVIEW_STATE_POLL_INTERVAL

		if elapsed < PERIPHERAL_PREVIEW_STATE_POLL_TIMEOUT then
			self.peripheralPreviewReplayTimer = TimerManager.addTimer(PERIPHERAL_PREVIEW_STATE_POLL_INTERVAL, scheduleReplayTimer)
		else
			scheduleEndFallback()
		end
	end

	scheduleReplayTimer()

	return true
end

function PlayerHandheldComponent:playLoopAnimation(animationKey, effectContext, skipStop, replayGeneration)
	if not animationKey then
		return false
	end

	if not skipStop then
		self:stopPeripheralPreviewAnimation()
	end

	local entity = self:getEntity()

	if not entity then
		return false
	end

	if replayGeneration and replayGeneration ~= self.peripheralPreviewAnimationGeneration then
		return false
	end

	local generation = replayGeneration

	if not generation then
		generation = (self.peripheralPreviewAnimationGeneration or 0) + 1
		self.peripheralPreviewAnimationGeneration = generation
	end

	if effectContext then
		HandheldAppearanceUtils.setPreviewEffectContext(entity, effectContext.resource, effectContext.actionIds)
	else
		HandheldAppearanceUtils.clearPreviewEffectContext(entity)
	end

	local state = entity:playAnimation(animationKey, true, nil, false, PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY)

	self.peripheralPreviewAnimationState = state
	self.peripheralPreviewAnimationPlaying = true

	self:schedulePeripheralPreviewReplay(entity, state, animationKey, effectContext, generation)

	return true
end

function PlayerHandheldComponent:playOnceAnimation(animationKey, effectContext, skipStop)
	if not animationKey then
		return false
	end

	if not skipStop then
		self:stopPeripheralPreviewAnimation()
	end

	local entity = self:getEntity()

	if not entity then
		return false
	end

	local generation = (self.peripheralPreviewAnimationGeneration or 0) + 1

	self.peripheralPreviewAnimationGeneration = generation

	if effectContext then
		HandheldAppearanceUtils.setPreviewEffectContext(entity, effectContext.resource, effectContext.actionIds)
	else
		HandheldAppearanceUtils.clearPreviewEffectContext(entity)
	end

	local state = entity:playAnimation(animationKey, true, nil, false, PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY)

	self.peripheralPreviewAnimationState = state
	self.peripheralPreviewAnimationPlaying = state ~= nil

	if state and state.AddAutoTransition and state.AddEndCallback then
		state:AddAutoTransition(0)
		state:AddEndCallback(function(reason)
			local isCurrentPreview = reason == PlayableConst.END_REASON.PLAYBACK and generation == self.peripheralPreviewAnimationGeneration and self.peripheralPreviewAnimationState == state and self:getEntity() == entity

			if isCurrentPreview then
				self.peripheralPreviewAnimationState = nil
				self.peripheralPreviewAnimationPlaying = false

				HandheldAppearanceUtils.clearPreviewEffectContext(entity)
			end
		end)
	end

	return state ~= nil
end

function PlayerHandheldComponent:getPreviewAnimationKey(data, fallback)
	local animationName = HandheldAppearanceUIUtils.getPreviewPlayable(data, fallback)

	return animationName and (PlayableConst[animationName] or animationName) or nil
end

function PlayerHandheldComponent:playHandheldAction(data)
	local actionId = HandheldAppearanceUIUtils.getDefaultActionId(data)
	local actionConfig = actionId and AppearanceActionData[actionId] or nil
	local resource = data and data.res

	if not resource or resource == "" then
		return false
	end

	local animations = actionConfig and actionConfig.res1 or nil
	local fallbackAnimation = animations and (animations[2] or animations[1]) or actionConfig and (actionConfig.resLoop or actionConfig.res) or nil
	local animationKey = self:getPreviewAnimationKey(data, fallbackAnimation)

	if not animationKey then
		return false
	end

	self:stopPeripheralPreviewAnimation()

	local entity = self:getEntity()

	if not entity then
		return false
	end

	local generation = self.handheldPreloadGeneration or 0

	self.handheldPreloadGeneration = generation + 1
	generation = self.handheldPreloadGeneration
	self.handheldPreloadResource = resource
	self.handheldPreloadEntity = entity

	if entity.extraPreloadEffect then
		entity:extraPreloadEffect(resource)
	end

	local effectContext = {
		resource = resource,
		actionIds = data.actionIds or data.actionId
	}
	local elapsed = 0

	local function startAction()
		if generation ~= self.handheldPreloadGeneration or self:getEntity() ~= entity then
			return
		end

		self.handheldPreloadTimer = nil

		self:playOnceAnimation(animationKey, effectContext, true)
	end

	if self:isHandheldPreloaded(entity, resource) then
		startAction()
	else
		local function pollPreload()
			if generation ~= self.handheldPreloadGeneration or self:getEntity() ~= entity then
				self.handheldPreloadTimer = nil

				return
			end

			elapsed = elapsed + HANDHELD_PRELOAD_INTERVAL

			if self:isHandheldPreloaded(entity, resource) or elapsed >= HANDHELD_PRELOAD_TIMEOUT then
				startAction()

				return
			end

			self.handheldPreloadTimer = TimerManager.addTimer(HANDHELD_PRELOAD_INTERVAL, pollPreload)
		end

		self.handheldPreloadTimer = TimerManager.addTimer(HANDHELD_PRELOAD_INTERVAL, pollPreload)
	end

	return true
end

function PlayerHandheldComponent:onActionStateChanged(actionId)
	actionId = actionId or 0

	if not self.isActive or self.activePointId ~= AppearancePointEnum.FootPrint then
		return false
	end

	local data = self.currentOptionData

	if not data or data.isEmpty then
		self:setFootprintEffectVisible(false)

		return self:stopPeripheralPreviewAnimation()
	end

	if not HandheldAppearanceUtils.isFootprintActionAllowed(data, actionId) then
		self:setFootprintEffectVisible(true)
		self:stopPeripheralPreviewAnimation()

		return true
	end

	if actionId <= 0 then
		self:setFootprintEffectVisible(true)
		self:stopPeripheralPreviewAnimation()

		return true
	end

	self:setFootprintEffectVisible(true)

	return true
end

function PlayerHandheldComponent:onCharacterStateChanged(newState)
	if not self.isActive or self.activePointId ~= AppearancePointEnum.FootPrint then
		return false
	end

	local data = self.currentOptionData

	if not data or data.isEmpty then
		self:setFootprintEffectVisible(false)

		return false
	end

	local entity = self:getEntity()
	local actionId = entity and entity.singleActionState or 0

	if actionId > 0 then
		return self:onActionStateChanged(actionId)
	end

	local inLocomotion = newState ~= nil and CharacterStateConst.isChildOfState(newState, CharacterStateConst.LOCOMOTION) or false

	if inLocomotion then
		self:setFootprintEffectVisible(true)

		return true
	end

	self:setFootprintEffectVisible(true)
	self:stopPeripheralPreviewAnimation()

	return true
end

function PlayerHandheldComponent:playPointPreview(pointId, data, selectedByUser)
	if pointId == AppearancePointEnum.FootPrint then
		if data and data.isEmpty then
			self:stopPeripheralPreviewAnimation()
			self:setFootprintEffectVisible(false)

			return true
		end

		local entity = self:getEntity()
		local currentActionId = entity and entity.singleActionState or 0

		if not HandheldAppearanceUtils.isFootprintActionAllowed(data, currentActionId) then
			self:setFootprintEffectVisible(true)
			self:stopPeripheralPreviewAnimation()

			return true
		end

		if entity then
			entity._appearanceHandheldPreviewComponent = self
		end

		if not selectedByUser and data then
			local appearanceId = data.handheldId or data.itemId
			local equippedId = self:getEquippedId(pointId, false)

			if entity and appearanceId and appearanceId > 0 and appearanceId ~= equippedId then
				entity:setCustomShowPreview(appearanceId, true, pointId)

				self.previewPoints[pointId] = appearanceId
			end

			self:refreshPeripheralModel()
		end

		self:setFootprintEffectVisible(true)

		local animationKey = self:getPreviewAnimationKey(data, PlayableConst.Walk)

		return self:playLoopAnimation(animationKey)
	end

	if pointId == AppearancePointEnum.HandHeld and data and not data.isEmpty then
		return self:playHandheldAction(data)
	end

	if pointId == AppearancePointEnum.Effect and data and data.isEmpty then
		self:stopPeripheralPreviewAnimation()

		return true
	end

	if pointId == AppearancePointEnum.Effect and selectedByUser then
		local animationKey = self:getPreviewAnimationKey(data)

		if animationKey then
			return self:playLoopAnimation(animationKey)
		end

		return true
	end

	return false
end

function PlayerHandheldComponent:refreshPeripheralDetail(data)
	if not data then
		return false
	end

	if data.isEmpty then
		self.rootUComponent:TryChangePage("State", "Normal")
		self.ctrl:passToRightInfoComponent(self.rootUComponent)

		return true
	end

	local itemId = data.itemId or data.handheldId
	local config = self:getConfig(itemId) or {}
	local itemConfig = itemId and ItemData[itemId] or {}
	local fashion = data.fashion or config.fashion or 0

	self.rootUComponent:TryChangePage("State", "Detail")
	self.rootUComponent:TryChangePage("detail", data.claimed and "setting" or "source")
	self.rootUComponent:TryChangePage("BtnType", 3)
	self.ctrl:passToRightInfoComponent(self.rootUComponent, {
		name = pg.getLocalizationText(itemConfig.itemName or ""),
		fashion = fashion,
		desc = pg.getLocalizationText(itemConfig.itemDes or ""),
		id = itemId,
		claimed = data.claimed == true
	})

	return true
end

function PlayerHandheldComponent:refreshPeripheralModel()
	local entity = self:getEntity()
	local modelView = entity and entity.eModel and entity.eModel.modelModelView

	if not modelView then
		return false
	end

	ClientModelUtils.initAttachModelInfo(entity)
	ClientModelUtils.refreshModels(entity, modelView)

	return true
end

function PlayerHandheldComponent:restoreEquippedAppearance()
	local entity = self:getEntity()

	if not entity or not self.previewPoints or next(self.previewPoints) == nil then
		return false
	end

	for pointId in pairs(self.previewPoints) do
		entity:cancelCustomShowPreview(pointId)
	end

	self.previewPoints = {}

	return self:refreshPeripheralModel()
end

function PlayerHandheldComponent:getConfig(id)
	return self.model:getPeripheralConfig(id)
end

return PlayerHandheldComponent
