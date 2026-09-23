-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\PatrolTree\\PatrolMoveSubTree\\ST_NPCLeadPatrol.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local ST_NPCLeadPatrol = {
	behavior = {
		useForRoute = false,
		agenttype = "WxAgent",
		name = "PatrolTree/PatrolMoveSubTree/ST_NPCLeadPatrol",
		version = 11,
		properties = {},
		pars = {
			{
				name = "patrolPos",
				type = "vector<float>",
				value = "0:",
				const = {}
			},
			{
				name = "patrolMaxTime",
				type = "float",
				const = 0,
				value = "0"
			},
			{
				name = "tPatrolSpeed",
				type = "float",
				const = 0,
				value = "0"
			},
			{
				name = "tBehaviorSpeedRateType",
				type = "SpeedRateType",
				value = "Slow",
				const = BaseEnum.SpeedRateType.Slow
			},
			{
				name = "tPathFindType",
				type = "PathFindType",
				value = "Auto",
				const = BaseEnum.PathFindType.Auto
			},
			{
				name = "tUseAccurateArrive",
				type = "bool",
				const = false,
				value = "false"
			},
			{
				name = "tLeadTargetActorId",
				type = "int",
				const = 0,
				value = "0"
			},
			{
				name = "tJudgeSpeedRateType",
				type = "SpeedRateType",
				value = "Slow",
				const = BaseEnum.SpeedRateType.Slow
			}
		},
		attachments = {},
		node = {
			class = "Parallel",
			id = "24",
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
						class = "Assignment",
						id = "25",
						properties = {
							{
								CastRight = "false"
							},
							{
								Opl = {
									field = "tJudgeSpeedRateType"
								}
							},
							{
								Opr = {
									func = "judgeSpeedRateTypeByTarget",
									params = {
										{
											field = "tLeadTargetActorId"
										},
										{
											const = 3
										},
										{
											const = 4
										},
										{
											field = "tBehaviorSpeedRateType"
										}
									}
								}
							}
						},
						attachments = {},
						children = {}
					}
				},
				{
					node = {
						class = "Selector",
						id = "77",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									class = "Sequence",
									id = "78",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												class = "IfElse",
												id = "15",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															class = "Condition",
															id = "14",
															properties = {
																{
																	Operator = "Equal"
																},
																{
																	Opl = {
																		func = "checkCanFly"
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
															class = "IfElse",
															id = "5",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		class = "Condition",
																		id = "4",
																		properties = {
																			{
																				Operator = "Equal"
																			},
																			{
																				Opl = {
																					func = "checkPosIsOnGround",
																					params = {
																						{
																							field = "patrolPos"
																						}
																					}
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
																		class = "IfElse",
																		id = "68",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					class = "Condition",
																					id = "8",
																					properties = {
																						{
																							Operator = "Equal"
																						},
																						{
																							Opl = {
																								func = "checkIsFlying",
																								params = {
																									{
																										const = 0
																									}
																								}
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
																					class = "Sequence",
																					id = "52",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								class = "Action",
																								id = "53",
																								properties = {
																									{
																										Method = {
																											func = "moveToPos",
																											params = {
																												{
																													field = "patrolPos"
																												},
																												{
																													field = "patrolMaxTime"
																												},
																												{
																													const = true
																												},
																												{
																													const = 0
																												},
																												{
																													field = "tJudgeSpeedRateType"
																												},
																												{
																													field = "tPatrolSpeed"
																												},
																												{
																													field = "tPathFindType"
																												},
																												{
																													const = false
																												},
																												{
																													field = "tUseAccurateArrive"
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
																										class = "Precondition",
																										precondition = true,
																										transition = false,
																										effector = false,
																										id = "26",
																										properties = {
																											{
																												BinaryOperator = "And"
																											},
																											{
																												Operator = "Equal"
																											},
																											{
																												Opl = {
																													func = "checkIsInRangeTgt2D",
																													params = {
																														{
																															field = "tLeadTargetActorId"
																														},
																														{
																															const = 0
																														},
																														{
																															const = 5
																														},
																														{
																															const = true
																														},
																														{
																															const = true
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
																												Phase = "Enter"
																											}
																										}
																									}
																								},
																								children = {}
																							}
																						},
																						{
																							node = {
																								class = "Action",
																								id = "7",
																								properties = {
																									{
																										Method = {
																											func = "switchToState",
																											params = {
																												{
																													const = "LOCOMOTION"
																												},
																												{
																													const = 0
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
																					class = "Noop",
																					id = "69",
																					properties = {},
																					attachments = {},
																					children = {}
																				}
																			}
																		}
																	}
																},
																{
																	node = {
																		class = "IfElse",
																		id = "72",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					class = "Condition",
																					id = "70",
																					properties = {
																						{
																							Operator = "Equal"
																						},
																						{
																							Opl = {
																								func = "checkIsFlying",
																								params = {
																									{
																										const = 0
																									}
																								}
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
																					class = "Sequence",
																					id = "54",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								class = "Action",
																								id = "55",
																								properties = {
																									{
																										Method = {
																											func = "switchToState",
																											params = {
																												{
																													const = "FLYING"
																												},
																												{
																													const = 0
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
																								id = "56",
																								properties = {
																									{
																										Method = {
																											func = "moveToPos",
																											params = {
																												{
																													field = "patrolPos"
																												},
																												{
																													field = "patrolMaxTime"
																												},
																												{
																													const = true
																												},
																												{
																													const = 0
																												},
																												{
																													field = "tJudgeSpeedRateType"
																												},
																												{
																													field = "tPatrolSpeed"
																												},
																												{
																													field = "tPathFindType"
																												},
																												{
																													const = false
																												},
																												{
																													field = "tUseAccurateArrive"
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
																										class = "Precondition",
																										precondition = true,
																										transition = false,
																										effector = false,
																										id = "26",
																										properties = {
																											{
																												BinaryOperator = "And"
																											},
																											{
																												Operator = "Equal"
																											},
																											{
																												Opl = {
																													func = "checkIsInRangeTgt2D",
																													params = {
																														{
																															field = "tLeadTargetActorId"
																														},
																														{
																															const = 0
																														},
																														{
																															const = 5
																														},
																														{
																															const = true
																														},
																														{
																															const = true
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
																												Phase = "Enter"
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
																					class = "Noop",
																					id = "71",
																					properties = {},
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
															class = "Noop",
															id = "79",
															properties = {},
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
												id = "67",
												properties = {
													{
														Method = {
															func = "moveToPos",
															params = {
																{
																	field = "patrolPos"
																},
																{
																	field = "patrolMaxTime"
																},
																{
																	const = true
																},
																{
																	const = 0
																},
																{
																	field = "tJudgeSpeedRateType"
																},
																{
																	field = "tPatrolSpeed"
																},
																{
																	field = "tPathFindType"
																},
																{
																	const = false
																},
																{
																	field = "tUseAccurateArrive"
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
														class = "Precondition",
														precondition = true,
														transition = false,
														effector = false,
														id = "26",
														properties = {
															{
																BinaryOperator = "And"
															},
															{
																Operator = "Equal"
															},
															{
																Opl = {
																	func = "checkIsInRangeTgt2D",
																	params = {
																		{
																			field = "tLeadTargetActorId"
																		},
																		{
																			const = 0
																		},
																		{
																			const = 5
																		},
																		{
																			const = true
																		},
																		{
																			const = true
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
																Phase = "Enter"
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
									class = "Noop",
									id = "81",
									properties = {},
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

return ST_NPCLeadPatrol
