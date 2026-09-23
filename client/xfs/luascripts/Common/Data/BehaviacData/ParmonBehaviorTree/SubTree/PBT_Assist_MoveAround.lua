-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_Assist_MoveAround.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Assist_MoveAround = {
	behavior = {
		useForRoute = false,
		version = 11,
		agenttype = "CombatAgent",
		name = "ParmonBehaviorTree/SubTree/PBT_Assist_MoveAround",
		properties = {},
		pars = {},
		attachments = {},
		node = {
			id = "14",
			class = "SelectorProbability",
			properties = {
				{
					UntilSuccessOrEnd = false
				}
			},
			attachments = {},
			children = {
				{
					node = {
						id = "13",
						class = "DecoratorWeight",
						properties = {
							{
								DecorateWhenChildEnds = "false"
							},
							{
								Weight = {
									const = 1
								}
							}
						},
						attachments = {},
						children = {
							{
								node = {
									id = "12",
									class = "Action",
									properties = {
										{
											Method = {
												func = "moveAroundTarget",
												params = {
													{
														field = "tgt"
													},
													{
														const = 3
													},
													{
														const = 0
													},
													{
														const = BaseEnum.SpeedRateType.Mid
													},
													{
														const = true
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
						id = "15",
						class = "DecoratorWeight",
						properties = {
							{
								DecorateWhenChildEnds = "false"
							},
							{
								Weight = {
									const = 1
								}
							}
						},
						attachments = {},
						children = {
							{
								node = {
									id = "16",
									class = "Action",
									properties = {
										{
											Method = {
												func = "moveAroundTarget",
												params = {
													{
														field = "tgt"
													},
													{
														const = 3
													},
													{
														const = 0
													},
													{
														const = BaseEnum.SpeedRateType.Mid
													},
													{
														const = false
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
				}
			}
		}
	}
}

return PBT_Assist_MoveAround
