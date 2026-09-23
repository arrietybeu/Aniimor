-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\_Wild\\10471_Pomegg\\PBT_Wild_10471_Perception_LeaveByRoll.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Wild_10471_Perception_LeaveByRoll = {
	behavior = {
		useForRoute = false,
		agenttype = "CombatAgent",
		name = "ParmonBehaviorTree/SubTree/_Wild/10471_Pomegg/PBT_Wild_10471_Perception_LeaveByRoll",
		version = 47,
		properties = {},
		pars = {
			{
				type = "int",
				value = "0",
				const = 0,
				name = "tSensorTgtId"
			},
			{
				type = "float",
				value = "0",
				const = 0,
				name = "tLeaveTimeOut"
			},
			{
				type = "SpeedRateType",
				value = "Fast",
				name = "tSpeedRateType",
				const = BaseEnum.SpeedRateType.Fast
			},
			{
				type = "float",
				value = "0",
				const = 0,
				name = "tSpeed"
			}
		},
		attachments = {},
		node = {
			id = "106",
			class = "Sequence",
			properties = {},
			attachments = {
				{
					id = "5",
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
										const = "TE_Par_Leave"
									}
								}
							}
						},
						{
							Phase = "Both"
						}
					}
				},
				{
					id = "112",
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
										const = "TE_Wild_10471_MimicryLeave"
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
						id = "107",
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
						id = "79",
						class = "Sequence",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									id = "74",
									class = "IfElse",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "72",
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
																	field = "selfId"
																},
																{
																	const = "TA_CatchFailure_3"
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
												id = "73",
												class = "Assignment",
												properties = {
													{
														CastRight = "false"
													},
													{
														Opl = {
															field = "tLeaveTimeOut"
														}
													},
													{
														Opr = {
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
												id = "75",
												class = "IfElse",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "76",
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
																				field = "selfId"
																			},
																			{
																				const = "TA_CatchFailure_1"
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
															id = "77",
															class = "Assignment",
															properties = {
																{
																	CastRight = "false"
																},
																{
																	Opl = {
																		field = "tLeaveTimeOut"
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
															id = "78",
															class = "Assignment",
															properties = {
																{
																	CastRight = "false"
																},
																{
																	Opl = {
																		field = "tLeaveTimeOut"
																	}
																},
																{
																	Opr = {
																		const = 10
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
									id = "82",
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
									id = "80",
									class = "Action",
									properties = {
										{
											Method = {
												func = "addAITag",
												params = {
													{
														field = "selfId"
													},
													{
														const = "TA_Percept_Leave"
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
									id = "102",
									class = "Selector",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "103",
												class = "Sequence",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "101",
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
													},
													{
														node = {
															id = "104",
															class = "Action",
															properties = {
																{
																	Method = {
																		func = "switchToState",
																		params = {
																			{
																				const = "AIRING"
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
													}
												}
											}
										},
										{
											node = {
												id = "105",
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
									id = "122",
									class = "Selector",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "123",
												class = "Sequence",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "121",
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
													},
													{
														node = {
															id = "124",
															class = "Action",
															properties = {
																{
																	Method = {
																		func = "switchToState",
																		params = {
																			{
																				const = "MIMICRYOUT"
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
													}
												}
											}
										},
										{
											node = {
												id = "125",
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
									id = "83",
									class = "IfElse",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "100",
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
												id = "81",
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
												id = "84",
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
						id = "93",
						class = "IfElse",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									id = "89",
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
									id = "90",
									class = "Sequence",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "86",
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
												id = "91",
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
														id = "77",
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
												id = "87",
												class = "Selector",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "85",
															class = "Action",
															properties = {
																{
																	Method = {
																		func = "leaveTarget",
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
																			},
																			{
																				field = "tLeaveTimeOut"
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
																	id = "76",
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
															id = "88",
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
												id = "92",
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
									id = "94",
									class = "Sequence",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "95",
												class = "Selector",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "109",
															class = "Sequence",
															properties = {},
															attachments = {
																{
																	id = "119",
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
																				func = "setAttenuationMultiple",
																				params = {
																					{},
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
																},
																{
																	id = "120",
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
																				func = "setFullBodyIdle",
																				params = {
																					{
																						const = ""
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
																		id = "114",
																		class = "Action",
																		properties = {
																			{
																				Method = {
																					func = "setFullBodyIdle",
																					params = {
																						{
																							const = "SprintLoop"
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
																		id = "96",
																		class = "Action",
																		properties = {
																			{
																				Method = {
																					func = "leaveTarget",
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
																						},
																						{
																							field = "tLeaveTimeOut"
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
																		attachments = {},
																		children = {}
																	}
																},
																{
																	node = {
																		id = "97",
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
										},
										{
											node = {
												id = "98",
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

return PBT_Wild_10471_Perception_LeaveByRoll
