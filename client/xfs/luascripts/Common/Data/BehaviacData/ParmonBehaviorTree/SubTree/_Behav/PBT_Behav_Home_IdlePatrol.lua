-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\_Behav\\PBT_Behav_Home_IdlePatrol.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Behav_Home_IdlePatrol = {
	behavior = {
		useForRoute = false,
		agenttype = "CombatAgent",
		name = "ParmonBehaviorTree/SubTree/_Behav/PBT_Behav_Home_IdlePatrol",
		version = 53,
		properties = {},
		pars = {
			{
				name = "tTargetActorId",
				const = 0,
				type = "int",
				value = "0"
			},
			{
				name = "tBornPos",
				type = "vector<float>",
				value = "0:",
				const = {}
			}
		},
		attachments = {},
		node = {
			id = "85",
			class = "DecoratorLoop",
			properties = {
				{
					Count = {
						const = -1
					}
				},
				{
					DecorateWhenChildEnds = "true"
				},
				{
					DoneWithinFrame = "false"
				}
			},
			attachments = {},
			children = {
				{
					node = {
						id = "55",
						class = "Selector",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									id = "84",
									class = "Sequence",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "42",
												class = "Action",
												properties = {
													{
														Method = {
															func = "patrolInHomeland",
															params = {
																{
																	const = 3
																},
																{
																	const = 5
																},
																{
																	const = BaseEnum.SpeedRateType.Slow
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
														ResultResumeOption = "BT_ResumeSelf"
													}
												},
												attachments = {},
												children = {}
											}
										},
										{
											node = {
												id = "13",
												class = "Assignment",
												properties = {
													{
														CastRight = "false"
													},
													{
														Opl = {
															field = "patrolWeight"
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
										}
									}
								}
							},
							{
								node = {
									id = "69",
									class = "Sequence",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "74",
												class = "Action",
												properties = {
													{
														Method = {
															func = "waitTime",
															params = {
																{
																	const = 2
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
												id = "82",
												class = "Assignment",
												properties = {
													{
														CastRight = "false"
													},
													{
														Opl = {
															field = "tBornPos"
														}
													},
													{
														Opr = {
															func = "getBornPos"
														}
													}
												},
												attachments = {},
												children = {}
											}
										},
										{
											node = {
												id = "73",
												class = "Action",
												properties = {
													{
														Method = {
															func = "patrolInHomeland",
															params = {
																{
																	const = 3
																},
																{
																	const = 5
																},
																{
																	const = BaseEnum.SpeedRateType.Slow
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
									id = "77",
									class = "Action",
									properties = {
										{
											Method = {
												func = "teleportToPosition",
												params = {
													{
														field = "tBornPos"
													},
													{
														const = true
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

return PBT_Behav_Home_IdlePatrol
