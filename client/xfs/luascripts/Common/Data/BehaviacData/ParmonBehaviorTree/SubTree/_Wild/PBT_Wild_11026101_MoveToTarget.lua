-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\_Wild\\PBT_Wild_11026101_MoveToTarget.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Wild_11026101_MoveToTarget = {
	behavior = {
		agenttype = "CombatAgent",
		version = 20,
		name = "ParmonBehaviorTree/SubTree/_Wild/PBT_Wild_11026101_MoveToTarget",
		useForRoute = false,
		properties = {},
		pars = {
			{
				const = 0,
				name = "tTargetActorId",
				type = "int",
				value = "0"
			},
			{
				const = 0.2,
				name = "tStopDist",
				type = "float",
				value = "0.2"
			},
			{
				const = 5,
				name = "tMaxTimeout",
				type = "float",
				value = "5"
			},
			{
				const = true,
				name = "tFaceTarget",
				type = "bool",
				value = "true"
			},
			{
				const = 0,
				name = "tSpeed",
				type = "float",
				value = "0"
			},
			{
				name = "tMoveUpdateLevel",
				type = "MoveUpdateLevel",
				value = "Once",
				const = BaseEnum.MoveUpdateLevel.Once
			},
			{
				name = "tPathFindType",
				type = "PathFindType",
				value = "Auto",
				const = BaseEnum.PathFindType.Auto
			},
			{
				name = "tSpeedRateType",
				type = "SpeedRateType",
				value = "Slow",
				const = BaseEnum.SpeedRateType.Slow
			},
			{
				const = false,
				name = "tUseAccurateArrive",
				type = "bool",
				value = "false"
			},
			{
				const = false,
				name = "tNoBodySize",
				type = "bool",
				value = "false"
			}
		},
		attachments = {},
		node = {
			id = "10",
			class = "Selector",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						id = "8",
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
				},
				{
					node = {
						id = "12",
						class = "Noop",
						properties = {},
						attachments = {},
						children = {}
					}
				}
			}
		}
	}
}

return PBT_Wild_11026101_MoveToTarget
