-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_CustomLoopAnimation_Perform.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_CustomLoopAnimation_Perform = {
	behavior = {
		useForRoute = true,
		agenttype = "CombatAgent",
		name = "ParmonBehaviorTree/SubTree/PBT_CustomLoopAnimation_Perform",
		version = 10,
		properties = {},
		pars = {
			{
				type = "float",
				value = "0",
				const = 0,
				name = "tWaitTime"
			},
			{
				type = "string",
				value = "",
				const = "",
				name = "tEmojiBubbleKey"
			},
			{
				type = "float",
				value = "5",
				const = 5,
				name = "tEmojiBubbleTimeout"
			},
			{
				type = "string",
				value = "",
				const = "",
				name = "tAnimationStartKey"
			},
			{
				type = "string",
				value = "",
				const = "",
				name = "tAnimationLoopKey"
			},
			{
				type = "string",
				value = "",
				const = "",
				name = "tAnimationEndKey"
			},
			{
				type = "float",
				value = "5",
				const = 5,
				name = "tAnimationTimeout"
			},
			{
				type = "string",
				value = "",
				const = "",
				name = "tTimelineTag"
			},
			{
				type = "bool",
				value = "false",
				const = false,
				name = "tNeedLoop"
			},
			{
				type = "bool",
				value = "false",
				const = false,
				name = "tAnimationPlayOnce"
			}
		},
		attachments = {},
		node = {
			id = "1",
			class = "Sequence",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						id = "2",
						class = "Action",
						properties = {
							{
								Method = {
									func = "waitTime",
									params = {
										{
											field = "tWaitTime"
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
						id = "3",
						class = "Action",
						properties = {
							{
								Method = {
									func = "showEmojiBubble",
									params = {
										{
											field = "tEmojiBubbleKey"
										},
										{
											field = "tEmojiBubbleTimeout"
										},
										{
											field = "tNeedLoop"
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
						id = "5",
						class = "Selector",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									id = "6",
									class = "Sequence",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "7",
												class = "Condition",
												properties = {
													{
														Operator = "Equal"
													},
													{
														Opl = {
															field = "tNeedLoop"
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
												id = "8",
												class = "Action",
												properties = {
													{
														Method = {
															func = "switchToPerformStateMultiTime",
															params = {
																{
																	field = "tAnimationStartKey"
																},
																{
																	field = "tAnimationLoopKey"
																},
																{
																	field = "tAnimationEndKey"
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
									id = "9",
									class = "Sequence",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "10",
												class = "Condition",
												properties = {
													{
														Operator = "Equal"
													},
													{
														Opl = {
															field = "tAnimationPlayOnce"
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
												id = "11",
												class = "Action",
												properties = {
													{
														Method = {
															func = "switchToPerformStateOnce",
															params = {
																{
																	field = "tAnimationStartKey"
																},
																{
																	field = "tAnimationLoopKey"
																},
																{
																	field = "tAnimationEndKey"
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
									id = "12",
									class = "Action",
									properties = {
										{
											Method = {
												func = "switchToPerformStateFixTime",
												params = {
													{
														field = "tAnimationStartKey"
													},
													{
														field = "tAnimationLoopKey"
													},
													{
														field = "tAnimationEndKey"
													},
													{
														field = "tAnimationTimeout"
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

return PBT_CustomLoopAnimation_Perform
