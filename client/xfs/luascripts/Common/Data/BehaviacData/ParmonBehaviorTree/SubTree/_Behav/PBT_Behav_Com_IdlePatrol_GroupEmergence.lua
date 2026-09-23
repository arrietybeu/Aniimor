-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\_Behav\\PBT_Behav_Com_IdlePatrol_GroupEmergence.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Behav_Com_IdlePatrol_GroupEmergence = {
	behavior = {
		useForRoute = false,
		version = 15,
		agenttype = "WxAgent",
		name = "ParmonBehaviorTree/SubTree/_Behav/PBT_Behav_Com_IdlePatrol_GroupEmergence",
		properties = {},
		pars = {
			{
				name = "tNoIdleSpProb",
				const = 0,
				value = "0",
				type = "int"
			},
			{
				name = "SpeedRateType",
				value = "Slow",
				type = "SpeedRateType",
				const = BaseEnum.SpeedRateType.Slow
			},
			{
				name = "Speed",
				const = 1,
				value = "1",
				type = "float"
			},
			{
				name = "tBornPos",
				value = "0:",
				type = "vector<float>",
				const = {}
			}
		},
		attachments = {},
		node = {
			class = "Sequence",
			id = "28",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						class = "Assignment",
						id = "37",
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
						id = "9",
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
						class = "SelectorProbability",
						id = "0",
						properties = {
							{
								UntilSuccessOrEnd = false
							}
						},
						attachments = {},
						children = {
							{
								node = {
									class = "DecoratorWeight",
									id = "2",
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
												class = "Sequence",
												id = "1",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															class = "IfElse",
															id = "34",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		class = "Condition",
																		id = "36",
																		properties = {
																			{
																				Operator = "GreaterEqual"
																			},
																			{
																				Opl = {
																					func = "getDistByPos",
																					params = {
																						{
																							field = "tBornPos"
																						},
																						{
																							const = false
																						},
																						{
																							field = "selfId"
																						}
																					}
																				}
																			},
																			{
																				Opr = {
																					const = 30
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
																		id = "38",
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
																},
																{
																	node = {
																		class = "Selector",
																		id = "40",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					class = "Action",
																					id = "4",
																					properties = {
																						{
																							Method = {
																								func = "patrolInRange",
																								params = {
																									{
																										const = 0
																									},
																									{
																										field = "SpeedRateType"
																									},
																									{
																										field = "Speed"
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
																}
															}
														}
													},
													{
														node = {
															class = "Assignment",
															id = "3",
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
									class = "DecoratorWeight",
									id = "5",
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
												class = "Sequence",
												id = "6",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															class = "Compute",
															id = "26",
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
															class = "SelectorProbability",
															id = "23",
															properties = {
																{
																	UntilSuccessOrEnd = false
																}
															},
															attachments = {},
															children = {
																{
																	node = {
																		class = "DecoratorWeight",
																		id = "24",
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
																					class = "SelectorProbability",
																					id = "12",
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
																								id = "13",
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
																											class = "Sequence",
																											id = "11",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														class = "Condition",
																														id = "16",
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
																														class = "Action",
																														id = "10",
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
																								class = "DecoratorWeight",
																								id = "14",
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
																											class = "Sequence",
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
																														class = "Action",
																														id = "19",
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
																								class = "DecoratorWeight",
																								id = "15",
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
																											class = "Sequence",
																											id = "20",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														class = "Condition",
																														id = "21",
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
																														class = "Action",
																														id = "22",
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
																		class = "DecoratorWeight",
																		id = "25",
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
																					class = "Wait",
																					id = "8",
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
															class = "Assignment",
															id = "7",
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

return PBT_Behav_Com_IdlePatrol_GroupEmergence
