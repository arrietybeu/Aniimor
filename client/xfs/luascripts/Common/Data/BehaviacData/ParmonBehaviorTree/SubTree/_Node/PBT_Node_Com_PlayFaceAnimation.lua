-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\_Node\\PBT_Node_Com_PlayFaceAnimation.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Node_Com_PlayFaceAnimation = {
	behavior = {
		version = 14,
		useForRoute = true,
		agenttype = "CombatAgent",
		name = "ParmonBehaviorTree/SubTree/_Node/PBT_Node_Com_PlayFaceAnimation",
		properties = {},
		pars = {
			{
				value = "0",
				const = 0,
				type = "float",
				name = "tFadeTime"
			},
			{
				value = "",
				const = "",
				type = "string",
				name = "tFaceName"
			}
		},
		attachments = {},
		node = {
			id = "14",
			class = "Action",
			properties = {
				{
					Method = {
						func = "playFaceAnimation",
						params = {
							{
								field = "tFaceName"
							},
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

return PBT_Node_Com_PlayFaceAnimation
