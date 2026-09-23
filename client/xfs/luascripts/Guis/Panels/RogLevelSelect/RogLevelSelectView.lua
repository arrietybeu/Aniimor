-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\RogLevelSelect\\RogLevelSelectView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local ClientTextUtils = require("Utils.ClientTextUtils")
local RogLevelSelectView = Class.LightClass("RogLevelSelectView", UIView)

function RogLevelSelectView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.rootComponent = objectReference:GetRefValue("rootComponent")
	self.btnShop = objectReference:GetRefValue("btnShop")
	self.btnClose = objectReference:GetRefValue("btnClose")
	self.btnInfoUButton = objectReference:GetRefValue("btnInfoUButton")
	self.iconUp3UContainer = objectReference:GetRefValue("iconUp3UContainer")
	self.btnSwitchUButton = objectReference:GetRefValue("btnSwitchUButton")
	self.cycleUCountDown = objectReference:GetRefValue("cycleUCountDown")
	self.progressUBaseText = objectReference:GetRefValue("progressUBaseText")
	self.currencyUList = objectReference:GetRefValue("currencyUList")
	self.btnResetUButton = objectReference:GetRefValue("btnResetUButton")
	self.talentUList = objectReference:GetRefValue("talentUList")
	self.talentInfoUComponent = objectReference:GetRefValue("talentInfoUComponent")
	self.talentIconUImage = objectReference:GetRefValue("talentIconUImage")
	self.talentNameUBaseText = objectReference:GetRefValue("talentNameUBaseText")
	self.talentDescUBaseText = objectReference:GetRefValue("talentDescUBaseText")
	self.talentOwnUBaseText = objectReference:GetRefValue("talentOwnUBaseText")
	self.talentConsumeUBaseText = objectReference:GetRefValue("talentConsumeUBaseText")
	self.talentTipsUList = objectReference:GetRefValue("talentTipsUList")
	self.btnActiveUButton = objectReference:GetRefValue("btnActiveUButton")
	self.rootAnimation = objectReference:GetRefValue("rootAnimation")
	self.normalLevelUList = objectReference:GetRefValue("normalLevelUList")
	self.highLevelUList = objectReference:GetRefValue("highLevelUList")
	self.conditionAnimation = objectReference:GetRefValue("conditionAnimation")
	self.weeklyUButton = objectReference:GetRefValue("weeklyUButton")
	self.titleTabUList = objectReference:GetRefValue("titleTabUList")
	self.btnNextTipUButton = objectReference:GetRefValue("btnNextTipUButton")
	self.dailyRewardUButton = objectReference:GetRefValue("dailyRewardUButton")
	self.dailyRewardUBaseText = objectReference:GetRefValue("dailyRewardUBaseText")
	self.dailyReward1UBaseText = objectReference:GetRefValue("dailyReward1UBaseText")
	self.nextTipUBaseText = objectReference:GetRefValue("nextTipUBaseText")
	self.shopUBaseText = objectReference:GetRefValue("shopUBaseText")
	self.listLeftTopUList = objectReference:GetRefValue("listLeftTopUList")
	self.seasonTextUSDFText = objectReference:GetRefValue("seasonTextUSDFText")
	self.seasonText1USDFText = objectReference:GetRefValue("seasonText1USDFText")
	self.txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")
	self.countDownUCountDown = objectReference:GetRefValue("countDownUCountDown")
	self.rewardsUButton = objectReference:GetRefValue("rewardsUButton")
	self.txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	self.seasonUCountDown = objectReference:GetRefValue("seasonUCountDown")
end

function RogLevelSelectView:registerObjects()
	local btnActiveObjectReference = self.btnActiveUButton:GetComponent("ObjectReference")

	self.btnActiveUText = btnActiveObjectReference:GetRefValue("txtNameUText")
end

function RogLevelSelectView:initView()
	ClientTextUtils.setText(self.seasonTextUSDFText, pg.getGameString("Rogue_Season_LeftTime"))
	ClientTextUtils.setText(self.txtTitleUSDFText, pg.getGameString("Rogue_Week_LeftTime"))
	ClientTextUtils.setText(self.txtNameUSDFText, pg.getGameString("Rogue_Week_Reward"))
end

return RogLevelSelectView
