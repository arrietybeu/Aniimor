-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetManagement\\PetManagementCtrl.lua

local UICtrl = require("Guis.UICtrl")
local UIConst = require("Const.UIConst")
local NoticeDef = require("Common.NoticeDef")
local Class = require("Core.Framework.Class")
local MessageName = require("Const.MessageName")
local HotkeyConst = require("Const.HotkeyConst")
local TimerManager = require("Core.Timer.TimerManager")
local Time = require("Core.Common.Time")
local ConflictTypes = require("Common.ConflictTypes")
local SceneData = require("Data.scene_data")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local PetManagementCtrl = Class.LightClass("PetManagementCtrl", UICtrl)
local BoxPetComponent = require("Guis.Panels.PetManagement.Component.BoxPetComponent")
local DetailComponent = require("Guis.Panels.PetManagement.Component.DetailComponent")
local BoxListComponent = require("Guis.Panels.PetManagement.Component.BoxListComponent")
local ExplorePetComponent = require("Guis.Panels.PetManagement.Component.ExplorePetComponent")
local FightPetComponent = require("Guis.Panels.PetManagement.Component.FightPetComponent")
local PetResearchUtils = require("Guis.Utils.PetResearchUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Const = require("Common.Const.Const")
local ClientTextUtils = require("Utils.ClientTextUtils")
local PetManagementUtils = require("Utils.PetManagementUtils")
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")
local SysConfigData = require("Data.sys_config_data")
local PetManagementFilterModel = require("Guis.Panels.PetManagementFilter.PetManagementFilterModel")
local PetRenameValidator = require("Utils.PetRenameValidator")

PetManagementCtrl.messages = {
	[MessageName.PET_BOX_MAP_UPDATE] = {
		"refreshPetBox",
		true
	},
	[MessageName.PET_MANAGEMENT_ON_PET_MOVE_FINISHED] = {
		"onPetMoveFinished",
		true
	},
	[MessageName.MODIFY_PET_FORMATION] = {
		"onPetFormationUpdate",
		true
	},
	[MessageName.MODIFY_PET_EXPLORE_FORMATION] = {
		"onPetExploreFormationUpdate",
		true
	},
	[MessageName.FIGHT_GROUP_CHANGE] = {
		"onFightGroupChanged",
		true
	},
	[MessageName.ON_GROUP_NAME_CHANGE] = {
		"onGroupNameChanged",
		true
	},
	[MessageName.PET_CUSTOM_NAME_CHANGED] = {
		"onPetCustomNameChanged",
		true
	},
	[MessageName.PET_LEVEL_CHANGED] = {
		"onPetLevelChanged",
		true
	},
	[MessageName.PET_BOX_MAP_SEQUENCE_UPDATE] = {
		"onBoxMapSequenceChanged",
		true
	},
	[MessageName.ON_BOX_NAME_CHANGE] = {
		"onBoxNameChanged",
		true
	},
	[MessageName.PET_FAVORITE_CHANGE] = {
		"onPetFavoriteChanged",
		true
	},
	[MessageName.PET_FAVORITE_TYPE_CHANGE] = {
		"onPetFavoriteTypeChanged",
		true
	},
	[MessageName.PET_STAGE_UPDATE] = {
		"onPetEvolveChange",
		true
	},
	[MessageName.PET_EVOLVE_RED_DOT_RECORD_UPDATE] = {
		"onPetEvolveRedDotRecordUpdate",
		true
	},
	[MessageName.PLAYER_PET_CUR_ABILITY_CHANGED] = {
		"onPetCurAbilityChanged",
		true
	},
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	},
	[MessageName.ON_RECYCLE_PET] = {
		"onRecyclePet",
		true
	},
	[MessageName.ON_GIVE_PET] = {
		"onGivePet",
		true
	},
	[MessageName.HEALTH_POINT_CHANGE_ALTER] = {
		"onPetHpChanged",
		true
	},
	[MessageName.EXPLORE_PET_REVIVE_PERCENT_CHANGED] = {
		"onExplorePetRevivePercentChanged",
		true
	},
	[MessageName.PET_ADD_EXP] = {
		"onPetLevelChanged",
		true
	},
	[MessageName.CARRY_EQUIP] = {
		"event_CarryEquipped",
		true
	},
	[MessageName.CARRY_UNLOAD] = {
		"event_CarryUnload",
		true
	},
	[MessageName.CARRY_ASSIST_CHANGE] = {
		"event_CarryEquipped",
		true
	},
	[MessageName.CARRY_CERTIFY] = {
		"event_CarryCertify",
		true
	},
	[MessageName.ON_PET_BREAKTHROUGH_SUCCESS] = {
		"onPetBreakThroughSuccess",
		true
	},
	[MessageName.PLAYER_START_CARRY] = {
		"onPlayerStartCarry",
		true
	},
	[MessageName.PET_PROP_LEARN_CHANGE] = {
		"onPetPropLearnChange",
		true
	},
	[MessageName.PET_INHERIT_CHANGE] = {
		"onPetInheritChange",
		true
	},
	[MessageName.PET_CARRY_LOCK_CHANGE] = {
		"onPetCarryLockChange",
		true
	},
	[MessageName.PET_TRANSMOG_SCHEME_APPLIED] = {
		"onPetTransmogSchemeApplied",
		true
	},
	[MessageName.ON_SYSTEM_FUNCTION_UNLOCKED] = {
		"onSystemFunctionUnlocked",
		true
	}
}
PetManagementCtrl.MAX_FIGHT_PETS_COUNT = 4
PetManagementCtrl.DEFERRED_UI_SCENE_PRELOAD_DELAY = 2
PetManagementCtrl.DEFERRED_UI_SCENE_WAIT_INTERVAL = 0.05
PetManagementCtrl.PET_MOVE_REQUEST_TIMEOUT = 1
PetManagementCtrl.PET_MOVE_TOMBSTONE_TTL_MS = 30000
PetManagementCtrl.BACK_TO_WORLD_MAX_WAIT_FRAMES = 30
PetManagementCtrl.BACK_TO_WORLD_SETTLE_FRAMES = 2
PetManagementCtrl.timedOutSwitchBoxPetsByUid = PetManagementCtrl.timedOutSwitchBoxPetsByUid or {}
PetManagementCtrl._switchBoxPetRecordSeq = PetManagementCtrl._switchBoxPetRecordSeq or 0
PetManagementCtrl.DRAGGING_REPLICA_WIDGET = {
	EXPLORE_GROUP_CARD = 3,
	FIGHT_GROUP_CARD = 2,
	PET_BOX_CARD = 1,
	BOX_LIST_CARD = 4
}
PetManagementCtrl.CONSOLE_BAR_STATE = {
	IN_EMPTY_SKILL = "PetManagement_inEmptySkill",
	CAN_DROP = "PetManagement_canDrop",
	CAN_START_DRAG = "PetManagement_canStartDrag",
	IN_DRAGGING = "PetManagement_inDragging",
	IN_EMPTY_PET_BOX = "PetManagement_inEmptyPetBox"
}

function PetManagementCtrl:onShow()
	PetManagementCtrl.super.onShow(self)

	self.onMoveDisplay = false
end

function PetManagementCtrl:setConsoleBarState(stateKey, value)
	if CS.XGUI.Navigation and CS.XGUI.Navigation.ConsoleBar then
		CS.XGUI.Navigation.ConsoleBar.SetStateForAll(stateKey, value)

		if string.sub(stateKey, 1, 4) ~= "Not_" then
			CS.XGUI.Navigation.ConsoleBar.SetStateForAll("Not_" .. stateKey, not value)
		end
	end
end

function PetManagementCtrl:getManagedBlurEffect()
	return self.view and self.view.bgBlurUIBlurEffect
end

