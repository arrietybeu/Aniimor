-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_MoveToPoint.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_MoveToPoint = {
	behavior = {
		name = "ParmonBehaviorTree/SubTree/PBT_MoveToPoint",
		useForRoute = false,
		version = 5,
		agenttype = "WxAgent",
		properties = {},
		pars = {
			{
				name = "tMovePos",
				type = "vector<float>",
				value = "0:",
				const = {}
			},
			{
				name = "tMoveMaxTime",
				type = "float",
				value = "15",
				const = 15
			},
			{
				name = "tMoveSpeed",
				type = "float",
				value = "-1",
				const = -1
			},
			{
				name = "tBehaviorSpeedRateType",
				type = "SpeedRateType",
				value = "Mid",
				const = BaseEnum.SpeedRateType.Mid
			},
			{
				name = "tUseAccurateArrive",
				type = "bool",
				value = "false",
				const = false
			},
			{
				name = "tTeleportIfCannotMove",
				type = "bool",
				value = "false",
				const = false
			}
		},
		attachments = {},
		node = {
			id = "6",
			class = "Selector",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						id = "4",
						class = "Action",
						properties = {
							{
								Method = {
									func = "moveToPos",
									params = {
										{
											field = "tMovePos"
										},
										{
											field = "tMoveMaxTime"
										},
										{
											const = true
										},
										{
											const = 0
										},
										{
											field = "tBehaviorSpeedRateType"
										},
										{
											field = "tMoveSpeed"
										},
										{
											const = BaseEnum.PathFindType.Auto
										},
										{
											const = false
										},
										{
											field = "tUseAccurateArrive"
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
						id = "8",
						class = "IfElse",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									id = "13",
									class = "Condition",
									properties = {
										{
											Operator = "Equal"
										},
										{
											Opl = {
												field = "tTeleportIfCannotMove"
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
									id = "7",
									class = "Action",
									properties = {
										{
											Method = {
												func = "teleportToPosition",
												params = {
													{
														field = "tMovePos"
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
							},
							{
								node = {
									id = "12",
									class = "DecoratorAlwaysFailure",
									properties = {
										{
											DecorateWhenChildEnds = "false"
										}
									},
									attachments = {},
									children = {
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
							}
						}
					}
				}
			}
		}
	}
}

return PBT_MoveToPoint
