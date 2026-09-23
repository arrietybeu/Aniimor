-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_RandomCustomAnimation_GDC.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_RandomCustomAnimation_GDC = {
	behavior = {
		useForRoute = false,
		agenttype = "PuppetAgent",
		name = "ParmonBehaviorTree/SubTree/PBT_RandomCustomAnimation_GDC",
		version = 5,
		properties = {},
		pars = {
			{
				name = "tFollowTgtId",
				type = "int",
				const = 0,
				value = "0"
			}
		},
		attachments = {},
		node = {
			class = "DecoratorLoop",
			id = "15",
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
					transition = false,
					id = "16",
					precondition = true,
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
										field = "tFollowTgtId"
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
							Phase = "Both"
						}
					}
				}
			},
			children = {
				{
					node = {
						class = "SelectorProbability",
						id = "2",
						properties = {
							{
								UntilSuccessOrEnd = false
							}
						},
						attachments = {},
						children = {
							{
								node = {
									class = "DecoratorWeight",
									id = "4",
									properties = {
										{
											DecorateWhenChildEnds = "false"
										},
										{
											Weight = {
												const = 30
											}
										}
									},
									attachments = {},
									children = {
										{
											node = {
												class = "Action",
												id = "3",
												properties = {
													{
														Method = {
															func = "playAction",
															params = {
																{
																	const = "Behav_Happy"
																},
																{
																	const = 5
																},
																{
																	const = ""
																},
																{
																	const = false
																},
																{
																	const = false
																},
																{
																	const = 0
																},
																{
																	const = BaseEnum.AIAnimationRootMotionType.Default
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
									class = "DecoratorWeight",
									id = "6",
									properties = {
										{
											DecorateWhenChildEnds = "false"
										},
										{
											Weight = {
												const = 40
											}
										}
									},
									attachments = {},
									children = {
										{
											node = {
												class = "Action",
												id = "5",
												properties = {
													{
														Method = {
															func = "playAction",
															params = {
																{
																	const = "Behav_Love"
																},
																{
																	const = 5
																},
																{
																	const = ""
																},
																{
																	const = false
																},
																{
																	const = false
																},
																{
																	const = 0
																},
																{
																	const = BaseEnum.AIAnimationRootMotionType.Default
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
									class = "DecoratorWeight",
									id = "19",
									properties = {
										{
											DecorateWhenChildEnds = "false"
										},
										{
											Weight = {
												const = 50
											}
										}
									},
									attachments = {},
									children = {
										{
											node = {
												class = "Action",
												id = "18",
												properties = {
													{
														Method = {
															func = "playAction",
															params = {
																{
																	const = "Env_FlapHair"
																},
																{
																	const = 5
																},
																{
																	const = ""
																},
																{
																	const = false
																},
																{
																	const = false
																},
																{
																	const = 0
																},
																{
																	const = BaseEnum.AIAnimationRootMotionType.Default
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
									class = "DecoratorWeight",
									id = "21",
									properties = {
										{
											DecorateWhenChildEnds = "false"
										},
										{
											Weight = {
												const = 30
											}
										}
									},
									attachments = {},
									children = {
										{
											node = {
												class = "Action",
												id = "20",
												properties = {
													{
														Method = {
															func = "playAction",
															params = {
																{
																	const = "IdleSpecial"
																},
																{
																	const = 3
																},
																{
																	const = ""
																},
																{
																	const = false
																},
																{
																	const = false
																},
																{
																	const = 0
																},
																{
																	const = BaseEnum.AIAnimationRootMotionType.Default
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
									class = "DecoratorWeight",
									id = "22",
									properties = {
										{
											DecorateWhenChildEnds = "false"
										},
										{
											Weight = {
												const = 30
											}
										}
									},
									attachments = {},
									children = {
										{
											node = {
												class = "Action",
												id = "23",
												properties = {
													{
														Method = {
															func = "playAction",
															params = {
																{
																	const = "IdleSpecial02"
																},
																{
																	const = 3
																},
																{
																	const = ""
																},
																{
																	const = false
																},
																{
																	const = false
																},
																{
																	const = 0
																},
																{
																	const = BaseEnum.AIAnimationRootMotionType.Default
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
									class = "DecoratorWeight",
									id = "24",
									properties = {
										{
											DecorateWhenChildEnds = "false"
										},
										{
											Weight = {
												const = 20
											}
										}
									},
									attachments = {},
									children = {
										{
											node = {
												class = "Action",
												id = "25",
												properties = {
													{
														Method = {
															func = "playAction",
															params = {
																{
																	const = "Idle"
																},
																{
																	const = 3
																},
																{
																	const = ""
																},
																{
																	const = false
																},
																{
																	const = false
																},
																{
																	const = 0
																},
																{
																	const = BaseEnum.AIAnimationRootMotionType.Default
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

return PBT_RandomCustomAnimation_GDC
