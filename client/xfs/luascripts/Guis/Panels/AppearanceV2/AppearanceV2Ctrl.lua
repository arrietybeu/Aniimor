-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\AppearanceV2\\AppearanceV2Ctrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UIConst = require("Const.UIConst")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local UICtrl = require("Guis.UICtrl")
local AvatarUtils = require("Guis.Utils.AvatarUtils")
local AvatarShareService = require("Guis.Utils.AvatarShareService")
local PetComponent = require("Guis.Panels.AppearanceV2.Component.PetComponent")
local PlayerComponent = require("Guis.Panels.AppearanceV2.Component.PlayerComponent")
local WorkShopHomeComponent = require("Guis.Panels.AppearanceV2.Component.WorkShopHomeComponent")
local PhotoStudioEditComponent = require("Guis.Panels.AppearanceV2.Component.PhotoStudioEditComponent")
local AppearanceV2Ctrl = Class.LightClass("AppearanceV2Ctrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local HotkeyConst = require("Const.HotkeyConst")
local Const = require("Common.Const.Const")
local RightInfoComponent = require("Guis.Panels.AppearanceV2.Component.Common.RightInfoComponent")
local FuncMenuListData = require("Data.func_menu_list_data")
local PetJewelryOssCache = require("Utils.PetJewelryOssCache")
local PhotographyStudioUtils = require("Utils.PhotographyStudioUtils")
local TimerManager = require("Core.Timer.TimerManager")
local ClientUtils = require("Utils.ClientUtils")
local Object = CS.UnityEngine.Object
local APPEARANCE_CLOSE_TWEEN_ID = LuaUIUtils.TweenId("appearanceClose")

AppearanceV2Ctrl.messages = {
	[MessageName.ON_PRESET_SAVE] = {
		"onPresetSave",
		true
	},
	[MessageName.ON_SKELETON_LOADED] = {
		"onModelSkeletonLoaded",
		true
	},
	[MessageName.ON_PART_MODEL_ALL_LOADED] = {
		"onPartModelLoaded",
		true
	},
	[MessageName.SHOP_ON_BUY_ITEMS] = {
		"onBuyItems",
		true
	},
	[MessageName.MONEY_UNBOUND_CHANGE] = {
		"onMoneyChanged",
		true
	},
	[MessageName.ITEM_COUNT_MAP_CHANGE] = {
		"onMoneyChanged",
		true
	},
	[MessageName.CURRENCY_CHANGE] = {
		"onMoneyChanged",
		true
	},
	[MessageName.EVENT_GET_VITALITY_SCORE] = {
		"onGetVitalityScore",
		true
	},
	[MessageName.ON_AVATAR_FASHION_SCORE_CHANGED] = {
		"onAvatarFashionScoreChanged",
		true
	},
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	}
}

function AppearanceV2Ctrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.isClosingPanel = false
	self.avatarScene = pg.game.uiScene:getScene(UISceneConst.AVATAR_SCENE)
	self.curPresetKey = pg.game.avatar:getPresetKey(pg.me)
	self.entityId = self.curPresetKey
	self.components = {}
	self.curComponent = nil
	self.curComponentName = nil
	self.curPetId = info.curPetId

	self:initComponents()

	self.enterPage = info.enterPage or "player"
	self.selectSuitOnOpen = info.selectSuitOnOpen
	self.closeCallback = info.closeCallback
	self.vitalityPhase = info.phase
	self.vitalityThemeId = info.themeId
	self.petScore = info.petScore
	self.petScoreData = info.petScoreData
	self.vitalityEventId = info.vitalityEventId
	self.inVitality = self.vitalityPhase and self.vitalityThemeId
end

