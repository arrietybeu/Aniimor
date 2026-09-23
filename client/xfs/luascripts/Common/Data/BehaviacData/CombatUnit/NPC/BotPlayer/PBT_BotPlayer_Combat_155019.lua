-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\CombatUnit\\NPC\\BotPlayer\\PBT_BotPlayer_Combat_155019.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_BotPlayer_Combat_155019 = {
	behavior = {
		name = "CombatUnit/NPC/BotPlayer/PBT_BotPlayer_Combat_155019",
		useForRoute = false,
		version = 156,
		agenttype = "BotPlayerAgent",
		properties = {},
		pars = {
			{
				type = "int",
				value = "0",
				const = 0,
				name = "tCurrentPet"
			},
			{
				type = "float",
				value = "0",
				const = 0,
				name = "tCurrentPetHpPercent"
			},
			{
				type = "int",
				value = "0",
				const = 0,
				name = "tSwitchPetId"
			},
			{
				type = "int",
				value = "0",
				const = 0,
				name = "tTargetSkillId"
			},
			{
				type = "float",
				value = "0",
				const = 0,
				name = "tCurrentEp"
			}
		},
		attachments = {},
		node = {
			id = "1",
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
						id = "11",
						class = "Sequence",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									id = "5",
									class = "Sequence",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "124",
												class = "Assignment",
												properties = {
													{
														CastRight = "false"
													},
													{
														Opl = {
															field = "tCurrentPet"
														}
													},
													{
														Opr = {
															func = "getPetActorId",
															params = {
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
												id = "6",
												class = "Assignment",
												properties = {
													{
														CastRight = "false"
													},
													{
														Opl = {
															field = "tCurrentPetHpPercent"
														}
													},
													{
														Opr = {
															func = "getHpPercent",
															params = {
																{
																	field = "tCurrentPet"
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
												id = "12",
												class = "Assignment",
												properties = {
													{
														CastRight = "false"
													},
													{
														Opl = {
															field = "combatTactic"
														}
													},
													{
														Opr = {
															const = "common"
														}
													}
												},
												attachments = {},
												children = {}
											}
										},
										{
											node = {
												id = "115",
												class = "Assignment",
												properties = {
													{
														CastRight = "false"
													},
													{
														Opl = {
															field = "tCurrentEp"
														}
													},
													{
														Opr = {
															func = "getEp",
															params = {
																{
																	field = "selfId"
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
												id = "126",
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
										}
									}
								}
							},
							{
								node = {
									id = "4",
									class = "Selector",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "75",
												class = "Sequence",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "112",
															class = "And",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		id = "81",
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
																							field = "tgt"
																						},
																						{
																							const = 10003
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
																		id = "111",
																		class = "Condition",
																		properties = {
																			{
																				Operator = "NotEqual"
																			},
																			{
																				Opl = {
																					func = "getPetActorIdByFunctionIdFromPetList",
																					params = {
																						{
																							const = "DPS"
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
															id = "73",
															class = "Assignment",
															properties = {
																{
																	CastRight = "false"
																},
																{
																	Opl = {
																		field = "tSwitchPetId"
																	}
																},
																{
																	Opr = {
																		func = "getPetActorIdByFunctionIdFromPetList",
																		params = {
																			{
																				const = "DPS"
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
															id = "383",
															class = "Assignment",
															properties = {
																{
																	CastRight = "false"
																},
																{
																	Opl = {
																		field = "combatTactic"
																	}
																},
																{
																	Opr = {
																		const = "DPS"
																	}
																}
															},
															attachments = {},
															children = {}
														}
													},
													{
														node = {
															id = "279",
															class = "Action",
															properties = {
																{
																	Method = {
																		func = "switchPetByActorId",
																		params = {
																			{
																				field = "tSwitchPetId"
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
												id = "365",
												class = "Sequence",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "380",
															class = "Or",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		id = "366",
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
																							field = "tgt"
																						},
																						{
																							const = 2126302
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
																		id = "381",
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
																							field = "tgt"
																						},
																						{
																							const = 21233051
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
																}
															}
														}
													},
													{
														node = {
															id = "368",
															class = "Condition",
															properties = {
																{
																	Operator = "NotEqual"
																},
																{
																	Opl = {
																		func = "getPetActorIdByFunctionIdFromPetList",
																		params = {
																			{
																				const = "DPS"
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
															id = "364",
															class = "Assignment",
															properties = {
																{
																	CastRight = "false"
																},
																{
																	Opl = {
																		field = "tSwitchPetId"
																	}
																},
																{
																	Opr = {
																		func = "getPetActorIdByFunctionIdFromPetList",
																		params = {
																			{
																				const = "DPS"
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
															id = "375",
															class = "Condition",
															properties = {
																{
																	Operator = "Equal"
																},
																{
																	Opl = {
																		func = "checkSkillNotInCd",
																		params = {
																			{
																				const = 10530530
																			},
																			{
																				field = "tSwitchPetId"
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
															id = "382",
															class = "Assignment",
															properties = {
																{
																	CastRight = "false"
																},
																{
																	Opl = {
																		field = "combatTactic"
																	}
																},
																{
																	Opr = {
																		const = "SLEEP"
																	}
																}
															},
															attachments = {},
															children = {}
														}
													},
													{
														node = {
															id = "369",
															class = "Action",
															properties = {
																{
																	Method = {
																		func = "switchPetByActorId",
																		params = {
																			{
																				field = "tSwitchPetId"
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
												id = "7",
												class = "Sequence",
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
																		id = "8",
																		class = "Condition",
																		properties = {
																			{
																				Operator = "LessEqual"
																			},
																			{
																				Opl = {
																					field = "tCurrentPetHpPercent"
																				}
																			},
																			{
																				Opr = {
																					const = 0.6
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
																		class = "Condition",
																		properties = {
																			{
																				Operator = "NotEqual"
																			},
																			{
																				Opl = {
																					func = "getPetActorIdByFunctionIdFromPetList",
																					params = {
																						{
																							const = "HEAL"
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
															id = "16",
															class = "Assignment",
															properties = {
																{
																	CastRight = "false"
																},
																{
																	Opl = {
																		field = "tSwitchPetId"
																	}
																},
																{
																	Opr = {
																		func = "getPetActorIdByFunctionIdFromPetList",
																		params = {
																			{
																				const = "HEAL"
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
															id = "186",
															class = "Selector",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		id = "36",
																		class = "Condition",
																		properties = {
																			{
																				Operator = "Equal"
																			},
																			{
																				Opl = {
																					func = "checkSkillExistByFeatureId",
																					params = {
																						{
																							field = "tSwitchPetId"
																						},
																						{
																							const = 3
																						},
																						{
																							const = false
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
																		id = "187",
																		class = "Condition",
																		properties = {
																			{
																				Operator = "Equal"
																			},
																			{
																				Opl = {
																					func = "checkSkillExistByFeatureId",
																					params = {
																						{
																							field = "tSwitchPetId"
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
															id = "217",
															class = "Selector",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		id = "60",
																		class = "Sequence",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					id = "58",
																					class = "Assignment",
																					properties = {
																						{
																							CastRight = "false"
																						},
																						{
																							Opl = {
																								field = "tTargetSkillId"
																							}
																						},
																						{
																							Opr = {
																								func = "getSkillIdByFeature",
																								params = {
																									{
																										const = 3
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
																										field = "tSwitchPetId"
																									},
																									{
																										const = true
																									},
																									{
																										const = true
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
																					id = "227",
																					class = "Condition",
																					properties = {
																						{
																							Operator = "NotEqual"
																						},
																						{
																							Opl = {
																								field = "tTargetSkillId"
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
																		id = "220",
																		class = "Sequence",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					id = "218",
																					class = "Assignment",
																					properties = {
																						{
																							CastRight = "false"
																						},
																						{
																							Opl = {
																								field = "tTargetSkillId"
																							}
																						},
																						{
																							Opr = {
																								func = "getSkillIdByFeature",
																								params = {
																									{
																										const = 2
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
																										field = "tSwitchPetId"
																									},
																									{
																										const = true
																									},
																									{
																										const = true
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
																					id = "234",
																					class = "Condition",
																					properties = {
																						{
																							Operator = "NotEqual"
																						},
																						{
																							Opl = {
																								field = "tTargetSkillId"
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
															id = "222",
															class = "Sequence",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		id = "13",
																		class = "Assignment",
																		properties = {
																			{
																				CastRight = "false"
																			},
																			{
																				Opl = {
																					field = "combatTactic"
																				}
																			},
																			{
																				Opr = {
																					const = "Tactics_HEAL"
																				}
																			}
																		},
																		attachments = {},
																		children = {}
																	}
																},
																{
																	node = {
																		id = "251",
																		class = "DecoratorLoopUntil",
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
																				Until = "true"
																			}
																		},
																		attachments = {},
																		children = {
																			{
																				node = {
																					id = "320",
																					class = "Selector",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								id = "321",
																								class = "Condition",
																								properties = {
																									{
																										Operator = "Equal"
																									},
																									{
																										Opl = {
																											field = "tSwitchPetId"
																										}
																									},
																									{
																										Opr = {
																											field = "tCurrentPet"
																										}
																									}
																								},
																								attachments = {},
																								children = {}
																							}
																						},
																						{
																							node = {
																								id = "319",
																								class = "Sequence",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											id = "315",
																											class = "Action",
																											properties = {
																												{
																													Method = {
																														func = "waitTime",
																														params = {
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
																									},
																									{
																										node = {
																											id = "314",
																											class = "And",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "317",
																														class = "Condition",
																														properties = {
																															{
																																Operator = "Equal"
																															},
																															{
																																Opl = {
																																	func = "isInSkill",
																																	params = {
																																		{
																																			field = "tCurrentPet"
																																		},
																																		{
																																			const = 0
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
																														id = "316",
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
																																			field = "tCurrentPet"
																																		},
																																		{
																																			const = 10003
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
																									},
																									{
																										node = {
																											id = "318",
																											class = "Action",
																											properties = {
																												{
																													Method = {
																														func = "switchPetByActorId",
																														params = {
																															{
																																field = "tSwitchPetId"
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
											}
										},
										{
											node = {
												id = "94",
												class = "Sequence",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "88",
															class = "Sequence",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		id = "113",
																		class = "Condition",
																		properties = {
																			{
																				Operator = "LessEqual"
																			},
																			{
																				Opl = {
																					field = "tCurrentEp"
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
																		id = "90",
																		class = "Condition",
																		properties = {
																			{
																				Operator = "NotEqual"
																			},
																			{
																				Opl = {
																					func = "getPetActorIdByFunctionIdFromPetList",
																					params = {
																						{
																							const = "ENERGY"
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
															id = "172",
															class = "Sequence",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		id = "93",
																		class = "Assignment",
																		properties = {
																			{
																				CastRight = "false"
																			},
																			{
																				Opl = {
																					field = "tSwitchPetId"
																				}
																			},
																			{
																				Opr = {
																					func = "getPetActorIdByFunctionIdFromPetList",
																					params = {
																						{
																							const = "ENERGY"
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
																		id = "173",
																		class = "Condition",
																		properties = {
																			{
																				Operator = "NotEqual"
																			},
																			{
																				Opl = {
																					func = "getHpPercent",
																					params = {
																						{
																							field = "tSwitchPetId"
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
															id = "86",
															class = "Condition",
															properties = {
																{
																	Operator = "Equal"
																},
																{
																	Opl = {
																		func = "checkSkillExistByFeatureId",
																		params = {
																			{
																				field = "tSwitchPetId"
																			},
																			{
																				const = 5
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
													},
													{
														node = {
															id = "103",
															class = "Sequence",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		id = "102",
																		class = "Assignment",
																		properties = {
																			{
																				CastRight = "false"
																			},
																			{
																				Opl = {
																					field = "tTargetSkillId"
																				}
																			},
																			{
																				Opr = {
																					func = "getSkillIdByFeature",
																					params = {
																						{
																							const = 5
																						},
																						{
																							const = true
																						},
																						{
																							const = 0
																						},
																						{
																							const = false
																						},
																						{
																							field = "tSwitchPetId"
																						},
																						{
																							const = false
																						},
																						{
																							const = false
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
																		id = "228",
																		class = "Condition",
																		properties = {
																			{
																				Operator = "NotEqual"
																			},
																			{
																				Opl = {
																					field = "tTargetSkillId"
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
																		id = "101",
																		class = "Condition",
																		properties = {
																			{
																				Operator = "Equal"
																			},
																			{
																				Opl = {
																					func = "checkSkillNotInCd",
																					params = {
																						{
																							field = "tTargetSkillId"
																						},
																						{
																							field = "tSwitchPetId"
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
															id = "100",
															class = "Sequence",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		id = "95",
																		class = "Assignment",
																		properties = {
																			{
																				CastRight = "false"
																			},
																			{
																				Opl = {
																					field = "combatTactic"
																				}
																			},
																			{
																				Opr = {
																					const = "Tactics_ENERGY"
																				}
																			}
																		},
																		attachments = {},
																		children = {}
																	}
																},
																{
																	node = {
																		id = "256",
																		class = "DecoratorLoopUntil",
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
																				Until = "true"
																			}
																		},
																		attachments = {},
																		children = {
																			{
																				node = {
																					id = "328",
																					class = "Selector",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								id = "329",
																								class = "Condition",
																								properties = {
																									{
																										Operator = "Equal"
																									},
																									{
																										Opl = {
																											field = "tSwitchPetId"
																										}
																									},
																									{
																										Opr = {
																											field = "tCurrentPet"
																										}
																									}
																								},
																								attachments = {},
																								children = {}
																							}
																						},
																						{
																							node = {
																								id = "327",
																								class = "Sequence",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											id = "323",
																											class = "Action",
																											properties = {
																												{
																													Method = {
																														func = "waitTime",
																														params = {
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
																									},
																									{
																										node = {
																											id = "322",
																											class = "And",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "325",
																														class = "Condition",
																														properties = {
																															{
																																Operator = "Equal"
																															},
																															{
																																Opl = {
																																	func = "isInSkill",
																																	params = {
																																		{
																																			field = "tCurrentPet"
																																		},
																																		{
																																			const = 0
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
																														id = "324",
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
																																			field = "tCurrentPet"
																																		},
																																		{
																																			const = 10003
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
																									},
																									{
																										node = {
																											id = "326",
																											class = "Action",
																											properties = {
																												{
																													Method = {
																														func = "switchPetByActorId",
																														params = {
																															{
																																field = "tSwitchPetId"
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
											}
										},
										{
											node = {
												id = "118",
												class = "Sequence",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "122",
															class = "Condition",
															properties = {
																{
																	Operator = "NotEqual"
																},
																{
																	Opl = {
																		func = "getPetActorIdByFunctionIdFromPetList",
																		params = {
																			{
																				const = "SUP"
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
															id = "363",
															class = "Assignment",
															properties = {
																{
																	CastRight = "false"
																},
																{
																	Opl = {
																		field = "tSwitchPetId"
																	}
																},
																{
																	Opr = {
																		func = "getPetActorIdByFunctionIdFromPetList",
																		params = {
																			{
																				const = "SUP"
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
															id = "131",
															class = "IfElse",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		id = "127",
																		class = "Condition",
																		properties = {
																			{
																				Operator = "GreaterEqual"
																			},
																			{
																				Opl = {
																					func = "getHpPercent",
																					params = {
																						{
																							field = "tSwitchPetId"
																						}
																					}
																				}
																			},
																			{
																				Opr = {
																					const = 0.2
																				}
																			}
																		},
																		attachments = {},
																		children = {}
																	}
																},
																{
																	node = {
																		id = "266",
																		class = "DecoratorLoopUntil",
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
																				Until = "true"
																			}
																		},
																		attachments = {},
																		children = {
																			{
																				node = {
																					id = "344",
																					class = "Selector",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								id = "345",
																								class = "Condition",
																								properties = {
																									{
																										Operator = "Equal"
																									},
																									{
																										Opl = {
																											field = "tSwitchPetId"
																										}
																									},
																									{
																										Opr = {
																											field = "tCurrentPet"
																										}
																									}
																								},
																								attachments = {},
																								children = {}
																							}
																						},
																						{
																							node = {
																								id = "343",
																								class = "Sequence",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											id = "339",
																											class = "Action",
																											properties = {
																												{
																													Method = {
																														func = "waitTime",
																														params = {
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
																									},
																									{
																										node = {
																											id = "338",
																											class = "And",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "341",
																														class = "Condition",
																														properties = {
																															{
																																Operator = "Equal"
																															},
																															{
																																Opl = {
																																	func = "isInSkill",
																																	params = {
																																		{
																																			field = "tCurrentPet"
																																		},
																																		{
																																			const = 0
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
																														id = "340",
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
																																			field = "tCurrentPet"
																																		},
																																		{
																																			const = 10003
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
																									},
																									{
																										node = {
																											id = "342",
																											class = "Action",
																											properties = {
																												{
																													Method = {
																														func = "switchPetByActorId",
																														params = {
																															{
																																field = "tSwitchPetId"
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
																		id = "212",
																		class = "Selector",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					id = "210",
																					class = "Sequence",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								id = "191",
																								class = "Condition",
																								properties = {
																									{
																										Operator = "Equal"
																									},
																									{
																										Opl = {
																											func = "checkTargetIsFunctionId",
																											params = {
																												{
																													field = "tCurrentPet"
																												},
																												{
																													const = "HEAL"
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
																								id = "190",
																								class = "Condition",
																								properties = {
																									{
																										Operator = "NotEqual"
																									},
																									{
																										Opl = {
																											func = "getPetActorIdByFunctionIdFromPetList",
																											params = {
																												{
																													const = "HEAL"
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
																								id = "193",
																								class = "Assignment",
																								properties = {
																									{
																										CastRight = "false"
																									},
																									{
																										Opl = {
																											field = "tSwitchPetId"
																										}
																									},
																									{
																										Opr = {
																											func = "getPetActorIdByFunctionIdFromPetList",
																											params = {
																												{
																													const = "HEAL"
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
																								id = "208",
																								class = "Selector",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											id = "194",
																											class = "Condition",
																											properties = {
																												{
																													Operator = "Equal"
																												},
																												{
																													Opl = {
																														func = "checkSkillExistByFeatureId",
																														params = {
																															{
																																field = "tSwitchPetId"
																															},
																															{
																																const = 3
																															},
																															{
																																const = false
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
																											id = "209",
																											class = "Condition",
																											properties = {
																												{
																													Operator = "Equal"
																												},
																												{
																													Opl = {
																														func = "checkSkillExistByFeatureId",
																														params = {
																															{
																																field = "tSwitchPetId"
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
																								id = "301",
																								class = "Selector",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											id = "303",
																											class = "Condition",
																											properties = {
																												{
																													Operator = "NotEqual"
																												},
																												{
																													Opl = {
																														func = "getSkillIdByFeature",
																														params = {
																															{
																																const = 3
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
																																field = "tSwitchPetId"
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
																											id = "304",
																											class = "Condition",
																											properties = {
																												{
																													Operator = "NotEqual"
																												},
																												{
																													Opl = {
																														func = "getSkillIdByFeature",
																														params = {
																															{
																																const = 2
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
																																field = "tSwitchPetId"
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
																								id = "199",
																								class = "Sequence",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											id = "192",
																											class = "Assignment",
																											properties = {
																												{
																													CastRight = "false"
																												},
																												{
																													Opl = {
																														field = "combatTactic"
																													}
																												},
																												{
																													Opr = {
																														const = "Tactics_HEAL"
																													}
																												}
																											},
																											attachments = {},
																											children = {}
																										}
																									},
																									{
																										node = {
																											id = "276",
																											class = "DecoratorLoopUntil",
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
																													Until = "true"
																												}
																											},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "360",
																														class = "Selector",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	id = "361",
																																	class = "Condition",
																																	properties = {
																																		{
																																			Operator = "Equal"
																																		},
																																		{
																																			Opl = {
																																				field = "tSwitchPetId"
																																			}
																																		},
																																		{
																																			Opr = {
																																				field = "tCurrentPet"
																																			}
																																		}
																																	},
																																	attachments = {},
																																	children = {}
																																}
																															},
																															{
																																node = {
																																	id = "359",
																																	class = "Sequence",
																																	properties = {},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				id = "355",
																																				class = "Action",
																																				properties = {
																																					{
																																						Method = {
																																							func = "waitTime",
																																							params = {
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
																																		},
																																		{
																																			node = {
																																				id = "354",
																																				class = "And",
																																				properties = {},
																																				attachments = {},
																																				children = {
																																					{
																																						node = {
																																							id = "357",
																																							class = "Condition",
																																							properties = {
																																								{
																																									Operator = "Equal"
																																								},
																																								{
																																									Opl = {
																																										func = "isInSkill",
																																										params = {
																																											{
																																												field = "tCurrentPet"
																																											},
																																											{
																																												const = 0
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
																																							id = "356",
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
																																												field = "tCurrentPet"
																																											},
																																											{
																																												const = 10003
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
																																		},
																																		{
																																			node = {
																																				id = "358",
																																				class = "Action",
																																				properties = {
																																					{
																																						Method = {
																																							func = "switchPetByActorId",
																																							params = {
																																								{
																																									field = "tSwitchPetId"
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
																				}
																			},
																			{
																				node = {
																					id = "137",
																					class = "Sequence",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								id = "139",
																								class = "Assignment",
																								properties = {
																									{
																										CastRight = "false"
																									},
																									{
																										Opl = {
																											field = "tSwitchPetId"
																										}
																									},
																									{
																										Opr = {
																											func = "getPetActorIdByFunctionIdFromPetList",
																											params = {
																												{
																													const = "SUP"
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
																								id = "140",
																								class = "Condition",
																								properties = {
																									{
																										Operator = "GreaterEqual"
																									},
																									{
																										Opl = {
																											func = "getHpPercent",
																											params = {
																												{
																													field = "tSwitchPetId"
																												}
																											}
																										}
																									},
																									{
																										Opr = {
																											const = 0.2
																										}
																									}
																								},
																								attachments = {},
																								children = {}
																							}
																						},
																						{
																							node = {
																								id = "271",
																								class = "DecoratorLoopUntil",
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
																										Until = "true"
																									}
																								},
																								attachments = {},
																								children = {
																									{
																										node = {
																											id = "352",
																											class = "Selector",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														id = "353",
																														class = "Condition",
																														properties = {
																															{
																																Operator = "Equal"
																															},
																															{
																																Opl = {
																																	field = "tSwitchPetId"
																																}
																															},
																															{
																																Opr = {
																																	field = "tCurrentPet"
																																}
																															}
																														},
																														attachments = {},
																														children = {}
																													}
																												},
																												{
																													node = {
																														id = "351",
																														class = "Sequence",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	id = "347",
																																	class = "Action",
																																	properties = {
																																		{
																																			Method = {
																																				func = "waitTime",
																																				params = {
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
																															},
																															{
																																node = {
																																	id = "346",
																																	class = "And",
																																	properties = {},
																																	attachments = {},
																																	children = {
																																		{
																																			node = {
																																				id = "349",
																																				class = "Condition",
																																				properties = {
																																					{
																																						Operator = "Equal"
																																					},
																																					{
																																						Opl = {
																																							func = "isInSkill",
																																							params = {
																																								{
																																									field = "tCurrentPet"
																																								},
																																								{
																																									const = 0
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
																																				id = "348",
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
																																									field = "tCurrentPet"
																																								},
																																								{
																																									const = 10003
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
																															},
																															{
																																node = {
																																	id = "350",
																																	class = "Action",
																																	properties = {
																																		{
																																			Method = {
																																				func = "switchPetByActorId",
																																				params = {
																																					{
																																						field = "tSwitchPetId"
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
												id = "308",
												class = "Sequence",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "313",
															class = "Condition",
															properties = {
																{
																	Operator = "Equal"
																},
																{
																	Opl = {
																		func = "getPetActorIdByFunctionIdFromPetList",
																		params = {
																			{
																				const = "SUP"
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
															id = "307",
															class = "Assignment",
															properties = {
																{
																	CastRight = "false"
																},
																{
																	Opl = {
																		field = "tSwitchPetId"
																	}
																},
																{
																	Opr = {
																		func = "getPetActorIdByFunctionIdFromPetList",
																		params = {
																			{
																				const = "DPS"
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
															id = "386",
															class = "DecoratorLoopUntil",
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
																	Until = "true"
																}
															},
															attachments = {},
															children = {
																{
																	node = {
																		id = "387",
																		class = "Selector",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					id = "388",
																					class = "Condition",
																					properties = {
																						{
																							Operator = "Equal"
																						},
																						{
																							Opl = {
																								field = "tSwitchPetId"
																							}
																						},
																						{
																							Opr = {
																								field = "tCurrentPet"
																							}
																						}
																					},
																					attachments = {},
																					children = {}
																				}
																			},
																			{
																				node = {
																					id = "394",
																					class = "Sequence",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								id = "390",
																								class = "Action",
																								properties = {
																									{
																										Method = {
																											func = "waitTime",
																											params = {
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
																						},
																						{
																							node = {
																								id = "389",
																								class = "And",
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
																														func = "isInSkill",
																														params = {
																															{
																																field = "tCurrentPet"
																															},
																															{
																																const = 0
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
																											id = "391",
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
																																field = "tCurrentPet"
																															},
																															{
																																const = 10003
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
																						},
																						{
																							node = {
																								id = "393",
																								class = "Action",
																								properties = {
																									{
																										Method = {
																											func = "switchPetByActorId",
																											params = {
																												{
																													field = "tSwitchPetId"
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
										},
										{
											node = {
												id = "384",
												class = "Assignment",
												properties = {
													{
														CastRight = "false"
													},
													{
														Opl = {
															field = "combatTactic"
														}
													},
													{
														Opr = {
															const = "DPS"
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

return PBT_BotPlayer_Combat_155019
