-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_Test_WalkAnimation.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Test_WalkAnimation = {
	behavior = {
		version = 19,
		useForRoute = false,
		agenttype = "PetAgent",
		name = "ParmonBehaviorTree/SubTree/PBT_Test_WalkAnimation",
		properties = {},
		pars = {},
		attachments = {},
		node = {
			id = "47",
			class = "DecoratorLoop",
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
						id = "26",
						class = "Sequence",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									id = "36",
									class = "Selector",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "29",
												class = "Action",
												properties = {
													{
														Method = {
															func = "sideWalk",
															params = {
																{
																	field = "selfId"
																},
																{
																	const = 5
																},
																{
																	const = 180
																},
																{
																	const = 8
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
												id = "37",
												class = "Noop",
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
									id = "39",
									class = "Selector",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "40",
												class = "Action",
												properties = {
													{
														Method = {
															func = "sideWalk",
															params = {
																{
																	field = "selfId"
																},
																{
																	const = 5
																},
																{
																	const = 0
																},
																{
																	const = 8
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
												id = "38",
												class = "Noop",
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
									id = "43",
									class = "Selector",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "41",
												class = "Action",
												properties = {
													{
														Method = {
															func = "sideWalk",
															params = {
																{
																	field = "selfId"
																},
																{
																	const = 5
																},
																{
																	const = 90
																},
																{
																	const = 8
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
												id = "42",
												class = "Noop",
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
									id = "46",
									class = "Selector",
									properties = {},
									attachments = {},
									children = {
										{
											node = {
												id = "44",
												class = "Action",
												properties = {
													{
														Method = {
															func = "sideWalk",
															params = {
																{
																	field = "selfId"
																},
																{
																	const = 5
																},
																{
																	const = -90
																},
																{
																	const = 8
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
												id = "45",
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

return PBT_Test_WalkAnimation
