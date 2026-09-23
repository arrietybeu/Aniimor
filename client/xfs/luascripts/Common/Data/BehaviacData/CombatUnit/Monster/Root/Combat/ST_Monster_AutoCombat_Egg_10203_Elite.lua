-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\CombatUnit\\Monster\\Root\\Combat\\ST_Monster_AutoCombat_Egg_10203_Elite.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local ST_Monster_AutoCombat_Egg_10203_Elite = {
	behavior = {
		useForRoute = false,
		version = 153,
		agenttype = "PuppetAgent",
		name = "CombatUnit/Monster/Root/Combat/ST_Monster_AutoCombat_Egg_10203_Elite",
		properties = {},
		pars = {
			{
				name = "disToTgtForSkillMon",
				const = 0,
				type = "float",
				value = "0"
			},
			{
				name = "goBackDist",
				const = 0,
				type = "float",
				value = "0"
			},
			{
				name = "MeleeA1",
				const = 50,
				type = "int",
				value = "50"
			},
			{
				name = "MeleeA2",
				const = 50,
				type = "int",
				value = "50"
			},
			{
				name = "RangedA1",
				const = 50,
				type = "int",
				value = "50"
			},
			{
				name = "RangedA2",
				const = 50,
				type = "int",
				value = "50"
			},
			{
				name = "RangedB1",
				const = 0,
				type = "int",
				value = "0"
			},
			{
				name = "RangedB2",
				const = 0,
				type = "int",
				value = "0"
			},
			{
				name = "MeleeB1",
				const = 50,
				type = "int",
				value = "50"
			},
			{
				name = "MeleeB2",
				const = 50,
				type = "int",
				value = "50"
			},
			{
				name = "MeleeB3",
				const = 50,
				type = "int",
				value = "50"
			},
			{
				name = "RangedC1",
				const = 0,
				type = "int",
				value = "0"
			},
			{
				name = "RangedC2",
				const = 20,
				type = "int",
				value = "20"
			},
			{
				name = "RangedC3",
				const = 20,
				type = "int",
				value = "20"
			},
			{
				name = "Ex1",
				const = 0,
				type = "int",
				value = "0"
			},
			{
				name = "Ex2",
				const = 50,
				type = "int",
				value = "50"
			},
			{
				name = "Ex3",
				const = 100,
				type = "int",
				value = "100"
			},
			{
				name = "hasUsedEx",
				const = false,
				type = "bool",
				value = "false"
			},
			{
				name = "wyv",
				const = 0,
				type = "int",
				value = "0"
			},
			{
				name = "RangeA3",
				const = 50,
				type = "int",
				value = "50"
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
						id = "281",
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
						id = "280",
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
						id = "1413",
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
						id = "1426",
						class = "Sequence",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									id = "1428",
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
														const = 5
													},
													{
														const = 4
													},
													{
														const = true
													},
													{
														const = false
													},
													{
														const = true
													},
													{
														const = 7
													},
													{
														const = BaseEnum.MoveUpdateLevel.Fast
													},
													{
														const = BaseEnum.PathFindType.Auto
													},
													{
														const = BaseEnum.SpeedRateType.Fast
													},
													{
														const = 0
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
									id = "1429",
									class = "Action",
									properties = {
										{
											Method = {
												func = "castSkill",
												params = {
													{
														field = "tgt"
													},
													{
														const = 12030230
													},
													{
														const = false
													},
													{
														const = 0
													},
													{
														const = false
													},
													{
														const = BaseEnum.CastAbilitySourceType.Normal
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
									id = "1430",
									class = "Action",
									properties = {
										{
											Method = {
												func = "startTimer",
												params = {
													{
														const = "Punch"
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
						id = "3",
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
									id = "1447",
									class = "IfElse",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "1431",
												class = "Condition",
												properties = {
													{
														Operator = "GreaterEqual"
													},
													{
														Opl = {
															func = "getTimerValue",
															params = {
																{
																	const = "Punch"
																}
															}
														}
													},
													{
														Opr = {
															const = 3
														}
													}
												},
												attachments = {},
												children = {}
											}
										},
										{
											node = {
												id = "1451",
												class = "Sequence",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "1448",
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
																				const = 3
																			},
																			{
																				const = 4
																			},
																			{
																				const = true
																			},
																			{
																				const = false
																			},
																			{
																				const = true
																			},
																			{
																				const = 7
																			},
																			{
																				const = BaseEnum.MoveUpdateLevel.Fast
																			},
																			{
																				const = BaseEnum.PathFindType.Auto
																			},
																			{
																				const = BaseEnum.SpeedRateType.Fast
																			},
																			{
																				const = 0
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
															id = "1457",
															class = "Sequence",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		id = "1449",
																		class = "Action",
																		properties = {
																			{
																				Method = {
																					func = "castSkill",
																					params = {
																						{
																							field = "tgt"
																						},
																						{
																							const = 12030230
																						},
																						{
																							const = false
																						},
																						{
																							const = 0
																						},
																						{
																							const = false
																						},
																						{
																							const = BaseEnum.CastAbilitySourceType.Normal
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
																		id = "1450",
																		class = "Action",
																		properties = {
																			{
																				Method = {
																					func = "startTimer",
																					params = {
																						{
																							const = "Punch"
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
													}
												}
											}
										},
										{
											node = {
												id = "1452",
												class = "IfElse",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "1454",
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
																		const = 5
																	}
																}
															},
															attachments = {},
															children = {}
														}
													},
													{
														node = {
															id = "1456",
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
																				const = 4
																			},
																			{
																				const = 4
																			},
																			{
																				const = true
																			},
																			{
																				const = false
																			},
																			{
																				const = true
																			},
																			{
																				const = 7
																			},
																			{
																				const = BaseEnum.MoveUpdateLevel.Fast
																			},
																			{
																				const = BaseEnum.PathFindType.Auto
																			},
																			{
																				const = BaseEnum.SpeedRateType.Fast
																			},
																			{
																				const = 0
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
															id = "1436",
															class = "Action",
															properties = {
																{
																	Method = {
																		func = "sideWalk",
																		params = {
																			{
																				field = "tgt"
																			},
																			{
																				const = 1.5
																			},
																			{
																				const = -35
																			},
																			{
																				const = -1
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

return ST_Monster_AutoCombat_Egg_10203_Elite
