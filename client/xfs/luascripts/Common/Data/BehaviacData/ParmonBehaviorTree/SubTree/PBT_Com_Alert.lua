-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_Com_Alert.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Com_Alert = {
	behavior = {
		name = "ParmonBehaviorTree/SubTree/PBT_Com_Alert",
		version = 7,
		useForRoute = false,
		agenttype = "CombatAgent",
		properties = {},
		pars = {
			{
				name = "tTargetActorId",
				type = "int",
				const = 0,
				value = "0"
			}
		},
		attachments = {},
		node = {
			class = "Sequence",
			id = "8",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						class = "Sequence",
						id = "4",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									class = "Action",
									id = "2",
									properties = {
										{
											Method = {
												func = "moveToTargetPos",
												params = {
													{
														field = "tTargetActorId"
													},
													{
														const = 340
													},
													{
														const = 5
													},
													{
														const = 0
													},
													{
														const = 30
													},
													{
														const = true
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
														const = BaseEnum.SpeedRateType.Mid
													},
													{
														const = BaseEnum.PathFindType.Auto
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
											ResultResumeOption = "BT_ResumeSelf"
										}
									},
									attachments = {},
									children = {}
								}
							},
							{
								node = {
									class = "Action",
									id = "5",
									properties = {
										{
											Method = {
												func = "turnToTargetAtYaw",
												params = {
													{
														field = "tTargetActorId"
													},
													{
														const = 180
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
									class = "Action",
									id = "6",
									properties = {
										{
											Method = {
												func = "showEmojiBubble",
												params = {
													{
														const = "Alert"
													},
													{
														const = 0
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
												func = "playAction",
												params = {
													{
														const = "Behav_Alert"
													},
													{
														const = 0
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
						class = "Sequence",
						id = "21",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									class = "Action",
									id = "20",
									properties = {
										{
											Method = {
												func = "moveToTargetPos",
												params = {
													{
														field = "tTargetActorId"
													},
													{
														const = 20
													},
													{
														const = 5
													},
													{
														const = 0
													},
													{
														const = 30
													},
													{
														const = true
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
														const = BaseEnum.SpeedRateType.Mid
													},
													{
														const = BaseEnum.PathFindType.Auto
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
											ResultResumeOption = "BT_ResumeSelf"
										}
									},
									attachments = {},
									children = {}
								}
							},
							{
								node = {
									class = "Action",
									id = "22",
									properties = {
										{
											Method = {
												func = "turnToTargetAtYaw",
												params = {
													{
														field = "tTargetActorId"
													},
													{
														const = 180
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
									class = "Action",
									id = "23",
									properties = {
										{
											Method = {
												func = "showEmojiBubble",
												params = {
													{
														const = "Alert"
													},
													{
														const = 0
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
									id = "24",
									properties = {
										{
											Method = {
												func = "playAction",
												params = {
													{
														const = "Behav_Alert"
													},
													{
														const = 0
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
						class = "Sequence",
						id = "19",
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
												func = "moveToTargetPos",
												params = {
													{
														field = "tTargetActorId"
													},
													{
														const = 20
													},
													{
														const = 2.5
													},
													{
														const = 0
													},
													{
														const = 30
													},
													{
														const = true
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
														const = BaseEnum.SpeedRateType.Mid
													},
													{
														const = BaseEnum.PathFindType.Auto
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
											ResultResumeOption = "BT_ResumeSelf"
										}
									},
									attachments = {},
									children = {}
								}
							},
							{
								node = {
									class = "Action",
									id = "26",
									properties = {
										{
											Method = {
												func = "turnToTargetAtYaw",
												params = {
													{
														field = "tTargetActorId"
													},
													{
														const = 0
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
				}
			}
		}
	}
}

return PBT_Com_Alert