function AppearanceV2Ctrl:addListener()
	function self.view.backUButton.luaClick()
		self:closePanel()
	end

	self:bindHotKeyPerform(HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel, function()
		self:closePanel()

		return false
	end, self.view.rootUComponent.gameObject, "appearanceEscBind")

	function self.view.titleTabUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local name1 = objectReference:GetRefValue("name1")
		local name2 = objectReference:GetRefValue("name2")

		ClientTextUtils.setText(name1, pg.getGameString(data.text))
		ClientTextUtils.setText(name2, pg.getGameString(data.text))

		button.visualInteractable = data.componentName ~= "photoStudioEdit" or PhotographyStudioUtils.checkFunctionEnabled(false)
	end

	function self.view.titleTabUList.luaClick(button, data)
		if data.componentName == "photoStudioEdit" and not PhotographyStudioUtils.checkFunctionEnabled(true) then
			return
		end

		if data.componentName == "pet" then
			PetJewelryOssCache.ensureLoaded(function()
				if not self.components then
					return
				end

				self.view.rootUComponent:TryChangePage("Tab", data.controller)
				self:onTabClicked(data.componentName)
			end)

			return
		end

		self.view.rootUComponent:TryChangePage("Tab", data.controller)
		self:onTabClicked(data.componentName)
	end

	LuaUIUtils.setTopCurrencyItemList(self.view.currencyUList, UIConst.UI_ID_APPEARANCE_V2)

	self.petBoneTick = self:startTimer(function()
		if not self.components then
			return
		end

		if self.curComponentName == "pet" then
			local petComponent = self.components.pet

			if petComponent then
				petComponent:updatePetBone()
			end
		elseif self.curComponentName == "player" then
			if not self.components.player.components then
				return
			end

			local playerAccessoryComponent = self.components.player.components.accessory

			if playerAccessoryComponent then
				playerAccessoryComponent:updateBone()
			end
		end
	end, 0, true)

	AvatarUtils.renderPhotographyStudioBackgroundSelector(self.view.backgroundSelectorUSelector)

	function self.view.btnHairTieUButton.luaClick()
		AvatarUtils.toggleHairTie(self.avatarScene, self.view.btnHairTieUButton)
	end
end

function AppearanceV2Ctrl:onDestroy()
	local transition = self._appearanceCloseTransition

	if transition and not transition.completing then
		self:finishAppearanceCloseTransition(0)
	end

	AvatarUtils.cancelHairTie()

	self.avatarScene = nil
	self.model.cacheHairSuitId = nil
	self.isClosingPanel = false
	self.components = nil
	self.curComponent = nil
	self.rightInfoComponent = nil

	UICtrl.onDestroy(self)
end

function AppearanceV2Ctrl:onOpen(info)
	self:finishAppearanceCloseTransition(0)

	self.isClosingPanel = false

	UICtrl.onOpen(self, info)

	self.enterPhotographyStudioUid = info and info.photographyStudioUid

	if self.enterPage == "photoStudioEdit" and not PhotographyStudioUtils.checkFunctionEnabled(true) then
		self.enterPage = "player"
		self.enterPhotographyStudioUid = nil
	end

	self.avatarScene:addCameraZoomKeyBinding(self.view.gameObject)

	local enableCameraMode = info and info.enableCameraMode

	if enableCameraMode then
		self.uiScene:enableCameraMode(self.uiScene.CAMERA.SIMPLE)
	end

	local titleTabList = self.model:getTitleTabList()

	self.view.titleTabUList:SetList(titleTabList)

	for index, tabInfo in ipairs(titleTabList) do
		if self.enterPage == tabInfo.componentName then
			local res, tabBtn = self.view.titleTabUList:TryGetChildAt(index - 1)

			if res then
				tabBtn:OnClickSimulate()
			end

			break
		end
	end

	self:trySelectSuitOnOpen()
	AvatarShareService.tryImportFromClipboard()
	ClientTextUtils.setText(self.view.titleShadowUSDFText, pg.getLocalizationText(FuncMenuListData[151].name))

	if self.vitalityPhase then
		self.view.titleTabUList.gameObject:SetActiveEx(false)
	end

	self.view.leftLayoutBoxUWidget:SetNavGroupDefaultItem(self.view.backgroundSelectorUSelector)
