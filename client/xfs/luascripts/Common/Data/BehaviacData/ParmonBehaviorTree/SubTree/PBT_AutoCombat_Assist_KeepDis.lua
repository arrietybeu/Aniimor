-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_AutoCombat_Assist_KeepDis.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_AutoCombat_Assist_KeepDis = {
	behavior = {
		version = 33,
		useForRoute = false,
		name = "ParmonBehaviorTree/SubTree/PBT_AutoCombat_Assist_KeepDis",
		agenttype = "PetAgent",
		properties = {},
		pars = {
			{
				const = 0,
				type = "float",
				name = "goBackDist",
				value = "0"
			},
			{
				const = 0,
				type = "float",
				name = "CurrentDistToTarget",
				value = "0"
			},
			{
				const = 0,
				type = "float",
				name = "CurrentBoxDistToTarget",
				value = "0"
			}
		},
		attachments = {},
		node = {
			id = "25",
			class = "Sequence",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						id = "26",
						class = "Condition",
						properties = {
							{
								Operator = "LessEqual"
							},
							{
								Opl = {
									field = "CurrentDistToTarget"
								}
							},
							{
								Opr = {
									field = "minAttackDist"
								}
							}
						},
						attachments = {},
						children = {}
					}
				},
				{
					node = {
						id = "27",
						class = "Condition",
						properties = {
							{
								Operator = "NotEqual"
							},
							{
								Opl = {
									func = "isGoBackCd"
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
						id = "14",
						class = "Sequence",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									id = "35",
									class = "Condition",
									properties = {
										{
											Operator = "NotEqual"
										},
										{
											Opl = {
												func = "checkCharacterState",
												params = {
													{
														const = "SPECIALDEFENSE"
													},
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
									id = "67",
									class = "And",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "36",
												class = "Condition",
												properties = {
													{
														Operator = "NotEqual"
													},
													{
														Opl = {
															func = "checkNormalAttackByTags",
															params = {
																{
																	field = "selfId"
																},
																{
																	const = 0
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
												id = "68",
												class = "Condition",
												properties = {
													{
														Operator = "Equal"
													},
													{
														Opl = {
															func = "checkIsBreakST",
															params = {
																{
																	field = "tgt"
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
									id = "15",
									class = "Compute",
									properties = {
										{
											Operator = "Sub"
										},
										{
											Opl = {
												field = "goBackDist"
											}
										},
										{
											Opr1 = {
												field = "attackStopBoxDist"
											}
										},
										{
											Opr2 = {
												field = "CurrentBoxDistToTarget"
											}
										}
									},
									attachments = {},
									children = {}
								}
							},
							{
								node = {
									id = "16",
									class = "IfElse",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "18",
												class = "Condition",
												properties = {
													{
														Operator = "Greater"
													},
													{
														Opl = {
															func = "getRandomInt",
															params = {
																{
																	const = 0
																},
																{
																	const = 100
																}
															}
														}
													},
													{
														Opr = {
															const = 50
														}
													}
												},
												attachments = {},
												children = {}
											}
										},
										{
											node = {
												id = "17",
												class = "Action",
												properties = {
													{
														Method = {
															func = "jumpBackByLinkAngle",
															params = {
																{
																	field = "tgt"
																},
																{
																	const = 45
																},
																{
																	field = "goBackDist"
																},
																{
																	const = BaseEnum.RootMotionSyncPointEnum.AICustomPoint1
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
												id = "19",
												class = "Action",
												properties = {
													{
														Method = {
															func = "jumpBackByLinkAngle",
															params = {
																{
																	field = "tgt"
																},
																{
																	const = -45
																},
																{
																	field = "goBackDist"
																},
																{
																	const = BaseEnum.RootMotionSyncPointEnum.AICustomPoint1
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
									id = "65",
									class = "ReferencedBehavior",
									properties = {
										{
											ReferenceBehavior = {
												const = "PBT_AutoCombat_NormalAtkCombo"
											}
										},
										{
											subTreeProperties = {
												{
													Type = "Self",
													Name = "CurrentDistToTarget",
													Value = {
														field = "CurrentDistToTarget"
													}
												},
												{
													Type = "Self",
													Name = "CurrentBoxDistToTarget",
													Value = {
														field = "CurrentBoxDistToTarget"
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

return PBT_AutoCombat_Assist_KeepDis
