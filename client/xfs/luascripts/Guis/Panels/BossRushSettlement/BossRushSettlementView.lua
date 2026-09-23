-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\BossRushSettlement\\BossRushSettlementView.lua

local logger = require("Core.Log.LoggerManager").getLogger("BossRushSettlementView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local BossRushSettlementView = Class.LightClass("BossRushSettlementView", UIView)
local ClientTextUtils = require("Utils.ClientTextUtils")

function BossRushSettlementView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.rootUComponent = self.objectReference:GetRefValue("rootUComponent")
	self.panelSocre1UButton = self.objectReference:GetRefValue("panelSocre1UButton")
	self.panelSocre2UButton = self.objectReference:GetRefValue("panelSocre2UButton")
	self.panelSocre3UButton = self.objectReference:GetRefValue("panelSocre3UButton")
	self.totalScoreUBaseText = self.objectReference:GetRefValue("totalScoreUBaseText")
	self.totalStarUBaseText = self.objectReference:GetRefValue("totalStarUBaseText")
	self.btnReturnUButton = self.objectReference:GetRefValue("btnReturnUButton")
	self.btnExitUButton = self.objectReference:GetRefValue("btnExitUButton")
	self.bgCloseUButton = self.objectReference:GetRefValue("bgCloseUButton")
	self.oldScoreUBaseText = self.objectReference:GetRefValue("oldScoreUBaseText")
	self.newScoreUBaseText = self.objectReference:GetRefValue("newScoreUBaseText")
	self.oldStarUBaseText = self.objectReference:GetRefValue("oldStarUBaseText")
	self.newStarUBaseText = self.objectReference:GetRefValue("newStarUBaseText")
	self.rewardUList = self.objectReference:GetRefValue("rewardUList")
	self.scoreResultUButton = self.objectReference:GetRefValue("scoreResultUButton")
	self.starResultUButton = self.objectReference:GetRefValue("starResultUButton")
	self.rewardTipUBaseText = self.objectReference:GetRefValue("rewardTipUBaseText")
	self.btnAiHelpUButton = self.objectReference:GetRefValue("btnAiHelpUButton")
	self.escListItemUList = self.objectReference:GetRefValue("escListItemUList")
	self.rankNameTxtUBaseText = self.objectReference:GetRefValue("rankNameTxtUBaseText")
	self.rankNumTxtUBaseText = self.objectReference:GetRefValue("rankNumTxtUBaseText")
	self.goSeasonBtnUButton = self.objectReference:GetRefValue("goSeasonBtnUButton")
	self.goRankBtnUButton = self.objectReference:GetRefValue("goRankBtnUButton")
	self.resultBox3UButton = self.objectReference:GetRefValue("resultBox3UButton")
	self.seasonTxtNameUSDFText = self.objectReference:GetRefValue("seasonTxtNameUSDFText")
	self.consoleBarConsoleBar = self.objectReference:GetRefValue("consoleBarConsoleBar")
	self.resultBox1TxtUSDFText = self.objectReference:GetRefValue("resultBox1TxtUSDFText")
end

function BossRushSettlementView:registerObjects()
	local objectReference = self.btnReturnUButton:GetComponent("ObjectReference")

	self.btnReturnUText = objectReference:GetRefValue("txtNameUText")
	self.btnReturnHotKeyContent = objectReference:GetRefValue("keyHotKeyContent")

	local objectReference = self.btnExitUButton:GetComponent("ObjectReference")

	self.btnExitUText = objectReference:GetRefValue("txtNameUText")
	self.btnExitHotKeyContent = objectReference:GetRefValue("keyHotKeyContent")

	local objectReference = self.btnAiHelpUButton:GetComponent("ObjectReference")

	self.btnAiHelpUText = objectReference:GetRefValue("txtNameUText")
	self.btnAiHelpHotKeyContent = objectReference:GetRefValue("keyHotKeyContent")
end

function BossRushSettlementView:initView()
	ClientTextUtils.setText(self.rankNameTxtUBaseText, pg.getGameString("BOSS_RUSH_ESC_TIP1"))
	ClientTextUtils.setText(self.resultBox1TxtUSDFText, pg.getLocalizationText("1480502685"))
	ClientTextUtils.setText(self.seasonTxtNameUSDFText, pg.getLocalizationText("1557650816"))
end

return BossRushSettlementView
