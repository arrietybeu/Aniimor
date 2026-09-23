-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandPetManageNew\\HomelandPetManageNewCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomelandPetManageNewCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local HomelandPetBoxComponent = require("Guis.Panels.HomelandPetManage.Component.HomelandPetBoxComponent")
local HomelandFoodComponent = require("Guis.Panels.HomelandPetManage.Component.HomelandFoodComponent")
local RedDotConst = require("Const.RedDotConst")
local HotkeyConst = require("Const.HotkeyConst")
local TimerManager = require("Core.Timer.TimerManager")
local ClientTextUtils = require("Utils.ClientTextUtils")
local lume = require("Core.Common.lume")
local NoticeDef = require("Common.NoticeDef")
local Const = require("Common.Const.Const")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local HomelandPetManageNewCtrl = Class.LightClass("HomelandPetManageNewCtrl", UICtrl)
local PetData = require("Data.pet_data")
local PetManagementUtils = require("Utils.PetManagementUtils")
local RogueUtils = require("Utils.RogueUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")

HomelandPetManageNewCtrl.MAIN_TAB = {
	FOOD = 1,
	PET = 0
}
HomelandPetManageNewCtrl.NAV_GROUP = {
	PET_LIST = "ComPetList",
	HOME_BOX = "RightInfoHomePet",
	FOOD_PANEL = "PanelBtnFood",
	FOOD_LIST = "FoodListPetHome"
}
HomelandPetManageNewCtrl.messages = {
	[MessageName.HOMELAND_PETS_CHANGE] = {
		"refreshPetList",
		true
	},
	[MessageName.HOMELAND_PET_BOX_CAPACITY_CHANGED] = {
		"onPetBoxCapacityChanged",
		true
	},
	[MessageName.HOMELAND_AREA_LOCK_STATE_CHANGED] = {
		"onAreaLockStateChanged",
		true
	},
	[MessageName.HOMELAND_ORNAMENT_CHANGED] = {
		"onAbilityRequirementChanged",
		true
	},
	[MessageName.HOMELAND_FOOD_INFO_REFRESH] = {
		"onHomelandFoodInfoChange",
		true
	},
	[MessageName.HOMELAND_ITEM_MAP_CHANGED] = {
		"onItemMapChange",
		true
	}
}

function HomelandPetManageNewCtrl:onCreate(info)
	info = info or {}
	self.defaultTab = info.defaultTab or 0
	self.currentPetAreaId = info.areaId or Const.HOMELAND_AREA_TYPE.PRODUCE

	if not HomeLandUtils.canUseHomePetBoxArea(pg.space, self.currentPetAreaId) then
		self.currentPetAreaId = Const.HOMELAND_AREA_TYPE.PRODUCE
	end

	self.mainTabButtons = {}
	self.petTabRedDotButton = nil
	self.foodTabRedDotButton = nil

	PetManagementUtils.setIsHidePetBoxEditorLockIcon(true)
	UICtrl.onCreate(self, info)
end

function HomelandPetManageNewCtrl:initMainTab()
	local petLabel = self.view.txtPetTabUSDFText.text
	local foodLabel = self.view.txtFoodTabUSDFText.text

	self.view.legacyMainTabUWidget:SetActive(false)

	function self.view.listMainTabUList.luaRenderItem(button, index, data)
		LuaUIUtils.renderTitleTab(button, index, data)

		self.mainTabButtons[data.tab] = button

		if data.tab == HomelandPetManageNewCtrl.MAIN_TAB.PET and self.petTabRedDotButton ~= button then
			self.petTabRedDotButton = button

			pg.global.setPreViewRedDot(RedDotConst.RedDotPath.HOMELAND_PET_BOX_CAPACITY, button, function()
				return self.model:redDot_GetPetBoxCapacityState()
			end)
		elseif data.tab == HomelandPetManageNewCtrl.MAIN_TAB.FOOD and self.foodTabRedDotButton ~= button then
			self.foodTabRedDotButton = button

			self:refreshReddot()
		end
	end

	function self.view.listMainTabUList.luaClick(button, data)
		self.view.widget:TryChangePage("Tab", data.tab)
		self:refreshReddot()
	end

	self.view.listMainTabUList:SetList({
		{
			tIndex = 0,
			label = petLabel,
			tab = HomelandPetManageNewCtrl.MAIN_TAB.PET,
			selected = self.defaultTab == HomelandPetManageNewCtrl.MAIN_TAB.PET
		},
		{
			tIndex = 2,
			label = foodLabel,
			tab = HomelandPetManageNewCtrl.MAIN_TAB.FOOD,
			selected = self.defaultTab == HomelandPetManageNewCtrl.MAIN_TAB.FOOD
		}
	})
	self.view.listMainTabUList:SelectItem(self.defaultTab, false)
