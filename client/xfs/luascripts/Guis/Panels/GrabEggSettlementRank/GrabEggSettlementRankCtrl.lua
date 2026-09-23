-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GrabEggSettlementRank\\GrabEggSettlementRankCtrl.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local logger = require("Core.Log.LoggerManager").getLogger("GrabEggSettlementRankCtrl")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local GrabEggSettlementRankCtrl = Class.LightClass("GrabEggSettlementRankCtrl", UICtrl)
local Utils = require("Common.Utils.Utils")
local UIConst = require("Const.UIConst")
local Const = require("Common.Const.Const")
local NO_TAG_PROGRESS_START_DELAY = 0.67
local TAG_PROGRESS_START_DELAY = 1.28
local TOTAL_PROGRESS_TIME = 0.82
local EGG_INTERVAL = 0.25
local SMALL_LEVEL_INTERVAL = 0.67
local BIG_LEVEL_PRE_SWITCH = 1
local BIG_LEVEL_POST_SWITCH = 2
local FINAL_STAGE_DELAY = 0
local PERFORMANCE_APPEAR_DELAY = 0.3333
local POINT_FLY_FIRST_DELAY = 0.4333
local PERFORMANCE_TAG_INTERVAL = 0.16
local NO_TAG_ASSESS_APPEAR_DELAY = 1.3333
local TAG_ASSESS_APPEAR_DELAY = 2.3833
local STAGE_PROGRESS = 0
local STAGE_PROCESS1_EGG = 1
local STAGE_PROCESS2_SMALL_LEVEL = 2
local STAGE_PROCESS3_BIG_LEVEL = 3
local STAGE_BTN = 4
local LEVEL_STATE_UP = 0
local LEVEL_STATE_DOWN = 1
local TOP_RANK_NORMAL = 0
local TOP_RANK_MAX = 1
local pointsIncrease = "SFX_UI_Grabegg_Rank_Point_Increase"
local pointsLessen = "SFX_UI_Grabegg_Rank_Point_Lessen"
local starIncrease = "SFX_UI_Grabegg_Rank_Star_Increase"
local starLessen = "SFX_UI_Grabegg_Rank_Star_Lessen"
local stageIncrease = "SFX_UI_Grabegg_Rank_Stage_Upgrade"
local stageDowngrade = "SFX_UI_Grabegg_Rank_Stage_Downgrade"
local rankUpgrade = "SFX_UI_Grabegg_Rank_Rank_Upgrade"
local rankDowngrade = "SFX_UI_Grabegg_Rank_Rank_Downgrade"
local rankSuccess = "SFX_UI_Grabegg_Rank_Success"
local rankFail = "SFX_UI_Grabegg_Rank_Fail"
local assessAppear = "SFX_UI_Grabegg_Rank_Assess_Appear"
local performanceAppear = "SFX_UI_Grabegg_Rank_Performance_Appear"
local pointFly = "SFX_UI_Grabegg_Rank_Point_Fly"

GrabEggSettlementRankCtrl.messages = {}

function GrabEggSettlementRankCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
	self.model:setRankInfo(info and info.rankInfo, info and info.difficulty)

	self.result = info and info.result
	self.playSteps = {}
	self.playIndex = 0
	self.progressTimerId = nil
	self.processTimerId = nil
	self.finalTimerId = nil
	self.soundTimerIds = {}
	self.hasStarted = false
	self.hasProgressStarted = false
	self.hasProgressEffectStarted = false
	self.isEntranceAnimFinished = false
	self.isProgressPhaseFinished = false
	self.isProcessPhaseStarted = false
	self.isProcessPhaseFinished = false
	self.eggAnimationGeneration = 0
	self.pendingEggAnimationCount = 0
	self.afterEggAnimation = nil
	self.isRankAnimFinished = false
	self.isFinishingRankAnim = false
	self.isClosing = false

	self:initRankView()
	self:initLevelState()
end

function GrabEggSettlementRankCtrl:addListener()
	function self.view.btnFullCloseUButton.luaClick()
		if self.isRankAnimFinished then
			self:closeSettlement()
		else
			self:skipRankAnim()
		end
	end

	function self.view.listEggUList.luaRenderItem(button, index, data)
		button:TryChangePage("Stage", data.stage)
	end

	function self.view.tagListLeftUList.luaRenderItem(button, index, data)
		self.view:renderPerformanceTag(button, data, true)
	end

	function self.view.tagListRightUList.luaRenderItem(button, index, data)
		self.view:renderPerformanceTag(button, data, false)
	end
