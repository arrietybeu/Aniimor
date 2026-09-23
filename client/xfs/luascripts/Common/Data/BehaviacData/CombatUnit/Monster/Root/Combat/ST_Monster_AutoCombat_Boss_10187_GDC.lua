-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\CombatUnit\\Monster\\Root\\Combat\\ST_Monster_AutoCombat_Boss_10187_GDC.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local ST_Monster_AutoCombat_Boss_10187_GDC = {
	behavior = {
		name = "CombatUnit/Monster/Root/Combat/ST_Monster_AutoCombat_Boss_10187_GDC",
		version = 26,
		useForRoute = false,
		agenttype = "PuppetAgent",
		properties = {},
		pars = {
			{
				const = 0,
				type = "float",
				name = "disToTgtForSkillMon",
				value = "0"
			},
			{
				const = 0,
				type = "float",
				name = "goBackDist",
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
									id = "134",
									class = "Sequence",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "138",
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
												id = "135",
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
												id = "136",
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
												id = "137",
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
												id = "139",
												class = "IfElse",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "140",
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
															id = "141",
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
															id = "142",
															class = "Selector",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		id = "143",
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
																					id = "145",
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
																								id = "144",
																								class = "Sequence",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											id = "153",
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
																											id = "290",
																											class = "Selector",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "294",
																														class = "Sequence",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	id = "295",
																																	class = "Condition",
																																	properties = {
																																		{
																																			Operator = "LessEqual"
																																		},
																																		{
																																			Opl = {
																																				func = "getHpPercent",
																																				params = {
																																					{
																																						field = "selfId"
																																					}
																																				}
																																			}
																																		},
																																		{
																																			Opr = {
																																				const = 0.5
																																			}
																																		}
																																	},
																																	attachments = {},
																																	children = {}
																																}
																															},
																															{
																																node = {
																																	id = "296",
																																	class = "Condition",
																																	properties = {
																																		{
																																			Operator = "Equal"
																																		},
																																		{
																																			Opl = {
																																				func = "checkCanUseSkill",
																																				params = {
																																					{
																																						const = 0
																																					},
																																					{
																																						const = 11870512
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
																																	id = "349",
																																	class = "Condition",
																																	properties = {
																																		{
																																			Operator = "NotEqual"
																																		},
																																		{
																																			Opl = {
																																				func = "checkIsInBreakRecover",
																																				params = {
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
																																	id = "303",
																																	class = "Selector",
																																	properties = {},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				id = "304",
																																				class = "Condition",
																																				properties = {
																																					{
																																						Operator = "LessEqual"
																																					},
																																					{
																																						Opl = {
																																							func = "getTimerValue",
																																							params = {
																																								{
																																									const = "shieldSys"
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
																																				id = "302",
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
																																									const = "shieldSys"
																																								}
																																							}
																																						}
																																					},
																																					{
																																						Opr = {
																																							const = 40
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
																																	id = "300",
																																	class = "Action",
																																	properties = {
																																		{
																																			Method = {
																																				func = "startTimer",
																																				params = {
																																					{
																																						const = "shieldSys"
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
																																	id = "299",
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
																																						const = 11870512
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
																																			ResultResumeOption = "BT_NextNode"
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
																														id = "154",
																														class = "Sequence",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	id = "155",
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
																																	id = "156",
																																	class = "Sequence",
																																	properties = {},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				id = "157",
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
																																				id = "158",
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
																																				id = "159",
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
																																	id = "160",
																																	class = "Selector",
																																	properties = {},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				id = "161",
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
																																				id = "162",
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
																																	id = "164",
																																	class = "Selector",
																																	properties = {},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				id = "165",
																																				class = "Sequence",
																																				properties = {},
																																				attachments = {},
																																				children = {
																																					{
																																						node = {
																																							id = "210",
																																							class = "Selector",
																																							properties = {},
																																							attachments = {},
																																							children = {
																																								{
																																									node = {
																																										id = "209",
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
																																										id = "211",
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
																																							id = "148",
																																							class = "Selector",
																																							properties = {},
																																							attachments = {},
																																							children = {
																																								{
																																									node = {
																																										id = "166",
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
																																										id = "167",
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
																																							id = "283",
																																							class = "Selector",
																																							properties = {},
																																							attachments = {},
																																							children = {
																																								{
																																									node = {
																																										id = "284",
																																										class = "Sequence",
																																										properties = {},
																																										attachments = {},
																																										children = {
																																											{
																																												node = {
																																													id = "287",
																																													class = "Selector",
																																													properties = {},
																																													attachments = {},
																																													children = {
																																														{
																																															node = {
																																																id = "288",
																																																class = "Condition",
																																																properties = {
																																																	{
																																																		Operator = "LessEqual"
																																																	},
																																																	{
																																																		Opl = {
																																																			func = "getTimerValue",
																																																			params = {
																																																				{
																																																					const = "windAttack"
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
																																																id = "289",
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
																																																					const = "windAttack"
																																																				}
																																																			}
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
																																														}
																																													}
																																												}
																																											},
																																											{
																																												node = {
																																													id = "282",
																																													class = "Condition",
																																													properties = {
																																														{
																																															Operator = "Equal"
																																														},
																																														{
																																															Opl = {
																																																func = "checkCanUseSkill",
																																																params = {
																																																	{
																																																		const = 0
																																																	},
																																																	{
																																																		const = 11870350
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
																																													id = "149",
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
																																																const = 11870350
																																															}
																																														}
																																													},
																																													attachments = {},
																																													children = {}
																																												}
																																											},
																																											{
																																												node = {
																																													id = "286",
																																													class = "Action",
																																													properties = {
																																														{
																																															Method = {
																																																func = "startTimer",
																																																params = {
																																																	{
																																																		const = "windAttack"
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
																																										id = "328",
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
																																													id = "334",
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
																																																id = "337",
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
																																																			const = 11870330
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
																																													id = "331",
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
																																																id = "336",
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
																																																			const = 11870340
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
																																													id = "329",
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
																																																id = "335",
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
																																																			const = 11870350
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
																																							id = "150",
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
																																							id = "213",
																																							class = "Selector",
																																							properties = {},
																																							attachments = {},
																																							children = {
																																								{
																																									node = {
																																										id = "214",
																																										class = "Sequence",
																																										properties = {},
																																										attachments = {},
																																										children = {
																																											{
																																												node = {
																																													id = "343",
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
																																													id = "216",
																																													class = "Selector",
																																													properties = {},
																																													attachments = {},
																																													children = {
																																														{
																																															node = {
																																																id = "217",
																																																class = "Sequence",
																																																properties = {},
																																																attachments = {},
																																																children = {
																																																	{
																																																		node = {
																																																			id = "219",
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
																																																			id = "220",
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
																																																id = "218",
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
																																										id = "215",
																																										class = "Sequence",
																																										properties = {},
																																										attachments = {},
																																										children = {
																																											{
																																												node = {
																																													id = "221",
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
																																													id = "223",
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
																																																		const = true
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
																																													id = "224",
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
																																							id = "152",
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
																																				id = "163",
																																				class = "Sequence",
																																				properties = {},
																																				attachments = {},
																																				children = {
																																					{
																																						node = {
																																							id = "168",
																																							class = "Selector",
																																							properties = {},
																																							attachments = {},
																																							children = {
																																								{
																																									node = {
																																										id = "172",
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
																																										id = "169",
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
																																							id = "233",
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
																																												const = true
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
																																							id = "305",
																																							class = "IfElse",
																																							properties = {},
																																							attachments = {},
																																							children = {
																																								{
																																									node = {
																																										id = "306",
																																										class = "Condition",
																																										properties = {
																																											{
																																												Operator = "GreaterEqual"
																																											},
																																											{
																																												Opl = {
																																													func = "getHpPercent",
																																													params = {
																																														{
																																															field = "selfId"
																																														}
																																													}
																																												}
																																											},
																																											{
																																												Opr = {
																																													const = 0.5
																																												}
																																											}
																																										},
																																										attachments = {},
																																										children = {}
																																									}
																																								},
																																								{
																																									node = {
																																										id = "170",
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
																																															const = 3
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
																																										id = "307",
																																										class = "Sequence",
																																										properties = {},
																																										attachments = {},
																																										children = {
																																											{
																																												node = {
																																													id = "308",
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
																																																		const = 3
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
																																													id = "309",
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
																																																		const = 11870360
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
																																							id = "171",
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
																																	id = "173",
																																	class = "IfElse",
																																	properties = {},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				id = "181",
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
																																				id = "174",
																																				class = "Sequence",
																																				properties = {},
																																				attachments = {},
																																				children = {
																																					{
																																						node = {
																																							id = "176",
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
																																							id = "177",
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
																																				id = "175",
																																				class = "Sequence",
																																				properties = {},
																																				attachments = {},
																																				children = {
																																					{
																																						node = {
																																							id = "178",
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
																																							id = "179",
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
																																	id = "180",
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
																						}
																					}
																				}
																			},
																			{
																				node = {
																					id = "147",
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
																								id = "146",
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
																		id = "182",
																		class = "Sequence",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					id = "183",
																					class = "IfElse",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								id = "184",
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
																								id = "185",
																								class = "Sequence",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											id = "186",
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
																											id = "187",
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
																								id = "188",
																								class = "Sequence",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											id = "189",
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
																														const = 150
																													}
																												}
																											},
																											attachments = {},
																											children = {}
																										}
																									},
																									{
																										node = {
																											id = "190",
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
																					id = "195",
																					class = "Selector",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								id = "194",
																								class = "Sequence",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											id = "198",
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
																											id = "196",
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
																											id = "193",
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
																											id = "347",
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
																											id = "192",
																											class = "Selector",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "191",
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
																												},
																												{
																													node = {
																														id = "200",
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
																																			const = 2
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
																								id = "234",
																								class = "Selector",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											id = "235",
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
																														id = "241",
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
																																	id = "240",
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
																														id = "243",
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
																																	id = "242",
																																	class = "Sequence",
																																	properties = {},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				id = "244",
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
																																				id = "245",
																																				class = "Selector",
																																				properties = {},
																																				attachments = {},
																																				children = {
																																					{
																																						node = {
																																							id = "246",
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
																																							id = "247",
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
																																										const = 10
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
																																				id = "248",
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
																																									const = false
																																								},
																																								{
																																									const = 0.8
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
																																				id = "249",
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
																																				id = "250",
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
																											id = "252",
																											class = "Sequence",
																											properties = {},
																											attachments = {
																												{
																													transition = false,
																													id = "135",
																													precondition = true,
																													class = "Precondition",
																													effector = false,
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
																														id = "253",
																														class = "IfElse",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	id = "254",
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
																																	id = "256",
																																	class = "Sequence",
																																	properties = {},
																																	attachments = {
																																		{
																																			transition = false,
																																			id = "104",
																																			precondition = true,
																																			class = "Precondition",
																																			effector = false,
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
																																				id = "258",
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
																																	id = "339",
																																	class = "Selector",
																																	properties = {},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				id = "251",
																																				class = "Sequence",
																																				properties = {},
																																				attachments = {},
																																				children = {
																																					{
																																						node = {
																																							id = "237",
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
																																							id = "238",
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
																																							id = "346",
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
																																							id = "239",
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
																																		},
																																		{
																																			node = {
																																				id = "340",
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

return ST_Monster_AutoCombat_Boss_10187_GDC
