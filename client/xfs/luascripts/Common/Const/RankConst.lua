-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Const\\RankConst.lua

local ResetType = {
	SeasonHalf = 4,
	Month = 3,
	Week = 2,
	Day = 1,
	None = 0,
	Custom = 6,
	SeasonFull = 5
}
local RankConst = {
	MaxRankIdLength = 128,
	RefreshOffset = 0,
	OpenType = {
		Season = 2,
		Launch = 1,
		Custom = 4,
		FixedTime = 3
	},
	ResetType = ResetType,
	SettleType = {
		SeasonHalf = 4,
		Month = 3,
		Week = 2,
		Day = 1,
		SeasonFull = 5
	},
	TemporarySettle = {
		Normal = 0,
		Skip = 2,
		Previous = 1
	},
	ShowEnum = {
		PlayerInfo = 1,
		BossRushBuffSelect = 8,
		BossRushBattlePet = 7,
		BossRushBestScore = 6,
		PetInfo = 5,
		PlayerLevel = 4,
		PetTeamInfo = 3,
		TeamInfo = 2
	},
	ConfigFieldForInfo = {
		"extraInfo1",
		"extraInfo2",
		"extraInfo3",
		"extraInfo4"
	}
}

RankConst.RefreshType = ResetType
RankConst.OpenType.LaunchDay = RankConst.OpenType.Launch
RankConst.OpenType.SeasonStuff = RankConst.OpenType.Season
RankConst.OpenType.ConfigDay = RankConst.OpenType.FixedTime
RankConst.SettleType.None = 0

return RankConst
