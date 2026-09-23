-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GrabEggSettlementRank\\GrabEggSettlementRankView.lua

local logger = require("Core.Log.LoggerManager").getLogger("GrabEggSettlementRankView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local ClientTextUtils = require("Utils.ClientTextUtils")
local GrabEggSettlementRankView = Class.LightClass("GrabEggSettlementRankView", UIView)
local PROGRESS_ANIM_TIME = 0.3
local SKIP_ANIMATION_TEXT_KEY = "GRAB_EGG_SETTLEMENT_SKIP_ANIMATION"
local SCORE_LIMIT_TEXT_KEY = "GRAB_EGG_SETTLEMENT_MAXOFCURRENT"
local FAIL_AND_DOWN_TEXT_KEY = "GRAB_EGG_SETTLEMENT_FAILANDDOWN"
local RANK_SCORE_DOUBLE_SETTLEMENT_TIPS_TEXT_KEY = "GRAB_EGG_RANK_SCORE_DOUBLE_SETTLEMENT_TIPS"
local NOVICE_PROTECTION_TIPS_TEXT_KEY = "GRAB_EGG_NOVICEPROTECTION_TIPS_1"
local CONTENT_PROGRESS = 0
local CONTENT_SCORE_LIMIT = 1
local CONTENT_SETTLEMENT_TIPS = 2
local POINT_UP_NORMAL = 0
local POINT_UP_DOUBLE = 1
local MAX_PERFORMANCE_TAG_COUNT = 3
local TAG_ANIMATION_INVOKE_TIME = {
	[0] = CS.XGUI.EInvokeTime.Custom3,
	CS.XGUI.EInvokeTime.Custom4,
	CS.XGUI.EInvokeTime.Custom5,
	CS.XGUI.EInvokeTime.Custom6
}

function GrabEggSettlementRankView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.textRankNameUBaseText = objectReference:GetRefValue("textRankNameUBaseText")
	self.textSeasonNameUBaseText = objectReference:GetRefValue("textSeasonNameUBaseText")
	self.iconRankUImage = objectReference:GetRefValue("iconRankUImage")
	self.iconBoardUImage = objectReference:GetRefValue("iconBoardUImage")
	self.progressUProgress = objectReference:GetRefValue("progressUProgress")
	self.textChangeUBaseText = objectReference:GetRefValue("textChangeUBaseText")
	self.listEggUList = objectReference:GetRefValue("listEggUList")
	self.textLevelUBaseText = objectReference:GetRefValue("textLevelUBaseText")
	self.pointNumUBaseText = objectReference:GetRefValue("pointNumUBaseText")
	self.textPointUSDFText = objectReference:GetRefValue("textPointUSDFText")
	self.glowUWidget = objectReference:GetRefValue("glowUWidget")
	self.btnFullCloseUButton = objectReference:GetRefValue("btnFullCloseUButton")
	self.tagListLeftUList = objectReference:GetRefValue("tagListLeftUList")
	self.tagListRightUList = objectReference:GetRefValue("tagListRightUList")
	self.textCloseUSDFText = objectReference:GetRefValue("textCloseUSDFText")
	self.textContentUSDFText = objectReference:GetRefValue("textContentUSDFText")
	self.textContentcloseUSDFText = objectReference:GetRefValue("textContentcloseUSDFText")
	self.textUSDFText = objectReference:GetRefValue("textUSDFText")
	self.pointUpContentUWidget = objectReference:GetRefValue("pointUpContentUWidget")
	self.pointUPUSDFText = objectReference:GetRefValue("pointUPUSDFText")
end

function GrabEggSettlementRankView:registerObjects()
	return
end

function GrabEggSettlementRankView:initView()
	self:setGlowActive(false)
	ClientTextUtils.setText(self.textSeasonNameUBaseText, pg.getGameString("GRAB_EGG_SEASON_RANK_TITLE"))
	ClientTextUtils.setText(self.textUSDFText, pg.getGameString(FAIL_AND_DOWN_TEXT_KEY))
	self.pointUpContentUWidget:SetActive(false)
	self:renderCloseText(false)
end

function GrabEggSettlementRankView:renderRankScoreDouble(isDoubled, remainingTimes)
	if self.widget then
		self.widget:TryChangePage("PointUp", isDoubled and POINT_UP_DOUBLE or POINT_UP_NORMAL)
	else
		self.pointUpContentUWidget:SetActive(isDoubled)
	end

	if not isDoubled then
		return
	end

	remainingTimes = math.max(0, math.floor(tonumber(remainingTimes) or 0))

	ClientTextUtils.setText(self.pointUPUSDFText, pg.getFormatText(pg.getGameString(RANK_SCORE_DOUBLE_SETTLEMENT_TIPS_TEXT_KEY), remainingTimes))
end

function GrabEggSettlementRankView:renderCloseText(isAnimFinished)
	local textKey = isAnimFinished and "COMMON_CLICK_CONTINUE" or SKIP_ANIMATION_TEXT_KEY
	local closeText = pg.getGameString(textKey)

	ClientTextUtils.setText(self.textCloseUSDFText, closeText)
	ClientTextUtils.setText(self.textContentcloseUSDFText, closeText)
end

function GrabEggSettlementRankView:renderSettlementContent(isLimited, isNoviceProtected)
	if not self.widget then
		return
	end

	local contentPage = CONTENT_PROGRESS
	local contentText

	if isLimited then
		contentPage = CONTENT_SCORE_LIMIT
		contentText = pg.getGameString(SCORE_LIMIT_TEXT_KEY)
	elseif isNoviceProtected then
		contentPage = CONTENT_SETTLEMENT_TIPS
		contentText = pg.getGameString(NOVICE_PROTECTION_TIPS_TEXT_KEY)
	end

	self.widget:TryChangePage("Content", contentPage)

	if contentText and NotNil(self.textContentUSDFText) then
		ClientTextUtils.setText(self.textContentUSDFText, contentText)
	end
end

function GrabEggSettlementRankView:renderEvaluation(level)
	if self.widget then
		self.widget:TryChangePage("LevelNum", level or 0)
	end
end

function GrabEggSettlementRankView:renderRank(cfg, romanText, isTopRank)
	if not cfg then
		return
	end

	ClientTextUtils.setText(self.textRankNameUBaseText, pg.getLocalizationText(cfg.name))
	ClientTextUtils.setText(self.textLevelUBaseText, isTopRank and "" or romanText or "")

	self.iconRankUImage.url = cfg.icon
end

function GrabEggSettlementRankView:renderIconBoard(iconBoardUrl, isTopRank)
	if not self.iconBoardUImage then
		return
	end

	self.iconBoardUImage:SetActive(not isTopRank)

	if not isTopRank and iconBoardUrl then
		self.iconBoardUImage.url = iconBoardUrl
	end
end

function GrabEggSettlementRankView:renderProgress(score, point, useAnim, fromScore, animTime, fxScore)
	local progress = self.progressUProgress

	point = point or 0
	progress.minValue = 0
	progress.maxValue = point > 0 and point or 1

	local target = math.max(0, math.min(score or 0, progress.maxValue))
	local fxTarget = fxScore == nil and target or math.max(0, math.min(fxScore, progress.maxValue))

	progress.fxValue = fxTarget

	if fromScore then
		progress.value = math.max(0, math.min(fromScore, progress.maxValue))
	end

	if useAnim and progress.ProgressToValue then
		progress:ProgressToValue(target, nil, animTime or PROGRESS_ANIM_TIME)
	else
		progress.value = target
	end
end

function GrabEggSettlementRankView:stopProgressAnim()
	if self.progressUProgress and self.progressUProgress.KillProcessAnim then
		self.progressUProgress:KillProcessAnim()
	end

	self:stopProgressEffect()
end

function GrabEggSettlementRankView:stopProgressEffect()
	if IsNil(self.progressUProgress) then
		return
	end

	local parent = self.progressUProgress.transform.parent
	local animation = NotNil(parent) and parent:GetComponent("Animation") or nil

	if NotNil(animation) then
		animation:Stop()
	end
end

function GrabEggSettlementRankView:invokeProgressRestart()
	if self.widget then
		self.widget:InvokeCallback(CS.XGUI.EInvokeTime.Custom2)
	end
end

function GrabEggSettlementRankView:setGlowActive(active)
	if self.glowUWidget then
		self.glowUWidget:SetActive(active and true or false)
	end
end

function GrabEggSettlementRankView:renderScoreDelta(delta, isNegative)
	delta = tonumber(delta) or 0

	local sign = (isNegative or delta < 0) and "-" or "+"
	local text = string.format("%s%s", sign, math.abs(delta))

	ClientTextUtils.setText(self.textChangeUBaseText, text)
end

function GrabEggSettlementRankView:renderPointScore(currentPoint, totalPoint)
	if not self.textPointUSDFText then
		return
	end

	currentPoint = math.max(0, math.floor(tonumber(currentPoint) or 0))
	totalPoint = math.max(0, math.floor(tonumber(totalPoint) or 0))

	ClientTextUtils.setText(self.textPointUSDFText, string.format("%d/%d", currentPoint, totalPoint))
end

function GrabEggSettlementRankView:renderEggs(eggStageList)
	self.listEggUList:SetList(eggStageList or {})
end

function GrabEggSettlementRankView:playEggAnimation(index, isAdd, onFinished)
	local success, button = self.listEggUList:TryGetChildAt((index or 1) - 1)

	if not success or not button then
		if onFinished then
			onFinished(nil)
		end

		return
	end

	local targetStage = isAdd and 2 or 0
	local invokeTime = isAdd and CS.XGUI.EInvokeTime.User1 or CS.XGUI.EInvokeTime.User2

	button:TryChangePage("Stage", targetStage, false, true, false)
	button:InvokeCallbackWithCallback(invokeTime, function()
		if onFinished then
			onFinished(button)
		end
	end)
end

function GrabEggSettlementRankView:renderPerformanceTag(button, data, playEntranceAnim)
	local objectReference = button:GetComponent("ObjectReference")
	local iconSkillUImage = objectReference:GetRefValue("iconSkillUImage")
	local textUSDFText = objectReference:GetRefValue("textUSDFText")

	button:TryChangePage("Level", data.quality - 1)

	iconSkillUImage.url = data.icon

	ClientTextUtils.setText(textUSDFText, pg.getLocalizationText(data.name))

	if playEntranceAnim then
		button.renderOpacity = self.isFinishingPerformanceTagAnim and 1 or 0
	end
end

function GrabEggSettlementRankView:renderPerformanceTags(leftTags, rightTags)
	leftTags = leftTags or {}

	local displayTags = {}
	local tagCount = math.min(#leftTags, MAX_PERFORMANCE_TAG_COUNT)

	for index = 1, tagCount do
		displayTags[index] = leftTags[index]
	end

	local hasTags = tagCount > 0

	self.tagListLeftUList:SetEnableCustomInterval(hasTags)

	self.tagListLeftUList.luaPreInterval = hasTags and 0.42 or 0

	if self.widget then
		self.widget:TryChangePage("TagNum", tagCount, false, true, false)
	end

	self.tagListLeftUList:SetList(displayTags)
	self.tagListRightUList:SetList(rightTags or {})

	return tagCount
end

function GrabEggSettlementRankView:playPerformanceTagAnim(tagCount, onFinished)
	if not self.widget then
		if onFinished then
			onFinished()
		end

		return
	end

	local invokeTime = TAG_ANIMATION_INVOKE_TIME[tagCount or 0] or TAG_ANIMATION_INVOKE_TIME[0]

	if onFinished then
		self.widget:InvokeCallbackWithCallback(invokeTime, onFinished)
	else
		self.widget:InvokeCallback(invokeTime)
	end
end

function GrabEggSettlementRankView:finishPerformanceTagAnim()
	self.isFinishingPerformanceTagAnim = true

	self.tagListLeftUList:RefreshList(true)
	self.tagListRightUList:RefreshList(true)

	self.isFinishingPerformanceTagAnim = false
end

function GrabEggSettlementRankView:changePanelStage(stage)
	if self.widget then
		self.widget:TryChangePage("Stage", stage)
	end
end

function GrabEggSettlementRankView:changeLevelState(state)
	if self.widget then
		self.widget:TryChangePage("LevelState", state)
	end
end

function GrabEggSettlementRankView:changeTopRank(state)
	if self.widget then
		self.widget:TryChangePage("TopRank", state)
	end
end

function GrabEggSettlementRankView:renderPointNum(count)
	ClientTextUtils.setText(self.pointNumUBaseText, string.format("x%s", count or 0))
end

function GrabEggSettlementRankView:invokePointNumEvent(isAdd, onFinished)
	if not self.widget then
		if onFinished then
			onFinished()
		end

		return
	end

	local invokeTime = isAdd and CS.XGUI.EInvokeTime.User1 or CS.XGUI.EInvokeTime.User2

	if onFinished then
		self.widget:InvokeCallbackWithCallback(invokeTime, onFinished)
	else
		self.widget:InvokeCallback(invokeTime)
	end
end

return GrabEggSettlementRankView
