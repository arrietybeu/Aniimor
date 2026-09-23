-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\CombatUnit\\Monster\\Root\\Combat\\ST_Monster_AutoCombat_Boss_Minespine.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local ST_Monster_AutoCombat_Boss_Minespine = {
	behavior = {
		version = 144,
		name = "CombatUnit/Monster/Root/Combat/ST_Monster_AutoCombat_Boss_Minespine",
		useForRoute = false,
		agenttype = "PuppetAgent",
		properties = {},
		pars = {
			{
				type = "float",
				const = 0,
				name = "goBackDist",
				value = "0"
			},
			{
				type = "float",
				const = 0,
				name = "selfhp",
				value = "0"
			},
			{
				type = "float",
				const = 0,
				name = "disToTgtForSkillMon",
				value = "0"
			},
			{
				type = "int",
				const = 0,
				name = "creations",
				value = "0"
			},
			{
				type = "float",
				const = 0,
				name = "RandomYaw",
				value = "0"
			},
			{
				type = "int",
				const = 0,
				name = "battlestage",
				value = "0"
			},
			{
				type = "float",
				const = 0,
				name = "disToBornPos",
				value = "0"
			},
			{
				type = "int",
				const = 0,
				name = "skillfail",
				value = "0"
			},
			{
				type = "int",
				const = 0,
				name = "happyaction",
				value = "0"
			}
		},
		attachments = {},
		node = {
			id = "26",
			class = "Sequence",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						id = "444",
						class = "Sequence",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									id = "445",
									class = "Action",
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
									id = "443",
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
									id = "446",
									class = "Assignment",
									properties = {
										{
											CastRight = "false"
										},
										{
											Opl = {
												field = "bornPos"
											}
										},
										{
											Opr = {
												func = "getBornPos"
											}
										}
									},
									attachments = {},
									children = {}
								}
							},
							{
								node = {
									id = "383",
									class = "IfElse",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "384",
												class = "Condition",
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
												id = "375",
												class = "Sequence",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "442",
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
																				const = 0
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
															id = "376",
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
																				const = 12850710
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
												id = "447",
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
										}
									}
								}
							},
							{
								node = {
									id = "589",
									class = "Assignment",
									properties = {
										{
											CastRight = "false"
										},
										{
											Opl = {
												field = "battlestage"
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
									id = "588",
									class = "Assignment",
									properties = {
										{
											CastRight = "false"
										},
										{
											Opl = {
												field = "skillfail"
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
						id = "10",
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
									id = "25",
									class = "Sequence",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "393",
												class = "Sequence",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "381",
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
															id = "394",
															class = "Assignment",
															properties = {
																{
																	CastRight = "false"
																},
																{
																	Opl = {
																		field = "disToBornPos"
																	}
																},
																{
																	Opr = {
																		func = "getDistByPos",
																		params = {
																			{
																				field = "bornPos"
																			},
																			{
																				const = true
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
													}
												}
											}
										},
										{
											node = {
												id = "221",
												class = "IfElse",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "665",
															class = "And",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		id = "664",
																		class = "Condition",
																		properties = {
																			{
																				Operator = "NotEqual"
																			},
																			{
																				Opl = {
																					func = "checkIsInBreakRecover",
																					params = {
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
																		id = "227",
																		class = "Condition",
																		properties = {
																			{
																				Operator = "Equal"
																			},
																			{
																				Opl = {
																					field = "battlestage"
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
																		id = "700",
																		class = "Condition",
																		properties = {
																			{
																				Operator = "Equal"
																			},
																			{
																				Opl = {
																					func = "checkCanUseSkill",
																					params = {
																						{
																							field = "selfId"
																						},
																						{
																							const = 12851003
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
															id = "34",
															class = "IfElse",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		id = "669",
																		class = "And",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					id = "668",
																					class = "Condition",
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
																					id = "33",
																					class = "Condition",
																					properties = {
																						{
																							Operator = "Less"
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
																			}
																		}
																	}
																},
																{
																	node = {
																		id = "29",
																		class = "IfElse",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					id = "211",
																					class = "Condition",
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
																					id = "395",
																					class = "IfElse",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								id = "396",
																								class = "Condition",
																								properties = {
																									{
																										Operator = "GreaterEqual"
																									},
																									{
																										Opl = {
																											field = "disToBornPos"
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
																						},
																						{
																							node = {
																								id = "421",
																								class = "Sequence",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											id = "425",
																											class = "Assignment",
																											properties = {
																												{
																													CastRight = "false"
																												},
																												{
																													Opl = {
																														field = "battlestage"
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
																											id = "438",
																											class = "Action",
																											properties = {
																												{
																													Method = {
																														func = "turnToPos",
																														params = {
																															{
																																field = "bornPos"
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
																											id = "431",
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
																																const = 12850801
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
																											id = "450",
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
																																const = 12850702
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
																											id = "612",
																											class = "Selector",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "424",
																														class = "Action",
																														properties = {
																															{
																																Method = {
																																	func = "moveToPos",
																																	params = {
																																		{
																																			field = "bornPos"
																																		},
																																		{
																																			const = 5
																																		},
																																		{
																																			const = true
																																		},
																																		{
																																			const = 1
																																		},
																																		{
																																			const = BaseEnum.SpeedRateType.Fast
																																		},
																																		{
																																			const = 13
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
																												},
																												{
																													node = {
																														id = "613",
																														class = "True",
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
																											id = "539",
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
																																const = 12851003
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
																													ResultResumeOption = "BT_NextNode"
																												}
																											},
																											attachments = {
																												{
																													precondition = true,
																													id = "595",
																													class = "Precondition",
																													transition = false,
																													effector = false,
																													properties = {
																														{
																															BinaryOperator = "And"
																														},
																														{
																															Operator = "Equal"
																														},
																														{
																															Opl = {
																																func = "checkIsInSneak"
																															}
																														},
																														{
																															Opr2 = {
																																const = true
																															}
																														},
																														{
																															Phase = "Enter"
																														}
																													}
																												}
																											},
																											children = {}
																										}
																									},
																									{
																										node = {
																											id = "538",
																											class = "Selector",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "656",
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
																																			const = 12850713
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
																																ResultResumeOption = "BT_NextNode"
																															}
																														},
																														attachments = {
																															{
																																precondition = true,
																																id = "651",
																																class = "Precondition",
																																transition = false,
																																effector = false,
																																properties = {
																																	{
																																		BinaryOperator = "And"
																																	},
																																	{
																																		Operator = "Equal"
																																	},
																																	{
																																		Opl = {
																																			func = "checkIsInSneak"
																																		}
																																	},
																																	{
																																		Opr2 = {
																																			const = true
																																		}
																																	},
																																	{
																																		Phase = "Enter"
																																	}
																																}
																															}
																														},
																														children = {}
																													}
																												},
																												{
																													node = {
																														id = "681",
																														class = "Sequence",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	id = "540",
																																	class = "Assignment",
																																	properties = {
																																		{
																																			CastRight = "false"
																																		},
																																		{
																																			Opl = {
																																				field = "skillfail"
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
																																	id = "682",
																																	class = "Action",
																																	properties = {
																																		{
																																			Method = {
																																				func = "addBuff",
																																				params = {
																																					{
																																						const = 1000601
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
																																			ResultResumeOption = "BT_NextNode"
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
																								id = "400",
																								class = "IfElse",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											id = "401",
																											class = "Condition",
																											properties = {
																												{
																													Operator = "GreaterEqual"
																												},
																												{
																													Opl = {
																														field = "disToBornPos"
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
																											id = "214",
																											class = "Sequence",
																											properties = {},
																											attachments = {},
																											children = {
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
																																	field = "battlestage"
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
																														id = "614",
																														class = "Selector",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	id = "378",
																																	class = "Action",
																																	properties = {
																																		{
																																			Method = {
																																				func = "moveToPos",
																																				params = {
																																					{
																																						field = "bornPos"
																																					},
																																					{
																																						const = 5
																																					},
																																					{
																																						const = true
																																					},
																																					{
																																						const = 1
																																					},
																																					{
																																						const = BaseEnum.SpeedRateType.Fast
																																					},
																																					{
																																						const = 13
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
																															},
																															{
																																node = {
																																	id = "618",
																																	class = "True",
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
																														id = "596",
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
																																			const = 12851003
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
																																ResultResumeOption = "BT_NextNode"
																															}
																														},
																														attachments = {
																															{
																																precondition = true,
																																id = "595",
																																class = "Precondition",
																																transition = false,
																																effector = false,
																																properties = {
																																	{
																																		BinaryOperator = "And"
																																	},
																																	{
																																		Operator = "Equal"
																																	},
																																	{
																																		Opl = {
																																			func = "checkIsInSneak"
																																		}
																																	},
																																	{
																																		Opr2 = {
																																			const = true
																																		}
																																	},
																																	{
																																		Phase = "Enter"
																																	}
																																}
																															}
																														},
																														children = {}
																													}
																												},
																												{
																													node = {
																														id = "535",
																														class = "Selector",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	id = "655",
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
																																						const = 12850713
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
																																			ResultResumeOption = "BT_NextNode"
																																		}
																																	},
																																	attachments = {
																																		{
																																			precondition = true,
																																			id = "651",
																																			class = "Precondition",
																																			transition = false,
																																			effector = false,
																																			properties = {
																																				{
																																					BinaryOperator = "And"
																																				},
																																				{
																																					Operator = "Equal"
																																				},
																																				{
																																					Opl = {
																																						func = "checkIsInSneak"
																																					}
																																				},
																																				{
																																					Opr2 = {
																																						const = true
																																					}
																																				},
																																				{
																																					Phase = "Enter"
																																				}
																																			}
																																		}
																																	},
																																	children = {}
																																}
																															},
																															{
																																node = {
																																	id = "695",
																																	class = "Sequence",
																																	properties = {},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				id = "537",
																																				class = "Assignment",
																																				properties = {
																																					{
																																						CastRight = "false"
																																					},
																																					{
																																						Opl = {
																																							field = "skillfail"
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
																																				id = "696",
																																				class = "Action",
																																				properties = {
																																					{
																																						Method = {
																																							func = "addBuff",
																																							params = {
																																								{
																																									const = 1000601
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
																																						ResultResumeOption = "BT_NextNode"
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
																											id = "416",
																											class = "Sequence",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "420",
																														class = "Assignment",
																														properties = {
																															{
																																CastRight = "false"
																															},
																															{
																																Opl = {
																																	field = "battlestage"
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
																														id = "597",
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
																																			const = 12851003
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
																																ResultResumeOption = "BT_NextNode"
																															}
																														},
																														attachments = {
																															{
																																precondition = true,
																																id = "595",
																																class = "Precondition",
																																transition = false,
																																effector = false,
																																properties = {
																																	{
																																		BinaryOperator = "And"
																																	},
																																	{
																																		Operator = "Equal"
																																	},
																																	{
																																		Opl = {
																																			func = "checkIsInSneak"
																																		}
																																	},
																																	{
																																		Opr2 = {
																																			const = true
																																		}
																																	},
																																	{
																																		Phase = "Enter"
																																	}
																																}
																															}
																														},
																														children = {}
																													}
																												},
																												{
																													node = {
																														id = "532",
																														class = "Selector",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	id = "654",
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
																																						const = 12850713
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
																																			ResultResumeOption = "BT_NextNode"
																																		}
																																	},
																																	attachments = {
																																		{
																																			precondition = true,
																																			id = "651",
																																			class = "Precondition",
																																			transition = false,
																																			effector = false,
																																			properties = {
																																				{
																																					BinaryOperator = "And"
																																				},
																																				{
																																					Operator = "Equal"
																																				},
																																				{
																																					Opl = {
																																						func = "checkIsInSneak"
																																					}
																																				},
																																				{
																																					Opr2 = {
																																						const = true
																																					}
																																				},
																																				{
																																					Phase = "Enter"
																																				}
																																			}
																																		}
																																	},
																																	children = {}
																																}
																															},
																															{
																																node = {
																																	id = "679",
																																	class = "Sequence",
																																	properties = {},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				id = "533",
																																				class = "Assignment",
																																				properties = {
																																					{
																																						CastRight = "false"
																																					},
																																					{
																																						Opl = {
																																							field = "skillfail"
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
																																				id = "680",
																																				class = "Action",
																																				properties = {
																																					{
																																						Method = {
																																							func = "addBuff",
																																							params = {
																																								{
																																									const = 1000601
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
																																						ResultResumeOption = "BT_NextNode"
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
																					id = "398",
																					class = "IfElse",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								id = "399",
																								class = "Condition",
																								properties = {
																									{
																										Operator = "GreaterEqual"
																									},
																									{
																										Opl = {
																											field = "disToBornPos"
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
																								id = "414",
																								class = "Sequence",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											id = "410",
																											class = "Assignment",
																											properties = {
																												{
																													CastRight = "false"
																												},
																												{
																													Opl = {
																														field = "battlestage"
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
																											id = "430",
																											class = "Sequence",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "440",
																														class = "Action",
																														properties = {
																															{
																																Method = {
																																	func = "turnToPos",
																																	params = {
																																		{
																																			field = "bornPos"
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
																														id = "415",
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
																																			const = 12850703
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
																														id = "616",
																														class = "Selector",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	id = "413",
																																	class = "Action",
																																	properties = {
																																		{
																																			Method = {
																																				func = "moveToPos",
																																				params = {
																																					{
																																						field = "bornPos"
																																					},
																																					{
																																						const = 5
																																					},
																																					{
																																						const = true
																																					},
																																					{
																																						const = 3
																																					},
																																					{
																																						const = BaseEnum.SpeedRateType.Fast
																																					},
																																					{
																																						const = 13
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
																															},
																															{
																																node = {
																																	id = "621",
																																	class = "True",
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
																											id = "598",
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
																																const = 12851003
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
																													ResultResumeOption = "BT_NextNode"
																												}
																											},
																											attachments = {
																												{
																													precondition = true,
																													id = "595",
																													class = "Precondition",
																													transition = false,
																													effector = false,
																													properties = {
																														{
																															BinaryOperator = "And"
																														},
																														{
																															Operator = "Equal"
																														},
																														{
																															Opl = {
																																func = "checkIsInSneak"
																															}
																														},
																														{
																															Opr2 = {
																																const = true
																															}
																														},
																														{
																															Phase = "Enter"
																														}
																													}
																												}
																											},
																											children = {}
																										}
																									},
																									{
																										node = {
																											id = "529",
																											class = "Selector",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "653",
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
																																			const = 12850713
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
																																ResultResumeOption = "BT_NextNode"
																															}
																														},
																														attachments = {
																															{
																																precondition = true,
																																id = "651",
																																class = "Precondition",
																																transition = false,
																																effector = false,
																																properties = {
																																	{
																																		BinaryOperator = "And"
																																	},
																																	{
																																		Operator = "Equal"
																																	},
																																	{
																																		Opl = {
																																			func = "checkIsInSneak"
																																		}
																																	},
																																	{
																																		Opr2 = {
																																			const = true
																																		}
																																	},
																																	{
																																		Phase = "Enter"
																																	}
																																}
																															}
																														},
																														children = {}
																													}
																												},
																												{
																													node = {
																														id = "677",
																														class = "Sequence",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	id = "530",
																																	class = "Assignment",
																																	properties = {
																																		{
																																			CastRight = "false"
																																		},
																																		{
																																			Opl = {
																																				field = "skillfail"
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
																																	id = "678",
																																	class = "Action",
																																	properties = {
																																		{
																																			Method = {
																																				func = "addBuff",
																																				params = {
																																					{
																																						const = 1000601
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
																																			ResultResumeOption = "BT_NextNode"
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
																								id = "402",
																								class = "IfElse",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											id = "403",
																											class = "Condition",
																											properties = {
																												{
																													Operator = "GreaterEqual"
																												},
																												{
																													Opl = {
																														field = "disToBornPos"
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
																											id = "212",
																											class = "Sequence",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "228",
																														class = "Assignment",
																														properties = {
																															{
																																CastRight = "false"
																															},
																															{
																																Opl = {
																																	field = "battlestage"
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
																														id = "441",
																														class = "Action",
																														properties = {
																															{
																																Method = {
																																	func = "turnToPos",
																																	params = {
																																		{
																																			field = "bornPos"
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
																														id = "388",
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
																																			const = 12850702
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
																														id = "619",
																														class = "Selector",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	id = "379",
																																	class = "Action",
																																	properties = {
																																		{
																																			Method = {
																																				func = "moveToPos",
																																				params = {
																																					{
																																						field = "bornPos"
																																					},
																																					{
																																						const = 5
																																					},
																																					{
																																						const = true
																																					},
																																					{
																																						const = 1
																																					},
																																					{
																																						const = BaseEnum.SpeedRateType.Fast
																																					},
																																					{
																																						const = 13
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
																															},
																															{
																																node = {
																																	id = "620",
																																	class = "True",
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
																																			const = 12851003
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
																																ResultResumeOption = "BT_NextNode"
																															}
																														},
																														attachments = {
																															{
																																precondition = true,
																																id = "595",
																																class = "Precondition",
																																transition = false,
																																effector = false,
																																properties = {
																																	{
																																		BinaryOperator = "And"
																																	},
																																	{
																																		Operator = "Equal"
																																	},
																																	{
																																		Opl = {
																																			func = "checkIsInSneak"
																																		}
																																	},
																																	{
																																		Opr2 = {
																																			const = true
																																		}
																																	},
																																	{
																																		Phase = "Enter"
																																	}
																																}
																															}
																														},
																														children = {}
																													}
																												},
																												{
																													node = {
																														id = "526",
																														class = "Selector",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	id = "216",
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
																																						const = 12850713
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
																																			ResultResumeOption = "BT_NextNode"
																																		}
																																	},
																																	attachments = {
																																		{
																																			precondition = true,
																																			id = "651",
																																			class = "Precondition",
																																			transition = false,
																																			effector = false,
																																			properties = {
																																				{
																																					BinaryOperator = "And"
																																				},
																																				{
																																					Operator = "Equal"
																																				},
																																				{
																																					Opl = {
																																						func = "checkIsInSneak"
																																					}
																																				},
																																				{
																																					Opr2 = {
																																						const = true
																																					}
																																				},
																																				{
																																					Phase = "Enter"
																																				}
																																			}
																																		}
																																	},
																																	children = {}
																																}
																															},
																															{
																																node = {
																																	id = "673",
																																	class = "Sequence",
																																	properties = {},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				id = "528",
																																				class = "Assignment",
																																				properties = {
																																					{
																																						CastRight = "false"
																																					},
																																					{
																																						Opl = {
																																							field = "skillfail"
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
																																				id = "674",
																																				class = "Action",
																																				properties = {
																																					{
																																						Method = {
																																							func = "addBuff",
																																							params = {
																																								{
																																									const = 1000601
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
																																						ResultResumeOption = "BT_NextNode"
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
																											id = "408",
																											class = "Sequence",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "404",
																														class = "Assignment",
																														properties = {
																															{
																																CastRight = "false"
																															},
																															{
																																Opl = {
																																	field = "battlestage"
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
																														id = "409",
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
																																			const = 12850701
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
																																ResultResumeOption = "BT_NextNode"
																															}
																														},
																														attachments = {},
																														children = {}
																													}
																												},
																												{
																													node = {
																														id = "600",
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
																																			const = 12851003
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
																																ResultResumeOption = "BT_NextNode"
																															}
																														},
																														attachments = {
																															{
																																precondition = true,
																																id = "595",
																																class = "Precondition",
																																transition = false,
																																effector = false,
																																properties = {
																																	{
																																		BinaryOperator = "And"
																																	},
																																	{
																																		Operator = "Equal"
																																	},
																																	{
																																		Opl = {
																																			func = "checkIsInSneak"
																																		}
																																	},
																																	{
																																		Opr2 = {
																																			const = true
																																		}
																																	},
																																	{
																																		Phase = "Enter"
																																	}
																																}
																															}
																														},
																														children = {}
																													}
																												},
																												{
																													node = {
																														id = "523",
																														class = "Selector",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	id = "652",
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
																																						const = 12850713
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
																																			ResultResumeOption = "BT_NextNode"
																																		}
																																	},
																																	attachments = {
																																		{
																																			precondition = true,
																																			id = "651",
																																			class = "Precondition",
																																			transition = false,
																																			effector = false,
																																			properties = {
																																				{
																																					BinaryOperator = "And"
																																				},
																																				{
																																					Operator = "Equal"
																																				},
																																				{
																																					Opl = {
																																						func = "checkIsInSneak"
																																					}
																																				},
																																				{
																																					Opr2 = {
																																						const = true
																																					}
																																				},
																																				{
																																					Phase = "Enter"
																																				}
																																			}
																																		}
																																	},
																																	children = {}
																																}
																															},
																															{
																																node = {
																																	id = "675",
																																	class = "Sequence",
																																	properties = {},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				id = "525",
																																				class = "Assignment",
																																				properties = {
																																					{
																																						CastRight = "false"
																																					},
																																					{
																																						Opl = {
																																							field = "skillfail"
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
																																				id = "676",
																																				class = "Action",
																																				properties = {
																																					{
																																						Method = {
																																							func = "addBuff",
																																							params = {
																																								{
																																									const = 1000601
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
																																						ResultResumeOption = "BT_NextNode"
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
																		id = "670",
																		class = "IfElse",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					id = "671",
																					class = "Condition",
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
																					id = "672",
																					class = "Assignment",
																					properties = {
																						{
																							CastRight = "false"
																						},
																						{
																							Opl = {
																								field = "battlestage"
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
																					id = "32",
																					class = "True",
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
															id = "222",
															class = "True",
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
												id = "466",
												class = "IfElse",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "667",
															class = "And",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		id = "666",
																		class = "Condition",
																		properties = {
																			{
																				Operator = "NotEqual"
																			},
																			{
																				Opl = {
																					func = "checkIsInBreakRecover",
																					params = {
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
																		id = "459",
																		class = "Condition",
																		properties = {
																			{
																				Operator = "Equal"
																			},
																			{
																				Opl = {
																					field = "battlestage"
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
																		id = "697",
																		class = "Condition",
																		properties = {
																			{
																				Operator = "Equal"
																			},
																			{
																				Opl = {
																					func = "checkCanUseSkill",
																					params = {
																						{
																							field = "selfId"
																						},
																						{
																							const = 12851003
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
															id = "458",
															class = "IfElse",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		id = "457",
																		class = "Condition",
																		properties = {
																			{
																				Operator = "Less"
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
																					const = 0.4
																				}
																			}
																		},
																		attachments = {},
																		children = {}
																	}
																},
																{
																	node = {
																		id = "454",
																		class = "IfElse",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					id = "460",
																					class = "Condition",
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
																					id = "471",
																					class = "IfElse",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								id = "472",
																								class = "Condition",
																								properties = {
																									{
																										Operator = "GreaterEqual"
																									},
																									{
																										Opl = {
																											field = "disToBornPos"
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
																						},
																						{
																							node = {
																								id = "494",
																								class = "Sequence",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											id = "607",
																											class = "Assignment",
																											properties = {
																												{
																													CastRight = "false"
																												},
																												{
																													Opl = {
																														field = "battlestage"
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
																									},
																									{
																										node = {
																											id = "502",
																											class = "Action",
																											properties = {
																												{
																													Method = {
																														func = "turnToPos",
																														params = {
																															{
																																field = "bornPos"
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
																											id = "501",
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
																																const = 12850801
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
																											id = "623",
																											class = "Selector",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "497",
																														class = "Action",
																														properties = {
																															{
																																Method = {
																																	func = "moveToPos",
																																	params = {
																																		{
																																			field = "bornPos"
																																		},
																																		{
																																			const = 5
																																		},
																																		{
																																			const = true
																																		},
																																		{
																																			const = 1
																																		},
																																		{
																																			const = BaseEnum.SpeedRateType.Fast
																																		},
																																		{
																																			const = 13
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
																												},
																												{
																													node = {
																														id = "624",
																														class = "True",
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
																											id = "601",
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
																																const = 12851003
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
																											attachments = {
																												{
																													precondition = true,
																													id = "595",
																													class = "Precondition",
																													transition = false,
																													effector = false,
																													properties = {
																														{
																															BinaryOperator = "And"
																														},
																														{
																															Operator = "Equal"
																														},
																														{
																															Opl = {
																																func = "checkIsInSneak"
																															}
																														},
																														{
																															Opr2 = {
																																const = true
																															}
																														},
																														{
																															Phase = "Enter"
																														}
																													}
																												}
																											},
																											children = {}
																										}
																									},
																									{
																										node = {
																											id = "632",
																											class = "Selector",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "657",
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
																																			const = 12850713
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
																																ResultResumeOption = "BT_NextNode"
																															}
																														},
																														attachments = {
																															{
																																precondition = true,
																																id = "651",
																																class = "Precondition",
																																transition = false,
																																effector = false,
																																properties = {
																																	{
																																		BinaryOperator = "And"
																																	},
																																	{
																																		Operator = "Equal"
																																	},
																																	{
																																		Opl = {
																																			func = "checkIsInSneak"
																																		}
																																	},
																																	{
																																		Opr2 = {
																																			const = true
																																		}
																																	},
																																	{
																																		Phase = "Enter"
																																	}
																																}
																															}
																														},
																														children = {}
																													}
																												},
																												{
																													node = {
																														id = "683",
																														class = "Sequence",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	id = "631",
																																	class = "Assignment",
																																	properties = {
																																		{
																																			CastRight = "false"
																																		},
																																		{
																																			Opl = {
																																				field = "skillfail"
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
																																	id = "684",
																																	class = "Action",
																																	properties = {
																																		{
																																			Method = {
																																				func = "addBuff",
																																				params = {
																																					{
																																						const = 1000601
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
																																			ResultResumeOption = "BT_NextNode"
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
																								id = "475",
																								class = "IfElse",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											id = "476",
																											class = "Condition",
																											properties = {
																												{
																													Operator = "GreaterEqual"
																												},
																												{
																													Opl = {
																														field = "disToBornPos"
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
																											id = "462",
																											class = "Sequence",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "468",
																														class = "Assignment",
																														properties = {
																															{
																																CastRight = "false"
																															},
																															{
																																Opl = {
																																	field = "battlestage"
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
																												},
																												{
																													node = {
																														id = "625",
																														class = "Selector",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	id = "469",
																																	class = "Action",
																																	properties = {
																																		{
																																			Method = {
																																				func = "moveToPos",
																																				params = {
																																					{
																																						field = "bornPos"
																																					},
																																					{
																																						const = 5
																																					},
																																					{
																																						const = true
																																					},
																																					{
																																						const = 1
																																					},
																																					{
																																						const = BaseEnum.SpeedRateType.Fast
																																					},
																																					{
																																						const = 13
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
																															},
																															{
																																node = {
																																	id = "626",
																																	class = "True",
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
																														id = "602",
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
																																			const = 12851003
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
																																ResultResumeOption = "BT_NextNode"
																															}
																														},
																														attachments = {
																															{
																																precondition = true,
																																id = "595",
																																class = "Precondition",
																																transition = false,
																																effector = false,
																																properties = {
																																	{
																																		BinaryOperator = "And"
																																	},
																																	{
																																		Operator = "Equal"
																																	},
																																	{
																																		Opl = {
																																			func = "checkIsInSneak"
																																		}
																																	},
																																	{
																																		Opr2 = {
																																			const = true
																																		}
																																	},
																																	{
																																		Phase = "Enter"
																																	}
																																}
																															}
																														},
																														children = {}
																													}
																												},
																												{
																													node = {
																														id = "634",
																														class = "Selector",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	id = "658",
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
																																						const = 12850713
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
																																			ResultResumeOption = "BT_NextNode"
																																		}
																																	},
																																	attachments = {
																																		{
																																			precondition = true,
																																			id = "651",
																																			class = "Precondition",
																																			transition = false,
																																			effector = false,
																																			properties = {
																																				{
																																					BinaryOperator = "And"
																																				},
																																				{
																																					Operator = "Equal"
																																				},
																																				{
																																					Opl = {
																																						func = "checkIsInSneak"
																																					}
																																				},
																																				{
																																					Opr2 = {
																																						const = true
																																					}
																																				},
																																				{
																																					Phase = "Enter"
																																				}
																																			}
																																		}
																																	},
																																	children = {}
																																}
																															},
																															{
																																node = {
																																	id = "685",
																																	class = "Sequence",
																																	properties = {},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				id = "633",
																																				class = "Assignment",
																																				properties = {
																																					{
																																						CastRight = "false"
																																					},
																																					{
																																						Opl = {
																																							field = "skillfail"
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
																																				id = "686",
																																				class = "Action",
																																				properties = {
																																					{
																																						Method = {
																																							func = "addBuff",
																																							params = {
																																								{
																																									const = 1000601
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
																																						ResultResumeOption = "BT_NextNode"
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
																											id = "490",
																											class = "Sequence",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "493",
																														class = "Assignment",
																														properties = {
																															{
																																CastRight = "false"
																															},
																															{
																																Opl = {
																																	field = "battlestage"
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
																												},
																												{
																													node = {
																														id = "603",
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
																																			const = 12851003
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
																																ResultResumeOption = "BT_NextNode"
																															}
																														},
																														attachments = {
																															{
																																precondition = true,
																																id = "595",
																																class = "Precondition",
																																transition = false,
																																effector = false,
																																properties = {
																																	{
																																		BinaryOperator = "And"
																																	},
																																	{
																																		Operator = "Equal"
																																	},
																																	{
																																		Opl = {
																																			func = "checkIsInSneak"
																																		}
																																	},
																																	{
																																		Opr2 = {
																																			const = true
																																		}
																																	},
																																	{
																																		Phase = "Enter"
																																	}
																																}
																															}
																														},
																														children = {}
																													}
																												},
																												{
																													node = {
																														id = "636",
																														class = "Selector",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	id = "659",
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
																																						const = 12850713
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
																																			ResultResumeOption = "BT_NextNode"
																																		}
																																	},
																																	attachments = {
																																		{
																																			precondition = true,
																																			id = "651",
																																			class = "Precondition",
																																			transition = false,
																																			effector = false,
																																			properties = {
																																				{
																																					BinaryOperator = "And"
																																				},
																																				{
																																					Operator = "Equal"
																																				},
																																				{
																																					Opl = {
																																						func = "checkIsInSneak"
																																					}
																																				},
																																				{
																																					Opr2 = {
																																						const = true
																																					}
																																				},
																																				{
																																					Phase = "Enter"
																																				}
																																			}
																																		}
																																	},
																																	children = {}
																																}
																															},
																															{
																																node = {
																																	id = "687",
																																	class = "Sequence",
																																	properties = {},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				id = "635",
																																				class = "Assignment",
																																				properties = {
																																					{
																																						CastRight = "false"
																																					},
																																					{
																																						Opl = {
																																							field = "skillfail"
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
																																				id = "688",
																																				class = "Action",
																																				properties = {
																																					{
																																						Method = {
																																							func = "addBuff",
																																							params = {
																																								{
																																									const = 1000601
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
																																						ResultResumeOption = "BT_NextNode"
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
																					id = "473",
																					class = "IfElse",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								id = "474",
																								class = "Condition",
																								properties = {
																									{
																										Operator = "GreaterEqual"
																									},
																									{
																										Opl = {
																											field = "disToBornPos"
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
																								id = "488",
																								class = "Sequence",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											id = "484",
																											class = "Assignment",
																											properties = {
																												{
																													CastRight = "false"
																												},
																												{
																													Opl = {
																														field = "battlestage"
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
																									},
																									{
																										node = {
																											id = "500",
																											class = "Sequence",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "503",
																														class = "Action",
																														properties = {
																															{
																																Method = {
																																	func = "turnToPos",
																																	params = {
																																		{
																																			field = "bornPos"
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
																														id = "489",
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
																																			const = 12850703
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
																														id = "627",
																														class = "Selector",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	id = "487",
																																	class = "Action",
																																	properties = {
																																		{
																																			Method = {
																																				func = "moveToPos",
																																				params = {
																																					{
																																						field = "bornPos"
																																					},
																																					{
																																						const = 5
																																					},
																																					{
																																						const = true
																																					},
																																					{
																																						const = 3
																																					},
																																					{
																																						const = BaseEnum.SpeedRateType.Fast
																																					},
																																					{
																																						const = 13
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
																															},
																															{
																																node = {
																																	id = "628",
																																	class = "True",
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
																											id = "604",
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
																																const = 12851003
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
																													ResultResumeOption = "BT_NextNode"
																												}
																											},
																											attachments = {
																												{
																													precondition = true,
																													id = "595",
																													class = "Precondition",
																													transition = false,
																													effector = false,
																													properties = {
																														{
																															BinaryOperator = "And"
																														},
																														{
																															Operator = "Equal"
																														},
																														{
																															Opl = {
																																func = "checkIsInSneak"
																															}
																														},
																														{
																															Opr2 = {
																																const = true
																															}
																														},
																														{
																															Phase = "Enter"
																														}
																													}
																												}
																											},
																											children = {}
																										}
																									},
																									{
																										node = {
																											id = "638",
																											class = "Selector",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "660",
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
																																			const = 12850713
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
																																ResultResumeOption = "BT_NextNode"
																															}
																														},
																														attachments = {
																															{
																																precondition = true,
																																id = "651",
																																class = "Precondition",
																																transition = false,
																																effector = false,
																																properties = {
																																	{
																																		BinaryOperator = "And"
																																	},
																																	{
																																		Operator = "Equal"
																																	},
																																	{
																																		Opl = {
																																			func = "checkIsInSneak"
																																		}
																																	},
																																	{
																																		Opr2 = {
																																			const = true
																																		}
																																	},
																																	{
																																		Phase = "Enter"
																																	}
																																}
																															}
																														},
																														children = {}
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
																																	id = "637",
																																	class = "Assignment",
																																	properties = {
																																		{
																																			CastRight = "false"
																																		},
																																		{
																																			Opl = {
																																				field = "skillfail"
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
																																	id = "690",
																																	class = "Action",
																																	properties = {
																																		{
																																			Method = {
																																				func = "addBuff",
																																				params = {
																																					{
																																						const = 1000601
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
																																			ResultResumeOption = "BT_NextNode"
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
																								id = "477",
																								class = "IfElse",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											id = "478",
																											class = "Condition",
																											properties = {
																												{
																													Operator = "GreaterEqual"
																												},
																												{
																													Opl = {
																														field = "disToBornPos"
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
																											id = "455",
																											class = "Sequence",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "452",
																														class = "Assignment",
																														properties = {
																															{
																																CastRight = "false"
																															},
																															{
																																Opl = {
																																	field = "battlestage"
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
																												},
																												{
																													node = {
																														id = "504",
																														class = "Action",
																														properties = {
																															{
																																Method = {
																																	func = "turnToPos",
																																	params = {
																																		{
																																			field = "bornPos"
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
																														id = "470",
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
																																			const = 12850702
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
																														id = "629",
																														class = "Selector",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	id = "465",
																																	class = "Action",
																																	properties = {
																																		{
																																			Method = {
																																				func = "moveToPos",
																																				params = {
																																					{
																																						field = "bornPos"
																																					},
																																					{
																																						const = 5
																																					},
																																					{
																																						const = true
																																					},
																																					{
																																						const = 1
																																					},
																																					{
																																						const = BaseEnum.SpeedRateType.Fast
																																					},
																																					{
																																						const = 13
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
																															},
																															{
																																node = {
																																	id = "630",
																																	class = "True",
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
																														id = "605",
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
																																			const = 12851003
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
																																ResultResumeOption = "BT_NextNode"
																															}
																														},
																														attachments = {
																															{
																																precondition = true,
																																id = "595",
																																class = "Precondition",
																																transition = false,
																																effector = false,
																																properties = {
																																	{
																																		BinaryOperator = "And"
																																	},
																																	{
																																		Operator = "Equal"
																																	},
																																	{
																																		Opl = {
																																			func = "checkIsInSneak"
																																		}
																																	},
																																	{
																																		Opr2 = {
																																			const = true
																																		}
																																	},
																																	{
																																		Phase = "Enter"
																																	}
																																}
																															}
																														},
																														children = {}
																													}
																												},
																												{
																													node = {
																														id = "640",
																														class = "Selector",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	id = "661",
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
																																						const = 12850713
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
																																			ResultResumeOption = "BT_NextNode"
																																		}
																																	},
																																	attachments = {
																																		{
																																			precondition = true,
																																			id = "651",
																																			class = "Precondition",
																																			transition = false,
																																			effector = false,
																																			properties = {
																																				{
																																					BinaryOperator = "And"
																																				},
																																				{
																																					Operator = "Equal"
																																				},
																																				{
																																					Opl = {
																																						func = "checkIsInSneak"
																																					}
																																				},
																																				{
																																					Opr2 = {
																																						const = true
																																					}
																																				},
																																				{
																																					Phase = "Enter"
																																				}
																																			}
																																		}
																																	},
																																	children = {}
																																}
																															},
																															{
																																node = {
																																	id = "691",
																																	class = "Sequence",
																																	properties = {},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				id = "639",
																																				class = "Assignment",
																																				properties = {
																																					{
																																						CastRight = "false"
																																					},
																																					{
																																						Opl = {
																																							field = "skillfail"
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
																																				id = "692",
																																				class = "Action",
																																				properties = {
																																					{
																																						Method = {
																																							func = "addBuff",
																																							params = {
																																								{
																																									const = 1000601
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
																																						ResultResumeOption = "BT_NextNode"
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
																											id = "482",
																											class = "Sequence",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "479",
																														class = "Assignment",
																														properties = {
																															{
																																CastRight = "false"
																															},
																															{
																																Opl = {
																																	field = "battlestage"
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
																												},
																												{
																													node = {
																														id = "483",
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
																																			const = 12850701
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
																														id = "606",
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
																																			const = 12851003
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
																																ResultResumeOption = "BT_NextNode"
																															}
																														},
																														attachments = {
																															{
																																precondition = true,
																																id = "595",
																																class = "Precondition",
																																transition = false,
																																effector = false,
																																properties = {
																																	{
																																		BinaryOperator = "And"
																																	},
																																	{
																																		Operator = "Equal"
																																	},
																																	{
																																		Opl = {
																																			func = "checkIsInSneak"
																																		}
																																	},
																																	{
																																		Opr2 = {
																																			const = true
																																		}
																																	},
																																	{
																																		Phase = "Enter"
																																	}
																																}
																															}
																														},
																														children = {}
																													}
																												},
																												{
																													node = {
																														id = "642",
																														class = "Selector",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	id = "662",
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
																																						const = 12850713
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
																																			ResultResumeOption = "BT_NextNode"
																																		}
																																	},
																																	attachments = {
																																		{
																																			precondition = true,
																																			id = "651",
																																			class = "Precondition",
																																			transition = false,
																																			effector = false,
																																			properties = {
																																				{
																																					BinaryOperator = "And"
																																				},
																																				{
																																					Operator = "Equal"
																																				},
																																				{
																																					Opl = {
																																						func = "checkIsInSneak"
																																					}
																																				},
																																				{
																																					Opr2 = {
																																						const = true
																																					}
																																				},
																																				{
																																					Phase = "Enter"
																																				}
																																			}
																																		}
																																	},
																																	children = {}
																																}
																															},
																															{
																																node = {
																																	id = "693",
																																	class = "Sequence",
																																	properties = {},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				id = "641",
																																				class = "Assignment",
																																				properties = {
																																					{
																																						CastRight = "false"
																																					},
																																					{
																																						Opl = {
																																							field = "skillfail"
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
																																				id = "694",
																																				class = "Action",
																																				properties = {
																																					{
																																						Method = {
																																							func = "addBuff",
																																							params = {
																																								{
																																									const = 1000601
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
																																						ResultResumeOption = "BT_NextNode"
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
																		id = "456",
																		class = "True",
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
															id = "467",
															class = "True",
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
												id = "580",
												class = "IfElse",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "575",
															class = "Condition",
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
															id = "578",
															class = "IfElse",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		id = "573",
																		class = "Condition",
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
																},
																{
																	node = {
																		id = "572",
																		class = "Selector",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					id = "576",
																					class = "Sequence",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								id = "570",
																								class = "Selector",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											id = "569",
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
																																const = "JumpBackCd"
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
																											id = "568",
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
																																const = "JumpBackCd"
																															}
																														}
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
																									}
																								}
																							}
																						},
																						{
																							node = {
																								id = "566",
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
																													const = 5
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
																								id = "571",
																								class = "Action",
																								properties = {
																									{
																										Method = {
																											func = "startTimer",
																											params = {
																												{
																													const = "JumpBackCd"
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
																					id = "567",
																					class = "Action",
																					properties = {
																						{
																							Method = {
																								func = "walkBack",
																								params = {
																									{
																										field = "tgt"
																									},
																									{
																										const = 5
																									},
																									{
																										const = 3
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
																		id = "582",
																		class = "True",
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
															id = "581",
															class = "True",
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
												id = "11",
												class = "Sequence",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "544",
															class = "IfElse",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		id = "644",
																		class = "Condition",
																		properties = {
																			{
																				Operator = "Greater"
																			},
																			{
																				Opl = {
																					field = "skillfail"
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
																		id = "650",
																		class = "Sequence",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					id = "648",
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
																					id = "647",
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
																							ResultResumeOption = "BT_ResumeSelf"
																						}
																					},
																					attachments = {},
																					children = {}
																				}
																			},
																			{
																				node = {
																					id = "649",
																					class = "Assignment",
																					properties = {
																						{
																							CastRight = "false"
																						},
																						{
																							Opl = {
																								field = "skillfail"
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
																					id = "663",
																					class = "Assignment",
																					properties = {
																						{
																							CastRight = "false"
																						},
																						{
																							Opl = {
																								field = "happyaction"
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
																		id = "645",
																		class = "IfElse",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					id = "543",
																					class = "Condition",
																					properties = {
																						{
																							Operator = "GreaterEqual"
																						},
																						{
																							Opl = {
																								field = "happyaction"
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
																					id = "119",
																					class = "Sequence",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								id = "118",
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
																								id = "112",
																								class = "Action",
																								properties = {
																									{
																										Method = {
																											func = "playAction",
																											params = {
																												{
																													const = "Behav_Happy"
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
																										ResultResumeOption = "BT_ResumeSelf"
																									}
																								},
																								attachments = {},
																								children = {}
																							}
																						},
																						{
																							node = {
																								id = "546",
																								class = "Assignment",
																								properties = {
																									{
																										CastRight = "false"
																									},
																									{
																										Opl = {
																											field = "happyaction"
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
																					id = "646",
																					class = "True",
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
															id = "17",
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
															id = "18",
															class = "Assignment",
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
															id = "19",
															class = "Assignment",
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
															id = "150",
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
																		id = "152",
																		class = "DecoratorWeight",
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
																					id = "156",
																					class = "Sequence",
																					properties = {},
																					attachments = {
																						{
																							precondition = true,
																							id = "549",
																							class = "Precondition",
																							transition = false,
																							effector = false,
																							properties = {
																								{
																									BinaryOperator = "And"
																								},
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
																									Opr2 = {
																										const = 1
																									}
																								},
																								{
																									Phase = "Enter"
																								}
																							}
																						},
																						{
																							precondition = true,
																							id = "550",
																							class = "Precondition",
																							transition = false,
																							effector = false,
																							properties = {
																								{
																									BinaryOperator = "And"
																								},
																								{
																									Operator = "Equal"
																								},
																								{
																									Opl = {
																										func = "checkCanCombat"
																									}
																								},
																								{
																									Opr2 = {
																										const = true
																									}
																								},
																								{
																									Phase = "Enter"
																								}
																							}
																						}
																					},
																					children = {
																						{
																							node = {
																								id = "145",
																								class = "Sequence",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											id = "144",
																											class = "Assignment",
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
																														func = "getPropertyCd",
																														params = {
																															{
																																const = "fightCd"
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
																											id = "146",
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
																														func = "getPropertyCd",
																														params = {
																															{
																																const = "skillCd"
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
																											id = "168",
																											class = "Assignment",
																											properties = {
																												{
																													CastRight = "false"
																												},
																												{
																													Opl = {
																														field = "atkCd"
																													}
																												},
																												{
																													Opr = {
																														func = "getPropertyCd",
																														params = {
																															{
																																const = "atkCd"
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
																								id = "147",
																								class = "Selector",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											id = "169",
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
																																const = "fightCd01"
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
																											id = "170",
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
																																const = "fightCd01"
																															}
																														}
																													}
																												},
																												{
																													Opr = {
																														field = "fightCd"
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
																								id = "171",
																								class = "Selector",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											id = "172",
																											class = "Sequence",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "148",
																														class = "Selector",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	id = "158",
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
																																	id = "157",
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
																														id = "173",
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
																														id = "183",
																														class = "Sequence",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	id = "178",
																																	class = "IfElse",
																																	properties = {},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				id = "149",
																																				class = "Condition",
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
																																				id = "163",
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
																																							id = "349",
																																							class = "DecoratorWeight",
																																							properties = {
																																								{
																																									DecorateWhenChildEnds = "false"
																																								},
																																								{
																																									Weight = {
																																										const = 70
																																									}
																																								}
																																							},
																																							attachments = {},
																																							children = {
																																								{
																																									node = {
																																										id = "551",
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
																																															const = 12850102
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
																																							id = "362",
																																							class = "DecoratorWeight",
																																							properties = {
																																								{
																																									DecorateWhenChildEnds = "false"
																																								},
																																								{
																																									Weight = {
																																										const = 20
																																									}
																																								}
																																							},
																																							attachments = {},
																																							children = {
																																								{
																																									node = {
																																										id = "363",
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
																																															const = 10
																																														},
																																														{
																																															const = 3
																																														},
																																														{
																																															const = true
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
																																					}
																																				}
																																			}
																																		},
																																		{
																																			node = {
																																				id = "185",
																																				class = "IfElse",
																																				properties = {},
																																				attachments = {},
																																				children = {
																																					{
																																						node = {
																																							id = "186",
																																							class = "Condition",
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
																																							id = "189",
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
																																										id = "318",
																																										class = "DecoratorWeight",
																																										properties = {
																																											{
																																												DecorateWhenChildEnds = "false"
																																											},
																																											{
																																												Weight = {
																																													const = 20
																																												}
																																											}
																																										},
																																										attachments = {},
																																										children = {
																																											{
																																												node = {
																																													id = "311",
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
																																																id = "317",
																																																class = "DecoratorWeight",
																																																properties = {
																																																	{
																																																		DecorateWhenChildEnds = "false"
																																																	},
																																																	{
																																																		Weight = {
																																																			const = 50
																																																		}
																																																	}
																																																},
																																																attachments = {},
																																																children = {
																																																	{
																																																		node = {
																																																			id = "314",
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
																																																								const = 12850201
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
																																																id = "312",
																																																class = "DecoratorWeight",
																																																properties = {
																																																	{
																																																		DecorateWhenChildEnds = "false"
																																																	},
																																																	{
																																																		Weight = {
																																																			const = 50
																																																		}
																																																	}
																																																},
																																																attachments = {},
																																																children = {
																																																	{
																																																		node = {
																																																			id = "315",
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
																																																								const = 12850202
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
																																																id = "313",
																																																class = "DecoratorWeight",
																																																properties = {
																																																	{
																																																		DecorateWhenChildEnds = "false"
																																																	},
																																																	{
																																																		Weight = {
																																																			const = 50
																																																		}
																																																	}
																																																},
																																																attachments = {},
																																																children = {
																																																	{
																																																		node = {
																																																			id = "316",
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
																																																								const = 12850203
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
																																								},
																																								{
																																									node = {
																																										id = "330",
																																										class = "DecoratorWeight",
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
																																													id = "552",
																																													class = "Sequence",
																																													properties = {},
																																													attachments = {
																																														{
																																															precondition = true,
																																															id = "553",
																																															class = "Precondition",
																																															transition = false,
																																															effector = false,
																																															properties = {
																																																{
																																																	BinaryOperator = "And"
																																																},
																																																{
																																																	Operator = "Less"
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
																																																	Opr2 = {
																																																		const = 0.85
																																																	}
																																																},
																																																{
																																																	Phase = "Enter"
																																																}
																																															}
																																														}
																																													},
																																													children = {
																																														{
																																															node = {
																																																id = "334",
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
																																																					const = 12850102
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
																																										id = "583",
																																										class = "DecoratorWeight",
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
																																													id = "585",
																																													class = "Sequence",
																																													properties = {},
																																													attachments = {
																																														{
																																															precondition = true,
																																															id = "553",
																																															class = "Precondition",
																																															transition = false,
																																															effector = false,
																																															properties = {
																																																{
																																																	BinaryOperator = "And"
																																																},
																																																{
																																																	Operator = "Less"
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
																																																	Opr2 = {
																																																		const = 0.7
																																																	}
																																																},
																																																{
																																																	Phase = "Enter"
																																																}
																																															}
																																														}
																																													},
																																													children = {
																																														{
																																															node = {
																																																id = "584",
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
																																																					const = 12850500
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
																																										id = "205",
																																										class = "DecoratorWeight",
																																										properties = {
																																											{
																																												DecorateWhenChildEnds = "false"
																																											},
																																											{
																																												Weight = {
																																													const = 20
																																												}
																																											}
																																										},
																																										attachments = {},
																																										children = {
																																											{
																																												node = {
																																													id = "206",
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
																																																		const = 5
																																																	},
																																																	{
																																																		const = 3
																																																	},
																																																	{
																																																		const = true
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
																																								}
																																							}
																																						}
																																					},
																																					{
																																						node = {
																																							id = "188",
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
																																										id = "203",
																																										class = "DecoratorWeight",
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
																																													id = "204",
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
																																																		const = 12850600
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
																																										id = "201",
																																										class = "DecoratorWeight",
																																										properties = {
																																											{
																																												DecorateWhenChildEnds = "false"
																																											},
																																											{
																																												Weight = {
																																													const = 40
																																												}
																																											}
																																										},
																																										attachments = {},
																																										children = {
																																											{
																																												node = {
																																													id = "304",
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
																																																id = "308",
																																																class = "DecoratorWeight",
																																																properties = {
																																																	{
																																																		DecorateWhenChildEnds = "false"
																																																	},
																																																	{
																																																		Weight = {
																																																			const = 50
																																																		}
																																																	}
																																																},
																																																attachments = {},
																																																children = {
																																																	{
																																																		node = {
																																																			id = "307",
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
																																																								const = 12850201
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
																																																id = "305",
																																																class = "DecoratorWeight",
																																																properties = {
																																																	{
																																																		DecorateWhenChildEnds = "false"
																																																	},
																																																	{
																																																		Weight = {
																																																			const = 50
																																																		}
																																																	}
																																																},
																																																attachments = {},
																																																children = {
																																																	{
																																																		node = {
																																																			id = "306",
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
																																																								const = 12850202
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
																																																id = "309",
																																																class = "DecoratorWeight",
																																																properties = {
																																																	{
																																																		DecorateWhenChildEnds = "false"
																																																	},
																																																	{
																																																		Weight = {
																																																			const = 50
																																																		}
																																																	}
																																																},
																																																attachments = {},
																																																children = {
																																																	{
																																																		node = {
																																																			id = "310",
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
																																																								const = 12850203
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
																															},
																															{
																																node = {
																																	id = "104",
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
																																				id = "109",
																																				class = "DecoratorWeight",
																																				properties = {
																																					{
																																						DecorateWhenChildEnds = "false"
																																					},
																																					{
																																						Weight = {
																																							const = 20
																																						}
																																					}
																																				},
																																				attachments = {},
																																				children = {
																																					{
																																						node = {
																																							id = "365",
																																							class = "IfElse",
																																							properties = {},
																																							attachments = {},
																																							children = {
																																								{
																																									node = {
																																										id = "364",
																																										class = "Condition",
																																										properties = {
																																											{
																																												Operator = "Less"
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
																																										id = "366",
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
																																															const = 12851002
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
																																															const = 12851001
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
																																				id = "110",
																																				class = "DecoratorWeight",
																																				properties = {
																																					{
																																						DecorateWhenChildEnds = "false"
																																					},
																																					{
																																						Weight = {
																																							const = 20
																																						}
																																					}
																																				},
																																				attachments = {},
																																				children = {
																																					{
																																						node = {
																																							id = "114",
																																							class = "IfElse",
																																							properties = {},
																																							attachments = {},
																																							children = {
																																								{
																																									node = {
																																										id = "115",
																																										class = "Condition",
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
																																													const = 7
																																												}
																																											}
																																										},
																																										attachments = {},
																																										children = {}
																																									}
																																								},
																																								{
																																									node = {
																																										id = "141",
																																										class = "Sequence",
																																										properties = {},
																																										attachments = {},
																																										children = {
																																											{
																																												node = {
																																													id = "138",
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
																																																field = "distToTgt"
																																															}
																																														}
																																													},
																																													attachments = {},
																																													children = {}
																																												}
																																											},
																																											{
																																												node = {
																																													id = "289",
																																													class = "Sequence",
																																													properties = {},
																																													attachments = {},
																																													children = {
																																														{
																																															node = {
																																																id = "288",
																																																class = "Assignment",
																																																properties = {
																																																	{
																																																		CastRight = "false"
																																																	},
																																																	{
																																																		Opl = {
																																																			field = "RandomYaw"
																																																		}
																																																	},
																																																	{
																																																		Opr = {
																																																			func = "getRandomFloat",
																																																			params = {
																																																				{
																																																					const = -45
																																																				},
																																																				{
																																																					const = 45
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
																																																id = "286",
																																																class = "Action",
																																																properties = {
																																																	{
																																																		Method = {
																																																			func = "turnToTargetAtYaw",
																																																			params = {
																																																				{
																																																					field = "tgt"
																																																				},
																																																				{
																																																					const = 90
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
																																																id = "287",
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
																																																					const = 12850801
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
																																										id = "116",
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
																																															const = 7
																																														},
																																														{
																																															const = 3
																																														},
																																														{
																																															const = true
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
																																					}
																																				}
																																			}
																																		},
																																		{
																																			node = {
																																				id = "111",
																																				class = "DecoratorWeight",
																																				properties = {
																																					{
																																						DecorateWhenChildEnds = "false"
																																					},
																																					{
																																						Weight = {
																																							const = 20
																																						}
																																					}
																																				},
																																				attachments = {},
																																				children = {
																																					{
																																						node = {
																																							id = "285",
																																							class = "Sequence",
																																							properties = {},
																																							attachments = {},
																																							children = {
																																								{
																																									node = {
																																										id = "284",
																																										class = "Assignment",
																																										properties = {
																																											{
																																												CastRight = "false"
																																											},
																																											{
																																												Opl = {
																																													field = "RandomYaw"
																																												}
																																											},
																																											{
																																												Opr = {
																																													func = "getRandomFloat",
																																													params = {
																																														{
																																															const = -45
																																														},
																																														{
																																															const = 45
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
																																										id = "282",
																																										class = "Action",
																																										properties = {
																																											{
																																												Method = {
																																													func = "turnToTargetAtYaw",
																																													params = {
																																														{
																																															field = "tgt"
																																														},
																																														{
																																															field = "RandomYaw"
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
																																										id = "283",
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
																																															const = 12850801
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
																															},
																															{
																																node = {
																																	id = "542",
																																	class = "Compute",
																																	properties = {
																																		{
																																			Operator = "Add"
																																		},
																																		{
																																			Opl = {
																																				field = "happyaction"
																																			}
																																		},
																																		{
																																			Opr1 = {
																																				field = "happyaction"
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
																															}
																														}
																													}
																												},
																												{
																													node = {
																														id = "175",
																														class = "Action",
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
																											id = "176",
																											class = "Sequence",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "177",
																														class = "Selector",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	id = "180",
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
																																						const = "atkCd01"
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
																																	id = "181",
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
																																						const = "atkCd01"
																																					}
																																				}
																																			}
																																		},
																																		{
																																			Opr = {
																																				field = "atkCd"
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
																														id = "608",
																														class = "Selector",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	id = "448",
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
																																						const = 12851001
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
																																	id = "611",
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
																																						const = 12850500
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
																														id = "93",
																														class = "Action",
																														properties = {
																															{
																																Method = {
																																	func = "startTimer",
																																	params = {
																																		{
																																			const = "atkCd01"
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
																														id = "541",
																														class = "Compute",
																														properties = {
																															{
																																Operator = "Add"
																															},
																															{
																																Opl = {
																																	field = "happyaction"
																																}
																															},
																															{
																																Opr1 = {
																																	field = "happyaction"
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
																												}
																											}
																										}
																									}
																								}
																							}
																						},
																						{
																							node = {
																								id = "94",
																								class = "IfElse",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											id = "95",
																											class = "Condition",
																											properties = {
																												{
																													Operator = "Equal"
																												},
																												{
																													Opl = {
																														func = "checkIsBossAI"
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
																											id = "96",
																											class = "Sequence",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "98",
																														class = "Compute",
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
																																	const = 25
																																}
																															}
																														},
																														attachments = {},
																														children = {}
																													}
																												},
																												{
																													node = {
																														id = "99",
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
																																	const = 125
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
																											id = "97",
																											class = "Sequence",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "100",
																														class = "Compute",
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
																																	const = 25
																																}
																															}
																														},
																														attachments = {},
																														children = {}
																													}
																												},
																												{
																													node = {
																														id = "101",
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
																																	const = 125
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
																								id = "102",
																								class = "Action",
																								properties = {
																									{
																										Method = {
																											func = "startTimer",
																											params = {
																												{
																													const = "fightCd01"
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
																		id = "154",
																		class = "DecoratorWeight",
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
																					id = "554",
																					class = "Sequence",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								id = "561",
																								class = "Condition",
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
																								id = "555",
																								class = "Condition",
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
																								id = "558",
																								class = "Selector",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											id = "559",
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
																																const = "Side_Walk"
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
																											id = "560",
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
																																const = "Side_Walk"
																															}
																														}
																													}
																												},
																												{
																													Opr = {
																														const = 18
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
																								id = "562",
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
																											id = "564",
																											class = "DecoratorWeight",
																											properties = {
																												{
																													DecorateWhenChildEnds = "false"
																												},
																												{
																													Weight = {
																														const = 50
																													}
																												}
																											},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "556",
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
																																			const = 4
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
																											id = "563",
																											class = "DecoratorWeight",
																											properties = {
																												{
																													DecorateWhenChildEnds = "false"
																												},
																												{
																													Weight = {
																														const = 50
																													}
																												}
																											},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "565",
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
																																			const = 4
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
																						},
																						{
																							node = {
																								id = "557",
																								class = "Action",
																								properties = {
																									{
																										Method = {
																											func = "startTimer",
																											params = {
																												{
																													const = "Side_Walk"
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
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
}

return ST_Monster_AutoCombat_Boss_Minespine
