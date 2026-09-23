-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomeBook\\HomeBookCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomeBookCtrl")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local MessageName = require("Const.MessageName")
local RedDotConst = require("Const.RedDotConst")
local HomeBookRedDotUtils = require("Utils.HomeBookRedDotUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local HomeBookDataUtil = require("Utils.HomeBookDataUtils")
local UIConst = require("Const.UIConst")
local HomeBookCtrl = Class.LightClass("HomeBookCtrl", UICtrl)

HomeBookCtrl.messages = {
	[MessageName.ON_HOME_BOOK_DATA_CHANGED] = {
		"onHomeBookDataChanged",
		true
	},
	[MessageName.ON_HOME_BOOK_RED_DOT_CHANGED] = {
		"onHomeBookRedDotChanged",
		true
	}
}

function HomeBookCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function HomeBookCtrl:addListener()
	function self.view.btnBackUButton.luaClick()
		self:closePanel()
	end

	function self.view.btnRatingUButton.luaClick()
		self:onScoreClick()
	end
end

function HomeBookCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	self:refreshView()
end

function HomeBookCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function HomeBookCtrl:refreshView()
	ClientTextUtils.setText(self.view.tMPUSDFText, pg.getGameString("HOME_BOOK"))
	HomeBookRedDotUtils.refreshTree()
	self:RefreshScore()

	local list = self.model:getEntranceList()

	for i = 1, 5 do
		if list and list[i] then
			self:RefreshEntryItem(list[i], self.view.items[i])
		end
	end
end

function HomeBookCtrl:onHomeBookDataChanged()
	self:refreshView()
end

function HomeBookCtrl:onHomeBookRedDotChanged()
	self:refreshView()
end

function HomeBookCtrl:RefreshScore()
	local score = 0

	if pg.me then
		score = pg.me:getHomeHandbookLastViewedGrade()
	end

	ClientTextUtils.setText(self.view.txtNumUSDFText, score)

	local config = HomeBookDataUtil.getCurGradeConfig(score)

	if config then
		self.view.iconRewardUImage.url = config.gradeIcon or ""
	else
		self.view.iconRewardUImage.url = nil
	end

	ClientTextUtils.setText(self.view.txtRatingUSDFText, pg.getGameString("HOME_BOOK_SCORE"))

	local canGetReward = HomeBookRedDotUtils.canReceiveScoreReward()

	pg.global.setRedDot(RedDotConst.RedDotPath.HOME_BOOK_SCORE_REWARD, self.view.btnRatingUButton, canGetReward, RedDotConst.RedDotStyle.REWARD)
end

function HomeBookCtrl:RefreshEntryItem(entry, button)
	local objectReference = button:GetComponent("ObjectReference")
	local txtLockUSDFText = objectReference:GetRefValue("txtLockUSDFText")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local txtNumUSDFText = objectReference:GetRefValue("txtNumUSDFText")

	if not entry.isSeason then
		local redDotStyle = RedDotConst.RedDotStyle.NONE

		if entry.hasReward then
			redDotStyle = RedDotConst.RedDotStyle.REWARD
		elseif entry.isNew then
			redDotStyle = RedDotConst.RedDotStyle.NEW
		end

		local showRedDot = redDotStyle ~= RedDotConst.RedDotStyle.NONE

		pg.global.setRedDot(entry.redDotPath, button, showRedDot, redDotStyle)
	end

	function button.luaClick()
		if not entry.isUnlocked then
			pg.global.ui.tips:showTextTip(entry.unlockDesc)

			return
		end

		if entry.isSeason then
			pg.global.ui:open(UIConst.UI_ID_HOME_BOOK_SEASON, {
				categoryId = entry.categoryId,
				seasonId = entry.seasonId,
				title = entry.name
			})

			return
		end

		pg.global.ui:open(UIConst.UI_ID_HOME_BOOK_FURNITURE_SET, {
			categoryId = entry.categoryId,
			title = entry.name,
			isTextTab = entry.categoryId == 4
		})
	end

	ClientTextUtils.setText(txtNameUSDFText, entry.name)
	ClientTextUtils.setText(txtNumUSDFText, entry.progressText)
	ClientTextUtils.setText(txtLockUSDFText, entry.unlockDesc)
	button:TryChangePage("Unlock", entry.isUnlocked and 0 or 1)
end

function HomeBookCtrl:onScoreClick()
	if not pg.me then
		return
	end

	local oldScore = pg.me:getHomeHandbookLastViewedGrade()
	local newScore = pg.me:getHomeHandbookScore()
	local needScorePopup = oldScore < newScore

	pg.global.ui:open(UIConst.UI_ID_HOME_BOOK_SCORE_REWARD, {
		startTransparent = needScorePopup
	}, function()
		if not needScorePopup then
			return
		end

		local restored = false

		local function showScoreReward()
			if restored then
				return
			end

			restored = true

			local scoreRewardCtrl = pg.global.ui:tryGetCtrlByUid(UIConst.UI_ID_HOME_BOOK_SCORE_REWARD)

			if scoreRewardCtrl then
				scoreRewardCtrl:setRewardViewVisible(true)
			end
		end

		local newEntries = HomeBookDataUtil.getNewCollectedEntries(oldScore, newScore)

		pg.global.ui:open(UIConst.UI_ID_HOME_BOOK_SCORE_POPUP, {
			oldScore = oldScore,
			newScore = newScore,
			entries = newEntries,
			onClose = showScoreReward
		}, function()
			if pg.me then
				pg.me:reqRecordHomeHandbookViewedGrade()
			end
		end, showScoreReward)
	end)
end

return HomeBookCtrl
