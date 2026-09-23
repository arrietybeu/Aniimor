-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_FlyFollowTarget.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_FlyFollowTarget = {
	behavior = {
		useForRoute = false,
		agenttype = "CombatAgent",
		name = "ParmonBehaviorTree/SubTree/PBT_FlyFollowTarget",
		version = 9,
		properties = {},
		pars = {
			{
				type = "int",
				const = 0,
				value = "0",
				name = "tActorId"
			},
			{
				type = "float",
				const = 0,
				value = "0",
				name = "Dist"
			},
			{
				type = "float",
				const = 0,
				value = "0",
				name = "Height"
			}
		},
		attachments = {},
		node = {
			id = "2",
			class = "DecoratorLoop",
			properties = {
				{
					Count = {
						const = -1
					}
				},
				{
					DecorateWhenChildEnds = "false"
				},
				{
					DoneWithinFrame = "false"
				}
			},
			attachments = {},
			children = {
				{
					node = {
						id = "1",
						class = "Action",
						properties = {
							{
								Method = {
									func = "flyToTarget",
									params = {
										{
											field = "tActorId"
										},
										{
											field = "Dist"
										},
										{
											field = "Height"
										},
										{
											const = 0
										},
										{
											const = false
										},
										{
											const = 0
										},
										{
											const = false
										},
										{
											const = false
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

return PBT_FlyFollowTarget
