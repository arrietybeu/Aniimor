-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\_Behav\\PBT_Behav_Home_Operate.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Behav_Home_Operate = {
	behavior = {
		useForRoute = false,
		name = "ParmonBehaviorTree/SubTree/_Behav/PBT_Behav_Home_Operate",
		agenttype = "CombatAgent",
		version = 28,
		properties = {},
		pars = {
			{
				const = "",
				name = "tAnimationKey",
				value = "",
				type = "string"
			},
			{
				const = "",
				name = "tFaceAnimationkey",
				value = "",
				type = "string"
			},
			{
				name = "tTargetPos",
				value = "0:",
				type = "vector<float>",
				const = {}
			},
			{
				const = 0,
				name = "tYaw",
				value = "0",
				type = "float"
			},
			{
				name = "tWorkPos",
				value = "0:",
				type = "vector<float>",
				const = {}
			}
		},
		attachments = {},
		node = {
			class = "Sequence",
			id = "2",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						class = "Action",
						id = "19",
						properties = {
							{
								Method = {
									func = "switchToHomeWorkNow",
									params = {
										{
											field = "tWorkPos"
										},
										{
											field = "tYaw"
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
						id = "9",
						properties = {
							{
								Method = {
									func = "playAction",
									params = {
										{
											field = "tAnimationKey"
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
						attachments = {
							{
								effector = false,
								precondition = true,
								class = "Precondition",
								id = "10",
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
											func = "playRawAnimation",
											params = {
												{
													field = "tFaceAnimationkey"
												}
											}
										}
									},
									{
										Opr2 = {
											const = BaseEnum.EBTStatus.BT_SUCCESS
										}
									},
									{
										Phase = "Enter"
									}
								}
							},
							{
								effector = true,
								precondition = false,
								class = "Effector",
								id = "11",
								transition = false,
								properties = {
									{
										Operator = "Invalid"
									},
									{
										Opl = {
											func = "stopRawAnimation",
											params = {
												{
													field = "tFaceAnimationkey"
												}
											}
										}
									},
									{
										Phase = "Both"
									}
								}
							},
							{
								effector = true,
								precondition = false,
								class = "Effector",
								id = "16",
								transition = false,
								properties = {
									{
										Operator = "Invalid"
									},
									{
										Opl = {
											func = "switchToStateNow",
											params = {
												{
													const = "LOCOMOTION"
												},
												{
													const = ""
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
				}
			}
		}
	}
}

return PBT_Behav_Home_Operate
