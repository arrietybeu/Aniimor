-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\_Behav\\PBT_Behav_Com_SwimMimicryOutAndLeave.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Behav_Com_SwimMimicryOutAndLeave = {
	behavior = {
		version = 22,
		useForRoute = false,
		name = "ParmonBehaviorTree/SubTree/_Behav/PBT_Behav_Com_SwimMimicryOutAndLeave",
		agenttype = "CombatAgent",
		properties = {},
		pars = {},
		attachments = {},
		node = {
			class = "Sequence",
			id = "2",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						class = "IfElse",
						id = "10",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									class = "Condition",
									id = "9",
									properties = {
										{
											Operator = "Equal"
										},
										{
											Opl = {
												func = "checkCharacterState",
												params = {
													{
														const = "SWIMMIMICRY"
													},
													{}
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
									id = "7",
									properties = {
										{
											Method = {
												func = "switchToState",
												params = {
													{
														const = "SWIMMING"
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
							},
							{
								node = {
									class = "True",
									id = "12",
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
						class = "ReferencedBehavior",
						id = "8",
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

return PBT_Behav_Com_SwimMimicryOutAndLeave
