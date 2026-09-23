-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\RacingDungeon\\RacingDungeonCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local Const = require("Common.Const.Const")
local SandboxConst = require("Common.Const.SandboxConst")
local Time = require("Core.Common.Time")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local RacingEvaluateComponent = require("Guis.Panels.RacingDungeon.Component.RacingEvaluateComponent")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local ClientUtils = require("Utils.ClientUtils")
local LevelData = require("Data.level_data")
local RacingDungeonCtrl = Class.LightClass("RacingDungeonCtrl", UICtrl)

RacingDungeonCtrl.messages = {
	[MessageName.RACESAMPLE_PAUSE_TIMER] = {
		"PauseTimer",
		true
	},
	[MessageName.RACESAMPLE_RESUME_TIMER] = {
		"ResumeTimer",
		true
	},
	[MessageName.RACESAMPLE_RESTART] = {
		"Restart",
		true
	}
}

function RacingDungeonCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.view = self.view
	self.evaluateComponent = RacingEvaluateComponent.new(self, self.view.evaluateWidget)
	self.restartCount = 0
	self.hasReachS = false
	self.hasReachB = false
	self.racingTimer = self:startTimer(function()
		self:onRacingTick()
	end, 0.1, true)
end

function RacingDungeonCtrl:addListener()
	local rawKeyboardF4 = KeyBindingPro.GetOrAddKeyBindingByName(self.view.container.gameObject, "rawKeyboardF4")

	rawKeyboardF4.isVirtual = true
	rawKeyboardF4.actionPath = "Raw/KeyboardF4"

	function rawKeyboardF4.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" and self.refRacingPlay and self.refRacingPlay.status == SandboxConst.RacingDungeonState.RACING then
			self:PauseTimer()
			ClientUtils.showConfirmRaw(pg.getGameString("PUZZLE_RETRY_TITLE"), pg.getGameString("PUZZLE_TELEPORT_RETRY"), function()
				self:Restart()
			end, nil, function()
				self:ResumeTimer()
			end)
		end
	end
end

function RacingDungeonCtrl:PauseTimer()
	self.refRacingPlay:serverMsg("RPC_CS_PauseRacingTimer", pg.me.id)

	if self.racingTimer then
		self:killTimer(self.racingTimer)

		self.racingTimer = nil
	end
end

function RacingDungeonCtrl:ResumeTimer()
	self.refRacingPlay:serverMsg("RPC_CS_ResumeRacingTimer", pg.me.id)

	self.racingTimer = self:startTimer(function()
		self:onRacingTick()
	end, 0.1, true)
end

function RacingDungeonCtrl:Restart()
	ClientUtils.showBlackScreen(2002)
	self.refRacingPlay:serverMsg("RPC_CS_RestartRacing", pg.me.id)
	self.refRacingPlay:restartRacing()

	self.racingTimer = self:startTimer(function()
		self:onRacingTick()
	end, 0.1, true)
	self.restartCount = self.restartCount + 1
end

function RacingDungeonCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.refRacingPlay = info.refRacingPlay

	self:initState()
end

function RacingDungeonCtrl:onDestroy()
	self.refRacingPlay = nil

	if self.finishTimer then
		self:killTimer(self.finishTimer)

		self.finishTimer = nil
	end

	if self.racingTimer then
		self:killTimer(self.racingTimer)

		self.racingTimer = nil
	end

	UICtrl.onDestroy(self)

	self.evaluateComponent = nil
end

function RacingDungeonCtrl:startCountDown()
	self.view.widget:TryChangePage("State", 1)
	pg.game.audio:triggerEvent("SFX_UI_RacingGame_321GO")
end

function RacingDungeonCtrl:onRacingTick()
	if not self.refRacingPlay then
		return
	end

	if self.refRacingPlay.status == SandboxConst.RacingDungeonState.RACING then
		if self.evaluateComponent then
			self.evaluateComponent:updateRacingEvaluate()
		end

		ClientTextUtils.setText(self.view.countDownText, self:getTotalTimeText(Time.secondCache - self.refRacingPlay.startTime))
	end
end

function RacingDungeonCtrl:onStageChange(curStage)
	self.curStage = curStage

	if not self.view then
		return
	end

	if curStage > 0 then
		self.view.widget:TryChangePage("State", 2)
	end

	self:onRacingTick()
end

function RacingDungeonCtrl:initState()
	if not self.refRacingPlay then
		return
	end

	if self.refRacingPlay.status == SandboxConst.RacingDungeonState.RACING then
		self:onStageChange(self.refRacingPlay.curStage)
	end
end

function RacingDungeonCtrl:getTotalTimeText(totalTime)
	if not totalTime then
		return ""
	end

	return LuaUIUtils.getCountDownFormateText(totalTime)
end

function RacingDungeonCtrl:onFinishRacing(totalTime)
	if not self.refRacingPlay then
		return
	end

	local finalStage = self.refRacingPlay.curStage
	local finalScore = "S"

	if finalStage <= 1 then
		self.view.widget:TryChangePage("Medal", 0)
	elseif finalStage <= 2 then
		self.view.widget:TryChangePage("Medal", 1)

		finalScore = "A"
	else
		self.view.widget:TryChangePage("Medal", 2)

		finalScore = "B"
	end

	local sceneId = pg.me.space.sceneId

	LuaUIUtils.sendCustomLog(Const.BILogName.EVENT_RACING_TEMPLE, {
		RacingTemple_ID = LevelData[sceneId].dungeonId,
		RacingTemple_SuccessTime = totalTime,
		RacingTemple_Score = finalScore,
		RacingTemple_Restart = self.restartCount,
		RacingTemple_ScoreS = self.hasReachS,
		RacingTemple_ScoreB = self.hasReachB
	})

	local totalTimeText = self:getTotalTimeText(totalTime)

	ClientTextUtils.setText(self.view.resultText1, totalTimeText)
	ClientTextUtils.setText(self.view.resultText2, totalTimeText)
	ClientTextUtils.setText(self.view.resultText3, totalTimeText)
	self.view.widget:TryChangePage("State", 3)

	if self.finishTimer then
		self:killTimer(self.finishTimer)

		self.finishTimer = nil
	end

	self.finishTimer = self:startTimer(function()
		self.view.widget:TryChangePage("State", 0)
	end, 5)

	pg.game.audio:triggerEvent("SFX_UI_RacingGame_Settlement")
end

return RacingDungeonCtrl
