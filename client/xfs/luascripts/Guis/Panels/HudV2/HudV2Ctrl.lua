-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HudV2\\HudV2Ctrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("HudV2Ctrl")
local MessageName = require("Const.MessageName")
local HudSplicingCfg = require("Guis.Panels.HudV2.HudSplicingCfg")
local ClientConst = require("Const.ClientConst")
local UIConst = require("Const.UIConst")
local Class = require("Core.Framework.Class")
local MapHelper = require("GameApp.Map.MapHelper")
local Const = require("Common.Const.Const")
local ClientUtils = require("Utils.ClientUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientCashShopUtils = require("Utils.ClientCashShopUtils")
local CommonSwitch = require("Common.CommonSwitch")
local NoticeDef = require("Common.NoticeDef")
local Utils = require("Common.Utils.Utils")
local PetResearchUtils = require("Guis.Utils.PetResearchUtils")
local QuestUtils = require("GameApp.Quest.QuestUtils")
local PhotoUIComponent = require("Guis.Panels.HudV2.BaseComponent.PhotoUIComponent")
local FuncIdConfigData = require("Data.func_index_config_data")
local RedDotConst = require("Const.RedDotConst")
local ConflictTypes = require("Common.ConflictTypes")
local HotkeyConst = require("Const.HotkeyConst")
local EventConst = require("Const.EventConst")
local MapAreaConfigData = require("Data.map_area_config_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local BuffConfigData = require("Data.buff_config_data")
local SDKLoginConfig = require("SDK.SDKLoginConfig")
local TipAreaConst = require("Guis.Panels.Tips.TipAreaConst")
local AbilityConst = require("Common.Const.AbilityConst")
local GmToolUtils = require("Utils.GmToolUtils")
local HelpCenterParamsUtils = require("Utils.HelpCenterParamsUtils")
local RechargeUtils = require("GameApp.Recharge.RechargeUtils")
local BossRushUtils = require("Utils.BossRushUtils")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local PlatformBridgeLuaFacade = CS.FunPlus.WorldX.SDK.Platform.PlatformBridgeLuaFacade
local ControllerData = CS.FunPlus.WorldX.ControllerData
local SNEAK_MODE_TRANSITION_TIME = 0.3
local UICtrl = require("Guis.UICtrl")
local HudV2Ctrl = Class.LightClass("HudV2Ctrl", UICtrl)

HudV2Ctrl.messages = {
	[MessageName.CATCH_MODE_CHANGE_UI] = {
		"onCatchModeChange",
		true
	},
	[MessageName.MAGNESIS_MODE_CHANGE] = {
		"onMagnesisModeChange",
		true
	},
	[MessageName.MAGNESIS_SWITCH_BEHAVIOR] = {
		"onMagnesisBehaviorChange",
		true
	},
	[MessageName.SKILL_FREE_AIM] = {
		"onFreeAimModeChange",
		true
	},
	[MessageName.ON_SYSTEM_FUNCTION_UNLOCKED] = {
		"onSystemFunctionUnlocked",
		true
	},
	[MessageName.ON_SCHOOL_GUIDE_RED_DOT_CHANGED] = {
		"onSchoolGuideRedDotChanged",
		true
	},
	[MessageName.SCENE_LOADED] = {
		"onSceneLoaded",
		true
	},
	[MessageName.VEHICLE_SHOW_STATE_CHANGED] = {
		"onVehicleShowStateChanged",
		true
	},
	[MessageName.CHARACTER_STATE_CHANGED] = {
		"onCharacterStateChangedForVehicle",
		true
	},
	[MessageName.CHANGE_MAP_LAYER_DATA] = {
		"onChangeMapLayerData",
		true
	},
	[MessageName.SOCIAL_BUFF_CHANGE] = {
		"onSocialBuffChange",
		true
	},
	[MessageName.HIGH_GRASS_STATE_CHANGE] = {
		"refreshSneakHint",
		true
	},
	[MessageName.UI_ON_SHOW] = {
		"onHandleOnShowUI",
		true
	},
	[MessageName.UI_ON_HIDE] = {
		"onHandleOnHideUI",
		true
	},
	[MessageName.ON_CONTROL_ENT_CHANGED] = {
		"onControlEntChanged",
		true
	},
	[MessageName.ENTER_LIFE_FALLEN] = {
		"onEnterFallen",
		true
	},
	[MessageName.ENTER_LIFE_ALIVE] = {
		"onEnterAlive",
		true
	},
	[MessageName.ENTER_FALLEN_AID] = {
		"onEnterFallenAid",
		true
	},
	[MessageName.EXIT_FALLEN_AID] = {
		"onExitFallenAid",
		true
	},
	[MessageName.ENTER_PHOTO_AI_TRAIT] = {
		"enterPhotoAITrait",
		true
	},
	[MessageName.LEAVE_PHOTO_AI_TRAIT] = {
		"leavePhotoAITrait",
		true
	},
	[MessageName.AI_PHOTO_TRAIT_START] = {
		"onAITraitStart",
		true
	},
	[MessageName.AI_PHOTO_TRAIT_END] = {
		"onAITraitEnd",
		true
	},
	[MessageName.PET_RESEARCH_SKILL_UNLOCK_BY_ITEM] = {
		"onItemUnlockResearchSkill",
		true
	},
	[MessageName.MAP_AREA_ACTIVE] = {
		"onMapAreaActive",
		true
	},
	[MessageName.ON_PLAYER_ENTER_SCENE] = {
		"onPlayerEnterScene",
		true
	}
}

function HudV2Ctrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.unlockFuncDatas = {}
	self.curUnlockFuncId = nil
	self.needShowAddPetData = {}
	self.needShowAddItemData = {}
	self._baseComponentVisibleStateByReason = {}
end

function HudV2Ctrl:addListener()
	self:initHotKeys()
end

function HudV2Ctrl:onDestroy()
	if self._sneakModeActive then
		pg.global.cameraMgr:StopSneakMode(0)
	end

	self._sneakModeActive = nil
	self.quickPhoto = nil
	self._baseComponentVisibleStateByReason = nil

	UICtrl.onDestroy(self)

	for _, componentName in pairs(HudSplicingCfg.LayoutName) do
		self[componentName] = nil
	end
end

function HudV2Ctrl:onCatchModeChange(enable)
	local captureEntryGestureActive = enable and self:isCaptureEntryGestureActive()

	if enable then
		if self.RD and self.RD.interactGesture then
			self.RD.interactGesture:closeForCatchMode()
		end

		if not pg.game.controller:isInControlMainPlayer() or GmToolUtils and GmToolUtils.captureProbabilityHide then
			return
		end

		if not captureEntryGestureActive and not self:checkFastThrowMode() then
			self:hide()
		end

		self:leaveSimpleChatMode()
	else
		self:show()
		self:setIsInAim(false)
	end

	if not captureEntryGestureActive then
		self:refreshThrowItem()
	end

	self:refreshInteractGestureBtnState()
end

function HudV2Ctrl:onMagnesisModeChange(enable)
	if enable then
		self:hide()

		pg.global.ui.crawl.isInMagnesis = true
	else
		self:show()
		self:setIsInAim(false)
	end

	self:refreshInteractGestureBtnState()
end

function HudV2Ctrl:onMagnesisBehaviorChange(isThrow)
	if not pg.game.controller:isInControlMainPlayer() then
		return
	end

	if isThrow then
		self:setIsInAim(false)
	end
end

function HudV2Ctrl:onFreeAimModeChange(enable)
	if enable then
		self:hide()

		pg.global.ui.crawl.isInMagnesis = false

		pg.global.ui.crawl:openOrShow()
	else
		self:show()
		self:setIsInAim(false)
	end
end

function HudV2Ctrl:onOpen(info)
	UICtrl.onOpen(self, info)

	local hudName

	if info and info.isOffline then
		hudName = HudSplicingCfg.HudType.OffLine
	else
		hudName = self:getHudName()

		if not self.quickPhoto then
			self.quickPhoto = PhotoUIComponent.new(self)
		end
	end

	self:splicingViewComponent(hudName)

	if pg.me and pg.me.life == Const.LIFE_FALLEN then
		self:onEnterFallen()
	end
end

function HudV2Ctrl:onVisibleChange(visible)
	if visible then
		self:tryPlayFuncUnlock()
		self:tryShowAddPet()
		self:tryShowAddItem()
		self.view.rootComponent:InvokeCallback(CS.XGUI.EInvokeTime.Show)
	elseif self.RM and self.RM.petList then
		self.RM.petList:onTriggerCloseQuickSwitchPanel(false)
	end

	self:notifyLayoutComponents(visible)
end

function HudV2Ctrl:splicingViewComponent(hudName)
	local isMobile = pg.global.ui:runPlatformByMobile()

	for _, hudTypeName in pairs(HudSplicingCfg.LayoutName) do
		local cfg = HudSplicingCfg.SceneConfig[hudName]

		cfg = cfg[hudTypeName] or HudSplicingCfg.SceneConfig[HudSplicingCfg.HudType.World][hudTypeName]

		if not cfg.isEmpty then
			local module

			if isMobile then
				module = self:getMobileModule(hudName, hudTypeName)
			else
				module = self:getModule(hudName, hudTypeName)
			end

			if module and not self[hudTypeName] then
				self[hudTypeName] = module.new(self, nil, {
					isFixRoot = true,
					hudName = hudName,
					hudTypeName = hudTypeName
				})
			end
		end
	end
end

function HudV2Ctrl:getModule(hudName, hudTypeName)
	local componentName = string.format("%s%s", hudName, hudTypeName)
	local module
	local ok, result = pcall(require, string.format("Guis.Panels.HudV2.%s.%sComponent", hudName, componentName))

	if ok and result then
		module = result
	else
		componentName = string.format("Base%s", hudTypeName)
		ok, result = pcall(require, string.format("Guis.Panels.HudV2.BaseLayoutComponent.%sComponent", componentName))

		if ok and result then
			module = result
		else
			logger:warn(string.format("Component not found: %sComponent", componentName))
		end
	end

	return module
end

function HudV2Ctrl:getMobileModule(hudName, hudTypeName)
	if pg.global.sdkManager:isDouyinCloudChannel() and hudName == HudSplicingCfg.HudType.World and hudTypeName == HudSplicingCfg.LayoutName.LU then
		local ok, result = pcall(require, "Guis.Panels.HudV2.BaseLayoutComponent.BaseLUComponent")

		if ok and result then
			return result
		end

		logger:warn("Component not found: BaseLUComponent")

		return nil
	end

	local componentName = string.format("Mobile%s%s", hudName, hudTypeName)
	local module
	local ok, result = pcall(require, string.format("Guis.Panels.HudV2.%s.%sComponent", hudName, componentName))

	if ok and result then
		module = result
	else
		componentName = string.format("%s%s", hudName, hudTypeName)
		ok, result = pcall(require, string.format("Guis.Panels.HudV2.%s.%sComponent", hudName, componentName))

		if ok and result then
			module = result
		else
			componentName = string.format("MobileBase%s", hudTypeName)
			ok, result = pcall(require, string.format("Guis.Panels.HudV2.BaseLayoutComponent.%sComponent", componentName))

			if ok and result then
				module = result
			else
				componentName = string.format("Base%s", hudTypeName)
				ok, result = pcall(require, string.format("Guis.Panels.HudV2.BaseLayoutComponent.%sComponent", componentName))

				if ok and result then
					module = result
				else
					logger:warn(string.format("Component not found: %sComponent", componentName))
				end
			end
		end
	end

	return module
end

function HudV2Ctrl:getHudName()
	local sceneId = pg.space and pg.space.sceneId or pg.global.scene.targetSceneId

	if sceneId == 501 then
		return HudSplicingCfg.HudType.Ark
	elseif sceneId == 3007 then
		return HudSplicingCfg.HudType.OffLine
	elseif pg.me and pg.me.space and pg.me.space:isHomeland() and pg.me.space:isSelfHomeland(pg.me) then
		return HudSplicingCfg.HudType.HomeLand
	else
		return HudSplicingCfg.HudType.World
	end
end

function HudV2Ctrl:hideBaseComponent(hudTypeName, whiteList, reason)
	local layoutComponent = self[hudTypeName]

	if layoutComponent and layoutComponent.hideChildComponents then
		layoutComponent:hideChildComponents(whiteList, reason)
	end
end

function HudV2Ctrl:showBaseComponent(hudTypeName, whiteList, reason)
	local layoutComponent = self[hudTypeName]

	if layoutComponent and layoutComponent.showChildComponents then
		layoutComponent:showChildComponents(whiteList, reason)
	end
end

function HudV2Ctrl:hideBaseComponentsWithState(componentNames, reason)
	if not reason or not componentNames or #componentNames == 0 then
		return
	end

	local stateByReason = self._baseComponentVisibleStateByReason

	if not stateByReason or stateByReason[reason] then
		return
	end

	local componentNameSet = {}

	for _, componentName in ipairs(componentNames) do
		componentNameSet[componentName] = true
	end

	local components = {}

	for _, layoutName in pairs(HudSplicingCfg.LayoutName) do
		local layoutComponent = self[layoutName]

		if layoutComponent and componentNameSet[layoutName] then
			components[#components + 1] = layoutComponent
		elseif layoutComponent and layoutComponent.uiComponents then
			for _, component in ipairs(layoutComponent.uiComponents) do
				if component and componentNameSet[component.compName] then
					components[#components + 1] = component
				end
			end
		end
	end

	local state = {
		hiding = true,
		visibleState = {}
	}

	stateByReason[reason] = state

	for _, component in ipairs(components) do
		state.visibleState[component] = component._visible

		component:tryHide(reason)

		if state.restoreRequested then
			break
		end
	end

	state.hiding = false

	if state.restoreRequested then
		self:restoreBaseComponentsState(reason)
	end
end

function HudV2Ctrl:restoreBaseComponentsState(reason)
	local stateByReason = self._baseComponentVisibleStateByReason
	local state = stateByReason and stateByReason[reason]

	if not state then
		return
	end

	if state.hiding then
		state.restoreRequested = true

		return
	end

	if state.restoring then
		return
	end

	state.restoring = true

	for component, wasVisible in pairs(state.visibleState) do
		if component.hideState then
			if wasVisible then
				component:tryShow(reason)
			else
				component.hideState[reason] = false
			end
		end
	end

	if stateByReason[reason] == state then
		stateByReason[reason] = nil
	end
end

function HudV2Ctrl:checkCanOpenFuncMenu()
	if self.RU and self.RU.funcList then
		return self.RU.funcList.canOpenFuncMenu
	end

	return false
end

function HudV2Ctrl:onShow()
	self:showUIDAndVersion()
end

function HudV2Ctrl:onHide()
	return
end

function HudV2Ctrl:notifyLayoutComponents(visible)
	for _, layoutName in pairs(HudSplicingCfg.LayoutName) do
		local layout = self[layoutName]

		if layout then
			if visible then
				layout:playShowAnim()
			else
				layout:playHideAnim()
			end

			if layout.uiComponents then
				for _, comp in ipairs(layout.uiComponents) do
					if visible then
						if comp.onParentShow then
							comp:onParentShow()
						end
					elseif comp.onParentHide then
						comp:onParentHide()
					end
				end
			end
		end
	end
end

function HudV2Ctrl:showUIDAndVersion()
	local me = pg.me

	if self.view then
		ClientTextUtils.setText(self.view.uIDUSDFText, string.format("UID: %s", me.uid))
	end
end

function HudV2Ctrl:initHotKeys()
	self:bindHotKeyOverride(Const.FUNCTION_IDS.MAP, "MAP", nil, false, function()
		self:openMap()
	end)
	self:bindHotKeyOverride(Const.FUNCTION_IDS.PETENTRY, "PETENTRY", nil, true, function()
		self:openPetPanel()
	end)
	self:bindHotKeyOverride(Const.FUNCTION_IDS.BAG, "BAG", nil, true, function()
		self:openBag()
	end)
	self:bindHotKeyOverride(Const.FUNCTION_IDS.PETRESEARCH, "PETRESEARCH", nil, false, function()
		self:openPetResearch()
	end)
	self:bindHotKeyOverride(Const.FUNCTION_IDS.QUEST, "QUEST", nil, false, function()
		self:openQuest()
	end)
	self:bindHotKeyOverride(Const.FUNCTION_IDS.PLAYERENHANCEMENT, "PLAYERENHANCEMENT", nil, true, function()
		self:openPlayerEnhance()
	end)
	self:bindHotKeyOverride(Const.FUNCTION_IDS.HELP, "HELP", nil, false, function()
		pg.global.ui:open(UIConst.UI_ID_HELP)
	end)
	self:bindHotKeyOverride(Const.FUNCTION_IDS.PVP, "PVP", nil, false, function()
		self:openPvpMenu()
	end)
	self:bindHotKeyOverride(Const.FUNCTION_IDS.CASHSHOP, "ShopMall_All", nil, false, function()
		self:openCashShop()
	end)

	local serviceBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.transform.gameObject, "Service")

	serviceBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.Service
	serviceBind.isVirtual = true

	function serviceBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self:openServicePanel()
		end
	end

	local catchModeBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.transform.gameObject, "SwitchCatch")

	catchModeBind.actionPath = "Catch/SwitchCatchMode"
	catchModeBind.isVirtual = true

	function catchModeBind.luaTrigger(inputInfo)
		if not self.LD or not self.LD.ball then
			return
		end

		local ball = self.LD.ball
		local useGamepadHold = pg.game.input:isUsingGamepad() and pg.game.setting:getHoldToEnterCatchMode()

		if useGamepadHold then
			if inputInfo.phase == "Performed" and LuaUIUtils.isUIViewVisible(ball.uWidget) then
				ball:handleSwitchCatchModeAction(true)
			elseif inputInfo.phase == "Canceled" then
				ball:handleSwitchCatchModeAction(false)
			end
		elseif inputInfo.phase == "Performed" and LuaUIUtils.isUIViewVisible(ball.uWidget) then
			ball:handleSwitchCatchModeAction()
		end
	end
end

function HudV2Ctrl:performFunctionHotKey(funcId, funcName, func)
	if not pg.me:checkFunctionUnlock(funcName) then
		return
	end

	if not CommonSwitch[funcName] then
		pg.global.showBubbleMessage(NoticeDef.COMMON_SWITCH_CLOSE_TIP)

		return
	end

	if pg.me:MAGNESIS_READY_ST() or pg.me:MAGNESIS_ST() then
		return
	end

	if LuaUIUtils.checkFuncForbidden(funcId) then
		if pg.global.ui:checkUIOpen(UIConst.UI_ID_FUNC_MENU) then
			pg.global.ui.tips:showTextTip(pg.getGameString("FUNCTION_CANT_STATE"))
		end

		return
	end

	func()
end

function HudV2Ctrl:tryOpenMapByHotKey()
	self:performFunctionHotKey(Const.FUNCTION_IDS.MAP, "MAP", function()
		self:openMap()
	end)
end

function HudV2Ctrl:bindHotKeyOverride(funcId, funcName, actionPath, special, func)
	actionPath = actionPath or LuaUIUtils.getFuncActionPath(funcId)

	if not actionPath then
		return
	end

	local openSetupBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.transform.gameObject, actionPath)

	openSetupBind.actionPath = actionPath
	openSetupBind.isVirtual = true

	function openSetupBind.luaTrigger(inputInfo)
		if inputInfo.phase ~= "Performed" then
			return
		end

		self:performFunctionHotKey(funcId, funcName, func)
	end
end

function HudV2Ctrl:commonOpenFunc(funcId)
	if not LuaUIUtils.checkFuncUnlock(funcId) then
		return
	end

	if LuaUIUtils.checkFuncForbidden(funcId) then
		pg.global.ui.tips:showTextTip(pg.getGameString("FUNCTION_CANT_STATE"))

		return
	end

	if funcId == Const.FUNCTION_IDS.MAP then
		self:openMap()
	elseif funcId == Const.FUNCTION_IDS.PLAYERENHANCEMENT then
		self:openPlayerEnhance()
	end
end

function HudV2Ctrl:openMap()
	if pg.me == nil or pg.me.space == nil then
		return
	end

	if not pg.game:checkModuleEnable(ClientConst.ModuleKey.Map) then
		return
	end

	if pg.game.map:checkValidScene(pg.game.map:convertSceneId(pg.me.space.sceneId)) == true then
		pg.global.ui.map:open()
	else
		local forceOpen = MapHelper.checkMapForceOpen(pg.me.space.sceneId)

		if forceOpen then
			pg.global.ui:open(UIConst.UI_ID_MAP, {
				forceSceneId = ClientConst.SCENE_ARK
			})

			return
		end

		pg.global.showBubbleMessageById(2126)
	end
end

function HudV2Ctrl:openPetPanel()
	if pg.me == nil or pg.me.space == nil then
		return
	end

	if pg.me.space:isRogueEnv() then
		pg.global.ui:open(UIConst.UI_ID_TOWER_STAGE_INFO)
	elseif Utils.isPlayerInSpaceCatchRogueDungeon(pg.me) then
		pg.global.ui:open(UIConst.UI_ID_CATCH_ROGUE_PET_BAG)
	elseif pg.me.space:isHomeland() then
		pg.global.ui:open(UIConst.UI_ID_PET_MANAGEMENT, {
			subTab = 3
		})
	else
		pg.global.ui:open(UIConst.UI_ID_PET_MANAGEMENT)
	end
end

function HudV2Ctrl:openBag()
	if pg.me == nil or pg.me.space == nil then
		return
	end

	if pg.me.space:isGrabEgg() then
		pg.global.ui:open(UIConst.UI_ID_GRAB_EGGS_BAG, {
			items = pg.me:getNearbyCollectionList(),
			bagType = UIConst.GRAB_EGG_BAG_TYPE.NEARBY_ITEM,
			name = pg.getGameString("GRAB_EGG_NEARBY_ITEM")
		})
	else
		pg.global.ui.inventory:open()
	end
end

function HudV2Ctrl:openPetResearch(info)
	PetResearchUtils.openPetResearch(info)
end

function HudV2Ctrl:openQuest()
	if not pg.game:checkModuleEnable(ClientConst.ModuleKey.Quest) then
		return
	end

	pg.global.ui:open(UIConst.UI_ID_QUEST_PANEL, {
		QuestUtils.getTracingFinishedQuestType()
	})
end

function HudV2Ctrl:openPlayerEnhance()
	LuaUIUtils.openPlayerEnhance()
end

function HudV2Ctrl:openCashShop()
	if not ClientCashShopUtils.canOpenCashShop() then
		return
	end

	if pg.global.platform:isPS() and RechargeUtils.isEmptyStore() then
		PlatformBridgeLuaFacade.ShowCommonMessageDialogEmptyStore()

		return
	end

	if pg.me and pg.me:isInFishingCapture() then
		pg.global.ui:open(UIConst.UI_ID_CASH_SHOP, {
			fromPage = "main_menu",
			tabId = 5,
			showTabs = {
				3,
				5,
				7
			}
		})
	else
		pg.global.ui:open(UIConst.UI_ID_CASH_SHOP, {
			fromPage = "main_menu"
		})
	end
end

function HudV2Ctrl:getCurSelectPropId()
	if pg.global.ui:runPlatformByMobile() then
		if self.RD and self.RD.ballBtn then
			return self.RD.ballBtn:getCurSelectPropId()
		else
			local itemList = self.model:getCapturePropInfos()

			if #itemList > 0 then
				return itemList[1].itemId
			end
		end
	elseif self.LD and self.LD.ball then
		return self.LD.ball:getCurSelectPropId()
	else
		local itemList = self.model:getCapturePropInfos()

		if #itemList > 0 then
			return itemList[1].itemId
		end
	end
end

function HudV2Ctrl:checkFastThrowMode()
	if self.RD and self.RD.ballBtn then
		return self.RD.ballBtn:checkFastThrowMode()
	end

	return false
end

function HudV2Ctrl:isCaptureEntryGestureActive()
	local ballBtn = self.RD and self.RD.ballBtn

	return ballBtn and ballBtn:isCaptureEntryGestureActive() or false
end

function HudV2Ctrl:dungeonHideOtherUI()
	for _, id in ipairs(UIConst.DungeonCloseUI) do
		if pg.global.ui:checkUIOpen(id) then
			pg.global.ui:close(id, true)
		end
	end
end

function HudV2Ctrl:openSpecialTrain()
	pg.global.ui:open(UIConst.UI_ID_OPEN_SPECIAL_TRAIN_PANEL, nil, nil, nil, {
		textureWidth = 1400,
		textureHeight = 1400
	})
end

function HudV2Ctrl:openPhotoPanel(preset, snapshot)
	if self.LD then
		self.LD:openPhotoPanel(preset, snapshot)
	end
end

function HudV2Ctrl:openPetBall(param)
	if param and param.openHatch then
		pg.global.ui:open(UIConst.UI_ID_PET_FERTILITY, param, function()
			pg.global.ui.petFertility:additionOperation()
		end)
	else
		pg.global.ui:open(UIConst.UI_ID_PET_FERTILITY, param, function()
			if param then
				pg.global.ui.petFertility:additionOperation()
			end
		end)
	end
end

function HudV2Ctrl:openPvpMenu()
	LuaUIUtils.openPVPMenu()
end

function HudV2Ctrl:changeGmBtnVisible(visible)
	if self.RU and self.RU.funcList then
		self.RU.funcList:changeGmBtnVisible(visible)
	end
end

function HudV2Ctrl:refreshBossRushInfo()
	if self.LU and self.LU.bossRushBtnInfo then
		self.LU.bossRushBtnInfo:refreshBossRushInfo()
	end

	if self.LU and self.LU.bossRushInfo then
		self.LU.bossRushInfo:refreshBossRushInfo()
	end

	if self.RU and self.RU.funcList then
		self.RU.funcList:refreshFuncListBtn()
	end
end

function HudV2Ctrl:delayShowBossRushUpdate(data)
	self.bossRushUpdateData = data
end

function HudV2Ctrl:tryShowBossRushUpdate()
	if self.bossRushUpdateData then
		pg.global.ui:open(UIConst.UI_ID_BOSS_RUSH_SETTLEMENT, self.bossRushUpdateData)

		self.bossRushUpdateData = nil
	end
end

function HudV2Ctrl:onPlayerEnterScene()
	self:startTimer(function()
		self:tryShowBossRushUpdate()
		self:tryOpenTowerMain()
	end, 1)
end

function HudV2Ctrl:enterPhotoAITrait(data)
	if self.quickPhoto then
		self.quickPhoto:enterPhotoAITrait(data)
	end
end

function HudV2Ctrl:leavePhotoAITrait(data)
	if self.quickPhoto then
		self.quickPhoto:leavePhotoAITrait(data)
	end
end

function HudV2Ctrl:onAITraitStart(data)
	if self.quickPhoto then
		self.quickPhoto:onAITraitStart(data)
	end
end

function HudV2Ctrl:onAITraitEnd(data)
	if self.quickPhoto then
		self.quickPhoto:onAITraitEnd(data)
	end
end

function HudV2Ctrl:tryClearCurPhotoAiTrait()
	if self.quickPhoto then
		self.quickPhoto:tryClearCurPhotoAiTrait()
	end
end

function HudV2Ctrl:onItemUnlockResearchSkill(info)
	PetResearchUtils.openPetResearchDetail(info)
end

function HudV2Ctrl:onMapAreaActive(info)
	if info.sceneId ~= pg.game.map:convertSceneId(pg.me.space.sceneId) then
		return
	end

	for _, v in pairs(MapAreaConfigData) do
		if v.Campid == info.markId then
			pg.me:uploadMapFogToServer()
			pg.global.eventEmitter:emit(EventConst.ON_MAP_AREA_UNLOCK, v.areaName)

			break
		end
	end
end

function HudV2Ctrl:onSystemFunctionUnlocked(name)
	local data = FuncIdConfigData[name] or {}

	if data.entrance == nil then
		return
	end

	table.insert(self.unlockFuncDatas, data)
	self:startTimer(function()
		if self.curUnlockFuncId == nil then
			self:showFuncMenuUnlock(self.unlockFuncDatas[1])
		end
	end, 0.1)
end

function HudV2Ctrl:showFuncMenuUnlock(data)
	if pg.global.ui:checkUIOpen(UIConst.UI_ID_FUNC_MENU_UNLOCK) or pg.global.ui:checkUIVisible(UIConst.UI_ID_PLAYER_ASSESS) then
		return
	end

	if data and data.entrance then
		self.curUnlockFuncId = data.entrance[2]

		pg.global.ui:open(UIConst.UI_ID_FUNC_MENU_UNLOCK, {
			entrance = data.entrance,
			helpId = data.helpId,
			guideGroupId = data.guideGroupId,
			dialogueGraphId = data.dialogueGraphId
		})
	end
end

function HudV2Ctrl:tryPlayFuncUnlock()
	if self.curUnlockFuncId == nil and self.unlockFuncDatas and #self.unlockFuncDatas > 0 then
		self:showFuncMenuUnlock(self.unlockFuncDatas[1])
	end
end

function HudV2Ctrl:removeCurUnlockFunc()
	if self.curUnlockFuncId then
		self.curUnlockFuncId = nil

		if self.unlockFuncDatas then
			table.remove(self.unlockFuncDatas, 1)
		end
	end
end

function HudV2Ctrl:tryShowAddPet()
	if self.needShowAddPetData and #self.needShowAddPetData > 0 then
		local clientPetInfo = table.remove(self.needShowAddPetData, 1)

		pg.global.ui.tips:pushPetGot({
			clientPetInfo
		})

		if pg.global.ui:getModalPanelShowState(UIConst.UI_ID_TIPS) then
			pg.global.ui.tips:itemPetGot(clientPetInfo)
		end
	end
end

function HudV2Ctrl:delayShowPetAdd(clientShowPetInfo)
	if self.needShowAddPetData == nil then
		self.needShowAddPetData = {}
	end

	table.insert(self.needShowAddPetData, clientShowPetInfo)

	if self:checkUIVisible() then
		self:tryShowAddPet()
	end
end

function HudV2Ctrl:tryShowAddItem()
	if self.needShowAddItemData and #self.needShowAddItemData > 0 then
		local itemListData = table.remove(self.needShowAddItemData, 1)

		pg.global.ui.itemObtain:open(itemListData)
	end
end

function HudV2Ctrl:delayShowItemAdd(itemListData)
	if self.needShowAddItemData == nil then
		self.needShowAddItemData = {}
	end

	table.insert(self.needShowAddItemData, itemListData)

	if self:checkUIVisible() then
		self:tryShowAddItem()
	end
end

function HudV2Ctrl:onSchoolGuideRedDotChanged()
	pg.global.refreshRedDotState(RedDotConst.RedDotPath.SCHOOL_GUIDE)
end

function HudV2Ctrl:refreshInteractGestureBtnState()
	if self.LD and self.LD.refreshInteractGestureBtnState then
		self.LD:refreshInteractGestureBtnState()
	end
end

function HudV2Ctrl:showNpcDuelInCombat(bol)
	if self.MD and self.MD.showNpcDuelInCombat then
		self.MD:showNpcDuelInCombat(bol)
	end

	if self.LD and self.LD.refreshButtonVisibleState then
		self.LD:refreshButtonVisibleState()
	end
end

function HudV2Ctrl:onSceneLoaded()
	if pg.me and pg.me.inTeammateView then
		pg.me.inTeammateView = false
	end

	pg.global.refreshRedDotState(RedDotConst.RedDotPath.FUNC_MENU)
	self:refreshAllComponents()
end

function HudV2Ctrl:refreshAllComponents()
	if self.MD and self.MD.hpFuse then
		local isPvp = pg.me and pg.me.space and pg.me.space:isPvpEnv()

		self.MD.hpFuse:setFuseBtnVisible("pvp", not isPvp)
		self.MD.hpFuse:refreshStatusVisible()
		self.MD.hpFuse:refreshPossessedState()
		self.MD.hpFuse:refreshStatus()

		if pg.me then
			self.MD.hpFuse:onControlChanged(pg.me:isControllingPet())
		end
	end

	if self.RD and self.RD.skill then
		self.RD.skill:refreshSkillList()
		self.RD.skill:refreshExploreBtnVisible()
		self.RD.skill:bindPetActionModeAttributeNotify()
	elseif self.RD and self.RD.mobileSkill then
		self.RD.mobileSkill:refreshSkillList()
		self.RD.mobileSkill:refreshExploreBtnVisible()
		self.RD.mobileSkill:bindPetActionModeAttributeNotify()
	end

	if self.RD and self.RD.exploreBtn then
		self.RD.exploreBtn:refreshHudExplorePageState()
	end

	if self.RD and self.RD.mobile3C then
		self.RD.mobile3C:refreshNormalAttackBtn()
	end

	if self.RM and self.RM.petList then
		self.RM.petList:refreshPetListVisible()
	end

	if self.LD and self.LD.ball then
		self.LD.ball:refreshUIVisible()
	end

	if self.RD and self.RD.ballBtn then
		self.RD.ballBtn:refreshUIVisible()
	end

	if self.RU and self.RU.funcList then
		self.RU.funcList:refreshFuncListBtn()
	end

	if self.LD and self.LD.refreshButtonVisibleState then
		self.LD:refreshButtonVisibleState()
	end
end

function HudV2Ctrl:onVehicleShowStateChanged(info)
	self.isInVehicle = info.showVehicleInter

	if not self.view then
		return
	end

	if not pg.pawn then
		return
	end

	if self.isInVehicle then
		if self.RD and self.RD.interactGesture and self.RD.interactGesture.transform then
			self.RD.interactGesture:closeEmoticonPanel(nil, true)
		end

		self.pendingVehicleHudRestore = nil

		if self.RD and self.RD.skill then
			LuaUIUtils.setUIVisible(self.RD.skill.uWidget, false)
		end

		if self.RD and self.RD.mobile3C then
			LuaUIUtils.setUIVisible(self.RD.mobile3C.uWidget, false)
		end

		if self.RM and self.RM.petList then
			LuaUIUtils.setUIVisible(self.RM.petList.uWidget, false)
		end

		if self.RU and self.RU.funcList then
			LuaUIUtils.setUIVisible(self.RU.funcList.uWidget, false)
		end
	elseif pg.pawn and pg.pawn:RIDING_ST() then
		self.pendingVehicleHudRestore = true
	else
		self:restoreVehicleHud()
	end
end

function HudV2Ctrl:restoreVehicleHud()
	self.pendingVehicleHudRestore = nil

	if not self.view then
		return
	end

	if self.RD and self.RD.skill then
		LuaUIUtils.setUIVisible(self.RD.skill.uWidget, true)
		self.RD.skill:refreshSkillList(true)
	elseif self.RD and self.RD.mobileSkill then
		LuaUIUtils.setUIVisible(self.RD.mobileSkill.uWidget, true)
		self.RD.mobileSkill:refreshSkillList(true)
	end

	if self.RD and self.RD.mobile3C then
		LuaUIUtils.setUIVisible(self.RD.mobile3C.uWidget, true)
		self.RD.mobile3C:refreshSkillUIVisible()
	end

	if self.RM and self.RM.petList then
		LuaUIUtils.setUIVisible(self.RM.petList.uWidget, true)
		self.RM.petList:refreshPetListVisible()
	end

	if self.RU and self.RU.funcList then
		LuaUIUtils.setUIVisible(self.RU.funcList.uWidget, true)
	end
end

function HudV2Ctrl:onCharacterStateChangedForVehicle()
	if not self.pendingVehicleHudRestore then
		return
	end

	if pg.pawn and pg.pawn:RIDING_ST() then
		return
	end

	self:restoreVehicleHud()
end

function HudV2Ctrl:refreshFlyState()
	self:startTimer(function()
		local isMobile = pg.global.ui:runPlatformByMobile()

		if isMobile then
			self:refreshMobileFlyState()
		else
			self:refreshSkillList()
			self:refreshBallVisible()
		end

		local skillComponent = self.RD and (self.RD.skill or self.RD.mobileSkill)

		if skillComponent then
			skillComponent:refreshFinalSkillVisible()
		end
	end, 0)
end

function HudV2Ctrl:refreshMobileFlyState()
	if self.RD and self.RD.mobileSkill then
		self.RD.mobileSkill:refreshSkillList()
	end

	if self.RD and self.RD.mobile3C then
		self.RD.mobile3C:refreshExploreBtnState()
	end

	if self.RD and self.RD.mobileExplore then
		self.RD.mobileExplore:refreshSkillList()
	end
end

function HudV2Ctrl:refreshSkillList()
	if self.RD and self.RD.skill then
		self.RD.skill:refreshSkillList()
	elseif self.RD and self.RD.mobileSkill then
		self.RD.mobileSkill:refreshSkillList()
	end
end

function HudV2Ctrl:checkPetBallValidState()
	local petBallMap = pg.me.petBallMap

	if petBallMap == nil then
		return
	end

	local player = pg.me

	if not player:checkFunctionUnlock("PETBALL") then
		return
	end

	local active = false

	for k, v in pairs(petBallMap) do
		if type(v) == "table" then
			active = true

			break
		end
	end
end

function HudV2Ctrl:refreshBallVisible()
	if self.LD and self.LD.ball then
		self.LD.ball:refreshUIVisible()
	end
end

function HudV2Ctrl:setIsInAim(isInAim, abilityId)
	if self.RD and self.RD.aim then
		self.RD.aim:setIsInAim(isInAim, abilityId)
	end
end

function HudV2Ctrl:setLeftVisible(visible)
	if self.LU then
		self.LU:setVisible(visible)
	end
end

function HudV2Ctrl:openFuncMenu(selectedFuncID, cb)
	if not self:getEscBtnVisible() then
		return
	end

	if pg.me.space:isPvpEnv() then
		return
	end

	pg.me:forceExitCaptureMode()

	if not pg.pawn:checkStatus(ConflictTypes.CT_FUNC_MENU) then
		pg.global.ui.tips:showTextTip(pg.getGameString("FUNCTION_CANT_STATE"))

		return
	end

	pg.global.ui:open(UIConst.UI_ID_FUNC_MENU, {
		selectedFuncID = selectedFuncID
	}, function()
		if cb then
			cb()
		end
	end)
end

function HudV2Ctrl:getEscBtnVisible()
	if not pg.game:checkModuleEnable(ClientConst.ModuleKey.Esc) then
		return false
	end

	return true
end

function HudV2Ctrl:checkCanOpenGamepadMenu()
	local playerSpace = pg.me and pg.me.space

	if playerSpace and playerSpace:isNpcDuel() or BossRushUtils.isInBossRushBattleLevel() then
		return false
	end

	return true
end

function HudV2Ctrl:setGamepadMenuLongPressProgress(value)
	local progress = self.RU and self.RU.funcList and self.RU.funcList.gamepadMenuKeyProgressPress

	if not progress then
		return
	end

	progress:ProgressToValue(value or 0, nil, 0)
end

function HudV2Ctrl:refreshStatisticsInfoEx(...)
	ClientTextUtils.setText(self.view.statisticsTextUSDFText, ...)
end

function HudV2Ctrl:switchStatistics(visible)
	self.statisticsVisible = visible

	self.view.statisticsTextUSDFText:SetActive(visible)
end

function HudV2Ctrl:getStatisticsVisible()
	if self.statisticsVisible == nil then
		return false
	end

	return self.statisticsVisible
end

function HudV2Ctrl:setHudUIEffectState(active, param)
	return
end

function HudV2Ctrl:showStaminaAddFx()
	return
end

function HudV2Ctrl:setMapHudVisible(reasonKey, visible)
	reasonKey = reasonKey or "Default"

	if not self.hideMapHudDict then
		self.hideMapHudDict = {}
	end

	if visible then
		self.hideMapHudDict[reasonKey] = nil
	else
		self.hideMapHudDict[reasonKey] = false
	end
end

function HudV2Ctrl:hideByInfoStamp(hide)
	local showFuncMenu = pg.global.ui.funMenuExit.model:checkShowFunc()

	if self.RU and self.RU.funcList and self.RU.funcList.rootPanel then
		self.RU.funcList.rootPanel:SetActive(showFuncMenu and not hide)
	end

	if self.RM and self.RM.petList then
		if hide then
			self.RM.petList:hide()
		else
			self.RM.petList:show()
		end
	end
end

function HudV2Ctrl:setMateComponentVisible(visible)
	if self.RM and self.RM.petList and self.RM.petList.petUList then
		self.RM.petList.petUList:SetActive(visible)
	end
end

function HudV2Ctrl:showRecommendGesture(show, data)
	if self.LD and self.LD.showRecommendGesture then
		self.LD:showRecommendGesture(show, data)
	end
end

function HudV2Ctrl:onQuitBtnClick()
	if self.LU and self.LU.quitBtn and self.LU.quitBtn.onQuitBtnClick then
		self.LU.quitBtn:onQuitBtnClick()
	end
end

function HudV2Ctrl:tryOpenTowerMain()
	if self.needOpenTowerMain then
		self.needOpenTowerMain = false

		pg.global.ui:open(UIConst.UI_ID_ROG_LEVEL_SELECT)
	end
end

function HudV2Ctrl:muteEventSystemListener(mute)
	if not self.view then
		return
	end

	self.view.uIEventSystemListener.muteLeftPointerDownCheck = mute

	if not mute then
		function self.view.uIEventSystemListener.leftPointerDownEvent()
			pg.game.social.interactGestureComponent:rayCastPlayer()
		end
	else
		self.view.uIEventSystemListener.leftPointerDownEvent = nil
	end
end

function HudV2Ctrl:onSocialBuffChange(info)
	if not self.view then
		return
	end

	local ent = pg.getEntity(info.entId)

	if not ent then
		return
	end

	if info.isAdd then
		local buffName = BuffConfigData[info.templateId] and pg.getLocalizationText(BuffConfigData[info.templateId].buffName) or "empty config"
		local entUid = ent.uid
		local displayName = entUid and LuaUIUtils.getPlayerDisplayName(entUid, ent.playerName, true) or ent.playerName

		pg.global.showBubbleMessageRaw(string.format(pg.getGameString("ACTION_GET_BUFF_TOAST"), displayName or "", buffName or "empty name"))
	end
end

function HudV2Ctrl:onChangeMapLayerData()
	local minimap = pg.game.map:GetMiniMapUI()

	if minimap then
		minimap:onChangeMapLayerData()
	end
end

function HudV2Ctrl:openServicePanel()
	if not pg.global.sdkManager:canOpenHelpCenter() then
		return
	end

	if SDKLoginConfig.isEnabled() then
		local params = {
			entrance = 0
		}

		if pg.me then
			params.total_pay = pg.me.PcPayTotalMoney or 0
			params.last_pay_at = pg.me.PcLeastPayTime or 0
			params.pay_count = pg.me.PcPayTotalCount or 0
			params.first_pay_at = pg.me.PcFirstPayTime or 0
		end

		params.json_data = HelpCenterParamsUtils.buildJsonDataTable()

		pg.global.sdkManager:OpenHelpCenter(params)
	end
end

function HudV2Ctrl:openSurvey()
	local surveyRedDot = pg.global.ui.Survey.model:getSurveyItemNum()

	if surveyRedDot then
		pg.global.ui:open(UIConst.UI_ID_SURVEY)
	else
		pg.global.ui.tips:showTextTip(pg.getGameString("NO_SURVEY"))
	end
end

function HudV2Ctrl:openChat()
	if self.LD and self.LD.openChat then
		self.LD:openChat()
	end
end

function HudV2Ctrl:showSeamlessVFX()
	if self.MD and self.MD.showSeamlessVFX then
		self.MD:showSeamlessVFX()
	end
end

function HudV2Ctrl:_isSneakModeBlockedByUI()
	local _, fullscreenUID = self.adapter:getFullScreenVisibleState()

	if not fullscreenUID then
		return false
	end

	local uiConfig = UIConst.UI_CONFIGS[fullscreenUID]

	return uiConfig and uiConfig.enableMainCamera or false
end

function HudV2Ctrl:_shouldRefreshSneakHintForUI(uid)
	if uid == UIConst.UI_ID_AI_ASSISTANT or uid == UIConst.UI_ID_GUIDE_PANEL then
		return true
	end

	local uiConfig = UIConst.UI_CONFIGS[uid]

	return uiConfig and uiConfig.fullScreen and uiConfig.enableMainCamera or false
end

function HudV2Ctrl:refreshSneakHint()
	local player = pg.me
	local pawn = pg.pawn
	local inWind = false

	if player and pawn then
		local canGlideByPawn = pawn and pawn.canGlide and pawn:canGlide()
		local canGlideByExplore = pg.game.controller:getExplorePet(AbilityConst.SPECIFIC_ABILITY_INDEX_GLIDE)
		local canGlide = canGlideByPawn or canGlideByExplore

		inWind = pawn and not pawn:GLIDE_ST() and player.inConstraintWind and canGlide
	end

	if inWind then
		local isMobileInteract = pg.global.ui:runPlatformByMobile()
		local displayText = isMobileInteract and pg.getGameString("GLIDE_TIPS_MOBILE") or pg.getGameString("GLIDE_TIPS")

		pg.global.ui.tips:pushAreaManagerData({
			itemKey = "UnderTips",
			duration = 99999,
			areaType = TipAreaConst.AREAS.B,
			displayText = displayText
		})
	elseif pg.global.ui.tips.areaManager then
		pg.global.ui.tips.areaManager:hideAreaItemById(TipAreaConst.AREAS.B, "UnderTips")
	end

	local inGrass = pawn and pawn.inGrass or false
	local sneakModeActive = inGrass and not self:_isSneakModeBlockedByUI()

	if self._sneakModeActive == sneakModeActive then
		return
	end

	self._sneakModeActive = sneakModeActive

	if sneakModeActive then
		if pawn then
			pawn:stopEffect(ControllerData.EffDelayDash, true)
		end

		pg.global.cameraMgr:StartSneakMode(SNEAK_MODE_TRANSITION_TIME)
	else
		pg.global.cameraMgr:StopSneakMode(SNEAK_MODE_TRANSITION_TIME)
	end
end

function HudV2Ctrl:onHandleOnShowUI(uid)
	if self:_shouldRefreshSneakHintForUI(uid) then
		self:refreshSneakHint()
	end
end

function HudV2Ctrl:onHandleOnHideUI(uid)
	if self:_shouldRefreshSneakHintForUI(uid) then
		self:refreshSneakHint()
	end
end

function HudV2Ctrl:onControlEntChanged()
	self:refreshSneakHint()
end

function HudV2Ctrl:onEnterFallen()
	if self.RD then
		if self.RD.syncope == nil then
			local RDViewUINodeTrans = self.RD.view.uiNode.transform

			self.RD.syncope = self.RD:getBaseComponentCls(HudSplicingCfg.componentName.syncope).new(self.RD, RDViewUINodeTrans, {
				isAutoLoad = true,
				parentTrans = RDViewUINodeTrans,
				compName = HudSplicingCfg.componentName.syncope
			})
		else
			self.RD.syncope:setVisible(true, false)
		end
	end

	local player = pg.me

	if player and player:canShowSelfRescueToast() then
		ClientUtils.showBossMechanismTip(ClientConst.SELF_RESCUE_SP_TOAST_ID, 3, false)
	end

	pg.game:setModuleEnable("Fallen", ClientConst.ModuleKey.Skill, false)
end

function HudV2Ctrl:onEnterAlive()
	if self.RD and self.RD.syncope then
		self.RD.syncope:setVisible(false)
	end

	pg.game:setModuleEnable("Fallen", ClientConst.ModuleKey.Skill, true)
end

function HudV2Ctrl:onEnterFallenAid()
	if self.RD then
		if self.RD.syncope == nil then
			self.RD.syncope = self.RD:getBaseComponentCls(HudSplicingCfg.componentName.syncope).new(self.RD, nil, {
				isAutoLoad = true,
				parentTrans = self.RD.view.uiNode.transform,
				compName = HudSplicingCfg.componentName.syncope
			})
		else
			self.RD.syncope:setVisible(true, true)
		end
	end

	pg.game:setModuleEnable("FallenAid", ClientConst.ModuleKey.Skill, false)
end

function HudV2Ctrl:onExitFallenAid()
	if self.RD and self.RD.syncope then
		local player = pg.me

		if player and player:FALLEN_ST() then
			self.RD.syncope:setVisible(true, false)
		else
			self.RD.syncope:setVisible(false)
		end
	end

	pg.game:setModuleEnable("FallenAid", ClientConst.ModuleKey.Skill, true)
end

function HudV2Ctrl:leaveSimpleChatMode()
	if self.LD and self.LD.quickChat then
		self.LD.quickChat:leaveSimpleChatMode()
	end
end

function HudV2Ctrl:refreshThrowItem()
	local isThrow = pg.me:isThrowItem()
	local captureBall = pg.global.ui.captureBall

	if isThrow then
		pg.global.ui.throwPanel:openOrShow()

		if captureBall then
			captureBall:hide()
		end
	else
		local throwPanel = pg.global.ui:tryGetCtrlByUid(UIConst.UI_ID_THROW_PANEL)

		if throwPanel then
			throwPanel:hide()
		end

		if captureBall and pg.me and pg.me:isInCatchMode() and not pg.me:isFastThrowPresentationFinished() then
			captureBall:openOrShow()
		end
	end

	pg.global.ui.tips:refreshShortCutKey()
end

function HudV2Ctrl:switchAimVisible(visible)
	local captureBall = pg.global.ui.captureBall

	if captureBall then
		captureBall:switchAimVisible(visible)
	end
end

function HudV2Ctrl:clearHideMarkDict()
	table.clear(self.hideMarkDict)
end

function HudV2Ctrl:backToHome()
	self:clearHideMarkDict()
	self:resetVisibleState()
end

function HudV2Ctrl:clearBigDriveBallHideMark()
	self:setUIHide("BigDriveBall", false)
end

function HudV2Ctrl:onSwitchBigDriveBallMode(bigDriveBall)
	self:setUIHide("BigDriveBall", bigDriveBall)

	local captureBall = pg.global.ui.captureBall

	if captureBall then
		captureBall:onSwitchBigDriveBallMode(bigDriveBall)
	end
end

function HudV2Ctrl:showEmotionBtn(show)
	if self.LD and self.LD.showEmotionBtn then
		self.LD:showEmotionBtn(show)
	end
end

function HudV2Ctrl:onMobileQtePlay(isQteShow)
	if pg.global.ui:runPlatformByMobile() and self.RD and self.RD.mobileSkill then
		if isQteShow then
			self.RD.mobileSkill:hide()
		else
			self.RD.mobileSkill:show()
		end
	end
end

function HudV2Ctrl:checkSpecialTrainValidState()
	if self.RU and self.RU.funcList then
		self.RU.funcList:refreshFuncListBtn()
		self.RU.funcList:refreshSpecialTrainRedDot()
	end
end

function HudV2Ctrl:canPlaySeasonEntryFly(sourcePosition)
	local funcList = self.RU and self.RU.funcList

	return funcList and funcList:canPlaySeasonEntryFly(sourcePosition) == true
end

return HudV2Ctrl