end

function AppearanceV2Ctrl:trySelectSuitOnOpen()
	local suitInfo = self.selectSuitOnOpen

	if not suitInfo or not suitInfo.id then
		return
	end

	if self.enterPage ~= "player" then
		return
	end

	local playerComponent = self.components and self.components.player

	if playerComponent and playerComponent.selectSuitOnOpen then
		playerComponent:selectSuitOnOpen(suitInfo)
	end

	self.selectSuitOnOpen = nil
end

function AppearanceV2Ctrl:refreshConsoleBarState()
	local isPhotoStudioTab = self.curComponentName == "photoStudioEdit"
	local enableCameraControl = not isPhotoStudioTab and self.curComponent ~= self.components.workShopHome

	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("ConsoleBar_Accessories_Select", not isPhotoStudioTab)
	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("ConsoleBar_Accessories_CameraZoom", enableCameraControl)
	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("ConsoleBar_Accessories_CameraMove", enableCameraControl)
end

function AppearanceV2Ctrl:onShow()
	local curEntity = self.avatarScene:getCurEntity()

	if curEntity then
		curEntity.eModel:SetActive(true)
	end

	self:refreshCurrencyList()
end

function AppearanceV2Ctrl:openPhotographyStudioEditor(studioUid)
	if self.curComponentName ~= "photoStudioEdit" or not pg.me:getStudioInfo(studioUid) then
		return
	end

	local component = self.components.photoStudioEdit

	if component.selectedStudioUid ~= studioUid and not component:selectStudioByUid(studioUid) then
		return
	end

	component:openStudioEditor(studioUid)
end

function AppearanceV2Ctrl:onVisibleChange(visible)
	if not self.avatarScene then
		return
	end

	if visible then
		self.view.transform.gameObject:SetActiveEx(true)
		self.avatarScene:registerGesture(self.uid, {
			maskRayBoxTrans = self.view.maskRayBoxTransform
		})
		ClientTextUtils.setText(self.view.fashionNumUSDFText, string.format(pg.getGameString("AVATAR_FASHION_TIP_1"), pg.me.fashionScore))
	else
		self.avatarScene:unRegisterGesture(self.uid)
		self.view.transform.gameObject:SetActiveEx(false)
	end

	local curEntity = self.avatarScene:getCurEntity()

	if not curEntity or not curEntity.cancelCustomShowPreview then
		return
	end

	if self.components.player then
		self.components.player:onVisibleChange(visible)
	end
end

function AppearanceV2Ctrl:onTabClicked(componentName)
	self.avatarScene:setPhotographyStudioCharactersVisible(componentName == "photoStudioEdit")

	if self.curComponentName == "player" and componentName == "photoStudioEdit" then
		local playerComponent = self.components.player

		if playerComponent and playerComponent.prepareEnterPhotographyStudio then
			playerComponent:prepareEnterPhotographyStudio()
		end
	end

	for name, component in pairs(self.components) do
		if name ~= componentName then
			component:onLeavePage()
		end
	end

	self.curComponent = self.components[componentName]
	self.curComponentName = componentName

	self.curComponent:onEnterPage()
	self:refreshConsoleBarState()
end

function AppearanceV2Ctrl:close()
	self:closePanel(true)
end

function AppearanceV2Ctrl:closeImmediately()
	self:closePanel(true)
end

function AppearanceV2Ctrl:checkUIClosing()
	return self.isClosingPanel or UICtrl.checkUIClosing(self)
end