function PetManagementCtrl:open(info, cb, closeCb, sceneParams, onSceneLoadedCb, forceNoBlack)
	if self._waitBackToWorldFrameId then
		return
	end

	if self:checkNeedBackToWorldForBlur() then
		self:waitBackToWorldForBlur(function()
			PetManagementCtrl.super.open(self, info, cb, closeCb, sceneParams, onSceneLoadedCb, forceNoBlack)
		end)

		return
	end

	PetManagementCtrl.super.open(self, info, cb, closeCb, sceneParams, onSceneLoadedCb, forceNoBlack)
end

function PetManagementCtrl:checkNeedBackToWorldForBlur()
	if self._isOpen or self.view then
		return false
	end

	local blurConfig = self:getManagedBlurConfig()

	if not blurConfig or blurConfig.timing ~= UIConst.BLUR_TIMING.BEFORE_OPEN then
		return false
	end

	return pg.global.ui:checkUIOpen(UIConst.UI_ID_OPEN_SPECIAL_TRAIN_PANEL) == true
end

function PetManagementCtrl:waitBackToWorldForBlur(continuation)
	pg.global.ui:closeAllNormalPanel()

	local waitedFrames = 0
	local readyFrames = 0
	local frameId

	frameId = TimerManager.addRepeatNextFrameCb(function()
		waitedFrames = waitedFrames + 1

		if self:checkBackToWorldReady() then
			readyFrames = readyFrames + 1
		else
			readyFrames = 0
		end

		if readyFrames < PetManagementCtrl.BACK_TO_WORLD_SETTLE_FRAMES and waitedFrames < PetManagementCtrl.BACK_TO_WORLD_MAX_WAIT_FRAMES then
			return
		end

		TimerManager.delFrameCb(frameId)

		self._waitBackToWorldFrameId = nil

		continuation()
	end)
	self._waitBackToWorldFrameId = frameId
end

function PetManagementCtrl:checkBackToWorldReady()
	local uiScene = pg.game and pg.game.uiScene

	if uiScene and uiScene.uiSceneStack and #uiScene.uiSceneStack > 0 then
		return false
	end

	local cameraSystem = pg.game and pg.game.camera

	if cameraSystem and not cameraSystem.enableWorldCamera then
		return false
	end

	return not pg.global.ui:checkUIOpen(UIConst.UI_ID_OPEN_SPECIAL_TRAIN_PANEL)
end

function PetManagementCtrl:setIsDragging(isDragging)
	self.isDragging = isDragging

	self:_refreshTopRightTabsState()
	self:setConsoleBarState(self.CONSOLE_BAR_STATE.IN_DRAGGING, isDragging)

	if isDragging then
		self:setConsoleBarState(self.CONSOLE_BAR_STATE.CAN_START_DRAG, false)
	else
		self:setConsoleBarState(self.CONSOLE_BAR_STATE.CAN_DROP, false)
	end

	if self._hoveredComponent and self._hoveredButton and not IsNil(self._hoveredButton) then
		self._hoveredComponent:onHover(self._hoveredButton, self._hoveredIsEmpty, self._hoveredIsInUse)
	end
end

function PetManagementCtrl:recordHoveredButton(component, button, isEmpty, isInUse)
	self._hoveredComponent = component
	self._hoveredButton = button
	self._hoveredIsEmpty = isEmpty
	self._hoveredIsInUse = isInUse

	self:refreshMultiSelectBtnForbidden()
end

function PetManagementCtrl:clearHoveredButton(component, button)
	if self._hoveredButton == button then
		self._hoveredComponent = nil
		self._hoveredButton = nil
		self._hoveredIsEmpty = nil
		self._hoveredIsInUse = nil

		self:refreshMultiSelectBtnForbidden()
	end
end

function PetManagementCtrl:refreshMultiSelectBtnForbidden()
	local btn = self.view and self.view.gamepadVirtualButtonUButton

	if not btn then
		return
	end

	local hidden = true

	if self.inReleaseMode and self._hoveredComponent == self.boxPets and self._hoveredButton and not IsNil(self._hoveredButton) and self._hoveredIsEmpty ~= true and self._hoveredIsInUse ~= true then
		hidden = false
	end

	btn:SetHotkeyForceHidden(hidden)
end

function PetManagementCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
	self:initializeManagedBlur()

	self.model.isPvp = info and info.isPvp or false
	self.model.selectSortId = nil
	self.model.isDescending = nil
	self.model.filter = nil
	self.inReleaseMode = nil
	self.inFilterMode = nil
	self.model.inAutoFilterMode = nil
	self.hasIntelligentFilter = nil
	self.intelligentFilterId = nil
	self.player = pg.me

	self.model:setSelectGroupId(pg.me.curPetFormationIndex)

	self._initSelectSlotIndex = nil
	self._initGamepadFocusSlot = nil

	local targetPetId, targetBoxId, targetSlotIndex

	if info and info.petId then
		targetBoxId, targetSlotIndex = self.model:findBoxIdByPetId(info.petId)

		if targetBoxId then
			targetPetId = info.petId
		end
	end

	if not targetPetId and info and info.templateId then
		targetPetId, targetBoxId, targetSlotIndex = self.model:findPetIdByTemplateId(info.templateId)
	end

	if targetPetId then
		self.model.selectBoxId = targetBoxId

		self.model:setCurSelectPetId(targetPetId)

		self._initSelectSlotIndex = targetSlotIndex
		self._initGamepadFocusSlot = targetSlotIndex - 1
	else
		local petInfos = self.model:getGroupInfoById(self.model.selectGroupId)

		if petInfos[1] and petInfos[1].id then
			self.model:setCurSelectPetId(petInfos[1].id)
		end
	end

	self.model:initBoxManualLockStatues()

	self.petDetails = DetailComponent.new(self)
	self.boxPets = BoxPetComponent.new(self)

	function self.view.btnDisplayUButton.luaClick()
		self.boxPets:onClickDisplay()
	end

	self.explorePets = ExplorePetComponent.new(self)
	self.fightPets = FightPetComponent.new(self)
	self.boxLists = BoxListComponent.new(self)
	self.isDragging = false
	self.draggingReplicaWidget = nil
	self.draggingReplicaWidgetType = nil

	self:setConsoleBarState(self.CONSOLE_BAR_STATE.IN_DRAGGING, false)
	self:setConsoleBarState(self.CONSOLE_BAR_STATE.CAN_START_DRAG, false)
	self:setConsoleBarState(self.CONSOLE_BAR_STATE.CAN_DROP, false)
	self:setConsoleBarState(self.CONSOLE_BAR_STATE.IN_EMPTY_PET_BOX, false)
	self:setConsoleBarState(self.CONSOLE_BAR_STATE.IN_EMPTY_SKILL, false)

	self.selectedObjType = nil
	self.boxIdRecord = nil

	self:refreshLeftPanelHotKeyVisible()

	self.tickTimer = self:startTimer(function()
		self:tick()
	end, 0, true)

	self:_refreshPvpAverage()
end

function PetManagementCtrl:refreshLeftPanelNavFocus()
	return
end

function PetManagementCtrl:checkAndApplyIntelligentFilter()
	local fightPets = self.fightPets

	if not fightPets then
		self.boxPets:showAutoFilterBtn(false)

		return
	end

	self.hasIntelligentFilter = false
	self.intelligentFilterId = nil

	if fightPets.isBossRushMode then
		local BossRushLevelData = require("Data.bossrush_guanka_data")
		local levelData = BossRushLevelData[fightPets.bossRushLevelId]

		if levelData and levelData.intelligentFilterId then
			self.hasIntelligentFilter = true
			self.intelligentFilterId = levelData.intelligentFilterId
		end
	elseif fightPets.isRogueMode then
		local RogueDifficultyData = require("Data.rogue_difficulty_data")
		local difficultyCfg = RogueDifficultyData[fightPets.rogueLevelId]

		if difficultyCfg and difficultyCfg.intelligentFilterId then
			self.hasIntelligentFilter = true
			self.intelligentFilterId = difficultyCfg.intelligentFilterId
		end
	end

	if not self.hasIntelligentFilter then
		self.boxPets:showAutoFilterBtn(false)

		return
	end

	self.boxPets:showAutoFilterBtn(true)
	self.boxPets:applyIntelligentFilter(self.intelligentFilterId)
