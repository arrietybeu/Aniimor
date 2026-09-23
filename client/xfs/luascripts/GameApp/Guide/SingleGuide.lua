-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Guide\\SingleGuide.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local UIConst = require("Const.UIConst")
local ClientUtils = require("Utils.ClientUtils")
local Utils = require("Common.Utils.Utils")
local Time = require("Core.Common.Time")
local Class = require("Core.Framework.Class")
local guideData = require("Data.guide_data")
local SysConfigData = require("Data.sys_config_data")
local Const = require("Common.Const.Const")
local ClientConst = require("Const.ClientConst")
local GuideInputUtils = require("GameApp.Guide.GuideInputUtils")
local guideStepData = require("Data.guide_step_data")
local TimerManager = require("Core.Timer.TimerManager")
local GuideUtils = require("Utils.GuideUtils")
local logger = LoggerManager.getLogger("SingleGuide")
local SingleGuide = Class.LightClass("SingleGuide")
local Lume = require("Core.Common.lume")
local SafeCallback = require("Core.Framework.SafeCallback")
local SafeCallbackWithStatusAndReturn = require("Core.Framework.SafeCallbackWithStatusAndReturn")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local GuideTargetVisibleCheckLimitTime = 3
local GuideLockCheckLimitTime = 0.5
local GuidePlayAnimationMinTime = 0.5
local GuidePlayAnimationMaxTime = 3
local FloatingAutoFinishedTime = 0.66
local FloatingAutoHideTime = 0.17
local AIFinishedTime = 0.583
local AIHideTime = 0.083
local BerthTipFinishedTime = 0.25
local BerthTipHideTime = 0.33
local GuideGroupSkipDelay = SysConfigData.GUIDE_GROUP_SKIP_DELAY or 10
local GUIDE_NEXT_STEP_TYPES = {
	[Const.GUIDE_TYPE.GT_FOCUS] = true,
	[Const.GUIDE_TYPE.GT_FLOATING_DRAG] = true,
	[Const.GUIDE_TYPE.GT_FLOATING_AI] = true,
	[Const.GUIDE_TYPE.GT_POPUP_PANEL] = true,
	[Const.GUIDE_TYPE.GT_SPECIFIC_HIGHLIGHT] = true
}
local GUIDE_PANEL_SAME_TYPE_GROUP_ANIM_TYPES = {
	[Const.GUIDE_TYPE.GT_FLOATING_AUTO] = true,
	[Const.GUIDE_TYPE.GT_FLOATING_AI] = true
}

function SingleGuide:ctor()
	self.curGuideId = 0
	self.curGuideConfig = nil
	self.curGuideSteps = {}
	self.curStepId = nil
	self.curStepConfig = nil
end

function SingleGuide:start(guideId, stepId)
	self:initGuide(guideId, stepId)
	self:startStep()
end

function SingleGuide:initGuide(guideId, stepId)
	if not guideId then
		return
	end

	self.curGuideConfig = guideData[guideId]

	if self.curGuideConfig == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("没有引导配置", guideId)
		end

		self:finishGuide(Const.GUIDE_FINISH_REASON.COND_CHECK_FAILED)

		return
	end

	self.fullScreen = self.curGuideConfig.fullScreen or false
	self.conflictUIs = self.curGuideConfig.conflictUIs or {}

	if #self.curGuideConfig.step == 0 then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("引导%d中没有引导步骤!", guideId)
		end

		return
	end

	self.curGuidePause = false
	self.pausedStepId = nil
	self.curStepIndex = self:stepId2Index(self.curGuideConfig, stepId)
	self.curGuideId = guideId
	self.curGuideSteps = self.curGuideConfig.step
end

function SingleGuide:stepId2Index(guideCfg, stepId)
	local idx = 0

	if stepId then
		idx = Lume.find(guideCfg.step, stepId)

		if idx then
			idx = idx - 1
		else
			idx = 0
		end
	end

	return idx
end

function SingleGuide:initStep()
	self.startTime = nil
	self.isFinishingStep = false
	self.checkPassStartTime = nil
	self.focusTarget_1 = nil
	self.focusTarget_2 = nil
	self.focusTargetVisible = false
	self.currentGuidePanelArgs = nil

	self:killDelayFinishStepTimer()
	self:killTickTimer()
	self:killOneStepTimer()
	self:killCondCheckTimer()
	self:killStepTimeLimitTimer()
	self:killGroupSkipTimer()
end

function SingleGuide:startStep()
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("----开始引导", self.curGuideId, Time.realtimeSinceStartup)
	end

	self.isInGuide = true

	self:SetRaycastSimulateTestEnabled(false)
	self:executeNextStep()
end

function SingleGuide:executeNextStep()
	self:initStep()

	if self:guideStepForward() then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			logger:info("开始引导步骤", self.curStepId, Time.realtimeSinceStartup)
		end

		SafeCallback(self.onPreActiveCurrentStep, self, self.curStepConfig)

		if self.curStepConfig.type == Const.GUIDE_TYPE.GT_FOCUS or self.curStepConfig.type == Const.GUIDE_TYPE.GT_FLOATING_DRAG or self.curStepConfig.type == Const.GUIDE_TYPE.GT_SPECIFIC_HIGHLIGHT or not GuideUtils.checkStepDetailCondition(self.curStepId, self.curStepConfig) then
			self.startTime = Time.realtimeSinceStartup
			self.playAniTime = nil
			self.tickTimer = TimerManager.addRepeatTimer(0.1, function()
				self:checkTick(self.curGuideId, self.curStepId, self.curStepConfig)
			end)
		else
			self:activeCurrentStep()
		end
	else
		self:finishGuide(Const.GUIDE_FINISH_REASON.SUCESS)
	end
end

