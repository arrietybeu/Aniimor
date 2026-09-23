-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\_Behav\\PBT_Behav_Com_LeaveAndStare_ToPuppet.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Behav_Com_LeaveAndStare_ToPuppet = {
	behavior = {
		agenttype = "CombatAgent",
		name = "ParmonBehaviorTree/SubTree/_Behav/PBT_Behav_Com_LeaveAndStare_ToPuppet",
		version = 265,
		useForRoute = false,
		properties = {},
		pars = {
			{
				const = 0,
				type = "int",
				name = "tTargetActorId",
				value = "0"
			},
			{
				const = 0,
				type = "int",
				name = "tStareCount",
				value = "0"
			},
			{
				const = 0,
				type = "int",
				name = "LeaveCount",
				value = "0"
			},
			{
				const = 0,
				type = "int",
				name = "tStareCount",
				value = "0"
			}
		},
		attachments = {},
		node = {
			id = "458",
			class = "DecoratorLoop",
			properties = {
				{
					Count = {
						const = -1
					}
				},
				{
					DecorateWhenChildEnds = "true"
				},
				{
					DoneWithinFrame = "false"
				}
			},
			attachments = {},
			children = {
				{
					node = {
						id = "478",
						class = "IfElse",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									id = "479",
									class = "Condition",
									properties = {
										{
											Operator = "LessEqual"
										},
										{
											Opl = {
												field = "tStareCount"
											}
										},
										{
											Opr = {
												const = 2
											}
										}
									},
									attachments = {},
									children = {}
								}
							},
							{
								node = {
									id = "466",
									class = "Sequence",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "461",
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
															id = "459",
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
																				const = true
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
												id = "465",
												class = "Selector",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "467",
															class = "Sequence",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		id = "481",
																		class = "Condition",
																		properties = {
																			{
																				Operator = "Less"
																			},
																			{
																				Opl = {
																					func = "getDistByTgt",
																					params = {
																						{
																							field = "tTargetActorId"
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
																				Opr = {
																					const = 6
																				}
																			}
																		},
																		attachments = {},
																		children = {}
																	}
																},
																{
																	node = {
																		id = "476",
																		class = "IfElse",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					id = "474",
																					class = "Condition",
																					properties = {
																						{
																							Operator = "LessEqual"
																						},
																						{
																							Opl = {
																								field = "LeaveCount"
																							}
																						},
																						{
																							Opr = {
																								const = 3
																							}
																						}
																					},
																					attachments = {},
																					children = {}
																				}
																			},
																			{
																				node = {
																					id = "464",
																					class = "Sequence",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								id = "482",
																								class = "Compute",
																								properties = {
																									{
																										Operator = "Add"
																									},
																									{
																										Opl = {
																											field = "LeaveCount"
																										}
																									},
																									{
																										Opr1 = {
																											field = "LeaveCount"
																										}
																									},
																									{
																										Opr2 = {
																											const = 1
																										}
																									}
																								},
																								attachments = {},
																								children = {}
																							}
																						},
																						{
																							node = {
																								id = "483",
																								class = "Action",
																								properties = {
																									{
																										Method = {
																											func = "leaveTarget",
																											params = {
																												{
																													field = "tTargetActorId"
																												},
																												{
																													const = 6
																												},
																												{
																													const = 0
																												},
																												{
																													const = BaseEnum.SpeedRateType.Mid
																												},
																												{
																													const = 2
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
																					id = "475",
																					class = "ReferencedBehavior",
																					properties = {
																						{
																							ReferenceBehavior = {
																								const = "PBT_Perception_Leave"
																							}
																						},
																						{
																							subTreeProperties = {}
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
															id = "460",
															class = "Sequence",
															properties = {},
															attachments = {
																{
																	effector = false,
																	transition = false,
																	id = "316",
																	precondition = true,
																	class = "Precondition",
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
																						field = "tTargetActorId"
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
																				const = 6
																			}
																		},
																		{
																			Phase = "Both"
																		}
																	}
																},
																{
																	effector = true,
																	transition = false,
																	id = "288",
																	precondition = false,
																	class = "Effector",
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
																		id = "470",
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
																					id = "469",
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
																										const = true
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
																		id = "468",
																		class = "Action",
																		properties = {
																			{
																				Method = {
																					func = "waitTime",
																					params = {
																						{
																							const = 0.2
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
																		id = "463",
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
																		id = "477",
																		class = "Compute",
																		properties = {
																			{
																				Operator = "Add"
																			},
																			{
																				Opl = {
																					field = "tStareCount"
																				}
																			},
																			{
																				Opr1 = {
																					field = "tStareCount"
																				}
																			},
																			{
																				Opr2 = {
																					const = 1
																				}
																			}
																		},
																		attachments = {},
																		children = {}
																	}
																},
																{
																	node = {
																		id = "473",
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
																					id = "472",
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
																								id = "471",
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
																					id = "462",
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
									id = "480",
									class = "ReferencedBehavior",
									properties = {
										{
											ReferenceBehavior = {
												const = "PBT_Perception_Leave"
											}
										},
										{
											subTreeProperties = {}
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

return PBT_Behav_Com_LeaveAndStare_ToPuppet