end

function PetManagementCtrl:_clearDeferredUIScenePreloadTimer()
	if self.deferredUIScenePreloadTimer then
		self:killTimer(self.deferredUIScenePreloadTimer)

		self.deferredUIScenePreloadTimer = nil
	end
end

function PetManagementCtrl:_dispatchDeferredUISceneLoadCallbacks(scene)
	local callbacks = self.deferredUISceneLoadCallbacks

	self.deferredUISceneLoadCallbacks = nil

	if not callbacks then
		return
	end

	for _, callback in ipairs(callbacks) do
		callback(scene)
	end
end

function PetManagementCtrl:_finishDeferredUISceneLoad(scene, succeed)
	self.isLoadingDeferredUIScene = false
	self.deferredUISceneWaitTimer = nil

	local loadedScene = succeed and self._isOpen and self.uiScene == scene and scene:checkLoaded() and NotNil(scene.scene) and scene or nil

	if loadedScene then
		self:onUISceneLoaded()
		self:onUISceneVisibleChange(self:getUISceneVisibleWithUI())
	elseif self.uiScene == scene then
		if not scene.expire then
			scene:removeUICtrlKey(self.module)

			if not scene:checkHasUICtrlBind() then
				pg.game.uiScene:switchOutScene(self._uiSceneName, false, nil, self.module)
			end
		end

		self.uiScene = nil
	end

	self:_dispatchDeferredUISceneLoadCallbacks(loadedScene)
end

function PetManagementCtrl:_waitForDeferredUISceneLoad(scene)
	if not self._isOpen or self.uiScene ~= scene or scene.expire then
		self:_finishDeferredUISceneLoad(scene, false)

		return
	end

	if scene:checkLoaded() then
		self:_finishDeferredUISceneLoad(scene, scene:checkLoadSucceed())

		return
	end

	self.deferredUISceneWaitTimer = self:startTimer(function()
		self.deferredUISceneWaitTimer = nil

		self:_waitForDeferredUISceneLoad(scene)
	end, self.DEFERRED_UI_SCENE_WAIT_INTERVAL)
end

function PetManagementCtrl:_ensureDeferredUISceneLoaded(callback)
	if callback then
		self.deferredUISceneLoadCallbacks = self.deferredUISceneLoadCallbacks or {}

		table.insert(self.deferredUISceneLoadCallbacks, callback)
	end

	if not self._isOpen then
		self:_dispatchDeferredUISceneLoadCallbacks(nil)

		return
	end

	if not self.uiScene then
		self:initUIScene()
	end

	local scene = self.uiScene

	if scene:checkLoaded() then
		self:_finishDeferredUISceneLoad(scene, scene:checkLoadSucceed())

		return
	end

	if self.isLoadingDeferredUIScene then
		return
	end

	self.isLoadingDeferredUIScene = true

	if scene:checkLoadStateIsNone() then
		scene:startLoad()
	end

	self:_waitForDeferredUISceneLoad(scene)
end

function PetManagementCtrl:preloadDeferredUIScene()
	self:_ensureDeferredUISceneLoaded()
end

function PetManagementCtrl:requestPetPreviewScene()
	self:_clearDeferredUIScenePreloadTimer()

	if self.hasPendingPetPreviewSceneRequest then
		return
	end

	self.hasPendingPetPreviewSceneRequest = true

	self:_ensureDeferredUISceneLoaded(function(scene)
		self.hasPendingPetPreviewSceneRequest = false

		if not scene or not self.view or not self.petDetails then
			return
		end

		if self:getRightPanelCurrentPage() ~= 2 then
			return
		end

		if not self:checkUIVisible() then
			return
		end

		if not self.isPetPreviewSceneActive then
			scene:onCtrlVisibleChange(self.module, true)
			pg.game.uiScene:switchToScene(self._uiSceneName, nil, nil, nil, self.module)

			self.isPetPreviewSceneActive = true
		end

		self.petDetails:onPetPreviewSceneReady()
	end)
end

function PetManagementCtrl:onOpen(info)
	self.fightPets:onOpen(info)
	self.boxPets:refreshReleaseAvailability()

	local initSelectSlotIndex = info and info.selectSlot or self._initSelectSlotIndex

	if initSelectSlotIndex then
		self.boxPets:selectSlot(initSelectSlotIndex)

		self._initSelectSlotIndex = nil

		if pg.game.input:isUsingGamepad() then
			local initGamepadFocusSlot = initSelectSlotIndex - 1

			self._initGamepadFocusSlot = initGamepadFocusSlot

			self.boxPets:restoreBoxNavFocusSlot(initGamepadFocusSlot)
			self:startFrameTimer(function()
				if self._initGamepadFocusSlot == initGamepadFocusSlot then
					self._initGamepadFocusSlot = nil
				end
			end, 2)
		else
			self._initGamepadFocusSlot = nil
		end
	end

	self.boxPets:enablePetsDrag()

	if info and info.subTab == 2 then
		self:startTimer(function()
			self.view.skillBtn:OnClickSimulate()
		end, 0.15)
	end

	if info and info.subTab == 3 then
		self:startTimer(function()
			if self.view.infoBtn then
				self.view.infoBtn:OnClickSimulate()
			end
		end, 0.15)
	end

	if info and info.selectMinLevelBattlePet then
		self.fightPets:selectMinLevelBattlePet()
	end

	if info then
		self.closeCallback = info.closeAction
	else
		self.closeCallback = nil
	end

	if info and info.cancelBlur then
		self.view.bgBlurUWidget:SetActive(false)
	end

	self:refreshTopRightTabList(info)
	self.model:initBoxManualLockStatues()
	self:checkAndApplyIntelligentFilter()
	self:_clearDeferredUIScenePreloadTimer()

	self.deferredUIScenePreloadTimer = self:startTimer(function()
		self.deferredUIScenePreloadTimer = nil

		self:preloadDeferredUIScene()
	end, self.DEFERRED_UI_SCENE_PRELOAD_DELAY)
end

function PetManagementCtrl:onUISceneVisibleChange(visible)
	UICtrl.onUISceneVisibleChange(self, visible)

	if visible and self.uiScene then
		self.uiScene:resumeTargetTexture()
	end
end

function PetManagementCtrl:onVisibleChange(visible)
	if visible and self._uiSceneVisibleWithUICtrl == true and self.uiScene and not self.uiScene.expire then
		self.uiScene:resumeTargetTexture()
	end

	if visible then
		if self.petDetails and self.model and self.model.curSelectPetId then
			self:showPetInfo(self.model:setUpPetInfo(pg.me:getPetInfo(self.model.curSelectPetId)), true)
		end

		if self.fightPets then
			self.fightPets:refreshFightList()
		end

		if self.boxPets then
			self:refreshPetBox()
			self.boxPets:enablePetsDrag()
		end

		if self:getRightPanelCurrentPage() == 2 then
			self:requestPetPreviewScene()
		end
	end
end

function PetManagementCtrl:onPlayerStartCarry()
	pg.global.ui:closeAllNormalPanel()
end

function PetManagementCtrl:tick()
	self.boxLists:tick()
end

