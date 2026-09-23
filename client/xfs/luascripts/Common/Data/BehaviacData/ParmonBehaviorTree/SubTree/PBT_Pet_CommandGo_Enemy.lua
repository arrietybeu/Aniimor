-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_Pet_CommandGo_Enemy.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Pet_CommandGo_Enemy = {
	behavior = {
		useForRoute = false,
		agenttype = "PetAgent",
		name = "ParmonBehaviorTree/SubTree/PBT_Pet_CommandGo_Enemy",
		version = 17,
		properties = {},
		pars = {
			{
				name = "tTargetId",
				type = "int",
				const = 0,
				value = "0"
			},
			{
				name = "tTeleportDis",
				type = "float",
				const = 0,
				value = "0"
			},
			{
				name = "CurrentDistToTarget",
				type = "float",
				const = 0,
				value = "0"
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
						id = "46",
						class = "Sequence",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									id = "32",
									class = "Assignment",
									properties = {
										{
											CastRight = "false"
										},
										{
											Opl = {
												field = "masterId"
											}
										},
										{
											Opr = {
												func = "getMasterId"
											}
										}
									},
									attachments = {},
									children = {}
								}
							},
							{
								node = {
									id = "47",
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
							}
						}
					}
				},
				{
					node = {
						id = "26",
						class = "IfElse",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									id = "30",
									class = "Condition",
									properties = {
										{
											Operator = "NotEqual"
										},
										{
											Opl = {
												func = "isInCombat",
												params = {
													{
														field = "masterId"
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
									id = "3",
									class = "Action",
									properties = {
										{
											Method = {
												func = "showMasterBubble",
												params = {
													{
														const = "go"
													},
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
											ResultResumeOption = "BT_None"
										}
									},
									attachments = {},
									children = {}
								}
							},
							{
								node = {
									id = "28",
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
						id = "5",
						class = "Action",
						properties = {
							{
								Method = {
									func = "playMasterSound",
									params = {
										{
											const = "vox_player_go"
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
						id = "2",
						class = "IfElse",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									id = "6",
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
														field = "tTargetId"
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
									id = "7",
									class = "Sequence",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "9",
												class = "Action",
												properties = {
													{
														Method = {
															func = "showEmojiBubble",
															params = {
																{
																	const = "Think"
																},
																{
																	const = 5
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
												id = "10",
												class = "Selector",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "11",
															class = "DecoratorTime",
															properties = {
																{
																	Time = {
																		const = 6000
																	}
																},
																{
																	DecorateWhenChildEnds = "true"
																}
															},
															attachments = {
																{
																	transition = false,
																	id = "23",
																	class = "Precondition",
																	effector = false,
																	precondition = true,
																	properties = {
																		{
																			BinaryOperator = "And"
																		},
																		{
																			Operator = "Equal"
																		},
																		{
																			Opl = {
																				func = "checkIsInRangeTgt2D",
																				params = {
																					{
																						field = "masterId"
																					},
																					{
																						const = 0
																					},
																					{
																						const = 20
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
																			Opr2 = {
																				const = true
																			}
																		},
																		{
																			Phase = "Update"
																		}
																	}
																}
															},
															children = {
																{
																	node = {
																		id = "13",
																		class = "Action",
																		properties = {
																			{
																				Method = {
																					func = "turnToTarget",
																					params = {
																						{
																							field = "tTargetId"
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
															id = "12",
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
							},
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
												class = "Selector",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "16",
															class = "IfElse",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		id = "33",
																		class = "Sequence",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					id = "35",
																					class = "Compute",
																					properties = {
																						{
																							Operator = "Add"
																						},
																						{
																							Opl = {
																								field = "tTeleportDis"
																							}
																						},
																						{
																							Opr1 = {
																								field = "attackStopBoxDist"
																							}
																						},
																						{
																							Opr2 = {
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
																					id = "18",
																					class = "Condition",
																					properties = {
																						{
																							Operator = "Equal"
																						},
																						{
																							Opl = {
																								func = "checkIsInRangeTgt",
																								params = {
																									{
																										field = "tTargetId"
																									},
																									{
																										const = 0
																									},
																									{
																										field = "tTeleportDis"
																									},
																									{
																										const = true
																									},
																									{
																										const = true
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
																		id = "19",
																		class = "Action",
																		properties = {
																			{
																				Method = {
																					func = "turnToTarget",
																					params = {
																						{
																							field = "tTargetId"
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
																		id = "20",
																		class = "Sequence",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					id = "21",
																					class = "Action",
																					properties = {
																						{
																							Method = {
																								func = "petTeleportToTarget",
																								params = {
																									{
																										field = "tTargetId"
																									},
																									{
																										field = "attackStopBoxDist"
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
																					id = "25",
																					class = "Action",
																					properties = {
																						{
																							Method = {
																								func = "playEffectOnTarget",
																								params = {
																									{
																										const = "Eff_Common_Parmon_Switch"
																									},
																									{
																										field = "selfId"
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
																					id = "22",
																					class = "Wait",
																					properties = {
																						{
																							Time = {
																								const = 200
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
															id = "17",
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
												id = "45",
												class = "IfElse",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "40",
															class = "Condition",
															properties = {
																{
																	Operator = "Greater"
																},
																{
																	Opl = {
																		field = "CurrentDistToTarget"
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
															id = "41",
															class = "Sequence",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		id = "42",
																		class = "Action",
																		properties = {
																			{
																				Method = {
																					func = "moveToTarget",
																					params = {
																						{
																							field = "tTargetId"
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
																		id = "43",
																		class = "Action",
																		properties = {
																			{
																				Method = {
																					func = "castNormalAtkCombo",
																					params = {
																						{
																							field = "tTargetId"
																						},
																						{
																							const = 0
																						},
																						{
																							const = true
																						},
																						{
																							const = 1
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
															id = "44",
															class = "Action",
															properties = {
																{
																	Method = {
																		func = "castNormalAtkCombo",
																		params = {
																			{
																				field = "tTargetId"
																			},
																			{
																				const = 0
																			},
																			{
																				const = true
																			},
																			{
																				const = 1
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
															attachments = {
																{
																	transition = false,
																	id = "356",
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
																				field = "CurrentDistToTarget"
																			}
																		},
																		{
																			Opr2 = {
																				field = "maxAttackDist"
																			}
																		},
																		{
																			Phase = "Update"
																		}
																	}
																}
															},
															children = {}
														}
													}
												}
											}
										},
										{
											node = {
												id = "37",
												class = "Sequence",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "38",
															class = "Condition",
															properties = {
																{
																	Operator = "NotEqual"
																},
																{
																	Opl = {
																		func = "isInCombat",
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
															id = "39",
															class = "Action",
															properties = {
																{
																	Method = {
																		func = "showEmojiBubble",
																		params = {
																			{
																				const = "Think"
																			},
																			{
																				const = 5
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

return PBT_Pet_CommandGo_Enemy
