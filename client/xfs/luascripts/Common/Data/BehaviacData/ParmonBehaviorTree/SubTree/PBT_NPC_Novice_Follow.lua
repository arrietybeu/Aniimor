-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_NPC_Novice_Follow.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_NPC_Novice_Follow = {
	behavior = {
		name = "ParmonBehaviorTree/SubTree/PBT_NPC_Novice_Follow",
		useForRoute = false,
		version = 6,
		agenttype = "PuppetAgent",
		properties = {},
		pars = {
			{
				name = "tFollowEntActorID",
				value = "0",
				const = 0,
				type = "int"
			}
		},
		attachments = {},
		node = {
			class = "DecoratorLoop",
			id = "3",
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
						id = "4",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									class = "IfElse",
									id = "23",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												class = "Condition",
												id = "17",
												properties = {
													{
														Operator = "GreaterEqual"
													},
													{
														Opl = {
															func = "getDistByTgt",
															params = {
																{
																	field = "tFollowEntActorID"
																},
																{
																	const = false
																},
																{
																	const = false
																},
																{
																	const = 0
																}
															}
														}
													},
													{
														Opr = {
															const = 10
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
												id = "14",
												properties = {
													{
														Method = {
															func = "teleportToTargetSide",
															params = {
																{
																	field = "tFollowEntActorID"
																},
																{
																	const = 1
																},
																{
																	const = 4
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
												class = "Noop",
												id = "24",
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
									id = "13",
									properties = {
										{
											Method = {
												func = "moveToAppointedArea",
												params = {
													{
														field = "tFollowEntActorID"
													},
													{
														const = "NPCFollowNormalArea"
													},
													{
														const = "NPCNoviceStartArea"
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
									attachments = {
										{
											class = "Precondition",
											effector = false,
											precondition = true,
											transition = false,
											id = "25",
											properties = {
												{
													BinaryOperator = "And"
												},
												{
													Operator = "Less"
												},
												{
													Opl = {
														func = "getDistByTgt",
														params = {
															{
																field = "tFollowEntActorID"
															},
															{
																const = false
															},
															{
																const = false
															},
															{
																const = 0
															}
														}
													}
												},
												{
													Opr2 = {
														const = 10
													}
												},
												{
													Phase = "Update"
												}
											}
										}
									},
									children = {}
								}
							},
							{
								node = {
									class = "DecoratorLoop",
									id = "29",
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
									attachments = {
										{
											class = "Precondition",
											effector = false,
											precondition = true,
											transition = false,
											id = "30",
											properties = {
												{
													BinaryOperator = "And"
												},
												{
													Operator = "LessEqual"
												},
												{
													Opl = {
														func = "getDistByTgt",
														params = {
															{
																field = "tFollowEntActorID"
															},
															{
																const = false
															},
															{
																const = false
															},
															{
																const = 0
															}
														}
													}
												},
												{
													Opr2 = {
														const = 3
													}
												},
												{
													Phase = "Enter"
												}
											}
										}
									},
									children = {
										{
											node = {
												class = "Sequence",
												id = "28",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															class = "Action",
															id = "31",
															properties = {
																{
																	Method = {
																		func = "turnToTarget",
																		params = {
																			{
																				field = "tFollowEntActorID"
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
															class = "Action",
															id = "26",
															properties = {
																{
																	Method = {
																		func = "playNPCWaitAnimation"
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
															class = "Action",
															id = "27",
															properties = {
																{
																	Method = {
																		func = "waitTime",
																		params = {
																			{
																				const = 10
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
		}
	}
}

return PBT_NPC_Novice_Follow
