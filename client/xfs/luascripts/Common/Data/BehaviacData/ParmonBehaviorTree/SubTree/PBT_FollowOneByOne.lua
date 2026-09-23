-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_FollowOneByOne.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_FollowOneByOne = {
	behavior = {
		version = 14,
		useForRoute = false,
		agenttype = "CombatAgent",
		name = "ParmonBehaviorTree/SubTree/PBT_FollowOneByOne",
		properties = {},
		pars = {
			{
				const = 0,
				type = "int",
				name = "tFollowEntActorID",
				value = "0"
			},
			{
				const = 2,
				type = "float",
				name = "tFollowStopDist",
				value = "2"
			},
			{
				const = 0,
				type = "float",
				name = "tStartFollowDist",
				value = "0"
			}
		},
		attachments = {},
		node = {
			id = "1",
			class = "DecoratorLoop",
			properties = {
				{
					Count = {
						const = -1
					}
				},
				{
					DecorateWhenChildEnds = "false"
				},
				{
					DoneWithinFrame = "false"
				}
			},
			attachments = {},
			children = {
				{
					node = {
						id = "2",
						class = "Sequence",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									id = "4",
									class = "Compute",
									properties = {
										{
											Operator = "Add"
										},
										{
											Opl = {
												field = "tStartFollowDist"
											}
										},
										{
											Opr1 = {
												field = "tFollowStopDist"
											}
										},
										{
											Opr2 = {
												const = 1.5
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
									class = "IfElse",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "6",
												class = "Condition",
												properties = {
													{
														Operator = "Greater"
													},
													{
														Opl = {
															func = "getDistByTgt",
															params = {
																{
																	field = "tFollowEntActorID"
																},
																{
																	const = false
																},
																{
																	const = false
																},
																{
																	const = 0
																}
															}
														}
													},
													{
														Opr = {
															field = "tStartFollowDist"
														}
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
															func = "moveToTarget",
															params = {
																{
																	field = "tFollowEntActorID"
																},
																{
																	field = "tFollowStopDist"
																},
																{
																	const = 5
																},
																{
																	const = false
																},
																{
																	const = true
																},
																{
																	const = false
																},
																{
																	const = 0
																},
																{
																	const = BaseEnum.MoveUpdateLevel.VeryFast
																},
																{
																	const = BaseEnum.PathFindType.Auto
																},
																{
																	const = BaseEnum.SpeedRateType.Mid
																},
																{
																	const = 0
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
												id = "7",
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

return PBT_FollowOneByOne