function SingleGuide:checkTick(guideId, stepId, stepCfg)
	local curTime = Time.realtimeSinceStartup
	local continueTime = curTime - self.startTime
	local limitTime = math.min(GuideTargetVisibleCheckLimitTime, stepCfg.singleStepTimeLimit or 5)

	if not self.focusTargetVisible then
		self.focusTargetVisible, self.focusTarget_1, self.focusTarget_2 = GuideUtils.checkFocusTargetVisible(stepCfg)
	end

	if not self.focusTargetVisible then
		if limitTime <= continueTime then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("限制时间内面板未显示结束清空引导", guideId, stepId, limitTime, inspect(stepCfg.directionParams))
			end

			self:skipCurrentGuide()
		end

		return
	end

	if NotNil(self.focusTarget_1) then
		local widget_1 = self.focusTarget_1:GetComponent("UWidget")
		local hasAnimationSuccess, hasAnimation = SafeCallbackWithStatusAndReturn(function()
			return NotNil(widget_1) and widget_1:HasAnimation()
		end)

		if not hasAnimationSuccess and LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("[GuideAnimationCheckFailed] guideId[%s] stepId[%s] targetIndex[1] method[HasAnimation] error[%s]", tostring(guideId), tostring(stepId), tostring(hasAnimation))
		end

		if hasAnimationSuccess and hasAnimation then
			if self.playAniTime == nil then
				self.playAniTime = curTime
			end

			local elapsed = curTime - self.playAniTime

			if elapsed < GuidePlayAnimationMinTime then
				return
			end

			local isPlayingSuccess, isPlaying = SafeCallbackWithStatusAndReturn(function()
				return widget_1:IsPlayingAnimation()
			end)

			if not isPlayingSuccess and LoggerManager.checkLogger(LoggerConst.WARN) then
				logger:warn("[GuideAnimationCheckFailed] guideId[%s] stepId[%s] targetIndex[1] method[IsPlayingAnimation] error[%s]", tostring(guideId), tostring(stepId), tostring(isPlaying))
			end

			if isPlayingSuccess and isPlaying and elapsed < GuidePlayAnimationMaxTime then
				return
			end
		end
	end

	if NotNil(self.focusTarget_2) then
		local widget_2 = self.focusTarget_2:GetComponent("UWidget")
		local hasAnimationSuccess, hasAnimation = SafeCallbackWithStatusAndReturn(function()
			return NotNil(widget_2) and widget_2:HasAnimation()
		end)

		if not hasAnimationSuccess and LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("[GuideAnimationCheckFailed] guideId[%s] stepId[%s] targetIndex[2] method[HasAnimation] error[%s]", tostring(guideId), tostring(stepId), tostring(hasAnimation))
		end

		if hasAnimationSuccess and hasAnimation then
			if self.playAniTime == nil then
				self.playAniTime = curTime
			end

			local elapsed = curTime - self.playAniTime

			if elapsed < GuidePlayAnimationMinTime then
				return
			end

			local isPlayingSuccess, isPlaying = SafeCallbackWithStatusAndReturn(function()
				return widget_2:IsPlayingAnimation()
			end)

			if not isPlayingSuccess and LoggerManager.checkLogger(LoggerConst.WARN) then
				logger:warn("[GuideAnimationCheckFailed] guideId[%s] stepId[%s] targetIndex[2] method[IsPlayingAnimation] error[%s]", tostring(guideId), tostring(stepId), tostring(isPlaying))
			end

			if isPlayingSuccess and isPlaying and elapsed < GuidePlayAnimationMaxTime then
				return
			end
		end
	end

	self:killTickTimer()
	self:afterPassUIVisibleCheck(stepId, stepCfg)
end

function SingleGuide:killTickTimer()
	if self.tickTimer then
		TimerManager.removeTimer(self.tickTimer)

		self.tickTimer = nil
	end
end

function SingleGuide:getTimerRemain(startTime, duration)
	if startTime == nil or duration == nil then
		return nil
	end

	return math.max(0, duration - (Time.realtimeSinceStartup - startTime))
end

function SingleGuide:hasFullScreenPauseUI()
	if self.fullScreenPauseUIs == nil then
		return false
	end

	for _, paused in pairs(self.fullScreenPauseUIs) do
		if paused then
			return true
		end
	end

	return false
end

function SingleGuide:updateGuidePanelCountDownArgs(args)
	if args == nil or args.isCountDown ~= true then
		return
	end

	local timeRemain = self:getTimerRemain(self.singleStepTimeLimitTimerStartTime, self.singleStepTimeLimitTimerDuration) or self:getTimerRemain(self.oneStepTimerStartTime, self.oneStepTimerDuration)

	if timeRemain ~= nil then
		args.countDownTime = timeRemain
	end
end

function SingleGuide:pauseByFullScreenUI(uid)
	if uid == nil then
		return
	end

	self.fullScreenPauseUIs = self.fullScreenPauseUIs or {}

	if not self:hasFullScreenPauseUI() then
		self.curGuidePause = true

		self:killGroupSkipTimer()
		self:closeGuidePanel(self.curStepConfig)
		pg.game.input:setBlockEventWithWhiteList(ClientConst.BlockNoneUIEventKey.Guide, false)
	end

	self.fullScreenPauseUIs[uid] = true
end

function SingleGuide:resumeByFullScreenUI(uid)
	if self.fullScreenPauseUIs == nil or not self.fullScreenPauseUIs[uid] then
		return
	end

	self.fullScreenPauseUIs[uid] = nil

	if self:hasFullScreenPauseUI() then
		return
	end

	self.fullScreenPauseUIs = nil
	self.curGuidePause = false

	if self.currentGuidePanelArgs ~= nil and self.curStepConfig ~= nil then
		self:showGuidePanel(self.currentGuidePanelArgs)
		self:refreshGroupSkipTimer()
	end
end

function SingleGuide:afterPassUIVisibleCheck(stepId, stepCfg)
	if not GuideUtils.checkStepDetailCondition(stepId, stepCfg) then
		self:skipCurrentGuide()

		return
	end

	self:activeCurrentStep()
end

function SingleGuide:onPreActiveCurrentStep(stepCfg)
	if stepCfg.force == 1 then
		pg.game.input:setBlockEventWithWhiteList(ClientConst.BlockNoneUIEventKey.Guide, true, self:getForceTakeOverWhiteList(stepCfg))

		if not self.keepBlackMaskForNext and stepCfg.type ~= Const.GUIDE_TYPE.GT_POPUP_PANEL then
			self:showGuidePanel({
				showMask = true
			})
		end
	else
		pg.game.input:setBlockEventWithWhiteList(ClientConst.BlockNoneUIEventKey.Guide, false)
	end
end

