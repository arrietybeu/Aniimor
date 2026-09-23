-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\BossRushSeason\\BossRushSeasonView.lua

local logger = require("Core.Log.LoggerManager").getLogger("BossRushSeasonView")
local ClientTextUtils = require("Utils.ClientTextUtils")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local BossRushSeasonView = Class.LightClass("BossRushSeasonView", UIView)

function BossRushSeasonView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.titleUSDFText = objectReference:GetRefValue("titleUSDFText")
	self.btnInfoUButton = objectReference:GetRefValue("btnInfoUButton")
	self.listUList = objectReference:GetRefValue("listUList")
	self.starTipsUSDFText = objectReference:GetRefValue("starTipsUSDFText")
	self.starNumUSDFText = objectReference:GetRefValue("starNumUSDFText")
	self.btnBackUButton = objectReference:GetRefValue("btnBackUButton")
	self.txtCountDownUSDFText = objectReference:GetRefValue("txtCountDownUSDFText")
	self.seasonUCountDown = objectReference:GetRefValue("seasonUCountDown")
	self.countDownULayoutBox = objectReference:GetRefValue("countDownULayoutBox")
end

function BossRushSeasonView:registerObjects()
	return
end

function BossRushSeasonView:initView()
	ClientTextUtils.setText(self.titleUSDFText, ClientTextUtils.getGameString("BOSS_RUSH_SEASON"))
	ClientTextUtils.setText(self.txtCountDownUSDFText, ClientTextUtils.getGameString("BOSS_RUSH_SEASON_TIP2"))

	self.seasonUCountDown.formatText = pg.getGameString("BOSS_RUSH_SEASON_TIP3")
end

return BossRushSeasonView
