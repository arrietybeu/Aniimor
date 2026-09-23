-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Const\\TopLogoConst.lua

local AddressDataConst = require("Const.AddressDataConst")
local UIConst = require("Const.UIConst")
local ClientConst = require("Const.ClientConst")
local TopLogoConst = {}

TopLogoConst.OpenCacheDebugName = UNITY_EDITOR
TopLogoConst.OPEN_TOPLOGO_PROFILE = false
TopLogoConst.IS_SIMULATE_MOBILE = false
TopLogoConst.IsDebugAlertLog = false
TopLogoConst.PRELOAD_TOPLOG_RES_COUNT = 4
TopLogoConst.PreloadTopLogoResIds = {
	AddressDataConst.TOPLOGO_TOP_RESID
}
TopLogoConst.PreloadTopLogoPrefixes = {
	[AddressDataConst.TOPLOGO_TOP_RESID] = "Top_"
}
TopLogoConst.POOL_EXPIRE_TIME = 16
TopLogoConst.POOL_CAPACITY_MULTIPLIER = 2
TopLogoConst.CONTAINER_POOL_TARGET = 16
TopLogoConst.PreloadTopLogoUContainerInfo = {
	url = AddressDataConst.TOPLOGO_COMP_ROOTCONTAINER_GENERAL,
	count = TopLogoConst.CONTAINER_POOL_TARGET
}
TopLogoConst.REF_CONTAINER_LOADED_CALLBACK_GROUP = {
	CB_FUNC2 = 2,
	CB_FUNC1 = 1,
	CB_FUNC4 = 4,
	CB_FUNC3 = 3
}
TopLogoConst.TOPLOGO_PER_FRAME_UPDATE_COMPONENTS = {
	[UIConst.TOPLOGO_COMPONENT.ALERT] = true,
	[UIConst.TOPLOGO_COMPONENT.BATTLE_ROOM] = true,
	[UIConst.TOPLOGO_COMPONENT.COMBAT] = true,
	[UIConst.TOPLOGO_COMPONENT.FACILITY] = true,
	[UIConst.TOPLOGO_COMPONENT.INTERACT_SIGN] = true,
	[UIConst.TOPLOGO_COMPONENT.NPC] = true,
	[UIConst.TOPLOGO_COMPONENT.QUEST] = true,
	[UIConst.TOPLOGO_COMPONENT.VLOG] = true,
	[UIConst.TOPLOGO_COMPONENT.WORK_STATE] = true,
	[UIConst.TOPLOGO_COMPONENT.BUBBLE] = true
}
TopLogoConst.MULTI_TOPLOGO_ATTACH_TYPE = {
	TOP = 1,
	MID = 2
}
TopLogoConst.MULTI_TOPLOGO_ZONE_TYPE = {
	MidExtraLeft = "MidExtra/Left",
	Right = "Right",
	Mid = "Mid",
	Left = "Left",
	Sub = "Sub",
	Main = "Main",
	MidExtraMid = "MidExtra/Mid",
	MidExtraRight = "MidExtra/Right"
}

local multiTypes = TopLogoConst.MULTI_TOPLOGO_ATTACH_TYPE
local multiZones = TopLogoConst.MULTI_TOPLOGO_ZONE_TYPE

