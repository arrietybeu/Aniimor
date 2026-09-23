-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\TopTipArea\\GetEggLimitedTimeItem.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local BaseQueueItem = require("Guis.Panels.Tips.Items.BaseQueueItem")
local ClientTextUtils = require("Utils.ClientTextUtils")
local Time = require("Core.Common.Time")
local EggLimitTimeRewardData = require("Data.egg_limit_time_reward_data")
local EggLimitTimeRewardBoxData = require("Data.egg_limit_time_reward_box_data")
local DoTweenAnimMgr = DoTweenAnimMgr
local LuaUIUtils = require("Utils.LuaUIUtils")
local GetEggLimitedTimeItem = Class.LightClass("GetEggLimitedTimeItem", BaseQueueItem)
local DEFAULT_WARN_DURATION = 10
local BANNER_SHOW_TIME = 3
local DELAY_REWARD_NUM = 0.63
local DELAY_REWARD_ICON = 0.78
local FINISH_DELAY = 2
local STAGE_PLAY_TIME = 1.2
local MAX_REWARD_QUEUE = 3
local STAGE_ROLL_TIME = 0.5
local NORMAL_ROLL_TIME = 0.3
local KILL_ROLL_TWEEN_ID = "robEggKillRoll"
local KILL_ROLL_EASE = CS.DG.Tweening.Ease.__CastFrom(1)

local function getStageReward(stage)
	local cfg = EggLimitTimeRewardData[stage]

	if cfg == nil then
		return nil
	end

	local rewardId, rewardNum = nil, 0

	for templateId, numTab in pairs(cfg.RewardContent or EMPTY_TABLE) do
		rewardId = templateId
		rewardNum = numTab[1] or 0

		break
	end

	if rewardId == nil then
		return nil
	end

	local boxCfg = EggLimitTimeRewardBoxData[rewardId] or {}

	return {
		rewardId = rewardId,
		rewardNum = rewardNum,
		rewardIcon = boxCfg.Icon
	}
end

local function getStageKillNum(stage)
	local cfg = EggLimitTimeRewardData[stage]

	return cfg and cfg.KillNum or 0
end

local function getCompletedStage(totalKill)
	local stage = 0

	for i = 1, #EggLimitTimeRewardData do
		if totalKill >= getStageKillNum(i) then
			stage = i
		else
			break
		end
	end

	return stage
end

