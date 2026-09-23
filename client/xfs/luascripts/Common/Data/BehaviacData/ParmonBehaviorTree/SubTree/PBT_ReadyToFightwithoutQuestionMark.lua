-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_ReadyToFightwithoutQuestionMark.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_ReadyToFightwithoutQuestionMark = {
	behavior = {
		name = "ParmonBehaviorTree/SubTree/PBT_ReadyToFightwithoutQuestionMark",
		useForRoute = false,
		version = 17,
		agenttype = "CombatAgent",
		properties = {},
		pars = {
			{
				name = "tSensorTgtId",
				value = "0",
				const = 0,
				type = "int"
			},
			{
				name = "tRandomWaitTime",
				value = "0",
				const = 0,
				type = "float"
			},
			{
				name = "tShowExclamation",
				value = "false",
				const = false,
				type = "bool"
			}
		},
		attachments = {},
		node = {
			id = "1",
			class = "Sequence",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						id = "13",
						class = "IfElse",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									id = "14",
									class = "Condition",
									properties = {
										{
											Operator = "Equal"
										},
										{
											Opl = {
												field = "tSensorTgtId"
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
									id = "12",
									class = "Assignment",
									properties = {
										{
											CastRight = "false"
										},
										{
											Opl = {
												field = "tSensorTgtId"
											}
										},
										{
											Opr = {
												func = "getPerceptibilityTarget"
											}
										}
									},
									attachments = {},
									children = {}
								}
							},
							{
								node = {
									id = "15",
									class = "Noop",
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
						id = "5",
						class = "Action",
						properties = {
							{
								Method = {
									func = "enterCombat",
									params = {
										{
											field = "tSensorTgtId"
										}
									}
								}
							},
							{
								ResultOption = "BT_SUCCESS"
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

return PBT_ReadyToFightwithoutQuestionMark
