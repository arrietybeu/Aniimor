-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomeBookFurnitureDetail\\HomeBookFurnitureDetailCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local MessageName = require("Const.MessageName")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientConst = require("Const.ClientConst")
local UIConst = require("Const.UIConst")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local TimerManager = require("Core.Timer.TimerManager")
local Time = require("Core.Common.Time")
local TimeUtils = require("Common.Utils.TimeUtils")
local ComposeFurnitureData = require("Data.compose_furniture_data")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local HOME_BOOK_LOOK_TIP_TIME_PREF_KEY = "homeBookLookTipTime"
local HomeBookFurnitureDetailCtrl = Class.LightClass("HomeBookFurnitureDetailCtrl", UICtrl)

HomeBookFurnitureDetailCtrl.messages = {
	[MessageName.ON_HOME_BOOK_DATA_CHANGED] = {
		"onHomeBookDataChanged",
		true
	},
	[MessageName.ON_HOME_BOOK_ITEM_COUNT_CHANGED] = {
		"onHomeBookItemCountChanged",
		true
	}
}

function HomeBookFurnitureDetailCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.furnitureScene = pg.game.uiScene:getScene(UISceneConst.FURNITURE_STORE_SCENE)
end

function HomeBookFurnitureDetailCtrl:onVisibleChange(visible)
	if not visible then
		self:stopGamepadRotation()

		return
	end

	if not self.furnitureScene then
		return
	end

	self.furnitureScene:setGestureOptions("Bg", true, nil)

	if self.view.modelURawImage then
		self.furnitureScene:setRawImage(self.view.modelURawImage)
	end

	self.furnitureScene:initGestures()
	self:refreshView(true)
end

function HomeBookFurnitureDetailCtrl:addListener()
	function self.view.btnBackUButton.luaClick()
		self:closePanel()
	end

	function self.view.btnPrevUButton.luaClick()
		self:switchEntry(-1)
	end

	function self.view.btnNextUButton.luaClick()
		self:switchEntry(1)
	end

	function self.view.listSuitUList.luaRenderItem(button, index, data)
		self:renderSuitItem(button, data)
	end

	function self.view.listSuitUList.luaClick(button, data)
		self:openFurnitureFromSuit(data.id, data.name)
	end

	function self.view.buttonUButton.luaClick()
		self:openParentSuit()
	end

	function self.view.listGetUList.luaRenderItem(button, index, data)
		self:renderSourceItem(button, data)
	end

	if pg.global.navMgr then
		self:addNavFocusListener(function()
			if self.view then
				self:refreshConsoleBarState()
			end
		end, "HomeBookFurnitureDetail")
	end

	self:bindGamepadRotation()
end

function HomeBookFurnitureDetailCtrl:bindGamepadRotation()
	local binding = KeyBindingPro.GetOrAddKeyBindingByName(self.view.widget.gameObject, "homeBookFurnitureDetailRotateGamepad")

	binding.isVirtual = true
	binding.priority = -1
	binding.actionPath = "Raw/GamepadRightStickMove"

	function binding.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self.gamepadRotateDelta = inputInfo.valueVec2

			if self.gamepadRotateTimer == nil and self.furnitureScene then
				self.gamepadRotateTimer = self:startTimer(function()
					if self.furnitureScene and self.gamepadRotateDelta then
						local fakeDelta = Vector2.New(self.gamepadRotateDelta.x * 10, self.gamepadRotateDelta.y * 10)

						self.furnitureScene:onSwipeModel(fakeDelta)
					end
				end, 0, true)
			end
		elseif inputInfo.phase == "Canceled" then
			self:stopGamepadRotation()
		end

		return true
	end
end

function HomeBookFurnitureDetailCtrl:stopGamepadRotation()
	if self.gamepadRotateTimer then
		self:killTimer(self.gamepadRotateTimer)

		self.gamepadRotateTimer = nil
	end

	self.gamepadRotateDelta = nil
end

function HomeBookFurnitureDetailCtrl:onOpen(info)
	self:cancelHomeBookSecondVisibleFrameTimer()
	UICtrl.onOpen(self, info)
	self.model:setDetailInfo(info)
	self:refreshView(true)

	self.keepHomeBookSecondVisible = true
	self.homeBookSecondVisibleFrameId = self:startFrameTimer(function()
		self.homeBookSecondVisibleFrameId = nil

		self:releaseHomeBookVisible()
	end, 5)
end

function HomeBookFurnitureDetailCtrl:refreshConsoleBarState()
	local currentFocusedGroupName = pg.global.navMgr.CurrentFocusedGroupName
	local needChoose = currentFocusedGroupName == "ListSuit" or currentFocusedGroupName == "ListGet"

	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("HomeBookFurnitureDetail_Choose", needChoose)
