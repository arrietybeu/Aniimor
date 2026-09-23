-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Help\\HelpCtrl.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("HelpCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local Const = require("Common.Const.Const")
local HelpConst = require("Const.HelpConst")
local GuideCourseData = require("Data.guide_course_data")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local HotkeyConst = require("Const.HotkeyConst")
local UIConst = require("Const.UIConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientUtils = require("Utils.ClientUtils")
local PetResearchUtils = require("Guis.Utils.PetResearchUtils")
local LevelData = require("Data.level_data")
local NoticeDef = require("Common.NoticeDef")
local ClientTextUtils = require("Utils.ClientTextUtils")
local FuncMenuListData = require("Data.func_menu_list_data")
local HelpCtrl = Class.LightClass("HelpCtrl", UICtrl)
local ToBool = ToBool

HelpCtrl.messages = {
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	}
}

function HelpCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	info = info or {}
	self.specificScene = info.specificScene
	self.keepVisibleUIs = info.keepVisibleUIs

	local helpId = tonumber(info.helpId or 0)

	self.jumpCb = info.jumpCb

	if info.helpGroupId then
		local res, id = self.model.getHelpIdByGroupId(info.helpGroupId)

		if res then
			helpId = id
		end
	end

	self:initData()

	if helpId > 0 then
		self.view.optionList:SetEnableCustomInterval(false)

		self.selectedPageIndex = self.model:getHelpType(helpId)
	else
		self.view.optionList:SetEnableCustomInterval(true)

		self.selectedPageIndex = HelpConst.EntryType.ENTRY_ALL
	end

	self.view.panelObj:TryChangePage("Empty", 0)

	self.prevBtnBanned = false
	self.nextBtnBanned = false

	function self.view.listTabUList.luaRenderItem(btn, idx, data)
		local objectReference = btn:GetComponent("ObjectReference")
		local nameText = objectReference:GetRefValue("name1")
		local nameSelectText = objectReference:GetRefValue("name2")
		local realName = pg.getGameString(data.name)

		ClientTextUtils.setText(nameText, realName)
		ClientTextUtils.setText(nameSelectText, realName)

		function btn.luaClick()
			self.selectedPageIndex = idx

			self:showPageEntries()
		end
	end

	self.view.listTabUList:SetList(self.model.entryTitle)

	self.gotoIndex = helpId

	self:onInitPage()
end

function HelpCtrl:initData()
	self.entriesCache = self.model:getTotalHelpPageEntries(self.specificScene)

	for k = HelpConst.EntryType.ENTRY_ALL, HelpConst.EntryType.ENTRY_EXPLORE do
		local cache = self.entriesCache[k]
		local recentCnt, recentlyEntries = self.model:getRecentlyUnlockEntries(k)

		if recentCnt > 0 and recentlyEntries then
			for _, entry in ipairs(cache.entries) do
				table.insert(recentlyEntries, entry)
			end

			cache.entries = recentlyEntries
		end
	end
end

function HelpCtrl:onOpen(info)
	info = info or {}
	self.keepVisibleUIs = info.keepVisibleUIs

	ClientTextUtils.setText(self.view.closeBtnUSDFText, pg.getLocalizationText(FuncMenuListData[91].name))
end

function HelpCtrl:onInitPage()
	self:refreshListTab()
	self:showPageEntries()
	self.view.tabBarObjectCom:TryChangePage("TopLab", tonumber(self.selectedPageIndex))
end

function HelpCtrl:refreshListTab()
	self.view:setListTab(not self.specificScene, self.selectedPageIndex)
end

function HelpCtrl:onDestroy()
	self.selectedPageIndex = 0
	self.keepVisibleUIs = nil

	UICtrl.onDestroy(self)
end

function HelpCtrl:getWhiteList()
	return self.keepVisibleUIs or UICtrl.getWhiteList(self)
end

function HelpCtrl:addListener()
	local closeBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.widget.gameObject, "closeBind")

	closeBind.isVirtual = true
	closeBind.priority = -1
	closeBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel

	function closeBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self:dismiss()
		end
	end

	function self.view.closeBtn.luaClick()
		self:onCloseBtnClick()
	end

	function self.view.searchInputField.luaClick()
		self:enableCloseBtnShotCut(false)
		self:onSearchInputFieldClick()
	end

	function self.view.searchInputField.luaEndEdit()
		self:enableCloseBtnShotCut(true)
	end

	function self.view.searchInputField.luaValueChanged()
		self:showPageEntries()
	end

	function self.view.inputDeleteBtn.luaClick()
		self:onInputDeleteBtnClick()
	end

	function self.view.trashBtn.luaClick()
		self:onTrashBtnClick()
	end

	function self.view.optionList.luaRenderItem(button, index, data)
		self:onRefreshEntries(button, index, data)
	end

	function self.view.pagePointList.luaRenderItem(button, index, data)
		self:onRefreshPagePoints(button, index, data)
	end

	function self.view.redirectBtn.luaClick()
		self:onRedirectBtnClick()
	end

	function self.view.prevBtn.luaClick()
		self:onPrevBtnClick()
	end

	function self.view.nextBtn.luaClick()
		self:onNextBtnClick()
	end

	self:addRedirectFunctionMap()
	ClientTextUtils.setText(self.view.titleUSDFText, ClientTextUtils.getGameString("HELP"))
	ClientTextUtils.setText(self.view.btnRedirectUSDFText, ClientTextUtils.getGameString("SWITCH"))