function SingleGuide:activeCurrentStep()
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("activeCurrentStep", self.curGuideId, self.curStepId)
	end

	GuideUtils.setCameraBlendToFixed(self.curStepConfig)

	local function onCloseGuideStep(stepId, reason)
		if self.curStepId == stepId then
			reason = reason or Const.GUIDE_STEP_FINISH_REASON.CLICK_BTN

			self:finishStep(reason)
		end
	end

	if self.curStepConfig.type == Const.GUIDE_TYPE.GT_FOCUS or self.curStepConfig.type == Const.GUIDE_TYPE.GT_SPECIFIC_HIGHLIGHT then
		if not self:showFocusDirectionInfo(self.curStepConfig) then
			self:skipCurrentGuide()

			return
		end
	elseif self.curStepConfig.type == Const.GUIDE_TYPE.GT_FLOATING_AUTO then
		local isCountDown = self.curStepConfig.stepOneTime ~= nil
		local countDownTime = self.curStepConfig.stepOneTime

		if self.curStepConfig.endCheck ~= nil then
			for i = 1, #self.curStepConfig.endCheck do
				local endCheck = self.curStepConfig.endCheck[i]

				if endCheck == Const.GUIDE_STEP_END.GSC_COUNT_DOWN then
					local endCheckArg = self.curStepConfig.endCheckArg[i]

					if type(endCheckArg) == "table" then
						countDownTime = endCheckArg[1]
					else
						countDownTime = endCheckArg
					end

					isCountDown = true
				end
			end
		end

		local args = {}

		args.guideId = self.curGuideId
		args.stepId = self.curStepId
		args.msg = self.curStepConfig.msg
		args.isCountDown = isCountDown
		args.countDownTime = countDownTime
		args.onCloseGuideStep = onCloseGuideStep

		self:showGuidePanel(args)
	elseif self.curStepConfig.type == Const.GUIDE_TYPE.GT_FLOATING_DRAG then
		if not self:showDragDirectionInfo(self.curStepConfig) then
			self:skipCurrentGuide()

			return
		end
	elseif self.curStepConfig.type == Const.GUIDE_TYPE.GT_FLOATING_AI then
		self:showGuidePanel({
			guideId = self.curGuideId,
			stepId = self.curStepId,
			onCloseGuideStep = onCloseGuideStep
		})
	elseif self.curStepConfig.type == Const.GUIDE_TYPE.GT_POPUP_PANEL then
		local arg = {}

		arg.guideId = self.curGuideId
		arg.stepId = self.curStepId

		function arg.onSkipGroup()
			self:onSkipGroup()
		end

		function arg.isNextStepEnabled(stepCfg)
			return self:isNextStepEnabled(stepCfg or self.curStepConfig)
		end

		arg.canSkipGroup = self:canSkipGroup(self.curStepConfig)

		pg.global.ui:show(UIConst.UI_ID_GUIDE_POPUP_PANEL)
		pg.global.ui:open(UIConst.UI_ID_GUIDE_POPUP_PANEL, arg)
	end

	if self:isNextStepEnabled(self.curStepConfig) and LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("开启【下一步】功能键", self.curGuideId, self.curStepId, self:getNextStepActionPath())
	end

	if self.curStepConfig.static ~= nil then
		GuideUtils.setGameTime(self.curStepConfig.static)
	end

	GuideUtils.exeCustomFunc(self.curStepConfig)
	self:refreshEndOneStep(self.curStepConfig)
	self:refreshEndCheck(self.curStepConfig)
	self:refreshGroupSkipTimer()
end

function SingleGuide:canSkipGroup(stepCfg)
	if self.curGuideConfig == nil or self.curGuideConfig.notSkipGroup == 1 then
		return false
	end

	if stepCfg == nil or stepCfg.pressBlack ~= 1 then
		return false
	end

	return not table.contains(stepCfg.endCheck or {}, Const.GUIDE_STEP_END.GSC_COUNT_DOWN)
end

function SingleGuide:refreshGroupSkipTimer()
	self:killGroupSkipTimer()

	if not self:canSkipGroup(self.curStepConfig) or GuideGroupSkipDelay < 0 then
		return
	end

	local guideId = self.curGuideId
	local stepId = self.curStepId

	self.groupSkipTimer = TimerManager.addTimer(GuideGroupSkipDelay, function()
		self.groupSkipTimer = nil

		if not self.isInGuide or self.curGuideId ~= guideId or self.curStepId ~= stepId or self.curGuidePause then
			return
		end

		self.groupSkipEnabled = true

		if self.curStepConfig.force == 1 then
			pg.game.input:setBlockEventWithWhiteList(ClientConst.BlockNoneUIEventKey.Guide, true, self:getForceTakeOverWhiteList(self.curStepConfig))
		end

		if LoggerManager.checkLogger(LoggerConst.INFO) then
			logger:info("[GuideGroupSkip] enabled", guideId, stepId, GuideGroupSkipDelay)
		end

		if self.curStepConfig.type == Const.GUIDE_TYPE.GT_POPUP_PANEL and pg.global.ui.guidePopupPanel then
			pg.global.ui.guidePopupPanel:showGroupSkip()
		elseif pg.global.ui.guidePanel then
			pg.global.ui.guidePanel:showGroupSkip()
		else
			logger:info("[GuideGroupSkip] guide UI is unavailable", guideId, stepId, self.curStepConfig.type)
		end
	end)
end

function SingleGuide:killGroupSkipTimer()
	if self.groupSkipTimer then
		TimerManager.removeTimer(self.groupSkipTimer)

		self.groupSkipTimer = nil
	end

	self.groupSkipEnabled = false
end

function SingleGuide:onSkipGroup()
	if not self.groupSkipEnabled or not self:canSkipGroup(self.curStepConfig) then
		return
	end

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("[GuideGroupSkip] skip group", self.curGuideId, self.curStepId)
	end

	self:skipCurrentGuide(Const.GUIDE_FINISH_REASON.SKIP)
end

function SingleGuide:finishStep(reason, checkFinish)
	if self.isFinishingStep and checkFinish == nil then
		return
	end

	self.isFinishingStep = true

	GuideUtils.setGameTime(1)

	local sameTypeGroupInfo = self:getSameTypeStepGroupInfo()
	local isSameTypeAnimGroup = sameTypeGroupInfo ~= nil and sameTypeGroupInfo.canPlayPanelAnim
	local finishedTime, hideTime = self:getFinishedAnimTiming(self.curStepConfig)

	if checkFinish ~= true and reason ~= Const.GUIDE_STEP_FINISH_REASON.TIME_LIMIT and finishedTime > 0 then
		local finishingStepId = self.curStepId
		local shouldPlayHide = not isSameTypeAnimGroup or sameTypeGroupInfo.isLastStep

		if pg.global.ui.guidePanel then
			pg.global.ui.guidePanel:playFinishedState()
		end

		self:killDelayFinishStepTimer()

		self.delayFinStepTimer = TimerManager.addTimer(finishedTime, function()
			self.delayFinStepTimer = nil

			if self.curStepId ~= finishingStepId then
				return
			end

			if shouldPlayHide and hideTime > 0 and pg.global.ui.guidePanel and pg.global.ui.guidePanel:playHide() then
				self.delayFinStepTimer = TimerManager.addTimer(hideTime, function()
					self.delayFinStepTimer = nil

					if self.curStepId == finishingStepId then
						self:finishStep(reason, true)
					end
				end)

				return
			end

			self:finishStep(reason, true)
		end)

		return
	end

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("结束引导步骤", self.curStepId, Time.realtimeSinceStartup, reason, debug.traceback())
	end

	if GuideUtils.endCheckContains(self.curStepConfig, Const.GUIDE_STEP_END.GSC_FINISH_COND) then
		local endArg = self:getEndCheckArg(self.curStepConfig, Const.GUIDE_STEP_END.GSC_FINISH_COND)

		if endArg ~= nil then
			pg.me:unregisterGuideTrigger(endArg)
			self:killCondCheckTimer()
		end
	end

	GuideUtils.resetCameraBlendToFixed(self.curStepConfig)

	local nextCfg = self:peekNextStepConfig()

	self.keepBlackMaskForNext = self:shouldKeepBlackMask(self.curStepConfig, nextCfg)

	local keepSameTypePanelForNext = sameTypeGroupInfo ~= nil and sameTypeGroupInfo.canPlayPanelAnim and not sameTypeGroupInfo.isLastStep

	self:hideGuidePanel(self.curStepConfig, self.keepBlackMaskForNext or keepSameTypePanelForNext)

	if self.guideTopTipParam then
		if self.guideTopTipParam.finishInvoke then
			self.guideTopTipParam:finishInvoke()
		end

		self.guideTopTipParam = nil
	end

	self:executeNextStep()
