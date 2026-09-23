-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_Com_CombatWander.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Com_CombatWander = {
	behavior = {
		useForRoute = false,
		agenttype = "PetAgent",
		name = "ParmonBehaviorTree/SubTree/PBT_Com_CombatWander",
		version = 14,
		properties = {},
		pars = {
			{
				type = "string",
				name = "tEmojiBubbleKey",
				value = "",
				const = ""
			},
			{
				type = "float",
				name = "tEmojiBubbleTimeout",
				value = "0",
				const = 0
			},
			{
				type = "float",
				name = "tWaitTime",
				value = "0",
				const = 0
			},
			{
				type = "float",
				name = "tOccupyTime",
				value = "0",
				const = 0
			},
			{
				type = "float",
				name = "goBackDist",
				value = "0",
				const = 0
			}
		},
		attachments = {},
		node = {
			id = "51",
			class = "Sequence",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						id = "52",
						class = "Compute",
						properties = {
							{
								Operator = "Mul"
							},
							{
								Opl = {
									field = "tOccupyTime"
								}
							},
							{
								Opr1 = {
									field = "tOccupyTime"
								}
							},
							{
								Opr2 = {
									const = 1000
								}
							}
						},
						attachments = {},
						children = {}
					}
				},
				{
					node = {
						id = "6",
						class = "Action",
						properties = {
							{
								Method = {
									func = "showEmojiBubble",
									params = {
										{
											field = "tEmojiBubbleKey"
										},
										{
											field = "tEmojiBubbleTimeout"
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
						id = "45",
						class = "DecoratorTime",
						properties = {
							{
								Time = {
									field = "tOccupyTime"
								}
							},
							{
								DecorateWhenChildEnds = "false"
							}
						},
						attachments = {},
						children = {
							{
								node = {
									id = "59",
									class = "Sequence",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "61",
												class = "Selector",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "8",
															class = "Sequence",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		id = "14",
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
																		id = "15",
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
																		id = "95",
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
																		id = "84",
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
																		id = "10",
																		class = "Selector",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					id = "11",
																					class = "Sequence",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								id = "63",
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
																													const = "JumpBack"
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
																								id = "16",
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
																					id = "12",
																					class = "Sequence",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								id = "17",
																								class = "Action",
																								properties = {
																									{
																										Method = {
																											func = "runBack",
																											params = {
																												{
																													field = "tgt"
																												},
																												{
																													field = "goBackDist"
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
																			}
																		}
																	}
																}
															}
														}
													},
													{
														node = {
															id = "20",
															class = "IfElse",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		id = "21",
																		class = "Condition",
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
																		id = "22",
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
																					id = "24",
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
																								id = "23",
																								class = "Sequence",
																								properties = {},
																								attachments = {
																									{
																										transition = false,
																										id = "104",
																										class = "Precondition",
																										effector = false,
																										precondition = true,
																										properties = {
																											{
																												BinaryOperator = "And"
																											},
																											{
																												Operator = "Greater"
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
																												Opr2 = {
																													field = "minAttackDist"
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
																											id = "80",
																											class = "Selector",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "25",
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
																																			const = 1.2
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
																												},
																												{
																													node = {
																														id = "81",
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
																											id = "77",
																											class = "Action",
																											properties = {
																												{
																													Method = {
																														func = "waitTime",
																														params = {
																															{
																																const = 1
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
																					id = "27",
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
																								id = "31",
																								class = "Sequence",
																								properties = {},
																								attachments = {
																									{
																										transition = false,
																										id = "109",
																										class = "Precondition",
																										effector = false,
																										precondition = true,
																										properties = {
																											{
																												BinaryOperator = "And"
																											},
																											{
																												Operator = "Greater"
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
																												Opr2 = {
																													field = "minAttackDist"
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
																											id = "82",
																											class = "Selector",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "28",
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
																																			const = 1.2
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
																												},
																												{
																													node = {
																														id = "83",
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
																											id = "79",
																											class = "Action",
																											properties = {
																												{
																													Method = {
																														func = "waitTime",
																														params = {
																															{
																																const = 1
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
																		id = "57",
																		class = "Action",
																		properties = {
																			{
																				Method = {
																					func = "waitTime",
																					params = {
																						{
																							field = "tWaitTime"
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

return PBT_Com_CombatWander
