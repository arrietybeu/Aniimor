-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_Com_Affinity.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Com_Affinity = {
	behavior = {
		useForRoute = false,
		name = "ParmonBehaviorTree/SubTree/PBT_Com_Affinity",
		agenttype = "CombatAgent",
		version = 10,
		properties = {},
		pars = {
			{
				type = "int",
				value = "0",
				const = 0,
				name = "tTgtId"
			}
		},
		attachments = {},
		node = {
			class = "Sequence",
			id = "31",
			properties = {},
			attachments = {
				{
					class = "Effector",
					effector = true,
					precondition = false,
					transition = false,
					id = "5",
					properties = {
						{
							Operator = "Invalid"
						},
						{
							Opl = {
								func = "removeEntityTag",
								params = {
									{
										field = "selfId"
									},
									{
										const = "TE_Par_Affinity"
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
						id = "30",
						properties = {
							{
								Method = {
									func = "addEntityTag",
									params = {
										{
											field = "selfId"
										},
										{
											const = "TE_Par_Affinity"
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
						id = "4",
						properties = {
							{
								Method = {
									func = "showEmojiBubble",
									params = {
										{
											const = "Love"
										},
										{
											const = 3
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
						class = "Action",
						id = "1",
						properties = {
							{
								Method = {
									func = "turnToTargetAtYaw",
									params = {
										{
											field = "tTgtId"
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
						class = "Action",
						id = "6",
						properties = {
							{
								Method = {
									func = "moveAroundTarget",
									params = {
										{
											field = "tTgtId"
										},
										{
											const = 1.5
										},
										{
											const = 2.8
										},
										{
											const = BaseEnum.SpeedRateType.Mid
										},
										{
											const = false
										},
										{
											const = 3
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
						id = "16",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									class = "Sequence",
									id = "29",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												class = "Action",
												id = "27",
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
												id = "28",
												properties = {},
												attachments = {
													{
														class = "Precondition",
														effector = false,
														precondition = true,
														transition = false,
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
														effector = false,
														precondition = true,
														transition = false,
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
																			field = "tTgtId"
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
														effector = true,
														precondition = false,
														transition = false,
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
															id = "14",
															properties = {
																{
																	Method = {
																		func = "moveToTarget",
																		params = {
																			{
																				field = "tTgtId"
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
									id = "19",
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
												id = "17",
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
															id = "12",
															properties = {
																{
																	Method = {
																		func = "turnToTarget",
																		params = {
																			{
																				field = "tTgtId"
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
												id = "15",
												properties = {},
												attachments = {
													{
														class = "Precondition",
														effector = false,
														precondition = true,
														transition = false,
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
																			field = "tTgtId"
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
														effector = true,
														precondition = false,
														transition = false,
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
															id = "8",
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
																		id = "9",
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
																					id = "10",
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
																		id = "7",
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
																					id = "11",
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
															id = "26",
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
															id = "13",
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
															id = "25",
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
															id = "23",
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
																		id = "20",
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
																					id = "21",
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
																		id = "18",
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
																					id = "22",
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
															id = "24",
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
		}
	}
}

return PBT_Com_Affinity
