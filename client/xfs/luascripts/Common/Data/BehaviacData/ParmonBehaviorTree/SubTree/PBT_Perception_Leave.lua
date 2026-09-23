-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_Perception_Leave.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Perception_Leave = {
	behavior = {
		version = 60,
		name = "ParmonBehaviorTree/SubTree/PBT_Perception_Leave",
		agenttype = "CombatAgent",
		useForRoute = false,
		properties = {},
		pars = {
			{
				value = "0",
				type = "int",
				name = "tSensorTgtId",
				const = 0
			},
			{
				value = "0",
				type = "float",
				name = "tLeaveTimeOut",
				const = 0
			},
			{
				value = "Mid",
				type = "SpeedRateType",
				name = "tSpeedRateType",
				const = BaseEnum.SpeedRateType.Mid
			},
			{
				value = "3.5",
				type = "float",
				name = "tSpeed",
				const = 3.5
			}
		},
		attachments = {},
		node = {
			id = "83",
			class = "Sequence",
			properties = {},
			attachments = {
				{
					precondition = false,
					transition = false,
					id = "5",
					class = "Effector",
					effector = true,
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
										const = "TE_Par_Leave"
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
						id = "85",
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
											const = "TE_Par_Leave"
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
						id = "88",
						class = "IfElse",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									id = "90",
									class = "Selector",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "87",
												class = "Condition",
												properties = {
													{
														Operator = "Equal"
													},
													{
														Opl = {
															func = "checkCharacterState",
															params = {
																{
																	const = "AIRING"
																},
																{
																	field = "selfId"
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
												id = "91",
												class = "Condition",
												properties = {
													{
														Operator = "Equal"
													},
													{
														Opl = {
															func = "checkCharacterState",
															params = {
																{
																	const = "CLIMBING"
																},
																{
																	field = "selfId"
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
										}
									}
								}
							},
							{
								node = {
									id = "89",
									class = "Action",
									properties = {
										{
											Method = {
												func = "switchToState",
												params = {
													{
														const = "LOCOMOTION"
													},
													{
														const = 5
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
									id = "86",
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
						id = "70",
						class = "Sequence",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									id = "71",
									class = "Action",
									properties = {
										{
											Method = {
												func = "setAttenuationMultiple",
												params = {
													{
														field = "selfId"
													},
													{
														const = 0.1
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
									id = "72",
									class = "IfElse",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "73",
												class = "Condition",
												properties = {
													{
														Operator = "Equal"
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
												id = "46",
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
												id = "74",
												class = "True",
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
						id = "35",
						class = "IfElse",
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
									id = "28",
									class = "Sequence",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "36",
												class = "Action",
												properties = {
													{
														Method = {
															func = "showQuestionMark",
															params = {
																{
																	const = "DirectFull"
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
														ResultResumeOption = "BT_None"
													}
												},
												attachments = {},
												children = {}
											}
										},
										{
											node = {
												id = "27",
												class = "Action",
												properties = {
													{
														Method = {
															func = "switchToFly",
															params = {
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
														ResultOption = "BT_INVALID"
													},
													{
														ResultResumeOption = "BT_ResumeTree"
													}
												},
												attachments = {
													{
														precondition = false,
														transition = false,
														id = "77",
														class = "Effector",
														effector = true,
														properties = {
															{
																Operator = "Invalid"
															},
															{
																Opl = {
																	func = "setAttenuationMultiple",
																	params = {
																		{
																			field = "selfId"
																		},
																		{
																			const = 1
																		}
																	}
																}
															},
															{
																Phase = "Failure"
															}
														}
													}
												},
												children = {}
											}
										},
										{
											node = {
												id = "37",
												class = "Selector",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "99",
															class = "Action",
															properties = {
																{
																	Method = {
																		func = "leaveTargetInCatchFailure",
																		params = {
																			{
																				field = "tSensorTgtId"
																			},
																			{
																				const = 25
																			},
																			{
																				const = 3.5
																			},
																			{
																				const = BaseEnum.SpeedRateType.Mid
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
																	precondition = false,
																	transition = false,
																	id = "100",
																	class = "Effector",
																	effector = true,
																	properties = {
																		{
																			Operator = "Invalid"
																		},
																		{
																			Opl = {
																				func = "setAttenuationMultiple",
																				params = {
																					{
																						field = "selfId"
																					},
																					{
																						const = 1
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
															children = {}
														}
													},
													{
														node = {
															id = "38",
															class = "True",
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
												id = "31",
												class = "Action",
												properties = {
													{
														Method = {
															func = "enterDestroySelf"
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
							},
							{
								node = {
									id = "6",
									class = "Sequence",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "39",
												class = "Selector",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "101",
															class = "Action",
															properties = {
																{
																	Method = {
																		func = "leaveTargetInCatchFailure",
																		params = {
																			{
																				field = "tSensorTgtId"
																			},
																			{
																				const = 35
																			},
																			{
																				field = "tSpeed"
																			},
																			{
																				field = "tSpeedRateType"
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
																	precondition = false,
																	transition = false,
																	id = "100",
																	class = "Effector",
																	effector = true,
																	properties = {
																		{
																			Operator = "Invalid"
																		},
																		{
																			Opl = {
																				func = "setAttenuationMultiple",
																				params = {
																					{
																						field = "selfId"
																					},
																					{
																						const = 1
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
															children = {}
														}
													},
													{
														node = {
															id = "43",
															class = "Action",
															properties = {
																{
																	Method = {
																		func = "enterDestroySelf"
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
										},
										{
											node = {
												id = "69",
												class = "Action",
												properties = {
													{
														Method = {
															func = "enterDestroySelf"
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

return PBT_Perception_Leave
