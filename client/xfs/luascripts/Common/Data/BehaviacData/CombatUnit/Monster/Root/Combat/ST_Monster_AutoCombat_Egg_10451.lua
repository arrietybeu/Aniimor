-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\CombatUnit\\Monster\\Root\\Combat\\ST_Monster_AutoCombat_Egg_10451.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local ST_Monster_AutoCombat_Egg_10451 = {
	behavior = {
		useForRoute = false,
		name = "CombatUnit/Monster/Root/Combat/ST_Monster_AutoCombat_Egg_10451",
		agenttype = "PuppetAgent",
		version = 154,
		properties = {},
		pars = {
			{
				name = "disToTgtForSkillMon",
				value = "0",
				type = "float",
				const = 0
			},
			{
				name = "goBackDist",
				value = "0",
				type = "float",
				const = 0
			},
			{
				name = "MeleeA1",
				value = "50",
				type = "int",
				const = 50
			},
			{
				name = "MeleeA2",
				value = "50",
				type = "int",
				const = 50
			},
			{
				name = "RangedA1",
				value = "50",
				type = "int",
				const = 50
			},
			{
				name = "RangedA2",
				value = "50",
				type = "int",
				const = 50
			},
			{
				name = "RangedB1",
				value = "0",
				type = "int",
				const = 0
			},
			{
				name = "RangedB2",
				value = "0",
				type = "int",
				const = 0
			},
			{
				name = "MeleeB1",
				value = "50",
				type = "int",
				const = 50
			},
			{
				name = "MeleeB2",
				value = "50",
				type = "int",
				const = 50
			},
			{
				name = "MeleeB3",
				value = "50",
				type = "int",
				const = 50
			},
			{
				name = "RangedC1",
				value = "0",
				type = "int",
				const = 0
			},
			{
				name = "RangedC2",
				value = "20",
				type = "int",
				const = 20
			},
			{
				name = "RangedC3",
				value = "20",
				type = "int",
				const = 20
			},
			{
				name = "Ex1",
				value = "0",
				type = "int",
				const = 0
			},
			{
				name = "Ex2",
				value = "50",
				type = "int",
				const = 50
			},
			{
				name = "Ex3",
				value = "100",
				type = "int",
				const = 100
			},
			{
				name = "hasUsedEx",
				value = "false",
				type = "bool",
				const = false
			},
			{
				name = "wyv",
				value = "0",
				type = "int",
				const = 0
			},
			{
				name = "RangeA3",
				value = "50",
				type = "int",
				const = 50
			}
		},
		attachments = {},
		node = {
			class = "Sequence",
			id = "1",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						class = "Assignment",
						id = "281",
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
						class = "Condition",
						id = "280",
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
						class = "Assignment",
						id = "1413",
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
						class = "DecoratorLoop",
						id = "3",
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
									class = "Sequence",
									id = "1423",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												class = "Assignment",
												id = "1422",
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
												class = "Selector",
												id = "1457",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															class = "Sequence",
															id = "1458",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		class = "Condition",
																		id = "1459",
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
																							const = 1145103
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
																		class = "Action",
																		id = "1419",
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
																}
															}
														}
													},
													{
														node = {
															class = "Sequence",
															id = "1460",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		class = "Condition",
																		id = "1462",
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
																							const = 11451021
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
																		class = "SelectorProbability",
																		id = "1435",
																		properties = {
																			{
																				UntilSuccessOrEnd = false
																			}
																		},
																		attachments = {},
																		children = {
																			{
																				node = {
																					class = "DecoratorWeight",
																					id = "1437",
																					properties = {
																						{
																							DecorateWhenChildEnds = "false"
																						},
																						{
																							Weight = {
																								const = 10
																							}
																						}
																					},
																					attachments = {},
																					children = {
																						{
																							node = {
																								class = "Action",
																								id = "1441",
																								properties = {
																									{
																										Method = {
																											func = "playPhaseAction",
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
																													const = 5
																												},
																												{
																													const = "5"
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
																					class = "DecoratorWeight",
																					id = "1439",
																					properties = {
																						{
																							DecorateWhenChildEnds = "false"
																						},
																						{
																							Weight = {
																								const = 10
																							}
																						}
																					},
																					attachments = {},
																					children = {
																						{
																							node = {
																								class = "Action",
																								id = "1444",
																								properties = {
																									{
																										Method = {
																											func = "playPhaseAction",
																											params = {
																												{
																													const = "Behav_LoveStart"
																												},
																												{
																													const = "Behav_LoveLoop"
																												},
																												{
																													const = "Behav_LoveEnd"
																												},
																												{
																													const = 5
																												},
																												{
																													const = "5"
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
																					class = "DecoratorWeight",
																					id = "1440",
																					properties = {
																						{
																							DecorateWhenChildEnds = "false"
																						},
																						{
																							Weight = {
																								const = 10
																							}
																						}
																					},
																					attachments = {},
																					children = {
																						{
																							node = {
																								class = "Action",
																								id = "1445",
																								properties = {
																									{
																										Method = {
																											func = "playPhaseAction",
																											params = {
																												{
																													const = "Behav_CheerStart"
																												},
																												{
																													const = "Behav_CheerLoop"
																												},
																												{
																													const = "Behav_CheerEnd"
																												},
																												{
																													const = 5
																												},
																												{
																													const = "5"
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
															id = "1451",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		class = "Or",
																		id = "1464",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					class = "Condition",
																					id = "1452",
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
																										const = 11451022
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
																					class = "And",
																					id = "1467",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								class = "Condition",
																								id = "1465",
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
																													const = 1145103
																												},
																												{
																													const = 1
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
																								class = "Condition",
																								id = "1466",
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
																													const = 11451021
																												},
																												{
																													const = 1
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
																			}
																		}
																	}
																},
																{
																	node = {
																		class = "Action",
																		id = "1448",
																		properties = {
																			{
																				Method = {
																					func = "leaveTarget",
																					params = {
																						{
																							field = "tgt"
																						},
																						{
																							const = 10
																						},
																						{
																							const = 4
																						},
																						{
																							const = BaseEnum.SpeedRateType.Mid
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

return ST_Monster_AutoCombat_Egg_10451
