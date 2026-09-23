-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_CastChargeSkill.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_CastChargeSkill = {
	behavior = {
		version = 8,
		name = "ParmonBehaviorTree/SubTree/PBT_CastChargeSkill",
		agenttype = "CombatAgent",
		useForRoute = false,
		properties = {},
		pars = {
			{
				type = "int",
				value = "0",
				name = "tSkillTargetActorId",
				const = 0
			},
			{
				type = "int",
				value = "0",
				name = "tSkillId",
				const = 0
			},
			{
				type = "bool",
				value = "true",
				name = "tAutoCast",
				const = true
			},
			{
				type = "float",
				value = "0",
				name = "tChargeTime",
				const = 0
			},
			{
				type = "int",
				value = "0",
				name = "tPartId",
				const = 0
			},
			{
				type = "bool",
				value = "false",
				name = "tSkipBackswing",
				const = false
			},
			{
				type = "CastAbilitySourceType",
				value = "Normal",
				name = "tCastAbilitySource",
				const = BaseEnum.CastAbilitySourceType.Normal
			}
		},
		attachments = {},
		node = {
			id = "1",
			class = "Action",
			properties = {
				{
					Method = {
						func = "castChargetSkill",
						params = {
							{
								field = "tSkillTargetActorId"
							},
							{
								field = "tSkillId"
							},
							{
								field = "tChargeTime"
							},
							{
								field = "tPartId"
							},
							{
								field = "tSkipBackswing"
							},
							{
								field = "tAutoCast"
							},
							{
								field = "tCastAbilitySource"
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

return PBT_CastChargeSkill
