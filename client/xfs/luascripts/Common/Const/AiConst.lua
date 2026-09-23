-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Const\\AiConst.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local BehaviorPathMapData = require("Common.Data.BehaviacData.Meta.BehaviorPathMapData")
local EntityTagData = require("Data.entity_tag_data")
local Const = require("Common.Const.Const")
local AiConst = {}

AiConst.AI_DEBUG = {
	MODE = true,
	NAVMESH_LOG = false,
	SELFIE = false,
	PERCEPTIBILITY_NO_IMP = false,
	PERCEPTIBILITY_ID = 0,
	PERCEPTIBILITY = false,
	EVENT_LOG = false,
	PORT = 60779,
	ENT_ID = 0,
	REGISTRATION_INFO = UNITY_EDITOR,
	NODE_LOG = {
		Console_Receive = false,
		Console_Send_Process = false,
		Console_Send_Property = false,
		EntId = -1,
		Enable = false
	}
}
AiConst.CPP = true
AiConst.CT_V2 = true
AiConst.GLOBAL_OPEN_TICK = true
AiConst.DefaultNullTable = Const.CACHED_EMPTY_TABLE
AiConst.BEHAVIOR_TABLE_SLOT = {
	AllShinning = "allShinningBehavTable",
	ShinningAdditive = "shinningAdditiveBehavTable",
	All = "allBehavTable",
	EliteAdditive = "eliteAdditiveBehavTable",
	Additive = "additiveBehavTable",
	AllElite = "allEliteBehavTable"
}
AiConst.TICK_INTERVAL = {
	Special = 1,
	Normal = 2
}
AiConst.PERCEPTIBILITY_INTERVAL = 0.5
AiConst.PERCEPTIBILITY_NO_IMP_INTERVAL = 1
AiConst.LOD = {
	High = 1,
	VeryLow = 10,
	Low = 5,
	Mid = 2
}
AiConst.TICK_TRIGGER_LOD = {
	High = 1,
	AllMulti = 300,
	VeryLow = 25,
	Low = 10,
	Mid = 3
}
AiConst.TICK_TRIGGER_LOD_NAME = "TickTriggerLOD"
AiConst.TICK_TRIGGER_NAME = "TickTrigger"
AiConst.ForceRunBtReason = {
	AFKMode = 1,
	Default = 0
}
AiConst.ResetStateType = {
	resume = 4,
	pause = 3,
	enter = 1,
	exit = 2
}
AiConst.PauseBtReason = {
	Capture = 16,
	ClientVisible = 15,
	Dead = 14,
	KnockUp = 13,
	KnockBack = 12,
	Charm = 11,
	BreakFall = 10,
	AppearDash = 9,
	Break = 8,
	Authority = 7,
	Summon = 6,
	InHit = 5,
	Stun = 4,
	Visible = 3,
	Control = 2,
	GM = 1,
	HomeInitPetData = 34,
	UltimateAbility = 35,
	SupportAbility = 36,
	SheepGather = 37,
	BeCarry = 38,
	Default = 0,
	Vehicle = 39,
	NpcDuelStart = 40,
	FishingCapture = 41,
	ArkPropshop = 42,
	PetCafeInteract = 43,
	ClientModelActive = 44,
	AnimatorReady = 45,
	SupportPet = 46,
	TouchPet = 47,
	SneakOutByHit = 48,
	NpcInteractUIEnd = 1999,
	NpcInteractUIStart = 1000,
	SceneLoading = 50,
	PhotoTimePause = 49,
	SkeletonLoaded = 33,
	DialogueControl = 32,
	HideShowEntityDic = 31,
	DummyClone = 30,
	AbilityAction = 29,
	InPetBall = 28,
	ChainAttack = 27,
	SandBoxLoading = 26,
	SpaceLoading = 25,
	VoxelLoading = 24,
	Microphone = 23,
	BeStick = 22,
	CombatControl = 21,
	DialogueGraph = 20,
	Attach = 19,
	Photo = 18,
	PlayAnimationScript = 17
}
AiConst.IgnoreAILodReason = {
	InPetBall = 1,
	Route = 0,
	GamePlay = 2
}
AiConst.IgnoreAILuaLodReason = 1
AiConst.PauseBtReasonNeedBreakPlan = {
	[AiConst.PauseBtReason.Control] = true,
	[AiConst.PauseBtReason.Capture] = true,
	[AiConst.PauseBtReason.TouchPet] = true
}
AiConst.SERVICE_REQUEST_TYPE = {
	FIND_PATH = 1,
	RAYCAST_HIT = 4,
	FIDN_RANDOM_POINT = 3,
	FIND_SAMPLE_POSITION = 2
}
AiConst.ACTION_TYPE = {
	MoveMode = 7,
	TemplateRef = 6,
	State = 5,
	ShowBubble = 4,
	PlayAnim = 3,
	Random = 2,
	Sequence = 1,
	Wait = 0
}
AiConst.PATH_STATE = {
	ACTION_EXITING = 3,
	ACTION_RUNNING = 2,
	PATROL = 1,
	EXITED = 4
}
AiConst.PATROL_SUB_STATE = {
	ST_PatrolWalk = 1,
	ST_None = 0,
	ST_Sleep = 4,
	ST_Rest = 3,
	ST_PatrolRun = 2
}
AiConst.PATROL_MOVE_MAX_TIME = 30
AiConst.PATROL_SPLINE_MAX_TIME = 120
AiConst.PATROL_SPLINE_LONG_MAX_TIME = 600
AiConst.PATROL_SUB_STATE_REV = {}

