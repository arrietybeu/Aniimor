-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Setting\\SettingCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local HotkeyConst = require("Const.HotkeyConst")
local ClientSettingUtils = require("Utils.ClientSettingUtils")
local ClientConst = require("Const.ClientConst")
local SettingSelectorText = require("Data.setting_selector_text_data")
local SettingCtrl = Class.LightClass("SettingCtrl", UICtrl)
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local InputDeviceType = CS.FunPlus.WorldX.Manager.InputDeviceType
local UIConst = require("Const.UIConst")

SettingCtrl.messages = {
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	},
	[MessageName.INPUT_GAMEPAD_CONNECTION_CHANGED] = {
		"refreshSettingList",
		true
	},
	[MessageName.HOTKEY_UPDATE] = {
		"refreshSettingList",
		true
	},
	[MessageName.SCREEN_RESOLUTION_UPDATE] = {
		"refreshSettingList",
		true
	},
	[MessageName.RESOURCE_DOWNLOAD_STATE_CHANGED] = {
		"onResourceDownloadStateChanged",
		true
	},
	[MessageName.SDK_ACCOUNT_BIND_CHANGED] = {
		"refreshSettingListNoData",
		true
	}
}
SettingCtrl.RESOURCE_DOWNLOAD_REFRESH_INTERVAL = 2
SettingCtrl.PACK_DOWNLOAD_STATE_TEXT_KEY = {
	Downloaded = "RESOURCE_DOWNLOAD_DOWNLOADED",
	Wait = "RESOURCE_DOWNLOAD_WAIT",
	Pause = "RESOURCE_DOWNLOAD_PAUSE",
	Downloading = "RESOURCE_DOWNLOAD_DOWNLOADING",
	NotDownloaded = "RESOURCE_DOWNLOAD_NOT_DOWNLOADED"
}

function SettingCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
	self.model:setOpenSource(info)

	self.selectedTabName = info and info.selectedTabName
	self.selectedPackId = info and info.selectedPackId

	ClientTextUtils.setText(self.view.tMPUSDFText, pg.getGameString("SETTING"))
	self:initSettingTabList()
	self:initSettingList()
	self:refreshDeviceState()
end

function SettingCtrl:refreshAllData()
	self.model:getSettingData(true)
end

function SettingCtrl:forceSetCloudGameVideoQuality(videoQuality)
	local cloudEnable = ClientConfigCloudEnable

	ClientConfigCloudEnable = "false"

	local success, err = xpcall(function()
		pg.game.setting:setVideoQuality(videoQuality, false)
	end, debug.traceback)

	ClientConfigCloudEnable = cloudEnable

	if not success then
		error(err)
	end

	if cloudEnable == "true" then
		pg.game.setting:applyPlayerVideoQualityRelation(videoQuality)
		pg.game.setting:applyCloudGameFramePacingSettings()
	end
end

function SettingCtrl:addListener()
	function self.view.btnCloseUButton.luaClick()
		self:close()
	end

	function self.view.btnReSetUButton.luaClick()
		if self.curTabIndex and self.curTabIndex > 0 then
			local settingData = self.model:getSettingData()
			local tabData = settingData[self.curTabIndex]
			local isVideoTab = tabData.tab == "video"

			for _, cate in ipairs(tabData.items) do
				for _, settingItem in ipairs(cate.settingList) do
					local funcType = settingItem.info.funcType

					if funcType and ClientSettingUtils["setDefault_" .. funcType] then
						ClientSettingUtils["setDefault_" .. funcType](settingItem.info.funcParam)
					end
				end
			end

			if isVideoTab then
				pg.game.setting:resetCloudGamePerformanceSettingUserModified()
			end

			self:refreshSettingList()
		end
	end

	if CS.XGUI.Navigation.NavManager.Instance then
		CS.XGUI.Navigation.NavManager.Instance:AddLuaFocusCursorMovedListener("Setting", function()
			self:refreshConsoleBarState()
		end)
	end

	function self.view.btnDownloadAllUButton.luaClick()
		if pg.game.resourceDownload then
			pg.game.resourceDownload:startDownloadAllPackDownloadItems()
			self:refreshSettingListNoData()
		end
	end

	function self.view.btnClearUButton.luaClick()
		pg.global.ui:open(UIConst.UI_ID_RESOURCE_CLEAN)
	end
end

function SettingCtrl:refreshConsoleBarState()
	if not CS.XGUI.Navigation.NavManager.Instance then
		return
	end

	local focusedData = self:getFocusedSettingItemData()
	local isOnSelectableItem = true
	local hasDesc = false

	if focusedData then
		if focusedData.tIndex == 2 or focusedData.tIndex == 4 then
			isOnSelectableItem = false
		end

		hasDesc = not string.isNilOrEmpty(focusedData.desc)
	end

	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("isOnSelectableItem", isOnSelectableItem)
	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("hasDesc", hasDesc)
end

function SettingCtrl:getFocusedSettingItemData()
	local navMgr = CS.XGUI.Navigation.NavManager.Instance

	if not navMgr then
		return nil
	end

	local focused = navMgr.CurrentFocusedUContent

	if not focused or not focused.transform then
		return nil
	end

	if not self.view or not self.view.mainLabUList then
		return nil
	end

	local mainListTrans = self.view.mainLabUList.transform
	local trans = focused.transform
	local hitData

	while trans ~= nil do
		local btn = trans:GetComponent("UButton")

		if btn and btn.dataFromUList and hitData == nil then
			hitData = btn.dataFromUList
		end

		if trans == mainListTrans then
			return hitData
		end

		trans = trans.parent
	end

	return nil