function PetManagementCtrl:onDestroy()
	self:moveActiveSwitchBoxPetsToTombstones()

	self.player = nil

	pg.global.navMgr:RemoveLuaBeforeDragBeginListener("PetManagementCtrl")
	pg.global.navMgr:RemoveLuaDragEndListener("PetManagementCtrl")
	self:_clearDeferredUIScenePreloadTimer()

	if self.deferredUISceneWaitTimer then
		self:killTimer(self.deferredUISceneWaitTimer)

		self.deferredUISceneWaitTimer = nil
	end

	self.deferredUISceneLoadCallbacks = nil
	self.isLoadingDeferredUIScene = false
	self.isPetPreviewSceneActive = false
	self.hasPendingPetPreviewSceneRequest = false

	UICtrl.onDestroy(self)
	self:setConsoleBarState(self.CONSOLE_BAR_STATE.IN_DRAGGING, false)
	self:setConsoleBarState(self.CONSOLE_BAR_STATE.CAN_START_DRAG, false)
	self:setConsoleBarState(self.CONSOLE_BAR_STATE.CAN_DROP, false)
	self:setConsoleBarState(self.CONSOLE_BAR_STATE.IN_EMPTY_PET_BOX, false)
	self:setConsoleBarState(self.CONSOLE_BAR_STATE.IN_EMPTY_SKILL, false)
	PetManagementFilterModel.clearSessionCache()

	self.inReleaseMode = nil
	self.petDetails = nil

	self.boxPets:clearAllTempStorageGo()
	self.boxPets:clearData()

	self.boxPets = nil
	self.explorePets = nil

	if self.fightPets then
		self.fightPets:saveRogueTeam()
		self.fightPets:saveBossRushTeam()
	end

	self.fightPets = nil

	self.boxLists:destroyAll()

	self.boxLists = nil

	if self.tickTimer then
		self:killTimer(self.tickTimer)

		self.tickTimer = nil
	end

	self.model:clearIntelligentFilter()

	PetResearchUtils.inDetailLoading = nil

	self.model:redDot_Save()
	self.model:resetOnDestroy(self.boxIdRecord)

	self.m_openAutoSelectedTab = nil
	self.m_topRightTabListFinished = nil
	self.m_topRightTabItemList = nil

	self:killTimer(self.delayActiveBlurTimer)

	self.delayActiveBlurTimer = nil
end

function PetManagementCtrl:closePanel()
	self:dismiss()

	if self.closeCallback then
		self.closeCallback()
	end
end

function PetManagementCtrl:addListener()
	self.cancelBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.widget.gameObject, "cancelBind")
	self.cancelBind.isVirtual = true
	self.cancelBind.priority = -1
	self.cancelBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel

	function self.cancelBind.luaTrigger(inputInfo)
		if pg.game.input:isUsingGamepad() then
			if self.fightPets and self.fightPets.groupSelector.isPopup then
				return true
			end

			if inputInfo.phase == "Performed" then
				self:closePanel()
			end
		elseif inputInfo.phase == "Performed" then
			self:closePanel()
		end
	end

	local closeBind2 = KeyBindingPro.GetOrAddKeyBindingByName(self.view.widget.gameObject, "closeBind2")

	closeBind2.isVirtual = true
	closeBind2.priority = -1
	closeBind2.actionPath = LuaUIUtils.getFuncActionPath(Const.FUNCTION_IDS.PETENTRY)

	function closeBind2.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self:closePanel()
		end
	end

	function self.view.closeBtn.luaClick()
		self:closePanel()
	end

	function self.view.root.luaTryChangePage(name, pageIdx)
		if name == "ListType" and pageIdx == 0 then
			self.fightPets:hideFilterWhenSwitchBackToFightList()
			self.boxPets:showAllPetCardsElementIcon(false)
		elseif name == "ListType" and pageIdx == 1 then
			self.boxPets:hideFilterWhenSwitchBackToFightList()
			self.boxPets:showAllPetCardsElementIcon(true)
		elseif name == "ListType" and pageIdx == 2 then
			-- block empty
		end
	end

	self.currentPage = 0

	function self.view.btnBoxUButton.luaClick()
		pg.global.ui:open(UIConst.UI_ID_PET_MANAGEMENT_TIDY_UP, {
			boxId = self.model:getSelectBoxId()
		})
	end

	if self.view.leftHotKeyContent and self.view.leftHotKeyContent.SetHotKeyPaths then
		self.view.leftHotKeyContent:SetHotKeyPaths("Hud/LeftTriggerPagePrev")
	end

	if self.view.rightHotKeyContent and self.view.rightHotKeyContent.SetHotKeyPaths then
		self.view.rightHotKeyContent:SetHotKeyPaths("Hud/RightTriggerPageNxt")
	end

	self:bindHotKeyPerform("Hud/LeftTriggerPagePrev", function()
		if pg.game.input:isUsingGamepad() then
			return true
		end

		self.view.btnLeftUButton:OnClickSimulate()
	end, self.view.btnLeftUButton.gameObject)
	self:bindHotKeyPerform("Hud/RightTriggerPageNxt", function()
		if pg.game.input:isUsingGamepad() then
			return true
		end

		self.view.btnRightUButton:OnClickSimulate()
	end, self.view.btnRightUButton.gameObject)
	self:bindHotKeyPerform("Hud/InteractScroll", self.onPerformPetBoxScroll, self.view.btnLeftUButton.gameObject, "petBoxScroll")
	self.view.gamepadVirtualButtonUButton:SetGamepadAction("Raw/GamepadButtonWest", nil, function()
		if self.inReleaseMode and self.boxPets and self.boxPets.normalListBtnCaches and not self.inFilterMode then
			local ClickedBtn = {}

			for _, btn in pairs(self.boxPets.normalListBtnCaches) do
				if not IsNil(btn) and btn.isSelected and self.boxPets.btnFunctionCache and self.boxPets.btnFunctionCache[btn] then
					if not ClickedBtn[btn] then
						self.boxPets.btnFunctionCache[btn]()
					end

					ClickedBtn[btn] = true
				end
			end
		elseif self.inReleaseMode and self.boxPets and self.boxPets.filterListBtnCaches and self.inFilterMode then
			local ClickedBtn = {}

			for _, btn in pairs(self.boxPets.filterListBtnCaches) do
				if not IsNil(btn) and btn.isSelected and self.boxPets.btnFunctionCache and self.boxPets.btnFunctionCache[btn] then
					if not ClickedBtn[btn] then
						self.boxPets.btnFunctionCache[btn]()
					end

					ClickedBtn[btn] = true
				end
			end
		end
	end)
	self.view.gamepadVirtualButtonUButton:SetHotkeyConsoleBar("CONSOLE_BAR_MULTI_SELECT", -1)
	self:refreshMultiSelectBtnForbidden()

	function self.view.boxSelector.luaOnPopupChanged(isOpen)
		pg.global.ui:refreshLockCursor()
	end

	pg.global.navMgr:AddLuaBeforeDragBeginListener("PetManagementCtrl", function()
		if not self:getUIVisible() then
			return
		end

		pg.global.navMgr.IsOffsetOverride = true
		pg.global.navMgr.KeepFocusOnSuccessfulDrag = true
		pg.global.navMgr.OffsetOverrideValue = Vector2(0, 0.4)
	end)
	pg.global.navMgr:AddLuaDragEndListener("PetManagementCtrl", function()
		pg.global.navMgr.IsOffsetOverride = false
		pg.global.navMgr.KeepFocusOnSuccessfulDrag = false
	end)
	self.view.midPanelUComponent:SetNavGroupAllowSelectOnRestore(true)
	self.view.petListUWidget:SetNavGroupAllowSelectOnRestore(true)
end

