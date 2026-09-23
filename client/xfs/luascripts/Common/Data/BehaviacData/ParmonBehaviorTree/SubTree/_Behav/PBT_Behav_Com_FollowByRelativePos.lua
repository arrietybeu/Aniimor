-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\_Behav\\PBT_Behav_Com_FollowByRelativePos.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Behav_Com_FollowByRelativePos = {
	behavior = {
		version = 95,
		agenttype = "CombatAgent",
		name = "ParmonBehaviorTree/SubTree/_Behav/PBT_Behav_Com_FollowByRelativePos",
		useForRoute = false,
		properties = {},
		pars = {
			{
				const = 0,
				name = "tTargetActorId",
				value = "0",
				type = "int"
			},
			{
				const = 0,
				name = "tRandomValue",
				value = "0",
				type = "float"
			}
		},
		attachments = {},
		node = {
			id = "102",
			class = "Sequence",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						id = "101",
						class = "Condition",
						properties = {
							{
								Operator = "Equal"
							},
							{
								Opl = {
									func = "isInCombat",
									params = {
										{
											field = "tTargetActorId"
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
				},
				{
					node = {
						id = "105",
						class = "DecoratorLoop",
						properties = {
							{
								Count = {
									const = -1
								}
							},
							{
								DecorateWhenChildEnds = "false"
							},
							{
								DoneWithinFrame = "false"
							}
						},
						attachments = {},
						children = {
							{
								node = {
									id = "127",
									class = "IfElse",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "128",
												class = "Condition",
												properties = {
													{
														Operator = "Equal"
													},
													{
														Opl = {
															func = "checkIsFlying",
															params = {
																{
																	field = "selfId"
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
										},
										{
											node = {
												id = "116",
												class = "Selector",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "117",
															class = "Sequence",
															properties = {},
															attachments = {
																{
																	transition = false,
																	id = "35",
																	class = "Precondition",
																	effector = false,
																	precondition = true,
																	properties = {
																		{
																			BinaryOperator = "And"
																		},
																		{
																			Operator = "GreaterEqual"
																		},
																		{
																			Opl = {
																				func = "getDistByTgt",
																				params = {
																					{
																						field = "tTargetActorId"
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
																				const = 2
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
																		id = "104",
																		class = "Action",
																		properties = {
																			{
																				Method = {
																					func = "followTargetByRelativePos",
																					params = {
																						{
																							field = "tTargetActorId"
																						},
																						{
																							const = 5
																						},
																						{
																							const = 1
																						},
																						{
																							const = 0
																						},
																						{
																							const = 0
																						},
																						{
																							const = -1.3
																						},
																						{
																							const = 3
																						},
																						{
																							const = 8
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
															id = "120",
															class = "Sequence",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		id = "113",
																		class = "Assignment",
																		properties = {
																			{
																				CastRight = "false"
																			},
																			{
																				Opl = {
																					field = "tRandomValue"
																				}
																			},
																			{
																				Opr = {
																					func = "getRandomFloat",
																					params = {
																						{
																							const = 0
																						},
																						{
																							const = 1
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
																		id = "107",
																		class = "Sequence",
																		properties = {},
																		attachments = {
																			{
																				transition = false,
																				id = "35",
																				class = "Precondition",
																				effector = false,
																				precondition = true,
																				properties = {
																					{
																						BinaryOperator = "And"
																					},
																					{
																						Operator = "LessEqual"
																					},
																					{
																						Opl = {
																							func = "getDistByTgt",
																							params = {
																								{
																									field = "tTargetActorId"
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
																							const = 3.5
																						}
																					},
																					{
																						Phase = "Both"
																					}
																				}
																			},
																			{
																				transition = false,
																				id = "96",
																				class = "Effector",
																				effector = true,
																				precondition = false,
																				properties = {
																					{
																						Operator = "Invalid"
																					},
																					{
																						Opl = {
																							func = "hideEmojiBubble"
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
																					id = "124",
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
																			},
																			{
																				node = {
																					id = "108",
																					class = "Selector",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								id = "114",
																								class = "Sequence",
																								properties = {},
																								attachments = {
																									{
																										transition = false,
																										id = "35",
																										class = "Precondition",
																										effector = false,
																										precondition = true,
																										properties = {
																											{
																												BinaryOperator = "And"
																											},
																											{
																												Operator = "LessEqual"
																											},
																											{
																												Opl = {
																													func = "getDistByTgt",
																													params = {
																														{
																															field = "tTargetActorId"
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
																													const = 2
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
																											id = "106",
																											class = "IfElse",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "112",
																														class = "Condition",
																														properties = {
																															{
																																Operator = "GreaterEqual"
																															},
																															{
																																Opl = {
																																	field = "tRandomValue"
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
																														id = "118",
																														class = "Action",
																														properties = {
																															{
																																Method = {
																																	func = "playSleAnimationOnce",
																																	params = {
																																		{
																																			const = "Behav_HappyStart"
																																		},
																																		{
																																			const = "Behav_HappyLoop"
																																		},
																																		{
																																			const = "Behav_HappyEnd"
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
																												},
																												{
																													node = {
																														id = "111",
																														class = "False",
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
																								id = "119",
																								class = "IfElse",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											id = "110",
																											class = "Condition",
																											properties = {
																												{
																													Operator = "LessEqual"
																												},
																												{
																													Opl = {
																														field = "tRandomValue"
																													}
																												},
																												{
																													Opr = {
																														const = 0.15
																													}
																												}
																											},
																											attachments = {},
																											children = {}
																										}
																									},
																									{
																										node = {
																											id = "123",
																											class = "Sequence",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "126",
																														class = "Action",
																														properties = {
																															{
																																Method = {
																																	func = "showEmojiBubble",
																																	params = {
																																		{
																																			const = "Happy"
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
																														id = "109",
																														class = "Action",
																														properties = {
																															{
																																Method = {
																																	func = "moveAroundTarget",
																																	params = {
																																		{
																																			field = "tTargetActorId"
																																		},
																																		{
																																			const = 1.5
																																		},
																																		{
																																			const = 0
																																		},
																																		{
																																			const = BaseEnum.SpeedRateType.Slow
																																		},
																																		{
																																			const = false
																																		},
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
																												},
																												{
																													node = {
																														id = "125",
																														class = "Action",
																														properties = {
																															{
																																Method = {
																																	func = "turnToTarget",
																																	params = {
																																		{
																																			field = "tTargetActorId"
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
																											id = "103",
																											class = "Noop",
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
											}
										},
										{
											node = {
												id = "131",
												class = "Selector",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "130",
															class = "Sequence",
															properties = {},
															attachments = {
																{
																	transition = false,
																	id = "35",
																	class = "Precondition",
																	effector = false,
																	precondition = true,
																	properties = {
																		{
																			BinaryOperator = "And"
																		},
																		{
																			Operator = "GreaterEqual"
																		},
																		{
																			Opl = {
																				func = "getDistByTgt",
																				params = {
																					{
																						field = "tTargetActorId"
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
																				const = 2
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
																		id = "129",
																		class = "Action",
																		properties = {
																			{
																				Method = {
																					func = "moveToTarget",
																					params = {
																						{
																							field = "tTargetActorId"
																						},
																						{
																							const = 5
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
															id = "132",
															class = "Sequence",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		id = "139",
																		class = "Action",
																		properties = {
																			{
																				Method = {
																					func = "turnToTarget",
																					params = {
																						{
																							field = "tTargetActorId"
																						},
																						{
																							const = false
																						},
																						{
																							const = 2
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
																		id = "133",
																		class = "Assignment",
																		properties = {
																			{
																				CastRight = "false"
																			},
																			{
																				Opl = {
																					field = "tRandomValue"
																				}
																			},
																			{
																				Opr = {
																					func = "getRandomFloat",
																					params = {
																						{
																							const = 0
																						},
																						{
																							const = 1
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
																		id = "138",
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
																},
																{
																	node = {
																		id = "134",
																		class = "IfElse",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					id = "136",
																					class = "Condition",
																					properties = {
																						{
																							Operator = "GreaterEqual"
																						},
																						{
																							Opl = {
																								field = "tRandomValue"
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
																					id = "137",
																					class = "Action",
																					properties = {
																						{
																							Method = {
																								func = "playSleAnimationOnce",
																								params = {
																									{
																										const = "Behav_HappyStart"
																									},
																									{
																										const = "Behav_HappyLoop"
																									},
																									{
																										const = "Behav_HappyEnd"
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
																			},
																			{
																				node = {
																					id = "135",
																					class = "False",
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
					}
				}
			}
		}
	}
}

return PBT_Behav_Com_FollowByRelativePos
