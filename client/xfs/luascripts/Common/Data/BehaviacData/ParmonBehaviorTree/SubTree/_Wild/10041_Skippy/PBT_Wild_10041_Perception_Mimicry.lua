-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\ParmonBehaviorTree\\SubTree\\_Wild\\10041_Skippy\\PBT_Wild_10041_Perception_Mimicry.lua

local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local Enums = require("Common.AI.Behaviac.Enums")
local PBT_Wild_10041_Perception_Mimicry = {
	behavior = {
		name = "ParmonBehaviorTree/SubTree/_Wild/10041_Skippy/PBT_Wild_10041_Perception_Mimicry",
		version = 34,
		useForRoute = false,
		agenttype = "PuppetAgent",
		properties = {},
		pars = {
			{
				name = "tSensorTgtId",
				const = 0,
				type = "int",
				value = "0"
			},
			{
				name = "tTgtId",
				const = 0,
				type = "int",
				value = "0"
			},
			{
				name = "tAnimationKey",
				const = "",
				type = "string",
				value = ""
			},
			{
				name = "tCharacterState",
				const = "",
				type = "string",
				value = ""
			}
		},
		attachments = {},
		node = {
			class = "Sequence",
			id = "18",
			properties = {},
			attachments = {},
			children = {
				{
					node = {
						class = "Assignment",
						id = "24",
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
						class = "Action",
						id = "68",
						properties = {
							{
								Method = {
									func = "switchToState",
									params = {
										{
											const = "SWIMMIMICRY"
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
				},
				{
					node = {
						class = "IfElse",
						id = "87",
						properties = {},
						attachments = {},
						children = {
							{
								node = {
									class = "Condition",
									id = "70",
									properties = {
										{
											Operator = "GreaterEqual"
										},
										{
											Opl = {
												func = "getDistByTgt",
												params = {
													{
														field = "tSensorTgtId"
													},
													{
														const = true
													},
													{
														const = true
													},
													{
														const = 0
													}
												}
											}
										},
										{
											Opr = {
												const = 30
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
									id = "72",
									properties = {
										{
											Method = {
												func = "switchToState",
												params = {
													{
														const = "SWIMMIMICRYOUT"
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
							},
							{
								node = {
									class = "Noop",
									id = "88",
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

return PBT_Wild_10041_Perception_Mimicry