function PetManagementCtrl:onPerformPetBoxScroll(inputInfo)
	if pg.game.input:isUsingGamepad() then
		return true
	end

	if self.onMoveDisplay or self.isDragging or self.inFilterMode then
		return true
	end

	if self.view.boxSelector and self.view.boxSelector.isPopup then
		return true
	end

	local isPre = PetManagementDataHelper.getSwitchBoxPageIsPre(inputInfo and inputInfo.valueVec2 and inputInfo.valueVec2.y)

	if isPre == nil then
		return true
	end

	local button = isPre and self.view.btnLeftUButton or self.view.btnRightUButton

	if IsNil(button) then
		return true
	end

	button:OnClickSimulate()

	return false
end

function PetManagementCtrl:getWhiteList()
	local whiteList = {}

	whiteList[UIConst.UI_ID_REPLACE_SKILL_POPUP] = true
	whiteList[UIConst.UI_ID_PET_MANAGEMENT_FILTER] = true

	return whiteList
end

function PetManagementCtrl:switchManagementPages(index)
	if self.inReleaseMode then
		return
	end

	if index == self.currentPage then
		return
	end

	self.view.root:TryChangePage("ListType", index)

	self.currentPage = index

	self:refreshBaseNavigationSubArea(0)

	if self.m_topRightTabItemList then
		local isSelected = false
		local buttongChangePage = 0

		for i, item in pairs(self.m_topRightTabItemList) do
			isSelected = i == index
			item.isSelected = isSelected
			buttongChangePage = isSelected and 5 or 0

			if item and item.button then
				item.button:TryChangePage("button", buttongChangePage)
			end
		end
	end
end

function PetManagementCtrl:isInRightNavigation()
	return false
end

function PetManagementCtrl:refreshBaseNavigationSubArea(areaIdx)
	return
end

function PetManagementCtrl:getBaseGamepadSubAreaIdx(areaIdx)
	if areaIdx == 0 then
		if self.inReleaseMode then
			return 2
		end

		if self.currentPage == 1 then
			return 1
		end

		local isSupportMode

		isSupportMode = not not self.fightPets and not self.fightPets.isNormalBattleMode ~= false

		if isSupportMode then
			return 3
		else
			return 0
		end
	elseif areaIdx == 1 then
		if self.inFilterMode then
			return 1
		else
			return 0
		end
	end

	return 0
end

function PetManagementCtrl:onReleaseModeChange(isInReleaseMode)
	self:_refreshTopRightTabsState()
	self:refreshBaseNavigationSubArea(0)
	self:refreshMultiSelectBtnForbidden()
end

function PetManagementCtrl:initNavBattleMode()
	self:refreshBaseNavigationSubArea(0)
end

function PetManagementCtrl:openManagePage(show)
	if show then
		self.view.root:TryChangePage("ListType", 2)
	else
		self.view.root:TryChangePage("ListType", self.currentPage)
	end
end

function PetManagementCtrl:checkUIShowVirtualMouseCursor()
	return false
end

function PetManagementCtrl:getRightPanelCurrentPage()
	local _, page = self.view.rightPanelUComponent:TryGetCurrentPage("tabInfo")

	return page
end

function PetManagementCtrl:getListTypeCurrentPage()
	local _, page = self.view.root:TryGetCurrentPage("ListType")

	return page
end

function PetManagementCtrl:refreshPetBox(isHoverIn)
	if type(isHoverIn) == "table" then
		isHoverIn = nil
	end

	self.boxPets:refreshPetList(isHoverIn)
	self.boxPets:refreshBoxSelector()
	self.boxLists:refreshBoxList()
end

function PetManagementCtrl:onPetFormationUpdate()
	self.fightPets:refreshFightList()
	self.fightPets:refreshGroupSelector()
	TimerManager.addNextFrameCb(function()
		if not self.boxPets then
			return
		end

		if not self.boxPets:tryRefreshChangedBattleBadges() then
			self.boxPets:refreshPetList()
		end
	end)
	self.boxPets:refreshBoxSelector()
	self.boxLists:refreshBoxList()

	if self.delayRefreshPetFormationTimer then
		TimerManager.removeTimer(self.delayRefreshPetFormationTimer)

		self.delayRefreshPetFormationTimer = nil
	end

	self.delayRefreshPetFormationTimer = TimerManager.addTimer(0.1, function()
		self:showPetInfo(self.model:setUpPetInfo(pg.me:getPetInfo(self.model.curSelectPetId)), true)
	end)
end

function PetManagementCtrl:onPetExploreFormationUpdate()
	self.explorePets:refreshExploreList()
	TimerManager.addNextFrameCb(function()
		if not self.boxPets then
			return
		end

		if not self.boxPets:tryRefreshChangedBattleBadges() then
			self.boxPets:refreshPetList()
		end
	end)
	self.boxPets:refreshBoxSelector()
	self.boxLists:refreshBoxList()

	if self.delayRefreshPetExploreTimer then
		TimerManager.removeTimer(self.delayRefreshPetExploreTimer)

		self.delayRefreshPetExploreTimer = nil
	end

	self.delayRefreshPetExploreTimer = TimerManager.addTimer(0.1, function()
		self:showPetInfo(self.model:setUpPetInfo(pg.me:getPetInfo(self.model.curSelectPetId)), true)
	end)
end

function PetManagementCtrl:refreshAll()
	TimerManager.addNextFrameCb(function()
		if not self.fightPets then
			return
		end

		self.fightPets:refreshFightList()
		self.explorePets:refreshExploreList()
		self.boxPets:refreshPetList()
		self.boxPets:refreshBoxSelector()
		self.boxLists:refreshBoxList()
	end)
end

function PetManagementCtrl:onFightGroupChanged()
	self.fightPets:refreshFightBtn()
	self:onPetFormationUpdate()
end

function PetManagementCtrl:onBoxMapSequenceChanged(isManual)
	self.boxPets:refreshPetList(nil, isManual)
	self.boxPets:refreshBoxSelector()
	self.boxLists:refreshBoxList()
end

function PetManagementCtrl:checkInCombat()
	local pawn = pg.pawn
	local isRogue = self.fightPets and self.fightPets.isRogueMode

	if pawn:isInCombat() and not isRogue then
		pg.global.showBubbleMessage(NoticeDef.SWITCH_PET_IN_COMBAT)

		return true
	end

	return false
end

function PetManagementCtrl:showRename(renameType, forceId, ensureCb, cancelCb, loadCb)
	if renameType == self.model.RENAME_FOR_PET and not PetRenameValidator.canRenamePet() then
		pg.global.showBubbleMessage(NoticeDef.FORBID_CHANGE_PET_NAME)

		return
	end

	local title, id, text

	if renameType == self.model.RENAME_FOR_PET then
		title = pg.getGameString("RENAME_TIPS_PET")
		id = self.model.curSelectPetId
		text = self.model:getPetName(id)
	elseif renameType == self.model.RENAME_FOR_GROUP then
		title = pg.getGameString("RENAME_TIPS_GROUP")
		text = self.model:getGroupNameByIndex(forceId)
	elseif renameType == self.model.RENAME_FOR_BOX then
		title = pg.getGameString("RENAME_TIPS_BOX")
		text = self.model:getBoxNameById(forceId)
	end

	if forceId then
		id = forceId
	end

	pg.global.ui.tips:showCommonInput(title, function(newName)
		if string.isNilOrEmpty(newName) or string.find(newName, "%s") then
			pg.global.showBubbleMessageRaw(pg.getGameString("NAME_NOT_VALID"))

			return true
		end

		self.model:trySyncRename(newName, renameType, id)

		if ensureCb then
			ensureCb()
		end
	end, function()
		if cancelCb then
			cancelCb()
		end
	end, {
		characterLimit = renameType == self.model.RENAME_FOR_BOX and 12 or 14,
		text = text or ""
	}, loadCb)
end

function PetManagementCtrl:onGroupNameChanged(info)
	self.fightPets:refreshGroupSelector()
	self.fightPets:refreshSingleGroupSelectorItemName(info.index, info.newName)
