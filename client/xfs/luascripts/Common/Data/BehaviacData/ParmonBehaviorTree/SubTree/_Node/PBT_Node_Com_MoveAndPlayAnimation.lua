-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\_Node\\PBT_Node_Com_MoveAndPlayAnimation.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Node_Com_MoveAndPlayAnimation = {
	behavior = {
		useForRoute = true,
		agenttype = "CombatAgent",
		name = "ParmonBehaviorTree/SubTree/_Node/PBT_Node_Com_MoveAndPlayAnimation",
		version = 13,
		properties = {},
		pars = {
			{
				value = "0",
				name = "tTargetActorId",
				const = 0,
				type = "int"
			},
			{
				value = "",
				name = "tAnimationKey",
				const = "",
				type = "string"
			}
		},
		attachments = {},
		node = {
			id = "10",
			class = "Sequence",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						id = "14",
						class = "Action",
						properties = {
							{
								Method = {
									func = "moveToTarget",
									params = {
										{
											field = "tTargetActorId"
										},
										{
											const = 2
										},
										{
											const = 10
										},
										{
											const = false
										},
										{
											const = false
										},
										{
											const = true
										},
										{
											const = 0
										},
										{
											const = BaseEnum.MoveUpdateLevel.Normal
										},
										{
											const = BaseEnum.PathFindType.Voxel
										},
										{
											const = BaseEnum.SpeedRateType.Mid
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
						id = "13",
						class = "Action",
						properties = {
							{
								Method = {
									func = "playAction",
									params = {
										{
											field = "tAnimationKey"
										},
										{
											const = 0
										},
										{
											const = ""
										},
										{
											const = false
										},
										{
											const = true
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

return PBT_Node_Com_MoveAndPlayAnimation
