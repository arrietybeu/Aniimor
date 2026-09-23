-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_LeaveDestroy.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_LeaveDestroy = {
	behavior = {
		useForRoute = false,
		version = 5,
		agenttype = "CombatAgent",
		name = "ParmonBehaviorTree/SubTree/PBT_LeaveDestroy",
		properties = {},
		pars = {
			{
				name = "tSensorTgtId",
				type = "int",
				value = "0",
				const = 0
			}
		},
		attachments = {},
		node = {
			id = "2",
			class = "Sequence",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						id = "3",
						class = "Condition",
						properties = {
							{
								Operator = "NotEqual"
							},
							{
								Opl = {
									field = "tSensorTgtId"
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
						id = "5",
						class = "Action",
						properties = {
							{
								Method = {
									func = "showQuestionMark",
									params = {
										{
											const = "Orange"
										},
										{
											const = 1.14
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
						id = "4",
						class = "DecoratorTime",
						properties = {
							{
								Time = {
									const = 5000
								}
							},
							{
								DecorateWhenChildEnds = "true"
							}
						},
						attachments = {},
						children = {
							{
								node = {
									id = "7",
									class = "Sequence",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "11",
												class = "Action",
												properties = {
													{
														Method = {
															func = "switchToFly",
															params = {
																{
																	const = 3
																},
																{
																	const = 1
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
												id = "12",
												class = "Action",
												properties = {
													{
														Method = {
															func = "leaveTarget",
															params = {
																{
																	field = "tSensorTgtId"
																},
																{
																	const = 35
																},
																{
																	const = 18
																},
																{
																	const = BaseEnum.SpeedRateType.Mid
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
												class = "Action",
												properties = {
													{
														Method = {
															func = "enterDestroySelf"
														}
													},
													{
														ResultOption = "BT_SUCCESS"
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
		}
	}
}

return PBT_LeaveDestroy
