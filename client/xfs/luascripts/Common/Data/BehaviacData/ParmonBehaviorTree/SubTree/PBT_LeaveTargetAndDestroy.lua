-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_LeaveTargetAndDestroy.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_LeaveTargetAndDestroy = {
	behavior = {
		useForRoute = false,
		agenttype = "CombatAgent",
		name = "ParmonBehaviorTree/SubTree/PBT_LeaveTargetAndDestroy",
		version = 7,
		properties = {},
		pars = {
			{
				name = "tTargetActorId",
				const = 0,
				value = "0",
				type = "int"
			},
			{
				name = "tLeaveDistance",
				const = 5,
				value = "5",
				type = "float"
			},
			{
				name = "tSpeed",
				const = 4,
				value = "4",
				type = "float"
			},
			{
				name = "tSpeedRateType",
				value = "Mid",
				type = "SpeedRateType",
				const = BaseEnum.SpeedRateType.Mid
			},
			{
				name = "tMaxTime",
				const = 10,
				value = "10",
				type = "float"
			},
			{
				name = "tDestroyOnFail",
				const = false,
				value = "false",
				type = "bool"
			}
		},
		attachments = {},
		node = {
			id = "7",
			class = "IfElse",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						id = "5",
						class = "Condition",
						properties = {
							{
								Operator = "Equal"
							},
							{
								Opl = {
									field = "tDestroyOnFail"
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
						id = "4",
						class = "Sequence",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									id = "9",
									class = "Selector",
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
															func = "leaveTarget",
															params = {
																{
																	field = "tTargetActorId"
																},
																{
																	field = "tLeaveDistance"
																},
																{
																	field = "tSpeed"
																},
																{
																	field = "tSpeedRateType"
																},
																{
																	field = "tMaxTime"
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
												id = "11",
												class = "Noop",
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
												func = "enterDestroySelf"
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
							}
						}
					}
				},
				{
					node = {
						id = "10",
						class = "Sequence",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									id = "12",
									class = "Action",
									properties = {
										{
											Method = {
												func = "leaveTarget",
												params = {
													{
														field = "tTargetActorId"
													},
													{
														field = "tLeaveDistance"
													},
													{
														field = "tSpeed"
													},
													{
														field = "tSpeedRateType"
													},
													{
														field = "tMaxTime"
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
									id = "6",
									class = "Action",
									properties = {
										{
											Method = {
												func = "enterDestroySelf"
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
							}
						}
					}
				}
			}
		}
	}
}

return PBT_LeaveTargetAndDestroy
