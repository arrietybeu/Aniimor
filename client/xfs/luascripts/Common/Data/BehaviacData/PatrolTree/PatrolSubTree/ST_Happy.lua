-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\PatrolTree\\PatrolSubTree\\ST_Happy.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local ST_Happy = {
	behavior = {
		useForRoute = true,
		version = 5,
		name = "PatrolTree/PatrolSubTree/ST_Happy",
		agenttype = "CombatAgent",
		properties = {},
		pars = {},
		attachments = {},
		node = {
			class = "Sequence",
			id = "1",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						class = "Action",
						id = "2",
						properties = {
							{
								Method = {
									func = "showEmojiBubble",
									params = {
										{
											const = "Happy"
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
				},
				{
					node = {
						class = "Selector",
						id = "5",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									class = "Sequence",
									id = "7",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												class = "Condition",
												id = "8",
												properties = {
													{
														Operator = "Equal"
													},
													{
														Opl = {
															func = "hasAnimState",
															params = {
																{
																	const = "Behav_HappyLoop"
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
												class = "Action",
												id = "6",
												properties = {
													{
														Method = {
															func = "playPhaseAction",
															params = {
																{
																	const = "Behav_HappyStart"
																},
																{
																	const = "Behav_HappyLoop"
																},
																{
																	const = "Behav_HappyEnd"
																},
																{
																	const = 0
																},
																{
																	const = ""
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
									id = "4",
									properties = {
										{
											Method = {
												func = "playAction",
												params = {
													{
														const = "Behav_Happy"
													},
													{
														const = 4
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

return ST_Happy
