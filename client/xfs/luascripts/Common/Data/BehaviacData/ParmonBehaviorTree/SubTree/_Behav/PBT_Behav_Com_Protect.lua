-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\_Behav\\PBT_Behav_Com_Protect.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Behav_Com_Protect = {
	behavior = {
		useForRoute = false,
		version = 5,
		agenttype = "CombatAgent",
		name = "ParmonBehaviorTree/SubTree/_Behav/PBT_Behav_Com_Protect",
		properties = {},
		pars = {
			{
				value = "0",
				type = "int",
				const = 0,
				name = "tProtectActorId"
			},
			{
				value = "0",
				type = "int",
				const = 0,
				name = "tEnemyActorId"
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
						id = "1",
						class = "ReferencedBehavior",
						properties = {
							{
								ReferenceBehavior = {
									const = "PBT_Node_Com_SensedAlert"
								}
							},
							{
								subTreeProperties = {}
							}
						},
						attachments = {},
						children = {}
					}
				},
				{
					node = {
						id = "8",
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
									id = "9",
									class = "Sequence",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "7",
												class = "Action",
												properties = {
													{
														Method = {
															func = "moveToProtect",
															params = {
																{
																	field = "tProtectActorId"
																},
																{
																	field = "tEnemyActorId"
																},
																{
																	const = 3
																},
																{
																	const = 10
																},
																{
																	const = false
																},
																{
																	const = 0
																},
																{
																	const = BaseEnum.SpeedRateType.Mid
																},
																{
																	const = BaseEnum.PathFindType.Auto
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
												id = "10",
												class = "Action",
												properties = {
													{
														Method = {
															func = "turnToTarget",
															params = {
																{
																	field = "tEnemyActorId"
																},
																{
																	const = false
																},
																{
																	const = 2
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
												id = "3",
												class = "ReferencedBehavior",
												properties = {
													{
														ReferenceBehavior = {
															const = "PBT_Com_Angry"
														}
													},
													{
														subTreeProperties = {}
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

return PBT_Behav_Com_Protect