end

function HomeBookFurnitureDetailCtrl:cancelHomeBookSecondVisibleFrameTimer()
	if not self.homeBookSecondVisibleFrameId then
		return
	end

	TimerManager.delFrameCb(self.homeBookSecondVisibleFrameId)

	self.homeBookSecondVisibleFrameId = nil
end

function HomeBookFurnitureDetailCtrl:switchEntry(offset)
	if self.model:move(offset) then
		self.view.widget:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
		self:refreshView(true)
	end
end

function HomeBookFurnitureDetailCtrl:refreshView(resetPos)
	local data = self.model:getDetailData()

	if not data then
		self:closePanel()

		return
	end

	self.detailData = data

	ClientTextUtils.setText(self.view.tMPUSDFText, data.title)
	ClientTextUtils.setText(self.view.txtTagUSDFText, data.tag)
	ClientTextUtils.setText(self.view.txtNameUSDFText, data.name)
	ClientTextUtils.setText(self.view.txtLivabilityValueUSDFText, data.comfortValue)
	ClientTextUtils.setText(self.view.txtLoadValueUSDFText, data.loadValue)

	local showAddGrade = not data.isSuit and data.addGrade > 0

	if showAddGrade then
		ClientTextUtils.setText(self.view.txtAddUSDFText, "+" .. data.addGrade)
	end

	self.view.addUWidget:SetActive(showAddGrade)
	ClientTextUtils.setText(self.view.txtDescUSDFText, data.desc)
	ClientTextUtils.setText(self.view.txtInfoUSDFText, data.infoTitle)
	ClientTextUtils.setText(self.view.txtSuitInfoTitleUSDFText, data.infoTitle)
	ClientTextUtils.setText(self.view.txtNumUSDFText, data.progressText)
	ClientTextUtils.setText(self.view.txtGetUSDFText, data.getTitle)
	self.view.widget:TryChangePage("Unlock", data.isCollected and 0 or 1)
	self.view.btnPrevUButton:SetActive(data.canCycle)
	self.view.btnNextUButton:SetActive(data.canCycle)
	self.view.suitInfo1UWidget:SetActive(data.isSuit and #data.suitItems > 0)
	self.view.suitInfo2UWidget:SetActive(not data.isSuit and data.parentSuit ~= nil)
	self.view.listSuitUList:SetList(data.suitItems)
	self.view.listGetUList:SetList(data.sources)

	local parentSuit = data.parentSuit

	self.view.buttonUButton:SetActive(parentSuit ~= nil)

	self.view.iconUImage.url = parentSuit and parentSuit.icon or ""

	if self.view.scrollRectUScrollRect and resetPos then
		self.view.scrollRectUScrollRect:GoToPos(Vector2.zero, true)
	end

	self:refreshModel(data.modelData)
	self:refreshConsoleBarState()
end

function HomeBookFurnitureDetailCtrl:refreshModel(modelData)
	if not self.furnitureScene then
		return
	end

	if modelData and modelData.modelResId then
		self.furnitureScene:showModel(modelData)
	else
		self.furnitureScene:hideCurModel()
	end
end

function HomeBookFurnitureDetailCtrl:renderSuitItem(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local iconPropUImage = objectReference:GetRefValue("iconPropUImage")
	local addUWidget = objectReference:GetRefValue("addUWidget")

	iconPropUImage.url = data.icon or ""

	addUWidget:SetActive(false)
	button:TryChangePage("Quality", data.quality)
	button:TryChangePage("Unlock", data.isCollected and 0 or 1)
end

function HomeBookFurnitureDetailCtrl:showLookConfirm(name, lookCallback)
	local prefsCacheUtils = pg.global.prefsCacheUtils
	local lastIgnoreTime = prefsCacheUtils:getInt(HOME_BOOK_LOOK_TIP_TIME_PREF_KEY, 0, ClientConst.CACHE_TYPE_FLAG.USER)
	local currentTime = Time.secondCache
	local isIgnoredToday = lastIgnoreTime > 0 and TimeUtils.getAreaDayBegin(lastIgnoreTime) == TimeUtils.getAreaDayBegin(currentTime)

	if isIgnoredToday then
		lookCallback()

		return
	end

	local ignoreToday = false
	local desc = pg.getFormatText(pg.getGameString("HOME_BOOK_LOOK_DETAIL"), name)

	pg.global.showConfirmMsgRaw(pg.getGameString("HOME_BOOK_LOOK"), desc, function()
		if ignoreToday then
			prefsCacheUtils:setInt(HOME_BOOK_LOOK_TIP_TIME_PREF_KEY, Time.secondCache, ClientConst.CACHE_TYPE_FLAG.USER)
			prefsCacheUtils:save()
		end

		lookCallback()
	end, nil, nil, nil, nil, {
		hint = true,
		hintDesc = pg.getGameString("HOME_ORDER_PAY_HINT_TEXT"),
		hintCb = function(isSelected)
			ignoreToday = isSelected
		end
	})
end

function HomeBookFurnitureDetailCtrl:openFurnitureFromSuit(furnitureId, furnitureName)
	if not self.detailData or not self.detailData.isSuit then
		return
	end

	local parentSuitId = self.detailData.id
	local name = furnitureName and pg.getLocalizationText(furnitureName) or ""

	self:showLookConfirm(name, function()
		if self.model:selectEntry(furnitureId, parentSuitId) then
			self:refreshView(true)
		end
	end)
end

function HomeBookFurnitureDetailCtrl:openParentSuit()
	local parentSuit = self.detailData and self.detailData.parentSuit

	if parentSuit then
		local suitConfig = ComposeFurnitureData[parentSuit.id]
		local name = suitConfig and pg.getLocalizationText(suitConfig.name) or ""

		self:showLookConfirm(name, function()
			if self.model:selectEntry(parentSuit.id) then
				self:refreshView(true)
			end
		end)
	end
end

function HomeBookFurnitureDetailCtrl:renderSourceItem(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

	ClientTextUtils.setText(txtNameUSDFText, data.name)

	if data.sourceConfig then
		button.enabledTooltip = false
		button.luaClick = LuaUIUtils.getItemSourceClickFunc(button, data.sourceConfig, nil, data.sourceId)

		return
	end

	function button.luaClick()
		if data.isFurnitureStore then
			pg.global.ui:open(UIConst.UI_ID_HOMELAND_FURNITURE_STORE, {
				curItemId = data.itemId
			})
		end
	end
end

function HomeBookFurnitureDetailCtrl:onHomeBookDataChanged()
	if not self.view or not self.view.widget.IsVisible then
		return
	end

	self:refreshView()
end

function HomeBookFurnitureDetailCtrl:onHomeBookItemCountChanged(info)
	if not self.detailData or not self.detailData.isSuit then
		return
	end

	local updatedData = self.model:getDetailData()

	if not updatedData or updatedData.id ~= self.detailData.id then
		return
	end

	ClientTextUtils.setText(self.view.txtTagUSDFText, updatedData.tag)
	ClientTextUtils.setText(self.view.txtNumUSDFText, updatedData.progressText)
	self.view.widget:TryChangePage("Unlock", updatedData.isCollected and 0 or 1)

	local updatedItemById = {}

	for _, item in ipairs(updatedData.suitItems) do
		updatedItemById[item.id] = item
	end

	local suitItems = self.detailData.suitItems
	local listSuitUList = self.view.listSuitUList

	for index, item in ipairs(suitItems) do
		local updatedItem = updatedItemById[item.id]

		if updatedItem and item.id == info.itemId then
			for key, value in pairs(updatedItem) do
				item[key] = value
			end

			listSuitUList:RefreshElement(index - 1)
		end
	end

	self.detailData.isCollected = updatedData.isCollected
	self.detailData.progressText = updatedData.progressText
	self.detailData.tag = updatedData.tag
end

function HomeBookFurnitureDetailCtrl:close()
	self:releaseHomeBookVisible()
	UICtrl.close(self)
end

function HomeBookFurnitureDetailCtrl:releaseHomeBookVisible()
	self:cancelHomeBookSecondVisibleFrameTimer()

	if not self.keepHomeBookSecondVisible then
		return
	end

	self.keepHomeBookSecondVisible = false

	self.adapter:refreshUIVisible(self.uid)
end

function HomeBookFurnitureDetailCtrl:onDestroy()
	self:releaseHomeBookVisible()
	self:stopGamepadRotation()

	if self.furnitureScene then
		self.furnitureScene:hideCurModel()
		self.furnitureScene:setGestureOptions(nil, false, nil)
	end

	self.furnitureScene = nil
	self.detailData = nil

	UICtrl.onDestroy(self)
end

local HOME_BOOK_SECOND_VISIBLE_WHITE_LIST = {
	[UIConst.UI_ID_HOME_BOOK_FURNITURE_SET] = true,
	[UIConst.UI_ID_HOME_BOOK_SEASON] = true
}
local EMPTY_WHITE_LIST = {}

function HomeBookFurnitureDetailCtrl:getWhiteList()
	if self.keepHomeBookSecondVisible then
		return HOME_BOOK_SECOND_VISIBLE_WHITE_LIST
	end

	return EMPTY_WHITE_LIST
end

return HomeBookFurnitureDetailCtrl
