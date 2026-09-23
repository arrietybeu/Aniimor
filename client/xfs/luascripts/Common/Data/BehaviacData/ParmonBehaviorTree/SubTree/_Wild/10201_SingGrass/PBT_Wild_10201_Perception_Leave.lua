-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\_Wild\\10201_SingGrass\\PBT_Wild_10201_Perception_Leave.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Wild_10201_Perception_Leave = {
	behavior = {
		version = 29,
		useForRoute = false,
		agenttype = "PuppetAgent",
		name = "ParmonBehaviorTree/SubTree/_Wild/10201_SingGrass/PBT_Wild_10201_Perception_Leave",
		properties = {},
		pars = {
			{
				type = "int",
				value = "0",
				name = "tSensorTgtId",
				const = 0
			},
			{
				type = "int",
				value = "0",
				name = "tTgtId",
				const = 0
			},
			{
				type = "string",
				value = "0",
				name = "tCharacterState",
				const = "0"
			}
		},
		attachments = {},
		node = {
			id = "18",
			class = "Sequence",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						id = "24",
						class = "Assignment",
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
						id = "19",
						class = "Action",
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
				},
				{
					node = {
						id = "21",
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
				},
				{
					node = {
						id = "71",
						class = "DecoratorAlwaysSuccess",
						properties = {
							{
								DecorateWhenChildEnds = "true"
							}
						},
						attachments = {},
						children = {
							{
								node = {
									id = "69",
									class = "Sequence",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "72",
												class = "Condition",
												properties = {
													{
														Operator = "Equal"
													},
													{
														Opl = {
															func = "checkCharacterState",
															params = {
																{
																	const = "MIMICRY"
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
												id = "68",
												class = "Action",
												properties = {
													{
														Method = {
															func = "switchToState",
															params = {
																{
																	const = "LOCOMOTION"
																},
																{
																	const = 5
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
										},
										{
											node = {
												id = "73",
												class = "Action",
												properties = {
													{
														Method = {
															func = "sendMessageToTrigger",
															params = {
																{
																	field = "selfId"
																},
																{
																	const = 1016
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
					}
				},
				{
					node = {
						id = "47",
						class = "SelectorProbability",
						properties = {
							{
								UntilSuccessOrEnd = false
							}
						},
						attachments = {},
						children = {
							{
								node = {
									id = "49",
									class = "DecoratorWeight",
									properties = {
										{
											DecorateWhenChildEnds = "false"
										},
										{
											Weight = {
												const = 10
											}
										}
									},
									attachments = {},
									children = {
										{
											node = {
												id = "8",
												class = "Sequence",
												properties = {},
												attachments = {},
												children = {
													{
														node = {
															id = "15",
															class = "Action",
															properties = {
																{
																	Method = {
																		func = "showEmojiBubble",
																		params = {
																			{
																				const = "Happy"
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
															id = "14",
															class = "Action",
															properties = {
																{
																	Method = {
																		func = "playPhaseAction",
																		params = {
																			{
																				const = "Behav_HappyStart"
																			},
																			{
																				const = "Behav_HappyLoop"
																			},
																			{
																				const = "Behav_HappyEnd"
																			},
																			{
																				const = 0
																			},
																			{
																				const = ""
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
															id = "67",
															class = "ReferencedBehavior",
															properties = {
																{
																	ReferenceBehavior = {
																		const = "PBT_Perception_Leave"
																	}
																},
																{
																	subTreeProperties = {}
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
									id = "50",
									class = "DecoratorWeight",
									properties = {
										{
											DecorateWhenChildEnds = "false"
										},
										{
											Weight = {
												const = 90
											}
										}
									},
									attachments = {},
									children = {
										{
											node = {
												id = "66",
												class = "ReferencedBehavior",
												properties = {
													{
														ReferenceBehavior = {
															const = "PBT_Perception_Leave"
														}
													},
													{
														subTreeProperties = {}
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

return PBT_Wild_10201_Perception_Leave
