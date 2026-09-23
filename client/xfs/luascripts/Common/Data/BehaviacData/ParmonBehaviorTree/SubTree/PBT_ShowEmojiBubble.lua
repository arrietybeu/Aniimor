-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_ShowEmojiBubble.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_ShowEmojiBubble = {
	behavior = {
		agenttype = "CombatAgent",
		version = 5,
		name = "ParmonBehaviorTree/SubTree/PBT_ShowEmojiBubble",
		useForRoute = true,
		properties = {},
		pars = {
			{
				const = "",
				type = "string",
				name = "tEmojiBubbleKey",
				value = ""
			},
			{
				const = 5,
				type = "float",
				name = "tEmojiBubbleTimeout",
				value = "5"
			}
		},
		attachments = {},
		node = {
			id = "1",
			class = "Sequence",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						id = "3",
						class = "Action",
						properties = {
							{
								Method = {
									func = "showEmojiBubble",
									params = {
										{
											field = "tEmojiBubbleKey"
										},
										{
											field = "tEmojiBubbleTimeout"
										},
										{
											const = false
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
								ResultResumeOption = "BT_None"
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

return PBT_ShowEmojiBubble