local function getTargetStage(totalKill)
	local completed = getCompletedStage(totalKill)

	return math.min(completed + 1, #EggLimitTimeRewardData)
end

function GetEggLimitedTimeItem:onInit()
	self:setMaxLimit(1)

	self.uContainer = self.uWidget
	self.delayTimers = {}
	self.rewardQueue = {}
	self.rewardPlaying = false
	self.shownKill = 0
end

function GetEggLimitedTimeItem:pushData(data)
	data.totalKill = data.totalKill or data.killNum or 0
	data.appliedStage = 0
	self.pendingTotalKill = nil
	self.pendingWaveIndex = nil
	self.shownKill = 0
	self.data = data

	self:enqueue(data)

	if self:isRunning() then
		self:refreshView(self.uContainer.content, data)
	end
end

function GetEggLimitedTimeItem:onUpdate()
	self:tryPopupItem()
end

function GetEggLimitedTimeItem:tryPopupItem()
	if self:isQueueEmpty() or self:isReachTheLimit() then
		return
	end

	self.data = self:dequeue()

	self:addRunItem(self.data)
	self:initUContainer(self.data)
end

function GetEggLimitedTimeItem:refresh(totalKill)
	local data = self:firstRunItem()

	if data == nil then
		if totalKill ~= nil then
			self.pendingTotalKill = totalKill
		end

		return
	end

	if totalKill ~= nil then
		data.totalKill = totalKill
	end

	if IsNil(self.uContainer.content) then
		return
	end

	self:updateKill(data)
end

function GetEggLimitedTimeItem:hideById(id)
	self:clearDataQueue()

	local data = self:firstRunItem()

	if data then
		self:recycleToast(data)
	end
end

function GetEggLimitedTimeItem:onClearRunningList()
	local runNum = #self.runList

	for i = runNum, 1, -1 do
		self:recycleToast(self.runList[i])
	end
end

function GetEggLimitedTimeItem:onUIVisibleToHide()
	self:finished()
end

function GetEggLimitedTimeItem:onSceneUnload()
	self:hideById()
end

function GetEggLimitedTimeItem:recycleToast(data, force)
	if data.removing then
		return
	end

	data.removing = true

	self:stopCountDown()
	self:clearBannerTimer()
	self:clearRewardQueue()
	self:clearDelayTimers()
	self:destroyContent(data)
end

function GetEggLimitedTimeItem:destroyContent(data)
	if self:isQueueEmpty() then
		self.uContainer:DestroyContent()
	end

	self:removeItem(data)
end

function GetEggLimitedTimeItem:initUContainer(data)
	if not self.uContainer:CheckURLLoaded() then
		self.uContainer:LoadDefaultUrlManually(function()
			if data.removing or not self:isRunning() then
				return
			end

			self:renderItem(self.uContainer.content, data)
		end)
	else
		self:renderItem(self.uContainer.content, data)
	end
end

function GetEggLimitedTimeItem:renderItem(item, data)
	if IsNil(item) then
		return
	end

	data.removing = false
	self.root = item

	local objectReference = item:GetComponent("ObjectReference")

	self.countdownTimeTxt = objectReference:GetRefValue("countdownTimeTxt")

	ClientTextUtils.setText(self.countdownTimeTxt, pg.getGameString("GRAB_EGG_Chai_Tips_02"))

	self.countdownTime = objectReference:GetRefValue("countdownTime")
	self.killText = objectReference:GetRefValue("killText")

	ClientTextUtils.setText(self.killText, pg.getGameString("GRAB_EGG_Chai_Tips_03"))

	self.killNum = objectReference:GetRefValue("killNum")
	self.maxKillnum = objectReference:GetRefValue("maxKillnum")
	self.waveNumber = objectReference:GetRefValue("waveNumber")
	self.processbar = objectReference:GetRefValue("processbar")

	local cutLine = objectReference:GetRefValue("CutLine")

	if IsNil(cutLine) and NotNil(self.processbar) then
		cutLine = self.processbar.transform:Find("CutLine")
	end

	LuaUIUtils.setUIVisible(cutLine, false)

	self.curRewardTxt = objectReference:GetRefValue("curRewardTxt")

	ClientTextUtils.setText(self.curRewardTxt, pg.getGameString("GRAB_EGG_NO_REWARD"))

	self.curRewardIcon = objectReference:GetRefValue("curRewardIcon")
	self.curRewardNum = objectReference:GetRefValue("curRewardNum")

	self.root:TryChangePage("Text", 0)
	self.root:TryChangePage("Time", 0)

	if self.pendingTotalKill ~= nil then
		if self.pendingTotalKill > (data.totalKill or 0) then
			data.totalKill = self.pendingTotalKill
		end

		self.pendingTotalKill = nil
	end

	self:refreshView(item, data)

	if data.rewardStage then
		self:showRewardTip()
	elseif data.finishStage then
		self:showFinishTip()
	else
		self:startCountDown(data)
	end

	if self.pendingWaveIndex ~= nil then
		local waveIndex = self.pendingWaveIndex

		self.pendingWaveIndex = nil

		self:showWaveTip(waveIndex)
	end
end

function GetEggLimitedTimeItem:refreshView(item, data)
	if IsNil(item) then
		return
	end

	local totalKill = data.totalKill or 0
	local completedStage = getCompletedStage(totalKill)

	data.appliedStage = completedStage

	self:applyKillViewStatic(totalKill)
	self:applyStageRewardView(completedStage)
end

function GetEggLimitedTimeItem:startCountDown(data)
	if data.endTime == nil then
		return
	end

	self:stopCountDown()
	self:refreshCountDownNumber(data)

	self.countTimer = self:startTimer(function()
		self:refreshCountDownNumber(data)
	end, 1, true)
end

function GetEggLimitedTimeItem:refreshCountDownNumber(data)
	local remain = math.ceil(data.endTime - Time.secondCache)

	if remain < 0 then
		self:onCountDownFinish()

		return
	end

	if NotNil(self.countdownTime) then
		ClientTextUtils.setText(self.countdownTime, string.format("%ds", remain))
	end

	if NotNil(self.root) then
		self.root:InvokeCallback(CS.XGUI.EInvokeTime.User1)

		local warnDuration = data.warnDuration or DEFAULT_WARN_DURATION

		self.root:TryChangePage("Time", remain <= warnDuration and 1 or 0)
	end
end

function GetEggLimitedTimeItem:stopCountDown()
	if self.countTimer then
		self:killTimer(self.countTimer)

		self.countTimer = nil
	end
end

function GetEggLimitedTimeItem:onCountDownFinish()
	local data = self:firstRunItem()

	if data == nil or data.finishing then
		return
	end

	data.finishing = true

	self:stopCountDown()

	if NotNil(self.countdownTime) then
		ClientTextUtils.setText(self.countdownTime, string.format("%ds", 0))
	end

	self:showFinishBanner()

	if data.finishCb then
		data.finishCb()
	end
end

function GetEggLimitedTimeItem:showFinishBanner()
	if IsNil(self.root) or IsNil(self.waveNumber) then
		return
	end

	self:clearBannerTimer()
	ClientTextUtils.setText(self.waveNumber, pg.getGameString("GRAB_EGG_Chai_Tips_05"))
	self.root:TryChangePage("Text", 1)
end

function GetEggLimitedTimeItem:showFinishTip(params)
	local data = self:firstRunItem()

	if data == nil then
		return false
	end

	if params and params.killNum ~= nil then
		data.totalKill = params.killNum
	end

	data.finishStage = true
	data.finishing = true

	self:stopCountDown()
	self:showFinishBanner()

	return true
end

function GetEggLimitedTimeItem:showRewardTip()
	local data = self:firstRunItem()

	if data == nil then
		return false
	end

	data.rewardStage = true

	if IsNil(self.uContainer.content) then
		return true
	end

	if data.rewardShowing then
		return true
	end

	data.rewardShowing = true

	self:stopCountDown()
	self:showFinishBanner()
	self:addDelayTimer(function()
		self:recycleToast(data)
	end, FINISH_DELAY)

	return true
end

function GetEggLimitedTimeItem:updateKill(data)
	local totalKill = data.totalKill or 0
	local completedStage = getCompletedStage(totalKill)
	local oldStage = data.appliedStage or 0

	if oldStage < completedStage then
		for stage = oldStage + 1, completedStage do
			local reward = getStageReward(stage)
			local prev = getStageReward(stage - 1)

			if reward then
				if prev == nil or prev.rewardId ~= reward.rewardId then
					self:onRewardUpgrade(reward, stage)
				else
					self:onRewardNumAdd(reward, stage)
				end
			end
		end

		data.appliedStage = completedStage
	end

	self:refreshKill(totalKill)
end

function GetEggLimitedTimeItem:refreshKill(totalKill)
	if self.rewardPlaying then
		return
	end

	self:rollKillTo(totalKill, getTargetStage(totalKill), NORMAL_ROLL_TIME)
end

function GetEggLimitedTimeItem:applyKillViewStatic(totalKill)
	totalKill = totalKill or 0

	self:killRollTween()

	self.shownKill = totalKill

	local targetStage = getTargetStage(totalKill)
	local stageKill = getStageKillNum(targetStage)

	if NotNil(self.killNum) then
		ClientTextUtils.setText(self.killNum, tostring(totalKill))
	end

	if NotNil(self.maxKillnum) then
		ClientTextUtils.setText(self.maxKillnum, string.format("/%d", stageKill))
	end

	if NotNil(self.processbar) then
		self.processbar.value = stageKill > 0 and math.clamp(totalKill / stageKill, 0, 1) or 0
	end
end

function GetEggLimitedTimeItem:rollKillTo(targetKill, barStage, duration, onComplete)
	targetKill = targetKill or 0

	local stageKill = getStageKillNum(barStage)

	if NotNil(self.maxKillnum) then
		ClientTextUtils.setText(self.maxKillnum, string.format("/%d", stageKill))
	end

	local go = NotNil(self.processbar) and self.processbar.gameObject or nil

	if go == nil then
		self.shownKill = targetKill

		if NotNil(self.killNum) then
			ClientTextUtils.setText(self.killNum, tostring(targetKill))
		end

		if onComplete then
			onComplete()
		end

		return
	end

	local from = self.shownKill or 0

	self:killRollTween()
	DoTweenAnimMgr.DoFloat(go, from, targetKill, LuaUIUtils.TweenId(KILL_ROLL_TWEEN_ID), duration, 0, KILL_ROLL_EASE, nil, function(value)
		self.shownKill = value

		if NotNil(self.killNum) then
			ClientTextUtils.setText(self.killNum, tostring(math.floor(value + 0.5)))
		end

		if NotNil(self.processbar) then
			self.processbar.value = stageKill > 0 and math.clamp(value / stageKill, 0, 1) or 0
		end
	end, function()
		self.shownKill = targetKill

		if NotNil(self.killNum) then
			ClientTextUtils.setText(self.killNum, tostring(targetKill))
		end

		if NotNil(self.processbar) then
			self.processbar.value = stageKill > 0 and math.clamp(targetKill / stageKill, 0, 1) or 0
		end

		if onComplete then
			onComplete()
		end
	end, false)
end

function GetEggLimitedTimeItem:killRollTween()
	if NotNil(self.processbar) then
		DoTweenAnimMgr.Kill(self.processbar.gameObject, LuaUIUtils.TweenId(KILL_ROLL_TWEEN_ID))
	end
end

function GetEggLimitedTimeItem:showBanner(text)
	if IsNil(self.root) or IsNil(self.waveNumber) then
		return
	end

	ClientTextUtils.setText(self.waveNumber, text)
	self.root:TryChangePage("Text", 1)
	self:clearBannerTimer()

	self.bannerTimer = self:startTimer(function()
		self.bannerTimer = nil

		if NotNil(self.root) then
			self.root:TryChangePage("Text", 0)
		end
	end, BANNER_SHOW_TIME)
end

function GetEggLimitedTimeItem:showWaveTip(waveIndex)
	if IsNil(self.root) then
		self.pendingWaveIndex = waveIndex

		return
	end

	self:showBanner(pg.getFormatText(pg.getGameString("GRAB_EGG_Chai_Waves"), waveIndex))
end

function GetEggLimitedTimeItem:clearBannerTimer()
	if self.bannerTimer then
		self:killTimer(self.bannerTimer)

		self.bannerTimer = nil
	end
end

function GetEggLimitedTimeItem:onRewardNumAdd(reward, stage)
	self:pushRewardTask({
		kind = "numAdd",
		reward = reward,
		stage = stage
	})
end

function GetEggLimitedTimeItem:onRewardUpgrade(reward, stage)
	self:pushRewardTask({
		kind = "upgrade",
		reward = reward,
		stage = stage
	})
end

function GetEggLimitedTimeItem:pushRewardTask(task)
	table.insert(self.rewardQueue, task)
	self:tryPlayNextReward()
end

function GetEggLimitedTimeItem:tryPlayNextReward()
	if self.rewardPlaying then
		return
	end

	if #self.rewardQueue == 0 then
		local data = self:firstRunItem()

		if data then
			self:rollKillTo(data.totalKill, getTargetStage(data.totalKill), STAGE_ROLL_TIME)
		end

		return
	end

	while #self.rewardQueue > MAX_REWARD_QUEUE do
		local task = table.remove(self.rewardQueue, 1)

		self:applyRewardInstant(task)
	end

	local task = table.remove(self.rewardQueue, 1)

	self:playRewardTask(task)
end

function GetEggLimitedTimeItem:applyRewardInstant(task)
	self:applyStageRewardView(task.stage)

	self.shownKill = getStageKillNum(task.stage)
end

function GetEggLimitedTimeItem:playRewardTask(task)
	if IsNil(self.root) then
		self.rewardPlaying = false

		return
	end

	self.rewardPlaying = true

	self:rollKillTo(getStageKillNum(task.stage), task.stage, STAGE_ROLL_TIME, function()
		self:playRewardAnim(task)
	end)
end

function GetEggLimitedTimeItem:playRewardAnim(task)
	if IsNil(self.root) then
		self.rewardPlaying = false

		return
	end

	local reward = task.reward

	self.root:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)

	if task.kind == "upgrade" then
		self.root:InvokeCallback(CS.XGUI.EInvokeTime.Custom3)
		self:addDelayTimer(function()
			if NotNil(self.curRewardTxt) then
				ClientTextUtils.setText(self.curRewardTxt, pg.getGameString("GRAB_EGG_Chai_Tips_04"))
			end

			self:applyRewardIcon(reward.rewardIcon)
			self:applyRewardNum(reward.rewardNum)
		end, DELAY_REWARD_ICON)
	else
		self.root:InvokeCallback(CS.XGUI.EInvokeTime.Custom2)
		self:addDelayTimer(function()
			if NotNil(self.curRewardTxt) then
				ClientTextUtils.setText(self.curRewardTxt, pg.getGameString("GRAB_EGG_Chai_Tips_04"))
			end

			self:applyRewardNum(reward.rewardNum)
		end, DELAY_REWARD_NUM)
	end

	self:addDelayTimer(function()
		self:onRewardTaskFinished()
	end, STAGE_PLAY_TIME)