end

function HelpCtrl:addRedirectFunctionMap()
	self.functionBtnMap = {}
	self.functionBtnMap[UIConst.UI_ID_MAP] = function()
		pg.global.ui.hudV2:openMap()
	end
	self.functionBtnMap[UIConst.UI_ID_QUEST_PANEL] = function()
		pg.global.ui.hudV2:openQuest()
	end
	self.functionBtnMap[UIConst.UI_ID_PHOTO] = function()
		pg.global.ui.hudV2:openPhotoPanel()
	end
	self.functionBtnMap[UIConst.UI_ID_PET_BALL] = function()
		pg.global.ui.hudV2:openPetBall()
	end
	self.functionBtnMap[UIConst.UI_ID_SHOP_MAIN] = function()
		if LuaUIUtils.checkFuncTemporaryDisable(UIConst.UI_ID_SHOP_MAIN) then
			return
		end

		pg.global.ui:open(UIConst.UI_ID_SHOP_MAIN)
	end
	self.functionBtnMap[UIConst.UI_ID_PET_RESEARCH] = function()
		pg.global.ui.hudV2:openPetResearch()
	end
	self.functionBtnMap[UIConst.UI_ID_PET_MANAGEMENT] = function()
		pg.global.ui.hudV2:openPetPanel()
	end
	self.functionBtnMap[UIConst.UI_ID_PLAYER_ENHANCEMENT] = function()
		pg.global.ui.hudV2:openPlayerEnhance()
	end
	self.functionBtnMap[UIConst.UI_ID_INVENTORY] = function()
		pg.global.ui.inventory:open()
	end
	self.functionBtnMap[UIConst.UI_ID_OPEN_SPECIAL_TRAIN_PANEL] = function()
		pg.global.ui.hudV2:openSpecialTrain()
	end
	self.functionBtnMap[UIConst.UI_ID_PET_RESEARCH_DETAIL_V2] = function(pageIndex)
		PetResearchUtils.openPetResearchDetail({
			templateId = 1005100,
			subPageIdx = pageIndex
		})
	end
	self.functionBtnMap[UIConst.UI_ID_PET_MANAGEMENT] = function(pageIndex)
		pg.global.ui:open(UIConst.UI_ID_PET_MANAGEMENT, {
			selectSlot = 1,
			subTab = pageIndex
		})
	end
	self.functionBtnMap[UIConst.UI_ID_PET_RESEARCH_FRONT_PAGE] = function()
		pg.global.ui.petResearchFrontPageV2:open({
			countryId = 300001
		})
	end
	self.functionBtnMap[UIConst.UI_ID_CHAT] = function(pageIndex)
		pg.global.ui:open(UIConst.UI_ID_CHAT, {
			subTab = pageIndex
		}, nil, nil, {
			ignoreDisableMainCamera = true
		})
	end
	self.functionBtnMap[UIConst.UI_ID_RESTRAINT] = function()
		pg.global.ui.tips:showRestraint()
	end
	self.functionBtnMap[UIConst.UI_ID_PLAYER_ENHANCEMENT] = function(pageIndex)
		LuaUIUtils.openPlayerEnhance({
			defaultPlayerActive = false,
			defaultMode = pageIndex
		})
	end
	self.functionBtnMap[UIConst.UI_ID_SETTING] = function(pageIndex)
		pg.global.ui:open(UIConst.UI_ID_SETTING, {
			selectedTabName = HelpConst.SettingTabIndex2Name[pageIndex]
		})
	end
