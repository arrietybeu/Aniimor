-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\PatrolTree\\PatrolSubTree\\ST_MakeLoveForever.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local ST_MakeLoveForever = {
	behavior = {
		name = "PatrolTree/PatrolSubTree/ST_MakeLoveForever",
		version = 16,
		useForRoute = true,
		agenttype = "CombatAgent",
		properties = {},
		pars = {
			{
				const = 7,
				type = "float",
				name = "MakeLoveTimeOut",
				value = "7"
			},
			{
				const = false,
				type = "bool",
				name = "tIsLoop",
				value = "false"
			},
			{
				const = 0,
				type = "int",
				name = "tDialogueId",
				value = "0"
			}
		},
		attachments = {},
		node = {
			id = "1",
			class = "Sequence",
			properties = {},
			attachments = {
				{
					effector = true,
					precondition = false,
					transition = false,
					id = "27",
					class = "Effector",
					properties = {
						{
							Operator = "Invalid"
						},
						{
							Opl = {
								func = "lerpProperty",
								params = {
									{
										const = false
									},
									{
										const = 2
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
						id = "26",
						class = "Action",
						properties = {
							{
								Method = {
									func = "showEmojiBubble",
									params = {
										{
											const = "love"
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
						id = "25",
						class = "Action",
						properties = {
							{
								Method = {
									func = "lerpProperty",
									params = {
										{
											const = true
										},
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
								ResultResumeOption = "BT_None"
							}
						},
						attachments = {},
						children = {}
					}
				},
				{
					node = {
						id = "20",
						class = "IfElse",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									id = "21",
									class = "Condition",
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
									id = "23",
									class = "Sequence",
									properties = {},
									attachments = {
										{
											effector = false,
											precondition = true,
											transition = false,
											id = "24",
											class = "Precondition",
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
												id = "22",
												class = "Action",
												properties = {
													{
														Method = {
															func = "switchToPerformStateMultiTime",
															params = {
																{
																	const = "Behav_MakeLove_Start"
																},
																{
																	const = "Behav_MakeLove_Loop"
																},
																{
																	const = "Behav_MakeLove_End"
																},
																{
																	const = 999
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
									id = "19",
									class = "Action",
									properties = {
										{
											Method = {
												func = "switchToPerformStateFixTime",
												params = {
													{
														const = "Behav_MakeLove_Start"
													},
													{
														const = "Behav_MakeLove_Loop"
													},
													{
														const = "Behav_MakeLove_End"
													},
													{
														const = 999
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

return ST_MakeLoveForever
