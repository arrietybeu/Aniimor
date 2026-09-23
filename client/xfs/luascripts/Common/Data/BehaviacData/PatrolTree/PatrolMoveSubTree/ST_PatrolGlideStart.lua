-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\PatrolTree\\PatrolMoveSubTree\\ST_PatrolGlideStart.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local ST_PatrolGlideStart = {
	behavior = {
		useForRoute = false,
		version = 9,
		agenttype = "WxAgent",
		name = "PatrolTree/PatrolMoveSubTree/ST_PatrolGlideStart",
		properties = {},
		pars = {
			{
				value = "0:",
				type = "vector<float>",
				name = "patrolPosList",
				const = {}
			},
			{
				value = "0",
				const = 0,
				type = "float",
				name = "patrolMaxTime"
			},
			{
				value = "Slow",
				type = "SpeedRateType",
				name = "tBehaviorSpeedRateType",
				const = BaseEnum.SpeedRateType.Slow
			},
			{
				value = "0",
				const = 0,
				type = "float",
				name = "tPatrolSpeed"
			},
			{
				value = "false",
				const = false,
				type = "bool",
				name = "tUseAccurateArrive"
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
						id = "6",
						class = "Action",
						properties = {
							{
								Method = {
									func = "switchToState",
									params = {
										{
											const = "GLIDING"
										},
										{
											const = 0
										},
										{
											const = ""
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
						id = "2",
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
											const = {}
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
	}
}

return ST_PatrolGlideStart
