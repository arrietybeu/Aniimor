-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_Vision_Alert_Quicker.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Vision_Alert_Quicker = {
	behavior = {
		agenttype = "CombatAgent",
		version = 17,
		name = "ParmonBehaviorTree/SubTree/PBT_Vision_Alert_Quicker",
		useForRoute = false,
		properties = {},
		pars = {
			{
				name = "tSensorTgtId",
				type = "int",
				value = "0",
				const = 0
			},
			{
				name = "tRandomWaitTime",
				type = "float",
				value = "0",
				const = 0
			},
			{
				name = "tRandomWaitTime2",
				type = "float",
				value = "0",
				const = 0
			}
		},
		attachments = {},
		node = {
			id = "1",
			class = "Sequence",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						id = "2",
						class = "Condition",
						properties = {
							{
								Operator = "NotEqual"
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
						id = "12",
						class = "Assignment",
						properties = {
							{
								CastRight = "false"
							},
							{
								Opl = {
									field = "tRandomWaitTime"
								}
							},
							{
								Opr = {
									func = "getRandomFloat",
									params = {
										{
											const = 0
										},
										{
											const = 0.7
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
						id = "13",
						class = "Action",
						properties = {
							{
								Method = {
									func = "waitTime",
									params = {
										{
											field = "tRandomWaitTime"
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
						id = "3",
						class = "Sequence",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									id = "8",
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
									id = "23",
									class = "DecoratorAlwaysRunning",
									properties = {
										{
											DecorateWhenChildEnds = "false"
										}
									},
									attachments = {
										{
											precondition = true,
											id = "24",
											class = "Precondition",
											transition = false,
											effector = false,
											properties = {
												{
													BinaryOperator = "And"
												},
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
																const = "TA_VisionAlert"
															}
														}
													}
												},
												{
													Opr2 = {
														const = true
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
												id = "25",
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
															id = "22",
															class = "Sequence",
															properties = {},
															attachments = {},
															children = {
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
																							const = "Behav_Alert"
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
																},
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
																					field = "tRandomWaitTime2"
																				}
																			},
																			{
																				Opr = {
																					func = "getRandomFloat",
																					params = {
																						{
																							const = 0.7
																						},
																						{
																							const = 1.2
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
																		id = "19",
																		class = "Action",
																		properties = {
																			{
																				Method = {
																					func = "waitTime",
																					params = {
																						{
																							field = "tRandomWaitTime2"
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

return PBT_Vision_Alert_Quicker
