-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\PatrolTree\\PatrolSubTree\\ST_JumpToPos.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local ST_JumpToPos = {
	behavior = {
		agenttype = "CombatAgent",
		version = 7,
		useForRoute = true,
		name = "PatrolTree/PatrolSubTree/ST_JumpToPos",
		properties = {},
		pars = {
			{
				name = "tTimeout",
				type = "float",
				value = "0",
				const = 0
			},
			{
				name = "tTargetPosX",
				type = "float",
				value = "0",
				const = 0
			},
			{
				name = "tTargetPosY",
				type = "float",
				value = "0",
				const = 0
			},
			{
				name = "tTargetPosZ",
				type = "float",
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
									func = "playJumpActionToPos",
									params = {
										{
											const = "JumpInRun"
										},
										{
											field = "tTimeout"
										},
										{
											field = "tTargetPosX"
										},
										{
											field = "tTargetPosY"
										},
										{
											field = "tTargetPosZ"
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

return ST_JumpToPos
