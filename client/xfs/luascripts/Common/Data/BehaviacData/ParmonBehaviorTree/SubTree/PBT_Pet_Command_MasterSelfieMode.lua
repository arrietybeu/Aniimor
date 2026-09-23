-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\PBT_Pet_Command_MasterSelfieMode.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Pet_Command_MasterSelfieMode = {
	behavior = {
		version = 6,
		useForRoute = false,
		agenttype = "PetAgent",
		name = "ParmonBehaviorTree/SubTree/PBT_Pet_Command_MasterSelfieMode",
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
						id = "2",
						class = "DecoratorAlwaysRunning",
						properties = {
							{
								DecorateWhenChildEnds = "false"
							}
						},
						attachments = {
							{
								precondition = true,
								id = "3",
								class = "Precondition",
								transition = false,
								effector = false,
								properties = {
									{
										BinaryOperator = "And"
									},
									{
										Operator = "Equal"
									},
									{
										Opl = {
											func = "masterIsInSelfieMode"
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
								precondition = true,
								id = "4",
								class = "Precondition",
								transition = false,
								effector = false,
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
									id = "5",
									class = "Action",
									properties = {
										{
											Method = {
												func = "petMoveWithMasterSelfieMode",
												params = {
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

return PBT_Pet_Command_MasterSelfieMode
