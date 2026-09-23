-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_Noop.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Noop = {
	behavior = {
		version = 5,
		useForRoute = false,
		name = "ParmonBehaviorTree/SubTree/PBT_Noop",
		agenttype = "CombatAgent",
		properties = {},
		pars = {},
		attachments = {},
		node = {
			id = "1",
			class = "Noop",
			properties = {},
			attachments = {},
			children = {}
		}
	}
}

return PBT_Noop
