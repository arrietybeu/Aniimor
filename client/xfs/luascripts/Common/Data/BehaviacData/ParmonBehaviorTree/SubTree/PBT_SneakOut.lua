-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_SneakOut.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_SneakOut = {
	behavior = {
		useForRoute = true,
		version = 5,
		agenttype = "WxAgent",
		name = "ParmonBehaviorTree/SubTree/PBT_SneakOut",
		properties = {},
		pars = {
			{
				type = "bool",
				const = false,
				value = "false",
				name = "tIsHit"
			}
		},
		attachments = {},
		node = {
			class = "Action",
			id = "1",
			properties = {
				{
					Method = {
						func = "switchToSneakOut",
						params = {
							{
								field = "tIsHit"
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

return PBT_SneakOut
