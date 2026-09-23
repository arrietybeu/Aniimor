-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\CombatUnit\\Monster\\Root\\Combat\\ST_Monster_AutoCombat_Boss_10163.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local ST_Monster_AutoCombat_Boss_10163 = {
	behavior = {
		name = "CombatUnit/Monster/Root/Combat/ST_Monster_AutoCombat_Boss_10163",
		version = 104,
		useForRoute = false,
		agenttype = "PuppetAgent",
		properties = {},
		pars = {
			{
				type = "int",
				name = "tSkill_ComboAttack",
				const = 0,
				value = "0"
			},
			{
				type = "int",
				name = "tSkill_11630400",
				const = 0,
				value = "0"
			},
			{
				type = "int",
				name = "tSkill_11631200",
				const = 0,
				value = "0"
			},
			{
				type = "int",
				name = "tSkill_11631300",
				const = 0,
				value = "0"
			},
			{
				type = "int",
				name = "tSkill_11631301",
				const = 0,
				value = "0"
			},
			{
				type = "int",
				name = "tSkill_11631302",
				const = 0,
				value = "0"
			},
			{
				type = "int",
				name = "tSkill_11631303",
				const = 0,
				value = "0"
			},
			{
				type = "int",
				name = "tSkill_11631400",
				const = 0,
				value = "0"
			},
			{
				type = "int",
				name = "tSkill_11631500",
				const = 0,
				value = "0"
			},
			{
				type = "int",
				name = "tSkill_11631501",
				const = 0,
				value = "0"
			},
			{
				type = "int",
				name = "tSkill_11631600",
				const = 0,
				value = "0"
			},
			{
				type = "int",
				name = "tSkill_11631700",
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
				type = "int",
				name = "tPlayer",
				const = 0,
				value = "0"
			},
			{
				type = "bool",
				name = "tMechanismed",
				const = false,
				value = "false"
			},
			{
				type = "int",
				name = "tSkill_11630430",
				const = 0,
				value = "0"
			},
			{
				type = "float",
				name = "tBoxDist",
				const = 0,
				value = "0"
			}
		},
		attachments = {},
		node = {
			class = "Sequence",
			id = "198",
			properties = {},
			attachments = {},
			children = {
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
						class = "Action",
						id = "311",
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
						class = "Action",
						id = "466",
						properties = {
							{
								Method = {
									func = "startTimer",
									params = {
										{
											const = "fightInterval"
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
									id = "4",
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
												class = "Condition",
												id = "5",
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
												id = "6",
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
												id = "7",
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
												class = "Assignment",
												id = "251",
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
												class = "Assignment",
												id = "526",
												properties = {
													{
														CastRight = "false"
													},
													{
														Opl = {
															field = "tBoxDist"
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
												class = "IfElse",
												id = "256",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															class = "And",
															id = "301",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		class = "Condition",
																		id = "506",
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
																							const = 91163042
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
																		class = "Condition",
																		id = "302",
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
																							const = 11631200
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
															class = "Sequence",
															id = "260",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		class = "Assignment",
																		id = "296",
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
																							const = 11631200
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
																		id = "294",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					class = "Condition",
																					id = "297",
																					properties = {
																						{
																							Operator = "LessEqual"
																						},
																						{
																							Opl = {
																								func = "getMaxSkillDist",
																								params = {
																									{
																										const = 11631200
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
																					class = "Sequence",
																					id = "295",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								class = "Assignment",
																								id = "298",
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
																													const = 11631200
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
																								id = "299",
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
																					class = "Noop",
																					id = "293",
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
																		id = "261",
																		properties = {
																			{
																				Method = {
																					func = "castSkill",
																					params = {
																						{
																							field = "tPlayer"
																						},
																						{
																							const = 11631200
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
																		class = "Action",
																		id = "479",
																		properties = {
																			{
																				Method = {
																					func = "playAction",
																					params = {
																						{
																							const = "Behav_AlertLoop"
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
																		id = "480",
																		properties = {
																			{
																				Method = {
																					func = "playAction",
																					params = {
																						{
																							const = "Behav_AlertEnd"
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
															class = "Selector",
															id = "303",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		class = "Sequence",
																		id = "304",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					class = "Condition",
																					id = "305",
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
																					id = "307",
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
																										const = 11631400
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
																					id = "308",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								class = "Condition",
																								id = "309",
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
																											const = 8
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
																								id = "313",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											class = "Action",
																											id = "315",
																											properties = {
																												{
																													Method = {
																														func = "castSkill",
																														params = {
																															{
																																field = "tgt"
																															},
																															{
																																const = 11631400
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
																											id = "316",
																											properties = {
																												{
																													Method = {
																														func = "castSkill",
																														params = {
																															{
																																field = "tgt"
																															},
																															{
																																const = 11631700
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
																								id = "310",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											class = "Selector",
																											id = "320",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														class = "Condition",
																														id = "321",
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
																														class = "Condition",
																														id = "322",
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
																												}
																											}
																										}
																									},
																									{
																										node = {
																											class = "Action",
																											id = "312",
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
																											class = "Action",
																											id = "318",
																											properties = {
																												{
																													Method = {
																														func = "castSkill",
																														params = {
																															{
																																field = "tgt"
																															},
																															{
																																const = 11631400
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
																											id = "319",
																											properties = {
																												{
																													Method = {
																														func = "castSkill",
																														params = {
																															{
																																field = "tgt"
																															},
																															{
																																const = 11631700
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
																		id = "438",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					class = "Condition",
																					id = "439",
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
																					class = "Condition",
																					id = "441",
																					properties = {
																						{
																							Operator = "Equal"
																						},
																						{
																							Opl = {
																								field = "fightCd"
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
																					id = "443",
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
																										const = 11631303
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
																					id = "442",
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
																					id = "450",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								class = "Assignment",
																								id = "446",
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
																													const = 11631303
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
																								id = "451",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											class = "Condition",
																											id = "449",
																											properties = {
																												{
																													Operator = "LessEqual"
																												},
																												{
																													Opl = {
																														func = "getMaxSkillDist",
																														params = {
																															{
																																const = 11631303
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
																											class = "Sequence",
																											id = "452",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														class = "Assignment",
																														id = "453",
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
																																			const = 11631303
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
																														id = "447",
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
																											class = "Noop",
																											id = "448",
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
																								id = "445",
																								properties = {
																									{
																										Method = {
																											func = "castSkill",
																											params = {
																												{
																													field = "tgt"
																												},
																												{
																													const = 11631303
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
																								id = "493",
																								properties = {
																									{
																										Method = {
																											func = "playAction",
																											params = {
																												{
																													const = "Behav_AlertLoop"
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
																								id = "494",
																								properties = {
																									{
																										Method = {
																											func = "playAction",
																											params = {
																												{
																													const = "Behav_AlertEnd"
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
																								field = "tBoxDist"
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
																					class = "Sequence",
																					id = "458",
																					properties = {},
																					attachments = {},
																					children = {
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
																						},
																						{
																							node = {
																								class = "Assignment",
																								id = "457",
																								properties = {
																									{
																										CastRight = "false"
																									},
																									{
																										Opl = {
																											field = "tSkill_11630430"
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
																								id = "455",
																								properties = {
																									{
																										CastRight = "false"
																									},
																									{
																										Opl = {
																											field = "tSkill_11631301"
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
																								id = "459",
																								properties = {
																									{
																										CastRight = "false"
																									},
																									{
																										Opl = {
																											field = "tSkill_11631302"
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
																								id = "463",
																								properties = {
																									{
																										CastRight = "false"
																									},
																									{
																										Opl = {
																											field = "tSkill_11631303"
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
																								id = "461",
																								properties = {
																									{
																										CastRight = "false"
																									},
																									{
																										Opl = {
																											field = "tSkill_11631500"
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
																								id = "456",
																								properties = {
																									{
																										CastRight = "false"
																									},
																									{
																										Opl = {
																											field = "tSkill_11631501"
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
																								id = "462",
																								properties = {
																									{
																										CastRight = "false"
																									},
																									{
																										Opl = {
																											field = "tSkill_11631600"
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
																								id = "460",
																								properties = {
																									{
																										CastRight = "false"
																									},
																									{
																										Opl = {
																											field = "tSkill_11631700"
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
																																	class = "Sequence",
																																	id = "470",
																																	properties = {},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				class = "IfElse",
																																				id = "472",
																																				properties = {},
																																				attachments = {},
																																				children = {
																																					{
																																						node = {
																																							class = "Condition",
																																							id = "471",
																																							properties = {
																																								{
																																									Operator = "Greater"
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
																																							class = "Selector",
																																							id = "467",
																																							properties = {},
																																							attachments = {},
																																							children = {
																																								{
																																									node = {
																																										class = "Condition",
																																										id = "468",
																																										properties = {
																																											{
																																												Operator = "GreaterEqual"
																																											},
																																											{
																																												Opl = {
																																													func = "getTimerValue",
																																													params = {
																																														{
																																															const = "fightInterval"
																																														}
																																													}
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
																																								},
																																								{
																																									node = {
																																										class = "Condition",
																																										id = "469",
																																										properties = {
																																											{
																																												Operator = "LessEqual"
																																											},
																																											{
																																												Opl = {
																																													func = "getTimerValue",
																																													params = {
																																														{
																																															const = "fightInterval"
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
																																							class = "True",
																																							id = "478",
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
																																				class = "Sequence",
																																				id = "24",
																																				properties = {},
																																				attachments = {},
																																				children = {
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
																																					},
																																					{
																																						node = {
																																							class = "IfElse",
																																							id = "323",
																																							properties = {},
																																							attachments = {},
																																							children = {
																																								{
																																									node = {
																																										class = "Condition",
																																										id = "324",
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
																																										class = "IfElse",
																																										id = "353",
																																										properties = {},
																																										attachments = {},
																																										children = {
																																											{
																																												node = {
																																													class = "Condition",
																																													id = "354",
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
																																													class = "Sequence",
																																													id = "382",
																																													properties = {},
																																													attachments = {},
																																													children = {
																																														{
																																															node = {
																																																class = "IfElse",
																																																id = "386",
																																																properties = {},
																																																attachments = {},
																																																children = {
																																																	{
																																																		node = {
																																																			class = "Condition",
																																																			id = "384",
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
																																																								const = 11631303
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
																																																			id = "383",
																																																			properties = {
																																																				{
																																																					CastRight = "false"
																																																				},
																																																				{
																																																					Opl = {
																																																						field = "tSkill_11631303"
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
																																																			class = "Noop",
																																																			id = "385",
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
																																																class = "IfElse",
																																																id = "393",
																																																properties = {},
																																																attachments = {},
																																																children = {
																																																	{
																																																		node = {
																																																			class = "Condition",
																																																			id = "392",
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
																																																								const = 11631501
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
																																																			id = "395",
																																																			properties = {
																																																				{
																																																					CastRight = "false"
																																																				},
																																																				{
																																																					Opl = {
																																																						field = "tSkill_11631501"
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
																																																			class = "Noop",
																																																			id = "394",
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
																																																class = "IfElse",
																																																id = "388",
																																																properties = {},
																																																attachments = {},
																																																children = {
																																																	{
																																																		node = {
																																																			class = "Condition",
																																																			id = "387",
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
																																																								const = 11631301
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
																																																			id = "389",
																																																			properties = {
																																																				{
																																																					CastRight = "false"
																																																				},
																																																				{
																																																					Opl = {
																																																						field = "tSkill_11631301"
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
																																																			class = "Noop",
																																																			id = "390",
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
																																																class = "IfElse",
																																																id = "432",
																																																properties = {},
																																																attachments = {},
																																																children = {
																																																	{
																																																		node = {
																																																			class = "Condition",
																																																			id = "431",
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
																																																								const = 11631600
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
																																																			id = "433",
																																																			properties = {
																																																				{
																																																					CastRight = "false"
																																																				},
																																																				{
																																																					Opl = {
																																																						field = "tSkill_11631600"
																																																					}
																																																				},
																																																				{
																																																					Opr = {
																																																						const = 80
																																																					}
																																																				}
																																																			},
																																																			attachments = {},
																																																			children = {}
																																																		}
																																																	},
																																																	{
																																																		node = {
																																																			class = "Noop",
																																																			id = "430",
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
																																																class = "Compute",
																																																id = "391",
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
																																													id = "364",
																																													properties = {},
																																													attachments = {},
																																													children = {
																																														{
																																															node = {
																																																class = "IfElse",
																																																id = "366",
																																																properties = {},
																																																attachments = {},
																																																children = {
																																																	{
																																																		node = {
																																																			class = "Condition",
																																																			id = "365",
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
																																																								const = 11630430
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
																																																			id = "367",
																																																			properties = {
																																																				{
																																																					CastRight = "false"
																																																				},
																																																				{
																																																					Opl = {
																																																						field = "tSkill_11630430"
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
																																																			class = "Noop",
																																																			id = "368",
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
																																																class = "IfElse",
																																																id = "379",
																																																properties = {},
																																																attachments = {},
																																																children = {
																																																	{
																																																		node = {
																																																			class = "Condition",
																																																			id = "378",
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
																																																								const = 11631501
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
																																																			id = "380",
																																																			properties = {
																																																				{
																																																					CastRight = "false"
																																																				},
																																																				{
																																																					Opl = {
																																																						field = "tSkill_11631501"
																																																					}
																																																				},
																																																				{
																																																					Opr = {
																																																						const = 250
																																																					}
																																																				}
																																																			},
																																																			attachments = {},
																																																			children = {}
																																																		}
																																																	},
																																																	{
																																																		node = {
																																																			class = "Noop",
																																																			id = "381",
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
																																																class = "IfElse",
																																																id = "370",
																																																properties = {},
																																																attachments = {},
																																																children = {
																																																	{
																																																		node = {
																																																			class = "Condition",
																																																			id = "369",
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
																																																								const = 11631303
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
																																																			id = "371",
																																																			properties = {
																																																				{
																																																					CastRight = "false"
																																																				},
																																																				{
																																																					Opl = {
																																																						field = "tSkill_11631303"
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
																																																			class = "Noop",
																																																			id = "372",
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
																																																class = "IfElse",
																																																id = "375",
																																																properties = {},
																																																attachments = {},
																																																children = {
																																																	{
																																																		node = {
																																																			class = "Condition",
																																																			id = "374",
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
																																																								const = 11631600
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
																																																			id = "376",
																																																			properties = {
																																																				{
																																																					CastRight = "false"
																																																				},
																																																				{
																																																					Opl = {
																																																						field = "tSkill_11631600"
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
																																																			class = "Noop",
																																																			id = "377",
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
																																																class = "Compute",
																																																id = "373",
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
																																										class = "IfElse",
																																										id = "187",
																																										properties = {},
																																										attachments = {},
																																										children = {
																																											{
																																												node = {
																																													class = "Condition",
																																													id = "186",
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
																																													class = "Sequence",
																																													id = "190",
																																													properties = {},
																																													attachments = {},
																																													children = {
																																														{
																																															node = {
																																																class = "IfElse",
																																																id = "194",
																																																properties = {},
																																																attachments = {},
																																																children = {
																																																	{
																																																		node = {
																																																			class = "Condition",
																																																			id = "192",
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
																																																								const = 11631302
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
																																																			id = "191",
																																																			properties = {
																																																				{
																																																					CastRight = "false"
																																																				},
																																																				{
																																																					Opl = {
																																																						field = "tSkill_11631302"
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
																																																			class = "Noop",
																																																			id = "202",
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
																																																class = "IfElse",
																																																id = "204",
																																																properties = {},
																																																attachments = {},
																																																children = {
																																																	{
																																																		node = {
																																																			class = "Condition",
																																																			id = "203",
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
																																																								const = 11631301
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
																																																			id = "205",
																																																			properties = {
																																																				{
																																																					CastRight = "false"
																																																				},
																																																				{
																																																					Opl = {
																																																						field = "tSkill_11631301"
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
																																																			class = "Noop",
																																																			id = "206",
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
																																																class = "IfElse",
																																																id = "361",
																																																properties = {},
																																																attachments = {},
																																																children = {
																																																	{
																																																		node = {
																																																			class = "Condition",
																																																			id = "360",
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
																																																								const = 11631500
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
																																																			id = "362",
																																																			properties = {
																																																				{
																																																					CastRight = "false"
																																																				},
																																																				{
																																																					Opl = {
																																																						field = "tSkill_11631500"
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
																																																			class = "Noop",
																																																			id = "363",
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
																																																class = "IfElse",
																																																id = "436",
																																																properties = {},
																																																attachments = {},
																																																children = {
																																																	{
																																																		node = {
																																																			class = "Condition",
																																																			id = "435",
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
																																																								const = 11631600
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
																																																			id = "437",
																																																			properties = {
																																																				{
																																																					CastRight = "false"
																																																				},
																																																				{
																																																					Opl = {
																																																						field = "tSkill_11631600"
																																																					}
																																																				},
																																																				{
																																																					Opr = {
																																																						const = 80
																																																					}
																																																				}
																																																			},
																																																			attachments = {},
																																																			children = {}
																																																		}
																																																	},
																																																	{
																																																		node = {
																																																			class = "Noop",
																																																			id = "434",
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
																																																class = "Compute",
																																																id = "232",
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
																																													id = "200",
																																													properties = {},
																																													attachments = {},
																																													children = {
																																														{
																																															node = {
																																																class = "IfElse",
																																																id = "240",
																																																properties = {},
																																																attachments = {},
																																																children = {
																																																	{
																																																		node = {
																																																			class = "Condition",
																																																			id = "239",
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
																																																								const = 11630430
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
																																																			id = "241",
																																																			properties = {
																																																				{
																																																					CastRight = "false"
																																																				},
																																																				{
																																																					Opl = {
																																																						field = "tSkill_11630430"
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
																																																			class = "Noop",
																																																			id = "242",
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
																																																class = "IfElse",
																																																id = "236",
																																																properties = {},
																																																attachments = {},
																																																children = {
																																																	{
																																																		node = {
																																																			class = "Condition",
																																																			id = "235",
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
																																																								const = 11631500
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
																																																			id = "237",
																																																			properties = {
																																																				{
																																																					CastRight = "false"
																																																				},
																																																				{
																																																					Opl = {
																																																						field = "tSkill_11631500"
																																																					}
																																																				},
																																																				{
																																																					Opr = {
																																																						const = 250
																																																					}
																																																				}
																																																			},
																																																			attachments = {},
																																																			children = {}
																																																		}
																																																	},
																																																	{
																																																		node = {
																																																			class = "Noop",
																																																			id = "238",
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
																																																class = "IfElse",
																																																id = "274",
																																																properties = {},
																																																attachments = {},
																																																children = {
																																																	{
																																																		node = {
																																																			class = "Condition",
																																																			id = "273",
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
																																																								const = 11631302
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
																																																			id = "275",
																																																			properties = {
																																																				{
																																																					CastRight = "false"
																																																				},
																																																				{
																																																					Opl = {
																																																						field = "tSkill_11631302"
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
																																																			class = "Noop",
																																																			id = "276",
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
																																																class = "IfElse",
																																																id = "289",
																																																properties = {},
																																																attachments = {},
																																																children = {
																																																	{
																																																		node = {
																																																			class = "Condition",
																																																			id = "288",
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
																																																								const = 11631600
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
																																																			id = "290",
																																																			properties = {
																																																				{
																																																					CastRight = "false"
																																																				},
																																																				{
																																																					Opl = {
																																																						field = "tSkill_11631600"
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
																																																			class = "Noop",
																																																			id = "291",
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
																																																class = "Compute",
																																																id = "243",
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
																																								}
																																							}
																																						}
																																					},
																																					{
																																						node = {
																																							class = "SelectorProbability",
																																							id = "156",
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
																																										id = "157",
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
																																													class = "Sequence",
																																													id = "38",
																																													properties = {},
																																													attachments = {},
																																													children = {
																																														{
																																															node = {
																																																class = "IfElse",
																																																id = "159",
																																																properties = {},
																																																attachments = {},
																																																children = {
																																																	{
																																																		node = {
																																																			class = "Condition",
																																																			id = "158",
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
																																																			class = "Action",
																																																			id = "146",
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
																																																			class = "Noop",
																																																			id = "160",
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
																																											}
																																										}
																																									}
																																								},
																																								{
																																									node = {
																																										class = "DecoratorWeight",
																																										id = "165",
																																										properties = {
																																											{
																																												DecorateWhenChildEnds = "false"
																																											},
																																											{
																																												Weight = {
																																													field = "tSkill_11630430"
																																												}
																																											}
																																										},
																																										attachments = {},
																																										children = {
																																											{
																																												node = {
																																													class = "Sequence",
																																													id = "162",
																																													properties = {},
																																													attachments = {},
																																													children = {
																																														{
																																															node = {
																																																class = "Assignment",
																																																id = "169",
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
																																																					const = 11630430
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
																																																id = "153",
																																																properties = {},
																																																attachments = {},
																																																children = {
																																																	{
																																																		node = {
																																																			class = "Condition",
																																																			id = "149",
																																																			properties = {
																																																				{
																																																					Operator = "LessEqual"
																																																				},
																																																				{
																																																					Opl = {
																																																						func = "getMaxSkillDist",
																																																						params = {
																																																							{
																																																								const = 11630430
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
																																																			class = "Sequence",
																																																			id = "212",
																																																			properties = {},
																																																			attachments = {},
																																																			children = {
																																																				{
																																																					node = {
																																																						class = "Assignment",
																																																						id = "211",
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
																																																											const = 11630430
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
																																																						id = "120",
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
																																																			class = "Noop",
																																																			id = "154",
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
																																																id = "166",
																																																properties = {
																																																	{
																																																		Method = {
																																																			func = "castSkill",
																																																			params = {
																																																				{
																																																					field = "tgt"
																																																				},
																																																				{
																																																					const = 11630430
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
																																								},
																																								{
																																									node = {
																																										class = "DecoratorWeight",
																																										id = "189",
																																										properties = {
																																											{
																																												DecorateWhenChildEnds = "false"
																																											},
																																											{
																																												Weight = {
																																													field = "tSkill_11631301"
																																												}
																																											}
																																										},
																																										attachments = {},
																																										children = {
																																											{
																																												node = {
																																													class = "Sequence",
																																													id = "183",
																																													properties = {},
																																													attachments = {},
																																													children = {
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
																																																			field = "skillStopDist"
																																																		}
																																																	},
																																																	{
																																																		Opr = {
																																																			func = "getSkillStopBoxDist",
																																																			params = {
																																																				{
																																																					const = 11631301
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
																																																id = "184",
																																																properties = {},
																																																attachments = {},
																																																children = {
																																																	{
																																																		node = {
																																																			class = "Condition",
																																																			id = "182",
																																																			properties = {
																																																				{
																																																					Operator = "LessEqual"
																																																				},
																																																				{
																																																					Opl = {
																																																						func = "getMaxSkillDist",
																																																						params = {
																																																							{
																																																								const = 11631301
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
																																																			class = "Sequence",
																																																			id = "215",
																																																			properties = {},
																																																			attachments = {},
																																																			children = {
																																																				{
																																																					node = {
																																																						class = "Assignment",
																																																						id = "216",
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
																																																											const = 11631301
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
																																																						id = "180",
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
																																																			class = "Noop",
																																																			id = "181",
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
																																																id = "178",
																																																properties = {
																																																	{
																																																		Method = {
																																																			func = "castSkill",
																																																			params = {
																																																				{
																																																					field = "tgt"
																																																				},
																																																				{
																																																					const = 11631301
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
																																																class = "Action",
																																																id = "491",
																																																properties = {
																																																	{
																																																		Method = {
																																																			func = "playAction",
																																																			params = {
																																																				{
																																																					const = "Behav_AngryLoop"
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
																																																id = "492",
																																																properties = {
																																																	{
																																																		Method = {
																																																			func = "playAction",
																																																			params = {
																																																				{
																																																					const = "Behav_AngryEnd"
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
																																										class = "DecoratorWeight",
																																										id = "407",
																																										properties = {
																																											{
																																												DecorateWhenChildEnds = "false"
																																											},
																																											{
																																												Weight = {
																																													field = "tSkill_11631302"
																																												}
																																											}
																																										},
																																										attachments = {},
																																										children = {
																																											{
																																												node = {
																																													class = "Sequence",
																																													id = "405",
																																													properties = {},
																																													attachments = {},
																																													children = {
																																														{
																																															node = {
																																																class = "Assignment",
																																																id = "401",
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
																																																					const = 11631302
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
																																																id = "406",
																																																properties = {},
																																																attachments = {},
																																																children = {
																																																	{
																																																		node = {
																																																			class = "Condition",
																																																			id = "404",
																																																			properties = {
																																																				{
																																																					Operator = "LessEqual"
																																																				},
																																																				{
																																																					Opl = {
																																																						func = "getMaxSkillDist",
																																																						params = {
																																																							{
																																																								const = 11631302
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
																																																			class = "Sequence",
																																																			id = "408",
																																																			properties = {},
																																																			attachments = {},
																																																			children = {
																																																				{
																																																					node = {
																																																						class = "Assignment",
																																																						id = "409",
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
																																																											const = 11631302
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
																																																						id = "402",
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
																																																			class = "Noop",
																																																			id = "403",
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
																																																id = "400",
																																																properties = {
																																																	{
																																																		Method = {
																																																			func = "castSkill",
																																																			params = {
																																																				{
																																																					field = "tgt"
																																																				},
																																																				{
																																																					const = 11631302
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
																																								},
																																								{
																																									node = {
																																										class = "DecoratorWeight",
																																										id = "268",
																																										properties = {
																																											{
																																												DecorateWhenChildEnds = "false"
																																											},
																																											{
																																												Weight = {
																																													field = "tSkill_11631500"
																																												}
																																											}
																																										},
																																										attachments = {},
																																										children = {
																																											{
																																												node = {
																																													class = "Sequence",
																																													id = "265",
																																													properties = {},
																																													attachments = {},
																																													children = {
																																														{
																																															node = {
																																																class = "Assignment",
																																																id = "269",
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
																																																					const = 11631500
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
																																																id = "266",
																																																properties = {},
																																																attachments = {},
																																																children = {
																																																	{
																																																		node = {
																																																			class = "Condition",
																																																			id = "270",
																																																			properties = {
																																																				{
																																																					Operator = "LessEqual"
																																																				},
																																																				{
																																																					Opl = {
																																																						func = "getMaxSkillDist",
																																																						params = {
																																																							{
																																																								const = 11631500
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
																																																			class = "Sequence",
																																																			id = "267",
																																																			properties = {},
																																																			attachments = {},
																																																			children = {
																																																				{
																																																					node = {
																																																						class = "Assignment",
																																																						id = "271",
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
																																																											const = 11631500
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
																																																						id = "263",
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
																																																			class = "Noop",
																																																			id = "264",
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
																																																id = "272",
																																																properties = {
																																																	{
																																																		Method = {
																																																			func = "castSkill",
																																																			params = {
																																																				{
																																																					field = "tgt"
																																																				},
																																																				{
																																																					const = 11631500
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
																																								},
																																								{
																																									node = {
																																										class = "DecoratorWeight",
																																										id = "283",
																																										properties = {
																																											{
																																												DecorateWhenChildEnds = "false"
																																											},
																																											{
																																												Weight = {
																																													field = "tSkill_11631501"
																																												}
																																											}
																																										},
																																										attachments = {},
																																										children = {
																																											{
																																												node = {
																																													class = "Sequence",
																																													id = "280",
																																													properties = {},
																																													attachments = {},
																																													children = {
																																														{
																																															node = {
																																																class = "Assignment",
																																																id = "284",
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
																																																					const = 11631501
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
																																																id = "281",
																																																properties = {},
																																																attachments = {},
																																																children = {
																																																	{
																																																		node = {
																																																			class = "Condition",
																																																			id = "285",
																																																			properties = {
																																																				{
																																																					Operator = "LessEqual"
																																																				},
																																																				{
																																																					Opl = {
																																																						func = "getMaxSkillDist",
																																																						params = {
																																																							{
																																																								const = 11631501
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
																																																			class = "Sequence",
																																																			id = "282",
																																																			properties = {},
																																																			attachments = {},
																																																			children = {
																																																				{
																																																					node = {
																																																						class = "Assignment",
																																																						id = "286",
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
																																																											const = 11631501
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
																																																						id = "278",
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
																																																			class = "Noop",
																																																			id = "279",
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
																																																id = "287",
																																																properties = {
																																																	{
																																																		Method = {
																																																			func = "castSkill",
																																																			params = {
																																																				{
																																																					field = "tgt"
																																																				},
																																																				{
																																																					const = 11631501
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
																																																class = "Action",
																																																id = "497",
																																																properties = {
																																																	{
																																																		Method = {
																																																			func = "playAction",
																																																			params = {
																																																				{
																																																					const = "Behav_AlertLoop"
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
																																														},
																																														{
																																															node = {
																																																class = "Action",
																																																id = "498",
																																																properties = {
																																																	{
																																																		Method = {
																																																			func = "playAction",
																																																			params = {
																																																				{
																																																					const = "Behav_AlertEnd"
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
																																											}
																																										}
																																									}
																																								},
																																								{
																																									node = {
																																										class = "DecoratorWeight",
																																										id = "414",
																																										properties = {
																																											{
																																												DecorateWhenChildEnds = "false"
																																											},
																																											{
																																												Weight = {
																																													field = "tSkill_11631600"
																																												}
																																											}
																																										},
																																										attachments = {},
																																										children = {
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
																																																id = "415",
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
																																																					const = 11631600
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
																																																id = "412",
																																																properties = {},
																																																attachments = {},
																																																children = {
																																																	{
																																																		node = {
																																																			class = "Condition",
																																																			id = "416",
																																																			properties = {
																																																				{
																																																					Operator = "LessEqual"
																																																				},
																																																				{
																																																					Opl = {
																																																						func = "getMaxSkillDist",
																																																						params = {
																																																							{
																																																								const = 11631600
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
																																																			class = "Sequence",
																																																			id = "413",
																																																			properties = {},
																																																			attachments = {},
																																																			children = {
																																																				{
																																																					node = {
																																																						class = "Assignment",
																																																						id = "417",
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
																																																											const = 11631600
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
																																																						id = "418",
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
																																																			class = "Noop",
																																																			id = "410",
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
																																																id = "419",
																																																properties = {
																																																	{
																																																		Method = {
																																																			func = "castSkill",
																																																			params = {
																																																				{
																																																					field = "tgt"
																																																				},
																																																				{
																																																					const = 11631600
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
																																								},
																																								{
																																									node = {
																																										class = "DecoratorWeight",
																																										id = "424",
																																										properties = {
																																											{
																																												DecorateWhenChildEnds = "false"
																																											},
																																											{
																																												Weight = {
																																													field = "tSkill_11631700"
																																												}
																																											}
																																										},
																																										attachments = {},
																																										children = {
																																											{
																																												node = {
																																													class = "Sequence",
																																													id = "421",
																																													properties = {},
																																													attachments = {},
																																													children = {
																																														{
																																															node = {
																																																class = "Assignment",
																																																id = "425",
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
																																																					const = 11631700
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
																																																id = "422",
																																																properties = {},
																																																attachments = {},
																																																children = {
																																																	{
																																																		node = {
																																																			class = "Condition",
																																																			id = "426",
																																																			properties = {
																																																				{
																																																					Operator = "LessEqual"
																																																				},
																																																				{
																																																					Opl = {
																																																						func = "getMaxSkillDist",
																																																						params = {
																																																							{
																																																								const = 11631700
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
																																																			class = "Sequence",
																																																			id = "423",
																																																			properties = {},
																																																			attachments = {},
																																																			children = {
																																																				{
																																																					node = {
																																																						class = "Assignment",
																																																						id = "427",
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
																																																											const = 11631700
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
																																																						id = "428",
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
																																																			class = "Noop",
																																																			id = "420",
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
																																																id = "429",
																																																properties = {
																																																	{
																																																		Method = {
																																																			func = "castSkill",
																																																			params = {
																																																				{
																																																					field = "tgt"
																																																				},
																																																				{
																																																					const = 11631700
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
																																								},
																																								{
																																									node = {
																																										class = "DecoratorWeight",
																																										id = "177",
																																										properties = {
																																											{
																																												DecorateWhenChildEnds = "false"
																																											},
																																											{
																																												Weight = {
																																													field = "tSkill_11631303"
																																												}
																																											}
																																										},
																																										attachments = {},
																																										children = {
																																											{
																																												node = {
																																													class = "Sequence",
																																													id = "175",
																																													properties = {},
																																													attachments = {},
																																													children = {
																																														{
																																															node = {
																																																class = "Assignment",
																																																id = "171",
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
																																																					const = 11631303
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
																																																id = "176",
																																																properties = {},
																																																attachments = {},
																																																children = {
																																																	{
																																																		node = {
																																																			class = "Condition",
																																																			id = "174",
																																																			properties = {
																																																				{
																																																					Operator = "LessEqual"
																																																				},
																																																				{
																																																					Opl = {
																																																						func = "getMaxSkillDist",
																																																						params = {
																																																							{
																																																								const = 11631303
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
																																																			class = "Sequence",
																																																			id = "213",
																																																			properties = {},
																																																			attachments = {},
																																																			children = {
																																																				{
																																																					node = {
																																																						class = "Assignment",
																																																						id = "214",
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
																																																											const = 11631303
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
																																																						id = "172",
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
																																																			class = "Noop",
																																																			id = "173",
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
																																																id = "170",
																																																properties = {
																																																	{
																																																		Method = {
																																																			func = "castSkill",
																																																			params = {
																																																				{
																																																					field = "tgt"
																																																				},
																																																				{
																																																					const = 11631303
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
																																																class = "Action",
																																																id = "495",
																																																properties = {
																																																	{
																																																		Method = {
																																																			func = "playAction",
																																																			params = {
																																																				{
																																																					const = "Behav_AlertLoop"
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
																																														},
																																														{
																																															node = {
																																																class = "Action",
																																																id = "496",
																																																properties = {
																																																	{
																																																		Method = {
																																																			func = "playAction",
																																																			params = {
																																																				{
																																																					const = "Behav_AlertEnd"
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
																																							id = "233",
																																							properties = {},
																																							attachments = {},
																																							children = {
																																								{
																																									node = {
																																										class = "Assignment",
																																										id = "155",
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
																																													field = "tSkill_11630430"
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
																																										id = "196",
																																										properties = {
																																											{
																																												CastRight = "false"
																																											},
																																											{
																																												Opl = {
																																													field = "tSkill_11631301"
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
																																										id = "277",
																																										properties = {
																																											{
																																												CastRight = "false"
																																											},
																																											{
																																												Opl = {
																																													field = "tSkill_11631302"
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
																																										id = "396",
																																										properties = {
																																											{
																																												CastRight = "false"
																																											},
																																											{
																																												Opl = {
																																													field = "tSkill_11631303"
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
																																										id = "397",
																																										properties = {
																																											{
																																												CastRight = "false"
																																											},
																																											{
																																												Opl = {
																																													field = "tSkill_11631500"
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
																																										id = "197",
																																										properties = {
																																											{
																																												CastRight = "false"
																																											},
																																											{
																																												Opl = {
																																													field = "tSkill_11631501"
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
																																										id = "398",
																																										properties = {
																																											{
																																												CastRight = "false"
																																											},
																																											{
																																												Opl = {
																																													field = "tSkill_11631600"
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
																																										id = "399",
																																										properties = {
																																											{
																																												CastRight = "false"
																																											},
																																											{
																																												Opl = {
																																													field = "tSkill_11631700"
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
																																										id = "465",
																																										properties = {
																																											{
																																												Method = {
																																													func = "startTimer",
																																													params = {
																																														{
																																															const = "fightInterval"
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
																														id = "217",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	class = "And",
																																	id = "228",
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
																																				id = "75",
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
																																							const = 30
																																						}
																																					}
																																				},
																																				attachments = {},
																																				children = {
																																					{
																																						node = {
																																							class = "Selector",
																																							id = "76",
																																							properties = {},
																																							attachments = {},
																																							children = {
																																								{
																																									node = {
																																										class = "Sequence",
																																										id = "230",
																																										properties = {},
																																										attachments = {},
																																										children = {
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
																																													class = "Compute",
																																													id = "234",
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
																																							const = 30
																																						}
																																					}
																																				},
																																				attachments = {},
																																				children = {
																																					{
																																						node = {
																																							class = "Sequence",
																																							id = "151",
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
																																										class = "SelectorProbability",
																																										id = "102",
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
																																													id = "104",
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
																																													class = "DecoratorWeight",
																																													id = "108",
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
																																																class = "Action",
																																																id = "109",
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
																																		}
																																	}
																																}
																															},
																															{
																																node = {
																																	class = "Sequence",
																																	id = "221",
																																	properties = {},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				class = "Condition",
																																				id = "222",
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
																																				class = "SelectorProbability",
																																				id = "225",
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
																																							id = "226",
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
																																										class = "Action",
																																										id = "223",
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
																																							class = "DecoratorWeight",
																																							id = "227",
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
																																										class = "Action",
																																										id = "224",
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
																												}
																											}
																										}
																									}
																								}
																							}
																						}
																					}
																				}
																			}
																		}
																	}
																}
															}
														}
													}
												}
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
}

return ST_Monster_AutoCombat_Boss_10163
