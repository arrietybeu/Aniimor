-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_Sleep.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Sleep = {
	behavior = {
		useForRoute = true,
		version = 6,
		agenttype = "CombatAgent",
		name = "ParmonBehaviorTree/SubTree/PBT_Sleep",
		properties = {},
		pars = {
			{
				value = "7",
				type = "float",
				const = 7,
				name = "sleepTimeOut"
			},
			{
				value = "true",
				type = "bool",
				const = true,
				name = "tShowEmojiBubble"
			},
			{
				value = "false",
				type = "bool",
				const = false,
				name = "tisLoop"
			}
		},
		attachments = {},
		node = {
			id = "11",
			class = "Sequence",
			properties = {},
			attachments = {
				{
					transition = false,
					id = "8",
					class = "Effector",
					effector = true,
					precondition = false,
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
					id = "10",
					class = "Effector",
					effector = true,
					precondition = false,
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
						id = "13",
						class = "Action",
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
						id = "5",
						class = "Action",
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
						id = "7",
						class = "IfElse",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									id = "8",
									class = "Condition",
									properties = {
										{
											Operator = "Equal"
										},
										{
											Opl = {
												field = "tShowEmojiBubble"
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
									id = "2",
									class = "Action",
									properties = {
										{
											Method = {
												func = "showEmojiBubble",
												params = {
													{
														const = "Sleep"
													},
													{
														field = "sleepTimeOut"
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
							},
							{
								node = {
									id = "9",
									class = "True",
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
						id = "3",
						class = "Action",
						properties = {
							{
								Method = {
									func = "playPhaseAction",
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
										},
										{
											const = ""
										},
										{
											const = false
										},
										{
											field = "tisLoop"
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
						attachments = {
							{
								transition = false,
								id = "10",
								class = "Effector",
								effector = true,
								precondition = false,
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
						children = {}
					}
				}
			}
		}
	}
}

return PBT_Sleep
