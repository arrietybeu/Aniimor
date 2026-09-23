-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\_Node\\PBT_Node_Com_PlayEffectOnTarget.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Node_Com_PlayEffectOnTarget = {
	behavior = {
		version = 6,
		useForRoute = true,
		name = "ParmonBehaviorTree/SubTree/_Node/PBT_Node_Com_PlayEffectOnTarget",
		agenttype = "CombatAgent",
		properties = {},
		pars = {
			{
				name = "tEffectName",
				type = "string",
				value = "",
				const = ""
			},
			{
				name = "tTargetActorId",
				type = "int",
				value = "0",
				const = 0
			}
		},
		attachments = {},
		node = {
			class = "Sequence",
			id = "7",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						class = "IfElse",
						id = "5",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									class = "Condition",
									id = "3",
									properties = {
										{
											Operator = "Equal"
										},
										{
											Opl = {
												field = "tTargetActorId"
											}
										},
										{
											Opr = {
												const = 0
											}
										}
									},
									attachments = {},
									children = {}
								}
							},
							{
								node = {
									class = "Assignment",
									id = "4",
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
												field = "selfId"
											}
										}
									},
									attachments = {},
									children = {}
								}
							},
							{
								node = {
									class = "Noop",
									id = "6",
									properties = {},
									attachments = {},
									children = {}
								}
							}
						}
					}
				},
				{
					node = {
						class = "Action",
						id = "2",
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
		}
	}
}

return PBT_Node_Com_PlayEffectOnTarget
