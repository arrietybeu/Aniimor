-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomeBookScoreReward\\HomeBookScoreRewardCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local UIConst = require("Const.UIConst")
local MessageName = require("Const.MessageName")
local RedDotConst = require("Const.RedDotConst")
local NoticeDef = require("Common.NoticeDef")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local HomeBookRedDotUtils = require("Utils.HomeBookRedDotUtils")
local TimerManager = require("Core.Timer.TimerManager")
local HomeBookScoreRewardCtrl = Class.LightClass("HomeBookScoreRewardCtrl", UICtrl)

HomeBookScoreRewardCtrl.messages = {
	[MessageName.ON_HOME_BOOK_DATA_CHANGED] = {
		"onHomeBookDataChanged",
		true
	}
}

function HomeBookScoreRewardCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.isReceiving = false
end

function HomeBookScoreRewardCtrl:addListener()
	function self.view.btnBackUButton.luaClick()
		self:closePanel()
	end

	function self.view.listRewardUList.luaRenderItem(button, index, data)
		self:renderReward(button, data)
	end
end

function HomeBookScoreRewardCtrl:onOpen(info)
	self:cancelHomeBookVisibleFrameTimer()
	UICtrl.onOpen(self, info)
	self:setRewardViewVisible(type(info) ~= "table" or info.startTransparent ~= true)
	self:refreshView()

	self.keepHomeBookVisible = true
	self.homeBookVisibleFrameId = self:startFrameTimer(function()
		self.homeBookVisibleFrameId = nil
		self.keepHomeBookVisible = false

		self.adapter:refreshUIVisible(self.uid)
	end, 5)
end

function HomeBookScoreRewardCtrl:cancelHomeBookVisibleFrameTimer()
	if not self.homeBookVisibleFrameId then
		return
	end

	TimerManager.delFrameCb(self.homeBookVisibleFrameId)

	self.homeBookVisibleFrameId = nil
end

function HomeBookScoreRewardCtrl:setRewardViewVisible(visible)
	if self.view and self.view.widget then
		self.view.widget.renderOpacity = visible and 1 or 0
	end
end

function HomeBookScoreRewardCtrl:refreshView()
	ClientTextUtils.setText(self.view.tMPUSDFText, pg.getGameString("HOME_BOOK"))
	ClientTextUtils.setText(self.view.txtScoreTitleUSDFText, pg.getGameString("HOME_BOOK_CUR_SCORE"))

	local score = 0

	if pg.me then
		score = pg.me:getHomeHandbookScore()
	end

	ClientTextUtils.setText(self.view.txtScoreNumUSDFText, score)

	local gradeConfig = self.model:getCurrentGradeConfig()

	if gradeConfig then
		self.view.iconCampUImage.url = gradeConfig.gradeIcon or ""

		ClientTextUtils.setText(self.view.txtTitleUSDFText, pg.getLocalizationText(gradeConfig.title))
	else
		self.view.iconCampUImage.url = nil

		ClientTextUtils.setText(self.view.txtTitleUSDFText, "")
	end

	self.view.listRewardUList:SetList(self.model:getRewards())
	HomeBookRedDotUtils.refreshTree()
end

function HomeBookScoreRewardCtrl:renderReward(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local txtScoreUSDFText = objectReference:GetRefValue("txtScoreUSDFText")
	local listRewardUList = objectReference:GetRefValue("listRewardUList")
	local btnReciveUButton = objectReference:GetRefValue("btnReciveUButton")

	ClientTextUtils.setText(txtNameUSDFText, pg.getGameString("HOME_BOOK_SCORE"))
	ClientTextUtils.setText(txtScoreUSDFText, data.grade)
	button:TryChangePage("State", data.state)
	LuaUIUtils.setRewardListByDropId(listRewardUList, data.rewardId, nil, data.state == 1, data.state == 2)

	local receiveButton = btnReciveUButton

	receiveButton = receiveButton or button
	receiveButton.luaClick = nil

	if data.isClaimable then
		function receiveButton.luaClick()
			self:receiveAllRewards()
		end
	end

	pg.global.setRedDot(data.redDotPath, receiveButton, data.isClaimable, RedDotConst.RedDotStyle.REWARD)
end

function HomeBookScoreRewardCtrl:receiveAllRewards()
	if self.isReceiving or not pg.me then
		return
	end

	self.isReceiving = true

	pg.me:reqReceiveHandbookGradeReward(function(result)
		self.isReceiving = false

		if result ~= NoticeDef.SUCCESS then
			return
		end

		self:refreshView()
		HomeBookRedDotUtils.refreshTree()
	end)
end

function HomeBookScoreRewardCtrl:onHomeBookDataChanged()
	self:refreshView()
end

function HomeBookScoreRewardCtrl:onDestroy()
	self:cancelHomeBookVisibleFrameTimer()

	self.keepHomeBookVisible = false

	UICtrl.onDestroy(self)
end

local HOME_BOOK_VISIBLE_WHITE_LIST = {
	[UIConst.UI_ID_HOME_BOOK] = true
}
local EMPTY_WHITE_LIST = {}

function HomeBookScoreRewardCtrl:getWhiteList()
	if self.keepHomeBookVisible then
		return HOME_BOOK_VISIBLE_WHITE_LIST
	end

	return EMPTY_WHITE_LIST
end

return HomeBookScoreRewardCtrl
