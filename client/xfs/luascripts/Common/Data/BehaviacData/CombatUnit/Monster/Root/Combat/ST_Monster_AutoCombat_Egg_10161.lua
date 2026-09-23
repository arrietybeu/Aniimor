-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\CombatUnit\\Monster\\Root\\Combat\\ST_Monster_AutoCombat_Egg_10161.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local ST_Monster_AutoCombat_Egg_10161 = {
	behavior = {
		name = "CombatUnit/Monster/Root/Combat/ST_Monster_AutoCombat_Egg_10161",
		useForRoute = false,
		version = 58,
		agenttype = "PuppetAgent",
		properties = {},
		pars = {
			{
				type = "float",
				name = "CurrentDistToTarget",
				value = "0",
				const = 0
			},
			{
				type = "float",
				name = "CurrentBoxDistToTarget",
				value = "0",
				const = 0
			},
			{
				type = "float",
				name = "goBackDist",
				value = "0",
				const = 0
			},
			{
				type = "float",
				name = "skillStopDist",
				value = "0",
				const = 0
			},
			{
				type = "int",
				name = "tWeight_Group_SideWalk",
				value = "100",
				const = 100
			},
			{
				type = "int",
				name = "tWeight_Group_Wait",
				value = "100",
				const = 100
			},
			{
				type = "int",
				name = "tWeight_Group_Angry",
				value = "100",
				const = 100
			}
		},
		attachments = {},
		node = {
			class = "Sequence",
			id = "344",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						class = "Assignment",
						id = "347",
						properties = {
							{
								CastRight = "false"
							},
							{
								Opl = {
									field = "tgt"
								}
							},
							{
								Opr = {
									func = "getTarget"
								}
							}
						},
						attachments = {},
						children = {}
					}
				},
				{
					node = {
						class = "Condition",
						id = "346",
						properties = {
							{
								Operator = "NotEqual"
							},
							{
								Opl = {
									field = "tgt"
								}
							},
							{
								Opr = {
									const = 0
								}
							}
						},
						attachments = {},
						children = {}
					}
				},
				{
					node = {
						class = "Assignment",
						id = "345",
						properties = {
							{
								CastRight = "false"
							},
							{
								Opl = {
									field = "distToTgt"
								}
							},
							{
								Opr = {
									func = "getDistByTgt",
									params = {
										{
											field = "tgt"
										},
										{
											const = false
										},
										{
											const = false
										},
										{
											const = 0
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
						class = "Assignment",
						id = "351",
						properties = {
							{
								CastRight = "false"
							},
							{
								Opl = {
									field = "attackWeight"
								}
							},
							{
								Opr = {
									const = 100
								}
							}
						},
						attachments = {},
						children = {}
					}
				},
				{
					node = {
						class = "DecoratorLoop",
						id = "3",
						properties = {
							{
								Count = {
									const = -1
								}
							},
							{
								DecorateWhenChildEnds = "true"
							},
							{
								DoneWithinFrame = "false"
							}
						},
						attachments = {},
						children = {
							{
								node = {
									class = "Action",
									id = "434",
									properties = {
										{
											Method = {
												func = "leaveTarget",
												params = {
													{
														field = "tgt"
													},
													{
														const = 30
													},
													{
														const = 0
													},
													{
														const = BaseEnum.SpeedRateType.Fast
													},
													{
														const = 20
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

return ST_Monster_AutoCombat_Egg_10161
