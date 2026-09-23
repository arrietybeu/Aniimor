-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HudV2\\BaseComponent\\BossRushInfoUIComponent.lua

local HudBaseComponent = require("Guis.Panels.HudV2.HudBaseComponent")
local Class = require("Core.Framework.Class")
local UIConst = require("Const.UIConst")
local Const = require("Common.Const.Const")
local MessageName = require("Const.MessageName")
local ClientTextUtils = require("Utils.ClientTextUtils")
local BossRushUtils = require("Utils.BossRushUtils")
local Time = require("Core.Common.Time")
local SysConfigData = require("Data.sys_config_data")
local BossRushInfoUIComponent = Class.LightClass("BossRushInfoUIComponent", HudBaseComponent)

BossRushInfoUIComponent.messages = {
	[MessageName.BOSS_RUSH_BATTLE_START_TIME_CHANGED] = {
		"onBossRushStartBattle",
		true
	},
	[MessageName.BOSS_RUSH_LEVEL_SCORE_CHANGED] = {
		"onBossRushLevelScoreChanged",
		true
	},
	[MessageName.BOSS_RUSH_LEVEL_GRADE_CHANGED] = {
		"onBossRushLevelGradeChanged",
		true
	}
}

function BossRushInfoUIComponent:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.bossModInfoBarUWidget = objectReference:GetRefValue("bossModInfoBarUWidget")
	self.bossModInfoPanelUComponent = objectReference:GetRefValue("bossModInfoPanelUComponent")
end

function BossRushInfoUIComponent:initView()
	self:refreshBossRushInfo()
end

function BossRushInfoUIComponent:refreshBossRushInfo()
	if not pg.me.space:isBossRushEnv() then
		return
	end

	local curBossRushPlace = BossRushUtils.getCurBossRushPlace()
	local isBattleLevel = table.contains(Const.BossRushBattlePlace, curBossRushPlace)

	self.bossModInfoBarUWidget:SetActive(not isBattleLevel)
	self.bossModInfoPanelUComponent:SetActive(isBattleLevel)

	if isBattleLevel then
		self:initBossRushBattle()
	else
		if self.bossRushUCountDown then
			self.bossRushUCountDown.luaCountDownUpdate = nil

			self.bossRushUCountDown:Stop()
		end

		self:initBossRushPrepare()
	end
end

function BossRushInfoUIComponent:initBossRushBattle()
	local objectReference = self.bossModInfoPanelUComponent:GetComponent("ObjectReference")

	self.bossRushScoreNumUBaseText = objectReference:GetRefValue("scoreNumUBaseText")
	self.bossRushStarNumUBaseText = objectReference:GetRefValue("starNumUBaseText")
	self.bossRushUCountDown = objectReference:GetRefValue("countDownUCountDown")
	self.bossRushBattleRoot = objectReference:GetRefValue("rootUComponent")
	self.bossRushSettlementUButton = objectReference:GetRefValue("settlementUButton")
	self.bossRushCoinFlyNodeTransform = objectReference:GetRefValue("coinFlyNodeTransform")
	self.bossRushFlyCoinCoinGeneral = objectReference:GetRefValue("flyCoinCoinGeneral")
	self.bossRushIconCoinUWidget = objectReference:GetRefValue("iconCoinUWidget")
	self.bossRushFlyCoinCoinGeneral.subParent = self.bossRushCoinFlyNodeTransform
	self.bossRushFlyCoinCoinGeneral.targetPosition = self.bossRushIconCoinUWidget.transform.position

	local pos = pg.global.ui.tips:getBossTitleStagePos()

	if pos then
		self.bossRushFlyCoinCoinGeneral.sourcePosition = pos
	end

	function self.bossRushFlyCoinCoinGeneral.luaGeneralCoin()
		return
	end

	function self.bossRushFlyCoinCoinGeneral.luaStartFly()
		return
	end

	function self.bossRushFlyCoinCoinGeneral.luaEndFly()
		self.bossRushBattleRoot:InvokeCallback(CS.XGUI.EInvokeTime.User2)
		self:setBossRushStar()
	end

	self.bossRushFlyCoinCoinGeneral:StopCoin()

	local score = pg.space.levelScore or 0

	ClientTextUtils.setText(self.bossRushScoreNumUBaseText, math.floor(score))
	self:setBossRushStar()

	function self.bossRushSettlementUButton.luaClick()
		local canClick = not pg.me:isInTeam() or pg.me:isTeamLeader()

		if not canClick then
			pg.global.ui.tips:showTextTip(pg.getGameString("BOSS_RUSH_CANT_END_LEVEL_TIP"))

			return
		end

		pg.global.ui.hudV2.LU.quitBtn:onQuitBtnClick()
	end

	self:trySetBossRushCountDown(self.bossRushUCountDown)
end

