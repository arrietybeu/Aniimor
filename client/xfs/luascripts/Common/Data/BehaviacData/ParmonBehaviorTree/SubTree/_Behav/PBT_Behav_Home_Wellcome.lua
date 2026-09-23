-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\_Behav\\PBT_Behav_Home_Wellcome.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Behav_Home_Wellcome = {
	behavior = {
		name = "ParmonBehaviorTree/SubTree/_Behav/PBT_Behav_Home_Wellcome",
		useForRoute = false,
		agenttype = "CombatAgent",
		version = 11,
		properties = {},
		pars = {
			{
				type = "int",
				name = "tTargetActorId",
				value = "0",
				const = 0
			},
			{
				type = "vector<float>",
				name = "tTargetPos",
				value = "0:",
				const = {}
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
						id = "10",
						class = "Action",
						properties = {
							{
								Method = {
									func = "teleportToPosition",
									params = {
										{
											field = "tTargetPos"
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
									func = "moveToTarget",
									params = {
										{
											field = "tTargetActorId"
										},
										{
											const = 2
										},
										{
											const = 0
										},
										{
											const = false
										},
										{
											const = true
										},
										{
											const = true
										},
										{
											const = 1.5
										},
										{
											const = BaseEnum.MoveUpdateLevel.Normal
										},
										{
											const = BaseEnum.PathFindType.Auto
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
						id = "14",
						class = "SelectorProbability",
						properties = {
							{
								UntilSuccessOrEnd = false
							}
						},
						attachments = {},
						children = {
							{
								node = {
									id = "18",
									class = "DecoratorWeight",
									properties = {
										{
											DecorateWhenChildEnds = "false"
										},
										{
											Weight = {
												const = 1
											}
										}
									},
									attachments = {},
									children = {
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
																	const = "Love"
																},
																{
																	const = 5
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
										}
									}
								}
							},
							{
								node = {
									id = "17",
									class = "DecoratorWeight",
									properties = {
										{
											DecorateWhenChildEnds = "false"
										},
										{
											Weight = {
												const = 1
											}
										}
									},
									attachments = {},
									children = {
										{
											node = {
												id = "20",
												class = "Action",
												properties = {
													{
														Method = {
															func = "showEmojiBubble",
															params = {
																{
																	const = "Love2"
																},
																{
																	const = 5
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
										}
									}
								}
							},
							{
								node = {
									id = "22",
									class = "DecoratorWeight",
									properties = {
										{
											DecorateWhenChildEnds = "false"
										},
										{
											Weight = {
												const = 1
											}
										}
									},
									attachments = {},
									children = {
										{
											node = {
												id = "23",
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
																	const = 5
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
										}
									}
								}
							},
							{
								node = {
									id = "25",
									class = "DecoratorWeight",
									properties = {
										{
											DecorateWhenChildEnds = "false"
										},
										{
											Weight = {
												const = 1
											}
										}
									},
									attachments = {},
									children = {
										{
											node = {
												id = "24",
												class = "Action",
												properties = {
													{
														Method = {
															func = "showEmojiBubble",
															params = {
																{
																	const = "Happy2"
																},
																{
																	const = 5
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
										}
									}
								}
							},
							{
								node = {
									id = "28",
									class = "DecoratorWeight",
									properties = {
										{
											DecorateWhenChildEnds = "false"
										},
										{
											Weight = {
												const = 1
											}
										}
									},
									attachments = {},
									children = {
										{
											node = {
												id = "27",
												class = "Action",
												properties = {
													{
														Method = {
															func = "showEmojiBubble",
															params = {
																{
																	const = "Laugh"
																},
																{
																	const = 5
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
										}
									}
								}
							},
							{
								node = {
									id = "30",
									class = "DecoratorWeight",
									properties = {
										{
											DecorateWhenChildEnds = "false"
										},
										{
											Weight = {
												const = 1
											}
										}
									},
									attachments = {},
									children = {
										{
											node = {
												id = "29",
												class = "Action",
												properties = {
													{
														Method = {
															func = "showEmojiBubble",
															params = {
																{
																	const = "Shy"
																},
																{
																	const = 5
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
										}
									}
								}
							},
							{
								node = {
									id = "31",
									class = "DecoratorWeight",
									properties = {
										{
											DecorateWhenChildEnds = "false"
										},
										{
											Weight = {
												const = 1
											}
										}
									},
									attachments = {},
									children = {
										{
											node = {
												id = "32",
												class = "Action",
												properties = {
													{
														Method = {
															func = "showEmojiBubble",
															params = {
																{
																	const = "Hello"
																},
																{
																	const = 5
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
										}
									}
								}
							},
							{
								node = {
									id = "33",
									class = "DecoratorWeight",
									properties = {
										{
											DecorateWhenChildEnds = "false"
										},
										{
											Weight = {
												const = 1
											}
										}
									},
									attachments = {},
									children = {
										{
											node = {
												id = "34",
												class = "Action",
												properties = {
													{
														Method = {
															func = "showEmojiBubble",
															params = {
																{
																	const = "Proud"
																},
																{
																	const = 5
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
										}
									}
								}
							},
							{
								node = {
									id = "35",
									class = "DecoratorWeight",
									properties = {
										{
											DecorateWhenChildEnds = "false"
										},
										{
											Weight = {
												const = 1
											}
										}
									},
									attachments = {},
									children = {
										{
											node = {
												id = "36",
												class = "Action",
												properties = {
													{
														Method = {
															func = "showEmojiBubble",
															params = {
																{
																	const = "Cheer"
																},
																{
																	const = 5
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
										}
									}
								}
							},
							{
								node = {
									id = "37",
									class = "DecoratorWeight",
									properties = {
										{
											DecorateWhenChildEnds = "false"
										},
										{
											Weight = {
												const = 1
											}
										}
									},
									attachments = {},
									children = {
										{
											node = {
												id = "38",
												class = "Action",
												properties = {
													{
														Method = {
															func = "showEmojiBubble",
															params = {
																{
																	const = "Celebrate"
																},
																{
																	const = 5
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
										}
									}
								}
							}
						}
					}
				},
				{
					node = {
						id = "9",
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

return PBT_Behav_Home_Wellcome
