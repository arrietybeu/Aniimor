-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_Pet_CommandGo_EnvObjCan.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Pet_CommandGo_EnvObjCan = {
	behavior = {
		useForRoute = false,
		name = "ParmonBehaviorTree/SubTree/PBT_Pet_CommandGo_EnvObjCan",
		version = 7,
		agenttype = "PetAgent",
		properties = {},
		pars = {
			{
				const = 0,
				name = "tTargetId",
				type = "int",
				value = "0"
			},
			{
				const = 0,
				name = "tSkillId",
				type = "int",
				value = "0"
			},
			{
				const = 0,
				name = "tTargetEnvPartId",
				type = "int",
				value = "0"
			},
			{
				const = 2,
				name = "tSpeedMulti",
				type = "float",
				value = "2"
			},
			{
				const = 0,
				name = "tSkillStopDist",
				type = "float",
				value = "0"
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
						id = "2",
						class = "Action",
						properties = {
							{
								Method = {
									func = "showMasterBubble",
									params = {
										{
											const = "go"
										},
										{
											const = 1
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
						id = "3",
						class = "Action",
						properties = {
							{
								Method = {
									func = "playMasterSound",
									params = {
										{
											const = "vox_player_go"
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
						id = "4",
						class = "IfElse",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									id = "6",
									class = "Condition",
									properties = {
										{
											Operator = "Equal"
										},
										{
											Opl = {
												func = "checkIsInRangeTgt",
												params = {
													{
														field = "tTargetId"
													},
													{
														const = 0
													},
													{
														field = "attackStopBoxDist"
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
									id = "7",
									class = "Action",
									properties = {
										{
											Method = {
												func = "turnToTarget",
												params = {
													{
														field = "tTargetId"
													},
													{
														const = false
													},
													{
														const = 0
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
											ResultResumeOption = "BT_ResumeSelf"
										}
									},
									attachments = {},
									children = {}
								}
							},
							{
								node = {
									id = "8",
									class = "Sequence",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "11",
												class = "Assignment",
												properties = {
													{
														CastRight = "false"
													},
													{
														Opl = {
															field = "tSkillStopDist"
														}
													},
													{
														Opr = {
															func = "getSkillStopBoxDist",
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
												id = "9",
												class = "Action",
												properties = {
													{
														Method = {
															func = "letGoMove",
															params = {
																{
																	field = "tTargetId"
																},
																{
																	field = "tSkillStopDist"
																},
																{
																	field = "tSpeedMulti"
																},
																{
																	const = 0
																},
																{
																	field = "tTargetEnvPartId"
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
												id = "10",
												class = "Wait",
												properties = {
													{
														Time = {
															const = 200
														}
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
				},
				{
					node = {
						id = "5",
						class = "Action",
						properties = {
							{
								Method = {
									func = "castSkill",
									params = {
										{
											field = "tTargetId"
										},
										{
											field = "tSkillId"
										},
										{
											const = false
										},
										{
											field = "tTargetEnvPartId"
										},
										{
											const = false
										},
										{
											const = BaseEnum.CastAbilitySourceType.Normal
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

return PBT_Pet_CommandGo_EnvObjCan
