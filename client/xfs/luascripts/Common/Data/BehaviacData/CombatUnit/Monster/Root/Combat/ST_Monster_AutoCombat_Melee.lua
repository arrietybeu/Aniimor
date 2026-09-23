-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\CombatUnit\\Monster\\Root\\Combat\\ST_Monster_AutoCombat_Melee.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local ST_Monster_AutoCombat_Melee = {
	behavior = {
		name = "CombatUnit/Monster/Root/Combat/ST_Monster_AutoCombat_Melee",
		useForRoute = false,
		version = 20,
		agenttype = "PuppetAgent",
		properties = {},
		pars = {
			{
				name = "disToTgtForSkillMon",
				type = "float",
				const = 0,
				value = "0"
			},
			{
				name = "goBackDist",
				type = "float",
				const = 0,
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
						id = "2",
						class = "Action",
						properties = {
							{
								Method = {
									func = "startTimer",
									params = {
										{
											const = "enterCombat"
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
									id = "116",
									class = "Sequence",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "117",
												class = "Selector",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "118",
															class = "Sequence",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		id = "120",
																		class = "Condition",
																		properties = {
																			{
																				Operator = "Equal"
																			},
																			{
																				Opl = {
																					func = "checkIsInSneak"
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
																		id = "121",
																		class = "Action",
																		properties = {
																			{
																				Method = {
																					func = "switchToSneakOut",
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
															id = "119",
															class = "True",
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
												id = "4",
												class = "Sequence",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "5",
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
															id = "6",
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
															id = "7",
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
															id = "8",
															class = "Assignment",
															properties = {
																{
																	CastRight = "false"
																},
																{
																	Opl = {
																		field = "distToTgtForSkill"
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
																				const = true
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
															id = "9",
															class = "IfElse",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		id = "10",
																		class = "Condition",
																		properties = {
																			{
																				Operator = "GreaterEqual"
																			},
																			{
																				Opl = {
																					field = "distToTgtForSkill"
																				}
																			},
																			{
																				Opr = {
																					field = "maxKeepBoxDist"
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
																					func = "moveToTarget",
																					params = {
																						{
																							field = "tgt"
																						},
																						{
																							field = "bestKeepBoxDist"
																						},
																						{
																							const = 5
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
																							const = 0
																						},
																						{
																							const = BaseEnum.MoveUpdateLevel.Normal
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
																},
																{
																	node = {
																		id = "12",
																		class = "Selector",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					id = "13",
																					class = "SelectorProbability",
																					properties = {
																						{
																							UntilSuccessOrEnd = false
																						}
																					},
																					attachments = {},
																					children = {
																						{
																							node = {
																								id = "15",
																								class = "DecoratorWeight",
																								properties = {
																									{
																										DecorateWhenChildEnds = "false"
																									},
																									{
																										Weight = {
																											field = "attackWeight"
																										}
																									}
																								},
																								attachments = {},
																								children = {
																									{
																										node = {
																											id = "14",
																											class = "Sequence",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "19",
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
																																			const = "enterCombat"
																																		}
																																	}
																																}
																															},
																															{
																																Opr = {
																																	const = 1
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
																														class = "Sequence",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	id = "21",
																																	class = "Condition",
																																	properties = {
																																		{
																																			Operator = "Equal"
																																		},
																																		{
																																			Opl = {
																																				func = "checkCanCombat"
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
																																	id = "22",
																																	class = "Sequence",
																																	properties = {},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				id = "23",
																																				class = "Assignment",
																																				properties = {
																																					{
																																						CastRight = "false"
																																					},
																																					{
																																						Opl = {
																																							field = "fightCd"
																																						}
																																					},
																																					{
																																						Opr = {
																																							func = "getPropertyCd",
																																							params = {
																																								{
																																									const = "fightCd"
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
																																				id = "24",
																																				class = "Assignment",
																																				properties = {
																																					{
																																						CastRight = "false"
																																					},
																																					{
																																						Opl = {
																																							field = "skillCd"
																																						}
																																					},
																																					{
																																						Opr = {
																																							func = "getPropertyCd",
																																							params = {
																																								{
																																									const = "skillCd"
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
																																				id = "25",
																																				class = "Assignment",
																																				properties = {
																																					{
																																						CastRight = "false"
																																					},
																																					{
																																						Opl = {
																																							field = "atkCd"
																																						}
																																					},
																																					{
																																						Opr = {
																																							func = "getPropertyCd",
																																							params = {
																																								{
																																									const = "atkCd"
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
																																	id = "26",
																																	class = "Selector",
																																	properties = {},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				id = "28",
																																				class = "Condition",
																																				properties = {
																																					{
																																						Operator = "Less"
																																					},
																																					{
																																						Opl = {
																																							func = "getTimerValue",
																																							params = {
																																								{
																																									const = "fightCd01"
																																								}
																																							}
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
																																				id = "29",
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
																																									const = "fightCd01"
																																								}
																																							}
																																						}
																																					},
																																					{
																																						Opr = {
																																							field = "fightCd"
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
																																	id = "31",
																																	class = "Selector",
																																	properties = {},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				id = "32",
																																				class = "Sequence",
																																				properties = {},
																																				attachments = {},
																																				children = {
																																					{
																																						node = {
																																							id = "33",
																																							class = "Selector",
																																							properties = {},
																																							attachments = {},
																																							children = {
																																								{
																																									node = {
																																										id = "37",
																																										class = "Condition",
																																										properties = {
																																											{
																																												Operator = "Less"
																																											},
																																											{
																																												Opl = {
																																													func = "getTimerValue",
																																													params = {
																																														{
																																															const = "skillCd01"
																																														}
																																													}
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
																																										id = "38",
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
																																															const = "skillCd01"
																																														}
																																													}
																																												}
																																											},
																																											{
																																												Opr = {
																																													field = "skillCd"
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
																																							id = "34",
																																							class = "Assignment",
																																							properties = {
																																								{
																																									CastRight = "false"
																																								},
																																								{
																																									Opl = {
																																										field = "skillId"
																																									}
																																								},
																																								{
																																									Opr = {
																																										func = "selectSkillByWeight",
																																										params = {
																																											{
																																												field = "tgt"
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
																																							id = "35",
																																							class = "Condition",
																																							properties = {
																																								{
																																									Operator = "NotEqual"
																																								},
																																								{
																																									Opl = {
																																										field = "skillId"
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
																																							id = "138",
																																							class = "Selector",
																																							properties = {},
																																							attachments = {},
																																							children = {
																																								{
																																									node = {
																																										id = "139",
																																										class = "Sequence",
																																										properties = {},
																																										attachments = {},
																																										children = {
																																											{
																																												node = {
																																													id = "137",
																																													class = "Condition",
																																													properties = {
																																														{
																																															Operator = "LessEqual"
																																														},
																																														{
																																															Opl = {
																																																func = "getMaxSkillDist",
																																																params = {
																																																	{
																																																		field = "skillId"
																																																	}
																																																}
																																															}
																																														},
																																														{
																																															Opr = {
																																																field = "distToTgtForSkill"
																																															}
																																														}
																																													},
																																													attachments = {},
																																													children = {}
																																												}
																																											},
																																											{
																																												node = {
																																													id = "141",
																																													class = "Selector",
																																													properties = {},
																																													attachments = {},
																																													children = {
																																														{
																																															node = {
																																																id = "142",
																																																class = "Sequence",
																																																properties = {},
																																																attachments = {},
																																																children = {
																																																	{
																																																		node = {
																																																			id = "144",
																																																			class = "Condition",
																																																			properties = {
																																																				{
																																																					Operator = "Equal"
																																																				},
																																																				{
																																																					Opl = {
																																																						func = "checkAbilityIsCharge",
																																																						params = {
																																																							{
																																																								field = "skillId"
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
																																																			id = "145",
																																																			class = "Action",
																																																			properties = {
																																																				{
																																																					Method = {
																																																						func = "castChargetSkill",
																																																						params = {
																																																							{
																																																								field = "tgt"
																																																							},
																																																							{
																																																								field = "skillId"
																																																							},
																																																							{
																																																								const = 3
																																																							},
																																																							{
																																																								const = 0
																																																							},
																																																							{
																																																								const = true
																																																							},
																																																							{
																																																								const = true
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
																																																					ResultResumeOption = "BT_ResumeTree"
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
																																																id = "143",
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
																																																					field = "skillId"
																																																				},
																																																				{
																																																					const = false
																																																				},
																																																				{
																																																					const = 0
																																																				},
																																																				{
																																																					const = true
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
																																																		ResultResumeOption = "BT_ResumeTree"
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
																																										id = "140",
																																										class = "Sequence",
																																										properties = {},
																																										attachments = {},
																																										children = {
																																											{
																																												node = {
																																													id = "146",
																																													class = "Assignment",
																																													properties = {
																																														{
																																															CastRight = "false"
																																														},
																																														{
																																															Opl = {
																																																field = "disToTgtForSkillMon"
																																															}
																																														},
																																														{
																																															Opr = {
																																																func = "getSkillStopBoxDist",
																																																params = {
																																																	{
																																																		field = "skillId"
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
																																																func = "moveToTarget",
																																																params = {
																																																	{
																																																		field = "tgt"
																																																	},
																																																	{
																																																		field = "disToTgtForSkillMon"
																																																	},
																																																	{
																																																		const = 5
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
																																																		const = 0
																																																	},
																																																	{
																																																		const = BaseEnum.MoveUpdateLevel.Normal
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
																																											},
																																											{
																																												node = {
																																													id = "149",
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
																																																		field = "skillId"
																																																	},
																																																	{
																																																		const = false
																																																	},
																																																	{
																																																		const = 0
																																																	},
																																																	{
																																																		const = true
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
																																															ResultResumeOption = "BT_ResumeTree"
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
																																							id = "42",
																																							class = "Action",
																																							properties = {
																																								{
																																									Method = {
																																										func = "startTimer",
																																										params = {
																																											{
																																												const = "skillCd01"
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
																																				id = "43",
																																				class = "Sequence",
																																				properties = {},
																																				attachments = {},
																																				children = {
																																					{
																																						node = {
																																							id = "44",
																																							class = "Selector",
																																							properties = {},
																																							attachments = {},
																																							children = {
																																								{
																																									node = {
																																										id = "45",
																																										class = "Condition",
																																										properties = {
																																											{
																																												Operator = "Less"
																																											},
																																											{
																																												Opl = {
																																													func = "getTimerValue",
																																													params = {
																																														{
																																															const = "atkCd01"
																																														}
																																													}
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
																																										id = "46",
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
																																															const = "atkCd01"
																																														}
																																													}
																																												}
																																											},
																																											{
																																												Opr = {
																																													field = "atkCd"
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
																																							id = "172",
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
																																												field = "attackStopBoxDist"
																																											},
																																											{
																																												const = 5
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
																																												const = 0
																																											},
																																											{
																																												const = BaseEnum.MoveUpdateLevel.Once
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
																																					},
																																					{
																																						node = {
																																							id = "47",
																																							class = "Action",
																																							properties = {
																																								{
																																									Method = {
																																										func = "castNormalAtkCombo",
																																										params = {
																																											{
																																												field = "tgt"
																																											},
																																											{
																																												const = 0
																																											},
																																											{
																																												const = true
																																											},
																																											{
																																												const = 2
																																											},
																																											{
																																												const = true
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
																																									ResultResumeOption = "BT_ResumeTree"
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
																																										func = "startTimer",
																																										params = {
																																											{
																																												const = "atkCd01"
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
																																	id = "49",
																																	class = "IfElse",
																																	properties = {},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				id = "50",
																																				class = "Condition",
																																				properties = {
																																					{
																																						Operator = "Equal"
																																					},
																																					{
																																						Opl = {
																																							func = "checkIsBossAI"
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
																																				id = "51",
																																				class = "Sequence",
																																				properties = {},
																																				attachments = {},
																																				children = {
																																					{
																																						node = {
																																							id = "54",
																																							class = "Compute",
																																							properties = {
																																								{
																																									Operator = "Add"
																																								},
																																								{
																																									Opl = {
																																										field = "sideWalkWeight"
																																									}
																																								},
																																								{
																																									Opr1 = {
																																										field = "sideWalkWeight"
																																									}
																																								},
																																								{
																																									Opr2 = {
																																										const = 25
																																									}
																																								}
																																							},
																																							attachments = {},
																																							children = {}
																																						}
																																					},
																																					{
																																						node = {
																																							id = "55",
																																							class = "Assignment",
																																							properties = {
																																								{
																																									CastRight = "false"
																																								},
																																								{
																																									Opl = {
																																										field = "attackWeight"
																																									}
																																								},
																																								{
																																									Opr = {
																																										const = 125
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
																																				id = "52",
																																				class = "Sequence",
																																				properties = {},
																																				attachments = {},
																																				children = {
																																					{
																																						node = {
																																							id = "56",
																																							class = "Compute",
																																							properties = {
																																								{
																																									Operator = "Add"
																																								},
																																								{
																																									Opl = {
																																										field = "sideWalkWeight"
																																									}
																																								},
																																								{
																																									Opr1 = {
																																										field = "sideWalkWeight"
																																									}
																																								},
																																								{
																																									Opr2 = {
																																										const = 25
																																									}
																																								}
																																							},
																																							attachments = {},
																																							children = {}
																																						}
																																					},
																																					{
																																						node = {
																																							id = "57",
																																							class = "Assignment",
																																							properties = {
																																								{
																																									CastRight = "false"
																																								},
																																								{
																																									Opl = {
																																										field = "attackWeight"
																																									}
																																								},
																																								{
																																									Opr = {
																																										const = 125
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
																															},
																															{
																																node = {
																																	id = "58",
																																	class = "Action",
																																	properties = {
																																		{
																																			Method = {
																																				func = "startTimer",
																																				params = {
																																					{
																																						const = "fightCd01"
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
																									}
																								}
																							}
																						},
																						{
																							node = {
																								id = "17",
																								class = "DecoratorWeight",
																								properties = {
																									{
																										DecorateWhenChildEnds = "false"
																									},
																									{
																										Weight = {
																											field = "sideWalkWeight"
																										}
																									}
																								},
																								attachments = {},
																								children = {
																									{
																										node = {
																											id = "16",
																											class = "False",
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
																					id = "59",
																					class = "Sequence",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								id = "62",
																								class = "IfElse",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											id = "63",
																											class = "Condition",
																											properties = {
																												{
																													Operator = "Equal"
																												},
																												{
																													Opl = {
																														func = "checkIsBossAI"
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
																											id = "64",
																											class = "Sequence",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "65",
																														class = "Compute",
																														properties = {
																															{
																																Operator = "Add"
																															},
																															{
																																Opl = {
																																	field = "attackWeight"
																																}
																															},
																															{
																																Opr1 = {
																																	field = "attackWeight"
																																}
																															},
																															{
																																Opr2 = {
																																	const = 200
																																}
																															}
																														},
																														attachments = {},
																														children = {}
																													}
																												},
																												{
																													node = {
																														id = "66",
																														class = "Assignment",
																														properties = {
																															{
																																CastRight = "false"
																															},
																															{
																																Opl = {
																																	field = "sideWalkWeight"
																																}
																															},
																															{
																																Opr = {
																																	const = 50
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
																											id = "67",
																											class = "Sequence",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "68",
																														class = "Compute",
																														properties = {
																															{
																																Operator = "Add"
																															},
																															{
																																Opl = {
																																	field = "attackWeight"
																																}
																															},
																															{
																																Opr1 = {
																																	field = "attackWeight"
																																}
																															},
																															{
																																Opr2 = {
																																	const = 175
																																}
																															}
																														},
																														attachments = {},
																														children = {}
																													}
																												},
																												{
																													node = {
																														id = "69",
																														class = "Assignment",
																														properties = {
																															{
																																CastRight = "false"
																															},
																															{
																																Opl = {
																																	field = "sideWalkWeight"
																																}
																															},
																															{
																																Opr = {
																																	const = 50
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
																						},
																						{
																							node = {
																								id = "70",
																								class = "Selector",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											id = "71",
																											class = "Sequence",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "72",
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
																														id = "73",
																														class = "Condition",
																														properties = {
																															{
																																Operator = "LessEqual"
																															},
																															{
																																Opl = {
																																	field = "distToTgt"
																																}
																															},
																															{
																																Opr = {
																																	field = "minAttackDist"
																																}
																															}
																														},
																														attachments = {},
																														children = {}
																													}
																												},
																												{
																													node = {
																														id = "74",
																														class = "Condition",
																														properties = {
																															{
																																Operator = "Equal"
																															},
																															{
																																Opl = {
																																	func = "isGoBackCd"
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
																														id = "177",
																														class = "Compute",
																														properties = {
																															{
																																Operator = "Sub"
																															},
																															{
																																Opl = {
																																	field = "goBackDist"
																																}
																															},
																															{
																																Opr1 = {
																																	field = "attackStopBoxDist"
																																}
																															},
																															{
																																Opr2 = {
																																	field = "distToTgt"
																																}
																															}
																														},
																														attachments = {},
																														children = {}
																													}
																												},
																												{
																													node = {
																														id = "75",
																														class = "Selector",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	id = "76",
																																	class = "Sequence",
																																	properties = {},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				id = "77",
																																				class = "Action",
																																				properties = {
																																					{
																																						Method = {
																																							func = "jumpBackByLinkAngle",
																																							params = {
																																								{
																																									field = "tgt"
																																								},
																																								{
																																									const = 0
																																								},
																																								{
																																									field = "goBackDist"
																																								},
																																								{
																																									const = BaseEnum.RootMotionSyncPointEnum.AICustomPoint1
																																								},
																																								{
																																									const = false
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
																																	id = "78",
																																	class = "Sequence",
																																	properties = {},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				id = "79",
																																				class = "Action",
																																				properties = {
																																					{
																																						Method = {
																																							func = "runBack",
																																							params = {
																																								{
																																									field = "tgt"
																																								},
																																								{
																																									field = "goBackDist"
																																								},
																																								{
																																									const = 3
																																								},
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
																											id = "81",
																											class = "Selector",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "82",
																														class = "SelectorProbability",
																														properties = {
																															{
																																UntilSuccessOrEnd = false
																															}
																														},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	id = "84",
																																	class = "DecoratorWeight",
																																	properties = {
																																		{
																																			DecorateWhenChildEnds = "false"
																																		},
																																		{
																																			Weight = {
																																				const = 1
																																			}
																																		}
																																	},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				id = "83",
																																				class = "Sequence",
																																				properties = {},
																																				attachments = {
																																					{
																																						transition = false,
																																						id = "135",
																																						class = "Precondition",
																																						effector = false,
																																						precondition = true,
																																						properties = {
																																							{
																																								BinaryOperator = "And"
																																							},
																																							{
																																								Operator = "Less"
																																							},
																																							{
																																								Opl = {
																																									func = "getTimerValue",
																																									params = {
																																										{
																																											const = "fightCd01"
																																										}
																																									}
																																								}
																																							},
																																							{
																																								Opr2 = {
																																									field = "fightCd"
																																								}
																																							},
																																							{
																																								Phase = "Enter"
																																							}
																																						}
																																					}
																																				},
																																				children = {
																																					{
																																						node = {
																																							id = "85",
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
																																							id = "86",
																																							class = "Condition",
																																							properties = {
																																								{
																																									Operator = "LessEqual"
																																								},
																																								{
																																									Opl = {
																																										field = "distToTgt"
																																									}
																																								},
																																								{
																																									Opr = {
																																										field = "minKeepBoxDist"
																																									}
																																								}
																																							},
																																							attachments = {},
																																							children = {}
																																						}
																																					},
																																					{
																																						node = {
																																							id = "178",
																																							class = "Compute",
																																							properties = {
																																								{
																																									Operator = "Sub"
																																								},
																																								{
																																									Opl = {
																																										field = "goBackDist"
																																									}
																																								},
																																								{
																																									Opr1 = {
																																										field = "bestKeepBoxDist"
																																									}
																																								},
																																								{
																																									Opr2 = {
																																										field = "distToTgt"
																																									}
																																								}
																																							},
																																							attachments = {},
																																							children = {}
																																						}
																																					},
																																					{
																																						node = {
																																							id = "87",
																																							class = "Action",
																																							properties = {
																																								{
																																									Method = {
																																										func = "walkBack",
																																										params = {
																																											{
																																												field = "tgt"
																																											},
																																											{
																																												field = "goBackDist"
																																											},
																																											{
																																												const = 1.5
																																											},
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
																																					}
																																				}
																																			}
																																		}
																																	}
																																}
																															},
																															{
																																node = {
																																	id = "89",
																																	class = "DecoratorWeight",
																																	properties = {
																																		{
																																			DecorateWhenChildEnds = "false"
																																		},
																																		{
																																			Weight = {
																																				const = 1
																																			}
																																		}
																																	},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				id = "88",
																																				class = "False",
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
																																	id = "91",
																																	class = "DecoratorWeight",
																																	properties = {
																																		{
																																			DecorateWhenChildEnds = "false"
																																		},
																																		{
																																			Weight = {
																																				const = 1
																																			}
																																		}
																																	},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				id = "90",
																																				class = "Sequence",
																																				properties = {},
																																				attachments = {},
																																				children = {
																																					{
																																						node = {
																																							id = "92",
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
																																												const = "Taught01"
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
																																							id = "93",
																																							class = "Selector",
																																							properties = {},
																																							attachments = {},
																																							children = {
																																								{
																																									node = {
																																										id = "94",
																																										class = "Condition",
																																										properties = {
																																											{
																																												Operator = "Less"
																																											},
																																											{
																																												Opl = {
																																													func = "getTimerValue",
																																													params = {
																																														{
																																															const = "Taught01"
																																														}
																																													}
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
																																										id = "95",
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
																																															const = "Taught01"
																																														}
																																													}
																																												}
																																											},
																																											{
																																												Opr = {
																																													const = 12
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
																																							id = "96",
																																							class = "Action",
																																							properties = {
																																								{
																																									Method = {
																																										func = "turnToTarget",
																																										params = {
																																											{
																																												field = "tgt"
																																											},
																																											{
																																												const = true
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
																																							id = "97",
																																							class = "Action",
																																							properties = {
																																								{
																																									Method = {
																																										func = "playAction",
																																										params = {
																																											{
																																												const = "Taught01"
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
																																									ResultResumeOption = "BT_ResumeSelf"
																																								}
																																							},
																																							attachments = {},
																																							children = {}
																																						}
																																					},
																																					{
																																						node = {
																																							id = "98",
																																							class = "Action",
																																							properties = {
																																								{
																																									Method = {
																																										func = "startTimer",
																																										params = {
																																											{
																																												const = "Taught01"
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
																															}
																														}
																													}
																												},
																												{
																													node = {
																														id = "136",
																														class = "Sequence",
																														properties = {},
																														attachments = {
																															{
																																transition = false,
																																id = "135",
																																class = "Precondition",
																																effector = false,
																																precondition = true,
																																properties = {
																																	{
																																		BinaryOperator = "And"
																																	},
																																	{
																																		Operator = "Less"
																																	},
																																	{
																																		Opl = {
																																			func = "getTimerValue",
																																			params = {
																																				{
																																					const = "fightCd01"
																																				}
																																			}
																																		}
																																	},
																																	{
																																		Opr2 = {
																																			field = "fightCd"
																																		}
																																	},
																																	{
																																		Phase = "Enter"
																																	}
																																}
																															}
																														},
																														children = {
																															{
																																node = {
																																	id = "99",
																																	class = "IfElse",
																																	properties = {},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				id = "100",
																																				class = "Condition",
																																				properties = {
																																					{
																																						Operator = "Equal"
																																					},
																																					{
																																						Opl = {
																																							field = "canWalkLeftOrRight"
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
																																				id = "101",
																																				class = "SelectorProbability",
																																				properties = {
																																					{
																																						UntilSuccessOrEnd = false
																																					}
																																				},
																																				attachments = {},
																																				children = {
																																					{
																																						node = {
																																							id = "103",
																																							class = "DecoratorWeight",
																																							properties = {
																																								{
																																									DecorateWhenChildEnds = "false"
																																								},
																																								{
																																									Weight = {
																																										const = 30
																																									}
																																								}
																																							},
																																							attachments = {},
																																							children = {
																																								{
																																									node = {
																																										id = "102",
																																										class = "Sequence",
																																										properties = {},
																																										attachments = {
																																											{
																																												transition = false,
																																												id = "104",
																																												class = "Precondition",
																																												effector = false,
																																												precondition = true,
																																												properties = {
																																													{
																																														BinaryOperator = "And"
																																													},
																																													{
																																														Operator = "Greater"
																																													},
																																													{
																																														Opl = {
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
																																													},
																																													{
																																														Opr2 = {
																																															field = "minAttackDist"
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
																																													id = "105",
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
																																																		const = 1.2
																																																	},
																																																	{
																																																		const = -35
																																																	},
																																																	{
																																																		const = -1
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
																																								}
																																							}
																																						}
																																					},
																																					{
																																						node = {
																																							id = "108",
																																							class = "DecoratorWeight",
																																							properties = {
																																								{
																																									DecorateWhenChildEnds = "false"
																																								},
																																								{
																																									Weight = {
																																										const = 30
																																									}
																																								}
																																							},
																																							attachments = {},
																																							children = {
																																								{
																																									node = {
																																										id = "107",
																																										class = "Sequence",
																																										properties = {},
																																										attachments = {
																																											{
																																												transition = false,
																																												id = "109",
																																												class = "Precondition",
																																												effector = false,
																																												precondition = true,
																																												properties = {
																																													{
																																														BinaryOperator = "And"
																																													},
																																													{
																																														Operator = "Greater"
																																													},
																																													{
																																														Opl = {
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
																																													},
																																													{
																																														Opr2 = {
																																															field = "minAttackDist"
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
																																													id = "110",
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
																																																		const = 1.2
																																																	},
																																																	{
																																																		const = 35
																																																	},
																																																	{
																																																		const = -1
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
																																								}
																																							}
																																						}
																																					}
																																				}
																																			}
																																		},
																																		{
																																			node = {
																																				id = "112",
																																				class = "Wait",
																																				properties = {
																																					{
																																						Time = {
																																							const = 50
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
							}
						}
					}
				}
			}
		}
	}
}

return ST_Monster_AutoCombat_Melee
