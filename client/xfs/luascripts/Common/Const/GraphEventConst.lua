-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Const\\GraphEventConst.lua

local AccessControl = require("Core.Framework.AccessControl")
local enum_dummy = {
	is_enum_dummy = true
}
local GraphEventConst = {
	EVENT_TEST_1 = enum_dummy,
	EVENT_TEST_2 = enum_dummy,
	EVENT_TEST_3 = enum_dummy,
	ALL_PLAYER_DEATH = enum_dummy,
	ENTER_BATTLE_FIELD = enum_dummy,
	LEAVE_BATTLE_FIELD = enum_dummy,
	AI_EVENT = enum_dummy,
	PLAYER_RELOGIN = enum_dummy,
	SPAWNER_DEATH = enum_dummy
}

for attr, v in pairs(GraphEventConst) do
	if string.upper(attr) ~= attr then
		error("attr.upper() != attr: " .. attr)
	elseif type(v) ~= "table" or v.is_enum_dummy ~= true then
		error("%s: type(v) ~= enum_dummy: " .. attr)
	end

	GraphEventConst[attr] = attr
end

local EventComment = {
	SPAWNER_DEATH = "Spawner死亡",
	PLAYER_RELOGIN = "玩家重登",
	AI_EVENT = "AI相关事件",
	LEAVE_BATTLE_FIELD = "离开污染区域事件",
	ENTER_BATTLE_FIELD = "进入污染区域事件",
	ALL_PLAYER_DEATH = "所有玩家死亡"
}
local ParamEvent = {
	SPAWNER_DEATH = {
		valueIn = {
			spawnerId = "int"
		},
		valueOut = {}
	},
	AI_EVENT = {
		valueIn = {
			key = "string",
			value = "string"
		},
		valueOut = {
			key = "string",
			value = "string"
		}
	}
}

GraphEventConst._PARAM_EVENT = ParamEvent
GraphEventConst._EVENT_COMMENT = EventComment

return AccessControl.readOnly(GraphEventConst)
