-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_MoveToTargetEntityAtPos.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_MoveToTargetEntityAtPos = {
	behavior = {
		useForRoute = false,
		agenttype = "CombatAgent",
		version = 6,
		name = "ParmonBehaviorTree/SubTree/PBT_MoveToTargetEntityAtPos",
		properties = {},
		pars = {
			{
				value = "0",
				type = "int",
				name = "tTargetActorId",
				const = 0
			},
			{
				value = "0.2",
				type = "float",
				name = "tStopDist",
				const = 0.2
			},
			{
				value = "5",
				type = "float",
				name = "tMaxTimeout",
				const = 5
			},
			{
				value = "true",
				type = "bool",
				name = "tFaceTarget",
				const = true
			},
			{
				value = "0",
				type = "float",
				name = "tTargetYaw",
				const = 0
			},
			{
				value = "0",
				type = "float",
				name = "tTargetDistance",
				const = 0
			},
			{
				value = "false",
				type = "bool",
				name = "tNoBodySize",
				const = false
			},
			{
				value = "0",
				type = "float",
				name = "tSpeed",
				const = 0
			},
			{
				value = "Slow",
				type = "SpeedRateType",
				name = "tSpeedRateType",
				const = BaseEnum.SpeedRateType.Slow
			},
			{
				value = "false",
				type = "bool",
				name = "tUseAccurateArrive",
				const = false
			}
		},
		attachments = {},
		node = {
			id = "1",
			class = "Action",
			properties = {
				{
					Method = {
						func = "moveToTargetPos",
						params = {
							{
								field = "tTargetActorId"
							},
							{
								field = "tTargetYaw"
							},
							{
								field = "tTargetDistance"
							},
							{
								field = "tStopDist"
							},
							{
								field = "tMaxTimeout"
							},
							{
								field = "tNoBodySize"
							},
							{
								const = false
							},
							{
								field = "tFaceTarget"
							},
							{
								field = "tSpeed"
							},
							{
								field = "tSpeedRateType"
							},
							{
								const = BaseEnum.PathFindType.Auto
							},
							{
								field = "tUseAccurateArrive"
							},
							{
								const = false
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

return PBT_MoveToTargetEntityAtPos
