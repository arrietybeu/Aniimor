-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\PatrolTree\\PatrolMoveSubTree\\ST_PatrolIntermittentWalk.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local ST_PatrolIntermittentWalk = {
	behavior = {
		useForRoute = false,
		agenttype = "WxAgent",
		name = "PatrolTree/PatrolMoveSubTree/ST_PatrolIntermittentWalk",
		version = 6,
		properties = {},
		pars = {
			{
				type = "vector<float>",
				name = "patrolPos",
				value = "0:",
				const = {}
			},
			{
				type = "float",
				name = "patrolMaxTime",
				const = 0,
				value = "0"
			},
			{
				type = "float",
				name = "tPatrolSpeed",
				const = 0,
				value = "0"
			},
			{
				type = "SpeedRateType",
				name = "tBehaviorSpeedRateType",
				value = "Slow",
				const = BaseEnum.SpeedRateType.Slow
			}
		},
		attachments = {},
		node = {
			class = "Sequence",
			id = "1",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						class = "IfElse",
						id = "9",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									class = "Condition",
									id = "11",
									properties = {
										{
											Operator = "Equal"
										},
										{
											Opl = {
												func = "checkCanFly"
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
									class = "IfElse",
									id = "2",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												class = "Condition",
												id = "4",
												properties = {
													{
														Operator = "Equal"
													},
													{
														Opl = {
															func = "checkPosIsOnGround",
															params = {
																{
																	field = "patrolPos"
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
												id = "7",
												properties = {
													{
														Method = {
															func = "switchToGround"
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
												class = "Action",
												id = "8",
												properties = {
													{
														Method = {
															func = "switchToFly",
															params = {
																{
																	const = 2
																},
																{
																	const = 5
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
									class = "Noop",
									id = "12",
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
						class = "Selector",
						id = "3",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									class = "Action",
									id = "6",
									properties = {
										{
											Method = {
												func = "moveToPos",
												params = {
													{
														field = "patrolPos"
													},
													{
														field = "patrolMaxTime"
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
														field = "tPatrolSpeed"
													},
													{
														const = BaseEnum.PathFindType.Auto
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
											ResultResumeOption = "BT_ResumeSelf"
										}
									},
									attachments = {},
									children = {}
								}
							},
							{
								node = {
									class = "True",
									id = "5",
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

return ST_PatrolIntermittentWalk
