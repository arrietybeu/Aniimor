-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\LuaUIUtils\\UIConstants.lua

return function(LuaUIUtils)
	LuaUIUtils.EXPLORE_SKILL_NAME = {
		canGlide = "GLIDE",
		canFly = "FLY",
		canSwim = "SWIM",
		canClimb = "CLIMB"
	}
	LuaUIUtils.SP_CODE = {
		SP_FEATURE = 1,
		SP_SKILL = 0,
		SP_ATTR = 2
	}
	LuaUIUtils.ELEMENT_BTN_DATA_TABLE = {}
	LuaUIUtils.PET_CARD_ILLUSTRATE_BOOK = 8
	LuaUIUtils.PET_RESEARCH_REWARD = 9
	LuaUIUtils.PET_ICON = 1
	LuaUIUtils.PET_ICON_FLASH = 2
	LuaUIUtils.PET_IMG = 3
	LuaUIUtils.PET_IMG_FLASH = 4
	LuaUIUtils.PET_FIRST_SHOW = 5
	LuaUIUtils.PLAYER_AVATAR_TYPE = {
		CHAT = 1,
		DEFAULT = 0
	}
	LuaUIUtils.ITEM_SOURCE_TYPE_NONINTERACTIVE = 0
	LuaUIUtils.ITEM_SOURCE_TYPE_TIPS = 1
	LuaUIUtils.ITEM_SOURCE_TYPE_MAP_POS = 2
	LuaUIUtils.ITEM_SOURCE_TYPE_MAP_MARK = 3
	LuaUIUtils.ITEM_SOURCE_TYPE_EVENT = 4
	LuaUIUtils.ITEM_SOURCE_TYPE_MAP_FILTER = 5
	LuaUIUtils.ITEM_SOURCE_HOMELAND_FACILITIES = 6
	LuaUIUtils.ITEM_SOURCE_HOME_CAMP_CAR = 7
	LuaUIUtils.ITEM_SOURCE_JUMP_QUEST_PAGE = 8
	LuaUIUtils.JUMP_HOME = 1
	LuaUIUtils.SCREEN_CENTER = Vector3(0.5, 0.5, 0)
	LuaUIUtils.COUNTRY_ICON = 1
	LuaUIUtils.COUNTRY_IMG = 2
	LuaUIUtils.PetInfoState = {
		Catch = 0,
		None = 4,
		FriendCatch = 3,
		Find = 1
	}
	LuaUIUtils.ITEM_ICON_TYPE = {
		ICON_BIG = 2,
		ICON_SMALL = 1,
		ICON_NORMAL = 0
	}
	LuaUIUtils.SLOT_STATE = {
		LOCKED = "Locked",
		EMPTY = "Empty",
		EMPTY_NO_WORD = "EmptyNoWord",
		HAVE = "Have"
	}
	LuaUIUtils.SELECT_STATE = {
		PET_WEAR = "PetWear",
		TRY = "Try",
		ROLE_WEAR = "RoleWear",
		LOCKED = "Locked",
		NULL = "Null",
		BLANK = "Blank",
		HAVE = "Have"
	}
	LuaUIUtils.ArkForbidenOperation = {
		"Hud/BallMenu",
		"Hud/NormalAttack"
	}
	LuaUIUtils.HYPERLINK_EFFECT = {
		TOOLTIP = "tooltip",
		OTHER = "other"
	}
	LuaUIUtils.AbilityActionPath = {
		["Skill/CancelGrab"] = true
	}
end
