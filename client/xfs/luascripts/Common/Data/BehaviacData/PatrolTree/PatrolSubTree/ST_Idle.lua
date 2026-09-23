-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\PatrolTree\\PatrolSubTree\\ST_Idle.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local ST_Idle = {
	behavior = {
		useForRoute = true,
		name = "PatrolTree/PatrolSubTree/ST_Idle",
		agenttype = "CombatAgent",
		version = 5,
		properties = {},
		pars = {
			{
				type = "float",
				value = "4",
				name = "idleTimeout",
				const = 4
			}
		},
		attachments = {},
		node = {
			class = "Sequence",
			id = "1",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						class = "Action",
						id = "3",
						properties = {
							{
								Method = {
									func = "waitTime",
									params = {
										{
											field = "idleTimeout"
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

return ST_Idle
