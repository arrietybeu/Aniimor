-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_MoveToTargetEntity.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_MoveToTargetEntity = {
	behavior = {
		agenttype = "CombatAgent",
		name = "ParmonBehaviorTree/SubTree/PBT_MoveToTargetEntity",
		version = 11,
		useForRoute = false,
		properties = {},
		pars = {
			{
				type = "int",
				value = "0",
				name = "tTargetActorId",
				const = 0
			},
			{
				type = "float",
				value = "0.2",
				name = "tStopDist",
				const = 0.2
			},
			{
				type = "float",
				value = "5",
				name = "tMaxTimeout",
				const = 5
			},
			{
				type = "bool",
				value = "true",
				name = "tFaceTarget",
				const = true
			},
			{
				type = "float",
				value = "0",
				name = "tSpeed",
				const = 0
			},
			{
				type = "MoveUpdateLevel",
				value = "Once",
				name = "tMoveUpdateLevel",
				const = BaseEnum.MoveUpdateLevel.Once
			},
			{
				type = "PathFindType",
				value = "Auto",
				name = "tPathFindType",
				const = BaseEnum.PathFindType.Auto
			},
			{
				type = "SpeedRateType",
				value = "Slow",
				name = "tSpeedRateType",
				const = BaseEnum.SpeedRateType.Slow
			},
			{
				type = "bool",
				value = "false",
				name = "tUseAccurateArrive",
				const = false
			},
			{
				type = "bool",
				value = "false",
				name = "tNoBodySize",
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
						func = "moveToTarget",
						params = {
							{
								field = "tTargetActorId"
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
								field = "tMoveUpdateLevel"
							},
							{
								field = "tPathFindType"
							},
							{
								field = "tSpeedRateType"
							},
							{
								const = 0
							},
							{
								field = "tUseAccurateArrive"
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

return PBT_MoveToTargetEntity
