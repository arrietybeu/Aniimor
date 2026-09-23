-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\CombatUnit\\NPC\\BotPlayer\\PBT_BotPlayer_Assist_Combat_BACKSTAGE_SUP.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_BotPlayer_Assist_Combat_BACKSTAGE_SUP = {
	behavior = {
		version = 110,
		agenttype = "BotPlayerAgent",
		useForRoute = false,
		name = "CombatUnit/NPC/BotPlayer/PBT_BotPlayer_Assist_Combat_BACKSTAGE_SUP",
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
			},
			{
				type = "int",
				value = "0",
				const = 0,
				name = "tTeammateId1"
			},
			{
				type = "int",
				value = "0",
				const = 0,
				name = "tTeammateId2"
			},
			{
				type = "int",
				value = "0",
				const = 0,
				name = "tTeammateId3"
			},
			{
				type = "float",
				value = "0",
				const = 0,
				name = "tCurrentBreakPercent"
			},
			{
				type = "float",
				value = "0",
				const = 0,
				name = "tCurrentSp"
			},
			{
				type = "bool",
				value = "false",
				const = false,
				name = "IsNegative"
			},
			{
				type = "float",
				value = "0",
				const = 0,
				name = "tMaxSkillDist"
			},
			{
				type = "int",
				value = "0",
				const = 0,
				name = "tSupportSkillId"
			}
		},
		attachments = {},
		node = {
			id = "367",
			class = "Sequence",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						id = "391",
						class = "Or",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									id = "383",
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
									id = "392",
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
							}
						}
					}
				},
				{
					node = {
						id = "388",
						class = "Selector",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									id = "384",
									class = "Condition",
									properties = {
										{
											Operator = "Equal"
										},
										{
											Opl = {
												func = "checkTargetHasBuffTag",
												params = {
													{
														field = "tCurrentPet"
													},
													{
														const = "Positive"
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
									id = "408",
									class = "Selector",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "386",
												class = "Sequence",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "385",
															class = "Condition",
															properties = {
																{
																	Operator = "Equal"
																},
																{
																	Opl = {
																		func = "checkTargetHasBuffTag",
																		params = {
																			{
																				field = "tCurrentPet"
																			},
																			{
																				const = "Positive"
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
															id = "389",
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
															id = "390",
															class = "Condition",
															properties = {
																{
																	Operator = "NotEqual"
																},
																{
																	Opl = {
																		field = "tSwitchPetId"
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
															id = "382",
															class = "Condition",
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
																				field = "tSwitchPetId"
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
												id = "412",
												class = "Sequence",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "407",
															class = "Condition",
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
															id = "410",
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
															id = "411",
															class = "Condition",
															properties = {
																{
																	Operator = "NotEqual"
																},
																{
																	Opl = {
																		field = "tSwitchPetId"
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
															id = "409",
															class = "Condition",
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
																				field = "tSwitchPetId"
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
							}
						}
					}
				},
				{
					node = {
						id = "402",
						class = "Condition",
						properties = {
							{
								Operator = "NotEqual"
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
						id = "413",
						class = "Selector",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									id = "404",
									class = "Condition",
									properties = {
										{
											Operator = "Equal"
										},
										{
											Opl = {
												func = "checkSupportSkillCanCast",
												params = {
													{
														const = 0
													},
													{
														const = "SUP"
													},
													{
														const = 6
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
									id = "414",
									class = "Condition",
									properties = {
										{
											Operator = "Equal"
										},
										{
											Opl = {
												func = "checkSupportSkillCanCast",
												params = {
													{
														const = 0
													},
													{
														const = "SUP"
													},
													{
														const = 7
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
						id = "403",
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
									const = "Tactics_SupportSkill_SUP"
								}
							}
						},
						attachments = {},
						children = {}
					}
				},
				{
					node = {
						id = "415",
						class = "Selector",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									id = "405",
									class = "Condition",
									properties = {
										{
											Operator = "Equal"
										},
										{
											Opl = {
												func = "checkSupportSkillCanCast",
												params = {
													{
														const = 0
													},
													{
														const = "SUP"
													},
													{
														const = 6
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
							},
							{
								node = {
									id = "427",
									class = "Sequence",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "416",
												class = "Condition",
												properties = {
													{
														Operator = "Equal"
													},
													{
														Opl = {
															func = "checkSupportSkillCanCast",
															params = {
																{
																	const = 0
																},
																{
																	const = "SUP"
																},
																{
																	const = 7
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
										},
										{
											node = {
												id = "428",
												class = "Assignment",
												properties = {
													{
														CastRight = "false"
													},
													{
														Opl = {
															field = "IsNegative"
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
							}
						}
					}
				},
				{
					node = {
						id = "429",
						class = "IfElse",
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
												field = "IsNegative"
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
									id = "417",
									class = "Selector",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "425",
												class = "Sequence",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "432",
															class = "Assignment",
															properties = {
																{
																	CastRight = "false"
																},
																{
																	Opl = {
																		field = "tSupportSkillId"
																	}
																},
																{
																	Opr = {
																		func = "getCanCastSupportSkillId",
																		params = {
																			{
																				const = 0
																			},
																			{
																				const = "SUP"
																			},
																			{
																				const = 7
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
															id = "423",
															class = "Assignment",
															properties = {
																{
																	CastRight = "false"
																},
																{
																	Opl = {
																		field = "tMaxSkillDist"
																	}
																},
																{
																	Opr = {
																		func = "getMaxSkillDist",
																		params = {
																			{
																				field = "tSupportSkillId"
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
															id = "424",
															class = "Sequence",
															properties = {},
															attachments = {
																{
																	effector = false,
																	precondition = true,
																	id = "474",
																	class = "Precondition",
																	transition = false,
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
																				field = "tMaxSkillDist"
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
																		id = "426",
																		class = "Action",
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
										},
										{
											node = {
												id = "434",
												class = "Sequence",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "433",
															class = "Condition",
															properties = {
																{
																	Operator = "LessEqual"
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
																		field = "tMaxSkillDist"
																	}
																}
															},
															attachments = {},
															children = {}
														}
													},
													{
														node = {
															id = "418",
															class = "Action",
															properties = {
																{
																	Method = {
																		func = "tryCommandPetCastSupportSkill",
																		params = {
																			{
																				const = "SUP"
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
									id = "381",
									class = "Action",
									properties = {
										{
											Method = {
												func = "tryCommandPetCastSupportSkill",
												params = {
													{
														const = "SUP"
													},
													{
														const = 6
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

return PBT_BotPlayer_Assist_Combat_BACKSTAGE_SUP
