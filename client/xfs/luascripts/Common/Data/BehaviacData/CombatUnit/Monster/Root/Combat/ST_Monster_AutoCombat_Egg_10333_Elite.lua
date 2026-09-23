-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\CombatUnit\\Monster\\Root\\Combat\\ST_Monster_AutoCombat_Egg_10333_Elite.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local ST_Monster_AutoCombat_Egg_10333_Elite = {
	behavior = {
		name = "CombatUnit/Monster/Root/Combat/ST_Monster_AutoCombat_Egg_10333_Elite",
		version = 152,
		agenttype = "PuppetAgent",
		useForRoute = false,
		properties = {},
		pars = {
			{
				name = "disToTgtForSkillMon",
				value = "0",
				type = "float",
				const = 0
			},
			{
				name = "goBackDist",
				value = "0",
				type = "float",
				const = 0
			},
			{
				name = "MeleeA1",
				value = "50",
				type = "int",
				const = 50
			},
			{
				name = "MeleeA2",
				value = "50",
				type = "int",
				const = 50
			},
			{
				name = "RangedA1",
				value = "50",
				type = "int",
				const = 50
			},
			{
				name = "RangedA2",
				value = "50",
				type = "int",
				const = 50
			},
			{
				name = "RangedB1",
				value = "0",
				type = "int",
				const = 0
			},
			{
				name = "RangedB2",
				value = "0",
				type = "int",
				const = 0
			},
			{
				name = "MeleeB1",
				value = "50",
				type = "int",
				const = 50
			},
			{
				name = "MeleeB2",
				value = "50",
				type = "int",
				const = 50
			},
			{
				name = "MeleeB3",
				value = "50",
				type = "int",
				const = 50
			},
			{
				name = "RangedC1",
				value = "0",
				type = "int",
				const = 0
			},
			{
				name = "RangedC2",
				value = "20",
				type = "int",
				const = 20
			},
			{
				name = "RangedC3",
				value = "20",
				type = "int",
				const = 20
			},
			{
				name = "Ex1",
				value = "0",
				type = "int",
				const = 0
			},
			{
				name = "Ex2",
				value = "50",
				type = "int",
				const = 50
			},
			{
				name = "Ex3",
				value = "100",
				type = "int",
				const = 100
			},
			{
				name = "hasUsedEx",
				value = "false",
				type = "bool",
				const = false
			},
			{
				name = "wyv",
				value = "0",
				type = "int",
				const = 0
			},
			{
				name = "RangeA3",
				value = "50",
				type = "int",
				const = 50
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
						class = "Assignment",
						id = "281",
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
						class = "Condition",
						id = "280",
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
						class = "Assignment",
						id = "1413",
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
						class = "Sequence",
						id = "1426",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									class = "Action",
									id = "1428",
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
									class = "Action",
									id = "1429",
									properties = {
										{
											Method = {
												func = "castSkill",
												params = {
													{
														field = "tgt"
													},
													{
														const = 13330310
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
									class = "Action",
									id = "1430",
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
						class = "DecoratorLoop",
						id = "3",
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
									class = "IfElse",
									id = "1447",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												class = "Condition",
												id = "1431",
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
												class = "Sequence",
												id = "1451",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															class = "Action",
															id = "1448",
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
															class = "Action",
															id = "1449",
															properties = {
																{
																	Method = {
																		func = "castSkill",
																		params = {
																			{
																				field = "tgt"
																			},
																			{
																				const = 13330310
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
															class = "Action",
															id = "1450",
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
												class = "IfElse",
												id = "1452",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															class = "Condition",
															id = "1454",
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
															class = "Action",
															id = "1456",
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
															class = "Action",
															id = "1436",
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

return ST_Monster_AutoCombat_Egg_10333_Elite
