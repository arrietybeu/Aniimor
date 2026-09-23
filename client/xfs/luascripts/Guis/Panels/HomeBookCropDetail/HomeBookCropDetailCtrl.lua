-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomeBookCropDetail\\HomeBookCropDetailCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local MessageName = require("Const.MessageName")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local UIConst = require("Const.UIConst")
local TimerManager = require("Core.Timer.TimerManager")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local HomeBookCropDetailCtrl = Class.LightClass("HomeBookCropDetailCtrl", UICtrl)
local UNLOCK_PAGE_UNLOCKED = 0
local UNLOCK_PAGE_LOCKED = 1
local UNLOCK_PAGE_FIRST_UNLOCKED = 2

HomeBookCropDetailCtrl.messages = {
	[MessageName.ON_HOME_BOOK_DATA_CHANGED] = {
		"onHomeBookDataChanged",
		true
	}
}

function HomeBookCropDetailCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.furnitureScene = pg.game.uiScene:getScene(UISceneConst.FURNITURE_STORE_SCENE)

	if self.furnitureScene then
		self.furnitureScene:setGestureOptions("Bg", true, nil)

		if self.view.modelURawImage then
			self.furnitureScene:setRawImage(self.view.modelURawImage)
		end
	end
end

function HomeBookCropDetailCtrl:onVisibleChange(visible)
	if not visible then
		self:stopGamepadRotation()
	end
end

function HomeBookCropDetailCtrl:addListener()
	function self.view.btnBackUButton.luaClick()
		self:closePanel()
	end

	function self.view.btnPrevUButton.luaClick()
		self:switchEntry(-1)
	end

	function self.view.btnNextUButton.luaClick()
		self:switchEntry(1)
	end

	function self.view.listInfoUList.luaRenderItem(button, index, data)
		self:renderInfoItem(button, data)
	end

	function self.view.btnAutoCollectSwitchUButton.luaClick()
		self:onAutoCollectClick()
	end

	function self.view.btnInfoUButton.luaRenderTooltip(btn, com)
		local ref = com:GetComponent("ObjectReference")
		local txtNameUSDFText = ref:GetRefValue("txtNameUSDFText")

		ClientTextUtils.setText(txtNameUSDFText, pg.getGameString("HOMELAND_VARIATION_PLANT_INSTRUCTION"))
	end

	if pg.global.navMgr then
		self:addNavFocusListener(function()
			if self.view then
				self:refreshConsoleBarState()
			end
		end, "HomeBookCropDetail")
	end

	self:bindGamepadRotation()
end

function HomeBookCropDetailCtrl:bindGamepadRotation()
	local binding = KeyBindingPro.GetOrAddKeyBindingByName(self.view.widget.gameObject, "homeBookCropDetailRotateGamepad")

	binding.isVirtual = true
	binding.priority = -1
	binding.actionPath = "Raw/GamepadRightStickMove"

	function binding.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" and self.isModelPreviewVisible then
			self.gamepadRotateDelta = inputInfo.valueVec2

			if self.gamepadRotateTimer == nil and self.furnitureScene then
				self.gamepadRotateTimer = self:startTimer(function()
					if self.furnitureScene and self.gamepadRotateDelta and self.isModelPreviewVisible then
						local fakeDelta = Vector2.New(self.gamepadRotateDelta.x * 10, self.gamepadRotateDelta.y * 10)

						self.furnitureScene:onSwipeModel(fakeDelta)
					end
				end, 0, true)
			end
		elseif inputInfo.phase == "Canceled" then
			self:stopGamepadRotation()
		end

		return self.isModelPreviewVisible == true
	end
end

function HomeBookCropDetailCtrl:stopGamepadRotation()
	if self.gamepadRotateTimer then
		self:killTimer(self.gamepadRotateTimer)

		self.gamepadRotateTimer = nil
	end

	self.gamepadRotateDelta = nil
end

