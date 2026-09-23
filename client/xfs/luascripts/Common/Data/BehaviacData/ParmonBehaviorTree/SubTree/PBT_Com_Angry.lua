-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_Com_Angry.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Com_Angry = {
	behavior = {
		name = "ParmonBehaviorTree/SubTree/PBT_Com_Angry",
		useForRoute = false,
		version = 5,
		agenttype = "CombatAgent",
		properties = {},
		pars = {},
		attachments = {},
		node = {
			id = "4",
			class = "Selector",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						id = "3",
						class = "Sequence",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									id = "5",
									class = "Condition",
									properties = {
										{
											Operator = "Equal"
										},
										{
											Opl = {
												func = "hasAnimState",
												params = {
													{
														const = "Behav_AngryLoop"
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
									id = "1",
									class = "Action",
									properties = {
										{
											Method = {
												func = "playPhaseAction",
												params = {
													{
														const = "Behav_AngryStart"
													},
													{
														const = "Behav_AngryLoop"
													},
													{
														const = "Behav_AngryEnd"
													},
													{
														const = 0
													},
													{
														const = ""
													},
													{
														const = true
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
							}
						}
					}
				},
				{
					node = {
						id = "2",
						class = "Action",
						properties = {
							{
								Method = {
									func = "playAction",
									params = {
										{
											const = "Behav_Angry"
										},
										{
											const = 4
										},
										{
											const = ""
										},
										{
											const = false
										},
										{
											const = true
										},
										{
											const = 0
										},
										{
											const = BaseEnum.AIAnimationRootMotionType.Default
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

return PBT_Com_Angry
