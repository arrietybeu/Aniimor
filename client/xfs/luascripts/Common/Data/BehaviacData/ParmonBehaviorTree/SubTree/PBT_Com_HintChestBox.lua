-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_Com_HintChestBox.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Com_HintChestBox = {
	behavior = {
		name = "ParmonBehaviorTree/SubTree/PBT_Com_HintChestBox",
		version = 5,
		useForRoute = false,
		agenttype = "CombatAgent",
		properties = {},
		pars = {
			{
				name = "tTargetActorId",
				const = 0,
				type = "int",
				value = "0"
			},
			{
				name = "tStopDist",
				const = 0.2,
				type = "float",
				value = "0.2"
			},
			{
				name = "tMaxTimeout",
				const = 5,
				type = "float",
				value = "5"
			},
			{
				name = "tFaceTarget",
				const = true,
				type = "bool",
				value = "true"
			},
			{
				name = "tSpeed",
				const = 0,
				type = "float",
				value = "0"
			},
			{
				name = "tMoveUpdateLevel",
				type = "MoveUpdateLevel",
				value = "Once",
				const = BaseEnum.MoveUpdateLevel.Once
			},
			{
				name = "tTgtId",
				const = 0,
				type = "int",
				value = "0"
			},
			{
				name = "tTargetAtYawDegree",
				const = 0,
				type = "float",
				value = "0"
			},
			{
				name = "tWaitTime",
				const = 0,
				type = "float",
				value = "0"
			},
			{
				name = "tAnimationKey",
				const = "",
				type = "string",
				value = ""
			},
			{
				name = "tAnimationTimeout",
				const = 5,
				type = "float",
				value = "5"
			},
			{
				name = "tEmojiBubbleKey",
				const = "",
				type = "string",
				value = ""
			},
			{
				name = "tEmojiBubbleTimeout",
				const = 5,
				type = "float",
				value = "5"
			},
			{
				name = "tTimelineTag",
				const = "",
				type = "string",
				value = ""
			},
			{
				name = "tNeedLoop",
				const = false,
				type = "bool",
				value = "false"
			},
			{
				name = "IsCloseEnough",
				const = false,
				type = "bool",
				value = "false"
			}
		},
		attachments = {},
		node = {
			id = "8",
			class = "IfElse",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						id = "9",
						class = "Condition",
						properties = {
							{
								Operator = "Equal"
							},
							{
								Opl = {
									field = "IsCloseEnough"
								}
							},
							{
								Opr = {
									const = true
								}
							}
						},
						attachments = {},
						children = {}
					}
				},
				{
					node = {
						id = "2",
						class = "Sequence",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									id = "6",
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
														const = BaseEnum.PathFindType.Auto
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
							},
							{
								node = {
									id = "10",
									class = "Action",
									properties = {
										{
											Method = {
												func = "turnToTargetAtYaw",
												params = {
													{
														field = "tTgtId"
													},
													{
														field = "tTargetAtYawDegree"
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
									id = "11",
									class = "Action",
									properties = {
										{
											Method = {
												func = "waitTime",
												params = {
													{
														field = "tWaitTime"
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
									id = "12",
									class = "Action",
									properties = {
										{
											Method = {
												func = "showEmojiBubble",
												params = {
													{
														field = "tEmojiBubbleKey"
													},
													{
														field = "tEmojiBubbleTimeout"
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
														field = "tAnimationTimeout"
													},
													{
														field = "tTimelineTag"
													},
													{
														field = "tNeedLoop"
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
				},
				{
					node = {
						id = "1",
						class = "Action",
						properties = {
							{
								Method = {
									func = "showDialogue",
									params = {
										{
											const = 30002000
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

return PBT_Com_HintChestBox