end

function SettingCtrl:refreshDeviceState()
	local stateValue = pgUtils.GetDeviceState()

	self.view.sliderUSlider.value = stateValue

	local lowStateLimit = 0.3
	local midStateLimit = 0.7

	if stateValue < lowStateLimit then
		self.view.equipmentWidgetUComponent:TryChangePage("state", 0)
	elseif stateValue < midStateLimit then
		self.view.equipmentWidgetUComponent:TryChangePage("state", 1)
	else
		self.view.equipmentWidgetUComponent:TryChangePage("state", 2)
	end
end

function SettingCtrl:initSettingTabList()
	function self.view.choiceLabUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local iconUImage = objectReference:GetRefValue("iconUImage")
		local imgAddUImage = objectReference:GetRefValue("imgAddUImage")
		local imgMaskLockUImage = objectReference:GetRefValue("imgMaskLockUImage")
		local textUBaseText = objectReference:GetRefValue("textUBaseText")

		ClientTextUtils.setText(textUBaseText, data.label)

		iconUImage.url = data.icon
	end

	function self.view.choiceLabUList.luaClick(button, data)
		local index = self.view.choiceLabUList:GetChildIndex(button)

		self.view.choiceLabUList:DeselectAll()
		self.view.choiceLabUList:SelectItem(index)

		local curTabIndex = index + 1

		self.curTabIndex = curTabIndex

		local settingData = self.model:getSettingData()

		self.view.btnDownloadAllUButton:SetActive(settingData[self.curTabIndex].tab == "resource")
		self.view.btnClearUButton:SetActive(settingData[self.curTabIndex].tab == "resource")
		self:refreshSettingList()
	end

	self.curTabIndex = 1

	local settingData = self.model:getSettingData()

	self:selectTabByName(self.selectedTabName, settingData)
	self:refreshSettingTabList(settingData)
end

function SettingCtrl:selectTabByName(tabName, settingData)
	if not tabName then
		return false
	end

	settingData = settingData or self.model:getSettingData()

	for index, tabInfo in ipairs(settingData) do
		if tabInfo.tab == tabName then
			self.curTabIndex = index

			return true
		end
	end

	return false
end

function SettingCtrl:refreshSettingTabList(settingData)
	local settingData = settingData or self.model:getSettingData()

	for index, tab in ipairs(settingData) do
		tab.type = 2
		tab.selected = self.curTabIndex == index
	end

	self.view.choiceLabUList:SetList(settingData)
end

function SettingCtrl:initMainArea(data)
	local t = {}

	for i = 1, #data do
		local x = math.floor((i - 1) / 1) + 1
		local y = (i - 1) % 1 + 1

		if y == 1 then
			t[x] = {}
		end

		t[x][y] = {}
		t[x][y].Focus = function(x1, y1)
			self.gamePadComponent.navigation:baseFocus(t, x1, y1, self.view.consoleKeyUList)
			self.gamePadComponent:deSelectAll()

			local _, button = self.view.choiceLabUList:TryGetChildAt(i - 1)

			button:TryChangePage("button", 5)

			button.isSelected = true

			local curTabIndex = self.view.choiceLabUList:GetChildIndex(button) + 1

			if curTabIndex ~= self.curTabIndex then
				self.curTabIndex = curTabIndex

				self:refreshSettingList()
			end

			self.gamePadComponent.navigation:setLock(self.gamePadComponent.navigation.AREAS.MAIN_AREA, true, x1, y1)
		end
		t[x][y].Fun3 = function(x1, y1)
			self.view.btnCloseUButton.luaClick()
		end
		t[x][y].Fun3Name = pg.getGameString("BACK_TO_PRE")
		t[x][y].Fun4 = function(x1, y1)
			self.gamePadComponent.navigation:specificSet(self.gamePadComponent.navigation.AREAS.SUB_AREA, 1, 1)
			self.gamePadComponent.navigation:reFocus()
		end
		t[x][y].Fun4Name = pg.getGameString("CHECK_OUT")
	end

	self.gamePadComponent.navigation:initAreaTableSlots(self.gamePadComponent.navigation.MAIN_AREA, t)
end

function SettingCtrl:initSettingList()
	function self.view.mainLabUList.luaRenderItem(button, index, data)
		self:renderSettingItem(button, index, data)
	end

	self:refreshSettingList()
end

function SettingCtrl:refreshSettingListNoData()
	if self.view then
		self.view.mainLabUList:RefreshList()
	end
end

function SettingCtrl:refreshSettingList()
	local settingData = self:getSettingListData()

	self.tIndex4AnimPlayed = false

	self.view.mainLabUList:SetList(settingData)

	if not self:goToSelectedPackItem(settingData) then
		self.view.mainLabUList:GoToPos(Vector2.zero, true)
	end

	self:refreshResourceDownloadTimerState()

	if pg.game.input:isUsingGamepad() then
		local navMgr = CS.XGUI.Navigation.NavManager.Instance
		local focused = false

		for i = 0, 4 do
			local ok, btn = self.view.mainLabUList:TryGetChildAt(i)

			if ok and btn then
				if navMgr:FocusItem(btn) then
					focused = true

					break
				end
			else
				break
			end
		end

		if not focused then
			navMgr:TryFocusFirstAvailable()
		end
	end
end

function SettingCtrl:isResourceTabSelected()
	local settingData = self.model:getSettingData()
	local tabData = settingData and settingData[self.curTabIndex]

	return tabData and tabData.tab == "resource"
end

