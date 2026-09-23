-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\CombatUnit\\Monster\\Root\\Combat\\ST_Monster_AutoCombat_Egg_10029.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local ST_Monster_AutoCombat_Egg_10029 = {
	behavior = {
		useForRoute = false,
		agenttype = "PuppetAgent",
		version = 97,
		name = "CombatUnit/Monster/Root/Combat/ST_Monster_AutoCombat_Egg_10029",
		properties = {},
		pars = {
			{
				type = "float",
				const = 0,
				name = "CurrentDistToTarget",
				value = "0"
			},
			{
				type = "float",
				const = 0,
				name = "CurrentBoxDistToTarget",
				value = "0"
			},
			{
				type = "float",
				const = 0,
				name = "goBackDist",
				value = "0"
			},
			{
				type = "float",
				const = 0,
				name = "skillStopDist",
				value = "0"
			},
			{
				type = "int",
				const = 100,
				name = "tWeight_Group_SideWalk",
				value = "100"
			},
			{
				type = "int",
				const = 100,
				name = "tWeight_Group_Wait",
				value = "100"
			},
			{
				type = "int",
				const = 100,
				name = "tWeight_Group_Angry",
				value = "100"
			}
		},
		attachments = {},
		node = {
			id = "344",
			class = "Sequence",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						id = "347",
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
						id = "346",
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
						id = "345",
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
						id = "351",
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
									const = 100
								}
							}
						},
						attachments = {},
						children = {}
					}
				},
				{
					node = {
						id = "352",
						class = "Assignment",
						properties = {
							{
								CastRight = "false"
							},
							{
								Opl = {
									field = "skillCd"
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
						id = "515",
						class = "Sequence",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									id = "516",
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
												id = "520",
												class = "Sequence",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "518",
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
																				const = 0.2
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
															id = "519",
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
																				const = 14330111
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

return ST_Monster_AutoCombat_Egg_10029