function AppearanceV2Ctrl:finishAppearanceCloseTransition(duration)
	local transition = self._appearanceCloseTransition

	if not transition then
		return
	end

	if duration > 0 and NotNil(transition.cover) then
		if transition.releasing then
			return
		end

		transition.releasing = true
		transition.timeoutId = TimerManager.addTimer(duration + 0.2, function()
			if self._appearanceCloseTransition == transition then
				self:finishAppearanceCloseTransition(0)
			end
		end)

		DoTweenAnimMgr.DoAlpha(transition.cover, APPEARANCE_CLOSE_TWEEN_ID, 0, duration, 0, CS.DG.Tweening.Ease.OutQuad, function()
			if self._appearanceCloseTransition == transition then
				self:finishAppearanceCloseTransition(0)
			end
		end)

		return
	end

	self._appearanceCloseTransition = nil

	if transition.frameId then
		TimerManager.delFrameCb(transition.frameId)
	end

	if transition.timeoutId then
		TimerManager.removeTimer(transition.timeoutId)
	end

	if NotNil(transition.coverObject) then
		ClientUtils.tryWithLogError(function()
			DoTweenAnimMgr.Kill(transition.coverObject, APPEARANCE_CLOSE_TWEEN_ID, false)
			transition.coverObject:SetActiveEx(false)
		end)
		ClientUtils.tryWithLogErrorEx(Object.Destroy, transition.coverObject)
	end

	if transition.inputSuppressed and self.view == transition.view and NotNil(transition.view.widget) then
		ClientUtils.tryWithLogError(function()
			transition.view.widget.visibility = CS.XGUI.EVisibility[transition.visibilityName]
		end)
	end
end

function AppearanceV2Ctrl:startAppearanceCloseTransition()
	local blackChange = self.adapter.blackChange
	local template = blackChange and blackChange.view and blackChange.view.blackImage

	if not self:checkUIVisible() or not self:needBlackChangeOnClose() or IsNil(template) or not template.gameObject.activeInHierarchy then
		return false
	end

	local transition = {
		view = self.view
	}

	self._appearanceCloseTransition = transition

	local created = ClientUtils.tryWithLogError(function()
		transition.coverObject = Object.Instantiate(template.gameObject, template.transform.parent, false)
		transition.coverObject.name = "AppearanceCloseCover"
		transition.cover = transition.coverObject:GetComponent(typeof(CS.XGUI.UImage))
		transition.cover.renderOpacity = 0
		transition.cover.visibility = CS.XGUI.EVisibility.HitTestInvisible

		transition.coverObject.transform:SetAsLastSibling()
		transition.coverObject:SetActiveEx(true)

		transition.visibilityName = self.view.widget.visibility:ToString()
		self.view.widget.visibility = CS.XGUI.EVisibility.HitTestInvisible
		transition.inputSuppressed = true
	end)

	if not created then
		self:finishAppearanceCloseTransition(0)

		return false
	end

	self:clearDeferredUISceneActivation()
	self:clearBlackTimer()
	self:_refreshGameTimeStatusOnClose()

	local function onCovered()
		if self._appearanceCloseTransition ~= transition or transition.frameId then
			return
		end

		transition.frameId = TimerManager.addSpecificFrameCb(2, false, function()
			if self._appearanceCloseTransition ~= transition then
				return
			end

			transition.frameId = nil

			if self.view ~= transition.view then
				self:finishAppearanceCloseTransition(0)

				return
			end

			if IsNil(transition.cover) or not transition.coverObject.activeInHierarchy then
				self:closePanel(true)

				return
			end

			if transition.cover.renderOpacity < 1 then
				return
			end

			if transition.timeoutId then
				TimerManager.removeTimer(transition.timeoutId)

				transition.timeoutId = nil
			end

			transition.completing = true

			self:closeAppearancePanelImmediately()

			if self._appearanceCloseTransition ~= transition then
				return
			end

			transition.frameId = TimerManager.addSpecificFrameCb(4, false, function()
				if self._appearanceCloseTransition ~= transition then
					return
				end

				transition.frameId = nil

				self:finishAppearanceCloseTransition(0.3)
			end)
		end)
	end

	transition.timeoutId = TimerManager.addTimer(0.5, function()
		if self._appearanceCloseTransition ~= transition then
			return
		end

		transition.timeoutId = nil

		if IsNil(transition.cover) or not transition.coverObject.activeInHierarchy then
			self:closePanel(true)

			return
		end

		DoTweenAnimMgr.Kill(transition.coverObject, APPEARANCE_CLOSE_TWEEN_ID, false)

		transition.cover.renderOpacity = 1

		onCovered()
	end)

	DoTweenAnimMgr.DoAlpha(transition.cover, APPEARANCE_CLOSE_TWEEN_ID, 1, 0.1, 0, CS.DG.Tweening.Ease.OutQuad, onCovered)

	return true
