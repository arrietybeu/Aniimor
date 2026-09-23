-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_CastNormalAtkCombo.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_CastNormalAtkCombo = {
	behavior = {
		version = 19,
		useForRoute = false,
		name = "ParmonBehaviorTree/SubTree/PBT_CastNormalAtkCombo",
		agenttype = "CombatAgent",
		properties = {},
		pars = {
			{
				name = "tWaitTime",
				const = 0,
				type = "float",
				value = "0"
			},
			{
				name = "tSkipBackswing",
				const = false,
				type = "bool",
				value = "false"
			},
			{
				name = "tSkillTargetActorId",
				const = 0,
				type = "int",
				value = "0"
			},
			{
				name = "tEmojiBubbleKey",
				const = "",
				type = "string",
				value = ""
			},
			{
				name = "tEmojiBubbleTimeout",
				const = 0,
				type = "float",
				value = "0"
			},
			{
				name = "tRaycastOpen",
				const = false,
				type = "bool",
				value = "false"
			},
			{
				name = "tCastAbilitySource",
				type = "CastAbilitySourceType",
				value = "Normal",
				const = BaseEnum.CastAbilitySourceType.Normal
			}
		},
		attachments = {},
		node = {
			class = "Sequence",
			id = "8",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						class = "Action",
						id = "4",
						properties = {
							{
								Method = {
									func = "waitTime",
									params = {
										{
											field = "tWaitTime"
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
				},
				{
					node = {
						class = "IfElse",
						id = "0",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									class = "Condition",
									id = "27",
									properties = {
										{
											Operator = "Equal"
										},
										{
											Opl = {
												field = "tRaycastOpen"
											}
										},
										{
											Opr = {
												const = true
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
									id = "1",
									properties = {
										{
											CastRight = "false"
										},
										{
											Opl = {
												field = "tSkillTargetActorId"
											}
										},
										{
											Opr = {
												func = "getRaycastEntityActorId",
												params = {
													{
														const = 0
													},
													{
														const = 5
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
									class = "Noop",
									id = "2",
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
						id = "5",
						properties = {
							{
								Method = {
									func = "showEmojiBubble",
									params = {
										{
											field = "tEmojiBubbleKey"
										},
										{
											field = "tEmojiBubbleTimeout"
										},
										{
											const = false
										},
										{
											const = false
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
				},
				{
					node = {
						class = "Action",
						id = "42",
						properties = {
							{
								Method = {
									func = "castNormalAtkCombo",
									params = {
										{
											field = "tSkillTargetActorId"
										},
										{
											const = 4
										},
										{
											field = "tSkipBackswing"
										},
										{
											const = 4
										},
										{
											field = "tSkipBackswing"
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
		}
	}
}

return PBT_CastNormalAtkCombo
