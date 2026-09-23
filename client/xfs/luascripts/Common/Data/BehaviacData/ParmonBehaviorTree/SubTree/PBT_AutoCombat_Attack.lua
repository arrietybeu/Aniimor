-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_AutoCombat_Attack.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_AutoCombat_Attack = {
	behavior = {
		useForRoute = false,
		name = "ParmonBehaviorTree/SubTree/PBT_AutoCombat_Attack",
		agenttype = "PetAgent",
		version = 357,
		properties = {},
		pars = {
			{
				const = false,
				name = "tShow50PCBubble",
				type = "bool",
				value = "false"
			},
			{
				const = false,
				name = "tShow20PCBubble",
				type = "bool",
				value = "false"
			},
			{
				const = 0,
				name = "CurrentDistToTarget",
				type = "float",
				value = "0"
			},
			{
				const = 0,
				name = "CurrentEP",
				type = "float",
				value = "0"
			},
			{
				const = 0,
				name = "CurrentHpPercent",
				type = "float",
				value = "0"
			},
			{
				const = 0,
				name = "Weight_JumpBack",
				type = "int",
				value = "0"
			},
			{
				const = 0,
				name = "Weight_RunBack",
				type = "int",
				value = "0"
			},
			{
				const = 0,
				name = "Weight_Skill",
				type = "int",
				value = "0"
			},
			{
				const = 0,
				name = "Weight_CommonAttack",
				type = "int",
				value = "0"
			},
			{
				const = 0,
				name = "Weight_NothingToDo",
				type = "int",
				value = "0"
			},
			{
				const = 0,
				name = "maxSkillDist",
				type = "float",
				value = "0"
			},
			{
				const = 0,
				name = "skillStopDist",
				type = "float",
				value = "0"
			},
			{
				const = 0,
				name = "goBackDist",
				type = "float",
				value = "0"
			},
			{
				const = 0,
				name = "tNewTargetForCatchMode",
				type = "int",
				value = "0"
			},
			{
				const = 0,
				name = "CurrentBoxDistToTarget",
				type = "float",
				value = "0"
			},
			{
				const = 0,
				name = "tAngryPrepare",
				type = "int",
				value = "0"
			},
			{
				const = 0,
				name = "tDrowningDepth",
				type = "float",
				value = "0"
			},
			{
				const = 0,
				name = "tFlyHeight",
				type = "float",
				value = "0"
			},
			{
				const = 0,
				name = "tVerticalDistToTgt",
				type = "float",
				value = "0"
			},
			{
				const = "0",
				name = "tSkillPlan",
				type = "string",
				value = "0"
			},
			{
				const = 0,
				name = "tSkillUsed",
				type = "int",
				value = "0"
			},
			{
				const = 0,
				name = "tSkillComboCount",
				type = "int",
				value = "0"
			},
			{
				const = 0,
				name = "tEnvSkillTimer",
				type = "float",
				value = "0"
			}
		},
		attachments = {},
		node = {
			id = "866",
			class = "Selector",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						id = "871",
						class = "Sequence",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									id = "870",
									class = "Assignment",
									properties = {
										{
											CastRight = "false"
										},
										{
											Opl = {
												field = "tSkillPlan"
											}
										},
										{
											Opr = {
												func = "getParmonSkillPlanSubtreePath"
											}
										}
									},
									attachments = {},
									children = {}
								}
							},
							{
								node = {
									id = "872",
									class = "ReferencedBehavior",
									properties = {
										{
											ReferenceBehavior = {
												field = "tSkillPlan"
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
						id = "1357",
						class = "Selector",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									id = "1358",
									class = "Sequence",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "1359",
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
																	const = 9
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
												id = "1361",
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
												id = "1407",
												class = "Selector",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "1405",
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
																				const = "specialSkillCd"
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
															id = "1425",
															class = "Sequence",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		id = "1426",
																		class = "Assignment",
																		properties = {
																			{
																				CastRight = "false"
																			},
																			{
																				Opl = {
																					field = "tEnvSkillTimer"
																				}
																			},
																			{
																				Opr = {
																					func = "getEnvSkillTimer",
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
																		id = "1406",
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
																							const = "specialSkillCd"
																						}
																					}
																				}
																			},
																			{
																				Opr = {
																					field = "tEnvSkillTimer"
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
												id = "1394",
												class = "Selector",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "1397",
															class = "Sequence",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		id = "1395",
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
																							const = 9
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
																		id = "1396",
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
																		id = "1385",
																		class = "Sequence",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					id = "1392",
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
																					id = "1393",
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
																					id = "1389",
																					class = "IfElse",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								id = "1390",
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
																								id = "1387",
																								class = "Sequence",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											id = "1384",
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
																											id = "1391",
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
																											id = "1411",
																											class = "Action",
																											properties = {
																												{
																													Method = {
																														func = "startTimer",
																														params = {
																															{
																																const = "specialSkillCd"
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
																								id = "1410",
																								class = "Sequence",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											id = "1383",
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
																											id = "1412",
																											class = "Action",
																											properties = {
																												{
																													Method = {
																														func = "startTimer",
																														params = {
																															{
																																const = "specialSkillCd"
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
															id = "1398",
															class = "Sequence",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		id = "1399",
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
																							const = 9
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
																		id = "1400",
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
																		id = "1401",
																		class = "Selector",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					id = "1366",
																					class = "Sequence",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								id = "1367",
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
																								id = "1381",
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
																								id = "1382",
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
																								id = "1369",
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
																								id = "1370",
																								class = "IfElse",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											id = "1371",
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
																											id = "1368",
																											class = "Sequence",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "1365",
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
																														id = "1372",
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
																									},
																									{
																										node = {
																											id = "1364",
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
																			},
																			{
																				node = {
																					id = "1420",
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
							},
							{
								node = {
									id = "1428",
									class = "Sequence",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "1430",
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
																	const = 9
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
												id = "1429",
												class = "Condition",
												properties = {
													{
														Operator = "Equal"
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
												id = "875",
												class = "Selector",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "873",
															class = "Sequence",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		id = "874",
																		class = "Condition",
																		properties = {
																			{
																				Operator = "Equal"
																			},
																			{
																				Opl = {
																					func = "checkLinkSkillExist",
																					params = {
																						{
																							field = "selfId"
																						},
																						{
																							const = 6
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
																		id = "876",
																		class = "IfElse",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					id = "877",
																					class = "Condition",
																					properties = {
																						{
																							Operator = "Equal"
																						},
																						{
																							Opl = {
																								func = "checkTargetHasBuffFromSource",
																								params = {
																									{
																										field = "selfId"
																									},
																									{
																										const = "Positive"
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
																					id = "882",
																					class = "Selector",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								id = "881",
																								class = "ReferencedBehavior",
																								properties = {
																									{
																										ReferenceBehavior = {
																											const = "PBT_AutoCombat_SubAttack"
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
																								id = "885",
																								class = "Sequence",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											id = "886",
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
																											id = "1346",
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
																											id = "1347",
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
																											id = "888",
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
																											id = "889",
																											class = "IfElse",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "890",
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
																														id = "887",
																														class = "Sequence",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	id = "884",
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
																																	id = "894",
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
																												},
																												{
																													node = {
																														id = "893",
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
																						},
																						{
																							node = {
																								id = "1421",
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
																					id = "907",
																					class = "Sequence",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								id = "908",
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
																								id = "906",
																								class = "IfElse",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											id = "904",
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
																																field = "skillId"
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
																											id = "939",
																											class = "IfElse",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "940",
																														class = "Condition",
																														properties = {
																															{
																																Operator = "Equal"
																															},
																															{
																																Opl = {
																																	func = "checkLinkSkillCanCast",
																																	params = {
																																		{
																																			field = "selfId"
																																		},
																																		{
																																			const = 6
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
																														id = "911",
																														class = "Sequence",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	id = "1348",
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
																																	id = "964",
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
																																	id = "965",
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
																																	id = "915",
																																	class = "IfElse",
																																	properties = {},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				id = "916",
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
																																				id = "913",
																																				class = "Sequence",
																																				properties = {},
																																				attachments = {},
																																				children = {
																																					{
																																						node = {
																																							id = "910",
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
																																							id = "917",
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
																																		},
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
																															},
																															{
																																node = {
																																	id = "1150",
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
																																				field = "skillId"
																																			}
																																		}
																																	},
																																	attachments = {},
																																	children = {}
																																}
																															},
																															{
																																node = {
																																	id = "1339",
																																	class = "ReferencedBehavior",
																																	properties = {
																																		{
																																			ReferenceBehavior = {
																																				const = "PBT_AutoCombat_SubAttack"
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
																															}
																														}
																													}
																												},
																												{
																													node = {
																														id = "941",
																														class = "Selector",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	id = "944",
																																	class = "Sequence",
																																	properties = {},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				id = "945",
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
																																				id = "966",
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
																																				id = "967",
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
																																				id = "947",
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
																																				id = "948",
																																				class = "IfElse",
																																				properties = {},
																																				attachments = {},
																																				children = {
																																					{
																																						node = {
																																							id = "949",
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
																																							id = "946",
																																							class = "Sequence",
																																							properties = {},
																																							attachments = {},
																																							children = {
																																								{
																																									node = {
																																										id = "943",
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
																																										id = "950",
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
																																					},
																																					{
																																						node = {
																																							id = "942",
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
																															},
																															{
																																node = {
																																	id = "1422",
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
																									},
																									{
																										node = {
																											id = "1147",
																											class = "ReferencedBehavior",
																											properties = {
																												{
																													ReferenceBehavior = {
																														const = "PBT_AutoCombat_SubAttack"
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
																									}
																								}
																							}
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
															id = "1030",
															class = "Sequence",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		id = "1031",
																		class = "Condition",
																		properties = {
																			{
																				Operator = "Equal"
																			},
																			{
																				Opl = {
																					func = "checkLinkSkillExist",
																					params = {
																						{
																							field = "selfId"
																						},
																						{
																							const = 1
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
																		id = "1035",
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
																		id = "1125",
																		class = "IfElse",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					id = "1124",
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
																										field = "skillId"
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
																					id = "1034",
																					class = "IfElse",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								id = "1033",
																								class = "Condition",
																								properties = {
																									{
																										Operator = "Equal"
																									},
																									{
																										Opl = {
																											func = "checkLinkSkillCanCast",
																											params = {
																												{
																													field = "selfId"
																												},
																												{
																													const = 1
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
																								id = "1038",
																								class = "Sequence",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											id = "1349",
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
																											id = "1044",
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
																											id = "1045",
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
																											id = "1040",
																											class = "IfElse",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "1041",
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
																														id = "1039",
																														class = "Sequence",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	id = "1037",
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
																																	id = "1042",
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
																												},
																												{
																													node = {
																														id = "1036",
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
																									},
																									{
																										node = {
																											id = "1122",
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
																														field = "skillId"
																													}
																												}
																											},
																											attachments = {},
																											children = {}
																										}
																									},
																									{
																										node = {
																											id = "1340",
																											class = "ReferencedBehavior",
																											properties = {
																												{
																													ReferenceBehavior = {
																														const = "PBT_AutoCombat_SubAttack"
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
																									}
																								}
																							}
																						},
																						{
																							node = {
																								id = "1149",
																								class = "Selector",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											id = "1128",
																											class = "Sequence",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "1129",
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
																														id = "1143",
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
																														id = "1144",
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
																														id = "1131",
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
																														id = "1132",
																														class = "IfElse",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	id = "1133",
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
																																	id = "1130",
																																	class = "Sequence",
																																	properties = {},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				id = "1127",
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
																																				id = "1134",
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
																															},
																															{
																																node = {
																																	id = "1126",
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
																									},
																									{
																										node = {
																											id = "1423",
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
																			},
																			{
																				node = {
																					id = "1145",
																					class = "ReferencedBehavior",
																					properties = {
																						{
																							ReferenceBehavior = {
																								const = "PBT_AutoCombat_SubAttack"
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
																			}
																		}
																	}
																}
															}
														}
													},
													{
														node = {
															id = "1019",
															class = "Sequence",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		id = "986",
																		class = "Condition",
																		properties = {
																			{
																				Operator = "Equal"
																			},
																			{
																				Opl = {
																					func = "checkLinkSkillExist",
																					params = {
																						{
																							field = "selfId"
																						},
																						{
																							const = 7
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
																		id = "1022",
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
																							const = 7
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
																		id = "1024",
																		class = "IfElse",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					id = "988",
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
																										field = "skillId"
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
																					id = "1027",
																					class = "IfElse",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								id = "1018",
																								class = "Condition",
																								properties = {
																									{
																										Operator = "Equal"
																									},
																									{
																										Opl = {
																											func = "checkLinkSkillCanCast",
																											params = {
																												{
																													field = "selfId"
																												},
																												{
																													const = 7
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
																								id = "991",
																								class = "Sequence",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											id = "1350",
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
																																const = 7
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
																											id = "997",
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
																											id = "998",
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
																											id = "993",
																											class = "IfElse",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "994",
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
																														id = "992",
																														class = "Sequence",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	id = "990",
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
																																	id = "995",
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
																												},
																												{
																													node = {
																														id = "989",
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
																									},
																									{
																										node = {
																											id = "1151",
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
																														field = "skillId"
																													}
																												}
																											},
																											attachments = {},
																											children = {}
																										}
																									},
																									{
																										node = {
																											id = "1342",
																											class = "ReferencedBehavior",
																											properties = {
																												{
																													ReferenceBehavior = {
																														const = "PBT_AutoCombat_SubAttack"
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
																															Name = "tSkillUsed",
																															Type = "Self",
																															Value = {
																																field = "tSkillUsed"
																															}
																														},
																														{
																															Name = "tSkillComboCount",
																															Type = "Self",
																															Value = {
																																field = "tSkillComboCount"
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
																								id = "1026",
																								class = "Selector",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											id = "1001",
																											class = "Sequence",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "1002",
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
																														id = "1016",
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
																														id = "1017",
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
																														id = "1004",
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
																														id = "1005",
																														class = "IfElse",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	id = "1006",
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
																																	id = "1003",
																																	class = "Sequence",
																																	properties = {},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				id = "1000",
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
																																				id = "1007",
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
																															},
																															{
																																node = {
																																	id = "999",
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
																									},
																									{
																										node = {
																											id = "1424",
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
																			},
																			{
																				node = {
																					id = "1146",
																					class = "ReferencedBehavior",
																					properties = {
																						{
																							ReferenceBehavior = {
																								const = "PBT_AutoCombat_SubAttack"
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
																			}
																		}
																	}
																}
															}
														}
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
						id = "1047",
						class = "IfElse",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									id = "1049",
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
									id = "1051",
									class = "Sequence",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "1050",
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
												id = "1052",
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
																	const = 0
																},
																{
																	const = true
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
												id = "1343",
												class = "ReferencedBehavior",
												properties = {
													{
														ReferenceBehavior = {
															const = "PBT_AutoCombat_SubAttack"
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
										}
									}
								}
							},
							{
								node = {
									id = "1351",
									class = "IfElse",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "1354",
												class = "Or",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "1353",
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
															id = "1355",
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
																				const = 10072
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
															id = "1356",
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
																				const = 10014
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
													}
												}
											}
										},
										{
											node = {
												id = "1352",
												class = "ReferencedBehavior",
												properties = {
													{
														ReferenceBehavior = {
															const = "PBT_AutoCombat_SubAttack"
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
												id = "1087",
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
															id = "1090",
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
																		id = "1344",
																		class = "ReferencedBehavior",
																		properties = {
																			{
																				ReferenceBehavior = {
																					const = "PBT_AutoCombat_SubAttack"
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
																}
															}
														}
													},
													{
														node = {
															id = "1091",
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
																		id = "1094",
																		class = "Sequence",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					id = "1089",
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
																										const = 5
																									},
																									{
																										const = true
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
																					id = "1333",
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
																					id = "1100",
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
																					id = "1101",
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
																					id = "1096",
																					class = "IfElse",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								id = "1097",
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
																								id = "1095",
																								class = "Sequence",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											id = "1093",
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
																											id = "1098",
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
																								id = "1092",
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
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
}

return PBT_AutoCombat_Attack
