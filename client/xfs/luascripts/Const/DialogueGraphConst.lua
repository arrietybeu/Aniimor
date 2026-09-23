-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Const\\DialogueGraphConst.lua

local UIConst = require("Const.UIConst")
local DialogueGraphConst = {
	ENTITY_PLAYER_SET_POSITION_DISTANCE_MAX = 25,
	ENTITY_PUPPET_SET_POSITION_DISTANCE_MAX = 40,
	DIALOGUE_GRAPH_ID_NAMING = 52753679,
	DIALOGUE_GRAPH_PLAY_APPROXIMATELY_EPS = 0.1,
	SKIPPING_DURATION = 1,
	SKIP_FLOW_TRIGGER_DELAY = 0.5,
	SKIPPING_WAIT_REPEAT_TIME = 0.1,
	SKIP_PLAY_SPEED = 100,
	ENTITY_CUSTOM_STATIC_ID_MAX = 10,
	MONSTER_PAUSE_AI_RANGE = 20,
	RET_FLAG_FAILED = -1,
	RET_FLAG_SUCCESS = 0,
	RES_ID = "$DialogueGraph_%d.asset",
	NODE_FUNC_TYPE = {
		DIALOGUE_GET_DIALOGSET_ENTITY_ID_BY_INDEX = "getDialogsetEntityIdByIndex",
		PLAYER_SWITCH_CROUCH = "switchCrouch",
		DIALOGUE_GET_DIALOGSET_ENTITY_ID_BY_ID = "getDialogsetEntityIdByID",
		ENTITY_CHECK_ENTITY_TAKE_OVER = "checkEntityTakeOver",
		DIALOGUE_GET_DIALOGSET_ROTATION_BY_INDEX = "getDialogsetRotationByIndex",
		ENTITY_SET_ENTITY_TAKE_OVER = "setEntityTakeOver",
		DIALOGUE_GET_DIALOGSET_ROTATION_BY_ID = "getDialogsetRotationByID",
		CONDITION_CHECK_TRIGGER = "isCompleteCondition",
		DIALOGUE_GET_DIALOGSET_POSITION_BY_INDEX = "getDialogsetPositionByIndex",
		CONDITION_CHECK_STATUS = "conditionCheckStatus",
		DIALOGUE_GET_DIALOGSET_POSITION_BY_ID = "getDialogsetPositionByID",
		SCENE_SET_CHARACTER_FILL_LIGHT = "setCharacterFillLight",
		DIALOGUE_START_GUIDE = "startGuide",
		SCENE_ATTACH_TO_GRAPH_ROOT = "attachToGraphRoot",
		DIALOGUE_TRIGGER_CUSTOM_CALLBACK = "triggerCustomCallback",
		SCENE_RESET_VOLUME = "resetVolume",
		DIALOGUE_CLEAR_NPC_OBSERVE = "clearNpcObserve",
		SCENE_STOP_VOLUME_ANIMATION = "stopVolumeAnimation",
		DIALOGUE_OPEN_NPC_OBSERVE = "openNpcObserve",
		SCENE_DISABLE_VOLUME = "disableVolume",
		DIALOGUE_IS_AUTO_PLAYING = "isAutoPlaying",
		SCENE_APPLY_VOLUME = "applyVolume",
		DIALOGUE_DISABLE_SKIP = "disableSkip",
		SCENE_STOP_LOCAL_ENVIRONMENT = "stopLocalEnvironment",
		DIALOGUE_ENABLE_SKIP = "enableSkip",
		SCENE_START_LOCAL_ENVIRONMENT = "startLocalEnvironment",
		DIALOGUE_DO_EVENT = "doEventByData",
		SCENE_DISABLE_LOCAL_WIND = "disableLocalWind",
		DIALOGUE_APPLY_DIALOGSET_CAMERA = "applyDialogsetCamera",
		SCENE_START_LOCAL_WIND = "startLocalWind",
		DIALOGUE_CANCEL_PENDING_DIALOGSET = "cancelPendingDialogset",
		SCENE_STOP_ENTITY_LIGHT = "stopEntityLight",
		DIALOGUE_ENTER_DIALOGSET = "enterDialogset",
		SCENE_DISABLE_ENTITY_LIGHT = "disableEntityLight",
		DIALOGUE_STOP_PLOT_PHONE_CALL_ANIM = "stopPlotPhoneCallAnim",
		SCENE_START_ENTITY_LIGHT = "startEntityLight",
		DIALOGUE_PLAY_PLOT_PHONE_CALL_ANIM = "playPlotPhoneCallAnim",
		SCENE_STOP_LIGHT = "stopLight",
		DIALOGUE_EXIT_PRESET = "exitDialoguePreset",
		SCENE_DISABLE_LIGHT = "disableLight",
		DIALOGUE_ENTER_DIALOGUE_PRESET = "enterDialoguePreset",
		SCENE_START_LIGHT = "startLight",
		DIALOGUE_STOP_SIMPLE_NPC_CALL_ANIM = "stopSimpleNpcCallAnim",
		DYNAMIC_VALUE_BIND = "bindDynamicValue",
		DIALOGUE_PLAY_SIMPLE_NPC_CALL_ANIM = "playSimpleNpcCallAnim",
		DYNAMIC_VALUE_CREATE_DISTANCE = "getOrCreateDynamicDistanceValue",
		DIALOGUE_CLOSE_DIALOG = "closeDialog",
		DYNAMIC_VALUE_CREATE_COLOR_GRADIENT = "getOrCreateColorGradientValue",
		DIALOGUE_SHOW_DIALOG = "showDialog",
		DYNAMIC_VALUE_CREATE_ANIMATION_CURVE = "getOrCreateAnimationCurveValue",
		DIALOGUE_SET_MODEL = "setDialogueGraphModel",
		ENTITY_AI_CHECK_RUNNING = "checkEntityAIRunning",
		SET_FUN_TYPE_STATE_CHECK_SET_MODE = "setFuncTypeStateCheckSetMode",
		ENTITY_PLAY_SWITCH_TO_PLAYER = "playSwitchToPlayer",
		INIT_ON_NODE_START = "initOnNodeStart",
		ENTITY_PLAY_SWITCH_TO_PET = "playSwitchToPet",
		PLAYER_SWITCH_PET = "switchPet",
		ENTITY_CREATE_REF_VIRTUAL = "createRefVirtualEntity",
		PLAYER_STATE_ON_DISMOUNT = "onDismount",
		ENTITY_GET_OR_CREATE_HOME_FACILITY_PROXY = "getOrCreateHomeFacilityProxy",
		PLAYER_STATE_ON_MOUNT = "onMount",
		ENTITY_GET_SANDBOX_LEVEL_ITEM_TRANSFORM = "getSandboxLevelItemTransform",
		SCENE_RESET_VEGETATION_CULLING = "resetVegetationCulling",
		ENTITY_IS_PLAYER_IDLE = "isPlayerIdle",
		SCENE_SET_VEGETATION_CULLING_DISABLED = "setVegetationCullingDisabled",
		ENTITY_RESET_PLAYER_ACTIONS = "resetPlayerActions",
		TOD_RESET_WEATHER = "resetWeather",
		ENTITY_IS_IDLE = "isEntityIdle",
		TOD_CHANGE_WEATHER = "changeWeather",
		ENTITY_PLAY_VISIBILITY_EFFECTS = "playEntitiesVisibilityEffect",
		EFFECT_STOP = "stopPlayEffect",
		ENTITY_PLAY_VISIBILITY_EFFECT = "playEntityVisibilityEffect",
		EFFECT_PLAY = "playEffect",
		ENTITY_DISABLE_DIALOGUE_CONTROLLER = "disableEntityDialogueController",
		EFFECT_GET_GENERATOR_ID = "getEffectGeneratorId",
		ENTITY_PLAY_ANIMATOR_STATE = "playAnimatorState",
		STOP_SOUND = "stopSound",
		ENTITY_STOP_FACIAL_ANIMATION = "stopEntityFacialAnimation",
		PLAY_SOUND = "playSound",
		ENTITY_PLAY_FACIAL_ANIMATION = "playEntityFacialAnimation",
		UNPRELOAD_CUTSCENE = "unPreloadCutScene",
		ENTITY_STOP_ANIMATION = "stopEntityAnimation",
		PRELOAD_CUTSCENE = "preloadCutscene",
		ENTITY_PLAY_ANIMATION = "playEntityAnimation",
		PLAY_CUTSCENE = "playCutscene",
		ENTITY_CHANGE_STATE = "changeEntityState",
		CAMERA_RESET_DIALOGSET = "resetDialogsetCamera",
		ENTITY_STEER = "steerEntity",
		CAMERA_STOP_SHAKE = "stopCameraShake",
		ENTITY_START_MOVE = "startEntityMove",
		CAMERA_START_SHAKE = "startCameraShake",
		ENTITY_CANCEL_MULTI_LOOK_AT = "cancelMultiLookAt",
		CAMERA_APPLY_DOF = "applyCameraDof",
		ENTITY_MULTI_LOOK_AT = "multiLookAt",
		CAMERA_SET_DOF_ACTIVE = "setCameraDofActive",
		ENTITY_FORBID_POSITION_CHECK = "forbidPositionCheck",
		CAMERA_CANCEL_GRAPH_BLEND = "cancelGraphCameraBlend",
		ENTITY_TRY_DETACH_FROM_VEHICLE = "tryDetachFromVehicle",
		CAMERA_START_GRAPH_BLEND = "startGraphCameraBlend",
		ENTITY_ENTITY_CANCEL_CAST_ABILITY = "entityCancelAbility",
		CAMERA_PLAYER_CANCEL_MODIFY_INFO = "cancelModifyPlayerCameraInfo",
		ENTITY_ENTITY_CAST_ABILITY = "entityCastAbility",
		CAMERA_PLAYER_MODIFY_INFO = "modifyPlayerCameraInfo",
		ENTITY_SHOW_BUBBLE_EMOJI = "entityShowBubbleEmoji",
		CAMERA_PLAYER_SET_ZOOM_AND_ROTATION = "setPlayerCameraZoomAndRotation",
		ENTITY_CANCEL_LOOK_AT_ROLE = "cancelLookAtRole",
		CAMERA_APPLY_BLEND_TO_FIXED = "applyCameraBlendToFixed",
		ENTITY_LOOK_AT_ROLE = "lookAtRole",
		CAMERA_CANCEL_BLEND_TO_FIXED = "cancelBlendToFixed",
		ENTITY_CAN_PLAY_SPECIAL_IDLE = "canPlaySpecialIdleInDialogueGraph",
		CAMERA_BLEND_TO_FIXED = "cameraBlendToFixed",
		ENTITY_SET_ANIM_SPEED = "setEntityAnimSpeed",
		CAMERA_ENABLE_NPC_DIALOGUE_CAMERA = "enableNpcDialogueCamera",
		ENTITY_RESUME_BT = "resumeBt",
		UI_WAIT_CLOSE = "waitUIClose",
		ENTITY_PAUSE_BT = "pauseBt",
		UI_CLOSE_UI = "closeUI",
		ENTITY_STOP_AUTO_PATH_FINDING = "stopEntityAutoPathFinding",
		UI_SHOW_UI = "showUI",
		ENTITY_AUTO_PATH_FINDING = "entAutoPathFinding",
		UI_CLOSE_WHITE_SCREEN = "closeWhiteScreen",
		ENTITY_TRY_ATTACH_ON_VEHICLE = "tryAttachOnVehicle",
		UI_SHOW_WHITE_SCREEN = "showWhiteScreen",
		UI_CLOSE_BLACK_SCREEN = "closeBlackScreen",
		UI_SHOW_BLACK_SCREEN = "showBlackScreen"
	},
	NODE_PRIORTTY = {
		RESTRICTED = 5,
		CRITICAL = 4,
		HIGH = 3,
		MED = 2,
		LOW = 1
	},
	PRIORITY = {
		LOW = 0,
		HIGH = 1000,
		EXTREME_LOW = -1,
		MED = 500
	},
	PLAYBACK_DECISION = {
		PARALLEL = 1,
		DISCARD = 4,
		INTERRUPT = 3,
		QUEUE = 2
	},
	DIALOGUE_GRAPH_STATE = {
		DESTROY = 4,
		STOP = 3,
		PLAYING = 2,
		READY = 1,
		NONE = 0
	},
	PLAYBACK_PERMISSION = {
		AUTO_PLAY = 2,
		TURN_ON = 1,
		SKIP = 4,
		SKIP_DISABLED_FORCE = 8,
		NONE = 0
	},
	PLAYBACK_STATE = {
		NORMAL = 1,
		AUTO_PLAYING = 2,
		SKIPPING = 3,
		NONE = 0
	},
	FINISHED_REASON = {
		INTERRUPTED_FORCE_CLOSE_SERVER = "INTERRUPTED_FORCE_CLOSE_SERVER",
		INTERRUPTED_FORCE_CLOSE_EDITOR = "INTERRUPTED_FORCE_CLOSE_EDITOR",
		INTERRUPTED_LEAVE_SCENE = "INTERRUPTED_LEAVE_SCENE",
		INTERRUPTED_DISCONNECTED = "INTERRUPTED_DISCONNECTED",
		INTERRUPTED_CLEAR = "INTERRUPTED_CLEAR",
		INTERRUPTED_PLAYING = "INTERRUPTED_PLAYING",
		INTERRUPTED_PRIORITY = "INTERRUPTED_PRIORITY",
		INTERRUPTED_CRITICAL = "INTERRUPTED_CRITICAL",
		FINISHED = "FINISHED"
	},
	MODEL_TYPE = {
		NORMAL = 1,
		CUSTOM = 3,
		FREEDOM = 2
	},
	MODE_TYPE = {
		Control = 2,
		Freedom = 1,
		None = 0
	},
	HideAllUIWhiteList = {
		[UIConst.UI_ID_TOPLOGO] = true,
		[UIConst.UI_ID_NPC_CALL] = true,
		[UIConst.UI_ID_SKIP_PANEL] = true,
		[UIConst.UI_ID_DIALOGUE_ID] = true,
		[UIConst.UI_ID_GUIDE_PANEL] = true,
		[UIConst.UI_ID_NET_LOADING] = true,
		[UIConst.UI_ID_AI_ASSISTANT] = true,
		[UIConst.UI_ID_QTE_TIMELINE] = true,
		[UIConst.UI_ID_FISHING_CAPTURE_CONTRACT] = true,
		[UIConst.UI_ID_BLACK_SCREEN] = true,
		[UIConst.UI_ID_WHITE_SCREEN] = true,
		[UIConst.UI_PHOTO_SHOW_TIP] = true,
		[UIConst.UI_ID_DIALOG_REVIEW] = true,
		[UIConst.UI_ID_SUBTITLES_PANEL] = true,
		[UIConst.UI_ID_PLOT_PHONE_CALL] = true,
		[UIConst.UI_ID_BOTTOM_DIALOGUE] = true,
		[UIConst.UI_ID_CONFIG_TOPPING] = true,
		[UIConst.UI_ID_COMMON_CONFIRM] = true,
		[UIConst.UI_ID_DIALOGUE_SKIP] = true,
		[UIConst.UI_ID_GUIDE_POPUP_PANEL] = true,
		[UIConst.UI_ID_PET_SELECTION_PANEL] = true,
		[UIConst.UI_ID_COMMON_SKIP_PANEL] = true,
		[UIConst.UI_ID_BLACK_SCREEN_SKIP_PANEL] = true,
		[UIConst.UI_ID_SCENE_SELECTION_PANEL] = true,
		[UIConst.UI_ID_NATURAL_SELECTION_PANEL] = true,
		[UIConst.UI_ID_BLACK_CHANGE] = true
	},
	MobilePlatformWhiteList = {
		[UIConst.UI_ID_HUD_MOBILE_OPERATE] = true
	},
	CloseAllPanelWhiteList = {
		[UIConst.UI_ID_DEAD_PANEL] = true
	},
	GraphType = {
		SinglePlayer = 1,
		MultiPlayer = 2
	},
	EntityType = {
		HomeFacility = 5,
		VirtualEntity = 4,
		Pawn = 3,
		Puppet = 2,
		PlayerPet = 1,
		Player = 0
	},
	VIRTUAL_ENTITY_TYPE = {
		PLAYER_MATE_4 = 7,
		PLAYER_MATE_3 = 6,
		PLAYER_MATE_2 = 5,
		PLAYER_MATE_1 = 4,
		PLAYER_PET = 3,
		NPC = 2,
		PLAYER = 1
	},
	SETTING_KEY = {
		DIALOGUE_GRAPH_PLAY_SPEED = "playSpeed",
		DIALOGUE_GRAPH_AUTO_PLAY = "autoPlay"
	},
	DialogsetEnterType = {
		Teleport = 1,
		Move = 2
	},
	DialogsetSlotType = {
		VirtualNpc = 4,
		Npc = 3,
		MainPlayerPet = 2,
		MainPlayer = 1
	},
	SideEffectCategory = {
		IdempotentCommit = 2,
		Commit = 1,
		Rollbackable = 1
	},
	EventBlockWhiteList = {
		"Camera/ShowCursor"
	}
}
local FUNC_TYPE = DialogueGraphConst.NODE_FUNC_TYPE
local NODE_PRIORTTY = DialogueGraphConst.NODE_PRIORTTY

