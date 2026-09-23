-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_Com_Happy_New.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Com_Happy_New = {
	behavior = {
		agenttype = "CombatAgent",
		name = "ParmonBehaviorTree/SubTree/PBT_Com_Happy_New",
		version = 6,
		useForRoute = false,
		properties = {},
		pars = {
			{
				type = "float",
				value = "5",
				name = "tAnimationTimeout",
				const = 5
			},
			{
				type = "string",
				value = "",
				name = "tTimelineTag",
				const = ""
			},
			{
				type = "bool",
				value = "false",
				name = "tNeedLoop",
				const = false
			},
			{
				type = "bool",
				value = "false",
				name = "tPlayOnce",
				const = false
			}
		},
		attachments = {},
		node = {
			class = "Sequence",
			id = "11",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						class = "Action",
						id = "10",
						properties = {
							{
								Method = {
									func = "showEmojiBubble",
									params = {
										{
											const = "Happy"
										},
										{
											field = "tAnimationTimeout"
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
						id = "8",
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
												id = "9",
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
												id = "5",
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
																	field = "tAnimationTimeout"
																},
																{
																	field = "tTimelineTag"
																},
																{
																	field = "tPlayOnce"
																},
																{
																	field = "tNeedLoop"
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
									id = "6",
									properties = {
										{
											Method = {
												func = "playAction",
												params = {
													{
														const = "Behav_Happy"
													},
													{
														field = "tAnimationTimeout"
													},
													{
														field = "tTimelineTag"
													},
													{
														field = "tNeedLoop"
													},
													{
														field = "tPlayOnce"
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

return PBT_Com_Happy_New
