-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\BossRushSettlement\\BossRushSettlementCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("BossRushSettlementCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local FunMenuExitCtrl = require("Guis.Panels.FunMenuExit.FunMenuExitCtrl")
local BossRushSettlementCtrl = Class.LightClass("BossRushSettlementCtrl", FunMenuExitCtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")
local BossRushCycleData = require("Data.bossrush_cycle_data")
local BossRushLevelData = require("Data.bossrush_guanka_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PuppetData = require("Data.puppet_data")
local UIConst = require("Const.UIConst")
local BossRushUtils = require("Utils.BossRushUtils")
local HotKeyConst = require("Const.HotKeyConst")

BossRushSettlementCtrl.messages = {}

function BossRushSettlementCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.pageType = info and info.pageType or 0
	self.fromServer = info and info.fromServer or false
	self.newRecordData = info and info.newRecordData or nil

	self.view.rootUComponent:TryChangePage("hasNewRecord", self.pageType)

	self.cycleData = BossRushCycleData[pg.me.curBossRushCycleId]

	if not self.cycleData then
		logger:error("BossRushSettlementCtrl:initUI no cycle data for id:", pg.me.curBossRushCycleId)

		return
	end

	self.isScoreNew = false
	self.isStarNew = false
	self.inRankNew = false

	self:initUI()
end

function BossRushSettlementCtrl:addListener()
	function self.view.escListItemUList.luaRenderItem(button, index, data)
		self:onRenderItem(button, index, data)
	end

	function self.view.btnReturnUButton.luaClick()
		self:close()
	end

	function self.view.btnExitUButton.luaClick()
		if not self.fromServer then
			local title = pg.getGameString("WARNING")
			local desc = pg.getGameString("BOSS_RUSH_EXIT_CONFIRM_TIP")

			pg.global.showConfirmMsgRaw(title, desc, function()
				BossRushUtils.hasSettle = true

				pg.me:serverMsg("RPC_CS_BossRushQuitAndSettle")
				self:close()
			end, nil)
		else
			self:close()
		end
	end

	function self.view.btnAiHelpUButton.luaClick()
		if not self.fromServer and (pg.me:isTeamLeader() or not pg.me:isInTeam()) then
			pg.me:serverMsg("RPC_CS_BossRushRequireAddBot")
			self:close()
		end
	end

	function self.view.bgCloseUButton.luaClick()
		self:close()
	end

	self.view.goSeasonBtnUButton.gameObject:SetActiveEx(false)

	function self.view.goRankBtnUButton.luaClick()
		BossRushUtils.openRank()
		self:close()
	end
end

function BossRushSettlementCtrl:initUI()
	if self.pageType == 0 then
		self:initSettlement()
	else
		self:initNewRecord()
	end
end

function BossRushSettlementCtrl:initSettlement()
	self.view.btnReturnUButton:SetActive(not self.fromServer)
	ClientTextUtils.setText(self.view.btnReturnUText, pg.getGameString("BOSS_RUSH_ESC_BACK"))
	ClientTextUtils.setText(self.view.btnExitUText, pg.getGameString("BOSS_RUSH_ESC_QUIT"))
	ClientTextUtils.setText(self.view.btnAiHelpUText, pg.getGameString("BOSS_RUSH_ESC_AI_ADD"))
	ClientTextUtils.setText(self.view.rankNumTxtUBaseText, "")

	local isRankOpen = BossRushUtils.isRankOpen()
	local canAddBotPlayer = BossRushUtils.canAddBotPlayer()

	self.view.btnAiHelpUButton:SetActive(not self.fromServer and canAddBotPlayer)

	local score, star

	if self.newRecordData then
		score = self.newRecordData.totalScore or 0
		star = self.newRecordData.totalGrade or 0
		self.isScoreNew = score > self.newRecordData.lastBestScore
		self.isStarNew = star > self.newRecordData.lastBestGrade
	else
		score, star = BossRushUtils.getCurCycleTotalScore()
		self.isScoreNew = pg.me.curBossRushCycBestTotScore and score > pg.me.curBossRushCycBestTotScore
		self.isStarNew = pg.me.curBossRushCycBestGrades and star > pg.me.curBossRushCycBestGrades
	end

	ClientTextUtils.setText(self.view.totalScoreUBaseText, score)
	ClientTextUtils.setText(self.view.totalStarUBaseText, star)
	self.view.scoreResultUButton:TryChangePage("isNew", self.isScoreNew and 1 or 0)
	self.view.starResultUButton:TryChangePage("isNew", self.isStarNew and 1 or 0)
	self.view.resultBox3UButton:SetActive(isRankOpen)
	self.view.consoleBarConsoleBar:SetState("isShowRank", isRankOpen, true)
end

function BossRushSettlementCtrl:refreshMyRank(rank)
	local rankText = ""

	if rank == -1 then
		rankText = pg.getGameString("RANK_NOT_LISTED")
	elseif rank and rank > 0 then
		rankText = pg.getGameString("NUMBER") .. rank
	end

	ClientTextUtils.setText(self.view.rankNumTxtUBaseText, rankText)
end

function BossRushSettlementCtrl:initNewRecord()
	local oldBestScore = self.newRecordData and self.newRecordData.lastBestScore or 0
	local oldBestGrade = self.newRecordData and self.newRecordData.lastBestGrade or 0
	local newScore = self.newRecordData and self.newRecordData.totalScore or 0

	newScore = math.max(newScore, oldBestScore)

	local newGrade = self.newRecordData and self.newRecordData.totalGrade or 0

	newGrade = math.max(newGrade, oldBestGrade)

	ClientTextUtils.setText(self.view.oldScoreUBaseText, oldBestScore)
	ClientTextUtils.setText(self.view.newScoreUBaseText, newScore)
	ClientTextUtils.setText(self.view.oldStarUBaseText, oldBestGrade)
	ClientTextUtils.setText(self.view.newStarUBaseText, newGrade)
	self.view.rootUComponent:TryChangePage("HighScoreState", oldBestScore < newScore and 0 or 1)
	self.view.rootUComponent:TryChangePage("NowScoreState", oldBestGrade < newGrade and 0 or 1)

	function self.view.rewardUList.luaRenderItem(button, index, data)
		LuaUIUtils.renderRewardItem(button, data)
	end

	local rewards = self.newRecordData and self.newRecordData.rewards or {}
	local assistRewards = self.newRecordData and self.newRecordData.assistRewards or {}
	local rewardData = {}

	for id, value in pairs(rewards) do
		table.insert(rewardData, {
			id = id,
			num = value
		})
	end

	local hasAssist = false

	for id, value in pairs(assistRewards) do
		table.insert(rewardData, {
			id = id,
			num = value
		})

		hasAssist = true
	end

	if hasAssist then
		ClientTextUtils.setText(self.view.rewardTipUBaseText, pg.getGameString("BOSS_RUSH_HELP_REWARD"))
	end

	self.view.rewardUList:SetList(rewardData)
end

function BossRushSettlementCtrl:onDestroy()
	BossRushUtils.onLeaveBossRush()

	if (self.isScoreNew or self.isStarNew or BossRushUtils.checkHasAssistReward(self.newRecordData)) and self.fromServer then
		pg.global.ui.hudV2:delayShowBossRushUpdate({
			pageType = 1,
			newRecordData = self.newRecordData
		})
	end

	if self.pageType == 1 and BossRushUtils.showHelpTipArgs then
		BossRushUtils.showBossRushHelpTip(BossRushUtils.showHelpTipArgs)

		BossRushUtils.showHelpTipArgs = nil
	end

	if self.fromServer and pg.me.space:isBossRushEnv() then
		pg.me:serverMsg("RPC_CS_QuitSpace")
	end

	UICtrl.onDestroy(self)
end

function BossRushSettlementCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	self:refreshFuncItem()
end

function BossRushSettlementCtrl:onShow()
	if BossRushUtils.isRankOpen() then
		BossRushUtils.getMyRank(function(rank)
			self:refreshMyRank(rank)
		end)
	end
end

function BossRushSettlementCtrl:onHide()
	return
end

function BossRushSettlementCtrl:checkUIShowVirtualMouseCursor()
	return false
end

function BossRushSettlementCtrl:refreshFuncItem()
	local funcData = self.model:getFuncListData()

	self.view.escListItemUList:SetList(funcData)
end

return BossRushSettlementCtrl
