-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\_Node\\PBT_Node_Com_StopLipAnimation.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Node_Com_StopLipAnimation = {
	behavior = {
		agenttype = "CombatAgent",
		name = "ParmonBehaviorTree/SubTree/_Node/PBT_Node_Com_StopLipAnimation",
		version = 11,
		useForRoute = true,
		properties = {},
		pars = {
			{
				const = 0,
				value = "0",
				name = "tFadeTime",
				type = "float"
			}
		},
		attachments = {},
		node = {
			id = "12",
			class = "Action",
			properties = {
				{
					Method = {
						func = "stopLipAnimation",
						params = {
							{
								field = "tFadeTime"
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

return PBT_Node_Com_StopLipAnimation
