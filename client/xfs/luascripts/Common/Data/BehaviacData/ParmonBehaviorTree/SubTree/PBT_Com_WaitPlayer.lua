-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_Com_WaitPlayer.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Com_WaitPlayer = {
	behavior = {
		version = 20,
		useForRoute = true,
		agenttype = "PuppetAgent",
		name = "ParmonBehaviorTree/SubTree/PBT_Com_WaitPlayer",
		properties = {},
		pars = {
			{
				value = "true",
				const = true,
				type = "bool",
				name = "tFirstLoop"
			}
		},
		attachments = {},
		node = {
			id = "44",
			class = "DecoratorAlwaysSuccess",
			properties = {
				{
					DecorateWhenChildEnds = "true"
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
									class = "Assignment",
									properties = {
										{
											CastRight = "false"
										},
										{
											Opl = {
												field = "tgt"
											}
										},
										{
											Opr = {
												func = "getAuthorityPlayer"
											}
										}
									},
									attachments = {},
									children = {}
								}
							},
							{
								node = {
									id = "32",
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
									attachments = {
										{
											class = "Precondition",
											id = "33",
											transition = false,
											effector = false,
											precondition = true,
											properties = {
												{
													BinaryOperator = "And"
												},
												{
													Operator = "GreaterEqual"
												},
												{
													Opl = {
														func = "getDistByTgt",
														params = {
															{
																field = "tgt"
															},
															{
																const = false
															},
															{
																const = false
															},
															{
																const = 0
															}
														}
													}
												},
												{
													Opr2 = {
														const = 8
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
												id = "42",
												class = "Sequence",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "43",
															class = "Assignment",
															properties = {
																{
																	CastRight = "false"
																},
																{
																	Opl = {
																		field = "tgt"
																	}
																},
																{
																	Opr = {
																		func = "getAuthorityPlayer"
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
															class = "IfElse",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		id = "10",
																		class = "Condition",
																		properties = {
																			{
																				Operator = "Equal"
																			},
																			{
																				Opl = {
																					field = "tFirstLoop"
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
																		id = "21",
																		class = "Sequence",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					id = "27",
																					class = "Action",
																					properties = {
																						{
																							Method = {
																								func = "turnToTargetAtYaw",
																								params = {
																									{
																										field = "tgt"
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
																					id = "8",
																					class = "Action",
																					properties = {
																						{
																							Method = {
																								func = "playAction",
																								params = {
																									{
																										const = "Story_Greet"
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
																					id = "22",
																					class = "Assignment",
																					properties = {
																						{
																							CastRight = "false"
																						},
																						{
																							Opl = {
																								field = "tFirstLoop"
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
																			}
																		}
																	}
																},
																{
																	node = {
																		id = "13",
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
																					id = "15",
																					class = "DecoratorWeight",
																					properties = {
																						{
																							DecorateWhenChildEnds = "false"
																						},
																						{
																							Weight = {
																								const = 100
																							}
																						}
																					},
																					attachments = {},
																					children = {
																						{
																							node = {
																								id = "17",
																								class = "Sequence",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											id = "12",
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
																									},
																									{
																										node = {
																											id = "18",
																											class = "Action",
																											properties = {
																												{
																													Method = {
																														func = "waitTime",
																														params = {
																															{
																																const = 5
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
																					id = "16",
																					class = "DecoratorWeight",
																					properties = {
																						{
																							DecorateWhenChildEnds = "false"
																						},
																						{
																							Weight = {
																								const = 100
																							}
																						}
																					},
																					attachments = {},
																					children = {
																						{
																							node = {
																								id = "20",
																								class = "Sequence",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											id = "9",
																											class = "Action",
																											properties = {
																												{
																													Method = {
																														func = "playPhaseAction",
																														params = {
																															{
																																const = "Emotion_Think_Start"
																															},
																															{
																																const = "Emotion_Think_Loop"
																															},
																															{
																																const = "Emotion_Think_End"
																															},
																															{
																																const = 8
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
																											attachments = {
																												{
																													class = "Precondition",
																													id = "41",
																													transition = false,
																													effector = false,
																													precondition = true,
																													properties = {
																														{
																															BinaryOperator = "And"
																														},
																														{
																															Operator = "GreaterEqual"
																														},
																														{
																															Opl = {
																																func = "getDistByTgt",
																																params = {
																																	{
																																		field = "tgt"
																																	},
																																	{
																																		const = false
																																	},
																																	{
																																		const = false
																																	},
																																	{
																																		const = 0
																																	}
																																}
																															}
																														},
																														{
																															Opr2 = {
																																const = 8
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
																									},
																									{
																										node = {
																											id = "19",
																											class = "Action",
																											properties = {
																												{
																													Method = {
																														func = "waitTime",
																														params = {
																															{
																																const = 5
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

return PBT_Com_WaitPlayer