for k, v in pairs(AiConst.PATROL_SUB_STATE) do
	AiConst.PATROL_SUB_STATE_REV[v] = k
end

AiConst.CompositeType = {
	Sequence = 0,
	SelectorProbability = 1
}
AiConst.AUTO_PATH_CLOSE_LEN = 0.2
AiConst.FOLLOW_SAME_POS_SQR_DELTA = 0.01
AiConst.MAX_CHECK_DISTANCE = 400
AiConst.WALK_RANGE = 1.5
AiConst.WALK_MAX_HEIGHT = 2
AiConst.FOLLOW_ANIMATION_STATE_SWAP_TIME = 3
AiConst.FOLLOW_SPEED_SLOWDOWN_DEGREE = 70
AiConst.FOLLOW_SPEED_MAX_RATE = 1.2
AiConst.FOLLOW_SPEED_TARGET_RATE = 1.5
AiConst.FOLLOW_SPEED_MIN_RATE = 0.8
AiConst.FOLLOW_TOO_CLOSE = 0.5
AiConst.FOLLOW_CLOSE = 1.5
AiConst.FOLLOW_CLOSE_POW_2 = AiConst.FOLLOW_CLOSE * AiConst.FOLLOW_CLOSE
AiConst.FOLLOW_MID = 4
AiConst.FOLLOW_FAR = 5.5
AiConst.FOLLOW_TELEPORT = 20
AiConst.FOLLOW_MASTER_START_SPEED = 0.5
AiConst.FOLLOW_MASTER_SPEED_UP_SPEED = 4
AiConst.FOLLOW_LOCAL_MASTER_ANGLE = 150
AiConst.FOLLOW_SLOW_DOWN_TIME = 5
AiConst.FOLLOW_HEIGHT = 3
AiConst.PET_FOLLOW_DEGREE = 70
AiConst.PET_FOLLOW_RATIO = 0.66
AiConst.PET__FOLLOW_CAMERA_AFFECT_ANGLE = 80
AiConst.FOLLOW_SPEED_RATE = 0.7
AiConst.FOLLOW_RANGE_PLAN = 8
AiConst.FOLLOW_DEGREE = 120
AiConst.FOLLOW_CD = 20
AiConst.MAX_LEAVE_DISTANCE = 50
AiConst.LEVEL_DISTANCE = 10
AiConst.LEVEL_BACK_DISTANCE = 2
AiConst.MIN_LEAVE_DISTANCE = 2
AiConst.FLY_LEAVE_HEIGHT = 3
AiConst.DIRECTION_ANGLE = 60
AiConst.LEAVE_TARGET_DIRECTION_RECTIFIED_RATE = 0.9
AiConst.RANDOM_RADIUS = 2
AiConst.NAVMESH_RANDOM_RADIUS = 1
AiConst.MOVE_CD = 10
AiConst.NAVMESH_SERVICE_DEFAULIT_TIME = 10
AiConst.TARGET_POINT_STOP_DIST = 0.2
AiConst.STOP_DIST_MIN = 4
AiConst.SQUARE_TARGET_POINT_STOP_DIST = AiConst.TARGET_POINT_STOP_DIST * AiConst.TARGET_POINT_STOP_DIST
AiConst.DODGE_TIMEOUT = 2
AiConst.WALK_BACK_CD = 10
AiConst.CATCH_FAILURE_LEAVE_TIMEOUT = 10
AiConst.JUMP_TIME_OUT = 10
AiConst.JUMP_MAX_HEIGHT = 2
AiConst.DEFAULT_JUMP_MAX_DIST = 10
AiConst.EPSILON = 1.4013e-45
AiConst.KEEP_DIST_TIME = 1
AiConst.LET_GO_TIMEOUT = 5
AiConst.PET_PATROL_MATER_FORWARD = 10
AiConst.PET_PATROL_MASTER_BACK = -2
AiConst.PET_PATROL_RANGE_DEGREE = 45
AiConst.PET_MOVE_NEAR_DIST = 1
AiConst.PET_MOVE_ASIDE_EXTEND_DIST = 1
AiConst.PET_MOVE_ASIDE_MIN_DIST = 0.5
AiConst.PET_MOVE_ASIDE_MAX_DIST = 20
AiConst.PET_MOVE_ASIDE_ANGLE_RANGE = 150
AiConst.PET_MOVE_EXTRA_DIST_IN_SELFIE = 2
AiConst.PET_MOVE_RANGE_LENGTH_IN_SELFIE = 2
AiConst.PET_MOVE_RANGE_ANGLE_IN_SELFIE = 30
AiConst.PET_MOVE_OPTION_ANGLE_IN_SELFIE = 10
AiConst.PET_MOVE_REPATH_CD = 1
AiConst.TURN_YAW_MAX_TIME = 2
AiConst.LEAVE_REPTAH_CD = 0.7
AiConst.DEFAULT_REPATH_CD = 0.7
AiConst.BEHAVIOR_CD_REASON = {
	SuccessCD = 2,
	StartCD = 1,
	ActiveFailCD = 6,
	FailGCD = 5,
	SuccessGCD = 4,
	FailCD = 3
}
AiConst.MOVE_AROUND_POS_NUM = 18
AiConst.MOVE_AROUND_POS_DELTA_ANGLE = 10
AiConst.MOVE_AROUND_FADE_POS_NUM = 6
AiConst.HIDE_EMOJI_BUBBLE_TIMEOUT = 30
AiConst.SYNC_POINT_CUSTOM_INDEX = 10
AiConst.DEFAULT_ANIM_FADE_TIME = 0.2
AiConst.FLY_DEFAULT_STOP_DISTANCE = 0.2
AiConst.FLY_DEFAULT_TIMEOUT = 5
AiConst.FLY_AROUND_POS_NUM = 18
AiConst.FLY_AROUND_POS_DELTA_ANGLE = 10
AiConst.COMBO_INTERRUPT_PROB = 0.3
AiConst.PET_COMBO_INTERRUPT_PROB = 0.1
AiConst.AI_CONTROL_FLAG = {
	Capture = 2,
	Default = 1,
	Battle = 4
}
AiConst.PET_FEAR_LEVEL = 5
AiConst.PET_TELEPORT_DEGREE = {
	MaxDegree = 75,
	MinDegree = 45
}
AiConst.VOXEL_SEARCH_HEIGHT = 0.5
AiConst.PATROL_STATE = {
	WayPointBehaviorTurn = 5,
	WayPointBehavior = 4,
	MovingBehavior = 3,
	IntermittentPatrol = 2,
	Patrol = 1,
	Init = 0,
	Wait = 7,
	Jump = 9,
	Climb = 8,
	Disable = 6
}
AiConst.CLIMB_STATE = {
	ClimbEmoji = 3,
	ClimbWait = 2,
	ClimbMove = 1,
	ClimbOn = 0,
	ClimbDisable = 5,
	ClimbOff = 4
}
AiConst.ClimbType = {
	ClimbEmoji = 2,
	ClimbWait = 1,
	ClimbMove = 0
}
AiConst.CHARGE_SKILL_STATE = {
	Skill = 4,
	Charge = 3,
	initCharged = 2,
	Uncharged = 1
}
AiConst.DEFAULT_SENSOR_TREE_PATH_PRE = "MBTree/MBSubTree/"
AiConst.DEFAULT_PARMON_BEHAVIOR_TREE_PATH_PRE = "ParmonBehaviorTree/SubTree/"
AiConst.DEFAULT_PLAN_MIN_PRIORITY = -999999
AiConst.DEFAULT_PERCEPTIBLITY_ATTENUATION = -10
AiConst.PET_COMMAND_MODE = {
	Conductor = 2,
	Normal = 1
}
AiConst.DefaultAnimationClipLength = 0
AiConst.DefaultAnimationTimeout = 5
AiConst.DefaultSwitchStateTimeout = 10
AiConst.RemoteSyncSqrtDistance = 400
AiConst.DefaultGlideVelocityY = 2
AiConst.NAVMESH_SERVICE = {
	REQ_LOCAL_ID = 99,
	REQ_FAILED_ID = 0,
	REQ_MAX_ID = 2147483647,
	REQ_MIN_ID = 100
}
AiConst.AUTO_PATH_REQ_STATE = {
	PartialSuccessExceedDistance = 9,
	PartialSuccess = 8,
	ForceCancel = 7,
	Success = 6,
	ResponsePathDiscard = 5,
	SceneIdNotMatch = 3,
	ServicePathNotFound = 2,
	ServiceError = 1,
	Invalid = 0
}
AiConst.SMDefaultBaseState = {
	[BaseEnum.EBTRootState.ST_Root_Born] = BehaviorPathMapData.EnumNameMap.PBT_Behav_Com_Born,
	[BaseEnum.EBTRootState.ST_Root_Idle] = BehaviorPathMapData.EnumNameMap.PBT_Idle,
	[BaseEnum.EBTRootState.ST_Root_Alert] = BehaviorPathMapData.EnumNameMap.PBT_Idle,
	[BaseEnum.EBTRootState.ST_Root_Sensed] = BehaviorPathMapData.EnumNameMap.PBT_Idle,
	[BaseEnum.EBTRootState.ST_Root_Follow] = BehaviorPathMapData.EnumNameMap.PBT_FollowIdle,
	[BaseEnum.EBTRootState.ST_Root_Guide] = BehaviorPathMapData.EnumNameMap.PBT_Noop,
	[BaseEnum.EBTRootState.ST_Root_Combat] = BehaviorPathMapData.EnumNameMap.PBT_AutoCombat,
	[BaseEnum.EBTRootState.ST_Root_GoHome] = BehaviorPathMapData.EnumNameMap.PBT_GoHome,
	[BaseEnum.EBTRootState.ST_Root_Recruit] = BehaviorPathMapData.EnumNameMap.PBT_Noop,
	[BaseEnum.EBTRootState.ST_Root_Wait] = BehaviorPathMapData.EnumNameMap.PBT_Noop,
	[BaseEnum.EBTRootState.ST_Root_Dead] = BehaviorPathMapData.EnumNameMap.PBT_Noop,
	[BaseEnum.EBTRootState.ST_Root_Afk] = BehaviorPathMapData.EnumNameMap.PBT_Noop,
	[BaseEnum.EBTRootState.ST_Root_HomeLand] = BehaviorPathMapData.EnumNameMap.PBT_Behav_Home_IdlePatrol
}
AiConst.PetSMDefaultBaseState = {
	[BaseEnum.EBTRootState.ST_Root_Born] = BehaviorPathMapData.EnumNameMap.PBT_Noop,
	[BaseEnum.EBTRootState.ST_Root_Idle] = BehaviorPathMapData.EnumNameMap.PBT_FollowIdle,
	[BaseEnum.EBTRootState.ST_Root_Alert] = BehaviorPathMapData.EnumNameMap.PBT_FollowIdle,
	[BaseEnum.EBTRootState.ST_Root_Sensed] = BehaviorPathMapData.EnumNameMap.PBT_FollowIdle,
	[BaseEnum.EBTRootState.ST_Root_Follow] = BehaviorPathMapData.EnumNameMap.PBT_Pet_Follow,
	[BaseEnum.EBTRootState.ST_Root_Guide] = BehaviorPathMapData.EnumNameMap.PBT_Noop,
	[BaseEnum.EBTRootState.ST_Root_Combat] = BehaviorPathMapData.EnumNameMap.PBT_AutoCombat,
	[BaseEnum.EBTRootState.ST_Root_GoHome] = BehaviorPathMapData.EnumNameMap.PBT_GoHome,
	[BaseEnum.EBTRootState.ST_Root_Recruit] = BehaviorPathMapData.EnumNameMap.PBT_Noop,
	[BaseEnum.EBTRootState.ST_Root_Wait] = BehaviorPathMapData.EnumNameMap.PBT_Noop,
	[BaseEnum.EBTRootState.ST_Root_Dead] = BehaviorPathMapData.EnumNameMap.PBT_Noop,
	[BaseEnum.EBTRootState.ST_Root_Afk] = BehaviorPathMapData.EnumNameMap.PBT_Pet_Afk_Common,
	[BaseEnum.EBTRootState.ST_Root_HomeLand] = BehaviorPathMapData.EnumNameMap.PBT_Behav_Home_IdlePatrol
}
AiConst.ParmonPlanType = {
	EventPlan = 1,
	None = 999,
	NPCLeadPlan = 7,
	ClimbPlan = 6,
	SensorPlan = 5,
	BornPlan = 4,
	PatrolPlan = 3
}
AiConst.PatrolType = {
	Glide = 2,
	Normal = 1,
	Climb = 3,
	NPCLead = 4
}
AiConst.BehavType = {
	additive = "additive",
	base = "base"
}
AiConst.AIBeInterruptedType = {
	CanInterruptedByEP = 4,
	CanInterruptedBySelf = 2,
	CanInterruptedByHighPriority = 1
}
AiConst.Follow_Type = {
	Teleport = 5,
	SpeedUpFollow = 4,
	SlowDownFollow = 3,
	NormalFollow = 2,
	MoveAway = 1
}
AiConst.NpcStatusType = {
	Running = 1,
	Abort = 3,
	None = 0,
	Finish = 2
}
AiConst.EnvObjRVOType = {
	EnableStaticRVO = 1,
	EnableDynamicRVO = 2,
	Disable = 0
}
AiConst.RVODisableControlType = {
	SimpleMoveEntityFarDistance = 14,
	FarDistance = 14,
	BeGrab = 13,
	StaticSpawn = 12,
	NoCollision = 11,
	Dialogue = 10,
	HomePetEvent = 9,
	ControlPlayerSwitchToPet = 8,
	BeUnSummoned = 5,
	Authority = 4,
	BeStick = 6,
	Airing = 3,
	Visible = 7,
	Climb = 2,
	Disable = 1
}
AiConst.TeleportMinDistance = 0.1
AiConst.CatchMode_LowHPPercent = 0.2
AiConst.InvadeMode_PetCombatRange = 15
AiConst.AIControllerDisableReason = {
	ReasonNone = 0,
	BeStick = 16,
	Summon = 128,
	SwitchController = 512,
	SandBoxLoading = 2,
	SpaceLoading = 64,
	VoxelLoading = 4,
	Authority = 1024,
	BeControlled = 8,
	BeCaptured = 32,
	SceneLoading = 1,
	SkeletonLoaded = 2048
}
AiConst.MovementConst = {
	AreaDataType = {
		RelativeFocusPos = 1
	},
	PosUpdateStrategyType = {
		PetFollow = 1
	},
	ArriveStrategyType = {
		CommonArrive = 1
	}
}
AiConst.TrapNearBy = {
	height = 2,
	distance = 5
}
AiConst.MimicryState = {
	Defense = 1,
	None = 0,
	Fake = 2
}
AiConst.EBehaviorPatrolMoveType = {
	Jump = 1,
	Common = 0,
	Climb = 2
}
AiConst.HTNTaskType = {
	Compound = 2,
	None = 0,
	Primitive = 1
}
AiConst.AIDayTimeType = {
	Day = 1,
	None = 0,
	Night = 2
}
AiConst.WorldDayTime2AIDayTime = {
	[Const.TimePeriod.Morning] = AiConst.AIDayTimeType.Day,
	[Const.TimePeriod.Day] = AiConst.AIDayTimeType.Day,
	[Const.TimePeriod.Dusk] = AiConst.AIDayTimeType.Day,
	[Const.TimePeriod.Night] = AiConst.AIDayTimeType.Night
}
AiConst.HomePetMoveSpeed = 3
AiConst.HomePetMoveMaxTimeDelta = 1.5
AiConst.RequestBuffTimeout = 1
AiConst.DefaultPGCommonNone = "PG_Common_None"
AiConst.NpcReactionRange = 5
AiConst.CombatDodgeMaxTime = 0.2
AiConst.EAgentType = {
	PetAgent = 5,
	PetBallAgent = 6,
	PuppetAgent = 7,
	BotPlayerAgent = 4,
	CombatAgent = 3,
	WxAgent = 2,
	luaAgent = 1,
	VirtualAIAgent = 8
}
AiConst.CombatTag = EntityTagData.TE_Par_GroupCombat_TokenHolder.value
AiConst.BotPlayerDefaultCombatTactic = "Common"
AiConst.LuaMethodResetStateOffset = 1000
AiConst.DecelerationDisableReason = {
	AIDefault = 2,
	Logic = 1,
	None = 0
}
AiConst.SimpleMoveBehaviorMode = {
	PlaySleAnim = 3,
	PlaySingleAnim = 2,
	None = 0,
	Router = 1,
	FollowEntity = 4
}
AiConst.RouteType = {
	Simple = 1,
	Default = 0
}
AiConst.DefaultPathFindInvalidId = 0
AiConst.OfflineBehavGroupId = "BG_Wild_Com_IdlePatrol"
AiConst.BattleFieldRadius = 30
AiConst.clientMoveStateMap = {
	[CharacterStateConst.SNEAK] = function()
		return CharacterStateConst.SNEAKMOVE
	end,
	[CharacterStateConst.GROUND] = function()
		return CharacterStateConst.GROUNDWALK
	end,
	[CharacterStateConst.FLYING] = function()
		return CharacterStateConst.FLYMOVE
	end,
	[CharacterStateConst.CLIMBING] = function()
		return CharacterStateConst.CLIMBMOVE
	end,
	[CharacterStateConst.GLIDING] = function()
		return CharacterStateConst.GLIDEMOVE
	end,
	[CharacterStateConst.MIMICRY] = function()
		return CharacterStateConst.MIMICRYIDLE
	end,
	[CharacterStateConst.STATICSPAWN] = function()
		return CharacterStateConst.STATICSPAWNIDLE
	end,
	[CharacterStateConst.SPECIALMOVE] = function()
		return CharacterStateConst.SPECIALMOVEFORWARD
	end,
	[CharacterStateConst.SWIMMING] = function(SpeedRateType)
		if SpeedRateType == BaseEnum.SpeedRateType.Fast then
			return CharacterStateConst.SWIMFASTMOVE
		end

		return CharacterStateConst.SWIMMOVE
	end,
	[CharacterStateConst.LOCOMOTION] = function(SpeedRateType)
		if SpeedRateType == BaseEnum.SpeedRateType.Slow then
			return CharacterStateConst.WALK
		elseif SpeedRateType == BaseEnum.SpeedRateType.Fast then
			return CharacterStateConst.SPRINT
		elseif SpeedRateType == BaseEnum.SpeedRateType.Burst then
			return CharacterStateConst.SPEEDBURSTLOOP
		end

		return CharacterStateConst.RUN
	end
}
AiConst.serverMoveStateMap = {
	[CharacterStateConst.FLYING] = function()
		return CharacterStateConst.FLYMOVE
	end,
	[CharacterStateConst.LOCOMOTION] = function(SpeedRateType)
		if SpeedRateType == BaseEnum.SpeedRateType.Slow then
			return CharacterStateConst.WALK
		end

		return CharacterStateConst.RUN
	end
}
AiConst.idleStateMap = {
	[CharacterStateConst.SNEAK] = CharacterStateConst.SNEAKIDLE,
	[CharacterStateConst.FLYING] = CharacterStateConst.FLYHOVER,
	[CharacterStateConst.GROUND] = CharacterStateConst.GROUNDIDLE,
	[CharacterStateConst.CLIMBING] = CharacterStateConst.CLIMBIDLE,
	[CharacterStateConst.MIMICRY] = CharacterStateConst.MIMICRYIDLE,
	[CharacterStateConst.GLIDING] = CharacterStateConst.GLIDEIDLE,
	[CharacterStateConst.SWIMMING] = CharacterStateConst.SWIMIDLE,
	[CharacterStateConst.LOCOMOTION] = CharacterStateConst.IDLE
}

return AiConst
