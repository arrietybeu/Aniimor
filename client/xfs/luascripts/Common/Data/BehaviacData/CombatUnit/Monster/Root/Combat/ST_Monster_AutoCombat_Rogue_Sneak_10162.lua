-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\CombatUnit\\Monster\\Root\\Combat\\ST_Monster_AutoCombat_Rogue_Sneak_10162.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local ST_Monster_AutoCombat_Rogue_Sneak_10162 = {
	behavior = {
		version = 132,
		useForRoute = false,
		agenttype = "PuppetAgent",
		name = "CombatUnit/Monster/Root/Combat/ST_Monster_AutoCombat_Rogue_Sneak_10162",
		properties = {},
		pars = {
			{
				const = 0,
				value = "0",
				name = "CurrentDistToTarget",
				type = "float"
			},
			{
				const = 0,
				value = "0",
				name = "CurrentBoxDistToTarget",
				type = "float"
			},
			{
				const = 0,
				value = "0",
				name = "goBackDist",
				type = "float"
			},
			{
				const = 0,
				value = "0",
				name = "skillStopDist",
				type = "float"
			},
			{
				const = 0,
				value = "0",
				name = "tWeight_Group_SideWalk",
				type = "int"
			},
			{
				const = 0,
				value = "0",
				name = "tWeight_Group_Wait",
				type = "int"
			},
			{
				const = 0,
				value = "0",
				name = "tWeight_Group_Angry",
				type = "int"
			}
		},
		attachments = {},
		node = {
			id = "334",
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
						id = "314",
						class = "IfElse",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									id = "333",
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
														const = "fly"
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
									id = "312",
									class = "Sequence",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "337",
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
										},
										{
											node = {
												id = "423",
												class = "Action",
												properties = {
													{
														Method = {
															func = "switchToSneak"
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
												id = "332",
												class = "Action",
												properties = {
													{
														Method = {
															func = "startTimer",
															params = {
																{
																	const = "fly"
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
												id = "408",
												class = "Action",
												properties = {
													{
														Method = {
															func = "startTimer",
															params = {
																{
																	const = "sidewalk"
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
												id = "417",
												class = "Action",
												properties = {
													{
														Method = {
															func = "startTimer",
															params = {
																{
																	const = "flytime"
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
									id = "390",
									class = "IfElse",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "388",
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
																	const = "fly"
																}
															}
														}
													},
													{
														Opr = {
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
												id = "391",
												class = "Sequence",
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
																		func = "switchToSneak"
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
															id = "393",
															class = "Action",
															properties = {
																{
																	Method = {
																		func = "startTimer",
																		params = {
																			{
																				const = "fly"
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
															id = "422",
															class = "Action",
															properties = {
																{
																	Method = {
																		func = "startTimer",
																		params = {
																			{
																				const = "flytime"
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
												id = "315",
												class = "Sequence",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "316",
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
															id = "317",
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
															id = "318",
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
															id = "319",
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
															id = "442",
															class = "IfElse",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		id = "443",
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
																							const = "flytime"
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
																},
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
																										const = "flytime"
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
																					id = "447",
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
																										const = 999999
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
																		id = "341",
																		class = "IfElse",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					id = "340",
																					class = "Condition",
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
																					id = "448",
																					class = "Sequence",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								id = "426",
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
																													const = 1.5
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
																								id = "449",
																								class = "Selector",
																								properties = {},
																								attachments = {},
																								children = {
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
																																field = "tgt"
																															},
																															{
																																const = 11620400
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
																											id = "451",
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
																						}
																					}
																				}
																			},
																			{
																				node = {
																					id = "410",
																					class = "IfElse",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								id = "409",
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
																													const = "sidewalk"
																												}
																											}
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
																								id = "411",
																								class = "Sequence",
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
																														func = "startTimer",
																														params = {
																															{
																																const = "sidewalk"
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
																											id = "394",
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
																														id = "395",
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
																																	id = "405",
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
																												},
																												{
																													node = {
																														id = "396",
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
																																	id = "406",
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
																																						const = 2
																																					},
																																					{
																																						const = -35
																																					},
																																					{
																																						const = -2
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
																														id = "397",
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
																																	id = "404",
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
																																						const = 60
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
																														id = "398",
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
																																	id = "403",
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
																																						const = 2
																																					},
																																					{
																																						const = -60
																																					},
																																					{
																																						const = -2
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
																														id = "399",
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
																																	id = "401",
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
																																						const = 45
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
																														id = "400",
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
																																	id = "402",
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
																																						const = 2
																																					},
																																					{
																																						const = -45
																																					},
																																					{
																																						const = -2
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
																						},
																						{
																							node = {
																								id = "358",
																								class = "Selector",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											id = "321",
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
																														id = "322",
																														class = "DecoratorWeight",
																														properties = {
																															{
																																DecorateWhenChildEnds = "false"
																															},
																															{
																																Weight = {
																																	const = 3
																																}
																															}
																														},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	id = "326",
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
																																						const = 11620300
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
																														id = "323",
																														class = "DecoratorWeight",
																														properties = {
																															{
																																DecorateWhenChildEnds = "false"
																															},
																															{
																																Weight = {
																																	const = 2
																																}
																															}
																														},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	id = "452",
																																	class = "IfElse",
																																	properties = {},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				id = "453",
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
																																				id = "438",
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
																																									const = 11620400
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
																																				id = "437",
																																				class = "Action",
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
																															}
																														}
																													}
																												}
																											}
																										}
																									},
																									{
																										node = {
																											id = "454",
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
																														id = "455",
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
																																	id = "465",
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
																												},
																												{
																													node = {
																														id = "456",
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
																																	id = "466",
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
																																						const = 2
																																					},
																																					{
																																						const = -35
																																					},
																																					{
																																						const = -2
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
																														id = "457",
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
																																	id = "464",
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
																																						const = 60
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
																														id = "458",
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
																																	id = "463",
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
																																						const = 2
																																					},
																																					{
																																						const = -60
																																					},
																																					{
																																						const = -2
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
																														id = "459",
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
																																	id = "461",
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
																																						const = 45
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
																														id = "460",
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
																																	id = "462",
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
																																						const = 2
																																					},
																																					{
																																						const = -45
																																					},
																																					{
																																						const = -2
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

return ST_Monster_AutoCombat_Rogue_Sneak_10162
