-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\_Node\\PBT_Node_Com_FlyGrabEntity.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Node_Com_FlyGrabEntity = {
	behavior = {
		useForRoute = true,
		agenttype = "CombatAgent",
		name = "ParmonBehaviorTree/SubTree/_Node/PBT_Node_Com_FlyGrabEntity",
		version = 13,
		properties = {},
		pars = {
			{
				type = "int",
				name = "tTargetActorId",
				const = 0,
				value = "0"
			}
		},
		attachments = {},
		node = {
			class = "Action",
			id = "12",
			properties = {
				{
					Method = {
						func = "flyGrabEntity",
						params = {
							{
								field = "tTargetActorId"
							},
							{
								const = 5
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

return PBT_Node_Com_FlyGrabEntity
