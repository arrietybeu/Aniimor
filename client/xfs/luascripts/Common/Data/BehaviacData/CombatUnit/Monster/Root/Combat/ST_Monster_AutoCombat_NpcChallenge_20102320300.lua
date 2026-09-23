-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\CombatUnit\\Monster\\Root\\Combat\\ST_Monster_AutoCombat_NpcChallenge_20102320300.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local ST_Monster_AutoCombat_NpcChallenge_20102320300 = {
	behavior = {
		version = 119,
		name = "CombatUnit/Monster/Root/Combat/ST_Monster_AutoCombat_NpcChallenge_20102320300",
		useForRoute = false,
		agenttype = "PuppetAgent",
		properties = {},
		pars = {
			{
				value = "0",
				type = "float",
				const = 0,
				name = "CurrentDistToTarget"
			},
			{
				value = "0",
				type = "float",
				const = 0,
				name = "CurrentBoxDistToTarget"
			},
			{
				value = "0",
				type = "float",
				const = 0,
				name = "goBackDist"
			},
			{
				value = "0",
				type = "float",
				const = 0,
				name = "skillStopDist"
			},
			{
				value = "100",
				type = "int",
				const = 100,
				name = "tWeight_Group_SideWalk"
			},
			{
				value = "100",
				type = "int",
				const = 100,
				name = "tWeight_Group_Wait"
			},
			{
				value = "100",
				type = "int",
				const = 100,
				name = "tWeight_Group_Angry"
			},
			{
				value = "0",
				type = "int",
				const = 0,
				name = "tSkillRecoverCount"
			},
			{
				value = "0",
				type = "float",
				const = 0,
				name = "CurrentHpPercent"
			},
			{
				value = "0",
				type = "int",
				const = 0,
				name = "tSkillBuffCount"
			},
			{
				value = "0",
				type = "int",
				const = 0,
				name = "tSkillControlCount"
			},
			{
				value = "0",
				type = "float",
				const = 0,
				name = "jumpback"
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
											const = "jumpback"
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
									id = "447",
									class = "Sequence",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "466",
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
												id = "444",
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
												id = "445",
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
												id = "502",
												class = "IfElse",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "504",
															class = "And",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		id = "503",
																		class = "Condition",
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
																					func = "getMinAttackDist",
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
																		id = "499",
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
																							const = "jumpback"
																						}
																					}
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
																}
															}
														}
													},
													{
														node = {
															id = "506",
															class = "Sequence",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		id = "492",
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
																		id = "490",
																		class = "IfElse",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					id = "501",
																					class = "Condition",
																					properties = {
																						{
																							Operator = "Greater"
																						},
																						{
																							Opl = {
																								func = "getRandomInt",
																								params = {
																									{
																										const = 0
																									},
																									{
																										const = 100
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
																					id = "494",
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
																										const = 45
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
																							ResultResumeOption = "BT_ResumeTree"
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
																								func = "jumpBackByLinkAngle",
																								params = {
																									{
																										field = "tgt"
																									},
																									{
																										const = -45
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
																		id = "505",
																		class = "Action",
																		properties = {
																			{
																				Method = {
																					func = "startTimer",
																					params = {
																						{
																							const = "jumpback"
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
															id = "493",
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
												id = "498",
												class = "IfElse",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "500",
															class = "Condition",
															properties = {
																{
																	Operator = "Equal"
																},
																{
																	Opl = {
																		func = "checkSkillNotInCd",
																		params = {
																			{
																				const = 12320230
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
															id = "497",
															class = "Sequence",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		id = "495",
																		class = "Action",
																		properties = {
																			{
																				Method = {
																					func = "castSkill",
																					params = {
																						{
																							const = 0
																						},
																						{
																							const = 12320230
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
																		id = "496",
																		class = "Action",
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
													},
													{
														node = {
															id = "489",
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
												id = "470",
												class = "ReferencedBehavior",
												properties = {
													{
														ReferenceBehavior = {
															const = "PBT_AutoCombat_NormalAtkCombo"
														}
													},
													{
														subTreeProperties = {}
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

return ST_Monster_AutoCombat_NpcChallenge_20102320300
