-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandSeasonIntro\\HomelandSeasonIntroCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomelandSeasonIntroCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ClientTextUtils = require("Utils.ClientTextUtils")
local HomelandSeasonData = require("Data.home_season_data")
local HomeSeasonDescData = require("Data.home_season_desc_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Utils = require("Common.Utils.Utils")
local HomelandSeasonIntroCtrl = Class.LightClass("HomelandSeasonIntroCtrl", UICtrl)

HomelandSeasonIntroCtrl.messages = {}

function HomelandSeasonIntroCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.seasonId = info.seasonId
	self.selectedId = nil
end

function HomelandSeasonIntroCtrl:addListener()
	function self.view.btnCloseUButton.luaClick()
		self:close()
	end

	function self.view.tabListUList.luaRenderItem(button, index, data)
		self:onAnnouncementLeftTb(button, index, data)
	end

	function self.view.contentListUList.luaRenderItem(button, index, data)
		self:onAnnouncementRightInfo(button, index, data)
	end
end

function HomelandSeasonIntroCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function HomelandSeasonIntroCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	self:refreshSeasonInfo(true)
end

function HomelandSeasonIntroCtrl:onShow()
	return
end

function HomelandSeasonIntroCtrl:onHide()
	return
end

function HomelandSeasonIntroCtrl:refreshSeasonInfo(isInit)
	local seasonInfo = HomelandSeasonData[self.seasonId] or {}

	ClientTextUtils.setText(self.view.txtTitle, pg.getLocalizationText(seasonInfo.name))
	self:refreshTabList(isInit)
end

function HomelandSeasonIntroCtrl:refreshTabList(isInit)
	local seasonInfo = HomelandSeasonData[self.seasonId] or {}
	local seasonDes = seasonInfo.seasonDes or {}
	local tabListData = {}

	for _, descId in ipairs(seasonDes) do
		local descInfo = HomeSeasonDescData[descId]

		tabListData[#tabListData + 1] = {
			id = descId,
			title = pg.getLocalizationText(descInfo.name)
		}
	end

	if isInit then
		self.selectedId = seasonDes[1]

		self:refreshDescDetail(self.selectedId)
	end

	self.view.tabListUList:SetList(tabListData)
end

function HomelandSeasonIntroCtrl:refreshDescDetail(descId)
	local descInfo = HomeSeasonDescData[descId]
	local descListData = {}
	local tabDes = pg.getLocalizationText(descInfo.tabDes)
	local timeParams = {}
	local timeParamCount = 0

	for index = 1, 10 do
		timeParams[index] = ""

		local refTimeId = descInfo["refTimeId" .. index]

		if refTimeId and refTimeId ~= 0 then
			timeParamCount = index

			local timestamp = Utils.getConfigTimeOfAreaByData(nil, refTimeId)

			if timestamp then
				timeParams[index] = LuaUIUtils.timeStampToUtcString(timestamp)
			end
		end
	end

	if timeParamCount > 0 then
		tabDes = pg.getFormatText(tabDes, unpack(timeParams, 1, timeParamCount))
	end

	table.insert(descListData, {
		tIndex = 0,
		title = pg.getLocalizationText(descInfo.tabTitle)
	})

	if descInfo.tabpic then
		table.insert(descListData, {
			tIndex = 1,
			image = descInfo.tabpic
		})
	end

	table.insert(descListData, {
		tIndex = 2,
		text = tabDes
	})
	self.view.contentListUList:SetList(descListData)
end

function HomelandSeasonIntroCtrl:onAnnouncementLeftTb(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local titleText = objectReference:GetRefValue("name")

	ClientTextUtils.setText(titleText, data.title)

	button.isSelected = self.selectedId == data.id

	function button.luaClick()
		self.selectedId = data.id

		self.view.tabListUList:RefreshList()
		self:refreshDescDetail(self.selectedId)
	end
end

function HomelandSeasonIntroCtrl:setHyperlinkText(textComponent, text)
	textComponent.enabledHyperlink = true

	function textComponent.luaOnHyperlinkClick(action, content, contentRect)
		LuaUIUtils.clickHyperText(action, content, contentRect, contentRect)
	end

	ClientTextUtils.setText(textComponent, text)
end

function HomelandSeasonIntroCtrl:onAnnouncementRightInfo(button, index, data)
	if data.tIndex == 0 then
		local objectReference = button:GetComponent("ObjectReference")
		local titleText = objectReference:GetRefValue("titleText")

		self:setHyperlinkText(titleText, data.title)
	elseif data.tIndex == 1 or data.tIndex == 3 then
		local objectReference = button:GetComponent("ObjectReference")
		local bgUImage = objectReference:GetRefValue("bgUImage")

		if data.image then
			bgUImage.url = data.image
		else
			LuaUIUtils.setUIViewVisible(bgUImage, false)
		end
	elseif data.tIndex == 2 then
		local objectReference = button:GetComponent("ObjectReference")
		local titleText = objectReference:GetRefValue("txtName")

		self:setHyperlinkText(titleText, data.text)
	end
end

return HomelandSeasonIntroCtrl
