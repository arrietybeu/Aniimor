-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_AddBuff.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_AddBuff = {
	behavior = {
		name = "ParmonBehaviorTree/SubTree/PBT_AddBuff",
		useForRoute = false,
		version = 10,
		agenttype = "CombatAgent",
		properties = {},
		pars = {
			{
				name = "tBuffId",
				type = "int",
				const = 0,
				value = "0"
			},
			{
				name = "duration",
				type = "float",
				const = -1,
				value = "-1"
			}
		},
		attachments = {},
		node = {
			id = "12",
			class = "Action",
			properties = {
				{
					Method = {
						func = "addBuff",
						params = {
							{
								field = "tBuffId"
							},
							{
								field = "duration"
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

return PBT_AddBuff
