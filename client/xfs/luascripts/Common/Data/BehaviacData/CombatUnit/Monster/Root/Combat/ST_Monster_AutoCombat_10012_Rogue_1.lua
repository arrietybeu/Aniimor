-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\CombatUnit\\Monster\\Root\\Combat\\ST_Monster_AutoCombat_10012_Rogue_1.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local ST_Monster_AutoCombat_10012_Rogue_1 = {
	behavior = {
		useForRoute = false,
		name = "CombatUnit/Monster/Root/Combat/ST_Monster_AutoCombat_10012_Rogue_1",
		agenttype = "PuppetAgent",
		version = 78,
		properties = {},
		pars = {
			{
				type = "float",
				const = 0,
				value = "0",
				name = "disToTgtForSkillMon"
			},
			{
				type = "float",
				const = 0,
				value = "0",
				name = "goBackDist"
			}
		},
		attachments = {},
		node = {
			id = "247",
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
						id = "327",
						class = "Sequence",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									id = "337",
									class = "IfElse",
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
															func = "getTimerValue",
															params = {
																{
																	const = "Sleep"
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
												id = "340",
												class = "Action",
												properties = {
													{
														Method = {
															func = "startTimer",
															params = {
																{
																	const = "Sleep"
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
												id = "341",
												class = "Action",
												properties = {
													{
														Method = {
															func = "waitTime",
															params = {
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
							},
							{
								node = {
									id = "349",
									class = "IfElse",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "350",
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
																	const = "Sleep"
																}
															}
														}
													},
													{
														Opr = {
															const = 53
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
																	const = 10120811
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
												id = "352",
												class = "Action",
												properties = {
													{
														Method = {
															func = "waitTime",
															params = {
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
							},
							{
								node = {
									id = "342",
									class = "IfElse",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "344",
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
																	const = "Sleep"
																}
															}
														}
													},
													{
														Opr = {
															const = 47
														}
													}
												},
												attachments = {},
												children = {}
											}
										},
										{
											node = {
												id = "345",
												class = "Sequence",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "373",
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
															id = "371",
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
																				const = true
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
															id = "372",
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
																				const = 10120810
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
												id = "343",
												class = "Action",
												properties = {
													{
														Method = {
															func = "waitTime",
															params = {
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
							},
							{
								node = {
									id = "354",
									class = "IfElse",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "358",
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
																	const = "Sleep"
																}
															}
														}
													},
													{
														Opr = {
															const = 44
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
												class = "Sequence",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "357",
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
																				const = 10120811
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
												id = "355",
												class = "Action",
												properties = {
													{
														Method = {
															func = "waitTime",
															params = {
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
							},
							{
								node = {
									id = "359",
									class = "IfElse",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "363",
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
																	const = "Sleep"
																}
															}
														}
													},
													{
														Opr = {
															const = 32
														}
													}
												},
												attachments = {},
												children = {}
											}
										},
										{
											node = {
												id = "361",
												class = "Sequence",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "334",
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
															id = "336",
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
																				const = true
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
															id = "353",
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
																				const = 10120810
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
												id = "360",
												class = "Action",
												properties = {
													{
														Method = {
															func = "waitTime",
															params = {
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
							},
							{
								node = {
									id = "364",
									class = "IfElse",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "368",
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
																	const = "Sleep"
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
												id = "396",
												class = "IfElse",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "397",
															class = "Condition",
															properties = {
																{
																	Operator = "LessEqual"
																},
																{
																	Opl = {
																		func = "getTimerValue",
																		params = {
																			{
																				const = "Sleep"
																			}
																		}
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
															id = "366",
															class = "Sequence",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		id = "367",
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
																							const = 10120811
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
																		id = "385",
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
																							const = 10120811
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
																		id = "386",
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
																							const = 10120811
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
																		id = "393",
																		class = "Action",
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
													},
													{
														node = {
															id = "398",
															class = "Action",
															properties = {
																{
																	Method = {
																		func = "waitTime",
																		params = {
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
										},
										{
											node = {
												id = "365",
												class = "Action",
												properties = {
													{
														Method = {
															func = "waitTime",
															params = {
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
							},
							{
								node = {
									id = "381",
									class = "Sequence",
									properties = {},
									attachments = {},
									children = {
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
															field = "tgt"
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
												id = "382",
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
																	const = true
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
												id = "384",
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
																	const = 10120810
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
	}
}

return ST_Monster_AutoCombat_10012_Rogue_1
