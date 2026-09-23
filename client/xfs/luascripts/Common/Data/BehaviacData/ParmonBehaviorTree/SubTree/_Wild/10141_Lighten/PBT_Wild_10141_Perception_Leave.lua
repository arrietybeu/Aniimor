-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\_Wild\\10141_Lighten\\PBT_Wild_10141_Perception_Leave.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Wild_10141_Perception_Leave = {
	behavior = {
		useForRoute = false,
		agenttype = "PuppetAgent",
		name = "ParmonBehaviorTree/SubTree/_Wild/10141_Lighten/PBT_Wild_10141_Perception_Leave",
		version = 32,
		properties = {},
		pars = {
			{
				name = "tSensorTgtId",
				type = "int",
				value = "0",
				const = 0
			},
			{
				name = "tTgtId",
				type = "int",
				value = "0",
				const = 0
			}
		},
		attachments = {},
		node = {
			class = "Sequence",
			id = "84",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						class = "Sequence",
						id = "119",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									class = "Action",
									id = "121",
									properties = {
										{
											Method = {
												func = "setAttenuationMultiple",
												params = {
													{
														field = "selfId"
													},
													{
														const = 0.1
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
									class = "IfElse",
									id = "122",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												class = "Condition",
												id = "124",
												properties = {
													{
														Operator = "Equal"
													},
													{
														Opl = {
															field = "tSensorTgtId"
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
												id = "120",
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
												class = "True",
												id = "123",
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
						class = "IfElse",
						id = "83",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									class = "Condition",
									id = "82",
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
									class = "Sequence",
									id = "18",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												class = "Action",
												id = "19",
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
												class = "SelectorProbability",
												id = "47",
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
															id = "49",
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
																		class = "Sequence",
																		id = "73",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					class = "Action",
																					id = "115",
																					properties = {
																						{
																							Method = {
																								func = "playEffectOnTarget",
																								params = {
																									{
																										const = "Eff_Parmon_10141_EscapeLight"
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
																					class = "Selector",
																					id = "74",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								class = "Action",
																								id = "77",
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
																										class = "Effector",
																										transition = false,
																										effector = true,
																										precondition = false,
																										id = "75",
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
																								class = "Action",
																								id = "75",
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
																					class = "Action",
																					id = "76",
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
															class = "DecoratorWeight",
															id = "50",
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
																		class = "Sequence",
																		id = "68",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					class = "Action",
																					id = "118",
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
																							ResultResumeOption = "BT_ResumeTree"
																						}
																					},
																					attachments = {},
																					children = {}
																				}
																			},
																			{
																				node = {
																					class = "True",
																					id = "69",
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
									class = "Sequence",
									id = "89",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												class = "Action",
												id = "100",
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
												class = "SelectorProbability",
												id = "101",
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
															id = "112",
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
																		class = "Sequence",
																		id = "109",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					class = "Action",
																					id = "114",
																					properties = {
																						{
																							Method = {
																								func = "playEffectOnTarget",
																								params = {
																									{
																										const = "Eff_Parmon_10141_EscapeLight"
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
																					class = "Selector",
																					id = "105",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								class = "Action",
																								id = "104",
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
																										class = "Effector",
																										transition = false,
																										effector = true,
																										precondition = false,
																										id = "75",
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
																								class = "Action",
																								id = "106",
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
																					class = "Action",
																					id = "103",
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
															class = "DecoratorWeight",
															id = "107",
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
																		class = "Sequence",
																		id = "110",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					class = "Action",
																					id = "113",
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
																							ResultResumeOption = "BT_ResumeTree"
																						}
																					},
																					attachments = {},
																					children = {}
																				}
																			},
																			{
																				node = {
																					class = "True",
																					id = "108",
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

return PBT_Wild_10141_Perception_Leave