end

function AppearanceV2Ctrl:closePanel(immediately)
	immediately = immediately == true

	if self._appearanceCloseCleanupRunning then
		return
	end

	if immediately then
		self:finishAppearanceCloseTransition(0)
	elseif self.isClosingPanel and self._appearanceCloseTransition then
		return
	end

	self.isClosingPanel = true

	if not immediately and self:startAppearanceCloseTransition() then
		return
	end

	self:closeAppearancePanelImmediately()
end

function AppearanceV2Ctrl:closeAppearancePanelImmediately()
	if self._appearanceCloseCleanupRunning then
		return
	end

	self._appearanceCloseCleanupRunning = true
	self.isClosingPanel = true

	local closeCallback = self.closeCallback

	self.closeCallback = nil

	local ok, err = xpcall(function()
		if pg.global.ui:checkUIOpen(UIConst.UI_ID_PHOTOGRAPHY_STUDIO_EDIT) then
			pg.global.ui:closeImmediately(UIConst.UI_ID_PHOTOGRAPHY_STUDIO_EDIT)
		end

		if self.components then
			for _, component in pairs(self.components) do
				if component and component.destroy then
					component:destroy()
				end
			end
		end

		if self.inVitality and self.model and self.model.clearTryAccessData then
			self.model:clearTryAccessData()
		end

		local avatarScene = self.avatarScene

		if avatarScene and avatarScene.getAllEntities then
			local entities = avatarScene:getAllEntities()

			if entities then
				for key, entity in pairs(entities) do
					if entity and entity.syncToServer and key ~= "dummy" then
						entity:syncToServer()
					end
				end
			end
		end

		if pg.global.avatarMgr then
			pg.global.avatarMgr:ClearAvatar()
		end

		pg.global.ui:hideAllUIByCustomKey(UIConst.UI_HIDE_KEY.APPEARANCE)
	end, debug.traceback)

	if not ok then
		print("[AppearanceV2Ctrl] closePanel cleanup failed:", err)
	end

	ClientUtils.tryWithLogErrorEx(self.tryDestroyUIScene, self)
	ClientUtils.tryWithLogErrorEx(UICtrl.closeImmediately, self)

	self._appearanceCloseCleanupRunning = false

	if closeCallback then
		ClientUtils.tryWithLogError(closeCallback)
	end
end

function AppearanceV2Ctrl:refreshPage(ignoreSelectFirst, itemId)
	if not self.curComponent then
		return
	end

	self.curComponent:refreshPage(ignoreSelectFirst, itemId)
end

function AppearanceV2Ctrl:onModelSkeletonLoaded()
	if self.curComponent and self.curComponent.onModelSkeletonLoaded then
		self.curComponent:onModelSkeletonLoaded()
	end
end

function AppearanceV2Ctrl:onPartModelLoaded()
	if self.curComponent and self.curComponent.onPartModelLoaded then
		self.curComponent:onPartModelLoaded()
	end
end

