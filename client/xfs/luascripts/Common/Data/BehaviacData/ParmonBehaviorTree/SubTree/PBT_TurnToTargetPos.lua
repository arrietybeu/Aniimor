-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_TurnToTargetPos.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_TurnToTargetPos = {
	behavior = {
		name = "ParmonBehaviorTree/SubTree/PBT_TurnToTargetPos",
		version = 5,
		useForRoute = false,
		agenttype = "CombatAgent",
		properties = {},
		pars = {
			{
				type = "float",
				name = "tTargetAtYawDegree",
				const = 0,
				value = "0"
			},
			{
				type = "vector<float>",
				name = "tTargetPos",
				value = "3:0|0|0",
				const = {
					0,
					0,
					0
				}
			}
		},
		attachments = {},
		node = {
			class = "Action",
			id = "2",
			properties = {
				{
					Method = {
						func = "turnToPos",
						params = {
							{
								field = "tTargetPos"
							},
							{
								field = "tTargetAtYawDegree"
							},
							{
								const = false
							},
							{
								const = 0
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

return PBT_TurnToTargetPos
