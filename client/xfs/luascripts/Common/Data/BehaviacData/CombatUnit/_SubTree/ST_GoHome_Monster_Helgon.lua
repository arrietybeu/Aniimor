-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\CombatUnit\\_SubTree\\ST_GoHome_Monster_Helgon.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local ST_GoHome_Monster_Helgon = {
	behavior = {
		agenttype = "CombatAgent",
		name = "CombatUnit/_SubTree/ST_GoHome_Monster_Helgon",
		version = 5,
		useForRoute = false,
		properties = {},
		pars = {},
		attachments = {},
		node = {
			class = "Sequence",
			id = "1",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						class = "Selector",
						id = "2",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									class = "Sequence",
									id = "4",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												class = "Condition",
												id = "6",
												properties = {
													{
														Operator = "Equal"
													},
													{
														Opl = {
															func = "checkIsFlying",
															params = {
																{
																	const = 0
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
												id = "7",
												properties = {
													{
														Method = {
															func = "switchToGround"
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
									class = "True",
									id = "5",
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
						class = "Action",
						id = "3",
						properties = {
							{
								Method = {
									func = "gotoBornPos",
									params = {
										{
											const = 100
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

return ST_GoHome_Monster_Helgon
