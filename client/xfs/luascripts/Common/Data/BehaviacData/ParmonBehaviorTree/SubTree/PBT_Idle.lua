-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_Idle.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Idle = {
	behavior = {
		name = "ParmonBehaviorTree/SubTree/PBT_Idle",
		version = 13,
		agenttype = "WxAgent",
		useForRoute = false,
		properties = {},
		pars = {
			{
				const = 0,
				value = "0",
				type = "int",
				name = "tNoIdleSpProb"
			}
		},
		attachments = {},
		node = {
			id = "20",
			class = "Sequence",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						id = "21",
						class = "Action",
						properties = {
							{
								Method = {
									func = "doSendMessage",
									params = {
										{
											field = "selfId"
										},
										{
											const = {}
										},
										{
											const = "IdleMsgTrigger"
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
						id = "22",
						class = "Action",
						properties = {
							{
								Method = {
									func = "switchToState",
									params = {
										{
											field = "IdleMotionState"
										},
										{
											const = -1
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
						id = "1",
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
									id = "3",
									class = "DecoratorWeight",
									properties = {
										{
											DecorateWhenChildEnds = "false"
										},
										{
											Weight = {
												field = "patrolWeight"
											}
										}
									},
									attachments = {},
									children = {
										{
											node = {
												id = "4",
												class = "Sequence",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "19",
															class = "Action",
															properties = {
																{
																	Method = {
																		func = "patrolInRange",
																		params = {
																			{
																				const = 0
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
															id = "5",
															class = "Assignment",
															properties = {
																{
																	CastRight = "false"
																},
																{
																	Opl = {
																		field = "patrolWeight"
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
													}
												}
											}
										}
									}
								}
							},
							{
								node = {
									id = "7",
									class = "DecoratorWeight",
									properties = {
										{
											DecorateWhenChildEnds = "false"
										},
										{
											Weight = {
												const = 50
											}
										}
									},
									attachments = {},
									children = {
										{
											node = {
												id = "8",
												class = "Sequence",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "46",
															class = "Compute",
															properties = {
																{
																	Operator = "Sub"
																},
																{
																	Opl = {
																		field = "tNoIdleSpProb"
																	}
																},
																{
																	Opr1 = {
																		const = 100
																	}
																},
																{
																	Opr2 = {
																		field = "AI_IdleSpecialProb"
																	}
																}
															},
															attachments = {},
															children = {}
														}
													},
													{
														node = {
															id = "42",
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
																		id = "43",
																		class = "DecoratorWeight",
																		properties = {
																			{
																				DecorateWhenChildEnds = "false"
																			},
																			{
																				Weight = {
																					field = "AI_IdleSpecialProb"
																				}
																			}
																		},
																		attachments = {},
																		children = {
																			{
																				node = {
																					id = "30",
																					class = "SelectorProbability",
																					properties = {
																						{
																							UntilSuccessOrEnd = true
																						}
																					},
																					attachments = {},
																					children = {
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
																											id = "35",
																											class = "Sequence",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "34",
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
																																			const = "IdleSpecial"
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
																														id = "28",
																														class = "Action",
																														properties = {
																															{
																																Method = {
																																	func = "playAction",
																																	params = {
																																		{
																																			const = "IdleSpecial"
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
																							}
																						},
																						{
																							node = {
																								id = "32",
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
																											class = "Sequence",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "37",
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
																																			const = "IdleSpecial02"
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
																														id = "38",
																														class = "Action",
																														properties = {
																															{
																																Method = {
																																	func = "playAction",
																																	params = {
																																		{
																																			const = "IdleSpecial02"
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
																											id = "39",
																											class = "Sequence",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "40",
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
																																			const = "IdleSpecial03"
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
																																	func = "playAction",
																																	params = {
																																		{
																																			const = "IdleSpecial03"
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
																		id = "44",
																		class = "DecoratorWeight",
																		properties = {
																			{
																				DecorateWhenChildEnds = "false"
																			},
																			{
																				Weight = {
																					field = "tNoIdleSpProb"
																				}
																			}
																		},
																		attachments = {},
																		children = {
																			{
																				node = {
																					id = "14",
																					class = "Wait",
																					properties = {
																						{
																							Time = {
																								const = 3000
																							}
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
															id = "12",
															class = "Assignment",
															properties = {
																{
																	CastRight = "false"
																},
																{
																	Opl = {
																		field = "patrolWeight"
																	}
																},
																{
																	Opr = {
																		const = 50
																	}
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

return PBT_Idle
