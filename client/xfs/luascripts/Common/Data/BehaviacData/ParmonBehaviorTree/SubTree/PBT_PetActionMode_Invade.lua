-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_PetActionMode_Invade.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_PetActionMode_Invade = {
	behavior = {
		useForRoute = false,
		version = 15,
		agenttype = "PetAgent",
		name = "ParmonBehaviorTree/SubTree/PBT_PetActionMode_Invade",
		properties = {},
		pars = {
			{
				name = "tTargetID",
				const = 0,
				type = "int",
				value = "0"
			},
			{
				name = "CurrentDistToTarget",
				const = 0,
				type = "float",
				value = "0"
			}
		},
		attachments = {},
		node = {
			id = "6",
			class = "Sequence",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						id = "27",
						class = "Sequence",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									id = "7",
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
												field = "tTargetID"
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
												field = "CurrentDistToTarget"
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
							}
						}
					}
				},
				{
					node = {
						id = "11",
						class = "Assignment",
						properties = {
							{
								CastRight = "false"
							},
							{
								Opl = {
									field = "isEnterCombatByInvadeMode"
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
						id = "22",
						class = "IfElse",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									id = "20",
									class = "Condition",
									properties = {
										{
											Operator = "Greater"
										},
										{
											Opl = {
												field = "CurrentDistToTarget"
											}
										},
										{
											Opr = {
												field = "maxAttackDist"
											}
										}
									},
									attachments = {},
									children = {}
								}
							},
							{
								node = {
									id = "23",
									class = "Sequence",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "24",
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
																	field = "attackStopBoxDist"
																},
																{
																	const = 5
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
																	const = BaseEnum.MoveUpdateLevel.Normal
																},
																{
																	const = BaseEnum.PathFindType.Voxel
																},
																{
																	const = BaseEnum.SpeedRateType.Mid
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
														ResultResumeOption = "BT_ResumeTree"
													}
												},
												attachments = {},
												children = {}
											}
										},
										{
											node = {
												id = "25",
												class = "Action",
												properties = {
													{
														Method = {
															func = "castNormalAtkCombo",
															params = {
																{
																	field = "tgt"
																},
																{
																	const = 0
																},
																{
																	const = true
																},
																{
																	const = 1
																},
																{
																	const = true
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
														ResultResumeOption = "BT_ResumeTree"
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
									id = "26",
									class = "Action",
									properties = {
										{
											Method = {
												func = "castNormalAtkCombo",
												params = {
													{
														field = "tgt"
													},
													{
														const = 0
													},
													{
														const = true
													},
													{
														const = 1
													},
													{
														const = true
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
											ResultResumeOption = "BT_ResumeTree"
										}
									},
									attachments = {
										{
											class = "Precondition",
											id = "356",
											effector = false,
											precondition = true,
											transition = false,
											properties = {
												{
													BinaryOperator = "And"
												},
												{
													Operator = "LessEqual"
												},
												{
													Opl = {
														field = "CurrentDistToTarget"
													}
												},
												{
													Opr2 = {
														field = "maxAttackDist"
													}
												},
												{
													Phase = "Update"
												}
											}
										}
									},
									children = {}
								}
							}
						}
					}
				},
				{
					node = {
						id = "16",
						class = "Sequence",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									id = "17",
									class = "Condition",
									properties = {
										{
											Operator = "NotEqual"
										},
										{
											Opl = {
												func = "isInCombat",
												params = {
													{
														field = "selfId"
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
									id = "18",
									class = "Action",
									properties = {
										{
											Method = {
												func = "showEmojiBubble",
												params = {
													{
														const = "Think"
													},
													{
														const = 5
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

return PBT_PetActionMode_Invade
