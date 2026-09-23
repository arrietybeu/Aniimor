-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_AutoCombat_KeepDis.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_AutoCombat_KeepDis = {
	behavior = {
		name = "ParmonBehaviorTree/SubTree/PBT_AutoCombat_KeepDis",
		version = 33,
		useForRoute = false,
		agenttype = "PetAgent",
		properties = {},
		pars = {
			{
				const = 0,
				name = "goBackDist",
				type = "float",
				value = "0"
			},
			{
				const = 0,
				name = "CurrentDistToTarget",
				type = "float",
				value = "0"
			},
			{
				const = 0,
				name = "CurrentBoxDistToTarget",
				type = "float",
				value = "0"
			}
		},
		attachments = {},
		node = {
			class = "Selector",
			id = "53",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						class = "Sequence",
						id = "28",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									class = "Condition",
									id = "30",
									properties = {
										{
											Operator = "Equal"
										},
										{
											Opl = {
												func = "checkIsInRangeAndSectorTgt",
												params = {
													{
														field = "masterId"
													},
													{
														const = 120
													},
													{
														const = 240
													},
													{
														const = 15
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
									class = "Sequence",
									id = "55",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												class = "Selector",
												id = "63",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															class = "Condition",
															id = "61",
															properties = {
																{
																	Operator = "Less"
																},
																{
																	Opl = {
																		func = "getTimerValue",
																		params = {
																			{
																				const = "runBackTimer"
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
															id = "62",
															properties = {
																{
																	Operator = "GreaterEqual"
																},
																{
																	Opl = {
																		func = "getTimerValue",
																		params = {
																			{
																				const = "runBackTimer"
																			}
																		}
																	}
																},
																{
																	Opr = {
																		const = 20
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
												id = "60",
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
												class = "Action",
												id = "59",
												properties = {
													{
														Method = {
															func = "moveToTarget",
															params = {
																{
																	field = "masterId"
																},
																{
																	const = 10
																},
																{
																	const = 3
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
																	const = BaseEnum.PathFindType.Voxel
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
												class = "Action",
												id = "64",
												properties = {
													{
														Method = {
															func = "startTimer",
															params = {
																{
																	const = "runBackTimer"
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
						id = "25",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									class = "Condition",
									id = "26",
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
									id = "27",
									properties = {
										{
											Operator = "NotEqual"
										},
										{
											Opl = {
												func = "isGoBackCd"
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
									id = "14",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												class = "Selector",
												id = "39",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															class = "Condition",
															id = "37",
															properties = {
																{
																	Operator = "Less"
																},
																{
																	Opl = {
																		func = "getTimerValue",
																		params = {
																			{
																				const = "jumpBackTimer"
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
															id = "38",
															properties = {
																{
																	Operator = "GreaterEqual"
																},
																{
																	Opl = {
																		func = "getTimerValue",
																		params = {
																			{
																				const = "jumpBackTimer"
																			}
																		}
																	}
																},
																{
																	Opr = {
																		const = 20
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
												id = "35",
												properties = {
													{
														Operator = "NotEqual"
													},
													{
														Opl = {
															func = "checkCharacterState",
															params = {
																{
																	const = "SPECIALDEFENSE"
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
												class = "And",
												id = "67",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															class = "Condition",
															id = "36",
															properties = {
																{
																	Operator = "NotEqual"
																},
																{
																	Opl = {
																		func = "checkNormalAttackByTags",
																		params = {
																			{
																				field = "selfId"
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
															class = "Condition",
															id = "68",
															properties = {
																{
																	Operator = "Equal"
																},
																{
																	Opl = {
																		func = "checkIsBreakST",
																		params = {
																			{
																				field = "tgt"
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
												class = "Compute",
												id = "15",
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
												class = "IfElse",
												id = "16",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															class = "Sequence",
															id = "41",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		class = "Condition",
																		id = "18",
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
																		class = "Action",
																		id = "40",
																		properties = {
																			{
																				Method = {
																					func = "startTimer",
																					params = {
																						{
																							const = "jumpBackTimer"
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
															class = "Action",
															id = "17",
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
															class = "Action",
															id = "19",
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
												class = "ReferencedBehavior",
												id = "65",
												properties = {
													{
														ReferenceBehavior = {
															const = "PBT_AutoCombat_NormalAtkCombo"
														}
													},
													{
														subTreeProperties = {
															{
																Type = "Self",
																Name = "CurrentDistToTarget",
																Value = {
																	field = "CurrentDistToTarget"
																}
															},
															{
																Type = "Self",
																Name = "CurrentBoxDistToTarget",
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

return PBT_AutoCombat_KeepDis
