-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Const\\DialogueConst.lua

local UIConst = require("Const.UIConst")
local DialogueConst = {
	CHARACTER_RANDOM_BUBBLE = "characterRandomBubble",
	VIRTUAL_CAMERA_CUT_NAME = "CutCMVcam",
	NOTICE_HIT_AIR_WALL = 30001001,
	DEFAULT_SCREEN_TURN_COUNT = 5,
	DEFAULT_LOOK_AT_FADE_TIME = 3,
	CUSTOM_BUBBLE_DEFAULT_DURATION = 3,
	CUSTOM_BUBBLE_DIALOGUE_ID = -1,
	ChatType = {
		NONE = -1,
		MAXN = 10,
		AI_ASSISTANT = 10,
		BUBBLE_SPECIAL = 9,
		WHITE_SCREEN = 7,
		TELECALL = 6,
		BLACK_SCREEN = 5,
		DIALOGUE = 3,
		ASIDE = 2,
		BUBBLE = 1,
		ONLY_EVENT = 0
	},
	PlayType = {
		AUTO = 1,
		NONE = 0,
		AUTO_UNBREAKABLE = 3,
		CLICK_NEXT = 2
	},
	PlayMode = {
		TURN = 0,
		SINGLE = 1
	},
	SpeakerType = {
		OpponentTwinPet = 101,
		PlayerTwinPet = 100,
		Puppet = 2,
		Pet = 1,
		Player = 0,
		Illegal = -1
	},
	NpcType = {
		Other = 3,
		EnvObj = 2,
		Human = 0,
		Pet = 1
	},
	SrcType = {
		SIMPLE_EVENT = 2,
		Interaction = 1,
		PlotDialogue = 0,
		COMBAT = 4,
		AI = 3
	}
}

DialogueConst.ChatTypeToPlayTypeMap = {
	[DialogueConst.ChatType.NONE] = DialogueConst.PlayType.NONE,
	[DialogueConst.ChatType.ONLY_EVENT] = DialogueConst.PlayType.NONE,
	[DialogueConst.ChatType.BUBBLE] = DialogueConst.PlayType.AUTO_UNBREAKABLE,
	[DialogueConst.ChatType.ASIDE] = DialogueConst.PlayType.AUTO_UNBREAKABLE,
	[DialogueConst.ChatType.DIALOGUE] = DialogueConst.PlayType.CLICK_NEXT,
	[DialogueConst.ChatType.BLACK_SCREEN] = DialogueConst.PlayType.AUTO,
	[DialogueConst.ChatType.TELECALL] = DialogueConst.PlayType.AUTO_UNBREAKABLE,
	[DialogueConst.ChatType.WHITE_SCREEN] = DialogueConst.PlayType.AUTO,
	[DialogueConst.ChatType.BUBBLE_SPECIAL] = DialogueConst.PlayType.AUTO_UNBREAKABLE,
	[DialogueConst.ChatType.AI_ASSISTANT] = DialogueConst.PlayType.AUTO_UNBREAKABLE
}
DialogueConst.SPECIAL_CHAT_TYPE_FUNC_MAP = {
	[DialogueConst.ChatType.ONLY_EVENT] = "executeDialogEvent",
	[DialogueConst.ChatType.BUBBLE] = "showTopLogoBubble",
	[DialogueConst.ChatType.BUBBLE_SPECIAL] = "showTopLogoBubble"
}
DialogueConst.CHAT_TYPE_FUNC_MAP = {
	[DialogueConst.ChatType.ASIDE] = "showAside",
	[DialogueConst.ChatType.DIALOGUE] = "showBottomDialogue",
	[DialogueConst.ChatType.BLACK_SCREEN] = "showBlackScreen",
	[DialogueConst.ChatType.TELECALL] = "showNpcTeleCall",
	[DialogueConst.ChatType.AI_ASSISTANT] = "showAIAssistant",
	[DialogueConst.ChatType.WHITE_SCREEN] = "showWhiteScreen"
}
DialogueConst.UI_SHOW_FUNC_NAME = {
	[UIConst.UI_ID_NPC_CALL] = "showNpcCallContent"
}
DialogueConst.FORBID_RANDOM_TEXT_AI_BT_TREE = {}
DialogueConst.FORBID_RANDOM_TEXT_ENTITY_TAG = {}
DialogueConst.PERFORMANCE_LEVEL = {
	ONLY_LOOK_AT = 2,
	NO_PERFORMANCE = 3,
	LOOK_AT_AND_TURN = 0,
	IDLE_AND_LOOK_AT = 1
}
DialogueConst.DIALOGUE_GRAPH_PRESET_MODE = {
	OneOnOne = 0,
	Group = 1
}
DialogueConst.SEND_REPORT_ACTION_EVENT = {
	SKIP_DIALOGUE = 4,
	AUTO_END_SENTENCE = 3,
	PROACTIVELY_END_SENTENCE = 2,
	BEGIN_SENTENCE = 1
}
DialogueConst.CAMERA_MODE = {
	NONE = 2,
	IMMERSIVE = 1,
	FREEDOM = 0
}
DialogueConst.DIALOGUE_CLOSE_KEY = {
	DIALOG_CLOSE_NODE = "DIALOG_CLOSE_NODE"
}

return DialogueConst
