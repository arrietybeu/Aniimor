-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\CombatUnit\\NPC\\BotPlayer\\PBT_BotPlayer_Assist_Combat_BACKSTAGE_DPS.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_BotPlayer_Assist_Combat_BACKSTAGE_DPS = {
	behavior = {
		useForRoute = false,
		agenttype = "BotPlayerAgent",
		name = "CombatUnit/NPC/BotPlayer/PBT_BotPlayer_Assist_Combat_BACKSTAGE_DPS",
		version = 101,
		properties = {},
		pars = {
			{
				type = "int",
				name = "tCurrentPet",
				const = 0,
				value = "0"
			},
			{
				type = "float",
				name = "tCurrentPetHpPercent",
				const = 0,
				value = "0"
			},
			{
				type = "int",
				name = "tSwitchPetId",
				const = 0,
				value = "0"
			},
			{
				type = "int",
				name = "tTargetSkillId",
				const = 0,
				value = "0"
			},
			{
				type = "float",
				name = "tCurrentEp",
				const = 0,
				value = "0"
			},
			{
				type = "int",
				name = "tTeammateId1",
				const = 0,
				value = "0"
			},
			{
				type = "int",
				name = "tTeammateId2",
				const = 0,
				value = "0"
			},
			{
				type = "int",
				name = "tTeammateId3",
				const = 0,
				value = "0"
			},
			{
				type = "float",
				name = "tCurrentBreakPercent",
				const = 0,
				value = "0"
			},
			{
				type = "float",
				name = "tCurrentSp",
				const = 0,
				value = "0"
			},
			{
				type = "int",
				name = "tSupportSkillId",
				const = 0,
				value = "0"
			},
			{
				type = "float",
				name = "tMaxSkillDist",
				const = 0,
				value = "0"
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
						id = "392",
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
						id = "393",
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
						id = "395",
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
											const = "DPS"
										},
										{
											const = 0
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
						id = "394",
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
									const = "Tactics_SupportSkill_DPS"
								}
							}
						},
						attachments = {},
						children = {}
					}
				},
				{
					node = {
						id = "396",
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
											const = "DPS"
										},
										{
											const = 0
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
						id = "403",
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
											const = "DPS"
										},
										{
											const = 0
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
						id = "405",
						class = "Condition",
						properties = {
							{
								Operator = "NotEqual"
							},
							{
								Opl = {
									field = "tSupportSkillId"
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
						id = "398",
						class = "Selector",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									id = "401",
									class = "Sequence",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "404",
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
												id = "402",
												class = "Sequence",
												properties = {},
												attachments = {
													{
														class = "Precondition",
														id = "474",
														transition = false,
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
															id = "399",
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
									id = "408",
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
												id = "400",
												class = "Action",
												properties = {
													{
														Method = {
															func = "tryCommandPetCastSupportSkill",
															params = {
																{
																	const = "DPS"
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

return PBT_BotPlayer_Assist_Combat_BACKSTAGE_DPS
