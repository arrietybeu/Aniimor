-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\PatrolTree\\PatrolMoveSubTree\\ST_PatrolRun.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local ST_PatrolRun = {
	behavior = {
		agenttype = "WxAgent",
		useForRoute = false,
		name = "PatrolTree/PatrolMoveSubTree/ST_PatrolRun",
		version = 5,
		properties = {},
		pars = {
			{
				name = "patrolPos",
				value = "0:",
				type = "vector<float>",
				const = {}
			},
			{
				name = "patrolMaxTime",
				value = "15",
				type = "float",
				const = 15
			},
			{
				name = "tPatrolSpeed",
				value = "-1",
				type = "float",
				const = -1
			},
			{
				name = "tPatrolAnimationState",
				value = "RUN",
				type = "string",
				const = "RUN"
			}
		},
		attachments = {},
		node = {
			id = "1",
			class = "Action",
			properties = {
				{
					Method = {
						func = "moveToPos",
						params = {
							{
								field = "patrolPos"
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
								const = BaseEnum.SpeedRateType.Mid
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

return ST_PatrolRun
