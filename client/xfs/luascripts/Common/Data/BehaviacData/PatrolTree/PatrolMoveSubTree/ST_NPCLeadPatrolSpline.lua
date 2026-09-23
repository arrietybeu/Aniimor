-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\PatrolTree\\PatrolMoveSubTree\\ST_NPCLeadPatrolSpline.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local ST_NPCLeadPatrolSpline = {
	behavior = {
		useForRoute = false,
		agenttype = "WxAgent",
		name = "PatrolTree/PatrolMoveSubTree/ST_NPCLeadPatrolSpline",
		version = 16,
		properties = {},
		pars = {
			{
				type = "vector<float>",
				name = "patrolStartPos",
				value = "0:",
				const = {}
			},
			{
				type = "vector<float>",
				name = "patrolPosList",
				value = "0:",
				const = {}
			},
			{
				type = "float",
				name = "patrolMaxTime",
				const = 0,
				value = "0"
			},
			{
				type = "float",
				name = "tPatrolSpeed",
				const = 0,
				value = "0"
			},
			{
				type = "SpeedRateType",
				name = "tBehaviorSpeedRateType",
				value = "Mid",
				const = BaseEnum.SpeedRateType.Mid
			},
			{
				type = "bool",
				name = "tUseAccurateArrive",
				const = false,
				value = "false"
			},
			{
				type = "bool",
				name = "tIsFirstPoint",
				const = false,
				value = "false"
			},
			{
				type = "int",
				name = "tLeadTargetActorId",
				const = 0,
				value = "0"
			},
			{
				type = "vector<float>",
				name = "tNormalList",
				value = "0:",
				const = {}
			},
			{
				type = "SpeedRateType",
				name = "tJudgeSpeedRateType",
				value = "Slow",
				const = BaseEnum.SpeedRateType.Slow
			},
			{
				type = "vector<float>",
				name = "patrolPos",
				value = "0:",
				const = {}
			},
			{
				type = "PathFindType",
				name = "tPathFindType",
				value = "Auto",
				const = BaseEnum.PathFindType.Auto
			}
		},
		attachments = {},
		node = {
			class = "Parallel",
			id = "29",
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
						id = "32",
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
											field = "tJudgeSpeedRateType"
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
						id = "27",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									class = "Sequence",
									id = "1",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												class = "IfElse",
												id = "2",
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
																		id = "7",
																		properties = {
																			{
																				Operator = "Equal"
																			},
																			{
																				Opl = {
																					func = "checkPosIsOnGround",
																					params = {
																						{
																							field = "patrolStartPos"
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
																		class = "Selector",
																		id = "8",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					class = "Condition",
																					id = "12",
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
																					id = "39",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								class = "Action",
																								id = "38",
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
																													field = "tBehaviorSpeedRateType"
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
																								attachments = {},
																								children = {}
																							}
																						},
																						{
																							node = {
																								class = "Action",
																								id = "37",
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
																			}
																		}
																	}
																},
																{
																	node = {
																		class = "Selector",
																		id = "9",
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
																					id = "42",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								class = "Action",
																								id = "40",
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
																								id = "41",
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
																													field = "tBehaviorSpeedRateType"
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
													},
													{
														node = {
															class = "Noop",
															id = "6",
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
												class = "Selector",
												id = "17",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															class = "Condition",
															id = "18",
															properties = {
																{
																	Operator = "Equal"
																},
																{
																	Opl = {
																		field = "tIsFirstPoint"
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
															id = "15",
															properties = {
																{
																	Method = {
																		func = "moveToPos",
																		params = {
																			{
																				field = "patrolStartPos"
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
																				const = BaseEnum.PathFindType.Auto
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
																	precondition = true,
																	class = "Precondition",
																	transition = false,
																	id = "19",
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
																			Phase = "Update"
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
												class = "Action",
												id = "10",
												properties = {
													{
														Method = {
															func = "moveToPosList",
															params = {
																{
																	field = "patrolPosList"
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
																	field = "tNormalList"
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
														precondition = true,
														class = "Precondition",
														transition = false,
														id = "21",
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
																Phase = "Update"
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
									class = "True",
									id = "28",
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

return ST_NPCLeadPatrolSpline
