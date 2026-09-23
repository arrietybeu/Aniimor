-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\PatrolTree\\PatrolSubTree\\ST_Sleep.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local ST_Sleep = {
	behavior = {
		useForRoute = true,
		agenttype = "CombatAgent",
		version = 10,
		name = "PatrolTree/PatrolSubTree/ST_Sleep",
		properties = {},
		pars = {
			{
				const = 7,
				type = "float",
				value = "7",
				name = "sleepTimeOut"
			},
			{
				const = false,
				type = "bool",
				value = "false",
				name = "tIsLoop"
			},
			{
				const = 0,
				type = "int",
				value = "0",
				name = "tDialogueId"
			}
		},
		attachments = {},
		node = {
			class = "Sequence",
			id = "1",
			properties = {},
			attachments = {
				{
					transition = false,
					class = "Effector",
					effector = true,
					precondition = false,
					id = "8",
					properties = {
						{
							Operator = "Invalid"
						},
						{
							Opl = {
								func = "removeEntityTag",
								params = {
									{
										field = "selfId"
									},
									{
										const = "TE_Par_Sleep"
									}
								}
							}
						},
						{
							Phase = "Both"
						}
					}
				},
				{
					transition = false,
					class = "Effector",
					effector = true,
					precondition = false,
					id = "10",
					properties = {
						{
							Operator = "Invalid"
						},
						{
							Opl = {
								func = "setVisionAreaOverride",
								params = {
									{
										const = "visionAreaDefault"
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
			children = {
				{
					node = {
						class = "Action",
						id = "11",
						properties = {
							{
								Method = {
									func = "addEntityTag",
									params = {
										{
											field = "selfId"
										},
										{
											const = "TE_Par_Sleep"
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
						class = "Action",
						id = "5",
						properties = {
							{
								Method = {
									func = "setVisionAreaOverride",
									params = {
										{
											const = "visionAreaLow"
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
						id = "13",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									class = "Condition",
									id = "15",
									properties = {
										{
											Operator = "NotEqual"
										},
										{
											Opl = {
												field = "tDialogueId"
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
									class = "Action",
									id = "12",
									properties = {
										{
											Method = {
												func = "showDialogue",
												params = {
													{
														field = "tDialogueId"
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
									class = "True",
									id = "14",
									properties = {},
									attachments = {},
									children = {}
								}
							}
						}
					}
				},
				{
					node = {
						class = "IfElse",
						id = "20",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									class = "Condition",
									id = "21",
									properties = {
										{
											Operator = "Equal"
										},
										{
											Opl = {
												field = "tIsLoop"
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
									class = "Sequence",
									id = "23",
									properties = {},
									attachments = {
										{
											transition = false,
											class = "Precondition",
											effector = false,
											precondition = true,
											id = "24",
											properties = {
												{
													BinaryOperator = "And"
												},
												{
													Operator = "Equal"
												},
												{
													Opl = {
														field = "tIsLoop"
													}
												},
												{
													Opr2 = {
														const = true
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
												class = "Action",
												id = "22",
												properties = {
													{
														Method = {
															func = "switchToPerformStateMultiTime",
															params = {
																{
																	const = "Behav_SleepStart"
																},
																{
																	const = "Behav_SleepLoop"
																},
																{
																	const = "Behav_SleepEnd"
																},
																{
																	const = 9999
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
									class = "Action",
									id = "19",
									properties = {
										{
											Method = {
												func = "switchToPerformStateFixTime",
												params = {
													{
														const = "Behav_SleepStart"
													},
													{
														const = "Behav_SleepLoop"
													},
													{
														const = "Behav_SleepEnd"
													},
													{
														field = "sleepTimeOut"
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

return ST_Sleep
