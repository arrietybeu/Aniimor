-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\CombatUnit\\NPC\\BotPlayer\\PBT_BotPlayer_Assist_Combat_BACKSTAGE_ENERGY.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_BotPlayer_Assist_Combat_BACKSTAGE_ENERGY = {
	behavior = {
		useForRoute = false,
		name = "CombatUnit/NPC/BotPlayer/PBT_BotPlayer_Assist_Combat_BACKSTAGE_ENERGY",
		agenttype = "BotPlayerAgent",
		version = 99,
		properties = {},
		pars = {
			{
				name = "tCurrentPet",
				value = "0",
				type = "int",
				const = 0
			},
			{
				name = "tCurrentPetHpPercent",
				value = "0",
				type = "float",
				const = 0
			},
			{
				name = "tSwitchPetId",
				value = "0",
				type = "int",
				const = 0
			},
			{
				name = "tTargetSkillId",
				value = "0",
				type = "int",
				const = 0
			},
			{
				name = "tCurrentEp",
				value = "0",
				type = "float",
				const = 0
			},
			{
				name = "tTeammateId1",
				value = "0",
				type = "int",
				const = 0
			},
			{
				name = "tTeammateId2",
				value = "0",
				type = "int",
				const = 0
			},
			{
				name = "tTeammateId3",
				value = "0",
				type = "int",
				const = 0
			},
			{
				name = "tCurrentBreakPercent",
				value = "0",
				type = "float",
				const = 0
			},
			{
				name = "tCurrentSp",
				value = "0",
				type = "float",
				const = 0
			},
			{
				name = "tSupportSkillId",
				value = "0",
				type = "int",
				const = 0
			},
			{
				name = "tMaxSkillDist",
				value = "0",
				type = "float",
				const = 0
			}
		},
		attachments = {},
		node = {
			id = "367",
			class = "Sequence",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						id = "377",
						class = "Condition",
						properties = {
							{
								Operator = "LessEqual"
							},
							{
								Opl = {
									func = "getEp",
									params = {
										{
											field = "tCurrentPet"
										}
									}
								}
							},
							{
								Opr = {
									const = 20
								}
							}
						},
						attachments = {},
						children = {}
					}
				},
				{
					node = {
						id = "392",
						class = "Condition",
						properties = {
							{
								Operator = "NotEqual"
							},
							{
								Opl = {
									func = "checkTargetIsFunctionId",
									params = {
										{
											field = "tCurrentPet"
										},
										{
											const = "ENERGY"
										}
									}
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
						id = "394",
						class = "Condition",
						properties = {
							{
								Operator = "Equal"
							},
							{
								Opl = {
									func = "checkSupportSkillCanCast",
									params = {
										{
											const = 0
										},
										{
											const = "ENERGY"
										},
										{
											const = 5
										},
										{
											const = true
										},
										{
											const = false
										}
									}
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
						id = "393",
						class = "Assignment",
						properties = {
							{
								CastRight = "false"
							},
							{
								Opl = {
									field = "combatTactic"
								}
							},
							{
								Opr = {
									const = "Tactics_SupportSkill"
								}
							}
						},
						attachments = {},
						children = {}
					}
				},
				{
					node = {
						id = "395",
						class = "Condition",
						properties = {
							{
								Operator = "Equal"
							},
							{
								Opl = {
									func = "checkSupportSkillCanCast",
									params = {
										{
											const = 0
										},
										{
											const = "ENERGY"
										},
										{
											const = 5
										},
										{
											const = true
										},
										{
											const = true
										}
									}
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
						id = "399",
						class = "Action",
						properties = {
							{
								Method = {
									func = "tryCommandPetCastSupportSkill",
									params = {
										{
											const = "ENERGY"
										},
										{
											const = 5
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

return PBT_BotPlayer_Assist_Combat_BACKSTAGE_ENERGY
