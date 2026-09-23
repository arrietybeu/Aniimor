-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\_Wild\\10231_Flutternym\\PBT_Wild_10231_Leave.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Wild_10231_Leave = {
	behavior = {
		version = 8,
		useForRoute = false,
		name = "ParmonBehaviorTree/SubTree/_Wild/10231_Flutternym/PBT_Wild_10231_Leave",
		agenttype = "CombatAgent",
		properties = {},
		pars = {
			{
				type = "int",
				const = 0,
				name = "tTargetActorId",
				value = "0"
			},
			{
				type = "float",
				const = 5,
				name = "tLeaveDistance",
				value = "5"
			},
			{
				type = "float",
				const = 4,
				name = "tSpeed",
				value = "4"
			},
			{
				type = "SpeedRateType",
				name = "tSpeedRateType",
				value = "Mid",
				const = BaseEnum.SpeedRateType.Mid
			},
			{
				type = "float",
				const = 10,
				name = "tMaxTime",
				value = "10"
			}
		},
		attachments = {},
		node = {
			id = "11",
			class = "IfElse",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						id = "10",
						class = "Condition",
						properties = {
							{
								Operator = "Equal"
							},
							{
								Opl = {
									func = "checkTargetHasBuffById",
									params = {
										{
											field = "selfId"
										},
										{
											const = 2123100
										},
										{
											const = 1
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
						id = "16",
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
						class = "Sequence",
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
												func = "castSkill",
												params = {
													{
														const = 0
													},
													{
														const = 10600152
													},
													{
														const = false
													},
													{
														const = 0
													},
													{
														const = false
													},
													{
														const = BaseEnum.CastAbilitySourceType.Normal
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
									id = "17",
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

return PBT_Wild_10231_Leave
