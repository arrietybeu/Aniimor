-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\_Wild\\_GrabEggs\\PBT_Wild_GrabEggs_ProtectEgg_CheckEgg.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Wild_GrabEggs_ProtectEgg_CheckEgg = {
	behavior = {
		version = 19,
		name = "ParmonBehaviorTree/SubTree/_Wild/_GrabEggs/PBT_Wild_GrabEggs_ProtectEgg_CheckEgg",
		useForRoute = false,
		agenttype = "CombatAgent",
		properties = {},
		pars = {
			{
				type = "int",
				const = 0,
				name = "EggActorId",
				value = "0"
			},
			{
				type = "float",
				const = 0,
				name = "tWaitTime",
				value = "0"
			}
		},
		attachments = {},
		node = {
			class = "Sequence",
			id = "19",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						class = "Action",
						id = "26",
						properties = {
							{
								Method = {
									func = "addEntityTag",
									params = {
										{},
										{
											const = "protecteggfirst"
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
						class = "Sequence",
						id = "21",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									class = "Action",
									id = "13",
									properties = {
										{
											Method = {
												func = "moveToTarget",
												params = {
													{
														const = 0
													},
													{
														const = 5
													},
													{
														const = 0
													},
													{
														const = false
													},
													{
														const = false
													},
													{
														const = false
													},
													{
														const = 0
													},
													{
														const = BaseEnum.MoveUpdateLevel.Once
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
									class = "Action",
									id = "20",
									properties = {
										{
											Method = {
												func = "turnToTarget",
												params = {
													{
														const = 0
													},
													{
														const = false
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
									class = "Assignment",
									id = "23",
									properties = {
										{
											CastRight = "true"
										},
										{
											Opl = {
												field = "tWaitTime"
											}
										},
										{
											Opr = {
												func = "getRandomFloat",
												params = {
													{
														const = 3
													},
													{
														const = 5
													}
												}
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
									id = "24",
									properties = {
										{
											Method = {
												func = "waitTime",
												params = {
													{
														field = "tWaitTime"
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

return PBT_Wild_GrabEggs_ProtectEgg_CheckEgg
