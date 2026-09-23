-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_SwitchToFly.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_SwitchToFly = {
	behavior = {
		useForRoute = false,
		agenttype = "CombatAgent",
		name = "ParmonBehaviorTree/SubTree/PBT_SwitchToFly",
		version = 6,
		properties = {},
		pars = {
			{
				name = "tFlyHeight",
				value = "3",
				const = 3,
				type = "float"
			},
			{
				name = "tMaxTime",
				value = "5",
				const = 5,
				type = "float"
			}
		},
		attachments = {},
		node = {
			id = "4",
			class = "Action",
			properties = {
				{
					Method = {
						func = "switchToFly",
						params = {
							{
								field = "tFlyHeight"
							},
							{
								field = "tMaxTime"
							}
						}
					}
				},
				{
					ResultOption = "BT_INVALID"
				},
				{
					ResultResumeOption = "BT_ResumeSelf"
				}
			},
			attachments = {},
			children = {}
		}
	}
}

return PBT_SwitchToFly