end

function SingleGuide:eventfinishStep(stepId)
	if self.curStepConfig == nil or self.curStepId ~= stepId then
		return
	end

	self:finishStep(Const.GUIDE_STEP_FINISH_REASON.EVENT)
end

function SingleGuide:showFocusDirectionInfo(stepCfg)
	if stepCfg.directionMethod == Const.GUIDE_DIRECTION_TYPE.GUIDE_PORINT_TYPE_CONTROL then
		if stepCfg.directionParams == nil then
			return true
		end

		if IsNil(self.focusTarget_1) then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("未找到对应的控件！", self.curStepId, inspect(stepCfg.directionParams))
			end

			return false
		end

		local function onCloseGuideStep(stepId)
			if self.curStepId == stepId then
				self:finishStep(Const.GUIDE_STEP_FINISH_REASON.CLICK_BTN)
			end
		end

		local function onIncorrectCloseGuide(stepId)
			if self.curStepId == stepId and self.isFinishingStep then
				if LoggerManager.checkLogger(LoggerConst.INFO) then
					logger:info("[GuideFocusTarget] ignore target lost while step is finishing", self.curGuideId, stepId)
				end

				return
			end

			if self:isFocusTargetUIClosing(stepCfg) then
				if LoggerManager.checkLogger(LoggerConst.INFO) then
					logger:info("[GuideFocusTarget] ignore target lost while target UI is closing", self.curGuideId, stepId, GuideUtils.getPanelId(stepCfg))
				end

				return
			end

			self:skipCurrentGuide(Const.GUIDE_FINISH_REASON.FOCUS_TARGET_LOSE)
		end

		local arg = {}

		arg.guideId = self.curGuideId
		arg.stepId = self.curStepId
		arg.targetBtnTrans = self.focusTarget_1
		arg.addClickLinstener = GuideUtils.endCheckContains(self.curStepConfig, Const.GUIDE_STEP_END.GSC_CLICK_BTN)
		arg.onCloseGuideStep = onCloseGuideStep
		arg.onIncorrectCloseGuide = onIncorrectCloseGuide
		arg.maskAnimType = self:getMaskAnimType(self.keepBlackMaskForNext)
		self.keepBlackMaskForNext = nil

		self:showGuidePanel(arg)
	end

	return true
end

function SingleGuide:isFocusTargetUIClosing(stepCfg)
	if stepCfg == nil or not GuideUtils.endCheckContains(stepCfg, Const.GUIDE_STEP_END.GSC_CLOSE_UI) then
		return false
	end

	local closeUIId = self:getEndCheckArg(stepCfg, Const.GUIDE_STEP_END.GSC_CLOSE_UI)

	if closeUIId == nil or closeUIId ~= GuideUtils.getPanelId(stepCfg) then
		return false
	end

	local uiCtrl = pg.global.ui:tryGetCtrlByUid(closeUIId)

	if uiCtrl == nil then
		return false
	end

	if uiCtrl.checkUIClosing ~= nil and uiCtrl:checkUIClosing() then
		return true
	end

	return uiCtrl.isCloseing == true
end

function SingleGuide:showDragDirectionInfo(stepCfg)
	if stepCfg.directionMethod == Const.GUIDE_DIRECTION_TYPE.GUIDE_PORINT_TYPE_CONTROL then
		if stepCfg.directionParams == nil then
			return true
		end

		if IsNil(self.focusTarget_1) then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("未找到对应的控件！", self.curStepId, inspect(stepCfg.directionParams[1]))
			end

			return false
		end

		if IsNil(self.focusTarget_2) then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("未找到对应的控件！", self.curStepId, inspect(stepCfg.directionParams[2]))
			end

			return false
		end

		local function onCloseGuideStep(stepId)
			if self.curStepId == stepId then
				self:finishStep(Const.GUIDE_STEP_FINISH_REASON.CLICK_BTN)
			end
		end

		self:showGuidePanel({
			guideId = self.curGuideId,
			stepId = self.curStepId,
			targetBtnTransStart = self.focusTarget_1,
			targetBtnTransEnd = self.focusTarget_2,
			maskAnimType = self:getMaskAnimType(self.keepBlackMaskForNext),
			onCloseGuideStep = onCloseGuideStep
		})

		self.keepBlackMaskForNext = nil
	end

	return true
end

function SingleGuide:skipCurrentGuide(reason)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("跳过当前引导", self.curGuideId, self.curStepId, reason)
	end

	self:finishGuide(reason or Const.GUIDE_FINISH_REASON.SKIP)
end

function SingleGuide:closeCurrentGuide()
	self:closeGuide()
end

function SingleGuide:refreshEndOneStep(stepCfg)
	if not GuideUtils.canEnterTwoStep(stepCfg) then
		return
	end

	self.oneStepTimer = TimerManager.addTimer(stepCfg.stepOneTime, function()
		self.oneStepTimer = nil
		self.oneStepTimerStartTime = nil
		self.oneStepTimerDuration = nil

		GuideUtils.setGameTime(0)

		local whiteList

		if table.contains(stepCfg.endCheck, Const.GUIDE_STEP_END.GSC_INPUT_TRIGGERED) then
			whiteList = self:getInputTriggeredWhiteList(stepCfg)
		end

		whiteList = whiteList or {}

		if not self:isMobilePlatform() then
			local nextStepAction = self:getNextStepActionPath()

			if self:isNextStepEnabled(stepCfg) and not table.contains(whiteList, nextStepAction) then
				table.insert(whiteList, nextStepAction)
			end

			if self:canSkipGroup(stepCfg) then
				if not table.contains(whiteList, GuideInputUtils.GROUP_SKIP_KEYBOARD_ACTION) then
					table.insert(whiteList, GuideInputUtils.GROUP_SKIP_KEYBOARD_ACTION)
				end

				if not table.contains(whiteList, GuideInputUtils.GROUP_SKIP_GAMEPAD_ACTION) then
					table.insert(whiteList, GuideInputUtils.GROUP_SKIP_GAMEPAD_ACTION)
				end
			end
		end

		pg.game.input:setBlockEventWithWhiteList(ClientConst.BlockNoneUIEventKey.Guide, true, whiteList)
		self:showGuidePanel({
			toastGuidePanel = true,
			guideId = self.curGuideId,
			stepId = self.curStepId
		})
	end)
	self.oneStepTimerStartTime = Time.realtimeSinceStartup
	self.oneStepTimerDuration = stepCfg.stepOneTime
