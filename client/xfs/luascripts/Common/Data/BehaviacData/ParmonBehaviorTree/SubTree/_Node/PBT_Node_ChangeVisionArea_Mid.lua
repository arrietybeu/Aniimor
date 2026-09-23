-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\_Node\\PBT_Node_ChangeVisionArea_Mid.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Node_ChangeVisionArea_Mid = {
	behavior = {
		name = "ParmonBehaviorTree/SubTree/_Node/PBT_Node_ChangeVisionArea_Mid",
		useForRoute = true,
		agenttype = "CombatAgent",
		version = 13,
		properties = {},
		pars = {},
		attachments = {},
		node = {
			id = "19",
			class = "Action",
			properties = {
				{
					Method = {
						func = "setVisionAreaOverride",
						params = {
							{
								const = "visionAreaMid"
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
	}
}

return PBT_Node_ChangeVisionArea_Mid
