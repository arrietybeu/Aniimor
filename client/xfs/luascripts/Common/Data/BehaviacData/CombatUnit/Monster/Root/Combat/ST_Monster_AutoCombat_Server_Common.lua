-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\CombatUnit\\Monster\\Root\\Combat\\ST_Monster_AutoCombat_Server_Common.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local ST_Monster_AutoCombat_Server_Common = {
	behavior = {
		useForRoute = false,
		name = "CombatUnit/Monster/Root/Combat/ST_Monster_AutoCombat_Server_Common",
		agenttype = "PuppetAgent",
		version = 106,
		properties = {},
		pars = {
			{
				name = "CurrentDistToTarget",
				type = "float",
				value = "0",
				const = 0
			},
			{
				name = "CurrentBoxDistToTarget",
				type = "float",
				value = "0",
				const = 0
			},
			{
				name = "goBackDist",
				type = "float",
				value = "0",
				const = 0
			},
			{
				name = "skillStopDist",
				type = "float",
				value = "0",
				const = 0
			},
			{
				name = "tWeight_Group_SideWalk",
				type = "int",
				value = "100",
				const = 100
			},
			{
				name = "tWeight_Group_Wait",
				type = "int",
				value = "100",
				const = 100
			},
			{
				name = "tWeight_Group_Angry",
				type = "int",
				value = "100",
				const = 100
			},
			{
				name = "tSkillRecoverCount",
				type = "int",
				value = "0",
				const = 0
			},
			{
				name = "CurrentHpPercent",
				type = "float",
				value = "0",
				const = 0
			},
			{
				name = "tSkillBuffCount",
				type = "int",
				value = "0",
				const = 0
			},
			{
				name = "tSkillControlCount",
				type = "int",
				value = "0",
				const = 0
			},
			{
				name = "tSkillFar",
				type = "float",
				value = "0",
				const = 0
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
						id = "212",
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
				},
				{
					node = {
						id = "217",
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
						id = "385",
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
						id = "425",
						class = "Action",
						properties = {
							{
								Method = {
									func = "startTimer",
									params = {
										{
											const = "goBackCd"
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
									id = "171",
									class = "Sequence",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "355",
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
															id = "356",
															class = "Assignment",
															properties = {
																{
																	CastRight = "false"
																},
																{
																	Opl = {
																		field = "CurrentHpPercent"
																	}
																},
																{
																	Opr = {
																		func = "getHpPercent",
																		params = {
																			{
																				field = "selfId"
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
															id = "406",
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
												id = "172",
												class = "IfElse",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "169",
															class = "Condition",
															properties = {
																{
																	Operator = "Equal"
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
															id = "416",
															class = "Sequence",
															properties = {},
															attachments = {
																{
																	transition = false,
																	effector = false,
																	precondition = true,
																	id = "417",
																	class = "Precondition",
																	properties = {
																		{
																			BinaryOperator = "And"
																		},
																		{
																			Operator = "NotEqual"
																		},
																		{
																			Opl = {
																				func = "getTarget"
																			}
																		},
																		{
																			Opr2 = {
																				const = 0
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
																		id = "424",
																		class = "DecoratorLoop",
																		properties = {
																			{
																				Count = {
																					const = -1
																				}
																			},
																			{
																				DecorateWhenChildEnds = "false"
																			},
																			{
																				DoneWithinFrame = "false"
																			}
																		},
																		attachments = {},
																		children = {
																			{
																				node = {
																					id = "422",
																					class = "Action",
																					properties = {
																						{
																							Method = {
																								func = "patrolInRange",
																								params = {
																									{
																										const = 3
																									},
																									{
																										const = BaseEnum.SpeedRateType.Slow
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
																}
															}
														}
													},
													{
														node = {
															id = "167",
															class = "IfElse",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		id = "165",
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
																		id = "166",
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
																},
																{
																	node = {
																		id = "313",
																		class = "IfElse",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					id = "314",
																					class = "Condition",
																					properties = {
																						{
																							Operator = "Equal"
																						},
																						{
																							Opl = {
																								func = "checkCharacterState",
																								params = {
																									{
																										const = "MIMICRY"
																									},
																									{}
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
																					id = "312",
																					class = "Action",
																					properties = {
																						{
																							Method = {
																								func = "switchToState",
																								params = {
																									{
																										const = "MIMICRYOUT"
																									},
																									{
																										const = 5
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
																					id = "317",
																					class = "IfElse",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								id = "318",
																								class = "Condition",
																								properties = {
																									{
																										Operator = "Equal"
																									},
																									{
																										Opl = {
																											func = "checkCharacterState",
																											params = {
																												{
																													const = "SWIMMIMICRY"
																												},
																												{}
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
																								id = "316",
																								class = "Action",
																								properties = {
																									{
																										Method = {
																											func = "switchToState",
																											params = {
																												{
																													const = "SWIMMIMICRYOUT"
																												},
																												{
																													const = 5
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
																								id = "216",
																								class = "Sequence",
																								properties = {},
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
																														id = "6",
																														class = "Assignment",
																														properties = {
																															{
																																CastRight = "false"
																															},
																															{
																																Opl = {
																																	field = "CurrentDistToTarget"
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
																														id = "188",
																														class = "Assignment",
																														properties = {
																															{
																																CastRight = "false"
																															},
																															{
																																Opl = {
																																	field = "CurrentBoxDistToTarget"
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
																												}
																											}
																										}
																									},
																									{
																										node = {
																											id = "229",
																											class = "IfElse",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "234",
																														class = "Condition",
																														properties = {
																															{
																																Operator = "Equal"
																															},
																															{
																																Opl = {
																																	func = "checkCharacterState",
																																	params = {
																																		{
																																			const = "SWIMMING"
																																		},
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
																														id = "297",
																														class = "Sequence",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	id = "296",
																																	class = "Action",
																																	properties = {
																																		{
																																			Method = {
																																				func = "calcQualifiedPosByTarget",
																																				params = {
																																					{
																																						field = "tgt"
																																					},
																																					{
																																						const = 0
																																					},
																																					{
																																						field = "maxAttackDist"
																																					},
																																					{
																																						const = BaseEnum.CalcQualifiedPosQueryType.EightCompassDirections
																																					},
																																					{
																																						const = 2
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
																																	id = "298",
																																	class = "Action",
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
																																						const = 1
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
																														id = "150",
																														class = "IfElse",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	id = "311",
																																	class = "Sequence",
																																	properties = {},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				id = "151",
																																				class = "Condition",
																																				properties = {
																																					{
																																						Operator = "Equal"
																																					},
																																					{
																																						Opl = {
																																							func = "checkCanMoveToTarget",
																																							params = {
																																								{
																																									field = "tgt"
																																								},
																																								{
																																									field = "attackStopBoxDist"
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
																																				id = "310",
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
																																	id = "468",
																																	class = "Sequence",
																																	properties = {},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				id = "469",
																																				class = "Condition",
																																				properties = {
																																					{
																																						Operator = "Equal"
																																					},
																																					{
																																						Opl = {
																																							func = "checkTargetBlocked",
																																							params = {
																																								{
																																									field = "selfId"
																																								},
																																								{
																																									field = "tgt"
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
																																				id = "462",
																																				class = "IfElse",
																																				properties = {},
																																				attachments = {},
																																				children = {
																																					{
																																						node = {
																																							id = "470",
																																							class = "And",
																																							properties = {},
																																							attachments = {},
																																							children = {
																																								{
																																									node = {
																																										id = "465",
																																										class = "Condition",
																																										properties = {
																																											{
																																												Operator = "GreaterEqual"
																																											},
																																											{
																																												Opl = {
																																													func = "getVerticalDis",
																																													params = {
																																														{
																																															field = "selfId"
																																														},
																																														{
																																															field = "tgt"
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
																																										id = "471",
																																										class = "Condition",
																																										properties = {
																																											{
																																												Operator = "LessEqual"
																																											},
																																											{
																																												Opl = {
																																													func = "getVerticalDis",
																																													params = {
																																														{
																																															field = "selfId"
																																														},
																																														{
																																															field = "tgt"
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
																																								}
																																							}
																																						}
																																					},
																																					{
																																						node = {
																																							id = "463",
																																							class = "Sequence",
																																							properties = {},
																																							attachments = {},
																																							children = {
																																								{
																																									node = {
																																										id = "474",
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
																																															const = 1
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
																																															const = BaseEnum.MoveUpdateLevel.Slow
																																														},
																																														{
																																															const = BaseEnum.PathFindType.Voxel
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
																																										id = "472",
																																										class = "Action",
																																										properties = {
																																											{
																																												Method = {
																																													func = "playJumpAction",
																																													params = {
																																														{
																																															const = "Jump"
																																														},
																																														{
																																															const = 5
																																														},
																																														{
																																															const = 0
																																														},
																																														{
																																															const = 3
																																														},
																																														{
																																															const = BaseEnum.RootMotionSyncPointEnum.AICustomPoint1
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
																																							id = "473",
																																							class = "IfElse",
																																							properties = {},
																																							attachments = {},
																																							children = {
																																								{
																																									node = {
																																										id = "476",
																																										class = "And",
																																										properties = {},
																																										attachments = {},
																																										children = {
																																											{
																																												node = {
																																													id = "464",
																																													class = "Condition",
																																													properties = {
																																														{
																																															Operator = "LessEqual"
																																														},
																																														{
																																															Opl = {
																																																func = "getVerticalDis",
																																																params = {
																																																	{
																																																		field = "selfId"
																																																	},
																																																	{
																																																		field = "tgt"
																																																	}
																																																}
																																															}
																																														},
																																														{
																																															Opr = {
																																																const = -0.5
																																															}
																																														}
																																													},
																																													attachments = {},
																																													children = {}
																																												}
																																											},
																																											{
																																												node = {
																																													id = "487",
																																													class = "Condition",
																																													properties = {
																																														{
																																															Operator = "GreaterEqual"
																																														},
																																														{
																																															Opl = {
																																																func = "getVerticalDis",
																																																params = {
																																																	{
																																																		field = "selfId"
																																																	},
																																																	{
																																																		field = "tgt"
																																																	}
																																																}
																																															}
																																														},
																																														{
																																															Opr = {
																																																const = -2.75
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
																																										id = "488",
																																										class = "IfElse",
																																										properties = {},
																																										attachments = {},
																																										children = {
																																											{
																																												node = {
																																													id = "475",
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
																																													id = "481",
																																													class = "Sequence",
																																													properties = {},
																																													attachments = {},
																																													children = {
																																														{
																																															node = {
																																																id = "479",
																																																class = "Action",
																																																properties = {
																																																	{
																																																		Method = {
																																																			func = "switchToFly",
																																																			params = {
																																																				{
																																																					const = 4.5
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
																																																		ResultResumeOption = "BT_ResumeSelf"
																																																	}
																																																},
																																																attachments = {},
																																																children = {}
																																															}
																																														},
																																														{
																																															node = {
																																																id = "477",
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
																																																					const = 1
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
																																																					const = BaseEnum.MoveUpdateLevel.Slow
																																																				},
																																																				{
																																																					const = BaseEnum.PathFindType.AirNav
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
																																																		ResultOption = "BT_SUCCESS"
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
																																																id = "480",
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
																																																					const = 5
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
																																											},
																																											{
																																												node = {
																																													id = "489",
																																													class = "Sequence",
																																													properties = {},
																																													attachments = {},
																																													children = {
																																														{
																																															node = {
																																																id = "492",
																																																class = "Condition",
																																																properties = {
																																																	{
																																																		Operator = "GreaterEqual"
																																																	},
																																																	{
																																																		Opl = {
																																																			func = "getVerticalDis",
																																																			params = {
																																																				{
																																																					field = "selfId"
																																																				},
																																																				{
																																																					field = "tgt"
																																																				}
																																																			}
																																																		}
																																																	},
																																																	{
																																																		Opr = {
																																																			const = -1.5
																																																		}
																																																	}
																																																},
																																																attachments = {},
																																																children = {}
																																															}
																																														},
																																														{
																																															node = {
																																																id = "491",
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
																																																					const = 1
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
																																																					const = BaseEnum.MoveUpdateLevel.Slow
																																																				},
																																																				{
																																																					const = BaseEnum.PathFindType.Voxel
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
																																																id = "490",
																																																class = "Action",
																																																properties = {
																																																	{
																																																		Method = {
																																																			func = "playJumpAction",
																																																			params = {
																																																				{
																																																					const = "Jump"
																																																				},
																																																				{
																																																					const = 5
																																																				},
																																																				{
																																																					const = 0
																																																				},
																																																				{
																																																					const = 3
																																																				},
																																																				{
																																																					const = BaseEnum.RootMotionSyncPointEnum.AICustomPoint1
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
																																										id = "478",
																																										class = "Selector",
																																										properties = {},
																																										attachments = {},
																																										children = {
																																											{
																																												node = {
																																													id = "467",
																																													class = "Sequence",
																																													properties = {},
																																													attachments = {},
																																													children = {
																																														{
																																															node = {
																																																id = "486",
																																																class = "Action",
																																																properties = {
																																																	{
																																																		Method = {
																																																			func = "calcQualifiedPosByTarget",
																																																			params = {
																																																				{
																																																					field = "selfId"
																																																				},
																																																				{
																																																					const = 0
																																																				},
																																																				{
																																																					field = "CurrentBoxDistToTarget"
																																																				},
																																																				{
																																																					const = BaseEnum.CalcQualifiedPosQueryType.EightCompassDirections
																																																				},
																																																				{
																																																					const = 4
																																																				},
																																																				{
																																																					field = "tgt"
																																																				},
																																																				{
																																																					const = true
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
																																																id = "466",
																																																class = "Action",
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
																																													id = "482",
																																													class = "IfElse",
																																													properties = {},
																																													attachments = {},
																																													children = {
																																														{
																																															node = {
																																																id = "484",
																																																class = "Condition",
																																																properties = {
																																																	{
																																																		Operator = "Equal"
																																																	},
																																																	{
																																																		Opl = {
																																																			func = "checkCanMoveToTarget",
																																																			params = {
																																																				{
																																																					field = "tgt"
																																																				},
																																																				{
																																																					field = "attackStopBoxDist"
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
																																																id = "483",
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
																																																					const = 0.5
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
																																																					const = BaseEnum.PathFindType.Voxel
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
																																																		ResultOption = "BT_SUCCESS"
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
																																																id = "485",
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
																																																		ResultOption = "BT_SUCCESS"
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
																																							field = "CurrentBoxDistToTarget"
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
																																									const = 99
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
																																									const = 8
																																								},
																																								{
																																									const = BaseEnum.MoveUpdateLevel.Fast
																																								},
																																								{
																																									const = BaseEnum.PathFindType.Auto
																																								},
																																								{
																																									const = BaseEnum.SpeedRateType.Burst
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
																																				id = "194",
																																				class = "IfElse",
																																				properties = {},
																																				attachments = {},
																																				children = {
																																					{
																																						node = {
																																							id = "426",
																																							class = "True",
																																							properties = {},
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
																																																id = "289",
																																																class = "Selector",
																																																properties = {},
																																																attachments = {},
																																																children = {
																																																	{
																																																		node = {
																																																			id = "291",
																																																			class = "Sequence",
																																																			properties = {},
																																																			attachments = {},
																																																			children = {
																																																				{
																																																					node = {
																																																						id = "252",
																																																						class = "Sequence",
																																																						properties = {},
																																																						attachments = {},
																																																						children = {
																																																							{
																																																								node = {
																																																									id = "251",
																																																									class = "Condition",
																																																									properties = {
																																																										{
																																																											Operator = "Equal"
																																																										},
																																																										{
																																																											Opl = {
																																																												func = "checkTargetBlocked",
																																																												params = {
																																																													{
																																																														field = "selfId"
																																																													},
																																																													{
																																																														field = "tgt"
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
																																																									id = "260",
																																																									class = "IfElse",
																																																									properties = {},
																																																									attachments = {},
																																																									children = {
																																																										{
																																																											node = {
																																																												id = "261",
																																																												class = "And",
																																																												properties = {},
																																																												attachments = {},
																																																												children = {
																																																													{
																																																														node = {
																																																															id = "257",
																																																															class = "Condition",
																																																															properties = {
																																																																{
																																																																	Operator = "GreaterEqual"
																																																																},
																																																																{
																																																																	Opl = {
																																																																		func = "getVerticalDis",
																																																																		params = {
																																																																			{
																																																																				field = "selfId"
																																																																			},
																																																																			{
																																																																				field = "tgt"
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
																																																															id = "262",
																																																															class = "Condition",
																																																															properties = {
																																																																{
																																																																	Operator = "LessEqual"
																																																																},
																																																																{
																																																																	Opl = {
																																																																		func = "getVerticalDis",
																																																																		params = {
																																																																			{
																																																																				field = "selfId"
																																																																			},
																																																																			{
																																																																				field = "tgt"
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
																																																													}
																																																												}
																																																											}
																																																										},
																																																										{
																																																											node = {
																																																												id = "259",
																																																												class = "Sequence",
																																																												properties = {},
																																																												attachments = {},
																																																												children = {
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
																																																																				const = 1
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
																																																																				const = BaseEnum.MoveUpdateLevel.Slow
																																																																			},
																																																																			{
																																																																				const = BaseEnum.PathFindType.Voxel
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
																																																															id = "263",
																																																															class = "Action",
																																																															properties = {
																																																																{
																																																																	Method = {
																																																																		func = "playJumpAction",
																																																																		params = {
																																																																			{
																																																																				const = "Jump"
																																																																			},
																																																																			{
																																																																				const = 5
																																																																			},
																																																																			{
																																																																				const = 0
																																																																			},
																																																																			{
																																																																				const = 3
																																																																			},
																																																																			{
																																																																				const = BaseEnum.RootMotionSyncPointEnum.AICustomPoint1
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
																																																												id = "264",
																																																												class = "IfElse",
																																																												properties = {},
																																																												attachments = {},
																																																												children = {
																																																													{
																																																														node = {
																																																															id = "267",
																																																															class = "And",
																																																															properties = {},
																																																															attachments = {},
																																																															children = {
																																																																{
																																																																	node = {
																																																																		id = "258",
																																																																		class = "Condition",
																																																																		properties = {
																																																																			{
																																																																				Operator = "LessEqual"
																																																																			},
																																																																			{
																																																																				Opl = {
																																																																					func = "getVerticalDis",
																																																																					params = {
																																																																						{
																																																																							field = "selfId"
																																																																						},
																																																																						{
																																																																							field = "tgt"
																																																																						}
																																																																					}
																																																																				}
																																																																			},
																																																																			{
																																																																				Opr = {
																																																																					const = -0.5
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
																																																																		class = "Condition",
																																																																		properties = {
																																																																			{
																																																																				Operator = "GreaterEqual"
																																																																			},
																																																																			{
																																																																				Opl = {
																																																																					func = "getVerticalDis",
																																																																					params = {
																																																																						{
																																																																							field = "selfId"
																																																																						},
																																																																						{
																																																																							field = "tgt"
																																																																						}
																																																																					}
																																																																				}
																																																																			},
																																																																			{
																																																																				Opr = {
																																																																					const = -2.75
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
																																																															id = "284",
																																																															class = "IfElse",
																																																															properties = {},
																																																															attachments = {},
																																																															children = {
																																																																{
																																																																	node = {
																																																																		id = "266",
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
																																																																		id = "272",
																																																																		class = "Sequence",
																																																																		properties = {},
																																																																		attachments = {},
																																																																		children = {
																																																																			{
																																																																				node = {
																																																																					id = "270",
																																																																					class = "Action",
																																																																					properties = {
																																																																						{
																																																																							Method = {
																																																																								func = "switchToFly",
																																																																								params = {
																																																																									{
																																																																										const = 4.5
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
																																																																							ResultResumeOption = "BT_ResumeSelf"
																																																																						}
																																																																					},
																																																																					attachments = {},
																																																																					children = {}
																																																																				}
																																																																			},
																																																																			{
																																																																				node = {
																																																																					id = "268",
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
																																																																										const = 1
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
																																																																										const = BaseEnum.MoveUpdateLevel.Slow
																																																																									},
																																																																									{
																																																																										const = BaseEnum.PathFindType.AirNav
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
																																																																							ResultOption = "BT_SUCCESS"
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
																																																																					id = "271",
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
																																																																										const = 5
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
																																																																},
																																																																{
																																																																	node = {
																																																																		id = "285",
																																																																		class = "Sequence",
																																																																		properties = {},
																																																																		attachments = {},
																																																																		children = {
																																																																			{
																																																																				node = {
																																																																					id = "288",
																																																																					class = "Condition",
																																																																					properties = {
																																																																						{
																																																																							Operator = "GreaterEqual"
																																																																						},
																																																																						{
																																																																							Opl = {
																																																																								func = "getVerticalDis",
																																																																								params = {
																																																																									{
																																																																										field = "selfId"
																																																																									},
																																																																									{
																																																																										field = "tgt"
																																																																									}
																																																																								}
																																																																							}
																																																																						},
																																																																						{
																																																																							Opr = {
																																																																								const = -1.5
																																																																							}
																																																																						}
																																																																					},
																																																																					attachments = {},
																																																																					children = {}
																																																																				}
																																																																			},
																																																																			{
																																																																				node = {
																																																																					id = "287",
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
																																																																										const = 1
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
																																																																										const = BaseEnum.MoveUpdateLevel.Slow
																																																																									},
																																																																									{
																																																																										const = BaseEnum.PathFindType.Voxel
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
																																																																					id = "286",
																																																																					class = "Action",
																																																																					properties = {
																																																																						{
																																																																							Method = {
																																																																								func = "playJumpAction",
																																																																								params = {
																																																																									{
																																																																										const = "Jump"
																																																																									},
																																																																									{
																																																																										const = 5
																																																																									},
																																																																									{
																																																																										const = 0
																																																																									},
																																																																									{
																																																																										const = 3
																																																																									},
																																																																									{
																																																																										const = BaseEnum.RootMotionSyncPointEnum.AICustomPoint1
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
																																																															id = "269",
																																																															class = "Selector",
																																																															properties = {},
																																																															attachments = {},
																																																															children = {
																																																																{
																																																																	node = {
																																																																		id = "255",
																																																																		class = "Sequence",
																																																																		properties = {},
																																																																		attachments = {},
																																																																		children = {
																																																																			{
																																																																				node = {
																																																																					id = "282",
																																																																					class = "Action",
																																																																					properties = {
																																																																						{
																																																																							Method = {
																																																																								func = "calcQualifiedPosByTarget",
																																																																								params = {
																																																																									{
																																																																										field = "selfId"
																																																																									},
																																																																									{
																																																																										const = 0
																																																																									},
																																																																									{
																																																																										field = "CurrentBoxDistToTarget"
																																																																									},
																																																																									{
																																																																										const = BaseEnum.CalcQualifiedPosQueryType.EightCompassDirections
																																																																									},
																																																																									{
																																																																										const = 4
																																																																									},
																																																																									{
																																																																										field = "tgt"
																																																																									},
																																																																									{
																																																																										const = true
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
																																																																					id = "256",
																																																																					class = "Action",
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
																																																																		id = "273",
																																																																		class = "IfElse",
																																																																		properties = {},
																																																																		attachments = {},
																																																																		children = {
																																																																			{
																																																																				node = {
																																																																					id = "275",
																																																																					class = "Condition",
																																																																					properties = {
																																																																						{
																																																																							Operator = "Equal"
																																																																						},
																																																																						{
																																																																							Opl = {
																																																																								func = "checkCanMoveToTarget",
																																																																								params = {
																																																																									{
																																																																										field = "tgt"
																																																																									},
																																																																									{
																																																																										field = "attackStopBoxDist"
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
																																																																					id = "274",
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
																																																																										const = 0.5
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
																																																																										const = BaseEnum.PathFindType.Voxel
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
																																																																							ResultOption = "BT_SUCCESS"
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
																																																																					id = "276",
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
																																																																							ResultOption = "BT_SUCCESS"
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
																																																						id = "294",
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
																																																						id = "293",
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
																																																			id = "24",
																																																			class = "Sequence",
																																																			properties = {},
																																																			attachments = {},
																																																			children = {
																																																				{
																																																					node = {
																																																						id = "34",
																																																						class = "Selector",
																																																						properties = {},
																																																						attachments = {},
																																																						children = {
																																																							{
																																																								node = {
																																																									id = "336",
																																																									class = "Selector",
																																																									properties = {},
																																																									attachments = {},
																																																									children = {
																																																										{
																																																											node = {
																																																												id = "337",
																																																												class = "Sequence",
																																																												properties = {},
																																																												attachments = {},
																																																												children = {
																																																													{
																																																														node = {
																																																															id = "349",
																																																															class = "Selector",
																																																															properties = {},
																																																															attachments = {},
																																																															children = {
																																																																{
																																																																	node = {
																																																																		id = "350",
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
																																																																		id = "351",
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
																																																															id = "346",
																																																															class = "And",
																																																															properties = {},
																																																															attachments = {},
																																																															children = {
																																																																{
																																																																	node = {
																																																																		id = "339",
																																																																		class = "Condition",
																																																																		properties = {
																																																																			{
																																																																				Operator = "LessEqual"
																																																																			},
																																																																			{
																																																																				Opl = {
																																																																					field = "CurrentHpPercent"
																																																																				}
																																																																			},
																																																																			{
																																																																				Opr = {
																																																																					const = 0.6
																																																																				}
																																																																			}
																																																																		},
																																																																		attachments = {},
																																																																		children = {}
																																																																	}
																																																																},
																																																																{
																																																																	node = {
																																																																		id = "348",
																																																																		class = "Condition",
																																																																		properties = {
																																																																			{
																																																																				Operator = "Less"
																																																																			},
																																																																			{
																																																																				Opl = {
																																																																					field = "tSkillRecoverCount"
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
																																																															id = "343",
																																																															class = "Selector",
																																																															properties = {},
																																																															attachments = {},
																																																															children = {
																																																																{
																																																																	node = {
																																																																		id = "408",
																																																																		class = "Sequence",
																																																																		properties = {},
																																																																		attachments = {},
																																																																		children = {
																																																																			{
																																																																				node = {
																																																																					id = "338",
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
																																																																								func = "getSkillIdByFeature",
																																																																								params = {
																																																																									{
																																																																										const = 3
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
																																																																										const = 0
																																																																									},
																																																																									{
																																																																										const = true
																																																																									},
																																																																									{
																																																																										const = true
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
																																																																					id = "388",
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
																																																																			}
																																																																		}
																																																																	}
																																																																},
																																																																{
																																																																	node = {
																																																																		id = "409",
																																																																		class = "Sequence",
																																																																		properties = {},
																																																																		attachments = {},
																																																																		children = {
																																																																			{
																																																																				node = {
																																																																					id = "344",
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
																																																																								func = "getSkillIdByFeature",
																																																																								params = {
																																																																									{
																																																																										const = 4
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
																																																																										const = 0
																																																																									},
																																																																									{
																																																																										const = true
																																																																									},
																																																																									{
																																																																										const = true
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
																																																																					id = "410",
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
																																																																			}
																																																																		}
																																																																	}
																																																																},
																																																																{
																																																																	node = {
																																																																		id = "411",
																																																																		class = "Sequence",
																																																																		properties = {},
																																																																		attachments = {},
																																																																		children = {
																																																																			{
																																																																				node = {
																																																																					id = "345",
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
																																																																								func = "getSkillIdByFeature",
																																																																								params = {
																																																																									{
																																																																										const = 2
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
																																																																										const = 0
																																																																									},
																																																																									{
																																																																										const = true
																																																																									},
																																																																									{
																																																																										const = true
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
																																																																					id = "412",
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
																																																																			}
																																																																		}
																																																																	}
																																																																}
																																																															}
																																																														}
																																																													},
																																																													{
																																																														node = {
																																																															id = "352",
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
																																																													},
																																																													{
																																																														node = {
																																																															id = "353",
																																																															class = "Assignment",
																																																															properties = {
																																																																{
																																																																	CastRight = "false"
																																																																},
																																																																{
																																																																	Opl = {
																																																																		field = "tSkillRecoverCount"
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
																																																															id = "354",
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
																																																												id = "357",
																																																												class = "Sequence",
																																																												properties = {},
																																																												attachments = {},
																																																												children = {
																																																													{
																																																														node = {
																																																															id = "362",
																																																															class = "Selector",
																																																															properties = {},
																																																															attachments = {},
																																																															children = {
																																																																{
																																																																	node = {
																																																																		id = "361",
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
																																																																		id = "367",
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
																																																															id = "431",
																																																															class = "Or",
																																																															properties = {},
																																																															attachments = {},
																																																															children = {
																																																																{
																																																																	node = {
																																																																		id = "366",
																																																																		class = "Condition",
																																																																		properties = {
																																																																			{
																																																																				Operator = "Less"
																																																																			},
																																																																			{
																																																																				Opl = {
																																																																					field = "tSkillBuffCount"
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
																																																																		id = "430",
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
																																																																							const = "tSkillBuffCount"
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
																																																															id = "360",
																																																															class = "Selector",
																																																															properties = {},
																																																															attachments = {},
																																																															children = {
																																																																{
																																																																	node = {
																																																																		id = "358",
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
																																																																					func = "getSkillIdByFeature",
																																																																					params = {
																																																																						{
																																																																							const = 6
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
																																																																							const = 0
																																																																						},
																																																																						{
																																																																							const = true
																																																																						},
																																																																						{
																																																																							const = true
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
																																																															id = "389",
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
																																																															id = "368",
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
																																																													},
																																																													{
																																																														node = {
																																																															id = "369",
																																																															class = "Assignment",
																																																															properties = {
																																																																{
																																																																	CastRight = "false"
																																																																},
																																																																{
																																																																	Opl = {
																																																																		field = "tSkillBuffCount"
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
																																																															id = "370",
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
																																																													},
																																																													{
																																																														node = {
																																																															id = "446",
																																																															class = "Action",
																																																															properties = {
																																																																{
																																																																	Method = {
																																																																		func = "startTimer",
																																																																		params = {
																																																																			{
																																																																				const = "tSkillBuffCount"
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
																																																												id = "371",
																																																												class = "Sequence",
																																																												properties = {},
																																																												attachments = {},
																																																												children = {
																																																													{
																																																														node = {
																																																															id = "376",
																																																															class = "Selector",
																																																															properties = {},
																																																															attachments = {},
																																																															children = {
																																																																{
																																																																	node = {
																																																																		id = "375",
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
																																																																		id = "381",
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
																																																															id = "379",
																																																															class = "And",
																																																															properties = {},
																																																															attachments = {},
																																																															children = {
																																																																{
																																																																	node = {
																																																																		id = "386",
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
																																																																		id = "380",
																																																																		class = "Condition",
																																																																		properties = {
																																																																			{
																																																																				Operator = "Less"
																																																																			},
																																																																			{
																																																																				Opl = {
																																																																					field = "tSkillControlCount"
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
																																																															id = "374",
																																																															class = "Selector",
																																																															properties = {},
																																																															attachments = {},
																																																															children = {
																																																																{
																																																																	node = {
																																																																		id = "372",
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
																																																																					func = "getSkillIdByFeature",
																																																																					params = {
																																																																						{
																																																																							const = 1
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
																																																																							const = 0
																																																																						},
																																																																						{
																																																																							const = true
																																																																						},
																																																																						{
																																																																							const = true
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
																																																															id = "390",
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
																																																															id = "382",
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
																																																													},
																																																													{
																																																														node = {
																																																															id = "383",
																																																															class = "Assignment",
																																																															properties = {
																																																																{
																																																																	CastRight = "false"
																																																																},
																																																																{
																																																																	Opl = {
																																																																		field = "tSkillControlCount"
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
																																																															id = "384",
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
																																																												id = "455",
																																																												class = "Sequence",
																																																												properties = {},
																																																												attachments = {},
																																																												children = {
																																																													{
																																																														node = {
																																																															id = "450",
																																																															class = "Selector",
																																																															properties = {},
																																																															attachments = {},
																																																															children = {
																																																																{
																																																																	node = {
																																																																		id = "449",
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
																																																																		id = "452",
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
																																																															id = "459",
																																																															class = "Or",
																																																															properties = {},
																																																															attachments = {},
																																																															children = {
																																																																{
																																																																	node = {
																																																																		id = "451",
																																																																		class = "Condition",
																																																																		properties = {
																																																																			{
																																																																				Operator = "Less"
																																																																			},
																																																																			{
																																																																				Opl = {
																																																																					field = "tSkillBuffCount"
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
																																																																		id = "458",
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
																																																																							const = "tSkillFar"
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
																																																																}
																																																															}
																																																														}
																																																													},
																																																													{
																																																														node = {
																																																															id = "448",
																																																															class = "Selector",
																																																															properties = {},
																																																															attachments = {},
																																																															children = {
																																																																{
																																																																	node = {
																																																																		id = "447",
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
																																																																					func = "getSkillIdByFeature",
																																																																					params = {
																																																																						{
																																																																							const = 15
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
																																																																							const = 0
																																																																						},
																																																																						{
																																																																							const = true
																																																																						},
																																																																						{
																																																																							const = true
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
																																																															id = "457",
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
																																																															id = "453",
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
																																																													},
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
																																																																		field = "tSkillFar"
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
																																																															id = "456",
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
																																																													},
																																																													{
																																																														node = {
																																																															id = "460",
																																																															class = "Action",
																																																															properties = {
																																																																{
																																																																	Method = {
																																																																		func = "startTimer",
																																																																		params = {
																																																																			{
																																																																				const = "tSkillFar"
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
																																																												id = "35",
																																																												class = "Sequence",
																																																												properties = {},
																																																												attachments = {},
																																																												children = {
																																																													{
																																																														node = {
																																																															id = "18",
																																																															class = "Selector",
																																																															properties = {},
																																																															attachments = {},
																																																															children = {
																																																																{
																																																																	node = {
																																																																		id = "36",
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
																																																																		id = "37",
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
																																																															id = "404",
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
																																																																		func = "getSkillIdByFeature",
																																																																		params = {
																																																																			{
																																																																				const = 10
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
																																																																				const = 0
																																																																			},
																																																																			{
																																																																				const = true
																																																																			},
																																																																			{
																																																																				const = true
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
																																																															id = "405",
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
																																																															id = "20",
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
																																																															id = "178",
																																																															class = "Sequence",
																																																															properties = {},
																																																															attachments = {},
																																																															children = {
																																																																{
																																																																	node = {
																																																																		id = "179",
																																																																		class = "IfElse",
																																																																		properties = {},
																																																																		attachments = {},
																																																																		children = {
																																																																			{
																																																																				node = {
																																																																					id = "177",
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
																																																																								field = "CurrentDistToTarget"
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
																																																																					class = "Sequence",
																																																																					properties = {},
																																																																					attachments = {},
																																																																					children = {
																																																																						{
																																																																							node = {
																																																																								id = "174",
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
																																																																								id = "175",
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
																																																																													const = 8
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
																																																																					id = "176",
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
																																																																		id = "129",
																																																																		class = "Selector",
																																																																		properties = {},
																																																																		attachments = {},
																																																																		children = {
																																																																			{
																																																																				node = {
																																																																					id = "130",
																																																																					class = "Sequence",
																																																																					properties = {},
																																																																					attachments = {},
																																																																					children = {
																																																																						{
																																																																							node = {
																																																																								id = "132",
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
																																																																								id = "133",
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
																																																																					id = "131",
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
																																																															id = "22",
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
																																																										}
																																																									}
																																																								}
																																																							},
																																																							{
																																																								node = {
																																																									id = "38",
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
																																																															id = "186",
																																																															class = "Condition",
																																																															properties = {
																																																																{
																																																																	Operator = "LessEqual"
																																																																},
																																																																{
																																																																	Opl = {
																																																																		func = "getMaxAttackDist",
																																																																		params = {
																																																																			{
																																																																				field = "selfId"
																																																																			}
																																																																		}
																																																																	}
																																																																},
																																																																{
																																																																	Opr = {
																																																																		field = "CurrentDistToTarget"
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
																																																																				const = 8
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
																																																															id = "187",
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
																																																										}
																																																									}
																																																								}
																																																							}
																																																						}
																																																					}
																																																				},
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
																																																												const = 10
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
																																													id = "71",
																																													class = "Selector",
																																													properties = {},
																																													attachments = {},
																																													children = {
																																														{
																																															node = {
																																																id = "72",
																																																class = "Sequence",
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
																																																						field = "CurrentDistToTarget"
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
																																																			id = "429",
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
																																																								const = "goBackCd"
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
																																																			id = "147",
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
																																																						field = "CurrentBoxDistToTarget"
																																																					}
																																																				}
																																																			},
																																																			attachments = {},
																																																			children = {}
																																																		}
																																																	},
																																																	{
																																																		node = {
																																																			id = "76",
																																																			class = "Selector",
																																																			properties = {},
																																																			attachments = {},
																																																			children = {
																																																				{
																																																					node = {
																																																						id = "326",
																																																						class = "IfElse",
																																																						properties = {},
																																																						attachments = {},
																																																						children = {
																																																							{
																																																								node = {
																																																									id = "323",
																																																									class = "Condition",
																																																									properties = {
																																																										{
																																																											Operator = "NotEqual"
																																																										},
																																																										{
																																																											Opl = {
																																																												func = "isChildOfCharState",
																																																												params = {
																																																													{
																																																														field = "selfId"
																																																													},
																																																													{
																																																														const = "SPECIALDEFENSE"
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
																																																									id = "78",
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
																																																									id = "331",
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
																																																						id = "80",
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
																																																			id = "428",
																																																			class = "Action",
																																																			properties = {
																																																				{
																																																					Method = {
																																																						func = "startTimer",
																																																						params = {
																																																							{
																																																								const = "goBackCd"
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
																																																id = "124",
																																																class = "Sequence",
																																																properties = {},
																																																attachments = {},
																																																children = {
																																																	{
																																																		node = {
																																																			id = "101",
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
																																					},
																																					{
																																						node = {
																																							id = "206",
																																							class = "IfElse",
																																							properties = {},
																																							attachments = {},
																																							children = {
																																								{
																																									node = {
																																										id = "200",
																																										class = "Condition",
																																										properties = {
																																											{
																																												Operator = "LessEqual"
																																											},
																																											{
																																												Opl = {
																																													field = "CurrentDistToTarget"
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
																																										id = "195",
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
																																															field = "bestKeepBoxDist"
																																														},
																																														{
																																															const = 5
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
																																										id = "213",
																																										class = "IfElse",
																																										properties = {},
																																										attachments = {},
																																										children = {
																																											{
																																												node = {
																																													id = "215",
																																													class = "Condition",
																																													properties = {
																																														{
																																															Operator = "Equal"
																																														},
																																														{
																																															Opl = {
																																																func = "checkInViewport",
																																																params = {
																																																	{
																																																		field = "selfId"
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
																																													id = "209",
																																													class = "Action",
																																													properties = {
																																														{
																																															Method = {
																																																func = "moveToTargetPos",
																																																params = {
																																																	{
																																																		field = "tgt"
																																																	},
																																																	{
																																																		const = 0
																																																	},
																																																	{
																																																		field = "bestKeepBoxDist"
																																																	},
																																																	{
																																																		const = 2
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
																																																		const = 8
																																																	},
																																																	{
																																																		const = BaseEnum.SpeedRateType.Slow
																																																	},
																																																	{
																																																		const = BaseEnum.PathFindType.Auto
																																																	},
																																																	{
																																																		const = false
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
																																																			field = "tWeight_Group_SideWalk"
																																																		}
																																																	}
																																																},
																																																attachments = {},
																																																children = {
																																																	{
																																																		node = {
																																																			id = "239",
																																																			class = "Sequence",
																																																			properties = {},
																																																			attachments = {},
																																																			children = {
																																																				{
																																																					node = {
																																																						id = "240",
																																																						class = "Assignment",
																																																						properties = {
																																																							{
																																																								CastRight = "false"
																																																							},
																																																							{
																																																								Opl = {
																																																									field = "tWeight_Group_SideWalk"
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
																																																						id = "241",
																																																						class = "Assignment",
																																																						properties = {
																																																							{
																																																								CastRight = "false"
																																																							},
																																																							{
																																																								Opl = {
																																																									field = "tWeight_Group_Wait"
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
																																																						id = "242",
																																																						class = "Assignment",
																																																						properties = {
																																																							{
																																																								CastRight = "false"
																																																							},
																																																							{
																																																								Opl = {
																																																									field = "tWeight_Group_Angry"
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
																																																						id = "204",
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
																																																			field = "tWeight_Group_Wait"
																																																		}
																																																	}
																																																},
																																																attachments = {},
																																																children = {
																																																	{
																																																		node = {
																																																			id = "243",
																																																			class = "Sequence",
																																																			properties = {},
																																																			attachments = {},
																																																			children = {
																																																				{
																																																					node = {
																																																						id = "246",
																																																						class = "Assignment",
																																																						properties = {
																																																							{
																																																								CastRight = "false"
																																																							},
																																																							{
																																																								Opl = {
																																																									field = "tWeight_Group_Angry"
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
																																																						id = "244",
																																																						class = "Assignment",
																																																						properties = {
																																																							{
																																																								CastRight = "false"
																																																							},
																																																							{
																																																								Opl = {
																																																									field = "tWeight_Group_SideWalk"
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
																																																						id = "245",
																																																						class = "Assignment",
																																																						properties = {
																																																							{
																																																								CastRight = "false"
																																																							},
																																																							{
																																																								Opl = {
																																																									field = "tWeight_Group_Wait"
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
																																																						id = "222",
																																																						class = "Action",
																																																						properties = {
																																																							{
																																																								Method = {
																																																									func = "waitTime",
																																																									params = {
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
																																																id = "221",
																																																class = "DecoratorWeight",
																																																properties = {
																																																	{
																																																		DecorateWhenChildEnds = "false"
																																																	},
																																																	{
																																																		Weight = {
																																																			field = "tWeight_Group_Angry"
																																																		}
																																																	}
																																																},
																																																attachments = {},
																																																children = {
																																																	{
																																																		node = {
																																																			id = "247",
																																																			class = "Sequence",
																																																			properties = {},
																																																			attachments = {},
																																																			children = {
																																																				{
																																																					node = {
																																																						id = "248",
																																																						class = "Assignment",
																																																						properties = {
																																																							{
																																																								CastRight = "false"
																																																							},
																																																							{
																																																								Opl = {
																																																									field = "tWeight_Group_SideWalk"
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
																																																						id = "249",
																																																						class = "Assignment",
																																																						properties = {
																																																							{
																																																								CastRight = "false"
																																																							},
																																																							{
																																																								Opl = {
																																																									field = "tWeight_Group_Wait"
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
																																																						id = "250",
																																																						class = "Assignment",
																																																						properties = {
																																																							{
																																																								CastRight = "false"
																																																							},
																																																							{
																																																								Opl = {
																																																									field = "tWeight_Group_Angry"
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
																																																											const = 1
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
																																																								ResultResumeOption = "BT_ResumeTree"
																																																							}
																																																						},
																																																						attachments = {},
																																																						children = {}
																																																					}
																																																				},
																																																				{
																																																					node = {
																																																						id = "225",
																																																						class = "Selector",
																																																						properties = {},
																																																						attachments = {},
																																																						children = {
																																																							{
																																																								node = {
																																																									id = "224",
																																																									class = "Sequence",
																																																									properties = {},
																																																									attachments = {},
																																																									children = {
																																																										{
																																																											node = {
																																																												id = "226",
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
																																																																	const = "Behav_AngryLoop"
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
																																																												id = "227",
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
																																																																	const = 0
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
																																																							},
																																																							{
																																																								node = {
																																																									id = "223",
																																																									class = "Action",
																																																									properties = {
																																																										{
																																																											Method = {
																																																												func = "playAction",
																																																												params = {
																																																													{
																																																														const = "Behav_Angry"
																																																													},
																																																													{
																																																														const = 4
																																																													},
																																																													{
																																																														const = ""
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
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
}

return ST_Monster_AutoCombat_Server_Common
