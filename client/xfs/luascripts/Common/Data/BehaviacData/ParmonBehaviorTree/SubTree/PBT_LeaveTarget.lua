-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_LeaveTarget.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_LeaveTarget = {
	behavior = {
		name = "ParmonBehaviorTree/SubTree/PBT_LeaveTarget",
		useForRoute = false,
		version = 10,
		agenttype = "CombatAgent",
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
				const = 5,
				value = "5",
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
			class = "Action",
			id = "1",
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

return PBT_LeaveTarget
