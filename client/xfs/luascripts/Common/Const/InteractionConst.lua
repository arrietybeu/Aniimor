-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Const\\InteractionConst.lua

local InteractionConst = {
	INTERACTION_TYPE_INTERACT_ANIMATION = 187,
	INTERACTION_TYPE_ENTER_FLUTE_PORTAL = 186,
	INTERACTION_TYPE_LEAVE_EGG_MAN_MODE = 185,
	INTERACTION_TYPE_DISCOVER_PLAYER = 184,
	INTERACTION_TYPE_FALLEN_AID = 183,
	INTERACTION_TYPE_VLOG = 182,
	INTERACTION_TYPE_START_DITTO = 181,
	INTERACTION_TYPE_FRIEND = 180,
	INTERACTION_TYPE_HOME_INVENTORY = 164,
	INTERACTION_TYPE_MARKET = 163,
	INTERACTION_TYPE_CLEAN_TRASH = 162,
	INTERACTION_TYPE_MARK_SHARE = 161,
	INTERACTION_TYPE_ENVOBJ_INTERACT_COMMON = 120,
	INTERACTION_TYPE_BRANCH_LINE_AREA = 110,
	INTERACTION_TYPE_QUICK_CAPTURE_NO_EMPTY_SLOT = 109,
	INTERACTION_TYPE_BOSS_CAPTURE_CANCEL = 108,
	INTERACTION_TYPE_BOSS_CAPTURE = 107,
	INTERACTION_TYPE_LEVEL_ITEM_COMMON_INTERACT = 106,
	INTERACTION_TYPE_QUICK_CAPTURE_ILLEGAL_BALL = 105,
	INTERACTION_TYPE_QUICK_CAPTURE_NO_BALL = 104,
	INTERACTION_TYPE_LEVEL_ITEM_MOVE_PLATFORM = 85,
	INTERACTION_TYPE_LEVEL_ITEM_CREATE_SPAWNER = 84,
	INTERACTION_TYPE_MULTI_INTERACT_CANCEL = 83,
	INTERACTION_TYPE_MULTI_INTERACT = 82,
	INTERACTION_TYPE_RETURN_TEMP_PET = 81,
	INTERACTION_TYPE_GET_TEMP_PET = 80,
	INTERACTION_TYPE_QUICK_CAPTURE_NOT_BIND = 79,
	INTERACTION_TYPE_CALL_FRIENDS = 54,
	INTERACTION_TYPE_PUPPET_RANDOM_DIALOGUE = 30,
	INTERACTION_TYPE_MICROPHONE = 29,
	INTERACTION_TYPE_NPC_SPECIAL_INTERACTION = 28,
	INTERACTION_TYPE_NPC_INTERACTION_1 = 24,
	INTERACTION_TYPE_QUEST_COMMIT = 23,
	INTERACTION_TYPE_SANDBOX_ENT_FUNC = 22,
	INTERACTION_TYPE_EXIT_VEHICLE = 21,
	INTERACTION_TYPE_PLANT_SEED = 20,
	INTERACTION_TYPE_ARK_FUNC = 19,
	INTERACTION_TYPE_PET_LIFT = 18,
	INTERACTION_TYPE_NPC_INTERACTION = 17,
	INTERACTION_TYPE_MIMICRY = 16,
	INTERACTION_TYPE_THROW = 15,
	INTERACTION_TYPE_PUSH = 14,
	INTERACTION_TYPE_LIFT = 13,
	INTERACTION_TYPE_QUEST_DIALOGUE = 12,
	INTERACTION_TYPE_SWITCH_ABILITY = 11,
	INTERACTION_TYPE_NPC_FUNC = 10,
	INTERACTION_TYPE_PICK_UP = 9,
	INTERACTION_TYPE_QUICK_CAPTURE = 8,
	INTERACTION_TYPE_QUICK_PHOTO = 7,
	INTERACTION_TYPE_DROP = 6,
	INTERACTION_TYPE_ELEVATOR = 5,
	INTERACTION_TYPE_SWITCH = 4,
	INTERACTION_TYPE_ENT_FUNC = 1,
	INTERACT_ID_END = 30,
	INTERACT_HOME_CAR_PET_FINISH_DISPATCH = 450,
	INTERACT_HOME_PRODUCE_ACCELERATE = 2156,
	INTERACT_HOME_HATCHBOX_SUC = 2155,
	INTERACT_HOME_HATCHBOX_PLACE = 2154,
	INTERACT_HOME_HATCHBOX_VIEWDETAILS = 2153,
	INTERACT_HOME_HATCHBOX_SPEEDUP = 2152,
	INTERACT_HOME_HATCHBOX_FONDLE = 2151,
	INTERACT_HOME_DISABLE_ELECTRIC_MODE = 446,
	INTERACT_HOME_ENABLE_ELECTRIC_MODE = 445,
	INTERACT_HOME_PET_SNUGGLE_ACTION_ID = 288,
	INTERACT_HOME_FOOD_ACTION_ID = 458,
	INTERACT_HOME_LEVEL_UP_ID = 350,
	INTERACT_HOME_CALL_PET_WORK_ID = 405,
	INTERACT_HOME_DETAIL_ACTION_ID = 278,
	INTERACT_HOME_SETTING_ACTION_ID = 272,
	INTERACT_HOME_MUTATION_DELIVER_ACTION_ID = 289,
	INTERACT_HOME_DELIVER_ACTION_ID = 270,
	INTERACT_CANCEL_MULTI_INTERACT_ACTION_ID = 136,
	INTERACT_DROP_ACTION_ID = 6,
	DEFAULT_INTERACTION_DIALOGUE_ID = -2,
	DEFAULT_INTERACTION_CUSTOM_ID = -1,
	DEFAULT_INTERACTION_PROTOTYPE_ID = 1,
	INTERACTION_TYPE_ARK_PET_INTERACT = 189,
	INTERACTION_TYPE_ARK_PLAYER_INTERACT = 188
}

