-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_Pet_CommandGo_EnvObjCannot.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Pet_CommandGo_EnvObjCannot = {
	behavior = {
		useForRoute = false,
		agenttype = "PetAgent",
		name = "ParmonBehaviorTree/SubTree/PBT_Pet_CommandGo_EnvObjCannot",
		version = 8,
		properties = {},
		pars = {
			{
				value = "0",
				const = 0,
				type = "int",
				name = "tTargetId"
			},
			{
				value = "0",
				const = 0,
				type = "int",
				name = "tTargetEnvPartId"
			},
			{
				value = "0",
				const = 0,
				type = "float",
				name = "tSpeedMulti"
			}
		},
		attachments = {},
		node = {
			id = "3",
			class = "Sequence",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						id = "5",
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
						id = "6",
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
									id = "7",
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
												const = false
											}
										}
									},
									attachments = {},
									children = {}
								}
							},
							{
								node = {
									id = "24",
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
									id = "9",
									class = "Sequence",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "25",
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
																	field = "attackStopBoxDist"
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
												id = "26",
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
						id = "27",
						class = "Sequence",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									id = "28",
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
														const = 5
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
									id = "29",
									class = "Selector",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "30",
												class = "DecoratorTime",
												properties = {
													{
														Time = {
															const = 6000
														}
													},
													{
														DecorateWhenChildEnds = "true"
													}
												},
												attachments = {
													{
														transition = false,
														effector = false,
														precondition = true,
														id = "32",
														class = "Precondition",
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
															id = "33",
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
													}
												}
											}
										},
										{
											node = {
												id = "31",
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

return PBT_Pet_CommandGo_EnvObjCannot
