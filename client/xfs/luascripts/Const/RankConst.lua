-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Const\\RankConst.lua

local RankConst = {}

RankConst.EMPTY_VALUE_TEXT = "--"
RankConst.DisplayInfoType = {
	BATTLE_BUFF_ICONS = 7,
	BEST_SCORE = 6,
	PET_INFO = 5,
	PLAYER_LEVEL = 4,
	PET_TEAM_INFO = 3,
	TEAM_INFO = 2,
	PLAYER_INFO = 1
}
RankConst.TargetType = {
	USDF_TEXT = 1,
	PET_INFO = 4,
	PLAYER_TEAM_LAYOUT = 6,
	ICON_LAYOUT = 5,
	MEMBER_LAYOUT = 3,
	PLAYER_INFO = 2
}

local TARGET_TYPE = RankConst.TargetType

RankConst.DisplayNodeResIds = {
	[TARGET_TYPE.USDF_TEXT] = "$UI_Node_RankingItem_Score.prefab",
	[TARGET_TYPE.PLAYER_INFO] = "$UI_Node_RankingItem_PlayerName.prefab",
	[TARGET_TYPE.MEMBER_LAYOUT] = "$UI_Node_RankingItem_Team.prefab",
	[TARGET_TYPE.PET_INFO] = "$UI_Node_RankingItem_PetName.prefab",
	[TARGET_TYPE.ICON_LAYOUT] = "$UI_Node_RankingItem_Icon.prefab",
	[TARGET_TYPE.PLAYER_TEAM_LAYOUT] = "$UI_Node_RankingItem_PlayerTeamTeam.prefab"
}

return RankConst
