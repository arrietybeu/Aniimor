-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomeBookFurnitureSet\\HomeBookFurnitureSetCtrl.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local MessageName = require("Const.MessageName")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local HomeBookRedDotUtils = require("Utils.HomeBookRedDotUtils")
local RedDotConst = require("Const.RedDotConst")
local UIConst = require("Const.UIConst")
local TimerManager = require("Core.Timer.TimerManager")
local HomeBookFurnitureSetCtrl = Class.LightClass("HomeBookFurnitureSetCtrl", UICtrl)

HomeBookFurnitureSetCtrl.messages = {
	[MessageName.ON_HOME_BOOK_DATA_CHANGED] = {
		"onHomeBookDataChanged",
		true
	},
	[MessageName.ON_HOME_BOOK_ITEM_COUNT_CHANGED] = {
		"onHomeBookItemCountChanged",
		true
	}
}

local QUALITY_BACKGROUND = {
	"$UI_Img_HomeCollection_QualityBg_White.png",
	"$UI_Img_HomeCollection_QualityBg_Green.png",
	"$UI_Img_HomeCollection_QualityBg_Blue.png",
	"$UI_Img_HomeCollection_QualityBg_Purple.png",
	"$UI_Img_HomeCollection_QualityBg_Yellow.png"
}

local function setImage(image, url)
	image.url = url
end

local function setNewRedDot(button, path, isNew)
	pg.global.setRedDot(path, button, isNew, RedDotConst.RedDotStyle.NEW)
end

local function setRewardRedDot(button, path, isClaimable)
	pg.global.setRedDot(path, button, isClaimable, RedDotConst.RedDotStyle.REWARD)
end

local function selectTabItem(list, tabs, selectedId)
	for index, tab in ipairs(tabs) do
		if tab.id == selectedId then
			list:SelectItem(index - 1, false)

			return
		end
	end

	list:DeselectAll(false)
end

local function refreshTabItem(list, tabs, tabId)
	for index, tab in ipairs(tabs) do
		if tab.id == tabId then
			list:RefreshElement(index - 1)

			return
		end
	end
end

local function refreshChangedTabItems(list, tabs, updatedTabs)
	local updatedTabById = {}

	for _, tab in ipairs(updatedTabs) do
		updatedTabById[tab.id] = tab
	end

	for index, tab in ipairs(tabs) do
		local updatedTab = updatedTabById[tab.id]

		if updatedTab and updatedTab.isNew ~= tab.isNew then
			for key, value in pairs(updatedTab) do
				tab[key] = value
			end

			list:RefreshElement(index - 1)
		end
	end
end

function HomeBookFurnitureSetCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.TextTab = info.isTextTab or false

	self.view.transform:GetComponent("UComponent"):TryChangePage("Tab", self.TextTab and 1 or 0)
end

function HomeBookFurnitureSetCtrl:addListener()
	function self.view.btnBackUButton.luaClick()
		self:markCurrentSecondRead()
		self:closePanel()
	end

	function self.view.listTabUList.luaRenderItem(button, index, data)
		self:renderSecondTab(button, data)
	end

	function self.view.listTabUList.luaClick(button, data)
		self:selectSecondTab(data.id)
	end

	function self.view.leftListTabUList.luaRenderItem(button, index, data)
		self:renderThirdTab(button, data)
	end

	function self.view.leftListTabTextUList.luaRenderItem(button, index, data)
		self:renderThirdTab(button, data)
	end

	function self.view.leftListTabUList.luaClick(button, data)
		self:selectThirdTab(data.id)
	end

	function self.view.leftListTabTextUList.luaClick(button, data)
		self:selectThirdTab(data.id)
	end

	function self.view.listSuitUList.luaRenderItem(button, index, data)
		self:renderComposeItem(button, data)
	end

	function self.view.listSuitUList.luaClick(button, data)
		self:openComposeDetail(data)
	end

	function self.view.listCropsUList.luaRenderItem(button, index, data)
		self:renderNormalItem(button, data)
	end

	function self.view.listCropsUList.luaClick(button, data)
		self:openNormalDetail(data)
	end

	function self.view.listRewardUList.luaRenderItem(button, index, data)
		self:renderProgressReward(button, data)
	end
end

