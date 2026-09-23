-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\_Behav\\PBT_Behav_Home_Leisure_Petting.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Behav_Home_Leisure_Petting = {
	behavior = {
		name = "ParmonBehaviorTree/SubTree/_Behav/PBT_Behav_Home_Leisure_Petting",
		agenttype = "CombatAgent",
		version = 30,
		useForRoute = false,
		properties = {},
		pars = {
			{
				name = "tTargetActorId",
				const = 0,
				value = "0",
				type = "int"
			},
			{
				name = "tIsMasterInIdle",
				const = false,
				value = "false",
				type = "bool"
			},
			{
				name = "tMoveDist",
				const = 0,
				value = "0",
				type = "float"
			},
			{
				name = "tStopLoop",
				const = 0,
				value = "0",
				type = "int"
			},
			{
				name = "tEmojiKey",
				const = "",
				value = "",
				type = "string"
			},
			{
				name = "tAnimationStartKey",
				const = "",
				value = "",
				type = "string"
			},
			{
				name = "tAnimationLoopKey",
				const = "",
				value = "",
				type = "string"
			},
			{
				name = "tAnimationEndKey",
				const = "",
				value = "",
				type = "string"
			}
		},
		attachments = {},
		node = {
			id = "69",
			class = "Sequence",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						id = "71",
						class = "Assignment",
						properties = {
							{
								CastRight = "false"
							},
							{
								Opl = {
									field = "tMoveDist"
								}
							},
							{
								Opr = {
									const = 1.5
								}
							}
						},
						attachments = {},
						children = {}
					}
				},
				{
					node = {
						id = "89",
						class = "DecoratorLoop",
						properties = {
							{
								Count = {
									const = -1
								}
							},
							{
								DecorateWhenChildEnds = "true"
							},
							{
								DoneWithinFrame = "false"
							}
						},
						attachments = {
							{
								precondition = true,
								id = "97",
								class = "Precondition",
								transition = false,
								effector = false,
								properties = {
									{
										BinaryOperator = "And"
									},
									{
										Operator = "NotEqual"
									},
									{
										Opl = {
											field = "tStopLoop"
										}
									},
									{
										Opr2 = {
											const = 1
										}
									},
									{
										Phase = "Both"
									}
								}
							}
						},
						children = {
							{
								node = {
									id = "82",
									class = "Sequence",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "60",
												class = "IfElse",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "68",
															class = "Condition",
															properties = {
																{
																	Operator = "GreaterEqual"
																},
																{
																	Opl = {
																		func = "getDistByTgt",
																		params = {
																			{
																				field = "tTargetActorId"
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
																		field = "tMoveDist"
																	}
																}
															},
															attachments = {},
															children = {}
														}
													},
													{
														node = {
															id = "90",
															class = "Selector",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		id = "54",
																		class = "Action",
																		properties = {
																			{
																				Method = {
																					func = "followTargetByRelativePos",
																					params = {
																						{
																							field = "tTargetActorId"
																						},
																						{
																							const = 10
																						},
																						{
																							const = 2
																						},
																						{
																							const = 0
																						},
																						{
																							const = 0
																						},
																						{
																							const = 0
																						},
																						{
																							const = 2
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
																		id = "98",
																		class = "Assignment",
																		properties = {
																			{
																				CastRight = "false"
																			},
																			{
																				Opl = {
																					field = "tStopLoop"
																				}
																			},
																			{
																				Opr = {
																					const = 1
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
															id = "74",
															class = "Action",
															properties = {
																{
																	Method = {
																		func = "waitTime",
																		params = {
																			{
																				const = 0.5
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
												id = "83",
												class = "Sequence",
												properties = {},
												attachments = {
													{
														precondition = true,
														id = "87",
														class = "Precondition",
														transition = false,
														effector = false,
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
																			field = "tTargetActorId"
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
																	const = 4
																}
															},
															{
																Phase = "Both"
															}
														}
													}
												},
												children = {
													{
														node = {
															id = "86",
															class = "Action",
															properties = {
																{
																	Method = {
																		func = "showEmojiBubble",
																		params = {
																			{
																				field = "tEmojiKey"
																			},
																			{
																				const = 5
																			},
																			{
																				const = false
																			},
																			{
																				const = true
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
															id = "85",
															class = "Action",
															properties = {
																{
																	Method = {
																		func = "playSleAnimationOnce",
																		params = {
																			{
																				field = "tAnimationStartKey"
																			},
																			{
																				field = "tAnimationLoopKey"
																			},
																			{
																				field = "tAnimationEndKey"
																			},
																			{
																				const = ""
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

return PBT_Behav_Home_Leisure_Petting
