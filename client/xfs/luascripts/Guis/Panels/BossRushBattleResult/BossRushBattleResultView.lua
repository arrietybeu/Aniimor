-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\BossRushBattleResult\\BossRushBattleResultView.lua

local logger = require("Core.Log.LoggerManager").getLogger("BossRushBattleResultView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local ClientTextUtils = require("Utils.ClientTextUtils")
local BossRushBattleResultView = Class.LightClass("BossRushBattleResultView", UIView)

function BossRushBattleResultView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.rootUComponent = objectReference:GetRefValue("rootUComponent")
	self.bossNameUBaseText = objectReference:GetRefValue("bossNameUBaseText")
	self.starUBaseText = objectReference:GetRefValue("starUBaseText")
	self.scoreUBaseText = objectReference:GetRefValue("scoreUBaseText")
	self.timeUBaseText = objectReference:GetRefValue("timeUBaseText")
	self.playerUList = objectReference:GetRefValue("playerUList")
	self.countDownUCountDown = objectReference:GetRefValue("countDownUCountDown")
	self.bgCloseUButton = objectReference:GetRefValue("bgCloseUButton")
	self.result1UButton = objectReference:GetRefValue("result1UButton")
	self.result2UButton = objectReference:GetRefValue("result2UButton")
	self.result3UButton = objectReference:GetRefValue("result3UButton")
	self.keyListUList = objectReference:GetRefValue("keyListUList")
	self.btnAiHelpUButton = objectReference:GetRefValue("btnAiHelpUButton")
	self.btnExitUButton = objectReference:GetRefValue("btnExitUButton")
	self.btnViewDataUButton = objectReference:GetRefValue("btnViewDataUButton")
	self.textTipsUSDFText = objectReference:GetRefValue("textTipsUSDFText")
end

function BossRushBattleResultView:registerObjects()
	local objectReference = self.btnAiHelpUButton:GetComponent("ObjectReference")

	self.btnAiHelpUText = objectReference:GetRefValue("txtNameUText")
	self.btnAiHelpHotKeyContent = objectReference:GetRefValue("keyHotKeyContent")

	local objectReference = self.btnExitUButton:GetComponent("ObjectReference")

	self.btnExitUText = objectReference:GetRefValue("txtNameUText")
	self.btnExitHotKeyContent = objectReference:GetRefValue("keyHotKeyContent")
end

function BossRushBattleResultView:initView()
	ClientTextUtils.setText(self.btnViewDataUButton:GetComponent("ObjectReference"):GetRefValue("txtNameUText"), pg.getGameString("BOSS_RUSH_RESULT_TIP1"))
	ClientTextUtils.setText(self.textTipsUSDFText, pg.getGameString("BOSS_RUSH_RESULT_TIP4"))
end

return BossRushBattleResultView
