-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_FlyToTarget.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_FlyToTarget = {
	behavior = {
		name = "ParmonBehaviorTree/SubTree/PBT_FlyToTarget",
		version = 10,
		useForRoute = true,
		agenttype = "CombatAgent",
		properties = {},
		pars = {
			{
				name = "tActorId",
				const = 0,
				value = "0",
				type = "int"
			},
			{
				name = "tStopDist",
				const = 0,
				value = "0",
				type = "float"
			},
			{
				name = "tHeight",
				const = 0,
				value = "0",
				type = "float"
			},
			{
				name = "tTimeout",
				const = 0,
				value = "0",
				type = "float"
			},
			{
				name = "tNotFaceToPos",
				const = false,
				value = "false",
				type = "bool"
			},
			{
				name = "tMinHoldTime",
				const = 0,
				value = "0",
				type = "float"
			},
			{
				name = "tIgnoreVertical",
				const = false,
				value = "false",
				type = "bool"
			},
			{
				name = "tIgnoreHorizontal",
				const = false,
				value = "false",
				type = "bool"
			},
			{
				name = "tSpeed",
				const = 0,
				value = "0",
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
						func = "flyToTarget",
						params = {
							{
								field = "tActorId"
							},
							{
								field = "tStopDist"
							},
							{
								field = "tHeight"
							},
							{
								field = "tTimeout"
							},
							{
								field = "tNotFaceToPos"
							},
							{
								field = "tMinHoldTime"
							},
							{
								field = "tIgnoreVertical"
							},
							{
								field = "tIgnoreHorizontal"
							},
							{
								field = "tSpeed"
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

return PBT_FlyToTarget
