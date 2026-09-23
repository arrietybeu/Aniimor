-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Const\\DungeonConst.lua

local Const = require("Common.Const.Const")
local DungeonConst = {}

DungeonConst.STATUS = {
	CLOSE = 6,
	REWARD = 5,
	PLAYING = 4,
	COUNT_DONW = 3,
	PLAYER_READY = 2,
	INIT = 1,
	CREATING = 0,
	DESTROY = 7
}
DungeonConst.STATUS_HANDLER = {
	[DungeonConst.STATUS.INIT] = "onStatusInit",
	[DungeonConst.STATUS.PLAYER_READY] = "onStatusPlayerReady",
	[DungeonConst.STATUS.COUNT_DONW] = "onStatusCountDown",
	[DungeonConst.STATUS.PLAYING] = "onStatusPlaying",
	[DungeonConst.STATUS.REWARD] = "onStatusReward",
	[DungeonConst.STATUS.CLOSE] = "onStatusClosed"
}
DungeonConst.SPACE_ENTER_POSITION_HANDLER = {
	[Const.SPACE_TYPE_ROBEGG] = "handleRobEggEnterPosition",
	[Const.SPACE_TYPE_ROBEGG_UNDERGROUND] = "handleRobEggEnterPosition"
}
DungeonConst.EXIT_MODE = {
	PLAYER_QUIT = 2,
	NORMAL = 1,
	UNKNOWN = 0
}
DungeonConst.PLAYER_RESULT = {
	UNKNOWN = 0,
	FAILED = 2,
	SUCCESS = 1
}
DungeonConst.ClientInfoDef = {
	isRestart = {
		"boolean",
		false
	}
}
DungeonConst.DisplayInfoDef = {
	uid = {
		"string",
		""
	},
	name = {
		"string",
		""
	},
	pets = {
		"table"
	}
}
DungeonConst.DungeonTarget = {
	KILL_ALL = 1,
	TIMED_KILL_ALL = 2
}
DungeonConst.DungeonDifficulty = {
	NORMAL = 2,
	HARD = 3,
	EASY = 1
}
DungeonConst.MULTIBOSS_REWARD_TRAIL_EFFECT = {
	[Const.MULTIBOSS_REWARD.FIRST_NORMAL] = "rewardNormalFly",
	[Const.MULTIBOSS_REWARD.NORMAL] = "rewardNormalFly",
	[Const.MULTIBOSS_REWARD.RARE] = "rewardRareFly",
	[Const.MULTIBOSS_REWARD.HELP] = "rewardHelpFly"
}
DungeonConst.MULTIBOSS_REWARD_GAIN_EFFECT = {
	[Const.MULTIBOSS_REWARD.FIRST_NORMAL] = "rewardGainNormal",
	[Const.MULTIBOSS_REWARD.NORMAL] = "rewardGainNormal",
	[Const.MULTIBOSS_REWARD.RARE] = "rewardGainRare",
	[Const.MULTIBOSS_REWARD.HELP] = "rewardGainHelp"
}
DungeonConst.ROGUE_ALL_BUFF_TYPE_ID = -1
DungeonConst.RobEggStage = {
	PVP = 2,
	Escape = 1,
	PEACE = 0
}
DungeonConst.RobEggMode = {
	SingleTeam = 2,
	MultiTeam = 1
}
DungeonConst.REASON = {
	FAIL = 2,
	SUCCESS = 1,
	OTHER = 3
}
DungeonConst.CHECK_CONTEXT = {
	CHANGE_TEAM_DUNGEON = 1
}

return DungeonConst
