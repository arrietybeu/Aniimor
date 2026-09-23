-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_State_Idle.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_State_Idle = {
	behavior = {
		useForRoute = false,
		name = "ParmonBehaviorTree/SubTree/PBT_State_Idle",
		agenttype = "PuppetAgent",
		version = 18,
		properties = {},
		pars = {},
		attachments = {},
		node = {
			id = "20",
			class = "Sequence",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						id = "21",
						class = "Action",
						properties = {
							{
								Method = {
									func = "doSendMessage",
									params = {
										{
											field = "selfId"
										},
										{
											const = {}
										},
										{
											const = "IdleMsgTrigger"
										}
									}
								}
							},
							{
								ResultOption = "BT_INVALID"
							},
							{
								ResultResumeOption = "BT_None"
							}
						},
						attachments = {},
						children = {}
					}
				},
				{
					node = {
						id = "56",
						class = "ReferencedBehavior",
						properties = {
							{
								ReferenceBehavior = {
									field = "Param_ST_Idle"
								}
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

return PBT_State_Idle
