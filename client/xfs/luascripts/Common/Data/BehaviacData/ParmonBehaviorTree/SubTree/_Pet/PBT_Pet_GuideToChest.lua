-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\_Pet\\PBT_Pet_GuideToChest.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Pet_GuideToChest = {
	behavior = {
		name = "ParmonBehaviorTree/SubTree/_Pet/PBT_Pet_GuideToChest",
		version = 15,
		agenttype = "PetAgent",
		useForRoute = false,
		properties = {},
		pars = {
			{
				const = 0,
				name = "tTargetActorId",
				type = "int",
				value = "0"
			},
			{
				const = 0,
				name = "tStopDist",
				type = "float",
				value = "0"
			},
			{
				const = 0,
				name = "tMaxTimeout",
				type = "float",
				value = "0"
			},
			{
				const = false,
				name = "tFaceTarget",
				type = "bool",
				value = "false"
			},
			{
				const = 0,
				name = "tSpeed",
				type = "float",
				value = "0"
			},
			{
				name = "tMoveUpdateLevel",
				type = "MoveUpdateLevel",
				value = "VeryFast",
				const = BaseEnum.MoveUpdateLevel.VeryFast
			},
			{
				name = "tPathFindType",
				type = "PathFindType",
				value = "Auto",
				const = BaseEnum.PathFindType.Auto
			}
		},
		attachments = {},
		node = {
			id = "2",
			class = "Sequence",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						id = "3",
						class = "Action",
						properties = {
							{
								Method = {
									func = "turnToTargetAtYaw",
									params = {
										{
											field = "masterId"
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
						id = "1",
						class = "Action",
						properties = {
							{
								Method = {
									func = "showEmojiBubble",
									params = {
										{
											const = "Happy"
										},
										{
											const = 4
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
								ResultResumeOption = "BT_None"
							}
						},
						attachments = {},
						children = {}
					}
				},
				{
					node = {
						id = "0",
						class = "Action",
						properties = {
							{
								Method = {
									func = "playAction",
									params = {
										{
											const = "Behav_Happy"
										},
										{
											const = 3
										},
										{
											const = ""
										},
										{
											const = false
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
				},
				{
					node = {
						id = "4",
						class = "Action",
						properties = {
							{
								Method = {
									func = "moveToTarget",
									params = {
										{
											field = "guideTargetActorId"
										},
										{
											field = "tStopDist"
										},
										{
											field = "tMaxTimeout"
										},
										{
											const = false
										},
										{
											const = false
										},
										{
											field = "tFaceTarget"
										},
										{
											field = "tSpeed"
										},
										{
											field = "tMoveUpdateLevel"
										},
										{
											field = "tPathFindType"
										},
										{
											const = BaseEnum.SpeedRateType.Slow
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
				}
			}
		}
	}
}

return PBT_Pet_GuideToChest
