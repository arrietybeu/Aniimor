-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\PatrolTree\\PatrolSubTree\\ST_CastCutsomSkill.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local ST_CastCutsomSkill = {
	behavior = {
		version = 6,
		name = "PatrolTree/PatrolSubTree/ST_CastCutsomSkill",
		useForRoute = true,
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
				name = "tSkillId",
				const = 0,
				type = "int",
				value = "0"
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
									id = "9",
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
									id = "7",
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
									id = "8",
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
						id = "4",
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
						id = "5",
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

return ST_CastCutsomSkill