end

function PetManagementCtrl:onBoxNameChanged(info)
	self.boxPets:refreshBoxSelector()
	self.boxPets:refreshSingleBoxSelectorItemName(info.index, info.newName)
end

function PetManagementCtrl:onRecyclePet()
	self.model:setCurSelectPetId(nil)
	self.boxPets:refreshPetList()
	self.boxPets:refreshBoxSelector()
	self.boxLists:refreshBoxList()
	self.boxPets:modifyBatchReleasePetIds(nil, nil, true)
	self:showPetInfo()
	TimerManager.addNextFrameCb(function()
		if self.inReleaseMode and self.boxPets then
			self.boxPets:enablePetsDrag()
		end
	end)
end

function PetManagementCtrl:onGivePet(errorCode)
	if errorCode and errorCode == Const.FollowGivePetError.SUCCESS then
		self.model:setCurSelectPetId(nil)
		self.boxPets:refreshPetList()
		self.boxPets:refreshBoxSelector()
		self.boxLists:refreshBoxList()
		self.boxPets:modifyBatchReleasePetIds(nil, nil, true)
		self:showPetInfo()
	end
end

function PetManagementCtrl:showPetInfo(data, force)
	self.petDetails:refreshPetInfoDetail(data, force)
end

function PetManagementCtrl:onPetEvolveChange(info)
	if info.canStageUp == nil then
		return
	end

	self.petDetails:refreshCanEvolve(info.canStageUp)

	if info.petId == self.model.curSelectPetId then
		self.petDetails:refreshEvolveRedDot()
	end
end

function PetManagementCtrl:onPetEvolveRedDotRecordUpdate()
	if self.model.curSelectPetId ~= nil then
		self.petDetails:refreshEvolveRedDot()
	end
end

function PetManagementCtrl:onPetCustomNameChanged(info)
	local petId = info.petId

	self:tryRefreshFightPets(petId)

	if petId == self.model.curSelectPetId then
		local name = self.model:getCurPetName()

		self.petDetails:refreshPetName(name)
	end
end

function PetManagementCtrl:tryRefreshFightPets(petId)
	if self.model:checkInCurrentFight(petId) then
		self.fightPets:refreshFightList()
	end

	if self.fightPets and self.fightPets.isRogueMode then
		self.fightPets:TryRefreshRoguePetElement(petId)
	elseif self.fightPets and self.fightPets.isBossRushMode then
		self.fightPets:TryRefreshBossRushPetElement(petId)
	end
end

function PetManagementCtrl:onPetLevelChanged(info)
	local oldProp = {
		[Const.BASE_PROPERTY_HP_IDX] = {
			total = 0
		},
		[Const.BASE_PROPERTY_ATK_IDX] = {
			total = 0
		},
		[Const.BASE_PROPERTY_DEF_IDX] = {
			total = 0
		},
		[Const.BASE_PROPERTY_EP_REGEN_FORCE_IDX] = {
			total = 0
		},
		[Const.BASE_PROPERTY_DEF_MAG_IDX] = {
			total = 0
		},
		[Const.BASE_PROPERTY_ATK_MAG_IDX] = {
			total = 0
		}
	}

	if self.recordCurPetPropData then
		for k, v in pairs(self.recordCurPetPropData) do
			if oldProp[k] then
				oldProp[k].total = v
			end
		end
	end

	TimerManager.addTimer(0.2, function()
		local petId = info.petId

		self:tryRefreshFightPets(petId)
		self.boxPets:refreshPetList()
		self.boxPets:refreshBoxSelector()
		self.boxLists:refreshBoxList()
		self:showPetInfo(self.model:setUpPetInfo(pg.me:getPetInfo(petId)))

		local index = self.boxPets:getListIndexByPetId(petId)

		if index ~= nil then
			self.boxPets:refreshPetSelectedStatus(index)
		else
			index = self.fightPets:getListIndexByPetId(petId)

			if index ~= nil then
				self.fightPets:refreshPetSelectedStatus(index)
			end
		end

		info.oldProp = oldProp

		if info.oldLevel < info.newLevel then
			pg.global.ui:open(UIConst.UI_ID_PET_LEVEL_UP, info)
		end
	end)
end

function PetManagementCtrl:onPetFavoriteChanged(info)
	TimerManager.addNextFrameCb(function()
		local pet = self.player:getPetInfo(info[1])
		local petInfo = self.model:setUpPetInfo(pet)

		self.petDetails:resetBtnState(petInfo)
		self.boxPets:refreshSingleCardFavoriteState(info[1], info[2], petInfo)

		if self.inFilterMode then
			self.boxPets:refreshPetList()
		end

		self.fightPets:refreshFightList()
	end)
end

function PetManagementCtrl:onPetFavoriteTypeChanged(info)
	TimerManager.addNextFrameCb(function()
		local pet = self.player:getPetInfo(info[1])
		local petInfo = self.model:setUpPetInfo(pet)

		self.petDetails:resetBtnState(petInfo)
		self.boxPets:refreshSingleCardFavoriteState(info[1], petInfo.favoriteType, petInfo)

		if self.inFilterMode then
			self.boxPets:refreshPetList()
		end

		self.fightPets:refreshFightList()
		PetManagementUtils.onPetFavoriteChanged(pet)
	end)
end

function PetManagementCtrl:onPetCurAbilityChanged(info)
	local petId = info.petId

	if petId == self.model.curSelectPetId then
		self.petDetails:refreshSkillList(petId)
	end
end

function PetManagementCtrl:checkCurrentPetInfosContainsPet(isFight, exploreSlotIndex)
	return self.boxPets:checkCurrentPetInfosContainsPet(isFight, exploreSlotIndex)
end

function PetManagementCtrl:onPetHpChanged(info)
	return
end

function PetManagementCtrl:onExplorePetRevivePercentChanged(petInfoMessageBody)
	self.explorePets:onExplorePetRevivePercentChanged(petInfoMessageBody)
end

function PetManagementCtrl:highLightExploreSlot(resetAll, exploreSkillsData)
	self.explorePets:highLightExploreSlot(resetAll, exploreSkillsData)
end

