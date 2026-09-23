-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_Pet_Afk_Prepare.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Pet_Afk_Prepare = {
	behavior = {
		name = "ParmonBehaviorTree/SubTree/PBT_Pet_Afk_Prepare",
		version = 50,
		useForRoute = false,
		agenttype = "PetAgent",
		properties = {},
		pars = {
			{
				name = "tStandYawAngle",
				const = 0,
				type = "float",
				value = "0"
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
						id = "22",
						class = "Action",
						properties = {
							{
								Method = {
									func = "setAfkCamera",
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
								ResultResumeOption = "BT_None"
							}
						},
						attachments = {},
						children = {}
					}
				},
				{
					node = {
						id = "39",
						class = "IfElse",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									id = "40",
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
									id = "45",
									class = "IfElse",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "44",
												class = "Condition",
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
												id = "48",
												class = "Sequence",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "47",
															class = "Action",
															properties = {
																{
																	Method = {
																		func = "playEffectOnTarget",
																		params = {
																			{
																				const = "Eff_Common_Behav_Doubt"
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
															id = "46",
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
													}
												}
											}
										},
										{
											node = {
												id = "41",
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
																		func = "playEffectOnTarget",
																		params = {
																			{
																				const = "Eff_Common_Behav_Doubt"
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
															id = "18",
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
							},
							{
								node = {
									id = "28",
									class = "Action",
									properties = {
										{
											Method = {
												func = "playSleAnimationOnce",
												params = {
													{
														const = "Behav_AlertStart"
													},
													{
														const = "Behav_AlertLoop"
													},
													{
														const = "Behav_AlertEnd"
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
						id = "6",
						class = "Action",
						properties = {
							{
								Method = {
									func = "stopEffectOnTarget",
									params = {
										{
											const = "Eff_Common_Behav_Doubt"
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
						id = "43",
						class = "Action",
						properties = {
							{
								Method = {
									func = "playAction",
									params = {
										{
											const = "Idle"
										},
										{
											const = 1
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
				},
				{
					node = {
						id = "11",
						class = "Action",
						properties = {
							{
								Method = {
									func = "playEffectOnTarget",
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
				},
				{
					node = {
						id = "34",
						class = "IfElse",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									id = "36",
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
														const = "EnvBehav_ScreenShowLoop"
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
									id = "31",
									class = "Action",
									properties = {
										{
											Method = {
												func = "blendToFov",
												params = {
													{
														field = "afkFov"
													},
													{
														const = 1.2
													},
													{
														const = BaseEnum.BlendType.EaseOut
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
									id = "35",
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
						id = "3",
						class = "Compute",
						properties = {
							{
								Operator = "Add"
							},
							{
								Opl = {
									field = "tStandYawAngle"
								}
							},
							{
								Opr1 = {
									func = "getCameraYawAngle"
								}
							},
							{
								Opr2 = {
									const = 180
								}
							}
						},
						attachments = {},
						children = {}
					}
				},
				{
					node = {
						id = "20",
						class = "Parallel",
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
								SuccessPolicy = "SUCCEED_ON_ONE"
							}
						},
						attachments = {},
						children = {
							{
								node = {
									id = "2",
									class = "Action",
									properties = {
										{
											Method = {
												func = "turnToYaw",
												params = {
													{
														field = "tStandYawAngle"
													},
													{
														const = false
													},
													{
														const = 5
													},
													{
														const = false
													},
													{
														const = 1
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
									id = "30",
									class = "Action",
									properties = {
										{
											Method = {
												func = "playAction",
												params = {
													{
														const = "Walk"
													},
													{
														const = 0.5
													},
													{
														const = ""
													},
													{
														const = true
													},
													{
														const = false
													},
													{
														const = 0.5
													},
													{
														const = BaseEnum.AIAnimationRootMotionType.None
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

return PBT_Pet_Afk_Prepare