end

function SingleGuide:getForceTakeOverWhiteList(stepCfg)
	local whiteList = {}

	if stepCfg.endCheck ~= nil and GuideUtils.endCheckContains(stepCfg, Const.GUIDE_STEP_END.GSC_INPUT_TRIGGERED) then
		whiteList = self:getInputTriggeredWhiteList(stepCfg) or {}
	end

	table.insert(whiteList, "Camera/ShowCursor")

	if self.groupSkipEnabled and self:canSkipGroup(stepCfg) and not self:isMobilePlatform() then
		if not table.contains(whiteList, GuideInputUtils.GROUP_SKIP_KEYBOARD_ACTION) then
			table.insert(whiteList, GuideInputUtils.GROUP_SKIP_KEYBOARD_ACTION)
		end

		if not table.contains(whiteList, GuideInputUtils.GROUP_SKIP_GAMEPAD_ACTION) then
			table.insert(whiteList, GuideInputUtils.GROUP_SKIP_GAMEPAD_ACTION)
		end
	end

	if stepCfg.action then
		table.insert(whiteList, stepCfg.action)
	end

	if stepCfg.type == Const.GUIDE_TYPE.GT_FLOATING_AI or stepCfg.type == Const.GUIDE_TYPE.GT_POPUP_PANEL then
		table.insert(whiteList, "Common/MouseLeftButton")
	end

	if not self:isMobilePlatform() then
		local nextStepAction = self:getNextStepActionPath()

		if self:isNextStepEnabled(stepCfg) and not table.contains(whiteList, nextStepAction) then
			table.insert(whiteList, nextStepAction)
		end
	end

	if self:isNextStepEnabled(stepCfg) and not pg.game.input:isUsingGamepad() and not table.contains(whiteList, "Common/MouseLeftButton") then
		table.insert(whiteList, "Common/MouseLeftButton")
	end

	return whiteList
end

function SingleGuide:refreshEndCheck(stepCfg)
	local endCheckList = stepCfg.endCheck

	if endCheckList == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("引导没有配结束参数", self.curStepId)
		end

		return
	end

	for i = 1, #endCheckList do
		local endCheck = endCheckList[i]
		local endArg = stepCfg.endCheckArg[i]

		if endCheck == Const.GUIDE_STEP_END.GSC_COUNT_DOWN then
			if endArg ~= nil then
				local countDownTime

				if Utils.isTable(endArg) then
					countDownTime = endArg[1]
				else
					countDownTime = endArg
				end

				self:killStepTimeLimitTimer()

				self.singleStepTimeLimitTimer = TimerManager.addTimer(countDownTime, function()
					self.singleStepTimeLimitTimer = nil
					self.singleStepTimeLimitTimerStartTime = nil
					self.singleStepTimeLimitTimerDuration = nil

					self:finishStep(Const.GUIDE_STEP_FINISH_REASON.TIME_LIMIT)
				end)
				self.singleStepTimeLimitTimerStartTime = Time.realtimeSinceStartup
				self.singleStepTimeLimitTimerDuration = countDownTime
			elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("引导步骤的结束参数没填！", self.curStepId)
			end
		elseif endCheck == Const.GUIDE_STEP_END.GSC_CLICK_BTN then
			-- block empty
		elseif endCheck == Const.GUIDE_STEP_END.GSC_INPUT_DRAG then
			-- block empty
		elseif endCheck == Const.GUIDE_STEP_END.GSC_FINISH_COND and endArg ~= nil then
			local curStepId = self.curStepId

			pg.me:registerGuideTrigger(endArg)

			self.stepCondCheckTimer = self.stepCondCheckTimer or {}
			self.stepCondCheckTimer[i] = TimerManager.addRepeatTimer(0.5, function()
				if self.curStepId ~= curStepId then
					self:killCondCheckTimer()

					return
				end

				if pg.me.triggerMap:isCompleteOrMeetCondition(endArg) then
					self:killCondCheckTimer()
					self:finishStep(Const.GUIDE_STEP_FINISH_REASON.TRIGGER_MEET)
				end
			end)
		end
	end

	local timeLimit = stepCfg.singleStepTimeLimit

	if timeLimit ~= nil and timeLimit > 0 and self.singleStepTimeLimitTimer == nil then
		self.singleStepTimeLimitTimer = TimerManager.addTimer(timeLimit, function()
			self:skipCurrentGuide()
		end)
	end
end

function SingleGuide:killOneStepTimer()
	if self.oneStepTimer then
		TimerManager.removeTimer(self.oneStepTimer)

		self.oneStepTimer = nil
	end

	self.oneStepTimerStartTime = nil
	self.oneStepTimerDuration = nil
end

function SingleGuide:killStepTimeLimitTimer()
	if self.singleStepTimeLimitTimer then
		TimerManager.removeTimer(self.singleStepTimeLimitTimer)

		self.singleStepTimeLimitTimer = nil
	end

	self.singleStepTimeLimitTimerStartTime = nil
	self.singleStepTimeLimitTimerDuration = nil
end

function SingleGuide:killCondCheckTimer()
	if self.stepCondCheckTimer then
		for i = 1, #self.stepCondCheckTimer do
			TimerManager.removeTimer(self.stepCondCheckTimer[i])
		end
	end

	self.stepCondCheckTimer = nil
end

function SingleGuide:onOpenUI(uid)
	if self.curStepConfig == nil then
		return
	end

	local uiConfig = UIConst.UI_CONFIGS[uid]

	if self:hasFullScreenPauseUI() then
		if uiConfig ~= nil and uiConfig.fullScreen == true and self.fullScreen == true then
			self:pauseByFullScreenUI(uid)
		end

		return
	end

	if GuideUtils.endCheckContains(self.curStepConfig, Const.GUIDE_STEP_END.GSC_OPEN_UI) and self:getEndCheckArg(self.curStepConfig, Const.GUIDE_STEP_END.GSC_OPEN_UI) == uid then
		self:finishStep(Const.GUIDE_STEP_FINISH_REASON.OPEN_UI)

		return
	end

	if uiConfig ~= nil and uiConfig.fullScreen == true and self.fullScreen == true then
		self:pauseByFullScreenUI(uid)

		return
	end

	if table.contains(self.conflictUIs, uid) then
		self:skipCurrentGuide()

		return
	end
end