function PetManagementCtrl:onPetMoveFinished(info)
	local moveRecords = self.toSwitchBoxPets
	local moveRecord, moveRecordId = self:getSwitchBoxPetsRecord(info.preBoxIndex, info.preSlotIndex, info.toBoxIndex, info.toSlotIndex, moveRecords)
	local isTimedOutRecord = false

	if not moveRecord then
		moveRecords = self:getTimedOutSwitchBoxPets()
		moveRecord, moveRecordId = self:getSwitchBoxPetsRecord(info.preBoxIndex, info.preSlotIndex, info.toBoxIndex, info.toSlotIndex, moveRecords)
		isTimedOutRecord = moveRecord ~= nil
	end

	if isTimedOutRecord then
		self:removeSwitchBoxPetsRecord(moveRecordId, moveRecord, moveRecords)

		return
	end

	self._petMoveFinishSeq = (self._petMoveFinishSeq or 0) + 1

	local moveFinishSeq = self._petMoveFinishSeq

	self:removeSwitchBoxPetsRecord(moveRecordId, moveRecord, moveRecords)

	local useFilterSafeCompletion = moveRecord and (moveRecord.inFilterModeAtDispatch or self.inFilterMode)

	if useFilterSafeCompletion then
		self.onMoveDisplay = true

		self.boxPets:disablePetsDrag()
		self:startTimer(function()
			if not self:canFinishPetMove(moveFinishSeq) then
				return
			end

			self.onMoveDisplay = false

			self.boxPets:clearNavMoveFocus()
			self.boxPets:enablePetsDrag()
		end, 0.2)

		return
	end

	local isSameBoxMove = info.preBoxIndex == info.toBoxIndex

	if isSameBoxMove then
		self.onMoveDisplay = true

		self.boxPets:disablePetsDrag()
		self:startTimer(function()
			if not self:canFinishPetMove(moveFinishSeq) then
				return
			end

			self.boxPets:refreshPetSelectedStatus(info.toSlotIndex - 1)

			self.onMoveDisplay = false

			self.boxPets:clearNavMoveFocus()
			self.boxPets:enablePetsDrag()
		end, 0.2)

		return
	end

	self.boxPets:playAniEventByBoxIndexAndSlotIndex(info.toBoxIndex, info.toSlotIndex)

	if info.isSwap then
		self.boxPets:playAniEventByBoxIndexAndSlotIndex(info.preBoxIndex, info.preSlotIndex)
	end

	self.onMoveDisplay = true

	self.boxPets:disablePetsDrag()

	local showMovedBoxAfterDrop = self:shouldShowMovedBoxAfterDrop(moveRecord)

	if not showMovedBoxAfterDrop then
		if self.model:getSelectBoxId() ~= info.preBoxIndex then
			self.boxPets:switchBoxToIdx(info.preBoxIndex)
		end

		self:startTimer(function()
			if not self:canFinishPetMove(moveFinishSeq) then
				return
			end

			self.onMoveDisplay = false

			self.boxPets:clearNavMoveFocus()
			self.boxPets:enablePetsDrag()
		end, 0.2)

		return
	end

	if self.model:getSelectBoxId() ~= info.toBoxIndex then
		self.boxPets:switchBoxToIdx(info.toBoxIndex)
	end

	self:startTimer(function()
		self.boxPets:refreshPetSelectedStatus(info.toSlotIndex - 1)
	end, 0.2)
	self:startTimer(function()
		self.boxPets:switchBoxToIdx(info.preBoxIndex)
	end, 1)
	self:startTimer(function()
		if not self:canFinishPetMove(moveFinishSeq) then
			return
		end

		self.onMoveDisplay = false

		self.boxPets:clearNavMoveFocus()
	end, 1.1)
	self:startTimer(function()
		if not self:canFinishPetMove(moveFinishSeq) then
			return
		end

		self.boxPets:enablePetsDrag()
	end, 1.2)
end

function PetManagementCtrl:event_CarryEquipped(info)
	if self.petDetails then
		self.petDetails:setCarryItem(info.petId)
		self:startTimer(function()
			self.petDetails:setTotalAttribute(info.petId)
			self.petDetails:previewMaxLevel()
		end, 0.2)
	end
end

function PetManagementCtrl:event_CarryUnload(info)
	if self.petDetails then
		self.petDetails:setCarryItem(info.petId)
		self:startTimer(function()
			self.petDetails:setTotalAttribute(info.petId)
			self.petDetails:previewMaxLevel()
		end, 0.2)
	end
end

function PetManagementCtrl:event_CarryCertify(info)
	if not info or info.petId ~= self.model.curSelectPetId or not self.petDetails then
		return
	end

	self.petDetails:setCarryItem(info.petId)
end

function PetManagementCtrl:onInputDeviceChanged()
	if pg.global.navMgr and pg.global.navMgr.IsDragging then
		pg.global.navMgr:CancelNavDragByBKey()
	end

	if self.petDetails then
		self.petDetails:onInputDeviceChanged()
	end

	self:refreshLeftPanelHotKeyVisible()
	self:refreshLeftPanelNavFocus()
end

function PetManagementCtrl:refreshLeftPanelHotKeyVisible()
	self:changeLeftPanelHotKeyVisible(false)
end

function PetManagementCtrl:changeLeftPanelHotKeyVisible(isVisible)
	if not pg.game.input:isUsingGamepad() then
		isVisible = false
	end
end

function PetManagementCtrl:onPetBreakThroughSuccess(info)
	if self.petDetails then
		local petInfo = pg.me:getPetInfo(info.petId)

		self.petDetails:refreshCanBreakThrough(petInfo.needBreakthrough)

		local index = self.boxPets:getListIndexByPetId(info.petId)

		if index ~= nil then
			self.boxPets:refreshPetSelectedStatus(index)
		else
			index = self.fightPets:getListIndexByPetId(info.petId)

			if index ~= nil then
				self.fightPets:refreshPetSelectedStatus(index)
			end
		end
	end
end

function PetManagementCtrl:dismiss()
	UICtrl.dismiss(self)
	self.model:clearOnDismiss()
end

function PetManagementCtrl:showNormalList(enable)
	if enable then
		self.view.boxPetNewList.transform.anchoredPosition = Vector2(-7, 41)
		self.view.boxPetFilterList.transform.anchoredPosition = Vector2(9999, -262)

		self:showBoxLock(self._preMidBoxLockStatusCode or 0, true)
	else
		self.view.boxPetNewList.transform.anchoredPosition = Vector2(9999, 41)
		self.view.boxPetFilterList.transform.anchoredPosition = Vector2(-7, -262)

		self:showBoxLock(0, true)
	end

	self.view.animationWidget:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)

	if self.boxPets then
		self.boxPets:applyMidListsNavInteractable(enable)
	end
end

function PetManagementCtrl:refreshTopRightTabList(info)
	self.m_openAutoSelectedTab = info and info.tab or 1

	local isHideOtherTab = info and info.hideOtherTab
	local tabListData = self.model:getTopRightTabUListData(isHideOtherTab)

	if tabListData and not self.m_topRightTabListFinished then
		function self.view.topRightTabUList.luaRenderItem(button, index, data)
			self:m_refreshTopRightTabItem(button, index, data)
		end

		self.view.topRightTabUList:SetList(tabListData)

		self.m_topRightTabListFinished = true
	end
end

function PetManagementCtrl:m_refreshTopRightTabItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local name1 = objectReference:GetRefValue("name1")
	local name2 = objectReference:GetRefValue("name2")

	ClientTextUtils.setText(name1, pg.getGameString(data.nameKey or ""))
	ClientTextUtils.setText(name2, pg.getGameString(data.nameKey or ""))

	function button.luaClick()
		self:switchManagementPages(index)
	end

	self.m_topRightTabItemList = self.m_topRightTabItemList or {}
	self.m_topRightTabItemList[index] = {
		button = button,
		data = data
	}

	self:_refreshTopRightTabsState()

	if self.m_openAutoSelectedTab == index + 1 then
		button:OnClickSimulate()

		self.m_openAutoSelectedTab = nil
	end
end

function PetManagementCtrl:refreshBoxListBtnHoverPro(val)
	self.boxPets:refreshOnDragPro(val)
end

function PetManagementCtrl:setTopRightTabsSwitchLocked(locked)
	if self.view and self.view.topRightTabUList then
		self.view.topRightTabUList:SetSwitchForceHidden(locked and true or false)
	end
end

function PetManagementCtrl:_refreshTopRightTabsState()
	local inReleaseMode = self.inReleaseMode == true

	self:setTopRightTabsSwitchLocked(inReleaseMode or self.isDragging == true)

	if not self.m_topRightTabItemList then
		return
	end

	for index, item in pairs(self.m_topRightTabItemList) do
		local button = item and item.button

		if button and not IsNil(button) then
			button:SetActive(not inReleaseMode)
		end
	end
end

function PetManagementCtrl:_refreshPvpAverage()
	local average = self.model.isPvp

	self.view.tipInfoUWidget:SetActive(average)
	self.view.tabBarUWidget:SetActive(not average)

	if average then
		local tipInfoRefObj = self.view.tipInfoUWidget:GetComponent("ObjectReference")
		local textTipsUSDFText = tipInfoRefObj:GetRefValue("textTipsUSDFText")
		local buttonUButton = tipInfoRefObj:GetRefValue("buttonUButton")

		ClientTextUtils.setText(textTipsUSDFText, pg.getGameString("PET_PVP_AVARAGE_TIP"))

		function buttonUButton.luaClick()
			pg.global.ui:open(UIConst.UI_ID_HELP, {
				helpId = SysConfigData.PET_PVP_AVARAGE_HELP_ID or 1
			})
		end
	end