end

function HelpCtrl:onShow()
	return
end

function HelpCtrl:setPrevBtnActive(active)
	self.view.prevBtn.interactable = active
	self.prevBtnBanned = not active
end

function HelpCtrl:setNextBtnActive(active)
	self.view.nextBtn.interactable = active
	self.nextBtnBanned = not active
end

function HelpCtrl:onCloseBtnClick()
	self:dismiss()
end

function HelpCtrl:continueSwitchPages(isRight)
	if isRight == true then
		if self.selectedPageIndex == HelpConst.EntryType.ENTRY_EXPLORE then
			self.selectedPageIndex = HelpConst.EntryType.ENTRY_ALL
		else
			self.selectedPageIndex = self.selectedPageIndex + 1
		end
	elseif self.selectedPageIndex == HelpConst.EntryType.ENTRY_ALL then
		self.selectedPageIndex = HelpConst.EntryType.ENTRY_EXPLORE
	else
		self.selectedPageIndex = self.selectedPageIndex - 1
	end

	self:refreshListTab()
	self:showPageEntries()
end

function HelpCtrl:onInputDeleteBtnClick()
	self.view.searchInputField.text = ""
end

function HelpCtrl:onSearchInputFieldClick()
	self.selectedBtn = self.view.searchInputField
end

function HelpCtrl:onTrashBtnClick()
	ClientTextUtils.setText(self.view.searchInputField, "")
end

function HelpCtrl:enableCloseBtnShotCut(enable)
	local keyBindings = self.view.closeBtn.gameObject:GetComponents(typeof(KeyBindingPro))

	for i = 1, keyBindings.Length do
		keyBindings[i - 1].enabled = enable
	end
end

function HelpCtrl:onRefreshEntries(button, index, data)
	local isTitle = ToBool(data.isTitle)
	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

	if not isTitle then
		function button.luaClick()
			if data.isUnlock then
				button.isSelected = true
				self.selectedBtn = button

				self:onEntryBtnClick(data)
			else
				pg.global.showBubbleMessage(NoticeDef.HELP_ENTRY_LOCK)
			end
		end

		ClientTextUtils.setText(txtNameUSDFText, pg.getLocalizationText(data.entryName))
		button:TryChangePage("status", data.isUnlock and 0 or 1)

		if not data.isUnlock then
			local lockTextUSDFText = objectReference:GetRefValue("lockTextUSDFText")

			ClientTextUtils.setText(lockTextUSDFText, pg.getLocalizationText(data.entryName))
		end

		local keyHotKeyContent = objectReference:GetRefValue("keyHotKeyContent")

		if string.isNilOrEmpty(data.actionPath) then
			keyHotKeyContent:SetHotKeyPaths("")
		else
			keyHotKeyContent:SetHotKeyPaths(data.actionPath)
		end
	else
		button.skipInListSwitch = true

		ClientTextUtils.setText(txtNameUSDFText, self:getTitleText(data.entryName))

		local txNumberUSDFText = objectReference:GetRefValue("txNumberUSDFText")

		if data.unlockCnt then
			ClientTextUtils.setText(txNumberUSDFText, string.format("%d/%d", data.unlockCnt, data.totalNum))
		else
			ClientTextUtils.setText(txNumberUSDFText, data.totalNum)
		end
	end

	button.name = tostring(data.id)

	if self.needResetSelectBtn and not isTitle and data.isUnlock and self.gotoIndex == 0 and self.curEntry == nil then
		button.isSelected = true
		self.selectedBtn = button

		button.luaClick()

		self.needResetSelectBtn = false

		self:startTimer(function()
			self.view.optionList:GoToIndexMinCost(index)
		end, 0.1)
	end

	local isGotoIndex = self.gotoIndex == data.index or self.gotoIndex == data.groupIndex

	if isGotoIndex and button and not isTitle then
		self.gotoIndex = 0

		button.luaClick()
		self:startTimer(function()
			self.view.optionList:GoToIndexMinCost(index)
		end, 0.1)
	end