function SingleGuide:onCloseUI(uid)
	if self.curStepConfig == nil then
		return
	end

	local resumeFullScreenPause = self.fullScreenPauseUIs ~= nil and self.fullScreenPauseUIs[uid] == true

	if resumeFullScreenPause then
		self:resumeByFullScreenUI(uid)

		return
	end

	if self:hasFullScreenPauseUI() then
		return
	end

	if GuideUtils.endCheckContains(self.curStepConfig, Const.GUIDE_STEP_END.GSC_CLOSE_UI) and self:getEndCheckArg(self.curStepConfig, Const.GUIDE_STEP_END.GSC_CLOSE_UI) == uid then
		self:finishStep(Const.GUIDE_STEP_FINISH_REASON.CLOSE_UI)
	end
end

function SingleGuide:onUIVisibleChange(arg)
	if self:hasFullScreenPauseUI() then
		return
	end

	self:checkGuideVisible(arg.uid)
end

function SingleGuide:onInputActionTriggered(arg)
	if self.curStepConfig == nil then
		return
	end

	if self:hasFullScreenPauseUI() then
		return
	end

	local inputActionPath = string.format("%s/%s", arg.inputInfo.actionMapName, arg.inputInfo.actionName)

	if self.groupSkipEnabled and not pg.game.input:isUsingGamepad() and inputActionPath == GuideInputUtils.GROUP_SKIP_KEYBOARD_ACTION then
		self:onSkipGroup()

		return
	end

	if GuideUtils.endCheckContains(self.curStepConfig, Const.GUIDE_STEP_END.GSC_INPUT_TRIGGERED) and self:containsAction(self:getEndCheckArg(self.curStepConfig, Const.GUIDE_STEP_END.GSC_INPUT_TRIGGERED), inputActionPath) then
		self:finishStep(Const.GUIDE_STEP_FINISH_REASON.ACTION_TRIGGERED)

		return
	end

	if inputActionPath == self:getNextStepActionPath() then
		self:tryNextStep()
	end
end

function SingleGuide:onVirtualMouseConfirm()
	if self.curStepConfig == nil or self:hasFullScreenPauseUI() then
		return false
	end

	local actionPath = GuideInputUtils.NEXT_STEP_GAMEPAD_ACTION

	if GuideUtils.endCheckContains(self.curStepConfig, Const.GUIDE_STEP_END.GSC_INPUT_TRIGGERED) and self:containsAction(self:getEndCheckArg(self.curStepConfig, Const.GUIDE_STEP_END.GSC_INPUT_TRIGGERED), actionPath) then
		self:finishStep(Const.GUIDE_STEP_FINISH_REASON.ACTION_TRIGGERED)

		return true
	end

	if actionPath == self:getNextStepActionPath() then
		return self:tryNextStep()
	end

	return false
end

function SingleGuide:containsAction(guideActionPath, inputActionPath)
	if guideActionPath == nil then
		return false
	end

	if Utils.isTable(guideActionPath) then
		return table.contains(guideActionPath, inputActionPath)
	else
		return guideActionPath == inputActionPath
	end
end

function SingleGuide:onInputDeviceChanged(deviceType)
	if self.curStepConfig ~= nil and self.curStepConfig.force == 1 then
		pg.game.input:setBlockEventWithWhiteList(ClientConst.BlockNoneUIEventKey.Guide, true, self:getForceTakeOverWhiteList(self.curStepConfig))
	end
end

function SingleGuide:checkGuideVisible(uid)
	if self.curStepId == nil or self.curStepConfig == nil then
		return
	end

	if self.curStepConfig.type == Const.GUIDE_TYPE.GT_FLOATING_AUTO then
		-- block empty
	elseif self.curStepConfig.directionMethod == Const.GUIDE_DIRECTION_TYPE.GUIDE_PORINT_TYPE_CONTROL or self.curStepConfig.directionMethod == Const.GUIDE_DIRECTION_TYPE.GUIDE_PORINT_TYPE_ITEM then
		local visible = GuideUtils.checkUIVisible(self.curStepConfig, true)

		self:pauseGuide(not visible)
	end
end

function SingleGuide:pauseGuide(pause)
	if self.curGuidePause ~= pause then
		self.curGuidePause = pause

		if pg.global.ui:checkUIVisible(UIConst.UI_ID_GUIDE_PANEL) then
			pg.global.ui.guidePanel:pauseGuide(pause)
		end

		if pause then
			self.pausedStepId = self.curStepId

			self:killGroupSkipTimer()
			pg.global.ui:hide(UIConst.UI_ID_GUIDE_PANEL)
		else
			local pausedStepId = self.pausedStepId

			self.pausedStepId = nil

			if pausedStepId == self.curStepId then
				self:restartCurrentStep()
			end
		end
	end
end

function SingleGuide:restartCurrentStep()
	if self.curStepIndex == nil or self.curStepIndex <= 0 or self.curStepConfig == nil then
		return
	end

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("[Guide] restart current step after target UI restored", self.curGuideId, self.curStepId)
	end

	self:closeGuidePanel(self.curStepConfig)

	self.curStepIndex = self.curStepIndex - 1

	self:executeNextStep()
end

function SingleGuide:rallBackStep()
	if not self.rallBackNum then
		self.rallBackNum = 1
	else
		self.rallBackNum = self.rallBackNum + 1
	end

	if self.rallBackNum and self.rallBackNum > 50 then
		self.rallBackNum = nil

		self:skipCurrentGuide()

		return
	end

	self:closeGuidePanel()
	self:initStep(self.curGuideId)
end

function SingleGuide:closeGuide(reason)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("---结束当前引导 ", reason, self.curStepId, Time.realtimeSinceStartup)
	end

	self.isInGuide = false

	self:SetRaycastSimulateTestEnabled(true)
	GuideUtils.setGameTime()
	self:closeGuidePanel(self.curStepConfig)
	GuideUtils.resetCameraBlendToFixed(self.curStepConfig)
	pg.game.input:setBlockEventWithWhiteList(ClientConst.BlockNoneUIEventKey.Guide, false)
	self:clearData()
end

function SingleGuide:finishGuide(reason)
	self:closeGuide(reason)
	self.onFinishGuide(self.curGuideId, reason)
end

function SingleGuide:showGuidePanel(args)
	local panelArgs = Utils.deepCopyTable(args)

	panelArgs.sameTypeStepGroupInfo = self:getSameTypeStepGroupInfo()
	self.currentGuidePanelArgs = Utils.deepCopyTable(panelArgs)

	if self:hasFullScreenPauseUI() then
		pg.game.input:setBlockEventWithWhiteList(ClientConst.BlockNoneUIEventKey.Guide, false)

		return
	end

	panelArgs = Utils.deepCopyTable(self.currentGuidePanelArgs)

	function panelArgs.isNextStepEnabled(stepCfg)
		return self:isNextStepEnabled(stepCfg or self.curStepConfig)
	end

	function panelArgs.onNextStep()
		return self:tryNextStep()
	end

	function panelArgs.onVirtualMouseConfirm()
		return self:onVirtualMouseConfirm()
	end

	function panelArgs.onSkipGroup()
		self:onSkipGroup()
	end

	panelArgs.canSkipGroup = self:canSkipGroup(self.curStepConfig)

	self:updateGuidePanelCountDownArgs(panelArgs)
	pg.global.ui:show(UIConst.UI_ID_GUIDE_PANEL)
	pg.global.ui:open(UIConst.UI_ID_GUIDE_PANEL, panelArgs)
