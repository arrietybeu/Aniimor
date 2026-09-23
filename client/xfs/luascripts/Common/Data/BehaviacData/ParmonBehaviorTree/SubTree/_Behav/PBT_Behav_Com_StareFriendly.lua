-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\_Behav\\PBT_Behav_Com_StareFriendly.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Behav_Com_StareFriendly = {
	behavior = {
		useForRoute = false,
		agenttype = "CombatAgent",
		name = "ParmonBehaviorTree/SubTree/_Behav/PBT_Behav_Com_StareFriendly",
		version = 80,
		properties = {},
		pars = {
			{
				value = "0",
				const = 0,
				type = "int",
				name = "tTargetActorId"
			},
			{
				value = "0",
				const = 0,
				type = "float",
				name = "tRange"
			}
		},
		attachments = {},
		node = {
			id = "40",
			class = "Sequence",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						id = "109",
						class = "Action",
						properties = {
							{
								Method = {
									func = "showEmojiBubble",
									params = {
										{
											const = "Alert"
										},
										{
											const = 2
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
						id = "112",
						class = "Sequence",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									id = "115",
									class = "Action",
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
									id = "116",
									class = "Sequence",
									properties = {},
									attachments = {
										{
											effector = false,
											id = "113",
											transition = false,
											class = "Precondition",
											precondition = true,
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
											effector = false,
											id = "117",
											transition = false,
											class = "Precondition",
											precondition = true,
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
											effector = true,
											id = "119",
											transition = false,
											class = "Effector",
											precondition = false,
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
												id = "30",
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
						id = "74",
						class = "Parallel",
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
						attachments = {
							{
								effector = false,
								id = "80",
								transition = false,
								class = "Precondition",
								precondition = true,
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
							}
						},
						children = {
							{
								node = {
									id = "76",
									class = "DecoratorAlwaysSuccess",
									properties = {
										{
											DecorateWhenChildEnds = "false"
										}
									},
									attachments = {},
									children = {
										{
											node = {
												id = "21",
												class = "Action",
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
									id = "81",
									class = "Sequence",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "86",
												class = "Sequence",
												properties = {},
												attachments = {
													{
														effector = true,
														id = "103",
														transition = false,
														class = "Effector",
														precondition = false,
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
															id = "87",
															class = "Action",
															properties = {
																{
																	Method = {
																		func = "showEmojiBubble",
																		params = {
																			{
																				const = "Alert"
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
													},
													{
														node = {
															id = "105",
															class = "Action",
															properties = {
																{
																	Method = {
																		func = "sendMessageToTrigger",
																		params = {
																			{
																				field = "selfId"
																			},
																			{
																				const = 1010
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
															id = "89",
															class = "Action",
															properties = {
																{
																	Method = {
																		func = "playSleAnimationOnce",
																		params = {
																			{
																				const = "Behav_DoubtStart"
																			},
																			{
																				const = "Behav_DoubtLoop"
																			},
																			{
																				const = "Behav_DoubtEnd"
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
										},
										{
											node = {
												id = "124",
												class = "Sequence",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "122",
															class = "Action",
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
															id = "123",
															class = "Sequence",
															properties = {},
															attachments = {
																{
																	effector = false,
																	id = "113",
																	transition = false,
																	class = "Precondition",
																	precondition = true,
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
																	effector = false,
																	id = "117",
																	transition = false,
																	class = "Precondition",
																	precondition = true,
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
																	effector = true,
																	id = "119",
																	transition = false,
																	class = "Effector",
																	precondition = false,
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
																		id = "121",
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
												id = "125",
												class = "Action",
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
										},
										{
											node = {
												id = "99",
												class = "Sequence",
												properties = {},
												attachments = {
													{
														effector = true,
														id = "95",
														transition = false,
														class = "Effector",
														precondition = false,
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
															id = "16",
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
													},
													{
														node = {
															id = "93",
															class = "Action",
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
										},
										{
											node = {
												id = "100",
												class = "Action",
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

return PBT_Behav_Com_StareFriendly
