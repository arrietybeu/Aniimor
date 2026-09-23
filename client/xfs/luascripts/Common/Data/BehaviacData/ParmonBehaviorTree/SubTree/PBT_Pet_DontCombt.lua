-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_Pet_DontCombt.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Pet_DontCombt = {
	behavior = {
		useForRoute = false,
		agenttype = "PetAgent",
		name = "ParmonBehaviorTree/SubTree/PBT_Pet_DontCombt",
		version = 5,
		properties = {},
		pars = {
			{
				type = "int",
				const = 0,
				value = "0",
				name = "tTargetActorId"
			}
		},
		attachments = {},
		node = {
			id = "10",
			class = "Sequence",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						id = "19",
						class = "Selector",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									id = "14",
									class = "Action",
									properties = {
										{
											Method = {
												func = "followEntity",
												params = {
													{
														field = "masterId"
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
											ResultResumeOption = "BT_ResumeTree"
										}
									},
									attachments = {
										{
											transition = false,
											effector = false,
											precondition = true,
											id = "15",
											class = "Precondition",
											properties = {
												{
													BinaryOperator = "And"
												},
												{
													Operator = "LessEqual"
												},
												{
													Opl = {
														func = "getDistByTgt",
														params = {
															{
																field = "masterId"
															},
															{
																const = true
															},
															{
																const = true
															},
															{
																const = 0
															}
														}
													}
												},
												{
													Opr2 = {
														const = 1
													}
												},
												{
													Phase = "Both"
												}
											}
										}
									},
									children = {}
								}
							},
							{
								node = {
									id = "20",
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
						id = "5",
						class = "Selector",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									id = "1",
									class = "DecoratorAlwaysRunning",
									properties = {
										{
											DecorateWhenChildEnds = "false"
										}
									},
									attachments = {
										{
											transition = false,
											effector = false,
											precondition = true,
											id = "4",
											class = "Precondition",
											properties = {
												{
													BinaryOperator = "And"
												},
												{
													Operator = "Equal"
												},
												{
													Opl = {
														func = "getTarget"
													}
												},
												{
													Opr2 = {
														field = "tTargetActorId"
													}
												},
												{
													Phase = "Both"
												}
											}
										},
										{
											transition = false,
											effector = false,
											precondition = true,
											id = "3",
											class = "Precondition",
											properties = {
												{
													BinaryOperator = "And"
												},
												{
													Operator = "Equal"
												},
												{
													Opl = {
														func = "checkDontCombat",
														params = {
															{
																field = "tTargetActorId"
															}
														}
													}
												},
												{
													Opr2 = {
														const = true
													}
												},
												{
													Phase = "Both"
												}
											}
										}
									},
									children = {
										{
											node = {
												id = "2",
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
									id = "9",
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

return PBT_Pet_DontCombt
