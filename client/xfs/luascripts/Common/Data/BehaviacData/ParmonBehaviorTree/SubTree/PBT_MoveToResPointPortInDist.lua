-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_MoveToResPointPortInDist.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_MoveToResPointPortInDist = {
	behavior = {
		useForRoute = false,
		version = 8,
		agenttype = "CombatAgent",
		name = "ParmonBehaviorTree/SubTree/PBT_MoveToResPointPortInDist",
		properties = {},
		pars = {
			{
				type = "int",
				name = "tPointId",
				const = 0,
				value = "0"
			},
			{
				type = "int",
				name = "tPortId",
				const = 0,
				value = "0"
			},
			{
				type = "float",
				name = "tTimeout",
				const = 0,
				value = "0"
			},
			{
				type = "SpeedRateType",
				name = "tSpeedRateType",
				value = "Slow",
				const = BaseEnum.SpeedRateType.Slow
			},
			{
				type = "float",
				name = "tSpeed",
				const = 0,
				value = "0"
			},
			{
				type = "float",
				name = "tInteractDist",
				const = 0,
				value = "0"
			},
			{
				type = "bool",
				name = "tIgnoreSelfBodySize",
				const = true,
				value = "true"
			},
			{
				type = "bool",
				name = "tIgnorePointBodySize",
				const = true,
				value = "true"
			},
			{
				type = "bool",
				name = "tUseAccurateArrive",
				const = false,
				value = "false"
			}
		},
		attachments = {},
		node = {
			id = "1",
			class = "Sequence",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						id = "2",
						class = "Action",
						properties = {
							{
								Method = {
									func = "moveToResPointPortInDist",
									params = {
										{
											field = "tPointId"
										},
										{
											field = "tPortId"
										},
										{
											field = "tTimeout"
										},
										{
											field = "tSpeedRateType"
										},
										{
											field = "tSpeed"
										},
										{
											field = "tInteractDist"
										},
										{
											field = "tIgnoreSelfBodySize"
										},
										{
											field = "tIgnorePointBodySize"
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
						id = "3",
						class = "Action",
						properties = {
							{
								Method = {
									func = "turnToResPointPort",
									params = {
										{
											field = "tPointId"
										},
										{
											field = "tPortId"
										},
										{
											const = false
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
		}
	}
}

return PBT_MoveToResPointPortInDist
