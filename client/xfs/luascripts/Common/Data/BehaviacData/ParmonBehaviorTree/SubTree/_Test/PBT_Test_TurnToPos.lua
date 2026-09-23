-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\_Test\\PBT_Test_TurnToPos.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Test_TurnToPos = {
	behavior = {
		version = 13,
		useForRoute = false,
		agenttype = "CombatAgent",
		name = "ParmonBehaviorTree/SubTree/_Test/PBT_Test_TurnToPos",
		properties = {},
		pars = {
			{
				value = "0",
				const = 0,
				name = "tSensorTgtId",
				type = "int"
			},
			{
				value = "0:",
				name = "tSensorTgtPos",
				type = "vector<float>",
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
						func = "turnToPos",
						params = {
							{
								field = "tSensorTgtPos"
							},
							{
								const = 0
							},
							{
								const = true
							},
							{
								const = 5
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

return PBT_Test_TurnToPos
