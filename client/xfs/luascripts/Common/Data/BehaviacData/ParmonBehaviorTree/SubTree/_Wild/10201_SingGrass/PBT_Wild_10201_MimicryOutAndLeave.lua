-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\_Wild\\10201_SingGrass\\PBT_Wild_10201_MimicryOutAndLeave.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Wild_10201_MimicryOutAndLeave = {
	behavior = {
		version = 15,
		name = "ParmonBehaviorTree/SubTree/_Wild/10201_SingGrass/PBT_Wild_10201_MimicryOutAndLeave",
		useForRoute = false,
		agenttype = "WxAgent",
		properties = {},
		pars = {
			{
				name = "tCharacterState",
				const = "",
				type = "string",
				value = ""
			},
			{
				name = "tTgtId",
				const = 0,
				type = "int",
				value = "0"
			},
			{
				name = "tTargetAtYawDegree",
				const = 0,
				type = "float",
				value = "0"
			},
			{
				name = "tInstant",
				const = false,
				type = "bool",
				value = "false"
			},
			{
				name = "tAnimationKey",
				const = "",
				type = "string",
				value = ""
			}
		},
		attachments = {},
		node = {
			id = "11",
			class = "Sequence",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						id = "7",
						class = "Parallel",
						properties = {
							{
								ChildFinishPolicy = "CHILDFINISH_ONCE"
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
									id = "8",
									class = "Sequence",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "9",
												class = "Action",
												properties = {
													{
														Method = {
															func = "waitTime",
															params = {
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
														ResultResumeOption = "BT_ResumeSelf"
													}
												},
												attachments = {},
												children = {}
											}
										},
										{
											node = {
												id = "5",
												class = "Action",
												properties = {
													{
														Method = {
															func = "turnToTargetAtYaw",
															params = {
																{
																	field = "tTgtId"
																},
																{
																	field = "tTargetAtYawDegree"
																},
																{
																	const = false
																},
																{
																	const = 0
																},
																{
																	field = "tInstant"
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
									id = "2",
									class = "Action",
									properties = {
										{
											Method = {
												func = "switchToState",
												params = {
													{
														field = "tCharacterState"
													},
													{
														const = 0
													},
													{
														field = "tAnimationKey"
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
						id = "13",
						class = "ReferencedBehavior",
						properties = {
							{
								ReferenceBehavior = {
									const = "PBT_Perception_Leave"
								}
							},
							{
								subTreeProperties = {
									{
										Name = "tSensorTgtId",
										Type = "Self",
										Value = {
											field = "tTgtId"
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

return PBT_Wild_10201_MimicryOutAndLeave
