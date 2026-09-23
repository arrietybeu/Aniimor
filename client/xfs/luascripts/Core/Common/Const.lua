-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Common\\Const.lua

local AccessControl = require("Core.Framework.AccessControl")
local Const = {
	GM_MSG_WAITING = "__gm_msg_waiting__",
	GMTYPE_CLUSTER = 6,
	GMTYPE_PROCESS_OTHER = 5,
	GMTYPE_PROCESS = 4,
	GMTYPE_SERVICE = 3,
	GMTYPE_PLAYER = 2,
	GMTYPE_ACCOUNT = 1,
	SERVER_API_ANNOTATIONS_SERVER_ONLY = "ServerOnly",
	SERVER_API_ANNOTATIONS_AUTH_CHECK = "AuthCheck",
	SERVER_API_ANNOTATIONS_NEED_BIND = "NeedBind",
	ACCOUNT_LEGACY_COLLECTION_PREFIX = "accountLegacy",
	SERVER_OP_COLLECTION = "server_op",
	WORLD_SPAWNER_COLLECTION = "worldx_spawner",
	WORLD_COLLECTION = "worlds",
	HOMECAMP_COLLECTION = "homecamp",
	HOMELAND_COLLECTION = "homeland",
	MAPFOG_COLLECTION = "mapfogs",
	ACTIVITY_COLLECTION = "activity",
	WHITELIST_COLLECTION = "whitelist",
	GLOBALID_COLLECTION = "globalId",
	ACCOUNT_COLLECTION = "account",
	PLAYER_COLLECTION = "players",
	ENTITIES_COLLECTION = "entities",
	ACCESSOR_ENGINE = 4,
	ACCESSOR_CHANNEL = 3,
	ACCESSOR_SERVER = 2,
	ACCESSOR_CLIENT = 1,
	CreateClientEntityMode = {
		Normal = 0,
		Rebind = 2,
		Seamless = 1
	},
	ACCESSOR_INT_TO_STRING = {
		"ClientOnlyMsg",
		"ServerOnlyMsg",
		"ChannelMsg",
		"EngineMsg"
	},
	ARG_TYPE_NUMBER = {
		number = true,
		double = true,
		float = true,
		int = true
	},
	MicroServiceName = {
		ChatService = true,
		FriendService = true,
		MailService = true
	},
	EmptyTableMsgpacked = string.char(128),
	GM_ARG_SPECIAL = {
		ServerName = true,
		username = true,
		uid = true
	},
	GM_ARG_SPECIAL_IGNORE_CHECK = {
		ServerName = true
	}
}

return AccessControl.readOnly(Const)
