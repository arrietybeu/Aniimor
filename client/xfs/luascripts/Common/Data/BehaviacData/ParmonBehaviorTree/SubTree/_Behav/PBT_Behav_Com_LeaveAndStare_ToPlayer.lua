-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\_Behav\\PBT_Behav_Com_LeaveAndStare_ToPlayer.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Behav_Com_LeaveAndStare_ToPlayer = {
	behavior = {
		name = "ParmonBehaviorTree/SubTree/_Behav/PBT_Behav_Com_LeaveAndStare_ToPlayer",
		version = 262,
		useForRoute = false,
		agenttype = "CombatAgent",
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
			id = "343",
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
						id = "348",
						class = "IfElse",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									id = "349",
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
									id = "304",
									class = "Sequence",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "284",
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
															id = "13",
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
												id = "338",
												class = "Selector",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "356",
															class = "Sequence",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		id = "357",
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
																		id = "351",
																		class = "IfElse",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					id = "352",
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
																					id = "353",
																					class = "Sequence",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								id = "325",
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
																								id = "287",
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
																					id = "344",
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
															id = "292",
															class = "Sequence",
															properties = {},
															attachments = {
																{
																	effector = false,
																	precondition = true,
																	class = "Precondition",
																	id = "316",
																	transition = false,
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
																	precondition = false,
																	class = "Effector",
																	id = "288",
																	transition = false,
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
																		id = "312",
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
																					id = "311",
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
																		id = "341",
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
																		id = "293",
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
																		id = "347",
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
																		id = "319",
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
																					id = "318",
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
																								id = "317",
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
																					id = "294",
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
									id = "350",
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

return PBT_Behav_Com_LeaveAndStare_ToPlayer