end

function GrabEggSettlementRankCtrl:closeSettlement()
	if self.isClosing then
		return
	end

	self.isClosing = true

	pg.global.ui:open(UIConst.UI_ID_GRAB_EGGS_BAG, {
		settlement = true,
		bagType = UIConst.GRAB_EGG_BAG_TYPE.INVENTORY
	})
	self:close()
end

function GrabEggSettlementRankCtrl:skipRankAnim()
	if self.isRankAnimFinished then
		return
	end

	self:stopPlayTimer()
	self:cancelEggAnimation()
	self.view:stopProgressAnim()
	self.view:setGlowActive(false)
	self:renderFinalState()
	self.view:finishPerformanceTagAnim()

	self.isRankAnimFinished = true
	self.isFinishingRankAnim = false

	self.view:renderCloseText(true)
	self.view:changePanelStage(STAGE_BTN)
end

function GrabEggSettlementRankCtrl:onDestroy()
	self.isRankAnimFinished = true
	self.isFinishingRankAnim = false

	self:stopPlayTimer()
	self:cancelEggAnimation()
	self.view:stopProgressAnim()
	self.view:setGlowActive(false)
	UICtrl.onDestroy(self)
end

function GrabEggSettlementRankCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function GrabEggSettlementRankCtrl:onShow()
	self:startRankAnim()
end

function GrabEggSettlementRankCtrl:onHide()
	self:stopPlayTimer()
	self:cancelEggAnimation()
	self.view:stopProgressAnim()
	self.view:setGlowActive(false)
end

function GrabEggSettlementRankCtrl:checkCanOpen(showNotice, data)
	if pg.me and pg.me.space and Utils.isRobEggSceneId(pg.me.space.sceneId) then
		pg.game.grabEgg:markSettlement(nil)

		return false
	end

	return UICtrl.checkCanOpen(self, showNotice, data)
end

function GrabEggSettlementRankCtrl:initLevelState()
	if not self.model:isRankInfoValid() then
		return
	end

	local isNegative = self.result == Const.ROB_EGG_RESULT.Failure or self.model:isScoreNegative()

	self.view:changeLevelState(isNegative and LEVEL_STATE_DOWN or LEVEL_STATE_UP)
end

function GrabEggSettlementRankCtrl:initRankView()
	local isRankScoreLimited = self.model:isRankScoreLimited()
	local isRankScoreDoubled = self.model:isRankScoreDoubled() and not isRankScoreLimited
	local isNoviceScoreProtected = self.model:isNoviceScoreProtected()
	local rankScoreDoubleRemainingTimes = self.model:getRankScoreDoubleRemainingTimes()

	self.view:renderRankScoreDouble(isRankScoreDoubled, rankScoreDoubleRemainingTimes)

	local leftTags, rightTags = self.model:getPerformanceTagLists()

	self.performanceTagCount = self.view:renderPerformanceTags(leftTags, rightTags)

	self.view:renderSettlementContent(isRankScoreLimited, isNoviceScoreProtected)
	self.view:renderEvaluation(self.model:getEvaluationLevel())

	if not self.model:isRankInfoValid() then
		logger:error("invalid rankInfo")
		self.view:finishPerformanceTagAnim()

		self.isRankAnimFinished = true

		self.view:renderCloseText(true)
		self.view:changePanelStage(STAGE_BTN)

		return
	end

	local state = self.model:getInitialState()

	if not state then
		local info = self.model:getRankInfo()

		logger:error("rank config not found, bigRank:%s smallRank:%s", info.preBigRank, info.preSmallRank)
		self:renderFinalState()
		self.view:finishPerformanceTagAnim()

		self.isRankAnimFinished = true

		self.view:renderCloseText(true)
		self.view:changePanelStage(STAGE_BTN)

		return
	end

	self.view:changePanelStage(STAGE_PROGRESS)
	self:renderRankState(state, false)
	self.view:renderScoreDelta(self:getScoreDelta(), self.model:isScoreNegative())
	self:applyTopRankState(state.bigRank, state.eggNum)
