-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\CombatUnit\\NPC\\BotPlayer\\PBT_BotPlayer_Combat_154042.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_BotPlayer_Combat_154042 = {
	behavior = {
		useForRoute = false,
		agenttype = "BotPlayerAgent",
		name = "CombatUnit/NPC/BotPlayer/PBT_BotPlayer_Combat_154042",
		version = 160,
		properties = {},
		pars = {
			{
				type = "int",
				value = "0",
				name = "tCurrentPet",
				const = 0
			},
			{
				type = "float",
				value = "0",
				name = "tCurrentPetHpPercent",
				const = 0
			},
			{
				type = "int",
				value = "0",
				name = "tSwitchPetId",
				const = 0
			},
			{
				type = "int",
				value = "0",
				name = "tTargetSkillId",
				const = 0
			},
			{
				type = "float",
				value = "0",
				name = "tCurrentEp",
				const = 0
			},
			{
				type = "int",
				value = "0",
				name = "Pet",
				const = 0
			},
			{
				type = "int",
				value = "0",
				name = "PetId",
				const = 0
			},
			{
				type = "int",
				value = "0",
				name = "CheckPlayerPetId",
				const = 0
			},
			{
				type = "int",
				value = "0",
				name = "FirstAddBuff",
				const = 0
			}
		},
		attachments = {},
		node = {
			class = "DecoratorLoop",
			id = "489",
			properties = {
				{
					Count = {
						const = -1
					}
				},
				{
					DecorateWhenChildEnds = "false"
				},
				{
					DoneWithinFrame = "false"
				}
			},
			attachments = {},
			children = {
				{
					node = {
						class = "Sequence",
						id = "492",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									class = "Sequence",
									id = "490",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												class = "Assignment",
												id = "495",
												properties = {
													{
														CastRight = "false"
													},
													{
														Opl = {
															field = "tCurrentPet"
														}
													},
													{
														Opr = {
															func = "getPetActorId",
															params = {
																{
																	const = 0
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
												class = "Assignment",
												id = "491",
												properties = {
													{
														CastRight = "false"
													},
													{
														Opl = {
															field = "tCurrentPetHpPercent"
														}
													},
													{
														Opr = {
															func = "getHpPercent",
															params = {
																{
																	field = "tCurrentPet"
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
												class = "Assignment",
												id = "493",
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
															const = "common"
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
												id = "494",
												properties = {
													{
														CastRight = "false"
													},
													{
														Opl = {
															field = "tCurrentEp"
														}
													},
													{
														Opr = {
															func = "getEp",
															params = {
																{
																	field = "selfId"
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
												class = "Assignment",
												id = "496",
												properties = {
													{
														CastRight = "false"
													},
													{
														Opl = {
															field = "tgt"
														}
													},
													{
														Opr = {
															func = "getTarget"
														}
													}
												},
												attachments = {},
												children = {}
											}
										}
									}
								}
							},
							{
								node = {
									class = "Sequence",
									id = "500",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												class = "Action",
												id = "497",
												properties = {
													{
														Method = {
															func = "waitTime",
															params = {
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
					}
				}
			}
		}
	}
}

return PBT_BotPlayer_Combat_154042
