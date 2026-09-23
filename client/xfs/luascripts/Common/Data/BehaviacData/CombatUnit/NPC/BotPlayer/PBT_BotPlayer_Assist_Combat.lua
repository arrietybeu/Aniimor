-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\CombatUnit\\NPC\\BotPlayer\\PBT_BotPlayer_Assist_Combat.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_BotPlayer_Assist_Combat = {
	behavior = {
		useForRoute = false,
		name = "CombatUnit/NPC/BotPlayer/PBT_BotPlayer_Assist_Combat",
		agenttype = "BotPlayerAgent",
		version = 127,
		properties = {},
		pars = {
			{
				name = "tCurrentPet",
				value = "0",
				const = 0,
				type = "int"
			},
			{
				name = "tCurrentPetHpPercent",
				value = "0",
				const = 0,
				type = "float"
			},
			{
				name = "tSwitchPetId",
				value = "0",
				const = 0,
				type = "int"
			},
			{
				name = "tTargetSkillId",
				value = "0",
				const = 0,
				type = "int"
			},
			{
				name = "tCurrentEp",
				value = "0",
				const = 0,
				type = "float"
			},
			{
				name = "tTeammateId1",
				value = "0",
				const = 0,
				type = "int"
			},
			{
				name = "tTeammateId2",
				value = "0",
				const = 0,
				type = "int"
			},
			{
				name = "tTeammateId3",
				value = "0",
				const = 0,
				type = "int"
			},
			{
				name = "tCurrentBreakPercent",
				value = "0",
				const = 0,
				type = "float"
			},
			{
				name = "tCurrentSp",
				value = "0",
				const = 0,
				type = "float"
			}
		},
		attachments = {},
		node = {
			class = "Sequence",
			id = "2",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						class = "Assignment",
						id = "381",
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
									func = "getBattlePetActorId",
									params = {
										{
											field = "selfId"
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
						class = "DecoratorLoop",
						id = "1",
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
									class = "Sequence",
									id = "11",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												class = "Sequence",
												id = "5",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															class = "Assignment",
															id = "6",
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
															class = "Assignment",
															id = "12",
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
																		const = "Common"
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
															id = "115",
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
															class = "Assignment",
															id = "126",
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
															class = "Sequence",
															id = "127",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		class = "Assignment",
																		id = "128",
																		properties = {
																			{
																				CastRight = "false"
																			},
																			{
																				Opl = {
																					field = "tTeammateId1"
																				}
																			},
																			{
																				Opr = {
																					func = "getTeammatePetActorId",
																					params = {
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
																		class = "Assignment",
																		id = "129",
																		properties = {
																			{
																				CastRight = "false"
																			},
																			{
																				Opl = {
																					field = "tTeammateId2"
																				}
																			},
																			{
																				Opr = {
																					func = "getTeammatePetActorId",
																					params = {
																						{
																							const = 2
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
																		class = "Assignment",
																		id = "130",
																		properties = {
																			{
																				CastRight = "false"
																			},
																			{
																				Opl = {
																					field = "tTeammateId3"
																				}
																			},
																			{
																				Opr = {
																					func = "getTeammatePetActorId",
																					params = {
																						{
																							const = 3
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
															class = "Assignment",
															id = "288",
															properties = {
																{
																	CastRight = "false"
																},
																{
																	Opl = {
																		field = "tCurrentBreakPercent"
																	}
																},
																{
																	Opr = {
																		func = "getBreakPercent",
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
															class = "Assignment",
															id = "289",
															properties = {
																{
																	CastRight = "false"
																},
																{
																	Opl = {
																		field = "tCurrentSp"
																	}
																},
																{
																	Opr = {
																		func = "getSp",
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
													}
												}
											}
										},
										{
											node = {
												class = "Selector",
												id = "4",
												properties = {},
												attachments = {
													{
														class = "Precondition",
														transition = false,
														effector = false,
														precondition = true,
														id = "462",
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
																			field = "tCurrentPet"
																		},
																		{
																			const = 4003032
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
																Phase = "Both"
															}
														}
													}
												},
												children = {
													{
														node = {
															class = "Sequence",
															id = "75",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		class = "Condition",
																		id = "132",
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
																							const = "DPS"
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
																		class = "Selector",
																		id = "133",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					class = "ReferencedBehavior",
																					id = "376",
																					properties = {
																						{
																							ReferenceBehavior = {
																								const = "PBT_BotPlayer_Assist_Combat_BACKSTAGE_HEAL"
																							}
																						},
																						{
																							subTreeProperties = {
																								{
																									Name = "tCurrentPet",
																									Type = "Self",
																									Value = {
																										field = "tCurrentPet"
																									}
																								},
																								{
																									Name = "tCurrentPetHpPercent",
																									Type = "Self",
																									Value = {
																										field = "tCurrentPetHpPercent"
																									}
																								},
																								{
																									Name = "tSwitchPetId",
																									Type = "Self",
																									Value = {
																										field = "tCurrentPet"
																									}
																								},
																								{
																									Name = "tTargetSkillId",
																									Type = "Self",
																									Value = {
																										field = "tTargetSkillId"
																									}
																								},
																								{
																									Name = "tCurrentEp",
																									Type = "Self",
																									Value = {
																										field = "tCurrentEp"
																									}
																								},
																								{
																									Name = "tTeammateId1",
																									Type = "Self",
																									Value = {
																										field = "tTeammateId1"
																									}
																								},
																								{
																									Name = "tTeammateId2",
																									Type = "Self",
																									Value = {
																										field = "tTeammateId2"
																									}
																								},
																								{
																									Name = "tTeammateId3",
																									Type = "Self",
																									Value = {
																										field = "tTeammateId3"
																									}
																								},
																								{
																									Name = "tCurrentBreakPercent",
																									Type = "Self",
																									Value = {
																										field = "tCurrentBreakPercent"
																									}
																								},
																								{
																									Name = "tCurrentSp",
																									Type = "Self",
																									Value = {
																										field = "tCurrentSp"
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
																					class = "ReferencedBehavior",
																					id = "385",
																					properties = {
																						{
																							ReferenceBehavior = {
																								const = "PBT_BotPlayer_Assist_Combat_BACKSTAGE_ENERGY"
																							}
																						},
																						{
																							subTreeProperties = {
																								{
																									Name = "tCurrentPet",
																									Type = "Self",
																									Value = {
																										field = "tCurrentPet"
																									}
																								},
																								{
																									Name = "tCurrentPetHpPercent",
																									Type = "Self",
																									Value = {
																										field = "tCurrentPetHpPercent"
																									}
																								},
																								{
																									Name = "tSwitchPetId",
																									Type = "Self",
																									Value = {
																										field = "tSwitchPetId"
																									}
																								},
																								{
																									Name = "tTargetSkillId",
																									Type = "Self",
																									Value = {
																										field = "tTargetSkillId"
																									}
																								},
																								{
																									Name = "tCurrentEp",
																									Type = "Self",
																									Value = {
																										field = "tCurrentEp"
																									}
																								},
																								{
																									Name = "tTeammateId1",
																									Type = "Self",
																									Value = {
																										field = "tTeammateId1"
																									}
																								},
																								{
																									Name = "tTeammateId2",
																									Type = "Self",
																									Value = {
																										field = "tTeammateId2"
																									}
																								},
																								{
																									Name = "tTeammateId3",
																									Type = "Self",
																									Value = {
																										field = "tTeammateId3"
																									}
																								},
																								{
																									Name = "tCurrentBreakPercent",
																									Type = "Self",
																									Value = {
																										field = "tCurrentBreakPercent"
																									}
																								},
																								{
																									Name = "tCurrentSp",
																									Type = "Self",
																									Value = {
																										field = "tCurrentSp"
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
																					class = "ReferencedBehavior",
																					id = "386",
																					properties = {
																						{
																							ReferenceBehavior = {
																								const = "PBT_BotPlayer_Assist_Combat_BACKSTAGE_SUP"
																							}
																						},
																						{
																							subTreeProperties = {
																								{
																									Name = "tCurrentPet",
																									Type = "Self",
																									Value = {
																										field = "tCurrentPet"
																									}
																								},
																								{
																									Name = "tCurrentPetHpPercent",
																									Type = "Self",
																									Value = {
																										field = "tCurrentPetHpPercent"
																									}
																								},
																								{
																									Name = "tSwitchPetId",
																									Type = "Self",
																									Value = {
																										field = "tSwitchPetId"
																									}
																								},
																								{
																									Name = "tTargetSkillId",
																									Type = "Self",
																									Value = {
																										field = "tTargetSkillId"
																									}
																								},
																								{
																									Name = "tCurrentEp",
																									Type = "Self",
																									Value = {
																										field = "tCurrentEp"
																									}
																								},
																								{
																									Name = "tTeammateId1",
																									Type = "Self",
																									Value = {
																										field = "tTeammateId1"
																									}
																								},
																								{
																									Name = "tTeammateId2",
																									Type = "Self",
																									Value = {
																										field = "tTeammateId2"
																									}
																								},
																								{
																									Name = "tTeammateId3",
																									Type = "Self",
																									Value = {
																										field = "tTeammateId3"
																									}
																								},
																								{
																									Name = "tCurrentBreakPercent",
																									Type = "Self",
																									Value = {
																										field = "tCurrentBreakPercent"
																									}
																								},
																								{
																									Name = "tCurrentSp",
																									Type = "Self",
																									Value = {
																										field = "tCurrentSp"
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
																					class = "ReferencedBehavior",
																					id = "387",
																					properties = {
																						{
																							ReferenceBehavior = {
																								const = "PBT_BotPlayer_Assist_Combat_BACKSTAGE_BREAK"
																							}
																						},
																						{
																							subTreeProperties = {
																								{
																									Name = "tCurrentPet",
																									Type = "Self",
																									Value = {
																										field = "tCurrentPet"
																									}
																								},
																								{
																									Name = "tCurrentPetHpPercent",
																									Type = "Self",
																									Value = {
																										field = "tCurrentPetHpPercent"
																									}
																								},
																								{
																									Name = "tSwitchPetId",
																									Type = "Self",
																									Value = {
																										field = "tSwitchPetId"
																									}
																								},
																								{
																									Name = "tTargetSkillId",
																									Type = "Self",
																									Value = {
																										field = "tTargetSkillId"
																									}
																								},
																								{
																									Name = "tCurrentEp",
																									Type = "Self",
																									Value = {
																										field = "tCurrentEp"
																									}
																								},
																								{
																									Name = "tTeammateId1",
																									Type = "Self",
																									Value = {
																										field = "tTeammateId1"
																									}
																								},
																								{
																									Name = "tTeammateId2",
																									Type = "Self",
																									Value = {
																										field = "tTeammateId2"
																									}
																								},
																								{
																									Name = "tTeammateId3",
																									Type = "Self",
																									Value = {
																										field = "tTeammateId3"
																									}
																								},
																								{
																									Name = "tCurrentBreakPercent",
																									Type = "Self",
																									Value = {
																										field = "tCurrentBreakPercent"
																									}
																								},
																								{
																									Name = "tCurrentSp",
																									Type = "Self",
																									Value = {
																										field = "tCurrentSp"
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
																					class = "Noop",
																					id = "388",
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
															class = "Sequence",
															id = "169",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		class = "Condition",
																		id = "170",
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
																							const = "BREAK"
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
																		class = "Selector",
																		id = "171",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					class = "ReferencedBehavior",
																					id = "392",
																					properties = {
																						{
																							ReferenceBehavior = {
																								const = "PBT_BotPlayer_Assist_Combat_BACKSTAGE_DPS"
																							}
																						},
																						{
																							subTreeProperties = {
																								{
																									Name = "tCurrentPet",
																									Type = "Self",
																									Value = {
																										field = "tCurrentPet"
																									}
																								},
																								{
																									Name = "tCurrentPetHpPercent",
																									Type = "Self",
																									Value = {
																										field = "tCurrentPetHpPercent"
																									}
																								},
																								{
																									Name = "tSwitchPetId",
																									Type = "Self",
																									Value = {
																										field = "tSwitchPetId"
																									}
																								},
																								{
																									Name = "tTargetSkillId",
																									Type = "Self",
																									Value = {
																										field = "tTargetSkillId"
																									}
																								},
																								{
																									Name = "tCurrentEp",
																									Type = "Self",
																									Value = {
																										field = "tCurrentEp"
																									}
																								},
																								{
																									Name = "tTeammateId1",
																									Type = "Self",
																									Value = {
																										field = "tTeammateId1"
																									}
																								},
																								{
																									Name = "tTeammateId2",
																									Type = "Self",
																									Value = {
																										field = "tTeammateId2"
																									}
																								},
																								{
																									Name = "tTeammateId3",
																									Type = "Self",
																									Value = {
																										field = "tTeammateId3"
																									}
																								},
																								{
																									Name = "tCurrentBreakPercent",
																									Type = "Self",
																									Value = {
																										field = "tCurrentBreakPercent"
																									}
																								},
																								{
																									Name = "tCurrentSp",
																									Type = "Self",
																									Value = {
																										field = "tCurrentSp"
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
																					class = "ReferencedBehavior",
																					id = "389",
																					properties = {
																						{
																							ReferenceBehavior = {
																								const = "PBT_BotPlayer_Assist_Combat_BACKSTAGE_HEAL"
																							}
																						},
																						{
																							subTreeProperties = {
																								{
																									Name = "tCurrentPet",
																									Type = "Self",
																									Value = {
																										field = "tCurrentPet"
																									}
																								},
																								{
																									Name = "tCurrentPetHpPercent",
																									Type = "Self",
																									Value = {
																										field = "tCurrentPetHpPercent"
																									}
																								},
																								{
																									Name = "tSwitchPetId",
																									Type = "Self",
																									Value = {
																										field = "tCurrentPet"
																									}
																								},
																								{
																									Name = "tTargetSkillId",
																									Type = "Self",
																									Value = {
																										field = "tTargetSkillId"
																									}
																								},
																								{
																									Name = "tCurrentEp",
																									Type = "Self",
																									Value = {
																										field = "tCurrentEp"
																									}
																								},
																								{
																									Name = "tTeammateId1",
																									Type = "Self",
																									Value = {
																										field = "tTeammateId1"
																									}
																								},
																								{
																									Name = "tTeammateId2",
																									Type = "Self",
																									Value = {
																										field = "tTeammateId2"
																									}
																								},
																								{
																									Name = "tTeammateId3",
																									Type = "Self",
																									Value = {
																										field = "tTeammateId3"
																									}
																								},
																								{
																									Name = "tCurrentBreakPercent",
																									Type = "Self",
																									Value = {
																										field = "tCurrentBreakPercent"
																									}
																								},
																								{
																									Name = "tCurrentSp",
																									Type = "Self",
																									Value = {
																										field = "tCurrentSp"
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
																					class = "ReferencedBehavior",
																					id = "390",
																					properties = {
																						{
																							ReferenceBehavior = {
																								const = "PBT_BotPlayer_Assist_Combat_BACKSTAGE_ENERGY"
																							}
																						},
																						{
																							subTreeProperties = {
																								{
																									Name = "tCurrentPet",
																									Type = "Self",
																									Value = {
																										field = "tCurrentPet"
																									}
																								},
																								{
																									Name = "tCurrentPetHpPercent",
																									Type = "Self",
																									Value = {
																										field = "tCurrentPetHpPercent"
																									}
																								},
																								{
																									Name = "tSwitchPetId",
																									Type = "Self",
																									Value = {
																										field = "tSwitchPetId"
																									}
																								},
																								{
																									Name = "tTargetSkillId",
																									Type = "Self",
																									Value = {
																										field = "tTargetSkillId"
																									}
																								},
																								{
																									Name = "tCurrentEp",
																									Type = "Self",
																									Value = {
																										field = "tCurrentEp"
																									}
																								},
																								{
																									Name = "tTeammateId1",
																									Type = "Self",
																									Value = {
																										field = "tTeammateId1"
																									}
																								},
																								{
																									Name = "tTeammateId2",
																									Type = "Self",
																									Value = {
																										field = "tTeammateId2"
																									}
																								},
																								{
																									Name = "tTeammateId3",
																									Type = "Self",
																									Value = {
																										field = "tTeammateId3"
																									}
																								},
																								{
																									Name = "tCurrentBreakPercent",
																									Type = "Self",
																									Value = {
																										field = "tCurrentBreakPercent"
																									}
																								},
																								{
																									Name = "tCurrentSp",
																									Type = "Self",
																									Value = {
																										field = "tCurrentSp"
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
																					class = "ReferencedBehavior",
																					id = "391",
																					properties = {
																						{
																							ReferenceBehavior = {
																								const = "PBT_BotPlayer_Assist_Combat_BACKSTAGE_SUP"
																							}
																						},
																						{
																							subTreeProperties = {
																								{
																									Name = "tCurrentPet",
																									Type = "Self",
																									Value = {
																										field = "tCurrentPet"
																									}
																								},
																								{
																									Name = "tCurrentPetHpPercent",
																									Type = "Self",
																									Value = {
																										field = "tCurrentPetHpPercent"
																									}
																								},
																								{
																									Name = "tSwitchPetId",
																									Type = "Self",
																									Value = {
																										field = "tSwitchPetId"
																									}
																								},
																								{
																									Name = "tTargetSkillId",
																									Type = "Self",
																									Value = {
																										field = "tTargetSkillId"
																									}
																								},
																								{
																									Name = "tCurrentEp",
																									Type = "Self",
																									Value = {
																										field = "tCurrentEp"
																									}
																								},
																								{
																									Name = "tTeammateId1",
																									Type = "Self",
																									Value = {
																										field = "tTeammateId1"
																									}
																								},
																								{
																									Name = "tTeammateId2",
																									Type = "Self",
																									Value = {
																										field = "tTeammateId2"
																									}
																								},
																								{
																									Name = "tTeammateId3",
																									Type = "Self",
																									Value = {
																										field = "tTeammateId3"
																									}
																								},
																								{
																									Name = "tCurrentBreakPercent",
																									Type = "Self",
																									Value = {
																										field = "tCurrentBreakPercent"
																									}
																								},
																								{
																									Name = "tCurrentSp",
																									Type = "Self",
																									Value = {
																										field = "tCurrentSp"
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
																					class = "Noop",
																					id = "393",
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
															class = "Sequence",
															id = "211",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		class = "Condition",
																		id = "210",
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
																		class = "Selector",
																		id = "411",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					class = "Sequence",
																					id = "416",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								class = "Sequence",
																								id = "445",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											class = "Selector",
																											id = "412",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														class = "Condition",
																														id = "409",
																														properties = {
																															{
																																Operator = "LessEqual"
																															},
																															{
																																Opl = {
																																	func = "getHpPercent",
																																	params = {
																																		{
																																			field = "tTeammateId1"
																																		}
																																	}
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
																														class = "Condition",
																														id = "413",
																														properties = {
																															{
																																Operator = "LessEqual"
																															},
																															{
																																Opl = {
																																	func = "getHpPercent",
																																	params = {
																																		{
																																			field = "tTeammateId2"
																																		}
																																	}
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
																														class = "Condition",
																														id = "414",
																														properties = {
																															{
																																Operator = "LessEqual"
																															},
																															{
																																Opl = {
																																	func = "getHpPercent",
																																	params = {
																																		{
																																			field = "tTeammateId3"
																																		}
																																	}
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
																														class = "Condition",
																														id = "415",
																														properties = {
																															{
																																Operator = "LessEqual"
																															},
																															{
																																Opl = {
																																	func = "getHpPercent",
																																	params = {
																																		{
																																			field = "tCurrentPet"
																																		}
																																	}
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
																												}
																											}
																										}
																									},
																									{
																										node = {
																											class = "Selector",
																											id = "448",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														class = "Sequence",
																														id = "465",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	class = "Assignment",
																																	id = "446",
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
																																						const = true
																																					},
																																					{
																																						const = 0
																																					},
																																					{
																																						const = false
																																					},
																																					{
																																						field = "tCurrentPet"
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
																																	class = "Condition",
																																	id = "447",
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
																														class = "Sequence",
																														id = "467",
																														properties = {},
																														attachments = {},
																														children = {
																															{
																																node = {
																																	class = "Assignment",
																																	id = "449",
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
																																						const = true
																																					},
																																					{
																																						const = 0
																																					},
																																					{
																																						const = false
																																					},
																																					{
																																						field = "tCurrentPet"
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
																																	class = "Condition",
																																	id = "466",
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
																									}
																								}
																							}
																						},
																						{
																							node = {
																								class = "Assignment",
																								id = "418",
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
																											const = "Tactics_Heal"
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
																					class = "Selector",
																					id = "199",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								class = "ReferencedBehavior",
																								id = "397",
																								properties = {
																									{
																										ReferenceBehavior = {
																											const = "PBT_BotPlayer_Assist_Combat_BACKSTAGE_DPS"
																										}
																									},
																									{
																										subTreeProperties = {
																											{
																												Name = "tCurrentPet",
																												Type = "Self",
																												Value = {
																													field = "tCurrentPet"
																												}
																											},
																											{
																												Name = "tCurrentPetHpPercent",
																												Type = "Self",
																												Value = {
																													field = "tCurrentPetHpPercent"
																												}
																											},
																											{
																												Name = "tSwitchPetId",
																												Type = "Self",
																												Value = {
																													field = "tSwitchPetId"
																												}
																											},
																											{
																												Name = "tTargetSkillId",
																												Type = "Self",
																												Value = {
																													field = "tTargetSkillId"
																												}
																											},
																											{
																												Name = "tCurrentEp",
																												Type = "Self",
																												Value = {
																													field = "tCurrentEp"
																												}
																											},
																											{
																												Name = "tTeammateId1",
																												Type = "Self",
																												Value = {
																													field = "tTeammateId1"
																												}
																											},
																											{
																												Name = "tTeammateId2",
																												Type = "Self",
																												Value = {
																													field = "tTeammateId2"
																												}
																											},
																											{
																												Name = "tTeammateId3",
																												Type = "Self",
																												Value = {
																													field = "tTeammateId3"
																												}
																											},
																											{
																												Name = "tCurrentBreakPercent",
																												Type = "Self",
																												Value = {
																													field = "tCurrentBreakPercent"
																												}
																											},
																											{
																												Name = "tCurrentSp",
																												Type = "Self",
																												Value = {
																													field = "tCurrentSp"
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
																								class = "ReferencedBehavior",
																								id = "395",
																								properties = {
																									{
																										ReferenceBehavior = {
																											const = "PBT_BotPlayer_Assist_Combat_BACKSTAGE_ENERGY"
																										}
																									},
																									{
																										subTreeProperties = {
																											{
																												Name = "tCurrentPet",
																												Type = "Self",
																												Value = {
																													field = "tCurrentPet"
																												}
																											},
																											{
																												Name = "tCurrentPetHpPercent",
																												Type = "Self",
																												Value = {
																													field = "tCurrentPetHpPercent"
																												}
																											},
																											{
																												Name = "tSwitchPetId",
																												Type = "Self",
																												Value = {
																													field = "tSwitchPetId"
																												}
																											},
																											{
																												Name = "tTargetSkillId",
																												Type = "Self",
																												Value = {
																													field = "tTargetSkillId"
																												}
																											},
																											{
																												Name = "tCurrentEp",
																												Type = "Self",
																												Value = {
																													field = "tCurrentEp"
																												}
																											},
																											{
																												Name = "tTeammateId1",
																												Type = "Self",
																												Value = {
																													field = "tTeammateId1"
																												}
																											},
																											{
																												Name = "tTeammateId2",
																												Type = "Self",
																												Value = {
																													field = "tTeammateId2"
																												}
																											},
																											{
																												Name = "tTeammateId3",
																												Type = "Self",
																												Value = {
																													field = "tTeammateId3"
																												}
																											},
																											{
																												Name = "tCurrentBreakPercent",
																												Type = "Self",
																												Value = {
																													field = "tCurrentBreakPercent"
																												}
																											},
																											{
																												Name = "tCurrentSp",
																												Type = "Self",
																												Value = {
																													field = "tCurrentSp"
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
																								class = "ReferencedBehavior",
																								id = "396",
																								properties = {
																									{
																										ReferenceBehavior = {
																											const = "PBT_BotPlayer_Assist_Combat_BACKSTAGE_SUP"
																										}
																									},
																									{
																										subTreeProperties = {
																											{
																												Name = "tCurrentPet",
																												Type = "Self",
																												Value = {
																													field = "tCurrentPet"
																												}
																											},
																											{
																												Name = "tCurrentPetHpPercent",
																												Type = "Self",
																												Value = {
																													field = "tCurrentPetHpPercent"
																												}
																											},
																											{
																												Name = "tSwitchPetId",
																												Type = "Self",
																												Value = {
																													field = "tSwitchPetId"
																												}
																											},
																											{
																												Name = "tTargetSkillId",
																												Type = "Self",
																												Value = {
																													field = "tTargetSkillId"
																												}
																											},
																											{
																												Name = "tCurrentEp",
																												Type = "Self",
																												Value = {
																													field = "tCurrentEp"
																												}
																											},
																											{
																												Name = "tTeammateId1",
																												Type = "Self",
																												Value = {
																													field = "tTeammateId1"
																												}
																											},
																											{
																												Name = "tTeammateId2",
																												Type = "Self",
																												Value = {
																													field = "tTeammateId2"
																												}
																											},
																											{
																												Name = "tTeammateId3",
																												Type = "Self",
																												Value = {
																													field = "tTeammateId3"
																												}
																											},
																											{
																												Name = "tCurrentBreakPercent",
																												Type = "Self",
																												Value = {
																													field = "tCurrentBreakPercent"
																												}
																											},
																											{
																												Name = "tCurrentSp",
																												Type = "Self",
																												Value = {
																													field = "tCurrentSp"
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
																								class = "Sequence",
																								id = "451",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											class = "Condition",
																											id = "450",
																											properties = {
																												{
																													Operator = "GreaterEqual"
																												},
																												{
																													Opl = {
																														func = "getEp",
																														params = {
																															{
																																field = "selfId"
																															}
																														}
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
																											class = "ReferencedBehavior",
																											id = "398",
																											properties = {
																												{
																													ReferenceBehavior = {
																														const = "PBT_BotPlayer_Assist_Combat_BACKSTAGE_BREAK"
																													}
																												},
																												{
																													subTreeProperties = {
																														{
																															Name = "tCurrentPet",
																															Type = "Self",
																															Value = {
																																field = "tCurrentPet"
																															}
																														},
																														{
																															Name = "tCurrentPetHpPercent",
																															Type = "Self",
																															Value = {
																																field = "tCurrentPetHpPercent"
																															}
																														},
																														{
																															Name = "tSwitchPetId",
																															Type = "Self",
																															Value = {
																																field = "tSwitchPetId"
																															}
																														},
																														{
																															Name = "tTargetSkillId",
																															Type = "Self",
																															Value = {
																																field = "tTargetSkillId"
																															}
																														},
																														{
																															Name = "tCurrentEp",
																															Type = "Self",
																															Value = {
																																field = "tCurrentEp"
																															}
																														},
																														{
																															Name = "tTeammateId1",
																															Type = "Self",
																															Value = {
																																field = "tTeammateId1"
																															}
																														},
																														{
																															Name = "tTeammateId2",
																															Type = "Self",
																															Value = {
																																field = "tTeammateId2"
																															}
																														},
																														{
																															Name = "tTeammateId3",
																															Type = "Self",
																															Value = {
																																field = "tTeammateId3"
																															}
																														},
																														{
																															Name = "tCurrentBreakPercent",
																															Type = "Self",
																															Value = {
																																field = "tCurrentBreakPercent"
																															}
																														},
																														{
																															Name = "tCurrentSp",
																															Type = "Self",
																															Value = {
																																field = "tCurrentSp"
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
															id = "236",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		class = "Condition",
																		id = "235",
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
																							const = "SUP"
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
																		class = "Selector",
																		id = "429",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					class = "Sequence",
																					id = "430",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								class = "Selector",
																								id = "433",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											class = "Sequence",
																											id = "434",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														class = "Assignment",
																														id = "435",
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
																																			const = 6
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
																																			field = "tCurrentPet"
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
																														class = "Condition",
																														id = "436",
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
																														class = "Condition",
																														id = "464",
																														properties = {
																															{
																																Operator = "Equal"
																															},
																															{
																																Opl = {
																																	func = "checkTargetHasBuffFromSource",
																																	params = {
																																		{
																																			field = "tCurrentPet"
																																		},
																																		{
																																			const = "Positive"
																																		},
																																		{
																																			field = "tCurrentPet"
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
																											class = "Sequence",
																											id = "440",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														class = "Assignment",
																														id = "437",
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
																																			const = 7
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
																																			field = "tCurrentPet"
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
																														class = "Condition",
																														id = "438",
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
																														class = "Condition",
																														id = "463",
																														properties = {
																															{
																																Operator = "Equal"
																															},
																															{
																																Opl = {
																																	func = "checkTargetHasBuffFromSource",
																																	params = {
																																		{
																																			field = "tgt"
																																		},
																																		{
																																			const = "Negative"
																																		},
																																		{
																																			field = "tCurrentPet"
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
																								class = "Assignment",
																								id = "431",
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
																											const = "Tactics_Sup"
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
																					class = "Selector",
																					id = "234",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								class = "ReferencedBehavior",
																								id = "401",
																								properties = {
																									{
																										ReferenceBehavior = {
																											const = "PBT_BotPlayer_Assist_Combat_BACKSTAGE_DPS"
																										}
																									},
																									{
																										subTreeProperties = {
																											{
																												Name = "tCurrentPet",
																												Type = "Self",
																												Value = {
																													field = "tCurrentPet"
																												}
																											},
																											{
																												Name = "tCurrentPetHpPercent",
																												Type = "Self",
																												Value = {
																													field = "tCurrentPetHpPercent"
																												}
																											},
																											{
																												Name = "tSwitchPetId",
																												Type = "Self",
																												Value = {
																													field = "tSwitchPetId"
																												}
																											},
																											{
																												Name = "tTargetSkillId",
																												Type = "Self",
																												Value = {
																													field = "tTargetSkillId"
																												}
																											},
																											{
																												Name = "tCurrentEp",
																												Type = "Self",
																												Value = {
																													field = "tCurrentEp"
																												}
																											},
																											{
																												Name = "tTeammateId1",
																												Type = "Self",
																												Value = {
																													field = "tTeammateId1"
																												}
																											},
																											{
																												Name = "tTeammateId2",
																												Type = "Self",
																												Value = {
																													field = "tTeammateId2"
																												}
																											},
																											{
																												Name = "tTeammateId3",
																												Type = "Self",
																												Value = {
																													field = "tTeammateId3"
																												}
																											},
																											{
																												Name = "tCurrentBreakPercent",
																												Type = "Self",
																												Value = {
																													field = "tCurrentBreakPercent"
																												}
																											},
																											{
																												Name = "tCurrentSp",
																												Type = "Self",
																												Value = {
																													field = "tCurrentSp"
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
																								class = "ReferencedBehavior",
																								id = "403",
																								properties = {
																									{
																										ReferenceBehavior = {
																											const = "PBT_BotPlayer_Assist_Combat_BACKSTAGE_HEAL"
																										}
																									},
																									{
																										subTreeProperties = {
																											{
																												Name = "tCurrentPet",
																												Type = "Self",
																												Value = {
																													field = "tCurrentPet"
																												}
																											},
																											{
																												Name = "tCurrentPetHpPercent",
																												Type = "Self",
																												Value = {
																													field = "tCurrentPetHpPercent"
																												}
																											},
																											{
																												Name = "tSwitchPetId",
																												Type = "Self",
																												Value = {
																													field = "tCurrentPet"
																												}
																											},
																											{
																												Name = "tTargetSkillId",
																												Type = "Self",
																												Value = {
																													field = "tTargetSkillId"
																												}
																											},
																											{
																												Name = "tCurrentEp",
																												Type = "Self",
																												Value = {
																													field = "tCurrentEp"
																												}
																											},
																											{
																												Name = "tTeammateId1",
																												Type = "Self",
																												Value = {
																													field = "tTeammateId1"
																												}
																											},
																											{
																												Name = "tTeammateId2",
																												Type = "Self",
																												Value = {
																													field = "tTeammateId2"
																												}
																											},
																											{
																												Name = "tTeammateId3",
																												Type = "Self",
																												Value = {
																													field = "tTeammateId3"
																												}
																											},
																											{
																												Name = "tCurrentBreakPercent",
																												Type = "Self",
																												Value = {
																													field = "tCurrentBreakPercent"
																												}
																											},
																											{
																												Name = "tCurrentSp",
																												Type = "Self",
																												Value = {
																													field = "tCurrentSp"
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
																								class = "ReferencedBehavior",
																								id = "399",
																								properties = {
																									{
																										ReferenceBehavior = {
																											const = "PBT_BotPlayer_Assist_Combat_BACKSTAGE_ENERGY"
																										}
																									},
																									{
																										subTreeProperties = {
																											{
																												Name = "tCurrentPet",
																												Type = "Self",
																												Value = {
																													field = "tCurrentPet"
																												}
																											},
																											{
																												Name = "tCurrentPetHpPercent",
																												Type = "Self",
																												Value = {
																													field = "tCurrentPetHpPercent"
																												}
																											},
																											{
																												Name = "tSwitchPetId",
																												Type = "Self",
																												Value = {
																													field = "tSwitchPetId"
																												}
																											},
																											{
																												Name = "tTargetSkillId",
																												Type = "Self",
																												Value = {
																													field = "tTargetSkillId"
																												}
																											},
																											{
																												Name = "tCurrentEp",
																												Type = "Self",
																												Value = {
																													field = "tCurrentEp"
																												}
																											},
																											{
																												Name = "tTeammateId1",
																												Type = "Self",
																												Value = {
																													field = "tTeammateId1"
																												}
																											},
																											{
																												Name = "tTeammateId2",
																												Type = "Self",
																												Value = {
																													field = "tTeammateId2"
																												}
																											},
																											{
																												Name = "tTeammateId3",
																												Type = "Self",
																												Value = {
																													field = "tTeammateId3"
																												}
																											},
																											{
																												Name = "tCurrentBreakPercent",
																												Type = "Self",
																												Value = {
																													field = "tCurrentBreakPercent"
																												}
																											},
																											{
																												Name = "tCurrentSp",
																												Type = "Self",
																												Value = {
																													field = "tCurrentSp"
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
																								class = "Sequence",
																								id = "453",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											class = "Condition",
																											id = "452",
																											properties = {
																												{
																													Operator = "GreaterEqual"
																												},
																												{
																													Opl = {
																														func = "getEp",
																														params = {
																															{
																																field = "selfId"
																															}
																														}
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
																											class = "ReferencedBehavior",
																											id = "400",
																											properties = {
																												{
																													ReferenceBehavior = {
																														const = "PBT_BotPlayer_Assist_Combat_BACKSTAGE_BREAK"
																													}
																												},
																												{
																													subTreeProperties = {
																														{
																															Name = "tCurrentPet",
																															Type = "Self",
																															Value = {
																																field = "tCurrentPet"
																															}
																														},
																														{
																															Name = "tCurrentPetHpPercent",
																															Type = "Self",
																															Value = {
																																field = "tCurrentPetHpPercent"
																															}
																														},
																														{
																															Name = "tSwitchPetId",
																															Type = "Self",
																															Value = {
																																field = "tSwitchPetId"
																															}
																														},
																														{
																															Name = "tTargetSkillId",
																															Type = "Self",
																															Value = {
																																field = "tTargetSkillId"
																															}
																														},
																														{
																															Name = "tCurrentEp",
																															Type = "Self",
																															Value = {
																																field = "tCurrentEp"
																															}
																														},
																														{
																															Name = "tTeammateId1",
																															Type = "Self",
																															Value = {
																																field = "tTeammateId1"
																															}
																														},
																														{
																															Name = "tTeammateId2",
																															Type = "Self",
																															Value = {
																																field = "tTeammateId2"
																															}
																														},
																														{
																															Name = "tTeammateId3",
																															Type = "Self",
																															Value = {
																																field = "tTeammateId3"
																															}
																														},
																														{
																															Name = "tCurrentBreakPercent",
																															Type = "Self",
																															Value = {
																																field = "tCurrentBreakPercent"
																															}
																														},
																														{
																															Name = "tCurrentSp",
																															Type = "Self",
																															Value = {
																																field = "tCurrentSp"
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
															id = "263",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		class = "Condition",
																		id = "262",
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
																							const = "ENERGY"
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
																		class = "Selector",
																		id = "426",
																		properties = {},
																		attachments = {},
																		children = {
																			{
																				node = {
																					class = "Sequence",
																					id = "424",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								class = "Sequence",
																								id = "442",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											class = "Assignment",
																											id = "443",
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
																																field = "tCurrentPet"
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
																											class = "Condition",
																											id = "444",
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
																											class = "Selector",
																											id = "420",
																											properties = {},
																											attachments = {},
																											children = {
																												{
																													node = {
																														class = "Condition",
																														id = "419",
																														properties = {
																															{
																																Operator = "LessEqual"
																															},
																															{
																																Opl = {
																																	func = "getEp",
																																	params = {
																																		{
																																			field = "tCurrentPet"
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
																														class = "Condition",
																														id = "421",
																														properties = {
																															{
																																Operator = "LessEqual"
																															},
																															{
																																Opl = {
																																	func = "getEp",
																																	params = {
																																		{
																																			field = "tTeammateId1"
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
																														class = "Condition",
																														id = "427",
																														properties = {
																															{
																																Operator = "LessEqual"
																															},
																															{
																																Opl = {
																																	func = "getEp",
																																	params = {
																																		{
																																			field = "tTeammateId2"
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
																														class = "Condition",
																														id = "428",
																														properties = {
																															{
																																Operator = "LessEqual"
																															},
																															{
																																Opl = {
																																	func = "getEp",
																																	params = {
																																		{
																																			field = "tTeammateId3"
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
																												}
																											}
																										}
																									}
																								}
																							}
																						},
																						{
																							node = {
																								class = "Assignment",
																								id = "425",
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
																											const = "Tactics_Energy"
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
																					class = "Selector",
																					id = "261",
																					properties = {},
																					attachments = {},
																					children = {
																						{
																							node = {
																								class = "ReferencedBehavior",
																								id = "405",
																								properties = {
																									{
																										ReferenceBehavior = {
																											const = "PBT_BotPlayer_Assist_Combat_BACKSTAGE_DPS"
																										}
																									},
																									{
																										subTreeProperties = {
																											{
																												Name = "tCurrentPet",
																												Type = "Self",
																												Value = {
																													field = "tCurrentPet"
																												}
																											},
																											{
																												Name = "tCurrentPetHpPercent",
																												Type = "Self",
																												Value = {
																													field = "tCurrentPetHpPercent"
																												}
																											},
																											{
																												Name = "tSwitchPetId",
																												Type = "Self",
																												Value = {
																													field = "tSwitchPetId"
																												}
																											},
																											{
																												Name = "tTargetSkillId",
																												Type = "Self",
																												Value = {
																													field = "tTargetSkillId"
																												}
																											},
																											{
																												Name = "tCurrentEp",
																												Type = "Self",
																												Value = {
																													field = "tCurrentEp"
																												}
																											},
																											{
																												Name = "tTeammateId1",
																												Type = "Self",
																												Value = {
																													field = "tTeammateId1"
																												}
																											},
																											{
																												Name = "tTeammateId2",
																												Type = "Self",
																												Value = {
																													field = "tTeammateId2"
																												}
																											},
																											{
																												Name = "tTeammateId3",
																												Type = "Self",
																												Value = {
																													field = "tTeammateId3"
																												}
																											},
																											{
																												Name = "tCurrentBreakPercent",
																												Type = "Self",
																												Value = {
																													field = "tCurrentBreakPercent"
																												}
																											},
																											{
																												Name = "tCurrentSp",
																												Type = "Self",
																												Value = {
																													field = "tCurrentSp"
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
																								class = "ReferencedBehavior",
																								id = "406",
																								properties = {
																									{
																										ReferenceBehavior = {
																											const = "PBT_BotPlayer_Assist_Combat_BACKSTAGE_HEAL"
																										}
																									},
																									{
																										subTreeProperties = {
																											{
																												Name = "tCurrentPet",
																												Type = "Self",
																												Value = {
																													field = "tCurrentPet"
																												}
																											},
																											{
																												Name = "tCurrentPetHpPercent",
																												Type = "Self",
																												Value = {
																													field = "tCurrentPetHpPercent"
																												}
																											},
																											{
																												Name = "tSwitchPetId",
																												Type = "Self",
																												Value = {
																													field = "tCurrentPet"
																												}
																											},
																											{
																												Name = "tTargetSkillId",
																												Type = "Self",
																												Value = {
																													field = "tTargetSkillId"
																												}
																											},
																											{
																												Name = "tCurrentEp",
																												Type = "Self",
																												Value = {
																													field = "tCurrentEp"
																												}
																											},
																											{
																												Name = "tTeammateId1",
																												Type = "Self",
																												Value = {
																													field = "tTeammateId1"
																												}
																											},
																											{
																												Name = "tTeammateId2",
																												Type = "Self",
																												Value = {
																													field = "tTeammateId2"
																												}
																											},
																											{
																												Name = "tTeammateId3",
																												Type = "Self",
																												Value = {
																													field = "tTeammateId3"
																												}
																											},
																											{
																												Name = "tCurrentBreakPercent",
																												Type = "Self",
																												Value = {
																													field = "tCurrentBreakPercent"
																												}
																											},
																											{
																												Name = "tCurrentSp",
																												Type = "Self",
																												Value = {
																													field = "tCurrentSp"
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
																								class = "ReferencedBehavior",
																								id = "408",
																								properties = {
																									{
																										ReferenceBehavior = {
																											const = "PBT_BotPlayer_Assist_Combat_BACKSTAGE_SUP"
																										}
																									},
																									{
																										subTreeProperties = {
																											{
																												Name = "tCurrentPet",
																												Type = "Self",
																												Value = {
																													field = "tCurrentPet"
																												}
																											},
																											{
																												Name = "tCurrentPetHpPercent",
																												Type = "Self",
																												Value = {
																													field = "tCurrentPetHpPercent"
																												}
																											},
																											{
																												Name = "tSwitchPetId",
																												Type = "Self",
																												Value = {
																													field = "tSwitchPetId"
																												}
																											},
																											{
																												Name = "tTargetSkillId",
																												Type = "Self",
																												Value = {
																													field = "tTargetSkillId"
																												}
																											},
																											{
																												Name = "tCurrentEp",
																												Type = "Self",
																												Value = {
																													field = "tCurrentEp"
																												}
																											},
																											{
																												Name = "tTeammateId1",
																												Type = "Self",
																												Value = {
																													field = "tTeammateId1"
																												}
																											},
																											{
																												Name = "tTeammateId2",
																												Type = "Self",
																												Value = {
																													field = "tTeammateId2"
																												}
																											},
																											{
																												Name = "tTeammateId3",
																												Type = "Self",
																												Value = {
																													field = "tTeammateId3"
																												}
																											},
																											{
																												Name = "tCurrentBreakPercent",
																												Type = "Self",
																												Value = {
																													field = "tCurrentBreakPercent"
																												}
																											},
																											{
																												Name = "tCurrentSp",
																												Type = "Self",
																												Value = {
																													field = "tCurrentSp"
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
																								class = "Sequence",
																								id = "455",
																								properties = {},
																								attachments = {},
																								children = {
																									{
																										node = {
																											class = "Condition",
																											id = "456",
																											properties = {
																												{
																													Operator = "GreaterEqual"
																												},
																												{
																													Opl = {
																														func = "getEp",
																														params = {
																															{
																																field = "selfId"
																															}
																														}
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
																											class = "ReferencedBehavior",
																											id = "454",
																											properties = {
																												{
																													ReferenceBehavior = {
																														const = "PBT_BotPlayer_Assist_Combat_BACKSTAGE_BREAK"
																													}
																												},
																												{
																													subTreeProperties = {
																														{
																															Name = "tCurrentPet",
																															Type = "Self",
																															Value = {
																																field = "tCurrentPet"
																															}
																														},
																														{
																															Name = "tCurrentPetHpPercent",
																															Type = "Self",
																															Value = {
																																field = "tCurrentPetHpPercent"
																															}
																														},
																														{
																															Name = "tSwitchPetId",
																															Type = "Self",
																															Value = {
																																field = "tSwitchPetId"
																															}
																														},
																														{
																															Name = "tTargetSkillId",
																															Type = "Self",
																															Value = {
																																field = "tTargetSkillId"
																															}
																														},
																														{
																															Name = "tCurrentEp",
																															Type = "Self",
																															Value = {
																																field = "tCurrentEp"
																															}
																														},
																														{
																															Name = "tTeammateId1",
																															Type = "Self",
																															Value = {
																																field = "tTeammateId1"
																															}
																														},
																														{
																															Name = "tTeammateId2",
																															Type = "Self",
																															Value = {
																																field = "tTeammateId2"
																															}
																														},
																														{
																															Name = "tTeammateId3",
																															Type = "Self",
																															Value = {
																																field = "tTeammateId3"
																															}
																														},
																														{
																															Name = "tCurrentBreakPercent",
																															Type = "Self",
																															Value = {
																																field = "tCurrentBreakPercent"
																															}
																														},
																														{
																															Name = "tCurrentSp",
																															Type = "Self",
																															Value = {
																																field = "tCurrentSp"
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
																						}
																					}
																				}
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
												class = "Action",
												id = "80",
												properties = {
													{
														Method = {
															func = "waitTime",
															params = {
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
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
}

return PBT_BotPlayer_Assist_Combat
