-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_10581_CastSkill.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_10581_CastSkill = {
	behavior = {
		useForRoute = false,
		name = "ParmonBehaviorTree/SubTree/PBT_10581_CastSkill",
		agenttype = "CombatAgent",
		version = 14,
		properties = {},
		pars = {
			{
				type = "int",
				value = "0",
				const = 0,
				name = "tSensorTgtId"
			}
		},
		attachments = {},
		node = {
			class = "Sequence",
			id = "30",
			properties = {},
			attachments = {
				{
					class = "Effector",
					effector = true,
					precondition = false,
					transition = false,
					id = "5",
					properties = {
						{
							Operator = "Invalid"
						},
						{
							Opl = {
								func = "removeEntityTag",
								params = {
									{
										field = "selfId"
									},
									{
										const = "TE_Par_Leave"
									}
								}
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
						class = "Sequence",
						id = "26",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									class = "Action",
									id = "25",
									properties = {
										{
											Method = {
												func = "setAttenuationMultiple",
												params = {
													{
														field = "selfId"
													},
													{
														const = 0.1
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
									class = "IfElse",
									id = "27",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												class = "Condition",
												id = "28",
												properties = {
													{
														Operator = "Equal"
													},
													{
														Opl = {
															field = "tSensorTgtId"
														}
													},
													{
														Opr = {
															const = 0
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
												id = "24",
												properties = {
													{
														CastRight = "false"
													},
													{
														Opl = {
															field = "tSensorTgtId"
														}
													},
													{
														Opr = {
															func = "getPerceptibilityTarget"
														}
													}
												},
												attachments = {},
												children = {}
											}
										},
										{
											node = {
												class = "True",
												id = "29",
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
				},
				{
					node = {
						class = "IfElse",
						id = "14",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									class = "Condition",
									id = "16",
									properties = {
										{
											Operator = "Equal"
										},
										{
											Opl = {
												func = "checkCharacterState",
												params = {
													{
														const = "LOCOMOTION"
													},
													{
														field = "selfId"
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
									class = "Sequence",
									id = "17",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												class = "Action",
												id = "5",
												properties = {
													{
														Method = {
															func = "showEmojiBubble",
															params = {
																{
																	const = "Surprise"
																},
																{
																	const = 3
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
												id = "7",
												properties = {
													{
														Method = {
															func = "castSkill",
															params = {
																{
																	const = 0
																},
																{
																	const = 15810910
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
																	const = BaseEnum.CastAbilitySourceType.Normal
																}
															}
														}
													},
													{
														ResultOption = "BT_INVALID"
													},
													{
														ResultResumeOption = "BT_NextNode"
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
									id = "18",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												class = "Selector",
												id = "19",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															class = "Action",
															id = "23",
															properties = {
																{
																	Method = {
																		func = "leaveTargetInCatchFailure",
																		params = {
																			{
																				field = "tSensorTgtId"
																			},
																			{
																				const = 35
																			},
																			{
																				const = 3.5
																			},
																			{
																				const = BaseEnum.SpeedRateType.Mid
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
																	class = "Effector",
																	effector = true,
																	precondition = false,
																	transition = false,
																	id = "100",
																	properties = {
																		{
																			Operator = "Invalid"
																		},
																		{
																			Opl = {
																				func = "setAttenuationMultiple",
																				params = {
																					{
																						field = "selfId"
																					},
																					{
																						const = 1
																					}
																				}
																			}
																		},
																		{
																			Phase = "Both"
																		}
																	}
																}
															},
															children = {}
														}
													},
													{
														node = {
															class = "Action",
															id = "20",
															properties = {
																{
																	Method = {
																		func = "enterDestroySelf"
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
										},
										{
											node = {
												class = "Action",
												id = "22",
												properties = {
													{
														Method = {
															func = "enterDestroySelf"
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
					}
				}
			}
		}
	}
}

return PBT_10581_CastSkill
