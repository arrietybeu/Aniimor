-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_PartolInRange.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_PartolInRange = {
	behavior = {
		version = 5,
		useForRoute = false,
		name = "ParmonBehaviorTree/SubTree/PBT_PartolInRange",
		agenttype = "CombatAgent",
		properties = {},
		pars = {
			{
				const = 0,
				value = "0",
				name = "tPatrolRange",
				type = "float"
			}
		},
		attachments = {},
		node = {
			class = "Action",
			id = "1",
			properties = {
				{
					Method = {
						func = "patrolInRange",
						params = {
							{
								field = "tPatrolRange"
							},
							{
								const = BaseEnum.SpeedRateType.Slow
							},
							{
								const = 0
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

return PBT_PartolInRange
