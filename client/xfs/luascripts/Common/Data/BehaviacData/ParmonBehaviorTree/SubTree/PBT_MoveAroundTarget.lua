-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_MoveAroundTarget.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_MoveAroundTarget = {
	behavior = {
		agenttype = "WxAgent",
		version = 9,
		useForRoute = false,
		name = "ParmonBehaviorTree/SubTree/PBT_MoveAroundTarget",
		properties = {},
		pars = {
			{
				value = "0",
				type = "int",
				const = 0,
				name = "tTargetActorId"
			},
			{
				value = "0",
				type = "float",
				const = 0,
				name = "tRadius"
			},
			{
				value = "0",
				type = "float",
				const = 0,
				name = "tSpeed"
			},
			{
				value = "Mid",
				type = "SpeedRateType",
				name = "tSpeedRateType",
				const = BaseEnum.SpeedRateType.Mid
			},
			{
				value = "false",
				type = "bool",
				const = false,
				name = "tClockwise"
			},
			{
				value = "0",
				type = "float",
				const = 0,
				name = "tTimeout"
			}
		},
		attachments = {},
		node = {
			id = "1",
			class = "Action",
			properties = {
				{
					Method = {
						func = "moveAroundTarget",
						params = {
							{
								field = "tTargetActorId"
							},
							{
								field = "tRadius"
							},
							{
								field = "tSpeed"
							},
							{
								field = "tSpeedRateType"
							},
							{
								field = "tClockwise"
							},
							{
								field = "tTimeout"
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

return PBT_MoveAroundTarget