function AppearanceV2Ctrl:initComponents()
	local defaultPetId = pg.me:getAvatarFirstOrDefaultPetId()

	self.rightInfoComponent = RightInfoComponent.new(self)
	self.components.pet = PetComponent.new(self, self.view.playerTransform, {
		petId = self.curPetId or defaultPetId
	})
	self.components.player = PlayerComponent.new(self, self.view.playerTransform)
	self.components.workShopHome = WorkShopHomeComponent.new(self, self.view.workShopTransform)
	self.components.photoStudioEdit = PhotoStudioEditComponent.new(self, self.view.photographRoomTransform)
end

function AppearanceV2Ctrl:onBuyItems(data)
	if self.curComponent and self.curComponent.onBuyItems then
		self.curComponent:onBuyItems(data)
	end
end

function AppearanceV2Ctrl:onMoneyChanged(data)
	self:refreshCurrencyList()
end

function AppearanceV2Ctrl:onGetVitalityScore(data)
	if self.isClosingPanel then
		return
	end

	local pInfo = pg.me:getPetInfo(self.curPetId)
	local argsData = {}

	argsData.petScoreData = self.petScoreData
	argsData.accessoryScoreData = self.components.pet.accessoryScoreData
	argsData.entityId = pInfo.templateId
	argsData.petId = self.curPetId
	argsData.tryAccessData = self.model:getTryAccessData()

	pg.global.ui:close(UIConst.UI_ID_PETEVENT_PETCHOICE)
	self:closePanel(true)
	self.adapter:blackFadeIn(0.05)
	pg.global.ui:open(UIConst.UI_ID_PETEVENT_SETTLEMENT, argsData)
end

function AppearanceV2Ctrl:onInputDeviceChanged(deviceType)
	return
end

function AppearanceV2Ctrl:refreshCurrencyList()
	LuaUIUtils.setTopCurrencyItemList(self.view.currencyUList, UIConst.UI_ID_APPEARANCE_V2)
end

function AppearanceV2Ctrl:onPresetSave(info)
	local res, tabBtn = self.view.titleTabUList:TryGetChildAt(0)

	if res then
		tabBtn:OnClickSimulate()

		if self.playerComponent then
			self.playerComponent:focusTab(info.tabName)
		end

		if self.playerComponent and self.playerComponent:checkUIShow() then
			self.playerComponent:refreshPreset(info.tabName)
		end
	end
end

function AppearanceV2Ctrl:onAvatarFashionScoreChanged(info)
	ClientTextUtils.setText(self.view.fashionNumUSDFText, string.format(pg.getGameString("AVATAR_FASHION_TIP_1"), info.newValue))
end

function AppearanceV2Ctrl:delayRefreshDecal()
	return
end

function AppearanceV2Ctrl:passToRightInfoComponent(originCmp, extra)
	if self.inVitality then
		return
	end

	if not self.rightInfoComponent then
		return
	end

	local _, statePage = originCmp:TryGetCurrentPage("State")
	local _, detailPage = originCmp:TryGetCurrentPage("detail")
	local _, btnTypePage = originCmp:TryGetCurrentPage("BtnType")
	local wardrobe = self.view.wardrobeUContainer.content

	if not wardrobe or IsNil(wardrobe.gameObject) then
		return
	end

	local objectReference = self.view.playerTransform:GetComponent("ObjectReference")
	local rightTransform = objectReference:GetRefValue("rightTransform")

	if not rightTransform or IsNil(rightTransform.gameObject) then
		return
	end

	if statePage == self.model.RIGHT_INFO_CMP_STATE_PAGE_INDEX.Detail then
		rightTransform.gameObject:SetActiveEx(false)
		wardrobe.gameObject:SetActiveEx(true)
	else
		rightTransform.gameObject:SetActiveEx(true)
		wardrobe.gameObject:SetActiveEx(false)
	end

	self.rightInfoComponent:dealPassedControllers(detailPage, btnTypePage, wardrobe, objectReference, extra)
	self.rightInfoComponent:forceRenderSetList(wardrobe)
end

return AppearanceV2Ctrl
