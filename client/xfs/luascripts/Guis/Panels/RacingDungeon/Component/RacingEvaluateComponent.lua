-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\RacingDungeon\\Component\\RacingEvaluateComponent.lua

local UIComponent = require("Guis.Helper.UIComponent")
local Class = require("Core.Framework.Class")
local SandboxConst = require("Common.Const.SandboxConst")
local Time = require("Core.Common.Time")
local LuaUIUtils = require("Utils.LuaUIUtils")
local RaceDungeonConfigData = require("Data.race_dungeon_config_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local RacingEvaluateComponent = Class.LightClass("RacingEvaluateComponent", UIComponent)
local PlayTextAnimCD = 2
local SwitchEvaluateCD = 1
local DEFAULT_DUNGEON_ID = 2008

function RacingEvaluateComponent:onCtor(extraInfo)
	RacingEvaluateComponent.super.onCtor(self, extraInfo)

	self.curScore = -1
	self.stateChangeTime = 0
	self.sceneId = pg.me and pg.me.space.sceneId or DEFAULT_DUNGEON_ID
	self.configData = RaceDungeonConfigData[self.sceneId] or RaceDungeonConfigData[DEFAULT_DUNGEON_ID]
end

function RacingEvaluateComponent:onDestroy()
	RacingEvaluateComponent.super.onDestroy(self)
end

function RacingEvaluateComponent:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.evaluateS = self.objectReference:GetRefValue("evaluateS")
	self.evaluateA = self.objectReference:GetRefValue("evaluateA")
	self.evaluateB = self.objectReference:GetRefValue("evaluateB")
	self.infoText = self.objectReference:GetRefValue("infoText")
end

function RacingEvaluateComponent:initView()
	return
end

function RacingEvaluateComponent:updateRacingEvaluate()
	if self.ctrl.refRacingPlay then
		local valid, sampleTime, samplePercent = self.ctrl.refRacingPlay:getRacingSampleInfo()

		if valid then
			local score, scorePercent = self.ctrl.refRacingPlay:calcScoreAndRatio(sampleTime, samplePercent)

			self:setEvaluateInfo(score, scorePercent)
			LuaUIUtils.setUIVisible(self.uWidget, true)
		else
			LuaUIUtils.setUIVisible(self.uWidget, false)
		end
	end
end

function RacingEvaluateComponent:setEvaluateInfo(raceScore, percent)
	if self.curScore ~= raceScore then
		if self.lastSwitchTime and Time.realSecondCache - self.lastSwitchTime < SwitchEvaluateCD then
			return
		end

		self.lastSwitchTime = Time.realSecondCache

		local oldScore = self.curScore

		self.curScore = raceScore
		self.stateChangeTime = Time.realSecondCache
		self.keepMark = nil

		if oldScore ~= -1 then
			self:checkAndPlayTextAnim(oldScore, self.curScore)
		end
	end

	local curScoreRoot

	if raceScore == SandboxConst.RaceScore.S then
		self.uWidget:TryChangePage("Evaluate", "S")

		self.ctrl.hasReachS = true
		curScoreRoot = self.evaluateS
	elseif raceScore == SandboxConst.RaceScore.A then
		self.uWidget:TryChangePage("Evaluate", "A")

		curScoreRoot = self.evaluateA
	elseif raceScore == SandboxConst.RaceScore.B then
		self.uWidget:TryChangePage("Evaluate", "B")

		self.ctrl.hasReachB = true
		curScoreRoot = self.evaluateB
	end

	if curScoreRoot then
		local progress = curScoreRoot:GetComponent("UProgress")

		progress.minValue = 0
		progress.maxValue = 1
		progress.value = percent
	end

	self:checkAndPlayKeepAnim()
end

function RacingEvaluateComponent:checkAndPlayTextAnim(oldScore, newScore)
	if self.lastPlayTextTime and Time.realSecondCache - self.lastPlayTextTime < PlayTextAnimCD then
		return
	end

	self.lastPlayTextTime = Time.realSecondCache

	if newScore < oldScore then
		self.uWidget:TryChangePage("Grade", "Normal")
		self.uWidget:TryChangePage("Grade", "Break")
		pg.game.audio:playEvent("SFX_UI_TempleRacingGame_ImproveRating")
		ClientTextUtils.setText(self.infoText, pg.getLocalizationText(self.configData.RACE_EVALUATE_BREAK))
	elseif oldScore < newScore then
		self.uWidget:TryChangePage("Grade", "Normal")
		self.uWidget:TryChangePage("Grade", "Demote")
		pg.game.audio:playEvent("SFX_UI_TempleRacingGame_ReduceRating")
		ClientTextUtils.setText(self.infoText, pg.getLocalizationText(self.configData.RACE_EVALUATE_DEMOTE))
	end
end

function RacingEvaluateComponent:checkAndPlayKeepAnim()
	if self.curScore == SandboxConst.RaceScore.S then
		local keepMark = self.keepMark or 0

		if keepMark < 2 and Time.realSecondCache > self.stateChangeTime + 20 then
			self.keepMark = 2

			self.uWidget:TryChangePage("Grade", "Normal")
			self.uWidget:TryChangePage("Grade", "Break")
			pg.game.audio:playEvent("SFX_UI_TempleRacingGame_TextPopUp")
			ClientTextUtils.setText(self.infoText, pg.getLocalizationText(self.configData.RACE_EVALUATE_S_KEEP_2))

			return
		end

		if keepMark < 1 and Time.realSecondCache > self.stateChangeTime + 10 then
			self.keepMark = 1

			self.uWidget:TryChangePage("Grade", "Normal")
			self.uWidget:TryChangePage("Grade", "Break")
			pg.game.audio:playEvent("SFX_UI_TempleRacingGame_TextPopUp")
			ClientTextUtils.setText(self.infoText, pg.getLocalizationText(self.configData.RACE_EVALUATE_S_KEEP_1))

			return
		end
	end
end

return RacingEvaluateComponent
