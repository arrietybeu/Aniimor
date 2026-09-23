-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_Combat_Prepare_Default.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Combat_Prepare_Default = {
	behavior = {
		agenttype = "CombatAgent",
		name = "ParmonBehaviorTree/SubTree/PBT_Combat_Prepare_Default",
		version = 16,
		useForRoute = false,
		properties = {},
		pars = {
			{
				value = "0",
				name = "tTargetActorId",
				type = "int",
				const = 0
			}
		},
		attachments = {},
		node = {
			id = "8",
			class = "Sequence",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						id = "24",
						class = "Action",
						properties = {
							{
								Method = {
									func = "hideQuestionMark"
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
						id = "26",
						class = "Selector",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									id = "28",
									class = "Sequence",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "25",
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
																	const = "SWIMMING"
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
												class = "Action",
												properties = {
													{
														Method = {
															func = "calcQualifiedPosByTarget",
															params = {
																{
																	field = "tgt"
																},
																{
																	const = 0
																},
																{
																	field = "maxAttackDist"
																},
																{
																	const = BaseEnum.CalcQualifiedPosQueryType.EightCompassDirections
																},
																{
																	const = 2
																},
																{
																	const = 0
																},
																{
																	const = true
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
												id = "31",
												class = "Action",
												properties = {
													{
														Method = {
															func = "moveToQualifiedPos",
															params = {
																{
																	field = "selfId"
																},
																{
																	const = 5
																},
																{
																	const = 1
																},
																{
																	const = BaseEnum.SpeedRateType.Mid
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
										}
									}
								}
							},
							{
								node = {
									id = "27",
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
						id = "33",
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
												func = "checkCharacterState",
												params = {
													{
														const = "MIMICRY"
													},
													{}
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
									id = "40",
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
															func = "switchToState",
															params = {
																{
																	const = "MIMICRYOUT"
																},
																{
																	const = 5
																},
																{
																	const = "Hit_L"
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
												id = "41",
												class = "Action",
												properties = {
													{
														Method = {
															func = "sendMessageToTrigger",
															params = {
																{
																	field = "selfId"
																},
																{
																	const = 1016
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
									id = "38",
									class = "IfElse",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "39",
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
																	const = "SWIMMIMICRY"
																},
																{}
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
												id = "37",
												class = "Action",
												properties = {
													{
														Method = {
															func = "switchToState",
															params = {
																{
																	const = "SWIMMIMICRYOUT"
																},
																{
																	const = 5
																},
																{
																	const = "Hit_L"
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
												id = "35",
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
										}
									}
								}
							}
						}
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
									field = "tTargetActorId"
								}
							},
							{
								Opr = {
									func = "getTarget"
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
						class = "IfElse",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									id = "18",
									class = "Condition",
									properties = {
										{
											Operator = "Equal"
										},
										{
											Opl = {
												field = "combatReadyIsTurnToTarget"
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
									id = "11",
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
							},
							{
								node = {
									id = "19",
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
						id = "21",
						class = "IfElse",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									id = "20",
									class = "Condition",
									properties = {
										{
											Operator = "Equal"
										},
										{
											Opl = {
												field = "isCombatPrepareTrigger"
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
									id = "14",
									class = "Action",
									properties = {
										{
											Method = {
												func = "playAction",
												params = {
													{
														const = "Behav_Angry"
													},
													{
														const = -1
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
											ResultResumeOption = "BT_NextNode"
										}
									},
									attachments = {},
									children = {}
								}
							},
							{
								node = {
									id = "22",
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
	}
}

return PBT_Combat_Prepare_Default
