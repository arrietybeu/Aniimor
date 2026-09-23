-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_SwitchState.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_SwitchState = {
	behavior = {
		version = 5,
		useForRoute = false,
		name = "ParmonBehaviorTree/SubTree/PBT_SwitchState",
		agenttype = "WxAgent",
		properties = {},
		pars = {
			{
				const = "",
				type = "string",
				name = "tCharacterState",
				value = ""
			},
			{
				const = "",
				type = "string",
				name = "tAnimationKey",
				value = ""
			}
		},
		attachments = {},
		node = {
			id = "2",
			class = "Action",
			properties = {
				{
					Method = {
						func = "switchToState",
						params = {
							{
								field = "tCharacterState"
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

return PBT_SwitchState
