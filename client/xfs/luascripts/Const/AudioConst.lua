-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Const\\AudioConst.lua

local bit = bit
local AudioConst = {
	EVENT_TEAM_ENTER_MEMBER_CONFIRM = "SFX_UI_ImoSurvey_GetClue",
	AUDIO_FOOT_MATERAIL_SWITCH_COIN = 9,
	EVENT_TEAM_ENTER_CANCEL = "SFX_UI_QTE_Click_03",
	AUDIO_FOOT_MATERAIL_SWITCH_METAL = 7,
	EVENT_TEAM_ENTER_CONFIRM = "SFX_UI_QTE_Click_01",
	AUDIO_FOOT_MATERAIL_SWITCH_TILE = 5,
	EVENT_TEAM_INVITE = "SFX_UI_Invitations",
	AUDIO_FOOT_MATERAIL_SWITCH_GRASS = 3,
	EVENT_UI_PET_REPORTER = "SFX_UI_Report",
	AUDIO_FOOT_MATERAIL_SWITCH_DIRT = 1,
	EVENT_HOME_AREA_UNLOCK = "SFX_UI_Home_Area_unlock",
	SFX_UI_PLAYER_LEARN_SKILL = "SFX_UI_Player_Learn_Skill",
	EVENT_HOME_ARCHITECTURE_PLACE = "SFX_UI_Home_Architecture_Place",
	SFX_UI_SHOP_BUY = "SFX_UI_Shop_Buy",
	EVENT_HOME_ARCHITECTURE_SELECT = "SFX_UI_Home_Architecture_Select",
	BGM_ROB_EGG_LIMIT_TIME_CHALLENGE = "BGM_HitAndRun_Temple_Jizhiguai_Danger",
	EVENT_HOME_ARCHITECTURE_CLICK = "SFX_UI_Home_Architecture_Click",
	SFX_ROGUE_SWEEP = "SFX_ROGUE_SWEEP",
	EVENT_HOME_ARCHITECTURE_TAB = "SFX_UI_Home_Architecture_Tab",
	BGM_ROGUE_ENTER_UI = "BGM_Rogue_EnterUI",
	EVENT_HOME_ARCHITECTURE_MODEL = "SFX_UI_Home_Architecture_Model",
	AUDIO_FOOT_MATERAIL_SWITCH_WATER = 2,
	EVENT_HOME_STOREHOUSE_CLOSE = "SFX_UI_Home_Storehouse_Close",
	SFX_ROGUE_SWEEP_FINISH = "SFX_ROGUE_SWEEP_FINISH",
	EVENT_HOME_STOREHOUSE_TRANSFER = "SFX_UI_Home_Storehouse_Transfer",
	AUDIO_FOOT_MATERAIL_SWITCH_SNOW = 4,
	EVENT_HOME_STOREHOUSE_CONFIRM = "SFX_UI_Home_Storehouse_Confirm",
	EVENT_PET_STARUP_BGM = "BGM_UI_GrowthInterface",
	EVENT_HOME_STOREHOUSE_CLICK = "SFX_UI_Home_Storehouse_Click",
	AUDIO_FOOT_MATERAIL_SWITCH_WOOD = 6,
	EVENT_HOME_STOREHOUSE_OPEN = "SFX_UI_Home_Storehouse_Open",
	EVENT_PET_STARUP_3 = "SFX_UI_GrowthInterface_Breakthrough",
	EVENT_DAILY_ACTIVE_CLAIM_REWARD = "SFX_UI_DailyActive_ClaimReward",
	AUDIO_FOOT_MATERAIL_SWITCH_ROPE = 8,
	EVENT_CHARACTER_DEBUT = "SFX_UI_CharacterDebut",
	BNK_SFX_HIT = "SFX_Hit",
	EVENT_GAMEPAD_MENU_OPEN = "SFX_UI_HUD_OptionMenu_Open",
	AUDIO_FOOT_MATERAIL_SWITCH_ICE = 10,
	EVENT_GAMEPAD_MENU_SELECTED_CHANGED = "SFX_UI_HUD_OptionMenu_Hover",
	EVENT_AVATAR_MERGE_APPEAR = "Avartar_Merge_Appear",
	AUDIO_SEX_SWITCH_MALE = 1,
	EVENT_AVATAR_MERGE_RECIEVE = "Avartar_Merge_Recive",
	EVENT_STOP_AMB_STEALTH_LOOP = "stop_SFX_Stealth_Loop",
	RTPC_PAMON_MOVEMENT = "RTPC_Parmon_Movement",
	EVENT_AMB_STEALTH_LOOP = "SFX_Stealth_Loop",
	MAP_SYSTEM_START = "SFX_UI_Personal_SystemStart",
	EVENT_PLAYER_BOW_AIM = "Player_Bow_Aim",
	MAP_ClEAR_FOG = "SFX_UI_Map_ClearFog",
	EVENT_PLAYER_COMMON_JUMP = "Player_Common_Jump",
	WATER_IN_OUT_Outside = "Outside",
	EVENT_PLAYER_COMMON_SPRINTSTOP = "Player_Common_SprintStop",
	WATER_IN_OUT_Inside = "Inside",
	EVENT_PLAYER_COMMON_SPRINT_BS = "Player_Common_SprintBs",
	WATER_IN_OUT = "Water_In_Out",
	EVENT_PLAYER_COMMON_FALL_TO_GROUND = "Player_Common_FallToGround",
	STATE_GROUP_GAME_MUSIC_STATE = "Game_Music_State",
	EVENT_PLAYER_COMMON_FOOT_STEP_STOP = "Player_Common_FootStepStop",
	GAME_WEATHER_EVENT = "SFX_AMB_Weather",
	EVENT_PLAYER_COMMON_FOOT_STEP = "Player_Common_FootStep",
	GAME_MUSIC_EVENT = "Play_Game_Music",
	Sound_Type_BowAim = "BowAim",
	STATE_GROUP_BGM_SCENE_MUSIC = "BGM_Scene_Music",
	Sound_Type_Jump = "Jump",
	ATTENUATION_STATE_ID_NORMAL = "normal",
	Sound_Type_SprintStop = "SprintStop",
	STATE_GROUP_ATTENUATION = "menu_attenuation",
	Sound_Type_SprintBs = "SprintBs",
	ATTENUATION_STATE_ID_ATTENUATION_ARK = "attenuation_ARK",
	Sound_Type_FallToGround = "FallToGround",
	STATE_GROUP_BGM_VOLUME = "bgm_volume",
	Sound_Type_FootStepStop = "FootStepStop",
	BGM_VOLUME_STATE_ID_ATTENUATION = "attenuation",
	Sound_Type_FootStep = "FootStep",
	BGM_VOLUME_STATE_ID_NORMAL = "normal",
	SWITCH_STATE_SURFACE_MATERIAL_DEFAULT = "concret",
	SWITCH_STATE_ID_GIRL = "Girl",
	SWITCH_GROUP_SURFACE_MATERIAL = "surface_material",
	SWITCH_GROUP_SEX = "VOX_Emotion_Sex",
	SWITCH_STATE_ID_BOY = "Boy",
	AUDIO_ELEMENT_SWITCH_ELETRIC = 5,
	AUDIO_ELEMENT_SWITCH_COLD = 4,
	AUDIO_ELEMENT_SWITCH_WATER = 3,
	AUDIO_ELEMENT_SWITCH_FIRE = 2,
	AUDIO_ELEMENT_SWITCH_EMPTY = 1,
	STEALTH_STATE_ID_STEALTH = "stealth",
	AUDIO_MATERIAL_TYPE_GRASS = "grass",
	ATTENUATION_STATE_ID_ATTENUATION = "attenuation",
	AUDIO_MATERIAL_TYPE_METAL = "metal",
	STEALTH_STATE_ID_NORMAL = "normal",
	AUDIO_MATERIAL_TYPE_STONE = "stone",
	STATE_GROUP_STEALTH = "Stealth_state",
	AUDIO_MATERIAL_TYPE_FLESH = "flesh",
	AUDIO_HIT_TYPE_HEAVY = "h",
	AUDIO_HIT_TYPE_LIGHT = "s",
	AUDIO_WEAPON_TYPE_SLASH = "slash",
	RTPC_FOOTSTEP_QIANGDAN = "RTPC_Footsteb_QiangDan",
	AUDIO_WEAPON_TYPE_BLUNT = "blunt",
	RTPC_VOLUME_EX = "RTPC_Volume_EX",
	EVENT_PET_STARUP_2 = "SFX_UI_GrowthInterface_UpgradeStar_Full",
	RTPC_VOLUME_3P = "RTPC_Volume_1P_3P",
	EVENT_PET_STARUP_1 = "SFX_UI_GrowthInterface_UpgradeStar",
	RTPC_TIME = "RTPC_Time",
	EVENT_ROGUE_SHOW_DUNGEON_PANEL = "SFX_UI_Rouge_LevelIntroduce",
	RTPC_WEATHER_TYPE = "RTPC_Weather_Type",
	EVENT_ROGUE_GO_NEXT_DUNGEON = "SFX_UI_Rouge_Portal",
	RTPC_BOSS_SKILL = "RTPC_Boss_Skill",
	EVENT_SHOW_RARE_BUFF = "SFX_UI_Rouge_RareBuffAppear",
	EVENT_PET_EXCHANGE_SUCCESS = "SFX_UI_Exchangepet_effect",
	EVENT_TEAM_SPEECH_CREATE = "SFX_UI_VoiceChannel_Creat",
	AUDIO_SEX_SWITCH_FEMALE = 2,
	EVENT_CATCH_RATE_FAIL = "SFX_UI_CatchRate_Fail",
	EVENT_CATCH_RATE_LOW = "SFX_UI_CatchRate_Low",
	EVENT_CATCH_RATE_HIGH = "SFX_UI_CatchRate_High",
	EVENT_CATCH_RATE_GRANTEED = "SFX_UI_CatchRate_Granteed",
	EVENT_FUNC_MENU_LOCK_ICON = "SFX_UI_LockIcon",
	EVENT_FUNC_MENU_FUNC_UNLOCK = "SFX_UI_UnlockIcon",
	INIT_LOADED_BANKS = {
		"SFX_Hit",
		"Player_Action",
		"Player_Skill",
		"FantasyBeast_Skill",
		"Monster_Boss",
		"UI_Common",
		"UI_FantasyBeast",
		"MUS_LingShou_TEST"
	},
	AUDIO_ELEMENT_SWITCH_MAP = {
		"Empty",
		"Fire",
		"Water",
		"Cold",
		"Electric",
		name = "Element"
	},
	AUDIO_FOOT_MATERAIL_SWITCH_MAP = {
		"Dirt",
		"Water",
		"Grass",
		"Snow",
		"Tile",
		"Wood",
		"Metal",
		"Rope",
		"Coin",
		"Ice",
		name = "Foot_Material"
	},
	AUDIO_SEX_SWICH_MAP = {
		"Male",
		"Female",
		name = "Sex"
	},
	COMBAT_RTPC_TYPE = {
		NONE = 0,
		VOLUME_HIT_1P_3P_LEVEL_2 = 8,
		VOLUME_HIT_1P_3P_LEVEL_1 = 4,
		VOLUME_EX = 2,
		VOLUME_3P = 1
	}
}

