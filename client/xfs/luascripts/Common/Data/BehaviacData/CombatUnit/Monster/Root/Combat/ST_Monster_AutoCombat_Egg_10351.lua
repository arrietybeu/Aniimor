-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\CombatUnit\\Monster\\Root\\Combat\\ST_Monster_AutoCombat_Egg_10351.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local ST_Monster_AutoCombat_Egg_10351 = {
	behavior = {
		version = 56,
		name = "CombatUnit/Monster/Root/Combat/ST_Monster_AutoCombat_Egg_10351",
		useForRoute = false,
		agenttype = "PuppetAgent",
		properties = {},
		pars = {
			{
				name = "CurrentDistToTarget",
				const = 0,
				type = "float",
				value = "0"
			},
			{
				name = "CurrentBoxDistToTarget",
				const = 0,
				type = "float",
				value = "0"
			},
			{
				name = "goBackDist",
				const = 0,
				type = "float",
				value = "0"
			},
			{
				name = "skillStopDist",
				const = 0,
				type = "float",
				value = "0"
			},
			{
				name = "tWeight_Group_SideWalk",
				const = 100,
				type = "int",
				value = "100"
			},
			{
				name = "tWeight_Group_Wait",
				const = 100,
				type = "int",
				value = "100"
			},
			{
				name = "tWeight_Group_Angry",
				const = 100,
				type = "int",
				value = "100"
			}
		},
		attachments = {},
		node = {
			id = "326",
			class = "Sequence",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						id = "323",
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
						id = "324",
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
						id = "325",
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
						id = "322",
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
						id = "321",
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
						id = "328",
						class = "Sequence",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									id = "444",
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
														const = 1
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
														const = true
													},
													{
														const = 7
													},
													{
														const = BaseEnum.MoveUpdateLevel.Fast
													},
													{
														const = BaseEnum.PathFindType.Auto
													},
													{
														const = BaseEnum.SpeedRateType.Fast
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
									id = "423",
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
														const = 13510300
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
									id = "330",
									class = "Action",
									properties = {
										{
											Method = {
												func = "startTimer",
												params = {
													{
														const = "Attack"
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
									id = "331",
									class = "IfElse",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "327",
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
																	field = "selfId"
																},
																{
																	const = 2135102
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
												id = "435",
												class = "IfElse",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "443",
															class = "Sequence",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		id = "436",
																		class = "Condition",
																		properties = {
																			{
																				Operator = "Equal"
																			},
																			{
																				Opl = {
																					func = "checkCanMoveToTarget",
																					params = {
																						{
																							field = "tgt"
																						},
																						{
																							field = "attackStopBoxDist"
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
																		id = "442",
																		class = "Condition",
																		properties = {
																			{
																				Operator = "GreaterEqual"
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
																				Opr = {
																					const = 2
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
															id = "424",
															class = "IfElse",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		id = "425",
																		class = "Condition",
																		properties = {
																			{
																				Operator = "Equal"
																			},
																			{
																				Opl = {
																					func = "checkCanFly"
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
																		id = "432",
																		class = "Sequence",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					id = "433",
																					class = "Action",
																					properties = {
																						{
																							Method = {
																								func = "switchToFly",
																								params = {
																									{
																										const = 3
																									},
																									{
																										const = 5
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
																					id = "439",
																					class = "Action",
																					properties = {
																						{
																							Method = {
																								func = "flyToTarget",
																								params = {
																									{
																										field = "tgt"
																									},
																									{
																										const = 0.5
																									},
																									{
																										const = 2
																									},
																									{
																										const = 5
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
																					id = "434",
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
																										const = 5
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
																		id = "438",
																		class = "Sequence",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					id = "437",
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
																										const = 1
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
																					id = "426",
																					class = "Selector",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								id = "428",
																								class = "Sequence",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											id = "430",
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
																																const = "Behav_AngryLoop"
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
																											id = "431",
																											class = "Action",
																											properties = {
																												{
																													Method = {
																														func = "playPhaseAction",
																														params = {
																															{
																																const = "Behav_AngryStart"
																															},
																															{
																																const = "Behav_AngryLoop"
																															},
																															{
																																const = "Behav_AngryEnd"
																															},
																															{
																																const = 0
																															},
																															{
																																const = ""
																															},
																															{
																																const = true
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
																								id = "429",
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
																													const = 4
																												},
																												{
																													const = ""
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
															id = "350",
															class = "IfElse",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		id = "347",
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
																							const = "Attack"
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
																},
																{
																	node = {
																		id = "337",
																		class = "Sequence",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					id = "335",
																					class = "IfElse",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								id = "336",
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
																								id = "332",
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
																													const = 1
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
																													const = true
																												},
																												{
																													const = 7
																												},
																												{
																													const = BaseEnum.MoveUpdateLevel.Fast
																												},
																												{
																													const = BaseEnum.PathFindType.Auto
																												},
																												{
																													const = BaseEnum.SpeedRateType.Fast
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
																								id = "334",
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
																					id = "340",
																					class = "Sequence",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								id = "343",
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
																								id = "346",
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
																													const = 13510300
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
																								id = "342",
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
																								id = "341",
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
																													const = 13510300
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
																								id = "333",
																								class = "Action",
																								properties = {
																									{
																										Method = {
																											func = "startTimer",
																											params = {
																												{
																													const = "Attack"
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
																		id = "362",
																		class = "IfElse",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					id = "361",
																					class = "Condition",
																					properties = {
																						{
																							Operator = "GreaterEqual"
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
																					id = "364",
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
																										const = 1
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
																										const = true
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
																					id = "422",
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
												id = "389",
												class = "Selector",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "382",
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
																		id = "381",
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
																					id = "384",
																					class = "Sequence",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								id = "411",
																								class = "Selector",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											id = "402",
																											class = "Sequence",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "413",
																														class = "IfElse",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	id = "412",
																																	class = "Condition",
																																	properties = {
																																		{
																																			Operator = "LessEqual"
																																		},
																																		{
																																			Opl = {
																																				func = "getMaxAttackDist",
																																				params = {
																																					{
																																						field = "selfId"
																																					}
																																				}
																																			}
																																		},
																																		{
																																			Opr = {
																																				field = "CurrentDistToTarget"
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
																																						const = BaseEnum.MoveUpdateLevel.Once
																																					},
																																					{
																																						const = BaseEnum.PathFindType.Auto
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
																																	id = "415",
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
																														id = "416",
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
																									},
																									{
																										node = {
																											id = "407",
																											class = "Sequence",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "405",
																														class = "IfElse",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	id = "406",
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
																																	id = "401",
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
																																						const = 2
																																					},
																																					{
																																						const = 4
																																					},
																																					{
																																						const = true
																																					},
																																					{
																																						const = false
																																					},
																																					{
																																						const = true
																																					},
																																					{
																																						const = 7
																																					},
																																					{
																																						const = BaseEnum.MoveUpdateLevel.Fast
																																					},
																																					{
																																						const = BaseEnum.PathFindType.Auto
																																					},
																																					{
																																						const = BaseEnum.SpeedRateType.Fast
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
																																	id = "404",
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
																														id = "403",
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
																																			const = 13510300
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
																								id = "410",
																								class = "Sequence",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											id = "409",
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
																											id = "408",
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
																		id = "380",
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
																					id = "385",
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
															id = "400",
															class = "Sequence",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		id = "388",
																		class = "Sequence",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					id = "383",
																					class = "Compute",
																					properties = {
																						{
																							Operator = "Add"
																						},
																						{
																							Opl = {
																								field = "attackWeight"
																							}
																						},
																						{
																							Opr1 = {
																								field = "attackWeight"
																							}
																						},
																						{
																							Opr2 = {
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
																					id = "387",
																					class = "Assignment",
																					properties = {
																						{
																							CastRight = "false"
																						},
																						{
																							Opl = {
																								field = "sideWalkWeight"
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
																			}
																		}
																	}
																},
																{
																	node = {
																		id = "395",
																		class = "Selector",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					id = "396",
																					class = "Sequence",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								id = "386",
																								class = "Condition",
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
																								id = "397",
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
																								id = "390",
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
																								id = "398",
																								class = "Selector",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											id = "399",
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
																									},
																									{
																										node = {
																											id = "394",
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
																																const = 2
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
																			},
																			{
																				node = {
																					id = "393",
																					class = "Sequence",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								id = "392",
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
																								id = "391",
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
																													const = -35
																												},
																												{
																													const = -1
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

return ST_Monster_AutoCombat_Egg_10351
