-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\_Node\\PBT_Node_Com_IdleSpecial.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Node_Com_IdleSpecial = {
	behavior = {
		version = 17,
		name = "ParmonBehaviorTree/SubTree/_Node/PBT_Node_Com_IdleSpecial",
		useForRoute = true,
		agenttype = "CombatAgent",
		properties = {},
		pars = {},
		attachments = {},
		node = {
			class = "Selector",
			id = "37",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						class = "Sequence",
						id = "27",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									class = "Condition",
									id = "28",
									properties = {
										{
											Operator = "Equal"
										},
										{
											Opl = {
												func = "hasAnimState",
												params = {
													{
														const = "IdleSpecial02"
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
							},
							{
								node = {
									class = "Action",
									id = "19",
									properties = {
										{
											Method = {
												func = "playAction",
												params = {
													{
														const = "IdleSpecial"
													},
													{
														const = 0
													},
													{
														const = ""
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
														const = BaseEnum.AIAnimationRootMotionType.Default
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
						class = "Sequence",
						id = "31",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									class = "Condition",
									id = "33",
									properties = {
										{
											Operator = "Equal"
										},
										{
											Opl = {
												func = "hasAnimState",
												params = {
													{
														const = "IdleSpecial"
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
							},
							{
								node = {
									class = "Action",
									id = "21",
									properties = {
										{
											Method = {
												func = "playAction",
												params = {
													{
														const = "IdleSpecial02"
													},
													{
														const = 0
													},
													{
														const = ""
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
														const = BaseEnum.AIAnimationRootMotionType.Default
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
						class = "SelectorProbability",
						id = "35",
						properties = {
							{
								UntilSuccessOrEnd = false
							}
						},
						attachments = {},
						children = {
							{
								node = {
									class = "DecoratorWeight",
									id = "36",
									properties = {
										{
											DecorateWhenChildEnds = "false"
										},
										{
											Weight = {
												const = 1
											}
										}
									},
									attachments = {},
									children = {
										{
											node = {
												class = "Action",
												id = "39",
												properties = {
													{
														Method = {
															func = "playAction",
															params = {
																{
																	const = "IdleSpecial"
																},
																{
																	const = 0
																},
																{
																	const = ""
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
																	const = BaseEnum.AIAnimationRootMotionType.Default
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
									class = "DecoratorWeight",
									id = "40",
									properties = {
										{
											DecorateWhenChildEnds = "false"
										},
										{
											Weight = {
												const = 1
											}
										}
									},
									attachments = {},
									children = {
										{
											node = {
												class = "Action",
												id = "38",
												properties = {
													{
														Method = {
															func = "playAction",
															params = {
																{
																	const = "IdleSpecial02"
																},
																{
																	const = 0
																},
																{
																	const = ""
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
																	const = BaseEnum.AIAnimationRootMotionType.Default
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

return PBT_Node_Com_IdleSpecial