end

function GrabEggSettlementRankCtrl:applyTopRankState(bigRank, eggNum)
	if self.model:isTopBigRank(bigRank) then
		self.view:changeTopRank(TOP_RANK_MAX)
		self.view:renderPointNum(eggNum or 0)
	else
		self.view:changeTopRank(TOP_RANK_NORMAL)
	end
end

function GrabEggSettlementRankCtrl:renderRankIdentity(bigRank, smallRank, cfg)
	local isTopRank = cfg and not cfg.upNumber

	self.view:renderRank(cfg, self.model:getDisplayRoman(bigRank, smallRank), isTopRank)
	self.view:renderIconBoard(self.model:getRankIconBoardUrl(bigRank), isTopRank)
end

function GrabEggSettlementRankCtrl:renderRankState(state, useProgressAnim)
	self:renderRankIdentity(state.bigRank, state.smallRank, state.cfg)
	self.view:renderProgress(state.score, state.cfg and state.cfg.point, useProgressAnim)
	self.view:renderPointScore(state.pointScore, state.pointTotal)

	local upNumber = state.cfg and state.cfg.upNumber or state.eggNum or 0

	self.view:renderEggs(self.model:buildEggStageList(upNumber, state.eggNum, nil))
end

function GrabEggSettlementRankCtrl:getScoreDelta()
	return self.model:getTotalScore()
end

function GrabEggSettlementRankCtrl:renderFinalState()
	local state = self.model:getFinalState()

	if not state then
		return
	end

	if state.cfg then
		self:renderRankState(state, false)
	else
		self:renderRankIdentity(state.bigRank, state.smallRank, nil)
	end

	self:applyTopRankState(state.bigRank, state.eggNum)
end

function GrabEggSettlementRankCtrl:startRankAnim()
	if self.hasStarted then
		return
	end

	self.hasStarted = true

	if not self.model:isRankInfoValid() then
		self.view:finishPerformanceTagAnim()

		self.isRankAnimFinished = true

		self.view:renderCloseText(true)
		self.view:changePanelStage(STAGE_BTN)

		return
	end

	self.playSteps = self.model:buildPlaySteps()

	self.model:preparePointDisplaySteps(self.playSteps)
	self:prepareProgressDurations()

	self.playIndex = 0
	self.hasProgressStarted = false
	self.hasProgressEffectStarted = false
	self.isEntranceAnimFinished = false
	self.isProgressPhaseFinished = false
	self.isProcessPhaseStarted = false
	self.isProcessPhaseFinished = false

	self:cancelEggAnimation()
	self.view:renderScoreDelta(self:getScoreDelta(), self.model:isScoreNegative())
	self:playProgressPhase(1)
	self.view:playPerformanceTagAnim(self.performanceTagCount or 0, function()
		self:onEntranceAnimFinished()
	end)
	self:playEntranceSounds()
end

function GrabEggSettlementRankCtrl:playEntranceSounds()
	local resultEvent = self.result == Const.ROB_EGG_RESULT.Failure and rankFail or rankSuccess

	pg.game.audio:playEvent(resultEvent)

	local tagCount = self.performanceTagCount or 0
	local assessDelay = tagCount > 0 and TAG_ASSESS_APPEAR_DELAY or NO_TAG_ASSESS_APPEAR_DELAY

	self:playSoundAfterDelay(assessAppear, assessDelay)

	if tagCount <= 0 then
		return
	end

	self:playSoundAfterDelay(performanceAppear, PERFORMANCE_APPEAR_DELAY)

	for index = 1, tagCount do
		local delay = POINT_FLY_FIRST_DELAY + (index - 1) * PERFORMANCE_TAG_INTERVAL

		self:playSoundAfterDelay(pointFly, delay)
	end
end

function GrabEggSettlementRankCtrl:playSoundAfterDelay(eventName, delay)
	if not delay or delay <= 0 then
		pg.game.audio:playEvent(eventName)

		return
	end

	local timerId

	timerId = self:startTimer(function()
		self.soundTimerIds[timerId] = nil

		if not self.isRankAnimFinished and not self.isFinishingRankAnim then
			pg.game.audio:playEvent(eventName)
		end
	end, delay)
	self.soundTimerIds[timerId] = true
end

