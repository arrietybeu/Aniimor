-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\CombatUnit\\Monster\\Root\\Combat\\ST_Monster_AutoCombat_Boss_10262.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local ST_Monster_AutoCombat_Boss_10262 = {
	behavior = {
		version = 87,
		name = "CombatUnit/Monster/Root/Combat/ST_Monster_AutoCombat_Boss_10262",
		agenttype = "PuppetAgent",
		useForRoute = false,
		properties = {},
		pars = {
			{
				type = "int",
				value = "0",
				name = "tSkill_ComboAttack",
				const = 0
			},
			{
				type = "int",
				value = "0",
				name = "tSkill_12620130",
				const = 0
			},
			{
				type = "int",
				value = "0",
				name = "tSkill_12620200",
				const = 0
			},
			{
				type = "int",
				value = "0",
				name = "tSkill_12620400",
				const = 0
			},
			{
				type = "int",
				value = "0",
				name = "tSkill_12620500",
				const = 0
			},
			{
				type = "float",
				value = "0",
				name = "skillStopDist",
				const = 0
			},
			{
				type = "int",
				value = "0",
				name = "tPlayer",
				const = 0
			},
			{
				type = "int",
				value = "0",
				name = "tSkill_12620210",
				const = 0
			},
			{
				type = "int",
				value = "0",
				name = "tSkill_12620270",
				const = 0
			}
		},
		attachments = {},
		node = {
			id = "198",
			class = "Sequence",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						id = "152",
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
									const = 100
								}
							}
						},
						attachments = {},
						children = {}
					}
				},
				{
					node = {
						id = "314",
						class = "Assignment",
						properties = {
							{
								CastRight = "false"
							},
							{
								Opl = {
									field = "bornPos"
								}
							},
							{
								Opr = {
									func = "getBornPos"
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
									id = "4",
									class = "Sequence",
									properties = {},
									attachments = {},
									children = {
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
												id = "5",
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
												id = "6",
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
												id = "7",
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
												id = "251",
												class = "Assignment",
												properties = {
													{
														CastRight = "false"
													},
													{
														Opl = {
															field = "tPlayer"
														}
													},
													{
														Opr = {
															func = "getAuthorityPlayer"
														}
													}
												},
												attachments = {},
												children = {}
											}
										},
										{
											node = {
												id = "417",
												class = "IfElse",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "421",
															class = "Condition",
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
													},
													{
														node = {
															id = "423",
															class = "Sequence",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		id = "425",
																		class = "Action",
																		properties = {
																			{
																				Method = {
																					func = "playPhaseAction",
																					params = {
																						{
																							const = "Behav_AngryStart"
																						},
																						{
																							const = "Behav_AngryLoop"
																						},
																						{
																							const = "Behav_AngryEnd"
																						},
																						{
																							const = 3
																						},
																						{
																							const = ""
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
																		id = "424",
																		class = "Action",
																		properties = {
																			{
																				Method = {
																					func = "setEntityCacheValue",
																					params = {
																						{
																							const = "AI_BossStage"
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
															id = "256",
															class = "IfElse",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		id = "258",
																		class = "And",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					id = "255",
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
																					id = "259",
																					class = "Condition",
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
																					id = "441",
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
																			}
																		}
																	}
																},
																{
																	node = {
																		id = "260",
																		class = "Sequence",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					id = "261",
																					class = "Action",
																					properties = {
																						{
																							Method = {
																								func = "castSkill",
																								params = {
																									{
																										field = "tPlayer"
																									},
																									{
																										const = 12620600
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
																							ResultResumeOption = "BT_NextNode"
																						}
																					},
																					attachments = {},
																					children = {}
																				}
																			},
																			{
																				node = {
																					id = "439",
																					class = "Assignment",
																					properties = {
																						{
																							CastRight = "false"
																						},
																						{
																							Opl = {
																								field = "tSkill_12620270"
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
																		id = "248",
																		class = "IfElse",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					id = "427",
																					class = "And",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								id = "246",
																								class = "Condition",
																								properties = {
																									{
																										Operator = "Equal"
																									},
																									{
																										Opl = {
																											func = "checkTargetHasBuffById",
																											params = {
																												{
																													field = "selfId"
																												},
																												{
																													const = 100014
																												},
																												{
																													const = 1
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
																								id = "426",
																								class = "Condition",
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
																					id = "252",
																					class = "Sequence",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								id = "253",
																								class = "Action",
																								properties = {
																									{
																										Method = {
																											func = "turnToTargetAtYaw",
																											params = {
																												{
																													field = "tPlayer"
																												},
																												{
																													const = 0
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
																								id = "250",
																								class = "Action",
																								properties = {
																									{
																										Method = {
																											func = "castSkill",
																											params = {
																												{
																													field = "tPlayer"
																												},
																												{
																													const = 12620230
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
																					id = "295",
																					class = "IfElse",
																					properties = {},
																					attachments = {},
																					children = {
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
																								id = "299",
																								class = "Sequence",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											id = "298",
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
																											id = "300",
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
																																const = 12620510
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
																													ResultResumeOption = "BT_NextNode"
																												}
																											},
																											attachments = {},
																											children = {}
																										}
																									},
																									{
																										node = {
																											id = "301",
																											class = "Action",
																											properties = {
																												{
																													Method = {
																														func = "setEntityCacheValue",
																														params = {
																															{
																																const = "AI_BossStage"
																															},
																															{
																																const = 5
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
																											id = "438",
																											class = "Assignment",
																											properties = {
																												{
																													CastRight = "false"
																												},
																												{
																													Opl = {
																														field = "tSkill_12620270"
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
																								id = "332",
																								class = "IfElse",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											id = "333",
																											class = "Condition",
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
																											id = "335",
																											class = "Sequence",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "331",
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
																																			const = 1026202
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
																														id = "337",
																														class = "Action",
																														properties = {
																															{
																																Method = {
																																	func = "setEntityCacheValue",
																																	params = {
																																		{
																																			const = "AI_BossStage"
																																		},
																																		{
																																			const = 5
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
																														id = "309",
																														class = "IfElse",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	id = "327",
																																	class = "And",
																																	properties = {},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				id = "315",
																																				class = "Condition",
																																				properties = {
																																					{
																																						Operator = "GreaterEqual"
																																					},
																																					{
																																						Opl = {
																																							func = "getDistByPos",
																																							params = {
																																								{
																																									field = "bornPos"
																																								},
																																								{
																																									const = false
																																								},
																																								{
																																									field = "selfId"
																																								}
																																							}
																																						}
																																					},
																																					{
																																						Opr = {
																																							const = 28
																																						}
																																					}
																																				},
																																				attachments = {},
																																				children = {}
																																			}
																																		},
																																		{
																																			node = {
																																				id = "328",
																																				class = "Condition",
																																				properties = {
																																					{
																																						Operator = "GreaterEqual"
																																					},
																																					{
																																						Opl = {
																																							func = "getDistByPos",
																																							params = {
																																								{
																																									field = "bornPos"
																																								},
																																								{
																																									const = false
																																								},
																																								{
																																									field = "selfId"
																																								}
																																							}
																																						}
																																					},
																																					{
																																						Opr = {
																																							func = "getDistByPos",
																																							params = {
																																								{
																																									field = "bornPos"
																																								},
																																								{
																																									const = false
																																								},
																																								{
																																									field = "tPlayer"
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
																																	id = "329",
																																	class = "Action",
																																	properties = {
																																		{
																																			Method = {
																																				func = "castSkill",
																																				params = {
																																					{
																																						field = "tPlayer"
																																					},
																																					{
																																						const = 12620260
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
																																			ResultResumeOption = "BT_NextNode"
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
																																										id = "24",
																																										class = "Sequence",
																																										properties = {},
																																										attachments = {},
																																										children = {
																																											{
																																												node = {
																																													id = "46",
																																													class = "Sequence",
																																													properties = {},
																																													attachments = {},
																																													children = {
																																														{
																																															node = {
																																																id = "49",
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
																																																			const = 100
																																																		}
																																																	}
																																																},
																																																attachments = {},
																																																children = {}
																																															}
																																														},
																																														{
																																															node = {
																																																id = "50",
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
																																																			const = 100
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
																																													id = "187",
																																													class = "IfElse",
																																													properties = {},
																																													attachments = {},
																																													children = {
																																														{
																																															node = {
																																																id = "186",
																																																class = "Condition",
																																																properties = {
																																																	{
																																																		Operator = "GreaterEqual"
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
																																																id = "190",
																																																class = "Sequence",
																																																properties = {},
																																																attachments = {},
																																																children = {
																																																	{
																																																		node = {
																																																			id = "204",
																																																			class = "IfElse",
																																																			properties = {},
																																																			attachments = {},
																																																			children = {
																																																				{
																																																					node = {
																																																						id = "203",
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
																																																											field = "tgt"
																																																										},
																																																										{
																																																											const = 12620130
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
																																																						id = "205",
																																																						class = "Assignment",
																																																						properties = {
																																																							{
																																																								CastRight = "false"
																																																							},
																																																							{
																																																								Opl = {
																																																									field = "tSkill_12620130"
																																																								}
																																																							},
																																																							{
																																																								Opr = {
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
																																																						id = "206",
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
																																																			id = "194",
																																																			class = "IfElse",
																																																			properties = {},
																																																			attachments = {},
																																																			children = {
																																																				{
																																																					node = {
																																																						id = "192",
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
																																																											field = "tgt"
																																																										},
																																																										{
																																																											const = 12620240
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
																																																						id = "191",
																																																						class = "Assignment",
																																																						properties = {
																																																							{
																																																								CastRight = "false"
																																																							},
																																																							{
																																																								Opl = {
																																																									field = "tSkill_12620200"
																																																								}
																																																							},
																																																							{
																																																								Opr = {
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
																																																						id = "202",
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
																																																			id = "278",
																																																			class = "IfElse",
																																																			properties = {},
																																																			attachments = {},
																																																			children = {
																																																				{
																																																					node = {
																																																						id = "281",
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
																																																											field = "tgt"
																																																										},
																																																										{
																																																											const = 12620410
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
																																																						id = "279",
																																																						class = "Assignment",
																																																						properties = {
																																																							{
																																																								CastRight = "false"
																																																							},
																																																							{
																																																								Opl = {
																																																									field = "tSkill_12620400"
																																																								}
																																																							},
																																																							{
																																																								Opr = {
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
																																																						id = "280",
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
																																																			id = "366",
																																																			class = "IfElse",
																																																			properties = {},
																																																			attachments = {},
																																																			children = {
																																																				{
																																																					node = {
																																																						id = "370",
																																																						class = "And",
																																																						properties = {},
																																																						attachments = {},
																																																						children = {
																																																							{
																																																								node = {
																																																									id = "369",
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
																																																														field = "tgt"
																																																													},
																																																													{
																																																														const = 12620270
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
																																																									id = "371",
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
																																																												const = 0.7
																																																											}
																																																										}
																																																									},
																																																									attachments = {},
																																																									children = {}
																																																								}
																																																							},
																																																							{
																																																								node = {
																																																									id = "442",
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
																																																							}
																																																						}
																																																					}
																																																				},
																																																				{
																																																					node = {
																																																						id = "367",
																																																						class = "Assignment",
																																																						properties = {
																																																							{
																																																								CastRight = "false"
																																																							},
																																																							{
																																																								Opl = {
																																																									field = "tSkill_12620270"
																																																								}
																																																							},
																																																							{
																																																								Opr = {
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
																																																						id = "368",
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
																																																			id = "232",
																																																			class = "Compute",
																																																			properties = {
																																																				{
																																																					Operator = "Add"
																																																				},
																																																				{
																																																					Opl = {
																																																						field = "tSkill_ComboAttack"
																																																					}
																																																				},
																																																				{
																																																					Opr1 = {
																																																						field = "tSkill_ComboAttack"
																																																					}
																																																				},
																																																				{
																																																					Opr2 = {
																																																						const = 100
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
																																																id = "200",
																																																class = "Sequence",
																																																properties = {},
																																																attachments = {},
																																																children = {
																																																	{
																																																		node = {
																																																			id = "240",
																																																			class = "IfElse",
																																																			properties = {},
																																																			attachments = {},
																																																			children = {
																																																				{
																																																					node = {
																																																						id = "239",
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
																																																											field = "tgt"
																																																										},
																																																										{
																																																											const = 12620410
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
																																																						id = "241",
																																																						class = "Assignment",
																																																						properties = {
																																																							{
																																																								CastRight = "false"
																																																							},
																																																							{
																																																								Opl = {
																																																									field = "tSkill_12620400"
																																																								}
																																																							},
																																																							{
																																																								Opr = {
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
																																																						id = "242",
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
																																																			id = "236",
																																																			class = "IfElse",
																																																			properties = {},
																																																			attachments = {},
																																																			children = {
																																																				{
																																																					node = {
																																																						id = "235",
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
																																																											field = "tgt"
																																																										},
																																																										{
																																																											const = 12620520
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
																																																						id = "237",
																																																						class = "Assignment",
																																																						properties = {
																																																							{
																																																								CastRight = "false"
																																																							},
																																																							{
																																																								Opl = {
																																																									field = "tSkill_12620500"
																																																								}
																																																							},
																																																							{
																																																								Opr = {
																																																									const = 600
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
																																																			id = "274",
																																																			class = "IfElse",
																																																			properties = {},
																																																			attachments = {},
																																																			children = {
																																																				{
																																																					node = {
																																																						id = "273",
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
																																																											field = "tgt"
																																																										},
																																																										{
																																																											const = 12620250
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
																																																						id = "275",
																																																						class = "Assignment",
																																																						properties = {
																																																							{
																																																								CastRight = "false"
																																																							},
																																																							{
																																																								Opl = {
																																																									field = "tSkill_12620210"
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
																																																						id = "276",
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
																																																			id = "372",
																																																			class = "IfElse",
																																																			properties = {},
																																																			attachments = {},
																																																			children = {
																																																				{
																																																					node = {
																																																						id = "374",
																																																						class = "And",
																																																						properties = {},
																																																						attachments = {},
																																																						children = {
																																																							{
																																																								node = {
																																																									id = "375",
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
																																																														field = "tgt"
																																																													},
																																																													{
																																																														const = 12620270
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
																																																									id = "377",
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
																																																												const = 0.7
																																																											}
																																																										}
																																																									},
																																																									attachments = {},
																																																									children = {}
																																																								}
																																																							},
																																																							{
																																																								node = {
																																																									id = "445",
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
																																																							}
																																																						}
																																																					}
																																																				},
																																																				{
																																																					node = {
																																																						id = "376",
																																																						class = "Assignment",
																																																						properties = {
																																																							{
																																																								CastRight = "false"
																																																							},
																																																							{
																																																								Opl = {
																																																									field = "tSkill_12620270"
																																																								}
																																																							},
																																																							{
																																																								Opr = {
																																																									const = 100
																																																								}
																																																							}
																																																						},
																																																						attachments = {},
																																																						children = {}
																																																					}
																																																				},
																																																				{
																																																					node = {
																																																						id = "373",
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
																																																			id = "243",
																																																			class = "Compute",
																																																			properties = {
																																																				{
																																																					Operator = "Add"
																																																				},
																																																				{
																																																					Opl = {
																																																						field = "tSkill_ComboAttack"
																																																					}
																																																				},
																																																				{
																																																					Opr1 = {
																																																						field = "tSkill_ComboAttack"
																																																					}
																																																				},
																																																				{
																																																					Opr2 = {
																																																						const = 100
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
																																													id = "156",
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
																																																id = "157",
																																																class = "DecoratorWeight",
																																																properties = {
																																																	{
																																																		DecorateWhenChildEnds = "false"
																																																	},
																																																	{
																																																		Weight = {
																																																			field = "tSkill_ComboAttack"
																																																		}
																																																	}
																																																},
																																																attachments = {},
																																																children = {
																																																	{
																																																		node = {
																																																			id = "38",
																																																			class = "Sequence",
																																																			properties = {},
																																																			attachments = {},
																																																			children = {
																																																				{
																																																					node = {
																																																						id = "159",
																																																						class = "IfElse",
																																																						properties = {},
																																																						attachments = {},
																																																						children = {
																																																							{
																																																								node = {
																																																									id = "158",
																																																									class = "Condition",
																																																									properties = {
																																																										{
																																																											Operator = "LessEqual"
																																																										},
																																																										{
																																																											Opl = {
																																																												field = "maxAttackDist"
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
																																																									id = "146",
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
																																																														const = BaseEnum.SpeedRateType.Fast
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
																																																									id = "160",
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
																																																						id = "41",
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
																																																											const = 4
																																																										},
																																																										{
																																																											const = true
																																																										},
																																																										{
																																																											const = 3
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
																																																						id = "155",
																																																						class = "Assignment",
																																																						properties = {
																																																							{
																																																								CastRight = "false"
																																																							},
																																																							{
																																																								Opl = {
																																																									field = "tSkill_ComboAttack"
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
																																																	}
																																																}
																																															}
																																														},
																																														{
																																															node = {
																																																id = "165",
																																																class = "DecoratorWeight",
																																																properties = {
																																																	{
																																																		DecorateWhenChildEnds = "false"
																																																	},
																																																	{
																																																		Weight = {
																																																			field = "tSkill_12620200"
																																																		}
																																																	}
																																																},
																																																attachments = {},
																																																children = {
																																																	{
																																																		node = {
																																																			id = "162",
																																																			class = "Sequence",
																																																			properties = {},
																																																			attachments = {},
																																																			children = {
																																																				{
																																																					node = {
																																																						id = "169",
																																																						class = "Assignment",
																																																						properties = {
																																																							{
																																																								CastRight = "false"
																																																							},
																																																							{
																																																								Opl = {
																																																									field = "skillStopDist"
																																																								}
																																																							},
																																																							{
																																																								Opr = {
																																																									func = "getSkillStopBoxDist",
																																																									params = {
																																																										{
																																																											const = 12620240
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
																																																						id = "153",
																																																						class = "IfElse",
																																																						properties = {},
																																																						attachments = {},
																																																						children = {
																																																							{
																																																								node = {
																																																									id = "149",
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
																																																														const = 12620200
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
																																																									id = "212",
																																																									class = "Sequence",
																																																									properties = {},
																																																									attachments = {},
																																																									children = {
																																																										{
																																																											node = {
																																																												id = "211",
																																																												class = "Assignment",
																																																												properties = {
																																																													{
																																																														CastRight = "false"
																																																													},
																																																													{
																																																														Opl = {
																																																															field = "skillStopDist"
																																																														}
																																																													},
																																																													{
																																																														Opr = {
																																																															func = "getSkillStopBoxDist",
																																																															params = {
																																																																{
																																																																	const = 12620240
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
																																																												id = "120",
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
																																																																	field = "skillStopDist"
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
																																																																	const = BaseEnum.SpeedRateType.Fast
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
																																																									id = "154",
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
																																																						id = "166",
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
																																																											const = 12620240
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
																																																								ResultResumeOption = "BT_NextNode"
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
																																																id = "177",
																																																class = "DecoratorWeight",
																																																properties = {
																																																	{
																																																		DecorateWhenChildEnds = "false"
																																																	},
																																																	{
																																																		Weight = {
																																																			field = "tSkill_12620400"
																																																		}
																																																	}
																																																},
																																																attachments = {},
																																																children = {
																																																	{
																																																		node = {
																																																			id = "175",
																																																			class = "Sequence",
																																																			properties = {},
																																																			attachments = {},
																																																			children = {
																																																				{
																																																					node = {
																																																						id = "171",
																																																						class = "Assignment",
																																																						properties = {
																																																							{
																																																								CastRight = "false"
																																																							},
																																																							{
																																																								Opl = {
																																																									field = "skillStopDist"
																																																								}
																																																							},
																																																							{
																																																								Opr = {
																																																									func = "getSkillStopBoxDist",
																																																									params = {
																																																										{
																																																											const = 12620410
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
																																																						id = "176",
																																																						class = "IfElse",
																																																						properties = {},
																																																						attachments = {},
																																																						children = {
																																																							{
																																																								node = {
																																																									id = "174",
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
																																																														const = 12620410
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
																																																									id = "213",
																																																									class = "Sequence",
																																																									properties = {},
																																																									attachments = {},
																																																									children = {
																																																										{
																																																											node = {
																																																												id = "214",
																																																												class = "Assignment",
																																																												properties = {
																																																													{
																																																														CastRight = "false"
																																																													},
																																																													{
																																																														Opl = {
																																																															field = "skillStopDist"
																																																														}
																																																													},
																																																													{
																																																														Opr = {
																																																															func = "getSkillStopBoxDist",
																																																															params = {
																																																																{
																																																																	const = 12620410
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
																																																																	field = "skillStopDist"
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
																																																																	const = BaseEnum.SpeedRateType.Fast
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
																																																									id = "173",
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
																																																						id = "170",
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
																																																											const = 12620410
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
																																																								ResultResumeOption = "BT_NextNode"
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
																																																id = "189",
																																																class = "DecoratorWeight",
																																																properties = {
																																																	{
																																																		DecorateWhenChildEnds = "false"
																																																	},
																																																	{
																																																		Weight = {
																																																			field = "tSkill_12620500"
																																																		}
																																																	}
																																																},
																																																attachments = {},
																																																children = {
																																																	{
																																																		node = {
																																																			id = "183",
																																																			class = "Sequence",
																																																			properties = {},
																																																			attachments = {},
																																																			children = {
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
																																																									field = "skillStopDist"
																																																								}
																																																							},
																																																							{
																																																								Opr = {
																																																									func = "getSkillStopBoxDist",
																																																									params = {
																																																										{
																																																											const = 12620520
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
																																																						id = "184",
																																																						class = "IfElse",
																																																						properties = {},
																																																						attachments = {},
																																																						children = {
																																																							{
																																																								node = {
																																																									id = "182",
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
																																																														const = 12620520
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
																																																									id = "215",
																																																									class = "Sequence",
																																																									properties = {},
																																																									attachments = {},
																																																									children = {
																																																										{
																																																											node = {
																																																												id = "216",
																																																												class = "Assignment",
																																																												properties = {
																																																													{
																																																														CastRight = "false"
																																																													},
																																																													{
																																																														Opl = {
																																																															field = "skillStopDist"
																																																														}
																																																													},
																																																													{
																																																														Opr = {
																																																															func = "getSkillStopBoxDist",
																																																															params = {
																																																																{
																																																																	const = 12620520
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
																																																												id = "180",
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
																																																																	field = "skillStopDist"
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
																																																																	const = BaseEnum.SpeedRateType.Fast
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
																																																									id = "181",
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
																																																						id = "389",
																																																						class = "Sequence",
																																																						properties = {},
																																																						attachments = {},
																																																						children = {
																																																							{
																																																								node = {
																																																									id = "178",
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
																																																														const = 12620520
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
																																																											ResultResumeOption = "BT_NextNode"
																																																										}
																																																									},
																																																									attachments = {},
																																																									children = {}
																																																								}
																																																							},
																																																							{
																																																								node = {
																																																									id = "391",
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
																																																												id = "393",
																																																												class = "DecoratorWeight",
																																																												properties = {
																																																													{
																																																														DecorateWhenChildEnds = "false"
																																																													},
																																																													{
																																																														Weight = {
																																																															const = 100
																																																														}
																																																													}
																																																												},
																																																												attachments = {},
																																																												children = {
																																																													{
																																																														node = {
																																																															id = "394",
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
																																																												id = "392",
																																																												class = "DecoratorWeight",
																																																												properties = {
																																																													{
																																																														DecorateWhenChildEnds = "false"
																																																													},
																																																													{
																																																														Weight = {
																																																															const = 50
																																																														}
																																																													}
																																																												},
																																																												attachments = {},
																																																												children = {
																																																													{
																																																														node = {
																																																															id = "390",
																																																															class = "Action",
																																																															properties = {
																																																																{
																																																																	Method = {
																																																																		func = "playPhaseAction",
																																																																		params = {
																																																																			{
																																																																				const = "Behav_AngryStart"
																																																																			},
																																																																			{
																																																																				const = "Behav_AngryLoop"
																																																																			},
																																																																			{
																																																																				const = "Behav_AngryEnd"
																																																																			},
																																																																			{
																																																																				const = 3
																																																																			},
																																																																			{
																																																																				const = ""
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
																																														},
																																														{
																																															node = {
																																																id = "270",
																																																class = "DecoratorWeight",
																																																properties = {
																																																	{
																																																		DecorateWhenChildEnds = "false"
																																																	},
																																																	{
																																																		Weight = {
																																																			field = "tSkill_12620210"
																																																		}
																																																	}
																																																},
																																																attachments = {},
																																																children = {
																																																	{
																																																		node = {
																																																			id = "268",
																																																			class = "Sequence",
																																																			properties = {},
																																																			attachments = {},
																																																			children = {
																																																				{
																																																					node = {
																																																						id = "264",
																																																						class = "Assignment",
																																																						properties = {
																																																							{
																																																								CastRight = "false"
																																																							},
																																																							{
																																																								Opl = {
																																																									field = "skillStopDist"
																																																								}
																																																							},
																																																							{
																																																								Opr = {
																																																									func = "getSkillStopBoxDist",
																																																									params = {
																																																										{
																																																											const = 12620210
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
																																																						id = "269",
																																																						class = "IfElse",
																																																						properties = {},
																																																						attachments = {},
																																																						children = {
																																																							{
																																																								node = {
																																																									id = "267",
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
																																																														const = 12620250
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
																																																									id = "271",
																																																									class = "Sequence",
																																																									properties = {},
																																																									attachments = {},
																																																									children = {
																																																										{
																																																											node = {
																																																												id = "272",
																																																												class = "Assignment",
																																																												properties = {
																																																													{
																																																														CastRight = "false"
																																																													},
																																																													{
																																																														Opl = {
																																																															field = "skillStopDist"
																																																														}
																																																													},
																																																													{
																																																														Opr = {
																																																															func = "getSkillStopBoxDist",
																																																															params = {
																																																																{
																																																																	const = 12620250
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
																																																												id = "265",
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
																																																																	field = "skillStopDist"
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
																																																																	const = BaseEnum.SpeedRateType.Fast
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
																																																									id = "266",
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
																																																						id = "395",
																																																						class = "Sequence",
																																																						properties = {},
																																																						attachments = {},
																																																						children = {
																																																							{
																																																								node = {
																																																									id = "263",
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
																																																														const = 12620250
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
																																																									id = "396",
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
																																																												id = "398",
																																																												class = "DecoratorWeight",
																																																												properties = {
																																																													{
																																																														DecorateWhenChildEnds = "false"
																																																													},
																																																													{
																																																														Weight = {
																																																															const = 100
																																																														}
																																																													}
																																																												},
																																																												attachments = {},
																																																												children = {
																																																													{
																																																														node = {
																																																															id = "399",
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
																																																												id = "397",
																																																												class = "DecoratorWeight",
																																																												properties = {
																																																													{
																																																														DecorateWhenChildEnds = "false"
																																																													},
																																																													{
																																																														Weight = {
																																																															const = 50
																																																														}
																																																													}
																																																												},
																																																												attachments = {},
																																																												children = {
																																																													{
																																																														node = {
																																																															id = "400",
																																																															class = "Action",
																																																															properties = {
																																																																{
																																																																	Method = {
																																																																		func = "playPhaseAction",
																																																																		params = {
																																																																			{
																																																																				const = "Behav_AngryStart"
																																																																			},
																																																																			{
																																																																				const = "Behav_AngryLoop"
																																																																			},
																																																																			{
																																																																				const = "Behav_AngryEnd"
																																																																			},
																																																																			{
																																																																				const = 3
																																																																			},
																																																																			{
																																																																				const = ""
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
																																														},
																																														{
																																															node = {
																																																id = "287",
																																																class = "DecoratorWeight",
																																																properties = {
																																																	{
																																																		DecorateWhenChildEnds = "false"
																																																	},
																																																	{
																																																		Weight = {
																																																			field = "tSkill_12620130"
																																																		}
																																																	}
																																																},
																																																attachments = {},
																																																children = {
																																																	{
																																																		node = {
																																																			id = "285",
																																																			class = "Sequence",
																																																			properties = {},
																																																			attachments = {},
																																																			children = {
																																																				{
																																																					node = {
																																																						id = "282",
																																																						class = "Assignment",
																																																						properties = {
																																																							{
																																																								CastRight = "false"
																																																							},
																																																							{
																																																								Opl = {
																																																									field = "skillStopDist"
																																																								}
																																																							},
																																																							{
																																																								Opr = {
																																																									func = "getSkillStopBoxDist",
																																																									params = {
																																																										{
																																																											const = 12620130
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
																																																						id = "286",
																																																						class = "IfElse",
																																																						properties = {},
																																																						attachments = {},
																																																						children = {
																																																							{
																																																								node = {
																																																									id = "289",
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
																																																														const = 12620130
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
																																																									id = "288",
																																																									class = "Sequence",
																																																									properties = {},
																																																									attachments = {},
																																																									children = {
																																																										{
																																																											node = {
																																																												id = "290",
																																																												class = "Assignment",
																																																												properties = {
																																																													{
																																																														CastRight = "false"
																																																													},
																																																													{
																																																														Opl = {
																																																															field = "skillStopDist"
																																																														}
																																																													},
																																																													{
																																																														Opr = {
																																																															func = "getSkillStopBoxDist",
																																																															params = {
																																																																{
																																																																	const = 12620130
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
																																																												id = "283",
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
																																																																	field = "skillStopDist"
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
																																																																	const = BaseEnum.SpeedRateType.Fast
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
																																																									id = "284",
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
																																																						id = "401",
																																																						class = "Sequence",
																																																						properties = {},
																																																						attachments = {},
																																																						children = {
																																																							{
																																																								node = {
																																																									id = "291",
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
																																																														const = 12620130
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
																																																									id = "402",
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
																																																												id = "404",
																																																												class = "DecoratorWeight",
																																																												properties = {
																																																													{
																																																														DecorateWhenChildEnds = "false"
																																																													},
																																																													{
																																																														Weight = {
																																																															const = 100
																																																														}
																																																													}
																																																												},
																																																												attachments = {},
																																																												children = {
																																																													{
																																																														node = {
																																																															id = "405",
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
																																																												id = "403",
																																																												class = "DecoratorWeight",
																																																												properties = {
																																																													{
																																																														DecorateWhenChildEnds = "false"
																																																													},
																																																													{
																																																														Weight = {
																																																															const = 50
																																																														}
																																																													}
																																																												},
																																																												attachments = {},
																																																												children = {
																																																													{
																																																														node = {
																																																															id = "406",
																																																															class = "Action",
																																																															properties = {
																																																																{
																																																																	Method = {
																																																																		func = "playPhaseAction",
																																																																		params = {
																																																																			{
																																																																				const = "Behav_AngryStart"
																																																																			},
																																																																			{
																																																																				const = "Behav_AngryLoop"
																																																																			},
																																																																			{
																																																																				const = "Behav_AngryEnd"
																																																																			},
																																																																			{
																																																																				const = 3
																																																																			},
																																																																			{
																																																																				const = ""
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
																																														},
																																														{
																																															node = {
																																																id = "385",
																																																class = "DecoratorWeight",
																																																properties = {
																																																	{
																																																		DecorateWhenChildEnds = "false"
																																																	},
																																																	{
																																																		Weight = {
																																																			field = "tSkill_12620270"
																																																		}
																																																	}
																																																},
																																																attachments = {},
																																																children = {
																																																	{
																																																		node = {
																																																			id = "383",
																																																			class = "Sequence",
																																																			properties = {},
																																																			attachments = {},
																																																			children = {
																																																				{
																																																					node = {
																																																						id = "379",
																																																						class = "Assignment",
																																																						properties = {
																																																							{
																																																								CastRight = "false"
																																																							},
																																																							{
																																																								Opl = {
																																																									field = "skillStopDist"
																																																								}
																																																							},
																																																							{
																																																								Opr = {
																																																									func = "getSkillStopBoxDist",
																																																									params = {
																																																										{
																																																											const = 12620270
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
																																																						id = "443",
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
																																																						id = "384",
																																																						class = "IfElse",
																																																						properties = {},
																																																						attachments = {},
																																																						children = {
																																																							{
																																																								node = {
																																																									id = "382",
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
																																																														const = 12620270
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
																																																									id = "387",
																																																									class = "Sequence",
																																																									properties = {},
																																																									attachments = {},
																																																									children = {
																																																										{
																																																											node = {
																																																												id = "386",
																																																												class = "Assignment",
																																																												properties = {
																																																													{
																																																														CastRight = "false"
																																																													},
																																																													{
																																																														Opl = {
																																																															field = "skillStopDist"
																																																														}
																																																													},
																																																													{
																																																														Opr = {
																																																															func = "getSkillStopBoxDist",
																																																															params = {
																																																																{
																																																																	const = 12620270
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
																																																												id = "380",
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
																																																																	field = "skillStopDist"
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
																																																																	const = BaseEnum.SpeedRateType.Fast
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
																																																									id = "381",
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
																																																						id = "388",
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
																																																											const = 12620270
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
																																																						id = "412",
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
																																																									id = "414",
																																																									class = "DecoratorWeight",
																																																									properties = {
																																																										{
																																																											DecorateWhenChildEnds = "false"
																																																										},
																																																										{
																																																											Weight = {
																																																												const = 20
																																																											}
																																																										}
																																																									},
																																																									attachments = {},
																																																									children = {
																																																										{
																																																											node = {
																																																												id = "415",
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
																																																									id = "413",
																																																									class = "DecoratorWeight",
																																																									properties = {
																																																										{
																																																											DecorateWhenChildEnds = "false"
																																																										},
																																																										{
																																																											Weight = {
																																																												const = 80
																																																											}
																																																										}
																																																									},
																																																									attachments = {},
																																																									children = {
																																																										{
																																																											node = {
																																																												id = "416",
																																																												class = "Action",
																																																												properties = {
																																																													{
																																																														Method = {
																																																															func = "playPhaseAction",
																																																															params = {
																																																																{
																																																																	const = "Behav_AngryStart"
																																																																},
																																																																{
																																																																	const = "Behav_AngryLoop"
																																																																},
																																																																{
																																																																	const = "Behav_AngryEnd"
																																																																},
																																																																{
																																																																	const = 3
																																																																},
																																																																{
																																																																	const = ""
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
																																											},
																																											{
																																												node = {
																																													id = "233",
																																													class = "Sequence",
																																													properties = {},
																																													attachments = {},
																																													children = {
																																														{
																																															node = {
																																																id = "244",
																																																class = "Assignment",
																																																properties = {
																																																	{
																																																		CastRight = "false"
																																																	},
																																																	{
																																																		Opl = {
																																																			field = "tSkill_12620130"
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
																																																id = "195",
																																																class = "Assignment",
																																																properties = {
																																																	{
																																																		CastRight = "false"
																																																	},
																																																	{
																																																		Opl = {
																																																			field = "tSkill_12620200"
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
																																																id = "196",
																																																class = "Assignment",
																																																properties = {
																																																	{
																																																		CastRight = "false"
																																																	},
																																																	{
																																																		Opl = {
																																																			field = "tSkill_12620400"
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
																																																id = "197",
																																																class = "Assignment",
																																																properties = {
																																																	{
																																																		CastRight = "false"
																																																	},
																																																	{
																																																		Opl = {
																																																			field = "tSkill_12620500"
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
																																																id = "277",
																																																class = "Assignment",
																																																properties = {
																																																	{
																																																		CastRight = "false"
																																																	},
																																																	{
																																																		Opl = {
																																																			field = "tSkill_12620210"
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
																																																id = "378",
																																																class = "Assignment",
																																																properties = {
																																																	{
																																																		CastRight = "false"
																																																	},
																																																	{
																																																		Opl = {
																																																			field = "tSkill_12620270"
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
																																				id = "53",
																																				class = "Sequence",
																																				properties = {},
																																				attachments = {},
																																				children = {
																																					{
																																						node = {
																																							id = "59",
																																							class = "Sequence",
																																							properties = {},
																																							attachments = {},
																																							children = {
																																								{
																																									node = {
																																										id = "60",
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
																																													const = 100
																																												}
																																											}
																																										},
																																										attachments = {},
																																										children = {}
																																									}
																																								},
																																								{
																																									node = {
																																										id = "61",
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
																																							id = "217",
																																							class = "IfElse",
																																							properties = {},
																																							attachments = {},
																																							children = {
																																								{
																																									node = {
																																										id = "228",
																																										class = "And",
																																										properties = {},
																																										attachments = {},
																																										children = {
																																											{
																																												node = {
																																													id = "74",
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
																																													id = "75",
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
																																											}
																																										}
																																									}
																																								},
																																								{
																																									node = {
																																										id = "218",
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
																																													id = "219",
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
																																																id = "304",
																																																class = "Sequence",
																																																properties = {},
																																																attachments = {},
																																																children = {
																																																	{
																																																		node = {
																																																			id = "431",
																																																			class = "Selector",
																																																			properties = {},
																																																			attachments = {},
																																																			children = {
																																																				{
																																																					node = {
																																																						id = "302",
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
																																																											field = "attackStopBoxDist"
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
																																																						id = "305",
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
																																																											field = "attackStopBoxDist"
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
																																																	},
																																																	{
																																																		node = {
																																																			id = "306",
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
																																																						const = 100
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
																																													id = "220",
																																													class = "DecoratorWeight",
																																													properties = {
																																														{
																																															DecorateWhenChildEnds = "false"
																																														},
																																														{
																																															Weight = {
																																																const = 60
																																															}
																																														}
																																													},
																																													attachments = {},
																																													children = {
																																														{
																																															node = {
																																																id = "109",
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
																																																					const = 2
																																																				},
																																																				{
																																																					const = 35
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
																																								},
																																								{
																																									node = {
																																										id = "330",
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
																																															const = 2
																																														},
																																														{
																																															const = 35
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

return ST_Monster_AutoCombat_Boss_10262
