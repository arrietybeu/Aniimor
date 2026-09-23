-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Const\\RobEggConst.lua

local NoticeDef = require("Common.NoticeDef")
local Const = require("Common.Const.Const")
local RobEggConst = {
	EGG_SHIP_TRANSFER_NO_EGG_TEXT_COLOR = "#F67574",
	EGG_SHIP_TRANSFER_HAS_EGG_TEXT_COLOR = "#FFFFFF",
	CALCINATION_ENTRY_ENABLED = false,
	PVP_MODE_ENTRY_ENABLED = false,
	GM_SKIP_ENTER_CHECK = false,
	ROBEGG_BILOG_EXPENSIVE_ITEM_SELL_PRICE_LOG = 5000000
}

RobEggConst.RobEggTalentEffectType = {
	ROBEGG_AND_OUTSIDE = 2,
	ROBEGG_DUNGEON = 1
}
RobEggConst.RobEggTalentEventType = {
	ROBEGG_AND_OUTSIDE = 3,
	ROBEGG_DUNGEON = 1,
	OUTSIDE = 2,
	UNLOCK_TALENT = 4
}
RobEggConst.ROB_EGG_TALENT_EVENT_EFFECT = {
	LOOT_SPEED_UP = 1,
	DUMMY = 0
}
RobEggConst.LIMITTIME_STATE = {
	READY = 1,
	REWARD = 4,
	FINISH = 3,
	BEGIN = 2
}
RobEggConst.LIMIT_DURING_TIME = {
	REWARDTELPORTTIME = 50,
	REWARDDURINGTIME = 0.5,
	BEGINDURINGTIME = 60,
	CLIENTBEGINWAITTIME = 1.5,
	READYDURINGTIME = 10,
	CLIENTREADYWAITTIME = 1.5
}
RobEggConst.PROXIMITY_MAP_MARK_ACTIVE_DISTANCE = {
	[1997] = 30,
	[1996] = 30,
	[1998] = 30,
	[1999] = 30
}
RobEggConst.SYNC_MARK_TYPE = {
	LUCKY_MOUSE = 1
}
RobEggConst.SYNC_MARK_CONFIG_ID = {
	[RobEggConst.SYNC_MARK_TYPE.LUCKY_MOUSE] = 1021
}
RobEggConst.SCENE_CHECK = {
	[3004] = {
		checkFunc = "prepareEnterFairMode",
		noticeId = NoticeDef.ROB_EGG_MATES_BRING_FORBID_ITEM
	}
}
RobEggConst.ROBEGG_TICKET = {
	[Const.DungeonDifficultLevel.CHAOS] = {
		ticketId = 5200002
	}
}
RobEggConst.ROBEGG_NEWER_GUIDE = {
	GoToSubmitEgg = 3,
	GooutDG = 2,
	GoToDG = 1
}
RobEggConst.ROBEGG_LEVEL_SCORE_PROTECT_REASON = {
	Newer = 1,
	Dummy = 0
}

return RobEggConst
