-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_RandomLoopAnimation.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_RandomLoopAnimation = {
	behavior = {
		name = "ParmonBehaviorTree/SubTree/PBT_RandomLoopAnimation",
		useForRoute = true,
		version = 6,
		agenttype = "CombatAgent",
		properties = {},
		pars = {
			{
				type = "vector<float>",
				name = "tWeightList",
				value = "1:0",
				const = {
					0
				}
			},
			{
				type = "vector<string>",
				name = "tStateList",
				value = "1:",
				const = {
					""
				}
			},
			{
				type = "string",
				name = "tAnimState",
				value = "",
				const = ""
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
						id = "5",
						class = "Assignment",
						properties = {
							{
								CastRight = "false"
							},
							{
								Opl = {
									field = "tAnimState"
								}
							},
							{
								Opr = {
									func = "getStringByWeight",
									params = {
										{
											field = "tWeightList"
										},
										{
											field = "tStateList"
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
						id = "4",
						class = "Action",
						properties = {
							{
								Method = {
									func = "playAction",
									params = {
										{
											field = "tAnimState"
										},
										{
											const = 0
										},
										{
											const = ""
										},
										{
											const = true
										},
										{
											const = false
										},
										{
											const = 0
										},
										{
											const = BaseEnum.AIAnimationRootMotionType.Default
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

return PBT_RandomLoopAnimation
