-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CatchBossNew\\CatchBossNewCtrl.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local logger = require("Core.Log.LoggerManager").getLogger("CatchBossNewCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ClientUtils = require("Utils.ClientUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientCaptureUtils = require("Utils.ClientCaptureUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local UIConst = require("Const.UIConst")
local CameraConst = require("GameApp.Camera.CameraConst")
local Const = require("Common.Const.Const")
local Time = require("Core.Common.Time")
local NoticeDef = require("Common.NoticeDef")
local PetConfigData = require("Data.pet_config_data")
local CatchBossNewCtrl = Class.LightClass("CatchBossNewCtrl", UICtrl)
local TimerManager = require("Core.Timer.TimerManager")
local rectTransformUtility = CS.UnityEngine.RectTransformUtility
local CATCH_BALL_SHOP_CLASSIFY_ID = 5
local NAV_GROUP_REWARD = "List"
local CONSOLE_BAR_STATE_REWARD_FOCUSED = "CatchBossNew_RewardFocused"
local CONSOLE_BAR_LISTENER_NAME = "CatchBossNewConsoleBar"

local function setActive(target, active)
	if not target then
		return
	end

	if target.gameObject then
		target.gameObject:SetActiveEx(active)
	else
		target:SetActive(active)
	end
end

CatchBossNewCtrl.messages = {
	[MessageName.ON_BACKPACK_INFO_CHANGE] = {
		"onBackPackInfoChange",
		true
	},
	[MessageName.ITEM_COUNT_MAP_CHANGE] = {
		"refreshInfo",
		true
	},
	[MessageName.CURRENCY_CHANGE] = {
		"onCostCountChange",
		true
	},
	[MessageName.MONEY_COUNT_CHANGE] = {
		"onCostCountChange",
		true
	}
}

function CatchBossNewCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function CatchBossNewCtrl:addListener()
	function self.view.btnCancelUButton.luaClick()
		self:onCancelClick()
	end

	function self.view.btnConfirmUButton.luaClick()
		self:onConfirmClick()
	end

	if pg.global.navMgr then
		self:addNavFocusListener(function()
			self:refreshConsoleBarState()
		end, CONSOLE_BAR_LISTENER_NAME)

		self._consoleBarHotkeyListenerName = CONSOLE_BAR_LISTENER_NAME .. tostring(self.uid)

		pg.global.navMgr:AddLuaHotkeyActivationChangedListener(self._consoleBarHotkeyListenerName, function()
			self:refreshConsoleBarState()
		end)
	end
end

function CatchBossNewCtrl:refreshConsoleBarState()
	local navMgr = pg.global.navMgr
	local groupName = navMgr and navMgr.CurrentFocusedGroupName
	local canSelect = groupName == NAV_GROUP_REWARD

	CS.XGUI.Navigation.ConsoleBar.SetStateForAll(CONSOLE_BAR_STATE_REWARD_FOCUSED, not not canSelect)
end

function CatchBossNewCtrl:onDestroy()
	if self._consoleBarHotkeyListenerName and pg.global.navMgr then
		pg.global.navMgr:RemoveLuaHotkeyActivationChangedListener(self._consoleBarHotkeyListenerName)
	end

	self._consoleBarHotkeyListenerName = nil

	if pg.global.ui:checkUIShow(UIConst.UI_ID_COMMON_ITEM_TIP) then
		pg.global.ui:close(UIConst.UI_ID_COMMON_ITEM_TIP)
	end

	self._tooltipItemId = nil

	UICtrl.onDestroy(self)
	pg.global.ui:show(UIConst.UI_ID_HUD_V2)
end

function CatchBossNewCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	ClientTextUtils.setText(self.view.bossTxtRewardUSDFText, pg.getGameString("PET_CATCHBOSS_NEW_REWARD"))
	ClientTextUtils.setText(self.view.ballTxtCatchUSDFText, pg.getGameString("PET_CATCHBOSS_NEW_ACTION"))
	ClientTextUtils.setText(self.view.comsumeTxtNumUSDFText, pg.getGameString("PET_CATCHBOSS_NEW_COST"))
	ClientTextUtils.setText(self.view.btnCancelTxtNameUSDFText, pg.getGameString("PET_CATCHBOSS_NEW_GIVEUP"))
	ClientTextUtils.setText(self.view.btnConfirmTxtNameUSDFText, pg.getGameString("PET_CATCHBOSS_NEW_GET"))
	pg.global.ui:hide(UIConst.UI_ID_HUD_V2)

	self.bossEntity = info.bossEntity
	self.curSelectIndex = nil
	self.curSelectCastItem = nil

	self:refreshInfo()
end

function CatchBossNewCtrl:onShow()
	pg.game.camera:setDofEnable(CameraConst.DofStateKeys.BossCatch, true)
end

function CatchBossNewCtrl:onHide()
	pg.game.camera:setDofEnable(CameraConst.DofStateKeys.BossCatch, false)
end

function CatchBossNewCtrl:refreshInfo()
	self.itemList = self.model:getBossCapturePropInfos(self.bossEntity)

	table.insert(self.itemList, {
		empty = true
	})
	self:syncSelectedItem()

	function self.view.listUList.luaRenderItem(button, idx, data)
		self:renderCatchBallItem(button, idx, data)
	end

	self.view.listUList:SetList(self.itemList)
	self:refreshBossInfo()
	self:refreshRewardInfo()
	self:refreshCostInfo()
end

function CatchBossNewCtrl:syncSelectedItem()
	local selectedItemId = self.curSelectCastItem and self.curSelectCastItem.itemId

	self.curSelectIndex = nil
	self.curSelectCastItem = nil

	local firstIndex, firstItem, firstFreeIndex, firstFreeItem

	for idx, itemInfo in ipairs(self.itemList or EMPTY_TABLE) do
		if not itemInfo.empty then
			if not firstIndex then
				firstIndex = idx
				firstItem = itemInfo
			end

			if itemInfo.isFree and not firstFreeIndex then
				firstFreeIndex = idx
				firstFreeItem = itemInfo
			end

			if selectedItemId and itemInfo.itemId == selectedItemId then
				self.curSelectIndex = idx
				self.curSelectCastItem = itemInfo

				return
			end
		end
	end

	self.curSelectIndex = firstFreeIndex or firstIndex
	self.curSelectCastItem = firstFreeItem or firstItem
end

function CatchBossNewCtrl:refreshBossInfo()
	if not self.bossEntity then
		return
	end

	local gender = 2

	if self.bossEntity.gender == Const.GENDER_TYPE_MALE then
		gender = 0
	elseif self.bossEntity.gender == Const.GENDER_TYPE_FEMALE then
		gender = 1
	end

	local pData = self.bossEntity:getConfigData()

	self.view.bossInfoUComponent:TryChangePage("Gender", gender)
	ClientTextUtils.setText(self.view.txtLvUBaseText, string.format("%s %s", pg.getGameString("LEVEL_TAG"), self.bossEntity.level))
	ClientTextUtils.setText(self.view.txtNameUBaseText, pg.getLocalizationText(pData.name))

	function self.view.listElementUList.luaRenderItem(button, idx, data)
		self:renderBossElementItem(button, idx, data)
	end

	local _, elementNames = LuaUIUtils.getElementInfo(pData.elementType)

	self.view.listElementUList:SetList(elementNames)

	local petType = pData.functionId
	local petTypeIcon = petType and PetConfigData.petFunctionIcon[petType]
	local petTypeText = petType and PetConfigData[string.format("petFunctionText%s", petType)]

	setActive(self.view.bossOccupationUWidget, petTypeIcon ~= nil or petTypeText ~= nil)

	if petTypeIcon then
		self.view.bossIconOccupationUImage.url = petTypeIcon
	end

	if petTypeText then
		ClientTextUtils.setText(self.view.bossTxtOccupationUSDFText, pg.getLocalizationText(petTypeText))
	end
end

function CatchBossNewCtrl:refreshRewardInfo()
	local rewards = self.model:getBossCaptureRewardInfos(self.bossEntity)

	function self.view.bossRewardsUList.luaRenderItem(button, idx, data)
		LuaUIUtils.renderRewards(button, idx, data)
	end

	self.view.bossRewardsUList:SetList(rewards)
end

function CatchBossNewCtrl:refreshCostInfo()
	self.costInfo = self.model:getBossCaptureCostInfo(self.bossEntity)

	setActive(self.view.consumeUWidget, self.costInfo ~= nil)

	if not self.costInfo then
		self:refreshConfirmButtonState()

		return
	end

	self.costInfo.ownCount = ClientUtils.getItemCountById(self.costInfo.itemId)
	self.view.iconConsumeUImage.url = self.costInfo.icon

	local text = tostring(self.costInfo.count)

	if self.costInfo.ownCount < self.costInfo.count then
		text = string.format("<style=Debuff>%s</style>", text)
	end

	ClientTextUtils.setText(self.view.comsumeTxtNumUSDFText, text)

	local consumeText = pg.getGameString("PET_CATCHBOSS_NEW_COST")

	if consumeText and consumeText ~= "" then
		ClientTextUtils.setText(self.view.txtConsumeUSDFText, consumeText)
	end

	LuaUIUtils.setTopCurrencyItemList(self.view.listCurrencyUList, nil, {
		self.costInfo.itemId
	})
	self:refreshConfirmButtonState()
end

function CatchBossNewCtrl:isCostEnough()
	if not self.costInfo or not self.costInfo.count or self.costInfo.count <= 0 then
		return true
	end

	return ClientUtils.getItemCountById(self.costInfo.itemId) >= self.costInfo.count
end

function CatchBossNewCtrl:isCurSelectBallEnough()
	local item = self.curSelectCastItem

	if not item or item.empty then
		return false
	end

	if item.isFree then
		return true
	end

	return (item.count or 0) > 0
end

function CatchBossNewCtrl:refreshConfirmButtonState()
	if not self.view or not self.view.btnConfirmUButton then
		return
	end

	local enabled = self:isCurSelectBallEnough() and self:isCostEnough()

	self.view.btnConfirmUButton.visualInteractable = enabled

	self.view.btnConfirmUButton:TryChangePage("button", enabled and 1 or 4)
	TimerManager.addNextFrameCb(function()
		local rayBox = self.view.btnConfirmUButton.transform:Find("RayBox").gameObject

		rayBox:SetActiveEx(true)
	end)
end

function CatchBossNewCtrl:_toggleItemTooltip(data, targetButton)
	local opened = pg.global.ui:checkUIShow(UIConst.UI_ID_COMMON_ITEM_TIP)

	if not opened then
		self._tooltipItemId = nil
	end

	local sameItem = opened and self._tooltipItemId == data.itemId

	if opened then
		pg.global.ui:close(UIConst.UI_ID_COMMON_ITEM_TIP)
	end

	if sameItem then
		self._tooltipItemId = nil

		return
	end

	self._tooltipItemId = data.itemId

	pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
		checkTouchBegin = false,
		id = data.itemId,
		num = data.count or 0,
		targetRect = targetButton,
		allowedSourceIds = PetConfigData.bossCatchBallGetMethodsWhitelist,
		validateTouch = function(pos)
			if not NotNil(targetButton) then
				return true
			end

			local rt = targetButton.rectTransform

			if not rt then
				return true
			end

			return not rectTransformUtility.RectangleContainsScreenPoint(rt, pos, CS.XGUI.UWidget.uiCamera)
		end
	})
