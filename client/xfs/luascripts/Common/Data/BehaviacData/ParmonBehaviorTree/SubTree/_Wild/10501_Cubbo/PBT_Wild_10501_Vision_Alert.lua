-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\_Wild\\10501_Cubbo\\PBT_Wild_10501_Vision_Alert.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Wild_10501_Vision_Alert = {
	behavior = {
		name = "ParmonBehaviorTree/SubTree/_Wild/10501_Cubbo/PBT_Wild_10501_Vision_Alert",
		version = 19,
		useForRoute = false,
		agenttype = "CombatAgent",
		properties = {},
		pars = {
			{
				name = "tSensorTgtId",
				const = 0,
				type = "int",
				value = "0"
			},
			{
				name = "tRandomWaitTime",
				const = 0,
				type = "float",
				value = "0"
			},
			{
				name = "tRandomWaitTime2",
				const = 0,
				type = "float",
				value = "0"
			}
		},
		attachments = {},
		node = {
			class = "Sequence",
			id = "1",
			properties = {},
			attachments = {
				{
					class = "Effector",
					effector = true,
					precondition = false,
					transition = false,
					id = "41",
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
										const = "TE_Par_Alert"
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
						class = "Assignment",
						id = "29",
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
						class = "Action",
						id = "44",
						properties = {
							{
								Method = {
									func = "addEntityTag",
									params = {
										{
											field = "selfId"
										},
										{
											const = "TE_Par_Alert"
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
						class = "Sequence",
						id = "3",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									class = "Action",
									id = "8",
									properties = {
										{
											Method = {
												func = "showQuestionMark",
												params = {
													{
														const = "Normal"
													},
													{
														const = 1.8
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
									class = "Selector",
									id = "36",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												class = "Sequence",
												id = "38",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															class = "Condition",
															id = "34",
															properties = {
																{
																	Operator = "Equal"
																},
																{
																	Opl = {
																		func = "checkCharacterState",
																		params = {
																			{
																				const = "CLIMBING"
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
															class = "Action",
															id = "39",
															properties = {
																{
																	Method = {
																		func = "switchToState",
																		params = {
																			{
																				const = "AIRING"
																			},
																			{
																				const = -1
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
										},
										{
											node = {
												class = "True",
												id = "37",
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
									class = "Sequence",
									id = "22",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												class = "Selector",
												id = "32",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															class = "Sequence",
															id = "30",
															properties = {},
															attachments = {},
															children = {
																{
																	node = {
																		class = "Condition",
																		id = "27",
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
																		class = "Action",
																		id = "45",
																		properties = {
																			{
																				Method = {
																					func = "turnToTarget",
																					params = {
																						{
																							field = "tSensorTgtId"
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
															class = "True",
															id = "33",
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
												class = "Assignment",
												id = "21",
												properties = {
													{
														CastRight = "false"
													},
													{
														Opl = {
															field = "tRandomWaitTime2"
														}
													},
													{
														Opr = {
															func = "getRandomFloat",
															params = {
																{
																	const = 1
																},
																{
																	const = 1.5
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
												class = "Action",
												id = "19",
												properties = {
													{
														Method = {
															func = "waitTime",
															params = {
																{
																	field = "tRandomWaitTime2"
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

return PBT_Wild_10501_Vision_Alert
