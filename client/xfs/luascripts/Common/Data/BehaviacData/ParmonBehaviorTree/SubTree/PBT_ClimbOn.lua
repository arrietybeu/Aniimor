-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_ClimbOn.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_ClimbOn = {
	behavior = {
		name = "ParmonBehaviorTree/SubTree/PBT_ClimbOn",
		agenttype = "CombatAgent",
		version = 5,
		useForRoute = false,
		properties = {},
		pars = {
			{
				name = "tClimbOnPos",
				type = "vector<float>",
				value = "0:",
				const = {}
			},
			{
				name = "tClimbOnRot",
				type = "vector<float>",
				value = "0:",
				const = {}
			},
			{
				name = "tClimbYaw",
				type = "float",
				const = 0,
				value = "0"
			}
		},
		attachments = {},
		node = {
			id = "1",
			class = "Sequence",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						id = "9",
						class = "Action",
						properties = {
							{
								Method = {
									func = "turnToYaw",
									params = {
										{
											field = "tClimbYaw"
										},
										{
											const = false
										},
										{
											const = 5
										},
										{
											const = false
										},
										{
											const = 1
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
						id = "7",
						class = "Action",
						properties = {
							{
								Method = {
									func = "moveToPos",
									params = {
										{
											field = "tClimbOnPos"
										},
										{
											const = 20
										},
										{
											const = true
										},
										{
											const = 1.5
										},
										{
											const = BaseEnum.SpeedRateType.Mid
										},
										{
											const = 0
										},
										{
											const = BaseEnum.PathFindType.Auto
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
								ResultResumeOption = "BT_ResumeSelf"
							}
						},
						attachments = {},
						children = {}
					}
				},
				{
					node = {
						id = "8",
						class = "Action",
						properties = {
							{
								Method = {
									func = "switchToClimbOn",
									params = {
										{
											field = "tClimbOnPos"
										},
										{
											field = "tClimbOnRot"
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

return PBT_ClimbOn
