-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\_Behav\\PBT_Behav_Com_Scare.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Behav_Com_Scare = {
	behavior = {
		agenttype = "CombatAgent",
		name = "ParmonBehaviorTree/SubTree/_Behav/PBT_Behav_Com_Scare",
		version = 186,
		useForRoute = false,
		properties = {},
		pars = {
			{
				name = "tTargetActorId",
				value = "0",
				type = "int",
				const = 0
			},
			{
				name = "MoveToCount",
				value = "0",
				type = "int",
				const = 0
			}
		},
		attachments = {},
		node = {
			id = "264",
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
						id = "252",
						class = "Selector",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									id = "2",
									class = "Sequence",
									properties = {},
									attachments = {
										{
											transition = false,
											id = "243",
											class = "Precondition",
											effector = false,
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
														field = "MoveToCount"
													}
												},
												{
													Opr2 = {
														const = 3
													}
												},
												{
													Phase = "Enter"
												}
											}
										}
									},
									children = {
										{
											node = {
												id = "280",
												class = "Compute",
												properties = {
													{
														Operator = "Add"
													},
													{
														Opl = {
															field = "MoveToCount"
														}
													},
													{
														Opr1 = {
															field = "MoveToCount"
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
										},
										{
											node = {
												id = "163",
												class = "Selector",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "177",
															class = "IfElse",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		id = "178",
																		class = "Condition",
																		properties = {
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
																				Opr = {
																					const = 5
																				}
																			}
																		},
																		attachments = {},
																		children = {}
																	}
																},
																{
																	node = {
																		id = "179",
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
																							const = 4.5
																						},
																						{
																							const = 0
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
																							const = BaseEnum.SpeedRateType.Mid
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
																		id = "180",
																		class = "False",
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
															id = "181",
															class = "IfElse",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		id = "192",
																		class = "Condition",
																		properties = {
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
																					const = 4
																				}
																			}
																		},
																		attachments = {},
																		children = {}
																	}
																},
																{
																	node = {
																		id = "193",
																		class = "Action",
																		properties = {
																			{
																				Method = {
																					func = "walkBack",
																					params = {
																						{
																							field = "tTargetActorId"
																						},
																						{
																							const = 5
																						},
																						{
																							const = 5
																						},
																						{
																							const = 2
																						}
																					}
																				}
																			},
																			{
																				ResultOption = "BT_SUCCESS"
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
																		id = "184",
																		class = "False",
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
															id = "215",
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
																		id = "219",
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
																					id = "185",
																					class = "Sequence",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								id = "190",
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
																											id = "186",
																											class = "Action",
																											properties = {
																												{
																													Method = {
																														func = "sideWalk",
																														params = {
																															{
																																field = "tTargetActorId"
																															},
																															{
																																const = 0.5
																															},
																															{
																																const = -35
																															},
																															{
																																const = -1
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
																								id = "188",
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
																											id = "191",
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
																		id = "220",
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
																					id = "221",
																					class = "Sequence",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								id = "222",
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
																											id = "224",
																											class = "Action",
																											properties = {
																												{
																													Method = {
																														func = "sideWalk",
																														params = {
																															{
																																field = "tTargetActorId"
																															},
																															{
																																const = 0.5
																															},
																															{
																																const = 35
																															},
																															{
																																const = -1
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
																								id = "223",
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
																											id = "225",
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
										},
										{
											node = {
												id = "273",
												class = "Selector",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "160",
															class = "Sequence",
															properties = {},
															attachments = {
																{
																	transition = false,
																	id = "161",
																	class = "Precondition",
																	effector = false,
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
																			Phase = "Enter"
																		}
																	}
																},
																{
																	transition = false,
																	id = "208",
																	class = "Precondition",
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
																				const = 4
																			}
																		},
																		{
																			Phase = "Enter"
																		}
																	}
																}
															},
															children = {
																{
																	node = {
																		id = "26",
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
																					id = "135",
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
																								id = "18",
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
																					id = "143",
																					class = "Sequence",
																					properties = {},
																					attachments = {
																						{
																							transition = false,
																							id = "157",
																							class = "Effector",
																							effector = true,
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
																								id = "17",
																								class = "Action",
																								properties = {
																									{
																										Method = {
																											func = "showEmojiBubble",
																											params = {
																												{
																													const = "Angry"
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
																								id = "19",
																								class = "Action",
																								properties = {
																									{
																										Method = {
																											func = "playSleAnimationOnce",
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
													},
													{
														node = {
															id = "272",
															class = "Sequence",
															properties = {},
															attachments = {
																{
																	transition = false,
																	id = "208",
																	class = "Precondition",
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
																				const = 8
																			}
																		},
																		{
																			Phase = "Enter"
																		}
																	}
																}
															},
															children = {
																{
																	node = {
																		id = "274",
																		class = "Assignment",
																		properties = {
																			{
																				CastRight = "false"
																			},
																			{
																				Opl = {
																					field = "MoveToCount"
																				}
																			},
																			{
																				Opr = {
																					const = 4
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
												id = "232",
												class = "Sequence",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "151",
															class = "Action",
															properties = {
																{
																	Method = {
																		func = "waitTime",
																		params = {
																			{
																				const = 0.7
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
									id = "253",
									class = "Sequence",
									properties = {},
									attachments = {
										{
											transition = false,
											id = "243",
											class = "Precondition",
											effector = false,
											precondition = true,
											properties = {
												{
													BinaryOperator = "And"
												},
												{
													Operator = "Greater"
												},
												{
													Opl = {
														field = "MoveToCount"
													}
												},
												{
													Opr2 = {
														const = 3
													}
												},
												{
													Phase = "Enter"
												}
											}
										}
									},
									children = {
										{
											node = {
												id = "283",
												class = "Selector",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "281",
															class = "Sequence",
															properties = {},
															attachments = {
																{
																	transition = false,
																	id = "208",
																	class = "Precondition",
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
																				const = 10
																			}
																		},
																		{
																			Phase = "Enter"
																		}
																	}
																}
															},
															children = {
																{
																	node = {
																		id = "278",
																		class = "Sequence",
																		properties = {},
																		attachments = {
																			{
																				transition = false,
																				id = "279",
																				class = "Effector",
																				effector = true,
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
																					id = "269",
																					class = "Action",
																					properties = {
																						{
																							Method = {
																								func = "showEmojiBubble",
																								params = {
																									{
																										const = "Angry"
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
																					id = "266",
																					class = "Action",
																					properties = {
																						{
																							Method = {
																								func = "walkBack",
																								params = {
																									{
																										field = "tTargetActorId"
																									},
																									{
																										const = 30
																									},
																									{
																										const = 1
																									},
																									{
																										const = 0
																									}
																								}
																							}
																						},
																						{
																							ResultOption = "BT_SUCCESS"
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
																		id = "257",
																		class = "Action",
																		properties = {
																			{
																				Method = {
																					func = "turnToTargetAtYaw",
																					params = {
																						{
																							field = "tTargetActorId"
																						},
																						{
																							const = 180
																						},
																						{
																							const = false
																						},
																						{
																							const = 2
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
																		id = "263",
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
																							const = 50
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
															id = "282",
															class = "Action",
															properties = {
																{
																	Method = {
																		func = "enterCombat",
																		params = {
																			{
																				field = "tTargetActorId"
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
							}
						}
					}
				}
			}
		}
	}
}

return PBT_Behav_Com_Scare