function SettingCtrl:refreshResourceDownloadTimerState()
	if self:isResourceTabSelected() then
		self:startResourceDownloadRefreshTimer()
	else
		self:stopResourceDownloadRefreshTimer()
	end
end

function SettingCtrl:startResourceDownloadRefreshTimer()
	if self.resourceDownloadRefreshTimer then
		return
	end

	self.resourceDownloadRefreshTimer = self:startTimer(function()
		self:refreshSettingListNoData()
	end, self.RESOURCE_DOWNLOAD_REFRESH_INTERVAL, true)
end

function SettingCtrl:stopResourceDownloadRefreshTimer()
	if not self.resourceDownloadRefreshTimer then
		return
	end

	self:killTimer(self.resourceDownloadRefreshTimer)

	self.resourceDownloadRefreshTimer = nil
end

function SettingCtrl:onResourceDownloadStateChanged()
	if self:isResourceTabSelected() then
		self:refreshSettingListNoData()
	end
end

function SettingCtrl:goToSelectedPackItem(settingData)
	if not self.selectedPackId or not self:isResourceTabSelected() then
		return false
	end

	for listIndex, itemData in ipairs(settingData) do
		if itemData.tIndex == 6 and itemData.downloadItems then
			for downloadIndex, downloadItem in ipairs(itemData.downloadItems) do
				if tostring(downloadItem.packId) == tostring(self.selectedPackId) then
					self.selectedPackDownloadIndex = downloadIndex

					self.view.mainLabUList:GoToIndex(listIndex - 1, true)

					return true
				end
			end
		end
	end

	return false
end

function SettingCtrl:goToSelectedPackDownloadItem(downloadList, data)
	if not self.selectedPackId or not self.selectedPackDownloadIndex or not data.downloadItems then
		return
	end

	for downloadIndex, downloadItem in ipairs(data.downloadItems) do
		if tostring(downloadItem.packId) == tostring(self.selectedPackId) then
			downloadList:GoToIndex(downloadIndex - 1, true)

			self.selectedPackId = nil
			self.selectedPackDownloadIndex = nil

			return
		end
	end
end

function SettingCtrl:backToMain()
	local area = self.gamePadComponent.navigation.MAIN_AREA

	if area.Lock ~= nil and area.Lock.x ~= nil and area.Lock.y ~= nil then
		self.gamePadComponent.navigation:specificSet(self.gamePadComponent.navigation.AREAS.MAIN_AREA, area.Lock.x, area.Lock.y)
		self.gamePadComponent.navigation:reFocus()
	end
end