function HomeBookFurnitureSetCtrl:onOpen(info)
	self:cancelHomeBookVisibleFrameTimer()
	UICtrl.onOpen(self, info)
	self.model:setEntranceInfo(info)

	self.selectedSecondType = nil
	self.selectedThirdType = nil
	self.markedSecondType = nil

	ClientTextUtils.setText(self.view.tMPUSDFText, self.model:getTitle())
	ClientTextUtils.setText(self.view.txtPrrogressUSDFText, pg.getGameString("HOME_BOOK_COLLECTION_PROGRESS"))
	self:refreshSecondTabs()
	self:refreshCategoryProgress()

	self.keepHomeBookVisible = true
	self.homeBookVisibleFrameId = self:startFrameTimer(function()
		self.homeBookVisibleFrameId = nil

		self:releaseHomeBookVisible()
	end, 5)
end

function HomeBookFurnitureSetCtrl:cancelHomeBookVisibleFrameTimer()
	if not self.homeBookVisibleFrameId then
		return
	end

	TimerManager.delFrameCb(self.homeBookVisibleFrameId)

	self.homeBookVisibleFrameId = nil
end

function HomeBookFurnitureSetCtrl:onVisibleChange(visible)
	if not visible then
		return
	end

	self:refreshVisibleData()
end

function HomeBookFurnitureSetCtrl:close()
	self:releaseHomeBookVisible()
	UICtrl.close(self)
end

function HomeBookFurnitureSetCtrl:releaseHomeBookVisible()
	self:cancelHomeBookVisibleFrameTimer()

	if not self.keepHomeBookVisible then
		return
	end

	self.keepHomeBookVisible = false

	self.adapter:refreshUIVisible(self.uid)
end

function HomeBookFurnitureSetCtrl:onDestroy()
	self:releaseHomeBookVisible()
	self:markCurrentSecondRead()
	UICtrl.onDestroy(self)
end

function HomeBookFurnitureSetCtrl:refreshSecondTabs()
	self.secondTabs = self.model:getSecondTabs()

	self.view.listTabUList:SetList(self.secondTabs)

	if self.secondTabs[1] then
		self:selectSecondTab(self.secondTabs[1].id)
	end
end

