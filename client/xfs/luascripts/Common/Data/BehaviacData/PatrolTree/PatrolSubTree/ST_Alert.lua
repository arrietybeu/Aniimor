-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\PatrolTree\\PatrolSubTree\\ST_Alert.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local ST_Alert = {
	behavior = {
		name = "PatrolTree/PatrolSubTree/ST_Alert",
		version = 6,
		useForRoute = true,
		agenttype = "CombatAgent",
		properties = {},
		pars = {},
		attachments = {},
		node = {
			class = "Selector",
			id = "6",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						class = "Sequence",
						id = "5",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									class = "Condition",
									id = "7",
									properties = {
										{
											Operator = "Equal"
										},
										{
											Opl = {
												func = "hasAnimState",
												params = {
													{
														const = "Behav_AlertLoop"
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
									id = "3",
									properties = {
										{
											Method = {
												func = "playPhaseAction",
												params = {
													{
														const = "Behav_AlertStart"
													},
													{
														const = "Behav_AlertLoop"
													},
													{
														const = "Behav_AlertEnd"
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
						class = "Action",
						id = "4",
						properties = {
							{
								Method = {
									func = "playAction",
									params = {
										{
											const = "Behav_Alert"
										},
										{
											const = 6
										},
										{
											const = ""
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

return ST_Alert
