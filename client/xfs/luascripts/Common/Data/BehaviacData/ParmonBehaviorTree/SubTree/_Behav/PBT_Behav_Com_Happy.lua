-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\_Behav\\PBT_Behav_Com_Happy.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Behav_Com_Happy = {
	behavior = {
		useForRoute = false,
		name = "ParmonBehaviorTree/SubTree/_Behav/PBT_Behav_Com_Happy",
		agenttype = "CombatAgent",
		version = 21,
		properties = {},
		pars = {
			{
				name = "tTargetActorId",
				type = "int",
				value = "0",
				const = 0
			}
		},
		attachments = {},
		node = {
			class = "Sequence",
			id = "42",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						class = "Sequence",
						id = "58",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									class = "Action",
									id = "56",
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
									id = "57",
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
												id = "40",
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
						id = "45",
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
									id = "43",
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
												id = "38",
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
									id = "41",
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
																const = 3
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
												class = "SelectorProbability",
												id = "34",
												properties = {
													{
														UntilSuccessOrEnd = true
													}
												},
												attachments = {},
												children = {
													{
														node = {
															class = "DecoratorWeight",
															id = "35",
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
																		class = "Action",
																		id = "36",
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
															class = "DecoratorWeight",
															id = "33",
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
																		class = "Action",
																		id = "37",
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
													}
												}
											}
										},
										{
											node = {
												class = "Action",
												id = "55",
												properties = {
													{
														Method = {
															func = "sendMessageToTrigger",
															params = {
																{
																	field = "selfId"
																},
																{
																	const = 1011
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
												id = "46",
												properties = {
													{
														Method = {
															func = "playSleAnimationOnce",
															params = {
																{
																	const = "Behav_HappyStart"
																},
																{
																	const = "Behav_HappyLoop"
																},
																{
																	const = "Behav_HappyEnd"
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
										},
										{
											node = {
												class = "Action",
												id = "54",
												properties = {
													{
														Method = {
															func = "waitTime",
															params = {
																{
																	const = 1
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
												class = "SelectorProbability",
												id = "52",
												properties = {
													{
														UntilSuccessOrEnd = true
													}
												},
												attachments = {},
												children = {
													{
														node = {
															class = "DecoratorWeight",
															id = "49",
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
																		class = "Action",
																		id = "50",
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
															class = "DecoratorWeight",
															id = "48",
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
																		class = "Action",
																		id = "51",
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
													}
												}
											}
										},
										{
											node = {
												class = "Action",
												id = "53",
												properties = {
													{
														Method = {
															func = "playSleAnimationOnce",
															params = {
																{
																	const = "Behav_HappyStart"
																},
																{
																	const = "Behav_HappyLoop"
																},
																{
																	const = "Behav_HappyEnd"
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

return PBT_Behav_Com_Happy
