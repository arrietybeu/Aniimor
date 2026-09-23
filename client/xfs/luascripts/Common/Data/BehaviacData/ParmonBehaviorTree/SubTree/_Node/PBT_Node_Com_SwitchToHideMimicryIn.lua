-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\_Node\\PBT_Node_Com_SwitchToHideMimicryIn.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Node_Com_SwitchToHideMimicryIn = {
	behavior = {
		agenttype = "CombatAgent",
		version = 5,
		name = "ParmonBehaviorTree/SubTree/_Node/PBT_Node_Com_SwitchToHideMimicryIn",
		useForRoute = false,
		properties = {},
		pars = {
			{
				name = "tTargetPos",
				type = "vector<float>",
				value = "0:",
				const = {}
			}
		},
		attachments = {},
		node = {
			id = "1",
			class = "Action",
			properties = {
				{
					Method = {
						func = "switchToHideMimicryIn",
						params = {
							{
								field = "tTargetPos"
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

return PBT_Node_Com_SwitchToHideMimicryIn