end

function GetEggLimitedTimeItem:onRewardTaskFinished()
	self.rewardPlaying = false

	self:tryPlayNextReward()
end

function GetEggLimitedTimeItem:clearRewardQueue()
	table.clearArray(self.rewardQueue)

	self.rewardPlaying = false

	self:killRollTween()
end

function GetEggLimitedTimeItem:applyStageRewardView(stage)
	local reward = getStageReward(stage)

	if reward == nil then
		if NotNil(self.curRewardTxt) then
			ClientTextUtils.setText(self.curRewardTxt, pg.getGameString("GRAB_EGG_NO_REWARD"))
		end

		self:applyRewardIcon(nil)
		self:applyRewardNum(nil)

		return
	end

	if NotNil(self.curRewardTxt) then
		ClientTextUtils.setText(self.curRewardTxt, pg.getGameString("GRAB_EGG_Chai_Tips_04"))
	end

	self:applyRewardIcon(reward.rewardIcon)
	self:applyRewardNum(reward.rewardNum)
end

function GetEggLimitedTimeItem:applyRewardIcon(rewardIcon)
	if IsNil(self.curRewardIcon) then
		return
	end

	local hasRewardIcon = not string.isNilOrEmpty(rewardIcon)
	local rewardIconWidget = self.curRewardIcon.transform.parent:GetComponent(typeof(CS.XGUI.UWidget))

	if NotNil(rewardIconWidget) then
		rewardIconWidget:SetActiveFastestAndMarkIgnoreLayout(hasRewardIcon)
	else
		self.curRewardIcon.transform.parent.gameObject:SetActiveEx(hasRewardIcon)
	end

	if not hasRewardIcon then
		self.curRewardIcon.url = nil
	else
		self.curRewardIcon.url = rewardIcon
	end
end

function GetEggLimitedTimeItem:applyRewardNum(rewardNum)
	if IsNil(self.curRewardNum) then
		return
	end

	self.curRewardNum:SetActiveFastestAndMarkIgnoreLayout(rewardNum ~= nil)

	if rewardNum ~= nil then
		ClientTextUtils.setText(self.curRewardNum, rewardNum ~= 0 and string.format("x%d", rewardNum) or tostring(rewardNum))
	end
end

function GetEggLimitedTimeItem:addDelayTimer(func, delay)
	local id = self:startTimer(func, delay)

	table.insert(self.delayTimers, id)

	return id
end

function GetEggLimitedTimeItem:clearDelayTimers()
	for _, id in ipairs(self.delayTimers) do
		self:killTimer(id)
	end

	table.clearArray(self.delayTimers)
end

function GetEggLimitedTimeItem:onDestroy()
	if NotNil(self.uContainer) and NotNil(self.uContainer.content) then
		self.uContainer:DestroyContent()
	end

	self:setVisible(false)
	BaseQueueItem.onDestroy(self)
end

return GetEggLimitedTimeItem
