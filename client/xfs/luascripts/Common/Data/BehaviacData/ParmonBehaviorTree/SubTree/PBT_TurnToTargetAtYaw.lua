-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_TurnToTargetAtYaw.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_TurnToTargetAtYaw = {
	behavior = {
		name = "ParmonBehaviorTree/SubTree/PBT_TurnToTargetAtYaw",
		version = 6,
		useForRoute = false,
		agenttype = "CombatAgent",
		properties = {},
		pars = {
			{
				name = "tTgtId",
				const = 0,
				type = "int",
				value = "0"
			},
			{
				name = "tTargetAtYawDegree",
				const = 0,
				type = "float",
				value = "0"
			},
			{
				name = "tInstant",
				const = false,
				type = "bool",
				value = "false"
			}
		},
		attachments = {},
		node = {
			id = "1",
			class = "Action",
			properties = {
				{
					Method = {
						func = "turnToTargetAtYaw",
						params = {
							{
								field = "tTgtId"
							},
							{
								field = "tTargetAtYawDegree"
							},
							{
								const = false
							},
							{
								const = 0
							},
							{
								field = "tInstant"
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

return PBT_TurnToTargetAtYaw
