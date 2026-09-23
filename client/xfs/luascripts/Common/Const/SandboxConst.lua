-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Const\\SandboxConst.lua

local SandboxConst = {}

SandboxConst.SANDBOX_TYPE = {
	ARK = 3,
	DUNGEON = 2,
	SIMPLE = 1,
	NORMAL = 0
}
SandboxConst.AUTO_LOAD = {
	[SandboxConst.SANDBOX_TYPE.NORMAL] = true,
	[SandboxConst.SANDBOX_TYPE.DUNGEON] = true
}
SandboxConst.STATE = {
	HANGING = 1,
	LOADING = 0,
	FINISHED = 3,
	RUNNING = 2
}
SandboxConst.PROCESS = {
	CREATE = 0,
	PHASE = 4,
	RESET = 3,
	COMPLETE = 2,
	DESTROY = 1
}
SandboxConst.PHASE_CHANGE_REASON = {
	INTERNAL = 1,
	EXTERNAL = 2
}
SandboxConst.DESTROY_REASON = {
	METEOROLOGY = 9,
	BLOCK = 8,
	METEOR_OVER = 7,
	PLAYER_NOT_EXIST = 6,
	PLAYER_LEAVE = 5,
	LOAD = 3,
	MANUAL = 2,
	CHUNK = 1,
	RELOAD = 11,
	COMPLETE = 4,
	TIME_ACTIVE = 10
}
SandboxConst.RESET_TYPE = {
	NEW_DAY = 5,
	SECOND = 4,
	OTHER = 3,
	WEEK = 2,
	DAY = 1,
	NEW_WEEK = 6
}
SandboxConst.SIGHT_LEVEL = {
	FAR = 256,
	FARFARAWAY = 1024,
	FARAWAY = 512,
	NORMAL = 128,
	NEAR = 64,
	GLOBAL = -1
}
SandboxConst.ACTIVE_TYPE = {
	METEOROLOGY = 11,
	BLOCK = 10,
	DUNGEON_FINISHED = 5,
	SANDBOX_FINISHED = 6,
	TIME_ACTIVE = 12,
	MANUAL = 4,
	CONDITIONID = 13,
	WEATHER = 9,
	METEOR = 8,
	SANDBOX_DESTROY = 7,
	ACTIVITY = 3,
	QUEST = 2,
	INIT = 1
}
SandboxConst.ACTIVE_QUEST_TYPE = {
	QUEST_IN_SUBMIT = 4,
	QUEST_IN_COMPLETE = 3,
	QUEST_IN_ACCEPT = 2,
	QUEST_COMPLETED = 1,
	QUEST_ACCEPTED = 0
}
SandboxConst.ON_FINISH = {
	CLEAR = 2,
	FADE_OUT = 1,
	RETAIN_ONCE = 4,
	RETRAIN = 3
}
SandboxConst.LEVEL_ITEM_TYPE = {
	FOSSIL_BABY = "FossilBaby",
	GROUP_SING_PUZZLE = "GroupSingPuzzle",
	CONDENSE_WATER_BOUND_ITEM = "CondenseWaterBoundItem",
	SEQUENCE_SOUND = "SequenceSound",
	SPURT_ITEM = "SpurtItem",
	LEVEL_BUTTON = "LevelButton",
	TOTEM_PUZZLE = "TotemPuzzle",
	CHEST_SHIELD = "ChestShield",
	STUN_MUSHROOM = "StunMushroom",
	PRESS_PLATFORM = "PressPlatform",
	PET_EXCHANGE = "PetExchangeItem",
	BUFF_TRIGGER = "BuffTrigger",
	PLANT_NURSERY = "PlantNursery",
	TRICK_TRIGGER = "TrickTrigger",
	PLANT_TREE = "PlantTree",
	TimelineContainer = "TimelineContainer",
	DITTO_ENTRY = "DittoEntry",
	CHEST_CONTAINER = "ChestContainer",
	ADD_INTERACT = "AddInteract",
	SEESAW = "Seesaw",
	HitCounter = "HitCounter",
	TRIGGER = "Trigger",
	GRAB_EGG_DOOR = "GrabEggDoor",
	PLATFORM_PRO = "PlatformPro",
	ChallengeDoor = "ChallengeDoor",
	MOVING_PLATFORM = "MovingPlatform",
	BALL_TARGET_SB = "BallTargetSB",
	SWITCH = "Switch",
	GRID_CELL = "GridCell",
	LEVEL_ITEM = "LevelItem",
	TimerSB = "TimerSB",
	DialoguePlayer = "DialoguePlayer",
	MeetingPlace = "MeetingPlace",
	Rope = "Rope",
	GRID_GAME = "GridGame",
	PAINT_AREA = "PaintArea",
	ROTATING_PLATFORM = "RotatingPlatform",
	DUNGEON_SAVE_POINT = "DungeonSavePoint",
	TimelineExchange = "TimelineExchange",
	TWINKLE_PLATFORM_CONTROLLER = "TwinklePlatformController",
	QUICK_CONTROL = "QuickControl",
	BILATERATOTEM = "BilateralTotem",
	SLUDGE = "Sludge",
	AUDIO_TRIGGER = "AudioTrigger",
	SLUDGE_FIELD = "SludgeField",
	PIANO = "Piano",
	SLUDGE_PILE = "SludgePile",
	POSITION_BLENDER = "PositionBlender",
	CONDENSE_WATER_STONE = "CondenseWaterStone",
	MICROPHONE = "Microphone",
	EVENT_TRIGGER = "EventTrigger",
	MECHANISM_BALL_HOLE = "MechanismBallHole",
	LEVEL_ITEM_MULTI = "LevelItemMulti",
	ECHO_STONE = "EchoStone",
	ECHO_LINK = "EchoLink",
	LEVEL_MULTI_INTERACT = "LevelItemMultiInteractor",
	COLLECT_ITEM_PUZZLE = "CollectItemPuzzle",
	BEE_FLOWER = "BeeFlower",
	RACE_PUZZLE = "RacePuzzle",
	RETROSPECT_CHEST = "RetrospectChest",
	TRAMPOLINE = "Trampoline"
}
SandboxConst.SUB_COMPONENT_TYPE = {
	FollowState = "FollowState",
	Interactable = "Interactable",
	Retrospectable = "Retrospectable",
	DynamicVoxelSB = "DynamicVoxelSB",
	SpawnerControl = "SpawnerControl"
}
SandboxConst.LEVEL_ITEM_STATE = {
	ACTIVE = 1,
	INIT = 0
}
SandboxConst.LEVEL_ITEM_MILTI_STATE = {
	TRIGGER = 2,
	WAIT = 1,
	INIT = 0
}
SandboxConst.LEVEL_MULTI_INTERACT_STATE = {
	TRIGGER = 2,
	WAIT = 1,
	FINISH = 3,
	INIT = 0
}
SandboxConst.LEVEL_DITTO_ENTRY_STATE = {
	FINISH = 1,
	CD = 2,
	ACTIVE = 0
}
SandboxConst.NPC_SP_STATE_2_DITTO_STATE = {
	[1000] = SandboxConst.LEVEL_DITTO_ENTRY_STATE.ACTIVE,
	[1001] = SandboxConst.LEVEL_DITTO_ENTRY_STATE.FINISH
}
SandboxConst.MECHANISM_BALL_HOLE_STATE = {
	TRIGGER = 1,
	INIT = 0
}
SandboxConst.OPERATORS = {
	[">"] = 8,
	["<="] = 12,
	["<"] = 11,
	["=="] = 10,
	ceil = 7,
	floor = 6,
	["%"] = 5,
	["/"] = 4,
	["*"] = 3,
	["+"] = 1,
	["-"] = 2,
	[">="] = 9
}
SandboxConst.LOGICAL = {
	NOT = 3,
	OR = 2,
	AND = 1
}
SandboxConst.FIELDS_HANDLER = {
	state = "onStateChange"
}
SandboxConst.EVENT_TYPE = {
	SLUDGE_PROGRESS_CHANGED = 9,
	BUBBLE_BARRIER_SHELL_EXIT = 8,
	BUBBLE_BARRIER_SHELL_STAY = 7,
	BUBBLE_BARRIER_DISTORT = 6,
	BUBBLE_BARRIER_HIT = 5,
	OVERLAP_COUNTER_FREE = 4,
	OVERLAP_COUNTER_BUSY = 3,
	TRIGGER_LEAVE = 2,
	TRIGGER_ENTER = 1,
	BUBBLE_BARRIER_LEAVE = 14,
	BUBBLE_BARRIER_ENTER = 13,
	SLUDGE_CELL_REFRESHED = 12,
	SLUDGE_CELL_CLEARED = 11,
	SLUDGE_RESET = 10
}
SandboxConst.EVENT_TYPE_TRIGGER = {
	TRIGGER_ENTER = 1,
	TRIGGER_LEAVE = 2
}
SandboxConst.EVENT_TYPE_OVERLAP = {
	OVERLAP_COUNTER_BUSY = 3,
	OVERLAP_COUNTER_FREE = 4
}
SandboxConst.EVENT_TYPE_BUBBLE_BARRIER = {
	BUBBLE_BARRIER_ENTER = 13,
	BUBBLE_BARRIER_SHELL_EXIT = 8,
	BUBBLE_BARRIER_SHELL_STAY = 7,
	BUBBLE_BARRIER_DISTORT = 6,
	BUBBLE_BARRIER_HIT = 5,
	BUBBLE_BARRIER_LEAVE = 14
}
SandboxConst.COMMON_EVENT = {
	TIME_PUZZLE_WARN = "OnTimePuzzleWarning",
	TEAMATE_VIEW_CHANGE = "TeammateViewChange",
	TIME_PUZZLE_START = "OnTimePuzzleStart",
	PLAYER_TOGGLE_PET = "PLAYER_TOGGLE_PET",
	TIME_TRAVEL_TO_NOW = "TIME_TRAVEL_TO_NOW",
	TIME_TRAVEL_TO_LAST = "TIME_TRAVEL_TO_LAST",
	PET_EVOLUTION_COMPLETED = "PET_EVOLUTION_COMPLETED",
	BEE_FLOWER_HARVESTED = "BeeFlowerHarvested",
	PLAYER_HURT = "OnPlayerHurt",
	ARK_VIDEO_REFRESH = "OnArkVideoRefresh",
	ITEM_INTERACT_TRIGGER = "ITEM_INTERACT_TRIGGER",
	DEAD = "OnDead",
	CURRENT_AREA_WEATHER_REFRESH = "OnCurrentAreaWeatherRefresh",
	LEVELITEM_ENTER_MAGNESIS = "OnEnterMagnesis",
	PET_GHOST_EYE_STATE_CHANGED = "OnPetGhostEyeStateChanged",
	TIME_PUZZLE_RESET = "OnTimePuzzleReset",
	TIME_PUZZLE_SUCC = "OnTimePuzzleSuccess",
	TIME_PUZZLE_FAIL = "OnTimePuzzleFail"
}
SandboxConst.DITTO_STATE = {
	OUT_OF_RANGE = 5,
	REPEAT_ACTIVE = 4,
	FAIL = 3,
	SUCCESS = 2,
	FIRST_ACTIVE = 1,
	INACTIVE = 0
}
SandboxConst.DITTO_STATE_HANDLER = {
	[SandboxConst.DITTO_STATE.INACTIVE] = "onStatusInactive",
	[SandboxConst.DITTO_STATE.FIRST_ACTIVE] = "onStatusFirstActive",
	[SandboxConst.DITTO_STATE.SUCCESS] = "onStatusSuccess",
	[SandboxConst.DITTO_STATE.FAIL] = "onStatusFail",
	[SandboxConst.DITTO_STATE.REPEAT_ACTIVE] = "onStatusRepeatActive",
	[SandboxConst.DITTO_STATE.OUT_OF_RANGE] = "onOutOfRange"
}
SandboxConst.DITTO_DUNGEON_STATE = {
	FAIL = 1,
	START = 0,
	SUCCESS = 2
}
SandboxConst.DITTO_DUNGEON_RESULT = {
	DEAD = 5,
	ACTIVE = 1,
	FAIL = 3,
	SUCCESS = 2,
	EXIT = 4,
	DEFAULT = 0
}
SandboxConst.PET_CHALLENGE_RESULT = {
	OUT_OF_RANGE = 2,
	MANUALFAIL = 8,
	TIMEOUT = 6,
	CATCH_SHEEP = 5,
	DAMAGE_SHEEP = 4,
	CANCEL_CONTROL = 3,
	PLAYER_DEAD = 1,
	SUCCESS = 7,
	INIT = 0
}
SandboxConst.MONITOR_ATTRIBUTE = {
	SP = "getSpPercent",
	HP = "getHpPercent",
	BREAK = "getBreakPercent",
	EP = "getEpPercent"
}
SandboxConst.COMPARE_OP = {
	["!="] = 6,
	["<="] = 5,
	["<"] = 4,
	["=="] = 3,
	[">="] = 2,
	[">"] = 1
}
SandboxConst.GroupPuzzleState = {
	Disable = 0,
	Finish = 5,
	PlayingCutscene = 4,
	Failed = 3,
	Success = 2,
	Playing = 1
}
SandboxConst.RacingDungeonState = {
	COUNT_DONW = 1,
	NONE = 0,
	END = 3,
	RACING = 2
}
SandboxConst.RacePuzzleState = {
	Default = 0,
	Playing = 2,
	CountDown = 1
}
SandboxConst.RacePuzzleResultState = {
	Success = 1,
	Fail = 2
}
SandboxConst.ResetPuzzleReason = {
	Fail = 1,
	Break = 2,
	None = 0
}
SandboxConst.RaceScore = {
	S = 0,
	B = 2,
	A = 1
}
SandboxConst.CollectPuzzleState = {
	Default = 0,
	Playing = 2,
	CountDown = 1
}
SandboxConst.CollectPuzzleResultState = {
	Success = 1,
	Fail = 2
}
SandboxConst.PaintAreaState = {
	WaitOpenChest = 1,
	Ready = 0,
	Finish = 2
}
SandboxConst.GridCellState = {
	FAIL = 3,
	FLOWER = 2,
	GRASS = 1,
	EMPTY = 0
}
SandboxConst.GridGameState = {
	SUCCESS = 3,
	FAILED = 2,
	PLAYING = 1,
	WAITING = 0
}
SandboxConst.BEE_FLOWER_STATE = {
	COOLDOWN = 2,
	OPEN = 1,
	CLOSED = 0
}
SandboxConst.FOSSIL_BABY_STATE = {
	CLEARED = 2,
	HATCHED = 1,
	FOSSIL = 0
}
SandboxConst.RETROSPECT_CHEST_STATE = {
	OPENED = 2,
	CREATED = 1,
	HIDDEN = 0
}
SandboxConst.Permission = {
	OwnerInScene = 1,
	OnlyOwner = 0
}
SandboxConst.FINISH_TYPE = {
	Graph = 0,
	Chest = 1
}
SandboxConst.NODE_TARGET_TYPE = {
	SpaceOwner = 1,
	AllPlayersInSandbox = 0,
	SpecifiedPlayer = 2
}
SandboxConst.Role = {
	Owner = 1,
	All = 0
}
SandboxConst.SYNC_MODE = {
	OWNER_SAVE_ONLY = 2,
	OWNER_SAVE_ITEM = 1,
	ALL_SYNC = 0,
	OWNER_FULL = 3
}
SandboxConst.DEBUG_LOAD_RANGE = {
	ALL = -114514
}
SandboxConst.COMMON_RESULT = {
	FAILED = 2,
	SUCCESS = 1,
	DEFAULT = 0
}

return SandboxConst