TopLogoConst.TOPLOGO_RES_FRAME_CONFIG = {
	[multiTypes.TOP] = {
		AddressDataConst.TOPLOGO_TOP_RESID
	}
}
TopLogoConst.TOPLOGO_NEW_ZONE_CONFIG = {
	[UIConst.TOPLOGO_COMPONENT.TEAM_MATE] = {
		sort = 10,
		zoneRoot = multiTypes.TOP,
		zoneParent = multiZones.Main,
		component = UIConst.TOPLOGO_COMPONENT.TEAM_MATE,
		url = AddressDataConst.TOPLOGO_COMP_RES_TEAM_MATE
	},
	[UIConst.TOPLOGO_COMPONENT.QUEST] = {
		sort = 20,
		zoneRoot = multiTypes.TOP,
		zoneParent = multiZones.Main,
		component = UIConst.TOPLOGO_COMPONENT.QUEST,
		url = AddressDataConst.TOPLOGO_COMP_RES_QUEST
	},
	[UIConst.TOPLOGO_COMPONENT.BATTLE_ROOM] = {
		sort = 25,
		zoneRoot = multiTypes.TOP,
		zoneParent = multiZones.Main,
		component = UIConst.TOPLOGO_COMPONENT.BATTLE_ROOM,
		url = AddressDataConst.TOPLOGO_COMP_RES_BATTLE_ROOM
	},
	[UIConst.TOPLOGO_COMPONENT.PET_LEVEL_UP] = {
		sort = 26,
		zoneRoot = multiTypes.TOP,
		zoneParent = multiZones.MidExtraMid,
		component = UIConst.TOPLOGO_COMPONENT.PET_LEVEL_UP,
		url = AddressDataConst.TOPLOGO_COMP_RES_PET_LEVEL_UP
	},
	[UIConst.TOPLOGO_COMPONENT.FOCUS] = {
		sort = 30,
		zoneRoot = multiTypes.TOP,
		zoneParent = multiZones.Main,
		component = UIConst.TOPLOGO_COMPONENT.FOCUS,
		url = AddressDataConst.TOPLOGO_COMP_RES_FOCUS
	},
	[UIConst.TOPLOGO_COMPONENT.TEAM_SPEECH] = {
		sort = 40,
		zoneRoot = multiTypes.TOP,
		zoneParent = multiZones.Main,
		component = UIConst.TOPLOGO_COMPONENT.TEAM_SPEECH,
		url = AddressDataConst.TOPLOGO_COMP_RES_TEAM_SPEECH
	},
	[UIConst.TOPLOGO_COMPONENT.PET_EXCHANGE] = {
		sort = 50,
		zoneRoot = multiTypes.TOP,
		zoneParent = multiZones.Main,
		component = UIConst.TOPLOGO_COMPONENT.PET_EXCHANGE,
		url = AddressDataConst.TOPLOGO_COMP_RES_PET_EXCHANGE
	},
	[UIConst.TOPLOGO_COMPONENT.ICON] = {
		sort = 60,
		zoneRoot = multiTypes.TOP,
		zoneParent = multiZones.Main,
		component = UIConst.TOPLOGO_COMPONENT.ICON,
		url = AddressDataConst.TOPLOGO_COMP_RES_ICON
	},
	[UIConst.TOPLOGO_COMPONENT.SPACE_FOLLOW] = {
		sort = 70,
		zoneRoot = multiTypes.TOP,
		zoneParent = multiZones.Main,
		component = UIConst.TOPLOGO_COMPONENT.SPACE_FOLLOW,
		url = AddressDataConst.TOPLOGO_COMP_RES_SPACE_FOLLOW
	},
	[UIConst.TOPLOGO_COMPONENT.NPC] = {
		mutexGroup = "OnlyOne",
		zoneRoot = multiTypes.TOP,
		zoneParent = multiZones.Main,
		component = UIConst.TOPLOGO_COMPONENT.NPC,
		url = AddressDataConst.TOPLOGO_COMP_RES_NPC
	},
	[UIConst.TOPLOGO_COMPONENT.PHOTO] = {
		zoneRoot = multiTypes.TOP,
		zoneParent = multiZones.Main,
		component = UIConst.TOPLOGO_COMPONENT.PHOTO,
		url = AddressDataConst.TOPLOGO_COMP_RES_PHOTO
	},
	[UIConst.TOPLOGO_COMPONENT.PET_FERTILITY] = {
		mutexGroup = "OnlyOne",
		zoneRoot = multiTypes.TOP,
		zoneParent = multiZones.Main,
		component = UIConst.TOPLOGO_COMPONENT.PET_FERTILITY,
		url = AddressDataConst.TOPLOGO_COMP_RES_PET_FERTILITY
	},
	[UIConst.TOPLOGO_COMPONENT.CALL_FRIENDS] = {
		mutexGroup = "OnlyOne",
		zoneRoot = multiTypes.TOP,
		zoneParent = multiZones.Main,
		component = UIConst.TOPLOGO_COMPONENT.CALL_FRIENDS,
		url = AddressDataConst.TOPLOGO_COMP_RES_CALL_FRIENDS
	},
	[UIConst.TOPLOGO_COMPONENT.WORK_STATE] = {
		mutexGroup = "OnlyOne",
		zoneRoot = multiTypes.TOP,
		zoneParent = multiZones.Main,
		component = UIConst.TOPLOGO_COMPONENT.WORK_STATE,
		url = AddressDataConst.TOPLOGO_COMP_RES_WORK_STATE
	},
	[UIConst.TOPLOGO_COMPONENT.VLOG] = {
		sort = 80,
		zoneRoot = multiTypes.TOP,
		zoneParent = multiZones.MidExtraMid,
		component = UIConst.TOPLOGO_COMPONENT.VLOG,
		url = AddressDataConst.TOPLOGO_COMP_RES_VLOG
	},
	[UIConst.TOPLOGO_COMPONENT.PLAYERHUB] = {
		mutexGroup = "OnlyOne",
		zoneRoot = multiTypes.TOP,
		zoneParent = multiZones.MidExtraRight,
		component = UIConst.TOPLOGO_COMPONENT.PLAYERHUB,
		url = AddressDataConst.TOPLOGO_COMP_RES_PLAYERHUB
	},
	[UIConst.TOPLOGO_COMPONENT.FACILITY] = {
		mutexGroup = "OnlyOne",
		zoneRoot = multiTypes.TOP,
		zoneParent = multiZones.Main,
		component = UIConst.TOPLOGO_COMPONENT.FACILITY,
		url = AddressDataConst.TOPLOGO_COMP_RES_FACILITY
	},
	[UIConst.TOPLOGO_COMPONENT.SOCIAL] = {
		sort = 90,
		zoneRoot = multiTypes.TOP,
		zoneParent = multiZones.Main,
		component = UIConst.TOPLOGO_COMPONENT.SOCIAL,
		url = AddressDataConst.TOPLOGO_COMP_RES_SOCIAL
	},
	[UIConst.TOPLOGO_COMPONENT.GRAB_EGG_STATE] = {
		mutexGroup = "OnlyOne",
		zoneRoot = multiTypes.TOP,
		zoneParent = multiZones.Main,
		component = UIConst.TOPLOGO_COMPONENT.GRAB_EGG_STATE,
		url = AddressDataConst.TOPLOGO_COMP_RES_GRAB_EGG_STATE
	},
	[UIConst.TOPLOGO_COMPONENT.COMBAT] = {
		mutexGroup = "OnlyOne",
		zoneRoot = multiTypes.TOP,
		zoneParent = multiZones.Main,
		component = UIConst.TOPLOGO_COMPONENT.COMBAT,
		url = AddressDataConst.TOPLOGO_COMP_RES_COMBAT
	},
	[UIConst.TOPLOGO_COMPONENT.ALERT] = {
		sort = 100,
		zoneRoot = multiTypes.TOP,
		zoneParent = multiZones.Sub,
		component = UIConst.TOPLOGO_COMPONENT.ALERT,
		url = AddressDataConst.TOPLOGO_COMP_RES_ALERT
	},
	[UIConst.TOPLOGO_COMPONENT.PET_CHAT] = {
		sort = 110,
		zoneRoot = multiTypes.TOP,
		zoneParent = multiZones.Sub,
		component = UIConst.TOPLOGO_COMPONENT.PET_CHAT,
		url = AddressDataConst.TOPLOGO_COMP_RES_PET_CHAT
	},
	[UIConst.TOPLOGO_COMPONENT.BUBBLE] = {
		sort = 120,
		zoneRoot = multiTypes.TOP,
		zoneParent = multiZones.Sub,
		component = UIConst.TOPLOGO_COMPONENT.BUBBLE,
		url = AddressDataConst.TOPLOGO_COMP_RES_BUBBLE
	},
	[UIConst.TOPLOGO_COMPONENT.CHAT] = {
		sort = 130,
		zoneRoot = multiTypes.TOP,
		zoneParent = multiZones.Sub,
		component = UIConst.TOPLOGO_COMPONENT.CHAT,
		url = AddressDataConst.TOPLOGO_COMP_RES_CHAT
	},
	[UIConst.TOPLOGO_COMPONENT.PLAYER_CHAT] = {
		sort = 140,
		zoneRoot = multiTypes.TOP,
		zoneParent = multiZones.Sub,
		component = UIConst.TOPLOGO_COMPONENT.PLAYER_CHAT,
		url = AddressDataConst.TOPLOGO_COMP_RES_PLAYER_CHAT
	},
	[UIConst.TOPLOGO_COMPONENT.ACTION_STATE] = {
		sort = 150,
		zoneRoot = multiTypes.TOP,
		zoneParent = multiZones.Main,
		component = UIConst.TOPLOGO_COMPONENT.ACTION_STATE,
		url = AddressDataConst.TOPLOGO_COMP_RES_ACTION_STATE
	},
	[UIConst.TOPLOGO_COMPONENT.INTERACT_SIGN] = {
		mutexGroup = "OnlyOne",
		zoneRoot = multiTypes.TOP,
		zoneParent = multiZones.Main,
		component = UIConst.TOPLOGO_COMPONENT.INTERACT_SIGN,
		url = AddressDataConst.TOPLOGO_COMP_RES_INTERACT_SIGN
	},
	[UIConst.TOPLOGO_COMPONENT.WATER_STORAGE] = {
		sort = 160,
		zoneRoot = multiTypes.TOP,
		zoneParent = multiZones.Sub,
		component = UIConst.TOPLOGO_COMPONENT.WATER_STORAGE,
		url = AddressDataConst.TOPLOGO_COMP_RES_WATER_STORAGE
	}
}
TopLogoConst.TOPLOGO_NEW_ZONE_REVERSE_CONFIG = {
	[multiTypes.TOP] = {
		[multiZones.Main] = {
			UIConst.TOPLOGO_COMPONENT.FOCUS,
			UIConst.TOPLOGO_COMPONENT.SOCIAL,
			UIConst.TOPLOGO_COMPONENT.TEAM_MATE,
			UIConst.TOPLOGO_COMPONENT.QUEST,
			UIConst.TOPLOGO_COMPONENT.BATTLE_ROOM,
			UIConst.TOPLOGO_COMPONENT.TEAM_SPEECH,
			UIConst.TOPLOGO_COMPONENT.PET_EXCHANGE,
			UIConst.TOPLOGO_COMPONENT.ICON,
			UIConst.TOPLOGO_COMPONENT.SPACE_FOLLOW,
			UIConst.TOPLOGO_COMPONENT.ACTION_STATE,
			UIConst.TOPLOGO_COMPONENT.NPC,
			UIConst.TOPLOGO_COMPONENT.PHOTO,
			UIConst.TOPLOGO_COMPONENT.PET_FERTILITY,
			UIConst.TOPLOGO_COMPONENT.CALL_FRIENDS,
			UIConst.TOPLOGO_COMPONENT.WORK_STATE,
			UIConst.TOPLOGO_COMPONENT.FACILITY,
			UIConst.TOPLOGO_COMPONENT.GRAB_EGG_STATE,
			UIConst.TOPLOGO_COMPONENT.COMBAT,
			UIConst.TOPLOGO_COMPONENT.INTERACT_SIGN
		},
		[multiZones.Sub] = {
			UIConst.TOPLOGO_COMPONENT.PLAYER_CHAT,
			UIConst.TOPLOGO_COMPONENT.CHAT,
			UIConst.TOPLOGO_COMPONENT.BUBBLE,
			UIConst.TOPLOGO_COMPONENT.PET_CHAT,
			UIConst.TOPLOGO_COMPONENT.ALERT,
			UIConst.TOPLOGO_COMPONENT.WATER_STORAGE
		},
		[multiZones.MidExtraMid] = {
			UIConst.TOPLOGO_COMPONENT.PET_LEVEL_UP,
			UIConst.TOPLOGO_COMPONENT.VLOG
		},
		[multiZones.MidExtraRight] = {
			UIConst.TOPLOGO_COMPONENT.PLAYERHUB
		}
	}
}
TopLogoConst.GET_TOPLOGO_HEIGHT_ENTRY = {
	DEFAULT = "DEFAULT",
	ON_SKELETON_LOADED = "ON_SKELETON_LOADED"
}
TopLogoConst.QUEST_INFO_INTERACT_ID_INDEX = 8
TopLogoConst.CHAT_TOPLOGO_SHOW_NUM_MAX = 10

return TopLogoConst
