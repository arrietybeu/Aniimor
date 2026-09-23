-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\PatrolTree\\PatrolMoveSubTree\\ST_PatrolSplineWalk_MoveToPos.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local ST_PatrolSplineWalk_MoveToPos = {
	behavior = {
		name = "PatrolTree/PatrolMoveSubTree/ST_PatrolSplineWalk_MoveToPos",
		version = 17,
		useForRoute = false,
		agenttype = "WxAgent",
		properties = {},
		pars = {
			{
				name = "patrolPosList",
				type = "vector<float>",
				value = "0:",
				const = {}
			},
			{
				name = "patrolMaxTime",
				const = 0,
				type = "float",
				value = "0"
			},
			{
				name = "tPatrolSpeed",
				const = 0,
				type = "float",
				value = "0"
			},
			{
				name = "tBehaviorSpeedRateType",
				type = "SpeedRateType",
				value = "Slow",
				const = BaseEnum.SpeedRateType.Slow
			},
			{
				name = "patrolStartPos",
				type = "vector<float>",
				value = "0:",
				const = {}
			},
			{
				name = "tNormalList",
				type = "vector<float>",
				value = "0:",
				const = {}
			},
			{
				name = "tUseAccurateArrive",
				const = false,
				type = "bool",
				value = "false"
			},
			{
				name = "tIsFirstPoint",
				const = false,
				type = "bool",
				value = "false"
			}
		},
		attachments = {},
		node = {
			id = "1",
			class = "Sequence",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						id = "69",
						class = "Selector",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									id = "70",
									class = "Condition",
									properties = {
										{
											Operator = "Equal"
										},
										{
											Opl = {
												field = "tIsFirstPoint"
											}
										},
										{
											Opr = {
												const = false
											}
										}
									},
									attachments = {},
									children = {}
								}
							},
							{
								node = {
									id = "68",
									class = "Action",
									properties = {
										{
											Method = {
												func = "moveToPos",
												params = {
													{
														field = "patrolStartPos"
													},
													{
														field = "patrolMaxTime"
													},
													{
														const = true
													},
													{
														const = 0
													},
													{
														field = "tBehaviorSpeedRateType"
													},
													{
														field = "tPatrolSpeed"
													},
													{
														const = BaseEnum.PathFindType.Auto
													},
													{
														const = false
													},
													{
														field = "tUseAccurateArrive"
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
						id = "66",
						class = "Selector",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									id = "67",
									class = "Action",
									properties = {
										{
											Method = {
												func = "moveToPosList",
												params = {
													{
														field = "patrolPosList"
													},
													{
														field = "patrolMaxTime"
													},
													{
														const = true
													},
													{
														const = 0
													},
													{
														field = "tBehaviorSpeedRateType"
													},
													{
														field = "tPatrolSpeed"
													},
													{
														field = "tNormalList"
													},
													{
														field = "tUseAccurateArrive"
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
									id = "71",
									class = "Noop",
									properties = {},
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

return ST_PatrolSplineWalk_MoveToPos
