-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\CombatUnit\\NPC\\BotPet\\151004\\PBT_BotPet_AutoCombat_DPS_151004.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_BotPet_AutoCombat_DPS_151004 = {
	behavior = {
		version = 340,
		useForRoute = false,
		agenttype = "PetAgent",
		name = "CombatUnit/NPC/BotPet/151004/PBT_BotPet_AutoCombat_DPS_151004",
		properties = {},
		pars = {
			{
				name = "tShow50PCBubble",
				value = "false",
				type = "bool",
				const = false
			},
			{
				name = "tShow20PCBubble",
				value = "false",
				type = "bool",
				const = false
			},
			{
				name = "CurrentDistToTarget",
				value = "0",
				type = "float",
				const = 0
			},
			{
				name = "CurrentEP",
				value = "0",
				type = "float",
				const = 0
			},
			{
				name = "CurrentHpPercent",
				value = "0",
				type = "float",
				const = 0
			},
			{
				name = "Weight_JumpBack",
				value = "0",
				type = "int",
				const = 0
			},
			{
				name = "Weight_RunBack",
				value = "0",
				type = "int",
				const = 0
			},
			{
				name = "Weight_Skill",
				value = "0",
				type = "int",
				const = 0
			},
			{
				name = "Weight_CommonAttack",
				value = "0",
				type = "int",
				const = 0
			},
			{
				name = "Weight_NothingToDo",
				value = "0",
				type = "int",
				const = 0
			},
			{
				name = "maxSkillDist",
				value = "0",
				type = "float",
				const = 0
			},
			{
				name = "skillStopDist",
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
				name = "tNewTargetForCatchMode",
				value = "0",
				type = "int",
				const = 0
			},
			{
				name = "CurrentBoxDistToTarget",
				value = "0",
				type = "float",
				const = 0
			},
			{
				name = "tAngryPrepare",
				value = "0",
				type = "int",
				const = 0
			},
			{
				name = "tDrowningDepth",
				value = "0",
				type = "float",
				const = 0
			},
			{
				name = "tFlyHeight",
				value = "0",
				type = "float",
				const = 0
			},
			{
				name = "tVerticalDistToTgt",
				value = "0",
				type = "float",
				const = 0
			},
			{
				name = "tSkillPlan",
				value = "0",
				type = "string",
				const = "0"
			},
			{
				name = "tSkillUsed",
				value = "0",
				type = "int",
				const = 0
			},
			{
				name = "tCurrentTactics",
				value = "",
				type = "string",
				const = ""
			}
		},
		attachments = {},
		node = {
			id = "569",
			class = "Sequence",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						id = "687",
						class = "Compute",
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
						id = "686",
						class = "Assignment",
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
						id = "570",
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
									id = "464",
									class = "Sequence",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "117",
												class = "Sequence",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "1461",
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
															id = "116",
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
															id = "550",
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
													},
													{
														node = {
															id = "121",
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
															id = "118",
															class = "Assignment",
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
															id = "229",
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
													},
													{
														node = {
															id = "252",
															class = "Assignment",
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
															id = "249",
															class = "Assignment",
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
															id = "250",
															class = "Assignment",
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
															id = "251",
															class = "Assignment",
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
															id = "458",
															class = "Assignment",
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
															id = "1123",
															class = "Assignment",
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
															id = "1573",
															class = "Assignment",
															properties = {
																{
																	CastRight = "false"
																},
																{
																	Opl = {
																		field = "tCurrentTactics"
																	}
																},
																{
																	Opr = {
																		func = "getMasterCombatTactic"
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
												id = "6",
												class = "Selector",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "624",
															class = "Sequence",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		id = "623",
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
																		id = "640",
																		class = "IfElse",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					id = "641",
																					class = "And",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								id = "635",
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
																								id = "642",
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
																					id = "638",
																					class = "Sequence",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								id = "649",
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
																								id = "648",
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
																					id = "689",
																					class = "Sequence",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								id = "690",
																								class = "Assignment",
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
																								id = "645",
																								class = "IfElse",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											id = "653",
																											class = "And",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "636",
																														class = "Condition",
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
																														id = "678",
																														class = "Condition",
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
																											id = "679",
																											class = "IfElse",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "652",
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
																														id = "661",
																														class = "Sequence",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	id = "691",
																																	class = "Compute",
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
																																	id = "659",
																																	class = "Action",
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
																																	id = "658",
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
																																	id = "660",
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
																														id = "680",
																														class = "Sequence",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	id = "682",
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
																																	id = "681",
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
																											id = "664",
																											class = "Selector",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "627",
																														class = "Sequence",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	id = "677",
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
																																	id = "628",
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
																														id = "665",
																														class = "IfElse",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	id = "663",
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
																																	id = "669",
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
																																	id = "671",
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
																}
															}
														}
													},
													{
														node = {
															id = "436",
															class = "Selector",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		id = "1538",
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
																								id = "1636",
																								class = "Selector",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											id = "1345",
																											class = "Selector",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "1510",
																														class = "Sequence",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	id = "1506",
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
																																						field = "tgt"
																																					},
																																					{
																																						const = 10003
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
																																	id = "1346",
																																	class = "Sequence",
																																	properties = {},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				id = "1347",
																																				class = "Condition",
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
																																				id = "1351",
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
																																				id = "1694",
																																				class = "IfElse",
																																				properties = {},
																																				attachments = {},
																																				children = {
																																					{
																																						node = {
																																							id = "1695",
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
																																							id = "1693",
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
																																									ResultResumeOption = "BT_ResumeSelf"
																																								}
																																							},
																																							attachments = {},
																																							children = {}
																																						}
																																					},
																																					{
																																						node = {
																																							id = "1696",
																																							class = "Sequence",
																																							properties = {},
																																							attachments = {},
																																							children = {
																																								{
																																									node = {
																																										id = "1697",
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
																																										id = "1698",
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
																														id = "1558",
																														class = "Sequence",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	id = "1566",
																																	class = "Condition",
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
																																	id = "1561",
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
																																	id = "1700",
																																	class = "IfElse",
																																	properties = {},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				id = "1701",
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
																																				id = "1699",
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
																																						ResultResumeOption = "BT_ResumeSelf"
																																					}
																																				},
																																				attachments = {},
																																				children = {}
																																			}
																																		},
																																		{
																																			node = {
																																				id = "1702",
																																				class = "Sequence",
																																				properties = {},
																																				attachments = {},
																																				children = {
																																					{
																																						node = {
																																							id = "1703",
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
																																							id = "1704",
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
																											id = "1676",
																											class = "IfElse",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "1650",
																														class = "Selector",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	id = "1649",
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
																																						const = "shieldBlockCD"
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
																															},
																															{
																																node = {
																																	id = "1648",
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
																																						const = "shieldBlockCD"
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
																														id = "1651",
																														class = "Selector",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	id = "1537",
																																	class = "Selector",
																																	properties = {},
																																	attachments = {
																																		{
																																			id = "1638",
																																			transition = false,
																																			class = "Precondition",
																																			precondition = true,
																																			effector = false,
																																			properties = {
																																				{
																																					BinaryOperator = "Or"
																																				},
																																				{
																																					Operator = "Equal"
																																				},
																																				{
																																					Opl = {
																																						func = "isInSkill",
																																						params = {
																																							{
																																								field = "tgt"
																																							},
																																							{
																																								const = 0
																																							}
																																						}
																																					}
																																				},
																																				{
																																					Opr2 = {
																																						const = false
																																					}
																																				},
																																				{
																																					Phase = "Both"
																																				}
																																			}
																																		},
																																		{
																																			id = "1640",
																																			transition = false,
																																			class = "Precondition",
																																			precondition = true,
																																			effector = false,
																																			properties = {
																																				{
																																					BinaryOperator = "Or"
																																				},
																																				{
																																					Operator = "Equal"
																																				},
																																				{
																																					Opl = {
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
																																				id = "1548",
																																				class = "Sequence",
																																				properties = {},
																																				attachments = {},
																																				children = {
																																					{
																																						node = {
																																							id = "1547",
																																							class = "Condition",
																																							properties = {
																																								{
																																									Operator = "Equal"
																																								},
																																								{
																																									Opl = {
																																										field = "tCurrentTactics"
																																									}
																																								},
																																								{
																																									Opr = {
																																										const = "Tactics_STORE"
																																									}
																																								}
																																							},
																																							attachments = {},
																																							children = {}
																																						}
																																					},
																																					{
																																						node = {
																																							id = "1707",
																																							class = "ReferencedBehavior",
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
																																				id = "1552",
																																				class = "Sequence",
																																				properties = {},
																																				attachments = {},
																																				children = {
																																					{
																																						node = {
																																							id = "1551",
																																							class = "Condition",
																																							properties = {
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
																																												const = 91323020
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
																																							id = "1550",
																																							class = "Condition",
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
																																					},
																																					{
																																						node = {
																																							id = "1554",
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
																																												const = 12
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
																																							id = "1574",
																																							class = "Assignment",
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
																																							id = "1575",
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
																																							id = "1576",
																																							class = "IfElse",
																																							properties = {},
																																							attachments = {},
																																							children = {
																																								{
																																									node = {
																																										id = "1577",
																																										class = "Condition",
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
																																										id = "1579",
																																										class = "Sequence",
																																										properties = {},
																																										attachments = {},
																																										children = {
																																											{
																																												node = {
																																													id = "1578",
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
																																													id = "1585",
																																													class = "Action",
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
																																																		const = 4
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
																																											}
																																										}
																																									}
																																								},
																																								{
																																									node = {
																																										id = "1583",
																																										class = "Sequence",
																																										properties = {},
																																										attachments = {},
																																										children = {
																																											{
																																												node = {
																																													id = "1555",
																																													class = "Action",
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
																																																		const = 4
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
																																				id = "1706",
																																				class = "ReferencedBehavior",
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
																																	id = "1532",
																																	class = "Sequence",
																																	properties = {},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				id = "1567",
																																				class = "Condition",
																																				properties = {
																																					{
																																						Operator = "Equal"
																																					},
																																					{
																																						Opl = {
																																							func = "isInSkill",
																																							params = {
																																								{
																																									field = "tgt"
																																								},
																																								{
																																									const = 0
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
																																				id = "1527",
																																				class = "Sequence",
																																				properties = {},
																																				attachments = {},
																																				children = {
																																					{
																																						node = {
																																							id = "1641",
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
																																							id = "1642",
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
																																							id = "1529",
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
																																							id = "1588",
																																							class = "Action",
																																							properties = {
																																								{
																																									Method = {
																																										func = "startTimer",
																																										params = {
																																											{
																																												const = "shieldBlockCD"
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
																														id = "1675",
																														class = "Selector",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	id = "1661",
																																	class = "Sequence",
																																	properties = {},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				id = "1660",
																																				class = "Condition",
																																				properties = {
																																					{
																																						Operator = "Equal"
																																					},
																																					{
																																						Opl = {
																																							field = "tCurrentTactics"
																																						}
																																					},
																																					{
																																						Opr = {
																																							const = "Tactics_STORE"
																																						}
																																					}
																																				},
																																				attachments = {},
																																				children = {}
																																			}
																																		},
																																		{
																																			node = {
																																				id = "1708",
																																				class = "ReferencedBehavior",
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
																																	id = "1664",
																																	class = "Sequence",
																																	properties = {},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				id = "1663",
																																				class = "Condition",
																																				properties = {
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
																																									const = 91323020
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
																																				id = "1662",
																																				class = "Condition",
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
																																		},
																																		{
																																			node = {
																																				id = "1665",
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
																																									const = 12
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
																																				id = "1672",
																																				class = "Assignment",
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
																																				id = "1671",
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
																																				id = "1670",
																																				class = "IfElse",
																																				properties = {},
																																				attachments = {},
																																				children = {
																																					{
																																						node = {
																																							id = "1669",
																																							class = "Condition",
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
																																							id = "1667",
																																							class = "Sequence",
																																							properties = {},
																																							attachments = {},
																																							children = {
																																								{
																																									node = {
																																										id = "1673",
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
																																										id = "1674",
																																										class = "Action",
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
																																															const = 4
																																														},
																																														{
																																															const = 0
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
																																							id = "1668",
																																							class = "Sequence",
																																							properties = {},
																																							attachments = {},
																																							children = {
																																								{
																																									node = {
																																										id = "1666",
																																										class = "Action",
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
																																															const = 4
																																														},
																																														{
																																															const = 0
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
																															},
																															{
																																node = {
																																	id = "1705",
																																	class = "ReferencedBehavior",
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
																												}
																											}
																										}
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
																		id = "442",
																		class = "IfElse",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					id = "445",
																					class = "And",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								id = "417",
																								class = "Condition",
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
																								id = "402",
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
																								id = "415",
																								class = "Condition",
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
																					id = "584",
																					class = "Sequence",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								id = "593",
																								class = "IfElse",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											id = "592",
																											class = "Condition",
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
																											id = "596",
																											class = "Sequence",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "605",
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
																														id = "604",
																														class = "Assignment",
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
																											id = "594",
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
																								id = "599",
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
																								id = "595",
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
																								id = "601",
																								class = "IfElse",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											id = "602",
																											class = "Condition",
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
																											id = "603",
																											class = "Sequence",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "597",
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
																														id = "600",
																														class = "Assignment",
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
																											id = "598",
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
																								id = "589",
																								class = "Selector",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											id = "588",
																											class = "Sequence",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "590",
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
																														id = "586",
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
																											id = "587",
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
																								id = "591",
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

return PBT_BotPet_AutoCombat_DPS_151004
