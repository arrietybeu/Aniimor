-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_MoveToResPointPort.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_MoveToResPointPort = {
	behavior = {
		useForRoute = false,
		name = "ParmonBehaviorTree/SubTree/PBT_MoveToResPointPort",
		agenttype = "CombatAgent",
		version = 7,
		properties = {},
		pars = {
			{
				const = 0,
				value = "0",
				type = "int",
				name = "tPointId"
			},
			{
				const = 0,
				value = "0",
				type = "int",
				name = "tPortId"
			},
			{
				const = 0,
				value = "0",
				type = "float",
				name = "tTimeout"
			},
			{
				value = "Slow",
				type = "SpeedRateType",
				name = "tSpeedRateType",
				const = BaseEnum.SpeedRateType.Slow
			},
			{
				const = 0,
				value = "0",
				type = "float",
				name = "tSpeed"
			},
			{
				const = false,
				value = "false",
				type = "bool",
				name = "tUseAccurateArrive"
			}
		},
		attachments = {},
		node = {
			class = "Sequence",
			id = "1",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						class = "Action",
						id = "2",
						properties = {
							{
								Method = {
									func = "moveToResPointPort",
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
						class = "Action",
						id = "3",
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

return PBT_MoveToResPointPort
