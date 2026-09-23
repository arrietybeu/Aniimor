-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_Pet_CommandGo_NoTarget.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Pet_CommandGo_NoTarget = {
	behavior = {
		name = "ParmonBehaviorTree/SubTree/PBT_Pet_CommandGo_NoTarget",
		agenttype = "PetAgent",
		version = 5,
		useForRoute = false,
		properties = {},
		pars = {
			{
				name = "tNearbyEnvObjActorId",
				type = "int",
				const = 0,
				value = "0"
			},
			{
				name = "tCommandSkillId",
				type = "int",
				const = 0,
				value = "0"
			},
			{
				name = "tDistToTgtForSkill",
				type = "float",
				const = 0,
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
									id = "10",
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
														field = "masterId"
													},
													{
														const = 0
													},
													{
														const = 8
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
									id = "8",
									class = "Noop",
									properties = {},
									attachments = {},
									children = {}
								}
							},
							{
								node = {
									id = "18",
									class = "Action",
									properties = {
										{
											Method = {
												func = "teleportToTargetSide",
												params = {
													{
														field = "masterId"
													},
													{
														const = 0
													},
													{
														const = 3
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
				},
				{
					node = {
						id = "5",
						class = "Action",
						properties = {
							{
								Method = {
									func = "letGoMoveFail",
									params = {
										{
											const = 6
										},
										{
											const = 2
										},
										{
											const = 0
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
						id = "6",
						class = "Sequence",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									id = "11",
									class = "Action",
									properties = {
										{
											Method = {
												func = "showEmojiBubble",
												params = {
													{
														const = "Think"
													},
													{
														const = 2.5
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
									id = "17",
									class = "Action",
									properties = {
										{
											Method = {
												func = "waitTime",
												params = {
													{
														const = 2
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
									id = "12",
									class = "Selector",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "13",
												class = "DecoratorTime",
												properties = {
													{
														Time = {
															const = 500
														}
													},
													{
														DecorateWhenChildEnds = "true"
													}
												},
												attachments = {
													{
														precondition = true,
														id = "16",
														class = "Precondition",
														transition = false,
														effector = false,
														properties = {
															{
																BinaryOperator = "And"
															},
															{
																Operator = "Equal"
															},
															{
																Opl = {
																	func = "checkIsInRangeTgt2D",
																	params = {
																		{
																			field = "masterId"
																		},
																		{
																			const = 0
																		},
																		{
																			const = 20
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
																Opr2 = {
																	const = true
																}
															},
															{
																Phase = "Update"
															}
														}
													}
												},
												children = {
													{
														node = {
															id = "15",
															class = "Action",
															properties = {
																{
																	Method = {
																		func = "turnToTarget",
																		params = {
																			{
																				field = "masterId"
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
													}
												}
											}
										},
										{
											node = {
												id = "14",
												class = "Noop",
												properties = {},
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

return PBT_Pet_CommandGo_NoTarget
