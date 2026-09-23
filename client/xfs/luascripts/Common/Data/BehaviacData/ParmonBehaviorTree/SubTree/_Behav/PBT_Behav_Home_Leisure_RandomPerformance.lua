-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\_Behav\\PBT_Behav_Home_Leisure_RandomPerformance.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Behav_Home_Leisure_RandomPerformance = {
	behavior = {
		useForRoute = false,
		name = "ParmonBehaviorTree/SubTree/_Behav/PBT_Behav_Home_Leisure_RandomPerformance",
		agenttype = "CombatAgent",
		version = 16,
		properties = {},
		pars = {
			{
				type = "bool",
				const = false,
				name = "tIsStartLoopEndAnim",
				value = "false"
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
				type = "string",
				const = "",
				name = "tEmojiKey",
				value = ""
			},
			{
				type = "vector<float>",
				name = "tBornPos",
				value = "0:",
				const = {}
			}
		},
		attachments = {},
		node = {
			class = "Sequence",
			id = "39",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						class = "Action",
						id = "52",
						properties = {
							{
								Method = {
									func = "waitTime",
									params = {
										{
											const = 2
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
						class = "Selector",
						id = "51",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									class = "Action",
									id = "44",
									properties = {
										{
											Method = {
												func = "patrolInHomeland",
												params = {
													{
														const = 3
													},
													{
														const = 5
													},
													{
														const = BaseEnum.SpeedRateType.Slow
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
							},
							{
								node = {
									class = "Sequence",
									id = "49",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												class = "Action",
												id = "46",
												properties = {
													{
														Method = {
															func = "waitTime",
															params = {
																{
																	const = 2
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
												class = "Assignment",
												id = "50",
												properties = {
													{
														CastRight = "false"
													},
													{
														Opl = {
															field = "tBornPos"
														}
													},
													{
														Opr = {
															func = "getBornPos"
														}
													}
												},
												attachments = {},
												children = {}
											}
										},
										{
											node = {
												class = "Action",
												id = "47",
												properties = {
													{
														Method = {
															func = "patrolInHomeland",
															params = {
																{
																	const = 3
																},
																{
																	const = 5
																},
																{
																	const = BaseEnum.SpeedRateType.Slow
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
							},
							{
								node = {
									class = "Action",
									id = "48",
									properties = {
										{
											Method = {
												func = "teleportToPosition",
												params = {
													{
														field = "tBornPos"
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
				},
				{
					node = {
						class = "Action",
						id = "42",
						properties = {
							{
								Method = {
									func = "showEmojiBubble",
									params = {
										{
											field = "tEmojiKey"
										},
										{
											const = 5
										},
										{
											const = false
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
								ResultResumeOption = "BT_None"
							}
						},
						attachments = {},
						children = {}
					}
				},
				{
					node = {
						class = "IfElse",
						id = "41",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									class = "Condition",
									id = "43",
									properties = {
										{
											Operator = "Equal"
										},
										{
											Opl = {
												field = "tIsStartLoopEndAnim"
											}
										},
										{
											Opr = {
												const = false
											}
										}
									},
									attachments = {},
									children = {}
								}
							},
							{
								node = {
									class = "Action",
									id = "40",
									properties = {
										{
											Method = {
												func = "playAction",
												params = {
													{
														field = "tAnimationLoopKey"
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
							},
							{
								node = {
									class = "Action",
									id = "45",
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

return PBT_Behav_Home_Leisure_RandomPerformance
