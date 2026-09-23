-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\_Behav\\PBT_Behav_GamePlay_Leave.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Behav_GamePlay_Leave = {
	behavior = {
		useForRoute = false,
		version = 12,
		agenttype = "CombatAgent",
		name = "ParmonBehaviorTree/SubTree/_Behav/PBT_Behav_GamePlay_Leave",
		properties = {},
		pars = {
			{
				type = "int",
				const = 0,
				value = "0",
				name = "tTargetActorId"
			},
			{
				type = "float",
				const = 35,
				value = "35",
				name = "tLeaveDistance"
			},
			{
				type = "float",
				const = 4,
				value = "4",
				name = "tSpeed"
			},
			{
				type = "SpeedRateType",
				value = "Mid",
				name = "tSpeedRateType",
				const = BaseEnum.SpeedRateType.Mid
			},
			{
				type = "float",
				const = 10,
				value = "10",
				name = "tMaxTime"
			}
		},
		attachments = {},
		node = {
			id = "2",
			class = "Sequence",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						id = "3",
						class = "Assignment",
						properties = {
							{
								CastRight = "false"
							},
							{
								Opl = {
									field = "tTargetActorId"
								}
							},
							{
								Opr = {
									func = "getPerceptibilityTarget"
								}
							}
						},
						attachments = {},
						children = {}
					}
				},
				{
					node = {
						id = "1",
						class = "Action",
						properties = {
							{
								Method = {
									func = "leaveTarget",
									params = {
										{
											field = "tTargetActorId"
										},
										{
											field = "tLeaveDistance"
										},
										{
											field = "tSpeed"
										},
										{
											field = "tSpeedRateType"
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
		}
	}
}

return PBT_Behav_GamePlay_Leave
