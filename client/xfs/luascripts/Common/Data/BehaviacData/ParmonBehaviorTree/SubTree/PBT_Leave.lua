-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_Leave.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Leave = {
	behavior = {
		useForRoute = false,
		agenttype = "CombatAgent",
		version = 18,
		name = "ParmonBehaviorTree/SubTree/PBT_Leave",
		properties = {},
		pars = {
			{
				value = "0",
				type = "int",
				const = 0,
				name = "tSensorTgtId"
			}
		},
		attachments = {},
		node = {
			class = "Sequence",
			id = "41",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						class = "ReferencedBehavior",
						id = "40",
						properties = {
							{
								ReferenceBehavior = {
									const = "PBT_Perception_Leave"
								}
							},
							{
								subTreeProperties = {}
							}
						},
						attachments = {},
						children = {}
					}
				}
			}
		}
	}
}

return PBT_Leave
