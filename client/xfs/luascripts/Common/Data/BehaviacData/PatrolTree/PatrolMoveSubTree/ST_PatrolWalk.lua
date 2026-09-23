-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\PatrolTree\\PatrolMoveSubTree\\ST_PatrolWalk.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local ST_PatrolWalk = {
	behavior = {
		useForRoute = false,
		name = "PatrolTree/PatrolMoveSubTree/ST_PatrolWalk",
		agenttype = "WxAgent",
		version = 7,
		properties = {},
		pars = {
			{
				type = "vector<float>",
				name = "patrolPos",
				value = "0:",
				const = {}
			},
			{
				type = "float",
				const = 15,
				name = "patrolMaxTime",
				value = "15"
			},
			{
				type = "float",
				const = -1,
				name = "tPatrolSpeed",
				value = "-1"
			},
			{
				type = "PathFindType",
				name = "tPathFindType",
				value = "Auto",
				const = BaseEnum.PathFindType.Auto
			},
			{
				type = "SpeedRateType",
				name = "tBehaviorSpeedRateType",
				value = "Slow",
				const = BaseEnum.SpeedRateType.Slow
			},
			{
				type = "bool",
				const = false,
				name = "tUseAccurateArrive",
				value = "false"
			}
		},
		attachments = {},
		node = {
			id = "16",
			class = "Sequence",
			properties = {},
			attachments = {},
			children = {
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
									id = "33",
									class = "IfElse",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "38",
												class = "Condition",
												properties = {
													{
														Operator = "Equal"
													},
													{
														Opl = {
															func = "checkPosIsOnGround",
															params = {
																{
																	field = "patrolPos"
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
												id = "36",
												class = "Selector",
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
																		func = "checkIsFlying",
																		params = {
																			{
																				const = 0
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
													},
													{
														node = {
															id = "54",
															class = "Sequence",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		id = "53",
																		class = "Action",
																		properties = {
																			{
																				Method = {
																					func = "moveToPos",
																					params = {
																						{
																							field = "patrolPos"
																						},
																						{
																							field = "patrolMaxTime"
																						},
																						{
																							const = true
																						},
																						{
																							const = 0
																						},
																						{
																							field = "tBehaviorSpeedRateType"
																						},
																						{
																							field = "tPatrolSpeed"
																						},
																						{
																							field = "tPathFindType"
																						},
																						{
																							const = false
																						},
																						{
																							field = "tUseAccurateArrive"
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
																		id = "48",
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
																							const = 0
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
												id = "37",
												class = "Selector",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "41",
															class = "Condition",
															properties = {
																{
																	Operator = "Equal"
																},
																{
																	Opl = {
																		func = "checkIsFlying",
																		params = {
																			{
																				const = 0
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
															id = "52",
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
																					func = "switchToState",
																					params = {
																						{
																							const = "FLYING"
																						},
																						{
																							const = 0
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
																		id = "51",
																		class = "Action",
																		properties = {
																			{
																				Method = {
																					func = "moveToPos",
																					params = {
																						{
																							field = "patrolPos"
																						},
																						{
																							field = "patrolMaxTime"
																						},
																						{
																							const = true
																						},
																						{
																							const = 0
																						},
																						{
																							field = "tBehaviorSpeedRateType"
																						},
																						{
																							field = "tPatrolSpeed"
																						},
																						{
																							field = "tPathFindType"
																						},
																						{
																							const = false
																						},
																						{
																							field = "tUseAccurateArrive"
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
									id = "34",
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
						id = "31",
						class = "Selector",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									id = "43",
									class = "Action",
									properties = {
										{
											Method = {
												func = "moveToPos",
												params = {
													{
														field = "patrolPos"
													},
													{
														field = "patrolMaxTime"
													},
													{
														const = true
													},
													{
														const = 0
													},
													{
														field = "tBehaviorSpeedRateType"
													},
													{
														field = "tPatrolSpeed"
													},
													{
														field = "tPathFindType"
													},
													{
														const = false
													},
													{
														field = "tUseAccurateArrive"
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
									id = "50",
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

return ST_PatrolWalk
