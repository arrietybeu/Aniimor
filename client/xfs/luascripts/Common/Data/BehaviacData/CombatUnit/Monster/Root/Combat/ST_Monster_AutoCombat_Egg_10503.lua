-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\CombatUnit\\Monster\\Root\\Combat\\ST_Monster_AutoCombat_Egg_10503.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local ST_Monster_AutoCombat_Egg_10503 = {
	behavior = {
		version = 100,
		useForRoute = false,
		agenttype = "PuppetAgent",
		name = "CombatUnit/Monster/Root/Combat/ST_Monster_AutoCombat_Egg_10503",
		properties = {},
		pars = {
			{
				type = "float",
				const = 0,
				name = "CurrentDistToTarget",
				value = "0"
			},
			{
				type = "float",
				const = 0,
				name = "CurrentBoxDistToTarget",
				value = "0"
			},
			{
				type = "float",
				const = 0,
				name = "goBackDist",
				value = "0"
			},
			{
				type = "float",
				const = 0,
				name = "skillStopDist",
				value = "0"
			},
			{
				type = "int",
				const = 100,
				name = "tWeight_Group_SideWalk",
				value = "100"
			},
			{
				type = "int",
				const = 100,
				name = "tWeight_Group_Wait",
				value = "100"
			},
			{
				type = "int",
				const = 100,
				name = "tWeight_Group_Angry",
				value = "100"
			},
			{
				type = "int",
				const = 0,
				name = "tSkillRecoverCount",
				value = "0"
			},
			{
				type = "float",
				const = 0,
				name = "CurrentHpPercent",
				value = "0"
			},
			{
				type = "int",
				const = 0,
				name = "tSkillBuffCount",
				value = "0"
			},
			{
				type = "int",
				const = 0,
				name = "tSkillControlCount",
				value = "0"
			},
			{
				type = "float",
				const = 0,
				name = "tSkillFar",
				value = "0"
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
						id = "212",
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
						class = "Assignment",
						id = "217",
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
						class = "Action",
						id = "385",
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
						class = "Action",
						id = "425",
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
									id = "171",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												class = "Sequence",
												id = "355",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															class = "Assignment",
															id = "8",
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
															class = "Assignment",
															id = "356",
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
															class = "Assignment",
															id = "406",
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
												class = "IfElse",
												id = "172",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															class = "Condition",
															id = "169",
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
															class = "Sequence",
															id = "416",
															properties = {},
															attachments = {
																{
																	class = "Precondition",
																	transition = false,
																	effector = false,
																	precondition = true,
																	id = "417",
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
																		class = "DecoratorLoop",
																		id = "424",
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
																					class = "Action",
																					id = "422",
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
															class = "IfElse",
															id = "167",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		class = "Condition",
																		id = "165",
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
																		class = "Action",
																		id = "166",
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
																		class = "IfElse",
																		id = "313",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					class = "Condition",
																					id = "314",
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
																					class = "Action",
																					id = "312",
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
																					class = "IfElse",
																					id = "317",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								class = "Condition",
																								id = "318",
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
																								class = "Action",
																								id = "316",
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
																								class = "Sequence",
																								id = "216",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											class = "Sequence",
																											id = "4",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														class = "Assignment",
																														id = "6",
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
																														class = "Assignment",
																														id = "188",
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
																											class = "IfElse",
																											id = "229",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														class = "Condition",
																														id = "234",
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
																														class = "Sequence",
																														id = "297",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	class = "Action",
																																	id = "296",
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
																																	class = "Action",
																																	id = "298",
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
																														class = "IfElse",
																														id = "150",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	class = "Sequence",
																																	id = "311",
																																	properties = {},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				class = "Condition",
																																				id = "151",
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
																																				class = "Condition",
																																				id = "310",
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
																																	class = "IfElse",
																																	id = "156",
																																	properties = {},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				class = "Condition",
																																				id = "154",
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
																																				class = "Sequence",
																																				id = "191",
																																				properties = {},
																																				attachments = {},
																																				children = {
																																					{
																																						node = {
																																							class = "Action",
																																							id = "189",
																																							properties = {
																																								{
																																									Method = {
																																										func = "switchToFly",
																																										params = {
																																											{
																																												const = 3
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
																																							class = "Action",
																																							id = "307",
																																							properties = {
																																								{
																																									Method = {
																																										func = "flyToTarget",
																																										params = {
																																											{
																																												field = "tgt"
																																											},
																																											{
																																												const = 2
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
																																												const = 0
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
																																							id = "190",
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
																																				class = "Sequence",
																																				id = "300",
																																				properties = {},
																																				attachments = {},
																																				children = {
																																					{
																																						node = {
																																							class = "Action",
																																							id = "299",
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
																																							class = "Selector",
																																							id = "159",
																																							properties = {},
																																							attachments = {},
																																							children = {
																																								{
																																									node = {
																																										class = "Sequence",
																																										id = "158",
																																										properties = {},
																																										attachments = {},
																																										children = {
																																											{
																																												node = {
																																													class = "Condition",
																																													id = "160",
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
																																													class = "Action",
																																													id = "161",
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
																																										class = "Action",
																																										id = "157",
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
																															},
																															{
																																node = {
																																	class = "IfElse",
																																	id = "9",
																																	properties = {},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				class = "Condition",
																																				id = "10",
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
																																				class = "Selector",
																																				id = "462",
																																				properties = {},
																																				attachments = {},
																																				children = {
																																					{
																																						node = {
																																							class = "Sequence",
																																							id = "463",
																																							properties = {},
																																							attachments = {},
																																							children = {
																																								{
																																									node = {
																																										class = "Condition",
																																										id = "464",
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
																																													const = 30
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
																																										id = "465",
																																										properties = {
																																											{
																																												Method = {
																																													func = "teleportToTargetSide",
																																													params = {
																																														{
																																															field = "tgt"
																																														},
																																														{
																																															const = 2
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
																																							id = "11",
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
																																												const = BaseEnum.MoveUpdateLevel.Slow
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
																																					}
																																				}
																																			}
																																		},
																																		{
																																			node = {
																																				class = "IfElse",
																																				id = "194",
																																				properties = {},
																																				attachments = {},
																																				children = {
																																					{
																																						node = {
																																							class = "True",
																																							id = "426",
																																							properties = {},
																																							attachments = {},
																																							children = {}
																																						}
																																					},
																																					{
																																						node = {
																																							class = "Selector",
																																							id = "12",
																																							properties = {},
																																							attachments = {},
																																							children = {
																																								{
																																									node = {
																																										class = "SelectorProbability",
																																										id = "13",
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
																																													id = "15",
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
																																																class = "Selector",
																																																id = "289",
																																																properties = {},
																																																attachments = {},
																																																children = {
																																																	{
																																																		node = {
																																																			class = "Sequence",
																																																			id = "291",
																																																			properties = {},
																																																			attachments = {},
																																																			children = {
																																																				{
																																																					node = {
																																																						class = "Sequence",
																																																						id = "252",
																																																						properties = {},
																																																						attachments = {},
																																																						children = {
																																																							{
																																																								node = {
																																																									class = "Condition",
																																																									id = "251",
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
																																																									class = "IfElse",
																																																									id = "260",
																																																									properties = {},
																																																									attachments = {},
																																																									children = {
																																																										{
																																																											node = {
																																																												class = "And",
																																																												id = "261",
																																																												properties = {},
																																																												attachments = {},
																																																												children = {
																																																													{
																																																														node = {
																																																															class = "Condition",
																																																															id = "257",
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
																																																															class = "Condition",
																																																															id = "262",
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
																																																												class = "Sequence",
																																																												id = "259",
																																																												properties = {},
																																																												attachments = {},
																																																												children = {
																																																													{
																																																														node = {
																																																															class = "Action",
																																																															id = "265",
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
																																																															class = "Action",
																																																															id = "263",
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
																																																												class = "IfElse",
																																																												id = "264",
																																																												properties = {},
																																																												attachments = {},
																																																												children = {
																																																													{
																																																														node = {
																																																															class = "And",
																																																															id = "267",
																																																															properties = {},
																																																															attachments = {},
																																																															children = {
																																																																{
																																																																	node = {
																																																																		class = "Condition",
																																																																		id = "258",
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
																																																																		class = "Condition",
																																																																		id = "283",
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
																																																															class = "IfElse",
																																																															id = "284",
																																																															properties = {},
																																																															attachments = {},
																																																															children = {
																																																																{
																																																																	node = {
																																																																		class = "Condition",
																																																																		id = "266",
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
																																																																		class = "Sequence",
																																																																		id = "272",
																																																																		properties = {},
																																																																		attachments = {},
																																																																		children = {
																																																																			{
																																																																				node = {
																																																																					class = "Action",
																																																																					id = "270",
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
																																																																					class = "Action",
																																																																					id = "268",
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
																																																																					class = "Action",
																																																																					id = "271",
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
																																																																		class = "Sequence",
																																																																		id = "285",
																																																																		properties = {},
																																																																		attachments = {},
																																																																		children = {
																																																																			{
																																																																				node = {
																																																																					class = "Condition",
																																																																					id = "288",
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
																																																																					class = "Action",
																																																																					id = "287",
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
																																																																					class = "Action",
																																																																					id = "286",
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
																																																															class = "Selector",
																																																															id = "269",
																																																															properties = {},
																																																															attachments = {},
																																																															children = {
																																																																{
																																																																	node = {
																																																																		class = "Sequence",
																																																																		id = "255",
																																																																		properties = {},
																																																																		attachments = {},
																																																																		children = {
																																																																			{
																																																																				node = {
																																																																					class = "Action",
																																																																					id = "282",
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
																																																																					class = "Action",
																																																																					id = "256",
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
																																																																		class = "IfElse",
																																																																		id = "273",
																																																																		properties = {},
																																																																		attachments = {},
																																																																		children = {
																																																																			{
																																																																				node = {
																																																																					class = "Condition",
																																																																					id = "275",
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
																																																																					class = "Action",
																																																																					id = "274",
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
																																																																					class = "Action",
																																																																					id = "276",
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
																																																						class = "Assignment",
																																																						id = "294",
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
																																																						class = "Assignment",
																																																						id = "293",
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
																																																			class = "Sequence",
																																																			id = "24",
																																																			properties = {},
																																																			attachments = {},
																																																			children = {
																																																				{
																																																					node = {
																																																						class = "Selector",
																																																						id = "34",
																																																						properties = {},
																																																						attachments = {},
																																																						children = {
																																																							{
																																																								node = {
																																																									class = "Selector",
																																																									id = "336",
																																																									properties = {},
																																																									attachments = {},
																																																									children = {
																																																										{
																																																											node = {
																																																												class = "Sequence",
																																																												id = "337",
																																																												properties = {},
																																																												attachments = {},
																																																												children = {
																																																													{
																																																														node = {
																																																															class = "Selector",
																																																															id = "349",
																																																															properties = {},
																																																															attachments = {},
																																																															children = {
																																																																{
																																																																	node = {
																																																																		class = "Condition",
																																																																		id = "350",
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
																																																																		id = "351",
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
																																																															class = "And",
																																																															id = "346",
																																																															properties = {},
																																																															attachments = {},
																																																															children = {
																																																																{
																																																																	node = {
																																																																		class = "Condition",
																																																																		id = "339",
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
																																																																		class = "Condition",
																																																																		id = "348",
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
																																																															class = "Selector",
																																																															id = "343",
																																																															properties = {},
																																																															attachments = {},
																																																															children = {
																																																																{
																																																																	node = {
																																																																		class = "Sequence",
																																																																		id = "408",
																																																																		properties = {},
																																																																		attachments = {},
																																																																		children = {
																																																																			{
																																																																				node = {
																																																																					class = "Assignment",
																																																																					id = "338",
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
																																																																					class = "Condition",
																																																																					id = "388",
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
																																																																		class = "Sequence",
																																																																		id = "409",
																																																																		properties = {},
																																																																		attachments = {},
																																																																		children = {
																																																																			{
																																																																				node = {
																																																																					class = "Assignment",
																																																																					id = "344",
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
																																																																					class = "Condition",
																																																																					id = "410",
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
																																																																		class = "Sequence",
																																																																		id = "411",
																																																																		properties = {},
																																																																		attachments = {},
																																																																		children = {
																																																																			{
																																																																				node = {
																																																																					class = "Assignment",
																																																																					id = "345",
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
																																																																					class = "Condition",
																																																																					id = "412",
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
																																																															class = "Action",
																																																															id = "352",
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
																																																															class = "Assignment",
																																																															id = "353",
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
																																																															class = "Action",
																																																															id = "354",
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
																																																												id = "357",
																																																												properties = {},
																																																												attachments = {},
																																																												children = {
																																																													{
																																																														node = {
																																																															class = "Selector",
																																																															id = "362",
																																																															properties = {},
																																																															attachments = {},
																																																															children = {
																																																																{
																																																																	node = {
																																																																		class = "Condition",
																																																																		id = "361",
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
																																																																		id = "367",
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
																																																															class = "Or",
																																																															id = "431",
																																																															properties = {},
																																																															attachments = {},
																																																															children = {
																																																																{
																																																																	node = {
																																																																		class = "Condition",
																																																																		id = "366",
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
																																																																		class = "Condition",
																																																																		id = "430",
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
																																																															class = "Selector",
																																																															id = "360",
																																																															properties = {},
																																																															attachments = {},
																																																															children = {
																																																																{
																																																																	node = {
																																																																		class = "Assignment",
																																																																		id = "358",
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
																																																															class = "Condition",
																																																															id = "389",
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
																																																															class = "Action",
																																																															id = "368",
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
																																																															class = "Assignment",
																																																															id = "369",
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
																																																															class = "Action",
																																																															id = "370",
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
																																																															class = "Action",
																																																															id = "446",
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
																																																												class = "Sequence",
																																																												id = "371",
																																																												properties = {},
																																																												attachments = {},
																																																												children = {
																																																													{
																																																														node = {
																																																															class = "Selector",
																																																															id = "376",
																																																															properties = {},
																																																															attachments = {},
																																																															children = {
																																																																{
																																																																	node = {
																																																																		class = "Condition",
																																																																		id = "375",
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
																																																																		id = "381",
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
																																																															class = "And",
																																																															id = "379",
																																																															properties = {},
																																																															attachments = {},
																																																															children = {
																																																																{
																																																																	node = {
																																																																		class = "Condition",
																																																																		id = "386",
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
																																																																		class = "Condition",
																																																																		id = "380",
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
																																																															class = "Selector",
																																																															id = "374",
																																																															properties = {},
																																																															attachments = {},
																																																															children = {
																																																																{
																																																																	node = {
																																																																		class = "Assignment",
																																																																		id = "372",
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
																																																															class = "Condition",
																																																															id = "390",
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
																																																															class = "Action",
																																																															id = "382",
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
																																																															class = "Assignment",
																																																															id = "383",
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
																																																															class = "Action",
																																																															id = "384",
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
																																																												id = "455",
																																																												properties = {},
																																																												attachments = {},
																																																												children = {
																																																													{
																																																														node = {
																																																															class = "Selector",
																																																															id = "450",
																																																															properties = {},
																																																															attachments = {},
																																																															children = {
																																																																{
																																																																	node = {
																																																																		class = "Condition",
																																																																		id = "449",
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
																																																																		id = "452",
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
																																																															class = "Or",
																																																															id = "459",
																																																															properties = {},
																																																															attachments = {},
																																																															children = {
																																																																{
																																																																	node = {
																																																																		class = "Condition",
																																																																		id = "451",
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
																																																																		class = "Condition",
																																																																		id = "458",
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
																																																															class = "Selector",
																																																															id = "448",
																																																															properties = {},
																																																															attachments = {},
																																																															children = {
																																																																{
																																																																	node = {
																																																																		class = "Assignment",
																																																																		id = "447",
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
																																																															class = "Condition",
																																																															id = "457",
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
																																																															class = "Action",
																																																															id = "453",
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
																																																															class = "Assignment",
																																																															id = "454",
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
																																																															class = "Action",
																																																															id = "456",
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
																																																															class = "Action",
																																																															id = "460",
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
																																																												class = "Sequence",
																																																												id = "35",
																																																												properties = {},
																																																												attachments = {},
																																																												children = {
																																																													{
																																																														node = {
																																																															class = "Selector",
																																																															id = "18",
																																																															properties = {},
																																																															attachments = {},
																																																															children = {
																																																																{
																																																																	node = {
																																																																		class = "Condition",
																																																																		id = "36",
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
																																																																		id = "37",
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
																																																															class = "Assignment",
																																																															id = "404",
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
																																																															class = "Condition",
																																																															id = "405",
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
																																																															class = "Condition",
																																																															id = "20",
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
																																																															class = "Sequence",
																																																															id = "178",
																																																															properties = {},
																																																															attachments = {},
																																																															children = {
																																																																{
																																																																	node = {
																																																																		class = "IfElse",
																																																																		id = "179",
																																																																		properties = {},
																																																																		attachments = {},
																																																																		children = {
																																																																			{
																																																																				node = {
																																																																					class = "Condition",
																																																																					id = "177",
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
																																																																					class = "Sequence",
																																																																					id = "180",
																																																																					properties = {},
																																																																					attachments = {},
																																																																					children = {
																																																																						{
																																																																							node = {
																																																																								class = "Assignment",
																																																																								id = "174",
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
																																																																								class = "Action",
																																																																								id = "175",
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
																																																																					class = "Noop",
																																																																					id = "176",
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
																																																																		id = "129",
																																																																		properties = {},
																																																																		attachments = {},
																																																																		children = {
																																																																			{
																																																																				node = {
																																																																					class = "Sequence",
																																																																					id = "130",
																																																																					properties = {},
																																																																					attachments = {},
																																																																					children = {
																																																																						{
																																																																							node = {
																																																																								class = "Condition",
																																																																								id = "132",
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
																																																																								id = "133",
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
																																																																					id = "131",
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
																																																															id = "22",
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
																																																									class = "Sequence",
																																																									id = "38",
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
																																																															id = "186",
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
																																																															class = "Action",
																																																															id = "184",
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
																																																															class = "Noop",
																																																															id = "187",
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
																																																												class = "Action",
																																																												id = "41",
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
																																																						class = "Sequence",
																																																						id = "46",
																																																						properties = {},
																																																						attachments = {},
																																																						children = {
																																																							{
																																																								node = {
																																																									class = "Compute",
																																																									id = "49",
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
																																																									class = "Assignment",
																																																									id = "50",
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
																																													class = "DecoratorWeight",
																																													id = "17",
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
																																																id = "16",
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
																																										id = "53",
																																										properties = {},
																																										attachments = {},
																																										children = {
																																											{
																																												node = {
																																													class = "Sequence",
																																													id = "59",
																																													properties = {},
																																													attachments = {},
																																													children = {
																																														{
																																															node = {
																																																class = "Compute",
																																																id = "60",
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
																																																class = "Assignment",
																																																id = "61",
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
																																													class = "Selector",
																																													id = "71",
																																													properties = {},
																																													attachments = {},
																																													children = {
																																														{
																																															node = {
																																																class = "Sequence",
																																																id = "72",
																																																properties = {},
																																																attachments = {},
																																																children = {
																																																	{
																																																		node = {
																																																			class = "Condition",
																																																			id = "74",
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
																																																			class = "Condition",
																																																			id = "429",
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
																																																			class = "Compute",
																																																			id = "147",
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
																																																			class = "Selector",
																																																			id = "76",
																																																			properties = {},
																																																			attachments = {},
																																																			children = {
																																																				{
																																																					node = {
																																																						class = "IfElse",
																																																						id = "326",
																																																						properties = {},
																																																						attachments = {},
																																																						children = {
																																																							{
																																																								node = {
																																																									class = "Condition",
																																																									id = "323",
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
																																																									class = "Action",
																																																									id = "78",
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
																																																									class = "Noop",
																																																									id = "331",
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
																																																						class = "Action",
																																																						id = "80",
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
																																																			class = "Action",
																																																			id = "428",
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
																																																class = "Sequence",
																																																id = "124",
																																																properties = {},
																																																attachments = {},
																																																children = {
																																																	{
																																																		node = {
																																																			class = "Condition",
																																																			id = "101",
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
																																																			class = "Action",
																																																			id = "105",
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
																																							class = "IfElse",
																																							id = "206",
																																							properties = {},
																																							attachments = {},
																																							children = {
																																								{
																																									node = {
																																										class = "Condition",
																																										id = "200",
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
																																										class = "Action",
																																										id = "195",
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
																																										class = "IfElse",
																																										id = "213",
																																										properties = {},
																																										attachments = {},
																																										children = {
																																											{
																																												node = {
																																													class = "Condition",
																																													id = "215",
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
																																													class = "Action",
																																													id = "209",
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
																																													class = "SelectorProbability",
																																													id = "218",
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
																																																id = "219",
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
																																																			class = "Sequence",
																																																			id = "239",
																																																			properties = {},
																																																			attachments = {},
																																																			children = {
																																																				{
																																																					node = {
																																																						class = "Assignment",
																																																						id = "240",
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
																																																						class = "Assignment",
																																																						id = "241",
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
																																																						class = "Assignment",
																																																						id = "242",
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
																																																						class = "Action",
																																																						id = "204",
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
																																																class = "DecoratorWeight",
																																																id = "220",
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
																																																			class = "Sequence",
																																																			id = "243",
																																																			properties = {},
																																																			attachments = {},
																																																			children = {
																																																				{
																																																					node = {
																																																						class = "Assignment",
																																																						id = "246",
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
																																																						class = "Assignment",
																																																						id = "244",
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
																																																						class = "Assignment",
																																																						id = "245",
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
																																																						class = "Action",
																																																						id = "222",
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
																																																class = "DecoratorWeight",
																																																id = "221",
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
																																																			class = "Sequence",
																																																			id = "247",
																																																			properties = {},
																																																			attachments = {},
																																																			children = {
																																																				{
																																																					node = {
																																																						class = "Assignment",
																																																						id = "248",
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
																																																						class = "Assignment",
																																																						id = "249",
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
																																																						class = "Assignment",
																																																						id = "250",
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
																																																						class = "Action",
																																																						id = "302",
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
																																																						class = "Selector",
																																																						id = "225",
																																																						properties = {},
																																																						attachments = {},
																																																						children = {
																																																							{
																																																								node = {
																																																									class = "Sequence",
																																																									id = "224",
																																																									properties = {},
																																																									attachments = {},
																																																									children = {
																																																										{
																																																											node = {
																																																												class = "Condition",
																																																												id = "226",
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
																																																												class = "Action",
																																																												id = "227",
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
																																																									class = "Action",
																																																									id = "223",
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

return ST_Monster_AutoCombat_Egg_10503
