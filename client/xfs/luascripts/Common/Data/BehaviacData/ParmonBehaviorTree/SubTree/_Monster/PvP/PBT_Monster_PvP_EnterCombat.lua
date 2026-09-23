-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\_Monster\\PvP\\PBT_Monster_PvP_EnterCombat.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Monster_PvP_EnterCombat = {
	behavior = {
		agenttype = "PuppetAgent",
		version = 5,
		name = "ParmonBehaviorTree/SubTree/_Monster/PvP/PBT_Monster_PvP_EnterCombat",
		useForRoute = false,
		properties = {},
		pars = {
			{
				value = "0",
				type = "int",
				name = "tTargetID",
				const = 0
			}
		},
		attachments = {},
		node = {
			id = "1",
			class = "Action",
			properties = {
				{
					Method = {
						func = "enterCombat",
						params = {
							{
								field = "tTargetID"
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

return PBT_Monster_PvP_EnterCombat