end

function HelpCtrl:onEntryBtnClick(entry)
	self.curEntry = entry
	self.curHelpIds = self.curEntry.helpId
	self.curEntryInfoPagesMaxNum = #self.curHelpIds
	self.curEntryInfoPageId = 1

	self:refreshRightPanel(self.curEntryInfoPageId)

	local showInfoPage = self.curEntryInfoPagesMaxNum > 1

	self.view.prevBtn:SetActiveFastest(showInfoPage)
	self.view.nextBtn:SetActiveFastest(showInfoPage)
	self.view.pagePointList:SetActiveFastest(showInfoPage)
end

function HelpCtrl:onRefreshPagePoints(button, index, data)
	function button.luaClick()
		self.curEntryInfoPageId = data.pageIndex

		self:refreshPageContext()
		self:refreshPageBtn(self.curEntryInfoPageId)
	end
end

function HelpCtrl:onRedirectBtnClick()
	local helpInfo = self.model.getHelpInfo(self.curHelpIds[self.curEntryInfoPageId])
	local course = helpInfo.course
	local uiId = helpInfo.openUi
	local isUIIdValid = ToBool(uiId)
	local courseValid, reason = self:checkCourseValid(course)

	if not LuaUIUtils.checkUIFuncValid(uiId) then
		return
	end

	if not courseValid then
		if isUIIdValid then
			local concreteUI = helpInfo.concreteUI

			self:jumpToFunctionUI(uiId, concreteUI)
		elseif reason == 0 then
			pg.global.showBubbleMessage(NoticeDef.FUNC_NOT_UNLOCK)
		elseif reason == 1 then
			local courseTitle = GuideCourseData[course].title

			pg.global.showBubbleMessageRaw(pg.getFormatText(pg.getGameString("COURSE_CLOSED"), pg.getLocalizationText(courseTitle)))
		end
	else
		local courseTitle = GuideCourseData[course].title

		pg.global.showCommonTipUse(pg.getGameString("ENTRY_COURSE_HELP_TITLE"), pg.getFormatText(pg.getGameString("ENTRY_COURSE_HELP"), pg.getLocalizationText(courseTitle)), nil, function()
			if pg.global.ui:checkUIOpen(UIConst.UI_ID_FUNC_MENU) then
				pg.global.ui:close(UIConst.UI_ID_FUNC_MENU)
			end

			self:dismiss()
			ClientUtils.playTeleportDissolveEffectAndTeleportByFunc(function()
				pg.me:startCourse(course)
			end)
		end, nil)
	end
end

function HelpCtrl:onPrevBtnClick()
	if self.prevBtnBanned then
		return
	end

	self:refreshRightPanel(self.curEntryInfoPageId - 1)
end

function HelpCtrl:onNextBtnClick()
	if self.nextBtnBanned then
		return
	end

	self:refreshRightPanel(self.curEntryInfoPageId + 1)
