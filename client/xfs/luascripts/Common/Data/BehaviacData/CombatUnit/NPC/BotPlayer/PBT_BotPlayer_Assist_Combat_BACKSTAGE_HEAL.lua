-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\CombatUnit\\NPC\\BotPlayer\\PBT_BotPlayer_Assist_Combat_BACKSTAGE_HEAL.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_BotPlayer_Assist_Combat_BACKSTAGE_HEAL = {
	behavior = {
		name = "CombatUnit/NPC/BotPlayer/PBT_BotPlayer_Assist_Combat_BACKSTAGE_HEAL",
		useForRoute = false,
		version = 102,
		agenttype = "BotPlayerAgent",
		properties = {},
		pars = {
			{
				name = "tCurrentPet",
				const = 0,
				type = "int",
				value = "0"
			},
			{
				name = "tCurrentPetHpPercent",
				const = 0,
				type = "float",
				value = "0"
			},
			{
				name = "tSwitchPetId",
				const = 0,
				type = "int",
				value = "0"
			},
			{
				name = "tTargetSkillId",
				const = 0,
				type = "int",
				value = "0"
			},
			{
				name = "tCurrentEp",
				const = 0,
				type = "float",
				value = "0"
			},
			{
				name = "tTeammateId1",
				const = 0,
				type = "int",
				value = "0"
			},
			{
				name = "tTeammateId2",
				const = 0,
				type = "int",
				value = "0"
			},
			{
				name = "tTeammateId3",
				const = 0,
				type = "int",
				value = "0"
			},
			{
				name = "tCurrentBreakPercent",
				const = 0,
				type = "float",
				value = "0"
			},
			{
				name = "tCurrentSp",
				const = 0,
				type = "float",
				value = "0"
			},
			{
				name = "tSupportSkillId",
				const = 0,
				type = "int",
				value = "0"
			},
			{
				name = "tMaxSkillDist",
				const = 0,
				type = "float",
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
						id = "368",
						class = "Selector",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									id = "369",
									class = "Condition",
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
												const = 0.5
											}
										}
									},
									attachments = {},
									children = {}
								}
							},
							{
								node = {
									id = "370",
									class = "Or",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "371",
												class = "Condition",
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
															const = 0.5
														}
													}
												},
												attachments = {},
												children = {}
											}
										},
										{
											node = {
												id = "365",
												class = "Condition",
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
															const = 0.5
														}
													}
												},
												attachments = {},
												children = {}
											}
										},
										{
											node = {
												id = "366",
												class = "Condition",
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
															const = 0.5
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
						id = "385",
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
						id = "394",
						class = "Selector",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									id = "387",
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
														const = "HEAL"
													},
													{
														const = 2
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
									id = "389",
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
														const = "HEAL"
													},
													{
														const = 3
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
						id = "386",
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
									const = "Tactics_SupportSkill"
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
						class = "Or",
						properties = {},
						attachments = {},
						children = {
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
												func = "checkSupportSkillCanCast",
												params = {
													{
														const = 0
													},
													{
														const = "HEAL"
													},
													{
														const = 2
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
									id = "392",
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
														const = "HEAL"
													},
													{
														const = 3
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
							}
						}
					}
				},
				{
					node = {
						id = "364",
						class = "Selector",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									id = "363",
									class = "Action",
									properties = {
										{
											Method = {
												func = "tryCommandPetCastSupportSkill",
												params = {
													{
														const = "HEAL"
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
									id = "372",
									class = "Action",
									properties = {
										{
											Method = {
												func = "tryCommandPetCastSupportSkill",
												params = {
													{
														const = "HEAL"
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
							}
						}
					}
				}
			}
		}
	}
}

return PBT_BotPlayer_Assist_Combat_BACKSTAGE_HEAL