InteractionConst.TRIGGER_SRC_TYPE = {
	LEVEL_ITEM_INTERACT = 2,
	HOME_INTERACT = 1
}
InteractionConst.NO_TARGET_POS_LIST = {
	InteractionConst.INTERACTION_TYPE_PLANT_SEED,
	InteractionConst.INTERACTION_TYPE_DROP,
	InteractionConst.INTERACTION_TYPE_RETURN_TEMP_PET,
	InteractionConst.INTERACTION_TYPE_QUICK_PHOTO,
	InteractionConst.INTERACTION_TYPE_QUICK_CAPTURE,
	InteractionConst.INTERACTION_TYPE_CALL_FRIENDS,
	InteractionConst.INTERACTION_TYPE_EXIT_VEHICLE,
	InteractionConst.INTERACTION_TYPE_GET_TEMP_PET,
	InteractionConst.INTERACTION_TYPE_LEVEL_ITEM_COMMON_INTERACT,
	InteractionConst.INTERACTION_TYPE_MULTI_INTERACT,
	InteractionConst.INTERACTION_TYPE_MULTI_INTERACT_CANCEL,
	InteractionConst.INTERACTION_TYPE_LEVEL_ITEM_CREATE_SPAWNER,
	InteractionConst.INTERACTION_TYPE_LEVEL_ITEM_MOVE_PLATFORM,
	InteractionConst.INTERACTION_TYPE_BRANCH_LINE_AREA,
	InteractionConst.INTERACTION_TYPE_HOME_INVENTORY,
	InteractionConst.INTERACT_HOME_LEVEL_UP_ID
}
InteractionConst.INTERACTION_PRIORITY_LIST = {
	InteractionConst.INTERACTION_TYPE_QUEST_COMMIT,
	InteractionConst.INTERACTION_TYPE_VLOG,
	InteractionConst.INTERACTION_TYPE_QUEST_DIALOGUE,
	InteractionConst.INTERACTION_TYPE_SWITCH_ABILITY,
	InteractionConst.INTERACTION_TYPE_NPC_FUNC,
	InteractionConst.INTERACTION_TYPE_ARK_FUNC,
	InteractionConst.INTERACTION_TYPE_NPC_SPECIAL_INTERACTION,
	InteractionConst.INTERACTION_TYPE_PICK_UP,
	InteractionConst.INTERACTION_TYPE_LIFT,
	InteractionConst.INTERACTION_TYPE_PET_LIFT,
	InteractionConst.INTERACTION_TYPE_PUSH,
	InteractionConst.INTERACTION_TYPE_THROW,
	InteractionConst.INTERACTION_TYPE_SWITCH,
	InteractionConst.INTERACTION_TYPE_ENT_FUNC,
	InteractionConst.INTERACTION_TYPE_ENVOBJ_INTERACT_COMMON,
	InteractionConst.INTERACTION_TYPE_ELEVATOR,
	InteractionConst.INTERACTION_TYPE_MIMICRY,
	InteractionConst.INTERACTION_TYPE_NPC_INTERACTION,
	InteractionConst.INTERACTION_TYPE_NPC_INTERACTION_1,
	InteractionConst.INTERACTION_TYPE_SANDBOX_ENT_FUNC,
	InteractionConst.INTERACTION_TYPE_MARK_SHARE,
	InteractionConst.INTERACTION_TYPE_CLEAN_TRASH,
	InteractionConst.INTERACTION_TYPE_MICROPHONE,
	InteractionConst.INTERACTION_TYPE_PUPPET_RANDOM_DIALOGUE,
	InteractionConst.INTERACTION_TYPE_BOSS_CAPTURE,
	InteractionConst.INTERACTION_TYPE_BOSS_CAPTURE_CANCEL,
	InteractionConst.INTERACTION_TYPE_ARK_PLAYER_INTERACT,
	InteractionConst.INTERACTION_TYPE_ARK_PET_INTERACT,
	InteractionConst.INTERACTION_TYPE_FRIEND,
	InteractionConst.INTERACTION_TYPE_INTERACT_ANIMATION,
	InteractionConst.INTERACTION_TYPE_MARKET,
	InteractionConst.INTERACTION_TYPE_START_DITTO,
	InteractionConst.INTERACTION_TYPE_FALLEN_AID,
	InteractionConst.INTERACTION_TYPE_DISCOVER_PLAYER,
	InteractionConst.INTERACTION_TYPE_ENTER_FLUTE_PORTAL,
	InteractionConst.INTERACTION_TYPE_LEAVE_EGG_MAN_MODE
}
InteractionConst.INTERACTION_CONFIG = {
	[InteractionConst.INTERACTION_TYPE_ENT_FUNC] = {
		className = "InteractionUnitEntFunc"
	},
	[InteractionConst.INTERACTION_TYPE_ENVOBJ_INTERACT_COMMON] = {
		className = "InteractionUnitEntFunc"
	},
	[InteractionConst.INTERACTION_TYPE_PICK_UP] = {
		className = "InteractionUnitEntFunc"
	},
	[InteractionConst.INTERACTION_TYPE_SWITCH] = {
		className = "InteractionUnitOnlyFunc"
	},
	[InteractionConst.INTERACTION_TYPE_ELEVATOR] = {
		className = "InteractionUnitElevator"
	},
	[InteractionConst.INTERACTION_TYPE_DROP] = {
		className = "InteractionUnitOnlyFunc"
	},
	[InteractionConst.INTERACTION_TYPE_QUICK_PHOTO] = {
		className = "InteractionUnitOnlyFunc"
	},
	[InteractionConst.INTERACTION_TYPE_QUICK_CAPTURE] = {
		className = "InteractionQuickCatch"
	},
	[InteractionConst.INTERACTION_TYPE_NPC_FUNC] = {
		className = "InteractionUnitNpcFunc"
	},
	[InteractionConst.INTERACTION_TYPE_ARK_FUNC] = {
		className = "InteractionUnitArkFunc"
	},
	[InteractionConst.INTERACTION_TYPE_SWITCH_ABILITY] = {
		className = "InteractionSwitchAbility"
	},
	[InteractionConst.INTERACTION_TYPE_QUEST_DIALOGUE] = {
		className = "InteractionUnitQuestDialogue"
	},
	[InteractionConst.INTERACTION_TYPE_LIFT] = {
		className = "InteractionUnitEntFunc"
	},
	[InteractionConst.INTERACTION_TYPE_PET_LIFT] = {
		className = "InteractionUnitEntFunc"
	},
	[InteractionConst.INTERACTION_TYPE_PUSH] = {
		className = "InteractionUnitEntFunc"
	},
	[InteractionConst.INTERACTION_TYPE_THROW] = {
		className = "InteractionUnitEntFunc"
	},
	[InteractionConst.INTERACTION_TYPE_MIMICRY] = {
		className = "InteractionUnitMimicry"
	},
	[InteractionConst.INTERACTION_TYPE_NPC_INTERACTION] = {
		className = "InteractionUnitEntFunc"
	},
	[InteractionConst.INTERACTION_TYPE_NPC_INTERACTION_1] = {
		className = "InteractionUnitEntFunc"
	},
	[InteractionConst.INTERACTION_TYPE_CALL_FRIENDS] = {
		className = "InteractionCallFriends"
	},
	[InteractionConst.INTERACTION_TYPE_PLANT_SEED] = {
		className = "InteractionUnitOnlyFunc"
	},
	[InteractionConst.INTERACTION_TYPE_GET_TEMP_PET] = {
		className = "InteractionUnitOnlyFunc"
	},
	[InteractionConst.INTERACTION_TYPE_RETURN_TEMP_PET] = {
		className = "InteractionUnitOnlyFunc"
	},
	[InteractionConst.INTERACTION_TYPE_EXIT_VEHICLE] = {
		className = "InteractionUnitOnlyFunc"
	},
	[InteractionConst.INTERACTION_TYPE_SANDBOX_ENT_FUNC] = {
		className = "InteractionUnitOnlyFunc"
	},
	[InteractionConst.INTERACTION_TYPE_LEVEL_ITEM_COMMON_INTERACT] = {
		className = "InteractionUnitOnlyFunc"
	},
	[InteractionConst.INTERACTION_TYPE_MULTI_INTERACT] = {
		className = "InteractionUnitOnlyFunc"
	},
	[InteractionConst.INTERACTION_TYPE_LEVEL_ITEM_CREATE_SPAWNER] = {
		className = "InteractionUnitOnlyFunc"
	},
	[InteractionConst.INTERACTION_TYPE_LEVEL_ITEM_MOVE_PLATFORM] = {
		className = "InteractionUnitOnlyFunc"
	},
	[InteractionConst.INTERACTION_TYPE_MULTI_INTERACT_CANCEL] = {
		className = "InteractionUnitOnlyFunc"
	},
	[InteractionConst.INTERACTION_TYPE_QUEST_COMMIT] = {
		className = "InteractionUnitQuestCommit"
	},
	[InteractionConst.INTERACTION_TYPE_MARK_SHARE] = {
		className = "InteractionUnitMarkShare"
	},
	[InteractionConst.INTERACTION_TYPE_CLEAN_TRASH] = {
		className = "InteractionUnitEntFunc"
	},
	[InteractionConst.INTERACTION_TYPE_NPC_SPECIAL_INTERACTION] = {
		className = "InteractionUnitNpcSpecialInteract"
	},
	[InteractionConst.INTERACTION_TYPE_MICROPHONE] = {
		className = "InteractionUnitOnlyFunc"
	},
	[InteractionConst.INTERACTION_TYPE_PUPPET_RANDOM_DIALOGUE] = {
		className = "InteractionUnitOnlyFunc"
	},
	[InteractionConst.INTERACTION_TYPE_BOSS_CAPTURE] = {
		className = "InteractionUnitBossCatch"
	},
	[InteractionConst.INTERACTION_TYPE_BOSS_CAPTURE_CANCEL] = {
		className = "InteractionUnitBossCatchCancel"
	},
	[InteractionConst.INTERACTION_TYPE_BRANCH_LINE_AREA] = {
		className = "InteractionAreaBranchLine"
	},
	[InteractionConst.INTERACTION_TYPE_FRIEND] = {
		className = "InteractionUnitPlayerFunc"
	},
	[InteractionConst.INTERACTION_TYPE_MARKET] = {
		className = "InteractionUnitEntFunc"
	},
	[InteractionConst.INTERACTION_TYPE_HOME_INVENTORY] = {
		className = "InteractionUnitEntFunc"
	},
	[InteractionConst.INTERACT_HOME_LEVEL_UP_ID] = {
		className = "InteractionUnitEntFunc"
	},
	[InteractionConst.INTERACTION_TYPE_START_DITTO] = {
		className = "InteractionUnitOnlyFunc"
	},
	[InteractionConst.INTERACTION_TYPE_VLOG] = {
		className = "InteractionUnitOnlyFunc"
	},
	[InteractionConst.INTERACTION_TYPE_FALLEN_AID] = {
		className = "InteractionUnitFallenAidFunc"
	},
	[InteractionConst.INTERACTION_TYPE_DISCOVER_PLAYER] = {
		className = "InteractionUnitDiscoverPlayerFunc"
	},
	[InteractionConst.INTERACTION_TYPE_ENTER_FLUTE_PORTAL] = {
		className = "InteractionUnitOnlyFunc"
	},
	[InteractionConst.INTERACTION_TYPE_LEAVE_EGG_MAN_MODE] = {
		className = "InteractionUnitOnlyFunc"
	},
	[InteractionConst.INTERACTION_TYPE_INTERACT_ANIMATION] = {
		className = "InteractionUnitPlayerFunc"
	},
	[InteractionConst.INTERACTION_TYPE_ARK_PLAYER_INTERACT] = {
		className = "InteractionUnitPlayerFunc"
	},
	[InteractionConst.INTERACTION_TYPE_ARK_PET_INTERACT] = {
		className = "InteractionUnitOnlyFunc"
	}
}
InteractionConst.LEVEL_00 = 0
InteractionConst.LEVEL_01 = 1
InteractionConst.LEVEL_02 = 2
InteractionConst.LEVEL_03 = 3
InteractionConst.LEVEL_04 = 4
InteractionConst.LEVEL_05 = 5
InteractionConst.INTERACTION_PRIORITY_TABLE = {
	[InteractionConst.INTERACTION_TYPE_ENT_FUNC] = InteractionConst.LEVEL_00,
	[InteractionConst.INTERACTION_TYPE_SWITCH] = InteractionConst.LEVEL_01,
	[InteractionConst.INTERACTION_TYPE_ELEVATOR] = InteractionConst.LEVEL_01,
	[InteractionConst.INTERACTION_TYPE_DROP] = InteractionConst.LEVEL_02,
	[InteractionConst.INTERACTION_TYPE_PICK_UP] = InteractionConst.LEVEL_03,
	[InteractionConst.INTERACTION_TYPE_NPC_FUNC] = InteractionConst.LEVEL_01,
	[InteractionConst.INTERACTION_TYPE_SWITCH_ABILITY] = InteractionConst.LEVEL_04,
	[InteractionConst.INTERACTION_TYPE_QUEST_DIALOGUE] = InteractionConst.LEVEL_01,
	[InteractionConst.INTERACTION_TYPE_LIFT] = InteractionConst.LEVEL_02,
	[InteractionConst.INTERACTION_TYPE_PUSH] = InteractionConst.LEVEL_02,
	[InteractionConst.INTERACTION_TYPE_THROW] = InteractionConst.LEVEL_02,
	[InteractionConst.INTERACTION_TYPE_MIMICRY] = InteractionConst.LEVEL_01,
	[InteractionConst.INTERACTION_TYPE_NPC_INTERACTION] = InteractionConst.LEVEL_00,
	[InteractionConst.INTERACTION_TYPE_PET_LIFT] = InteractionConst.LEVEL_02,
	[InteractionConst.INTERACTION_TYPE_ARK_FUNC] = InteractionConst.LEVEL_01,
	[InteractionConst.INTERACTION_TYPE_PLANT_SEED] = InteractionConst.LEVEL_01,
	[InteractionConst.INTERACTION_TYPE_EXIT_VEHICLE] = InteractionConst.LEVEL_01,
	[InteractionConst.INTERACTION_TYPE_SANDBOX_ENT_FUNC] = InteractionConst.LEVEL_01,
	[InteractionConst.INTERACTION_TYPE_QUEST_COMMIT] = InteractionConst.LEVEL_01,
	[InteractionConst.INTERACTION_TYPE_NPC_INTERACTION_1] = InteractionConst.LEVEL_00,
	[InteractionConst.INTERACTION_TYPE_NPC_SPECIAL_INTERACTION] = InteractionConst.LEVEL_04,
	[InteractionConst.INTERACTION_TYPE_MICROPHONE] = InteractionConst.LEVEL_04,
	[InteractionConst.INTERACTION_TYPE_PUPPET_RANDOM_DIALOGUE] = InteractionConst.LEVEL_04,
	[InteractionConst.INTERACTION_TYPE_CALL_FRIENDS] = InteractionConst.LEVEL_04,
	[InteractionConst.INTERACTION_TYPE_GET_TEMP_PET] = InteractionConst.LEVEL_01,
	[InteractionConst.INTERACTION_TYPE_RETURN_TEMP_PET] = InteractionConst.LEVEL_01,
	[InteractionConst.INTERACTION_TYPE_MULTI_INTERACT] = InteractionConst.LEVEL_02,
	[InteractionConst.INTERACTION_TYPE_MULTI_INTERACT_CANCEL] = InteractionConst.LEVEL_02,
	[InteractionConst.INTERACTION_TYPE_LEVEL_ITEM_CREATE_SPAWNER] = InteractionConst.LEVEL_01,
	[InteractionConst.INTERACTION_TYPE_LEVEL_ITEM_MOVE_PLATFORM] = InteractionConst.LEVEL_01,
	[InteractionConst.INTERACTION_TYPE_LEVEL_ITEM_COMMON_INTERACT] = InteractionConst.LEVEL_01,
	[InteractionConst.INTERACTION_TYPE_BRANCH_LINE_AREA] = InteractionConst.LEVEL_01,
	[InteractionConst.INTERACTION_TYPE_ENVOBJ_INTERACT_COMMON] = InteractionConst.LEVEL_01,
	[InteractionConst.INTERACTION_TYPE_MARK_SHARE] = InteractionConst.LEVEL_02,
	[InteractionConst.INTERACTION_TYPE_CLEAN_TRASH] = InteractionConst.LEVEL_01,
	[InteractionConst.INTERACTION_TYPE_MARKET] = InteractionConst.LEVEL_01,
	[InteractionConst.INTERACTION_TYPE_HOME_INVENTORY] = InteractionConst.LEVEL_01,
	[InteractionConst.INTERACTION_TYPE_FRIEND] = InteractionConst.LEVEL_05,
	[InteractionConst.INTERACTION_TYPE_INTERACT_ANIMATION] = InteractionConst.LEVEL_05,
	[InteractionConst.INTERACTION_TYPE_ARK_PLAYER_INTERACT] = InteractionConst.LEVEL_05,
	[InteractionConst.INTERACTION_TYPE_ARK_PET_INTERACT] = InteractionConst.LEVEL_05,
	[InteractionConst.INTERACTION_TYPE_START_DITTO] = InteractionConst.LEVEL_01
}
InteractionConst.STYLE_CONST = {
	VLOG_INTERACT = 1030,
	FRIEND_INTERACT = 263,
	PHOTO_IDENTIFY = 122,
	QUICK_CAPTURE = 7,
	PHOTO = 3,
	ARK_COCKTAIL_INTERACT = 473,
	ARK_PET_UP_INTERACT = 472,
	ENTER_FLUTE_PORTAL = 409,
	FALLEN_AID = 388,
	CARRY_SEGG = 375
}
InteractionConst.KeyBinding = {
	[0] = "Hud/F",
	"Hud/Space"
}
InteractionConst.EntInteractPriority = {
	StaticNpc = 2,
	HomePet = 1,
	Default = 0
}
InteractionConst.ChestInteractShowSpecialItemId = {
	[1009] = true
}
InteractionConst.QuestCorrelationType = {
	InteractionConst.INTERACTION_TYPE_QUEST_DIALOGUE,
	InteractionConst.INTERACTION_TYPE_QUEST_COMMIT,
	InteractionConst.INTERACTION_TYPE_NPC_SPECIAL_INTERACTION
}
InteractionConst.ControlEntSensitiveUnitCheckType = {
	[InteractionConst.INTERACTION_TYPE_LIFT] = 1,
	[InteractionConst.INTERACTION_TYPE_PET_LIFT] = 1,
	[InteractionConst.INTERACTION_TYPE_PUSH] = 1,
	[InteractionConst.INTERACTION_TYPE_THROW] = 1,
	[InteractionConst.INTERACTION_TYPE_ENT_FUNC] = 2,
	[InteractionConst.INTERACTION_TYPE_NPC_FUNC] = 2,
	[InteractionConst.INTERACTION_TYPE_NPC_INTERACTION] = 2,
	[InteractionConst.INTERACTION_TYPE_NPC_INTERACTION_1] = 2,
	[InteractionConst.INTERACTION_TYPE_NPC_SPECIAL_INTERACTION] = 2
}
InteractionConst.UNIT_CONTROL_ENT_SENSITIVE = 1
InteractionConst.UNIT_CONTROL_ENT_CONDITIONAL_SENSITIVE = 2

return InteractionConst
