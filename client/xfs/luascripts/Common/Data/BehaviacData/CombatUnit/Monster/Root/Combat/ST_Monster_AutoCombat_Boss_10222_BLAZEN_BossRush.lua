-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\CombatUnit\\Monster\\Root\\Combat\\ST_Monster_AutoCombat_Boss_10222_BLAZEN_BossRush.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local ST_Monster_AutoCombat_Boss_10222_BLAZEN_BossRush = {
	behavior = {
		useForRoute = false,
		name = "CombatUnit/Monster/Root/Combat/ST_Monster_AutoCombat_Boss_10222_BLAZEN_BossRush",
		agenttype = "PuppetAgent",
		version = 180,
		properties = {},
		pars = {
			{
				type = "float",
				const = 0,
				name = "disToTgtForSkillMon",
				value = "0"
			},
			{
				type = "float",
				const = 0,
				name = "goBackDist",
				value = "0"
			},
			{
				type = "int",
				const = 0,
				name = "Attack",
				value = "0"
			},
			{
				type = "int",
				const = 0,
				name = "ThunderSurge_12220101",
				value = "0"
			},
			{
				type = "int",
				const = 0,
				name = "ThunderClaw_12220601",
				value = "0"
			},
			{
				type = "int",
				const = 0,
				name = "ShadowBoltBackstab_12220511",
				value = "0"
			},
			{
				type = "int",
				const = 0,
				name = "Discharge_12220401",
				value = "0"
			},
			{
				type = "int",
				const = 0,
				name = "VoltStrike_12220111",
				value = "0"
			},
			{
				type = "int",
				const = 0,
				name = "FlashStrike_12220501",
				value = "0"
			},
			{
				type = "int",
				const = 0,
				name = "ThunderCross_12220701",
				value = "0"
			},
			{
				type = "int",
				const = 0,
				name = "EX",
				value = "0"
			},
			{
				type = "int",
				const = 0,
				name = "Relax",
				value = "0"
			},
			{
				type = "int",
				const = 0,
				name = "Combo",
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
						id = "281",
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
						id = "280",
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
						id = "1133",
						class = "Assignment",
						properties = {
							{
								CastRight = "false"
							},
							{
								Opl = {
									field = "maxKeepBoxDist"
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
						id = "1737",
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
						id = "1736",
						class = "Action",
						properties = {
							{
								Method = {
									func = "playSleAnimationOnce",
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
											const = ""
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
									id = "1722",
									class = "IfElse",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "1721",
												class = "And",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "1717",
															class = "Condition",
															properties = {
																{
																	Operator = "Greater"
																},
																{
																	Opl = {
																		func = "getTargetBuffLayerCount",
																		params = {
																			{
																				field = "selfId"
																			},
																			{
																				const = 4000003
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
															id = "1718",
															class = "Condition",
															properties = {
																{
																	Operator = "Equal"
																},
																{
																	Opl = {
																		func = "getEntityCacheValue",
																		params = {
																			{
																				const = "AI_BossStage"
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
													}
												}
											}
										},
										{
											node = {
												id = "1719",
												class = "Sequence",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "1720",
															class = "Action",
															properties = {
																{
																	Method = {
																		func = "setEntityCacheValue",
																		params = {
																			{
																				const = "AI_BossStage"
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
															id = "1500",
															class = "Sequence",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		id = "1314",
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
																							const = 12229910
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
																		id = "1317",
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
																							const = 12229914
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
																		id = "1451",
																		class = "Action",
																		properties = {
																			{
																				Method = {
																					func = "sendMessageToTrigger",
																					params = {
																						{
																							field = "selfId"
																						},
																						{
																							const = 1022201
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
												id = "1729",
												class = "IfElse",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "1728",
															class = "And",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		id = "1731",
																		class = "Condition",
																		properties = {
																			{
																				Operator = "Greater"
																			},
																			{
																				Opl = {
																					func = "getTargetBuffLayerCount",
																					params = {
																						{
																							field = "selfId"
																						},
																						{
																							const = 4000003
																						}
																					}
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
																		id = "1732",
																		class = "Condition",
																		properties = {
																			{
																				Operator = "Equal"
																			},
																			{
																				Opl = {
																					func = "getEntityCacheValue",
																					params = {
																						{
																							const = "AI_BossStage"
																						}
																					}
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
																}
															}
														}
													},
													{
														node = {
															id = "1726",
															class = "Sequence",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		id = "1727",
																		class = "Action",
																		properties = {
																			{
																				Method = {
																					func = "setEntityCacheValue",
																					params = {
																						{
																							const = "AI_BossStage"
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
																				ResultResumeOption = "BT_None"
																			}
																		},
																		attachments = {},
																		children = {}
																	}
																},
																{
																	node = {
																		id = "1730",
																		class = "Sequence",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					id = "1724",
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
																										const = 12229910
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
																					id = "1725",
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
																										const = 12229914
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
																					id = "1723",
																					class = "Action",
																					properties = {
																						{
																							Method = {
																								func = "sendMessageToTrigger",
																								params = {
																									{
																										field = "selfId"
																									},
																									{
																										const = 1022201
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
															id = "1506",
															class = "Sequence",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		id = "1493",
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
																		id = "1494",
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
																		id = "1492",
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
																							const = true
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
																		id = "1703",
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
																		id = "1617",
																		class = "IfElse",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					id = "1618",
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
																										const = 21222001
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
																					id = "1643",
																					class = "IfElse",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								id = "1641",
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
																								id = "1696",
																								class = "Sequence",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											id = "1619",
																											class = "IfElse",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "1620",
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
																																			const = 12220401
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
																														id = "1621",
																														class = "Assignment",
																														properties = {
																															{
																																CastRight = "false"
																															},
																															{
																																Opl = {
																																	field = "Discharge_12220401"
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
																														id = "1637",
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
																											id = "1650",
																											class = "IfElse",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "1626",
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
																																			const = 12220601
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
																														id = "1628",
																														class = "Assignment",
																														properties = {
																															{
																																CastRight = "false"
																															},
																															{
																																Opl = {
																																	field = "ThunderClaw_12220601"
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
																														id = "1627",
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
																											id = "1635",
																											class = "Assignment",
																											properties = {
																												{
																													CastRight = "false"
																												},
																												{
																													Opl = {
																														field = "Attack"
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
																											id = "1697",
																											class = "Compute",
																											properties = {
																												{
																													Operator = "Add"
																												},
																												{
																													Opl = {
																														field = "Combo"
																													}
																												},
																												{
																													Opr1 = {
																														field = "Combo"
																													}
																												},
																												{
																													Opr2 = {
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
																								id = "1661",
																								class = "Sequence",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											id = "1739",
																											class = "Compute",
																											properties = {
																												{
																													Operator = "Add"
																												},
																												{
																													Opl = {
																														field = "Combo"
																													}
																												},
																												{
																													Opr1 = {
																														field = "Combo"
																													}
																												},
																												{
																													Opr2 = {
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
																											id = "1662",
																											class = "Assignment",
																											properties = {
																												{
																													CastRight = "false"
																												},
																												{
																													Opl = {
																														field = "VoltStrike_12220111"
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
																											id = "1663",
																											class = "Assignment",
																											properties = {
																												{
																													CastRight = "false"
																												},
																												{
																													Opl = {
																														field = "FlashStrike_12220501"
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
																											id = "1738",
																											class = "Assignment",
																											properties = {
																												{
																													CastRight = "false"
																												},
																												{
																													Opl = {
																														field = "Attack"
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
																									}
																								}
																							}
																						}
																					}
																				}
																			},
																			{
																				node = {
																					id = "1545",
																					class = "Sequence",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								id = "1543",
																								class = "Assignment",
																								properties = {
																									{
																										CastRight = "false"
																									},
																									{
																										Opl = {
																											field = "Attack"
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
																								id = "1515",
																								class = "IfElse",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											id = "1520",
																											class = "And",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "1519",
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
																																	const = 6
																																}
																															}
																														},
																														attachments = {},
																														children = {}
																													}
																												},
																												{
																													node = {
																														id = "1517",
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
																																			const = 12220101
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
																											id = "1518",
																											class = "Assignment",
																											properties = {
																												{
																													CastRight = "false"
																												},
																												{
																													Opl = {
																														field = "ThunderSurge_12220101"
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
																											id = "1546",
																											class = "Assignment",
																											properties = {
																												{
																													CastRight = "false"
																												},
																												{
																													Opl = {
																														field = "ThunderSurge_12220101"
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
																								id = "1521",
																								class = "IfElse",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											id = "1522",
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
																																const = 12220601
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
																											id = "1524",
																											class = "Assignment",
																											properties = {
																												{
																													CastRight = "false"
																												},
																												{
																													Opl = {
																														field = "ThunderClaw_12220601"
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
																											id = "1523",
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
																								id = "1533",
																								class = "IfElse",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											id = "1585",
																											class = "And",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "1534",
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
																																	const = 20
																																}
																															}
																														},
																														attachments = {},
																														children = {}
																													}
																												},
																												{
																													node = {
																														id = "1586",
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
																																			const = 12220101
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
																											id = "1544",
																											class = "Assignment",
																											properties = {
																												{
																													CastRight = "false"
																												},
																												{
																													Opl = {
																														field = "ShadowBoltBackstab_12220511"
																													}
																												},
																												{
																													Opr = {
																														const = 500
																													}
																												}
																											},
																											attachments = {},
																											children = {}
																										}
																									},
																									{
																										node = {
																											id = "1531",
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
																			}
																		}
																	}
																},
																{
																	node = {
																		id = "1702",
																		class = "Sequence",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					id = "1587",
																					class = "IfElse",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								id = "1588",
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
																													const = 21222001
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
																								id = "745",
																								class = "IfElse",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											id = "1699",
																											class = "Condition",
																											properties = {
																												{
																													Operator = "Less"
																												},
																												{
																													Opl = {
																														field = "Combo"
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
																											id = "746",
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
																														id = "1592",
																														class = "DecoratorWeight",
																														properties = {
																															{
																																DecorateWhenChildEnds = "false"
																															},
																															{
																																Weight = {
																																	field = "Attack"
																																}
																															}
																														},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	id = "1589",
																																	class = "Sequence",
																																	properties = {},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				id = "1595",
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
																																									const = 4
																																								},
																																								{
																																									const = true
																																								},
																																								{
																																									const = 3
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
																																				id = "1591",
																																				class = "Assignment",
																																				properties = {
																																					{
																																						CastRight = "false"
																																					},
																																					{
																																						Opl = {
																																							field = "Attack"
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
																															}
																														}
																													}
																												},
																												{
																													node = {
																														id = "1602",
																														class = "DecoratorWeight",
																														properties = {
																															{
																																DecorateWhenChildEnds = "false"
																															},
																															{
																																Weight = {
																																	field = "ThunderClaw_12220601"
																																}
																															}
																														},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	id = "1601",
																																	class = "Sequence",
																																	properties = {},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				id = "1611",
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
																																									const = 12220601
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
																																				id = "1603",
																																				class = "Assignment",
																																				properties = {
																																					{
																																						CastRight = "false"
																																					},
																																					{
																																						Opl = {
																																							field = "ThunderClaw_12220601"
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
																															}
																														}
																													}
																												},
																												{
																													node = {
																														id = "768",
																														class = "DecoratorWeight",
																														properties = {
																															{
																																DecorateWhenChildEnds = "false"
																															},
																															{
																																Weight = {
																																	field = "Discharge_12220401"
																																}
																															}
																														},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	id = "777",
																																	class = "Sequence",
																																	properties = {},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				id = "776",
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
																																									const = 12220401
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
																																				id = "779",
																																				class = "Assignment",
																																				properties = {
																																					{
																																						CastRight = "false"
																																					},
																																					{
																																						Opl = {
																																							field = "Discharge_12220401"
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
																															}
																														}
																													}
																												},
																												{
																													node = {
																														id = "1740",
																														class = "DecoratorWeight",
																														properties = {
																															{
																																DecorateWhenChildEnds = "false"
																															},
																															{
																																Weight = {
																																	field = "Attack"
																																}
																															}
																														},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	id = "1741",
																																	class = "Sequence",
																																	properties = {},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				id = "1745",
																																				class = "IfElse",
																																				properties = {},
																																				attachments = {},
																																				children = {
																																					{
																																						node = {
																																							id = "1744",
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
																																							id = "1743",
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
																																												const = 4
																																											},
																																											{
																																												const = true
																																											},
																																											{
																																												const = 3
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
																																							id = "1746",
																																							class = "Sequence",
																																							properties = {},
																																							attachments = {},
																																							children = {
																																								{
																																									node = {
																																										id = "1747",
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
																																															const = 2.5
																																														},
																																														{
																																															const = 3.5
																																														},
																																														{
																																															const = true
																																														},
																																														{
																																															const = true
																																														},
																																														{
																																															const = true
																																														},
																																														{
																																															const = 8
																																														},
																																														{
																																															const = BaseEnum.MoveUpdateLevel.Slow
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
																																								},
																																								{
																																									node = {
																																										id = "1748",
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
																																															const = 4
																																														},
																																														{
																																															const = true
																																														},
																																														{
																																															const = 3
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
																																				id = "1742",
																																				class = "Assignment",
																																				properties = {
																																					{
																																						CastRight = "false"
																																					},
																																					{
																																						Opl = {
																																							field = "Attack"
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
																															}
																														}
																													}
																												}
																											}
																										}
																									},
																									{
																										node = {
																											id = "1296",
																											class = "Sequence",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "1700",
																														class = "Assignment",
																														properties = {
																															{
																																CastRight = "false"
																															},
																															{
																																Opl = {
																																	field = "Combo"
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
																														id = "1218",
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
																																	id = "1654",
																																	class = "DecoratorWeight",
																																	properties = {
																																		{
																																			DecorateWhenChildEnds = "false"
																																		},
																																		{
																																			Weight = {
																																				field = "FlashStrike_12220501"
																																			}
																																		}
																																	},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				id = "1660",
																																				class = "Sequence",
																																				properties = {},
																																				attachments = {},
																																				children = {
																																					{
																																						node = {
																																							id = "1219",
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
																																												const = 12220501
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
																																							id = "1668",
																																							class = "Sequence",
																																							properties = {},
																																							attachments = {},
																																							children = {
																																								{
																																									node = {
																																										id = "1664",
																																										class = "Assignment",
																																										properties = {
																																											{
																																												CastRight = "false"
																																											},
																																											{
																																												Opl = {
																																													field = "VoltStrike_12220111"
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
																																										id = "1665",
																																										class = "Assignment",
																																										properties = {
																																											{
																																												CastRight = "false"
																																											},
																																											{
																																												Opl = {
																																													field = "FlashStrike_12220501"
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
																																					}
																																				}
																																			}
																																		}
																																	}
																																}
																															},
																															{
																																node = {
																																	id = "1655",
																																	class = "DecoratorWeight",
																																	properties = {
																																		{
																																			DecorateWhenChildEnds = "false"
																																		},
																																		{
																																			Weight = {
																																				field = "VoltStrike_12220111"
																																			}
																																		}
																																	},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				id = "1669",
																																				class = "Sequence",
																																				properties = {},
																																				attachments = {},
																																				children = {
																																					{
																																						node = {
																																							id = "1220",
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
																																												const = 12220111
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
																																							id = "1670",
																																							class = "Sequence",
																																							properties = {},
																																							attachments = {},
																																							children = {
																																								{
																																									node = {
																																										id = "1666",
																																										class = "Assignment",
																																										properties = {
																																											{
																																												CastRight = "false"
																																											},
																																											{
																																												Opl = {
																																													field = "VoltStrike_12220111"
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
																																										id = "1667",
																																										class = "Assignment",
																																										properties = {
																																											{
																																												CastRight = "false"
																																											},
																																											{
																																												Opl = {
																																													field = "FlashStrike_12220501"
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
																														id = "1297",
																														class = "IfElse",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	id = "1298",
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
																																						const = 21222001
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
																																	id = "1227",
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
																																				id = "1681",
																																				class = "DecoratorWeight",
																																				properties = {
																																					{
																																						DecorateWhenChildEnds = "false"
																																					},
																																					{
																																						Weight = {
																																							field = "FlashStrike_12220501"
																																						}
																																					}
																																				},
																																				attachments = {},
																																				children = {
																																					{
																																						node = {
																																							id = "1676",
																																							class = "Sequence",
																																							properties = {},
																																							attachments = {},
																																							children = {
																																								{
																																									node = {
																																										id = "1672",
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
																																															const = 12220501
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
																																										id = "1677",
																																										class = "Sequence",
																																										properties = {},
																																										attachments = {},
																																										children = {
																																											{
																																												node = {
																																													id = "1673",
																																													class = "Assignment",
																																													properties = {
																																														{
																																															CastRight = "false"
																																														},
																																														{
																																															Opl = {
																																																field = "VoltStrike_12220111"
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
																																													id = "1675",
																																													class = "Assignment",
																																													properties = {
																																														{
																																															CastRight = "false"
																																														},
																																														{
																																															Opl = {
																																																field = "FlashStrike_12220501"
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
																																								}
																																							}
																																						}
																																					}
																																				}
																																			}
																																		},
																																		{
																																			node = {
																																				id = "1671",
																																				class = "DecoratorWeight",
																																				properties = {
																																					{
																																						DecorateWhenChildEnds = "false"
																																					},
																																					{
																																						Weight = {
																																							field = "VoltStrike_12220111"
																																						}
																																					}
																																				},
																																				attachments = {},
																																				children = {
																																					{
																																						node = {
																																							id = "1678",
																																							class = "Sequence",
																																							properties = {},
																																							attachments = {},
																																							children = {
																																								{
																																									node = {
																																										id = "1682",
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
																																															const = 12220111
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
																																										id = "1679",
																																										class = "Sequence",
																																										properties = {},
																																										attachments = {},
																																										children = {
																																											{
																																												node = {
																																													id = "1680",
																																													class = "Assignment",
																																													properties = {
																																														{
																																															CastRight = "false"
																																														},
																																														{
																																															Opl = {
																																																field = "VoltStrike_12220111"
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
																																													id = "1674",
																																													class = "Assignment",
																																													properties = {
																																														{
																																															CastRight = "false"
																																														},
																																														{
																																															Opl = {
																																																field = "FlashStrike_12220501"
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
																																	id = "1299",
																																	class = "False",
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
																														id = "1300",
																														class = "IfElse",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	id = "1302",
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
																																						const = 21222001
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
																																	id = "1240",
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
																																				id = "1693",
																																				class = "DecoratorWeight",
																																				properties = {
																																					{
																																						DecorateWhenChildEnds = "false"
																																					},
																																					{
																																						Weight = {
																																							field = "FlashStrike_12220501"
																																						}
																																					}
																																				},
																																				attachments = {},
																																				children = {
																																					{
																																						node = {
																																							id = "1688",
																																							class = "Sequence",
																																							properties = {},
																																							attachments = {},
																																							children = {
																																								{
																																									node = {
																																										id = "1684",
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
																																															const = 12220501
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
																																										id = "1689",
																																										class = "Sequence",
																																										properties = {},
																																										attachments = {},
																																										children = {
																																											{
																																												node = {
																																													id = "1685",
																																													class = "Assignment",
																																													properties = {
																																														{
																																															CastRight = "false"
																																														},
																																														{
																																															Opl = {
																																																field = "VoltStrike_12220111"
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
																																													id = "1687",
																																													class = "Assignment",
																																													properties = {
																																														{
																																															CastRight = "false"
																																														},
																																														{
																																															Opl = {
																																																field = "FlashStrike_12220501"
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
																																								}
																																							}
																																						}
																																					}
																																				}
																																			}
																																		},
																																		{
																																			node = {
																																				id = "1683",
																																				class = "DecoratorWeight",
																																				properties = {
																																					{
																																						DecorateWhenChildEnds = "false"
																																					},
																																					{
																																						Weight = {
																																							field = "VoltStrike_12220111"
																																						}
																																					}
																																				},
																																				attachments = {},
																																				children = {
																																					{
																																						node = {
																																							id = "1690",
																																							class = "Sequence",
																																							properties = {},
																																							attachments = {},
																																							children = {
																																								{
																																									node = {
																																										id = "1694",
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
																																															const = 12220111
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
																																										id = "1691",
																																										class = "Sequence",
																																										properties = {},
																																										attachments = {},
																																										children = {
																																											{
																																												node = {
																																													id = "1692",
																																													class = "Assignment",
																																													properties = {
																																														{
																																															CastRight = "false"
																																														},
																																														{
																																															Opl = {
																																																field = "VoltStrike_12220111"
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
																																													id = "1686",
																																													class = "Assignment",
																																													properties = {
																																														{
																																															CastRight = "false"
																																														},
																																														{
																																															Opl = {
																																																field = "FlashStrike_12220501"
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
																																	id = "1301",
																																	class = "False",
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
																														id = "1406",
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
																																			const = 12220701
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
																														id = "1712",
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
																														id = "1411",
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
																						},
																						{
																							node = {
																								id = "1561",
																								class = "SelectorProbability",
																								properties = {
																									{
																										UntilSuccessOrEnd = false
																									}
																								},
																								attachments = {
																									{
																										precondition = true,
																										transition = false,
																										id = "1707",
																										class = "Precondition",
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
																													func = "checkTargetHasBuffById",
																													params = {
																														{
																															field = "selfId"
																														},
																														{
																															const = 21222003
																														},
																														{
																															const = 1
																														}
																													}
																												}
																											},
																											{
																												Opr2 = {
																													const = false
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
																											id = "1549",
																											class = "DecoratorWeight",
																											properties = {
																												{
																													DecorateWhenChildEnds = "false"
																												},
																												{
																													Weight = {
																														field = "Attack"
																													}
																												}
																											},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "1551",
																														class = "Sequence",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	id = "1567",
																																	class = "IfElse",
																																	properties = {},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				id = "1566",
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
																																				id = "1553",
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
																																									const = 4
																																								},
																																								{
																																									const = true
																																								},
																																								{
																																									const = 3
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
																																				id = "1568",
																																				class = "Sequence",
																																				properties = {},
																																				attachments = {},
																																				children = {
																																					{
																																						node = {
																																							id = "1569",
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
																																												const = 2.5
																																											},
																																											{
																																												const = 3.5
																																											},
																																											{
																																												const = true
																																											},
																																											{
																																												const = true
																																											},
																																											{
																																												const = true
																																											},
																																											{
																																												const = 8
																																											},
																																											{
																																												const = BaseEnum.MoveUpdateLevel.Slow
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
																																					},
																																					{
																																						node = {
																																							id = "1571",
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
																																												const = 4
																																											},
																																											{
																																												const = true
																																											},
																																											{
																																												const = 3
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
																																	id = "1552",
																																	class = "Assignment",
																																	properties = {
																																		{
																																			CastRight = "false"
																																		},
																																		{
																																			Opl = {
																																				field = "Attack"
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
																												}
																											}
																										}
																									},
																									{
																										node = {
																											id = "1556",
																											class = "DecoratorWeight",
																											properties = {
																												{
																													DecorateWhenChildEnds = "false"
																												},
																												{
																													Weight = {
																														field = "ThunderClaw_12220601"
																													}
																												}
																											},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "1558",
																														class = "Sequence",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	id = "1577",
																																	class = "IfElse",
																																	properties = {},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				id = "1578",
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
																																				id = "1560",
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
																																									const = 12220601
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
																																				id = "1579",
																																				class = "Sequence",
																																				properties = {},
																																				attachments = {},
																																				children = {
																																					{
																																						node = {
																																							id = "1580",
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
																																												const = 2.5
																																											},
																																											{
																																												const = 3.5
																																											},
																																											{
																																												const = true
																																											},
																																											{
																																												const = true
																																											},
																																											{
																																												const = true
																																											},
																																											{
																																												const = 8
																																											},
																																											{
																																												const = BaseEnum.MoveUpdateLevel.Slow
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
																																					},
																																					{
																																						node = {
																																							id = "1584",
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
																																												const = 12220601
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
																																	id = "1559",
																																	class = "Assignment",
																																	properties = {
																																		{
																																			CastRight = "false"
																																		},
																																		{
																																			Opl = {
																																				field = "ThunderClaw_12220601"
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
																												}
																											}
																										}
																									},
																									{
																										node = {
																											id = "1550",
																											class = "DecoratorWeight",
																											properties = {
																												{
																													DecorateWhenChildEnds = "false"
																												},
																												{
																													Weight = {
																														field = "ThunderSurge_12220101"
																													}
																												}
																											},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "1554",
																														class = "Sequence",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	id = "1557",
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
																																						const = 12220101
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
																																	id = "1555",
																																	class = "Assignment",
																																	properties = {
																																		{
																																			CastRight = "false"
																																		},
																																		{
																																			Opl = {
																																				field = "ThunderSurge_12220101"
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
																												}
																											}
																										}
																									},
																									{
																										node = {
																											id = "1562",
																											class = "DecoratorWeight",
																											properties = {
																												{
																													DecorateWhenChildEnds = "false"
																												},
																												{
																													Weight = {
																														field = "ShadowBoltBackstab_12220511"
																													}
																												}
																											},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "1563",
																														class = "Sequence",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	id = "1565",
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
																																						const = 12220511
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
																																	id = "1564",
																																	class = "Assignment",
																																	properties = {
																																		{
																																			CastRight = "false"
																																		},
																																		{
																																			Opl = {
																																				field = "ShadowBoltBackstab_12220511"
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
																					id = "1701",
																					class = "Compute",
																					properties = {
																						{
																							Operator = "Add"
																						},
																						{
																							Opl = {
																								field = "Relax"
																							}
																						},
																						{
																							Opr1 = {
																								field = "Relax"
																							}
																						},
																						{
																							Opr2 = {
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
																		id = "1511",
																		class = "IfElse",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					id = "1512",
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
																										const = 21222003
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
																					id = "1513",
																					class = "Noop",
																					properties = {},
																					attachments = {},
																					children = {}
																				}
																			},
																			{
																				node = {
																					id = "1706",
																					class = "IfElse",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								id = "1705",
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
																													const = 21222001
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
																								id = "1704",
																								class = "Noop",
																								properties = {},
																								attachments = {},
																								children = {}
																							}
																						},
																						{
																							node = {
																								id = "1473",
																								class = "Sequence",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											id = "1507",
																											class = "Sequence",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "1454",
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
																														id = "1452",
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
																														id = "1463",
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
																																			const = true
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
																														id = "1464",
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
																																			const = true
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
																											id = "1480",
																											class = "IfElse",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "1476",
																														class = "Condition",
																														properties = {
																															{
																																Operator = "Greater"
																															},
																															{
																																Opl = {
																																	field = "Relax"
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
																														id = "1490",
																														class = "Sequence",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	id = "1477",
																																	class = "Assignment",
																																	properties = {
																																		{
																																			CastRight = "false"
																																		},
																																		{
																																			Opl = {
																																				field = "Relax"
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
																																	id = "1478",
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
																																						const = 3
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
																																	id = "1491",
																																	class = "Action",
																																	properties = {
																																		{
																																			Method = {
																																				func = "playSleAnimationOnce",
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
																																						const = ""
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
																												},
																												{
																													node = {
																														id = "1466",
																														class = "IfElse",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	id = "1481",
																																	class = "Condition",
																																	properties = {
																																		{
																																			Operator = "Greater"
																																		},
																																		{
																																			Opl = {
																																				field = "distToTgt"
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
																																	id = "1613",
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
																																						const = 2.5
																																					},
																																					{
																																						const = 3.5
																																					},
																																					{
																																						const = true
																																					},
																																					{
																																						const = true
																																					},
																																					{
																																						const = true
																																					},
																																					{
																																						const = 8
																																					},
																																					{
																																						const = BaseEnum.MoveUpdateLevel.Slow
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
																															},
																															{
																																node = {
																																	id = "1484",
																																	class = "Sequence",
																																	properties = {},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				id = "1467",
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
																																				id = "1469",
																																				class = "Selector",
																																				properties = {},
																																				attachments = {},
																																				children = {
																																					{
																																						node = {
																																							id = "1470",
																																							class = "Sequence",
																																							properties = {},
																																							attachments = {},
																																							children = {
																																								{
																																									node = {
																																										id = "1487",
																																										class = "And",
																																										properties = {},
																																										attachments = {},
																																										children = {
																																											{
																																												node = {
																																													id = "1468",
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
																																													id = "1471",
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
																																											}
																																										}
																																									}
																																								},
																																								{
																																									node = {
																																										id = "1453",
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
																																										id = "1474",
																																										class = "Selector",
																																										properties = {},
																																										attachments = {},
																																										children = {
																																											{
																																												node = {
																																													id = "1472",
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
																																													id = "1475",
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
																																																		const = 3
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
																																					},
																																					{
																																						node = {
																																							id = "1482",
																																							class = "Sequence",
																																							properties = {},
																																							attachments = {},
																																							children = {
																																								{
																																									node = {
																																										id = "1485",
																																										class = "And",
																																										properties = {},
																																										attachments = {},
																																										children = {
																																											{
																																												node = {
																																													id = "1483",
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
																																													id = "1486",
																																													class = "Condition",
																																													properties = {
																																														{
																																															Operator = "Greater"
																																														},
																																														{
																																															Opl = {
																																																field = "distToTgt"
																																															}
																																														},
																																														{
																																															Opr = {
																																																const = 6
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
																																										id = "1456",
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
																																													id = "1457",
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
																																																id = "1458",
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
																																																					const = 3
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
																																											},
																																											{
																																												node = {
																																													id = "1459",
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
																																																id = "1460",
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
																																																					const = 3
																																																				},
																																																				{
																																																					const = 35
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
																																					},
																																					{
																																						node = {
																																							id = "1462",
																																							class = "Sequence",
																																							properties = {},
																																							attachments = {},
																																							children = {
																																								{
																																									node = {
																																										id = "1509",
																																										class = "And",
																																										properties = {},
																																										attachments = {},
																																										children = {
																																											{
																																												node = {
																																													id = "1508",
																																													class = "Condition",
																																													properties = {
																																														{
																																															Operator = "Greater"
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
																																													id = "1461",
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
																																																const = 6
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
																																										id = "1455",
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
																																															const = 6
																																														},
																																														{
																																															const = 4
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

return ST_Monster_AutoCombat_Boss_10222_BLAZEN_BossRush
