-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomeCampManager\\HomeCampManagerCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomeCampManagerCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local HomeCampManagerCtrl = Class.LightClass("HomeCampManagerCtrl", UICtrl)
local Time = require("Core.Common.Time")
local UIConst = require("Const.UIConst")
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local NoticeDef = require("Common.NoticeDef")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientUtils = require("Utils.ClientUtils")
local ItemUtils = require("Common.Utils.ItemUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local TimerManager = require("Core.Timer.TimerManager")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local PetManagementUtils = require("Utils.PetManagementUtils")
local UILib_HomeCampPetDispatchInfo = require("Guis.Panels.UILibs.Pets.UILib_HomeCampPetDispatchInfo")
local HomeCampUtils = require("Utils.HomeCampUtils")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local ItemData = require("Data.item_data")
local HomeCampData = require("Data.home_camp_data")
local AddressDataConst = require("Const.AddressDataConst")
local HotkeyConst = require("Const.HotkeyConst")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local NAV_GROUP_LIST_REWARD = "ListReward"
local NAV_GROUP_LIST_PET_DOWN = "ListPetDown"

HomeCampManagerCtrl.NAV_GROUP_COM_PET_LIST = "ComPetList"

local CONSOLE_BAR_LISTENER_NAME = "HomeCampManager"
local DispatchListItemTempIds = {
	HasPet = 0,
	WaitDispatch = 3,
	NoPet_Lock = 2,
	NoPet_Unlock = 1
}

HomeCampManagerCtrl.messages = {
	[MessageName.HOME_CAR_CAMP_SWITCH_PET_DISPATCHUI] = {
		"forceSwitchToPetsMgrUI",
		true
	},
	[MessageName.HOME_CAR_CAMP_CHANGE_PETS] = {
		"changeCampPetSuc",
		true
	},
	[MessageName.HOME_CAR_CAMP_DISPATCH] = {
		"startDispatchSuc",
		true
	},
	[MessageName.HOME_CAR_CAMP_DISPATCH_STOP] = {
		"stopDispatchSuc",
		true
	},
	[MessageName.HOME_CAR_CAMP_DISPATCH_FINISH] = {
		"finishDispatchSuc",
		true
	},
	[MessageName.HOME_CAR_CAMP_DISPATCH_STATE_CHANGED] = {
		"dispatchStateChanged",
		true
	},
	[MessageName.HOME_CAR_CAMP_READY_REMOVE_PETS] = {
		"resetPetsSelectedInfo",
		true
	},
	[MessageName.HOME_CAR_CAMP_COMPLETE_REMOVE_PETS] = {
		"forceSwitchToCampMgrUI",
		true
	},
	[MessageName.HOME_CAR_CAMP_INFO_REFRESHED] = {
		"refreshExploreAreaInfo",
		true
	}
}

function HomeCampManagerCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
	self.model:init()

	self.m_uiLibPetsDispatchInfo = UILib_HomeCampPetDispatchInfo.new(self.view.delegateUComponent, self)

	function self.view.btnBackUButton.luaClick()
		self:m_onGamepadBack()
	end

	self.view.btnBackUButton:SetGamepadAction("Common/GamepadCancel")

	function self.view.listRewardUList.luaRenderItem(button, index, data)
		self:m_renderRewardItem(button, index, data)
	end

	self:refreshRootUI(UIConst.HOME_CAMP_MANAGER_PAGE_TYPE.CampMgr, true)
end

function HomeCampManagerCtrl:backUI()
	if self.m_pageType == UIConst.HOME_CAMP_MANAGER_PAGE_TYPE.CampMgr then
		self:close()
	else
		self:forceSwitchToCampMgrUI()
	end
end

function HomeCampManagerCtrl:addListener()
	UICtrl.addListener(self)

	if pg.global.navMgr then
		pg.global.navMgr:AddLuaFocusCursorMovedListener(CONSOLE_BAR_LISTENER_NAME, function()
			self:refreshConsoleBarState()
		end)
		pg.global.navMgr:AddLuaHotkeyActivationChangedListener(CONSOLE_BAR_LISTENER_NAME, function()
			self:refreshConsoleBarState()
		end)
	end

	function self.view.btnSwitchUButton.luaClick()
		self:onSwitchButtonClick()
	end

	self:refreshSwitchButtonInfo()
	self:bindVirtualHotKey(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonWest, "campMgrDismountBind", function()
		if self.m_pageType == UIConst.HOME_CAMP_MANAGER_PAGE_TYPE.CampMgr then
			local dispatchState = self.m_uiLibPetsDispatchInfo:getCampCarEntPetsState()

			if dispatchState == UIConst.HOME_CAMP_DISPATCH_STATE.UnDispatch and not self.m_uiLibPetsDispatchInfo:isShowingDispatchTypes() then
				self:forceSwitchToPetsMgrUI()
			end

			return
		end

		self:triggerFocusedPetDismount()
	end)
	self:m_setupCloseIntercept()
end

function HomeCampManagerCtrl:m_setupCloseIntercept()
	local go = self.view and self.view.widget and self.view.widget.gameObject

	if not go then
		return
	end

	local bind = KeyBindingPro.GetOrAddKeyBindingByName(go, "campMgrBackIntercept")

	bind.isVirtual = true
	bind.priority = 0
	bind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonEast

	function bind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			if not pg.game.input or not pg.game.input:isUsingGamepad() then
				return true
			end

			self:m_onGamepadBack()

			return false
		end

		return true
	end
end

function HomeCampManagerCtrl:m_onGamepadBack()
	if self.m_backGuard then
		return
	end

	self.m_backGuard = true

	TimerManager.addNextFrameCb(function()
		self.m_backGuard = false
	end)

	local navMgr = CS.XGUI.Navigation.NavManager.Instance

	if navMgr and navMgr.IsInModalGroup and navMgr:IsInModalGroup() and self:m_tryExitModalGroup() then
		return
	end

	self:backUI()
end

function HomeCampManagerCtrl:m_tryExitModalGroup()
	local navMgr = CS.XGUI.Navigation.NavManager.Instance

	if not navMgr then
		return false
	end

	if self.m_pageType == UIConst.HOME_CAMP_MANAGER_PAGE_TYPE.DispatchMgr and navMgr.TryFocusFirstAvailable then
		navMgr:TryFocusFirstAvailable()

		if navMgr.IsInModalGroup and navMgr:IsInModalGroup() and navMgr.ClearFocus then
			navMgr:ClearFocus()
		end
	elseif navMgr.ClearFocus then
		navMgr:ClearFocus()
	end

	if navMgr.IsInModalGroup and navMgr:IsInModalGroup() then
		return false
	end

	self:refreshConsoleBarState()

	return true
end

function HomeCampManagerCtrl:refreshConsoleBarState()
	local navMgr = CS.XGUI.Navigation.NavManager.Instance

	if not navMgr then
		return
	end

	local groupName = navMgr.CurrentFocusedGroupName
	local isDispatchMgr = self.m_pageType == UIConst.HOME_CAMP_MANAGER_PAGE_TYPE.DispatchMgr
	local isCampMgr = self.m_pageType == UIConst.HOME_CAMP_MANAGER_PAGE_TYPE.CampMgr
	local isPetDownFocused = groupName == NAV_GROUP_LIST_PET_DOWN
	local canSelect = isCampMgr and groupName == NAV_GROUP_LIST_REWARD or isDispatchMgr and groupName == HomeCampManagerCtrl.NAV_GROUP_COM_PET_LIST
	local dispatchState = self.m_uiLibPetsDispatchInfo:getCampCarEntPetsState()
	local canEdit = isCampMgr and dispatchState == UIConst.HOME_CAMP_DISPATCH_STATE.UnDispatch and not self.m_uiLibPetsDispatchInfo:isShowingDispatchTypes()
	local canRemove = isDispatchMgr and isPetDownFocused and self:m_isFocusedPetRemovable(navMgr)

	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("canSelect", not not canSelect)
	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("canEdit", not not canEdit)
	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("canReplace", not not canRemove)
end

function HomeCampManagerCtrl:refreshPetListNavigationState(isShowingDispatchTypes)
	local navMgr = pg.global.navMgr

	if not navMgr then
		return
	end

	local enableNavigation = self.m_pageType == UIConst.HOME_CAMP_MANAGER_PAGE_TYPE.DispatchMgr or isShowingDispatchTypes

	navMgr:SetNavGroupForceNonInteractable(NAV_GROUP_LIST_PET_DOWN, not enableNavigation)

	if not enableNavigation and navMgr.CurrentFocusedGroupName == NAV_GROUP_LIST_PET_DOWN then
		navMgr:ClearFocus()
	end
end

function HomeCampManagerCtrl:m_syncNavFocus(button)
	if not button or IsNil(button) then
		return
	end

	local navMgr = CS.XGUI.Navigation.NavManager.Instance

	if not navMgr or not navMgr.FocusItem then
		return
	end

	local cur = navMgr.CurrentFocusedUContent

	if not IsNil(cur) and cur.gameObject == button.gameObject then
		return
	end

	navMgr:FocusItem(button)
end

function HomeCampManagerCtrl:onItemFocused(button)
	self:m_syncNavFocus(button)
	self:refreshConsoleBarState()
end

function HomeCampManagerCtrl:triggerFocusedPetDismount()
	if self.m_pageType ~= UIConst.HOME_CAMP_MANAGER_PAGE_TYPE.DispatchMgr then
		return
	end

	local navMgr = CS.XGUI.Navigation.NavManager.Instance

	if not navMgr or not self:m_isFocusedPetRemovable(navMgr) then
		return
	end

	local navItem = navMgr.CurrentFocusedUContent

	if not navItem or IsNil(navItem) then
		return
	end

	local data = navItem.dataFromUList
	local campPetInfo = data and data.campPetInfo

	if not campPetInfo then
		return
	end

	if self.m_uiLibPetsDispatchInfo and self.m_uiLibPetsDispatchInfo.m_removeFocusedCampPet then
		self.m_pendingFocusGroup = NAV_GROUP_LIST_PET_DOWN

		self.m_uiLibPetsDispatchInfo:m_removeFocusedCampPet(campPetInfo)
	end
end

function HomeCampManagerCtrl:bindVirtualHotKey(actionPath, bindName, func)
	local target = self.view and self.view.transform and self.view.transform.gameObject

	if not target then
		return
	end

	local bind = KeyBindingPro.GetOrAddKeyBindingByName(target, bindName)

	bind.actionPath = actionPath
	bind.isVirtual = true
	bind.priority = -1

	function bind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			if not pg.game.input or not pg.game.input:isUsingGamepad() then
				return
			end

			func()
		end
	end
end

function HomeCampManagerCtrl:requestFocusFirstSlot()
	if self.focusFirstSlotTimer then
		TimerManager.removeTimer(self.focusFirstSlotTimer)

		self.focusFirstSlotTimer = nil
	end

	self.focusFirstSlotTimer = TimerManager.addNextFrameCb(function()
		self.focusFirstSlotTimer = nil

		local navMgr = CS.XGUI.Navigation.NavManager.Instance
		local pendingGroup = self.m_pendingFocusGroup

		self.m_pendingFocusGroup = nil

		if pendingGroup and navMgr and navMgr.FocusGroupByName and navMgr:FocusGroupByName(pendingGroup, false) then
			self:refreshConsoleBarState()

			return
		end

		if navMgr and navMgr.TryFocusFirstAvailable then
			navMgr:TryFocusFirstAvailable()
		end

		self:refreshConsoleBarState()
	end)
end

function HomeCampManagerCtrl:m_isFocusedPetRemovable(navMgr)
	local navItem = navMgr and navMgr.CurrentFocusedUContent
	local data = navItem and navItem.dataFromUList

	if not data then
		return false
	end

	local dispatchState = self.m_uiLibPetsDispatchInfo and self.m_uiLibPetsDispatchInfo:getCampCarEntPetsState() or UIConst.HOME_CAMP_DISPATCH_STATE.UnDispatch

	if dispatchState ~= UIConst.HOME_CAMP_DISPATCH_STATE.UnDispatch then
		return false
	end

	return data.type == 1 and data.tIndex == 0 and not data.isLock and data.campPetInfo ~= nil
end

function HomeCampManagerCtrl:onDestroy()
	if pg.global.navMgr then
		pg.global.navMgr:SetNavGroupForceNonInteractable(NAV_GROUP_LIST_PET_DOWN, false)
		pg.global.navMgr:RemoveLuaFocusCursorMovedListener(CONSOLE_BAR_LISTENER_NAME)
		pg.global.navMgr:RemoveLuaHotkeyActivationChangedListener(CONSOLE_BAR_LISTENER_NAME)
	end

	if self.focusFirstSlotTimer then
		TimerManager.removeTimer(self.focusFirstSlotTimer)

		self.focusFirstSlotTimer = nil
	end

	self.m_uiLibPetsDispatchInfo:onDestroy()
	UICtrl.onDestroy(self)
end

function HomeCampManagerCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	self.m_uiLibPetsDispatchInfo.btnConfirmUButton:RemoveLuaGamepadHotkey()
	self:refreshExploreAreaInfo()
end

function HomeCampManagerCtrl:onShow()
	return
end

function HomeCampManagerCtrl:onHide()
	return
end

function HomeCampManagerCtrl:getCampCarEnt()
	local carUid = pg.me and pg.me.uid

	return HomeLandUtils.getCampCarEntity(carUid)
end

function HomeCampManagerCtrl:forceSwitchToPetsMgrUI()
	self.m_pendingFocusGroup = HomeCampManagerCtrl.NAV_GROUP_COM_PET_LIST

	self:refreshRootUI(UIConst.HOME_CAMP_MANAGER_PAGE_TYPE.DispatchMgr, true)
end

function HomeCampManagerCtrl:forceSwitchToCampMgrUI()
	self:refreshRootUI(UIConst.HOME_CAMP_MANAGER_PAGE_TYPE.CampMgr, true)
end

function HomeCampManagerCtrl:forceSwitchToCurUI()
	self:refreshRootUI(self.m_pageType, true)
end

function HomeCampManagerCtrl:refreshRootUI(pageType, forceSet)
	if not forceSet and self.m_pageType == pageType then
		return
	end

	self.m_pageType = pageType

	self.view.rootUComponent:TryChangePage("Type", self.m_pageType)

	local titleKey = pageType == UIConst.HOME_CAMP_MANAGER_PAGE_TYPE.CampMgr and "HOMECAMP_PET_TRAVEL" or "HOME_CAMP_CAR_DISPATCH_MGR"

	ClientTextUtils.setText(self.view.backUSDFText, pg.getGameString(titleKey))
	ClientTextUtils.setText(self.view.txtTipsUSDFText, pg.getGameString("CAMP_PET_CANT_BATTLE_HINT"))
	self:m_refreshPetsList()
	self:m_refreshListRewards()
	self:switch3DScene()
	self:setSceneDisplayPets()
	self:trySetSceneDisplayPetsDisplay()
	self:m_refreshDispatchDetail(forceSet)
	self:refreshConsoleBarState()
	self:requestFocusFirstSlot()
end

function HomeCampManagerCtrl:refreshBoardTopLogo()
	local selfCarGroup = pg.game.homeCar:getHomeCarGroup(pg.me.uid)

	if selfCarGroup then
		selfCarGroup:refreshPetInfos()
	end
end

function HomeCampManagerCtrl:m_refreshPetsList()
	if self.m_pageType ~= UIConst.HOME_CAMP_MANAGER_PAGE_TYPE.DispatchMgr then
		return
	end

	PetManagementUtils.setListButtonDelegateTable({
		selectedChanged = function(data)
			self:onSelectedChanged(data)
		end,
		renderExtraLogic = function(button, index, data)
			button.draggable = false
		end
	})

	PetManagementUtils.displayType = UIConst.PET_SLOT_DISPLAY_TYPE.Homeland
	PetManagementUtils.dynamicUpdateDropWidget = true

	PetManagementUtils.initSimpleMidTemplate(self.view.petListTransform, nil, true, UIConst.PET_SLOT_SUB_DISPLAY_TYPE.Homeland_Camp)
end

function HomeCampManagerCtrl:onSelectedChanged(petInfo)
	if not petInfo then
		return
	end

	local petId = petInfo.id
	local toastKey

	if ClientUtils.checkPetIsFollowPet(petId) then
		toastKey = "HOME_CAR_CAMP_PET_TO_CAMP_DISPATCH_CONFIRM"
	else
		local cachePetIds = self.model:getUICacheCampPetIds()

		if cachePetIds and next(cachePetIds) then
			for _, v in ipairs(cachePetIds) do
				if v == petId then
					toastKey = "HOME_CAR_CAMP_PET_ALREADY_IN_CAMP"

					break
				end
			end
		end
	end

	if toastKey then
		local totastL10nTxt = pg.getGameString(toastKey)

		ClientUtils.showConfirmRaw(pg.getGameString("WARNING"), totastL10nTxt, function()
			self.model:tryAddCacheCampPets(petInfo, true)
		end, false)
	else
		self.model:tryAddCacheCampPets(petInfo, true)
	end
end

function HomeCampManagerCtrl:m_refreshDispatchDetail(forceSet)
	self.m_uiLibPetsDispatchInfo:setDataAndRefresh(self.m_pageType, forceSet)
end

function HomeCampManagerCtrl:m_refreshListRewards()
	local campId = self:getSelectedExploreAreaId() or 0
	local homeCampData = HomeCampData[campId]

	if homeCampData then
		ClientTextUtils.setText(self.view.txtRewardUSDFText, pg.getFormatText(pg.getGameString("HOMECAMP_PET_TRAVEL_EARN"), pg.getLocalizationText(homeCampData.name)))
	end

	local cfgItemIds = HomeCampUtils.getCarDispatchPreviewRewardItemIds(self:getCampCarEnt(), campId)
	local items = {}

	for _, itemId in ipairs(cfgItemIds) do
		local itemCfg = ItemData[itemId] or {}
		local icon = itemCfg and itemCfg.icon or ""

		table.insert(items, {
			id = itemId,
			iconUrl = icon,
			unkownInfoText = pg.getGameString("HOME_CAMP_UNKOWN_REWARD_TIP")
		})
	end

	HomeCampUtils.trySetUnknownDispatchItem(items, true)

	local extraRewardItemIds = HomeCampUtils.getCampDisplayExtraRewardList(campId)

	for index, itemId in ipairs(extraRewardItemIds) do
		local itemCfg = ItemData[itemId] or {}

		table.insert(items, index, {
			id = itemId,
			iconUrl = itemCfg.icon or ""
		})
	end

	self.view.listRewardUList:SetList(items)
end

function HomeCampManagerCtrl:m_renderRewardItem(button, index, data)
	if not data then
		return
	end

	LuaUIUtils.renderRewardItem(button, data)

	function button.luaHover()
		self:onItemFocused(button)
	end
end

function HomeCampManagerCtrl:changeCampPetSuc()
	if self.m_pageType == UIConst.HOME_CAMP_MANAGER_PAGE_TYPE.DispatchMgr then
		PetManagementUtils.refreshPetList()
	end

	self:setSceneDisplayPets()
	self.m_uiLibPetsDispatchInfo:resetSelectedData()
	self.m_uiLibPetsDispatchInfo:refreshUI()
	self:refreshBoardTopLogo()
	self:refreshConsoleBarState()
	self:requestFocusFirstSlot()
end

function HomeCampManagerCtrl:startDispatchSuc()
	self:setSceneDisplayPetsDisplay(false)
	self:refreshBoardTopLogo()
	self:close()
end

function HomeCampManagerCtrl:stopDispatchSuc()
	self:setSceneDisplayPetsDisplay(true)
	self.m_uiLibPetsDispatchInfo:resetSelectedData()
	self.m_uiLibPetsDispatchInfo:refreshUI()
	self:refreshBoardTopLogo()
	self:refreshConsoleBarState()
end

function HomeCampManagerCtrl:dispatchStateChanged()
	self.m_uiLibPetsDispatchInfo:refreshUI()
end

function HomeCampManagerCtrl:finishDispatchSuc(rewardArgs)
	local campCarEnt = self:getCampCarEnt()

	if not campCarEnt then
		return
	end

	self:refreshBoardTopLogo()
	self:setSceneDisplayPetsDisplay(true)
	self.m_uiLibPetsDispatchInfo:resetSelectedData()
	self.m_uiLibPetsDispatchInfo:refreshUI()
end

function HomeCampManagerCtrl:resetPetsSelectedInfo()
	PetManagementUtils.setSelectedPet(-1)
end

function HomeCampManagerCtrl:switch3DScene()
	local scene = pg.game.uiScene:getScene(UISceneConst.HOME_CAMP_RVPETS_SCENE)

	if not scene or not scene:isCreated() then
		return
	end

	scene:switchToPage(self.m_pageType)
end

function HomeCampManagerCtrl:setSceneDisplayPets()
	local scene = pg.game.uiScene:getScene(UISceneConst.HOME_CAMP_RVPETS_SCENE)

	if not scene or not scene:isCreated() then
		return
	end

	local campCarEnt = self:getCampCarEnt()
	local campPetIds = campCarEnt and campCarEnt:getCampPetIds() or {}

	scene:setSceneDisplayPets(self.m_pageType, campPetIds)
end

function HomeCampManagerCtrl:trySetSceneDisplayPetsDisplay()
	local scene = pg.game.uiScene:getScene(UISceneConst.HOME_CAMP_RVPETS_SCENE)

	if not scene or not scene:isCreated() then
		return
	end

	local campCarEnt = self:getCampCarEnt()
	local carEntDispatchState = campCarEnt and campCarEnt:getCampPetDispatchState() or UIConst.HOME_CAMP_DISPATCH_STATE.UnDispatch

	if carEntDispatchState == UIConst.HOME_CAMP_DISPATCH_STATE.Dispatching then
		scene:setSceneDisplayPetsDisplay(false)
	else
		scene:setSceneDisplayPetsDisplay(true)
	end
end

function HomeCampManagerCtrl:setSceneDisplayPetsDisplay(isShow)
	local scene = pg.game.uiScene:getScene(UISceneConst.HOME_CAMP_RVPETS_SCENE)

	if not scene or not scene:isCreated() then
		return
	end

	scene:setSceneDisplayPetsDisplay(isShow)
end

function HomeCampManagerCtrl:isPrivateHomeCamp()
	local campInfo = pg.me and pg.me.getPlayerHomeCampInfo and pg.me:getPlayerHomeCampInfo()
	local lineInfo = campInfo and campInfo.lineInfo

	return lineInfo and lineInfo.isPrivate or false
end

function HomeCampManagerCtrl:getSelectedExploreAreaId()
	local dispatchInfo = pg.me and pg.me.campDispatchInfo
	local dispatchCampId = dispatchInfo and dispatchInfo.campId

	if dispatchInfo and (dispatchInfo.endTs or 0) > 0 and not dispatchInfo.isFinished and dispatchCampId and HomeCampData[dispatchCampId] and ClientUtils.checkHomeCampUnlock(dispatchCampId) then
		self.m_selectedExploreAreaId = dispatchCampId

		return dispatchCampId
	end

	local selectedAreaId = self.m_selectedExploreAreaId

	if self:isPrivateHomeCamp() and selectedAreaId and HomeCampData[selectedAreaId] and ClientUtils.checkHomeCampUnlock(selectedAreaId) then
		return selectedAreaId
	end

	local currentCampStaticId = pg.me and pg.me.curCampStaticId

	if currentCampStaticId and HomeCampData[currentCampStaticId] and ClientUtils.checkHomeCampUnlock(currentCampStaticId) then
		self.m_selectedExploreAreaId = currentCampStaticId

		return currentCampStaticId
	end

	self.m_selectedExploreAreaId = nil

	return nil
end

function HomeCampManagerCtrl:refreshExploreAreaInfo()
	self:refreshSwitchButtonInfo()
	self:m_refreshListRewards()
end

function HomeCampManagerCtrl:refreshSwitchButtonInfo()
	local objectReference = self.view.btnSwitchUButton:GetComponent("ObjectReference")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local selectedAreaId = self:getSelectedExploreAreaId()
	local selectedCampCfg = HomeCampData[selectedAreaId or 0]
	local areaName = selectedCampCfg and pg.getLocalizationText(selectedCampCfg.name) or ""

	ClientTextUtils.setText(txtNameUSDFText, areaName)
	self.view.btnSwitchUButton:SetActive(true)
	self.view.btnSwitchUButton:TryChangePage("Unlock", self:isPrivateHomeCamp() and 0 or 1)
end

function HomeCampManagerCtrl:onExploreAreaConfirm(areaData)
	local campStaticId = areaData and (areaData.campStaticId or areaData.id)

	if not campStaticId or not HomeCampData[campStaticId] or not ClientUtils.checkHomeCampUnlock(campStaticId) then
		return
	end

	self.m_selectedExploreAreaId = campStaticId

	self:refreshExploreAreaInfo()
end

function HomeCampManagerCtrl:onSwitchButtonClick()
	if self.m_pageType ~= UIConst.HOME_CAMP_MANAGER_PAGE_TYPE.CampMgr or pg.global.ui:checkUIOpen(UIConst.UI_ID_HOME_CAMP_CHOOSE_EXPLORE_AREA) then
		return
	end

	if not self:isPrivateHomeCamp() then
		pg.global.showBubbleMessageById(NoticeDef.HOME_CAMP_SWITCH_EXPLORE_AREA_INVALID)

		return
	end

	local dispatchState = HomeCampUtils.getPlayerCarPetsDispatchState(self:getCampCarEnt())

	if dispatchState ~= UIConst.HOME_CAMP_DISPATCH_STATE.UnDispatch then
		pg.global.showBubbleMessageById(NoticeDef.HOME_CAMP_CANT_SWITCH_AREA_IN_EXPLORING)

		return
	end

	pg.global.ui.homeCampChooseExploreArea:open({
		selectedAreaId = self:getSelectedExploreAreaId(),
		onConfirm = function(areaData)
			self:onExploreAreaConfirm(areaData)
		end
	})
end

return HomeCampManagerCtrl
