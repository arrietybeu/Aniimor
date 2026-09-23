-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\_Wild\\_GrabEggs\\PBT_Wild_GrabEggs_Guard_AlertCheck.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Wild_GrabEggs_Guard_AlertCheck = {
	behavior = {
		useForRoute = false,
		agenttype = "CombatAgent",
		name = "ParmonBehaviorTree/SubTree/_Wild/_GrabEggs/PBT_Wild_GrabEggs_Guard_AlertCheck",
		version = 43,
		properties = {},
		pars = {
			{
				name = "tSensorTgtId",
				type = "int",
				const = 0,
				value = "0"
			},
			{
				name = "tRandomStopDis",
				type = "float",
				const = 0,
				value = "0"
			},
			{
				name = "tRandomWaitTime",
				type = "float",
				const = 0,
				value = "0"
			},
			{
				name = "tSensorTgtPos",
				type = "vector<float>",
				value = "0:",
				const = {}
			}
		},
		attachments = {},
		node = {
			id = "3",
			class = "Sequence",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						id = "5",
						class = "Action",
						properties = {
							{
								Method = {
									func = "showQuestionMark",
									params = {
										{
											const = "Normal"
										},
										{
											const = 1.8
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
						id = "14",
						class = "Selector",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									id = "16",
									class = "Sequence",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "13",
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
												id = "17",
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
									id = "15",
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
						id = "8",
						class = "Sequence",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									id = "9",
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
														const = "LOCOMOTION"
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
									id = "30",
									class = "IfElse",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "32",
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
																	field = "tSensorTgtId"
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
															const = 12
														}
													}
												},
												attachments = {},
												children = {}
											}
										},
										{
											node = {
												id = "31",
												class = "Sequence",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "21",
															class = "Assignment",
															properties = {
																{
																	CastRight = "false"
																},
																{
																	Opl = {
																		field = "tRandomStopDis"
																	}
																},
																{
																	Opr = {
																		func = "getRandomFloat",
																		params = {
																			{
																				const = 8
																			},
																			{
																				const = 10
																			}
																		}
																	}
																}
															},
															attachments = {},
															children = {}
														}
													},
													{
														node = {
															id = "48",
															class = "Action",
															properties = {
																{
																	Method = {
																		func = "moveToPos",
																		params = {
																			{
																				field = "tSensorTgtPos"
																			},
																			{
																				const = 10
																			},
																			{
																				const = true
																			},
																			{
																				field = "tRandomStopDis"
																			},
																			{
																				const = BaseEnum.SpeedRateType.Slow
																			},
																			{
																				const = 2.5
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
												id = "63",
												class = "Action",
												properties = {
													{
														Method = {
															func = "turnToTarget",
															params = {
																{
																	field = "tSensorTgtId"
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
									id = "57",
									class = "Selector",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "59",
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
																		func = "hasAnimState",
																		params = {
																			{
																				const = "Behav_DoubtLoop"
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
															id = "56",
															class = "Action",
															properties = {
																{
																	Method = {
																		func = "playPhaseAction",
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
																				const = 3
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
															attachments = {},
															children = {}
														}
													}
												}
											}
										},
										{
											node = {
												id = "4",
												class = "Action",
												properties = {
													{
														Method = {
															func = "playAction",
															params = {
																{
																	const = "Behav_Doubt"
																},
																{
																	const = 3
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
														ResultResumeOption = "BT_ResumeTree"
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

return PBT_Wild_GrabEggs_Guard_AlertCheck
