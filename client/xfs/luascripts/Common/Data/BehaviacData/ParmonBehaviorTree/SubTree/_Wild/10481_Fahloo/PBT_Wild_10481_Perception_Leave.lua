-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\_Wild\\10481_Fahloo\\PBT_Wild_10481_Perception_Leave.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Wild_10481_Perception_Leave = {
	behavior = {
		version = 60,
		name = "ParmonBehaviorTree/SubTree/_Wild/10481_Fahloo/PBT_Wild_10481_Perception_Leave",
		useForRoute = false,
		agenttype = "CombatAgent",
		properties = {},
		pars = {
			{
				name = "tSensorTgtId",
				type = "int",
				const = 0,
				value = "0"
			}
		},
		attachments = {},
		node = {
			class = "Sequence",
			id = "39",
			properties = {},
			attachments = {
				{
					transition = false,
					id = "5",
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
				}
			},
			children = {
				{
					node = {
						class = "Action",
						id = "38",
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
						class = "Sequence",
						id = "67",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									class = "Action",
									id = "71",
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
									class = "IfElse",
									id = "68",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												class = "Condition",
												id = "69",
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
												class = "Assignment",
												id = "66",
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
												class = "True",
												id = "70",
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
						class = "Sequence",
						id = "21",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									class = "Action",
									id = "17",
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
									class = "Action",
									id = "79",
									properties = {
										{
											Method = {
												func = "showEmojiBubble",
												params = {
													{
														const = "Surprise"
													},
													{
														const = 4
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
									class = "Action",
									id = "80",
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
							},
							{
								node = {
									class = "Action",
									id = "40",
									properties = {
										{
											Method = {
												func = "switchToFly",
												params = {
													{
														const = 0
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
							},
							{
								node = {
									class = "Action",
									id = "43",
									properties = {
										{
											Method = {
												func = "addBuff",
												params = {
													{
														const = 11146
													},
													{
														const = 15
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
									id = "46",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												class = "Action",
												id = "65",
												properties = {
													{
														Method = {
															func = "flyToTarget",
															params = {
																{
																	field = "selfId"
																},
																{
																	const = 0
																},
																{
																	const = 20
																},
																{
																	const = 10
																},
																{
																	const = true
																},
																{
																	const = 15
																},
																{
																	const = false
																},
																{
																	const = true
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
										},
										{
											node = {
												class = "IfElse",
												id = "84",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															class = "Condition",
															id = "85",
															properties = {
																{
																	Operator = "Equal"
																},
																{
																	Opl = {
																		func = "checkTargetHasBuffById",
																		params = {
																			{
																				field = "selfId"
																			},
																			{
																				const = 11146
																			},
																			{
																				const = 1
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
															class = "Sequence",
															id = "59",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		class = "Action",
																		id = "61",
																		properties = {
																			{
																				Method = {
																					func = "playEffectOnTarget",
																					params = {
																						{
																							const = "Eff_Parmon_LevelAppear_Normal"
																						},
																						{
																							field = "selfId"
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
																		class = "Action",
																		id = "47",
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
															class = "True",
															id = "86",
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
									class = "IfElse",
									id = "87",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												class = "Condition",
												id = "91",
												properties = {
													{
														Operator = "Equal"
													},
													{
														Opl = {
															func = "checkTargetHasBuffById",
															params = {
																{
																	field = "selfId"
																},
																{
																	const = 11146
																},
																{
																	const = 1
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
												class = "Sequence",
												id = "90",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															class = "Action",
															id = "89",
															properties = {
																{
																	Method = {
																		func = "playEffectOnTarget",
																		params = {
																			{
																				const = "Eff_Parmon_LevelAppear_Normal"
																			},
																			{
																				field = "selfId"
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
															class = "Action",
															id = "88",
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
												class = "True",
												id = "92",
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
				}
			}
		}
	}
}

return PBT_Wild_10481_Perception_Leave
