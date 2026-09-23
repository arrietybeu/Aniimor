-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\PatrolTree\\PatrolMoveSubTree\\ST_PatrolSplineWalk.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local ST_PatrolSplineWalk = {
	behavior = {
		name = "PatrolTree/PatrolMoveSubTree/ST_PatrolSplineWalk",
		version = 23,
		useForRoute = false,
		agenttype = "WxAgent",
		properties = {},
		pars = {
			{
				value = "0:",
				name = "patrolPosList",
				type = "vector<float>",
				const = {}
			},
			{
				value = "0",
				const = 0,
				name = "patrolMaxTime",
				type = "float"
			},
			{
				value = "0",
				const = 0,
				name = "tPatrolSpeed",
				type = "float"
			},
			{
				value = "Slow",
				name = "tBehaviorSpeedRateType",
				type = "SpeedRateType",
				const = BaseEnum.SpeedRateType.Slow
			},
			{
				value = "0:",
				name = "patrolStartPos",
				type = "vector<float>",
				const = {}
			},
			{
				value = "0:",
				name = "tNormalList",
				type = "vector<float>",
				const = {}
			},
			{
				value = "false",
				const = false,
				name = "tUseAccurateArrive",
				type = "bool"
			},
			{
				value = "false",
				const = false,
				name = "tIsFirstPoint",
				type = "bool"
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
						class = "IfElse",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									id = "4",
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
									id = "5",
									class = "IfElse",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "7",
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
																	field = "patrolStartPos"
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
												id = "8",
												class = "Selector",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "73",
															class = "Sequence",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		id = "12",
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
																		id = "90",
																		class = "ReferencedBehavior",
																		properties = {
																			{
																				ReferenceBehavior = {
																					const = "ST_PatrolSplineWalk_MoveToPos"
																				}
																			},
																			{
																				subTreeProperties = {
																					{
																						Type = "Self",
																						Name = "patrolPosList",
																						Value = {
																							field = "patrolPosList"
																						}
																					},
																					{
																						Type = "Self",
																						Name = "patrolMaxTime",
																						Value = {
																							field = "patrolMaxTime"
																						}
																					},
																					{
																						Type = "Self",
																						Name = "tPatrolSpeed",
																						Value = {
																							field = "tPatrolSpeed"
																						}
																					},
																					{
																						Type = "Self",
																						Name = "tBehaviorSpeedRateType",
																						Value = {
																							field = "tBehaviorSpeedRateType"
																						}
																					},
																					{
																						Type = "Self",
																						Name = "patrolStartPos",
																						Value = {
																							field = "patrolStartPos"
																						}
																					},
																					{
																						Type = "Self",
																						Name = "tNormalList",
																						Value = {
																							field = "tNormalList"
																						}
																					},
																					{
																						Type = "Self",
																						Name = "tUseAccurateArrive",
																						Value = {
																							field = "tUseAccurateArrive"
																						}
																					},
																					{
																						Type = "Self",
																						Name = "tIsFirstPoint",
																						Value = {
																							field = "tIsFirstPoint"
																						}
																					}
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
															id = "25",
															class = "Sequence",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		id = "89",
																		class = "ReferencedBehavior",
																		properties = {
																			{
																				ReferenceBehavior = {
																					const = "ST_PatrolSplineWalk_MoveToPos"
																				}
																			},
																			{
																				subTreeProperties = {
																					{
																						Type = "Self",
																						Name = "patrolPosList",
																						Value = {
																							field = "patrolPosList"
																						}
																					},
																					{
																						Type = "Self",
																						Name = "patrolMaxTime",
																						Value = {
																							field = "patrolMaxTime"
																						}
																					},
																					{
																						Type = "Self",
																						Name = "tPatrolSpeed",
																						Value = {
																							field = "tPatrolSpeed"
																						}
																					},
																					{
																						Type = "Self",
																						Name = "tBehaviorSpeedRateType",
																						Value = {
																							field = "tBehaviorSpeedRateType"
																						}
																					},
																					{
																						Type = "Self",
																						Name = "patrolStartPos",
																						Value = {
																							field = "patrolStartPos"
																						}
																					},
																					{
																						Type = "Self",
																						Name = "tNormalList",
																						Value = {
																							field = "tNormalList"
																						}
																					},
																					{
																						Type = "Self",
																						Name = "tUseAccurateArrive",
																						Value = {
																							field = "tUseAccurateArrive"
																						}
																					},
																					{
																						Type = "Self",
																						Name = "tIsFirstPoint",
																						Value = {
																							field = "tIsFirstPoint"
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
																		id = "23",
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
												id = "9",
												class = "Selector",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "75",
															class = "Sequence",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		id = "14",
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
																		id = "88",
																		class = "ReferencedBehavior",
																		properties = {
																			{
																				ReferenceBehavior = {
																					const = "ST_PatrolSplineWalk_MoveToPos"
																				}
																			},
																			{
																				subTreeProperties = {
																					{
																						Type = "Self",
																						Name = "patrolPosList",
																						Value = {
																							field = "patrolPosList"
																						}
																					},
																					{
																						Type = "Self",
																						Name = "patrolMaxTime",
																						Value = {
																							field = "patrolMaxTime"
																						}
																					},
																					{
																						Type = "Self",
																						Name = "tPatrolSpeed",
																						Value = {
																							field = "tPatrolSpeed"
																						}
																					},
																					{
																						Type = "Self",
																						Name = "tBehaviorSpeedRateType",
																						Value = {
																							field = "tBehaviorSpeedRateType"
																						}
																					},
																					{
																						Type = "Self",
																						Name = "patrolStartPos",
																						Value = {
																							field = "patrolStartPos"
																						}
																					},
																					{
																						Type = "Self",
																						Name = "tNormalList",
																						Value = {
																							field = "tNormalList"
																						}
																					},
																					{
																						Type = "Self",
																						Name = "tUseAccurateArrive",
																						Value = {
																							field = "tUseAccurateArrive"
																						}
																					},
																					{
																						Type = "Self",
																						Name = "tIsFirstPoint",
																						Value = {
																							field = "tIsFirstPoint"
																						}
																					}
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
															id = "60",
															class = "Sequence",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		id = "26",
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
																		id = "84",
																		class = "ReferencedBehavior",
																		properties = {
																			{
																				ReferenceBehavior = {
																					const = "ST_PatrolSplineWalk_MoveToPos"
																				}
																			},
																			{
																				subTreeProperties = {
																					{
																						Type = "Self",
																						Name = "patrolPosList",
																						Value = {
																							field = "patrolPosList"
																						}
																					},
																					{
																						Type = "Self",
																						Name = "patrolMaxTime",
																						Value = {
																							field = "patrolMaxTime"
																						}
																					},
																					{
																						Type = "Self",
																						Name = "tPatrolSpeed",
																						Value = {
																							field = "tPatrolSpeed"
																						}
																					},
																					{
																						Type = "Self",
																						Name = "tBehaviorSpeedRateType",
																						Value = {
																							field = "tBehaviorSpeedRateType"
																						}
																					},
																					{
																						Type = "Self",
																						Name = "patrolStartPos",
																						Value = {
																							field = "patrolStartPos"
																						}
																					},
																					{
																						Type = "Self",
																						Name = "tNormalList",
																						Value = {
																							field = "tNormalList"
																						}
																					},
																					{
																						Type = "Self",
																						Name = "tUseAccurateArrive",
																						Value = {
																							field = "tUseAccurateArrive"
																						}
																					},
																					{
																						Type = "Self",
																						Name = "tIsFirstPoint",
																						Value = {
																							field = "tIsFirstPoint"
																						}
																					}
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
										}
									}
								}
							},
							{
								node = {
									id = "91",
									class = "ReferencedBehavior",
									properties = {
										{
											ReferenceBehavior = {
												const = "ST_PatrolSplineWalk_MoveToPos"
											}
										},
										{
											subTreeProperties = {
												{
													Type = "Self",
													Name = "patrolPosList",
													Value = {
														field = "patrolPosList"
													}
												},
												{
													Type = "Self",
													Name = "patrolMaxTime",
													Value = {
														field = "patrolMaxTime"
													}
												},
												{
													Type = "Self",
													Name = "tPatrolSpeed",
													Value = {
														field = "tPatrolSpeed"
													}
												},
												{
													Type = "Self",
													Name = "tBehaviorSpeedRateType",
													Value = {
														field = "tBehaviorSpeedRateType"
													}
												},
												{
													Type = "Self",
													Name = "patrolStartPos",
													Value = {
														field = "patrolStartPos"
													}
												},
												{
													Type = "Self",
													Name = "tNormalList",
													Value = {
														field = "tNormalList"
													}
												},
												{
													Type = "Self",
													Name = "tUseAccurateArrive",
													Value = {
														field = "tUseAccurateArrive"
													}
												},
												{
													Type = "Self",
													Name = "tIsFirstPoint",
													Value = {
														field = "tIsFirstPoint"
													}
												}
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
	}
}

return ST_PatrolSplineWalk
