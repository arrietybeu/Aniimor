-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\CombatUnit\\Monster\\Root\\Combat\\ST_Monster_AutoCombat_Test_10203_Threeday.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local ST_Monster_AutoCombat_Test_10203_Threeday = {
	behavior = {
		version = 84,
		useForRoute = false,
		name = "CombatUnit/Monster/Root/Combat/ST_Monster_AutoCombat_Test_10203_Threeday",
		agenttype = "PuppetAgent",
		properties = {},
		pars = {
			{
				name = "bubbleCount",
				type = "int",
				const = 0,
				value = "0"
			}
		},
		attachments = {},
		node = {
			id = "18",
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
						id = "19",
						class = "Sequence",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									id = "103",
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
									id = "21",
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
									id = "28",
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
									id = "29",
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
									id = "30",
									class = "Selector",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "156",
												class = "Sequence",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "157",
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
																				const = "enterCombat1"
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
															id = "159",
															class = "Action",
															properties = {
																{
																	Method = {
																		func = "startTimer",
																		params = {
																			{
																				const = "enterCombat1"
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
															id = "160",
															class = "Action",
															properties = {
																{
																	Method = {
																		func = "waitTime",
																		params = {
																			{
																				const = 1.5
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
															id = "158",
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
															id = "166",
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
																		id = "164",
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
																					id = "167",
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
																										const = 1
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
																		id = "162",
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
																					id = "169",
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
																		id = "163",
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
																					id = "170",
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
																		id = "165",
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
																					id = "168",
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
																										const = 2.5
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
																		id = "161",
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
																					id = "172",
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
																		id = "171",
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
																					id = "173",
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
																										const = 3.5
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
												id = "31",
												class = "Sequence",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "33",
															class = "Condition",
															properties = {
																{
																	Operator = "Greater"
																},
																{
																	Opl = {
																		field = "distToTgtForSkill"
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
															id = "4",
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
																				const = 14
																			},
																			{
																				const = 3
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
																				const = BaseEnum.MoveUpdateLevel.VeryFast
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
													}
												}
											}
										},
										{
											node = {
												id = "32",
												class = "Sequence",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "37",
															class = "Condition",
															properties = {
																{
																	Operator = "LessEqual"
																},
																{
																	Opl = {
																		field = "distToTgtForSkill"
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
															id = "190",
															class = "Condition",
															properties = {
																{
																	Operator = "Greater"
																},
																{
																	Opl = {
																		field = "distToTgtForSkill"
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
															id = "109",
															class = "Selector",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		id = "175",
																		class = "Sequence",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					id = "174",
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
																										const = 0.5
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
																					id = "110",
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
																										const = 12030321
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
																					id = "179",
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
																								id = "181",
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
																					id = "177",
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
																								id = "183",
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
																					id = "176",
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
																								id = "184",
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
																					id = "180",
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
																								id = "182",
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
																													const = 2.5
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
																					id = "178",
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
																								id = "186",
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
																					id = "185",
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
																								id = "187",
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
																													const = 3.5
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
										},
										{
											node = {
												id = "191",
												class = "Sequence",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "192",
															class = "Condition",
															properties = {
																{
																	Operator = "LessEqual"
																},
																{
																	Opl = {
																		field = "distToTgtForSkill"
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
																				const = 14
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
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
}

return ST_Monster_AutoCombat_Test_10203_Threeday
