-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_LoopAnimAndBreak.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_LoopAnimAndBreak = {
	behavior = {
		version = 14,
		useForRoute = false,
		agenttype = "CombatAgent",
		name = "ParmonBehaviorTree/SubTree/PBT_LoopAnimAndBreak",
		properties = {},
		pars = {
			{
				type = "float",
				const = 0,
				name = "tWaitTime",
				value = "0"
			},
			{
				type = "string",
				const = "",
				name = "tEmojiBubbleKey",
				value = ""
			},
			{
				type = "float",
				const = 5,
				name = "tEmojiBubbleTimeout",
				value = "5"
			},
			{
				type = "string",
				const = "",
				name = "tAnimationStartKey",
				value = ""
			},
			{
				type = "string",
				const = "",
				name = "tAnimationLoopKey",
				value = ""
			},
			{
				type = "string",
				const = "",
				name = "tAnimationEndKey",
				value = ""
			},
			{
				type = "float",
				const = 5,
				name = "tAnimationTimeout",
				value = "5"
			},
			{
				type = "string",
				const = "",
				name = "tTimelineTag",
				value = ""
			},
			{
				type = "bool",
				const = false,
				name = "tNeedLoop",
				value = "false"
			},
			{
				type = "string",
				const = "AnimationEnd",
				name = "tBreakTag",
				value = "AnimationEnd"
			}
		},
		attachments = {},
		node = {
			id = "15",
			class = "Selector",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						id = "1",
						class = "Sequence",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									id = "2",
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
									id = "3",
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
														field = "tNeedLoop"
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
									id = "4",
									class = "Action",
									properties = {
										{
											Method = {
												func = "playPhaseAction",
												params = {
													{
														field = "tAnimationStartKey"
													},
													{
														field = "tAnimationLoopKey"
													},
													{
														field = "tAnimationEndKey"
													},
													{
														field = "tAnimationTimeout"
													},
													{
														field = "tTimelineTag"
													},
													{
														const = false
													},
													{
														field = "tNeedLoop"
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
									attachments = {
										{
											transition = false,
											id = "13",
											precondition = true,
											class = "Precondition",
											effector = false,
											properties = {
												{
													BinaryOperator = "And"
												},
												{
													Operator = "Equal"
												},
												{
													Opl = {
														func = "hasAITag",
														params = {
															{
																field = "selfId"
															},
															{
																field = "tBreakTag"
															}
														}
													}
												},
												{
													Opr2 = {
														const = false
													}
												},
												{
													Phase = "Both"
												}
											}
										}
									},
									children = {}
								}
							}
						}
					}
				},
				{
					node = {
						id = "10",
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
												func = "playAction",
												params = {
													{
														field = "tAnimationEndKey"
													},
													{
														const = 0
													},
													{
														field = "tTimelineTag"
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
							},
							{
								node = {
									id = "12",
									class = "Action",
									properties = {
										{
											Method = {
												func = "removeAITag",
												params = {
													{
														field = "selfId"
													},
													{
														field = "tBreakTag"
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
		}
	}
}

return PBT_LoopAnimAndBreak