end

function HelpCtrl:refreshRightPanel(curSelectedInfoPageId)
	self:refreshPageBtn(curSelectedInfoPageId)

	self.curEntryInfoPageId = curSelectedInfoPageId

	self:refreshContext()
end

function HelpCtrl:refreshPageBtn(curSelectedInfoPageId)
	if curSelectedInfoPageId < 1 then
		curSelectedInfoPageId = 1
	end

	if curSelectedInfoPageId > self.curEntryInfoPagesMaxNum then
		curSelectedInfoPageId = self.curEntryInfoPagesMaxNum
	end

	self:setPrevBtnActive(curSelectedInfoPageId > 1)
	self:setNextBtnActive(curSelectedInfoPageId < self.curEntryInfoPagesMaxNum)
end

function HelpCtrl:refreshContext()
	ClientTextUtils.setText(self.view.contextNameText, pg.getLocalizationText(self.curEntry.entryName))
	LuaUIUtils.setUIViewVisible(self.view.contextImg, false)
	self:refreshPageContext()
	self:refreshPointPageList()
end

function HelpCtrl:refreshPageContext()
	local info = self.model.getHelpInfo(self.curHelpIds[self.curEntryInfoPageId])

	self.view:setHelpInfo(info)
end

function HelpCtrl:getTitleText(entryName)
	local title = pg.getGameString(entryName)

	if self.specificScene then
		local ldd = LevelData[self.specificScene]

		if ldd then
			title = pg.getLocalizationText(ldd.name)
		else
			title = pg.getGameString(HelpConst.EntryTypeName[4])
		end
	end

	return title
end

function HelpCtrl:refreshPointPageList()
	local data = {}

	for i = 1, self.curEntryInfoPagesMaxNum do
		table.insert(data, {
			tIndex = 0,
			id = i,
			pageIndex = i
		})
	end

	self.view.pagePointList:SetList(data)
	self.view.pagePointList:SelectItem(self.curEntryInfoPageId - 1)
end

function HelpCtrl:showPageEntries()
	self.needResetSelectBtn = true
	self.curEntry = nil

	if ToBool(self.view.searchInputField.text) then
		self.view.inputDeleteBtn:SetActive(true)

		local _, searchedEntries = self:trySearchEntryByKeyword(self.view.searchInputField.text)

		self:showSearchedEntries(searchedEntries)
	else
		self.view.inputDeleteBtn:SetActive(false)
		self.view.panelObj:TryChangePage("Empty", 0)

		local pageId = self.specificScene or self.selectedPageIndex

		self.view.optionList:SetList(self.entriesCache[pageId].entries)
	end
end

function HelpCtrl:showSearchedEntries(entries)
	if ToBool(entries) then
		self.view.panelObj:TryChangePage("Empty", 0)
		self.view.optionList:SetList(entries)
	else
		self.view.panelObj:TryChangePage("Empty", 1)
		self.view.optionList:SetList({}, true)
		ClientTextUtils.setText(self.view.emptySearchText, pg.getFormatText(pg.getGameString("RESEARCH_EMPTY"), self.view.searchInputField.text))
	end
end

function HelpCtrl:initListArea(data)
	local t = {}

	for i = 1, #data do
		local x = math.floor((i - 1) / 1) + 1
		local y = (i - 1) % 1 + 1

		if y == 1 then
			t[x] = {}
		end

		t[x][y] = {}
		t[x][y].Focus = function(x1, y1)
			self.gamePadComponent:baseFocus(t, x1, y1)
			self.gamePadComponent:deSelectAll()

			local _, button = self.view.optionList:TryGetChildAt(i - 1)

			button:TryChangePage("button", 5)
			button.luaClick()
			self.view.optionList:GoToIndexMinCost(i - 1)
		end
		t[x][y].Fun3 = function(x1, y1)
			self:dismiss()
		end
		t[x][y].Fun3Name = pg.getGameString("BACK_TO_PRE")
		t[x][y].Fun7 = function(x1, y1)
			self.view.prevBtn.luaClick()
		end
		t[x][y].Fun7Name = pg.getGameString("PRE_PAGE")
		t[x][y].Fun8 = function(x1, y1)
			self.view.nextBtn.luaClick()
		end
		t[x][y].Fun8Name = pg.getGameString("NXT_PAGE")
	end

	self.gamePadComponent.navigation:initAreaTableSlots(self.gamePadComponent.navigation.LIST_AREA, t)
