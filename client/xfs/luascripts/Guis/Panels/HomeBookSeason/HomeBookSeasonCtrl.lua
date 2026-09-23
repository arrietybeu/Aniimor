-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomeBookSeason\\HomeBookSeasonCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local MessageName = require("Const.MessageName")
local ClientTextUtils = require("Utils.ClientTextUtils")
local HomeBookRedDotUtils = require("Utils.HomeBookRedDotUtils")
local UIConst = require("Const.UIConst")
local TimerManager = require("Core.Timer.TimerManager")
local HomeBookSeasonCtrl = Class.LightClass("HomeBookSeasonCtrl", UICtrl)

HomeBookSeasonCtrl.messages = {
	[MessageName.ON_HOME_BOOK_DATA_CHANGED] = {
		"onHomeBookDataChanged",
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

function HomeBookSeasonCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function HomeBookSeasonCtrl:addListener()
	if self.view.btnBackUButton then
		function self.view.btnBackUButton.luaClick()
			self:closePanel()
		end
	end

	if self.view.listItemUList then
		function self.view.listItemUList.luaRenderItem(button, index, data)
			self:renderGroup(button, data)
		end
	end
end

function HomeBookSeasonCtrl:onOpen(info)
	self:cancelHomeBookVisibleFrameTimer()
	UICtrl.onOpen(self, info)
	self.model:setSeasonInfo(info)
	self:refreshView()

	self.keepHomeBookVisible = true
	self.homeBookVisibleFrameId = self:startFrameTimer(function()
		self.homeBookVisibleFrameId = nil

		self:releaseHomeBookVisible()
	end, 5)
end

function HomeBookSeasonCtrl:cancelHomeBookVisibleFrameTimer()
	if not self.homeBookVisibleFrameId then
		return
	end

	TimerManager.delFrameCb(self.homeBookVisibleFrameId)

	self.homeBookVisibleFrameId = nil
end

function HomeBookSeasonCtrl:refreshView()
	if self.view.tMPUSDFText then
		ClientTextUtils.setText(self.view.tMPUSDFText, self.model:getTitle())
	end

	if self.view.listItemUList then
		self.view.listItemUList:SetList(self.model:getGroups())
	end
end

function HomeBookSeasonCtrl:renderGroup(button, data)
	local root = button.transform
	local objectReference = button:GetComponent("ObjectReference")
	local txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")
	local txtNumUSDFText = objectReference:GetRefValue("txtNumUSDFText")
	local listItemUList = objectReference:GetRefValue("listItemUList")

	if txtTitleUSDFText then
		ClientTextUtils.setText(txtTitleUSDFText, data.title)
	end

	if txtNumUSDFText then
		ClientTextUtils.setText(txtNumUSDFText, string.format("%d/%d", data.collectedCount, data.totalCount))
	end

	if not listItemUList then
		return
	end

	if data.tIndex == 0 then
		function listItemUList.luaRenderItem(itemButton, index, itemData)
			self:renderSuitItem(itemButton, itemData, data.entryIds)
		end
	else
		function listItemUList.luaRenderItem(itemButton, index, itemData)
			self:renderNormalItem(itemButton, itemData, data.entryIds)
		end
	end

	listItemUList:SetList(data.items)
end

function HomeBookSeasonCtrl:renderSuitItem(button, data, entryIds)
	local objectReference = button:GetComponent("ObjectReference")
	local txtNotCollected = objectReference:GetRefValue("txtNotCollectedUSDFText")
	local txtNum = objectReference:GetRefValue("txtNumUSDFText")
	local txtName = objectReference:GetRefValue("txtNameUSDFText")
	local icon = objectReference:GetRefValue("iconUImage")

	ClientTextUtils.setText(txtNotCollected, pg.getGameString("HOME_BOOK_NOT_COLLECTED"))
	ClientTextUtils.setText(txtNum, data.progressText)
	ClientTextUtils.setText(txtName, data.name)

	icon.url = data.icon or ""

	button:TryChangePage("NotCollected", data.isCollected and 0 or 1)

	function button.luaClick()
		self:openSuitDetail(data, entryIds)
	end
end

function HomeBookSeasonCtrl:renderNormalItem(button, data, entryIds)
	local objectReference = button:GetComponent("ObjectReference")
	local txtName = objectReference:GetRefValue("txtNameUSDFText")
	local qualityBg = objectReference:GetRefValue("imgBgQualityUImage")
	local icon = objectReference:GetRefValue("iconUImage")
	local addUWidget = objectReference:GetRefValue("addUWidget")
	local txtAddUSDFText = objectReference:GetRefValue("txtAddUSDFText")

	ClientTextUtils.setText(txtName, data.name)

	local showAddGrade = data.addGrade > 0

	if showAddGrade then
		ClientTextUtils.setText(txtAddUSDFText, "+" .. data.addGrade)
	end

	addUWidget:SetActive(showAddGrade)

	qualityBg.url = QUALITY_BACKGROUND[data.quality] or QUALITY_BACKGROUND[1]
	icon.url = data.icon or ""

	button:TryChangePage("NotCollected", data.isCollected and 0 or 1)

	function button.luaClick()
		self:openCropDetail(data, entryIds)
	end
end

function HomeBookSeasonCtrl:openSuitDetail(data, entryIds)
	if data.sourceType ~= "furniture" and data.sourceType ~= "compose" then
		return
	end

	pg.global.ui:open(UIConst.UI_ID_HOME_BOOK_FURNITURE_DETAIL, {
		entryId = data.id,
		entryIds = entryIds
	})
end

function HomeBookSeasonCtrl:openCropDetail(data, entryIds)
	if data.sourceType ~= "item" then
		return
	end

	pg.global.ui:open(UIConst.UI_ID_HOME_BOOK_CROP_DETAIL, {
		entryId = data.id,
		entryIds = entryIds
	})
end

function HomeBookSeasonCtrl:onHomeBookDataChanged()
	self:refreshView()
end

function HomeBookSeasonCtrl:close()
	self:releaseHomeBookVisible()
	UICtrl.close(self)
end

function HomeBookSeasonCtrl:releaseHomeBookVisible()
	self:cancelHomeBookVisibleFrameTimer()

	if not self.keepHomeBookVisible then
		return
	end

	self.keepHomeBookVisible = false

	self.adapter:refreshUIVisible(self.uid)
end

function HomeBookSeasonCtrl:onDestroy()
	self:releaseHomeBookVisible()
	UICtrl.onDestroy(self)
end

local HOME_BOOK_VISIBLE_WHITE_LIST = {
	[UIConst.UI_ID_HOME_BOOK] = true
}
local EMPTY_WHITE_LIST = {}

function HomeBookSeasonCtrl:getWhiteList()
	if self.keepHomeBookVisible then
		return HOME_BOOK_VISIBLE_WHITE_LIST
	end

	return EMPTY_WHITE_LIST
end

return HomeBookSeasonCtrl