function HomeBookFurnitureSetCtrl:renderSecondTab(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local name1 = objectReference:GetRefValue("name1")
	local name2 = objectReference:GetRefValue("name2")

	ClientTextUtils.setText(name1, data.name)
	ClientTextUtils.setText(name2, data.name)

	button.isSelected = data.id == self.selectedSecondType

	setNewRedDot(button, data.newRedDotPath, data.isNew)
end

function HomeBookFurnitureSetCtrl:markCurrentSecondRead()
	local secondType = self.selectedSecondType

	if not secondType or self.markedSecondType == secondType then
		return
	end

	HomeBookRedDotUtils.markSecondRead(secondType)

	self.markedSecondType = secondType

	for _, tab in ipairs(self.secondTabs or EMPTY_TABLE) do
		if tab.id == secondType then
			tab.isNew = false

			break
		end
	end
end

function HomeBookFurnitureSetCtrl:selectSecondTab(secondType)
	local previousSecondType = self.selectedSecondType

	if previousSecondType and previousSecondType ~= secondType then
		self:markCurrentSecondRead()
	end

	self.selectedSecondType = secondType
	self.markedSecondType = nil

	if previousSecondType and previousSecondType ~= secondType then
		refreshTabItem(self.view.listTabUList, self.secondTabs, previousSecondType)
	end

	selectTabItem(self.view.listTabUList, self.secondTabs, secondType)

	self.thirdTabs = self.model:getThirdTabs(secondType)
	self.selectedThirdType = nil

	if self.TextTab then
		self.view.leftListTabTextUList:SetList(self.thirdTabs)
	else
		self.view.leftListTabUList:SetList(self.thirdTabs)
	end

	if self.thirdTabs[1] then
		self:selectThirdTab(self.thirdTabs[1].id)
	else
		self:clearContentLists()
	end
end

function HomeBookFurnitureSetCtrl:renderThirdTab(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")

	if self.TextTab then
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

		ClientTextUtils.setText(txtNameUSDFText, data.name)
	else
		local textUBaseText = objectReference:GetRefValue("textUBaseText")

		ClientTextUtils.setText(textUBaseText, data.name)

		iconUImage.url = data.icon or ""
	end

	button.isSelected = data.id == self.selectedThirdType

	setNewRedDot(button, data.newRedDotPath, data.isNew)
end

function HomeBookFurnitureSetCtrl:selectThirdTab(thirdType)
	if thirdType == self.selectedThirdType then
		return
	end

	self.selectedThirdType = thirdType

	if self.TextTab then
		selectTabItem(self.view.leftListTabTextUList, self.thirdTabs, thirdType)
	else
		selectTabItem(self.view.leftListTabUList, self.thirdTabs, thirdType)
	end

	self:refreshContentLists(true)
end

function HomeBookFurnitureSetCtrl:clearContentLists()
	self.view.listSuitUList:SetList({})
	self.view.listCropsUList:SetList({})
	self.view.listSuitUList.gameObject:SetActiveEx(false)
	self.view.listCropsUList.gameObject:SetActiveEx(false)
end

function HomeBookFurnitureSetCtrl:refreshContentLists(resetPosition)
	local composeList, normalList = self.model:getContentLists(self.selectedThirdType)

	self.composeList = composeList
	self.normalList = normalList

	local showCompose = #composeList > 0
	local suitList = {}
	local cropsList = {}

	if showCompose then
		suitList = composeList
	else
		cropsList = normalList
	end

	if showCompose then
		self.view.listCropsUList.gameObject:SetActiveEx(false)
		self.view.listCropsUList:SetList(cropsList)
		self.view.listSuitUList:SetList(suitList)
		self.view.listSuitUList.gameObject:SetActiveEx(true)

		if resetPosition then
			self.view.listSuitUList:GoToIndex(0, true)
		end
	else
		self.view.listSuitUList.gameObject:SetActiveEx(false)
		self.view.listSuitUList:SetList(suitList)
		self.view.listCropsUList:SetList(cropsList)
		self.view.listCropsUList.gameObject:SetActiveEx(true)

		if resetPosition and #cropsList > 0 then
			self.view.listCropsUList:GoToIndex(0, true)
		end
	end
end

function HomeBookFurnitureSetCtrl:renderComposeItem(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtNotCollectedUSDFText = objectReference:GetRefValue("txtNotCollectedUSDFText")
	local txtNumUSDFText = objectReference:GetRefValue("txtNumUSDFText")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local iconUImage = objectReference:GetRefValue("iconUImage")

	ClientTextUtils.setText(txtNotCollectedUSDFText, pg.getGameString("HOME_BOOK_NOT_COLLECTED"))
	ClientTextUtils.setText(txtNameUSDFText, data.name)
	ClientTextUtils.setText(txtNumUSDFText, data.progressText)
	txtNotCollectedUSDFText.gameObject:SetActiveEx(data.collectedCount == 0)
	setImage(iconUImage, data.icon)

	local collectPage = 1

	if data.isCollected then
		collectPage = 0
	end

	button:TryChangePage("NotCollected", collectPage)
	setNewRedDot(button, data.newRedDotPath, data.isNew)
end

function HomeBookFurnitureSetCtrl:renderNormalItem(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local imgBgQualityUImage = objectReference:GetRefValue("imgBgQualityUImage")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local addUWidget = objectReference:GetRefValue("addUWidget")
	local txtAddUSDFText = objectReference:GetRefValue("txtAddUSDFText")

	ClientTextUtils.setText(txtNameUSDFText, data.name)

	local showAddGrade = data.addGrade > 0

	if showAddGrade then
		ClientTextUtils.setText(txtAddUSDFText, "+" .. data.addGrade)
	end

	addUWidget:SetActive(showAddGrade)
	setImage(iconUImage, data.icon or "")
	setImage(imgBgQualityUImage, QUALITY_BACKGROUND[data.quality] or QUALITY_BACKGROUND[1])

	local collectPage = 1

	if data.isCollected then
		collectPage = 0
	end

	button:TryChangePage("NotCollected", collectPage)
	setNewRedDot(button, data.newRedDotPath, data.isNew)
end

function HomeBookFurnitureSetCtrl:openComposeDetail(data)
	self:markCurrentSecondRead()
	pg.global.ui:open(UIConst.UI_ID_HOME_BOOK_FURNITURE_DETAIL, {
		entryId = data.id
	})
end

function HomeBookFurnitureSetCtrl:openNormalDetail(data)
	self:markCurrentSecondRead()

	if data.sourceType == "furniture" then
		pg.global.ui:open(UIConst.UI_ID_HOME_BOOK_FURNITURE_DETAIL, {
			entryId = data.id
		})
	elseif data.sourceType == "item" then
		pg.global.ui:open(UIConst.UI_ID_HOME_BOOK_CROP_DETAIL, {
			entryId = data.id
		})
	end
end

function HomeBookFurnitureSetCtrl:refreshCategoryProgress()
	local progress = self.model:getCategoryProgress()

	ClientTextUtils.setText(self.view.txtNumNowUSDFText, progress.current)
	ClientTextUtils.setText(self.view.txtNumTotalUSDFText, string.format("/%d", progress.total))
	self.view.listRewardUList:SetList(progress.rewards)
end

function HomeBookFurnitureSetCtrl:renderProgressReward(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local rewardItem = objectReference:GetRefValue("rewardItemUButton")
	local numText = objectReference:GetRefValue("numUSDFText")
	local progress = objectReference:GetRefValue("progress2UProgress")

	progress.minValue = 0
	progress.maxValue = 1

	if data.numMax <= data.numMin then
		progress.value = 1
	else
		local current = pg.me:getHomeHandbookCategoryCount(self.model.categoryId)

		progress.value = math.max(0, math.min(1, (current - data.numMin) / (data.numMax - data.numMin)))
	end

	ClientTextUtils.setText(numText, data.numMax)

	local rewardData = LuaUIUtils.getRewardItemByDropId(data.rewardId)[1]

	rewardData.state = 0

	if data.isReceived then
		rewardData.state = 1
	elseif data.isClaimable then
		rewardData.state = 2
	end

	rewardData.extraFunc = nil

	if data.isClaimable then
		function rewardData.extraFunc()
			self:receiveCategoryReward()
		end
	end

	LuaUIUtils.renderRewardItem(rewardItem, rewardData)
	setRewardRedDot(button, data.redDotPath, data.isClaimable)
end

function HomeBookFurnitureSetCtrl:receiveCategoryReward()
	pg.me:reqReceiveCategoryProgressReward(self.model.categoryId, function()
		self:refreshCategoryProgress()
		HomeBookRedDotUtils.refreshTree(self.model.categoryId)
	end)
end

function HomeBookFurnitureSetCtrl:refreshVisibleData()
	self.secondTabs = self.model:getSecondTabs()

	self.view.listTabUList:SetList(self.secondTabs)
	selectTabItem(self.view.listTabUList, self.secondTabs, self.selectedSecondType)

	if self.selectedSecondType then
		self.thirdTabs = self.model:getThirdTabs(self.selectedSecondType)

		if self.TextTab then
			self.view.leftListTabTextUList:SetList(self.thirdTabs)
			selectTabItem(self.view.leftListTabTextUList, self.thirdTabs, self.selectedThirdType)
		else
			self.view.leftListTabUList:SetList(self.thirdTabs)
			selectTabItem(self.view.leftListTabUList, self.thirdTabs, self.selectedThirdType)
		end
	end

	if self.selectedThirdType then
		self:refreshContentLists()
	end
end

function HomeBookFurnitureSetCtrl:refreshTabRedDots()
	local secondTabs = self.secondTabs or EMPTY_TABLE
	local updatedSecondTabs = self.model:getSecondTabs()

	refreshChangedTabItems(self.view.listTabUList, secondTabs, updatedSecondTabs)

	if not self.selectedSecondType then
		return
	end

	local thirdTabs = self.thirdTabs or EMPTY_TABLE
	local updatedThirdTabs = self.model:getThirdTabs(self.selectedSecondType)
	local thirdTabList = self.TextTab and self.view.leftListTabTextUList or self.view.leftListTabUList

	refreshChangedTabItems(thirdTabList, thirdTabs, updatedThirdTabs)
end

function HomeBookFurnitureSetCtrl:onHomeBookDataChanged(info)
	local itemId = info and info.itemId

	if itemId then
		self.markedSecondType = nil
	end

	self:refreshTabRedDots()

	if itemId and self.model:doesEntryAffectThirdType(itemId, self.selectedThirdType) then
		self:refreshContentLists()
	end

	self:refreshCategoryProgress()
end

function HomeBookFurnitureSetCtrl:onHomeBookItemCountChanged(info)
	if not self.selectedThirdType or not self.composeList or #self.composeList == 0 then
		return
	end

	self:refreshTabRedDots()

	local updatedComposeList = self.model:getContentLists(self.selectedThirdType)
	local updatedDataById = {}

	for _, data in ipairs(updatedComposeList) do
		updatedDataById[data.id] = data
	end

	local composeList = self.composeList
	local listSuitUList = self.view.listSuitUList

	for index, data in ipairs(composeList) do
		local updatedData = updatedDataById[data.id]

		if updatedData and updatedData.progressText ~= data.progressText then
			for key, value in pairs(updatedData) do
				data[key] = value
			end

			listSuitUList:RefreshElement(index - 1)
		end
	end
end

local HOME_BOOK_VISIBLE_WHITE_LIST = {
	[UIConst.UI_ID_HOME_BOOK] = true
}
local EMPTY_WHITE_LIST = {}

function HomeBookFurnitureSetCtrl:getWhiteList()
	if self.keepHomeBookVisible then
		return HOME_BOOK_VISIBLE_WHITE_LIST
	end

	return EMPTY_WHITE_LIST
end

return HomeBookFurnitureSetCtrl
