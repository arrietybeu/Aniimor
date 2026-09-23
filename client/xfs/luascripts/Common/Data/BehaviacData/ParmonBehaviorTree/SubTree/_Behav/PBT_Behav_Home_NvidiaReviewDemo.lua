-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\_Behav\\PBT_Behav_Home_NvidiaReviewDemo.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Behav_Home_NvidiaReviewDemo = {
	behavior = {
		name = "ParmonBehaviorTree/SubTree/_Behav/PBT_Behav_Home_NvidiaReviewDemo",
		useForRoute = false,
		version = 62,
		agenttype = "CombatAgent",
		properties = {},
		pars = {
			{
				name = "tAnimationKey",
				type = "string",
				const = "0",
				value = "0"
			},
			{
				name = "tEmojiKey",
				type = "string",
				const = "0",
				value = "0"
			},
			{
				name = "tAnimationStartKey",
				type = "string",
				const = "",
				value = ""
			},
			{
				name = "tAnimationLoopKey",
				type = "string",
				const = "",
				value = ""
			},
			{
				name = "tAnimationEndKey",
				type = "string",
				const = "",
				value = ""
			},
			{
				name = "tSpeed",
				type = "float",
				const = 2,
				value = "2"
			},
			{
				name = "tSpeedRateType",
				type = "SpeedRateType",
				value = "Mid",
				const = BaseEnum.SpeedRateType.Mid
			},
			{
				name = "tActorId",
				type = "int",
				const = 0,
				value = "0"
			},
			{
				name = "tAnimationTime",
				type = "float",
				const = 0,
				value = "0"
			},
			{
				name = "tEmojiTime",
				type = "float",
				const = 0,
				value = "0"
			},
			{
				name = "tTargetPos",
				type = "vector<float>",
				value = "1:0",
				const = {
					0
				}
			},
			{
				name = "tStopDist",
				type = "float",
				const = 0,
				value = "0"
			},
			{
				name = "tIsFollow",
				type = "bool",
				const = false,
				value = "false"
			},
			{
				name = "tMoveDist",
				type = "float",
				const = 0,
				value = "0"
			},
			{
				name = "tIsGoTargetPos",
				type = "bool",
				const = false,
				value = "false"
			}
		},
		attachments = {},
		node = {
			id = "77",
			class = "IfElse",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						id = "79",
						class = "Condition",
						properties = {
							{
								Operator = "NotEqual"
							},
							{
								Opl = {
									field = "tIsFollow"
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
						id = "39",
						class = "Sequence",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									id = "53",
									class = "Selector",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "72",
												class = "Sequence",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "88",
															class = "Condition",
															properties = {
																{
																	Operator = "Equal"
																},
																{
																	Opl = {
																		field = "tIsGoTargetPos"
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
															id = "70",
															class = "Action",
															properties = {
																{
																	Method = {
																		func = "moveToPos",
																		params = {
																			{
																				field = "tTargetPos"
																			},
																			{
																				const = 0
																			},
																			{
																				const = true
																			},
																			{
																				const = 0
																			},
																			{
																				field = "tSpeedRateType"
																			},
																			{
																				field = "tSpeed"
																			},
																			{
																				const = BaseEnum.PathFindType.Auto
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
												id = "57",
												class = "Sequence",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "56",
															class = "Condition",
															properties = {
																{
																	Operator = "NotEqual"
																},
																{
																	Opl = {
																		field = "tActorId"
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
															id = "58",
															class = "Action",
															properties = {
																{
																	Method = {
																		func = "moveToTarget",
																		params = {
																			{
																				field = "tActorId"
																			},
																			{
																				const = 2
																			},
																			{
																				const = 0
																			},
																			{
																				const = false
																			},
																			{
																				const = true
																			},
																			{
																				const = true
																			},
																			{
																				field = "tSpeed"
																			},
																			{
																				const = BaseEnum.MoveUpdateLevel.Normal
																			},
																			{
																				const = BaseEnum.PathFindType.Auto
																			},
																			{
																				field = "tSpeedRateType"
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
												id = "62",
												class = "Sequence",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "61",
															class = "Condition",
															properties = {
																{
																	Operator = "Equal"
																},
																{
																	Opl = {
																		field = "tActorId"
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
															id = "63",
															class = "Noop",
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
									id = "65",
									class = "Selector",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "45",
												class = "Action",
												properties = {
													{
														Method = {
															func = "showEmojiBubble",
															params = {
																{
																	field = "tEmojiKey"
																},
																{
																	field = "tEmojiTime"
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
												id = "66",
												class = "Noop",
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
									id = "48",
									class = "Selector",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "49",
												class = "Sequence",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "50",
															class = "Condition",
															properties = {
																{
																	Operator = "NotEqual"
																},
																{
																	Opl = {
																		field = "tAnimationKey"
																	}
																},
																{
																	Opr = {
																		const = ""
																	}
																}
															},
															attachments = {},
															children = {}
														}
													},
													{
														node = {
															id = "67",
															class = "Action",
															properties = {
																{
																	Method = {
																		func = "turnToTarget",
																		params = {
																			{
																				field = "tActorId"
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
															id = "44",
															class = "Action",
															properties = {
																{
																	Method = {
																		func = "playAction",
																		params = {
																			{
																				field = "tAnimationKey"
																			},
																			{
																				field = "tAnimationTime"
																			},
																			{
																				const = ""
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
										},
										{
											node = {
												id = "51",
												class = "Sequence",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "52",
															class = "Condition",
															properties = {
																{
																	Operator = "NotEqual"
																},
																{
																	Opl = {
																		field = "tAnimationStartKey"
																	}
																},
																{
																	Opr = {
																		const = ""
																	}
																}
															},
															attachments = {},
															children = {}
														}
													},
													{
														node = {
															id = "68",
															class = "Action",
															properties = {
																{
																	Method = {
																		func = "turnToTarget",
																		params = {
																			{
																				field = "tActorId"
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
															id = "69",
															class = "Action",
															properties = {
																{
																	Method = {
																		func = "playPhaseAction",
																		params = {
																			{
																				field = "tAnimationStartKey"
																			},
																			{
																				field = "tAnimationLoopKey"
																			},
																			{
																				field = "tAnimationEndKey"
																			},
																			{
																				field = "tAnimationTime"
																			},
																			{
																				const = ""
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
												id = "64",
												class = "Noop",
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
						id = "85",
						class = "Sequence",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									id = "87",
									class = "Compute",
									properties = {
										{
											Operator = "Add"
										},
										{
											Opl = {
												field = "tMoveDist"
											}
										},
										{
											Opr1 = {
												field = "tStopDist"
											}
										},
										{
											Opr2 = {
												const = 0.5
											}
										}
									},
									attachments = {},
									children = {}
								}
							},
							{
								node = {
									id = "76",
									class = "DecoratorLoopUntil",
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
											Until = "false"
										}
									},
									attachments = {},
									children = {
										{
											node = {
												id = "83",
												class = "IfElse",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "82",
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
																				field = "tActorId"
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
																		field = "tMoveDist"
																	}
																}
															},
															attachments = {},
															children = {}
														}
													},
													{
														node = {
															id = "89",
															class = "Action",
															properties = {
																{
																	Method = {
																		func = "followEntity",
																		params = {
																			{
																				field = "tActorId"
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
															id = "81",
															class = "Action",
															properties = {
																{
																	Method = {
																		func = "waitTime",
																		params = {
																			{
																				const = 0.5
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

return PBT_Behav_Home_NvidiaReviewDemo
