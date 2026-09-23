-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\_Monster\\ST_Monster_AutoCombat_Boss_10143_BossRush.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local ST_Monster_AutoCombat_Boss_10143_BossRush = {
	behavior = {
		useForRoute = false,
		version = 123,
		agenttype = "PuppetAgent",
		name = "ParmonBehaviorTree/SubTree/_Monster/ST_Monster_AutoCombat_Boss_10143_BossRush",
		properties = {},
		pars = {
			{
				type = "float",
				name = "disToTgtForSkillMon",
				const = 0,
				value = "0"
			},
			{
				type = "float",
				name = "goBackDist",
				const = 0,
				value = "0"
			},
			{
				type = "int",
				name = "tPlayer",
				const = 0,
				value = "0"
			},
			{
				type = "int",
				name = "shuimushanbi",
				const = 0,
				value = "0"
			}
		},
		attachments = {},
		node = {
			id = "133",
			class = "Sequence",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						id = "864",
						class = "Action",
						properties = {
							{
								Method = {
									func = "castSkill",
									params = {
										{
											field = "selfId"
										},
										{
											const = 11430104
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
						id = "1180",
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
						id = "1179",
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
						id = "1178",
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
						id = "1637",
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
						id = "1662",
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
						id = "1664",
						class = "Assignment",
						properties = {
							{
								CastRight = "false"
							},
							{
								Opl = {
									field = "tPlayer"
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
						id = "131",
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
									id = "1597",
									class = "Selector",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "1655",
												class = "IfElse",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "1657",
															class = "And",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		id = "1656",
																		class = "Condition",
																		properties = {
																			{
																				Operator = "GreaterEqual"
																			},
																			{
																				Opl = {
																					func = "getDistByPos",
																					params = {
																						{
																							field = "bornPos"
																						},
																						{
																							const = false
																						},
																						{
																							field = "selfId"
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
																},
																{
																	node = {
																		id = "1658",
																		class = "Condition",
																		properties = {
																			{
																				Operator = "GreaterEqual"
																			},
																			{
																				Opl = {
																					func = "getDistByPos",
																					params = {
																						{
																							field = "bornPos"
																						},
																						{
																							const = false
																						},
																						{
																							field = "selfId"
																						}
																					}
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
																							const = false
																						},
																						{
																							field = "tPlayer"
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
															id = "1659",
															class = "Action",
															properties = {
																{
																	Method = {
																		func = "castSkill",
																		params = {
																			{
																				field = "tPlayer"
																			},
																			{
																				const = 11430109
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
															attachments = {},
															children = {}
														}
													},
													{
														node = {
															id = "1665",
															class = "DecoratorAlwaysFailure",
															properties = {
																{
																	DecorateWhenChildEnds = "false"
																}
															},
															attachments = {},
															children = {
																{
																	node = {
																		id = "1660",
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
												id = "1919",
												class = "IfElse",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "1917",
															class = "And",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		id = "1913",
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
																							const = 4000002
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
																		id = "1914",
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
															id = "1915",
															class = "Sequence",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		id = "1916",
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
																		id = "1920",
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
																							const = 11430107
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
															id = "1880",
															class = "IfElse",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		id = "1884",
																		class = "And",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					id = "1879",
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
																										const = 4000002
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
																					id = "1881",
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
																		id = "1882",
																		class = "Sequence",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					id = "138",
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
																					id = "1883",
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
																					id = "1898",
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
																										const = 11430105
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
																					attachments = {},
																					children = {}
																				}
																			},
																			{
																				node = {
																					id = "1903",
																					class = "Sequence",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								id = "1902",
																								class = "Condition",
																								properties = {
																									{
																										Operator = "Less"
																									},
																									{
																										Opl = {
																											func = "getEntityCacheValue",
																											params = {
																												{
																													const = "BulblyDeath"
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
																								id = "1901",
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
																						}
																					}
																				}
																			},
																			{
																				node = {
																					id = "1928",
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
																										const = 11430107
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
																		id = "1896",
																		class = "IfElse",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					id = "1891",
																					class = "And",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								id = "1878",
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
																													const = 4000002
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
																						},
																						{
																							node = {
																								id = "1892",
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
																					id = "1895",
																					class = "Sequence",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								id = "1930",
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
																								id = "1894",
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
																													const = 3
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
																								id = "1929",
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
																													const = 11430108
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
																					id = "1897",
																					class = "IfElse",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								id = "1885",
																								class = "And",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											id = "1893",
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
																																const = 4000002
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
																											id = "1889",
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
																														const = 3
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
																								id = "1886",
																								class = "Sequence",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											id = "1888",
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
																																const = 4
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
																											id = "1900",
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
																																const = 114301051
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
																											attachments = {},
																											children = {}
																										}
																									},
																									{
																										node = {
																											id = "1909",
																											class = "Sequence",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "1908",
																														class = "Condition",
																														properties = {
																															{
																																Operator = "Less"
																															},
																															{
																																Opl = {
																																	func = "getEntityCacheValue",
																																	params = {
																																		{
																																			const = "BulblyDeath"
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
																														id = "1907",
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
																												}
																											}
																										}
																									}
																								}
																							}
																						},
																						{
																							node = {
																								id = "1935",
																								class = "Sequence",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											id = "873",
																											class = "Selector",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "149",
																														class = "Sequence",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	id = "143",
																																	class = "Condition",
																																	properties = {
																																		{
																																			Operator = "Less"
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
																																	id = "156",
																																	class = "Sequence",
																																	properties = {},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				id = "166",
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
																																				id = "167",
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
																																				id = "172",
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
																																				id = "1115",
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
																																				id = "1170",
																																				class = "Selector",
																																				properties = {},
																																				attachments = {},
																																				children = {
																																					{
																																						node = {
																																							id = "1173",
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
																																										id = "1172",
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
																																													id = "1184",
																																													class = "Sequence",
																																													properties = {},
																																													attachments = {},
																																													children = {
																																														{
																																															node = {
																																																id = "1012",
																																																class = "IfElse",
																																																properties = {},
																																																attachments = {},
																																																children = {
																																																	{
																																																		node = {
																																																			id = "1013",
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
																																																			id = "1039",
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
																																																						id = "1040",
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
																																																									id = "1030",
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
																																																														const = 11430201
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
																																																						id = "1753",
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
																																																									id = "1759",
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
																																																														const = 11430112
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
																																																						id = "1987",
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
																																																									id = "1988",
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
																																																														const = 11430101
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
																																																						id = "1290",
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
																																																									id = "1291",
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
																																																														const = 3
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
																																																	},
																																																	{
																																																		node = {
																																																			id = "1019",
																																																			class = "IfElse",
																																																			properties = {},
																																																			attachments = {},
																																																			children = {
																																																				{
																																																					node = {
																																																						id = "1021",
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
																																																						id = "1020",
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
																																																									id = "1767",
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
																																																												id = "1766",
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
																																																																	const = 11430112
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
																																																									id = "1769",
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
																																																												id = "1768",
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
																																																																	const = 11430201
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
																																																									id = "1774",
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
																																																												id = "1775",
																																																												class = "Sequence",
																																																												properties = {},
																																																												attachments = {},
																																																												children = {
																																																													{
																																																														node = {
																																																															id = "1773",
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
																																																																				const = 3
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
																																																													},
																																																													{
																																																														node = {
																																																															id = "1772",
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
																																																																				const = -1
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
																																																													}
																																																												}
																																																											}
																																																										}
																																																									}
																																																								}
																																																							},
																																																							{
																																																								node = {
																																																									id = "1989",
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
																																																												id = "1990",
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
																																																																	const = 11430101
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
																																																				},
																																																				{
																																																					node = {
																																																						id = "1017",
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
																																																									id = "1786",
																																																									class = "DecoratorWeight",
																																																									properties = {
																																																										{
																																																											DecorateWhenChildEnds = "false"
																																																										},
																																																										{
																																																											Weight = {
																																																												const = 5
																																																											}
																																																										}
																																																									},
																																																									attachments = {},
																																																									children = {
																																																										{
																																																											node = {
																																																												id = "1788",
																																																												class = "Sequence",
																																																												properties = {},
																																																												attachments = {},
																																																												children = {
																																																													{
																																																														node = {
																																																															id = "1787",
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
																																																																				const = 11430401
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
																																																																	ResultResumeOption = "BT_ResumeTree"
																																																																}
																																																															},
																																																															attachments = {},
																																																															children = {}
																																																														}
																																																													},
																																																													{
																																																														node = {
																																																															id = "1789",
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
																																																									id = "1777",
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
																																																												id = "1776",
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
																																																																	const = 11430112
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
																																																									id = "1785",
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
																																																												id = "1784",
																																																												class = "Sequence",
																																																												properties = {},
																																																												attachments = {},
																																																												children = {
																																																													{
																																																														node = {
																																																															id = "1783",
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
																																																																				const = 3
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
																																																													},
																																																													{
																																																														node = {
																																																															id = "1782",
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
																																																																				const = -1
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
																																																id = "1191",
																																																class = "IfElse",
																																																properties = {},
																																																attachments = {},
																																																children = {
																																																	{
																																																		node = {
																																																			id = "1192",
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
																																																			id = "1189",
																																																			class = "Sequence",
																																																			properties = {},
																																																			attachments = {},
																																																			children = {
																																																				{
																																																					node = {
																																																						id = "1187",
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
																																																						id = "1186",
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
																																																			id = "1188",
																																																			class = "Sequence",
																																																			properties = {},
																																																			attachments = {},
																																																			children = {
																																																				{
																																																					node = {
																																																						id = "1185",
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
																																																						id = "1702",
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
																																														}
																																													}
																																												}
																																											}
																																										}
																																									}
																																								},
																																								{
																																									node = {
																																										id = "1171",
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
																																													id = "1174",
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
																																							id = "1141",
																																							class = "Sequence",
																																							properties = {},
																																							attachments = {},
																																							children = {
																																								{
																																									node = {
																																										id = "1149",
																																										class = "IfElse",
																																										properties = {},
																																										attachments = {},
																																										children = {
																																											{
																																												node = {
																																													id = "1148",
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
																																													id = "1147",
																																													class = "Sequence",
																																													properties = {},
																																													attachments = {},
																																													children = {
																																														{
																																															node = {
																																																id = "1146",
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
																																																			const = 175
																																																		}
																																																	}
																																																},
																																																attachments = {},
																																																children = {}
																																															}
																																														},
																																														{
																																															node = {
																																																id = "1145",
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
																																											},
																																											{
																																												node = {
																																													id = "1144",
																																													class = "Sequence",
																																													properties = {},
																																													attachments = {},
																																													children = {
																																														{
																																															node = {
																																																id = "1143",
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
																																																			const = 150
																																																		}
																																																	}
																																																},
																																																attachments = {},
																																																children = {}
																																															}
																																														},
																																														{
																																															node = {
																																																id = "1142",
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
																																								},
																																								{
																																									node = {
																																										id = "1137",
																																										class = "Selector",
																																										properties = {},
																																										attachments = {},
																																										children = {
																																											{
																																												node = {
																																													id = "1138",
																																													class = "Sequence",
																																													properties = {},
																																													attachments = {},
																																													children = {
																																														{
																																															node = {
																																																id = "1134",
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
																																																id = "1136",
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
																																																id = "1139",
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
																																																id = "1169",
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
																																																id = "1132",
																																																class = "Selector",
																																																properties = {},
																																																attachments = {},
																																																children = {
																																																	{
																																																		node = {
																																																			id = "1140",
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
																																																			id = "1130",
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
																																													id = "1129",
																																													class = "Selector",
																																													properties = {},
																																													attachments = {},
																																													children = {
																																														{
																																															node = {
																																																id = "1128",
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
																																																			id = "1124",
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
																																																						id = "1125",
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
																																																			id = "1122",
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
																																																						id = "1123",
																																																						class = "Sequence",
																																																						properties = {},
																																																						attachments = {},
																																																						children = {
																																																							{
																																																								node = {
																																																									id = "1121",
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
																																																														const = "Skill_Halo"
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
																																																									id = "1120",
																																																									class = "Selector",
																																																									properties = {},
																																																									attachments = {},
																																																									children = {
																																																										{
																																																											node = {
																																																												id = "1150",
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
																																																																	const = "Skill_Halo"
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
																																																												id = "1151",
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
																																																																	const = "Skill_Halo"
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
																																																									id = "1152",
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
																																																														const = 0.8
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
																																																									id = "1153",
																																																									class = "Action",
																																																									properties = {
																																																										{
																																																											Method = {
																																																												func = "playAction",
																																																												params = {
																																																													{
																																																														const = "Skill_Halo"
																																																													},
																																																													{
																																																														const = -1
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
																																																									id = "1154",
																																																									class = "Action",
																																																									properties = {
																																																										{
																																																											Method = {
																																																												func = "startTimer",
																																																												params = {
																																																													{
																																																														const = "Skill_Halo"
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
																																														},
																																														{
																																															node = {
																																																id = "1157",
																																																class = "IfElse",
																																																properties = {},
																																																attachments = {},
																																																children = {
																																																	{
																																																		node = {
																																																			id = "1158",
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
																																																			id = "1163",
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
																																																						id = "1165",
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
																																																			id = "1167",
																																																			class = "Selector",
																																																			properties = {},
																																																			attachments = {},
																																																			children = {
																																																				{
																																																					node = {
																																																						id = "1155",
																																																						class = "Sequence",
																																																						properties = {},
																																																						attachments = {},
																																																						children = {
																																																							{
																																																								node = {
																																																									id = "1119",
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
																																																									id = "1127",
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
																																																												field = "minKeepBoxDist"
																																																											}
																																																										}
																																																									},
																																																									attachments = {},
																																																									children = {}
																																																								}
																																																							},
																																																							{
																																																								node = {
																																																									id = "1166",
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
																																																												field = "bestKeepBoxDist"
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
																																																									id = "1126",
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
																																																														field = "goBackDist"
																																																													},
																																																													{
																																																														const = 1.5
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
																																																						id = "1168",
																																																						class = "Action",
																																																						properties = {
																																																							{
																																																								Method = {
																																																									func = "playAction",
																																																									params = {
																																																										{
																																																											const = "Skill_Halo"
																																																										},
																																																										{
																																																											const = -1
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
																																										id = "1955",
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
																														id = "1354",
																														class = "Sequence",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	id = "1364",
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
																																	id = "1356",
																																	class = "Sequence",
																																	properties = {},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				id = "1357",
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
																																				id = "1358",
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
																																				id = "1359",
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
																																				id = "1360",
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
																																				id = "1353",
																																				class = "Selector",
																																				properties = {},
																																				attachments = {},
																																				children = {
																																					{
																																						node = {
																																							id = "1418",
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
																																										id = "1417",
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
																																													id = "1421",
																																													class = "Sequence",
																																													properties = {},
																																													attachments = {},
																																													children = {
																																														{
																																															node = {
																																																id = "1422",
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
																																																					const = "enterCombat"
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
																																																id = "1423",
																																																class = "Sequence",
																																																properties = {},
																																																attachments = {},
																																																children = {
																																																	{
																																																		node = {
																																																			id = "1397",
																																																			class = "Sequence",
																																																			properties = {},
																																																			attachments = {},
																																																			children = {
																																																				{
																																																					node = {
																																																						id = "1378",
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
																																																											const = 2114303
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
																																																						id = "1377",
																																																						class = "IfElse",
																																																						properties = {},
																																																						attachments = {},
																																																						children = {
																																																							{
																																																								node = {
																																																									id = "1395",
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
																																																									id = "1800",
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
																																																												id = "1791",
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
																																																															id = "1790",
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
																																																																				const = 11430101
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
																																																												id = "1798",
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
																																																															id = "1799",
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
																																																																				const = 11430301
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
																																																												id = "1797",
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
																																																															id = "1796",
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
																																																																				const = 11430114
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
																																																												id = "1794",
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
																																																															id = "1795",
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
																																																																				const = 11430111
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
																																																												id = "1793",
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
																																																															id = "1792",
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
																																																																				const = 11430202
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
																																																							},
																																																							{
																																																								node = {
																																																									id = "1385",
																																																									class = "IfElse",
																																																									properties = {},
																																																									attachments = {},
																																																									children = {
																																																										{
																																																											node = {
																																																												id = "1384",
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
																																																												id = "1813",
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
																																																															id = "1802",
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
																																																																		id = "1801",
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
																																																																							const = 11430101
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
																																																															id = "1809",
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
																																																																		id = "1810",
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
																																																																							const = 11430301
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
																																																															id = "1808",
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
																																																																		id = "1807",
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
																																																																							const = 11430114
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
																																																															id = "1804",
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
																																																																		id = "1803",
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
																																																																							const = 11430202
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
																																																															id = "1805",
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
																																																																		id = "1806",
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
																																																																							const = 11430111
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
																																																															id = "1812",
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
																																																																		id = "1811",
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
																																																																							const = 11430102
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
																																																										},
																																																										{
																																																											node = {
																																																												id = "1814",
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
																																																															id = "1831",
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
																																																																		id = "1830",
																																																																		class = "Sequence",
																																																																		properties = {},
																																																																		attachments = {},
																																																																		children = {
																																																																			{
																																																																				node = {
																																																																					id = "1815",
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
																																																																										const = 11430401
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
																																																																							ResultResumeOption = "BT_ResumeTree"
																																																																						}
																																																																					},
																																																																					attachments = {},
																																																																					children = {}
																																																																				}
																																																																			},
																																																																			{
																																																																				node = {
																																																																					id = "1832",
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
																																																															id = "1827",
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
																																																																		id = "1826",
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
																																																																							const = 11430101
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
																																																															id = "1822",
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
																																																																		id = "1823",
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
																																																																							const = 11430301
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
																																																															id = "1821",
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
																																																																		id = "1820",
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
																																																																							const = 11430114
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
																																																															id = "1817",
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
																																																																		id = "1816",
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
																																																																							const = 11430202
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
																																																															id = "1818",
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
																																																																		id = "1819",
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
																																																																							const = 11430111
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
																																																															id = "1825",
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
																																																																		id = "1824",
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
																																																																							const = 11430102
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
																																																					}
																																																				}
																																																			}
																																																		}
																																																	},
																																																	{
																																																		node = {
																																																			id = "1429",
																																																			class = "IfElse",
																																																			properties = {},
																																																			attachments = {},
																																																			children = {
																																																				{
																																																					node = {
																																																						id = "1430",
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
																																																						id = "1427",
																																																						class = "Sequence",
																																																						properties = {},
																																																						attachments = {},
																																																						children = {
																																																							{
																																																								node = {
																																																									id = "1425",
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
																																																									id = "1424",
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
																																																						id = "1426",
																																																						class = "Sequence",
																																																						properties = {},
																																																						attachments = {},
																																																						children = {
																																																							{
																																																								node = {
																																																									id = "1420",
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
																																																									id = "1428",
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
																																										id = "1416",
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
																																													id = "1419",
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
																																							id = "1313",
																																							class = "Sequence",
																																							properties = {},
																																							attachments = {},
																																							children = {
																																								{
																																									node = {
																																										id = "1320",
																																										class = "IfElse",
																																										properties = {},
																																										attachments = {},
																																										children = {
																																											{
																																												node = {
																																													id = "1322",
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
																																													id = "1319",
																																													class = "Sequence",
																																													properties = {},
																																													attachments = {},
																																													children = {
																																														{
																																															node = {
																																																id = "1318",
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
																																																			const = 175
																																																		}
																																																	}
																																																},
																																																attachments = {},
																																																children = {}
																																															}
																																														},
																																														{
																																															node = {
																																																id = "1317",
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
																																											},
																																											{
																																												node = {
																																													id = "1316",
																																													class = "Sequence",
																																													properties = {},
																																													attachments = {},
																																													children = {
																																														{
																																															node = {
																																																id = "1315",
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
																																																			const = 150
																																																		}
																																																	}
																																																},
																																																attachments = {},
																																																children = {}
																																															}
																																														},
																																														{
																																															node = {
																																																id = "1314",
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
																																								},
																																								{
																																									node = {
																																										id = "1309",
																																										class = "Selector",
																																										properties = {},
																																										attachments = {},
																																										children = {
																																											{
																																												node = {
																																													id = "1310",
																																													class = "Sequence",
																																													properties = {},
																																													attachments = {},
																																													children = {
																																														{
																																															node = {
																																																id = "1306",
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
																																																id = "1308",
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
																																																id = "1311",
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
																																																id = "1321",
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
																																																id = "1304",
																																																class = "Selector",
																																																properties = {},
																																																attachments = {},
																																																children = {
																																																	{
																																																		node = {
																																																			id = "1307",
																																																			class = "Sequence",
																																																			properties = {},
																																																			attachments = {},
																																																			children = {
																																																				{
																																																					node = {
																																																						id = "1312",
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
																																																			id = "1305",
																																																			class = "Sequence",
																																																			properties = {},
																																																			attachments = {},
																																																			children = {
																																																				{
																																																					node = {
																																																						id = "1302",
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
																																														}
																																													}
																																												}
																																											},
																																											{
																																												node = {
																																													id = "1330",
																																													class = "Selector",
																																													properties = {},
																																													attachments = {},
																																													children = {
																																														{
																																															node = {
																																																id = "1329",
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
																																																			id = "1327",
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
																																																						id = "1328",
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
																																																			id = "1325",
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
																																																						id = "1326",
																																																						class = "Sequence",
																																																						properties = {},
																																																						attachments = {},
																																																						children = {
																																																							{
																																																								node = {
																																																									id = "1324",
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
																																																														const = "Skill_Halo"
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
																																																									id = "1323",
																																																									class = "Selector",
																																																									properties = {},
																																																									attachments = {},
																																																									children = {
																																																										{
																																																											node = {
																																																												id = "1331",
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
																																																																	const = "Skill_Halo"
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
																																																												id = "1332",
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
																																																																	const = "Skill_Halo"
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
																																																									id = "1333",
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
																																																														const = 0.8
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
																																																									id = "1335",
																																																									class = "Action",
																																																									properties = {
																																																										{
																																																											Method = {
																																																												func = "playAction",
																																																												params = {
																																																													{
																																																														const = "Skill_Halo"
																																																													},
																																																													{
																																																														const = -1
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
																																																									id = "1334",
																																																									class = "Action",
																																																									properties = {
																																																										{
																																																											Method = {
																																																												func = "startTimer",
																																																												params = {
																																																													{
																																																														const = "Skill_Halo"
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
																																														},
																																														{
																																															node = {
																																																id = "1341",
																																																class = "IfElse",
																																																properties = {},
																																																attachments = {},
																																																children = {
																																																	{
																																																		node = {
																																																			id = "1342",
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
																																																			id = "1347",
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
																																																						id = "1349",
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
																																																			id = "1351",
																																																			class = "Selector",
																																																			properties = {},
																																																			attachments = {},
																																																			children = {
																																																				{
																																																					node = {
																																																						id = "1339",
																																																						class = "Sequence",
																																																						properties = {},
																																																						attachments = {},
																																																						children = {
																																																							{
																																																								node = {
																																																									id = "1336",
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
																																																									id = "1338",
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
																																																												field = "minKeepBoxDist"
																																																											}
																																																										}
																																																									},
																																																									attachments = {},
																																																									children = {}
																																																								}
																																																							},
																																																							{
																																																								node = {
																																																									id = "1350",
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
																																																												field = "bestKeepBoxDist"
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
																																																									id = "1337",
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
																																																														field = "goBackDist"
																																																													},
																																																													{
																																																														const = 1.5
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
																																																						id = "1352",
																																																						class = "Action",
																																																						properties = {
																																																							{
																																																								Method = {
																																																									func = "playAction",
																																																									params = {
																																																										{
																																																											const = "Skill_Halo"
																																																										},
																																																										{
																																																											const = -1
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
																																										id = "1953",
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
																												}
																											}
																										}
																									},
																									{
																										node = {
																											id = "1936",
																											class = "Sequence",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "1937",
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
																														id = "1938",
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
																														id = "1939",
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
																														id = "1941",
																														class = "IfElse",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	id = "1945",
																																	class = "And",
																																	properties = {},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				id = "1943",
																																				class = "Condition",
																																				properties = {
																																					{
																																						Operator = "GreaterEqual"
																																					},
																																					{
																																						Opl = {
																																							field = "shuimushanbi"
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
																																				id = "1944",
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
																																									const = 11430115
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
																																				id = "1948",
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
																																		}
																																	}
																																}
																															},
																															{
																																node = {
																																	id = "1942",
																																	class = "Sequence",
																																	properties = {},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				id = "1934",
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
																																									const = 11430115
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
																																						ResultResumeOption = "BT_ResumeTree"
																																					}
																																				},
																																				attachments = {},
																																				children = {}
																																			}
																																		},
																																		{
																																			node = {
																																				id = "1946",
																																				class = "Assignment",
																																				properties = {
																																					{
																																						CastRight = "false"
																																					},
																																					{
																																						Opl = {
																																							field = "shuimushanbi"
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
																																	id = "1947",
																																	class = "Compute",
																																	properties = {
																																		{
																																			Operator = "Add"
																																		},
																																		{
																																			Opl = {
																																				field = "shuimushanbi"
																																			}
																																		},
																																		{
																																			Opr1 = {
																																				field = "shuimushanbi"
																																			}
																																		},
																																		{
																																			Opr2 = {
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

return ST_Monster_AutoCombat_Boss_10143_BossRush
