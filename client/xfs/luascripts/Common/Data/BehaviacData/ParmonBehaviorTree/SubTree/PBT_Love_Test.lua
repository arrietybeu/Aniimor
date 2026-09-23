-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_Love_Test.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Love_Test = {
	behavior = {
		agenttype = "CombatAgent",
		name = "ParmonBehaviorTree/SubTree/PBT_Love_Test",
		version = 6,
		useForRoute = false,
		properties = {},
		pars = {},
		attachments = {},
		node = {
			class = "Sequence",
			id = "14",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						class = "Action",
						id = "15",
						properties = {
							{
								Method = {
									func = "showEmojiBubble",
									params = {
										{
											const = "Love"
										},
										{
											const = 10
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
				},
				{
					node = {
						class = "Action",
						id = "16",
						properties = {
							{
								Method = {
									func = "playRawAnimation",
									params = {
										{
											const = "Ani_Parmon_10291_Behav_Love"
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

return PBT_Love_Test
