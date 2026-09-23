-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\_Behav\\PBT_Behav_Com_Love.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Behav_Com_Love = {
	behavior = {
		version = 28,
		useForRoute = false,
		agenttype = "CombatAgent",
		name = "ParmonBehaviorTree/SubTree/_Behav/PBT_Behav_Com_Love",
		properties = {},
		pars = {
			{
				value = "0",
				type = "int",
				name = "tTargetActorId",
				const = 0
			}
		},
		attachments = {},
		node = {
			class = "Sequence",
			id = "26",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						class = "Sequence",
						id = "40",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									class = "Action",
									id = "37",
									properties = {
										{
											Method = {
												func = "startTimer",
												params = {
													{
														const = "tMoveTimer"
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
									class = "Sequence",
									id = "39",
									properties = {},
									attachments = {
										{
											class = "Precondition",
											transition = false,
											effector = false,
											precondition = true,
											id = "113",
											properties = {
												{
													BinaryOperator = "And"
												},
												{
													Operator = "LessEqual"
												},
												{
													Opl = {
														func = "getTimerValue",
														params = {
															{
																const = "tMoveTimer"
															}
														}
													}
												},
												{
													Opr2 = {
														const = 10
													}
												},
												{
													Phase = "Both"
												}
											}
										},
										{
											class = "Precondition",
											transition = false,
											effector = false,
											precondition = true,
											id = "117",
											properties = {
												{
													BinaryOperator = "And"
												},
												{
													Operator = "LessEqual"
												},
												{
													Opl = {
														func = "getDistByTgt",
														params = {
															{
																field = "tTargetActorId"
															},
															{
																const = true
															},
															{
																const = true
															},
															{
																const = 0
															}
														}
													}
												},
												{
													Opr2 = {
														const = 15
													}
												},
												{
													Phase = "Both"
												}
											}
										},
										{
											class = "Effector",
											transition = false,
											effector = true,
											precondition = false,
											id = "119",
											properties = {
												{
													Operator = "Invalid"
												},
												{
													Opl = {
														func = "cleanTimer",
														params = {
															{
																const = "tMoveTimer"
															}
														}
													}
												},
												{
													Phase = "Both"
												}
											}
										}
									},
									children = {
										{
											node = {
												class = "Action",
												id = "22",
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
																	const = false
																},
																{
																	const = 0
																},
																{
																	const = BaseEnum.MoveUpdateLevel.Normal
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
										}
									}
								}
							}
						}
					}
				},
				{
					node = {
						class = "Parallel",
						id = "36",
						properties = {
							{
								ChildFinishPolicy = "CHILDFINISH_LOOP"
							},
							{
								ExitPolicy = "EXIT_ABORT_RUNNINGSIBLINGS"
							},
							{
								FailurePolicy = "FAIL_ON_ONE"
							},
							{
								SuccessPolicy = "SUCCEED_ON_ALL"
							}
						},
						attachments = {},
						children = {
							{
								node = {
									class = "DecoratorAlwaysSuccess",
									id = "27",
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
												id = "17",
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
									id = "24",
									properties = {},
									attachments = {
										{
											class = "Precondition",
											transition = false,
											effector = false,
											precondition = true,
											id = "35",
											properties = {
												{
													BinaryOperator = "And"
												},
												{
													Operator = "Equal"
												},
												{
													Opl = {
														func = "checkTargetLocation",
														params = {
															{
																field = "tTargetActorId"
															},
															{
																const = 0
															},
															{
																const = 0
															},
															{
																const = 0
															},
															{
																const = 6
															}
														}
													}
												},
												{
													Opr2 = {
														const = true
													}
												},
												{
													Phase = "Both"
												}
											}
										},
										{
											class = "Effector",
											transition = false,
											effector = true,
											precondition = false,
											id = "103",
											properties = {
												{
													Operator = "Invalid"
												},
												{
													Opl = {
														func = "hideEmojiBubble"
													}
												},
												{
													Phase = "Both"
												}
											}
										}
									},
									children = {
										{
											node = {
												class = "Action",
												id = "34",
												properties = {
													{
														Method = {
															func = "showEmojiBubble",
															params = {
																{
																	const = "Love"
																},
																{
																	const = 10
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
												class = "Action",
												id = "33",
												properties = {
													{
														Method = {
															func = "playSleAnimationFixTime",
															params = {
																{
																	const = "Behav_LoveStart"
																},
																{
																	const = "Behav_LoveLoop"
																},
																{
																	const = "Behav_LoveEnd"
																},
																{
																	const = 10
																},
																{
																	const = ""
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

return PBT_Behav_Com_Love