function GrabEggSettlementRankCtrl:stopSoundTimers()
	for timerId in pairs(self.soundTimerIds or EMPTY_TABLE) do
		self:killTimer(timerId)
	end

	self.soundTimerIds = {}
end

function GrabEggSettlementRankCtrl:prepareProgressDurations()
	local totalDistance = 0
	local lastChangedStep

	for _, step in ipairs(self.playSteps or EMPTY_TABLE) do
		local distance = math.abs((step.toScore or 0) - (step.fromScore or 0))

		step.progressDistance = distance
		step.progressDuration = 0

		if distance > 0 then
			totalDistance = totalDistance + distance
			lastChangedStep = step
		end
	end

	if totalDistance <= 0 then
		return
	end

	local allocatedTime = 0

	for _, step in ipairs(self.playSteps) do
		if step.progressDistance > 0 then
			if step == lastChangedStep then
				step.progressDuration = math.max(0, TOTAL_PROGRESS_TIME - allocatedTime)
			else
				step.progressDuration = TOTAL_PROGRESS_TIME * step.progressDistance / totalDistance
				allocatedTime = allocatedTime + step.progressDuration
			end
		end
	end
end

function GrabEggSettlementRankCtrl:onEntranceAnimFinished()
	if self.isRankAnimFinished or self.isFinishingRankAnim then
		return
	end

	self.isEntranceAnimFinished = true

	self:tryStartProcessPhase()
end

function GrabEggSettlementRankCtrl:onProgressPhaseFinished()
	if self.hasProgressEffectStarted then
		self.view:stopProgressEffect()
	end

	self.isProgressPhaseFinished = true

	self:tryStartProcessPhase()
end

function GrabEggSettlementRankCtrl:tryStartProcessPhase()
	if self.isRankAnimFinished or self.isFinishingRankAnim or self.isProcessPhaseStarted or not self.isEntranceAnimFinished or not self.isProgressPhaseFinished then
		return
	end

	self.isProcessPhaseStarted = true

	if #(self.playSteps or {}) == 0 then
		self.isProcessPhaseFinished = true

		self:finishRankAnim()

		return
	end

	self.playIndex = 0

	self.view:changePanelStage(STAGE_PROCESS1_EGG)
	self:playNextStep()
end

function GrabEggSettlementRankCtrl:onProcessPhaseFinished()
	if self:continueWhenEggAnimationFinished(function()
		self:onProcessPhaseFinished()
	end) then
		return
	end

	self.isProcessPhaseFinished = true

	self:finishRankAnim()
end

function GrabEggSettlementRankCtrl:abortRankAnim()
	self:cancelEggAnimation()

	self.isProgressPhaseFinished = true
	self.isProcessPhaseFinished = true

	self.view:finishPerformanceTagAnim()
	self:finishRankAnim()
end

function GrabEggSettlementRankCtrl:playProgressPhase(stepIndex)
	local step = self.playSteps[stepIndex]

	if not step then
		self:onProgressPhaseFinished()

		return
	end

	local cfg = self.model:getRankConfig(step.bigRank, step.smallRank)

	if not cfg then
		self:abortRankAnim()

		return
	end

	if (step.fromScore or 0) == (step.toScore or 0) then
		self.view:renderPointScore(step.toPoint, step.toPointTotal)
		self:playProgressPhase(stepIndex + 1)

		return
	end

	local maxScore = step.maxScore or cfg.point
	local fromScore = step.fromScore or 0
	local toScore = step.toScore or 0
	local progressTime = step.progressDuration or 0
	local fxScore = fromScore < toScore and toScore or fromScore

	self.view:renderProgress(fromScore, maxScore, false, nil, nil, fxScore)
	self.view:renderPointScore(step.fromPoint, step.fromPointTotal)

	local startDelay = 0

	if not self.hasProgressStarted then
		self.hasProgressStarted = true
		startDelay = (self.performanceTagCount or 0) == 0 and NO_TAG_PROGRESS_START_DELAY or TAG_PROGRESS_START_DELAY
	end

	local function startProgress()
		if not self.hasProgressEffectStarted then
			self.hasProgressEffectStarted = true

			self.view:invokeProgressRestart()
		end

		self.view:renderProgress(toScore, maxScore, true, fromScore, progressTime, fxScore)

		local pointsEvent = (step.toScore or 0) < (step.fromScore or 0) and pointsLessen or pointsIncrease

		pg.game.audio:playEvent(pointsEvent)

		local isGain = (step.toScore or 0) > (step.fromScore or 0)

		self.view:setGlowActive(isGain)

		local function finishProgress()
			self.progressTimerId = nil

			self.view:setGlowActive(false)
			self.view:renderPointScore(step.toPoint, step.toPointTotal)
			self:playProgressPhase(stepIndex + 1)
		end

		if progressTime > 0 then
			self.progressTimerId = self:startTimer(finishProgress, progressTime)
		else
			finishProgress()
		end
	end

	if startDelay > 0 then
		self.progressTimerId = self:startTimer(function()
			self.progressTimerId = nil

			startProgress()
		end, startDelay)
	else
		startProgress()
	end
