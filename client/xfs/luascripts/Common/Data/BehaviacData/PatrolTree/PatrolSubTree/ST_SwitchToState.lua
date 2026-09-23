-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\PatrolTree\\PatrolSubTree\\ST_SwitchToState.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local ST_SwitchToState = {
	behavior = {
		agenttype = "CombatAgent",
		name = "PatrolTree/PatrolSubTree/ST_SwitchToState",
		useForRoute = true,
		version = 5,
		properties = {},
		pars = {
			{
				name = "tStateName",
				const = "",
				type = "string",
				value = ""
			},
			{
				name = "tAnimationKey",
				const = "",
				type = "string",
				value = ""
			}
		},
		attachments = {},
		node = {
			id = "1",
			class = "Action",
			properties = {
				{
					Method = {
						func = "switchToState",
						params = {
							{
								field = "tStateName"
							},
							{
								const = 0
							},
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
					ResultResumeOption = "BT_ResumeSelf"
				}
			},
			attachments = {},
			children = {}
		}
	}
}

return ST_SwitchToState
