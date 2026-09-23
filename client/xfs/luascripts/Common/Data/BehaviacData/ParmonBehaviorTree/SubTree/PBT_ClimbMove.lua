-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_ClimbMove.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_ClimbMove = {
	behavior = {
		version = 10,
		name = "ParmonBehaviorTree/SubTree/PBT_ClimbMove",
		useForRoute = false,
		agenttype = "CombatAgent",
		properties = {},
		pars = {
			{
				type = "vector<float>",
				name = "tTargetPosList",
				value = "0:",
				const = {}
			},
			{
				type = "vector<float>",
				name = "tNormalList",
				value = "0:",
				const = {}
			}
		},
		attachments = {},
		node = {
			id = "4",
			class = "Action",
			properties = {
				{
					Method = {
						func = "moveToPosList",
						params = {
							{
								field = "tTargetPosList"
							},
							{
								const = 100
							},
							{
								const = true
							},
							{
								const = 0
							},
							{
								const = BaseEnum.SpeedRateType.Mid
							},
							{
								const = 2
							},
							{
								field = "tNormalList"
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

return PBT_ClimbMove