end

function CatchBossNewCtrl:renderCatchBallItem(button, idx, data)
	local objectReference = button:GetComponent("ObjectReference")
	local rootComponent = objectReference:GetRefValue("rootComponent")
	local iconBallUImage = objectReference:GetRefValue("iconBallUImage")
	local txtNumUBaseText = objectReference:GetRefValue("txtNumUBaseText")
	local txtPercentUBaseText = objectReference:GetRefValue("txtPercentUBaseText")
	local txtNameUBaseText = objectReference:GetRefValue("txtNameUBaseText")
	local rootButton = objectReference:GetRefValue("rootButton")
	local freeTagUWidget = objectReference:GetRefValue("freeTagUWidget")
	local txtFreeUSDFText = objectReference:GetRefValue("txtFreeUSDFText")

	ClientTextUtils.setText(txtFreeUSDFText, pg.getGameString("PET_CATCHBOSS_NEW_FREE"))

	local itemIndex = idx + 1

	if data.empty then
		rootComponent:TryChangePage("Empty", 0)

		function rootButton.luaClick()
			self:selectItem(itemIndex)
		end

		rootButton.interactable = true
		rootButton.isSelected = false
		rootButton.enabledLongPress = false
		rootButton.luaLongPress = nil
		rootButton.luaBeginLongPress = nil

		freeTagUWidget:SetActive(false)

		return
	end

	rootComponent:TryChangePage("Empty", 1)
	rootComponent:TryChangePage("Quality", data.quality or 0)

	iconBallUImage.url = LuaUIUtils.getIconByItemId(data.itemId)

	ClientTextUtils.setText(txtNumUBaseText, data.isFree and "" or tostring(data.count or 0))
	ClientTextUtils.setText(txtNameUBaseText, pg.getLocalizationText(data.name))
	ClientTextUtils.setText(txtPercentUBaseText, LuaUIUtils.formatCatchRate(data.prob) .. "%")
	rootComponent:TryChangePage("SuccessRate", ClientCaptureUtils.getBossCatchPageByRate(data.prob))

	local hasCount = (data.count or 0) > 0
	local enabled = data.isFree == true or hasCount
	local isChampionEmpty = data.isChampion == true and not hasCount

	rootButton.enabledLongPress = true
	rootButton.luaLongPress = nil

	local longPressFired = false

	function rootButton.luaBeginLongPress()
		longPressFired = true

		self:_toggleItemTooltip(data, rootButton)
	end

	if isChampionEmpty then
		rootButton.interactable = true
		rootButton.visualInteractable = false

		local dim = Color(0.4, 0.4, 0.4, 1)

		iconBallUImage.color = dim
		txtNumUBaseText.color = dim

		function rootButton.luaClick()
			longPressFired = false
		end
	else
		rootButton.interactable = enabled
		rootButton.visualInteractable = enabled

		local normal = Color(1, 1, 1, 1)

		iconBallUImage.color = normal
		txtNumUBaseText.color = normal

		function rootButton.luaClick()
			if longPressFired then
				longPressFired = false

				return
			end

			self:selectItem(itemIndex)
		end
	end

	rootButton.isSelected = self.curSelectIndex == itemIndex

	freeTagUWidget:SetActive(data.isFree == true)