function SettingCtrl:initSubArea(data)
	local t = {}
	local countX = 1
	local countY = 1

	for i = 1, #data do
		if data[i].tIndex ~= 0 and data[i].tIndex ~= self.model.keyReplaceIndex then
			if countY == 1 then
				t[countX] = {}
			end

			if data[i].tIndex == 1 then
				t[countX][countY] = {}
				t[countX][countY].Focus = function(x, y)
					self.gamePadComponent.navigation:baseFocus(t, x, y, self.view.consoleKeyUList)
					self.gamePadComponent:deSelectVisualAll()

					local _, button = self.view.mainLabUList:TryGetChildAt(i - 1)

					button:TryChangePage("GamePadFocus", 1)
					self.view.mainLabUList:GoToItem(button)
				end
				t[countX][countY].Fun3 = function(x, y)
					self:backToMain()
				end
				t[countX][countY].Fun3Name = pg.getGameString("BACK_TO_PRE")
				t[countX][countY].Fun4 = function(x, y)
					local _, button = self.view.mainLabUList:TryGetChildAt(i - 1)
					local selector = button:GetChild("SelectorSort"):GetComponent("USelector")

					self.curCommonSwitchSelector = selector

					selector:InteractPopup()
					self.gamePadComponent.navigation:recordCursor()

					if data[i].info.funcType == "setScreenMode" then
						self.gamePadComponent.navigation:specificSet(self.gamePadComponent.navigation.AREAS.SCREEN_MODE_AREA, 1, 1)
					elseif data[i].info.funcType == "setResolution" then
						self.gamePadComponent.navigation:specificSet(self.gamePadComponent.navigation.AREAS.SCREEN_RESOLUTION_AREA, 1, 1)
					elseif data[i].info.funcType == "language" or data[i].info.funcType == "audioLanguage" then
						self.gamePadComponent.navigation:specificSet(self.gamePadComponent.navigation.AREAS.LANGUAGE_SELECTOR_AREA, 1, 1)
					elseif data[i].info.funcType == "antialiasing" then
						self.gamePadComponent.navigation:specificSet(self.gamePadComponent.navigation.AREAS.SCREEN_AA_AREA, 1, 1)
					else
						self.gamePadComponent.navigation:specificSet(self.gamePadComponent.navigation.AREAS.COMMON_SWITCH_AREA, 1, 1)
					end

					self.gamePadComponent.navigation:delayFocus(nil, 0.1)
				end
				t[countX][countY].Fun4Name = pg.getGameString("GAMEPAD_CHOOSE")
			elseif data[i].tIndex == 2 then
				t[countX][countY] = {}
				t[countX][countY].Focus = function(x, y)
					self.gamePadComponent.navigation:baseFocus(t, x, y, self.view.consoleKeyUList)
					self.gamePadComponent:deSelectVisualAll()

					local _, button = self.view.mainLabUList:TryGetChildAt(i - 1)

					button:TryChangePage("GamePadFocus", 1)

					if data[i].info ~= nil and data[i].info.tab == "operate" then
						self.view.mainLabUList:GoToItem(button)
					end
				end
				t[countX][countY].Fun3 = function(x, y)
					self:backToMain()
				end
				t[countX][countY].Fun3Name = pg.getGameString("BACK_TO_PRE")
				t[countX][countY].Fun7 = function(x, y)
					local _, button = self.view.mainLabUList:TryGetChildAt(i - 1)
					local slider = button:GetChild("Slider"):GetComponent("USlider")

					slider.value = slider.value - 1
				end
				t[countX][countY].Fun7Name = pg.getGameString("DEC")
				t[countX][countY].Fun7IsImportant = true
				t[countX][countY].Fun8 = function(x, y)
					local _, button = self.view.mainLabUList:TryGetChildAt(i - 1)
					local slider = button:GetChild("Slider"):GetComponent("USlider")

					slider.value = slider.value + 1
				end
				t[countX][countY].Fun8Name = pg.getGameString("INC")
				t[countX][countY].Fun8IsImportant = true

				if data[i].info ~= nil and data[i].info.tab == "operate" then
					t[countX][countY].Fun1 = function(x, y)
						if self.btnEditor ~= nil and self.btnEditor.luaClick ~= nil then
							self.btnEditor.luaClick()
						end
					end
					t[countX][countY].Fun1Name = pg.getGameString("EDIT")
					t[countX][countY].Fun1IsImportant = true
				end
			elseif data[i].tIndex == 3 then
				for j = 1, #data[i].info.widgetParam do
					t[countX][j] = {}
					t[countX][j].Focus = function(x, y)
						self.gamePadComponent.navigation:baseFocus(t, x, y, self.view.consoleKeyUList)
						self.gamePadComponent:deSelectVisualAll()

						local _, button = self.view.mainLabUList:TryGetChildAt(i - 1)
						local objRef = button.transform:GetComponent("ObjectReference")
						local listUList = objRef:GetRefValue("listUList")
						local _, button1 = listUList:TryGetChildAt(j - 1)

						button1:TryChangePage("button", 5)
						button1:TryChangePage("GamePadFocus", 1)
						self.view.mainLabUList:GoToItem(button)
					end
					t[countX][j].Fun3 = function(x, y)
						self:backToMain()
					end
					t[countX][j].Fun3Name = pg.getGameString("BACK_TO_PRE")
					t[countX][j].Fun4 = function(x, y)
						local _, button = self.view.mainLabUList:TryGetChildAt(i - 1)
						local uList = button:GetChild("List"):GetComponent("UList")
						local _, btn = uList:TryGetChildAt(j - 1)

						ClientSettingUtils["set_" .. data[i].info.funcType](btn.dataFromUList)
					end
					t[countX][j].Fun4Name = pg.getGameString("GAMEPAD_CHOOSE")

					if self.curTabIndex and self.curTabIndex > 0 then
						t[countX][j].Fun2 = function(x, y)
							self.view.btnReSetUButton.luaClick()
						end
						t[countX][j].Fun2Name = pg.getGameString("RESTORE_TO_DEFAULT")
						t[countX][j].Fun2IsImportant = true
					end
				end
			elseif data[i].tIndex == 5 then
				t[countX][countY] = {}
				t[countX][countY].Focus = function(x, y)
					self.gamePadComponent.navigation:baseFocus(t, x, y, self.view.consoleKeyUList)
					self.gamePadComponent:deSelectVisualAll()

					local _, button = self.view.mainLabUList:TryGetChildAt(i - 1)

					button:TryChangePage("GamePadFocus", 1)
					self.view.mainLabUList:GoToItem(button)
				end
				t[countX][countY].Fun3 = function(x, y)
					self:backToMain()
				end
				t[countX][countY].Fun3Name = pg.getGameString("BACK_TO_PRE")
				t[countX][countY].Fun4 = function(x, y)
					local _, button = self.view.mainLabUList:TryGetChildAt(i - 1)
					local confirmButton = button:GetChild("BtnConfirm")

					confirmButton.luaClick()
				end
				t[countX][countY].Fun4Name = pg.getGameString("GAMEPAD_CHOOSE")
			end

			countX = countX + 1
		end
	end

	self.gamePadComponent.navigation:initAreaTableSlots(self.gamePadComponent.navigation.SUB_AREA, t)
end