end

function HomelandPetManageNewCtrl:addListener()
	function self.view.widget.luaTryChangePage(name, pageIdx, lastIdx)
		if name == "Tab" then
			self.view.listMainTabUList:SelectItem(pageIdx, false)

			if pageIdx == 1 then
				if not self.homeFood then
					self.homeFood = HomelandFoodComponent.new(self, self.view.tabFoodUWidget)
				end
			else
				if not self.homePetBox then
					self.homePetBox = HomelandPetBoxComponent.new(self, self.view.tabPetUContainer, {
						areaId = self.currentPetAreaId
					})
				else
					self.model:redDot_RecordPetBoxCapacityRead()
				end

				self:focusDefaultPetListItem()
			end

			if lastIdx == 0 and pageIdx ~= lastIdx then
				pg.global.refreshRedDotState(RedDotConst.RedDotPath.HOMELAND_PET_BOX_CAPACITY)
			end
		end
	end

	self:initMainTab()
	self:bindHotKeyPerform(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadLeftShoulder, function()
		if not pg.game.input or not pg.game.input:isUsingGamepad() then
			return
		end

		local success, currentTab = self.view.widget:TryGetCurrentPage("Tab")

		if success and currentTab ~= HomelandPetManageNewCtrl.MAIN_TAB.PET then
			self.view.widget:TryChangePage("Tab", HomelandPetManageNewCtrl.MAIN_TAB.PET)
		end
	end)
	self:bindHotKeyPerform(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadRightShoulder, function()
		if not pg.game.input or not pg.game.input:isUsingGamepad() then
			return
		end

		local success, currentTab = self.view.widget:TryGetCurrentPage("Tab")

		if success and currentTab ~= HomelandPetManageNewCtrl.MAIN_TAB.FOOD then
			self.view.widget:TryChangePage("Tab", HomelandPetManageNewCtrl.MAIN_TAB.FOOD)
		end
	end)

	if self.defaultTab == 0 then
		self.homePetBox = HomelandPetBoxComponent.new(self, self.view.tabPetUContainer, {
			areaId = self.currentPetAreaId
		})
	else
		self:switchToFood()
	end

	function self.view.btnBackUButton.luaClick()
		self:closePanel()
	end

	ClientTextUtils.setText(self.view.tMPUSDFText, pg.getGameString("HOMELAND_PLOT_PET_MANAGE"))

	if not self.foodTabRedDotButton then
		self:refreshReddot()
	end

	if CS.XGUI.Navigation.NavManager.Instance then
		CS.XGUI.Navigation.NavManager.Instance:AddLuaFocusCursorMovedListener("HomelandPetManageNew", function()
			self:refreshConsoleBarState()
		end)
		CS.XGUI.Navigation.NavManager.Instance:AddLuaHotkeyActivationChangedListener("HomelandPetManageNew", function()
			self:refreshConsoleBarState()
		end)
	end

	self:bindHotKeyPerform(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonNorth, function()
		if not pg.game.input or not pg.game.input:isUsingGamepad() then
			return true
		end

		if not self.homePetBox then
			return true
		end

		if self.homePetBox.inBatchMode then
			return true
		end

		local navMgr = CS.XGUI.Navigation.NavManager.Instance

		if not navMgr then
			return true
		end

		local groupName = navMgr.CurrentFocusedGroupName

		if groupName == HomelandPetManageNewCtrl.NAV_GROUP.PET_LIST then
			self:onGamepadNorthPutPetToBox()
			self.homePetBox:closePetTip()
		elseif groupName == HomelandPetManageNewCtrl.NAV_GROUP.HOME_BOX then
			self:onGamepadNorthTakePetFromBox()
			self.homePetBox:closePetTip()
		else
			return true
		end
	end)
end

