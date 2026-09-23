-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\_NPC\\PBT_NPC_LeadPatrol_WaitPlayer.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_NPC_LeadPatrol_WaitPlayer = {
	behavior = {
		version = 5,
		useForRoute = false,
		agenttype = "CombatAgent",
		name = "ParmonBehaviorTree/SubTree/_NPC/PBT_NPC_LeadPatrol_WaitPlayer",
		properties = {},
		pars = {
			{
				const = 0,
				type = "int",
				value = "0",
				name = "tLeadTargetActorId"
			}
		},
		attachments = {},
		node = {
			id = "3",
			class = "Selector",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						id = "2",
						class = "Sequence",
						properties = {},
						attachments = {
							{
								effector = false,
								precondition = true,
								class = "Precondition",
								id = "11",
								transition = false,
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
													field = "tLeadTargetActorId"
												},
												{
													const = 0
												},
												{
													const = 4
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
										Opr2 = {
											const = false
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
									id = "6",
									class = "Action",
									properties = {
										{
											Method = {
												func = "turnToTarget",
												params = {
													{
														field = "tLeadTargetActorId"
													},
													{
														const = false
													},
													{
														const = 3
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
									class = "Action",
									properties = {
										{
											Method = {
												func = "playSleAnimationOnce",
												params = {
													{
														const = "Emotion_Cheer_Start"
													},
													{
														const = ""
													},
													{
														const = "Emotion_Cheer_End"
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
									id = "8",
									class = "Action",
									properties = {
										{
											Method = {
												func = "waitTime",
												params = {
													{
														const = 2
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
						id = "7",
						class = "True",
						properties = {},
						attachments = {},
						children = {}
					}
				}
			}
		}
	}
}

return PBT_NPC_LeadPatrol_WaitPlayer
