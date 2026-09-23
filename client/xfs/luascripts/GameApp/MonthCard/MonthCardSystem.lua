-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\MonthCard\\MonthCardSystem.lua

local Class = require("Core.Framework.Class")
local SystemBase = require("GameApp.Core.SystemBase")
local MonthCardConst = require("GameApp.MonthCard.MonthCardConst")
local MonthCardUtils = require("GameApp.MonthCard.MonthCardUtils")
local MessageName = require("Const.MessageName")
local UIConst = require("Const.UIConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local LoggerManager = require("Core.Log.LoggerManager")
local logger = LoggerManager.getLogger("MonthCardSystem")
local MonthCardSystem = Class.LightClass("MonthCardSystem", SystemBase)

function MonthCardSystem:getMessageBindMap()
	return {
		[MessageName.NOTIFY_ACTIVITY_DAY_UPDATED] = "activityDayUpdate",
		[MessageName.QUEST_ON_STATE_CHANGE] = "onQuestStateChange"
	}
end

function MonthCardSystem:onCtor()
	return
end

function MonthCardSystem:onInit()
	return
end

function MonthCardSystem:onClear()
	return
end

function MonthCardSystem:onDestroy()
	return
end

function MonthCardSystem:onLogin()
	self._dailyPopupShownThisSession = false
end

function MonthCardSystem:onPlayerEnterScene()
	self:tryShowDailyRewardPopup()
end

function MonthCardSystem:activityDayUpdate()
	self._dailyPopupShownThisSession = false

	self:tryShowDailyRewardPopup()
end

function MonthCardSystem:onQuestStateChange(data)
	if MonthCardUtils.isPreorderGuideTriggerMatched(data.questId, data.state) then
		self:tryShowPreorderGuide(false)
	end
end

function MonthCardSystem:requestClaimDailyReward()
	if MonthCardUtils.getDailyRewardState() ~= MonthCardConst.DAILY_REWARD_STATE.AVAILABLE then
		return
	end

	pg.me:monthCardReceiveDailyAward()
end

function MonthCardSystem:requestClaimStoredReward()
	if not MonthCardUtils.hasStoredReward() then
		return
	end

	pg.me:monthCardReceiveStoreAward()
end

function MonthCardSystem:tryShowPreorderGuide(isManual)
	if not MonthCardUtils.isPreorderGuideEnabled() then
		return false
	end

	pg.global.ui:open(UIConst.UI_ID_GAME_PREORDER_GUIDE, {
		isManual = isManual ~= false
	})

	return true
end

function MonthCardSystem:reportPreorderWindow(actionType, uiId, isManual)
	LuaUIUtils.sendCustomLog("ui_window", {
		action_type = actionType,
		id = tostring(uiId),
		is_manual = isManual and 1 or 0
	})
end

function MonthCardSystem:openPreorderMonthCard()
	pg.global.ui:open(UIConst.UI_ID_BP_PERMIT, {
		fromPreorderGuide = true
	})
end

function MonthCardSystem:onDailyRewardClaimed()
	self._dailyPopupShownThisSession = true

	pg.global.ui:open(UIConst.UI_ID_MONTHLY_CARD_SELFIE)
end

function MonthCardSystem:tryShowDailyRewardPopup()
	if self._dailyPopupShownThisSession then
		return
	end

	if MonthCardUtils.getDailyRewardState() ~= MonthCardConst.DAILY_REWARD_STATE.AVAILABLE then
		return
	end

	self:requestClaimDailyReward()
end

return MonthCardSystem