end

function GrabEggSettlementRankCtrl:playNextStep()
	local nextIndex = self.playIndex + 1
	local step = self.playSteps[nextIndex]
	local canStaggerNextEgg = step and not step.isLevelUpClear and not step.isSmallLevelChange and not step.isBigLevelChange and not self.model:isTopBigRank(step.bigRank) and (step.newEggIndex ~= nil or step.removeEggIndex ~= nil)

	if not canStaggerNextEgg and self:continueWhenEggAnimationFinished(function()
		self:playNextStep()
	end) then
		return
	end

	self.playIndex = nextIndex

	if not step then
		self:onProcessPhaseFinished()

		return
	end

	local cfg = self.model:getRankConfig(step.bigRank, step.smallRank)

	if not cfg then
		self:abortRankAnim()

		return
	end

	self:playEggStage(step, cfg)
end

function GrabEggSettlementRankCtrl:continueAfterProcess1(step)
	local hasLevelChange = step.isSmallLevelChange or step.isBigLevelChange

	if hasLevelChange and self:continueWhenEggAnimationFinished(function()
		self:playLevelStage(step)
	end) then
		return
	end

	self:playLevelStage(step)
end

function GrabEggSettlementRankCtrl:playEggStage(step, cfg)
	if step.isLevelUpClear then
		self.view:changePanelStage(STAGE_PROCESS1_EGG)
		self.view:renderEggs(self.model:buildEggStageList(cfg.upNumber, 0, nil))
		self:playLevelStage(step)

		return
	end

	local isAdd = step.newEggIndex ~= nil
	local isRemove = step.removeEggIndex ~= nil

	if not isAdd and not isRemove then
		self:continueAfterProcess1(step)

		return
	end

	if self.model:isTopBigRank(step.bigRank) then
		self:playTopEggStage(step, isAdd)

		return
	end

	self.view:changePanelStage(STAGE_PROCESS1_EGG)

	local highlightIndex = step.newEggIndex or step.removeEggIndex

	self:startEggAnimation(highlightIndex, isAdd)
	pg.game.audio:playEvent(isRemove and starLessen or starIncrease)

	self.processTimerId = self:startTimer(function()
		self.processTimerId = nil

		self:continueAfterProcess1(step)
	end, EGG_INTERVAL)
end

function GrabEggSettlementRankCtrl:startEggAnimation(eggIndex, isAdd)
	if not eggIndex then
		return
	end

	local generation = self.eggAnimationGeneration
	local hasFinished = false

	self.pendingEggAnimationCount = self.pendingEggAnimationCount + 1

	self.view:playEggAnimation(eggIndex, isAdd, function(button)
		if hasFinished then
			return
		end

		hasFinished = true

		if generation ~= self.eggAnimationGeneration or self.isRankAnimFinished or self.isFinishingRankAnim then
			return
		end

		if isAdd and button and not IsNil(button) then
			button:TryChangePage("Stage", 1)
		end

		self.pendingEggAnimationCount = math.max(0, self.pendingEggAnimationCount - 1)

		if self.pendingEggAnimationCount == 0 then
			local callback = self.afterEggAnimation

			self.afterEggAnimation = nil

			if callback then
				callback()
			end
		end
	end)
end

function GrabEggSettlementRankCtrl:continueWhenEggAnimationFinished(callback)
	if self.pendingEggAnimationCount <= 0 then
		return false
	end

	self.afterEggAnimation = callback

	return true
end

