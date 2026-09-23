-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\MonthCard\\MonthCardUtils.lua

local Time = require("Core.Common.Time")
local TimeUtils = require("Common.Utils.TimeUtils")
local SysConfigData = require("Data.sys_config_data")
local MonthCardBgData = require("Data.monthcard_bg_data")
local AttributeEntryData = require("Data.attribute_entry_data")
local CustomTriggerData = require("Data.custom_trigger_data")
local TriggerUtils = require("Common.Utils.TriggerUtils")
local QuestCommonUtils = require("Common.Utils.QuestCommonUtils")
local Utils = require("Common.Utils.Utils")
local MonthCardConst = require("GameApp.MonthCard.MonthCardConst")
local MonthCardUtils = {}
local PREORDER_GUIDE_TRIGGER_ID = 1601261
local PREORDER_GUIDE_CHANNEL_ID = "google.official.Abkykj"
local PREORDER_GUIDE_BANNED_EVENT_IDS = {
	[1508] = true,
	[1555] = true
}

function MonthCardUtils.isPreorderGuideEnabled()
	local sdkManager = pg.global and pg.global.sdkManager

	if not sdkManager then
		return false
	end

	return sdkManager:isPkgChannel(PREORDER_GUIDE_CHANNEL_ID)
end

function MonthCardUtils.isNpcFuncEventBannedByPreorderGuide(eventIds)
	if not eventIds then
		return false
	end

	local hasBanned = false

	for _, eventId in ipairs(eventIds) do
		if PREORDER_GUIDE_BANNED_EVENT_IDS[eventId] then
			hasBanned = true

			break
		end
	end

	if not hasBanned then
		return false
	end

	return MonthCardUtils.isPreorderGuideEnabled()
end

function MonthCardUtils.isPreorderGuideTriggerMatched(questId, state)
	local triggerMap = pg.me and pg.me.triggerMap

	if not triggerMap then
		return false
	end

	local triggerData = CustomTriggerData[PREORDER_GUIDE_TRIGGER_ID]
	local condition = triggerData.condition[1]

	if questId == nil and state == nil then
		return triggerMap:isCompleteOrMeetCondition(PREORDER_GUIDE_TRIGGER_ID) or QuestCommonUtils.questAccepted(pg.me, condition[2])
	end

	if questId ~= condition[2] or not TriggerUtils.checkMeetOperator(state, condition[5], condition[4]) then
		return false
	end

	return triggerMap:isCompleteOrMeetCondition(PREORDER_GUIDE_TRIGGER_ID)
end

function MonthCardUtils.isActivated()
	if not pg.me then
		return false
	end

	return Utils.monthCardIsOpen(pg.me)
end

function MonthCardUtils.getRemainingDays()
	return Utils.monthCardRemainDays(pg.me) - 1
end

function MonthCardUtils.getExpireTime()
	if not pg.me then
		return 0
	end

	return pg.me.mcEndTm
end

function MonthCardUtils.canPurchase()
	local remaining = MonthCardUtils.getRemainingDays()
	local daysOneCard = SysConfigData.MONTH_CARD_STATE_TIME or 30
	local nextDays = remaining + daysOneCard

	return nextDays <= SysConfigData.MONTH_CARD_STATE_MAX
end

function MonthCardUtils.getDailyRewardState()
	if not MonthCardUtils.isActivated() then
		return MonthCardConst.DAILY_REWARD_STATE.NOT_AVAILABLE
	end

	local lastReceiveTm = pg.me.mcLastReceiveDailyAwardTm or 0
	local now = Time.secondCache
	local todayResetTm = TimeUtils.getServerDayBegin(now)

	if todayResetTm <= lastReceiveTm then
		return MonthCardConst.DAILY_REWARD_STATE.CLAIMED
	end

	return MonthCardConst.DAILY_REWARD_STATE.AVAILABLE
end

local MONTH_ABBR = {
	"MONTH_CARD_FACIAL_MONTH_01",
	"MONTH_CARD_FACIAL_MONTH_02",
	"MONTH_CARD_FACIAL_MONTH_03",
	"MONTH_CARD_FACIAL_MONTH_04",
	"MONTH_CARD_FACIAL_MONTH_05",
	"MONTH_CARD_FACIAL_MONTH_06",
	"MONTH_CARD_FACIAL_MONTH_07",
	"MONTH_CARD_FACIAL_MONTH_08",
	"MONTH_CARD_FACIAL_MONTH_09",
	"MONTH_CARD_FACIAL_MONTH_10",
	"MONTH_CARD_FACIAL_MONTH_11",
	"MONTH_CARD_FACIAL_MONTH_12"
}

function MonthCardUtils.getCurrentMonthDay()
	local Const = require("Common.Const.Const")
	local areaOffset = Const.TIME_AREA_OFFSET_UTCO[Utils.getServerArea()] or 0
	local t = os.date("!*t", Time.secondCache + areaOffset)

	return pg.getGameString(MONTH_ABBR[t.month]), t.day
end

function MonthCardUtils.getMonthCardBg()
	local Const = require("Common.Const.Const")
	local areaOffset = Const.TIME_AREA_OFFSET_UTCO[Utils.getServerArea()] or 0
	local t = os.date("!*t", Time.secondCache + areaOffset)
	local teamplayId = t.year * 100 + t.month
	local cfg = MonthCardBgData[teamplayId]

	if cfg then
		return cfg.bg
	end

	return nil
end

function MonthCardUtils.getStoredRewardDays()
	if not pg.me then
		return 0
	end

	return pg.me.mcStoreDailyAwards
end

function MonthCardUtils.hasStoredReward()
	return MonthCardUtils.getStoredRewardDays() > 0
end

function MonthCardUtils.getMonthCardProductConfig()
	return nil
end

function MonthCardUtils.getPrivilegeListByIds(idList, colorType, title)
	if not idList then
		return {}
	end

	colorType = colorType or 0

	local result = {}

	if title then
		result[#result + 1] = {
			id = 0,
			desc = title,
			colorType = colorType
		}
	end

	local isOverseas = Utils.isOverseas()

	for _, id in ipairs(idList) do
		local entry = AttributeEntryData[id]

		if entry and (entry.country ~= 1 or not isOverseas) then
			result[#result + 1] = {
				id = id,
				desc = entry.desc,
				colorType = colorType
			}
		end
	end

	return result
end

function MonthCardUtils.getPrivilegeList()
	return MonthCardUtils.getPrivilegeListByIds(SysConfigData.MONTH_CARD_PRIVILEGE, 0)
end

function MonthCardUtils.getPrivilegeReduceHatchTime()
	local id = SysConfigData.MONTH_CARD_PRIVILEGE[2]
	local entry = id and AttributeEntryData[id] or nil

	return entry and entry.attrValue or 0
end

function MonthCardUtils.getCumulativeRewardConfig(days)
	return nil
end

function MonthCardUtils.getDailyRewardConfig()
	return nil
end

function MonthCardUtils.getImmediateRewardConfig()
	return nil
end

return MonthCardUtils
