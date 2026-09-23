-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_Pet_Afk_Common.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Pet_Afk_Common = {
	behavior = {
		useForRoute = false,
		name = "ParmonBehaviorTree/SubTree/PBT_Pet_Afk_Common",
		version = 30,
		agenttype = "PetAgent",
		properties = {},
		pars = {
			{
				const = 0,
				name = "tStandYawAngle",
				value = "0",
				type = "float"
			},
			{
				const = 0,
				name = "tWaitTime",
				value = "0",
				type = "float"
			},
			{
				const = 0,
				name = "tRangeNum",
				value = "0",
				type = "float"
			}
		},
		attachments = {},
		node = {
			class = "Sequence",
			id = "111",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						class = "Action",
						id = "112",
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
				},
				{
					node = {
						class = "Parallel",
						id = "113",
						properties = {
							{
								ChildFinishPolicy = "CHILDFINISH_ONCE"
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
									class = "Sequence",
									id = "115",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												class = "Action",
												id = "114",
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
										},
										{
											node = {
												class = "Action",
												id = "116",
												properties = {
													{
														Method = {
															func = "stopEffectOnTarget",
															params = {
																{
																	const = "Eff_Common_Behav_Love"
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
										}
									}
								}
							},
							{
								node = {
									class = "Sequence",
									id = "119",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												class = "Action",
												id = "120",
												properties = {
													{
														Method = {
															func = "setAFKScreen",
															params = {
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
												class = "Action",
												id = "123",
												properties = {
													{
														Method = {
															func = "playSleAnimationMultiTime",
															params = {
																{
																	const = "EnvBehav_ScreenShowStart"
																},
																{
																	const = "EnvBehav_ScreenShowLoop"
																},
																{
																	const = "EnvBehav_ScreenShowEnd"
																},
																{
																	field = "afkAnimLoopCount"
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
												class = "Action",
												id = "121",
												properties = {
													{
														Method = {
															func = "setAFKScreen",
															params = {
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
												class = "IfElse",
												id = "134",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															class = "Condition",
															id = "135",
															properties = {
																{
																	Operator = "Equal"
																},
																{
																	Opl = {
																		func = "checkEntityHasTag",
																		params = {
																			{
																				field = "selfId"
																			},
																			{
																				const = "TE_Par_AFK_NeedNoEffect"
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
															class = "Action",
															id = "137",
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
																				const = "T_AniEvent_NoEffect"
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
															id = "136",
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
				},
				{
					node = {
						class = "Assignment",
						id = "125",
						properties = {
							{
								CastRight = "false"
							},
							{
								Opl = {
									field = "tWaitTime"
								}
							},
							{
								Opr = {
									func = "getRandomFloat",
									params = {
										{
											const = 1
										},
										{
											const = 3
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
						class = "Action",
						id = "122",
						properties = {
							{
								Method = {
									func = "waitTime",
									params = {
										{
											field = "tWaitTime"
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
						id = "124",
						properties = {
							{
								Method = {
									func = "playAfkAnimation"
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

return PBT_Pet_Afk_Common
