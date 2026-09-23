-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_ShowQuestionMark.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_ShowQuestionMark = {
	behavior = {
		useForRoute = false,
		name = "ParmonBehaviorTree/SubTree/PBT_ShowQuestionMark",
		agenttype = "CombatAgent",
		version = 5,
		properties = {},
		pars = {
			{
				name = "tMarkType",
				const = "",
				type = "string",
				value = ""
			},
			{
				name = "tTimeout",
				const = 0,
				type = "float",
				value = "0"
			}
		},
		attachments = {},
		node = {
			id = "2",
			class = "Action",
			properties = {
				{
					Method = {
						func = "showQuestionMark",
						params = {
							{
								field = "tMarkType"
							},
							{
								field = "tTimeout"
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

return PBT_ShowQuestionMark
