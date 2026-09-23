-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_NPC_Novice_ReadyToFight.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_NPC_Novice_ReadyToFight = {
	behavior = {
		useForRoute = false,
		name = "ParmonBehaviorTree/SubTree/PBT_NPC_Novice_ReadyToFight",
		version = 11,
		agenttype = "CombatAgent",
		properties = {},
		pars = {
			{
				const = 0,
				name = "tTarget",
				value = "0",
				type = "int"
			}
		},
		attachments = {},
		node = {
			id = "27",
			class = "Sequence",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						id = "30",
						class = "Action",
						properties = {
							{
								Method = {
									func = "turnToTarget",
									params = {
										{
											field = "tTarget"
										},
										{
											const = false
										},
										{
											const = 0
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
								ResultResumeOption = "BT_ResumeSelf"
							}
						},
						attachments = {},
						children = {}
					}
				},
				{
					node = {
						id = "29",
						class = "Action",
						properties = {
							{
								Method = {
									func = "enterCombat",
									params = {
										{
											field = "tTarget"
										}
									}
								}
							},
							{
								ResultOption = "BT_SUCCESS"
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

return PBT_NPC_Novice_ReadyToFight
