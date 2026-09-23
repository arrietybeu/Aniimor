-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_Pet_Follow.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Pet_Follow = {
	behavior = {
		version = 28,
		useForRoute = false,
		agenttype = "PetAgent",
		name = "ParmonBehaviorTree/SubTree/PBT_Pet_Follow",
		properties = {},
		pars = {
			{
				const = 0,
				type = "float",
				value = "0",
				name = "tInWaterDepth"
			},
			{
				const = 0,
				type = "float",
				value = "0",
				name = "tCurrentDistToMaster"
			}
		},
		attachments = {},
		node = {
			class = "Sequence",
			id = "1",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						class = "IfElse",
						id = "30",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									class = "Condition",
									id = "34",
									properties = {
										{
											Operator = "Equal"
										},
										{
											Opl = {
												func = "checkStartFollow",
												params = {
													{
														field = "followTarget"
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
									id = "5",
									properties = {
										{
											Method = {
												func = "followEntity",
												params = {
													{
														field = "followTarget"
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
											ResultResumeOption = "BT_ResumeTree"
										}
									},
									attachments = {},
									children = {}
								}
							},
							{
								node = {
									class = "Noop",
									id = "32",
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
						class = "Action",
						id = "20",
						properties = {
							{
								Method = {
									func = "turnToTarget",
									params = {
										{
											field = "followTarget"
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
								ResultOption = "BT_SUCCESS"
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
						class = "Compute",
						id = "48",
						properties = {
							{
								Operator = "Mul"
							},
							{
								Opl = {
									field = "tInWaterDepth"
								}
							},
							{
								Opr1 = {
									func = "getBodyHeight",
									params = {
										{
											field = "selfId"
										}
									}
								}
							},
							{
								Opr2 = {
									const = -0.3
								}
							}
						},
						attachments = {},
						children = {}
					}
				},
				{
					node = {
						class = "IfElse",
						id = "36",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									class = "And",
									id = "58",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												class = "Condition",
												id = "38",
												properties = {
													{
														Operator = "Equal"
													},
													{
														Opl = {
															func = "isOnWater",
															params = {
																{
																	field = "selfId"
																},
																{
																	field = "tInWaterDepth"
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
												class = "Condition",
												id = "57",
												properties = {
													{
														Operator = "Equal"
													},
													{
														Opl = {
															func = "checkHasAbility",
															params = {
																{
																	field = "selfId"
																},
																{
																	const = BaseEnum.AbilityType.Swim
																}
															}
														}
													},
													{
														Opr = {
															const = false
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
									class = "Sequence",
									id = "51",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												class = "Action",
												id = "50",
												properties = {
													{
														Method = {
															func = "calcQualifiedPosByTarget",
															params = {
																{
																	field = "selfId"
																},
																{
																	const = 3
																},
																{
																	const = 8
																},
																{
																	const = BaseEnum.CalcQualifiedPosQueryType.EightCompassDirections
																},
																{
																	const = 4
																},
																{
																	const = 0
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
														ResultOption = "BT_SUCCESS"
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
												id = "49",
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
																	const = 0
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
														ResultOption = "BT_SUCCESS"
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
												id = "55",
												properties = {
													{
														Method = {
															func = "turnToTarget",
															params = {
																{
																	field = "followTarget"
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
														ResultOption = "BT_SUCCESS"
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
												id = "86",
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
																		func = "isOnWater",
																		params = {
																			{
																				field = "selfId"
																			},
																			{
																				field = "tInWaterDepth"
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
															id = "83",
															properties = {
																{
																	Method = {
																		func = "teleportToTargetSide",
																		params = {
																			{
																				field = "followTarget"
																			},
																			{
																				const = 0.5
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
															class = "Noop",
															id = "87",
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
									class = "Noop",
									id = "39",
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
						class = "Action",
						id = "35",
						properties = {
							{
								Method = {
									func = "exitFollow"
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

return PBT_Pet_Follow
