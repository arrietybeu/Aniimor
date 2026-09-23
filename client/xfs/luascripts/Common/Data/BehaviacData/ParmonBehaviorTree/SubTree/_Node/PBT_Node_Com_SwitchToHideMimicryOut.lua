-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\_Node\\PBT_Node_Com_SwitchToHideMimicryOut.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Node_Com_SwitchToHideMimicryOut = {
	behavior = {
		version = 14,
		name = "ParmonBehaviorTree/SubTree/_Node/PBT_Node_Com_SwitchToHideMimicryOut",
		useForRoute = false,
		agenttype = "CombatAgent",
		properties = {},
		pars = {
			{
				name = "tNeedPlayAnim",
				const = true,
				type = "bool",
				value = "true"
			},
			{
				name = "tJumpDistance",
				const = 0,
				type = "float",
				value = "0"
			}
		},
		attachments = {},
		node = {
			class = "Action",
			id = "3",
			properties = {
				{
					Method = {
						func = "switchToHideMimicryOut",
						params = {
							{
								field = "tNeedPlayAnim"
							},
							{
								field = "tJumpDistance"
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

return PBT_Node_Com_SwitchToHideMimicryOut
