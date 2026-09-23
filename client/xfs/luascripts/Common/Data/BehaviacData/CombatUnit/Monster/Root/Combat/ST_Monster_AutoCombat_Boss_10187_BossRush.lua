-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\CombatUnit\\Monster\\Root\\Combat\\ST_Monster_AutoCombat_Boss_10187_BossRush.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local ST_Monster_AutoCombat_Boss_10187_BossRush = {
	behavior = {
		useForRoute = false,
		name = "CombatUnit/Monster/Root/Combat/ST_Monster_AutoCombat_Boss_10187_BossRush",
		version = 27,
		agenttype = "PuppetAgent",
		properties = {},
		pars = {
			{
				const = 0,
				type = "float",
				value = "0",
				name = "disToTgtForSkillMon"
			},
			{
				const = 0,
				type = "float",
				value = "0",
				name = "goBackDist"
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
						class = "Action",
						id = "2",
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
									class = "Sequence",
									id = "134",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												class = "Assignment",
												id = "138",
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
												id = "135",
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
												id = "136",
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
												class = "Assignment",
												id = "137",
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
												class = "IfElse",
												id = "354",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															class = "And",
															id = "350",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		class = "Condition",
																		id = "355",
																		properties = {
																			{
																				Operator = "Greater"
																			},
																			{
																				Opl = {
																					func = "getTargetBuffLayerCount",
																					params = {
																						{
																							field = "selfId"
																						},
																						{
																							const = 4000002
																						}
																					}
																				}
																			},
																			{
																				Opr = {
																					const = 2
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
																		id = "353",
																		properties = {
																			{
																				Operator = "Equal"
																			},
																			{
																				Opl = {
																					func = "getEntityCacheValue",
																					params = {
																						{
																							const = "AI_BossStage"
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
																}
															}
														}
													},
													{
														node = {
															class = "Sequence",
															id = "352",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		class = "Action",
																		id = "351",
																		properties = {
																			{
																				Method = {
																					func = "setEntityCacheValue",
																					params = {
																						{
																							const = "AI_BossStage"
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
																				ResultResumeOption = "BT_None"
																			}
																		},
																		attachments = {},
																		children = {}
																	}
																},
																{
																	node = {
																		class = "Action",
																		id = "372",
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
															class = "IfElse",
															id = "370",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		class = "And",
																		id = "363",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					class = "Condition",
																					id = "356",
																					properties = {
																						{
																							Operator = "Greater"
																						},
																						{
																							Opl = {
																								func = "getTargetBuffLayerCount",
																								params = {
																									{
																										field = "selfId"
																									},
																									{
																										const = 4000002
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
																					class = "Condition",
																					id = "364",
																					properties = {
																						{
																							Operator = "Equal"
																						},
																						{
																							Opl = {
																								func = "getEntityCacheValue",
																								params = {
																									{
																										const = "AI_BossStage"
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
																			}
																		}
																	}
																},
																{
																	node = {
																		class = "Sequence",
																		id = "367",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					class = "Action",
																					id = "366",
																					properties = {
																						{
																							Method = {
																								func = "setEntityCacheValue",
																								params = {
																									{
																										const = "AI_BossStage"
																									},
																									{
																										const = 2
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
																					class = "Action",
																					id = "374",
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
																		class = "IfElse",
																		id = "371",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					class = "And",
																					id = "357",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								class = "Condition",
																								id = "365",
																								properties = {
																									{
																										Operator = "Greater"
																									},
																									{
																										Opl = {
																											func = "getTargetBuffLayerCount",
																											params = {
																												{
																													field = "selfId"
																												},
																												{
																													const = 4000002
																												}
																											}
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
																								class = "Condition",
																								id = "361",
																								properties = {
																									{
																										Operator = "Equal"
																									},
																									{
																										Opl = {
																											func = "getEntityCacheValue",
																											params = {
																												{
																													const = "AI_BossStage"
																												}
																											}
																										}
																									},
																									{
																										Opr = {
																											const = 2
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
																					id = "358",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								class = "Action",
																								id = "360",
																								properties = {
																									{
																										Method = {
																											func = "setEntityCacheValue",
																											params = {
																												{
																													const = "AI_BossStage"
																												},
																												{
																													const = 3
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
																								class = "Action",
																								id = "373",
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
																					class = "IfElse",
																					id = "139",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								class = "Condition",
																								id = "140",
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
																								class = "Action",
																								id = "141",
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
																								class = "Selector",
																								id = "142",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											class = "SelectorProbability",
																											id = "143",
																											properties = {
																												{
																													UntilSuccessOrEnd = false
																												}
																											},
																											attachments = {},
																											children = {
																												{
																													node = {
																														class = "DecoratorWeight",
																														id = "145",
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
																																	class = "Sequence",
																																	id = "144",
																																	properties = {},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				class = "Condition",
																																				id = "153",
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
																																				class = "Sequence",
																																				id = "154",
																																				properties = {},
																																				attachments = {},
																																				children = {
																																					{
																																						node = {
																																							class = "Condition",
																																							id = "155",
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
																																							class = "Sequence",
																																							id = "156",
																																							properties = {},
																																							attachments = {},
																																							children = {
																																								{
																																									node = {
																																										class = "Assignment",
																																										id = "157",
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
																																										class = "Assignment",
																																										id = "158",
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
																																										class = "Assignment",
																																										id = "159",
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
																																							class = "Selector",
																																							id = "160",
																																							properties = {},
																																							attachments = {},
																																							children = {
																																								{
																																									node = {
																																										class = "Condition",
																																										id = "161",
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
																																										class = "Condition",
																																										id = "162",
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
																																							class = "Selector",
																																							id = "164",
																																							properties = {},
																																							attachments = {},
																																							children = {
																																								{
																																									node = {
																																										class = "Sequence",
																																										id = "165",
																																										properties = {},
																																										attachments = {},
																																										children = {
																																											{
																																												node = {
																																													class = "Selector",
																																													id = "210",
																																													properties = {},
																																													attachments = {},
																																													children = {
																																														{
																																															node = {
																																																class = "Action",
																																																id = "209",
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
																																																class = "True",
																																																id = "211",
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
																																													class = "Selector",
																																													id = "148",
																																													properties = {},
																																													attachments = {},
																																													children = {
																																														{
																																															node = {
																																																class = "Condition",
																																																id = "166",
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
																																																class = "Condition",
																																																id = "167",
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
																																													class = "Selector",
																																													id = "283",
																																													properties = {},
																																													attachments = {},
																																													children = {
																																														{
																																															node = {
																																																class = "Sequence",
																																																id = "284",
																																																properties = {},
																																																attachments = {},
																																																children = {
																																																	{
																																																		node = {
																																																			class = "Selector",
																																																			id = "287",
																																																			properties = {},
																																																			attachments = {},
																																																			children = {
																																																				{
																																																					node = {
																																																						class = "Condition",
																																																						id = "288",
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
																																																						class = "Condition",
																																																						id = "289",
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
																																																			class = "Condition",
																																																			id = "282",
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
																																																			class = "Assignment",
																																																			id = "149",
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
																																																			class = "Action",
																																																			id = "286",
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
																																																class = "SelectorProbability",
																																																id = "328",
																																																properties = {
																																																	{
																																																		UntilSuccessOrEnd = false
																																																	}
																																																},
																																																attachments = {},
																																																children = {
																																																	{
																																																		node = {
																																																			class = "DecoratorWeight",
																																																			id = "334",
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
																																																						class = "Assignment",
																																																						id = "337",
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
																																																			class = "DecoratorWeight",
																																																			id = "331",
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
																																																						class = "Assignment",
																																																						id = "336",
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
																																																			class = "DecoratorWeight",
																																																			id = "329",
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
																																																						class = "Assignment",
																																																						id = "335",
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
																																													class = "Condition",
																																													id = "150",
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
																																													class = "Selector",
																																													id = "213",
																																													properties = {},
																																													attachments = {},
																																													children = {
																																														{
																																															node = {
																																																class = "Sequence",
																																																id = "214",
																																																properties = {},
																																																attachments = {},
																																																children = {
																																																	{
																																																		node = {
																																																			class = "Condition",
																																																			id = "343",
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
																																																			class = "Selector",
																																																			id = "216",
																																																			properties = {},
																																																			attachments = {},
																																																			children = {
																																																				{
																																																					node = {
																																																						class = "Sequence",
																																																						id = "217",
																																																						properties = {},
																																																						attachments = {},
																																																						children = {
																																																							{
																																																								node = {
																																																									class = "Condition",
																																																									id = "219",
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
																																																									class = "Action",
																																																									id = "220",
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
																																																						class = "Action",
																																																						id = "218",
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
																																																class = "Sequence",
																																																id = "215",
																																																properties = {},
																																																attachments = {},
																																																children = {
																																																	{
																																																		node = {
																																																			class = "Assignment",
																																																			id = "221",
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
																																																			class = "Action",
																																																			id = "223",
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
																																																			class = "Action",
																																																			id = "224",
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
																																													class = "Action",
																																													id = "152",
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
																																										class = "Sequence",
																																										id = "163",
																																										properties = {},
																																										attachments = {},
																																										children = {
																																											{
																																												node = {
																																													class = "Selector",
																																													id = "168",
																																													properties = {},
																																													attachments = {},
																																													children = {
																																														{
																																															node = {
																																																class = "Condition",
																																																id = "172",
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
																																																class = "Condition",
																																																id = "169",
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
																																													class = "Action",
																																													id = "233",
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
																																													class = "IfElse",
																																													id = "305",
																																													properties = {},
																																													attachments = {},
																																													children = {
																																														{
																																															node = {
																																																class = "Condition",
																																																id = "375",
																																																properties = {
																																																	{
																																																		Operator = "GreaterEqual"
																																																	},
																																																	{
																																																		Opl = {
																																																			func = "getEntityCacheValue",
																																																			params = {
																																																				{
																																																					const = "AI_BossStage"
																																																				}
																																																			}
																																																		}
																																																	},
																																																	{
																																																		Opr = {
																																																			const = 2
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
																																																id = "309",
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
																																														},
																																														{
																																															node = {
																																																class = "Action",
																																																id = "170",
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
																																														}
																																													}
																																												}
																																											},
																																											{
																																												node = {
																																													class = "Action",
																																													id = "171",
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
																																							class = "IfElse",
																																							id = "173",
																																							properties = {},
																																							attachments = {},
																																							children = {
																																								{
																																									node = {
																																										class = "Condition",
																																										id = "181",
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
																																										class = "Sequence",
																																										id = "174",
																																										properties = {},
																																										attachments = {},
																																										children = {
																																											{
																																												node = {
																																													class = "Compute",
																																													id = "176",
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
																																													class = "Assignment",
																																													id = "177",
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
																																										class = "Sequence",
																																										id = "175",
																																										properties = {},
																																										attachments = {},
																																										children = {
																																											{
																																												node = {
																																													class = "Compute",
																																													id = "178",
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
																																													class = "Assignment",
																																													id = "179",
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
																																							class = "Action",
																																							id = "180",
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
																														class = "DecoratorWeight",
																														id = "147",
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
																																	class = "False",
																																	id = "146",
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
																											class = "Sequence",
																											id = "182",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														class = "IfElse",
																														id = "183",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	class = "Condition",
																																	id = "184",
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
																																	class = "Sequence",
																																	id = "185",
																																	properties = {},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				class = "Compute",
																																				id = "186",
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
																																				class = "Assignment",
																																				id = "187",
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
																																	class = "Sequence",
																																	id = "188",
																																	properties = {},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				class = "Compute",
																																				id = "189",
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
																																				class = "Assignment",
																																				id = "190",
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
																														class = "Selector",
																														id = "195",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	class = "Sequence",
																																	id = "194",
																																	properties = {},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				class = "Assignment",
																																				id = "198",
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
																																				class = "Condition",
																																				id = "196",
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
																																				class = "Condition",
																																				id = "193",
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
																																				class = "Compute",
																																				id = "347",
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
																																				class = "Selector",
																																				id = "192",
																																				properties = {},
																																				attachments = {},
																																				children = {
																																					{
																																						node = {
																																							class = "Action",
																																							id = "191",
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
																																							class = "Action",
																																							id = "200",
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
																																	class = "Selector",
																																	id = "234",
																																	properties = {},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				class = "SelectorProbability",
																																				id = "235",
																																				properties = {
																																					{
																																						UntilSuccessOrEnd = false
																																					}
																																				},
																																				attachments = {},
																																				children = {
																																					{
																																						node = {
																																							class = "DecoratorWeight",
																																							id = "241",
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
																																										class = "False",
																																										id = "240",
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
																																							class = "DecoratorWeight",
																																							id = "243",
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
																																										class = "Sequence",
																																										id = "242",
																																										properties = {},
																																										attachments = {},
																																										children = {
																																											{
																																												node = {
																																													class = "Condition",
																																													id = "244",
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
																																													class = "Selector",
																																													id = "245",
																																													properties = {},
																																													attachments = {},
																																													children = {
																																														{
																																															node = {
																																																class = "Condition",
																																																id = "246",
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
																																																class = "Condition",
																																																id = "247",
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
																																													class = "Action",
																																													id = "248",
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
																																													class = "Action",
																																													id = "249",
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
																																													class = "Action",
																																													id = "250",
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
																																				class = "Sequence",
																																				id = "252",
																																				properties = {},
																																				attachments = {
																																					{
																																						transition = false,
																																						class = "Precondition",
																																						precondition = true,
																																						effector = false,
																																						id = "135",
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
																																							class = "IfElse",
																																							id = "253",
																																							properties = {},
																																							attachments = {},
																																							children = {
																																								{
																																									node = {
																																										class = "Condition",
																																										id = "254",
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
																																										class = "Sequence",
																																										id = "256",
																																										properties = {},
																																										attachments = {
																																											{
																																												transition = false,
																																												class = "Precondition",
																																												precondition = true,
																																												effector = false,
																																												id = "104",
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
																																													class = "Action",
																																													id = "258",
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
																																										class = "Selector",
																																										id = "339",
																																										properties = {},
																																										attachments = {},
																																										children = {
																																											{
																																												node = {
																																													class = "Sequence",
																																													id = "251",
																																													properties = {},
																																													attachments = {},
																																													children = {
																																														{
																																															node = {
																																																class = "Assignment",
																																																id = "237",
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
																																																class = "Condition",
																																																id = "238",
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
																																																class = "Compute",
																																																id = "346",
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
																																																class = "Action",
																																																id = "239",
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
																																													class = "Action",
																																													id = "340",
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
								}
							}
						}
					}
				}
			}
		}
	}
}

return ST_Monster_AutoCombat_Boss_10187_BossRush
