-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\CombatUnit\\Monster\\Root\\Combat\\ST_Monster_AutoCombat_Boss_10503_BossRush.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local ST_Monster_AutoCombat_Boss_10503_BossRush = {
	behavior = {
		agenttype = "PuppetAgent",
		name = "CombatUnit/Monster/Root/Combat/ST_Monster_AutoCombat_Boss_10503_BossRush",
		version = 312,
		useForRoute = false,
		properties = {},
		pars = {
			{
				value = "200",
				type = "int",
				name = "tSkill_ComboAttack",
				const = 200
			},
			{
				value = "200",
				type = "int",
				name = "tSkill_15030110",
				const = 200
			},
			{
				value = "100",
				type = "int",
				name = "tSkill_15030111",
				const = 100
			},
			{
				value = "100",
				type = "int",
				name = "tSkill_15030112",
				const = 100
			},
			{
				value = "100",
				type = "int",
				name = "tSkill_15030113",
				const = 100
			},
			{
				value = "0",
				type = "float",
				name = "skillStopDist",
				const = 0
			},
			{
				value = "0",
				type = "int",
				name = "tPlayer",
				const = 0
			},
			{
				value = "100",
				type = "int",
				name = "tSkill_15030310",
				const = 100
			},
			{
				value = "200",
				type = "int",
				name = "tSkill_15030210",
				const = 200
			},
			{
				value = "0",
				type = "int",
				name = "TimerStarted_1",
				const = 0
			},
			{
				value = "0",
				type = "int",
				name = "tSkill_Rest",
				const = 0
			},
			{
				value = "0",
				type = "int",
				name = "tNewState",
				const = 0
			},
			{
				value = "0",
				type = "int",
				name = "tPreState",
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
						id = "699",
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
						id = "698",
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
						id = "564",
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
						id = "494",
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
											const = ""
										},
										{
											const = ""
										},
										{
											const = 0
										},
										{
											const = "0"
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
						id = "758",
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
				},
				{
					node = {
						id = "757",
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
												id = "732",
												class = "Selector",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "514",
															class = "Sequence",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		id = "548",
																		class = "Condition",
																		properties = {
																			{
																				Operator = "Greater"
																			},
																			{
																				Opl = {
																					func = "getTargetBuffLayerCount",
																					params = {
																						{},
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
																		id = "856",
																		class = "Condition",
																		properties = {
																			{
																				Operator = "Equal"
																			},
																			{
																				Opl = {
																					field = "tNewState"
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
																		id = "513",
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
																							const = 15030400
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
																		id = "851",
																		class = "Assignment",
																		properties = {
																			{
																				CastRight = "false"
																			},
																			{
																				Opl = {
																					field = "tNewState"
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
																		id = "850",
																		class = "Assignment",
																		properties = {
																			{
																				CastRight = "false"
																			},
																			{
																				Opl = {
																					field = "tPreState"
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
															id = "606",
															class = "Sequence",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		id = "604",
																		class = "Selector",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					id = "566",
																					class = "IfElse",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								id = "567",
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
																													const = 2150303
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
																								id = "763",
																								class = "Sequence",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											id = "600",
																											class = "Sequence",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "717",
																														class = "Selector",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	id = "602",
																																	class = "Sequence",
																																	properties = {},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				id = "716",
																																				class = "Condition",
																																				properties = {
																																					{
																																						Operator = "Equal"
																																					},
																																					{
																																						Opl = {
																																							field = "tNewState"
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
																																				id = "747",
																																				class = "Condition",
																																				properties = {
																																					{
																																						Operator = "Equal"
																																					},
																																					{
																																						Opl = {
																																							field = "tPreState"
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
																																				id = "801",
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
																																		},
																																		{
																																			node = {
																																				id = "855",
																																				class = "Sequence",
																																				properties = {},
																																				attachments = {},
																																				children = {
																																					{
																																						node = {
																																							id = "853",
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
																																												const = 15039910
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
																																							id = "854",
																																							class = "Action",
																																							properties = {
																																								{
																																									Method = {
																																										func = "startTimer",
																																										params = {
																																											{
																																												const = "15039910"
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
																																				id = "748",
																																				class = "Assignment",
																																				properties = {
																																					{
																																						CastRight = "false"
																																					},
																																					{
																																						Opl = {
																																							field = "tPreState"
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
																																	id = "730",
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
																														id = "572",
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
																																	id = "573",
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
																																				id = "769",
																																				class = "DecoratorAlwaysSuccess",
																																				properties = {
																																					{
																																						DecorateWhenChildEnds = "true"
																																					}
																																				},
																																				attachments = {},
																																				children = {
																																					{
																																						node = {
																																							id = "576",
																																							class = "Sequence",
																																							properties = {},
																																							attachments = {},
																																							children = {
																																								{
																																									node = {
																																										id = "577",
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
																																													const = 50
																																												}
																																											}
																																										},
																																										attachments = {},
																																										children = {}
																																									}
																																								},
																																								{
																																									node = {
																																										id = "569",
																																										class = "IfElse",
																																										properties = {},
																																										attachments = {},
																																										children = {
																																											{
																																												node = {
																																													id = "570",
																																													class = "Condition",
																																													properties = {
																																														{
																																															Operator = "GreaterEqual"
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
																																															Opr = {
																																																const = 6
																																															}
																																														}
																																													},
																																													attachments = {},
																																													children = {}
																																												}
																																											},
																																											{
																																												node = {
																																													id = "739",
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
																																																id = "740",
																																																class = "DecoratorWeight",
																																																properties = {
																																																	{
																																																		DecorateWhenChildEnds = "false"
																																																	},
																																																	{
																																																		Weight = {
																																																			const = 4
																																																		}
																																																	}
																																																},
																																																attachments = {},
																																																children = {
																																																	{
																																																		node = {
																																																			id = "582",
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
																																																								const = 10
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
																																																id = "741",
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
																																																			id = "789",
																																																			class = "Sequence",
																																																			properties = {},
																																																			attachments = {},
																																																			children = {
																																																				{
																																																					node = {
																																																						id = "737",
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
																																																											const = 15030600
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
																																																						id = "790",
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
																																																											const = 10
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
																																																	}
																																																}
																																															}
																																														}
																																													}
																																												}
																																											},
																																											{
																																												node = {
																																													id = "796",
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
																																																		const = 10
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
																																										id = "845",
																																										class = "Selector",
																																										properties = {},
																																										attachments = {},
																																										children = {
																																											{
																																												node = {
																																													id = "846",
																																													class = "Sequence",
																																													properties = {},
																																													attachments = {},
																																													children = {
																																														{
																																															node = {
																																																id = "847",
																																																class = "Condition",
																																																properties = {
																																																	{
																																																		Operator = "Greater"
																																																	},
																																																	{
																																																		Opl = {
																																																			func = "getTimerValue",
																																																			params = {
																																																				{
																																																					const = "15039910"
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
																																														},
																																														{
																																															node = {
																																																id = "848",
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
																																																					const = 15039910
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
																																																id = "849",
																																																class = "Action",
																																																properties = {
																																																	{
																																																		Method = {
																																																			func = "startTimer",
																																																			params = {
																																																				{
																																																					const = "15039910"
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
																																													id = "638",
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
																																																id = "631",
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
																																																			id = "710",
																																																			class = "Selector",
																																																			properties = {},
																																																			attachments = {},
																																																			children = {
																																																				{
																																																					node = {
																																																						id = "687",
																																																						class = "Sequence",
																																																						properties = {},
																																																						attachments = {},
																																																						children = {
																																																							{
																																																								node = {
																																																									id = "706",
																																																									class = "Sequence",
																																																									properties = {},
																																																									attachments = {},
																																																									children = {
																																																										{
																																																											node = {
																																																												id = "691",
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
																																																																	const = false
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
																																																									id = "815",
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
																																																						id = "711",
																																																						class = "True",
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
																																																id = "640",
																																																class = "DecoratorWeight",
																																																properties = {
																																																	{
																																																		DecorateWhenChildEnds = "false"
																																																	},
																																																	{
																																																		Weight = {
																																																			field = "tSkill_15030110"
																																																		}
																																																	}
																																																},
																																																attachments = {},
																																																children = {
																																																	{
																																																		node = {
																																																			id = "636",
																																																			class = "Sequence",
																																																			properties = {},
																																																			attachments = {},
																																																			children = {
																																																				{
																																																					node = {
																																																						id = "633",
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
																																																											const = 15030110
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
																																																						id = "695",
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
																																																									id = "697",
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
																																																												id = "669",
																																																												class = "Sequence",
																																																												properties = {},
																																																												attachments = {},
																																																												children = {
																																																													{
																																																														node = {
																																																															id = "632",
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
																																																																				const = 15030110
																																																																			},
																																																																			{
																																																																				const = true
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
																																																													},
																																																													{
																																																														node = {
																																																															id = "811",
																																																															class = "Sequence",
																																																															properties = {},
																																																															attachments = {
																																																																{
																																																																	id = "628",
																																																																	transition = false,
																																																																	effector = false,
																																																																	precondition = true,
																																																																	class = "Precondition",
																																																																	properties = {
																																																																		{
																																																																			BinaryOperator = "And"
																																																																		},
																																																																		{
																																																																			Operator = "LessEqual"
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
																																																																				const = 8
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
																																																																		id = "650",
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
																																																																					id = "667",
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
																																																																								id = "820",
																																																																								class = "Sequence",
																																																																								properties = {},
																																																																								attachments = {},
																																																																								children = {
																																																																									{
																																																																										node = {
																																																																											id = "670",
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
																																																																																const = 15030112
																																																																															},
																																																																															{
																																																																																const = true
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
																																																																									},
																																																																									{
																																																																										node = {
																																																																											id = "665",
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
																																																																																const = 15030113
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
																																																																											id = "819",
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
																																																																					id = "668",
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
																																																																								id = "862",
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
																																																																													const = 15030112
																																																																												},
																																																																												{
																																																																													const = true
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
																																																									id = "696",
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
																																																												id = "671",
																																																												class = "Sequence",
																																																												properties = {},
																																																												attachments = {},
																																																												children = {
																																																													{
																																																														node = {
																																																															id = "666",
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
																																																																				const = 15030111
																																																																			},
																																																																			{
																																																																				const = true
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
																																																													},
																																																													{
																																																														node = {
																																																															id = "812",
																																																															class = "Sequence",
																																																															properties = {},
																																																															attachments = {
																																																																{
																																																																	id = "628",
																																																																	transition = false,
																																																																	effector = false,
																																																																	precondition = true,
																																																																	class = "Precondition",
																																																																	properties = {
																																																																		{
																																																																			BinaryOperator = "And"
																																																																		},
																																																																		{
																																																																			Operator = "LessEqual"
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
																																																																				const = 8
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
																																																																		id = "675",
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
																																																																					id = "674",
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
																																																																								id = "826",
																																																																								class = "Sequence",
																																																																								properties = {},
																																																																								attachments = {},
																																																																								children = {
																																																																									{
																																																																										node = {
																																																																											id = "863",
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
																																																																																const = 15030112
																																																																															},
																																																																															{
																																																																																const = true
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
																																																																									},
																																																																									{
																																																																										node = {
																																																																											id = "676",
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
																																																																																const = 15030113
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
																																																																											id = "825",
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
																																																																					id = "673",
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
																																																																								id = "864",
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
																																																																													const = 15030112
																																																																												},
																																																																												{
																																																																													const = true
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
																																														},
																																														{
																																															node = {
																																																id = "648",
																																																class = "DecoratorWeight",
																																																properties = {
																																																	{
																																																		DecorateWhenChildEnds = "false"
																																																	},
																																																	{
																																																		Weight = {
																																																			field = "tSkill_15030210"
																																																		}
																																																	}
																																																},
																																																attachments = {},
																																																children = {
																																																	{
																																																		node = {
																																																			id = "646",
																																																			class = "Sequence",
																																																			properties = {},
																																																			attachments = {},
																																																			children = {
																																																				{
																																																					node = {
																																																						id = "642",
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
																																																											const = 15030210
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
																																																						id = "898",
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
																																																									id = "897",
																																																									class = "DecoratorWeight",
																																																									properties = {
																																																										{
																																																											DecorateWhenChildEnds = "false"
																																																										},
																																																										{
																																																											Weight = {
																																																												const = 2
																																																											}
																																																										}
																																																									},
																																																									attachments = {},
																																																									children = {
																																																										{
																																																											node = {
																																																												id = "902",
																																																												class = "Sequence",
																																																												properties = {},
																																																												attachments = {},
																																																												children = {
																																																													{
																																																														node = {
																																																															id = "901",
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
																																																																				const = 15030210
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
																																																													},
																																																													{
																																																														node = {
																																																															id = "904",
																																																															class = "Sequence",
																																																															properties = {},
																																																															attachments = {
																																																																{
																																																																	id = "628",
																																																																	transition = false,
																																																																	effector = false,
																																																																	precondition = true,
																																																																	class = "Precondition",
																																																																	properties = {
																																																																		{
																																																																			BinaryOperator = "And"
																																																																		},
																																																																		{
																																																																			Operator = "LessEqual"
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
																																																																				const = 8
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
																																																																		id = "900",
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
																																																																							const = 15030310
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
																																																																		id = "903",
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
																																																							},
																																																							{
																																																								node = {
																																																									id = "899",
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
																																																												id = "896",
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
																																																																	const = 15030210
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
																																																				}
																																																			}
																																																		}
																																																	}
																																																}
																																															}
																																														},
																																														{
																																															node = {
																																																id = "659",
																																																class = "DecoratorWeight",
																																																properties = {
																																																	{
																																																		DecorateWhenChildEnds = "false"
																																																	},
																																																	{
																																																		Weight = {
																																																			field = "tSkill_15030310"
																																																		}
																																																	}
																																																},
																																																attachments = {},
																																																children = {
																																																	{
																																																		node = {
																																																			id = "664",
																																																			class = "Sequence",
																																																			properties = {},
																																																			attachments = {},
																																																			children = {
																																																				{
																																																					node = {
																																																						id = "649",
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
																																																											const = 15030310
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
																																																						id = "663",
																																																						class = "IfElse",
																																																						properties = {},
																																																						attachments = {},
																																																						children = {
																																																							{
																																																								node = {
																																																									id = "658",
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
																																																														const = 15030310
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
																																																									id = "662",
																																																									class = "Sequence",
																																																									properties = {},
																																																									attachments = {},
																																																									children = {
																																																										{
																																																											node = {
																																																												id = "657",
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
																																																																	const = 15030310
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
																																																									id = "661",
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
																																																						id = "655",
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
																																																											const = 15030310
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
																																	id = "575",
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
																																				id = "574",
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
																												}
																											}
																										}
																									}
																								}
																							}
																						},
																						{
																							node = {
																								id = "766",
																								class = "Sequence",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											id = "622",
																											class = "Sequence",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "729",
																														class = "Selector",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	id = "749",
																																	class = "Sequence",
																																	properties = {},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				id = "752",
																																				class = "Condition",
																																				properties = {
																																					{
																																						Operator = "Equal"
																																					},
																																					{
																																						Opl = {
																																							field = "tNewState"
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
																																				id = "805",
																																				class = "Condition",
																																				properties = {
																																					{
																																						Operator = "Equal"
																																					},
																																					{
																																						Opl = {
																																							field = "tPreState"
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
																																				id = "802",
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
																																		},
																																		{
																																			node = {
																																				id = "754",
																																				class = "Assignment",
																																				properties = {
																																					{
																																						CastRight = "false"
																																					},
																																					{
																																						Opl = {
																																							field = "tPreState"
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
																																	id = "731",
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
																																				id = "768",
																																				class = "DecoratorAlwaysSuccess",
																																				properties = {
																																					{
																																						DecorateWhenChildEnds = "true"
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
																																										id = "507",
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
																																										id = "9",
																																										class = "IfElse",
																																										properties = {},
																																										attachments = {},
																																										children = {
																																											{
																																												node = {
																																													id = "794",
																																													class = "Condition",
																																													properties = {
																																														{
																																															Operator = "GreaterEqual"
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
																																															Opr = {
																																																const = 6
																																															}
																																														}
																																													},
																																													attachments = {},
																																													children = {}
																																												}
																																											},
																																											{
																																												node = {
																																													id = "791",
																																													class = "Sequence",
																																													properties = {},
																																													attachments = {
																																														{
																																															id = "810",
																																															transition = false,
																																															effector = false,
																																															precondition = true,
																																															class = "Precondition",
																																															properties = {
																																																{
																																																	BinaryOperator = "And"
																																																},
																																																{
																																																	Operator = "LessEqual"
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
																																																	Opr2 = {
																																																		const = 2
																																																	}
																																																},
																																																{
																																																	Phase = "Update"
																																																}
																																															}
																																														}
																																													},
																																													children = {
																																														{
																																															node = {
																																																id = "793",
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
																																																					const = 15030600
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
																																																id = "792",
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
																																																					const = 10
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
																																													id = "795",
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
																																																		const = 10
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
																																										id = "156",
																																										class = "SelectorProbability",
																																										properties = {
																																											{
																																												UntilSuccessOrEnd = false
																																											}
																																										},
																																										attachments = {
																																											{
																																												id = "807",
																																												transition = false,
																																												effector = false,
																																												precondition = true,
																																												class = "Precondition",
																																												properties = {
																																													{
																																														BinaryOperator = "And"
																																													},
																																													{
																																														Operator = "LessEqual"
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
																																														Opr2 = {
																																															const = 2
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
																																																id = "713",
																																																class = "Selector",
																																																properties = {},
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
																																																						id = "707",
																																																						class = "Sequence",
																																																						properties = {},
																																																						attachments = {},
																																																						children = {
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
																																																														const = false
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
																																																						id = "816",
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
																																																						id = "498",
																																																						class = "Compute",
																																																						properties = {
																																																							{
																																																								Operator = "Add"
																																																							},
																																																							{
																																																								Opl = {
																																																									field = "tSkill_Rest"
																																																								}
																																																							},
																																																							{
																																																								Opr1 = {
																																																									field = "tSkill_Rest"
																																																								}
																																																							},
																																																							{
																																																								Opr2 = {
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
																																																			id = "714",
																																																			class = "True",
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
																																													id = "868",
																																													class = "DecoratorWeight",
																																													properties = {
																																														{
																																															DecorateWhenChildEnds = "false"
																																														},
																																														{
																																															Weight = {
																																																field = "tSkill_15030110"
																																															}
																																														}
																																													},
																																													attachments = {},
																																													children = {
																																														{
																																															node = {
																																																id = "866",
																																																class = "Sequence",
																																																properties = {},
																																																attachments = {},
																																																children = {
																																																	{
																																																		node = {
																																																			id = "867",
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
																																																								const = 15030110
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
																																																			id = "879",
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
																																																						id = "881",
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
																																																									id = "875",
																																																									class = "Sequence",
																																																									properties = {},
																																																									attachments = {},
																																																									children = {
																																																										{
																																																											node = {
																																																												id = "865",
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
																																																																	const = 15030110
																																																																},
																																																																{
																																																																	const = true
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
																																																										},
																																																										{
																																																											node = {
																																																												id = "893",
																																																												class = "Sequence",
																																																												properties = {},
																																																												attachments = {
																																																													{
																																																														id = "628",
																																																														transition = false,
																																																														effector = false,
																																																														precondition = true,
																																																														class = "Precondition",
																																																														properties = {
																																																															{
																																																																BinaryOperator = "And"
																																																															},
																																																															{
																																																																Operator = "LessEqual"
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
																																																																	const = 8
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
																																																															id = "870",
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
																																																																		id = "873",
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
																																																																					id = "883",
																																																																					class = "Sequence",
																																																																					properties = {},
																																																																					attachments = {},
																																																																					children = {
																																																																						{
																																																																							node = {
																																																																								id = "886",
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
																																																																													const = 15030112
																																																																												},
																																																																												{
																																																																													const = true
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
																																																																						},
																																																																						{
																																																																							node = {
																																																																								id = "871",
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
																																																																													const = 15030113
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
																																																																								id = "882",
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
																																																																		id = "874",
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
																																																																					id = "887",
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
																																																																										const = 15030112
																																																																									},
																																																																									{
																																																																										const = true
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
																																																						id = "880",
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
																																																									id = "876",
																																																									class = "Sequence",
																																																									properties = {},
																																																									attachments = {},
																																																									children = {
																																																										{
																																																											node = {
																																																												id = "872",
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
																																																																	const = 15030111
																																																																},
																																																																{
																																																																	const = true
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
																																																										},
																																																										{
																																																											node = {
																																																												id = "892",
																																																												class = "Sequence",
																																																												properties = {},
																																																												attachments = {
																																																													{
																																																														id = "628",
																																																														transition = false,
																																																														effector = false,
																																																														precondition = true,
																																																														class = "Precondition",
																																																														properties = {
																																																															{
																																																																BinaryOperator = "And"
																																																															},
																																																															{
																																																																Operator = "LessEqual"
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
																																																																	const = 8
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
																																																															id = "891",
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
																																																																		id = "878",
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
																																																																					id = "885",
																																																																					class = "Sequence",
																																																																					properties = {},
																																																																					attachments = {},
																																																																					children = {
																																																																						{
																																																																							node = {
																																																																								id = "890",
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
																																																																													const = 15030112
																																																																												},
																																																																												{
																																																																													const = true
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
																																																																						},
																																																																						{
																																																																							node = {
																																																																								id = "889",
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
																																																																													const = 15030113
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
																																																																								id = "884",
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
																																																																		id = "877",
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
																																																																					id = "888",
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
																																																																										const = 15030112
																																																																									},
																																																																									{
																																																																										const = true
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
																																																			id = "894",
																																																			class = "Compute",
																																																			properties = {
																																																				{
																																																					Operator = "Add"
																																																				},
																																																				{
																																																					Opl = {
																																																						field = "tSkill_Rest"
																																																					}
																																																				},
																																																				{
																																																					Opr1 = {
																																																						field = "tSkill_Rest"
																																																					}
																																																				},
																																																				{
																																																					Opr2 = {
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
																																																field = "tSkill_15030210"
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
																																																								const = 15030210
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
																																																			id = "907",
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
																																																						id = "911",
																																																						class = "DecoratorWeight",
																																																						properties = {
																																																							{
																																																								DecorateWhenChildEnds = "false"
																																																							},
																																																							{
																																																								Weight = {
																																																									const = 2
																																																								}
																																																							}
																																																						},
																																																						attachments = {},
																																																						children = {
																																																							{
																																																								node = {
																																																									id = "906",
																																																									class = "Sequence",
																																																									properties = {},
																																																									attachments = {},
																																																									children = {
																																																										{
																																																											node = {
																																																												id = "914",
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
																																																																	const = 15030210
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
																																																										},
																																																										{
																																																											node = {
																																																												id = "912",
																																																												class = "Sequence",
																																																												properties = {},
																																																												attachments = {
																																																													{
																																																														id = "628",
																																																														transition = false,
																																																														effector = false,
																																																														precondition = true,
																																																														class = "Precondition",
																																																														properties = {
																																																															{
																																																																BinaryOperator = "And"
																																																															},
																																																															{
																																																																Operator = "LessEqual"
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
																																																																	const = 8
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
																																																															id = "909",
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
																																																																				const = 15030310
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
																																																															id = "910",
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
																																																				},
																																																				{
																																																					node = {
																																																						id = "905",
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
																																																									id = "913",
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
																																																														const = 15030210
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
																																																			id = "500",
																																																			class = "Compute",
																																																			properties = {
																																																				{
																																																					Operator = "Add"
																																																				},
																																																				{
																																																					Opl = {
																																																						field = "tSkill_Rest"
																																																					}
																																																				},
																																																				{
																																																					Opr1 = {
																																																						field = "tSkill_Rest"
																																																					}
																																																				},
																																																				{
																																																					Opr2 = {
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
																																														}
																																													}
																																												}
																																											},
																																											{
																																												node = {
																																													id = "453",
																																													class = "DecoratorWeight",
																																													properties = {
																																														{
																																															DecorateWhenChildEnds = "false"
																																														},
																																														{
																																															Weight = {
																																																field = "tSkill_15030310"
																																															}
																																														}
																																													},
																																													attachments = {},
																																													children = {
																																														{
																																															node = {
																																																id = "449",
																																																class = "Sequence",
																																																properties = {},
																																																attachments = {},
																																																children = {
																																																	{
																																																		node = {
																																																			id = "454",
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
																																																								const = 15030310
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
																																																			id = "458",
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
																																																								const = 15030310
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
																																																			id = "501",
																																																			class = "Compute",
																																																			properties = {
																																																				{
																																																					Operator = "Add"
																																																				},
																																																				{
																																																					Opl = {
																																																						field = "tSkill_Rest"
																																																					}
																																																				},
																																																				{
																																																					Opr1 = {
																																																						field = "tSkill_Rest"
																																																					}
																																																				},
																																																				{
																																																					Opr2 = {
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
																					id = "609",
																					class = "Selector",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								id = "774",
																								class = "Sequence",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											id = "775",
																											class = "Sequence",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "776",
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
																											id = "780",
																											class = "IfElse",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "787",
																														class = "And",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	id = "778",
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
																																	id = "915",
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
																																				const = 1.5
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
																														id = "783",
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
																																	id = "784",
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
																																				id = "779",
																																				class = "Sequence",
																																				properties = {},
																																				attachments = {},
																																				children = {
																																					{
																																						node = {
																																							id = "788",
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
																																												const = 4
																																											},
																																											{
																																												const = 4
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
																																					},
																																					{
																																						node = {
																																							id = "777",
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
																																	id = "808",
																																	class = "DecoratorWeight",
																																	properties = {
																																		{
																																			DecorateWhenChildEnds = "false"
																																		},
																																		{
																																			Weight = {
																																				const = 40
																																			}
																																		}
																																	},
																																	attachments = {
																																		{
																																			id = "809",
																																			transition = false,
																																			effector = false,
																																			precondition = true,
																																			class = "Precondition",
																																			properties = {
																																				{
																																					BinaryOperator = "And"
																																				},
																																				{
																																					Operator = "Less"
																																				},
																																				{
																																					Opl = {
																																						func = "getTargetBuffLayerCount",
																																						params = {
																																							{
																																								field = "selfId"
																																							},
																																							{
																																								const = 2150303
																																							}
																																						}
																																					}
																																				},
																																				{
																																					Opr2 = {
																																						const = 1
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
																																				id = "495",
																																				class = "Sequence",
																																				properties = {},
																																				attachments = {},
																																				children = {
																																					{
																																						node = {
																																							id = "496",
																																							class = "Assignment",
																																							properties = {
																																								{
																																									CastRight = "false"
																																								},
																																								{
																																									Opl = {
																																										field = "tSkill_Rest"
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
																																							id = "508",
																																							class = "IfElse",
																																							properties = {},
																																							attachments = {},
																																							children = {
																																								{
																																									node = {
																																										id = "541",
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
																																															const = 2150102
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
																																										id = "510",
																																										class = "True",
																																										properties = {},
																																										attachments = {},
																																										children = {}
																																									}
																																								},
																																								{
																																									node = {
																																										id = "817",
																																										class = "Sequence",
																																										properties = {},
																																										attachments = {},
																																										children = {
																																											{
																																												node = {
																																													id = "818",
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
																																													id = "486",
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
																																																		const = ""
																																																	},
																																																	{
																																																		const = ""
																																																	},
																																																	{
																																																		const = 2
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
																														id = "786",
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
																																			const = 3.5
																																		},
																																		{
																																			const = 45
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
																								id = "610",
																								class = "True",
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
								}
							}
						}
					}
				}
			}
		}
	}
}

return ST_Monster_AutoCombat_Boss_10503_BossRush