function BossRushInfoUIComponent:initBossRushPrepare()
	local objectReference = self.bossModInfoBarUWidget:GetComponent("ObjectReference")
	local rewardUButton = objectReference:GetRefValue("rewardUButton")
	local scoreUBaseText = objectReference:GetRefValue("scoreUBaseText")
	local starUBaseText = objectReference:GetRefValue("starUBaseText")
	local scoreNameUBaseText = objectReference:GetRefValue("scoreNameUBaseText")

	function rewardUButton.luaClick()
		pg.global.ui:open(UIConst.UI_ID_BOSS_RUSH_REWARD)
	end

	self:bindHotKeyPerform("Hud/BossRushReward", function()
		rewardUButton:OnClickSimulate()
	end)

	local score, star = BossRushUtils.getCurCycleTotalScore()

	ClientTextUtils.setText(scoreUBaseText, score)
	ClientTextUtils.setText(starUBaseText, star)
	ClientTextUtils.setText(scoreNameUBaseText, pg.getGameString("BOSS_RUSH_SCORE_NAME"))
end

function BossRushInfoUIComponent:onBossRushStartBattle()
	local objectReference = self.bossModInfoPanelUComponent:GetComponent("ObjectReference")
	local countDownUCountDown = objectReference:GetRefValue("countDownUCountDown")

	self.bossRushBattleRoot = objectReference:GetRefValue("rootUComponent")

	self:trySetBossRushCountDown(countDownUCountDown)
end

function BossRushInfoUIComponent:trySetBossRushCountDown(countDownUCountDown)
	if pg.space.battleStartTime and pg.space.battleStartTime > 0 or BossRushUtils.needResetBattleTime then
		local curTime = SysConfigData.BossRushCombatDuration

		BossRushUtils.needResetBattleTime = false

		if pg.space.battleStartTime and pg.space.battleStartTime > 0 then
			curTime = pg.space.battleStartTime + SysConfigData.BossRushCombatDuration - Time.secondCache
		end

		local warnTime1 = 30
		local warnTime2 = 10

		function countDownUCountDown.luaCountDownUpdate(second)
			if second < warnTime2 then
				self.bossRushBattleRoot:TryChangePage("ProgressState", 2)

				if self.needWarnTip2 then
					self.needWarnTip2 = false

					pg.global.ui.tips:showTextTip(ClientTextUtils.concatByLanguage(pg.getGameString("SHOP_LEFT_PROP_NUM"), warnTime2, pg.getGameString("SECOND_LONG")))
				end
			elseif second < warnTime1 then
				self.bossRushBattleRoot:TryChangePage("ProgressState", 1)

				if self.needWarnTip1 then
					self.needWarnTip1 = false

					pg.global.ui.tips:showTextTip(ClientTextUtils.concatByLanguage(pg.getGameString("SHOP_LEFT_PROP_NUM"), warnTime1, pg.getGameString("SECOND_LONG")))
				end
			end
		end

		if warnTime1 <= curTime then
			self.needWarnTip1 = true
			self.needWarnTip2 = true
		elseif warnTime2 <= curTime then
			self.needWarnTip2 = true
		end

		local state = curTime < warnTime2 and 2 or curTime < warnTime1 and 1 or 0

		self.bossRushBattleRoot:TryChangePage("ProgressState", state)
		countDownUCountDown:Play(curTime, SysConfigData.BossRushCombatDuration)
	end
end

function BossRushInfoUIComponent:onBossRushLevelScoreChanged()
	if self.bossRushScoreNumUBaseText then
		self.bossRushBattleRoot:InvokeCallback(CS.XGUI.EInvokeTime.User1)

		local score = pg.space.levelScore or 0

		ClientTextUtils.setText(self.bossRushScoreNumUBaseText, math.floor(score))
	end
end

function BossRushInfoUIComponent:onBossRushLevelGradeChanged()
	if self.bossRushFlyCoinCoinGeneral.sourcePosition == nil then
		self.bossRushFlyCoinCoinGeneral.sourcePosition = pg.global.ui.tips:getBossTitleStagePos()
	end

	self.bossRushFlyCoinCoinGeneral:PlayCoinSingle()
end

function BossRushInfoUIComponent:setBossRushStar()
	if self.bossRushStarNumUBaseText then
		local star = pg.space.levelGrade or 0
		local maxStar = SysConfigData.BossRushMaxStarSideBoss
		local curBossRushPlace = BossRushUtils.getCurBossRushPlace()

		if curBossRushPlace == Const.BossRushTeleportTarget.BossMid then
			maxStar = maxStar * SysConfigData.BossRushStarMultiplierMidBoss
		end

		ClientTextUtils.setText(self.bossRushStarNumUBaseText, star, "/", maxStar)
		self.bossRushSettlementUButton:SetActive(maxStar <= star)
	end
end

function BossRushInfoUIComponent:onDestroy()
	HudBaseComponent.onDestroy(self)
end

return BossRushInfoUIComponent
