-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\_Monster\\PBT_Monster_ClousterBoss_SummonRunAway.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Monster_ClousterBoss_SummonRunAway = {
	behavior = {
		version = 10,
		useForRoute = false,
		name = "ParmonBehaviorTree/SubTree/_Monster/PBT_Monster_ClousterBoss_SummonRunAway",
		agenttype = "PuppetAgent",
		properties = {},
		pars = {},
		attachments = {},
		node = {
			id = "11",
			class = "Sequence",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						id = "12",
						class = "Assignment",
						properties = {
							{
								CastRight = "false"
							},
							{
								Opl = {
									field = "tgt"
								}
							},
							{
								Opr = {
									func = "getAuthorityPlayer"
								}
							}
						},
						attachments = {},
						children = {}
					}
				},
				{
					node = {
						id = "10",
						class = "Action",
						properties = {
							{
								Method = {
									func = "leaveTarget",
									params = {
										{
											field = "tgt"
										},
										{
											const = 20
										},
										{
											const = -1
										},
										{
											const = BaseEnum.SpeedRateType.Fast
										},
										{
											const = 10
										}
									}
								}
							},
							{
								ResultOption = "BT_SUCCESS"
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
						id = "6",
						class = "Action",
						properties = {
							{
								Method = {
									func = "enterDestroySelf"
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

return PBT_Monster_ClousterBoss_SummonRunAway
