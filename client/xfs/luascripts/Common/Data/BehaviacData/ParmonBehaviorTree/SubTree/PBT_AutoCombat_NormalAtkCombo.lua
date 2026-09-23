-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_AutoCombat_NormalAtkCombo.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_AutoCombat_NormalAtkCombo = {
	behavior = {
		version = 41,
		useForRoute = false,
		agenttype = "PetAgent",
		name = "ParmonBehaviorTree/SubTree/PBT_AutoCombat_NormalAtkCombo",
		properties = {},
		pars = {
			{
				type = "float",
				value = "0",
				name = "CurrentDistToTarget",
				const = 0
			},
			{
				type = "float",
				value = "0",
				name = "CurrentBoxDistToTarget",
				const = 0
			},
			{
				type = "float",
				value = "0",
				name = "tMaxAttackDist",
				const = 0
			}
		},
		attachments = {},
		node = {
			id = "82",
			class = "Sequence",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						id = "84",
						class = "Compute",
						properties = {
							{
								Operator = "Add"
							},
							{
								Opl = {
									field = "tMaxAttackDist"
								}
							},
							{
								Opr1 = {
									field = "maxAttackDist"
								}
							},
							{
								Opr2 = {
									const = 3
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
						class = "IfElse",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									id = "67",
									class = "Or",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "65",
												class = "Condition",
												properties = {
													{
														Operator = "Less"
													},
													{
														Opl = {
															field = "CurrentDistToTarget"
														}
													},
													{
														Opr = {
															field = "minAttackDist"
														}
													}
												},
												attachments = {},
												children = {}
											}
										},
										{
											node = {
												id = "66",
												class = "Condition",
												properties = {
													{
														Operator = "Greater"
													},
													{
														Opl = {
															field = "CurrentDistToTarget"
														}
													},
													{
														Opr = {
															field = "maxAttackDist"
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
									id = "69",
									class = "Sequence",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "70",
												class = "Action",
												properties = {
													{
														Method = {
															func = "moveToTarget",
															params = {
																{
																	field = "tgt"
																},
																{
																	field = "attackStopBoxDist"
																},
																{
																	const = 5
																},
																{
																	const = false
																},
																{
																	const = false
																},
																{
																	const = true
																},
																{
																	const = 0
																},
																{
																	const = BaseEnum.MoveUpdateLevel.Normal
																},
																{
																	const = BaseEnum.PathFindType.Voxel
																},
																{
																	const = BaseEnum.SpeedRateType.Mid
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
														ResultResumeOption = "BT_ResumeTree"
													}
												},
												attachments = {},
												children = {}
											}
										},
										{
											node = {
												id = "73",
												class = "Parallel",
												properties = {
													{
														ChildFinishPolicy = "CHILDFINISH_LOOP"
													},
													{
														ExitPolicy = "EXIT_ABORT_RUNNINGSIBLINGS"
													},
													{
														FailurePolicy = "FAIL_ON_ONE"
													},
													{
														SuccessPolicy = "SUCCEED_ON_ALL"
													}
												},
												attachments = {},
												children = {
													{
														node = {
															id = "72",
															class = "Action",
															properties = {
																{
																	Method = {
																		func = "castNormalAtkCombo",
																		params = {
																			{
																				field = "tgt"
																			},
																			{
																				const = 0
																			},
																			{
																				const = true
																			},
																			{
																				const = 2
																			},
																			{
																				const = true
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
																	ResultResumeOption = "BT_ResumeTree"
																}
															},
															attachments = {
																{
																	transition = false,
																	effector = false,
																	precondition = true,
																	id = "356",
																	class = "Precondition",
																	properties = {
																		{
																			BinaryOperator = "And"
																		},
																		{
																			Operator = "LessEqual"
																		},
																		{
																			Opl = {
																				field = "CurrentDistToTarget"
																			}
																		},
																		{
																			Opr2 = {
																				field = "tMaxAttackDist"
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
															id = "74",
															class = "Assignment",
															properties = {
																{
																	CastRight = "false"
																},
																{
																	Opl = {
																		field = "CurrentDistToTarget"
																	}
																},
																{
																	Opr = {
																		func = "getDistByTgt",
																		params = {
																			{
																				field = "tgt"
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
									id = "77",
									class = "Parallel",
									properties = {
										{
											ChildFinishPolicy = "CHILDFINISH_LOOP"
										},
										{
											ExitPolicy = "EXIT_ABORT_RUNNINGSIBLINGS"
										},
										{
											FailurePolicy = "FAIL_ON_ONE"
										},
										{
											SuccessPolicy = "SUCCEED_ON_ALL"
										}
									},
									attachments = {},
									children = {
										{
											node = {
												id = "71",
												class = "Action",
												properties = {
													{
														Method = {
															func = "castNormalAtkCombo",
															params = {
																{
																	field = "tgt"
																},
																{
																	const = 0
																},
																{
																	const = true
																},
																{
																	const = 2
																},
																{
																	const = true
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
														ResultResumeOption = "BT_ResumeTree"
													}
												},
												attachments = {
													{
														transition = false,
														effector = false,
														precondition = true,
														id = "356",
														class = "Precondition",
														properties = {
															{
																BinaryOperator = "And"
															},
															{
																Operator = "LessEqual"
															},
															{
																Opl = {
																	field = "CurrentDistToTarget"
																}
															},
															{
																Opr2 = {
																	field = "tMaxAttackDist"
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
												id = "76",
												class = "Assignment",
												properties = {
													{
														CastRight = "false"
													},
													{
														Opl = {
															field = "CurrentDistToTarget"
														}
													},
													{
														Opr = {
															func = "getDistByTgt",
															params = {
																{
																	field = "tgt"
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

return PBT_AutoCombat_NormalAtkCombo
