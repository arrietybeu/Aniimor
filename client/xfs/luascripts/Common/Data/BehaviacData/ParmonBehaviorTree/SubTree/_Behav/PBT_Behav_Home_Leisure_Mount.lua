-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\_Behav\\PBT_Behav_Home_Leisure_Mount.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Behav_Home_Leisure_Mount = {
	behavior = {
		useForRoute = false,
		name = "ParmonBehaviorTree/SubTree/_Behav/PBT_Behav_Home_Leisure_Mount",
		agenttype = "CombatAgent",
		version = 19,
		properties = {},
		pars = {
			{
				type = "vector<float>",
				name = "tVehiclePos",
				value = "0:",
				const = {}
			},
			{
				type = "int",
				const = 0,
				name = "tVehicleActorId",
				value = "0"
			},
			{
				type = "int",
				const = 0,
				name = "tSeatIndex",
				value = "0"
			},
			{
				type = "int",
				const = 0,
				name = "tRevision",
				value = "0"
			}
		},
		attachments = {},
		node = {
			id = "55",
			class = "Sequence",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						id = "56",
						class = "Selector",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									id = "54",
									class = "Action",
									properties = {
										{
											Method = {
												func = "moveToPos",
												params = {
													{
														field = "tVehiclePos"
													},
													{
														const = 10
													},
													{
														const = true
													},
													{
														const = 2
													},
													{
														const = BaseEnum.SpeedRateType.Mid
													},
													{
														const = 0
													},
													{
														const = BaseEnum.PathFindType.ForceMove
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
									id = "57",
									class = "Action",
									properties = {
										{
											Method = {
												func = "teleportToPosition",
												params = {
													{
														field = "tVehiclePos"
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
				},
				{
					node = {
						id = "53",
						class = "Action",
						properties = {
							{
								Method = {
									func = "tryHomeLeisureMount",
									params = {
										{
											field = "tVehicleActorId"
										},
										{
											field = "tSeatIndex"
										},
										{
											field = "tRevision"
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
				}
			}
		}
	}
}

return PBT_Behav_Home_Leisure_Mount
