-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\_Wild\\10501_Cubbo\\ST_Wild_10501_Gohome.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local ST_Wild_10501_Gohome = {
	behavior = {
		version = 5,
		useForRoute = false,
		name = "ParmonBehaviorTree/SubTree/_Wild/10501_Cubbo/ST_Wild_10501_Gohome",
		agenttype = "CombatAgent",
		properties = {},
		pars = {
			{
				value = "0:",
				name = "tBornPos",
				type = "vector<float>",
				const = {}
			}
		},
		attachments = {},
		node = {
			class = "Selector",
			id = "1",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						class = "Sequence",
						id = "9",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									class = "Action",
									id = "10",
									properties = {
										{
											Method = {
												func = "addBuff",
												params = {
													{
														const = 215010101
													},
													{
														const = -1
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
									id = "2",
									properties = {
										{
											Method = {
												func = "gotoBornPos",
												params = {
													{
														const = -1
													}
												}
											}
										},
										{
											ResultOption = "BT_INVALID"
										},
										{
											ResultResumeOption = "BT_NextNode"
										}
									},
									attachments = {},
									children = {}
								}
							},
							{
								node = {
									class = "Action",
									id = "11",
									properties = {
										{
											Method = {
												func = "addEntityTag",
												params = {
													{},
													{
														const = "TE_Wild_10501_ReturnSleep"
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
				},
				{
					node = {
						class = "Sequence",
						id = "3",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									class = "Assignment",
									id = "7",
									properties = {
										{
											CastRight = "false"
										},
										{
											Opl = {
												field = "tBornPos"
											}
										},
										{
											Opr = {
												func = "getBornPos"
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
									id = "8",
									properties = {
										{
											Method = {
												func = "teleportToPosition",
												params = {
													{
														field = "tBornPos"
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
									id = "12",
									properties = {
										{
											Method = {
												func = "addBuff",
												params = {
													{
														const = 215010101
													},
													{
														const = -1
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
									id = "13",
									properties = {
										{
											Method = {
												func = "addEntityTag",
												params = {
													{},
													{
														const = "TE_Wild_10501_ReturnSleep"
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
		}
	}
}

return ST_Wild_10501_Gohome
