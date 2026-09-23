-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\CombatUnit\\Monster\\Root\\Combat\\ST_Monster_AutoCombat_Boss_10212_Summon.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local ST_Monster_AutoCombat_Boss_10212_Summon = {
	behavior = {
		useForRoute = false,
		version = 17,
		agenttype = "PuppetAgent",
		name = "CombatUnit/Monster/Root/Combat/ST_Monster_AutoCombat_Boss_10212_Summon",
		properties = {},
		pars = {
			{
				type = "float",
				const = 7,
				value = "7",
				name = "disToTgtForSkillMon"
			},
			{
				type = "float",
				const = 0,
				value = "0",
				name = "goBackDist"
			}
		},
		attachments = {},
		node = {
			id = "154",
			class = "Sequence",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						id = "160",
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
						id = "150",
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
									id = "161",
									class = "IfElse",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "162",
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
												id = "168",
												class = "Selector",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "173",
															class = "Sequence",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		id = "172",
																		class = "Action",
																		properties = {
																			{
																				Method = {
																					func = "turnToTargetAtYaw",
																					params = {
																						{
																							field = "tgt"
																						},
																						{
																							const = 0
																						},
																						{
																							const = false
																						},
																						{
																							const = 5
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
																		id = "155",
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
																							const = 12110300
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
															id = "167",
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
																				const = 3
																			},
																			{
																				const = ""
																			},
																			{
																				const = false
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
												id = "170",
												class = "Selector",
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
																		func = "castSkill",
																		params = {
																			{
																				field = "tgt"
																			},
																			{
																				const = 12110300
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
															id = "169",
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
																				const = 3
																			},
																			{
																				const = ""
																			},
																			{
																				const = false
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
	}
}

return ST_Monster_AutoCombat_Boss_10212_Summon
