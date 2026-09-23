-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\PatrolTree\\PatrolSubTree\\ST_HeartBreak.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local ST_HeartBreak = {
	behavior = {
		agenttype = "CombatAgent",
		version = 5,
		name = "PatrolTree/PatrolSubTree/ST_HeartBreak",
		useForRoute = true,
		properties = {},
		pars = {},
		attachments = {},
		node = {
			class = "Sequence",
			id = "2",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						class = "Action",
						id = "3",
						properties = {
							{
								Method = {
									func = "showEmojiBubble",
									params = {
										{
											const = "Heartbreak"
										},
										{
											const = 5
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
						class = "Wait",
						id = "4",
						properties = {
							{
								Time = {
									const = 5000
								}
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

return ST_HeartBreak
