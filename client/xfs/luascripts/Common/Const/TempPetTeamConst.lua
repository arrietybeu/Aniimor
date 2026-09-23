-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Const\\TempPetTeamConst.lua

local Const = require("Common.Const.Const")
local TempPetTeamConst = {}

TempPetTeamConst.CARRY_MODE_DISABLE = -1
TempPetTeamConst.CARRY_MODE_DEFAULT = 0
TempPetTeamConst.CARRY_MODE_BUFF_ONLY = 1
TempPetTeamConst.EXTRA_ATTR_KEY_PROPS = 1
TempPetTeamConst.EXTRA_ATTR_KEY_PROP_GROUPS = 2
TempPetTeamConst.EXTRA_ATTR_KEY_BUFF_IDS = 3
TempPetTeamConst.StrategyConfig = {
	[Const.PET_TEAM_TYPE_TMP_FAIR_PVP] = {},
	[Const.PET_TEAM_TYPE_TMP_UNFAIR_PVP] = {},
	[Const.PET_TEAM_TYPE_TMP_EVENT] = {},
	[Const.PET_TEAM_TYPE_TMP_STANDARD] = {},
	[Const.PET_TEAM_TYPE_TMP_BOSS_CHALLENGE] = {
		useTempExplore = false,
		useTempFormation = false,
		bypassControlLevel = true,
		forceDefaultCombat = false
	},
	[Const.PET_TEAM_TYPE_TMP_CATCH_ROGUE] = {},
	[Const.PET_TEAM_TYPE_TMP_ROBEGG] = {
		useTempExplore = false
	}
}
TempPetTeamConst.PVP_DEFAULT_GROUPID = 1
TempPetTeamConst.PVP_ROBEGG_GROUPID = 2
TempPetTeamConst.PVP_BOSSRUSH_GROUPID = 3
TempPetTeamConst.DefaultConfig = {
	useTempExplore = true,
	useTempFormation = true,
	recordCombatState = false,
	bypassControlLevel = false,
	forceDefaultCombat = true
}

return TempPetTeamConst