end

function PetManagementCtrl:getPetBoxPosition(petId)
	local petBoxMap = pg and pg.me and pg.me.petBoxMap

	if not petBoxMap then
		return nil, nil
	end

	for boxIndex = 1, #petBoxMap do
		local petBox = petBoxMap[boxIndex]

		if petBox then
			for slotIndex = 1, petBox.slotCount do
				if petBox[slotIndex] == petId then
					return boxIndex, slotIndex
				end
			end
		end
	end

	return nil, nil
end

function PetManagementCtrl:hasSwitchBoxPetsRecord()
	return self.toSwitchBoxPets ~= nil and next(self.toSwitchBoxPets) ~= nil
end

function PetManagementCtrl:getTimedOutSwitchBoxPets()
	local uid = pg and pg.me and pg.me.uid

	if not uid then
		return nil
	end

	local timedOutRecords = PetManagementCtrl.timedOutSwitchBoxPetsByUid[uid]

	if not timedOutRecords then
		timedOutRecords = {}
		PetManagementCtrl.timedOutSwitchBoxPetsByUid[uid] = timedOutRecords
	end

	local expiredRecordIds = {}

	for recordId, record in pairs(timedOutRecords) do
		if not record.tombstoneExpireAt or record.tombstoneExpireAt <= Time.millisecondCache then
			table.insert(expiredRecordIds, recordId)
		end
	end

	for _, recordId in ipairs(expiredRecordIds) do
		timedOutRecords[recordId] = nil
	end

	return timedOutRecords
end

function PetManagementCtrl:moveActiveSwitchBoxPetsToTombstones(expectedDispatchSeq)
	if expectedDispatchSeq and self._activePetMoveDispatchSeq ~= expectedDispatchSeq then
		return false
	end

	if not self:hasSwitchBoxPetsRecord() then
		return false
	end

	local timedOutRecords = self:getTimedOutSwitchBoxPets()

	if not timedOutRecords then
		return false
	end

	for recordId, record in pairs(self.toSwitchBoxPets) do
		record.tombstoneExpireAt = Time.millisecondCache + self.PET_MOVE_TOMBSTONE_TTL_MS
		timedOutRecords[recordId] = record
	end

	self.toSwitchBoxPets = {}
	self._activePetMoveDispatchSeq = nil

	return true
end

function PetManagementCtrl:recordSwitchBoxPets(petIds, targetBoxIndexes, targetSlotIndexes, showMovedBoxAfterDrop)
	if self:hasSwitchBoxPetsRecord() then
		return false
	end

	local timedOutRecords = self:getTimedOutSwitchBoxPets()
	local preparedRecords = {}

	for i, petId in ipairs(petIds) do
		local preBoxIndex, preSlotIndex = self:getPetBoxPosition(petId)

		if not preBoxIndex or not preSlotIndex then
			return false
		end

		local targetBoxIndex = targetBoxIndexes[i]
		local targetSlotIndex = targetSlotIndexes[i]
		local timedOutRecord = self:getSwitchBoxPetsRecord(preBoxIndex, preSlotIndex, targetBoxIndex, targetSlotIndex, timedOutRecords)

		if timedOutRecord then
			return false
		end

		preparedRecords[i] = {
			petId = petId,
			preBoxIndex = preBoxIndex,
			preSlotIndex = preSlotIndex,
			boxIndex = targetBoxIndex,
			slotIndex = targetSlotIndex
		}
	end

	self.toSwitchBoxPets = {}
	self._petMoveDispatchSeq = (self._petMoveDispatchSeq or 0) + 1

	local dispatchSeq = self._petMoveDispatchSeq

	self._activePetMoveDispatchSeq = dispatchSeq

	for _, preparedRecord in ipairs(preparedRecords) do
		PetManagementCtrl._switchBoxPetRecordSeq = PetManagementCtrl._switchBoxPetRecordSeq + 1

		local recordId = PetManagementCtrl._switchBoxPetRecordSeq

		self.toSwitchBoxPets[recordId] = {
			petId = preparedRecord.petId,
			recordSeq = recordId,
			dispatchSeq = dispatchSeq,
			preBoxIndex = preparedRecord.preBoxIndex,
			preSlotIndex = preparedRecord.preSlotIndex,
			boxIndex = preparedRecord.boxIndex,
			slotIndex = preparedRecord.slotIndex,
			showMovedBoxAfterDrop = showMovedBoxAfterDrop ~= false,
			inFilterModeAtDispatch = self.inFilterMode == true
		}
	end

	self.onMoveDisplay = true

	self.boxPets:disablePetsDrag()
	self:startTimer(function()
		if not self:moveActiveSwitchBoxPetsToTombstones(dispatchSeq) then
			return
		end

		self._petMoveFinishSeq = (self._petMoveFinishSeq or 0) + 1
		self.onMoveDisplay = false

		self.boxPets:clearNavMoveFocus()
		self.boxPets:enablePetsDrag()
	end, self.PET_MOVE_REQUEST_TIMEOUT)

	return true
end

function PetManagementCtrl:getSwitchBoxPetsRecord(preBoxIndex, preSlotIndex, toBoxIndex, toSlotIndex, records)
	if not records then
		return nil, nil
	end

	local matchedRecord, matchedRecordId

	for recordId, record in pairs(records) do
		if record.preBoxIndex == preBoxIndex and record.preSlotIndex == preSlotIndex and record.boxIndex == toBoxIndex and record.slotIndex == toSlotIndex and (not matchedRecord or record.recordSeq < matchedRecord.recordSeq) then
			matchedRecord = record
			matchedRecordId = recordId
		end
	end

	return matchedRecord, matchedRecordId
end

function PetManagementCtrl:shouldShowMovedBoxAfterDrop(moveRecord)
	if not moveRecord then
		return true
	end

	return moveRecord.showMovedBoxAfterDrop ~= false
end

function PetManagementCtrl:removeSwitchBoxPetsRecord(recordId, expectedRecord, records)
	if not records or not recordId then
		return
	end

	if records[recordId] ~= expectedRecord then
		return
	end

	records[recordId] = nil

	if records == self.toSwitchBoxPets and not self:hasSwitchBoxPetsRecord() then
		self._activePetMoveDispatchSeq = nil
	end
end

function PetManagementCtrl:canFinishPetMove(moveFinishSeq)
	return self._petMoveFinishSeq == moveFinishSeq and not self:hasSwitchBoxPetsRecord()
end

function PetManagementCtrl:showBoxLock(lockStatusCode, notRecord)
	self.view.midPanelUComponent:TryChangePage("Lock", lockStatusCode)

	if notRecord then
		return
	end

	self._preMidBoxLockStatusCode = lockStatusCode
end

function PetManagementCtrl:onPetPropLearnChange(info)
	self:refreshAll()
end

function PetManagementCtrl:onPetInheritChange(info)
	self:refreshAll()
end

function PetManagementCtrl:onPetCarryLockChange(retInfo)
	self.petDetails:refreshOnCarryLockChange(retInfo.isLocked)
end

function PetManagementCtrl:onPetTransmogSchemeApplied()
	if self.petDetails then
		self.petDetails:tryRefreshPetPreview(true)
	end
end

function PetManagementCtrl:pauseUIScene()
	if self.uiScene then
		self.uiScene:pauseTargetTexture()
	end
end

function PetManagementCtrl:onSystemFunctionUnlocked(info)
	if self.petDetails then
		self.petDetails:refreshGotoCultivateUIBtnsActive()
	end
end

return PetManagementCtrl
