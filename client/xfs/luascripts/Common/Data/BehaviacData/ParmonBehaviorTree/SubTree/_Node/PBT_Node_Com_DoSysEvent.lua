-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\_Node\\PBT_Node_Com_DoSysEvent.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Node_Com_DoSysEvent = {
	behavior = {
		useForRoute = true,
		agenttype = "CombatAgent",
		name = "ParmonBehaviorTree/SubTree/_Node/PBT_Node_Com_DoSysEvent",
		version = 16,
		properties = {},
		pars = {
			{
				value = "0",
				const = 0,
				type = "int",
				name = "tEventId"
			}
		},
		attachments = {},
		node = {
			id = "21",
			class = "Sequence",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						id = "19",
						class = "Action",
						properties = {
							{
								Method = {
									func = "doSysEvent",
									params = {
										{
											field = "selfId"
										},
										{
											field = "tEventId"
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
						id = "20",
						class = "Action",
						properties = {
							{
								Method = {
									func = "debugLog",
									params = {
										{
											field = "tEventId"
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

return PBT_Node_Com_DoSysEvent
