-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_TriggerBlueprint.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_TriggerBlueprint = {
	behavior = {
		name = "ParmonBehaviorTree/SubTree/PBT_TriggerBlueprint",
		useForRoute = true,
		version = 6,
		agenttype = "CombatAgent",
		properties = {},
		pars = {
			{
				type = "string",
				name = "tEventName",
				value = "",
				const = ""
			}
		},
		attachments = {},
		node = {
			id = "1",
			class = "Action",
			properties = {
				{
					Method = {
						func = "triggerBlueprint",
						params = {
							{
								field = "tEventName"
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

return PBT_TriggerBlueprint
