-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_Pet_Command_MasterCrouchAndCatchMode.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Pet_Command_MasterCrouchAndCatchMode = {
	behavior = {
		name = "ParmonBehaviorTree/SubTree/PBT_Pet_Command_MasterCrouchAndCatchMode",
		useForRoute = false,
		version = 5,
		agenttype = "PetAgent",
		properties = {},
		pars = {},
		attachments = {},
		node = {
			id = "1",
			class = "Sequence",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						id = "4",
						class = "DecoratorAlwaysRunning",
						properties = {
							{
								DecorateWhenChildEnds = "false"
							}
						},
						attachments = {
							{
								id = "6",
								transition = false,
								effector = false,
								precondition = true,
								class = "Precondition",
								properties = {
									{
										BinaryOperator = "And"
									},
									{
										Operator = "Equal"
									},
									{
										Opl = {
											func = "masterIsInCrouch"
										}
									},
									{
										Opr2 = {
											const = true
										}
									},
									{
										Phase = "Both"
									}
								}
							},
							{
								id = "7",
								transition = false,
								effector = false,
								precondition = true,
								class = "Precondition",
								properties = {
									{
										BinaryOperator = "Or"
									},
									{
										Operator = "Equal"
									},
									{
										Opl = {
											func = "masterIsInCatchMode"
										}
									},
									{
										Opr2 = {
											const = true
										}
									},
									{
										Phase = "Both"
									}
								}
							},
							{
								id = "11",
								transition = false,
								effector = false,
								precondition = true,
								class = "Precondition",
								properties = {
									{
										BinaryOperator = "Or"
									},
									{
										Operator = "Equal"
									},
									{
										Opl = {
											func = "masterIsInMagnesisMode"
										}
									},
									{
										Opr2 = {
											const = true
										}
									},
									{
										Phase = "Both"
									}
								}
							},
							{
								id = "5",
								transition = false,
								effector = false,
								precondition = true,
								class = "Precondition",
								properties = {
									{
										BinaryOperator = "And"
									},
									{
										Operator = "Equal"
									},
									{
										Opl = {
											func = "isInCombat",
											params = {
												{
													const = 0
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
									id = "10",
									class = "Action",
									properties = {
										{
											Method = {
												func = "petMoveWithMasterCrouchAndCatchMode",
												params = {
													{
														const = 0
													},
													{
														const = BaseEnum.SpeedRateType.Slow
													},
													{
														const = 0
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

return PBT_Pet_Command_MasterCrouchAndCatchMode
