-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Const\\FishingCaptureConst.lua

local FISHING_CAPTURE_CONFIG_DATA = require("Data.fishing_capture_config_data")
local FishingCaptureConst = {}

FishingCaptureConst.ActivityStage = {
	WindkissCompanion = 3,
	IrisCompanion = 2,
	FlowerGathering = 1
}
FishingCaptureConst.ActivityTabState = {
	ConditionLocked = 3,
	CountdownLocked = 2,
	Unlocked = 1
}
FishingCaptureConst.CubeType = {
	LEGEND = 1,
	SEASON = 2
}
FishingCaptureConst.SeasonCubeState = {
	CanBuild = 2,
	Exhausted = 1,
	Insufficient = 0
}
FishingCaptureConst.Phase = {
	SETTLE = 5,
	CAPTURE = 4,
	TRANSITION = 3,
	BATTLE = 2,
	READY = 1
}
FishingCaptureConst.EntranceType = {
	Final = 2,
	Weekly = 1
}
FishingCaptureConst.SettleReason = {
	PLAYER_DEAD = 6,
	DISCONNECT = 5,
	PLAYER_QUIT = 4,
	BOSS_ESCAPE = 3,
	TIMEOUT = 2,
	CAPTURE_SUCCESS = 1
}
FishingCaptureConst.TICKET_ITEM_ID = 1018
FishingCaptureConst.TICKET_SHOP_ITEM_ID = 360005
FishingCaptureConst.FAIL_TIME_ID = 402
FishingCaptureConst.DUNGEON_EXIT_DELAY_TIME = 60
FishingCaptureConst.SFX_ACTIVITY_UI = "SFX_UI_BossCatch_huodongjiemian_Loop"
FishingCaptureConst.SFX_CUBE_MADE = "SFX_FC_CUBE_MADE"
FishingCaptureConst.SFX_CONTRACT_SHOW = "SFX_FC_CONTRACT_SHOW"
FishingCaptureConst.SFX_CONTRACT_STAY = "SFX_FC_CONTRACT_STAY"
FishingCaptureConst.SFX_CONTRACT_DOWN = "SFX_FC_CONTRACT_DOWN"
FishingCaptureConst.SFX_CAPTURE_SUCCESS = "SFX_UI_BossCatch_CaptureSuccess"
FishingCaptureConst.BGM_CUBE_BUILD_UI = "BGM_UI_BuildTheCube_Irily"
FishingCaptureConst.BGM_CONTRACT_END = "BGM_Operations_Catch_Irily_02"
FishingCaptureConst.BLACK_FOG_SCREEN_EFFECT_KEY = "Eff_Env_Sceneobject_BossCatch_BlackFog_Screen"
FishingCaptureConst.IRIS_ITEM_ID = 1017
FishingCaptureConst.WINDKISS_COMMISSION_LETTER = 1027
FishingCaptureConst.CubeType = {
	LEGEND = 1,
	SEASON = 2
}
FishingCaptureConst.SOURCE = {
	ANIIMO_RESEARCH = 2006,
	SILVER_BADGE = 2028,
	LEYLINE_TREE_NOURISHMENT = 5101,
	ELITE_LINKER_CHALLENGE = 20012,
	BOSS_FIRST_CLEAR = 9005,
	GATHERING = 2007,
	JOURNEY_QUESTS = 10058,
	MAIN_STORY = 2009,
	EVENT_SHOP = 1005,
	MEDAL_SHOP = 5000,
	FADED_RAINBOW = 20040,
	CLUE_TRACKING = 10050
}
FishingCaptureConst.CUBE_REWARD_COUNT = 1

function FishingCaptureConst.get(key)
	local v = FISHING_CAPTURE_CONFIG_DATA and FISHING_CAPTURE_CONFIG_DATA[key]

	if v ~= nil then
		return v
	end

	return FishingCaptureConst[key]
end

return FishingCaptureConst
