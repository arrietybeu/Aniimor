-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_SetFullbodyIdle.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_SetFullbodyIdle = {
	behavior = {
		useForRoute = true,
		agenttype = "PuppetAgent",
		name = "ParmonBehaviorTree/SubTree/PBT_SetFullbodyIdle",
		version = 10,
		properties = {},
		pars = {
			{
				value = "",
				const = "",
				type = "string",
				name = "tAnimationKey"
			}
		},
		attachments = {},
		node = {
			class = "Action",
			id = "11",
			properties = {
				{
					Method = {
						func = "setFullBodyIdle",
						params = {
							{
								field = "tAnimationKey"
							}
						}
					}
				},
				{
					ResultOption = "BT_INVALID"
				},
				{
					ResultResumeOption = "BT_None"
				}
			},
			attachments = {},
			children = {}
		}
	}
}

return PBT_SetFullbodyIdle
