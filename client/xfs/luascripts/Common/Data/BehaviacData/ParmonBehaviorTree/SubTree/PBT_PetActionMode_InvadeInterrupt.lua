-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_PetActionMode_InvadeInterrupt.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_PetActionMode_InvadeInterrupt = {
	behavior = {
		agenttype = "PetAgent",
		version = 12,
		useForRoute = false,
		name = "ParmonBehaviorTree/SubTree/PBT_PetActionMode_InvadeInterrupt",
		properties = {},
		pars = {
			{
				const = 0,
				type = "int",
				value = "0",
				name = "tTargetID"
			}
		},
		attachments = {},
		node = {
			id = "6",
			class = "Sequence",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						id = "11",
						class = "Assignment",
						properties = {
							{
								CastRight = "false"
							},
							{
								Opl = {
									field = "isEnterCombatByInvadeMode"
								}
							},
							{
								Opr = {
									const = false
								}
							}
						},
						attachments = {},
						children = {}
					}
				},
				{
					node = {
						id = "12",
						class = "Action",
						properties = {
							{
								Method = {
									func = "resetRootState",
									params = {
										{
											const = BaseEnum.EBTRootState.ST_Root_Combat
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

return PBT_PetActionMode_InvadeInterrupt