end

function SingleGuide:hideGuidePanel(stepCfg, keepBlackMask)
	if pg.global.ui.guidePanel then
		pg.global.ui.guidePanel:finshGuideStep()
	end

	if not keepBlackMask then
		self.currentGuidePanelArgs = nil

		pg.global.ui:hide(UIConst.UI_ID_GUIDE_PANEL)
	end

	pg.global.ui:close(UIConst.UI_ID_GUIDE_POPUP_PANEL)
end

function SingleGuide:peekNextStepConfig()
	if self.curGuideSteps == nil or self.curStepIndex == nil then
		return nil
	end

	for i = self.curStepIndex + 1, #self.curGuideSteps do
		local stepCfg = guideStepData[self.curGuideSteps[i]]

		if stepCfg ~= nil and GuideUtils.checkPlatformLimit(stepCfg) then
			return stepCfg
		end
	end

	return nil
end

function SingleGuide:getSameTypeStepGroupInfo(stepIndex)
	stepIndex = stepIndex or self.curStepIndex

	if self.curGuideSteps == nil or stepIndex == nil then
		return nil
	end

	local stepId = self.curGuideSteps[stepIndex]
	local stepCfg = guideStepData[stepId]

	if stepCfg == nil or not GuideUtils.checkPlatformLimit(stepCfg) then
		return nil
	end

	local firstIndex = stepIndex
	local lastIndex = stepIndex

	for i = stepIndex - 1, 1, -1 do
		local prevCfg = guideStepData[self.curGuideSteps[i]]

		if prevCfg ~= nil and GuideUtils.checkPlatformLimit(prevCfg) then
			if prevCfg.type ~= stepCfg.type then
				break
			end

			firstIndex = i
		end
	end

	for i = stepIndex + 1, #self.curGuideSteps do
		local nextCfg = guideStepData[self.curGuideSteps[i]]

		if nextCfg ~= nil and GuideUtils.checkPlatformLimit(nextCfg) then
			if nextCfg.type ~= stepCfg.type then
				break
			end

			lastIndex = i
		end
	end

	local stepIds = {}

	for i = firstIndex, lastIndex do
		local groupStepId = self.curGuideSteps[i]
		local groupStepCfg = guideStepData[groupStepId]

		if groupStepCfg ~= nil and GuideUtils.checkPlatformLimit(groupStepCfg) then
			table.insert(stepIds, groupStepId)
		end
	end

	return {
		type = stepCfg.type,
		firstStepId = stepIds[1],
		lastStepId = stepIds[#stepIds],
		stepIds = stepIds,
		isGroup = #stepIds > 1,
		canPlayPanelAnim = #stepIds > 1 and GUIDE_PANEL_SAME_TYPE_GROUP_ANIM_TYPES[stepCfg.type] == true,
		isFirstStep = stepIndex == firstIndex,
		isLastStep = stepIndex == lastIndex
	}
end

function SingleGuide:shouldKeepBlackMask(curCfg, nextCfg)
	if curCfg == nil or nextCfg == nil then
		return false
	end

	local function isBlackMaskStep(cfg)
		if cfg.pressBlack ~= 1 then
			return false
		end

		return cfg.type == Const.GUIDE_TYPE.GT_FOCUS or cfg.type == Const.GUIDE_TYPE.GT_SPECIFIC_HIGHLIGHT or cfg.type == Const.GUIDE_TYPE.GT_FLOATING_DRAG
	end

	return isBlackMaskStep(curCfg) and isBlackMaskStep(nextCfg)
end

function SingleGuide:getMaskAnimType(keepBlackMask)
	if keepBlackMask then
		return CS.XGUI.EGuideMaskAnimType.None
	end

	return nil
end

function SingleGuide:closeGuidePanel(stepCfg)
	pg.global.ui:closeImmediately(UIConst.UI_ID_GUIDE_PANEL)
	pg.global.ui:closeImmediately(UIConst.UI_ID_GUIDE_POPUP_PANEL)
end

function SingleGuide:getStepID(stepIndex)
	return self.curGuideConfig.step[stepIndex]
end

function SingleGuide:guideStepForward()
	if self.curStepIndex < #self.curGuideSteps then
		self.curStepIndex = self.curStepIndex + 1
		self.curStepId = self:getStepID(self.curStepIndex)
		self.curStepConfig = guideStepData[self.curStepId]

		if not GuideUtils.checkPlatformLimit(self.curStepConfig) then
			return self:guideStepForward()
		end

		return true
	else
		return false
	end
end

function SingleGuide:canShowBerthTip(stepCfg)
	if stepCfg == nil or stepCfg.directionMethod ~= Const.GUIDE_DIRECTION_TYPE.GUIDE_PORINT_TYPE_CONTROL then
		return false
	end

	return stepCfg.type == Const.GUIDE_TYPE.GT_FOCUS or stepCfg.type == Const.GUIDE_TYPE.GT_FLOATING_DRAG or stepCfg.type == Const.GUIDE_TYPE.GT_SPECIFIC_HIGHLIGHT
end

function SingleGuide:getFinishedAnimTiming(stepCfg)
	if stepCfg.type == Const.GUIDE_TYPE.GT_FLOATING_AUTO and stepCfg.animation == 1 then
		return FloatingAutoFinishedTime, FloatingAutoHideTime
	elseif stepCfg.type == Const.GUIDE_TYPE.GT_FLOATING_AI then
		return AIFinishedTime, AIHideTime
	elseif self:canShowBerthTip(stepCfg) then
		return BerthTipFinishedTime, BerthTipHideTime
	end

	return 0, 0
end

function SingleGuide:getFinishedTime(stepCfg)
	local finishedTime, hideTime = self:getFinishedAnimTiming(stepCfg)

	return finishedTime + hideTime
end

function SingleGuide:killDelayFinishStepTimer()
	if self.delayFinStepTimer ~= nil then
		TimerManager.removeTimer(self.delayFinStepTimer)

		self.delayFinStepTimer = nil
	end
end

function SingleGuide:getEndCheckArg(stepCfg, endCheckType)
	if stepCfg == nil or stepCfg.endCheck == nil or stepCfg.endCheckArg == nil then
		return nil
	end

	for i = 1, #stepCfg.endCheck do
		if stepCfg.endCheck[i] == endCheckType then
			return stepCfg.endCheckArg[i]
		end
	end
end

function SingleGuide:getInputTriggeredWhiteList(stepCfg)
	local actionPath = self:getEndCheckArg(stepCfg, Const.GUIDE_STEP_END.GSC_INPUT_TRIGGERED)

	if actionPath == nil then
		return nil
	end

	local whiteList = {}

	if Utils.isTable(actionPath) then
		local actionList = Utils.deepCopyTable(actionPath)

		for i = 1, #actionList do
			table.insert(whiteList, actionList[i])
		end
	else
		table.insert(whiteList, actionPath)
	end

	return whiteList
end

function SingleGuide:isActionBoundToInput(actionPath, inputPath)
	local input = pg.game.input

	if input == nil or input.getCurHotkeyManager == nil or input.getActionKeyBind == nil then
		return false
	end

	local hotkeyManager = input:getCurHotkeyManager()

	if hotkeyManager == nil then
		return false
	end

	local binding = input:getActionKeyBind(hotkeyManager, actionPath)

	if binding == nil or binding == "" then
		return false
	end

	local bindingControl = string.match(binding, "([^/]+)$")
	local targetControl = string.match(inputPath, "([^/]+)$")

	return bindingControl ~= nil and targetControl ~= nil and string.lower(bindingControl) == string.lower(targetControl)
end

function SingleGuide:addGuideAction(actionList, actionPath)
	if actionPath == nil then
		return
	end

	if Utils.isTable(actionPath) then
		for i = 1, #actionPath do
			self:addGuideAction(actionList, actionPath[i])
		end

		return
	end

	if type(actionPath) == "string" and actionPath ~= "" and not table.contains(actionList, actionPath) then
		table.insert(actionList, actionPath)
	end
end

function SingleGuide:getEndCheckActions(stepCfg)
	local actionList = {}

	if stepCfg == nil or stepCfg.endCheck == nil or stepCfg.endCheckArg == nil then
		return actionList
	end

	local endCheckCount = #stepCfg.endCheck

	for i = 1, endCheckCount do
		local endCheck = stepCfg.endCheck[i]

		if endCheck == Const.GUIDE_STEP_END.GSC_INPUT_TRIGGERED then
			self:addGuideAction(actionList, stepCfg.endCheckArg[i])
		elseif endCheck == Const.GUIDE_STEP_END.GSC_CLICK_BTN then
			local endArg = endCheckCount == 1 and stepCfg.endCheckArg or stepCfg.endCheckArg[i]
			local targetBtnTrans = GuideUtils.getFocusTarget(endArg)

			if NotNil(targetBtnTrans) then
				local keyBindingPros = targetBtnTrans:GetComponentsInChildren(typeof(KeyBindingPro))
				local actionCountBefore = #actionList

				if keyBindingPros ~= nil then
					for j = 0, keyBindingPros.Length - 1 do
						self:addGuideAction(actionList, keyBindingPros[j].actionPath)
					end
				end

				if LoggerManager.checkLogger(LoggerConst.INFO) then
					logger:info("[GuideNextStep] endCheck按钮Action扫描", self.curGuideId, self.curStepId, targetBtnTrans.name, keyBindingPros and keyBindingPros.Length or 0, #actionList - actionCountBefore, inspect(endArg))
				end
			elseif LoggerManager.checkLogger(LoggerConst.INFO) then
				logger:info("[GuideNextStep] endCheck目标节点未找到", self.curGuideId, self.curStepId, inspect(endArg))
			end
		end
	end

	return actionList
end

function SingleGuide:getNextStepActionPath()
	return GuideInputUtils.getNextStepActionPath()
end

function SingleGuide:getNextStepInputPath()
	return GuideInputUtils.getNextStepInputPath()
end

function SingleGuide:isMobilePlatform()
	return ClientUtils.getAdaptionPlatform() == UIConst.PLATFORM.Mobile
end

function SingleGuide:tryNextStep()
	if not self:isNextStepEnabled(self.curStepConfig) then
		return false
	end

	self:finishStep(Const.GUIDE_STEP_FINISH_REASON.ACTION_TRIGGERED)

	return true
end

function SingleGuide:isNextStepEnabled(stepCfg)
	if stepCfg == nil or stepCfg.force ~= 1 or stepCfg.notSkip ~= nil and stepCfg.notSkip ~= 0 or not GUIDE_NEXT_STEP_TYPES[stepCfg.type] then
		return false
	end

	if self:isMobilePlatform() then
		return true
	end

	local nextStepInput = self:getNextStepInputPath()
	local endCheckActions = self:getEndCheckActions(stepCfg)

	if #endCheckActions == 0 then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			logger:info("[GuideNextStep] enabled: endCheck未获取到有效Action", self.curGuideId, self.curStepId, inspect(stepCfg.endCheckArg), nextStepInput)
		end

		return true
	end

	for i = 1, #endCheckActions do
		if self:isActionBoundToInput(endCheckActions[i], nextStepInput) then
			if LoggerManager.checkLogger(LoggerConst.INFO) then
				logger:info("[GuideNextStep] disabled: endCheck Action与下一步物理按键相同", self.curGuideId, self.curStepId, endCheckActions[i], nextStepInput)
			end

			return false
		end
	end

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("[GuideNextStep] enabled: endCheck Action与下一步物理按键不同", self.curGuideId, self.curStepId, inspect(endCheckActions), nextStepInput)
	end

	return true
end

function SingleGuide:isInFocusStep()
	return self.curStepConfig ~= nil and (self.curStepConfig.type == Const.GUIDE_TYPE.GT_FOCUS or self.curStepConfig.type == Const.GUIDE_TYPE.GT_SPECIFIC_HIGHLIGHT)
end

function SingleGuide:SetRaycastSimulateTestEnabled(active)
	local ok, err = xpcall(function()
		if pg.global.navMgr.SetRaycastSimulateTestEnabled then
			pg.global.navMgr:SetRaycastSimulateTestEnabled(active)

			if LoggerManager.checkLogger(LoggerConst.INFO) then
				logger:info("[Guide] SetRaycastSimulateTestEnabled(%s) success .", tostring(active))
			end
		end
	end, debug.traceback)

	if not ok and LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("[Guide] SetRaycastSimulateTestEnabled(%s) failed .", tostring(active), err)
	end
end

function SingleGuide:clearData()
	self:killDelayFinishStepTimer()
	self:killTickTimer()
	self:killOneStepTimer()
	self:killCondCheckTimer()
	self:killStepTimeLimitTimer()
	self:killGroupSkipTimer()

	self.curStepId = nil
	self.curGuideSteps = {}
	self.curStepConfig = nil
	self.waittingShowStepIds = {}
	self.focusTarget_1 = nil
	self.focusTarget_2 = nil
	self.currentGuidePanelArgs = nil
	self.fullScreenPauseUIs = nil
	self.pausedStepId = nil
end

return SingleGuide