AudioConst.StateIdPriority = {
	[AudioConst.STATE_GROUP_BGM_VOLUME] = {
		[AudioConst.ATTENUATION_STATE_ID_ATTENUATION_ARK] = 2,
		[AudioConst.BGM_VOLUME_STATE_ID_ATTENUATION] = 1,
		[AudioConst.BGM_VOLUME_STATE_ID_NORMAL] = 0
	},
	[AudioConst.STATE_GROUP_ATTENUATION] = {
		[AudioConst.ATTENUATION_STATE_ID_ATTENUATION] = 1,
		[AudioConst.ATTENUATION_STATE_ID_NORMAL] = 0
	}
}
AudioConst.DEFAULT_SOUND_DATA = {
	[AudioConst.Sound_Type_FootStep] = AudioConst.EVENT_PLAYER_COMMON_FOOT_STEP,
	[AudioConst.Sound_Type_FootStepStop] = AudioConst.EVENT_PLAYER_COMMON_FOOT_STEP_STOP,
	[AudioConst.Sound_Type_FallToGround] = AudioConst.EVENT_PLAYER_COMMON_FALL_TO_GROUND,
	[AudioConst.Sound_Type_SprintBs] = AudioConst.EVENT_PLAYER_COMMON_SPRINT_BS,
	[AudioConst.Sound_Type_SprintStop] = AudioConst.EVENT_PLAYER_COMMON_SPRINTSTOP,
	[AudioConst.Sound_Type_Jump] = AudioConst.EVENT_PLAYER_COMMON_JUMP,
	[AudioConst.Sound_Type_BowAim] = AudioConst.EVENT_PLAYER_BOW_AIM
}
AudioConst.VolumeType = {
	Sfx = "sfx_bus_volume",
	BGM = "bgm_bus_volume",
	Vox = "vox_bus_volume",
	All = "master_audio_bus_volume"
}
AudioConst.SetVolumeReason = {
	Focus = 3,
	Loading = 2,
	Default = 1,
	MAX = 3
}
AudioConst.VolumeType2SetFunc = {
	bgm_bus_volume = "musicVol",
	sfx_bus_volume = "soundVol",
	master_audio_bus_volume = "mainVol",
	vox_bus_volume = "voiceVol"
}
AudioConst.AkCallbackType = {
	AK_MIDIEvent = 65536,
	AK_MusicSyncAll = 32512,
	AK_MusicSyncPoint = 16384,
	AK_MusicSyncUserCue = 8192,
	AK_MusicSyncGrid = 4096,
	AK_MusicSyncExit = 2048,
	AK_MusicSyncEntry = 1024,
	AK_MusicSyncBar = 512,
	AK_MusicSyncBeat = 256,
	AK_MusicPlayStarted = 128,
	AK_MusicPlaylistSelect = 64,
	AK_Starvation = 32,
	AK_SpeakerVolumeMatrix = 16,
	AK_Duration = 8,
	AK_Marker = 4,
	AK_EndOfDynamicSequenceItem = 2,
	AK_EndOfEvent = 1
}

