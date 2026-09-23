-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\CombatUnit\\Monster\\Root\\Combat\\ST_Monster_AutoCombat_FriendSideNPC.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local ST_Monster_AutoCombat_FriendSideNPC = {
	behavior = {
		agenttype = "PuppetAgent",
		useForRoute = false,
		name = "CombatUnit/Monster/Root/Combat/ST_Monster_AutoCombat_FriendSideNPC",
		version = 52,
		properties = {},
		pars = {
			{
				const = 0,
				name = "disToTgtForSkillMon",
				value = "0",
				type = "float"
			},
			{
				const = 0,
				name = "goBackDist",
				value = "0",
				type = "float"
			}
		},
		attachments = {},
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
									class = "IfElse",
									id = "195",
									properties = {},
									attachments = {},
									children = {
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
												class = "Noop",
												id = "196",
												properties = {},
												attachments = {},
												children = {}
											}
										},
										{
											node = {
												class = "Action",
												id = "197",
												properties = {
													{
														Method = {
															func = "resetRootState",
															params = {
																{
																	const = BaseEnum.EBTRootState.ST_Root_Guide
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
															field = "distToTgtForSkill"
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
																	const = false
																},
																{
																	const = 0
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
										},
										{
											node = {
												class = "IfElse",
												id = "175",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															class = "Or",
															id = "249",
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
																		id = "248",
																		properties = {
																			{
																				Operator = "Equal"
																			},
																			{
																				Opl = {
																					func = "checkIsInRangeAndSectorTgt",
																					params = {
																						{
																							field = "tgt"
																						},
																						{
																							const = -22.5
																						},
																						{
																							const = 22.5
																						},
																						{
																							const = 0
																						},
																						{
																							const = 10
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
															class = "Selector",
															id = "232",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		class = "Sequence",
																		id = "233",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					class = "Condition",
																					id = "236",
																					properties = {
																						{
																							Operator = "Equal"
																						},
																						{
																							Opl = {
																								func = "checkIsInRangeAndSectorTgt",
																								params = {
																									{
																										field = "tgt"
																									},
																									{
																										const = 0
																									},
																									{
																										const = 180
																									},
																									{
																										const = 0
																									},
																									{
																										const = 30
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
																					id = "231",
																					properties = {
																						{
																							Method = {
																								func = "moveToTargetPos",
																								params = {
																									{
																										field = "tgt"
																									},
																									{
																										const = 70
																									},
																									{
																										field = "attackStopBoxDist"
																									},
																									{
																										const = 0.5
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
																										const = false
																									},
																									{
																										const = 0
																									},
																									{
																										const = BaseEnum.SpeedRateType.Mid
																									},
																									{
																										const = BaseEnum.PathFindType.Auto
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
																		id = "234",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					class = "Condition",
																					id = "237",
																					properties = {
																						{
																							Operator = "Equal"
																						},
																						{
																							Opl = {
																								func = "checkIsInRangeAndSectorTgt",
																								params = {
																									{
																										field = "tgt"
																									},
																									{
																										const = 180
																									},
																									{
																										const = 360
																									},
																									{
																										const = 0
																									},
																									{
																										const = 30
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
																					id = "235",
																					properties = {
																						{
																							Method = {
																								func = "moveToTargetPos",
																								params = {
																									{
																										field = "tgt"
																									},
																									{
																										const = -70
																									},
																									{
																										field = "attackStopBoxDist"
																									},
																									{
																										const = 0.5
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
																										const = false
																									},
																									{
																										const = 0
																									},
																									{
																										const = BaseEnum.SpeedRateType.Mid
																									},
																									{
																										const = BaseEnum.PathFindType.Auto
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
															id = "34",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		class = "Sequence",
																		id = "35",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					class = "Assignment",
																					id = "19",
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
																								func = "selectSkillByWeight",
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
																					class = "Condition",
																					id = "151",
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
																					class = "Assignment",
																					id = "134",
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
																					class = "Sequence",
																					id = "190",
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
																								class = "IfElse",
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
																													Operator = "Less"
																												},
																												{
																													Opl = {
																														field = "distToTgt"
																													}
																												},
																												{
																													Opr = {
																														field = "disToTgtForSkillMon"
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
																											id = "160",
																											properties = {
																												{
																													Method = {
																														func = "turnToTargetAtYaw",
																														params = {
																															{
																																field = "tgt"
																															},
																															{
																																const = 180
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
																											class = "Action",
																											id = "159",
																											properties = {
																												{
																													Method = {
																														func = "turnToTargetAtYaw",
																														params = {
																															{
																																field = "tgt"
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
																									}
																								}
																							}
																						},
																						{
																							node = {
																								class = "Action",
																								id = "136",
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
																													const = false
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
																						}
																					}
																				}
																			},
																			{
																				node = {
																					class = "Selector",
																					id = "126",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								class = "Sequence",
																								id = "191",
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
																																const = false
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
																								id = "137",
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
																		id = "187",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					class = "IfElse",
																					id = "185",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								class = "Condition",
																								id = "153",
																								properties = {
																									{
																										Operator = "Less"
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
																								class = "Sequence",
																								id = "192",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											class = "Action",
																											id = "194",
																											properties = {
																												{
																													Method = {
																														func = "turnToTargetAtYaw",
																														params = {
																															{
																																field = "tgt"
																															},
																															{
																																const = 180
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
																											class = "Action",
																											id = "193",
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
																																const = false
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
																									}
																								}
																							}
																						},
																						{
																							node = {
																								class = "Noop",
																								id = "186",
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
																					id = "188",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								class = "Condition",
																								id = "184",
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
																								class = "Sequence",
																								id = "38",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											class = "Action",
																											id = "152",
																											properties = {
																												{
																													Method = {
																														func = "turnToTargetAtYaw",
																														params = {
																															{
																																field = "tgt"
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
																																const = false
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
																									}
																								}
																							}
																						},
																						{
																							node = {
																								class = "Noop",
																								id = "189",
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
																					id = "176",
																					properties = {
																						{
																							Method = {
																								func = "castCombo",
																								params = {
																									{
																										field = "tgt"
																									},
																									{
																										const = 9100001
																									},
																									{
																										const = 5
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
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
}

return ST_Monster_AutoCombat_FriendSideNPC
