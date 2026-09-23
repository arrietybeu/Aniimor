-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_Perception_Egg10501.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Perception_Egg10501 = {
	behavior = {
		name = "ParmonBehaviorTree/SubTree/PBT_Perception_Egg10501",
		agenttype = "CombatAgent",
		version = 67,
		useForRoute = false,
		properties = {},
		pars = {
			{
				name = "tSensorTgtId",
				value = "0",
				type = "int",
				const = 0
			},
			{
				name = "tLeaveTimeOut",
				value = "0",
				type = "float",
				const = 0
			},
			{
				name = "tSpeedRateType",
				value = "Mid",
				type = "SpeedRateType",
				const = BaseEnum.SpeedRateType.Mid
			},
			{
				name = "tSpeed",
				value = "3.5",
				type = "float",
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
						id = "87",
						class = "Assignment",
						properties = {
							{
								CastRight = "false"
							},
							{
								Opl = {
									field = "tgt"
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
						id = "86",
						class = "Condition",
						properties = {
							{
								Operator = "NotEqual"
							},
							{
								Opl = {
									field = "tgt"
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
						id = "88",
						class = "Assignment",
						properties = {
							{
								CastRight = "false"
							},
							{
								Opl = {
									field = "distToTgt"
								}
							},
							{
								Opr = {
									func = "getDistByTgt",
									params = {
										{
											field = "tgt"
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
							}
						},
						attachments = {},
						children = {}
					}
				},
				{
					node = {
						id = "101",
						class = "DecoratorLoop",
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
								DoneWithinFrame = "false"
							}
						},
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
												id = "102",
												class = "Assignment",
												properties = {
													{
														CastRight = "false"
													},
													{
														Opl = {
															field = "distToTgt"
														}
													},
													{
														Opr = {
															func = "getDistByTgt",
															params = {
																{
																	field = "tgt"
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
													}
												},
												attachments = {},
												children = {}
											}
										},
										{
											node = {
												id = "148",
												class = "Action",
												properties = {
													{
														Method = {
															func = "addBuff",
															params = {
																{
																	const = 62150101
																},
																{
																	const = -1
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
												id = "150",
												class = "IfElse",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "91",
															class = "Condition",
															properties = {
																{
																	Operator = "Greater"
																},
																{
																	Opl = {
																		field = "distToTgt"
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
															id = "153",
															class = "Selector",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		id = "154",
																		class = "Sequence",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					id = "157",
																					class = "Condition",
																					properties = {
																						{
																							Operator = "Greater"
																						},
																						{
																							Opl = {
																								field = "distToTgt"
																							}
																						},
																						{
																							Opr = {
																								const = 30
																							}
																						}
																					},
																					attachments = {},
																					children = {}
																				}
																			},
																			{
																				node = {
																					id = "156",
																					class = "Action",
																					properties = {
																						{
																							Method = {
																								func = "teleportToTargetSide",
																								params = {
																									{
																										field = "tgt"
																									},
																									{
																										const = 2
																									},
																									{
																										const = 4
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
																		id = "152",
																		class = "Action",
																		properties = {
																			{
																				Method = {
																					func = "moveToTarget",
																					params = {
																						{
																							field = "tgt"
																						},
																						{
																							field = "bestKeepBoxDist"
																						},
																						{
																							const = 99
																						},
																						{
																							const = false
																						},
																						{
																							const = false
																						},
																						{
																							const = true
																						},
																						{
																							const = 8
																						},
																						{
																							const = BaseEnum.MoveUpdateLevel.Slow
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
																}
															}
														}
													},
													{
														node = {
															id = "158",
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
					}
				}
			}
		}
	}
}

return PBT_Perception_Egg10501
