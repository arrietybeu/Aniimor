-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_Perception_Stare.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Perception_Stare = {
	behavior = {
		agenttype = "CombatAgent",
		version = 14,
		useForRoute = false,
		name = "ParmonBehaviorTree/SubTree/PBT_Perception_Stare",
		properties = {},
		pars = {
			{
				type = "int",
				value = "0",
				name = "tSensorTgtId",
				const = 0
			},
			{
				type = "float",
				value = "0",
				name = "tMaxTime",
				const = 0
			},
			{
				type = "float",
				value = "0",
				name = "tRandomTime",
				const = 0
			}
		},
		attachments = {},
		node = {
			id = "1",
			class = "Sequence",
			properties = {},
			attachments = {
				{
					id = "46",
					transition = false,
					class = "Effector",
					effector = true,
					precondition = false,
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
										const = "TE_Par_Stare"
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
						id = "27",
						class = "Assignment",
						properties = {
							{
								CastRight = "false"
							},
							{
								Opl = {
									field = "tSensorTgtId"
								}
							},
							{
								Opr = {
									func = "getPerceptibilityTarget"
								}
							}
						},
						attachments = {},
						children = {}
					}
				},
				{
					node = {
						id = "2",
						class = "Condition",
						properties = {
							{
								Operator = "NotEqual"
							},
							{
								Opl = {
									field = "tSensorTgtId"
								}
							},
							{
								Opr = {
									const = 0
								}
							}
						},
						attachments = {},
						children = {}
					}
				},
				{
					node = {
						id = "45",
						class = "Action",
						properties = {
							{
								Method = {
									func = "addEntityTag",
									params = {
										{
											field = "selfId"
										},
										{
											const = "TE_Par_Stare"
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
						id = "31",
						class = "IfElse",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									id = "33",
									class = "Condition",
									properties = {
										{
											Operator = "Equal"
										},
										{
											Opl = {
												func = "hasAITag",
												params = {
													{
														const = 0
													},
													{
														const = "TA_VisionFull"
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
									id = "15",
									class = "DecoratorAlwaysRunning",
									properties = {
										{
											DecorateWhenChildEnds = "false"
										}
									},
									attachments = {
										{
											id = "24",
											transition = false,
											class = "Precondition",
											effector = false,
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
														func = "hasAITag",
														params = {
															{
																field = "selfId"
															},
															{
																const = "TA_VisionFull"
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
												id = "14",
												class = "DecoratorLoop",
												properties = {
													{
														Count = {
															const = -1
														}
													},
													{
														DecorateWhenChildEnds = "false"
													},
													{
														DoneWithinFrame = "false"
													}
												},
												attachments = {},
												children = {
													{
														node = {
															id = "25",
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
															attachments = {},
															children = {
																{
																	node = {
																		id = "22",
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
																					id = "23",
																					class = "DecoratorWeight",
																					properties = {
																						{
																							DecorateWhenChildEnds = "false"
																						},
																						{
																							Weight = {
																								const = 30
																							}
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
																											func = "waitTime",
																											params = {
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
																						}
																					}
																				}
																			},
																			{
																				node = {
																					id = "24",
																					class = "DecoratorWeight",
																					properties = {
																						{
																							DecorateWhenChildEnds = "false"
																						},
																						{
																							Weight = {
																								const = 10
																							}
																						}
																					},
																					attachments = {},
																					children = {
																						{
																							node = {
																								id = "10",
																								class = "Selector",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											id = "12",
																											class = "Sequence",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "13",
																														class = "Condition",
																														properties = {
																															{
																																Operator = "Equal"
																															},
																															{
																																Opl = {
																																	func = "hasAnimState",
																																	params = {
																																		{
																																			const = "Behav_AngryLoop"
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
																														id = "11",
																														class = "Action",
																														properties = {
																															{
																																Method = {
																																	func = "playPhaseAction",
																																	params = {
																																		{
																																			const = "Behav_AngryStart"
																																		},
																																		{
																																			const = "Behav_AngryLoop"
																																		},
																																		{
																																			const = "Behav_AngryEnd"
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
																																const = "Behav_Angry"
																															},
																															{
																																const = 4
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
																				}
																			}
																		}
																	}
																},
																{
																	node = {
																		id = "26",
																		class = "Action",
																		properties = {
																			{
																				Method = {
																					func = "turnToTarget",
																					params = {
																						{
																							field = "tSensorTgtId"
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
													}
												}
											}
										}
									}
								}
							},
							{
								node = {
									id = "34",
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
									attachments = {},
									children = {
										{
											node = {
												id = "35",
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
															id = "37",
															class = "DecoratorWeight",
															properties = {
																{
																	DecorateWhenChildEnds = "false"
																},
																{
																	Weight = {
																		const = 30
																	}
																}
															},
															attachments = {},
															children = {
																{
																	node = {
																		id = "39",
																		class = "Action",
																		properties = {
																			{
																				Method = {
																					func = "waitTime",
																					params = {
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
																}
															}
														}
													},
													{
														node = {
															id = "38",
															class = "DecoratorWeight",
															properties = {
																{
																	DecorateWhenChildEnds = "false"
																},
																{
																	Weight = {
																		const = 10
																	}
																}
															},
															attachments = {},
															children = {
																{
																	node = {
																		id = "40",
																		class = "Selector",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					id = "42",
																					class = "Sequence",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								id = "43",
																								class = "Condition",
																								properties = {
																									{
																										Operator = "Equal"
																									},
																									{
																										Opl = {
																											func = "hasAnimState",
																											params = {
																												{
																													const = "Behav_AngryLoop"
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
																								id = "41",
																								class = "Action",
																								properties = {
																									{
																										Method = {
																											func = "playPhaseAction",
																											params = {
																												{
																													const = "Behav_AngryStart"
																												},
																												{
																													const = "Behav_AngryLoop"
																												},
																												{
																													const = "Behav_AngryEnd"
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
																			},
																			{
																				node = {
																					id = "44",
																					class = "Action",
																					properties = {
																						{
																							Method = {
																								func = "playAction",
																								params = {
																									{
																										const = "Behav_Angry"
																									},
																									{
																										const = 4
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
														}
													}
												}
											}
										},
										{
											node = {
												id = "36",
												class = "Action",
												properties = {
													{
														Method = {
															func = "turnToTarget",
															params = {
																{
																	field = "tSensorTgtId"
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
							}
						}
					}
				}
			}
		}
	}
}

return PBT_Perception_Stare
