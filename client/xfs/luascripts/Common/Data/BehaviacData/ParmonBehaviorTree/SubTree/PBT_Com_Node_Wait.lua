-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_Com_Node_Wait.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Com_Node_Wait = {
	behavior = {
		useForRoute = false,
		agenttype = "CombatAgent",
		name = "ParmonBehaviorTree/SubTree/PBT_Com_Node_Wait",
		version = 6,
		properties = {},
		pars = {
			{
				type = "float",
				const = 0,
				value = "0",
				name = "tWaitTime"
			}
		},
		attachments = {},
		node = {
			id = "10",
			class = "Action",
			properties = {
				{
					Method = {
						func = "waitTime",
						params = {
							{
								field = "tWaitTime"
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

return PBT_Com_Node_Wait
