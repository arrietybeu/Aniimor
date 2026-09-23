-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_CastSameTypeSkill.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_CastSameTypeSkill = {
	behavior = {
		version = 7,
		useForRoute = false,
		agenttype = "CombatAgent",
		name = "ParmonBehaviorTree/SubTree/PBT_CastSameTypeSkill",
		properties = {},
		pars = {
			{
				type = "float",
				const = 0,
				name = "tWaitTime",
				value = "0"
			},
			{
				type = "int",
				const = 0,
				name = "tSkillId",
				value = "0"
			},
			{
				type = "int",
				const = 0,
				name = "tSkillTargetActorId",
				value = "0"
			},
			{
				type = "string",
				const = "",
				name = "tEmojiBubbleKey",
				value = ""
			},
			{
				type = "float",
				const = 5,
				name = "tEmojiBubbleTimeout",
				value = "5"
			},
			{
				type = "bool",
				const = false,
				name = "tRaycastOpen",
				value = "false"
			},
			{
				type = "CastAbilitySourceType",
				name = "tCastAbilitySource",
				value = "Normal",
				const = BaseEnum.CastAbilitySourceType.Normal
			}
		},
		attachments = {},
		node = {
			class = "Sequence",
			id = "1",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						class = "Action",
						id = "2",
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
						id = "3",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									class = "Condition",
									id = "4",
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
									id = "5",
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
						id = "8",
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
						class = "Assignment",
						id = "7",
						properties = {
							{
								CastRight = "false"
							},
							{
								Opl = {
									field = "tSkillId"
								}
							},
							{
								Opr = {
									func = "getSameTypeSkillId",
									params = {
										{
											field = "tSkillId"
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
						class = "Action",
						id = "9",
						properties = {
							{
								Method = {
									func = "castSkill",
									params = {
										{
											field = "tSkillTargetActorId"
										},
										{
											field = "tSkillId"
										},
										{
											const = false
										},
										{
											const = 0
										},
										{
											const = false
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

return PBT_CastSameTypeSkill