end

function HelpCtrl:trySearchEntryByKeyword(keyword)
	local pageId = self.specificScene or self.selectedPageIndex

	if pageId == HelpConst.EntryType.ENTRY_ALL then
		local allResults = {}
		local allCnt = 0

		for i = 1, HelpConst.EntryType.ENTRY_EXPLORE do
			local cnt, results = self:trySearchOnePageByKeyword(keyword, i)

			if cnt and cnt > 0 then
				table.mergeList(allResults, results)

				allCnt = allCnt + cnt
			end
		end

		return allCnt, allResults
	else
		return self:trySearchOnePageByKeyword(keyword, pageId)
	end
end

function HelpCtrl:trySearchOnePageByKeyword(keyword, pageId)
	local entries = self.entriesCache[pageId]
	local results = {}
	local cnt = 0
	local foundEntry = false
	local startIndex = 2

	for idx, entry in pairs(entries.entries) do
		if not entry.isRecent then
			local localizedEntryName = pg.getLocalizationText(entry.entryName)

			if string.find(string.split(localizedEntryName, "<")[1], keyword) then
				results[startIndex] = {
					tIndex = 1,
					id = cnt,
					helpId = entry.helpId,
					entryName = entry.entryName,
					sortLevel = entry.sortLevel,
					isUnlock = entry.isUnlock
				}
				cnt = cnt + 1
				foundEntry = true
				startIndex = startIndex + 1
			end
		end
	end

	if foundEntry then
		if ToBool(results) then
			results[1] = {
				tIndex = 0,
				isTitle = true,
				entryName = HelpConst.EntryTypeName[pageId],
				totalNum = cnt
			}

			table.sort(results, function(a, b)
				if a.isTitle then
					return true
				end

				if b.isTitle then
					return false
				end

				return a.sortLevel < b.sortLevel
			end)
		end

		return cnt, results
	end

	return nil
end

function HelpCtrl:getCurrentPageEntries(index)
	return self.model:getHelpPageEntries(index)
end

function HelpCtrl:getRencentlyUnlockedEntryIds(index)
	local player = pg.me

	if not player then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("@hyj no player found")
		end

		return nil
	end

	if index == HelpConst.EntryType.ENTRY_ALL then
		return player:getAllRecentlyUnlockedIds()
	else
		return player:getSubTabRecentlyUnlockedIds(index)
	end
end

function HelpCtrl:jumpToFunctionUI(uiId, tabId)
	self:dismiss()

	local me = pg.me

	if not me then
		return
	end

	local isUnlocked = me:checkFunctionUnlockByUIId(uiId)

	if isUnlocked then
		if self.functionBtnMap[uiId] then
			self.functionBtnMap[uiId](tabId)
		else
			pg.global.ui:open(uiId)
		end

		if self.jumpCb then
			self.jumpCb()
		end
	else
		pg.global.showBubbleMessage(NoticeDef.FUNC_NOT_UNLOCK)
	end
end

function HelpCtrl:checkCourseValid(course)
	if not ToBool(course) then
		return false, -1
	end

	local courseConfig = GuideCourseData[course]

	if not courseConfig then
		return false, -1
	end

	if not pg.me:checkFunctionUnlock(36) then
		return false, 0
	end

	if courseConfig.condition ~= nil and courseConfig.condition ~= 0 then
		return pg.me.triggerMap:isCompleteOrMeetCondition(courseConfig.condition), 1
	end

	return true
end

return HelpCtrl
