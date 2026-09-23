-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\_Wild\\10141_Lighten\\PBT_Wild_10142_Perception_Leave.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Wild_10142_Perception_Leave = {
	behavior = {
		useForRoute = false,
		version = 10,
		agenttype = "PuppetAgent",
		name = "ParmonBehaviorTree/SubTree/_Wild/10141_Lighten/PBT_Wild_10142_Perception_Leave",
		properties = {},
		pars = {
			{
				name = "tSensorTgtId",
				const = 0,
				type = "int",
				value = "0"
			},
			{
				name = "tTgtId",
				const = 0,
				type = "int",
				value = "0"
			}
		},
		attachments = {},
		node = {
			id = "31",
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
									field = "tSensorTgtId"
								}
							},
							{
								Opr = {
									func = "getPerceptibilityTarget"
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
						class = "IfElse",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									id = "29",
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
									id = "3",
									class = "Sequence",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "4",
												class = "Action",
												properties = {
													{
														Method = {
															func = "turnToTarget",
															params = {
																{
																	field = "tSensorTgtId"
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
												id = "7",
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
															id = "8",
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
																		id = "13",
																		class = "Sequence",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					id = "37",
																					class = "Action",
																					properties = {
																						{
																							Method = {
																								func = "playEffectOnTarget",
																								params = {
																									{
																										const = "Eff_Parmon_10142_EscapeLight"
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
																					id = "2",
																					class = "Selector",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								id = "1",
																								class = "Action",
																								properties = {
																									{
																										Method = {
																											func = "leaveTarget",
																											params = {
																												{
																													field = "tSensorTgtId"
																												},
																												{
																													const = 35
																												},
																												{
																													const = 3.5
																												},
																												{
																													const = BaseEnum.SpeedRateType.Mid
																												},
																												{
																													const = 10
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
																										effector = true,
																										precondition = false,
																										id = "75",
																										class = "Effector",
																										properties = {
																											{
																												Operator = "Invalid"
																											},
																											{
																												Opl = {
																													func = "setAttenuationMultiple",
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
																												Phase = "Both"
																											}
																										}
																									}
																								},
																								children = {}
																							}
																						},
																						{
																							node = {
																								id = "5",
																								class = "Action",
																								properties = {
																									{
																										Method = {
																											func = "enterDestroySelf"
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
																					id = "0",
																					class = "Action",
																					properties = {
																						{
																							Method = {
																								func = "enterDestroySelf"
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
															id = "9",
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
																		id = "11",
																		class = "Sequence",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					id = "33",
																					class = "Action",
																					properties = {
																						{
																							Method = {
																								func = "addBuff",
																								params = {
																									{
																										const = 10072
																									},
																									{
																										const = 7
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
																					id = "12",
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
										}
									}
								}
							},
							{
								node = {
									id = "15",
									class = "Sequence",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "23",
												class = "Action",
												properties = {
													{
														Method = {
															func = "switchToGround"
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
												id = "21",
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
															id = "14",
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
																		id = "22",
																		class = "Sequence",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					id = "27",
																					class = "Action",
																					properties = {
																						{
																							Method = {
																								func = "playEffectOnTarget",
																								params = {
																									{
																										const = "Eff_Parmon_10142_EscapeLight"
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
																					id = "18",
																					class = "Selector",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								id = "19",
																								class = "Action",
																								properties = {
																									{
																										Method = {
																											func = "leaveTarget",
																											params = {
																												{
																													field = "tSensorTgtId"
																												},
																												{
																													const = 35
																												},
																												{
																													const = 3.5
																												},
																												{
																													const = BaseEnum.SpeedRateType.Mid
																												},
																												{
																													const = 10
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
																										effector = true,
																										precondition = false,
																										id = "75",
																										class = "Effector",
																										properties = {
																											{
																												Operator = "Invalid"
																											},
																											{
																												Opl = {
																													func = "setAttenuationMultiple",
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
																												Phase = "Both"
																											}
																										}
																									}
																								},
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
																											func = "enterDestroySelf"
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
																					id = "20",
																					class = "Action",
																					properties = {
																						{
																							Method = {
																								func = "enterDestroySelf"
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
																		id = "17",
																		class = "Sequence",
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
																								func = "addBuff",
																								params = {
																									{
																										const = 10072
																									},
																									{
																										const = 7
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
																					id = "26",
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
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
}

return PBT_Wild_10142_Perception_Leave
