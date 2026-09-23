-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_Noop_Failure.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Noop_Failure = {
	behavior = {
		useForRoute = false,
		name = "ParmonBehaviorTree/SubTree/PBT_Noop_Failure",
		agenttype = "CombatAgent",
		version = 10,
		properties = {},
		pars = {
			{
				name = "CurrentEP",
				const = 0,
				type = "float",
				value = "0"
			},
			{
				name = "maxSkillDist",
				const = 0,
				type = "float",
				value = "0"
			},
			{
				name = "skillStopDist",
				const = 0,
				type = "float",
				value = "0"
			},
			{
				name = "goBackDist",
				const = 0,
				type = "float",
				value = "0"
			},
			{
				name = "CurrentBoxDistToTarget",
				const = 0,
				type = "float",
				value = "0"
			},
			{
				name = "tSkillUsed",
				const = 0,
				type = "int",
				value = "0"
			}
		},
		attachments = {},
		node = {
			class = "DecoratorAlwaysFailure",
			id = "3",
			properties = {
				{
					DecorateWhenChildEnds = "false"
				}
			},
			attachments = {},
			children = {
				{
					node = {
						class = "Noop",
						id = "1",
						properties = {},
						attachments = {},
						children = {}
					}
				}
			}
		}
	}
}

return PBT_Noop_Failure