function HomeBookCropDetailCtrl:onOpen(info)
	self:cancelHomeBookSecondVisibleFrameTimer()
	UICtrl.onOpen(self, info)
	self.model:setDetailInfo(info)
	self:refreshView()

	self.keepHomeBookSecondVisible = true
	self.homeBookSecondVisibleFrameId = self:startFrameTimer(function()
		self.homeBookSecondVisibleFrameId = nil

		self:releaseHomeBookVisible()
	end, 5)
end

function HomeBookCropDetailCtrl:refreshConsoleBarState()
	local currentFocusedGroupName = pg.global.navMgr.CurrentFocusedGroupName
	local needChoose = currentFocusedGroupName == "ListInfo"
	local needRotate = self.isModelPreviewVisible == true

	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("HomeBookCropDetail_Choose", needChoose)
	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("HomeBookCropDetail_Rotate", needRotate)
end

function HomeBookCropDetailCtrl:cancelHomeBookSecondVisibleFrameTimer()
	if not self.homeBookSecondVisibleFrameId then
		return
	end

	TimerManager.delFrameCb(self.homeBookSecondVisibleFrameId)

	self.homeBookSecondVisibleFrameId = nil
end

function HomeBookCropDetailCtrl:switchEntry(offset)
	if self.model:move(offset) then
		self.view.widget:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
		self:refreshView()
	end
end

function HomeBookCropDetailCtrl:refreshView()
	local data = self.model:getDetailData()

	if not data then
		self:closePanel()

		return
	end

	ClientTextUtils.setText(self.view.tMPUSDFText, data.title)
	ClientTextUtils.setText(self.view.txtNameUSDFText, data.name)

	local showAddGrade = data.addGrade > 0

	if showAddGrade then
		ClientTextUtils.setText(self.view.txtAddUSDFText, "+" .. data.addGrade)
	end

	self.view.addUWidget:SetActive(showAddGrade)
	ClientTextUtils.setText(self.view.txtDescUSDFText, data.desc)
	self:refreshPreview(data)

	local unlockPage = data.isCollected and UNLOCK_PAGE_UNLOCKED or UNLOCK_PAGE_LOCKED

	if data.isCollected and pg.me and pg.me:consumeHomeBookCropFirstUnlock(data.id) then
		unlockPage = UNLOCK_PAGE_FIRST_UNLOCKED
	end

	self.view.widget:TryChangePage("Unlock", unlockPage)

	if unlockPage == UNLOCK_PAGE_UNLOCKED then
		self.view.txtTagUSDFText.renderOpacity = 1
		self.view.txtLockTagUSDFText.renderOpacity = 0
	end

	if unlockPage == UNLOCK_PAGE_LOCKED then
		self.view.txtTagUSDFText.renderOpacity = 0
		self.view.txtLockTagUSDFText.renderOpacity = 1
	end

	ClientTextUtils.setText(self.view.txtTagUSDFText, pg.getGameString("HOMELAND_PLOT_UNLOCKED"))
	ClientTextUtils.setText(self.view.txtLockTagUSDFText, pg.getGameString("HOMELAND_ITEM_LOCKED"))
	self.view.btnPrevUButton:SetActive(data.canCycle)
	self.view.btnNextUButton:SetActive(data.canCycle)
	self.view.listInfoUList:SetList(data.infoList)
	self:refreshAutoCollect(data.id)
	self:refreshConsoleBarState()
end

function HomeBookCropDetailCtrl:refreshPreview(data)
	local canShowModel = data.modelData ~= nil and data.modelData.modelResId ~= nil and self.furnitureScene ~= nil and self.view.modelURawImage ~= nil

	self.isModelPreviewVisible = canShowModel

	if not canShowModel then
		self:stopGamepadRotation()
	end

	self.view.iconCropUImage:SetActive(not canShowModel)

	if self.view.modelURawImage then
		self.view.modelURawImage:SetActive(canShowModel)
	end

	if canShowModel then
		self.furnitureScene:showModel(data.modelData)

		return
	end

	if self.furnitureScene then
		self.furnitureScene:hideCurModel()
	end

	self.view.iconCropUImage.url = data.icon or ""
	self.view.iconCropUImage.grayed = not data.isCollected
end