function HomelandPetManageNewCtrl:refreshConsoleBarState()
	if CS.XGUI.Navigation.NavManager.Instance then
		local groupName = CS.XGUI.Navigation.NavManager.Instance.CurrentFocusedGroupName
		local canPutIn = groupName == HomelandPetManageNewCtrl.NAV_GROUP.PET_LIST
		local canTakeOut = groupName == HomelandPetManageNewCtrl.NAV_GROUP.HOME_BOX
		local foodSlotList = pg.space.homeFoodSlotList
		local space = pg.space
		local isWorking = foodSlotList:isWorking(space)
		local canTakeOutFood = groupName == HomelandPetManageNewCtrl.NAV_GROUP.FOOD_LIST and isWorking
		local isPetBatchMode = self:isPetTabActive() and self.homePetBox and self.homePetBox.inBatchMode
		local isPetTipOpen = self:isPetTabActive() and self.homePetBox and self.homePetBox:isPetTipOpen()
		local canCheck = not isPetBatchMode and not isPetTipOpen
		local canSelect = isPetBatchMode or isPetTipOpen or groupName == HomelandPetManageNewCtrl.NAV_GROUP.FOOD_PANEL

		CS.XGUI.Navigation.ConsoleBar.SetStateForAll("canPutIn", canPutIn)
		CS.XGUI.Navigation.ConsoleBar.SetStateForAll("canTakeOut", canTakeOut)
		CS.XGUI.Navigation.ConsoleBar.SetStateForAll("canCheck", canCheck and not canSelect)
		CS.XGUI.Navigation.ConsoleBar.SetStateForAll("canSelect", canSelect)
		CS.XGUI.Navigation.ConsoleBar.SetStateForAll("canTakeOutFood", canTakeOutFood)
	end
end

function HomelandPetManageNewCtrl:isPetTabActive()
	if not self.view or not self.view.widget then
		return false
	end

	local success, pageIdx = self.view.widget:TryGetCurrentPage("Tab")

	return success and pageIdx == HomelandPetManageNewCtrl.MAIN_TAB.PET
end

function HomelandPetManageNewCtrl:scheduleGamepadFocus(resolveButton)
	if not pg.game.input or not pg.game.input:isUsingGamepad() then
		return
	end

	if self._gamepadFocusFrameId then
		TimerManager.delFrameCb(self._gamepadFocusFrameId)

		self._gamepadFocusFrameId = nil
	end

	self._gamepadFocusFrameId = TimerManager.addNextFrameCb(function()
		self._gamepadFocusFrameId = nil

		if not pg.game.input or not pg.game.input:isUsingGamepad() then
			return
		end

		local button = resolveButton and resolveButton()

		if IsNil(button) or not button.gameObject.activeInHierarchy then
			return
		end

		if not button.isNavFocused and not button:TryNavFocus() then
			local navMgr = CS.XGUI.Navigation.NavManager.Instance

			if navMgr then
				navMgr:FocusItem(button)
			end
		end
	end)
end

function HomelandPetManageNewCtrl:focusDefaultPetListItem()
	if not self:isPetTabActive() then
		return
	end

	self:scheduleGamepadFocus(function()
		local buttons = PetManagementUtils._getPetListButtons()

		return buttons and buttons[0]
	end)
end

function HomelandPetManageNewCtrl:getFocusedHomePetSlot()
	if not pg.game.input or not pg.game.input:isUsingGamepad() then
		return
	end

	local navMgr = CS.XGUI.Navigation.NavManager.Instance

	if not navMgr or navMgr.CurrentFocusedGroupName ~= HomelandPetManageNewCtrl.NAV_GROUP.HOME_BOX then
		return
	end

	local navItem = navMgr.CurrentFocusedUContent
	local data = navItem and navItem.dataFromUList

	return data and data.slotIdx
end

function HomelandPetManageNewCtrl:restoreHomePetFocus(slotIdx)
	if not slotIdx then
		return
	end

	self:scheduleGamepadFocus(function()
		local list = self.homePetBox and self.homePetBox.listPetHomeUList

		if not list then
			return
		end

		local success, button = list:TryGetChildAt(slotIdx - 1)

		return success and button or nil
	end)
end

