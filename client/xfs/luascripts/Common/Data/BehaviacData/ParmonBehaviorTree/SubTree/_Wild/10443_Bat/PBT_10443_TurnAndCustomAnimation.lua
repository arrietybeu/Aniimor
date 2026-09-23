-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\_Wild\\10443_Bat\\PBT_10443_TurnAndCustomAnimation.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_10443_TurnAndCustomAnimation = {
	behavior = {
		name = "ParmonBehaviorTree/SubTree/_Wild/10443_Bat/PBT_10443_TurnAndCustomAnimation",
		version = 67,
		useForRoute = false,
		agenttype = "CombatAgent",
		properties = {},
		pars = {
			{
				name = "tTargetActorId",
				type = "int",
				const = 0,
				value = "0"
			},
			{
				name = "tWaitTime",
				type = "float",
				const = 0,
				value = "0"
			},
			{
				name = "tAnimationKey",
				type = "string",
				const = "",
				value = ""
			},
			{
				name = "tAnimationTimeout",
				type = "float",
				const = 5,
				value = "5"
			},
			{
				name = "tEmojiBubbleKey",
				type = "string",
				const = "",
				value = ""
			},
			{
				name = "tEmojiBubbleTimeout",
				type = "float",
				const = 5,
				value = "5"
			},
			{
				name = "tTimelineTag",
				type = "string",
				const = "",
				value = ""
			},
			{
				name = "tNeedLoop",
				type = "bool",
				const = false,
				value = "false"
			},
			{
				name = "tAnimationPlayOnce",
				type = "bool",
				const = false,
				value = "false"
			},
			{
				name = "tEmojiBubbleMustPlayFull",
				type = "bool",
				const = false,
				value = "false"
			}
		},
		attachments = {},
		node = {
			class = "Sequence",
			id = "40",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						class = "Parallel",
						id = "114",
						properties = {
							{
								ChildFinishPolicy = "CHILDFINISH_ONCE"
							},
							{
								ExitPolicy = "EXIT_ABORT_RUNNINGSIBLINGS"
							},
							{
								FailurePolicy = "FAIL_ON_ONE"
							},
							{
								SuccessPolicy = "SUCCEED_ON_ONE"
							}
						},
						attachments = {},
						children = {
							{
								node = {
									class = "DecoratorAlwaysRunning",
									id = "115",
									properties = {
										{
											DecorateWhenChildEnds = "false"
										}
									},
									attachments = {},
									children = {
										{
											node = {
												class = "Action",
												id = "21",
												properties = {
													{
														Method = {
															func = "turnToTarget",
															params = {
																{
																	field = "tTargetActorId"
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
										}
									}
								}
							},
							{
								node = {
									class = "Sequence",
									id = "81",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												class = "Action",
												id = "106",
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
												class = "Action",
												id = "107",
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
																	field = "tEmojiBubbleMustPlayFull"
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
												class = "Action",
												id = "108",
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
																	field = "tAnimationPlayOnce"
																},
																{
																	const = 10
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
					}
				}
			}
		}
	}
}

return PBT_10443_TurnAndCustomAnimation