function GrabEggSettlementRankCtrl:cancelEggAnimation()
	self.eggAnimationGeneration = (self.eggAnimationGeneration or 0) + 1
	self.pendingEggAnimationCount = 0
	self.afterEggAnimation = nil
end

function GrabEggSettlementRankCtrl:playTopEggStage(step, isAdd)
	local target

	if step.isSmallLevelChange or step.isBigLevelChange then
		target = (step.fromEggNum or 0) + (isAdd and 1 or -1)
	else
		target = step.nextEggNum or step.eggNum or 0
	end

	if target < 0 then
		target = 0
	end

	self.view:changePanelStage(STAGE_PROCESS1_EGG)
	self.view:renderPointNum(target)
	pg.game.audio:playEvent(isAdd and starIncrease or starLessen)

	local generation = self.eggAnimationGeneration
	local hasFinished = false

	self.view:invokePointNumEvent(isAdd, function()
		if hasFinished or generation ~= self.eggAnimationGeneration or self.isRankAnimFinished or self.isFinishingRankAnim then
			return
		end

		hasFinished = true

		if step.isSmallLevelChange or step.isBigLevelChange then
			self:playLevelStage(step)

			return
		end

		self:playNextStep()
	end)
end

function GrabEggSettlementRankCtrl:playLevelStage(step)
	if step.isSmallLevelChange then
		self.view:changePanelStage(STAGE_PROCESS2_SMALL_LEVEL)
		self:applyLevelChange(step)

		local stageEvent = step.isLevelDownPop and stageDowngrade or stageIncrease

		pg.game.audio:playEvent(stageEvent)

		self.processTimerId = self:startTimer(function()
			self.processTimerId = nil

			self:afterLevelChange(step)
		end, SMALL_LEVEL_INTERVAL)

		return
	end

	if step.isBigLevelChange then
		self:playBigLevelStage(step)

		return
	end

	self:playNextStep()
end

function GrabEggSettlementRankCtrl:playBigLevelStage(step)
	self.view:changePanelStage(STAGE_PROCESS3_BIG_LEVEL)

	self.processTimerId = self:startTimer(function()
		self.processTimerId = nil

		self:applyLevelChange(step)

		local rankEvent = step.isLevelDownPop and rankDowngrade or rankUpgrade

		pg.game.audio:playEvent(rankEvent)

		self.processTimerId = self:startTimer(function()
			self.processTimerId = nil

			self:afterLevelChange(step)
		end, BIG_LEVEL_POST_SWITCH)
	end, BIG_LEVEL_PRE_SWITCH)
end

function GrabEggSettlementRankCtrl:afterLevelChange(step)
	self:playNextStep()
end

function GrabEggSettlementRankCtrl:applyLevelChange(step)
	local nextCfg = self.model:getRankConfig(step.nextBigRank, step.nextSmallRank)

	self:renderRankIdentity(step.nextBigRank, step.nextSmallRank, nextCfg)

	if nextCfg then
		local nextEgg = step.nextEggNum or 0

		self.view:renderEggs(self.model:buildEggStageList(nextCfg.upNumber, nextEgg, nil))
		self:applyTopRankState(step.nextBigRank, nextEgg)
	end
end

function GrabEggSettlementRankCtrl:finishRankAnim()
	if self.isRankAnimFinished or self.isFinishingRankAnim or not self.isProgressPhaseFinished or not self.isProcessPhaseFinished then
		return
	end

	self.isFinishingRankAnim = true

	self:stopPlayTimer()
	self.view:stopProgressAnim()
	self.view:setGlowActive(false)
	self:renderFinalState()

	self.finalTimerId = self:startTimer(function()
		self.finalTimerId = nil
		self.isRankAnimFinished = true
		self.isFinishingRankAnim = false

		self.view:renderCloseText(true)
		self.view:changePanelStage(STAGE_BTN)
	end, FINAL_STAGE_DELAY)
end

function GrabEggSettlementRankCtrl:stopPlayTimer()
	local timerFields = {
		"progressTimerId",
		"processTimerId",
		"finalTimerId"
	}

	for _, field in ipairs(timerFields) do
		local timerId = self[field]

		if timerId then
			self:killTimer(timerId)

			self[field] = nil
		end
	end

	self:stopSoundTimers()
end

return GrabEggSettlementRankCtrl