end

function CatchBossNewCtrl:renderBossElementItem(button, idx, data)
	LuaUIUtils.setElementGrade(button, data.element, self.bossEntity.templateId, false)
end

function CatchBossNewCtrl:selectItem(itemIndex)
	itemIndex = math.clamp(itemIndex, 1, #self.itemList)

	local itemInfo = self.itemList[itemIndex]

	if not itemInfo then
		return false
	end

	if itemInfo.empty then
		self:openCatchBallShop()

		return false
	end

	self.curSelectIndex = itemIndex
	self.curSelectCastItem = itemInfo

	self.view.listUList:RefreshList()
	self:refreshConfirmButtonState()

	return true
end

function CatchBossNewCtrl:openCatchBallShop()
	if LuaUIUtils.checkFuncTemporaryDisable(UIConst.UI_ID_SHOP_MAIN) then
		return
	end

	pg.global.ui:open(UIConst.UI_ID_SHOP_MAIN, {
		shopTags = {
			CATCH_BALL_SHOP_CLASSIFY_ID
		}
	})
end

function CatchBossNewCtrl:onCancelClick()
	pg.me:cancelBossCapture(self.bossEntity.actorId)
	self:dismiss()
end

function CatchBossNewCtrl:showCostNotEnoughConfirm()
	if not self.costInfo then
		return
	end

	if self.costInfo.itemId == Const.CommonEnergyType_Stamina then
		LuaUIUtils.openVitalityGot(Const.CommonEnergyType_Stamina)
	else
		LuaUIUtils.showItemNotEnough(self.costInfo.itemId)
	end
end

function CatchBossNewCtrl:onConfirmClick()
	if self.lastClickTime and Time.realSecondCache - self.lastClickTime <= 1 then
		return
	end

	self.lastClickTime = Time.realSecondCache

	local itemInfo = self.curSelectCastItem

	if not itemInfo or itemInfo.empty then
		pg.global.showBubbleMessageRaw(pg.getGameString("PET_CATCHBOSS_NEW_TOAST_PLEASE_CHOOSE"))

		return
	end

	if not itemInfo.isFree and ClientUtils.getItemCountById(itemInfo.itemId) <= 0 then
		LuaUIUtils.showItemNotEnough(itemInfo.itemId)

		return
	end

	if self.costInfo and self.costInfo.count > 0 and ClientUtils.getItemCountById(self.costInfo.itemId) < self.costInfo.count then
		self:showCostNotEnoughConfirm()

		return
	end

	if pg.game.controller.onHandleSwitchProp then
		pg.game.controller:onHandleSwitchProp()
	end

	if pg.game.controller.onHandleThrow then
		pg.game.controller:onHandleThrow()
	end
end

function CatchBossNewCtrl:getCurSelectPropId()
	return self.curSelectCastItem and self.curSelectCastItem.itemId
end

function CatchBossNewCtrl:isCurSelectFree()
	return self.curSelectCastItem and self.curSelectCastItem.isFree == true
end

function CatchBossNewCtrl:getCurSelectPropInfo()
	return self.curSelectCastItem
end

function CatchBossNewCtrl:onBackPackInfoChange()
	self:refreshInfo()
end

function CatchBossNewCtrl:onCostCountChange()
	self:refreshCostInfo()

	if self.view and self.view.listCurrencyUList then
		self.view.listCurrencyUList:RefreshList()
	end
end

return CatchBossNewCtrl