function HomeBookCropDetailCtrl:renderInfoItem(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

	ClientTextUtils.setText(txtNameUSDFText, data.title)

	if data.tIndex == 0 then
		local textUSDFText = objectReference:GetRefValue("textUSDFText")
		local iconUImage = objectReference:GetRefValue("iconUImage")

		ClientTextUtils.setText(textUSDFText, data.text or "")

		local hasIcon = data.icon ~= nil and data.icon ~= ""

		iconUImage:SetActive(hasIcon)

		if hasIcon then
			iconUImage.url = data.icon
		end

		return
	end

	local listItemUList = objectReference:GetRefValue("listItemUList")
	local panelKeyUWidget = objectReference:GetRefValue("panelKeyUWidget")

	panelKeyUWidget:SetActive(data.isFirstItemList == true)

	function listItemUList.luaRenderItem(itemButton, index, itemData)
		LuaUIUtils.renderRewardItem(itemButton, itemData, nil, true)

		function itemButton.luaClick()
			self:onInfoItemClick(itemButton, itemData.id)
		end
	end

	listItemUList:SetList(data.items or {})
end

function HomeBookCropDetailCtrl:onInfoItemClick(itemButton, itemId)
	pg.global.ui.commonItemTip:open({
		num = 1,
		id = itemId,
		targetRect = itemButton
	})
end

function HomeBookCropDetailCtrl:refreshAutoCollect(entryId)
	self.autoCollectData = self.model:getAutoCollectData(entryId)

	local visible = self.autoCollectData ~= nil

	self.view.autoHarvestUWidget:SetActive(visible)

	if not self.autoCollectData then
		return
	end

	ClientTextUtils.setText(self.view.txtTipsUSDFText, self.autoCollectData.text)

	self.view.btnAutoCollectSwitchUButton.isSelected = self.autoCollectData.isOn

	self:refreshSwitchText(self.autoCollectData.isOn)
end

function HomeBookCropDetailCtrl:refreshSwitchText(isOn)
	if self.view.txtSwitchNameUSDFText then
		ClientTextUtils.setText(self.view.txtSwitchNameUSDFText, pg.getGameString(isOn and "ON" or "OFF"))
	end
end

function HomeBookCropDetailCtrl:onAutoCollectClick()
	if not self.autoCollectData then
		return
	end

	local newIsOn = not self.autoCollectData.isOn

	self.autoCollectData.isOn = newIsOn

	self:refreshSwitchText(newIsOn)
	pg.me:reqSetPlantAutoCollectSwitch(self.autoCollectData.itemId, newIsOn)
end

function HomeBookCropDetailCtrl:onHomeBookDataChanged()
	self:refreshView()
end

function HomeBookCropDetailCtrl:close()
	self:releaseHomeBookVisible()
	UICtrl.close(self)
end

function HomeBookCropDetailCtrl:releaseHomeBookVisible()
	self:cancelHomeBookSecondVisibleFrameTimer()

	if not self.keepHomeBookSecondVisible then
		return
	end

	self.keepHomeBookSecondVisible = false

	self.adapter:refreshUIVisible(self.uid)
end

function HomeBookCropDetailCtrl:onDestroy()
	self:releaseHomeBookVisible()
	self:stopGamepadRotation()

	self.isModelPreviewVisible = false

	if self.furnitureScene then
		self.furnitureScene:hideCurModel()
		self.furnitureScene:setGestureOptions(nil, false, nil)
	end

	self.furnitureScene = nil
	self.autoCollectData = nil

	UICtrl.onDestroy(self)
end

local HOME_BOOK_SECOND_VISIBLE_WHITE_LIST = {
	[UIConst.UI_ID_HOME_BOOK_FURNITURE_SET] = true,
	[UIConst.UI_ID_HOME_BOOK_SEASON] = true
}
local EMPTY_WHITE_LIST = {}

function HomeBookCropDetailCtrl:getWhiteList()
	if self.keepHomeBookSecondVisible then
		return HOME_BOOK_SECOND_VISIBLE_WHITE_LIST
	end

	return EMPTY_WHITE_LIST
end

return HomeBookCropDetailCtrl
