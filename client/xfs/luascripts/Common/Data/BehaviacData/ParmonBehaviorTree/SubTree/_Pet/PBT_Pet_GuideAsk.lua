-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\_Pet\\PBT_Pet_GuideAsk.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Pet_GuideAsk = {
	behavior = {
		useForRoute = false,
		agenttype = "PetAgent",
		name = "ParmonBehaviorTree/SubTree/_Pet/PBT_Pet_GuideAsk",
		version = 13,
		properties = {},
		pars = {
			{
				type = "int",
				name = "tSensorTgtId",
				const = 0,
				value = "0"
			},
			{
				type = "float",
				name = "tRandomWaitTime",
				const = 0,
				value = "0"
			}
		},
		attachments = {},
		node = {
			id = "8",
			class = "Action",
			properties = {
				{
					Method = {
						func = "waitTime",
						params = {
							{
								const = 3.5
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

return PBT_Pet_GuideAsk
