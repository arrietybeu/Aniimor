-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\PatrolTree\\PatrolMoveSubTree\\ST_PatrolTurn.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local ST_PatrolTurn = {
	behavior = {
		version = 6,
		useForRoute = false,
		agenttype = "CombatAgent",
		name = "PatrolTree/PatrolMoveSubTree/ST_PatrolTurn",
		properties = {},
		pars = {
			{
				value = "0",
				const = 0,
				type = "float",
				name = "tTurnYaw"
			}
		},
		attachments = {},
		node = {
			id = "1",
			class = "Action",
			properties = {
				{
					Method = {
						func = "turnToYaw",
						params = {
							{
								field = "tTurnYaw"
							},
							{
								const = false
							},
							{
								const = -1
							},
							{
								const = false
							},
							{
								const = 0
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

return ST_PatrolTurn