function HomelandPetManageNewCtrl:onGamepadNorthPutPetToBox()
	local navMgr = CS.XGUI.Navigation.NavManager.Instance
	local navItem = navMgr and navMgr.CurrentFocusedUContent

	if not navItem then
		return
	end

	local data = navItem.dataFromUList

	if not data or data.isEmpty or not data.id then
		return
	end

	local space = pg.space
	local canAddPet = space and space.petBoxMap and space.petBoxMap:canHoldPetCount(1)

	if not canAddPet then
		pg.global.showBubbleMessage(NoticeDef.HOME_ERROR_PET_UPPER_LIMIT)

		return
	end

	local petId = data.id
	local player = pg.me

	if not player or not player:checkHomelandAddPet(petId) then
		return
	end

	local petPrepareInfoList = player.petPrepareList or {}
	local prepareFormationList = player.prepareFormationList
	local exploreFormation = prepareFormationList and prepareFormationList[1] and prepareFormationList[1].exploreFormation
	local isCombatPet = lume.find(petPrepareInfoList, petId) ~= nil
	local isExplore = exploreFormation and lume.find(exploreFormation, petId) ~= nil
	local isInRogue = RogueUtils.isPetInRogue(petId)

	if isInRogue then
		pg.global.ui.tips:showTextTip(pg.getGameString("PET_IN_ROGUE_BATTLE"))
	elseif isCombatPet or isExplore then
		pg.global.showConfirmMsgRaw(pg.getGameString("RELEASE_WARN"), pg.getGameString("HOME_BATTLE_PET_REMOVE_CHECK"), function()
			pg.me.space:addHomelandPetBatch({
				petId
			}, self.currentPetAreaId)
		end, false)
	else
		pg.me.space:addHomelandPetBatch({
			petId
		}, self.currentPetAreaId)
	end
end

function HomelandPetManageNewCtrl:onGamepadNorthTakePetFromBox()
	local listPetHomeUList = self.homePetBox.listPetHomeUList

	if not listPetHomeUList then
		return
	end

	local navMgr = CS.XGUI.Navigation.NavManager.Instance
	local navItem = navMgr and navMgr.CurrentFocusedUContent

	if not navItem then
		return
	end

	local data = listPetHomeUList:GetData(navItem)

	if not data or data.isEmpty or not data.id then
		return
	end

	local petId = data.id
	local remainSlots = pg.me.petBoxMap and pg.me.petBoxMap:getValidEmptySlot() or 0

	if remainSlots < 1 then
		pg.global.showBubbleMessage(NoticeDef.PET_BAG_FULL)

		return
	end

	if data.inFacility then
		pg.global.showConfirmMsgRaw(pg.getGameString("RELEASE_WARN"), pg.getGameString("HOME_WORKING_PET_REMOVE_CHECK"), function()
			pg.me.space:removeHomelandPetBatch({
				petId
			}, -1, self.currentPetAreaId)
		end, false)
	else
		pg.me.space:removeHomelandPetBatch({
			petId
		}, -1, self.currentPetAreaId)
	end
end

function HomelandPetManageNewCtrl:refreshReddot()
	local foodSlotList = pg.space.homeFoodSlotList
	local space = pg.space
	local isWorking = foodSlotList:isWorking(space)
	local hasPet = space and HomeLandUtils.getPetCurCount(space) > 0
	local showRedDot = hasPet and not isWorking or false
	local foodTabButton = self.mainTabButtons[HomelandPetManageNewCtrl.MAIN_TAB.FOOD] or self.view.btnFoodUButton

	pg.global.setRedDot(RedDotConst.RedDotPath.HOMELAND_FOOD_MANGE, foodTabButton, showRedDot, RedDotConst.RedDotStyle.POINT)
end

function HomelandPetManageNewCtrl:switchToFood()
	self.view.widget:TryChangePage("Tab", 1)

	if self.homeFood then
		self.homeFood:refreshFoodInfo()
	end
end

function HomelandPetManageNewCtrl:refreshPetList(info)
	self._petListDirty = true

	if self._petListRefreshFrameId then
		return
	end

	self._petListRefreshFrameId = TimerManager.addNextFrameCb(function()
		self._petListRefreshFrameId = nil

		self:flushPetListRefresh()
	end)
end

function HomelandPetManageNewCtrl:flushPetListRefresh()
	if not self._petListDirty then
		return
	end

	self._petListDirty = false

	if self.homePetBox then
		self.homePetBox:refreshOnPetChange()
	end

	if self.homeFood then
		self.homeFood:refreshFoodBandInfo()
	end

	pg.global.refreshRedDotState(RedDotConst.RedDotPath.HOMELAND_PET_BOX_CAPACITY)
	self:refreshReddot()
end

function HomelandPetManageNewCtrl:onAbilityRequirementChanged()
	if self.homePetBox then
		self.homePetBox:invalidateAbilityRequirement()
	end
end

function HomelandPetManageNewCtrl:switchPetArea(areaId)
	if not HomeLandUtils.canUseHomePetBoxArea(pg.space, areaId) then
		return false
	end

	local focusedSlot = self:getFocusedHomePetSlot()

	if self.homePetBox then
		local switched = self.homePetBox:setCurrentAreaId(areaId)

		if not switched and self.homePetBox.currentAreaId ~= areaId then
			return false
		end

		if switched then
			self:restoreHomePetFocus(focusedSlot)
		end
	end

	self.currentPetAreaId = areaId

	return true
