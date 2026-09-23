-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\PatrolTree\\PatrolSubTree\\ST_JumpDist.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local ST_JumpDist = {
	behavior = {
		useForRoute = true,
		agenttype = "CombatAgent",
		name = "PatrolTree/PatrolSubTree/ST_JumpDist",
		version = 5,
		properties = {},
		pars = {
			{
				type = "float",
				name = "tTimeout",
				value = "0",
				const = 0
			},
			{
				type = "float",
				name = "tDist",
				value = "5",
				const = 5
			},
			{
				type = "float",
				name = "tDegree",
				value = "0",
				const = 0
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
						id = "2",
						class = "Action",
						properties = {
							{
								Method = {
									func = "playJumpAction",
									params = {
										{
											const = "AI_JumpInRun"
										},
										{
											field = "tTimeout"
										},
										{
											field = "tDegree"
										},
										{
											field = "tDist"
										},
										{
											const = BaseEnum.RootMotionSyncPointEnum.AICustomPoint1
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

return ST_JumpDist
