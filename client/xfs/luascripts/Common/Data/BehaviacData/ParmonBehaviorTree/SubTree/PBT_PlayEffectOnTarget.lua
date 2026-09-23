-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_PlayEffectOnTarget.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_PlayEffectOnTarget = {
	behavior = {
		useForRoute = false,
		version = 5,
		agenttype = "CombatAgent",
		name = "ParmonBehaviorTree/SubTree/PBT_PlayEffectOnTarget",
		properties = {},
		pars = {
			{
				name = "tEffectName",
				value = "",
				type = "string",
				const = ""
			},
			{
				name = "tTargetActorId",
				value = "0",
				type = "int",
				const = 0
			}
		},
		attachments = {},
		node = {
			class = "Action",
			id = "1",
			properties = {
				{
					Method = {
						func = "playEffectOnTarget",
						params = {
							{
								field = "tEffectName"
							},
							{
								field = "tTargetActorId"
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

return PBT_PlayEffectOnTarget
