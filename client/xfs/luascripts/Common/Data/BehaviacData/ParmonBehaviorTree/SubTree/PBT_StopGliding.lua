-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_StopGliding.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_StopGliding = {
	behavior = {
		version = 11,
		useForRoute = true,
		agenttype = "WxAgent",
		name = "ParmonBehaviorTree/SubTree/PBT_StopGliding",
		properties = {},
		pars = {
			{
				value = "false",
				const = false,
				type = "bool",
				name = "exitGlidingImmediate"
			}
		},
		attachments = {},
		node = {
			id = "4",
			class = "Sequence",
			properties = {},
			attachments = {},
			children = {
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
									class = "Condition",
									properties = {
										{
											Operator = "Equal"
										},
										{
											Opl = {
												func = "checkCharacterState",
												params = {
													{
														const = "GLIDING"
													},
													{
														const = 0
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
									id = "7",
									class = "Condition",
									properties = {
										{
											Operator = "Equal"
										},
										{
											Opl = {
												field = "exitGlidingImmediate"
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
									id = "9",
									class = "Sequence",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "8",
												class = "Action",
												properties = {
													{
														Method = {
															func = "switchToState",
															params = {
																{
																	const = "AIRING"
																},
																{
																	const = -1
																},
																{
																	const = ""
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
												id = "10",
												class = "Action",
												properties = {
													{
														Method = {
															func = "switchToState",
															params = {
																{
																	const = "LOCOMOTION"
																},
																{
																	const = 0
																},
																{
																	const = ""
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
				},
				{
					node = {
						id = "2",
						class = "Selector",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									id = "3",
									class = "Condition",
									properties = {
										{
											Operator = "Equal"
										},
										{
											Opl = {
												func = "checkCharacterState",
												params = {
													{
														const = "GLIDING"
													},
													{
														const = 0
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
									id = "1",
									class = "Action",
									properties = {
										{
											Method = {
												func = "switchToState",
												params = {
													{
														const = "LOCOMOTION"
													},
													{
														const = 0
													},
													{
														const = ""
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

return PBT_StopGliding
