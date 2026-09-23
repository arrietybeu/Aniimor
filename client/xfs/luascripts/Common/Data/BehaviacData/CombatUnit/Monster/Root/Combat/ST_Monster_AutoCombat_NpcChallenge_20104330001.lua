-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\CombatUnit\\Monster\\Root\\Combat\\ST_Monster_AutoCombat_NpcChallenge_20104330001.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local ST_Monster_AutoCombat_NpcChallenge_20104330001 = {
	behavior = {
		useForRoute = false,
		version = 332,
		name = "CombatUnit/Monster/Root/Combat/ST_Monster_AutoCombat_NpcChallenge_20104330001",
		agenttype = "PetAgent",
		properties = {},
		pars = {
			{
				value = "false",
				type = "bool",
				name = "tShow50PCBubble",
				const = false
			},
			{
				value = "false",
				type = "bool",
				name = "tShow20PCBubble",
				const = false
			},
			{
				value = "0",
				type = "float",
				name = "CurrentDistToTarget",
				const = 0
			},
			{
				value = "0",
				type = "float",
				name = "CurrentEP",
				const = 0
			},
			{
				value = "0",
				type = "float",
				name = "CurrentHpPercent",
				const = 0
			},
			{
				value = "0",
				type = "int",
				name = "Weight_JumpBack",
				const = 0
			},
			{
				value = "0",
				type = "int",
				name = "Weight_RunBack",
				const = 0
			},
			{
				value = "0",
				type = "int",
				name = "Weight_Skill",
				const = 0
			},
			{
				value = "0",
				type = "int",
				name = "Weight_CommonAttack",
				const = 0
			},
			{
				value = "0",
				type = "int",
				name = "Weight_NothingToDo",
				const = 0
			},
			{
				value = "0",
				type = "float",
				name = "maxSkillDist",
				const = 0
			},
			{
				value = "0",
				type = "float",
				name = "skillStopDist",
				const = 0
			},
			{
				value = "0",
				type = "float",
				name = "goBackDist",
				const = 0
			},
			{
				value = "0",
				type = "int",
				name = "tNewTargetForCatchMode",
				const = 0
			},
			{
				value = "0",
				type = "float",
				name = "CurrentBoxDistToTarget",
				const = 0
			},
			{
				value = "0",
				type = "int",
				name = "tAngryPrepare",
				const = 0
			},
			{
				value = "0",
				type = "float",
				name = "tDrowningDepth",
				const = 0
			},
			{
				value = "0",
				type = "float",
				name = "tFlyHeight",
				const = 0
			},
			{
				value = "0",
				type = "float",
				name = "tVerticalDistToTgt",
				const = 0
			},
			{
				value = "0",
				type = "string",
				name = "tSkillPlan",
				const = "0"
			},
			{
				value = "0",
				type = "int",
				name = "tSkillUsed",
				const = 0
			},
			{
				value = "0",
				type = "string",
				name = "tCurrentTactics",
				const = "0"
			},
			{
				value = "0",
				type = "float",
				name = "Skillcd",
				const = 0
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
						class = "Action",
						id = "1405",
						properties = {
							{
								Method = {
									func = "startTimer",
									params = {
										{
											const = "Skillcd"
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
									class = "Parallel",
									id = "10",
									properties = {
										{
											ChildFinishPolicy = "CHILDFINISH_LOOP"
										},
										{
											ExitPolicy = "EXIT_ABORT_RUNNINGSIBLINGS"
										},
										{
											FailurePolicy = "FAIL_ON_ONE"
										},
										{
											SuccessPolicy = "SUCCEED_ON_ALL"
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
																		id = "1398",
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
																		id = "1366",
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
																		id = "1410",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					class = "Sequence",
																					id = "1400",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								class = "Condition",
																								id = "1369",
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
																											const = "SUP"
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
																								id = "1386",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											class = "Assignment",
																											id = "1388",
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
																											class = "Condition",
																											id = "1391",
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
																											id = "1390",
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
																											class = "Action",
																											id = "1403",
																											properties = {
																												{
																													Method = {
																														func = "waitTime",
																														params = {
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
																					class = "Sequence",
																					id = "1346",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								class = "Condition",
																								id = "1404",
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
																											const = "DPS"
																										}
																									}
																								},
																								attachments = {},
																								children = {}
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
																												Type = "Self",
																												Name = "tShow50PCBubble",
																												Value = {
																													field = "tShow50PCBubble"
																												}
																											},
																											{
																												Type = "Self",
																												Name = "tShow20PCBubble",
																												Value = {
																													field = "tShow20PCBubble"
																												}
																											},
																											{
																												Type = "Self",
																												Name = "CurrentDistToTarget",
																												Value = {
																													field = "CurrentDistToTarget"
																												}
																											},
																											{
																												Type = "Self",
																												Name = "CurrentEP",
																												Value = {
																													field = "CurrentEP"
																												}
																											},
																											{
																												Type = "Self",
																												Name = "CurrentHpPercent",
																												Value = {
																													field = "CurrentHpPercent"
																												}
																											},
																											{
																												Type = "Self",
																												Name = "Weight_JumpBack",
																												Value = {
																													field = "Weight_JumpBack"
																												}
																											},
																											{
																												Type = "Self",
																												Name = "Weight_RunBack",
																												Value = {
																													field = "Weight_RunBack"
																												}
																											},
																											{
																												Type = "Self",
																												Name = "Weight_Skill",
																												Value = {
																													field = "Weight_Skill"
																												}
																											},
																											{
																												Type = "Self",
																												Name = "Weight_CommonAttack",
																												Value = {
																													field = "Weight_CommonAttack"
																												}
																											},
																											{
																												Type = "Self",
																												Name = "Weight_NothingToDo",
																												Value = {
																													field = "Weight_NothingToDo"
																												}
																											},
																											{
																												Type = "Self",
																												Name = "maxSkillDist",
																												Value = {
																													field = "maxSkillDist"
																												}
																											},
																											{
																												Type = "Self",
																												Name = "skillStopDist",
																												Value = {
																													field = "skillStopDist"
																												}
																											},
																											{
																												Type = "Self",
																												Name = "goBackDist",
																												Value = {
																													field = "goBackDist"
																												}
																											},
																											{
																												Type = "Self",
																												Name = "tNewTargetForCatchMode",
																												Value = {
																													field = "tNewTargetForCatchMode"
																												}
																											},
																											{
																												Type = "Self",
																												Name = "CurrentBoxDistToTarget",
																												Value = {
																													field = "CurrentBoxDistToTarget"
																												}
																											},
																											{
																												Type = "Self",
																												Name = "tAngryPrepare",
																												Value = {
																													field = "tAngryPrepare"
																												}
																											},
																											{
																												Type = "Self",
																												Name = "tDrowningDepth",
																												Value = {
																													field = "tDrowningDepth"
																												}
																											},
																											{
																												Type = "Self",
																												Name = "tFlyHeight",
																												Value = {
																													field = "tFlyHeight"
																												}
																											},
																											{
																												Type = "Self",
																												Name = "tVerticalDistToTgt",
																												Value = {
																													field = "tVerticalDistToTgt"
																												}
																											},
																											{
																												Type = "Self",
																												Name = "tSkillPlan",
																												Value = {
																													field = "tSkillPlan"
																												}
																											},
																											{
																												Type = "Self",
																												Name = "tSkillUsed",
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
																						}
																					}
																				}
																			},
																			{
																				node = {
																					class = "Sequence",
																					id = "1406",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								class = "Condition",
																								id = "1411",
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
																											const = "ENERGY"
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
																								id = "1407",
																								properties = {
																									{
																										Operator = "GreaterEqual"
																									},
																									{
																										Opl = {
																											func = "getTimerValue",
																											params = {
																												{
																													const = "Skillcd"
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
																								class = "Action",
																								id = "1408",
																								properties = {
																									{
																										Method = {
																											func = "castSkill",
																											params = {
																												{
																													field = "tgt"
																												},
																												{
																													const = 14330100
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
																								id = "1409",
																								properties = {
																									{
																										Method = {
																											func = "startTimer",
																											params = {
																												{
																													const = "Skillcd"
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
																					id = "758",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								class = "Or",
																								id = "757",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											class = "Condition",
																											id = "755",
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
																											id = "756",
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
																								id = "759",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											class = "Action",
																											id = "760",
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
																											id = "761",
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
																								id = "762",
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
																										class = "Precondition",
																										transition = false,
																										effector = false,
																										precondition = true,
																										id = "356",
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
												id = "80",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															class = "Sequence",
															id = "87",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		class = "And",
																		id = "100",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					class = "Condition",
																					id = "101",
																					properties = {
																						{
																							Operator = "Less"
																						},
																						{
																							Opl = {
																								func = "getHpPercent",
																								params = {
																									{
																										const = 0
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
																					id = "102",
																					properties = {
																						{
																							Operator = "Equal"
																						},
																						{
																							Opl = {
																								field = "tShow50PCBubble"
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
																		class = "Action",
																		id = "93",
																		properties = {
																			{
																				Method = {
																					func = "showEmojiBubble",
																					params = {
																						{
																							const = "Cry"
																						},
																						{
																							const = 3
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
																		class = "Assignment",
																		id = "92",
																		properties = {
																			{
																				CastRight = "true"
																			},
																			{
																				Opl = {
																					field = "tShow50PCBubble"
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
															class = "Sequence",
															id = "88",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		class = "Condition",
																		id = "94",
																		properties = {
																			{
																				Operator = "GreaterEqual"
																			},
																			{
																				Opl = {
																					func = "getHpPercent",
																					params = {
																						{
																							const = 0
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
																		class = "Assignment",
																		id = "95",
																		properties = {
																			{
																				CastRight = "true"
																			},
																			{
																				Opl = {
																					field = "tShow50PCBubble"
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
															class = "Sequence",
															id = "89",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		class = "And",
																		id = "103",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					class = "Condition",
																					id = "104",
																					properties = {
																						{
																							Operator = "Less"
																						},
																						{
																							Opl = {
																								func = "getHpPercent",
																								params = {
																									{
																										const = 0
																									}
																								}
																							}
																						},
																						{
																							Opr = {
																								const = 0.2
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
																					id = "105",
																					properties = {
																						{
																							Operator = "Equal"
																						},
																						{
																							Opl = {
																								field = "tShow20PCBubble"
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
																		class = "Action",
																		id = "96",
																		properties = {
																			{
																				Method = {
																					func = "showEmojiBubble",
																					params = {
																						{
																							const = "Cry"
																						},
																						{
																							const = 3
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
																		class = "Assignment",
																		id = "97",
																		properties = {
																			{
																				CastRight = "true"
																			},
																			{
																				Opl = {
																					field = "tShow20PCBubble"
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
															class = "Sequence",
															id = "90",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		class = "Condition",
																		id = "98",
																		properties = {
																			{
																				Operator = "GreaterEqual"
																			},
																			{
																				Opl = {
																					func = "getHpPercent",
																					params = {
																						{
																							const = 0
																						}
																					}
																				}
																			},
																			{
																				Opr = {
																					const = 0.2
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
																		id = "99",
																		properties = {
																			{
																				CastRight = "true"
																			},
																			{
																				Opl = {
																					field = "tShow20PCBubble"
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
															class = "Noop",
															id = "91",
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

return ST_Monster_AutoCombat_NpcChallenge_20104330001