function AudioConst.checkCallbackType(eventType, callbackType)
	return bit.band(eventType, callbackType) ~= 0
end

AudioConst.BgmPriority = {
	DeadPanel = 38,
	TimelineClip = 37,
	FishingCaptureCubeUI = 36,
	RogueUI = 35,
	PET_BALL_UI = 34,
	PetDetailScene = 33,
	PetResearchDetail = 32,
	PetResearch = 31,
	UI = 30,
	Cutscene = 39,
	Vitality_UI = 41,
	Scene = 1,
	BgmArea = 2,
	SoundArea = 3,
	SeamlessScene = 4,
	MAX = 41,
	Loading = 40,
	DialogueGraph = 24,
	PuzzleGame = 23,
	Level = 22,
	ExtraTempPet = 21,
	Avatar = 20,
	BossDeath = 19,
	Boss = 18,
	Elite = 17,
	Combat = 16,
	GrabEggDanger = 15,
	Login = 14,
	ClientEvent = 13,
	DefaultUI = 10,
	HomelandMusicPlayer = 7,
	SceneEmitter = 6,
	Room = 5
}
AudioConst.BGMCombatState = {
	Playing = 1,
	Stop = 3,
	Fading = 2
}
AudioConst.DisableAuxEnvReason = {
	Default = 1,
	Cutscene = 2
}
AudioConst.AttenGroupStateReason = {
	UI = "UI",
	PVP = "PVP",
	Default = "Default",
	Cutscene = "Cutscene"
}

return AudioConst