function SettingCtrl:getSettingListData()
	local settingItemData = {}
	local settingData = self.model:getSettingData()
	local tabData = settingData[self.curTabIndex]
	local showReset = self.model:checkShowReset(tabData.tab)

	LuaUIUtils.setUIViewVisible(self.view.btnReSetUButton.gameObject, showReset)

	local haveBtn = self.model:checkHaveBtn(tabData.tab)

	self.view.root:TryChangePage("HaveBtn", haveBtn and 1 or 0)

	for index2, cate in ipairs(tabData.items) do
		if cate.cate and cate.cate ~= "null" then
			settingItemData[#settingItemData + 1] = cate
		end

		for index3, settingItem in ipairs(cate.settingList) do
			settingItemData[#settingItemData + 1] = settingItem
		end
	end

	return settingItemData
end

function SettingCtrl:isSettingVisibleForCurrentInputDevice(funcType)
	local isUsingGamepad = pg.game.input:isUsingGamepad()

	if UIConst.GAMEPAD_ONLY_SETTING_FUNC_TYPES[funcType] then
		return isUsingGamepad
	end

	if UIConst.NON_GAMEPAD_ONLY_SETTING_FUNC_TYPES[funcType] then
		return not isUsingGamepad
	end

	return true
end

function SettingCtrl:renderSettingItem(button, index, data)
	if data.tIndex == 0 then
		button:TryChangePage("EmptyWidget", index == 0 and 1 or 0)

		return
	end

	local funcType = data.info.funcType
	local buttonFunc = data.info.buttonFunc

	if funcType == nil and buttonFunc == nil and data.tIndex ~= self.model.keyReplaceIndex then
		return
	end

	local detailTipBtn, selectorSortSelector
	local objectReference = button:GetComponent("ObjectReference")

	if objectReference then
		detailTipBtn = objectReference:GetRefValue("detailTipBtn")
		selectorSortSelector = objectReference:GetRefValue("selectorSortUSelector")
	end

	if not string.isNilOrEmpty(data.desc) then
		if detailTipBtn then
			detailTipBtn:SetActive(true)

			detailTipBtn.tooltipId = pg.getLocalizationText(data.desc)

			if selectorSortSelector then
				function button.luaClick()
					selectorSortSelector:InteractPopup(true)
				end
			else
				button.luaClick = nil
			end
		end
	else
		if detailTipBtn then
			detailTipBtn:SetActive(false)
		end

		button.luaClick = nil
	end

	if data.info.funcParam and data.info.funcParam[1] and ClientSettingUtils["check_" .. data.info.funcParam[1]] and not ClientSettingUtils["check_" .. data.info.funcParam[1]]() then
		button:SetActive(false)

		return
	end

	if funcType and ClientSettingUtils["check_" .. funcType] and not ClientSettingUtils["check_" .. funcType]() then
		button:SetActive(false)

		return
	end

	if not self:isSettingVisibleForCurrentInputDevice(funcType) then
		button:SetActive(false)

		return
	end

	button:SetActive(true)

	if data.tIndex == 1 or data.tIndex == 8 then
		local selector = button:GetChild("SelectorSort"):GetComponent("USelector")
		local selectorText = selector:GetChild("TxtName"):GetComponent("USDFText")

		selector.selectedIndex = -1

		function selector.luaRenderPopup(popup, uList)
			function uList.luaRenderItem(button2, index2, data2)
				button2:TryChangePage("Check", data2.selected and 2 or 1)
			end
		end

		local optionData = ClientSettingUtils.getOptionsData(data)
		local getter = funcType and ClientSettingUtils["get_" .. funcType]

		if not getter then
			button:SetActive(false)

			return
		end

		local curValue = getter(optionData, data.info.funcParam)

		if curValue == nil then
			button:SetActive(false)

			return
		end

		if funcType == "setVideoQuality" then
			for idx, option in pairs(optionData) do
				if option.value == pg.game.setting:getInt(ClientConst.PrefKey.VideoQualityRecommend, -1) then
					option.label = ClientTextUtils.concatByLanguage(option.label, pg.getGameString("VIDEO_QUALITY_RECOMMEND"))
				end
			end
		elseif funcType == "crossPlatform" then
			local _h = SettingCtrl._platformHooks
			local isReadOnly = _h and _h.isCrossPlatformSettingReadOnly and _h.isCrossPlatformSettingReadOnly()

			if isReadOnly then
				local curOption = optionData[curValue + 1]

				if not curOption then
					button:SetActive(false)

					return
				end

				optionData = {
					curOption
				}
				curValue = 0
			end
		end

		selector.options = optionData
		selector.selectedIndex = curValue

		selector:RefreshOptions()
		selector:RefreshSelector()

		local selectedOption = optionData[selector.selectedIndex + 1]

		if selectedOption then
			ClientTextUtils.setText(selectorText, selectedOption.label)
		end

		function selector.luaOptionClick(optionButton, optionData)
			if ClientConfigCloudEnable == "true" and funcType == ClientConst.SettingFuncType.VideoQuality then
				self:forceSetCloudGameVideoQuality(optionData.value)
			else
				ClientSettingUtils.applyPlayerSettingValue(funcType, optionData.value, data.info.funcParam)
			end

			local logKey = funcType

			if data.info.funcParam and data.info.funcParam[1] then
				logKey = logKey .. data.info.funcParam[1]
			end

			ClientSettingUtils.setLog(logKey, optionData.value)
		end
	elseif data.tIndex == 2 or data.tIndex == 7 then
		local slider = button:GetChild("Slider"):GetComponent("USlider")

		slider.luaValueChanged = nil

		local sliderText = button:GetChild("Text"):GetComponent("UBaseText")
		local isAudio = data.info.tab == "audio"

		button:TryChangePage("isAudio", isAudio and 0 or 1)

		local getter = funcType and ClientSettingUtils["get_" .. funcType]

		if not getter then
			button:SetActive(false)

			return
		end

		local curValue = getter(nil, data.info.funcParam)

		if curValue == nil then
			button:SetActive(false)

			return
		end

		local minValue, maxValue = ClientSettingUtils.getSliderMinMaxValue(data.info)

		slider.minValue = minValue
		slider.maxValue = maxValue
		slider.value = curValue

		local sliderStep = 0.1
		local setupMethod = "sliderStep_" .. funcType

		if ClientSettingUtils[setupMethod] then
			sliderStep = ClientSettingUtils[setupMethod]()
		elseif slider.maxValue - slider.minValue >= 10 or data.info.valueType == "int" then
			sliderStep = 1
		end

		slider.stepSize = sliderStep

		ClientTextUtils.setText(sliderText, tostring(curValue))

		function slider.luaValueChanged(value)
			ClientSettingUtils.applyPlayerSettingValue(funcType, value, data.info.funcParam)
			ClientSettingUtils.setLog(funcType, value)
			ClientTextUtils.setText(sliderText, tostring(value))
		end
	elseif data.tIndex == 3 then
		local getter = funcType and ClientSettingUtils["get_" .. funcType]

		if not getter then
			button:SetActive(false)

			return
		end

		local curValue = getter()
		local optionData = ClientSettingUtils.getOptionsData(data)

		if not optionData[curValue] then
			button:SetActive(false)

			return
		end

		optionData[curValue].selected = true

		local uList = button:GetChild("List"):GetComponent("UList")

		function uList.luaRenderItem(button2, index2, data2)
			local icon = button2:GetChild("Bg"):GetComponent("UImage")

			if data2.img then
				icon.url = data2.img
			end
		end

		function uList.luaClick(button2, data2)
			ClientSettingUtils.applyPlayerSettingValue(funcType, data2.value)
			ClientSettingUtils.setLog(funcType, data2.value)
		end

		uList:SetList(optionData)
	elseif data.tIndex == 4 then
		local objectReference = button:GetComponent("ObjectReference")
		local btnEditorUButton = objectReference:GetRefValue("btnEditorUButton")
		local consoleWidgetTransform = objectReference:GetRefValue("consoleWidgetTransform")
		local instructionUButton = objectReference:GetRefValue("instructionUButton")
		local pcWidgetTransform = objectReference:GetRefValue("pcWidgetTransform")
		local layoutBoxAnimation = objectReference:GetRefValue("layoutBoxAnimation")

		if pg.game.input:isUsingGamepad() then
			local curDeviceType = pg.game.input:getCurDeviceType()

			if curDeviceType == InputDeviceType.PSPad then
				instructionUButton:TryChangePage("Controller_Platform", 1)
			elseif curDeviceType == InputDeviceType.XBox then
				instructionUButton:TryChangePage("Controller_Platform", 0)
			elseif curDeviceType == InputDeviceType.SwitchPad then
				instructionUButton:TryChangePage("Controller_Platform", 2)
			end

			local gamepadKeyRoot = consoleWidgetTransform:Find("KeyText")
			local gamepadTextMap = ClientSettingUtils.getGamepadTextList(gamepadKeyRoot)

			for _, keyText in pairs(gamepadTextMap) do
				ClientTextUtils.setText(keyText, "")
			end

			local Resolver = require("GameApp.Input.GamepadManualResolver")
			local SettingKeyReplaceModel = require("Guis.Panels.SettingKeyReplace.SettingKeyReplaceModel")
			local kReplaceModel = pg.global.ui.settingKeyReplace and pg.global.ui.settingKeyReplace.model or SettingKeyReplaceModel

			for index, value in ipairs(ClientSettingUtils.gamepadShowKeyList) do
				local path = pg.game.input.gamepadHotkeyManager:GetActionPath(value)

				if path == "" then
					path = ClientSettingUtils.gamepadShowKeyDefaultPathMap[value]
				end

				local genericPath = Resolver.getGenericPathByDevicePath(path)

				if genericPath then
					path = genericPath
				end

				path = ClientSettingUtils.getGamepadGenericPath(path)

				if not gamepadTextMap[path] and ClientSettingUtils.gamepadShowKeyDefaultPathMap[value] then
					path = ClientSettingUtils.gamepadShowKeyDefaultPathMap[value]
				end

				if gamepadTextMap[path] then
					local text = ClientSettingUtils.getGamepadShowKeyText(value, kReplaceModel)

					if text then
						ClientTextUtils.setText(gamepadTextMap[path], text)
					end
				end
			end

			self:bindHotKey(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonWest, function()
				self.btnEditor.luaClick()
			end, nil, btnEditorUButton.gameObject)
		else
			self:renderKeyboardItem(pcWidgetTransform, data)
		end

		self.btnEditor = btnEditorUButton

		function self.btnEditor.luaClick()
			ClientSettingUtils.openKeyReplace()
		end

		if not self.tIndex4AnimPlayed then
			layoutBoxAnimation:Play("VX_Setting_Item_In")

			self.tIndex4AnimPlayed = true
		end
	elseif data.tIndex == 5 then
		local objectReference = button:GetComponent("ObjectReference")
		local confirmButton = objectReference:GetRefValue("btnConfirmUButton")
		local objectReference2 = confirmButton:GetComponent("ObjectReference")
		local txtNameUBaseText = objectReference2:GetRefValue("txtNameUText")
		local textId = SettingSelectorText[data.info.widgetTxt[1]].name

		ClientTextUtils.setText(txtNameUBaseText, pg.getLocalizationText(textId))

		local function onConfirm()
			ClientSettingUtils.setValue(buttonFunc[1])
			ClientSettingUtils.setLog(buttonFunc[1], 1)
		end

		confirmButton.luaClick = onConfirm
		button.luaClick = onConfirm
	elseif data.tIndex == 6 then
		local objectReference = button:GetComponent("ObjectReference")
		local downloadList = objectReference:GetRefValue("downloadList")

		function downloadList.luaRenderItem(button1, index1, data1)
			self:renderPackDownloadItem(button1, data1, funcType)
		end

		downloadList:SetList(data.downloadItems)
		self:goToSelectedPackDownloadItem(downloadList, data)
	elseif data.tIndex == 10 then
		self:renderAccountBindItem(button, data)
	end
end

function SettingCtrl:renderPackDownloadItem(button, data, funcType)
	local objectReference = button:GetComponent("ObjectReference")
	local imgPicUImage = objectReference:GetRefValue("imgPicUImage")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local txtTotalUSDFText = objectReference:GetRefValue("txtTotalUSDFText")
	local downloadState = pg.game.resourceDownload and pg.game.resourceDownload:getPackDownloadState(data, data._downloadState or {}) or nil

	data._downloadState = downloadState

	ClientTextUtils.setText(txtNameUSDFText, data.text)
	ClientTextUtils.setText(txtTotalUSDFText, self:getPackDownloadTotalText(data, downloadState))

	imgPicUImage.url = data.iconUrl

	self:renderPackDownloadState(button, downloadState)

	local function onClick()
		if not pg.game.resourceDownload then
			return
		end

		local newState = pg.game.resourceDownload:requestDownloadPack(data)

		data._downloadState = newState

		ClientTextUtils.setText(txtTotalUSDFText, self:getPackDownloadTotalText(data, newState))
		self:renderPackDownloadState(button, newState)
	end

	button.luaClick = onClick
end

function SettingCtrl:getPackDownloadTotalText(data, downloadState)
	if pg.game.resourceDownload then
		return pg.game.resourceDownload:formatDownloadBytes(downloadState and downloadState.totalSize or 0)
	end

	return "0B"
end

function SettingCtrl:renderPackDownloadState(button, downloadState)
	local objectReference = button:GetComponent("ObjectReference")
	local progressUProgress = objectReference:GetRefValue("progressUProgress")
	local txtStateUSDFText = objectReference:GetRefValue("txtStateUSDFText")
	local txtDownloadingUSDFText = objectReference:GetRefValue("txtDownloadingUSDFText")
	local txtProgressUSDFText = objectReference:GetRefValue("txtProgressUSDFText")
	local stateName = downloadState and downloadState.stateName or "NotDownloaded"

	button:TryChangePage("State", stateName)

	local stateTextKey = self.PACK_DOWNLOAD_STATE_TEXT_KEY[stateName]
	local stateText = pg.getGameString(stateTextKey)

	if stateName == "Downloading" then
		ClientTextUtils.setText(txtDownloadingUSDFText, pg.getFormatText(stateText, self:getPackDownloadProgressText(downloadState)))
	else
		ClientTextUtils.setText(txtDownloadingUSDFText, stateText)
	end

	progressUProgress.normalizedValue = downloadState and downloadState.progress or 0

	ClientTextUtils.setText(txtProgressUSDFText, self:getPackDownloadPercentText(downloadState))
end

function SettingCtrl:getPackDownloadProgressText(downloadState)
	if not downloadState or not pg.game.resourceDownload then
		return ""
	end

	return pg.game.resourceDownload:formatDownloadBytes(downloadState.curSize or 0) .. "/" .. pg.game.resourceDownload:formatDownloadBytes(downloadState.totalSize or 0)
end

function SettingCtrl:getPackDownloadPercentText(downloadState)
	local progress = downloadState and downloadState.progress or 0

	return tostring(math.floor(progress * 100 + 0.5)) .. "%"
end

function SettingCtrl:renderAccountBindItem(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local nameText = objectReference:GetRefValue("txtName")
	local tipsText = objectReference:GetRefValue("txtTips")
	local bindButton = objectReference:GetRefValue("btnUButton")
	local bindButtonText = objectReference:GetRefValue("txtbtn")
	local widgetTxt = data.info.widgetTxt
	local isBound, displayText, actionTextIndex, unboundTextIndex = ClientSettingUtils.getAccountBindDisplayData(data.info)
	local actionTextId = SettingSelectorText[widgetTxt[actionTextIndex]].name

	if string.isNilOrEmpty(displayText) and unboundTextIndex then
		local unboundTextId = SettingSelectorText[widgetTxt[unboundTextIndex]].name

		displayText = pg.getLocalizationText(unboundTextId)
	end

	ClientTextUtils.setText(nameText, data.label)
	ClientTextUtils.setText(tipsText, displayText or "")
	ClientTextUtils.setText(bindButtonText, pg.getLocalizationText(actionTextId))

	function bindButton.luaClick()
		ClientSettingUtils.handleAccountBindClick(data.info, isBound)
	end

	button.luaClick = bindButton.luaClick
end

local function renderKeyListItem(button, index, data)
	button:TryChangePage("IsEmpty", data.isEmpty and 1 or 0)

	if not data.isEmpty then
		button:TryChangePage("Color", data.color)

		local keyText = string.gsub(data.key, "^%l", string.upper)

		ClientTextUtils.setText(button.transform:Find("Widget/Text"):GetComponent("UBaseText"), keyText)
	end
end

function SettingCtrl:renderKeyboardItem(pcWidgetTransform, data)
	local objectReference = pcWidgetTransform:GetComponent("ObjectReference")
	local list1UList = objectReference:GetRefValue("list1UList")
	local list2UList = objectReference:GetRefValue("list2UList")
	local list3UList = objectReference:GetRefValue("list3UList")
	local list4UList = objectReference:GetRefValue("list4UList")
	local list5UList = objectReference:GetRefValue("list5UList")
	local list6UList = objectReference:GetRefValue("list6UList")
	local list7UList = objectReference:GetRefValue("list7UList")
	local leftTextUText = objectReference:GetRefValue("leftTextUText")
	local rightTextUText = objectReference:GetRefValue("rightTextUText")

	list1UList.luaRenderItem = renderKeyListItem
	list2UList.luaRenderItem = renderKeyListItem
	list3UList.luaRenderItem = renderKeyListItem
	list4UList.luaRenderItem = renderKeyListItem
	list5UList.luaRenderItem = renderKeyListItem
	list6UList.luaRenderItem = renderKeyListItem

	local keyList, allKeys = ClientSettingUtils.getKeyboardKeyList()

	list1UList:SetList(keyList[1])
	list2UList:SetList(keyList[2])
	list3UList:SetList(keyList[3])
	list4UList:SetList(keyList[4])
	list5UList:SetList(keyList[5])
	list6UList:SetList(keyList[6])

	function list7UList.luaRenderItem(button, index, data)
		button:TryChangePage("Color", data.color)

		local objectReference = button:GetComponent("ObjectReference")
		local keyUText = objectReference:GetRefValue("keyUText")
		local keyNameUText = objectReference:GetRefValue("keyNameUText")
		local keyText = string.gsub(data.key, "^%l", string.upper)

		ClientTextUtils.setText(keyUText, keyText)
		ClientTextUtils.setText(keyNameUText, pg.getLocalizationText(data.desc))
	end

	list7UList:SetList(allKeys)
	ClientTextUtils.setText(leftTextUText, pg.getLocalizationText(keyList[7][1].desc))
	ClientTextUtils.setText(rightTextUText, pg.getLocalizationText(keyList[7][2].desc))
end

function SettingCtrl:initSelectorArea(data, selector, optionData, funcType)
	local t = {}

	for i = 1, #data do
		local x = math.floor((i - 1) / 1) + 1
		local y = (i - 1) % 1 + 1

		if y == 1 then
			t[x] = {}
		end

		t[x][y] = {}
		t[x][y].Focus = function(x1, y1)
			self.gamePadComponent.navigation:baseFocus(t, x1, y1, self.view.consoleKeyUList)
			self.gamePadComponent:deSelectVisualAll()

			local btn = self.curCommonSwitchSelector.transform:GetChild(4):GetChild(1):Find("View/Content"):GetChild(i - 1):GetComponent("UButton")

			btn:TryChangePage("button", 2)
		end
		t[x][y].Fun3 = function(x1, y1)
			self.curCommonSwitchSelector:InteractPopup()
			self.gamePadComponent.navigation:resumeCursor()
			self.gamePadComponent.navigation:reFocus()
		end
		t[x][y].Fun3Name = pg.getGameString("BACK_TO_PRE")
		t[x][y].Fun4 = function(x1, y1)
			local btn = self.curCommonSwitchSelector.transform:GetChild(4):GetChild(1):Find("View/Content"):GetChild(i - 1):GetComponent("UButton")

			btn:OnClickSimulate()
			self.gamePadComponent.navigation:resumeCursor()
			self.gamePadComponent.navigation:delayFocus(nil, 0.1)
		end
		t[x][y].Fun4Name = pg.getGameString("GAMEPAD_CHOOSE")
	end

	if funcType == "setScreenMode" then
		self.gamePadComponent.navigation:initAreaTableSlots(self.gamePadComponent.navigation.SCREEN_MODE_AREA, t)
	elseif funcType == "setResolution" then
		self.gamePadComponent.navigation:initAreaTableSlots(self.gamePadComponent.navigation.SCREEN_RESOLUTION_AREA, t)
	elseif funcType == "language" or funcType == "audioLanguage" then
		self.gamePadComponent.navigation:initAreaTableSlots(self.gamePadComponent.navigation.LANGUAGE_SELECTOR_AREA, t)
	elseif funcType == "antialiasing" then
		self.gamePadComponent.navigation:initAreaTableSlots(self.gamePadComponent.navigation.SCREEN_AA_AREA, t)
	else
		self.gamePadComponent.navigation:initAreaTableSlots(self.gamePadComponent.navigation.COMMON_SWITCH_AREA, t)
	end
end

function SettingCtrl:onDestroy()
	self:stopResourceDownloadRefreshTimer()

	if CS.XGUI.Navigation.NavManager.Instance then
		CS.XGUI.Navigation.NavManager.Instance:RemoveLuaFocusCursorMovedListener("Setting")
	end

	ClientSettingUtils.reportLog()

	if pg.game.setting:isConsolePlatform() or ClientConfigCloudEnable == "true" then
		pg.game.setting:save()
	end

	UICtrl.onDestroy(self)
end

function SettingCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	if not info or not info.selectedTabName and not info.selectedPackId then
		return
	end

	self.selectedTabName = info.selectedTabName
	self.selectedPackId = info.selectedPackId

	if not self.view or not self.view.mainLabUList then
		return
	end

	local settingData = self.model:getSettingData()

	self:selectTabByName(self.selectedTabName, settingData)
	self:refreshSettingTabList(settingData)

	if self.view.btnDownloadAllUButton then
		self.view.btnDownloadAllUButton:SetActive(settingData[self.curTabIndex].tab == "resource")
	end

	if self.view.btnClearUButton then
		self.view.btnClearUButton:SetActive(settingData[self.curTabIndex].tab == "resource")
	end

	self:refreshSettingList()
end

function SettingCtrl:onShow()
	if ClientConfigAppCountry == "cn" then
		self.view.textRecord:SetActive(true)

		function self.view.textRecord.luaOnHyperlinkClick(str1, str2)
			LuaUIUtils.clickHyperText(str1, str2, self.view.textRecord)
		end

		ClientTextUtils.setText(self.view.textRecord, pg.getGameString("LEGAL_APP_TIP"))
	else
		self.view.textRecord:SetActive(false)
	end

	self:refreshResourceDownloadTimerState()
end

function SettingCtrl:onHide()
	self:stopResourceDownloadRefreshTimer()
end

function SettingCtrl:onInputDeviceChanged(deviceType)
	self:refreshSettingList()
end

return SettingCtrl
