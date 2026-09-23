-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\_Node\\PBT_Node_Com_LookAtEntity.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Node_Com_LookAtEntity = {
	behavior = {
		agenttype = "CombatAgent",
		name = "ParmonBehaviorTree/SubTree/_Node/PBT_Node_Com_LookAtEntity",
		version = 9,
		useForRoute = true,
		properties = {},
		pars = {
			{
				const = 0,
				type = "int",
				name = "tTargetStaticId",
				value = "0"
			},
			{
				const = 0,
				type = "int",
				name = "tTargetActorId",
				value = "0"
			},
			{
				const = false,
				type = "bool",
				name = "tForce",
				value = "false"
			}
		},
		attachments = {},
		node = {
			id = "10",
			class = "Sequence",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						id = "8",
						class = "Assignment",
						properties = {
							{
								CastRight = "false"
							},
							{
								Opl = {
									field = "tTargetActorId"
								}
							},
							{
								Opr = {
									func = "getActorId",
									params = {
										{
											field = "tTargetStaticId"
										}
									}
								}
							}
						},
						attachments = {},
						children = {}
					}
				},
				{
					node = {
						id = "9",
						class = "Action",
						properties = {
							{
								Method = {
									func = "lookAtEntity",
									params = {
										{
											field = "tTargetActorId"
										},
										{
											field = "tForce"
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
		}
	}
}

return PBT_Node_Com_LookAtEntity
