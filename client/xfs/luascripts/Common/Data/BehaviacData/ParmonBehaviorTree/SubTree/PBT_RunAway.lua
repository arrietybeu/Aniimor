-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_RunAway.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_RunAway = {
	behavior = {
		useForRoute = false,
		agenttype = "CombatAgent",
		name = "ParmonBehaviorTree/SubTree/PBT_RunAway",
		version = 11,
		properties = {},
		pars = {},
		attachments = {},
		node = {
			id = "3",
			class = "Sequence",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						id = "11",
						class = "Action",
						properties = {
							{
								Method = {
									func = "moveToQualifiedPosAwayFromTeammates",
									params = {
										{
											field = "tgt"
										},
										{
											const = 10
										},
										{
											const = 12
										},
										{
											const = 2
										},
										{
											const = 0
										},
										{
											const = 0
										},
										{
											const = BaseEnum.SpeedRateType.Fast
										},
										{
											const = true
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

return PBT_RunAway