DialogueGraphConst.NODE_FUNC_MAP = {
	[FUNC_TYPE.DIALOGUE_SET_MODEL] = {
		priority = NODE_PRIORTTY.HIGH,
		stateCheckFunc = FUNC_TYPE.SET_FUN_TYPE_STATE_CHECK_SET_MODE
	},
	[FUNC_TYPE.DIALOGUE_SHOW_DIALOG] = {
		cancelFunc = FUNC_TYPE.DIALOGUE_CLOSE_DIALOG,
		priority = NODE_PRIORTTY.HIGH
	},
	[FUNC_TYPE.DIALOGUE_CLOSE_DIALOG] = {
		relatedFunc = FUNC_TYPE.DIALOGUE_SHOW_DIALOG,
		priority = NODE_PRIORTTY.HIGH
	},
	[FUNC_TYPE.DIALOGUE_PLAY_SIMPLE_NPC_CALL_ANIM] = {
		cancelFunc = FUNC_TYPE.DIALOGUE_STOP_SIMPLE_NPC_CALL_ANIM,
		priority = NODE_PRIORTTY.HIGH
	},
	[FUNC_TYPE.DIALOGUE_STOP_SIMPLE_NPC_CALL_ANIM] = {
		relatedFunc = FUNC_TYPE.DIALOGUE_PLAY_SIMPLE_NPC_CALL_ANIM,
		priority = NODE_PRIORTTY.HIGH
	},
	[FUNC_TYPE.DIALOGUE_ENTER_DIALOGUE_PRESET] = {
		cancelFunc = FUNC_TYPE.DIALOGUE_EXIT_PRESET,
		priority = NODE_PRIORTTY.HIGH
	},
	[FUNC_TYPE.DIALOGUE_EXIT_PRESET] = {
		relatedFunc = FUNC_TYPE.DIALOGUE_ENTER_DIALOGUE_PRESET,
		priority = NODE_PRIORTTY.HIGH
	},
	[FUNC_TYPE.DIALOGUE_PLAY_PLOT_PHONE_CALL_ANIM] = {
		cancelFunc = FUNC_TYPE.DIALOGUE_STOP_PLOT_PHONE_CALL_ANIM,
		priority = NODE_PRIORTTY.HIGH
	},
	[FUNC_TYPE.DIALOGUE_STOP_PLOT_PHONE_CALL_ANIM] = {
		relatedFunc = FUNC_TYPE.DIALOGUE_PLAY_PLOT_PHONE_CALL_ANIM,
		priority = NODE_PRIORTTY.HIGH
	},
	[FUNC_TYPE.UI_SHOW_BLACK_SCREEN] = {
		cancelFunc = FUNC_TYPE.UI_CLOSE_BLACK_SCREEN,
		priority = NODE_PRIORTTY.HIGH
	},
	[FUNC_TYPE.UI_CLOSE_BLACK_SCREEN] = {
		relatedFunc = FUNC_TYPE.UI_SHOW_BLACK_SCREEN,
		priority = NODE_PRIORTTY.HIGH
	},
	[FUNC_TYPE.UI_SHOW_WHITE_SCREEN] = {
		cancelFunc = FUNC_TYPE.UI_CLOSE_WHITE_SCREEN,
		priority = NODE_PRIORTTY.HIGH
	},
	[FUNC_TYPE.UI_CLOSE_WHITE_SCREEN] = {
		relatedFunc = FUNC_TYPE.UI_SHOW_WHITE_SCREEN,
		priority = NODE_PRIORTTY.HIGH
	},
	[FUNC_TYPE.UI_SHOW_UI] = {
		priority = NODE_PRIORTTY.HIGH
	},
	[FUNC_TYPE.CAMERA_ENABLE_NPC_DIALOGUE_CAMERA] = {
		priority = NODE_PRIORTTY.HIGH
	},
	[FUNC_TYPE.CAMERA_BLEND_TO_FIXED] = {
		cancelFunc = FUNC_TYPE.CAMERA_CANCEL_BLEND_TO_FIXED,
		priority = NODE_PRIORTTY.HIGH
	},
	[FUNC_TYPE.CAMERA_APPLY_BLEND_TO_FIXED] = {
		cancelFunc = FUNC_TYPE.CAMERA_CANCEL_BLEND_TO_FIXED,
		priority = NODE_PRIORTTY.HIGH
	},
	[FUNC_TYPE.CAMERA_PLAYER_SET_ZOOM_AND_ROTATION] = {
		priority = NODE_PRIORTTY.HIGH
	},
	[FUNC_TYPE.CAMERA_CANCEL_BLEND_TO_FIXED] = {
		relatedFunc = FUNC_TYPE.CAMERA_BLEND_TO_FIXED
	},
	[FUNC_TYPE.CAMERA_PLAYER_MODIFY_INFO] = {
		cancelFunc = FUNC_TYPE.CAMERA_PLAYER_CANCEL_MODIFY_INFO,
		priority = NODE_PRIORTTY.HIGH
	},
	[FUNC_TYPE.CAMERA_PLAYER_CANCEL_MODIFY_INFO] = {},
	[FUNC_TYPE.PLAY_CUTSCENE] = {
		priority = NODE_PRIORTTY.CRITICAL
	},
	[FUNC_TYPE.TOD_CHANGE_WEATHER] = {
		priority = NODE_PRIORTTY.HIGH
	},
	[FUNC_TYPE.TOD_RESET_WEATHER] = {
		priority = NODE_PRIORTTY.HIGH
	},
	[FUNC_TYPE.PLAYER_STATE_ON_MOUNT] = {
		checkFunc = FUNC_TYPE.ENTITY_CHECK_ENTITY_TAKE_OVER
	},
	[FUNC_TYPE.PLAYER_STATE_ON_DISMOUNT] = {
		checkFunc = FUNC_TYPE.ENTITY_CHECK_ENTITY_TAKE_OVER
	},
	[FUNC_TYPE.PLAYER_SWITCH_PET] = {
		checkFunc = FUNC_TYPE.ENTITY_CHECK_ENTITY_TAKE_OVER
	},
	[FUNC_TYPE.PLAYER_SWITCH_CROUCH] = {
		checkFunc = FUNC_TYPE.ENTITY_CHECK_ENTITY_TAKE_OVER
	},
	[FUNC_TYPE.ENTITY_SET_ENTITY_TAKE_OVER] = {
		priority = NODE_PRIORTTY.HIGH,
		checkFunc = FUNC_TYPE.ENTITY_CHECK_ENTITY_TAKE_OVER
	},
	[FUNC_TYPE.ENTITY_TRY_ATTACH_ON_VEHICLE] = {
		priority = NODE_PRIORTTY.HIGH,
		checkFunc = FUNC_TYPE.ENTITY_CHECK_ENTITY_TAKE_OVER
	},
	[FUNC_TYPE.ENTITY_AUTO_PATH_FINDING] = {
		priority = NODE_PRIORTTY.HIGH,
		checkFunc = FUNC_TYPE.ENTITY_CHECK_ENTITY_TAKE_OVER
	},
	[FUNC_TYPE.ENTITY_PAUSE_BT] = {
		cancelFunc = FUNC_TYPE.ENTITY_RESUME_BT
	},
	[FUNC_TYPE.ENTITY_RESUME_BT] = {
		relatedFunc = FUNC_TYPE.ENTITY_PAUSE_BT
	},
	[FUNC_TYPE.ENTITY_LOOK_AT_ROLE] = {
		cancelFunc = FUNC_TYPE.ENTITY_CANCEL_LOOK_AT_ROLE
	},
	[FUNC_TYPE.ENTITY_CANCEL_LOOK_AT_ROLE] = {
		relatedFunc = FUNC_TYPE.ENTITY_LOOK_AT_ROLE
	},
	[FUNC_TYPE.ENTITY_ENTITY_CAST_ABILITY] = {
		relatedFunc = FUNC_TYPE.ENTITY_ENTITY_CANCEL_CAST_ABILITY
	},
	[FUNC_TYPE.ENTITY_ENTITY_CANCEL_CAST_ABILITY] = {
		relatedFunc = FUNC_TYPE.ENTITY_ENTITY_CAST_ABILITY,
		checkFunc = FUNC_TYPE.ENTITY_CHECK_ENTITY_TAKE_OVER
	}
}
DialogueGraphConst.PRIORITY_MAP = {
	[DialogueGraphConst.PRIORITY.EXTREME_LOW] = {
		[DialogueGraphConst.PRIORITY.EXTREME_LOW] = DialogueGraphConst.PLAYBACK_DECISION.INTERRUPT,
		[DialogueGraphConst.PRIORITY.LOW] = DialogueGraphConst.PLAYBACK_DECISION.INTERRUPT,
		[DialogueGraphConst.PRIORITY.MED] = DialogueGraphConst.PLAYBACK_DECISION.INTERRUPT,
		[DialogueGraphConst.PRIORITY.HIGH] = DialogueGraphConst.PLAYBACK_DECISION.INTERRUPT
	},
	[DialogueGraphConst.PRIORITY.LOW] = {
		[DialogueGraphConst.PRIORITY.EXTREME_LOW] = DialogueGraphConst.PLAYBACK_DECISION.DISCARD,
		[DialogueGraphConst.PRIORITY.LOW] = DialogueGraphConst.PLAYBACK_DECISION.PARALLEL,
		[DialogueGraphConst.PRIORITY.MED] = DialogueGraphConst.PLAYBACK_DECISION.INTERRUPT,
		[DialogueGraphConst.PRIORITY.HIGH] = DialogueGraphConst.PLAYBACK_DECISION.INTERRUPT
	},
	[DialogueGraphConst.PRIORITY.MED] = {
		[DialogueGraphConst.PRIORITY.EXTREME_LOW] = DialogueGraphConst.PLAYBACK_DECISION.DISCARD,
		[DialogueGraphConst.PRIORITY.LOW] = DialogueGraphConst.PLAYBACK_DECISION.PARALLEL,
		[DialogueGraphConst.PRIORITY.MED] = DialogueGraphConst.PLAYBACK_DECISION.QUEUE,
		[DialogueGraphConst.PRIORITY.HIGH] = DialogueGraphConst.PLAYBACK_DECISION.INTERRUPT
	},
	[DialogueGraphConst.PRIORITY.HIGH] = {
		[DialogueGraphConst.PRIORITY.EXTREME_LOW] = DialogueGraphConst.PLAYBACK_DECISION.DISCARD,
		[DialogueGraphConst.PRIORITY.LOW] = DialogueGraphConst.PLAYBACK_DECISION.PARALLEL,
		[DialogueGraphConst.PRIORITY.MED] = DialogueGraphConst.PLAYBACK_DECISION.QUEUE,
		[DialogueGraphConst.PRIORITY.HIGH] = DialogueGraphConst.PLAYBACK_DECISION.QUEUE
	}
}
DialogueGraphConst.ModelTypeMap = {
	[DialogueGraphConst.MODEL_TYPE.NORMAL] = {
		hideAllUI = true,
		resetAllActions = true,
		blockEvent = true,
		exitCatchMode = true,
		hideTopLogo = true
	},
	[DialogueGraphConst.MODEL_TYPE.FREEDOM] = {
		hideAllUI = true,
		hideTopLogo = true
	},
	[DialogueGraphConst.MODEL_TYPE.CUSTOM] = {}
}
DialogueGraphConst.BlendFunction = {
	Cubic = 4,
	EaseInOut = 3,
	EaseOut = 2,
	EaseIn = 1,
	Linear = 0
}
DialogueGraphConst.MovementType = {
	OrbitalMovement = 2,
	LocalMovement = 1,
	None = 0
}
DialogueGraphConst.MovementMode = {
	PingPong = 2,
	Loop = 1,
	Once = 0
}

local VirCamBlendFunction = CS.FunPlus.WorldX.VirtualCamera.VirtualCameraBlendFunction

DialogueGraphConst.CameraBlendFunction = {
	Linear = VirCamBlendFunction.Linear,
	EaseIn = VirCamBlendFunction.EaseIn,
	EaseOut = VirCamBlendFunction.EaseOut,
	EaseInOut = VirCamBlendFunction.EaseInOut,
	Cubic = VirCamBlendFunction.Cubic
}
DialogueGraphConst.DIALOGUE_GRAPH_LEGACY_TOPLOGO_COMPONENTS = {
	"multiPlayer"
}
DialogueGraphConst.DIALOGUE_STATE_KEY = {
	HIDE_MARK_SHARE = "hideMarkShare",
	STATE_CONFLICT = "stateConflict",
	HIDE_INTERACTION_SIGN = "hideInteractionSign",
	DISABLE_SPACE_FOLLOW = "disableSpaceFollow",
	HIDE_ENTITIES = "hideEntities",
	HIDE_TOP_LOGO = "hideTopLogo",
	HIDE_ALL_UI = "hideAllUI",
	AMBIENT_INTENSITY = "ambientIntensity"
}

return DialogueGraphConst
