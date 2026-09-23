-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_10141_FlyToHeight.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_10141_FlyToHeight = {
	behavior = {
		version = 21,
		useForRoute = false,
		agenttype = "CombatAgent",
		name = "ParmonBehaviorTree/SubTree/PBT_10141_FlyToHeight",
		properties = {},
		pars = {
			{
				value = "0",
				type = "float",
				name = "tHeight",
				const = 0
			},
			{
				value = "0",
				type = "int",
				name = "tActorId",
				const = 0
			},
			{
				value = "0",
				type = "float",
				name = "tWaitTime",
				const = 0
			},
			{
				value = "0",
				type = "float",
				name = "tSpeed",
				const = 0
			}
		},
		attachments = {},
		node = {
			id = "3",
			class = "IfElse",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						id = "4",
						class = "Condition",
						properties = {
							{
								Operator = "Equal"
							},
							{
								Opl = {
									func = "checkIsFlying",
									params = {
										{
											field = "selfId"
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
									func = "flyToTarget",
									params = {
										{
											field = "tActorId"
										},
										{
											const = 0
										},
										{
											field = "tHeight"
										},
										{
											const = 20
										},
										{
											const = true
										},
										{
											field = "tWaitTime"
										},
										{
											const = false
										},
										{
											const = true
										},
										{
											field = "tSpeed"
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
						id = "5",
						class = "Sequence",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									id = "6",
									class = "Action",
									properties = {
										{
											Method = {
												func = "switchToFly",
												params = {
													{
														const = 0
													},
													{
														const = 0.5
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
									class = "Action",
									properties = {
										{
											Method = {
												func = "flyToTarget",
												params = {
													{
														field = "tActorId"
													},
													{
														const = 0
													},
													{
														field = "tHeight"
													},
													{
														const = 20
													},
													{
														const = true
													},
													{
														field = "tWaitTime"
													},
													{
														const = false
													},
													{
														const = true
													},
													{
														field = "tSpeed"
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

return PBT_10141_FlyToHeight
