-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\CombatUnit\\NPC\\BotPet\\PBT_BotPet_AutoCombat_BREAK.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_BotPet_AutoCombat_BREAK = {
	behavior = {
		name = "CombatUnit/NPC/BotPet/PBT_BotPet_AutoCombat_BREAK",
		version = 312,
		useForRoute = false,
		agenttype = "PetAgent",
		properties = {},
		pars = {
			{
				type = "bool",
				name = "tShow50PCBubble",
				const = false,
				value = "false"
			},
			{
				type = "bool",
				name = "tShow20PCBubble",
				const = false,
				value = "false"
			},
			{
				type = "float",
				name = "CurrentDistToTarget",
				const = 0,
				value = "0"
			},
			{
				type = "float",
				name = "CurrentEP",
				const = 0,
				value = "0"
			},
			{
				type = "float",
				name = "CurrentHpPercent",
				const = 0,
				value = "0"
			},
			{
				type = "int",
				name = "Weight_JumpBack",
				const = 0,
				value = "0"
			},
			{
				type = "int",
				name = "Weight_RunBack",
				const = 0,
				value = "0"
			},
			{
				type = "int",
				name = "Weight_Skill",
				const = 0,
				value = "0"
			},
			{
				type = "int",
				name = "Weight_CommonAttack",
				const = 0,
				value = "0"
			},
			{
				type = "int",
				name = "Weight_NothingToDo",
				const = 0,
				value = "0"
			},
			{
				type = "float",
				name = "maxSkillDist",
				const = 0,
				value = "0"
			},
			{
				type = "float",
				name = "skillStopDist",
				const = 0,
				value = "0"
			},
			{
				type = "float",
				name = "goBackDist",
				const = 0,
				value = "0"
			},
			{
				type = "int",
				name = "tNewTargetForCatchMode",
				const = 0,
				value = "0"
			},
			{
				type = "float",
				name = "CurrentBoxDistToTarget",
				const = 0,
				value = "0"
			},
			{
				type = "int",
				name = "tAngryPrepare",
				const = 0,
				value = "0"
			},
			{
				type = "float",
				name = "tDrowningDepth",
				const = 0,
				value = "0"
			},
			{
				type = "float",
				name = "tFlyHeight",
				const = 0,
				value = "0"
			},
			{
				type = "float",
				name = "tVerticalDistToTgt",
				const = 0,
				value = "0"
			},
			{
				type = "string",
				name = "tSkillPlan",
				const = "0",
				value = "0"
			},
			{
				type = "int",
				name = "tSkillUsed",
				const = 0,
				value = "0"
			},
			{
				type = "float",
				name = "tCurrentSp",
				const = 0,
				value = "0"
			},
			{
				type = "float",
				name = "tCurrentBreakPercent",
				const = 0,
				value = "0"
			}
		},
		attachments = {},
		node = {
			class = "Sequence",
			id = "569",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						class = "Compute",
						id = "687",
						properties = {
							{
								Operator = "Mul"
							},
							{
								Opl = {
									field = "tDrowningDepth"
								}
							},
							{
								Opr1 = {
									func = "getBodyHeight",
									params = {
										{
											field = "selfId"
										}
									}
								}
							},
							{
								Opr2 = {
									const = -0.6
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
						id = "686",
						properties = {
							{
								CastRight = "false"
							},
							{
								Opl = {
									field = "tAngryPrepare"
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
						id = "570",
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
									id = "464",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												class = "Sequence",
												id = "117",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															class = "Assignment",
															id = "465",
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
															id = "116",
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
															id = "550",
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
													},
													{
														node = {
															class = "Assignment",
															id = "121",
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
															id = "118",
															properties = {
																{
																	CastRight = "false"
																},
																{
																	Opl = {
																		field = "CurrentEP"
																	}
																},
																{
																	Opr = {
																		func = "getEp",
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
															id = "229",
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
													},
													{
														node = {
															class = "Assignment",
															id = "252",
															properties = {
																{
																	CastRight = "false"
																},
																{
																	Opl = {
																		field = "Weight_JumpBack"
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
															id = "249",
															properties = {
																{
																	CastRight = "false"
																},
																{
																	Opl = {
																		field = "Weight_RunBack"
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
															id = "250",
															properties = {
																{
																	CastRight = "false"
																},
																{
																	Opl = {
																		field = "Weight_Skill"
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
															id = "251",
															properties = {
																{
																	CastRight = "false"
																},
																{
																	Opl = {
																		field = "Weight_CommonAttack"
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
															id = "458",
															properties = {
																{
																	CastRight = "false"
																},
																{
																	Opl = {
																		field = "Weight_NothingToDo"
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
															id = "1123",
															properties = {
																{
																	CastRight = "false"
																},
																{
																	Opl = {
																		field = "tSkillUsed"
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
															id = "1572",
															properties = {
																{
																	CastRight = "false"
																},
																{
																	Opl = {
																		field = "tCurrentSp"
																	}
																},
																{
																	Opr = {
																		func = "getSp",
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
															id = "1573",
															properties = {
																{
																	CastRight = "false"
																},
																{
																	Opl = {
																		field = "tCurrentBreakPercent"
																	}
																},
																{
																	Opr = {
																		func = "getBreakPercent",
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
													}
												}
											}
										},
										{
											node = {
												class = "Selector",
												id = "6",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															class = "Sequence",
															id = "624",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		class = "Condition",
																		id = "623",
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
																		id = "640",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					class = "And",
																					id = "641",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								class = "Condition",
																								id = "635",
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
																								id = "642",
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
																					id = "638",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								class = "Action",
																								id = "649",
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
																								id = "648",
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
																					class = "Sequence",
																					id = "689",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								class = "Assignment",
																								id = "690",
																								properties = {
																									{
																										CastRight = "false"
																									},
																									{
																										Opl = {
																											field = "tVerticalDistToTgt"
																										}
																									},
																									{
																										Opr = {
																											func = "getVerticalDis",
																											params = {
																												{
																													field = "tgt"
																												},
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
																								class = "IfElse",
																								id = "645",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											class = "And",
																											id = "653",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														class = "Condition",
																														id = "636",
																														properties = {
																															{
																																Operator = "GreaterEqual"
																															},
																															{
																																Opl = {
																																	field = "tVerticalDistToTgt"
																																}
																															},
																															{
																																Opr = {
																																	const = 0.25
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
																														id = "678",
																														properties = {
																															{
																																Operator = "LessEqual"
																															},
																															{
																																Opl = {
																																	field = "tVerticalDistToTgt"
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
																												}
																											}
																										}
																									},
																									{
																										node = {
																											class = "IfElse",
																											id = "679",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														class = "Condition",
																														id = "652",
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
																														id = "661",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	class = "Compute",
																																	id = "691",
																																	properties = {
																																		{
																																			Operator = "Add"
																																		},
																																		{
																																			Opl = {
																																				field = "tFlyHeight"
																																			}
																																		},
																																		{
																																			Opr1 = {
																																				field = "tVerticalDistToTgt"
																																			}
																																		},
																																		{
																																			Opr2 = {
																																				const = 1.5
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
																																	id = "659",
																																	properties = {
																																		{
																																			Method = {
																																				func = "switchToFly",
																																				params = {
																																					{
																																						field = "tFlyHeight"
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
																																	id = "658",
																																	properties = {
																																		{
																																			Method = {
																																				func = "moveToTarget",
																																				params = {
																																					{
																																						field = "tgt"
																																					},
																																					{
																																						field = "minAttackDist"
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
																																	id = "660",
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
																														id = "680",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	class = "Action",
																																	id = "682",
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
																																	id = "681",
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
																											id = "664",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														class = "Sequence",
																														id = "627",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	class = "Action",
																																	id = "677",
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
																																	id = "628",
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
																														id = "665",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	class = "Condition",
																																	id = "663",
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
																																	id = "669",
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
																																	id = "671",
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
																}
															}
														}
													},
													{
														node = {
															class = "Selector",
															id = "436",
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
																					class = "ReferencedBehavior",
																					id = "1580",
																					properties = {
																						{
																							ReferenceBehavior = {
																								const = "PBT_AutoCombat_KeepDis"
																							}
																						},
																						{
																							subTreeProperties = {
																								{
																									Name = "goBackDist",
																									Type = "Self",
																									Value = {
																										field = "goBackDist"
																									}
																								},
																								{
																									Name = "CurrentDistToTarget",
																									Type = "Self",
																									Value = {
																										field = "CurrentDistToTarget"
																									}
																								},
																								{
																									Name = "CurrentBoxDistToTarget",
																									Type = "Self",
																									Value = {
																										field = "CurrentBoxDistToTarget"
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
																					class = "Selector",
																					id = "737",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								class = "Sequence",
																								id = "129",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											class = "Condition",
																											id = "130",
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
																											class = "Assignment",
																											id = "152",
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
																											id = "154",
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
																											class = "Action",
																											id = "728",
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
																						},
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
																											id = "157",
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
																											class = "Assignment",
																											id = "156",
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
																											id = "159",
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
																											class = "Action",
																											id = "729",
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
																											class = "And",
																											id = "166",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														class = "Condition",
																														id = "162",
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
																																	const = 0.8
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
																														id = "253",
																														properties = {
																															{
																																Operator = "LessEqual"
																															},
																															{
																																Opl = {
																																	func = "getShieldValue",
																																	params = {
																																		{
																																			field = "selfId"
																																		}
																																	}
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
																											class = "Assignment",
																											id = "161",
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
																											id = "164",
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
																											class = "Action",
																											id = "732",
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
																					class = "Selector",
																					id = "1466",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								class = "Sequence",
																								id = "1515",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											class = "Condition",
																											id = "1514",
																											properties = {
																												{
																													Operator = "Equal"
																												},
																												{
																													Opl = {
																														func = "checkCharacterState",
																														params = {
																															{
																																const = "SNEAK"
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
																											id = "1497",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														class = "Condition",
																														id = "1528",
																														properties = {
																															{
																																Operator = "Equal"
																															},
																															{
																																Opl = {
																																	func = "checkSkillExistByFeatureId",
																																	params = {
																																		{
																																			field = "selfId"
																																		},
																																		{
																																			const = 16
																																		},
																																		{
																																			const = true
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
																														id = "1512",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	class = "Sequence",
																																	id = "1498",
																																	properties = {},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				class = "Assignment",
																																				id = "1468",
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
																																									const = 16
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
																																				id = "1513",
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
																																				id = "1488",
																																				properties = {},
																																				attachments = {},
																																				children = {
																																					{
																																						node = {
																																							class = "Assignment",
																																							id = "1483",
																																							properties = {
																																								{
																																									CastRight = "false"
																																								},
																																								{
																																									Opl = {
																																										field = "maxSkillDist"
																																									}
																																								},
																																								{
																																									Opr = {
																																										func = "getMaxSkillDist",
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
																																							class = "Assignment",
																																							id = "1484",
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
																																							class = "IfElse",
																																							id = "1485",
																																							properties = {},
																																							attachments = {},
																																							children = {
																																								{
																																									node = {
																																										class = "Condition",
																																										id = "1486",
																																										properties = {
																																											{
																																												Operator = "GreaterEqual"
																																											},
																																											{
																																												Opl = {
																																													field = "CurrentDistToTarget"
																																												}
																																											},
																																											{
																																												Opr = {
																																													field = "maxSkillDist"
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
																																										id = "1489",
																																										properties = {},
																																										attachments = {},
																																										children = {
																																											{
																																												node = {
																																													class = "Action",
																																													id = "1487",
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
																																													class = "Action",
																																													id = "1495",
																																													properties = {
																																														{
																																															Method = {
																																																func = "castCombo",
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
																																													id = "1525",
																																													properties = {
																																														{
																																															Method = {
																																																func = "showEmojiBubble",
																																																params = {
																																																	{
																																																		const = "Happy"
																																																	},
																																																	{
																																																		const = 5
																																																	},
																																																	{
																																																		const = false
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
																																										id = "1526",
																																										properties = {},
																																										attachments = {},
																																										children = {
																																											{
																																												node = {
																																													class = "Action",
																																													id = "1496",
																																													properties = {
																																														{
																																															Method = {
																																																func = "castCombo",
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
																																													id = "1527",
																																													properties = {
																																														{
																																															Method = {
																																																func = "showEmojiBubble",
																																																params = {
																																																	{
																																																		const = "Happy"
																																																	},
																																																	{
																																																		const = 5
																																																	},
																																																	{
																																																		const = false
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
																																	class = "Selector",
																																	id = "1499",
																																	properties = {},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				class = "Sequence",
																																				id = "1507",
																																				properties = {},
																																				attachments = {},
																																				children = {
																																					{
																																						node = {
																																							class = "Assignment",
																																							id = "1508",
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
																																							class = "Condition",
																																							id = "1509",
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
																																							class = "Action",
																																							id = "1510",
																																							properties = {
																																								{
																																									Method = {
																																										func = "walkBack",
																																										params = {
																																											{
																																												field = "tgt"
																																											},
																																											{
																																												const = 8
																																											},
																																											{
																																												const = 5
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
																																				id = "1500",
																																				properties = {},
																																				attachments = {},
																																				children = {
																																					{
																																						node = {
																																							class = "DecoratorAlwaysSuccess",
																																							id = "1501",
																																							properties = {
																																								{
																																									DecorateWhenChildEnds = "false"
																																								}
																																							},
																																							attachments = {},
																																							children = {
																																								{
																																									node = {
																																										class = "SelectorProbability",
																																										id = "1502",
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
																																													id = "1503",
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
																																																id = "1518",
																																																properties = {},
																																																attachments = {},
																																																children = {
																																																	{
																																																		node = {
																																																			class = "Action",
																																																			id = "1517",
																																																			properties = {
																																																				{
																																																					Method = {
																																																						func = "showEmojiBubble",
																																																						params = {
																																																							{
																																																								const = "Think"
																																																							},
																																																							{
																																																								const = 5
																																																							},
																																																							{
																																																								const = false
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
																																																			id = "1505",
																																																			properties = {
																																																				{
																																																					Method = {
																																																						func = "sideWalk",
																																																						params = {
																																																							{
																																																								field = "tgt"
																																																							},
																																																							{
																																																								const = 3
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
																																													class = "DecoratorWeight",
																																													id = "1504",
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
																																																id = "1519",
																																																properties = {},
																																																attachments = {},
																																																children = {
																																																	{
																																																		node = {
																																																			class = "Action",
																																																			id = "1520",
																																																			properties = {
																																																				{
																																																					Method = {
																																																						func = "showEmojiBubble",
																																																						params = {
																																																							{
																																																								const = "Think"
																																																							},
																																																							{
																																																								const = 5
																																																							},
																																																							{
																																																								const = false
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
																																																			id = "1506",
																																																			properties = {
																																																				{
																																																					Method = {
																																																						func = "sideWalk",
																																																						params = {
																																																							{
																																																								field = "tgt"
																																																							},
																																																							{
																																																								const = 3
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
																																								}
																																							}
																																						}
																																					},
																																					{
																																						node = {
																																							class = "Action",
																																							id = "1511",
																																							properties = {
																																								{
																																									Method = {
																																										func = "waitTime",
																																										params = {
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
																														class = "Sequence",
																														id = "1516",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	class = "DecoratorAlwaysSuccess",
																																	id = "1482",
																																	properties = {
																																		{
																																			DecorateWhenChildEnds = "false"
																																		}
																																	},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				class = "Sequence",
																																				id = "1473",
																																				properties = {},
																																				attachments = {},
																																				children = {
																																					{
																																						node = {
																																							class = "Selector",
																																							id = "1481",
																																							properties = {},
																																							attachments = {},
																																							children = {
																																								{
																																									node = {
																																										class = "Condition",
																																										id = "1471",
																																										properties = {
																																											{
																																												Operator = "Less"
																																											},
																																											{
																																												Opl = {
																																													func = "getTimerValue",
																																													params = {
																																														{
																																															const = "eventNoticeCD"
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
																																										id = "1472",
																																										properties = {
																																											{
																																												Operator = "GreaterEqual"
																																											},
																																											{
																																												Opl = {
																																													func = "getTimerValue",
																																													params = {
																																														{
																																															const = "eventNoticeCD"
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
																																							id = "1469",
																																							properties = {
																																								{
																																									Method = {
																																										func = "startTimer",
																																										params = {
																																											{
																																												const = "eventNoticeCD"
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
																																	class = "Selector",
																																	id = "1470",
																																	properties = {},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				class = "Sequence",
																																				id = "1474",
																																				properties = {},
																																				attachments = {},
																																				children = {
																																					{
																																						node = {
																																							class = "Assignment",
																																							id = "1479",
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
																																							class = "Condition",
																																							id = "1480",
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
																																							class = "Action",
																																							id = "1475",
																																							properties = {
																																								{
																																									Method = {
																																										func = "walkBack",
																																										params = {
																																											{
																																												field = "tgt"
																																											},
																																											{
																																												const = 8
																																											},
																																											{
																																												const = 5
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
																																				id = "1477",
																																				properties = {},
																																				attachments = {},
																																				children = {
																																					{
																																						node = {
																																							class = "DecoratorAlwaysSuccess",
																																							id = "1494",
																																							properties = {
																																								{
																																									DecorateWhenChildEnds = "false"
																																								}
																																							},
																																							attachments = {},
																																							children = {
																																								{
																																									node = {
																																										class = "SelectorProbability",
																																										id = "1490",
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
																																													id = "1491",
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
																																																id = "1521",
																																																properties = {},
																																																attachments = {},
																																																children = {
																																																	{
																																																		node = {
																																																			class = "Action",
																																																			id = "1522",
																																																			properties = {
																																																				{
																																																					Method = {
																																																						func = "showEmojiBubble",
																																																						params = {
																																																							{
																																																								const = "Think"
																																																							},
																																																							{
																																																								const = 5
																																																							},
																																																							{
																																																								const = false
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
																																																			id = "1478",
																																																			properties = {
																																																				{
																																																					Method = {
																																																						func = "sideWalk",
																																																						params = {
																																																							{
																																																								field = "tgt"
																																																							},
																																																							{
																																																								const = 3
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
																																													class = "DecoratorWeight",
																																													id = "1492",
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
																																																id = "1523",
																																																properties = {},
																																																attachments = {},
																																																children = {
																																																	{
																																																		node = {
																																																			class = "Action",
																																																			id = "1524",
																																																			properties = {
																																																				{
																																																					Method = {
																																																						func = "showEmojiBubble",
																																																						params = {
																																																							{
																																																								const = "Think"
																																																							},
																																																							{
																																																								const = 5
																																																							},
																																																							{
																																																								const = false
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
																																																			id = "1493",
																																																			properties = {
																																																				{
																																																					Method = {
																																																						func = "sideWalk",
																																																						params = {
																																																							{
																																																								field = "tgt"
																																																							},
																																																							{
																																																								const = 3
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
																																								}
																																							}
																																						}
																																					},
																																					{
																																						node = {
																																							class = "Action",
																																							id = "1476",
																																							properties = {
																																								{
																																									Method = {
																																										func = "waitTime",
																																										params = {
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
																								class = "Sequence",
																								id = "1555",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											class = "Condition",
																											id = "1529",
																											properties = {
																												{
																													Operator = "Equal"
																												},
																												{
																													Opl = {
																														func = "checkCharacterState",
																														params = {
																															{
																																const = "FLYING"
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
																											class = "Selector",
																											id = "1530",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														class = "Sequence",
																														id = "1531",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	class = "Condition",
																																	id = "1532",
																																	properties = {
																																		{
																																			Operator = "Equal"
																																		},
																																		{
																																			Opl = {
																																				func = "checkSkillExistByFeatureId",
																																				params = {
																																					{
																																						field = "selfId"
																																					},
																																					{
																																						const = 15
																																					},
																																					{
																																						const = true
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
																																	id = "1533",
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
																																						const = false
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
																																	id = "1534",
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
																																	id = "1542",
																																	properties = {},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				class = "Assignment",
																																				id = "1535",
																																				properties = {
																																					{
																																						CastRight = "false"
																																					},
																																					{
																																						Opl = {
																																							field = "maxSkillDist"
																																						}
																																					},
																																					{
																																						Opr = {
																																							func = "getMaxSkillDist",
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
																																				class = "Assignment",
																																				id = "1536",
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
																																				class = "IfElse",
																																				id = "1537",
																																				properties = {},
																																				attachments = {},
																																				children = {
																																					{
																																						node = {
																																							class = "Condition",
																																							id = "1538",
																																							properties = {
																																								{
																																									Operator = "GreaterEqual"
																																								},
																																								{
																																									Opl = {
																																										field = "CurrentDistToTarget"
																																									}
																																								},
																																								{
																																									Opr = {
																																										field = "maxSkillDist"
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
																																							id = "1539",
																																							properties = {},
																																							attachments = {},
																																							children = {
																																								{
																																									node = {
																																										class = "Action",
																																										id = "1540",
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
																																										class = "Action",
																																										id = "1543",
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
																																					},
																																					{
																																						node = {
																																							class = "Action",
																																							id = "1541",
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
																															}
																														}
																													}
																												},
																												{
																													node = {
																														class = "Sequence",
																														id = "1544",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	class = "Condition",
																																	id = "1551",
																																	properties = {
																																		{
																																			Operator = "Equal"
																																		},
																																		{
																																			Opl = {
																																				func = "checkNormalAttackByTags",
																																				params = {
																																					{
																																						field = "selfId"
																																					},
																																					{
																																						const = 5
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
																																	id = "1548",
																																	properties = {},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				class = "Or",
																																				id = "1547",
																																				properties = {},
																																				attachments = {},
																																				children = {
																																					{
																																						node = {
																																							class = "Condition",
																																							id = "1545",
																																							properties = {
																																								{
																																									Operator = "Less"
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
																																							id = "1546",
																																							properties = {
																																								{
																																									Operator = "Greater"
																																								},
																																								{
																																									Opl = {
																																										field = "CurrentDistToTarget"
																																									}
																																								},
																																								{
																																									Opr = {
																																										field = "maxAttackDist"
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
																																				id = "1549",
																																				properties = {},
																																				attachments = {},
																																				children = {
																																					{
																																						node = {
																																							class = "Action",
																																							id = "1550",
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
																																							class = "Action",
																																							id = "1557",
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
																																		},
																																		{
																																			node = {
																																				class = "Action",
																																				id = "1558",
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
																																				attachments = {
																																					{
																																						precondition = true,
																																						id = "356",
																																						class = "Precondition",
																																						transition = false,
																																						effector = false,
																																						properties = {
																																							{
																																								BinaryOperator = "And"
																																							},
																																							{
																																								Operator = "LessEqual"
																																							},
																																							{
																																								Opl = {
																																									field = "CurrentDistToTarget"
																																								}
																																							},
																																							{
																																								Opr2 = {
																																									field = "maxAttackDist"
																																								}
																																							},
																																							{
																																								Phase = "Update"
																																							}
																																						}
																																					}
																																				},
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
																														id = "1560",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	class = "And",
																																	id = "1561",
																																	properties = {},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				class = "Condition",
																																				id = "1562",
																																				properties = {
																																					{
																																						Operator = "Equal"
																																					},
																																					{
																																						Opl = {
																																							func = "checkSkillExistByFeatureId",
																																							params = {
																																								{
																																									field = "selfId"
																																								},
																																								{
																																									const = 15
																																								},
																																								{
																																									const = true
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
																																				id = "1571",
																																				properties = {
																																					{
																																						Operator = "Equal"
																																					},
																																					{
																																						Opl = {
																																							func = "checkNormalAttackByTags",
																																							params = {
																																								{
																																									field = "selfId"
																																								},
																																								{
																																									const = 5
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
																																		}
																																	}
																																}
																															},
																															{
																																node = {
																																	class = "DecoratorAlwaysSuccess",
																																	id = "1563",
																																	properties = {
																																		{
																																			DecorateWhenChildEnds = "false"
																																		}
																																	},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				class = "Sequence",
																																				id = "1570",
																																				properties = {},
																																				attachments = {},
																																				children = {
																																					{
																																						node = {
																																							class = "Sequence",
																																							id = "1565",
																																							properties = {},
																																							attachments = {
																																								{
																																									precondition = false,
																																									id = "1288",
																																									class = "Effector",
																																									transition = false,
																																									effector = true,
																																									properties = {
																																										{
																																											Operator = "Invalid"
																																										},
																																										{
																																											Opl = {
																																												func = "checkCanMoveToTarget",
																																												params = {
																																													{
																																														field = "tgt"
																																													},
																																													{
																																														const = 5
																																													}
																																												}
																																											}
																																										},
																																										{
																																											Phase = "Success"
																																										}
																																									}
																																								}
																																							},
																																							children = {
																																								{
																																									node = {
																																										class = "Action",
																																										id = "1564",
																																										properties = {
																																											{
																																												Method = {
																																													func = "followEntityInCombat",
																																													params = {
																																														{
																																															field = "masterId"
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
																																							id = "1569",
																																							properties = {},
																																							attachments = {},
																																							children = {
																																								{
																																									node = {
																																										class = "Condition",
																																										id = "1567",
																																										properties = {
																																											{
																																												Operator = "Less"
																																											},
																																											{
																																												Opl = {
																																													func = "getTimerValue",
																																													params = {
																																														{
																																															const = "eventNoticeCD"
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
																																										id = "1568",
																																										properties = {
																																											{
																																												Operator = "GreaterEqual"
																																											},
																																											{
																																												Opl = {
																																													func = "getTimerValue",
																																													params = {
																																														{
																																															const = "eventNoticeCD"
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
																																							id = "1566",
																																							properties = {
																																								{
																																									Method = {
																																										func = "startTimer",
																																										params = {
																																											{
																																												const = "eventNoticeCD"
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
																														id = "1553",
																														properties = {},
																														attachments = {
																															{
																																precondition = false,
																																id = "1288",
																																class = "Effector",
																																transition = false,
																																effector = true,
																																properties = {
																																	{
																																		Operator = "Invalid"
																																	},
																																	{
																																		Opl = {
																																			func = "checkCanMoveToTarget",
																																			params = {
																																				{
																																					field = "tgt"
																																				},
																																				{
																																					const = 5
																																				}
																																			}
																																		}
																																	},
																																	{
																																		Phase = "Success"
																																	}
																																}
																															}
																														},
																														children = {
																															{
																																node = {
																																	class = "Action",
																																	id = "1559",
																																	properties = {
																																		{
																																			Method = {
																																				func = "followEntityInCombat",
																																				params = {
																																					{
																																						field = "masterId"
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
																								class = "DecoratorAlwaysFailure",
																								id = "1552",
																								properties = {
																									{
																										DecorateWhenChildEnds = "false"
																									}
																								},
																								attachments = {},
																								children = {
																									{
																										node = {
																											class = "Noop",
																											id = "1556",
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
																					class = "Selector",
																					id = "1345",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								class = "Sequence",
																								id = "1346",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											class = "Condition",
																											id = "1347",
																											properties = {
																												{
																													Operator = "GreaterEqual"
																												},
																												{
																													Opl = {
																														func = "getSp",
																														params = {
																															{
																																field = "selfId"
																															}
																														}
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
																											class = "Assignment",
																											id = "1351",
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
																														func = "getUltimateSkillId"
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
																											id = "1574",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														class = "Condition",
																														id = "1575",
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
																																	const = 15
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
																														id = "1349",
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
																														id = "1576",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	class = "Action",
																																	id = "1577",
																																	properties = {
																																		{
																																			Method = {
																																				func = "moveToTarget",
																																				params = {
																																					{
																																						field = "tgt"
																																					},
																																					{
																																						const = 15
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
																																	class = "Action",
																																	id = "1578",
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
																								id = "1353",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											class = "Or",
																											id = "1463",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														class = "Condition",
																														id = "1354",
																														properties = {
																															{
																																Operator = "LessEqual"
																															},
																															{
																																Opl = {
																																	func = "getBreakPercent",
																																	params = {
																																		{
																																			field = "tgt"
																																		}
																																	}
																																}
																															},
																															{
																																Opr = {
																																	const = 0.75
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
																														id = "1464",
																														properties = {
																															{
																																Operator = "GreaterEqual"
																															},
																															{
																																Opl = {
																																	field = "CurrentEP"
																																}
																															},
																															{
																																Opr = {
																																	const = 60
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
																											class = "ReferencedBehavior",
																											id = "1152",
																											properties = {
																												{
																													ReferenceBehavior = {
																														const = "PBT_AutoCombat_Attack"
																													}
																												},
																												{
																													subTreeProperties = {
																														{
																															Name = "tShow50PCBubble",
																															Type = "Self",
																															Value = {
																																field = "tShow50PCBubble"
																															}
																														},
																														{
																															Name = "tShow20PCBubble",
																															Type = "Self",
																															Value = {
																																field = "tShow20PCBubble"
																															}
																														},
																														{
																															Name = "CurrentDistToTarget",
																															Type = "Self",
																															Value = {
																																field = "CurrentDistToTarget"
																															}
																														},
																														{
																															Name = "CurrentEP",
																															Type = "Self",
																															Value = {
																																field = "CurrentEP"
																															}
																														},
																														{
																															Name = "CurrentHpPercent",
																															Type = "Self",
																															Value = {
																																field = "CurrentHpPercent"
																															}
																														},
																														{
																															Name = "Weight_JumpBack",
																															Type = "Self",
																															Value = {
																																field = "Weight_JumpBack"
																															}
																														},
																														{
																															Name = "Weight_RunBack",
																															Type = "Self",
																															Value = {
																																field = "Weight_RunBack"
																															}
																														},
																														{
																															Name = "Weight_Skill",
																															Type = "Self",
																															Value = {
																																field = "Weight_Skill"
																															}
																														},
																														{
																															Name = "Weight_CommonAttack",
																															Type = "Self",
																															Value = {
																																field = "Weight_CommonAttack"
																															}
																														},
																														{
																															Name = "Weight_NothingToDo",
																															Type = "Self",
																															Value = {
																																field = "Weight_NothingToDo"
																															}
																														},
																														{
																															Name = "maxSkillDist",
																															Type = "Self",
																															Value = {
																																field = "maxSkillDist"
																															}
																														},
																														{
																															Name = "skillStopDist",
																															Type = "Self",
																															Value = {
																																field = "skillStopDist"
																															}
																														},
																														{
																															Name = "goBackDist",
																															Type = "Self",
																															Value = {
																																field = "goBackDist"
																															}
																														},
																														{
																															Name = "tNewTargetForCatchMode",
																															Type = "Self",
																															Value = {
																																field = "tNewTargetForCatchMode"
																															}
																														},
																														{
																															Name = "CurrentBoxDistToTarget",
																															Type = "Self",
																															Value = {
																																field = "CurrentBoxDistToTarget"
																															}
																														},
																														{
																															Name = "tAngryPrepare",
																															Type = "Self",
																															Value = {
																																field = "tAngryPrepare"
																															}
																														},
																														{
																															Name = "tDrowningDepth",
																															Type = "Self",
																															Value = {
																																field = "tDrowningDepth"
																															}
																														},
																														{
																															Name = "tFlyHeight",
																															Type = "Self",
																															Value = {
																																field = "tFlyHeight"
																															}
																														},
																														{
																															Name = "tVerticalDistToTgt",
																															Type = "Self",
																															Value = {
																																field = "tVerticalDistToTgt"
																															}
																														},
																														{
																															Name = "tSkillPlan",
																															Type = "Self",
																															Value = {
																																field = "tSkillPlan"
																															}
																														},
																														{
																															Name = "tSkillUsed",
																															Type = "Self",
																															Value = {
																																field = "tSkillUsed"
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
																											id = "1357",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														class = "Assignment",
																														id = "1362",
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
																																			const = 13
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
																																			const = 0
																																		},
																																		{
																																			const = false
																																		},
																																		{
																																			const = false
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
																														id = "1365",
																														properties = {
																															{
																																CastRight = "false"
																															},
																															{
																																Opl = {
																																	field = "maxSkillDist"
																																}
																															},
																															{
																																Opr = {
																																	func = "getMaxSkillDist",
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
																														class = "Assignment",
																														id = "1364",
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
																														class = "Condition",
																														id = "1363",
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
																														class = "IfElse",
																														id = "1359",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	class = "Condition",
																																	id = "1360",
																																	properties = {
																																		{
																																			Operator = "GreaterEqual"
																																		},
																																		{
																																			Opl = {
																																				field = "CurrentDistToTarget"
																																			}
																																		},
																																		{
																																			Opr = {
																																				field = "maxSkillDist"
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
																																	id = "1358",
																																	properties = {},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				class = "Action",
																																				id = "1356",
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
																																				class = "Action",
																																				id = "1361",
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
																																		}
																																	}
																																}
																															},
																															{
																																node = {
																																	class = "Action",
																																	id = "1355",
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
																															}
																														}
																													}
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
																					class = "ReferencedBehavior",
																					id = "1579",
																					properties = {
																						{
																							ReferenceBehavior = {
																								const = "PBT_AutoCombat_NormalAtkCombo"
																							}
																						},
																						{
																							subTreeProperties = {
																								{
																									Name = "CurrentDistToTarget",
																									Type = "Self",
																									Value = {
																										field = "CurrentDistToTarget"
																									}
																								},
																								{
																									Name = "CurrentBoxDistToTarget",
																									Type = "Self",
																									Value = {
																										field = "CurrentBoxDistToTarget"
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
																		id = "442",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					class = "And",
																					id = "445",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								class = "Condition",
																								id = "417",
																								properties = {
																									{
																										Operator = "Greater"
																									},
																									{
																										Opl = {
																											field = "CurrentDistToTarget"
																										}
																									},
																									{
																										Opr = {
																											field = "maxAttackDist"
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
																								id = "402",
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
																								id = "415",
																								properties = {
																									{
																										Operator = "Less"
																									},
																									{
																										Opl = {
																											field = "maxAttackDist"
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
																					class = "Sequence",
																					id = "584",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								class = "IfElse",
																								id = "593",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											class = "Condition",
																											id = "592",
																											properties = {
																												{
																													Operator = "Equal"
																												},
																												{
																													Opl = {
																														field = "tAngryPrepare"
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
																											id = "596",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														class = "Action",
																														id = "605",
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
																														class = "Assignment",
																														id = "604",
																														properties = {
																															{
																																CastRight = "false"
																															},
																															{
																																Opl = {
																																	field = "tAngryPrepare"
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
																											class = "Noop",
																											id = "594",
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
																								class = "Condition",
																								id = "599",
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
																											field = "maxAttackDist"
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
																								id = "595",
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
																								class = "IfElse",
																								id = "601",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											class = "Condition",
																											id = "602",
																											properties = {
																												{
																													Operator = "Equal"
																												},
																												{
																													Opl = {
																														field = "tAngryPrepare"
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
																											id = "603",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														class = "Action",
																														id = "597",
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
																																			const = 4
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
																														id = "600",
																														properties = {
																															{
																																CastRight = "false"
																															},
																															{
																																Opl = {
																																	field = "tAngryPrepare"
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
																											class = "Noop",
																											id = "598",
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
																								id = "589",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											class = "Sequence",
																											id = "588",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														class = "Condition",
																														id = "590",
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
																														id = "586",
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
																											id = "587",
																											properties = {
																												{
																													Method = {
																														func = "playAction",
																														params = {
																															{
																																const = "Behav_Angry"
																															},
																															{
																																const = 0
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
																								id = "591",
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
																}
															}
														}
													}
												}
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
}

return PBT_BotPet_AutoCombat_BREAK
