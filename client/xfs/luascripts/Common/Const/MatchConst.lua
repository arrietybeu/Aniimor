-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Const\\MatchConst.lua

local RoomConst = require("Common.Const.RoomConst")
local MatchConst = {}

MatchConst = {
	MATCH_STATUS_IN_MARKAGAIN = 10,
	MATCH_STATUS_IN_DUNGEON = 9,
	MATCH_STATUS_IN_ROOM = 8,
	MATCH_STATUS_IN_MATCH = 7,
	MATCH_STATUS_IN_MODIFYTEAM = 6,
	MATCH_STATUS_IN_REPLY = 5,
	MATCH_STATUS_IN_INVITE = 4,
	MATCH_STATUS_IN_AGAIN = 3,
	MATCH_STATUS_IN_MARKSUCC = 2,
	MATCH_STATUS_INIT = 1,
	MatchTypeDungeon = 203,
	MatchTypeTeam = 202,
	MatchTypeSingle = 201,
	MatchTypeRobEgg = 102,
	MatchTypeUnFairPVP1V1Debug = 101,
	MatchTypeFairPVP1V1Debug = 100,
	MatchTypeInvitePVP1V1_Fair = 4,
	MatchTypePVP1V1_UnFair = 2,
	MatchTypePVP1V1_Fair = 1,
	MatchTypeNone = 0,
	PVP1V1_2V2_POOLID = 3,
	PVP1V1_1V3_POOLID = 2,
	TEAM_DEFAULT_POOLID = 1,
	PVP1V1_DEFAULT_POOLID = 0,
	INVITEPVP1V1 = {
		ST_MARK = 4,
		ST_MATCH = 3,
		ST_PREPARE = 2,
		ST_INVITE = 1,
		ST_INIT = 0,
		ST_AGAIN = 5
	},
	INVITE_RESULT = {
		CHECK_FAILED = 1,
		SUCCESS = 0,
		TIME_OUT = 2
	},
	CONTRACT_BATTLE = {
		ST_PVP_UNLOCK = 7,
		ST_PLAYER_OFFLINE = 9,
		ST_PLAYER_DEAD = 8,
		ST_INIT = 1,
		ST_OTHER_INTERFACE = 6,
		ST_IN_BATTLE = 5,
		ST_IN_DIALOGUEPRO = 4,
		ST_IN_DUNGEON = 3,
		ST_IN_TEAM = 2
	},
	PvpCheckType = {
		Formation = 1,
		Matching = 2
	},
	ErrorCode = {
		NO_ALL_READY = 6,
		PLAYER_NUM = 5,
		NO_LEADER = 4,
		INNER_ERR = 3,
		MATCHING = 2,
		SWITCH_CLOSE = 1
	},
	SuitType = {
		Regular = 1,
		FirstTeam = 2
	},
	SuitCondition = {
		Power = 2,
		Level = 1
	},
	MatchLogType = {
		Success = 1,
		Reject = 3,
		Cancel = 2
	}
}
MatchConst.DEFAULT_POOL_CAPACITY = 1000
MatchConst.DEFAULT_CAMP_COUNT = 10
MatchConst.DEFAULT_CAMP_MEMBER_COUNT = 4
MatchConst.MATCH_TIMEOUT_SEC = 300
MatchConst.MAX_FIND_TIMES = 50
MatchConst.ONCE_TICK_COUNT = 200
MatchConst.TICK_OUT_TIME = 20
MatchConst.MATCH_FILTER_CONDITION = {
	MATCH_FILTER_CLASS_INFO = 100,
	MATCH_FILTER_ROB_EGG_RANK = 3,
	MATCH_FILTER_POWER = 2,
	MATCH_FILTER_LEVEL = 1,
	MATCH_FILTER_SCORE = 0
}
MatchConst.CLASS_MATCH_TYPE = {
	REGION = 3,
	COUNTRY = 2,
	CLASS = 1
}
MatchConst.CLASS_MATCH_SCOPE = {
	[MatchConst.CLASS_MATCH_TYPE.CLASS] = 1,
	[MatchConst.CLASS_MATCH_TYPE.COUNTRY] = 10000,
	[MatchConst.CLASS_MATCH_TYPE.REGION] = 1000000
}
MatchConst.MATCH_SUIT_VALUE_PROJECTION = {
	[MatchConst.MATCH_FILTER_CONDITION.MATCH_FILTER_LEVEL] = "level",
	[MatchConst.MATCH_FILTER_CONDITION.MATCH_FILTER_POWER] = "playerCp",
	[MatchConst.MATCH_FILTER_CONDITION.MATCH_FILTER_ROB_EGG_RANK] = "robEggRank"
}
MatchConst.SUIT_METHOD_TYPE = {
	SUIT_METHOD_FIXED = 1,
	SUIT_METHOD_WEIGHT = 2
}
MatchConst.MATCH_UNIT_TYPE = {
	MERGE = 3,
	TEAM = 2,
	PLAYER = 1
}
MatchConst.MATCH_PLAN_TYPE = {
	PLAYER_COUNT = 2,
	CAMP_COUNT = 1
}
MatchConst.MATCH_ADD_MEM_TYPE = {
	BAN_AUTO_ADD = 0,
	FORCE_AUTO_ADD = 2,
	AUTO_ADD = 1
}
MatchConst.MATCH_PHASE_STAGE = {
	MERGE_TEAM = 1,
	ENTER_GAME = 4,
	CONFIRMING = 3,
	MATCH_CAMP = 2
}
MatchConst.MATCH_TEAM_MEMBER_TYPE = {
	MATCH_BOT_ENTER = 2,
	MATCH_MEMBER_ENTER = 1,
	DIRECTLY_ENTER = 0
}
MatchConst.MatchWeightTile = "weightValue"
MatchConst.MatchSuitValueTile = "suitValue"
MatchConst.MatchSuitWeightTile = "suitWeight"

return MatchConst
