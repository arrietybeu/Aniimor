-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\knowledgeDetail\\KnowledgeDetailCtrl.lua

local UICtrl = require("Guis.UICtrl")
local Class = require("Core.Framework.Class")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local KnowledgeManager = require("GameApp.Knowledge.KnowledgeManager")
local logger = LoggerManager.getLogger("KnowledgeDetailCtrl")
local UIConst = require("Const.UIConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local LuaMsgUtils = require("Utils.LuaMsgUtils")
local RedDotConst = require("Const.RedDotConst")
local HotkeyConst = require("Const.HotkeyConst")
local KnowledgeDetailCtrl = Class.LightClass("KnowledgeDetailCtrl", UICtrl)
local SUB_TYPE_TITLE_T_INDEX = 0
local DIRECTORY_T_INDEX = 1
local DATA_2_UI_INDEX = {
	5,
	0,
	1,
	4,
	3,
	2
}

function KnowledgeDetailCtrl:afterInit()
	self.knowledgeManager = KnowledgeManager.getInstance()
	self.detailRefreshVersion = 0
end

function KnowledgeDetailCtrl:onOpen(info)
	self.knowledgeManager:acquireUIData(self)

	info = info or {}
	self.mainTypeMarkedRead = false
	self.detailRefreshVersion = self.detailRefreshVersion + 1
	self.targetKnowledgeId = tonumber(info.knowledgeId)

	local targetLocation = self.targetKnowledgeId and self.knowledgeManager:getKnowledgeLocation(self.targetKnowledgeId) or nil

	self.mainTypeId = targetLocation and targetLocation.mainTypeId or tonumber(info.mainTypeId)

	local mainTypeData = self.knowledgeManager:getMainTypeData(self.mainTypeId)

	if mainTypeData == nil then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("KnowledgeMainTypeData is missing, mainTypeId: %s", tostring(self.mainTypeId))
		end

		return
	end

	ClientTextUtils.setText(self.view.titleTxt, pg.getLocalizationText(mainTypeData.title))
	ClientTextUtils.setText(self.view.collectPercentTxt, string.format("%s %d/%d", pg.getLocalizationText(pg.getGameString("COLLECT_PROGRESS_TXT")), mainTypeData.num, mainTypeData.maxNum))

	self.mainTypeData = mainTypeData
	self.subTypeListMap = {}
	self.directoryButtonMap = {}
	self.targetSubTypeId = targetLocation and targetLocation.subTypeId or nil
	self.targetListId = targetLocation and targetLocation.listId or nil
	self.targetPageIndex = targetLocation and targetLocation.pageIndex or nil
	self.pendingTargetDirectoryClick = targetLocation ~= nil
	self.pendingDefaultDirectoryClick = targetLocation == nil

	local subTypeList = self:buildSubTypeList(mainTypeData)

	self.view.listTab:SetList(subTypeList)

	if targetLocation ~= nil then
		for index, subTypeInfo in ipairs(subTypeList) do
			if subTypeInfo.subTypeId == targetLocation.subTypeId then
				self.view.listTab:GoToIndex(index - 1, true)

				break
			end
		end
	end
end

function KnowledgeDetailCtrl:buildSubTypeList(mainTypeData)
	local subTypeList = {}

	for subTypeId, subTypeData in pairs(mainTypeData.dataDict) do
		table.insert(subTypeList, {
			subTypeId = subTypeId,
			subTypeData = subTypeData
		})
	end

	table.sort(subTypeList, function(a, b)
		local aHasNew = self.knowledgeManager:isSubTypeNew(a.subTypeData)
		local bHasNew = self.knowledgeManager:isSubTypeNew(b.subTypeData)

		if aHasNew ~= bHasNew then
			return aHasNew
		end

		if a.subTypeData.sort == b.subTypeData.sort then
			return a.subTypeId < b.subTypeId
		end

		return a.subTypeData.sort < b.subTypeData.sort
	end)

	return subTypeList
end

function KnowledgeDetailCtrl:buildCatalogList(subTypeData)
	local catalogList = {}

	if subTypeData == nil or subTypeData.dataDict == nil then
		return catalogList
	end

	for listId, catalogData in pairs(subTypeData.dataDict) do
		table.insert(catalogList, {
			listId = listId,
			catalogData = catalogData
		})
	end

	table.sort(catalogList, function(a, b)
		local aHasNew = self.knowledgeManager:isCatalogNew(a.catalogData)
		local bHasNew = self.knowledgeManager:isCatalogNew(b.catalogData)

		if aHasNew ~= bHasNew then
			return aHasNew
		end

		return a.listId < b.listId
	end)

	return catalogList
end

function KnowledgeDetailCtrl:addListener()
	UICtrl.addListener(self)

	function self.view.exitBtn.luaClick()
		self:dismiss()
	end

	function self.view.listTab.luaRenderItem(button, index, data)
		self:refreshSubTypeItem(button, index, data)
	end
end

function KnowledgeDetailCtrl:refreshParentKnowledgeRedDots()
	if self.mainTypeId ~= nil then
		pg.global.refreshRedDotState(string.format(RedDotConst.RedDotPath.KNOWLEDGE_MAIN_TYPE, self.mainTypeId))
	end

	pg.global.refreshRedDotState(RedDotConst.RedDotPath.KNOWLEDGE_ENTRY)
end

function KnowledgeDetailCtrl:close()
	if not self.mainTypeMarkedRead and self.mainTypeData ~= nil then
		self.mainTypeMarkedRead = true

		self.knowledgeManager:markMainTypeKnowledgeSeen(self.mainTypeData)
		self:refreshParentKnowledgeRedDots()
	end

	UICtrl.close(self)
end

function KnowledgeDetailCtrl:onHide()
	self:refreshParentKnowledgeRedDots()
	UICtrl.onHide(self)
end

function KnowledgeDetailCtrl:onDestroy()
	self:refreshParentKnowledgeRedDots()

	self.detailRefreshVersion = self.detailRefreshVersion + 1
	self.currentDirectoryData = nil
	self.currentKnowledgeItemData = nil
	self.collectionDetailRefs = nil
	self.subTypeListMap = nil
	self.directoryButtonMap = nil
	self.targetKnowledgeId = nil
	self.targetSubTypeId = nil
	self.targetListId = nil
	self.targetPageIndex = nil
	self.pendingTargetDirectoryClick = nil
	self.pendingTargetPageIndex = nil

	self.knowledgeManager:releaseUIData(self)
	UICtrl.onDestroy(self)
end

function KnowledgeDetailCtrl:refreshSubTypeItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local list = objectReference:GetRefValue("list")

	self.subTypeListMap[data.subTypeId] = list

	function list.luaRenderItem(sub_button, sub_index, sub_data)
		if sub_data.tIndex == SUB_TYPE_TITLE_T_INDEX then
			self:refreshSubTypeTitle(sub_button, sub_index, sub_data)
		elseif sub_data.tIndex == DIRECTORY_T_INDEX then
			self:refreshDirectory(sub_button, sub_index, sub_data)
		end
	end

	local subTypeData = data.subTypeData
	local subTypeId = data.subTypeId
	local subTypeItemList = self:buildSubTypeItemList(subTypeId, subTypeData)

	list:SetList(subTypeItemList)

	if self.pendingTargetDirectoryClick and subTypeId == self.targetSubTypeId then
		for itemIndex, itemData in ipairs(subTypeItemList) do
			if itemData.tIndex == DIRECTORY_T_INDEX and itemData.listId == self.targetListId then
				list:GoToIndex(itemIndex - 1, true)

				break
			end
		end
	end
end

function KnowledgeDetailCtrl:buildSubTypeItemList(subTypeId, subTypeData)
	local itemList = {
		{
			tIndex = SUB_TYPE_TITLE_T_INDEX,
			subTypeId = subTypeId,
			subTypeData = subTypeData
		}
	}
	local catalogList = self:buildCatalogList(subTypeData)

	for _, catalogInfo in ipairs(catalogList) do
		table.insert(itemList, {
			tIndex = DIRECTORY_T_INDEX,
			subTypeId = subTypeId,
			subTypeData = subTypeData,
			listId = catalogInfo.listId,
			catalogData = catalogInfo.catalogData
		})
	end

	return itemList
end

function KnowledgeDetailCtrl:refreshSubTypeTitle(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txt = objectReference:GetRefValue("txt")

	ClientTextUtils.setText(txt, pg.getLocalizationText(data.subTypeData.title))

	button.luaClick = nil
end

function KnowledgeDetailCtrl:refreshDirectory(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtContent = objectReference:GetRefValue("txtContent")

	ClientTextUtils.setText(txtContent, pg.getLocalizationText(data.catalogData.title))

	self.directoryButtonMap[button] = true
	button.isSelected = self.currentDirectoryData ~= nil and self.currentDirectoryData.subTypeId == data.subTypeId and self.currentDirectoryData.listId == data.listId

	local redDotPath = string.format(RedDotConst.RedDotPath.KNOWLEDGE_DETAIL_CATALOG, self.mainTypeId, data.subTypeId, data.listId)

	pg.global.setPreViewRedDot(redDotPath, button, function()
		return self.knowledgeManager:isCatalogNew(data.catalogData) and RedDotConst.RedDotStyle.NEW or RedDotConst.RedDotStyle.NONE
	end)

	local isDefaultClick = false

	function button.luaClick()
		self:selectDirectoryButton(button, data)

		local newKnowledgeCount = self.knowledgeManager:getCatalogNewKnowledgeCount(data.catalogData)

		if not isDefaultClick and newKnowledgeCount == 1 then
			self.knowledgeManager:markCatalogKnowledgeSeen(data.catalogData)
			self:refreshCatalogKnowledgeRedDots(data)
		end

		local targetPageIndex = self.pendingTargetPageIndex

		self.pendingTargetPageIndex = nil

		self:refreshRightPageDetails(data, isDefaultClick and newKnowledgeCount == 1, targetPageIndex)

		local subTypeList = self.subTypeListMap[data.subTypeId]
		local subTypeItemList = self:buildSubTypeItemList(data.subTypeId, data.subTypeData)

		subTypeList:SetList(subTypeItemList)

		for itemIndex, itemData in ipairs(subTypeItemList) do
			if itemData.tIndex == DIRECTORY_T_INDEX and itemData.listId == data.listId then
				self:restoreDirectorySelection(subTypeList, itemIndex - 1, data, self.detailRefreshVersion)

				break
			end
		end
	end

	local isTargetDirectory = self.pendingTargetDirectoryClick and data.subTypeId == self.targetSubTypeId and data.listId == self.targetListId

	if isTargetDirectory then
		self.pendingTargetDirectoryClick = false
		self.pendingTargetPageIndex = self.targetPageIndex

		self:startFrameTimer(function()
			button:OnClickSimulate()
		end, 1)
	elseif self.pendingDefaultDirectoryClick then
		self.pendingDefaultDirectoryClick = false

		self:startFrameTimer(function()
			isDefaultClick = true

			button:OnClickSimulate()

			isDefaultClick = false
		end, 1)
	end
end

function KnowledgeDetailCtrl:selectDirectoryButton(selectedButton, directoryData)
	self.currentDirectoryData = directoryData

	for button in pairs(self.directoryButtonMap) do
		button.isSelected = button == selectedButton
	end
end

function KnowledgeDetailCtrl:restoreDirectorySelection(subTypeList, itemIndex, directoryData, refreshVersion, retryCount)
	subTypeList:GoToIndex(itemIndex, true)
	self:startFrameTimer(function()
		if refreshVersion ~= self.detailRefreshVersion then
			return
		end

		local success, button = subTypeList:TryGetChildAt(itemIndex)

		if success then
			self:selectDirectoryButton(button, directoryData)

			return
		end

		retryCount = tonumber(retryCount) or 0

		if retryCount < 1 then
			self:restoreDirectorySelection(subTypeList, itemIndex, directoryData, refreshVersion, retryCount + 1)
		elseif LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("Cannot restore knowledge directory selection, subTypeId: %s, listId: %s, index: %s", tostring(directoryData.subTypeId), tostring(directoryData.listId), tostring(itemIndex))
		end
	end, 1)
end

function KnowledgeDetailCtrl:refreshCatalogRedDot(directoryData)
	pg.global.refreshRedDotState(string.format(RedDotConst.RedDotPath.KNOWLEDGE_DETAIL_CATALOG, self.mainTypeId, directoryData.subTypeId, directoryData.listId))
end

function KnowledgeDetailCtrl:refreshCatalogKnowledgeRedDots(directoryData)
	for _, knowledgeItemData in ipairs(directoryData.catalogData.dataList) do
		pg.global.refreshRedDotState(self:getKnowledgeItemRedDotPath(knowledgeItemData.knowledgeId))
	end

	self:refreshCatalogRedDot(directoryData)
end

function KnowledgeDetailCtrl:markPageKnowledgeSeen(knowledgeItemData)
	self.knowledgeManager:markKnowledgeItemSeen(knowledgeItemData)
	pg.global.refreshRedDotState(self:getKnowledgeItemRedDotPath(knowledgeItemData.knowledgeId))
	self:refreshCatalogRedDot(self.currentDirectoryData)
end

function KnowledgeDetailCtrl:refreshRightPageDetails(directoryData, suppressDefaultPageRead, pageIndex)
	if directoryData == nil or directoryData.catalogData == nil then
		self:resetCurrentDetailData()

		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("Knowledge directory data is invalid, mainTypeId: %s, listId: %s", tostring(self.mainTypeId), tostring(directoryData and directoryData.listId))
		end

		return
	end

	local dataList = directoryData.catalogData.dataList

	if dataList == nil or dataList[1] == nil then
		self:resetCurrentDetailData()

		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("Knowledge catalog has no unlocked item, mainTypeId: %s, listId: %s", tostring(self.mainTypeId), tostring(directoryData.listId))
		end

		return
	end

	pageIndex = tonumber(pageIndex) or 1

	local knowledgeItemData = dataList[pageIndex]

	if knowledgeItemData == nil or knowledgeItemData.data == nil then
		self:resetCurrentDetailData()

		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("Knowledge item data is missing, mainTypeId: %s, listId: %s, knowledgeId: %s", tostring(self.mainTypeId), tostring(directoryData.listId), tostring(knowledgeItemData and knowledgeItemData.knowledgeId))
		end

		return
	end

	if self:isCurrentKnowledgeItem(knowledgeItemData) then
		return
	end

	self.detailRefreshVersion = self.detailRefreshVersion + 1

	local refreshVersion = self.detailRefreshVersion
	local uiIndex = DATA_2_UI_INDEX[self.mainTypeId]

	if uiIndex == nil then
		self:resetCurrentDetailData(false)

		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("Knowledge detail UI index is missing, mainTypeId: %s", tostring(self.mainTypeId))
		end

		return
	end

	self.currentDirectoryData = directoryData
	self.currentKnowledgeItemData = knowledgeItemData

	self.view.root:TryChangePage("Type", uiIndex)

	if self.mainTypeId == 1 then
		self:refreshBooksPages(directoryData.catalogData, refreshVersion, suppressDefaultPageRead, pageIndex)
	elseif self.mainTypeId == 2 then
		self:refreshDrawingsPages(directoryData.catalogData, refreshVersion, suppressDefaultPageRead, pageIndex)
	elseif self.mainTypeId == 3 then
		self:refreshCollectionsPages(directoryData.catalogData, refreshVersion, suppressDefaultPageRead, pageIndex)
	elseif LoggerManager.checkLogger(LoggerConst.WARN) then
		logger:warn("Knowledge detail page is not implemented, mainTypeId: %s", tostring(self.mainTypeId))
	end
end

function KnowledgeDetailCtrl:isCurrentKnowledgeItem(knowledgeItemData)
	local currentKnowledgeItemData = self.currentKnowledgeItemData

	return currentKnowledgeItemData ~= nil and knowledgeItemData ~= nil and currentKnowledgeItemData.knowledgeId == knowledgeItemData.knowledgeId and currentKnowledgeItemData.pageId == knowledgeItemData.pageId
end

function KnowledgeDetailCtrl:resetCurrentDetailData(invalidateCallback)
	if invalidateCallback ~= false then
		self.detailRefreshVersion = self.detailRefreshVersion + 1
	end

	self.currentDirectoryData = nil
	self.currentKnowledgeItemData = nil

	local refs = self.collectionDetailRefs

	if refs then
		self:clearCollectionsItemDetails(refs.icon, refs.name, refs.scrollRect)
		refs.listPage:SetList({})
	end
end

function KnowledgeDetailCtrl:refreshCollectionsPages(catalogData, refreshVersion, suppressDefaultPageRead, pageIndex)
	self.view.collectionNode:SetUrlWithCallback("$UI_Node_Knowledge_Details_Collection.prefab", function(content)
		if refreshVersion ~= self.detailRefreshVersion then
			return
		end

		local objectReference = content:GetComponent("ObjectReference")
		local icon = objectReference:GetRefValue("icon")
		local name = objectReference:GetRefValue("name")
		local scrollRect = objectReference:GetRefValue("scrollRect")
		local listPage = objectReference:GetRefValue("pageList")
		local btnView = objectReference:GetRefValue("btnView")

		scrollRect:SetRightStickScrollConsoleBar("KNOWLEDGE_UP_DOWN_SCROLL", 1)

		self.collectionDetailRefs = {
			icon = icon,
			name = name,
			scrollRect = scrollRect,
			listPage = listPage,
			btnView = btnView
		}

		function listPage.luaRenderItem(button, index, data)
			self:refreshCollectionsPageItem(button, index, data, listPage, icon, name, scrollRect, btnView)
		end

		listPage.luaClick = nil

		function btnView.luaClick()
			LuaMsgUtils.useItemById(self.currentKnowledgeItemData.data.itemId, 1, {})
		end

		local knowledgeItemList = catalogData.dataList

		listPage:SetList(knowledgeItemList)

		pageIndex = tonumber(pageIndex) or 1

		local knowledgeItemData = knowledgeItemList[pageIndex]

		if knowledgeItemData ~= nil then
			if not suppressDefaultPageRead then
				self:markPageKnowledgeSeen(knowledgeItemData)
			end

			self:refreshCollectionsItemDetails(icon, name, scrollRect, btnView, knowledgeItemData)
			self:simulatePageClick(listPage, pageIndex, refreshVersion)
		end
	end)
end

function KnowledgeDetailCtrl:refreshCollectionsPageItem(button, index, data, listPage, icon, name, scrollRect, btnView)
	local objectReference = button:GetComponent("ObjectReference")
	local txtPage = objectReference:GetRefValue("txtPage")

	ClientTextUtils.setText(txtPage, tostring(index + 1))

	local redDotPath = self:getKnowledgeItemRedDotPath(data.knowledgeId)

	pg.global.setPreViewRedDot(redDotPath, button, function()
		return self.knowledgeManager:isKnowledgeItemNew(data) and RedDotConst.RedDotStyle.NEW or RedDotConst.RedDotStyle.NONE
	end)

	function button.luaClick()
		self:selectPageButton(listPage, button)
		self:markPageKnowledgeSeen(data)

		if not self:isCurrentKnowledgeItem(data) then
			self:refreshCollectionsItemDetails(icon, name, scrollRect, btnView, data)
		end
	end
end

function KnowledgeDetailCtrl:getKnowledgeItemRedDotPath(knowledgeId)
	return string.format(RedDotConst.RedDotPath.KNOWLEDGE_DETAIL_ITEM, self.mainTypeId, self.currentDirectoryData.subTypeId, self.currentDirectoryData.listId, knowledgeId)
end

function KnowledgeDetailCtrl:refreshCollectionsItemDetails(icon, name, scrollRect, btnView, knowledgeItemData)
	self:clearCollectionsItemDetails(icon, name, scrollRect)

	local data = knowledgeItemData.data
	local content = scrollRect.content
	local descText = content:GetComponent("USDFText")

	if descText == nil then
		descText = content:GetComponent("UBaseText")
	end

	self.currentKnowledgeItemData = knowledgeItemData
	icon.url = data.icon

	ClientTextUtils.setText(name, pg.getLocalizationText(data.title))
	ClientTextUtils.setText(descText, pg.getLocalizationText(data.desc))
	LuaUIUtils.setUIViewVisible(btnView, data.canView == true)
	scrollRect:GoToPos(Vector2.zero, true)
end

function KnowledgeDetailCtrl:clearCollectionsItemDetails(icon, name, scrollRect)
	icon.url = nil

	ClientTextUtils.setText(name, "")

	local descText = scrollRect.content:GetComponent("USDFText")

	if descText == nil then
		descText = scrollRect.content:GetComponent("UBaseText")
	end

	ClientTextUtils.setText(descText, "")
end

function KnowledgeDetailCtrl:refreshBooksPages(catalogData, refreshVersion, suppressDefaultPageRead, pageIndex)
	self.view.bookNode:SetUrlWithCallback("$UI_Node_Knowledge_Details_Book.prefab", function(content)
		if refreshVersion ~= self.detailRefreshVersion then
			return
		end

		local objectReference = content:GetComponent("ObjectReference")
		local title = objectReference:GetRefValue("title")
		local listPage = objectReference:GetRefValue("listPage")
		local listText = objectReference:GetRefValue("listText")
		local btnPrev = objectReference:GetRefValue("btnPrev")
		local btnNext = objectReference:GetRefValue("btnNext")

		listText:SetRightStickScrollConsoleBar("KNOWLEDGE_UP_DOWN_SCROLL", 1)

		local bookRefs = {
			currentPage = 1,
			title = title,
			listPage = listPage,
			listText = listText,
			btnPrev = btnPrev,
			btnNext = btnNext,
			knowledgeItemList = catalogData.dataList
		}

		bookRefs.prevRedDotPath = self:getBookNavigationRedDotPath(RedDotConst.RedDotPath.KNOWLEDGE_DETAIL_BOOK_PREV)
		bookRefs.nextRedDotPath = self:getBookNavigationRedDotPath(RedDotConst.RedDotPath.KNOWLEDGE_DETAIL_BOOK_NEXT)

		pg.global.setPreViewRedDot(bookRefs.prevRedDotPath, btnPrev, function()
			return self:hasNewBookPageInRange(bookRefs, 1, bookRefs.currentPage - 1) and RedDotConst.RedDotStyle.NEW or RedDotConst.RedDotStyle.NONE
		end)
		pg.global.setPreViewRedDot(bookRefs.nextRedDotPath, btnNext, function()
			return self:hasNewBookPageInRange(bookRefs, bookRefs.currentPage + 1, #bookRefs.knowledgeItemList) and RedDotConst.RedDotStyle.NEW or RedDotConst.RedDotStyle.NONE
		end)

		function listText.luaRenderItem(button, index, data)
			self:refreshBookTextItem(button, index, data)
		end

		function listPage.luaClick(button, data)
			self:selectPageButton(listPage, button)
			self:markPageKnowledgeSeen(data)

			if not self:isCurrentKnowledgeItem(data) then
				local page = listPage:GetChildIndex(button) + 1

				self:refreshBookItemDetails(bookRefs, catalogData.dataList, page)
			end
		end

		listPage:SetList(catalogData.dataList)

		pageIndex = tonumber(pageIndex) or 1

		local knowledgeItemData = catalogData.dataList[pageIndex]

		if knowledgeItemData ~= nil then
			if not suppressDefaultPageRead then
				self:markPageKnowledgeSeen(knowledgeItemData)
			end

			self:refreshBookItemDetails(bookRefs, catalogData.dataList, pageIndex)
			self:simulatePageClick(listPage, pageIndex, refreshVersion)
		end
	end)
end

function KnowledgeDetailCtrl:refreshBookTextItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtContent = objectReference:GetRefValue("txtContent")

	ClientTextUtils.setText(txtContent, pg.getLocalizationText(data.text))
end

function KnowledgeDetailCtrl:refreshBookItemDetails(bookRefs, knowledgeItemList, page)
	local knowledgeItemData = knowledgeItemList[page]

	self.currentKnowledgeItemData = knowledgeItemData

	ClientTextUtils.setText(bookRefs.title, pg.getLocalizationText(knowledgeItemData.data.title))
	bookRefs.listText:SetList({
		{
			text = knowledgeItemData.data.desc
		}
	})

	bookRefs.btnPrev.interactable = page > 1
	bookRefs.btnNext.interactable = page < #knowledgeItemList
	bookRefs.currentPage = page

	pg.global.refreshRedDotState(bookRefs.prevRedDotPath)
	pg.global.refreshRedDotState(bookRefs.nextRedDotPath)

	function bookRefs.btnPrev.luaClick()
		local prevPage = page - 1
		local knowledgeItemData = knowledgeItemList[prevPage]

		self:markPageKnowledgeSeen(knowledgeItemData)
		self:refreshBookItemDetails(bookRefs, knowledgeItemList, prevPage)
		self:simulatePageClick(bookRefs.listPage, prevPage, self.detailRefreshVersion)
	end

	function bookRefs.btnNext.luaClick()
		local nextPage = page + 1

		if nextPage > #knowledgeItemList then
			nextPage = #knowledgeItemList
		end

		local knowledgeItemData = knowledgeItemList[nextPage]

		self:markPageKnowledgeSeen(knowledgeItemData)
		self:refreshBookItemDetails(bookRefs, knowledgeItemList, nextPage)
		self:simulatePageClick(bookRefs.listPage, nextPage, self.detailRefreshVersion)
	end
end

function KnowledgeDetailCtrl:hasNewBookPageInRange(bookRefs, firstPage, lastPage)
	if lastPage < firstPage then
		return false
	end

	for page = firstPage, lastPage do
		if self.knowledgeManager:isKnowledgeItemNew(bookRefs.knowledgeItemList[page]) then
			return true
		end
	end

	return false
end

function KnowledgeDetailCtrl:getBookNavigationRedDotPath(pathTemplate)
	return string.format(pathTemplate, self.mainTypeId, self.currentDirectoryData.subTypeId, self.currentDirectoryData.listId)
end

function KnowledgeDetailCtrl:refreshDrawingsPages(catalogData, refreshVersion, suppressDefaultPageRead, pageIndex)
	self.view.paintingNode:SetUrlWithCallback("$UI_Node_Knowledge_Details_Painting.prefab", function(content)
		if refreshVersion ~= self.detailRefreshVersion then
			return
		end

		local objectReference = content:GetComponent("ObjectReference")
		local photo = objectReference:GetRefValue("photo")
		local title = objectReference:GetRefValue("title")
		local listPage = objectReference:GetRefValue("listPage")
		local scrollRect = objectReference:GetRefValue("scrollRect")
		local photoBtn = objectReference:GetRefValue("photoBtn")

		function listPage.luaRenderItem(button, index, data)
			self:refreshDrawingsPageItem(button, index, data, listPage, photo, title, scrollRect)
		end

		listPage.luaClick = nil

		function photoBtn.luaClick()
			pg.global.ui:open(UIConst.UI_ID_KNOWLEDGE_POPUP, {
				knowledgeItemData = self.currentKnowledgeItemData
			})
		end

		photoBtn:SetHotkeyConsoleBar("HOMELAND_COMPOSE_VIEW_DETAIL", 1)
		listPage:SetList(catalogData.dataList)

		pageIndex = tonumber(pageIndex) or 1

		local knowledgeItemData = catalogData.dataList[pageIndex]

		if knowledgeItemData ~= nil then
			if not suppressDefaultPageRead then
				self:markPageKnowledgeSeen(knowledgeItemData)
			end

			self:refreshDrawingsItemDetails(photo, title, scrollRect, knowledgeItemData)
			self:simulatePageClick(listPage, pageIndex, refreshVersion)
		end
	end)
end

function KnowledgeDetailCtrl:refreshDrawingsPageItem(button, index, data, listPage, photo, title, scrollRect)
	local objectReference = button:GetComponent("ObjectReference")
	local txtPage = objectReference:GetRefValue("txtPage")

	ClientTextUtils.setText(txtPage, tostring(index + 1))

	local redDotPath = self:getKnowledgeItemRedDotPath(data.knowledgeId)

	pg.global.setPreViewRedDot(redDotPath, button, function()
		return self.knowledgeManager:isKnowledgeItemNew(data) and RedDotConst.RedDotStyle.NEW or RedDotConst.RedDotStyle.NONE
	end)

	function button.luaClick()
		self:selectPageButton(listPage, button)
		self:markPageKnowledgeSeen(data)

		if not self:isCurrentKnowledgeItem(data) then
			self:refreshDrawingsItemDetails(photo, title, scrollRect, data)
		end
	end
end

function KnowledgeDetailCtrl:refreshDrawingsItemDetails(photo, title, scrollRect, knowledgeItemData)
	self.currentKnowledgeItemData = knowledgeItemData
	photo.url = knowledgeItemData.data.icon

	ClientTextUtils.setText(title, pg.getLocalizationText(knowledgeItemData.data.title))

	local descText = scrollRect.content:GetComponent("USDFText")

	if descText == nil then
		descText = scrollRect.content:GetComponent("UBaseText")
	end

	ClientTextUtils.setText(descText, pg.getLocalizationText(knowledgeItemData.data.desc))
	scrollRect:GoToPos(Vector2.zero, true)
end

function KnowledgeDetailCtrl:simulatePageClick(listPage, page, refreshVersion, retryCount)
	page = tonumber(page) or 1

	local pageIndex = page - 1
	local knowledgeItemData = listPage:GetData(pageIndex)

	if knowledgeItemData == nil then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("Cannot simulate knowledge page click, invalid page: %s", tostring(page))
		end

		return
	end

	listPage:GoToIndex(pageIndex, true)
	self:startFrameTimer(function()
		if refreshVersion ~= nil and refreshVersion ~= self.detailRefreshVersion then
			return
		end

		local success, button = listPage:TryGetChildAt(pageIndex)

		if success then
			self:selectPageButton(listPage, button)

			return
		end

		retryCount = tonumber(retryCount) or 0

		if retryCount < 1 then
			self:simulatePageClick(listPage, page, refreshVersion, retryCount + 1)
		elseif LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("Cannot sync knowledge page selection, page item is not instantiated, page: %s", tostring(page))
		end
	end, 1)
end

function KnowledgeDetailCtrl:selectPageButton(listPage, selectedButton)
	local index = 0

	while listPage:GetData(index) ~= nil do
		local success, button = listPage:TryGetChildAt(index)

		if success then
			button.isSelected = button == selectedButton
		end

		index = index + 1
	end
end

return KnowledgeDetailCtrl
