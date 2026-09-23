-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\_Wild\\_GrabEggs\\PBT_Wild_GrabEggs_ProtectEgg_Patrol.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Wild_GrabEggs_ProtectEgg_Patrol = {
	behavior = {
		agenttype = "CombatAgent",
		name = "ParmonBehaviorTree/SubTree/_Wild/_GrabEggs/PBT_Wild_GrabEggs_ProtectEgg_Patrol",
		version = 18,
		useForRoute = false,
		properties = {},
		pars = {
			{
				const = 0,
				value = "0",
				name = "EggActorId",
				type = "int"
			},
			{
				const = 0,
				value = "0",
				name = "tPatrolRange",
				type = "float"
			}
		},
		attachments = {},
		node = {
			id = "19",
			class = "Sequence",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						id = "29",
						class = "Assignment",
						properties = {
							{
								CastRight = "false"
							},
							{
								Opl = {
									field = "tPatrolRange"
								}
							},
							{
								Opr = {
									func = "getRandomFloat",
									params = {
										{
											const = 5
										},
										{
											const = 15
										}
									}
								}
							}
						},
						attachments = {},
						children = {}
					}
				},
				{
					node = {
						id = "27",
						class = "Action",
						properties = {
							{
								Method = {
									func = "patrolInRange",
									params = {
										{
											field = "tPatrolRange"
										},
										{
											const = BaseEnum.SpeedRateType.Slow
										},
										{
											const = 0
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
		}
	}
}

return PBT_Wild_GrabEggs_ProtectEgg_Patrol