end

function HomelandPetManageNewCtrl:onAreaLockStateChanged()
	if not HomeLandUtils.canUseHomePetBoxArea(pg.space, self.currentPetAreaId) then
		self:switchPetArea(Const.HOMELAND_AREA_TYPE.PRODUCE)
	elseif self.homePetBox then
		self.homePetBox:refreshAreaTabState()
	end
end

function HomelandPetManageNewCtrl:onPetBoxCapacityChanged()
	if self.homePetBox and self.homePetBox.txtTotalUSDFText then
		self.homePetBox:refreshHomePetList()
		self.homePetBox:refreshPetCount()
	end

	pg.global.refreshRedDotState(RedDotConst.RedDotPath.HOMELAND_PET_BOX_CAPACITY)

	local _, pageIdx = self.view.widget:TryGetCurrentPage("Tab")

	if pageIdx == 0 then
		self.model:redDot_RecordPetBoxCapacityRead()
	end
end

function HomelandPetManageNewCtrl:onHomelandFoodInfoChange()
	if self.homeFood then
		self.homeFood:refreshFoodInfo()
	end

	self:refreshReddot()
end

function HomelandPetManageNewCtrl:onItemMapChange()
	if self.homeFood then
		self.homeFood:refreshFoodList()
	end
end

function HomelandPetManageNewCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function HomelandPetManageNewCtrl:onShow()
	return
end

function HomelandPetManageNewCtrl:onVisibleChange(visible)
	if visible and self.homePetBox then
		self.homePetBox:restorePetManagementTemplate()
	end
end

function HomelandPetManageNewCtrl:onHide()
	return
end

function HomelandPetManageNewCtrl:onDestroy()
	if self._gamepadFocusFrameId then
		TimerManager.delFrameCb(self._gamepadFocusFrameId)

		self._gamepadFocusFrameId = nil
	end

	if self._petListRefreshFrameId then
		TimerManager.delFrameCb(self._petListRefreshFrameId)

		self._petListRefreshFrameId = nil
	end

	self._petListDirty = false

	if CS.XGUI.Navigation.NavManager.Instance then
		CS.XGUI.Navigation.NavManager.Instance:RemoveLuaFocusCursorMovedListener("HomelandPetManageNew")
		CS.XGUI.Navigation.NavManager.Instance:RemoveLuaHotkeyActivationChangedListener("HomelandPetManageNew")
	end

	PetManagementUtils.setIsHidePetBoxEditorLockIcon(false)
	pg.global.refreshRedDotState(RedDotConst.RedDotPath.HOMELAND_MANAGE)
	UICtrl.onDestroy(self)

	self.homeFood = nil
	self.homePetBox = nil
	self.petTabRedDotButton = nil
	self.foodTabRedDotButton = nil
end

function HomelandPetManageNewCtrl:checkShowPetConfirm()
	if not pg.game.home.curLoginShowPetHint then
		return false
	end

	local checkAbilityList = {
		1001,
		1002,
		1003,
		1007,
		1100
	}
	local checkResult = {}
	local petBoxMap = pg.space.petBoxMap

	for slotIndex = 1, petBoxMap:getSlotCount() do
		local petId = petBoxMap:getPetId(Const.HOMELAND_AREA_TYPE.PRODUCE, slotIndex)
		local petInfo = petId and pg.space.pets[petId]
		local petData = petInfo and PetData[petInfo.templateId]
		local homeAbility = petData and petData.homeAbility

		if homeAbility then
			for id in pairs(homeAbility) do
				checkResult[id] = true
			end
		end
	end

	for _, abilityId in ipairs(checkAbilityList) do
		if not checkResult[abilityId] then
			return true
		end
	end

	return false
end

function HomelandPetManageNewCtrl:closePanel()
	local isOpenPetTips = self.homePetBox and self.homePetBox:isPetTipOpen()

	if isOpenPetTips then
		self.homePetBox:closePetTip()
	elseif self:checkShowPetConfirm() then
		local extraInfo = {
			hint = true,
			hintCb = function(isSelected)
				pg.game.home.curLoginShowPetHint = not isSelected
			end
		}

		pg.global.showConfirmMsgRaw(pg.getGameString("WARNING"), pg.getGameString("HOME_PET_ELEMENT_CONFIRM_CONTENT"), function()
			self:close()
		end, false, nil, nil, nil, extraInfo)
	else
		self:close()
	end
end

return HomelandPetManageNewCtrl
