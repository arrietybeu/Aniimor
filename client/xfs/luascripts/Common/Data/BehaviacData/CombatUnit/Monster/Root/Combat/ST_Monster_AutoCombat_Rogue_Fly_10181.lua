-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\CombatUnit\\Monster\\Root\\Combat\\ST_Monster_AutoCombat_Rogue_Fly_10181.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local ST_Monster_AutoCombat_Rogue_Fly_10181 = {
	behavior = {
		version = 114,
		useForRoute = false,
		agenttype = "PuppetAgent",
		name = "CombatUnit/Monster/Root/Combat/ST_Monster_AutoCombat_Rogue_Fly_10181",
		properties = {},
		pars = {
			{
				name = "CurrentDistToTarget",
				value = "0",
				type = "float",
				const = 0
			},
			{
				name = "CurrentBoxDistToTarget",
				value = "0",
				type = "float",
				const = 0
			},
			{
				name = "goBackDist",
				value = "0",
				type = "float",
				const = 0
			},
			{
				name = "skillStopDist",
				value = "0",
				type = "float",
				const = 0
			},
			{
				name = "tWeight_Group_SideWalk",
				value = "0",
				type = "int",
				const = 0
			},
			{
				name = "tWeight_Group_Wait",
				value = "0",
				type = "int",
				const = 0
			},
			{
				name = "tWeight_Group_Angry",
				value = "0",
				type = "int",
				const = 0
			}
		},
		attachments = {},
		node = {
			id = "334",
			class = "DecoratorLoop",
			properties = {
				{
					Count = {
						const = -1
					}
				},
				{
					DecorateWhenChildEnds = "true"
				},
				{
					DoneWithinFrame = "false"
				}
			},
			attachments = {},
			children = {}
		}
	}
}

return ST_Monster_AutoCombat_Rogue_Fly_10181
